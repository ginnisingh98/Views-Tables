--------------------------------------------------------
--  DDL for Package OE_PAYMENT_ASSURANCE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PAYMENT_ASSURANCE_WF" AUTHID CURRENT_USER as
/* $Header: OEXWMPMS.pls 120.1 2006/03/29 16:52:52 spooruli noship $ */

PROCEDURE Start_Payment_Assurance(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);


PROCEDURE Payment_Receipt(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);


END OE_Payment_Assurance_WF;

/
