--------------------------------------------------------
--  DDL for Package MTL_MOVEMENT_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_MOVEMENT_STAT_PKG" AUTHID CURRENT_USER AS
/* $Header: INVMVSTS.pls 120.0 2005/05/25 05:27:32 appldev noship $ */

-- Public Declarations:
--     user_id               number
--     pseudo_movement_id    number

   user_id                   NUMBER;
   pseudo_movement_id        NUMBER;

-- Package
--    mtl_movement_stat_pkg

-- Purpose
--   This package defines all procedures that are called from
--   Inventory and AR autoinvoice interface.

-- History
--    MAR-10-95     Rudolf F. Reichenberger     Created


--   *************************************************************
  -- Procedure
  -- upd_inv_movements

  -- Purpose
  --   This procedure is called from the inventory or cost
  --   processor to update either the item unit cost or the
  --   status, item unit cost, primary quantity, transaction
  --   quantity and transaction uom code for movement
  --   records in MTL_MOVEMENT_STATISTICS table.

  -- History
  --     MAR-10-95     Rudolf F. Reichenberger     Created

  -- Arguments
  --   p_movement_id           number
  --   p_transaction_quantity  number
  --   p_primary_quantity      number
  --   p_transaction_uom       varchar2
  --   p_actual_cost           number
  --   p_transaction_date      number
  --   p_call_type             varchar2

  -- Example
  --   mtl_movement_stat_pkg.upd_inv_movements ()

  -- Notes

      PROCEDURE upd_inv_movements  (p_movement_id          IN NUMBER,
                                    p_transaction_quantity IN NUMBER,
                                    p_primary_quantity     IN NUMBER,
                                    p_transaction_uom      IN VARCHAR2,
                                    p_actual_cost          IN NUMBER,
                                    p_transaction_date     IN DATE,
                                    p_call_type            IN VARCHAR2);

--   ****************************************************************
  -- Procedure
  -- upd_ins_rcv_movements

  -- Purpose
  --  This procedure is called from the receiving processor after the
  --  processor generates the appropriate ids and before the final
  --  commit; the procedure will update the shipment_header_id,
  --  shipment_line_id, quantity, etc.. for adjustment entries, the
  --  procedure will insert a corresponding adjusting movement record.

  -- History
  --     Apr-07-95     Rudolf F. Reichenberger     Created

  -- Arguments
  -- p_movement_id             number
  -- p_parent_movement_id      number
  -- p_shipment_header_id      number
  -- p_shipment_line_id        number
  -- p_transaction_quantity    number
  -- p_transaction_uom_code    varchar2
  -- p_type                    varchar2

  -- Example
  --   mtl_movement_stat_pkg.upd_ins_rcv_movements ()

  -- Notes

  PROCEDURE upd_ins_rcv_movements  (
                  p_movement_id           IN NUMBER,
                  p_parent_movement_id    IN NUMBER,
                  p_shipment_header_id    IN NUMBER,
                  p_shipment_line_id      IN NUMBER,
                  p_transaction_quantity  IN NUMBER,
                  p_transaction_uom_code  IN VARCHAR2,
                  p_type                  IN VARCHAR2,
		  p_transaction_date      IN DATE);

--   *******************************************************************

END mtl_movement_stat_pkg;
 

/
