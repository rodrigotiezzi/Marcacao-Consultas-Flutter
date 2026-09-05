import '../models/models.dart';

const especialidadesIniciais = <Especialidade>[
  Especialidade(
    id: 1,
    nome: 'Cardiologia',
    descricao: 'Cuidados com o coração',
  ),
  Especialidade(id: 2, nome: 'Dermatologia', descricao: 'Cuidados com a pele'),
  Especialidade(
    id: 3,
    nome: 'Ortopedia',
    descricao: 'Cuidados com ossos e articulações',
  ),
  Especialidade(id: 4, nome: 'Pediatria', descricao: 'Cuidados com crianças'),
  Especialidade(id: 5, nome: 'Ginecologia', descricao: 'Saúde da mulher'),
  Especialidade(
    id: 6,
    nome: 'Oftalmologia',
    descricao: 'Cuidados com os olhos',
  ),
  Especialidade(
    id: 7,
    nome: 'Neurologia',
    descricao: 'Cuidados com o sistema nervoso',
  ),
  Especialidade(id: 8, nome: 'Psiquiatria', descricao: 'Saúde mental'),
  Especialidade(id: 9, nome: 'Endocrinologia', descricao: 'Cuidados hormonais'),
  Especialidade(id: 10, nome: 'Clínica Geral', descricao: 'Atendimento geral'),
];

final medicosIniciais = <Medico>[
  Medico(
    id: 1,
    nome: 'Dr. Carlos Silva',
    crm: '12345-SP',
    especialidade: especialidadesIniciais[0],
    ativo: true,
  ),
  Medico(
    id: 2,
    nome: 'Dra. Ana Costa',
    crm: '23456-SP',
    especialidade: especialidadesIniciais[1],
    ativo: true,
  ),
  Medico(
    id: 3,
    nome: 'Dr. Pedro Santos',
    crm: '34567-SP',
    especialidade: especialidadesIniciais[2],
    ativo: true,
  ),
  Medico(
    id: 4,
    nome: 'Dra. Maria Oliveira',
    crm: '45678-SP',
    especialidade: especialidadesIniciais[3],
    ativo: true,
  ),
  Medico(
    id: 5,
    nome: 'Dra. Juliana Mendes',
    crm: '56789-SP',
    especialidade: especialidadesIniciais[4],
    ativo: true,
  ),
  Medico(
    id: 6,
    nome: 'Dr. Roberto Lima',
    crm: '67890-SP',
    especialidade: especialidadesIniciais[5],
    ativo: true,
  ),
  Medico(
    id: 7,
    nome: 'Dra. Fernanda Souza',
    crm: '78901-SP',
    especialidade: especialidadesIniciais[6],
    ativo: true,
  ),
  Medico(
    id: 8,
    nome: 'Dr. Lucas Almeida',
    crm: '89012-SP',
    especialidade: especialidadesIniciais[7],
    ativo: true,
  ),
  Medico(
    id: 9,
    nome: 'Dra. Patricia Rocha',
    crm: '90123-SP',
    especialidade: especialidadesIniciais[8],
    ativo: true,
  ),
  Medico(
    id: 10,
    nome: 'Dr. João Ferreira',
    crm: '01234-SP',
    especialidade: especialidadesIniciais[9],
    ativo: true,
  ),
];

const pacientesIniciais = <Paciente>[
  Paciente(
    id: 1,
    nome: 'Maria Silva',
    cpf: '131.105.218-35',
    email: 'maria.silva@email.com',
    telefone: '(11) 98765-4321',
  ),
  Paciente(
    id: 2,
    nome: 'João Santos',
    cpf: '123.456.789-00',
    email: 'joao.santos@email.com',
    telefone: '(11) 91234-5678',
  ),
  Paciente(
    id: 3,
    nome: 'Ana Costa',
    cpf: '111.222.333-44',
    email: 'ana.costa@email.com',
    telefone: '(11) 99999-8888',
  ),
];


