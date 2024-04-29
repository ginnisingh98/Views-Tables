--------------------------------------------------------
--  DDL for Package ECX_ERROR_HANDLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_ERROR_HANDLING_PVT" AUTHID CURRENT_USER AS
-- $Header: ECXERRHS.pls 115.4 2002/11/08 06:47:46 ndivakar ship $

PROCEDURE Print_Parse_Error (p_err_pos     IN PLS_INTEGER,
                             p_string      IN VARCHAR2);

END;


 

/
