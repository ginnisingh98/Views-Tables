--------------------------------------------------------
--  DDL for Package CS_GET_COVERAGE_VALUES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_GET_COVERAGE_VALUES_PUB" AUTHID CURRENT_USER AS
/* $Header: csctcvgs.pls 115.0 99/07/16 08:52:05 porting ship  $ */

/*******************************************************************************
  --  GLOBAL VARIABLES
*******************************************************************************/

  G_PKG_NAME       CONSTANT   VARCHAR2(200)   := 'CS_GET_COVERAGE_VALUES_PUB';
  G_APP_NAME       CONSTANT   VARCHAR2(3)     := 'CS';

/*******************************************************************************
  --  Procedures and Functions
*******************************************************************************/

  PROCEDURE Get_Bill_Rates (
                p_api_version             IN  NUMBER,
                p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
                p_coverage_id             IN  NUMBER,
		      p_exception_coverage_flag IN  VARCHAR2,
			 p_business_process_id     IN  NUMBER,
			 p_bill_rate_code          IN  VARCHAR2,
			 p_unit_of_measure_code    IN  VARCHAR2,
			 p_list_price              IN  NUMBER,
			 x_flat_rate               OUT NUMBER,
			 x_percent_rate            OUT NUMBER,
			 x_ltem_price              OUT NUMBER,
                x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2  );

  PROCEDURE Get_Preferred_Engineer (
                p_api_version             IN  NUMBER,
                p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
                p_coverage_id             IN  NUMBER,
			 p_business_process_id     IN  VARCHAR2,
		      p_exception_coverage_flag IN  VARCHAR2,
			 x_preferred_engineer1     OUT VARCHAR2,
			 x_preferred_engineer2     OUT VARCHAR2,
                x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2  );

  PROCEDURE Get_Exception_coverage (
                p_api_version             IN  NUMBER,
                p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
                p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
                p_coverage_id             IN  NUMBER,
		      x_exception_coverage_id   OUT NUMBER,
                x_return_status           OUT VARCHAR2,
                x_msg_count               OUT NUMBER,
                x_msg_data                OUT VARCHAR2  );

END CS_GET_COVERAGE_VALUES_PUB;

 

/
