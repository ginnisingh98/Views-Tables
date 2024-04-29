--------------------------------------------------------
--  DDL for Package OE_CREDIT_INTERFACE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREDIT_INTERFACE_UTIL" AUTHID CURRENT_USER AS
-- $Header: OEXUCERS.pls 120.1.12010000.1 2008/07/25 07:55:08 appldev ship $
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    OEXUCERS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Package Spec of OE_CREDIT_INTERFACE_UTIL                           |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|    Get_Exposure_Amount                                                |
--|                                                                       |
--| HISTORY                                                               |
--|    Aug-01-2006 Initial Creation                                       |
--|=======================================================================+

--===============================================================================
-- PROCEDURE : Get_exposure_amount
-- Comments  : Return the overall exposure amount in RA_INTERFACE_LINES_ALL table
--===============================================================================
PROCEDURE Get_exposure_amount
( p_header_id              IN  NUMBER
, p_customer_id            IN  NUMBER
, p_site_use_id            IN  NUMBER
, p_credit_check_rule_rec  IN  OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
, p_system_parameter_rec   IN  OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
, p_credit_level           IN  VARCHAR2
, p_limit_curr_code        IN  VARCHAR2
, p_usage_curr             IN  OE_CREDIT_CHECK_UTIL.curr_tbl_type
, p_global_exposure_flag   IN  VARCHAR2 := 'N'
, x_exposure_amount        OUT NOCOPY NUMBER
, x_conversion_status      OUT NOCOPY OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE
, x_return_status          OUT NOCOPY VARCHAR2
) ;

END OE_CREDIT_INTERFACE_UTIL ;

/
