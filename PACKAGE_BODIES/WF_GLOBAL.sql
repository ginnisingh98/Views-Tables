--------------------------------------------------------
--  DDL for Package Body WF_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_GLOBAL" as
/* $Header: WFGLOBLB.pls 115.0 2004/07/23 15:11:13 vshanmug noship $ */

-- Init
--   Procedure to initialize or reset the Workflow State variables and cache
--   when Apps Initialize is performed.
procedure Init
is
begin
  -- Workflow engine context variables
  Wf_Engine.setctx_itemtype := '';
  Wf_Engine.setctx_itemkey := '';

  -- Set threshold to the default value if in case it was reset in other sessions
  Wf_Engine.threshold := 50;

  -- Clear Woreflow error stack
  Wf_Core.Clear;

  -- Add other initialize/reset code here

end Init;

end WF_GLOBAL;

/
