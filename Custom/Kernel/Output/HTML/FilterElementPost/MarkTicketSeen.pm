# --
# Copyright (C) 2017 - 2023 Perl-Services.de, https://www.perl-services.de/
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

    my $LabelSeen = $LayoutObject->{LanguageObject}->Translate(
        "Mark ticket seen",
    );

    my $LabelUnseen = $LayoutObject->{LanguageObject}->Translate(
        "Mark ticket unseen",
    );

    my $Link = sprintf "%sAction=AgentMarkTicketSeen&TicketID=%s", $LayoutObject->{Baselink}, $TicketID;

    my $Snippet = qq~
        <div class="ArticleFilter MarkTicketSeen Icons" >
            <span class="InvisibleText">$LabelSeen</span>
            <a href="$Link" id="MarkTicketSeenIcon"><i class="fa fa-eye"></i><span>$LabelSeen</span></a>
        </div>
        <div class="ArticleFilter MarkTicketSeen Icons" >
            <span class="InvisibleText">$LabelUnseen</span>
            <a href="$Link&Subaction=Unseen" id="MarkTicketSeenIcon"><i class="fa fa-eye-slash"></i><span>$LabelUnseen</span></a>
        </div>
    ~;

    ${ $Param{Data} } =~ s{
        <div \s+ class="AdditionalInformation \s+ ControlRow"> \K
    }{
        $Snippet
    }xms;

    return 1;
}

1;
