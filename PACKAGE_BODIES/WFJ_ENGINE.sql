--------------------------------------------------------
--  DDL for Package Body WFJ_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WFJ_ENGINE" as
/* $Header: wfjengb.pls 120.1 2005/07/02 02:47:06 appldev ship $ */

--
-- Error (PRIVATE)
--   Print a page with an error message.
--   Errors are retrieved from these sources in order:
--     1. wf_core errors
--     2. Oracle errors
--     3. Unspecified INTERNAL error
--
procedure Error
is
begin

null;
end Error;


procedure AddItemAttr(itemtype in varchar2,
                      itemkey in varchar2,
                      aname in varchar2) is

begin
    Wf_Engine.AddItemAttr(itemtype, itemkey, aname);
    htp.p('Success');
    return;
exception
    when others then
        Wfj_Engine.Error;
        return;
end AddItemAttr;


procedure SetItemAttrText(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in varchar2) is
begin
    Wf_Engine.SetItemAttrText(itemtype, itemkey, aname, avalue);
    htp.p('Success');
    return;
exception
    when others then
        Wfj_Engine.Error;
        return;
end SetItemAttrText;


procedure SetItemAttrNumber(itemtype in varchar2,
                            itemkey in varchar2,
                            aname in varchar2,
                            avalue in number) is
begin
    Wf_Engine.SetItemAttrNumber(itemtype, itemkey, aname, avalue);
    htp.p('Success');
    return;
exception
    when others then
        Wfj_Engine.Error;
        return;
end SetItemAttrNumber;


procedure SetItemAttrDate(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in date) is
begin
    Wf_Engine.SetItemAttrDate(itemtype, itemkey, aname, avalue);
    htp.p('Success');
    return;
exception
    when others then
        Wfj_Engine.Error;
        return;
end SetItemAttrDate;


procedure SetItemAttrDocument(itemtype in varchar2,
                              itemkey in varchar2,
                              aname in varchar2,
                              documentid in varchar2) is
begin
    Wf_Engine.SetItemAttrDocument(itemtype, itemkey, aname, documentid);
    htp.p('Success');
    return;
exception
    when others then
        Wfj_Engine.Error;
        return;
end SetItemAttrDocument;

procedure SetItemOwner(itemtype in varchar2,
                       itemkey in varchar2,
                       owner in varchar2) is
begin
    Wf_Engine.SetItemOwner(itemtype, itemkey, owner);
    htp.p('Success');
    return;
exception
    when others then
        Wfj_Engine.Error;
        return;
end SetItemOwner;


procedure SetItemUserKey(itemtype in varchar2,
                         itemkey in varchar2,
                         userkey In varchar2) is
begin
    Wf_Engine.SetItemUserKey(itemtype, itemkey, userkey);
    htp.p('Success');
    return;
exception
    when others then
        Wfj_Engine.Error;
        return;
end SetItemUserKey;


procedure CreateProcess(itemtype in varchar2,
                        itemkey  in varchar2,
                        process  in varchar2) is
begin
    Wf_Engine.CreateProcess(itemtype, itemkey, process);
    htp.p('Success');
    return;
exception
    when others then
        Wfj_Engine.Error;
        return;
end CreateProcess;


procedure StartProcess(itemtype in varchar2,
                       itemkey  in varchar2) is
begin
    Wf_Engine.StartProcess(itemtype, itemkey);
    htp.p('Success');
    return;
exception
    when others then
        Wfj_Engine.Error;
        return;
end StartProcess;



procedure SuspendProcess(itemtype in varchar2,
                         itemkey  in varchar2,
                         process  in varchar2) is
begin
    Wf_Engine.SuspendProcess(itemtype, itemkey, process);
    htp.p('Success');
    return;
exception
    when others then
        Wfj_Engine.Error;
        return;
end SuspendProcess;


procedure AbortProcess(itemtype in varchar2,
                       itemkey  in varchar2,
                       process  in varchar2,
                       result   in varchar2) is
begin
    Wf_Engine.AbortProcess(itemtype, itemkey, process, result);
    htp.p('Success');
    return;
exception
    when others then
        Wfj_Engine.Error;
        return;
end AbortProcess;


procedure ResumeProcess(itemtype in varchar2,
                        itemkey  in varchar2,
                        process  in varchar2) is
begin
    Wf_Engine.ResumeProcess(itemtype, itemkey, process);
    htp.p('Success');
    return;
exception
    when others then
        Wfj_Engine.Error;
        return;
end ResumeProcess;


procedure AssignActivity(itemtype in varchar2,
                         itemkey  in varchar2,
                         activity in varchar2,
                         performer in varchar2) is
begin
    Wf_Engine.AssignActivity(itemtype, itemkey, activity, performer);
    htp.p('Success');
    return;
exception
    when others then
        Wfj_Engine.Error;
        return;
end AssignActivity;


END WFJ_ENGINE;

/
