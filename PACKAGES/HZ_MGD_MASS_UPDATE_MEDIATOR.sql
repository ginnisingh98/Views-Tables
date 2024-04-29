--------------------------------------------------------
--  DDL for Package HZ_MGD_MASS_UPDATE_MEDIATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MGD_MASS_UPDATE_MEDIATOR" AUTHID CURRENT_USER AS
/* $Header: ARHCMUMS.pls 120.2 2005/06/30 04:46:39 bdhotkar noship $*/
/*+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    ARHCMUMS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Specification of the package HZ_MGD_MASS_UPDATE_MEDIATOR          |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Mass_Update_Usage_Rules                                           |
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
G_PKG_NAME CONSTANT VARCHAR2(30) := 'HZ_MGD_MASS_UPDATE_MEDIATOR';

--===================
-- GLOBAL VARIABLES
--===================

--========================================================================
-- PROCEDURE : Mass_Update_Usage_Rules  PUBLIC
-- PARAMETERS: p_profile_class_id     Profile Class ID
--             p_currency_code        Currency Code
--             p_profile_class_amount_id
--             x_errbuf               error buffer
--             x_retcode              0 success, 1 warning, 2 error
--
-- COMMENT   : This is the concurrent program for Mass update credit usages
--
--========================================================================
PROCEDURE Mass_Update_Usage_Rules
( p_profile_class_id  IN  NUMBER
, p_currency_code     IN  VARCHAR2
, p_profile_class_amount_id IN NUMBER
, x_errbuf            OUT NOCOPY  VARCHAR2
, x_retcode           OUT NOCOPY VARCHAR2
);

END HZ_MGD_MASS_UPDATE_MEDIATOR;

 

/
