--------------------------------------------------------
--  DDL for Package Body POS_SBD_IBY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SBD_IBY_PKG" as
/*$Header: POSIBYB.pls 120.15.12010000.2 2011/01/07 08:52:08 puppulur ship $ */

PROCEDURE remove_iby_temp_account (
  p_iby_temp_ext_bank_account_id IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)

IS
	l_step NUMBER;
BEGIN
  	l_step := 0;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin remove_iby_temp_account ');
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_iby_temp_ext_bank_account_id ' || p_iby_temp_ext_bank_account_id);
	END IF;

  	delete from iby_temp_ext_bank_accts
	where temp_ext_bank_acct_id = p_iby_temp_ext_bank_account_id;


	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End remove_iby_temp_account ');
	END IF;

  l_step := 1;

  x_status      :='S';
  x_exception_msg :=NULL;

EXCEPTION
    WHEN OTHERS THEN
      x_exception_msg := 'Failure at step ' || l_step;
      raise_application_error(-20060, x_exception_msg, true);
END remove_iby_temp_account;

PROCEDURE create_iby_temp_account (
  p_party_id in NUMBER
, p_status in varchar2
, p_owner_primary_flag in varchar2
, p_payment_factor_flag in varchar2
, p_BANK_ID in NUMBER
, p_BANK_NAME in VARCHAR2
, p_BANK_NAME_ALT in varchar2
, p_BANK_NUMBER in VARCHAR2
, p_BANK_INSTITUTION in varchar2
, p_BANK_ADDRESS1 in VARCHAR2
, p_BANK_ADDRESS2 in VARCHAR2
, p_BANK_ADDRESS3 in VARCHAR2
, p_BANK_ADDRESS4 in VARCHAR2
, p_BANK_CITY in VARCHAR2
, p_BANK_COUNTY in VARCHAR2
, p_BANK_STATE in VARCHAR2
, p_BANK_ZIP in VARCHAR2
, p_BANK_PROVINCE in VARCHAR2
, p_BANK_COUNTRY in VARCHAR2
, p_BRANCH_ID in NUMBER
, p_BRANCH_NAME in VARCHAR2
, p_BRANCH_NAME_ALT in varchar2
, p_BRANCH_NUMBER in VARCHAR2
, p_BRANCH_TYPE in varchar2
, p_RFC_IDENTIFIER in varchar2
, p_BIC in varchar2
, p_BRANCH_ADDRESS1 in VARCHAR2
, p_BRANCH_ADDRESS2 in VARCHAR2
, p_BRANCH_ADDRESS3 in VARCHAR2
, p_BRANCH_ADDRESS4 in VARCHAR2
, p_BRANCH_CITY in VARCHAR2
, p_BRANCH_COUNTY in VARCHAR2
, p_BRANCH_STATE in VARCHAR2
, p_BRANCH_ZIP in VARCHAR2
, p_BRANCH_PROVINCE in VARCHAR2
, p_BRANCH_COUNTRY in VARCHAR2
, p_EXT_BANK_ACCOUNT_ID in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_bank_account_name_alt in varchar2
, p_check_digits in varchar2
, p_iban in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, p_FOREIGN_PAYMENT_USE_FLAG in varchar2
, p_bank_account_type in varchar2
, p_account_description in varchar2
, p_end_date in date
, p_start_date in date
, p_agency_location_code in varchar2
, p_account_suffix in varchar2
, p_EXCHANGE_RATE_AGREEMENT_NUM in VARCHAR2
, P_EXCHANGE_RATE_AGREEMENT_TYPE in VARCHAR2
, p_EXCHANGE_RATE in NUMBER
, p_NOTES in VARCHAR2
, p_NOTE_ALT in varchar2
, x_temp_ext_bank_account_id out nocopy NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS
	l_step NUMBER;
 	l_bank_location_rec          hz_location_v2pub.LOCATION_REC_TYPE;
 	l_branch_location_rec          hz_location_v2pub.LOCATION_REC_TYPE;
	l_bank_location_id number;
	l_branch_location_id number;
	l_msg_count NUMBER;

BEGIN
	l_step := 0;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin create_iby_temp_account ');
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_party_id ' || p_party_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_id ' || p_bank_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_id ' || p_branch_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_ext_bank_account_id ' || p_ext_bank_account_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_status ' || p_status);
	END IF;

  	if p_bank_id is null and p_bank_name is not null then

    	POS_SBD_IBY_PKG.create_location (
	  p_ADDRESS1 => p_bank_address1
	, p_ADDRESS2 => p_bank_address2
	, p_ADDRESS3 => p_bank_address3
	, p_ADDRESS4 => p_bank_address4
	, p_CITY     => p_bank_city
	, p_COUNTY   => p_bank_county
	, p_STATE    => p_bank_state
	, p_ZIP      => p_bank_zip
	, p_PROVINCE => p_bank_province
	, p_COUNTRY  => p_country_code
        , x_location_id => l_bank_location_id
	, x_status   => x_status
	, x_exception_msg => x_exception_msg);

	end if;

	l_step := 1;

	if p_branch_id is null and p_branch_name is not null then

    	POS_SBD_IBY_PKG.create_location (
	  p_ADDRESS1 => p_branch_address1
	, p_ADDRESS2 => p_branch_address2
	, p_ADDRESS3 => p_branch_address3
	, p_ADDRESS4 => p_branch_address4
	, p_CITY     => p_branch_city
	, p_COUNTY   => p_branch_county
	, p_STATE    => p_branch_state
	, p_ZIP      => p_branch_zip
	, p_PROVINCE => p_branch_province
	, p_COUNTRY  => p_country_code
	, x_location_id => l_branch_location_id
	, x_status   => x_status
	, x_exception_msg => x_exception_msg);

	end if;

	l_step := 2;

    	select IBY_TEMP_EXT_BANK_ACCTS_S.nextval into x_temp_ext_bank_account_id from dual;

    	insert into iby_temp_ext_bank_accts
    	(
	     temp_ext_bank_acct_id
	   , status
	   , account_owner_party_id
	   , owner_primary_flag
	   , payment_factor_flag
	   , request_id
	   , program_application_id
	   , program_id
	   , program_update_date
	   , object_version_number
	   , creation_date
	   , created_by
	   , last_update_date
	   , last_updated_by
	   , last_update_login
	   , BANK_ID
	   , BANK_NAME
	   , BANK_NAME_ALT
	   , BANK_NUMBER
	   , BANK_INSTITUTION_TYPE
	   , BANK_ADDRESS_ID
	   , BRANCH_ID
  	   , BRANCH_NAME
	   , BRANCH_NAME_ALT
	   , BRANCH_NUMBER
	   , BRANCH_TYPE
	   , RFC_IDENTIFIER
	   , BIC
	   , BRANCH_ADDRESS_ID
	   , EXT_BANK_ACCOUNT_ID
	   , bank_account_num
	   , bank_account_name
	   , bank_account_name_alt
	   , check_digits
	   , iban
	   , currency_code
	   , FOREIGN_PAYMENT_USE_FLAG
	   , bank_account_type
	   , country_code
	   , description
	   , end_date
	   , start_date
	   , agency_location_code
	   , account_suffix
	   , EXCHANGE_RATE_AGREEMENT_NUM
	   , EXCHANGE_RATE_AGREEMENT_TYPE
	   , EXCHANGE_RATE
	   , NOTE
	   , NOTE_ALT
	  )
	  values
	  (
	     x_temp_ext_bank_account_id
	   , p_status
	   , p_party_id
	   , p_owner_primary_flag
	   , p_payment_factor_flag
	   , null
	   , 177
	   , 177
	   , sysdate
	   , 1
	   , sysdate
	   , fnd_global.user_id
	   , sysdate
	   , fnd_global.user_id
	   , fnd_global.login_id
	   , p_BANK_ID
	   , p_BANK_NAME
	   , p_BANK_NAME_ALT
	   , p_BANK_NUMBER
	   , p_BANK_INSTITUTION
	   , l_bank_location_id
	   , p_BRANCH_ID
	   , p_BRANCH_NAME
	   , p_BRANCH_NAME_ALT
	   , p_BRANCH_NUMBER
	   , p_BRANCH_TYPE
	   , p_RFC_IDENTIFIER
	   , p_BIC
	   , l_branch_location_id
	   , p_EXT_BANK_ACCOUNT_ID
	   , p_bank_account_number
	   , p_bank_account_name
	   , p_bank_account_name_alt
	   , p_check_digits
	   , p_iban
	   , p_currency_code
	   , p_FOREIGN_PAYMENT_USE_FLAG
	   , p_bank_account_type
	   , p_country_code
	   , p_account_description
	   , p_end_date
	   , p_start_date
	   , p_agency_location_code
	   , p_account_suffix
	   , p_EXCHANGE_RATE_AGREEMENT_NUM
	   , p_EXCHANGE_RATE_AGREEMENT_TYPE
	   , p_EXCHANGE_RATE
	   , p_NOTES
	   , p_NOTE_ALT
	  );

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End create_iby_temp_account ');
	END IF;

  	l_step := 3;

	x_status      :='S';
	x_exception_msg :=NULL;

EXCEPTION
    WHEN OTHERS THEN
	x_exception_msg := 'Failure at step ' || l_step;
      	raise_application_error(-20061, x_exception_msg, true);
END create_iby_temp_account;


/* This procedure updates the iby temp account on buyer's request.
 *
 */
PROCEDURE update_iby_temp_account (
  p_temp_ext_bank_acct_id in number
, p_party_id in NUMBER
, p_status in varchar2
, p_owner_primary_flag in varchar2
, p_payment_factor_flag in varchar2
, p_BANK_ID in NUMBER
, p_BANK_NAME in VARCHAR2
, p_BANK_NAME_ALT in varchar2
, p_BANK_NUMBER in VARCHAR2
, p_BANK_INSTITUTION in varchar2
, p_BANK_ADDRESS1 in VARCHAR2
, p_BANK_ADDRESS2 in VARCHAR2
, p_BANK_ADDRESS3 in VARCHAR2
, p_BANK_ADDRESS4 in VARCHAR2
, p_BANK_CITY in VARCHAR2
, p_BANK_COUNTY in VARCHAR2
, p_BANK_STATE in VARCHAR2
, p_BANK_ZIP in VARCHAR2
, p_BANK_PROVINCE in VARCHAR2
, p_BANK_COUNTRY in VARCHAR2
, p_BRANCH_ID in NUMBER
, p_BRANCH_NAME in VARCHAR2
, p_BRANCH_NAME_ALT in varchar2
, p_BRANCH_NUMBER in VARCHAR2
, p_BRANCH_TYPE in varchar2
, p_RFC_IDENTIFIER in varchar2
, p_BIC in varchar2
, p_BRANCH_ADDRESS1 in VARCHAR2
, p_BRANCH_ADDRESS2 in VARCHAR2
, p_BRANCH_ADDRESS3 in VARCHAR2
, p_BRANCH_ADDRESS4 in VARCHAR2
, p_BRANCH_CITY in VARCHAR2
, p_BRANCH_COUNTY in VARCHAR2
, p_BRANCH_STATE in VARCHAR2
, p_BRANCH_ZIP in VARCHAR2
, p_BRANCH_PROVINCE in VARCHAR2
, p_BRANCH_COUNTRY in VARCHAR2
, p_EXT_BANK_ACCOUNT_ID in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_bank_account_name_alt in varchar2
, p_check_digits in varchar2
, p_iban in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, p_FOREIGN_PAYMENT_USE_FLAG in varchar2
, p_bank_account_type in varchar2
, p_account_description in varchar2
, p_end_date in date
, p_start_date in date
, p_agency_location_code in varchar2
, p_account_suffix in varchar2
, p_EXCHANGE_RATE_AGREEMENT_NUM in VARCHAR2
, p_exchange_rate_agreement_type in VARCHAR2
, p_EXCHANGE_RATE in NUMBER
, p_NOTES in VARCHAR2
, p_NOTE_ALT in varchar2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS
 	l_step NUMBER;
	l_bank_location_id number;
	l_branch_location_id number;
 	l_msg_count NUMBER;

	cursor l_bank_branch_loc_cur is
 	select iby.bank_address_id, iby.branch_address_id
  	into l_bank_location_id, l_branch_location_id
  	from iby_temp_ext_bank_accts iby
  	where temp_ext_bank_acct_id = p_temp_ext_bank_acct_id;

BEGIN
  	l_step := 0;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin update_iby_temp_account ');
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_temp_ext_account_id ' || p_temp_ext_bank_acct_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_party_id ' || p_party_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_id ' || p_bank_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_id ' || p_branch_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_ext_bank_account_id ' || p_ext_bank_account_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_status ' || p_status);
	END IF;

  	open l_bank_branch_loc_cur;
  	fetch l_bank_branch_loc_cur into l_bank_location_id, l_branch_location_id;
  	close l_bank_branch_loc_cur;

  	l_step := 1;

  	if p_bank_id is null then

    		if l_bank_location_id is not null then

			if p_country_code is null OR p_bank_address1 is null then

				l_bank_location_id := null;

			else

			    	POS_SBD_IBY_PKG.update_location (
	  			  p_location_id => l_bank_location_id
				, p_ADDRESS1 => p_bank_address1
				, p_ADDRESS2 => p_bank_address2
				, p_ADDRESS3 => p_bank_address3
				, p_ADDRESS4 => p_bank_address4
				, p_CITY     => p_bank_city
				, p_COUNTY   => p_bank_county
				, p_STATE    => p_bank_state
				, p_ZIP      => p_bank_zip
				, p_PROVINCE => p_bank_province
				, p_COUNTRY  => p_country_code
				, x_status   => x_status
				, x_exception_msg => x_exception_msg);
			end if;

    		else

			if p_country_code is null OR p_bank_address1 is null then
				l_bank_location_id := null;
			else
		    		POS_SBD_IBY_PKG.create_location (
				  p_ADDRESS1 => p_bank_address1
				, p_ADDRESS2 => p_bank_address2
				, p_ADDRESS3 => p_bank_address3
				, p_ADDRESS4 => p_bank_address4
				, p_CITY     => p_bank_city
				, p_COUNTY   => p_bank_county
				, p_STATE    => p_bank_state
				, p_ZIP      => p_bank_zip
				, p_PROVINCE => p_bank_province
				, p_COUNTRY  => p_country_code
			        , x_location_id => l_bank_location_id
				, x_status   => x_status
				, x_exception_msg => x_exception_msg);
			end if;

    		end if;
  	end if;

  	l_step := 2;

  	if p_branch_id is null then

   		if l_branch_location_id is not null then

			if p_country_code is null OR p_branch_address1 is null then

				l_branch_location_id := null;

			else

    				POS_SBD_IBY_PKG.update_location (
				  p_location_id => l_branch_location_id
				, p_ADDRESS1 => p_branch_address1
				, p_ADDRESS2 => p_branch_address2
				, p_ADDRESS3 => p_branch_address3
				, p_ADDRESS4 => p_branch_address4
				, p_CITY     => p_branch_city
				, p_COUNTY   => p_branch_county
				, p_STATE    => p_branch_state
				, p_ZIP      => p_branch_zip
				, p_PROVINCE => p_branch_province
				, p_COUNTRY  => p_country_code
				, x_status   => x_status
				, x_exception_msg => x_exception_msg);
			end if;

   		else

			if p_country_code is null OR p_branch_address1 is null then

				l_branch_location_id := null;

			else

  		  		POS_SBD_IBY_PKG.create_location (
	 	       	 	  p_ADDRESS1 => p_branch_address1
				, p_ADDRESS2 => p_branch_address2
				, p_ADDRESS3 => p_branch_address3
				, p_ADDRESS4 => p_branch_address4
				, p_CITY     => p_branch_city
				, p_COUNTY   => p_branch_county
				, p_STATE    => p_branch_state
				, p_ZIP      => p_branch_zip
				, p_PROVINCE => p_branch_province
				, p_COUNTRY  => p_country_code
				, x_location_id => l_branch_location_id
				, x_status   => x_status
				, x_exception_msg => x_exception_msg);
			end if;

  		end if;
	end if;

 	l_step := 3;

	update iby_temp_ext_bank_accts set
	     status = p_status
	   , account_owner_party_id = p_party_id
	   , owner_primary_flag = p_owner_primary_flag
	   , payment_factor_flag = p_payment_factor_flag
	   , last_update_date = sysdate
	   , last_updated_by = fnd_global.user_id
	   , last_update_login = fnd_global.login_id
	   , BANK_ID = p_bank_id
	   , BANK_NAME = p_bank_name
	   , BANK_NAME_ALT = p_bank_name_alt
	   , BANK_NUMBER = p_bank_number
	   , BANK_INSTITUTION_TYPE = p_bank_institution
	   , BANK_ADDRESS_ID = l_bank_location_id
	   , BRANCH_ID = p_branch_id
	   , BRANCH_NAME = p_branch_name
	   , BRANCH_NAME_ALT = p_branch_name_alt
	   , BRANCH_NUMBER = p_branch_number
	   , BRANCH_TYPE = p_branch_type
	   , RFC_IDENTIFIER = p_rfc_identifier
	   , BIC = p_bic
	   , BRANCH_ADDRESS_ID = l_branch_location_id
	   , EXT_BANK_ACCOUNT_ID = nvl(p_ext_bank_account_id, ext_bank_account_id)
	   , bank_account_num = p_bank_account_number
	   , bank_account_name = p_bank_account_name
	   , bank_account_name_alt = p_bank_account_name_alt
	   , check_digits = p_check_digits
	   , iban = p_iban
	   , currency_code = p_currency_code
	   , FOREIGN_PAYMENT_USE_FLAG = p_foreign_payment_use_flag
	   , bank_account_type = p_bank_account_type
	   , country_code = p_country_code
	   , description = p_account_description
	   , end_date = p_end_date
	   , start_date = p_start_date
	   , agency_location_code = p_agency_location_code
	   , account_suffix = p_account_suffix
	   , EXCHANGE_RATE_AGREEMENT_NUM = p_exchange_rate_agreement_num
	   , EXCHANGE_RATE_AGREEMENT_TYPE = p_exchange_rate_agreement_type
	   , EXCHANGE_RATE = p_exchange_rate
	   , NOTE = p_notes
	   , NOTE_ALT = p_note_alt
	   where temp_ext_bank_acct_id = p_temp_ext_bank_acct_id;

	l_step := 4;

  	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End update_iby_temp_account ');
	END IF;

  	x_status      :='S';
  	x_exception_msg :=NULL;

EXCEPTION
    WHEN OTHERS THEN
      	raise_application_error(-20062, 'Failure at step ' || l_step || Sqlerrm, true);
END update_iby_temp_account;

/* This procedure creates the location.
 *
 */
PROCEDURE create_location (
  p_ADDRESS1 in VARCHAR2
, p_ADDRESS2 in VARCHAR2
, p_ADDRESS3 in VARCHAR2
, p_ADDRESS4 in VARCHAR2
, p_CITY in VARCHAR2
, p_COUNTY in VARCHAR2
, p_STATE in VARCHAR2
, p_ZIP in VARCHAR2
, p_PROVINCE in VARCHAR2
, p_COUNTRY in VARCHAR2
, x_location_id out nocopy number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

	l_step number;
	l_msg_count number;
	l_location_rec hz_location_v2pub.LOCATION_REC_TYPE;

BEGIN

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin create_location ');
	END IF;

	if p_country is not null and p_address1 is not null then
	    l_location_rec.country := p_country;
	    l_location_rec.address1 := p_address1;
	    l_location_rec.address2 := p_address2;
	    l_location_rec.address3 := p_address3;
	    l_location_rec.address4 := p_address4;
	    l_location_rec.city := p_city;
	    l_location_rec.postal_code := p_zip;
	    l_location_rec.state := p_state;
	    l_location_rec.province := p_province;
	    l_location_rec.country := p_country;
	    l_location_rec.county := p_county;

	    l_location_rec.created_by_module := 'POS_SUPPLIER_MGMT';
	    l_location_rec.application_id := 177;

	    hz_location_v2pub.create_location (
	        p_init_msg_list => fnd_api.g_true,
	        p_location_rec  => l_location_rec,
	        x_location_id   => x_location_id,
	        x_return_status => x_status,
	        x_msg_count => l_msg_count,
	        x_msg_data => x_exception_msg);
	else
		x_status := 'S';
	end if;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End create_location ');
	END IF;


EXCEPTION
    WHEN OTHERS THEN
	raise_application_error(-20063, 'Create location failure', true);
END create_location;



/* This procedure updates the location.
 *
 */
PROCEDURE update_location (
  p_location_id in NUMBER
, p_ADDRESS1 in VARCHAR2
, p_ADDRESS2 in VARCHAR2
, p_ADDRESS3 in VARCHAR2
, p_ADDRESS4 in VARCHAR2
, p_CITY in VARCHAR2
, p_COUNTY in VARCHAR2
, p_STATE in VARCHAR2
, p_ZIP in VARCHAR2
, p_PROVINCE in VARCHAR2
, p_COUNTRY in VARCHAR2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

	l_step number;
	l_msg_count number;
	l_obj_ver HZ_LOCATIONS.object_version_number%TYPE;
	l_created_by_module HZ_PARTY_SITES.created_by_module%TYPE;
	l_location_rec hz_location_v2pub.LOCATION_REC_TYPE;

BEGIN

	l_step := 0;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin update_location ');
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_location_id ' || p_location_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_country ' || p_country);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_address1 ' || p_address1);
	END IF;

	select object_version_number, created_by_module
    	into l_obj_ver, l_created_by_module from hz_locations
    	where location_id = p_location_id;

	l_step := 1;

   	l_location_rec.location_id := p_location_id;
    	l_location_rec.country := p_country;
    	l_location_rec.address1 := p_address1;

    	if p_address2 is not null then l_location_rec.address2 := p_address2;
    	else l_location_rec.address2 := FND_API.G_MISS_CHAR;
    	end if;

    	if p_address3 is not null then l_location_rec.address3 := p_address3;
    	else l_location_rec.address3 :=  FND_API.G_MISS_CHAR;
    	end if;

    	if p_address4 is not null then l_location_rec.address4 := p_address4;
    	else l_location_rec.address4 :=  FND_API.G_MISS_CHAR;
    	end if;

    	l_location_rec.city := p_city;
    	l_location_rec.postal_code := p_zip;

    	if p_state is not null then l_location_rec.state := p_state;
    	else l_location_rec.state :=  FND_API.G_MISS_CHAR;
    	end if;

    	if p_province is not null then l_location_rec.province := p_province;
    	else l_location_rec.province :=  FND_API.G_MISS_CHAR;
    	end if;

    	if p_county is not null then l_location_rec.county := p_county;
    	else l_location_rec.county :=  FND_API.G_MISS_CHAR;
    	end if;

    	l_location_rec.created_by_module := l_created_by_module;
    	l_location_rec.application_id := 177;
    	hz_location_v2pub.update_location (
        	p_init_msg_list => fnd_api.g_true,
        	p_location_rec  => l_location_rec,
        	p_object_version_number   => l_obj_ver,
        	x_return_status => x_status,
        	x_msg_count => l_msg_count,
        	x_msg_data => x_exception_msg
    	);

	l_step := 2;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End update_location ');
	END IF;

EXCEPTION
    WHEN OTHERS THEN
      x_exception_msg := 'Failure at step ' || l_step;
      raise_application_error(-20065, x_exception_msg, true);
END update_location;


PROCEDURE validate_account (
  p_mapping_id in NUMBER
-- Bank
, p_BANK_ID in NUMBER
, p_BANK_NAME in VARCHAR2
, p_BANK_NAME_ALT in varchar2
, p_BANK_NUMBER in VARCHAR2
, p_BANK_INSTITUTION in varchar2
, p_BANK_ADDRESS1 in VARCHAR2
, p_BANK_ADDRESS2 in VARCHAR2
, p_BANK_ADDRESS3 in VARCHAR2
, p_BANK_ADDRESS4 in VARCHAR2
, p_BANK_CITY in VARCHAR2
, p_BANK_COUNTY in VARCHAR2
, p_BANK_STATE VARCHAR2
, p_BANK_ZIP in VARCHAR2
, p_BANK_PROVINCE in VARCHAR2
, p_BANK_COUNTRY in VARCHAR2
-- Branch
, p_BRANCH_ID in NUMBER
, p_BRANCH_NAME in VARCHAR2
, p_BRANCH_NAME_ALT in varchar2
, p_BRANCH_NUMBER in VARCHAR2
, p_BRANCH_TYPE in varchar2
, p_RFC_IDENTIFIER in varchar2
, p_BIC in varchar2
, p_BRANCH_ADDRESS1 in VARCHAR2
, p_BRANCH_ADDRESS2 in VARCHAR2
, p_BRANCH_ADDRESS3 in VARCHAR2
, p_BRANCH_ADDRESS4 in VARCHAR2
, p_BRANCH_CITY in VARCHAR2
, p_BRANCH_COUNTY in VARCHAR2
, p_BRANCH_STATE VARCHAR2
, p_BRANCH_ZIP in VARCHAR2
, p_BRANCH_PROVINCE in VARCHAR2
, p_BRANCH_COUNTRY in VARCHAR2
-- Account
, p_EXT_BANK_ACCOUNT_ID in number
, p_account_request_id in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_bank_account_name_alt in varchar2
, p_check_digits in varchar2
, p_iban in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, p_FOREIGN_PAYMENT_USE_FLAG in varchar2
, p_bank_account_type in varchar2
, p_account_description in varchar2
, p_end_date in date
, p_start_date in date
, p_agency_location_code in varchar2
, p_account_suffix in varchar2
, p_EXCHANGE_RATE_AGREEMENT_NUM in VARCHAR2
, P_EXCHANGE_RATE_AGREEMENT_TYPE in VARCHAR2
, p_EXCHANGE_RATE in NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)

IS

	l_ext_bank_rec            IBY_EXT_BANKACCT_PUB.ExtBank_rec_type;
	l_ext_bank_branch_rec     IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type;
 	l_ext_bank_acct_rec       IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type;
 	l_result_rec              IBY_FNDCPT_COMMON_PUB.Result_rec_type;
 	l_msg_count number;
 	l_step number;
	l_temp_bank_account_num IBY_EXT_BANK_ACCOUNTS.BANK_ACCOUNT_NUM%TYPE;

 	cursor l_party_id_cur is
 	select party_id from pos_supplier_mappings where mapping_id = p_mapping_id;
 	l_party_id number;

 	l_need_validation varchar2(1);

 	l_create_flag varchar2(1);
BEGIN

   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin validate_account ');
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_mapping_id ' || p_mapping_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_id ' || p_bank_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_id ' || p_branch_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_name ' || p_bank_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_name ' || p_branch_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_number ' || p_bank_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_number ' || p_branch_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_account_number ' || p_bank_account_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_account_name ' || p_bank_account_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_currency_code ' || p_currency_code);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_country_code ' || p_country_code);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_iban ' || p_iban);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_check_digits ' || p_check_digits);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_ext_bank_account_id ' || p_ext_bank_account_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_account_request_ud ' || p_account_request_id);
	END IF;

	l_step := 0;

	-- Drop all the error message stack.
	FND_MSG_PUB.initialize;

    	open l_party_id_cur;
    	fetch l_party_id_cur into l_party_id;
    	close l_party_id_cur;

	l_step := 1;

	POS_SBD_IBY_PKG.check_for_duplicates (
	  p_mapping_id => p_mapping_id
	, p_BANK_ID => p_bank_id
	, p_BANK_NAME => p_bank_name
	, p_BANK_NUMBER => p_bank_number
	, p_BRANCH_ID => p_branch_id
	, p_BRANCH_NAME => p_branch_name
	, p_BRANCH_NUMBER => p_branch_number
	, p_EXT_BANK_ACCOUNT_ID => p_ext_bank_account_id
	, p_bank_account_number => p_bank_account_number
	, p_bank_account_name  => p_bank_account_name
	, p_currency_code => p_currency_code
	, p_country_code => p_country_code
	, p_account_request_id => p_account_request_id
	, x_need_validation => l_need_validation
	, x_status        => x_status
	, x_exception_msg => x_exception_msg);

	l_step := 2;

    	if x_status <> 'S' then
		return;
    	end if;

	l_step := 3;

    	if l_need_validation = 'Y' then

	    	l_step := 4;
	    	l_ext_bank_rec.bank_id	       := p_bank_id;
	    	l_ext_bank_rec.bank_name                   := p_bank_name;
	    	l_ext_bank_rec.bank_number                 := p_bank_number;
	   	l_ext_bank_rec.institution_type            := p_bank_institution;
	    	l_ext_bank_rec.country_code                := p_country_code;
	    	l_ext_bank_rec.bank_alt_name               := p_bank_name_alt;

		l_step := 5;
		l_ext_bank_branch_rec.branch_party_id      := p_branch_id;
    		l_ext_bank_branch_rec.branch_name          := p_branch_name;
    		l_ext_bank_branch_rec.branch_number        := p_branch_number;
    		l_ext_bank_branch_rec.branch_type	       := p_branch_type;
    		l_ext_bank_branch_rec.alternate_branch_name := p_branch_name_alt;
    		l_ext_bank_branch_rec.bic                  := p_bic;
    		l_ext_bank_branch_rec.rfc_identifier       := p_rfc_identifier;

    		l_step := 6;
    		l_ext_bank_acct_rec.bank_account_id	       := p_EXT_BANK_ACCOUNT_ID;
    		l_ext_bank_acct_rec.country_code	       := p_country_code;
    		l_ext_bank_acct_rec.branch_id	       := p_branch_id;
    		l_ext_bank_acct_rec.bank_id		       := p_bank_id;
    		l_ext_bank_acct_rec.acct_owner_party_id    := l_party_id;
    		l_ext_bank_acct_rec.bank_account_name      := p_bank_account_name;

		/* BUG 10384712 START */

		IF p_EXT_BANK_ACCOUNT_ID IS NOT NULL THEN

		SELECT BANK_ACCOUNT_NUM INTO l_temp_bank_account_num
		FROM
		IBY_EXT_BANK_ACCOUNTS
		WHERE
                EXT_BANK_ACCOUNT_ID=p_EXT_BANK_ACCOUNT_ID;

                l_ext_bank_acct_rec.bank_account_num       := l_temp_bank_account_num;
		ELSE
                l_ext_bank_acct_rec.bank_account_num       := p_bank_account_number;
		END IF;

		/* BUG 10384712 END */

    		l_ext_bank_acct_rec.currency	       := p_currency_code;
    		l_ext_bank_acct_rec.iban		       := p_iban;
    		l_ext_bank_acct_rec.check_digits	       := p_check_digits;
    		l_ext_bank_acct_rec.alternate_acct_name    := p_bank_account_name_alt;
    		l_ext_bank_acct_rec.acct_type	       := p_bank_account_type;
    		l_ext_bank_acct_rec.acct_suffix	       := p_account_suffix;
    		l_ext_bank_acct_rec.agency_location_code   := p_agency_location_code;
   		l_ext_bank_acct_rec.foreign_payment_use_flag := p_foreign_payment_use_flag;
    		l_ext_bank_acct_rec.exchange_rate_agreement_num := p_exchange_rate_agreement_num;
    		l_ext_bank_acct_rec.exchange_rate_agreement_type := p_exchange_rate_agreement_type;
    		l_ext_bank_acct_rec.exchange_rate	       := p_exchange_rate;
    		l_ext_bank_acct_rec.payment_factor_flag    := 'Y';
    		l_ext_bank_acct_rec.end_date               := p_end_date;
    		l_ext_bank_acct_rec.START_DATE             := p_start_date;

    		l_step := 7;

    		if p_ext_bank_account_id is null then
			l_create_flag := FND_API.G_TRUE;
    		else
			l_create_flag := FND_API.G_FALSE;
    		end if;

    		IBY_EXT_BANKACCT_VALIDATIONS.iby_validate_account(
    		p_api_version             => 1.0,
    		p_init_msg_list           => FND_API.G_TRUE,
    		p_create_flag             => l_create_flag,
    		p_ext_bank_rec            => l_ext_bank_rec,
    		p_ext_bank_branch_rec     => l_ext_bank_branch_rec,
   		p_ext_bank_acct_rec       => l_ext_bank_acct_rec,
    		x_return_status           => x_status,
    		x_msg_count               => l_msg_count,
    		x_msg_data                => x_exception_msg,
    		x_response                => l_result_rec
    		);

   		IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' IBY API Validation Status ' || x_status);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' IBY API Validation msg count ' || l_msg_count);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' IBY API Validation exception msg ' || x_exception_msg);
		END IF;

    		l_step := 8;

    	end if;

   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End validate_account ');
	END IF;

