--------------------------------------------------------
--  DDL for Package OKC_WF_SELECT_MSG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_WF_SELECT_MSG_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCPMSGS.pls 120.0 2005/05/25 18:28:45 appldev noship $ */
		PROCEDURE select_message(
				itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2);
End OKC_WF_SELECT_MSG_PVT;

 

/
