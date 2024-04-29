--------------------------------------------------------
--  DDL for Package HZ_GNR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GNR_UTIL_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHGNRUS.pls 120.10.12010000.2 2009/02/16 06:41:09 rgokavar ship $ */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE loc_components_rec_type IS RECORD(
    ADDRESS_STYLE             VARCHAR2(30),
    COUNTRY                   VARCHAR2(60),
    VALIDATE_COUNTRY_AGAINST  VARCHAR2(1),
    CITY                      VARCHAR2(60),
    POSTAL_CODE               VARCHAR2(60),
    STATE                     VARCHAR2(60),
    VALIDATE_STATE_AGAINST    VARCHAR2(1),
    PROVINCE                  VARCHAR2(60),
    VALIDATE_PROVINCE_AGAINST VARCHAR2(1),
    COUNTY                    VARCHAR2(60),
    POSTAL_PLUS4_CODE         VARCHAR2(10),
    ATTRIBUTE1                VARCHAR2(150),
    ATTRIBUTE2                VARCHAR2(150),
    ATTRIBUTE3                VARCHAR2(150),
    ATTRIBUTE4                VARCHAR2(150),
    ATTRIBUTE5                VARCHAR2(150),
    ATTRIBUTE6                VARCHAR2(150),
    ATTRIBUTE7                VARCHAR2(150),
    ATTRIBUTE8                VARCHAR2(150),
    ATTRIBUTE9                VARCHAR2(150),
    ATTRIBUTE10               VARCHAR2(150)
);

TYPE map_rec_type IS RECORD(
     MAP_ID               NUMBER(15),
     COUNTRY_CODE         VARCHAR2(2),
     LOC_TBL_NAME         VARCHAR2(30),
     ADDRESS_STYLE        VARCHAR2(30)
);

TYPE usage_rec_type IS RECORD(
     USAGE_ID              NUMBER(15),
     MAP_ID                NUMBER(15),
     USAGE_CODE            VARCHAR2(30)
);

TYPE usage_tbl_type IS TABLE OF usage_rec_type
    INDEX BY BINARY_INTEGER;

TYPE usage_dtls_rec_type IS RECORD(
     USAGE_ID              NUMBER(15),
     GEOGRAPHY_TYPE        VARCHAR2(30)
);

TYPE usage_dtls_tbl_type IS TABLE OF usage_dtls_rec_type
    INDEX BY BINARY_INTEGER;


TYPE maploc_rec_type IS RECORD(
    LOC_SEQ_NUM     NUMBER,
    LOC_COMPONENT   VARCHAR2(30),
    GEOGRAPHY_TYPE  VARCHAR2(30),
    GEO_ELEMENT_COL VARCHAR2(30),
    LOC_COMPVAL     VARCHAR2(150),
    GEOGRAPHY_ID    NUMBER,
    GEOGRAPHY_CODE  VARCHAR2(30)
);

TYPE maploc_rec_tbl_type IS TABLE OF maploc_rec_type
    INDEX BY BINARY_INTEGER;

TYPE v_tbl_type IS TABLE OF varchar2(150)
    INDEX BY BINARY_INTEGER;

-- Added by Nishant on 16-Feb-2006 for creating pre and post location update
-- processing procedures
TYPE loc_other_param_rec_type IS RECORD(
    called_from VARCHAR2(30)
);

--------------------------------------
-- procedures and functions
--------------------------------------
PROCEDURE getLocCompValues(
   P_loc_table            IN VARCHAR2,
   p_loc_components_rec   IN  loc_components_rec_type,
   x_map_dtls_tbl         IN  OUT NOCOPY maploc_rec_tbl_type,
   x_status               OUT NOCOPY VARCHAR2
 );
--------------------------------------
--------------------------------------
FUNCTION getLocCompCount(
   p_map_dtls_tbl         IN  maploc_rec_tbl_type) RETURN NUMBER;
--------------------------------------
--------------------------------------
PROCEDURE fill_values(
   x_map_dtls_tbl         IN  OUT NOCOPY maploc_rec_tbl_type
 );
--------------------------------------
--------------------------------------
FUNCTION fix_multiparent(
   p_geography_id         IN NUMBER,
   x_map_dtls_tbl         IN  OUT NOCOPY maploc_rec_tbl_type
 ) RETURN BOOLEAN;
--------------------------------------
--------------------------------------
FUNCTION fix_child(
   x_map_dtls_tbl         IN  OUT NOCOPY maploc_rec_tbl_type
 ) RETURN BOOLEAN;
