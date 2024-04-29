--------------------------------------------------------
--  DDL for Package OE_SERVICE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SERVICE_WF" AUTHID CURRENT_USER as
/* $Header: OEXSVWFS.pls 120.0 2005/06/04 11:09:50 appldev noship $ */
G_PKG_NAME       CONSTANT VARCHAR2(30) := 'OE_SERVICE_WF';

PROCEDURE SET_LINE_SERVICE_CREDIT(
	itemtype  in varchar2,
	itemkey   in varchar2,
        actid     in number,
	funcmode  in varchar2,
	resultout in out NOCOPY /* file.sql.39 change */ varchar2);

END OE_SERVICE_WF;

 

/
