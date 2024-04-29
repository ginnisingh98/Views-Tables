--------------------------------------------------------
--  DDL for Package Body DDR_POP_CALENDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DDR_POP_CALENDAR_PKG" AS
/* $Header: ddrcldrb.pls 120.6.12010000.2 2010/03/03 04:06:52 vbhave ship $ */

  /* SURROGATE KEY format for each level */
  g_YR_ID_format        VARCHAR2(10) := 'YYYYMMDD'; -- Start day of Year
  g_QTR_ID_format       VARCHAR2(10) := 'YYYYMMDD'; -- Start day of Quarter
  g_MNTH_ID_format      VARCHAR2(10) := 'YYYYMMDD'; -- Start day of Month
  g_PRD_ID_format       VARCHAR2(10) := 'YYYYMMDD'; -- Start day of Period
  g_WK_ID_format        VARCHAR2(10) := 'YYYYMMDD'; -- Start day of Week
  g_DAY_ID_format       VARCHAR2(10) := 'YYYYMMDD'; -- Each Day

  g_src_sys_idnt          VARCHAR2(40) := 'SQL-Script';
  g_src_sys_dt            DATE := sysdate;
  g_crtd_by_DSR           VARCHAR2(30) := USER;
  g_last_updt_by_DSR      VARCHAR2(30) := USER;
  g_created_by            NUMBER(15) := -1;
  g_creation_date         DATE := sysdate;
  g_last_updated_by       NUMBER(15) := -1;
  g_last_update_date      DATE := sysdate;
  g_last_update_login     NUMBER(15) := -1;

  PROCEDURE Raise_Error (p_error_text IN VARCHAR2)
  IS
      l_error_text        VARCHAR2(240);
  BEGIN
      l_error_text := p_error_text;
      Raise_Application_Error(-20001,l_error_text);
  END;

  PROCEDURE Get_Last_Year_Details (
      p_clndr_type            IN VARCHAR2,
      p_org_code              IN VARCHAR2,
      p_last_year             OUT NOCOPY NUMBER,
      p_last_year_start_dt    OUT NOCOPY DATE,
      p_last_year_end_dt      OUT NOCOPY DATE
  )
  IS
      l_SQL_str     VARCHAR2(500) := null;
      l_table_name  VARCHAR2(30);
  BEGIN
      IF p_clndr_type = 'CLNDR' THEN l_table_name := 'DDR_R_CLNDR_YR';
      ELSIF p_clndr_type = 'BSNS' THEN l_table_name := 'DDR_R_BSNS_YR';
      ELSIF p_clndr_type = 'FSCL' THEN l_table_name := 'DDR_R_FSCL_YR';
      ELSIF p_clndr_type = 'ADVR' THEN l_table_name := 'DDR_R_ADVR_YR';
      ELSIF p_clndr_type = 'PLNG' THEN l_table_name := 'DDR_R_PLNG_YR';
      END IF;

