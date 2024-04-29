--------------------------------------------------------
--  DDL for Package Body WF_FUNCTION_CALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_FUNCTION_CALL" as
/* $Header: wffncalb.pls 115.2 2003/03/14 05:16:51 vshanmug ship $ */
/*
** Execute - Making static procedure calls from Workflow Code
*/
procedure Execute(funcname  in     varchar2,
                  itemtype  in     varchar2,
                  itemkey   in     varchar2,
                  actid     in     number,
                  funmode   in     varchar2,
                  resultout in out nocopy varchar2,
                  executed  out    nocopy boolean)
as
  l_funcname varchar2(240);
begin
  executed := FALSE;
  l_funcname := upper(trim(funcname));

  -- Function calls for Item Type WFSTD
  if (itemtype = 'WFSTD') then
     if (l_funcname = 'WF_STANDARD.ANDJOIN') then
         WF_STANDARD.ANDJOIN(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.ASSIGN') then
         WF_STANDARD.ASSIGN(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.BLOCK') then
         WF_STANDARD.BLOCK(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.COMPARE') then
         WF_STANDARD.COMPARE(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.COMPAREEVENTPROPERTY') then
         WF_STANDARD.COMPAREEVENTPROPERTY(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.COMPAREEXECUTIONTIME') then
         WF_STANDARD.COMPAREEXECUTIONTIME(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.CONTINUEFLOW') then
         WF_STANDARD.CONTINUEFLOW(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.DEFER') then
         WF_STANDARD.DEFER(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.GETEVENTPROPERTY') then
         WF_STANDARD.GETEVENTPROPERTY(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.GETURL') then
         WF_STANDARD.GETURL(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.LAUNCHPROCESS') then
         WF_STANDARD.LAUNCHPROCESS(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.LOOPCOUNTER') then
         WF_STANDARD.LOOPCOUNTER(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.NOOP') then
         WF_STANDARD.NOOP(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.NOTIFY') then
         WF_STANDARD.NOTIFY(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.ORJOIN') then
         WF_STANDARD.ORJOIN(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.ROLERESOLUTION') then
         WF_STANDARD.ROLERESOLUTION(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.SETEVENTPROPERTY') then
         WF_STANDARD.SETEVENTPROPERTY(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.VOTEFORRESULTTYPE') then
         WF_STANDARD.VOTEFORRESULTTYPE(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.WAIT') then
         WF_STANDARD.WAIT(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'WF_STANDARD.WAITFORFLOW') then
         WF_STANDARD.WAITFORFLOW(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
  end if;

  -- Function calls for Item Type FNDFFWK
  if (itemtype = 'FNDFFWK') then
     if (l_funcname = 'FND_FLEX_WORKFLOW_APIS.ABORT_GENERATION') then
         FND_FLEX_WORKFLOW_APIS.ABORT_GENERATION(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'FND_FLEX_WORKFLOW_APIS.ASSIGN_TO_SEGMENT') then
         FND_FLEX_WORKFLOW_APIS.ASSIGN_TO_SEGMENT(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'FND_FLEX_WORKFLOW_APIS.COPY_FROM_COMBINATION') then
         FND_FLEX_WORKFLOW_APIS.COPY_FROM_COMBINATION(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'FND_FLEX_WORKFLOW_APIS.COPY_SEGMENT_FROM_COMBINATION') then
         FND_FLEX_WORKFLOW_APIS.COPY_SEGMENT_FROM_COMBINATION(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'FND_FLEX_WORKFLOW_APIS.COPY_SEGMENT_FROM_COMBINATION2') then
         FND_FLEX_WORKFLOW_APIS.COPY_SEGMENT_FROM_COMBINATION2(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'FND_FLEX_WORKFLOW_APIS.END_GENERATION') then
         FND_FLEX_WORKFLOW_APIS.END_GENERATION(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'FND_FLEX_WORKFLOW_APIS.GET_VALUE_FROM_COMBINATION') then
         FND_FLEX_WORKFLOW_APIS.GET_VALUE_FROM_COMBINATION(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'FND_FLEX_WORKFLOW_APIS.GET_VALUE_FROM_COMBINATION2') then
         FND_FLEX_WORKFLOW_APIS.GET_VALUE_FROM_COMBINATION2(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'FND_FLEX_WORKFLOW_APIS.IS_COMBINATION_COMPLETE') then
         FND_FLEX_WORKFLOW_APIS.IS_COMBINATION_COMPLETE(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'FND_FLEX_WORKFLOW_APIS.START_GENERATION') then
         FND_FLEX_WORKFLOW_APIS.START_GENERATION(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
     if (l_funcname = 'FND_FLEX_WORKFLOW_APIS.VALIDATE_COMBINATION') then
         FND_FLEX_WORKFLOW_APIS.VALIDATE_COMBINATION(itemtype, itemkey,
                                     actid, funmode, resultout);
         executed := TRUE;
         return;
     end if;
  end if;
end Execute;
end WF_FUNCTION_CALL;

/
