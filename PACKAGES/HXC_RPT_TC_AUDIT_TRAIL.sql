--------------------------------------------------------
--  DDL for Package HXC_RPT_TC_AUDIT_TRAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RPT_TC_AUDIT_TRAIL" AUTHID CURRENT_USER AS
/* $Header: hxcrptaudittrail.pkh 120.4.12010000.2 2008/10/30 17:07:11 asrajago ship $ */


TYPE NUMTABLE     IS TABLE OF NUMBER(15);
TYPE VARCHARTABLE IS TABLE OF VARCHAR2(2000);
TYPE DATETABLE    IS TABLE OF DATE;
TYPE FLOATTABLE   IS TABLE OF NUMBER(22,15);

TYPE TIMEDETAILSTABLE IS TABLE OF hxc_rpt_tc_details_all%ROWTYPE;
TYPE AUDITTABLE       IS TABLE OF hxc_rpt_tc_audit%ROWTYPE;

P_FROM_DATE     VARCHAR2(30);
P_TO_DATE       VARCHAR2(30);
P_DAT_REGEN     VARCHAR2(30);
P_RECORD_SAVE   VARCHAR2(30);
P_ORG_ID        NUMBER;
P_LOCN_ID       NUMBER;
P_PAYROLL_ID    NUMBER;
P_SUPERVISOR_ID NUMBER;
P_PERSON_ID     NUMBER;

LP_FROM_DATE    VARCHAR2(30);
LP_TO_DATE      VARCHAR2(30);
LP_DAT_REGEN    VARCHAR2(30);
LP_RECORD_SAVE  VARCHAR2(30);
LP_ORG          VARCHAR2(150);
LP_LOCATION     VARCHAR2(150);
LP_PAYROLL      VARCHAR2(150);
LP_SUPERVISOR   VARCHAR2(250);
LP_PERSON       VARCHAR2(250);
LP_SYSDATE      VARCHAR2(50);
LP_NO_PARM      VARCHAR2(50);
LP_USER         VARCHAR2(500);

FUNCTION afterpform RETURN BOOLEAN;

FUNCTION beforereport RETURN BOOLEAN;

FUNCTION afterreport RETURN BOOLEAN;

PROCEDURE translate_parameters;



PROCEDURE execute_audit_trail_reporting  (errbuf          OUT NOCOPY VARCHAR2,
                                          retcode         OUT NOCOPY NUMBER,
                                          p_date_from     IN  VARCHAR2 ,
                                          p_date_to       IN  VARCHAR2 ,
                                          p_data_regen    IN  VARCHAR2 ,
                                          p_record_save   IN  VARCHAR2 ,
                                          p_org_id        IN  NUMBER DEFAULT NULL,
                                          p_locn_id       IN  NUMBER DEFAULT NULL,
                                          p_payroll_id    IN  NUMBER DEFAULT NULL,
                                          p_supervisor_id IN  NUMBER DEFAULT NULL,
                                          p_person_id     IN  NUMBER DEFAULT NULL );



END HXC_RPT_TC_AUDIT_TRAIL;


/
