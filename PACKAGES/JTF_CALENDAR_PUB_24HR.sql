--------------------------------------------------------
--  DDL for Package JTF_CALENDAR_PUB_24HR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CALENDAR_PUB_24HR" AUTHID CURRENT_USER AS
/* $Header: jtfclpas.pls 120.3.12010000.2 2009/08/26 11:26:19 rkamasam ship $ */
/*#
 * Joint Task Force core Calendar Public API's.
 * This package is for finding the availability and working shift hours of a particular resource
 * during a specified period. This API support shifts beyond 24 hrs.
 * @rep:scope internal
 * @rep:product CAC
 * @rep:displayname JTF Calendar Public API
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_SCHEDULE
 */

-- ************************************************************************
-- Start of Comments
--     	Package Name	: JTF_CLAENDAR_PUB
--	Purpose		: Joint Task Force core Calendar Public API's
--			  This package is for finding the availability,
--			  working shift hours of a particular resource
--			  during a specified period
--	Procedures	: (See below for specification)
--	Notes		: This package is publicly available for use
--	History		: 09/29/99	VMOVVA		created
--                        06/16/03      ABRAINA         Fixed GSCC warning.
--                        08/11/03  ABRAINA         Added ResourceDt_To_ServerDT
--
-- End of Comments
-- ************************************************************************

  TYPE Shift_Rec_Type IS RECORD
   ( shift_construct_id 	NUMBER ,
     --shift_date			DATE,
     start_time			DATE,
     end_time			DATE,
     availability_type 		VARCHAR2(40)
   );

   TYPE Shift_Tbl_Type IS TABLE OF Shift_Rec_Type
	INDEX BY BINARY_INTEGER;

   -- Added by Sudhir  on 25/04/2002
   -- To return attribute1 - attribute15 in Get_Resource_Shifts API.
   TYPE Shift_Rec_Attributes_Type IS RECORD
   ( shift_construct_id 	NUMBER ,
     start_time			DATE,
     end_time			DATE,
     availability_type 		VARCHAR2(40),
     attribute1         	VARCHAR2(150),
     attribute2         	VARCHAR2(150),
     attribute3         	VARCHAR2(150),
     attribute4         	VARCHAR2(150),
     attribute5         	VARCHAR2(150),
     attribute6         	VARCHAR2(150),
     attribute7         	VARCHAR2(150),
     attribute8         	VARCHAR2(150),
     attribute9         	VARCHAR2(150),
     attribute10        	VARCHAR2(150),
     attribute11        	VARCHAR2(150),
     attribute12        	VARCHAR2(150),
     attribute13        	VARCHAR2(150),
     attribute14        	VARCHAR2(150),
     attribute15        	VARCHAR2(150)

   );

   TYPE Shift_Tbl_Attributes_Type IS TABLE OF Shift_Rec_Attributes_Type
      	INDEX BY BINARY_INTEGER;

-- ************************************************************************
-- Start of comments
--	API name 	: Get_Available Time
--	Type		: Public.
--	Function	: Get availability (Working Hours - Exception Hours
--                        - Task Assignment Hours) of a resource during the
--                        specified period
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version   	IN 	NUMBER	Required
--			  p_init_msg_list 	IN 	VARCHAR2 Optional
--					      	Default = FND_API.G_FALSE
--			  p_resource_id   	IN 	NUMBER   Required
--			  p_resource_type	IN	VARCHAR2 Required
--			  p_start_date	   	IN 	DATE
--			  p_end_date	   	IN 	DATE
--	OUT		: x_return_status 	OUT	VARCHAR2(1)
--			  x_msg_count	   	OUT	NUMBER
--			  x_msg_data	   	OUT	VARCHAR2(2000)
--			  x_shift	  	OUT	SHIFT_TBL_TYPE
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		:
--
-- End of comments
-- ************************************************************************
/*#
 * Get availabile time gets (Working Hours - Exception Hours - Task Assignment Hours)
 * of a resource during the specified period
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize message list flag
 * @param p_resource_id Search for Resource Id
 * @param p_resource_type Resource Type
 * @param p_start_date Search Start DateTime
 * @param p_end_date Search End DateTime
 * @param x_return_status API return status flag
 * @param x_msg_count API Error message count
 * @param x_msg_data API Error message data
 * @param x_shift Shift returned for a given resource
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Get Available Time
 */
 PROCEDURE Get_Available_Time
