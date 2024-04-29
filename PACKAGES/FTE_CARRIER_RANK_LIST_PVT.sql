--------------------------------------------------------
--  DDL for Package FTE_CARRIER_RANK_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_CARRIER_RANK_LIST_PVT" AUTHID CURRENT_USER AS
/* $Header: FTECLTHS.pls 120.2 2005/06/23 16:17:57 appldev noship $ */

   c_sdebug    CONSTANT NUMBER := wsh_debug_sv.c_level1;
   c_debug     CONSTANT NUMBER := wsh_debug_sv.c_level2;

   S_CREATE	CONSTANT 	VARCHAR2(30)	:=	'CREATE';
   S_UPDATE	CONSTANT	VARCHAR2(30)	:=	'UPDATE';
   S_DELETE	CONSTANT	VARCHAR2(30)	:=	'DELETE';
   S_SET_CURRENT	CONSTANT	VARCHAR2(30)	:=	'SET_CURRENT';
   S_APPEND	CONSTANT	VARCHAR2(30)	:=	'APPEND';
   S_REPLACE	CONSTANT	VARCHAR2(30)	:=	'REPLACE';
   S_GET	CONSTANT	VARCHAR2(30)	:=	'GET';

   S_SOURCE_RG	CONSTANT	VARCHAR2(30)	:=	'RG';
   S_SOURCE_UI	CONSTANT	VARCHAR2(30)	:=	'MAN';
   S_SOURCE_LCSS CONSTANT	VARCHAR2(30)	:=	'LCSS';
   S_SOURCE_TP	CONSTANT	VARCHAR2(30)	:=	'TP';

--
--  Procedure:          RANK_LIST_ACTION
--  Parameters:         Move Record info; rowid, move_id, name, return_status as OUT
--  Description:        This procedure will create a move. It will
--                      return to the user the move_id and generates a name if
--				    move name is not specified.
--

TYPE carrier_rank_list_rec IS RECORD (
  RANK_ID                   NUMBER   ,
  TRIP_ID                   NUMBER	,
  RANK_SEQUENCE             NUMBER	,
  CARRIER_ID		    NUMBER,
  SERVICE_LEVEL	            VARCHAR2(30),
  MODE_OF_TRANSPORT         VARCHAR2(30),
  LANE_ID                   NUMBER,
  SOURCE		    VARCHAR2(30),
  ENABLED		    VARCHAR2(1),
  ESTIMATED_RATE	    NUMBER,
  CURRENCY_CODE		    VARCHAR2(15),
  VEHICLE_ITEM_ID	    NUMBER,
  ESTIMATED_TRANSIT_TIME    NUMBER,
  TRANSIT_TIME_UOM	    VARCHAR2(3),
  VERSION		    NUMBER,
  CONSIGNEE_CARRIER_AC_NO   VARCHAR2(240),
  FREIGHT_TERMS_CODE	    VARCHAR2(30),
  INITSMCONFIG		    VARCHAR2(3),
  ATTRIBUTE_CATEGORY        VARCHAR2(150),
  ATTRIBUTE1                VARCHAR2(150),
  ATTRIBUTE2                VARCHAR2(150),
  ATTRIBUTE3                VARCHAR2(150),
  ATTRIBUTE4                VARCHAR2(150),
  ATTRIBUTE5                VARCHAR2(150),
  ATTRIBUTE6                VARCHAR2(150),
  ATTRIBUTE7                VARCHAR2(150),
  ATTRIBUTE8                VARCHAR2(150),
  ATTRIBUTE9                VARCHAR2(150),
  ATTRIBUTE10               VARCHAR2(150),
  ATTRIBUTE11               VARCHAR2(150),
  ATTRIBUTE12               VARCHAR2(150),
  ATTRIBUTE13               VARCHAR2(150),
  ATTRIBUTE14               VARCHAR2(150),
  ATTRIBUTE15               VARCHAR2(150),
  CREATION_DATE             DATE   ,
  CREATED_BY                NUMBER ,
  LAST_UPDATE_DATE          DATE   ,
  LAST_UPDATED_BY           NUMBER ,
  LAST_UPDATE_LOGIN         NUMBER,
  IS_CURRENT		    VARCHAR(1),
  SINGLE_CURR_RATE	NUMBER,
  SORT			VARCHAR2(2),
  SCHEDULE_FROM		DATE,
  SCHEDULE_TO		DATE,
  SCHEDULE_ID		NUMBER,
  VEHICLE_ORG_ID		NUMBER,
  CALL_RG_FLAG		VARCHAR2(1));

TYPE carrier_rank_list_tbl_type is TABLE of carrier_rank_list_rec index by binary_integer;

    TYPE NUMBER_TAB	IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE DATE_TAB	IS TABLE OF DATE INDEX BY BINARY_INTEGER;
    TYPE VARCHAR2_150TAB	IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
    TYPE VARCHAR2_30TAB	IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

