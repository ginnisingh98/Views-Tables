--------------------------------------------------------
--  DDL for Package Body QPR_PN_ENTITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_PN_ENTITIES_PVT" AS
/* $Header: QPRPNEHB.pls 120.1 2007/12/17 09:08:11 vinnaray noship $ */

--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : DELETE_DEALS
--
-- PARAMETERS:
--             p_price_plan_id         Price plan ID for which deals needs
--                                     to be deleted
--             x_return_status         Return status
--
-- COMMENT   : This procedure deletes all the requests responses and
--             related reports for a given price plan id
--========================================================================

  PROCEDURE DELETE_DEALS(
        p_price_plan_id        IN            NUMBER,
        x_return_status    OUT NOCOPY    VARCHAR2)
  IS

     l_report_id     NUMBER;
     l_return_status VARCHAR2(1);
  BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
     WHEN OTHERS
     THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
  END DELETE_DEALS;

END QPR_PN_ENTITIES_PVT;


/
