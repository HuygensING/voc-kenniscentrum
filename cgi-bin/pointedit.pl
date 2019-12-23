#!/usr/bin/perl
###################################################################################
###################################################################################
#
# PointEdit configuration manual
#
# $selfurl
#
#    In the Configuration section, you must change the $selfurl variable
#    so that it points to where you have this script located.  
#
# $password
#
#    You should also change the $password variable to a password you choose.
#
# $title and $bodystyle
#
#    If you want a different title or bodystyle for the PointEdit-generated
#    pages, or a different bodystyle, you can change them here.
#
# Other things you may need to do:
#
#    PointEdit needs to have permissions set to 777 (Unix) owner read/write/execute
#    and other read/execute in order to work.  Depending on the system you use,
#    you may need to change the permissions of the files edited by PointEdit to
#    666 (Unix) or owner read/write other read/write.
#
# HTML syntax reference
#
#    on the line BEFORE the one you wish to edit, put the following:
#        <!---PointEdit TYPE={TAG|LINE|AREA|SSI} NAME=helpfulname--->
#
#    example
#        <!-- PointEdit TYPE=TAG NAME=bodytag--->
#        <BODY BGCOLOR="#ffffff">
#
#        <!-- PointEdit TYPE=AREA NAME=area -->
#        Some lines
#        Some more lines
#        <!-- PointEdit TYPE=AREA NAME=area -->
#
###################################################################################
###################################################################################

#configuration section

#$selfurl = "http://www.voc-kenniscentrum.nl/cgi-bin/pointedit.pl";
$selfurl = "http://voc-kenniscentrum.nl.gridminer.nl/cgi-bin/pointedit.pl";

$password = "ruyter#XVII";

$title = "VOC-Kenniscentrum - pagina's aanpassen";
$bodystyle = "<body bgcolor=\"#ffffff\" vlink=\"#a5a5a5\" alink=\"#000000\" link=\"#ff0000\" text=\"#000000\">";

####################
#execution starts

#let the browser know we're coming
&printhtmlhead;

&readparam;   #read in CGI parameters to %cgiVals

# &putenv;

#check if any arguments
if (%cgiVals) {

   $editfile = delete $cgiVals{'edit'};

   if (%cgiVals) {
      &parseedit;
   }
   else {
      &editfileform;	#edit $editfile
   }
}
else {    #input form
   &printfileform;
}

&printhtmlfoot;

#exit script
exit(0);