-- For bulk operations
    TYPE	ENABLED_TAB		  	IS TABLE OF FTE_CARRIER_RANK_LIST.ENABLED%TYPE	  INDEX BY BINARY_INTEGER;
    TYPE	CURRENCY_CODE_TAB		IS TABLE OF FTE_CARRIER_RANK_LIST.CURRENCY_CODE%TYPE	  INDEX BY BINARY_INTEGER;
    TYPE	TRANSIT_TIME_UOM_TAB		IS TABLE OF FTE_CARRIER_RANK_LIST.TRANSIT_TIME_UOM%TYPE	  INDEX BY BINARY_INTEGER;
    TYPE	INITSMCONFIG_TAB		IS TABLE OF FTE_CARRIER_RANK_LIST.INITSMCONFIG%TYPE		  INDEX BY BINARY_INTEGER;
    TYPE	IS_CURRENT_TAB			IS TABLE OF VARCHAR2(1)		  INDEX BY BINARY_INTEGER;
    TYPE	SORT_TAB			IS TABLE OF VARCHAR2(2)			  INDEX BY BINARY_INTEGER;
    TYPE	CALL_RG_FLAG_TAB		IS TABLE OF FTE_CARRIER_RANK_LIST.CALL_RG_FLAG%TYPE		  INDEX BY BINARY_INTEGER;


TYPE carrier_rank_list_bulk_rec IS RECORD (
    RANK_ID                    NUMBER_TAB,
    TRIP_ID                    NUMBER_TAB,
    RANK_SEQUENCE              NUMBER_TAB,
    CARRIER_ID		       NUMBER_TAB,
    SERVICE_LEVEL	       VARCHAR2_30TAB,
    MODE_OF_TRANSPORT          VARCHAR2_30TAB,
    LANE_ID                    NUMBER_TAB,
    SOURCE		       VARCHAR2_30TAB,
    ESTIMATED_RATE	       NUMBER_TAB,
    CURRENCY_CODE	       CURRENCY_CODE_TAB,
    VEHICLE_ITEM_ID	       NUMBER_TAB,
    ESTIMATED_TRANSIT_TIME     NUMBER_TAB,
    TRANSIT_TIME_UOM	       TRANSIT_TIME_UOM_TAB,
    CONSIGNEE_CARRIER_AC_NO    NUMBER_TAB,
    FREIGHT_TERMS_CODE	       VARCHAR2_30TAB,
    ATTRIBUTE_CATEGORY         VARCHAR2_150TAB,
    ATTRIBUTE1                 VARCHAR2_150TAB,
    ATTRIBUTE2                 VARCHAR2_150TAB,
    ATTRIBUTE3                 VARCHAR2_150TAB,
    ATTRIBUTE4                 VARCHAR2_150TAB,
    ATTRIBUTE5                 VARCHAR2_150TAB,
    ATTRIBUTE6                 VARCHAR2_150TAB,
    ATTRIBUTE7                 VARCHAR2_150TAB,
    ATTRIBUTE8                 VARCHAR2_150TAB,
    ATTRIBUTE9                 VARCHAR2_150TAB,
    ATTRIBUTE10                VARCHAR2_150TAB,
    ATTRIBUTE11                VARCHAR2_150TAB,
    ATTRIBUTE12                VARCHAR2_150TAB,
    ATTRIBUTE13                VARCHAR2_150TAB,
    ATTRIBUTE14                VARCHAR2_150TAB,
    ATTRIBUTE15                VARCHAR2_150TAB,
    SCHEDULE_FROM	       DATE_TAB,
    SCHEDULE_TO		       DATE_TAB,
    SCHEDULE_ID		       NUMBER_TAB,
    VEHICLE_ORG_ID	       NUMBER_TAB,
    CALL_RG_FLAG	       CALL_RG_FLAG_TAB);


-- Global Cursor
PROCEDURE CREATE_RANK_LIST_BULK(
	p_api_version_number	IN		NUMBER,
	p_init_msg_list	        IN   		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_ranklist		IN OUT NOCOPY	carrier_rank_list_bulk_rec);



PROCEDURE RANK_LIST_ACTION(
	p_api_version_number	IN		NUMBER,
	p_init_msg_list	        IN   		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_action_code		IN		VARCHAR2,
	p_ranklist		IN OUT NOCOPY	carrier_rank_list_tbl_type,
	p_trip_id		IN		NUMBER,
	p_rank_id		IN		NUMBER);

PROCEDURE RANK_LIST_ACTION_UIWRAPPER(
	p_api_version_number	IN		NUMBER,
	p_init_msg_list	        IN   		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_action_code		IN		VARCHAR2,
	p_ranklist		IN OUT NOCOPY	FTE_SS_RATE_SORT_TAB_TYPE,
	p_trip_id		IN		NUMBER,
	p_rank_id		IN		NUMBER);

PROCEDURE DELETE_RANK_LIST_UIWRAPPER(
	p_api_version_number	IN		NUMBER,
	p_init_msg_list	        IN   		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_trip_id		IN		FTE_ID_TAB_TYPE);


PROCEDURE GET_RANK_DETAILS(
	p_init_msg_list	        IN   		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	x_rankdetails		OUT NOCOPY	carrier_rank_list_rec,
	p_rank_id		IN		NUMBER);

PROCEDURE GET_RANK_LIST(
	p_init_msg_list	        IN   		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	x_ranklist		OUT NOCOPY	carrier_rank_list_tbl_type,
	p_trip_id		IN		NUMBER);

PROCEDURE IS_RANK_LIST_EXHAUSTED(
	p_init_msg_list	        IN   		VARCHAR2,
	x_is_exhausted		OUT NOCOPY	VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_trip_id		IN		NUMBER);


PROCEDURE REMOVE_SERVICE_APPLY_NEXT(
	p_init_msg_list	        IN   		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_trip_id		IN		NUMBER,
	p_price_request_id	IN		NUMBER);


PROCEDURE PRINT_RANK_LIST(p_trip_id		IN		NUMBER);


END FTE_CARRIER_RANK_LIST_PVT;



 

/
