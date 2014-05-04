
# Define filebucket 'main':
filebucket { 'main':
  server => 'puppet.myowntechpros.com',
  path   => false,
}

File { backup => 'main' }
import "base/*.pp"
import "nodes/*.pp"
