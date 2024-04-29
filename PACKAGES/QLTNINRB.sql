--------------------------------------------------------
--  DDL for Package QLTNINRB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTNINRB" AUTHID CURRENT_USER as
/* $Header: qltninrb.pls 120.0.12010000.2 2008/10/17 06:33:57 skolluku ship $ */
-- A Server Side Name In
-- By Kevin Wiggen

-- Changed the signature of INIT_CURSOR. Added X_PLAN_ID and X_OCCURRENCE
-- for bug 1843356. kabalakr 22 feb 02.

  PROCEDURE INIT_CURSOR(X_PLAN_ID NUMBER DEFAULT NULL, X_TXN_HEADER_ID NUMBER,
                        X_COLLECTION_ID NUMBER DEFAULT NULL, X_OCCURRENCE NUMBER DEFAULT NULL );

  FUNCTION NAME_IN(X_COL_NAME VARCHAR2)
  	  RETURN VARCHAR2;


  FUNCTION NEXT_ROW
 	  RETURN BOOLEAN;


  PROCEDURE CLOSE_CURSOR;

  -- return the maximum number of result characteristic columns
  FUNCTION RES_CHAR_COLUMNS RETURN NUMBER;

  -- Bug 7491253. 12.1.1 FP for Bug 6599571
  -- Adding a new procedure to set the value fields for
  -- record in session for collection import
  -- skolluku
  PROCEDURE set_value(X_COL_NAME VARCHAR2,return_value VARCHAR2);

END qltninrb;


/
