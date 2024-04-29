--------------------------------------------------------
--  DDL for Package Body IGI_STP_TABLE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_STP_TABLE_HANDLER_PKG" AS
-- $Header: igistpab.pls 120.11.12000000.8 2007/10/09 06:05:00 gkumares ship $
--following variables added for bug 3199481: fnd logging changes: sdixit
   l_debug_level number;
   l_state_level number;
   l_proc_level number;
   l_event_level number;
   l_excep_level number;
   l_error_level number;
   l_unexp_level number;





 PROCEDURE Address_Insert_Row( 	X_rowid IN OUT NOCOPY VARCHAR2,
			X_address_id NUMBER,
			X_customer_id NUMBER,
			X_org_id NUMBER,
			X_status VARCHAR2,
			X_orig_system_reference VARCHAR2,
			X_country VARCHAR2,
			X_address1 VARCHAR2,
			X_address2 VARCHAR2,
			X_address3 VARCHAR2,
			X_address4 VARCHAR2,
			X_city VARCHAR2,
			X_postal_code VARCHAR2,
			X_state VARCHAR2,
			X_province VARCHAR2,
			X_county VARCHAR2,
			X_address_key VARCHAR2,
			X_key_account_flag VARCHAR2,
			X_language VARCHAR2,
			X_address_lines_phonetic VARCHAR2,
			X_customer_category_code VARCHAR2,
			X_ece_tp_location_code VARCHAR2,
			X_stp_common_ref VARCHAR2,
			X_stp_alt_addr VARCHAR2,
			X_stp_supplier VARCHAR2,
			X_stp_site_inactive_date DATE,
			X_creation_date	DATE,
			X_created_by NUMBER,
			X_last_update_login NUMBER,
			X_last_update_date DATE,
			X_last_updated_by NUMBER,
                        X_party_id NUMBER,
                        X_location_id NUMBER,
                        X_party_site_id NUMBER,
                        X_party_site_number VARCHAR2) IS


	CURSOR C IS SELECT location_id FROM HZ_LOCATIONS
		    WHERE location_id = X_location_id;
	CURSOR C1 IS SELECT party_site_id FROM HZ_PARTY_SITES
		    WHERE party_site_id = X_party_site_id;
	CURSOR C2 IS SELECT rowid FROM HZ_CUST_ACCT_SITES
		    WHERE cust_acct_site_id = X_address_id;
	CURSOR C3 IS SELECT address_id FROM IGI_RA_ADDRESSES
		    WHERE address_id = X_address_id;
	CURSOR C4 IS SELECT location_id FROM HZ_LOC_ASSIGNMENTS
		    WHERE location_id = X_location_id;

        c_location_id  number(15);
        c1_party_site_id number(15);
        c3_address_id  number(15);

    p_cust_site_use_rec HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE;
    p_customer_profile_rec HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
    x_site_use_id NUMBER;
    x_return_status VARCHAR2(2000);
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);

-- Bug 2037659 Fix

   l_location_rec   hz_location_v2pub.location_rec_type;
   l_return_status  varchar2(3);
   l_msg_count      number;
   l_msg_data       varchar2(2000);
   l_loc_id         number;
   l_loc_out_id     number;

-- Bug 2037659 Fix

   l_party_site_rec    hz_party_site_v2pub.party_site_rec_type;
   l_party_site_id     number;
   l_party_site_number varchar2(2000);


   l_application_id    number;
   l_cust_acct_site_rec hz_cust_account_site_v2pub.cust_acct_site_rec_type;
   l_cust_acct_site_id  number;
   l_profile_value varchar2(100);  -- For capturing the value returned from fnd_profile.get

   v_cnt number;

 BEGIN

 -- Bug 2037659 Fix

    l_location_rec.location_id := x_location_id;
    l_location_rec.country := x_country;
    l_location_rec.address1 := x_address1;
    l_location_rec.address2 := x_address2;
    l_location_rec.address3 := x_address3;
    l_location_rec.address4 := x_address4;
    l_location_rec.city := x_city;
    l_location_rec.postal_code := x_postal_code;
    l_location_rec.state := x_state;
    l_location_rec.province := x_province;
    l_location_rec.county := x_county;
    l_location_rec.language := x_language;
    l_location_rec.orig_system_reference := x_location_id;
    l_location_rec.created_by_module	 := 'IGI_STP';
-- Bug 2846318 Start
    l_location_rec.address_lines_phonetic := x_address_lines_phonetic;
-- Bug 2846318 End


    l_cust_acct_site_rec.cust_acct_site_id      := X_address_id;
    l_cust_acct_site_rec.cust_account_id        := X_customer_id;
    l_cust_acct_site_rec.party_site_id		:= X_party_site_id;
    l_cust_acct_site_rec.orig_system_reference  := X_orig_system_reference;
    l_cust_acct_site_rec.status			:= X_status;
    l_cust_acct_site_rec.customer_category_code	:= X_customer_category_code;
    l_cust_acct_site_rec.key_account_flag	:= X_key_account_flag;
    l_cust_acct_site_rec.ece_tp_location_code	:= X_ece_tp_location_code;
    l_cust_acct_site_rec.created_by_module	:= 'IGI_STP';


    hz_location_v2pub.create_location
      (
        p_init_msg_list => fnd_api.g_false,
        p_location_rec => l_location_rec,
        x_location_id => l_loc_id,
        x_return_status => l_return_status,
        x_msg_count  => l_msg_count,
        x_msg_data  => l_msg_data
     );


    OPEN C;
    FETCH C INTO c_location_id;
    IF (C%NOTFOUND) THEN
	CLOSE C;
	Raise NO_DATA_FOUND;
    END IF;
    CLOSE C;



    -- Bug 2037659 Fix
  /*
      hz_tax_assignment_v2pub.create_loc_assignment
    (
         p_init_msg_list      => fnd_api.g_false,
         p_location_id        => l_loc_id,
         p_lock_flag          => fnd_api.g_false,
         p_created_by_module  => 'IGI_STP',
         p_application_id     => l_application_id,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data           => l_msg_data,
         x_loc_id	      => l_loc_out_id
     );



    OPEN C4;
    FETCH C4 INTO c_location_id;
    IF (C4%NOTFOUND) THEN
	CLOSE C4;
	Raise NO_DATA_FOUND;
    END IF;
    CLOSE C4; */

    l_party_site_rec.party_site_id                 := X_party_site_id;
    l_party_site_rec.party_id		       := X_party_id;
    l_party_site_rec.location_id     	       := X_location_id;

    FND_PROFILE.GET('HZ_GENERATE_PARTY_SITE_NUMBER', l_profile_value);

    IF (l_profile_value = 'N') THEN
	l_party_site_rec.party_site_number := X_party_site_number;
    ELSE
	l_party_site_rec.party_site_number := NULL;
    END IF;

    IF (X_status = 'A') THEN	/* Code changed */
    	l_party_site_rec.identifying_address_flag  := 'Y';
    ELSE
    	l_party_site_rec.identifying_address_flag := 'N';
    END IF;

    l_party_site_rec.status   		       := X_status;
    l_party_site_rec.created_by_module	       := 'IGI_STP';

    hz_party_site_v2pub.create_party_site
    (
      	p_init_msg_list     => fnd_api.g_true,
       	p_party_site_rec    => l_party_site_rec,
       	x_party_site_id     => l_party_site_id,
       	x_party_site_number => l_party_site_number,
       	x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data
     );

    OPEN C1;
    FETCH C1 INTO c1_party_site_id;
    IF (C1%NOTFOUND) THEN
	CLOSE C1;
	Raise NO_DATA_FOUND;
    END IF;
    CLOSE C1;


    hz_cust_account_site_v2pub.create_cust_acct_site
    (
   	p_init_msg_list      => fnd_api.g_false,
   	p_cust_acct_site_rec => l_cust_acct_site_rec,
   	x_cust_acct_site_id  => l_cust_acct_site_id,
   	x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data
    );

    OPEN C2;
    FETCH C2 INTO X_ROWID;
    IF (C2%NOTFOUND) THEN
	CLOSE C2;
	Raise NO_DATA_FOUND;
    END IF;
    CLOSE C2;

 /*       p_cust_site_use_rec.cust_acct_site_id := l_cust_acct_site_id;
    	p_cust_site_use_rec.site_use_code := 'BILL_TO';
    	p_cust_site_use_rec.created_by_module := 'IGI_STP';
    	hz_cust_account_site_v2pub.create_cust_site_use(
    	'T',
    	p_cust_site_use_rec,
    	p_customer_profile_rec,
    	'',
    	'',
    	x_site_use_id,
    	x_return_status,
    	x_msg_count,
        x_msg_data); */



     INSERT INTO igi_ra_addresses(
		address_id,
		ORG_ID,
		stp_common_ref,
		stp_alt_addr,
		stp_supplier,
		stp_site_inactive_date,
		creation_date,
		created_by,
		last_update_login,
		last_update_date,
		last_updated_by)
    VALUES(
		X_address_id,
		X_ORG_ID,
		X_stp_common_ref,
		X_stp_alt_addr,
		X_stp_supplier,
		X_stp_site_inactive_date,
		X_creation_date,
		X_created_by,
		X_last_update_login,
		X_last_update_date,
		X_last_updated_by);

    OPEN C3;
    FETCH C3 INTO c3_address_id;
    IF (C3%NOTFOUND) THEN
	CLOSE C3;
	Raise NO_DATA_FOUND;
    END IF;
    CLOSE C3;



 END Address_Insert_Row;





