--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_CODE_ASSIGNMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_CODE_ASSIGNMENTS" AS
/*$Header: ARHLCDAB.pls 120.35.12010000.2 2008/11/26 05:58:33 vsegu ship $*/


  l_row_id                              ROWID;
  l_batch_id                            NUMBER;
  l_code_assignment_id                  CODE_ASSIGNMENT_ID;
  l_party_orig_system                   PARTY_ORIG_SYSTEM;
  l_party_orig_system_reference         PARTY_ORIG_SYSTEM_REFERENCE;
  l_owner_table_id                      OWNER_TABLE_ID;
  l_class_category                      CLASS_CATEGORY;
  l_class_code                          CLASS_CODE;
  l_start_date_active                   START_DATE_ACTIVE;
  l_end_date_active                     END_DATE_ACTIVE;
  l_rank                                RANK;
  l_created_by_module                   CREATED_BY_MODULE;

  l_error_flag                          FLAG_COLUMN;
  l_action_mismatch_errors              FLAG_ERROR;
  l_missing_parent_error                FLAG_ERROR;
  l_class_category_null_errors          FLAG_ERROR;
  l_class_cate_foreignkey_errors        CLASS_CATEGORY;
  l_class_code_null_errors              FLAG_ERROR;
  l_class_code_lookup_errors            LOOKUP_ERROR;
  l_start_end_date_errors               FLAG_ERROR;
  l_identical_classcode_errors          FLAG_ERROR;
  l_multi_assign_errors                 FLAG_ERROR;
  l_leaf_node_errors                    FLAG_ERROR;
  l_start_date_errors 		        FLAG_ERROR;
  l_dss_security_errors			FLAG_COLUMN;
  l_insert_update_flag                  INSERT_UPDATE_FLAG;
  l_exception_exists                    FLAG_ERROR;


  l_error_party_id                      OWNER_TABLE_ID;
  l_error_class_category                CLASS_CATEGORY;
  l_error_party_type                    PARTY_TYPE;
  l_update_party_id                     OWNER_TABLE_ID;
  l_update_code_assignment_id           CODE_ASSIGNMENT_ID;
  l_update_class_category               CLASS_CATEGORY;
  l_update_class_code                   CLASS_CODE;
  l_update_party_type                   PARTY_TYPE;
  l_update_max_party_id                 NUMBER;
  l_update_min_party_id                 NUMBER;

  l_createdby_errors                    LOOKUP_ERROR;

  /* Keep track of rows that do not get inserted or updated successfully.
     Those are the rows that have some validation or DML errors.
     Use this when inserting into or updating other tables so that we
     do not need to check all the validation arrays. */

  l_num_row_processed NUMBER_COLUMN;

  l_no_end_date DATE;
  l_update_int_class_category           CLASS_CATEGORY;


/**********************************************
 *  private procedure validate_DSS_security
 *
 * DESCRIPTION
 *     Check if the DSS security is
 *     granted to the user.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-10-03   Kate Shan    o Created

************************************************/

PROCEDURE validate_DSS_security IS
  dss_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  dss_msg_count     NUMBER := 0;
  dss_msg_data      VARCHAR2(2000):= null;
BEGIN

  /* Check if the DSS security is granted to the user.
     Only check for update. */
  FOR i IN 1..l_code_assignment_id.count LOOP
    l_dss_security_errors(i) :=
    		hz_dss_util_pub.test_instance(
                p_operation_code     => 'UPDATE',
                p_db_object_name     => 'HZ_CODE_ASSIGNMENTS',
                p_instance_pk1_value => l_code_assignment_id(i),
                p_user_name          => fnd_global.user_name,
                x_return_status      => dss_return_status,
                x_msg_count          => dss_msg_count,
                x_msg_data           => dss_msg_data);

  END LOOP;

END validate_DSS_security;


/**********************************************
 * private procedure report_errors
 *
 * DESCRIPTION
 *     Report error.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     P_ACTION                     IN     VARCHAR2,
 *     P_DML_EXCEPTION              IN     VARCHAR2,
 *
 * NOTES Used by update procedure.
 *       Error is caught individually, it's reported individually
 *
 * MODIFICATION HISTORY
 *
 *   07-10-03   Kate Shan    o Created
 *
**********************************************/

PROCEDURE report_errors(
  P_DML_RECORD    IN      HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
  P_ACTION        IN      VARCHAR2,
  P_DML_EXCEPTION IN	  VARCHAR2
) IS
  l_error_id HZ_IMP_CLASSIFICS_INT.ERROR_ID%TYPE;
  m NUMBER := 1;
  n NUMBER := 1;
  num_exp NUMBER;
  exp_ind NUMBER := 1;

