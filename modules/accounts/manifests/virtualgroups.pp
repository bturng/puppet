define accounts::virtualgroups (
  $gid ) {
  group {
    $title:
      gid                   => $gid,
      ensure                => present;
  }
}
