--------------------------------------------------------
--  DDL for Package EC_CODE_CONVERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_CODE_CONVERSION_PVT" AUTHID CURRENT_USER AS
-- $Header: ECVXREFS.pls 120.3 2005/09/30 07:10:37 arsriniv ship $
/*#
 * This package contains routines to perform code conversion between internal and external codes
 * @rep:scope internal
 * @rep:product EC
 * @rep:lifecycle active
 * @rep:displayname Code Conversion
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY EC_CODE_CONVERSION
 */

--  Global constants holding the package and file names to be used by
--  messaging routines in the case of an unexpected error.

G_PKG_NAME	CONSTANT VARCHAR2(30) := 'EC_Code_Conversion_PVT';
G_FILE_NAME	CONSTANT VARCHAR2(12) := 'ECVXREFB.pls';

G_XREF_NOT_FOUND	CONSTANT VARCHAR2(1) := 'X';

-- Start of Comments
--	API name 	: Convert_from_int_to_ext
--	Type		: Private.
--	Function	: Perform value lookup to convert internal value
--			  to external value(s)
--	Pre-reqs	: None.
--	Paramaeters	:
--	IN		:	p_api_version_number	IN NUMBER		Required
--				p_init_msg_list		IN VARCHAR2 		Optional
--					Default = FND_API.G_FALSE
--				p_simulate		IN VARCHAR2		Optional
--					Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2		Optional
--					Default = FND_API.G_FALSE
--				p_validation_level	IN NUMBER		Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_Category     		IN VARCHAR2		Required
--				p_Key1			IN VARCHAR2		Optional
--					Default = NULL
--				p_Key2			IN VARCHAR2		Optional
--					Default = NULL
--				p_Key3			IN VARCHAR2		Optional
--					Default = NULL
--				p_Key4			IN VARCHAR2		Optional
--					Default = NULL
--				p_Key5			IN VARCHAR2		Optional
--					Default = NULL
--				p_Int_val		IN VARCHAR2		Required

--
--	OUT		:	p_return_status		OUT VARCHAR2(1)
--				p_msg_count		OUT NUMBER
--				p_msg_data		OUT VARCHAR2(2000)
--				p_Ext_val1		OUT VARCHAR2
--				p_Ext_val2		OUT VARCHAR2
--				p_Ext_val3		OUT VARCHAR2
--				p_Ext_val4		OUT VARCHAR2
--				p_Ext_val5		OUT VARCHAR2
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Note text
--
--
--	API name 	: Convert_from_ext_to_int
--	Type		: Private.
--	Function	: Perform value lookup to convert external value(s)
--			  to internal value
--	Pre-reqs	: None.
--	Paramaeters	:
--	IN		:	p_api_version_number	IN NUMBER		Required
--				p_init_msg_list		IN VARCHAR2 		Optional
--					Default = FND_API.G_FALSE
--				p_simulate		IN VARCHAR2		Optional
--					Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2		Optional
--					Default = FND_API.G_FALSE
--				p_validation_level	IN NUMBER		Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_Category     		IN VARCHAR2		Required
--				p_Key1			IN VARCHAR2		Optional
--					Default = NULL
--				p_Key2			IN VARCHAR2		Optional
--					Default = NULL
--				p_Key3			IN VARCHAR2		Optional
--					Default = NULL
--				p_Key4			IN VARCHAR2		Optional
--					Default = NULL
--				p_Key5			IN VARCHAR2		Optional
--					Default = NULL
--				p_Ext_val1		IN VARCHAR2		Required
--				p_Ext_val2		IN VARCHAR2		Optional
--					Default = NULL
--				p_Ext_val3		IN VARCHAR2		Optional
--					Default = NULL
--				p_Ext_val4		IN VARCHAR2		Optional
--					Default = NULL
--				p_Ext_val5		IN VARCHAR2		Optional
--					Default = NULL
--
--	OUT		:	p_return_status		OUT VARCHAR2(1)
--				p_msg_count		OUT NUMBER
--				p_msg_data		OUT VARCHAR2(2000)
--				p_Int_val		OUT VARCHAR2
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Note text
--
--
-- End Of Comments

/*#
 * Used  to convert internal value to external values
 * @param p_api_version_number API Version Number
 * @param p_init_msg_list  Initialize Message List?
 * @param p_simulate      Simulate
 * @param p_commit        Commit
 * @param p_validation_level  Validation Level
 * @param p_return_status Return Status
 * @param p_msg_count  Message Count
 * @param p_msg_data   Message Data
 * @param p_Category Code Category Name
 * @param p_Key1 Value of Key Column 1
 * @param p_Key2 Value of Key Column 2
 * @param p_Key3 Value of Key Column 3
 * @param p_Key4 Value of Key Column 4
 * @param p_Key5 value of Key Column 5
 * @param p_Int_val Internal Value
 * @param p_Ext_val1 External Value 1
 * @param p_Ext_val2 External Value 2
 * @param p_Ext_val3 External Value 3
 * @param p_Ext_val4 External Value 4
 * @param p_Ext_val5 External Value 5
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Internal to External Code Conversion
 * @rep:compatibility S
 */

