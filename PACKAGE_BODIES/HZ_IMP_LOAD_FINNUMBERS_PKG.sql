--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_FINNUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_FINNUMBERS_PKG" AS
/*$Header: ARHLFNNB.pls 120.3 2006/01/17 08:36:17 vravicha noship $*/


   c_end_date                DATE := to_date('4712.12.31 00:01','YYYY.MM.DD HH24:MI');
   g_debug_count             NUMBER := 0;
   --g_debug                   BOOLEAN := FALSE;

   l_fn_id                   FN_ID;
   l_fr_id                   FR_ID;
   l_tca_fr_id               TCA_FR_ID;

   l_fin_num                 FINANCIAL_NUMBER;
   l_fin_num_name            FINANCIAL_NUMBER_NAME ;
   l_fin_num_cur             FINANCIAL_NUMBER_CURRENCY;
   l_proj_act_flag           PROJECTED_ACTUAL_FLAG;
   l_fin_units_applied       FINANCIAL_UNITS_APPLIED;
   l_created_by_module       CREATED_BY_MODULE;
   l_action_flag             ACTION_FLAG;
   --l_fin_num_name_err        LOOKUP_ERROR;
   l_action_error_flag       FLAG_ERROR;
   l_error_flag              FLAG_ERROR;

   l_exception_exists        FLAG_ERROR;
   l_num_row_processed       NUMBER_COLUMN;
   l_row_id                  ROWID;

   l_createdby_errors        LOOKUP_ERROR;

   PROCEDURE open_update_cursor (
     update_cursor               IN OUT NOCOPY        update_cursor_type,
     P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE );


   PROCEDURE process_insert_finnumbers (
     P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     x_return_status             OUT NOCOPY    VARCHAR2,
     x_msg_count                 OUT NOCOPY    NUMBER,
     x_msg_data                  OUT NOCOPY    VARCHAR2 );


   PROCEDURE process_update_finnumbers (
     P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     x_return_status             OUT NOCOPY    VARCHAR2,
     x_msg_count                 OUT NOCOPY    NUMBER,
     x_msg_data                  OUT NOCOPY    VARCHAR2 );


   PROCEDURE report_errors(
     P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DML_EXCEPTION             IN            VARCHAR2);


   PROCEDURE populate_error_table(
     P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DUP_VAL_EXP               IN     VARCHAR2 );

  --------------------------------------
  -- forward declaration of private procedures and functions
  --------------------------------------

   /*PROCEDURE enable_debug;
   PROCEDURE disable_debug;
   */

   PROCEDURE load_finnumbers (
     P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     x_return_status             OUT NOCOPY    VARCHAR2,
     x_msg_count                 OUT NOCOPY    NUMBER,
     x_msg_data                  OUT NOCOPY    VARCHAR2 )
   IS
   l_debug_prefix		       VARCHAR2(30) := '';
   BEGIN
     savepoint load_finnumbers_pvt;
     FND_MSG_PUB.initialize;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     --enable_debug;
     -- Debug info.
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FN:load_finnumbers()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

     process_insert_finnumbers(P_DML_RECORD,
                               x_return_status, x_msg_count, x_msg_data  );

     IF x_return_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
       process_update_finnumbers(P_DML_RECORD,
                                 x_return_status, x_msg_count, x_msg_data  );
     END IF;

     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FN:load_finnumbers()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
     END IF;
     --disable_debug;

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ----dbms_output.put_line('G_EXC_ERROR');

     ROLLBACK TO load_finnumbers_pvt;
     FND_FILE.put_line(fnd_file.log,'Execution error occurs while loading financial numbers');
     FND_FILE.put_line(fnd_file.log, SQLERRM);
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ----dbms_output.put_line('Unexpected error occurs while loading financial numbers');

     ROLLBACK TO load_finnumbers_pvt;
     FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading financial numbers');
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
     IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'load_finnumbers Exception: ',
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>SQLERRM,
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
     END IF;
     ----dbms_output.put_line('load_finnumbers Exception: ');

     ROLLBACK TO load_finnumbers_pvt;
     FND_FILE.put_line(fnd_file.log,'Unexpected other errors occurs while loading financial numbers');
     FND_FILE.put_line(fnd_file.log, SQLERRM);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   END load_finnumbers;


   PROCEDURE open_update_cursor ( update_cursor      IN OUT NOCOPY  update_cursor_type,
                                  P_DML_RECORD       IN      HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE) IS
   l_sql_query VARCHAR2(11000) :=
