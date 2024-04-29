--------------------------------------------------------
--  DDL for Package CZ_MANAGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_MANAGER" AUTHID CURRENT_USER as
/*  $Header: czmangrs.pls 115.9 2002/11/27 17:05:30 askhacha ship $	*/

procedure ASSESS_DATA;

procedure TRIGGERS_ENABLED
(Switch in varchar2);

procedure CONSTRAINTS_ENABLED
(Switch in varchar2);

procedure REDO_SEQUENCES
(RedoStart_Flag in varchar2,
 incr           in integer default null);

procedure RESET_CLEAR;

procedure PURGE;

procedure PURGE_CP(Errbuf IN OUT NOCOPY VARCHAR2,
		   Retcode IN OUT NOCOPY pls_integer);

end;

 

/
