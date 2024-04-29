--------------------------------------------------------
--  DDL for Package Body BIS_ERROR_MESSAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_ERROR_MESSAGE_PVT" AS
/* $Header: BISVERMB.pls 115.6 2002/12/16 10:25:36 rchandra ship $ */
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
G_PKG_NAME CONSTANT VARCHAR(30) := 'bis_ERROR_MESSAGE_PVT';
g_gen_error_tbl     BIS_UTILITIES_PUB.Error_Tbl_Type;
-- ============================================================================
--PROCEDURE : Init_Log
--PARAMETERS
--  1. x_return_status    error or normal
--  2. x_error_Tbl        table of error messages

--COMMENT   : Call this function to start logging the messages
--RETURN    : None
--EXCEPTION : None
-- ============================================================================

PROCEDURE init_log
IS

l_return_status VARCHAR2(10);
l_error_Tbl     BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  init_log(l_return_status, l_error_Tbl);
END init_log;

PROCEDURE init_log
( x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  g_gen_error_tbl.DELETE;
END init_log;

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
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  g_gen_error_tbl(g_gen_error_tbl.COUNT + 1) := p_err_rec;
END update_error_log;

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
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  for i in 1 .. p_err_tbl.COUNT LOOP
    g_gen_error_tbl(g_gen_error_tbl.COUNT + 1) := p_err_tbl(i);
  END LOOP;
END update_error_log;

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
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_error_count := g_gen_error_tbl.COUNT;
END get_Error_count;

-- ============================================================================
--PROCEDURE : get_Error_count
--COMMENT   : Call this function to log failed generation
--RETURN    : None
--EXCEPTION : None
-- ============================================================================
PROCEDURE get_Error_tbl
( x_error_tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_error_tbl := g_gen_error_tbl;
END get_Error_tbl;
--
END BIS_ERROR_MESSAGE_PVT;

/