BEGIN

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'report_errors (+)');
  /**********************************/
  /* Validation and Error reporting */
  /**********************************/

  IF l_code_assignment_id.count = 0 THEN
    return;
  END IF;

  /**********************************/
  /* Validation and Error reporting */
  /**********************************/
  l_num_row_processed := null;
  l_num_row_processed := NUMBER_COLUMN();
  l_num_row_processed.extend(l_code_assignment_id.count);
  l_exception_exists := null;
  l_exception_exists := FLAG_ERROR();
  l_exception_exists.extend(l_code_assignment_id.count);
  num_exp := SQL%BULK_EXCEPTIONS.COUNT;

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, '  ' || P_ACTION || ' Action, ' || ' total ' || num_exp || ' exceptions');

  FOR k IN 1..l_code_assignment_id.count LOOP

    /* If DML fails due to validation errors or exceptions */
      IF SQL%BULK_ROWCOUNT(k) = 0 THEN
        --FND_FILE.PUT_LINE(FND_FILE.LOG,  '  DML fails at record ' || ' -> l_code_assignment_id = ' || l_code_assignment_id (k) ||' !');

	l_num_row_processed(k) := 0;

        /* Check for any exceptions during DML */
        IF P_DML_EXCEPTION = 'Y' THEN
          /* determine if exception at this index */
          FOR i IN exp_ind..num_exp LOOP
            IF SQL%BULK_EXCEPTIONS(i).ERROR_INDEX = k THEN
              l_exception_exists(k) := 'Y';
            ELSIF SQL%BULK_EXCEPTIONS(i).ERROR_INDEX > k THEN
              EXIT;
            END IF;
          END LOOP;
        END IF; /* P_DML_EXCEPTION = 'Y' */

      ELSE
         l_num_row_processed(k) := 1;
      END IF; /* SQL%BULK_ROWCOUNT(k) = 0 */
    END LOOP;

    /* insert into tmp error tables */
    forall j in 1..l_code_assignment_id.count
      insert into hz_imp_tmp_errors
      (
         request_id,
         batch_id,
         int_row_id,
         interface_table_name,
         error_id,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date,
	 ACTION_MISMATCH_FLAG,
         MISSING_PARENT_FLAG,
         e2_flag, e3_flag,
	 e4_flag,e5_flag,e6_flag,
	 e7_flag,
         e8_flag, e9_flag, e10_flag,
         OTHER_EXCEP_FLAG
      )

      (
        select P_DML_RECORD.REQUEST_ID,
               P_DML_RECORD.BATCH_ID,
               l_row_id(j),
               'HZ_IMP_CLASSIFICS_INT',
               HZ_IMP_ERRORS_S.NextVal,
               P_DML_RECORD.SYSDATE,
               P_DML_RECORD.USER_ID,
               P_DML_RECORD.SYSDATE,
               P_DML_RECORD.USER_ID,
               P_DML_RECORD.LAST_UPDATE_LOGIN,
               P_DML_RECORD.PROGRAM_APPLICATION_ID,
               P_DML_RECORD.PROGRAM_ID,
               P_DML_RECORD.SYSDATE,
               l_action_mismatch_errors(j),
               'Y',
	       'Y', 'Y',
               l_start_end_date_errors(j),
               l_identical_classcode_errors(j),
               l_multi_assign_errors(j),
	       'Y',
	       l_start_date_errors(j),
               decode(l_dss_security_errors(j), FND_API.G_TRUE,'Y',null),
               'Y',
               l_exception_exists(j)
          from dual
         where l_num_row_processed(j) = 0
      );

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'report_errors (-)');

END report_errors;



/********************************************************************************
 *
 * PROCEDURE populate_error_table
 *
 * DESCRIPTION
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *         P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
 *         P_DUP_VAL_EXP               IN     VARCHAR2
 *         P_SQL_ERRM                  IN     VARCHAR2
 *
 *   OUT
 * NOTES   record errors in temp error when exception happens during insert or update.
 *
 * MODIFICATION HISTORY
 *
 *   08-27-03   Kate Shan    o Created
 *
 ********************************************************************************/

PROCEDURE populate_error_table(
     P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DUP_VAL_EXP               IN     VARCHAR2,
     P_SQL_ERRM                  IN     VARCHAR2  ) IS

     dup_val_exp_val             VARCHAR2(1) := null;
     other_exp_val               VARCHAR2(1) := 'Y';
BEGIN

   -- FND_FILE.PUT_LINE(FND_FILE.LOG,'populate_error_table');

     -- in constraint voilation happen,  DUP_VAL_IDX_EXCEP_FLAG column
     -- in temp error table will be set
     -- 'A' indicate HZ_CODE_ASSIGNMENTS_U1 constraint violation
     -- 'B' indicate HZ_CODE_ASSIGNMENTS_U2 constraint violation

     if (P_DUP_VAL_EXP = 'Y') then
       other_exp_val := null;
       if(instr(P_SQL_ERRM, 'HZ_CODE_ASSIGNMENTS_U1')<>0) then
         dup_val_exp_val := 'A';
       elsif(instr(P_SQL_ERRM, 'HZ_CODE_ASSIGNMENTS_U2')<>0) then
         dup_val_exp_val := 'B';
       end if;
     end if;

   -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'dup_val_exp_val:' || dup_val_exp_val);

     insert into hz_imp_tmp_errors
     (
       request_id,
       batch_id,
       int_row_id,
       interface_table_name,
       error_id,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_application_id,
       program_id,
       program_update_date,
       e1_flag,
       e2_flag,
       e3_flag,
       e4_flag,
       e5_flag,
       e6_flag,
       e7_flag,
       e8_flag,
       e9_flag,
       e10_flag,
       DUP_VAL_IDX_EXCEP_FLAG,
       OTHER_EXCEP_FLAG,
       ACTION_MISMATCH_FLAG,MISSING_PARENT_FLAG
     )
     (
       select P_DML_RECORD.REQUEST_ID,
              P_DML_RECORD.BATCH_ID,
              clsf_sg.int_row_id,
              'HZ_IMP_CLASSIFICS_INT',
              HZ_IMP_ERRORS_S.NextVal,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.LAST_UPDATE_LOGIN,
              P_DML_RECORD.PROGRAM_APPLICATION_ID,
              P_DML_RECORD.PROGRAM_ID,
              P_DML_RECORD.SYSDATE,
	      'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y',
              dup_val_exp_val,
              other_exp_val,
              'Y','Y'
         from hz_imp_classifics_sg clsf_sg, hz_imp_classifics_int clsf_int
        where clsf_sg.action_flag = 'I'
          and clsf_int.rowid = clsf_sg.int_row_id
          and clsf_int.batch_id = P_DML_RECORD.BATCH_ID
          and clsf_int.party_orig_system = P_DML_RECORD.OS
          and clsf_int.party_orig_system_reference
              between P_DML_RECORD.FROM_OSR and P_DML_RECORD.TO_OSR
     );

END populate_error_table;

/********************************************************************************
 *
 *	process_insert_codeassigns
 *
 ********************************************************************************/

