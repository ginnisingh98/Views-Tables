--------------------------------------------------------
--  DDL for Package FV_CST_GL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_CST_GL" AUTHID CURRENT_USER as
    -- $Header: FVCSTGLS.pls 115.0 2003/07/02 20:25:43 djhaimes noship $
--==============================================================
procedure CORRECT_GL_INTERFACE_ENTRIES (
		p_group_id        in  number,
		p_Receipt_id    	in  number,
		p_Deliver_id    	in  number);

--          Purpose of Function
--
--          Given group id, rcv transaction id 1, rcv transaction id 2
--          select rows from gl interface with that group_id and a reference25
--          of transaction id 1 or 2 (receive or deliver) and an actual_flag
--          of 'A' (don't want to process encumbrance entries) delete two rows
--          with the same value in code_combination_id, one DR and one CR.
--          If more or less than  4 rows found, throw an exception


End  FV_CST_GL ;

 

/
