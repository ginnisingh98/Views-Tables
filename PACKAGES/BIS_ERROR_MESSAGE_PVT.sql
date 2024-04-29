--------------------------------------------------------
--  DDL for Package BIS_ERROR_MESSAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_ERROR_MESSAGE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVERMS.pls 115.7 2002/12/16 10:25:39 rchandra ship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVERMS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Privvate API for keeping track of error messages
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 09-Apr-99 ansingha Creation
REM |
REM +=======================================================================+
*/
--
--
-- ============================================================================
--PROCEDURE : Init_Log
--PARAMETERS
--  1. x_return_status    error or normal
--  2. x_error_Tbl        table of error messages

--COMMENT   : Call this function to start logging the messages
--RETURN    : None
--EXCEPTION : None
-- ============================================================================

PROCEDURE init_log;

PROCEDURE init_log
( x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- ============================================================================
--PROCEDURE : Update_Error_Log
--PARAMETERS: 1. p_errm   - error message
--            2. x_return_status    error or normal
--            3. x_error_Tbl        table of error messages
--COMMENT   : Call this function to log failed generation
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE update_error_log
( p_err_rec             IN  BIS_UTILITIES_PUB.Error_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- ============================================================================
--PROCEDURE : Update_Error_Log
--PARAMETERS: 1. p_errm   - error message
--            2. x_return_status    error or normal
--            3. x_error_Tbl        table of error messages
--COMMENT   : Call this function to log failed generation
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE update_error_log
( p_err_tbl             IN  BIS_UTILITIES_PUB.Error_tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- ============================================================================
--PROCEDURE : get_Error_count
--COMMENT   : Call this function to log failed generation
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE get_Error_count
( x_error_count         OUT NOCOPY NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
-- ============================================================================
--PROCEDURE : get_Error_count
--COMMENT   : Call this function to log failed generation
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE get_Error_tbl
( x_error_tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
END BIS_ERROR_MESSAGE_PVT;

 

/