##record edited changes
sub parseedit {
   $inputpwd = $cgiVals{'password'};
   if ($inputpwd eq $password) {
      #changes are OK'ed by administrator
      open(FILE, "$editfile");
      @filelines = <FILE>;
      close(FILE);

      $inarea = 0;
      $inline = 0;
      $intag = 0;
      $inssi = 0;
     
      open(FILE, ">$editfile");
      foreach (@filelines) {
         chomp($_);
         if (/<!--.*?PointEdit.*?\>/i) {
            print FILE "$_\n";     #output line
            @tokens = split(/ /,$_);
            foreach $token (@tokens) {
               $token =~ s/\-//g;
               $token =~ s/\>//g;
               $token =~ s/\"//g;
               ($var,$val) = split(/=/,uc($token));
               if ($val) {
                   if ($var eq 'TYPE') {
                       $type = $val;
                   }
                   elsif ($var eq 'NAME') {
                       $name = $val;
                   }
               }
            } #endif foreach

            if ($type eq 'LINE') {
               $inline = 1;
            }
            elsif ($type eq 'AREA') {
               if ($inarea == 0) {
                  $inarea = 1;
               }
               else {
                  $inarea = 0;
               }
            }
            elsif ($type eq 'TAG') {
               $intag = 1;
            }
            elsif ($type eq 'SSI') {
               $inssi = 1;
            }

         } #endif (pointedit)
         else {
            if ($inline == 1) {
                $inline = 0;
                $newline = $cgiVals{$name};
                if ($newline) {
                   print FILE "$newline\n";
                }
                else {
                   print FILE "$_\n";
                }
            }
            elsif ($inarea == 1) {
                $newlines = $cgiVals{$name};
                if ($newlines) {
                   chomp($newlines);
                   print FILE "$newlines\n";
                   $inarea = 2;
                }
                else {
                   print FILE "$_\n";
                }
            }
            elsif ($inarea == 2) {
            }
            elsif ($intag == 1) {
                $intag = 0;
                $_ =~ s/\"//g;
                $_ =~ s/\>//g;
                $_ =~ s/\<//g;
                @tagtokens = split(/ /,$_);
                print FILE "<";
                foreach $tagtoken (@tagtokens) {
                    ($tagvar,$tagval) = split(/=/,$tagtoken);
                    if ($tagval) {
                        $tagvar = uc($tagvar);
                        $newtag = $cgiVals{"$name\_$tagvar"};
                        if ($newtag) {
                            print FILE "$tagvar=\"$newtag\" ";
                        }
                        else {
                            print FILE "$tagvar=\"$tagval\" ";
                        }
                    }
                    else {
                        print FILE "$tagtoken ";
                    }
                } #end foreach
                print FILE ">\n";
            }
            elsif ($inssi == 1) {
                $inssi = 0;
                $_ =~ s/\!//g;
                $_ =~ s/\>//g;
                $_ =~ s/\<//g;
                $_ =~ s/\-//g;
                $_ =~ s/\"//g;
                @ssitokens = split(/ /,$_);
                print FILE "<!--";
                foreach $ssitoken (@ssitokens) {
                    ($ssivar,$ssival) = split(/=/,$ssitoken);
                    if ($ssival) {
                        $ssivar = uc($ssivar);
                        $newval = $cgiVals{"$name\_$ssivar"};
                        if ($newval) {
                            print FILE "$ssivar=\"$newval\" ";
                        }
                        else {
                            print FILE "$ssivar=\"$ssival\" ";
                        }
                    }
                    else {
                        print FILE "$ssitoken ";
                    }
                } #end foreach
                print FILE "-->\n";
            }
            else {
                print FILE "$_\n";
            }

         } #end ifelse on (pointedit)

      } #end foreach on filelines
      close(FILE);

      print "<H3>Je aanpassingen zijn opgeslagen</H3>\n";
      print "<P><HR>\n";
      &printfileform;
   }
   else {
      print "<H1>Sorry, je wachtwoord is incorrect. Er zijn GEEN aanpassingen gemaakt.</H1>\n";
   }
}

