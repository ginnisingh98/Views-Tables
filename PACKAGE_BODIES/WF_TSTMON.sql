--------------------------------------------------------
--  DDL for Package Body WF_TSTMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_TSTMON" as
/* $Header: wftmonb.pls 115.1 2002/11/11 11:33:42 rosthoma noship $ */

--
-- Procedure
--	StartProcess
--
-- Description
--      Initiate workflow for Test Workflow Monitor
--
--
--
procedure GetMonURLs(itemtype  in varchar2,
                     itemkey   in varchar2,
                     actid   in number,
                     funcmode  in varchar2,
                     resultout in out varchar2)
is

   entered_type VARCHAR2(8);
   entered_key VARCHAR2(240);

--
begin
	--
	--
	-- Initialize workflow item attributes
	--
	--
	entered_type := wf_engine.GetActivityAttrText(itemtype, itemkey, actid,'INITEMTYPE');
	entered_key := wf_engine.getActivityAttrText(itemtype, itemkey, actid, 'INITEMKEY');
	wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'SIMPLEWITH',
					avalue   => wf_fwkmon.getAnonymousSimpleURL(entered_type , entered_key , 'HISTORY', 'Y'));
      --
      wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'SIMPLEWO',
					avalue   => wf_fwkmon.getAnonymousSimpleURL(entered_type , entered_key , 'HISTORY', 'N'));
      --
	wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ADVANCEDWITH',
					avalue   => wf_fwkmon.getAnonymousAdvanceURL(entered_type , entered_key , 'HISTORY', 'Y'));
      --
	wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ADVANCEDWO',
					avalue   => wf_fwkmon.getAnonymousAdvanceURL(entered_type , entered_key , 'HISTORY', 'N'));
      --



   resultout := 'COMPLETE';

exception
	when others then
		--
		wf_core.context('TSTMNAPI','PRC_TSTMNAPI', itemtype, itemkey, to_char(actid), funcmode);
		raise;
		--
end GetMonURLs;
end;

/
