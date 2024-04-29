--------------------------------------------------------
--  DDL for Package Body PJI_RM_SUM_AVL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_RM_SUM_AVL" AS
  /* $Header: PJISR04B.pls 120.7 2006/05/03 17:15:08 appldev noship $ */

--Defining Global PL/SQL Table variables for bulk insert in PJI_RM_AGGR_AVL3
	g_exp_organization_id_in_tbl	N_TYPE_TAB;
	g_exp_org_id_in_tbl		N_TYPE_TAB;
	g_period_type_id_in_tbl		N_TYPE_TAB;
	g_time_id_in_tbl		N_TYPE_TAB;
	g_person_id_in_tbl		N_TYPE_TAB;
	g_calendar_type_in_tbl		V_TYPE_TAB;
	g_threshold_in_tbl		N_TYPE_TAB;
	g_as_of_date_in_tbl		N_TYPE_TAB;
	g_bckt_1_cs_in_tbl		N_TYPE_TAB;
	g_bckt_2_cs_in_tbl		N_TYPE_TAB;
	g_bckt_3_cs_in_tbl		N_TYPE_TAB;
	g_bckt_4_cs_in_tbl		N_TYPE_TAB;
	g_bckt_5_cs_in_tbl		N_TYPE_TAB;
	g_bckt_1_cm_in_tbl		N_TYPE_TAB;
	g_bckt_2_cm_in_tbl		N_TYPE_TAB;
	g_bckt_3_cm_in_tbl		N_TYPE_TAB;
	g_bckt_4_cm_in_tbl		N_TYPE_TAB;
	g_bckt_5_cm_in_tbl		N_TYPE_TAB;
	g_total_res_cnt_in_tbl		N_TYPE_TAB;

--Defining Global PL/SQL Table variables for bulk insert in PJI_RM_AGGR_AVL4
	gw_exp_organization_id_in_tbl	N_TYPE_TAB;
	gw_exp_org_id_in_tbl		N_TYPE_TAB;
	gw_period_type_id_in_tbl	N_TYPE_TAB;
	gw_time_id_in_tbl		N_TYPE_TAB;
	gw_person_id_in_tbl		N_TYPE_TAB;
	gw_calendar_type_in_tbl		V_TYPE_TAB;
	gw_threshold_in_tbl		N_TYPE_TAB;
	gw_as_of_date_in_tbl		N_TYPE_TAB;
	gw_availability_in_tbl		N_TYPE_TAB;
	gw_total_res_cnt_in_tbl		N_TYPE_TAB;

--Defining Global variables for storing buckets

	g_avl_res_cnt_1	PJI_RM_AGGR_AVL2.avl_res_count_bkt1%TYPE;
	g_avl_res_cnt_2	PJI_RM_AGGR_AVL2.avl_res_count_bkt2%TYPE;
	g_avl_res_cnt_3	PJI_RM_AGGR_AVL2.avl_res_count_bkt3%TYPE;
	g_avl_res_cnt_4	PJI_RM_AGGR_AVL2.avl_res_count_bkt4%TYPE;
	g_avl_res_cnt_5	PJI_RM_AGGR_AVL2.avl_res_count_bkt5%TYPE;

--Package level global Variables to store the resource
--availability buckets values
	g_bucket_1_min	NUMBER(15);
	g_bucket_2_min	NUMBER(15);
	g_bucket_3_min	NUMBER(15);
	g_bucket_4_min	NUMBER(15);
	g_bucket_5_min	NUMBER(15);
	g_bucket_1_max	NUMBER(15);
	g_bucket_2_max	NUMBER(15);
	g_bucket_3_max	NUMBER(15);
	g_bucket_4_max	NUMBER(15);
	g_bucket_5_max	NUMBER(15);

--Defining global variable for storing threshold value
	g_no_of_user_def_threshold  	NUMBER(15);

--Defning global variable for storing minimum week day
	g_min_wk_j_st_date	NUMBER(15);

--Defning global variable for storing number of user
--defined rolling weeks
	g_no_of_roll_week	NUMBER(15);

	g_curr_res_left_count NUMBER := 0;

PROCEDURE INIT_PCKG_GLOBAL_VARS
IS
l_min_bucket_tbl    	N_TYPE_TAB;
l_max_bucket_tbl  	N_TYPE_TAB;
BEGIN
	--Get all the user defined bucket values
	SELECT  pmb.from_value,
		pmb.to_value
	BULK COLLECT INTO
		l_min_bucket_tbl,
		l_max_bucket_tbl
	FROM pji_mt_buckets pmb
	WHERE pmb.bucket_set_code = 'PJI_RES_AVL_DAYS'
	ORDER BY pmb.seq;

	g_bucket_1_min := l_min_bucket_tbl(1);
	g_bucket_2_min := l_min_bucket_tbl(2);
	g_bucket_3_min := l_min_bucket_tbl(3);
	g_bucket_4_min := l_min_bucket_tbl(4);
	g_bucket_5_min := l_min_bucket_tbl(5);

	g_bucket_1_max := l_max_bucket_tbl(1);
	g_bucket_2_max := l_max_bucket_tbl(2);
	g_bucket_3_max := l_max_bucket_tbl(3);
	g_bucket_4_max := l_max_bucket_tbl(4);
	g_bucket_5_max := power(2,49);

	--Get the number of thresholds being used in the system set up
	SELECT count(*)
	INTO g_no_of_user_def_threshold
	FROM PJI_MT_BUCKETS
	WHERE BUCKET_SET_CODE = 'PJI_RESOURCE_AVAILABILITY';

	--Get the minimum of julian start day from fii_time_day
	SELECT MIN(to_char(fiik.start_date,'j'))
	INTO g_min_wk_j_st_date
	FROM fii_time_week fiik;

	--Get the number of rolling weeks being used in the system set up
	SELECT rolling_weeks
	INTO g_no_of_roll_week
	FROM PJI_SYSTEM_SETTINGS;

END INIT_PCKG_GLOBAL_VARS;

PROCEDURE POP_ROLL_WEEK_OFFSET
IS
l_roll_week_offset_cnt NUMBER(15) := 0;
l_no_of_roll_week	NUMBER := 0;
BEGIN
	--Check if the table is already populated or not
	SELECT count(*)
	INTO l_roll_week_offset_cnt
	FROM PJI_ROLL_WEEK_OFFSET;

	-- If already populated then return
	IF (l_roll_week_offset_cnt <> 0 )THEN
		RETURN;
	END IF;

	--Otherwise populate the table

	--Get the number of rolling weeks being used in the system set up
	SELECT rolling_weeks
	INTO l_no_of_roll_week
	FROM PJI_SYSTEM_SETTINGS;

	FOR i in 1.. l_no_of_roll_week-1
	LOOP
		INSERT INTO PJI_ROLL_WEEK_OFFSET
		(
		  GLOBAL_SEQUENCE_ID,
		  OFFSET
		)
		VALUES
		(
		 i,
		 -(l_no_of_roll_week - i)
		);
	END LOOP;
	INSERT INTO PJI_ROLL_WEEK_OFFSET
	(
	  GLOBAL_SEQUENCE_ID,
	  OFFSET
	)
	VALUES
	(
	 l_no_of_roll_week,
	 0
	);
	FOR j in 1.. l_no_of_roll_week-1
	LOOP
		INSERT INTO PJI_ROLL_WEEK_OFFSET
		(
		  GLOBAL_SEQUENCE_ID,
		  OFFSET
		)
		VALUES
		(
		 l_no_of_roll_week + j,
		 j
		);
	END LOOP;

	-- implicit commit
	FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
	                             tabname => 'PJI_ROLL_WEEK_OFFSET',
	                             percent => 100,
	                             degree  => 1);

	COMMIT;

END POP_ROLL_WEEK_OFFSET;

PROCEDURE CALCULATE_BUCKET_VALUE
(
	 p_res_cnt     		IN         NUMBER
	,x_bckt_1 		OUT NOCOPY NUMBER
        ,x_bckt_2 		OUT NOCOPY NUMBER
        ,x_bckt_3 		OUT NOCOPY NUMBER
	,x_bckt_4 		OUT NOCOPY NUMBER
        ,x_bckt_5 		OUT NOCOPY NUMBER
)
IS
BEGIN

--Processing for FIRST bucket
IF (p_res_cnt >= g_bucket_1_min
	AND p_res_cnt <= g_bucket_1_max) THEN
		-- This resource contributes to this bucket NOW
		-- So change is 1
		x_bckt_1 := 1;
ELSE
		x_bckt_1 := 0;
END IF;

--Processing for SECOND bucket
IF (p_res_cnt >= g_bucket_2_min
	AND p_res_cnt <= g_bucket_2_max) THEN
		-- This resource contributes to this bucket NOW
		-- So change is 1
		x_bckt_2 := 1;
ELSE
		x_bckt_2 := 0;
END IF;

--Processing for THIRD bucket
IF (p_res_cnt >= g_bucket_3_min
	AND p_res_cnt <= g_bucket_3_max) THEN
		-- This resource contributes to this bucket NOW
		-- So change is 1
		x_bckt_3 := 1;
ELSE
		x_bckt_3 := 0;
END IF;

--Processing for FOURTH bucket
IF (p_res_cnt >= g_bucket_4_min
	AND p_res_cnt <= g_bucket_4_max) THEN
		-- This resource contributes to this bucket NOW
		-- So change is 1
		x_bckt_4 := 1;
ELSE
		x_bckt_4 := 0;
END IF;

--Processing for FIFTH bucket
IF (p_res_cnt >= g_bucket_5_min
	AND p_res_cnt <= g_bucket_5_max) THEN
		-- This resource contributes to this bucket NOW
		-- So change is 1
		x_bckt_5 := 1;
ELSE
		x_bckt_5 := 0;
END IF;

END CALCULATE_BUCKET_VALUE;

PROCEDURE CALC_CS_RES_CNT_VALUE
(
	p_res_cnt_tbl	IN OUT NOCOPY N_TYPE_TAB
)
IS
BEGIN
IF (g_avl_res_cnt_1 = 0) THEN
	p_res_cnt_tbl(11) := GREATEST (p_res_cnt_tbl(6), NVL(p_res_cnt_tbl(11),0));

	--Since availability is 0 on current day
	--therefore,setting the consecutive count to 0
	p_res_cnt_tbl(6) := 0;
END IF;

IF (g_avl_res_cnt_2 = 0) THEN
	p_res_cnt_tbl(12) := GREATEST (p_res_cnt_tbl(7), NVL(p_res_cnt_tbl(12),0));

	--Since availability is 0 on current day
	--therefore,setting the consecutive count to 0
	p_res_cnt_tbl(7) := 0;
END IF;

IF (g_avl_res_cnt_3 = 0) THEN
	p_res_cnt_tbl(13) := GREATEST (p_res_cnt_tbl(8), NVL(p_res_cnt_tbl(13),0));

	--Since availability is 0 on current day
	--therefore,setting the consecutive count to 0
	p_res_cnt_tbl(8) := 0;
END IF;

IF (g_avl_res_cnt_4 = 0) THEN
	p_res_cnt_tbl(14) := GREATEST (p_res_cnt_tbl(9), NVL(p_res_cnt_tbl(14),0));

	--Since availability is 0 on current day
	--therefore,setting the consecutive count to 0
	p_res_cnt_tbl(9) := 0;
END IF;

IF (g_avl_res_cnt_5 = 0) THEN
	p_res_cnt_tbl(15) := GREATEST (p_res_cnt_tbl(10), NVL(p_res_cnt_tbl(15),0));

	--Since availability is 0 on current day
	--therefore,setting the consecutive count to 0
	p_res_cnt_tbl(10) := 0;
END IF;

END CALC_CS_RES_CNT_VALUE;

PROCEDURE DEL_GLOBAL_RS_AVL3_TBL
IS
BEGIN
	g_exp_organization_id_in_tbl.DELETE;
	g_exp_org_id_in_tbl.DELETE;
	g_period_type_id_in_tbl.DELETE;
	g_time_id_in_tbl.DELETE;
	g_person_id_in_tbl.DELETE;
	g_calendar_type_in_tbl.DELETE;
	g_threshold_in_tbl.DELETE;
	g_as_of_date_in_tbl.DELETE;
	g_bckt_1_cs_in_tbl.DELETE;
	g_bckt_2_cs_in_tbl.DELETE;
	g_bckt_3_cs_in_tbl.DELETE;
	g_bckt_4_cs_in_tbl.DELETE;
	g_bckt_5_cs_in_tbl.DELETE;
	g_bckt_1_cm_in_tbl.DELETE;
	g_bckt_2_cm_in_tbl.DELETE;
	g_bckt_3_cm_in_tbl.DELETE;
	g_bckt_4_cm_in_tbl.DELETE;
	g_bckt_5_cm_in_tbl.DELETE;
	g_total_res_cnt_in_tbl.DELETE;

END DEL_GLOBAL_RS_AVL3_TBL;

PROCEDURE BULK_INSERT_RS_AVL3
(
	p_exp_organization_id_in_tbl	IN N_TYPE_TAB,
	p_exp_org_id_in_tbl		IN N_TYPE_TAB,
	p_period_type_id_in_tbl		IN N_TYPE_TAB,
	p_time_id_in_tbl		IN N_TYPE_TAB,
	p_person_id_in_tbl		IN N_TYPE_TAB,
	p_calendar_type_in_tbl		IN V_TYPE_TAB,
	p_threshold_in_tbl		IN N_TYPE_TAB,
	p_as_of_date_in_tbl		IN N_TYPE_TAB,
	p_bckt_1_cs_in_tbl		IN N_TYPE_TAB,
	p_bckt_2_cs_in_tbl		IN N_TYPE_TAB,
	p_bckt_3_cs_in_tbl		IN N_TYPE_TAB,
	p_bckt_4_cs_in_tbl		IN N_TYPE_TAB,
	p_bckt_5_cs_in_tbl		IN N_TYPE_TAB,
	p_bckt_1_cm_in_tbl		IN N_TYPE_TAB,
	p_bckt_2_cm_in_tbl		IN N_TYPE_TAB,
	p_bckt_3_cm_in_tbl		IN N_TYPE_TAB,
	p_bckt_4_cm_in_tbl		IN N_TYPE_TAB,
	p_bckt_5_cm_in_tbl		IN N_TYPE_TAB,
	p_total_res_cnt_in_tbl		IN N_TYPE_TAB,
	p_run_mode			IN VARCHAR2,
	p_blind_insert_flag		IN VARCHAR2
)
IS

--Defining local variables
	l_curr_count	NUMBER := 0;
	l_max_count	NUMBER := 200;
BEGIN
	IF (p_blind_insert_flag = 'Y') THEN
		IF (p_run_mode = 'OLD_FACT_RECORDS') THEN
			FORALL k IN 1.. g_exp_organization_id_in_tbl.count
			INSERT INTO PJI_RM_AGGR_AVL3
			(
				EXPENDITURE_ORGANIZATION_ID,
				EXPENDITURE_ORG_ID,
				PERIOD_TYPE_ID,
				TIME_ID ,
				PERSON_ID,
				CALENDAR_TYPE,
				THRESHOLD,
				AS_OF_DATE,
				BCKT_1_CS,
				BCKT_2_CS,
				BCKT_3_CS,
				BCKT_4_CS,
				BCKT_5_CS,
				BCKT_1_CM,
				BCKT_2_CM,
				BCKT_3_CM,
				BCKT_4_CM,
				BCKT_5_CM,
				TOTAL_RES_COUNT
			)
			VALUES
			(
				g_exp_organization_id_in_tbl(k),
				g_exp_org_id_in_tbl(k),
				g_period_type_id_in_tbl(k),
				g_time_id_in_tbl(k),
				g_person_id_in_tbl(k),
				g_calendar_type_in_tbl(k),
				g_threshold_in_tbl(k),
				g_as_of_date_in_tbl(k),
				-g_bckt_1_cs_in_tbl(k),
				-g_bckt_2_cs_in_tbl(k),
				-g_bckt_3_cs_in_tbl(k),
				-g_bckt_4_cs_in_tbl(k),
				-g_bckt_5_cs_in_tbl(k),
				-g_bckt_1_cm_in_tbl(k),
				-g_bckt_2_cm_in_tbl(k),
				-g_bckt_3_cm_in_tbl(k),
				-g_bckt_4_cm_in_tbl(k),
				-g_bckt_5_cm_in_tbl(k),
				-g_total_res_cnt_in_tbl(k)
			);
		ELSE
			FORALL k IN 1.. g_exp_organization_id_in_tbl.count
			INSERT INTO PJI_RM_AGGR_AVL3
			(
				EXPENDITURE_ORGANIZATION_ID,
				EXPENDITURE_ORG_ID,
				PERIOD_TYPE_ID,
				TIME_ID ,
				PERSON_ID,
				CALENDAR_TYPE,
				THRESHOLD,
				AS_OF_DATE,
				BCKT_1_CS,
				BCKT_2_CS,
				BCKT_3_CS,
				BCKT_4_CS,
				BCKT_5_CS,
				BCKT_1_CM,
				BCKT_2_CM,
				BCKT_3_CM,
				BCKT_4_CM,
				BCKT_5_CM,
				TOTAL_RES_COUNT
			)
			VALUES
			(
				g_exp_organization_id_in_tbl(k),
				g_exp_org_id_in_tbl(k),
				g_period_type_id_in_tbl(k),
				g_time_id_in_tbl(k),
				g_person_id_in_tbl(k),
				g_calendar_type_in_tbl(k),
				g_threshold_in_tbl(k),
				g_as_of_date_in_tbl(k),
				g_bckt_1_cs_in_tbl(k),
				g_bckt_2_cs_in_tbl(k),
				g_bckt_3_cs_in_tbl(k),
				g_bckt_4_cs_in_tbl(k),
				g_bckt_5_cs_in_tbl(k),
				g_bckt_1_cm_in_tbl(k),
				g_bckt_2_cm_in_tbl(k),
				g_bckt_3_cm_in_tbl(k),
				g_bckt_4_cm_in_tbl(k),
				g_bckt_5_cm_in_tbl(k),
				g_total_res_cnt_in_tbl(k)
			);
		END IF;

		DEL_GLOBAL_RS_AVL3_TBL;

		RETURN;

	END IF;

	FOR i in p_exp_organization_id_in_tbl.FIRST.. p_exp_organization_id_in_tbl.LAST
	LOOP
		--Assigning passed PL/SQL table values to local PL/SQL Tables
		--Before that get the last count of the local table
		l_curr_count	:= g_exp_organization_id_in_tbl.COUNT;

		g_exp_organization_id_in_tbl(l_curr_count + 1) 	:= p_exp_organization_id_in_tbl(i);
		g_exp_org_id_in_tbl(l_curr_count + 1) 		:= p_exp_org_id_in_tbl(i);
		g_period_type_id_in_tbl(l_curr_count + 1) 	:= p_period_type_id_in_tbl(i);
		g_time_id_in_tbl(l_curr_count + 1) 		:= p_time_id_in_tbl(i);
		g_person_id_in_tbl(l_curr_count + 1) 		:= p_person_id_in_tbl(i);
		g_calendar_type_in_tbl(l_curr_count + 1) 	:= p_calendar_type_in_tbl(i);
		g_threshold_in_tbl(l_curr_count + 1) 		:= p_threshold_in_tbl(i);
		g_as_of_date_in_tbl(l_curr_count + 1) 		:= p_as_of_date_in_tbl(i);
		g_bckt_1_cs_in_tbl(l_curr_count + 1) 		:= p_bckt_1_cs_in_tbl(i);
		g_bckt_2_cs_in_tbl(l_curr_count + 1) 		:= p_bckt_2_cs_in_tbl(i);
		g_bckt_3_cs_in_tbl(l_curr_count + 1) 		:= p_bckt_3_cs_in_tbl(i);
		g_bckt_4_cs_in_tbl(l_curr_count + 1) 		:= p_bckt_4_cs_in_tbl(i);
		g_bckt_5_cs_in_tbl(l_curr_count + 1) 		:= p_bckt_5_cs_in_tbl(i);
		g_bckt_1_cm_in_tbl(l_curr_count + 1) 		:= p_bckt_1_cm_in_tbl(i);
		g_bckt_2_cm_in_tbl(l_curr_count + 1) 		:= p_bckt_2_cm_in_tbl(i);
		g_bckt_3_cm_in_tbl(l_curr_count + 1) 		:= p_bckt_3_cm_in_tbl(i);
		g_bckt_4_cm_in_tbl(l_curr_count + 1) 		:= p_bckt_4_cm_in_tbl(i);
		g_bckt_5_cm_in_tbl(l_curr_count + 1) 		:= p_bckt_5_cm_in_tbl(i);
		g_total_res_cnt_in_tbl(l_curr_count + 1)	:= p_total_res_cnt_in_tbl(i);
	END LOOP;

	IF (g_exp_organization_id_in_tbl.COUNT >= l_max_count) THEN
		IF (p_run_mode = 'OLD_FACT_RECORDS') THEN
			FORALL k IN 1.. g_exp_organization_id_in_tbl.count
			INSERT INTO PJI_RM_AGGR_AVL3
			(
				EXPENDITURE_ORGANIZATION_ID,
				EXPENDITURE_ORG_ID,
				PERIOD_TYPE_ID,
				TIME_ID ,
				PERSON_ID,
				CALENDAR_TYPE,
				THRESHOLD,
				AS_OF_DATE,
				BCKT_1_CS,
				BCKT_2_CS,
				BCKT_3_CS,
				BCKT_4_CS,
				BCKT_5_CS,
				BCKT_1_CM,
				BCKT_2_CM,
				BCKT_3_CM,
				BCKT_4_CM,
				BCKT_5_CM,
				TOTAL_RES_COUNT
			)
			VALUES
			(
				g_exp_organization_id_in_tbl(k),
				g_exp_org_id_in_tbl(k),
				g_period_type_id_in_tbl(k),
				g_time_id_in_tbl(k),
				g_person_id_in_tbl(k),
				g_calendar_type_in_tbl(k),
				g_threshold_in_tbl(k),
				g_as_of_date_in_tbl(k),
				-g_bckt_1_cs_in_tbl(k),
				-g_bckt_2_cs_in_tbl(k),
				-g_bckt_3_cs_in_tbl(k),
				-g_bckt_4_cs_in_tbl(k),
				-g_bckt_5_cs_in_tbl(k),
				-g_bckt_1_cm_in_tbl(k),
				-g_bckt_2_cm_in_tbl(k),
				-g_bckt_3_cm_in_tbl(k),
				-g_bckt_4_cm_in_tbl(k),
				-g_bckt_5_cm_in_tbl(k),
				-g_total_res_cnt_in_tbl(k)
			);
		ELSE
			FORALL k IN 1.. g_exp_organization_id_in_tbl.count
			INSERT INTO PJI_RM_AGGR_AVL3
			(
				EXPENDITURE_ORGANIZATION_ID,
				EXPENDITURE_ORG_ID,
				PERIOD_TYPE_ID,
				TIME_ID ,
				PERSON_ID,
				CALENDAR_TYPE,
				THRESHOLD,
				AS_OF_DATE,
				BCKT_1_CS,
				BCKT_2_CS,
				BCKT_3_CS,
				BCKT_4_CS,
				BCKT_5_CS,
				BCKT_1_CM,
				BCKT_2_CM,
				BCKT_3_CM,
				BCKT_4_CM,
				BCKT_5_CM,
				TOTAL_RES_COUNT
			)
			VALUES
			(
				g_exp_organization_id_in_tbl(k),
				g_exp_org_id_in_tbl(k),
				g_period_type_id_in_tbl(k),
				g_time_id_in_tbl(k),
				g_person_id_in_tbl(k),
				g_calendar_type_in_tbl(k),
				g_threshold_in_tbl(k),
				g_as_of_date_in_tbl(k),
				g_bckt_1_cs_in_tbl(k),
				g_bckt_2_cs_in_tbl(k),
				g_bckt_3_cs_in_tbl(k),
				g_bckt_4_cs_in_tbl(k),
				g_bckt_5_cs_in_tbl(k),
				g_bckt_1_cm_in_tbl(k),
				g_bckt_2_cm_in_tbl(k),
				g_bckt_3_cm_in_tbl(k),
				g_bckt_4_cm_in_tbl(k),
				g_bckt_5_cm_in_tbl(k),
				g_total_res_cnt_in_tbl(k)
			);
		END IF;

		DEL_GLOBAL_RS_AVL3_TBL;
	END IF;

END BULK_INSERT_RS_AVL3;

PROCEDURE PREPARE_TO_INS_INTO_AVL3
(
	p_exp_organization_id	IN PJI_RM_AGGR_AVL2.expenditure_organization_id%TYPE,
	p_exp_org_id		IN PJI_RM_AGGR_AVL2.expenditure_org_id%TYPE,
	p_person_id		IN PJI_RM_AGGR_AVL2.person_id%TYPE,
      	p_time_id		IN PJI_RM_AGGR_AVL2.time_id%TYPE,
      	p_curr_pd		IN NUMBER,
      	p_as_of_date		IN NUMBER,
      	p_pd_org_st_date	IN NUMBER,
	p_period_type_id	IN NUMBER,
	p_calendar_type		IN VARCHAR2,
	p_res_cnt_tbl		IN N_TYPE_TAB,
	p_run_mode		IN VARCHAR2,
	p_blind_insert_flag	IN VARCHAR2,
	x_zero_bkt_cnt_flag	OUT NOCOPY VARCHAR2
)
IS

