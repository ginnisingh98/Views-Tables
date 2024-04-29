--------------------------------------------------------
--  DDL for Package POP_CMERGE_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POP_CMERGE_REQ" AUTHID CURRENT_USER AS
/* $Header: pocmer2s.pls 115.3 2003/04/09 20:58:42 davidng ship $ */
   procedure MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);
END POP_CMERGE_REQ;

 

/
