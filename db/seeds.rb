require_relative '../model/resource'
require_relative '../model/request'
Resource.create(name: 'Computadora', description: 'Notebook con 4GB de RAM y 256 GB de espacio en disco con Linux')
Resource.create(name: 'Monitor', description: 'Monitor de 24 pulgadas SAMSUNG')
Resource.create(name: 'Sala de reuniones', description: 'Sala de reuniones con máquinas y proyector')
Request.create(from: '2013-11-13 11:00:00', to: '2013-11-13 12:00:00', status: 'approved', resources_id: 2, user: 'sorgentini@gmail.com')
Request.create(from: '2013-11-13 14:00:00', to: '2013-11-13 15:00:00', status: 'pending', resources_id: 2, user: 'robertoX@gmail.com')
Request.create(from: '2013-11-14 11:00:00', to: '2013-11-14 12:00:00', status: 'approved', resources_id: 2, user: 'juandomingo@gmail.com')