(	p_api_version         	IN	NUMBER		,
    	p_init_msg_list		IN	VARCHAR2:=FND_API.G_FALSE,
    	p_resource_id  		IN  	NUMBER			,
	p_resource_type		IN	VARCHAR2		,
	p_start_date		IN	DATE			,
	p_end_date		IN	DATE			,
    	x_return_status		OUT NOCOPY	VARCHAR2	,
    	x_msg_count		OUT NOCOPY	NUMBER		,
    	x_msg_data		OUT NOCOPY	VARCHAR2	,
	x_shift			OUT NOCOPY	SHIFT_TBL_TYPE
);
-- ************************************************************************
-- Start of comments
--	API name 	: Get_Available_Slot
--	Type		: Public.
--	Function	: Get available time slot of requested duration for
--			  the given resource during the specified period.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version   		IN 	NUMBER	Required
--			  p_init_msg_list 		IN 	VARCHAR2 Optional
--					      	Default = FND_API.G_FALSE
--			  p_resource_id   		IN 	NUMBER   Required
--			  p_resource_type		IN	VARCHAR2 Required
--			  p_start_date_time   		IN 	DATE
--                        p_end_date_time       	IN      DATE
--			  p_duration			IN	NUMBER   Required
--	OUT		: x_return_status		OUT	VARCHAR2(1)
--			  x_msg_count			OUT	NUMBER
--			  x_msg_data			OUT	VARCHAR2(2000)
--			  x_slot_start_date		OUT	DATE
--               	  x_slot_end_date       	OUT     DATE
--               	  x_shift_construct_id  	OUT     NUMBER
--               	  x_availability_type   	OUT     VARCHAR2
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		:
--
-- End of comments
-- ************************************************************************
/*#
 * Get available time slot of requested duration for the given resource during
 * the specified period.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize message list flag
 * @param p_resource_id Search for Resource Id
 * @param p_resource_type Resource Type
 * @param p_start_date_time Search Start DateTime
 * @param p_end_date_time Search End DateTime
 * @param p_duration Search duration
 * @param x_return_status API return status flag
 * @param x_msg_count API Error message count
 * @param x_msg_data API Error message data
 * @param x_slot_start_date Returned slot start DateTime
 * @param x_slot_end_date Returned slot end DateTime
 * @param x_shift_construct_id Returned shift construct ID
 * @param x_availability_type  Returned availabilty type
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Get Available Slot
 */
PROCEDURE Get_Available_Slot
(	p_api_version         	IN	NUMBER			,
        p_init_msg_list		IN	VARCHAR2:=FND_API.G_FALSE,
    	p_resource_id   	IN  	NUMBER			,
	p_resource_type		IN	VARCHAR2		,
	p_start_date_time	IN	DATE			,
	p_end_date_time		IN	DATE			,
	p_duration		IN	NUMBER	     		,
    	x_return_status		OUT NOCOPY	VARCHAR2	 	,
    	x_msg_count		OUT NOCOPY	NUMBER      		,
    	x_msg_data		OUT NOCOPY	VARCHAR2		,
	x_slot_start_date	OUT NOCOPY	DATE			,
        x_slot_end_date         OUT NOCOPY     DATE			,
        x_shift_construct_id   	OUT NOCOPY     NUMBER         		,
        x_availability_type    	OUT NOCOPY    VARCHAR2
);
-- ************************************************************************
-- Start of comments
--	API name 	: Get_Resource_Shifts
--	Type		: Public.
--	Function	: Get the availability (Working Hours - Exception Hours)
--                        of a resource during the specified period
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version   	IN 	NUMBER	Required
--			  p_init_msg_list 	IN 	VARCHAR2 Optional
--					      	Default = FND_API.G_FALSE
--			  p_resource_id   	IN 	NUMBER   Required
--			  p_resource_type	IN	VARCHAR2 Required
--			  p_start_date	   	IN 	DATE
--			  p_end_date	   	IN 	DATE
--	OUT		: x_return_status 	OUT	VARCHAR2(1)
--			  x_msg_count	   	OUT	NUMBER
--			  x_msg_data	   	OUT	VARCHAR2(2000)
--			  x_shift	   		OUT	SHIFT_TBL_TYPE
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		:
--
-- End of comments
-- ************************************************************************

PROCEDURE Get_Resource_Shifts
(	p_api_version         	IN	NUMBER		,
    	p_init_msg_list		IN	VARCHAR2:=FND_API.G_FALSE,
    	p_resource_id  		IN  	NUMBER			,
	p_resource_type		IN	VARCHAR2		,
	p_start_date		IN	DATE			,
	p_end_date		IN	DATE			,
    	x_return_status		OUT NOCOPY	VARCHAR2	 	,
    	x_msg_count		OUT NOCOPY	NUMBER			,
    	x_msg_data		OUT NOCOPY	VARCHAR2		,
	x_shift			OUT NOCOPY	SHIFT_TBL_TYPE
);

