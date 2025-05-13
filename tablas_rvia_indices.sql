-- **** RVIA ***

-- TABLAS
CREATE TABLE IF NOT EXISTS public.cat_roles (
    idu_rol serial NOT NULL,
    nom_rol VARCHAR(255) NOT NULL,
    num_nivel INT NOT NULL DEFAULT 0,
    fec_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (idu_rol)
);

COMMENT ON TABLE public.cat_roles IS 'Tabla que almacena los diferentes roles de trabajo';
COMMENT ON COLUMN public.cat_roles.idu_rol IS 'Identificador del rol de trabajo';
COMMENT ON COLUMN public.cat_roles.nom_rol IS 'Nombre del rol de trabajo';
COMMENT ON COLUMN public.cat_roles.num_nivel IS 'Nivel del rol de trabajo 
    0 - Administrador, 
    1 - Autorizador, 
    2 - Usuario, 
    3 - Invitado';
COMMENT ON COLUMN public.cat_roles.fec_creacion IS 'Fecha de registro del rol de trabajo';
COMMENT ON COLUMN public.cat_roles.fec_actualizacion IS 'Fecha de actualización del registro del rol de trabajo';

CREATE TABLE IF NOT EXISTS public.cat_colaboradores (
    idu_usuario serial NOT NULL,
    num_empleado INT NOT NULL UNIQUE,
    nom_usuario TEXT NOT NULL,
    idu_rol INT NOT NULL,
    nom_correo TEXT NOT NULL UNIQUE,
    nom_contrasena TEXT NOT NULL,
    opc_es_activo BOOLEAN NOT NULL DEFAULT true,
    fec_creacion TIMESTAMP NOT NULL DEFAULT now(),
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT now(),
    CONSTRAINT cat_colaboradores_idu_rol_fkey FOREIGN KEY (idu_rol) REFERENCES public.cat_roles(idu_rol),
    PRIMARY KEY (idu_usuario)
);

COMMENT ON TABLE public.cat_colaboradores IS 'Tabla que almacena los usuarios';
COMMENT ON COLUMN public.cat_colaboradores.idu_usuario IS 'Identificador del usuario';
COMMENT ON COLUMN public.cat_colaboradores.num_empleado IS 'Número de empleado';
COMMENT ON COLUMN public.cat_colaboradores.nom_usuario IS 'Nombre del usuario';
COMMENT ON COLUMN public.cat_colaboradores.idu_rol IS 'Identificador del rol del usuario';
COMMENT ON COLUMN public.cat_colaboradores.nom_correo IS 'Correo electrónico del usuario';
COMMENT ON COLUMN public.cat_colaboradores.nom_contrasena IS 'Contrasena del usuario';
COMMENT ON COLUMN public.cat_colaboradores.opc_es_activo IS 'Bandera para saber si un usuario esta activo';
COMMENT ON COLUMN public.cat_colaboradores.fec_creacion IS 'Fecha de registro del usuario';
COMMENT ON COLUMN public.cat_colaboradores.fec_actualizacion IS 'Fecha de actualización del registro del usuario';

CREATE TABLE IF NOT EXISTS public.ctl_estatus_aplicaciones (
    idu_estatus_aplicacion serial NOT NULL,
    des_estatus_aplicacion TEXT NOT NULL,
    fec_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (idu_estatus_aplicacion)
);

COMMENT ON TABLE public.ctl_estatus_aplicaciones IS 'Tabla que almacena los diferentes estatus de las aplicaciones';
COMMENT ON COLUMN public.ctl_estatus_aplicaciones.idu_estatus_aplicacion IS 'Identificador del estatus';
COMMENT ON COLUMN public.ctl_estatus_aplicaciones.des_estatus_aplicacion IS 'Descripción del estatus de la aplicación 
    1- En proceso 
    2- En espera 
    3- Finalizado 
    4-Rechazado';
COMMENT ON COLUMN public.ctl_estatus_aplicaciones.fec_creacion IS 'Fecha de registro del estatus';
COMMENT ON COLUMN public.ctl_estatus_aplicaciones.fec_actualizacion IS 'Fecha de actualización del registro del estatus';