EXCEPTION
    WHEN OTHERS THEN
      	x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      	raise_application_error(-20066, x_exception_msg, true);
END validate_account;

PROCEDURE assign_site_to_account (
  p_temp_ext_bank_account_id in number
, p_vendor_site_id in number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)

IS

	l_msg_count number;
	l_step number;

	CURSOR l_temp_account_cur is
	select temp.ext_bank_account_id, temp.account_owner_party_id
	from IBY_TEMP_EXT_BANK_ACCTS temp
	where temp.temp_ext_bank_acct_id = p_temp_ext_bank_account_id;

	l_temp_account_rec l_temp_account_cur%ROWTYPE;
	l_result_rec              IBY_FNDCPT_COMMON_PUB.Result_rec_type;
	l_ext_bank_account_id IBY_TEMP_EXT_BANK_ACCTS.ext_bank_account_id%TYPE;
	l_payee_rec               IBY_DISBURSEMENT_SETUP_PUB.PayeeContext_Rec_Type;
	l_pay_instr_rec           IBY_FNDCPT_SETUP_PUB.PmtInstrument_rec_type;
	l_pay_assign_rec          IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
	l_party_id number;
	L_PAYEE_ASSIGNMENT_ID number;

	cursor l_site_detail_cur is
	select org_id, party_site_id from ap_supplier_sites_all where
	vendor_site_id = p_vendor_site_id;
	l_party_site_id number;
	l_org_id number;

	cursor l_max_p_cur is
	select max(uses.order_of_preference)
	from iby_pmt_instr_uses_all uses, iby_external_payees_all payee,
	iby_ext_bank_accounts act, ap_supplier_sites_all pvsa
	where uses.instrument_type = 'BANKACCOUNT'
	AND sysdate between NVL(act.start_date,sysdate) AND NVL(act.end_date,sysdate)
	and payee.ext_payee_id = uses.ext_pmt_party_id
	and payee.org_id = pvsa.org_id
	and payee.party_site_id = pvsa.party_site_id
	and org_type = 'OPERATING_UNIT'
	and pvsa.vendor_site_id = payee.supplier_site_id
	and payee.supplier_site_id  = p_vendor_site_id
	and uses.instrument_id = act.ext_bank_account_id
	and payee.payee_party_id = l_party_id
	and payee.party_site_id is null;

	l_priority number;

	cursor l_payee_cur is
	select payee.object_version_number, payee.ext_payee_id from iby_external_payees_all payee
	where payee.ext_payee_id = l_party_id
	and payee.org_id is null
	and payee.party_site_id is null
	and payee.supplier_site_id  = p_vendor_site_id;
	l_cur_payee_rec l_payee_cur%ROWTYPE;

	cursor l_payee_assignment_cur is
	select uses.object_version_number
	from iby_external_payees_all payee, iby_pmt_instr_uses_all uses
	where payee.ext_payee_id = l_party_id
	and payee.org_id is null
	and payee.party_site_id is null
	and payee.supplier_site_id  = p_vendor_site_id
	and payee.ext_payee_id = uses.ext_pmt_party_id
	and uses.instrument_id = l_ext_bank_account_id
	and uses.instrument_type = 'BANKACCOUNT';

	l_cur_payee_assign_rec l_payee_assignment_cur%ROWTYPE;


