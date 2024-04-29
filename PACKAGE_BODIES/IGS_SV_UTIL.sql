--------------------------------------------------------
--  DDL for Package Body IGS_SV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SV_UTIL" AS
/* $Header: IGSSV02B.pls 120.7 2006/07/27 07:36:19 svadde noship $ */

/******************************************************************

    Copyright (c) 2006 Oracle Corporation, Redwood Shores, CA, USA
                         All rights reserved.

 Created By         : SreeKrishna Vadde

 Date Created By    : Wednesday, January 04, 2006

 Purpose            : This  is a utility package for all sevis related operations


 remarks            : None

 Change History

Who                   When           What
-----------------------------------------------------------
******************************************************************/
   PROCEDURE get_prev_btch_dtls (
      p_key_code            IN       VARCHAR2,
      p_person_id           IN       NUMBER,
      p_cur_batch_id        IN       NUMBER,
      p_extra_param         IN       VARCHAR2,
      x_prev_batch_id       OUT  NOCOPY    NUMBER,
      x_prev_btch_prcs_dt   OUT  NOCOPY    DATE
   )
   /******************************************************************
   Created By         : SreeKrishna Vadde

   Date Created By    : Thursday, January 05, 2006

   Purpose            : It returns the previously processed batch id and it's process date.

   Change History
   Who                  When            What
------------------------------------------------------------------------
 vskumar		31-May-2006	Bug 5245394. Xbuild3 performance fix. used bind parameters in the query.
******************************************************************/
   IS
      batch_no_crsr    bath_crsr;
      l_prev_btch_id   NUMBER;
      l_tbl_name       VARCHAR2 (30);
      l_extra_critra   VARCHAR2 (50)  := '';
      l_stmt           VARCHAR2 (400);

      CURSOR proc_dt_crsr (batch_no NUMBER)
      IS
         SELECT creation_date
           FROM igs_sv_batches
          WHERE batch_id = batch_no;
   BEGIN
      get_tbl_extra_params (
         p_key_code,
         p_extra_param,
         l_tbl_name,
         l_extra_critra
      );

      IF l_extra_critra IS NOT NULL THEN
	 l_stmt := 'SELECT MAX(BATCH_ID) FROM ' || l_tbl_name || ' WHERE PERSON_ID = :1 AND BATCH_ID < :2 '
		  || l_extra_critra;
	 OPEN batch_no_crsr FOR l_stmt USING p_person_id, p_cur_batch_id, p_extra_param;
      ELSE
	 l_stmt := 'SELECT MAX(BATCH_ID) FROM ' || l_tbl_name || ' WHERE PERSON_ID = :1 AND BATCH_ID < :2 ';
	 OPEN batch_no_crsr FOR l_stmt USING p_person_id, p_cur_batch_id;
      END IF;


      FETCH batch_no_crsr INTO x_prev_batch_id;
      CLOSE batch_no_crsr;
      OPEN proc_dt_crsr (x_prev_batch_id);
      FETCH proc_dt_crsr INTO x_prev_btch_prcs_dt;
      CLOSE proc_dt_crsr;
   END get_prev_btch_dtls;

   PROCEDURE get_tbl_extra_params (
      p_key_code       IN       VARCHAR2,
      p_extra_param    IN       VARCHAR2,
      x_tbl_name       OUT   NOCOPY   VARCHAR2,
      x_extra_critra   OUT   NOCOPY   VARCHAR2
   )
  /******************************************************************
   Created By         : SreeKrishna Vadde

   Date Created By    : Thursday, January 05, 2006

   Purpose            : It returns the table name and criteria for perticuler key.

   Internal

   Change History
   Who                  When            What
   vskumar		31-May-2006	Bug 5245394. Xbuild3 performance fix. used bind parameters in the query.
------------------------------------------------------------------------

******************************************************************/
   IS
   BEGIN
      IF (p_key_code = 'SV_BIO') THEN
         x_tbl_name := 'IGS_SV_BIO_INFO';
      ELSIF (p_key_code = 'SV_CONVICTION') THEN
         x_tbl_name := 'IGS_SV_CONVICTIONS';
         x_extra_critra := ' and CONVICTION_ID = :p_extra_param ';
      ELSIF (p_key_code = 'SV_DEPDNT') THEN
         x_tbl_name := 'IGS_SV_DEPDNT_INFO';
         x_extra_critra := ' and DEPDNT_ID = :p_extra_param ';
      ELSIF (   p_key_code = 'SV_CPT_EMPL'
             OR p_key_code = 'SV_OFF_EMPL'
             OR p_key_code = 'SV_OPT_EMPL'
	     OR p_key_code = 'SV_EMPL'
            ) THEN
         x_tbl_name := 'IGS_SV_EMPL_INFO';
         x_extra_critra := ' and NONIMG_EMPL_ID = :p_extra_param';
      ELSIF (p_key_code = 'SV_FINANCIAL') THEN
         x_tbl_name := 'IGS_SV_FINANCE_INFO';
      ELSIF (p_key_code = 'SV_LEGAL') THEN
         x_tbl_name := 'IGS_SV_LEGAL_INFO';
      ELSIF (p_key_code = 'SV_OTHER') THEN
         x_tbl_name := 'IGS_SV_OTH_INFO';
      ELSIF (   p_key_code = 'SV_PRGMS'
             OR p_key_code = 'SV_STATUS'
            ) THEN
         x_tbl_name := 'IGS_SV_PRGMS_INFO';
      ELSIF (p_key_code = 'SV_SOA') THEN
         x_tbl_name := 'IGS_SV_ADDRESSES';
         x_extra_critra :=    ' and PARTY_SITE_ID = :p_extra_param';
	  ELSIF (p_key_code = 'SV_F_ADDR') THEN
         x_tbl_name := 'IGS_SV_ADDRESSES';
	  ELSIF (p_key_code = 'SV_US_ADDR') THEN
         x_tbl_name := 'IGS_SV_ADDRESSES';
      ELSIF (p_key_code = 'SV_AUTH_DROP') THEN
         x_tbl_name := 'IGS_SV_PRGMS_INFO';
		 x_extra_critra :=    ' and SEVIS_AUTH_ID = :p_extra_param';
      END IF;
   END get_tbl_extra_params;

   FUNCTION ismutuallyexclusive (
      p_person_id          NUMBER,
      p_batch_id           NUMBER,
      p_operation          VARCHAR2,
      p_information_type   VARCHAR2
   )
    /******************************************************************
   Created By         : Manoj Kumar

   Date Created By    : Thursday, January 05, 2006

   Purpose            : Checks weather this record is mutually exclusive with any record in the current batch


   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
      RETURN BOOLEAN
   IS
      CURSOR c_check(cp_information_type VARCHAR2, cp_mutually_info_typ VARCHAR2)
      IS
         SELECT COUNT (*)
           FROM igs_sv_btch_summary
          WHERE batch_id = p_batch_id
            AND person_id = p_person_id
            AND ACTION_CODE IN (SELECT lookup_code
                               FROM igs_lookup_values
                              WHERE lookup_type = cp_mutually_info_typ)
            AND action_code <> 'NEW' AND TAG_CODE = cp_information_type;

      l_count   NUMBER := 0;
   BEGIN
      OPEN c_check(p_information_type,p_information_type || '_MUT_EXCL_OPR' );
      FETCH c_check INTO l_count;
      CLOSE c_check;

      IF l_count > 0 THEN
         RETURN TRUE ;
      ELSE
         RETURN FALSE ;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         null;
   END;

   PROCEDURE change_record_status (
      p_person_id     IN   NUMBER,
      p_batch_id      IN   NUMBER,
      p_info_key      IN   VARCHAR2,
      p_extra_param   IN   VARCHAR2,
      p_change_data   IN   VARCHAR2,
      p_summary_id    IN   NUMBER
   )
    /******************************************************************
   Created By         : SreeKrishna Vadde

   Date Created By    : Thursday, January 05, 2006

   Purpose            : Used to put and remove hold for a perticuler record

   Change History
   Who                  When            What
   vskumar		31-May-2006	Bug 5245394.Xbuild3 performance related fix. Replaced query and used bind parameters.
------------------------------------------------------------------------

******************************************************************/
   IS
      l_gen_xml_flg      BOOLEAN                            := TRUE ;
      l_batch_id         igs_sv_batches.batch_id%TYPE;
	  l_tmp_btch_id	igs_sv_batches.batch_id%TYPE;
      l_batch_rec        igs_sv_batches%ROWTYPE;
      l_person_rec       igs_sv_persons%ROWTYPE;
      l_tbl_name         VARCHAR2 (30);
      l_extra_criteria   VARCHAR2 (100);
      l_rec_count        NUMBER;
      l_query		 VARCHAR2(2000);
	  l_pers_status igs_sv_persons.record_status%TYPE;
	  l_batch_status igs_sv_batches.BATCH_TYPE%TYPE;

      CURSOR batch_crsr (cp_batch_id NUMBER)
      IS
         SELECT *
           FROM igs_sv_batches
          WHERE batch_id = cp_batch_id;

	CURSOR c_batch_type (cp_batch_id NUMBER)
      IS
         SELECT BATCH_TYPE
           FROM igs_sv_batches
          WHERE batch_id = cp_batch_id;

	CURSOR pers_rec_status (cp_person_id NUMBER,cp_batch_id NUMBER)
	  IS
		select
			record_status
		from igs_sv_persons
			where person_id = cp_person_id and batch_id = cp_batch_id;

   BEGIN
      SAVEPOINT batch_sav_pnt;

      IF p_change_data = 'HOLD' THEN
         UPDATE igs_sv_btch_summary
            SET adm_action_code = 'HOLD',
                last_update_date = SYSDATE,
                last_update_login = fnd_global.user_id
          WHERE summary_id = p_summary_id;

         RETURN;
      END IF;

      OPEN batch_crsr (p_batch_id);
      FETCH batch_crsr INTO l_batch_rec;
      CLOSE batch_crsr;

      IF l_batch_rec.batch_status = 'S' THEN
         l_batch_id := l_batch_rec.batch_id;
         l_gen_xml_flg := FALSE ;
      --
     /* ELSIF l_batch_rec.batch_status = 'X' THEN
         l_batch_id := l_batch_rec.batch_id;
      --*/
      ELSE
         --select igs_sv_batches_id_s.NEXTVAL into :i from dual;
        l_batch_id := open_new_batch(p_person_id,p_batch_id,'HOLD');
      END IF;