--------------------------------------
--------------------------------------
FUNCTION getQuery(
   p_map_dtls_tbl         IN  maploc_rec_tbl_type,
   p_mdu_tbl              IN  maploc_rec_tbl_type,
   x_status               OUT NOCOPY VARCHAR2
 ) RETURN VARCHAR2;
--------------------------------------
--------------------------------------
-- Below function is for creating the query when there is a cause MULTIPLE_MATCH
-- In this case the query is same as the query created by getQuery function except that
-- this also add the check to verify the identifier_type is NAME
-- Fix for bug #
FUNCTION getQueryforMultiMatch(
   p_map_dtls_tbl         IN  maploc_rec_tbl_type,
   p_mdu_tbl              IN  maploc_rec_tbl_type,
   x_status               OUT NOCOPY VARCHAR2
 ) RETURN VARCHAR2;
--------------------------------------
--------------------------------------
FUNCTION check_GNR_For_Usage(
  p_location_id           IN NUMBER,
  p_location_table_name   IN VARCHAR2,
  p_usage_code            IN VARCHAR2,
  p_mdu_tbl               IN maploc_rec_tbl_type,
  x_status                OUT NOCOPY varchar2
 ) RETURN BOOLEAN;
--------------------------------------
--------------------------------------
 PROCEDURE create_gnr (
       p_location_id            IN number,
       p_location_table_name    IN varchar2,
       p_usage_code             IN varchar2,
       p_map_status             IN varchar2,
       p_loc_components_rec     IN  loc_components_rec_type,
       p_lock_flag              IN varchar2,
       p_map_dtls_tbl           IN maploc_rec_tbl_type,
       x_status                 OUT NOCOPY varchar2
 );
--------------------------------------
--------------------------------------
FUNCTION get_usage_val_status(
       p_map_dtls_tbl          IN maploc_rec_tbl_type,
       p_mdu_tbl               IN maploc_rec_tbl_type
      ) RETURN VARCHAR2;
--------------------------------------
--------------------------------------
PROCEDURE fix_no_match(
   x_map_dtls_tbl         IN  OUT NOCOPY maploc_rec_tbl_type,
   x_status               OUT NOCOPY VARCHAR2
 );
--------------------------------------
--------------------------------------
PROCEDURE getMinValStatus(
   p_mdu_tbl             IN  maploc_rec_tbl_type,
   x_status               IN  OUT NOCOPY VARCHAR2
 );
--------------------------------------
--------------------------------------
FUNCTION do_usage_val(
  p_cause                 IN VARCHAR2,
  p_map_dtls_tbl          IN maploc_rec_tbl_type,
  p_mdu_tbl               IN maploc_rec_tbl_type,
  x_mdtl_derived_tbl      IN OUT NOCOPY maploc_rec_tbl_type,
  x_status                OUT NOCOPY varchar2
 ) RETURN BOOLEAN;
--------------------------------------
--------------------------------------
FUNCTION getAddrValStatus(
   p_map_dtls_tbl         IN  maploc_rec_tbl_type,
   p_mdu_tbl              IN  maploc_rec_tbl_type,
   p_called_from          IN  VARCHAR2,
   p_addr_val_level       IN  VARCHAR2,
   x_addr_warn_msg        OUT NOCOPY VARCHAR2,
   x_map_status           IN  VARCHAR2,
   x_status               IN  OUT NOCOPY VARCHAR2
 ) RETURN VARCHAR2;
--------------------------------------
--------------------------------------

/**
 * PROCEDURE getMapRec
 *
 * DESCRIPTION
 *     This private procedure is used to gets
 *     1. the map record for a given location.
 *     2. populates component values from loc rec
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *     p_locId               Location Identifier
 *     p_locTbl              Location Table
 *
 *   OUT:
 *
 *   x_mapTbl   Table of records that has
 *              geo element, type and loc components and their values
 *   x_status   Y in case of success, otherwise error message name
 *   x_mapId   map identifier
 *   x_cntry   country code
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *
 */
 PROCEDURE getMapRec(
   p_locId       IN NUMBER,
   p_locTbl      IN VARCHAR2,
   x_mlTbl      OUT NOCOPY maploc_rec_tbl_type,
   x_mapId      OUT NOCOPY NUMBER,
   x_cntry      OUT NOCOPY varchar2,
   x_status     OUT NOCOPY VARCHAR2
 );
