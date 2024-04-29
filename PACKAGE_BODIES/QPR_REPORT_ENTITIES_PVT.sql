--------------------------------------------------------
--  DDL for Package Body QPR_REPORT_ENTITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_REPORT_ENTITIES_PVT" AS
/* $Header: QPRRPTEB.pls 120.0 2007/10/11 13:20:22 agbennet noship $ */

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
        x_return_status    OUT NOCOPY    VARCHAR2)
  IS
  BEGIN

     DELETE FROM QPR_REPORT_HDRS_B
     WHERE REPORT_HEADER_ID = p_report_id;

     DELETE FROM QPR_REPORT_HDRS_TL
     WHERE REPORT_HEADER_ID = p_report_id;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
     WHEN OTHERS
     THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END DELETE_REPORT_HEADER;


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
                x_return_status OUT NOCOPY VARCHAR2)
  IS
      l_report_line_id  NUMBER;
      l_related_report_id  NUMBER;

      CURSOR Get_Report_Lines(p_report_id NUMBER)
      IS
          SELECT REPORT_LINE_ID
          FROM QPR_REPORT_LINES
          WHERE REPORT_HEADER_ID = p_report_id;

  BEGIN

     DELETE_RELATED_REPORTS(p_report_id,x_return_status);

     OPEN Get_Report_Lines(p_report_id);
     LOOP
       FETCH Get_Report_Lines INTO l_report_line_id;
        IF Get_Report_Lines%NOTFOUND
        THEN
           EXIT;
        END IF;
       DELETE FROM BISM_OBJECTS
        WHERE OBJECT_NAME LIKE 'qpr'||l_report_line_id||'q%';
     END LOOP;
     CLOSE Get_Report_Lines;

     DELETE FROM QPR_REPORT_LINES
     WHERE REPORT_HEADER_ID = p_report_id;

     DELETE FROM QPR_REPORT_RELNS
     WHERE PARENT_REPORT_ID = p_report_id;

     DELETE FROM QPR_REPORT_HDRS_TL
     WHERE REPORT_HEADER_ID = p_report_id;

    DELETE FROM QPR_REPORT_HDRS_B
    WHERE REPORT_HEADER_ID = p_report_id;


    EXCEPTION
       WHEN OTHERS
       THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

   END DELETE_REPORT;

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
              x_return_status   OUT NOCOPY VARCHAR2)

   IS

        l_related_report_id        NUMBER;
        l_report_line_id           NUMBER;

        CURSOR Get_Report_Lines(p_parent_report_id NUMBER)
        IS
          SELECT REPORT_LINE_ID
          FROM QPR_REPORT_LINES
          WHERE REPORT_HEADER_ID = p_parent_report_id;

        CURSOR Get_Related_Reports(p_parent_report_id NUMBER)
        IS
          SELECT TARGET_REPORT_ID
          FROM QPR_REPORT_RELNS
          WHERE PARENT_REPORT_ID = p_parent_report_id;

     BEGIN

          OPEN Get_Related_Reports(p_parent_report_id);
          LOOP
              FETCH Get_Related_Reports INTO l_related_report_id;
              IF Get_Related_Reports%NOTFOUND
              THEN
                EXIT;
              END IF;
              OPEN Get_Report_Lines(l_related_report_id);
              LOOP
              FETCH Get_Report_Lines INTO l_report_line_id;
              IF Get_Report_Lines%NOTFOUND
              THEN
                EXIT;
              END IF;
              DELETE FROM BISM_OBJECTS
                 WHERE OBJECT_NAME LIKE 'qpr'||l_report_line_id||'q%';
              END LOOP;
              CLOSE Get_Report_Lines;
         END LOOP;
         CLOSE Get_Related_Reports;

         DELETE FROM QPR_REPORT_HDRS_B WHERE REPORT_HEADER_ID IN
             (SELECT TARGET_REPORT_ID FROM QPR_REPORT_RELNS WHERE PARENT_REPORT_ID = p_parent_report_id);

         DELETE FROM QPR_REPORT_HDRS_TL WHERE REPORT_HEADER_ID IN
             (SELECT TARGET_REPORT_ID FROM QPR_REPORT_RELNS WHERE PARENT_REPORT_ID = p_parent_report_id);

         DELETE FROM QPR_REPORT_LINES WHERE REPORT_HEADER_ID IN
             (SELECT TARGET_REPORT_ID FROM QPR_REPORT_RELNS WHERE PARENT_REPORT_ID = p_parent_report_id);

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        EXCEPTION
          WHEN OTHERS
            THEN
              x_return_status := FND_API.G_RET_STS_ERROR;

     END DELETE_RELATED_REPORTS;


--===========================================================
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
        x_return_status    OUT NOCOPY    VARCHAR2)
  IS

     l_report_line_id       NUMBER;

    CURSOR Get_Report_Lines(c_price_plan_id NUMBER)
    IS
        SELECT QRL.REPORT_LINE_ID
        FROM QPR_REPORT_HDRS_B QRH,
	     QPR_REPORT_LINES QRL
        WHERE QRH.REPORT_HEADER_ID = QRL.REPORT_HEADER_ID
	AND QRH.PLAN_ID = c_price_plan_id;
  BEGIN

     OPEN Get_Report_lines(p_price_plan_id);
     LOOP

	FETCH Get_Report_Lines INTO l_report_line_id;
	IF Get_Report_Lines%NOTFOUND
	THEN
	   EXIT;
	END IF;

	DELETE FROM BISM_OBJECTS
	WHERE OBJECT_NAME LIKE 'qpr'||l_report_line_id||'q%';

     END LOOP;
     CLOSE Get_Report_Lines;

     DELETE FROM QPR_REPORT_LINES
     WHERE REPORT_HEADER_ID IN (
		SELECT REPORT_HEADER_ID
		FROM QPR_REPORT_HDRS_B
		WHERE PLAN_ID = p_price_plan_id
				);

     DELETE FROM QPR_REPORT_RELNS
     WHERE PARENT_REPORT_ID IN (
		SELECT REPORT_HEADER_ID
		FROM QPR_REPORT_HDRS_B
		WHERE PLAN_ID = p_price_plan_id
				);

     DELETE FROM QPR_REPORT_HDRS_TL
     WHERE REPORT_HEADER_ID IN (
		SELECT REPORT_HEADER_ID
		FROM QPR_REPORT_HDRS_B
		WHERE PLAN_ID = p_price_plan_id
				);
     DELETE FROM QPR_REPORT_HDRS_B
     WHERE PLAN_ID = p_price_plan_id;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
     WHEN OTHERS
     THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
  END DELETE_REPORTS;

END QPR_REPORT_ENTITIES_PVT;


/
