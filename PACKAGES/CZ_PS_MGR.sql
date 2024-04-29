--------------------------------------------------------
--  DDL for Package CZ_PS_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_PS_MGR" AUTHID CURRENT_USER as
/*  $Header: czpsmgrs.pls 115.14 2004/05/17 19:47:49 skudravs ship $	*/


CZ_SCHEMA varchar2(30);

procedure ASSESS_DATA;

procedure TRIGGERS_ENABLED
(Switch in varchar2);

procedure CONSTRAINTS_ENABLED
(Switch in varchar2);

procedure REDO_SEQUENCES
(RedoStart_Flag in varchar2,
incr            in integer default null);

PROCEDURE delete_Orphaned_Nodes;

procedure PURGE;

procedure MODIFIED
(AS_OF in OUT NOCOPY date);

procedure RESET_CLEAR;

procedure REDO_STATISTICS;

end;

 

/
