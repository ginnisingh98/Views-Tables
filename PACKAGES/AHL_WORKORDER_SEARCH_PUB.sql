--------------------------------------------------------
--  DDL for Package AHL_WORKORDER_SEARCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_WORKORDER_SEARCH_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPWSOS.pls 120.0.12010000.1 2008/11/30 21:14:08 sikumar noship $ */

	G_PKG_NAME 	CONSTANT 	VARCHAR2(28) 	:= 'AHL_WORKORDER_SEARCH_PUB';

  -- Definition of search criteria for searching workorders for a user role
  TYPE WORKORDERS_SEARCH_REC_TYPE IS RECORD
	(
			WORKORDER_NUMBER											VARCHAR2(80),
			DESCRIPTION														VARCHAR2(240),
			STATUS_CODE														VARCHAR2(30),
			STATUS																VARCHAR2(80),
			VISIT_NUMBER													NUMBER,
			SCHEDULED_START_DATE									DATE,
			SCHEDULED_END_DATE										DATE,
			START_ROW_INDEX												NUMBER,
			NUMBER_OF_ROWS												NUMBER,
			SEARCH_TABLE_INDEX										NUMBER,
			ACCOUNTING_CLASS											VARCHAR2(10),
			DEPARTMENT_CLASS_CODE									VARCHAR2(10),
			VISIT_TASK_NUMBER											NUMBER,
			PROJECT																VARCHAR2(30),
			PROJECT_TASK													VARCHAR2(20),
			MAINTENANCE_REQUIREMENT_TITLE					VARCHAR2(80),
			ITEM																	VARCHAR2(30),
			ORGANIZATION													VARCHAR2(240),
			DEPARTMENT														VARCHAR2(240),
			UNIT_NAME															VARCHAR2(4000),
			EMPLOYEE															VARCHAR2(240),
			NON_ROUTINE_NUMBER										VARCHAR2(80),
			OPERATION_CODE												VARCHAR2(30),
			OPERATION_DESCRIPTION									VARCHAR2(500),
			PRIORITY															VARCHAR2(80),
			CONFIRMED_FAILURE_FLAG								VARCHAR2(1),
			BOM_RESOURCE													VARCHAR2(10),
			WORKORDER_TYPE												VARCHAR2(80)
	);

	-- Definition of WORK_ORDER_REC_TYPE
	TYPE WORK_ORDER_REC_TYPE IS RECORD
	(
			WORKORDER_ID													NUMBER,
			OBJECT_VERSION_NUMBER									NUMBER,
			WORKORDER_NUMBER											VARCHAR2(80),
			DESCRIPTION														VARCHAR2(240),
			STATUS_CODE														VARCHAR2(30),
			STATUS																VARCHAR2(80),
			VISIT_NUMBER													NUMBER,
			UNIT_NAME															VARCHAR2(4000),
			MODEL																	VARCHAR2(30),
			ATA_CODE															VARCHAR2(30),
			ENIGMA_DOCUMENT_ID										VARCHAR2(80),
			ASSIGNED_START_DATE										DATE,
  		IS_COMPLETE_ENABLED										VARCHAR2(1),
			IS_UPDATE_ENABLED											VARCHAR2(1),
			IS_RES_TXN_ENABLED										VARCHAR2(1)
	);

	-- Definition of search results record structure WORK_ORDERS_SEARCH_RESULT_TBL_TYPE
	TYPE WORK_ORDERS_RESULT_TBL_TYPE IS TABLE OF WORK_ORDER_REC_TYPE
        index by Binary_Integer;

	-- Definition of ASSIGNED_WORK_ORDERS_TYPE
	TYPE WORK_ORDERS_TYPE IS RECORD
	(
			START_ROW_INDEX												NUMBER,
			NUMBER_OF_ROWS												NUMBER,
			WORK_ORDERS													WORK_ORDERS_RESULT_TBL_TYPE
	);





------------------------
-- Declare Procedure --
------------------------
-- Start of Comments --
--  Procedure name    : get_assgnd_wo_search_results
--  Function          : Will return the Assigned and User qualified Work Order SEarch Results for an Input Search Criteria
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--
--
--  get_assgnd_wo_search_results Parameters:
--
--			workorders_search_rec								IN OUT			WORKORDERS_SEARCH_REC_TYPE
--			assigned_work_orders_tbl						OUT NOCOPY	WORK_ORDERS_SEARCH_RESULT_TBL_TYPE
--			user_qlfd_work_orders_tbl						OUT NOCOPY	WORK_ORDERS_SEARCH_RESULT_TBL_TYPE
--  		service_return_status_rec					  OUT NOCOPY	SERVICE_RETURN_STATUS_REC_TYPE
--
--
--  Version :
--                Initial Version   1.0
--
--  End of Comments.
------------------------

	PROCEDURE get_wo_search_results(
				p_api_version											  IN					NUMBER,
				p_init_msg_list										  IN				  VARCHAR2 := FND_API.G_TRUE,
				p_commit													  IN				  VARCHAR2 := FND_API.G_FALSE,
				p_validation_level									IN				  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
				p_module_type												IN				  VARCHAR2,
				p_userid                                                                                IN VARCHAR2 := NULL,
				x_return_status											OUT NOCOPY	VARCHAR2,
				x_msg_count													OUT NOCOPY	NUMBER,
				x_msg_data													OUT NOCOPY	VARCHAR2,
				p_workorders_search_rec							    IN 			WORKORDERS_SEARCH_REC_TYPE,
				x_work_order_results								    OUT NOCOPY	WORK_ORDERS_TYPE
																			  );


END AHL_WORKORDER_SEARCH_PUB;

/
