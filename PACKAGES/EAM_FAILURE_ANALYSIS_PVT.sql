--------------------------------------------------------
--  DDL for Package EAM_FAILURE_ANALYSIS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_FAILURE_ANALYSIS_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVFALS.pls 120.2 2006/10/05 07:31:43 amourya noship $ */

Type eam_asset_failure_rec_type is record
        ( ASSET_TYPE                  	NUMBER        	,
          MAINTENANCE_OBJECT_ID	      	NUMBER 	    	,
          MAINTAINED_NUMBER       	VARCHAR2(30)  	,
          DESCRIPTIVE_TEXT            	VARCHAR2(240) 	,
          MAINTAINED_GROUP	        VARCHAR2(40)  	,
          MAINTAINED_GROUP_ID	        NUMBER        	,
          WIP_ENTITY_ID		        NUMBER 		,
          WIP_ENTITY_NAME		VARCHAR2(240) 	,
          ORGANIZATION_ID             	NUMBER        	,
          ORGANIZATION_CODE           	VARCHAR2(3)   	,
          ASSET_CATEGORY 		VARCHAR2(163) 	,
          ASSET_CATEGORY_ID           	NUMBER        	,
          ASSET_LOCATION 		VARCHAR2(30) 	,
          OWNING_DEPARTMENT 	        VARCHAR2(10) 	,
          FAILURE_CODE 			VARCHAR2(80) 	,
          CAUSE_CODE 			VARCHAR2(80) 	,
          RESOLUTION_CODE 		VARCHAR2(80)	,
          FAILURE_DATE 		        DATE 		,
          COMMENTS 		        VARCHAR2(2000)  ,
          DAYS_BETWEEN_FAILURES       	NUMBER          ,
          TIME_TO_REPAIR              	NUMBER        	,
          METER_ID                    	NUMBER        	,
	  METER_NAME			VARCHAR2(50)	,
          METER_UOM	  	        VARCHAR2(3) 	,
          READING_BETWEEN_FAILURES    	NUMBER		,
          INCLUDE_FOR_READING_AGGR	VARCHAR2(1)	,
          INCLUDE_FOR_COST_AGGR	      	VARCHAR2(1)
        );


Type eam_asset_failure_tbl_type is table of eam_asset_failure_rec_type
          INDEX BY BINARY_INTEGER;

TYPE children_assets_tbl_type is table of number INDEX BY BINARY_INTEGER;

Procedure GET_HISTORY_RECORDS_ADV
( P_WHERE_CLAUSE	    	IN  VARCHAR2,
  P_FROM_DATE_CLAUSE		IN  VARCHAR2,
  P_SELECTED_METER	  	IN  NUMBER,
  P_CURRENT_ORG_ID    		IN  NUMBER,
  X_GROUP_ID 	        	OUT NOCOPY  NUMBER,
  x_return_status     		OUT NOCOPY  VARCHAR2,
  x_msg_count         		OUT NOCOPY  NUMBER,
  x_msg_data          		OUT NOCOPY  VARCHAR2,
  x_unmatched_uom_class 	OUT NOCOPY  VARCHAR2,
  x_unmatched_currency  	OUT NOCOPY  VARCHAR2);

Procedure GET_HISTORY_RECORDS_FA_ADV
( P_WHERE_CLAUSE	        IN VARCHAR2,
  P_WHERE_CLAUSE_1		IN  VARCHAR2,
  P_FROM_DATE_CLAUSE	    	IN VARCHAR2,
  P_SELECTED_METER	      	IN NUMBER,
  P_INCLUDE_CHILDREN	    	IN VARCHAR2,
  P_VIEW_BY	              	IN VARCHAR2,
  P_COMPUTE_REPAIR_COSTS	IN VARCHAR2,
  P_CURRENT_ORG_ID        	IN VARCHAR2,
  X_GROUP_ID 	            	OUT NOCOPY  NUMBER,
  x_return_status         	OUT NOCOPY  VARCHAR2,
  x_msg_count             	OUT NOCOPY  NUMBER,
  x_msg_data              	OUT NOCOPY  VARCHAR2,
  x_unmatched_uom_class 	OUT NOCOPY  VARCHAR2,
  x_unmatched_currency  	OUT NOCOPY  VARCHAR2);


Procedure GET_FAILURE_METER_RECS_CURSOR
( P_WHERE_CLAUSE		IN  VARCHAR2,
  P_SELECTED_METER	  	IN  NUMBER,
  P_FROM_DATE_CLAUSE  		IN  VARCHAR2,
  P_VIEW_BY                     IN  NUMBER,
  X_REF_FAILURES      		OUT NOCOPY SYS_REFCURSOR);

Procedure GET_FAILURE_RECS_CURSOR
( P_WHERE_CLAUSE	    	IN  VARCHAR2,
  P_FROM_DATE_CLAUSE  		IN  VARCHAR2,
  P_VIEW_BY                     IN  NUMBER,
  X_REF_FAILURES      		OUT NOCOPY SYS_REFCURSOR);