BEGIN

	l_step := 0;
   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin assign_site_to_account ');
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_vendor_site_id ' || p_vendor_site_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_temp_ext_bank_account_id ' || p_temp_ext_bank_account_id);
	END IF;

	l_step := 1;

	for l_temp_account_rec in l_temp_account_cur loop

		l_ext_bank_account_id := l_temp_account_rec.ext_bank_account_id;
		l_party_id := l_temp_account_rec.account_owner_party_id;

		l_step := 3;

		open l_max_p_cur;
		fetch l_max_p_cur into l_priority;
		close l_max_p_cur;

		l_step := 4;

		if l_priority is null then
			l_priority := 1;
		else
			l_priority := l_priority + 1;
		end if;

		open l_site_detail_cur;
		fetch l_site_detail_cur into l_org_id, l_party_site_id;
		close l_site_detail_cur;

		l_step := 5;
       		l_payee_rec.Payment_Function := 'PAYABLES_DISB';
       		l_payee_rec.Party_id := l_party_id;
        	l_payee_rec.Party_Site_id := l_party_site_id;
        	l_payee_rec.org_Id := l_org_id;
        	l_payee_rec.Supplier_Site_id := p_vendor_site_id;
        	l_payee_rec.Org_Type := 'OPERATING_UNIT';

        	l_pay_instr_rec.Instrument_Type := 'BANKACCOUNT';
        	l_pay_instr_rec.Instrument_Id := l_ext_bank_account_id;

        	l_pay_assign_rec.Instrument := l_pay_instr_rec;
        	l_pay_assign_rec.Priority := l_priority;
        	l_pay_assign_rec.Start_Date := sysdate;
        	l_pay_assign_rec.End_Date := null;

		l_step := 6;

		IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Calling Set_Payee_Instr_Assignment ');
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_payee_rec.Party_id ' || l_payee_rec.Party_id);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_payee_rec.Payment_Function ' || l_payee_rec.Payment_Function);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_payee_rec.Supplier_Site_id ' || l_payee_rec.Supplier_Site_id);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_pay_instr_rec.Instrument_Type ' || l_pay_instr_rec.Instrument_Type);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_pay_instr_rec.Instrument_Id ' || l_pay_instr_rec.Instrument_Id);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_pay_assign_rec.Priority ' || l_pay_assign_rec.Priority);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_pay_assign_rec.Start_Date ' || l_pay_assign_rec.Start_Date );
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_pay_assign_rec.End_Date ' || l_pay_assign_rec.End_Date);
		END IF;

        	IBY_DISBURSEMENT_SETUP_PUB.Set_Payee_Instr_Assignment(
          	p_api_version      => 1.0,
           	p_init_msg_list    => FND_API.G_FALSE,
           	p_commit           => FND_API.G_FALSE,
           	x_return_status    => x_status,
           	x_msg_count        => l_msg_count,
           	x_msg_data         => x_exception_msg,
           	p_payee            => l_payee_rec,
          	p_assignment_attribs => l_pay_assign_rec,
           	x_assign_id        => l_payee_assignment_id,
          	x_response         => l_result_rec
        	);
		l_step := 7;

		IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' After Set_Payee_Instr_Assignment ');
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_return_status ' || x_status);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_msg_count ' || l_msg_count);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_msg_data ' || x_exception_msg);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_assign_id ' || l_payee_assignment_id);
		END IF;

		if l_payee_assignment_id is null OR x_status is null OR x_status <> 'S' then
		l_step := 8;
		raise_application_error(-20084, 'IBY Failed to create assignment ' || x_exception_msg, true);
		end if;

	end loop;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' END assign_site_to_account ');
	END IF;

