--------------------------------------------------------
--  DDL for Package IRC_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_WEB" AUTHID CURRENT_USER as
/* $Header: ircweb.pkh 120.0 2005/07/26 15:02:33 mbocutt noship $ */
--
procedure show_vacancy (M in VARCHAR2);
--
procedure show_candidate (M in VARCHAR2);
--
procedure show_approval (M in VARCHAR2);
--
procedure correct_approval (M in VARCHAR2);
--
end irc_web;

 

/