PROCEDURE process_insert_code_assignment (
  P_DML_RECORD  	       IN  	     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,X_RETURN_STATUS             OUT NOCOPY    VARCHAR2
  ,X_MSG_COUNT                 OUT NOCOPY    NUMBER
  ,X_MSG_DATA                  OUT NOCOPY    VARCHAR2
) IS

  c_handle_insert RefCurType;

  l_insert_sql varchar2(20000) :=
  '
  insert all
    when (--error_flag is null
         action_mismatch_error is not null
     and classcat_foreignkey_error is not null
     and class_code_lookup_error is not null
     and start_end_date_error is not null
     and identical_classcode_error is not null
     and multi_assign_error is not null
     and leaf_node_error is not null
     and createdby_error is not null
     and missing_parent_error is not null) then
    into hz_code_assignments (
         application_id,
         actual_content_source, -- Bug 4079902
         content_source_type,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date,
         request_id,
         code_assignment_id,
         owner_table_name,
         owner_table_id,
         class_category,
         class_code,
         primary_flag,
         rank,
         start_date_active,
         end_date_active,
         status,
         object_version_number,
         created_by_module)
  values (
         :application_id,
         :actual_content_src,
         ''USER_ENTERED'', -- Bug 4079902
         :user_id,
         :l_sysdate,
         :user_id,
         :l_sysdate,
         :last_update_login,
         :program_application_id,
         :program_id,
         :l_sysdate,
         :request_id,
         code_assignment_id,
         ''HZ_PARTIES'',
         party_id,
         class_category,
         class_code,
         nvl(primary_flag, ''N''),
         rank,
         start_date_active,
         end_date_active,
         ''A'',
         1, -- OBJECT_VERSION_NUMBER,
         created_by_module)
    else
    into hz_imp_tmp_errors (
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date,
         error_id,
         batch_id,
         request_id,
         int_row_id,
         interface_table_name,
         ACTION_MISMATCH_FLAG,
         MISSING_PARENT_FLAG,
         --e1_flag,
         e2_flag,
         e3_flag,
         e4_flag,
         e5_flag,
         e6_flag,
         e7_flag,
	 e8_flag,
	 e9_flag,
         e10_flag)
  values (
         :user_id,
         :l_sysdate,
         :user_id,
         :l_sysdate,
         :last_update_login,
         :program_application_id,
         :program_id,
         :l_sysdate,
         hz_imp_errors_s.nextval,
         :p_batch_id,
         :request_id,
         row_id,
         ''HZ_IMP_CLASSIFICS_INT'',
         action_mismatch_error,
         missing_parent_error,
 	 --error_flag,
         classcat_foreignkey_error,
         class_code_lookup_error,
         start_end_date_error,
         identical_classcode_error,
         multi_assign_error,
         leaf_node_error,
	 ''Y'', ''Y'',
         createdby_error)
    with tc as (select 0 a from dual union all select 1 a from dual)
  select /*+ ordered push_subq  index(cas) use_nl(cai) use_nl(class_code_lookups) */ cai.rowid row_id,
         cas.code_assignment_id,
         hp.party_id party_id,
         cai.class_category,
         class_code_lookups.lookup_code class_code,
         decode(cai.start_date_active, :p_gmiss_date, sysdate, null, sysdate, cai.start_date_active) start_date_active,
         nullif(cai.end_date_active, :p_gmiss_date) end_date_active,
         nullif(cai.rank, :p_gmiss_num) rank,
	 cas.primary_flag primary_flag,
         nvl(nullif(cai.created_by_module, :p_gmiss_char), ''HZ_IMPORT'') created_by_module,
         cas.error_flag,
         nvl2(nullif(nullif(cai.insert_update_flag, :p_gmiss_char), cas.action_flag), null, ''Y'') action_mismatch_error,
         nvl2(hp.party_id,''Y'',null) missing_parent_error,
         decode(cai.class_category, :p_gmiss_char, null, nvl2(class_cat.class_category, ''Y'', null)) classcat_foreignkey_error,
         nvl2(nullif(cai.class_code, :p_gmiss_char), nvl2(class_code_lookups.lookup_code, ''Y'', null), null) class_code_lookup_error,
         decode(cai.start_date_active, :p_gmiss_date, ''Y'',
	        nvl2(cai.end_date_active, decode(sign(cai.end_date_active - nvl(cai.start_date_active, sysdate)), -1, null, ''Y''), ''Y'')) start_end_date_error,
	 decode(tc1.a, 0, ''Y'') identical_classcode_error,
	 decode(tc2.a, 0, ''Y'') multi_assign_error,
	 decode(tc3.a, 0, ''Y'') leaf_node_error,
         decode(cai.created_by_module, :p_gmiss_char, ''Y'', null, ''Y'', nvl2(createdby_l.lookup_code,''Y'',null)) createdby_error
    from hz_imp_classifics_sg cas,
         hz_imp_classifics_int cai,
         fnd_lookup_values class_code_lookups,
         hz_class_categories class_cat,
	 tc tc1, tc tc2, tc tc3,
         hz_parties hp,
         fnd_lookup_values createdby_l

   where hp.party_id (+) = cas.party_id
     AND hp.status (+) = ''A''
     AND cas.batch_id = :p_batch_id
     and cas.batch_mode_flag = :p_batch_mode_flag
     and cas.party_orig_system = :p_wu_os
     and cas.party_orig_system_reference between :p_from_osr and :p_to_osr
     and cai.rowid = cas.int_row_id
     and cas.action_flag = ''I''
     and cai.class_category = class_cat.class_category (+)
