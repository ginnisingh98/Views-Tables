--------------------------------------------------------
--  DDL for Package INV_MOBILE_HELPER_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MOBILE_HELPER_FUNCTIONS" AUTHID CURRENT_USER AS
/* $Header: INVMTXHS.pls 120.1 2005/06/17 09:55:45 appldev  $*/
PROCEDURE tracelog (p_err_msg IN VARCHAR2,
		    p_module IN VARCHAR2,
		    p_level IN NUMBER := 9);

PROCEDURE SQL_ERROR(routine IN VARCHAR2 ,
                    location IN VARCHAR2,
                    error_code IN NUMBER);

-- retrieve, concatenate and clear the message stack

PROCEDURE get_stacked_messages(x_message OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

END inv_mobile_helper_functions;

 

/
