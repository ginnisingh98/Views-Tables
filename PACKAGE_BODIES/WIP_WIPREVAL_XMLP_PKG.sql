--------------------------------------------------------
--  DDL for Package Body WIP_WIPREVAL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPREVAL_XMLP_PKG" AS
/* $Header: WIPREVALB.pls 120.1 2008/01/09 10:08:02 dwkrishn noship $ */
  FUNCTION DISP_CURRENCYFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (REPORT_OPTION || '(' || CURRENCY_CODE || ')');
  END DISP_CURRENCYFORMULA;

  FUNCTION ORG_NAME_HDRFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (ORG_NAME);
  END ORG_NAME_HDRFORMULA;

  FUNCTION TOT_CST_INC_APP_CSTFORMULA(TOT_ACT_ISS_STD IN NUMBER
                                     ,TOT_RES_APP_COST IN NUMBER
                                     ,TOT_RES_OVR_APP_COST IN NUMBER
                                     ,TOT_MV_OVR_APP_COST IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(TOT_ACT_ISS_STD)*/NULL;
    /*SRW.REFERENCE(TOT_RES_APP_COST)*/NULL;
    /*SRW.REFERENCE(TOT_RES_OVR_APP_COST)*/NULL;
    /*SRW.REFERENCE(TOT_MV_OVR_APP_COST)*/NULL;
    RETURN (NVL(TOT_ACT_ISS_STD
              ,0) + NVL(TOT_RES_APP_COST
              ,0) + NVL(TOT_RES_OVR_APP_COST
              ,0) + NVL(TOT_MV_OVR_APP_COST
              ,0));
  END TOT_CST_INC_APP_CSTFORMULA;

  FUNCTION TOT_CST_INC_EFF_VARFORMULA(TOT_USG_VAR IN NUMBER
                                     ,TOT_EFF_VAR IN NUMBER
                                     ,TOT_RES_OVR_EFF_VAR IN NUMBER
                                     ,TOT_MV_OVR_EFF_VAR IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(TOT_USG_VAR)*/NULL;
    /*SRW.REFERENCE(TOT_EFF_VAR)*/NULL;
    /*SRW.REFERENCE(TOT_RES_OVR_EFF_VAR)*/NULL;
    /*SRW.REFERENCE(TOT_MV_OVR_EFF_VAR)*/NULL;
    RETURN (NVL(TOT_USG_VAR
              ,0) + NVL(TOT_EFF_VAR
              ,0) + NVL(TOT_RES_OVR_EFF_VAR
              ,0) + NVL(TOT_MV_OVR_EFF_VAR
              ,0));
  END TOT_CST_INC_EFF_VARFORMULA;

  FUNCTION TOT_JOB_BALANCE_CSTFORMULA(TOT_CST_INC_APP_CST IN NUMBER
                                     ,TOT_SCP_AND_COMP_CST IN NUMBER
                                     ,TOT_CLOSE_TRX_CST IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(TOT_CST_INC_APP_CST)*/NULL;
    /*SRW.REFERENCE(TOT_SCP_AND_COMP_CST)*/NULL;
    /*SRW.REFERENCE(TOT_CLOSE_TRX_CST)*/NULL;
    RETURN (NVL(TOT_CST_INC_APP_CST
              ,0) - NVL(TOT_SCP_AND_COMP_CST
              ,0) - NVL(TOT_CLOSE_TRX_CST
              ,0));
  END TOT_JOB_BALANCE_CSTFORMULA;

  FUNCTION TOT_CST_INC_STD_CSTFORMULA(TOT_REQ_JOB_STD IN NUMBER
                                     ,TOT_RES_STD_COST IN NUMBER
                                     ,TOT_RES_OVR_STD_COST IN NUMBER
                                     ,TOT_MV_OVR_STD_COST IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(TOT_REQ_JOB_STD)*/NULL;
    /*SRW.REFERENCE(TOT_RES_STD_COST)*/NULL;
    /*SRW.REFERENCE(TOT_RES_OVR_STD_COST)*/NULL;
    /*SRW.REFERENCE(TOT_MV_OVR_STD_COST)*/NULL;
    RETURN (NVL(TOT_REQ_JOB_STD
              ,0) + NVL(TOT_RES_STD_COST
              ,0) + NVL(TOT_RES_OVR_STD_COST
              ,0) + NVL(TOT_MV_OVR_STD_COST
              ,0));
  END TOT_CST_INC_STD_CSTFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      EXECUTE IMMEDIATE
        'DELETE FROM WIP_TEMP_REPORTS
        WHERE  PROGRAM_SOURCE = ''WIPREVAL''';
      EXECUTE IMMEDIATE
        'COMMIT';
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION MAT_DISPFORMULA(QTY_REQ_SUM IN NUMBER
                          ,REQ_JOB_STD_SUM IN NUMBER
                          ,QTY_ISS_PER_OP_SUM IN NUMBER
                          ,ACT_ISS_STD_SUM IN NUMBER
                          ,SUPPLY_TYPE_CODE IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF ((QTY_REQ_SUM <> 0) OR (REQ_JOB_STD_SUM <> 0) OR (QTY_ISS_PER_OP_SUM <> 0) OR (ACT_ISS_STD_SUM <> 0)) THEN
      IF (SUPPLY_TYPE_CODE <> 4 AND SUPPLY_TYPE_CODE <> 5) THEN
        RETURN (1);
      ELSIF (QTY_ISS_PER_OP_SUM <> 0) THEN
        RETURN (1);
      ELSIF (SUPPLY_TYPE_CODE = 4) THEN
        IF (P_INCLUDE_BULK = 1) THEN
          RETURN (1);
        ELSE
          RETURN (0);
        END IF;
      ELSIF (SUPPLY_TYPE_CODE = 5) THEN
        IF (P_INCLUDE_VENDOR = 1) THEN
          RETURN (1);
        ELSE
          RETURN (0);
        END IF;
      END IF;
    ELSE
      RETURN (0);
    END IF;
    RETURN NULL;
  END MAT_DISPFORMULA;

  FUNCTION FROM_ASSY_DISP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FROM_ASSY_DISP;
  END FROM_ASSY_DISP_P;

  FUNCTION TO_LINE_DISP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_LINE_DISP;
  END TO_LINE_DISP_P;

  FUNCTION TO_CLASS_DISP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CLASS_DISP;
  END TO_CLASS_DISP_P;

  FUNCTION TO_ASSY_DISP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_ASSY_DISP;
  END TO_ASSY_DISP_P;

  FUNCTION FROM_LINE_DISP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FROM_LINE_DISP;
  END FROM_LINE_DISP_P;

  FUNCTION FROM_CLASS_DISP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FROM_CLASS_DISP;
  END FROM_CLASS_DISP_P;

  FUNCTION CHART_OF_ACCTS_ID_P RETURN NUMBER IS
  BEGIN
    RETURN CHART_OF_ACCTS_ID;
  END CHART_OF_ACCTS_ID_P;

  FUNCTION C_COUNTER_P RETURN NUMBER IS
  BEGIN
    RETURN C_COUNTER;
  END C_COUNTER_P;

  FUNCTION CALENDAR_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CALENDAR_CODE;
  END CALENDAR_CODE_P;

  FUNCTION CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CURRENCY_CODE;
  END CURRENCY_CODE_P;

  FUNCTION WHERE_PERIOD_P RETURN VARCHAR2 IS
  BEGIN
    RETURN WHERE_PERIOD;
  END WHERE_PERIOD_P;

  FUNCTION ORG_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ORG_NAME;
  END ORG_NAME_P;

  FUNCTION REPORT_SORT_BY_AFT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN REPORT_SORT_BY_AFT;
  END REPORT_SORT_BY_AFT_P;

  FUNCTION EXCEPTION_SET_ID_P RETURN NUMBER IS
  BEGIN
    RETURN EXCEPTION_SET_ID;
  END EXCEPTION_SET_ID_P;

  FUNCTION REPORT_OPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN REPORT_OPTION;
  END REPORT_OPTION_P;

  FUNCTION WHERE_CLASS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN WHERE_CLASS;
  END WHERE_CLASS_P;

  FUNCTION WHERE_ASSEMBLY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN WHERE_ASSEMBLY;
  END WHERE_ASSEMBLY_P;

  FUNCTION REPORT_SORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN REPORT_SORT;
  END REPORT_SORT_P;

  FUNCTION WHERE_LINE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN WHERE_LINE;
  END WHERE_LINE_P;

  FUNCTION PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN PRECISION;
  END PRECISION_P;

  FUNCTION EXT_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN EXT_PRECISION;
  END EXT_PRECISION_P;

  FUNCTION C_INCLUDE_VENDOR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_INCLUDE_VENDOR;
  END C_INCLUDE_VENDOR_P;

  FUNCTION C_INCLUDE_BULK_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_INCLUDE_BULK;
  END C_INCLUDE_BULK_P;

 FUNCTION BEFOREREPORT RETURN BOOLEAN IS
BEGIN

DECLARE
canonical varchar2(10) := 'DDMMYYYY';
BEGIN

C_FROM_PERIOD_START_DATE := to_date(to_char(FROM_PERIOD_START_DATE,'YYYY/MM/DD HH24:MI:SS'),'YYYY/MM/DD HH24:MI:SS');
C_TO_PERIOD_END_DATE := to_date(to_char(TO_PERIOD_END_DATE,'YYYY/MM/DD HH24:MI:SS'),'YYYY/MM/DD HH24:MI:SS');

--SRW.MESSAGE(0, 'IN BEFORE REPORT TRIGGER');

SELECT OOD.ORGANIZATION_NAME,
       OOD.CHART_OF_ACCOUNTS_ID,
       SOB.CURRENCY_CODE,
       FC.EXTENDED_PRECISION,
       FC.PRECISION,
       RPT_RUN_OPT.MEANING,
       MP.CALENDAR_CODE,
       MP.CALENDAR_EXCEPTION_SET_ID,
       ML1.MEANING,
       ML2.MEANING
INTO   ORG_NAME,
       CHART_OF_ACCTS_ID,
       CURRENCY_CODE,
       EXT_PRECISION,
       PRECISION,
       REPORT_OPTION,
       CALENDAR_CODE,
       EXCEPTION_SET_ID,
       C_Include_Bulk,
       C_Include_Vendor
FROM   FND_CURRENCIES FC,
       GL_SETS_OF_BOOKS SOB,
       ORG_ORGANIZATION_DEFINITIONS OOD,
       MFG_LOOKUPS RPT_RUN_OPT,
       MTL_PARAMETERS MP,
       MFG_LOOKUPS ML1,
       MFG_LOOKUPS ML2
WHERE  OOD.ORGANIZATION_ID = ORG_ID
AND    OOD.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
AND    MP.ORGANIZATION_ID = ORG_ID
AND    SOB.CURRENCY_CODE = FC.CURRENCY_CODE
AND    FC.ENABLED_FLAG = 'Y'
AND    RPT_RUN_OPT.LOOKUP_TYPE = 'CST_WIP_VALUE_REPORT_TYPE'
AND    RPT_RUN_OPT.LOOKUP_CODE = REPORT_RUN_OPT
AND    ML1.LOOKUP_CODE = NVL(P_Include_Bulk,2)
AND    ML1.LOOKUP_TYPE = 'SYS_YES_NO'
AND    ML2.LOOKUP_CODE = NVL(P_Include_Vendor,2)
AND    ML2.LOOKUP_TYPE = 'SYS_YES_NO';


-- if user entered null, make sure we display null, i.e. use _disp

FROM_ASSY_DISP := FROM_ASSEMBLY;
TO_ASSY_DISP := TO_ASSEMBLY;
FROM_CLASS_DISP := FROM_CLASS;
TO_CLASS_DISP := TO_CLASS;
FROM_LINE_DISP :=FROM_LINE;
TO_LINE_DISP := TO_LINE;

IF FROM_ASSEMBLY IS NULL THEN
SELECT NVL(MIN(WE.WIP_ENTITY_NAME),'X')
INTO   FROM_ASSEMBLY
FROM WIP_ENTITIES WE
WHERE  WE.ORGANIZATION_ID = ORG_ID
AND    WE.ENTITY_TYPE = 2;
END IF;

IF TO_ASSEMBLY IS NULL THEN
SELECT NVL(MAX(WE.WIP_ENTITY_NAME),'X')
INTO   TO_ASSEMBLY
FROM WIP_ENTITIES WE
WHERE  WE.ORGANIZATION_ID = ORG_ID
AND    WE.ENTITY_TYPE = 2;
END IF;

IF FROM_CLASS IS NULL THEN
SELECT NVL(MIN(WRI.CLASS_CODE),'X')
INTO   FROM_CLASS
FROM   WIP_REPETITIVE_ITEMS WRI
WHERE  WRI.ORGANIZATION_ID = ORG_ID;
END IF;

IF TO_CLASS IS NULL THEN
SELECT NVL(MAX(WRI.CLASS_CODE),'X')
INTO   TO_CLASS
FROM   WIP_REPETITIVE_ITEMS WRI
WHERE  WRI.ORGANIZATION_ID = ORG_ID;
END IF;

IF FROM_LINE IS NULL THEN
SELECT NVL(MIN(WL.LINE_CODE),'X')
INTO   FROM_LINE
FROM   WIP_LINES WL
WHERE  WL.ORGANIZATION_ID = ORG_ID;
END IF;

IF TO_LINE IS NULL THEN
SELECT NVL(MAX(WL.LINE_CODE),'X')
INTO   TO_LINE
FROM   WIP_LINES WL
WHERE  WL.ORGANIZATION_ID = ORG_ID;
END IF;

--SRW.USER_EXIT('FND SRWINIT');

/*SRW.USER_EXIT('FND FLEXSQL CODE="GL#" NUM=":CHART_OF_ACCTS_ID"
        APPL_SHORT_NAME="SQLGL" OUTPUT=":P_FLEXDATA_ACCT"
        MODE="SELECT" DISPLAY="ALL"
        TABLEALIAS="GCC"');*/

/*SRW.USER_EXIT('FND FLEXSQL CODE="MSTK"
        APPL_SHORT_NAME="INV" OUTPUT=":P_FLEXDATA_ITEM"
        MODE="SELECT" DISPLAY="ALL"
        TABLEALIAS="MSI"');*/

EXECUTE IMMEDIATE'delete from wip_temp_reports
where program_source = ''WIPREVAL''';


--SRW.MESSAGE(444, 'DONE WITH test2 INSERT');
TO_PERIOD_END_DATE_char:=to_char(TO_PERIOD_END_DATE,'DD-MON-YY');

FROM_PERIOD_START_DATE_char:=to_char(FROM_PERIOD_START_DATE,'DD-MON-YY');



EXECUTE IMMEDIATE 'insert into wip_temp_reports
 (organization_id,
  program_source,
  last_updated_by,
  wip_entity_id,
  key1,
  key2,
  key3,
  key4,
  key5,
  attribute1,
         date1,
         date2)
select /*+ RULE */
     wrs.organization_id,
     ''WIPREVAL'',
     31,
     wrs.wip_entity_id,
     wrs.line_id,
     wrs.repetitive_schedule_id,
     decode(sign(trunc(wrs.last_unit_start_date)-
        to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')),
        -1, (bcd1.prior_seq_num - bcd2.next_seq_num +
             decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1))),
         1, (bcd1.prior_seq_num - bcd2.next_seq_num + 1),
         (bcd1.prior_seq_num - bcd2.next_seq_num +
             decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1)))),
     0,
     0,
     ''N'',to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
     ,
    to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
from
     bom_calendar_dates bcd1,
     bom_calendar_dates bcd2,
     wip_entities we,
     wip_lines wl,
     wip_repetitive_items wri,
     wip_repetitive_schedules wrs
where
     bcd1.calendar_date =
       decode(sign(trunc(wrs.last_unit_start_date) -
          to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')),
              -1, trunc(wrs.last_unit_start_date),
              1, to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''),
              trunc(wrs.last_unit_start_date))
and  bcd2.calendar_date =
       decode(sign(
	to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''') -
                   trunc(wrs.first_unit_start_date)),
           -1, trunc(wrs.first_unit_start_date),
            1, to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''),
              trunc(wrs.first_unit_start_date))
and  bcd1.calendar_code = :CALENDAR_CODE
and  bcd2.calendar_code = :CALENDAR_CODE
and  bcd1.exception_set_id = :EXCEPTION_SET_ID
and  bcd2.exception_set_id = :EXCEPTION_SET_ID
and  we.wip_entity_name between :FROM_ASSEMBLY and :TO_ASSEMBLY
and  we.entity_type = 2
and  we.organization_id = :ORG_ID
and  wrs.wip_entity_id = we.wip_entity_id
and  wl.line_code between :FROM_LINE and :TO_LINE
and  wl.organization_id = :ORG_ID
and  wrs.line_id = wl.line_id
and  wri.line_id = wrs.line_id
and  wri.class_code between :FROM_CLASS and :TO_CLASS
and  wri.organization_id = :ORG_ID
and  wri.wip_entity_id = wrs.wip_entity_id
and  wrs.organization_id = :ORG_ID
and  ((trunc(wrs.first_unit_start_date) between
     to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
         and to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''))
     or (trunc(wrs.last_unit_start_date) between
      to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
         and to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''))
     or ((trunc(wrs.first_unit_start_date) <
      to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''))
     and (trunc(wrs.last_unit_start_date) >
      to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''))))
and not exists
     (select mmta.repetitive_schedule_id
      from   mtl_material_txn_allocations mmta,
                mtl_material_transactions mmt
         where mmt.transaction_date  >=
                to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
         and   mmt.transaction_date < to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''') + 1
         and  mmt.transaction_id = mmta.transaction_id
         and  mmta.organization_id = mmt.organization_id
         and  mmt.organization_id = :ORG_ID
	 and  mmt.transaction_source_id = we.wip_entity_id
	 and  mmt.transaction_source_type_id + 0 = 5
         and  mmta.repetitive_schedule_id = wrs.repetitive_schedule_id)
and  wrs.repetitive_schedule_id in
     (select repetitive_schedule_id
      from   wip_period_balances
      where  repetitive_schedule_id = wrs.repetitive_schedule_id
	and  organization_id = wrs.organization_id
	and  wip_entity_id = wrs.wip_entity_id)
group by
     wrs.organization_id,
     wrs.wip_entity_id,
     wrs.line_id,
     wrs.repetitive_schedule_id,
     wrs.last_unit_start_date,
     wrs.processing_work_days,
     (bcd1.prior_seq_num - bcd2.next_seq_num)'
USING

 CALENDAR_CODE , CALENDAR_CODE , EXCEPTION_SET_ID , EXCEPTION_SET_ID , FROM_ASSEMBLY , TO_ASSEMBLY, ORG_ID
, FROM_LINE , TO_LINE , ORG_ID , FROM_CLASS , TO_CLASS , ORG_ID , ORG_ID , ORG_ID ;

--SRW.MESSAGE(5, 'DONE WITH 1 INSERT');

EXECUTE IMMEDIATE 'insert into wip_temp_reports
  (organization_id,
  program_source,
  last_updated_by,
  wip_entity_id,
  key1,
  key2,
  key3,
  key4,
  key5,
  attribute1,
         date1,
         date2)
select /*+ RULE */
     wrs.organization_id,
     ''WIPREVAL'',
     31,
     wrs.wip_entity_id,
     wrs.line_id,
     wrs.repetitive_schedule_id,
     decode(sign(trunc(wrs.last_unit_start_date)-
      to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')),
      -1, (decode(sign(bcd1.prior_seq_num - bcd2.next_seq_num + 1),
               -1, 0,
                1, (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                    mod(wrs.processing_work_days,1))),
                (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                    mod(wrs.processing_work_days,1))))),
       1, (decode(sign(bcd1.prior_seq_num - bcd2.next_seq_num + 1),
               -1, 0,
                1, (bcd1.prior_seq_num - bcd2.next_seq_num + 1),
                (bcd1.prior_seq_num - bcd2.next_seq_num + 1))),
       (decode(sign(bcd1.prior_seq_num - bcd2.next_seq_num + 1),
               -1, 0,
                1, (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1))),
                (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1)))))),
     sum(mmta1.primary_quantity),
     sum(mmta2.primary_quantity),
     ''N'',
     to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''),
     to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
