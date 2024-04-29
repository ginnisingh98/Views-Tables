--------------------------------------------------------
--  DDL for Package FND_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_WEB" AUTHID CURRENT_USER as
/* $Header: AFSCWEBS.pls 120.0 2005/05/07 17:50:03 appldev ship $ */

procedure PING;
procedure VERSION(filter in varchar2 default ''); --Bug 1850949 - changed default value
procedure SHOWENV;
end FND_WEB;

 

/