/***************************************************************************************/
 PROCEDURE Address_Update_Row( 	X_rowid IN OUT NOCOPY VARCHAR2,
			X_org_id NUMBER,
			X_status VARCHAR2,
			X_orig_system_reference VARCHAR2,
			X_country VARCHAR2,
			X_address1 VARCHAR2,
			X_address2 VARCHAR2,
			X_address3 VARCHAR2,
			X_address4 VARCHAR2,
			X_city VARCHAR2,
			X_postal_code VARCHAR2,
			X_state VARCHAR2,
			X_province VARCHAR2,
			X_county VARCHAR2,
			X_address_key VARCHAR2,
			X_language VARCHAR2,
			X_address_lines_phonetic VARCHAR2,
			X_customer_category_code VARCHAR2,
			X_ece_tp_location_code VARCHAR2,
			X_stp_common_ref VARCHAR2,
			X_stp_alt_addr VARCHAR2,
			X_stp_supplier VARCHAR2,
			X_stp_site_inactive_date DATE,
			X_last_update_login NUMBER,
			X_last_update_date DATE,
			X_last_updated_by NUMBER) IS
   l_location_rec   hz_location_v2pub.location_rec_type;
   l_return_status  varchar2(3);
   l_msg_count      number;
   l_msg_data       varchar2(2000);

   l_location_id    number;
   l_object_version_number number;
   cursor c_loc is select LOC.LOCATION_ID from HZ_PARTY_SITES PS, HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES CS
                        WHERE PS.PARTY_SITE_ID = CS.PARTY_SITE_ID
                        AND LOC.LOCATION_ID = PS.LOCATION_ID
   			AND CS.rowid = x_rowid;

   l_party_site_id     number;
   l_party_site_rec    hz_party_site_v2pub.party_site_rec_type;
   cursor c_party is select PS.party_site_id from HZ_PARTY_SITES PS, HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES CS
                        WHERE PS.PARTY_SITE_ID = CS.PARTY_SITE_ID
                        AND LOC.LOCATION_ID = PS.LOCATION_ID
   			AND CS.rowid = x_rowid;

   l_cust_acct_site_rec hz_cust_account_site_v2pub.cust_acct_site_rec_type;
   l_cust_acct_site_id  number;
   cursor c_cust_acct is select cust_acct_site_id from hz_cust_acct_sites
   			where rowid = X_rowid;

   cursor c_obj_version_loc (p_location_id hz_locations.location_id%type) is
   select object_version_number
   from hz_locations
   where (location_id = p_location_id);

   cursor c_obj_version_site (p_party_site_id hz_party_sites.party_site_id%type) is
   select object_version_number
   from hz_party_sites
   where (party_site_id = p_party_site_id);

   cursor c_obj_version_cust_acct (p_cust_acct_site_id hz_cust_acct_sites.cust_acct_site_id%type) is
   select object_version_number
   from hz_cust_acct_sites
   where (cust_acct_site_id = p_cust_acct_site_id);

 BEGIN
    OPEN C_LOC;
    FETCH C_LOC INTO l_location_id;
    IF (C_LOC%NOTFOUND) THEN
       CLOSE C_LOC;
       Raise NO_DATA_FOUND;
    END IF;
    CLOSE C_LOC;

    --Modified for bug # 5263736
    l_location_rec.location_id := l_location_id;
    l_location_rec.country := x_country;
    l_location_rec.address1 := x_address1;
    l_location_rec.address2 := NVL(x_address2, fnd_api.g_miss_char);
    l_location_rec.address3 := NVL(x_address3, fnd_api.g_miss_char);
    l_location_rec.address4 := NVL(x_address4, fnd_api.g_miss_char);
    l_location_rec.city := NVL(x_city, fnd_api.g_miss_char);
    l_location_rec.postal_code := NVL(x_postal_code, fnd_api.g_miss_char);
    l_location_rec.state := NVL(x_state, fnd_api.g_miss_char);
    l_location_rec.province := NVL(x_province, fnd_api.g_miss_char);
    l_location_rec.county := NVL(x_county, fnd_api.g_miss_char);
    l_location_rec.language := NVL(x_language, fnd_api.g_miss_char);
    l_location_rec.address_lines_phonetic := NVL(x_address_lines_phonetic, fnd_api.g_miss_char);
     --Modified for bug # 5263736


    OPEN C_PARTY;
    FETCH C_PARTY INTO l_party_site_id;
    IF (C_PARTY%NOTFOUND) THEN
       CLOSE C_PARTY;
       Raise NO_DATA_FOUND;
    END IF;
    CLOSE C_PARTY;


    l_party_site_rec.party_site_id             := l_party_site_id;
    l_party_site_rec.status   		       := X_status;
    l_party_site_rec.created_by_module	       := 'IGI_STP';

    OPEN C_CUST_ACCT;
    FETCH C_CUST_ACCT INTO l_cust_acct_site_id;
    IF (C_CUST_ACCT%NOTFOUND) THEN
    	CLOSE C_CUST_ACCT;
    	Raise NO_DATA_FOUND;
    END IF;
    CLOSE C_CUST_ACCT;

    --Modified for bug # 5263736
    l_cust_acct_site_rec.cust_acct_site_id      := NVL(l_cust_acct_site_id, fnd_api.g_miss_num);
    l_cust_acct_site_rec.status			:= X_status;
    l_cust_acct_site_rec.language               := NVL(X_language, fnd_api.g_miss_char);
    l_cust_acct_site_rec.customer_category_code	:= NVL(X_customer_category_code, fnd_api.g_miss_char);
    l_cust_acct_site_rec.ece_tp_location_code	:= NVL(X_ece_tp_location_code, fnd_api.g_miss_char);
    --Modified for bug # 5263736

    OPEN c_obj_version_loc (l_location_id);
    FETCH c_obj_version_loc INTO l_object_version_number;
    CLOSE c_obj_version_loc;




    hz_location_v2pub.update_location
    (
        p_init_msg_list => fnd_api.g_false,
        p_location_rec => l_location_rec,
        p_object_version_number => l_object_version_number,
        X_return_status => l_return_status,
        X_msg_count  => l_msg_count,
        X_msg_data  => l_msg_data
    );





    --Added for bug 5263736
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RETURN;
    END IF;
    --Added for bug 5263736
	/* Since the same local variable is used for capturing object version numbers of hz_locations and hz_party_sites first nullify it */

        l_object_version_number := NULL;

       	OPEN c_obj_version_site (l_party_site_id);
    	FETCH c_obj_version_site INTO l_object_version_number;
    	CLOSE c_obj_version_site;

        hz_party_site_v2pub.update_party_site
        (
         	p_init_msg_list     => fnd_api.g_false,
         	p_party_site_rec    => l_party_site_rec,
         	p_object_version_number => l_object_version_number,
         	x_return_status      => l_return_status,
                x_msg_count          => l_msg_count,
                x_msg_data           => l_msg_data
        );

         /* Since the same local variable is used for capturing object version numbers of hz_locations, hz_party_sites andcust_acc hz_cust_acct_sites first nullify it */

        l_object_version_number := NULL;

        OPEN c_obj_version_cust_acct (l_cust_acct_site_id);
    	FETCH c_obj_version_cust_acct INTO l_object_version_number;
    	CLOSE c_obj_version_cust_acct;

          hz_cust_account_site_v2pub.update_cust_acct_site
      (
   	p_init_msg_list      => fnd_api.g_false,
   	p_cust_acct_site_rec => l_cust_acct_site_rec,
   	p_object_version_number => l_object_version_number,
   	x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data
     );

     UPDATE igi_ra_addresses ira
     SET
		stp_common_ref	= X_stp_common_ref,
		stp_alt_addr	= X_stp_alt_addr,
		stp_supplier	= X_stp_supplier,
		stp_site_inactive_date = X_stp_site_inactive_date,
		last_update_login	= X_last_update_login,
		last_update_date	= X_last_update_date,
		last_updated_by		= X_last_updated_by
     WHERE ira.address_id = (select CS.cust_acct_site_id
                             from HZ_PARTY_SITES PS, HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES CS
                        WHERE PS.PARTY_SITE_ID = CS.PARTY_SITE_ID
                        AND LOC.LOCATION_ID = PS.LOCATION_ID
   			AND CS.rowid = x_rowid);
 END Address_Update_Row;


/***************************************************************************************/
 PROCEDURE Address_Lock_Row( 	X_rowid IN OUT NOCOPY VARCHAR2,
			X_org_id NUMBER,
			X_status VARCHAR2,
			X_orig_system_reference VARCHAR2,
			X_country VARCHAR2,
			X_address1 VARCHAR2,
			X_address2 VARCHAR2,
			X_address3 VARCHAR2,
			X_address4 VARCHAR2,
			X_city VARCHAR2,
			X_postal_code VARCHAR2,
			X_state VARCHAR2,
			X_province VARCHAR2,
			X_county VARCHAR2,
			X_address_key VARCHAR2,
			X_language VARCHAR2,
			X_address_lines_phonetic VARCHAR2,
			X_customer_category_code VARCHAR2,
			X_ece_tp_location_code VARCHAR2,
			X_stp_common_ref VARCHAR2,
			X_stp_alt_addr VARCHAR2,
			X_stp_supplier VARCHAR2,
			X_stp_site_inactive_date DATE) IS
		CURSOR C IS
		SELECT CS.ORG_ID,
		CS.STATUS,
		CS.orig_system_reference,
		LOC.country,
		LOC.address1,
		LOC.address2,
		LOC.address3,
		LOC.address4,
		LOC.city,
		LOC.postal_code,
		LOC.state,
		LOC.province,
		LOC.county ,
		LOC.address_key,
		LOC.language,
		LOC.address_lines_phonetic,
		CS.customer_category_code,
		CS.ece_tp_location_code
		FROM HZ_PARTY_SITES PS, HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES CS
                WHERE        PS.PARTY_SITE_ID = CS.PARTY_SITE_ID
                        AND LOC.LOCATION_ID = PS.LOCATION_ID
   			AND CS.rowid = x_rowid
		FOR UPDATE OF CS.cust_acct_site_id NOWAIT;

		RecAddr C%ROWTYPE;

		CURSOR C1 IS
		SELECT *
		FROM igi_ra_addresses ira
		WHERE	ira.address_id = (select CS.cust_acct_site_id
                                          from HZ_PARTY_SITES PS, HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES CS
                        WHERE PS.PARTY_SITE_ID = CS.PARTY_SITE_ID
                        AND LOC.LOCATION_ID = PS.LOCATION_ID
   			AND CS.rowid = x_rowid)
		FOR UPDATE OF ira.address_Id NOWAIT;

		RecAddr1 C1%ROWTYPE;

	BEGIN
		OPEN C;
		FETCH C INTO RecAddr;
		IF (C%NOTFOUND) THEN
			CLOSE C;
			FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
                        --bug 3199481 fnd logging changes: sdixit
                        IF (l_excep_level >=  l_debug_level ) THEN
                            FND_LOG.MESSAGE (l_excep_level ,
                                 'igi.pls.igistpab.IGI_STP_TABLE_HANDLER_PKG.Address_Lock_Row.msg1',
                                 FALSE);
                        END IF;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		CLOSE C;

		OPEN C1;
		FETCH C1 INTO RecAddr1;
		IF (C1%NOTFOUND) THEN
			CLOSE C1;
			FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
                        --bug 3199481 fnd logging changes: sdixit
                        IF (l_excep_level >=  l_debug_level ) THEN
                            FND_LOG.MESSAGE (l_excep_level ,
                                 'igi.pls.igistpab.IGI_STP_TABLE_HANDLER_PKG.Address_Lock_Row.msg2',
                                 FALSE);
                        END IF;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		CLOSE C1;

		IF (
		      (   (RecAddr.org_id = X_org_id)
		      OR  (    (RecAddr.org_id IS NULL)
		          AND  (X_org_id IS NULL)
			   )
		       )
		 AND   (RecAddr.status = X_status)
		 AND  (RecAddr.orig_system_reference = X_orig_system_reference)
		 AND  (RecAddr.country = X_country)
		 AND  (RecAddr.address1 = X_address1)
		 AND  (	  (RecAddr.address2 = X_address2)
		      OR  (    (RecAddr.address2 IS NULL)
			  AND  (X_address2 IS NULL)))
		 AND  (	  (RecAddr.address3 = X_address3)
		      OR  (    (RecAddr.address3 IS NULL)
			  AND  (X_address3 IS NULL)))
		 AND  (	  (RecAddr.address4 = X_address4)
		      OR  (    (RecAddr.address4 IS NULL)
			  AND  (X_address4 IS NULL)))
		 AND  (	  (RecAddr.city = X_city)
		      OR  (    (RecAddr.city IS NULL)
			  AND  (X_city IS NULL)))
		 AND  (	  (RecAddr.postal_code = X_postal_code)
		      OR  (    (RecAddr.postal_code IS NULL)
			  AND  (X_postal_code IS NULL)))
		 AND  (	  (RecAddr.state = X_state)
		      OR  (    (RecAddr.state IS NULL)
			  AND  (X_state IS NULL)))
		 AND  (	  (RecAddr.province = X_province)
		      OR  (    (RecAddr.province IS NULL)
			  AND  (X_province IS NULL)))
		 AND  (	  (RecAddr.county = X_county)
		      OR  (    (RecAddr.county IS NULL)
			  AND  (X_county IS NULL)))
		 AND  (	  (RecAddr.address_key = X_address_key)
		      OR  (    (RecAddr.address_key IS NULL)
			  AND  (X_address_key IS NULL)))
		 AND  (	  (RecAddr.language = X_language)
		      OR  (    (RecAddr.language IS NULL)
			  AND  (X_language IS NULL)))
		 AND  (	  (RecAddr.address_lines_phonetic = X_address_lines_phonetic)
		      OR  (    (RecAddr.address_lines_phonetic IS NULL)
			  AND  (X_address_lines_phonetic IS NULL)))
		 AND  (	  (RecAddr.customer_category_code = X_customer_category_code)
		      OR  (    (RecAddr.customer_category_code IS NULL)
			  AND  (X_customer_category_code IS NULL)))
		 AND  (	  (RecAddr.ece_tp_location_code = X_ece_tp_location_code)
		      OR  (    (RecAddr.ece_tp_location_code IS NULL)
			  AND  (X_ece_tp_location_code IS NULL)))
		 AND  (RecAddr1.stp_common_ref = X_stp_common_ref)
		 AND  (	  (RecAddr1.stp_alt_addr = X_stp_alt_addr)
		      OR  (    (RecAddr1.stp_alt_addr IS NULL)
			  AND  (X_stp_alt_addr IS NULL)))
		 AND  (	  (RecAddr1.stp_supplier = X_stp_supplier)
		      OR  (    (RecAddr1.stp_supplier IS NULL)
			  AND  (X_stp_supplier IS NULL)))
		 AND  (	  (RecAddr1.stp_site_inactive_date = X_stp_site_inactive_date)
		      OR  (    (RecAddr1.stp_site_inactive_date IS NULL)
			  AND  (X_stp_site_inactive_date IS NULL)))
		     ) THEN
		     return;
		ELSE

		    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                    --bug 3199481 fnd logging changes: sdixit
                    IF (l_excep_level >=  l_debug_level ) THEN
                        FND_LOG.MESSAGE (l_excep_level ,
                        'igi.pls.igistpab.IGI_STP_TABLE_HANDLER_PKG.Address_Lock_Row',
                        FALSE);
                    END IF;
		    APP_EXCEPTION.Raise_Exception;
		 END IF;

	END Address_Lock_Row;

