
//Based on https://en.wikipedia.org/wiki/Spirograph
//l is the ratio of distance of the drawing point from the center of a smaller gear to the
//radius of the smaller gear
//k is the ratio of the radius of the small gear to the radius of the big gear
//Returns the coordinates of the drawing point at given time
function spirograph( scale, l, k, time )
{
    var a = ( 1.0 - k ) / k;
    return [
                scale * (( 1.0 - k ) * Math.cos(time) + l * k * Math.cos( a * time )),
                scale * (( 1.0 - k ) * Math.sin(time) - l * k * Math.sin( a * time )),
           ];
};