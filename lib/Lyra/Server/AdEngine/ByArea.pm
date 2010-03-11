package Lyra::Server::AdEngine::ByArea;
use Math::Round;
use Moose;
use namespace::autoclean;

with qw(Lyra::Trait::AsyncPsgiApp Lyra::Trait::WithMemcached Lyra::Trait::WithDBI);
# 1. 緯度経度（クエリ−）をmsecに変換
# 2. 変換した秒から範囲をきめて矩形を作成(4点の緯度経度を作成）
# 3. DBに登録してあるカラム（RTree-Index）に作成した条件（矩形）でSELECT
# 4. SELECTした結果をXMLなりJSで返す

sub process {
    my ($self, $start_response, $env) = @_;

    # 1 + 2 は同期してやる

    $self->dbh->exec(
        "SELECT .....",
        sub {
            # ここで処理

            # ログ取りのためのディスパッチ
        }
    );
}

sub _convert_to_msec {
    my ($self, $coordinate) = @_;
    my @coordinate = split '\.', $coordinate;
    $coordinate[1] *= 10 if length($coordinate[1]) == 5;
    return int($coordinate[0] * 3600000 + $coordinate[1] * 3.6);
}

sub _convert_to_degree {
    my ($self, $coordinate) = @_;
    my $degree = $coordinate / 3600 / 1000;
    return nearest(0.000001, $degree);
}

__PACKAGE__->meta->make_immutable();

1;
