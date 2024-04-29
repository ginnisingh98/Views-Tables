--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_012
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_012" AS
/* $Header: IGSAD90B.pls 120.2 2006/01/25 09:23:00 skpandey noship $ */
/*
 ||  Change History :
 ||  Who             When            What

 || ssaleem          13_OCT_2003     Bug : 3130316
 ||                                  Logging is modified to include logging mechanism
 || asbala           28-SEP-2003     Bug 3130316. Import Process Source Category Rule processing changes,
                                     lookup caching related changes, and cursor parameterization.
 || npalanis         6-JAN-2003      Bug : 2734697
 ||                                  code added to commit after import of every
 ||                                  100 records .New variable l_processed_records added
 ||  gmuralid        26-NOV-2002    BUG 2466674 - V2API UPTAKE
                                    changed reference of HZ_PER_INFO_PUB to HZ_PERSON_INFO_V2PUB AND
                                    HZ_CONTACT_POINT_PUB  TO HZ_CONTACT_POINT_V2PUB for create and update of
                                    person language and contact points

     ssawhney       27 may       BUG - 2377751, error codes modified from E008 for contacts.
 ||  npalanis       9-may-2002   BUG - 2352725
 ||                                Dupcontact point id value is set
 ||                              and also bug - 2338473 for messages is changed.
 ||  npalanis       6-may-2002   Bug - 2352725
 ||                              * The contact point type in the interface table is made not
 ||                                null and check is added that the contact point type must be PHONE or
 ||                                EMAIL.
 ||                              * IF check is added to see that whether the contact point type
 ||                                is PHONE or EMAIL before and the respective attributes are populated
 ||                                before creating or updating contact points.
 ||                              * In dup check cursor contact point type = 'PHONE' check is
 ||                                made.
 ||                              * Validate procedure is added to validate contact point type,
 ||                                phone line type,phone country code , email format from fnd lookups.
 ||                              * If check is added in validate proc to check that email address,
 ||                                email format cannot be null when contact point type is 'EMAIl' and
 ||                                phone number , phone line type cannot be null when contact point type is
 ||                                'PHONE'.
 ||                              * The contact point type check and phone line type check in
 ||                                create and update contact point proc is removed.
 ||                              * Cursor C1 fetches records based on contact point ID =
 ||                                igs_ad_contacts_int.interface_contacts_id it is changed to
 ||                                contact point ID = l_contact_point_id from hz_contact_points.
 ||  ssawhney       15 nov       Bug no.2103692:Person Interface DLD
 ||                              prc_pe_citizenship code is removed from here and added to
 ||                              IGS_AD_IMP_007.
 ||  gmaheswa       11 Nov 2003  Bug 3223043 HZ.K Impact Changes
    */

cst_mi_val_18  CONSTANT VARCHAR2(2) := '18';
cst_mi_val_19  CONSTANT VARCHAR2(2) := '19';
cst_mi_val_20  CONSTANT VARCHAR2(2) := '20';
cst_mi_val_21  CONSTANT VARCHAR2(2) := '21';
cst_mi_val_22  CONSTANT VARCHAR2(2) := '22';
cst_mi_val_23  CONSTANT VARCHAR2(2) := '23';
cst_mi_val_24  CONSTANT VARCHAR2(2) := '24';
cst_mi_val_25  CONSTANT VARCHAR2(2) := '25';

cst_stat_val_1  CONSTANT VARCHAR2(1) := '1';
cst_stat_val_2  CONSTANT VARCHAR2(1) := '2';
cst_stat_val_3  CONSTANT VARCHAR2(1) := '3';

cst_err_val_246 CONSTANT VARCHAR2(4) := 'E246';
cst_err_val_695 CONSTANT VARCHAR2(4) := 'E695';
cst_err_val_014 CONSTANT VARCHAR2(4) := 'E014';

