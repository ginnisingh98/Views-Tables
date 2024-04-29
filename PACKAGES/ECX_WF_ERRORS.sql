--------------------------------------------------------
--  DDL for Package ECX_WF_ERRORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_WF_ERRORS" AUTHID CURRENT_USER as
-- $Header: ECXWERRS.pls 120.1.12000000.4 2007/07/11 11:48:10 susaha ship $


procedure GetInErrorDetails(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);

procedure GetOutErrorDetails(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);

procedure GETTPROLE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);

procedure GETSAROLE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2);

 procedure  GetErrorRetryCount(
    itemtype in varchar2,
    itemkey         in varchar2,
    actid           in number,
    funcmode        in varchar2,
    result     in  out NOCOPY varchar2);
procedure  GetTimeoutValue(
    itemtype in varchar2,
    itemkey         in varchar2,
    actid           in number,
    funcmode        in varchar2,
    result      in out NOCOPY varchar2);
procedure  GETTOROLE(
    itemtype in varchar2,
    itemkey         in varchar2,
    actid           in number,
    funcmode        in varchar2,
    result   in    out NOCOPY varchar2);

end ECX_WF_ERRORS;

 

/
