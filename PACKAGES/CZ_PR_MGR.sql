--------------------------------------------------------
--  DDL for Package CZ_PR_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_PR_MGR" AUTHID CURRENT_USER as
/*  $Header: czprmgrs.pls 115.13 2002/11/27 17:14:53 askhacha ship $	*/


CZ_SCHEMA varchar2(30);

procedure ASSESS_DATA;

procedure TRIGGERS_ENABLED
(Switch in varchar2);

procedure CONSTRAINTS_ENABLED
(Switch in varchar2);

procedure REDO_SEQUENCES
(RedoStart_Flag in varchar2,
incr            in integer default null);

procedure PURGE;

procedure MODIFIED
(AS_OF in OUT NOCOPY date);

procedure RESET_CLEAR;

procedure REDO_STATISTICS;

end;

 

/
