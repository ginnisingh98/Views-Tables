--------------------------------------------------------
--  DDL for Package ZPB_DHMINTERFACE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_DHMINTERFACE_GRP" AUTHID CURRENT_USER as
/* $Header: ZPBGDHMS.pls 120.0.12010.2 2005/12/23 06:00:56 appldev noship $ */

-- API name   : Get_Business_Area_Info
-- Type       : Group
-- Function   : Returns the Business Area ID and Ledger ID for the
--              current user session
-- Pre-reqs   : None.
-- Parameters :
--
--   OUT : x_business_area_id  OUT NUMBER
--         x_ledger_id         OUT NUMBER
--
procedure Get_Business_Area_Info
   (x_business_area_id  OUT NOCOPY ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type,
    x_ledger_id         OUT NOCOPY FEM_LEDGERS_B.LEDGER_ID%type,
    x_snapshot_id       OUT NOCOPY NUMBER);

-- API name   : Export_Dimension
-- Type       : Group
-- Function   : Exports the metadata from the Personal AW to the FEM personal
--              tables for DHM use
-- Pre-reqs   : None.
-- Parameters :
--   IN : p_api_version      IN NUMBER   Required
--        p_init_msg_list    IN VARCHAR2 Optional Default = G_FALSE
--        p_commit           IN VARCHAR2 Optional Default = G_FALSE
--        p_validation_level IN NUMBER   Optional Default = G_VALID_LEVEL_FULL
--        p_dimension_id     IN NUMBER   The FEM dimension ID
--        p_user_id          IN NUMBER   The FND_USER user_id
--        p_attr_id          IN VARCHAR2 The EPB attribute id (EPB-only)
--
--   OUT : x_return_status OUT  VARCHAR2(1)
--         x_msg_count     OUT  NUMBER
--         x_msg_data      OUT  VARCHAR2(2000)
--
-- Version : Current version    1.0
--           Initial version    1.0
--
-- Notes : None
--
procedure Transfer_To_DHM
   (p_api_version      IN      NUMBER,
    p_init_msg_list    IN      VARCHAR2 := FND_API.G_FALSE,
    p_commit           IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,
    p_dimension_id     IN      NUMBER,
    p_user_id          IN      NUMBER,
    p_attr_id          IN      VARCHAR2 := NULL);

-- API name   : Import_Dimension
-- Type       : Group
-- Function   : Imports the metadata from the FEM personal tables back into the
--              Personal AW
-- Pre-reqs   : None.
-- Parameters :
--   IN : p_api_version      IN NUMBER   Required
--        p_init_msg_list    IN VARCHAR2 Optional Default = G_FALSE
--        p_commit           IN VARCHAR2 Optional Default = G_FALSE
--        p_validation_level IN NUMBER   Optional Default = G_VALID_LEVEL_FULL
--        p_dimension_id     IN NUMBER   The FEM dimension ID
--        p_user_id          IN NUMBER   The FND_USER user_id
--
--   OUT : x_return_status OUT  VARCHAR2(1)
--         x_msg_count     OUT  NUMBER
--         x_msg_data      OUT  VARCHAR2(2000)
--
-- Version : Current version    1.0
--           Initial version    1.0
--
-- Notes : None
--
procedure Transfer_To_EPB
   (p_api_version      IN      NUMBER,
    p_init_msg_list    IN      VARCHAR2 := FND_API.G_FALSE,
    p_commit           IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,
    p_dimension_id     IN      NUMBER,
    p_user_id          IN      NUMBER,
    p_attr_id          IN      VARCHAR2 := NULL);

end ZPB_DHMInterface_GRP;

 

/
