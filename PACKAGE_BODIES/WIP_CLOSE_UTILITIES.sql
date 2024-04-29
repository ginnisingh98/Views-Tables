--------------------------------------------------------
--  DDL for Package Body WIP_CLOSE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_CLOSE_UTILITIES" AS
 /* $Header: wipclutb.pls 115.10 2003/10/06 19:28:01 ccai ship $ */

  FUNCTION UNCLOSE_JOB
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER,
     P_class_code VARCHAR2) RETURN NUMBER IS

  CURSOR c1 IS
        SELECT  WDJ.DATE_RELEASED,
                WDJ.DATE_COMPLETED,
                WDJ.DATE_CLOSED
        FROM    ORG_ACCT_PERIODS OAP,
                WIP_DISCRETE_JOBS WDJ
        WHERE   WDJ.WIP_ENTITY_ID = P_Wip_Entity_Id
        AND     WDJ.ORGANIZATION_ID = P_Organization_Id
        AND     OAP.ORGANIZATION_ID = WDJ.ORGANIZATION_ID
        AND     INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG (WDJ.DATE_CLOSED,
                                                       wdj.organization_id)
                  BETWEEN OAP.PERIOD_START_DATE AND OAP.SCHEDULE_CLOSE_DATE
        AND     OAP.OPEN_FLAG = 'Y';

  X_Date_Released DATE;
  X_Date_Completed DATE;
  X_Date_Closed DATE;
  BEGIN

    OPEN C1;
    FETCH C1 INTO X_Date_Released,
                  X_Date_Completed,
                  X_Date_Closed;
    IF C1%NOTFOUND THEN
        CLOSE C1;
        RETURN(0);
    END IF;
    CLOSE C1;

    IF (X_Date_Released IS NOT NULL) THEN
        WIP_CHANGE_STATUS.INSERT_PERIOD_BALANCES
		(P_wip_entity_id, P_organization_id, '', '',
                              P_class_code, X_Date_closed);
    END IF;

    -- reset back to 6 (eam rel) if 7 (eam close), set to 5 (osfm rel)
    -- if 8 (osfm close), otherwise, set it back to 1 (discrete)
    UPDATE WIP_ENTITIES
       SET ENTITY_TYPE = decode(ENTITY_TYPE, 7, 6, 8, 5, 1)
     WHERE WIP_ENTITY_ID = P_wip_entity_id;

    RETURN(1);

  END UNCLOSE_JOB;

  FUNCTION Check_Pending_Close
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER,
     P_request_id NUMBER) RETURN NUMBER IS
  old_status NUMBER;
  rid varchar2(30);
  req_id NUMBER := P_request_id;
  dummy BOOLEAN;
  dev_phase VARCHAR2(30);
  dev_status VARCHAR2(30);
  rphase VARCHAR2(30);
  rstatus VARCHAR2(30);
  msg VARCHAR2(240);
  BEGIN
        dummy := FND_CONCURRENT.get_request_status(
                        req_id,
                        '',
                        '',
                        rphase, rstatus,
                        dev_phase, dev_status,
                        msg);
        IF dev_phase IN ('PENDING', 'RUNNING', 'NORMAL') OR
          (dev_phase = 'COMPLETE'
                AND dev_status IN ('NORMAL','WARNING')) THEN
                return(0);
        ELSE
                DECLARE CURSOR C1 IS
                        SELECT WDCT.STATUS_TYPE,
			       WDCT.rowid
                        FROM   WIP_DISCRETE_JOBS WDJ,
			       WIP_DJ_CLOSE_TEMP WDCT
                        WHERE  WDCT.WIP_ENTITY_ID = P_wip_entity_id
                        AND    WDCT.ORGANIZATION_ID = P_organization_id
			AND    WDJ.WIP_ENTITY_ID = WDCT.WIP_ENTITY_ID
			AND    WDJ.STATUS_TYPE = WIP_CONSTANTS.PEND_CLOSE;
                BEGIN
                        OPEN C1;
                        FETCH C1 INTO old_status, rid;

                        -- This should never happen but if it does...
			-- Actually could happen in the COMPLETE Error Case
                        IF C1%NOTFOUND THEN
                                CLOSE C1;
                                return(0);
                        END IF;

                        DELETE FROM WIP_DJ_CLOSE_TEMP
                        WHERE ROWID = rid;

                        CLOSE C1;
                        return(old_status);
                END;
        END IF;
  END Check_Pending_Close;

END WIP_CLOSE_UTILITIES;

/
