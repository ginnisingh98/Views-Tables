--------------------------------------------------------
--  DDL for Package AHL_VWP_MR_CST_PR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_MR_CST_PR_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMCPS.pls 115.1 2003/09/25 21:15:08 rtadikon noship $ */
-----------------------------------------------------------
-- PACKAGE
-- AHL_VWP_MR_CST_PR_PVT
--
-- PURPOSE
--    This package is a Private API for managing Visit Stages information in CMRO.
--    It contains specification for pl/sql records and tables
--
--    Estimate_mr_cost (see below for specification)
--    Estimate_mr_price (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
--
--
--  Created By Rajanath Tadikonda/rtadikon 25-Aug-2003
--
-----------------------------------------------------------

-------------------------------------
-- Visit MR Record Type   -----
-------------------------------------
--

---------------------------------------------------------------------
-- PROCEDURE
-- Estimate_mr_cost
-- Estimate_mr_price
--
-- PURPOSE
--
--
-- PARAMETERS
--
--
--
-- NOTES
--    1. Procedure helps out to link between JSP page and API package
--    2. On the basis  of operation flag as one field in each record type
--       the further procedure for create/update/delete for Visit MRs.
---------------------------------------------------------------------

PROCEDURE Estimate_MR_Cost (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  :=Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  :=Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    :=Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2,
   p_x_cost_price_rec     IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
);


PROCEDURE Estimate_MR_Price (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  :=Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2,
   p_x_cost_price_rec     IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
);


PROCEDURE Get_MR_Items_No_Price(
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  :=Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   p_cost_price_rec       IN  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
   x_cost_price_tbl      OUT    NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_tbl_type
);

PROCEDURE Get_MR_Cost_Details(
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  :=Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2,
   p_x_cost_price_rec     IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
);

END AHL_VWP_MR_CST_PR_PVT;

 

/