PROCEDURE prc_pe_cntct_dtls (
 p_source_type_id IN NUMBER,
 p_batch_id IN NUMBER )
 AS

 l_prog_label  VARCHAR2(100);
 l_label  VARCHAR2(100);
 l_debug_str VARCHAR2(2000);
 l_enable_log VARCHAR2(1);
 l_request_id NUMBER;


 CURSOR c_pc(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE)  IS
    SELECT  ai.interface_contacts_id,
            ai.interface_id ai_interface_id,
            UPPER(ai.contact_point_type) contact_point_type,
            ai.email_address,
            UPPER(ai.email_format) email_format,
            UPPER(ai.primary_flag) primary_flag,
            UPPER(ai.phone_line_type) phone_line_type,
            ai.phone_country_code,
            ai.phone_area_code,
            ai.phone_number,
            ai.phone_extension,
            ai.status ai_status,
            ai.match_ind ai_match_ind,
            ai.error_code ai_error_code,
            ai.dup_contact_point_id,
            ai.created_by,
            ai.creation_date,
            ai.last_updated_by,
            ai.last_update_date,
            ai.last_update_login,
            ai.request_id,
            ai.program_application_id,
            ai.program_id,
            ai.program_update_date,
            i.interface_id i_interface_id,
            i.person_id i_person_id,
            i.match_ind  i_match_ind
    FROM   igs_ad_contacts_int_all ai, igs_ad_interface_all i
    WHERE  ai.interface_run_id = cp_interface_run_id
	AND    i.interface_id = ai.interface_id
        AND    i.interface_run_id = cp_interface_run_id
	AND    ai.status  = '2';

    l_var VARCHAR2(1);
    l_rule VARCHAR2(1);
    l_error_code VARCHAR2(25);
    l_status VARCHAR2(25);
    l_dup_var BOOLEAN;
    l_check VARCHAR2(10);
    l_contact_point_id igs_ad_contacts_int.dup_contact_point_id%TYPE;
    rec_pc c_pc%ROWTYPE;
    l_processed_records NUMBER(5) := 0 ;
    -- local variable to store the value of global variable igs_ad_imp_001.g_interface_run_id
    l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
     PROCEDURE crt_prsn_contacts(rec_pc c_pc%ROWTYPE  ,
                                 error_code OUT NOCOPY VARCHAR2,
                                 status OUT NOCOPY VARCHAR2) AS
        l_update_date1 DATE;
        l_return_status VARCHAR2(25);
            l_msg_count NUMBER;
            l_msg_data VARCHAR2(4000);
            l_smp VARCHAR2(25);
             l_smp1 VARCHAR2(25);
             p_error_code  VARCHAR2(25);
            p_status VARCHAR2(25);
            p_contact_points_rec       HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
            p_email_rec                HZ_CONTACT_POINT_V2PUB.email_rec_type;
                p_phone_rec                HZ_CONTACT_POINT_V2PUB.phone_rec_type;

             l_tmp_var1         VARCHAR2(500);
             l_tmp_var          VARCHAR2(500);
      BEGIN

       IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

	 IF (l_request_id IS NULL) THEN
	    l_request_id := fnd_global.conc_request_id;
	 END IF;

	 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_cntct_dtls.begin_crt_prsn_contacts';
	 l_debug_str := 'Igs_Ad_Imp_012.crt_prsn_contacts';

	 fnd_log.string_with_context( fnd_log.level_procedure,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
       END IF;

          p_contact_points_rec.contact_point_type :=  rec_pc.contact_point_type;
--        commented for bug fix for bug#1606314
--    p_contact_points_rec.status := rec_pc.ai_status;
      p_contact_points_rec.owner_table_name := 'HZ_PARTIES';
      p_contact_points_rec.owner_table_id := rec_pc.i_person_id;
      p_contact_points_rec.primary_flag := nvl(rec_pc.primary_flag,'N');
      p_contact_points_rec.content_source_type := 'USER_ENTERED';
       p_contact_points_rec.created_by_module := 'IGS';

      IF rec_pc.contact_point_type = 'EMAIL' THEN
              p_email_rec.email_format := rec_pc.email_format;
             p_email_rec.email_address := rec_pc.email_address;
       END IF;

      IF rec_pc.contact_point_type = 'PHONE' THEN
              p_phone_rec.phone_area_code     := rec_pc.phone_area_code;
              p_phone_rec.phone_country_code  := rec_pc.phone_country_code;
              p_phone_rec.phone_number        := rec_pc.phone_number;
             p_phone_rec.phone_extension     := rec_pc.phone_extension;
             p_phone_rec.phone_line_type     := rec_pc.phone_line_type;
       END IF;

              HZ_CONTACT_POINT_V2PUB.create_contact_point(
                                    p_init_msg_list         => FND_API.G_FALSE,
                                    p_contact_point_rec     => p_contact_points_rec,
                                    p_email_rec             => p_email_rec,
                                    p_phone_rec             => p_phone_rec,
                                    x_return_status         => l_return_status,
                                    x_msg_count             => l_msg_count,
                                    x_msg_data              => l_msg_data,
                                    x_contact_point_id      => l_contact_point_id
                                                   );
      IF l_return_status IN ('E','U') THEN

            IF l_msg_count > 1 THEN
               FOR i IN 1..l_msg_count
               LOOP
                 l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                 l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
               END LOOP;
                 l_msg_data := l_tmp_var1;
            END IF;

        l_error_code := 'E322';
        l_status := '3'; ---check with the existinf error codes


       IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

	 IF (l_request_id IS NULL) THEN
	    l_request_id := fnd_global.conc_request_id;
	 END IF;

	 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_cntct_dtls.exception_crt_prsn_contacts';

	 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
	 fnd_message.set_token('INTERFACE_ID',rec_pc.interface_contacts_id);
	 fnd_message.set_token('ERROR_CD','E322');

	 l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;

	 fnd_log.string_with_context( fnd_log.level_exception,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
       END IF;

       IF l_enable_log = 'Y' THEN
    	 igs_ad_imp_001.logerrormessage(rec_pc.interface_contacts_id,'E322');
       END IF;

        UPDATE igs_ad_contacts_int_all
        SET error_code='E322',status='3'
        WHERE interface_contacts_id=rec_pc.interface_contacts_id;

      ELSE

        l_status := '1';
        UPDATE igs_ad_contacts_int_all
        SET status='1'
        WHERE interface_contacts_id=rec_pc.interface_contacts_id;

      END IF;
      EXCEPTION
        WHEN OTHERS THEN

            p_error_Code:= 'E322';
            p_status:= '3';

	       IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_cntct_dtls.exception_crt_prsn_contacts';

		 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		 fnd_message.set_token('INTERFACE_ID',rec_pc.interface_contacts_id);
		 fnd_message.set_token('ERROR_CD','E322');

		 l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;

		 fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	       END IF;

	       IF l_enable_log = 'Y' THEN
		     igs_ad_imp_001.logerrormessage(rec_pc.interface_contacts_id,'E322');
	       END IF;

            UPDATE igs_ad_contacts_int_all
            SET error_code='E322',status='3'
            WHERE interface_contacts_id=rec_pc.interface_contacts_id;

      END crt_prsn_contacts;

PROCEDURE  validate_prsn_contacts(c_pc_rec c_pc%ROWTYPE,l_Check OUT NOCOPY VARCHAR2 )  AS

  -- 4. phone country code is now to be validated against
  -- HZ_PHONE_COUNTRY_CODEs  : HZ F validations -- ssawhney  bug 2203778
  CURSOR c_ph_cntry_cd (p_phone_country_code VARCHAR2) IS
  SELECT 'X'
  FROM   HZ_PHONE_COUNTRY_CODES
  WHERE PHONE_COUNTRY_CODE = p_phone_country_code;

  l_dummy                  VARCHAR2(1);

  BEGIN

     IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

	 IF (l_request_id IS NULL) THEN
	    l_request_id := fnd_global.conc_request_id;
	 END IF;

	 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_cntct_dtls.begin_validate_prsn_contacts';
	 l_debug_str := 'Igs_Ad_Imp_012.validate_prsn_contacts';

	 fnd_log.string_with_context( fnd_log.level_procedure,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('COMMUNICATION_TYPE',c_pc_rec.contact_point_type,222))
    THEN
          --   If the validation is not successful.

       IF l_enable_log = 'Y' THEN
	     igs_ad_imp_001.logerrormessage(c_pc_rec.interface_contacts_id,'E246');
       END IF;

          UPDATE igs_ad_contacts_int_all
          SET    status      = cst_stat_val_3,
                 error_code  = cst_err_val_246,
                 match_ind   = cst_mi_val_18
          WHERE  interface_contacts_id  = c_pc_rec.interface_contacts_id;
          l_Check := 'TRUE';
          RETURN;
    END IF;

    IF c_pc_rec.primary_flag IS NOT NULL THEN
      IF c_pc_rec.primary_flag NOT IN ('N','Y') THEN

       IF l_enable_log = 'Y' THEN
	     igs_ad_imp_001.logerrormessage(c_pc_rec.interface_contacts_id,'E450');
       END IF;

        UPDATE igs_ad_contacts_int_all
        SET    error_code  = 'E450',
               status      = '3'
        WHERE  interface_contacts_id = c_pc_rec.interface_contacts_id;
        l_Check := 'TRUE';
        RETURN;
      END IF;
    END IF;

    IF c_pc_rec.contact_point_type = 'PHONE' THEN
    --     Validation to check whether phone line type or phone number are null
      IF c_pc_rec.phone_number IS NULL OR c_pc_rec.phone_line_type IS NULL THEN

        IF l_enable_log = 'Y' THEN
	      igs_ad_imp_001.logerrormessage(c_pc_rec.interface_contacts_id,'E250');
        END IF;

        UPDATE igs_ad_contacts_int_all
        SET    error_code  = 'E250',
               status      = '3'
        WHERE  interface_contacts_id = c_pc_rec.interface_contacts_id;
        l_Check := 'TRUE';
        RETURN;
      END IF;

      IF NOT
      (igs_pe_pers_imp_001.validate_lookup_type_code('PHONE_LINE_TYPE',c_pc_rec.phone_line_type,222))
      THEN
          --   If the validation is not successful.

        IF l_enable_log = 'Y' THEN
	      igs_ad_imp_001.logerrormessage(c_pc_rec.interface_contacts_id,'E247');
    	END IF;

        UPDATE igs_ad_contacts_int_all
        SET    status      = '3',
               error_code   = 'E247'
        WHERE  interface_contacts_id = c_pc_rec.interface_contacts_id;
        l_Check := 'TRUE';
        RETURN;
      END IF;

    -- Validate the PHONE_COUNTRY_CODE
    IF c_pc_rec.phone_country_code IS NOT NULL THEN
      OPEN c_ph_cntry_cd(c_pc_rec.phone_country_code);
      FETCH c_ph_cntry_cd INTO l_dummy;
      IF c_ph_cntry_cd%NOTFOUND THEN
          --   If the validation is not successful.

        IF l_enable_log = 'Y' THEN
 	       igs_ad_imp_001.logerrormessage(c_pc_rec.interface_contacts_id,'E173');
    	END IF;

        UPDATE igs_ad_contacts_int_all
        SET    status      = '3',
               error_code   = 'E173'
        WHERE  interface_contacts_id = c_pc_rec.interface_contacts_id;
        CLOSE c_ph_cntry_cd;
        l_Check := 'TRUE';
        RETURN;
      END IF;
      CLOSE c_ph_cntry_cd;
    END IF;

  END IF;

  IF c_pc_rec.contact_point_type = 'EMAIL' THEN
      -- Validation to check whether email address is null
    IF c_pc_rec.email_address IS NULL THEN

      IF l_enable_log = 'Y' THEN
 	     igs_ad_imp_001.logerrormessage(c_pc_rec.interface_contacts_id,'E251');
      END IF;

      UPDATE igs_ad_contacts_int_all
      SET    error_code  = 'E251',
             status      = '3'
      WHERE  interface_contacts_id = c_pc_rec.interface_contacts_id;
      l_Check := 'TRUE';
      RETURN;
    END IF;

    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('EMAIL_FORMAT',c_pc_rec.email_format,222))
    THEN

      IF l_enable_log = 'Y' THEN
 	     igs_ad_imp_001.logerrormessage(c_pc_rec.interface_contacts_id,'E248');
      END IF;

      UPDATE igs_ad_contacts_int_all
      SET    error_code  = 'E248',
             status      = '3'
      WHERE  interface_contacts_id = c_pc_rec.interface_contacts_id;
      l_Check := 'TRUE';
      RETURN;
    END IF;
  END IF;
  l_check := 'FALSE';
END validate_prsn_contacts;

-- local procedure ends;

-- main procedure begins;
BEGIN

  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
  l_prog_label := 'igs.plsql.igs_ad_imp_012.prc_pe_cntct_dtls';
  l_label      := 'igs.plsql.igs_ad_imp_012.prc_pe_cntct_dtls.';
  l_enable_log := igs_ad_imp_001.g_enable_log;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

	 IF (l_request_id IS NULL) THEN
	    l_request_id := fnd_global.conc_request_id;
	 END IF;

	 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_cntct_dtls.begin';
	 l_debug_str := 'Igs_Ad_Imp_012.prc_pe_cntct_dtls';

	 fnd_log.string_with_context( fnd_log.level_procedure,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  l_rule :=igs_ad_imp_001.find_source_cat_rule(p_source_type_id,'PERSON_CONTACTS');

  -- 1.If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_ad_contacts_int_all
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND interface_run_id = l_interface_run_id
      AND status = cst_stat_val_2;
  END IF;

  --2. If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_ad_contacts_int_all ai
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_19
    WHERE ai.interface_run_id = l_interface_run_id
      AND ai.status = cst_stat_val_2
      AND EXISTS(  SELECT '1'
                   FROM   hz_contact_points  pe, igs_ad_interface_all i
		   WHERE  i.interface_run_id = l_interface_run_id
                    AND   i.interface_id = ai.interface_id
		    AND   pe.owner_table_id = i.person_id
		     AND  UPPER(ai.contact_point_type) = pe.contact_point_type
		     AND  pe.owner_table_name = 'HZ_PARTIES'
		     AND  ((pe.email_format= UPPER(ai.email_format)
                     AND UPPER(pe.email_address) = UPPER(ai.email_address)
                     AND pe.contact_point_type='EMAIL')
                     OR (pe.phone_line_type = UPPER(ai.phone_line_type)
                     AND (pe.phone_country_code = ai.phone_country_code OR (pe.phone_country_code IS NULL AND ai.phone_country_code IS NULL))
                     AND (UPPER(pe.phone_Area_code) = UPPER(ai.phone_area_code) OR (pe.phone_Area_code IS NULL AND ai.phone_area_code IS NULL ) )
                     AND pe.phone_number=ai.phone_number
                     AND pe.contact_point_type='PHONE'))
		     );
  END IF;

  -- 3.If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_ad_contacts_int_all
    SET status = cst_stat_val_1
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN (cst_mi_val_18,cst_mi_val_19,cst_mi_val_22,cst_mi_val_23)
      AND status=cst_stat_val_2;
  END IF;

  -- 4.If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_ad_contacts_int_all
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695
    WHERE interface_run_id = l_interface_run_id
      AND (match_ind IS NOT NULL AND match_ind NOT IN (cst_mi_val_21,cst_mi_val_25))
      AND status=cst_stat_val_2;
  END IF;

  -- 5.If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_ad_contacts_int_all ai
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_23
    WHERE ai.interface_run_id = l_interface_run_id
      AND ai.match_ind IS NULL
      AND ai.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM   hz_contact_points  pe, igs_ad_interface_all i
		   WHERE  i.interface_run_id = l_interface_run_id
                    AND   i.interface_id = ai.interface_id
		    AND   pe.owner_table_id = i.person_id
		     AND  UPPER(ai.contact_point_type) = pe.contact_point_type
		     AND  pe.owner_table_name = 'HZ_PARTIES'
		     AND  ((pe.email_format= UPPER(ai.email_format)
                     AND UPPER(pe.email_address) = UPPER(ai.email_address)
                     AND pe.contact_point_type='EMAIL')
                     OR (pe.phone_line_type = UPPER(ai.phone_line_type)
                     AND (pe.phone_country_code = ai.phone_country_code OR (pe.phone_country_code IS NULL AND ai.phone_country_code IS NULL))
                     AND (UPPER(pe.phone_Area_code) = UPPER(ai.phone_area_code) OR (pe.phone_Area_code IS NULL AND ai.phone_area_code IS NULL ) )
                     AND pe.phone_number=ai.phone_number
                     AND (pe.phone_extension = ai.phone_extension
                               OR (pe.phone_extension IS NULL AND ai.phone_extension IS NULL))
		     AND pe.contact_point_type='PHONE'))
                     AND pe.primary_flag = NVL(ai.primary_flag,'N')
                     AND pe.content_source_type = 'USER_ENTERED'
		 );
  END IF;

  -- 6.If rule in R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_ad_contacts_int_all ai
    SET status = cst_stat_val_3,
        match_ind = cst_mi_val_20,
	dup_contact_point_id = (SELECT contact_point_id
	                        FROM hz_contact_points pe, igs_ad_interface_all i
   			        WHERE  i.interface_run_id = l_interface_run_id
				     AND  i.interface_id = ai.interface_id
                                     AND  rownum = 1
				     AND  pe.owner_table_id = i.person_id
				     AND  UPPER(ai.contact_point_type) = pe.contact_point_type
				     AND  pe.owner_table_name = 'HZ_PARTIES'
				     AND  ((pe.email_format= UPPER(ai.email_format)
					    AND UPPER(pe.email_address) = UPPER(ai.email_address)
					    AND pe.contact_point_type='EMAIL')
				     OR (pe.phone_line_type = UPPER(ai.phone_line_type)
					    AND (pe.phone_country_code = ai.phone_country_code OR (pe.phone_country_code IS NULL AND ai.phone_country_code IS NULL))
					    AND (UPPER(pe.phone_Area_code) = UPPER(ai.phone_area_code) OR (pe.phone_Area_code IS NULL AND ai.phone_area_code IS NULL ) )
					    AND pe.phone_number=ai.phone_number
					    AND pe.contact_point_type='PHONE')))
    WHERE ai.interface_run_id = l_interface_run_id
      AND ai.match_ind IS NULL
      AND ai.status = cst_stat_val_2
      AND EXISTS (SELECT '1'
                   FROM   hz_contact_points  pe, igs_ad_interface_all i
		   WHERE  i.interface_run_id = l_interface_run_id
		     AND  i.interface_id = ai.interface_id
		     AND  pe.owner_table_id = i.person_id
		     AND  UPPER(ai.contact_point_type) = pe.contact_point_type
		     AND  pe.owner_table_name = 'HZ_PARTIES'
		     AND  ((pe.email_format= UPPER(ai.email_format)
                            AND UPPER(pe.email_address) = UPPER(ai.email_address)
                            AND pe.contact_point_type='EMAIL')
                     OR (pe.phone_line_type = UPPER(ai.phone_line_type)
                            AND (pe.phone_country_code = ai.phone_country_code OR (pe.phone_country_code IS NULL AND ai.phone_country_code IS NULL))
                            AND (UPPER(pe.phone_Area_code) = UPPER(ai.phone_area_code) OR (pe.phone_Area_code IS NULL AND ai.phone_area_code IS NULL ) )
                            AND pe.phone_number=ai.phone_number
                            AND pe.contact_point_type='PHONE')));
  END IF;

  FOR rec_pc1 IN c_pc(l_interface_run_id) LOOP

  l_processed_records := l_processed_records + 1;
  l_check := 'FALSE' ;
  Validate_Prsn_Contacts(rec_pc1,l_check);

  IF l_check = 'FALSE' THEN
    DECLARE
     CURSOR check_dup_contact(   p_owner_table_id NUMBER,
                              p_contact_point_type VARCHAR2,
                              p_email_format VARCHAR2,
                              p_email_address VARCHAR2,
                              p_phone_line_type VARCHAR2,
                              p_phone_country_code VARCHAR2,
                              p_phone_area_code VARCHAR2,
                              p_phone_number VARCHAR2
                               ) IS
    SELECT ROWID, hi.*
    FROM  hz_contact_points hi
    WHERE   hi.owner_table_id=p_owner_table_id
      AND     UPPER(hi.contact_point_type)=UPPER(p_contact_point_type)
      AND     UPPER(hi.owner_table_name)='HZ_PARTIES'
      AND     ((UPPER(hi.email_format)=UPPER(p_email_format)
               AND UPPER(hi.email_address)=UPPER(p_email_address)
               AND UPPER(hi.contact_point_type)='EMAIL')
              OR (UPPER(hi.phone_line_type)=UPPER(p_phone_line_type)
                  AND (UPPER(hi.phone_country_code)=UPPER(p_phone_country_code) OR (hi.phone_country_code IS NULL AND p_phone_country_code IS NULL ) )
                  AND (UPPER(hi.phone_Area_code)=UPPER(p_phone_area_code) OR (hi.phone_Area_code IS NULL AND p_phone_area_code IS NULL ) )
                  AND UPPER(hi.phone_number)=UPPER(p_phone_number)
                  AND UPPER(hi.contact_point_type)='PHONE'));

    check_dup_contact_rec check_dup_contact%ROWTYPE;
    BEGIN
    check_dup_contact_rec.contact_point_type := NULL;
    OPEN check_dup_contact(   rec_pc1.i_person_id,
                              rec_pc1.contact_point_type,
                              rec_pc1.email_format,
                              rec_pc1.email_address,
                              rec_pc1.phone_line_type,
                              rec_pc1.phone_country_code,
                              rec_pc1.phone_area_code,
                              rec_pc1.phone_number );
    FETCH check_dup_contact INTO check_dup_contact_rec;
    CLOSE check_dup_contact;
    l_contact_point_id := check_dup_contact_rec.contact_point_id;
    IF check_dup_contact_rec.contact_point_type IS NOT NULL THEN
      IF l_rule = 'I' THEN
        DECLARE
          l_tmp_var1 VARCHAR2(500);
          l_tmp_var  VARCHAR2(500);
          l_rowid VARCHAR2(25);
          l_last_update DATE;
          l_return_status VARCHAR2(25);
          l_msg_count NUMBER;
          l_msg_data VARCHAR2(4000);
          l_smp VARCHAR2(25);
          l_smp1 VARCHAR2(25);
          l_obj_ver                    hz_contact_points.object_version_number%TYPE;
          p_contact_points_rec        HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
          p_email_rec                 HZ_CONTACT_POINT_V2PUB.email_rec_type;
          p_phone_rec                 HZ_CONTACT_POINT_V2PUB.phone_rec_type;

        BEGIN
          SELECT object_version_number
          INTO   l_obj_ver
          FROM   hz_contact_points
          WHERE  contact_point_id = check_dup_contact_rec.contact_point_id;

          p_contact_points_rec.contact_point_id    := check_dup_contact_rec.contact_point_id;
          p_contact_points_rec.contact_point_type  := rec_pc1.contact_point_type;
          p_contact_points_rec.owner_table_name    := 'HZ_PARTIES';
          p_contact_points_rec.owner_table_id      := rec_pc1.i_person_id;
          p_contact_points_rec.primary_flag        := NVL((NVL(rec_pc1.primary_flag,check_dup_contact_rec.primary_flag)),FND_API.G_MISS_CHAR);
      --  p_contact_points_rec.content_source_type := 'USER_ENTERED';
      --  p_contact_points_rec.created_by_module   := 'IGS';
          IF rec_pc1.contact_point_type = 'EMAIL' THEN
            p_email_rec.email_format := NVL(rec_pc1.email_format,FND_API.G_MISS_CHAR);
            p_email_rec.email_address :=NVL(rec_pc1.email_address,FND_API.G_MISS_CHAR);
          END IF;
          IF rec_pc1.contact_point_type = 'PHONE' THEN
            p_phone_rec.phone_country_code   := NVL((NVL(rec_pc1.phone_country_code,check_dup_contact_rec.phone_country_code)),FND_API.G_MISS_CHAR); --
            p_phone_rec.phone_line_type      :=NVL(rec_pc1.phone_line_type,FND_API.G_MISS_CHAR);
            p_phone_rec.phone_area_code      := NVL((NVL(rec_pc1.phone_area_code,check_dup_contact_rec.phone_area_code)),FND_API.G_MISS_CHAR); --
            p_phone_rec.phone_number         := NVL(rec_pc1.phone_number,FND_API.G_MISS_CHAR);
            p_phone_rec.phone_extension      := NVL((NVL(rec_pc1.phone_extension,check_dup_contact_rec.phone_extension)),FND_API.G_MISS_CHAR); --
          END IF;

          HZ_CONTACT_POINT_V2PUB.update_contact_point(
                             p_init_msg_list         => FND_API.G_FALSE,
                             p_contact_point_rec     => p_contact_points_rec,
                             p_email_rec             => p_email_rec ,
                            p_phone_rec             => p_phone_rec,
                             p_object_version_number => l_obj_ver,
                             x_return_status         => l_return_status,
                             x_msg_count             => l_msg_count,
                             x_msg_data              => l_msg_data
                                                   );

          IF l_return_status IN ('E','U') THEN
            IF l_msg_count > 1 THEN
              FOR i IN 1..l_msg_count LOOP -- loop thro the various error msgs and display
	        l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
		l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
              END LOOP;
              l_msg_data := l_tmp_var1;
	    END IF;
            l_error_code := 'E014';
            l_status := '3';
                      --error code to be defined for the updation failure

	    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_cntct_dtls.exception1';

		 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		 fnd_message.set_token('INTERFACE_ID',rec_pc1.interface_contacts_id);
		 fnd_message.set_token('ERROR_CD','E014');

		 l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;

		 fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	     END IF;

	     IF l_enable_log = 'Y' THEN
		    igs_ad_imp_001.logerrormessage(rec_pc1.interface_contacts_id,'E014');
	     END IF;


            UPDATE igs_ad_contacts_int_all
            SET    ERROR_CODE = 'E014',
                   status='3'
            WHERE interface_contacts_id = rec_pc1.interface_contacts_id;
          ELSE
            l_status := '1';
            UPDATE igs_ad_contacts_int_all
            SET    status=cst_stat_val_1,
                   match_ind =cst_mi_val_18
            WHERE interface_contacts_id = rec_pc1.interface_contacts_id;
          END IF; -- if l_return_status

        EXCEPTION
          WHEN OTHERS THEN

             IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_cntct_dtls.exception2';

		 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		 fnd_message.set_token('INTERFACE_ID',rec_pc1.interface_contacts_id);
		 fnd_message.set_token('ERROR_CD','E014');

		 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

		 fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	     END IF;

	     IF l_enable_log = 'Y' THEN
		    igs_ad_imp_001.logerrormessage(rec_pc1.interface_contacts_id,'E014');
	     END IF;

            UPDATE igs_ad_contacts_int_all
            SET    match_ind = cst_mi_val_18,
                   status = cst_stat_val_3
            WHERE  interface_contacts_id  = rec_pc1.interface_contacts_id;
        END;  -- begin
      ELSIF l_rule = 'R' THEN
        IF rec_pc1.ai_match_ind = '21' THEN
          DECLARE
	    l_tmp_var1          VARCHAR2(500);
	    l_tmp_var          VARCHAR2(500);
     	    l_rowid VARCHAR2(25);
	    l_last_update DATE;
	    l_smp VARCHAR2(25);
	    l_smp1 VARCHAR2(25);
            l_return_status VARCHAR2(25);
            l_msg_count NUMBER;
            l_msg_data VARCHAR2(4000);
            p_contact_points_rec          HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
            p_email_rec                   HZ_CONTACT_POINT_V2PUB.email_rec_type;
            p_phone_rec                   HZ_CONTACT_POINT_V2PUB.phone_rec_type;
            l_obj_ver          hz_contact_points.object_version_number%TYPE;

          BEGIN
            SELECT object_version_number
            INTO l_obj_ver
            FROM hz_contact_points
            WHERE contact_point_id = l_contact_point_id;
            p_contact_points_rec.contact_point_id := l_contact_point_id;
            p_contact_points_rec.contact_point_type := rec_pc1.contact_point_type;
            p_contact_points_rec.owner_table_name := 'HZ_PARTIES';
            p_contact_points_rec.owner_table_id := rec_pc1.i_person_id;
            p_contact_points_rec.primary_flag := NVL((NVL(rec_pc1.primary_flag,check_dup_contact_rec.primary_flag)),FND_API.G_MISS_CHAR);

        --  p_contact_points_rec.content_source_type := 'USER_ENTERED';
        --  p_contact_points_rec.created_by_module := 'IGS';

            IF rec_pc1.contact_point_type = 'EMAIL' THEN
              p_email_rec.email_format := NVL(rec_pc1.email_format,FND_API.G_MISS_CHAR);
              p_email_rec.email_address :=NVL(rec_pc1.email_address,FND_API.G_MISS_CHAR);
            END IF;

            IF rec_pc1.contact_point_type = 'PHONE' THEN
              p_phone_rec.phone_country_code := NVL((NVL(rec_pc1.phone_country_code,check_dup_contact_rec.phone_country_code)),FND_API.G_MISS_CHAR);
              p_phone_rec.phone_line_type := NVL(rec_pc1.phone_line_type,FND_API.G_MISS_CHAR);
              p_phone_rec.phone_area_code := NVL((NVL(rec_pc1.phone_area_code,check_dup_contact_rec.phone_area_code)),FND_API.G_MISS_CHAR);
              p_phone_rec.phone_number    := NVL(rec_pc1.phone_number,FND_API.G_MISS_CHAR);
              p_phone_rec.phone_extension := NVL((NVL(rec_pc1.phone_extension,check_dup_contact_rec.phone_extension)),FND_API.G_MISS_CHAR) ;
            END IF;
            HZ_CONTACT_POINT_V2PUB.update_contact_point(
                                           p_init_msg_list         => FND_API.G_FALSE,
                                           p_contact_point_rec     => p_contact_points_rec,
                                           p_email_rec             => p_email_rec ,
                                        p_phone_rec             => p_phone_rec,
                                           p_object_version_number => l_obj_ver,
                                           x_return_status         => l_return_status,
                                           x_msg_count             => l_msg_count,
                                           x_msg_data              => l_msg_data
                                                                 );


            IF l_return_status IN ('E','U') THEN
              IF l_msg_count > 1 THEN
                FOR i IN 1..l_msg_count
                LOOP
                  l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
                END LOOP;
                l_msg_data := l_tmp_var1;
              END IF;
              l_error_code := 'E014';
              --error code to be defined for the updation failure

	       IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_cntct_dtls.exception3';

		 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		 fnd_message.set_token('INTERFACE_ID',rec_pc1.interface_contacts_id);
		 fnd_message.set_token('ERROR_CD',l_error_code);

		 l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;

		 fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	       END IF;

	       IF l_enable_log = 'Y' THEN
		     igs_ad_imp_001.logerrormessage(rec_pc1.interface_contacts_id,'E014');
	       END IF;

              UPDATE igs_ad_contacts_int_all
              SET    error_code = 'E014',
                     status='3'
              WHERE interface_contacts_id = rec_pc1.interface_contacts_id;
            ELSE
              UPDATE igs_ad_contacts_int_all
              SET status = cst_stat_val_1,
	      match_ind = cst_mi_val_18
              WHERE interface_contacts_id = rec_pc1.interface_contacts_id;
            END IF;
            EXCEPTION
              WHEN OTHERS THEN

	       IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_cntct_dtls.exception4';

		 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		 fnd_message.set_token('INTERFACE_ID',rec_pc1.interface_contacts_id);
		 fnd_message.set_token('ERROR_CD','E014');

		 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

		 fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	       END IF;

	       IF l_enable_log = 'Y' THEN
		     igs_ad_imp_001.logerrormessage(rec_pc1.interface_contacts_id,'E014');
	       END IF;

                UPDATE igs_ad_contacts_int_all
                SET    status = '3'
                WHERE  interface_contacts_id  = rec_pc1.interface_contacts_id;
            END;  -- begin
          END IF;  -- if match_ind
        END IF;  -- if l_rule
      ELSE -- l_dup = FALSE
        BEGIN
          crt_prsn_contacts(rec_pc => rec_pc1, error_code => l_error_code,  status => l_status  ) ;
        EXCEPTION
          WHEN OTHERS THEN

	       IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_cntct_dtls.exception5';

		 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		 fnd_message.set_token('INTERFACE_ID',rec_pc1.interface_contacts_id);
		 fnd_message.set_token('ERROR_CD','E518');

		 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

		 fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	       END IF;

	       IF l_enable_log = 'Y' THEN
		     igs_ad_imp_001.logerrormessage(rec_pc1.interface_contacts_id,'E518');
	       END IF;

            UPDATE igs_ad_contacts_int_all
            SET    status = '3',error_code='E518'
            WHERE interface_contacts_id = rec_pc1.interface_contacts_id;
        END;
      END IF;  -- if chk_dup_contact
      END; -- outer begin
    END IF;  -- l_check is true
 -- nothing is done here as the final update has happened inside validate person only.
    IF l_processed_records = 100 THEN
      COMMIT;
      l_processed_records := 0;
    END IF;
  END LOOP;
END prc_pe_cntct_dtls;

PROCEDURE prc_pe_language (
 p_source_type_id IN NUMBER,
 p_batch_id IN NUMBER )
 AS
   /*
      ||  Created By : pkpatel
      ||  Created On : 10-JUN-2002
      ||  Purpose : Bug No:2402077 Validate the Person ID type and Format mask for Alternate ID
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      ||  pkpatel        15-JAN-2003     Bug NO: 2397876
      ||                                 Added all the missing validations and replaced E008 with proper error codes
   */

   l_prog_label  VARCHAR2(100);
   l_label  VARCHAR2(100);
   l_debug_str VARCHAR2(2000);
   l_enable_log VARCHAR2(1);
   l_request_id NUMBER;
   l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

    CURSOR person_language_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
    SELECT hii.*, i.person_id
    FROM   igs_ad_language_int_all hii, igs_ad_interface_all i
    WHERE  hii.interface_run_id = cp_interface_run_id
	AND    i.interface_id = hii.interface_id
        AND    i.interface_run_id = cp_interface_run_id
	AND    hii.status  = '2';

    l_var VARCHAR2(1);
    l_rule VARCHAR2(1);
    l_error_code VARCHAR2(25);
    l_status VARCHAR2(25);
    l_return_status VARCHAR2(25);
    l_dup_var BOOLEAN;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(4000);
    p_person_language_rec   person_language_cur%ROWTYPE;
    person_language_rec     person_language_cur%ROWTYPE;
    l_processed_records NUMBER(5) := 0;

    FUNCTION  validate_lang(p_person_language_rec IN person_language_cur%ROWTYPE)
    RETURN BOOLEAN IS

      CURSOR lang_name_cur(cp_language_code  p_person_language_rec.language_name%TYPE) IS
      SELECT 'X'
      FROM  fnd_languages_vl
      WHERE language_code = cp_language_code;

      l_exists  VARCHAR2(1);
      l_error_code  igs_ad_interface_all.ERROR_CODE%TYPE;
    BEGIN
      OPEN lang_name_cur(p_person_language_rec.language_name);
      FETCH lang_name_cur INTO l_exists;
      IF lang_name_cur%NOTFOUND THEN
            CLOSE lang_name_cur;
            l_error_code := 'E551';
            RAISE NO_DATA_FOUND;
      END IF;
      CLOSE lang_name_cur;

      IF p_person_language_rec.READS_LEVEL IS NOT NULL AND NOT (igs_pe_pers_imp_001.validate_lookup_type_code('HZ_LANGUAGE_PROFICIENCY',p_person_language_rec.READS_LEVEL,222)) THEN
        l_error_code := 'E750';
        RAISE NO_DATA_FOUND;
      END IF;

      IF p_person_language_rec.SPEAKS_LEVEL IS NOT NULL AND NOT (igs_pe_pers_imp_001.validate_lookup_type_code('HZ_LANGUAGE_PROFICIENCY',p_person_language_rec.SPEAKS_LEVEL,222)) THEN
        l_error_code := 'E751';
        RAISE NO_DATA_FOUND;
      END IF;

      IF p_person_language_rec.WRITES_LEVEL IS NOT NULL AND NOT (igs_pe_pers_imp_001.validate_lookup_type_code('HZ_LANGUAGE_PROFICIENCY',p_person_language_rec.WRITES_LEVEL,222)) THEN
        l_error_code := 'E752';
        RAISE NO_DATA_FOUND;
      END IF;

      IF p_person_language_rec.UNDERSTANDS_LEVEL IS NOT NULL AND NOT (igs_pe_pers_imp_001.validate_lookup_type_code('HZ_LANGUAGE_PROFICIENCY',p_person_language_rec.UNDERSTANDS_LEVEL,222)) THEN
        l_error_code := 'E753';
        RAISE NO_DATA_FOUND;
      END IF;

      IF p_person_language_rec.LANG_STATUS <> 'A' AND p_person_language_rec.LANG_STATUS <> 'I' THEN
        l_error_code := 'E754';
        RAISE NO_DATA_FOUND;
      END IF;

      RETURN TRUE;

    EXCEPTION
     WHEN NO_DATA_FOUND THEN

        UPDATE igs_ad_language_int_all
        SET status = '3',
            error_code = l_error_code
        WHERE interface_language_id = p_person_language_rec.interface_language_id;

        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

	 IF (l_request_id IS NULL) THEN
	    l_request_id := fnd_global.conc_request_id;
	 END IF;

	 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_language.exception_validate_lang';

	 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
	 fnd_message.set_token('INTERFACE_ID',p_person_language_rec.interface_language_id);
	 fnd_message.set_token('ERROR_CD',l_error_code);

	 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

	 fnd_log.string_with_context( fnd_log.level_exception,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
       END IF;

       IF l_enable_log = 'Y' THEN
	     igs_ad_imp_001.logerrormessage(p_person_language_rec.interface_language_id,l_error_code);
       END IF;

        RETURN FALSE;
    END validate_lang;


      PROCEDURE crt_prsn_language(p_person_language_rec IN person_language_cur%ROWTYPE) AS
            l_return_status VARCHAR2(25);
            l_msg_count NUMBER;
            l_msg_data VARCHAR2(4000);
            l_language_use_reference_id NUMBER;
            l_language_id3 NUMBER;

             --V2 API UPTAKE BY GMURALID
             p_per_language_rec     HZ_PERSON_INFO_V2PUB.person_language_rec_type;
             l_tmp_var1             VARCHAR2(500);
             l_tmp_var              VARCHAR2(500);
	     l_object_version_number NUMBER;
	     l_last_update_date    DATE;
      BEGIN

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

	 IF (l_request_id IS NULL) THEN
	    l_request_id := fnd_global.conc_request_id;
	 END IF;

	 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_language.begin_crt_prsn_language';
	 l_debug_str := 'Igs_Ad_Imp_012.crt_prsn_language';

	 fnd_log.string_with_context( fnd_log.level_procedure,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;


       IF validate_lang(p_person_language_rec) THEN

	  igs_pe_languages_pkg.Languages(
	         p_action 			=> 'INSERT',
		 P_LANGUAGE_NAME 		=> p_person_language_rec.language_name,
		 p_DESCRIPTION			=> null,
		 p_PARTY_ID			=> p_person_language_rec.person_id,
		 p_native_language		=> p_person_language_rec.native_language,
		 p_primary_language_indicator   => p_person_language_rec.primary_language_indicator,
		 P_READS_LEVEL                  => p_person_language_rec.reads_level,
		 P_SPEAKS_LEVEL                 => p_person_language_rec.speaks_level,
		 P_WRITES_LEVEL                 => p_person_language_rec.writes_level,
		 p_END_DATE                     => null,
		 p_status                       => p_person_language_rec.lang_status,
		 p_understand_level             => p_person_language_rec.understands_level,
		 p_last_update_date             => l_last_update_date,
		 p_return_status                => l_return_status,
		 p_msg_count                    => l_msg_count,
		 p_msg_data                     => l_msg_data,
		 P_language_use_reference_id 	=> l_language_use_reference_id,
                 p_language_ovn                 => l_object_version_number
             );

		 IF l_return_status IN ('E','U') THEN
                       IF l_msg_count > 1 THEN
                            FOR i IN 1..l_msg_count
                            LOOP
                                 l_tmp_var :=  fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                                 l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
                            END LOOP;
                         l_msg_data := l_tmp_var1;
                       END IF;

                    UPDATE igs_ad_language_int_all
                    SET status = '3',
                        error_code = 'E322'
                    WHERE interface_language_id = p_person_language_rec.interface_language_id;

                    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

	 		 IF (l_request_id IS NULL) THEN
			    l_request_id := fnd_global.conc_request_id;
			 END IF;

			 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_language.exception_crt_prsn_language1';

			 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
			 fnd_message.set_token('INTERFACE_ID',p_person_language_rec.interface_language_id);
			 fnd_message.set_token('ERROR_CD','E322');

			 l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;

			 fnd_log.string_with_context( fnd_log.level_exception,
							  l_label,
							  l_debug_str, NULL,
							  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                   END IF;

		   IF l_enable_log = 'Y' THEN
			 igs_ad_imp_001.logerrormessage(p_person_language_rec.interface_language_id,'E322');
		   END IF;

                  ELSE

                    UPDATE igs_ad_language_int_all
                    SET status = '1',
                        error_code = NULL
                    WHERE interface_language_id = p_person_language_rec.interface_language_id;

                  END IF;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
                    UPDATE igs_ad_language_int_all
                    SET status = '3',
                        error_code = 'E322'
                    WHERE interface_language_id = p_person_language_rec.interface_language_id;

                    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

	 		 IF (l_request_id IS NULL) THEN
			    l_request_id := fnd_global.conc_request_id;
			 END IF;

			 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_language.exception_crt_prsn_language2';

			 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
			 fnd_message.set_token('INTERFACE_ID',p_person_language_rec.interface_language_id);
			 fnd_message.set_token('ERROR_CD','E322');

			 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

			 fnd_log.string_with_context( fnd_log.level_exception,
							  l_label,
							  l_debug_str, NULL,
							  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                   END IF;

		   IF l_enable_log = 'Y' THEN
			 igs_ad_imp_001.logerrormessage(p_person_language_rec.interface_language_id,'E322');
		   END IF;

      END crt_prsn_language;
 -- end of local procedure crt_prsn_lang
 -- start of main procedure prc_pe_lang
BEGIN

  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
  l_prog_label := 'igs.plsql.igs_ad_imp_012.prc_pe_language';
  l_label      := 'igs.plsql.igs_ad_imp_012.prc_pe_language.';
  l_enable_log := igs_ad_imp_001.g_enable_log;

  l_rule :=igs_ad_imp_001.find_source_cat_rule(p_source_type_id,'PERSON_LANGUAGES');

  -- 1.If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_ad_language_int_all
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND interface_run_id = l_interface_run_id
      AND status = cst_stat_val_2;
  END IF;

  --2. If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_ad_language_int_all ai
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_19
    WHERE ai.interface_run_id = l_interface_run_id
      AND ai.status = cst_stat_val_2
      AND EXISTS(  SELECT '1'
                   FROM   hz_person_language  pe, igs_ad_interface_all i
                   WHERE  i.interface_run_id = l_interface_run_id
                    AND   i.interface_id = ai.interface_id
        		    AND   pe.party_id = i.person_id
                    AND  pe.language_name = UPPER(ai.language_name)
		     );
  END IF;

  -- 3.If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_ad_language_int_all
    SET status = cst_stat_val_1
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN (cst_mi_val_18,cst_mi_val_19,cst_mi_val_22,cst_mi_val_23)
      AND status=cst_stat_val_2;
  END IF;

  -- 4.If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_ad_language_int_all
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695
    WHERE interface_run_id = l_interface_run_id
      AND (match_ind IS NOT NULL AND match_ind NOT IN (cst_mi_val_21,cst_mi_val_25))
      AND status=cst_stat_val_2;
  END IF;

  -- 5.If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_ad_language_int_all mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_23
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM   hz_person_language  pe, igs_ad_interface_all i
                   WHERE  i.interface_run_id = l_interface_run_id
                    AND   i.interface_id = mi.interface_id
		    AND   pe.language_name = UPPER(mi.language_name)
		    AND   pe.party_id = i.person_id
		    AND   NVL(UPPER(pe.native_language),'N') = NVL(UPPER(mi.native_language),'N')
		    AND   NVL(UPPER(pe.primary_language_indicator),'N') = NVL(UPPER(mi.primary_language_indicator),'N')
		    AND   NVL(UPPER(pe.reads_level),'*!*')  = NVL(UPPER(mi.reads_level),'*!*')
		    AND   NVL(UPPER(pe.speaks_level),'*!*') = NVL(UPPER(mi.speaks_level),'*!*')
		    AND   NVL(UPPER(pe.writes_level),'*!*') = NVL(UPPER(mi.writes_level),'*!*')
		    AND   NVL(UPPER(pe.spoken_comprehension_level),'*!*') = NVL(UPPER(mi.understands_level),'*!*')
		    AND   NVL(UPPER(pe.status),'*!*') = NVL(UPPER(mi.lang_status),'*!*')
		    );
  END IF;

  -- 6.If rule in R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_ad_language_int_all mi
    SET status = cst_stat_val_3,
        match_ind = cst_mi_val_20
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS (SELECT '1'
                   FROM   hz_person_language  pe, igs_ad_interface_all i
                   WHERE  i.interface_run_id = l_interface_run_id
                    AND   i.interface_id = mi.interface_id
        		    AND   pe.party_id = i.person_id
                    AND   pe.language_name = UPPER(mi.language_name));
  END IF;

  FOR person_language_rec IN person_language_cur(l_interface_run_id) LOOP
  DECLARE
    CURSOR check_dup_language(p_person_id NUMBER, p_language_name VARCHAR2 ) IS
    SELECT rowid, hi.*
    FROM  hz_person_language hi
    WHERE hi.party_id = p_person_id
    AND   hi.language_name = p_language_name;
    check_dup_language_rec check_dup_language%ROWTYPE;
  BEGIN
    person_language_rec.language_name   := UPPER(person_language_rec.language_name);
    person_language_rec.native_language := UPPER(person_language_rec.native_language);
    person_language_rec.primary_language_indicator := UPPER(person_language_rec.primary_language_indicator);
    person_language_rec.reads_level := UPPER(person_language_rec.reads_level);
    person_language_rec.speaks_level := UPPER(person_language_rec.speaks_level);
    person_language_rec.writes_level := UPPER(person_language_rec.writes_level);
    person_language_rec.understands_level := UPPER(person_language_rec.understands_level);
    person_language_rec.lang_status := UPPER(person_language_rec.lang_status);

    l_processed_records := l_processed_records + 1 ;

    check_dup_language_rec.language_name := NULL;
    OPEN check_dup_language(person_language_rec.person_id,person_language_rec.language_name);
    FETCH check_dup_language INTO check_dup_language_rec;
    CLOSE check_dup_language;
    IF check_dup_language_rec.language_name IS NOT NULL THEN
      IF l_rule = 'I' THEN
        IF validate_lang(person_language_rec) THEN
        DECLARE
          l_rowid                        VARCHAR2(25);
 	  l_return_status                VARCHAR2(25);
	  l_msg_count                    NUMBER;
	  l_msg_data                     VARCHAR2(2000);
	  l_language_use_reference_id    NUMBER;
	  p_per_language_rec             HZ_PERSON_INFO_V2PUB.person_language_rec_type;

          l_tmp_var1                     VARCHAR2(500);
          l_tmp_var                      VARCHAR2(500);
          l_object_version_number        hz_person_language.OBJECT_VERSION_NUMBER%TYPE;


        BEGIN

          igs_pe_languages_pkg.Languages(
	         p_action 			=>  'UPDATE',
		 P_LANGUAGE_NAME 		=>  person_language_rec.language_name,
		 p_DESCRIPTION			=>  NULL,
		 p_PARTY_ID			=>  person_language_rec.person_id,
		 p_native_language		=>  NVL(person_language_rec.native_language,check_dup_language_rec.native_language),
		 p_primary_language_indicator   =>  NVL(person_language_rec.primary_language_indicator,check_dup_language_rec.primary_language_indicator),
		 P_READS_LEVEL                  =>  NVL(person_language_rec.reads_level,check_dup_language_rec.reads_level),
		 P_SPEAKS_LEVEL                 =>  NVL(person_language_rec.speaks_level,check_dup_language_rec.speaks_level),
		 P_WRITES_LEVEL                 =>  NVL(person_language_rec.writes_level,check_dup_language_rec.writes_level),
		 p_END_DATE                     =>  NULL,
		 p_status                       =>  NVL(person_language_rec.lang_status,check_dup_language_rec.status),
		 p_understand_level             =>  NVL(person_language_rec.understands_level,check_dup_language_rec.spoken_comprehension_level),
		 p_last_update_date             =>  person_language_rec.last_update_date,
		 p_return_status                =>  l_return_status,
		 p_msg_count                    =>  l_msg_count,
		 p_msg_data                     =>  l_msg_data,
		 P_language_use_reference_id 	=>  check_dup_language_rec.language_use_reference_id,
                 p_language_ovn                 =>  check_dup_language_rec.object_version_number
             );

          IF l_return_status IN ('E','U') THEN
	   IF l_msg_count > 1 THEN
	     FOR i IN 1..l_msg_count
	     LOOP
		    l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
		    l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
	     END LOOP;
		    l_msg_data := l_tmp_var1;
	   END IF;

	    UPDATE igs_ad_language_int_all
	    SET    error_code = 'E014',
		     status='3'
	    WHERE interface_language_id = person_language_rec.interface_language_id;

	    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_language.exception1';

		 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		 fnd_message.set_token('INTERFACE_ID',person_language_rec.interface_language_id);
		 fnd_message.set_token('ERROR_CD','E014');

		 l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;

		 fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	    END IF;

	    IF l_enable_log = 'Y' THEN
		 igs_ad_imp_001.logerrormessage(person_language_rec.interface_language_id,'E014');
	    END IF;


	  ELSE

	      UPDATE igs_ad_language_int_all
	      SET    status=cst_stat_val_1,
	      match_ind = cst_mi_val_18
	      WHERE interface_language_id = person_language_rec.interface_language_id;
	  END IF;

	   EXCEPTION
	    WHEN OTHERS THEN

	      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		 IF (l_request_id IS NULL) THEN
		    l_request_id := fnd_global.conc_request_id;
		 END IF;

		 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_language.exception2';

		 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		 fnd_message.set_token('INTERFACE_ID',person_language_rec.interface_language_id);
		 fnd_message.set_token('ERROR_CD','E014');

		 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

		 fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	      END IF;

	      IF l_enable_log = 'Y' THEN
		    igs_ad_imp_001.logerrormessage(person_language_rec.interface_language_id,'E014');
	      END IF;

		UPDATE igs_ad_language_int_all
		SET    match_ind = NULL,
			   status = cst_stat_val_3,
			   error_code = cst_err_val_014
		WHERE  interface_language_id  = person_language_rec.interface_language_id;
	   END;  -- inner begin
          END IF;  -- if validate_lang

        ELSIF l_rule = 'R' THEN
          IF person_language_rec.match_ind = '21' THEN
            IF validate_lang(person_language_rec) THEN
            DECLARE
              l_rowid                        VARCHAR2(25);
              l_return_status                VARCHAR2(25);
              l_msg_count                    NUMBER;
              l_msg_data                     VARCHAR2(4000);
              l_language_use_reference_id    NUMBER;
              p_per_language_rec             HZ_PERSON_INFO_V2PUB.person_language_rec_type;
              l_tmp_var1                     VARCHAR2(500);
              l_tmp_var                      VARCHAR2(500);
              l_object_version_number        hz_person_language.OBJECT_VERSION_NUMBER%TYPE;


            BEGIN

                igs_pe_languages_pkg.Languages(
			p_action 		       => 'UPDATE',
			P_LANGUAGE_NAME 	       => person_language_rec.language_name,
			p_DESCRIPTION		       => NULL,
			p_PARTY_ID		       => person_language_rec.person_id,
			p_native_language	       => NVL(person_language_rec.native_language,check_dup_language_rec.native_language),
			p_primary_language_indicator   => NVL(person_language_rec.primary_language_indicator,check_dup_language_rec.primary_language_indicator),
			P_READS_LEVEL                  => NVL(person_language_rec.reads_level,check_dup_language_rec.reads_level),
			P_SPEAKS_LEVEL                 => NVL(person_language_rec.speaks_level,check_dup_language_rec.speaks_level),
			P_WRITES_LEVEL                 => NVL(person_language_rec.writes_level,check_dup_language_rec.writes_level),
			p_END_DATE                     => NULL,
			p_status                       => NVL(person_language_rec.lang_status,check_dup_language_rec.status),
			p_understand_level             => NVL(person_language_rec.understands_level,check_dup_language_rec.spoken_comprehension_level),
			p_last_update_date             => person_language_rec.last_update_date,
			p_return_status                => l_return_status,
			p_msg_count                    => l_msg_count,
			p_msg_data                     => l_msg_data,
			P_language_use_reference_id    => check_dup_language_rec.language_use_reference_id,
			p_language_ovn                 => check_dup_language_rec.object_version_number
                );

                IF l_return_status IN ('E','U') THEN

                  IF l_msg_count > 1 THEN
                    FOR i IN 1..l_msg_count
                    LOOP
                      l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                      l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
                    END LOOP;
                    l_msg_data := l_tmp_var1;
                  END IF;

                  UPDATE igs_ad_language_int_all
                  SET    error_code = 'E014',
                         status='3'
                  WHERE interface_language_id = person_language_rec.interface_language_id;

		  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

			 IF (l_request_id IS NULL) THEN
			    l_request_id := fnd_global.conc_request_id;
			 END IF;

			 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_language.exception3';

			 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
			 fnd_message.set_token('INTERFACE_ID',person_language_rec.interface_language_id);
			 fnd_message.set_token('ERROR_CD','E014');

			 l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;

			 fnd_log.string_with_context( fnd_log.level_exception,
							  l_label,
							  l_debug_str, NULL,
							  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
		  END IF;

		  IF l_enable_log = 'Y' THEN
			 igs_ad_imp_001.logerrormessage(person_language_rec.interface_language_id,'E014');
		  END IF;

   	       ELSE
		      UPDATE igs_ad_language_int_all
		      SET    status=cst_stat_val_1,
		      match_ind = cst_mi_val_18
		      WHERE interface_language_id = person_language_rec.interface_language_id;
		END IF;

              EXCEPTION
                WHEN OTHERS THEN

		  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

			 IF (l_request_id IS NULL) THEN
			    l_request_id := fnd_global.conc_request_id;
			 END IF;

			 l_label := 'igs.plsql.igs_ad_imp_012.prc_pe_language.exception4';

			 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
			 fnd_message.set_token('INTERFACE_ID',person_language_rec.interface_language_id);
			 fnd_message.set_token('ERROR_CD','E014');

			 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

			 fnd_log.string_with_context( fnd_log.level_exception,
							  l_label,
							  l_debug_str, NULL,
							  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
		  END IF;

		  IF l_enable_log = 'Y' THEN
			 igs_ad_imp_001.logerrormessage(person_language_rec.interface_language_id,'E014');
		  END IF;

                  UPDATE igs_ad_language_int_all
                  SET    match_ind = NULL,
                               status = cst_stat_val_3,
                               error_code = cst_err_val_014
                  WHERE  interface_language_id  = person_language_rec.interface_language_id;
              END;
            END IF; -- if validate_lang
          END IF;  -- if match_ind
         END IF;  -- if l_rule
      ELSE

        crt_prsn_language(p_person_language_rec => person_language_rec) ;

      END IF;  -- if check_dup_lang
      IF l_processed_records = 100 THEN
        COMMIT;
        l_processed_records := 0;
      END IF;
    END;
    END LOOP;
  END prc_pe_language ;

-- Starts procedure PRC_APCNT_ATH_DTLS
--
PROCEDURE prc_apcnt_ath_dtls
(
           p_source_type_id     IN      NUMBER,
           p_batch_id           IN      NUMBER )
AS
  /*
  ||  Created By : prabhat.patel@Oracle.com
  ||  Created On : 15-NOV-2001
  ||  Purpose : This is a private procedure. This procedure is for importing person Athletic details.
  ||            DLD: Person Interface DLD.  Enh Bug# 2103692.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || npalanis         6-JAN-2003      Bug : 2734697
  ||                                  code added to commit after import of every
  ||                                  100 records .New variable l_processed_records added
  ||  npalanis        23-JUL-2002    Bug - 2421865
  ||                                 Validation code writtem for gpa value if negative.
  ||                                 Date validations added.
  ||                                 Lookup code columns are made upper before inserting.
  ||  asbala         16-OCT-2003     Bug 3130316. Import Process Source Category Rule processing changes,
                                     lookup caching related changes, and cursor parameterization.
  */

        l_rule VARCHAR2(1);
        l_error_code igs_pe_ath_dtl_int.error_code%TYPE;
        l_status     igs_pe_ath_dtl_int.status%TYPE;
        l_default_date DATE := IGS_GE_DATE.IGSDATE('4712/12/31');
        l_processed_records NUMBER(5) := 0;
	-- variables for logging
	  l_prog_label  VARCHAR2(4000);
	  l_label  VARCHAR2(4000);
	  l_debug_str VARCHAR2(4000);
	  l_enable_log VARCHAR2(1);
	  l_request_id NUMBER(10);

	  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;


        --Pick up the records for processing from the Athletic Details Interface Table
        CURSOR ath_dtl_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
        SELECT ai.*, i.person_id
        FROM    igs_pe_ath_dtl_int ai,
                igs_ad_interface_all i
        WHERE  ai.interface_run_id = cp_interface_run_id
	AND    i.interface_id = ai.interface_id
        AND    i.interface_run_id = cp_interface_run_id
	AND    ai.status  = '2';


       --Cursor to provide Duplicate check and Null handling while Updating.
       CURSOR dup_chk_ath_dtl_cur(cp_person_id igs_pe_athletic_dtl.person_id%TYPE) IS
       SELECT ROWID, ad.*
       FROM   igs_pe_athletic_dtl ad
       WHERE  person_id  = cp_person_id;

       --Cursor to check for Discrepancy
        dup_chk_ath_dtl_rec    dup_chk_ath_dtl_cur%ROWTYPE;
        ath_dtl_rec            ath_dtl_cur%ROWTYPE;


-- Start Local Procedure crt_apcnt_ath_dtl
PROCEDURE crt_apcnt_ath_dtl(
		p_ath_dtl_rec   IN      ath_dtl_cur%ROWTYPE
		 )
AS
	l_rowid VARCHAR2(25);
	l_athletic_details_id   igs_pe_athletic_dtl.athletic_details_id%TYPE;
	l_error_code            igs_pe_ath_dtl_int.error_code%TYPE;
BEGIN
                -- Call Log header
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_003.crt_apcnt_ath_dtls.begin';
    l_debug_str := 'Interface ATHLETIC DTLS Id : ' || p_ath_dtl_rec.interface_athletic_dtls_id;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
    			          l_debug_str, NULL,
				  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

                igs_pe_athletic_dtl_pkg.insert_row (
                                         x_rowid               => l_rowid,
                                         x_athletic_details_id => l_athletic_details_id,
                                         x_person_id           => p_ath_dtl_rec.person_id,
                                         x_athletic_gpa        => p_ath_dtl_rec.athletic_gpa,
                                         x_eligibility_status_cd => p_ath_dtl_rec.eligibility_status_cd,
                                         x_predict_elig_code   => p_ath_dtl_rec.predict_elig_code,
                                         x_tentative_adm_code  => p_ath_dtl_rec.tentative_adm_code,
                                         x_review_date         => p_ath_dtl_rec.review_date,
                                         x_comments            => p_ath_dtl_rec.comments,
                                         x_mode                => 'R'
                                         );
                l_error_code:=NULL;
                UPDATE igs_pe_ath_dtl_int
                SET    status     = '1',
                       error_code = l_error_code
                WHERE  interface_athletic_dtls_id = p_ath_dtl_rec.interface_athletic_dtls_id;

        EXCEPTION
                WHEN OTHERS THEN
                        l_error_code := 'E093'; -- Athletics Details Insertion Failed

                        UPDATE igs_pe_ath_dtl_int
                        SET    status     = '3',
                               error_code = l_error_code
                        WHERE  interface_athletic_dtls_id = p_ath_dtl_rec.interface_athletic_dtls_id;

                        -- Call Log detail
		  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		    IF (l_request_id IS NULL) THEN
		      l_request_id := fnd_global.conc_request_id;
		    END IF;

		    l_label := 'igs.plsql.igs_ad_imp_003.crt_apcnt_ath_dtl.exception '||'E093';

		      l_debug_str :=  'igs_ad_imp_003.prc_apcnt_ath_dtls.crt_apcnt_ath_dtl'
					||' Exception from igs_pe_athletic_dtl_Pkg.Insert_Row '
					|| ' INTERFACE_ATHLETIC_DTLS_ID : ' ||
					(p_ath_dtl_rec.interface_athletic_dtls_id) ||
					' Status : ' || '3' ||  ' ErrorCode : ' ||  l_error_code
					||' SQLERRM:' ||  SQLERRM;

		    fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
		  END IF;

		IF l_enable_log = 'Y' THEN
		  igs_ad_imp_001.logerrormessage(p_ath_dtl_rec.interface_athletic_dtls_id,'E093','IGS_PE_ATH_DTL_INT');
		END IF;

        END crt_apcnt_ath_dtl;
-- END OF LOCAL PROCEDURE crt_apcnt_ath_dtl


-- Start Local function Validate_Record

FUNCTION validate_record(p_ath_dtl_rec  IN      ath_dtl_cur%ROWTYPE)
	  RETURN BOOLEAN IS
	  l_error_code   igs_pe_ath_dtl_int.error_code%TYPE;
	  l_birth_dt  IGS_AD_INTERFACE.BIRTH_DT%TYPE;
	  l_person_id IGS_AD_INTERFACE.PERSON_ID%TYPE;

	CURSOR birth_dt_cur(p_person_id IGS_AD_INTERFACE.PERSON_ID%TYPE) IS
	SELECT Birth_date
	FROM IGS_PE_PERSON_BASE_V
	WHERE  person_id= p_person_id;

BEGIN

	-- ELIGIBILITY_STATUS_ID
	-- kumma, 2608360 replaced the igs_ad_code_classes with igs_lookup_values

  IF p_ath_dtl_rec.eligibility_status_cd IS NOT NULL THEN
    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('PE_ATH_ELG_STATUS',p_ath_dtl_rec.eligibility_status_cd,8405))
    THEN
	 l_error_code := 'E095'; -- Person Athletics Details Validation Failed - Eligibility Status
	 RAISE no_data_found;
    END IF;
  ELSE
    l_error_code := NULL;
  END IF;

	-- TENTATIVE_ADM_CD

      IF p_ath_dtl_rec.tentative_adm_code IS NOT NULL AND
      NOT
      (igs_pe_pers_imp_001.validate_lookup_type_code('PE_TENTATIVE_ADM_TYPE',p_ath_dtl_rec.tentative_adm_code,8405))
      THEN
	 l_error_code := 'E096'; -- Person Athletics Details Validation Failed - Tentative Admission Code
	 RAISE no_data_found;
      ELSE
	 l_error_code := NULL;
      END IF;

	-- PREDICT_ELIG_CODE

      IF p_ath_dtl_rec.predict_elig_code IS NOT NULL AND
      NOT
      (igs_pe_pers_imp_001.validate_lookup_type_code('PE_PRE_ELIG_TYPE',p_ath_dtl_rec.predict_elig_code,8405))
      THEN
	 l_error_code := 'E097'; -- Person Athletics Details Validation Failed - Predicted Eligibility
	 RAISE no_data_found;
      ELSE
	 l_error_code := NULL;
      END IF;

      IF p_ath_dtl_rec.ATHLETIC_GPA IS NOT NULL AND p_ath_dtl_rec.ATHLETIC_GPA < 0 THEN
	 l_error_code := 'E283';
	 RAISE no_data_found;
      ELSE
	 l_error_code := NULL;
      END IF;

      IF p_ath_dtl_rec.review_date IS NOT NULL THEN

	OPEN Birth_dt_cur(p_ath_dtl_rec.person_id) ;
	FETCH Birth_dt_cur INTO l_birth_dt;
	   IF l_birth_dt IS NOT NULL AND l_birth_dt > p_ath_dtl_rec.review_date THEN
		    l_error_code := 'E284';
		    CLOSE Birth_dt_cur;
		    RAISE no_data_found;
	   ELSE
		    l_error_code := NULL;
	   END IF;
	CLOSE Birth_dt_cur;
      END IF;
      RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN

	UPDATE igs_pe_ath_dtl_int
	SET    status     = '3',
	       error_code = l_error_code
	WHERE  interface_athletic_dtls_id = p_ath_dtl_rec.interface_athletic_dtls_id;

			-- Call Log detail
	  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

	    IF (l_request_id IS NULL) THEN
	      l_request_id := fnd_global.conc_request_id;
	    END IF;

	    l_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_ath_dtls.exception '||l_error_code;

	      l_debug_str :=  'igs_ad_imp_003.prc_apcnt_ath_dtls.validate_record '
				|| ' Validation Failed for '
				|| ' INTERFACE_ATHLETIC_DTLS_ID : ' ||
				(p_ath_dtl_rec.interface_athletic_dtls_id) ||
				' Status : ' || '3' ||  ' ErrorCode : ' ||
				l_error_code||' SQLERRM:' ||  SQLERRM;

	    fnd_log.string_with_context( fnd_log.level_exception,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	  END IF;

	IF l_enable_log = 'Y' THEN
	  igs_ad_imp_001.logerrormessage(p_ath_dtl_rec.interface_athletic_dtls_id,l_error_code,'IGS_PE_ATH_DTL_INT');
	END IF;
	RETURN FALSE;
END validate_record;
-- End Local function Validate_Record

BEGIN

        -- Call Log header
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_prog_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_ath_dtls';
  l_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_ath_dtls.';

  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_ath_dtls.begin';
    l_debug_str := 'Batch Id : ' || p_batch_id ;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
    			          l_debug_str, NULL,
				  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  l_rule :=  igs_ad_imp_001.find_source_cat_rule(
				   p_source_type_id     =>  P_SOURCE_TYPE_ID,
				   p_category           =>  'PERSON_ATHLETICS');


  -- 1.If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN

    UPDATE igs_pe_ath_dtl_int
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND interface_run_id = l_interface_run_id
      AND status = cst_stat_val_2;
  END IF;

  --2. If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_pe_ath_dtl_int ai
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_19
    WHERE ai.interface_run_id = l_interface_run_id
      AND ai.status = cst_stat_val_2
      AND EXISTS(  SELECT '1'
                   FROM   igs_pe_athletic_dtl  pe, igs_ad_interface_all i
                   WHERE  i.interface_id = ai.interface_id
		     AND  i.interface_run_id = l_interface_run_id
                     AND  pe.person_id = NVL(i.person_id, -99)
		     );
  END IF;

  -- 3.If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_pe_ath_dtl_int
    SET status = cst_stat_val_1
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN (cst_mi_val_18,cst_mi_val_19,cst_mi_val_22,cst_mi_val_23)
      AND status=cst_stat_val_2;
  END IF;

  -- 4.If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_pe_ath_dtl_int
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695
    WHERE interface_run_id = l_interface_run_id
      AND (match_ind IS NOT NULL AND match_ind NOT IN (cst_mi_val_21,cst_mi_val_25))
      AND status=cst_stat_val_2;
  END IF;

  -- 5.If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_pe_ath_dtl_int mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_23
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM   igs_pe_athletic_dtl  pe, igs_ad_interface_all i
                   WHERE  i.interface_id = mi.interface_id
		     AND  i.interface_run_id = l_interface_run_id
                     AND  pe.person_id = NVL(i.person_id, -99) AND
		      NVL(pe.athletic_gpa, -99)      = NVL(mi.athletic_gpa,-99) AND
		      NVL(UPPER(pe.eligibility_status_cd), '~')      = NVL(UPPER(mi.eligibility_status_cd),'~') AND
		      NVL(UPPER(pe.predict_elig_code), '~')  = NVL(UPPER(mi.predict_elig_code),'~') AND
		      NVL(UPPER(pe.tentative_adm_code), '~') = NVL(UPPER(mi.tentative_adm_code),'~') AND
		      NVL(TRUNC(pe.review_date),l_default_date)= NVL(TRUNC(mi.review_date),l_default_date) AND
		      NVL(UPPER(pe.comments), '~')           = NVL(UPPER(mi.comments), '~'));
  END IF;

  -- 6.If rule in R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_pe_ath_dtl_int ai
    SET status = cst_stat_val_3,
        match_ind = cst_mi_val_18,
	dup_athletic_details_id = (SELECT athletic_details_id
	                           FROM igs_pe_athletic_dtl  pe, igs_ad_interface_all i
				   WHERE  i.interface_id = ai.interface_id
				     AND  i.interface_run_id = l_interface_run_id
				     AND  pe.person_id = NVL(i.person_id, -99))
    WHERE ai.interface_run_id = l_interface_run_id
      AND ai.match_ind IS NULL
      AND ai.status = cst_stat_val_2
      AND EXISTS (SELECT '1'
                   FROM   igs_pe_athletic_dtl  pe, igs_ad_interface_all i
                   WHERE  i.interface_id = ai.interface_id
		     AND  i.interface_run_id = l_interface_run_id
                     AND  pe.person_id = NVL(i.person_id, -99));
  END IF;

      FOR ath_dtl_rec IN ath_dtl_cur(l_interface_run_id) LOOP

        l_processed_records := l_processed_records + 1 ;

        ath_dtl_rec.eligibility_status_cd := UPPER(ath_dtl_rec.eligibility_status_cd);
        ath_dtl_rec.tentative_adm_code := UPPER(ath_dtl_rec.tentative_adm_code);
        ath_dtl_rec.predict_elig_code  := UPPER(ath_dtl_rec.predict_elig_code);
        ath_dtl_rec.review_date := TRUNC(ath_dtl_rec.review_date);

        IF validate_record(ath_dtl_rec) THEN
	-- For each record picked up do the following :
	-- Check to see if the record already exists.
	      dup_chk_ath_dtl_rec.athletic_details_id := NULL;
	   OPEN  dup_chk_ath_dtl_cur(ath_dtl_rec.person_id);
	   FETCH dup_chk_ath_dtl_cur INTO dup_chk_ath_dtl_rec;
	   CLOSE dup_chk_ath_dtl_cur;

	   --If its a duplicate record find the source category rule for that Source Category.
	   IF dup_chk_ath_dtl_rec.athletic_details_id IS NOT NULL THEN

		IF l_rule = 'I' THEN

		  BEGIN
		      igs_pe_athletic_dtl_pkg.update_row (
					       x_rowid               => dup_chk_ath_dtl_rec.rowid,
					       x_athletic_details_id => dup_chk_ath_dtl_rec.athletic_details_id,
					       x_person_id           => NVL(ath_dtl_rec.person_id,dup_chk_ath_dtl_rec.person_id),
					       x_athletic_gpa        => NVL(ath_dtl_rec.athletic_gpa,dup_chk_ath_dtl_rec.athletic_gpa),
					       x_eligibility_status_cd => NVL(ath_dtl_rec.eligibility_status_cd,dup_chk_ath_dtl_rec.eligibility_status_cd),
					       x_predict_elig_code   => NVL(ath_dtl_rec.predict_elig_code,dup_chk_ath_dtl_rec.predict_elig_code),
					       x_tentative_adm_code  => NVL(ath_dtl_rec.tentative_adm_code,dup_chk_ath_dtl_rec.tentative_adm_code),
					       x_review_date         => NVL(ath_dtl_rec.review_date,dup_chk_ath_dtl_rec.review_date),
					       x_comments            => NVL(ath_dtl_rec.comments,dup_chk_ath_dtl_rec.comments),
					       x_mode                => 'R'
						 );
			l_error_code := NULL;
			l_status := '1';

			UPDATE  igs_pe_ath_dtl_int
			SET     status = l_status,
				error_code = l_error_code,
				match_ind = cst_mi_val_18  -- '18' Match occured and used import values
			WHERE   interface_athletic_dtls_id = ath_dtl_rec.interface_athletic_dtls_id;

			EXCEPTION
			  WHEN OTHERS THEN
				l_error_code := 'E094'; -- Could not update Person Athletics Details
				l_status := '3';

			  UPDATE        igs_pe_ath_dtl_int
			  SET           status = l_status,
					error_code = l_error_code
			  WHERE         interface_athletic_dtls_id = ath_dtl_rec.interface_athletic_dtls_id;

				-- Call Log detail
			  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

			    IF (l_request_id IS NULL) THEN
			      l_request_id := fnd_global.conc_request_id;
			    END IF;

			    l_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_ath_dtls.exception2 '||l_error_code;

			      l_debug_str :=  'igs_ad_imp_003.prc_apcnt_ath_dtls'
					||' Exception from igs_pe_athletic_dtl_Pkg.Update_Row '
					|| ' INTERFACE_ATHLETIC_DTLS_ID : ' ||
					(ath_dtl_rec.interface_athletic_dtls_id) ||
					' Status : ' || '3' ||  ' ErrorCode : ' ||
					l_error_code ||' SQLERRM:' ||  SQLERRM;

			    fnd_log.string_with_context( fnd_log.level_exception,
							  l_label,
							  l_debug_str, NULL,
							  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
			  END IF;

			IF l_enable_log = 'Y' THEN
			  igs_ad_imp_001.logerrormessage(ath_dtl_rec.interface_athletic_dtls_id,l_error_code,'IGS_PE_ATH_DTL_INT');
			END IF;

			END;

		ELSIF l_rule = 'R' THEN
		 IF  ath_dtl_rec.match_ind = '21' THEN  -- '21' Match reviewed and to be imported
		  BEGIN
		      igs_pe_athletic_dtl_pkg.update_row (
					       x_rowid               => dup_chk_ath_dtl_rec.rowid,
					       x_athletic_details_id => dup_chk_ath_dtl_rec.athletic_details_id,
					       x_person_id           => NVL(ath_dtl_rec.person_id,dup_chk_ath_dtl_rec.person_id),
					       x_athletic_gpa        => NVL(ath_dtl_rec.athletic_gpa,dup_chk_ath_dtl_rec.athletic_gpa),
					       x_eligibility_status_cd => NVL(ath_dtl_rec.eligibility_status_cd,dup_chk_ath_dtl_rec.eligibility_status_cd),
					       x_predict_elig_code   => NVL(ath_dtl_rec.predict_elig_code,dup_chk_ath_dtl_rec.predict_elig_code),
					       x_tentative_adm_code  => NVL(ath_dtl_rec.tentative_adm_code,dup_chk_ath_dtl_rec.tentative_adm_code),
					       x_review_date         => NVL(ath_dtl_rec.review_date,dup_chk_ath_dtl_rec.review_date),
					       x_comments            => NVL(ath_dtl_rec.comments,dup_chk_ath_dtl_rec.comments),
					       x_mode                => 'R'
						 );
			l_error_code := NULL;
			l_status := '1';

			UPDATE  igs_pe_ath_dtl_int
			SET     status = l_status,
				error_code = l_error_code,
				match_ind = cst_mi_val_18
			WHERE   interface_athletic_dtls_id = ath_dtl_rec.interface_athletic_dtls_id;

			EXCEPTION
			  WHEN OTHERS THEN
				l_error_code := 'E094'; -- Could not update Person Athletics Details
				l_status := '3';

			  UPDATE        igs_pe_ath_dtl_int
			  SET           status = l_status,
					error_code = l_error_code
			  WHERE         interface_athletic_dtls_id = ath_dtl_rec.interface_athletic_dtls_id;

				-- Call Log detail
			  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

			    IF (l_request_id IS NULL) THEN
			      l_request_id := fnd_global.conc_request_id;
			    END IF;

			    l_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_ath_dtls.exception1 '||l_error_code;

			      l_debug_str :=  'igs_ad_imp_003.prc_apcnt_ath_dtls'
					||' Exception from igs_pe_athletic_dtl_Pkg.Update_Row '
					|| ' INTERFACE_ATHLETIC_DTLS_ID : ' ||
					(ath_dtl_rec.interface_athletic_dtls_id) ||
					' Status : ' || '3' ||  ' ErrorCode : ' ||
					l_error_code ||' SQLERRM:' ||  SQLERRM;

			    fnd_log.string_with_context( fnd_log.level_exception,
							  l_label,
							  l_debug_str, NULL,
							  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
			  END IF;

			IF l_enable_log = 'Y' THEN
			  igs_ad_imp_001.logerrormessage(ath_dtl_rec.interface_athletic_dtls_id,l_error_code,'IGS_PE_ATH_DTL_INT');
			END IF;

			END;
		    END IF;  -- ath_dtl_rec.MATCH_IND check

		END IF;--  l_rule  check for 'I','R' or 'E'.

	ELSE    -- If its not a duplicate record then Create a new record in OSS
		crt_apcnt_ath_dtl (p_ath_dtl_rec => ath_dtl_rec);

	END IF; -- Record existance in IGS_PE_ATHLETIC_DTL check
  END IF; -- Check for Validate Record

	IF l_processed_records = 100 THEN
	COMMIT;
	l_processed_records := 0;
	END IF;

  END LOOP;
END prc_apcnt_ath_dtls;

--
-- Starts procedure PRC_APCNT_ATH_PRG
--
PROCEDURE prc_apcnt_ath_prg
(
           p_source_type_id     IN      NUMBER,
           p_batch_id           IN      NUMBER )
AS
  /*
  ||  Created By : prabhat.patel@Oracle.com
  ||  Created On : 14-NOV-2001
  ||  Purpose : This is a private procedure. This procedure is for importing person Athletic Program Information.
  ||            DLD: Person Interface DLD.  Enh Bug# 2103692.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || npalanis         6-JAN-2003      Bug : 2734697
  ||                                  code added to commit after import of every
  ||                                  100 records .New variable l_processed_records added
  ||  npalanis        23-JUL-2002    Bug - 2421865
  ||                                 Date validations added.
  ||  asbala          16-OCT-2003    Bug 3130316. Import Process Source Category Rule processing changes,
                                     lookup caching related changes, and cursor parameterization.
  */

        l_rule VARCHAR2(1);
        l_error_code igs_pe_ath_prg_int.error_code%TYPE;
        l_status     igs_pe_ath_prg_int.status%TYPE;
        l_default_date DATE := IGS_GE_DATE.IGSDATE('4712/12/31');
        l_processed_records NUMBER(5) := 0;
	-- variables for logging
	  l_prog_label  VARCHAR2(4000);
	  l_label  VARCHAR2(4000);
	  l_debug_str VARCHAR2(4000);
	  l_enable_log VARCHAR2(1);
	  l_request_id NUMBER(10);

	  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

        --Pick up the records for processing from the Athletic Programs Interface Table
        CURSOR ath_prg_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
        SELECT ai.*, i.person_id
        FROM    igs_pe_ath_prg_int ai, igs_ad_interface_all i
        WHERE  ai.interface_run_id = cp_interface_run_id
	AND    i.interface_id = ai.interface_id
        AND    i.interface_run_id = cp_interface_run_id
	AND    ai.status  = '2';


       --Cursor to check for duplicates and provide Null handling while Updating.
       CURSOR dup_chk_ath_prg_cur(cp_person_id igs_pe_athletic_prg.person_id%TYPE,
                                  cp_athletic_prg_code igs_pe_athletic_prg.athletic_prg_code%TYPE,
                                  cp_start_date igs_pe_athletic_prg.start_date%TYPE) IS
       SELECT ROWID, ap.*
       FROM   igs_pe_athletic_prg ap
       WHERE  person_id  = cp_person_id AND
              UPPER(athletic_prg_code) = UPPER(cp_athletic_prg_code) AND
              start_date = cp_start_date;


        dup_chk_ath_prg_rec    dup_chk_ath_prg_cur%ROWTYPE;
        ath_prg_rec            ath_prg_cur%ROWTYPE;


-- Start Local Procedure crt_apcnt_ath_prg
PROCEDURE crt_apcnt_ath_prg(
		p_ath_prg_rec   IN      ath_prg_cur%ROWTYPE
		 )
AS
	l_rowid VARCHAR2(25);
	l_athletic_prg_id   igs_pe_athletic_prg.athletic_prg_id%TYPE;
	l_error_code        igs_pe_ath_prg_int.error_code%TYPE;
BEGIN
                -- Call Log header
   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_003.crt_apcnt_ath_prg.begin';
    l_debug_str := 'Interface athletic prg Id : ' || p_ath_prg_rec.interface_athletic_prg_id;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
    			          l_debug_str, NULL,
				  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;


                igs_pe_athletic_prg_pkg.insert_row (
                                         x_rowid               => l_rowid,
                                         x_athletic_prg_id => l_athletic_prg_id,
                                         x_person_id        => p_ath_prg_rec.person_id,
                                         x_athletic_prg_code => p_ath_prg_rec.athletic_prg_code,
                                         x_rating           => p_ath_prg_rec.rating,
                                         x_start_date       => p_ath_prg_rec.start_date,
                                         x_end_date         => p_ath_prg_rec.end_date,
                                         x_recruited_ind    => p_ath_prg_rec.recruited_ind,
                                         x_participating_ind => p_ath_prg_rec.participating_ind,
                                         x_last_update_dt   => p_ath_prg_rec.last_update_date,
                                         x_mode             => 'R'
                                           );
                l_error_code:=NULL;
                UPDATE igs_pe_ath_prg_int
                SET    status     = '1',
                       error_code = l_error_code
                WHERE  interface_athletic_prg_id = p_ath_prg_rec.interface_athletic_prg_id;

        EXCEPTION
                WHEN OTHERS THEN
                        l_error_code := 'E099'; -- Athletics Program Insertion Failed

                        UPDATE igs_pe_ath_prg_int
                        SET    status     = '3',
                               error_code = l_error_code
                        WHERE  interface_athletic_prg_id = p_ath_prg_rec.interface_athletic_prg_id;

                        -- Call Log detail
		  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		    IF (l_request_id IS NULL) THEN
		      l_request_id := fnd_global.conc_request_id;
		    END IF;

		    l_label := 'igs.plsql.igs_ad_imp_003.crt_apcnt_ath_dtl.exception '||l_error_code;

		      l_debug_str := 'igs_ad_imp_003.prc_apcnt_ath_prg.crt_apcnt_ath_prg'
					||' Exception from igs_pe_athletic_prg_Pkg.Insert_Row '
					|| ' INTERFACE_ATHLETIC_PRG_ID : ' ||
					(p_ath_prg_rec.interface_athletic_prg_id) ||
					' Status : ' || '3' ||  ' ErrorCode : ' ||  l_error_code
					||' SQLERRM:' ||  SQLERRM;

		    fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
		  END IF;

		IF l_enable_log = 'Y' THEN
		  igs_ad_imp_001.logerrormessage(p_ath_prg_rec.interface_athletic_prg_id,l_error_code,'IGS_PE_ATH_PRG_INT');
		END IF;
        END crt_apcnt_ath_prg;
-- END OF LOCAL PROCEDURE crt_apcnt_ath_prg

-- Start Local function Validate_Record
        FUNCTION validate_record(p_ath_prg_rec  IN      ath_prg_cur%ROWTYPE)
                  RETURN BOOLEAN IS
                  l_error_code   igs_pe_ath_prg_int.error_code%TYPE;
                  l_birth_dt  IGS_AD_INTERFACE.BIRTH_DT%TYPE;

                CURSOR birth_dt_cur(p_person_id IGS_AD_INTERFACE.PERSON_ID%TYPE) IS
                SELECT Birth_date
                FROM IGS_PE_PERSON_BASE_V
                WHERE  person_id= p_person_id;
        BEGIN

                -- ATHLETIC_PRG_CD
		--kumma, 2608360 replaced the igs_ad_code_classes code with igs_lookup_values

		/*
                FROM   igs_ad_code_classes cc
                WHERE  cc.class='SPORTS_TYPES' AND
                       NVL(closed_ind,'N') = 'N' AND
                       code_id = p_ath_prg_rec.athletic_prg_code;
		       */


              IF (p_ath_prg_rec.athletic_prg_code IS NOT NULL AND
	      NOT
	      (igs_pe_pers_imp_001.validate_lookup_type_code('PE_ATH_PRG_TYPE',p_ath_prg_rec.athletic_prg_code,8405)))
	      OR(p_ath_prg_rec.athletic_prg_code IS NULL)  THEN
                 l_error_code := 'E101'; -- Person Athletics Program Validation Failed - Athletic Program Code
                 RAISE no_data_found;
              ELSE
                 l_error_code := NULL;
              END IF;

                OPEN Birth_dt_cur(p_ath_prg_rec.person_id) ;
                FETCH Birth_dt_cur INTO l_birth_dt;
                   IF l_birth_dt IS NOT NULL AND l_birth_dt > p_ath_prg_rec.start_date THEN
                      l_error_code := 'E222';
                      CLOSE Birth_dt_cur;
                      RAISE no_data_found;
                    END IF;
                CLOSE Birth_dt_cur;


                 -- START_DATE and END_DATE
              IF p_ath_prg_rec.end_date IS NOT NULL THEN
                   IF p_ath_prg_rec.end_date < p_ath_prg_rec.start_date THEN
                        l_error_code := 'E208'; -- Person Athletics Program Validation Failed - End Date
                        RAISE no_data_found;
                   END IF;
              END IF;

                -- RECRUITED_IND
              IF p_ath_prg_rec.recruited_ind  NOT IN ('Y','N')THEN
                 l_error_code := 'E103'; -- Person Athletics Program Validation Failed - Recruited Indicator
                 RAISE no_data_found;
              END IF;

              -- PARTICIPATING_IND
              IF p_ath_prg_rec.participating_ind NOT IN ('Y', 'N') THEN
                 l_error_code := 'E104'; -- Person Athletics Program Validation Failed - Participating Indicator
                 RAISE no_data_found;
              END IF;

                RETURN TRUE;
        EXCEPTION
                WHEN OTHERS THEN

                        UPDATE igs_pe_ath_prg_int
                        SET    status     = '3',
                               error_code = l_error_code
                        WHERE  interface_athletic_prg_id = p_ath_prg_rec.interface_athletic_prg_id;

                        -- Call Log detail
			  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

			    IF (l_request_id IS NULL) THEN
			      l_request_id := fnd_global.conc_request_id;
			    END IF;

			    l_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_ath_prg.val_exception '||l_error_code;

			      l_debug_str :=  'igs_ad_imp_003.prc_apcnt_ath_prg.validate_record'
                                                || ' Validation Failed for'
                                                || ' INTERFACE_ATHLETIC_PRG_ID : ' ||
                                                (p_ath_prg_rec.interface_athletic_prg_id) ||
                                                ' Status : ' || '3' ||  ' ErrorCode : ' ||
						l_error_code||' SQLERRM:' ||  SQLERRM;

			    fnd_log.string_with_context( fnd_log.level_exception,
							  l_label,
							  l_debug_str, NULL,
							  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
			  END IF;

			IF l_enable_log = 'Y' THEN
			  igs_ad_imp_001.logerrormessage(p_ath_prg_rec.interface_athletic_prg_id,l_error_code,'IGS_PE_ATH_PRG_INT');
			END IF;

                        RETURN FALSE;
        END validate_record;
-- End Local function Validate_Record
-- Start of main procedure
BEGIN

  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_prog_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_ath_prg';
  l_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_ath_prg.';

  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_ath_prg.begin';
    l_debug_str := 'Batch Id : ' || p_batch_id ;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
    			          l_debug_str, NULL,
				  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  l_rule :=  igs_ad_imp_001.find_source_cat_rule(
					   p_source_type_id     =>  P_SOURCE_TYPE_ID,
					   p_category           =>  'PERSON_ATHLETICS');


  -- 1.If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_pe_ath_prg_int
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND interface_run_id = l_interface_run_id
      AND status = cst_stat_val_2;
  END IF;

  --2. If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
--skpandey, Bug#3702782, Changed select statement for optimization
    UPDATE igs_pe_ath_prg_int ai
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_19
    WHERE ai.interface_run_id = l_interface_run_id
      AND ai.status = cst_stat_val_2
      AND EXISTS(  SELECT '1'
                   FROM   igs_pe_athletic_prg  pe, igs_ad_interface_all i
                   WHERE  i.interface_id = ai.interface_id
		     AND  i.interface_run_id = l_interface_run_id
                     AND  pe.person_id  = NVL(i.person_id, -99) AND
                     pe.athletic_prg_code = UPPER(ai.athletic_prg_code) AND
                     pe.start_date = TRUNC(ai.start_date)
		     );
  END IF;

  -- 3.If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_pe_ath_prg_int
    SET status = cst_stat_val_1
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN (cst_mi_val_18,cst_mi_val_19,cst_mi_val_22,cst_mi_val_23)
      AND status=cst_stat_val_2;
  END IF;

  -- 4.If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_pe_ath_prg_int
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695
    WHERE interface_run_id = l_interface_run_id
      AND (match_ind IS NOT NULL AND match_ind NOT IN (cst_mi_val_21,cst_mi_val_25))
      AND status=cst_stat_val_2;
  END IF;

  -- 5.If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
--skpandey, Bug#3702782, Changed select statement for optimization
    UPDATE igs_pe_ath_prg_int ai
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_23
    WHERE ai.interface_run_id = l_interface_run_id
      AND ai.match_ind IS NULL
      AND ai.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM   igs_pe_athletic_prg  pe, igs_ad_interface_all i
                   WHERE  i.interface_id = ai.interface_id
		     AND  i.interface_run_id = l_interface_run_id
                     AND  pe.person_id  = NVL(i.person_id, -99) AND
                     pe.athletic_prg_code = UPPER(ai.athletic_prg_code) AND
                     pe.start_date = TRUNC(ai.start_date) AND
	              NVL(UPPER(pe.rating), '~') = NVL(UPPER(ai.rating),'~') AND
	              NVL(pe.end_date, l_default_date ) = NVL(TRUNC(ai.end_date),l_default_date) AND
		      NVL(UPPER(pe.recruited_ind),'N') = NVL(UPPER(ai.recruited_ind),'N') AND
		      NVL(UPPER(pe.participating_ind),'N') = NVL(UPPER(ai.participating_ind),'N'));
  END IF;

  -- 6.If rule in R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
--skpandey, Bug#3702782, Changed select statement for optimization
    UPDATE igs_pe_ath_prg_int ai
    SET status = cst_stat_val_3,
        match_ind = cst_mi_val_20,
	dup_athletic_prg_id = (SELECT athletic_prg_id
	                           FROM igs_pe_athletic_prg  pe, igs_ad_interface_all i
				   WHERE  i.interface_id = ai.interface_id
				     AND  i.interface_run_id = l_interface_run_id
				     AND  pe.person_id  = NVL(i.person_id, -99) AND
				     pe.athletic_prg_code = UPPER(ai.athletic_prg_code) AND
				     pe.start_date = TRUNC(ai.start_date))
    WHERE ai.interface_run_id = l_interface_run_id
      AND ai.match_ind IS NULL
      AND ai.status = cst_stat_val_2
      AND EXISTS (SELECT '1'
                   FROM   igs_pe_athletic_prg  pe, igs_ad_interface_all i
                   WHERE  i.interface_id = ai.interface_id
		     AND  i.interface_run_id = l_interface_run_id
                     AND  pe.person_id  = NVL(i.person_id, -99) AND
                     pe.athletic_prg_code = UPPER(ai.athletic_prg_code) AND
                     pe.start_date = TRUNC(ai.start_date));
  END IF;

  FOR ath_prg_rec IN ath_prg_cur(l_interface_run_id) LOOP

      l_processed_records := l_processed_records + 1 ;

      ath_prg_rec.athletic_prg_code := UPPER(ath_prg_rec.athletic_prg_code);
      ath_prg_rec.recruited_ind := UPPER(ath_prg_rec.recruited_ind);
      ath_prg_rec.participating_ind := UPPER(ath_prg_rec.participating_ind);
      ath_prg_rec.end_date := TRUNC(ath_prg_rec.end_date);
      ath_prg_rec.start_date := TRUNC(ath_prg_rec.start_date);

        IF validate_record(ath_prg_rec) THEN
                -- For each record picked up do the following :
                -- Check to see if the record already exists.
                        dup_chk_ath_prg_rec.athletic_prg_id := NULL;
                   OPEN  dup_chk_ath_prg_cur(ath_prg_rec.person_id,
                                             ath_prg_rec.athletic_prg_code,
                                             ath_prg_rec.start_date );
                   FETCH dup_chk_ath_prg_cur INTO dup_chk_ath_prg_rec;
                   CLOSE dup_chk_ath_prg_cur;

                   --If its a duplicate record find the source category rule for that Source Category.
                   IF dup_chk_ath_prg_rec.athletic_prg_id IS NOT NULL THEN
                        IF l_rule = 'I' THEN
                          BEGIN
                              igs_pe_athletic_prg_pkg.update_row (
                                                       x_rowid              => dup_chk_ath_prg_rec.rowid,
                                                       x_athletic_prg_id    => dup_chk_ath_prg_rec.athletic_prg_id,
                                                       x_person_id          => NVL(ath_prg_rec.person_id,dup_chk_ath_prg_rec.person_id),
                                                       x_athletic_prg_code  => ath_prg_rec.athletic_prg_code,
                                                       x_rating             => NVL(ath_prg_rec.rating,dup_chk_ath_prg_rec.rating),
                                                       x_start_date         => ath_prg_rec.start_date,
                                                       x_end_date           => NVL(ath_prg_rec.end_date,dup_chk_ath_prg_rec.end_date),
                                                       x_recruited_ind      => ath_prg_rec.recruited_ind,
                                                       x_participating_ind  => ath_prg_rec.participating_ind,
                                                       x_last_update_dt     =>nvl(ath_prg_rec.last_update_date,dup_chk_ath_prg_rec.last_update_dt),
                                                       x_mode               => 'R'
                                                         );
                                l_error_code := NULL;
                                l_status := '1';

                                UPDATE  igs_pe_ath_prg_int
                                SET     status = l_status,
                                        error_code = l_error_code,
                                        match_ind = cst_mi_val_18  -- '18' Match occured and used import values
                                WHERE   interface_athletic_prg_id = ath_prg_rec.interface_athletic_prg_id;

                                EXCEPTION
                                  WHEN OTHERS THEN
                                        l_error_code := 'E100'; -- Could not update Person Athletics Program Details
                                        l_status := '3';

                                  UPDATE        igs_pe_ath_prg_int
                                  SET           status = l_status,
                                                error_code = l_error_code
                                  WHERE         interface_athletic_prg_id = ath_prg_rec.interface_athletic_prg_id;

                                        -- Call Log detail
				  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

				    IF (l_request_id IS NULL) THEN
				      l_request_id := fnd_global.conc_request_id;
				    END IF;

				    l_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_ath_prg.exception1 '||l_error_code;

				      l_debug_str :=  'igs_ad_imp_003.prc_apcnt_ath_prg'
                                                ||' Exception from igs_pe_athletic_prg_Pkg.Update_Row '
                                                || ' INTERFACE_ATHLETIC_PRG_ID : ' ||
                                                (ath_prg_rec.interface_athletic_prg_id) ||
                                                ' Status : ' || '3' ||  ' ErrorCode : ' ||
						l_error_code||' SQLERRM:' ||  SQLERRM;

				    fnd_log.string_with_context( fnd_log.level_exception,
								  l_label,
								  l_debug_str, NULL,
								  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
				  END IF;

				IF l_enable_log = 'Y' THEN
				  igs_ad_imp_001.logerrormessage(ath_prg_rec.interface_athletic_prg_id,l_error_code,'IGS_PE_ATH_PRG_INT');
				END IF;

                                END;

                        ELSIF l_rule = 'R' THEN
                         IF  ath_prg_rec.match_ind = '21' THEN  -- '21' Match reviewed and to be imported
                          BEGIN
                              igs_pe_athletic_prg_pkg.update_row (
                                                       x_rowid              => dup_chk_ath_prg_rec.rowid,
                                                       x_athletic_prg_id    => dup_chk_ath_prg_rec.athletic_prg_id,
                                                       x_person_id          => NVL(ath_prg_rec.person_id,dup_chk_ath_prg_rec.person_id),
                                                       x_athletic_prg_code  => ath_prg_rec.athletic_prg_code,
                                                       x_rating             => NVL(ath_prg_rec.rating,dup_chk_ath_prg_rec.rating),
                                                       x_start_date         => ath_prg_rec.start_date,
                                                       x_end_date           => NVL(ath_prg_rec.end_date,dup_chk_ath_prg_rec.end_date),
                                                       x_recruited_ind      => ath_prg_rec.recruited_ind,
                                                       x_participating_ind  => ath_prg_rec.participating_ind,
                                                       x_last_update_dt     => nvl(ath_prg_rec.last_update_date,dup_chk_ath_prg_rec.last_update_dt),
                                                       x_mode               => 'R'
                                                         );
                                l_error_code := NULL;
                                l_status := '1';

                                UPDATE  igs_pe_ath_prg_int
                                SET     status = l_status,
                                        error_code = l_error_code,
                                        match_ind = cst_mi_val_18
                                WHERE   interface_athletic_prg_id = ath_prg_rec.interface_athletic_prg_id;

                                EXCEPTION
                                  WHEN OTHERS THEN
                                        l_error_code := 'E100'; -- Could not update Person Athletics Program Details
                                        l_status := '3';

                                  UPDATE        igs_pe_ath_prg_int
                                  SET           status = l_status,
                                                error_code = l_error_code
                                  WHERE         interface_athletic_prg_id = ath_prg_rec.interface_athletic_prg_id;

                                        -- Call Log detail
				  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

				    IF (l_request_id IS NULL) THEN
				      l_request_id := fnd_global.conc_request_id;
				    END IF;

				    l_label := 'igs.plsql.igs_ad_imp_003.prc_apcnt_ath_prg.exception2 '||l_error_code;

				      l_debug_str :=  'igs_ad_imp_003.prc_apcnt_ath_prg'
                                                ||' Exception from igs_pe_athletic_prg_Pkg.Update_Row '
                                                || ' INTERFACE_ATHLETIC_PRG_ID : ' ||
                                                (ath_prg_rec.interface_athletic_prg_id) ||
                                                ' Status : ' || '3' ||  ' ErrorCode : ' ||
						l_error_code||' SQLERRM:' ||  SQLERRM;

				    fnd_log.string_with_context( fnd_log.level_exception,
								  l_label,
								  l_debug_str, NULL,
								  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
				  END IF;

				IF l_enable_log = 'Y' THEN
				  igs_ad_imp_001.logerrormessage(ath_prg_rec.interface_athletic_prg_id,l_error_code,'IGS_PE_ATH_PRG_INT');
				END IF;

                                END;

                            END IF;  -- ath_prg_rec.MATCH_IND check

                        END IF;--  l_rule  check for 'I','R' or 'E'.

                ELSE    -- If its not a duplicate record then Create a new record in OSS
                        crt_apcnt_ath_prg (p_ath_prg_rec => ath_prg_rec);
                END IF; -- Record existance in IGS_PE_ATHLETIC_PRG check
         END IF; -- Check for Validate Record

         IF l_processed_records = 100 THEN
            COMMIT;
            l_processed_records := 0;
         END IF;

        END LOOP;
END prc_apcnt_ath_prg;

PROCEDURE prc_apcnt_ath
(
           p_source_type_id     IN      NUMBER,
           p_batch_id   IN      NUMBER )

AS
  /*
    ||  Created By : pkpatel
    ||  Created On : 11-NOV-2001
    ||  Purpose : This procedure process the Athletic Details of a Person
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    || samaresh      24-JAN-2002      The table Igs_ad_appl_int has been obsoleted
    ||                                 new table igs_ad_apl_int has been created
    ||                                 as a part of build ADI - Import Prc Changes
    ||                                 bug# 2191058
    ||  pkpatel       11-NOV-2001      Bug no.2103692 :For Person Interface DLD
    ||                                 Created new Procedure to process the Athletic Information of the person
    ||                                 This is the driving procedure in which both the procedures for processing
    ||                                 Athletic Details and Athletic Programs are called.
    ||  (reverse chronological order - newest change first)
  */
BEGIN
           prc_apcnt_ath_dtls(p_source_type_id, p_batch_id);
           prc_apcnt_ath_prg (p_source_type_id, p_batch_id);
END  prc_apcnt_ath;

END IGS_AD_IMP_012;

/
