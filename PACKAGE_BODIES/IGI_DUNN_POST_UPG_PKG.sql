--------------------------------------------------------
--  DDL for Package Body IGI_DUNN_POST_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_DUNN_POST_UPG_PKG" as
/* $Header: igidunkb.pls 120.11 2008/02/19 09:27:27 mbremkum ship $ */

G_PKG_NAME                      CONSTANT VARCHAR2(30) := 'IGI_DUNN_POST_UPG_PKG';
g_debug_level                   NUMBER :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_state_level                   NUMBER :=  FND_LOG.LEVEL_STATEMENT;
g_proc_level                    NUMBER :=  FND_LOG.LEVEL_PROCEDURE;
g_event_level                   NUMBER :=  FND_LOG.LEVEL_EVENT;
g_excep_level                   NUMBER :=  FND_LOG.LEVEL_EXCEPTION;
g_error_level                   NUMBER :=  FND_LOG.LEVEL_ERROR;
g_unexp_level                   NUMBER :=  FND_LOG.LEVEL_UNEXPECTED;
g_path                          VARCHAR2(255) := 'IGI.PLSQL.IGIDUNKB.IGI_DUNN_POST_UPG_PKG.';
g_debug_mode                    VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE Put_Debug_Msg (
   p_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
);

PROCEDURE DUNNING_UPG(ERRBUF OUT NOCOPY  VARCHAR2,
		      RETCODE OUT NOCOPY VARCHAR2) IS

l_old_dls_id 	NUMBER;
l_dls_id 	NUMBER;
l_name 		ar_dunning_letter_sets.name%TYPE;
l_old_ccy_code  igi_dun_letter_set_cur.currency_code%TYPE;
l_ccy_code	igi_dun_letter_set_cur.currency_code%TYPE;
l_old_customer_profile_id NUMBER;
l_aging_bct_id  ar_aging_buckets.aging_bucket_id%TYPE;
l_not_exists	BOOLEAN;
l_length	NUMBER;

l_full_path VARCHAR2(255);

BEGIN

l_full_path := g_path || 'DUNNING_UPG';

FOR r_bkts IN c_bkts LOOP

         SELECT ar_aging_buckets_s.NEXTVAL INTO l_aging_bct_id
         FROM dual;

	 l_length := length(to_char(l_aging_bct_id));

         INSERT INTO ar_aging_buckets
               (
               aging_bucket_id,
               bucket_name,
               status,
               aging_type,
               description,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login
               )
         VALUES(
               l_aging_bct_id,                        		  -- aging_bucket_id
               /*Changed the Bucket Name to Dunning Letter Set name - mbremkum*/
               (substr(r_bkts.name,0,(20-l_length)) || l_aging_bct_id),-- bucket_name
               'A',                                               -- status
               'INTTIER',                                         -- aging_type
               r_bkts.name,					  -- description
               -1,                                                -- created_by
               SYSDATE,                                           -- creation_date
               -1,                                                -- last_updated_by
               SYSDATE,                                           -- last_update_date
               -1                                                 -- last_update_login
               )
        RETURNING aging_bucket_id INTO l_aging_bucket_id;

        FOR r_bkts_lines IN c_bkts_lines(r_bkts.dls_id) LOOP

             INSERT INTO ar_aging_bucket_lines_b
                   (
                   aging_bucket_line_id,
                   aging_bucket_id,
                   bucket_sequence_num,
                   days_start,
                   days_to,
                   type,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login
                   )
             VALUES(
                   ar_aging_bucket_lines_s.NEXTVAL,
                   l_aging_bucket_id,
                   r_bkts_lines.dunning_line_num,
                   r_bkts_lines.range_of_days_from,
                   r_bkts_lines.range_of_days_to,
                   'CURRENT',
                   -1,
                   SYSDATE,
                   -1,
                   SYSDATE,
                   -1
                   );

        END LOOP;

END LOOP;

