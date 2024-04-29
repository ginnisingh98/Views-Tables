--------------------------------------------------------
--  DDL for Package CS_SR_PROB_CODE_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_PROB_CODE_MAPPING_PKG" AUTHID CURRENT_USER as
/* $Header: csxpbcds.pls 120.0 2005/12/12 16:14:21 smisra noship $ */

TYPE probcode_search_rec IS RECORD (
   service_request_type_id NUMBER,
   inventory_item_id NUMBER,
   organization_id NUMBER,
   product_category_id NUMBER
 );

PROCEDURE VALIDATE_PROBLEM_CODE
( p_api_version   	IN 	NUMBER,
   p_init_msg_list 	IN 	VARCHAR2,
   p_probcode_criteria_rec  IN CS_SR_PROB_CODE_MAPPING_PKG.probcode_search_rec,
   p_problem_code   IN  VARCHAR2,
   x_return_status  OUT NOCOPY    VARCHAR2,
   x_msg_count      OUT NOCOPY     NUMBER,
   x_msg_data       OUT NOCOPY    VARCHAR2
);




TYPE probcode_map_criteria_rec IS RECORD (
    problem_map_id NUMBER,
    service_request_type_id NUMBER,
    inventory_item_id NUMBER,
    organization_id NUMBER,
    product_category_id NUMBER,
    start_date_active DATE,
    end_date_active DATE
);

TYPE problem_codes_rec IS RECORD (
        problem_map_detail_id NUMBER,
        problem_code varchar2(30),
        problem_code_meaning varchar2(80),
        start_date_active DATE,
        end_date_active DATE
);

TYPE problem_codes_tbl_type IS TABLE OF problem_codes_rec INDEX BY BINARY_INTEGER;

PROCEDURE CREATE_MAPPING_RULES
( p_api_version			  IN         NUMBER,
  p_init_msg_list		  IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_commit			      IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_probcode_map_criteria_rec IN probcode_map_criteria_rec,
  p_problem_codes_tbl       IN problem_codes_tbl_type,
  x_return_status		  OUT NOCOPY VARCHAR2,
  x_msg_count			  OUT NOCOPY NUMBER,
  x_msg_data			  OUT NOCOPY VARCHAR2,
  x_problem_map_id        OUT NOCOPY NUMBER
);

PROCEDURE UPDATE_MAPPING_RULES
( p_api_version			  IN         NUMBER,
  p_init_msg_list		  IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_commit			      IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_probcode_map_criteria_rec IN probcode_map_criteria_rec,
  p_problem_codes_tbl       IN  problem_codes_tbl_type,
  x_return_status		  OUT NOCOPY VARCHAR2,
  x_msg_count			  OUT NOCOPY NUMBER,
  x_msg_data			  OUT NOCOPY VARCHAR2
);

PROCEDURE PROPAGATE_MAP_CRITERIA_DATES
( p_api_version			  IN         NUMBER,
  p_init_msg_list		  IN         VARCHAR2 	:= FND_API.G_FALSE,
  x_return_status		  OUT NOCOPY VARCHAR2,
  x_msg_count			  OUT NOCOPY NUMBER,
  x_msg_data			  OUT NOCOPY VARCHAR2
);

END; -- Package Specification CS_SR_PROB_CODE_MAPPING_PKG

 

/
