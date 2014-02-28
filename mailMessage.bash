emailAddress=$1
ProjectDirectory=$2
mailx -t $emailAddress \
 -a "From: WebNinja" \
 -a "Subject: WindNinja account created" \
 -a "Reply-To: Natalie Wagenbrenner <nwagenbrenner@gmail.com>" \
 -a "Cc: nwagenbrenner@gmail.com" <<!

Your WindNinja project has been created. Access your project here:

http://forest.moscowfsl.wsu.edu/climate/$ProjectDirectory

!
echo Message sent, emailAddress = $emailAddress, ProjectDirectory = $ProjectDirectory

