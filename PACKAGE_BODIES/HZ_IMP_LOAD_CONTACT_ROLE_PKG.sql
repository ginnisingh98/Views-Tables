--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_CONTACT_ROLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_CONTACT_ROLE_PKG" AS
/*$Header: ARHLOCRB.pls 120.13 2005/12/06 13:56:34 vravicha noship $*/

  l_action_mismatch_errors	FLAG_ERROR;
  l_error_flag			NUMBER_COLUMN;
  l_role_type_error 		LOOKUP_ERROR;
  l_owner_table_error		FLAG_ERROR;

  l_row_id 			ROWID;
  l_batch_id 	 		BATCH_ID;
  l_cp_orig_system 		CONT_ORIG_SYSTEM;
  l_cp_orig_system_reference 	CONT_ORIG_SYSTEM_REFERENCE;
  l_controle_orig_system 	CONT_ORIG_SYSTEM;
  l_controle_orig_system_ref	CONT_ORIG_SYSTEM_REFERENCE;
  l_insert_update_flag 	 	INSERT_UPDATE_FLAG;
  l_interface_status 	 	INTERFACE_STATUS;
  l_action_flag 		ACTION_FLAG;
  l_error_id 	 		ERROR_ID;
  l_org_contact_id		ORG_CONTACT_ID;
  l_org_contact_role_id		ORG_CONTACT_ROLE_ID;
  l_created_by_module 	 	CREATED_BY_MODULE;
  l_role_type			ROLE_TYPE;
  l_rerun_flag 			varchar2(1);
  l_errm 			varchar2(100);

  l_num_row_processed 		NUMBER_COLUMN;

  l_user_id 			NUMBER;
  l_user_name 			varchar2(100);

  l_last_update_login  		NUMBER;
  l_program_id 			NUMBER;
  l_program_application_id 	NUMBER;
  l_request_id 			NUMBER;
  l_program_update_date 	DATE;
  l_no_end_date 		DATE;
  g_debug_count   		NUMBER := 0;
  g_debug         		BOOLEAN := FALSE;

  l_createdby_errors            LOOKUP_ERROR;

PROCEDURE populate_error_table(
     P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DUP_VAL_EXP               IN     VARCHAR2,
     P_SQL_ERRM                  IN     VARCHAR2  ) IS

     dup_val_exp_val             VARCHAR2(1) := null;
     other_exp_val               VARCHAR2(1) := 'Y';
     l_debug_prefix		       VARCHAR2(30) := '';
BEGIN

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ROLE: populate_error_table()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;
      IF(P_DUP_VAL_EXP = 'Y') then
       other_exp_val := null;
       IF(instr(P_SQL_ERRM, '_U1')<>0) THEN
	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'ROLE: HZ_ORG_CONTACT_ROLES_U1 violated',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

         dup_val_exp_val := 'A';
       ELSE -- '_U2'
	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'ROLE: HZ_ORG_CONTACT_ROLES_U2 violated',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

         dup_val_exp_val := 'B';
       END IF;
      END IF;

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
       ACTION_MISMATCH_FLAG,
       MISSING_PARENT_FLAG,
       DUP_VAL_IDX_EXCEP_FLAG,
       OTHER_EXCEP_FLAG
     )
     (
       select P_DML_RECORD.REQUEST_ID,
              P_DML_RECORD.BATCH_ID,
              p_sg.int_row_id,
              'HZ_IMP_CONTACTROLES_INT',
              HZ_IMP_ERRORS_S.NextVal,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.LAST_UPDATE_LOGIN,
              P_DML_RECORD.PROGRAM_APPLICATION_ID,
              P_DML_RECORD.PROGRAM_ID,
              P_DML_RECORD.SYSDATE,
              'Y',
              'Y',
              'Y',
              'Y',
              'Y',
              dup_val_exp_val,
              other_exp_val
         from hz_imp_contactroles_int int,hz_imp_contactroles_sg p_sg
        where int.rowid = p_sg.int_row_id
          and p_sg.action_flag = 'I'
          and p_sg.batch_id = P_DML_RECORD.BATCH_ID
          and int.sub_orig_system = P_DML_RECORD.OS
          and int.sub_orig_system_reference
              between P_DML_RECORD.FROM_OSR and P_DML_RECORD.TO_OSR
     );
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ROLE:populate_error_table()-',
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
 *	process_insert_contactroles
 *
 ********************************************************************************/

