# --
# Copyright (C) 2017 - 2023 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentMarkTicketSeen;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ArticleObject      = $Kernel::OM->Get('Kernel::System::Ticket::Article');

    my $TicketID  = $ParamObject->GetParam( Param => 'TicketID' );

    if ( !$TicketID ) {
        return $LayoutObject->ErrorScreen(
            Message => 'No TicketID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    # check permissions
    my $Access = $TicketObject->TicketPermission(
        Type     => 'ro',
        TicketID => $TicketID,
        UserID   => $Self->{UserID}
    );

    # error screen, don't show ticket
    if ( !$Access ) {
        my $TranslatableMessage = $LayoutObject->{LanguageObject}->Translate(
            "We are sorry, you do not have permissions anymore to access this ticket in its current state. "
        );

        return $LayoutObject->NoPermission(
            Message    => $TranslatableMessage,
            WithHeader => 'yes',
        );
    }

    my @ArticleIndex = $ArticleObject->ArticleList(
        TicketID => $TicketID,
    );

    my $Method = 'ArticleFlagSet';
    my $Subaction = $ParamObject->GetParam( Param => 'Subaction' );
    if ( lc $Subaction eq 'unseen' ) {
        $Method = 'ArticleFlagDelete';
    }

    for my $Article ( @ArticleIndex ) {
        $ArticleObject->$Method(
            ArticleID => $Article->{ArticleID},
            TicketID  => $TicketID,
            Key       => 'Seen',
            Value     => 1,
            UserID    => $Self->{UserID},
        );
    }

    if ( lc $Subaction eq 'unseen' ) {
        $TicketObject->TicketFlagDelete(
            TicketID  => $TicketID,
            Key       => 'Seen',
            UserID    => $Self->{UserID},
        );
    }

    return $LayoutObject->Redirect(
        OP => 'Action=AgentTicketZoom&TicketID=' . $TicketID,
    );
}

1;
