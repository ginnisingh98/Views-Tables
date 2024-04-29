--------------------------------------------------------
--  DDL for Package Body OKE_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DEBUG" AS
/* $Header: OKEDBGB.pls 115.2 2003/10/08 17:40:51 alaw noship $ */

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

    G_Debug_Mode := NVL( FND_PROFILE.VALUE('OKE_DEBUG_MODE') , 'N' );
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

    G_Module := nvl( module , nvl( G_Module , 'oke.plsql.generic' ) );

    FND_LOG.STRING( G_Log_Level , G_Module , text );

  END IF;

EXCEPTION
WHEN OTHERS THEN
  NULL;
END Debug;


END OKE_DEBUG;

/
