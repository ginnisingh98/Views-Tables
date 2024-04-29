--------------------------------------------------------
--  DDL for Package MSD_NTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_NTF" AUTHID CURRENT_USER AS
/* $Header: msdntwfs.pls 120.0 2005/05/25 17:46:36 appldev noship $ */

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

procedure SHOW_REPORT_CLOB(document_id in varchar2,
                           display_type in varchar2,
                           document in out nocopy clob,
                           document_type in out nocopy varchar2);

end MSD_NTF;

 

/