from
     mtl_material_transactions mmt1,
     mtl_material_txn_allocations mmta1,
     mtl_material_transactions mmt2,
     mtl_material_txn_allocations mmta2,
     bom_calendar_dates bcd1,
     bom_calendar_dates bcd2,
     wip_lines wl,
     wip_repetitive_items wri,
     wip_repetitive_schedules wrs,
     wip_entities we
where
     bcd1.calendar_date =
       decode(sign(trunc(wrs.last_unit_start_date) -
          to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')),
            -1, trunc(wrs.last_unit_start_date),
            1, to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''),
            trunc(wrs.last_unit_start_date))
and  bcd2.calendar_date =
       decode(sign(
          to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''') -
          trunc(wrs.first_unit_start_date)),
            -1, trunc(wrs.first_unit_start_date),
            1, to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''),
            trunc(wrs.first_unit_start_date))
and  bcd1.calendar_code = :CALENDAR_CODE
and  bcd2.calendar_code = :CALENDAR_CODE
and  bcd1.exception_set_id = :EXCEPTION_SET_ID
and  bcd2.exception_set_id = :EXCEPTION_SET_ID
and  mmt1.transaction_action_id in (31,32)
and  mmt1.transaction_date >=
       to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
and  mmt1.transaction_date <
       to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''') + 1
and  mmt1.transaction_id = mmta1.transaction_id
and  mmta1.organization_id = mmt1.organization_id
and  mmt1.organization_id = :ORG_ID
and  mmt1.transaction_source_id = we.wip_entity_id
and  mmt1.transaction_source_type_id + 0 = 5
and  mmt2.transaction_source_id = we.wip_entity_id
and  mmt2.transaction_source_type_id + 0 = 5
and  mmt2.transaction_action_id = 30
and  mmt2.transaction_date >=
       to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
and  mmt2.transaction_date <
       to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''') + 1
and  mmt2.transaction_id = mmta2.transaction_id
and  mmta2.organization_id = mmt2.organization_id
and  mmt2.organization_id = :ORG_ID
and  mmta2.repetitive_schedule_id = wrs.repetitive_schedule_id
and  we.wip_entity_name between :FROM_ASSEMBLY and :TO_ASSEMBLY
and  we.entity_type = 2
and  we.organization_id = :ORG_ID
and  wrs.wip_entity_id = we.wip_entity_id
and  wl.line_code between :FROM_LINE and :TO_LINE
and  wl.organization_id = :ORG_ID
and  wrs.line_id = wl.line_id
and  wri.line_id = wrs.line_id
and  wri.class_code between :FROM_CLASS and :TO_CLASS
and  wri.organization_id = :ORG_ID
and  wri.wip_entity_id = wrs.wip_entity_id
and  wrs.organization_id = :ORG_ID
and  mmta1.repetitive_schedule_id = wrs.repetitive_schedule_id
group by mmta1.repetitive_schedule_id,
   mmta2.repetitive_schedule_id,
   wrs.organization_id,
   wrs.wip_entity_id,
   wrs.line_id,
   wrs.repetitive_schedule_id,
   wrs.last_unit_start_date,
   wrs.processing_work_days,
   (bcd1.prior_seq_num - bcd2.next_seq_num)'
 USING
 CALENDAR_CODE , CALENDAR_CODE , EXCEPTION_SET_ID , EXCEPTION_SET_ID , ORG_ID , ORG_ID , FROM_ASSEMBLY , TO_ASSEMBLY , ORG_ID
 , FROM_LINE , TO_LINE , ORG_ID , FROM_CLASS, TO_CLASS , ORG_ID , ORG_ID ;

--SRW.MESSAGE(6, 'DONE WITH 2 INSERTS');

EXECUTE IMMEDIATE 'update wip_temp_reports wtr
set key4 =
   (select sum(mmta1.primary_quantity)
    from   mtl_material_transactions mmt1,
           mtl_material_txn_allocations mmta1
    where  mmt1.transaction_action_id in (31,32)
    and  mmt1.transaction_date  >=
          to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
    and  mmt1.transaction_date  <
          to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''') + 1
    and  mmt1.transaction_id = mmta1.transaction_id
    and  mmta1.organization_id = mmt1.organization_id
    and  mmt1.organization_id = :ORG_ID
    and  mmt1.transaction_source_id = wtr.wip_entity_id
    and  mmt1.transaction_source_type_id + 0 = 5
    and  mmta1.repetitive_schedule_id = wtr.key2)
