--------------------------------------------------------
--  DDL for Package Body PJM_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_DEBUG" AS
/* $Header: PJMDBGB.pls 115.3 2003/07/09 22:09:07 alaw noship $ */

--
-- Debugger Globals
--
G_User_ID        NUMBER          := NULL;
G_Debug_Mode     VARCHAR2(1)     := NULL;
G_Module         VARCHAR2(240);
G_Log_Level      NUMBER;
G_Runtime_Level  NUMBER          := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

-- -------------------------------------------------------------------
-- PL/SQL Server Debugger
-- -------------------------------------------------------------------

--
-- This procedure forces the current session into debug mode regardless
-- of the user profile setting
--
PROCEDURE Enable_Debug IS
BEGIN
  G_User_ID    := FND_GLOBAL.User_ID;
  G_Debug_Mode := 'Y';
END Enable_Debug;


--
-- This procedure forces the current session out of debug mode regardless
-- of the user profile setting
--
PROCEDURE Disable_Debug IS
BEGIN
  G_User_ID    := FND_GLOBAL.User_ID;
  G_Debug_Mode := 'N';
END Disable_Debug;


--
-- This function checks for debug mode setting.
--
FUNCTION Debug_Mode
RETURN VARCHAR2 IS
BEGIN

  IF (  G_Debug_Mode IS NULL
     OR G_User_ID <> FND_GLOBAL.User_ID ) THEN

    G_Debug_Mode := NVL( FND_PROFILE.VALUE('PJM_DEBUG_MODE') , 'N' );
    G_User_ID := FND_GLOBAL.User_ID;

  END IF;

  RETURN ( G_Debug_Mode );

EXCEPTION
  WHEN OTHERS THEN
    RETURN ( 'N' );

END Debug_Mode;


PROCEDURE Debug
( text       IN  VARCHAR2
, module     IN  VARCHAR2
, log_level  IN  NUMBER
) IS

BEGIN

  G_Log_Level := nvl( log_level , FND_LOG.LEVEL_STATEMENT );

  IF ( G_Log_Level >= G_Runtime_Level OR Debug_Mode = 'Y' ) THEN

    G_Module := nvl( module , nvl( G_Module , 'pjm.plsql.generic' ) );

    FND_LOG.STRING( G_Log_Level , G_Module , text );

  END IF;

EXCEPTION
WHEN OTHERS THEN
  NULL;
END Debug;


--
-- This procedure is obsolete and will do nothing
--
PROCEDURE Indent ( level IN  NUMBER ) IS
BEGIN
  NULL;
END Indent;

END PJM_DEBUG;

/
