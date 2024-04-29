--------------------------------------------------------
--  DDL for Package Body HRI_OPL_PER_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_PER_PERSON" AS
/* $Header: hripperdim.pkb 120.0.12000000.2 2007/04/12 13:27:38 smohapat noship $ */
--
-- Types required to support tables of column values.
--
-- @@ Code specific to this view/table below
-- @@ INTRUCTION TO DEVELOPER:
-- @@ 1/ For each column in your 'source view' create a TYPE in the format
-- @@    g_<col_name>_type.  Each TYPE should be a table of 'target table.
-- @@    column'%TYPE indexed by binary_integer. i.e.:
-- @@
-- @@    TYPE g_<col_name>_type IS TABLE OF
-- @@      <target_table>%TYPE
-- @@      INDEX BY BINARY_INTEGER;
-- @@
--


TYPE g_per_work_phone_type
IS TABLE OF  hri_cs_per_person_ct.per_work_phone%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_work_location_type
IS TABLE OF  hri_cs_per_person_ct.per_work_location%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_adt_ppf_person_id_type
IS TABLE OF  hri_cs_per_person_ct.adt_ppf_person_id%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_adt_ppf_eff_start_date_type
IS TABLE OF  hri_cs_per_person_ct.adt_ppf_effctv_start_date%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_adt_ppf_eff_end_date_type
IS TABLE OF  hri_cs_per_person_ct.adt_ppf_effctv_end_date%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_buyer_flag_code_type
IS TABLE OF  hri_cs_per_person_ct.per_buyer_flag_code%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_date_of_birth_type
IS TABLE OF  hri_cs_per_person_ct.per_date_of_birth%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_middle_names_type
IS TABLE OF  hri_cs_per_person_ct.per_middle_names%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_known_as_type
IS TABLE OF  hri_cs_per_person_ct.per_known_as%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_honors_type
IS TABLE OF  hri_cs_per_person_ct.per_honors%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_pre_name_adjunct_type
IS TABLE OF  hri_cs_per_person_ct.per_pre_name_adjunct%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_apl_number_type
IS TABLE OF  hri_cs_per_person_ct.per_apl_number%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_emp_number_type
IS TABLE OF  hri_cs_per_person_ct.per_emp_number%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_cwk_number_type
IS TABLE OF  hri_cs_per_person_ct.per_cwk_number%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_apl_flag_crnt_code_type
IS TABLE OF  hri_cs_per_person_ct.per_apl_flag_crnt_code%TYPE
INDEX BY BINARY_INTEGER;


TYPE g_per_emp_flag_crnt_code_type
IS TABLE OF  hri_cs_per_person_ct.per_emp_flag_crnt_code%TYPE
INDEX BY BINARY_INTEGER;


TYPE g_per_cwk_flag_crnt_code_type
IS TABLE OF  hri_cs_per_person_ct.per_cwk_flag_crnt_code%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_person_name_lcl_type
IS TABLE OF  hri_cs_per_person_ct.per_person_name_lcl%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_first_name_type
IS TABLE OF  hri_cs_per_person_ct.per_first_name%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_place_of_birth_type
IS TABLE OF  hri_cs_per_person_ct.per_place_of_birth%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_last_name_prev_type
IS TABLE OF  hri_cs_per_person_ct.per_last_name_prev%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_order_by_type
IS TABLE OF  hri_cs_per_person_ct.per_order_by%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_person_name_gbl_type
IS TABLE OF  hri_cs_per_person_ct.per_person_name_gbl%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_last_name_type
IS TABLE OF  hri_cs_per_person_ct.per_last_name%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_wrkr_crnt_flag_code_type
IS TABLE OF  hri_cs_per_person_ct.per_worker_crnt_flag_code%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_country_of_birth_type
IS TABLE OF  hri_cs_per_person_ct.per_country_of_birth%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_date_of_death_type
IS TABLE OF  hri_cs_per_person_ct.per_date_of_death%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_work_email_type
IS TABLE OF  hri_cs_per_person_ct.per_work_email%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_title_type
IS TABLE OF  hri_cs_per_person_ct.per_title%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_suffix_type
IS TABLE OF  hri_cs_per_person_ct.per_suffix%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_person_name_type
IS TABLE OF  hri_cs_per_person_ct.per_person_name%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_person_pk_type
IS TABLE OF  hri_cs_per_person_ct.per_person_pk%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_marital_status_crnt_type
IS TABLE OF  hri_cs_per_person_ct.per_marital_status_crnt%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_gender_crnt_type
IS TABLE OF  hri_cs_per_person_ct.per_gender_crnt%TYPE
INDEX BY BINARY_INTEGER;



--
-- @@ Code specific to this view/table below ENDS
--
--
-- PLSQL tables representing database table columns
--

