--------------------------------------------------------
--  DDL for Package Body AR_MOVEMENT_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_MOVEMENT_STAT_PKG" AS
/* $Header: armvstb.pls 115.1 99/07/17 00:56:24 porting ship $ */

--
-- PUBLIC PROCEDURES
--
-- PUBLIC VARIABLES
--    pseudo_movement_id
--    user_id
--

--   ***************************************************************
  -- Procedure
  -- upd_ar_invoices

  -- Purpose
  --  This procedure is called from the autoinvoice program to
  --  update MTL_MOVEMENT_STATISTICS table with invoice price
  --  information.

  -- History
  --     MAR-21-95     Rudolf F. Reichenberger     Created

  -- Arguments
  -- p_customer_trx_id         number
  -- p_batch_id                number

  -- Example
  --   mtl_movement_stat_pkg.upd_ar_invoices ()

  -- Notes

  PROCEDURE upd_ar_invoices     (p_customer_trx_id      IN NUMBER,
                                 p_batch_id             IN NUMBER)
  IS

   CURSOR get_invoice_lines (a_customer_trx_id NUMBER) IS
      SELECT   mtl.movement_id, lin.customer_trx_line_id
      FROM     mtl_movement_statistics mtl, ra_customer_trx_lines lin
       WHERE   lin.movement_id = mtl.movement_id
        AND    lin.movement_id is not null
        AND    lin.customer_trx_id = a_customer_trx_id
        AND    lin.line_type = 'LINE' FOR UPDATE OF
               mtl.movement_id NOWAIT;

    BEGIN

--    ***   The Cursor get_invoice_lines locks all movement_id's  ***
--    ***   in mtl_movement_statistics table which exists in      ***
--    ***   ra_customer_trx_lines table related to the            ***
--    ***   requested customer_trx_id                             ***

--    ***   This Cursor also gets all customer_trx_lines rows     ***
--    ***   for a given customer_trx_id where a movement_id       ***
--    ***   exists in the mtl_movement_statistics as well as      ***
--    ***   in the ra_customer_trx_lines table.

      FOR lines IN get_invoice_lines(p_customer_trx_id) LOOP

--    ***   Invoice Price Information Update               ***

             UPDATE mtl_movement_statistics
                SET invoice_id = p_customer_trx_id,
                    invoice_batch_id = p_batch_id,
                    customer_trx_line_id = lines.customer_trx_line_id,
                    last_update_date = sysdate,
                    last_updated_by = user_id
                WHERE movement_id = lines.movement_id;

      END LOOP;
END upd_ar_invoices;

--   *******************************************************************
--     ** initialization part of the package        **  --

--     ** FUNCTION FND_GLOBAL.USER_ID Returns the   **
--     ** user_id for the last_updated_by column    **

BEGIN
       user_id := FND_GLOBAL.USER_ID;
--   *******************************************************************
END ar_movement_stat_pkg;

/