--Defining PL/SQL Table variables for bulk insert in PJI_RM_AGGR_AVL3
	l_worker_id_in_tbl		N_TYPE_TAB;
	l_exp_organization_id_in_tbl	N_TYPE_TAB;
	l_exp_org_id_in_tbl		N_TYPE_TAB;
	l_period_type_id_in_tbl		N_TYPE_TAB;
	l_time_id_in_tbl		N_TYPE_TAB;
	l_person_id_in_tbl		N_TYPE_TAB;
	l_calendar_type_in_tbl		V_TYPE_TAB;
	l_threshold_in_tbl		N_TYPE_TAB;
	l_as_of_date_in_tbl		N_TYPE_TAB;
	l_pd_org_st_date_in_tbl		N_TYPE_TAB;
	l_bckt_1_cs_in_tbl		N_TYPE_TAB;
	l_bckt_2_cs_in_tbl		N_TYPE_TAB;
	l_bckt_3_cs_in_tbl		N_TYPE_TAB;
	l_bckt_4_cs_in_tbl		N_TYPE_TAB;
	l_bckt_5_cs_in_tbl		N_TYPE_TAB;
	l_bckt_1_cm_in_tbl		N_TYPE_TAB;
	l_bckt_2_cm_in_tbl		N_TYPE_TAB;
	l_bckt_3_cm_in_tbl		N_TYPE_TAB;
	l_bckt_4_cm_in_tbl		N_TYPE_TAB;
	l_bckt_5_cm_in_tbl		N_TYPE_TAB;
	l_total_res_cnt_in_tbl		N_TYPE_TAB;
--Variables for holding resource count values
	l_res_cnt_cs 	NUMBER := 0;
	l_res_cnt_cm 	NUMBER := 0;
BEGIN
x_zero_bkt_cnt_flag := 'Y';
IF (p_blind_insert_flag = 'Y') THEN
	BULK_INSERT_RS_AVL3
	(
		p_exp_organization_id_in_tbl	=> l_exp_organization_id_in_tbl,
		p_exp_org_id_in_tbl		=> l_exp_org_id_in_tbl,
		p_period_type_id_in_tbl		=> l_period_type_id_in_tbl,
		p_time_id_in_tbl		=> l_time_id_in_tbl,
		p_person_id_in_tbl		=> l_person_id_in_tbl,
		p_calendar_type_in_tbl		=> l_calendar_type_in_tbl,
		p_threshold_in_tbl		=> l_threshold_in_tbl,
		p_as_of_date_in_tbl		=> l_pd_org_st_date_in_tbl,
		p_bckt_1_cs_in_tbl		=> l_bckt_1_cs_in_tbl,
		p_bckt_2_cs_in_tbl		=> l_bckt_2_cs_in_tbl,
		p_bckt_3_cs_in_tbl		=> l_bckt_3_cs_in_tbl,
		p_bckt_4_cs_in_tbl		=> l_bckt_4_cs_in_tbl,
		p_bckt_5_cs_in_tbl		=> l_bckt_5_cs_in_tbl,
		p_bckt_1_cm_in_tbl		=> l_bckt_1_cm_in_tbl,
		p_bckt_2_cm_in_tbl		=> l_bckt_2_cm_in_tbl,
		p_bckt_3_cm_in_tbl		=> l_bckt_3_cm_in_tbl,
		p_bckt_4_cm_in_tbl		=> l_bckt_4_cm_in_tbl,
		p_bckt_5_cm_in_tbl		=> l_bckt_5_cm_in_tbl,
		p_total_res_cnt_in_tbl		=> l_total_res_cnt_in_tbl,
		p_run_mode			=> p_run_mode,
		p_blind_insert_flag		=> p_blind_insert_flag
	);
ELSE
	--Push this record in a PL/SQL table and will
	--BULK INSERT at the end of processing
	FOR j in 1.. g_no_of_user_def_threshold
	LOOP
		--DBMS_OUTPUT.PUT_LINE('3');
		l_exp_organization_id_in_tbl(j) :=p_exp_organization_id;
		l_exp_org_id_in_tbl(j)		:=p_exp_org_id;
		l_period_type_id_in_tbl(j)	:=p_period_type_id;
		l_time_id_in_tbl(j)		:=p_time_id;
		l_person_id_in_tbl(j)		:=p_person_id;
		l_calendar_type_in_tbl(j)	:=p_calendar_type;
		l_threshold_in_tbl(j)		:=j;
		l_as_of_date_in_tbl(j)		:= p_as_of_date;
		l_pd_org_st_date_in_tbl(j)	:= p_pd_org_st_date;
		l_res_cnt_cs			:= p_res_cnt_tbl(j+10);
		l_res_cnt_cm			:= p_res_cnt_tbl(j);
		l_total_res_cnt_in_tbl(j)	:= 1;

		--Populate PL/SQL Table values for consecutive counts
		CALCULATE_BUCKET_VALUE
		(
			 p_res_cnt     	=> l_res_cnt_cs
			,x_bckt_1 	=> l_bckt_1_cs_in_tbl(j)
			,x_bckt_2 	=> l_bckt_2_cs_in_tbl(j)
			,x_bckt_3 	=> l_bckt_3_cs_in_tbl(j)
			,x_bckt_4 	=> l_bckt_4_cs_in_tbl(j)
		        ,x_bckt_5 	=> l_bckt_5_cs_in_tbl(j)
		);

		--Populate PL/SQL Table values for consecutive counts
		CALCULATE_BUCKET_VALUE
		(
			 p_res_cnt     	=> l_res_cnt_cm
			,x_bckt_1 	=> l_bckt_1_cm_in_tbl(j)
			,x_bckt_2 	=> l_bckt_2_cm_in_tbl(j)
			,x_bckt_3 	=> l_bckt_3_cm_in_tbl(j)
			,x_bckt_4 	=> l_bckt_4_cm_in_tbl(j)
			,x_bckt_5 	=> l_bckt_5_cm_in_tbl(j)
		);

	END LOOP;

	FOR j in 1.. g_no_of_user_def_threshold
	LOOP
		IF (	l_bckt_1_cm_in_tbl(j) <> 0
			OR l_bckt_2_cm_in_tbl(j) <> 0
			OR l_bckt_3_cm_in_tbl(j) <> 0
			OR l_bckt_4_cm_in_tbl(j) <> 0
			OR l_bckt_5_cm_in_tbl(j) <> 0
			OR l_bckt_1_cm_in_tbl(j) <> 0
			OR l_bckt_2_cm_in_tbl(j) <> 0
			OR l_bckt_3_cm_in_tbl(j) <> 0
			OR l_bckt_4_cm_in_tbl(j) <> 0
			OR l_bckt_5_cm_in_tbl(j) <> 0
		   ) THEN
			x_zero_bkt_cnt_flag := 'N';
			EXIT;
		END IF;
	END LOOP;

	IF (x_zero_bkt_cnt_flag = 'N') THEN
	--Call the bulk insert to insert rows for this particular
	--period and person id for all thresholds

		BULK_INSERT_RS_AVL3
		(
			p_exp_organization_id_in_tbl	=> l_exp_organization_id_in_tbl,
			p_exp_org_id_in_tbl		=> l_exp_org_id_in_tbl,
			p_period_type_id_in_tbl		=> l_period_type_id_in_tbl,
			p_time_id_in_tbl		=> l_time_id_in_tbl,
			p_person_id_in_tbl		=> l_person_id_in_tbl,
			p_calendar_type_in_tbl		=> l_calendar_type_in_tbl,
			p_threshold_in_tbl		=> l_threshold_in_tbl,
			p_as_of_date_in_tbl		=> l_pd_org_st_date_in_tbl,
			p_bckt_1_cs_in_tbl		=> l_bckt_1_cs_in_tbl,
			p_bckt_2_cs_in_tbl		=> l_bckt_2_cs_in_tbl,
			p_bckt_3_cs_in_tbl		=> l_bckt_3_cs_in_tbl,
			p_bckt_4_cs_in_tbl		=> l_bckt_4_cs_in_tbl,
			p_bckt_5_cs_in_tbl		=> l_bckt_5_cs_in_tbl,
			p_bckt_1_cm_in_tbl		=> l_bckt_1_cm_in_tbl,
			p_bckt_2_cm_in_tbl		=> l_bckt_2_cm_in_tbl,
			p_bckt_3_cm_in_tbl		=> l_bckt_3_cm_in_tbl,
			p_bckt_4_cm_in_tbl		=> l_bckt_4_cm_in_tbl,
			p_bckt_5_cm_in_tbl		=> l_bckt_5_cm_in_tbl,
			p_total_res_cnt_in_tbl		=> l_total_res_cnt_in_tbl,
			p_run_mode			=> p_run_mode,
			p_blind_insert_flag		=> p_blind_insert_flag
		);

	--If the period has not changed then only org has changed
	--so post the reversal on as of date
		IF (p_time_id = p_curr_pd) THEN
		--Negate the bucket values for current date
			FOR j in 1.. g_no_of_user_def_threshold
			LOOP
				l_bckt_1_cs_in_tbl(j) := -l_bckt_1_cs_in_tbl(j);
				l_bckt_2_cs_in_tbl(j) := -l_bckt_2_cs_in_tbl(j);
				l_bckt_3_cs_in_tbl(j) := -l_bckt_3_cs_in_tbl(j);
				l_bckt_4_cs_in_tbl(j) := -l_bckt_4_cs_in_tbl(j);
				l_bckt_5_cs_in_tbl(j) := -l_bckt_5_cs_in_tbl(j);
				l_bckt_1_cm_in_tbl(j) := -l_bckt_1_cm_in_tbl(j);
				l_bckt_2_cm_in_tbl(j) := -l_bckt_2_cm_in_tbl(j);
				l_bckt_3_cm_in_tbl(j) := -l_bckt_3_cm_in_tbl(j);
				l_bckt_4_cm_in_tbl(j) := -l_bckt_4_cm_in_tbl(j);
				l_bckt_5_cm_in_tbl(j) := -l_bckt_5_cm_in_tbl(j);
				l_total_res_cnt_in_tbl(j) := -l_total_res_cnt_in_tbl(j);
			END LOOP;

			BULK_INSERT_RS_AVL3
			(
				p_exp_organization_id_in_tbl	=> l_exp_organization_id_in_tbl,
				p_exp_org_id_in_tbl		=> l_exp_org_id_in_tbl,
				p_period_type_id_in_tbl		=> l_period_type_id_in_tbl,
				p_time_id_in_tbl		=> l_time_id_in_tbl,
				p_person_id_in_tbl		=> l_person_id_in_tbl,
				p_calendar_type_in_tbl		=> l_calendar_type_in_tbl,
				p_threshold_in_tbl		=> l_threshold_in_tbl,
				p_as_of_date_in_tbl		=> l_as_of_date_in_tbl,
				p_bckt_1_cs_in_tbl		=> l_bckt_1_cs_in_tbl,
				p_bckt_2_cs_in_tbl		=> l_bckt_2_cs_in_tbl,
				p_bckt_3_cs_in_tbl		=> l_bckt_3_cs_in_tbl,
				p_bckt_4_cs_in_tbl		=> l_bckt_4_cs_in_tbl,
				p_bckt_5_cs_in_tbl		=> l_bckt_5_cs_in_tbl,
				p_bckt_1_cm_in_tbl		=> l_bckt_1_cm_in_tbl,
				p_bckt_2_cm_in_tbl		=> l_bckt_2_cm_in_tbl,
				p_bckt_3_cm_in_tbl		=> l_bckt_3_cm_in_tbl,
				p_bckt_4_cm_in_tbl		=> l_bckt_4_cm_in_tbl,
				p_bckt_5_cm_in_tbl		=> l_bckt_5_cm_in_tbl,
				p_total_res_cnt_in_tbl		=> l_total_res_cnt_in_tbl,
				p_run_mode			=> p_run_mode,
				p_blind_insert_flag		=> p_blind_insert_flag
			);
		END IF;
	ELSIF (x_zero_bkt_cnt_flag = 'Y') THEN
		--If the PERIOD HAS CHANGED AND the counts are
		--zero, we still need to POST the values
		--for total resources.
		IF (p_time_id <> p_curr_pd) THEN
			--the bucket values are zero

				BULK_INSERT_RS_AVL3
				(
					p_exp_organization_id_in_tbl	=> l_exp_organization_id_in_tbl,
					p_exp_org_id_in_tbl		=> l_exp_org_id_in_tbl,
					p_period_type_id_in_tbl		=> l_period_type_id_in_tbl,
					p_time_id_in_tbl		=> l_time_id_in_tbl,
					p_person_id_in_tbl		=> l_person_id_in_tbl,
					p_calendar_type_in_tbl		=> l_calendar_type_in_tbl,
					p_threshold_in_tbl		=> l_threshold_in_tbl,
					p_as_of_date_in_tbl		=> l_pd_org_st_date_in_tbl,
					p_bckt_1_cs_in_tbl		=> l_bckt_1_cs_in_tbl,
					p_bckt_2_cs_in_tbl		=> l_bckt_2_cs_in_tbl,
					p_bckt_3_cs_in_tbl		=> l_bckt_3_cs_in_tbl,
					p_bckt_4_cs_in_tbl		=> l_bckt_4_cs_in_tbl,
					p_bckt_5_cs_in_tbl		=> l_bckt_5_cs_in_tbl,
					p_bckt_1_cm_in_tbl		=> l_bckt_1_cm_in_tbl,
					p_bckt_2_cm_in_tbl		=> l_bckt_2_cm_in_tbl,
					p_bckt_3_cm_in_tbl		=> l_bckt_3_cm_in_tbl,
					p_bckt_4_cm_in_tbl		=> l_bckt_4_cm_in_tbl,
					p_bckt_5_cm_in_tbl		=> l_bckt_5_cm_in_tbl,
					p_total_res_cnt_in_tbl		=> l_total_res_cnt_in_tbl,
					p_run_mode			=> p_run_mode,
					p_blind_insert_flag		=> p_blind_insert_flag
				);
		END IF;

	END IF;
END IF;
END PREPARE_TO_INS_INTO_AVL3;

PROCEDURE DEL_GLOBAL_RS_AVL4_TBL
IS
BEGIN
	gw_exp_organization_id_in_tbl.DELETE;
	gw_exp_org_id_in_tbl.DELETE;
	gw_period_type_id_in_tbl.DELETE;
	gw_time_id_in_tbl.DELETE;
	gw_person_id_in_tbl.DELETE;
	gw_calendar_type_in_tbl.DELETE;
	gw_threshold_in_tbl.DELETE;
	gw_availability_in_tbl.DELETE;
	gw_total_res_cnt_in_tbl.DELETE;

END DEL_GLOBAL_RS_AVL4_TBL;

PROCEDURE BULK_INSERT_RS_AVL4
(
	p_exp_organization_id_in_tbl	IN N_TYPE_TAB,
	p_exp_org_id_in_tbl		IN N_TYPE_TAB,
	p_period_type_id_in_tbl		IN N_TYPE_TAB,
	p_time_id_in_tbl		IN N_TYPE_TAB,
	p_person_id_in_tbl		IN N_TYPE_TAB,
	p_calendar_type_in_tbl		IN V_TYPE_TAB,
	p_threshold_in_tbl		IN N_TYPE_TAB,
	p_as_of_date_in_tbl		IN N_TYPE_TAB,
	p_availability_in_tbl		IN N_TYPE_TAB,
	p_total_res_cnt_in_tbl		IN N_TYPE_TAB,
	p_run_mode			IN VARCHAR2,
	p_blind_insert_flag		IN VARCHAR2
)
IS

--Defining local variables
	l_curr_count	NUMBER := 0;
	l_max_count	NUMBER := 200;
BEGIN
	IF (p_blind_insert_flag = 'Y') THEN
		IF (p_run_mode = 'OLD_FACT_RECORDS') THEN
			FORALL k IN 1.. gw_exp_organization_id_in_tbl.count
			INSERT INTO PJI_RM_AGGR_AVL4
			(
				EXPENDITURE_ORGANIZATION_ID,
				EXPENDITURE_ORG_ID,
				PERIOD_TYPE_ID,
				TIME_ID ,
				PERSON_ID,
				CALENDAR_TYPE,
				THRESHOLD,
				AS_OF_DATE,
				AVAILABILITY,
				TOTAL_RES_COUNT
			)
			VALUES
			(
				gw_exp_organization_id_in_tbl(k),
				gw_exp_org_id_in_tbl(k),
				gw_period_type_id_in_tbl(k),
				gw_time_id_in_tbl(k),
				gw_person_id_in_tbl(k),
				gw_calendar_type_in_tbl(k),
				gw_threshold_in_tbl(k),
				gw_as_of_date_in_tbl(k),
				-gw_availability_in_tbl(k),
				-gw_total_res_cnt_in_tbl(k)
			);
		ELSE
			FORALL k IN 1.. gw_exp_organization_id_in_tbl.count
			INSERT INTO PJI_RM_AGGR_AVL4
			(
				EXPENDITURE_ORGANIZATION_ID,
				EXPENDITURE_ORG_ID,
				PERIOD_TYPE_ID,
				TIME_ID ,
				PERSON_ID,
				CALENDAR_TYPE,
				THRESHOLD,
				AS_OF_DATE,
				AVAILABILITY,
				TOTAL_RES_COUNT
			)
			VALUES
			(
				gw_exp_organization_id_in_tbl(k),
				gw_exp_org_id_in_tbl(k),
				gw_period_type_id_in_tbl(k),
				gw_time_id_in_tbl(k),
				gw_person_id_in_tbl(k),
				gw_calendar_type_in_tbl(k),
				gw_threshold_in_tbl(k),
				gw_as_of_date_in_tbl(k),
				gw_availability_in_tbl(k),
				gw_total_res_cnt_in_tbl(k)
			);
		END IF;

		DEL_GLOBAL_RS_AVL4_TBL;

		RETURN;

	END IF;

	FOR i in p_exp_organization_id_in_tbl.FIRST.. p_exp_organization_id_in_tbl.LAST
	LOOP
		--Assigning passed PL/SQL table values to local PL/SQL Tables
		--Before that get the last count of the local table
		l_curr_count	:= gw_exp_organization_id_in_tbl.COUNT;

		gw_exp_organization_id_in_tbl(l_curr_count + 1) := p_exp_organization_id_in_tbl(i);
		gw_exp_org_id_in_tbl(l_curr_count + 1) 		:= p_exp_org_id_in_tbl(i);
		gw_period_type_id_in_tbl(l_curr_count + 1) 	:= p_period_type_id_in_tbl(i);
		gw_time_id_in_tbl(l_curr_count + 1) 		:= p_time_id_in_tbl(i);
		gw_person_id_in_tbl(l_curr_count + 1) 		:= p_person_id_in_tbl(i);
		gw_calendar_type_in_tbl(l_curr_count + 1) 	:= p_calendar_type_in_tbl(i);
		gw_threshold_in_tbl(l_curr_count + 1) 		:= p_threshold_in_tbl(i);
		gw_as_of_date_in_tbl(l_curr_count + 1) 		:= p_as_of_date_in_tbl(i);
		gw_availability_in_tbl(l_curr_count + 1) 	:= p_availability_in_tbl(i);
		gw_total_res_cnt_in_tbl(l_curr_count + 1)	:= p_total_res_cnt_in_tbl(i);
	END LOOP;

	IF (gw_exp_organization_id_in_tbl.COUNT >= l_max_count) THEN
		IF (p_run_mode = 'OLD_FACT_RECORDS') THEN
			FORALL k IN 1.. gw_exp_organization_id_in_tbl.count
			INSERT INTO PJI_RM_AGGR_AVL4
			(
				EXPENDITURE_ORGANIZATION_ID,
				EXPENDITURE_ORG_ID,
				PERIOD_TYPE_ID,
				TIME_ID ,
				PERSON_ID,
				CALENDAR_TYPE,
				THRESHOLD,
				AS_OF_DATE,
				AVAILABILITY,
				TOTAL_RES_COUNT
			)
			VALUES
			(
				gw_exp_organization_id_in_tbl(k),
				gw_exp_org_id_in_tbl(k),
				gw_period_type_id_in_tbl(k),
				gw_time_id_in_tbl(k),
				gw_person_id_in_tbl(k),
				gw_calendar_type_in_tbl(k),
				gw_threshold_in_tbl(k),
				gw_as_of_date_in_tbl(k),
				-gw_availability_in_tbl(k),
				-gw_total_res_cnt_in_tbl(k)
			);
		ELSE
			FORALL k IN 1.. gw_exp_organization_id_in_tbl.count
			INSERT INTO PJI_RM_AGGR_AVL4
			(
				EXPENDITURE_ORGANIZATION_ID,
				EXPENDITURE_ORG_ID,
				PERIOD_TYPE_ID,
				TIME_ID ,
				PERSON_ID,
				CALENDAR_TYPE,
				THRESHOLD,
				AS_OF_DATE,
				AVAILABILITY,
				TOTAL_RES_COUNT
			)
			VALUES
			(
				gw_exp_organization_id_in_tbl(k),
				gw_exp_org_id_in_tbl(k),
				gw_period_type_id_in_tbl(k),
				gw_time_id_in_tbl(k),
				gw_person_id_in_tbl(k),
				gw_calendar_type_in_tbl(k),
				gw_threshold_in_tbl(k),
				gw_as_of_date_in_tbl(k),
				gw_availability_in_tbl(k),
				gw_total_res_cnt_in_tbl(k)
			);
		END IF;
		DEL_GLOBAL_RS_AVL4_TBL;
	END IF;

END BULK_INSERT_RS_AVL4;

PROCEDURE PREPARE_TO_INS_INTO_AVL4
(
	p_exp_organization_id	IN PJI_RM_AGGR_AVL2.expenditure_organization_id%TYPE,
	p_exp_org_id		IN PJI_RM_AGGR_AVL2.expenditure_org_id%TYPE,
	p_person_id		IN PJI_RM_AGGR_AVL2.person_id%TYPE,
      	p_time_id		IN PJI_RM_AGGR_AVL2.time_id%TYPE,
      	p_curr_pd		IN NUMBER,
	p_as_of_date		IN NUMBER,
      	p_pd_org_st_date	IN NUMBER,
	p_period_type_id	IN NUMBER,
	p_calendar_type		IN VARCHAR2,
	p_res_cnt_tbl		IN N_TYPE_TAB,
	p_run_mode		IN VARCHAR2,
	p_blind_insert_flag	IN VARCHAR2,
	x_zero_bkt_cnt_flag	OUT NOCOPY VARCHAR2
)
IS

--Defining PL/SQL Table variables for bulk insert in PJI_RM_AGGR_AVL4
	l_exp_organization_id_in_tbl	N_TYPE_TAB;
	l_exp_org_id_in_tbl		N_TYPE_TAB;
	l_period_type_id_in_tbl		N_TYPE_TAB;
	l_time_id_in_tbl		N_TYPE_TAB;
	l_person_id_in_tbl		N_TYPE_TAB;
	l_calendar_type_in_tbl		V_TYPE_TAB;
	l_threshold_in_tbl		N_TYPE_TAB;
	l_as_of_date_in_tbl		N_TYPE_TAB;
	l_pd_org_st_date_in_tbl		N_TYPE_TAB;
	l_availability_in_tbl		N_TYPE_TAB;
	l_total_res_cnt_in_tbl		N_TYPE_TAB;

--Variables for holding resource count values
	l_res_cnt 	NUMBER := 0;
BEGIN
x_zero_bkt_cnt_flag := 'Y';
IF (p_blind_insert_flag = 'Y') THEN
	BULK_INSERT_RS_AVL4
	(
		p_exp_organization_id_in_tbl	=> l_exp_organization_id_in_tbl,
		p_exp_org_id_in_tbl		=> l_exp_org_id_in_tbl,
		p_period_type_id_in_tbl		=> l_period_type_id_in_tbl,
		p_time_id_in_tbl		=> l_time_id_in_tbl,
		p_person_id_in_tbl		=> l_person_id_in_tbl,
		p_calendar_type_in_tbl		=> l_calendar_type_in_tbl,
		p_threshold_in_tbl		=> l_threshold_in_tbl,
		p_as_of_date_in_tbl		=> l_pd_org_st_date_in_tbl,
		p_availability_in_tbl		=> l_availability_in_tbl,
		p_total_res_cnt_in_tbl		=> l_total_res_cnt_in_tbl,
		p_run_mode			=> p_run_mode,
		p_blind_insert_flag		=> p_blind_insert_flag
	);
