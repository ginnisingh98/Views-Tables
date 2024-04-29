--------------------------------------------------------
--  DDL for Package EC_TRADING_PARTNER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_TRADING_PARTNER_PVT" AUTHID CURRENT_USER AS
-- $Header: ECVTPXFS.pls 120.2 2005/09/28 07:23:08 arsriniv ship $

--  Global constants holding the package and file names to be used by
--  messaging routines in the case of an unexpected error.

G_PKG_NAME	CONSTANT VARCHAR2(30) := 'EC_Trading_Partner_PVT';
G_FILE_NAME	CONSTANT VARCHAR2(12) := 'ECVTPXFB.pls';

--  Global constants representing CUSTOMER and SUPPLIER

G_BANK		CONSTANT	VARCHAR2(10) := 'BANK';
G_CUSTOMER	CONSTANT	VARCHAR2(10) := 'CUSTOMER';
G_SUPPLIER	CONSTANT	VARCHAR2(10) := 'SUPPLIER';
G_LOCATION	CONSTANT	VARCHAR2(10) := 'LOCATION';

G_TP_NOT_FOUND	CONSTANT	VARCHAR2(1) := 'X';

-- Start of Comments
--	API name 	: Get_TP_Address
--	Type		: Private.
--	Function	: Retrieve Supplier/Customer and Address information for a TP
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
--				p_translator_code	IN VARCHAR2		Required
--				p_location_code_ext	IN VARCHAR2		Required
--				p_info_type		IN VARCHAR2		Required
--
--	OUT		:	p_return_status		OUT VARCHAR2(1)
--				p_msg_count		OUT NUMBER
--				p_msg_data		OUT VARCHAR2(2000)
--				p_entity_id		OUT NUMBER
--				p_entity_address_id	OUT NUMBER
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Note text
--
--
--	API name 	: Get_TP_Address_Ref
--	Type		: Private.
--	Function	: Retrieve Supplier/Customer and Address information for a TP
--			  This implementation is per request from the automotive team
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
--				p_reference_ext1	IN VARCHAR2		Required
--				p_reference_ext2	IN VARCHAR2		Required
--				p_info_type		IN VARCHAR2		Required
--
--	OUT		:	p_return_status		OUT VARCHAR2(1)
--				p_msg_count		OUT NUMBER
--				p_msg_data		OUT VARCHAR2(2000)
--				p_entity_id		OUT NUMBER
--				p_entity_address_id	OUT NUMBER
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Note text
--
--
--	API name 	: Get_TP_Location_Code
--	Type		: Private.
--	Function	: Retrieve TP information for an address
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
--				p_entity_address_id	IN NUMBER		Required
--				p_info_type		IN VARCHAR2		Required
--
--	OUT		:	p_return_status		OUT VARCHAR2(1)
--				p_msg_count		OUT NUMBER
--				p_msg_data		OUT VARCHAR2(2000)
--				p_location_code_ext	OUT VARCHAR2
--				p_reference_ext1	OUT VARCHAR2
--				p_reference_ext2	OUT VARCHAR2

--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Note text
--
--

--  ***********************************************
--	procedure Get_TP_Address
--  ***********************************************
PROCEDURE Get_TP_Address
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_translator_code		IN	VARCHAR2,
   p_location_code_ext		IN	VARCHAR2,
   p_info_type			IN	VARCHAR2,
   p_entity_id			OUT NOCOPY	NUMBER,
   p_entity_address_id		OUT NOCOPY	NUMBER
);


--  ***********************************************
--	procedure Get_TP_Address_Auto
--
--  Overload this procedure per request from
--  the automotive team
--  ***********************************************
PROCEDURE Get_TP_Address_Ref
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_reference_ext1		IN	VARCHAR2,
   p_reference_ext2		IN	VARCHAR2,
   p_info_type			IN	VARCHAR2,
   p_entity_id			OUT NOCOPY	NUMBER,
   p_entity_address_id		OUT NOCOPY	NUMBER
);


--  ***********************************************
--	procedure Get_TP_Location_Code
--  ***********************************************
PROCEDURE Get_TP_Location_Code
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_entity_address_id		IN	NUMBER,
   p_info_type			IN	VARCHAR2,
   p_location_code_ext		OUT NOCOPY	VARCHAR2,
   p_reference_ext1		OUT NOCOPY	VARCHAR2,
   p_reference_ext2		OUT NOCOPY	VARCHAR2
);


FUNCTION IS_ENTITY_ENABLED
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_transaction_type		IN	VARCHAR2,
   p_transaction_subtype	IN      VARCHAR2,
   p_entity_type		IN      VARCHAR2,
   p_entity_id			IN      NUMBER
) RETURN BOOLEAN;


END;

 

/