FOR r_aging_bkts IN c_aging_bkts LOOP

    BEGIN

         INSERT INTO ar_charge_schedules
               (
               schedule_id,
               schedule_name,
               schedule_description,
               object_version_number,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login
               )
         VALUES(
               ar_charge_schedules_s.NEXTVAL,				-- schedule_id
               r_aging_bkts.name || '_' || r_aging_bkts.ccy_code,	-- schedule_name
               r_aging_bkts.name || '_' || r_aging_bkts.ccy_code,	-- schedule_description
               1,							-- object_version_number
               -1,							-- created_by
               SYSDATE,							-- creation_date
               -1,							-- last_updated_by
               SYSDATE,							-- last_update_date
               -1							-- last_update_login
               )
         RETURNING schedule_id INTO l_schedule_id;

         IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg(l_full_path, 'Dunning Letter Set Name: ' || r_aging_bkts.name);
                Put_Debug_Msg(l_full_path, 'Currency Code: ' || r_aging_bkts.ccy_code);
                Put_Debug_Msg(l_full_path, 'Dunning Letter Set ID: ' || r_aging_bkts.dls_id);
                Put_Debug_Msg(l_full_path, 'Schedule ID: ' || l_schedule_id);
         END IF;
         --dbms_output.put_line('Inserted Rows in ar_charge_schedules : '|| SQL%ROWCOUNT);


         UPDATE hz_cust_profile_amts hcpa
         SET    (interest_type, /*interest_fixed_amount,*/ interest_schedule_id,
                 last_updated_by, last_update_date) =
                (SELECT distinct DECODE(idls.charge_per_invoice_flag, 'Y', 'CHARGES_SCHEDULE', 'N', 'CHARGE_PER_TIER'),
                        /*interest_fixed_amount column is used if interest_type is 'FIXED_AMOUNT' - mbremkum*/
                        /*DECODE(idls.charge_per_invoice_flag, 'Y', idclsl.invoice_charge_amount, NULL),*/
                        /*Schedule ID is always populated if interest_type is
                        'CHARGES_SCHEDULE' or 'CHARGE_PER_TIER' - mbremkum*/
                        l_schedule_id,
                        -1, SYSDATE
                 FROM   igi_dun_letter_sets  idls,
                        igi_dun_cust_letter_set_lines idclsl
                /*Added the below condition so that update is based on
                dunning_letter_set_id from the cursor - mbremkum*/
                 WHERE  idls.dunning_letter_set_id = r_aging_bkts.dls_id
                 AND    idls.dunning_letter_set_id = idclsl.dunning_letter_set_id
                 AND    idclsl.customer_profile_id = hcpa.cust_account_profile_id
                 AND    idclsl.currency_code       = hcpa.currency_code
		 AND    hcpa.currency_code	   = r_aging_bkts.ccy_code
                 AND    NVL(idclsl.site_use_id,-99)= NVL(hcpa.site_use_id, -99))
         WHERE EXISTS (SELECT 'Y'
                       FROM   igi_dun_letter_sets  idls,
                              igi_dun_cust_letter_set_lines idclsl
                       WHERE  idls.dunning_letter_set_id = r_aging_bkts.dls_id
		       AND    idls.dunning_letter_set_id = idclsl.dunning_letter_set_id
                       AND    idclsl.customer_profile_id = hcpa.cust_account_profile_id
                       AND    idclsl.currency_code       = hcpa.currency_code
		       AND    hcpa.currency_code	 = r_aging_bkts.ccy_code
                       AND    NVL(idclsl.site_use_id,-99)= NVL(hcpa.site_use_id, -99));

        /*Added the below query to update schedule_id and interest_type in Customer Profile Class Amount*/

         UPDATE hz_cust_prof_class_amts hcpca
         SET    (interest_type, interest_schedule_id,
                 last_updated_by, last_update_date) =
                (SELECT distinct DECODE(idls.charge_per_invoice_flag, 'Y', 'CHARGES_SCHEDULE', 'N', 'CHARGE_PER_TIER'),
                        l_schedule_id,
                        -1, SYSDATE
                 FROM   igi_dun_letter_sets  idls,
                        igi_dun_cust_letter_set_lines idclsl
                 WHERE  idls.dunning_letter_set_id = r_aging_bkts.dls_id
                 AND    idls.dunning_letter_set_id = idclsl.dunning_letter_set_id
                 AND    idclsl.customer_profile_class_id = hcpca.profile_class_id
                 AND    idclsl.currency_code       = hcpca.currency_code
		 AND    hcpca.currency_code	   = r_aging_bkts.ccy_code)
         WHERE EXISTS (SELECT 'Y'
                       FROM   igi_dun_letter_sets  idls,
                              igi_dun_cust_letter_set_lines idclsl
                       WHERE  idls.dunning_letter_set_id = r_aging_bkts.dls_id
                       AND    idls.dunning_letter_set_id = idclsl.dunning_letter_set_id
                       AND    idclsl.customer_profile_class_id = hcpca.profile_class_id
                       AND    idclsl.currency_code       = hcpca.currency_code
		       AND    hcpca.currency_code	 = r_aging_bkts.ccy_code);

         --dbms_output.put_line('Updated Rows in hz_cust_profile_amts : '|| SQL%ROWCOUNT);

	 SELECT aging_bucket_id INTO l_aging_bucket_id
	 FROM ar_aging_buckets
	 WHERE description = r_aging_bkts.name;

         IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg(l_full_path, 'Aging bucket ID: ' || l_aging_bucket_id);
         END IF;

         --dbms_output.put_line('Inserted Rows in ar_aging_buckets : '|| SQL%ROWCOUNT);

         INSERT INTO ar_charge_schedule_hdrs
               (
               schedule_header_id,
               schedule_id,
               schedule_header_type,
               aging_bucket_id,
               start_date,
               end_date,
               status,
               object_version_number,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login
               )
         VALUES(
               ar_charge_schedule_hdrs_s.NEXTVAL,
               l_schedule_id,
               'AMOUNT',
               l_aging_bucket_id,
               to_date('01-01-1900', 'DD-MM-YYYY'),
               null,
               'A',
               1,
               -1,
               SYSDATE,
               -1,
               SYSDATE,
               -1
               )
         RETURNING schedule_header_id INTO l_schedule_header_id;

         IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg(l_full_path, 'Charge Schedule Header ID: ' || l_schedule_header_id);
         END IF;

         --dbms_output.put_line('Inserted Rows in ar_charge_schedule_hdrs : '|| SQL%ROWCOUNT);

         FOR r_aging_bkt_lines IN c_aging_bkt_lines(r_aging_bkts.dls_id, r_aging_bkts.ccy_code) LOOP

	      SELECT aging_bucket_line_id INTO l_aging_bucket_line_id
	      FROM ar_aging_bucket_lines_b
	      WHERE aging_bucket_id = l_aging_bucket_id
		    AND bucket_sequence_num = r_aging_bkt_lines.dunning_line_num
		    AND days_start = r_aging_bkt_lines.range_of_days_from
		    AND days_to = r_aging_bkt_lines.range_of_days_to;

             IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg(l_full_path, 'Aging Bucket Line ID: ' || l_aging_bucket_line_id);
             END IF;


             --dbms_output.put_line('Inserted Rows in ar_aging_bucket_lines_b : '|| SQL%ROWCOUNT);

             INSERT INTO ar_charge_schedule_lines
                   (
                   schedule_line_id,
                   schedule_header_id,
                   schedule_id,
                   aging_bucket_id,
                   aging_bucket_line_id,
                   amount,
                   rate,
                   object_version_number,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login
                   )
             VALUES(
                   ar_charge_schedule_lines_s.NEXTVAL,
                   l_schedule_header_id,
                   l_schedule_id,
                   l_aging_bucket_id,
                   l_aging_bucket_line_id,
                   decode(r_aging_bkt_lines.charge_type, 'Y',
                            r_aging_bkt_lines.invoice_charge_amount,
                            'N', r_aging_bkt_lines.letter_charge_amount),
                   NULL,
                   1,
                   -1,
                   SYSDATE,
                   -1,
                   SYSDATE,
                   -1
                   );

             IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg(l_full_path, 'Inserted Rows in ar_charge_schedule_lines : '|| SQL%ROWCOUNT);
             END IF;

             --dbms_output.put_line('Inserted Rows in ar_charge_schedule_lines : '|| SQL%ROWCOUNT);

         END LOOP;

    EXCEPTION

          WHEN OTHERS THEN
                IF (g_debug_mode = 'Y') THEN
                        Put_Debug_Msg(l_full_path, SQLERRM);
                END IF;
                ROLLBACK;
                APP_EXCEPTION.Raise_Exception;
    END;