ELSE
	--Push this record in a PL/SQL table and will
	--BULK INSERT at the end of processing
	FOR j in 1.. g_no_of_user_def_threshold
	LOOP
		l_exp_organization_id_in_tbl(j) :=p_exp_organization_id;
		l_exp_org_id_in_tbl(j)		:=p_exp_org_id;
		l_period_type_id_in_tbl(j)	:=p_period_type_id;
		l_time_id_in_tbl(j)		:=p_time_id;
		l_person_id_in_tbl(j)		:=p_person_id;
		l_calendar_type_in_tbl(j)	:=p_calendar_type;
		l_threshold_in_tbl(j)		:=j;
		l_as_of_date_in_tbl(j)		:= p_as_of_date;
		l_pd_org_st_date_in_tbl(j)	:= p_pd_org_st_date;
		l_res_cnt			:= p_res_cnt_tbl(j);
		l_availability_in_tbl(j)	:= sign(l_res_cnt);
		l_total_res_cnt_in_tbl(j)	:= 1;
	END LOOP;

	FOR j in 1.. g_no_of_user_def_threshold
	LOOP
		IF (	l_availability_in_tbl(j) <> 0
		   ) THEN
			x_zero_bkt_cnt_flag := 'N';
			EXIT;
		END IF;
	END LOOP;
	IF (x_zero_bkt_cnt_flag = 'N') THEN
	--Call the bulk insert to insert rows for this particular
	--period and person id for all thresholds

		BULK_INSERT_RS_AVL4
		(
			p_exp_organization_id_in_tbl	=> l_exp_organization_id_in_tbl,
			p_exp_org_id_in_tbl		=> l_exp_org_id_in_tbl,
			p_period_type_id_in_tbl		=> l_period_type_id_in_tbl,
			p_time_id_in_tbl		=> l_time_id_in_tbl,
			p_person_id_in_tbl		=> l_person_id_in_tbl,
			p_calendar_type_in_tbl		=> l_calendar_type_in_tbl,
			p_threshold_in_tbl		=> l_threshold_in_tbl,
			p_as_of_date_in_tbl		=> l_pd_org_st_date_in_tbl,
			p_availability_in_tbl		=> l_availability_in_tbl,
			p_total_res_cnt_in_tbl		=> l_total_res_cnt_in_tbl,
			p_run_mode			=> p_run_mode,
			p_blind_insert_flag		=> p_blind_insert_flag
		);
	--If the period has not changed then only org has changed
	--so post the reversal on as of date
		IF (p_time_id = p_curr_pd) THEN
		--Negate the bucket values for current date
			FOR j in 1.. g_no_of_user_def_threshold
			LOOP
				l_availability_in_tbl(j) := -l_availability_in_tbl(j);
				l_total_res_cnt_in_tbl(j) := -l_total_res_cnt_in_tbl(j);
			END LOOP;

			BULK_INSERT_RS_AVL4
			(
				p_exp_organization_id_in_tbl	=> l_exp_organization_id_in_tbl,
				p_exp_org_id_in_tbl		=> l_exp_org_id_in_tbl,
				p_period_type_id_in_tbl		=> l_period_type_id_in_tbl,
				p_time_id_in_tbl		=> l_time_id_in_tbl,
				p_person_id_in_tbl		=> l_person_id_in_tbl,
				p_calendar_type_in_tbl		=> l_calendar_type_in_tbl,
				p_threshold_in_tbl		=> l_threshold_in_tbl,
				p_as_of_date_in_tbl		=> l_as_of_date_in_tbl,
				p_availability_in_tbl		=> l_availability_in_tbl,
				p_total_res_cnt_in_tbl		=> l_total_res_cnt_in_tbl,
				p_run_mode			=> p_run_mode,
				p_blind_insert_flag		=> p_blind_insert_flag
			);
		END IF;
	ELSIF (x_zero_bkt_cnt_flag = 'Y') THEN
		--If the PERIOD HAS CHANGED AND the counts are
		--zero, we still need to POST the values
		--for total resources.
		IF (p_time_id <> p_curr_pd) THEN
		--the bucket values are zero

			BULK_INSERT_RS_AVL4
			(
				p_exp_organization_id_in_tbl	=> l_exp_organization_id_in_tbl,
				p_exp_org_id_in_tbl		=> l_exp_org_id_in_tbl,
				p_period_type_id_in_tbl		=> l_period_type_id_in_tbl,
				p_time_id_in_tbl		=> l_time_id_in_tbl,
				p_person_id_in_tbl		=> l_person_id_in_tbl,
				p_calendar_type_in_tbl		=> l_calendar_type_in_tbl,
				p_threshold_in_tbl		=> l_threshold_in_tbl,
				p_as_of_date_in_tbl		=> l_pd_org_st_date_in_tbl,
				p_availability_in_tbl		=> l_availability_in_tbl,
				p_total_res_cnt_in_tbl		=> l_total_res_cnt_in_tbl,
				p_run_mode			=> p_run_mode,
				p_blind_insert_flag		=> p_blind_insert_flag
			);
		END IF;
	END IF;
END IF;

END PREPARE_TO_INS_INTO_AVL4;

PROCEDURE CALCULATE_RES_AVL
(
	p_worker_id		IN NUMBER,
	p_person_id		IN NUMBER,
	p_run_mode		IN VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2
)
IS
--Defining PL/SQL Table variables
	l_worker_id_tbl			N_TYPE_TAB;
	l_exp_organization_id_tbl	N_TYPE_TAB;
	l_exp_org_id_tbl		N_TYPE_TAB;
	l_person_id_tbl			N_TYPE_TAB;
	l_time_id_tbl			N_TYPE_TAB;
	l_week_id_tbl			N_TYPE_TAB;
	l_ent_period_id_tbl		N_TYPE_TAB;
	l_ent_qtr_id_tbl		N_TYPE_TAB;
	l_gl_period_id_tbl		N_TYPE_TAB;
	l_gl_qtr_id_tbl			N_TYPE_TAB;
	l_roll_x_week_1_tbl		N_TYPE_TAB;
	l_roll_x_week_2_tbl		N_TYPE_TAB;
	l_roll_x_week_3_tbl		N_TYPE_TAB;
	l_roll_x_week_4_tbl		N_TYPE_TAB;
	l_roll_x_week_5_tbl		N_TYPE_TAB;
	l_roll_x_week_6_tbl		N_TYPE_TAB;
	l_roll_x_week_7_tbl		N_TYPE_TAB;
	l_roll_x_week_8_tbl		N_TYPE_TAB;
	l_roll_x_week_9_tbl		N_TYPE_TAB;
	l_roll_x_week_10_tbl		N_TYPE_TAB;
	l_roll_x_week_11_tbl		N_TYPE_TAB;
	l_roll_x_week_12_tbl		N_TYPE_TAB;
	l_roll_x_week_13_tbl		N_TYPE_TAB;
	l_avl_res_cnt_1_tbl		N_TYPE_TAB;
	l_avl_res_cnt_2_tbl		N_TYPE_TAB;
	l_avl_res_cnt_3_tbl		N_TYPE_TAB;
	l_avl_res_cnt_4_tbl		N_TYPE_TAB;
	l_avl_res_cnt_5_tbl		N_TYPE_TAB;

--Defining Local variables for local use
      	l_worker_id		PJI_RM_AGGR_AVL2.worker_id%TYPE;
      	l_exp_organization_id	PJI_RM_AGGR_AVL2.expenditure_organization_id%TYPE;
      	l_exp_org_id		PJI_RM_AGGR_AVL2.expenditure_org_id%TYPE;
      	l_person_id		PJI_RM_AGGR_AVL2.person_id%TYPE;
      	l_time_id		PJI_RM_AGGR_AVL2.time_id%TYPE;
      	l_week_id		PJI_RM_AGGR_AVL2.week_id%TYPE;
      	l_ent_period_id		PJI_RM_AGGR_AVL2.ent_period%TYPE;
      	l_ent_qtr_id		PJI_RM_AGGR_AVL2.ent_qtr%TYPE;
      	l_gl_period_id		PJI_RM_AGGR_AVL2.gl_period%TYPE;
      	l_gl_qtr_id		PJI_RM_AGGR_AVL2.gl_qtr%TYPE;
      	l_roll_x_week1		PJI_RM_AGGR_AVL2.roll_x_week_1%TYPE;
      	l_roll_x_week2		PJI_RM_AGGR_AVL2.roll_x_week_2%TYPE;
      	l_roll_x_week3		PJI_RM_AGGR_AVL2.roll_x_week_3%TYPE;
      	l_roll_x_week4		PJI_RM_AGGR_AVL2.roll_x_week_4%TYPE;
      	l_roll_x_week5		PJI_RM_AGGR_AVL2.roll_x_week_5%TYPE;
      	l_roll_x_week6		PJI_RM_AGGR_AVL2.roll_x_week_6%TYPE;
      	l_roll_x_week7		PJI_RM_AGGR_AVL2.roll_x_week_7%TYPE;
      	l_roll_x_week8		PJI_RM_AGGR_AVL2.roll_x_week_8%TYPE;
      	l_roll_x_week9		PJI_RM_AGGR_AVL2.roll_x_week_9%TYPE;
      	l_roll_x_week10		PJI_RM_AGGR_AVL2.roll_x_week_10%TYPE;
      	l_roll_x_week11		PJI_RM_AGGR_AVL2.roll_x_week_11%TYPE;
      	l_roll_x_week12		PJI_RM_AGGR_AVL2.roll_x_week_12%TYPE;
      	l_roll_x_week13		PJI_RM_AGGR_AVL2.roll_x_week_13%TYPE;

--Defining PL/SQL Local variables for local use
--Need to store old value of the previous row
--when processing records row by row from
--PJI_RM_AGGR_AVL2 table
	l_old_worker_id			PJI_RM_AGGR_AVL2.worker_id%TYPE := -1;
	l_old_exp_orgnztion_id		PJI_RM_AGGR_AVL2.expenditure_organization_id%TYPE := -1;
	l_old_exp_org_id		PJI_RM_AGGR_AVL2.expenditure_org_id%TYPE := -1;
      	l_old_person_id			PJI_RM_AGGR_AVL2.person_id%TYPE := -1;
	l_old_week_id			PJI_RM_AGGR_AVL2.week_id%TYPE := -1;
      	l_old_ent_period_id		PJI_RM_AGGR_AVL2.ent_period%TYPE := -1;
	l_old_ent_qtr_id		PJI_RM_AGGR_AVL2.ent_qtr%TYPE := -1;
	l_old_gl_period_id		PJI_RM_AGGR_AVL2.gl_period%TYPE := -1;
	l_old_gl_qtr_id			PJI_RM_AGGR_AVL2.gl_qtr%TYPE := -1;
	l_old_roll_x_week1		PJI_RM_AGGR_AVL2.roll_x_week_1%TYPE := -1;
	l_old_roll_x_week2		PJI_RM_AGGR_AVL2.roll_x_week_2%TYPE := -1;
	l_old_roll_x_week3		PJI_RM_AGGR_AVL2.roll_x_week_3%TYPE := -1;
	l_old_roll_x_week4		PJI_RM_AGGR_AVL2.roll_x_week_4%TYPE := -1;
	l_old_roll_x_week5		PJI_RM_AGGR_AVL2.roll_x_week_5%TYPE := -1;
	l_old_roll_x_week6		PJI_RM_AGGR_AVL2.roll_x_week_6%TYPE := -1;
	l_old_roll_x_week7		PJI_RM_AGGR_AVL2.roll_x_week_7%TYPE := -1;
	l_old_roll_x_week8		PJI_RM_AGGR_AVL2.roll_x_week_8%TYPE := -1;
	l_old_roll_x_week9		PJI_RM_AGGR_AVL2.roll_x_week_9%TYPE := -1;
	l_old_roll_x_week10		PJI_RM_AGGR_AVL2.roll_x_week_10%TYPE := -1;
	l_old_roll_x_week11		PJI_RM_AGGR_AVL2.roll_x_week_11%TYPE := -1;
	l_old_roll_x_week12		PJI_RM_AGGR_AVL2.roll_x_week_12%TYPE := -1;
      	l_old_roll_x_week13		PJI_RM_AGGR_AVL2.roll_x_week_13%TYPE := -1;

--Defining local variables for storing resource counts for ALL periods
	/* Important Point */
	/* We are maintaing PL/SQL tables for storing
	   resource counts for NEW
	   VALUES for EACH PERIOD. The description of
	   tables are as follows:
		--> NEW Records
		[LENGTH = 15
			  {
			      5 (no of thresholds)
				x
			      3
				(
				 1 for cumulative count +
				 1 for current consecutive count +
				 1 for "previous and greater than" current consecutive count
				)
			  }
		]
 	*/

	l_week_res_cnt_tbl	N_TYPE_TAB;

	l_ent_pd_res_cnt_tbl	N_TYPE_TAB;
	l_ent_qtr_res_cnt_tbl 	N_TYPE_TAB;

	l_gl_pd_res_cnt_tbl 	N_TYPE_TAB;
	l_gl_qtr_res_cnt_tbl 	N_TYPE_TAB;

	l_roll_x_wk1_res_cnt_tbl	N_TYPE_TAB;
	l_roll_x_wk2_res_cnt_tbl	N_TYPE_TAB;
	l_roll_x_wk3_res_cnt_tbl	N_TYPE_TAB;
	l_roll_x_wk4_res_cnt_tbl	N_TYPE_TAB;
	l_roll_x_wk5_res_cnt_tbl	N_TYPE_TAB;
	l_roll_x_wk6_res_cnt_tbl	N_TYPE_TAB;
	l_roll_x_wk7_res_cnt_tbl	N_TYPE_TAB;
	l_roll_x_wk8_res_cnt_tbl	N_TYPE_TAB;
	l_roll_x_wk9_res_cnt_tbl	N_TYPE_TAB;
	l_roll_x_wk10_res_cnt_tbl	N_TYPE_TAB;
	l_roll_x_wk11_res_cnt_tbl	N_TYPE_TAB;
	l_roll_x_wk12_res_cnt_tbl	N_TYPE_TAB;
	l_roll_x_wk13_res_cnt_tbl	N_TYPE_TAB;

 --These are variables to store the count to determine posting
 --dates of the availability buckets
 	l_week_count			NUMBER(15) := 0;

 	l_ent_pd_count			NUMBER(15) := 0;
 	l_ent_qtr_count			NUMBER(15) := 0;

 	l_gl_pd_count			NUMBER(15) := 0;
 	l_gl_qtr_count			NUMBER(15) := 0;

 	l_roll_x_wk1_count		NUMBER(15) := 0;
 	l_roll_x_wk2_count		NUMBER(15) := 0;
 	l_roll_x_wk3_count		NUMBER(15) := 0;
 	l_roll_x_wk4_count		NUMBER(15) := 0;
 	l_roll_x_wk5_count		NUMBER(15) := 0;
 	l_roll_x_wk6_count		NUMBER(15) := 0;
 	l_roll_x_wk7_count		NUMBER(15) := 0;
 	l_roll_x_wk8_count		NUMBER(15) := 0;
 	l_roll_x_wk9_count		NUMBER(15) := 0;
 	l_roll_x_wk10_count		NUMBER(15) := 0;
 	l_roll_x_wk11_count		NUMBER(15) := 0;
 	l_roll_x_wk12_count		NUMBER(15) := 0;
 	l_roll_x_wk13_count		NUMBER(15) := 0;

--These are variables to store the date of the posting
--date for the non-zero availability buckets.
	l_start_date_org_week		NUMBER(15) := 0;

      	l_start_date_org_ent_pd		NUMBER(15) := 0;
      	l_start_date_org_ent_qtr	NUMBER(15) := 0;

      	l_start_date_org_gl_pd		NUMBER(15) := 0;
      	l_start_date_org_gl_qtr		NUMBER(15) := 0;

      	l_start_date_org_roll_x_wk1	NUMBER(15) := 0;
      	l_start_date_org_roll_x_wk2	NUMBER(15) := 0;
      	l_start_date_org_roll_x_wk3	NUMBER(15) := 0;
      	l_start_date_org_roll_x_wk4	NUMBER(15) := 0;
      	l_start_date_org_roll_x_wk5	NUMBER(15) := 0;
      	l_start_date_org_roll_x_wk6	NUMBER(15) := 0;
      	l_start_date_org_roll_x_wk7	NUMBER(15) := 0;
      	l_start_date_org_roll_x_wk8	NUMBER(15) := 0;
      	l_start_date_org_roll_x_wk9	NUMBER(15) := 0;
      	l_start_date_org_roll_x_wk10	NUMBER(15) := 0;
      	l_start_date_org_roll_x_wk11	NUMBER(15) := 0;
      	l_start_date_org_roll_x_wk12	NUMBER(15) := 0;
      	l_start_date_org_roll_x_wk13	NUMBER(15) := 0;

--These are variables to store the organization change event
--for each period type
	l_week_org_change_flag	VARCHAR2(1):= 'N';

      	l_ent_pd_org_change_flag	VARCHAR2(1):= 'N';
      	l_ent_qtr_org_change_flag	VARCHAR2(1):= 'N';

      	l_gl_pd_org_change_flag		VARCHAR2(1):= 'N';
      	l_gl_qtr_org_change_flag	VARCHAR2(1):= 'N';

      	l_roll_x_wk1_org_change_flag	VARCHAR2(1):= 'N';
      	l_roll_x_wk2_org_change_flag	VARCHAR2(1):= 'N';
      	l_roll_x_wk3_org_change_flag	VARCHAR2(1):= 'N';
      	l_roll_x_wk4_org_change_flag	VARCHAR2(1):= 'N';
      	l_roll_x_wk5_org_change_flag	VARCHAR2(1):= 'N';
      	l_roll_x_wk6_org_change_flag	VARCHAR2(1):= 'N';
      	l_roll_x_wk7_org_change_flag	VARCHAR2(1):= 'N';
      	l_roll_x_wk8_org_change_flag	VARCHAR2(1):= 'N';
      	l_roll_x_wk9_org_change_flag	VARCHAR2(1):= 'N';
      	l_roll_x_wk10_org_change_flag	VARCHAR2(1):= 'N';
      	l_roll_x_wk11_org_change_flag	VARCHAR2(1):= 'N';
      	l_roll_x_wk12_org_change_flag	VARCHAR2(1):= 'N';
      	l_roll_x_wk13_org_change_flag	VARCHAR2(1):= 'N';

 -- Other Local Variables
      	l_bulk_fetch_count		NUMBER := 0;
      	l_count				NUMBER := 1;
      	l_max_count			NUMBER := 200;
      	l_dummy_res_tbl			N_TYPE_TAB;
  	l_zero_bkt_cnt_flag		VARCHAR2(1):= 'Y';

--To make sure that the last valid record for a period
--is processed correctly, a dummy record is inserted in
--the cursor with negative values
Cursor Res_cur IS
SELECT
	WORKER_ID,
	EXPENDITURE_ORGANIZATION_ID,
	EXPENDITURE_ORG_ID,
	PERSON_ID,
	TIME_ID,
	WEEK_ID,
	ENT_PERIOD,
	ENT_QTR ,
	GL_PERIOD,
	GL_QTR  ,
	ROLL_X_WEEK_1,
	ROLL_X_WEEK_2,
	ROLL_X_WEEK_3,
	ROLL_X_WEEK_4,
	ROLL_X_WEEK_5,
	ROLL_X_WEEK_6,
	ROLL_X_WEEK_7,
	ROLL_X_WEEK_8,
	ROLL_X_WEEK_9,
	ROLL_X_WEEK_10,
	ROLL_X_WEEK_11,
	ROLL_X_WEEK_12,
	ROLL_X_WEEK_13,
	AVL_RES_COUNT_BKT1,
	AVL_RES_COUNT_BKT2,
	AVL_RES_COUNT_BKT3,
	AVL_RES_COUNT_BKT4,
	AVL_RES_COUNT_BKT5
FROM
	PJI_RM_AGGR_AVL2 avl2
WHERE 	avl2.person_id = p_person_id
UNION ALL
SELECT
	 p_worker_id as WORKER_ID,
	 power(2,49) as EXPENDITURE_ORGANIZATION_ID,
	 power(2,49) as EXPENDITURE_ORG_ID,
	 power(2,49) as PERSON_ID,
	 power(2,49) as TIME_ID,
	-power(2,49) as WEEK_ID,
	-power(2,49) as ENT_PERIOD,
	-power(2,49) as ENT_QTR ,
	-power(2,49) as GL_PERIOD,
	-power(2,49) as GL_QTR  ,
	 365243 as ROLL_X_WEEK_1,
	 365243 as ROLL_X_WEEK_2,
	 365243 as ROLL_X_WEEK_3,
	 365243 as ROLL_X_WEEK_4,
	 365243 as ROLL_X_WEEK_5,
	 365243 as ROLL_X_WEEK_6,
	 365243 as ROLL_X_WEEK_7,
	 365243 as ROLL_X_WEEK_8,
	 365243 as ROLL_X_WEEK_9,
	 365243 as ROLL_X_WEEK_10,
	 365243 as ROLL_X_WEEK_11,
	 365243 as ROLL_X_WEEK_12,
	 365243 as ROLL_X_WEEK_13,
	-power(2,0) as AVL_RES_COUNT_BKT1,
	-power(2,0) as AVL_RES_COUNT_BKT2,
	-power(2,0) as AVL_RES_COUNT_BKT3,
	-power(2,0) as AVL_RES_COUNT_BKT4,
	-power(2,0) as AVL_RES_COUNT_BKT5
FROM
	DUAL
ORDER BY TIME_ID,
	 EXPENDITURE_ORGANIZATION_ID;

BEGIN

delete from PJI_RM_AGGR_AVL1 where worker_id = p_worker_id;
delete from PJI_RM_AGGR_AVL2 where worker_id = p_worker_id;

x_return_status := FND_API.G_RET_STS_SUCCESS;
savepoint before_calc_starts;
/*PHASE 1*/
/*
The idea is to determine all different periods and quarters for
both enterprise and GL periods that are affected by the
incremental change in the availability data.
So, for Enterprise periods, we select from PJI_RM_AGGR_RES2
and join it to FII_TIME_DAY to get appropriate distinct records
for the periods/quarters/weeks affected. Similarly, for GL periods,
we select from PJI_RM_AGGR_RES2 and join it to
FII_TIME_CAL_DAY_MV and PJI_ORG_EXTR_INFO to get appropriate
distinct records for the periods/quarters affected.
*/
/*
Populate AVL1 only for old fact records
and use the stored values from AVL5
to get values in AVL1 for the new (after
the change is applied) fact records
*/

IF (p_run_mode = 'OLD_FACT_RECORDS') THEN

	--Insert into TMP1 table
	INSERT INTO PJI_RM_AGGR_AVL1
	(
		EXPENDITURE_ORG_ID,
		WORKER_ID,
		PERSON_ID,
		CALENDAR_TYPE,
                GL_CALENDAR_ID,
		PERIOD_TYPE_ID,
		PERIOD_ID,
		PERIOD_TYPE
	)
	SELECT
		cur1.expenditure_org_id as expenditure_org_id,
		cur1.worker_id as worker_id,
		cur1.person_id as person_id,
		cur1.calendar_type as calendar_type,
                cur1.gl_calendar_id as gl_calendar_id,
		cur1.period_type_id as period_type_id,
		cur1.period_id as period_id,
		cur1.period_type as period_type
	FROM
	(
	SELECT /*+ no_merge(rt1) */
		DISTINCT
		rt1.expenditure_org_id as expenditure_org_id,
		rt1.worker_id as worker_id,
		rt1.person_id as person_id,
		rt1.calendar_type as calendar_type,
                rt1.gl_calendar_id as gl_calendar_id,
		case when rt2.tmp_index = 1 then
				   16
			 when rt2.tmp_index = 2 then
				   64
			 end                                period_type_id,
		case when rt2.tmp_index = 1 then
				   rt1.week_id
			 when rt2.tmp_index = 2 then
				   rt1.qtr_id
			 end                                period_id,
		case when rt2.tmp_index = 1 then
				   'W'
			 when rt2.tmp_index = 2 then
				   'E'
			 end                                period_type
	FROM
	(
	SELECT /*+ ordered
		   index(tmp2. PJI_RM_AGGR_RES2_N1)
		   full(fiit) use_hash(fiit) */
		DISTINCT
		tmp2.expenditure_org_id as expenditure_org_id,
		p_worker_id as worker_id,
		tmp2.person_id as person_id,
		tmp2.calendar_type as calendar_type,
                tmp2.gl_calendar_id as gl_calendar_id,
		fiit.ent_qtr_id as qtr_id,
		(to_char(fiit.week_start_date,'j') - g_min_wk_j_st_date)/7 + 1 as week_id
	FROM
		PJI_RM_AGGR_RES2 tmp2,
		FII_TIME_DAY fiit
	WHERE
		tmp2.person_id = p_person_id
		and tmp2.time_id = fiit.report_date_julian
		and (
			ABS(nvl(tmp2.capacity_hrs, 0)) + ABS(nvl(tmp2.available_res_count_bkt1_s, 0)) +
			ABS(nvl(tmp2.available_res_count_bkt2_s, 0)) + ABS(nvl(tmp2.available_res_count_bkt3_s, 0)) +
			ABS(nvl(tmp2.available_res_count_bkt4_s, 0)) + ABS(nvl(tmp2.available_res_count_bkt5_s, 0))
		    ) > 0
		) rt1,
		(
		SELECT 1 as tmp_index from dual
		UNION ALL
		SELECT 2 as tmp_index from dual
		) rt2
UNION ALL
SELECT /*+ ordered
	   index(tmp2, PJI_RM_AGGR_RES2_N1)
	   index(fiit, FII_TIME_CAL_DAY_MV_U1) */
	DISTINCT
	tmp2.expenditure_org_id as expenditure_org_id,
	p_worker_id as worker_id,
	tmp2.person_id as person_id,
	tmp2.calendar_type as calendar_type,
        tmp2.gl_calendar_id as gl_calendar_id,
	64 as period_type_id,
	fiit.cal_qtr_id as period_id,
	'G' as period_type
FROM
	PJI_RM_AGGR_RES2 tmp2,
	FII_TIME_CAL_DAY_MV fiit
WHERE
	tmp2.person_id = p_person_id
	and to_date(to_char(tmp2.time_id), 'J') = fiit.report_date
	and (
		ABS(nvl(tmp2.capacity_hrs, 0)) + ABS(nvl(tmp2.available_res_count_bkt1_s, 0)) +
		ABS(nvl(tmp2.available_res_count_bkt2_s, 0)) + ABS(nvl(tmp2.available_res_count_bkt3_s, 0)) +
		ABS(nvl(tmp2.available_res_count_bkt4_s, 0)) + ABS(nvl(tmp2.available_res_count_bkt5_s, 0))
	    )> 0
	and tmp2.gl_calendar_id = fiit.calendar_id
) cur1;

--Insert this is AVL5 table so that we can pick up
--the values from this table in the second run after
--changes are applied to the fact table

	INSERT INTO PJI_RM_AGGR_AVL5
	(
		EXPENDITURE_ORG_ID,
		PERSON_ID,
		CALENDAR_TYPE,
                GL_CALENDAR_ID,
		PERIOD_TYPE_ID,
		PERIOD_ID,
		PERIOD_TYPE
	)
	SELECT
		avl1.expenditure_org_id as expenditure_org_id,
		avl1.person_id as person_id,
		avl1.calendar_type as calendar_type,
                avl1.gl_calendar_id as gl_calendar_id,
		avl1.period_type_id as period_type_id,
		avl1.period_id as period_id,
		avl1.period_type as period_type
	FROM 	PJI_RM_AGGR_AVL1 avl1;
ELSE
--This is for the next run when changes
--have been applied to the fact table
	INSERT INTO PJI_RM_AGGR_AVL1
	(
		EXPENDITURE_ORG_ID,
		WORKER_ID,
		PERSON_ID,
		CALENDAR_TYPE,
                GL_CALENDAR_ID,
		PERIOD_TYPE_ID,
		PERIOD_ID,
		PERIOD_TYPE
	)
	SELECT
		avl5.expenditure_org_id as expenditure_org_id,
		p_worker_id as worker_id,
		avl5.person_id as person_id,
		avl5.calendar_type as calendar_type,
                avl5.gl_calendar_id as gl_calendar_id,
		avl5.period_type_id as period_type_id,
		avl5.period_id as period_id,
		avl5.period_type as period_type
	FROM 	PJI_RM_AGGR_AVL5 avl5
	WHERE 	avl5.person_id = p_person_id;
