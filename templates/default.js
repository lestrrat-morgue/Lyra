document.writeln('<ul>');
? for (@_) {
document.writeln('<li><a href="XXX" target="_blank"><?= $_->[0] ?></a> <?= $_->[1] ?></li>');
? }
document.writeln('</ul>');

