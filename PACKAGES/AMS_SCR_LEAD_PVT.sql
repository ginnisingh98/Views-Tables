--------------------------------------------------------
--  DDL for Package AMS_SCR_LEAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_SCR_LEAD_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvslds.pls 115.2 2002/12/26 09:41:58 sodixit noship $ */
-- ===============================================================
-- Package name
--         AMS_SCR_LEAD_PVT
-- Purpose
--          This package contains APIs used for creating Sales Lead
--
-- History
--
-- NOTE
--
-- ===============================================================

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

TYPE scr_lead_rec_type IS RECORD
(
          party_id                  NUMBER,
	  FIRST_NAME		    VARCHAR2(150),
	  LAST_NAME		    VARCHAR2(150),
	  ORGANIZATION		    VARCHAR2(255),
	  JOB_TITLE		    VARCHAR2(50),
	  EMAIL_ADDRESS             VARCHAR2(240),
	  DAY_AREA_CODE		    VARCHAR2(10),
	  DAY_PHONE_NUMBER	    VARCHAR2(25),
	  DAY_EXTENSION		    VARCHAR2(20),
	  ADDRESS1		    VARCHAR2(240),
	  ADDRESS2		    VARCHAR2(240),
	  ADDRESS3		    VARCHAR2(240),
	  ADDRESS4		    VARCHAR2(240),
	  CITY			    VARCHAR2(60),
	  STATE			    VARCHAR2(60),
	  COUNTRY		    VARCHAR2(60),
	  POSTAL_CODE		    VARCHAR2(60),
          INTEREST_TYPE		    NUMBER,
	  PURCHASING_TIME_FRAME     Varchar2(30),
	  BUDGET_STATUS_CODE        Varchar2(30),
	  BUDGET_AMOUNT             NUMBER,
	  BUDGET_CURRENCY_CODE      VARCHAR2(30),
	  CONTACT_ROLE_CODE         Varchar2(30)
);

g_miss_lead_rec		       scr_lead_rec_type;

--===================================================================
--   API Name
--         CREATE_SALES_LEAD
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_flow_component_id       IN  Number
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   ==============================================================================
--

PROCEDURE CREATE_SALES_LEAD(
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_party_type		 IN   VARCHAR2,
    p_scr_lead_rec               IN   scr_lead_rec_type := g_miss_lead_rec,
    p_camp_sch_source_code	 IN   VARCHAR2,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_party_id                   IN   NUMBER,
    p_org_party_id            IN   NUMBER,
    p_org_rel_party_id           IN   NUMBER
     );

END  AMS_SCR_LEAD_PVT;

 

/
