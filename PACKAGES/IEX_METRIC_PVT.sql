--------------------------------------------------------
--  DDL for Package IEX_METRIC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_METRIC_PVT" AUTHID CURRENT_USER AS
/* $Header: iexvmtrs.pls 120.3 2005/07/07 14:09:34 jypark noship $ */

  TYPE Metric_ID_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE Metric_Name_Tbl_Type IS TABLE OF VARCHAR2(45) INDEX BY BINARY_INTEGER;
  TYPE Metric_Value_Tbl_Type IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  TYPE Metric_Rating_Tbl_Type IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;

  PROCEDURE Get_Metric_Info
      (p_api_version      	IN  NUMBER := 1.0,
       p_init_msg_list    	IN  VARCHAR2,
       p_commit           	IN  VARCHAR2,
       p_validation_level 	IN  NUMBER,
       x_return_status    	OUT NOCOPY VARCHAR2,
       x_msg_count        	OUT NOCOPY NUMBER,
       x_msg_data         	OUT NOCOPY VARCHAR2,
       p_party_id         	IN  NUMBER,
       p_cust_account_id  	IN  NUMBER,
       p_customer_site_use_id   IN  NUMBER,
       p_delinquency_id     	IN  NUMBER,
       p_filter_by_object       IN  VARCHAR2,
       x_metric_id_tbl          OUT NOCOPY Metric_ID_Tbl_Type,
       x_metric_name_tbl        OUT NOCOPY Metric_Name_Tbl_Type,
       x_metric_value_tbl       OUT NOCOPY Metric_Value_Tbl_Type,
       x_metric_rating_tbl      OUT NOCOPY Metric_Rating_tbl_Type);

  PROCEDURE Test_Metric
      (
       p_filter_id         	IN  NUMBER,
       p_score_comp_type_id IN  NUMBER,
       x_return_status    	OUT NOCOPY VARCHAR2,
       x_metric_value       OUT NOCOPY VARCHAR2);
END;

 

/