EXCEPTION
    WHEN OTHERS THEN
	x_status := 'E';
	x_exception_msg := 'Failure at step ' || l_step;
      	raise_application_error(-20067, x_exception_msg, true);
END assign_site_to_account;


PROCEDURE prenote_iby_temp_account (
  p_temp_ext_bank_account_id in number
, p_vendor_site_id in number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)

IS
	l_step number;
BEGIN

	l_step := 0;
   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin prenote_iby_temp_account ');
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_vendor_site_id ' || p_vendor_site_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_temp_ext_bank_account_id ' || p_temp_ext_bank_account_id);
	END IF;

	-- Create/Update the account
	POS_SBD_IBY_PKG.approve_iby_temp_account (
	  p_temp_ext_bank_account_id => p_temp_ext_bank_account_id
	, x_status => x_status
	, x_exception_msg => x_exception_msg
	);

	l_step := 1;

	POS_SBD_IBY_PKG.assign_site_to_account (
	  p_temp_ext_bank_account_id => p_temp_ext_bank_account_id
	, p_vendor_site_id => p_vendor_site_id
	, x_status => x_status
	, x_exception_msg => x_exception_msg
	);

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' END prenote_iby_temp_account ');
	END IF;

EXCEPTION
    WHEN OTHERS THEN
	x_exception_msg := 'Failure at step ' || l_step;
      	raise_application_error(-20068, x_exception_msg, true);
