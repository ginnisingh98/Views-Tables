--------------------------------------------------------
--  DDL for Package MRP_END_ASSY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_END_ASSY" AUTHID CURRENT_USER AS
/* $Header: MRPEPEGS.pls 115.0 99/07/16 12:19:56 porting ship $  */
PROCEDURE peg(p_org_id IN number,
              p_compile_desig IN varchar2,
              p_item_to_peg IN number);
END MRP_END_ASSY;

 

/