where wtr.key4 <> 0
and   wtr.key5 <> 0
and   wtr.program_source = ''WIPREVAL'''
USING
ORG_ID;

--SRW.MESSAGE(4, 'DONE WIT');

EXECUTE IMMEDIATE 'update wip_temp_reports wtr
set key5 =
   (select sum(mmta2.primary_quantity)
    from   mtl_material_transactions mmt2,
           mtl_material_txn_allocations mmta2
    where  mmt2.transaction_action_id = 30
    and  mmt2.transaction_date >=
          to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
    and  mmt2.transaction_date <
          to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''') + 1
    and  mmt2.transaction_id = mmta2.transaction_id
    and  mmta2.organization_id = mmt2.organization_id
    and  mmt2.organization_id = :ORG_ID
    and  mmt2.transaction_source_id = wtr.wip_entity_id
    and  mmt2.transaction_source_type_id + 0 = 5
    and  mmta2.repetitive_schedule_id = wtr.key2)
where wtr.key4 <> 0
and   wtr.key5 <> 0
and   wtr.program_source = ''WIPREVAL'''
USING
ORG_ID;


EXECUTE IMMEDIATE 'insert into wip_temp_reports
   (organization_id,
   program_source,
   last_updated_by,
   wip_entity_id,
   key1,
   key2,
   key3,
   key4,
   key5,
   attribute1,
         date1,
         date2)
select /*+ RULE */
     wrs.organization_id,
     ''WIPREVAL'',
     31,
     wrs.wip_entity_id,
     wrs.line_id,
     wrs.repetitive_schedule_id,
     decode(sign(trunc(wrs.last_unit_start_date)-
     to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')),
     -1, (decode(sign(bcd1.prior_seq_num - bcd2.next_seq_num + 1),
               -1, 0,
                1, (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1))),
                (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1))))),
     1, (decode(sign(bcd1.prior_seq_num - bcd2.next_seq_num + 1),
               -1, 0,
                1, (bcd1.prior_seq_num - bcd2.next_seq_num + 1),
                (bcd1.prior_seq_num - bcd2.next_seq_num + 1))),
     (decode(sign(bcd1.prior_seq_num - bcd2.next_seq_num + 1),
               -1, 0,
                1, (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1))),
                (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1)))))),
     sum(mmta1.primary_quantity),
     0,
     ''N'',
     to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''),
     to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
from
     mtl_material_transactions mmt1,
     mtl_material_txn_allocations mmta1,
     bom_calendar_dates bcd1,
     bom_calendar_dates bcd2,
     wip_lines wl,
     wip_repetitive_schedules wrs,
     wip_repetitive_items wri,
     wip_entities we
where
     bcd1.calendar_date =
       decode(sign(trunc(wrs.last_unit_start_date) -
          to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')),
            -1, trunc(wrs.last_unit_start_date),
            1, to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''),
            trunc(wrs.last_unit_start_date))
and  bcd2.calendar_date =
       decode(sign(
          to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''') -
          trunc(wrs.first_unit_start_date)),
           -1, trunc(wrs.first_unit_start_date),
           1, to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''),
           trunc(wrs.first_unit_start_date))