-----------------------------------------
/**
 * PROCEDURE getLocRec
 *
 * DESCRIPTION
 *     This private procedure is used to get
 * the location record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *     p_locId               Location Identifier
 *     p_locTbl              Location Table
 *
 *   IN OUT:
 *   x_mapTbl   Table of records that has location sequence number,
 *              geo element, type and loc components and their values
 *
 *   OUT:
 *     x_status       procedure status
 *
 * EXCEPTIONS RAISED
 *
 *
 * NOTES
 * By the time thi sprocedure was called but for loc_comval all
 * other elements of x_mapTbl were already populated.
 *
 * MODIFICATION HISTORY
 *
 *
 */
 PROCEDURE getLocRec (
   p_locId     IN NUMBER,
   p_locTbl    IN VARCHAR2,
   x_mlTbl     IN OUT NOCOPY maploc_rec_tbl_type,
   x_status    OUT NOCOPY VARCHAR2
 );
-----------------------------------------------------------
/**
 * PROCEDURE getCntryStyle
 *
 * DESCRIPTION
 *     This private procedure is used to get the country code address style for a location.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *     p_locId               Location Identifier
 *     p_locTbl              Location Table
 *
 *   OUT:
 *
 *     x_cntry                Country Code
 *     x_addrStyle           Address Style
 *
 * EXCEPTIONS RAISED
 *
 *  HZ_NO_LOC_TBL
 *  HZ_GEO_INVALID_COUNTRY
 *  HZ_GEO_NO_LOC_REC
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *
 */

 PROCEDURE getCntryStyle (
       p_locId       IN NUMBER,
       p_locTbl      IN VARCHAR2,
       x_cntry       OUT NOCOPY VARCHAR2,
       x_addrStyle   OUT NOCOPY VARCHAR2,
       x_status      OUT NOCOPY VARCHAR2
 );
-----------------------------------------------------------
/**
 * PROCEDURE gnrIns
 *
 * DESCRIPTION
 *     This private procedure is used to insert or update the
 *     GNR table.
 *     This procedure will update if the same location id and
 *     geography id combination is existing otherwise this will insert.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *     p_locId               Location Identifier
 *     p_locTbl              Location Table
 *
 *     p_mapTbl   Table of records that has location sequence number,
 *              geo element, type and loc components and their values
 *
 *   OUT:
 *
 *     x_status       procedure status
 *
 *
 * EXCEPTIONS RAISED
 *
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *
 */

 PROCEDURE gnrIns (
       p_locId       IN NUMBER,
       p_locTbl      IN VARCHAR2,
       p_mapTbl      IN maploc_rec_tbl_type,
       x_status      OUT NOCOPY VARCHAR2
 );
-----------------------------------------------------------
/**
 * PROCEDURE gnrl
 *
 * DESCRIPTION
 *     This private procedure is used to insert or update the
 *     GNR Log table. This log table will be updated irrespective
 *     of whether the GNRing of a location record is sucessfull or not.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_locId        Location Identifier
 *     p_locTbl       Location Table
 *     p_mapStatus    sucess, error or warning
 *     p_mesg         encoded mesg
 *
 *
 * EXCEPTIONS RAISED
 *
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *
 */

 PROCEDURE gnrl (
       p_locId       IN NUMBER,
       p_locTbl      IN VARCHAR2,
       p_mapStatus   IN VARCHAR2,
       p_mesg        IN VARCHAR2
 );
----------------------------------------------
/**
* Procedure to write a message to the out file
**/
----------------------------------------------
PROCEDURE out(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);
----------------------------------------------
/**
* Procedure to write a message to the log file
**/
----------------------------------------------
PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);
----------------------------------------------
/**
* Procedure to write a message to the out and log files
**/
----------------------------------------------
PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);
----------------------------------------------
/**
* Function to fetch messages of the stack and log the error
* Also returns the error
**/
----------------------------------------------
FUNCTION logerror RETURN VARCHAR2;
----------------------------------------------
/**
* procedure to fetch messages of the stack and log the error
**/
----------------------------------------------
PROCEDURE logerr;
----------------------------------------------
/*
  this procedure takes a message_name and enters into the message stack
  and writes into the log file also.
*/
PROCEDURE mesglog(
   p_locId     IN NUMBER,
   p_locTbl    IN VARCHAR2,
   p_message      IN      VARCHAR2,
   p_tkn1_name    IN      VARCHAR2,
   p_tkn1_val     IN      VARCHAR2,
   p_tkn2_name    IN      VARCHAR2,
   p_tkn2_val     IN      VARCHAR2
   );
----------------------------------------------
/**
 * PROCEDURE getMapId
 *
 * DESCRIPTION
 *    This private procedure is used to gets the
 *    map identifier for a given location id, loc table name
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *     p_locId               Location Identifier
 *     p_locTbl              Location Table
 *
 *   OUT:
 *
 *   x_status   Y in case of success, otherwise error message name
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *
 */
 PROCEDURE getMapId(
   p_locId       IN NUMBER,
   p_locTbl      IN VARCHAR2,
   x_cntry      OUT NOCOPY VARCHAR2,
   x_mapId      OUT NOCOPY NUMBER,
   x_status     OUT NOCOPY VARCHAR2
 );
