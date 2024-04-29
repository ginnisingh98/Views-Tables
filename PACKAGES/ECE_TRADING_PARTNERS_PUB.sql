--------------------------------------------------------
--  DDL for Package ECE_TRADING_PARTNERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_TRADING_PARTNERS_PUB" AUTHID CURRENT_USER AS
-- $Header: ECVNWTPS.pls 120.2 2005/09/28 07:25:44 arsriniv ship $

   --  Global constants holding the package and file names to be used by
   --  messaging routines in the case of an unexpected error.
   G_PKG_NAME                 CONSTANT VARCHAR2(30)   := 'ece_trading_partners_pub';
   G_FILE_NAME                CONSTANT VARCHAR2(12)   := 'ECVTPXFB.pls';

   --  Global constants representing Bank, Customer, Internal Location, and Supplier.
   G_BANK                     CONSTANT NUMBER         := 0;
   G_CUSTOMER                 CONSTANT NUMBER         := 1;
   G_HR_LOCATION              CONSTANT NUMBER         := 2;
   G_SUPPLIER                 CONSTANT NUMBER         := 3;

   -- Global constants representing Status Codes
   G_NO_ERRORS                CONSTANT NUMBER         := 0;
   G_INCONSISTENT_ADDR_COMP   CONSTANT NUMBER         := 1;
   G_CANNOT_DERIVE_ADDR       CONSTANT NUMBER         := 2;
   G_CANNOT_DERIVE_ADDR_ID    CONSTANT NUMBER         := 3;
   G_INVALID_ADDR_ID          CONSTANT NUMBER         := 4;
   G_INVALID_ORG_ID           CONSTANT NUMBER         := 5;
   G_INVALID_PARAMETER        CONSTANT NUMBER         := 6;
   G_UNEXP_ERROR              CONSTANT NUMBER         := 7;

  -- bug 2151462
   G_MULTIPLE_LOC_FOUND       CONSTANT NUMBER         := 8;
   G_MULTIPLE_ADDR_FOUND      CONSTANT NUMBER         := 9;

