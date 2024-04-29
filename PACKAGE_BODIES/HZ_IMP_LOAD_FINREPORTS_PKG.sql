--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_FINREPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_FINREPORTS_PKG" AS
/*$Header: ARHLFNRB.pls 120.5 2006/01/17 08:46:06 vravicha noship $*/



g_debug_count             NUMBER := 0;
  --g_debug                   BOOLEAN := FALSE;

  l_parent_party_id         PARENT_PARTY_ID;
  l_fr_id                   FR_ID;
  l_party_id                PARTY_ID;
  l_audit_ind               AUDIT_IND;
  l_consolidated_ind        CONSOLIDATED_IND;
  l_date_rpt_issued         DATE_REPORT_ISSUED;
  l_doc_ref                 DOCUMENT_REFERENCE;
  l_estimated_ind           ESTIMATED_IND;
  l_final_ind               FINAL_IND;
  l_fiscal_ind              FISCAL_IND;
  l_forecast_ind            FORECAST_IND;
  l_issued_period           ISSUED_PERIOD;
  l_opening_ind             OPENING_IND;
  l_proforma_ind            PROFORMA_IND;
  l_qualified_ind           QUALIFIED_IND;
  l_rpt_start_date          REPORT_START_DATE;
  l_rpt_end_date            REPORT_END_DATE;
  l_req_auth                REQUIRING_AUTHORITY;
  l_restated_ind            RESTATED_IND;
  l_signed_by_prin          SIGNED_BY_PRINCIPALS_IND;
  l_trial_balance_ind       TRIAL_BALANCE_IND;
  l_type_of_finreport       TYPE_OF_FINANCIAL_REPORT;
  l_unbal_ind               UNBALANCED_IND;
  l_created_by_module       CREATED_BY_MODULE;


  l_audit_ind_err           FLAG_ERROR;
  l_consolidated_ind_err    FLAG_ERROR;
  l_estimated_ind_err       FLAG_ERROR;
  l_final_ind_err           FLAG_ERROR;
  l_fiscal_ind_err          FLAG_ERROR;
  l_forecast_ind_err        FLAG_ERROR;
  l_opening_ind_err         FLAG_ERROR;
  l_proforma_ind_err        FLAG_ERROR;
  l_qualified_ind_err       FLAG_ERROR;
  l_restated_ind_err        FLAG_ERROR;
  l_signed_by_prin_err      FLAG_ERROR;
  l_trial_balance_ind_err   FLAG_ERROR;
  l_unbal_ind_err           FLAG_ERROR;
  l_date_err                FLAG_ERROR;
  l_action_error_flag       FLAG_ERROR;
  l_error_flag              FLAG_ERROR;
  l_date_comb_flag          FLAG_ERROR;
  l_rpt_date_flag           FLAG_ERROR;
  l_action_flag             ACTION_FLAG;

  /* Keep track of rows that do not get inserted or updated successfully.
     Those are the rows that have some validation or DML errors.
     Use this when inserting into or updating other tables so that we
     do not need to check all the validation arrays. */
  l_exception_exists            FLAG_ERROR;
  l_num_row_processed           NUMBER_COLUMN;
  l_row_id                      ROWID;
  l_errm                        varchar2(100);

  --------------------------------------
  -- forward declaration of private procedures and functions
  --------------------------------------

   /*PROCEDURE enable_debug;
   PROCEDURE disable_debug;
   */

   PROCEDURE process_insert_reports (
     P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     x_return_status             OUT NOCOPY    VARCHAR2,
     x_msg_count                 OUT NOCOPY    NUMBER,
     x_msg_data                  OUT NOCOPY    VARCHAR2 );

  PROCEDURE process_update_reports (
     P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     x_return_status             OUT NOCOPY    VARCHAR2,
     x_msg_count                 OUT NOCOPY    NUMBER,
     x_msg_data                  OUT NOCOPY    VARCHAR2 );

   PROCEDURE open_update_cursor (
     update_cursor               IN OUT  NOCOPY update_cursor_type,
     P_DML_RECORD                IN             HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE);

   PROCEDURE report_errors(
     P_DML_RECORD                IN      HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DML_EXCEPTION             IN      VARCHAR2);

   PROCEDURE populate_error_table(
     P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DUP_VAL_EXP               IN     VARCHAR2,
     P_SQL_ERRM                  IN     VARCHAR2  );

   PROCEDURE load_finreports (
     P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     x_return_status             OUT NOCOPY    VARCHAR2,
     x_msg_count                 OUT NOCOPY    NUMBER,
     x_msg_data                  OUT NOCOPY    VARCHAR2 )
   IS
   l_debug_prefix		       VARCHAR2(30) := '';
   BEGIN
     savepoint load_finreports_pvt;
     FND_MSG_PUB.initialize;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     --enable_debug;
     -- Debug info.
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FR:load_finreports()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

     process_insert_reports(P_DML_RECORD,
                            x_return_status, x_msg_count, x_msg_data  );

     IF x_return_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
       process_update_reports(P_DML_RECORD,
                              x_return_status, x_msg_count, x_msg_data  );
     END IF;

     -- Debug info.
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FR:load_finreports()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
     --disable_debug;

   EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --dbms_output.put_line('load finreport exception ' || SQLERRM);

     FND_FILE.put_line(fnd_file.log,'Execution error occurs while loading financial reports');
     FND_FILE.put_line(fnd_file.log, SQLERRM);
     ROLLBACK TO load_finreports_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --dbms_output.put_line('load finreport exception ' || SQLERRM);

     ROLLBACK TO load_finreports_pvt;
     FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading financial reports');
     FND_FILE.put_line(fnd_file.log, SQLERRM);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     --dbms_output.put_line('load finreport exception ' || SQLERRM);

     IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'load_finreports Exception:',
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>SQLERRM,
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;

     ROLLBACK TO load_finreports_pvt;
     FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading financial reports');
     FND_FILE.put_line(fnd_file.log, SQLERRM);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   END load_finreports;


   PROCEDURE process_insert_reports (
     P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     x_return_status             OUT NOCOPY    VARCHAR2,
     x_msg_count                 OUT NOCOPY    NUMBER,
     x_msg_data                  OUT NOCOPY    VARCHAR2 ) IS

     l_sql_query VARCHAR2(15000) := 'begin insert all
  when (audit_ind_err is not null -- include all the validation
   and consolidated_ind_err is not null
   and estimated_ind_err is not null
   and final_ind_err is not null
   and fiscal_ind_err is not null
   and forecast_ind_err is not null
   and opening_ind_err is not null
   and proforma_ind_err is not null
   and qualified_ind_err is not null
   and restated_ind_err is not null
   and signed_by_prin_err is not null
   and trial_balance_ind_err is not null
   and unbal_ind_err is not null
   and date_err is not null
   and action_mismatch_error is not null
   and parent_party_id is not null
   and party_id is not null
   and date_comb_err is not null
   and rpt_date_err is not null
   and createdby_error is not null
   ) then
  into hz_financial_reports (
       actual_content_source,
       content_source_type,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_id,
       program_application_id,
       program_update_date,
       application_id,
       request_id,
       FINANCIAL_REPORT_ID,
       PARTY_ID,
       STATUS,
       OBJECT_VERSION_NUMBER,
       AUDIT_IND,
       CONSOLIDATED_IND,
       CREATED_BY_MODULE,
       DATE_REPORT_ISSUED,
       DOCUMENT_REFERENCE,
       ESTIMATED_IND,
       FINAL_IND,
       FISCAL_IND,
       FORECAST_IND,
       ISSUED_PERIOD,
       OPENING_IND,
       PROFORMA_IND,
       QUALIFIED_IND,
       REPORT_END_DATE,
       REPORT_START_DATE,
       REQUIRING_AUTHORITY,
       RESTATED_IND,
       SIGNED_BY_PRINCIPALS_IND,
       TRIAL_BALANCE_IND,
       TYPE_OF_FINANCIAL_REPORT,
       UNBALANCED_IND)