-- ************************************************************************
-- Start of comments
--	API name 	: Get_Resource_Shifts
--	Type		: Public.
--	Function	: Get the availability (Working Hours - Exception Hours)
--                        of a resource during the specified period to return attributes
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version   	IN 	NUMBER	Required
--			  p_init_msg_list 	IN 	VARCHAR2 Optional
--					      	Default = FND_API.G_FALSE
--			  p_resource_id   	IN 	NUMBER   Required
--			  p_resource_type	IN	VARCHAR2 Required
--			  p_start_date	   	IN 	DATE
--			  p_end_date	   	IN 	DATE
--	OUT		: x_return_status 	OUT	VARCHAR2(1)
--			  x_msg_count	   	OUT	NUMBER
--			  x_msg_data	   	OUT	VARCHAR2(2000)
--			  x_shift	   	OUT	SHIFT_TBL_ATTRIBUTES_TYPE
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		:
--
-- End of comments

-- ************************************************************************
/*#
 * Get the availability (Working Hours - Exception Hours) of a resource during
 * the specified period
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize message list flag
 * @param p_resource_id Search for Resource Id
 * @param p_resource_type Resource Type
 * @param p_start_date Search Start DateTime
 * @param p_end_date Search End DateTime
 * @param x_return_status API return status flag
 * @param x_msg_count API Error message count
 * @param x_msg_data API Error message data
 * @param x_shift Shift returned with attributes for a given resource
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Get Resource Shift with attributes
 */
PROCEDURE Get_Resource_Shifts
(	p_api_version         	IN	NUMBER		,
    	p_init_msg_list		IN	VARCHAR2:=FND_API.G_FALSE,
    	p_resource_id  		IN  	NUMBER			,
	p_resource_type		IN	VARCHAR2		,
	p_start_date		IN	DATE			,
	p_end_date		IN	DATE			,
    	x_return_status		OUT NOCOPY	VARCHAR2	 	,
    	x_msg_count		OUT NOCOPY	NUMBER			,
    	x_msg_data		OUT NOCOPY	VARCHAR2		,
	x_shift			OUT NOCOPY	SHIFT_TBL_ATTRIBUTES_TYPE
);

-- ************************************************************************
-- Start of comments
--	API name 	: Is_Res_Available
--	Type		: Public.
--	Function	: Determine whether the given resource is
--			  available during the specified period.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version   	IN 	NUMBER	Required
--			  p_init_msg_list 	IN 	VARCHAR2 Optional
--					      	Default = FND_API.G_FALSE
--			  p_resource_id   	IN 	NUMBER   Required
--			  p_resource_type	IN	VARCHAR2 Required
--			  p_start_date_time   	IN 	DATE
--			  p_duration		IN	NUMBER   Required
--	OUT		: x_return_status	OUT	VARCHAR2(1)
--			  x_msg_count		OUT	NUMBER
--			  x_msg_data		OUT	VARCHAR2(2000)
--			  x_avail		OUT   	VARCHAR2
--	Version		: Current version	1.0
--			  	  Initial version 	1.0
--
--	Notes		:
--
-- End of comments
-- ************************************************************************
/*#
 * Determine whether the given resource is available during the specified period.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize message list flag
 * @param p_resource_id Search for Resource Id
 * @param p_resource_type Resource Type
 * @param p_start_date_time Search Start DateTime
 * @param p_duration Search Duration
 * @param x_return_status API return status flag
 * @param x_msg_count API Error message count
 * @param x_msg_data API Error message data
 * @param x_avail Resource availabilty confirmation flag
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Is Resource Available
 */
PROCEDURE Is_Res_Available
(	p_api_version         	IN	NUMBER				,
        p_init_msg_list		IN	VARCHAR2:=FND_API.G_FALSE	,
    	p_resource_id   	     IN  	NUMBER		,
	p_resource_type		IN	VARCHAR2		,
	p_start_date_time	     IN	DATE			,
	p_duration		     IN	NUMBER		,
    	x_return_status		OUT NOCOPY	VARCHAR2	 	,
    	x_msg_count		     OUT NOCOPY	NUMBER		,
    	x_msg_data		     OUT NOCOPY	VARCHAR2		,
	x_avail			     OUT NOCOPY	varchar2
);
-- ************************************************************************
-- Start of comments
--	API name 	: Get_Res_Schedule
--	Type		: Public.
--	Function	: Get the working, exception, assigned Task hours for
--                        a given Resource in the given date range.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version   	IN 	NUMBER	Required
--			  p_init_msg_list 	IN 	VARCHAR2 Optional
--					      	Default = FND_API.G_FALSE
--			  p_resource_id   	IN 	NUMBER   Required
--			  p_resource_type	IN	VARCHAR2 Required
--			  p_start_date   	IN 	DATE
--			  p_end_date		IN	DATE
--			  p_duration		IN	NUMBER   Required
--	OUT		: x_return_status	OUT	VARCHAR2(1)
--			  x_msg_count		OUT	NUMBER
--			  x_msg_data		OUT	VARCHAR2(2000)
--			  x_shift		OUT	SHIFT_TBL_TYPE
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		:
--
-- End of comments
-- ************************************************************************
/*#
 * Get the working, exception, assigned Task hours for a given Resource in the
 * given date range.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize message list flag
 * @param p_resource_id Search for Resource Id
 * @param p_resource_type Resource Type
 * @param p_start_date Search Start DateTime
 * @param p_end_date Search End DateTime
 * @param x_return_status API return status flag
 * @param x_msg_count API Error message count
 * @param x_msg_data API Error message data
 * @param x_shift Shift returned for a given resource
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Get Resource Schedule
 */
