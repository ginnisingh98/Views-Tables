--------------------------------------------------------
--  DDL for Package EAM_OBJECTINSTANTIATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_OBJECTINSTANTIATION_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPMOIS.pls 115.7 2002/12/14 00:27:08 chrng noship $ */

TYPE Association_Id_Tbl_Type IS
	TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- Log file variables
g_log_file		UTL_FILE.FILE_TYPE;
g_is_logged		NUMBER := NVL(FND_PROFILE.VALUE('EAM_MOI_IS_LOGGED'), EAM_API_Log_PVT.g_NO);
g_log_file_dir		VARCHAR2(2000) := FND_PROFILE.VALUE('EAM_MOI_LOG_FILE_DIR');
g_log_file_name		VARCHAR2(2000) := FND_PROFILE.VALUE('EAM_MOI_LOG_FILE_NAME');

-- Start of comments
--	API name 	: Instantiate_Object
--	Type		: Public
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				p_init_msg_list			IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    		IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level		IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_maintenance_object_id		IN	NUMBER
--				p_maintenance_object_type	IN	NUMBER

--	OUT		:	x_return_status			OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)

--	Version	:
--			  Initial version 	1.0
--
--	Notes		: This API is to be called after the creation of a
--			maintenance object (item, asset number, etc.).
--			Then it will in turn call the private packages for the
--			Activity Instantiation and PM Instantiation.
--
-- End of comments

PROCEDURE Instantiate_Object
( 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	-- returns if Instantiation is successful
	x_return_status			OUT NOCOPY	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY	NUMBER				,
	x_msg_data			OUT NOCOPY	VARCHAR2			,

	-- input: maintenance object (id and type)
	p_maintenance_object_id		IN	NUMBER, -- for Maintenance Object Type of 1, this should be Gen_Object_Id
	p_maintenance_object_type	IN	NUMBER -- only supports Type 1 (Serial Numbers) for now
);



-- This is a wrapper for Instantiate_Object.
-- It takes current_organization_id, inventory_item_id, serial_number
-- and looks up the Gen_Object_Id before calling Instantiate_Object.

PROCEDURE Instantiate_Serial_Number
( 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	-- returns if Instantiation is successful
	x_return_status			OUT NOCOPY	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY	NUMBER				,
	x_msg_data			OUT NOCOPY	VARCHAR2			,

	-- inputs: specify a Serial Number
	p_current_organization_id	IN	NUMBER,
	p_inventory_item_id		IN	NUMBER,
	p_serial_number			IN	VARCHAR2
);

END EAM_ObjectInstantiation_PUB;


 

/