/***************************************************************************************/
 PROCEDURE Site_Insert_Row( 	X_Rowid IN VARCHAR2,
			X_vendor_site_id NUMBER,
			X_vendor_id NUMBER,
			X_vendor_site_code VARCHAR2,
			X_purchasing_site_flag VARCHAR2,
			X_rfq_only_site_flag VARCHAR2,
			X_pay_site_flag VARCHAR2,
			X_attention_ar_flag VARCHAR2,
			X_address_line1 VARCHAR2,
			X_address_line2 VARCHAR2,
			X_address_line3 VARCHAR2,
			X_city VARCHAR2,
			X_state VARCHAR2,
			X_zip VARCHAR2,
			X_province VARCHAR2,
			X_country VARCHAR2,
			X_customer_num VARCHAR2,
			X_ship_to_location_id NUMBER,
			X_bill_to_location_id NUMBER,
			X_inactive_date DATE,
			X_payment_method_lookup_code VARCHAR2,
			X_terms_date_basis VARCHAR2,
			X_vat_code VARCHAR2,
			X_accts_pay_code_comb_id NUMBER,
			X_prepay_code_combination_id NUMBER,
			X_pay_group_lookup_code VARCHAR2,
			X_payment_priority NUMBER,
			X_terms_id NUMBER,
			X_pay_date_basis_lookup_code VARCHAR2,
			X_always_take_disc_flag VARCHAR2,
			X_invoice_currency_code VARCHAR2,
			X_payment_currency_code VARCHAR2,
			X_hold_all_payments_flag VARCHAR2,
			X_hold_future_payments_flag VARCHAR2,
			X_hold_unmatched_inv_flag VARCHAR2,
			X_exclusive_payment_flag VARCHAR2,
			X_tax_reporting_site_flag VARCHAR2,
			X_validation_number NUMBER,
			X_excl_freight_from_discount VARCHAR2,
			X_org_id NUMBER,
			X_address_line4 VARCHAR2,
			X_county VARCHAR2,
			X_address_style VARCHAR2,
			X_language VARCHAR2,
			X_allow_awt_flag VARCHAR2,
			X_auto_tax_calc_flag VARCHAR2,
			X_auto_tax_calc_override VARCHAR2,
			X_amount_includes_tax_flag VARCHAR2,
			X_ap_tax_rounding_rule VARCHAR2,
			X_vendor_site_code_alt VARCHAR2,
			X_address_lines_alt VARCHAR2,
			X_bank_charge_bearer VARCHAR2,
			X_ece_tp_location_code VARCHAR2,
			X_pcard_site_flag VARCHAR2,
			X_creation_date	DATE,
			X_created_by NUMBER,
			X_last_update_login NUMBER,
			X_last_update_date DATE,
			X_last_updated_by NUMBER,
                        X_fin_match_option VARCHAR2 ) IS



		    l_vendor_site_rec    	 ap_vendor_pub_pkg.r_vendor_site_rec_type;
		    l_return_status 	 varchar2(2000);
		    l_msg_count 		 NUMBER;
		    l_msg_data 		 VARCHAR2(2000);
		    l_vendor_site_id		 AP_SUPPLIERS.VENDOR_ID%TYPE;
		    l_party_site_id		 HZ_PARTY_SITES.party_site_id %TYPE;
		    l_location_id                HZ_LOCATIONS.location_id%type;

	CURSOR C IS SELECT rowid FROM ap_supplier_sites
		    WHERE vendor_site_id = l_vendor_site_id;

    v_rowid VARCHAR2(25);

 BEGIN


                l_vendor_site_rec.ACCTS_PAY_CODE_COMBINATION_ID	:=  X_accts_pay_code_comb_id  ;
		l_vendor_site_rec.ADDRESS_LINE1   := X_address_line1 ;
		l_vendor_site_rec.ADDRESS_LINE2 := X_address_line2;
		l_vendor_site_rec.ADDRESS_LINE3  := X_address_line3;
		l_vendor_site_rec.ADDRESS_LINE4 :=   X_address_line4;
		l_vendor_site_rec.ADDRESS_LINES_ALT:=  X_address_lines_alt;
		l_vendor_site_rec.ADDRESS_STYLE  := X_address_style;
		l_vendor_site_rec.ALLOW_AWT_FLAG :=	X_allow_awt_flag ;
		l_vendor_site_rec.ALWAYS_TAKE_DISC_FLAG	  := X_always_take_disc_flag;
		l_vendor_site_rec.BANK_CHARGE_BEARER	:= x_bank_charge_bearer ;
		l_vendor_site_rec.BILL_TO_LOCATION_ID	:= x_bill_to_location_id;
		l_vendor_site_rec.CITY:= x_city ;
		l_vendor_site_rec.COUNTRY         	:= x_country ;
		l_vendor_site_rec.COUNTY          	:= x_county ;
		l_vendor_site_rec.CUSTOMER_NUM	:= x_customer_num ;
		l_vendor_site_rec.ECE_TP_LOCATION_CODE	:= x_ece_tp_location_code;
		l_vendor_site_rec.MATCH_OPTION	:= x_fin_match_option ;
		l_vendor_site_rec.HOLD_ALL_PAYMENTS_FLAG	:= x_hold_all_payments_flag ;
		l_vendor_site_rec.HOLD_FUTURE_PAYMENTS_FLAG	:= x_hold_future_payments_flag ;
		l_vendor_site_rec.HOLD_UNMATCHED_INVOICES_FLAG	:= x_hold_unmatched_inv_flag ;
		l_vendor_site_rec.INACTIVE_DATE	:= x_inactive_date ;
		l_vendor_site_rec.INVOICE_CURRENCY_CODE	:= x_invoice_currency_code ;
		l_vendor_site_rec.LANGUAGE        	:= x_language ;
		l_vendor_site_rec.LAST_UPDATE_DATE	:= x_last_update_date ;
		l_vendor_site_rec.LAST_UPDATED_BY	:= x_last_updated_by ;
		l_vendor_site_rec.ORG_ID	:= x_org_id ;
		l_vendor_site_rec.PAY_DATE_BASIS_LOOKUP_CODE	:= x_pay_date_basis_lookup_code;
		l_vendor_site_rec.PAY_GROUP_LOOKUP_CODE	:= x_pay_group_lookup_code ;
		l_vendor_site_rec.PAY_SITE_FLAG	:= x_pay_site_flag ;
		l_vendor_site_rec.PAYMENT_CURRENCY_CODE	:= x_payment_currency_code ;
		l_vendor_site_rec.PAYMENT_PRIORITY	:= x_payment_priority ;
		l_vendor_site_rec.PCARD_SITE_FLAG	:= x_pcard_site_flag ;
		l_vendor_site_rec.PREPAY_CODE_COMBINATION_ID	:= x_prepay_code_combination_id;
		l_vendor_site_rec.PROVINCE        	:= x_province ;
		l_vendor_site_rec.PURCHASING_SITE_FLAG	:= x_purchasing_site_flag ;
		l_vendor_site_rec.RFQ_ONLY_SITE_FLAG	:= x_rfq_only_site_flag ;
		l_vendor_site_rec.SHIP_TO_LOCATION_ID	:= x_ship_to_location_id ;
		l_vendor_site_rec.STATE           	:= x_state ;
		l_vendor_site_rec.TAX_REPORTING_SITE_FLAG	:= x_tax_reporting_site_flag;
		l_vendor_site_rec.TERMS_DATE_BASIS	:= x_terms_date_basis ;
		l_vendor_site_rec.TERMS_ID	:= x_terms_id ;
		l_vendor_site_rec.VALIDATION_NUMBER	:= x_validation_number;
		l_vendor_site_rec.VENDOR_ID	:= x_vendor_id ;
		l_vendor_site_rec.VENDOR_SITE_CODE	:= x_vendor_site_code ;
		l_vendor_site_rec.VENDOR_SITE_CODE_ALT	:= x_vendor_site_code_alt ;
		l_vendor_site_rec.VENDOR_SITE_ID	:= x_vendor_site_id ;
		l_vendor_site_rec.ZIP             	:= x_zip ;



		AP_VENDOR_PUB_PKG.Create_Vendor_Site
		(p_api_version => 1.0,
		 p_init_msg_list => FND_API.G_TRUE,
		 p_commit =>FND_API.G_FALSE,
		 p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
		 x_return_status      => l_return_status,
		 x_msg_count          => l_msg_count,
        	 x_msg_data           => l_msg_data,
        	 p_vendor_site_rec => l_vendor_site_rec,
        	 x_vendor_site_id => l_vendor_site_id,
        	 x_party_site_id => l_party_site_id,
        	 x_location_id => l_location_id);



		OPEN C;
		FETCH C INTO v_rowid;
		IF (C%NOTFOUND) THEN
			CLOSE C;
			Raise NO_DATA_FOUND;
		END IF;
		CLOSE C;
 END Site_Insert_Row;

