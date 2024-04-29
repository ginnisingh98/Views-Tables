--------------------------------------------------------
--  DDL for Package HZ_GNR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GNR_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHGNRPS.pls 120.7 2006/06/16 18:33:51 nsinghai noship $ */

  PROCEDURE process_gnr (
    p_location_table_name  IN         VARCHAR2,
    p_location_id          IN         NUMBER,
    p_call_type            IN         VARCHAR2, -- supported values ("C" and "U")
    p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2);

  /*
    This procedure will validate the location record against geography data.
    Input Parameters:
      p_location_id   : Location Id from HZ_LOCATIONS table to be validated
      p_create_gnr_record : parameter that indicates if GNR record for the passed
	                        in location needs to be created or not. Default is Y.
	                        If only needs to test the validity of location and GNR
	                        record creation is not desired, then N can be passed.
	Output Parameters:
	  x_addr_val_level : Address Validation Level as determined by the program and
	                     it used to do address validation
	  x_addr_warn_msg  : Message Text when address validation level is Warning and
	                     x_addr_val_status returns W i.e. not success.
	  x_addr_val_status: Address validation Status. It can have 4 values:
	                     S (Success): Address validation is successful
	                     W (Warning): Validation Level is WARNING and address validation
	                                  is not successful
	                     E (Error) : Address validation is NOT successful
	                     U (Unexpected Error) : System Error
	  x_return_status  : Return Status of API. It can have 3 values:
	                     S (Success): Address validation is successful (Even if x_addr_val_status
						              is W (Warning), this will return S.
	                     E (Error)  : Address validation is NOT successful
	                     U (Unexpected Error) : System Error
      x_msg_count      : No. of messages stacked.
      x_msg_data       : Message Text for the messages stacked by validateLoc API.
	                     It will return message for both E as well as W status
						 of x_addr_val_status.

      Usage of API:    If purpose is to only validate location id and get the error
	                   message text for that location, then read x_addr_val_status
					   for status and x_msg_data for message text.
                       If used in plsql API flow, to read all the stacked messages,
					   use FND_MSG_PUB utility to read message stack.

  */
  PROCEDURE validateLoc (
    p_location_id          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    x_addr_val_level       OUT NOCOPY VARCHAR2,
    x_addr_warn_msg        OUT NOCOPY VARCHAR2,
    x_addr_val_status      OUT NOCOPY VARCHAR2,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    p_create_gnr_record    IN  VARCHAR2 DEFAULT 'Y'
    );

  PROCEDURE validateLoc(
    p_location_id               IN NUMBER DEFAULT NULL,
    p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE,
    p_usage_code                IN VARCHAR2 DEFAULT 'GEOGRAPHY',
    p_address_style             IN VARCHAR2 DEFAULT NULL,
    p_country                   IN VARCHAR2,
    p_state                     IN VARCHAR2 DEFAULT NULL,
    p_province                  IN VARCHAR2 DEFAULT NULL,
    p_county                    IN VARCHAR2 DEFAULT NULL,
    p_city                      IN VARCHAR2 DEFAULT NULL,
    p_postal_code               IN VARCHAR2 DEFAULT NULL,
    p_postal_plus4_code         IN VARCHAR2 DEFAULT NULL,
    p_attribute1                IN VARCHAR2 DEFAULT NULL,
    p_attribute2                IN VARCHAR2 DEFAULT NULL,
    p_attribute3                IN VARCHAR2 DEFAULT NULL,
    p_attribute4                IN VARCHAR2 DEFAULT NULL,
    p_attribute5                IN VARCHAR2 DEFAULT NULL,
    p_attribute6                IN VARCHAR2 DEFAULT NULL,
    p_attribute7                IN VARCHAR2 DEFAULT NULL,
    p_attribute8                IN VARCHAR2 DEFAULT NULL,
    p_attribute9                IN VARCHAR2 DEFAULT NULL,
    p_attribute10               IN VARCHAR2 DEFAULT NULL,
    x_addr_val_level            OUT NOCOPY VARCHAR2,
    x_addr_warn_msg             OUT NOCOPY VARCHAR2,
    x_addr_val_status           OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2);

  FUNCTION get_addr_val_level(p_country_code IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE get_addr_val_status(
    p_location_table_name  IN         VARCHAR2,
    p_location_id          IN         NUMBER,
    p_usage_code           IN         VARCHAR2,
    x_is_validated          OUT NOCOPY VARCHAR2,
    x_address_status       OUT NOCOPY VARCHAR2);


END HZ_GNR_PUB;

 

/