g_per_work_phone             g_per_work_phone_type ;
g_per_work_location          g_per_work_location_type ;
g_adt_ppf_person_id          g_adt_ppf_person_id_type ;
g_adt_ppf_effctv_start_date  g_adt_ppf_eff_start_date_type ;
g_adt_ppf_effctv_end_date    g_adt_ppf_eff_end_date_type ;
g_per_buyer_flag_code        g_per_buyer_flag_code_type ;
g_per_date_of_birth          g_per_date_of_birth_type ;
g_per_middle_names           g_per_middle_names_type ;
g_per_known_as               g_per_known_as_type ;
g_per_honors                 g_per_honors_type ;
g_per_pre_name_adjunct       g_per_pre_name_adjunct_type ;
g_per_apl_number             g_per_apl_number_type ;
g_per_emp_number             g_per_emp_number_type ;
g_per_cwk_number             g_per_cwk_number_type ;
g_per_apl_flag_crnt_code     g_per_apl_flag_crnt_code_type ;
g_per_emp_flag_crnt_code     g_per_emp_flag_crnt_code_type ;
g_per_cwk_flag_crnt_code     g_per_cwk_flag_crnt_code_type ;
g_per_person_name_lcl        g_per_person_name_lcl_type ;
g_per_first_name             g_per_first_name_type ;
g_per_place_of_birth         g_per_place_of_birth_type ;
g_per_last_name_prev         g_per_last_name_prev_type ;
g_per_order_by               g_per_order_by_type ;
g_per_person_name_gbl        g_per_person_name_gbl_type ;
g_per_last_name              g_per_last_name_type ;
g_per_worker_crnt_flag_code  g_per_wrkr_crnt_flag_code_type ;
g_per_country_of_birth       g_per_country_of_birth_type ;
g_per_date_of_death          g_per_date_of_death_type ;
g_per_work_email             g_per_work_email_type ;
g_per_title                  g_per_title_type ;
g_per_suffix                 g_per_suffix_type ;
g_per_person_name            g_per_person_name_type ;
g_per_person_pk              g_per_person_pk_type ;
g_per_marital_status_crnt    g_per_marital_status_crnt_type;
g_per_gender_crnt            g_per_gender_crnt_type;


--
-- Holds the range for which the collection is to be run.
--
g_start_date    DATE;
g_end_date      DATE;
g_full_refresh  VARCHAR2(10);
--
-- The HRI schema
--
g_schema                  VARCHAR2(400);
--
-- Set to true to output to a concurrent log file
--
g_conc_request_flag       BOOLEAN := FALSE;
--
-- Number of rows bulk processed at a time
--
g_chunk_size              PLS_INTEGER;
--
-- End of time date
--
-- CONSTANTS
-- =========
--
-- @@ Code specific to this view/table below
-- @@ in the call to hri_bpl_conc_log.get_last_collect_to_date
-- @@ change param1/2 to be the concurrent program short name,
-- @@ and the target table name respectively.
--
g_target_table          VARCHAR2(30) DEFAULT 'hri_cs_per_person_ct';
g_cncrnt_prgrm_shrtnm   VARCHAR2(30) DEFAULT 'HRI_CS_PER_PERSON_CT';
--
-- @@ Code specific to this view/table below ENDS
--
-- constants that hold the value that indicates to full refresh or not.
--
g_is_full_refresh    VARCHAR2(5) DEFAULT 'Y';
g_not_full_refresh   VARCHAR2(5) DEFAULT 'N';

--
-- WHO Column data
--

g_sysdate           DATE := sysdate;
g_user              NUMBER(10):= fnd_global.user_id;

--
-- ----------------------------------------------------------------------------
-- Runs given sql statement dynamically
-- ----------------------------------------------------------------------------
PROCEDURE run_sql_stmt_noerr(p_sql_stmt   VARCHAR2)
IS
BEGIN

  EXECUTE IMMEDIATE p_sql_stmt;

EXCEPTION WHEN OTHERS THEN

  null;

END run_sql_stmt_noerr;

-- -------------------------------------------------------------------------
--
-- Inserts row into concurrent program log when the g_conc_request_flag has
-- been set to TRUE, otherwise does nothing
--

PROCEDURE output(p_text  VARCHAR2)
  IS
  --
BEGIN
  --
  -- Write to the concurrent request log if called from a concurrent request
  --
  IF (g_conc_request_flag = TRUE) THEN
    --
    -- Put text to log file
    --
    fnd_file.put_line(FND_FILE.log, p_text);
    --
  END IF;
  --
END output;
--
-- -------------------------------------------------------------------------
--
-- Recovers rows to insert when an exception occurs
--
PROCEDURE recover_insert_rows(p_stored_rows_to_insert NUMBER) IS

