document.writeln('<ul>');
? use URI;
? my $uri = URI->new(shift);
? for my $ad (@_) { # id, title, content
?   $uri->query_form( rid => $ad->[3], ad => $ad->[0] );
document.writeln('<li><a href="<?= $uri ?>" target="_blank"><?= $ad->[1] ?></a> <?= $ad->[2] ?></li>');
? }
document.writeln('</ul>');

