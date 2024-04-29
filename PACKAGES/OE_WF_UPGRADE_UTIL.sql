--------------------------------------------------------
--  DDL for Package OE_WF_UPGRADE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_WF_UPGRADE_UTIL" AUTHID CURRENT_USER as
/* $Header: OEXWUPGS.pls 120.0 2005/06/01 02:47:32 appldev noship $ */

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'OE_WF_UPGRADE_UTIL';

-- Cycle Result
RES_NOT_APPLICABLE       CONSTANT NUMBER := 8;
RES_FAIL_NOT_APPLICABLE  CONSTANT NUMBER := 24;
RES_ELIGIBLE             CONSTANT NUMBER := 18;
RES_PARTIAL              CONSTANT NUMBER := 5;
RES_CONFIRMED            CONSTANT NUMBER := 6;
RES_COMPLETE             CONSTANT NUMBER := 11;
RES_INTERFACED           CONSTANT NUMBER := 14;
RES_WORK_ORDER_COMPLETED CONSTANT NUMBER := 19;


PROCEDURE UPGRADE_CUSTOM_ACTIVITY_BLOCK(
	itemtype  in varchar2,
	itemkey   in varchar2,
     actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE UPGRADE_PRE_APPROVAL(
	itemtype  in varchar2,
	itemkey   in varchar2,
     actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2); /* file.sql.39 change */

PROCEDURE IS_ORDER_PAST_BOOKING(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE IS_LINE_PAST_SHIPPING(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE IS_LINE_SHIP_ELIGIBLE(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE IS_RETURN_RECEIVED(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE IS_RETURN_INSPECTED(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE IS_LINE_PAST_INVOICING(
     itemtype  in varchar2,
     itemkey   in varchar2,
     actid     in number,
     funcmode  in varchar2,
     resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE IS_ORDER_CLOSED(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE IS_LINE_CLOSED(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE IS_LINE_PAST_DEMAND_IFACE(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE CHECK_PUR_REL_STATUS(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE CHK_MFG_RELEASE_STS(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE IS_LINE_PAST_MFG_RELEASE(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE IS_LINE_ATO_MODEL(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE IS_MODE_UPGRADE(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2);/* file.sql.39 change */

END OE_WF_UPGRADE_UTIL;

 

/
