--------------------------------------------------------
--  DDL for Package Body DDR_REF_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DDR_REF_UTIL_PKG" AS
/* $Header: ddrurefb.pls 120.2.12010000.6 2010/04/27 00:39:31 gglover ship $ */

FUNCTION GET_ERR_MSG (p_err_no VARCHAR2 DEFAULT NULL)
RETURN varchar2 as
 l_err_msg VARCHAR2(40);
begin
  if p_err_no is not null then
    select err_name into l_err_msg from ddr_l_err where err_cd = p_err_no;
    return (l_err_msg);
  else
    return(null);
  end if;
end GET_ERR_MSG;

PROCEDURE TRUNC_INTERFACE (p_table_parameters IN VARCHAR2 DEFAULT NULL)
IS

 n                number;
 text             varchar2(500);
 cut_text         varchar2(100);
 p_loading_mode   varchar2(40);
Begin
 select param_val into p_loading_mode from ddr_l_sys_param where param_cd = 'RUN_TYP_REF';
 text:=p_table_parameters;
 If
    text is not null
 Then
    Loop
    n:=0;
    n:= Instr(text,',');
    If
             n<>0
      Then
                   cut_text:= Substr(text,1,n-1);
              Else
                   cut_text:= text;
      End If;

   If p_loading_mode = 'P' THEN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '|| 'DDR.' || CUT_TEXT;
   END IF;
    Exit when n=0;
    text:= Substr(text,n+1);
   End Loop;
 End If;
End TRUNC_INTERFACE;

FUNCTION CHECK_MFG_ITEM_HCHY (p_hchy_cd VARCHAR2, p_hchy_level VARCHAR2)
RETURN VARCHAR2
as
	l_mfg_item_lvl NUMBER;
        l_return       VARCHAR2(30);

	CURSOR cur_cmpny IS
	SELECT 1
	FROM   DDR_R_MFG_ITEM_CMPNY
	WHERE  MFG_CMPNY_CD = p_hchy_cd;

	CURSOR cur_div IS
	SELECT 1
	FROM   DDR_R_MFG_ITEM_DIV
	WHERE  MFG_DIV_CD = p_hchy_cd
	AND    EFF_TO_DT IS NULL;

	CURSOR cur_grp IS
	SELECT 1
	FROM   DDR_R_MFG_ITEM_GRP
	WHERE  MFG_GRP_CD = p_hchy_cd
	AND    EFF_TO_DT IS NULL;

	CURSOR cur_class IS
	SELECT 1
	FROM   DDR_R_MFG_ITEM_CLASS
	WHERE  MFG_CLASS_CD = p_hchy_cd
	AND    EFF_TO_DT IS NULL;

	CURSOR cur_sbc IS
	SELECT 1
	FROM   DDR_R_MFG_ITEM_SBC
	WHERE  MFG_SBC_CD = p_hchy_cd
	AND    EFF_TO_DT IS NULL;

	CURSOR cur_item IS
	SELECT 1
	FROM   DDR_R_MFG_ITEM
	WHERE  MFG_ITEM_NBR = p_hchy_cd
	AND    EFF_TO_DT IS NULL;

	CURSOR cur_sku IS
	SELECT 1
	FROM  DDR_R_MFG_SKU_ITEM
	WHERE MFG_SKU_ITEM_NBR = p_hchy_cd
	AND   EFF_TO_DT IS NULL;