-----------------------------------------
/**
  Function : gnr_exists

  DESCRIPTION :
     Function to tell if the GNR already processed for a given
     location record or not.

  ARGUMENTS  :
     IN   p_location_id NUMBER
     IN   p_location_table_name VARCHAR2

  RETURNS : BOOLEAN
     TRUE  : If GNR exists
     FALSE : If GNR does not exists

   MODIFICATION HISTORY:
   17-FEB-2006   Baiju nair    Created

**/
  FUNCTION gnr_exists(p_location_id IN NUMBER,
                      p_location_table_name IN VARCHAR2) RETURN BOOLEAN;

-----------------------------------------

/**
  Function : location_updation_allowed

  DESCRIPTION :
     Function to tell if the location can be updated or not. It directly calls
     ARH_ADDR_PKG.check_tran_for_all_accts to do this validation. This function is
     just a wrapper for ease of use in GNR code

  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED :
     ARH_ADDR_PKG

  ARGUMENTS  :
     IN   p_location_id NUMBER

  RETURNS : BOOLEAN
     TRUE  : Location updation is allowed
     FALSE : Location updation is not allowed

   MODIFICATION HISTORY:
     16-FEB-2006   Nishant Singhai    Created

**/

  FUNCTION location_updation_allowed(p_location_id IN NUMBER) RETURN BOOLEAN;

/**
   Procedure : pre_location_update

  DESCRIPTION :
    Procedure to do pre-update processing for a given location record. This will
    be used in GNR program, where it updates the location components.

  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED :
     HZ_LOCATION_V2PUB
     hz_fuzzy_pub
     hz_timezone_pub

  ARGUMENTS  :
     IN      p_old_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE

     IN OUT  p_new_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE
     IN OUT  p_other_location_params HZ_GNR_UTIL_PKG.location_other_param_rec_type
	         (extendible - for future use)

   MODIFICATION HISTORY:
     16-FEB-2006   Nishant Singhai    Created
**/

PROCEDURE pre_location_update (
     p_old_location_rec      IN            HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
     p_new_location_rec      IN OUT NOCOPY HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
     p_other_location_params IN OUT NOCOPY HZ_GNR_UTIL_PKG.loc_other_param_rec_type,
     x_return_status         OUT NOCOPY    VARCHAR2,
     x_msg_count             OUT NOCOPY    NUMBER,
     x_msg_data              OUT NOCOPY    VARCHAR2
);

/**
   Procedure : post_location_update

  DESCRIPTION :
    Procedure to do post-update processing for a given location record. This will
    be used in GNR program, where it updates the location components.

  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED :
     HZ_LOCATION_V2PUB
     HZ_UTILITY_V2PUB
     HZ_DQM_SYNC
     HZ_BUSINESS_EVENT_V2PVT
     HZ_POPULATE_BOT_PKG

  ARGUMENTS  :
     IN      p_old_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE

     IN OUT  p_new_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE
     IN OUT  p_other_location_params HZ_GNR_UTIL_PKG.location_other_param_rec_type
	         (extendible - for future use)

   MODIFICATION HISTORY:
     16-FEB-2006   Nishant Singhai    Created
**/

PROCEDURE post_location_update (
     p_old_location_rec      IN            HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
     p_new_location_rec      IN OUT NOCOPY HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
     p_other_location_params IN OUT NOCOPY HZ_GNR_UTIL_PKG.loc_other_param_rec_type,
     x_return_status         OUT NOCOPY    VARCHAR2,
     x_msg_count             OUT NOCOPY    NUMBER,
     x_msg_data              OUT NOCOPY    VARCHAR2
);

--ER#7240974
/**
   Function : postal_code_to_validate

  DESCRIPTION :
	Based on profile(HZ_VAL_FIRST_5_DIGIT_US_ZIP) value,
	it will return the postal code that needs to be validated.

  ARGUMENTS  :
     IN   p_country_code VARCHAR2
     IN   p_postal_code  VARCHAR2

  RETURNS : VARCHAR2
    postal code that needs to be validated


   MODIFICATION HISTORY:
     17-DEC-2008   Sudhir Gokavarapu    Created

**/

FUNCTION postal_code_to_validate(
   p_country_code         IN VARCHAR2,
   p_postal_code          IN VARCHAR2
 ) RETURN VARCHAR2;

END HZ_GNR_UTIL_PKG;

/