END LOOP;

/*Create new charge schedules when amounts are updated at customer level - Start - mbremkum*/

IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg(l_full_path, 'Create new schedules and override existing if amounts updated at customer level');
END IF;

FOR r_aging_bkts_site IN c_aging_bkts_site LOOP

	FOR r_override_dunning_letter IN c_override_dunning_letter(r_aging_bkts_site.dls_id, r_aging_bkts_site.ccy_code, r_aging_bkts_site.charge_type) LOOP

		l_old_dls_id := -9999;
		l_old_ccy_code := 'XXX';
		l_old_customer_profile_id := -9999;

		FOR r_aging_bkt_lines_site IN c_aging_bkt_lines_site(r_override_dunning_letter.dls_id, r_override_dunning_letter.ccy_code,r_override_dunning_letter.customer_profile_id ) LOOP

		l_not_exists := TRUE;

		BEGIN

		   IF (l_old_dls_id <> r_aging_bkt_lines_site.dunning_letter_set_id OR l_old_ccy_code <> r_aging_bkt_lines_site.ccy_code OR l_old_customer_profile_id <> r_aging_bkt_lines_site.customer_profile_id) THEN

			BEGIN

				SELECT distinct adls.dunning_letter_set_id,
					adls.name,
					idlsc.currency_code INTO l_dls_id, l_name, l_ccy_code
				FROM   igi_dun_letter_set_cur      idlsc,
				       ar_dunning_letter_sets      adls,
				       igi_dun_letter_sets         idls
				WHERE  adls.dunning_letter_set_id = r_aging_bkt_lines_site.dunning_letter_set_id
				AND    idlsc.dunning_letter_set_id = r_aging_bkt_lines_site.dunning_letter_set_id
				AND    idls.dunning_letter_set_id  = r_aging_bkt_lines_site.dunning_letter_set_id
				AND    idlsc.currency_code = r_aging_bkt_lines_site.ccy_code
				AND    idls.use_dunning_flag       = 'Y'
				AND NOT EXISTS (SELECT 'Y'
						FROM    ar_charge_schedules acs
						WHERE   acs.schedule_name = adls.name || '_' || idlsc.currency_code || '_' || r_aging_bkt_lines_site.customer_profile_id);
			EXCEPTION

			   WHEN NO_DATA_FOUND THEN
				l_not_exists := FALSE;

			END;

		   END IF;

		   IF ( (l_old_dls_id <> r_aging_bkt_lines_site.dunning_letter_set_id OR l_old_ccy_code <> r_aging_bkt_lines_site.ccy_code OR l_old_customer_profile_id <> r_aging_bkt_lines_site.customer_profile_id) AND l_not_exists) THEN
		      /*Create charge schedule for each unique Dunning Letter Set ID*/

			l_old_dls_id := r_aging_bkt_lines_site.dunning_letter_set_id;
			l_old_ccy_code := r_aging_bkt_lines_site.ccy_code;
			l_old_customer_profile_id := r_aging_bkt_lines_site.customer_profile_id;

			/*Check if a Charge Scedule already exists by that name. Also Fetch the Dunning Letter Name and Currency*/
			IF (g_debug_mode = 'Y') THEN
			       Put_Debug_Msg(l_full_path, 'Creating new Charge Schedule for Dunning Letter Set ID: ' || r_aging_bkt_lines_site.dunning_letter_set_id || ' and Currency: ' ||r_aging_bkt_lines_site.ccy_code );
			END IF;

			INSERT INTO ar_charge_schedules
			       (
			       schedule_id,
			       schedule_name,
			       schedule_description,
			       object_version_number,
			       created_by,
			       creation_date,
			       last_updated_by,
			       last_update_date,
			       last_update_login
			       )
			       VALUES(
			       ar_charge_schedules_s.NEXTVAL,							-- schedule_id
			       l_name || '_' || l_ccy_code || '_' || r_aging_bkt_lines_site.customer_profile_id,	-- schedule_name
			       l_name || '_' || l_ccy_code || '_' || r_aging_bkt_lines_site.customer_profile_id,	-- schedule_description
			       1,										-- object_version_number
			       -1,										-- created_by
			       SYSDATE,										-- creation_date
			       -1,										-- last_updated_by
			       SYSDATE,										-- last_update_date
			       -1										-- last_update_login
			       )
			       RETURNING schedule_id INTO l_schedule_id;

			IF (g_debug_mode = 'Y') THEN
			       Put_Debug_Msg(l_full_path, 'Dunning Letter Set Name(Site Override): ' || l_name);
			       Put_Debug_Msg(l_full_path, 'Currency Code(Site Override): ' || l_ccy_code);
			       Put_Debug_Msg(l_full_path, 'Dunning Letter Set ID(Site Override): ' || l_dls_id);
			       Put_Debug_Msg(l_full_path, 'Customer Profile ID(Site Override): ' || r_aging_bkt_lines_site.customer_profile_id);
			       Put_Debug_Msg(l_full_path, 'Schedule ID(Site Override): ' || l_schedule_id);
			END IF;

			UPDATE hz_cust_profile_amts hcpa
			SET    (interest_type, interest_schedule_id,
				last_updated_by, last_update_date) =
			       (SELECT distinct DECODE(idls.charge_per_invoice_flag, 'Y', 'CHARGES_SCHEDULE', 'N', 'CHARGE_PER_TIER'),
				       l_schedule_id,-1, SYSDATE
				       FROM   igi_dun_letter_sets  idls,
					      igi_dun_cust_letter_set_lines idclsl
				       WHERE  idls.dunning_letter_set_id = l_dls_id
				       AND    idls.dunning_letter_set_id = idclsl.dunning_letter_set_id
				       AND    hcpa.cust_account_profile_id = r_aging_bkt_lines_site.customer_profile_id
				       AND    hcpa.currency_code = r_aging_bkt_lines_site.ccy_code
				       AND    NVL(hcpa.site_use_id, -99) = NVL(r_aging_bkt_lines_site.site_use_id, -99))
				 WHERE EXISTS (SELECT 'Y'
					       FROM   igi_dun_letter_sets  idls,
						      igi_dun_cust_letter_set_lines idclsl
					       WHERE  idls.dunning_letter_set_id = l_dls_id
					       AND    idls.dunning_letter_set_id = idclsl.dunning_letter_set_id
					       AND    hcpa.cust_account_profile_id = r_aging_bkt_lines_site.customer_profile_id
					       AND    hcpa.currency_code = r_aging_bkt_lines_site.ccy_code
					       AND    NVL(hcpa.site_use_id, -99) = NVL(r_aging_bkt_lines_site.site_use_id, -99));

			SELECT aging_bucket_id INTO l_aging_bucket_id FROM ar_aging_buckets
			WHERE description = r_aging_bkt_lines_site.name;

			INSERT INTO ar_charge_schedule_hdrs
				   (
				   schedule_header_id,
				   schedule_id,
				   schedule_header_type,
				   aging_bucket_id,
				   start_date,
				   end_date,
				   status,
				   object_version_number,
				   created_by,
				   creation_date,
				   last_updated_by,
				   last_update_date,
				   last_update_login
				   )
				VALUES(
				   ar_charge_schedule_hdrs_s.NEXTVAL,
				   l_schedule_id,
				   'AMOUNT',
				   l_aging_bucket_id,
				   to_date('01-01-1900', 'DD-MM-YYYY'),
				   null,
				   'A',
				   1,
				   -1,
				   SYSDATE,
				   -1,
				   SYSDATE,
				   -1
				   )
				 RETURNING schedule_header_id INTO l_schedule_header_id;

				IF (g_debug_mode = 'Y') THEN
					Put_Debug_Msg(l_full_path, 'Charge Schedule Header ID(Site Override): ' || l_schedule_header_id);
				END IF;

		   END IF;

		   IF l_not_exists THEN

			   IF (g_debug_mode = 'Y') THEN
				Put_Debug_Msg(l_full_path, 'Dunning Line Number(Site Override): ' || r_aging_bkt_lines_site.dunning_line_num);
				Put_Debug_Msg(l_full_path, 'Range of days from(Site Override): ' || r_aging_bkt_lines_site.range_of_days_from);
				Put_Debug_Msg(l_full_path, 'Range of days to(Site Override): ' || r_aging_bkt_lines_site.range_of_days_to);
			   END IF;

		      SELECT aging_bucket_line_id INTO l_aging_bucket_line_id
		      FROM ar_aging_bucket_lines_b
		      WHERE aging_bucket_id = l_aging_bucket_id
			    AND bucket_sequence_num = r_aging_bkt_lines_site.dunning_line_num
			    AND days_start = r_aging_bkt_lines_site.range_of_days_from
			    AND days_to = r_aging_bkt_lines_site.range_of_days_to;

		      IF (g_debug_mode = 'Y') THEN
			Put_Debug_Msg(l_full_path, 'Aging Bucket Line ID(Site Override): ' || l_aging_bucket_line_id);
		      END IF;

		      INSERT INTO ar_charge_schedule_lines
			    (
			     schedule_line_id,
			     schedule_header_id,
			     schedule_id,
			     aging_bucket_id,
			     aging_bucket_line_id,
			     amount,
			     rate,
			     object_version_number,
			     created_by,
			     creation_date,
			     last_updated_by,
			     last_update_date,
			     last_update_login
			    )
		       VALUES(
			     ar_charge_schedule_lines_s.NEXTVAL,
			     l_schedule_header_id,
			     l_schedule_id,
			     l_aging_bucket_id,
			     l_aging_bucket_line_id,
			     decode(r_aging_bkt_lines_site.charge_type, 'Y', r_aging_bkt_lines_site.invoice_charge_amount,
				      'N', r_aging_bkt_lines_site.letter_charge_amount),
			     NULL,
			     1,
			     -1,
			     SYSDATE,
			     -1,
			     SYSDATE,
			     -1
			     );
		      IF (g_debug_mode = 'Y') THEN
			     Put_Debug_Msg(l_full_path, 'Inserted Rows in ar_charge_schedule_lines(Site Override): '|| SQL%ROWCOUNT);
		      END IF;

		   END IF;

		   EXCEPTION

			  WHEN OTHERS THEN
				  IF (g_debug_mode = 'Y') THEN
				    Put_Debug_Msg(l_full_path, SQLERRM);
				  END IF;
				  ROLLBACK;
				  APP_EXCEPTION.Raise_Exception;
		   END;

		END LOOP;

	END LOOP;