--     and decode(cai.class_category, ''NACE'', replace(cai.class_code, ''.'', ''''), cai.class_code) = decode(cai.class_category, ''NACE'',  replace(class_code_lookups.lookup_code (+), ''.'', ''''), class_code_lookups.lookup_code (+))
     and cai.class_code = class_code_lookups.lookup_code (+)
     and cai.class_category = class_code_lookups.lookup_type (+)
     and class_code_lookups.language (+) = userenv(''LANG'')
     and createdby_l.lookup_code (+) = cai.created_by_module
     and createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
     and createdby_l.language (+) = userenv(''LANG'')
     and createdby_l.view_application_id (+) = 222
     and createdby_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
     and tc1.a = (select count(*) -- check date overlap, 0 indicates no error
           from hz_code_assignments c
          where c.class_category = cai.class_category
            and c.class_code = cai.class_code
            and c.owner_table_name = ''HZ_PARTIES''
            and c.owner_table_id = cas.party_id
            and nvl(cai.end_date_active, :l_no_end_date) >=
                c.start_date_active
            and nvl(c.end_date_active, :l_no_end_date) >=
                decode(cai.start_date_active, null, sysdate, :p_gmiss_date, sysdate, cai.start_date_active)
            --and c.content_source_type = :l_content_source_type (bug 4079902)
            and c.actual_content_source = :l_content_source_type
            and c.status = ''A''
            and rownum = 1)
     and tc2.a = (select count(*) -- check multi class code, 0 indicates no error
           from hz_code_assignments c_assign,
                hz_class_categories c_cat
          where c_cat.class_category = c_assign.class_category
            and c_cat.class_category = cai.class_category
            and c_assign.owner_table_id = cas.party_id
            and c_assign.owner_table_name = ''HZ_PARTIES''
            and c_cat.allow_multi_assign_flag = ''N''
            and nvl(cai.end_date_active, :l_no_end_date) >=
                c_assign.start_date_active
            and nvl(c_assign.end_date_active, :l_no_end_date) >=
                decode(cai.start_date_active, null, sysdate, :p_gmiss_date, sysdate, cai.start_date_active)
            --and c_assign.content_source_type = :l_content_source_type (bug 4079902)
            and c_assign.actual_content_source = :l_content_source_type
            and status = ''A''
            and rownum = 1)
     and tc3.a = (select count(*) -- check leaf node, 0 indicates no error
           from hz_class_categories c_cate,
                hz_class_code_relations c_rel
          where c_cate.class_category = cai.class_category
            and c_cate.allow_leaf_node_only_flag = ''Y''
	    and c_rel.class_category = cai.class_category
	    and c_rel.class_code = cai.class_code
	    and c_rel.sub_class_code is not null
	    and sysdate between c_rel.start_date_active
	    and nvl(c_rel.end_date_active, :l_no_end_date)
            and rownum = 1)
  ';


  l_where_first_run_sql varchar2(35) := ' AND cai.interface_status is null';
  l_where_rerun_sql varchar2(35) := ' AND cai.interface_status = ''C''';

  l_where_enabled_lookup_sql varchar2(1000) :=
  ' AND  ( class_code_lookups.ENABLED_FLAG(+) = ''Y'' AND
  TRUNC(:l_sysdate) BETWEEN
  TRUNC(NVL( class_code_lookups.START_DATE_ACTIVE,:l_sysdate ) ) AND
  TRUNC(NVL( class_code_lookups.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  ( createdby_l.ENABLED_FLAG(+) = ''Y'' AND
          TRUNC(:l_sysdate) BETWEEN
          TRUNC(NVL( createdby_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
          TRUNC(NVL( createdby_l.END_DATE_ACTIVE,:l_sysdate ) ) )';

  l_entity_attr_id number := null;
  l_dml_exception varchar2(1) := 'N';

  primary_flag_err_cursor RefCurType;
  de_norm_cursor          RefCurType;
  pid_cursor              RefCurType;

BEGIN

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'process_insert_code_assignments (+)');

  savepoint process_insert_codeassigns_pvt;

  FND_MSG_PUB.initialize;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

--    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_BATCH_ID'||P_BATCH_ID);
--    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_wu_os'||p_wu_os);
--    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_from_osr'||p_from_osr);
--    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_to_osr'||p_to_osr);

  IF P_DML_RECORD.ALLOW_DISABLED_LOOKUP = 'Y' THEN
    -- FND_FILE.PUT_LINE(FND_FILE.LOG,'l_allow_disabled_lookup = Y');

    IF P_DML_RECORD.RERUN = 'N' THEN
      --  First Run
      -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'First run');
      EXECUTE IMMEDIATE l_insert_sql || l_where_first_run_sql
      USING
      p_dml_record.application_id,
      p_dml_record.actual_content_src,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.last_update_login,
      p_dml_record.program_application_id,
      p_dml_record.program_id,
      p_dml_record.sysdate,
      p_dml_record.request_id,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.last_update_login,
      p_dml_record.program_application_id,
      p_dml_record.program_id,
      p_dml_record.sysdate,
      p_dml_record.batch_id,
      p_dml_record.request_id,
      p_dml_record.gmiss_date,
      p_dml_record.gmiss_date,
      p_dml_record.gmiss_num,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_date,
      p_dml_record.gmiss_char,
      p_dml_record.batch_id,
      p_dml_record.batch_mode_flag,
      p_dml_record.os,
      p_dml_record.from_osr,
      p_dml_record.to_osr,
      l_no_end_date,
      l_no_end_date,
      p_dml_record.gmiss_date,
      p_dml_record.actual_content_src,
      l_no_end_date,
      l_no_end_date,
      p_dml_record.gmiss_date,
      p_dml_record.actual_content_src,
      l_no_end_date
      ;

    ELSE
      -- Rerun
      -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'Re-run');
      EXECUTE IMMEDIATE l_insert_sql || l_where_rerun_sql
      USING
      p_dml_record.application_id,
      p_dml_record.actual_content_src,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.last_update_login,
      p_dml_record.program_application_id,
      p_dml_record.program_id,
      p_dml_record.sysdate,
      p_dml_record.request_id,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.last_update_login,
      p_dml_record.program_application_id,
      p_dml_record.program_id,
      p_dml_record.sysdate,
      p_dml_record.batch_id,
      p_dml_record.request_id,
      p_dml_record.gmiss_date,
      p_dml_record.gmiss_date,
      p_dml_record.gmiss_num,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_date,
      p_dml_record.gmiss_char,
      p_dml_record.batch_id,
      p_dml_record.batch_mode_flag,
      p_dml_record.os,
      p_dml_record.from_osr,
      p_dml_record.to_osr,
      l_no_end_date,
      l_no_end_date,
      p_dml_record.gmiss_date,
      p_dml_record.actual_content_src,
      l_no_end_date,
      l_no_end_date,
      p_dml_record.gmiss_date,
      p_dml_record.actual_content_src,
      l_no_end_date;


    END IF;

  ELSE -- l_allow_disabled_lookup
      -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_allow_disabled_lookup = N');

    IF P_DML_RECORD.RERUN = 'N' THEN

      --  First Run
      -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'First run');
      EXECUTE IMMEDIATE l_insert_sql|| l_where_first_run_sql || l_where_enabled_lookup_sql
      USING
      p_dml_record.application_id,
      p_dml_record.actual_content_src,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.last_update_login,
      p_dml_record.program_application_id,
      p_dml_record.program_id,
      p_dml_record.sysdate,
      p_dml_record.request_id,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.last_update_login,
      p_dml_record.program_application_id,
      p_dml_record.program_id,
      p_dml_record.sysdate,
      p_dml_record.batch_id,
      p_dml_record.request_id,
      p_dml_record.gmiss_date,
      p_dml_record.gmiss_date,
      p_dml_record.gmiss_num,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_date,
      p_dml_record.gmiss_char,
      p_dml_record.batch_id,
      p_dml_record.batch_mode_flag,
      p_dml_record.os,
      p_dml_record.from_osr,
      p_dml_record.to_osr,
      l_no_end_date,
      l_no_end_date,
      p_dml_record.gmiss_date,
      p_dml_record.actual_content_src,
      l_no_end_date,
      l_no_end_date,
      p_dml_record.gmiss_date,
      p_dml_record.actual_content_src,
      l_no_end_date,
      p_dml_record.sysdate,
      p_dml_record.sysdate,
      p_dml_record.sysdate,
      p_dml_record.sysdate,
      p_dml_record.sysdate,
      p_dml_record.sysdate;

    ELSE
      -- Rerun
      -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'Re-run');
      EXECUTE IMMEDIATE l_insert_sql || l_where_rerun_sql || l_where_enabled_lookup_sql
      USING
      p_dml_record.application_id,
      p_dml_record.actual_content_src,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.last_update_login,
      p_dml_record.program_application_id,
      p_dml_record.program_id,
      p_dml_record.sysdate,
      p_dml_record.request_id,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.user_id,
      p_dml_record.sysdate,
      p_dml_record.last_update_login,
      p_dml_record.program_application_id,
      p_dml_record.program_id,
      p_dml_record.sysdate,
      p_dml_record.batch_id,
      p_dml_record.request_id,
      p_dml_record.gmiss_date,
      p_dml_record.gmiss_date,
      p_dml_record.gmiss_num,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_char,
      p_dml_record.gmiss_date,
      p_dml_record.gmiss_char,
      p_dml_record.batch_id,
      p_dml_record.batch_mode_flag,
      p_dml_record.os,
      p_dml_record.from_osr,
      p_dml_record.to_osr,
      l_no_end_date,
      l_no_end_date,
      p_dml_record.gmiss_date,
      p_dml_record.actual_content_src,
      l_no_end_date,
      l_no_end_date,
      p_dml_record.gmiss_date,
      p_dml_record.actual_content_src,
      l_no_end_date,
      p_dml_record.sysdate,
      p_dml_record.sysdate,
      p_dml_record.sysdate,
      p_dml_record.sysdate,
      p_dml_record.sysdate,
      p_dml_record.sysdate;

    END IF;

  END IF;


  /* Failed primary code assignment */
  /* for all failed primary code assignment, nullify the corresponding denormalization column */

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'de-norm failed primary record with primary_flag = Y');

  OPEN primary_flag_err_cursor FOR
