--------------------------------------------------------
--  DDL for Package AMS_GENERIC_NTFY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_GENERIC_NTFY_PVT" AUTHID CURRENT_USER as
/* $Header: amsvgnts.pls 120.1 2005/06/15 02:03:17 appldev  $ */
--

PROCEDURE StartProcess
           (p_activity_type          IN   VARCHAR2,
            p_activity_id            IN   NUMBER,
	    p_item_key_suffix        IN   NUMBER,
            p_workflowprocess        IN   VARCHAR2   DEFAULT NULL,
            p_item_type              IN   VARCHAR2   DEFAULT NULL,
	    p_subject                IN   VARCHAR2,
	    p_send_by                IN   VARCHAR2   DEFAULT NULL,
	    p_sent_to                IN   VARCHAR2   DEFAULT NULL
             );


PROCEDURE Ams_Generic_Notification(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in OUT NOCOPY  varchar2,
                document_type			in OUT NOCOPY varchar2    );

PROCEDURE Update_Gen_Status(itemtype IN varchar2,
                        itemkey  IN varchar2,
                        actid           in  number,
                        funcmode        in  varchar2,
                        resultout       OUT NOCOPY varchar2    );

END ams_generic_ntfy_pvt;

 

/
