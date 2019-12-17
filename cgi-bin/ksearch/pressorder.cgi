#!/usr/bin/perl

# Instelbare variabelen:

# This should match the mail program on your system.
$mailprog='/usr/sbin/sendmail -t -oi -oeq';
# $mailprog='/usr/lib/sendmail -t';

# De ontvanger van de e-mailtjes
$recipient='KITLV <sitinjak@kitlv.nl>';

# De veldnamen van het HTML-formulier
@fields = (
    "PersName", "Address", "PostCode", "City", "Country",
    "Email", "Author", "Title", "Creditcard", "Date",
    "Fotonummer", "Albumnummer", "Plaatscode", "Plaatsnummer",
    "BW13x18", "aantal13x18", "publ13x18",
    "BW18x24", "aantal18x24", "publ18x24",
    "BW24x30", "aantal24x30", "publ24x30",
    "BW30x40", "aantal30x40", "publ30x40",
    "BW40x50", "aantal40x50", "publ40x50",
    "BW50x60", "aantal50x60", "publ50x60",
    "Col13x18", "aantCol13x18", "publCol13x18",
    "Col18x24", "aantCol18x24", "publCol18x24",
    "Col24x30", "aantCol24x30", "publCol24x30",
    "Col30x40", "aantCol30x40", "publCol30x40",
    "Col40x50", "aantCol40x50", "publCol40x50",
    "Col50x60", "aantCol50x60", "publCol50x60",
    "Slide24x36", "aantSlide24x36", "publSlide24x36",
    "Slide60x60", "aantSlide60x60", "publSlide60x60",
);  # End of Fieldnames

%renames = (
    "BW13x18" => "Black/white photo 13x18",
    "aantal13x18" => "aantal B/W 13x18",
    "publ13x18" => "publicatie B/W 13x18",
    "BW18x24" => "Black/white photo 18x24",
    "aantal18x24" => "aantal B/W 18x24",
    "publ18x24" => "publicatie B/W 18x24",
    "BW24x30" => "Black/white photo 24x30",
    "aantal24x30" => "aantal B/W 24x30",
    "publ24x30" => "publicatie B/W 24x30",
    "BW30x40" => "Black/white photo 30x40",
    "aantal30x40" => "aantal B/W 30x40",
    "publ30x40" => "publicatie B/W 30x40",
    "BW40x50" => "Black/white photo 40x50",
    "aantal40x50" => "aantal B/W 40x50",
    "publ40x50" => "publicatie B/W 40x50",
    "BW50x60" => "Black/white photo 50x60",
    "aantal50x60" => "aantal B/W 50x60",
    "publ50x60" => "publicatie B/W 50x60",
    "Col13x18" => "Color photo 13x18 cm",
    "aantCol13x18" => "aantal Color 13x18",
    "publCol13x18" => "publicatie Col 13x18",
    "Col18x24" => "Color photo 18x24",
    "aantCol18x24" => "aantal Color 18x24",
    "publCol18x24" => "publicatie Col 18x24",
    "Col24x30" => "Color photo 24x30",
    "aantCol24x30" => "aantal Color 24x30",
    "publCol24x30" => "publicatie Col 24x30",
    "Col30x40" => "Color photo 30x40",
    "aantCol30x40" => "aantal Color 30x40",
    "publCol30x40" => "publicatie Col 30x40",
    "Col40x50" => "Color photo 40x50",
    "aantCol40x50" => "aantal Color 40x50",
    "publCol40x50" => "publicatie Col 40x50",
    "Col50x60" => "Color photo 50x60",
    "aantCol50x60" => "aantal Color 50x60",
    "publCol50x60" => "publicatie Col 50x60",
    "Slide24x36" => "Slide 24x36",
    "aantSlide24x36" => "aantal Slide 24x36",
    "publSlide24x36" => "publicatie Slide 24x36",
    "Slide60x60" => "Slide 60x60",
    "aantSlide60x60" => "aantal Slide 60x60",
    "publSlide60x60" => "publicatie Slide 60x60"
);  # End of Renames

# Einde instelbare waarden
####################################################

# Get the input
read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

# Split the name-value pairs
@pairs = split(/&/, $buffer);

foreach $pair (@pairs)
{
    ($name, $value) = split(/=/, $pair);

    # Un-Webify plus signs and %-encoding
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

    # Stop people from using subshells to execute commands
    # Not a big deal when using sendmail, but very important
    # when using UCB mail (aka mailx).
    $value =~ s/~!/ ~!/g; 

    # Uncomment for debugging purposes
    # print "Setting $name to $value<P>";

    $FORM{$name} = $value;
}

# Print out a content-type for HTTP/1.0 compatibility
print "Content-type: text/html\n\n";

# If the comments are blank, then give a "blank form" response
&blank_response unless $FORM{'Email'};

# Now send mail to $recipient

open (MAIL, "|$mailprog") || die "Can't open $mailprog!\n";
print MAIL "From: \"$FORM{'PersName'}\" <$FORM{'Email'}>\n";
print MAIL "To: $recipient\n";
if ($FORM{'Email'}){
print MAIL "Cc: \"$FORM{'PersName'}\" <$FORM{'Email'}>\n"; }
print MAIL "Reply-To: $recipient\n";
print MAIL "Subject: $FORM{Subject}\n";
print MAIL "\n";
print MAIL "$FORM{Subject}\n";
print MAIL  "------------------------------------------------------------\n";
foreach $field (@fields) {
    $content = $FORM{$field};
    if (exists $renames{$field}) {
       $field = $renames{$field};
    }
    $content =~ s/^on$/yes/;
    if ($content ne "") {
       print MAIL "$field: $content \n";
    }
}
close (MAIL);

# Make the person feel good for writing to us
print "<HTML><HEAD>\n";
print "<TITLE>Your Order has been received</TITLE>";
print "</HEAD><BODY>\n";
print "<H1>Your Order has been received</H1>";

print "<p>Thanks for your order";
print "You will receive a copy of your order in your mailbox.\n";


# ------------------------------------------------------------
# subroutine blank_response
sub blank_response {
    print "<HTML><HEAD>\n";
    print "<TITLE>Your order has not been sent</TITLE>";
    print "</HEAD><BODY>\n";
    print "<H1>Your order has not been sent</H1>";

    print "The form wasn't filled out properly ; ";
    print "at least, your e-mail hasn't been filled out. ";
    print "For this reason this form will not be processed. ";
    exit;
}
