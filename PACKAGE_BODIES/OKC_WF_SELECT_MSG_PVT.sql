--------------------------------------------------------
--  DDL for Package Body OKC_WF_SELECT_MSG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_WF_SELECT_MSG_PVT" AS
/* $Header: OKCPMSGB.pls 120.0 2005/05/25 19:33:45 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
	PROCEDURE select_message(
				itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2) IS
		l_escalate_owner	VARCHAR2(100);
	BEGIN
		-- RUN mode - normal process execution
		if (funcmode = 'RUN') then
		l_escalate_owner := wf_engine.GetItemAttrText(
								itemtype => itemtype,
	      							itemkey	 => itemkey,
								aname  	 => 'ESCALATE_OWNER');
		End if;
		If l_escalate_owner is NOT NULL THEN
			resultout := 'COMPLETE:T';
		Elsif l_escalate_owner IS NULL THEN
			resultout := 'COMPLETE:F';
		End if;
	EXCEPTION
		when others then
	  	wf_core.context('OKC_WF_SELECT_MSG_PVT',
				'SELECT_MESSAGE',
				itemtype,
				itemkey,
				to_char(actid),
				funcmode);
	  		raise;
	END select_message;
END OKC_WF_SELECT_MSG_PVT;

/