PROCEDURE process_insert_contactroles (
  P_DML_RECORD	 	 IN  	HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

  c_handle_insert RefCurType;

  l_insert_sql varchar2(15000) :=
  '
  insert all
  when (action_mismatch_error is not null
   and role_type_error is not null
   and owner_table_error is not null
   and createdby_error is not null
   and controle_osr_mismatch_err is not null ) then
  into hz_org_contact_roles (
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
       org_contact_role_id,
       org_contact_id,
       role_type,
       role_level,
       primary_flag,
       object_version_number,
       created_by_module,
       status)
  values(
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
       contact_role_id,
       contact_id,
       role_type,
       ''N'',
       ''N'',
       1,
       nvl(nullif(created_by_module, :p_gmiss_char), ''HZ_IMPORT''),
       ''A'')
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
       ''HZ_IMP_CONTACTROLES_INT'',
       role_type_error,
       controle_osr_mismatch_err,
       createdby_error,
       action_mismatch_error,
       owner_table_error)
  select /*+ leading(crs) use_nl(role_type_l) */
		cri.rowid row_id,
       -- cri.contact_orig_system,
       -- cri.contact_orig_system_reference,
       -- cri.sub_orig_system,
       -- cri.sub_orig_system_reference,
       -- cri.insert_update_flag,
       cri.role_type,
       -- cri.interface_status,
       -- crs.action_flag,
       nvl(nullif(cri.created_by_module,:p_gmiss_char),''HZ_IMPORT'') created_by_module,
       crs.contact_id,
       crs.contact_role_id,
       nvl2(nullif(cri.role_type, :p_gmiss_char), nvl2(role_type_l.lookup_code, ''Y'', null), null) role_type_error,
       nvl2(nullif(nullif(insert_update_flag, :p_gmiss_char), action_flag), null, ''Y'') action_mismatch_error,
       nvl2(mosr.owner_table_id,''Y'',null) owner_table_error ,
       --nvl2(nullif(mosr.party_id,mosr_party.owner_table_id),null,''Y'') controle_osr_mismatch_err
       nvl2(nullif(mosr.orig_system_reference,cri.contact_orig_system_reference),null,''Y'') controle_osr_mismatch_err,
       nvl2(nullif(cri.created_by_module,:p_gmiss_char),createdby_l.lookup_code,''Y'') createdby_error

  from hz_imp_contactroles_int cri,
       hz_imp_contactroles_sg crs,
       hz_orig_sys_references mosr,
       --hz_orig_sys_references mosr_party,
       hz_org_contacts org_cont,
       --hz_relationships rel,
       fnd_lookup_values role_type_l,
       fnd_lookup_values createdby_l
  where cri.rowid = crs.int_row_id
   and org_cont.org_contact_id = crs.contact_id
   and mosr.orig_system (+) = cri.contact_orig_system
   and mosr.orig_system_reference (+) = cri.contact_orig_system_reference
   and mosr.status (+) = ''A''
   and mosr.owner_table_name (+) = ''HZ_ORG_CONTACTS''
   --and mosr.party_id = rel.party_id
   --and rel.subject_table_name = ''HZ_PARTIES''
   --and rel.directional_flag = ''F''
   --and rel.subject_id = mosr_party.owner_table_id
   --and mosr_party.orig_system (+) = cri.sub_orig_system
   --and mosr_party.orig_system_reference (+) = cri.sub_orig_system_reference
   --and mosr_party.status (+) = ''A''
   --and mosr_party.owner_table_name (+) = ''HZ_PARTIES''
   and role_type_l.lookup_code (+) = cri.role_type
   and role_type_l.lookup_type (+) = ''CONTACT_ROLE_TYPE''
   and role_type_l.language (+) = userenv(''LANG'')
   and role_type_l.view_application_id (+) = 222
   and role_type_l.security_group_id (+) =
           fnd_global.lookup_security_group(''CONTACT_ROLE_TYPE'', 222)
   and createdby_l.lookup_code (+) = cri.created_by_module
   and createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
   and createdby_l.language (+) = userenv(''LANG'')
   and createdby_l.view_application_id (+) = 222
   and createdby_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
   and crs.action_flag = ''I''
   and crs.batch_id = :p_batch_id
   and crs.sub_orig_system = :p_wu_os
   and crs.sub_orig_system_reference between :p_from_osr and :p_to_osr
   and crs.batch_mode_flag = :p_batch_mode_flag ';

  l_where_first_run_sql varchar2(35) := ' AND cri.interface_status is null';
  l_where_rerun_sql varchar2(35) := ' AND cri.interface_status = ''C''';
  l_where_enabled_lookup_sql varchar2(1000) :=
	' AND  ( role_type_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(SYSDATE) BETWEEN
	  TRUNC(NVL( role_type_l.START_DATE_ACTIVE,SYSDATE ) ) AND
	  TRUNC(NVL( role_type_l.END_DATE_ACTIVE,SYSDATE ) ) )
 AND  ( createdby_l.ENABLED_FLAG(+) = ''Y'' AND
          TRUNC(SYSDATE) BETWEEN
          TRUNC(NVL( createdby_l.START_DATE_ACTIVE,SYSDATE ) ) AND
          TRUNC(NVL( createdby_l.END_DATE_ACTIVE,SYSDATE ) ) )';

  l_final_sql		VARCHAR2(15000);
  l_dml_exception 	varchar2(1) := 'N';
  l_debug_prefix	VARCHAR2(30) := '';