and  bcd1.calendar_code = :CALENDAR_CODE
and  bcd2.calendar_code = :CALENDAR_CODE
and  bcd1.exception_set_id = :EXCEPTION_SET_ID
and  bcd2.exception_set_id = :EXCEPTION_SET_ID
and  mmt1.transaction_action_id in (31,32)
and  mmt1.transaction_date >=
       to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
and  mmt1.transaction_date <
       to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')+ 1
and  mmt1.transaction_id = mmta1.transaction_id
and  mmta1.organization_id = mmt1.organization_id
and  mmt1.organization_id = :ORG_ID
and  mmt1.transaction_source_id = we.wip_entity_id
and  mmt1.transaction_source_type_id + 0 = 5
and  we.wip_entity_name between :FROM_ASSEMBLY and :TO_ASSEMBLY
and  we.entity_type = 2
and  we.organization_id = :ORG_ID
and  wrs.wip_entity_id = we.wip_entity_id
and  wl.line_code between :FROM_LINE and :TO_LINE
and  wl.organization_id = :ORG_ID
and  wrs.line_id = wl.line_id
and  wri.line_id = wrs.line_id
and  wri.class_code between :FROM_CLASS and :TO_CLASS
and  wri.organization_id = :ORG_ID
and  wri.wip_entity_id = wrs.wip_entity_id
and  wrs.organization_id = :ORG_ID
and  mmta1.repetitive_schedule_id = wrs.repetitive_schedule_id
and  mmta1.repetitive_schedule_id not in
 (select key2
  from   wip_temp_reports
  where  program_source = ''WIPREVAL'')