values (
       :1, -- actual_content_source
       ''USER_ENTERED'', -- content_source_type
       :2, -- created_by
       :3, -- creation_date
       :2, -- last_updated_by
       :3, -- last_update_date
       :4, -- last_update_login
       :5, -- program_id
       :6, -- program_application_id
       :3, -- program_update_date
       :7, -- application_id
       :8, -- request_id
       financial_report_id,
       party_id,
       ''A'',
       1,
       audit_ind,
       consolidated_ind,
       created_by_module,
       date_report_issued,
       document_reference,
       estimated_ind,
       final_ind,
       fiscal_ind,
       forecast_ind,
       issued_period,
       opening_ind,
       proforma_ind,
       qualified_ind,
       report_end_date,
       report_start_date,
       requiring_authority,
       restated_ind,
       signed_by_principals_ind,
       trial_balance_ind,
       type_of_financial_report,
       unbalanced_ind)
  else
  into hz_imp_tmp_errors (
       error_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_id,
       program_application_id,
       program_update_date,
       batch_id,
       request_id,
       int_row_id,
       interface_table_name,
       ACTION_MISMATCH_FLAG,
       MISSING_PARENT_FLAG,
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
       e11_flag,
       e12_flag,
       e13_flag,
       e14_flag,
       e15_flag,
       e16_flag,
       e17_flag)