END IF;

/*PHASE 2*/
/*
The basic idea for phase 2 is to determine the earliest
and the latest dates that are affected across all periods.
So, once this is determined, we store records as a union
of all days that are affected across all periods. The same
day may actually affect a period in enterprise period but
may not affect a period in GL. We store that information
in a matrix table that has a completely denormalized schema.
*/
--Populate TMP2 table
INSERT INTO PJI_RM_AGGR_AVL2
(
	WORKER_ID,
	EXPENDITURE_ORGANIZATION_ID,
	EXPENDITURE_ORG_ID,
	PERSON_ID,
	TIME_ID,
	WEEK_ID,
	ENT_PERIOD,
	ENT_QTR ,
	GL_PERIOD,
	GL_QTR  ,
	ROLL_X_WEEK_1,
	ROLL_X_WEEK_2,
	ROLL_X_WEEK_3,
	ROLL_X_WEEK_4,
	ROLL_X_WEEK_5,
	ROLL_X_WEEK_6,
	ROLL_X_WEEK_7,
	ROLL_X_WEEK_8,
	ROLL_X_WEEK_9,
	ROLL_X_WEEK_10,
	ROLL_X_WEEK_11,
	ROLL_X_WEEK_12,
	ROLL_X_WEEK_13,
	AVL_RES_COUNT_BKT1,
	AVL_RES_COUNT_BKT2,
	AVL_RES_COUNT_BKT3,
	AVL_RES_COUNT_BKT4,
	AVL_RES_COUNT_BKT5
)
SELECT /*+ full(cur2) use_hash(cur2) index(fct, PJI_RM_RES_F_N2) */
	cur2.worker_id as worker_id,
	fct.expenditure_organization_id,
	fct.expenditure_org_id,
	cur2.person_id as person_id,
	cur2.time_id as time_id,
	cur2.week_id as week_id,
	cur2.ent_period as ent_period,
	cur2.ent_qtr as ent_qtr,
	cur2.gl_period as gl_period,
	cur2.gl_qtr as gl_qtr,
	cur2.ROLL_X_WEEK_1 as ROLL_X_WEEK_1,
	cur2.ROLL_X_WEEK_2 as ROLL_X_WEEK_2,
	cur2.ROLL_X_WEEK_3 as ROLL_X_WEEK_3,
	cur2.ROLL_X_WEEK_4 as ROLL_X_WEEK_4,
	cur2.ROLL_X_WEEK_5 as ROLL_X_WEEK_5,
	cur2.ROLL_X_WEEK_6 as ROLL_X_WEEK_6,
	cur2.ROLL_X_WEEK_7 as ROLL_X_WEEK_7,
	cur2.ROLL_X_WEEK_8 as ROLL_X_WEEK_8,
	cur2.ROLL_X_WEEK_9 as ROLL_X_WEEK_9,
	cur2.ROLL_X_WEEK_10 as ROLL_X_WEEK_10,
	cur2.ROLL_X_WEEK_11 as ROLL_X_WEEK_11,
	cur2.ROLL_X_WEEK_12 as ROLL_X_WEEK_12,
	cur2.ROLL_X_WEEK_13 as ROLL_X_WEEK_13,
	NVL(fct.AVAILABLE_RES_COUNT_BKT1_S, 0) as AVL_RES_COUNT_BKT1,
	NVL(fct.AVAILABLE_RES_COUNT_BKT2_S, 0) as AVL_RES_COUNT_BKT2,
	NVL(fct.AVAILABLE_RES_COUNT_BKT3_S, 0) as AVL_RES_COUNT_BKT3,
	NVL(fct.AVAILABLE_RES_COUNT_BKT4_S, 0) as AVL_RES_COUNT_BKT4,
	NVL(fct.AVAILABLE_RES_COUNT_BKT5_S, 0) as AVL_RES_COUNT_BKT5