Begin
	IF p_hchy_level IS NULL OR p_hchy_cd IS NULL
	THEN
		l_return := 'DSR-1001';
		RETURN (l_return);
	END IF;

	l_mfg_item_lvl := -1;
	IF UPPER(p_hchy_level) IN ('COMPANY','DIVISION','GROUP','CLASS','SUBCLASS','ITEM','SKU','NA') THEN

		IF p_hchy_level='COMPANY'
		THEN
		    	OPEN cur_cmpny;
		    	FETCH cur_cmpny INTO l_mfg_item_lvl;
		    	CLOSE cur_cmpny;
		ELSIF p_hchy_level='DIVISION'
		THEN
			OPEN cur_div;
			FETCH cur_div INTO l_mfg_item_lvl;
			CLOSE cur_div;
		ELSIF p_hchy_level='GROUP'
		THEN
			OPEN cur_grp;
			FETCH cur_grp INTO l_mfg_item_lvl;
			CLOSE cur_grp;
		ELSIF p_hchy_level='CLASS'
		THEN
			OPEN cur_class;
			FETCH cur_class INTO l_mfg_item_lvl;
			CLOSE cur_class;
		ELSIF p_hchy_level='SUBCLASS'
		THEN
			OPEN cur_sbc;
			FETCH cur_sbc INTO l_mfg_item_lvl;
			CLOSE cur_sbc;
		ELSIF p_hchy_level='ITEM'
		THEN
			OPEN cur_item;
			FETCH cur_item INTO l_mfg_item_lvl;
			CLOSE cur_item;
		ELSIF p_hchy_level='SKU'
		THEN
			OPEN cur_sku;
			FETCH cur_sku INTO l_mfg_item_lvl;
			CLOSE cur_sku;
		ELSIF p_hchy_level='NA'
                THEN
			IF p_hchy_cd ='-1'
			THEN
				l_mfg_item_lvl := 1;
			ELSE
				l_mfg_item_lvl := -1;
			END IF;
		END IF;

		IF l_mfg_item_lvl='-1'
		THEN
			l_return := 'DSR-1002';
		END IF;

	ELSE l_return := 'DSR-1002';
	END IF;

        RETURN(l_return);
End CHECK_MFG_ITEM_HCHY;

FUNCTION CHECK_ORG_HCHY (p_hchy_cd VARCHAR2, p_hchy_level VARCHAR2, p_org_cd
VARCHAR2)
RETURN VARCHAR2
as
	l_org_lvl  NUMBER;
        l_return VARCHAR2(30);
        l_rtl_org_cd NUMBER;
        l_valid_org_bu NUMBER;

        CURSOR cur_org IS
        SELECT 1
        FROM  DDR_R_ORG
        WHERE ORG_CD = p_org_cd;

        CURSOR cur_chain IS
        SELECT 1
        FROM   DDR_R_ORG_CHAIN
        WHERE  CHAIN_CD = p_hchy_cd
        AND    ORG_CD = p_org_cd
        AND    EFF_TO_DT IS NULL;

        CURSOR cur_area IS
        SELECT 1
        FROM   DDR_R_ORG_AREA
        WHERE  AREA_CD = p_hchy_cd
        AND    ORG_CD = p_org_cd
        AND    EFF_TO_DT IS NULL;

        CURSOR cur_rgn IS
        SELECT 1
        FROM   DDR_R_ORG_RGN
        WHERE  RGN_CD = p_hchy_cd
        AND    ORG_CD = p_org_cd
        AND    EFF_TO_DT IS NULL;

        CURSOR cur_dstrct IS
        SELECT 1
        FROM   DDR_R_ORG_DSTRCT
        WHERE  DSTRCT_CD = p_hchy_cd
        AND    ORG_CD = p_org_cd
        AND    EFF_TO_DT IS NULL;

        CURSOR cur_bsns_unit IS
        SELECT 1
        FROM   DDR_R_ORG_BSNS_UNIT
        WHERE  BSNS_UNIT_CD = p_hchy_cd
        AND    ORG_CD = p_org_cd
        AND    EFF_TO_DT IS NULL;
