--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_PARTY_SITE_USE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_PARTY_SITE_USE_PKG" AS
/*$Header: ARHLPSUB.pls 120.16.12010000.2 2008/10/17 12:31:21 idali ship $*/

  l_action_mismatch_errors	FLAG_ERROR;
  l_error_flag			NUMBER_COLUMN;
  l_site_use_type_error  	LOOKUP_ERROR;
  l_owner_table_error		FLAG_ERROR;
  l_site_use_constr_error	FLAG_ERROR;

  l_row_id 			ROWID;
  l_batch_id 	 	   	batch_id;
  l_site_orig_system 	 	SITE_ORIG_SYSTEM;
  l_site_orig_system_reference 	SITE_ORIG_SYSTEM_REFERENCE;
  l_site_use_type		SITE_USE_TYPE;
  l_insert_update_flag 	 	INSERT_UPDATE_FLAG;
  l_interface_status 	 	INTERFACE_STATUS;
  l_action_flag 	 	ACTION_FLAG;
  l_error_id 	 		ERROR_ID;
  l_party_site_id		PARTY_SITE_ID;
  l_party_site_use_id		PARTY_SITE_USE_ID;
  l_created_by_module 	   	CREATED_BY_MODULE;

  l_errm 			VARCHAR2(100);
  l_num_row_processed 		NUMBER_COLUMN;
  l_user_id 			NUMBER;
  l_last_update_login 	   	NUMBER;
  l_program_id 			NUMBER;
  l_program_application_id 	NUMBER;
  l_request_id 			NUMBER;
  l_program_update_date 	DATE;
  l_no_end_date 		DATE;
  l_rerun_flag 			varchar2(1);
  l_primary_flag            	FLAG_ERROR;

  g_debug_count   		NUMBER := 0;
  --g_debug        		BOOLEAN := FALSE;
  l_createdby_errors            LOOKUP_ERROR;


PROCEDURE populate_error_table(
     P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DUP_VAL_EXP               IN     VARCHAR2,
     P_SQL_ERRM                  IN     VARCHAR2  ) IS

     dup_val_exp_val             VARCHAR2(1) := null;
     other_exp_val               VARCHAR2(1) := 'Y';
     l_debug_prefix		 VARCHAR2(30) := '';
BEGIN

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PSU:populate_error_table()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;
      IF(P_DUP_VAL_EXP = 'Y') then
       other_exp_val := null;
       IF(instr(P_SQL_ERRM, '_U1')<>0) THEN
	  IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'PSU: HZ_PARTY_SITE_USES_U1 violated',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
          END IF;
         dup_val_exp_val := 'A';
      /* ELSE -- '_U2'
          IF g_debug THEN
          hz_utility_v2pub.debug('PSU: violated');
          END IF;
         dup_val_exp_val := 'B';  */
       END IF;
      END IF;

   --dbms_output.put_line('dup_val_exp_val:' || dup_val_exp_val);

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
       ACTION_MISMATCH_FLAG,
       MISSING_PARENT_FLAG,
       DUP_VAL_IDX_EXCEP_FLAG,
       OTHER_EXCEP_FLAG
     )
     (
       select P_DML_RECORD.REQUEST_ID,
              P_DML_RECORD.BATCH_ID,
              p_sg.int_row_id,
              'HZ_IMP_ADDRESSUSES_INT',
              HZ_IMP_ERRORS_S.NextVal,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.LAST_UPDATE_LOGIN,
              P_DML_RECORD.PROGRAM_APPLICATION_ID,
              P_DML_RECORD.PROGRAM_ID,
              P_DML_RECORD.SYSDATE,
              'Y','Y','Y','Y','Y', 'Y',
              dup_val_exp_val,
              other_exp_val
         from hz_imp_addressuses_int int,hz_imp_addressuses_sg p_sg
        where int.rowid = p_sg.int_row_id
          and p_sg.action_flag = 'I'
          and p_sg.batch_id = P_DML_RECORD.BATCH_ID
          and int.party_orig_system = P_DML_RECORD.OS
          and int.party_orig_system_reference
              between P_DML_RECORD.FROM_OSR and P_DML_RECORD.TO_OSR
     );
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PSU:populate_error_table()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
END populate_error_table;

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
 END enable_debug;
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

/********************************************************************************
 *
 *	process_insert_partysiteuses
 *
 ********************************************************************************/

