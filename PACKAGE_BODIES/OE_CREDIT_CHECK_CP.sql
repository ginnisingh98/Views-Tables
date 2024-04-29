--------------------------------------------------------
--  DDL for Package Body OE_CREDIT_CHECK_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREDIT_CHECK_CP" AS
-- $Header: OEXCCRCB.pls 120.1 2005/10/17 22:31:14 spooruli noship $

--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    OEXCCRCB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Body of OE_CREDIT_CHECK_CP                                         |
--|                                                                       |
--| HISTORY                                                               |
--|     08/10/2001 Rene Schaub     Created                                |
--|     03/25/2002 Vanessa To      Added Purge_External_Exposure          |
--+======================================================================*/

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'OE_CREDIT_CHECK_CP';

--===================
-- GLOBAL VARIABLES
--===================

--===================
-- PRIVATE PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Init_Summary_Table     PUBLIC
-- PARAMETERS: x_retcode              0 success, 1 warning, 2 error
--             x_errbuf               error buffer
--             p_lock_tables          'Y' or 'N' for all transaction tables
--
--=======================================================================--


PROCEDURE  Init_Summary_Table
( x_retcode        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_errbuf         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, p_lock_tables    IN  VARCHAR2
)
IS
BEGIN

OE_CREDIT_EXPOSURE_PVT.Init_Summary_Table
( x_retcode
, x_errbuf
, p_lock_tables
);

END Init_Summary_Table;

--========================================================================
-- PROCEDURE : Purge_External_Exposure PUBLIC
-- PARAMETERS: x_retcode              0 success, 1 warning, 2 error
--             x_errbuf               error buffer
--             p_exposure_source_code user defined exposure source code
--
--=======================================================================--

PROCEDURE Purge_External_Exposure
( x_retcode                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_errbuf                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  /* Moac */
, p_org_id                 IN  NUMBER
, p_exposure_source_code   IN  VARCHAR2
)
IS
BEGIN
  OE_DEBUG_PUB.Add('*****Parameters***** ');
  OE_DEBUG_PUB.Add('p_exposure_source_code = '||p_exposure_source_code);
  OE_DEBUG_PUB.Add('******************** ');
  OE_EXT_CREDIT_EXPOSURE_PVT.Purge
    ( p_org_id               => p_org_id
    , p_exposure_source_code => p_exposure_source_code);
x_retcode := 0;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    OE_DEBUG_PUB.Add('OEXCCRCB: Purge_External_Exposure -- Unexpected Error');
    x_retcode := 2;
    x_errbuf  := sqlerrm;
END Purge_External_Exposure;


END OE_CREDIT_CHECK_CP;

/