CREATE TABLE IF NOT EXISTS public.ctl_codigo_fuentes (
    idu_codigo_fuente serial NOT NULL,
    nom_codigo_fuente TEXT NOT NULL,
    nom_directorio TEXT NOT NULL,
    fec_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (idu_codigo_fuente)
);

COMMENT ON TABLE public.ctl_codigo_fuentes IS 'Tabla que almacena los códigos fuentes';
COMMENT ON COLUMN public.ctl_codigo_fuentes.idu_codigo_fuente IS 'Identificador del código fuente';
COMMENT ON COLUMN public.ctl_codigo_fuentes.nom_codigo_fuente IS 'Nombre del código fuente';
COMMENT ON COLUMN public.ctl_codigo_fuentes.nom_directorio IS 'Directorio donde se almacena el código fuente';
COMMENT ON COLUMN public.ctl_codigo_fuentes.fec_creacion IS 'Fecha de registro del código fuente';
COMMENT ON COLUMN public.ctl_codigo_fuentes.fec_creacion IS 'Fecha de actualización de registro del código fuente';

CREATE TABLE IF NOT EXISTS public.mae_aplicaciones (
    idu_aplicacion serial NOT NULL,
    idu_proyecto bigint NOT NULL,
    nom_aplicacion TEXT NOT NULL,
    idu_usuario INT NOT NULL,
    num_accion INT NOT NULL,
    opc_arquitectura JSONB DEFAULT '{"1": false, "2": false, "3": false, "4": false}',
    clv_estatus INT NOT NULL,
    opc_lenguaje INT NOT NULL DEFAULT 0,
    opc_estatus_doc INT NOT NULL DEFAULT 0,
    opc_estatus_doc_code INT NOT NULL DEFAULT 0,
    opc_estatus_caso INT NOT NULL DEFAULT 0,
    opc_estatus_calificar INT NOT NULL DEFAULT 0,
    idu_codigo_fuente INT,

    fec_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT mae_aplicaciones_idu_usuario_fkey FOREIGN KEY (idu_usuario) REFERENCES public.cat_colaboradores(idu_usuario),
    CONSTRAINT mae_aplicaciones_idu_codigo_fuente_fkey FOREIGN KEY (idu_codigo_fuente) REFERENCES public.ctl_codigo_fuentes(idu_codigo_fuente),
    CONSTRAINT mae_aplicaciones_clv_estatus_fkey FOREIGN KEY (clv_estatus) REFERENCES public.ctl_estatus_aplicaciones(idu_estatus_aplicacion),
    PRIMARY KEY (idu_aplicacion)
);

COMMENT ON TABLE public.mae_aplicaciones IS 'Tabla que almacena las aplicaciones';
COMMENT ON COLUMN public.mae_aplicaciones.idu_aplicacion IS 'Identificador de la aplicación';
COMMENT ON COLUMN public.mae_aplicaciones.idu_proyecto IS 'Identificador único generado de la aplicación';
COMMENT ON COLUMN public.mae_aplicaciones.nom_aplicacion IS 'Nombre de la aplicación';
COMMENT ON COLUMN public.mae_aplicaciones.idu_usuario IS 'Identificador del usuario responsable de la aplicación';
COMMENT ON COLUMN public.mae_aplicaciones.num_accion IS 'Identificador de acción a trabajar 
    0-N/A 
    1- Actualizacion 
    2- Sanitización 
    3-Migración';
COMMENT ON COLUMN public.mae_aplicaciones.opc_arquitectura IS 'Objeto para opciones de arquitectura a trabajar 
    1- Documentación completa 
    2- Documentacion por código 
    3- Casos de prueba 
    4- Calificación de código';
COMMENT ON COLUMN public.mae_aplicaciones.clv_estatus IS 'Clave del estatus de la aplicación';
COMMENT ON COLUMN public.mae_aplicaciones.opc_lenguaje IS 'Identificador del lenguaje de programación para migrar';
COMMENT ON COLUMN public.mae_aplicaciones.opc_estatus_doc IS 'Estatus del proceso de documentacion completa de la aplicación';
COMMENT ON COLUMN public.mae_aplicaciones.opc_estatus_doc_code IS 'Estatus del proceso de documentacion por código de la aplicación';
COMMENT ON COLUMN public.mae_aplicaciones.opc_estatus_caso IS 'Estatus del proceso de casos de prueba completa de la aplicación';
COMMENT ON COLUMN public.mae_aplicaciones.opc_estatus_calificar IS 'Estatus del proceso de calificación de código de la aplicación';
COMMENT ON COLUMN public.mae_aplicaciones.idu_codigo_fuente IS 'Identificador del código fuente de la aplicación';
COMMENT ON COLUMN public.mae_aplicaciones.fec_creacion IS 'Fecha de registro de la aplicación';
COMMENT ON COLUMN public.mae_aplicaciones.fec_actualizacion IS 'Fecha de actualización deñ registro de la aplicación';

