-- RVIA
-- Se modifican los nombres de las tablas de acuerdo al estandar
-- TABLAS
ALTER TABLE public.tbl_roles 						RENAME TO cat_roles;
ALTER TABLE public.cat_colaborador 					RENAME TO cat_colaboradores;
ALTER TABLE public.tcl_estatusaplicaciones 			RENAME TO ctl_estatus_aplicaciones;
ALTER TABLE public.tbl_codigo_fuentes 				RENAME TO ctl_codigo_fuentes;
ALTER TABLE public.tbl_aplicaciones 				RENAME TO mae_aplicaciones;
ALTER TABLE public.tbl_escaneos 					RENAME TO mov_escaneos;
ALTER TABLE public.usuarios_x_aplicaciones 			RENAME TO ctl_usuarios_por_aplicaciones;
ALTER TABLE public.aplicaciones_x_escaneos 			RENAME TO ctl_aplicaciones_por_escaneos;
ALTER TABLE public.tcl_seguimiento_modificaciones 	RENAME TO his_seguimiento_modificaciones;
ALTER TABLE public.tbl_checkmarx 					RENAME TO ctl_checkmarx;
ALTER TABLE public.tbl_costos_proyectos 			RENAME TO mov_costos_proyectos;

-- CAMPOS
-- Se cambian los nombres de los campos de acuerdo al estandar
ALTER TABLE public.cat_colaboradores 	RENAME COLUMN esactivo TO opc_es_activo;
ALTER TABLE public.mov_costos_proyectos RENAME COLUMN txt_descripcion TO des_descripcion;