'select party_id, class_category
  from (
select cls_sg.party_id, cls_sg.class_category,
       rank() over (partition by
       cls_sg.party_id, cls_sg.class_category order by
       cls_sg.code_assignment_id) r
  from HZ_IMP_TMP_ERRORS err_table,
       hz_imp_classifics_sg cls_sg,
       hz_parties hp
 where err_table.request_id  = :request_id
   and err_table.interface_table_name = ''HZ_IMP_CLASSIFICS_INT''
   and cls_sg.batch_id = :batch_id
   and cls_sg.batch_mode_flag = :batch_mode_flag
   and cls_sg.party_orig_system = :orig_system
   and cls_sg.party_orig_system_reference between :from_osr and :to_osr
   and cls_sg.primary_flag = ''Y''
   and cls_sg.action_flag = ''I''
   and cls_sg.class_category in ( ''CUSTOMER_CATEGORY'', ''SIC'', ''NACE'')
   and cls_sg.int_row_id = err_table.int_row_id
   and hp.party_id=cls_sg.party_id
   )
 where r=1'
        using P_DML_RECORD.REQUEST_ID,P_DML_RECORD.BATCH_ID,
              P_DML_RECORD.BATCH_MODE_FLAG, P_DML_RECORD.OS,
              P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR;

  fetch primary_flag_err_cursor  BULK COLLECT INTO
    l_error_party_id, l_error_class_category;

  close primary_flag_err_cursor;

  -- nullify denorm column in hz_parties
  /* Bug 409189: when checking class_category in hz_imp_classifics_sg,
     check for 'SIC' instead of the individual SIC code type as this is how
     matching populates the column */
  forall i in 1..l_error_party_id.count
  update hz_parties hz_pty
  set category_code = decode(l_error_class_category(i), 'CUSTOMER_CATEGORY',  null, category_code),
      sic_code_type = decode(l_error_class_category(i), 'SIC', null, sic_code_type),
      sic_code = decode(l_error_class_category(i), 'SIC', null, sic_code)
  where hz_pty.party_id = l_error_party_id(i);

  -- nullify denorm column in hz_organization_profiles
  /* Bug 409189: when checking hz_organization_profiles.actual_content_source,
     there are three cases to consider:
     1. ACS is third party. Update org profile where ACS = '<third party>'
     2. ACS is USER_ENTERED and party has third party profile.
        Update org profile where ACS = 'USER_ENTERED'
     3. ACS is USER_ENTERED and party only has USER_ENTERED profile.
        Update org profile where ACS = 'SST'
  */

  /* Take care of cases 1 and 2 */
  forall i in 1..l_error_party_id.count
  update hz_organization_profiles org
  set
      local_activity_code = decode(l_error_class_category(i), 'NACE',  null, local_activity_code),
      sic_code_type = decode(l_error_class_category(i), 'SIC',null, sic_code_type),
      sic_code = decode(l_error_class_category(i), 'SIC', null, sic_code)
  where org.party_id = l_error_party_id(i)
        and effective_end_date is null
        and actual_content_source = P_DML_RECORD.actual_content_src;

  /* Take care of case 3.
     Even though this will update SST record for case 2 as well, since
     we will rerun mix-n-match to derive SST, it'll be ok to update here */
  forall i in 1..l_error_party_id.count
  update hz_organization_profiles org
  set
      local_activity_code = decode(l_error_class_category(i), 'NACE',  null, local_activity_code),
      sic_code_type = decode(l_error_class_category(i), 'SIC',null, sic_code_type),
      sic_code = decode(l_error_class_category(i), 'SIC', null, sic_code)
  where org.party_id = l_error_party_id(i)
        and effective_end_date is null
        and actual_content_source = decode(P_DML_RECORD.actual_content_src, 'USER_ENTERED', 'SST',
                                      '-INVALID_ACS-');



  /* de-norm the primary address to parties */
  /* Note: for error case, the party with the id will just be not found */
  /*       in update. Not necessary to filter out here. */

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'de-norm record with primary_flag = Y');

  OPEN de_norm_cursor FOR
    '     select cls_sg.party_id,
            cls_sg.code_assignment_id,
            cls_sg.class_category,
            cls_sg.class_code,
            cls_int.class_category
     from   hz_imp_classifics_sg cls_sg,
            hz_imp_parties_sg p_sg,
            hz_imp_classifics_int cls_int,
            hz_code_assignments hca
      where cls_sg.batch_id = :batch_id
        and cls_sg.batch_mode_flag = :batch_mode_flag
        and cls_sg.party_orig_system = :orig_system
        and cls_sg.party_orig_system_reference
            between :from_osr and :to_osr
        and cls_sg.primary_flag = ''Y''
        and cls_sg.action_flag = ''I''
        and p_sg.action_flag(+) = ''U''
        and p_sg.batch_id(+) = cls_sg.batch_id
        and p_sg.batch_mode_flag(+) = :batch_mode_flag
        and p_sg.party_orig_system(+) = :orig_system
        and p_sg.party_orig_system_reference(+) = cls_sg.party_orig_system_reference
        and cls_sg.class_category in ( ''CUSTOMER_CATEGORY'', ''SIC'', ''NACE'')
        and cls_int.rowid = cls_sg.int_row_id
        and hca.code_assignment_id=cls_sg.code_assignment_id
        '
        using P_DML_RECORD.BATCH_ID,
              P_DML_RECORD.BATCH_MODE_FLAG, P_DML_RECORD.OS,
              P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR,
	      P_DML_RECORD.BATCH_MODE_FLAG, P_DML_RECORD.OS;

  fetch de_norm_cursor  BULK COLLECT INTO
      l_update_party_id, l_update_code_assignment_id, l_update_class_category,
      l_update_class_code, l_update_int_class_category;

  close de_norm_cursor;

  /* Get the max and min party_id for all records that need to redo classification
     denormalization. These are used for calling HZ_MIXNM_CONC_DYNAMIC_PKG to
     derive SST. */
  OPEN pid_cursor FOR
  'select max(party_id), min(party_id)
   from hz_imp_classifics_sg
   where batch_id = :batch_id
   and batch_mode_flag = :batch_mode_flag
   and party_orig_system = :orig_system
   and party_orig_system_reference between :from_osr and :to_osr
   and primary_flag = ''Y''
   and action_flag = ''I''
   and class_category in (''CUSTOMER_CATEGORY'',''SIC'',''NACE'')'
   using P_DML_RECORD.BATCH_ID, P_DML_RECORD.BATCH_MODE_FLAG, P_DML_RECORD.OS,
         P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR;

  fetch pid_cursor INTO
    l_update_max_party_id, l_update_min_party_id;


  -- de-norm to hz_parties
  forall i in 1..l_update_party_id.count
  update hz_parties hz_pty
  set category_code = decode(l_update_class_category(i), 'CUSTOMER_CATEGORY',  l_update_class_code(i), category_code),
      sic_code_type = decode(l_update_class_category(i), 'SIC', l_update_int_class_category(i), sic_code_type),
      sic_code = decode(l_update_class_category(i), 'SIC', l_update_class_code(i), sic_code)
  where hz_pty.party_id = l_update_party_id(i);

  -- de-norm to hz_organization_profiles
  /* Bug 409189: when checking hz_organization_profiles.actual_content_source,
     there are three cases to consider:
     1. ACS is third party. Update org profile where ACS = '<third party>'
     2. ACS is USER_ENTERED and party has third party profile.
        Update org profile where ACS = 'USER_ENTERED'
     3. ACS is USER_ENTERED and party only has USER_ENTERED profile.
        Update org profile where ACS = 'SST'
  */

  /* Take care of cases 1 and 2 */
  forall i in 1..l_update_party_id.count
  update hz_organization_profiles org
  set local_activity_code = decode(l_update_class_category(i), 'NACE',  l_update_class_code(i), local_activity_code),
      sic_code_type = decode(l_update_class_category(i), 'SIC', l_update_int_class_category(i), sic_code_type),
      sic_code = decode(l_update_class_category(i), 'SIC', l_update_class_code(i), sic_code)
  where org.party_id = l_update_party_id(i)
        and effective_end_date is null
        and actual_content_source = P_DML_RECORD.actual_content_src;

  /* Take care of cases 3 */
  forall i in 1..l_update_party_id.count
  update hz_organization_profiles org
  set local_activity_code = decode(l_update_class_category(i), 'NACE',  l_update_class_code(i), local_activity_code),
      sic_code_type = decode(l_update_class_category(i), 'SIC', l_update_int_class_category(i), sic_code_type),
      sic_code = decode(l_update_class_category(i), 'SIC', l_update_class_code(i), sic_code)
  where org.party_id = l_update_party_id(i)
        and effective_end_date is null
        and actual_content_source = decode(P_DML_RECORD.actual_content_src, 'USER_ENTERED', 'SST',
                                      P_DML_RECORD.actual_content_src);

  /* Run mix-n-match after updating org profiles if
     mix-n-match is enabled */
  IF l_update_party_id.count > 0 AND
     HZ_MIXNM_UTILITY.isMixNMatchEnabled('HZ_ORGANIZATION_PROFILES',l_entity_attr_id) = 'Y' THEN
	HZ_MIXNM_CONC_DYNAMIC_PKG.ImportUpdateOrgSST(P_DML_RECORD.actual_content_src,P_DML_RECORD.FROM_OSR,P_DML_RECORD.TO_OSR,P_DML_RECORD.BATCH_ID,P_DML_RECORD.request_id,P_DML_RECORD.program_id,P_DML_RECORD.program_application_id);
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'process_insert_code_assignment (-)');

