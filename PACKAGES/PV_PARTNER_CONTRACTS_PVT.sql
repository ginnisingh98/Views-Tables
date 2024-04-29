--------------------------------------------------------
--  DDL for Package PV_PARTNER_CONTRACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PARTNER_CONTRACTS_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvpcos.pls 120.1 2005/08/19 13:34:37 appldev ship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Partner_Contracts_PVT
-- Purpose
--
-- History
--        01-APR-2004    Karen.Tsao     Fixed for bug 3540615. Added API Is_Contract_Exists.
--        09-DEC-2004    Karen.Tsao     Modified for 11.5.11.
--        02-MAY-2004    Karen.Tsao     Took out Is_Contract_Exists() because it is not used.
--
-- NOTE
--
-- ===============================================================
-- Default number of records fetch per call
-- G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Get_Appropriate_Contract
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--      p_partner_party_id           IN   NUMBER
--      p_program_id                 IN   NUMBER
--
--   OUT
--      x_contract_id                OUT  NUMBER
--   Version : Current version 1.0
--
--   End of Comments
--   ==============================================================================
--
function get_contract_response_options( p_geo_hierarchy_id in varchar2 )
return varchar2;

PROCEDURE Is_Contract_Exist_Then_Create(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2

   ,p_program_id                 IN   NUMBER
   ,p_partner_id                 IN   NUMBER
   ,p_enrl_request_id            IN   NUMBER

   ,x_exist                      OUT  NOCOPY  VARCHAR2
);

PROCEDURE Get_Contract_Response_Options(
     p_partner_party_id           IN   NUMBER
    ,x_cntr_resp_opt_tbl          OUT  NOCOPY   JTF_VARCHAR2_TABLE_200
);

END PV_Partner_Contracts_PVT;

 

/
