--------------------------------------------------------
--  DDL for Package POP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POP_CMERGE" AUTHID CURRENT_USER as
/* $Header: pocmer1s.pls 115.2 2002/02/14 22:09:08 rshahi ship $ */

   procedure MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);

end POP_CMERGE;

 

/
