--------------------------------------------------------
--  DDL for Package MTL_MGD_INV_POSITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_MGD_INV_POSITIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: INVTPOSS.pls 115.1 2002/12/24 23:29:30 vjavli ship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVUTOSS.pls                                                      |
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
);

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
);

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
);

--========================================================================
-- PROCEDURE : Delete_All             PUBLIC
-- COMMENT   : Delete all rows
--=======================================================================--
PROCEDURE Delete_All;

END MTL_MGD_INV_POSITIONS_PKG;

 

/
