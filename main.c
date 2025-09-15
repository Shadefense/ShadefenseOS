
void kernel_main(void);
volatile unsigned char *video = (volatile unsigned char *)0xA0000;


void kernel_main(void)
{
    for ( int currPixelPos = 0; currPixelPos < 320 * 200; currPixelPos++ )
        video[ currPixelPos ] = 9;
    while( 1 );
}