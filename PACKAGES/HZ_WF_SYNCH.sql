--------------------------------------------------------
--  DDL for Package HZ_WF_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_WF_SYNCH" AUTHID CURRENT_USER AS
/* $Header: ARHWFSNS.pls 120.5 2005/10/06 21:33:58 smattegu noship $ */

   TYPE SYNC_REC_TYPE IS RECORD
   (
	USER_NAME	 WF_LOCAL_USER_ROLES.USER_NAME%TYPE,
	DISPLAY_NAME      WF_LOCAL_ROLES.DISPLAY_NAME%TYPE,
	DESCRIPTION       WF_LOCAL_ROLES.DESCRIPTION%TYPE,
	NOTIFICATION_PREF WF_LOCAL_ROLES.NOTIFICATION_PREFERENCE%TYPE,
	LANGUAGE          WF_LOCAL_ROLES.LANGUAGE%TYPE,
	TERRITORY         WF_LOCAL_ROLES.TERRITORY%TYPE,
	EMAIL_ADDRESS     WF_LOCAL_ROLES.EMAIL_ADDRESS%TYPE,
	FAX               WF_LOCAL_ROLES.FAX%TYPE,
	STATUS            WF_LOCAL_ROLES.STATUS%TYPE,
	START_DATE        WF_LOCAL_ROLES.START_DATE%TYPE,
	EXPIRATION_DATE   WF_LOCAL_ROLES.EXPIRATION_DATE%TYPE,
	SYSTEM_ID         WF_LOCAL_ROLES.ORIG_SYSTEM_ID%TYPE
   );
  TYPE SYNC_TBL_TYPE IS TABLE OF SYNC_REC_TYPE INDEX BY PLS_INTEGER;

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/*===========================================================================+
 | PROCEDURE
 |              propogate_user_role
 |
 | DESCRIPTION
 |              Propogates user information to WF tables
 |
 | SCOPE - Public
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |		WF_LOCAL_SYNCH
 |
 | ARGUMENTS  : IN:
 |                 p_subscription_guid      in raw,
 |
 |              OUT:
 |
 |          IN/ OUT:
 |                 p_event                  in out NOCOPY wf_event_t |
 |
 |
 | RETURNS    : VARCHAR2
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

FUNCTION propagate_user_role(
              p_subscription_guid      in raw,
              p_event                  in out NOCOPY wf_event_t)
return varchar2
;


/*===========================================================================+
 | PROCEDURE
 |              propogate_role
 |
 | DESCRIPTION
 |              Propogates user information to WF tables
 |
 | SCOPE - Public
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |		WF_LOCAL_SYNCH
 |
 | ARGUMENTS  : IN:
 |                p_subscription_guid      in raw,
 |
 |              OUT:
 |
 |          IN/ OUT:
 |                p_event                  in out NOCOPY wf_event_t
 |
 |
 | RETURNS    : VARCHAR2
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

FUNCTION propagate_role(
             p_subscription_guid      in raw,
             p_event                  in out NOCOPY wf_event_t)
return varchar2
;


/*===========================================================================+
 | The following procedures are covers that call the WF_LOCAL_SYNCH APIS.
 +===========================================================================*/

PROCEDURE SYNCHGROUPWFUSERROLE ( RelationshipId         IN Number        );

PROCEDURE SYNCHPERSONWFROLE (
        PartyId         IN Number,
        p_update        IN Boolean Default False ,
        p_overwrite     IN Boolean Default False );

PROCEDURE SYNCHCONTACTWFROLE (
        PartyId         IN Number,
        p_update        IN Boolean Default False ,
        p_overwrite     IN Boolean Default False );

PROCEDURE SYNCHGROUPWFROLE (
        PartyId         IN Number,
        p_update        IN Boolean Default False ,
        p_overwrite     IN Boolean Default False );


END HZ_WF_SYNCH;


 

/
