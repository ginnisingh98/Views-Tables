--------------------------------------------------------
--  DDL for Package OKL_CREDIT_DATAPOINTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREDIT_DATAPOINTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCDPS.pls 120.4 2006/04/06 19:55:54 rravikir noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_CREDIT_DATAPOINTS_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(30)  := OKL_API.G_APP_NAME;
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_USER_ID              CONSTANT NUMBER        := FND_GLOBAL.USER_ID;
  G_LOGIN_ID             CONSTANT NUMBER        := FND_GLOBAL.LOGIN_ID;
  G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
  G_DB_ERROR             CONSTANT VARCHAR2(30)  := 'OKL_DB_ERROR';
  G_PKG_NAME_TOKEN       CONSTANT VARCHAR2(30)  := 'PKG_NAME';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(30)  := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLERRM';
  G_API_TYPE         	 CONSTANT VARCHAR2(4) := '_PVT';

  --subtype lap_dp_tbl_type is okl_lad_pvt.lad_tbl_type;

  TYPE lap_dp_rec_type IS RECORD (
     id                             okl_leaseapp_datapoints.id%TYPE
    ,object_version_number          okl_leaseapp_datapoints.object_version_number%TYPE
    ,leaseapp_id            		okl_leaseapp_datapoints.leaseapp_id%TYPE
	,data_point_id          		okl_leaseapp_datapoints.data_point_id%TYPE
	,data_point_category			okl_leaseapp_datapoints.data_point_category%TYPE
	,data_point_value       		okl_leaseapp_datapoints.data_point_value%TYPE
	,data_point_name				ar_cmgt_data_points_vl.data_point_name%TYPE
	,description					ar_cmgt_data_points_vl.description%TYPE);

  TYPE lap_dp_tbl_type IS TABLE OF lap_dp_rec_type INDEX BY PLS_INTEGER;