-- Start of Comments
--	API name 	: Get_TP_Address
--	Type		: Private.
--	Function	: Retrieve Supplier/Customer and Address information for a TP
--	Pre-reqs	: None.
--	Paramaeters	:
-- IN    :  p_api_version_number    IN NUMBER      Required
--          p_init_msg_list         IN VARCHAR2    Optional Default = FND_API.G_FALSE
--          p_simulate              IN VARCHAR2    Optional Default = FND_API.G_FALSE
--          p_commit                IN VARCHAR2    Optional Default = FND_API.G_FALSE
--          p_validation_level      IN NUMBER      Optional Default = FND_API.G_VALID_LEVEL_FULL
--          p_translator_code       IN VARCHAR2    Required
--          p_location_code_ext     IN VARCHAR2    Required
--          p_info_type             IN VARCHAR2    Required
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

   PROCEDURE ece_get_address_wrapper(
      p_api_version_number       IN    NUMBER,
      p_init_msg_list            IN    VARCHAR2 := FND_API.G_FALSE,
      p_simulate                 IN    VARCHAR2 := FND_API.G_FALSE,
      p_commit                   IN    VARCHAR2 := FND_API.G_FALSE,
      p_validation_level         IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status            OUT NOCOPY   VARCHAR2,
      x_msg_count                OUT NOCOPY   NUMBER,
      x_msg_data                 OUT NOCOPY   VARCHAR2,
      x_status_code              OUT NOCOPY   NUMBER,
      p_address_type             IN    NUMBER,
      p_transaction_type         IN    VARCHAR2,
      p_org_id_in                IN    NUMBER DEFAULT NULL,
      p_address_id_in            IN    NUMBER DEFAULT NULL,
      p_tp_location_code_in      IN    VARCHAR2 DEFAULT NULL,
      p_translator_code_in       IN    VARCHAR2 DEFAULT NULL,
      p_tp_location_name_in      IN    VARCHAR2 DEFAULT NULL,
      p_address_line1_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line2_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line3_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line4_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line_alt_in      IN    VARCHAR2 DEFAULT NULL,
      p_city_in                  IN    VARCHAR2 DEFAULT NULL,
      p_county_in                IN    VARCHAR2 DEFAULT NULL,
      p_state_in                 IN    VARCHAR2 DEFAULT NULL,
      p_zip_in                   IN    VARCHAR2 DEFAULT NULL,
      p_province_in              IN    VARCHAR2 DEFAULT NULL,
      p_country_in               IN    VARCHAR2 DEFAULT NULL,
      p_region_1_in              IN    VARCHAR2 DEFAULT NULL,
      p_region_2_in              IN    VARCHAR2 DEFAULT NULL,
      p_region_3_in              IN    VARCHAR2 DEFAULT NULL,
      x_entity_id_out            OUT NOCOPY   NUMBER,
      x_org_id_out               OUT NOCOPY   NUMBER,
      x_address_id_out           OUT NOCOPY   NUMBER,
      x_tp_location_code_out     OUT NOCOPY   VARCHAR2,
      x_translator_code_out      OUT NOCOPY   VARCHAR2,
      x_tp_location_name_out     OUT NOCOPY   VARCHAR2,
      x_address_line1_out        OUT NOCOPY   VARCHAR2,
      x_address_line2_out        OUT NOCOPY   VARCHAR2,
      x_address_line3_out        OUT NOCOPY   VARCHAR2,
      x_address_line4_out        OUT NOCOPY   VARCHAR2,
      x_address_line_alt_out     OUT NOCOPY   VARCHAR2,
      x_city_out                 OUT NOCOPY   VARCHAR2,
      x_county_out               OUT NOCOPY   VARCHAR2,
      x_state_out                OUT NOCOPY   VARCHAR2,
      x_zip_out                  OUT NOCOPY   VARCHAR2,
      x_province_out             OUT NOCOPY   VARCHAR2,
      x_country_out              OUT NOCOPY   VARCHAR2,
      x_region_1_out             OUT NOCOPY   VARCHAR2,
      x_region_2_out             OUT NOCOPY   VARCHAR2,
      x_region_3_out             OUT NOCOPY   VARCHAR2);

   PROCEDURE ece_get_address(
      p_api_version_number       IN    NUMBER,
      p_init_msg_list            IN    VARCHAR2 := fnd_api.G_FALSE,
      p_simulate                 IN    VARCHAR2 := fnd_api.G_FALSE,
      p_commit                   IN    VARCHAR2 := fnd_api.G_FALSE,
      p_validation_level         IN    NUMBER   := fnd_api.G_VALID_LEVEL_FULL,
      x_return_status            OUT NOCOPY   VARCHAR2,
      x_msg_count                OUT NOCOPY   NUMBER,
      x_msg_data                 OUT NOCOPY   VARCHAR2,
      x_status_code              OUT NOCOPY   NUMBER,
      p_precedence_code          IN    VARCHAR2,
      p_address_type             IN    NUMBER,
      p_transaction_type         IN    VARCHAR2,
      p_org_id_in                IN    NUMBER DEFAULT NULL,
      p_address_id_in            IN    NUMBER DEFAULT NULL,
      p_tp_location_code_in      IN    VARCHAR2 DEFAULT NULL,
      p_translator_code_in       IN    VARCHAR2 DEFAULT NULL,
      p_tp_location_name_in      IN    VARCHAR2 DEFAULT NULL,
      p_address_line1_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line2_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line3_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line4_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line_alt_in      IN    VARCHAR2 DEFAULT NULL,
      p_city_in                  IN    VARCHAR2 DEFAULT NULL,
      p_county_in                IN    VARCHAR2 DEFAULT NULL,
      p_state_in                 IN    VARCHAR2 DEFAULT NULL,
      p_zip_in                   IN    VARCHAR2 DEFAULT NULL,
      p_province_in              IN    VARCHAR2 DEFAULT NULL,
      p_country_in               IN    VARCHAR2 DEFAULT NULL,
      p_region_1_in              IN    VARCHAR2 DEFAULT NULL,
      p_region_2_in              IN    VARCHAR2 DEFAULT NULL,
      p_region_3_in              IN    VARCHAR2 DEFAULT NULL,
      x_org_id_out               OUT NOCOPY   NUMBER,
      x_address_id_out           OUT NOCOPY   NUMBER,
      x_tp_location_code_out     OUT NOCOPY   VARCHAR2,
      x_translator_code_out      OUT NOCOPY   VARCHAR2,
      x_tp_location_name_out     OUT NOCOPY   VARCHAR2,
      x_address_line1_out        OUT NOCOPY   VARCHAR2,
      x_address_line2_out        OUT NOCOPY   VARCHAR2,
      x_address_line3_out        OUT NOCOPY   VARCHAR2,
      x_address_line4_out        OUT NOCOPY   VARCHAR2,
      x_address_line_alt_out     OUT NOCOPY   VARCHAR2,
      x_city_out                 OUT NOCOPY   VARCHAR2,
      x_county_out               OUT NOCOPY   VARCHAR2,
      x_state_out                OUT NOCOPY   VARCHAR2,
      x_zip_out                  OUT NOCOPY   VARCHAR2,
      x_province_out             OUT NOCOPY   VARCHAR2,
      x_country_out              OUT NOCOPY   VARCHAR2,
      x_region_1_out             OUT NOCOPY   VARCHAR2,
      x_region_2_out             OUT NOCOPY   VARCHAR2,
      x_region_3_out             OUT NOCOPY   VARCHAR2);

   FUNCTION ece_compare_addresses(
      p_address_line1_in         IN    VARCHAR2,
      p_address_line2_in         IN    VARCHAR2,
      p_address_line3_in         IN    VARCHAR2,
      p_address_line4_in         IN    VARCHAR2,
      p_address_line_alt_in      IN    VARCHAR2,
      p_city_in                  IN    VARCHAR2,
      p_county_in                IN    VARCHAR2,
      p_state_in                 IN    VARCHAR2,
      p_zip_in                   IN    VARCHAR2,
      p_province_in              IN    VARCHAR2,
      p_country_in               IN    VARCHAR2,
      p_region_1_in              IN    VARCHAR2,
      p_region_2_in              IN    VARCHAR2,
      p_region_3_in              IN    VARCHAR2,
      p2_address_line1_in        IN    VARCHAR2,
      p2_address_line2_in        IN    VARCHAR2,
      p2_address_line3_in        IN    VARCHAR2,
      p2_address_line4_in        IN    VARCHAR2,
      p2_address_line_alt_in     IN    VARCHAR2,
      p2_city_in                 IN    VARCHAR2,
      p2_county_in               IN    VARCHAR2,
      p2_state_in                IN    VARCHAR2,
      p2_zip_in                  IN    VARCHAR2,
      p2_province_in             IN    VARCHAR2,
      p2_country_in              IN    VARCHAR2,
      p2_region_1_in             IN    VARCHAR2,
      p2_region_2_in             IN    VARCHAR2,
      p2_region_3_in             IN    VARCHAR2) RETURN BOOLEAN;

   FUNCTION scrub(
      p_instring VARCHAR2) RETURN VARCHAR2;

   --***********************************************
   -- procedure Get_TP_Address
   --***********************************************
   PROCEDURE Get_TP_Address(
      p_api_version_number       IN    NUMBER,
      p_init_msg_list            IN    VARCHAR2 := fnd_api.G_FALSE,
      p_simulate                 IN    VARCHAR2 := fnd_api.G_FALSE,
      p_commit                   IN    VARCHAR2 := fnd_api.G_FALSE,
      p_validation_level         IN    NUMBER   := fnd_api.G_VALID_LEVEL_FULL,
      p_return_status            OUT NOCOPY   VARCHAR2,
      p_msg_count                OUT NOCOPY   NUMBER,
      p_msg_data                 OUT NOCOPY   VARCHAR2,
      p_translator_code          IN    VARCHAR2,
      p_location_code_ext        IN    VARCHAR2,
      p_info_type                IN    VARCHAR2,
      p_entity_id                OUT NOCOPY   NUMBER,
      p_entity_address_id        OUT NOCOPY   NUMBER);

   --***********************************************
   -- procedure Get_TP_Address_Auto
   --
   --  Overload this procedure per request from
   --  the automotive team
   --***********************************************
   PROCEDURE Get_TP_Address_Ref(
      p_api_version_number       IN    NUMBER,
      p_init_msg_list            IN    VARCHAR2 := fnd_api.G_FALSE,
      p_simulate                 IN    VARCHAR2 := fnd_api.G_FALSE,
      p_commit                   IN    VARCHAR2 := fnd_api.G_FALSE,
      p_validation_level         IN    NUMBER   := fnd_api.G_VALID_LEVEL_FULL,
      p_return_status            OUT NOCOPY   VARCHAR2,
      p_msg_count                OUT NOCOPY   NUMBER,
      p_msg_data                 OUT NOCOPY   VARCHAR2,
      p_reference_ext1           IN    VARCHAR2,
      p_reference_ext2           IN    VARCHAR2,
      p_info_type                IN    VARCHAR2,
      p_entity_id                OUT NOCOPY   NUMBER,
      p_entity_address_id        OUT NOCOPY   NUMBER);

   --***********************************************
   -- procedure Get_TP_Location_Code
   --***********************************************
   PROCEDURE Get_TP_Location_Code(
      p_api_version_number       IN    NUMBER,
      p_init_msg_list            IN    VARCHAR2 := fnd_api.G_FALSE,
      p_simulate                 IN    VARCHAR2 := fnd_api.G_FALSE,
      p_commit                   IN    VARCHAR2 := fnd_api.G_FALSE,
      p_validation_level         IN    NUMBER   := fnd_api.G_VALID_LEVEL_FULL,
      p_return_status            OUT NOCOPY   VARCHAR2,
      p_msg_count                OUT NOCOPY   NUMBER,
      p_msg_data                 OUT NOCOPY   VARCHAR2,
      p_entity_address_id        IN    NUMBER,
      p_info_type                IN    VARCHAR2,
      p_location_code_ext        OUT NOCOPY   VARCHAR2,
      p_reference_ext1           OUT NOCOPY   VARCHAR2,
      p_reference_ext2           OUT NOCOPY   VARCHAR2);

END;


 

/
