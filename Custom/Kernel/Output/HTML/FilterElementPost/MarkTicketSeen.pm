# --
# Copyright (C) 2017 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::MarkTicketSeen;

use strict;
use warnings;

use List::Util qw(first);

our @ObjectDependencies = qw(
    Kernel::System::Web::Request
    Kernel::Output::HTML::Layout
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    $Self->{UserID} = $Param{UserID};

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject     = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get template name
    my $Templatename = $Param{TemplateFile} || '';

    return 1 if !$Templatename;
    return 1 if !$Param{Templates}->{$Templatename};

    # define if rich text should be used
    my ($TicketID) = $ParamObject->GetParam( Param => 'TicketID' );

    return 1 if !$TicketID;

    return 1 if ${$Param{Data}} =~ m{MarkTicketSeen Icons};

    my $Label = $LayoutObject->{LanguageObject}->Translate(
        "Mark ticket seen",
    );

    my $Snippet = qq~
        <div class="ArticleFilter MarkTicketSeen Icons" >
            <span class="InvisibleText">$Label</span>
            <a href="#" id="MarkTicketSeenIcon"><i class="fa fa-eye"></i><span>$Label</span></a>
        </div>
    ~;

    ${ $Param{Data} } =~ s{
        ( <div \s+ class="\w+ \s+ Icons"> )
    }{
        $Snippet $1
    }xms;

    $LayoutObject->AddJSOnDocumentComplete(
        Code => qq~
            \$('#MarkTicketSeenIcon').bind( 'click', function() {
                var FormData = {
                    Action: 'AgentMarkTicketSeen',
                    TicketID: $TicketID
                };

                if (!Core.Config.Get('SessionIDCookie')) {
                    FormData[Core.Config.Get('SessionName')] = Core.Config.Get('SessionID');
                    FormData[Core.Config.Get('CustomerPanelSessionName')] = Core.Config.Get('SessionID');
                }

                \$.ajax({
                    url: Core.Config.Get('Baselink'),
                    type: 'POST',
                    data : FormData
                });
            });
        ~,
    );

    return 1;
}

1;
