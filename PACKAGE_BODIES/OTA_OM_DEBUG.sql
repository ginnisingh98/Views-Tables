--------------------------------------------------------
--  DDL for Package Body OTA_OM_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OM_DEBUG" AS
/* $Header: ottomdbg.pkb 120.0 2005/05/29 07:45:33 appldev noship $ */
--
-- Package Variables
--
g_package  	VARCHAR2(33) := 'OTA_OM_DEBUG.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <reset_debug_level> >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE RESET_DEBUG_LEVEL
IS

BEGIN
 OE_DEBUG_PUB.G_DEBUG_LEVEL:=0;

END RESET_DEBUG_LEVEL;

-- ----------------------------------------------------------------------------
-- |--------------------------< <set_debug_level> >------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE SET_DEBUG_LEVEL (p_debug_level IN NUMBER)
IS

BEGIN
 OE_DEBUG_PUB.G_DEBUG_LEVEL:=p_debug_level;

END SET_DEBUG_LEVEL;


END OTA_OM_DEBUG;

/
