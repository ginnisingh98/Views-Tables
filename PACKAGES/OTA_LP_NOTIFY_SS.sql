--------------------------------------------------------
--  DDL for Package OTA_LP_NOTIFY_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_NOTIFY_SS" AUTHID CURRENT_USER as
/* $Header: otlpsnot.pkh 120.0.12000000.1 2007/01/18 04:49:36 appldev noship $ */

    PROCEDURE create_wf_process( p_lp_notification_type in varchar2,
            p_lp_enrollment_id in number default null,
            p_lp_member_enrollment_id in number default null
          ) ;


    PROCEDURE get_notification_type
		(itemtype 	IN WF_ITEMS.ITEM_TYPE%TYPE
		,itemkey	IN WF_ITEMS.ITEM_KEY%TYPE
   		,actid	IN NUMBER
   	    ,funcmode	IN VARCHAR2
	    ,resultout	OUT nocopy VARCHAR2 );

    PROCEDURE is_Manager_enrolled_path
		(itemtype 	IN WF_ITEMS.ITEM_TYPE%TYPE
		,itemkey	IN WF_ITEMS.ITEM_KEY%TYPE
   		,actid	IN NUMBER
   	    ,funcmode	IN VARCHAR2
	    ,resultout	OUT nocopy VARCHAR2 );


    PROCEDURE send_lp_ct_notifications(ERRBUF OUT NOCOPY  VARCHAR2,
      RETCODE OUT NOCOPY VARCHAR2);
    PROCEDURE send_lpm_ct_notifications(ERRBUF OUT NOCOPY  VARCHAR2,
      RETCODE OUT NOCOPY VARCHAR2);

    PROCEDURE is_Manager_same_as_creator
		(itemtype 	IN WF_ITEMS.ITEM_TYPE%TYPE
		,itemkey	IN WF_ITEMS.ITEM_KEY%TYPE
   		,actid	IN NUMBER
   	    ,funcmode	IN VARCHAR2
        ,resultout	OUT nocopy VARCHAR2 );

end ota_lp_notify_ss;

 

/