FUNCTION credit_line_number(x_resultout	OUT NOCOPY VARCHAR2,
       			     		x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION credit_line_expiration_date (x_resultout	OUT NOCOPY VARCHAR2,
   			  						  x_errormsg	OUT NOCOPY VARCHAR2) RETURN DATE;

FUNCTION currency (x_resultout	OUT NOCOPY VARCHAR2,
               	   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION sales_rep (x_resultout	OUT NOCOPY VARCHAR2,
               		x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION program_vendor (x_resultout	OUT NOCOPY VARCHAR2,
               			 x_errormsg		OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION program_agreement_number (x_resultout	OUT NOCOPY VARCHAR2,
               				       x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION expected_start_date (x_resultout	OUT NOCOPY VARCHAR2,
               				  x_errormsg	OUT NOCOPY VARCHAR2) RETURN DATE;

FUNCTION expected_delivery_date (x_resultout	OUT NOCOPY VARCHAR2,
               				     x_errormsg		OUT NOCOPY VARCHAR2) RETURN DATE;

FUNCTION expected_funding_date (x_resultout	OUT NOCOPY VARCHAR2,
                     			x_errormsg	OUT NOCOPY VARCHAR2) RETURN DATE;

FUNCTION lease_application_template (x_resultout	OUT NOCOPY VARCHAR2,
                   				     x_errormsg		OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION org_unit (x_resultout	OUT NOCOPY VARCHAR2,
                   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION prospect_address (x_resultout	OUT NOCOPY VARCHAR2,
                   		   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION term_of_deal (x_resultout	OUT NOCOPY VARCHAR2,
                   	   x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION financial_product (x_resultout	OUT NOCOPY VARCHAR2,
                   			x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION item (x_resultout	OUT NOCOPY VARCHAR2,
               x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION item_description (x_resultout	OUT NOCOPY VARCHAR2,
                  		   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION item_supplier (x_resultout	OUT NOCOPY VARCHAR2,
                 		x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION model (x_resultout	OUT NOCOPY VARCHAR2,
                x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION manufacturer (x_resultout	OUT NOCOPY VARCHAR2,
                   	   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION year_of_manufacture (x_resultout	OUT NOCOPY VARCHAR2,
                   	   		  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION no_of_units (x_resultout	OUT NOCOPY VARCHAR2,
                   	  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;


FUNCTION unit_cost (x_resultout	OUT NOCOPY VARCHAR2,
                   	x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION install_site (x_resultout	OUT NOCOPY VARCHAR2,
                   	   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;


FUNCTION usage_of_equipment  (x_resultout	OUT NOCOPY VARCHAR2,
              			   	  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION usage_industry (x_resultout	OUT NOCOPY VARCHAR2,
              		     x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION usage_category  (x_resultout	OUT NOCOPY VARCHAR2,
                	      x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION usage_amount (x_resultout	OUT NOCOPY VARCHAR2,
                       x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION add_on_item (x_resultout	OUT NOCOPY VARCHAR2,
              		  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION add_on_item_description (x_resultout	OUT NOCOPY VARCHAR2,
              			  		  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION add_on_item_supplier (x_resultout	OUT NOCOPY VARCHAR2,
              			  	   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION add_on_item_model (x_resultout	OUT NOCOPY VARCHAR2,
              			    x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION add_on_item_manufacturer (x_resultout	OUT NOCOPY VARCHAR2,
              			  		   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION add_on_item_amount (x_resultout	OUT NOCOPY VARCHAR2,
              			     x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION asset_residual_value (x_resultout	OUT NOCOPY VARCHAR2,
              			       x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION down_payment_amount (x_resultout	OUT NOCOPY VARCHAR2,
              			      x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION subsidy_amount  (x_resultout	OUT NOCOPY VARCHAR2,
              			  x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION trade_in_amount  (x_resultout	OUT NOCOPY VARCHAR2,
              			   x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION trade_in_asset_number  (x_resultout	OUT NOCOPY VARCHAR2,
              			  		 x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION pmnt_frequency  (x_resultout	OUT NOCOPY VARCHAR2,
              			  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION pmnt_arrears_yn  (x_resultout	OUT NOCOPY VARCHAR2,
              			   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION pmnt_periods  (x_resultout	OUT NOCOPY VARCHAR2,
              			x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION pmnt_amounts  (x_resultout	OUT NOCOPY VARCHAR2,
              			x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION pmnt_start_date  (x_resultout	OUT NOCOPY VARCHAR2,
              			   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION pmnt_end_date  (x_resultout	OUT NOCOPY VARCHAR2,
              			 x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION fee_type  (x_resultout	OUT NOCOPY VARCHAR2,
              		x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION fee_name  (x_resultout	OUT NOCOPY VARCHAR2,
              		x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION fee_amount  (x_resultout	OUT NOCOPY VARCHAR2,
              		  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION fee_date  (x_resultout	OUT NOCOPY VARCHAR2,
              		x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION amount_requested(x_resultout	OUT NOCOPY VARCHAR2,
       					  x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION total_subsidized_cost(x_resultout	OUT NOCOPY VARCHAR2,
       					       x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION total_financed_amount(x_resultout	OUT NOCOPY VARCHAR2,
     					       x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION security_deposit(x_resultout	OUT NOCOPY VARCHAR2,
       					  x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION billed_tax(x_resultout	OUT NOCOPY VARCHAR2,
       				x_errormsg	OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION payment_structure(x_resultout	OUT NOCOPY VARCHAR2,
       					   x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

PROCEDURE fetch_leaseapp_datapoints(p_api_version      IN   NUMBER
                    				,p_init_msg_list   IN   VARCHAR2  DEFAULT OKL_API.G_FALSE
                      				,p_leaseapp_id	   IN  	NUMBER
                      				,x_lap_dp_tbl_type OUT NOCOPY  lap_dp_tbl_type
                      				,x_return_status   OUT NOCOPY  VARCHAR2
                      				,x_msg_count       OUT NOCOPY  NUMBER
                      				,x_msg_data        OUT NOCOPY  VARCHAR2);

PROCEDURE delete_leaseapp_datapoints(p_api_version     IN   NUMBER
                    				,p_init_msg_list   IN   VARCHAR2  DEFAULT OKL_API.G_FALSE
                      				,p_leaseapp_id	   IN  	NUMBER
                      				,x_return_status   OUT NOCOPY  VARCHAR2
                      				,x_msg_count       OUT NOCOPY  NUMBER
                      				,x_msg_data        OUT NOCOPY  VARCHAR2);

PROCEDURE store_leaseapp_datapoints(p_api_version      IN   NUMBER
                  				   ,p_init_msg_list   IN  VARCHAR2  DEFAULT OKL_API.G_FALSE
                      			   ,p_lap_dp_tbl      IN  lap_dp_tbl_type
                      			   ,x_return_status   OUT NOCOPY  VARCHAR2
                      			   ,x_msg_count       OUT NOCOPY  NUMBER
                      			   ,x_msg_data        OUT NOCOPY  VARCHAR2);

FUNCTION leaseapp_datapoints_exists(p_leaseapp_id	   IN  	NUMBER) RETURN BOOLEAN;

FUNCTION fetch_data_point_value(x_resultout	OUT NOCOPY VARCHAR2,
       				   			x_errormsg	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

END OKL_CREDIT_DATAPOINTS_PVT;

/
