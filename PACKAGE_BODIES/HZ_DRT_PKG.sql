--------------------------------------------------------
--  DDL for Package Body HZ_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DRT_PKG" AS
/*$Header: ARHZDRTB.pls 120.0.12010000.22 2018/07/16 12:12:43 rgokavar noship $ */

  PROCEDURE TCA_FND_DRC
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) ;
    p_user_id number(20);
    l_count number;
    l_temp varchar2(20);
l_debug_prefix                     VARCHAR2(30) := 'DRT ';
  BEGIN

      l_proc := 'HZ_DRT_PKG.tca_fnd_drc';

   --For FND DRC, parameter person_id is USER_ID
   p_user_id := person_id;

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>' TCA_FND_DRC User Id : '||p_user_id,
                               p_msg_level=>fnd_log.level_procedure);
		END IF;

	  SELECT COUNT(*) into l_count
	FROM fnd_profile_options p,
	  fnd_profile_option_values v
	WHERE p.profile_option_name = 'HZ_DEFAULT_DATA_LIBRARIAN'
	AND p.profile_option_id     = v.profile_option_id
	AND v.profile_option_value  = TO_CHAR(p_user_id)
	AND ROWNUM = 1;

	    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>' Profile count : '||l_count,
                               p_msg_level=>fnd_log.level_procedure);
		END IF;

		if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_user_id
  			  ,entity_type => 'FND'
			  ,status => 'E'
			  ,msgcode => 'HZ_DEFAULT_DATA_LIBRARIAN'
			  ,msgaplid => 222
			  ,result_tbl => result_tbl);
		end if;

/*

  n := process_code.count + 1;

  result_tbl(n).person_id := person_id;
  result_tbl(n).entity_type := 'FND';
  result_tbl(n).status := 'S';
  result_tbl(n).msgcode := 'HZ_DRT_ERR_CODE';
  --FND utility
  hr_utility.set_message(453,'HZ_DRT_ERR_CODE');

  result_tbl(n).msgtext := hr_utility.get_message();

*/
  EXCEPTION
          WHEN OTHERS THEN

				IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
				hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Exception in TCA_FND_DRC, Error : '||SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200),
									   p_msg_level=>fnd_log.level_procedure);
				END IF;
          RAISE;

  END tca_fnd_drc;


  -- Procedure for syncing WF_LOCAL_ROLES information with party information.
  PROCEDURE jtf_resource_wf_sync
   (p_party_id   IN number)  IS
   l_party_name VARCHAR2(360);
l_debug_prefix                     VARCHAR2(30) := 'DRT ';
BEGIN

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'jtf_resource_wf_sync (+)',
                               p_msg_level=>fnd_log.level_procedure);
		END IF;

		SELECT PARTY_NAME INTO l_party_name
		FROM HZ_PARTIES WHERE PARTY_ID = p_party_id;

		UPDATE WF_LOCAL_ROLES
		SET DISPLAY_NAME = l_party_name
		,NAME = 'HZ_PARTY:'||ORIG_SYSTEM_ID
        ,DESCRIPTION = NULL
		,EMAIL_ADDRESS = NULL
        ,FAX = NULL,
        EXPIRATION_DATE = CASE WHEN NVL(EXPIRATION_DATE,SYSDATE) >= SYSDATE THEN SYSDATE -1 ELSE EXPIRATION_DATE END
        WHERE ORIG_SYSTEM = 'HZ_PARTY'
        AND ORIG_SYSTEM_ID = p_party_id;

		UPDATE WF_LOCAL_ROLES_TL
		SET DISPLAY_NAME = l_party_name
		,NAME = 'HZ_PARTY:'||ORIG_SYSTEM_ID
        ,DESCRIPTION = NULL
        WHERE ORIG_SYSTEM = 'HZ_PARTY'
        AND ORIG_SYSTEM_ID = p_party_id;

		UPDATE WF_LOCAL_USER_ROLES
		SET USER_NAME = 'HZ_PARTY:'||USER_ORIG_SYSTEM_ID,
		EXPIRATION_DATE =  CASE WHEN NVL(EXPIRATION_DATE,SYSDATE) >= SYSDATE THEN SYSDATE -1 ELSE EXPIRATION_DATE END ,
		USER_END_DATE   =  CASE WHEN NVL(USER_END_DATE,SYSDATE)   >= SYSDATE THEN SYSDATE -1 ELSE USER_END_DATE END
		WHERE USER_ORIG_SYSTEM_ID = p_party_id
		AND USER_ORIG_SYSTEM = 'HZ_PARTY' ;

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'jtf_resource_wf_sync (-)',
                               p_msg_level=>fnd_log.level_procedure);
		END IF;

         EXCEPTION
          WHEN OTHERS THEN

				IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
				hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Exception in jtf_resource_wf_sync Error : '||SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200),
									   p_msg_level=>fnd_log.level_procedure);
				END IF;
          RAISE;

   END;


  PROCEDURE tca_tca_pre
    (p_party_id   IN number)  IS

    l_sql_stmt VARCHAR2(2000);
    --l_return_status VARCHAR2 (1000) DEFAULT '';
		l_debug_prefix                     VARCHAR2(30) := 'DRT ';
   BEGIN

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'hz_parties_pre (+)',
                               p_msg_level=>fnd_log.level_procedure);
		END IF;


     hz_common_pub.disable_cont_source_security;

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'hz_parties_pre (-)',
                               p_msg_level=>fnd_log.level_procedure);
		END IF;

      EXCEPTION
          WHEN OTHERS THEN

				IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
				hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Exception in hz_parties_pre Error : '||SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200),
									   p_msg_level=>fnd_log.level_procedure);
				END IF;
          RAISE;

   END tca_tca_pre;


  PROCEDURE DO_UPDATE_LOCATIONS
       (p_party_id   IN number)  IS

