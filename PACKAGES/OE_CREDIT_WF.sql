--------------------------------------------------------
--  DDL for Package OE_CREDIT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREDIT_WF" AUTHID CURRENT_USER as
/* $Header: OEXWCRCS.pls 120.1.12010000.1 2008/07/25 08:08:26 appldev ship $ */

procedure OE_CHECK_AVAILABLE_CREDIT(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

procedure OE_CHECK_FOR_HOLDS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

procedure OE_APPLY_CREDIT_HOLD(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

procedure OE_RELEASE_CREDIT_HOLD(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

procedure OE_WAIT_HOLD_NTF(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);

procedure CREDIT_BLOCK(
	itemtype   in varchar2,
	itemkey    in varchar2,
	actid      in number,
	funcmode   in varchar2,
	resultout  in out nocopy varchar2);

function GetHeaderID(
	itemtype   in varchar2,
	itemkey	   in varchar2 )
return number;

function CheckManualRelease(
	header_id  in number)
return varchar2;

function WhichCreditRule(
	itemtype   in varchar2,
	itemkey    in varchar2,
	actid      in number)
return varchar2;

end OE_CREDIT_WF;

/