values (
       hz_imp_errors_s.nextval,
       :2, -- created_by
       :3, -- creation_date
       :2, -- last_updated_by
       :3, -- last_update_date
       :4, -- last_update_login
       :5, -- program_id
       :6, -- program_application_id
       :3, -- program_update_date
       :9,
       :8,
       row_id,
       ''HZ_IMP_FINREPORTS_INT'',
       action_mismatch_error,
       nvl2(parent_party_id,  ''Y'', null),
       date_err,
       audit_ind_err,
       consolidated_ind_err,
       estimated_ind_err,
       final_ind_err,
       fiscal_ind_err,
       forecast_ind_err,
       opening_ind_err,
       proforma_ind_err,
       qualified_ind_err,
       restated_ind_err,
       signed_by_prin_err,
       trial_balance_ind_err,
       unbal_ind_err,
       date_comb_err, -- date combination error
       rpt_date_err, -- only one report date provided
       createdby_error
       )
select row_id,
       financial_report_id,
       parent_party_id,
       party_id,
       audit_ind,
       consolidated_ind,
	   created_by_module,
       date_report_issued,
       document_reference,
       estimated_ind,
       final_ind,
       fiscal_ind,
       forecast_ind,
       issued_period,
       opening_ind,
       proforma_ind,
       qualified_ind,
       report_end_date,
       report_start_date,
       requiring_authority,
       restated_ind,
       signed_by_principals_ind,
       trial_balance_ind,
       type_of_financial_report,
       unbalanced_ind,
       decode(audit_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null) audit_ind_err,
       decode(consolidated_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null) consolidated_ind_err,
       decode(estimated_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null) estimated_ind_err,
       decode(final_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null) final_ind_err,
       decode(fiscal_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null) fiscal_ind_err,
       decode(forecast_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null) forecast_ind_err,
       decode(opening_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null) opening_ind_err,
       decode(proforma_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null) proforma_ind_err,
       decode(qualified_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null) qualified_ind_err,
       decode(restated_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null) restated_ind_err,
       decode(signed_by_principals_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null) signed_by_prin_err,
       decode(trial_balance_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null) trial_balance_ind_err,
       decode(unbalanced_ind, null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null) unbal_ind_err,
       nvl2(report_start_date, nvl2(report_end_date, decode(sign(report_end_date-report_start_date), -1, null, ''Y''), ''Y''), ''Y'') date_err,
       nvl2(nullif(insert_update_flag, action_flag), null, ''Y'') action_mismatch_error,
       nvl2(ISSUED_PERIOD, nvl2(REPORT_START_DATE, null, ''Y''), nvl2(REPORT_START_DATE, ''Y'', null)) date_comb_err,
       nvl2(REPORT_START_DATE, nvl2(REPORT_END_DATE, ''Y'', null), nvl2(REPORT_END_DATE, null, ''Y'')) rpt_date_err,
       createdby_error
  from (
select /*+ leading(fr_sg) use_nl(fr_int) rowid(fr_int) */
       hp.party_id parent_party_id,
       fr_int.rowid row_id,
       nullif(fr_int.insert_update_flag, :10) insert_update_flag,
       fr_sg.error_flag,
       fr_sg.action_flag,
       fr_sg.financial_report_id,
       fr_sg.party_id,
       nullif(fr_int.audit_ind, :10) audit_ind,
       nullif(fr_int.consolidated_ind, :10) consolidated_ind,
       nvl(nullif(fr_int.created_by_module, :10), ''HZ_IMPORT'') created_by_module,
       nvl2(nullif(fr_int.created_by_module, :10), nvl2(createdby_l.lookup_code,''Y'',null), ''Y'') createdby_error,
       nullif(fr_int.date_report_issued, :11) date_report_issued,
       fr_int.document_reference, -- logical key, cannot be null or g-miss
       nullif(fr_int.estimated_ind, :10) estimated_ind,
       nullif(fr_int.final_ind, :10) final_ind,
       nullif(fr_int.fiscal_ind, :10) fiscal_ind,
       nullif(fr_int.forecast_ind, :10) forecast_ind,
       nullif(fr_int.issued_period, :10) issued_period,
       nullif(fr_int.opening_ind, :10) opening_ind,
       nullif(fr_int.proforma_ind, :10) proforma_ind,
       nullif(fr_int.qualified_ind, :10) qualified_ind,
       nullif(fr_int.report_end_date, :11) report_end_date,
       nullif(fr_int.report_start_date, :11) report_start_date,
       nullif(fr_int.requiring_authority, :10) requiring_authority,
       nullif(fr_int.restated_ind, :10) restated_ind,
       nullif(fr_int.signed_by_principals_ind, :10) signed_by_principals_ind,
       nullif(fr_int.trial_balance_ind, :10) trial_balance_ind,
       fr_int.type_of_financial_report, -- logical key, cannot be null or g-miss
       nullif(fr_int.unbalanced_ind, :10) unbalanced_ind
  FROM hz_imp_finreports_int fr_int,
       hz_imp_finreports_sg fr_sg,
       hz_parties hp,
       fnd_lookup_values createdby_l
 WHERE fr_sg.party_orig_system = :12
   AND fr_sg.party_orig_system_reference between :13 AND :14
   AND fr_int.rowid = fr_sg.int_row_id
   AND fr_sg.action_flag = ''I''
   AND fr_sg.batch_mode_flag = :15
   AND fr_sg.batch_id = :9
   AND hp.party_id (+) = fr_sg.party_id
   AND hp.status (+) = ''A''
   AND createdby_l.lookup_code (+) = fr_int.created_by_module
   AND createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
   AND createdby_l.language (+) = userenv(''LANG'')
   AND createdby_l.view_application_id (+) = 222
   AND createdby_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
   ' ;

  l_where_enabled_lookup_sql varchar2(3000) :=
	' AND  ( createdby_l.ENABLED_FLAG(+) = ''Y'' AND
          TRUNC(:3) BETWEEN
          TRUNC(NVL( createdby_l.START_DATE_ACTIVE,:3 ) ) AND
          TRUNC(NVL( createdby_l.END_DATE_ACTIVE,:3 ) ) )
	  ';
  /*
     Fix bug 4175285: Remove duplicate selection.Since parties with same OS+OSR but different
     party_id can exist in a batch, when we querying, duplicate records may be created.
     E.g. There are 2 parties in a DNB batch:
    OS    OSR     PID    STATUS
    ---------------------------
    DNB   456     1002     A
    DNB   456     1003     A

    The Status will set to 'I' after stage 3. Without this where clause:
    'AND party_mosr.party_id = nvl(fr_sg.party_id,party_mosr.party_id)'
    The above query will return duplicate records for the same fin report and raise
    _U1 Unique index constraint error.

  */
   l_sql_query_end varchar2(15000):= '); end;';
   l_first_run_clause varchar2(40) := ' AND fr_int.interface_status is null';
   l_re_run_clause varchar2(40) := ' AND fr_int.interface_status = ''C''';
   l_final_qry varchar2(15000);
   l_debug_prefix		       VARCHAR2(30) := '';
   BEGIN
     -- Debug info.

     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FR:process_insert_reports()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

     savepoint process_insert_finreports_pvt;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- add clause for first-run/re-run
    IF P_DML_RECORD.ALLOW_DISABLED_LOOKUP = 'Y' THEN
     if(P_DML_RECORD.RERUN='N') then
       l_final_qry := l_sql_query || l_first_run_clause;
     else
       l_final_qry := l_sql_query || l_re_run_clause;
     end if;
    ELSE
     if(P_DML_RECORD.RERUN='N') then
       l_final_qry := l_sql_query || l_first_run_clause || l_where_enabled_lookup_sql ;
     else
       l_final_qry := l_sql_query || l_re_run_clause || l_where_enabled_lookup_sql ;
     end if;
    END IF;



     l_final_qry := l_final_qry || l_sql_query_end;

     execute immediate l_final_qry
     using
      P_DML_RECORD.ACTUAL_CONTENT_SRC,
      P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.PROGRAM_ID,
      P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.APPLICATION_ID,
      P_DML_RECORD.REQUEST_ID, P_DML_RECORD.BATCH_ID,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_DATE,
      P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR,
      P_DML_RECORD.BATCH_MODE_FLAG;

     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FR:process_insert_reports()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

   EXCEPTION
     WHEN DUP_VAL_ON_INDEX THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert fin reports dup val exception: ' || SQLERRM);
      ROLLBACK to process_insert_finreports_pvt;

      populate_error_table(P_DML_RECORD, 'Y', sqlerrm);
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

     WHEN OTHERS THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert fin reports other exception: ' || SQLERRM);
      ROLLBACK to process_insert_finreports_pvt;

       populate_error_table(P_DML_RECORD, 'N', sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

   END process_insert_reports;


   PROCEDURE populate_error_table(
     P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DUP_VAL_EXP               IN     VARCHAR2,
     P_SQL_ERRM                  IN     VARCHAR2  ) IS

     dup_val_exp_val             VARCHAR2(1) := null;
     other_exp_val               VARCHAR2(1) := 'Y';
     l_debug_prefix		 VARCHAR2(30) := '';
   BEGIN

     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FR:populate_error_table()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

     /* other entities need to add checking for other constraints */
     if (P_DUP_VAL_EXP = 'Y') then
       other_exp_val := null;
       if(instr(P_SQL_ERRM, '_U1')<>0) then
         dup_val_exp_val := 'A';
       else -- '_U2'
         dup_val_exp_val := 'B';
       end if;
     end if;

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
       DUP_VAL_IDX_EXCEP_FLAG,
       e1_flag,e2_flag,e3_flag,e4_flag,e5_flag,
       e6_flag,e7_flag,e8_flag,e9_flag,e10_flag,
       e11_flag,e12_flag,e13_flag,e14_flag,
       e15_flag, e16_flag,
       e17_flag,
       OTHER_EXCEP_FLAG,
       missing_parent_flag
     )
     (
       select P_DML_RECORD.REQUEST_ID,
              P_DML_RECORD.BATCH_ID,
              fr_sg.int_row_id,
              'HZ_IMP_FINREPORTS_INT',
              HZ_IMP_ERRORS_S.NextVal,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.LAST_UPDATE_LOGIN,
              P_DML_RECORD.PROGRAM_APPLICATION_ID,
              P_DML_RECORD.PROGRAM_ID,
              P_DML_RECORD.SYSDATE,
              dup_val_exp_val,
              -- this function report errors for exception
              -- not checking all other potential errors
              'Y','Y','Y','Y','Y','Y','Y', 'Y',
              'Y','Y','Y','Y','Y','Y','Y', 'Y',
              'Y',
              other_exp_val, 'Y'
         from hz_imp_finreports_sg fr_sg
        where fr_sg.action_flag = 'I'
          and fr_sg.batch_id = P_DML_RECORD.BATCH_ID
          and fr_sg.party_orig_system = P_DML_RECORD.OS
          and fr_sg.party_orig_system_reference
              between P_DML_RECORD.FROM_OSR and P_DML_RECORD.TO_OSR
     );

     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FR:populate_error_table()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

   END populate_error_table;


   PROCEDURE process_update_reports (
     P_DML_RECORD      IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     x_return_status             OUT NOCOPY    VARCHAR2,
     x_msg_count                 OUT NOCOPY    NUMBER,
     x_msg_data                  OUT NOCOPY    VARCHAR2 ) IS
     c_update_cursor             update_cursor_type;
     l_dml_exception             varchar2(1) := 'N';
     l_debug_prefix		 VARCHAR2(30) := '';
   BEGIN
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'process_update_reports()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
     savepoint process_update_reports_pvt;
     FND_MSG_PUB.initialize;
     --Initialize API return status to success.
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     open_update_cursor(c_update_cursor, P_DML_RECORD);
     fetch c_update_cursor bulk collect into
       l_row_id,
       l_action_error_flag,
       l_action_flag,
       l_fr_id,
       l_party_id,
       l_audit_ind,
       l_consolidated_ind,
       l_created_by_module,
       l_date_rpt_issued,
       l_doc_ref,
       l_estimated_ind,
       l_final_ind,
       l_fiscal_ind,
       l_forecast_ind,
       l_issued_period,
       l_opening_ind,
       l_proforma_ind,
       l_qualified_ind,
       l_rpt_end_date,
       l_rpt_start_date,
       l_req_auth,
       l_restated_ind,
       l_signed_by_prin,
       l_trial_balance_ind,
       l_type_of_finreport,
       l_unbal_ind,
       l_audit_ind_err,
       l_consolidated_ind_err,
       l_estimated_ind_err,
       l_final_ind_err,
       l_fiscal_ind_err,
       l_forecast_ind_err,
       l_opening_ind_err,
       l_proforma_ind_err,
       l_qualified_ind_err,
       l_restated_ind_err,
       l_signed_by_prin_err,
       l_trial_balance_ind_err,
       l_unbal_ind_err,
       l_date_err,
       l_action_error_flag,
       l_error_flag,
       l_date_comb_flag,
       l_rpt_date_flag;
     close c_update_cursor;

     forall j in 1..l_fr_id.count
       update hz_financial_reports set
         PROGRAM_ID             = P_DML_RECORD.PROGRAM_ID,
         PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
         PROGRAM_UPDATE_DATE   = P_DML_RECORD.SYSDATE,
         REQUEST_ID            = P_DML_RECORD.REQUEST_ID,
         LAST_UPDATE_LOGIN     = P_DML_RECORD.LAST_UPDATE_LOGIN,
         LAST_UPDATE_DATE      = P_DML_RECORD.SYSDATE,
         LAST_UPDATED_BY       = P_DML_RECORD.USER_ID,
         OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
         APPLICATION_ID        = NVL(APPLICATION_ID, P_DML_RECORD.APPLICATION_ID),
  	     -- don't modify old value if new one is null
         REQUIRING_AUTHORITY   = DECODE(l_req_auth(j), NULL, REQUIRING_AUTHORITY, P_DML_RECORD.GMISS_CHAR, NULL, l_req_auth(j)),
  	     AUDIT_IND        = DECODE(l_audit_ind(j), NULL, AUDIT_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_audit_ind(j)),
  	     CONSOLIDATED_IND = DECODE(l_consolidated_ind(j), NULL, CONSOLIDATED_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_consolidated_ind(j)),
  	     ESTIMATED_IND    = DECODE(l_estimated_ind(j), NULL, ESTIMATED_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_estimated_ind(j)),
  	     FINAL_IND        = DECODE(l_final_ind(j), NULL, FINAL_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_final_ind(j)),
  	     FISCAL_IND       = DECODE(l_fiscal_ind(j), NULL, FISCAL_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_fiscal_ind(j)),
  	     FORECAST_IND     = DECODE(l_forecast_ind(j), NULL, FORECAST_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_forecast_ind(j)),
  	     OPENING_IND      = DECODE(l_opening_ind(j), NULL, OPENING_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_opening_ind(j)),
  	     PROFORMA_IND     = DECODE(l_proforma_ind(j), NULL, PROFORMA_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_proforma_ind(j)),
  	     QUALIFIED_IND    = DECODE(l_qualified_ind(j), NULL, QUALIFIED_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_qualified_ind(j)),
  	     RESTATED_IND     = DECODE(l_restated_ind(j), NULL, RESTATED_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_restated_ind(j)),
  	     TRIAL_BALANCE_IND        = DECODE(l_trial_balance_ind(j), NULL, TRIAL_BALANCE_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_trial_balance_ind(j)),
  	     UNBALANCED_IND           = DECODE(l_unbal_ind(j), NULL, UNBALANCED_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_unbal_ind(j)),
  	     SIGNED_BY_PRINCIPALS_IND = DECODE(l_signed_by_prin(j), NULL, SIGNED_BY_PRINCIPALS_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_signed_by_prin(j))
