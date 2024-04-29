--------------------------------------------------------
--  DDL for Package AHL_RSV_RESERVATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_RSV_RESERVATIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVRSVS.pls 120.3.12010000.2 2008/11/13 14:27:12 skpathak ship $ */

	G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_RSV_RESERVATIONS_PVT';

	-- Definition of serial number table type
	/**** {{ R12 Enhanced reservations code changes }}****/
	TYPE serial_number_rec_type IS RECORD
	(
		inventory_item_id NUMBER
		,serial_number VARCHAR2(30)
   );

	TYPE serial_number_tbl_type IS TABLE OF serial_number_rec_type
		INDEX BY BINARY_INTEGER;

	---------------------------------------------------------------------------------------------------------
	-- Declare Procedures --
	---------------------------------------------------------------------------------------------------------
	-- Start of Comments --
	--  Procedure name		: CREATE_RESERVATION
	--  Type						: Private
	--  Function				: Reserves the serial numbers in the p_serial_number_tbl
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
	--  CREATE_RESERVATION Parameters:
	--			p_scheduled_material_id : The Schedule Material Id
	--			p_serial_number_tbl		: The table of Serial Numbers to be reserved
	--  End of Comments.
	---------------------------------------------------------------------------------------------------------
	PROCEDURE CREATE_RESERVATION(
		p_api_version				IN 					NUMBER		:= 1.0,
		p_init_msg_list       	IN 					VARCHAR2		:= FND_API.G_FALSE,
		p_commit              	IN 					VARCHAR2 	:= FND_API.G_FALSE,
		p_validation_level    	IN 					NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
		p_module_type				IN						VARCHAR2,
		x_return_status       	OUT 		NOCOPY	VARCHAR2,
		x_msg_count           	OUT 		NOCOPY	NUMBER,
		x_msg_data            	OUT 		NOCOPY	VARCHAR2,
		p_scheduled_material_id	IN						NUMBER  ,
		p_serial_number_tbl		IN						serial_number_tbl_type);


	---------------------------------------------------------------------------------------------------------
	-- Declare Procedures --
	---------------------------------------------------------------------------------------------------------
	-- Start of Comments --
	--  Procedure name		: UPDATE_RESERVATION
	--  Type						: Private
	--  Function				: Updates reservation for serial numbers in the p_serial_number_tbl
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
	--  UPDATE_RESERVATION Parameters:
	--			p_scheduled_material_id : The Schedule Material Id
	--			p_requested_date			: The new date for which the reservations need to chaned
	--  End of Comments.
	---------------------------------------------------------------------------------------------------------
	PROCEDURE UPDATE_RESERVATION(
		p_api_version				IN 					NUMBER		:= 1.0,
		p_init_msg_list       	IN 					VARCHAR2		:= FND_API.G_FALSE,
		p_commit              	IN 					VARCHAR2 	:= FND_API.G_FALSE,
		p_validation_level    	IN 					NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
		p_module_type				IN						VARCHAR2,
		x_return_status       	OUT 		NOCOPY	VARCHAR2,
		x_msg_count           	OUT 		NOCOPY	NUMBER,
		x_msg_data            	OUT 		NOCOPY	VARCHAR2,
		p_scheduled_material_id	IN						NUMBER  ,
		p_requested_date			IN						DATE);


	---------------------------------------------------------------------------------------------------------
	-- Declare Procedures --
	---------------------------------------------------------------------------------------------------------
	-- Start of Comments --
	--  Procedure name		: DELETE_RESERVATION
	--  Type						: Private
	--  Function				: API to delete all the reservation made for a requirement
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
	--  DELETE_RESERVATION Parameters:
	--			p_scheduled_material_id : The Schedule Material Id
	--			p_sub_inventory_code		: If not null then only reservations from this subinventory will be deleted, if null all 											  the reservations will be deleted.
	--			p_serial_number		: If not null, then only the reservation (may have other serials also) with this serial number will be deleted.
	--  End of Comments.
	---------------------------------------------------------------------------------------------------------
	PROCEDURE DELETE_RESERVATION(
		p_api_version				IN 					NUMBER		:= 1.0,
		p_init_msg_list       	IN 					VARCHAR2		:= FND_API.G_FALSE,
		p_commit              	IN 					VARCHAR2 	:= FND_API.G_FALSE,
		p_validation_level    	IN 					NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
		p_module_type				IN						VARCHAR2,
		x_return_status       	OUT 		NOCOPY	VARCHAR2,
		x_msg_count           	OUT 		NOCOPY	NUMBER,
		x_msg_data            	OUT 		NOCOPY	VARCHAR2,
		p_scheduled_material_id	IN						NUMBER  ,
		p_sub_inventory_code    IN           VARCHAR2 := NULL,
		p_serial_number         IN           VARCHAR2 := NULL);
	---------------------------------------------------------------------------------------------------------
	-- Declare Procedures --
	---------------------------------------------------------------------------------------------------------
	-- Start of Comments --
	--  Procedure name		: RELIEVE_RESERVATION
	--  Type						: Private
	--  Function				: API to delete the reservation made for a particular serial number
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
	--  RELIEVE_RESERVATION Parameters:
	--			p_scheduled_material_id : The Schedule Material Id
	--			p_serial_number			: The Serial number whose reservation has to be deleted
	--  End of Comments.
	---------------------------------------------------------------------------------------------------------
	PROCEDURE RELIEVE_RESERVATION(
		p_api_version				IN 					NUMBER		:= 1.0,
		p_init_msg_list       	IN 					VARCHAR2		:= FND_API.G_FALSE,
		p_commit              	IN 					VARCHAR2 	:= FND_API.G_FALSE,
		p_validation_level    	IN 					NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
		p_module_type				IN						VARCHAR2,
		x_return_status       	OUT 		NOCOPY	VARCHAR2,
		x_msg_count           	OUT 		NOCOPY	NUMBER,
		x_msg_data            	OUT 		NOCOPY	VARCHAR2,
		p_scheduled_material_id	IN						NUMBER  ,
		p_serial_number			IN						VARCHAR2);



	---------------------------------------------------------------------------------------------------------
	-- Declare Procedures --
	---------------------------------------------------------------------------------------------------------
	-- Start of Comments --
	--  Procedure name		: TRANSFER_RESERVATION
	--  Type						: Private
	--  Function				: API to delete the reservation made for a particular serial number
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
	--  TRANSFER_RESERVATION Parameters:
	--			p_visit_id					: The id of the visit for which the reservations need to be transferred.
	--  End of Comments.
	---------------------------------------------------------------------------------------------------------
	PROCEDURE TRANSFER_RESERVATION(
		p_api_version				IN 					NUMBER		:= 1.0,
		p_init_msg_list       	IN 					VARCHAR2		:= FND_API.G_FALSE,
		p_commit              	IN 					VARCHAR2 	:= FND_API.G_FALSE,
		p_validation_level    	IN 					NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
		p_module_type				IN						VARCHAR2,
		x_return_status       	OUT 		NOCOPY	VARCHAR2,
		x_msg_count           	OUT 		NOCOPY	NUMBER,
		x_msg_data            	OUT 		NOCOPY	VARCHAR2,
		p_visit_id					IN						NUMBER);



	---------------------------------------------------------------------------------------------------------
	-- Declare Procedures --
	---------------------------------------------------------------------------------------------------------
	-- Start of Comments --
	--  Procedure name		: UPDATE_VISIT_RESERVATIONS
	--  Type						: Private
	--  Function				: API to update all the reservations for s particular visit
	--  Pre-reqs				:
	--  Standard IN  Parameters :
	--  Standard OUT Parameters :
	--      x_return_status		OUT		VARCHAR2			Required
	--
	--  UPDATE_VISIT_RESERVATIONS Parameters:
	--			p_visit_id					: The visit id for which the reservations need to be transferred.
	--  End of Comments.
   ---------------------------------------------------------------------------------------------------------
	PROCEDURE UPDATE_VISIT_RESERVATIONS(
		x_return_status       	OUT 		NOCOPY	VARCHAR2,
		p_visit_id					IN						NUMBER);


	---------------------------------------------------------------------------------------------------------
	-- Declare Procedures --
	---------------------------------------------------------------------------------------------------------
	-- Start of Comments --
	--  Procedure name		: DELETE_VISIT_RESERVATIONS
	--  Type						: Private
	--  Function				: API to delete all the reservations for s particular visit
	--  Pre-reqs				:
	--  Standard IN  Parameters :
	--  Standard OUT Parameters :
	--      x_return_status		OUT		VARCHAR2			Required
	--
	--  DELETE_VISIT_RESERVATIONS Parameters:
	--			p_visit_id					: The visit id for which the reservations need to be deleted
	--  End of Comments.
 	---------------------------------------------------------------------------------------------------------
	PROCEDURE DELETE_VISIT_RESERVATIONS(
		x_return_status       	OUT 		NOCOPY	VARCHAR2,
		p_visit_id					IN						NUMBER);


	---------------------------------------------------------------------------------------------------------
	-- Declare Procedures --
	---------------------------------------------------------------------------------------------------------
	-- Start of Comments --
	--  Procedure name		: TRANSFER_RESERVATION_MATRL_REQR
	--  Type						: Private
	--  Function				: API to transfer reservations for a particular material requirement
	--  Pre-reqs				:
	--  Standard IN  Parameters :
	--  Standard OUT Parameters :
	--      x_return_status		OUT		VARCHAR2			Required
	--      x_msg_count
   --      x_msg_data
	--  DELETE_VISIT_RESERVATIONS Parameters:
	--			p_visit_task_id					: The task id for which the reservations need to be transferred
   --       p_from_mat_req_id             : The scheduled material id of the from record
   --       p_to_mat_req_id               : The scheduled material id of the to record
	--  End of Comments.
   ---------------------------------------------------------------------------------------------------------
   PROCEDURE   TRNSFR_RSRV_FOR_MATRL_REQR(
		p_api_version				IN 					NUMBER		:= 1.0,
		p_init_msg_list       	IN 					VARCHAR2		:= FND_API.G_FALSE,
		p_commit              	IN 					VARCHAR2 	:= FND_API.G_FALSE,
		p_validation_level    	IN 					NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
		p_module_type				IN						VARCHAR2,
		x_return_status       	OUT 		NOCOPY	VARCHAR2,
		x_msg_count           	OUT 		NOCOPY	NUMBER,
		x_msg_data            	OUT 		NOCOPY	VARCHAR2,
      p_visit_task_id         IN                NUMBER,
      p_from_mat_req_id       IN                NUMBER,
      p_to_mat_req_id         IN                NUMBER
      );

END AHL_RSV_RESERVATIONS_PVT;

/