PROCEDURE Get_Res_Schedule
(	p_api_version         	IN	NUMBER		,
        p_init_msg_list		IN	VARCHAR2:=FND_API.G_FALSE,
        p_resource_id   	IN      NUMBER			,
	p_resource_type		IN	VARCHAR2		,
	p_start_date		IN	DATE			,
	p_end_date		IN	DATE			,
        x_return_status		OUT NOCOPY	VARCHAR2	 	,
        x_msg_count		OUT NOCOPY	NUMBER			,
        x_msg_data		OUT NOCOPY	VARCHAR2		,
	x_shift			OUT NOCOPY	SHIFT_TBL_TYPE
);
-- ************************************************************************
-- Start of comments
--	API name 	: get_g_false
--	Type		: Public.
--	Function	: Used as a wrapper function to get FND_API.G_FALSE.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: None.
--	OUT		: None.
--      RETURN          : FND_API.G_FALSE VARCHAR2
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		:
--
-- End of comments
-- ************************************************************************

FUNCTION get_g_false return varchar2;

-- ************************************************************************
-- Start of comments
--	API name 	: get_g_miss_num
--	Type		: Public.
--	Function	: Used as a wrapper function to get FND_API.G_MISS_NUM.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: None.
--	OUT		: None.
--      RETURN          : FND_API.G_MISS_NUM NUMBER
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		:
--
-- End of comments
-- ************************************************************************

FUNCTION get_g_miss_num return number;

-- ************************************************************************
-- Start of comments
--	API name 	: get_g_miss_char
--	Type		: Public.
--	Function	: Used as a wrapper function to get FND_API.G_MISS_CHAR.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: None.
--	OUT		: None.
--      RETURN          : FND_API.G_MISS_CHAR VARCHAR2
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		:
--
-- End of comments
-- ************************************************************************

FUNCTION get_g_miss_char return varchar2;

-- ************************************************************************
-- Start of comments
--	API name 	: get_g_miss_date
--	Type		: Public.
--	Function	: Used as a wrapper function to get FND_API.G_MISS_DATE.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: None.
--	OUT		: None.
--      RETURN          : FND_API.G_MISS_DATE DATE
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		:
--
-- End of comments
-- ************************************************************************

FUNCTION get_g_miss_date return date;

-- ************************************************************************
-- Start of comments
--      API name        : check_resource_status
--      Type            : Public.
--      Function        : Used to validate a given resource_id and type with
--                        respect to active dates.
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_resource_id   IN NUMBER   Required
--                      : p_resource_type IN VARCHAR2 Required
--      OUT             : None.
--      RETURN          : BOOLEAN
--      Version         : Current version       1.0
--                        Initial version       1.0
--
--      Notes           :
--
-- End of comments
-- ************************************************************************

--Comment out by jawang on 06/18/2002 for ARU 2416495
--FUNCTION check_resource_status(p_resource_id IN NUMBER,p_resource_type IN VARCHAR2) RETURN BOOLEAN;

-- ************************************************************************
-- Start of comments
--	API name 	: ResourceDt_To_ServerDT
--	Type		: Public.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: None.
--	OUT		: None.
--    RETURN      : FND_API.G_MISS_DATE DATE
--	Version	: Current version	1.0
--	  		  Initial version 1.0
--
--	Notes		: Create Function for timezone conversion form
--                  resource timezone to server timezone.
--                  Added for Simplex Timezone Enh # 3034073 by ABRAINA
--
-- End of comments
-- ************************************************************************

Function ResourceDt_To_ServerDT ( P_Resource_DtTime IN date, P_Resource_TZ_Id IN Number , p_Server_TZ_id IN Number ) RETURN date ;
Function Get_Res_Timezone_Id ( P_Resource_Id IN Number , p_resource_type IN VARCHAR2 ) RETURN Number ;
Function Validate_Cal_Date ( P_Calendar_Id IN Number, P_shift_date IN Date ) RETURN Boolean ;
END;

/