'SELECT fn_int.ROWID,
        fn_sg.action_flag,
        fn_sg.financial_report_id,
        fn_sg.financial_number_id,
        fn_int.FINANCIAL_NUMBER,
        fn_int.FINANCIAL_NUMBER_NAME,
        fn_int.FINANCIAL_NUMBER_CURRENCY,
        fn_int.PROJECTED_ACTUAL_FLAG,
        fn_int.FINANCIAL_UNITS_APPLIED,
        fn_int.CREATED_BY_MODULE,
        decode(nvl(fn_int.insert_update_flag, fn_sg.action_flag), fn_sg.action_flag, ''Y'', null),
        fn_sg.error_flag
   FROM hz_imp_finnumbers_int fn_int,
        hz_imp_finnumbers_sg fn_sg
  WHERE fn_sg.batch_id = :BATCH_ID
    and fn_sg.batch_mode_flag = :BATCH_MODE_FLAG
    and fn_sg.party_orig_system = :WU_OS
    and fn_sg.party_orig_system_reference between :FROM_OSR AND :TO_OSR
    and fn_sg.action_flag = ''U''
    and fn_int.rowid = fn_sg.int_row_id';

   l_first_run_clause varchar2(40) := ' AND fn_int.interface_status is null';
   l_re_run_clause varchar2(40) := ' AND fn_int.interface_status = ''C''';
   l_debug_prefix		       VARCHAR2(30) := '';
   --l_where_enabled_lookup_sql varchar2(3000) :=	' AND  ( fin_num_l.ENABLED_FLAG(+) = ''Y'' )';

   BEGIN

   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FN:open_update_cursor()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
   END IF;

   if(P_DML_RECORD.RERUN='Y') then
     l_sql_query := l_sql_query || l_re_run_clause;
   else
     l_sql_query := l_sql_query || l_first_run_clause;
   end if;

   OPEN update_cursor FOR l_sql_query
       USING --P_DML_RECORD.GMISS_CHAR,
       P_DML_RECORD.BATCH_ID, P_DML_RECORD.BATCH_MODE_FLAG,
       P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR;


   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FN:open_update_cursor()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
   END IF;
   END open_update_cursor;


   PROCEDURE process_insert_finnumbers (
     P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     x_return_status             OUT NOCOPY    VARCHAR2,
     x_msg_count                 OUT NOCOPY    NUMBER,
     x_msg_data                  OUT NOCOPY    VARCHAR2 ) IS

   l_sql_query VARCHAR2(15000) :=
'begin insert all
  when (action_flag = ''I''
   and fin_num_name_err is not null
   and action_mismatch_error is not null
   and createdby_error is not null
   and tca_fr_id is not null) then
  into hz_financial_numbers (
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_update_date,
       request_id,
       actual_content_source,
       application_id,
       content_source_type,
       program_application_id,
       program_id,
       FINANCIAL_NUMBER_ID,
       FINANCIAL_REPORT_ID,
       FINANCIAL_NUMBER,
       FINANCIAL_NUMBER_NAME,
       FINANCIAL_NUMBER_CURRENCY,
       PROJECTED_ACTUAL_FLAG,
       FINANCIAL_UNITS_APPLIED,
       STATUS,
       OBJECT_VERSION_NUMBER,
       CREATED_BY_MODULE)
values (
       :1,
       :2,
       :1,
       :2,
       :3,
       :2,
       :4,
       :5,
       :6,
       ''USER_ENTERED'',
       :7,
       :8,
       fn_id,
       fr_id,
       fin_num,
       fin_num_name,
       fin_num_cur,
       nvl(proj_act_flag, ''A''),
       fin_units_applied,
       ''A'',
       1,
       created_by_module)
  else
  into hz_imp_tmp_errors (
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_update_date,
       program_application_id,
       program_id,
       error_id,
       batch_id,
       request_id,
       int_row_id,
       interface_table_name,
       ACTION_MISMATCH_FLAG,
       MISSING_PARENT_FLAG,
       e1_flag,
       e2_flag)
values (
       :1,
       :2,
       :1,
       :2,
       :3,
       :2,
       :7,
       :8,
       hz_imp_errors_s.nextval,
       :9,
       :4,
       row_id,
       ''HZ_IMP_FINNUMBERS_INT'',
       action_mismatch_error,
       nvl2(tca_fr_id, ''Y'', null),
       fin_num_name_err,
       createdby_error)