/*	 cursor c_locations (l_party_id NUMBER) is
		 SELECT hl.location_id,
			  object_version_number
			FROM hz_locations hl
			WHERE LOCATION_ID IN
			  (SELECT LOCATION_ID
			  FROM HZ_PARTY_SITES
			  WHERE PARTY_ID = l_party_id
			  OR (PARTY_ID  IN
				(SELECT PARTY_ID
				FROM HZ_RELATIONSHIPS
				WHERE SUBJECT_ID       = l_party_id
				AND SUBJECT_TABLE_NAME = 'HZ_PARTIES'
				AND SUBJECT_TYPE       = 'PERSON'
				))
			  );
*/
         cursor c_ps_locations (l_party_id NUMBER) is
         SELECT distinct  PS.LOCATION_ID
			  FROM HZ_PARTY_SITES PS
			  WHERE PARTY_ID IN  (
					SELECT p_party_id FROM DUAL
					UNION
					select hr.party_id
					from hz_relationships hr
					where hr.subject_id = p_party_id
					AND HR.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
					AND HR.subject_type = 'PERSON'
			  );





     cursor c_shared_locations (l_party_id NUMBER,l_ps_location_id NUMBER) is
		SELECT ps1.party_id,
			   rel.subject_id, rel.object_id,
						   ps1.party_site_id, ps1.location_id
		FROM hz_party_sites ps1,
					   hz_relationships rel
		WHERE ps1.location_id = l_ps_location_id
		AND ps1.party_id  = REL.party_id (+)
		and REL.directional_flag (+) = 'F'
		MINUS
		SELECT ps1.party_id,
			   rel.subject_id, rel.object_id,
						   ps1.party_site_id, ps1.location_id
		FROM hz_party_sites ps1,
					   hz_relationships rel
		WHERE ps1.location_id = l_ps_location_id
		AND ps1.party_id  = REL.party_id (+)
		and REL.directional_flag (+) = 'F'
		and (ps1.party_id = l_party_id
		OR
		ps1.party_id IN (SELECT rel.party_id FROM hz_relationships REL
					 WHERE  subject_id = l_party_id
					 AND    subject_table_name = 'HZ_PARTIES'
					 AND    subject_type = 'PERSON')
		);

		l_shared_location_count NUMBER;
		l_dummy_loc_count NUMBER;
		l_debug_prefix                     VARCHAR2(30) := 'DRT ';
		l_party_id NUMBER := p_party_id;
		l_location_id NUMBER;
	    p_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
		p_object_version_number number;
		l_loc_object_version_number number;
		x_return_status VARCHAR2(2000) := 'S';
		x_msg_count NUMBER;
		x_msg_data VARCHAR2(2000);

		c_party_id NUMBER;
	    c_subject_id NUMBER;
		c_object_id NUMBER;
		c_party_site_id NUMBER;
		c_location_id NUMBER;
		l_ps_location_id NUMBER;

		BEGIN

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'DO_UPDATE_LOCATIONS (+)',
                               p_msg_level=>fnd_log.level_procedure);
		END IF;

		OPEN c_ps_locations(l_party_id);
		FETCH  c_ps_locations INTO l_ps_location_id;
		LOOP
		 EXIT WHEN c_ps_locations%NOTFOUND ;

				 c_party_id := NULL;
				OPEN c_shared_locations (l_party_id,l_ps_location_id);
				   FETCH c_shared_locations INTO c_party_id, c_subject_id, c_object_id,c_party_site_id, c_location_id;
				CLOSE c_shared_locations;

							IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
							hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Processing location  : '||l_ps_location_id||' Shared Loc : '||c_party_id,
												   p_msg_level=>fnd_log.level_procedure);
							END IF;


				IF c_party_id IS NOT NULL THEN

							IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
							hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'c_party_id is NOT NULL. for LocationID : '||l_ps_location_id,
												   p_msg_level=>fnd_log.level_procedure);
							END IF;

				--c_party_id exists means there are shared locations
					SELECT count(1) INTO l_dummy_loc_count FROM hz_locations WHERE location_id = -54321;
					  --If location -54321 does not exists then insert data in to HZ_LOCATIONS table.
					  IF 	l_dummy_loc_count = 0 THEN
						IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
						hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>' -54321 location does not exists, inserting new location. ',
											   p_msg_level=>fnd_log.level_procedure);
						END IF;

						INSERT INTO hz_locations (    location_id,    last_update_date,    last_updated_by,    creation_date,
								   created_by,    last_update_login,    orig_system_reference,    country,
								address1,    address_key,        validated_flag,   content_source_type,
								sales_tax_inside_city_limits,     object_version_number,    created_by_module,
									timezone_id,    geometry_status_code,    actual_content_source
							) VALUES (
								-54321,    sysdate,    122,    sysdate,    122,    -1,    '-54321',    'US',
								'**********',    '****',       'N',     'USER_ENTERED',   '1',      1,    'TCA_V2_API',
									1,     'DIRTY',    'USER_ENTERED'
							);

					 END IF;

							IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
							hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Shared sites exists, updating sites with -54321 location. ',
												   p_msg_level=>fnd_log.level_procedure);
							END IF;

					 -- Update Party sites with location_id -54321 (masked location)
						 UPDATE HZ_PARTY_SITES
							SET LOCATION_ID = -54321 ,
							GLOBAL_ATTRIBUTE20 = l_ps_location_id
							WHERE LOCATION_ID = l_ps_location_id
							AND (PARTY_ID = l_party_id
										  OR (PARTY_ID  IN
											(SELECT PARTY_ID
											FROM HZ_RELATIONSHIPS
											WHERE SUBJECT_ID       = l_party_id
											AND SUBJECT_TABLE_NAME = 'HZ_PARTIES'
											AND SUBJECT_TYPE       = 'PERSON'
											))
								);

							IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
							hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Updated party sites with -54321 : '||SQL%ROWCOUNT,
												   p_msg_level=>fnd_log.level_procedure);
							END IF;

				ELSif c_party_id IS NULL THEN

				--c_party_id is NULL means there are NO shared locations
				--Locations should be masked.
							IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
							hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'c_party_id is NULL so masking for LocationID : '||l_ps_location_id,
												   p_msg_level=>fnd_log.level_procedure);
							END IF;
				BEGIN
					SELECT object_version_number INTO l_loc_object_version_number
					FROM hz_locations
					WHERE location_id = l_ps_location_id;

					 p_location_rec.location_id := l_ps_location_id;
					 p_object_version_number := l_loc_object_version_number;

					--Address_key replacement word not exists for '*******' so direct update statement used.

							UPDATE HZ_LOCATIONS
							SET
							ADDRESS1 = '**********',
							ADDRESS2 = NULL,
							ADDRESS3 = NULL,
							ADDRESS4 = NULL,
							ADDRESS_KEY = '***' ,
							ADDRESS_LINES_PHONETIC = NULL,
							GEOMETRY = NULL,
							POSTAL_CODE = NULL,
							POSTAL_PLUS4_CODE = NULL
							WHERE LOCATION_ID = l_ps_location_id;


					 --p_location_rec.address1 := '**********';
					 --p_location_rec.address2 := fnd_api.g_miss_char;
					 --p_location_rec.address3 := fnd_api.g_miss_char;
					 --p_location_rec.address4 := fnd_api.g_miss_char;
					 --p_location_rec.address_key := fnd_api.g_miss_char;
					 --p_location_rec.address_lines_phonetic  := fnd_api.g_miss_char;
					 --p_location_rec.geometry := NULL;
					 --p_location_rec.postal_code  := fnd_api.g_miss_char;
					 --p_location_rec.postal_plus4_code  := fnd_api.g_miss_char;



					hz_location_v2pub.update_location('T',p_location_rec,p_object_version_number,x_return_status,x_msg_count,x_msg_data);


					  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
						hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Location update return Status for Location ID : '||l_ps_location_id||'  ' ||x_return_status,
											   p_msg_level=>fnd_log.level_procedure);
						END IF;
					 IF x_return_status = 'S' THEN

					   null;
					-- When Location update was not success then return Error .
					 ELSIF x_return_status <> 'S' THEN
							RAISE FND_API.G_EXC_ERROR;
					 END IF;
                EXCEPTION
				WHEN NO_DATA_FOUND THEN
					IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Exception in DO_UPDATE_LOCATIONS NO DATA FOUND for location : '||l_ps_location_id,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;

				--RETURN SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200);
				 --RAISE FND_API.G_EXC_ERROR;
				 NULL;
  			    END;


				END IF; --shared locations end if



        FETCH  c_ps_locations INTO l_ps_location_id;
		END LOOP;
		CLOSE c_ps_locations;

		--------------------------------



	    EXCEPTION
          WHEN OTHERS THEN

				IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
				hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Exception in DO_UPDATE_LOCATIONS Error : '||SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200),
									   p_msg_level=>fnd_log.level_procedure);
				END IF;
          RAISE;

	END DO_UPDATE_LOCATIONS;


  PROCEDURE tca_tca_post
    (p_party_id   IN number)  IS

    --l_sql_stmt VARCHAR2(2000);
    --l_return_status VARCHAR2 (1000) DEFAULT '';
   /*
    CURSOR C_REL_PARTIES IS
		select rel.party_id ,
		decode(DIRECTIONAL_FLAG,'F',sub.party_name||'-'||obj.party_name||'-'||rel.party_number,'B',obj.party_name||'-'||sub.party_name||'-'||rel.party_number) REL_PARTY_NAME
		from hz_parties rel,hz_parties sub,hz_parties obj,hz_relationships hr
		where hr.party_id = rel.party_id
		and hr.subject_id = sub.party_id
		and hr.object_id = obj.party_id
		AND SUB.PARTY_ID = p_party_id
		AND HR.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
		AND HR.OBJECT_TABLE_NAME = 'HZ_PARTIES';
 */
    --l_random_string VARCHAR2(200) ;

	    cursor c_all_parties is
	    SELECT p_party_id FROM DUAL
		UNION
		select hr.party_id
		from hz_relationships hr
		where hr.subject_id = p_party_id
		AND HR.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
		AND HR.subject_type = 'PERSON';

		l_relationshp_id NUMBER;
	    p_relationship_rec HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;

		p_person_rec HZ_PARTY_V2PUB.PERSON_REC_TYPE;
		p_party_object_version_number NUMBER;
		x_profile_id NUMBER;


		cursor c_party_sites (l_party_id NUMBER)  is
		SELECT PARTY_SITE_ID,
		  object_version_number,
		  status
		FROM HZ_PARTY_SITES
		WHERE PARTY_ID IN(
		SELECT p_party_id FROM DUAL
					UNION
					select hr.party_id
					from hz_relationships hr
					where hr.subject_id = p_party_id
					AND HR.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
					AND HR.subject_type = 'PERSON'
		);

		p_party_site_rec HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
		l_party_site_id HZ_PARTY_SITES.PARTY_SITE_ID%TYPE;