#parse and edit the file
sub editfileform {

   $inarea = 0;
   $inline = 0;
   $intag = 0;
   $inssi = 0;

   open(FILE, "$editfile");
   @filelines = <FILE>;
   close(FILE);

   print "\n<TABLE BORDER=\"0\" CELLSPACING=\"2\" CELLPADDING=\"5\">\n";
   print "<FORM ACTION=\"$selfurl\" METHOD=\"POST\">\n\n";

   foreach (@filelines) {
      chomp($_);
      if (/<!-- PointEdit/i) {
         #tokenize
         @tokens = split(/ /,$_);
         foreach $token (@tokens) {
             $token =~ s/\-//g;
             $token =~ s/\>//g;
             $token =~ s/\"//g;
             ($var,$val) = split(/=/,uc($token));
             if ($val) {
                 if ($var eq 'TYPE') {
                     $type = $val;
                 }
                 elsif ($var eq 'NAME') {
                     $name = $val;
                 }
             }
         }
         
         if ($type eq 'LINE') {
             $inline = 1;
             print "<TR><TD>\nEdit line field $name:<BR>\n";
             print "<BLOCKQUOTE>\n<INPUT TYPE=\"test\" SIZE=\"50\" NAME=\"$name\" ";
         }
         elsif ($type eq 'AREA') {
             if ($inarea == 0) {
                $inarea = 1;
                print "<TR><TD>\nEdit area field $name:<BR>\n";
                print "<BLOCKQUOTE>\n<TEXTAREA ROWS=\"60\" COLS=\"70\" NAME=\"$name\">\n";
             }
             else {
                $inarea = 0;
                print "\n</TEXTAREA>\n</BLOCKQUOTE>\n</TD></TR>\n";
           
             }
         }
         elsif ($type eq 'TAG') {
             $intag = 1;
             print "<TR><TD>\nEdit tag field $name:<BR>\n<BLOCKQUOTE>\n";
         }
         elsif ($type eq 'SSI') {
             $inssi = 1;
             print "<TR><TD>\nEdit SSI field $name:<BR>\n<BLOCKQUOTE>\n";
         }
         else {
             print "<TR><TD>Unrecognized PointEdit type $type\n</TD></TR>\n";
         }
      }
      else {
         if ($inline == 1) {
             $inline = 0;
             print "VALUE=\"$_\"><BR>\n</BLOCKQUOTE>\n</TD></TR>\n";
         }
         elsif ($inarea == 1) {
             #chomp($_);
             print "$_";
         }
         elsif ($intag == 1) {
             $intag = 0;
             $_ =~ s/\"//g;
             $_ =~ s/\>//g;
             $_ =~ s/\<//g;
             @tagtokens = split(/ /,$_);
             foreach $tagtoken (@tagtokens) {
                 ($tagvar,$tagval) = split(/=/,$tagtoken);
                 $tagvar = uc($tagvar);
                 if ($tagval) {
                     print "Tag field $tagvar:";
                     print "<INPUT TYPE=\"text\" NAME=\"$name\_$tagvar\" ROWS=\"30\" VALUE=\"$tagval\"><BR>\n";
                 }
             } #end foreach
             print "\n</BLOCKQUOTE>\n</TD></TR>\n";
         }
         elsif ($inssi == 1) {
             $inssi = 0;
             $_ =~ s/\!//g;
             $_ =~ s/\>//g;
             $_ =~ s/\<//g;
             $_ =~ s/\-//g;
             $_ =~ s/\"//g;
             @ssitokens = split(/ /,$_);
             foreach $ssitoken (@ssitokens) {
                 ($ssivar,$ssival) = split(/=/,$ssitoken);
                 if ($ssival) {
                     $ssivar = uc($ssivar);
                     print "Tag field $ssivar:";
                     print "<INPUT TYPE=\"text\" NAME=\"$name\_$ssivar\" ROWS=\"30\" VALUE=\"$ssival\"><BR>\n";
                 }
             } #end foreach
             print "\n</BLOCKQUOTE>\n</TD></TR>\n";
         }
      }
   }  #end foreach

   print "\n<TR><TD><CENTER><INPUT TYPE=\"hidden\" NAME=\"edit\" VALUE=\"$editfile\">\n";
   print "\nVul hier het wachtwoord in<BR>\n<INPUT TYPE=\"text\" NAME=\"password\"><P>\n";
   print "<INPUT TYPE=\"submit\" VALUE=\"Submit\"></CENTER>\n</TD></TR>";
   print "\n</FORM>\n</TABLE>\n\n";
}