/***************************************************************************************/
 PROCEDURE Site_Update_Row(X_vendor_site_id IN number,
			X_vendor_site_code VARCHAR2,
			X_address_line1 VARCHAR2,
			X_address_line2 VARCHAR2,
			X_address_line3 VARCHAR2,
			X_city VARCHAR2,
			X_state VARCHAR2,
			X_zip VARCHAR2,
			X_province VARCHAR2,
			X_country VARCHAR2,
			X_inactive_date DATE,
			X_org_id NUMBER,
			X_address_line4 VARCHAR2,
			X_county VARCHAR2,
			X_address_style VARCHAR2,
			X_language VARCHAR2,
			X_vendor_site_code_alt VARCHAR2,
			X_address_lines_alt VARCHAR2,
			X_bank_charge_bearer VARCHAR2,
			X_ece_tp_location_code VARCHAR2,
			X_pay_site_flag VARCHAR2,
			X_address_lines_phonetic VARCHAR2,
			X_last_update_login NUMBER,
			X_last_update_date DATE,
			X_last_updated_by NUMBER) IS

			l_vendor_site_rec    	 ap_vendor_pub_pkg.r_vendor_site_rec_type;


			l_return_status 	 varchar2(2000);
			l_msg_count 		 NUMBER;
			l_msg_data 		 VARCHAR2(2000);
			l_vendor_site_id		 AP_SUPPLIERS.VENDOR_ID%TYPE;
			l_party_site_id		 HZ_PARTY_SITES.party_site_id %TYPE;
		        l_location_id                HZ_LOCATIONS.location_id%type;


			l_location_rec   hz_location_v2pub.location_rec_type;
                        l_object_version_number number;
			cursor c_loc is select LOC.LOCATION_ID from HZ_PARTY_SITES PS, HZ_LOCATIONS LOC,AP_SUPPLIER_SITES_ALL AP
			                        WHERE PS.PARTY_SITE_ID = AP.PARTY_SITE_ID
			                        AND LOC.LOCATION_ID = PS.LOCATION_ID
			                        AND LOC.LOCATION_ID = AP.LOCATION_ID
   			                        AND AP.vendor_site_id = X_vendor_site_id
   			                        AND AP.ORG_ID = X_org_id;

   			   cursor c_obj_version_loc (p_location_id hz_locations.location_id%type) is
   				select object_version_number
   				from hz_locations
   				where (location_id = p_location_id);



   			l_party_site_rec    hz_party_site_v2pub.party_site_rec_type;
   			cursor c_party is select PS.party_site_id from HZ_PARTY_SITES PS, HZ_LOCATIONS LOC, AP_SUPPLIER_SITES_ALL AP
                        WHERE PS.PARTY_SITE_ID = AP.PARTY_SITE_ID
   			AND AP.vendor_site_id = X_vendor_site_id
   			AND AP.ORG_ID = X_org_id;

   			   cursor c_obj_version_site (p_party_site_id hz_party_sites.party_site_id%type) is
			   select object_version_number
			   from hz_party_sites
   			   where (party_site_id = p_party_site_id);
 BEGIN

    OPEN C_LOC;
    FETCH C_LOC INTO l_location_id;
    IF (C_LOC%NOTFOUND) THEN
       CLOSE C_LOC;
       Raise NO_DATA_FOUND;
    END IF;


    CLOSE C_LOC;


        l_location_rec.location_id := l_location_id;
        l_location_rec.country := NVL(X_country,fnd_api.g_miss_char);
        l_location_rec.address1 := NVL(X_address_line1,fnd_api.g_miss_char);
        l_location_rec.address2 := NVL(X_address_line2,fnd_api.g_miss_char);
        l_location_rec.address3 := NVL(X_address_line3,fnd_api.g_miss_char);
        l_location_rec.address4 := NVL(X_address_line4,fnd_api.g_miss_char);
        l_location_rec.city := NVL(x_city,fnd_api.g_miss_char);
        l_location_rec.postal_code := NVL(X_zip,fnd_api.g_miss_char);
        l_location_rec.state := NVL(x_state,fnd_api.g_miss_char);
        l_location_rec.province := NVL(x_province,fnd_api.g_miss_char);
        l_location_rec.county := NVL(x_county,fnd_api.g_miss_char);
        l_location_rec.language := NVL(x_language,fnd_api.g_miss_char);
        --l_location_rec.address_lines_phonetic := NVL(x_address_lines_phonetic,fnd_api.g_miss_char);


            OPEN C_PARTY;
	    FETCH C_PARTY INTO l_party_site_id;
	    IF (C_PARTY%NOTFOUND) THEN
	       CLOSE C_PARTY;
	       Raise NO_DATA_FOUND;
	    END IF;
	    CLOSE C_PARTY;


	    l_party_site_rec.party_site_id             := l_party_site_id;
	    select decode(X_pay_site_flag,'Y','A','I') into l_party_site_rec.status from dual;
            --l_party_site_rec.created_by_module	       := 'AP_SUPPLIERS_API';


                OPEN c_obj_version_loc (l_location_id);
	        FETCH c_obj_version_loc INTO l_object_version_number;
	        CLOSE c_obj_version_loc;


	        hz_location_v2pub.update_location
	        (
	            'T',
	            l_location_rec,
	            l_object_version_number,
	            l_return_status,
	            l_msg_count,
	            l_msg_data
                );



                 commit;



                 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		        RETURN;
                 END IF;

                 l_object_version_number := NULL;

		        OPEN c_obj_version_site (l_party_site_id);
		     	FETCH c_obj_version_site INTO l_object_version_number;
		     	CLOSE c_obj_version_site;


		         hz_party_site_v2pub.update_party_site
		         (
		          	p_init_msg_list     => fnd_api.g_false,
		          	p_party_site_rec    => l_party_site_rec,
		          	p_object_version_number => l_object_version_number,
		          	x_return_status      => l_return_status,
		                 x_msg_count          => l_msg_count,
		                 x_msg_data           => l_msg_data
                         );



                 commit;



                          l_object_version_number := NULL;
                                         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
					        RETURN;
                                          END IF;



		                   /*  l_vendor_site_rec.VENDOR_SITE_CODE	:= x_vendor_site_code ;
		                    l_vendor_site_rec.ADDRESS_LINE1   :=  NVL(X_address_line1, fnd_api.g_miss_char);
				    l_vendor_site_rec.ADDRESS_LINE2 :=  NVL(X_address_line2, fnd_api.g_miss_char);
				    l_vendor_site_rec.ADDRESS_LINE3  := NVL(X_address_line3, fnd_api.g_miss_char);
				    l_vendor_site_rec.CITY:= NVL(x_city, fnd_api.g_miss_char);
				    l_vendor_site_rec.STATE           	:= NVL(x_state, fnd_api.g_miss_char);
				    l_vendor_site_rec.ZIP             	:= NVL(X_zip, fnd_api.g_miss_char);
				    l_vendor_site_rec.PROVINCE        	:=  NVL(x_state, fnd_api.g_miss_char);
				    l_vendor_site_rec.COUNTRY         	:= x_country ;
				    l_vendor_site_rec.INACTIVE_DATE	:= x_inactive_date ;
				    l_vendor_site_rec.ORG_ID	:= X_org_id ;
				    l_vendor_site_rec.ADDRESS_LINE4 :=   NVL(X_address_line4, fnd_api.g_miss_char);
				    l_vendor_site_rec.COUNTY          	:= NVL(x_county, fnd_api.g_miss_char);
				    l_vendor_site_rec.ADDRESS_STYLE  := X_address_style;
				    l_vendor_site_rec.LANGUAGE        	:= NVL(x_language, fnd_api.g_miss_char);
				    l_vendor_site_rec.VENDOR_SITE_CODE	:= x_vendor_site_code ;
				    l_vendor_site_rec.ADDRESS_LINES_ALT:=  X_address_lines_alt;
				    l_vendor_site_rec.BANK_CHARGE_BEARER	:= x_bank_charge_bearer ;
				    l_vendor_site_rec.ECE_TP_LOCATION_CODE	:= x_ece_tp_location_code;
				    l_vendor_site_rec.PAY_SITE_FLAG	:= x_pay_site_flag ;
				    l_vendor_site_rec.LAST_UPDATE_DATE	:= x_last_update_date ;
				    l_vendor_site_rec.LAST_UPDATED_BY	:= x_last_updated_by ;




				     AP_VENDOR_PUB_PKG.update_Vendor_Site
				    		(p_api_version => 1.0,
				    		 p_init_msg_list => FND_API.G_TRUE,
				    		 p_commit =>FND_API.G_FALSE,
				    		 p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
				    		 x_return_status      => l_return_status,
				    		 x_msg_count          => l_msg_count,
				            	 x_msg_data           => l_msg_data,
				            	 p_vendor_site_rec => l_vendor_site_rec,
				            	 p_vendor_site_id => X_vendor_site_id
				            	); */

				    AP_TCA_SUPPLIER_SYNC_PKG.SYNC_Supplier_Sites(l_return_status,
				    						 l_msg_count,
		                                                                 l_msg_data,
                                                                                 l_location_id,
                                                                                 l_party_site_id);



		IF (SQL%NOTFOUND) THEN
			Raise NO_DATA_FOUND;
		END IF;
 END Site_Update_Row;

