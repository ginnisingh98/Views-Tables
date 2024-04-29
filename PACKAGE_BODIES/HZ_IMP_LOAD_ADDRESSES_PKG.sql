--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_ADDRESSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_ADDRESSES_PKG" AS
/*$Header: ARHLADDB.pls 120.47 2007/10/17 09:40:48 idali ship $*/


  /* Commented the code for bug 4079902. */

  -- bug fix 3851810
  /*
  g_pst_mixnmatch_enabled             VARCHAR2(1);
  g_pst_selected_datasources          VARCHAR2(255);
  g_pst_is_datasource_selected        VARCHAR2(1) := 'N';
  g_pst_entity_attr_id                NUMBER;
  */
  g_debug_count                NUMBER := 0;
  --g_debug                      BOOLEAN := FALSE;

  c_end_date                   DATE := to_date('4712.12.31 00:01','YYYY.MM.DD HH24:MI');

  l_owner_table_id             OWNER_TABLE_ID;
  l_site_orig_system           SITE_ORIG_SYSTEM;
  l_site_orig_system_reference SITE_ORIG_SYSTEM_REFERENCE;
  l_old_site_osr               SITE_ORIG_SYSTEM_REFERENCE;
  l_site_id                    SITE_ID;
  l_new_site_id                SITE_ID;
  l_party_id                   PARTY_ID;
  l_site_name                  SITE_NAME;
  l_party_site_number          PARTY_SITE_NUMBER;
  l_error_party_id             PARTY_ID;
  l_error_site_id              SITE_ID;
  l_update_party_id            PARTY_ID;
  l_update_site_id             SITE_ID;
  l_val_status_code            VALIDATION_STATUS_CODE;
  l_old_profile_sst_flag       PROFILE_SST_FLAG;

  l_attr_category   ATTRIBUTE_CATEGORY;
  l_attr1           ATTRIBUTE;
  l_attr2           ATTRIBUTE;
  l_attr3           ATTRIBUTE;
  l_attr4           ATTRIBUTE;
  l_attr5           ATTRIBUTE;
  l_attr6           ATTRIBUTE;
  l_attr7           ATTRIBUTE;
  l_attr8           ATTRIBUTE;
  l_attr9           ATTRIBUTE;
  l_attr10          ATTRIBUTE;
  l_attr11          ATTRIBUTE;
  l_attr12          ATTRIBUTE;
  l_attr13          ATTRIBUTE;
  l_attr14          ATTRIBUTE;
  l_attr15          ATTRIBUTE;
  l_attr16          ATTRIBUTE;
  l_attr17          ATTRIBUTE;
  l_attr18          ATTRIBUTE;
  l_attr19          ATTRIBUTE;
  l_attr20          ATTRIBUTE;

  l_old_attr_category   ATTRIBUTE_CATEGORY;
  l_old_attr1           ATTRIBUTE;
  l_old_attr2           ATTRIBUTE;
  l_old_attr3           ATTRIBUTE;
  l_old_attr4           ATTRIBUTE;
  l_old_attr5           ATTRIBUTE;
  l_old_attr6           ATTRIBUTE;
  l_old_attr7           ATTRIBUTE;
  l_old_attr8           ATTRIBUTE;
  l_old_attr9           ATTRIBUTE;
  l_old_attr10          ATTRIBUTE;
  l_old_attr11          ATTRIBUTE;
  l_old_attr12          ATTRIBUTE;
  l_old_attr13          ATTRIBUTE;
  l_old_attr14          ATTRIBUTE;
  l_old_attr15          ATTRIBUTE;
  l_old_attr16          ATTRIBUTE;
  l_old_attr17          ATTRIBUTE;
  l_old_attr18          ATTRIBUTE;
  l_old_attr19          ATTRIBUTE;
  l_old_attr20          ATTRIBUTE;

  l_country         COUNTRY;
  l_addr1           ADDRESS;
  l_addr2           ADDRESS;
  l_addr3           ADDRESS;
  l_addr4           ADDRESS;
  l_city            CITY;
  l_postal_code     POSTAL_CODE;
  l_state           STATE;
  l_province        PROVINCE;
  l_county          COUNTY;

  l_old_country     COUNTRY;
  l_old_addr1       ADDRESS;
  l_old_addr2       ADDRESS;
  l_old_addr3       ADDRESS;
  l_old_addr4       ADDRESS;
  l_old_city        CITY;
  l_old_postal_code POSTAL_CODE;
  l_old_state       STATE;
  l_old_province    PROVINCE;
  l_old_county      COUNTY;

  l_action_flag     ACTION_FLAG;
  l_country_std     COUNTRY;
  l_addr1_std       ADDRESS;
  l_addr2_std       ADDRESS;
  l_addr3_std       ADDRESS;
  l_addr4_std       ADDRESS;
  l_city_std        CITY;
  l_postal_code_std POSTAL_CODE;
  l_ps_admin_int    STATE;
  l_ps_admin_std    STATE;
  l_county_std      COUNTY;

  l_old_timezone    TIMEZONE;
  l_timezone        TIMEZONE;
  l_timezone_code   TIMEZONE_CODE;

  l_addr_phonetic   ADDRESS_LINES_PHONETIC;
  l_postal_plus4    POSTAL_PLUS4_CODE;
  l_loc_dir         LOCATION_DIRECTIONS;
  l_clli_code       CLLI_CODE;
  l_language        LANGUAGE;
  l_short_desc      SHORT_DESCRIPTION;
  l_desc            DESCRIPTION;
  l_delvy_pt_code   DELIVERY_POINT_CODE;
  l_last_updated_by LAST_UPDATED_BY;
  l_sales_tax_code  SALES_TAX_GEOCODE;
  l_sales_tax_limit SALES_TAX_LIMITS;

  l_old_addr_phonetic   ADDRESS_LINES_PHONETIC;
  l_old_postal_plus4    POSTAL_PLUS4_CODE;
  l_old_loc_dir         LOCATION_DIRECTIONS;
  l_old_clli_code       CLLI_CODE;
  l_old_language        LANGUAGE;
  l_old_short_desc      SHORT_DESCRIPTION;
  l_old_desc            DESCRIPTION;
  l_old_delvy_pt_code   DELIVERY_POINT_CODE;
  l_old_sales_tax_code  SALES_TAX_GEOCODE;
  l_old_sales_tax_limit SALES_TAX_LIMITS;

 -- l_fa_loc_id       FA_LOCATION_ID;
  l_created_by_module       CREATED_BY_MODULE;
  --l_location_profile_id     LOCATION_PROFILE_ID;
  l_location_id             LOCATION_ID;
  l_new_loc_id              LOCATION_ID;
  l_accept_std_flag         ACCEPT_STANDARDIZED_FLAG;
  l_adptr_content_src       ADAPTER_CONTENT_SRC;
  l_corr_mv_ind             CORRECT_MOVE_INDICATOR;
  l_ident_addr_flag         IDENT_ADDR_FLAG;

  l_valid_status_code       VALID_STATUS_CODE;
  l_old_valid_status_code   VALID_STATUS_CODE;
  l_date_validated          DATE_VALIDATED;

  l_application_id          APPLICATION_ID;
  l_action_error_flag       FLAG_ERROR;
  l_error_flag              FLAG_ERROR;
  l_address_err             LOOKUP_ERROR;
  l_country_err             LOOKUP_ERROR;
  l_lang_err                LOOKUP_ERROR;
  l_timezone_err            LOOKUP_ERROR;
  l_flex_val_errors	        NUMBER_COLUMN;
  l_dss_security_errors     FLAG_ERROR;
  l_addr_ch_flag            FLAG_ERROR;
  l_tax_ch_flag             FLAG_ERROR;
  l_move_count              NUMBER_COLUMN; -- number of moved records
  l_corr_count              NUMBER_COLUMN; -- number of corrected records
  l_init_upd_count          NUMBER_COLUMN; -- total number of corrected/updated records
  l_corr_upd_count          NUMBER_COLUMN; -- total number of corrected/updated records
  l_temp_upd_count          NUMBER_COLUMN; -- number of temp update records
  l_NEW_OSR_EXISTS          FLAG_ERROR;
  l_primary_flag            FLAG_ERROR;

  l_createdby_errors        LOOKUP_ERROR;

  l_exception_exists        FLAG_ERROR;
  l_num_row_processed       NUMBER_COLUMN;
  l_row_id                  ROWID;
  l_errm                    VARCHAR2(100);

  l_allow_correction VARCHAR2(1);
  l_maintain_loc_hist VARCHAR2(1);
  l_allow_std_update VARCHAR2(1);

  l_third_party_update_error FLAG_ERROR; /* bug 4079902 */

  TYPE OWNING_PARTY_ID_LIST IS TABLE OF HZ_PARTIES.PARTY_ID%TYPE;
  l_owning_party_id OWNING_PARTY_ID_LIST;

  --------------------------------------
  -- forward declaration of private procedures and functions
  --------------------------------------

  /*PROCEDURE enable_debug;
  PROCEDURE disable_debug;
  */

  PROCEDURE open_update_cursor (update_cursor     IN OUT NOCOPY update_cursor_type,
                                P_DML_RECORD      IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  );

  PROCEDURE process_insert_addresses (
    P_DML_RECORD      IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  PROCEDURE populate_error_table(
     P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DUP_VAL_EXP               IN     VARCHAR2,
     P_SQL_ERRM                  IN     VARCHAR2  );

  PROCEDURE process_update_addresses (
    P_DML_RECORD      IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  PROCEDURE report_errors(
     P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DML_EXCEPTION             IN            VARCHAR2);

  PROCEDURE sync_party_tax_profile
  ( P_BATCH_ID                      IN NUMBER,
    P_REQUEST_ID                    IN NUMBER,
    P_ORIG_SYSTEM                   IN VARCHAR2,
    P_FROM_OSR                      IN VARCHAR2,
    P_TO_OSR                        IN VARCHAR2,
    P_BATCH_MODE_FLAG               IN VARCHAR2,
    P_PROGRAM_ID                    IN NUMBER
  );

FUNCTION validate_desc_flexfield_f(
  p_attr_category  IN VARCHAR2,
  p_attr1          IN VARCHAR2,
  p_attr2          IN VARCHAR2,
  p_attr3          IN VARCHAR2,
  p_attr4          IN VARCHAR2,
  p_attr5          IN VARCHAR2,
  p_attr6          IN VARCHAR2,
  p_attr7          IN VARCHAR2,
  p_attr8          IN VARCHAR2,
  p_attr9          IN VARCHAR2,
  p_attr10         IN VARCHAR2,
  p_attr11         IN VARCHAR2,
  p_attr12         IN VARCHAR2,
  p_attr13         IN VARCHAR2,
  p_attr14         IN VARCHAR2,
  p_attr15         IN VARCHAR2,
  p_attr16         IN VARCHAR2,
  p_attr17         IN VARCHAR2,
  p_attr18         IN VARCHAR2,
  p_attr19         IN VARCHAR2,
  p_attr20         IN VARCHAR2,
  p_validation_date IN DATE,
  p_gmiss_char     IN VARCHAR2
) RETURN VARCHAR2 IS
l_debug_prefix		       VARCHAR2(30) := '';
BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:validate_desc_flexfield_f()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  FND_FLEX_DESCVAL.set_context_value(nullif(p_attr_category, p_gmiss_char));

  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE1', nullif(p_attr1, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE2', nullif(p_attr2, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE3', nullif(p_attr3, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE4', nullif(p_attr4, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE5', nullif(p_attr5, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE6', nullif(p_attr6, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE7', nullif(p_attr7, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE8', nullif(p_attr8, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE9', nullif(p_attr9, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE10', nullif(p_attr10, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE11', nullif(p_attr11, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE12', nullif(p_attr12, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE13', nullif(p_attr13, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE14', nullif(p_attr14, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE15', nullif(p_attr15, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE16', nullif(p_attr16, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE17', nullif(p_attr17, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE18', nullif(p_attr18, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE19', nullif(p_attr19, p_gmiss_char));
  FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE20', nullif(p_attr20, p_gmiss_char));

  IF (FND_FLEX_DESCVAL.validate_desccols(
      'AR',
      'HZ_PARTY_SITES',
      'V',
      p_validation_date)) THEN
    return 'Y';
  ELSE
    return null;
  END IF;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:validate_desc_flexfield_f()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

END validate_desc_flexfield_f;


  PROCEDURE load_addresses (
    P_DML_RECORD  	            IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
    P_UPDATE_STR_ADDR           IN            VARCHAR2,
    P_MAINTAIN_LOC_HIST         IN            VARCHAR2,
    P_ALLOW_ADDR_CORR           IN            VARCHAR2,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  ) IS
  l_debug_prefix		       VARCHAR2(30) := '';
  BEGIN
    savepoint load_addresses_pvt;
    FND_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --enable_debug;
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:load_addresses()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_allow_correction := P_ALLOW_ADDR_CORR;
    l_maintain_loc_hist := P_MAINTAIN_LOC_HIST;
    l_allow_std_update := P_UPDATE_STR_ADDR;

    l_move_count := null;
    l_init_upd_count := null;
    l_corr_count := null;
    l_corr_upd_count := null;
    l_temp_upd_count := null;
    l_move_count := NUMBER_COLUMN();
    l_init_upd_count := NUMBER_COLUMN();
    l_corr_count := NUMBER_COLUMN();
    l_corr_upd_count := NUMBER_COLUMN();
    l_temp_upd_count := NUMBER_COLUMN();


    process_insert_addresses(P_DML_RECORD,
                             x_return_status, x_msg_count, x_msg_data );

    IF x_return_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
      process_update_addresses(P_DML_RECORD, x_return_status,
                               x_msg_count, x_msg_data );
    END IF;

    sync_party_tax_profile
    ( P_BATCH_ID           =>   P_DML_RECORD.batch_id ,
      P_REQUEST_ID         =>   P_DML_RECORD.request_id ,
      P_ORIG_SYSTEM        =>   P_DML_RECORD.os ,
      P_FROM_OSR           =>   P_DML_RECORD.from_osr ,
      P_TO_OSR             =>   P_DML_RECORD.to_osr ,
      P_BATCH_MODE_FLAG    =>   P_DML_RECORD.batch_mode_flag,
      P_PROGRAM_ID         =>   P_DML_RECORD.program_id
    );

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:load_addresses()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;



        ----dbms_output.put_line('end of loading address');
   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ----dbms_output.put_line('===============G_EXC_ERROR error');
     ROLLBACK TO load_addresses_pvt;
     FND_FILE.put_line(fnd_file.log,'Execution error occurs while loading addresses');
     FND_FILE.put_line(fnd_file.log, SQLERRM);
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
     END IF;
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:load_addresses()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ----dbms_output.put_line('================unexpected error');

     ROLLBACK TO load_addresses_pvt;
     FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading addresses');
     FND_FILE.put_line(fnd_file.log, SQLERRM);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'UNEXPECTED ERROR',
			       p_msg_level=>fnd_log.level_error);
     END IF;
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:load_addresses()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

   WHEN OTHERS THEN
     ----dbms_output.put_line('================load_addresses Exception: ' || SQLERRM);

     IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'load_addresses Exception: ',
	                       p_prefix=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
	hz_utility_v2pub.debug(p_message=>SQLERRM,
	                       p_prefix=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
     END IF;
     ROLLBACK TO load_addresses_pvt;
     FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading addresses');
     FND_FILE.put_line(fnd_file.log, SQLERRM);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
    IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'SQL ERROR',
			       p_msg_level=>fnd_log.level_error);
     END IF;
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:load_addresses()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

  END load_addresses;


  PROCEDURE process_insert_addresses (
    P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  ) IS
  l_sql_query VARCHAR2(20000) :=
  'begin insert all
  when (action_mismatch_error is not null
   and error_flag is null         -- e1
   and address_error is not null  -- e2
   and country_error is not null  -- e3
   and lang_error is not null     -- e4
   and timezone_error is not null -- e5
   and owner_table_id is not null
   and flex_val_error is not null -- e6
   and createdby_error is not null -- e6
   ) then
  into hz_party_sites (
       actual_content_source,
       party_site_name,
       request_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       program_id,
       program_application_id,
       program_update_date,
       application_id,
       party_site_id,
       party_id,
       location_id,
       party_site_number,
       orig_system_reference,
       status,
       object_version_number,
       identifying_address_flag,
       created_by_module,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       attribute16,
       attribute17,
       attribute18,
       attribute19,
       attribute20)
values (
       :1,
       nullif(party_site_name, :2),
       :3,
       :4,
       :5,
       :4,
       :5,
       :6,
       :7,
       :8,
       :5,
       :9,
       party_site_id,
       party_id,
       hr_locations_s.NextVal,
       nvl(party_site_number, hz_party_site_number_s.nextval),
       site_orig_system_reference,
       ''A'',
       1,
       nvl(primary_flag, ''N''),
       created_by_module,
       nullif(attr_category, :2),
       nullif(attr1, :2),
       nullif(attr2, :2),
       nullif(attr3, :2),
       nullif(attr4, :2),
       nullif(attr5, :2),
       nullif(attr6, :2),
       nullif(attr7, :2),
       nullif(attr8,  :2),
       nullif(attr9,  :2),
       nullif(attr10,  :2),
       nullif(attr11,  :2),
       nullif(attr12,  :2),
       nullif(attr13,  :2),
       nullif(attr14,  :2),
       nullif(attr15,  :2),
       nullif(attr16,  :2),
       nullif(attr17,  :2),
       nullif(attr18,  :2),
       nullif(attr19,  :2),
       nullif(attr20,  :2))
  into hz_orig_sys_references (
       application_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       orig_system_ref_id,
       orig_system,
       orig_system_reference,
       owner_table_name,
       owner_table_id,
       status,
       start_date_active,
       object_version_number,
       created_by_module,
       party_id,
       request_id,
       program_application_id,
       program_id,
       program_update_date)
values (
       :9,
       :4,
       :5,
       :4,
       :5,
       :6,
       hz_orig_system_ref_s.nextval,
       site_orig_system,
       site_orig_system_reference,
       ''HZ_PARTY_SITES'',
       party_site_id,
       ''A'',
       :5,
       1,
       created_by_module,
       party_id,
       :3,
       :8,
       :7,
       :5)
  into hz_locations (
       actual_content_source,
       application_id,
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
       location_id,
       orig_system_reference,
       country,
       address1,
       address2,
       address3,
       address4,
       city,
       postal_code,
       state,
       province,
       county,
       validated_flag,
       address_lines_phonetic,
       postal_plus4_code,
       timezone_id,
       location_directions,
       clli_code,
       language,
       short_description,
       description,
       delivery_point_code,
       sales_tax_geocode,
       sales_tax_inside_city_limits,
       geometry_status_code,
       object_version_number,
       validation_status_code,
       date_validated,
       created_by_module)
values (
       :1,
       :9,
       ''USER_ENTERED'',
       :4,
       :5,
       :4,
       :5,
       :6,
       :8,
       :7,
       :5,
       :3,
       hr_locations_s.NextVal,
       site_orig_system_reference,
       decode(accept_std_flag, ''Y'', country_std, country),
       decode(accept_std_flag, ''Y'', address1_std, address1),
       decode(accept_std_flag, ''Y'', address2_std, address2),
       decode(accept_std_flag, ''Y'', address3_std, address3),
       decode(accept_std_flag, ''Y'', address4_std, address4),
       decode(accept_std_flag, ''Y'', city_std, city),
       decode(accept_std_flag, ''Y'', postal_code_std, postal_code),
       decode(accept_std_flag, ''Y'', nvl2(province, null, prov_state_admin_code_std), state),
       decode(accept_std_flag, ''Y'', nvl2(province, prov_state_admin_code_std, null), province),
       decode(accept_std_flag, ''Y'', county_std, county),
       ''N'',
       nullif(address_lines_phonetic, :2),
       nullif(postal_plus4_code, :2),
       upgrade_tz_id,
       nullif(location_directions, :2),
       nullif(clli_code, :2),
       nullif(language, :2),
       nullif(short_description, :2),
       nullif(description, :2),
       nullif(delivery_point_code, :2),
       nullif(sales_tax_geocode, :2),
       nvl(nullif(sales_tax_inside_city_limits, :2), ''1''),
       ''DIRTY'',
       1,
       decode(accept_std_flag, ''Y'', addr_valid_status_code, null),
       decode(accept_std_flag, ''Y'', date_validated, null),
       created_by_module)
  -- insert ino location profile with user data
  into hz_location_profiles (
       actual_content_source,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       location_id,
       location_profile_id,
       address1,
       address2,
       address3,
       address4,
       city,
       prov_state_admin_code,
       county,
       country,
       postal_code,
       effective_start_date,
       validation_sst_flag,
       object_version_number,
       request_id,
       program_application_id,
       program_id,
       program_update_date)
values (
       :1,
       :4,
       :5,
       :4,
       :5,
       :6,
       hr_locations_s.NextVal,
       hz_location_profiles_s.nextval,
       address1,
       address2,
       address3,
       address4,
       city,
       nvl(state, province),
       county,
       country,
       postal_code,
       :5,
       ''Y'', -- validation_sst_flag
       1,
       :3,
       :8,
       :7,
       :5)
  when (action_mismatch_error is not null
   and error_flag is null
   and address_error is not null
   and country_error is not null
   and lang_error is not null
   and timezone_error is not null
   and owner_table_id is not null
   and accept_std_flag is not null -- if validated data present
   and flex_val_error is not null
   ) then
  into hz_location_profiles (
       actual_content_source,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       location_id,
       location_profile_id,
       address1,
       address2,
       address3,
       address4,
       city,
       prov_state_admin_code,
       county,
       country,
       postal_code,
       effective_start_date,
       validation_status_code,
       date_validated,
       validation_sst_flag,
       object_version_number,
       request_id,
       program_application_id,
       program_id,
       program_update_date)
values (
       adapter_content_source,
       :4,
       :5,
       :4,
       :5,
       :6,
       hr_locations_s.NextVal,
       hz_location_profiles_s.nextval+1,
       address1_std,
       address2_std,
       address3_std,
       address4_std,
       city_std,
       prov_state_admin_code_std,
       county_std,
       country_std,
       postal_code_std,
       :5,
       addr_valid_status_code,
       date_validated,
       decode(accept_std_flag, ''Y'', ''Y'', ''N''), -- validation_sst_flag
       1,
       :3,
       :8,
       :7,
       :5)
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
       e1_flag,
       e2_flag,
       e3_flag,
       e4_flag,
       e5_flag,
       e6_flag,
       e7_flag,
       e8_flag,
       e9_flag/* bug 4079902 */,
       e10_flag,
       e11_flag)
values (
       :4,
       :5,
       :4,
       :5,
       :6,
       :8,
       :7,
       :5,
       hz_imp_errors_s.nextval,
       :10,
       :3,
       row_id,
       ''HZ_IMP_ADDRESSES_INT'',
       action_mismatch_error,
       nvl2(owner_table_id, ''Y'', null),
       nvl2(error_flag, DECODE(error_flag,3,''Y'', null), ''Y''),
       address_error,
       country_error,
       lang_error,
       timezone_error,
       flex_val_error,
       ''Y'',
       ''Y'',
       ''Y'',
       nvl2(error_flag, DECODE(error_flag,2,''Y'', null), ''Y''),
       createdby_error)
select /*+ leading(site_sg) use_nl(site_int) rowid(site_int) use_nl(timezone) */
       hp.party_id owner_table_id,
       site_int.addr_valid_status_code,
       site_int.date_validated,
       site_int.rowid row_id,
       site_sg.party_site_id,
       site_int.party_site_number,
       site_int.party_site_name,
       site_sg.party_id,
       site_int.site_orig_system,
       site_int.site_orig_system_reference,
       site_int.country,
       site_int.country_std,
       site_int.address1,
       nullif(site_int.address2, :2) address2,
       nullif(site_int.address3, :2) address3,
       nullif(site_int.address4, :2) address4,
       site_int.address1_std,
       site_int.address2_std,
       site_int.address3_std,
       site_int.address4_std,
       nullif(site_int.city, :2) city,
       site_int.city_std,
       nullif(site_int.postal_code, :2) postal_code,
       site_int.postal_code_std,
       nullif(site_int.state, :2) state,
       site_int.prov_state_admin_code_std,
       site_int.province,
       nullif(site_int.county, :2) county,
       site_int.county_std,
       site_int.address_lines_phonetic,
       site_int.postal_plus4_code,
       timezone.upgrade_tz_id,
       site_int.location_directions,
       site_int.clli_code,
       site_int.language,
       site_int.short_description,
       site_int.description,
       site_int.delivery_point_code,
       site_int.sales_tax_geocode,
       site_int.sales_tax_inside_city_limits,
       nvl(nullif(site_int.created_by_module, :2), ''HZ_IMPORT'') created_by_module,
       site_int.last_updated_by,
       site_int.accept_standardized_flag accept_std_flag,
       site_int.adapter_content_source adapter_content_source,
       site_int.attribute_category attr_category,
       site_int.attribute1 attr1,
       site_int.attribute2 attr2,
       site_int.attribute3 attr3,
       site_int.attribute4 attr4,
       site_int.attribute5 attr5,
       site_int.attribute6 attr6,
       site_int.attribute7 attr7,
       site_int.attribute8 attr8,
       site_int.attribute9 attr9,
       site_int.attribute10 attr10,
       site_int.attribute11 attr11,
       site_int.attribute12 attr12,
       site_int.attribute13 attr13,
       site_int.attribute14 attr14,
       site_int.attribute15 attr15,
       site_int.attribute16 attr16,
       site_int.attribute17 attr17,
       site_int.attribute18 attr18,
       site_int.attribute19 attr19,
       site_int.attribute20 attr20,
       nvl2(nullif(site_int.address1, :2),
       nvl2(site_int.accept_standardized_flag, nvl2(nullif(site_int.address1_std, :2), ''Y'' ,null), ''Y'')
       , null) address_error,
       nvl2(nullif(site_int.country, :2),
       nvl2(fnd_terr.territory_code,
         nvl2(site_int.accept_standardized_flag,
           nvl2(nullif(site_int.country_std, :2),
             nvl2(fnd_terr2.territory_code, ''Y'', null),
           null), ''Y''),
       null), null) country_error,
       nvl2(nullif(site_int.language, :2), nvl2(fnd_lang.language_code, ''Y'', null), ''Y'') lang_error,
       nvl2(nullif(site_int.timezone_code, :2), nvl2(timezone.timezone_code, ''Y'', null), ''Y'') timezone_error,
       nvl2(nullif(nullif(site_int.insert_update_flag, :2), site_sg.action_flag), null, ''Y'') action_mismatch_error,
       site_sg.error_flag,
       site_sg.primary_flag primary_flag,
       nvl2(nullif(site_int.created_by_module, :2), nvl2(createdby_l.lookup_code, ''Y'', null), ''Y'') createdby_error,
       decode(:11, ''Y'',
         HZ_IMP_LOAD_ADDRESSES_PKG.validate_desc_flexfield_f(
         site_int.attribute_category, site_int.attribute1, site_int.attribute2, site_int.attribute3, site_int.attribute4,
         site_int.attribute5, site_int.attribute6, site_int.attribute7, site_int.attribute8, site_int.attribute9,
         site_int.attribute10, site_int.attribute11, site_int.attribute12, site_int.attribute13, site_int.attribute14,
         site_int.attribute15, site_int.attribute16, site_int.attribute17, site_int.attribute18, site_int.attribute19,
         site_int.attribute20, :5, :2
         ), ''T'') flex_val_error
  FROM HZ_IMP_ADDRESSES_INT site_int,
       HZ_IMP_ADDRESSES_SG site_sg,
       FND_TERRITORIES fnd_terr,
       FND_TERRITORIES fnd_terr2,
       (select language_code
          from FND_LANGUAGES
          where installed_flag in (''B'', ''I'')) fnd_lang,
       fnd_timezones_b timezone,
       HZ_PARTIES hp,
       fnd_lookup_values createdby_l
 WHERE hp.party_id (+) = site_sg.party_id
   AND hp.status (+) = ''A''
   AND site_sg.action_flag = ''I''
   AND site_sg.party_orig_system = :12
   AND site_sg.party_orig_system_reference between :13 AND :14
   AND site_int.rowid = site_sg.int_row_id
   and site_sg.batch_id = :10
   and site_sg.batch_mode_flag = :15
   AND fnd_terr.territory_code (+) = nullif(site_int.country, :2)
   AND fnd_terr2.territory_code (+) = nullif(site_int.country_std, :2)
   AND fnd_lang.language_code (+) = site_int.language
   --AND fnd_lang.installed_flag (+) in (''B'', ''I'')
   and createdby_l.lookup_code (+) = site_int.created_by_module
   and createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
   and createdby_l.language (+) = userenv(''LANG'')
   and createdby_l.view_application_id (+) = 222
   and createdby_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
   AND timezone.timezone_code (+) = site_int.timezone_code';

  l_where_enabled_lookup_sql varchar2(4000) :=
 	'AND  ( createdby_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:5) BETWEEN
	  TRUNC(NVL( createdby_l.START_DATE_ACTIVE,:5 ) ) AND
	  TRUNC(NVL( createdby_l.END_DATE_ACTIVE,:5 ) ) )';

   l_sql_query_end varchar2(15000):= '; end;';
   l_first_run_clause varchar2(40) := ' AND site_int.interface_status is null';
   l_re_run_clause varchar2(40) := ' AND site_int.interface_status = ''C''';
   --l_where_enabled_lookup_sql varchar2(3000) := ' AND  ( timezone.ENABLED_FLAG(+) = ''Y'' )';
   l_final_qry varchar2(20000);
   primary_flag_err_cursor pri_flag_cursor_type;
   de_norm_cursor de_norm_cursor_type;
   l_debug_prefix  VARCHAR2(30) := '';
  BEGIN

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:process_insert_addresses()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    savepoint process_insert_addresses_pvt;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- add clause for first run/re-run
    if(P_DML_RECORD.RERUN='N') then
      l_final_qry := l_sql_query || l_first_run_clause;
    else
      l_final_qry := l_sql_query || l_re_run_clause;
    end if;

    -- add clause for filtering out disabled lookup

    if P_DML_RECORD.ALLOW_DISABLED_LOOKUP <> 'Y' then
      l_final_qry := l_final_qry || l_where_enabled_lookup_sql;
    end if;

    l_final_qry := l_final_qry || l_sql_query_end;

    execute immediate l_final_qry using
      P_DML_RECORD.ACTUAL_CONTENT_SRC, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.REQUEST_ID, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.PROGRAM_ID,
      P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.APPLICATION_ID,
      P_DML_RECORD.BATCH_ID, P_DML_RECORD.flex_validation,P_DML_RECORD.OS,
      P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR, P_DML_RECORD.BATCH_MODE_FLAG;

    /* DE-NORM */
    /* for all the failed record of primary_flag = 'Y', update the party with */
    /* the next available address                                             */
    OPEN primary_flag_err_cursor FOR
    'select
       party_id,
       party_site_id
     from
     (
       select
         party_id,party_site_id,
         rank() over (partition by all_site_ids.party_id
           order by all_site_ids.party_site_id) new_rank
       from
       (
         select addr_sg.party_id,
                hz_ps.party_site_id
           from HZ_IMP_TMP_ERRORS err_table,
                hz_imp_addresses_sg addr_sg,
                hz_party_sites hz_ps
          where err_table.request_id = :request_id
            and interface_table_name = ''HZ_IMP_ADDRESSES_INT''
            and addr_sg.batch_id = :batch_id
            and addr_sg.batch_mode_flag = :batch_mode_flag
            and addr_sg.party_orig_system = :orig_system
            and addr_sg.party_orig_system_reference  between :from_osr and :to_osr
            and addr_sg.primary_flag = ''Y''
            and addr_sg.int_row_id = err_table.int_row_id
            and addr_sg.action_flag = ''I''
            and hz_ps.party_id (+) =  addr_sg.party_id
            and addr_sg.party_id is not null
       ) all_site_ids
     )
     where new_rank = 1'
          using P_DML_RECORD.REQUEST_ID,P_DML_RECORD.BATCH_ID,--P_DML_RECORD.BATCH_ID,
                P_DML_RECORD.BATCH_MODE_FLAG, P_DML_RECORD.OS,
                P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR;

    fetch primary_flag_err_cursor  BULK COLLECT INTO
      l_error_party_id, l_error_site_id;
    close primary_flag_err_cursor;

    forall i in 1..l_error_party_id.count
      update hz_parties hz_pty
         set ( address1, address2, address3, address4,
               country, county, city, state, province,
               postal_code ) =
             ( select address1, address2, address3, address4,
                      country, county, city, state, province,
                      postal_code
                 from hz_party_sites hz_ps,
                      hz_locations hz_loc
                where hz_ps.location_id = hz_loc.location_id
                  and hz_ps.party_site_id = l_error_site_id(i)
                union -- nullify if no next available address
               select null,null,null,null,null,
                      null,null,null,null,null
                 from dual
                where l_error_site_id(i) is null
             ),
             object_version_number = object_version_number + 1,
             last_update_date = P_DML_RECORD.SYSDATE,
             last_updated_by = P_DML_RECORD.USER_ID,
             last_update_login = P_DML_RECORD.LAST_UPDATE_LOGIN,
             program_update_date =  P_DML_RECORD.SYSDATE
       where hz_pty.party_id = l_error_party_id(i);

    forall i in 1..l_error_party_id.count
      update hz_party_sites
         set identifying_address_flag = 'Y',
             object_version_number = object_version_number + 1,
             last_update_date = P_DML_RECORD.SYSDATE,
             last_updated_by = P_DML_RECORD.USER_ID,
             last_update_login = P_DML_RECORD.LAST_UPDATE_LOGIN,
             program_update_date =  P_DML_RECORD.SYSDATE
       where party_site_id = l_error_site_id(i);

    /* de-norm the primary address to parties */
    /* Note: for error case, the party site with the id will just be not found */
    /*       in update. Not necessary to filter out here.                      */

    /* bug fix 3851810   */
    /* If DNB is not selected as a visible data soruce, we should not  */
    /* denormalize it even it is the first active address created for the  */
    /* party. We should only denormalize the visible address. */

    -- check if the data source is seleted.

   /* Commented the code for bug 4079902. */

    /*
    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_LOCATIONS',
      p_entity_attr_id                 => g_pst_entity_attr_id,
      p_mixnmatch_enabled              => g_pst_mixnmatch_enabled,
      p_selected_datasources           => g_pst_selected_datasources );

    g_pst_is_datasource_selected :=
      HZ_MIXNM_UTILITY.isDataSourceSelected (
        p_selected_datasources           => g_pst_selected_datasources,
        p_actual_content_source          => p_dml_record.actual_content_src );


   IF g_pst_is_datasource_selected = 'Y' THEN
   */
      OPEN de_norm_cursor FOR
        'select addr_sg.party_id, addr_sg.party_site_id
           from hz_imp_addresses_sg addr_sg
          where addr_sg.batch_id = :batch_id
            and addr_sg.batch_mode_flag = :batch_mode_flag
            and addr_sg.party_orig_system = :orig_system
            and addr_sg.party_orig_system_reference
                between :from_osr and :to_osr
            and addr_sg.primary_flag = ''Y''
            and addr_sg.action_flag = ''I''
            and addr_sg.party_action_flag = ''U''
            '
            using P_DML_RECORD.BATCH_ID,
                  P_DML_RECORD.BATCH_MODE_FLAG, P_DML_RECORD.OS,
                  P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR;

      fetch de_norm_cursor  BULK COLLECT INTO
        l_update_party_id, l_update_site_id;
      close de_norm_cursor;

      forall i in 1..l_update_party_id.count
        update hz_parties hz_pty
           set ( address1, address2, address3, address4,
                 country, county, city, state, province,
                 postal_code
                  ) =
               ( select address1, address2, address3, address4,
                        country, county, city, state, province,
                        postal_code
                   from hz_party_sites hz_ps,
                        hz_locations hz_loc
                  where hz_ps.location_id = hz_loc.location_id
                    and hz_ps.party_site_id = l_update_site_id(i)
               ),
              object_version_number = object_version_number + 1,
              last_update_date = P_DML_RECORD.SYSDATE,
              last_updated_by = P_DML_RECORD.USER_ID,
              last_update_login = P_DML_RECORD.LAST_UPDATE_LOGIN,
              program_update_date =  P_DML_RECORD.SYSDATE
         where hz_pty.party_id = l_update_party_id(i);

    -- END IF;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:process_insert_addresses()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

  return;
  exception
    when DUP_VAL_ON_INDEX then
      ----dbms_output.put_line('=================dup val exception');
      ----dbms_output.put_line(sqlerrm);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert addresses dup val exception: ' || SQLERRM);
      ROLLBACK to process_insert_addresses_pvt;

      populate_error_table(P_DML_RECORD, 'Y', sqlerrm);
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
    when others then
      ----dbms_output.put_line('===================other exception');
      ----dbms_output.put_line(sqlerrm);

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert addresses other exception: ' || SQLERRM);
      ROLLBACK to process_insert_addresses_pvt;

      populate_error_table(P_DML_RECORD, 'N', sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

  end process_insert_addresses;


   PROCEDURE populate_error_table(
     P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DUP_VAL_EXP               IN     VARCHAR2,
     P_SQL_ERRM                  IN     VARCHAR2  ) IS

     dup_val_exp_val             VARCHAR2(1) := null;
     other_exp_val               VARCHAR2(1) := 'Y';
     l_debug_prefix		 VARCHAR2(30) := '';
   BEGIN

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:populate_error_table()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

     /* other entities need to add checking for other constraints */
     if (P_DUP_VAL_EXP = 'Y') then
       other_exp_val := null;
       if(instr(P_SQL_ERRM, 'PARTY_SITES_U1')<>0) then
         dup_val_exp_val := 'A';
       elsif(instr(P_SQL_ERRM, 'PARTY_SITES_U2')<>0) then
         dup_val_exp_val := 'B';
       else -- '_U2'
         dup_val_exp_val := 'C';
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
       OTHER_EXCEP_FLAG, missing_parent_flag,
       e1_flag,e2_flag,e3_flag,e4_flag,e5_flag,e6_flag,e7_flag,e9_flag,e8_flag,e10_flag,
       e11_flag
     )
     (
       select P_DML_RECORD.REQUEST_ID,
              P_DML_RECORD.BATCH_ID,
              fr_sg.int_row_id,
              'HZ_IMP_ADDRESSES_INT',
              hz_imp_errors_s.NextVal,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.LAST_UPDATE_LOGIN,
              P_DML_RECORD.PROGRAM_APPLICATION_ID,
              P_DML_RECORD.PROGRAM_ID,
              P_DML_RECORD.SYSDATE,
              dup_val_exp_val,
              other_exp_val, 'Y',
              'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y',
              'Y'
         from hz_imp_addresses_sg fr_sg
        where fr_sg.action_flag = 'I'
          and fr_sg.batch_id = P_DML_RECORD.BATCH_ID
          and fr_sg.party_orig_system = P_DML_RECORD.OS
          and fr_sg.party_orig_system_reference
              between P_DML_RECORD.FROM_OSR and P_DML_RECORD.TO_OSR
     );

   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:populate_error_table()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
   END IF;

   END populate_error_table;


    PROCEDURE open_update_cursor (update_cursor   IN OUT NOCOPY update_cursor_type,
                                  P_DML_RECORD    IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
    ) IS

  /* Note: Is it a problem to generate foreign key party site, location id */
  /* here for move? Many ids from sequence would be lost.                  */
   l_sql_query VARCHAR2(20000) :=
'SELECT hz_loc.ADDRESS_LINES_PHONETIC,
        hz_loc.POSTAL_PLUS4_CODE,
        hz_loc.LOCATION_DIRECTIONS,
        hz_loc.CLLI_CODE,
        hz_loc.LANGUAGE,
        hz_loc.SHORT_DESCRIPTION,
        hz_loc.DESCRIPTION,
        hz_loc.DELIVERY_POINT_CODE,
        hz_loc.SALES_TAX_GEOCODE,
        hz_loc.SALES_TAX_INSIDE_CITY_LIMITS,
        0 flex_val_errors,
        ''T'' dss_security_errors,
        hz_loc.validation_status_code,
        mosr.owner_table_id,
        nvl2(nullif(mosr2.party_id,site_sg.party_id),decode(hz_ps1.Identifying_address_flag,
            ''Y'',''N'',''Y''),hz_ps.IDENTIFYING_ADDRESS_FLAG)
        identifying_address_flag,
        mosr2.party_id owning_party_id,
        site_int.addr_valid_status_code,
        hz_loc.validation_status_code,
        site_int.date_validated,
        site_int.CORRECT_MOVE_INDICATOR,
        site_sg.action_flag,
        site_int.ROWID,
        hz_ps.location_id,
        hr_locations_s.NextVal,
        site_sg.party_site_id,
        hz_party_sites_s.NextVal,
        site_int.party_site_number,
        site_int.party_site_name,
        site_sg.party_id,
        site_int.site_orig_system,
        site_int.site_orig_system_reference,
        site_sg.old_site_orig_system_ref,
        site_int.country,
        site_int.country_std,
        site_int.address1, site_int.address2, site_int.address3, site_int.address4,
        site_int.address1_std, site_int.address2_std, site_int.address3_std, site_int.address4_std,
        site_int.city, site_int.city_std, site_int.postal_code, site_int.postal_code_std,
        site_int.state, site_int.prov_state_admin_code_std,
        site_int.PROVINCE, site_int.county, site_int.county_std,
        hz_loc.country,
        hz_loc.address1,hz_loc.address2,hz_loc.address3,hz_loc.address4,
        hz_loc.city, hz_loc.postal_code,
        hz_loc.state, hz_loc.province, hz_loc.county,
        site_int.ADDRESS_LINES_PHONETIC,
        site_int.POSTAL_PLUS4_CODE,
        hz_loc.time_zone,
        timezone.UPGRADE_TZ_ID,
        site_int.TIMEZONE_CODE,
        site_int.location_directions,
        site_int.clli_code,
        site_int.language,
        site_int.short_description,
        site_int.description,
        site_int.delivery_point_code,
        site_int.SALES_TAX_GEOCODE,
        site_int.SALES_TAX_INSIDE_CITY_LIMITS,
        site_int.CREATED_BY_MODULE,
        site_int.LAST_UPDATED_BY,
        site_int.ACCEPT_STANDARDIZED_FLAG,
        site_int.ADAPTER_CONTENT_SOURCE,
        site_int.attribute_category, site_int.attribute1, site_int.attribute2,
        site_int.attribute3, site_int.attribute4, site_int.attribute5,
        site_int.attribute6,  site_int.attribute7, site_int.attribute8,
        site_int.attribute9, site_int.attribute10, site_int.attribute11,
        site_int.attribute12, site_int.attribute13, site_int.attribute14,
        site_int.attribute15, site_int.attribute16, site_int.attribute17,
        site_int.attribute18, site_int.attribute19, site_int.attribute20,
        hz_loc.attribute_category, hz_loc.attribute1, hz_loc.attribute2,
        hz_loc.attribute3, hz_loc.attribute4, hz_loc.attribute5,
        hz_loc.attribute6,  hz_loc.attribute7,  hz_loc.attribute8,
        hz_loc.attribute9,  hz_loc.attribute10, hz_loc.attribute11,
        hz_loc.attribute12, hz_loc.attribute13, hz_loc.attribute14,
        hz_loc.attribute15, hz_loc.attribute16, hz_loc.attribute17,
        hz_loc.attribute18, hz_loc.attribute19, hz_loc.attribute20,
        site_sg.NEW_OSR_EXISTS_FLAG,
        decode(site_int.state,
          null, decode(hz_loc.state,
            null, decode(site_int.province, null, hz_loc.province, :GMISS_CHAR, null, site_int.province),hz_loc.state),
          :GMISS_CHAR, decode(site_int.province, null, hz_loc.province, :GMISS_CHAR, null, site_int.province),
          site_int.state) ps_admin_code,

       nvl2(nullif(site_int.address1, :GMISS_CHAR),
       nvl2(site_int.accept_standardized_flag, nvl2(nullif(site_int.address1_std, :GMISS_CHAR), ''Y'' ,null), ''Y'')
       , null) address_error,

       nvl2(nullif(site_int.country, :GMISS_CHAR),
       nvl2(fnd_terr.territory_code,
         nvl2(site_int.accept_standardized_flag,
           nvl2(nullif(site_int.country_std, :GMISS_CHAR),
             nvl2(fnd_terr2.territory_code, ''Y'', null),
           null), ''Y''),
       null), null) country_error,

        decode(site_int.language, null, ''Y'', :GMISS_CHAR, ''Y'', fnd_lang.language_code) lang_error,
        decode(site_int.timezone_code, null, ''Y'', :GMISS_CHAR, ''Y'', timezone.timezone_code) timezone_error,
        decode(nvl(site_int.insert_update_flag, site_sg.action_flag), site_sg.action_flag, ''Y'', null) action_mismatch_error,
        site_sg.error_flag,
        decode(site_int.ACCEPT_STANDARDIZED_FLAG, ''Y'',
          decode(hz_loc.country, site_int.country_std,
          decode(nvl(hz_loc.state,hz_loc.province), site_int.prov_state_admin_code_std,
          decode(hz_loc.county, site_int.county_std,
          decode(hz_loc.city, site_int.city_std,
          decode(hz_loc.postal_code, site_int.postal_code_std,
          decode(hz_loc.address1, site_int.address1_std,
          decode(hz_loc.address2, site_int.address2_std,
          decode(hz_loc.address3, site_int.address3_std,
          decode(hz_loc.address4, site_int.address4_std,
          null, ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''),
          decode(hz_loc.country,
          decode(site_int.country, :GMISS_CHAR, null, null, hz_loc.country, site_int.country),
          decode(hz_loc.state,
          decode(site_int.state, :GMISS_CHAR, null, null, hz_loc.state, site_int.state),
          decode(hz_loc.province,
          decode(site_int.province, :GMISS_CHAR, null, null, hz_loc.province, site_int.province),
          decode(hz_loc.county,
          decode(site_int.county, :GMISS_CHAR, null, null, hz_loc.county, site_int.county),
          decode(hz_loc.city,
          decode(site_int.city, :GMISS_CHAR, null, null, hz_loc.city, site_int.city),
          decode(hz_loc.postal_code,
          decode(site_int.postal_code, :GMISS_CHAR, null, null, hz_loc.postal_code, site_int.postal_code),
          decode(hz_loc.address1,
          decode(site_int.address1, :GMISS_CHAR, null, null, hz_loc.address1, site_int.address1),
          decode(hz_loc.address2,
          decode(site_int.address2, :GMISS_CHAR, null, null, hz_loc.address2, site_int.address2),
          decode(hz_loc.address3,
          decode(site_int.address3, :GMISS_CHAR, null, null, hz_loc.address3, site_int.address3),
          decode(hz_loc.address4,
          decode(site_int.address4, :GMISS_CHAR, null, null, hz_loc.address4, site_int.address4),
          null, ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y'')) addr_ch_flag,
        decode(site_int.ACCEPT_STANDARDIZED_FLAG, ''Y'',
          decode(hz_loc.country, site_int.country_std,
          decode(nvl(hz_loc.state,hz_loc.province), site_int.prov_state_admin_code_std,
          decode(hz_loc.county, site_int.county_std,
          decode(hz_loc.city, site_int.city_std,
          decode(hz_loc.postal_code, site_int.postal_code_std,
          null, ''Y''), ''Y''), ''Y''), ''Y''), ''Y''),
          decode(hz_loc.country,
          decode(site_int.country, :GMISS_CHAR, null, null, hz_loc.country, site_int.country),
          decode(hz_loc.state,
          decode(site_int.state, :GMISS_CHAR, null, null, hz_loc.state, site_int.state),
          decode(hz_loc.province,
          decode(site_int.province, :GMISS_CHAR, null, null, hz_loc.province, site_int.province),
          decode(hz_loc.county,
          decode(site_int.county, :GMISS_CHAR, null, null, hz_loc.county, site_int.county),
          decode(hz_loc.city,
          decode(site_int.city, :GMISS_CHAR, null, null, hz_loc.city, site_int.city),
          decode(hz_loc.postal_code,
          decode(site_int.postal_code, :GMISS_CHAR, null, null, hz_loc.postal_code, site_int.postal_code),
          null, ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y'')) tax_ch_flag,
          hz_ps.identifying_address_flag primary_flag,
          /* bug 4079902 */
          nvl2(nullif(hz_ps.actual_content_source,:l_os),
              nvl2(nullif(hos.orig_system_type,''PURCHASED''),''Y'',null),
              ''Y'')             third_party_update_error,
          nvl2(nullif(site_int.created_by_module,:GMISS_CHAR),
               decode(site_int.CORRECT_MOVE_INDICATOR,
                      ''M'',nvl2(createdby_l.lookup_code,''Y'',null),
                      nvl2(site_sg.new_osr_exists_flag,
                           nvl2(nullif(site_int.site_orig_system_reference,site_sg.old_site_orig_system_ref),
                                nvl2(createdby_l.lookup_code,''Y'',null),
                                ''Y''
                               ),
                           ''Y''
                          )
                     ),
               ''Y'')  createdby_error

   FROM HZ_IMP_ADDRESSES_INT site_int,
        HZ_IMP_ADDRESSES_SG  site_sg,
        FND_TERRITORIES fnd_terr,
        FND_TERRITORIES fnd_terr2,
        ( select language_code
          from FND_LANGUAGES
          where installed_flag in (''B'', ''I'')
         ) fnd_lang,
        fnd_timezones_b timezone,
        hz_party_sites hz_ps,
        hz_locations hz_loc,
        HZ_ORIG_SYS_REFERENCES mosr,
        HZ_ORIG_SYSTEMS_B hos,
        hz_party_sites hz_ps1,
        HZ_ORIG_SYS_REFERENCES mosr2,
        fnd_lookup_values createdby_l

  WHERE mosr.orig_system (+) = site_sg.party_orig_system
    AND mosr.orig_system_reference (+) = site_sg.party_orig_system_reference
    AND mosr.status (+) = ''A''
    AND mosr.owner_table_name (+) = ''HZ_PARTIES''
    AND mosr.owner_table_id (+) = site_sg.party_id
    AND site_sg.action_flag = ''U''
    AND site_int.batch_id = :CP_BATCH_ID
    AND site_sg.batch_id = :CP_BATCH_ID
    AND site_sg.batch_mode_flag = :CP_BATCH_MODE_FLAG
    AND site_sg.party_orig_system = :CP_OS
    AND site_sg.party_orig_system_reference between :CP_FROM_OSR AND :CP_TO_OSR
    AND site_int.rowid = site_sg.int_row_id

    AND fnd_terr.territory_code (+) = nullif(site_int.country, :GMSSS_CHAR)
    AND fnd_terr2.territory_code (+) = nullif(site_int.country_std, :GMSSS_CHAR)

    AND fnd_lang.language_code (+) = site_int.language
    AND timezone.timezone_code (+) = site_int.timezone_code
    AND hz_ps.party_site_id = site_sg.party_site_id
    AND hz_loc.location_id = hz_ps.location_id
    AND hz_ps.actual_content_source=hos.orig_system
    AND hz_ps1.party_id(+) = site_sg.party_id
    AND hz_ps1.status(+) = ''A''
    AND hz_ps1.identifying_address_flag(+) =''Y''
    AND mosr2.orig_system (+) = site_sg.site_orig_system
    AND mosr2.orig_system_reference (+) = site_sg.site_orig_system_reference
    AND mosr2.status (+) = ''A''
    AND mosr2.owner_table_name (+) = ''HZ_PARTY_SITES''
    AND mosr2.owner_table_id (+) = site_sg.party_site_id
    AND createdby_l.lookup_code (+) = site_int.created_by_module
    AND createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
    AND createdby_l.language (+) = userenv(''LANG'')
    AND createdby_l.view_application_id (+) = 222
    AND createdby_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
';

   l_sql_query_w_prf VARCHAR2(20000) :=
'SELECT --hz_loc_prf.validation_status_code,
          ( select validation_sst_flag
              from hz_location_profiles hz_loc_prf
             where hz_loc_prf.actual_content_source = site_int.ADAPTER_CONTENT_SOURCE
               and hz_loc_prf.location_id = hz_loc.location_id
               and nullif(EFFECTIVE_END_DATE, :CP_END_DATE) is null
          ) old_prf_sst,
        hz_loc.ADDRESS_LINES_PHONETIC,
        hz_loc.POSTAL_PLUS4_CODE,
        hz_loc.LOCATION_DIRECTIONS,
        hz_loc.CLLI_CODE,
        hz_loc.LANGUAGE,
        hz_loc.SHORT_DESCRIPTION,
        hz_loc.DESCRIPTION,
        hz_loc.DELIVERY_POINT_CODE,
        hz_loc.SALES_TAX_GEOCODE,
        hz_loc.SALES_TAX_INSIDE_CITY_LIMITS,
        0 flex_val_errors,
        ''T'' dss_security_errors,
        hz_loc.validation_status_code,
        mosr.owner_table_id,
        nvl2(nullif(mosr2.party_id,site_sg.party_id),decode(hz_ps1.Identifying_address_flag,
            ''Y'',''N'',''Y''),hz_ps.IDENTIFYING_ADDRESS_FLAG)
        identifying_address_flag,
        mosr2.party_id owning_party_id,
        site_int.addr_valid_status_code,
        hz_loc.validation_status_code,
        site_int.date_validated,
        site_int.CORRECT_MOVE_INDICATOR,
        site_sg.action_flag,
        site_int.ROWID,
        hz_ps.location_id,
        hr_locations_s.NextVal,
        site_sg.party_site_id,
        hz_party_sites_s.NextVal,
        site_int.party_site_number,
        site_int.party_site_name,
        site_sg.party_id,
        site_int.site_orig_system,
        site_int.site_orig_system_reference,
        site_sg.old_site_orig_system_ref,
        site_int.country,
        site_int.country_std,
        site_int.address1, site_int.address2, site_int.address3, site_int.address4,
        site_int.address1_std, site_int.address2_std, site_int.address3_std, site_int.address4_std,
        site_int.city, site_int.city_std, site_int.postal_code, site_int.postal_code_std,
        site_int.state, site_int.prov_state_admin_code_std,
        site_int.PROVINCE, site_int.county, site_int.county_std,
        hz_loc.country,
        hz_loc.address1,hz_loc.address2,hz_loc.address3,hz_loc.address4,
        hz_loc.city, hz_loc.postal_code,
        hz_loc.state, hz_loc.province, hz_loc.county,
        site_int.ADDRESS_LINES_PHONETIC,
        site_int.POSTAL_PLUS4_CODE,
        hz_loc.time_zone,
        timezone.UPGRADE_TZ_ID,
        site_int.TIMEZONE_CODE,
        site_int.location_directions,
        site_int.clli_code,
        site_int.language,
        site_int.short_description,
        site_int.description,
        site_int.delivery_point_code,
        site_int.SALES_TAX_GEOCODE,
        site_int.SALES_TAX_INSIDE_CITY_LIMITS,
        site_int.CREATED_BY_MODULE,
        site_int.LAST_UPDATED_BY,
        site_int.ACCEPT_STANDARDIZED_FLAG,
        site_int.ADAPTER_CONTENT_SOURCE,
        site_int.attribute_category, site_int.attribute1, site_int.attribute2,
        site_int.attribute3, site_int.attribute4, site_int.attribute5,
        site_int.attribute6,  site_int.attribute7, site_int.attribute8,
        site_int.attribute9, site_int.attribute10, site_int.attribute11,
        site_int.attribute12, site_int.attribute13, site_int.attribute14,
        site_int.attribute15, site_int.attribute16, site_int.attribute17,
        site_int.attribute18, site_int.attribute19, site_int.attribute20,
        hz_loc.attribute_category, hz_loc.attribute1, hz_loc.attribute2,
        hz_loc.attribute3, hz_loc.attribute4, hz_loc.attribute5,
        hz_loc.attribute6,  hz_loc.attribute7,  hz_loc.attribute8,
        hz_loc.attribute9,  hz_loc.attribute10, hz_loc.attribute11,
        hz_loc.attribute12, hz_loc.attribute13, hz_loc.attribute14,
        hz_loc.attribute15, hz_loc.attribute16, hz_loc.attribute17,
        hz_loc.attribute18, hz_loc.attribute19, hz_loc.attribute20,
        site_sg.NEW_OSR_EXISTS_FLAG,
        decode(site_int.state,
          null, decode(hz_loc.state,
            null, decode(site_int.province, null, hz_loc.province, :GMISS_CHAR, null, site_int.province),hz_loc.state),
          :GMISS_CHAR, decode(site_int.province, null, hz_loc.province, :GMISS_CHAR, null, site_int.province),
          site_int.state) ps_admin_code,

        nvl2(nullif(site_int.address1, :GMISS_CHAR),
        nvl2(site_int.accept_standardized_flag, nvl2(nullif(site_int.address1_std, :GMISS_CHAR), ''Y'' ,null), ''Y'')
        , null) address_error,

        nvl2(nullif(site_int.country, :GMISS_CHAR),
        nvl2(fnd_terr.territory_code,
         nvl2(site_int.accept_standardized_flag,
           nvl2(nullif(site_int.country_std, :GMISS_CHAR),
             nvl2(fnd_terr2.territory_code, ''Y'', null),
           null), ''Y''),
        null), null) country_error,

        decode(site_int.language, null, ''Y'', :GMISS_CHAR, ''Y'', fnd_lang.language_code) lang_error,
        decode(site_int.timezone_code, null, ''Y'', :GMISS_CHAR, ''Y'', timezone.timezone_code) timezone_error,
        decode(nvl(site_int.insert_update_flag, site_sg.action_flag), site_sg.action_flag, ''Y'', null) action_mismatch_error,
        site_sg.error_flag,
        decode(site_int.ACCEPT_STANDARDIZED_FLAG, ''Y'',
          decode(hz_loc.country, site_int.country_std,
          decode(nvl(hz_loc.state,hz_loc.province), site_int.prov_state_admin_code_std,
          decode(hz_loc.county, site_int.county_std,
          decode(hz_loc.city, site_int.city_std,
          decode(hz_loc.postal_code, site_int.postal_code_std,
          decode(hz_loc.address1, site_int.address1_std,
          decode(hz_loc.address2, site_int.address2_std,
          decode(hz_loc.address3, site_int.address3_std,
          decode(hz_loc.address4, site_int.address4_std,
          null, ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''),
          decode(hz_loc.country,
          decode(site_int.country, :GMISS_CHAR, null, null, hz_loc.country, site_int.country),
          decode(hz_loc.state,
          decode(site_int.state, :GMISS_CHAR, null, null, hz_loc.state, site_int.state),
          decode(hz_loc.province,
          decode(site_int.province, :GMISS_CHAR, null, null, hz_loc.province, site_int.province),
          decode(hz_loc.county,
          decode(site_int.county, :GMISS_CHAR, null, null, hz_loc.county, site_int.county),
          decode(hz_loc.city,
          decode(site_int.city, :GMISS_CHAR, null, null, hz_loc.city, site_int.city),
          decode(hz_loc.postal_code,
          decode(site_int.postal_code, :GMISS_CHAR, null, null, hz_loc.postal_code, site_int.postal_code),
          decode(hz_loc.address1,
          decode(site_int.address1, :GMISS_CHAR, null, null, hz_loc.address1, site_int.address1),
          decode(hz_loc.address2,
          decode(site_int.address2, :GMISS_CHAR, null, null, hz_loc.address2, site_int.address2),
          decode(hz_loc.address3,
          decode(site_int.address3, :GMISS_CHAR, null, null, hz_loc.address3, site_int.address3),
          decode(hz_loc.address4,
          decode(site_int.address4, :GMISS_CHAR, null, null, hz_loc.address4, site_int.address4),
          null, ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y'')) addr_ch_flag,
        decode(site_int.ACCEPT_STANDARDIZED_FLAG, ''Y'',
          decode(hz_loc.country, site_int.country_std,
          decode(nvl(hz_loc.state,hz_loc.province), site_int.prov_state_admin_code_std,
          decode(hz_loc.county, site_int.county_std,
          decode(hz_loc.city, site_int.city_std,
          decode(hz_loc.postal_code, site_int.postal_code_std,
          null, ''Y''), ''Y''), ''Y''), ''Y''), ''Y''),
          decode(hz_loc.country,
          decode(site_int.country, :GMISS_CHAR, null, null, hz_loc.country, site_int.country),
          decode(hz_loc.state,
          decode(site_int.state, :GMISS_CHAR, null, null, hz_loc.state, site_int.state),
          decode(hz_loc.province,
          decode(site_int.province, :GMISS_CHAR, null, null, hz_loc.province, site_int.province),
          decode(hz_loc.county,
          decode(site_int.county, :GMISS_CHAR, null, null, hz_loc.county, site_int.county),
          decode(hz_loc.city,
          decode(site_int.city, :GMISS_CHAR, null, null, hz_loc.city, site_int.city),
          decode(hz_loc.postal_code,
          decode(site_int.postal_code, :GMISS_CHAR, null, null, hz_loc.postal_code, site_int.postal_code),
          null, ''Y''), ''Y''), ''Y''), ''Y''), ''Y''), ''Y'')) tax_ch_flag,
          hz_ps.identifying_address_flag primary_flag,
          /* bug 4079902 */
          nvl2(nullif(hz_ps.actual_content_source,:l_os),
              nvl2(nullif(hos.orig_system_type,''PURCHASED''),''Y'',null),
              ''Y'')             third_party_update_error,
          nvl2(nullif(site_int.created_by_module,:GMISS_CHAR),
               decode(site_int.CORRECT_MOVE_INDICATOR,
                      ''M'',nvl2(createdby_l.lookup_code,''Y'',null),
                      nvl2(site_sg.new_osr_exists_flag,
                           nvl2(nullif(site_int.site_orig_system_reference,site_sg.old_site_orig_system_ref),
                                nvl2(createdby_l.lookup_code,''Y'',null),
                                ''Y''
                               ),
                           ''Y''
                          )
                     ),
               ''Y'')  createdby_error

   FROM HZ_IMP_ADDRESSES_INT site_int,
        HZ_IMP_ADDRESSES_SG  site_sg,
        FND_TERRITORIES fnd_terr,
        FND_TERRITORIES fnd_terr2,
        ( select language_code
          from FND_LANGUAGES
          where installed_flag in (''B'', ''I'')
         ) fnd_lang,
        fnd_timezones_b timezone,
        hz_party_sites hz_ps,
        hz_locations hz_loc,
        HZ_ORIG_SYS_REFERENCES mosr,
        HZ_ORIG_SYSTEMS_B hos,
        hz_party_sites hz_ps1,
        HZ_ORIG_SYS_REFERENCES mosr2,
        fnd_lookup_values createdby_l
  WHERE mosr.orig_system (+) = site_sg.party_orig_system
    AND mosr.orig_system_reference (+) = site_sg.party_orig_system_reference
    AND mosr.status (+) = ''A''
    AND mosr.owner_table_name (+) = ''HZ_PARTIES''
    AND mosr.owner_table_id (+) = site_sg.party_id
    AND site_sg.action_flag = ''U''
    AND site_int.batch_id = :CP_BATCH_ID
    AND site_sg.batch_id = :CP_BATCH_ID
    AND site_sg.batch_mode_flag = :CP_BATCH_MODE_FLAG
    AND site_sg.party_orig_system = :CP_OS
    AND site_sg.party_orig_system_reference between :CP_FROM_OSR AND :CP_TO_OSR
    AND site_int.rowid = site_sg.int_row_id
    AND fnd_terr.territory_code (+) = nullif(site_int.country, :GMSSS_CHAR)
    AND fnd_terr2.territory_code (+) = nullif(site_int.country_std, :GMSSS_CHAR)
    AND fnd_lang.language_code (+) = site_int.language
    AND timezone.timezone_code (+) = site_int.timezone_code
    AND hz_ps.party_site_id = site_sg.party_site_id
    --AND hz_loc_prf.location_id (+) = hz_loc.location_id
    AND hz_loc.location_id = hz_ps.location_id
 AND hz_ps.actual_content_source=hos.orig_system
    AND hz_ps1.party_id(+) = site_sg.party_id
    AND hz_ps1.status(+) = ''A''
    AND hz_ps1.identifying_address_flag(+) =''Y''AND mosr2.orig_system (+) = site_sg.site_orig_system
    AND mosr2.orig_system_reference (+) = site_sg.site_orig_system_reference
    AND mosr2.status (+) = ''A''
    AND mosr2.owner_table_name (+) = ''HZ_PARTY_SITES''
    AND mosr2.owner_table_id (+) = site_sg.party_site_id
    AND createdby_l.lookup_code (+) = site_int.created_by_module
    AND createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
    AND createdby_l.language (+) = userenv(''LANG'')
    AND createdby_l.view_application_id (+) = 222
    AND createdby_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
';

  l_where_enabled_lookup_sql varchar2(4000) :=
 	'AND  ( createdby_l.ENABLED_FLAG(+) = ''Y'' AND
	  TRUNC(:5) BETWEEN
	  TRUNC(NVL( createdby_l.START_DATE_ACTIVE,:5 ) ) AND
	  TRUNC(NVL( createdby_l.END_DATE_ACTIVE,:5 ) ) )';

   l_first_run_clause varchar2(40) := ' AND site_int.interface_status is null';
   l_re_run_clause varchar2(40) := ' AND site_int.interface_status = ''C''';

   --l_where_enabled_lookup_sql varchar2(3000) :=	' AND  ( timezone.ENABLED_FLAG(+) = ''Y'' )';

   l_final_qry varchar2(20000);
   l_debug_prefix  VARCHAR2(30) := '';
  BEGIN

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:open_update_cursor()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  if(l_allow_std_update <> 'Y') then
    l_final_qry := l_sql_query_w_prf;
  else
    l_final_qry := l_sql_query;
  end if;

  if(P_DML_RECORD.RERUN='N') then
    l_final_qry := l_final_qry || l_first_run_clause;
  else
    l_final_qry := l_final_qry || l_re_run_clause;
  end if;


  IF P_DML_RECORD.ALLOW_DISABLED_LOOKUP = 'N' THEN
    l_final_qry := l_final_qry || l_where_enabled_lookup_sql;

    if(l_allow_std_update = 'Y') then
    OPEN update_cursor FOR l_final_qry
    USING P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.ACTUAL_CONTENT_SRC,P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.BATCH_ID,
          P_DML_RECORD.BATCH_ID, P_DML_RECORD.BATCH_MODE_FLAG,
          P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE;

  else
  OPEN update_cursor FOR l_final_qry
    USING c_end_date, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.ACTUAL_CONTENT_SRC,
          P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.BATCH_ID, P_DML_RECORD.BATCH_ID, P_DML_RECORD.BATCH_MODE_FLAG,
          P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE;
  end if;
ELSE
    if(l_allow_std_update = 'Y') then
    OPEN update_cursor FOR l_final_qry
    USING P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.ACTUAL_CONTENT_SRC,P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.BATCH_ID,
          P_DML_RECORD.BATCH_ID, P_DML_RECORD.BATCH_MODE_FLAG,
          P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR;

  else
  OPEN update_cursor FOR l_final_qry
    USING c_end_date, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.ACTUAL_CONTENT_SRC,
          P_DML_RECORD.GMISS_CHAR,
          P_DML_RECORD.BATCH_ID, P_DML_RECORD.BATCH_ID, P_DML_RECORD.BATCH_MODE_FLAG,
          P_DML_RECORD.OS, P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR,
          P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR;
  end if;
END IF;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:open_update_cursor()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  END open_update_cursor;


PROCEDURE validate_desc_flexfield(
  p_validation_date IN DATE
) IS
  l_flex_exists  VARCHAR2(1);
  l_debug_prefix VARCHAR2(30) := '';
BEGIN

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:validate_desc_flexfield()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  FOR i IN 1..l_site_id.count LOOP

    FND_FLEX_DESCVAL.set_context_value(l_attr_category(i));

    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE1', l_attr1(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE2', l_attr2(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE3', l_attr3(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE4', l_attr4(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE5', l_attr5(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE6', l_attr6(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE7', l_attr7(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE8', l_attr8(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE9', l_attr9(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE10', l_attr10(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE11', l_attr11(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE12', l_attr12(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE13', l_attr13(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE14', l_attr14(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE15', l_attr15(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE16', l_attr16(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE17', l_attr17(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE18', l_attr18(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE19', l_attr19(i));
    FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE20', l_attr20(i));

    IF (NOT FND_FLEX_DESCVAL.validate_desccols(
      'AR',
      'HZ_PARTY_SITES',
      'V',
      p_validation_date)) THEN
      l_flex_val_errors(i) := 1;
    END IF;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'ADDR:validate_desc_flexfield()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

  END LOOP;

  ----dbms_output.put_line('validate_desc_flexfield-');
END validate_desc_flexfield;


PROCEDURE validate_DSS_security IS
  dss_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  dss_msg_count     NUMBER := 0;
  dss_msg_data      VARCHAR2(2000):= null;
  l_debug_prefix    VARCHAR2(30) := '';
BEGIN

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'validate_DSS_security for address.');

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'PTY:validate_DSS_security()+',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
  END IF;

  /* Check if the DSS security is granted to the user.
     Only check for update. */
  FOR i IN 1..l_site_id.count LOOP
    l_dss_security_errors(i) :=
              hz_dss_util_pub.test_instance(
                p_operation_code     => 'UPDATE',
                p_db_object_name     => 'HZ_PARTY_SITES',
                p_instance_pk1_value => l_site_id(i),
                p_user_name          => fnd_global.user_name,
                x_return_status      => dss_return_status,
                x_msg_count          => dss_msg_count,
                x_msg_data           => dss_msg_data);
  END LOOP;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'PTY:validate_DSS_security()-',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
  END IF;

  END validate_DSS_security;


   PROCEDURE process_update_addresses (
    P_DML_RECORD                IN            HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  ) IS
  c_update_cursor             update_cursor_type;
  l_dml_exception             varchar2(1) := 'N';
  l_debug_prefix	      VARCHAR2(30) := '';
  BEGIN

    ----dbms_output.put_line('process_update_addresses+');
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'process_update_addresses()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    savepoint process_update_addresses_pvt;
    FND_MSG_PUB.initialize;
    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    open_update_cursor(c_update_cursor, P_DML_RECORD);

    if(l_allow_std_update= 'Y') then
    fetch c_update_cursor  BULK COLLECT INTO
    l_old_addr_phonetic,
  l_old_postal_plus4,
  l_old_loc_dir,
  l_old_clli_code,
  l_old_language,
  l_old_short_desc,
  l_old_desc,
  l_old_delvy_pt_code,
  l_old_sales_tax_code,
  l_old_sales_tax_limit,
    l_flex_val_errors,
    l_dss_security_errors,
    l_val_status_code,
    l_owner_table_id,
    l_ident_addr_flag,
    l_owning_party_id,
    l_valid_status_code,
    l_old_valid_status_code,
    l_date_validated,
    l_corr_mv_ind,
    l_action_flag,
    l_row_id,
    l_location_id,
    l_new_loc_id,
    l_site_id,
    l_new_site_id,
    l_party_site_number,
    l_site_name,
    l_party_id,
    l_site_orig_system,
    l_site_orig_system_reference,
    l_old_site_osr,
    l_country, l_country_std,
    l_addr1, l_addr2, l_addr3, l_addr4,
    l_addr1_std, l_addr2_std, l_addr3_std, l_addr4_std,
    l_city, l_city_std, l_postal_code, l_postal_code_std, l_state,
    l_ps_admin_std,
    l_province, l_county, l_county_std,
    l_old_country,
    l_old_addr1, l_old_addr2, l_old_addr3, l_old_addr4,
    l_old_city, l_old_postal_code,
    l_old_state, l_old_province, l_old_county,
    l_addr_phonetic, l_postal_plus4, l_old_timezone, l_timezone, l_timezone_code,
    l_loc_dir, l_clli_code, l_language,
    l_short_desc, l_desc,
    l_delvy_pt_code,
    l_sales_tax_code,
    l_sales_tax_limit,
    --l_fa_loc_id,
    l_created_by_module,
    l_last_updated_by,
    l_accept_std_flag,
    l_adptr_content_src,
    l_attr_category, l_attr1, l_attr2, l_attr3, l_attr4, l_attr5, l_attr6,
    l_attr7, l_attr8, l_attr9, l_attr10, l_attr11, l_attr12, l_attr13,
    l_attr14, l_attr15, l_attr16, l_attr17, l_attr18, l_attr19, l_attr20,
    l_old_attr_category, l_old_attr1, l_old_attr2, l_old_attr3, l_old_attr4, l_old_attr5, l_old_attr6,
    l_old_attr7, l_old_attr8, l_old_attr9, l_old_attr10, l_old_attr11, l_old_attr12, l_old_attr13,
    l_old_attr14, l_old_attr15, l_old_attr16, l_old_attr17, l_old_attr18, l_old_attr19, l_old_attr20,
    l_NEW_OSR_EXISTS,
    l_ps_admin_int,
    l_address_err,
    l_country_err,
    l_lang_err,
    l_timezone_err,
    l_action_error_flag,
    l_error_flag,
    l_addr_ch_flag,
    l_tax_ch_flag,
    l_primary_flag,
    --l_moved_site_id,
    --l_moved_site_number
    l_third_party_update_error, /* Bug 4079902 */
    l_createdby_errors;


    else
    fetch c_update_cursor  BULK COLLECT INTO
    l_old_profile_sst_flag,
    l_old_addr_phonetic,
  l_old_postal_plus4,
  l_old_loc_dir,
  l_old_clli_code,
  l_old_language,
  l_old_short_desc,
  l_old_desc,
  l_old_delvy_pt_code,
  l_old_sales_tax_code,
  l_old_sales_tax_limit,
    l_flex_val_errors,
    l_dss_security_errors,
    l_val_status_code,
    l_owner_table_id,
    l_ident_addr_flag,
    l_owning_party_id,
    l_valid_status_code,
    l_old_valid_status_code,
    l_date_validated,
    l_corr_mv_ind,
    l_action_flag,
    l_row_id,
    l_location_id,
    l_new_loc_id,
    l_site_id,
    l_new_site_id,
    l_party_site_number,
    l_site_name,
    l_party_id,
    l_site_orig_system,
    l_site_orig_system_reference,
    l_old_site_osr,
    l_country, l_country_std,
    l_addr1, l_addr2, l_addr3, l_addr4,
    l_addr1_std, l_addr2_std, l_addr3_std, l_addr4_std,
    l_city, l_city_std, l_postal_code, l_postal_code_std, l_state,
    l_ps_admin_std,
    l_province, l_county, l_county_std,
    l_old_country,
    l_old_addr1, l_old_addr2, l_old_addr3, l_old_addr4,
    l_old_city, l_old_postal_code,
    l_old_state, l_old_province, l_old_county,
    l_addr_phonetic, l_postal_plus4, l_old_timezone, l_timezone, l_timezone_code,
    l_loc_dir, l_clli_code, l_language,
    l_short_desc, l_desc,
    l_delvy_pt_code,
    l_sales_tax_code,
    l_sales_tax_limit,
    --l_fa_loc_id,
    l_created_by_module,
    l_last_updated_by,
    l_accept_std_flag,
    l_adptr_content_src,
    l_attr_category, l_attr1, l_attr2, l_attr3, l_attr4, l_attr5, l_attr6,
    l_attr7, l_attr8, l_attr9, l_attr10, l_attr11, l_attr12, l_attr13,
    l_attr14, l_attr15, l_attr16, l_attr17, l_attr18, l_attr19, l_attr20,
    l_old_attr_category, l_old_attr1, l_old_attr2, l_old_attr3, l_old_attr4, l_old_attr5, l_old_attr6,
    l_old_attr7, l_old_attr8, l_old_attr9, l_old_attr10, l_old_attr11, l_old_attr12, l_old_attr13,
    l_old_attr14, l_old_attr15, l_old_attr16, l_old_attr17, l_old_attr18, l_old_attr19, l_old_attr20,
    l_NEW_OSR_EXISTS,
    l_ps_admin_int,
    l_address_err,
    l_country_err,
    l_lang_err,
    l_timezone_err,
    l_action_error_flag,
    l_error_flag,
    l_addr_ch_flag,
    l_tax_ch_flag,
    l_primary_flag,
    --l_moved_site_id,
    --l_moved_site_number
    l_third_party_update_error, /* Bug 4079902 */
    l_createdby_errors;


    end if;

    close c_update_cursor;

    /* Do FND desc flex validation based on profile */
    IF P_DML_RECORD.FLEX_VALIDATION = 'Y' THEN
      validate_desc_flexfield(P_DML_RECORD.SYSDATE);
    END IF;

    /* Do DSS security validation based on profile */
    IF P_DML_RECORD.DSS_SECURITY = 'Y' THEN
      validate_DSS_security;
    END IF;

   ----dbms_output.put_line('number of input records: ' || l_site_id.count);
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'number of input records: ' || l_site_id.count,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    l_move_count.extend(l_site_id.count);
    l_init_upd_count.extend(l_site_id.count);
    l_corr_count.extend(l_site_id.count);
    l_corr_upd_count.extend(l_site_id.count);
    l_temp_upd_count.extend(l_site_id.count);

    /* handle correction and no-address-column-change records         */
    /* update location profile for user data                        */
    /* if profile Maintain Location History = 'Y', end-date old one */
    /* otherwise, update the entry directly                         */
    forall j in 1..l_site_id.count save exceptions
      update hz_location_profiles
         set effective_end_date = decode(l_maintain_loc_hist, 'Y', P_DML_RECORD.SYSDATE, null),
             address1 = decode(l_maintain_loc_hist, 'Y', address1, decode(l_addr1(j), P_DML_RECORD.GMISS_CHAR, null, null, address1, l_addr1(j))),
             address2 = decode(l_maintain_loc_hist, 'Y', address2, decode(l_addr2(j), P_DML_RECORD.GMISS_CHAR, null, null, address2, l_addr2(j))),
             address3 = decode(l_maintain_loc_hist, 'Y', address3, decode(l_addr3(j), P_DML_RECORD.GMISS_CHAR, null, null, address3, l_addr3(j))),
             address4 = decode(l_maintain_loc_hist, 'Y', address4, decode(l_addr4(j), P_DML_RECORD.GMISS_CHAR, null, null, address4, l_addr4(j))),
             city = decode(l_maintain_loc_hist, 'Y', city, decode(l_city(j), P_DML_RECORD.GMISS_CHAR, null, null, city, l_city(j))),
             prov_state_admin_code = decode(l_maintain_loc_hist, 'Y', prov_state_admin_code, l_ps_admin_int(j)),
             COUNTY = decode(l_maintain_loc_hist, 'Y', COUNTY, decode(l_county(j), P_DML_RECORD.GMISS_CHAR, null, null, city, l_county(j))),
             COUNTRY = decode(l_maintain_loc_hist, 'Y', country, nvl(l_country(j), COUNTRY)),
             postal_code = decode(l_maintain_loc_hist, 'Y', postal_code, decode(l_postal_code(j), P_DML_RECORD.GMISS_CHAR, null, null, postal_code, l_postal_code(j))),
             --validation_sst_flag = decode(l_maintain_loc_hist, 'Y', validation_sst_flag, decode(l_accept_std_flag(j), 'Y', 'N', 'Y')),
             /* no need to update validation status code for user data */
             object_version_number = object_version_number+1,
             last_update_date = P_DML_RECORD.SYSDATE,
             last_updated_by = P_DML_RECORD.USER_ID,
             last_update_login = P_DML_RECORD.LAST_UPDATE_LOGIN
       where location_id=l_location_id(j)               /*                            */
         and actual_content_source = P_DML_RECORD.ACTUAL_CONTENT_SRC /*  keys for location profile */
         and nullif(effective_end_date, c_end_date) is null               /*                            */
         and l_action_error_flag(j) is not null      -- error checks
         and l_error_flag(j) is null
         and l_address_err(j) is not null
         and l_country_err(j) is not null
         and l_lang_err(j) is not null
         and l_timezone_err(j) is not null
         and l_flex_val_errors(j) = 0
         and l_dss_security_errors(j) = 'T'
         and (( nvl(l_corr_mv_ind(j), 'M') = 'C'     -- correction
            and l_allow_correction = 'Y')            -- and allowed
         or nvl(l_addr_ch_flag(j), 'N') <> 'Y')      -- or no change in addr cols
         and l_third_party_update_error(j) IS NOT NULL /* bug 4079902 */
         and l_createdby_errors(j) IS NOT NULL;


    /* record row count for corrected/updated records */
    FOR k IN 1..l_site_id.count LOOP
      if l_addr_ch_flag(k)='Y' then
        l_corr_count(k) := SQL%BULK_ROWCOUNT(k);
      else
        l_corr_count(k) := 0;
      end if;
      l_init_upd_count(k) := SQL%BULK_ROWCOUNT(k);
    end loop;

    /* update row count for corrected/updated records */
    FOR k IN 1..l_site_id.count LOOP
      if l_addr_ch_flag(k)='Y' then
        l_corr_count(k) := l_init_upd_count(k);
      end if;
      l_corr_upd_count(k) := l_init_upd_count(k);
    end loop;

    /* handle move records */
    /* create new party site and invalidate old one if it is necessary to move */
    /* condition: if address-related column change and correct_move_indicator='N'/null */
    begin
    forall j in 1..l_site_id.count save exceptions
    insert into hz_party_sites
    ( PARTY_SITE_ID,
      PARTY_ID,
      LOCATION_ID,
      PARTY_SITE_NUMBER,
      LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
      REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE,
      ORIG_SYSTEM_REFERENCE,
      STATUS,
      PARTY_SITE_NAME,
      OBJECT_VERSION_NUMBER,
      CREATED_BY_MODULE,
      APPLICATION_ID,
      ACTUAL_CONTENT_SOURCE,
      IDENTIFYING_ADDRESS_FLAG,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       attribute16,
       attribute17,
       attribute18,
       attribute19,
       attribute20
    )
    ( select
        l_new_site_id(j),
        l_party_id(j),
        l_new_loc_id(j),
        hz_party_site_number_s.NextVal,
        P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.USER_ID,
        P_DML_RECORD.REQUEST_ID,
        P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
        l_site_orig_system_reference(j),
        'A',
        nullif(l_site_name(j),P_DML_RECORD.GMISS_CHAR),
        1,
        nvl(l_created_by_module(j), 'HZ_IMPORT'),
        P_DML_RECORD.APPLICATION_ID,
        --'ACS for inserted party site',
        P_DML_RECORD.ACTUAL_CONTENT_SRC,
        nvl(l_ident_addr_flag(j), 'N'),
        nullif(nvl(l_attr_category(j), l_old_attr_category(j)),  P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr1(j), l_attr1(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr2(j), l_attr2(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr3(j), l_attr3(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr4(j), l_attr4(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr5(j), l_attr5(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr6(j), l_attr6(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr7(j), l_attr7(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr8(j), l_attr8(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr9(j), l_attr9(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr10(j), l_attr10(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr11(j), l_attr11(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr12(j), l_attr12(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr13(j), l_attr13(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr14(j), l_attr14(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr15(j), l_attr15(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr16(j), l_attr16(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr17(j), l_attr17(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr18(j), l_attr18(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr19(j), l_attr19(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_attr20(j), l_attr20(j)), P_DML_RECORD.GMISS_CHAR)
   from dual
  where l_action_error_flag(j) is not null
    and l_error_flag(j) is null
    and l_address_err(j) is not null
    and l_country_err(j) is not null
    and l_lang_err(j) is not null
    and l_timezone_err(j) is not null
    and l_flex_val_errors(j) = 0
    and l_dss_security_errors(j) = 'T'
    and nvl(l_corr_mv_ind(j), 'M') = 'M'
    and l_addr_ch_flag(j) = 'Y'
    and l_third_party_update_error(j) IS NOT NULL /* bug 4079902 */
    and l_createdby_errors(j) IS NOT NULL);
    EXCEPTION
    WHEN OTHERS THEN
      ----dbms_output.put_line('Other exceptions hz_party_sites:' || SQLERRM);
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug(p_message=>'Other exceptions hz_party_sites:',
	                       p_prefix=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
         hz_utility_v2pub.debug(p_message=>SQLERRM,
	                       p_prefix=>'ERROR',
			       p_msg_level=>fnd_log.level_error);

      END IF;

      l_dml_exception := 'Y';
    END;

    /* record row count for moved records */
    FOR k IN 1..l_site_id.count LOOP
      l_move_count(k) := SQL%BULK_ROWCOUNT(k);
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'number of records moved(' || k ||'):' || l_move_count(k),
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
    end loop;

    report_errors(P_DML_RECORD, l_dml_exception);

    /* update hz_locations if                                    */
    /* a) address corrected, or                                  */
    /* b) address updated directly                               */
    /* for addr cols, update only if not standardized address or */
    /* profile option allows update                              */
    forall j in 1..l_site_id.count
      update hz_locations
         set LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
             LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
             LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
             REQUEST_ID = P_DML_RECORD.REQUEST_ID,
             PROGRAM_APPLICATION_ID = P_DML_RECORD.PROGRAM_APPLICATION_ID,
             PROGRAM_ID = P_DML_RECORD.PROGRAM_ID,
             PROGRAM_UPDATE_DATE = P_DML_RECORD.SYSDATE,
             COUNTRY = decode(VALIDATION_STATUS_CODE, null, -- not standardized, alway ok to update
                          decode(l_accept_std_flag(j), 'Y', l_country_std(j),
                            decode(l_country(j), null, COUNTRY, l_country(j))),
                          decode(l_allow_std_update, 'N', COUNTRY,
                            decode(l_accept_std_flag(j), 'Y', l_country_std(j),
                              decode(l_country(j), null, COUNTRY, l_country(j))))),
             ADDRESS1 = decode(VALIDATION_STATUS_CODE, null, -- not standardized, alway ok to update
                          decode(l_accept_std_flag(j), 'Y', l_addr1_std(j),
                            decode(l_addr1(j), null, ADDRESS1, l_addr1(j))),
                          decode(l_allow_std_update, 'N', ADDRESS1,
                            decode(l_accept_std_flag(j), 'Y', l_addr1_std(j),
                              decode(l_addr1(j), null, ADDRESS1, l_addr1(j))))),
             ADDRESS2 = decode(VALIDATION_STATUS_CODE, null, -- not standardized, alway ok to update
                          decode(l_accept_std_flag(j), 'Y', l_addr2_std(j),
                            decode(l_addr2(j), null, ADDRESS2, P_DML_RECORD.GMISS_CHAR, null, l_addr2(j))),
                          decode(l_allow_std_update, 'N', ADDRESS2,
                            decode(l_accept_std_flag(j), 'Y', l_addr2_std(j),
                              decode(l_addr2(j), null, ADDRESS2, P_DML_RECORD.GMISS_CHAR, null, l_addr2(j))))),
             ADDRESS3 = decode(VALIDATION_STATUS_CODE, null, -- not standardized, alway ok to update
                          decode(l_accept_std_flag(j), 'Y', l_addr3_std(j),
                            decode(l_addr3(j), null, ADDRESS3, P_DML_RECORD.GMISS_CHAR, null, l_addr3(j))),
                          decode(l_allow_std_update, 'N', ADDRESS3,
                            decode(l_accept_std_flag(j), 'Y', l_addr3_std(j),
                              decode(l_addr3(j), null, ADDRESS3, P_DML_RECORD.GMISS_CHAR, null, l_addr3(j))))),
             ADDRESS4 = decode(VALIDATION_STATUS_CODE, null, -- not standardized, alway ok to update
                          decode(l_accept_std_flag(j), 'Y', l_addr4_std(j),
                            decode(l_addr4(j), null, ADDRESS4, P_DML_RECORD.GMISS_CHAR, null, l_addr4(j))),
                          decode(l_allow_std_update, 'N', ADDRESS4,
                            decode(l_accept_std_flag(j), 'Y', l_addr4_std(j),
                              decode(l_addr4(j), null, ADDRESS4, P_DML_RECORD.GMISS_CHAR, null, l_addr4(j))))),
             CITY = decode(VALIDATION_STATUS_CODE, null, -- not standardized, alway ok to update
                          decode(l_accept_std_flag(j), 'Y', l_city_std(j),
                            decode(l_city(j), null, CITY, P_DML_RECORD.GMISS_CHAR, null, l_city(j))),
                          decode(l_allow_std_update, 'N', CITY,
                            decode(l_accept_std_flag(j), 'Y', l_city_std(j),
                              decode(l_city(j), null, CITY, P_DML_RECORD.GMISS_CHAR, null, l_city(j))))),
             POSTAL_CODE = decode(VALIDATION_STATUS_CODE, null, -- not standardized, alway ok to update
                          decode(l_accept_std_flag(j), 'Y', l_postal_code_std(j),
                            decode(l_postal_code(j), null, POSTAL_CODE, P_DML_RECORD.GMISS_CHAR, null, l_postal_code(j))),
                          decode(l_allow_std_update, 'N', POSTAL_CODE,
                            decode(l_accept_std_flag(j), 'Y', l_postal_code_std(j),
                              decode(l_postal_code(j), null, POSTAL_CODE, P_DML_RECORD.GMISS_CHAR, null, l_postal_code(j))))),
             STATE = decode(VALIDATION_STATUS_CODE, null, -- not standardized, alway ok to update
                        decode(l_accept_std_flag(j), 'Y', decode(l_province(j), null, l_ps_admin_std(j), null),
                            decode(l_state(j), null, STATE, P_DML_RECORD.GMISS_CHAR, null, l_state(j))),
                          decode(l_allow_std_update, 'N', STATE,
                            decode(l_accept_std_flag(j), 'Y', decode(l_province(j), null, l_ps_admin_std(j), null),
                              decode(l_state(j), null, STATE, P_DML_RECORD.GMISS_CHAR, null, l_state(j))))),
             PROVINCE = decode(VALIDATION_STATUS_CODE, null, -- not standardized, alway ok to update
                          decode(l_accept_std_flag(j), 'Y', decode(l_province(j), null, null, l_ps_admin_std(j)),
                            decode(l_province(j), null, PROVINCE, P_DML_RECORD.GMISS_CHAR, null, l_province(j))),
                          decode(l_allow_std_update, 'N', PROVINCE,
                            decode(l_accept_std_flag(j), 'Y', decode(l_province(j), null, null, l_ps_admin_std(j)),
                              decode(l_province(j), null, PROVINCE, P_DML_RECORD.GMISS_CHAR, null, l_province(j))))),
             COUNTY = decode(VALIDATION_STATUS_CODE, null, -- not standardized, alway ok to update
                          decode(l_accept_std_flag(j), 'Y', l_county_std(j),
                            decode(l_county(j), null, COUNTY, P_DML_RECORD.GMISS_CHAR, null, l_county(j))),
                          decode(l_allow_std_update, 'N', COUNTY,
                            decode(l_accept_std_flag(j), 'Y', l_county_std(j),
                              decode(l_county(j), null, COUNTY, P_DML_RECORD.GMISS_CHAR, null, l_county(j))))),
             ADDRESS_LINES_PHONETIC = DECODE(l_addr_phonetic(j), NULL, ADDRESS_LINES_PHONETIC, P_DML_RECORD.GMISS_CHAR, NULL, l_addr_phonetic(j)),
             POSTAL_PLUS4_CODE = DECODE(l_postal_plus4(j), NULL, POSTAL_PLUS4_CODE, P_DML_RECORD.GMISS_CHAR, NULL, l_postal_plus4(j)),
             DELIVERY_POINT_CODE = DECODE(l_delvy_pt_code(j), NULL, DELIVERY_POINT_CODE, P_DML_RECORD.GMISS_CHAR, NULL, l_delvy_pt_code(j)),
             LOCATION_DIRECTIONS = DECODE(l_loc_dir(j), NULL, LOCATION_DIRECTIONS, P_DML_RECORD.GMISS_CHAR, NULL, l_loc_dir(j)),
             CLLI_CODE = DECODE(l_clli_code(j), NULL, CLLI_CODE, P_DML_RECORD.GMISS_CHAR, NULL, l_clli_code(j)),
             LANGUAGE = DECODE(l_language(j), NULL, LANGUAGE, P_DML_RECORD.GMISS_CHAR, NULL, l_language(j)),
             SHORT_DESCRIPTION = DECODE(l_short_desc(j), NULL, SHORT_DESCRIPTION, P_DML_RECORD.GMISS_CHAR, NULL, l_short_desc(j)),
             DESCRIPTION = DECODE(l_desc(j), NULL, DESCRIPTION, P_DML_RECORD.GMISS_CHAR, NULL, l_desc(j)),
             SALES_TAX_GEOCODE = DECODE(l_sales_tax_code(j), NULL, SALES_TAX_GEOCODE, P_DML_RECORD.GMISS_CHAR, NULL, l_sales_tax_code(j)),
             SALES_TAX_INSIDE_CITY_LIMITS = DECODE(l_sales_tax_limit(j), NULL, SALES_TAX_INSIDE_CITY_LIMITS, P_DML_RECORD.GMISS_CHAR, NULL, l_sales_tax_limit(j)),
             OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1,
             --CREATED_BY_MODULE = nvl(CREATED_BY_MODULE, decode(l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, l_created_by_module(j))),
             APPLICATION_ID = nvl(APPLICATION_ID, P_DML_RECORD.APPLICATION_ID),
             TIMEZONE_ID = DECODE(l_timezone_code(j), NULL, TIMEZONE_ID, P_DML_RECORD.GMISS_CHAR, NULL, l_timezone(j)),
             ACTUAL_CONTENT_SOURCE = P_DML_RECORD.ACTUAL_CONTENT_SRC,
             /* if validation_status_code was null, the location was not standardized.
                For standardized address, status would not change if not allowed to update
                standardized address.
                Otherwise, just set value according to accept standardized flag
             */
             VALIDATION_STATUS_CODE = decode(VALIDATION_STATUS_CODE, null,
                                        decode(l_accept_std_flag(j), 'Y', l_valid_status_code(j), null),
                                        decode(l_allow_std_update, 'N', VALIDATION_STATUS_CODE,
                                        decode(l_accept_std_flag(j), 'Y', l_valid_status_code(j), null))),
             DATE_VALIDATED = decode(VALIDATION_STATUS_CODE, null,
                                decode(l_accept_std_flag(j), 'Y', l_date_validated(j), null),
                                decode(l_allow_std_update, 'N', DATE_VALIDATED,
                                decode(l_accept_std_flag(j), 'Y', l_date_validated(j), null)))
       where location_id = l_location_id(j)
         and l_corr_upd_count(j) = 1;

      forall j in 1..l_site_id.count
           update hz_party_sites
              set ATTRIBUTE_CATEGORY = DECODE(l_attr_category(j), NULL, ATTRIBUTE_CATEGORY, P_DML_RECORD.GMISS_CHAR, NULL, l_attr_category(j)),
                  ATTRIBUTE1 = DECODE(l_attr1(j), NULL, attribute1, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr1(j)),
                  ATTRIBUTE2 = DECODE(l_attr2(j), NULL, attribute2, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr2(j)),
                  ATTRIBUTE3 = DECODE(l_attr3(j), NULL, attribute3, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr3(j)),
                  ATTRIBUTE4 = DECODE(l_attr4(j), NULL, attribute4, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr4(j)),
                  ATTRIBUTE5 = DECODE(l_attr5(j), NULL, attribute5, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr5(j)),
                  ATTRIBUTE6 = DECODE(l_attr6(j), NULL, attribute6, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr6(j)),
                  ATTRIBUTE7 = DECODE(l_attr7(j), NULL, attribute7, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr7(j)),
                  ATTRIBUTE8 = DECODE(l_attr8(j), NULL, attribute8, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr8(j)),
                  ATTRIBUTE9 = DECODE(l_attr9(j), NULL, attribute9, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr9(j)),
                  ATTRIBUTE10 = DECODE(l_attr10(j), NULL, attribute10, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr10(j)),
                  ATTRIBUTE11 = DECODE(l_attr11(j), NULL, attribute11, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr11(j)),
                  ATTRIBUTE12 = DECODE(l_attr12(j), NULL, attribute12, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr12(j)),
                  ATTRIBUTE13 = DECODE(l_attr13(j), NULL, attribute13, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr13(j)),
                  ATTRIBUTE14 = DECODE(l_attr14(j), NULL, attribute14, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr14(j)),
                  ATTRIBUTE15 = DECODE(l_attr15(j), NULL, attribute15, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr15(j)),
                  ATTRIBUTE16 = DECODE(l_attr16(j), NULL, attribute16, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr16(j)),
                  ATTRIBUTE17 = DECODE(l_attr17(j), NULL, attribute17, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr17(j)),
                  ATTRIBUTE18 = DECODE(l_attr18(j), NULL, attribute18, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr18(j)),
                  ATTRIBUTE19 = DECODE(l_attr19(j), NULL, attribute19, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr19(j)),
                  ATTRIBUTE20 = DECODE(l_attr20(j), NULL, attribute20, P_DML_RECORD.GMISS_CHAR, NULL,  l_attr20(j))
            where hz_party_sites.party_site_id = l_site_id(j)
              and l_corr_upd_count(j) = 1;


   /* insert into hz_location_profiles with user data if maintaining old record */
   /* insert if                                                                 */
   /* 1) record moved, or                                                       */
   /* 2) record corrected, and maintaining history and old record exist,or      */
   /* 3) record update, and maintaining historyand old record exist,            */
    ForAll j in 1..l_site_id.count
    insert into HZ_LOCATION_PROFILES
    ( LOCATION_ID, LOCATION_PROFILE_ID,
      ADDRESS1, ADDRESS2,  ADDRESS3,  ADDRESS4,
      CITY,  PROV_STATE_ADMIN_CODE,
      COUNTY, COUNTRY, POSTAL_CODE,
      ACTUAL_CONTENT_SOURCE,
      EFFECTIVE_START_DATE,
      validation_sst_flag,
      OBJECT_VERSION_NUMBER,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE
    )
    ( select
        decode(l_move_count(j), 1, l_new_loc_id(j), l_location_id(j)),
        hz_location_profiles_s.NextVal,
        nvl(l_addr1(j), l_old_addr1(j)),
        nullif(nvl(l_addr2(j), l_old_addr2(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_addr3(j), l_old_addr3(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_addr4(j), l_old_addr4(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_city(j), l_old_city(j)), P_DML_RECORD.GMISS_CHAR),
        nullif( nvl(decode(l_state(j), null, l_province(j),
                    P_DML_RECORD.GMISS_CHAR, l_province(j), l_state(j)),
                    nvl(l_old_state(j), l_old_province(j))),
                    P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_county(j), l_old_county(j)), P_DML_RECORD.GMISS_CHAR),
        nvl(l_country(j), l_old_country(j)),
        nullif(nvl(l_postal_code(j), l_old_postal_code(j)), P_DML_RECORD.GMISS_CHAR),
        --'ACS for usr data', --P_CONTENT_SRC_TYPE,
        P_DML_RECORD.ACTUAL_CONTENT_SRC,
        P_DML_RECORD.SYSDATE,
        'Y', -- validation_sst_flag
        1,
        P_DML_RECORD.SYSDATE,
        P_DML_RECORD.USER_ID,
        P_DML_RECORD.LAST_UPDATE_LOGIN,
        P_DML_RECORD.SYSDATE,
        P_DML_RECORD.USER_ID,
        P_DML_RECORD.REQUEST_ID,
        P_DML_RECORD.PROGRAM_APPLICATION_ID,
        P_DML_RECORD.PROGRAM_ID,
        P_DML_RECORD.SYSDATE
   from dual
  where ( l_maintain_loc_hist = 'Y' and (l_init_upd_count(j) = 1) )
     or l_move_count(j) = 1
      );

    /* modify location profiles of std data if std data exist and */
    /* 1) record corrected, or   */
    /* 2) record update          */
    /* If maitaining history, end-date eixisting one. Otherwise update it. */
    forall j in 1..l_site_id.count
      update hz_location_profiles
         set EFFECTIVE_END_DATE = decode(l_maintain_loc_hist, 'Y',
                                         --do not end-date if sst and not allowed to
                                         --correct standardized address
                                         decode(validation_sst_flag, 'Y',
                                                decode(l_allow_std_update, 'N', null, P_DML_RECORD.SYSDATE),
                                                P_DML_RECORD.SYSDATE),
                                         null),
             address1 = decode(l_maintain_loc_hist, 'Y', address1,
                               --do not update if sst and not allowed to
                               --correct standardized address
                               decode(validation_sst_flag, 'Y',
                                      decode(l_allow_std_update, 'N', address1, l_addr1_std(j)),
                                      l_addr1_std(j))),
             address2 = decode(l_maintain_loc_hist, 'Y', address2,
                               decode(validation_sst_flag, 'Y',
                                      decode(l_allow_std_update, 'N', address2, l_addr2_std(j)),
                                      l_addr2_std(j))),
             address3 = decode(l_maintain_loc_hist, 'Y', address3,
                               decode(validation_sst_flag, 'Y',
                                      decode(l_allow_std_update, 'N', address3, l_addr3_std(j)),
                                      l_addr3_std(j))),
             address4 = decode(l_maintain_loc_hist, 'Y', address4,
                               decode(validation_sst_flag, 'Y',
                                      decode(l_allow_std_update, 'N', address4, l_addr4_std(j)),
                                      l_addr4_std(j))),
             city = decode(l_maintain_loc_hist, 'Y', city,
                               decode(validation_sst_flag, 'Y',
                                      decode(l_allow_std_update, 'N', city, l_city_std(j)),
                                      l_city_std(j))),
             prov_state_admin_code = decode(l_maintain_loc_hist, 'Y', prov_state_admin_code,
                               decode(validation_sst_flag, 'Y',
                                      decode(l_allow_std_update, 'N', prov_state_admin_code, l_ps_admin_std(j)),
                                      l_ps_admin_std(j))),
             county = decode(l_maintain_loc_hist, 'Y', county,
                               decode(validation_sst_flag, 'Y',
                                      decode(l_allow_std_update, 'N', county, l_county_std(j)),
                                      l_county_std(j))),
             country = decode(l_maintain_loc_hist, 'Y', country,
                               decode(validation_sst_flag, 'Y',
                                      decode(l_allow_std_update, 'N', country, l_country_std(j)),
                                      l_country_std(j))),
             postal_code = decode(l_maintain_loc_hist, 'Y', postal_code,
                               decode(validation_sst_flag, 'Y',
                                      decode(l_allow_std_update, 'N', postal_code, l_postal_code_std(j)),
                                      l_postal_code_std(j))),
             validation_sst_flag = decode(l_maintain_loc_hist, 'Y', validation_sst_flag,
                                     decode(l_allow_std_update, 'Y', decode(l_accept_std_flag(j), 'Y', 'Y', 'N'),
                                       -- if not allowed to update standardized
                                       decode(l_val_status_code(j), null,
                                         -- not a standarized address
                                         decode(l_accept_std_flag(j), 'Y', 'Y', 'N'),
                                         validation_sst_flag))),
             validation_status_code = decode(l_maintain_loc_hist, 'Y', validation_status_code, l_valid_status_code(j)),
             date_validated = decode(l_maintain_loc_hist, 'Y', date_validated, P_DML_RECORD.SYSDATE),
             object_version_number = object_version_number+1,
             last_update_date = P_DML_RECORD.SYSDATE,
             last_updated_by = P_DML_RECORD.USER_ID,
             last_update_login = P_DML_RECORD.LAST_UPDATE_LOGIN
       where location_id = l_location_id(j)                 /*                            */
         and actual_content_source = l_adptr_content_src(j) /*  keys for location profile */
         and nullif(effective_end_date, c_end_date) is null /*                            */
         and (l_corr_upd_count(j) = 1)
         and l_accept_std_flag(j) is not null; -- make sure std data available

    /* get row count for updated location profiles */
    FOR k IN 1..l_site_id.count LOOP
      l_temp_upd_count(k) := SQL%BULK_ROWCOUNT(k);
    end loop;

    /* insert into hz_location_profiles with std data                                */
    /* insert if std data available and the location record is                       */
    /* 1) record moved or                                                            */
    /* 2) record corrected, and maintaining history ,or       */
    /* 3) record update, and maintaining history , or         */
    /* 4) record corrected, but no existing hz_location_profiles (l_temp_upd_count(k) = 0), or */
    /* 5) record update, but no existing hz_location_profiles (l_temp_upd_count(k) = 0)        */
    if l_allow_std_update = 'Y' then
    ForAll j in 1..l_site_id.count
    insert into HZ_LOCATION_PROFILES
    ( LOCATION_PROFILE_ID, LOCATION_ID,
      ADDRESS1, ADDRESS2,  ADDRESS3,  ADDRESS4,
      CITY, PROV_STATE_ADMIN_CODE,
      COUNTY, COUNTRY, POSTAL_CODE,
      ACTUAL_CONTENT_SOURCE,
      EFFECTIVE_START_DATE,
      validation_status_code,
      DATE_VALIDATED,
      OBJECT_VERSION_NUMBER,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY,
      VALIDATION_SST_FLAG,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE
    )
    ( select
        hz_location_profiles_s.NextVal,
        decode(l_move_count(j), 1, l_new_loc_id(j), l_location_id(j)),
        l_addr1_std(j),
        l_addr2_std(j),
        l_addr3_std(j),
        l_addr4_std(j),
        l_city_std(j),
        l_ps_admin_std(j),
        l_county_std(j),
        l_country_std(j),
        l_postal_code_std(j),
        l_adptr_content_src(j), --ACTUAL_CONTENT_SOURCE
        --'ACS for std data',
        P_DML_RECORD.SYSDATE,
        l_valid_status_code(j),  -- validation_status_code
        P_DML_RECORD.SYSDATE,    -- DATE_VALIDATED
        1,
        P_DML_RECORD.SYSDATE,
        P_DML_RECORD.USER_ID,
        P_DML_RECORD.LAST_UPDATE_LOGIN,
        P_DML_RECORD.SYSDATE,
        P_DML_RECORD.USER_ID,
        decode(l_accept_std_flag(j), 'Y', 'Y', 'N'),
        P_DML_RECORD.REQUEST_ID,
        P_DML_RECORD.PROGRAM_APPLICATION_ID,
        P_DML_RECORD.PROGRAM_ID,
        P_DML_RECORD.SYSDATE
   from dual
  where l_accept_std_flag(j) is not null
     and (l_move_count(j) = 1 -- record moved
       or ( l_corr_upd_count(j) = 1 -- record corrected/updated
        and ( l_temp_upd_count(j) = 0 -- std loc profile does not exist
           or l_maintain_loc_hist = 'Y' -- to maintain history
            ))));
    else
    ForAll j in 1..l_site_id.count
    insert into HZ_LOCATION_PROFILES
    ( LOCATION_PROFILE_ID, LOCATION_ID,
      ADDRESS1, ADDRESS2,  ADDRESS3,  ADDRESS4,
      CITY, PROV_STATE_ADMIN_CODE,
      COUNTY, COUNTRY, POSTAL_CODE,
      ACTUAL_CONTENT_SOURCE,
      EFFECTIVE_START_DATE,
      validation_status_code,
      DATE_VALIDATED,
      OBJECT_VERSION_NUMBER,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY,
      VALIDATION_SST_FLAG,
      EFFECTIVE_END_DATE,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE
    )
    ( select
        hz_location_profiles_s.NextVal,
        decode(l_move_count(j), 1, l_new_loc_id(j), l_location_id(j)),
        l_addr1_std(j),
        l_addr2_std(j),
        l_addr3_std(j),
        l_addr4_std(j),
        l_city_std(j),
        l_ps_admin_std(j),
        l_county_std(j),
        l_country_std(j),
        l_postal_code_std(j),
        l_adptr_content_src(j), --ACTUAL_CONTENT_SOURCE
        --'ACS for std data',
        P_DML_RECORD.SYSDATE,
        l_valid_status_code(j),  -- validation_status_code
        P_DML_RECORD.SYSDATE,    -- DATE_VALIDATED
        1,
        P_DML_RECORD.SYSDATE,
        P_DML_RECORD.USER_ID,
        P_DML_RECORD.LAST_UPDATE_LOGIN,
        P_DML_RECORD.SYSDATE,
        P_DML_RECORD.USER_ID,
        decode(l_move_count(j), 1, decode(l_accept_std_flag(j), 'Y', 'Y', 'N'),
          -- record corrected/moved
          decode(l_val_status_code(j), null,
            -- not a standarized address
            decode(l_accept_std_flag(j), 'Y', 'Y', 'N'),
            -- get old value
            -- if l_old_profile_sst_flag is null, the profile is new. There must be
            -- another profile with SST = 'Y'. Set this to 'N'
            nvl(l_old_profile_sst_flag(j), 'N'))),
        decode(l_move_count(j), 1,null,
          -- record corrected/moved
          decode(l_val_status_code(j), null,
            -- not a standardized address, don't end-date new profile
            null,
            -- a standardized address,
            -- if l_old_profile_sst_flag(j) is null, no old profile exists,
            -- don't end-date this one
            -- of  l_old_profile_sst_flag(j) = 'Y', old profile exists and is SST,
            -- end-date it
            -- else it is an updated profile, don't end-date
            decode(l_old_profile_sst_flag(j), 'Y', P_DML_RECORD.SYSDATE, null))),
        P_DML_RECORD.REQUEST_ID,
        P_DML_RECORD.PROGRAM_APPLICATION_ID,
        P_DML_RECORD.PROGRAM_ID,
        P_DML_RECORD.SYSDATE
   from dual
  where l_accept_std_flag(j) is not null
     and (l_move_count(j) = 1 -- record moved
       or ( l_corr_upd_count(j) = 1 -- record corrected/updated
        and ( l_temp_upd_count(j) = 0 -- std loc profile does not exist
           or l_maintain_loc_hist = 'Y' -- to maintain history
            ))));
    end if;

    /* end-date old mosr entries if */
    /* 1) record moved
    /* 2) record corrected and osr change (collision or not) */
    forall j in 1..l_site_id.count
      update hz_orig_sys_references mosr
        set status = 'I',
            last_updated_by = P_DML_RECORD.USER_ID,
            last_update_login = P_DML_RECORD.LAST_UPDATE_LOGIN,
            last_update_date = P_DML_RECORD.SYSDATE,
            end_date_active = P_DML_RECORD.SYSDATE,
            object_version_number = object_version_number + 1
      where status = 'A'
        and orig_system = l_site_orig_system(j)
        and orig_system_reference = l_old_site_osr(j)
        and owner_table_name = 'HZ_PARTY_SITES'
        and ( l_move_count(j) = 1 or
              (l_corr_upd_count(j) = 1 and
              l_site_orig_system_reference(j) <> l_old_site_osr(j)));

    /* insert into hz_locations with user or std data based on accept std flag */
    /* insert if move */
    forall j in 1..l_site_id.count
    insert into hz_locations
    ( LOCATION_ID,
      LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
      CONTENT_SOURCE_TYPE,
      ACTUAL_CONTENT_SOURCE,
      REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE,
      ORIG_SYSTEM_REFERENCE,
      COUNTRY, ADDRESS1, ADDRESS2, ADDRESS3,  ADDRESS4,
      CITY, POSTAL_CODE, STATE, PROVINCE, COUNTY,
      VALIDATED_FLAG,
      ADDRESS_LINES_PHONETIC, POSTAL_PLUS4_CODE, TIMEZONE_ID,
      LOCATION_DIRECTIONS, CLLI_CODE, LANGUAGE,
      SHORT_DESCRIPTION, DESCRIPTION,
      DELIVERY_POINT_CODE,
      SALES_TAX_GEOCODE,
      SALES_TAX_INSIDE_CITY_LIMITS,
      GEOMETRY_STATUS_CODE, OBJECT_VERSION_NUMBER, CREATED_BY_MODULE, APPLICATION_ID,
      VALIDATION_STATUS_CODE, DATE_VALIDATED
    )
    ( select
        l_new_loc_id(j),
        P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.USER_ID,
        'USER_ENTERED',
        P_DML_RECORD.ACTUAL_CONTENT_SRC,        -- ACTUAL_CONTENT_SOURCE
        --'ACS for usr/std data',
        P_DML_RECORD.REQUEST_ID,
        P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID, P_DML_RECORD.SYSDATE,
        l_site_orig_system_reference(j),
        decode(l_accept_std_flag(j), 'Y', l_country_std(j), nvl(l_country(j), l_old_country(j))),
        decode(l_accept_std_flag(j), 'Y', l_addr1_std(j), nvl(l_addr1(j), l_old_addr1(j))),
        decode(l_accept_std_flag(j), 'Y', l_addr2_std(j), nullif(nvl(l_addr2(j), l_old_addr2(j)), P_DML_RECORD.GMISS_CHAR)),
        decode(l_accept_std_flag(j), 'Y', l_addr3_std(j), nullif(nvl(l_addr3(j), l_old_addr3(j)), P_DML_RECORD.GMISS_CHAR)),
        decode(l_accept_std_flag(j), 'Y', l_addr4_std(j), nullif(nvl(l_addr4(j), l_old_addr4(j)), P_DML_RECORD.GMISS_CHAR)),
        decode(l_accept_std_flag(j), 'Y', l_city_std(j), nullif(nvl(l_city(j), l_old_city(j)), P_DML_RECORD.GMISS_CHAR)),
        decode(l_accept_std_flag(j), 'Y', l_postal_code_std(j), nullif(nvl(l_postal_code(j), l_old_postal_code(j)), P_DML_RECORD.GMISS_CHAR)),
        decode(l_accept_std_flag(j), 'Y', decode(l_province(j), null, l_ps_admin_std(j), null), nullif(nvl(l_state(j), l_old_state(j)), P_DML_RECORD.GMISS_CHAR)),
        decode(l_accept_std_flag(j), 'Y', decode(l_province(j), null, null, l_ps_admin_std(j)), nullif(nvl(l_province(j), l_old_province(j)), P_DML_RECORD.GMISS_CHAR)),
        decode(l_accept_std_flag(j), 'Y', l_county_std(j), nullif(nvl(l_county(j), l_old_county(j)), P_DML_RECORD.GMISS_CHAR)),
        'N',
        nullif(nvl(l_addr_phonetic(j), l_old_addr_phonetic(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_postal_plus4(j), l_old_postal_plus4(j)), P_DML_RECORD.GMISS_CHAR),
        decode(l_timezone_code(j), null, l_old_timezone(j), P_DML_RECORD.GMISS_CHAR, null, l_timezone(j)),
        nullif(nvl(l_loc_dir(j), l_old_loc_dir(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_clli_code(j), l_old_clli_code(j)),P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_language(j), l_old_language(j)),P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_short_desc(j), l_old_short_desc(j)),P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_desc(j),l_old_desc(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_delvy_pt_code(j), l_old_delvy_pt_code(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_sales_tax_code(j),l_old_sales_tax_code(j)), P_DML_RECORD.GMISS_CHAR),
        nullif(nvl(l_sales_tax_limit(j),l_old_sales_tax_limit(j)), P_DML_RECORD.GMISS_CHAR),
        'DIRTY', 1,
	    nvl(l_created_by_module(j), 'HZ_IMPORT'),
        P_DML_RECORD.APPLICATION_ID,
        decode(l_accept_std_flag(j), 'Y', l_valid_status_code(j), null),
        decode(l_accept_std_flag(j), 'Y', l_date_validated(j), null)
   from dual
  where l_move_count(j) = 1);

    /* end-date collided entries if */
    /* 1) record moved and collision happens
    /* 2) record corrected and collision happens */
    forall j in 1..l_site_id.count
      update hz_orig_sys_references mosr
        set status = 'I',
            last_updated_by = P_DML_RECORD.USER_ID,
            last_update_login = P_DML_RECORD.LAST_UPDATE_LOGIN,
            last_update_date = P_DML_RECORD.SYSDATE,
            end_date_active = P_DML_RECORD.SYSDATE
            ,--reason_code = 'end-dated mosr',
            object_version_number = object_version_number + 1
      where status = 'A'
        and orig_system = l_site_orig_system(j)
        and orig_system_reference = l_site_orig_system_reference(j)
        and owner_table_name = 'HZ_PARTY_SITES'
        and l_NEW_OSR_EXISTS(j) is not null
        and (l_move_count(j) = 1 or l_corr_upd_count(j) = 1)
        ;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
     FOR k IN 1..l_site_id.count LOOP
       hz_utility_v2pub.debug(p_message=>'end-dating collided mosr(' || k ||'):' || SQL%BULK_ROWCOUNT(k),
			     p_prefix =>l_debug_prefix,
			     p_msg_level=>fnd_log.level_statement);
     END LOOP;
    END IF;

    /* insert new mosr entrues if */
    /* 1) record moved, or */
    /* 2) record corrected and osr change */
    /* insert new mosr entry for new address */
    ForAll j in 1..l_site_id.count
    insert into HZ_ORIG_SYS_REFERENCES
    ( ORIG_SYSTEM_REF_ID,
	  ORIG_SYSTEM,
	  ORIG_SYSTEM_REFERENCE,
	  OWNER_TABLE_NAME,
	  OWNER_TABLE_ID,
	  STATUS,
	  START_DATE_ACTIVE,
	  CREATED_BY,
	  CREATION_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATE_LOGIN,
	  CREATED_BY_MODULE,
	  APPLICATION_ID,
	  OBJECT_VERSION_NUMBER,
          PARTY_ID,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE
    )
    (select
       HZ_ORIG_SYSTEM_REF_S.NEXTVAL,
       l_site_orig_system(j),
       l_site_orig_system_reference(j),
       'HZ_PARTY_SITES',
       decode(l_move_count(j),1,l_new_site_id(j),l_site_id(j)),
       'A',
       P_DML_RECORD.SYSDATE,
       P_DML_RECORD.USER_ID,
       P_DML_RECORD.SYSDATE,
       P_DML_RECORD.USER_ID,
       P_DML_RECORD.SYSDATE,
       P_DML_RECORD.LAST_UPDATE_LOGIN,
       nvl(l_created_by_module(j), 'HZ_IMPORT'),
       P_DML_RECORD.APPLICATION_ID,
       1,
       l_party_id(j),
       P_DML_RECORD.REQUEST_ID,
       P_DML_RECORD.PROGRAM_APPLICATION_ID,
       P_DML_RECORD.PROGRAM_ID,
       P_DML_RECORD.SYSDATE
  from dual
 where ( l_move_count(j) = 1 or
         (l_corr_upd_count(j) = 1 and
          l_site_orig_system_reference(j) <> l_old_site_osr(j)))
     );

    /*                                             */
    /* Perform remaining process for moved records */
    /*                                             */
    /* invalidate old party sites */
    forall j in 1..l_site_id.count
      update hz_party_sites hz_ps
        set program_update_date = P_DML_RECORD.SYSDATE,
            status = 'I',
            last_update_date = P_DML_RECORD.SYSDATE,
            last_updated_by = P_DML_RECORD.USER_ID,
            last_update_login = P_DML_RECORD.LAST_UPDATE_LOGIN,
            object_version_number = object_version_number + 1,
            identifying_address_flag = 'N',
            --CREATED_BY_MODULE = nvl(CREATED_BY_MODULE, decode(l_created_by_module(j), P_DML_RECORD.GMISS_CHAR, CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, l_created_by_module(j))),
            APPLICATION_ID = nvl(APPLICATION_ID, P_DML_RECORD.APPLICATION_ID)
      where hz_ps.party_site_id = l_site_id(j)
        and (l_owning_party_id(j)= l_party_id(j)
            OR l_site_orig_system_reference(j) <> l_old_site_osr(j) )
        and l_move_count(j) = 1;

    /* Reset SST flag of other profiles of other actual content source */
    forall j in 1..l_site_id.count
    update hz_location_profiles
       set validation_sst_flag = 'N',
           object_version_number = object_version_number + 1,
           last_update_date = P_DML_RECORD.SYSDATE,
           last_updated_by = P_DML_RECORD.USER_ID,
           last_update_login = P_DML_RECORD.LAST_UPDATE_LOGIN
     where actual_content_source
           not in ( P_DML_RECORD.ACTUAL_CONTENT_SRC, l_adptr_content_src(j))
       and nullif(effective_end_date, c_end_date) is null
       and location_id = l_location_id(j)
       and l_accept_std_flag(j) = 'Y'
       and (l_allow_std_update = 'Y' or l_val_status_code(j) is null);


    /* DE-NORM */
    /* For corrected address, de-norm the value to hz_parties if         */
    /* 1) it is primary address, and                                     */
    /* 2) it is not standarzed or allowed update to standardized address */

    /* bug fix 3851810   */
    /* If DNB is not selected as a visible data soruce, we should not  */
    /* denormalize it even it is the first active address created for the  */
    /* party. We should only denormalize the visible address. */

    -- check if the data source is seleted.


    /* Commented the code for bug 4079902. */

    /*
    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_LOCATIONS',
      p_entity_attr_id                 => g_pst_entity_attr_id,
      p_mixnmatch_enabled              => g_pst_mixnmatch_enabled,
      p_selected_datasources           => g_pst_selected_datasources );

    g_pst_is_datasource_selected :=
      HZ_MIXNM_UTILITY.isDataSourceSelected (
        p_selected_datasources           => g_pst_selected_datasources,
        p_actual_content_source          => p_dml_record.actual_content_src );

    IF g_pst_is_datasource_selected = 'Y' THEN
    */
      forall j in 1..l_site_id.count
      update hz_parties
        set country = decode(l_accept_std_flag(j), 'Y', l_country_std(j),
                              decode(l_country(j), null, COUNTRY, l_country(j))),
            address1 = decode(l_accept_std_flag(j), 'Y', l_addr1_std(j),
                              decode(l_addr1(j), null, ADDRESS1, l_addr1(j))),
            address2 = decode(l_accept_std_flag(j), 'Y', l_addr2_std(j),
                         decode(l_addr2(j), null, ADDRESS2, P_DML_RECORD.GMISS_CHAR, null, l_addr2(j))),
            address3 = decode(l_accept_std_flag(j), 'Y', l_addr3_std(j),
                         decode(l_addr3(j), null, ADDRESS3, P_DML_RECORD.GMISS_CHAR, null, l_addr3(j))),
            address4 = decode(l_accept_std_flag(j), 'Y', l_addr4_std(j),
                         decode(l_addr4(j), null, ADDRESS4, P_DML_RECORD.GMISS_CHAR, null, l_addr4(j))),
            county = decode(l_accept_std_flag(j), 'Y', l_county_std(j),
                         decode(l_county(j), null, COUNTY, P_DML_RECORD.GMISS_CHAR, null, l_county(j))),
            city = decode(l_accept_std_flag(j), 'Y', l_city_std(j),
                         decode(l_city(j), null, CITY, P_DML_RECORD.GMISS_CHAR, null, l_city(j))),
            postal_code = decode(l_accept_std_flag(j), 'Y', l_postal_code_std(j),
                         decode(l_postal_code(j), null, POSTAL_CODE, P_DML_RECORD.GMISS_CHAR, null, l_postal_code(j))),
            state    = decode(l_accept_std_flag(j), 'Y',
                         decode(l_province(j), null, l_ps_admin_std(j), null),
                         decode(l_state(j), null, STATE, P_DML_RECORD.GMISS_CHAR, null, l_state(j))),
            province = decode(l_accept_std_flag(j), 'Y',
                         decode(l_province(j), null, null, l_ps_admin_std(j)),
                         decode(l_province(j), null, PROVINCE, P_DML_RECORD.GMISS_CHAR, null, l_province(j))),
            object_version_number = object_version_number + 1,
            last_update_date = P_DML_RECORD.SYSDATE,
            last_updated_by = P_DML_RECORD.USER_ID,
            last_update_login = P_DML_RECORD.LAST_UPDATE_LOGIN,
            program_update_date =  P_DML_RECORD.SYSDATE
      where party_id = l_party_id(j)
        and l_ident_addr_flag(j) = 'Y'
        and ( l_move_count(j) = 1 or
             (l_corr_count(j) = 1
               and (l_allow_std_update = 'Y' or l_old_valid_status_code(j) is null)));

   -- END IF;

   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'process_update_addresses()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Update addresses other exception: ' || SQLERRM);

        ROLLBACK to process_update_addresses_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

   end process_update_addresses;


   PROCEDURE report_errors(
     P_DML_RECORD                IN        HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DML_EXCEPTION             IN        VARCHAR2
   ) IS
   num_exp NUMBER;
   exp_ind NUMBER := 1;
   l_debug_prefix VARCHAR2(30) := '';
   begin
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'report_errors()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

     /**********************************/
     /* Validation and Error reporting */
     /**********************************/
     IF l_site_id.count = 0 THEN
       return;
     END IF;

     l_num_row_processed := null;
     l_num_row_processed := NUMBER_COLUMN();
     l_num_row_processed.extend(l_site_id.count);
     l_exception_exists := null;
     l_exception_exists := FLAG_ERROR();
     l_exception_exists.extend(l_site_id.count);
     num_exp := SQL%BULK_EXCEPTIONS.COUNT;

     FOR k IN 1..l_site_id.count LOOP

       IF (l_corr_upd_count(k) <> 0)or
          (l_move_count(k) <> 0) then
         l_num_row_processed(k) := 1;
       else
	 IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'DML fails at ' || k,
			          p_prefix=>'ERROR',
			          p_msg_level=>fnd_log.level_error);
	 END IF;
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
         END IF;
       END IF;
     END LOOP;
  /* insert into tmp error tables */

  forall j in 1..l_site_id.count
    insert into hz_imp_tmp_errors
    (  request_id,
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
       e1_flag,e2_flag,e3_flag,e4_flag,e5_flag,e6_flag,e7_flag,e8_flag,
       e9_flag,/* Bug 4079902 */
       e10_flag,
       e11_flag,
       OTHER_EXCEP_FLAG,
       MISSING_PARENT_FLAG
    )
    (
      select P_DML_RECORD.REQUEST_ID,
             P_DML_RECORD.BATCH_ID,
             l_row_id(j),
             'HZ_IMP_ADDRESSES_INT',
             hz_imp_errors_s.NextVal,
             P_DML_RECORD.SYSDATE,
             P_DML_RECORD.USER_ID,
             P_DML_RECORD.SYSDATE,
             P_DML_RECORD.USER_ID,
             P_DML_RECORD.LAST_UPDATE_LOGIN,
             P_DML_RECORD.PROGRAM_APPLICATION_ID,
             P_DML_RECORD.PROGRAM_ID,
             P_DML_RECORD.SYSDATE,
             v.ACTION_MISMATCH_FLAG,
             v.E1_FLAG,
             v.E2_FLAG,
             v.E3_FLAG,
             v.E4_FLAG,
             v.E5_FLAG,
             v.E6_FLAG,
             v.E7_FLAG,
             v.E8_FLAG,
             v.E9_FLAG,
             v.E10_FLAG,
             v.E11_FLAG,
             v.OTHER_EXCEP_FLAG,
             v.MISSING_PARENT_FLAG
       FROM (
          select
             l_action_error_flag(j) ACTION_MISMATCH_FLAG,
             nvl2(l_error_flag(j), DECODE(l_error_flag(j),3,'Y', null), 'Y') E1_FLAG,  -- e1
             l_address_err(j) E2_FLAG, -- e2
             nvl2(l_country_err(j), 'Y', null) E3_FLAG, -- e3
             nvl2(l_lang_err(j), 'Y', null) E4_FLAG, -- e4
             nvl2(l_timezone_err(j), 'Y', null) E5_FLAG, -- e5
             nvl2(l_flex_val_errors(j),'Y', null) E6_FLAG, -- e6
             decode(l_corr_mv_ind(j), 'C', -- corection only error (e7),
               decode(l_addr_ch_flag(j), 'Y', -- error if correction not allowed
                 decode(l_allow_correction, 'N', null, 'Y'), 'Y'), 'Y') E7_FLAG,
             nvl2(l_error_flag(j), DECODE(l_error_flag(j),2,'Y', null), 'Y') E10_FLAG,  -- e10
             l_exception_exists(j) OTHER_EXCEP_FLAG,
             nvl2(l_owner_table_id(j),'Y',null) MISSING_PARENT_FLAG,
             decode(l_dss_security_errors(j), FND_API.G_TRUE,'Y',null) E8_FLAG, -- e8
             l_third_party_update_error(j) E9_FLAG, --e9
             l_createdby_errors(j) E11_FLAG
           from dual
           where l_num_row_processed(j) = 0
       ) v
       WHERE v.ACTION_MISMATCH_FLAG is null
       OR v.E1_FLAG is null
       OR v.E2_FLAG is null
       OR v.E3_FLAG is null
       OR v.E4_FLAG is null
       OR v.E5_FLAG is null
       OR v.E6_FLAG is null
       OR v.E7_FLAG is null
       OR v.E8_FLAG is null
       OR v.E9_FLAG is null
       OR v.E10_FLAG is null
       OR v.E11_FLAG is null
       OR v.MISSING_PARENT_FLAG is null
       OR v.OTHER_EXCEP_FLAG is not null
    );


    /* Update errored records in interface table */
    -- this update should be performed along with final error table population

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'report_errors()-',
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

PROCEDURE sync_party_tax_profile
  ( P_BATCH_ID                      IN NUMBER,
    P_REQUEST_ID                    IN NUMBER,
    P_ORIG_SYSTEM                   IN VARCHAR2,
    P_FROM_OSR                      IN VARCHAR2,
    P_TO_OSR                        IN VARCHAR2,
    P_BATCH_MODE_FLAG               IN VARCHAR2,
    P_PROGRAM_ID                    IN NUMBER
  )
IS

BEGIN

  -- Import Party Sites
  MERGE INTO ZX_PARTY_TAX_PROFILE PTP
    USING
      (SELECT 'THIRD_PARTY_SITE' PARTY_TYPE_CODE,
        ps.party_site_id PARTY_ID,
       loc.country COUNTRY_CODE,--4742586
        FND_GLOBAL.Login_ID PROGRAM_LOGIN_ID ,
        NULL TAX_REFERENCE,
        SYSDATE CREATION_DATE,
        FND_GLOBAL.User_ID CREATED_BY,
        SYSDATE LAST_UPDATE_DATE,
        FND_GLOBAL.User_ID LAST_UPDATED_BY,
        FND_GLOBAL.Login_ID LAST_UPDATE_LOGIN
      FROM HZ_PARTY_SITES ps, HZ_IMP_ADDRESSES_SG pssg,HZ_LOCATIONS loc, --4742586
           HZ_IMP_ADDRESSES_INT psint
      WHERE loc.request_id = p_request_id --Bug No.4956874.SQLID:14455142
      AND ps.party_site_id = pssg.party_site_id -- Bug 5210879.
     AND  loc.location_id = ps.location_id --4742586
      AND pssg.batch_mode_flag = p_batch_mode_flag
      AND pssg.batch_id = p_batch_id
      AND pssg.party_orig_system = p_orig_system
      AND pssg.party_orig_system_reference BETWEEN p_from_osr AND p_to_osr
      AND psint.rowid=pssg.int_row_id
      AND (psint.interface_status is NULL or psint.interface_status='C')
      ) PTY
    ON (PTY.PARTY_ID = PTP.PARTY_ID AND PTP.PARTY_TYPE_CODE = 'THIRD_PARTY_SITE')
    WHEN MATCHED THEN
      UPDATE SET
        PTP.LAST_UPDATE_DATE=PTY.LAST_UPDATE_DATE,
        PTP.LAST_UPDATED_BY=PTY.LAST_UPDATED_BY,
        PTP.LAST_UPDATE_LOGIN=PTY.LAST_UPDATE_LOGIN,
        PTP.OBJECT_VERSION_NUMBER = PTP.OBJECT_VERSION_NUMBER +1,
        PTP.PROGRAM_ID = P_PROGRAM_ID,
        PTP.REQUEST_ID = P_REQUEST_ID
    WHEN NOT MATCHED THEN
      INSERT (
        PARTY_TYPE_CODE,
        PARTY_TAX_PROFILE_ID,
        PARTY_ID,
        PROGRAM_LOGIN_ID,
        REP_REGISTRATION_NUMBER,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER,
        COUNTRY_CODE,
        REQUEST_ID,
        PROGRAM_ID) --4742586
      VALUES (
        PTY.PARTY_TYPE_CODE,
        ZX_PARTY_TAX_PROFILE_S.NEXTVAL,
        PTY.PARTY_ID,
        PTY.PROGRAM_LOGIN_ID,
        PTY.TAX_REFERENCE,
        PTY.CREATION_DATE,
        PTY.CREATED_BY,
        PTY.LAST_UPDATE_DATE,
        PTY.LAST_UPDATED_BY,
        PTY.LAST_UPDATE_LOGIN,
        1,
        PTY.COUNTRY_CODE,
        P_REQUEST_ID,
        P_PROGRAM_ID);

END sync_party_tax_profile;

END HZ_IMP_LOAD_ADDRESSES_PKG;

/