--         CREATED_BY_MODULE        = NVL(CREATED_BY_MODULE, decode(l_created_by_module(j),P_DML_RECORD.GMISS_CHAR, CREATED_BY_MODULE, null, CREATED_BY_MODULE,l_created_by_module(j)))
   where FINANCIAL_REPORT_ID = l_fr_id(j)
     and l_audit_ind_err(j) is not null
     and l_consolidated_ind_err(j) is not null
     and l_estimated_ind_err(j) is not null
     and l_final_ind_err(j) is not null
     and l_fiscal_ind_err(j) is not null
     and l_forecast_ind_err(j) is not null
     and l_opening_ind_err(j) is not null
     and l_proforma_ind_err(j) is not null
     and l_qualified_ind_err(j) is not null
     and l_restated_ind_err(j) is not null
     and l_signed_by_prin_err(j) is not null
     and l_trial_balance_ind_err(j) is not null
     and l_unbal_ind_err(j) is not null
     and l_action_error_flag(j) is not null
     and l_error_flag(j) is null
     and l_date_comb_flag(j) is not null
     and l_rpt_date_flag(j) is not null
     ;

     report_errors(P_DML_RECORD, l_dml_exception);

     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'process_update_reports()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Update reports other exception: ' || SQLERRM);

        ROLLBACK to process_update_reports_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

   END process_update_reports;


   PROCEDURE open_update_cursor (update_cursor     IN OUT NOCOPY update_cursor_type,
                                 P_DML_RECORD      IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
   ) IS
   l_sql_query varchar2(11000) :=
	   'SELECT /*+ leading(fr_sg) use_nl(fr_int) rowid(fr_int) */
        fr_int.ROWID,
        fr_int.insert_update_flag,
        fr_sg.action_flag,
        fr_sg.financial_report_id,
        fr_sg.party_id,
        fr_int.AUDIT_IND,
        fr_int.CONSOLIDATED_IND,
        fr_int.CREATED_BY_MODULE,
        fr_int.DATE_REPORT_ISSUED,
        fr_int.DOCUMENT_REFERENCE,
        fr_int.ESTIMATED_IND,
        fr_int.FINAL_IND,
        fr_int.FISCAL_IND,
        fr_int.FORECAST_IND,
        fr_int.ISSUED_PERIOD,
        fr_int.OPENING_IND,
        fr_int.PROFORMA_IND,
        fr_int.QUALIFIED_IND,
        fr_int.REPORT_END_DATE,
        fr_int.REPORT_START_DATE,
        fr_int.REQUIRING_AUTHORITY,
        fr_int.RESTATED_IND,
        fr_int.SIGNED_BY_PRINCIPALS_IND,
        fr_int.TRIAL_BALANCE_IND,
        fr_int.TYPE_OF_FINANCIAL_REPORT,
        fr_int.UNBALANCED_IND,
        decode(fr_int.AUDIT_IND, :G_MISS_CHAR, ''Y'', null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null),
        decode(fr_int.CONSOLIDATED_IND, :G_MISS_CHAR, ''Y'', null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null),
        decode(fr_int.ESTIMATED_IND, :G_MISS_CHAR, ''Y'', null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null),
        decode(fr_int.FINAL_IND, :G_MISS_CHAR, ''Y'', null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null),
        decode(fr_int.FISCAL_IND, :G_MISS_CHAR, ''Y'', null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null),
        decode(fr_int.FORECAST_IND, :G_MISS_CHAR, ''Y'', null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null),
        decode(fr_int.OPENING_IND, :G_MISS_CHAR, ''Y'', null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null),
        decode(fr_int.PROFORMA_IND, :G_MISS_CHAR, ''Y'', null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null),
        decode(fr_int.QUALIFIED_IND, :G_MISS_CHAR, ''Y'', null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null),
        decode(fr_int.RESTATED_IND, :G_MISS_CHAR, ''Y'', null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null),
        decode(fr_int.SIGNED_BY_PRINCIPALS_IND, :G_MISS_CHAR, ''Y'', null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null),
        decode(fr_int.TRIAL_BALANCE_IND, :G_MISS_CHAR, ''Y'', null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null),
        decode(fr_int.UNBALANCED_IND, :G_MISS_CHAR, ''Y'', null, ''Y'', ''Y'', ''Y'', ''N'', ''Y'', null),
        decode(fr_int.REPORT_END_DATE, :P_G_MISS_DATE, ''Y'',
          decode(fr_int.REPORT_START_DATE, :P_G_MISS_DATE, ''Y'',
           decode( nvl(fr_int.REPORT_END_DATE, hz_fr.REPORT_END_DATE) , null, ''Y'',
           decode( nvl(fr_int.REPORT_START_DATE, hz_fr.REPORT_START_DATE) , null, ''Y'',
           decode(sign(nvl(fr_int.REPORT_END_DATE, hz_fr.REPORT_END_DATE)- nvl(fr_int.REPORT_START_DATE, hz_fr.REPORT_START_DATE)), -1, null, ''Y''))))),
        decode(nvl(fr_int.insert_update_flag, fr_sg.action_flag), fr_sg.action_flag, ''Y'', null) action_mismatch_error,
        fr_sg.error_flag,
       nvl2(fr_int.ISSUED_PERIOD, nvl2(fr_int.REPORT_START_DATE, null, ''Y''), nvl2(fr_int.REPORT_START_DATE, ''Y'', null)) date_comb_err,
       nvl2(fr_int.REPORT_START_DATE, nvl2(fr_int.REPORT_END_DATE, ''Y'', null), nvl2(fr_int.REPORT_END_DATE, null, ''Y'')) rpt_date_err
   FROM hz_imp_finreports_int fr_int,
        hz_imp_finreports_sg  fr_sg,
        hz_financial_reports hz_fr
  WHERE fr_sg.batch_id = :P_BATCH_ID
    AND fr_sg.batch_mode_flag = :BATCH_MODE_FLAG
    AND fr_sg.party_orig_system = :P_OS
    AND fr_sg.party_orig_system_reference  between :P_FROM_OSR AND :TO_OSR
    AND fr_sg.action_flag = ''U''
    AND fr_int.rowid = fr_sg.int_row_id
    and hz_fr.financial_report_id = fr_sg.financial_report_id';

   l_first_run_clause varchar2(40) := ' AND fr_int.interface_status is null';
   l_re_run_clause varchar2(40) := ' AND fr_int.interface_status = ''C''';
   l_debug_prefix		       VARCHAR2(30) := '';
   BEGIN

   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FR:open_update_cursor()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

   if(P_DML_RECORD.RERUN='Y') then
     OPEN update_cursor FOR l_sql_query || l_re_run_clause
       USING P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
       P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
       P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
       P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_DATE,
       P_DML_RECORD.BATCH_ID, P_DML_RECORD.BATCH_MODE_FLAG,
       P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR;
   else
     OPEN update_cursor FOR l_sql_query || l_first_run_clause
       USING P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
       P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
       P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
       P_DML_RECORD.GMISS_DATE, P_DML_RECORD.GMISS_DATE,
       P_DML_RECORD.BATCH_ID, P_DML_RECORD.BATCH_MODE_FLAG,
       P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR;
   end if;

   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FR:open_update_cursor()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

   END open_update_cursor;


