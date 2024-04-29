--------------------------------------------------------
--  DDL for Package ECE_ERROR_HANDLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_ERROR_HANDLING_PVT" AUTHID CURRENT_USER AS
-- $Header: ECERRHLS.pls 115.2 99/07/17 05:21:23 porting shi $

PROCEDURE Print_Parse_Error (p_err_pos     IN NUMBER,
                             p_string      IN VARCHAR2);

END;


 

/
