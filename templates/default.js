document.writeln('<ul>');
? my $uri = shift;
? for my $ad (@_) { # id, title, content
?   $uri->query_form( ad => $ad->{id} );
document.writeln('<li><a href="<?= $uri ?>" target="_blank"><?= Encode::encode_utf8($ad->{title}) ?></a> <?= Encode::encode_utf8($ad->{content}) ?></li>');
? }
document.writeln('</ul>');