BEGIN
  --
  -- loop through rows still to insert one at a time
  --
  FOR i IN 1..p_stored_rows_to_insert LOOP
    --
    -- Trap unique constraint errors
    --
    BEGIN
      --
      -- @@ Code specific to this view/table below
      -- @@ INTRUCTION TO DEVELOPER:
      -- @@ 1/ For each column in your view put a column in the insert
      -- @@ statement below.
      -- @@ 2/ Prefix each column in the VALUE clause with g_
      -- @@ 3/ make sure (i) is at the end of each column in the value clause
      --

      INSERT INTO hri_cs_per_person_ct(
  		 per_work_phone
		,per_work_location
		,adt_ppf_person_id
		,adt_ppf_effctv_start_date
		,adt_ppf_effctv_end_date
		,per_buyer_flag_code
		,per_date_of_birth
		,per_middle_names
		,per_known_as
		,per_honors
		,per_pre_name_adjunct
		,per_apl_number
		,per_emp_number
		,per_cwk_number
		,per_apl_flag_crnt_code
		,per_emp_flag_crnt_code
		,per_cwk_flag_crnt_code
		,per_person_name_lcl
		,per_first_name
		,per_place_of_birth
		,per_last_name_prev
		,per_order_by
		,per_person_name_gbl
		,per_last_name
		,per_worker_crnt_flag_code
		,per_country_of_birth
		,per_date_of_death
		,per_work_email
		,per_title
		,per_suffix
		,per_person_name
		,per_person_pk
                ,per_marital_status_crnt
                ,per_gender_crnt
		)
      VALUES(	 g_per_work_phone(i)
		,g_per_work_location(i)
		,g_adt_ppf_person_id(i)
		,g_adt_ppf_effctv_start_date(i)
		,g_adt_ppf_effctv_end_date(i)
		,g_per_buyer_flag_code(i)
		,g_per_date_of_birth(i)
		,g_per_middle_names(i)
		,g_per_known_as(i)
		,g_per_honors(i)
	  	,g_per_pre_name_adjunct(i)
		,g_per_apl_number(i)
		,g_per_emp_number(i)
		,g_per_cwk_number(i)
		,g_per_apl_flag_crnt_code(i)
		,g_per_emp_flag_crnt_code(i)
		,g_per_cwk_flag_crnt_code(i)
		,g_per_person_name_lcl(i)
		,g_per_first_name(i)
		,g_per_place_of_birth(i)
		,g_per_last_name_prev(i)
		,g_per_order_by(i)
                ,g_per_person_name_gbl(i)
                ,g_per_last_name(i)
                ,g_per_worker_crnt_flag_code(i)
                ,g_per_country_of_birth(i)
                ,g_per_date_of_death(i)
                ,g_per_work_email(i)
                ,g_per_title(i)
                ,g_per_suffix(i)
                ,g_per_person_name(i)
                ,g_per_person_pk(i)
                ,g_per_marital_status_crnt(i)
                ,g_per_gender_crnt(i)
		);
      --
      -- @@Code specific to this view/table below ENDS
      --
    EXCEPTION
      --
      WHEN OTHERS THEN
        --
        -- Probable overlap on date tracked assignment rows
        --
        --
        output(sqlerrm);
        output(sqlcode);
        --
      --
    END;
    --
  END LOOP;
  --
  COMMIT;
  --
END recover_insert_rows;
--
-- -------------------------------------------------------------------------
--
-- Bulk inserts rows from global temporary table to database table
--
PROCEDURE bulk_insert_rows(p_stored_rows_to_insert NUMBER) IS
  --
BEGIN
  --
  -- insert chunk of rows
  --
  -- @@ Code specific to this view/table below
  -- @@ INTRUCTION TO DEVELOPER:
  -- @@ 1/ For each column in your view put a column in the insert statement
  --       below.
  -- @@ 2/ Prefix each column in the VALUE clause with g_
  -- @@ 3/ make sure (i) is at the end of each column in the value clause
  --
   FORALL i IN 1..p_stored_rows_to_insert
      INSERT INTO hri_cs_per_person_ct(
  		 per_work_phone
		,per_work_location
		,adt_ppf_person_id
		,adt_ppf_effctv_start_date
		,adt_ppf_effctv_end_date
		,per_buyer_flag_code
		,per_date_of_birth
		,per_middle_names
		,per_known_as
		,per_honors
		,per_pre_name_adjunct
		,per_apl_number
		,per_emp_number
		,per_cwk_number
		,per_apl_flag_crnt_code
		,per_emp_flag_crnt_code
		,per_cwk_flag_crnt_code
		,per_person_name_lcl
		,per_first_name
		,per_place_of_birth
		,per_last_name_prev
		,per_order_by
		,per_person_name_gbl
		,per_last_name
		,per_worker_crnt_flag_code
		,per_country_of_birth
		,per_date_of_death
		,per_work_email
		,per_title
		,per_suffix
		,per_person_name
		,per_person_pk
                ,per_marital_status_crnt
                ,per_gender_crnt
                )
          VALUES(g_per_work_phone(i)
		,g_per_work_location(i)
		,g_adt_ppf_person_id(i)
		,g_adt_ppf_effctv_start_date(i)
		,g_adt_ppf_effctv_end_date(i)
		,g_per_buyer_flag_code(i)
		,g_per_date_of_birth(i)
		,g_per_middle_names(i)
		,g_per_known_as(i)
		,g_per_honors(i)
	  	,g_per_pre_name_adjunct(i)
		,g_per_apl_number(i)
		,g_per_emp_number(i)
		,g_per_cwk_number(i)
		,g_per_apl_flag_crnt_code(i)
		,g_per_emp_flag_crnt_code(i)
		,g_per_cwk_flag_crnt_code(i)
		,g_per_person_name_lcl(i)
		,g_per_first_name(i)
		,g_per_place_of_birth(i)
		,g_per_last_name_prev(i)
		,g_per_order_by(i)
                ,g_per_person_name_gbl(i)
                ,g_per_last_name(i)
                ,g_per_worker_crnt_flag_code(i)
                ,g_per_country_of_birth(i)
                ,g_per_date_of_death(i)
                ,g_per_work_email(i)
                ,g_per_title(i)
                ,g_per_suffix(i)
                ,g_per_person_name(i)
                ,g_per_person_pk(i)
                ,g_per_marital_status_crnt(i)
                ,g_per_gender_crnt(i)
        	);

  --
  -- @@Code specific to this view/table below ENDS
  --
  -- commit the chunk of rows
  --
  COMMIT;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    -- Probable unique constraint error
    --
    ROLLBACK;
    --
    recover_insert_rows(p_stored_rows_to_insert);
    --
  --