Procedure GET_HISTORY_RECORDS_SIMPLE
( P_GEN_OBJECT_ID   		IN NUMBER,
  P_FROM_DATE	      		IN DATE,
  P_TO_DATE         		IN DATE,
  P_SELECTED_METER		IN NUMBER,
  P_CURRENT_ORG_ID  		IN NUMBER,
  X_GROUP_ID 	      		OUT NOCOPY  NUMBER,
  x_return_status   		OUT NOCOPY  VARCHAR2,
  x_msg_count       		OUT NOCOPY  NUMBER,
  x_msg_data        		OUT NOCOPY  VARCHAR2,
  x_unmatched_uom_class 	OUT NOCOPY  VARCHAR2,
  x_unmatched_currency  	OUT NOCOPY  VARCHAR2);


Procedure GET_HISTORY_RECORDS_FA_SIMPLE
( P_GEN_OBJECT_ID         	IN  NUMBER,
  P_MAINT_GROUP_ID        	IN  NUMBER,
  P_CATEGORY_ID           	IN  NUMBER,
  P_FAILURE_CODE          	IN  VARCHAR2,
  P_FROM_DATE	            	IN  DATE,
  P_TO_DATE               	IN  DATE,
  P_INCLUDE_CHILDREN	    	IN  VARCHAR2,
  P_VIEW_BY	              	IN  VARCHAR2,
  P_COMPUTE_REPAIR_COSTS	IN  VARCHAR2,
  P_SELECTED_METER        	IN  NUMBER,
  P_CURRENT_ORG_ID        	IN  NUMBER,
  X_GROUP_ID 	            	OUT NOCOPY  NUMBER,
  x_return_status       	OUT NOCOPY  VARCHAR2,
  x_msg_count           	OUT NOCOPY  NUMBER,
  x_msg_data            	OUT NOCOPY  VARCHAR2,
  x_unmatched_uom_class 	OUT NOCOPY  VARCHAR2,
  x_unmatched_currency  	OUT NOCOPY  VARCHAR2);


Procedure INSERT_INTO_TEMP_TABLE
( p_group_id            	IN NUMBER,
  P_ASSET_FAILURE_TBL	  	IN eam_asset_failure_tbl_type);

Procedure COMPUTE_REPAIR_COSTS
( P_GROUP_ID	     		IN NUMBER);

PROCEDURE VALIDATE_RECORDS
( P_ASSET_FAILURE_TBL 		IN OUT NOCOPY EAM_ASSET_FAILURE_TBL_TYPE,
  P_VALIDATE_METERS   		IN VARCHAR2,
  P_VALIDATE_CURRENCY 		IN VARCHAR2,
  P_CURRENT_ORG_ID    		IN NUMBER,
  x_unmatched_uom_class  	OUT NOCOPY VARCHAR2,
  x_unmatched_currency   	OUT NOCOPY VARCHAR2);

/* Following procedures added for Include Children functionality :Failure Analysis Page*/
  Procedure GET_CHILD_RECORDS_FA_SIMPLE
( P_GEN_OBJECT_ID         IN  NUMBER,
  P_MAINT_GROUP_ID        IN  NUMBER,
  P_CATEGORY_ID           IN  NUMBER,
  P_FAILURE_CODE          IN  VARCHAR2,
  P_FROM_DATE	          IN  DATE,
  P_TO_DATE               IN  DATE,
  P_VIEW_BY	          IN  VARCHAR2,
  P_COMPUTE_REPAIR_COSTS  IN  VARCHAR2,
  P_CURRENT_ORG_ID        IN  NUMBER,
  x_group_id 	            IN OUT NOCOPY NUMBER,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_data              OUT NOCOPY  VARCHAR2,
  x_unmatched_uom_class   OUT NOCOPY  VARCHAR2,
  x_unmatched_currency    OUT NOCOPY  VARCHAR2);

Procedure GET_CHILD_RECORDS_FA_ADV
( P_WHERE_CLAUSE                IN VARCHAR2,
  P_WHERE_CLAUSE_1		IN VARCHAR2,
  P_FROM_DATE_CLAUSE            IN VARCHAR2,
  P_VIEW_BY                     IN VARCHAR2,
  P_COMPUTE_REPAIR_COSTS        IN VARCHAR2,
  P_CURRENT_ORG_ID              IN NUMBER,
  x_group_id                    IN  OUT NOCOPY NUMBER,
  x_return_status               OUT NOCOPY  VARCHAR2,
  x_msg_data                    OUT NOCOPY  VARCHAR2,
  x_unmatched_uom_class         OUT NOCOPY  VARCHAR2,
  x_unmatched_currency          OUT NOCOPY  VARCHAR2);

PROCEDURE GET_CHILD_RECS_CURSOR
    ( p_where_clause      IN VARCHAR2,
      p_where_clause_1    IN VARCHAR2,
      p_from_date_clause  IN VARCHAR2,
      p_view_by           IN VARCHAR2,
      P_ORG_ID			IN  VARCHAR2,
      x_ref_failures      OUT NOCOPY SYS_REFCURSOR);

PROCEDURE GET_CHILD_METER_RECS_CURSOR
( P_WHERE_CLAUSE                IN  VARCHAR2,
  P_WHERE_CLAUSE_1		IN  VARCHAR2,
  P_FROM_DATE_CLAUSE            IN  VARCHAR2,
  P_VIEW_BY                     IN  VARCHAR2,
  P_ORG_ID			IN  VARCHAR2,
  X_REF_FAILURES                OUT NOCOPY SYS_REFCURSOR);


END EAM_FAILURE_ANALYSIS_PVT;


 

/