/*		cursor c_locations (l_party_id NUMBER) is
		 SELECT hl.location_id,
			  object_version_number
			FROM hz_locations hl
			WHERE LOCATION_ID IN
			  (SELECT LOCATION_ID
			  FROM HZ_PARTY_SITES
			  WHERE PARTY_ID = l_party_id
			  OR (PARTY_ID  IN
				(SELECT PARTY_ID
				FROM HZ_RELATIONSHIPS
				WHERE SUBJECT_ID       = l_party_id
				AND SUBJECT_TABLE_NAME = 'HZ_PARTIES'
				AND SUBJECT_TYPE       = 'PERSON'
				))
			  );
*/



		 p_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
		 l_location_id NUMBER;
		 p_rel_object_version_number NUMBER;

		cursor c_accounts (l_party_id NUMBER)  is
		select cust_account_id,object_version_number,status
		 from HZ_CUST_ACCOUNTS
		 where party_id = l_party_id;

		 p_cust_account_rec HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
		 p_account_object_version_num NUMBER;
		  l_cust_account_id NUMBER;

	/*	cursor c_cust_site_uses (l_party_id NUMBER)    is
		 SELECT SITE_USE_ID,object_version_number,STATUS,cust_acct_site_id,org_id FROM HZ_CUST_SITE_USES_ALL WHERE
			SITE_USE_ID IN
			(SELECT SITE_USE_ID
			FROM HZ_CUST_SITE_USES_ALL CSU,
			  HZ_CUST_ACCT_SITES_ALL CAS
			WHERE CSU.CUST_ACCT_SITE_ID = CAS.CUST_ACCT_SITE_ID
			AND ( EXISTS
			  (SELECT 1
			  FROM HZ_PARTY_SITES PS
			  WHERE PS.PARTY_SITE_ID = CAS.PARTY_SITE_ID
			  AND (PARTY_ID          = l_party_id
			  OR (PARTY_ID          IN
				(SELECT PARTY_ID FROM HZ_RELATIONSHIPS WHERE SUBJECT_ID = l_party_id
				  AND SUBJECT_TABLE_NAME = 'HZ_PARTIES'
				  AND SUBJECT_TYPE  = 'PERSON'
				)))
			  )
				OR ( EXISTS
				  (SELECT 1
				  FROM HZ_CUST_ACCOUNTS CA
				  WHERE CA.PARTY_ID      = l_party_id
				  AND CA.CUST_ACCOUNT_ID = CAS.CUST_ACCOUNT_ID
			  ) ))
		   )
		   ORDER BY cust_acct_site_id,SITE_USE_CODE DESC;
*/

