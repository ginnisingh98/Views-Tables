--------------------------------------------------------
--  DDL for Package FTE_WSH_TRIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_WSH_TRIPS_PVT" AUTHID CURRENT_USER AS
/* $Header: FTEFWTHS.pls 115.7 2002/12/03 21:49:33 hbhagava noship $ */

   c_sdebug    CONSTANT NUMBER := wsh_debug_sv.c_level1;
   c_debug     CONSTANT NUMBER := wsh_debug_sv.c_level2;

--
-- Type: 			Trip_Rectype
-- Definition:		In sync with the table definition for trips
-- Use:			In table handlers, calling packages


TYPE fte_wsh_trip_rec_type IS RECORD (
 FTE_TRIP_ID			NUMBER DEFAULT FND_API.G_MISS_NUM,
 WSH_TRIP_ID                    NUMBER DEFAULT FND_API.G_MISS_NUM,
 SEQUENCE_NUMBER                NUMBER DEFAULT FND_API.G_MISS_NUM,
 CREATION_DATE                  DATE DEFAULT FND_API.G_MISS_DATE,
 CREATED_BY                     NUMBER DEFAULT FND_API.G_MISS_NUM,
 LAST_UPDATE_DATE               DATE DEFAULT FND_API.G_MISS_DATE,
 LAST_UPDATED_BY                NUMBER DEFAULT FND_API.G_MISS_NUM,
 LAST_UPDATE_LOGIN              NUMBER DEFAULT FND_API.G_MISS_NUM,
 PROGRAM_APPLICATION_ID         NUMBER DEFAULT FND_API.G_MISS_NUM,
 PROGRAM_ID                     NUMBER DEFAULT FND_API.G_MISS_NUM,
 PROGRAM_UPDATE_DATE            DATE DEFAULT FND_API.G_MISS_DATE,
 REQUEST_ID                     NUMBER DEFAULT FND_API.G_MISS_NUM,
 ATTRIBUTE_CATEGORY             VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE1                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE2                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE3                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE4                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE5                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE6                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE7                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE8                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE9                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE10                    VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE11                    VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE12                    VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE13                    VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE14                    VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 ATTRIBUTE15                    VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR
);


--
--  Procedure:          Validate_Trip
--  Parameters: 	p_trip_info	Trip Record info
--              	p_action_code   'CREATE' or 'UPDATE'
--			x_return_status	return_status
--  Description:        This procedure will validate a fte_wsh_trip.
--

PROCEDURE Validate_Trip
(
	p_trip_info	     	IN	fte_wsh_trip_rec_type,
	p_action_code		IN 	VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2
);

--
--  Procedure:          Create_Trip
--  Parameters: 	p_trip_info	Trip Record info
--			x_return_status	return_status
--  Description:        This procedure will create a fte_wsh_trip.
--

PROCEDURE Create_Trip
(
	p_trip_info	     	IN	fte_wsh_trip_rec_type,
	x_return_status		OUT NOCOPY	VARCHAR2
);

--
--  Procedure:          Update_Trip
--  Parameters: 	p_trip_info	Trip Record info
-- 			p_validate_flag	'Y' validate before update
--			x_return_status	return_status
--  Description:        This procedure will update a fte_wsh_trip.
--

PROCEDURE Update_Trip
(
	p_trip_info	     	IN	fte_wsh_trip_rec_type,
	p_validate_flag		IN	VARCHAR2 DEFAULT 'Y',
	x_return_status		OUT NOCOPY	VARCHAR2
);

--
--  Procedure:          Delete_Trip
--  Parameters: 	p_fte_trip_id
--			p_wsh_trip_id
--			x_return_status	return_status
--  Description:        This procedure will create a fte_wsh_trip.
--

PROCEDURE Validate_Trip_For_Delete
(
	P_init_msg_list	        IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_fte_trip_id	     	IN	NUMBER,
	p_wsh_trip_id	     	IN	NUMBER,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2
);

--
--  Procedure:          Delete_Trip
--  Parameters: 	p_fte_trip_id
--			p_wsh_trip_id
--			x_return_status	return_status
--  Description:        This procedure will create a fte_wsh_trip.
--

PROCEDURE Delete_Trip
(
	P_init_msg_list	        IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_fte_trip_id	     	IN	NUMBER,
	p_wsh_trip_id	     	IN	NUMBER,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2
);

--
--  Procedure:          Create_Update_Trip
--  Description:        Wrapper around Create_Trip and Update_Trip
-- 			depends on the p_action_code 'CREATE' or 'UPDATE'
--

PROCEDURE Validate_Trip_Wrapper
(
 pp_FTE_TRIP_ID			IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_WSH_TRIP_ID                 IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_SEQUENCE_NUMBER             IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_CREATION_DATE               IN   DATE DEFAULT FND_API.G_MISS_DATE,
 pp_CREATED_BY                  IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_LAST_UPDATE_DATE            IN   DATE DEFAULT FND_API.G_MISS_DATE,
 pp_LAST_UPDATED_BY             IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_LAST_UPDATE_LOGIN           IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_PROGRAM_APPLICATION_ID      IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_PROGRAM_ID                  IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_PROGRAM_UPDATE_DATE         IN   DATE DEFAULT FND_API.G_MISS_DATE,
 pp_REQUEST_ID                  IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_ATTRIBUTE_CATEGORY          IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE1                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE2                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE3                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE4                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE5                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE6                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE7                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE8                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE9                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE10                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE11                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE12                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE13                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE14                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE15                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	P_init_msg_list	        IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_action_code		IN 	VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2
);

--
--  Procedure:          Create_Update_Trip_Wrapper
--  Description:        Wrapper around Create_Trip and Update_Trip
-- 			depends on the p_action_code 'CREATE' or 'UPDATE'
--

PROCEDURE Create_Update_Trip_Wrapper
(
 pp_FTE_TRIP_ID			IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_WSH_TRIP_ID                 IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_SEQUENCE_NUMBER             IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_CREATION_DATE               IN   DATE DEFAULT FND_API.G_MISS_DATE,
 pp_CREATED_BY                  IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_LAST_UPDATE_DATE            IN   DATE DEFAULT FND_API.G_MISS_DATE,
 pp_LAST_UPDATED_BY             IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_LAST_UPDATE_LOGIN           IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_PROGRAM_APPLICATION_ID      IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_PROGRAM_ID                  IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_PROGRAM_UPDATE_DATE         IN   DATE DEFAULT FND_API.G_MISS_DATE,
 pp_REQUEST_ID                  IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
 pp_ATTRIBUTE_CATEGORY          IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE1                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE2                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE3                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE4                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE5                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE6                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE7                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE8                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE9                  IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE10                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE11                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE12                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE13                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE14                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 pp_ATTRIBUTE15                 IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	P_init_msg_list	        IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_action_code		IN 	VARCHAR2,
	p_validate_flag		IN	VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2
);

END fte_wsh_trips_pvt;

 

/