--	my_dbg('Before First Cursor - l_batch_rec.batch_status : ', l_batch_rec.batch_status);

	OPEN pers_rec_status (p_person_id,p_batch_id);
      FETCH pers_rec_status INTO l_pers_status;
    CLOSE pers_rec_status;

--	my_dbg('After First Cursor - l_pers_status : ',l_pers_status);

	IF ( l_pers_status = 'N'  AND l_batch_rec.batch_status <> 'S' ) THEN
--		my_dbg('After New And Not S ','Came after');
		OPEN c_batch_type (p_batch_id);
		  FETCH c_batch_type INTO l_batch_status;
		CLOSE c_batch_type;

--		my_dbg('After New And Not S - l_batch_status : ',l_batch_status);

		IF( (l_batch_status  = 'I' AND (p_info_key = 'SV_BIO'  OR  p_info_key = 'SV_F_ADDR'  OR p_info_key = 'SV_PRGMS'  OR p_info_key = 'SV_FINANCIAL' ) )
		OR (l_batch_status  = 'E' AND (p_info_key = 'SV_BIO'  OR  p_info_key = 'SV_PRGMS'  OR p_info_key = 'SV_US_ADDR'  OR p_info_key = 'SV_SOA'  OR p_info_key = 'SV_FINANCIAL' ) ) )
		THEN

