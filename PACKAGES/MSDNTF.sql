--------------------------------------------------------
--  DDL for Package MSDNTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSDNTF" AUTHID CURRENT_USER AS
/* $Header: msdntwfs.pls 115.2 2002/05/08 13:08:29 pkm ship   $ */

PROCEDURE SETUSER (AdHocRole in varchar2,
                    UserList in varchar2)  ;

PROCEDURE SETROLE (AdHocRole in varchar2, ExpDays in number) ;

PROCEDURE REMUSER (AdHocRole in varchar2,
                   UserList in varchar2) ;

-- REMALL cleans up wf_local_roles.  It is called from OES by ntf.purgerole
-- ntf.purgerole also calls wf_purge.notificatons and wf_purgeItem
-- along with this so all expired notifications are cleaned.
-- These are called by expiration_date.
--
PROCEDURE REMALL (AdHocRole in varchar2)  ;

--
-- Accepts arguements to set message for notifications.
-- Creates notifcation process, sets attributes and
-- starts [sends] the notification.  It relies on the
-- Ad Hoc directory service being set.

PROCEDURE DO_NTFY (WorkflowProcess in varchar2,
                      iteminput in varchar2,
                      inputkey in varchar2,
                      inowner in varchar2,
                      AdHocRole in varchar2,
                      URLfragment in varchar2,
		      Subject in varchar2,
                      msgBody in varchar2)  ;

end MSDNTF;

 

/