group by mmta1.repetitive_schedule_id,
   wrs.organization_id,
   wrs.wip_entity_id,
   wrs.line_id,
   wrs.repetitive_schedule_id,
   wrs.last_unit_start_date,
   wrs.processing_work_days,
   (bcd1.prior_seq_num - bcd2.next_seq_num)'
 USING
  CALENDAR_CODE , CALENDAR_CODE , EXCEPTION_SET_ID , EXCEPTION_SET_ID ,
  ORG_ID , FROM_ASSEMBLY , TO_ASSEMBLY, ORG_ID , FROM_LINE , TO_LINE , ORG_ID , FROM_CLASS , TO_CLASS , ORG_ID , ORG_ID ;

--SRW.MESSAGE(7, 'DONE WITH 3 INSERTS');

EXECUTE IMMEDIATE 'insert into wip_temp_reports
 (organization_id,
  program_source,
  last_updated_by,
  wip_entity_id,
  key1,
  key2,
  key3,
  key4,
  key5,
  attribute1,
         date1,
         date2)
select /*+ RULE */
     wrs.organization_id,
     ''WIPREVAL'',
     31,
     wrs.wip_entity_id,
     wrs.line_id,
     wrs.repetitive_schedule_id,
     decode(sign(trunc(wrs.last_unit_start_date)-
        to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')),
        -1, (decode(sign(bcd1.prior_seq_num - bcd2.next_seq_num + 1),
               -1, 0,
                1, (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1))),
                (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1))))),
         1, (decode(sign(bcd1.prior_seq_num - bcd2.next_seq_num + 1),
               -1, 0,
                1, (bcd1.prior_seq_num - bcd2.next_seq_num + 1),
                (bcd1.prior_seq_num - bcd2.next_seq_num + 1))),
         (decode(sign(bcd1.prior_seq_num - bcd2.next_seq_num + 1),
               -1, 0,
                1, (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1))),
                (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1)))))),
     0,
     sum(mmta2.primary_quantity),
     ''N'',
     to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''),
     to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