END bulk_insert_rows;
--
-- -------------------------------------------------------------------------
--
-- Loops through table and collects into table structure.
--
PROCEDURE Incremental_Update IS
  --
BEGIN
  --
  -- @@ Code specific to this view/table below
  -- @@ INTRUCTION TO DEVELOPER:
  -- @@ 1/ Change the code below to reflect the columns in your view / table
  -- @@ 2/ Change the FROM, INSERT, DELETE statements to point at the relevant
  -- @@    source view / table
  --
  -- Insert completly new rows
  --
  -- log('Doing insert.');

  INSERT INTO hri_cs_per_person_ct(
  		 per_work_phone
		,per_work_location
		,adt_ppf_person_id
		,adt_ppf_effctv_start_date
		,adt_ppf_effctv_end_date
		,per_buyer_flag_code
		,per_date_of_birth
		,per_middle_names
		,per_known_as
		,per_honors
		,per_pre_name_adjunct
		,per_apl_number
		,per_emp_number
		,per_cwk_number
		,per_apl_flag_crnt_code
		,per_emp_flag_crnt_code
		,per_cwk_flag_crnt_code
		,per_person_name_lcl
		,per_first_name
		,per_place_of_birth
		,per_last_name_prev
		,per_order_by
		,per_person_name_gbl
		,per_last_name
		,per_worker_crnt_flag_code
		,per_country_of_birth
		,per_date_of_death
		,per_work_email
		,per_title
		,per_suffix
		,per_person_name
		,per_person_pk
                ,per_marital_status_crnt
                ,per_gender_crnt
                )
         SELECT NVL(per.work_telephone,'NA_EDW')
               ,NVL(per.internal_location,'NA_EDW')
               ,per.person_id
               ,per.effective_start_date
               ,per.effective_end_date
               ,case
                when poa.agent_id = per.person_id
                 and (
                      poa.end_date_active is null
                      or
                      trunc(sysdate) between poa.start_date_active
                                         and poa.end_date_active
                      )
                then 'Y'
                else 'N'
                end
               ,NVL(per.date_of_birth,hr_general.start_of_time)
               ,per.middle_names
               ,per.known_as
               ,per.honors
               ,per.pre_name_adjunct
               ,NVL(per.applicant_number,'NA_EDW')
               ,NVL(per.employee_number,'NA_EDW')
               ,NVL(per.npw_number,'NA_EDW')
               ,per.current_applicant_flag
               ,per.current_employee_flag
               ,per.current_npw_flag
               ,per.local_name
               ,per.first_name
               ,NVL(per.town_of_birth,'NA_EDW')
               ,per.previous_last_name
               ,per.order_name
               ,per.global_name
               ,per.last_name
               ,decode(nvl(per.current_employee_flag,'N'),'Y','Y',current_npw_flag)
               ,NVL(per.country_of_birth,'NA_EDW')
               ,NVL(per.date_of_death,hr_general.end_of_time)
               ,NVL(per.email_address,'NA_EDW')
               ,per.title
               ,per.suffix
               ,per.first_name
               ,per.person_id
               ,NVL(per.marital_status,'NA_EDW')
               ,NVL(per.sex,'NA_EDW')
  FROM per_all_people_f per
      ,po_agents        poa
  WHERE per.person_id  = poa.agent_id(+)
   AND TRUNC(sysdate) between per.effective_start_date and per.effective_end_date
   AND NOT EXISTS (SELECT 'x'
                  FROM   hri_cs_per_person_ct tbl
                  WHERE  per.person_id              = tbl.per_person_pk
                 );

  -- log('Insert >'||TO_CHAR(sql%rowcount));
  -- log('Doing update.');
  --
  --------------------------------------------------------
  --Update Strategy for change in buyer status
  --Nos of DB writes is limited to the rows changed only.
  --------------------------------------------------------


 UPDATE hri_cs_per_person_ct tbl
   SET (per_buyer_flag_code) = (decode(tbl.per_buyer_flag_code, 'Y', 'N', 'Y'))
 WHERE tbl.per_person_pk in
       (SELECT ct.per_person_pk person_id
          FROM (SELECT tbl.per_person_pk,
                       tbl.per_buyer_flag_code collected_flag,
                       case
                        when poa.agent_id = tbl.per_person_pk
                         and (
                          poa.end_date_active is null
                          or
                          trunc(sysdate) between poa.start_date_active
                                         and poa.end_date_active
                              )
                          then 'Y'
                          else 'N'
                          end  buyer_flag
                  FROM hri_cs_per_person_ct tbl, po_agents poa
                 WHERE tbl.per_person_pk = poa.agent_id(+)
                 )ct
         WHERE ct.buyer_flag <> ct.collected_flag
         );


 -- Update CT with PAPF attribs

  UPDATE hri_cs_per_person_ct tbl
        SET (    per_work_phone
		,per_work_location
		,adt_ppf_person_id
		,adt_ppf_effctv_start_date
		,adt_ppf_effctv_end_date
		,per_date_of_birth
		,per_middle_names
		,per_known_as
		,per_honors
		,per_pre_name_adjunct
		,per_apl_number
		,per_emp_number
		,per_cwk_number
		,per_apl_flag_crnt_code
		,per_emp_flag_crnt_code
		,per_cwk_flag_crnt_code
		,per_person_name_lcl
		,per_first_name
		,per_place_of_birth
		,per_last_name_prev
		,per_order_by
		,per_person_name_gbl
		,per_last_name
		,per_worker_crnt_flag_code
		,per_country_of_birth
		,per_date_of_death
		,per_work_email
		,per_title
		,per_suffix
		,per_person_name
		,per_person_pk
                ,per_marital_status_crnt
                ,per_gender_crnt
                )=
      (SELECT   per.work_telephone
               ,per.internal_location
               ,per.person_id
               ,per.effective_start_date
               ,per.effective_end_date
               ,per.date_of_birth
               ,per.middle_names
               ,per.known_as
               ,per.honors
               ,per.pre_name_adjunct
               ,per.applicant_number
               ,per.employee_number
               ,per.npw_number
               ,per.current_applicant_flag
               ,per.current_employee_flag
               ,per.current_npw_flag
               ,per.global_name
               ,per.first_name
               ,per.town_of_birth
               ,per.previous_last_name
               ,per.order_name
               ,per.global_name
               ,per.last_name
               ,DECODE(nvl(per.current_employee_flag,'N'),'Y','Y',current_npw_flag)
               ,per.country_of_birth
               ,per.date_of_death
               ,per.email_address
               ,per.title
               ,per.suffix
               ,per.first_name
               ,per.person_id
               ,per.marital_status
               ,per.sex
           FROM per_all_people_f     per
           WHERE per.person_id              = tbl.per_person_pk
	   AND   TRUNC(sysdate)
                 between per.effective_start_date and per.effective_end_date
	   )
    WHERE tbl.per_person_pk in
	             (SELECT  per1.person_id
		      from per_all_people_f per1
		      where per1.last_update_date
                      between g_start_date and g_end_date
		      );
  --
  -- log('Update >'||TO_CHAR(sql%rowcount));
  --
  -- Delete rows that no longer exist in the source view.
  --
  -- log('Doing delete.');


  DELETE
  FROM hri_cs_per_person_ct tbl
  WHERE NOT EXISTS (SELECT 'x'
                    FROM  per_all_people_f per
                    WHERE per.person_id            = tbl.per_person_pk
		    AND  TRUNC(sysdate) BETWEEN
                    per.effective_start_date AND per.effective_end_date )
   and tbl.per_person_pk <> -1;


  -- log('Delete >'||TO_CHAR(sql%rowcount));
  --
  -- @@ Code specific to this view/table below ENDS
  --
  COMMIT;
  -- log('Done incremental update.');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    Output('Failure in incremental update process.');
    --
    RAISE;
    --
    --