Begin
	IF p_hchy_level IS NULL OR p_hchy_cd IS NULL OR p_org_cd IS NULL
        THEN
		l_return := 'DSR-1001';
                RETURN l_return;
        END IF;

        l_org_lvl := -1;
	IF UPPER(p_hchy_level) IN ('ORGANIZATION','CHAIN','AREA','REGION','DISTRICT','BU')
        THEN

		IF p_hchy_level='ORGANIZATION'
		THEN
                   IF p_hchy_cd = p_org_cd
                   THEN
		      OPEN  cur_org;
                      FETCH cur_org INTO l_org_lvl;
                      CLOSE cur_org;
                   ELSE
                      l_org_lvl := -1;
                   END IF;
		ELSIF p_hchy_level='CHAIN'
		THEN
                    OPEN  cur_chain;
                    FETCH cur_chain INTO l_org_lvl;
                    CLOSE cur_chain;
		ELSIF p_hchy_level='AREA'
		THEN
                    OPEN  cur_area;
                    FETCH cur_area INTO l_org_lvl;
                    CLOSE cur_area;
		ELSIF p_hchy_level='REGION'
		THEN
                    OPEN  cur_rgn;
                    FETCH cur_rgn INTO l_org_lvl;
                    CLOSE cur_rgn;
		ELSIF p_hchy_level='DISTRICT'
		THEN
                    OPEN  cur_dstrct;
                    FETCH cur_dstrct INTO l_org_lvl;
                    CLOSE cur_dstrct;
		ELSIF p_hchy_level='BU'
		THEN
                    OPEN  cur_bsns_unit;
                    FETCH cur_bsns_unit INTO l_org_lvl;
                    CLOSE cur_bsns_unit;
                END IF;

	ELSIF p_hchy_level='NA'
        THEN
            IF p_hchy_cd ='-1' AND p_org_cd = '-1'
            THEN
		l_org_lvl := 1;
	    ELSE
		l_org_lvl := -1;
	    END IF;

	ELSE l_return := 'DSR-1002';
	END IF;

        IF l_org_lvl ='-1'
        THEN
            l_return := 'DSR-1006';
        END IF;

        RETURN(l_return);
End CHECK_ORG_HCHY;

FUNCTION CHECK_RTL_ITEM_HCHY (p_hchy_cd VARCHAR2, p_hchy_level VARCHAR2)
RETURN VARCHAR2
as
	l_rtl_item_lvl NUMBER;
        l_return       VARCHAR2(30);

	CURSOR cur_cmpny IS
	SELECT 1
	FROM   DDR_R_RTL_ITEM_CMPNY
	WHERE  RTL_CMPNY_CD = p_hchy_cd;

	CURSOR cur_div IS
	SELECT 1
	FROM   DDR_R_RTL_ITEM_DIV
	WHERE  RTL_DIV_CD = p_hchy_cd
	AND    EFF_TO_DT IS NULL;

	CURSOR cur_grp IS
	SELECT 1
	FROM   DDR_R_RTL_ITEM_GRP
	WHERE  RTL_GRP_CD = p_hchy_cd
	AND    EFF_TO_DT IS NULL;

	CURSOR cur_dept IS
 	SELECT 1
	FROM   DDR_R_RTL_ITEM_DEPT
	WHERE  RTL_DEPT_CD = p_hchy_cd
	AND    EFF_TO_DT IS NULL;

	CURSOR cur_class IS
	SELECT 1
	FROM   DDR_R_RTL_ITEM_CLASS
	WHERE  RTL_CLASS_CD = p_hchy_cd
	AND    EFF_TO_DT IS NULL;

	CURSOR cur_sbc IS
	SELECT 1
	FROM   DDR_R_RTL_ITEM_SBC
	WHERE  RTL_SBC_CD = p_hchy_cd
	AND    EFF_TO_DT IS NULL;

	CURSOR cur_item IS
	SELECT 1
	FROM   DDR_R_RTL_ITEM
	WHERE  RTL_ITEM_NBR = p_hchy_cd
	AND    EFF_TO_DT IS NULL;

	CURSOR cur_sku IS
	SELECT 1
	FROM  DDR_R_RTL_SKU_ITEM
	WHERE RTL_SKU_ITEM_NBR = p_hchy_cd
	AND   EFF_TO_DT IS NULL;

