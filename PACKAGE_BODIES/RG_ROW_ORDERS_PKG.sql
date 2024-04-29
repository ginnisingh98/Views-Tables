--------------------------------------------------------
--  DDL for Package Body RG_ROW_ORDERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_ROW_ORDERS_PKG" AS
/* $Header: rgirordb.pls 120.1 2003/04/29 01:29:22 djogg ship $ */
  FUNCTION new_row_order_id
                  RETURN        NUMBER
  IS
	new_sequence_number     NUMBER;
  BEGIN
        SELECT rg_row_orders_s.nextval
        INTO   new_sequence_number
        FROM   dual;

        RETURN(new_sequence_number);
  END new_row_order_id;

  --
  -- NAME
  --   check_dup_row_order_name
  -- DESCRIPTION
  --   Check whether new_name already used by another report sets
  -- PARAMETERS
  -- 1. Current application ID
  -- 2. Current Row Order ID
  -- 3. New Row Order name
  --
  FUNCTION check_dup_row_order_name(    cur_application_id IN   NUMBER,
				        cur_row_order_id  IN	NUMBER,
					new_name           IN   VARCHAR2)
                  RETURN        BOOLEAN
  IS
	rec_returned	NUMBER;
  BEGIN
     SELECT count(*)
     INTO   rec_returned
     FROM   rg_row_orders
     WHERE  row_order_id <> cur_row_order_id
     AND    name = new_name
     AND    application_id = cur_application_id;

     IF rec_returned > 0 THEN
            RETURN(TRUE);
     ELSE
            RETURN(FALSE);
     END IF;
  END check_dup_row_order_name;


  PROCEDURE check_references(X_row_order_id NUMBER) IS
    dummy NUMBER;
  BEGIN
    SELECT 1 INTO dummy FROM sys.dual
    WHERE NOT EXISTS
      (SELECT 1
       FROM   rg_reports
       WHERE  row_order_id = X_row_order_id);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('RG','RG_FORMS_REF_OBJECT');
      FND_MESSAGE.set_token('OBJECT', 'RG_ROW_ORDER', TRUE);
      APP_EXCEPTION.raise_exception;
  END check_references;

END rg_row_orders_pkg;

/