PROCEDURE Convert_from_int_to_ext
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_Category     		IN	VARCHAR2,
   p_Key1			IN	VARCHAR2 := NULL,
   p_Key2			IN	VARCHAR2 := NULL,
   p_Key3			IN	VARCHAR2 := NULL,
   p_Key4			IN	VARCHAR2 := NULL,
   p_Key5			IN	VARCHAR2 := NULL,
   p_Int_val			IN	VARCHAR2,
   p_Ext_val1			OUT NOCOPY	VARCHAR2,
   p_Ext_val2			OUT NOCOPY	VARCHAR2,
   p_Ext_val3			OUT NOCOPY	VARCHAR2,
   p_Ext_val4			OUT NOCOPY	VARCHAR2,
   p_Ext_val5			OUT NOCOPY	VARCHAR2
);

/*#
 * Used  to convert external values to internal value
 * @param p_api_version_number API version number
 * @param p_init_msg_list  Initialize Message List?
 * @param p_simulate       Simulate
 * @param p_commit         Commit
 * @param p_validation_level Validation Level
 * @param p_return_status Return Status
 * @param p_msg_count     Message Count
 * @param p_msg_data      Message Data
 * @param p_Category Code Category Name
 * @param p_Key1 Value of Key Column 1
 * @param p_Key2 Value of Key Column 2
 * @param p_Key3 Value of Key Column 3
 * @param p_Key4 Value of Key Column 4
 * @param p_Key5 value of Key Column 5
 * @param p_Ext_val1 External Value 1
 * @param p_Ext_val2 External Value 2
 * @param p_Ext_val3 External Value 3
 * @param p_Ext_val4 External Value 4
 * @param p_Ext_val5 External Value 5
 * @param p_Int_val Internal Value
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname External to Internal Code Conversion
 * @rep:compatibility S
 */

PROCEDURE Convert_from_ext_to_int
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_Category     		IN	VARCHAR2,
   p_Key1			IN	VARCHAR2 := NULL,
   p_Key2			IN	VARCHAR2 := NULL,
   p_Key3			IN	VARCHAR2 := NULL,
   p_Key4			IN	VARCHAR2 := NULL,
   p_Key5			IN	VARCHAR2 := NULL,
   p_Ext_val1			IN	VARCHAR2,
   p_Ext_val2			IN	VARCHAR2 := NULL,
   p_Ext_val3			IN	VARCHAR2 := NULL,
   p_Ext_val4			IN	VARCHAR2 := NULL,
   p_Ext_val5			IN	VARCHAR2 := NULL,
   p_Int_val			OUT NOCOPY	VARCHAR2
);

PROCEDURE populate_plsql_tbl_with_extval(
	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_simulate		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN			VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN			NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	p_return_status		OUT NOCOPY		VARCHAR2,
	p_msg_count		OUT NOCOPY		NUMBER,
	p_msg_data		OUT NOCOPY		VARCHAR2,
	p_key_tbl		IN			ece_flatfile_pvt.Interface_tbl_type,
	p_tbl			IN OUT NOCOPY  ece_flatfile_pvt.Interface_tbl_type);

PROCEDURE populate_plsql_tbl_with_extval(
	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_simulate		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	p_return_status		OUT NOCOPY	VARCHAR2,
	p_msg_count		OUT NOCOPY	NUMBER,
	p_msg_data		OUT NOCOPY	VARCHAR2,
	p_tbl			IN OUT	NOCOPY		ec_utils.mapping_tbl,
	p_level			IN			number
	);


PROCEDURE populate_plsql_tbl_with_intval(
	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE,
	p_simulate		IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	:= FND_API.G_FALSE,
	p_validation_level	IN	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
	p_return_status		OUT NOCOPY	VARCHAR2,
	p_msg_count		OUT NOCOPY	NUMBER,
	p_msg_data		OUT NOCOPY	VARCHAR2,
	p_key_tbl		IN OUT NOCOPY	ece_flatfile_pvt.Interface_tbl_type,
	p_apps_tbl		IN OUT NOCOPY	ece_flatfile_pvt.Interface_tbl_type);

PROCEDURE populate_plsql_tbl_with_intval
	(
	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE,
	p_simulate		IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	:= FND_API.G_FALSE,
	p_validation_level	IN	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
	p_return_status		OUT NOCOPY	VARCHAR2,
	p_msg_count		OUT NOCOPY	NUMBER,
	p_msg_data		OUT NOCOPY	VARCHAR2,
	p_apps_tbl		IN OUT NOCOPY		ec_utils.mapping_tbl,
	p_level			IN			NUMBER
	);
END;


 

/