PROCEDURE report_errors(
  P_DML_RECORD          IN      HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
  P_DML_EXCEPTION       IN      VARCHAR2
) IS

  num_exp NUMBER;
  exp_ind NUMBER := 1;
  l_debug_prefix  VARCHAR2(30) := '';
BEGIN
   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FR:report_errors()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

  /**********************************/
  /* Validation and Error reporting */
  /**********************************/
  IF l_fr_id.count = 0 THEN
    return;
  END IF;

  l_num_row_processed := null;
  l_num_row_processed := NUMBER_COLUMN();
  l_num_row_processed.extend(l_fr_id.count);
  l_exception_exists := null;
  l_exception_exists := FLAG_ERROR();
  l_exception_exists.extend(l_fr_id.count);
  num_exp := SQL%BULK_EXCEPTIONS.COUNT;

  FOR k IN 1..l_fr_id.count LOOP

    IF SQL%BULK_ROWCOUNT(k) = 0 THEN
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'DML fails at ' || k,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      l_num_row_processed(k) := 0;

      /* Check for any exceptions during DML               */
      /* Note: Financial number update would not cause any */
      /*       dup val exception, other entities copying   */
      /*       the code may need to take care of that.     */
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
  forall j in 1..l_fr_id.count
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
       e1_flag,e2_flag,e3_flag,e4_flag,e5_flag,
       e6_flag,e7_flag,e8_flag,e9_flag,e10_flag,
       e11_flag,e12_flag,e13_flag,e14_flag,e15_flag,e16_flag,
       e17_flag,
       OTHER_EXCEP_FLAG,
       MISSING_PARENT_FLAG
    )
    (
      select P_DML_RECORD.REQUEST_ID,
             P_DML_RECORD.BATCH_ID,
             l_row_id(j),
             'HZ_IMP_FINREPORTS_INT',
             HZ_IMP_ERRORS_S.NextVal,
             P_DML_RECORD.SYSDATE,
             P_DML_RECORD.USER_ID,
             P_DML_RECORD.SYSDATE,
             P_DML_RECORD.USER_ID,
             P_DML_RECORD.LAST_UPDATE_LOGIN,
             P_DML_RECORD.PROGRAM_APPLICATION_ID,
             P_DML_RECORD.PROGRAM_ID,
             P_DML_RECORD.SYSDATE,
             l_action_error_flag(j),
             l_date_err(j), -- e1
             l_audit_ind_err(j),
             l_consolidated_ind_err(j),
             l_estimated_ind_err(j),
             l_final_ind_err(j),
             l_fiscal_ind_err(j),
             l_forecast_ind_err(j),
             l_opening_ind_err(j),
             l_proforma_ind_err(j),
             l_qualified_ind_err(j),
             l_restated_ind_err(j), -- e11
             l_signed_by_prin_err(j),
             l_trial_balance_ind_err(j),
             l_unbal_ind_err(j),
             l_date_comb_flag(j),
             l_rpt_date_flag(j),
             'Y',
             l_exception_exists(j), 'Y'
        from dual
       where l_num_row_processed(j) = 0
    );

   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FR:report_errors()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

END report_errors;

  --------------------------------------
  -- private procedures and functions
  --------------------------------------
    --------------------------------------
  /*PROCEDURE enable_debug IS
  BEGIN
    g_debug_count := g_debug_count + 1;

    IF g_debug_count = 1 THEN
      IF fnd_profile.value('HZ_API_FILE_DEBUG_ON') = 'Y' OR
       fnd_profile.value('HZ_API_DBMS_DEBUG_ON') = 'Y'
      THEN
        hz_utility_v2pub.enable_debug;
        g_debug := TRUE;
      END IF;
    END IF;
  END enable_debug;      -- end procedure
  */
  --------------------------------------
  --------------------------------------
  /*PROCEDURE disable_debug IS
    BEGIN

      IF g_debug THEN
        g_debug_count := g_debug_count - 1;
             IF g_debug_count = 0 THEN
               hz_utility_v2pub.disable_debug;
               g_debug := FALSE;
            END IF;
      END IF;

   END disable_debug;
   */


END HZ_IMP_LOAD_FINREPORTS_PKG;

/
