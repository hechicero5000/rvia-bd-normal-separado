-- **** RVIA Prompts ****

-- TABLAS
CREATE TABLE IF NOT EXISTS public.cat_lenguajes (
    idu_lenguaje serial NOT NULL,
    nom_lenguaje VARCHAR(255) NOT NULL,
    fec_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (idu_lenguaje)
);

COMMENT ON TABLE public.cat_lenguajes IS 'Tabla que almacena los lenguajes de programación soportados';
COMMENT ON COLUMN public.cat_lenguajes.idu_lenguaje IS 'Identificador del lenguaje de programación';
COMMENT ON COLUMN public.cat_lenguajes.nom_lenguaje IS 'Nombre del lenguaje de programación';
COMMENT ON COLUMN public.cat_lenguajes.fec_creacion IS 'fecha de registro del lenguaje de programación';

CREATE TABLE IF NOT EXISTS public.cat_esquemas (
    idu_esquema SERIAL PRIMARY KEY,         
    des_descripcion VARCHAR(255) NOT NULL   
);

COMMENT ON TABLE public.cat_esquemas IS 'Esquemas de prompts para IA';
COMMENT ON COLUMN public.cat_esquemas.idu_esquema IS 'Identificador del esquema';
COMMENT ON COLUMN public.cat_esquemas.des_descripcion IS 'Nombre del esquema';

CREATE TABLE IF NOT EXISTS public.mae_prompts (
    idu_prompt SERIAL PRIMARY KEY,                      
    idu_esquema INT NOT NULL,                           
    body TEXT NOT NULL,                                 
    fec_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,     
    num_efectividad BIGINT,
    num_accion INT NOT NULL,                              
    des_comentarios TEXT,                                
    opc_es_activo BOOLEAN DEFAULT TRUE,                   
    CONSTRAINT fk_esquema FOREIGN KEY (idu_esquema) REFERENCES cat_esquemas(idu_esquema)
);

COMMENT ON TABLE public.mae_prompts IS 'Prompts probados y evaluados para usar';
COMMENT ON COLUMN public.mae_prompts.idu_prompt IS 'Identificador del prompt';
COMMENT ON COLUMN public.mae_prompts.idu_esquema IS 'Identificador del esquema usando en el prompt';
COMMENT ON COLUMN public.mae_prompts.body IS 'Prompt usado';
COMMENT ON COLUMN public.mae_prompts.fec_creacion IS 'Fecha de registro del prompt';
COMMENT ON COLUMN public.mae_prompts.num_efectividad IS 'Efectividad del prompt 1-10';
COMMENT ON COLUMN public.mae_prompts.num_accion IS 'Acción a realizar con el prompt [Actualizar, Sanitizar, Migrar]';
COMMENT ON COLUMN public.mae_prompts.des_comentarios IS 'Comentarios agregados';
COMMENT ON COLUMN public.mae_prompts.opc_es_activo IS 'Bandera para saber si es un prompt valido';

CREATE TABLE IF NOT EXISTS public.ctl_lenguajes_x_prompts (
    idu_lenguaje INT NOT NULL,                                 
    idu_prompt INT NOT NULL,                                  
    CONSTRAINT fk_lenguaje FOREIGN KEY (idu_lenguaje) REFERENCES cat_lenguajes(idu_lenguaje),   
    CONSTRAINT fk_prompt FOREIGN KEY (idu_prompt) REFERENCES mae_prompts(idu_prompt),
    PRIMARY KEY (idu_lenguaje, idu_prompt)                    
);

COMMENT ON TABLE public.ctl_lenguajes_x_prompts IS 'Relación entre lenguajes de programación y prompts creados';
COMMENT ON COLUMN public.ctl_lenguajes_x_prompts.idu_lenguaje IS 'Identificador del lenguajes de programación para el que se probo';
COMMENT ON COLUMN public.ctl_lenguajes_x_prompts.idu_prompt IS 'Identificado del prompt creado para ese lenguaje de programación';

-- GRANT PERMISOS

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.cat_lenguajes TO sysrvia_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.cat_esquemas TO sysrvia_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.mae_prompts TO sysrvia_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.ctl_lenguajes_x_prompts TO sysrvia_dev;

-- INDICES

CREATE INDEX ix_cat_esquemas_des_descripcion ON public.cat_esquemas(des_descripcion);

CREATE INDEX ix_mae_prompts_idu_esquema ON public.mae_prompts(idu_esquema);
CREATE INDEX ix_mae_prompts_num_efectividad ON public.mae_prompts(num_efectividad);

CREATE INDEX ix_ctl_lenguajes_x_prompts_idu_lenguaje ON public.ctl_lenguajes_x_prompts(idu_lenguaje);
CREATE INDEX ix_ctl_lenguajes_x_prompts_idu_prompt ON public.ctl_lenguajes_x_prompts(idu_prompt);

