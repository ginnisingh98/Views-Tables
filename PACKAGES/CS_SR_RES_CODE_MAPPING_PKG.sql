--------------------------------------------------------
--  DDL for Package CS_SR_RES_CODE_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_RES_CODE_MAPPING_PKG" AUTHID CURRENT_USER as
/* $Header: csxrscds.pls 120.0 2005/12/12 16:10:26 smisra noship $ */

TYPE rescode_search_rec IS RECORD (
   service_request_type_id NUMBER,
   inventory_item_id NUMBER,
   organization_id NUMBER,
   product_category_id NUMBER,
   problem_code VARCHAR2(30)
 );

PROCEDURE VALIDATE_RESOLUTION_CODE
( p_api_version   	IN 	NUMBER,
  p_init_msg_list 	IN 	VARCHAR2,
  p_rescode_criteria_rec  IN CS_SR_RES_CODE_MAPPING_PKG.rescode_search_rec,
  p_resolution_code   IN  VARCHAR2,
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_count      OUT NOCOPY     NUMBER,
  x_msg_data       OUT NOCOPY    VARCHAR2
);



TYPE rescode_map_criteria_rec IS RECORD (
    resolution_map_id NUMBER,
    service_request_type_id NUMBER,
    inventory_item_id NUMBER,
    organization_id NUMBER,
    product_category_id NUMBER,
    problem_code varchar2(30),
    start_date_active DATE,
    end_date_active DATE
);

TYPE resolution_codes_rec IS RECORD (
        resolution_map_detail_id NUMBER,
        resolution_code varchar2(30),
        resolution_code_meaning varchar2(80),
        start_date_active DATE,
        end_date_active DATE
);

TYPE resolution_codes_tbl_type IS TABLE OF resolution_codes_rec INDEX BY BINARY_INTEGER;


PROCEDURE CREATE_MAPPING_RULES
( p_api_version			  IN         NUMBER,
  p_init_msg_list		  IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_commit			      IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_rescode_map_criteria_rec IN rescode_map_criteria_rec,
  p_resolution_codes_tbl        IN resolution_codes_tbl_type,
  x_return_status		  OUT NOCOPY VARCHAR2,
  x_msg_count			  OUT NOCOPY NUMBER,
  x_msg_data			  OUT NOCOPY VARCHAR2,
  x_resolution_map_id        OUT NOCOPY NUMBER
);

PROCEDURE UPDATE_MAPPING_RULES
( p_api_version			  IN         NUMBER,
  p_init_msg_list		  IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_commit			      IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_rescode_map_criteria_rec  IN rescode_map_criteria_rec,
  p_resolution_codes_tbl         IN resolution_codes_tbl_type,
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
) ;


END; -- Package Specification CS_SR_RES_CODE_MAPPING_PKG

 

/
