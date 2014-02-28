emailAddress=$1
ProjectDirectory=$2
shinyAppp=$3
mailx -t $emailAddress \
 -a "From: WebNinja" \
 -a "Subject: $shinyApp account created" \
 -a "Reply-To: Natalie Wagenbrenner <nwagenbrenner@gmail.com>" \
 -a "Cc: nwagenbrenner@gmail.com" <<!

Your $shinApp project has been created. Access your project here:

http://forest.moscowfsl.wsu.edu:3838/shinyWindNinja/$ProjectDirectory

!
echo Message sent, emailAddress = $emailAddress, ProjectDirectory = $ProjectDirectory