CREATE TABLE IF NOT EXISTS public.mov_escaneos (
    idu_escaneo serial NOT NULL,
    nom_escaneo TEXT NOT NULL,
    nom_directorio TEXT NOT NULL,
    idu_aplicacion INT NOT NULL,
    fec_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT mov_escaneos_idu_aplicacion_fuente_fkey FOREIGN KEY (idu_aplicacion) REFERENCES public.mae_aplicaciones(idu_aplicacion),
    PRIMARY KEY (idu_escaneo)
);

COMMENT ON TABLE public.mov_escaneos IS 'Tabla que almacena los escaneos realizados';
COMMENT ON COLUMN public.mov_escaneos.idu_escaneo IS 'Identificador del escaneo';
COMMENT ON COLUMN public.mov_escaneos.nom_escaneo IS 'Nombre del escaneo';
COMMENT ON COLUMN public.mov_escaneos.nom_directorio IS 'Directorio donde se almacena el escaneo';
COMMENT ON COLUMN public.mov_escaneos.idu_aplicacion IS 'Identificador de la aplicación del escaneo';
COMMENT ON COLUMN public.mov_escaneos.fec_creacion IS 'Fecha de registro del escaneo';

CREATE TABLE IF NOT EXISTS public.ctl_usuarios_por_aplicaciones (
    idu serial NOT NULL,
    idu_usuario INT NOT NULL,
    idu_aplicacion INT NOT NULL,
    CONSTRAINT ctl_usuarios_por_aplicaciones_idu_usuario_fkey FOREIGN KEY (idu_usuario) REFERENCES public.cat_colaboradores(idu_usuario),
    CONSTRAINT ctl_usuarios_por_aplicaciones_idu_aplicacion_fkey FOREIGN KEY (idu_aplicacion) REFERENCES public.mae_aplicaciones(idu_aplicacion),
    PRIMARY KEY (idu)
);
--sin datos para comentar

CREATE TABLE IF NOT EXISTS public.ctl_aplicaciones_por_escaneos (
    idu serial NOT NULL,
    idu_aplicacion INT NOT NULL,
    idu_escaneo INT NOT NULL,
    CONSTRAINT ctl_aplicaciones_por_escaneos_idu_aplicacion_fkey FOREIGN KEY (idu_aplicacion) REFERENCES public.mae_aplicaciones(idu_aplicacion),
    CONSTRAINT ctl_aplicaciones_por_escaneos_idu_escaneo_fkey FOREIGN KEY (idu_escaneo) REFERENCES public.mov_escaneos(idu_escaneo),
    PRIMARY KEY (idu)
);
--sin datos para comentar

CREATE TABLE IF NOT EXISTS public.his_seguimiento_modificaciones (
    idu_seguimiento serial NOT NULL,
    nom_tabla TEXT NOT NULL,
    nom_accion TEXT NOT NULL,
    idu_usuario INT NOT NULL,
    fec_evento TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    identificador_registro JSONB,
    valores_anteriores JSONB,
    valores_nuevos JSONB,
	PRIMARY KEY (idu_seguimiento)
);
--sin datos para comentar

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

CREATE TABLE IF NOT EXISTS public.ctl_checkmarx (
    idu_checkmarx serial NOT NULL,
    nom_checkmarx TEXT NOT NULL,
    nom_directorio TEXT NOT NULL,
    idu_aplicacion INT NOT NULL,
    fec_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ctl_checkmarx_idu_aplicacion_fkey FOREIGN KEY (idu_aplicacion) REFERENCES public.mae_aplicaciones(idu_aplicacion),
    PRIMARY KEY (idu_checkmarx)
);

