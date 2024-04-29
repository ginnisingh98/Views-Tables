--------------------------------------------------------
--  DDL for Package RG_ROW_ORDERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_ROW_ORDERS_PKG" AUTHID CURRENT_USER AS
/* $Header: rgirords.pls 120.1 2003/04/29 01:29:26 djogg ship $ */
  --
  -- NAME
  --   new_row_order_id
  --
  -- DESCRIPTION
  --   Get a new report set id from rg_report_sets_s
  --
  -- PARAMETERS
  --   *None*
  --
  FUNCTION new_row_order_id
                  RETURN        NUMBER;
  --
  -- NAME
  --   check_dup_row_order_name
  --
  -- DESCRIPTION
  --   Check whether new_name already used by another row order
  --   in the currenct application.
  --
  -- PARAMETERS
  -- 1. Current Application ID
  -- 2. Current Row Order ID
  -- 3. New row order name
  --
  FUNCTION check_dup_row_order_name(cur_application_id IN   NUMBER,
				     cur_row_order_id  IN   NUMBER,
				     new_name           IN   VARCHAR2)
                                     RETURN             BOOLEAN;

  /*
   * Name: check_references
   * Desc: Check if the specified row order is used in a report.  If it is,
   *       raise an exception.
   */
  PROCEDURE check_references(X_row_order_id NUMBER);

END rg_row_orders_pkg;

 

/
