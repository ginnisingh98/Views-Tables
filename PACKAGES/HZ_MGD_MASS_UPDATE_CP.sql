--------------------------------------------------------
--  DDL for Package HZ_MGD_MASS_UPDATE_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MGD_MASS_UPDATE_CP" AUTHID CURRENT_USER AS
/* $Header: ARHCMUCS.pls 120.2 2005/06/30 04:46:28 bdhotkar noship $*/
/*+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    ARHCMUCS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Spec. of concurrent program package HZ_MGD_MASS_UPDATE_CP         |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Run_Mass_Update_Credit_Usages                                     |
--|                                                                       |
--| HISTORY                                                               |
--|     05/14/2002 tsimmond    Created                                    |
--|     11/27/2002 tsimmond    Updated   Added WHENEVER OSERROR EXIT      |
--|                                      FAILURE ROLLBACK                 |
--|                                                                       |
--+======================================================================*/


--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'HZ_MGD_MASS_UPDATE_CP';

--===================
-- GLOBAL VARIABLES
--===================
G_RELEASE          VARCHAR2(3);

--========================================================================
-- PROCEDURE : Run_Mass_Update_Credit_Usages  PUBLIC
-- PARAMETERS: p_profile_class_id     Profile Class ID
--             p_currency_code        Currency Code
--             p_profile_class_amount_id profile_class_amount_id
--             p_release              OLD or NEW(is when AR Credit Management
--                                    is installed)
--             x_errbuf               error buffer
--             x_retcode              0 success, 1 warning, 2 error
--
-- COMMENT   : This is the concurrent program for mass update update credit usages
--
--========================================================================
PROCEDURE Run_Mass_Update_Credit_Usages
( x_errbuf            OUT NOCOPY VARCHAR2
, x_retcode           OUT NOCOPY VARCHAR2
, p_profile_class_id  IN  NUMBER
, p_currency_code     IN  VARCHAR2
, p_profile_class_amount_id IN NUMBER
, p_release            IN VARCHAR2

);

END HZ_MGD_MASS_UPDATE_CP;

 

/
