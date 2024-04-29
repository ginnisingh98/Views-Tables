--------------------------------------------------------
--  DDL for Package CZ_OM_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_OM_MGR" AUTHID CURRENT_USER as
/*  $Header: czommgrs.pls 115.12 2002/11/27 17:08:00 askhacha ship $	*/


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