from
     mtl_material_transactions mmt2,
     mtl_material_txn_allocations mmta2,
     bom_calendar_dates bcd1,
     bom_calendar_dates bcd2,
     wip_lines wl,
     wip_repetitive_schedules wrs,
     wip_repetitive_items wri,
     wip_entities we
where
     bcd1.calendar_date =
       decode(sign(trunc(wrs.last_unit_start_date) -
          to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')),
              -1, trunc(wrs.last_unit_start_date),
              1, to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''),
              trunc(wrs.last_unit_start_date))
and  bcd2.calendar_date =
       decode(sign(
          to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''') -
          trunc(wrs.first_unit_start_date)),
           -1, trunc(wrs.first_unit_start_date),
           1, to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''),
           trunc(wrs.first_unit_start_date))
and  bcd1.calendar_code = :CALENDAR_CODE
and  bcd2.calendar_code = :CALENDAR_CODE
and  bcd1.exception_set_id = :EXCEPTION_SET_ID
and  bcd2.exception_set_id = :EXCEPTION_SET_ID
and  mmt2.transaction_action_id = 30
and  mmt2.transaction_date >=
       to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
and  mmt2.transaction_date <
       to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''') + 1
and  mmt2.transaction_id = mmta2.transaction_id
and  mmta2.organization_id = mmt2.organization_id
and  mmt2.organization_id = :ORG_ID
and  mmt2.transaction_source_id = we.wip_entity_id
and  mmt2.transaction_source_type_id + 0 = 5
and  mmta2.repetitive_schedule_id = wrs.repetitive_schedule_id
and  mmta2.repetitive_schedule_id not in
 (select key2
  from   wip_temp_reports
  where  program_source = ''WIPREVAL'')
and  we.wip_entity_name between :FROM_ASSEMBLY and :TO_ASSEMBLY
and  we.entity_type = 2
and  we.organization_id = :ORG_ID
and  wrs.wip_entity_id = we.wip_entity_id
and  wl.line_code between :FROM_LINE and :TO_LINE
and  wl.organization_id = :ORG_ID
and  wrs.line_id = wl.line_id
and  wri.line_id = wrs.line_id
and  wri.class_code between :FROM_CLASS and :TO_CLASS
and  wri.organization_id = :ORG_ID
and  wri.wip_entity_id = wrs.wip_entity_id
and  wrs.organization_id = :ORG_ID
group by mmta2.repetitive_schedule_id,
   wrs.organization_id,
   wrs.wip_entity_id,
   wrs.line_id,
   wrs.repetitive_schedule_id,
   wrs.last_unit_start_date,
   wrs.processing_work_days,
   (bcd1.prior_seq_num - bcd2.next_seq_num)'
 USING
   CALENDAR_CODE , CALENDAR_CODE , EXCEPTION_SET_ID , EXCEPTION_SET_ID ,
   ORG_ID , FROM_ASSEMBLY , TO_ASSEMBLY, ORG_ID , FROM_LINE , TO_LINE , ORG_ID , FROM_CLASS , TO_CLASS , ORG_ID , ORG_ID;

--SRW.MESSAGE(8, 'DONE WITH 4 INSERTS');

EXECUTE IMMEDIATE 'insert into wip_temp_reports
 (organization_id,
  program_source,
  last_updated_by,
  wip_entity_id,
  key1,
  key2,
  key3,
  key4,
  key5,
  attribute1,
         date1,
         date2)
select /*+ RULE */
     wrs.organization_id,
     ''WIPREVAL'',
     31,
     wrs.wip_entity_id,
     wrs.line_id,
     wrs.repetitive_schedule_id,
     decode(sign(trunc(wrs.last_unit_start_date)-
        to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')),
        -1, (decode(sign(bcd1.prior_seq_num - bcd2.next_seq_num + 1),
               -1, 0,
                1, (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1))),
                (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1))))),
         1, (decode(sign(bcd1.prior_seq_num - bcd2.next_seq_num + 1),
               -1, 0,
                1, (bcd1.prior_seq_num - bcd2.next_seq_num + 1),
                (bcd1.prior_seq_num - bcd2.next_seq_num + 1))),
         (decode(sign(bcd1.prior_seq_num - bcd2.next_seq_num + 1),
               -1, 0,
                1, (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1))),
                (bcd1.prior_seq_num - bcd2.next_seq_num +
                    decode(mod(wrs.processing_work_days,1),0,1,
                     mod(wrs.processing_work_days,1)))))),
     0,
     0,
     ''Y'',
     to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''),
     to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