END prenote_iby_temp_account;


PROCEDURE approve_iby_temp_account (
  p_temp_ext_bank_account_id in number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)

IS

	l_msg_count number;
	l_step number;

	l_temp_bank_account_num IBY_EXT_BANK_ACCOUNTS.BANK_ACCOUNT_NUM%TYPE;
	l_record_type IBY_FNDCPT_COMMON_PUB.Result_rec_type;
	l_end_date DATE;
	l_start_date DATE;
	l_count NUMBER;
	l_msg_data varchar(2000);
	CURSOR l_temp_account_cur is

	select req.account_request_id,
	temp.bank_id, temp.bank_name, temp.bank_number,
	temp.bank_institution_type, temp.bank_name_alt,
	temp.bank_address_id,
	temp.branch_id, temp.branch_name, temp.branch_number, temp.bic,
	temp.branch_type, temp.branch_name_alt, temp.rfc_identifier,
	temp.branch_address_id,
	temp.ext_bank_account_id, temp.account_owner_party_id,
	temp.country_code, temp.FOREIGN_PAYMENT_USE_FLAG,
	temp.bank_account_name, temp.bank_account_num, temp.check_digits,
	temp.iban, temp.currency_code,
	temp.bank_account_name_alt, temp.bank_account_type,
	temp.description, temp.end_date, temp.start_date, temp.agency_location_code,
	temp.status, temp.note, temp.note_alt, temp.account_suffix, temp.exchange_rate,
	temp.exchange_rate_agreement_num, temp.exchange_rate_agreement_type, temp.payment_factor_flag
	from IBY_TEMP_EXT_BANK_ACCTS temp, pos_acnt_gen_req req
	where temp.temp_ext_bank_acct_id = p_temp_ext_bank_account_id
	and req.temp_ext_bank_acct_id = temp.temp_ext_bank_acct_id;
	l_temp_account_rec l_temp_account_cur%ROWTYPE;

	l_ext_bank_rec            IBY_EXT_BANKACCT_PUB.ExtBank_rec_type;
	l_ext_bank_branch_rec     IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type;
	l_ext_bank_acct_rec       IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type;
	l_result_rec              IBY_FNDCPT_COMMON_PUB.Result_rec_type;
        l_primary_owner_id HZ_PARTIES.party_id%TYPE;
        l_non_primary_owner_id HZ_PARTIES.party_id%TYPE;
	l_joint_acct_owner_id NUMBER;

	l_bank_id IBY_TEMP_EXT_BANK_ACCTS.bank_id%TYPE;
	l_branch_id IBY_TEMP_EXT_BANK_ACCTS.branch_id%TYPE;
	l_ext_bank_account_id IBY_TEMP_EXT_BANK_ACCTS.ext_bank_account_id%TYPE;
	l_account_request_id POS_ACNT_GEN_REQ.account_request_id%TYPE;
	l_bank_address_id IBY_TEMP_EXT_BANK_ACCTS.bank_address_id%TYPE;
	l_branch_address_id IBY_TEMP_EXT_BANK_ACCTS.branch_address_id%TYPE;
	l_bank_party_site_id number;
	l_bank_party_site_number varchar2(2000);
	l_branch_party_site_id number;
	l_branch_party_site_number varchar2(2000);
	l_party_site_rec  HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;

	cursor l_cur_act_cur is
	select act.object_version_number, ow.account_owner_party_id
	from iby_ext_bank_accounts act, iby_account_owners ow
	where ow.ext_bank_account_id = act.ext_bank_account_id
	and act.ext_bank_account_id = l_ext_bank_account_id
	and ow.primary_flag = 'Y'
	and NVL(ow.end_date,SYSDATE+10)>SYSDATE
	AND sysdate between NVL(act.start_date,sysdate) AND NVL(act.end_date,sysdate);
	l_cur_act_rec l_cur_act_cur%ROWTYPE;
