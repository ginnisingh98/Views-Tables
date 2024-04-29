--------------------------------------------------------
--  DDL for Package Body DDR_TIME_TRANSFORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DDR_TIME_TRANSFORM_PKG" AS
/* $Header: ddrttfmb.pls 120.2 2008/03/24 11:06:40 sdaga noship $ */
  g_src_sys_idnt          VARCHAR2(40) := 'SQL-Script';
  g_src_sys_dt            DATE := sysdate;
  g_crtd_by_DSR           VARCHAR2(30) := USER;
  g_last_updt_by_DSR      VARCHAR2(30) := USER;
  g_created_by            NUMBER(15) := -1;
  g_creation_date         DATE := sysdate;
  g_last_updated_by       NUMBER(15) := -1;
  g_last_update_date      DATE := sysdate;
  g_last_update_login     NUMBER(15) := -1;

  FUNCTION Add_Day (p_day_code IN VARCHAR2,p_no_of_days IN NUMBER DEFAULT 1)
  RETURN VARCHAR2
  AS
      l_new_day_code    VARCHAR2(10);
  BEGIN
      l_new_day_code := TO_CHAR(TO_DATE(p_day_code,'YYYYMMDD') + p_no_of_days,'YYYYMMDD');
      RETURN l_new_day_code;
  END Add_Day;

  FUNCTION Add_Week (p_week_code IN VARCHAR2,p_no_of_weeks IN NUMBER DEFAULT 1)
  RETURN VARCHAR2
  AS
      l_year_no         NUMBER;
      l_week_no         NUMBER;
      l_no_of_weeks     NUMBER;
      l_new_year_no     NUMBER;
      l_new_week_no     NUMBER;
      l_new_week_code   VARCHAR2(10);
      l_max_week_no     NUMBER := 52;
  BEGIN
      IF p_no_of_weeks = 0 THEN RETURN p_week_code; END IF;

      l_year_no := TO_NUMBER(SUBSTR(p_week_code,1,4));
      l_week_no := TO_NUMBER(SUBSTR(p_week_code,5));
      l_no_of_weeks := ABS(p_no_of_weeks);

      IF p_no_of_weeks > 0
      THEN
          IF (l_max_week_no-l_week_no) >= l_no_of_weeks
          THEN
              l_new_year_no := l_year_no;
              l_new_week_no := l_week_no + l_no_of_weeks;
          ELSE
              l_new_year_no := l_year_no + FLOOR((l_no_of_weeks-(l_max_week_no-l_week_no))/l_max_week_no) + 1;
              l_new_week_no := MOD(l_no_of_weeks-(l_max_week_no-l_week_no),l_max_week_no);
          END IF;
      ELSE /* i.e. p_no_of_weeks < 0 */
          IF l_week_no > l_no_of_weeks
          THEN
              l_new_year_no := l_year_no;
              l_new_week_no := l_week_no - l_no_of_weeks;
          ELSE
              l_new_year_no := l_year_no - FLOOR((l_no_of_weeks-l_week_no)/l_max_week_no) - 1;
              l_new_week_no := l_max_week_no - MOD(l_no_of_weeks-l_week_no,l_max_week_no);
          END IF;
      END IF;

      l_new_week_code := TO_CHAR(l_new_year_no) || LPAD(TO_CHAR(l_new_week_no),2,'0');
      RETURN l_new_week_code;
  END Add_Week;

  FUNCTION Add_Month (p_month_code IN VARCHAR2,p_no_of_months IN NUMBER DEFAULT 1)
  RETURN VARCHAR2
  AS
      l_new_month_code    VARCHAR2(10);
  BEGIN
      l_new_month_code := TO_CHAR(ADD_MONTHS(TO_DATE(p_month_code,'YYYYMM'),p_no_of_months),'YYYYMM');
      RETURN l_new_month_code;
  END Add_Month;

  FUNCTION Add_Quarter (p_qtr_code IN VARCHAR2,p_no_of_qtrs IN NUMBER DEFAULT 1)
  RETURN VARCHAR2
  AS
      l_year_no         NUMBER;
      l_qtr_no          NUMBER;
      l_no_of_qtrs      NUMBER;
      l_new_year_no     NUMBER;
      l_new_qtr_no      NUMBER;
      l_new_qtr_code    VARCHAR2(10);
      l_max_qtr_no      NUMBER := 4;
  BEGIN
      IF p_no_of_qtrs = 0 THEN RETURN p_qtr_code; END IF;

      l_year_no := TO_NUMBER(SUBSTR(p_qtr_code,1,4));
      l_qtr_no := TO_NUMBER(SUBSTR(p_qtr_code,5));
      l_no_of_qtrs := ABS(p_no_of_qtrs);

      IF p_no_of_qtrs > 0
      THEN
          IF (l_max_qtr_no-l_qtr_no) >= l_no_of_qtrs
          THEN
              l_new_year_no := l_year_no;
              l_new_qtr_no := l_qtr_no + l_no_of_qtrs;
          ELSE
              l_new_year_no := l_year_no + FLOOR((l_no_of_qtrs-(l_max_qtr_no-l_qtr_no))/l_max_qtr_no) + 1;
              l_new_qtr_no := MOD(l_no_of_qtrs-(l_max_qtr_no-l_qtr_no),l_max_qtr_no);
          END IF;
      ELSE /* i.e. p_no_of_qtrs < 0 */
          IF l_qtr_no > l_no_of_qtrs
          THEN
              l_new_year_no := l_year_no;
              l_new_qtr_no := l_qtr_no - l_no_of_qtrs;
          ELSE
              l_new_year_no := l_year_no - FLOOR((l_no_of_qtrs-l_qtr_no)/l_max_qtr_no) - 1;
              l_new_qtr_no := l_max_qtr_no - MOD(l_no_of_qtrs-l_qtr_no,l_max_qtr_no);
          END IF;
      END IF;

      l_new_qtr_code := TO_CHAR(l_new_year_no) || TO_CHAR(l_new_qtr_no);
      RETURN l_new_qtr_code;
  END Add_Quarter;

  PROCEDURE Populate_BSNS_Transformation (
        p_org_cd          IN VARCHAR2,
        p_start_year      IN NUMBER,
        p_end_year        IN NUMBER
  )
  AS
  BEGIN

      /* Populate DDR_R_DAY_TRANS table */
      delete from DDR_R_DAY_TRANS
      where  (DAY_CD,CLNDR_CD) in (
              select DAY_CD,CLNDR_CD
              from   DDR_TIME_BSNS_DAY_V
              where  ORG_CD = p_org_cd
              and    YR_CD between to_char(p_start_year) and to_char(p_end_year)
          );

      insert into DDR_R_DAY_TRANS (
          MFG_ORG_CD,
          DAY_TRANS_ID,
          DAY_CD,
          CLNDR_CD,
          CLNDR_TYP,
          LAST_DAY_THIS_YR_CD,
          LAST_WK_THIS_DAY_CD,
          LAST_MNTH_THIS_DAY_CD,
          LAST_PRD_THIS_DAY_CD,
          LAST_QTR_THIS_DAY_CD,
          LAST_YR_THIS_DAY_CD,
          NXT_DAY_THIS_YR_CD,
          NXT_WK_THIS_DAY_CD,
          NXT_MNTH_THIS_DAY_CD,
          NXT_PRD_THIS_DAY_CD,
          NXT_QTR_THIS_DAY_CD,
          NXT_YR_THIS_DAY_CD,
          SRC_SYS_IDNT,
          SRC_SYS_DT,
          CRTD_BY_DSR,
          LAST_UPDT_BY_DSR,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN
      )
      select
          BDAY.MFG_ORG_CD,
          DDR_R_DAY_TRANS_SEQ.NEXTVAL,
          BDAY.DAY_CD,
          BDAY.CLNDR_CD,
          'BSNS',
          PDAY.DAY_CD,
          PWK.DAY_CD,
          PMNTH.DAY_CD,
          null,
          PQTR.DAY_CD,
          PYR.DAY_CD,
          NDAY.DAY_CD,
          NWK.DAY_CD,
          NMNTH.DAY_CD,
          null,
          NQTR.DAY_CD,
          NYR.DAY_CD,
          g_src_sys_idnt,
          g_src_sys_dt,
          g_crtd_by_DSR,
          g_last_updt_by_DSR,
          g_created_by,
          g_creation_date,
          g_last_updated_by,
          g_last_update_date,
          g_last_update_login
      from
            DDR_TIME_BSNS_DAY_V BDAY,
            DDR_TIME_BSNS_DAY_V PDAY,
            DDR_TIME_BSNS_DAY_V PWK,
            DDR_TIME_BSNS_DAY_V PMNTH,
            DDR_TIME_BSNS_DAY_V PQTR,
            DDR_TIME_BSNS_DAY_V PYR,
            DDR_TIME_BSNS_DAY_V NDAY,
            DDR_TIME_BSNS_DAY_V NWK,
            DDR_TIME_BSNS_DAY_V NMNTH,
            DDR_TIME_BSNS_DAY_V NQTR,
            DDR_TIME_BSNS_DAY_V NYR
      where BDAY.ORG_CD = p_org_cd
      and   BDAY.YR_CD between to_char(p_start_year) and to_char(p_end_year)
      and   PDAY.ORG_CD(+) = BDAY.ORG_CD
      and   PDAY.CLNDR_CD(+) = BDAY.CLNDR_CD
      and   PDAY.DAY_CD(+) = add_day(BDAY.DAY_CD,-1)
      and   PWK.ORG_CD(+) = BDAY.ORG_CD
      and   PWK.CLNDR_CD(+) = BDAY.CLNDR_CD
      and   PWK.DAY_CD(+) = add_day(BDAY.DAY_CD,-7)
      and   PMNTH.ORG_CD(+) = BDAY.ORG_CD
      and   PMNTH.CLNDR_CD(+) = BDAY.CLNDR_CD
      and   PMNTH.DAY_CD(+) = add_day(BDAY.DAY_CD,-30)
      and   PQTR.ORG_CD(+) = BDAY.ORG_CD
      and   PQTR.CLNDR_CD(+) = BDAY.CLNDR_CD
      and   PQTR.DAY_CD(+) = add_day(BDAY.DAY_CD,-91)
      and   PYR.ORG_CD(+) = BDAY.ORG_CD
      and   PYR.CLNDR_CD(+) = BDAY.CLNDR_CD
      and   PYR.DAY_CD(+) = add_day(BDAY.DAY_CD,-364)
      and   NDAY.ORG_CD(+) = BDAY.ORG_CD
      and   NDAY.CLNDR_CD(+) = BDAY.CLNDR_CD
      and   NDAY.DAY_CD(+) = add_day(BDAY.DAY_CD,1)
      and   NWK.ORG_CD(+) = BDAY.ORG_CD
      and   NWK.CLNDR_CD(+) = BDAY.CLNDR_CD
      and   NWK.DAY_CD(+) = add_day(BDAY.DAY_CD,7)
      and   NMNTH.ORG_CD(+) = BDAY.ORG_CD
      and   NMNTH.CLNDR_CD(+) = BDAY.CLNDR_CD
      and   NMNTH.DAY_CD(+) = add_day(BDAY.DAY_CD,30)
      and   NQTR.ORG_CD(+) = BDAY.ORG_CD
      and   NQTR.CLNDR_CD(+) = BDAY.CLNDR_CD
      and   NQTR.DAY_CD(+) = add_day(BDAY.DAY_CD,91)
      and   NYR.ORG_CD(+) = BDAY.ORG_CD
      and   NYR.CLNDR_CD(+) = BDAY.CLNDR_CD
      and   NYR.DAY_CD(+) = add_day(BDAY.DAY_CD,364)
      ;

      /* Populate DDR_R_WK_TRANS table */
      delete from DDR_R_WK_TRANS
      where  (WK_CD,CLNDR_CD) in (
              select WK_CD,CLNDR_CD
              from   DDR_TIME_BSNS_WK_V
              where  ORG_CD = p_org_cd
              and    YR_CD between to_char(p_start_year) and to_char(p_end_year)
          );

      insert into DDR_R_WK_TRANS (
          MFG_ORG_CD,
          WK_TRANS_ID,
          WK_ID,
          WK_CD,
          CLNDR_CD,
          CLNDR_TYP,
          LAST_WK_THIS_YR_ID,
          LAST_WK_THIS_YR_CD,
          LAST_MNTH_THIS_WK_ID,
          LAST_MNTH_THIS_WK_CD,
          LAST_PRD_THIS_WK_ID,
          LAST_PRD_THIS_WK_CD,
          LAST_QTR_THIS_WK_ID,
          LAST_QTR_THIS_WK_CD,
          LAST_YR_THIS_WK_ID,
          LAST_YR_THIS_WK_CD,
          NXT_WK_THIS_YR_WK_ID,
          NXT_WK_THIS_YR_WK_CD,
          NXT_MNTH_THIS_WK_ID,
          NXT_MNTH_THIS_WK_CD,
          NXT_PRD_THIS_WK_ID,
          NXT_PRD_THIS_WK_CD,
          NXT_QTR_THIS_WK_ID,
          NXT_QTR_THIS_WK_CD,
          NXT_YR_THIS_WK_ID,
          NXT_YR_THIS_WK_CD,
          SRC_SYS_IDNT,
          SRC_SYS_DT,
          CRTD_BY_DSR,
          LAST_UPDT_BY_DSR,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN
      )
      select
          WK.MFG_ORG_CD,
          DDR_R_WK_TRANS_SEQ.NEXTVAL,
          WK.WK_ID,
          WK.WK_CD,
          WK.CLNDR_CD,
          'BSNS',
          PWK.WK_ID,
          PWK.WK_CD,
          PMNTH.WK_ID,
          PMNTH.WK_CD,
          null,
          null,
          PQTR.WK_ID,
          PQTR.WK_CD,
          PYR.WK_ID,
          PYR.WK_CD,
          NWK.WK_ID,
          NWK.WK_CD,
          NMNTH.WK_ID,
          NMNTH.WK_CD,
          null,
          null,
          NQTR.WK_ID,
          NQTR.WK_CD,
          NYR.WK_ID,
          NYR.WK_CD,
          g_src_sys_idnt,
          g_src_sys_dt,
          g_crtd_by_DSR,
          g_last_updt_by_DSR,
          g_created_by,
          g_creation_date,
          g_last_updated_by,
          g_last_update_date,
          g_last_update_login
      from
            DDR_TIME_BSNS_WK_V WK,
            DDR_TIME_BSNS_WK_V PWK,
            DDR_TIME_BSNS_WK_V PMNTH,
            DDR_TIME_BSNS_WK_V PQTR,
            DDR_TIME_BSNS_WK_V PYR,
            DDR_TIME_BSNS_WK_V NWK,
            DDR_TIME_BSNS_WK_V NMNTH,
            DDR_TIME_BSNS_WK_V NQTR,
            DDR_TIME_BSNS_WK_V NYR
      where WK.ORG_CD = p_org_cd
      and   WK.YR_CD between to_char(p_start_year) and to_char(p_end_year)
      and   PWK.ORG_CD(+) = WK.ORG_CD
      and   PWK.CLNDR_CD(+) = WK.CLNDR_CD
      and   PWK.WK_CD(+) = add_week(WK.WK_CD,-1)
      and   PMNTH.ORG_CD(+) = WK.ORG_CD
      and   PMNTH.CLNDR_CD(+) = WK.CLNDR_CD
      and   PMNTH.WK_CD(+) = add_week(WK.WK_CD,-4)
      and   PQTR.ORG_CD(+) = WK.ORG_CD
      and   PQTR.CLNDR_CD(+) = WK.CLNDR_CD
      and   PQTR.WK_CD(+) = add_week(WK.WK_CD,-13)
      and   PYR.ORG_CD(+) = WK.ORG_CD
      and   PYR.CLNDR_CD(+) = WK.CLNDR_CD
      and   PYR.WK_CD(+) = add_week(WK.WK_CD,-52)
      and   NWK.ORG_CD(+) = WK.ORG_CD
      and   NWK.CLNDR_CD(+) = WK.CLNDR_CD
      and   NWK.WK_CD(+) = add_week(WK.WK_CD,1)
      and   NMNTH.ORG_CD(+) = WK.ORG_CD
      and   NMNTH.CLNDR_CD(+) = WK.CLNDR_CD
      and   NMNTH.WK_CD(+) = add_week(WK.WK_CD,4)
      and   NQTR.ORG_CD(+) = WK.ORG_CD
      and   NQTR.CLNDR_CD(+) = WK.CLNDR_CD
      and   NQTR.WK_CD(+) = add_week(WK.WK_CD,13)
      and   NYR.ORG_CD(+) = WK.ORG_CD
      and   NYR.CLNDR_CD(+) = WK.CLNDR_CD
      and   NYR.WK_CD(+) = add_week(WK.WK_CD,52)
      ;

      /* Populate DDR_R_MNTH_TRANS table */
      delete from DDR_R_MNTH_TRANS
      where  (MNTH_CD,CLNDR_CD) in (
              select MNTH_CD,CLNDR_CD
              from   DDR_TIME_BSNS_MNTH_V
              where  ORG_CD = p_org_cd
              and    YR_CD between to_char(p_start_year) and to_char(p_end_year)
          );

      insert into DDR_R_MNTH_TRANS (
          MFG_ORG_CD,
          MNTH_TRANS_ID,
          MNTH_ID,
          MNTH_CD,
          CLNDR_CD,
          CLNDR_TYP,
          LAST_MNTH_THIS_YR_ID,
          LAST_MNTH_THIS_YR_CD,
          LAST_QTR_THIS_MNTH_ID,
          LAST_QTR_THIS_MNTH_CD,
          LAST_YR_THIS_MNTH_ID,
          LAST_YR_THIS_MNTH_CD,
          NXT_MNTH_THIS_YR_ID,
          NXT_MNTH_THIS_YR_CD,
          NXT_QTR_THIS_MNTH_ID,
          NXT_QTR_THIS_MNTH_CD,
          NXT_YR_THIS_MNTH_ID,
          NXT_YR_THIS_MNTH_CD,
          SRC_SYS_IDNT,
          SRC_SYS_DT,
          CRTD_BY_DSR,
          LAST_UPDT_BY_DSR,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN
      )
      select
          MNTH.MFG_ORG_CD,
          DDR_R_MNTH_TRANS_SEQ.NEXTVAL,
          MNTH.MNTH_ID,
          MNTH.MNTH_CD,
          MNTH.CLNDR_CD,
          'BSNS',
          PMNTH.MNTH_ID,
          PMNTH.MNTH_CD,
          PQTR.MNTH_ID,
          PQTR.MNTH_CD,
          PYR.MNTH_ID,
          PYR.MNTH_CD,
          NMNTH.MNTH_ID,
          NMNTH.MNTH_CD,
          NQTR.MNTH_ID,
          NQTR.MNTH_CD,
          NYR.MNTH_ID,
          NYR.MNTH_CD,
          g_src_sys_idnt,
          g_src_sys_dt,
          g_crtd_by_DSR,
          g_last_updt_by_DSR,
          g_created_by,
          g_creation_date,
          g_last_updated_by,
          g_last_update_date,
          g_last_update_login
      from
            DDR_TIME_BSNS_MNTH_V MNTH,
            DDR_TIME_BSNS_MNTH_V PMNTH,
            DDR_TIME_BSNS_MNTH_V PQTR,
            DDR_TIME_BSNS_MNTH_V PYR,
            DDR_TIME_BSNS_MNTH_V NMNTH,
            DDR_TIME_BSNS_MNTH_V NQTR,
            DDR_TIME_BSNS_MNTH_V NYR
      where MNTH.ORG_CD = p_org_cd
      and   MNTH.YR_CD between to_char(p_start_year) and to_char(p_end_year)
      and   PMNTH.ORG_CD(+) = MNTH.ORG_CD
      and   PMNTH.CLNDR_CD(+) = MNTH.CLNDR_CD
      and   PMNTH.MNTH_CD(+) = add_month(MNTH.MNTH_CD,-1)
      and   PQTR.ORG_CD(+) = MNTH.ORG_CD
      and   PQTR.CLNDR_CD(+) = MNTH.CLNDR_CD
      and   PQTR.MNTH_CD(+) = add_month(MNTH.MNTH_CD,-3)
      and   PYR.ORG_CD(+) = MNTH.ORG_CD
      and   PYR.CLNDR_CD(+) = MNTH.CLNDR_CD
      and   PYR.MNTH_CD(+) = add_month(MNTH.MNTH_CD,-12)
      and   NMNTH.ORG_CD(+) = MNTH.ORG_CD
      and   NMNTH.CLNDR_CD(+) = MNTH.CLNDR_CD
      and   NMNTH.MNTH_CD(+) = add_month(MNTH.MNTH_CD,1)
      and   NQTR.ORG_CD(+) = MNTH.ORG_CD
      and   NQTR.CLNDR_CD(+) = MNTH.CLNDR_CD
      and   NQTR.MNTH_CD(+) = add_month(MNTH.MNTH_CD,3)
      and   NYR.ORG_CD(+) = MNTH.ORG_CD
      and   NYR.CLNDR_CD(+) = MNTH.CLNDR_CD
      and   NYR.MNTH_CD(+) = add_month(MNTH.MNTH_CD,12)
      ;

      /* Populate DDR_R_QTR_TRANS table */
      delete from DDR_R_QTR_TRANS
      where  (QTR_CD,CLNDR_CD) in (
              select QTR_CD,CLNDR_CD
              from   DDR_TIME_BSNS_QTR_V
              where  ORG_CD = p_org_cd
              and    YR_CD between to_char(p_start_year) and to_char(p_end_year)
          );

      insert into DDR_R_QTR_TRANS (
          MFG_ORG_CD,
          QTR_TRANS_ID,
          QTR_ID,
          QTR_CD,
          CLNDR_CD,
          CLNDR_TYP,
          LAST_QTR_THIS_YR_ID,
          LAST_QTR_THIS_YR_CD,
          LAST_YR_THIS_QTR_ID,
          LAST_YR_THIS_QTR_CD,
          NXT_QTR_THIS_YR_ID,
          NXT_QTR_THIS_YR_CD,
          NXT_YR_THIS_QTR_ID,
          NXT_YR_THIS_QTR_CD,
          SRC_SYS_IDNT,
          SRC_SYS_DT,
          CRTD_BY_DSR,
          LAST_UPDT_BY_DSR,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN
      )
      select
          QTR.MFG_ORG_CD,
          DDR_R_QTR_TRANS_SEQ.NEXTVAL,
          QTR.QTR_ID,
          QTR.QTR_CD,
          QTR.CLNDR_CD,
          'BSNS',
          PQTR.QTR_ID,
          PQTR.QTR_CD,
          PYR.QTR_ID,
          PYR.QTR_CD,
          NQTR.QTR_ID,
          NQTR.QTR_CD,
          NYR.QTR_ID,
          NYR.QTR_CD,
          g_src_sys_idnt,
          g_src_sys_dt,
          g_crtd_by_DSR,
          g_last_updt_by_DSR,
          g_created_by,
          g_creation_date,
          g_last_updated_by,
          g_last_update_date,
          g_last_update_login
      from
            DDR_TIME_BSNS_QTR_V QTR,
            DDR_TIME_BSNS_QTR_V PQTR,
            DDR_TIME_BSNS_QTR_V PYR,
            DDR_TIME_BSNS_QTR_V NQTR,
            DDR_TIME_BSNS_QTR_V NYR
      where QTR.ORG_CD = p_org_cd
      and   QTR.YR_CD between to_char(p_start_year) and to_char(p_end_year)
      and   PQTR.ORG_CD(+) = QTR.ORG_CD
      and   PQTR.CLNDR_CD(+) = QTR.CLNDR_CD
      and   PQTR.QTR_CD(+) = add_quarter(QTR.QTR_CD,-1)
      and   PYR.ORG_CD(+) = QTR.ORG_CD
      and   PYR.CLNDR_CD(+) = QTR.CLNDR_CD
      and   PYR.QTR_CD(+) = add_quarter(QTR.QTR_CD,-4)
      and   NQTR.ORG_CD(+) = QTR.ORG_CD
      and   NQTR.CLNDR_CD(+) = QTR.CLNDR_CD
      and   NQTR.QTR_CD(+) = add_quarter(QTR.QTR_CD,1)
      and   NYR.ORG_CD(+) = QTR.ORG_CD
      and   NYR.CLNDR_CD(+) = QTR.CLNDR_CD
      and   NYR.QTR_CD(+) = add_quarter(QTR.QTR_CD,4)
      ;

      /* Populate DDR_R_YR_TRANS table */
      delete from DDR_R_YR_TRANS
      where  (YR_CD,CLNDR_CD) in (
              select YR_CD,CLNDR_CD
              from   DDR_TIME_BSNS_YR_V
              where  ORG_CD = p_org_cd
              and    YR_CD between to_char(p_start_year) and to_char(p_end_year)
          );

      insert into DDR_R_YR_TRANS (
          MFG_ORG_CD,
          YR_TRANS_ID,
          YR_ID,
          YR_CD,
          CLNDR_CD,
          CLNDR_TYP,
          LAST_YR_ID,
          LAST_YR_CD,
          NXT_YR_ID,
          NXT_YR_CD,
          SRC_SYS_IDNT,
          SRC_SYS_DT,
          CRTD_BY_DSR,
          LAST_UPDT_BY_DSR,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN
      )
      select
          YR.MFG_ORG_CD,
          DDR_R_YR_TRANS_SEQ.NEXTVAL,
          YR.YR_ID,
          YR.YR_CD,
          YR.CLNDR_CD,
          'BSNS',
          PYR.YR_ID,
          PYR.YR_CD,
          NYR.YR_ID,
          NYR.YR_CD,
          g_src_sys_idnt,
          g_src_sys_dt,
          g_crtd_by_DSR,
          g_last_updt_by_DSR,
          g_created_by,
          g_creation_date,
          g_last_updated_by,
          g_last_update_date,
          g_last_update_login
      from
            DDR_TIME_BSNS_YR_V YR,
            DDR_TIME_BSNS_YR_V PYR,
            DDR_TIME_BSNS_YR_V NYR
      where YR.ORG_CD = p_org_cd
      and   YR.YR_CD between to_char(p_start_year) and to_char(p_end_year)
      and   PYR.ORG_CD(+) = YR.ORG_CD
      and   PYR.CLNDR_CD(+) = YR.CLNDR_CD
      and   PYR.YR_CD(+) = YR.YR_CD - 1
      and   NYR.ORG_CD(+) = YR.ORG_CD
      and   NYR.CLNDR_CD(+) = YR.CLNDR_CD
      and   NYR.YR_CD(+) = YR.YR_CD + 1
      ;

			/*Starting data population for todate transformations*/
			/* Populate DDR_R_DAY_TODATE_TRANS table */
			delete from DDR_R_DAY_TODATE_TRANS
				where  (DAY_CD,CLNDR_CD) in (
				select DAY_CD,CLNDR_CD
				from   DDR_TIME_BSNS_DAY_V
				where  ORG_CD = p_org_cd
				and    YR_CD between to_char(p_start_year) and to_char(p_end_year)
				);

			INSERT INTO DDR_R_DAY_TODATE_TRANS(
				MFG_ORG_CD,
				DAY_TODATE_TRANS_ID,
				DAY_CD,
				CLNDR_CD,
				CLNDR_TYP,
				YR_DAY_CD,
				SRC_SYS_IDNT,
				SRC_SYS_DT,
				CRTD_BY_DSR ,
				LAST_UPDT_BY_DSR  ,
				CREATED_BY  ,
				CREATION_DATE  ,
				LAST_UPDATED_BY   ,
				LAST_UPDATE_DATE   ,
				LAST_UPDATE_LOGIN
				)
				select
				YTD.MFG_ORG_CD,
				DDR_R_DAY_TODATE_TRANS_SEQ.NEXTVAL,
				YTD.DAY_CD,
				YTD.CLNDR_CD,
				'BSNS',
				YTD.YR_DAY_CD,
				g_src_sys_idnt,
				g_src_sys_dt,
				g_crtd_by_DSR,
				g_last_updt_by_DSR,
				g_created_by,
				g_creation_date,
				g_last_updated_by,
				g_last_update_date,
				g_last_update_login
			FROM
				(SELECT
				A.MFG_ORG_CD MFG_ORG_CD,
				A.DAY_CD DAY_CD,
				A.CLNDR_CD CLNDR_CD,
				B.DAY_CD YR_DAY_CD
				FROM DDR_TIME_BSNS_DAY_V A,
				DDR_TIME_BSNS_DAY_V B
				WHERE A.YR_CD = B.YR_CD
				AND A.DAY_CD >= B.DAY_CD
				AND A.ORG_CD = B.ORG_CD
				AND A.ORG_CD = p_org_cd
				AND A.YR_CD between to_char(p_start_year) and to_char(p_end_year)
				ORDER BY A.DAY_CD,
				B.DAY_CD) YTD;

			/* Populate DDR_R_WK_TODATE_TRANS table */
			delete from DDR_R_WK_TODATE_TRANS
			where  (WK_CD,CLNDR_CD) in (
				select WK_CD,CLNDR_CD
				from   DDR_TIME_BSNS_WK_V
				where  ORG_CD = p_org_cd
				and    YR_CD between to_char(p_start_year) and to_char(p_end_year)
				);

			INSERT INTO DDR_R_WK_TODATE_TRANS(
				MFG_ORG_CD,
				WK_TODATE_TRANS_ID,
				WK_ID,
				WK_CD,
				CLNDR_CD,
				CLNDR_TYP,
				YR_WK_ID,
				YR_WK_CD,
				SRC_SYS_IDNT,
				SRC_SYS_DT,
				CRTD_BY_DSR ,
				LAST_UPDT_BY_DSR  ,
				CREATED_BY  ,
				CREATION_DATE  ,
				LAST_UPDATED_BY   ,
				LAST_UPDATE_DATE   ,
				LAST_UPDATE_LOGIN
				)
				select
				YTD.MFG_ORG_CD,
				DDR_R_WK_TODATE_TRANS_SEQ.NEXTVAL,
				YTD.WK_ID,
				YTD.WK_CD,
				YTD.CLNDR_CD,
				'BSNS',
				YTD.YR_WK_ID,
				YTD.YR_WK_CD,
				g_src_sys_idnt,
				g_src_sys_dt,
				g_crtd_by_DSR,
				g_last_updt_by_DSR,
				g_created_by,
				g_creation_date,
				g_last_updated_by,
				g_last_update_date,
				g_last_update_login
			FROM
				(SELECT
				A.MFG_ORG_CD MFG_ORG_CD,
				A.WK_CD WK_CD,
				A.WK_ID WK_ID,
				A.CLNDR_CD CLNDR_CD,
				B.WK_CD YR_WK_CD,
				B.WK_ID YR_WK_ID
				FROM DDR_TIME_BSNS_WK_V A,
				DDR_TIME_BSNS_WK_V B
				WHERE A.YR_CD = B.YR_CD
				AND A.WK_CD >= B.WK_CD
				AND A.ORG_CD = B.ORG_CD
				AND A.ORG_CD = p_org_cd
				AND A.YR_CD between to_char(p_start_year) and to_char(p_end_year)
				ORDER BY A.WK_CD,
				B.WK_CD) YTD;

			/* Populate DDR_R_MNTH_TODATE_TRANS table */
			delete from DDR_R_MNTH_TODATE_TRANS
			where  (MNTH_CD,CLNDR_CD) in (
				select MNTH_CD,CLNDR_CD
				from   DDR_TIME_BSNS_MNTH_V
				where  ORG_CD = p_org_cd
				and    YR_CD between to_char(p_start_year) and to_char(p_end_year)
				);

			INSERT INTO DDR_R_MNTH_TODATE_TRANS(
				MFG_ORG_CD,
				MNTH_TODATE_TRANS_ID,
				MNTH_ID,
				MNTH_CD,
				CLNDR_CD,
				CLNDR_TYP,
				YR_MNTH_ID,
				YR_MNTH_CD,
				SRC_SYS_IDNT,
				SRC_SYS_DT,
				CRTD_BY_DSR ,
				LAST_UPDT_BY_DSR  ,
				CREATED_BY  ,
				CREATION_DATE  ,
				LAST_UPDATED_BY   ,
				LAST_UPDATE_DATE   ,
				LAST_UPDATE_LOGIN
				)
				select
				YTD.MFG_ORG_CD,
				DDR_R_MNTH_TODATE_TRANS_SEQ.NEXTVAL,
				YTD.MNTH_ID,
				YTD.MNTH_CD,
				YTD.CLNDR_CD,
				'BSNS',
				YTD.YR_MNTH_ID,
				YTD.YR_MNTH_CD,
				g_src_sys_idnt,
				g_src_sys_dt,
				g_crtd_by_DSR,
				g_last_updt_by_DSR,
				g_created_by,
				g_creation_date,
				g_last_updated_by,
				g_last_update_date,
				g_last_update_login
			FROM
				(SELECT
				A.MFG_ORG_CD MFG_ORG_CD,
				A.MNTH_CD MNTH_CD,
				A.MNTH_ID MNTH_ID,
				A.CLNDR_CD CLNDR_CD,
				B.MNTH_CD YR_MNTH_CD,
				B.MNTH_ID YR_MNTH_ID
				FROM DDR_TIME_BSNS_MNTH_V A,
				DDR_TIME_BSNS_MNTH_V B
				WHERE A.YR_CD = B.YR_CD
				AND A.MNTH_CD >= B.MNTH_CD
				AND A.ORG_CD = B.ORG_CD
				AND A.ORG_CD = p_org_cd
				AND A.YR_CD between to_char(p_start_year) and to_char(p_end_year)
				ORDER BY A.MNTH_CD,
				B.MNTH_CD) YTD;

			/* Populate DDR_R_QTR_TODATE_TRANS table */
			delete from DDR_R_QTR_TODATE_TRANS
			where  (QTR_CD,CLNDR_CD) in (
				select QTR_CD,CLNDR_CD
				from   DDR_TIME_BSNS_QTR_V
				where  ORG_CD = p_org_cd
				and    YR_CD between to_char(p_start_year) and to_char(p_end_year)
				);

			INSERT INTO DDR_R_QTR_TODATE_TRANS(
				MFG_ORG_CD,
				QTR_TODATE_TRANS_ID,
				QTR_ID,
				QTR_CD,
				CLNDR_CD,
				CLNDR_TYP,
				YR_QTR_ID,
				YR_QTR_CD,
				SRC_SYS_IDNT,
				SRC_SYS_DT,
				CRTD_BY_DSR ,
				LAST_UPDT_BY_DSR  ,
				CREATED_BY  ,
				CREATION_DATE  ,
				LAST_UPDATED_BY   ,
				LAST_UPDATE_DATE   ,
				LAST_UPDATE_LOGIN
				)
				select
				YTD.MFG_ORG_CD,
				DDR_R_QTR_TODATE_TRANS_SEQ.NEXTVAL,
				YTD.QTR_ID,
				YTD.QTR_CD,
				YTD.CLNDR_CD,
				'BSNS',
				YTD.YR_QTR_ID,
				YTD.YR_QTR_CD,
				g_src_sys_idnt,
				g_src_sys_dt,
				g_crtd_by_DSR,
				g_last_updt_by_DSR,
				g_created_by,
				g_creation_date,
				g_last_updated_by,
				g_last_update_date,
				g_last_update_login
			FROM
				(SELECT
				A.MFG_ORG_CD MFG_ORG_CD,
				A.QTR_CD QTR_CD,
				A.QTR_ID QTR_ID,
				A.CLNDR_CD CLNDR_CD,
				B.QTR_CD YR_QTR_CD,
				B.QTR_ID YR_QTR_ID
				FROM DDR_TIME_BSNS_QTR_V A,
				DDR_TIME_BSNS_QTR_V B
				WHERE A.YR_CD = B.YR_CD
				AND A.QTR_CD >= B.QTR_CD
				AND A.ORG_CD = B.ORG_CD
				AND A.ORG_CD = p_org_cd
				AND A.YR_CD between to_char(p_start_year) and to_char(p_end_year)
				ORDER BY A.QTR_CD,
				B.QTR_CD) YTD;

      COMMIT;
  END Populate_BSNS_Transformation;

END ddr_time_transform_pkg;

/