CREATE INDEX ix_cat_lenguajes_nom_lenguaje ON public.cat_lenguajes(nom_lenguaje);


-- TYPE
CREATE TYPE typ_prompt_esquema_lenguaje AS ( 
    idu_prompt INT,
    body TEXT,
    fec_creacion DATE,
    num_efectividad BIGINT,
    num_accion INT
);

COMMENT ON TYPE typ_prompt_esquema_lenguaje IS 
'Tipo typ_prompt_esquema_lenguaje que representa la estructura que devuelve la función fun_obtener_prompts_por_lenguaje_esquema.
Sus campos:
    - idu_prompt: Identificador único del prompt.
    - body: Contenido del prompt.
    - fec_creacion: Fecha de creación del prompt.
    - num_efectividad: Efectividad del prompt.
    - num_accion: Número de acción del prompt.';

-- Funcion fun_obtener_prompts_por_lenguaje_esquema
CREATE OR REPLACE FUNCTION fun_obtener_prompts_por_lenguaje_esquema(
    idu_lenguaje INT, 
    idu_esquema  INT,
    num_cantidad INT,
    num_accion INT
) 
RETURNS SETOF typ_prompt_esquema_lenguaje AS $$ 
BEGIN
    RETURN QUERY
    SELECT p.idu_prompt, 
           p.body, 
           p.fec_creacion::DATE, 
           p.num_efectividad,
           p.num_accion
    FROM mae_prompts p
    INNER JOIN ctl_lenguajes_x_prompts lxp 
            ON p.idu_prompt = lxp.idu_prompt
    INNER JOIN cat_lenguajes cl 
            ON lxp.idu_lenguaje = cl.idu_lenguaje
    WHERE cl.idu_lenguaje = fun_obtener_prompts_por_lenguaje_esquema.idu_lenguaje
      AND p.idu_esquema = fun_obtener_prompts_por_lenguaje_esquema.idu_esquema
      AND p.num_accion = fun_obtener_prompts_por_lenguaje_esquema.num_accion
    ORDER BY p.num_efectividad DESC
    LIMIT fun_obtener_prompts_por_lenguaje_esquema.num_cantidad;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fun_obtener_prompts_por_lenguaje_esquema (INT,INT,INT,INT) 
IS 'Devuelve una lista de prompts para un lenguaje de programación y esquema, 
ordenados de mayor a menor efectividad.
Parámetros:
    - idu_lenguaje= identificador del lenguaje de programación,
    - idu_esquema=  identificador del esquema de prompt,
    - num_cantidad= número máximo de elementos a listar,
    - num_accion= número de acción del prompt';


-- INSERT
 
-- cat_esquemas
INSERT INTO cat_esquemas (idu_esquema, des_descripcion) VALUES (0, 'RTF');
INSERT INTO cat_esquemas (idu_esquema, des_descripcion) VALUES (1, 'TAO');
INSERT INTO cat_esquemas (idu_esquema, des_descripcion) VALUES (2, 'BAB');
INSERT INTO cat_esquemas (idu_esquema, des_descripcion) VALUES (3, 'CARE');

   -- CAT_LENGUAJES
INSERT INTO public.cat_lenguajes (idu_lenguaje,nom_lenguaje, fec_creacion) VALUES
(1,'76a0df877a5be0ca7e4101abb1f88af7:93113c0a6772b891c06971e4a26326a4', NOW()),   --PHP
(2,'b9837c89e061b9ac1aa7d5cb35b22087:755ef89b24776e271f4a3f6764b4bd98', NOW()),   --Python
(3,'30a9a9cb821dd90704bb217b3bece748:ccdbb3924a002c290a48871cb44a0814', NOW()),   --Java
(4,'3e40db6094a4236a83abf8a97b491731:f78126808dc93ab6e10c83e24c549907', NOW()),   --JavaScript
(5,'4faa41f986e8aed0b992b31bc04332c1:00b8fccc581ad2899a06be8c122e00f3', NOW()),   --C#
                                                                                  
(6,'755624a4130de31bfb7cc27ea6cd2d0b:1c30a9a5fc63ea61549b80012f90b10d', NOW()),   --C
(7,'49a00625c36cd034d9eb903de1178811:8a3251392f8ab75aa742e4a7cffb2868', NOW()),   --C++
(8,'78ff7ca63b9d5497cb510bc21b960003:7250c5417b4a74b3f3125775b03612d4', NOW()),   --CSS
(9,'48550f41b1e2551c032b69b2284ab3db:987c6438c2aaab3beada24bda4654425', NOW()),   --Clojure
(10,'9c073e195b25b85887570a248850a567:7c0e29cf52c5e3af96fb5e8267b8f685', NOW()),  --Dart

