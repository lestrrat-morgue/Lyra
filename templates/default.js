document.writeln('<ul>');
? my $uri = URI->new(shift);
? for my $ad (@_) { # id, title, content
?   my $a_uri = $uri->clone;
?   $a_uri->query_form( rid => $ad->[3], ad => $ad->[0] );
document.writeln('<li><a href="<?= $a_uri ?>" target="_blank"><?= $ad->[1] ?></a> <?= $ad->[2] ?></li>');
? }
document.writeln('</ul>');