Begin
	IF p_hchy_level IS NULL OR p_hchy_cd IS NULL
	THEN
		l_return := 'DSR-1001';
		RETURN (l_return);
	END IF;

	l_rtl_item_lvl := -1;
	IF UPPER(p_hchy_level) IN ('COMPANY','DIVISION','GROUP','DEPARTMENT','CLASS','SUBCLASS','ITEM','SKU','NA') THEN

		IF p_hchy_level='COMPANY'
		THEN
		    	OPEN cur_cmpny;
		    	FETCH cur_cmpny INTO l_rtl_item_lvl;
		    	CLOSE cur_cmpny;
		ELSIF p_hchy_level='DIVISION'
		THEN
			OPEN cur_div;
			FETCH cur_div INTO l_rtl_item_lvl;
			CLOSE cur_div;
		ELSIF p_hchy_level='GROUP'
		THEN
			OPEN cur_grp;
			FETCH cur_grp INTO l_rtl_item_lvl;
			CLOSE cur_grp;
		ELSIF p_hchy_level='DEPARTMENT'
		THEN
			OPEN cur_dept;
			FETCH cur_dept INTO l_rtl_item_lvl;
			CLOSE cur_dept;
		ELSIF p_hchy_level='CLASS'
		THEN
			OPEN cur_class;
			FETCH cur_class INTO l_rtl_item_lvl;
			CLOSE cur_class;
		ELSIF p_hchy_level='SUBCLASS'
		THEN
			OPEN cur_sbc;
			FETCH cur_sbc INTO l_rtl_item_lvl;
			CLOSE cur_sbc;
		ELSIF p_hchy_level='ITEM'
		THEN
			OPEN cur_item;
			FETCH cur_item INTO l_rtl_item_lvl;
			CLOSE cur_item;
		ELSIF p_hchy_level='SKU'
		THEN
			OPEN cur_sku;
			FETCH cur_sku INTO l_rtl_item_lvl;
			CLOSE cur_sku;
		ELSIF p_hchy_level='NA'
                THEN
			IF p_hchy_cd ='-1'
			THEN
				l_rtl_item_lvl := 1;
			ELSE
				l_rtl_item_lvl := -1;
			END IF;
		END IF;

		IF l_rtl_item_lvl='-1'
		THEN
			l_return := 'DSR-1002';
		END IF;

	ELSE l_return := 'DSR-1002';
	END IF;

        RETURN(l_return);
End CHECK_RTL_ITEM_HCHY;

FUNCTION CHECK_TIME_HCHY (p_hchy_cd VARCHAR2, p_hchy_level VARCHAR2)
RETURN VARCHAR2
as
	l_time_lvl NUMBER;
        l_return       VARCHAR2(30);

	CURSOR cur_yr IS
	SELECT 1
	FROM   DDR_R_BSNS_YR
	WHERE  YR_CD = p_hchy_cd;

	CURSOR cur_qtr IS
	SELECT 1
	FROM   DDR_R_BSNS_QTR
	WHERE  QTR_CD = p_hchy_cd;

	CURSOR cur_mnth IS
	SELECT 1
	FROM   DDR_R_BSNS_MNTH
	WHERE  MNTH_CD = p_hchy_cd;

	CURSOR cur_wk IS
 	SELECT 1
	FROM   DDR_R_BSNS_WK
	WHERE  WK_CD = p_hchy_cd;

	CURSOR cur_day IS
	SELECT 1
	FROM   DDR_R_DAY
	WHERE  DAY_CD = p_hchy_cd;

Begin
	IF p_hchy_level IS NULL OR p_hchy_cd IS NULL
	THEN
		l_return := 'DSR-1001';
		RETURN (l_return);
	END IF;

	l_time_lvl := -1;
	IF UPPER(p_hchy_level) IN ('YEAR','QUARTER','MONTH','WEEK','DAY','NA') THEN

		IF p_hchy_level='YEAR'
		THEN
		    	OPEN cur_yr;
		    	FETCH cur_yr INTO l_time_lvl;
		    	CLOSE cur_yr;
		ELSIF p_hchy_level='QUARTER'
		THEN
			OPEN cur_qtr;
			FETCH cur_qtr INTO l_time_lvl;
			CLOSE cur_qtr;
		ELSIF p_hchy_level='MONTH'
		THEN
			OPEN cur_mnth;
			FETCH cur_mnth INTO l_time_lvl;
			CLOSE cur_mnth;
		ELSIF p_hchy_level='WEEK'
		THEN
			OPEN cur_wk;
			FETCH cur_wk INTO l_time_lvl;
			CLOSE cur_wk;
		ELSIF p_hchy_level='DAY'
		THEN
			OPEN cur_day;
			FETCH cur_day INTO l_time_lvl;
			CLOSE cur_day;
		ELSIF p_hchy_level='NA'
                THEN
			IF p_hchy_cd ='-1'
			THEN
				l_time_lvl := 1;
			ELSE
				l_time_lvl := -1;
			END IF;
		END IF;

		IF l_time_lvl ='-1'
		THEN
			l_return := 'DSR-1002';
		END IF;

	ELSE l_return := 'DSR-1002';
	END IF;

        RETURN(l_return);