FROM
(
SELECT
	cur1.worker_id as worker_id,
	cur1.person_id as person_id,
	cur1.time_id as time_id,
	sum(cur1.week_id) as week_id,
	sum(cur1.ent_period) as ent_period,
	sum(cur1.ent_qtr) as ent_qtr,
	sum(cur1.gl_period) as gl_period,
	sum(cur1.gl_qtr) as gl_qtr,
	sum(cur1.ROLL_X_WEEK_1) as ROLL_X_WEEK_1,
	sum(cur1.ROLL_X_WEEK_2) as ROLL_X_WEEK_2,
	sum(cur1.ROLL_X_WEEK_3) as ROLL_X_WEEK_3,
	sum(cur1.ROLL_X_WEEK_4) as ROLL_X_WEEK_4,
	sum(cur1.ROLL_X_WEEK_5) as ROLL_X_WEEK_5,
	sum(cur1.ROLL_X_WEEK_6) as ROLL_X_WEEK_6,
	sum(cur1.ROLL_X_WEEK_7) as ROLL_X_WEEK_7,
	sum(cur1.ROLL_X_WEEK_8) as ROLL_X_WEEK_8,
	sum(cur1.ROLL_X_WEEK_9) as ROLL_X_WEEK_9,
	sum(cur1.ROLL_X_WEEK_10) as ROLL_X_WEEK_10,
	sum(cur1.ROLL_X_WEEK_11) as ROLL_X_WEEK_11,
	sum(cur1.ROLL_X_WEEK_12) as ROLL_X_WEEK_12,
	sum(cur1.ROLL_X_WEEK_13) as ROLL_X_WEEK_13
FROM
(
SELECT /*+ cardinality(avl_tmp1, 1) cache(fiit) */  DISTINCT
	p_worker_id as worker_id,
	avl_tmp1.person_id as person_id,
	fiit.report_date_julian as time_id,
	0 as week_id,
	fiit.ent_period_id as ent_period,
	fiit.ent_qtr_id as ent_qtr,
	0 as gl_period,
	0 as gl_qtr,
	0 as ROLL_X_WEEK_1,
	0 as ROLL_X_WEEK_2,
	0 as ROLL_X_WEEK_3,
	0 as ROLL_X_WEEK_4,
	0 as ROLL_X_WEEK_5,
	0 as ROLL_X_WEEK_6,
	0 as ROLL_X_WEEK_7,
	0 as ROLL_X_WEEK_8,
	0 as ROLL_X_WEEK_9,
	0 as ROLL_X_WEEK_10,
	0 as ROLL_X_WEEK_11,
	0 as ROLL_X_WEEK_12,
	0 as ROLL_X_WEEK_13
FROM
	PJI_RM_AGGR_AVL1 avl_tmp1,
	FII_TIME_DAY fiit
WHERE
	avl_tmp1.PERIOD_ID = fiit.ENT_QTR_ID
	and avl_tmp1.period_type_id = 64
	and avl_tmp1.period_type = 'E'
	and avl_tmp1.worker_id = p_worker_id
UNION ALL
SELECT  /*+ cardinality(avl_tmp1, 1) */
	DISTINCT
	p_worker_id as worker_id,
	avl_tmp1.person_id as person_id,
	fiit.report_date_julian as time_id,
	0 as week_id,
	0 as ent_period,
	0 as ent_qtr,
	fiit.cal_period_id as gl_period,
	fiit.cal_qtr_id as gl_qtr,
	0 as ROLL_X_WEEK_1,
	0 as ROLL_X_WEEK_2,
	0 as ROLL_X_WEEK_3,
	0 as ROLL_X_WEEK_4,
	0 as ROLL_X_WEEK_5,
	0 as ROLL_X_WEEK_6,
	0 as ROLL_X_WEEK_7,
	0 as ROLL_X_WEEK_8,
	0 as ROLL_X_WEEK_9,
	0 as ROLL_X_WEEK_10,
	0 as ROLL_X_WEEK_11,
	0 as ROLL_X_WEEK_12,
	0 as ROLL_X_WEEK_13
FROM
	PJI_RM_AGGR_AVL1 avl_tmp1,
	FII_TIME_CAL_PERIOD per,
	FII_TIME_CAL_DAY_MV fiit
WHERE
	avl_tmp1.PERIOD_ID = per.CAL_QTR_ID
	and avl_tmp1.gl_calendar_id = per.calendar_id
	and per.cal_period_id = fiit.cal_period_id
        and per.calendar_id = fiit.calendar_id
	and avl_tmp1.period_type_id = 64
	and avl_tmp1.period_type = 'G'
	and avl_tmp1.worker_id = p_worker_id
UNION ALL
SELECT
	cur.worker_id as worker_id,
	cur.person_id as person_id,
	fiid.report_date_julian as time_id,
	cur.week_id as week_id,
	0 as ent_period,
	0 as ent_qtr,
	0 as gl_period,
	0 as gl_qtr,
	cur.rw1 as ROLL_X_WEEK_1,
	cur.rw2 as ROLL_X_WEEK_2,
	cur.rw3 as ROLL_X_WEEK_3,
	cur.rw4 as ROLL_X_WEEK_4,
	cur.rw5 as ROLL_X_WEEK_5,
	cur.rw6 as ROLL_X_WEEK_6,
	cur.rw7 as ROLL_X_WEEK_7,
	cur.rw8 as ROLL_X_WEEK_8,
	cur.rw9 as ROLL_X_WEEK_9,
	cur.rw10 as ROLL_X_WEEK_10,
	cur.rw11 as ROLL_X_WEEK_11,
	cur.rw12 as ROLL_X_WEEK_12,
	cur.rw13 as ROLL_X_WEEK_13
FROM
(
	SELECT /*+ no_merge cardinality(1) */
		cur4.worker_id as worker_id,
		cur4.person_id as person_id,
		fweek.week_id as period_id,
		fweek1.week_id as week_id,
		cur4.rw1 as rw1,
		cur4.rw2 as rw2,
		cur4.rw3 as rw3,
		cur4.rw4 as rw4,
		cur4.rw5 as rw5,
		cur4.rw6 as rw6,
		cur4.rw7 as rw7,
		cur4.rw8 as rw8,
		cur4.rw9 as rw9,
		cur4.rw10 as rw10,
		cur4.rw11 as rw11,
		cur4.rw12 as rw12,
		cur4.rw13 as rw13
	FROM
	(
		SELECT
			  cur5.worker_id as worker_id,
			  cur5.person_id as person_id,
			  cur5.sequence_id as period_id,
			  sum(NVL(cur5.week_id,0)) as week_id,
			  DECODE(sign(g_no_of_roll_week-0),1,( (FLOOR(( cur5.sequence_id - 0 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 0 ) * decode( sign(sum(cur5.rw1_flag)), 0, NULL, 1),null)   rw1
			, DECODE(sign(g_no_of_roll_week-1),1,( (FLOOR(( cur5.sequence_id - 1 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 1 ) * decode( sign(sum(cur5.rw2_flag)), 0, NULL, 1),null)   rw2
			, DECODE(sign(g_no_of_roll_week-2),1,( (FLOOR(( cur5.sequence_id - 2 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 2 ) * decode( sign(sum(cur5.rw3_flag)), 0, NULL, 1),null)   rw3
			, DECODE(sign(g_no_of_roll_week-3),1,( (FLOOR(( cur5.sequence_id - 3 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 3 ) * decode( sign(sum(cur5.rw4_flag)), 0, NULL, 1),null)   rw4
			, DECODE(sign(g_no_of_roll_week-4),1,( (FLOOR(( cur5.sequence_id - 4 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 4 ) * decode( sign(sum(cur5.rw5_flag)), 0, NULL, 1),null)   rw5
			, DECODE(sign(g_no_of_roll_week-5),1,( (FLOOR(( cur5.sequence_id - 5 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 5 ) * decode( sign(sum(cur5.rw6_flag)), 0, NULL, 1),null)   rw6
			, DECODE(sign(g_no_of_roll_week-6),1,( (FLOOR(( cur5.sequence_id - 6 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 6 ) * decode( sign(sum(cur5.rw7_flag)), 0, NULL, 1),null)   rw7
			, DECODE(sign(g_no_of_roll_week-7),1,( (FLOOR(( cur5.sequence_id - 7 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 7 ) * decode( sign(sum(cur5.rw8_flag)), 0, NULL, 1),null)   rw8
			, DECODE(sign(g_no_of_roll_week-8),1,( (FLOOR(( cur5.sequence_id - 8 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 8 ) * decode( sign(sum(cur5.rw9_flag)), 0, NULL, 1),null)   rw9
			, DECODE(sign(g_no_of_roll_week-9),1,( (FLOOR(( cur5.sequence_id - 9 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 9 ) * decode( sign(sum(cur5.rw10_flag)), 0, NULL, 1),null)   rw10
			, DECODE(sign(g_no_of_roll_week-10),1,( (FLOOR(( cur5.sequence_id - 10 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 10 ) * decode( sign(sum(cur5.rw11_flag)), 0, NULL, 1),null)   rw11
			, DECODE(sign(g_no_of_roll_week-11),1,( (FLOOR(( cur5.sequence_id - 11 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 11 ) * decode( sign(sum(cur5.rw12_flag)), 0, NULL, 1),null)   rw12
			, DECODE(sign(g_no_of_roll_week-12),1,( (FLOOR(( cur5.sequence_id - 12 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 12 ) * decode( sign(sum(cur5.rw13_flag)), 0, NULL, 1),null)   rw13
		FROM
		(
			SELECT	  DISTINCT
				  p_worker_id as worker_id,
				  w.person_id as person_id,
				  w.period_id + rw.offset                            sequence_id
				, case when rw.offset = 0 then
						   w.period_id
					  else
						   null
				  end  	   		 	          	     as week_id
				, DECODE(sign(g_no_of_roll_week-0),1,1-abs(sign( FLOOR((w.period_id-(    (FLOOR(( w.period_id + rw.offset - 0 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 0    ))/g_no_of_roll_week) )),null)   rw1_flag
				, DECODE(sign(g_no_of_roll_week-1),1,1-abs(sign( FLOOR((w.period_id-(    (FLOOR(( w.period_id + rw.offset - 1 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 1    ))/g_no_of_roll_week) )),null)   rw2_flag
				, DECODE(sign(g_no_of_roll_week-2),1,1-abs(sign( FLOOR((w.period_id-(    (FLOOR(( w.period_id + rw.offset - 2 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 2    ))/g_no_of_roll_week) )),null)   rw3_flag
				, DECODE(sign(g_no_of_roll_week-3),1,1-abs(sign( FLOOR((w.period_id-(    (FLOOR(( w.period_id + rw.offset - 3 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 3    ))/g_no_of_roll_week) )),null)   rw4_flag
				, DECODE(sign(g_no_of_roll_week-4),1,1-abs(sign( FLOOR((w.period_id-(    (FLOOR(( w.period_id + rw.offset - 4 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 4    ))/g_no_of_roll_week) )),null)   rw5_flag
				, DECODE(sign(g_no_of_roll_week-5),1,1-abs(sign( FLOOR((w.period_id-(    (FLOOR(( w.period_id + rw.offset - 5 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 5    ))/g_no_of_roll_week) )),null)   rw6_flag
				, DECODE(sign(g_no_of_roll_week-6),1,1-abs(sign( FLOOR((w.period_id-(    (FLOOR(( w.period_id + rw.offset - 6 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 6    ))/g_no_of_roll_week) )),null)   rw7_flag
				, DECODE(sign(g_no_of_roll_week-7),1,1-abs(sign( FLOOR((w.period_id-(    (FLOOR(( w.period_id + rw.offset - 7 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 7    ))/g_no_of_roll_week) )),null)   rw8_flag
				, DECODE(sign(g_no_of_roll_week-8),1,1-abs(sign( FLOOR((w.period_id-(    (FLOOR(( w.period_id + rw.offset - 8 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 8    ))/g_no_of_roll_week) )),null)   rw9_flag
				, DECODE(sign(g_no_of_roll_week-9),1,1-abs(sign( FLOOR((w.period_id-(    (FLOOR(( w.period_id + rw.offset - 9 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 9    ))/g_no_of_roll_week) )),null)   rw10_flag
				, DECODE(sign(g_no_of_roll_week-10),1,1-abs(sign( FLOOR((w.period_id-(    (FLOOR(( w.period_id + rw.offset - 10 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 10    ))/g_no_of_roll_week) )),null)   rw11_flag
				, DECODE(sign(g_no_of_roll_week-11),1,1-abs(sign( FLOOR((w.period_id-(    (FLOOR(( w.period_id + rw.offset - 11 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 11    ))/g_no_of_roll_week) )),null)   rw12_flag
				, DECODE(sign(g_no_of_roll_week-12),1,1-abs(sign( FLOOR((w.period_id-(    (FLOOR(( w.period_id + rw.offset - 12 + g_no_of_roll_week )/g_no_of_roll_week)-1) * g_no_of_roll_week + 12    ))/g_no_of_roll_week) )),null)   rw13_flag
			FROM
				PJI_RM_AGGR_AVL1     w
			      , PJI_ROLL_WEEK_OFFSET    rw
			WHERE
				w.period_type = 'W'
			and     w.worker_id = p_worker_id
		) cur5
		GROUP BY worker_id,
		person_id,
		sequence_id
	) cur4,
	(
	SELECT /*+ cache(fiit) */
		 fiit.week_id as week_id,
		(to_char(fiit.start_date,'j') - g_min_wk_j_st_date)/7 + 1 as sequence_id
	FROM
		FII_TIME_WEEK fiit
	) fweek,
	(
	SELECT /*+ cache(fiii) */
		 fiii.week_id as week_id,
		(to_char(fiii.start_date,'j') - g_min_wk_j_st_date)/7 + 1 as sequence_id
	FROM
		FII_TIME_WEEK fiii
	) fweek1
	WHERE
	cur4.period_id = fweek.sequence_id
	and cur4.week_id = fweek1.sequence_id (+)
) cur
, FII_TIME_DAY fiid
WHERE
	cur.PERIOD_ID = fiid.WEEK_ID
) cur1
GROUP BY
	cur1.worker_id,
	cur1.person_id,
	cur1.time_id
) cur2,
	PJI_RM_RES_F fct
  WHERE
	cur2.time_id        = fct.time_id
	and cur2.person_id  = fct.person_id
	and 'C'             = fct.calendar_type
	and 0              <> nvl(fct.capacity_hrs, 0)
	and p_person_id     = fct.person_id;

/*PHASE 3*/
/*
The basic idea for phase 3 is to determine the availability
of resources for the user defined buckets for each period
type. So, we do a row by row processing for all the records
entered in PJI_RM_AGGR_AVL2 table and based on the affect
it has on each period (enterprise quarter, enterprise period,
GL period, GL quarter, Rolling Weeks), we process for each
period type separately.
Different processing is done for Cumulative buckets and
consecutive buckets within the same period.
*/
--Initializing PL/SQL Static tables for storing
--resource count values for each period

FOR i_r in 1.. 15
LOOP
	--Storing resource count values for week
	l_week_res_cnt_tbl(i_r) := 0;

	--Storing resource count values for enterprise periods / quarters
	l_ent_pd_res_cnt_tbl(i_r) := 0;
	l_ent_qtr_res_cnt_tbl(i_r) := 0;

	--Storing resource count values for enterprise periods / quarters
	l_gl_pd_res_cnt_tbl(i_r) := 0;
	l_gl_qtr_res_cnt_tbl(i_r) := 0;

	--Storing resource count values for Rolling wks
	l_roll_x_wk1_res_cnt_tbl(i_r) := 0;
	l_roll_x_wk2_res_cnt_tbl(i_r) := 0;
	l_roll_x_wk3_res_cnt_tbl(i_r) := 0;
	l_roll_x_wk4_res_cnt_tbl(i_r) := 0;
	l_roll_x_wk5_res_cnt_tbl(i_r) := 0;
	l_roll_x_wk6_res_cnt_tbl(i_r) := 0;
	l_roll_x_wk7_res_cnt_tbl(i_r) := 0;
	l_roll_x_wk8_res_cnt_tbl(i_r) := 0;
	l_roll_x_wk9_res_cnt_tbl(i_r) := 0;
	l_roll_x_wk10_res_cnt_tbl(i_r) := 0;
	l_roll_x_wk11_res_cnt_tbl(i_r) := 0;
	l_roll_x_wk12_res_cnt_tbl(i_r) := 0;
	l_roll_x_wk13_res_cnt_tbl(i_r) := 0;
END LOOP;

OPEN Res_cur;
LOOP
	-- Delete existing records from the PL/SQL tables
	l_worker_id_tbl.DELETE;
	l_exp_organization_id_tbl.DELETE;
	l_exp_org_id_tbl.DELETE;
	l_person_id_tbl.DELETE;
	l_time_id_tbl.DELETE;
	l_week_id_tbl.DELETE;
	l_ent_period_id_tbl.DELETE;
	l_ent_qtr_id_tbl.DELETE;
	l_gl_period_id_tbl.DELETE;
	l_gl_qtr_id_tbl.DELETE;
	l_roll_x_week_1_tbl.DELETE;
	l_roll_x_week_2_tbl.DELETE;
	l_roll_x_week_3_tbl.DELETE;
	l_roll_x_week_4_tbl.DELETE;
	l_roll_x_week_5_tbl.DELETE;
	l_roll_x_week_6_tbl.DELETE;
	l_roll_x_week_7_tbl.DELETE;
	l_roll_x_week_8_tbl.DELETE;
	l_roll_x_week_9_tbl.DELETE;
	l_roll_x_week_10_tbl.DELETE;
	l_roll_x_week_11_tbl.DELETE;
	l_roll_x_week_12_tbl.DELETE;
	l_roll_x_week_13_tbl.DELETE;
	l_avl_res_cnt_1_tbl.DELETE;
	l_avl_res_cnt_2_tbl.DELETE;
	l_avl_res_cnt_3_tbl.DELETE;
	l_avl_res_cnt_4_tbl.DELETE;
	l_avl_res_cnt_5_tbl.DELETE;

	FETCH Res_cur
		BULK COLLECT INTO
		l_worker_id_tbl,
		l_exp_organization_id_tbl,
		l_exp_org_id_tbl,
		l_person_id_tbl,
		l_time_id_tbl,
		l_week_id_tbl,
		l_ent_period_id_tbl,
		l_ent_qtr_id_tbl,
		l_gl_period_id_tbl,
		l_gl_qtr_id_tbl,
		l_roll_x_week_1_tbl,
		l_roll_x_week_2_tbl,
		l_roll_x_week_3_tbl,
		l_roll_x_week_4_tbl,
		l_roll_x_week_5_tbl,
		l_roll_x_week_6_tbl,
		l_roll_x_week_7_tbl,
		l_roll_x_week_8_tbl,
		l_roll_x_week_9_tbl,
		l_roll_x_week_10_tbl,
		l_roll_x_week_11_tbl,
		l_roll_x_week_12_tbl,
		l_roll_x_week_13_tbl,
		l_avl_res_cnt_1_tbl,
		l_avl_res_cnt_2_tbl,
		l_avl_res_cnt_3_tbl,
		l_avl_res_cnt_4_tbl,
		l_avl_res_cnt_5_tbl
		LIMIT l_max_count;
	l_bulk_fetch_count := l_exp_organization_id_tbl.count;

	IF (l_bulk_fetch_count = 0) THEN
		EXIT;
	END IF;
	FOR i in l_exp_organization_id_tbl.FIRST.. l_exp_organization_id_tbl.LAST
	LOOP
		--Assigning PL/SQL table values to local variables

		l_worker_id		:= l_worker_id_tbl(i);
		l_exp_organization_id 	:= l_exp_organization_id_tbl(i);
		l_exp_org_id	 	:= l_exp_org_id_tbl(i);
		l_person_id		:= l_person_id_tbl(i);
		l_time_id		:= l_time_id_tbl(i);
		l_week_id		:= l_week_id_tbl(i);
		l_ent_period_id		:= l_ent_period_id_tbl(i);
		l_ent_qtr_id		:= l_ent_qtr_id_tbl(i);
		l_gl_period_id		:= l_gl_period_id_tbl(i);
		l_gl_qtr_id		:= l_gl_qtr_id_tbl(i);
		l_roll_x_week1		:= l_roll_x_week_1_tbl(i);
		l_roll_x_week2		:= l_roll_x_week_2_tbl(i);
		l_roll_x_week3		:= l_roll_x_week_3_tbl(i);
		l_roll_x_week4		:= l_roll_x_week_4_tbl(i);
		l_roll_x_week5		:= l_roll_x_week_5_tbl(i);
		l_roll_x_week6		:= l_roll_x_week_6_tbl(i);
		l_roll_x_week7		:= l_roll_x_week_7_tbl(i);
		l_roll_x_week8		:= l_roll_x_week_8_tbl(i);
		l_roll_x_week9		:= l_roll_x_week_9_tbl(i);
		l_roll_x_week10		:= l_roll_x_week_10_tbl(i);
		l_roll_x_week11		:= l_roll_x_week_11_tbl(i);
		l_roll_x_week12		:= l_roll_x_week_12_tbl(i);
		l_roll_x_week13		:= l_roll_x_week_13_tbl(i);
		g_avl_res_cnt_1 	:= l_avl_res_cnt_1_tbl(i);
		g_avl_res_cnt_2		:= l_avl_res_cnt_2_tbl(i);
		g_avl_res_cnt_3 	:= l_avl_res_cnt_3_tbl(i);
		g_avl_res_cnt_4 	:= l_avl_res_cnt_4_tbl(i);
		g_avl_res_cnt_5 	:= l_avl_res_cnt_5_tbl(i);

		--Processing starts now
      		--First for ENTERPRISE PERIOD
      		IF (l_ent_period_id <> 0 AND l_ent_period_id IS NOT NULL) THEN
      			IF (l_old_ent_period_id < 0
      				OR l_old_person_id < 0
      				OR l_old_exp_orgnztion_id < 0
      			   ) THEN
      				-- Do Nothing
      				-- This is just to make sure that nothing is
      				-- executed for the very first time the program
      				-- comes in the Cursor
      				--DBMS_OUTPUT.PUT_LINE('1');
      					NULL;
      			ELSIF (l_ent_period_id <> l_old_ent_period_id
      				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
      				  ) THEN
				--All records for this enterprise period
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_ent_pd_res_cnt_tbl(11) := GREATEST (l_ent_pd_res_cnt_tbl(6), NVL(l_ent_pd_res_cnt_tbl(11),0));
				l_ent_pd_res_cnt_tbl(12) := GREATEST (l_ent_pd_res_cnt_tbl(7), NVL(l_ent_pd_res_cnt_tbl(12),0));
				l_ent_pd_res_cnt_tbl(13) := GREATEST (l_ent_pd_res_cnt_tbl(8), NVL(l_ent_pd_res_cnt_tbl(13),0));
				l_ent_pd_res_cnt_tbl(14) := GREATEST (l_ent_pd_res_cnt_tbl(9), NVL(l_ent_pd_res_cnt_tbl(14),0));
				l_ent_pd_res_cnt_tbl(15) := GREATEST (l_ent_pd_res_cnt_tbl(10), NVL(l_ent_pd_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and enterprise period in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
				    	p_time_id		=> l_old_ent_period_id,
				    	p_curr_pd		=> l_ent_period_id,
				    	p_as_of_date		=> l_time_id,
				    	p_pd_org_st_date	=> l_start_date_org_ent_pd,
					p_period_type_id	=> 32,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_ent_pd_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_ent_period_id = l_old_ent_period_id) THEN
					l_ent_pd_org_change_flag	:= 'Y';
				ELSE
					l_ent_pd_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_ent_pd_res_cnt_tbl.FIRST.. l_ent_pd_res_cnt_tbl.LAST
				LOOP
					l_ent_pd_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_ent_pd_res_cnt_tbl(1)	:= NVL(l_ent_pd_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_ent_pd_res_cnt_tbl(2)	:= NVL(l_ent_pd_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_ent_pd_res_cnt_tbl(3)	:= NVL(l_ent_pd_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_ent_pd_res_cnt_tbl(4)	:= NVL(l_ent_pd_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_ent_pd_res_cnt_tbl(5)	:= NVL(l_ent_pd_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

        	        --Processing for consecutive records
			l_ent_pd_res_cnt_tbl(6)	:= NVL(l_ent_pd_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_ent_pd_res_cnt_tbl(7)	:= NVL(l_ent_pd_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_ent_pd_res_cnt_tbl(8)	:= NVL(l_ent_pd_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_ent_pd_res_cnt_tbl(9)	:= NVL(l_ent_pd_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_ent_pd_res_cnt_tbl(10):= NVL(l_ent_pd_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_ent_pd_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_ent_pd_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_ent_pd := l_time_id;
			ELSIF (l_ent_pd_count = 0) THEN
			BEGIN
				SELECT to_char(fiit.start_date,'j')
				INTO l_start_date_org_ent_pd
				FROM fii_time_ent_period fiit
				WHERE ent_period_id = l_ent_period_id;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_ent_pd_res_cnt_tbl
			);
      			--Assigning current enterprise period id to
      			--old period id local variable
      			l_old_ent_period_id 	:= l_ent_period_id;
      			l_ent_pd_count		:= l_ent_pd_count + 1;
      			l_ent_pd_org_change_flag:= 'N';
      		END IF;
      		/* End of Processing for ENTERPRISE PERIOD */

		--For ENTERPRISE QUARTER
		IF (l_ent_qtr_id <> 0 AND l_ent_qtr_id IS NOT NULL) THEN
			IF (l_old_ent_qtr_id < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_ent_qtr_id <> l_old_ent_qtr_id
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this ENTERPRISE QUARTER
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_ent_qtr_res_cnt_tbl(11) := GREATEST (l_ent_qtr_res_cnt_tbl(6), NVL(l_ent_qtr_res_cnt_tbl(11),0));
				l_ent_qtr_res_cnt_tbl(12) := GREATEST (l_ent_qtr_res_cnt_tbl(7), NVL(l_ent_qtr_res_cnt_tbl(12),0));
				l_ent_qtr_res_cnt_tbl(13) := GREATEST (l_ent_qtr_res_cnt_tbl(8), NVL(l_ent_qtr_res_cnt_tbl(13),0));
				l_ent_qtr_res_cnt_tbl(14) := GREATEST (l_ent_qtr_res_cnt_tbl(9), NVL(l_ent_qtr_res_cnt_tbl(14),0));
				l_ent_qtr_res_cnt_tbl(15) := GREATEST (l_ent_qtr_res_cnt_tbl(10), NVL(l_ent_qtr_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and ENTERPRISE QUARTER in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_ent_qtr_id,
					p_curr_pd		=> l_ent_qtr_id,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_ent_qtr,
					p_period_type_id	=> 64,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_ent_qtr_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_ent_qtr_id = l_old_ent_qtr_id) THEN
					l_ent_qtr_org_change_flag	:= 'Y';
				ELSE
					l_ent_qtr_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_ent_qtr_res_cnt_tbl.FIRST.. l_ent_qtr_res_cnt_tbl.LAST
				LOOP
					l_ent_qtr_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_ent_qtr_res_cnt_tbl(1)	:= NVL(l_ent_qtr_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_ent_qtr_res_cnt_tbl(2)	:= NVL(l_ent_qtr_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_ent_qtr_res_cnt_tbl(3)	:= NVL(l_ent_qtr_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_ent_qtr_res_cnt_tbl(4)	:= NVL(l_ent_qtr_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_ent_qtr_res_cnt_tbl(5)	:= NVL(l_ent_qtr_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_ent_qtr_res_cnt_tbl(6)	:= NVL(l_ent_qtr_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_ent_qtr_res_cnt_tbl(7)	:= NVL(l_ent_qtr_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_ent_qtr_res_cnt_tbl(8)	:= NVL(l_ent_qtr_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_ent_qtr_res_cnt_tbl(9)	:= NVL(l_ent_qtr_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_ent_qtr_res_cnt_tbl(10):= NVL(l_ent_qtr_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_ent_qtr_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_ent_qtr_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_ent_qtr := l_time_id;
			ELSIF (l_ent_qtr_count = 0) THEN
			BEGIN
				SELECT to_char(fiit.start_date,'j')
				INTO l_start_date_org_ent_qtr
				FROM fii_time_ent_qtr fiit
				WHERE ent_qtr_id = l_ent_qtr_id;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_ent_qtr_res_cnt_tbl
			);
			--Assigning current ENTERPRISE QUARTER id to
			--old period id local variable
			l_old_ent_qtr_id 	:= l_ent_qtr_id;
			l_ent_qtr_count		:= l_ent_qtr_count + 1;
			l_ent_qtr_org_change_flag:= 'N';
		END IF;
		/* End of Processing for ENTERPRISE QUARTER */

		--For GL PERIOD
		IF (l_gl_period_id <> 0 AND l_gl_period_id IS NOT NULL) THEN
			IF (l_old_gl_period_id < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_gl_period_id <> l_old_gl_period_id
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this GL PERIOD
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_gl_pd_res_cnt_tbl(11) := GREATEST (l_gl_pd_res_cnt_tbl(6), NVL(l_gl_pd_res_cnt_tbl(11),0));
				l_gl_pd_res_cnt_tbl(12) := GREATEST (l_gl_pd_res_cnt_tbl(7), NVL(l_gl_pd_res_cnt_tbl(12),0));
				l_gl_pd_res_cnt_tbl(13) := GREATEST (l_gl_pd_res_cnt_tbl(8), NVL(l_gl_pd_res_cnt_tbl(13),0));
				l_gl_pd_res_cnt_tbl(14) := GREATEST (l_gl_pd_res_cnt_tbl(9), NVL(l_gl_pd_res_cnt_tbl(14),0));
				l_gl_pd_res_cnt_tbl(15) := GREATEST (l_gl_pd_res_cnt_tbl(10), NVL(l_gl_pd_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and GL PERIOD in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_gl_period_id,
					p_curr_pd		=> l_gl_period_id,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_gl_pd,
					p_period_type_id	=> 32,
					p_calendar_type		=> 'G',
					p_res_cnt_tbl		=> l_gl_pd_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_gl_period_id = l_old_gl_period_id) THEN
					l_gl_pd_org_change_flag	:= 'Y';
				ELSE
					l_gl_pd_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_gl_pd_res_cnt_tbl.FIRST.. l_gl_pd_res_cnt_tbl.LAST
				LOOP
					l_gl_pd_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_gl_pd_res_cnt_tbl(1)	:= NVL(l_gl_pd_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_gl_pd_res_cnt_tbl(2)	:= NVL(l_gl_pd_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_gl_pd_res_cnt_tbl(3)	:= NVL(l_gl_pd_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_gl_pd_res_cnt_tbl(4)	:= NVL(l_gl_pd_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_gl_pd_res_cnt_tbl(5)	:= NVL(l_gl_pd_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_gl_pd_res_cnt_tbl(6)	:= NVL(l_gl_pd_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_gl_pd_res_cnt_tbl(7)	:= NVL(l_gl_pd_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_gl_pd_res_cnt_tbl(8)	:= NVL(l_gl_pd_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_gl_pd_res_cnt_tbl(9)	:= NVL(l_gl_pd_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_gl_pd_res_cnt_tbl(10):= NVL(l_gl_pd_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_gl_pd_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_gl_pd_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_gl_pd := l_time_id;
			ELSIF (l_gl_pd_count = 0) THEN
			BEGIN
				SELECT to_char(fiit.start_date,'j')
				INTO l_start_date_org_gl_pd
				FROM fii_time_cal_period fiit
				WHERE cal_period_id = l_gl_period_id;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_gl_pd_res_cnt_tbl
			);
			--Assigning current GL PERIOD id to
			--old period id local variable
			l_old_gl_period_id 	:= l_gl_period_id;
			l_gl_pd_count		:= l_gl_pd_count + 1;
			l_gl_pd_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for GL PERIOD */

		--For GL QUARTER
		IF (l_gl_qtr_id <> 0 AND l_gl_qtr_id IS NOT NULL) THEN
			IF (l_old_gl_qtr_id < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_gl_qtr_id <> l_old_gl_qtr_id
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this GL QUARTER
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_gl_qtr_res_cnt_tbl(11) := GREATEST (l_gl_qtr_res_cnt_tbl(6), NVL(l_gl_qtr_res_cnt_tbl(11),0));
				l_gl_qtr_res_cnt_tbl(12) := GREATEST (l_gl_qtr_res_cnt_tbl(7), NVL(l_gl_qtr_res_cnt_tbl(12),0));
				l_gl_qtr_res_cnt_tbl(13) := GREATEST (l_gl_qtr_res_cnt_tbl(8), NVL(l_gl_qtr_res_cnt_tbl(13),0));
				l_gl_qtr_res_cnt_tbl(14) := GREATEST (l_gl_qtr_res_cnt_tbl(9), NVL(l_gl_qtr_res_cnt_tbl(14),0));
				l_gl_qtr_res_cnt_tbl(15) := GREATEST (l_gl_qtr_res_cnt_tbl(10), NVL(l_gl_qtr_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and GL QUARTER in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_gl_qtr_id,
					p_curr_pd		=> l_gl_qtr_id,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_gl_qtr,
					p_period_type_id	=> 64,
					p_calendar_type		=> 'G',
					p_res_cnt_tbl		=> l_gl_qtr_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_gl_qtr_id = l_old_gl_qtr_id) THEN
					l_gl_qtr_org_change_flag	:= 'Y';
				ELSE
					l_gl_qtr_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_gl_qtr_res_cnt_tbl.FIRST.. l_gl_qtr_res_cnt_tbl.LAST
				LOOP
					l_gl_qtr_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_gl_qtr_res_cnt_tbl(1)	:= NVL(l_gl_qtr_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_gl_qtr_res_cnt_tbl(2)	:= NVL(l_gl_qtr_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_gl_qtr_res_cnt_tbl(3)	:= NVL(l_gl_qtr_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_gl_qtr_res_cnt_tbl(4)	:= NVL(l_gl_qtr_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_gl_qtr_res_cnt_tbl(5)	:= NVL(l_gl_qtr_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_gl_qtr_res_cnt_tbl(6)	:= NVL(l_gl_qtr_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_gl_qtr_res_cnt_tbl(7)	:= NVL(l_gl_qtr_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_gl_qtr_res_cnt_tbl(8)	:= NVL(l_gl_qtr_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_gl_qtr_res_cnt_tbl(9)	:= NVL(l_gl_qtr_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_gl_qtr_res_cnt_tbl(10):= NVL(l_gl_qtr_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_gl_qtr_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_gl_qtr_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_gl_qtr := l_time_id;
			ELSIF (l_gl_qtr_count = 0) THEN
			BEGIN
				SELECT to_char(fiit.start_date,'j')
				INTO l_start_date_org_gl_qtr
				FROM fii_time_cal_qtr fiit
				WHERE cal_qtr_id = l_gl_qtr_id;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_gl_qtr_res_cnt_tbl
			);
			--Assigning current GL QUARTER id to
			--old period id local variable
			l_old_gl_qtr_id 	:= l_gl_qtr_id;
			l_gl_qtr_count		:= l_gl_qtr_count + 1;
			l_gl_qtr_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for GL QUARTER */

		-- For ROLLING WEEK 1
		IF (l_roll_x_week1 > 0 AND l_roll_x_week1 IS NOT NULL) THEN
			IF (l_old_roll_x_week1 < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_roll_x_week1 <> l_old_roll_x_week1
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this ROLLING WEEK 1
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_roll_x_wk1_res_cnt_tbl(11) := GREATEST (l_roll_x_wk1_res_cnt_tbl(6), NVL(l_roll_x_wk1_res_cnt_tbl(11),0));
				l_roll_x_wk1_res_cnt_tbl(12) := GREATEST (l_roll_x_wk1_res_cnt_tbl(7), NVL(l_roll_x_wk1_res_cnt_tbl(12),0));
				l_roll_x_wk1_res_cnt_tbl(13) := GREATEST (l_roll_x_wk1_res_cnt_tbl(8), NVL(l_roll_x_wk1_res_cnt_tbl(13),0));
				l_roll_x_wk1_res_cnt_tbl(14) := GREATEST (l_roll_x_wk1_res_cnt_tbl(9), NVL(l_roll_x_wk1_res_cnt_tbl(14),0));
				l_roll_x_wk1_res_cnt_tbl(15) := GREATEST (l_roll_x_wk1_res_cnt_tbl(10), NVL(l_roll_x_wk1_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and ROLLING WEEK 1 in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_roll_x_week1,
					p_curr_pd		=> l_roll_x_week1,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_roll_x_wk1,
					p_period_type_id	=> 16,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_roll_x_wk1_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_roll_x_week1 = l_old_roll_x_week1) THEN
					l_roll_x_wk1_org_change_flag	:= 'Y';
				ELSE
					l_roll_x_wk1_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_roll_x_wk1_res_cnt_tbl.FIRST.. l_roll_x_wk1_res_cnt_tbl.LAST
				LOOP
					l_roll_x_wk1_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_roll_x_wk1_res_cnt_tbl(1)	:= NVL(l_roll_x_wk1_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_roll_x_wk1_res_cnt_tbl(2)	:= NVL(l_roll_x_wk1_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_roll_x_wk1_res_cnt_tbl(3)	:= NVL(l_roll_x_wk1_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_roll_x_wk1_res_cnt_tbl(4)	:= NVL(l_roll_x_wk1_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_roll_x_wk1_res_cnt_tbl(5)	:= NVL(l_roll_x_wk1_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_roll_x_wk1_res_cnt_tbl(6)	:= NVL(l_roll_x_wk1_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_roll_x_wk1_res_cnt_tbl(7)	:= NVL(l_roll_x_wk1_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_roll_x_wk1_res_cnt_tbl(8)	:= NVL(l_roll_x_wk1_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_roll_x_wk1_res_cnt_tbl(9)	:= NVL(l_roll_x_wk1_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_roll_x_wk1_res_cnt_tbl(10):= NVL(l_roll_x_wk1_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_roll_x_wk1_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_roll_x_wk1_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_roll_x_wk1 := l_time_id;
			ELSIF (l_roll_x_wk1_count = 0) THEN
			BEGIN
				 SELECT to_char(fiit.start_date,'j')
				 INTO l_start_date_org_roll_x_wk1
				 FROM FII_TIME_WEEK fiit
				 WHERE fiit.start_date = to_date(to_char(((l_roll_x_week1 - 1) * 7) +    -- Bug#4903567
				 g_min_wk_j_st_date), 'J');
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_roll_x_wk1_res_cnt_tbl
			);
			--Assigning current ROLLING WEEK 1 id to
			--old period id local variable
			l_old_roll_x_week1 	:= l_roll_x_week1;
			l_roll_x_wk1_count	:= l_roll_x_wk1_count + 1;
			l_roll_x_wk1_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for ROLLING WEEK 1 */

      		-- For ROLLING WEEK 2
		IF (l_roll_x_week2 > 0 AND l_roll_x_week2 IS NOT NULL) THEN
			IF (l_old_roll_x_week2 < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_roll_x_week2 <> l_old_roll_x_week2
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this ROLLING WEEK 2
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_roll_x_wk2_res_cnt_tbl(11) := GREATEST (l_roll_x_wk2_res_cnt_tbl(6), NVL(l_roll_x_wk2_res_cnt_tbl(11),0));
				l_roll_x_wk2_res_cnt_tbl(12) := GREATEST (l_roll_x_wk2_res_cnt_tbl(7), NVL(l_roll_x_wk2_res_cnt_tbl(12),0));
				l_roll_x_wk2_res_cnt_tbl(13) := GREATEST (l_roll_x_wk2_res_cnt_tbl(8), NVL(l_roll_x_wk2_res_cnt_tbl(13),0));
				l_roll_x_wk2_res_cnt_tbl(14) := GREATEST (l_roll_x_wk2_res_cnt_tbl(9), NVL(l_roll_x_wk2_res_cnt_tbl(14),0));
				l_roll_x_wk2_res_cnt_tbl(15) := GREATEST (l_roll_x_wk2_res_cnt_tbl(10), NVL(l_roll_x_wk2_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and ROLLING WEEK 2 in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_roll_x_week2,
					p_curr_pd		=> l_roll_x_week2,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_roll_x_wk2,
					p_period_type_id	=> 16,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_roll_x_wk2_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_roll_x_week2 = l_old_roll_x_week2) THEN
					l_roll_x_wk2_org_change_flag	:= 'Y';
				ELSE
					l_roll_x_wk2_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_roll_x_wk2_res_cnt_tbl.FIRST.. l_roll_x_wk2_res_cnt_tbl.LAST
				LOOP
					l_roll_x_wk2_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_roll_x_wk2_res_cnt_tbl(1)	:= NVL(l_roll_x_wk2_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_roll_x_wk2_res_cnt_tbl(2)	:= NVL(l_roll_x_wk2_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_roll_x_wk2_res_cnt_tbl(3)	:= NVL(l_roll_x_wk2_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_roll_x_wk2_res_cnt_tbl(4)	:= NVL(l_roll_x_wk2_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_roll_x_wk2_res_cnt_tbl(5)	:= NVL(l_roll_x_wk2_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_roll_x_wk2_res_cnt_tbl(6)	:= NVL(l_roll_x_wk2_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_roll_x_wk2_res_cnt_tbl(7)	:= NVL(l_roll_x_wk2_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_roll_x_wk2_res_cnt_tbl(8)	:= NVL(l_roll_x_wk2_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_roll_x_wk2_res_cnt_tbl(9)	:= NVL(l_roll_x_wk2_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_roll_x_wk2_res_cnt_tbl(10):= NVL(l_roll_x_wk2_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_roll_x_wk2_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_roll_x_wk2_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_roll_x_wk2 := l_time_id;
			ELSIF (l_roll_x_wk2_count = 0) THEN
			BEGIN
				 SELECT to_char(fiit.start_date,'j')
				 INTO l_start_date_org_roll_x_wk2
				 FROM FII_TIME_WEEK fiit
				 WHERE fiit.start_date = to_date(to_char(((l_roll_x_week2 - 1) * 7) +      -- Bug#4903567
				 g_min_wk_j_st_date), 'J');
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_roll_x_wk2_res_cnt_tbl
			);
			--Assigning current ROLLING WEEK 2 id to
			--old period id local variable
			l_old_roll_x_week2 	:= l_roll_x_week2;
			l_roll_x_wk2_count	:= l_roll_x_wk2_count + 1;
			l_roll_x_wk2_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for ROLLING WEEK 2 */

      		-- For ROLLING WEEK 3
		IF (l_roll_x_week3 > 0 AND l_roll_x_week3 IS NOT NULL) THEN
			IF (l_old_roll_x_week3 < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_roll_x_week3 <> l_old_roll_x_week3
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this ROLLING WEEK 3
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_roll_x_wk3_res_cnt_tbl(11) := GREATEST (l_roll_x_wk3_res_cnt_tbl(6), NVL(l_roll_x_wk3_res_cnt_tbl(11),0));
				l_roll_x_wk3_res_cnt_tbl(12) := GREATEST (l_roll_x_wk3_res_cnt_tbl(7), NVL(l_roll_x_wk3_res_cnt_tbl(12),0));
				l_roll_x_wk3_res_cnt_tbl(13) := GREATEST (l_roll_x_wk3_res_cnt_tbl(8), NVL(l_roll_x_wk3_res_cnt_tbl(13),0));
				l_roll_x_wk3_res_cnt_tbl(14) := GREATEST (l_roll_x_wk3_res_cnt_tbl(9), NVL(l_roll_x_wk3_res_cnt_tbl(14),0));
				l_roll_x_wk3_res_cnt_tbl(15) := GREATEST (l_roll_x_wk3_res_cnt_tbl(10), NVL(l_roll_x_wk3_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and ROLLING WEEK 3 in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_roll_x_week3,
					p_curr_pd		=> l_roll_x_week3,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_roll_x_wk3,
					p_period_type_id	=> 16,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_roll_x_wk3_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_roll_x_week3 = l_old_roll_x_week3) THEN
					l_roll_x_wk3_org_change_flag	:= 'Y';
				ELSE
					l_roll_x_wk3_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_roll_x_wk3_res_cnt_tbl.FIRST.. l_roll_x_wk3_res_cnt_tbl.LAST
				LOOP
					l_roll_x_wk3_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_roll_x_wk3_res_cnt_tbl(1)	:= NVL(l_roll_x_wk3_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_roll_x_wk3_res_cnt_tbl(2)	:= NVL(l_roll_x_wk3_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_roll_x_wk3_res_cnt_tbl(3)	:= NVL(l_roll_x_wk3_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_roll_x_wk3_res_cnt_tbl(4)	:= NVL(l_roll_x_wk3_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_roll_x_wk3_res_cnt_tbl(5)	:= NVL(l_roll_x_wk3_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_roll_x_wk3_res_cnt_tbl(6)	:= NVL(l_roll_x_wk3_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_roll_x_wk3_res_cnt_tbl(7)	:= NVL(l_roll_x_wk3_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_roll_x_wk3_res_cnt_tbl(8)	:= NVL(l_roll_x_wk3_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_roll_x_wk3_res_cnt_tbl(9)	:= NVL(l_roll_x_wk3_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_roll_x_wk3_res_cnt_tbl(10):= NVL(l_roll_x_wk3_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_roll_x_wk3_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_roll_x_wk3_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_roll_x_wk3 := l_time_id;
			ELSIF (l_roll_x_wk3_count = 0) THEN
			BEGIN
				 SELECT to_char(fiit.start_date,'j')
				 INTO l_start_date_org_roll_x_wk3
				 FROM FII_TIME_WEEK fiit
				 WHERE fiit.start_date = to_date(to_char(((l_roll_x_week3 - 1) * 7) +       -- Bug#4903567
				 g_min_wk_j_st_date), 'J');
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_roll_x_wk3_res_cnt_tbl
			);
			--Assigning current ROLLING WEEK 3 id to
			--old period id local variable
			l_old_roll_x_week3 	:= l_roll_x_week3;
			l_roll_x_wk3_count	:= l_roll_x_wk3_count + 1;
			l_roll_x_wk3_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for ROLLING WEEK 3 */

      		-- For ROLLING WEEK 4
		IF (l_roll_x_week4 > 0 AND l_roll_x_week4 IS NOT NULL) THEN
			IF (l_old_roll_x_week4 < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_roll_x_week4 <> l_old_roll_x_week4
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this ROLLING WEEK 4
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_roll_x_wk4_res_cnt_tbl(11) := GREATEST (l_roll_x_wk4_res_cnt_tbl(6), NVL(l_roll_x_wk4_res_cnt_tbl(11),0));
				l_roll_x_wk4_res_cnt_tbl(12) := GREATEST (l_roll_x_wk4_res_cnt_tbl(7), NVL(l_roll_x_wk4_res_cnt_tbl(12),0));
				l_roll_x_wk4_res_cnt_tbl(13) := GREATEST (l_roll_x_wk4_res_cnt_tbl(8), NVL(l_roll_x_wk4_res_cnt_tbl(13),0));
				l_roll_x_wk4_res_cnt_tbl(14) := GREATEST (l_roll_x_wk4_res_cnt_tbl(9), NVL(l_roll_x_wk4_res_cnt_tbl(14),0));
				l_roll_x_wk4_res_cnt_tbl(15) := GREATEST (l_roll_x_wk4_res_cnt_tbl(10), NVL(l_roll_x_wk4_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and ROLLING WEEK 4 in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_roll_x_week4,
					p_curr_pd		=> l_roll_x_week4,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_roll_x_wk4,
					p_period_type_id	=> 16,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_roll_x_wk4_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_roll_x_week4 = l_old_roll_x_week4) THEN
					l_roll_x_wk4_org_change_flag	:= 'Y';
				ELSE
					l_roll_x_wk4_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_roll_x_wk4_res_cnt_tbl.FIRST.. l_roll_x_wk4_res_cnt_tbl.LAST
				LOOP
					l_roll_x_wk4_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_roll_x_wk4_res_cnt_tbl(1)	:= NVL(l_roll_x_wk4_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_roll_x_wk4_res_cnt_tbl(2)	:= NVL(l_roll_x_wk4_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_roll_x_wk4_res_cnt_tbl(3)	:= NVL(l_roll_x_wk4_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_roll_x_wk4_res_cnt_tbl(4)	:= NVL(l_roll_x_wk4_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_roll_x_wk4_res_cnt_tbl(5)	:= NVL(l_roll_x_wk4_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_roll_x_wk4_res_cnt_tbl(6)	:= NVL(l_roll_x_wk4_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_roll_x_wk4_res_cnt_tbl(7)	:= NVL(l_roll_x_wk4_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_roll_x_wk4_res_cnt_tbl(8)	:= NVL(l_roll_x_wk4_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_roll_x_wk4_res_cnt_tbl(9)	:= NVL(l_roll_x_wk4_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_roll_x_wk4_res_cnt_tbl(10):= NVL(l_roll_x_wk4_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_roll_x_wk4_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_roll_x_wk4_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_roll_x_wk4 := l_time_id;
			ELSIF (l_roll_x_wk4_count = 0) THEN
			BEGIN
				 SELECT to_char(fiit.start_date,'j')
				 INTO l_start_date_org_roll_x_wk4
				 FROM FII_TIME_WEEK fiit
				 WHERE fiit.start_date = to_date(to_char(((l_roll_x_week4 - 1) * 7) +      -- Bug#4903567
				 g_min_wk_j_st_date), 'J');
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_roll_x_wk4_res_cnt_tbl
			);
			--Assigning current ROLLING WEEK 4 id to
			--old period id local variable
			l_old_roll_x_week4 	:= l_roll_x_week4;
			l_roll_x_wk4_count	:= l_roll_x_wk4_count + 1;
			l_roll_x_wk4_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for ROLLING WEEK 4 */

      		-- For ROLLING WEEK 5
		IF (l_roll_x_week5 > 0 AND l_roll_x_week5 IS NOT NULL) THEN
			IF (l_old_roll_x_week5 < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_roll_x_week5 <> l_old_roll_x_week5
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this ROLLING WEEK 5
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_roll_x_wk5_res_cnt_tbl(11) := GREATEST (l_roll_x_wk5_res_cnt_tbl(6), NVL(l_roll_x_wk5_res_cnt_tbl(11),0));
				l_roll_x_wk5_res_cnt_tbl(12) := GREATEST (l_roll_x_wk5_res_cnt_tbl(7), NVL(l_roll_x_wk5_res_cnt_tbl(12),0));
				l_roll_x_wk5_res_cnt_tbl(13) := GREATEST (l_roll_x_wk5_res_cnt_tbl(8), NVL(l_roll_x_wk5_res_cnt_tbl(13),0));
				l_roll_x_wk5_res_cnt_tbl(14) := GREATEST (l_roll_x_wk5_res_cnt_tbl(9), NVL(l_roll_x_wk5_res_cnt_tbl(14),0));
				l_roll_x_wk5_res_cnt_tbl(15) := GREATEST (l_roll_x_wk5_res_cnt_tbl(10), NVL(l_roll_x_wk5_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and ROLLING WEEK 5 in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_roll_x_week5,
					p_curr_pd		=> l_roll_x_week5,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_roll_x_wk5,
					p_period_type_id	=> 16,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_roll_x_wk5_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_roll_x_week5 = l_old_roll_x_week5) THEN
					l_roll_x_wk5_org_change_flag	:= 'Y';
				ELSE
					l_roll_x_wk5_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_roll_x_wk5_res_cnt_tbl.FIRST.. l_roll_x_wk5_res_cnt_tbl.LAST
				LOOP
					l_roll_x_wk5_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_roll_x_wk5_res_cnt_tbl(1)	:= NVL(l_roll_x_wk5_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_roll_x_wk5_res_cnt_tbl(2)	:= NVL(l_roll_x_wk5_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_roll_x_wk5_res_cnt_tbl(3)	:= NVL(l_roll_x_wk5_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_roll_x_wk5_res_cnt_tbl(4)	:= NVL(l_roll_x_wk5_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_roll_x_wk5_res_cnt_tbl(5)	:= NVL(l_roll_x_wk5_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_roll_x_wk5_res_cnt_tbl(6)	:= NVL(l_roll_x_wk5_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_roll_x_wk5_res_cnt_tbl(7)	:= NVL(l_roll_x_wk5_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_roll_x_wk5_res_cnt_tbl(8)	:= NVL(l_roll_x_wk5_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_roll_x_wk5_res_cnt_tbl(9)	:= NVL(l_roll_x_wk5_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_roll_x_wk5_res_cnt_tbl(10):= NVL(l_roll_x_wk5_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_roll_x_wk5_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_roll_x_wk5_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_roll_x_wk5 := l_time_id;
			ELSIF (l_roll_x_wk5_count = 0) THEN
			BEGIN
				 SELECT to_char(fiit.start_date,'j')
				 INTO l_start_date_org_roll_x_wk5
				 FROM FII_TIME_WEEK fiit
				 WHERE fiit.start_date = to_date(to_char(((l_roll_x_week5 - 1) * 7) +      -- Bug#4903567
				 g_min_wk_j_st_date), 'J');
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_roll_x_wk5_res_cnt_tbl
			);
			--Assigning current ROLLING WEEK 5 id to
			--old period id local variable
			l_old_roll_x_week5 	:= l_roll_x_week5;
			l_roll_x_wk5_count	:= l_roll_x_wk5_count + 1;
			l_roll_x_wk5_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for ROLLING WEEK 5 */

      		-- For ROLLING WEEK 6
		IF (l_roll_x_week6 > 0 AND l_roll_x_week6 IS NOT NULL) THEN
			IF (l_old_roll_x_week6 < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_roll_x_week6 <> l_old_roll_x_week6
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this ROLLING WEEK 6
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_roll_x_wk6_res_cnt_tbl(11) := GREATEST (l_roll_x_wk6_res_cnt_tbl(6), NVL(l_roll_x_wk6_res_cnt_tbl(11),0));
				l_roll_x_wk6_res_cnt_tbl(12) := GREATEST (l_roll_x_wk6_res_cnt_tbl(7), NVL(l_roll_x_wk6_res_cnt_tbl(12),0));
				l_roll_x_wk6_res_cnt_tbl(13) := GREATEST (l_roll_x_wk6_res_cnt_tbl(8), NVL(l_roll_x_wk6_res_cnt_tbl(13),0));
				l_roll_x_wk6_res_cnt_tbl(14) := GREATEST (l_roll_x_wk6_res_cnt_tbl(9), NVL(l_roll_x_wk6_res_cnt_tbl(14),0));
				l_roll_x_wk6_res_cnt_tbl(15) := GREATEST (l_roll_x_wk6_res_cnt_tbl(10), NVL(l_roll_x_wk6_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and ROLLING WEEK 6 in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_roll_x_week6,
					p_curr_pd		=> l_roll_x_week6,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_roll_x_wk6,
					p_period_type_id	=> 16,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_roll_x_wk6_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_roll_x_week6 = l_old_roll_x_week6) THEN
					l_roll_x_wk6_org_change_flag	:= 'Y';
				ELSE
					l_roll_x_wk6_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_roll_x_wk6_res_cnt_tbl.FIRST.. l_roll_x_wk6_res_cnt_tbl.LAST
				LOOP
					l_roll_x_wk6_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_roll_x_wk6_res_cnt_tbl(1)	:= NVL(l_roll_x_wk6_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_roll_x_wk6_res_cnt_tbl(2)	:= NVL(l_roll_x_wk6_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_roll_x_wk6_res_cnt_tbl(3)	:= NVL(l_roll_x_wk6_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_roll_x_wk6_res_cnt_tbl(4)	:= NVL(l_roll_x_wk6_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_roll_x_wk6_res_cnt_tbl(5)	:= NVL(l_roll_x_wk6_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_roll_x_wk6_res_cnt_tbl(6)	:= NVL(l_roll_x_wk6_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_roll_x_wk6_res_cnt_tbl(7)	:= NVL(l_roll_x_wk6_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_roll_x_wk6_res_cnt_tbl(8)	:= NVL(l_roll_x_wk6_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_roll_x_wk6_res_cnt_tbl(9)	:= NVL(l_roll_x_wk6_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_roll_x_wk6_res_cnt_tbl(10):= NVL(l_roll_x_wk6_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_roll_x_wk6_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_roll_x_wk6_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_roll_x_wk6 := l_time_id;
			ELSIF (l_roll_x_wk6_count = 0) THEN
			BEGIN
				 SELECT to_char(fiit.start_date,'j')
				 INTO l_start_date_org_roll_x_wk6
				 FROM FII_TIME_WEEK fiit
				 WHERE fiit.start_date = to_date(to_char(((l_roll_x_week6 - 1) * 7) +      -- Bug#4903567
				 g_min_wk_j_st_date), 'J');
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_roll_x_wk6_res_cnt_tbl
			);
			--Assigning current ROLLING WEEK 6 id to
			--old period id local variable
			l_old_roll_x_week6 	:= l_roll_x_week6;
			l_roll_x_wk6_count	:= l_roll_x_wk6_count + 1;
			l_roll_x_wk6_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for ROLLING WEEK 6 */

      		-- For ROLLING WEEK 7
		IF (l_roll_x_week7 > 0 AND l_roll_x_week7 IS NOT NULL) THEN
			IF (l_old_roll_x_week7 < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_roll_x_week7 <> l_old_roll_x_week7
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this ROLLING WEEK 7
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_roll_x_wk7_res_cnt_tbl(11) := GREATEST (l_roll_x_wk7_res_cnt_tbl(6), NVL(l_roll_x_wk7_res_cnt_tbl(11),0));
				l_roll_x_wk7_res_cnt_tbl(12) := GREATEST (l_roll_x_wk7_res_cnt_tbl(7), NVL(l_roll_x_wk7_res_cnt_tbl(12),0));
				l_roll_x_wk7_res_cnt_tbl(13) := GREATEST (l_roll_x_wk7_res_cnt_tbl(8), NVL(l_roll_x_wk7_res_cnt_tbl(13),0));
				l_roll_x_wk7_res_cnt_tbl(14) := GREATEST (l_roll_x_wk7_res_cnt_tbl(9), NVL(l_roll_x_wk7_res_cnt_tbl(14),0));
				l_roll_x_wk7_res_cnt_tbl(15) := GREATEST (l_roll_x_wk7_res_cnt_tbl(10), NVL(l_roll_x_wk7_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and ROLLING WEEK 7 in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_roll_x_week7,
					p_curr_pd		=> l_roll_x_week7,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_roll_x_wk7,
					p_period_type_id	=> 16,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_roll_x_wk7_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_roll_x_week7 = l_old_roll_x_week7) THEN
					l_roll_x_wk7_org_change_flag	:= 'Y';
				ELSE
					l_roll_x_wk7_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_roll_x_wk7_res_cnt_tbl.FIRST.. l_roll_x_wk7_res_cnt_tbl.LAST
				LOOP
					l_roll_x_wk7_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_roll_x_wk7_res_cnt_tbl(1)	:= NVL(l_roll_x_wk7_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_roll_x_wk7_res_cnt_tbl(2)	:= NVL(l_roll_x_wk7_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_roll_x_wk7_res_cnt_tbl(3)	:= NVL(l_roll_x_wk7_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_roll_x_wk7_res_cnt_tbl(4)	:= NVL(l_roll_x_wk7_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_roll_x_wk7_res_cnt_tbl(5)	:= NVL(l_roll_x_wk7_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_roll_x_wk7_res_cnt_tbl(6)	:= NVL(l_roll_x_wk7_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_roll_x_wk7_res_cnt_tbl(7)	:= NVL(l_roll_x_wk7_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_roll_x_wk7_res_cnt_tbl(8)	:= NVL(l_roll_x_wk7_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_roll_x_wk7_res_cnt_tbl(9)	:= NVL(l_roll_x_wk7_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_roll_x_wk7_res_cnt_tbl(10):= NVL(l_roll_x_wk7_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_roll_x_wk7_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_roll_x_wk7_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_roll_x_wk7 := l_time_id;
			ELSIF (l_roll_x_wk7_count = 0) THEN
			BEGIN
				 SELECT to_char(fiit.start_date,'j')
				 INTO l_start_date_org_roll_x_wk7
				 FROM FII_TIME_WEEK fiit
				 WHERE fiit.start_date = to_date(to_char(((l_roll_x_week7 - 1) * 7) +      -- Bug#4903567
				 g_min_wk_j_st_date), 'J');
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_roll_x_wk7_res_cnt_tbl
			);
			--Assigning current ROLLING WEEK 7 id to
			--old period id local variable
			l_old_roll_x_week7 	:= l_roll_x_week7;
			l_roll_x_wk7_count	:= l_roll_x_wk7_count + 1;
			l_roll_x_wk7_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for ROLLING WEEK 7 */

      		-- For ROLLING WEEK 8
		IF (l_roll_x_week8 > 0 AND l_roll_x_week8 IS NOT NULL) THEN
			IF (l_old_roll_x_week8 < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_roll_x_week8 <> l_old_roll_x_week8
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this ROLLING WEEK 8
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_roll_x_wk8_res_cnt_tbl(11) := GREATEST (l_roll_x_wk8_res_cnt_tbl(6), NVL(l_roll_x_wk8_res_cnt_tbl(11),0));
				l_roll_x_wk8_res_cnt_tbl(12) := GREATEST (l_roll_x_wk8_res_cnt_tbl(7), NVL(l_roll_x_wk8_res_cnt_tbl(12),0));
				l_roll_x_wk8_res_cnt_tbl(13) := GREATEST (l_roll_x_wk8_res_cnt_tbl(8), NVL(l_roll_x_wk8_res_cnt_tbl(13),0));
				l_roll_x_wk8_res_cnt_tbl(14) := GREATEST (l_roll_x_wk8_res_cnt_tbl(9), NVL(l_roll_x_wk8_res_cnt_tbl(14),0));
				l_roll_x_wk8_res_cnt_tbl(15) := GREATEST (l_roll_x_wk8_res_cnt_tbl(10), NVL(l_roll_x_wk8_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and ROLLING WEEK 8 in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_roll_x_week8,
					p_curr_pd		=> l_roll_x_week8,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_roll_x_wk8,
					p_period_type_id	=> 16,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_roll_x_wk8_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_roll_x_week8 = l_old_roll_x_week8) THEN
					l_roll_x_wk8_org_change_flag	:= 'Y';
				ELSE
					l_roll_x_wk8_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_roll_x_wk8_res_cnt_tbl.FIRST.. l_roll_x_wk8_res_cnt_tbl.LAST
				LOOP
					l_roll_x_wk8_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_roll_x_wk8_res_cnt_tbl(1)	:= NVL(l_roll_x_wk8_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_roll_x_wk8_res_cnt_tbl(2)	:= NVL(l_roll_x_wk8_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_roll_x_wk8_res_cnt_tbl(3)	:= NVL(l_roll_x_wk8_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_roll_x_wk8_res_cnt_tbl(4)	:= NVL(l_roll_x_wk8_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_roll_x_wk8_res_cnt_tbl(5)	:= NVL(l_roll_x_wk8_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_roll_x_wk8_res_cnt_tbl(6)	:= NVL(l_roll_x_wk8_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_roll_x_wk8_res_cnt_tbl(7)	:= NVL(l_roll_x_wk8_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_roll_x_wk8_res_cnt_tbl(8)	:= NVL(l_roll_x_wk8_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_roll_x_wk8_res_cnt_tbl(9)	:= NVL(l_roll_x_wk8_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_roll_x_wk8_res_cnt_tbl(10):= NVL(l_roll_x_wk8_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_roll_x_wk8_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_roll_x_wk8_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_roll_x_wk8 := l_time_id;
			ELSIF (l_roll_x_wk8_count = 0) THEN
			BEGIN
				 SELECT to_char(fiit.start_date,'j')
				 INTO l_start_date_org_roll_x_wk8
				 FROM FII_TIME_WEEK fiit
				 WHERE fiit.start_date = to_date(to_char(((l_roll_x_week8 - 1) * 7) +      -- Bug#4903567
				 g_min_wk_j_st_date), 'J');
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_roll_x_wk8_res_cnt_tbl
			);
			--Assigning current ROLLING WEEK 8 id to
			--old period id local variable
			l_old_roll_x_week8 	:= l_roll_x_week8;
			l_roll_x_wk8_count	:= l_roll_x_wk8_count + 1;
			l_roll_x_wk8_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for ROLLING WEEK 8 */

      		-- For ROLLING WEEK 9
		IF (l_roll_x_week9 > 0 AND l_roll_x_week9 IS NOT NULL) THEN
			IF (l_old_roll_x_week9 < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_roll_x_week9 <> l_old_roll_x_week9
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this ROLLING WEEK 9
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_roll_x_wk9_res_cnt_tbl(11) := GREATEST (l_roll_x_wk9_res_cnt_tbl(6), NVL(l_roll_x_wk9_res_cnt_tbl(11),0));
				l_roll_x_wk9_res_cnt_tbl(12) := GREATEST (l_roll_x_wk9_res_cnt_tbl(7), NVL(l_roll_x_wk9_res_cnt_tbl(12),0));
				l_roll_x_wk9_res_cnt_tbl(13) := GREATEST (l_roll_x_wk9_res_cnt_tbl(8), NVL(l_roll_x_wk9_res_cnt_tbl(13),0));
				l_roll_x_wk9_res_cnt_tbl(14) := GREATEST (l_roll_x_wk9_res_cnt_tbl(9), NVL(l_roll_x_wk9_res_cnt_tbl(14),0));
				l_roll_x_wk9_res_cnt_tbl(15) := GREATEST (l_roll_x_wk9_res_cnt_tbl(10), NVL(l_roll_x_wk9_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and ROLLING WEEK 9 in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_roll_x_week9,
					p_curr_pd		=> l_roll_x_week9,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_roll_x_wk9,
					p_period_type_id	=> 16,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_roll_x_wk9_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_roll_x_week9 = l_old_roll_x_week9) THEN
					l_roll_x_wk9_org_change_flag	:= 'Y';
				ELSE
					l_roll_x_wk9_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_roll_x_wk9_res_cnt_tbl.FIRST.. l_roll_x_wk9_res_cnt_tbl.LAST
				LOOP
					l_roll_x_wk9_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_roll_x_wk9_res_cnt_tbl(1)	:= NVL(l_roll_x_wk9_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_roll_x_wk9_res_cnt_tbl(2)	:= NVL(l_roll_x_wk9_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_roll_x_wk9_res_cnt_tbl(3)	:= NVL(l_roll_x_wk9_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_roll_x_wk9_res_cnt_tbl(4)	:= NVL(l_roll_x_wk9_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_roll_x_wk9_res_cnt_tbl(5)	:= NVL(l_roll_x_wk9_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_roll_x_wk9_res_cnt_tbl(6)	:= NVL(l_roll_x_wk9_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_roll_x_wk9_res_cnt_tbl(7)	:= NVL(l_roll_x_wk9_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_roll_x_wk9_res_cnt_tbl(8)	:= NVL(l_roll_x_wk9_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_roll_x_wk9_res_cnt_tbl(9)	:= NVL(l_roll_x_wk9_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_roll_x_wk9_res_cnt_tbl(10):= NVL(l_roll_x_wk9_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_roll_x_wk9_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_roll_x_wk9_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_roll_x_wk9 := l_time_id;
			ELSIF (l_roll_x_wk9_count = 0) THEN
			BEGIN
				 SELECT to_char(fiit.start_date,'j')
				 INTO l_start_date_org_roll_x_wk9
				 FROM FII_TIME_WEEK fiit
				 WHERE fiit.start_date = to_date(to_char(((l_roll_x_week9 - 1) * 7) +      -- Bug#4903567
				 g_min_wk_j_st_date), 'J');
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_roll_x_wk9_res_cnt_tbl
			);
			--Assigning current ROLLING WEEK 9 id to
			--old period id local variable
			l_old_roll_x_week9 	:= l_roll_x_week9;
			l_roll_x_wk9_count	:= l_roll_x_wk9_count + 1;
			l_roll_x_wk9_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for ROLLING WEEK 9 */

      		-- For ROLLING WEEK 10
		IF (l_roll_x_week10 > 0 AND l_roll_x_week10 IS NOT NULL) THEN
			IF (l_old_roll_x_week10 < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_roll_x_week10 <> l_old_roll_x_week10
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this ROLLING WEEK 10
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_roll_x_wk10_res_cnt_tbl(11) := GREATEST (l_roll_x_wk10_res_cnt_tbl(6), NVL(l_roll_x_wk10_res_cnt_tbl(11),0));
				l_roll_x_wk10_res_cnt_tbl(12) := GREATEST (l_roll_x_wk10_res_cnt_tbl(7), NVL(l_roll_x_wk10_res_cnt_tbl(12),0));
				l_roll_x_wk10_res_cnt_tbl(13) := GREATEST (l_roll_x_wk10_res_cnt_tbl(8), NVL(l_roll_x_wk10_res_cnt_tbl(13),0));
				l_roll_x_wk10_res_cnt_tbl(14) := GREATEST (l_roll_x_wk10_res_cnt_tbl(9), NVL(l_roll_x_wk10_res_cnt_tbl(14),0));
				l_roll_x_wk10_res_cnt_tbl(15) := GREATEST (l_roll_x_wk10_res_cnt_tbl(10), NVL(l_roll_x_wk10_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and ROLLING WEEK 10 in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_roll_x_week10,
					p_curr_pd		=> l_roll_x_week10,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_roll_x_wk10,
					p_period_type_id	=> 16,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_roll_x_wk10_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_roll_x_week10 = l_old_roll_x_week10) THEN
					l_roll_x_wk10_org_change_flag	:= 'Y';
				ELSE
					l_roll_x_wk10_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_roll_x_wk10_res_cnt_tbl.FIRST.. l_roll_x_wk10_res_cnt_tbl.LAST
				LOOP
					l_roll_x_wk10_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_roll_x_wk10_res_cnt_tbl(1)	:= NVL(l_roll_x_wk10_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_roll_x_wk10_res_cnt_tbl(2)	:= NVL(l_roll_x_wk10_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_roll_x_wk10_res_cnt_tbl(3)	:= NVL(l_roll_x_wk10_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_roll_x_wk10_res_cnt_tbl(4)	:= NVL(l_roll_x_wk10_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_roll_x_wk10_res_cnt_tbl(5)	:= NVL(l_roll_x_wk10_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_roll_x_wk10_res_cnt_tbl(6)	:= NVL(l_roll_x_wk10_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_roll_x_wk10_res_cnt_tbl(7)	:= NVL(l_roll_x_wk10_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_roll_x_wk10_res_cnt_tbl(8)	:= NVL(l_roll_x_wk10_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_roll_x_wk10_res_cnt_tbl(9)	:= NVL(l_roll_x_wk10_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_roll_x_wk10_res_cnt_tbl(10):= NVL(l_roll_x_wk10_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_roll_x_wk10_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_roll_x_wk10_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_roll_x_wk10 := l_time_id;
			ELSIF (l_roll_x_wk10_count = 0) THEN
			BEGIN
				 SELECT to_char(fiit.start_date,'j')
				 INTO l_start_date_org_roll_x_wk10
				 FROM FII_TIME_WEEK fiit
				 WHERE fiit.start_date = to_date(to_char(((l_roll_x_week10 - 1) * 7) +     -- Bug#4903567
				 g_min_wk_j_st_date), 'J');
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_roll_x_wk10_res_cnt_tbl
			);
			--Assigning current ROLLING WEEK 10 id to
			--old period id local variable
			l_old_roll_x_week10 	:= l_roll_x_week10;
			l_roll_x_wk10_count	:= l_roll_x_wk10_count + 1;
			l_roll_x_wk10_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for ROLLING WEEK 10 */

      		-- For ROLLING WEEK 11
		IF (l_roll_x_week11 > 0 AND l_roll_x_week11 IS NOT NULL) THEN
			IF (l_old_roll_x_week11 < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_roll_x_week11 <> l_old_roll_x_week11
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this ROLLING WEEK 11
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_roll_x_wk11_res_cnt_tbl(11) := GREATEST (l_roll_x_wk11_res_cnt_tbl(6), NVL(l_roll_x_wk11_res_cnt_tbl(11),0));
				l_roll_x_wk11_res_cnt_tbl(12) := GREATEST (l_roll_x_wk11_res_cnt_tbl(7), NVL(l_roll_x_wk11_res_cnt_tbl(12),0));
				l_roll_x_wk11_res_cnt_tbl(13) := GREATEST (l_roll_x_wk11_res_cnt_tbl(8), NVL(l_roll_x_wk11_res_cnt_tbl(13),0));
				l_roll_x_wk11_res_cnt_tbl(14) := GREATEST (l_roll_x_wk11_res_cnt_tbl(9), NVL(l_roll_x_wk11_res_cnt_tbl(14),0));
				l_roll_x_wk11_res_cnt_tbl(15) := GREATEST (l_roll_x_wk11_res_cnt_tbl(10), NVL(l_roll_x_wk11_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and ROLLING WEEK 11 in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_roll_x_week11,
					p_curr_pd		=> l_roll_x_week11,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_roll_x_wk11,
					p_period_type_id	=> 16,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_roll_x_wk11_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_roll_x_week11 = l_old_roll_x_week11) THEN
					l_roll_x_wk11_org_change_flag	:= 'Y';
				ELSE
					l_roll_x_wk11_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_roll_x_wk11_res_cnt_tbl.FIRST.. l_roll_x_wk11_res_cnt_tbl.LAST
				LOOP
					l_roll_x_wk11_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_roll_x_wk11_res_cnt_tbl(1)	:= NVL(l_roll_x_wk11_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_roll_x_wk11_res_cnt_tbl(2)	:= NVL(l_roll_x_wk11_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_roll_x_wk11_res_cnt_tbl(3)	:= NVL(l_roll_x_wk11_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_roll_x_wk11_res_cnt_tbl(4)	:= NVL(l_roll_x_wk11_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_roll_x_wk11_res_cnt_tbl(5)	:= NVL(l_roll_x_wk11_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_roll_x_wk11_res_cnt_tbl(6)	:= NVL(l_roll_x_wk11_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_roll_x_wk11_res_cnt_tbl(7)	:= NVL(l_roll_x_wk11_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_roll_x_wk11_res_cnt_tbl(8)	:= NVL(l_roll_x_wk11_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_roll_x_wk11_res_cnt_tbl(9)	:= NVL(l_roll_x_wk11_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_roll_x_wk11_res_cnt_tbl(10):= NVL(l_roll_x_wk11_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_roll_x_wk11_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_roll_x_wk11_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_roll_x_wk11 := l_time_id;
			ELSIF (l_roll_x_wk11_count = 0) THEN
			BEGIN
				 SELECT to_char(fiit.start_date,'j')
				 INTO l_start_date_org_roll_x_wk11
				 FROM FII_TIME_WEEK fiit
				 WHERE fiit.start_date = to_date(to_char(((l_roll_x_week11 - 1) * 7) +     -- Bug#4903567
				 g_min_wk_j_st_date), 'J');
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_roll_x_wk11_res_cnt_tbl
			);
			--Assigning current ROLLING WEEK 11 id to
			--old period id local variable
			l_old_roll_x_week11 	:= l_roll_x_week11;
			l_roll_x_wk11_count	:= l_roll_x_wk11_count + 1;
			l_roll_x_wk11_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for ROLLING WEEK 11 */

      		-- For ROLLING WEEK 12
		IF (l_roll_x_week12 > 0 AND l_roll_x_week12 IS NOT NULL) THEN
			IF (l_old_roll_x_week12 < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_roll_x_week12 <> l_old_roll_x_week12
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this ROLLING WEEK 12
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_roll_x_wk12_res_cnt_tbl(11) := GREATEST (l_roll_x_wk12_res_cnt_tbl(6), NVL(l_roll_x_wk12_res_cnt_tbl(11),0));
				l_roll_x_wk12_res_cnt_tbl(12) := GREATEST (l_roll_x_wk12_res_cnt_tbl(7), NVL(l_roll_x_wk12_res_cnt_tbl(12),0));
				l_roll_x_wk12_res_cnt_tbl(13) := GREATEST (l_roll_x_wk12_res_cnt_tbl(8), NVL(l_roll_x_wk12_res_cnt_tbl(13),0));
				l_roll_x_wk12_res_cnt_tbl(14) := GREATEST (l_roll_x_wk12_res_cnt_tbl(9), NVL(l_roll_x_wk12_res_cnt_tbl(14),0));
				l_roll_x_wk12_res_cnt_tbl(15) := GREATEST (l_roll_x_wk12_res_cnt_tbl(10), NVL(l_roll_x_wk12_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and ROLLING WEEK 12 in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_roll_x_week12,
					p_curr_pd		=> l_roll_x_week12,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_roll_x_wk12,
					p_period_type_id	=> 16,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_roll_x_wk12_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_roll_x_week12 = l_old_roll_x_week12) THEN
					l_roll_x_wk12_org_change_flag	:= 'Y';
				ELSE
					l_roll_x_wk12_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_roll_x_wk12_res_cnt_tbl.FIRST.. l_roll_x_wk12_res_cnt_tbl.LAST
				LOOP
					l_roll_x_wk12_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_roll_x_wk12_res_cnt_tbl(1)	:= NVL(l_roll_x_wk12_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_roll_x_wk12_res_cnt_tbl(2)	:= NVL(l_roll_x_wk12_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_roll_x_wk12_res_cnt_tbl(3)	:= NVL(l_roll_x_wk12_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_roll_x_wk12_res_cnt_tbl(4)	:= NVL(l_roll_x_wk12_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_roll_x_wk12_res_cnt_tbl(5)	:= NVL(l_roll_x_wk12_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_roll_x_wk12_res_cnt_tbl(6)	:= NVL(l_roll_x_wk12_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_roll_x_wk12_res_cnt_tbl(7)	:= NVL(l_roll_x_wk12_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_roll_x_wk12_res_cnt_tbl(8)	:= NVL(l_roll_x_wk12_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_roll_x_wk12_res_cnt_tbl(9)	:= NVL(l_roll_x_wk12_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_roll_x_wk12_res_cnt_tbl(10):= NVL(l_roll_x_wk12_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_roll_x_wk12_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_roll_x_wk12_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_roll_x_wk12 := l_time_id;
			ELSIF (l_roll_x_wk12_count = 0) THEN
			BEGIN
				 SELECT to_char(fiit.start_date,'j')
				 INTO l_start_date_org_roll_x_wk12
				 FROM FII_TIME_WEEK fiit
				 WHERE fiit.start_date = to_date(to_char(((l_roll_x_week12 - 1) * 7) +     -- Bug#4903567
				 g_min_wk_j_st_date), 'J');
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_roll_x_wk12_res_cnt_tbl
			);
			--Assigning current ROLLING WEEK 12 id to
			--old period id local variable
			l_old_roll_x_week12 	:= l_roll_x_week12;
			l_roll_x_wk12_count	:= l_roll_x_wk12_count + 1;
			l_roll_x_wk12_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for ROLLING WEEK 12 */

      		-- For ROLLING WEEK 13
		IF (l_roll_x_week13 > 0 AND l_roll_x_week13 IS NOT NULL) THEN
			IF (l_old_roll_x_week13 < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0
			   ) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
				--DBMS_OUTPUT.PUT_LINE('1');
					NULL;
			ELSIF (l_roll_x_week13 <> l_old_roll_x_week13
				  OR l_exp_organization_id <> l_old_exp_orgnztion_id
				  ) THEN
				--All records for this ROLLING WEEK 13
				--and person ids are processed. So, now determine
				--the buckets
				/*
				For consecutive records this processing is being done
				because if the last record in the counting of
				resource counts is 1, the previous count for consecutive
				availability will not get replaced with the new count.
				*/

				l_roll_x_wk13_res_cnt_tbl(11) := GREATEST (l_roll_x_wk13_res_cnt_tbl(6), NVL(l_roll_x_wk13_res_cnt_tbl(11),0));
				l_roll_x_wk13_res_cnt_tbl(12) := GREATEST (l_roll_x_wk13_res_cnt_tbl(7), NVL(l_roll_x_wk13_res_cnt_tbl(12),0));
				l_roll_x_wk13_res_cnt_tbl(13) := GREATEST (l_roll_x_wk13_res_cnt_tbl(8), NVL(l_roll_x_wk13_res_cnt_tbl(13),0));
				l_roll_x_wk13_res_cnt_tbl(14) := GREATEST (l_roll_x_wk13_res_cnt_tbl(9), NVL(l_roll_x_wk13_res_cnt_tbl(14),0));
				l_roll_x_wk13_res_cnt_tbl(15) := GREATEST (l_roll_x_wk13_res_cnt_tbl(10), NVL(l_roll_x_wk13_res_cnt_tbl(15),0));

				--INSERT Records for this particular
				--person id and ROLLING WEEK 13 in
				--PJI_RM_AGGR_AVL3 table

				PREPARE_TO_INS_INTO_AVL3
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_roll_x_week13,
					p_curr_pd		=> l_roll_x_week13,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_roll_x_wk13,
					p_period_type_id	=> 16,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_roll_x_wk13_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_roll_x_week13 = l_old_roll_x_week13) THEN
					l_roll_x_wk13_org_change_flag	:= 'Y';
				ELSE
					l_roll_x_wk13_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0
				FOR m in l_roll_x_wk13_res_cnt_tbl.FIRST.. l_roll_x_wk13_res_cnt_tbl.LAST
				LOOP
					l_roll_x_wk13_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;
			--Processing for cumulative records
			l_roll_x_wk13_res_cnt_tbl(1)	:= NVL(l_roll_x_wk13_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_roll_x_wk13_res_cnt_tbl(2)	:= NVL(l_roll_x_wk13_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_roll_x_wk13_res_cnt_tbl(3)	:= NVL(l_roll_x_wk13_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_roll_x_wk13_res_cnt_tbl(4)	:= NVL(l_roll_x_wk13_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_roll_x_wk13_res_cnt_tbl(5)	:= NVL(l_roll_x_wk13_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Processing for consecutive records
			l_roll_x_wk13_res_cnt_tbl(6)	:= NVL(l_roll_x_wk13_res_cnt_tbl(6),0) + g_avl_res_cnt_1;
			l_roll_x_wk13_res_cnt_tbl(7)	:= NVL(l_roll_x_wk13_res_cnt_tbl(7),0) + g_avl_res_cnt_2;
			l_roll_x_wk13_res_cnt_tbl(8)	:= NVL(l_roll_x_wk13_res_cnt_tbl(8),0) + g_avl_res_cnt_3;
			l_roll_x_wk13_res_cnt_tbl(9)	:= NVL(l_roll_x_wk13_res_cnt_tbl(9),0) + g_avl_res_cnt_4;
			l_roll_x_wk13_res_cnt_tbl(10):= NVL(l_roll_x_wk13_res_cnt_tbl(10),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_roll_x_wk13_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_roll_x_wk13_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_roll_x_wk13 := l_time_id;
			ELSIF (l_roll_x_wk13_count = 0) THEN
			BEGIN
				 SELECT to_char(fiit.start_date,'j')
				 INTO l_start_date_org_roll_x_wk13
				 FROM FII_TIME_WEEK fiit
				 WHERE fiit.start_date = to_date(to_char(((l_roll_x_week13 - 1) * 7) +     -- Bug#4903567
				 g_min_wk_j_st_date), 'J');
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Call API to compare and store consecutive counts
			--for the resource
			CALC_CS_RES_CNT_VALUE
			(
				p_res_cnt_tbl	=> l_roll_x_wk13_res_cnt_tbl
			);
			--Assigning current ROLLING WEEK 13 id to
			--old period id local variable
			l_old_roll_x_week13 	:= l_roll_x_week13;
			l_roll_x_wk13_count	:= l_roll_x_wk13_count + 1;
			l_roll_x_wk13_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for ROLLING WEEK 13 */

		--Then for WEEK
		--Different from all other periods above because
		--this is to put data for current available resources
		--in a week for a different report
		IF (l_week_id <> 0 AND l_week_id IS NOT NULL) THEN

			IF (l_old_week_id < 0
				OR l_old_person_id < 0
				OR l_old_exp_orgnztion_id < 0) THEN
				-- Do Nothing
				-- This is just to make sure that nothing is
				-- executed for the very first time the program
				-- comes in the Cursor
					NULL;
			ELSIF (l_week_id <> l_old_week_id
				OR l_exp_organization_id <> l_old_exp_orgnztion_id) THEN
				--All records for this WEEK
				--and person id are processed. So, now determine
				--the buckets

				--INSERT Records for this particular
				--person id and WEEK in
				--PJI_RM_AGGR_AVL4 table

				PREPARE_TO_INS_INTO_AVL4
				(
					p_exp_organization_id	=> l_old_exp_orgnztion_id,
					p_exp_org_id		=> l_old_exp_org_id,
					p_person_id		=> l_old_person_id,
					p_time_id		=> l_old_week_id,
					p_curr_pd		=> l_week_id,
					p_as_of_date		=> l_time_id,
					p_pd_org_st_date	=> l_start_date_org_week,
					p_period_type_id	=> 16,
					p_calendar_type		=> 'E',
					p_res_cnt_tbl		=> l_week_res_cnt_tbl,
					p_run_mode		=> p_run_mode,
					p_blind_insert_flag	=> 'N',
					x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
				);

				IF (l_week_id = l_old_week_id) THEN
					l_week_org_change_flag	:= 'Y';
				ELSE
					l_week_count		:= 0;
				END IF;
				--After insert SET ALL count and values to 0

				FOR m in l_week_res_cnt_tbl.FIRST.. l_week_res_cnt_tbl.LAST
				LOOP
					l_week_res_cnt_tbl(m) := 0;
				END LOOP;
			END IF;

			--Processing for week availability records
			l_week_res_cnt_tbl(1)	:= NVL(l_week_res_cnt_tbl(1),0) + g_avl_res_cnt_1;
			l_week_res_cnt_tbl(2)	:= NVL(l_week_res_cnt_tbl(2),0) + g_avl_res_cnt_2;
			l_week_res_cnt_tbl(3)	:= NVL(l_week_res_cnt_tbl(3),0) + g_avl_res_cnt_3;
			l_week_res_cnt_tbl(4)	:= NVL(l_week_res_cnt_tbl(4),0) + g_avl_res_cnt_4;
			l_week_res_cnt_tbl(5)	:= NVL(l_week_res_cnt_tbl(5),0) + g_avl_res_cnt_5;

			--Store the starting day of the period
			IF (l_week_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'Y') THEN
				NULL;
			ELSIF (l_week_org_change_flag = 'Y' AND l_zero_bkt_cnt_flag = 'N') THEN
				l_start_date_org_week := l_time_id;
			ELSIF (l_week_count = 0) THEN
			BEGIN
				SELECT to_char(fiit.start_date,'j')
				INTO l_start_date_org_week
				FROM fii_time_week fiit
				WHERE l_week_id = fiit.week_id;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			--Assigning current WEEK id to
			--old period id local variable
			l_old_week_id := l_week_id;
			l_week_count	:= l_week_count + 1;
			l_week_org_change_flag:= 'N';
		END IF;
      		/* End of Processing for WEEK */
		/* After end of processing for ALL PERIODS */
		--Store old values for person id, org id and
		--organization id

		l_old_exp_orgnztion_id 	:= l_exp_organization_id;
		l_old_exp_org_id 	:= l_exp_org_id;
      		l_old_person_id 	:= l_person_id;
	END LOOP;
END LOOP;
CLOSE Res_cur;
/*
Make sure that the current records in PL/SQL tables for
inserting in PJI_RM_AGGR_AVL3 and PJI_RM_AGGR_AVL4 table are inserted.
If the number of PL/SQL records did not reach 200
it may not be inserted. So, call the Bulk insert API
with blind insert flag = 'Y' and all variables and
tables as empty. Also, no processing is done on any
of the parameters other than P_BLIND_INSERT_FLAG,
so passing everything as null and dummy PL/SQL tables
*/
	PREPARE_TO_INS_INTO_AVL3
	(
		p_exp_organization_id	=> null,
		p_exp_org_id		=> null,
		p_person_id		=> null,
		p_time_id		=> null,
		p_curr_pd		=> null,
		p_as_of_date		=> null,
		p_pd_org_st_date	=> null,
		p_period_type_id	=> null,
		p_calendar_type		=> null,
		p_res_cnt_tbl		=> l_dummy_res_tbl,
		p_run_mode		=> p_run_mode,
		p_blind_insert_flag	=> 'Y',
		x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
	);

	PREPARE_TO_INS_INTO_AVL4
	(
		p_exp_organization_id	=> null,
		p_exp_org_id		=> null,
		p_person_id		=> null,
		p_time_id		=> null,
		p_curr_pd		=> null,
		p_as_of_date		=> null,
		p_pd_org_st_date	=> null,
		p_period_type_id	=> null,
		p_calendar_type		=> null,
		p_res_cnt_tbl		=> l_dummy_res_tbl,
		p_run_mode		=> p_run_mode,
		p_blind_insert_flag	=> 'Y',
		x_zero_bkt_cnt_flag	=> l_zero_bkt_cnt_flag
	);

/*EXCEPTION
	WHEN OTHERS THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO before_calc_starts;*/
END CALCULATE_RES_AVL;

/**************************************************************************
THE PART BELOW IS THE DRIVER PART FOR CALCULATIONS. IT ACTS LIKE AN
OVERALL MANAGER WHO MONITORS THE RESOURCE AVAILABILITY CALCULATIONS
**************************************************************************/

/*
This procedure gives the current
resource count in the resource status
table that have not been processed
*/
PROCEDURE CALC_CURR_RES_COUNT
IS

BEGIN

SELECT COUNT(*)
INTO g_curr_res_left_count
FROM PJI_RM_RES_BATCH_MAP
WHERE worker_status IS NULL
and worker_id IS NULL;

END CALC_CURR_RES_COUNT;

/*
This procedure is used to merge the organization
level records for the RESOURCE AVAILABILITY DURATION
*/
PROCEDURE MERGE_ORG_AVL_DUR
	(p_worker_id	IN NUMBER)
IS
--Defining values for who columns
    l_last_update_date  DATE := sysdate;
    l_last_updated_by   NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date     DATE := sysdate;
    l_created_by        NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
    l_process 		VARCHAR2(30);
BEGIN

	l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

	IF (NOT PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
	(
		l_process,
		'PJI_RM_SUM_AVL.MERGE_ORG_AVL_DUR(p_worker_id);'
	)) THEN
		RETURN;
	END IF;

	-- Populate the global variable for minimum
	-- start date of week in a julian date

		SELECT MIN(to_char(fiik.start_date,'j'))
		INTO g_min_wk_j_st_date
		FROM fii_time_week fiik;

/* Group all the records based on periods and
   MERGE IN the fact table
 */
 MERGE /*+ parallel(rmr) */ into PJI_AV_ORG_F rmr
 USING
     (
       SELECT
	 rtmp.EXPENDITURE_ORGANIZATION_ID 	as EXPENDITURE_ORGANIZATION_ID,
	 rtmp.EXPENDITURE_ORG_ID 		as EXPENDITURE_ORG_ID,
	 rtmp.TIME_ID 				as TIME_ID,
	 rtmp.PERIOD_TYPE_ID 			as PERIOD_TYPE_ID,
	 rtmp.CALENDAR_TYPE 			as CALENDAR_TYPE,
	 rtmp.THRESHOLD 			as THRESHOLD,
	 rtmp.AS_OF_DATE			as AS_OF_DATE,
	 sum(rtmp.BCKT_1_CS)       		BCKT_1_CS,
	 sum(rtmp.BCKT_2_CS)       		BCKT_2_CS,
	 sum(rtmp.BCKT_3_CS)       		BCKT_3_CS,
	 sum(rtmp.BCKT_4_CS)       		BCKT_4_CS,
	 sum(rtmp.BCKT_5_CS)       		BCKT_5_CS,
	 sum(rtmp.BCKT_1_CM)       		BCKT_1_CM,
	 sum(rtmp.BCKT_2_CM)       		BCKT_2_CM,
	 sum(rtmp.BCKT_3_CM)       		BCKT_3_CM,
	 sum(rtmp.BCKT_4_CM)       		BCKT_4_CM,
	 sum(rtmp.BCKT_5_CM)       		BCKT_5_CM,
	 sum(rtmp.TOTAL_RES_COUNT)     		TOTAL_RES_COUNT,
	 l_last_update_date   			LAST_UPDATE_DATE,
	 l_last_updated_by    			LAST_UPDATED_BY,
	 l_creation_date      			CREATION_DATE,
	 l_created_by         			CREATED_BY,
	 l_last_update_login  			LAST_UPDATE_LOGIN
       FROM
	 (
	       SELECT
			rtmp1.EXPENDITURE_ORGANIZATION_ID as EXPENDITURE_ORGANIZATION_ID,
			rtmp1.EXPENDITURE_ORG_ID 	as EXPENDITURE_ORG_ID,
			case when rtmp1.period_type_id = 16 then
					  fwk.WEEK_ID
				 when rtmp1.period_type_id <> 16 then
					   rtmp1.TIME_ID
			end                                TIME_ID,
			rtmp1.PERIOD_TYPE_ID 		as PERIOD_TYPE_ID,
			rtmp1.PERSON_ID 		as PERSON_ID,
			rtmp1.CALENDAR_TYPE 		as CALENDAR_TYPE,
			rtmp1.THRESHOLD 		as THRESHOLD,
			rtmp1.AS_OF_DATE 		as AS_OF_DATE,
			rtmp1.BCKT_1_CS 		as BCKT_1_CS,
			rtmp1.BCKT_2_CS 		as BCKT_2_CS,
			rtmp1.BCKT_3_CS 		as BCKT_3_CS,
			rtmp1.BCKT_4_CS 		as BCKT_4_CS,
			rtmp1.BCKT_5_CS 		as BCKT_5_CS,
			rtmp1.BCKT_1_CM 		as BCKT_1_CM,
			rtmp1.BCKT_2_CM 		as BCKT_2_CM,
			rtmp1.BCKT_3_CM 		as BCKT_3_CM,
			rtmp1.BCKT_4_CM 		as BCKT_4_CM,
			rtmp1.BCKT_5_CM 		as BCKT_5_CM,
			rtmp1.TOTAL_RES_COUNT 		as TOTAL_RES_COUNT
	       FROM
	       (
		       SELECT
				 EXPENDITURE_ORGANIZATION_ID,
				 EXPENDITURE_ORG_ID,
				 TIME_ID,
				 PERIOD_TYPE_ID,
				 PERSON_ID,
				 CALENDAR_TYPE,
				 THRESHOLD,
				 AS_OF_DATE,
				 BCKT_1_CS,
				 BCKT_2_CS,
				 BCKT_3_CS,
				 BCKT_4_CS,
				 BCKT_5_CS,
				 BCKT_1_CM,
				 BCKT_2_CM,
				 BCKT_3_CM,
				 BCKT_4_CM,
				 BCKT_5_CM,
				 TOTAL_RES_COUNT
			FROM
				 PJI_RM_AGGR_AVL3
		) rtmp1,
		(
			SELECT
				 fiit.WEEK_ID as WEEK_ID,
				(to_char(fiit.start_date,'j') - g_min_wk_j_st_date)/7 + 1 as SEQUENCE_ID
			FROM
				FII_TIME_WEEK fiit
				ORDER BY SEQUENCE_ID
		) fwk
		WHERE
			rtmp1.time_id = fwk.sequence_id (+)
			ORDER BY 1,2,3,4,5
	) rtmp
      GROUP BY
	rtmp.EXPENDITURE_ORGANIZATION_ID,
	rtmp.EXPENDITURE_ORG_ID,
	rtmp.PERIOD_TYPE_ID,
	rtmp.TIME_ID,
	rtmp.CALENDAR_TYPE,
	rtmp.THRESHOLD,
	rtmp.AS_OF_DATE
     ) tmp1
     ON
     (
       tmp1.EXPENDITURE_ORGANIZATION_ID = rmr.EXPENDITURE_ORGANIZATION_ID and
       tmp1.EXPENDITURE_ORG_ID          = rmr.EXPENDITURE_ORG_ID          and
       tmp1.PERIOD_TYPE_ID              = rmr.PERIOD_TYPE_ID              and
       tmp1.TIME_ID                     = rmr.TIME_ID                     and
       tmp1.CALENDAR_TYPE               = rmr.CALENDAR_TYPE		  and
       tmp1.THRESHOLD               	= rmr.THRESHOLD			  and
       tmp1.AS_OF_DATE               	= rmr.AS_OF_DATE
     )
     WHEN MATCHED THEN UPDATE SET
       rmr.BCKT_1_CS       	= rmr.BCKT_1_CS       + tmp1.BCKT_1_CS,
       rmr.BCKT_2_CS       	= rmr.BCKT_2_CS       + tmp1.BCKT_2_CS,
       rmr.BCKT_3_CS       	= rmr.BCKT_3_CS       + tmp1.BCKT_3_CS,
       rmr.BCKT_4_CS       	= rmr.BCKT_4_CS       + tmp1.BCKT_4_CS,
       rmr.BCKT_5_CS       	= rmr.BCKT_5_CS       + tmp1.BCKT_5_CS,
       rmr.BCKT_1_CM       	= rmr.BCKT_1_CM       + tmp1.BCKT_1_CM,
       rmr.BCKT_2_CM       	= rmr.BCKT_2_CM       + tmp1.BCKT_2_CM,
       rmr.BCKT_3_CM       	= rmr.BCKT_3_CM       + tmp1.BCKT_3_CM,
       rmr.BCKT_4_CM       	= rmr.BCKT_4_CM       + tmp1.BCKT_4_CM,
       rmr.BCKT_5_CM       	= rmr.BCKT_5_CM       + tmp1.BCKT_5_CM,
       rmr.TOTAL_RES_COUNT      = rmr.TOTAL_RES_COUNT + tmp1.TOTAL_RES_COUNT,
       rmr.LAST_UPDATE_DATE   	= tmp1.LAST_UPDATE_DATE,
       rmr.LAST_UPDATED_BY    	= tmp1.LAST_UPDATED_BY,
       rmr.LAST_UPDATE_LOGIN  	= tmp1.LAST_UPDATE_LOGIN
     WHEN NOT MATCHED THEN INSERT
     (
	      rmr.EXPENDITURE_ORGANIZATION_ID,
	      rmr.EXPENDITURE_ORG_ID,
	      rmr.PERIOD_TYPE_ID,
	      rmr.TIME_ID,
	      rmr.CALENDAR_TYPE,
	      rmr.THRESHOLD,
	      rmr.AS_OF_DATE,
	      rmr.CREATION_DATE,
	      rmr.CREATED_BY,
	      rmr.LAST_UPDATE_DATE,
	      rmr.LAST_UPDATED_BY,
	      rmr.LAST_UPDATE_LOGIN,
	      rmr.BCKT_1_CS,
	      rmr.BCKT_2_CS,
	      rmr.BCKT_3_CS,
	      rmr.BCKT_4_CS,
	      rmr.BCKT_5_CS,
	      rmr.BCKT_1_CM,
	      rmr.BCKT_2_CM,
	      rmr.BCKT_3_CM,
	      rmr.BCKT_4_CM,
	      rmr.BCKT_5_CM,
	      rmr.TOTAL_RES_COUNT
     )
     values
     (
	      tmp1.EXPENDITURE_ORGANIZATION_ID,
	      tmp1.EXPENDITURE_ORG_ID,
	      tmp1.PERIOD_TYPE_ID,
	      tmp1.TIME_ID,
	      tmp1.CALENDAR_TYPE,
	      tmp1.THRESHOLD,
	      tmp1.AS_OF_DATE,
	      tmp1.CREATION_DATE,
	      tmp1.CREATED_BY,
	      tmp1.LAST_UPDATE_DATE,
	      tmp1.LAST_UPDATED_BY,
	      tmp1.LAST_UPDATE_LOGIN,
	      tmp1.BCKT_1_CS,
	      tmp1.BCKT_2_CS,
	      tmp1.BCKT_3_CS,
	      tmp1.BCKT_4_CS,
	      tmp1.BCKT_5_CS,
	      tmp1.BCKT_1_CM,
	      tmp1.BCKT_2_CM,
	      tmp1.BCKT_3_CM,
	      tmp1.BCKT_4_CM,
	      tmp1.BCKT_5_CM,
	      tmp1.TOTAL_RES_COUNT
     );

     	PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
     	(
     		l_process,
     		'PJI_RM_SUM_AVL.MERGE_ORG_AVL_DUR(p_worker_id);'
     	);

	COMMIT;

END MERGE_ORG_AVL_DUR;

/*
This procedure is used to merge the organization level
records for the CURRENT RESOURCE AVAILABILITY
*/

PROCEDURE MERGE_CURR_ORG_AVL
	(p_worker_id	IN NUMBER)
IS
--Defining values for who columns
    l_last_update_date  DATE := sysdate;
    l_last_updated_by   NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date     DATE := sysdate;
    l_created_by        NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;
    l_process 		VARCHAR2(30);
BEGIN

	l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

	IF (NOT PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
	(
		l_process,
		'PJI_RM_SUM_AVL.MERGE_CURR_ORG_AVL(p_worker_id);'
	)) THEN
		RETURN;
	END IF;

	-- Populate the global variable for minimum
	-- start date of week in a julian date

		SELECT MIN(to_char(fiik.start_date,'j'))
		INTO g_min_wk_j_st_date
		FROM fii_time_week fiik;

/* Group all the records based on periods and
   MERGE IN the fact table
 */
 MERGE /*+ parallel(rmr) */ into PJI_CA_ORG_F rmr
 USING
     (
       SELECT
	 rtmp.EXPENDITURE_ORGANIZATION_ID 	as EXPENDITURE_ORGANIZATION_ID,
	 rtmp.EXPENDITURE_ORG_ID 		as EXPENDITURE_ORG_ID,
	 rtmp.TIME_ID 				as TIME_ID,
	 rtmp.PERIOD_TYPE_ID 			as PERIOD_TYPE_ID,
	 rtmp.CALENDAR_TYPE 			as CALENDAR_TYPE,
	 rtmp.THRESHOLD 			as THRESHOLD,
	 rtmp.AS_OF_DATE 			as AS_OF_DATE,
	 sum(rtmp.AVAILABILITY)       		AVAILABILITY,
	 sum(rtmp.TOTAL_RES_COUNT)     		TOTAL_RES_COUNT,
	 l_last_update_date   			LAST_UPDATE_DATE,
	 l_last_updated_by    			LAST_UPDATED_BY,
	 l_creation_date      			CREATION_DATE,
	 l_created_by         			CREATED_BY,
	 l_last_update_login  			LAST_UPDATE_LOGIN
       FROM
		PJI_RM_AGGR_AVL4 rtmp
      GROUP BY
	rtmp.EXPENDITURE_ORGANIZATION_ID,
	rtmp.EXPENDITURE_ORG_ID,
	rtmp.PERIOD_TYPE_ID,
	rtmp.TIME_ID,
	rtmp.CALENDAR_TYPE,
	rtmp.THRESHOLD,
	rtmp.AS_OF_DATE
     ) tmp1
     ON
     (
       tmp1.EXPENDITURE_ORGANIZATION_ID = rmr.EXPENDITURE_ORGANIZATION_ID and
       tmp1.EXPENDITURE_ORG_ID          = rmr.EXPENDITURE_ORG_ID          and
       tmp1.PERIOD_TYPE_ID              = rmr.PERIOD_TYPE_ID              and
       tmp1.TIME_ID                     = rmr.TIME_ID                     and
       tmp1.CALENDAR_TYPE               = rmr.CALENDAR_TYPE		  and
       tmp1.THRESHOLD               	= rmr.THRESHOLD			  and
       tmp1.AS_OF_DATE               	= rmr.AS_OF_DATE
     )
     WHEN MATCHED THEN UPDATE SET
       rmr.AVAILABILITY       	= rmr.AVAILABILITY       + tmp1.AVAILABILITY,
       rmr.TOTAL_RES_COUNT      = rmr.TOTAL_RES_COUNT    + tmp1.TOTAL_RES_COUNT,
       rmr.LAST_UPDATE_DATE   	= tmp1.LAST_UPDATE_DATE,
       rmr.LAST_UPDATED_BY    	= tmp1.LAST_UPDATED_BY,
       rmr.LAST_UPDATE_LOGIN  	= tmp1.LAST_UPDATE_LOGIN
     WHEN NOT MATCHED THEN INSERT
     (
	      rmr.EXPENDITURE_ORGANIZATION_ID,
	      rmr.EXPENDITURE_ORG_ID,
	      rmr.PERIOD_TYPE_ID,
	      rmr.TIME_ID,
	      rmr.CALENDAR_TYPE,
	      rmr.THRESHOLD,
	      rmr.AS_OF_DATE,
	      rmr.CREATION_DATE,
	      rmr.CREATED_BY,
	      rmr.LAST_UPDATE_DATE,
	      rmr.LAST_UPDATED_BY,
	      rmr.LAST_UPDATE_LOGIN,
	      rmr.AVAILABILITY,
	      rmr.TOTAL_RES_COUNT
     )
     values
     (
	      tmp1.EXPENDITURE_ORGANIZATION_ID,
	      tmp1.EXPENDITURE_ORG_ID,
	      tmp1.PERIOD_TYPE_ID,
	      tmp1.TIME_ID,
	      tmp1.CALENDAR_TYPE,
	      tmp1.THRESHOLD,
	      tmp1.AS_OF_DATE,
	      tmp1.CREATION_DATE,
	      tmp1.CREATED_BY,
	      tmp1.LAST_UPDATE_DATE,
	      tmp1.LAST_UPDATED_BY,
	      tmp1.LAST_UPDATE_LOGIN,
	      tmp1.AVAILABILITY,
	      tmp1.TOTAL_RES_COUNT
     );

	PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
	(
		l_process,
		'PJI_RM_SUM_AVL.MERGE_CURR_ORG_AVL(p_worker_id);'
	);

	COMMIT;

END MERGE_CURR_ORG_AVL;

/*
This procedure updates the resource status
for which the error occured (if it occured
at all) and processing has not been done.
After this update, the resource can be
picked up by any worker in the current run
*/

PROCEDURE UPDATE_RES_STATUS
IS
BEGIN

--Update status table to make sure that any resource
--that was not processed last time is processed this
--time

UPDATE PJI_RM_RES_BATCH_MAP
SET worker_id = null
WHERE worker_status IS NULL
AND worker_id IS NOT NULL;

COMMIT;

END UPDATE_RES_STATUS;

/*
This procedure is called to clean up the temporary
table space allocated for the resource availability
calculations. This would also clean up the status
table for resource calculations
*/
PROCEDURE RES_CALC_CLEANUP
	(p_worker_id	IN NUMBER)
IS
--Defining local variables
l_process 	VARCHAR2(30);
BEGIN
	l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

	IF (NOT PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
	(
		l_process,
		'PJI_RM_SUM_AVL.RES_CALC_CLEANUP(p_worker_id);'
	)) THEN
		RETURN;
	END IF;

	execute immediate ('truncate table ' || PJI_UTILS.get_pji_schema_name || '.PJI_RM_AGGR_AVL1');

	execute immediate ('truncate table ' || PJI_UTILS.get_pji_schema_name || '.PJI_RM_AGGR_AVL2');

	execute immediate ('truncate table ' || PJI_UTILS.get_pji_schema_name || '.PJI_RM_AGGR_AVL3');

	execute immediate ('truncate table ' || PJI_UTILS.get_pji_schema_name || '.PJI_RM_AGGR_AVL4');

	execute immediate ('truncate table ' || PJI_UTILS.get_pji_schema_name || '.PJI_RM_AGGR_AVL5');

	execute immediate ('truncate table ' || PJI_UTILS.get_pji_schema_name || '.PJI_RM_RES_BATCH_MAP');

	PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
	(
		l_process,
		'PJI_RM_SUM_AVL.RES_CALC_CLEANUP(p_worker_id);'
	);
	COMMIT;

END RES_CALC_CLEANUP;

/*
This procedure is used to determine the
resources that would be processed by the
worker id passed to this procedure for
1st run, i.e., for OLD fact records.
One the resources are determined the procedure
calls appropriate APIs to get the resource
buckets calculated
*/
PROCEDURE START_RES_AVL_CALC_R1
	(p_worker_id	IN NUMBER)
IS

-- Defining local variables
	l_person_id 		NUMBER := 0;
	l_partition		NUMBER := 1;
	l_try_res_again		VARCHAR2(1) := 'N';
	l_count_res_status 	NUMBER := 0;
	l_process 		VARCHAR2(30);
        l_row_count             NUMBER := 0;
        l_parallel_processes    NUMBER;

        l_return_status VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;

BEGIN
	--This call in the loop will take care of:
	--PHASE 1
	--PHASE 2
	--PHASE 3
	--of the summarization process for resources in the buckets

	l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

	IF (NOT PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
	(
		l_process,
		'PJI_RM_SUM_AVL.START_RES_AVL_CALC_R1(p_worker_id);'
	)) THEN
		RETURN;
	END IF;

	--Instantiate package level (ONLY) global variables
	INIT_PCKG_GLOBAL_VARS;
	--POP_ROLL_WEEK_OFFSET;

	--Get count from the status table to get the maximum number
	--of times the loop should run

	SELECT COUNT(*)
	INTO l_count_res_status
	FROM PJI_RM_RES_BATCH_MAP;

	FOR i in 1.. l_count_res_status
	LOOP
		l_try_res_again := 'N';
		pji_utils.write2log(p_worker_id || ': R1: Before updating PJI_RM_RES_BATCH_MAP and returning resource id');
		UPDATE PJI_RM_RES_BATCH_MAP
		SET worker_id = p_worker_id
		WHERE worker_status IS NULL
		and worker_id IS NULL
		and rownum < 2
		RETURNING person_id
		INTO l_person_id;
		pji_utils.write2log(p_worker_id || ': R1: After updating PJI_RM_RES_BATCH_MAP and returning resource id');
		IF SQL%ROWCOUNT <> 0 THEN
			COMMIT;
		ELSE
			CALC_CURR_RES_COUNT;
			IF (g_curr_res_left_count = 0) THEN
				EXIT;
			ELSE
				l_try_res_again := 'Y';
			END IF;
		END IF;

		IF(l_try_res_again = 'Y') THEN
			--Wait for some time and try again
			PJI_PROCESS_UTIL.sleep(PJI_RM_SUM_MAIN.g_process_delay);
		ELSE
			pji_utils.write2log(p_worker_id || ': R1: Before Calculating availability');
			CALCULATE_RES_AVL
			(
				p_worker_id	=> p_worker_id,
				p_person_id	=> l_person_id,
				p_run_mode	=> 'OLD_FACT_RECORDS',
				x_return_status => l_return_status
			);
			pji_utils.write2log(p_worker_id || ': R1: After Calculating availability');
			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				/*
				UPDATE PJI_RM_RES_BATCH_MAP
				SET worker_id = null
				WHERE person_id = l_person_id;

				COMMIT;
				*/
				--Raise the error here
				raise RAISE_USER_DEF_EXCEPTION;
			ELSE
				pji_utils.write2log(p_worker_id || ': R1: Before Updating PJI_RM_RES_BATCH_MAP for completion');
				UPDATE PJI_RM_RES_BATCH_MAP
				SET worker_status = 'C'
				WHERE person_id = l_person_id
				and worker_id = p_worker_id;
				pji_utils.write2log(p_worker_id || ': R1: After Updating PJI_RM_RES_BATCH_MAP for completion');
				COMMIT;
			END IF;
		END IF;
	END LOOP;

	select count(*)
	into   l_row_count
	from   PJI_RM_RES_BATCH_MAP
	where  nvl(WORKER_STATUS, 'X') <> 'C';

	if (l_row_count = 0) then

          l_parallel_processes := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_RM_SUM_MAIN.g_process, 'PARALLEL_PROCESSES');

          for x in 2 .. l_parallel_processes loop

            update PJI_SYSTEM_PRC_STATUS
            set    STEP_STATUS = 'C'
            where  PROCESS_NAME = PJI_RM_SUM_MAIN.g_process || to_char(x)
              and  STEP_NAME = 'PJI_RM_SUM_AVL.START_RES_AVL_CALC_R1(p_worker_id);';

            commit;

          end loop;

	end if;

	PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
	(
		l_process,
		'PJI_RM_SUM_AVL.START_RES_AVL_CALC_R1(p_worker_id);'
	);

	COMMIT;
EXCEPTION
	WHEN RAISE_USER_DEF_EXCEPTION THEN
		RAISE;
	WHEN OTHERS THEN
		RAISE;
END START_RES_AVL_CALC_R1;

/*
This procedure is used to determine the
resources that would be processed by the
worker id passed to this procedure for
2nd run, i.e., for NEW fact records.
One the resources are determined the procedure
calls appropriate APIs to get the resource
buckets calculated
*/
PROCEDURE START_RES_AVL_CALC_R2
	(p_worker_id	IN NUMBER)
IS

-- Defining local variables
	l_person_id 		NUMBER := 0;
	l_partition		NUMBER := 1;
	l_try_res_again		VARCHAR2(1) := 'N';
	l_count_res_status 	NUMBER := 0;
	l_process 		VARCHAR2(30);
        l_row_count             NUMBER := 0;
        l_parallel_processes    NUMBER;

        l_return_status VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;

BEGIN
	--This call in the loop will take care of:
	--PHASE 1
	--PHASE 2
	--PHASE 3
	--of the summarization process for resources in the buckets

	l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

	IF (NOT PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
	(
		l_process,
		'PJI_RM_SUM_AVL.START_RES_AVL_CALC_R2(p_worker_id);'
	)) THEN
		RETURN;
	END IF;

	COMMIT;

	--Instantiate package level (ONLY) global variables
		INIT_PCKG_GLOBAL_VARS;
		--POP_ROLL_WEEK_OFFSET;

	--Get count from the status table to get the maximum number
	--of times the loop should run

	SELECT COUNT(*)
	INTO l_count_res_status
	FROM PJI_RM_RES_BATCH_MAP;

	FOR i in 1.. l_count_res_status
	LOOP
		l_try_res_again := 'N';
		pji_utils.write2log(p_worker_id || ': R2: Before updating PJI_RM_RES_BATCH_MAP and returning resource id');
		UPDATE PJI_RM_RES_BATCH_MAP
		SET worker_id = p_worker_id
		WHERE worker_status IS NULL
		and worker_id IS NULL
		and rownum < 2
		RETURNING person_id
		INTO l_person_id;
		pji_utils.write2log(p_worker_id || ': R2: After updating PJI_RM_RES_BATCH_MAP and returning resource id');
		IF SQL%ROWCOUNT <> 0 THEN
			COMMIT;
		ELSE
			CALC_CURR_RES_COUNT;
			IF (g_curr_res_left_count = 0) THEN
				EXIT;
			ELSE
				l_try_res_again := 'Y';
			END IF;
		END IF;

		IF(l_try_res_again = 'Y') THEN
			--Wait for some time and try again
			PJI_PROCESS_UTIL.sleep(PJI_RM_SUM_MAIN.g_process_delay);
		ELSE
			pji_utils.write2log(p_worker_id || ': R2: Before Calculating availability');
			CALCULATE_RES_AVL
			(
				p_worker_id	=> p_worker_id,
				p_person_id	=> l_person_id,
				p_run_mode	=> 'NEW_FACT_RECORDS',
				x_return_status => l_return_status
			);
			pji_utils.write2log(p_worker_id || ': R2: After Calculating availability');
			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				/*
				UPDATE PJI_RM_RES_BATCH_MAP
				SET worker_id = null
				WHERE person_id = l_person_id;

				COMMIT;
				*/
				--Raise the error here
				raise RAISE_USER_DEF_EXCEPTION;
			ELSE
				pji_utils.write2log(p_worker_id || ': R2: Before Updating PJI_RM_RES_BATCH_MAP for completion');
				UPDATE PJI_RM_RES_BATCH_MAP
				SET worker_status = 'C'
				WHERE person_id = l_person_id
				and worker_id = p_worker_id;
				pji_utils.write2log(p_worker_id || ': R2: After Updating PJI_RM_RES_BATCH_MAP for completion');
				COMMIT;
			END IF;
		END IF;
	END LOOP;

	select count(*)
	into   l_row_count
	from   PJI_RM_RES_BATCH_MAP
	where  nvl(WORKER_STATUS, 'X') <> 'C';

	if (l_row_count = 0) then

          l_parallel_processes := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_RM_SUM_MAIN.g_process, 'PARALLEL_PROCESSES');

          for x in 2 .. l_parallel_processes loop

            update PJI_SYSTEM_PRC_STATUS
            set    STEP_STATUS = 'C'
            where  PROCESS_NAME = PJI_RM_SUM_MAIN.g_process || to_char(x)
              and  STEP_NAME = 'PJI_RM_SUM_AVL.START_RES_AVL_CALC_R2(p_worker_id);';

            commit;

          end loop;

	end if;

	PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
	(
		l_process,
		'PJI_RM_SUM_AVL.START_RES_AVL_CALC_R2(p_worker_id);'
	);

	COMMIT;
EXCEPTION
	WHEN RAISE_USER_DEF_EXCEPTION THEN
		RAISE;
	WHEN OTHERS THEN
		RAISE;
END START_RES_AVL_CALC_R2;

/*
This procedure updates the resource status
table for run 2 with new fact records
*/
PROCEDURE UPDATE_RES_STA_FOR_RUN2
	(p_worker_id	IN NUMBER)
IS
l_process 		VARCHAR2(30);
l_res_process_cnt 	NUMBER(15):=0;
l_res_full_cnt 		NUMBER(15):=0;
BEGIN

l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  -- implicit commit
  FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                               tabname => 'PJI_RM_AGGR_RES2',
                               percent => 10,
                               degree  => BIS_COMMON_PARAMETERS.
                                          GET_DEGREE_OF_PARALLELISM);
  -- implicit commit
  FND_STATS.GATHER_COLUMN_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                tabname => 'PJI_RM_AGGR_RES2',
                                colname => 'PERSON_ID',
                                percent => 10,
                                degree  => BIS_COMMON_PARAMETERS.
                                           GET_DEGREE_OF_PARALLELISM);

IF (NOT PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
(
	l_process,
	'PJI_RM_SUM_AVL.UPDATE_RES_STA_FOR_RUN2(p_worker_id);'
)) THEN
	RETURN;
END IF;

--This update should be done only if the process has run
--for old records BUT HAS NOT run for new records. If the
--process has run for even one new record, then this update
--should not happen
SELECT count(*)
INTO l_res_process_cnt
FROM PJI_RM_RES_BATCH_MAP
where worker_id IS NOT NULL
AND   worker_status IS NOT NULL;

SELECT count(*)
INTO l_res_full_cnt
FROM PJI_RM_RES_BATCH_MAP;

IF (l_res_full_cnt = l_res_process_cnt) THEN

	--update all resources with null values for
	--worker and status to make it available
	--for next run with new fact records

	UPDATE PJI_RM_RES_BATCH_MAP
	SET worker_id = null,
	    worker_status = null;
END IF;

PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
(
	l_process,
	'PJI_RM_SUM_AVL.UPDATE_RES_STA_FOR_RUN2(p_worker_id);'
);

COMMIT;

END UPDATE_RES_STA_FOR_RUN2;

/*
This procedure is used to insert rows
in the resource status table. The
population and constant update of this
status table helps in maintaining dynamic
pooling of workers and also help in starting
process just prior to the point of error
during run time
*/

PROCEDURE INS_INTO_RES_STATUS
	(p_worker_id	IN NUMBER)
IS
--Defining local variables
l_process 		VARCHAR2(30);
l_count_res_status 	NUMBER := 0;
BEGIN

l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

IF (NOT PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
(
	l_process,
	'PJI_RM_SUM_AVL.INS_INTO_RES_STATUS(p_worker_id);'
)) THEN
	RETURN;
END IF;

SELECT COUNT(*)
INTO l_count_res_status
FROM PJI_RM_RES_BATCH_MAP;

IF (l_count_res_status = 0) THEN
--If this is the first time program is being run then'
--no data would be present, so insert the resources
--one needs to process
	INSERT INTO PJI_RM_RES_BATCH_MAP(person_id)
	SELECT DISTINCT person_id from PJI_RM_AGGR_RES2;
END IF;

-- implicit commit
FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                             tabname => 'PJI_RM_RES_BATCH_MAP',
                             percent => 10,
                             degree  => BIS_COMMON_PARAMETERS.
                                        GET_DEGREE_OF_PARALLELISM);
-- implicit commit
FND_STATS.GATHER_COLUMN_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                              tabname => 'PJI_RM_RES_BATCH_MAP',
                              colname => 'PERSON_ID',
                              percent => 10,
                              degree  => BIS_COMMON_PARAMETERS.
                                         GET_DEGREE_OF_PARALLELISM);

PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
(
	l_process,
	'PJI_RM_SUM_AVL.INS_INTO_RES_STATUS(p_worker_id);'
);

COMMIT;

END INS_INTO_RES_STATUS;

/*
This procedure is used to refresh the
organization level materialized view
for resource duration availability buckets
*/

PROCEDURE REFRESH_AV_ORGO_F_MV
	(p_worker_id	IN NUMBER)
IS
--Defining local variables
l_process 		VARCHAR2(30);
l_p_degree        	NUMBER := 0;
l_extraction_type varchar2(30);
l_pji_schema      varchar2(30);
l_apps_schema     varchar2(30);
l_errbuf          varchar2(255);
l_retcode         varchar2(255);
BEGIN

l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

IF (NOT PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
(
	l_process,
	'PJI_RM_SUM_AVL.REFRESH_AV_ORGO_F_MV(p_worker_id);'
)) THEN
	RETURN;
END IF;
l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                     (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

if (upper(nvl(FND_PROFILE.VALUE('PJI_USE_DBI_RSG'), 'N')) = 'Y' and
    l_extraction_type <> 'PARTIAL') then
  return;
end if;

l_pji_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
l_apps_schema := PJI_UTILS.GET_APPS_SCHEMA_NAME;
l_p_degree := BIS_COMMON_PARAMETERS.GET_DEGREE_OF_PARALLELISM();
    if (l_p_degree = 1) then
      l_p_degree := 0;
    end if;

FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_pji_schema,
                             TABNAME => 'PJI_ORG_DENORM',
                             PERCENT => 10,
                             DEGREE  => l_p_degree);

IF (l_extraction_type = 'FULL') THEN
  PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                          l_retcode,
                          'PJI_AV_ORGO_F_MV',
                          'C',
                          'N');
ELSE

	FND_STATS.GATHER_TABLE_STATS
	(OWNNAME => l_pji_schema,
	   TABNAME => 'MLOG$_PJI_AV_ORG_F',
	   PERCENT => 10,
           DEGREE  => l_p_degree);

        PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                                l_retcode,
                                'PJI_AV_ORGO_F_MV',
                                'F',
                                'N');

END IF;

if (l_extraction_type <> 'INCREMENTAL') then
FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                             tabname => 'PJI_AV_ORGO_F_MV',
                             percent => 10,
                             degree  => l_p_degree);
end if;

PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
(
	l_process,
	'PJI_RM_SUM_AVL.REFRESH_AV_ORGO_F_MV(p_worker_id);'
);

COMMIT;

END REFRESH_AV_ORGO_F_MV;

/*
This procedure is used to refresh the
organization level materialized view
for current resource availability
*/

PROCEDURE REFRESH_CA_ORGO_F_MV
	(p_worker_id	IN NUMBER)
IS
--Defining local variables
l_process 		VARCHAR2(30);
l_p_degree        	NUMBER := 0;
l_extraction_type varchar2(30);
l_pji_schema      varchar2(30);
l_apps_schema     varchar2(30);
l_errbuf          varchar2(255);
l_retcode         varchar2(255);
BEGIN

l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

IF (NOT PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
(
	l_process,
	'PJI_RM_SUM_AVL.REFRESH_CA_ORGO_F_MV(p_worker_id);'
)) THEN
	RETURN;
END IF;
l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                     (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

if (upper(nvl(FND_PROFILE.VALUE('PJI_USE_DBI_RSG'), 'N')) = 'Y' and
    l_extraction_type <> 'PARTIAL') then
  return;
end if;

l_pji_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
l_apps_schema := PJI_UTILS.GET_APPS_SCHEMA_NAME;
l_p_degree := BIS_COMMON_PARAMETERS.GET_DEGREE_OF_PARALLELISM();
    if (l_p_degree = 1) then
      l_p_degree := 0;
    end if;

IF (l_extraction_type = 'FULL') THEN
  PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                          l_retcode,
                          'PJI_CA_ORGO_F_MV',
                          'C',
                          'N');
ELSE

	FND_STATS.GATHER_TABLE_STATS
	(OWNNAME => l_pji_schema,
	   TABNAME => 'MLOG$_PJI_CA_ORG_F',
	   PERCENT => 10,
           DEGREE  => l_p_degree);

        PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                                l_retcode,
                                'PJI_CA_ORGO_F_MV',
                                'F',
                                'N');

END IF;

if (l_extraction_type <> 'INCREMENTAL') then
FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                             tabname => 'PJI_CA_ORGO_F_MV',
                             percent => 10,
                             degree  => l_p_degree);
end if;

PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
(
	l_process,
	'PJI_RM_SUM_AVL.REFRESH_CA_ORGO_F_MV(p_worker_id);'
);

COMMIT;

END REFRESH_CA_ORGO_F_MV;

END PJI_RM_SUM_AVL;

/