EXCEPTION

  WHEN DUP_VAL_ON_INDEX THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert code assignment dup val exception: ' || SQLERRM);
    ROLLBACK to process_insert_codeassigns_pvt;

    populate_error_table(P_DML_RECORD, 'Y', SQLERRM);
    x_return_status := FND_API.G_RET_STS_ERROR;

    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;

  WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert code assignment other exception: ' || SQLERRM);
    ROLLBACK to process_insert_codeassigns_pvt;

    populate_error_table(P_DML_RECORD, 'N', SQLERRM);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;


END process_insert_code_assignment;



/********************************************************************************
 *
 *	process_update_code_assignment
 *
 ********************************************************************************/

PROCEDURE process_update_code_assignment (
  P_DML_RECORD  	       IN  	     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,X_RETURN_STATUS             OUT NOCOPY    VARCHAR2
  ,X_MSG_COUNT                 OUT NOCOPY    NUMBER
  ,X_MSG_DATA                  OUT NOCOPY    VARCHAR2
) IS

  c_handle_update RefCurType;

  l_update_sql varchar2(20000) :=
       'SELECT
        cai.rowid,
        nvl(cai.party_orig_system, cas.party_orig_system) party_orig_system,
        nvl(cai.party_orig_system_reference, cas.party_orig_system_reference) party_orig_system_reference,

        -- code assignment columns
        cas.code_assignment_id,
        nvl(cai.start_date_active, sysdate) start_date_active,
        decode(cai.end_date_active, :G_MISS_DATE, null) end_date_active,
        decode(cai.rank, :G_MISS_NUM, null, cai.rank) rank,

	-- errors
        cas.error_flag,
        ''T'' dss_security_errors,
        decode(nvl(cai.insert_update_flag, cas.action_flag), cas.action_flag, ''Y'', null) action_mismatch_error,
        ''Y'' missing_parent_error,
        decode(cai.end_date_active, null, ''Y'',
               decode(sign(cai.end_date_active - nvl(cai.start_date_active, sysdate)), -1, null, ''Y'')) start_end_date_error,
        decode(cai.START_DATE_ACTIVE, :G_MISS_DATE, null, ''Y'') start_date_error,

        decode(tc1.a, 0, ''Y'') identical_classcode_error,
        decode(tc2.a, 0, ''Y'') multi_assign_error
        FROM HZ_IMP_CLASSIFICS_INT  cai,
         HZ_IMP_CLASSIFICS_SG   cas,
         (select 0 a from dual union all select 1 a from dual) tc1,
         (select 0 a from dual union all select 1 a from dual) tc2
        WHERE
        cas.batch_id = :P_BATCH_ID
        AND cas.batch_mode_flag = :P_BATCH_MODE_FLAG
        AND cas.party_orig_system = :P_WU_OS
        AND cas.party_orig_system_reference between :P_FROM_OSR and :P_TO_OSR
        AND cai.rowid = cas.int_row_id

        and tc1.a = (select count(*) -- check date overlap, 0 indicates no error
          from hz_code_assignments c
          where c.code_assignment_id <> cas.code_assignment_id
            and c.class_category = cas.class_category
            and c.class_code = cas.class_code
            and c.owner_table_name = ''HZ_PARTIES''
            and c.owner_table_id = cas.party_id
            and nvl(cai.end_date_active, :l_no_end_date) >=
                c.start_date_active
            and nvl(c.end_date_active, :l_no_end_date) >=
                cai.start_date_active
            and c.actual_content_source = :l_content_source_type --(bug 4079902)
            --and c.content_source_type = :l_content_source_type
            and c.status = ''A''
            and rownum = 1)
        and tc2.a = (select count(*) -- check multi class code, 0 indicates no error
           from hz_code_assignments c_assign,
                hz_class_categories c_cat
          where c_cat.class_category = c_assign.class_category
            and c_cat.class_category = cas.class_category
            and c_assign.owner_table_id = cas.party_id
            and c_assign.owner_table_name = ''HZ_PARTIES''
            and c_cat.allow_multi_assign_flag = ''N''
            and nvl(cai.end_date_active, :l_no_end_date) >=
                c_assign.start_date_active
            and nvl(c_assign.end_date_active, :l_no_end_date) >=
                cai.start_date_active
            --and c_assign.content_source_type = :l_content_source_type (bug 4079902)
            and c_assign.actual_content_source = :l_content_source_type
            and status = ''A''
            and rownum = 1)
        AND cas.ACTION_FLAG = ''U''
        ';


  l_where_first_run_sql varchar2(35) := ' AND cai.interface_status is null';
  l_where_rerun_sql varchar2(35) := ' AND cai.interface_status = ''C''';

  l_dml_exception varchar2(1) := 'N';

