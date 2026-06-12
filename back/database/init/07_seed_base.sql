-- Usuários base do sistema (senha: onac123 — bcrypt cost 10)
INSERT INTO usuario (nome, email, senha_hash, perfil) VALUES
    ('Sistema ONAC', 'sistema@onac.serpro.gov.br', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'ADMIN'),
    ('Carlos Oliveira', 'carlos.oliveira@onac.serpro.gov.br', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'ANALISTA'),
    ('Júlia Mendes', 'julia.mendes@onac.serpro.gov.br', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'GESTOR'),
    ('Admin Sistema', 'admin@onac.serpro.gov.br', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'ADMIN')
ON CONFLICT (email) DO NOTHING;