BEGIN

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ROLE:process_insert_contactroles+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'ROLE:RERUN:' || P_DML_RECORD.RERUN,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
		 hz_utility_v2pub.debug(p_message=>'ROLE:ALLOW_DISABLED_LOOKUP:' || P_DML_RECORD.ALLOW_DISABLED_LOOKUP,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
  END IF;

  savepoint load_contactroles_pvt;

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
	hz_utility_v2pub.debug(p_message=>'ROLE:process_insert_contactroles-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert contactroles dup val exception: ' || SQLERRM);
        ROLLBACK to load_contactroles_pvt;
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
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert contactroles other exception: ' || SQLERRM);
       ROLLBACK TO load_contactroles_pvt;
       populate_error_table(P_DML_RECORD, 'N', SQLERRM);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
       FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
       FND_MSG_PUB.ADD;
       FND_MSG_PUB.Count_And_Get(
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data);

END process_insert_contactroles;

/********************************************************************************
 *
 *	load_contactroles
 *
 ********************************************************************************/

PROCEDURE load_contactroles (
  P_DML_RECORD  	       	   IN  HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS
l_debug_prefix	VARCHAR2(30) := '';
BEGIN

  savepoint load_contactroles_pvt;

  -- Check if API is called in debug mode. If yes, enable debug.
  --enable_debug;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ROLE:process_insert_contactroles+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  FND_MSG_PUB.initialize;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  process_insert_contactroles
    (
     P_DML_RECORD  	 	 => P_DML_RECORD
     ,x_return_status    => x_return_status
     ,x_msg_count        => x_msg_count
     ,x_msg_data         => x_msg_data
    );

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ROLE:load_contactroles-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
  -- if enabled, disable debug
  --disable_debug;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO load_contactroles_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO load_contactroles_pvt;
     FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading contactroles');
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
     ROLLBACK TO load_contactroles_pvt;
     FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading contactroles');
     FND_FILE.put_line(fnd_file.log, l_errm);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END load_contactroles;

END HZ_IMP_LOAD_CONTACT_ROLE_PKG;

/