--		my_dbg('Inside Last IF : ',p_info_key);

			FOR c_data_rec IN ( select SUMMARY_ID,
						BATCH_ID,
						PERSON_ID,
						ACTION_CODE ,
						TAG_CODE,
						ADM_ACTION_CODE ,
						OWNER_TABLE_NAME ,
						OWNER_TABLE_IDENTIFIER
					from igs_sv_btch_summary where batch_id = p_batch_id and person_id = p_person_id )

			LOOP
--				my_dbg('Inside  IF TAG_CODE : ',c_data_rec.TAG_CODE);

				UPDATE igs_sv_btch_summary
				 SET batch_id = l_batch_id,
					 adm_action_code = c_data_rec.ADM_ACTION_CODE,
					 last_update_date = SYSDATE,
					 last_update_login = fnd_global.user_id
			   WHERE summary_id = c_data_rec.summary_id;
--				my_dbg('After UPDATE c_data_rec.summary_id : ',c_data_rec.summary_id);
				get_tbl_extra_params (
					 c_data_rec.tag_code,
					 c_data_rec.owner_table_identifier,
					 l_tbl_name,
					 l_extra_criteria
				  );

--				  my_dbg('After get_tbl_extra_params  l_tbl_name : ',l_tbl_name);
--				  my_dbg('After get_tbl_extra_params  l_extra_criteria : ',l_extra_criteria);

				  IF l_extra_criteria IS NOT NULL THEN
					  l_query := 'UPDATE ' || l_tbl_name ||' set BATCH_ID = :l_batch_id where BATCH_ID = :p_batch_id and person_id = :p_person_id'|| l_extra_criteria;
					  EXECUTE IMMEDIATE l_query USING l_batch_id , p_batch_id, p_person_id, c_data_rec.owner_table_identifier;
				  ELSE
					  l_query := 'UPDATE ' || l_tbl_name ||' set BATCH_ID = :l_batch_id where BATCH_ID = :p_batch_id and person_id = :p_person_id';
					  EXECUTE IMMEDIATE l_query USING l_batch_id , p_batch_id, p_person_id;
				  END IF;

			END LOOP;
		END IF;
	END IF;

	  UPDATE igs_sv_btch_summary
		 SET batch_id = l_batch_id,
			 adm_action_code = 'SEND',
			 last_update_date = SYSDATE,
			 last_update_login = fnd_global.user_id
	   WHERE summary_id = p_summary_id;

	  get_tbl_extra_params (
		 p_info_key,
		 p_extra_param,
		 l_tbl_name,
		 l_extra_criteria
	  );

	  IF l_extra_criteria IS NOT NULL THEN
		  l_query := 'UPDATE ' || l_tbl_name ||' set BATCH_ID = :l_batch_id where BATCH_ID = :p_batch_id and person_id = :p_person_id'
			   || l_extra_criteria;
		  EXECUTE IMMEDIATE l_query USING l_batch_id , p_batch_id, p_person_id, p_extra_param;
	  ELSE
		  l_query := 'UPDATE ' || l_tbl_name ||' set BATCH_ID = :l_batch_id where BATCH_ID = :p_batch_id and person_id = :p_person_id';
		  EXECUTE IMMEDIATE l_query USING l_batch_id , p_batch_id, p_person_id;
	  END IF;


   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK TO batch_sav_pnt;

         IF fnd_log.test (fnd_log.level_statement, 'igs.plsql.IGS_SV_UTIL')
         THEN
            fnd_log.string_with_context (
               fnd_log.level_statement,
               'igs.plsql.igs_sv_util.change_record_status',
               'Exception in unhold_record. ' || SQLERRM,NULL,NULL,NULL,NULL,NULL,NULL
            );
         END IF;
   END;


  FUNCTION open_new_batch(p_person_id number, p_batch_id number, p_caller varchar2)
	return number is
	 /******************************************************************
   Created By         : SreeKrishna Vadde

   Date Created By    : Thursday, January 05, 2006

   Purpose            : Creates a new batch with same info as the current abtch and returns the new batch id

   Internal

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
	  l_batch_id         igs_sv_batches.batch_id%TYPE;
      l_batch_rec        igs_sv_batches%ROWTYPE;
      l_person_rec       igs_sv_persons%ROWTYPE;
      l_rec_count        NUMBER;

      CURSOR batch_crsr (cp_batch_id NUMBER)
      IS
         SELECT *
           FROM igs_sv_batches
          WHERE batch_id = cp_batch_id;

      CURSOR person_crsr (cp_person_id NUMBER, cp_batch_id NUMBER)
      IS
         SELECT *
           FROM igs_sv_persons
          WHERE batch_id = cp_batch_id AND person_id = cp_person_id;

      CURSOR chk_rec_count_crsr (cp_person_id NUMBER, cp_batch_id NUMBER)
      IS
         SELECT COUNT (*)
           FROM igs_sv_btch_summary
          WHERE batch_id = cp_batch_id AND person_id = cp_person_id;

BEGIN
	      OPEN batch_crsr (p_batch_id);
			 FETCH batch_crsr INTO l_batch_rec;
		  CLOSE batch_crsr;

		 SELECT igs_sv_batches_id_s.NEXTVAL INTO l_batch_id from dual;

         INSERT INTO igs_sv_batches
                     (batch_id, schema_version,
                      sevis_user_id, sevis_school_id,
                      batch_status, batch_type, creation_date,
                      created_by, last_updated_by,
                      last_update_date, last_update_login,
                      sevis_error_code,
                      xml_gen_date,
                      inbound_process_date,
		      sevis_school_org_id,
		      sevis_user_person_id)
              VALUES (l_batch_id, l_batch_rec.schema_version,
                      l_batch_rec.sevis_user_id, l_batch_rec.sevis_school_id,
                      'S', l_batch_rec.batch_type, SYSDATE,
                      l_batch_rec.created_by, l_batch_rec.last_updated_by,
                      SYSDATE, l_batch_rec.last_update_login,
                      l_batch_rec.sevis_error_code,
                      l_batch_rec.xml_gen_date,
                      l_batch_rec.inbound_process_date,
		      l_batch_rec.sevis_school_org_id,
		      l_batch_rec.sevis_user_person_id);

         OPEN person_crsr (p_person_id, p_batch_id);
         FETCH person_crsr INTO l_person_rec;
         CLOSE person_crsr;
         OPEN chk_rec_count_crsr (p_person_id, p_batch_id);
         FETCH chk_rec_count_crsr INTO l_rec_count;
         CLOSE chk_rec_count_crsr;

         IF (l_rec_count = 1 and p_caller <> 'CONN_JOB')
         THEN
            UPDATE igs_sv_persons
               SET batch_id = l_batch_id
             WHERE batch_id = p_batch_id AND person_id = p_person_id;
         ELSE
            INSERT INTO igs_sv_persons
                        (batch_id, person_id,
                         record_number, form_id,
                         print_form, pdso_sevis_id,
                         record_status,
                         person_number,
                         sevis_user_id,
                         issuing_reason,
                         curr_session_end_date,
                         next_session_start_date,
                         other_reason,
                         transfer_from_school,
                         ev_create_reason,
                         ev_form_number, creation_date,
                         created_by, last_updated_by, last_update_date,
                         last_update_login,
                         init_prgm_start_date,
                         sevis_error_code,
                         sevis_error_element,
                         no_show_flag, status_code,
                         last_session_flag,
                         adjudicated_flag,
                         REPRINT_RSN_CODE ,
                         reprint_remarks, remarks,
			 pdso_sevis_person_id)
                 VALUES (l_batch_id, l_person_rec.person_id,
                         l_person_rec.record_number, l_person_rec.form_id,
                         l_person_rec.print_form, l_person_rec.pdso_sevis_id,
                         l_person_rec.record_status,
                         l_person_rec.person_number,
                         l_person_rec.sevis_user_id,
                         l_person_rec.issuing_reason,
                         l_person_rec.curr_session_end_date,
                         l_person_rec.next_session_start_date,
                         l_person_rec.other_reason,
                         l_person_rec.transfer_from_school,
                         l_person_rec.ev_create_reason,
                         l_person_rec.ev_form_number, SYSDATE,
                         fnd_global.user_id, fnd_global.user_id, SYSDATE,
                         l_person_rec.last_update_login,
                         l_person_rec.init_prgm_start_date,
                         l_person_rec.sevis_error_code,
                         l_person_rec.sevis_error_element,
                         l_person_rec.no_show_flag, l_person_rec.status_code,
                         l_person_rec.last_session_flag,
                         l_person_rec.adjudicated_flag,
                         l_person_rec.REPRINT_RSN_CODE ,
                         l_person_rec.reprint_remarks, l_person_rec.remarks,
			 l_person_rec.pdso_sevis_person_id);
         END IF;

		return l_batch_id;
	END open_new_batch;


procedure create_Person_Rec(p_person_id number, p_old_batch_id number, p_new_batch_id number)
	is
	 /******************************************************************
   Created By         : SreeKrishna Vadde

   Date Created By    : Thursday, January 05, 2006

   Purpose            : Creates a new batch with same info as the current abtch and returns the new batch id

   Internal

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
	  l_batch_id         igs_sv_batches.batch_id%TYPE;
      l_batch_rec        igs_sv_batches%ROWTYPE;
      l_person_rec       igs_sv_persons%ROWTYPE;
      l_rec_count        NUMBER;


      CURSOR person_crsr (cp_person_id NUMBER, cp_batch_id NUMBER)
      IS
         SELECT *
           FROM igs_sv_persons
          WHERE batch_id = cp_batch_id AND person_id = cp_person_id;

BEGIN

         OPEN person_crsr (p_person_id, p_old_batch_id);
         FETCH person_crsr INTO l_person_rec;
         CLOSE person_crsr;

            INSERT INTO igs_sv_persons
                        (batch_id, person_id,
                         record_number, form_id,
                         print_form, pdso_sevis_id,
                         record_status,
                         person_number,
                         sevis_user_id,
                         issuing_reason,
                         curr_session_end_date,
                         next_session_start_date,
                         other_reason,
                         transfer_from_school,
                         ev_create_reason,
                         ev_form_number, creation_date,
                         created_by, last_updated_by, last_update_date,
                         last_update_login,
                         init_prgm_start_date,
                         sevis_error_code,
                         sevis_error_element,
                         no_show_flag, status_code,
                         last_session_flag,
                         adjudicated_flag,
                         REPRINT_RSN_CODE ,
                         reprint_remarks, remarks)
                 VALUES (p_new_batch_id, l_person_rec.person_id,
                         l_person_rec.record_number, l_person_rec.form_id,
                         l_person_rec.print_form, l_person_rec.pdso_sevis_id,
                         l_person_rec.record_status,
                         l_person_rec.person_number,
                         l_person_rec.sevis_user_id,
                         l_person_rec.issuing_reason,
                         l_person_rec.curr_session_end_date,
                         l_person_rec.next_session_start_date,
                         l_person_rec.other_reason,
                         l_person_rec.transfer_from_school,
                         l_person_rec.ev_create_reason,
                         l_person_rec.ev_form_number, SYSDATE,
                         fnd_global.user_id, fnd_global.user_id, SYSDATE,
                         l_person_rec.last_update_login,
                         l_person_rec.init_prgm_start_date,
                         l_person_rec.sevis_error_code,
                         l_person_rec.sevis_error_element,
                         l_person_rec.no_show_flag, l_person_rec.status_code,
                         l_person_rec.last_session_flag,
                         l_person_rec.adjudicated_flag,
                         l_person_rec.REPRINT_RSN_CODE ,
                         l_person_rec.reprint_remarks, l_person_rec.remarks);

	END create_Person_Rec;


  FUNCTION GET_BTCH_PROCESS_DT(
      p_person_id igs_sv_prgms_info.person_id%TYPE,
      p_sevis_auth_id igs_sv_prgms_info.sevis_auth_id%TYPE
 ) RETURN DATE IS
  /******************************************************************
   Created By         : Manoj Kumar

   Date Created By    : Thursday, January 05, 2006

   Purpose            : It returns Process date

   Internal

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
    CURSOR c_btch_date IS
      SELECT MAX(prgm.BATCH_ID) , btch.creation_date
      FROM igs_sv_prgms_info prgm, IGS_SV_BATCHES btch
      WHERE prgm.batch_id = btch.batch_id AND
      prgm.person_id = p_person_id AND
      prgm.sevis_auth_id = p_sevis_auth_id AND
      prgm.prgm_action_type = 'DB' AND
      btch.batch_status <> 'E'
      GROUP BY btch.creation_date;
      l_btch_date c_btch_date%ROWTYPE;
 BEGIN
      OPEN c_btch_date;
      FETCH c_btch_date INTO l_btch_date;
      IF c_btch_date%ROWCOUNT > 0 THEN
           CLOSE c_btch_date;
      RETURN l_btch_date.creation_date;
      END IF;
      CLOSE c_btch_date;
      RETURN NULL;
 EXCEPTION
   WHEN OTHERS THEN
      null;
 END GET_BTCH_PROCESS_DT;


PROCEDURE GET_PROGRAM_DATES(
      p_person_id IN igs_pe_nonimg_form.person_id%TYPE,
      p_prgm_end_date OUT NOCOPY igs_pe_nonimg_form.prgm_end_date%TYPE,
      p_prgm_start_date OUT NOCOPY igs_pe_nonimg_form.prgm_start_date%TYPE
 ) IS
  /******************************************************************
   Created By         : Preeti Bhardwaj

   Date Created By    : Monday, April 10, 2006

   Purpose            : It returns program dates

   Internal

   Change History
   Who                  When            What
------------------------------------------------------------------------

******************************************************************/
    CURSOR c_prg_dates(cp_form_id igs_pe_nonimg_form.nonimg_form_id%TYPE) IS
      SELECT prgm_start_date, prgm_end_date
      FROM igs_pe_nonimg_form ipnf
      WHERE ipnf.person_id = p_person_id AND
            ipnf.nonimg_form_id = cp_form_id;


    CURSOR c_action_date(cp_form_id igs_pe_nonimg_form.nonimg_form_id%TYPE) IS
      SELECT prgm_start_date prgm_start_date,
            prgm_end_date prgm_end_date
       FROM igs_pe_nonimg_stat
      WHERE nonimg_form_id = cp_form_id
      ORDER BY last_update_date DESC;

    CURSOR c_form_id IS
      SELECT nonimg_form_id
      FROM igs_pe_nonimg_form
      WHERE person_id = p_person_id AND
            form_status = 'A';

      l_prgm_end_date DATE;
      l_prgm_start_date DATE;
      l_temp_end_date DATE;
      l_temp_start_date DATE;
      l_form_id  igs_pe_nonimg_form.nonimg_form_id%TYPE := 0;

 BEGIN
	OPEN c_form_id;
	FETCH c_form_id INTO l_form_id;
	CLOSE c_form_id;

	FOR c_action_date_rec IN c_action_date(l_form_id) LOOP
	     IF c_action_date_rec.prgm_end_date IS NOT NULL AND l_prgm_end_date IS NULL THEN
	            l_prgm_end_date := c_action_date_rec.prgm_end_date;
	     END IF;
	     IF c_action_date_rec.prgm_start_date IS NOT NULL AND l_prgm_start_date IS NULL  THEN
	            l_prgm_start_date := c_action_date_rec.prgm_start_date;
	     END IF;
	     IF l_prgm_start_date IS NOT NULL AND l_prgm_end_date IS NOT NULL  THEN
	           EXIT;
	     END IF;

	END LOOP;

	OPEN c_prg_dates(l_form_id);
	FETCH c_prg_dates INTO l_temp_start_date, l_temp_end_date;
	CLOSE c_prg_dates;

	IF l_prgm_start_date IS NULL THEN
	   l_prgm_start_date := l_temp_start_date;
	END IF;
	IF l_prgm_end_date IS NULL THEN
	   l_prgm_end_date := l_temp_end_date;
	END IF;
        p_prgm_end_date := l_prgm_end_date;
	p_prgm_start_date := l_prgm_start_date;
 EXCEPTION
   WHEN OTHERS THEN
      null;
 END GET_PROGRAM_DATES;

END igs_sv_util;

/