PROCEDURE process_insert_partysiteuses (
   P_DML_RECORD	 	 IN  	HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

  c_handle_insert 	RefCurType;

  l_insert_sql varchar2(16000) :=
  '
  insert all
  when (action_mismatch_error is not null
   and site_use_type_error is not null
   and site_use_constr_error is not null
    and owner_table_error is not null
    and createdby_error is not null
   and addruse_osr_mismatch_err is not null  ) then
  into hz_party_site_uses (
       application_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_application_id,
       program_id,
       program_update_date,
       request_id,
       party_site_use_id,
       party_site_id,
       site_use_type,
       status,
       object_version_number,
       created_by_module,
       primary_per_type)
  values (
       :application_id,
       :user_id,
       :l_sysdate,
       :user_id,
       :l_sysdate,
       :last_update_login,
       :program_application_id,
       :program_id,
       :l_sysdate,
       :request_id,
       party_site_use_id,
       party_site_id,
       site_use_type,
       ''A'',
        1,
       nvl(nullif(created_by_module, :p_gmiss_char), ''HZ_IMPORT''),
       nvl(primary_flag, ''N''))
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
       e1_flag,
       e2_flag,
       e3_flag,
       e4_flag,
       ACTION_MISMATCH_FLAG,
       MISSING_PARENT_FLAG)
  values (
       :user_id,
       :l_sysdate,
       :user_id,
       :l_sysdate,
       :last_update_login,
       :program_application_id,
       :program_id,
       :l_sysdate,
       HZ_IMP_ERRORS_S.nextval,
       :p_batch_id,
       :request_id,
       row_id,
       ''HZ_IMP_ADDRESSUSES_INT'',
       site_use_type_error,
       site_use_constr_error,
       addruse_osr_mismatch_err,
       createdby_error,
       action_mismatch_error,
       owner_table_error)
  select /*+ leading(pss) use_nl(mosr,mosr_party,site_use_type_l)*/
       psi.rowid row_id,
       psi.site_use_type,
       nvl(nullif(psi.created_by_module,:p_gmiss_char),''HZ_IMPORT'') created_by_module,
       pss.party_site_id,
       pss.party_site_use_id,
       nvl2(nullif(psi.site_use_type, :p_gmiss_char), nvl2(site_use_type_l.lookup_code, ''Y'', null),null) site_use_type_error,
       --nvl2(psu.party_site_use_id, null, ''Y'') site_use_constr_error,
       nvl2(nullif(psi.site_use_type,psu.site_use_type),''Y'',null) site_use_constr_error,
        nvl2(nullif(nullif(psi.insert_update_flag, :p_gmiss_char), pss.action_flag), null, ''Y'') action_mismatch_error,
       nvl2(mosr.owner_table_id,''Y'',null) owner_table_error,
       nvl2(nullif(mosr.party_id,mosr_party.owner_table_id),null,''Y'')addruse_osr_mismatch_err,
       pss.primary_flag,
       nvl2(nullif(psi.created_by_module,:p_gmiss_char),nvl2(createdby_l.lookup_code,''Y'',null),''Y'') createdby_error

  from hz_imp_addressuses_int psi,
       hz_imp_addressuses_sg pss,
       fnd_lookup_values site_use_type_l,
       hz_orig_sys_references mosr,
       hz_orig_sys_references mosr_party,
       hz_party_site_uses psu,
       fnd_lookup_values createdby_l
 where psi.rowid = pss.int_row_id
   and mosr.orig_system (+) = psi.site_orig_system
   and mosr.orig_system_reference (+) = psi.site_orig_system_reference
   and mosr.status (+) = ''A''
   and mosr.owner_table_name (+) = ''HZ_PARTY_SITES''
   and mosr_party.orig_system (+) = psi.party_orig_system
   and mosr_party.orig_system_reference (+) = psi.party_orig_system_reference
   and mosr_party.status (+) = ''A''
   and mosr_party.owner_table_name (+) = ''HZ_PARTIES''
   and site_use_type_l.lookup_code (+) = psi.site_use_type
   and site_use_type_l.lookup_type (+) = ''PARTY_SITE_USE_CODE''
   and site_use_type_l.language (+) = userenv(''LANG'')
   and site_use_type_l.view_application_id (+) = 222
   and site_use_type_l.security_group_id (+) =
           fnd_global.lookup_security_group(''PARTY_SITE_USE_CODE'', 222)
   and createdby_l.lookup_code (+) = psi.created_by_module
   and createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
   and createdby_l.language (+) = userenv(''LANG'')
   and createdby_l.view_application_id (+) = 222
   and createdby_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
   and psu.party_site_id (+) = pss.party_site_id
   and psu.site_use_type (+) = pss.site_use_type
   and psu.status (+) = ''A''
   and pss.action_flag = ''I''
   and pss.batch_id = :p_batch_id
   and pss.party_orig_system = :p_wu_os
   and pss.party_orig_system_reference between :p_from_osr and :p_to_osr
   and pss.batch_mode_flag = :p_batch_mode_flag ';

  l_where_first_run_sql varchar2(35) := ' AND psi.interface_status is null';
  l_where_rerun_sql varchar2(35) := ' AND psi.interface_status = ''C''';
  l_where_enabled_lookup_sql varchar2(1000) :=
	' AND  ( site_use_type_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(SYSDATE) BETWEEN
	  TRUNC(NVL( site_use_type_l.START_DATE_ACTIVE,SYSDATE ) ) AND
	  TRUNC(NVL( site_use_type_l.END_DATE_ACTIVE,SYSDATE ) ) )
 AND  ( createdby_l.ENABLED_FLAG(+) = ''Y'' AND
          TRUNC(SYSDATE) BETWEEN
          TRUNC(NVL( createdby_l.START_DATE_ACTIVE,SYSDATE ) ) AND
          TRUNC(NVL( createdby_l.END_DATE_ACTIVE,SYSDATE ) ) )';

  l_final_sql		VARCHAR2(15000);
  l_dml_exception varchar2(1) := 'N';
  l_debug_prefix       VARCHAR2(30) := '';
BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PSU:process_insert_partysiteuses+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'PSU:RERUN:' || P_DML_RECORD.RERUN,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'PSU:ALLOW_DISABLED_LOOKUP:' || P_DML_RECORD.ALLOW_DISABLED_LOOKUP,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
  END IF;

  savepoint process_insert_psu_pvt;

  FND_MSG_PUB.initialize;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF P_DML_RECORD.ALLOW_DISABLED_LOOKUP = 'Y' THEN
    IF P_DML_RECORD.RERUN = 'N' THEN
      l_final_sql := l_insert_sql || l_where_first_run_sql;
    ELSE
      l_final_sql := l_insert_sql || l_where_rerun_sql;
    END IF;
  ELSE
    IF P_DML_RECORD.RERUN = 'N' THEN
	  l_final_sql := l_insert_sql || l_where_first_run_sql || l_where_enabled_lookup_sql;
    ELSE
      l_final_sql := l_insert_sql || l_where_rerun_sql || l_where_enabled_lookup_sql;
    END IF;
  END IF;

  EXECUTE IMMEDIATE  l_final_sql using
   	P_DML_RECORD.APPLICATION_ID,
	P_DML_RECORD.USER_ID,
	P_DML_RECORD.SYSDATE,
	P_DML_RECORD.USER_ID,
	P_DML_RECORD.SYSDATE,
	P_DML_RECORD.LAST_UPDATE_LOGIN,
	P_DML_RECORD.PROGRAM_APPLICATION_ID,
	P_DML_RECORD.PROGRAM_ID,
	P_DML_RECORD.SYSDATE,

	P_DML_RECORD.REQUEST_ID,
	P_DML_RECORD.GMISS_CHAR,

	P_DML_RECORD.USER_ID,
	P_DML_RECORD.SYSDATE,
	P_DML_RECORD.USER_ID,
	P_DML_RECORD.SYSDATE,
	P_DML_RECORD.LAST_UPDATE_LOGIN,
	P_DML_RECORD.PROGRAM_APPLICATION_ID,
	P_DML_RECORD.PROGRAM_ID,
	P_DML_RECORD.SYSDATE,

	P_DML_RECORD.BATCH_ID,
	P_DML_RECORD.REQUEST_ID,
	P_DML_RECORD.GMISS_CHAR,
	P_DML_RECORD.GMISS_CHAR,
	P_DML_RECORD.GMISS_CHAR,
	P_DML_RECORD.GMISS_CHAR,
	P_DML_RECORD.BATCH_ID,
	P_DML_RECORD.OS,
	P_DML_RECORD.FROM_OSR,
	P_DML_RECORD.TO_OSR,
	P_DML_RECORD.BATCH_MODE_FLAG;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PSU:process_insert_partysiteuses-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert partysiteuses dup val exception: ' || SQLERRM);
        ROLLBACK to process_insert_psu_pvt;
        populate_error_table(P_DML_RECORD, 'Y', SQLERRM);
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN OTHERS THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert partysiteuses other exception: ' || SQLERRM);
       ROLLBACK TO process_insert_psu_pvt;
       populate_error_table(P_DML_RECORD, 'N', SQLERRM);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
       FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
       FND_MSG_PUB.ADD;
       FND_MSG_PUB.Count_And_Get(
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data);

END process_insert_partysiteuses;


/********************************************************************************
 *
 *	load_partysiteuses
 *
 ********************************************************************************/

PROCEDURE load_partysiteuses (
   P_DML_RECORD  	       	   IN  HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS
l_debug_prefix		 VARCHAR2(30) := '';
BEGIN

  savepoint load_partysiteuses_pvt;

  -- Check if API is called in debug mode. If yes, enable debug.
  --enable_debug;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PSU:load_partysiteuses()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  FND_MSG_PUB.initialize;

   --Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   process_insert_partysiteuses
    (
     P_DML_RECORD  	 	 => P_DML_RECORD
     ,x_return_status    => x_return_status
     ,x_msg_count        => x_msg_count
     ,x_msg_data         => x_msg_data
     );

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'PSU:load_partysiteuses()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
   -- if enabled, disable debug
   --disable_debug;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO load_partysiteuses_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO load_partysiteuses_pvt;
     FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading partysiteuses');
     FND_FILE.put_line(fnd_file.log, l_errm);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,l_errm);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'PSU:load_partysiteuses Exception:',
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>SQLERRM,
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;

     ROLLBACK TO load_partysiteuses_pvt;
     FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading partysiteuses');
     FND_FILE.put_line(fnd_file.log, l_errm);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END load_partysiteuses;

END HZ_IMP_LOAD_PARTY_SITE_USE_PKG;

/
