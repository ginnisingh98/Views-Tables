--------------------------------------------------------
--  DDL for Package QPR_REPORT_ENTITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_REPORT_ENTITIES_PVT" AUTHID CURRENT_USER AS
/* $Header: QPRRPTES.pls 120.0 2007/10/11 13:20:03 agbennet noship $ */

--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : DELETE_REPORT_HEADER
--
-- PARAMETERS:
--             p_report_id             Id for the Report Header to be deleted
--             x_return_status         Return status
--
-- COMMENT   : This procedure deletes the record from the Report Header tables
--========================================================================

   PROCEDURE DELETE_REPORT_HEADER(
        p_report_id        IN            NUMBER,
        x_return_status    OUT NOCOPY    VARCHAR2);


--========================================================================
-- PROCEDURE : DELETE_REPORT
--
-- PARAMETERS:
--             p_report_id             Report Header Id for which Report needs
--                                     to be deleted
--
--             x_return_status         Return status
--
-- COMMENT   : This procedure deletes  the report header, lines, relations
--             for a given report id
--========================================================================

  PROCEDURE DELETE_REPORT(
                p_report_id    IN     NUMBER,
                x_return_status OUT NOCOPY VARCHAR2);



--===========================================================
-- PROCEDURE : DELETE_RELATED_REPORTS
--
-- PARAMETERS:
--             p_report_id         Parent report id for whom related reports
--                                  should be deleted
--             x_return_status         Return status
--
-- COMMENT   : This procedure deletes all the related report headers, lines
--             for a given report  id
--========================================================================

   PROCEDURE DELETE_RELATED_REPORTS(
              p_parent_report_id       IN NUMBER,
              x_return_status   OUT NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : DELETE_REPORTS
--
-- PARAMETERS:
--             p_price_plan_id         Price plan ID for which reports needs
--                                     to be deleted
--             x_return_status         Return status
--
-- COMMENT   : This procedure deletes all the report headers, lines, relations
--             for a given price plan id
--========================================================================

  PROCEDURE DELETE_REPORTS(
        p_price_plan_id        IN            NUMBER,
        x_return_status    OUT NOCOPY    VARCHAR2);

END QPR_REPORT_ENTITIES_PVT;

/