(11,'09c689dc42a59ca4c15a50917763b66d:88f5b7442353f294b0e83d0dbcc09f30', NOW()),  --Elixir
(12,'1efe79db9fa6bfe23f517c579d75b26f:4ffa1e4b5c87822d508ee69b5fe11df1', NOW()),  --Erlang
(13,'cf1976df7d9b0a1a32132e7b0c137d8c:437de34f7d260e98869ba29550e99de8', NOW()),  --Fortran
(14,'0adc0743fe7bcdad2123bbdeba3acba2:5e57cfdfee66b89f8ee4d14e456e1ebb', NOW()),  --Go
(15,'c0ea4e8197d7711b4c3e55129b8480cb:d7ec9bde59e12a63825e9771b7cbb10a', NOW()),  --GoogleSQL

(16,'7d42e2d0a16761769b1e432bd5e7f901:a1e609315ec46e5987bf2e2023c366ab', NOW()),  --Groovy
(17,'2bb9ed86ddadbef8c219f92a619911ca:c8d13cdaa9534b3f120a92c9009d6fba', NOW()),  --Haskell
(18,'684331368b8bdee0866c1cc7bafa4702:be77cf2fd634db1dd6a7135392bbaa2a', NOW()),  --HTML
(19,'e59cdb781863482816a5043a09b65ed0:79d9372b76f7381ccc3a4d5a6f4064f186ab7f04d54a056181d73966e22dc6cd', NOW()), --JavaServer Pages
(20,'6425e64c8ed56de5aa8cd3d869bca066:007097ce2e252b242a58b689ba350137', NOW()),  --Kotlin

(21,'8e22933171ea90ae86a4f24043809855:ac2b5925cb6c80acd12c66107721da65f112ee075dba19205b16311cdc71b470', NOW()), --Lean (proof assistant)
(22,'7183100e3b8a6d28f304d62024e34c2b:fb31325a0e45789123063b0dcd04e234', NOW()),  --Lua
(23,'013b4a1f2cb5e51d7a8468cb2e6bf6ed:f5fce403f4873193c6cc53d965404e3e', NOW()),  --Objective-C
(24,'29a094d4067f91500a0e2741a08fb1ae:475a240f53bffc48b3c070909f22f0e4', NOW()),  --OCaml
(25,'0cf507892a73c0118a921a863b5ba033:4a3cfe613954daaecc0e6c033079f286', NOW()),  --Perl

(26,'c4d734e48a9cf6324f1d8cd430488f07:e6edd995e6d82e70669c70890c61acee', NOW()),  --R
(27,'e726b5cfccea24885e23716ba2035fc6:a8b15c1826588f54312066ef6408668e', NOW()),  --Ruby
(28,'ecc3a1805335de7a5b6259355dcb9c04:58090be7838fdd736c95ff05cae41235', NOW()),  --Rust
(29,'c5bd9b4197dbd0da87eb466296208493:838bb62365eb4e218f336ff93e3b8e61', NOW()),  --Scala
(30,'c8f6b3529ffabc0c8b956f7ab1163095:d7ff8ec70c09932aa4a4c7e272890b7d', NOW()),  --Shell script

(31,'f956ae48c99739113367665f22da9dc6:35e4c24f2a008917a133b4d0936d4233', NOW()),  --Solidity
(32,'8baa0f1dfda4eecb82cd185e6450cf25:87171b015d9dfa1fffdafc53bcab9781', NOW()),  --SQL
(33,'120d725a1a823dfbce70a4e7d3935637:a8adf9a96c36007c2bc7bd949abd24c4', NOW()),  --Swift
(34,'316bd73b9f698ad6a39b0011e2234123:5f4634b14ffaa085378fd0cb625a2b63', NOW()),  --TypeScript
(35,'014b2dfbb772aa43483f1289aac36f5f:05f3a0b123c55785124aedbc45e76fa3', NOW()),  --XML

(36,'7500c1ced89b650946090bc7ddcde7aa:27653c000a009b4bc1d3dba635f0c603', NOW()),  --Verilog
(37,'1b7d1190c5feed2a17a6637fd924a417:b701e376be782b67ddc2511ee087e6ee', NOW()),  --YAML
(38,'d6d51d53e3d22625b9c2e08c3bf1f3df:fff4fdefb7aed0a5b177bc9552b122a0', NOW()),  --Visual Basic
(39,'e3f1c4b7ab3617f0bbf3cd740a8b67c7:469ed7855ff3bbfa64fb410e60eaf37b65447b80249425f7d10b7e5f03e13ac4', NOW()),  --Visual Basic .NET
(40,'b3a43ba14b0af4bac5373b6987bc5f6a:5fbbec5205c82af81b62805fcac9a27a', NOW()),  --VUE

(41,'ab920246a31c3981446145cf369b483e:f3d567f70f68e28530f54fb87789abc6', NOW())  --REACT
ON CONFLICT (idu_lenguaje) DO NOTHING;