CREATE TABLE `click` (
   `id` char(10),
   `landing_uri` text,
    UNIQUE(`id`)
) ENGINE=Innodb DEFAULT CHARSET=utf8;
INSERT INTO click VALUES('ad00000001', 'http://localhost');
