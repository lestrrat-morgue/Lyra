package Lyra::Server::AdProvider::ByArea;
use Moose;
use namespace::autoclean;

with qw(Lyra::Trait::AsyncPsgiApp Lyra::Trait::WithMemcached Lyra::Trait::WithDBI);
# 1. 緯度経度（クエリ−）を秒に変換
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

__PACKAGE__->meta->make_immutable();

1;