End CHECK_TIME_HCHY;

FUNCTION GET_REF_MAP_RUN_ID(P_AUDIT_ID VARCHAR2) RETURN NUMBER IS

BEGIN
  IF p_audit_id = c_audit_id THEN  --{
    RETURN c_map_id;
  ELSE  --}{
    c_audit_id := p_audit_id;

    select DDR_LOAD_SEQ.NEXTVAL
    into c_map_id
    from dual;

    RETURN c_map_id;
  END IF;  --}

END GET_REF_MAP_RUN_ID;

PROCEDURE parse_pad_accounts(p_max_level IN NUMBER DEFAULT 10) AS
    v_elems      account_array;  -- array indexed by level
    v_elems_ID   account_array;  -- array indexed by level
    v_counter    NUMBER := 0;
    v_curr_level NUMBER := 1;
    v_prev_level NUMBER := 0;

    -- We want to denormailze the account hierarchy but because of SCD2, there could be records
    -- with same account but different from/to dates. To remove this problem we need to associate
    -- by account id and parent account id instead of acocunt code.
    -- However, account id is generated by the dimension object. Currently the dimension object is
    -- set as one-level and no hierarchy. Therefore there is no way to produce parent account id
    -- there. As a result we have to use PL/SQL to add the parent account id after the SCD2 data is generated.
    --
    -- generate parent account id from SCD2 data, assuming new open records have higher
    -- ID than older or closed ones. Couple of note points:
    -- 1. Some duplicate records are present when looking up manager id. These will have mismatched
    --    from/to dates and are filtered out by date order by emp_id in the first WHERE clause
    -- 2. The top accounts are missed out in the first query. They are added in by the second query.
    CURSOR account_cursor IS
    SELECT ORG_HCHY_ID, HRCHY_CD, CHILD_ID BSNS_ENT_ID, LEVEL, CHILD_CD BSNS_ENT_CD,
           SRC_SYS_DT, SRC_SYS_IDNT, EFF_FROM_DT, EFF_TO_DT
    FROM
    (
      SELECT ORG_HCHY_ID, HRCHY_CD, PARENT_ID, PARENT_CD, CHILD_ID, CHILD_CD,
             SRC_SYS_DT, SRC_SYS_IDNT, EFF_FROM_DT, EFF_TO_DT
      FROM
      (
        SELECT t1.ORG_HCHY_ID ORG_HCHY_ID, t1.HRCHY_CD HRCHY_CD,
               t1.ORG_BSNS_ENT_ID PARENT_ID, t1.BSNS_ENT_CD PARENT_CD,
               t2.ORG_BSNS_ENT_ID CHILD_ID, t2.BSNS_ENT_CD CHILD_CD,
               t2.SRC_SYS_DT SRC_SYS_DT, t2.SRC_SYS_IDNT SRC_SYS_IDNT,
               t1.EFF_FROM_DT EFF_FROM_DT, t1.EFF_TO_DT, t2.EFF_FROM_DT FROM_DT_2, t2.EFF_TO_DT TO_DT_2
        FROM DDR_R_ORG_BSNS_ENT t1 INNER JOIN DDR_R_ORG_BSNS_ENT t2
        ON (t1.BSNS_ENT_CD = t2.BSNS_ENT_PRNT_CD  AND t1.ORG_HCHY_ID =
t2.ORG_HCHY_ID)
      )
      WHERE NOT ((TO_DT_2 is not null AND TO_DT_2 < EFF_FROM_DT) OR (EFF_TO_DT is not null AND FROM_DT_2 > EFF_TO_DT))
      UNION
      (
        SELECT
          ORG_HCHY_ID, HRCHY_CD,
          CASE WHEN BSNS_ENT_PRNT_CD is null THEN null
          ELSE ORG_BSNS_ENT_ID
          END PARENT_ID,
          BSNS_ENT_PRNT_CD PARENT_CD,
          ORG_BSNS_ENT_ID CHILD_ID,
          BSNS_ENT_CD CHILD_CD,
          SRC_SYS_DT, SRC_SYS_IDNT,
          EFF_FROM_DT, EFF_TO_DT
        FROM DDR_R_ORG_BSNS_ENT
        WHERE BSNS_ENT_PRNT_CD is null
      )
    )
    START WITH PARENT_CD is null
    CONNECT BY PARENT_ID = PRIOR CHILD_ID;


    -- store previous record columns before level change
    v_hchy_id NUMBER;
    v_hchy_cd VARCHAR2(30);
    v_acct_id NUMBER;
    v_acct_cd VARCHAR2(30);
    v_sys_id  VARCHAR2(40);
    v_sys_dt  DATE;

    v_sql_stmt VARCHAR2(2048) := '';
    v_sql_hdr1  VARCHAR2(250) := 'INSERT INTO DDR_R_AOH_LVL_DTL (ORG_HCHY_ID,HRCHY_CD, BSNS_ENT_ID,BSNS_ENT_CD,BSNS_ENT_LEVEL,PRNT1_BSNS_ENT_CD,PRNT1_BSNS_ENT_ID,PRNT2_BSNS_ENT_CD, PRNT2_BSNS_ENT_ID,PRNT3_BSNS_ENT_CD,PRNT3_BSNS_ENT_ID,';
    v_sql_hdr2  VARCHAR2(250) := 'PRNT4_BSNS_ENT_CD,PRNT4_BSNS_ENT_ID, PRNT5_BSNS_ENT_CD,PRNT5_BSNS_ENT_ID,PRNT6_BSNS_ENT_CD,PRNT6_BSNS_ENT_ID,PRNT7_BSNS_ENT_CD, PRNT7_BSNS_ENT_ID,PRNT8_BSNS_ENT_CD,PRNT8_BSNS_ENT_ID,PRNT9_BSNS_ENT_CD,PRNT9_BSNS_ENT_ID,';
    v_sql_hdr3 VARCHAR2(250) := 'SRC_SYS_IDNT,SRC_SYS_DT,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,CRTD_BY_DSR, LAST_UPDT_BY_DSR,LAST_UPDATE_LOGIN) VALUES(';

    v_hchy_cols VARCHAR2(100) :='';
    v_acct_cols VARCHAR2(100) := '';
    v_prnt_cols VARCHAR2(1000) := '';
    v_sys_cols  VARCHAR2(100) := '';

    v_commit_stmt VARCHAR2(10) := 'commit';

