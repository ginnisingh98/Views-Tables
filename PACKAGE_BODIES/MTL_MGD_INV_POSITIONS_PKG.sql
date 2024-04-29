--------------------------------------------------------
--  DDL for Package Body MTL_MGD_INV_POSITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_MGD_INV_POSITIONS_PKG" AS
/* $Header: INVTPOSB.pls 115.1 2002/12/24 23:24:58 vjavli ship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVUTOSB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Table Handler for table MTL_MGD_INVENTORY_POSITIONS               |
--| HISTORY                                                               |
--|     09/01/2000 Paolo Juvara      Created                              |
--+======================================================================*/


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Insert_Row             PUBLIC
-- PARAMETERS: p_?????                one parameter per column
--             x_rowid                rowid of the inserted row
-- COMMENT   : Inserts a row in MTL_MGD_INVENTORY_POSITIONS; standard who
--             value are optional and defaulted from profile options
--=======================================================================--
PROCEDURE Insert_Row
( p_data_set_name             IN  VARCHAR2
, p_bucket_name               IN  VARCHAR2
, p_organization_code         IN  VARCHAR2
, p_inventory_item_code       IN  VARCHAR2
, p_creation_date             IN  DATE DEFAULT NULL
, p_created_by                IN   NUMBER  DEFAULT NULL
, p_last_update_date          IN  DATE DEFAULT NULL
, p_last_updated_by           IN  NUMBER DEFAULT NULL
, p_last_update_login         IN  NUMBER DEFAULT NULL
, p_request_id                IN  NUMBER DEFAULT NULL
, p_program_application_id    IN  NUMBER DEFAULT NULL
, p_program_id                IN  NUMBER DEFAULT NULL
, p_program_update_date       IN  DATE DEFAULT NULL
, p_hierarchy_id              IN  NUMBER
, p_hierarchy_name            IN  VARCHAR2
, p_parent_organization_code  IN  VARCHAR2
, p_parent_organization_id    IN  VARCHAR2
, p_bucket_size_code          IN  VARCHAR2
, p_bucket_start_date         IN  DATE
, p_bucket_end_date           IN  DATE
, p_inventory_item_id         IN  NUMBER
, p_organization_id           IN  NUMBER
, p_hierarchy_delta_qty       IN  NUMBER
, p_hierarchy_end_on_hand_qty IN  NUMBER
, p_org_received_qty          IN  NUMBER
, p_org_issued_qty            IN  NUMBER
, p_org_delta_qty             IN  NUMBER
, p_org_end_on_hand_qty       IN  NUMBER
)
IS
BEGIN
  INSERT INTO mtl_mgd_inventory_positions
  ( data_set_name
  , bucket_name
  , organization_code
  , inventory_item_code
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , request_id
  , program_application_id
  , program_id
  , program_update_date
  , hierarchy_id
  , hierarchy_name
  , parent_organization_code
  , parent_organization_id
  , bucket_size_code
  , bucket_start_date
  , bucket_end_date
  , inventory_item_id
  , organization_id
  , hierarchy_delta_qty
  , hierarchy_end_on_hand_qty
  , org_received_qty
  , org_issued_qty
  , org_delta_qty
  , org_end_on_hand_qty
  )
  VALUES
  ( p_data_set_name
  , p_bucket_name
  , p_organization_code
  , p_inventory_item_code
  , NVL(p_creation_date, SYSDATE)
  , NVL(p_created_by, NVL(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')), 0))
  , NVL(p_last_update_date, SYSDATE)
  , NVL(p_last_updated_by, NVL(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')), 0))
  , NVL(p_last_update_login, TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')))
  , NVL(p_request_id, TO_NUMBER(FND_PROFILE.VALUE('CONC_REQ_ID')))
  , NVL(p_program_application_id,TO_NUMBER(FND_PROFILE.Value('PROG_APPL_ID')))
  , NVL(p_program_id, TO_NUMBER(FND_PROFILE.Value('CONC_PROG_ID')))
  , NVL(p_program_update_date, SYSDATE)
  , p_hierarchy_id
  , p_hierarchy_name
  , p_parent_organization_code
  , p_parent_organization_id
  , p_bucket_size_code
  , p_bucket_start_date
  , p_bucket_end_date
  , p_inventory_item_id
  , p_organization_id
  , p_hierarchy_delta_qty
  , p_hierarchy_end_on_hand_qty
  , p_org_received_qty
  , p_org_issued_qty
  , p_org_delta_qty
  , p_org_end_on_hand_qty
  );
END Insert_Row;

--========================================================================
-- PROCEDURE : Update_Hierarchy_Data  PUBLIC
-- PARAMETERS: p_data_set_name        identifies row (1/4)
--             p_bucket_name          identfies row (2/4)
--             p_organization_id      identifies_row (3/4)
--             p_inventory_item_id    identifies_row (4/4)
--             p_?????                one parameter per column to update
-- COMMENT   : Updates the hierarchy data on a row in MTL_MGD_INVENTORY_POSITIONS;
--             standard who value are optional and defaulted from profile options
--=======================================================================--
PROCEDURE Update_Hierarchy_Data
( p_data_set_name             IN  VARCHAR2
, p_bucket_name               IN  VARCHAR2
, p_organization_id           IN  NUMBER
, p_inventory_item_id         IN  NUMBER
, p_last_update_date          IN  DATE   DEFAULT NULL
, p_last_updated_by           IN  NUMBER DEFAULT NULL
, p_last_update_login         IN  NUMBER DEFAULT NULL
, p_request_id                IN  NUMBER DEFAULT NULL
, p_program_application_id    IN  NUMBER DEFAULT NULL
, p_program_id                IN  NUMBER DEFAULT NULL
, p_program_update_date       IN  DATE   DEFAULT NULL
, p_hierarchy_delta_qty       IN  NUMBER
, p_hierarchy_end_on_hand_qty IN  NUMBER
)
IS
BEGIN

  UPDATE mtl_mgd_inventory_positions
    SET  last_update_date          = NVL(p_last_update_date, SYSDATE)
      ,  last_updated_by           = NVL
                                     ( p_last_updated_by
                                     , NVL(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')), 0)
                                     )
      ,  last_update_login         = NVL
                                     ( p_last_update_login
                                     , TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'))
                                     )
      ,  request_id                = NVL
                                    ( p_request_id
                                    , TO_NUMBER(FND_PROFILE.VALUE('CONC_REQ_ID'))
                                    )
      ,  program_application_id    = NVL
                                     ( p_program_application_id
                                     , TO_NUMBER
                                       (FND_PROFILE.Value('PROG_APPL_ID'))
                                     )
      ,  program_id                = NVL
                                     ( p_program_id
                                     , TO_NUMBER
                                       (FND_PROFILE.Value('CONC_PROG_ID'))
                                     )
      ,  program_update_date       = NVL(p_program_update_date, SYSDATE)
      ,  hierarchy_delta_qty       = p_hierarchy_delta_qty
      ,  hierarchy_end_on_hand_qty = p_hierarchy_end_on_hand_qty
   WHERE data_set_name     = p_data_set_name
     AND bucket_name       = p_bucket_name
     AND organization_id   = p_organization_id
     AND inventory_item_id = p_inventory_item_id;

END Update_Hierarchy_Data;

--========================================================================
-- PROCEDURE : Delete                 PUBLIC
-- PARAMETERS: p_data_set_name        delete specific data set name
--             p_created_by           delete data set for specific user ID
--             p_creation_date        delete data set created before date
-- COMMENT   : Delete rows using one or more specified criteria (each criteria is
--             an additional filter
--=======================================================================--
PROCEDURE Delete
( p_data_set_name             IN  VARCHAR2 DEFAULT NULL
, p_created_by                IN  NUMBER   DEFAULT NULL
, p_creation_date             IN  DATE     DEFAULT NULL
)
IS
BEGIN
  DELETE
    FROM  mtl_mgd_inventory_positions
    WHERE data_set_name  = NVL(p_data_set_name, data_set_name)
      AND created_by     = NVL(p_created_by, created_by)
      AND creation_date <= NVL(p_creation_date, creation_date);
END Delete;

--========================================================================
-- PROCEDURE : Delete_All             PUBLIC
-- COMMENT   : Delete all rows
--=======================================================================--
PROCEDURE Delete_All
IS
BEGIN
  DELETE
    FROM  mtl_mgd_inventory_positions;
END Delete_All;

END MTL_MGD_INV_POSITIONS_PKG;

/
