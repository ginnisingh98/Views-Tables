--------------------------------------------------------
--  DDL for Package OE_CREDIT_CHECK_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREDIT_CHECK_CP" AUTHID CURRENT_USER AS
-- $Header: OEXCCRCS.pls 120.1 2005/10/17 22:30:42 spooruli noship $

--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    OEXCCRCS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Specification of OE_CREDIT_CHECK_CP                                |
--|                                                                       |
--| HISTORY                                                               |
--|     08/10/2001 Rene Schaub     Created                                |
--|     03/25/2002 Vanessa To      Added Purge_External_Exposure procedure|
--+======================================================================*/

--===================
-- CONSTANTS
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
, p_lock_tables    IN  VARCHAR2  DEFAULT  'N'
);

--========================================================================
-- PROCEDURE : Purge_External_Exposure     PUBLIC
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
);

END OE_CREDIT_CHECK_CP;

 

/