/***************************************************************************************/
 PROCEDURE Site_Lock_Row(X_vendor_site_id IN number,
			X_vendor_site_code VARCHAR2,
			X_address_line1 VARCHAR2,
			X_address_line2 VARCHAR2,
			X_address_line3 VARCHAR2,
			X_city VARCHAR2,
			X_state VARCHAR2,
			X_zip VARCHAR2,
			X_province VARCHAR2,
			X_country VARCHAR2,
			X_inactive_date DATE,
			X_org_id NUMBER,
			X_address_line4 VARCHAR2,
			X_county VARCHAR2,
			X_address_style VARCHAR2,
			X_language VARCHAR2,
			X_vendor_site_code_alt VARCHAR2,
			X_address_lines_alt VARCHAR2,
			X_bank_charge_bearer VARCHAR2,
			X_ece_tp_location_code VARCHAR2) IS
		CURSOR C IS
		SELECT *
		FROM ap_supplier_sites_all
		WHERE	vendor_site_id = X_vendor_site_id
		and org_id = x_org_id
		FOR UPDATE OF vendor_site_id NOWAIT;

		RecSite C%ROWTYPE;

	BEGIN
		OPEN C;
		FETCH C INTO RecSite;
		IF (C%NOTFOUND) THEN
			CLOSE C;
			FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
                        --bug 3199481 fnd logging changes: sdixit
                        IF (l_excep_level >=  l_debug_level ) THEN
                            FND_LOG.MESSAGE (l_excep_level ,
                           'igi.pls.igistpab.IGI_STP_TABLE_HANDLER_PKG.Site_Lock_Row',FALSE);
                        END IF;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		CLOSE C;

		IF (
		      (RecSite.vendor_site_code = X_vendor_site_code)
		 AND  (	  (RecSite.address_line1 = X_address_line1)
		      OR  (    (RecSite.address_line1 IS NULL)
			  AND  (X_address_line1 IS NULL)))
		 AND  (	  (RecSite.address_line2 = X_address_line2)
		      OR  (    (RecSite.address_line2 IS NULL)
			  AND  (X_address_line2 IS NULL)))
		 AND  (	  (RecSite.address_line3 = X_address_line3)
		      OR  (    (RecSite.address_line3 IS NULL)
			  AND  (X_address_line3 IS NULL)))
		 AND  (	  (RecSite.city = X_city)
		      OR  (    (RecSite.city IS NULL)
			  AND  (X_city IS NULL)))
		 AND  (	  (RecSite.state = X_state)
		      OR  (    (RecSite.state IS NULL)
			  AND  (X_state IS NULL)))
		 AND  (	  (RecSite.zip = X_zip)
		      OR  (    (RecSite.zip IS NULL)
			  AND  (X_zip IS NULL)))
		 AND  (	  (RecSite.province = X_province)
		      OR  (    (RecSite.province IS NULL)
			  AND  (X_province IS NULL)))
		 AND  (	  (RecSite.country = X_country)
		      OR  (    (RecSite.country IS NULL)
			  AND  (X_country IS NULL)))
		 AND  (	  (RecSite.inactive_date = X_inactive_date)
		      OR  (    (RecSite.inactive_date IS NULL)
			  AND  (X_inactive_date IS NULL)))
		 AND  (	  (RecSite.org_id = X_org_id)
		      OR  (    (RecSite.org_id IS NULL)
			  AND  (X_org_id IS NULL)))
		 AND  (	  (RecSite.address_line4 = X_address_line4)
		      OR  (    (RecSite.address_line4 IS NULL)
			  AND  (X_address_line4 IS NULL)))
		 AND  (	  (RecSite.county = X_county)
		      OR  (    (RecSite.county IS NULL)
			  AND  (X_county IS NULL)))
		 AND  (	  (RecSite.address_style = X_address_style)
		      OR  (    (RecSite.address_style IS NULL)
			  AND  (X_address_style IS NULL)))
		 AND  (	  (RecSite.language = X_language)
		      OR  (    (RecSite.language IS NULL)
			  AND  (X_language IS NULL)))
		 AND  (	  (RecSite.vendor_site_code_alt = X_vendor_site_code_alt)
		      OR  (    (RecSite.vendor_site_code_alt IS NULL)
			  AND  (X_vendor_site_code_alt IS NULL)))
		 AND  (	  (RecSite.address_lines_alt = X_address_lines_alt)
		      OR  (    (RecSite.address_lines_alt IS NULL)
			  AND  (X_address_lines_alt IS NULL)))
		 AND  (	  (RecSite.bank_charge_bearer = X_bank_charge_bearer)
		      OR  (    (RecSite.bank_charge_bearer IS NULL)
			  AND  (X_bank_charge_bearer IS NULL)))
		 AND  (	  (RecSite.ece_tp_location_code = X_ece_tp_location_code)
		      OR  (    (RecSite.ece_tp_location_code IS NULL)
			  AND  (X_ece_tp_location_code IS NULL)))
		     ) THEN
		     return;
		ELSE
		    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                        --bug 3199481 fnd logging changes: sdixit
                    IF (l_excep_level >=  l_debug_level ) THEN
                        FND_LOG.MESSAGE (l_excep_level ,
                        'igi.pls.igistpab.IGI_STP_TABLE_HANDLER_PKG.Site_Lock_Row',
                        FALSE);
                        END IF;
		    APP_EXCEPTION.Raise_Exception;
		 END IF;

	END Site_Lock_Row;

/***************************************************************************************/
PROCEDURE Customer_Insert_Row( X_rowid IN OUT NOCOPY VARCHAR2,
			X_customer_id NUMBER,
			X_customer_name VARCHAR2,
			X_customer_number OUT NOCOPY VARCHAR2,
			X_customer_key VARCHAR2,
			X_status VARCHAR2,
			X_stp_enforce_threshold VARCHAR2,
			X_orig_system_reference VARCHAR2,
			X_customer_prospect_code VARCHAR2,
			X_customer_type VARCHAR2,
			X_tax_reference VARCHAR2,
			X_gsa_indicator VARCHAR2,
			X_jgzz_fiscal_code VARCHAR2,
			X_warehouse_id NUMBER,
			X_competitor_flag VARCHAR2,
			X_reference_use_flag VARCHAR2,
			X_third_party_flag VARCHAR2,
			X_customer_name_phonetic VARCHAR2,
			X_stp_type VARCHAR2,
			X_creation_date	DATE,
			X_created_by NUMBER,
			X_last_update_login NUMBER,
			X_last_update_date DATE,
			X_last_updated_by NUMBER,
                        X_party_id NUMBER,
                        X_party_number VARCHAR2,
                        X_party_type VARCHAR2,
                        X_account_replication_key NUMBER  ) IS

        l_party_rec                     HZ_PARTY_V2PUB.PARTY_REC_TYPE;
        l_organization_rec 		HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
        l_customer_profile_rec		HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
	l_return_status 		VARCHAR2(2000);
	l_msg_count 		NUMBER;
	l_msg_data 		VARCHAR2(2000);
	l_party_id 			NUMBER ;
	l_party_number 		VARCHAR2(2000);
	l_profile_id 			NUMBER;

	l_cust_account_rec              HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
	l_account_number		NUMBER;
	l_cust_account_id		number;

	c_party_id number(15);
        c_customer_id number(15);

	CURSOR C IS SELECT party_id FROM hz_parties
		    WHERE party_id = X_party_id;
	CURSOR C1 IS SELECT rowid FROM hz_cust_accounts
		    WHERE cust_account_id = X_customer_id;
	CURSOR C2 IS SELECT customer_id FROM igi_ra_customers
		    WHERE customer_id = X_customer_id;

	CURSOR c_gen_cust_num IS
	SELECT generate_customer_number
	FROM ar_system_parameters;

	l_gen_cust_num varchar2(1);
	l_profile_value varchar2(100);	-- For capturing the value returned by fnd_profile.get
 BEGIN
        --fnd_log.string(1,'IGI_STP','In Customer Insert');

 	l_party_rec.party_id               := X_party_id;


	FND_PROFILE.GET('HZ_GENERATE_PARTY_NUMBER', l_profile_value);

	IF (l_profile_value = 'N') THEN
		l_party_rec.party_number := X_party_number;
	ELSE
		l_party_rec.party_number := NULL;
	END IF;

 	l_party_rec.orig_system_reference  := X_orig_system_reference;
 	l_party_rec.status		   := X_status;
 	l_organization_rec.organization_name := X_customer_name;
 	l_organization_rec.tax_reference     := X_tax_reference;
 	l_organization_rec.jgzz_fiscal_code  := X_jgzz_fiscal_code;
 	l_organization_rec.content_source_type := 'USER_ENTERED';
 	l_organization_rec.created_by_module := 'IGI_STP';
 	l_organization_rec.party_rec         := l_party_rec;

 	l_cust_account_rec.cust_account_id   := X_customer_id;

 	OPEN c_gen_cust_num;
 	FETCH c_gen_cust_num INTO l_gen_cust_num;
 	IF (l_gen_cust_num <> 'Y') THEN
 		SELECT hz_cust_accounts_s.nextval INTO X_Customer_Number
 		FROM dual;
 	END IF;
 	CLOSE c_gen_cust_num;

 	l_cust_account_rec.account_number	  := X_customer_number; /* Please check */
 	l_cust_account_rec.status		  := X_status;
 	l_cust_account_rec.orig_system_reference  := X_orig_system_reference;
 	l_cust_account_rec.customer_type	  := X_customer_type;
--
--   Bug 2918737 Start
--
-- 	l_cust_account_rec.warehouse_id		  := X_warehouse_id;
--
--   Bug 2918737 End
--
 	l_cust_account_rec.created_by_module	  := 'IGI_STP';


 	hz_party_v2pub.create_organization
 	(
 		p_init_msg_list      => fnd_api.g_true,
 		p_organization_rec   => l_organization_rec,
 		x_return_status      => l_return_status,
         	x_msg_count          => l_msg_count,
        	x_msg_data           => l_msg_data,
        	x_party_id 	     => l_party_id,
        	x_party_number       => l_party_number,
        	x_profile_id         => l_profile_id
        );





	OPEN C;
	FETCH C INTO c_party_id;
	IF (C%NOTFOUND) THEN
		CLOSE C;
		Raise NO_DATA_FOUND;
	END IF;
	CLOSE C;


        hz_cust_account_v2pub.create_cust_account
        (
      	    p_init_msg_list         => fnd_api.g_true,
    	    p_cust_account_rec	=> l_cust_account_rec,
    	    p_organization_rec	=> l_organization_rec,
    	    p_customer_profile_rec  => l_customer_profile_rec,
    	    p_create_profile_amt    => fnd_api.g_true,
    	    x_cust_account_id	=> l_cust_account_id,
    	    x_account_number 	=> l_account_number,
    	    x_party_id		=> l_party_id,
    	    x_party_number		=> l_party_number,
    	    x_profile_id		=> l_profile_id,
    	    x_return_status		=> l_return_status,
    	    x_msg_count		=> l_msg_count,
    	    x_msg_data		=> l_msg_data
        );

        X_Customer_Number := l_account_number;	-- Assign the account number returned to the OUT variable X_Customer_Number so that the same can be reflected in the form

    	OPEN C1;
	FETCH C1 INTO X_ROWID;
	IF (C1%NOTFOUND) THEN
		CLOSE C1;
		Raise NO_DATA_FOUND;
	END IF;
	CLOSE C1;



	INSERT INTO igi_ra_customers(
		customer_id,
		stp_enforce_threshold,
		stp_type,
		creation_date,
		created_by,
		last_update_login,
		last_update_date,
		last_updated_by)
	VALUES(
		X_customer_id,
		X_stp_enforce_threshold,
		X_stp_type,
		X_creation_date,
		X_created_by,
		X_last_update_login,
		X_last_update_date,
		X_last_updated_by);

	OPEN C2;
	FETCH C2 INTO c_customer_id;
	IF (C2%NOTFOUND) THEN
		CLOSE C2;
		Raise NO_DATA_FOUND;
	END IF;
	CLOSE C2;



