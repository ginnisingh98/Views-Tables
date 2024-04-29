--------------------------------------------------------
--  DDL for Package Body JTF_PF_SOA_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PF_SOA_MIGRATE_PKG" AS
/* $Header: jtfpfsoamgrtpkgb.pls 120.5 2006/08/18 08:53:32 rjaiswal noship $ */
    PROCEDURE MIGRATE_LOGINS_DATA(timezone_offset IN NUMBER) IS
        maxstartt DATE;
        maxendt DATE;

        BEGIN
    		BEGIN
    		    SELECT max(timestamp) INTO maxstartt
    			FROM jtf_pf_ses_activity
    			WHERE tech_stack='AUDIT' AND pagename='LOGIN';
    		EXCEPTION
    			WHEN no_data_found THEN
    			maxstartt := NULL;
    		END;

    		-- insert login data from fnd_logins
        	INSERT INTO jtf_pf_ses_activity
                (
                seqid, day, timestamp, sessionid, userid,
                appid, respid, langid, proxyid,
                startt,
    			tech_stack, pagename, statuscode, exect, po, object_version_number, thinkt,
                created_by, creation_date, last_updated_by, last_update_date, last_update_login, servername, serverport
                )
        	        (SELECT /*+ parallel(i) use_nl(f) */ JTF_PF_SOA_SEQ.NEXTVAL + 0.1, trunc(f.start_time), f.start_time, i.session_id, f.user_id,
                        NVL(i.responsibility_application_id, -1), NVL(i.responsibility_id, -1), NVL(i.language_code, -1), NVL(i.proxy_user_id, -1),
                        (trunc( (f.start_time - to_date('1970/01/01', 'YYYY/MM/DD')) * 86400 * 1000) - timezone_offset) startt,
        				'AUDIT', 'LOGIN', 200, 0, -1, 1, (f.end_time - f.start_time) * 86400 * 1000 thinkt,
                        fnd_global.user_id, sysdate, fnd_global.user_id, sysdate, fnd_global.conc_login_id, 'N/A', -1
        			FROM fnd_logins f, icx_sessions i
        			WHERE f.login_id = i.login_id
        				AND (maxstartt IS NULL
                                             OR f.start_time > maxstartt
        				     OR (f.start_time = maxstartt AND f.user_id NOT IN (SELECT userid FROM jtf_pf_ses_activity WHERE tech_stack='AUDIT' AND pagename='LOGIN' AND timestamp=maxstartt and day= maxstartt)))
        			);

    		BEGIN
    			SELECT max(timestamp) INTO maxendt
    			FROM jtf_pf_ses_activity
    			WHERE tech_stack='AUDIT' AND pagename='LOGOUT';
    		EXCEPTION
    			WHEN no_data_found THEN
    			maxendt := NULL;
    		END;

    		-- insert logout data from fnd_logins
        	INSERT INTO jtf_pf_ses_activity
                (seqid, day, timestamp, sessionid, userid,
                appid, respid, langid,proxyid,
                startt,
        		tech_stack, pagename, statuscode, exect, po, object_version_number, created_by,
        		creation_date, last_updated_by, last_update_date, last_update_login
                )
        			(SELECT /*+ parallel(i) use_nl(f) */  JTF_PF_SOA_SEQ.NEXTVAL + 0.1, trunc(f.end_time), f.end_time, i.session_id, f.user_id,
                        NVL(i.responsibility_application_id, -1), NVL(i.responsibility_id, -1), NVL(i.language_code, -1), NVL(i.proxy_user_id, -1),
                        (trunc( (end_time - to_date('1970/01/01', 'YYYY/MM/DD')) * 86400 * 1000) - timezone_offset) startt,
            			'AUDIT', 'LOGOUT', 200, 0, -1, 1, fnd_global.user_id,
            			sysdate, fnd_global.user_id, sysdate, fnd_global.conc_login_id
        			FROM fnd_logins f, icx_sessions i
        			WHERE f.login_id = i.login_id
                                        AND f.end_time IS NOT NULL
        				AND (maxendt IS NULL
                                             OR f.end_time > maxendt
        				     OR (f.end_time = maxendt AND f.user_id NOT IN (SELECT userid FROM jtf_pf_ses_activity WHERE tech_stack='AUDIT' AND pagename='LOGOUT' AND timestamp=maxendt AND day=maxendt)))
        			);

    END MIGRATE_LOGINS_DATA;

	PROCEDURE MIGRATE_RESP_DATA(timezone_offset IN NUMBER) IS
	    maxtimestamp DATE;
	    BEGIN
	    	BEGIN
		    	SELECT max(timestamp) INTO maxtimestamp
				FROM jtf_pf_ses_activity
				WHERE tech_stack = 'AUDIT' AND pagename = 'RESP_CHANGE';
	    	EXCEPTION
		    	WHEN no_data_found THEN
		    	maxtimestamp := NULL;
	    	END;

	        IF(maxtimestamp IS NOT NULL) THEN
	        	DELETE FROM jtf_pf_ses_activity
	        	WHERE tech_stack = 'AUDIT' AND pagename = 'RESP_CHANGE' AND timestamp = maxtimestamp;
	        END IF;

	       	INSERT INTO jtf_pf_ses_activity
		        (seqid, day, timestamp, sessionid, userid, appid,
				respid, langid, proxyid,
				startt,
				tech_stack, pagename, statuscode, exect, thinkt,
				po, object_version_number, created_by, creation_date, last_updated_by,
				last_update_date, last_update_login
				)
		            (SELECT /*+ parallel(i) use_nl(r) */ JTF_PF_SOA_SEQ.NEXTVAL + 0.1, trunc(r.start_time), r.start_time, i.session_id, i.user_id, r.resp_appl_id,
						r.responsibility_id, NVL(i.language_code, -1), NVL(i.proxy_user_id, -1),
						(trunc( (r.start_time - to_date('1970/01/01', 'YYYY/MM/DD')) * 86400 * 1000) - timezone_offset) startt,
						'AUDIT', 'RESP_CHANGE', 200, 0, (r.end_time - r.start_time) * 86400 * 1000 thinkt,
						-1, 1, fnd_global.user_id, sysdate, fnd_global.user_id,
						sysdate, fnd_global.conc_login_id
					FROM fnd_login_responsibilities r, icx_sessions i
					WHERE r.login_id = i.login_id
                                              AND (maxtimestamp IS NULL
                                                   OR r.start_time > maxtimestamp
                                                   OR (r.start_time = maxtimestamp AND r.responsibility_id NOT IN
						        (SELECT respid FROM jtf_pf_ses_activity WHERE tech_stack='AUDIT' AND pagename = 'RESP_CHANGE' AND timestamp = maxtimestamp AND day=maxtimestamp))));

	END MIGRATE_RESP_DATA;

	PROCEDURE MIGRATE_FORMS_DATA(timezone_offset IN NUMBER) IS
	    maxtimestamp DATE;
	    BEGIN
	    	BEGIN
			    SELECT max(timestamp) INTO maxtimestamp FROM jtf_pf_ses_activity WHERE tech_stack='FORM';
			EXCEPTION
				WHEN no_data_found THEN
				maxtimestamp := NULL;
			END;

	        IF(maxtimestamp IS NOT NULL) THEN
	          DELETE FROM jtf_pf_ses_activity
	          WHERE tech_stack = 'FORM' AND timestamp = maxtimestamp;
	        END IF;

                INSERT INTO jtf_pf_ses_activity
		( seqid, day, timestamp, sessionid, userid, appid,
		  respid, langid,proxyid,startt, tech_stack, pagename,
		  statuscode, exect, thinkt, po, object_version_number,
		  created_by, creation_date, last_updated_by, last_update_date,
		  last_update_login
		)
		( SELECT /*+ parallel(i) use_nl(f) */ JTF_PF_SOA_SEQ.NEXTVAL + 0.1, trunc(f.start_time), f.start_time,
		  i.session_id, i.user_id, f.form_appl_id, r.responsibility_id, NVL(i.language_code, -1),NVL(i.proxy_user_id, -1),
		  (trunc( (f.start_time - to_date('1970/01/01', 'YYYY/MM/DD')) * 86400 * 1000) - timezone_offset) startt,
		  'FORM', to_char(f.form_id), 200, 0, (f.end_time - f.start_time) * 86400 * 1000 thinkt, -1, 1,
		  fnd_global.user_id, sysdate, fnd_global.user_id, sysdate, fnd_global.conc_login_id
		  FROM fnd_login_resp_forms f, icx_sessions i, fnd_login_responsibilities r
		  WHERE f.login_id = i.login_id
                        AND r.login_resp_id = f.login_resp_id
                        AND (maxtimestamp IS NULL
                             OR f.start_time > maxtimestamp
                             OR (f.start_time = maxtimestamp AND to_char(f.form_id) NOT IN (SELECT pagename FROM jtf_pf_ses_activity WHERE tech_stack = 'FORM' AND timestamp = maxtimestamp and day = maxtimestamp AND to_char(f.form_id) = pagename)))
		);
	END MIGRATE_FORMS_DATA;

END JTF_PF_SOA_MIGRATE_PKG;

/