cursor c_cust_site_uses (l_party_id NUMBER)    is
		 SELECT SITE_USE_ID,object_version_number,STATUS,cust_acct_site_id,org_id FROM HZ_CUST_SITE_USES_ALL WHERE
	    site_use_id IN (
        SELECT site_use_id
        FROM
            hz_cust_site_uses_all csu,
            hz_cust_acct_sites_all cas
        WHERE
            csu.cust_acct_site_id = cas.cust_acct_site_id
             AND ( CAS.PARTY_SITE_ID    IN
					(SELECT PS.PARTY_SITE_ID
					FROM HZ_PARTY_SITES PS
					WHERE  ( party_id IN (
                        SELECT /*+ unnest */  l_party_id  FROM dual
                        UNION
                        SELECT/*+ unnest */ party_id FROM
                            hz_relationships
                        WHERE
                            subject_id = l_party_id
                            AND subject_table_name = 'HZ_PARTIES'
                            AND subject_type = 'PERSON'
                        ) )
            ) )
        UNION
        SELECT site_use_id
        FROM
            hz_cust_site_uses_all csu,
            hz_cust_acct_sites_all cas
        WHERE
            csu.cust_acct_site_id = cas.cust_acct_site_id
		 AND ( CAS.CUST_ACCOUNT_ID  IN
			(SELECT
			  /*+ unnest */
			  CA.CUST_ACCOUNT_ID
			FROM HZ_CUST_ACCOUNTS CA
			WHERE CA.PARTY_ID = l_party_id
            ) )
		)
			   ORDER BY cust_acct_site_id,SITE_USE_CODE DESC;


		  l_site_use_id NUMBER;
		  p_site_use_object_version_num NUMBER;
		  p_cust_site_use_rec hz_cust_account_site_v2pub.CUST_SITE_USE_REC_TYPE;
		  l_cust_acct_site_id NUMBER;
		  l_site_use_object_version_num NUMBER;
		  l_cust_site_org_id NUMBER;

		   cursor c_org_contacts  is
			SELECT ORG_CONTACT_ID
			FROM HZ_ORG_CONTACTS hoc
			WHERE PARTY_RELATIONSHIP_ID IN
			  (SELECT HR.RELATIONSHIP_ID
			  FROM HZ_RELATIONSHIPS HR,
				HZ_PARTIES HP
			  WHERE HR.SUBJECT_ID       = HP.PARTY_ID
			  AND HP.PARTY_TYPE         = 'PERSON'
			  AND HP.PARTY_ID           = p_party_id
			  AND HR.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
			  AND HR.SUBJECT_TYPE       = 'PERSON'
			  );



		p_org_contact_rec HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
		p_cont_object_version_number NUMBER;
		l_org_contact_id NUMBER;

		p_citizenship_rec     HZ_PERSON_INFO_V2PUB.citizenship_REC_TYPE;

		cursor c_citizensips is
		SELECT object_version_number ,citizenship_id,status
        FROM HZ_CITIZENSHIP
		WHERE party_id = p_party_id ;

		p_employ_hist_rec     HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE;

		cursor c_emp_history is
					  SELECT object_version_number ,employment_history_id,status
					  FROM HZ_EMPLOYMENT_HISTORY
					  WHERE party_id = p_party_id ;

		l_financial_profile_rec     HZ_PARTY_INFO_PUB.FINANCIAL_PROFILE_REC_TYPE;
		l_last_update_date date;


		CURSOR c_financial_profiles is
		  SELECT FINANCIAL_PROFILE_ID,status,last_update_date
          FROM HZ_FINANCIAL_PROFILE
		  WHERE party_id = p_party_id ;


		cursor c_contact_points (l_party_id NUMBER) is
		SELECT CONTACT_POINT_ID,
		  OBJECT_VERSION_NUMBER ,
		  STATUS
		FROM HZ_CONTACT_POINTS
		WHERE (OWNER_TABLE_NAME = 'HZ_PARTIES'
		AND OWNER_TABLE_ID      = l_party_id )
		UNION
		  SELECT HCP.CONTACT_POINT_ID,
		  HCP.OBJECT_VERSION_NUMBER ,
		  HCP.STATUS
		FROM HZ_CONTACT_POINTS HCP,HZ_PARTY_SITES HPS
		WHERE OWNER_TABLE_NAME = 'HZ_PARTY_SITES'
		AND OWNER_TABLE_ID    = HPS.PARTY_SITE_ID
		AND HPS.PARTY_ID = l_party_id
		UNION
		  SELECT HCP.CONTACT_POINT_ID,
		  HCP.OBJECT_VERSION_NUMBER ,
		  HCP.STATUS
		FROM HZ_CONTACT_POINTS HCP,HZ_RELATIONSHIPS HR
		WHERE OWNER_TABLE_NAME = 'HZ_PARTIES'
		AND OWNER_TABLE_ID   = HR.PARTY_ID
		AND HR.SUBJECT_TYPE = 'PERSON'
		AND SUBJECT_TABLE_NAME = 'HZ_PARTIES'
		AND HR.SUBJECT_ID        = l_party_id;

	/*		select CONTACT_POINT_ID,object_version_number ,status from hz_contact_points WHERE
			(OWNER_TABLE_NAME = 'HZ_PARTIES' AND OWNER_TABLE_ID = l_party_id ) OR (OWNER_TABLE_NAME = 'HZ_PARTY_SITES' AND OWNER_TABLE_ID IN
			  (SELECT PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID = l_party_id
			  ) ) OR (OWNER_TABLE_NAME = 'HZ_PARTIES' AND OWNER_TABLE_ID IN
			  (SELECT HP.PARTY_ID
			  FROM HZ_PARTIES HP ,
				HZ_RELATIONSHIPS HR,
				HZ_PARTIES SUB_PARTY
			  WHERE OWNER_TABLE_NAME   = 'HZ_PARTIES'
			  AND HP.PARTY_TYPE        = 'PARTY_RELATIONSHIP'
			  AND HR.PARTY_ID          = HP.PARTY_ID
			  AND SUB_PARTY.PARTY_TYPE = 'PERSON'
			  AND HR.SUBJECT_ID        = l_party_id
			  ));
		*/
		p_contact_points_rec HZ_CONTACT_POINT_v2pub.contact_point_rec_type;
		p_edi_rec HZ_CONTACT_POINT_v2pub.EDI_REC_TYPE;
		p_email_rec HZ_CONTACT_POINT_v2pub.EMAIL_REC_TYPE;
		p_phone_rec HZ_CONTACT_POINT_v2pub.PHONE_REC_TYPE;
		p_telex_rec HZ_CONTACT_POINT_v2pub.TELEX_REC_TYPE;
		p_web_rec HZ_CONTACT_POINT_v2pub.WEB_REC_TYPE;
		L_Contact_Point_Id number;
		p_object_version_number number;

		x_return_status VARCHAR2(2000) := 'S';
		x_msg_count NUMBER;
		x_msg_data VARCHAR2(2000);
		l_db_status VARCHAR2(2);
		l_status  VARCHAR2(10);
		l_debug_prefix                     VARCHAR2(30) := 'DRT ';
		l_party_id NUMBER;
   BEGIN

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'hz_parties_post (+)',
                               p_msg_level=>fnd_log.level_procedure);
		END IF;

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'DRT post process for PartyID : '||p_party_id,
                               p_msg_level=>fnd_log.level_procedure);
		END IF;



	--Enable content security, which we disabled in Pre process
     hz_common_pub.enable_cont_source_security;

	 --Setting Created by module value to 'HR API' to allow update_person API to update HR created parties also.
     FND_Profile.Put('HZ_CREATED_BY_MODULE',   'HR API');




          BEGIN
  		  --Main Party update
			  p_person_rec.party_rec.party_id := p_party_id;


				  SELECT object_version_number,STATUS,PERSON_FIRST_NAME,PERSON_LAST_NAME
				  into p_party_object_version_number ,l_db_status, p_person_rec.person_first_name,	  p_person_rec.person_last_name
				  FROM HZ_PARTIES
				  WHERE party_id = p_person_rec.party_rec.party_id;


				IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
				hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Party status  : '||l_db_status,
									   p_msg_level=>fnd_log.level_procedure);
				END IF;


			   -- If party is Active make it Inactive. Will not change for status Merge and Delete.
			   IF l_db_status = 'A' THEN
					p_person_rec.party_rec.status := 'I';


				    --Submitting status update through API.
					--For parties we handle following things with update_person API call
					 --DQM sync ,Inactivate,business event submission
					hz_party_v2pub.update_person('T',p_person_rec,p_party_object_version_number,x_profile_id,x_return_status,x_msg_count,x_msg_data);



					IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Update_person return Status : '||x_return_status,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;

			 -- When Person party update was not success then return Error .
					 IF x_return_status <> 'S' THEN
						 RAISE FND_API.G_EXC_ERROR;
					 END IF;

			   ELSE
			       -- When Party status is Inactive then calling only DQM sync call.
			       --p_person_rec.party_rec.status := l_db_status;
				   HZ_DQM_SYNC.sync_person(p_party_id, 'U');

					IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Party status is Inactive. Skipping Update call and only DQM Sync call initiated.',
										   p_msg_level=>fnd_log.level_procedure);
					END IF;

			   END IF;

		     EXCEPTION
            WHEN NO_DATA_FOUND THEN
				IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
				hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Exception in Update_person Error : '||SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200),
									   p_msg_level=>fnd_log.level_procedure);
				END IF;

            --RETURN SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200);
             RAISE FND_API.G_EXC_ERROR;
		   WHEN TOO_MANY_ROWS THEN
				IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
				hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Exception in Update_person Error : '||SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200),
									   p_msg_level=>fnd_log.level_procedure);
				END IF;

            --RETURN SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200);
             RAISE FND_API.G_EXC_ERROR;
		   END;


          -- Org Contact update
		  --No Status change, to submit business event we are calling update API.
	      BEGIN
			  OPEN c_org_contacts ;
			  FETCH c_org_contacts into l_org_contact_id;

			  LOOP
			  EXIT WHEN c_org_contacts%NOTFOUND ;

				  p_org_contact_rec.org_contact_id := l_org_contact_id;



						  select oc.object_version_number oc_ovn,hr.object_version_number,hp.object_version_number,oc.status
						  into  p_cont_object_version_number ,p_rel_object_version_number,p_party_object_version_number,l_db_status
								from HZ_ORG_CONTACTS oc,HZ_RELATIONSHIPS hr,HZ_PARTIES hp
						where PARTY_RELATIONSHIP_ID = RELATIONSHIP_ID
						and HP.PARTY_ID = HR.PARTY_ID
						and org_contact_id = l_org_contact_id
						and rownum = 1	;


						hz_party_contact_v2pub.update_org_contact('T',p_org_contact_rec,p_cont_object_version_number,p_rel_object_version_number,p_party_object_version_number,x_return_status,x_msg_count,x_msg_data);

					   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
						hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Org Contact update return Status for OrgContact ID : '||l_org_contact_id||' : ' ||x_return_status,
											   p_msg_level=>fnd_log.level_procedure);
						END IF;

					 -- When update was not success then return Error .
					 IF x_return_status <> 'S' THEN
						RAISE FND_API.G_EXC_ERROR;
					 END IF;

				  FETCH c_org_contacts into l_org_contact_id;
				 END LOOP;
				 CLOSE c_org_contacts;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Exception in Update ORG contact Error : '||SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200),
								   p_msg_level=>fnd_log.level_procedure);
			END IF;

		--RETURN SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200);
		WHEN TOO_MANY_ROWS THEN
			IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Exception in Update ORG contact  Error : '||SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200),
								   p_msg_level=>fnd_log.level_procedure);
			END IF;

		--RETURN SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200);
		RAISE FND_API.G_EXC_ERROR;
		END;


      -- Employement History update
          BEGIN

			  OPEN c_emp_history ;
			  FETCH c_emp_history into p_object_version_number,p_employ_hist_rec.employment_history_id,l_db_status;
			  LOOP
			  EXIT WHEN c_emp_history%NOTFOUND ;
			  p_employ_hist_rec.party_id := p_party_id;


			  IF l_db_status = 'A' THEN
					p_employ_hist_rec.status := 'I';



			  HZ_PERSON_INFO_V2PUB.update_employment_history(
                   p_init_msg_list             => 'T',
                   p_employment_history_rec    => p_employ_hist_rec,
                   p_object_version_number     => p_object_version_number,
                   x_return_status             => x_return_status,
                   x_msg_count                 => x_msg_count,
                   x_msg_data                  => x_msg_data
                 );

				 IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Employement Hist update return Status for EmpHist ID : '||p_employ_hist_rec.employment_history_id||'  ' ||x_return_status,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;

				 -- When Person party Site update was not success then return Error .
				 IF x_return_status <> 'S' THEN
					RAISE FND_API.G_EXC_ERROR;
				 END IF;

			  ELSE

				 IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Inactive Employement Hist update skipped for EmpHist ID : '||p_employ_hist_rec.employment_history_id,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;

				 --p_employ_hist_rec.status := l_db_status;
			  END IF;

			  FETCH c_emp_history into p_object_version_number,p_employ_hist_rec.employment_history_id,l_db_status;

			  END LOOP;
			  CLOSE c_emp_history;


		   END;

          -- Citizenship update
		   BEGIN


		     OPEN c_citizensips ;
			  FETCH c_citizensips into p_object_version_number,p_citizenship_rec.citizenship_id,l_db_status;
			  LOOP
			  EXIT WHEN c_citizensips%NOTFOUND ;

		      p_citizenship_rec.party_id := p_party_id;


			  IF l_db_status = 'A' THEN
					p_citizenship_rec.status := 'I';

				  HZ_PERSON_INFO_V2PUB.update_citizenship(
					p_init_msg_list             => 'T',
					p_citizenship_rec           => p_citizenship_rec,
					p_object_version_number     => p_object_version_number,
					x_return_status             => x_return_status,
					x_msg_count                 => x_msg_count,
					x_msg_data                  => x_msg_data
				  );
				 IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Citizenship update return Status for Citizenship ID : '||p_citizenship_rec.citizenship_id||'  ' ||x_return_status,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;

				 -- When Citizenship update was not success then return Error .
				 IF x_return_status <> 'S' THEN
					RAISE FND_API.G_EXC_ERROR;
				 END IF;

			  ELSE
					--p_citizenship_rec.status := l_db_status;

				 IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Inactive Citizenship update skipped for Citizenship ID : '||p_citizenship_rec.citizenship_id,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;
			  END IF;

			  FETCH c_citizensips into p_object_version_number,p_citizenship_rec.citizenship_id,l_db_status;

			  END LOOP;
			  CLOSE c_citizensips;


		   END;

	 -- Financial profile update

	     BEGIN
	   	     l_financial_profile_rec.party_id := p_party_id;

             OPEN c_financial_profiles ;
			  FETCH c_financial_profiles into l_financial_profile_rec.FINANCIAL_PROFILE_ID,l_db_status,l_last_update_date;
			  LOOP
			  EXIT WHEN c_financial_profiles%NOTFOUND ;


	 	      IF l_db_status = 'A' THEN
					l_financial_profile_rec.status := 'I';


				   HZ_PARTY_INFO_PUB.update_financial_profile(
					   p_api_version               => 1.0,
					   p_financial_profile_rec     => l_financial_profile_rec,
					   p_last_update_date          => l_last_update_date,
					   x_return_status             => x_return_status,
					   x_msg_count                 => x_msg_count,
					   x_msg_data                  => x_msg_data
					 );

	 	            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Financial profile update return Status for FinProf ID : '||l_financial_profile_rec.FINANCIAL_PROFILE_ID ||'  ' ||x_return_status,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;

				 -- When Financial profile update was not success then return Error .
				 IF x_return_status <> 'S' THEN
					RAISE FND_API.G_EXC_ERROR;
				 END IF;

			  ELSE
					--l_financial_profile_rec.status := l_db_status;
	 	            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Inactive Financial profile update skipped for FinProf ID : '||l_financial_profile_rec.FINANCIAL_PROFILE_ID ,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;

			  END IF;
			  FETCH c_financial_profiles into l_financial_profile_rec.FINANCIAL_PROFILE_ID,l_db_status,l_last_update_date;

			  END LOOP;
			  CLOSE c_financial_profiles;


		   END;

 --Account update
		  BEGIN
			  OPEN c_accounts (p_party_id);
			  FETCH c_accounts into l_cust_account_id,p_account_object_version_num,l_db_status;
			  LOOP
			  EXIT WHEN c_accounts%NOTFOUND ;

			  p_cust_account_rec.cust_account_id := l_cust_account_id;
			  IF l_db_status = 'A' THEN
				p_cust_account_rec.status := 'I';


			   HZ_CUST_ACCOUNT_V2PUB.update_cust_account('T',p_cust_account_rec,p_account_object_version_num,x_return_status,x_msg_count,x_msg_data);

				   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Account update return Status for Account ID : '||l_cust_account_id||'  ' ||x_return_status,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;

				 -- When Person party Site update was not success then return Error .
				 IF x_return_status <> 'S' THEN
					RAISE FND_API.G_EXC_ERROR;
				 END IF;

			  ELSE
			    --p_cust_account_rec.status := l_db_status;
				   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Inactive Account update skipped for Account ID : '||l_cust_account_id,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;


			  END IF;

			 FETCH c_accounts into l_cust_account_id,p_account_object_version_num,l_db_status;
			  END LOOP;
			  CLOSE c_accounts;

		   END;



