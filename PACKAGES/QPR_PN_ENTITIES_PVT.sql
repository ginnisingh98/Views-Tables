--------------------------------------------------------
--  DDL for Package QPR_PN_ENTITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_PN_ENTITIES_PVT" AUTHID CURRENT_USER AS
/* $Header: QPRPNEHS.pls 120.0 2007/10/11 13:20:39 agbennet noship $ */

--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : DELETE_DEALS
--
-- PARAMETERS:
--             p_price_plan_id         Price plan ID for which requests and
--                                     responses needs to be deleted
--             x_return_status         Return status
--
-- COMMENT   : This procedure deletes all the requests, responses and related
--             reports for a given price plan id
--========================================================================

  PROCEDURE DELETE_DEALS(
        p_price_plan_id        IN            NUMBER,
        x_return_status    OUT NOCOPY    VARCHAR2);

END QPR_PN_ENTITIES_PVT;

/