END;


--
-- -------------------------------------------------------------------------
--
--
-- Loops through table and collects into table structure.
--
PROCEDURE Full_Refresh IS
  --
  -- Select all from the source view for materialization
  --
  -- @@ Code specific to this view/table below
  -- @@ INTRUCTION TO DEVELOPER:
  -- @@ 1/ Change the select beloe to select all the columns from your view
  -- @@ 2/ Change the FROM statement to point at the relevant source view
  --
  CURSOR source_view_csr IS
         SELECT NVL(per.work_telephone,'NA_EDW')
               ,NVL(per.internal_location,'NA_EDW')
               ,per.person_id
               ,per.effective_start_date
               ,per.effective_end_date
               ,case
                when poa.agent_id = per.person_id
                 and (
                      poa.end_date_active is null
                      or
                      trunc(sysdate) between poa.start_date_active
                                         and poa.end_date_active
                      )
                then 'Y'
                else 'N'
                end
               ,NVL(per.date_of_birth,hr_general.start_of_time)
               ,per.middle_names
               ,per.known_as
               ,per.honors
               ,per.pre_name_adjunct
               ,NVL(per.applicant_number,'NA_EDW')
               ,NVL(per.employee_number,'NA_EDW')
               ,NVL(per.npw_number,'NA_EDW')
               ,per.current_applicant_flag
               ,per.current_employee_flag
               ,per.current_npw_flag
               ,per.local_name
               ,per.first_name
               ,NVL(per.town_of_birth,'NA_EDW')
               ,per.previous_last_name
               ,per.order_name
               ,per.global_name
               ,per.last_name
               ,decode(nvl(per.current_employee_flag,'N'),'Y','Y',current_npw_flag)
               ,NVL(per.country_of_birth,'NA_EDW')
               ,NVL(per.date_of_death,hr_general.end_of_time)
               ,NVL(per.email_address,'NA_EDW')
               ,per.title
               ,per.suffix
               ,per.first_name
               ,per.person_id
               ,NVL(per.marital_status,'NA_EDW')
               ,NVL(per.sex,'NA_EDW')
  FROM per_all_people_f  per,
       po_agents         poa
  WHERE TRUNC(sysdate) between per.effective_start_date and per.effective_end_date
     AND  per.person_id  = poa.agent_id(+);

  --
  -- @@Code specific to this view/table below ENDS
  --
  l_exit_main_loop       BOOLEAN := FALSE;
  l_rows_fetched         PLS_INTEGER := g_chunk_size;
  l_sql_stmt      VARCHAR2(2000);
  --
