package RemoteImageDriver;
use Dancer2;
use RemoteImageDriver::Imager;

use File::Spec;
use File::Temp qw( tempdir );

our $VERSION = '0.1';

my $temp_dir = tempdir();

sub upload_file {
    my $file     = params->{file};
    my $filename = File::Spec->catfile( $temp_dir, $file );
    my $upload   = upload('file');
    $upload->copy_to($filename);

    my ($suffix) = $file =~ /\.([^\.]+)$/;
    $suffix = lc $suffix;
    $suffix = 'jpeg' if $suffix eq 'jpg';

    ( $filename, $suffix );
}

get '/' => sub {
    template 'index';
};

post 'scale' => sub {
    my ( $filename, $suffix ) = upload_file();

    my $width  = param 'width';
    my $height = param 'height';

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->scale( width => $width, height => $height );

    content_type $suffix;
    $blob;
};

post 'crop_rectangle' => sub {
    my ( $filename, $suffix ) = upload_file();

    my $left = param 'left' || 0;
    my $top  = param 'top'  || 0;
    my $width  = param 'width';
    my $height = param 'height';

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->crop_rectangle(
        left   => $left,
        top    => $top,
        width  => $width,
        height => $height,
    );

    content_type $suffix;
    $blob;
};

post 'flip_horizontal' => sub {
    my ( $filename, $suffix ) = upload_file();

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->flip_hozontal;

    content_type $suffix;
    $blob;
};

post 'flip_vertical' => sub {
    my ( $filename, $suffix ) = upload_file();

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->flip_vertical;

    content_type $suffix;
    $blob;
};

post '/rotate' => sub {
    my ( $filename, $suffix ) = upload_file();

    my $degrees = param 'degrees';
    $degrees %= 360;

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->rotate( degrees => $degrees );

    content_type $suffix;
    $blob;
};

post 'convert' => sub {
    my ( $filename, $suffix ) = upload_file();

    my $type = param 'type';

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->convert( type => $type );

    content_type $type;
    $blob;
};

true;
