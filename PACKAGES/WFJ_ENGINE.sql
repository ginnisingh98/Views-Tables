--------------------------------------------------------
--  DDL for Package WFJ_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WFJ_ENGINE" AUTHID CURRENT_USER as
/* $Header: wfjengs.pls 115.6 2002/11/06 13:34:44 rosthoma ship $ */

procedure AddItemAttr(itemtype in varchar2,
                      itemkey in varchar2,
                      aname in varchar2);

procedure SetItemAttrText(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in varchar2);

procedure SetItemAttrNumber(itemtype in varchar2,
                            itemkey in varchar2,
                            aname in varchar2,
                            avalue in number);

procedure SetItemAttrDate(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in date);

procedure SetItemAttrDocument(itemtype in varchar2,
                              itemkey in varchar2,
                              aname in varchar2,
                              documentid in varchar2);

procedure SetItemOwner(itemtype in varchar2,
                       itemkey in varchar2,
                       owner in varchar2);

procedure SetItemUserKey(itemtype in varchar2,
                         itemkey in varchar2,
                         userkey In varchar2);

procedure CreateProcess(itemtype in varchar2,
                        itemkey  in varchar2,
                        process  in varchar2 default '');

procedure StartProcess(itemtype in varchar2,
                       itemkey  in varchar2);


procedure SuspendProcess(itemtype in varchar2,
                         itemkey  in varchar2,
                         process  in varchar2 default '');

procedure AbortProcess(itemtype in varchar2,
                       itemkey  in varchar2,
                       process  in varchar2 default '',
                       result   in varchar2 default wf_engine.eng_force);

procedure ResumeProcess(itemtype in varchar2,
                        itemkey  in varchar2,
                        process  in varchar2 default '');

procedure AssignActivity(itemtype in varchar2,
                         itemkey  in varchar2,
                         activity in varchar2,
                         performer in varchar2);

END WFJ_ENGINE;

 

/