BEGIN
  -- log('here ...');
  --
  -- Truncate the target table prior to full refresh.
  --
  l_sql_stmt := 'TRUNCATE TABLE ' || g_schema || '.'||g_target_table;
  -- log('>'||l_sql_stmt||'<');
  --
  EXECUTE IMMEDIATE(l_sql_stmt);
  -- log('truncated ...');


  --Disable WHO TRIGGERS on table prior to full refresh

  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_PER_PERSON_CT_WHO DISABLE');

  -- Drop all the INDEXES on the table
  hri_utl_ddl.log_and_drop_indexes
         (p_application_short_name => 'HRI',
          p_table_name             => 'HRI_CS_PER_PERSON_CT',
          p_table_owner            =>  g_schema);



  --
  --Create an Unassigned row
  --

   insert into hri_cs_per_person_ct(
         PER_PERSON_PK
        ,PER_PERSON_NAME
        ,PER_ORDER_BY
        ,PER_PERSON_NAME_GBL
        ,PER_PERSON_NAME_LCL
        ,PER_FIRST_NAME
        ,PER_LAST_NAME
        ,PER_LAST_NAME_PREV
        ,PER_MIDDLE_NAMES
        ,PER_KNOWN_AS
        ,PER_HONORS
        ,PER_TITLE
        ,PER_SUFFIX
        ,PER_PRE_NAME_ADJUNCT
        ,PER_APL_NUMBER
        ,PER_EMP_NUMBER
        ,PER_CWK_NUMBER
        ,PER_APL_FLAG_CRNT_CODE
        ,PER_EMP_FLAG_CRNT_CODE
        ,PER_CWK_FLAG_CRNT_CODE
        ,PER_WORKER_CRNT_FLAG_CODE
        ,PER_BUYER_FLAG_CODE
        ,PER_DATE_OF_BIRTH
        ,PER_PLACE_OF_BIRTH
        ,PER_COUNTRY_OF_BIRTH
        ,PER_DATE_OF_DEATH
        ,PER_WORK_EMAIL
        ,PER_WORK_PHONE
        ,PER_WORK_LOCATION
        ,ADT_PPF_PERSON_ID
        ,ADT_PPF_EFFCTV_START_DATE
        ,ADT_PPF_EFFCTV_END_DATE
        ,PER_MARITAL_STATUS_CRNT
        ,PER_GENDER_CRNT  )
    select
          id
         ,id_char
         ,NULL
         ,id_char
         ,id_char
         ,id_char
         ,id_char
         ,id_char
         ,id_char
         ,NULL
         ,NULL
         ,NULL
         ,NULL
         ,NULL
         ,id_char
         ,id_char
         ,id_char
         ,id_char
         ,id_char
         ,id_char
         ,id_char
         ,id_char
         ,hr_general.end_of_time
         ,id_char
         ,id_char
         ,hr_general.end_of_time
         ,id_char
         ,id_char
         ,id_char
         ,id
         ,hr_general.end_of_time
         ,hr_general.end_of_time
         ,id_char
         ,id_char
        from hri_unassigned ;

    commit;

  --
  --
  -- Write timing information to log
  --
  output('Truncated the table:   '  ||
         to_char(sysdate,'HH24:MI:SS'));
  --
  -- open main cursor
  --
  -- log('open cursor ...');
  OPEN source_view_csr;
  --
  <<main_loop>>
  LOOP
    --
    -- bulk fetch rows limit the fetch to value of g_chunk_size
    --
    -- @@ Code specific to this view/table below
    -- @@ INTRUCTION TO DEVELOPER:
    -- @@ Change the bulk collect below to select all the columns from your
    -- @@ view
    --
    -- log('start fetch ...');
    -- log('>'||TO_CHAR(g_chunk_size)||'<');
    FETCH source_view_csr
    BULK COLLECT INTO
                 g_per_work_phone
		,g_per_work_location
		,g_adt_ppf_person_id
		,g_adt_ppf_effctv_start_date
		,g_adt_ppf_effctv_end_date
		,g_per_buyer_flag_code
		,g_per_date_of_birth
		,g_per_middle_names
		,g_per_known_as
		,g_per_honors
	  	,g_per_pre_name_adjunct
		,g_per_apl_number
		,g_per_emp_number
		,g_per_cwk_number
		,g_per_apl_flag_crnt_code
		,g_per_emp_flag_crnt_code
		,g_per_cwk_flag_crnt_code
		,g_per_person_name_lcl
		,g_per_first_name
		,g_per_place_of_birth
		,g_per_last_name_prev
		,g_per_order_by
                ,g_per_person_name_gbl
                ,g_per_last_name
                ,g_per_worker_crnt_flag_code
                ,g_per_country_of_birth
                ,g_per_date_of_death
                ,g_per_work_email
                ,g_per_title
                ,g_per_suffix
                ,g_per_person_name
                ,g_per_person_pk
                ,g_per_marital_status_crnt
                ,g_per_gender_crnt
    LIMIT g_chunk_size;
    -- log('finish fetch ...');
    --
    -- @@Code specific to this view/table below ENDS
    --
    -- check to see if the last row has been fetched
    --
    IF source_view_csr%NOTFOUND THEN
      --
      -- last row fetched, set exit loop flag
      --
      l_exit_main_loop := TRUE;
      --
      -- do we have any rows to process?
      --
      l_rows_fetched := MOD(source_view_csr%ROWCOUNT,g_chunk_size);
      --
      -- note: if l_rows_fetched > 0 then more rows are required to be
      -- processed and the l_rows_fetched will contain the exact number of
      -- rows left to process
      --
      IF l_rows_fetched = 0 THEN
        --
        -- no more rows to process so exit loop
        --
        EXIT main_loop;
      END IF;
    END IF;
    --
    -- bulk insert rows processed so far
    --
    -- log('call bulk ...');
    bulk_insert_rows (l_rows_fetched);
    -- log('end bulk ...');
    --
    -- exit loop if required
    --
    IF l_exit_main_loop THEN
      --
      EXIT main_loop;
      --
    END IF;
    --
  END LOOP;
  --
  CLOSE source_view_csr;

  --Enable WHO TRIGGERS

    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_PER_PERSON_CT_WHO ENABLE');

  --Enable INDEX

  hri_utl_ddl.recreate_indexes
       (p_application_short_name => 'HRI',
        p_table_name             => 'HRI_CS_PER_PERSON_CT',
        p_table_owner            =>  g_schema);

  --
  -- log('End ...');


