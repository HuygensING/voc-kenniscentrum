

<!-- Beginning of JavaScript Applet -------------------

/* Copyright (C)1996 Web Integration Systems, Inc. DBA Websys, Inc.
   All Rights Reserved.
   This applet can be re-used or modified, if credit is given in
   the source code.
   We will not be held responsible for any unwanted effects due to the
   usage of this applet or any derivative.  No warrantees for usability
   for any specific application are given or implied.
   Chris Skinner, January 30th, 1996.
   Hacked by YOUR NAME HERE--THE DATE HERE
*/

function scrollit_r2l(seed)

{

        var m1 = "  HET KITLV IS ";
        var m2 = " GESLOTEN VAN 21 DECEMBER ";
        var m3 = " T/M 2 JANUARI 2002  ";


        var msg=m1+m2+m3;
        var out = " ";
        var c   = 1;
        if (seed > 100) {
        seed--;
                var cmd="scrollit_r2l(" + seed + ")";
               timerTwo=window.setTimeout(cmd,100);
        }
        else if (seed <= 100 && seed > 0) {

                for (c=0 ; c < seed ; c++) {

                        out+=" ";

                }

                out+=msg;

                seed--;

                var cmd="scrollit_r2l(" + seed + ")";

                    window.status=out;

                timerTwo=window.setTimeout(cmd,100);

        }

        else if (seed <= 0) {
      if (-seed < msg.length) {
    out+=msg.substring(-seed,msg.length);

                        seed--;
   var cmd="scrollit_r2l(" + seed + ")";
   window.status=out;
   timerTwo=window.setTimeout(cmd,100);
   }
else {
window.status=" ";
timerTwo=window.setTimeout("scrollit_r2l(100)",75);
}
}
}
// -- End of JavaScript code ---------------->
</SCRIPT>
<BODY BACKGROUND="#######" onLoad="timerONE=window.setTimeout('scrollit_r2l(10)',100);">

<!--EIND MELDING SLUITING -->