BEGIN

   x_status := 'S';

   l_step := 0;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' BEGIN approve_iby_temp_account ');
	END IF;

   for l_temp_account_rec in l_temp_account_cur loop

	l_bank_id := l_temp_account_rec.bank_id;
	l_branch_id := l_temp_account_rec.branch_id;
	l_ext_bank_account_id := l_temp_account_rec.ext_bank_account_id;
	l_branch_address_id := l_temp_account_rec.branch_address_id;
	l_bank_address_id := l_temp_account_rec.bank_address_id;
	l_account_request_id := l_temp_account_rec.account_request_id;

	l_step := 1;
	if (l_bank_id is null and
		(l_temp_account_rec.bank_number is not null OR l_temp_account_rec.bank_name is not null))
	then

		-- Load the bank record.
		l_ext_bank_rec.bank_name                   := l_temp_account_rec.bank_name;
		l_ext_bank_rec.bank_number                 := l_temp_account_rec.bank_number;
		l_ext_bank_rec.institution_type            := 'BANK';
		l_ext_bank_rec.country_code                := l_temp_account_rec.country_code;
		l_ext_bank_rec.bank_alt_name               := l_temp_account_rec.bank_name_alt;

		IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Calling IBY_EXT_BANKACCT_PUB.create_ext_bank');
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_rec.bank_name ' || l_ext_bank_rec.bank_name);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_rec.bank_number ' || l_ext_bank_rec.bank_number);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_rec.institution_type ' || l_ext_bank_rec.institution_type );
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_rec.country_code ' || l_ext_bank_rec.country_code);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_rec.bank_alt_name ' || l_ext_bank_rec.bank_alt_name);
		END IF;

	        -- Create a bank
	        IBY_EXT_BANKACCT_PUB.create_ext_bank (
         	p_api_version              => 1.0,
         	p_init_msg_list              => FND_API.G_TRUE,
         	p_ext_bank_rec             => l_ext_bank_rec,
         	x_bank_id                  => l_bank_id,
         	x_return_status            => x_status,
         	x_msg_count                => l_msg_count,
         	x_msg_data                 => x_exception_msg,
         	x_response                 => l_result_rec
        	);

		IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' After Calling IBY_EXT_BANKACCT_PUB.create_ext_bank');
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_return_status ' || x_status);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_msg_count ' || l_msg_count);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_msg_data ' || x_exception_msg);
		END IF;

		if l_bank_id is null OR x_status <> 'S' then
			raise_application_error(-20073, 'IBY Failed to create a bank', true);
		end if;

	   	if l_bank_address_id is not null then

			l_party_site_rec.party_id := l_bank_id;
	    		l_party_site_rec.party_site_name := null;
    			l_party_site_rec.status := 'A';
    			l_party_site_rec.location_id := l_bank_address_id;
    			l_party_site_rec.identifying_address_flag := 'Y';
    			l_party_site_rec.created_by_module := 'POS_SUPPLIER_MGMT';
    			l_party_site_rec.application_id := 177;

    			hz_party_site_v2pub.create_party_site
			(
			p_init_msg_list => FND_API.G_FALSE,
        		p_party_site_rec => l_party_site_rec,
        		x_party_site_id => l_bank_party_site_id,
        		x_party_site_number => l_bank_party_site_number,
        		x_return_status => x_status,
        		x_msg_count => l_msg_count,
        		x_msg_data => x_exception_msg);
    		end if;
	end if;

	l_step := 2;
        if (l_branch_id is null AND
	(l_temp_account_rec.branch_number is not null OR l_temp_account_rec.branch_name is not null))
	then

        	l_ext_bank_branch_rec.bank_party_id        := l_bank_id;
        	l_ext_bank_branch_rec.branch_name          := l_temp_account_rec.branch_name;
        	l_ext_bank_branch_rec.branch_number        := l_temp_account_rec.branch_number;
        	l_ext_bank_branch_rec.branch_type          := l_temp_account_rec.branch_type;
        	l_ext_bank_branch_rec.alternate_branch_name := l_temp_account_rec.branch_name_alt;
        	l_ext_bank_branch_rec.bic                  := l_temp_account_rec.bic;
        	l_ext_bank_branch_rec.rfc_identifier       := l_temp_account_rec.rfc_identifier;

		IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Calling IBY_EXT_BANKACCT_PUB.create_ext_bank_branch');
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_branch_rec.bank_party_id ' || l_ext_bank_branch_rec.bank_party_id);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_branch_rec.branch_name ' || l_ext_bank_branch_rec.branch_name);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_branch_rec.branch_number ' || l_ext_bank_branch_rec.branch_number);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_branch_rec.branch_type ' || l_ext_bank_branch_rec.branch_type);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_branch_rec.alternate_branch_name '
				|| l_ext_bank_branch_rec.alternate_branch_name);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_branch_rec.bic  ' || l_ext_bank_branch_rec.bic );
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_branch_rec.rfc_identifier ' || l_ext_bank_branch_rec.rfc_identifier);
		END IF;

        	IBY_EXT_BANKACCT_PUB.create_ext_bank_branch (
        	 p_api_version                => 1.0,
        	 p_init_msg_list              => FND_API.G_TRUE,
        	 p_ext_bank_branch_rec        => l_ext_bank_branch_rec,
        	 x_branch_id                  => l_branch_id,
        	 x_return_status              => x_status,
        	 x_msg_count                  => l_msg_count,
        	 x_msg_data                   => x_exception_msg,
        	 x_response                   => l_result_rec
        	);

		IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' After Calling IBY_EXT_BANKACCT_PUB.create_ext_bank_branch');
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_return_status ' || x_status);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_msg_count ' || l_msg_count);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_msg_data ' || x_exception_msg);
		END IF;

		if l_branch_id is null OR x_status <> 'S'  then
			raise_application_error(-20072, 'IBY Failed to create a branch', true);
		end if;

	   	if l_branch_address_id is not null then

			l_party_site_rec.party_id := l_branch_id;
	    		l_party_site_rec.party_site_name := null;
    			l_party_site_rec.status := 'A';
    			l_party_site_rec.location_id := l_branch_address_id;
    			l_party_site_rec.identifying_address_flag := 'Y';
    			l_party_site_rec.created_by_module := 'POS_SUPPLIER_MGMT';
    			l_party_site_rec.application_id := 177;

    			hz_party_site_v2pub.create_party_site
			(
			p_init_msg_list => FND_API.G_FALSE,
        		p_party_site_rec => l_party_site_rec,
        		x_party_site_id => l_branch_party_site_id,
        		x_party_site_number => l_branch_party_site_number,
        		x_return_status => x_status,
        		x_msg_count => l_msg_count,
        		x_msg_data => x_exception_msg);
    		end if;
	end if;

	l_step := 3;

	-- Find out if it exists
	if l_ext_bank_account_id is null then
		IBY_EXT_BANKACCT_PUB.check_ext_acct_exist(
			p_api_version       => 1.0,
    			p_init_msg_list     => FND_API.G_FALSE,
			p_bank_id	    => l_bank_id,
    			p_branch_id         => l_branch_id,
        		p_acct_number       => l_temp_account_rec.bank_account_num,
        		p_acct_name         => l_temp_account_rec.bank_account_name,
        		p_currency          => l_temp_account_rec.currency_code,
			p_country_code      => l_temp_account_rec.country_code,
    			x_acct_id           => l_ext_bank_account_id,
        		x_start_date        => l_start_date,
       			x_end_date          => l_end_date,
        		x_return_status     => x_status,
    			x_msg_count         => l_msg_count,
    			x_msg_data          => l_msg_data,
    			x_response          => l_record_type);

	end if;

	-- Find out if we need to add this person as an owner.
	if l_ext_bank_account_id is not null then
		 open l_cur_act_cur;
		 fetch l_cur_act_cur into l_cur_act_rec;
		 close l_cur_act_cur;

        	 l_primary_owner_id := l_cur_act_rec.account_owner_party_id;
		 l_non_primary_owner_id := l_temp_account_rec.ACCOUNT_OWNER_PARTY_ID;

		 if l_primary_owner_id <> l_temp_account_rec.ACCOUNT_OWNER_PARTY_ID then
		 	  IBY_EXT_BANKACCT_PUB.add_joint_account_owner (
			   p_api_version       => 1.0,
			   p_init_msg_list     => FND_API.G_FALSE,
			   p_bank_account_id   => l_ext_bank_account_id,
			   p_acct_owner_party_id => l_non_primary_owner_id,
			   x_joint_acct_owner_id => l_joint_acct_owner_id,
           		   x_return_status     => x_status,
    			   x_msg_count         => l_msg_count,
    			   x_msg_data          => l_msg_data,
    			   x_response          => l_record_type);
		 end if;

		 IF x_status <> 'S' then
			raise_application_error(-20074, 'IBY API AJAA Failed' || l_msg_data, true);
    	 	 END IF;
	end if;

         l_ext_bank_acct_rec.bank_account_id        := l_ext_bank_account_id;
	 l_ext_bank_acct_rec.country_code           := l_temp_account_rec.country_code;
         l_ext_bank_acct_rec.branch_id              := l_branch_id;
         l_ext_bank_acct_rec.bank_id                := l_bank_id;
         l_ext_bank_acct_rec.acct_owner_party_id    := l_temp_account_rec.ACCOUNT_OWNER_PARTY_ID;
         l_ext_bank_acct_rec.bank_account_name      := l_temp_account_rec.bank_account_name;
         l_ext_bank_acct_rec.bank_account_num       := l_temp_account_rec.bank_account_num;
         l_ext_bank_acct_rec.currency               := l_temp_account_rec.currency_code;
         l_ext_bank_acct_rec.iban                   := l_temp_account_rec.iban;
         l_ext_bank_acct_rec.check_digits           := l_temp_account_rec.check_digits;
         l_ext_bank_acct_rec.alternate_acct_name    := l_temp_account_rec.bank_account_name_alt;
         l_ext_bank_acct_rec.acct_type              := l_temp_account_rec.bank_account_type;
         l_ext_bank_acct_rec.acct_suffix            := l_temp_account_rec.account_suffix;
         l_ext_bank_acct_rec.agency_location_code   := l_temp_account_rec.agency_location_code;
         l_ext_bank_acct_rec.foreign_payment_use_flag := l_temp_account_rec.FOREIGN_PAYMENT_USE_FLAG;
         l_ext_bank_acct_rec.payment_factor_flag    := l_temp_account_rec.payment_factor_flag;
         l_ext_bank_acct_rec.end_date               := l_temp_account_rec.end_date;
         l_ext_bank_acct_rec.start_date             := l_temp_account_rec.start_date;
	 l_ext_bank_acct_rec.description            := l_temp_account_rec.description;


	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Calling IBY_EXT_BANKACCT_PUB.create/update_ext_bank_acct');
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.bank_account_id ' || l_ext_bank_acct_rec.bank_account_id);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.country_code ' || l_ext_bank_acct_rec.country_code);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.branch_id ' || l_ext_bank_acct_rec.branch_id);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.bank_id ' || l_ext_bank_acct_rec.bank_id);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
		' l_ext_bank_acct_rec.acct_owner_party_id ' || l_ext_bank_acct_rec.acct_owner_party_id);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.bank_account_name ' || l_ext_bank_acct_rec.bank_account_name);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.bank_account_num ' || l_ext_bank_acct_rec.bank_account_num);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.currency ' || l_ext_bank_acct_rec.currency);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.iban ' || l_ext_bank_acct_rec.iban);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.check_digits ' || l_ext_bank_acct_rec.check_digits);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
		' l_ext_bank_acct_rec.alternate_acct_name ' || l_ext_bank_acct_rec.alternate_acct_name);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.acct_type ' || l_ext_bank_acct_rec.acct_type);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.acct_suffix ' || l_ext_bank_acct_rec.acct_suffix);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
		' l_ext_bank_acct_rec.agency_location_code ' || l_ext_bank_acct_rec.agency_location_code);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
		' l_ext_bank_acct_rec.foreign_payment_use_flag '
			|| l_ext_bank_acct_rec.foreign_payment_use_flag);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
		' l_ext_bank_acct_rec.payment_factor_flag ' || l_ext_bank_acct_rec.payment_factor_flag);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.end_date ' || l_ext_bank_acct_rec.end_date);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.start_date ' || l_ext_bank_acct_rec.start_date);
	END IF;


        if l_ext_bank_account_id is null then

         l_ext_bank_acct_rec.exchange_rate_agreement_num := l_temp_account_rec.exchange_rate_agreement_num;
         l_ext_bank_acct_rec.exchange_rate_agreement_type := l_temp_account_rec.exchange_rate_agreement_type;
         l_ext_bank_acct_rec.exchange_rate          := l_temp_account_rec.exchange_rate;

	 IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.exchange_rate_agreement_num  '
			|| l_ext_bank_acct_rec.exchange_rate_agreement_num);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.exchange_rate_agreement_type '
			|| l_ext_bank_acct_rec.exchange_rate_agreement_type);
     		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_ext_bank_acct_rec.exchange_rate ' || l_ext_bank_acct_rec.exchange_rate);
	 END IF;

	 IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Now Calling IBY_EXT_BANKACCT_PUB.create_ext_bank_acct');
	 END IF;

	 IBY_EXT_BANKACCT_PUB.create_ext_bank_acct (
          p_api_version                => 1.0,
          p_init_msg_list              => FND_API.G_TRUE,
          p_ext_bank_acct_rec          => l_ext_bank_acct_rec,
          x_acct_id                    => l_ext_bank_account_id,
          x_return_status              => x_status,
          x_msg_count                  => l_msg_count,
          x_msg_data                   => x_exception_msg,
          x_response                   => l_result_rec
         );

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' After Calling IBY_EXT_BANKACCT_PUB.create_ext_bank_acct');
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_return_status ' || x_status);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_msg_count ' || l_msg_count);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_msg_data ' || x_exception_msg);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_acct_id ' || l_ext_bank_account_id);

	 END IF;

	 IF x_status <> 'S' OR l_ext_bank_account_id is null then
		raise_application_error(-20070, 'IBY API CEBA' || x_exception_msg, true);
    	 END IF;

	else

	 IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Now Calling IBY_EXT_BANKACCT_PUB.update_ext_bank_acct');
	 END IF;

	 open l_cur_act_cur;
	 fetch l_cur_act_cur into l_cur_act_rec;
	 close l_cur_act_cur;

         l_ext_bank_acct_rec.object_version_number := l_cur_act_rec.object_version_number;


	 /* BUG 10384712 START */

	  IF l_ext_bank_account_id IS NOT NULL THEN

	     SELECT BANK_ACCOUNT_NUM INTO l_temp_bank_account_num
	     FROM
	     IBY_EXT_BANK_ACCOUNTS
	     WHERE
             EXT_BANK_ACCOUNT_ID=l_ext_bank_account_id;

             l_ext_bank_acct_rec.bank_account_num       := l_temp_bank_account_num;
	  END IF;

		/* BUG 10384712 END */

	 IBY_EXT_BANKACCT_PUB.update_ext_bank_acct (
          p_api_version                => 1.0,
          p_init_msg_list              => FND_API.G_TRUE,
          p_ext_bank_acct_rec          => l_ext_bank_acct_rec,
          x_return_status              => x_status,
          x_msg_count                  => l_msg_count,
          x_msg_data                   => x_exception_msg,
          x_response                   => l_result_rec
         );

	 IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' After Calling IBY_EXT_BANKACCT_PUB.update_ext_bank_acct');
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_return_status ' || x_status);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_msg_count ' || l_msg_count);
     			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_msg_data ' || x_exception_msg);
	 END IF;

	 IF x_status <> 'S' then
		raise_application_error(-20071, 'IBY API UEBA Failed' || x_exception_msg, true);
    	 END IF;

	end if;

	POS_SBD_IBY_PKG.update_req_with_account (
	  p_temp_ext_bank_account_id => p_temp_ext_bank_account_id
	, p_ext_bank_account_id =>  l_ext_bank_account_id
	, p_account_request_id => l_account_request_id
	, p_bank_id => l_bank_id
	, p_branch_id => l_branch_id
	, x_status        => x_status
	, x_exception_msg => x_exception_msg
	);

   end loop;

   IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End approve_iby_temp_account');
   END IF;