/*Included the following Insert Statement for Bug 2450283*/
/*The Standard Customer Form(AR) expects a record in hz_organization_profiles.
  So including this insert statement here. The situation arises when STP customer
  is queried in the Core AR Customer Standard Form and modifications are made and saved.*/
/*
		INSERT into hz_organization_profiles
		(ORGANIZATION_PROFILE_ID,
		PARTY_ID,
		ORGANIZATION_NAME,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		CONTENT_SOURCE_TYPE,
		EFFECTIVE_START_DATE)
        	VALUES
		(hz_organization_profiles_s.nextval,
		 X_party_id,
 		 X_customer_name,
 		 X_last_update_date,
		 X_last_updated_by,
 		 X_creation_date,
 		 X_created_by,
 		 'USER_ENTERED',
                 trunc(sysdate));
  */
 END Customer_Insert_Row;
/***************************************************************************************/
 PROCEDURE Customer_Update_Row (X_rowid IN OUT NOCOPY VARCHAR2,
			X_customer_name VARCHAR2,
			X_customer_number VARCHAR2,
			X_customer_key VARCHAR2,
			X_status VARCHAR2,
			X_stp_enforce_threshold VARCHAR2,
			X_orig_system_reference VARCHAR2,
			X_tax_reference VARCHAR2,
			X_jgzz_fiscal_code VARCHAR2,
			X_warehouse_id NUMBER,
			X_customer_name_phonetic VARCHAR2,
			X_stp_type VARCHAR2,
			X_last_update_login NUMBER,
			X_last_update_date DATE,
			X_last_updated_by NUMBER ) IS

	l_party_rec                     HZ_PARTY_V2PUB.PARTY_REC_TYPE;
        l_organization_rec 		HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
	l_return_status 		VARCHAR2(2000);
	l_msg_count 		NUMBER;
	l_msg_data 		VARCHAR2(2000);
	l_party_id 			NUMBER;
	l_party_number 		VARCHAR2(2000);
	l_profile_id 			NUMBER;



	l_cust_account_rec              HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
	l_object_version_number		 NUMBER;
	l_cust_account_id			 NUMBER;

--Bug 3902175
	l_object_cust_version_number NUMBER;

	CURSOR c_all IS
	SELECT nvl(a.object_version_number,fnd_api.G_NULL_NUM),a.party_id,a.cust_account_id,nvl(p.object_version_number,fnd_api.G_NULL_NUM)
	FROM hz_cust_accounts a,hz_parties p
	WHERE a.party_id   = p.party_id
	AND   a.rowid 	   = X_rowid;

 BEGIN


 	OPEN C_ALL;
 	FETCH C_ALL INTO l_object_cust_version_number,l_party_id,l_cust_account_id,l_object_version_number;
 	IF (C_ALL%NOTFOUND) THEN
 	  RAISE NO_DATA_FOUND;
 	  CLOSE C_ALL;
 	END IF;
 	CLOSE C_ALL;


 	l_party_rec.party_id               := l_party_id;
 	l_party_rec.orig_system_reference  := nvl(X_orig_system_reference,fnd_api.G_NULL_CHAR);
 	l_party_rec.status		   := nvl(X_status,fnd_api.G_NULL_CHAR);

 	l_organization_rec.organization_name := nvl(X_customer_name,fnd_api.G_NULL_CHAR);
 	l_organization_rec.tax_reference     := nvl(X_tax_reference,fnd_api.G_NULL_CHAR);
 	l_organization_rec.jgzz_fiscal_code  := nvl(X_jgzz_fiscal_code,fnd_api.G_NULL_CHAR);
 	l_organization_rec.content_source_type := 'USER_ENTERED';
 	l_organization_rec.party_rec         := l_party_rec;


 	l_cust_account_rec.cust_account_id	  := l_cust_account_id;
 	l_cust_account_rec.status	  	  := nvl(X_status,fnd_api.G_NULL_CHAR);


 	hz_party_v2pub.update_organization
 	(
 		p_init_msg_list      => fnd_api.g_false,
 		p_organization_rec   => l_organization_rec,
 		p_party_object_version_number => l_object_version_number,
 		x_profile_id         => l_profile_id,
 		x_return_status      => l_return_status,
         	x_msg_count          => l_msg_count,
        	x_msg_data           => l_msg_data
        );
        l_object_version_number := NULL;


        hz_cust_account_v2pub.update_cust_account
        (
    	    p_init_msg_list         => fnd_api.g_false,
    	    p_cust_account_rec	=> l_cust_account_rec,
    	    p_object_version_number => l_object_cust_version_number,
    	    x_return_status		=> l_return_status,
    	    x_msg_count		=> l_msg_count,
    	    x_msg_data		=> l_msg_data
        );

	UPDATE igi_ra_customers irc
	SET 	stp_enforce_threshold	= X_stp_enforce_threshold,
		stp_type				= X_stp_type,
		last_update_login		= X_last_update_login,
		last_update_date		= X_last_update_date,
		last_updated_by			= X_last_updated_by
	WHERE irc.customer_id = (select a.cust_account_id from hz_cust_accounts a,hz_parties p
				  	     where a.party_id = p.party_id and a.rowid = X_rowid); -- Bug 3902175

	IF (SQL%NOTFOUND) THEN
		Raise NO_DATA_FOUND;
	END IF;
 END Customer_Update_Row;

/***************************************************************************************/
 PROCEDURE Customer_Lock_Row( 	X_rowid IN OUT NOCOPY VARCHAR2,
			X_customer_name VARCHAR2,
			X_customer_number VARCHAR2,
			X_customer_key VARCHAR2,
			X_status VARCHAR2,
		        X_stp_enforce_threshold VARCHAR2,
			X_orig_system_reference VARCHAR2,
			X_tax_reference VARCHAR2,
			X_jgzz_fiscal_code VARCHAR2,
			X_warehouse_id NUMBER,
			X_customer_name_phonetic VARCHAR2,
			X_stp_type VARCHAR2 ) IS

		CURSOR C IS
		SELECT *
		FROM igi_ar_customers_v --bug3514922 sdixit
		WHERE	row_id = X_rowid
		FOR UPDATE OF customer_id NOWAIT;

		RecCust C%ROWTYPE;

		CURSOR C1 IS
		SELECT *
		FROM igi_ra_customers irc
		WHERE irc.customer_id = (select a.cust_account_id from hz_cust_accounts a,hz_parties p  -- Bug 3902175
				  	     	     where a.party_id = p.party_id and a.rowid = X_rowid)
		FOR UPDATE OF irc.customer_id NOWAIT;

		RecCust1 C1%ROWTYPE;

	BEGIN

		OPEN C;
		FETCH C INTO RecCust;
		IF (C%NOTFOUND) THEN
			CLOSE C;
			FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
                        --bug 3199481 fnd logging changes: sdixit
                        IF (l_excep_level >=  l_debug_level ) THEN
                            FND_LOG.MESSAGE (l_excep_level ,
                            'igi.pls.igistpab.IGI_STP_TABLE_HANDLER_PKG.Customer_Lock_Row',
                            FALSE);
                        END IF;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		CLOSE C;

		OPEN C1;
		FETCH C1 INTO RecCust1;
		IF (C1%NOTFOUND) THEN
			CLOSE C1;
			FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
                        --bug 3199481 fnd logging changes: sdixit
                        IF (l_excep_level >=  l_debug_level ) THEN
                        FND_LOG.MESSAGE (l_excep_level ,
                            'igi.pls.igistpab.IGI_STP_TABLE_HANDLER_PKG.Customer_Lock_Row',
                            FALSE);
                        END IF;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		CLOSE C1;

		IF (
		      (RecCust.customer_name = X_customer_name)
		 AND  (RecCust.customer_number = X_customer_number)
		 AND  (	  (RecCust.customer_key = X_customer_key)
		      OR  (    (RecCust.customer_key IS NULL)
			  AND  (X_customer_key IS NULL)))
		 AND  (RecCust.status = X_status)
                 AND  (   (RecCust1.stp_enforce_threshold = X_stp_enforce_threshold)
                      OR  (    (RecCust1.stp_enforce_threshold IS NULL)
                          AND  (X_stp_enforce_threshold IS NULL)))
		 AND  (RecCust.orig_system_reference = X_orig_system_reference)
		 AND  (	  (RecCust.tax_reference = X_tax_reference)
		      OR  (    (RecCust.tax_reference IS NULL)
			  AND  (X_tax_reference IS NULL)))
		 AND  (	  (RecCust.jgzz_fiscal_code = X_jgzz_fiscal_code)
		      OR  (    (RecCust.jgzz_fiscal_code IS NULL)
			  AND  (X_jgzz_fiscal_code IS NULL)))
--		 AND  (	  (RecCust.warehouse_id = X_warehouse_id)  -- Bug 3902175 commented because Lock issue occurs
-- 			    OR  (    (RecCust.warehouse_id IS NULL)
--			    AND  (X_warehouse_id IS NULL)))
--		 AND  (	  (RecCust.customer_name_phonetic = X_customer_name_phonetic)
--		      OR  (    (RecCust.customer_name_phonetic IS NULL)
--			  AND  (X_customer_name_phonetic IS NULL)))
		 AND  (	  (RecCust1.stp_type = X_stp_type)
		      OR  (    (RecCust1.stp_type IS NULL)
			  AND  (X_stp_type IS NULL)))
		     ) THEN
		     return;
		ELSE

		    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                        --bug 3199481 fnd logging changes: sdixit
                        IF (l_excep_level >=  l_debug_level ) THEN
                            FND_LOG.MESSAGE (l_excep_level ,
                            'igi.pls.igistpab.IGI_STP_TABLE_HANDLER_PKG.Customer_Lock_Row',
                            FALSE);
                        END IF;
		    APP_EXCEPTION.Raise_Exception;
		 END IF;

	END Customer_Lock_Row;

