--------------------------------------------------------
--  DDL for Package INV_DROPSHIP_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DROPSHIP_GLOBALS" AUTHID CURRENT_USER AS
/* $Header: INVDSGLS.pls 115.2 2003/11/06 00:06:30 vipartha noship $ */

-- Record type for drop ship
-- Description of attributes in the record type

-- PARENT_TRANSACTION_ID      - This column would indicate which is the
-- parent transaction record for a set of records. The parent transaction
-- id corresponds to the transaction id of the MMT record of the parent record
-- LOGICAL_TRX_TYPE_CODE -- This code indicates the transaction that
-- initiated the creation of the logical transations.
--    1 - Drop Ship Receipt
--    2 - Drop Ship Deliver
--    3 - Global Procurement/ Return to vendor
--    4 - Retroactive Price Update
--    5 - Extenal Shipments across OUs or RMAs

--  Intercomany Cost -- Intercompany transaction cost
--  Intercompany Pricing Option
-- TRX_FLOW_HEADER_ID -  Indicates the tramsaction flow that is being used
--     for the creation of logical transactions
-- LOGICAL_TRANSACTIONS_CREATED -- Indicates whether the logical
--       transactions have been created or deferred.
--      1 - Indicates Yes created
--      2 - Indicates NO nit created
-- LOGICAL_TRANSACTION -- Indicates whether it is a physical or logical txn.


TYPE logical_trx_attr_rec IS RECORD
  (
   transaction_id                    NUMBER         :=  NULL,
   transaction_type_id               NUMBER         := NULL,
   transaction_action_id             NUMBER         := NULL,
   transaction_source_type_id        NUMBER         := NULL,
   parent_transaction_id             NUMBER         :=  NULL,
   logical_trx_type_code             NUMBER         :=  NULL,
   intercompany_cost                 NUMBER         :=  NULL,
   intercompany_pricing_option       NUMBER         :=  NULL,
   trx_flow_header_id                NUMBER         :=  NULL,
   logical_transactions_created      NUMBER         :=  NULL,
   logical_transaction               NUMBER         :=  NULL,
   intercompany_currency_code        VARCHAR2(31)       :=  NULL

   );

TYPE logical_trx_attr_tbl IS TABLE OF logical_trx_attr_rec INDEX BY BINARY_INTEGER;


end INV_DROPSHIP_GLOBALS;

 

/
