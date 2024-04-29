--------------------------------------------------------
--  DDL for Package WF_FUNCTION_CALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_FUNCTION_CALL" AUTHID CURRENT_USER as
/* $Header: wffncals.pls 115.2 2003/03/14 05:27:18 vshanmug ship $ */

/*
** Execute - Makes a static call to the procedure based on the input
**           parameter funcname
*/

procedure Execute(funcname  in     varchar2,
                  itemtype  in     varchar2,
                  itemkey   in     varchar2,
                  actid     in     number,
                  funmode   in     varchar2,
                  resultout in out nocopy varchar2,
                  executed  out    nocopy boolean);

end WF_FUNCTION_CALL;

 

/