COMMENT ON TABLE public.ctl_checkmarx IS 'Tabla que almacena los Csv';
COMMENT ON COLUMN public.ctl_checkmarx.idu_checkmarx IS 'Identificador del csv';
COMMENT ON COLUMN public.ctl_checkmarx.nom_checkmarx IS 'Nombre del csv';
COMMENT ON COLUMN public.ctl_checkmarx.nom_directorio IS 'Directorio donde se almacena el csv';
COMMENT ON COLUMN public.ctl_checkmarx.idu_aplicacion IS 'Identificador de la aplicación a la que pertenece el csv';
COMMENT ON COLUMN public.ctl_checkmarx.fec_creacion IS 'Fecha de registro del csv';

CREATE TABLE IF NOT EXISTS public.mov_costos_proyectos (
    num_empleado bigint NOT NULL,
    id_proyecto bigint NOT NULL,
    nom_proyecto character varying(100) NOT NULL,
    nom_cliente_ia character(25) NOT NULL,
    val_monto numeric(15, 2) NOT NULL,
    des_descripcion TEXT NOT NULL,    
    fec_movto timestamp without time zone NOT NULL DEFAULT now(),
    keyx serial NOT NULL,
    CONSTRAINT pk_mov_costos_proyectos PRIMARY KEY (keyx)
) WITHOUT OIDS;

COMMENT ON TABLE public.mov_costos_proyectos IS 'Datos de empleados y sentencias encontradas en el parseo de un proyecto';
COMMENT ON COLUMN public.mov_costos_proyectos.num_empleado IS 'Número de empleado de la persona que ejecutó la aplicación';
COMMENT ON COLUMN public.mov_costos_proyectos.id_proyecto IS 'ID del Proyecto';
COMMENT ON COLUMN public.mov_costos_proyectos.nom_proyecto IS 'Nombre del Proyecto';
COMMENT ON COLUMN public.mov_costos_proyectos.nom_cliente_ia IS 'Nombre del cliente de IA que se utilizó';
COMMENT ON COLUMN public.mov_costos_proyectos.val_monto IS 'Costo del proyecto por uso de la IA';
COMMENT ON COLUMN public.mov_costos_proyectos.des_descripcion IS 'Descripción referente al proyecto o costos generados por la IA';

-- GRANT PERMISOS PARA CADA TABLA
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.cat_roles TO sysrvia_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.cat_colaboradores TO sysrvia_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.ctl_estatus_aplicaciones TO sysrvia_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.ctl_codigo_fuentes TO sysrvia_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.mae_aplicaciones TO sysrvia_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.mov_escaneos TO sysrvia_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.ctl_usuarios_por_aplicaciones TO sysrvia_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.ctl_aplicaciones_por_escaneos TO sysrvia_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.his_seguimiento_modificaciones TO sysrvia_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.cat_lenguajes TO sysrvia_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.ctl_checkmarx TO sysrvia_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.mov_costos_proyectos TO sysrvia_dev;

-- INDICES 
CREATE INDEX ix_cat_roles_nom_rol ON public.cat_roles(nom_rol);
CREATE INDEX ix_cat_roles_num_nivel ON public.cat_roles(num_nivel);

CREATE INDEX ix_cat_colaboradores_num_empleado ON public.cat_colaboradores(num_empleado);
CREATE INDEX ix_cat_colaboradores_idu_rol ON public.cat_colaboradores(idu_rol);
CREATE INDEX ix_cat_colaboradores_nom_usuario ON public.cat_colaboradores(nom_usuario);
CREATE INDEX ix_cat_colaboradores_nom_correo ON public.cat_colaboradores(nom_correo);

CREATE INDEX ix_ctl_estatus_aplicaciones_des_estatus_aplicacion ON public.ctl_estatus_aplicaciones(des_estatus_aplicacion);

CREATE INDEX ix_ctl_codigo_fuentes_nom_codigo_fuente ON public.ctl_codigo_fuentes(nom_codigo_fuente);

CREATE INDEX ix_mae_aplicaciones_idu_usuario ON public.mae_aplicaciones(idu_usuario);
CREATE INDEX ix_mae_aplicaciones_clv_estatus ON public.mae_aplicaciones(clv_estatus);
CREATE INDEX ix_mae_aplicaciones_num_accion ON public.mae_aplicaciones(num_accion);