from
     mtl_material_transactions mmt3,
     mtl_material_txn_allocations mmta3,
     bom_calendar_dates bcd1,
     bom_calendar_dates bcd2,
     wip_lines wl,
     wip_repetitive_schedules wrs,
     wip_repetitive_items wri,
     wip_entities we
where
     bcd1.calendar_date =
       decode(sign(trunc(wrs.last_unit_start_date) -
          to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')),
           -1, trunc(wrs.last_unit_start_date),
           1, to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''),
           trunc(wrs.last_unit_start_date))
and  bcd2.calendar_date =
       decode(sign(
          to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''') -
          trunc(wrs.first_unit_start_date)),
           -1, trunc(wrs.first_unit_start_date),
           1, to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||'''),
           trunc(wrs.first_unit_start_date))
and  bcd1.calendar_code = :CALENDAR_CODE
and  bcd2.calendar_code = :CALENDAR_CODE
and  bcd1.exception_set_id = :EXCEPTION_SET_ID
and  bcd2.exception_set_id = :EXCEPTION_SET_ID
and  mmt3.transaction_action_id in (1,27,33,34)
and  mmt3.transaction_date  >=
       to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
and  mmt3.transaction_date <
       to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''') + 1
and  mmt3.transaction_id = mmta3.transaction_id
and  mmta3.organization_id = mmt3.organization_id
and  mmt3.organization_id = :ORG_ID
and  mmt3.transaction_source_id = we.wip_entity_id
and  mmt3.transaction_source_type_id + 0 = 5
and  mmta3.repetitive_schedule_id = wrs.repetitive_schedule_id
and  mmta3.repetitive_schedule_id not in
 (select key2
  from   wip_temp_reports
  where  program_source = ''WIPREVAL'')
and  we.wip_entity_name between :FROM_ASSEMBLY and :TO_ASSEMBLY
and  we.entity_type = 2
and  we.organization_id = :ORG_ID
and  wrs.wip_entity_id = we.wip_entity_id
and  wl.line_code between :FROM_LINE and :TO_LINE
and  wl.organization_id = :ORG_ID
and  wrs.line_id = wl.line_id
and  wri.line_id = wrs.line_id
and  wri.class_code between :FROM_CLASS and :TO_CLASS
and  wri.organization_id = :ORG_ID
and  wri.wip_entity_id = wrs.wip_entity_id
and  wrs.organization_id = :ORG_ID
and  mmta3.repetitive_schedule_id = wrs.repetitive_schedule_id
group by mmta3.repetitive_schedule_id,
   wrs.organization_id,
   wrs.wip_entity_id,
   wrs.line_id,
   wrs.repetitive_schedule_id,
   wrs.last_unit_start_date,
   wrs.processing_work_days,
   (bcd1.prior_seq_num - bcd2.next_seq_num)'

 USING
  CALENDAR_CODE , CALENDAR_CODE , EXCEPTION_SET_ID , EXCEPTION_SET_ID ,
  ORG_ID , FROM_ASSEMBLY , TO_ASSEMBLY , ORG_ID , FROM_LINE , TO_LINE , ORG_ID , FROM_CLASS , TO_CLASS , ORG_ID , ORG_ID;

--SRW.MESSAGE(9, 'DONE WITH 5 INSERTS');

EXECUTE IMMEDIATE 'update wip_temp_reports wtr
set    attribute1 = ''Y''
where  key2 in
  (select  /*+ RULE */
     wrs.repetitive_schedule_id
  from
     wip_repetitive_schedules wrs,
     mtl_material_transactions mmt3,
     mtl_material_txn_allocations mmta3
  where
     mmt3.transaction_action_id in (1,27,33,34)
  and  mmt3.transaction_date >=
       to_date('||''''|| C_FROM_PERIOD_START_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''')
  and  mmt3.transaction_date <
       to_date('||''''|| C_TO_PERIOD_END_DATE || ''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''') + 1
  and  mmt3.transaction_id = mmta3.transaction_id
  and  mmta3.organization_id = mmt3.organization_id
  and  mmt3.organization_id = :ORG_ID
  and  mmt3.transaction_source_id = wrs.wip_entity_id
  and  mmt3.transaction_source_type_id + 0 = 5
  and  mmta3.repetitive_schedule_id = wrs.repetitive_schedule_id
  and  wrs.repetitive_schedule_id = wtr.key2
  and  wrs.line_id = wtr.key1
  and  wrs.organization_id = :ORG_ID
  group by mmta3.repetitive_schedule_id,
     wrs.organization_id,
     wrs.wip_entity_id,
     wrs.line_id,
     wrs.repetitive_schedule_id)
