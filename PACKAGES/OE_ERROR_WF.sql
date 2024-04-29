--------------------------------------------------------
--  DDL for Package OE_ERROR_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ERROR_WF" AUTHID CURRENT_USER as
/* $Header: OEXWERRS.pls 120.1.12000000.1 2007/01/16 22:13:43 appldev ship $ */

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'OE_ERROR_WF';

G_BATCH_RETRY_FLAG VARCHAR2(1) := 'N';

PROCEDURE purge_error_flow (p_item_type IN varchar2,
                            p_item_key  IN varchar2);

PROCEDURE Initialize_Errors(     itemtype        VARCHAR2,
                                itemkey         VARCHAR2,
                                actid           NUMBER,
                                funcmode        VARCHAR2,
                                result          OUT NOCOPY VARCHAR2 );

procedure update_process_messages (itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out NOCOPY /* file.sql.39 change */ varchar2);


procedure Set_entity_Descriptor(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out NOCOPY /* file.sql.39 change */ varchar2);

PROCEDURE Check_Error_Active(     itemtype        IN VARCHAR2,
                                itemkey         IN VARCHAR2,
                                actid           IN NUMBER,
                                funcmode        IN VARCHAR2,
                                result          OUT NOCOPY VARCHAR2 );

procedure Reset_Error(itemtype   in varchar2,
                     itemkey    in varchar2,
                     actid      in number,
                     funcmode   in varchar2,
                     resultout  in out nocopy varchar2);

PROCEDURE EM_Batch_Retry_Conc_Pgm (
	   errbuf                               OUT NOCOPY VARCHAR,
	   retcode                              OUT NOCOPY NUMBER,
	   p_item_key                           IN  VARCHAR2,
           p_dummy1                             IN  VARCHAR2, -- this param is not used
	   p_item_type			        IN  VARCHAR2,
	   p_activity_name		       	IN  VARCHAR2,
	   p_activity_error_date_from           IN  VARCHAR2,
	   p_activity_error_date_to             IN  VARCHAR2,
           p_mode                               IN  VARCHAR2);

FUNCTION Check_Closed_Delivery_Detail (p_item_key IN VARCHAR2,
                                       p_process_activity IN NUMBER)
RETURN BOOLEAN;

END OE_ERROR_WF;

 

/
