--------------------------------------------------------
--  DDL for Package CE_BASIG_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BASIG_WF" AUTHID CURRENT_USER as
/* $Header: cebasigwfs.pls 120.1 2005/09/20 06:01:42 svali noship $ */

procedure SELECT_NEXT_APPROVER(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy varchar2);


procedure UPDATE_SIGNATORY_HISTORY_APPR(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy varchar2);


procedure UPDATE_SIGNATORY_HISTORY_REJ(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy varchar2);


procedure APPROVE_SIGNATORY(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy varchar2);


procedure REJECT_SIGNATORY(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2);

procedure SELECTOR(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    command  in varchar2,
    result    in out nocopy varchar2);


procedure startit(id number);
procedure initialize
 (fndApplicationIdIn in integer,
 transactionIdIn in varchar2,
 transactionTypeIn in varchar2 default null);

PROCEDURE init_all(    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    command  in varchar2,
    result    in out nocopy varchar2);

procedure INSERT_HISTORY_RECORD(p_action VARCHAR2);
end CE_BASIG_WF;

 

/
