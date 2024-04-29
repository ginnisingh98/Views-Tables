--------------------------------------------------------
--  DDL for Package POR_NOTIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_NOTIFICATION_PKG" AUTHID CURRENT_USER as
/* $Header: PORNOTFS.pls 115.2 2002/11/19 00:45:41 jjessup ship $ */

-- NOTE: This package is modified from WFA_HTML_JSP, to support todo list
--       displayed in SSP home page. (See bug 1300992)
--       It requires username as an input variable. The middle-tier Java bean
--       should find out username from the cookie. Security is assumed
--       because a user would have a valid connection in order to make
--       a JDBC call to the plsql packages in the database.

-- see bug 1927860
-- getTodoNotifications is deprecated and getNotificationSubjects is used
-- the logic to get the notifications is moved to java code

procedure  getTodoNotifications(
 username in varchar2 default null,
 subject1 out nocopy varchar2,
 subject2 out nocopy varchar2,
 subject3 out nocopy varchar2,
 nid1 out nocopy varchar2,
 nid2 out nocopy varchar2,
 nid3 out nocopy varchar2,
 display_more out nocopy varchar2);

procedure  getNotificationSubjects(
 nid1 in integer,
 nid2 in integer,
 nid3 in integer,
 subject1 out nocopy varchar2,
 subject2 out nocopy varchar2,
 subject3 out nocopy varchar2);

end por_notification_pkg;

 

/
