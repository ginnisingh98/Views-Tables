--------------------------------------------------------
--  DDL for Package CZ_PSFT_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_PSFT_INTEGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: czpsints.pls 120.1.12000000.1 2007/01/18 02:02:49 appldev ship $ */

   TYPE t_ref IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;
   TYPE t_name IS TABLE OF VARCHAR2(2000)
      INDEX BY BINARY_INTEGER;

PROCEDURE get_solutions_details(solutionsXML 	OUT NOCOPY CLOB,
				x_run_id 	IN OUT NOCOPY NUMBER,
				x_pb_status 	IN OUT NOCOPY VARCHAR2);

PROCEDURE get_models_details(modelsXML 	OUT NOCOPY CLOB,
			     x_run_id 	IN OUT NOCOPY NUMBER,
			     x_pb_status IN OUT NOCOPY VARCHAR2);

PROCEDURE get_config_details(p_api_version             IN NUMBER
                            ,p_config_hdr_id           IN NUMBER
                            ,p_config_rev_nbr          IN NUMBER
                            ,p_product_key             IN VARCHAR2
                            ,p_application_id          IN NUMBER
                            ,p_price_info_list         IN SYSTEM.VARCHAR_TBL_TYPE
                            ,p_check_violation_flag    IN VARCHAR2
                            ,p_check_connection_flag   IN VARCHAR2
                            ,p_baseline_config_hdr_id  IN NUMBER
                            ,p_baseline_config_rev_nbr IN NUMBER
                            ,x_config_details       OUT NOCOPY CLOB
                            ,x_return_status        OUT NOCOPY VARCHAR2
                            ,x_msg_count            OUT NOCOPY NUMBER
                            ,x_msg_data             OUT NOCOPY VARCHAR2
                            );


END cz_psft_integration_pvt;

 

/