and   attribute1 = ''N'''
USING
 ORG_ID , ORG_ID;

--SRW.MESSAGE(10, 'DONE WITH MATERIAL UPDATES');


-- This update is necessary, because it's possible for lusd - fusd to be
-- > processing_days.

EXECUTE IMMEDIATE 'update wip_temp_reports wtr
set    wtr.key3 = (wtr.key3 - 1)
where  wtr.program_source = ''WIPREVAL''
and    wtr.key2 =
       (select wrs.repetitive_schedule_id
        from   wip_repetitive_schedules wrs,
               bom_calendar_dates bcd1,
               bom_calendar_dates bcd2
        where  wrs.repetitive_schedule_id = wtr.key2
        and    wrs.organization_id = wtr.organization_id
        and    bcd1.calendar_date = trunc(wrs.last_unit_start_date)
        and    bcd2.calendar_date = trunc(wrs.first_unit_start_date)
        and    bcd1.calendar_code = :CALENDAR_CODE
        and    bcd2.calendar_code = :CALENDAR_CODE
        and    bcd1.exception_set_id = :EXCEPTION_SET_ID
        and    bcd2.exception_set_id = :EXCEPTION_SET_ID
        and    ((bcd1.prior_seq_num - bcd2.next_seq_num + 1)
                  > ceil(wrs.processing_work_days)))'
USING
CALENDAR_CODE , CALENDAR_CODE , EXCEPTION_SET_ID , EXCEPTION_SET_ID;

EXECUTE IMMEDIATE 'update wip_temp_reports wtr
set    wtr.key6 =
          (select wtr.key3 * wrs.daily_production_rate
           from   wip_repetitive_schedules wrs
           where  wrs.repetitive_schedule_id = wtr.key2)
where  wtr.program_source = ''WIPREVAL''';

--SRW.MESSAGE(11, 'DONE WITH INSERTS');

END;
  return (TRUE);
END;

FUNCTION GET_PRECISION RETURN VARCHAR2 IS
begin

if p_qty_precision = 0 then return('999G999G999G990');

elsif p_qty_precision = 1 then return('999G999G999G990D0');

elsif p_qty_precision = 3 then return('999G999G999G990D000');

elsif p_qty_precision = 4 then return('999G999G999G990D0000');

elsif p_qty_precision = 5 then return('999G999G999G990D00000');

elsif p_qty_precision = 6 then  return('999G999G999G990D000000');

else return('999G999G999G990D00');

end if;

END;
END WIP_WIPREVAL_XMLP_PKG;


/
