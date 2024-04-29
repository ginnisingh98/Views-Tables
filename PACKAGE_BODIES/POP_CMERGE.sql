--------------------------------------------------------
--  DDL for Package Body POP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POP_CMERGE" as
/* $Header: pocmer1b.pls 115.1 99/07/17 02:20:32 porting ship $ */

       procedure MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is
	begin
          POP_CMERGE_REQ.merge(req_id, set_num, process_mode);
	end MERGE;
end POP_CMERGE;

/
