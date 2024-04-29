--------------------------------------------------------
--  DDL for Package FTE_MOVES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_MOVES_PVT" AUTHID CURRENT_USER AS
/* $Header: FTEMVTHS.pls 120.0 2005/05/26 18:23:31 appldev noship $ */

   c_sdebug    CONSTANT NUMBER := wsh_debug_sv.c_level1;
   c_debug     CONSTANT NUMBER := wsh_debug_sv.c_level2;

--
-- Type: 		Fte Moves Rectype
-- Definition:		In sync with the table definition for trips
-- Use:			In table handlers, calling packages


TYPE MOVE_REC_TYPE IS RECORD (
	 MOVE_ID                              	  FTE_MOVES.MOVE_ID%TYPE,
	 MOVE_TYPE_CODE				  FTE_MOVES.MOVE_TYPE_CODE%TYPE,
	 LANE_ID				  FTE_MOVES.LANE_ID%TYPE,
	 SERVICE_LEVEL				  FTE_MOVES.SERVICE_LEVEL%TYPE,
	 PLANNED_FLAG				  FTE_MOVES.PLANNED_FLAG%TYPE,
	 CM_TRIP_NUMBER				  FTE_MOVES.CM_TRIP_NUMBER%TYPE,
	 TP_PLAN_NAME				  FTE_MOVES.TP_PLAN_NAME%TYPE,
	 CREATION_DATE                            DATE,
	 CREATED_BY                               NUMBER,
	 LAST_UPDATE_DATE                         DATE,
	 LAST_UPDATED_BY                          NUMBER,
	 LAST_UPDATE_LOGIN                        NUMBER,
	 PROGRAM_APPLICATION_ID                   NUMBER,
	 PROGRAM_ID                               NUMBER,
	 PROGRAM_UPDATE_DATE                      DATE,
	 REQUEST_ID                               NUMBER,
	 ATTRIBUTE_CATEGORY                       VARCHAR2(150),
	 ATTRIBUTE1                               VARCHAR2(150),
	 ATTRIBUTE2                               VARCHAR2(150),
	 ATTRIBUTE3                               VARCHAR2(150),
	 ATTRIBUTE4                               VARCHAR2(150),
	 ATTRIBUTE5                               VARCHAR2(150),
	 ATTRIBUTE6                               VARCHAR2(150),
	 ATTRIBUTE7                               VARCHAR2(150),
	 ATTRIBUTE8                               VARCHAR2(150),
	 ATTRIBUTE9                               VARCHAR2(150),
	 ATTRIBUTE10                              VARCHAR2(150),
	 ATTRIBUTE11                              VARCHAR2(150),
	 ATTRIBUTE12                              VARCHAR2(150),
	 ATTRIBUTE13                              VARCHAR2(150),
	 ATTRIBUTE14                              VARCHAR2(150),
	 ATTRIBUTE15                              VARCHAR2(150)
);


-- Table of MOVES_REC_TYPE
TYPE MOVE_ATTR_TBL_TYPE is TABLE of MOVE_REC_TYPE INDEX BY BINARY_INTEGER;



--
--  Procedure:          Create_Move
--  Parameters:         Move Record info; rowid, move_id, name, return_status as OUT
--  Description:        This procedure will create a move. It will
--                      return to the user the move_id and generates a name if
--				    move name is not specified.
--

PROCEDURE CREATE_MOVE(
	p_init_msg_list	        IN   		VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_move_info		IN  		MOVE_REC_TYPE,
	x_move_id		OUT NOCOPY  	NUMBER,
	x_return_status		OUT NOCOPY 	VARCHAR2
);


--
--  Procedure:          Delete_move
--  Parameters:         Row_id, move_id, return_status and validate_flag
--  Description:        This procedure will delete a move. If rowid is not null
--				    move_id is found, and move_id is used to delete move.
--                      validate_flag - 'Y' means check_delete_move is called
--

PROCEDURE DELETE_MOVE(
	p_init_msg_list	        IN   		VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_move_id	     	IN	NUMBER,
	p_validate_flag 	IN  	VARCHAR2 DEFAULT 'Y',
	x_return_status		OUT 	NOCOPY 	VARCHAR2
);


--
--  Procedure:          Update_move
--  Parameters:         move rowid, move Record info and return_status
--  Description:        This procedure will update a move.
--

PROCEDURE UPDATE_MOVE(
	p_init_msg_list	        IN   		VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_move_info		IN		move_rec_type,
	x_return_status		OUT NOCOPY 	VARCHAR2
);


--
--  Procedure:          MARK_MOVE_REPRICE_FLAG
--  Parameters:         move rowid, x_return_status,x_return_msg,x_return_data
--  Description:        This procedure will mark reprice flag for all the trips in the move. This
--			procedure can be called to set reprice flag if move is CM is dissolved.
--


PROCEDURE MARK_MOVE_REPRICE_FLAG(
	p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_MOVE_id       IN NUMBER,
        x_return_status OUT     NOCOPY  VARCHAR2,
        x_msg_count    OUT     NOCOPY  VARCHAR2,
        x_msg_data   OUT     NOCOPY  VARCHAR2);


--
--  Procedure:          Lock_move
--  Parameters:         move rowid, move Record info and return_status
--  Description:        This procedure will lock a move row.
--
/**
PROCEDURE LOCK_MOVE(
	p_rowid			IN	VARCHAR2,
	p_move_info		IN	move_rec_type
	x_return_status		OUT NOCOPY 	VARCHAR2
);

--
--  PROCEDURE:          Populate_Record
--  Parameters:         MOVE id as IN, MOVE Record info and return status as OUT
--  Description:        This PROCEDURE will populate a MOVE Record.
--

PROCEDURE POPULATE_RECORD(
	p_MOVE_id			IN	NUMBER,
	x_MOVE_info		OUT NOCOPY 	MOVE_rec_type,
	x_return_status	OUT NOCOPY 	VARCHAR2);


--
--  Function:		Get_Name
--  Parameters:		p_MOVE_id - Id for MOVE
--  Description:	This PROCEDURE will return MOVE Name for a MOVE Id
--


FUNCTION Get_Name
	(p_MOVE_id		IN	NUMBER
	 ) RETURN VARCHAR2;


--
--  PROCEDURE:   Lock_MOVE Wrapper
--  Parameters:  A table of all Attributes of a MOVE Record,
--               Caller in
--               Return_Status,Valid_index_id_tab out
--  Description: This PROCEDURE will lock multiple MOVEs.
PROCEDURE Lock_MOVE(
	p_rec_attr_tab		IN		MOVE_Attr_Tbl_Type,
        p_caller		IN		VARCHAR2,
        p_valid_index_tab       IN              WSH_UTIL_CORE.ID_TAB_TYPE,
        x_valid_ids_tab         OUT             NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
	x_return_status		OUT		NOCOPY VARCHAR2
);
*/

END FTE_MOVES_PVT;



 

/
