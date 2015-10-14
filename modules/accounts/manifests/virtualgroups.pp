define accounts::virtualgroups (
          $gid,
          $members =  undef ) {
  group {$title:
      gid                   => $gid,
      members               => $members,
      ensure                => present,
  }
}