select row_id, action_flag, fr_id, nvl2(ranking, tca_fr_id, null) tca_fr_id, fn_id, fin_num, fin_num_name,
       fin_num_cur, proj_act_flag, fin_units_applied, created_by_module,
       fin_num_name_err, action_mismatch_error, error_flag, createdby_error
  from (
select row_id, action_flag, fr_id, tca_fr_id, fn_id, fin_num, fin_num_name,
       fin_num_cur, proj_act_flag, fin_units_applied, created_by_module,
       nvl2(lkup, ''Y'', null) fin_num_name_err,
       action_mismatch_error, error_flag, createdby_error,
       rank() over
       (partition by row_id order by ranking nulls last) new_rank,
       ranking
  from (
select /*+ use_nl(fin_num_l) */ fn_int.rowid row_id,
       fn_sg.action_flag,
       fn_sg.financial_report_id fr_id,         -- logical key
       hz_fr.financial_report_id tca_fr_id,
       fn_sg.financial_number_id fn_id,
       nullif(fn_int.financial_number_name, :10) fin_num_name,  -- logical key
       nullif(fn_int.financial_number, :11) fin_num,
       nullif(fn_int.financial_number_currency, :10) fin_num_cur,
       nullif(fn_int.projected_actual_flag, :10) proj_act_flag,
       nullif(fn_int.financial_units_applied, :11) fin_units_applied,
       nvl(nullif(fn_int.created_by_module, :10), ''HZ_IMPORT'') created_by_module,
       nvl2(nullif(fn_int.created_by_module, :10), nvl2(createdby_l.lookup_code,''Y'',null), ''Y'') createdby_error,
       fin_num_l.lookup_code lkup,
       nvl2(nullif(nullif(fn_int.insert_update_flag, :10), fn_sg.action_flag), null, ''Y'') action_mismatch_error,
       fn_sg.error_flag error_flag,
	 case when fn_sg.ISSUED_PERIOD = hz_fr.ISSUED_PERIOD then 1
	      when trunc(fn_sg.REPORT_START_DATE) =
		   trunc(hz_fr.REPORT_START_DATE)
	       and trunc(fn_sg.REPORT_END_DATE) =
		   trunc(hz_fr.REPORT_END_DATE) then 2 end ranking
  from hz_imp_finnumbers_int fn_int,
       hz_imp_finnumbers_sg fn_sg,
       fnd_lookup_values fin_num_l,
       hz_financial_reports hz_fr,
       fnd_lookup_values createdby_l
 where fn_sg.batch_id = :9
   and fn_sg.party_orig_system = :12
   and fn_sg.party_orig_system_reference between :13 and :14
   and fn_sg.action_flag = ''I''
   and fn_int.rowid = fn_sg.int_row_id
   and fin_num_l.lookup_code(+) =  fn_int.financial_number_name
   and fin_num_l.lookup_type(+) = ''FIN_NUM_NAME''
   and fin_num_l.language (+) = userenv(''LANG'')
   and fin_num_l.view_application_id (+) = 222
   and fin_num_l.security_group_id (+) =
       fnd_global.lookup_security_group(''FIN_NUM_NAME'', 222)
   AND createdby_l.lookup_code (+) = fn_int.created_by_module
   AND createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
   AND createdby_l.language (+) = userenv(''LANG'')
   AND createdby_l.view_application_id (+) = 222
   AND createdby_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
   and fn_sg.party_id = hz_fr.party_id (+)
   and nvl(trunc(fn_sg.DATE_REPORT_ISSUED), :15) =
       nvl(trunc(hz_fr.DATE_REPORT_ISSUED (+) ) , :15)
   and fn_sg.type_of_financial_report = hz_fr.type_of_financial_report (+)
   and fn_sg.document_reference = hz_fr.document_reference (+)
   and hz_fr.ACTUAL_CONTENT_SOURCE (+) = :5
   and fn_sg.batch_mode_flag = :16';

   l_sql_query_end varchar2(15000):= ' )) where new_rank = 1; end;';
   l_first_run_clause varchar2(40) := ' AND fn_int.interface_status is null';
   l_re_run_clause varchar2(40) := ' AND fn_int.interface_status = ''C''';
   l_final_qry varchar2(15000);
   l_debug_prefix VARCHAR2(30) := '';
   --l_where_enabled_lookup_sql varchar2(3000) := ' AND fin_num_l.ENABLED_FLAG(+) = ''Y''';
   l_where_enabled_lookup_sql varchar2(3000) := ' AND  ( fin_num_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:17) BETWEEN
	  TRUNC(NVL( fin_num_l.START_DATE_ACTIVE,:17 ) ) AND
	  TRUNC(NVL( fin_num_l.END_DATE_ACTIVE,:17 ) ) )
          AND  ( createdby_l.ENABLED_FLAG(+) = ''Y'' AND
          TRUNC(:17) BETWEEN
          TRUNC(NVL( createdby_l.START_DATE_ACTIVE,:17 ) ) AND
          TRUNC(NVL( createdby_l.END_DATE_ACTIVE,:17 ) ) )';

   BEGIN
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'process_insert_finnumbers()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
     END IF;
     savepoint process_insert_finnumbers_pvt;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     if(P_DML_RECORD.RERUN='N') then
       l_final_qry := l_sql_query || l_first_run_clause;
     else
       l_final_qry := l_sql_query || l_re_run_clause;
     end if;

     -- add clause for filtering out disabled lookup
     if P_DML_RECORD.ALLOW_DISABLED_LOOKUP <> 'Y' then
       l_final_qry := l_final_qry || l_where_enabled_lookup_sql;
       l_final_qry := l_final_qry || l_sql_query_end;
       execute immediate l_final_qry using
       P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE,
       P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
       P_DML_RECORD.ACTUAL_CONTENT_SRC, P_DML_RECORD.APPLICATION_ID,
       P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID,
       P_DML_RECORD.BATCH_ID, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_NUM,
       P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR,
       c_end_date, P_DML_RECORD.BATCH_MODE_FLAG,P_DML_RECORD.SYSDATE;
     else
       l_final_qry := l_final_qry || l_sql_query_end;
       execute immediate l_final_qry using
       P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE,
       P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.REQUEST_ID,
       P_DML_RECORD.ACTUAL_CONTENT_SRC, P_DML_RECORD.APPLICATION_ID,
       P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID,
       P_DML_RECORD.BATCH_ID, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_NUM,
       P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR,
       c_end_date, P_DML_RECORD.BATCH_MODE_FLAG;
     end if;

     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'process_insert_finnumbers()-',
	                          p_prefix=>l_debug_prefix,
			                  p_msg_level=>fnd_log.level_procedure);
    END IF;

   EXCEPTION
     WHEN DUP_VAL_ON_INDEX THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert finnumbers dup val exception: ' || SQLERRM);
      ROLLBACK to process_insert_finnumbers_pvt;

      populate_error_table(P_DML_RECORD, 'Y');
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
     WHEN OTHERS THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert finnumbers other exception: ' || SQLERRM);
      ROLLBACK to process_insert_finnumbers_pvt;

      populate_error_table(P_DML_RECORD, 'N');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
   END process_insert_finnumbers;


   PROCEDURE populate_error_table(
     P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DUP_VAL_EXP               IN     VARCHAR2 ) IS

     dup_val_exp_val             VARCHAR2(1) := null;
     other_exp_val               VARCHAR2(1) := 'Y';
     l_debug_prefix		       VARCHAR2(30) := '';
   BEGIN
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FN:populate_error_table()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

     if (P_DUP_VAL_EXP = 'Y') then
       dup_val_exp_val := 'Y';
       other_exp_val := null;
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
       OTHER_EXCEP_FLAG,
       e1_flag,
       e2_flag,
       missing_parent_flag
     )
     (
       select P_DML_RECORD.REQUEST_ID,
              P_DML_RECORD.BATCH_ID,
              fn_sg.int_row_id,
              'HZ_IMP_FINNUMBERS_INT',
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
              other_exp_val,
              -- this function report errors for exception
              -- not checking all other potential errors
              'Y', 'Y', 'Y'
         from hz_imp_finnumbers_sg fn_sg
        where fn_sg.action_flag = 'I'
          and fn_sg.batch_id = P_DML_RECORD.BATCH_ID
          and fn_sg.party_orig_system = P_DML_RECORD.OS
          and fn_sg.party_orig_system_reference
              between P_DML_RECORD.FROM_OSR and P_DML_RECORD.TO_OSR
     );

     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FN:populate_error_table()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
   END populate_error_table;


   PROCEDURE process_update_finnumbers (
     P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     x_return_status             OUT NOCOPY    VARCHAR2,
     x_msg_count                 OUT NOCOPY    NUMBER,
     x_msg_data                  OUT NOCOPY    VARCHAR2 ) IS
     c_update_cursor             update_cursor_type;
     l_dml_exception             varchar2(1) := 'N';
     l_debug_prefix		       VARCHAR2(30) := '';
   BEGIN

     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FN:process_update_finnumbers()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
     savepoint process_update_finnumbers_pvt;
     FND_MSG_PUB.initialize;
     --Initialize API return status to success.
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     open_update_cursor(c_update_cursor, P_DML_RECORD);
     fetch c_update_cursor bulk collect into
       l_row_id,
       l_action_flag,
       l_fr_id,         -- logical key
       l_fn_id,
       l_fin_num,
       l_fin_num_name,  -- logical key
       l_fin_num_cur,
       l_proj_act_flag,
       l_fin_units_applied,
       l_created_by_module,
       --l_fin_num_name_err,
       l_action_error_flag,
       l_error_flag;
     close c_update_cursor;

     --begin
     forall j in 1..l_fn_id.count
  update hz_financial_numbers set
         PROGRAM_APPLICATION_ID = PROGRAM_APPLICATION_ID ,
         PROGRAM_ID             = PROGRAM_ID ,
         PROGRAM_UPDATE_DATE    = P_DML_RECORD.SYSDATE,
         FINANCIAL_NUMBER          = decode(l_fin_num(j), P_DML_RECORD.GMISS_CHAR, null, l_fin_num(j)),
         FINANCIAL_NUMBER_CURRENCY = decode(l_fin_num_cur(j), P_DML_RECORD.GMISS_CHAR, null, l_fin_num_cur(j)),
         PROJECTED_ACTUAL_FLAG     = decode(l_proj_act_flag(j), P_DML_RECORD.GMISS_CHAR, 'A', null, 'A', l_proj_act_flag(j)),
         FINANCIAL_UNITS_APPLIED   = decode(l_fin_units_applied(j), P_DML_RECORD.GMISS_CHAR, null, l_fin_units_applied(j)),
         REQUEST_ID                = P_DML_RECORD.REQUEST_ID,
         LAST_UPDATE_LOGIN     = P_DML_RECORD.USER_ID,
         LAST_UPDATE_DATE      = P_DML_RECORD.SYSDATE,
         LAST_UPDATED_BY       = P_DML_RECORD.USER_ID,
         OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
