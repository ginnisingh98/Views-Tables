--------------------------------------------------------
--  DDL for Package CS_COVERAGE_SERVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_COVERAGE_SERVICE_PUB" AUTHID CURRENT_USER AS
/* $Header: csctcsos.pls 115.0 99/07/16 08:51:19 porting ship  $ */

/*******************************************************************************
  --  GLOBAL VARIABLES
*******************************************************************************/

  G_PKG_NAME       CONSTANT   VARCHAR2(200)   := 'CS_COVERAGE_SERVICE_PUB';
  G_APP_NAME       CONSTANT   VARCHAR2(3)     := 'CS';

/*******************************************************************************
  --  Procedures and Functions
*******************************************************************************/

  PROCEDURE Check_Service_Overlap (
                p_api_version          IN  NUMBER,
                p_init_msg_list        IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit               IN  VARCHAR2  := FND_API.G_FALSE,
                p_service_inv_item_id  IN  NUMBER,
                p_organization_id      IN  NUMBER,
		      p_customer_product_id  IN  NUMBER,
			 p_coverage_level_code  IN  VARCHAR2,
			 p_coverage_level_value IN  NUMBER,
			 p_coverage_level_id    IN  NUMBER,
                p_start_date_active    IN  DATE,
                p_end_date_active      IN  DATE,
                x_Overlap_flag         OUT VARCHAR2,
                x_return_status        OUT VARCHAR2,
                x_msg_count            OUT NUMBER,
                x_msg_data             OUT VARCHAR2  );

  PROCEDURE Check_Other_Overlap (
                p_api_version          IN  NUMBER,
                p_init_msg_list        IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit               IN  VARCHAR2  := FND_API.G_FALSE,
                p_service_inv_item_id  IN  NUMBER,
                p_organization_id      IN  NUMBER,
		      p_customer_product_id  IN  NUMBER,
			 p_coverage_level_code  IN  VARCHAR2,
			 p_coverage_level_value IN  NUMBER,
                p_start_date_active    IN  DATE,
                p_end_date_active      IN  DATE,
                x_Overlap_flag         OUT VARCHAR2,
                x_return_status        OUT VARCHAR2,
                x_msg_count            OUT NUMBER,
                x_msg_data             OUT VARCHAR2  );

  PROCEDURE Validate_Coverage_Times (
                p_api_version             IN  NUMBER,
                p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
                p_coverage_id             IN  NUMBER,
                p_business_process_id     IN  NUMBER,
                p_call_date_time          IN  DATE,
                p_time_zone_id            IN  NUMBER,
                p_exception_coverage_flag IN  VARCHAR2,
		      x_covered_yes_no          OUT VARCHAR2,
                x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2  );

END CS_COVERAGE_SERVICE_PUB;

 

/
