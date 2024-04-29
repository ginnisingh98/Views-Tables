--------------------------------------------------------
--  DDL for Package PJM_UEFF_ONHAND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_UEFF_ONHAND" AUTHID CURRENT_USER AS
/* $Header: PJMUEOHS.pls 115.9 2003/01/28 23:41:52 alaw ship $ */
--
--  Name          : Onhand_Quantity
--  Pre-reqs      : None
--  Function      : This function returns onhand quantity for a specific
--                  unit number and item/org/rev/subinv/locator/lot that
--                  matches the unit number on the OE line
--
--
--  Parameters    :
--  IN            : X_source_line                   NUMBER
--                  X_item_id                       NUMBER
--                  X_organization_id               NUMBER
--                  X_revision                      VARCHAR2
--                  X_subinventory                  VARCHAR2
--                  X_locator_id                    NUMBER
--                  X_lot_number                    VARCHAR2
--                  X_lpn_id                        NUMBER      BUG 2752979
--                  X_cost_group_id                 NUMBER      BUG 2752979
--
--
--  Returns       : NUMBER
--
FUNCTION Onhand_Quantity
( X_source_line                   IN     NUMBER
, X_item_id                       IN     NUMBER
, X_organization_id               IN     NUMBER
, X_revision                      IN     VARCHAR2
, X_subinventory                  IN     VARCHAR2
, X_locator_id                    IN     NUMBER
, X_lot_number                    IN     VARCHAR2
, X_lpn_id                        IN     NUMBER    DEFAULT NULL
, X_cost_group_id                 IN     NUMBER    DEFAULT NULL
) RETURN NUMBER;
-- PRAGMA RESTRICT_REFERENCES (Onhand_Quantity, WNDS, WNPS);


--
--  Name          : Txn_Quantity
--  Pre-reqs      : None
--  Function      : This function returns transaction quantity for a specific
--                  transaction that matches the unit number on the OE line
--
--
--  Parameters    :
--  IN            : X_source_line                   NUMBER
--                  X_trx_temp_id                   NUMBER
--                  X_lot_number                    VARCHAR2
--
--  Returns       : NUMBER
--
FUNCTION Txn_Quantity
( X_source_line                   IN     NUMBER
, X_trx_temp_id                   IN     NUMBER
, X_lot_number                    IN     VARCHAR2
, X_Fetch_From_DB                 IN     VARCHAR2 DEFAULT 'Y'
, X_item_id                       IN     NUMBER   DEFAULT NULL
, X_organization_id               IN     NUMBER   DEFAULT NULL
, X_src_type_id                   IN     NUMBER   DEFAULT NULL
, X_trx_src_id                    IN     NUMBER   DEFAULT NULL
, X_rcv_trx_id                    IN     NUMBER   DEFAULT NULL
, X_trx_sign                      IN     NUMBER   DEFAULT NULL
, X_trx_src_line_id               IN     NUMBER   DEFAULT NULL
) RETURN NUMBER;
-- PRAGMA RESTRICT_REFERENCES (Txn_Quantity, WNDS, WNPS);


END;

 

/