--         CREATED_BY_MODULE     = NVL(CREATED_BY_MODULE, decode(l_created_by_module(j),P_DML_RECORD.GMISS_CHAR, CREATED_BY_MODULE, null, CREATED_BY_MODULE,l_created_by_module(j))),
         -- do not update application_id if old value exists
         APPLICATION_ID        = NVL(APPLICATION_ID, P_DML_RECORD.APPLICATION_ID)
   where FINANCIAL_NUMBER_ID = l_fn_id(j)
     --and l_fin_num_name_err(j) is not null
     and l_action_error_flag(j) is not null
     and l_error_flag(j) is null;

     report_errors(P_DML_RECORD, l_dml_exception);

     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FN:process_update_finnumbers()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
        ----dbms_output.put_line('Update finnumbers other exception: ' || SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Update finnumbers other exception: ' || SQLERRM);

        ROLLBACK to process_update_finnumbers_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

   END process_update_finnumbers;


   PROCEDURE report_errors(
     P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DML_EXCEPTION             IN            VARCHAR2
   ) IS

   num_exp NUMBER;
   exp_ind NUMBER := 1;
   l_debug_prefix		       VARCHAR2(30) := '';
   BEGIN
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FN:report_errors()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

     /**********************************/
     /* Validation and Error reporting */
     /**********************************/
     IF l_fn_id.count = 0 THEN
       return;
     END IF;

     l_num_row_processed := null;
     l_num_row_processed := NUMBER_COLUMN();
     l_num_row_processed.extend(l_fr_id.count);
     l_exception_exists := null;
     l_exception_exists := FLAG_ERROR();
     l_exception_exists.extend(l_fr_id.count);
     num_exp := SQL%BULK_EXCEPTIONS.COUNT;

     FOR k IN 1..l_fn_id.count LOOP
       IF SQL%BULK_ROWCOUNT(k) = 0
       THEN
	 IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'DML fails at ' || k,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
         END IF;
         l_num_row_processed(k) := 0;

         /* Check for any exceptions during DML               */
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
       e1_flag,
       e2_flag,
       OTHER_EXCEP_FLAG,
       MISSING_PARENT_FLAG
     )
     (
      select P_DML_RECORD.REQUEST_ID,
             P_DML_RECORD.BATCH_ID,
             l_row_id(j),
             'HZ_IMP_FINNUMBERS_INT',
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
             'Y', --l_fin_num_name_err(j),
             'Y',
             l_exception_exists(j), 'Y'
        from dual
       where l_num_row_processed(j) = 0
     );

     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'FN:report_errors()-',
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


END HZ_IMP_LOAD_FINNUMBERS_PKG;

/
