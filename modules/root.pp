user { 'root':
  ensure           => 'present',
  comment          => 'root',
  shell            => '/bin/sh',
}
