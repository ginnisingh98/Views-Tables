--------------------------------------------------------
--  DDL for Package AR_MOVEMENT_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_MOVEMENT_STAT_PKG" AUTHID CURRENT_USER AS
/* $Header: armvsts.pls 115.1 99/07/17 00:56:29 porting ship $ */

-- Public Declarations:
--     user_id               number
--     pseudo_movement_id    number

   user_id                   NUMBER;
   pseudo_movement_id        NUMBER;

-- Package
--    ar_movement_stat_pkg

-- Purpose
--   This package defines all procedures that are called from
--   the receiving processor.

-- History
--    MAY-10-95     Rudolf F. Reichenberger     Created


--   *******************************************************************
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

      PROCEDURE upd_ar_invoices    (p_customer_trx_id      IN NUMBER,
                                    p_batch_id             IN NUMBER);

--   ************************************************************


END ar_movement_stat_pkg;

 

/