EXCEPTION
    WHEN OTHERS THEN
      x_exception_msg := 'Failure at step ' || l_step;
      raise_application_error(-20069, x_exception_msg, true);
END approve_iby_temp_account;

PROCEDURE update_req_with_account (
  p_temp_ext_bank_account_id in number
, p_ext_bank_account_id in number
, p_account_request_id in number
, p_bank_id in number
, p_branch_id in number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

l_step number;

BEGIN

	l_step := 0;
	update pos_acnt_addr_summ_req
	set ext_bank_account_id = p_ext_bank_account_id,
	last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id,
	object_version_number = object_version_number + 1
	where account_request_id = p_account_request_id;

	l_step := 2;
	update pos_acnt_gen_req
	set ext_bank_account_id = p_ext_bank_account_id,
	last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id,
	object_version_number = object_version_number + 1
	where account_request_id = p_account_request_id;

	l_step := 3;
	update iby_temp_ext_bank_accts
	set bank_id = p_bank_id,
	branch_id = p_branch_id,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id,
 	object_version_number = object_version_number + 1,
	ext_bank_account_id = p_ext_bank_account_id
	where temp_ext_bank_acct_id = p_temp_ext_bank_account_id;

	x_status := 'S';

EXCEPTION
    WHEN OTHERS THEN
      x_exception_msg := 'Failure at step ' || l_step;
      raise_application_error(-20078, x_exception_msg, true);
END update_req_with_account;


PROCEDURE check_for_duplicates (
  p_mapping_id in NUMBER
, p_BANK_ID in NUMBER
, p_BANK_NAME in VARCHAR2
, p_BANK_NUMBER in VARCHAR2
, p_BRANCH_ID in NUMBER
, p_BRANCH_NAME in VARCHAR2
, p_BRANCH_NUMBER in VARCHAR2
, p_EXT_BANK_ACCOUNT_ID in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, p_account_request_id in number
, x_need_validation out nocopy varchar2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)

IS

	l_step number;
	l_bank_id HZ_PARTIES.party_id%TYPE;
	l_branch_id HZ_PARTIES.party_id%TYPE;
	l_ext_bank_account_id IBY_TEMP_EXT_BANK_ACCTS.EXT_BANK_ACCOUNT_ID%TYPE;
	l_record_type IBY_FNDCPT_COMMON_PUB.Result_rec_type;
	l_end_date DATE;
	l_start_date DATE;
	l_msg_count NUMBER;
	l_count NUMBER;
	l_msg_data varchar(2000);

	cursor dup_temp_act_cur is
	select count(*) from iby_temp_ext_bank_accts iby, pos_acnt_gen_req pos
	where pos.mapping_id = p_mapping_id
	and pos.temp_ext_bank_acct_id = iby.temp_ext_bank_acct_id
	and (
	     (iby.currency_code = p_currency_code
		and p_currency_code is not null and iby.currency_code is not null) OR
	     (p_currency_code is null and iby.currency_code is null)
	    )

	and iby.country_code = p_country_code
	and iby.status in ('NEW', 'IN_VERIFICATION', 'VERIFICATION_FAILED', 'CORRECTED', 'CHANGE_PENDING')
	AND ((iby.bank_id = p_bank_id and p_bank_id is not null and iby.bank_id is not null) OR
	     (iby.bank_number = p_bank_number and p_bank_number is not null and iby.bank_number is not null) OR
	     (p_bank_id is null and iby.bank_id is null and p_bank_number is null and iby.bank_number is null)
	    )
	AND (
	      (iby.branch_id = p_branch_id and p_branch_id is not null and iby.branch_id is not null) OR
	      (iby.branch_number = p_branch_number and p_branch_number is not null
	       and iby.branch_number is not null) OR
	      (p_branch_id is null and iby.branch_id is null
	       and p_branch_number is null and iby.branch_number is null)
	    )

	AND (
	     (iby.bank_account_num = p_bank_account_number and p_bank_account_number is not null
	       and iby.bank_account_num is not null) OR
	     (iby.bank_account_name = p_bank_account_name and p_bank_account_name is not null
	       and iby.bank_account_name is not null)
	    )
	AND ((pos.account_request_id <> p_account_request_id and p_account_request_id is not null and
		pos.account_request_id is not null) OR (p_account_request_id is null));

	cursor dup_cur_act_cur is
	select count(*) from iby_ext_bank_accounts act, iby_account_owners o, pos_supplier_mappings pmap
	where o.ext_bank_account_id  = act.ext_bank_account_id
	and (
		(act.currency_code = p_currency_code
		 and act.currency_code is not null and p_currency_code is not null) OR
		(act.currency_code is null and p_currency_code is null)
	    )
	and o.account_owner_party_id = pmap.party_id
	and pmap.mapping_id = p_mapping_id
	and ((act.bank_id = l_bank_id and act.bank_id is not null and l_bank_id is not null) OR
	     (act.bank_id is null and l_bank_id is null))
	and ((act.branch_id = l_branch_id and act.branch_id is not null
		and l_branch_id is not null) OR
	     (act.branch_id is null and l_branch_id is null))
	and (
		act.bank_account_name = p_bank_account_name
		 and act.bank_account_name is not null and p_bank_account_name is not null
	    )
	and ((act.ext_bank_account_id <> p_EXT_BANK_ACCOUNT_ID and p_EXT_BANK_ACCOUNT_ID is not null)
		OR p_EXT_BANK_ACCOUNT_ID is null)
	and act.country_code = p_country_code
	and not exists
	(
	select 1 from IBY_TEMP_EXT_BANK_ACCTS temp
	where temp.EXT_BANK_ACCOUNT_ID = act.ext_bank_account_id
	and temp.status in ('CORRECTED', 'NEW', 'IN_VERIFICATION', 'VERIFICATION_FAILED', 'CHANGE_PENDING')
	and temp.account_owner_party_id = o.account_owner_party_id
	)
	and ((act.ext_bank_account_id <> p_ext_bank_account_id and p_ext_bank_account_id is not null and
	act.ext_bank_account_id is not null) OR (p_ext_bank_account_id is null))
	AND sysdate between NVL(act.start_date,sysdate) AND NVL(act.end_date,sysdate);

BEGIN

	l_step := 0;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin check_for_duplicates ');
	END IF;

	x_need_validation := 'Y';
	x_status := 'S';

	-- If bank id is not specified then check if its duplicate
	if p_bank_id is null then
	  ce_bank_pub.check_bank_exist(
        	p_country_code             => p_country_code,
        	p_bank_name                => p_bank_name,
       		p_bank_number              => p_bank_number,
        	x_bank_id                  => l_bank_id,
       		x_end_date                 => l_end_date);

	  if l_bank_id is not null then
		x_status := 'E';
	  	fnd_message.set_name('POS', 'POS_SBD_DUP_BANK');
       		fnd_msg_pub.add;
          end if;

	else
	  l_bank_id := p_bank_id;
	end if;

	-- If branch id is not specified then check if its duplicate.
	if p_branch_id is null then

		if l_bank_id is not null then

 	  		ce_bank_pub.check_branch_exist(
        			p_bank_id                  => l_bank_id,
        			p_branch_name              => p_branch_name,
        			p_branch_number            => p_branch_number,
        			x_branch_id                => l_branch_id,
        			x_end_date                 => l_end_date);
	  		if l_branch_id is not null then
				x_status := 'E';
				fnd_message.set_name('POS', 'POS_SBD_DUP_BRANCH');
       				fnd_msg_pub.add;
			end if;

		end if;
	else
	  l_branch_id := p_branch_id;
	end if;

	open dup_temp_act_cur;
	fetch dup_temp_act_cur into l_count;
	if l_count is null then l_count := 0;
	end if;
		if l_count <> 0 then
			x_status := 'E';
			fnd_message.set_name('POS', 'POS_SBD_DUP_ACT2');
       			fnd_msg_pub.add;
		end if;
	close dup_temp_act_cur;

	l_count := 0;
	open dup_cur_act_cur;
	fetch dup_cur_act_cur into l_count;
	if l_count is null then l_count := 0;
	end if;
	close dup_cur_act_cur;

	if l_count <> 0 then
			x_status := 'E';
			fnd_message.set_name('POS', 'POS_SBD_DUP_ACT1');
       			fnd_msg_pub.add;
	end if;

	if l_bank_id is not null and l_branch_id is not null and
	   p_EXT_BANK_ACCOUNT_ID is null and x_status = 'S' then
		IBY_EXT_BANKACCT_PUB.check_ext_acct_exist(
			p_api_version       => 1.0,
    			p_init_msg_list     => FND_API.G_FALSE,
			p_bank_id	    => l_bank_id,
    			p_branch_id         => l_branch_id,
        		p_acct_number       => p_bank_account_number,
        		p_acct_name         => p_bank_account_name,
        		p_currency          => p_currency_code,
			p_country_code	    => p_country_code,
    			x_acct_id           => l_ext_bank_account_id,
        		x_start_date        => l_start_date,
       			x_end_date          => l_end_date,
        		x_return_status     => x_status,
    			x_msg_count         => l_msg_count,
    			x_msg_data          => l_msg_data,
    			x_response          => l_record_type);
		if l_ext_bank_account_id is not null then
       			x_need_validation := 'N';
		end if;
	end if;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End check_for_duplicates ');
	END IF;

EXCEPTION

    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      raise_application_error(-20085, x_exception_msg, true);
END check_for_duplicates;


END POS_SBD_IBY_PKG;

/
