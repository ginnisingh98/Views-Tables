--------------------------------------------------------
--  DDL for Package WF_NOTIFICATION2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_NOTIFICATION2" AUTHID CURRENT_USER as
/* $Header: wfntf2s.pls 115.0 2003/03/03 20:02:23 ctilley noship $ */

--
-- GetMoreInfoRole
--   Return current "More Information Role" of a notification.
-- IN
--   nid - Notification Id
-- RETURNS
--   The name of the user that the notification is waiting for further
--   information.
--

function GetMoreInfoRole(
  nid in number)
return varchar2;

end WF_NOTIFICATION2;


 

/