END LOOP;

FOR r_aging_bkts_uu IN c_aging_bkts_uu LOOP

        BEGIN

                INSERT INTO ar_charge_schedules
                (
                schedule_id,
                schedule_name,
                schedule_description,
                object_version_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
                )
                VALUES(
                ar_charge_schedules_s.NEXTVAL,
                r_aging_bkts_uu.name || '_' || r_aging_bkts_uu.ccy_code || '_'
                || decode(r_aging_bkts_uu.charge_type, 'Y', 'PER_LETTER', 'N', 'PER_INVOICE'),
                r_aging_bkts_uu.name || '_' || r_aging_bkts_uu.ccy_code|| '_'
                || decode(r_aging_bkts_uu.charge_type, 'Y', 'PER_LETTER', 'N', 'PER_INVOICE'),
                1,
                -1,
                SYSDATE,
                -1,
                SYSDATE,
                -1
                )
                RETURNING schedule_id INTO l_schedule_id;

                IF (g_debug_mode = 'Y') THEN
                        Put_Debug_Msg(l_full_path, 'Dunning Letter Set Name (Un Used): ' || r_aging_bkts_uu.name);
                        Put_Debug_Msg(l_full_path, 'Currency Code (Un Used): ' || r_aging_bkts_uu.ccy_code);
                        Put_Debug_Msg(l_full_path, 'Dunning Letter Set ID (Un Used): ' || r_aging_bkts_uu.dls_id);
                        Put_Debug_Msg(l_full_path, 'Schedule ID (Un Used): ' || l_schedule_id);
                END IF;

                SELECT aging_bucket_id INTO l_aging_bucket_id
                FROM ar_aging_buckets
                WHERE description = r_aging_bkts_uu.name;

                INSERT INTO ar_charge_schedule_hdrs
                (
                schedule_header_id,
                schedule_id,
                schedule_header_type,
                aging_bucket_id,
                start_date,
                end_date,
                status,
                object_version_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
                )
                VALUES(
                ar_charge_schedule_hdrs_s.NEXTVAL,
                l_schedule_id,
                'AMOUNT',
                l_aging_bucket_id,
                to_date('01-01-1900', 'DD-MM-YYYY'),
                null,
                'A',
                1,
                -1,
                SYSDATE,
                -1,
                SYSDATE,
                -1
                )
                RETURNING schedule_header_id INTO l_schedule_header_id;

                FOR r_aging_bkt_lines IN c_aging_bkt_lines(r_aging_bkts_uu.dls_id, r_aging_bkts_uu.ccy_code) LOOP

                        SELECT aging_bucket_line_id INTO l_aging_bucket_line_id
                        FROM ar_aging_bucket_lines_b
                        WHERE aging_bucket_id = l_aging_bucket_id
                        AND bucket_sequence_num = r_aging_bkt_lines.dunning_line_num
                        AND days_start = r_aging_bkt_lines.range_of_days_from
                        AND days_to = r_aging_bkt_lines.range_of_days_to;

                        IF (g_debug_mode = 'Y') THEN
                                Put_Debug_Msg(l_full_path, 'Aging Bucket Line ID (Un Used): ' || l_aging_bucket_line_id);
                        END IF;

                        INSERT INTO ar_charge_schedule_lines
                        (
                        schedule_line_id,
                        schedule_header_id,
                        schedule_id,
                        aging_bucket_id,
                        aging_bucket_line_id,
                        amount,
                        rate,
                        object_version_number,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login
                        )
                        VALUES(
                        ar_charge_schedule_lines_s.NEXTVAL,
                        l_schedule_header_id,
                        l_schedule_id,
                        l_aging_bucket_id,
                        l_aging_bucket_line_id,
                        decode(r_aging_bkt_lines.charge_type, 'Y',
                            r_aging_bkt_lines.letter_charge_amount,
                            'N', r_aging_bkt_lines.invoice_charge_amount),
                        NULL,
                        1,
                        -1,
                        SYSDATE,
                        -1,
                        SYSDATE,
                        -1
                        );

                        IF (g_debug_mode = 'Y') THEN
                                Put_Debug_Msg(l_full_path, 'Inserted Rows in ar_charge_schedule_lines (Un Used): '|| SQL%ROWCOUNT);
                        END IF;

                END LOOP;       /*FOR r_aging_bkt_lines IN c_aging_bkt_lines*/

        EXCEPTION

                WHEN OTHERS THEN
                        IF (g_debug_mode = 'Y') THEN
                                Put_Debug_Msg(l_full_path, SQLERRM);
                        END IF;
                        ROLLBACK;
                        APP_EXCEPTION.Raise_Exception;
        END;

