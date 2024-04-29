--------------------------------------------------------
--  DDL for Package WF_ADVANCED_WORKLIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ADVANCED_WORKLIST" AUTHID CURRENT_USER as
/* $Header: wfadvws.pls 120.2.12010000.2 2009/10/29 10:50:26 sudchakr ship $ */

--
-- Authenticate (PUBLIC)
--   Verify user is allowed access to this notification
-- IN
--   nid - notification id
--   nkey - notification access key (if disconnected); currently unused
-- RETURNS
--   Current user name
--
function Authenticate(
  username in varchar2,
  nid in number,
  nkey in varchar2)
return varchar2;

procedure getInfoAfterDenorm( p_nid in number,
     p_langcode in varchar2,
     p_subject out nocopy varchar2,
     p_touser out nocopy varchar2,
     p_fromuser out nocopy varchar2);

--
-- Authenticate2 (PUBLIC)
--   Verify if user allowed access to this notification. This API takes into
--   consideration if the user being authenticated is a proxy to the original
--   notification recipient
-- IN
--   nid - notification id
--   nkey - notification access key (if disconnected); currently unused
-- RETURNS
--   Current user name
--
function Authenticate2(username in varchar2,
                       nid      in number,
                       nkey     in varchar2)
return varchar2;

procedure SetNavFromHomePage(isebizhomepage in number);

function GetNavFromHomePage return Boolean;

end WF_ADVANCED_WORKLIST;

/