CREATE INDEX ix_mov_escaneos_idu_aplicacion ON public.mov_escaneos(idu_aplicacion);

CREATE INDEX ix_ctl_usuarios_por_aplicaciones_idu_usuario ON public.ctl_usuarios_por_aplicaciones(idu_usuario);
CREATE INDEX ix_ctl_usuarios_por_aplicaciones_idu_aplicacion ON public.ctl_usuarios_por_aplicaciones(idu_aplicacion);

CREATE INDEX ix_ctl_aplicaciones_por_escaneos_idu_aplicacion ON public.ctl_aplicaciones_por_escaneos(idu_aplicacion);
CREATE INDEX ix_ctl_aplicaciones_por_escaneos_idu_escaneo ON public.ctl_aplicaciones_por_escaneos(idu_escaneo);

CREATE INDEX ix_cat_lenguajes_nom_lenguaje ON public.cat_lenguajes(nom_lenguaje);

CREATE INDEX ix_ctl_checkmarx_idu_aplicacion ON public.ctl_checkmarx(idu_aplicacion);

CREATE INDEX ix_mov_costos_proyectos_id_proyecto ON public.mov_costos_proyectos(id_proyecto);

-- Type: typ_costo
CREATE TYPE public.typ_costo AS (
    num_empleado integer,
    id_proyecto integer,
    nom_proyecto character,
    nom_cliente_ia character,
    des_descripcion text,
    val_monto numeric
);

-- Función
CREATE OR REPLACE FUNCTION fun_insertar_costo_proyecto(
    bigint,
    bigint,
    character,
    character,
    text,
    numeric
)
RETURNS smallint
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    num_empleado        ALIAS FOR $1;
    id_proyecto         ALIAS FOR $2;
    nom_proyecto        ALIAS FOR $3;
    nom_cliente_ia      ALIAS FOR $4;
    des_descripcion     ALIAS FOR $5;
    val_monto           ALIAS FOR $6;
BEGIN
    INSERT INTO mov_costos_proyectos ( num_empleado, id_proyecto, nom_proyecto, nom_cliente_ia, des_descripcion, val_monto) 
    VALUES ($1::integer, $2::integer, $3::varchar, $4::varchar, $5::text, $6::numeric );

    RETURN 1;
END;
$BODY$;

-- INSERT
 
    -- TBL_ROLE
INSERT INTO public.cat_roles (nom_rol, num_nivel) VALUES ('560d8d05cfacc7ea2dae3c177ee41032:5cc44baca89a4f886de66004424365ce', 0); -- Administrador
INSERT INTO public.cat_roles (nom_rol, num_nivel) VALUES ('5ab4703fc4b825f24ea82846be79afc0:60ab1450601d55d1f02a7d56bd826f76', 1); -- Autorizador
INSERT INTO public.cat_roles (nom_rol, num_nivel) VALUES ('0daa2f33f60b83f71d7fb413af2cb021:04add2fdaa8b917bfd922138cd2e3ba8', 2); -- Usuario
INSERT INTO public.cat_roles (nom_rol, num_nivel) VALUES ('30b8c410e6269fa777611d55484d1b4b:af90f2d60ae3f5be722fffcaa64fb90d', 3); -- Invitado
 
    -- public.ctl_estatus_aplicaciones
INSERT INTO public.ctl_estatus_aplicaciones (des_estatus_aplicacion) VALUES ('8d4eeca7beca562d3ae13d6c9bf37a4c:e8f47083f14f62866b125983e3d29972'); --En proceso 
INSERT INTO public.ctl_estatus_aplicaciones (des_estatus_aplicacion) VALUES ('801fd9ca729ba4aab550f9d7e3e2a1f1:7f8bac24bafc70e6c1dfbf9c49945294'); --En espera 
INSERT INTO public.ctl_estatus_aplicaciones (des_estatus_aplicacion) VALUES ('cc2e2fc966d95e1c8a1154f9100c0d90:76c6a68d933c01addf108e6a1159e948'); --Finalizado 
INSERT INTO public.ctl_estatus_aplicaciones (des_estatus_aplicacion) VALUES ('d1bf0da203b9f69f9dda56c172681107:d70863402490d4b8abb4477eaac0528a'); --Rechazado

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