#print beginning form
sub printfileform {
   print <<EndOfFileform;
<H3>VOC-Kenniscentrum - Pagina's aanpassen</H3>
<P>
<HR>
<P>

<FORM ACTION="$selfurl" METHOD="POST">
Indexpagina:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../index.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
VOC-Begin:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../vocbegin.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Kamer-Amsterdam:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../kamer-amsterdam.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Kamer-Zeeland:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../kamer-zeeland.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Kamer-Enkhuizen:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../kamer-enkhuizen.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Kamer-Delft:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../kamer-delft.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Kamer-Hoorn:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../kamer-hoorn.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Kamer-Rotterdam:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../kamer-rotterdam.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
VOC-Schepen:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../vocschepen.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
VOC-Overzee:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../vocoverzee.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Batavia:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-batavia.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Ceylon:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-ceylon.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Java
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-java.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Ambon:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-ambon.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Makassar:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-makassar.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Banda:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-banda.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Malabar:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-malabar.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Molukken:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-molukken.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Kaap:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-kaap.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Coromandel:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-coromandel.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Malakka:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-malakka.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Bantam:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-bantam.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Japan:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-japan.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Formosa:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-formosa.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Bengalen:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-bengalen.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-Perzie:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-perzie.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Gewest-China:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../gewest-china.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Producten-Peper:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-peper.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>


<FORM ACTION="$selfurl" METHOD="POST">
Producten-Kruidnagelen:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-kruidnagelen.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Producten-Nootmuskaat en Foelie:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-nootmuskaat.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Producten-Kaneel:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-kaneel.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Producten-Rijst:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-rijst.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>


<FORM ACTION="$selfurl" METHOD="POST">
Producten-Koffie:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-koffie.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>


<FORM ACTION="$selfurl" METHOD="POST">
Producten-Thee:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-thee.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>


<FORM ACTION="$selfurl" METHOD="POST">
Producten-Suiker:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-suiker.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>


<FORM ACTION="$selfurl" METHOD="POST">
Producten-Opium:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-opium.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>


<FORM ACTION="$selfurl" METHOD="POST">
Producten-Goud en Zilver:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-goud.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>


<FORM ACTION="$selfurl" METHOD="POST">
Producten-Koper:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-koper.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>


<FORM ACTION="$selfurl" METHOD="POST">
Producten-Tin:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-tin.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Producten-Porselein:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-porselein.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Producten-Olifanten:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-olifanten.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>


<FORM ACTION="$selfurl" METHOD="POST">
Producten-Zijde:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-zijde.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>


<FORM ACTION="$selfurl" METHOD="POST">
Producten-Effen kleden:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-kledeneffen.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>


<FORM ACTION="$selfurl" METHOD="POST">
Producten-Gedecoreerde kleden:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../prod-kledendecor.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>


<FORM ACTION="$selfurl" METHOD="POST">
Literatuur:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../literatuur1.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

<FORM ACTION="$selfurl" METHOD="POST">
Adressen:
<BR>
<INPUT TYPE="text" SIZE="30" NAME="edit" VALUE="../adressen.html">&nbsp;<INPUT TYPE="submit" value="Aanpassen">
<p>
</FORM>

EndOfFileform
;

}


#prints HTML header
sub printhtmlhead {

   print("Content-type: text/html\n\n");
   print <<EndOfHTML;
<HTML><HEAD><TITLE>$title</TITLE></HEAD>
$bodystyle
EndOfHTML
;

}

#print HTML footer
sub printhtmlfoot {

  print("<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-3962916-23"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-3962916-23');
</script>
</body></HTML>\n");
}

# read parameters
# name/value pairs are in %cgiVals (global) hash
sub readparam {

  if ( ($ENV{'REQUEST_METHOD'} eq 'POST') || ($ENV{'REQUEST_METHOD'} eq 'post') ) {
    read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});          #read for POST method to $buffer
    @cgiPairs = split(/\&/,$buffer);
  }
  else {
    #get the pairs of parameters passed to the script      for GET method
    @cgiPairs = split(/\&/,$ENV{'QUERY_STRING'}); 
  }

  #split the pairs into a %cgiVals hash
  foreach $pair ( @cgiPairs ) {
       ($var,$val) = split("=",$pair);
       $val =~ s/\+/ /g;
       $val =~ s/%(..)/pack("c",hex($1))/ge;
       $cgiVals{"$var"} = "$val";
  }
}

#note!  for textarea fields, add this:
#  $FORM{'comments'} =~ s/\r/\n/;
#
#which replaces the linefeeds with the \n newline

sub putenv {

   foreach $key (keys(%ENV)) {
      print "$key = $ENV{$key}<BR>\n";
   }
}



