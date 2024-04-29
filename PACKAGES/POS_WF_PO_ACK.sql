--------------------------------------------------------
--  DDL for Package POS_WF_PO_ACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_WF_PO_ACK" AUTHID CURRENT_USER AS
/* $Header: POSAKPOS.pls 115.2 2002/11/26 02:06:46 mji ship $ */

--

procedure  acceptance_required   ( itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    );
--

procedure  Register_acceptance   ( itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    );
--

procedure  Register_rejection   (  itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    );

--

procedure  Initialize_Attributes(  itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    );
--

procedure abort_notification (  document_id	in number,
				document_rev	in number,
				document_type   in varchar2);

--
procedure  Initialize_AckAttributes(
                                   itemtype        in  varchar2,
                                   itemkey         in  varchar2,
                                   actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    );


END POS_WF_PO_ACK;

 

/