END LOOP;       /*FOR r_aging_bkts_uu IN c_aging_bkts_uu LOOP*/

FOR r_aging_bkts_uu_site IN c_aging_bkts_uu_site LOOP

	FOR r_override_dunning_letter_uu IN c_override_dunning_letter_uu(r_aging_bkts_uu_site.dls_id, r_aging_bkts_uu_site.ccy_code, r_aging_bkts_uu_site.charge_type) LOOP

		l_old_dls_id := -9999;
		l_old_ccy_code := 'XXX';
		l_old_customer_profile_id := -9999;

		FOR r_aging_bkt_lines_site IN c_aging_bkt_lines_site(r_override_dunning_letter_uu.dls_id, r_override_dunning_letter_uu.ccy_code,r_override_dunning_letter_uu.customer_profile_id ) LOOP

		l_not_exists := TRUE;

		BEGIN

		   IF (l_old_dls_id <> r_aging_bkt_lines_site.dunning_letter_set_id OR l_old_ccy_code <> r_aging_bkt_lines_site.ccy_code OR l_old_customer_profile_id <> r_aging_bkt_lines_site.customer_profile_id) THEN

			BEGIN

				SELECT distinct adls.dunning_letter_set_id,
					adls.name,
					idlsc.currency_code INTO l_dls_id, l_name, l_ccy_code
				FROM   igi_dun_letter_set_cur      idlsc,
				       ar_dunning_letter_sets      adls,
				       igi_dun_letter_sets         idls
				WHERE  adls.dunning_letter_set_id = r_aging_bkt_lines_site.dunning_letter_set_id
				AND    idlsc.dunning_letter_set_id = r_aging_bkt_lines_site.dunning_letter_set_id
				AND    idls.dunning_letter_set_id  = r_aging_bkt_lines_site.dunning_letter_set_id
				AND    idlsc.currency_code = r_aging_bkt_lines_site.ccy_code
				AND    idls.use_dunning_flag       = 'Y'
				AND NOT EXISTS (SELECT 'Y'
						FROM    ar_charge_schedules acs
						WHERE   acs.schedule_name = adls.name || '_' || idlsc.currency_code || '_' || r_aging_bkt_lines_site.customer_profile_id || '_'
                || decode(r_aging_bkt_lines_site.charge_type, 'Y', 'PER_LETTER', 'N', 'PER_INVOICE'));
			EXCEPTION

			   WHEN NO_DATA_FOUND THEN
				l_not_exists := FALSE;

			END;

		   END IF;

		   IF ( (l_old_dls_id <> r_aging_bkt_lines_site.dunning_letter_set_id OR l_old_ccy_code <> r_aging_bkt_lines_site.ccy_code OR l_old_customer_profile_id <> r_aging_bkt_lines_site.customer_profile_id) AND l_not_exists) THEN
		      /*Create charge schedule for each unique Dunning Letter Set ID*/

			l_old_dls_id := r_aging_bkt_lines_site.dunning_letter_set_id;
			l_old_ccy_code := r_aging_bkt_lines_site.ccy_code;
			l_old_customer_profile_id := r_aging_bkt_lines_site.customer_profile_id;

			/*Check if a Charge Scedule already exists by that name. Also Fetch the Dunning Letter Name and Currency*/
			IF (g_debug_mode = 'Y') THEN
			       Put_Debug_Msg(l_full_path, 'Creating new Charge Schedule for Dunning Letter Set ID (Site Override - Un Used): ' || r_aging_bkt_lines_site.dunning_letter_set_id || ' and Currency: ' ||r_aging_bkt_lines_site.ccy_code );
			END IF;

			INSERT INTO ar_charge_schedules
			       (
			       schedule_id,
			       schedule_name,
			       schedule_description,
			       object_version_number,
			       created_by,
			       creation_date,
			       last_updated_by,
			       last_update_date,
			       last_update_login
			       )
			       VALUES(
			       ar_charge_schedules_s.NEXTVAL,							-- schedule_id
			       l_name || '_' || l_ccy_code || '_' || r_aging_bkt_lines_site.customer_profile_id || '_'
                || decode(r_aging_bkt_lines_site.charge_type, 'Y', 'PER_LETTER', 'N', 'PER_INVOICE'),	-- schedule_name
			       l_name || '_' || l_ccy_code || '_' || r_aging_bkt_lines_site.customer_profile_id || '_'
                || decode(r_aging_bkt_lines_site.charge_type, 'Y', 'PER_LETTER', 'N', 'PER_INVOICE'),	-- schedule_description
			       1,										-- object_version_number
			       -1,										-- created_by
			       SYSDATE,										-- creation_date
			       -1,										-- last_updated_by
			       SYSDATE,										-- last_update_date
			       -1										-- last_update_login
			       )
			       RETURNING schedule_id INTO l_schedule_id;

			IF (g_debug_mode = 'Y') THEN
			       Put_Debug_Msg(l_full_path, 'Dunning Letter Set Name(Site Override - Un Used): ' || l_name);
			       Put_Debug_Msg(l_full_path, 'Currency Code(Site Override - Un Used): ' || l_ccy_code);
			       Put_Debug_Msg(l_full_path, 'Dunning Letter Set ID(Site Override - Un Used): ' || l_dls_id);
			       Put_Debug_Msg(l_full_path, 'Customer Profile ID(Site Override - Un Used): ' || r_aging_bkt_lines_site.customer_profile_id);
			       Put_Debug_Msg(l_full_path, 'Schedule ID(Site Override - Un Used): ' || l_schedule_id);
			END IF;

			SELECT aging_bucket_id INTO l_aging_bucket_id FROM ar_aging_buckets
			WHERE description = r_aging_bkt_lines_site.name;

			INSERT INTO ar_charge_schedule_hdrs
				   (
				   schedule_header_id,
				   schedule_id,
				   schedule_header_type,
				   aging_bucket_id,
				   start_date,
				   end_date,
				   status,
				   object_version_number,
				   created_by,
				   creation_date,
				   last_updated_by,
				   last_update_date,
				   last_update_login
				   )
				VALUES(
				   ar_charge_schedule_hdrs_s.NEXTVAL,
				   l_schedule_id,
				   'AMOUNT',
				   l_aging_bucket_id,
				   to_date('01-01-1900', 'DD-MM-YYYY'),
				   null,
				   'A',
				   1,
				   -1,
				   SYSDATE,
				   -1,
				   SYSDATE,
				   -1
				   )
				 RETURNING schedule_header_id INTO l_schedule_header_id;

				IF (g_debug_mode = 'Y') THEN
					Put_Debug_Msg(l_full_path, 'Charge Schedule Header ID(Site Override): ' || l_schedule_header_id);
				END IF;

		   END IF;

		   IF l_not_exists THEN

		      IF (g_debug_mode = 'Y') THEN
		      	Put_Debug_Msg(l_full_path, 'Dunning Line Number(Site Override - Un Used): ' || r_aging_bkt_lines_site.dunning_line_num);
			Put_Debug_Msg(l_full_path, 'Range of days from(Site Override - Un Used): ' || r_aging_bkt_lines_site.range_of_days_from);
			Put_Debug_Msg(l_full_path, 'Range of days to(Site Override - Un Used): ' || r_aging_bkt_lines_site.range_of_days_to);
		      END IF;

		      SELECT aging_bucket_line_id INTO l_aging_bucket_line_id
		      FROM ar_aging_bucket_lines_b
		      WHERE aging_bucket_id = l_aging_bucket_id
			    AND bucket_sequence_num = r_aging_bkt_lines_site.dunning_line_num
			    AND days_start = r_aging_bkt_lines_site.range_of_days_from
			    AND days_to = r_aging_bkt_lines_site.range_of_days_to;

		      IF (g_debug_mode = 'Y') THEN
			Put_Debug_Msg(l_full_path, 'Aging Bucket Line ID(Site Override - Un Used): ' || l_aging_bucket_line_id);
		      END IF;

		      INSERT INTO ar_charge_schedule_lines
			    (
			     schedule_line_id,
			     schedule_header_id,
			     schedule_id,
			     aging_bucket_id,
			     aging_bucket_line_id,
			     amount,
			     rate,
			     object_version_number,
			     created_by,
			     creation_date,
			     last_updated_by,
			     last_update_date,
			     last_update_login
			    )
		       VALUES(
			     ar_charge_schedule_lines_s.NEXTVAL,
			     l_schedule_header_id,
			     l_schedule_id,
			     l_aging_bucket_id,
			     l_aging_bucket_line_id,
			     decode(r_aging_bkt_lines_site.charge_type, 'Y', r_aging_bkt_lines_site.letter_charge_amount,
				      'N', r_aging_bkt_lines_site.invoice_charge_amount),
			     NULL,
			     1,
			     -1,
			     SYSDATE,
			     -1,
			     SYSDATE,
			     -1
			     );
		      IF (g_debug_mode = 'Y') THEN
			     Put_Debug_Msg(l_full_path, 'Inserted Rows in ar_charge_schedule_lines(Site Override - Un Used): '|| SQL%ROWCOUNT);
		      END IF;

		   END IF;

		   EXCEPTION

			  WHEN OTHERS THEN
				  IF (g_debug_mode = 'Y') THEN
				    Put_Debug_Msg(l_full_path, SQLERRM);
				  END IF;
				  ROLLBACK;
				  APP_EXCEPTION.Raise_Exception;
		   END;

		END LOOP;

	END LOOP;

