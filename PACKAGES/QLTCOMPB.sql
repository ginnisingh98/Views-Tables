--------------------------------------------------------
--  DDL for Package QLTCOMPB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTCOMPB" AUTHID CURRENT_USER AS
/* $Header: qltcompb.pls 115.3 2002/11/27 19:22:58 jezheng ship $ */
-- Compare Functions for the server
-- 2/8/95
-- Kevin Wiggen


  FUNCTION compare(value1 IN VARCHAR2,
		      operator IN NUMBER,
		      value2 IN VARCHAR2,
		      value3 IN VARCHAR2)
  	RETURN BOOLEAN;

  FUNCTION compare(value1 IN NUMBER,
		      operator IN NUMBER,
		      value2 IN NUMBER,
		      value3 IN NUMBER)
  	RETURN BOOLEAN;

  FUNCTION compare(value1 IN DATE,
		      operator IN NUMBER,
		      value2 IN DATE,
		      value3 IN DATE)
  	RETURN BOOLEAN;

  -- Bug2336153. Added compare_seq function to support Sequence Datatype

  FUNCTION compare_seq(value1 IN VARCHAR2,
                       operator IN NUMBER,
		       value2 IN VARCHAR2,
    	 	       value3 IN VARCHAR2)
        RETURN BOOLEAN;

  FUNCTION compare(value1 IN VARCHAR2,
		      operator IN NUMBER,
		      value2 IN VARCHAR2,
		      value3 IN VARCHAR2,
		      datatype NUMBER)
  	RETURN BOOLEAN;

END QLTCOMPB;


 

/