BEGIN

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'process_update_code_assignment (+)');

  savepoint process_update_codeassigns_pvt;

  FND_MSG_PUB.initialize;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF P_DML_RECORD.RERUN = 'N' THEN
    --  First Run
    -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'First run');
    OPEN c_handle_update FOR l_update_sql || l_where_first_run_sql
    USING P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_NUM, P_DML_RECORD.GMISS_DATE,
          P_DML_RECORD.batch_id, P_DML_RECORD.batch_mode_flag,
	  P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR,
          l_no_end_date, l_no_end_date, P_DML_RECORD.ACTUAL_CONTENT_SRC,
          l_no_end_date, l_no_end_date, P_DML_RECORD.ACTUAL_CONTENT_SRC;

  ELSE
    -- Rerun
    -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'Re-run');
    OPEN c_handle_update FOR l_update_sql || l_where_rerun_sql
    USING P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_NUM, P_DML_RECORD.GMISS_DATE,
          P_DML_RECORD.batch_id, P_DML_RECORD.batch_mode_flag,
	  P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR,
          l_no_end_date, l_no_end_date, P_DML_RECORD.ACTUAL_CONTENT_SRC,
          l_no_end_date, l_no_end_date, P_DML_RECORD.ACTUAL_CONTENT_SRC;

  END IF;

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'Fetch update cursor');
  FETCH c_handle_update BULK COLLECT INTO
        l_row_id,
        l_party_orig_system,
        l_party_orig_system_reference,

	-- code assignment columns
        l_code_assignment_id,
        l_start_date_active,
        l_end_date_active,
        l_rank,

	-- errors
        l_error_flag,
        l_dss_security_errors,
        l_action_mismatch_errors,
        l_missing_parent_error,
        l_start_end_date_errors,
        l_start_date_errors,
        l_identical_classcode_errors,
        l_multi_assign_errors;

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'count = ' || l_code_assignment_id.count);

  /*** Do DSS security validation based on profile ***/
  IF NVL(FND_PROFILE.value('HZ_IMP_DSS_SECURITY'), 'N') = 'Y' THEN
    validate_DSS_security;
  END IF;

  -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'Update code assignment');

  BEGIN

    ForAll j in 1..l_code_assignment_id.count SAVE EXCEPTIONS
      update hz_code_assignments set
