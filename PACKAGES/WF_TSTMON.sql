--------------------------------------------------------
--  DDL for Package WF_TSTMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_TSTMON" AUTHID CURRENT_USER as
/* $Header: wftmons.pls 115.2 2002/11/11 11:53:15 rosthoma noship $ */

--
-- Procedure
--	StartProcess
--
-- Description		starts the test Workflow Monitor process
--
-- IN
--   ItemType - Item Type from Launch Process screen
--   ItemKey - Item Key from Launch process screen
--
procedure GetMonURLs(itemtype  in varchar2,
                 itemkey   in varchar2,
                 actid   in number,
                 funcmode  in varchar2,
                 resultout in out varchar2);
end WF_TSTMON;

 

/
