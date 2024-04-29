--------------------------------------------------------
--  DDL for Package FTE_TRIP_MOVES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_TRIP_MOVES_PVT" AUTHID CURRENT_USER AS
/* $Header: FTEMTTHS.pls 115.1 2003/09/12 02:23:51 wrudge noship $ */

   c_sdebug    CONSTANT NUMBER := wsh_debug_sv.c_level1;
   c_debug     CONSTANT NUMBER := wsh_debug_sv.c_level2;

--
-- Type: 		TRIP_MOVES
-- Definition:		In sync with the table definition for trip moves
-- Use:			In table handlers, calling packages


TYPE TRIP_MOVES_REC_TYPE IS RECORD (
	 MOVE_ID			NUMBER,
	 TRIP_ID	                NUMBER,
	 SEQUENCE_NUMBER                NUMBER,
	 TRIP_MOVE_ID			NUMBER,
	 CREATION_DATE                  DATE,
	 CREATED_BY                     NUMBER,
	 LAST_UPDATE_DATE               DATE,
	 LAST_UPDATED_BY                NUMBER,
	 LAST_UPDATE_LOGIN              NUMBER,
	 PROGRAM_APPLICATION_ID         NUMBER,
	 PROGRAM_ID                     NUMBER,
	 PROGRAM_UPDATE_DATE            DATE,
	 REQUEST_ID                     NUMBER,
	 ATTRIBUTE_CATEGORY             VARCHAR2(150),
	 ATTRIBUTE1                     VARCHAR2(150),
	 ATTRIBUTE2                     VARCHAR2(150),
	 ATTRIBUTE3                     VARCHAR2(150),
	 ATTRIBUTE4                     VARCHAR2(150),
	 ATTRIBUTE5                     VARCHAR2(150),
	 ATTRIBUTE6                     VARCHAR2(150),
	 ATTRIBUTE7                     VARCHAR2(150),
	 ATTRIBUTE8                     VARCHAR2(150),
	 ATTRIBUTE9                     VARCHAR2(150),
	 ATTRIBUTE10                    VARCHAR2(150),
	 ATTRIBUTE11                    VARCHAR2(150),
	 ATTRIBUTE12                    VARCHAR2(150),
	 ATTRIBUTE13                    VARCHAR2(150),
	 ATTRIBUTE14                    VARCHAR2(150),
	 ATTRIBUTE15                    VARCHAR2(150)
);


-- Table of MOVES_REC_TYPE
TYPE TRIP_MOVE_ATTR_TBL_TYPE is TABLE of TRIP_MOVES_REC_TYPE INDEX BY BINARY_INTEGER;


--
--  Procedure:          CREATE_TRIP_MOVES
--  Parameters: 	p_trip_info	Trip Record info
--			x_return_status	return_status
--  Description:        This procedure will create a fte_wsh_trip.
--

PROCEDURE CREATE_TRIP_MOVES
(
	p_init_msg_list	        IN   		VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_trip_moves_info	IN		TRIP_MOVES_REC_TYPE,
	x_trip_move_id		OUT NOCOPY	NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2
);

--
--  Procedure:          UPDATE_TRIP_MOVES
--  Parameters: 	p_trip__moves_info	Trip Moves Record info
-- 			p_validate_flag	'Y' validate before update
--			x_return_status	return_status
--  Description:        This procedure will update a FTE_TRIP_MOVES.
--

PROCEDURE UPDATE_TRIP_MOVES
(
	p_init_msg_list	        IN 		VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_trip_moves_info	IN		TRIP_MOVES_REC_TYPE,
	x_return_status		OUT NOCOPY	VARCHAR2
);


--
--  Procedure:          DELETE_TRIP_MOVES
--  Parameters: 	p_trip_move_id
--			x_return_status	return_status
--  Description:        This procedure will delete trip_moves.
--

PROCEDURE DELETE_TRIP_MOVES
(
	p_init_msg_list	        IN 		VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_trip_move_id	     	IN		NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2
);



--
--  Procedure:          Lock_trip_move
--  Parameters:         move rowid, trip move Record info and return_status
--  Description:        This procedure will lock a move row.
--

/**
PROCEDURE LOCK_TRIP_MOVES(
	p_rowid			IN	VARCHAR2,
	p_trip_move_info	IN	TRIP_MOVES_REC_TYPE
	x_return_status		OUT NOCOPY	VARCHAR2
);
*/

--
--  PROCEDURE:   LOCK_MOVE Wrapper
--  Parameters:  A table of all Attributes of a MOVE Record,
--               Caller in
--               Return_Status,Valid_index_id_tab out
--  Description: This PROCEDURE will lock multiple MOVEs.
/**
PROCEDURE LOCK_TRIP_MOVES(
	p_rec_attr_tab		IN		TRIP_MOVE_ATTR_TBL_TYPE,
        p_caller		IN		VARCHAR2,
        p_valid_index_tab       IN              WSH_UTIL_CORE.ID_TAB_TYPE,
        x_valid_ids_tab         OUT             NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
	x_return_status		OUT NOCOPY	VARCHAR2
);
*/

END FTE_TRIP_MOVES_PVT;

 

/