/***************************************************************************************/
 PROCEDURE Supplier_Insert_Row( X_rowid IN VARCHAR2,
			X_vendor_id NUMBER,
			X_vendor_name VARCHAR2,
			X_segment1 VARCHAR2,
			X_stp_enforce_threshold VARCHAR2,
			X_summary_flag VARCHAR2,
			X_enabled_flag VARCHAR2,
			X_one_time_flag VARCHAR2,
			X_payment_priority NUMBER,
			X_num_1099 VARCHAR2,
			X_start_date_active DATE,
                        X_end_date_active DATE,
			X_women_owned_flag VARCHAR2,
			X_small_business_flag VARCHAR2,
			X_hold_flag VARCHAR2,
			X_federal_reportable_flag VARCHAR2,
			X_vat_registration_num VARCHAR2,
			X_vendor_name_alt VARCHAR2,
			X_auto_tax_calc_flag VARCHAR2,
			X_auto_tax_calc_override VARCHAR2,
			X_ap_tax_rounding_rule VARCHAR2,
			X_bank_charge_bearer VARCHAR2,
			X_state_reportable_flag VARCHAR2,
			X_amount_includes_tax_flag VARCHAR2,
			X_hold_all_payments_flag VARCHAR2,
			X_hold_future_payments_flag VARCHAR2,
			X_always_take_disc_flag VARCHAR2,
			X_excl_freight_from_discount VARCHAR2,
			X_auto_calc_interest_flag VARCHAR2,
			X_invoice_currency_code VARCHAR2,
			X_payment_currency_code VARCHAR2,
			X_exclusive_payment_flag VARCHAR2,
			X_terms_date_basis VARCHAR2,
			X_pay_date_basis_lookup_code VARCHAR2,
			X_payment_method_lookup_code VARCHAR2,
			X_enforce_ship_to_loc_code VARCHAR2,
			X_qty_rcv_tolerance NUMBER,
			X_qty_rcv_exception_code VARCHAR2,
			X_days_early_receipt_allowed NUMBER,
			X_allow_subst_receipts_flag VARCHAR2,
			X_days_late_receipt_allowed NUMBER,
			X_allow_unord_receipts_flag VARCHAR2,
			X_receipt_days_exception_code VARCHAR2,
			X_allow_awt_flag VARCHAR2,
			X_bill_to_location_id NUMBER,
			X_receiving_routing_id NUMBER,
			X_ship_to_location_id NUMBER,
			X_pay_group_lookup_code VARCHAR2,
			X_terms_id NUMBER,
			X_set_of_books_id NUMBER,
			X_inspection_required_flag VARCHAR2,
			X_receipt_required_flag VARCHAR2,
			X_creation_date	DATE,
			X_created_by NUMBER,
			X_last_update_login NUMBER,
			X_last_update_date DATE,
			X_last_updated_by NUMBER,
                        X_future_dated_payment_ccid NUMBER,
                        X_fin_match_option VARCHAR2,
                        X_po_create_dm_flag VARCHAR2,
                        X_customer_id NUMBER ) IS

        l_vendor_rec    	 ap_vendor_pub_pkg.r_vendor_rec_type;
        l_return_status 	 varchar2(2000);
        l_msg_count 		 NUMBER;
	l_msg_data 		 VARCHAR2(2000);
	l_vendor_id		 AP_SUPPLIERS.VENDOR_ID%TYPE;
	l_party_id		 HZ_PARTIES.PARTY_ID%TYPE;



	CURSOR C IS SELECT rowid FROM AP_SUPPLIERS
		    WHERE vendor_id = l_vendor_id;
	CURSOR C1 IS SELECT vendor_id FROM igi_po_vendors
		    WHERE vendor_id = l_vendor_id;
        c1_vendor_id number(15);

        v_rowid VARCHAR2(25);

 BEGIN



		l_vendor_rec.VENDOR_ID 		:= X_vendor_id;
		l_vendor_rec.SEGMENT1           := X_segment1;
		l_vendor_rec.VENDOR_NAME	:= X_vendor_name;
		l_vendor_rec.ALLOW_AWT_FLAG	:= X_allow_awt_flag;
		l_vendor_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG	:= X_allow_subst_receipts_flag;
		l_vendor_rec.ALLOW_UNORDERED_RECEIPTS_FLAG	:= X_allow_unord_receipts_flag;
		l_vendor_rec.ALWAYS_TAKE_DISC_FLAG	:= X_always_take_disc_flag ;
		l_vendor_rec.AUTO_CALCULATE_INTEREST_FLAG	:= X_auto_calc_interest_flag;
		l_vendor_rec.BANK_CHARGE_BEARER	:= X_bank_charge_bearer;
		l_vendor_rec.DAYS_EARLY_RECEIPT_ALLOWED	:= X_days_early_receipt_allowed;
		l_vendor_rec.DAYS_LATE_RECEIPT_ALLOWED       	:= X_days_late_receipt_allowed ;
		l_vendor_rec.ENABLED_FLAG	:= X_enabled_flag;
		l_vendor_rec.END_DATE_ACTIVE	:= X_end_date_active;
		l_vendor_rec.ENFORCE_SHIP_TO_LOCATION_CODE	:= X_enforce_ship_to_loc_code;
		l_vendor_rec.EXCLUDE_FREIGHT_FROM_DISCOUNT	:= X_excl_freight_from_discount;
		l_vendor_rec.FEDERAL_REPORTABLE_FLAG	:= X_federal_reportable_flag;
		l_vendor_rec.HOLD_ALL_PAYMENTS_FLAG	:= X_hold_all_payments_flag;
		l_vendor_rec.HOLD_FLAG	:= X_hold_flag;
		l_vendor_rec.HOLD_FUTURE_PAYMENTS_FLAG 	:= X_hold_future_payments_flag;
		l_vendor_rec.INSPECTION_REQUIRED_FLAG	:= X_inspection_required_flag;
		l_vendor_rec.INVOICE_CURRENCY_CODE	:= X_invoice_currency_code;
		l_vendor_rec.JGZZ_FISCAL_CODE                	:= X_num_1099 ;
		l_vendor_rec.ONE_TIME_FLAG	:= X_one_time_flag;
		l_vendor_rec.PAY_DATE_BASIS_LOOKUP_CODE 	:= X_pay_date_basis_lookup_code;
		l_vendor_rec.PAY_GROUP_LOOKUP_CODE	:= X_pay_group_lookup_code;
		l_vendor_rec.PAYMENT_CURRENCY_CODE	:= X_payment_currency_code;
		l_vendor_rec.PAYMENT_PRIORITY	:= X_payment_priority;
		l_vendor_rec.QTY_RCV_EXCEPTION_CODE	:= X_qty_rcv_exception_code;
		l_vendor_rec.QTY_RCV_TOLERANCE	:= X_qty_rcv_tolerance;
		l_vendor_rec.RECEIPT_DAYS_EXCEPTION_CODE	:= X_receipt_days_exception_code;
		l_vendor_rec.RECEIPT_REQUIRED_FLAG	:= X_receipt_required_flag ;
		l_vendor_rec.RECEIVING_ROUTING_ID	:= X_receiving_routing_id;
		l_vendor_rec.SEGMENT1	:= X_segment1;
		l_vendor_rec.SET_OF_BOOKS_ID	:= X_set_of_books_id;
		l_vendor_rec.SMALL_BUSINESS_FLAG	:= X_small_business_flag;
		l_vendor_rec.START_DATE_ACTIVE	:= X_start_date_active;
		l_vendor_rec.STATE_REPORTABLE_FLAG	:= X_state_reportable_flag;
		l_vendor_rec.SUMMARY_FLAG	:= X_summary_flag;
		l_vendor_rec.TAX_REFERENCE := X_vat_registration_num;
		l_vendor_rec.TERMS_DATE_BASIS	:= X_terms_date_basis;
		l_vendor_rec.TERMS_ID	:= X_terms_id;
		l_vendor_rec.VENDOR_ID	:= X_vendor_id;
		l_vendor_rec.VENDOR_NAME	:= X_vendor_name;
		l_vendor_rec.VENDOR_NAME_ALT	:= X_vendor_name_alt;
		l_vendor_rec.WOMEN_OWNED_FLAG	:= X_women_owned_flag;



		 ap_vendor_pub_pkg.create_vendor
		(p_init_msg_list      => fnd_api.g_true,
		p_api_version        => 1.0,
		p_commit              => FND_API.G_FALSE,
		p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
		 p_vendor_rec        => l_vendor_rec,
		 x_return_status      => l_return_status,
		 x_msg_count          => l_msg_count,
		 x_msg_data           => l_msg_data,
		 x_vendor_id          => l_vendor_id,
 		 x_party_id           => l_party_id);





		OPEN C;
		FETCH C INTO v_rowid;
		IF (C%NOTFOUND) THEN
			CLOSE C;
			Raise NO_DATA_FOUND;
		END IF;
		CLOSE C;

		INSERT INTO igi_po_vendors(
			vendor_id,
			stp_enforce_threshold,
                        customer_id,
			creation_date,
			created_by,
			last_update_login,
			last_update_date,
			last_updated_by)
		VALUES(
			l_vendor_id,
			X_stp_enforce_threshold,
                        X_customer_id,
			X_creation_date,
			X_created_by,
			X_last_update_login,
			X_last_update_date,
			X_last_updated_by);
		OPEN C1;
		FETCH C1 INTO c1_vendor_id;
		IF (C1%NOTFOUND) THEN
			CLOSE C1;
			Raise NO_DATA_FOUND;
		END IF;
		CLOSE C1;
 END Supplier_Insert_Row;