EXCEPTION
  WHEN OTHERS THEN
    --
    -- unexpected error has occurred so close down
    -- main bulk cursor if it is open
    --
    IF source_view_csr%ISOPEN THEN
      --
      CLOSE source_view_csr;
      --
    END IF;
    --
    -- re-raise error
    RAISE;
    --
  --
END Full_Refresh;
--
-- -------------------------------------------------------------------------
-- Checks what mode you are running in, and if g_full_refresh =
-- g_is_full_refresh calls
-- Full_Refresh procedure, otherwise Incremental_Update is called.
--
PROCEDURE Collect IS
  --
BEGIN
  --
  -- If in full refresh mode chnage the dates so that the collection history
  -- is correctly maintained.
  --
  IF g_full_refresh = g_is_full_refresh THEN
    --
    g_start_date   := hr_general.start_of_time;
    g_end_date     := SYSDATE;
    --
    -- log('Doing full refresh.');
    Full_Refresh;
    --
  ELSE
    --
    -- log('Doing incremental update.');
    --
    -- If the passed in date range is NULL default it.
    --
    IF g_start_date IS NULL OR
       g_end_date   IS NULL
    THEN
    -- log('Input dates NULL.');
      --
      g_start_date   :=  fnd_date.displaydt_to_date(
                                  hri_bpl_conc_log.get_last_collect_to_date(
                                        g_cncrnt_prgrm_shrtnm
                                       ,g_target_table));
      --
      g_end_date     := SYSDATE;
      -- log('start >'||TO_CHAR(g_start_date));
      -- log('end >'||TO_CHAR(g_end_date));
      -- log('Defaulted input DATES.');
      --
    END IF;
    --
    -- log('Calling incremental update.');
    Incremental_Update;
    -- log('Completed incremental update.');
    --
  END IF;
  --
