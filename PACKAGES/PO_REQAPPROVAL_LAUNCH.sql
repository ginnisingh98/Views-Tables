--------------------------------------------------------
--  DDL for Package PO_REQAPPROVAL_LAUNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQAPPROVAL_LAUNCH" AUTHID CURRENT_USER AS
/* $Header: POXWPA5S.pls 115.3 2004/04/02 14:27:53 nipagarw ship $ */


 /*=======================================================================+
 | FILENAME
 |   POXWPA5S.sql
 |
 | DESCRIPTION
 |   PL/SQL spec for package:  PO_REQAPPROVAL_LAUNCH
 |
 | NOTES
 | MODIFIED    Ben Chihaoui (06/10/97)
 *=====================================================================*/

--  Launch_CreatePO_WF
--
--  IN
--   itemtype --   itemkey --   actid  --   funcmode
--  OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Launch_CreatePO_WF(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
--
PROCEDURE POREQ_SELECTOR  -- Added as a part of Bug 3540107
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out nocopy varchar2
);

end PO_REQAPPROVAL_LAUNCH;

 

/