BEGIN
    -- clean up the previous records
    EXECUTE IMMEDIATE 'truncate table DDR.DDR_R_AOH_LVL_DTL drop storage';

    -- The logic detects individual branch in the tree:
    -- 1. Read a row, if it is second row or more, we initialize previous level
    -- 2. store the account level and code from current record
    -- 3. if level has decreased, we write all previously accumulated accounts into one record
    -- 4. clean up and start from current record to start traversing a new branch.

    FOR acct_rec IN account_cursor
    LOOP
        v_counter := v_counter + 1;

        -- set previous level after one record is read
        IF (v_counter  > 1)
        THEN
            v_prev_level := v_curr_level;
        END IF;

        v_curr_level := acct_rec.LEVEL;
        v_elems(v_counter) := acct_rec.BSNS_ENT_CD;
        v_elems_id(v_counter) := acct_rec.BSNS_ENT_ID;

        -- Adjust counter and account array pointer when level is not in order
        IF ( v_prev_level > 0 AND v_curr_level <= v_prev_level )
        THEN
            -- write to table in Elems from 1..Counter
            v_hchy_cols := v_hchy_id || ',' || '''' || v_hchy_cd || '''' || ',';
            v_acct_cols := v_acct_id || ',' || '''' || v_acct_cd || '''' || ',' || v_prev_level || ',';
            FOR p in 1..p_max_level-1
            LOOP
                IF (p < v_counter)
                THEN
                    v_prnt_cols := v_prnt_cols || '''' || v_elems(p) || '''' || ',' || v_elems_id(p) || ',';
                ELSE
                    v_prnt_Cols := v_prnt_Cols || '''' || v_elems(v_counter-1) || '''' || ',' || v_elems_id(v_counter-1) || ',';  -- padding
                END IF;
            END LOOP;

            v_sys_cols := '''' || v_sys_id || '''' || ',' || 'TO_DATE(' || '''' || v_sys_dt || '''' || '),' || 'SYSDATE' || ', -1,' || 'SYSDATE' || ',-1,' || '''' || USER || '''' || ',' || '''' || USER || '''' || ',-1';
            v_sql_stmt := v_sql_hdr1 || v_sql_hdr2 || v_sql_hdr3 || v_hchy_cols || v_acct_cols || v_prnt_cols || v_sys_cols || ')';
            --dbms_output.put_line(v_sql_stmt);
            EXECUTE IMMEDIATE v_sql_stmt;

            -- clean up the statements for next time
            v_hchy_cols := '';
            v_acct_cols := '';
            v_prnt_cols := '';
            v_sys_cols := '';
        END IF;

        -- reset account array to previous level
        FOR i IN v_curr_level..v_counter
        LOOP
            v_elems(i) := null;
            v_elems_id(i) := null;
        END LOOP;

        -- retreat back to the levels corresponding to the record we read
        v_counter := v_curr_level;
        v_prev_level := v_curr_level - 1;
        v_elems(v_counter) := acct_rec.BSNS_ENT_CD;
        v_elems_id(v_counter) := acct_rec.BSNS_ENT_ID;

        -- store account attrs used to write to table when level changes as at that time
        -- cursor already points to the next record.
        v_hchy_id := acct_rec.ORG_HCHY_ID;
        v_hchy_cd := acct_rec.HRCHY_CD;
        v_acct_cd := acct_rec.BSNS_ENT_CD;
        v_acct_id := acct_rec.BSNS_ENT_ID;
        v_sys_id := acct_rec.SRC_SYS_IDNT;
        v_sys_dt := acct_rec.SRC_SYS_DT;
    END LOOP;

    -- Last record in cursor is also a lowest level account and ened to be exported
    IF v_counter > 0
    THEN
        v_hchy_cols := v_hchy_id || ',' || '''' || v_hchy_cd || '''' || ',';
        v_acct_cols := v_acct_id || ',' || '''' || v_acct_cd || '''' || ',' || v_curr_level || ',';
        FOR p in 1..p_max_level-1
        LOOP
            IF (p <= v_counter)  -- note the difference here on counter from with above
            THEN
                v_prnt_cols := v_prnt_cols || '''' || v_elems(p) || '''' || ',' || v_elems_id(p) || ',';
            ELSE
                v_prnt_cols := v_prnt_cols || '''' || v_acct_cd || '''' || ',' || v_acct_id || ',';  -- padding
            END IF;
        END LOOP;

        v_sys_cols := '''' || v_sys_id || '''' || ',' || 'TO_DATE(' || '''' || v_sys_dt || '''' || '),' || 'SYSDATE' || ', -1,' || 'SYSDATE' || ',-1,' || '''' || USER || '''' || ',' || '''' || USER || '''' || ',-1';
        v_sql_stmt := v_sql_hdr1 || v_sql_hdr2 || v_sql_hdr3 || v_hchy_cols || v_acct_cols || v_prnt_cols || v_sys_cols || ')';
        --dbms_output.put_line(v_sql_stmt);
        EXECUTE IMMEDIATE v_sql_stmt;
    END IF;
    EXECUTE IMMEDIATE v_commit_stmt;

    EXCEPTION
        WHEN others THEN
            --dbms_output.put_line('Error detected in parse_pad_accounts: ' || SQLERRM);
            ROLLBACK;

    END parse_pad_accounts;

END ddr_ref_util_pkg;

/