END Collect;
--
-- -------------------------------------------------------------------------
-- Checks if the Target table is Empty
--
FUNCTION Target_table_is_Empty RETURN BOOLEAN IS
  --
  -- @@ Code specific to this view/table below
  -- @@ INTRUCTION TO DEVELOPER:
  -- @@ Change the table in the FROM clause below to be the same as  your
  -- @@ target table.
  --
  CURSOR csr_recs_exist IS
  SELECT 'x'
  FROM   hri_cs_per_person_ct;
  --
  -- @@ Code specific to this view/table ENDS
  --
  l_exists_chr    VARCHAR2(1);
  l_exists        BOOLEAN;
  --
BEGIN
  --
  OPEN csr_recs_exist;
  --
  FETCH csr_recs_exist INTO l_exists_chr;
  --
  IF (csr_recs_exist%NOTFOUND)
  THEN
    --
    l_exists := TRUE;
    -- log('no data in table');
    --
  ELSE
    --
    l_exists := FALSE;
    -- log('data is in table');
    --
  END IF;
  --
  CLOSE csr_recs_exist;
  --
  RETURN l_exists;
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    CLOSE csr_recs_exist;
    RAISE;
    --
  --
END Target_table_is_Empty;
--
-- -------------------------------------------------------------------------
--
-- Main entry point to load the table.
--
PROCEDURE Load(p_chunk_size    IN NUMBER,
               p_start_date    IN VARCHAR2,
               p_end_date      IN VARCHAR2,
               p_full_refresh  IN VARCHAR2) IS
  --
  -- Variables required for table truncation.
  --
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
   --
BEGIN
  --
  output('PL/SQL Start:   ' || to_char(sysdate,'HH24:MI:SS'));
  --
  -- Set globals
  --
  g_start_date := to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
  g_end_date   := to_date(p_end_date,   'YYYY/MM/DD HH24:MI:SS');

  --
  IF p_chunk_size IS NULL
  THEN
    --
    g_chunk_size := 500;
    --
  ELSE
    --
    g_chunk_size   := p_chunk_size;
    --
  END IF;
  --
  IF p_full_refresh IS NULL
  THEN
    --
    g_full_refresh := g_not_full_refresh;
    --
  ELSE
    --
    g_full_refresh := p_full_refresh;
    --
  END IF;
  --
  -- If the target table is empty default to full refresh.
  --
  IF Target_table_is_Empty
  THEN
    --
    output('Target table '||g_target_table||
           ' is empty, so doing a full refresh.');
    -- log('Doing a full refresh....');
    --
    g_full_refresh := g_is_full_refresh;

    --
  END IF;
  --
  -- log('p_chunk_size>'||TO_CHAR(g_chunk_size)||'<');
  -- Find the schema we are running in.
  --
  IF NOT fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, g_schema)
  THEN
    --
    -- Could not find the schema raising exception.
    --
    output('Could not find schema to run in.');
    --
    -- log('Could not find schema.');
    RAISE NO_DATA_FOUND;
    --
  END IF;
  --
  -- Update information about collection
  --
  -- log('Record process start.');
  /* double check correct val passed in below */
  hri_bpl_conc_log.record_process_start(g_cncrnt_prgrm_shrtnm);
  --
  -- Time at start
  --
  -- log('collect.');
  --
  -- Get HRI schema name - get_app_info populates l_schema
  --
  -- Insert new records
  --
  collect;
  -- log('collectED.');
  --
  -- Write timing information to log
  --
  output('Finished changes to the table:  '  ||
         to_char(sysdate,'HH24:MI:SS'));
  --
  -- Gather index stats
  --
  -- log('gather stats.');
  fnd_stats.gather_table_stats(g_schema, g_target_table);
  --
  -- Write timing information to log
  --
  output('Gathered stats:   '  ||
         to_char(sysdate,'HH24:MI:SS'));
  --
  -- log('log end.');
  hri_bpl_conc_log.log_process_end(
        p_status         => TRUE,
        p_period_from    => TRUNC(g_start_date),
        p_period_to      => TRUNC(g_end_date),
        p_attribute1     => p_full_refresh,
        p_attribute2     => p_chunk_size);
  -- log('-END-');
  --

EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    ROLLBACK;
    RAISE;
    --
  --
END Load;
--
-- -------------------------------------------------------------------------
--
-- Entry point to be called from the concurrent manager
--
PROCEDURE Load(errbuf          OUT NOCOPY VARCHAR2,
               retcode         OUT NOCOPY VARCHAR2,
               p_chunk_size    IN NUMBER,
               p_start_date    IN VARCHAR2,
               p_end_date      IN VARCHAR2,
               p_full_refresh  IN VARCHAR2)
IS
  --
BEGIN
  --
  -- Enable output to concurrent request log
  --
  g_conc_request_flag := TRUE;
  --
  load(p_chunk_size   => p_chunk_size,
       p_start_date   => p_start_date,
       p_end_date     => p_end_date,
       p_full_refresh => p_full_refresh);
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    errbuf  := SQLERRM;
    retcode := SQLCODE;
    --
  --
END load;

END HRI_OPL_PER_PERSON;

/