/*
      SELECT yr_strt_dt, yr_end_dt
      FROM   DDR_R_BSNS_YR
      WHERE  yr_nbr = (
          SELECT MAX(yr_nbr)
          FROM   DDR_R_BSNS_YR
          WHERE  clndr_cd = (
              SELECT clndr_cd
              FROM   DDR_R_CLNDR
              WHERE  org_cd = p_org_code
              AND    clndr_typ = 'BSNS'
            )
        )
-- Bug# 6866605 change start
       AND clndr_cd = (
              SELECT clndr_cd
              FROM   DDR_R_CLNDR
              WHERE  org_cd = p_org_code
              AND    clndr_typ = 'BSNS'
            )
-- Bug# 6866605 change end
*/
      l_SQL_str := 'select YR_NBR, YR_STRT_DT, YR_END_DT from ' || l_table_name || ' where YR_NBR =';
      l_SQL_str := l_SQL_str || ' (select max(YR_NBR) from ' || l_table_name;
      IF p_clndr_type IN ('BSNS','FSCL','ADVR','PLNG')
      THEN
          l_SQL_str := l_SQL_str || ' where CLNDR_CD = (select CLNDR_CD from DDR_R_CLNDR';
          l_SQL_str := l_SQL_str || ' where ORG_CD = ''' || p_org_code || ''' and CLNDR_TYP = ''' || p_clndr_type ||''')';
-- Bug# 6866605 change start
          l_SQL_str := l_SQL_str || ')';
          l_SQL_str := l_SQL_str || ' AND clndr_cd = (SELECT clndr_cd FROM DDR_R_CLNDR WHERE org_cd = ''' || p_org_code || ''' AND clndr_typ = ''' || p_clndr_type || ''')';
      ELSE
          l_SQL_str := l_SQL_str || ')';
      END IF;
-- Bug# 6866605 change end
      BEGIN
          EXECUTE IMMEDIATE l_SQL_str INTO p_last_year, p_last_year_start_dt, p_last_year_end_dt;
      EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
              p_last_year := null;
              p_last_year_start_dt := null;
              p_last_year_end_dt := null;
      END;
  END Get_Last_Year_Details;

  PROCEDURE Get_Last_Calendar_Week_Details (
      p_last_week             OUT NOCOPY NUMBER,
      p_last_week_start_dt    OUT NOCOPY DATE,
      p_last_week_end_dt      OUT NOCOPY DATE
  )
  IS
      cursor cur_week is
      select WK_NBR, WK_STRT_DT, WK_END_DT
      from   DDR_R_CLNDR_WK
      where  WK_NBR = (
          select max(WK_NBR)
          from   DDR_R_CLNDR_WK
      );
  BEGIN
      OPEN cur_week;
      FETCH cur_week INTO p_last_week,p_last_week_start_dt,p_last_week_end_dt;
      IF cur_week%NOTFOUND
      THEN
          p_last_week := null;
          p_last_week_start_dt := null;
          p_last_week_end_dt := null;
      END IF;
      CLOSE cur_week;
  END Get_Last_Calendar_Week_Details;

  PROCEDURE Get_Calendar_Week (
      p_date                  IN DATE,
      p_week_id               OUT NOCOPY NUMBER,
      p_week_code             OUT NOCOPY VARCHAR2
  )
  IS
      cursor cur_week is
      select CLNDR_WK_ID, WK_CD
      from   DDR_R_CLNDR_WK
      where  p_date between TRUNC(WK_STRT_DT)
                    and     TRUNC(WK_END_DT) + .99999;
  BEGIN
      OPEN cur_week;
      FETCH cur_week INTO p_week_id,p_week_code;
      IF cur_week%NOTFOUND
      THEN
          p_week_id := null;
          p_week_code := null;
      END IF;
      CLOSE cur_week;
  END Get_Calendar_Week;

  FUNCTION Get_Organization_Type (p_org_code IN VARCHAR2)
  RETURN VARCHAR2
  IS
      cursor cur_org is
      select ORG_TYP
      from   DDR_R_ORG
      where  ORG_CD = p_org_code;

      l_org_type    DDR_R_ORG.ORG_TYP%TYPE;
  BEGIN
      OPEN cur_org;
      FETCH cur_org INTO l_org_type;
      IF cur_org%NOTFOUND
      THEN
          l_org_type := null;
      END IF;
      CLOSE cur_org;
      RETURN l_org_type;
  END Get_Organization_Type;

  FUNCTION Get_Manufacturer
  RETURN VARCHAR2
  IS
      cursor cur_mfg is
      select ORG_CD
      from   DDR_R_ORG
      where  ORG_TYP = 'MFG';

      l_mfg_code    DDR_R_ORG.ORG_CD%TYPE;
  BEGIN
      OPEN cur_mfg;
      FETCH cur_mfg INTO l_mfg_code;
      IF cur_mfg%NOTFOUND
      THEN
          l_mfg_code := null;
      END IF;
      CLOSE cur_mfg;
      RETURN l_mfg_code;
  END Get_Manufacturer;

-- Bug# 6965786 change start
  FUNCTION Get_Spcl_Prd_Qtr(
     P_extra_week_period     IN VARCHAR2,
     P_qtr_array               Number_Tab,
     P_period_array            Number_Tab
  )
  RETURN VARCHAR2
  IS
     l_period_no                NUMBER:=0;
     l_period_idx_name          VARCHAR2(30);
     l_tot_no_of_weeks_period   NUMBER:=0;
     l_qtr_no                   NUMBER:=0;
     l_qtr_idx_name             VARCHAR2(30);
     l_tot_no_of_weeks_qtr      NUMBER:=0;
  BEGIN
     LOOP
        l_period_no := l_period_no + 1;
        l_period_idx_name := 'P' || to_char(l_period_no);
        l_tot_no_of_weeks_period := l_tot_no_of_weeks_period + P_period_array(l_period_idx_name);
        EXIT WHEN P_extra_week_period = l_period_idx_name;
     END LOOP;
     LOOP
        l_qtr_no := l_qtr_no + 1;
        l_qtr_idx_name := 'Q' || to_char(l_qtr_no);
        l_tot_no_of_weeks_qtr := l_tot_no_of_weeks_qtr + P_qtr_array(l_qtr_idx_name);
        EXIT WHEN l_tot_no_of_weeks_period <= l_tot_no_of_weeks_qtr;
     END LOOP;
     RETURN l_qtr_idx_name;
  END Get_Spcl_Prd_Qtr;
-- Bug# 6965786 change end

  PROCEDURE Create_WKDAY_Records
  IS
      cursor cur_wkday is
      select 1
      from   DDR_R_WKDAY;

      l_dummy         NUMBER(1);
      l_sunday_date   DATE;
  BEGIN
      OPEN cur_wkday;
      FETCH cur_wkday INTO l_dummy;
      IF cur_wkday%NOTFOUND
      THEN
          l_sunday_date := TRUNC(sysdate,'DAY');
          FOR day_idx IN 1 .. 7
          LOOP
              insert into DDR_R_WKDAY (
                  WKDAY_ID,
                  WKDAY_CD,
                  WKDAY_DESC,
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
              values (
                  day_idx,
                  day_idx,
                  TO_CHAR(l_sunday_date+day_idx-1,'DAY'),
                  g_src_sys_idnt,
                  g_src_sys_dt,
                  g_crtd_by_DSR,
                  g_last_updt_by_DSR,
                  g_created_by,
                  g_creation_date,
                  g_last_updated_by,
                  g_last_update_date,
                  g_last_update_login
              );
          END LOOP;
      END IF;
      CLOSE cur_wkday;
  END Create_WKDAY_Records;

  FUNCTION Get_Calendar (
      p_clndr_type            IN VARCHAR2,
      p_org_code              IN VARCHAR2,
      p_mfg_org_code          IN VARCHAR2
  )
  RETURN VARCHAR2
  IS
      cursor cur_clndr is
      select CLNDR_CD
      from   DDR_R_CLNDR
      where  CLNDR_TYP = p_clndr_type
      and    ORG_CD = p_org_code
      and    MFG_ORG_CD = p_mfg_org_code;

      l_clndr_cd      DDR_R_CLNDR.CLNDR_CD%TYPE;
  BEGIN
      OPEN cur_clndr;
      FETCH cur_clndr INTO l_clndr_cd;
      IF cur_clndr%NOTFOUND
      THEN
          l_clndr_cd := p_org_code || '-' || p_clndr_type;
          insert into DDR_R_CLNDR (
              CLNDR_ID,
              MFG_ORG_CD,
              CLNDR_CD,
              ORG_CD,
              CLNDR_TYP,
              CLNDR_DESC,
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
          values (
              DDR_R_CLNDR_SEQ.NEXTVAL,
              p_mfg_org_code,
              l_clndr_cd,
              p_org_code,
              p_clndr_type,
              p_org_code || ' - ' ||
                  decode(p_clndr_type,
                       'BSNS','Business',
                       'FSCL','Fiscal',
                       'ADVR','Advertising',
                       'PLNG','Planning'
                  ),
              g_src_sys_idnt,
              g_src_sys_dt,
              g_crtd_by_DSR,
              g_last_updt_by_DSR,
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login
          );
      END IF;
      CLOSE cur_clndr;
      RETURN l_clndr_cd;
  END Get_Calendar;

  FUNCTION Check_Calendar_Year_Exists (
      p_clndr_type            IN VARCHAR2,
      p_start_date            IN DATE,
      p_no_of_years           IN NUMBER,
      p_spl_year_count        IN NUMBER
  )
  RETURN VARCHAR2
  IS
      cursor cur_clndr_yr (p_year IN NUMBER) is
      select 1
      from   DDR_R_CLNDR_YR
      where  YR_NBR = p_year;

      l_start_year    NUMBER;
      l_end_year      NUMBER;
      l_end_date      DATE;
      l_year          NUMBER;
      l_dummy         NUMBER;
      l_missing_year  VARCHAR2(100);
  BEGIN
      l_start_year := TO_NUMBER(TO_CHAR(p_start_date,'YYYY'));

      IF p_clndr_type IN ('BSNS','ADVR','PLNG')
      THEN
          l_end_date := p_start_date + p_no_of_years*52*7 + nvl(p_spl_year_count,0)*7 - 1;
      ELSIF p_clndr_type = 'FSCL'
      THEN
          l_end_date := ADD_MONTHS(p_start_date,p_no_of_years*12);
      END IF;

      l_end_year := TO_NUMBER(TO_CHAR(l_end_date,'YYYY'));

      l_missing_year := null;
      FOR year_idx IN l_start_year .. l_end_year
      LOOP
          OPEN cur_clndr_yr (year_idx);
          FETCH cur_clndr_yr INTO l_dummy;
          IF cur_clndr_yr%NOTFOUND
          THEN
              IF l_missing_year IS NOT NULL
              THEN
                  l_missing_year := l_missing_year || ',';
              END IF;
              l_missing_year := l_missing_year || TO_CHAR(year_idx);
          END IF;
          CLOSE cur_clndr_yr;
      END LOOP;

      RETURN l_missing_year;
  END Check_Calendar_Year_Exists;

  PROCEDURE Populate_Month_Arrays (
      p_month_array           IN OUT NOCOPY  Number_Tab,
      p_qtr_array             IN OUT NOCOPY  Number_Tab,
      p_spl_year_array        IN OUT NOCOPY  Number_Tab,
      p_five_week_month_list  IN      VARCHAR2,
      p_special_year_list     IN      VARCHAR2,
      p_extra_week_month      IN      VARCHAR2,
      p_no_of_years           IN      NUMBER,
      p_start_date            IN      DATE
  )
  IS
      l_month_count           NUMBER;
      l_five_week_month_list  VARCHAR2(100);
      l_token                 VARCHAR2(30);
      l_month_idx_name        VARCHAR2(30);
      l_qtr_idx_name          VARCHAR2(30);
      l_special_year_list     VARCHAR2(100);
      l_special_year_count    NUMBER;
      l_extra_week_month      VARCHAR2(30);
      l_extra_week_count      NUMBER;
      l_start_year            NUMBER;
      l_end_year              NUMBER;
  BEGIN
      IF p_five_week_month_list IS NULL
      THEN
          Raise_Error('List of Months (of 5-Week) must be specified');
      END IF;

      /* Perform five-week-month related validation */
      l_five_week_month_list := REPLACE(UPPER(p_five_week_month_list),' ','');
      l_month_count := LENGTH(l_five_week_month_list) - LENGTH(REPLACE(l_five_week_month_list,',','')) + 1;

      IF l_month_count <> 4
      THEN
          Raise_Error('List of Months (of 5-Week) must have exactly four months specified');
      END IF;

      FOR idx IN 0 .. (l_month_count-1)
      LOOP
          IF (idx=0)
          THEN
              IF INSTR(l_five_week_month_list,',',1,1) <> 0
              THEN
                  l_token := SUBSTR(l_five_week_month_list,1,INSTR(l_five_week_month_list,',',1,1)-1);
              ELSE
                  l_token := l_five_week_month_list;
              END IF;
          ELSE
              IF INSTR(l_five_week_month_list,',',1,idx+1) <> 0
              THEN
                  l_token := SUBSTR(l_five_week_month_list,INSTR(l_five_week_month_list,',',1,idx)+1,
                                                INSTR(l_five_week_month_list,',',1,idx+1)-INSTR(l_five_week_month_list,',',1,idx)-1);
              ELSE
                  l_token  := SUBSTR(l_five_week_month_list,INSTR(l_five_week_month_list,',',1,idx)+1);
              END IF;
          END IF;

          IF l_token NOT IN ('M1','M2','M3','M4','M5','M6','M7','M8','M9','M10','M11','M12')
          THEN
              Raise_Error('Invalid Month specification in List of Months (of 5-Week) => ' || l_token);
          END IF;

          p_month_array(l_token) := 5;
      END LOOP;

      FOR idx IN 1 .. 12
      LOOP
          l_month_idx_name := 'M' || to_char(idx);
          IF NOT p_month_array.EXISTS(l_month_idx_name)
          THEN
              p_month_array(l_month_idx_name) := 4;
          END IF;
      END LOOP;

      p_qtr_array('Q1') := p_month_array('M1') + p_month_array('M2') + p_month_array('M3');
      p_qtr_array('Q2') := p_month_array('M4') + p_month_array('M5') + p_month_array('M6');
      p_qtr_array('Q3') := p_month_array('M7') + p_month_array('M8') + p_month_array('M9');
      p_qtr_array('Q4') := p_month_array('M10') + p_month_array('M11') + p_month_array('M12');

      FOR idx IN 1 .. 4
      LOOP
          l_qtr_idx_name := 'Q' || to_char(idx);
          IF p_qtr_array(l_qtr_idx_name) <> 13
          THEN
              Raise_Error('In List of Months (of 5-Week), exactly one month to be specified for Quarter => ' || l_qtr_idx_name);
          END IF;
      END LOOP;

      IF p_special_year_list IS NOT NULL
      THEN
          IF p_extra_week_month IS NULL
          THEN
              Raise_Error('Month (with extra Week for Special Year) must be specified');
          END IF;

          /* Perform Validation for p_extra_week_month */
          l_extra_week_month := REPLACE(UPPER(p_extra_week_month),' ','');
          l_extra_week_count := LENGTH(l_extra_week_month) - LENGTH(REPLACE(l_extra_week_month,',','')) + 1;
          IF l_extra_week_count <> 1
          THEN
              Raise_Error('Month (with extra Week for Special Year) must have exactly one month specified');
          END IF;

          IF l_extra_week_month NOT IN ('M1','M2','M3','M4','M5','M6','M7','M8','M9','M10','M11','M12')
          THEN
              Raise_Error('Invalid Month specification in Month (with extra Week for Special Year) => ' || l_extra_week_month);
          END IF;

          IF p_month_array(l_extra_week_month) = 5
          THEN
              Raise_Error('Month (with extra Week for Special Year) is already a five-week month');
          END IF;

          /* Build the special year array and Perform the corresponding validation */
          l_special_year_list := REPLACE(UPPER(p_special_year_list),' ','');
          l_special_year_count := LENGTH(l_special_year_list) - LENGTH(REPLACE(l_special_year_list,',','')) + 1;

          IF l_special_year_count > p_no_of_years
          THEN
              Raise_Error('Number of Special Years can''t be more than number of Years to be populated');
          END IF;

          l_start_year := TO_CHAR(p_start_date,'YYYY');
          l_end_year := l_start_year + p_no_of_years - 1;

          FOR idx IN 0 .. (l_special_year_count-1)
          LOOP
              IF (idx=0)
              THEN
                  IF INSTR(l_special_year_list,',',1,1) <> 0
                  THEN
                      l_token := SUBSTR(l_special_year_list,1,INSTR(l_special_year_list,',',1,1)-1);
                  ELSE
                      l_token := l_special_year_list;
                  END IF;
              ELSE
                  IF INSTR(l_special_year_list,',',1,idx+1) <> 0
                  THEN
                      l_token := SUBSTR(l_special_year_list,INSTR(l_special_year_list,',',1,idx)+1,
                                                    INSTR(l_special_year_list,',',1,idx+1)-INSTR(l_special_year_list,',',1,idx)-1);
                  ELSE
                      l_token  := SUBSTR(l_special_year_list,INSTR(l_special_year_list,',',1,idx)+1);
                  END IF;
              END IF;

              p_spl_year_array(l_token) := to_number(l_token);
              IF to_number(l_token) NOT BETWEEN l_start_year AND l_end_year
              THEN
                  Raise_Error('Special Year not within the range of Years to be populated => ' || l_token);
              END IF;
          END LOOP;
      END IF;

  END Populate_Month_Arrays;

  PROCEDURE Populate_Period_Arrays (
      p_period_array          IN OUT NOCOPY  Number_Tab,
      p_qtr_array             IN OUT NOCOPY  Number_Tab,
      p_spl_year_array        IN OUT NOCOPY  Number_Tab,
      p_period_dist_list      IN      VARCHAR2,
      p_week_dist_list        IN      VARCHAR2,
      p_special_year_list     IN      VARCHAR2,
      p_extra_week_period     IN      VARCHAR2,
      p_no_of_years           IN      NUMBER,
      p_start_date            IN      DATE
  )
  IS
      l_qtr_count             NUMBER;
      l_period_count          NUMBER;
      l_period_count_qtr      NUMBER;
      l_period_dist_list      VARCHAR2(100);
      l_week_dist_list        VARCHAR2(500);
      l_token                 VARCHAR2(30);
      l_period_idx_name       VARCHAR2(30);
      l_qtr_idx_name          VARCHAR2(30);
      l_special_year_list     VARCHAR2(100);
      l_special_year_count    NUMBER;
      l_extra_week_period     VARCHAR2(30);
      l_extra_week_count      NUMBER;
      l_start_year            NUMBER;
      l_end_year              NUMBER;
      l_token_name            VARCHAR2(30);
      l_token_value           VARCHAR2(30);
      l_period_number         VARCHAR2(10);
      l_week_count            NUMBER;
      l_period_idx            NUMBER;
  BEGIN
      IF p_period_dist_list IS NULL
      THEN
          Raise_Error('Period Distribution list over Quarters must be specified');
      END IF;

      IF p_week_dist_list IS NULL
      THEN
          Raise_Error('Week Distribution list over Periods must be specified');
      END IF;

      /* Perform Period Distribution and Week Distribution related validation */
      l_period_dist_list := REPLACE(UPPER(p_period_dist_list),' ','');
      l_qtr_count := LENGTH(l_period_dist_list) - LENGTH(REPLACE(l_period_dist_list,',','')) + 1;

      IF l_qtr_count <> 4
      THEN
          Raise_Error('Period Distribution List must have exactly four Quarters specified');
      END IF;

      l_period_count_qtr := 0;
      FOR idx IN 0 .. (l_qtr_count-1)
      LOOP
          IF (idx=0)
          THEN
              IF INSTR(l_period_dist_list,',',1,1) <> 0
              THEN
                  l_token := SUBSTR(l_period_dist_list,1,INSTR(l_period_dist_list,',',1,1)-1);
              ELSE
                  l_token := l_period_dist_list;
              END IF;
          ELSE
              IF INSTR(l_period_dist_list,',',1,idx+1) <> 0
              THEN
                  l_token := SUBSTR(l_period_dist_list,INSTR(l_period_dist_list,',',1,idx)+1,
                                                INSTR(l_period_dist_list,',',1,idx+1)-INSTR(l_period_dist_list,',',1,idx)-1);
              ELSE
                  l_token  := SUBSTR(l_period_dist_list,INSTR(l_period_dist_list,',',1,idx)+1);
              END IF;
          END IF;

          l_token_name := SUBSTR(l_token,1,INSTR(l_token,'=')-1);
          l_token_value := SUBSTR(l_token,INSTR(l_token,'=')+1);

          IF l_token_name NOT IN ('Q1','Q2','Q3','Q4')
          THEN
              Raise_Error('Invalid Quarter specification in Period Distribution List => ' || l_token_name);
          END IF;

          l_period_count_qtr := l_period_count_qtr + to_number(l_token_value);
          p_qtr_array(l_token_name) := to_number(l_token_value);
      END LOOP;

      l_week_dist_list := REPLACE(UPPER(p_week_dist_list),' ','');
      l_period_count := LENGTH(l_week_dist_list) - LENGTH(REPLACE(l_week_dist_list,',','')) + 1;

      IF l_period_count <> l_period_count_qtr
      THEN
          Raise_Error('Number of Periods mismatch between Period and Week Distribution List');
      END IF;

      l_week_count := 0;
      FOR idx IN 0 .. (l_period_count-1)
      LOOP
          IF (idx=0)
          THEN
              IF INSTR(l_week_dist_list,',',1,1) <> 0
              THEN
                  l_token := SUBSTR(l_week_dist_list,1,INSTR(l_week_dist_list,',',1,1)-1);
              ELSE
                  l_token := l_week_dist_list;
              END IF;
          ELSE
              IF INSTR(l_week_dist_list,',',1,idx+1) <> 0
              THEN
                  l_token := SUBSTR(l_week_dist_list,INSTR(l_week_dist_list,',',1,idx)+1,
                                                INSTR(l_week_dist_list,',',1,idx+1)-INSTR(l_week_dist_list,',',1,idx)-1);
              ELSE
                  l_token  := SUBSTR(l_week_dist_list,INSTR(l_week_dist_list,',',1,idx)+1);
              END IF;
          END IF;

          l_token_name := SUBSTR(l_token,1,INSTR(l_token,'=')-1);
          l_token_value := SUBSTR(l_token,INSTR(l_token,'=')+1);

          /* Validate Period Name */
          IF SUBSTR(l_token_name,1,1) <> 'P'
          THEN
              Raise_Error('Invalid Period specification in Week Distribution List => ' || l_token_name);
          END IF;

          l_period_number := SUBSTR(l_token_name,2);
          IF l_period_number <> to_char(idx+1)
          THEN
              Raise_Error('Period is not in order in Week Distribution List => ' || l_token_name);
          END IF;

          p_period_array(l_token_name) := to_number(l_token_value);
          l_week_count := l_week_count + to_number(l_token_value);
      END LOOP;

      IF l_week_count <> 52
      THEN
            Raise_Error('Total number of weeks over all Periods must be 52');
      END IF;

      /* Populate the Quarter array */
      l_period_idx := 0;
      FOR idx_outer IN 1 .. 4
      LOOP
          l_qtr_idx_name := 'Q' || to_char(idx_outer);
          l_period_count_qtr := p_qtr_array(l_qtr_idx_name);
          p_qtr_array(l_qtr_idx_name) := 0;
          FOR idx IN 1 .. l_period_count_qtr
          LOOP
              l_period_idx := l_period_idx + 1;
              l_period_idx_name := 'P' || to_char(l_period_idx);
              p_qtr_array(l_qtr_idx_name) := p_qtr_array(l_qtr_idx_name) + p_period_array(l_period_idx_name);
          END LOOP;

/*
          IF p_qtr_array(l_qtr_idx_name) <> 13
          THEN
              Raise_Error('Each Quarter must have exactly 13 Weeks. Quarter ' || l_qtr_idx_name || ' has ' || to_char(p_qtr_array(l_qtr_idx_name)) || ' weeks');
          END IF;
*/
      END LOOP;

      IF p_special_year_list IS NOT NULL
      THEN
          IF p_extra_week_period IS NULL
          THEN
              Raise_Error('Period (with extra Week for Special Year) must be specified');
          END IF;

          /* Perform Validation for p_extra_week_period */
          l_extra_week_period := REPLACE(UPPER(p_extra_week_period),' ','');
          l_extra_week_count := LENGTH(l_extra_week_period) - LENGTH(REPLACE(l_extra_week_period,',','')) + 1;
          IF l_extra_week_count <> 1
          THEN
              Raise_Error('Period (with extra Week for Special Year) must have exactly one period specified');
          END IF;

          IF SUBSTR(l_extra_week_period,1,1) <> 'P'
          THEN
              Raise_Error('Invalid Period specification in Period (with extra Week for Special Year) => ' || l_extra_week_period);
          END IF;

          l_period_number := SUBSTR(l_extra_week_period,2);
          IF to_number(l_period_number) NOT BETWEEN 1 AND l_period_count
          THEN
              Raise_Error('Invalid Period specification in Period (with extra Week for Special Year) => ' || l_extra_week_period);
          END IF;

          /* Build the special year array and Perform the corresponding validation */
          l_special_year_list := REPLACE(UPPER(p_special_year_list),' ','');
          l_special_year_count := LENGTH(l_special_year_list) - LENGTH(REPLACE(l_special_year_list,',','')) + 1;

          IF l_special_year_count > p_no_of_years
          THEN
              Raise_Error('Number of Special Years can''t be more than number of Years to be populated');
          END IF;

          l_start_year := TO_CHAR(p_start_date,'YYYY');
          l_end_year := l_start_year + p_no_of_years - 1;

          FOR idx IN 0 .. (l_special_year_count-1)
          LOOP
              IF (idx=0)
              THEN
                  IF INSTR(l_special_year_list,',',1,1) <> 0
                  THEN
                      l_token := SUBSTR(l_special_year_list,1,INSTR(l_special_year_list,',',1,1)-1);
                  ELSE
                      l_token := l_special_year_list;
                  END IF;
              ELSE
                  IF INSTR(l_special_year_list,',',1,idx+1) <> 0
                  THEN
                      l_token := SUBSTR(l_special_year_list,INSTR(l_special_year_list,',',1,idx)+1,
                                                    INSTR(l_special_year_list,',',1,idx+1)-INSTR(l_special_year_list,',',1,idx)-1);
                  ELSE
                      l_token  := SUBSTR(l_special_year_list,INSTR(l_special_year_list,',',1,idx)+1);
                  END IF;
              END IF;

              p_spl_year_array(l_token) := to_number(l_token);
              IF to_number(l_token) NOT BETWEEN l_start_year AND l_end_year
              THEN
                  Raise_Error('Special Year not within the range of Years to be populated => ' || l_token);
              END IF;
          END LOOP;
      END IF;

  END Populate_Period_Arrays;

  PROCEDURE Populate_STND_Calendar (
        p_no_of_years         IN NUMBER,
        p_start_year          IN NUMBER    DEFAULT NULL
  )
  AS
      l_last_year               NUMBER;
      l_last_year_start_date    DATE;
      l_last_year_end_date      DATE;
      l_last_week               NUMBER;
      l_last_week_start_date    DATE;
      l_last_week_end_date      DATE;

      l_no_of_years             NUMBER;
      l_no_year_days            NUMBER;
      l_curr_year_id            NUMBER;
      l_curr_year               NUMBER;
      l_curr_year_start_date    DATE;
      l_curr_year_end_date      DATE;
      l_curr_year_desc          VARCHAR2(40);
      l_curr_qtr_id             NUMBER;
      l_curr_qtr                NUMBER;
      l_curr_qtr_start_date     DATE;
      l_curr_qtr_end_date       DATE;
      l_curr_month_id           NUMBER;
      l_curr_month              NUMBER;
      l_curr_month_start_date   DATE;
      l_curr_month_end_date     DATE;
      l_curr_week_id            NUMBER;
      l_curr_week               NUMBER;
      l_curr_week_start_date    DATE;
      l_curr_week_end_date      DATE;
      l_curr_day_id             NUMBER;
      l_curr_date               DATE;
      l_wkday_id                NUMBER;
      l_qtr_no                  NUMBER;
      l_month_no                NUMBER;
      l_week_no                 NUMBER;

  BEGIN
      /* Check existence of record in DDR_R_CLNDR_YR and get last year details */
      Get_Last_Year_Details('CLNDR',null,l_last_year,l_last_year_start_date,l_last_year_end_date);
      IF l_last_year IS NULL /* Last year record does not exist */
      THEN
          IF p_start_year IS NULL
          THEN
              Raise_Error('Year must be specified');
          END IF;
          l_last_year := p_start_year-1;
          l_last_year_start_date := TO_DATE(TO_CHAR(l_last_year) || '01','YYYYMM');
          l_last_year_end_date := ADD_MONTHS(l_last_year_start_date,12)-1;
-- Bug# 6863276 change start
      ELSE
          IF p_start_year IS NOT NULL
          THEN
              Raise_Error('Year must be NULL');
          END IF;
-- Bug# 6863276 change end
      END IF;

      /* Check existence of record in DDR_R_CLNDR_WK and get last week details */
      Get_Last_Calendar_Week_Details(l_last_week,l_last_week_start_date,l_last_week_end_date);
      IF l_last_week IS NULL /* Last week record does not exist */
      THEN
          l_last_week_start_date := TRUNC(l_last_year_end_date,'DAY');
          l_last_week_end_date := l_last_week_start_date + 7 - 1;
      END IF;

      l_no_of_years := nvl(p_no_of_years,1);

      /* Check existance of record in DDR_R_WKDAY. Create records if not alreday exists */
      Create_WKDAY_Records;

      /* Initialize Year and Week Variables for loop operation */
      l_curr_year := l_last_year;
      l_curr_year_start_date := l_last_year_start_date;
      l_curr_year_end_date := l_last_year_end_date;
      l_curr_week_start_date := l_last_week_start_date;
      l_curr_week_end_date := l_last_week_end_date;

      /* Create records in various Calendar tables */
      FOR year_idx IN 1 .. l_no_of_years
      LOOP
          l_curr_year := l_curr_year +1;
          l_curr_year_start_date := l_curr_year_end_date+1;
          l_curr_year_end_date := ADD_MONTHS(l_curr_year_start_date,12)-1;
          l_no_year_days := l_curr_year_end_date - l_curr_year_start_date + 1;
          -- l_curr_year_id := TO_NUMBER(TO_CHAR(l_curr_year_start_date,g_YR_ID_format));
          SELECT DDR_R_CLNDR_YR_SEQ.NEXTVAL
          INTO   l_curr_year_id
          FROM   DUAL;
          l_curr_year_desc := 'CY ' || TO_CHAR(l_curr_year);

          insert into DDR_R_CLNDR_YR (
              CLNDR_YR_ID,
              YR_CD,
              YR_NBR,
              YR_DESC,
              YR_STRT_DT,
              YR_END_DT,
              YR_TIMESPN,
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
          values (
              l_curr_year_id,
              l_curr_year,
              l_curr_year,
              l_curr_year_desc,
              l_curr_year_start_date,
              l_curr_year_end_date,
              l_no_year_days,
              g_src_sys_idnt,
              g_src_sys_dt,
              g_crtd_by_DSR,
              g_last_updt_by_DSR,
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login
          );

          /* Initialize Variables for loop operation */
          l_curr_qtr_end_date := l_curr_year_start_date - 1;
          l_curr_month_end_date := l_curr_year_start_date - 1;
          l_curr_date := l_curr_year_start_date - 1;
          l_qtr_no := 0;
          l_month_no := 0;
          l_week_no := 0;

          FOR day_idx IN 1 .. l_no_year_days
          LOOP
              l_curr_date := l_curr_date + 1;

              IF (l_curr_date > l_curr_qtr_end_date) /* New Quarter */
              THEN
                  l_qtr_no := l_qtr_no + 1;
                  l_curr_qtr_start_date := l_curr_date;
                  l_curr_qtr_end_date := ADD_MONTHS(l_curr_qtr_start_date,3)-1;
                  -- l_curr_qtr_id := TO_NUMBER(TO_CHAR(l_curr_qtr_start_date,g_QTR_ID_format));
                  SELECT DDR_R_CLNDR_QTR_SEQ.NEXTVAL
                  INTO   l_curr_qtr_id
                  FROM   DUAL;
                  l_curr_qtr := TO_NUMBER(TO_CHAR(l_curr_year) || TO_CHAR(l_qtr_no));

                  insert into DDR_R_CLNDR_QTR (
                      CLNDR_QTR_ID,
                      QTR_CD,
                      QTR_NBR,
                      QTR_DESC,
                      QTR_STRT_DT,
                      QTR_END_DT,
                      QTR_TIMESPN,
                      CLNDR_YR_ID,
                      YR_CD,
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
                  values (
                      l_curr_qtr_id,
                      l_curr_qtr,
                      l_curr_qtr,
                      l_curr_year_desc || ' Q' || TO_CHAR(l_qtr_no),
                      l_curr_qtr_start_date,
                      l_curr_qtr_end_date,
                      l_curr_qtr_end_date - l_curr_qtr_start_date + 1,
                      l_curr_year_id,
                      l_curr_year,
                      g_src_sys_idnt,
                      g_src_sys_dt,
                      g_crtd_by_DSR,
                      g_last_updt_by_DSR,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login
                  );
              END IF;

              IF (l_curr_date > l_curr_month_end_date) /* New Month */
              THEN
                  l_month_no := l_month_no + 1;
                  l_curr_month_start_date := l_curr_date;
                  l_curr_month_end_date := ADD_MONTHS(l_curr_month_start_date,1)-1;
                  -- l_curr_month_id := TO_NUMBER(TO_CHAR(l_curr_month_start_date,g_MNTH_ID_format));
                  SELECT DDR_R_CLNDR_MNTH_SEQ.NEXTVAL
                  INTO   l_curr_month_id
                  FROM   DUAL;
                  l_curr_month := TO_NUMBER(TO_CHAR(l_curr_year) || LPAD(TO_CHAR(l_month_no),2,'0'));

                  insert into DDR_R_CLNDR_MNTH (
                      CLNDR_MNTH_ID,
                      MNTH_CD,
                      MNTH_NBR,
                      MNTH_DESC,
                      MNTH_STRT_DT,
                      MNTH_END_DT,
                      MNTH_TIMESPN,
                      CLNDR_QTR_ID,
                      QTR_CD,
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
                  values (
                      l_curr_month_id,
                      l_curr_month,
                      l_curr_month,
                      l_curr_year_desc || ' M' || TO_CHAR(l_month_no),
                      l_curr_month_start_date,
                      l_curr_month_end_date,
                      l_curr_month_end_date - l_curr_month_start_date + 1,
                      l_curr_qtr_id,
                      l_curr_qtr,
                      g_src_sys_idnt,
                      g_src_sys_dt,
                      g_crtd_by_DSR,
                      g_last_updt_by_DSR,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login
                  );
              END IF;

              IF (l_curr_date > l_curr_week_end_date) /* New Week */
              THEN
                  l_week_no := l_week_no + 1;
                  l_curr_week_start_date := l_curr_date;
                  l_curr_week_end_date := l_curr_week_start_date + 7 - 1;
                  -- l_curr_week_id := TO_NUMBER(TO_CHAR(l_curr_week_start_date,g_WK_ID_format));
                  SELECT DDR_R_CLNDR_WK_SEQ.NEXTVAL
                  INTO   l_curr_week_id
                  FROM   DUAL;
                  l_curr_week := TO_NUMBER(TO_CHAR(l_curr_year) || LPAD(TO_CHAR(l_week_no),2,'0'));

                  insert into DDR_R_CLNDR_WK (
                      CLNDR_WK_ID,
                      WK_CD,
                      WK_NBR,
                      WK_DESC,
                      WK_STRT_DT,
                      WK_END_DT,
                      WK_TIMESPN,
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
                  values (
                      l_curr_week_id,
                      l_curr_week,
                      l_curr_week,
                      l_curr_year_desc || ' W' || TO_CHAR(l_week_no),
                      l_curr_week_start_date,
                      l_curr_week_end_date,
                      l_curr_week_end_date - l_curr_week_start_date + 1,
                      g_src_sys_idnt,
                      g_src_sys_dt,
                      g_crtd_by_DSR,
                      g_last_updt_by_DSR,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login
                  );
              END IF;

              /* Insert Day Record */
              l_curr_day_id := TO_NUMBER(TO_CHAR(l_curr_date,g_DAY_ID_format));
              l_wkday_id := TRUNC(l_curr_date) - TRUNC(l_curr_date,'DAY') + 1;

              IF l_curr_week IS NULL
              THEN
                  Get_Calendar_Week (l_curr_date,l_curr_week_id,l_curr_week);
              END IF;

              insert into DDR_R_DAY (
                  DAY_CD,
                  CLNDR_DT,
                  CLNDR_DT_DESC,
                  JULIAN_DAY,
                  WKDAY_ID,
                  WK_DAY,
                  CLNDR_WK_ID,
                  WK_CD,
                  CLNDR_MNTH_ID,
                  MNTH_CD,
                  DAY_OF_YR,
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
              values (
                  l_curr_day_id,
                  l_curr_date,
                  l_curr_year_desc || ' ' || TO_CHAR(l_curr_date),
                  TO_CHAR(l_curr_date,'J'),
                  l_wkday_id,
                  l_wkday_id,
                  l_curr_week_id,
                  l_curr_week,
                  l_curr_month_id,
                  l_curr_month,
                  day_idx,
                  g_src_sys_idnt,
                  g_src_sys_dt,
                  g_crtd_by_DSR,
                  g_last_updt_by_DSR,
                  g_created_by,
                  g_creation_date,
                  g_last_updated_by,
                  g_last_update_date,
                  g_last_update_login
              );
          END LOOP; /* end of day loop */
      END LOOP; /* end of year loop */

      COMMIT;
  END Populate_STND_Calendar;

  PROCEDURE Populate_BSNS_Calendar (
        p_org_cd                IN VARCHAR2,
        p_no_of_years           IN NUMBER,
        p_start_date            IN DATE       DEFAULT NULL,
        p_five_week_month_list  IN VARCHAR2,
        p_special_year_list     IN VARCHAR2,
        p_extra_week_month      IN VARCHAR2
  )
  IS
      l_qtr_array               Number_Tab;
      l_month_array             Number_Tab;
      l_spl_year_array          Number_Tab;
      l_extra_week_month        VARCHAR2(30);

-- Bug# 6932509 change start
      l_cut_extra_mnth          number;
      l_qtr_start_mnth          number;
      l_qtr_end_mnth            number;
-- Bug# 6932509 change end

      l_last_year               NUMBER;
      l_last_year_start_date    DATE;
      l_last_year_end_date      DATE;

      l_org_type                DDR_R_ORG.ORG_TYP%TYPE;
      l_mfg_org_cd              DDR_R_ORG.ORG_CD%TYPE;
      l_clndr_cd                DDR_R_CLNDR.CLNDR_CD%TYPE;
      l_missing_year            VARCHAR2(100);

      l_spl_year_flag           BOOLEAN := FALSE;
      l_no_of_years             NUMBER;
      l_no_of_weeks             NUMBER;
      l_no_year_days            NUMBER;
      l_curr_year_id            NUMBER;
      l_curr_year               NUMBER;
      l_curr_year_start_date    DATE;
      l_curr_year_end_date      DATE;
      l_curr_year_desc          VARCHAR2(40);
      l_curr_qtr_id             NUMBER;
      l_curr_qtr                NUMBER;
      l_curr_qtr_start_date     DATE;
      l_curr_qtr_end_date       DATE;
      l_curr_month_id           NUMBER;
      l_curr_month              NUMBER;
      l_curr_month_start_date   DATE;
      l_curr_month_end_date     DATE;
      l_curr_week_id            NUMBER;
      l_curr_week               NUMBER;
      l_curr_week_start_date    DATE;
      l_curr_week_end_date      DATE;
      l_curr_day_id             NUMBER;
      l_curr_date               DATE;
      l_qtr_no                  NUMBER;
      l_month_no                NUMBER;
      l_week_no                 NUMBER;
      l_no_of_weeks_qtr         NUMBER;
      l_no_of_weeks_month       NUMBER;
      l_day_no                  NUMBER;
      l_qtr_idx_name            VARCHAR2(30);
      l_month_idx_name          VARCHAR2(30);
  BEGIN
      /*
        Validate that p_org_cd is not null and also it is a valid organization as per DDR_R_ORG table
        Check that Organization Type in ('MFG','RTL')
      */
      IF p_org_cd IS NULL
      THEN
          Raise_Error('Organization Code must be specified');
      END IF;

      l_org_type := Get_Organization_Type(p_org_cd);
      IF l_org_type IS NULL
      THEN
          Raise_Error('Invalid Organization');
      END IF;

      IF l_org_type NOT IN ('MFG','RTL','DST')
      THEN
          Raise_Error('Business Calendar can be defined for Manufacturer, Retailer and Distributor only');
      END IF;

      /* Validate that Manufacturing Organization exists in DDR_R_ORG */
      l_mfg_org_cd := Get_Manufacturer;
      IF (l_org_type <> 'MFG') AND (l_mfg_org_cd IS NULL)
      THEN
          Raise_Error('Manufacturer Organization not yet defined');
      END IF;

      /* Check existence of record in DDR_R_BSNS_YR and get last year details */
      Get_Last_Year_Details('BSNS',p_org_cd,l_last_year,l_last_year_start_date,l_last_year_end_date);
      IF l_last_year IS NULL /* Last year record does not exist */
      THEN
          IF p_start_date IS NULL
          THEN
              Raise_Error('Start Date must be specified');
          END IF;
          l_last_year := TO_NUMBER(TO_CHAR(p_start_date,'YYYY'))-1;
          l_last_year_end_date := p_start_date - 1;
-- Bug# 6863276 change start
      ELSE
          IF p_start_date IS NOT NULL
          THEN
              Raise_Error('Start Date must be NULL');
          END IF;
-- Bug# 6863276 change end
      END IF;

      l_no_of_years := nvl(p_no_of_years,1);

      /* Populate Quarter and Month array */
      Populate_Month_Arrays(l_month_array,l_qtr_array,l_spl_year_array,p_five_week_month_list,p_special_year_list,p_extra_week_month,l_no_of_years,l_last_year_end_date+1);
      l_extra_week_month := REPLACE(UPPER(p_extra_week_month),' ','');

      /* Check existance of record in DDR_R_CLNDR_YR for all relevant years */
      l_missing_year := Check_Calendar_Year_Exists('BSNS',l_last_year_end_date+1,l_no_of_years,l_spl_year_array.COUNT);
      IF l_missing_year IS NOT NULL
      THEN
          Raise_Error('Standard Calendar to be populated for years (' || l_missing_year || ')');
      END IF;

      /*
        Check whether record exists in DDR_R_CLNDR for CLNDR_TYP='BSNS' and ORG_CD=p_org_cd;
        If no such record exists
        then
            Insert a record into DDR_R_CLNDR for the organization p_org_cd with CLNDR_TYP='BSNS';
        end if;
      */
      l_clndr_cd := Get_Calendar('BSNS',p_org_cd,l_mfg_org_cd);

      /* Initialize Year Variables for loop operation */
      l_curr_year := l_last_year;
      l_curr_year_start_date := l_last_year_start_date;
      l_curr_year_end_date := l_last_year_end_date;

      /* Create records in various Business Calendar tables */
      FOR year_idx IN 1 .. l_no_of_years
      LOOP
          l_curr_year := l_curr_year + 1;

          IF l_spl_year_array.EXISTS(to_char(l_curr_year))
          THEN
              l_spl_year_flag := TRUE;
              l_no_of_weeks := 53;
          ELSE
              l_spl_year_flag := FALSE;
              l_no_of_weeks := 52;
          END IF;

          l_curr_year_start_date := l_curr_year_end_date+1;
          l_curr_year_end_date := l_curr_year_start_date + (7*l_no_of_weeks) - 1;
          l_no_year_days := l_curr_year_end_date - l_curr_year_start_date + 1;
          -- l_curr_year_id := TO_NUMBER(TO_CHAR(l_curr_year_start_date,g_YR_ID_format));
          SELECT DDR_R_BSNS_YR_SEQ.NEXTVAL
          INTO   l_curr_year_id
          FROM   DUAL;
          l_curr_year_desc := 'BY ' || TO_CHAR(l_curr_year);

          insert into DDR_R_BSNS_YR (
              BSNS_YR_ID,
              MFG_ORG_CD,
              CLNDR_CD,
              YR_CD,
              YR_NBR,
              YR_DESC,
              YR_STRT_DT,
              YR_END_DT,
              YR_TIMESPN,
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
          values (
              l_curr_year_id,
              l_mfg_org_cd,
              l_clndr_cd,
              l_curr_year,
              l_curr_year,
              l_curr_year_desc,
              l_curr_year_start_date,
              l_curr_year_end_date,
              l_no_year_days,
              g_src_sys_idnt,
              g_src_sys_dt,
              g_crtd_by_DSR,
              g_last_updt_by_DSR,
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login
          );

          /* Initialize Variables for loop operation */
          l_curr_qtr_end_date := l_curr_year_start_date - 1;
          l_curr_month_end_date := l_curr_year_start_date - 1;
          l_curr_date := l_curr_year_start_date - 1;
          l_qtr_no := 0;
          l_month_no := 0;
          l_week_no := 0;
          l_day_no := 0;

          FOR week_idx IN 1 .. l_no_of_weeks
          LOOP
              l_curr_date := l_curr_year_start_date + 7 * (week_idx-1);

              IF (l_curr_date > l_curr_qtr_end_date) /* New Quarter */
              THEN
                  l_qtr_no := l_qtr_no + 1;
                  l_curr_qtr_start_date := l_curr_date;
                  l_qtr_idx_name := 'Q' || to_char(l_qtr_no);

                  IF (l_spl_year_flag = TRUE)
                  THEN
--Bug# 6932509 change start
--                    l_no_of_weeks_qtr := l_qtr_array(l_qtr_idx_name) + 1;
                      l_cut_extra_mnth  := to_number(substr(p_extra_week_month,2));
                      l_qtr_start_mnth := (l_qtr_no - 1) * 3 + 1;
                      l_qtr_end_mnth   := l_qtr_no * 3;
                              IF l_cut_extra_mnth between l_qtr_start_mnth and l_qtr_end_mnth
                              THEN
                                  l_no_of_weeks_qtr := l_qtr_array(l_qtr_idx_name) + 1;
                              ELSE
                                  l_no_of_weeks_qtr := l_qtr_array(l_qtr_idx_name);
                              END IF;
--Bug# 6932509 change end
                  ELSE
                      l_no_of_weeks_qtr := l_qtr_array(l_qtr_idx_name);
                  END IF;

                  l_curr_qtr_end_date := l_curr_qtr_start_date + 7*l_no_of_weeks_qtr - 1;
                  -- l_curr_qtr_id := TO_NUMBER(TO_CHAR(l_curr_qtr_start_date,g_QTR_ID_format));
                  SELECT DDR_R_BSNS_QTR_SEQ.NEXTVAL
                  INTO   l_curr_qtr_id
                  FROM   DUAL;
                  l_curr_qtr := TO_NUMBER(TO_CHAR(l_curr_year) || TO_CHAR(l_qtr_no));

                  insert into DDR_R_BSNS_QTR (
                      BSNS_QTR_ID,
                      MFG_ORG_CD,
                      CLNDR_CD,
                      QTR_CD,
                      QTR_NBR,
                      QTR_DESC,
                      QTR_STRT_DT,
                      QTR_END_DT,
                      QTR_TIMESPN,
                      BSNS_YR_ID,
                      YR_CD,
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
                  values (
                      l_curr_qtr_id,
                      l_mfg_org_cd,
                      l_clndr_cd,
                      l_curr_qtr,
                      l_curr_qtr,
                      l_curr_year_desc || ' Q' || TO_CHAR(l_qtr_no),
                      l_curr_qtr_start_date,
                      l_curr_qtr_end_date,
                      l_curr_qtr_end_date - l_curr_qtr_start_date + 1,
                      l_curr_year_id,
                      l_curr_year,
                      g_src_sys_idnt,
                      g_src_sys_dt,
                      g_crtd_by_DSR,
                      g_last_updt_by_DSR,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login
                  );
              END IF;

              IF (l_curr_date > l_curr_month_end_date) /* New Month */
              THEN
                  l_month_no := l_month_no + 1;
                  l_curr_month_start_date := l_curr_date;
                  l_month_idx_name := 'M' || to_char(l_month_no);

                  IF ( (l_spl_year_flag = TRUE) AND (l_extra_week_month = l_month_idx_name) )
                  THEN
                      l_no_of_weeks_month := l_month_array(l_month_idx_name) + 1;
                  ELSE
                      l_no_of_weeks_month := l_month_array(l_month_idx_name);
                  END IF;

                  l_curr_month_end_date := l_curr_month_start_date + 7*l_no_of_weeks_month - 1;
                  -- l_curr_month_id := TO_NUMBER(TO_CHAR(l_curr_month_start_date,g_MNTH_ID_format));
                  SELECT DDR_R_BSNS_MNTH_SEQ.NEXTVAL
                  INTO   l_curr_month_id
                  FROM   DUAL;
                  l_curr_month := TO_NUMBER(TO_CHAR(l_curr_year) || LPAD(TO_CHAR(l_month_no),2,'0'));

                  insert into DDR_R_BSNS_MNTH (
                      BSNS_MNTH_ID,
                      MFG_ORG_CD,
                      CLNDR_CD,
                      MNTH_CD,
                      MNTH_NBR,
                      MNTH_DESC,
                      MNTH_STRT_DT,
                      MNTH_END_DT,
                      MNTH_TIMESPN,
                      BSNS_QTR_ID,
                      QTR_CD,
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
                  values (
                      l_curr_month_id,
                      l_mfg_org_cd,
                      l_clndr_cd,
                      l_curr_month,
                      l_curr_month,
                      l_curr_year_desc || ' M' || TO_CHAR(l_month_no),
                      l_curr_month_start_date,
                      l_curr_month_end_date,
                      l_curr_month_end_date - l_curr_month_start_date + 1,
                      l_curr_qtr_id,
                      l_curr_qtr,
                      g_src_sys_idnt,
                      g_src_sys_dt,
                      g_crtd_by_DSR,
                      g_last_updt_by_DSR,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login
                  );
              END IF;

              /* Insert Record into Week table */
              l_week_no := l_week_no + 1;
              l_curr_week_start_date := l_curr_date;
              l_curr_week_end_date := l_curr_week_start_date + 7 - 1;
              -- l_curr_week_id := TO_NUMBER(TO_CHAR(l_curr_week_start_date,g_WK_ID_format));
              SELECT DDR_R_BSNS_WK_SEQ.NEXTVAL
              INTO   l_curr_week_id
              FROM   DUAL;
              l_curr_week := TO_NUMBER(TO_CHAR(l_curr_year) || LPAD(TO_CHAR(l_week_no),2,'0'));

              insert into DDR_R_BSNS_WK (
                  BSNS_WK_ID,
                  MFG_ORG_CD,
                  CLNDR_CD,
                  WK_CD,
                  WK_NBR,
                  WK_DESC,
                  WK_STRT_DT,
                  WK_END_DT,
                  WK_TIMESPN,
                  BSNS_MNTH_ID,
                  MNTH_CD,
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
              values (
                  l_curr_week_id,
                  l_mfg_org_cd,
                  l_clndr_cd,
                  l_curr_week,
                  l_curr_week,
                  l_curr_year_desc || ' W' || TO_CHAR(l_week_no),
                  l_curr_week_start_date,
                  l_curr_week_end_date,
                  l_curr_week_end_date - l_curr_week_start_date + 1,
                  l_curr_month_id,
                  l_curr_month,
                  g_src_sys_idnt,
                  g_src_sys_dt,
                  g_crtd_by_DSR,
                  g_last_updt_by_DSR,
                  g_created_by,
                  g_creation_date,
                  g_last_updated_by,
                  g_last_update_date,
                  g_last_update_login
              );

              /* Insert Records into Base Day table */
              l_curr_date := l_curr_date - 1;
              FOR day_idx IN 1 .. 7
              LOOP
                  l_curr_date := l_curr_date + 1;
                  l_day_no := l_day_no + 1;
                  l_curr_day_id := TO_NUMBER(TO_CHAR(l_curr_date,g_DAY_ID_format));

                  insert into DDR_R_BASE_DAY (
                      BASE_DAY_ID,
                      MFG_ORG_CD,
                      CLNDR_CD,
                      DAY_CD,
                      CLNDR_TYP,
                      WK_ID,
                      WK_CD,
                      MNTH_ID,
                      MNTH_CD,
                      DAY_OF_YR,
                      WKEND_IND,
                      CLNDR_STRT_DT,
                      CLNDR_END_DT,
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
                  values (
                      DDR_R_BASE_DAY_SEQ.NEXTVAL,
                      l_mfg_org_cd,
                      l_clndr_cd,
                      l_curr_day_id,
                      'BSNS',
                      l_curr_week_id,
                      l_curr_week,
                      l_curr_month_id,
                      l_curr_month,
                      l_day_no,
                      decode(TRIM(TO_CHAR(l_curr_date,'DAY')),'SATURDAY','Y','SUNDAY','Y','N'),
                      l_curr_date,
                      l_curr_date,
                      g_src_sys_idnt,
                      g_src_sys_dt,
                      g_crtd_by_DSR,
                      g_last_updt_by_DSR,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login
                  );
              END LOOP;

          END LOOP; /* end of week loop */

      END LOOP; /* end of year loop */

      COMMIT;
  END Populate_BSNS_Calendar;

  PROCEDURE Populate_FSCL_Calendar (
        p_org_cd              IN VARCHAR2,
        p_no_of_years         IN NUMBER,
        p_start_year_month    IN NUMBER  DEFAULT NULL
  )
  AS
      l_last_year               NUMBER;
      l_last_year_start_date    DATE;
      l_last_year_end_date      DATE;

      l_org_type                DDR_R_ORG.ORG_TYP%TYPE;
      l_mfg_org_cd              DDR_R_ORG.ORG_CD%TYPE;
      l_clndr_cd                DDR_R_CLNDR.CLNDR_CD%TYPE;
      l_missing_year            VARCHAR2(100);

      l_no_of_years             NUMBER;
      l_no_year_days            NUMBER;
      l_curr_year_id            NUMBER;
      l_curr_year               NUMBER;
      l_curr_year_start_date    DATE;
      l_curr_year_end_date      DATE;
      l_curr_year_desc          VARCHAR2(40);
      l_curr_qtr_id             NUMBER;
      l_curr_qtr                NUMBER;
      l_curr_qtr_start_date     DATE;
      l_curr_qtr_end_date       DATE;
      l_curr_month_id           NUMBER;
      l_curr_month              NUMBER;
      l_curr_month_start_date   DATE;
      l_curr_month_end_date     DATE;
      l_curr_day_id             NUMBER;
      l_curr_date               DATE;
      l_qtr_no                  NUMBER;
      l_month_no                NUMBER;
      l_day_no                  NUMBER;
  BEGIN
      /*
        Validate that p_org_cd is not null and also it is a valid organization as per DDR_R_ORG table
        Check that Organization Type in ('MFG')
      */
      IF p_org_cd IS NULL
      THEN
          Raise_Error('Organization Code must be specified');
      END IF;

      l_org_type := Get_Organization_Type(p_org_cd);
      IF l_org_type IS NULL
      THEN
          Raise_Error('Invalid Organization');
      END IF;

      IF l_org_type NOT IN ('MFG')
      THEN
          Raise_Error('Fiscal Calendar can be defined for Manufacturer only');
      END IF;

      /* Set the Manufacturer code with the given organization code */
      l_mfg_org_cd := p_org_cd;

      /* Check existence of record in DDR_R_FSCL_YR and get last year details */
      Get_Last_Year_Details('FSCL',p_org_cd,l_last_year,l_last_year_start_date,l_last_year_end_date);
      IF l_last_year IS NULL /* Last year record does not exist */
      THEN
          IF p_start_year_month IS NULL
          THEN
              Raise_Error('Start Year-Month (YYYYMM) must be specified');
          END IF;
          l_last_year := TO_NUMBER(SUBSTR(p_start_year_month,1,4))-1;
          l_last_year_end_date := TO_DATE(p_start_year_month,'YYYYMM')-1; /* Fiscal Year starts on 1st day of the month */
-- Bug# 6863276 change start
      ELSE
          IF p_start_year_month IS NOT NULL
          THEN
              Raise_Error('Start Year-Month (YYYYMM) must be NULL');
          END IF;
-- Bug# 6863276 change end
      END IF;

      l_no_of_years := nvl(p_no_of_years,1);

      /* Check existance of record in DDR_R_CLNDR_YR for all relevant years */
      l_missing_year := Check_Calendar_Year_Exists('FSCL',l_last_year_end_date+1,l_no_of_years,null);
      IF l_missing_year IS NOT NULL
      THEN
          Raise_Error('Standard Calendar to be populated for years (' || l_missing_year || ')');
      END IF;

      /*
        Check whether record exists in DDR_R_CLNDR for CLNDR_TYP='FSCL' and ORG_CD=p_org_cd;
        If no such record exists
        then
            Insert a record into DDR_R_CLNDR for the organization p_org_cd with CLNDR_TYP='FSCL';
        end if;
      */
      l_clndr_cd := Get_Calendar('FSCL',p_org_cd,l_mfg_org_cd);

      /* Initialize Year Variables for loop operation */
      l_curr_year := l_last_year;
      l_curr_year_start_date := l_last_year_start_date;
      l_curr_year_end_date := l_last_year_end_date;

      /* Create records in various Fiscal Calendar tables */
      FOR year_idx IN 1 .. l_no_of_years
      LOOP
          l_curr_year := l_curr_year +1;
          l_curr_year_start_date := l_curr_year_end_date+1;
          l_curr_year_end_date := ADD_MONTHS(l_curr_year_start_date,12)-1;
          l_no_year_days := l_curr_year_end_date - l_curr_year_start_date + 1;
          -- l_curr_year_id := TO_NUMBER(TO_CHAR(l_curr_year_start_date,g_YR_ID_format));
          SELECT DDR_R_FSCL_YR_SEQ.NEXTVAL
          INTO   l_curr_year_id
          FROM   DUAL;
          l_curr_year_desc := 'FY ' || TO_CHAR(l_curr_year);

          insert into DDR_R_FSCL_YR (
              FSCL_YR_ID,
              MFG_ORG_CD,
              CLNDR_CD,
              YR_CD,
              YR_NBR,
              YR_DESC,
              YR_STRT_DT,
              YR_END_DT,
              YR_TIMESPN,
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
          values (
              l_curr_year_id,
              l_mfg_org_cd,
              l_clndr_cd,
              l_curr_year,
              l_curr_year,
              l_curr_year_desc,
              l_curr_year_start_date,
              l_curr_year_end_date,
              l_no_year_days,
              g_src_sys_idnt,
              g_src_sys_dt,
              g_crtd_by_DSR,
              g_last_updt_by_DSR,
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login
          );

          /* Initialize Variables for loop operation */
          l_curr_qtr_end_date := l_curr_year_start_date - 1;
          l_curr_month_end_date := l_curr_year_start_date - 1;
          l_curr_date := l_curr_year_start_date - 1;
          l_qtr_no := 0;
          l_month_no := 0;
          l_day_no := 0;

          FOR day_idx IN 1 .. l_no_year_days
          LOOP
              l_curr_date := l_curr_date + 1;

              IF (l_curr_date > l_curr_qtr_end_date) /* New Quarter */
              THEN
                  l_qtr_no := l_qtr_no + 1;
                  l_curr_qtr_start_date := l_curr_date;
                  l_curr_qtr_end_date := ADD_MONTHS(l_curr_qtr_start_date,3)-1;
                  -- l_curr_qtr_id := TO_NUMBER(TO_CHAR(l_curr_qtr_start_date,g_QTR_ID_format));
                  SELECT DDR_R_FSCL_QTR_SEQ.NEXTVAL
                  INTO   l_curr_qtr_id
                  FROM   DUAL;
                  l_curr_qtr := TO_NUMBER(TO_CHAR(l_curr_year) || TO_CHAR(l_qtr_no));

                  insert into DDR_R_FSCL_QTR (
                      FSCL_QTR_ID,
                      MFG_ORG_CD,
                      CLNDR_CD,
                      QTR_CD,
                      QTR_NBR,
                      QTR_DESC,
                      QTR_STRT_DT,
                      QTR_END_DT,
                      QTR_TIMESPN,
                      FSCL_YR_ID,
                      YR_CD,
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
                  values (
                      l_curr_qtr_id,
                      l_mfg_org_cd,
                      l_clndr_cd,
                      l_curr_qtr,
                      l_curr_qtr,
                      l_curr_year_desc || ' Q' || TO_CHAR(l_qtr_no),
                      l_curr_qtr_start_date,
                      l_curr_qtr_end_date,
                      l_curr_qtr_end_date - l_curr_qtr_start_date + 1,
                      l_curr_year_id,
                      l_curr_year,
                      g_src_sys_idnt,
                      g_src_sys_dt,
                      g_crtd_by_DSR,
                      g_last_updt_by_DSR,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login
                  );
              END IF;

              IF (l_curr_date > l_curr_month_end_date) /* New Month */
              THEN
                  l_month_no := l_month_no + 1;
                  l_curr_month_start_date := l_curr_date;
                  l_curr_month_end_date := ADD_MONTHS(l_curr_month_start_date,1)-1;
                  -- l_curr_month_id := TO_NUMBER(TO_CHAR(l_curr_month_start_date,g_MNTH_ID_format));
                  SELECT DDR_R_FSCL_MNTH_SEQ.NEXTVAL
                  INTO   l_curr_month_id
                  FROM   DUAL;
                  l_curr_month := TO_NUMBER(TO_CHAR(l_curr_year) || LPAD(TO_CHAR(l_month_no),2,'0'));

                  insert into DDR_R_FSCL_MNTH (
                      FSCL_MNTH_ID,
                      MFG_ORG_CD,
                      CLNDR_CD,
                      MNTH_CD,
                      MNTH_NBR,
                      MNTH_DESC,
                      MNTH_STRT_DT,
                      MNTH_END_DT,
                      MNTH_TIMESPN,
                      FSCL_QTR_ID,
                      QTR_CD,
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
                  values (
                      l_curr_month_id,
                      l_mfg_org_cd,
                      l_clndr_cd,
                      l_curr_month,
                      l_curr_month,
                      l_curr_year_desc || ' M' || TO_CHAR(l_month_no),
                      l_curr_month_start_date,
                      l_curr_month_end_date,
                      l_curr_month_end_date - l_curr_month_start_date + 1,
                      l_curr_qtr_id,
                      l_curr_qtr,
                      g_src_sys_idnt,
                      g_src_sys_dt,
                      g_crtd_by_DSR,
                      g_last_updt_by_DSR,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login
                  );
              END IF;

              /* Insert Day Record */
              l_day_no := l_day_no + 1;
              l_curr_day_id := TO_NUMBER(TO_CHAR(l_curr_date,g_DAY_ID_format));

              insert into DDR_R_BASE_DAY (
                  BASE_DAY_ID,
                  MFG_ORG_CD,
                  CLNDR_CD,
                  DAY_CD,
                  CLNDR_TYP,
                  WK_ID,
                  WK_CD,
                  MNTH_ID,
                  MNTH_CD,
                  DAY_OF_YR,
                  WKEND_IND,
                  CLNDR_STRT_DT,
                  CLNDR_END_DT,
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
              values (
                  DDR_R_BASE_DAY_SEQ.NEXTVAL,
                  l_mfg_org_cd,
                  l_clndr_cd,
                  l_curr_day_id,
                  'FSCL',
                  null,
                  null,
                  l_curr_month_id,
                  l_curr_month,
                  l_day_no,
                  decode(TRIM(TO_CHAR(l_curr_date,'DAY')),'SATURDAY','Y','SUNDAY','Y','N'),
                  l_curr_date,
                  l_curr_date,
                  g_src_sys_idnt,
                  g_src_sys_dt,
                  g_crtd_by_DSR,
                  g_last_updt_by_DSR,
                  g_created_by,
                  g_creation_date,
                  g_last_updated_by,
                  g_last_update_date,
                  g_last_update_login
              );

          END LOOP; /* end of day loop */
      END LOOP; /* end of year loop */

      COMMIT;
  END Populate_FSCL_Calendar;

  PROCEDURE Populate_ADVR_Calendar (
        p_org_cd                IN VARCHAR2,
        p_no_of_years           IN NUMBER,
        p_start_date            IN DATE     DEFAULT NULL,
        p_period_dist_list      IN VARCHAR2,
        p_week_dist_list        IN VARCHAR2,
        p_special_year_list     IN VARCHAR2,
        p_extra_week_period     IN VARCHAR2
  )
  AS
      l_qtr_array               Number_Tab;
      l_period_array            Number_Tab;
      l_spl_year_array          Number_Tab;
      l_extra_week_period       VARCHAR2(30);

      l_last_year               NUMBER;
      l_last_year_start_date    DATE;
      l_last_year_end_date      DATE;

      l_org_type                DDR_R_ORG.ORG_TYP%TYPE;
      l_mfg_org_cd              DDR_R_ORG.ORG_CD%TYPE;
      l_clndr_cd                DDR_R_CLNDR.CLNDR_CD%TYPE;
      l_missing_year            VARCHAR2(100);

      l_spl_year_flag           BOOLEAN := FALSE;
      l_no_of_years             NUMBER;
      l_no_of_weeks             NUMBER;
      l_no_year_days            NUMBER;
      l_curr_year_id            NUMBER;
      l_curr_year               NUMBER;
      l_curr_year_start_date    DATE;
      l_curr_year_end_date      DATE;
      l_curr_year_desc          VARCHAR2(40);
      l_curr_qtr_id             NUMBER;
      l_curr_qtr                NUMBER;
      l_curr_qtr_start_date     DATE;
      l_curr_qtr_end_date       DATE;
      l_curr_period_id          NUMBER;
      l_curr_period             NUMBER;
      l_curr_period_start_date  DATE;
      l_curr_period_end_date    DATE;
      l_curr_week_id            NUMBER;
      l_curr_week               NUMBER;
      l_curr_week_start_date    DATE;
      l_curr_week_end_date      DATE;
      l_curr_day_id             NUMBER;
      l_curr_date               DATE;
      l_qtr_no                  NUMBER;
      l_period_no               NUMBER;
      l_week_no                 NUMBER;
      l_no_of_weeks_qtr         NUMBER;
      l_no_of_weeks_period      NUMBER;
      l_day_no                  NUMBER;
      l_qtr_idx_name            VARCHAR2(30);
      l_period_idx_name         VARCHAR2(30);
-- Bug# 6965786 change start
      l_spcl_qtr                VARCHAR2(30);
-- Bug# 6965786 change end
  BEGIN
      /*
        Validate that p_org_cd is not null and also it is a valid organization as per DDR_R_ORG table
        Check that Organization Type in ('MFG','RTL')
      */
      IF p_org_cd IS NULL
      THEN
          Raise_Error('Organization Code must be specified');
      END IF;

      l_org_type := Get_Organization_Type(p_org_cd);
      IF l_org_type IS NULL
      THEN
          Raise_Error('Invalid Organization');
      END IF;

      IF l_org_type NOT IN ('MFG')
      THEN
          Raise_Error('Advertising Calendar can be defined for Manufacturer only');
      END IF;

      /* Set the Manufacturer code with the given organization code */
      l_mfg_org_cd := p_org_cd;

      /* Check existence of record in DDR_R_ADVR_YR and get last year details */
      Get_Last_Year_Details('ADVR',p_org_cd,l_last_year,l_last_year_start_date,l_last_year_end_date);
      IF l_last_year IS NULL /* Last year record does not exist */
      THEN
          IF p_start_date IS NULL
          THEN
              Raise_Error('Start Date must be specified');
          END IF;
          l_last_year := TO_NUMBER(TO_CHAR(p_start_date,'YYYY'))-1;
          l_last_year_end_date := p_start_date - 1;
-- Bug# 6863276 change start
      ELSE
          IF p_start_date IS NOT NULL
          THEN
              Raise_Error('Start Date must be NULL');
          END IF;
-- Bug# 6863276 change end
      END IF;

      l_no_of_years := nvl(p_no_of_years,1);

      /* Populate ADVR different arrays like Quarter, Period, Special Year etc. */
      Populate_Period_Arrays(l_period_array,l_qtr_array,l_spl_year_array,p_period_dist_list,p_week_dist_list,p_special_year_list,p_extra_week_period,l_no_of_years,l_last_year_end_date+1);
      l_extra_week_period := REPLACE(UPPER(p_extra_week_period),' ','');

      /* Check existance of record in DDR_R_CLNDR_YR for all relevant years */
      l_missing_year := Check_Calendar_Year_Exists('ADVR',l_last_year_end_date+1,l_no_of_years,l_spl_year_array.COUNT);
      IF l_missing_year IS NOT NULL
      THEN
          Raise_Error('Standard Calendar to be populated for years (' || l_missing_year || ')');
      END IF;

      /*
        Check whether record exists in DDR_R_CLNDR for CLNDR_TYP='ADVR' and ORG_CD=p_org_cd;
        If no such record exists
        then
            Insert a record into DDR_R_CLNDR for the organization p_org_cd with CLNDR_TYP='ADVR';
        end if;
      */
      l_clndr_cd := Get_Calendar('ADVR',p_org_cd,l_mfg_org_cd);

      /* Initialize Year Variables for loop operation */
      l_curr_year := l_last_year;
      l_curr_year_start_date := l_last_year_start_date;
      l_curr_year_end_date := l_last_year_end_date;

-- Bug# 6965786 change start
      /* Calculating the special periode belongs in which quater  */
      l_spcl_qtr := Get_Spcl_Prd_Qtr(l_extra_week_period,l_qtr_array,l_period_array);
-- Bug# 6965786 change end

      /* Create records in various Advertising Calendar tables */
      FOR year_idx IN 1 .. l_no_of_years
      LOOP
          l_curr_year := l_curr_year + 1;

          IF l_spl_year_array.EXISTS(to_char(l_curr_year))
          THEN
              l_spl_year_flag := TRUE;
              l_no_of_weeks := 53;
          ELSE
              l_spl_year_flag := FALSE;
              l_no_of_weeks := 52;
          END IF;

          l_curr_year_start_date := l_curr_year_end_date+1;
          l_curr_year_end_date := l_curr_year_start_date + (7*l_no_of_weeks) - 1;
          l_no_year_days := l_curr_year_end_date - l_curr_year_start_date + 1;
          -- l_curr_year_id := TO_NUMBER(TO_CHAR(l_curr_year_start_date,g_YR_ID_format));
          SELECT DDR_R_ADVR_YR_SEQ.NEXTVAL
          INTO   l_curr_year_id
          FROM   DUAL;
          l_curr_year_desc := 'AY ' || TO_CHAR(l_curr_year);

          insert into DDR_R_ADVR_YR (
              ADVR_YR_ID,
              MFG_ORG_CD,
              CLNDR_CD,
              YR_CD,
              YR_NBR,
              YR_DESC,
              YR_STRT_DT,
              YR_END_DT,
              YR_TIMESPN,
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
          values (
              l_curr_year_id,
              l_mfg_org_cd,
              l_clndr_cd,
              l_curr_year,
              l_curr_year,
              l_curr_year_desc,
              l_curr_year_start_date,
              l_curr_year_end_date,
              l_no_year_days,
              g_src_sys_idnt,
              g_src_sys_dt,
              g_crtd_by_DSR,
              g_last_updt_by_DSR,
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login
          );

          /* Initialize Variables for loop operation */
          l_curr_qtr_end_date := l_curr_year_start_date - 1;
          l_curr_period_end_date := l_curr_year_start_date - 1;
          l_curr_date := l_curr_year_start_date - 1;
          l_qtr_no := 0;
          l_period_no := 0;
          l_week_no := 0;
          l_day_no := 0;

          FOR week_idx IN 1 .. l_no_of_weeks
          LOOP
              l_curr_date := l_curr_year_start_date + 7 * (week_idx-1);

              IF (l_curr_date > l_curr_qtr_end_date) /* New Quarter */
              THEN
                  l_qtr_no := l_qtr_no + 1;
                  l_curr_qtr_start_date := l_curr_date;
                  l_qtr_idx_name := 'Q' || to_char(l_qtr_no);
-- Bug# 6965786 change start
--                IF (l_spl_year_flag = TRUE)
                  IF (l_spl_year_flag = TRUE) AND l_spcl_qtr = l_qtr_idx_name
-- Bug# 6965786 change end
                  THEN
                      l_no_of_weeks_qtr := l_qtr_array(l_qtr_idx_name) + 1;
                  ELSE
                      l_no_of_weeks_qtr := l_qtr_array(l_qtr_idx_name);
                  END IF;

                  l_curr_qtr_end_date := l_curr_qtr_start_date + 7*l_no_of_weeks_qtr - 1;
                  -- l_curr_qtr_id := TO_NUMBER(TO_CHAR(l_curr_qtr_start_date,g_QTR_ID_format));
                  SELECT DDR_R_ADVR_QTR_SEQ.NEXTVAL
                  INTO   l_curr_qtr_id
                  FROM   DUAL;
                  l_curr_qtr := TO_NUMBER(TO_CHAR(l_curr_year) || TO_CHAR(l_qtr_no));

                  insert into DDR_R_ADVR_QTR (
                      ADVR_QTR_ID,
                      MFG_ORG_CD,
                      CLNDR_CD,
                      QTR_CD,
                      QTR_NBR,
                      QTR_DESC,
                      QTR_STRT_DT,
                      QTR_END_DT,
                      QTR_TIMESPN,
                      ADVR_YR_ID,
                      YR_CD,
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
                  values (
                      l_curr_qtr_id,
                      l_mfg_org_cd,
                      l_clndr_cd,
                      l_curr_qtr,
                      l_curr_qtr,
                      l_curr_year_desc || ' Q' || TO_CHAR(l_qtr_no),
                      l_curr_qtr_start_date,
                      l_curr_qtr_end_date,
                      l_curr_qtr_end_date - l_curr_qtr_start_date + 1,
                      l_curr_year_id,
                      l_curr_year,
                      g_src_sys_idnt,
                      g_src_sys_dt,
                      g_crtd_by_DSR,
                      g_last_updt_by_DSR,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login
                  );
              END IF;

              IF (l_curr_date > l_curr_period_end_date) /* New Period */
              THEN
                  l_period_no := l_period_no + 1;
                  l_curr_period_start_date := l_curr_date;
                  l_period_idx_name := 'P' || to_char(l_period_no);

                  IF ( (l_spl_year_flag = TRUE) AND (l_extra_week_period = l_period_idx_name) )
                  THEN
                      l_no_of_weeks_period := l_period_array(l_period_idx_name) + 1;
                  ELSE
                      l_no_of_weeks_period := l_period_array(l_period_idx_name);
                  END IF;

                  l_curr_period_end_date := l_curr_period_start_date + 7*l_no_of_weeks_period - 1;
                  -- l_curr_period_id := TO_NUMBER(TO_CHAR(l_curr_period_start_date,g_PRD_ID_format));
                  SELECT DDR_R_ADVR_PRD_SEQ.NEXTVAL
                  INTO   l_curr_period_id
                  FROM   DUAL;
                  l_curr_period := TO_NUMBER(TO_CHAR(l_curr_year) || LPAD(TO_CHAR(l_period_no),2,'0'));

                  insert into DDR_R_ADVR_PRD (
                      ADVR_PRD_ID,
                      MFG_ORG_CD,
                      CLNDR_CD,
                      PRD_CD,
                      PRD_NBR,
                      PRD_DESC,
                      PRD_STRT_DT,
                      PRD_END_DT,
                      PRD_TIMESPN,
                      ADVR_QTR_ID,
                      QTR_CD,
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
                  values (
                      l_curr_period_id,
                      l_mfg_org_cd,
                      l_clndr_cd,
                      l_curr_period,
                      l_curr_period,
                      l_curr_year_desc || ' P' || TO_CHAR(l_period_no),
                      l_curr_period_start_date,
                      l_curr_period_end_date,
                      l_curr_period_end_date - l_curr_period_start_date + 1,
                      l_curr_qtr_id,
                      l_curr_qtr,
                      g_src_sys_idnt,
                      g_src_sys_dt,
                      g_crtd_by_DSR,
                      g_last_updt_by_DSR,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login
                  );
              END IF;

              /* Insert Record into Week table */
              l_week_no := l_week_no + 1;
              l_curr_week_start_date := l_curr_date;
              l_curr_week_end_date := l_curr_week_start_date + 7 - 1;
              -- l_curr_week_id := TO_NUMBER(TO_CHAR(l_curr_week_start_date,g_WK_ID_format));
              SELECT DDR_R_ADVR_WK_SEQ.NEXTVAL
              INTO   l_curr_week_id
              FROM   DUAL;
              l_curr_week := TO_NUMBER(TO_CHAR(l_curr_year) || LPAD(TO_CHAR(l_week_no),2,'0'));

              insert into DDR_R_ADVR_WK (
                  ADVR_WK_ID,
                  MFG_ORG_CD,
                  CLNDR_CD,
                  WK_CD,
                  WK_NBR,
                  WK_DESC,
                  WK_STRT_DT,
                  WK_END_DT,
                  WK_TIMESPN,
                  ADVR_PRD_ID,
                  PRD_CD,
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
              values (
                  l_curr_week_id,
                  l_mfg_org_cd,
                  l_clndr_cd,
                  l_curr_week,
                  l_curr_week,
                  l_curr_year_desc || ' W' || TO_CHAR(l_week_no),
                  l_curr_week_start_date,
                  l_curr_week_end_date,
                  l_curr_week_end_date - l_curr_week_start_date + 1,
                  l_curr_period_id,
                  l_curr_period,
                  g_src_sys_idnt,
                  g_src_sys_dt,
                  g_crtd_by_DSR,
                  g_last_updt_by_DSR,
                  g_created_by,
                  g_creation_date,
                  g_last_updated_by,
                  g_last_update_date,
                  g_last_update_login
              );

              /* Insert Records into Base Day table */
              l_curr_date := l_curr_date - 1;
              FOR day_idx IN 1 .. 7
              LOOP
                  l_curr_date := l_curr_date + 1;
                  l_day_no := l_day_no + 1;
                  l_curr_day_id := TO_NUMBER(TO_CHAR(l_curr_date,g_DAY_ID_format));

                  insert into DDR_R_BASE_DAY (
                      BASE_DAY_ID,
                      MFG_ORG_CD,
                      CLNDR_CD,
                      DAY_CD,
                      CLNDR_TYP,
                      WK_ID,
                      WK_CD,
                      MNTH_ID,
                      MNTH_CD,
                      DAY_OF_YR,
                      WKEND_IND,
                      CLNDR_STRT_DT,
                      CLNDR_END_DT,
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
                  values (
                      DDR_R_BASE_DAY_SEQ.NEXTVAL,
                      l_mfg_org_cd,
                      l_clndr_cd,
                      l_curr_day_id,
                      'ADVR',
                      l_curr_week_id,
                      l_curr_week,
                      null,
                      null,
                      l_day_no,
                      decode(TRIM(TO_CHAR(l_curr_date,'DAY')),'SATURDAY','Y','SUNDAY','Y','N'),
                      l_curr_date,
                      l_curr_date,
                      g_src_sys_idnt,
                      g_src_sys_dt,
                      g_crtd_by_DSR,
                      g_last_updt_by_DSR,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login
                  );
              END LOOP;

          END LOOP; /* end of week loop */

      END LOOP; /* end of year loop */

      COMMIT;
  END Populate_ADVR_Calendar;

  PROCEDURE Populate_PLNG_Calendar (
        p_org_cd                IN VARCHAR2,
        p_no_of_years           IN NUMBER,
        p_start_date            IN DATE     DEFAULT NULL,
        p_period_dist_list      IN VARCHAR2,
        p_week_dist_list        IN VARCHAR2,
        p_special_year_list     IN VARCHAR2,
        p_extra_week_period     IN VARCHAR2
  )
  AS
      l_qtr_array               Number_Tab;
      l_period_array            Number_Tab;
      l_spl_year_array          Number_Tab;
      l_extra_week_period       VARCHAR2(30);

      l_last_year               NUMBER;
      l_last_year_start_date    DATE;
      l_last_year_end_date      DATE;

      l_org_type                DDR_R_ORG.ORG_TYP%TYPE;
      l_mfg_org_cd              DDR_R_ORG.ORG_CD%TYPE;
      l_clndr_cd                DDR_R_CLNDR.CLNDR_CD%TYPE;
      l_missing_year            VARCHAR2(100);

      l_spl_year_flag           BOOLEAN := FALSE;
      l_no_of_years             NUMBER;
      l_no_of_weeks             NUMBER;
      l_no_year_days            NUMBER;
      l_curr_year_id            NUMBER;
      l_curr_year               NUMBER;
      l_curr_year_start_date    DATE;
      l_curr_year_end_date      DATE;
      l_curr_year_desc          VARCHAR2(40);
      l_curr_qtr_id             NUMBER;
      l_curr_qtr                NUMBER;
      l_curr_qtr_start_date     DATE;
      l_curr_qtr_end_date       DATE;
      l_curr_period_id          NUMBER;
      l_curr_period             NUMBER;
      l_curr_period_start_date  DATE;
      l_curr_period_end_date    DATE;
      l_curr_week_id            NUMBER;
      l_curr_week               NUMBER;
      l_curr_week_start_date    DATE;
      l_curr_week_end_date      DATE;
      l_curr_day_id             NUMBER;
      l_curr_date               DATE;
      l_qtr_no                  NUMBER;
      l_period_no               NUMBER;
      l_week_no                 NUMBER;
      l_no_of_weeks_qtr         NUMBER;
      l_no_of_weeks_period      NUMBER;
      l_day_no                  NUMBER;
      l_qtr_idx_name            VARCHAR2(30);
      l_period_idx_name         VARCHAR2(30);
-- Bug# 6965786 change start
      l_spcl_qtr                VARCHAR2(30);
-- Bug# 6965786 change end
  BEGIN
      /*
        Validate that p_org_cd is not null and also it is a valid organization as per DDR_R_ORG table
        Check that Organization Type in ('MFG','RTL')
      */
      IF p_org_cd IS NULL
      THEN
          Raise_Error('Organization Code must be specified');
      END IF;

      l_org_type := Get_Organization_Type(p_org_cd);
      IF l_org_type IS NULL
      THEN
          Raise_Error('Invalid Organization');
      END IF;

      IF l_org_type NOT IN ('MFG')
      THEN
          Raise_Error('Planning Calendar can be defined for Manufacturer only');
      END IF;

      /* Set the Manufacturer code with the given organization code */
      l_mfg_org_cd := p_org_cd;

      /* Check existence of record in DDR_R_ADVR_YR and get last year details */
      Get_Last_Year_Details('PLNG',p_org_cd,l_last_year,l_last_year_start_date,l_last_year_end_date);
      IF l_last_year IS NULL /* Last year record does not exist */
      THEN
          IF p_start_date IS NULL
          THEN
              Raise_Error('Start Date must be specified');
          END IF;
          l_last_year := TO_NUMBER(TO_CHAR(p_start_date,'YYYY'))-1;
          l_last_year_end_date := p_start_date - 1;
-- Bug# 6863276 change start
      ELSE
          IF p_start_date IS NOT NULL
          THEN
              Raise_Error('Start Date must be NULL');
          END IF;
-- Bug# 6863276 change end
      END IF;

      l_no_of_years := nvl(p_no_of_years,1);

      /* Populate PLNG different arrays like Quarter, Period, Special Year etc. */
      Populate_Period_Arrays(l_period_array,l_qtr_array,l_spl_year_array,p_period_dist_list,p_week_dist_list,p_special_year_list,p_extra_week_period,l_no_of_years,l_last_year_end_date+1);
      l_extra_week_period := REPLACE(UPPER(p_extra_week_period),' ','');

      /* Check existance of record in DDR_R_CLNDR_YR for all relevant years */
      l_missing_year := Check_Calendar_Year_Exists('PLNG',l_last_year_end_date+1,l_no_of_years,l_spl_year_array.COUNT);
      IF l_missing_year IS NOT NULL
      THEN
          Raise_Error('Standard Calendar to be populated for years (' || l_missing_year || ')');
      END IF;

      /*
        Check whether record exists in DDR_R_CLNDR for CLNDR_TYP='PLNG' and ORG_CD=p_org_cd;
        If no such record exists
        then
            Insert a record into DDR_R_CLNDR for the organization p_org_cd with CLNDR_TYP='PLNG';
        end if;
      */
      l_clndr_cd := Get_Calendar('PLNG',p_org_cd,l_mfg_org_cd);

      /* Initialize Year Variables for loop operation */
      l_curr_year := l_last_year;
      l_curr_year_start_date := l_last_year_start_date;
      l_curr_year_end_date := l_last_year_end_date;

-- Bug# 6965786 change start
      /* Calculating the special periode belongs in which quater  */
      l_spcl_qtr := Get_Spcl_Prd_Qtr(l_extra_week_period,l_qtr_array,l_period_array);
-- Bug# 6965786 change end

      /* Create records in various Planning Calendar tables */
      FOR year_idx IN 1 .. l_no_of_years
      LOOP
          l_curr_year := l_curr_year + 1;

          IF l_spl_year_array.EXISTS(to_char(l_curr_year))
          THEN
              l_spl_year_flag := TRUE;
              l_no_of_weeks := 53;
          ELSE
              l_spl_year_flag := FALSE;
              l_no_of_weeks := 52;
          END IF;

          l_curr_year_start_date := l_curr_year_end_date+1;
          l_curr_year_end_date := l_curr_year_start_date + (7*l_no_of_weeks) - 1;
          l_no_year_days := l_curr_year_end_date - l_curr_year_start_date + 1;
          -- l_curr_year_id := TO_NUMBER(TO_CHAR(l_curr_year_start_date,g_YR_ID_format));
          SELECT DDR_R_PLNG_YR_SEQ.NEXTVAL
          INTO   l_curr_year_id
          FROM   DUAL;
          l_curr_year_desc := 'PY ' || TO_CHAR(l_curr_year);

          insert into DDR_R_PLNG_YR (
              PLNG_YR_ID,
              MFG_ORG_CD,
              CLNDR_CD,
              YR_CD,
              YR_NBR,
              YR_DESC,
              YR_STRT_DT,
              YR_END_DT,
              YR_TIMESPN,
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
          values (
              l_curr_year_id,
              l_mfg_org_cd,
              l_clndr_cd,
              l_curr_year,
              l_curr_year,
              l_curr_year_desc,
              l_curr_year_start_date,
              l_curr_year_end_date,
              l_no_year_days,
              g_src_sys_idnt,
              g_src_sys_dt,
              g_crtd_by_DSR,
              g_last_updt_by_DSR,
              g_created_by,
              g_creation_date,
              g_last_updated_by,
              g_last_update_date,
              g_last_update_login
          );

          /* Initialize Variables for loop operation */
          l_curr_qtr_end_date := l_curr_year_start_date - 1;
          l_curr_period_end_date := l_curr_year_start_date - 1;
          l_curr_date := l_curr_year_start_date - 1;
          l_qtr_no := 0;
          l_period_no := 0;
          l_week_no := 0;
          l_day_no := 0;

          FOR week_idx IN 1 .. l_no_of_weeks
          LOOP
              l_curr_date := l_curr_year_start_date + 7 * (week_idx-1);

              IF (l_curr_date > l_curr_qtr_end_date) /* New Quarter */
              THEN
                  l_qtr_no := l_qtr_no + 1;
                  l_curr_qtr_start_date := l_curr_date;
                  l_qtr_idx_name := 'Q' || to_char(l_qtr_no);

-- Bug# 6965786 change start
--                IF (l_spl_year_flag = TRUE)
                  IF (l_spl_year_flag = TRUE) AND l_spcl_qtr = l_qtr_idx_name
-- Bug# 6965786 change end
                  THEN
                      l_no_of_weeks_qtr := l_qtr_array(l_qtr_idx_name) + 1;
                  ELSE
                      l_no_of_weeks_qtr := l_qtr_array(l_qtr_idx_name);
                  END IF;

                  l_curr_qtr_end_date := l_curr_qtr_start_date + 7*l_no_of_weeks_qtr - 1;
                  -- l_curr_qtr_id := TO_NUMBER(TO_CHAR(l_curr_qtr_start_date,g_QTR_ID_format));
                  SELECT DDR_R_PLNG_QTR_SEQ.NEXTVAL
                  INTO   l_curr_qtr_id
                  FROM   DUAL;
                  l_curr_qtr := TO_NUMBER(TO_CHAR(l_curr_year) || TO_CHAR(l_qtr_no));

                  insert into DDR_R_PLNG_QTR (
                      PLNG_QTR_ID,
                      MFG_ORG_CD,
                      CLNDR_CD,
                      QTR_CD,
                      QTR_NBR,
                      QTR_DESC,
                      QTR_STRT_DT,
                      QTR_END_DT,
                      QTR_TIMESPN,
                      PLNG_YR_ID,
                      YR_CD,
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
                  values (
                      l_curr_qtr_id,
                      l_mfg_org_cd,
                      l_clndr_cd,
                      l_curr_qtr,
                      l_curr_qtr,
                      l_curr_year_desc || ' Q' || TO_CHAR(l_qtr_no),
                      l_curr_qtr_start_date,
                      l_curr_qtr_end_date,
                      l_curr_qtr_end_date - l_curr_qtr_start_date + 1,
                      l_curr_year_id,
                      l_curr_year,
                      g_src_sys_idnt,
                      g_src_sys_dt,
                      g_crtd_by_DSR,
                      g_last_updt_by_DSR,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login
                  );
              END IF;

              IF (l_curr_date > l_curr_period_end_date) /* New Period */
              THEN
                  l_period_no := l_period_no + 1;
                  l_curr_period_start_date := l_curr_date;
                  l_period_idx_name := 'P' || to_char(l_period_no);

                  IF ( (l_spl_year_flag = TRUE) AND (l_extra_week_period = l_period_idx_name) )
                  THEN
                      l_no_of_weeks_period := l_period_array(l_period_idx_name) + 1;
                  ELSE
                      l_no_of_weeks_period := l_period_array(l_period_idx_name);
                  END IF;

                  l_curr_period_end_date := l_curr_period_start_date + 7*l_no_of_weeks_period - 1;
                  -- l_curr_period_id := TO_NUMBER(TO_CHAR(l_curr_period_start_date,g_PRD_ID_format));
                  SELECT DDR_R_PLNG_PRD_SEQ.NEXTVAL
                  INTO   l_curr_period_id
                  FROM   DUAL;
                  l_curr_period := TO_NUMBER(TO_CHAR(l_curr_year) || LPAD(TO_CHAR(l_period_no),2,'0'));

                  insert into DDR_R_PLNG_PRD (
                      PLNG_PRD_ID,
                      MFG_ORG_CD,
                      CLNDR_CD,
                      PRD_CD,
                      PRD_NBR,
                      PRD_DESC,
                      PRD_STRT_DT,
                      PRD_END_DT,
                      PRD_TIMESPN,
                      PLNG_QTR_ID,
                      QTR_CD,
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
                  values (
                      l_curr_period_id,
                      l_mfg_org_cd,
                      l_clndr_cd,
                      l_curr_period,
                      l_curr_period,
                      l_curr_year_desc || ' P' || TO_CHAR(l_period_no),
                      l_curr_period_start_date,
                      l_curr_period_end_date,
                      l_curr_period_end_date - l_curr_period_start_date + 1,
                      l_curr_qtr_id,
                      l_curr_qtr,
                      g_src_sys_idnt,
                      g_src_sys_dt,
                      g_crtd_by_DSR,
                      g_last_updt_by_DSR,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login
                  );
              END IF;

              /* Insert Record into Week table */
              l_week_no := l_week_no + 1;
              l_curr_week_start_date := l_curr_date;
              l_curr_week_end_date := l_curr_week_start_date + 7 - 1;
              -- l_curr_week_id := TO_NUMBER(TO_CHAR(l_curr_week_start_date,g_WK_ID_format));
              SELECT DDR_R_PLNG_WK_SEQ.NEXTVAL
              INTO   l_curr_week_id
              FROM   DUAL;
              l_curr_week := TO_NUMBER(TO_CHAR(l_curr_year) || LPAD(TO_CHAR(l_week_no),2,'0'));

              insert into DDR_R_PLNG_WK (
                  PLNG_WK_ID,
                  MFG_ORG_CD,
                  CLNDR_CD,
                  WK_CD,
                  WK_NBR,
                  WK_DESC,
                  WK_STRT_DT,
                  WK_END_DT,
                  WK_TIMESPN,
                  PLNG_PRD_ID,
                  PRD_CD,
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
              values (
                  l_curr_week_id,
                  l_mfg_org_cd,
                  l_clndr_cd,
                  l_curr_week,
                  l_curr_week,
                  l_curr_year_desc || ' W' || TO_CHAR(l_week_no),
                  l_curr_week_start_date,
                  l_curr_week_end_date,
                  l_curr_week_end_date - l_curr_week_start_date + 1,
                  l_curr_period_id,
                  l_curr_period,
                  g_src_sys_idnt,
                  g_src_sys_dt,
                  g_crtd_by_DSR,
                  g_last_updt_by_DSR,
                  g_created_by,
                  g_creation_date,
                  g_last_updated_by,
                  g_last_update_date,
                  g_last_update_login
              );

              /* Insert Records into Base Day table */
              l_curr_date := l_curr_date - 1;
              FOR day_idx IN 1 .. 7
              LOOP
                  l_curr_date := l_curr_date + 1;
                  l_day_no := l_day_no + 1;
                  l_curr_day_id := TO_NUMBER(TO_CHAR(l_curr_date,g_DAY_ID_format));

                  insert into DDR_R_BASE_DAY (
                      BASE_DAY_ID,
                      MFG_ORG_CD,
                      CLNDR_CD,
                      DAY_CD,
                      CLNDR_TYP,
                      WK_ID,
                      WK_CD,
                      MNTH_ID,
                      MNTH_CD,
                      DAY_OF_YR,
                      WKEND_IND,
                      CLNDR_STRT_DT,
                      CLNDR_END_DT,
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
                  values (
                      DDR_R_BASE_DAY_SEQ.NEXTVAL,
                      l_mfg_org_cd,
                      l_clndr_cd,
                      l_curr_day_id,
                      'PLNG',
                      l_curr_week_id,
                      l_curr_week,
                      null,
                      null,
                      l_day_no,
                      decode(TRIM(TO_CHAR(l_curr_date,'DAY')),'SATURDAY','Y','SUNDAY','Y','N'),
                      l_curr_date,
                      l_curr_date,
                      g_src_sys_idnt,
                      g_src_sys_dt,
                      g_crtd_by_DSR,
                      g_last_updt_by_DSR,
                      g_created_by,
                      g_creation_date,
                      g_last_updated_by,
                      g_last_update_date,
                      g_last_update_login
                  );
              END LOOP;

          END LOOP; /* end of week loop */

      END LOOP; /* end of year loop */

      COMMIT;
  END Populate_PLNG_Calendar;

END ddr_pop_calendar_pkg;

/
