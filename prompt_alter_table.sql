-- PROMPTS
-- Se agrega un nuevo campo num_accion

-- CAMPOS
ALTER TABLE public.mae_prompts ADD COLUMN num_accion INT NOT NULL DEFAULT 0;