END LOOP;

/*End - Create new charge schedules when amounts are updated at customer level - mbremkum*/

-- Update Customer Profiles
UPDATE hz_customer_profiles hcp
SET late_charge_type = (SELECT DECODE(dunning_charge_type, 'A', 'ADJ',
                                                           'I', 'INV', dunning_charge_type)
                        FROM   igi_dun_cust_prof idcp
                        WHERE  idcp.customer_profile_id = hcp.cust_account_profile_id
                        AND    idcp.use_dunning_flag    = 'Y'),
    /*Added the following to update hz_customer_profiles if Dunning Flaf is enabled - mbremkum*/
    dunning_letters = (SELECT idcp.use_dunning_flag
                        FROM   igi_dun_cust_prof idcp
                        WHERE  idcp.customer_profile_id = hcp.cust_account_profile_id
                        AND    idcp.use_dunning_flag    = 'Y')
WHERE EXISTS (SELECT 'Y'
           FROM   igi_dun_cust_prof idcp1
           WHERE  idcp1.customer_profile_id = hcp.cust_account_profile_id
           AND    idcp1.use_dunning_flag    = 'Y');

--dbms_output.put_line('Updated Rows in hz_customer_profiles : '|| SQL%ROWCOUNT);

-- Update Customer Profile Classes
UPDATE hz_cust_profile_classes hcpc
SET late_charge_type = (SELECT DECODE(dunning_charge_type, 'A', 'ADJ',
                                                           'I', 'INV', dunning_charge_type)
                        FROM   igi_dun_cust_prof_class idcpc
                        WHERE  idcpc.customer_profile_class_id = hcpc.profile_class_id
                        AND    idcpc.use_dunning_flag          = 'Y'),
    /*Added the following to update hz_cust_profile_classes if Dunning Flaf is enabled - mbremkum*/
    dunning_letters = (SELECT idcpc.use_dunning_flag
                        FROM   igi_dun_cust_prof_class idcpc
                        WHERE  idcpc.customer_profile_class_id = hcpc.profile_class_id
                        AND    idcpc.use_dunning_flag          = 'Y')
WHERE EXISTS (SELECT 'Y'
           FROM   igi_dun_cust_prof_class idcpc1
           WHERE  idcpc1.customer_profile_class_id = hcpc.profile_class_id
           AND    idcpc1.use_dunning_flag          = 'Y');

COMMIT;

--dbms_output.put_line('Updated Rows in hz_cust_profile_classes : '|| SQL%ROWCOUNT);


EXCEPTION

WHEN OTHERS THEN
        errbuf := SQLERRM;
        retcode := 2;
        IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg(l_full_path, 'Dunning Migration Failed with: ' || errbuf);
        END IF;
END DUNNING_UPG;

PROCEDURE Put_Debug_Msg (
   p_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
) IS
BEGIN
  IF(g_state_level >= g_debug_level) THEN
    FND_LOG.STRING(g_state_level, p_path, p_debug_msg);
  END IF;
  RETURN;
EXCEPTION
  WHEN OTHERS THEN
          NULL;
          RETURN;
END Put_Debug_Msg;

END IGI_DUNN_POST_UPG_PKG;

/