/*    comment out for bug fix 3546566
        START_DATE_ACTIVE =
                    nvl(l_start_date_active(j), start_date_active),
        END_DATE_ACTIVE =
                   DECODE(l_end_date_active(j),
                   	  NULL, end_date_active,
                   	  P_DML_RECORD.GMISS_DATE, NULL,
                   	  l_end_date_active(j)),
*/
        RANK = l_rank(j),
        LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
        LAST_UPDATE_DATE = trunc(P_DML_RECORD.SYSDATE),
        LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER =
                   DECODE(OBJECT_VERSION_NUMBER,
                   	  NULL, 1,
                   	  OBJECT_VERSION_NUMBER+1),
	REQUEST_ID = P_DML_RECORD.REQUEST_ID,
        PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE
      where
        code_assignment_id = l_code_assignment_id(j)
        and l_dss_security_errors(j) = 'T'
        and l_action_mismatch_errors(j) is not null
        and l_start_end_date_errors(j) is not null
        and l_start_date_errors(j) is not null
        and l_identical_classcode_errors(j) is not null
        and l_multi_assign_errors(j) is not null;

    EXCEPTION
      WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Other exceptions');
        l_dml_exception := 'Y';

      FOR k IN 1..l_code_assignment_id.count LOOP
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'dml_errors BULK_ROWCOUNT = ' || SQL%BULK_ROWCOUNT(k));
       END LOOP;

    END;

    report_errors(P_DML_RECORD, 'U', l_dml_exception);

    CLOSE c_handle_update;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'process_update_code_assignment (-)');

  EXCEPTION

    WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Update code assignment other exception: ' || SQLERRM);

        ROLLBACK to process_update_codeassigns_pvt;

        populate_error_table(P_DML_RECORD, 'N', SQLERRM);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

END process_update_code_assignment;


/********************************************************************************
 *
 *	load_code_assignments
 *
 ********************************************************************************/

PROCEDURE load_code_assignments (
   P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,X_RETURN_STATUS             OUT NOCOPY    VARCHAR2
  ,X_MSG_COUNT                 OUT NOCOPY    NUMBER
  ,X_MSG_DATA                  OUT NOCOPY    VARCHAR2
) IS

   l_return_status    VARCHAR2(30);
   l_msg_data         VARCHAR2(2000);
   l_msg_count        NUMBER;

BEGIN

   savepoint load_code_assignments_pvt;
   FND_MSG_PUB.initialize;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'load_code_assignments (+)');

   --Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_no_end_date := TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS');


   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.os = ' || p_dml_record.os) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.from_osr = ' || p_dml_record.from_osr ) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.to_osr = ' || p_dml_record.to_osr) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.actual_content_src = ' || p_dml_record.actual_content_src) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.rerun = ' || p_dml_record.rerun) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.error_limit = ' || p_dml_record.error_limit) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.batch_mode_flag = ' || p_dml_record.batch_mode_flag) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.user_id = ' || p_dml_record.user_id ) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.last_update_login = ' || p_dml_record.last_update_login) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.program_id = ' || p_dml_record.program_id) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.program_application_id = ' || p_dml_record.program_application_id) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.request_id = ' || p_dml_record.request_id) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.application_id = ' || p_dml_record.application_id) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.gmiss_char = ' || p_dml_record.gmiss_char) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.gmiss_num = ' || to_char(p_dml_record.gmiss_num)) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.gmiss_date = ' || to_char(p_dml_record.gmiss_date, 'MM-DD-YYYY')) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.flex_validation = ' || p_dml_record.flex_validation) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.allow_disabled_lookup = ' || p_dml_record.allow_disabled_lookup) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dml_record.profile_version = ' || p_dml_record.profile_version) ;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_no_end_date = ' || l_no_end_date) ;


   process_insert_code_assignment(
      P_DML_RECORD       => P_DML_RECORD
     ,x_return_status    => x_return_status
     ,x_msg_count        => x_msg_count
     ,x_msg_data         => x_msg_data
   );

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     return;
   END IF;

   process_update_code_assignment(
      P_DML_RECORD       => P_DML_RECORD
     ,x_return_status    => x_return_status
     ,x_msg_count        => x_msg_count
     ,x_msg_data         => x_msg_data
   );

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'load_code_assignments (-)');

END load_code_assignments;
END HZ_IMP_LOAD_CODE_ASSIGNMENTS;

/
