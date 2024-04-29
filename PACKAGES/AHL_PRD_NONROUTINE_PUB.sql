--------------------------------------------------------
--  DDL for Package AHL_PRD_NONROUTINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_NONROUTINE_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPPNRS.pls 120.0.12010000.1 2008/11/30 21:07:48 sikumar noship $ */

	G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_CREATE_NON_ROUTINE_SERVICE';

	-- Definition of material_requirement_rec_type
   TYPE  MATERIAL_REQUIREMENT_REC_TYPE IS RECORD
   (
      INVENTORY_ITEM_ID                 NUMBER,
      ITEM_NUMBER                       VARCHAR2(40),
      ITEM_DESCRIPTION                  VARCHAR2(240),
      REQUIRED_QUANTITY                 NUMBER,
      PART_UOM                          VARCHAR2(30),
      REQUIRED_DATE                     DATE
   );
	-- Definition of material_requirements_type
   TYPE MATERIAL_REQUIREMENTS_TBL IS TABLE OF MATERIAL_REQUIREMENT_REC_TYPE  INDEX BY BINARY_INTEGER;

   -- Definition of Non Routine Record type
   TYPE NON_ROUTINE_REC_TYPE IS RECORD
   (
      SERVICE_REQUEST_ID            NUMBER,
      OBJECT_VERSION_NUMBER         NUMBER,
      WORKORDER_ID                  NUMBER,
      WORKORDER_NUMBER              VARCHAR2(80),
      VISIT_ID                      NUMBER,
      VISIT_NUMBER                  NUMBER,
      RELEASE_NON_ROUTINE_WORKORDER VARCHAR2(1),
      ORIGINATOR_WORKORDER_ID       NUMBER,
      ORIGINATOR_WORKORDER_NUMBER   VARCHAR2(80),
      ORIGINATOR_VISIT_ID           NUMBER,
      ORIGINATOR_VISIT_NUMBER       NUMBER,
      ORIGINATOR_TASK               NUMBER,
      SERVICE_REQUEST_TYPE          VARCHAR2(30),
      SERVICE_REQUEST_TYPE_CODE     VARCHAR2(30),
      SUMMARY                       VARCHAR2(240),
      PROBLEM_CODE                  VARCHAR2(50),
      PROBLEM_CODE_MEANING          VARCHAR2(80),
      RESOLUTION_CODE               VARCHAR2(50),
      RESOLUTION_CODE_MEANING       VARCHAR2(240),
      ESTIMATED_DURATION            NUMBER,
      ESTIMATED_DURATION_UOM        VARCHAR2(30),
      REPORT_BY_TYPE                VARCHAR2(80),
      REPORT_TYPE_CODE              VARCHAR2(30),
      REPORT_TYPE                   VARCHAR2(80),
      CONTACT_TYPE_CODE             VARCHAR2(50),
      CONTACT_TYPE                  VARCHAR2(30),
      CONTACT_ID                    NUMBER,
      CONTACT_NAME                  VARCHAR2(360),
      PARTY_ID                      NUMBER,
      PARTY_NAME                    VARCHAR2(360),
      SERVICE_REQUEST_DATE          DATE,
      SERVICE_REQUEST_STATUS_CODE   VARCHAR2(30),
      SERVICE_REQUEST_STATUS        VARCHAR2(80),
      SEVERITY_ID                   NUMBER,
      SEVERITY_NAME                 VARCHAR2(30),
      URGENCY_ID                    NUMBER,
      URGENCY_NAME                  VARCHAR2(30),
      ATA_CODE                      VARCHAR2(30),
      POSITION                      VARCHAR2(30),
      POSITION_ID                   NUMBER,
      UNIT_NAME                     VARCHAR2(80),
      ITEM_NUMBER                   VARCHAR2(40),
      SERIAL_NUMBER                 VARCHAR2(30),
      INSTANCE_NUMBER               NUMBER,
      LOT_NUMBER                    VARCHAR2(80)
   );

	-------------------------------------------------------------------------------------------------
	-- Declare Procedures --
	-------------------------------------------------------------------------------------------------
	-- Start of Comments --
	--  Procedure name		: CREATE_NON_ROUTINE
	--  Type						: Public
	--  Function				: Creates a Non routine and adds material requirements for the NR
	--  Pre-reqs				:
	--  Standard IN  Parameters :
	--      p_api_version		IN			NUMBER        	Required
	--      p_init_msg_list		IN			VARCHAR2			Default FND_API.G_FALSE
	--      p_commit				IN			VARCHAR2     	Default FND_API.G_FALSE
	--      p_validation_level	IN			NUMBER       	Default FND_API.G_VALID_LEVEL_FULL
	--		  p_module_type		IN			VARCHAR2			Default NULL
	--  Standard OUT Parameters :
	--      x_return_status		OUT		VARCHAR2			Required
	--      x_msg_count			OUT		NUMBER			Required
	--      x_msg_data			OUT		VARCHAR2			Required
	--
	--  CREATE_NON_ROUTINE Parameters:
	--			p_create_non_routine_input_rec   : Parameters needed for the creation of the NR
   --       p_matrl_reqrs_for_nr_tbl         : Material requirements for the NR
	--			x_create_non_routine_output_rec	: Parameters returned after the creation of the NR
	--  End of Comments.
PROCEDURE CREATE_NON_ROUTINE
   (
  		p_api_version				         IN 					NUMBER		:= 1.0,
		p_init_msg_list       	         IN 					VARCHAR2		:= FND_API.G_FALSE,
		p_commit              	         IN 					VARCHAR2 	:= FND_API.G_FALSE,
		p_validation_level    	         IN 					NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
		p_module_type				         IN						VARCHAR2,
		p_user_id                        IN              VARCHAR2:=NULL,
      p_create_nr_input_rec            IN                NON_ROUTINE_REC_TYPE,
      p_matrl_reqrs_for_nr_tbl         IN                MATERIAL_REQUIREMENTS_TBL,
      x_create_nr_output_rec           OUT      NOCOPY   NON_ROUTINE_REC_TYPE,
		x_return_status       	         OUT 		NOCOPY	VARCHAR2,
		x_msg_count           	         OUT 		NOCOPY	NUMBER,
		x_msg_data            	         OUT 		NOCOPY	VARCHAR2
   );


END AHL_PRD_NONROUTINE_PUB;

/
