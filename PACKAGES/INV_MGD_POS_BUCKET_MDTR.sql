--------------------------------------------------------
--  DDL for Package INV_MGD_POS_BUCKET_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_POS_BUCKET_MDTR" AUTHID CURRENT_USER AS
/* $Header: INVMPBKS.pls 120.0 2005/05/25 04:48:21 appldev noship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVMPBKS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Inventory Position View and Export: Time Bucket Mediator          |
--| HISTORY                                                               |
--|     09/05/2000 Paolo Juvara      Created                              |
--+======================================================================*/


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Build_Bucket_List       PUBLIC
-- PARAMETERS: p_organization_id       organization holding the calendar
--             p_date_from             date range from
--             p_date_to               date range to
--             p_bucket_size           PERIOD, WEEK, DAY or HOUR
--             x_bucket_tbl            list of buckets
-- COMMENT   : Builds the list of buckets in the given date range
-- PRE-COND  : p_date_to > p_date_from
-- POST-COND : x_bucket_tbl is not empty
--========================================================================
PROCEDURE Build_Bucket_List
( p_organization_id    IN            NUMBER
, p_date_from          IN            DATE
, p_date_to            IN            DATE
, p_bucket_size        IN            VARCHAR2
, x_bucket_tbl         IN OUT NOCOPY INV_MGD_POS_UTIL.bucket_tbl_type
);


END INV_MGD_POS_BUCKET_MDTR;

 

/