--Cust Acct Site Uses update
		  BEGIN
			  OPEN c_cust_site_uses (p_party_id);
			  FETCH c_cust_site_uses into l_site_use_id,l_site_use_object_version_num,l_db_status,l_cust_acct_site_id,l_cust_site_org_id;
			  LOOP
			  EXIT WHEN c_cust_site_uses%NOTFOUND ;

			  p_cust_site_use_rec.site_use_id := l_site_use_id;
			  p_cust_site_use_rec.cust_acct_site_id := l_cust_acct_site_id;
			  IF l_db_status = 'A' THEN
				p_cust_site_use_rec.status := 'I';


				p_site_use_object_version_num := l_site_use_object_version_num ;
					IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Account Site use update p_site_use_object_version_num : '||p_site_use_object_version_num
                    ||'Org : '||l_cust_site_org_id||'Site Use ID : '||l_site_use_id,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;
				begin
				mo_global.set_org_context(l_cust_site_org_id,null,'AR');
				end;

				begin
				mo_global.set_policy_context('S',l_cust_site_org_id);
				end;


               hz_cust_account_site_v2pub.update_cust_site_use('T',p_cust_site_use_rec,p_site_use_object_version_num,x_return_status,x_msg_count,x_msg_data);

				   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Account Site use update return Status for Site Use ID : '||l_site_use_id||'  ' ||x_return_status,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;

				 -- When Person party Site update was not success then return Error .
				 IF x_return_status <> 'S' THEN
					RAISE FND_API.G_EXC_ERROR;
				 END IF;

			ELSE

					IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Account Site use was not active skipping API call for Site Use ID : '||l_site_use_id,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;

			    p_cust_site_use_rec.status := l_db_status;
			END IF;

		  	--	l_site_use_object_version_num := NULL;
			 FETCH c_cust_site_uses into l_site_use_id,l_site_use_object_version_num,l_db_status,l_cust_acct_site_id,l_cust_site_org_id;
			  END LOOP;
			  CLOSE c_cust_site_uses;

		   END;


	-- Contact Point update.
	-- Contact points will be available for related parties but kept it out of All parties loop.
	     BEGIN
			OPEN c_contact_points(p_party_id) ;
			  FETCH c_contact_points into L_Contact_Point_Id,P_OBJECT_VERSION_NUMBER,l_db_status;
			  LOOP
				EXIT WHEN c_contact_points%NOTFOUND ;

				  p_contact_points_rec.contact_point_id := L_Contact_Point_Id;
				-- p_contact_points_rec.status := 'I';

			  	 IF l_db_status = 'A' THEN
					p_contact_points_rec.status := 'I';


			  --p_contact_points_rec.TRANSPOSED_PHONE_NUMBER := 0;


				hz_contact_point_v2pub.update_contact_point('T',p_contact_points_rec,p_edi_rec,p_email_rec,p_phone_rec,p_telex_rec,p_web_rec,p_object_version_number,x_return_status,x_msg_count,x_msg_data);

					IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'update_contact_point return Status for Contact point ID : '||L_Contact_Point_Id||'  ' ||x_return_status,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;

				 -- When Contact point update was not success then return Error .
				 IF x_return_status <> 'S' THEN
					RAISE FND_API.G_EXC_ERROR;
				 END IF;
				  ELSE
					--p_contact_points_rec.status := l_db_status;
					IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Inactive contact_point update skipped for Contact point ID : '||L_Contact_Point_Id,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;



				  END IF;
  			  FETCH c_contact_points into L_Contact_Point_Id,P_OBJECT_VERSION_NUMBER,l_db_status;

			  END LOOP;
			CLOSE c_contact_points;

		   END;

	--Processing location data
     DO_UPDATE_LOCATIONS(p_party_id);



	-- Party Site Update
        BEGIN
		--p_party_site_rec.party_id := p_party_id;

		OPEN c_party_sites (p_party_id);
		  FETCH c_party_sites into l_party_site_id,p_object_version_number,l_db_status;
		  LOOP
			EXIT WHEN c_party_sites%NOTFOUND ;


				  p_party_site_rec.party_site_id := l_party_site_id;
				  p_party_site_rec.status  := 'I';

				  IF l_db_status = 'A' THEN
					p_party_site_rec.status := 'I';



				-- Now call the stored program
				  hz_party_site_v2pub.update_party_site('T',p_party_site_rec,p_object_version_number,x_return_status,x_msg_count,x_msg_data);

				  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Party site update return Status for Party Site ID : '||l_party_site_id||'  ' ||x_return_status,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;

				 -- When Person party Site update was not success then return Error .
				 IF x_return_status <> 'S' THEN
					RAISE FND_API.G_EXC_ERROR;
				 END IF;

				  ELSE
					--p_party_site_rec.status := l_db_status;
				  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Inactive Party site update skipped for Party Site ID : '||l_party_site_id,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;
				  END IF;

			  FETCH c_party_sites into l_party_site_id,p_object_version_number,l_db_status;

			  END LOOP;
			  CLOSE c_party_sites;

		   END;

    -- Entities, which can be part of related parties.
    -- Fetch relationship party_id and update for both main party and related party
   -- BEGIN
		 OPEN c_all_parties;
		 FETCH c_all_parties INTO l_party_id;
         LOOP
         EXIT WHEN 	c_all_parties%NOTFOUND;


		 BEGIN

           -- Relationship update is Only for related parties i.e other than main party.
		   IF 	l_party_id <> P_party_id THEN


		   SELECT p.object_version_number,r.object_version_number,r.status ,r.relationship_id
		   into  p_party_object_version_number,p_object_version_number,l_db_status,l_relationshp_id
		   FROM hz_relationships r,hz_parties p
		   WHERE r.party_id = p.party_id
		   AND p.party_id = l_party_id
		   AND ROWNUM = 1;

		     p_relationship_rec.relationship_id := l_relationshp_id;

		   	  IF l_db_status = 'A' THEN
					p_relationship_rec.status := 'I';



		   hz_relationship_v2pub.update_relationship('T',p_relationship_rec,p_object_version_number,p_party_object_version_number,x_return_status,x_msg_count,x_msg_data);

		   	   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Relationship update return Status for Relationship ID : '||l_relationshp_id||'  ' ||x_return_status,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;


				 IF x_return_status <> 'S' THEN
					RAISE FND_API.G_EXC_ERROR;
				 END IF;

			  ELSE
					--p_relationship_rec.status := l_db_status;
		   	        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Inactive Relationship update skipped for Relationship ID : '||l_relationshp_id,
										   p_msg_level=>fnd_log.level_procedure);
					END IF;



			  END IF;

		  END IF;
           EXCEPTION
	       WHEN NO_DATA_FOUND THEN
				IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
				hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Exception in Update Relationship Error : '||SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200),
									   p_msg_level=>fnd_log.level_procedure);
				END IF;

            --RETURN SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200);
		   WHEN TOO_MANY_ROWS THEN
				IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
				hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Exception in Update Relationship Error : '||SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200),
									   p_msg_level=>fnd_log.level_procedure);
				END IF;

            --RETURN SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200);
            RAISE FND_API.G_EXC_ERROR;
		   END;


    --LOOP for all related parties.
	FETCH c_all_parties INTO l_party_id;
	END LOOP;
 	CLOSE c_all_parties;




    --Calling jtf_resource_wf_sync for resource sync with WF
    jtf_resource_wf_sync(p_party_id);

 --END;
	    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'hz_parties_post (-) Return Success. ',
                               p_msg_level=>fnd_log.level_procedure);
		END IF;


        EXCEPTION
            WHEN OTHERS THEN
				IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
				hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Exception in hz_parties_post Error : '||SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200),
									   p_msg_level=>fnd_log.level_procedure);
				END IF;

            --RETURN SUBSTR(SQLCODE||' - '||SQLERRM, 1, 200);
            RAISE FND_API.G_EXC_ERROR;
   END tca_tca_post;




   END HZ_DRT_PKG;

/