/***************************************************************************************/
 PROCEDURE Supplier_Update_Row(X_rowid IN VARCHAR2,
			X_vendor_name VARCHAR2,
			X_num_1099 VARCHAR2,
			X_vat_registration_num VARCHAR2,
			X_VENDOR_ID NUMBER,
			X_vendor_name_alt VARCHAR2,
                        X_end_date_active DATE,
                        X_status VARCHAR2,
                        X_orig_system_reference VARCHAR2,
			X_last_update_login NUMBER,
			X_last_update_date DATE,
			X_stp_enforce_threshold VARCHAR2,
			X_last_updated_by NUMBER
			) IS

			 	l_vendor_rec    	 ap_vendor_pub_pkg.r_vendor_rec_type;
			        l_return_status 	 varchar2(2000);
			        l_msg_count 		 NUMBER;
				l_msg_data 		 VARCHAR2(2000);
				l_vendor_id		 AP_SUPPLIERS.VENDOR_ID%TYPE;
				l_party_id		 HZ_PARTIES.PARTY_ID%TYPE;
				l_object_version_number		 NUMBER;
				l_profile_id 			NUMBER;

				 l_party_rec                     HZ_PARTY_V2PUB.PARTY_REC_TYPE;
				 l_organization_rec 		HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
 BEGIN

 select party_id,nvl(object_version_number,fnd_api.G_NULL_NUM) into l_party_id,l_object_version_number from hz_parties where party_name = X_vendor_name and created_by_module = 'AP_SUPPLIERS_API';

  	l_party_rec.party_id               := l_party_id;
  	--l_party_rec.orig_system_reference  := nvl(X_orig_system_reference,fnd_api.G_NULL_CHAR);
 	l_party_rec.status		   := nvl(X_status,fnd_api.G_NULL_CHAR);


	l_organization_rec.organization_name := nvl(X_vendor_name,fnd_api.G_NULL_CHAR);
	l_organization_rec.tax_reference     := nvl(X_vat_registration_num,fnd_api.G_NULL_CHAR);
	l_organization_rec.jgzz_fiscal_code  := nvl(X_num_1099,fnd_api.G_NULL_CHAR);
	l_organization_rec.content_source_type := 'USER_ENTERED';
 	l_organization_rec.party_rec         := l_party_rec;


 	 	hz_party_v2pub.update_organization
	 	(
	 		p_init_msg_list      => fnd_api.g_false,
	 		p_organization_rec   => l_organization_rec,
	 		p_party_object_version_number => l_object_version_number,
	 		x_profile_id         => l_profile_id,
	 		x_return_status      => l_return_status,
	         	x_msg_count          => l_msg_count,
	        	x_msg_data           => l_msg_data
               );

               AP_TCA_SUPPLIER_SYNC_PKG.SYNC_Supplier(l_return_status,
				    		      l_msg_count,
		                                      l_msg_data,
                                                      l_party_id);



		/* l_vendor_rec.VENDOR_NAME	:= X_vendor_name;
		l_vendor_rec.JGZZ_FISCAL_CODE   := nvl(X_num_1099,fnd_api.G_NULL_CHAR);
		l_vendor_rec.TAX_REFERENCE := nvl(X_vat_registration_num,fnd_api.G_NULL_CHAR);
		l_vendor_rec.VENDOR_NAME_ALT	:= X_vendor_name_alt;
		l_vendor_rec.END_DATE_ACTIVE	:= X_end_date_active;




		AP_VENDOR_PUB_PKG.Update_Vendor(
		p_api_version  => 1.0,
		p_init_msg_list => FND_API.G_TRUE,
		p_commit => FND_API.G_FALSE,
		p_validation_level => FND_API.G_VALID_LEVEL_FULL,
		x_return_status      => l_return_status,
		x_msg_count          => l_msg_count,
		x_msg_data           => l_msg_data,
        	p_vendor_rec        => l_vendor_rec,
        	p_vendor_id         => X_VENDOR_ID); */




		UPDATE igi_po_vendors ipv
		SET 	ipv.stp_enforce_threshold     = X_stp_enforce_threshold
                WHERE ipv.vendor_id = (select pv.vendor_id
                                       from AP_SUPPLIERS pv
                                       where pv.rowid = X_rowid);

 END Supplier_Update_Row;

/***************************************************************************************/
 PROCEDURE Supplier_Lock_Row( X_rowid IN VARCHAR2,
			X_vendor_name VARCHAR2,
			X_num_1099 VARCHAR2,
			X_vat_registration_num VARCHAR2,
			X_vendor_name_alt VARCHAR2,
			X_stp_enforce_threshold VARCHAR2,
                        X_end_date_active DATE) IS

		CURSOR C IS
		SELECT *
		FROM ap_suppliers
		WHERE	rowid = X_rowid
		FOR UPDATE OF vendor_id NOWAIT;

		RecSupp C%ROWTYPE;
		CURSOR C1 IS
		SELECT *
		FROM igi_po_vendors ipv
		WHERE ipv.vendor_id = (select pv.vendor_id
                                       from  ap_suppliers pv
                                       where pv.rowid =  X_rowid )
		FOR UPDATE OF ipv.vendor_id NOWAIT;
		RecSupp1 C1%ROWTYPE;

	BEGIN
		OPEN C;
		FETCH C INTO RecSupp;
		IF (C%NOTFOUND) THEN
			CLOSE C;
			FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
                        --bug 3199481 fnd logging changes: sdixit
                        IF (l_excep_level >=  l_debug_level ) THEN
                        FND_LOG.MESSAGE (l_excep_level ,
                            'igi.pls.igistpab.IGI_STP_TABLE_HANDLER_PKG.Supplier_Lock_Row.msg1',
                            FALSE);
                        END IF;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		CLOSE C;
		OPEN C1;
		FETCH C1 INTO RecSupp1;
		IF (C1%NOTFOUND) THEN
			CLOSE C1;
			FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
                        --bug 3199481 fnd logging changes: sdixit
                        IF (l_excep_level >=  l_debug_level ) THEN
                        FND_LOG.MESSAGE (l_excep_level ,
                            'igi.pls.igistpab.IGI_STP_TABLE_HANDLER_PKG.Supplier_Lock_Row.msg2',
                            FALSE);
                        END IF;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		CLOSE C1;

		-- Bug 3079883 (Tpradhan)
		-- Modified the equality of vendor name below to compare it with only the first 50 characters
		-- obtained from po_vendors for Bug 3079883.
	 	--bug 3519422 sdixit
                --reverting above fix as now customer name is 360 characters

		IF (
		      (RecSupp.vendor_name = X_vendor_name)
		 AND  (	  (RecSupp.num_1099 = X_num_1099)
		      OR  (    (RecSupp.num_1099 IS NULL)
			  AND  (X_num_1099 IS NULL)))
		 AND  (	  (RecSupp.vat_registration_num = X_vat_registration_num)
		      OR  (    (RecSupp.vat_registration_num IS NULL)
			  AND  (X_vat_registration_num IS NULL)))
		 AND  (	  (RecSupp.vendor_name_alt = X_vendor_name_alt)
		      OR  (    (RecSupp.vendor_name_alt IS NULL)
			  AND  (X_vendor_name_alt IS NULL)))
                 AND  (   (RecSupp1.stp_enforce_threshold = X_stp_enforce_threshold)
                      OR  (    (RecSupp1.stp_enforce_threshold IS NULL)
                          AND  (X_stp_enforce_threshold IS NULL)))
         	 AND  (	  (RecSupp.end_date_active = X_end_date_active)
		      OR  (    (RecSupp.end_date_active IS NULL)
			  AND  (X_end_date_active IS NULL)))
		     ) THEN
		     return;
		ELSE
		    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                        --bug 3199481 fnd logging changes: sdixit
                    IF (l_excep_level >=  l_debug_level ) THEN
                    FND_LOG.MESSAGE (l_excep_level ,
                            'igi.pls.igistpab.IGI_STP_TABLE_HANDLER_PKG.Supplier_Lock_Row',
                            FALSE);
                    END IF;
		    APP_EXCEPTION.Raise_Exception;
		 END IF;

	END Supplier_Lock_Row;

/***************************************************************************************/

 PROCEDURE Package_Update_Row( X_rowid VARCHAR2,
			X_exchange_rate NUMBER,
			X_exchange_rate_type VARCHAR2,
			X_exchange_date DATE,
			X_last_update_login NUMBER,
			X_last_update_date DATE,
			X_last_updated_by NUMBER) IS
 BEGIN
		UPDATE igi_stp_packages
		SET     exchange_rate		= X_exchange_rate,
			exchange_rate_type      = X_exchange_rate_type,
			exchange_date		= X_exchange_date,
			last_update_login	= X_last_update_login,
			last_update_date	= X_last_update_date,
			last_updated_by		= X_last_updated_by
                WHERE rowid = x_rowid;
		IF (SQL%NOTFOUND) THEN
			Raise NO_DATA_FOUND;
		END IF;

 END Package_Update_Row;


/***************************************************************************************/
 PROCEDURE Package_Lock_Row( X_rowid IN OUT NOCOPY VARCHAR2,
			X_batch_id NUMBER,
			X_package_id NUMBER,
			X_package_num NUMBER,
			X_stp_id NUMBER,
			X_application VARCHAR2,
			X_accounting_date DATE,
			X_trx_number VARCHAR2,
			X_related_trx_number VARCHAR2,
			X_reference VARCHAR2,
			X_amount NUMBER,
			X_currency_code VARCHAR2,
			X_exchange_rate NUMBER,
			X_exchange_rate_type VARCHAR2,
			X_exchange_date DATE) IS
		CURSOR C IS
		SELECT *
		FROM igi_stp_packages
		WHERE rowid = X_rowid
		FOR UPDATE of exchange_rate NOWAIT;

		Recinfo C%ROWTYPE;

	BEGIN
		OPEN C;
		FETCH C INTO Recinfo;
		IF (C%NOTFOUND) THEN
			CLOSE C;
			FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
                        --bug 3199481 fnd logging changes: sdixit
                        IF (l_excep_level >=  l_debug_level ) THEN
                            FND_LOG.MESSAGE (l_excep_level ,
                            'igi.pls.igistpab.IGI_STP_TABLE_HANDLER_PKG.Package_Lock_Row',
                            FALSE);
                        END IF;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		CLOSE C;

		IF ( (Recinfo.batch_id = X_batch_id)
		 AND  (Recinfo.package_id = X_package_id)
		 AND  (	  (Recinfo.package_num = X_package_num)
		      OR  (    (Recinfo.package_num IS NULL)
			  AND  (X_package_num IS NULL)))
		 AND  (Recinfo.stp_id = X_stp_id)
		 AND  (Recinfo.application = X_application)
                 AND  (Recinfo.accounting_date = X_accounting_date)
		 AND  (	  (Recinfo.trx_number = X_trx_number)
		      OR  (    (Recinfo.trx_number IS NULL)
			  AND  (X_trx_number IS NULL)))
                 AND  (	  (Recinfo.related_trx_number = X_related_trx_number)
	              OR  (    (Recinfo.related_trx_number IS NULL)
			  AND  (X_related_trx_number IS NULL)))
		AND  (	  (Recinfo.reference = X_reference)
		      OR  (    (Recinfo.reference IS NULL)
			  AND  (X_reference IS NULL)))
		AND  (Recinfo.amount = X_amount)
	        AND  (	  (Recinfo.currency_code = X_currency_code)
		      OR  (    (Recinfo.currency_code IS NULL)
			  AND  (X_currency_code IS NULL)))
	        AND  (	  (Recinfo.exchange_rate = X_exchange_rate)
		      OR  (    (Recinfo.exchange_rate IS NULL)
			  AND  (X_exchange_rate IS NULL)))
	        AND  (	  (Recinfo.exchange_rate_type = X_exchange_rate_type)
		      OR  (    (Recinfo.exchange_rate_type IS NULL)
			  AND  (X_exchange_rate_type IS NULL)))
	        AND  (	  (Recinfo.exchange_date = X_exchange_date)
		      OR  (    (Recinfo.exchange_date IS NULL)
			  AND  (X_exchange_date IS NULL)))
                 )then
                     return;
		ELSE
		    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                        --bug 3199481 fnd logging changes: sdixit
                    IF (l_excep_level >=  l_debug_level ) THEN
                        FND_LOG.MESSAGE (l_excep_level ,
                            'igi.pls.igistpab.IGI_STP_TABLE_HANDLER_PKG.Package_Lock_Row',
                            FALSE);
                    END IF;
		    APP_EXCEPTION.Raise_Exception;
		 END IF;

	END Package_Lock_Row;
BEGIN
-- Bug 3902175 GSCC warnings fixed
   l_debug_level    :=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level 	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level 	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level 	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level 	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level 	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level 	:=	FND_LOG.LEVEL_UNEXPECTED;

END IGI_STP_TABLE_HANDLER_PKG;

/
