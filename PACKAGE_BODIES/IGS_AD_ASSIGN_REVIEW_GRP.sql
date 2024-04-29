--------------------------------------------------------
--  DDL for Package Body IGS_AD_ASSIGN_REVIEW_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_ASSIGN_REVIEW_GRP" AS
/* $Header: IGSADB3B.pls 120.4 2006/02/23 06:21:21 arvsrini noship $ */

-- declaring constants for the inclusion and exclusion indicator
  g_incl_ind         CONSTANT VARCHAR2(1) := 'I';
  g_excl_ind         CONSTANT VARCHAR2(1) := 'E';

PROCEDURE assign_review_group(
	ERRBUF                         OUT NOCOPY VARCHAR2,
        RETCODE                        OUT NOCOPY NUMBER,
	P_APPL_REV_PROFILE_ID          IN NUMBER,
	P_ENTRY_STAT_ID                IN NUMBER,
	P_NOMINATED_COURSE_CD          IN VARCHAR2,
	P_PERSON_ID                    IN NUMBER,
	P_UNIT_SET_CD                  IN VARCHAR2,
	P_CALENDAR_DETAILS             IN VARCHAR2,
	P_ADMISSION_PROCESS_CATEGORY   IN VARCHAR2,
        P_ORG_ID                       IN NUMBER)
AS
 /*************************************************************
  Created By :samaresh
  Date : 09-NOV-2001
  Created By : Sandhya.Amaresh
  Purpose : This Procedure Assigns Review Groups to Applications
  that havent been assigned Review Groups
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ***************************************************************/

  -- Cursor to fetch the Review Profile Grouping Code given the
  -- Review Profile Id
  CURSOR c_appl_revprof_group_cd(cp_appl_rev_profile_id NUMBER) IS
    SELECT appl_rev_profile_gr_cd,site_use_code,review_profile_name
    FROM igs_ad_apl_rev_prf_all
    WHERE appl_rev_profile_id = cp_appl_rev_profile_id;

  -- Cursor to fetch the Review Group Id, Review Group Code, given
  -- the Review Profile Id
  CURSOR c_appl_revprof_revgr(cp_appl_rev_profile_id NUMBER) IS
    SELECT appl_revprof_revgr_id,revprof_revgr_cd,revprof_revgr_name
    FROM igs_ad_apl_rprf_rgr
    WHERE appl_rev_profile_id = cp_appl_rev_profile_id
    ORDER BY appl_revprof_revgr_id;

  -- Cursor to fetch the Inclusion and Exclusion Values given
  -- the Review Group Id and the Inclusion Exclusion Indicator
  CURSOR c_revgr_incl_excl(cp_appl_revprof_revgr_id NUMBER,cp_incl_excl_ind VARCHAR2) IS
    SELECT *
    FROM igs_ad_rvgr_inc_exc
    WHERE appl_revprof_revgr_id = cp_appl_revprof_revgr_id
    AND incl_excl_ind = cp_incl_excl_ind;

  c_revgr_incl_excl_rec c_revgr_incl_excl%ROWTYPE;

  -- Cursor to fetch the Inclusion and Exclusion Values given
  -- the Review Group Id For the Address
  CURSOR c_revgr_addr(cp_appl_revprof_revgr_id NUMBER) IS
    SELECT *
    FROM igs_ad_rvgr_inc_exc
    WHERE appl_revprof_revgr_id = cp_appl_revprof_revgr_id ;

  c_revgr_addr_rec c_revgr_addr%ROWTYPE;

  CURSOR c_arp_rec_found (cp_person_id NUMBER,cp_admission_appl_number NUMBER,
          cp_nominated_course_cd VARCHAR2,cp_sequence_number NUMBER) IS
    SELECT rowid,arp.*
    FROM igs_ad_appl_arp arp
    WHERE person_id = cp_person_id
    AND admission_appl_number = cp_admission_appl_number
    AND nominated_course_cd = cp_nominated_course_cd
    AND sequence_number = cp_sequence_number;

  TYPE rec_persondetail IS RECORD (
    person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
    admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
    nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
    sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE);

  TYPE rec_persondet_addr IS RECORD (
    person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
    admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
    nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
    sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE,
    country igs_or_inst_addr.country%TYPE,
    state igs_or_inst_addr.state%TYPE,
    postal_code igs_or_inst_addr.postal_code%TYPE);

  TYPE c_ref IS REF CURSOR ;

  l_include_where VARCHAR2(2000) DEFAULT NULL;
  l_surname_include_where VARCHAR2(2000) DEFAULT NULL;
  l_curr_inst_addr_include_where VARCHAR2(2000) DEFAULT NULL;
  l_exclude_where VARCHAR2(2000) DEFAULT NULL;
  l_surname_exclude_where VARCHAR2(2000) DEFAULT NULL;
  l_curr_inst_addr_exclude_where VARCHAR2(2000) DEFAULT NULL;
  l_applicant_addr_exclude_where VARCHAR2(2000) DEFAULT NULL;
  l_applicant_addr_include_where VARCHAR2(2000) DEFAULT NULL;
  l_market_code_exclude_where VARCHAR2(2000) DEFAULT NULL;
  l_market_code_include_where VARCHAR2(2000) DEFAULT NULL;
  l_prog_of_study_include_where VARCHAR2(2000)DEFAULT NULL;
  l_organization_include_where VARCHAR2(2000)DEFAULT NULL;
  l_cal_detls_include_where VARCHAR2(2000) DEFAULT NULL;
  l_cur_statement VARCHAR2(4000);
  l_satisfied CONSTANT VARCHAR2(9) := 'SATISFIED';
  l_pending CONSTANT VARCHAR2(7) := 'PENDING';
  l_count_incl_excl NUMBER :=0;
  l_percentage_symbol CONSTANT VARCHAR2(1) :='%';
  l_cursor_id NUMBER(15);
  l_num_of_rows NUMBER(10);
  l_person_id			igs_ad_ps_appl_inst_all.person_id%TYPE;
  l_admission_appl_number	igs_ad_ps_appl_inst_all.admission_appl_number%TYPE;
  l_nominated_course_cd		igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE;
  l_sequence_number		igs_ad_ps_appl_inst_all.sequence_number%TYPE;
  l_debug  VARCHAR2(4000);


  l_admission_cat              igs_ad_appl_all.admission_cat%TYPE;
  l_s_admission_process_type   igs_ad_appl_all.s_admission_process_type%TYPE;
  l_acad_cal_type              igs_ca_inst_all.cal_type%TYPE;
  l_acad_ci_sequence_number    igs_ca_inst_all.sequence_number%TYPE;
  l_adm_cal_type               igs_ca_inst_all.cal_type%TYPE;
  l_adm_ci_sequence_number     igs_ca_inst_all.sequence_number%TYPE;
  l_country		       igs_or_inst_addr.country%TYPE;
  l_state		       igs_or_inst_addr.state%TYPE;
  l_postal_code		       igs_or_inst_addr.postal_code%TYPE;
  l_pe_country		       igs_pe_addr_v.country_cd%TYPE;
  l_pe_state		       igs_pe_addr_v.state%TYPE;
  l_pe_postal_code	       igs_pe_addr_v.postal_code%TYPE;


  l_addr_include_ind	BOOLEAN;
  l_addr_excluded_ind	BOOLEAN;

  c_appl_revprof_group_cd_rec c_appl_revprof_group_cd%ROWTYPE;

  c_incl_excl c_ref;
  c_appl_addr_rec rec_persondet_addr;
  c_appl_rec rec_persondetail;

  c_arp_rec_found_rec c_arp_rec_found%ROWTYPE;
  lv_rowid VARCHAR2(25);
  lv_appl_arp_id NUMBER(15);

BEGIN
  IGS_GE_GEN_003.Set_org_id(p_org_id);
  -- Check the Review Grouping Name
  -- If the Grouping is Alpabetical By Surname
  OPEN c_appl_revprof_group_cd(p_appl_rev_profile_id);
  FETCH c_appl_revprof_group_cd INTO c_appl_revprof_group_cd_rec;
  CLOSE c_appl_revprof_group_cd;

  -- Write the Profile Name to the log file
  FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
  FND_FILE.PUT_LINE(FND_FILE.LOG,LPAD(FND_MESSAGE.GET_STRING('IGS',
          'IGS_AD_APPL_PROF_NAME_PROC'),'27',' ')
          ||'    '|| c_appl_revprof_group_cd_rec.review_profile_name);
  FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

  -- Write the Calander Details to the log file
  FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_CL_DTLS');
  FND_MESSAGE.SET_TOKEN('CLDTLS', p_calendar_details);
  FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

  -- Write the Admission Process Cagtegory Details to the log file
  FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_APC');
  FND_MESSAGE.SET_TOKEN('APC', p_admission_process_category);
  FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

  IF p_admission_process_category IS NULL THEN
    l_admission_cat             := NULL;
    l_s_admission_process_type  := NULL;
  ELSE
    l_admission_cat             := RTRIM ( SUBSTR ( p_admission_process_category, 1, 10));
    l_s_admission_process_type  := TRIM ( SUBSTR ( p_admission_process_category, 11));
  END IF;


 IF c_appl_revprof_group_cd_rec.appl_rev_profile_gr_cd = 'ALPHA_SUR_NAME' THEN
    -- Open the cursor to fetch the Review Group Ids which belong to this
    -- particular Review Profile Id
  FOR c_appl_revprof_revgr_rec IN c_appl_revprof_revgr(p_appl_rev_profile_id) LOOP

    -- Write the Group Code to the log file
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,LPAD(FND_MESSAGE.GET_STRING('IGS',
                'IGS_AD_APPL_GRP_CD_PROC'),'27',' ') ||
		'    '||c_appl_revprof_revgr_rec.revprof_revgr_name);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,LPAD(FND_MESSAGE.GET_STRING('IGS',
                'IGS_AD_PERSON_ID'),'20',' ')||LPAD(FND_MESSAGE.GET_STRING('IGS',
                'IGS_AD_APPL_NO'),'20',' ')
	        ||LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_CRS_CD'),'20',' ')||
                LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_SEQ_NUM'),'20',' '));


    l_cur_statement := NULL;

    -- Check if there are any include or exclude records for the Group id.
    OPEN c_revgr_incl_excl(c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
               g_incl_ind);
    FETCH c_revgr_incl_excl INTO  c_revgr_incl_excl_rec;
    IF c_revgr_incl_excl%FOUND THEN
    CLOSE c_revgr_incl_excl;

	fnd_dsql.init;
        fnd_dsql.add_text('SELECT apl.person_id,apl.admission_appl_number,apl.nominated_course_cd,apl.sequence_number ');
	fnd_dsql.add_text('FROM hz_parties pe, igs_ad_ps_appl_inst_all apl, igs_ad_appl_all app,igs_ad_doc_stat doc, igs_ad_ou_stat ou ');
	fnd_dsql.add_text('WHERE pe.party_id = apl.person_id AND doc.s_adm_doc_status = ');
        fnd_dsql.add_bind(l_satisfied);
	fnd_dsql.add_text(' AND ou.s_adm_outcome_status = ');
	fnd_dsql.add_bind(l_pending);
	fnd_dsql.add_text(' AND doc.adm_doc_status = apl.adm_doc_status ');
	fnd_dsql.add_text('AND ou.adm_outcome_status = apl.adm_outcome_status AND ((');

	fnd_dsql.add_bind(p_entry_stat_id);
	fnd_dsql.add_text(' IS NOT NULL AND apl.entry_status = ');
	fnd_dsql.add_bind(p_entry_stat_id);
	fnd_dsql.add_text(' ) OR ');
	fnd_dsql.add_bind(p_entry_stat_id);
	fnd_dsql.add_text(' IS NULL ) AND ((');

	fnd_dsql.add_bind(p_nominated_course_cd);
	fnd_dsql.add_text(' IS NOT NULL AND apl.nominated_course_cd = ');
	fnd_dsql.add_bind(p_nominated_course_cd);
	fnd_dsql.add_text(' ) OR ');
	fnd_dsql.add_bind(p_nominated_course_cd);
	fnd_dsql.add_text(' IS NULL ) AND ((');

	fnd_dsql.add_bind(p_person_id);
	fnd_dsql.add_text(' IS NOT NULL AND apl.person_id = ');
	fnd_dsql.add_bind(p_person_id);
	fnd_dsql.add_text(' ) OR ');
	fnd_dsql.add_bind(p_person_id);
	fnd_dsql.add_text(' IS NULL ) AND ((');

	fnd_dsql.add_bind(p_unit_set_cd);
	fnd_dsql.add_text(' IS NOT NULL AND apl.unit_set_cd = ');
	fnd_dsql.add_bind(p_unit_set_cd);
	fnd_dsql.add_text(' ) OR ');
	fnd_dsql.add_bind(p_unit_set_cd);
	fnd_dsql.add_text(' IS NULL ) AND ((');

	fnd_dsql.add_bind(l_admission_cat);
	fnd_dsql.add_text(' IS NOT NULL AND app.admission_cat = ');
	fnd_dsql.add_bind(l_admission_cat);
	fnd_dsql.add_text(' ) OR ');
	fnd_dsql.add_bind(l_admission_cat);
	fnd_dsql.add_text(' IS NULL ) AND ((');

	fnd_dsql.add_bind(l_s_admission_process_type);
	fnd_dsql.add_text(' IS NOT NULL AND app.s_admission_process_type = ');
	fnd_dsql.add_bind(l_s_admission_process_type);
	fnd_dsql.add_text(' ) OR ');
	fnd_dsql.add_bind(l_s_admission_process_type);
	fnd_dsql.add_text(' IS NULL ) AND ');

	fnd_dsql.add_text('apl.person_id = app.person_id AND apl.admission_appl_number = app.admission_appl_number');

	IF p_calendar_details IS NOT NULL THEN
	  -- Get the Academic Calander details form the Academic Calender Parameter
	  l_acad_cal_type		:= RTRIM ( SUBSTR ( p_calendar_details, 1, 10));
	  l_acad_ci_sequence_number   := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 14, 6));

	  -- Get the Admission Calander details form the Admission Calender Parameter
	  l_adm_cal_type              := RTRIM ( SUBSTR ( p_calendar_details, 23, 10));
	  l_adm_ci_sequence_number    := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 37, 6));


	  IF l_acad_cal_type IS NULL OR l_acad_ci_sequence_number IS NULL OR l_adm_cal_type IS NULL OR l_adm_ci_sequence_number IS NULL THEN
	   fnd_dsql.add_text(' 1=2 ' );
	  ELSE
           fnd_dsql.add_text(' AND app.acad_cal_type = ');
           fnd_dsql.add_bind(l_acad_cal_type);

	   fnd_dsql.add_text(' AND app.acad_ci_sequence_number = ');
           fnd_dsql.add_bind(l_acad_ci_sequence_number);

	   fnd_dsql.add_text(' AND app.adm_cal_type = ');
           fnd_dsql.add_bind(l_adm_cal_type);

	   fnd_dsql.add_text(' AND app.adm_ci_sequence_number = ');
           fnd_dsql.add_bind(l_adm_ci_sequence_number);

	  END IF;
	END IF;

	OPEN c_revgr_incl_excl(c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
               g_excl_ind);
	FETCH c_revgr_incl_excl INTO  c_revgr_incl_excl_rec;
	IF c_revgr_incl_excl%FOUND THEN
		CLOSE c_revgr_incl_excl;

		fnd_dsql.add_text(' AND pe.person_last_name IN ( ( SELECT person_last_name ');
		fnd_dsql.add_text(' FROM hz_parties WHERE ');

		l_count_incl_excl:=0;

		-- Open a cursor to fetch all the include Records and combine them to form a where clause
		FOR c_revgr_incl_excl_rec IN c_revgr_incl_excl(c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
			g_incl_ind) LOOP
			IF (l_count_incl_excl > 0) THEN
				fnd_dsql.add_text(' OR ');
			END IF;

			fnd_dsql.add_text(' ((UPPER(person_last_name) BETWEEN NVL(UPPER( ');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.start_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ) AND NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.end_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ) ) OR UPPER(person_last_name) LIKE NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.end_value);
			fnd_dsql.add_text('),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ))');

			l_count_incl_excl:=l_count_incl_excl+1;

		END LOOP;


		fnd_dsql.add_text(' )');

		l_count_incl_excl:=0;
		fnd_dsql.add_text(' MINUS  ( SELECT person_last_name FROM hz_parties WHERE ');

   		-- Open a cursor to fetch all the exclusion Records and combine them to form a where clause
		FOR c_revgr_incl_excl_rec IN c_revgr_incl_excl(c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
			g_excl_ind) LOOP

			IF (l_count_incl_excl > 0) THEN
				fnd_dsql.add_text(' OR ');
			END IF;

	  		fnd_dsql.add_text(' ((UPPER(person_last_name) BETWEEN NVL(UPPER( ');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.start_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ) AND NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.end_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ) ) OR UPPER(person_last_name) LIKE NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.end_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ))');

			l_count_incl_excl:=l_count_incl_excl+1;
		END LOOP;

		fnd_dsql.add_text(' ))');
		l_count_incl_excl:=0;


	 ELSE
		CLOSE c_revgr_incl_excl;
		fnd_dsql.add_text(' AND pe.person_last_name IN ( SELECT person_last_name ');
		fnd_dsql.add_text(' FROM hz_parties WHERE ');

		FOR c_revgr_incl_excl_rec IN c_revgr_incl_excl(c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
			g_incl_ind) LOOP
			IF (l_count_incl_excl > 0) THEN
			  fnd_dsql.add_text(' OR ');
			END IF;
			fnd_dsql.add_text(' ((UPPER(person_last_name) BETWEEN NVL(UPPER( ');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.start_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ) AND NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.end_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ) ) OR UPPER(person_last_name) LIKE NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.end_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ))');

			l_count_incl_excl:=l_count_incl_excl+1;

		END LOOP;

		l_count_incl_excl:=0;
		fnd_dsql.add_text(' )');

	END IF; -- End of checking presence of exclude records

	l_cur_statement := fnd_dsql.get_text(FALSE);
        l_cursor_id := dbms_sql.open_cursor;
        fnd_dsql.set_cursor(l_cursor_id);

        dbms_sql.parse(l_cursor_id, l_cur_statement, dbms_sql.native);
        fnd_dsql.do_binds;

        dbms_sql.define_column(l_cursor_id, 1, l_person_id);
	dbms_sql.define_column(l_cursor_id, 2, l_admission_appl_number);
	dbms_sql.define_column(l_cursor_id, 3, l_nominated_course_cd, 6);
	dbms_sql.define_column(l_cursor_id, 4, l_sequence_number);


        l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id);

        LOOP
	    EXIT WHEN dbms_sql.FETCH_ROWS(l_cursor_id) = 0;
            dbms_sql.column_value(l_cursor_id, 1, l_person_id);
	    dbms_sql.column_value(l_cursor_id, 2, l_admission_appl_number);
	    dbms_sql.column_value(l_cursor_id, 3, l_nominated_course_cd);
	    dbms_sql.column_value(l_cursor_id, 4, l_sequence_number);

           OPEN  c_arp_rec_found(l_person_id, l_admission_appl_number, l_nominated_course_cd, l_sequence_number);
           FETCH c_arp_rec_found INTO c_arp_rec_found_rec;
	   IF c_arp_rec_found%NOTFOUND THEN
	     -- Insert Using TableHandler
	     lv_rowid := NULL;
	     lv_appl_arp_id := NULL;
             igs_ad_appl_arp_pkg.insert_row (
		   x_rowid => lv_rowid,
		   x_appl_arp_id => lv_appl_arp_id,
		   x_person_id => l_person_id,
		   x_admission_appl_number => l_admission_appl_number,
		   x_nominated_course_cd => l_nominated_course_cd,
		   x_sequence_number     => l_sequence_number,
		   x_appl_rev_profile_id => p_appl_rev_profile_id,
                   x_appl_revprof_revgr_id => c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
                   x_mode => 'R');

	     -- Write the Application Instance which got Assigned to a
	     -- Particular Review Code to the Log file
	     FND_FILE.PUT_LINE(FND_FILE.LOG,LPAD(IGS_GE_NUMBER.TO_CANN(l_person_id),'20',' ')||
		        LPAD(IGS_GE_NUMBER.TO_CANN(l_admission_appl_number),'20',' ')||
			LPAD(l_nominated_course_cd,'15',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(l_sequence_number),'20',' '));
	   ELSIF c_arp_rec_found_rec.appl_revprof_revgr_id IS NULL THEN
	     -- Update Using Table Handler
	     igs_ad_appl_arp_pkg.update_row (
		   x_rowid => c_arp_rec_found_rec.rowid,
		   x_appl_arp_id => c_arp_rec_found_rec.appl_arp_id,
		   x_person_id => c_arp_rec_found_rec.person_id,
		   x_admission_appl_number => c_arp_rec_found_rec.admission_appl_number,
		   x_nominated_course_cd => c_arp_rec_found_rec.nominated_course_cd,
		   x_sequence_number     => c_arp_rec_found_rec.sequence_number,
		   x_appl_rev_profile_id => p_appl_rev_profile_id,
                   x_appl_revprof_revgr_id => c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
                   x_mode => 'R');

  	     -- Write the Application Instance which got Assigned to a
	     --Particular Review Code to the Log file
	     FND_FILE.PUT_LINE(FND_FILE.LOG,LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.person_id),'20',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.admission_appl_number),'20',' ')||
			LPAD(c_arp_rec_found_rec.nominated_course_cd,'20',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.sequence_number),'20',' '));
           END IF;
           CLOSE c_arp_rec_found;


        END LOOP;
        dbms_sql.close_cursor(l_cursor_id);

    -- No include or exclude Records for this Group Code
    ELSE
      CLOSE c_revgr_incl_excl;
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_NO_REC_FOUND'));
    END IF;
    -- Loop through the next Review Group Code for the Profile ID
    END LOOP;






  -- Check if the Review Group Code is Geographical by Insitution Address
  ELSIF c_appl_revprof_group_cd_rec.appl_rev_profile_gr_cd = 'GEO_BY_INSTITUTION_ADDR' THEN
    FOR c_appl_revprof_revgr_rec IN c_appl_revprof_revgr(p_appl_rev_profile_id) LOOP
      -- Write the Group Code to the log file
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_GRP_CD_PROC'),'27',' ') ||
	        '    ' ||c_appl_revprof_revgr_rec.revprof_revgr_name);
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_PERSON_ID'),'20',' ')||
	        LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_NO'),'20',' ')
		||LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_CRS_CD'),'20',' ')||
		LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_SEQ_NUM'),'20',' '));

      l_cur_statement := NULL;

      -- Check if there are any include or exclude records for the Group id.
      OPEN c_revgr_addr(c_appl_revprof_revgr_rec.appl_revprof_revgr_id);
      FETCH c_revgr_addr INTO c_revgr_addr_rec;
      IF c_revgr_addr%FOUND THEN
      CLOSE c_revgr_addr;

	fnd_dsql.init;
	fnd_dsql.add_text('SELECT apl.person_id,apl.admission_appl_number, apl.nominated_course_cd, apl.sequence_number, addr.country, addr.state ,addr.postal_code');
	fnd_dsql.add_text(' FROM igs_pe_hz_parties hp, igs_ad_ps_appl_inst_all apl, igs_ad_appl_all app, igs_ad_doc_stat doc, igs_ad_ou_stat ou, igs_or_inst_addr addr, igs_ad_acad_history_v aah ');
	fnd_dsql.add_text(' WHERE hp.party_id = apl.person_id  AND hp.party_id = aah.person_id AND aah.CURRENT_INST = ');
	fnd_dsql.add_bind('Y');
	fnd_dsql.add_text(' AND aah.institution_code = addr.institution_cd AND addr.addr_type = ' );
	fnd_dsql.add_bind(c_appl_revprof_group_cd_rec.site_use_code);
	fnd_dsql.add_text(' AND doc.s_adm_doc_status = ');
	fnd_dsql.add_bind(l_satisfied);
	fnd_dsql.add_text(' AND ou.s_adm_outcome_status = ');
	fnd_dsql.add_bind(l_pending);
	fnd_dsql.add_text(' AND doc.adm_doc_status = apl.adm_doc_status AND ou.adm_outcome_status = apl.adm_outcome_status AND (( ');

	fnd_dsql.add_bind(p_entry_stat_id);
	fnd_dsql.add_text(' IS NOT NULL AND apl.entry_status = ' );
	fnd_dsql.add_bind(p_entry_stat_id);
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_entry_stat_id );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(p_nominated_course_cd );
	fnd_dsql.add_text(' IS NOT NULL AND apl.nominated_course_cd = ');
	fnd_dsql.add_bind(p_nominated_course_cd);
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_nominated_course_cd );
	fnd_dsql.add_text(' IS NULL )  AND (( ');

	fnd_dsql.add_bind(p_person_id );
	fnd_dsql.add_text(' IS NOT NULL AND apl.person_id = ' );
	fnd_dsql.add_bind(p_person_id );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_person_id );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(p_unit_set_cd );
	fnd_dsql.add_text(' IS NOT NULL AND apl.unit_set_cd = ');
	fnd_dsql.add_bind(p_unit_set_cd);
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_unit_set_cd );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(l_admission_cat );
	fnd_dsql.add_text(' IS NOT NULL AND app.admission_cat = ' );
	fnd_dsql.add_bind(l_admission_cat );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(l_admission_cat );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(l_s_admission_process_type );
	fnd_dsql.add_text(' IS NOT NULL AND app.s_admission_process_type = ' );
	fnd_dsql.add_bind(l_s_admission_process_type);
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(l_s_admission_process_type );

	fnd_dsql.add_text(' IS NULL ) AND apl.person_id = app.person_id AND apl.admission_appl_number = app.admission_appl_number ');

	IF p_calendar_details IS NOT NULL THEN
	  -- Get the Academic Calander details form the Academic Calender Parameter
	  l_acad_cal_type		:= RTRIM ( SUBSTR ( p_calendar_details, 1, 10));
	  l_acad_ci_sequence_number   := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 14, 6));

	  -- Get the Admission Calander details form the Admission Calender Parameter
	  l_adm_cal_type              := RTRIM ( SUBSTR ( p_calendar_details, 23, 10));
	  l_adm_ci_sequence_number    := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 37, 6));


	  IF l_acad_cal_type IS NULL OR l_acad_ci_sequence_number IS NULL OR l_adm_cal_type IS NULL OR l_adm_ci_sequence_number IS NULL THEN
	   fnd_dsql.add_text(' 1=2 ' );
	  ELSE
           fnd_dsql.add_text(' AND app.acad_cal_type = ');
           fnd_dsql.add_bind(l_acad_cal_type);

	   fnd_dsql.add_text(' AND app.acad_ci_sequence_number = ');
           fnd_dsql.add_bind(l_acad_ci_sequence_number);

	   fnd_dsql.add_text(' AND app.adm_cal_type = ');
           fnd_dsql.add_bind(l_adm_cal_type);

	   fnd_dsql.add_text(' AND app.adm_ci_sequence_number = ');
           fnd_dsql.add_bind(l_adm_ci_sequence_number);

	  END IF;
	END IF;

	l_addr_include_ind := FALSE;
	l_addr_excluded_ind := FALSE;

	FOR c_revgr_addr_rec IN c_revgr_addr(c_appl_revprof_revgr_rec.appl_revprof_revgr_id)
	LOOP
		 IF c_revgr_addr_rec.incl_excl_ind IS NULL OR c_revgr_addr_rec.incl_excl_ind = 'I' THEN
			l_addr_include_ind := TRUE;
		 ELSIF c_revgr_addr_rec.postal_incl_excl_ind = 'E' THEN
			l_addr_excluded_ind := TRUE;
		 END IF;

	END LOOP;

	IF (l_addr_include_ind) /*IS TRUE */THEN

		fnd_dsql.add_text(' AND (');
		l_count_incl_excl:=0;

		FOR c_revgr_addr_rec IN c_revgr_addr(c_appl_revprof_revgr_rec.appl_revprof_revgr_id)
		LOOP
		-- If the Current Record had include for the State
		IF c_revgr_addr_rec.incl_excl_ind IS NULL THEN

			IF (l_count_incl_excl > 0) THEN
			  fnd_dsql.add_text(' OR ');
			END IF;

			fnd_dsql.add_text(' (');

			fnd_dsql.add_text(' addr.country = ');
			fnd_dsql.add_bind(c_revgr_addr_rec.country);

			-- If the Current Record had include for the Postal Code
			IF c_revgr_addr_rec.postal_incl_excl_ind = 'I' THEN
				fnd_dsql.add_text(' AND ( UPPER(addr.postal_code) BETWEEN NVL(UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_start_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) AND NVL( UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) OR addr.postal_code LIKE ');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value );
				fnd_dsql.add_text(' )');


			-- If the Current Recode had exclude for the Postal Code
			ELSIF c_revgr_addr_rec.postal_incl_excl_ind = 'E' THEN
	                        fnd_dsql.add_text(' AND (UPPER(addr.postal_code) NOT BETWEEN NVL(UPPER(');
		                fnd_dsql.add_bind(c_revgr_addr_rec.postal_start_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) AND  NVL(UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) AND addr.postal_code NOT LIKE ');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value);
				fnd_dsql.add_text(' )');
			END IF;

			fnd_dsql.add_text(' )');
			l_count_incl_excl:=l_count_incl_excl+1;


		ELSIF c_revgr_addr_rec.incl_excl_ind = 'I' THEN

			IF (l_count_incl_excl > 0) THEN
			  fnd_dsql.add_text(' OR ');
			END IF;

			fnd_dsql.add_text(' (');

 			fnd_dsql.add_text(' addr.country = ');
			fnd_dsql.add_bind(c_revgr_addr_rec.country);
			fnd_dsql.add_text(' AND ( UPPER(addr.state) BETWEEN NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_addr_rec.start_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ) AND NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_addr_rec.end_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ) OR addr.state LIKE ');
			fnd_dsql.add_bind(c_revgr_addr_rec.end_value);
			fnd_dsql.add_text(' )');

			-- If the Current Record had include for the Postal Code
			IF c_revgr_addr_rec.postal_incl_excl_ind = 'I' THEN
				fnd_dsql.add_text(' AND ( UPPER(addr.postal_code) BETWEEN NVL(UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_start_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) AND NVL(UPPER(');
		                fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) OR addr.postal_code LIKE ');
			        fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value );
				fnd_dsql.add_text(' )') ;
			-- If the Current Recode had exclude for the Postal Code
			ELSIF c_revgr_addr_rec.postal_incl_excl_ind = 'E' THEN
				fnd_dsql.add_text(' AND (UPPER(addr.postal_code) NOT BETWEEN NVL(UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_start_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) AND  NVL(UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value );
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) AND addr.postal_code NOT LIKE ');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value);
				fnd_dsql.add_text(' )' );
			END IF;

			fnd_dsql.add_text(' )');
			l_count_incl_excl:=l_count_incl_excl+1;


		END IF;
		END LOOP;

		l_count_incl_excl:=0;
		fnd_dsql.add_text(' )');

		IF (l_addr_excluded_ind ) /*IS TRUE*/ THEN
			--logic for removing excludes
			fnd_dsql.add_text(' AND NOT (');
			l_count_incl_excl:=0;

			FOR c_revgr_addr_rec IN c_revgr_addr(c_appl_revprof_revgr_rec.appl_revprof_revgr_id)
			LOOP
			IF c_revgr_addr_rec.incl_excl_ind = 'E' THEN
				IF (l_count_incl_excl > 0) THEN
					fnd_dsql.add_text(' OR ');
				END IF;

				fnd_dsql.add_text(' (');

				fnd_dsql.add_text(' addr.country = ');
				fnd_dsql.add_bind(c_revgr_addr_rec.country);
				fnd_dsql.add_text(' AND ( UPPER(addr.state) BETWEEN NVL(UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.start_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) AND NVL(UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.end_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) OR addr.state LIKE ');
				fnd_dsql.add_bind(c_revgr_addr_rec.end_value);
				fnd_dsql.add_text(' )');

				fnd_dsql.add_text(' )');
				l_count_incl_excl:=l_count_incl_excl+1;

			END IF;
			END LOOP;

			l_count_incl_excl:=0;
			fnd_dsql.add_text('  )');
		END IF;

	END IF;

	l_cur_statement := fnd_dsql.get_text(FALSE);
	l_debug := fnd_dsql.get_text(TRUE);


        l_cursor_id := dbms_sql.open_cursor;
        fnd_dsql.set_cursor(l_cursor_id);

        dbms_sql.parse(l_cursor_id, l_cur_statement, dbms_sql.native);
        fnd_dsql.do_binds;

        dbms_sql.define_column(l_cursor_id, 1, l_person_id);
	dbms_sql.define_column(l_cursor_id, 2, l_admission_appl_number);
	dbms_sql.define_column(l_cursor_id, 3, l_nominated_course_cd, 6);
	dbms_sql.define_column(l_cursor_id, 4, l_sequence_number);
	dbms_sql.define_column(l_cursor_id, 5, l_country, 60);
	dbms_sql.define_column(l_cursor_id, 6, l_state, 60);
	dbms_sql.define_column(l_cursor_id, 7, l_postal_code, 60);



        l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id);

	/*for debugging*/
	l_debug := fnd_dsql.get_text(TRUE);


        LOOP
	    EXIT WHEN dbms_sql.FETCH_ROWS(l_cursor_id) = 0;
            dbms_sql.column_value(l_cursor_id, 1, l_person_id);
	    dbms_sql.column_value(l_cursor_id, 2, l_admission_appl_number);
	    dbms_sql.column_value(l_cursor_id, 3, l_nominated_course_cd);
	    dbms_sql.column_value(l_cursor_id, 4, l_sequence_number);
	    dbms_sql.column_value(l_cursor_id, 5, l_country);
	    dbms_sql.column_value(l_cursor_id, 6, l_state);
	    dbms_sql.column_value(l_cursor_id, 7, l_postal_code);


	    OPEN  c_arp_rec_found(l_person_id,l_admission_appl_number,
	          l_nominated_course_cd,l_sequence_number);
            FETCH c_arp_rec_found INTO c_arp_rec_found_rec;
	    IF c_arp_rec_found%NOTFOUND THEN
	      -- Insert Using TableHandler
	      lv_rowid := NULL;
	      lv_appl_arp_id := NULL;
	      igs_ad_appl_arp_pkg.insert_row (
		   x_rowid => lv_rowid,
		   x_appl_arp_id => lv_appl_arp_id,
		   x_person_id => l_person_id,
		   x_admission_appl_number => l_admission_appl_number,
		   x_nominated_course_cd => l_nominated_course_cd,
		   x_sequence_number     => l_sequence_number,
		   x_appl_rev_profile_id => p_appl_rev_profile_id,
                   x_appl_revprof_revgr_id => c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
                   x_mode => 'R');

	      -- Write the Application Instance
	      --which got Assigned to a Particular Review Code to the Log file
	      FND_FILE.PUT_LINE(FND_FILE.LOG,LPAD(IGS_GE_NUMBER.TO_CANN(l_person_id),'20',' ')||
		        LPAD(IGS_GE_NUMBER.TO_CANN(l_admission_appl_number),'20',' ')||
			LPAD(l_nominated_course_cd,'15',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(l_sequence_number),'20',' '));

	    ELSIF c_arp_rec_found_rec.appl_revprof_revgr_id IS NULL THEN
	      -- Update Using Table Handler
	      igs_ad_appl_arp_pkg.update_row (
		   x_rowid => c_arp_rec_found_rec.rowid,
		   x_appl_arp_id => c_arp_rec_found_rec.appl_arp_id,
		   x_person_id => c_arp_rec_found_rec.person_id,
		   x_admission_appl_number => c_arp_rec_found_rec.admission_appl_number,
		   x_nominated_course_cd => c_arp_rec_found_rec.nominated_course_cd,
		   x_sequence_number     => c_arp_rec_found_rec.sequence_number,
		   x_appl_rev_profile_id => p_appl_rev_profile_id,
                   x_appl_revprof_revgr_id => c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
                   x_mode => 'R');

  	      -- Write the Application Instance which got Assigned to a
	      -- Particular Review Code to the Log file
	      FND_FILE.PUT_LINE(FND_FILE.LOG,LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.person_id),'20',' ')||
		        LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.admission_appl_number),'20',' ')||
			LPAD(c_arp_rec_found_rec.nominated_course_cd,'20',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.sequence_number),'20',' '));

            END IF;
            CLOSE c_arp_rec_found;
        END LOOP;
        dbms_sql.close_cursor(l_cursor_id);

    -- No include or exclude Records for this Group Code
    ELSE
      CLOSE c_revgr_addr;
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_NO_REC_FOUND'));
    END IF;
    -- Loop through the next Review Group Code for the Profile ID
    END LOOP;







  -- Check if the Review Group Code is Geographical by Applicant Address
  ELSIF c_appl_revprof_group_cd_rec.appl_rev_profile_gr_cd = 'GEO_BY_APPLICANT_ADDR' THEN
    FOR c_appl_revprof_revgr_rec IN c_appl_revprof_revgr(p_appl_rev_profile_id) LOOP
      -- Write the Group Code to the log file
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_GRP_CD_PROC'),'27',' ')
                       ||'    '||c_appl_revprof_revgr_rec.revprof_revgr_name);
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_PERSON_ID'),'20',' ')||
                                    LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_NO'),'20',' ')||
                                    LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_CRS_CD'),'20',' ')||
     		                    LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_SEQ_NUM'),'20',' '));
      l_cur_statement := NULL;

      -- Check if there are any include or exclude records for the Group id.
      OPEN c_revgr_addr(c_appl_revprof_revgr_rec.appl_revprof_revgr_id);
      FETCH c_revgr_addr INTO c_revgr_addr_rec;
      IF c_revgr_addr%FOUND THEN
      CLOSE c_revgr_addr;


	fnd_dsql.init;
	fnd_dsql.add_text(' SELECT apl.person_id,apl.admission_appl_number, apl.nominated_course_cd, apl.sequence_number , addr.country_cd, addr.state, addr.postal_code ');
	fnd_dsql.add_text('  FROM hz_parties hp, hz_party_site_uses psu, igs_ad_ps_appl_inst_all apl, igs_ad_appl_all app, igs_ad_doc_stat doc, igs_ad_ou_stat ou, igs_pe_addr_v addr ');
	fnd_dsql.add_text(' WHERE hp.party_id = apl.person_id  AND hp.party_id = addr.person_id  AND addr.party_site_id = psu.party_site_id  AND psu.site_use_type = ');
	fnd_dsql.add_bind(c_appl_revprof_group_cd_rec.site_use_code);
	fnd_dsql.add_text(' AND doc.s_adm_doc_status = ' );
	fnd_dsql.add_bind(l_satisfied);
	fnd_dsql.add_text(' AND ou.s_adm_outcome_status = ' );
	fnd_dsql.add_bind(l_pending);
	fnd_dsql.add_text(' AND doc.adm_doc_status = apl.adm_doc_status AND ou.adm_outcome_status = apl.adm_outcome_status AND (( ');

	fnd_dsql.add_bind(p_entry_stat_id);
	fnd_dsql.add_text(' IS NOT NULL AND apl.entry_status = ');
	fnd_dsql.add_bind(p_entry_stat_id );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_entry_stat_id );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(p_nominated_course_cd);
	fnd_dsql.add_text(' IS NOT NULL AND apl.nominated_course_cd = ' );
	fnd_dsql.add_bind(p_nominated_course_cd );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_nominated_course_cd);
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(p_person_id );
	fnd_dsql.add_text(' IS NOT NULL AND apl.person_id = ' );
	fnd_dsql.add_bind(p_person_id );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_person_id );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(p_unit_set_cd );
	fnd_dsql.add_text(' IS NOT NULL AND apl.unit_set_cd = ');
	fnd_dsql.add_bind(p_unit_set_cd );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_unit_set_cd );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(l_admission_cat );
	fnd_dsql.add_text(' IS NOT NULL AND app.admission_cat = ' );
	fnd_dsql.add_bind(l_admission_cat );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(l_admission_cat );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(l_s_admission_process_type );
	fnd_dsql.add_text(' IS NOT NULL AND app.s_admission_process_type = ' );
	fnd_dsql.add_bind(l_s_admission_process_type );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(l_s_admission_process_type );
	fnd_dsql.add_text(' IS NULL ) AND apl.person_id = app.person_id AND apl.admission_appl_number = app.admission_appl_number ');


	IF p_calendar_details IS NOT NULL THEN
	  -- Get the Academic Calander details form the Academic Calender Parameter
	  l_acad_cal_type		:= RTRIM ( SUBSTR ( p_calendar_details, 1, 10));
	  l_acad_ci_sequence_number   := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 14, 6));

	  -- Get the Admission Calander details form the Admission Calender Parameter
	  l_adm_cal_type              := RTRIM ( SUBSTR ( p_calendar_details, 23, 10));
	  l_adm_ci_sequence_number    := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 37, 6));


	  IF l_acad_cal_type IS NULL OR l_acad_ci_sequence_number IS NULL OR l_adm_cal_type IS NULL OR l_adm_ci_sequence_number IS NULL THEN
	   fnd_dsql.add_text(' 1=2 ' );
	  ELSE
           fnd_dsql.add_text(' AND app.acad_cal_type = ');
           fnd_dsql.add_bind(l_acad_cal_type);

	   fnd_dsql.add_text(' AND app.acad_ci_sequence_number = ');
           fnd_dsql.add_bind(l_acad_ci_sequence_number);

	   fnd_dsql.add_text(' AND app.adm_cal_type = ');
           fnd_dsql.add_bind(l_adm_cal_type);

	   fnd_dsql.add_text(' AND app.adm_ci_sequence_number = ');
           fnd_dsql.add_bind(l_adm_ci_sequence_number);

	  END IF;
	END IF;


	l_addr_include_ind := FALSE;
	l_addr_excluded_ind := FALSE;

	FOR c_revgr_addr_rec IN c_revgr_addr(c_appl_revprof_revgr_rec.appl_revprof_revgr_id)
	LOOP
		 IF c_revgr_addr_rec.incl_excl_ind IS NULL OR c_revgr_addr_rec.incl_excl_ind = 'I' THEN
			l_addr_include_ind := TRUE;
		 ELSIF c_revgr_addr_rec.postal_incl_excl_ind = 'E' THEN
			l_addr_excluded_ind := TRUE;
		 END IF;

	END LOOP;
	IF l_addr_include_ind /*IS TRUE */THEN

		fnd_dsql.add_text(' AND (');
		l_count_incl_excl:=0;

		FOR c_revgr_addr_rec IN c_revgr_addr(c_appl_revprof_revgr_rec.appl_revprof_revgr_id)
		LOOP
		-- If the Current Record had include for the State
		IF c_revgr_addr_rec.incl_excl_ind IS NULL THEN

			IF (l_count_incl_excl > 0) THEN
			  fnd_dsql.add_text(' OR ');
			END IF;

			fnd_dsql.add_text(' (');

			fnd_dsql.add_text(' addr.country_cd =');
			fnd_dsql.add_bind(c_revgr_addr_rec.country);

			-- If the Current Record had include for the Postal Code
			IF c_revgr_addr_rec.postal_incl_excl_ind = 'I' THEN
				fnd_dsql.add_text(' AND ( UPPER(addr.postal_code) BETWEEN NVL(UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_start_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) AND NVL( UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) OR addr.postal_code LIKE ');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value );
				fnd_dsql.add_text(' )');

			-- If the Current Recode had exclude for the Postal Code
			ELSIF c_revgr_addr_rec.postal_incl_excl_ind = 'E' THEN
	                        fnd_dsql.add_text(' AND (UPPER(addr.postal_code) NOT BETWEEN NVL(UPPER(');
		                fnd_dsql.add_bind(c_revgr_addr_rec.postal_start_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) AND  NVL(UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) AND addr.postal_code NOT LIKE ');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value);
				fnd_dsql.add_text(' )');
			END IF;

			fnd_dsql.add_text(' )');
			l_count_incl_excl:=l_count_incl_excl+1;


		ELSIF c_revgr_addr_rec.incl_excl_ind = 'I' THEN

			IF (l_count_incl_excl > 0) THEN
			  fnd_dsql.add_text(' OR ');
			END IF;

			fnd_dsql.add_text(' (');

 			fnd_dsql.add_text(' addr.country_cd =');
			fnd_dsql.add_bind(c_revgr_addr_rec.country);
			fnd_dsql.add_text(' AND ( UPPER(addr.state) BETWEEN NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_addr_rec.start_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ) AND NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_addr_rec.end_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ) OR addr.state LIKE ');
			fnd_dsql.add_bind(c_revgr_addr_rec.end_value);
			fnd_dsql.add_text(' )');


			-- If the Current Record had include for the Postal Code
			IF c_revgr_addr_rec.postal_incl_excl_ind = 'I' THEN
				fnd_dsql.add_text(' AND ( UPPER(addr.postal_code) BETWEEN NVL(UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_start_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) AND NVL(UPPER(');
		                fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) OR addr.postal_code LIKE ');
			        fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value );
				fnd_dsql.add_text(' )') ;


			-- If the Current Recode had exclude for the Postal Code
			ELSIF c_revgr_addr_rec.postal_incl_excl_ind = 'E' THEN
				fnd_dsql.add_text(' AND (UPPER(addr.postal_code) NOT BETWEEN NVL(UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_start_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) AND  NVL(UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value );
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) AND addr.postal_code NOT LIKE ');
				fnd_dsql.add_bind(c_revgr_addr_rec.postal_end_value);
				fnd_dsql.add_text(' )' );
			END IF;


			fnd_dsql.add_text(' )');
			l_count_incl_excl:=l_count_incl_excl+1;


		END IF;
		END LOOP;

		l_count_incl_excl:=0;
		fnd_dsql.add_text('  )');

		IF l_addr_excluded_ind /*IS TRUE*/ THEN
			--logic for removing excludes
			fnd_dsql.add_text(' AND NOT (');
			l_count_incl_excl:=0;

			FOR c_revgr_addr_rec IN c_revgr_addr(c_appl_revprof_revgr_rec.appl_revprof_revgr_id)
			LOOP
			IF c_revgr_addr_rec.incl_excl_ind = 'E' THEN
				IF (l_count_incl_excl > 0) THEN
					fnd_dsql.add_text(' OR ');
				END IF;

				fnd_dsql.add_text(' (');

				fnd_dsql.add_text(' addr.country_cd = ');
				fnd_dsql.add_bind(c_revgr_addr_rec.country);
				fnd_dsql.add_text(' AND ( UPPER(addr.state) BETWEEN NVL(UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.start_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) AND NVL(UPPER(');
				fnd_dsql.add_bind(c_revgr_addr_rec.end_value);
				fnd_dsql.add_text(' ),');
				fnd_dsql.add_bind(l_percentage_symbol);
				fnd_dsql.add_text(' ) OR addr.state LIKE ');
				fnd_dsql.add_bind(c_revgr_addr_rec.end_value);
				fnd_dsql.add_text(' )');


				fnd_dsql.add_text(' )');
				l_count_incl_excl:=l_count_incl_excl+1;

			END IF;
			END LOOP;

			l_count_incl_excl:=0;
			fnd_dsql.add_text(' )');
		END IF;

	END IF;


	l_cur_statement := fnd_dsql.get_text(FALSE);

        l_cursor_id := dbms_sql.open_cursor;
        fnd_dsql.set_cursor(l_cursor_id);

        dbms_sql.parse(l_cursor_id, l_cur_statement, dbms_sql.native);
        fnd_dsql.do_binds;

        dbms_sql.define_column(l_cursor_id, 1, l_person_id);
	dbms_sql.define_column(l_cursor_id, 2, l_admission_appl_number);
	dbms_sql.define_column(l_cursor_id, 3, l_nominated_course_cd, 6);
	dbms_sql.define_column(l_cursor_id, 4, l_sequence_number);
	dbms_sql.define_column(l_cursor_id, 5, l_pe_country, 60);
	dbms_sql.define_column(l_cursor_id, 6, l_pe_state, 60);
	dbms_sql.define_column(l_cursor_id, 7, l_pe_postal_code, 60);


        l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id);

	/*for debugging*/
	l_debug := fnd_dsql.get_text(TRUE);


        LOOP
	    EXIT WHEN dbms_sql.FETCH_ROWS(l_cursor_id) = 0;
            dbms_sql.column_value(l_cursor_id, 1, l_person_id);
	    dbms_sql.column_value(l_cursor_id, 2, l_admission_appl_number);
	    dbms_sql.column_value(l_cursor_id, 3, l_nominated_course_cd);
	    dbms_sql.column_value(l_cursor_id, 4, l_sequence_number);
	    dbms_sql.column_value(l_cursor_id, 5, l_pe_country);
	    dbms_sql.column_value(l_cursor_id, 6, l_pe_state);
	    dbms_sql.column_value(l_cursor_id, 7, l_pe_postal_code);


            OPEN  c_arp_rec_found(l_person_id,l_admission_appl_number,
	              l_nominated_course_cd,l_sequence_number);
            FETCH c_arp_rec_found INTO c_arp_rec_found_rec;
	    IF c_arp_rec_found%NOTFOUND THEN
	       -- Insert Using TableHandler
	      lv_rowid := NULL;
	      lv_appl_arp_id := NULL;
	      igs_ad_appl_arp_pkg.insert_row (
		   x_rowid => lv_rowid,
		   x_appl_arp_id => lv_appl_arp_id,
		   x_person_id => l_person_id,
		   x_admission_appl_number => l_admission_appl_number,
		   x_nominated_course_cd => l_nominated_course_cd,
		   x_sequence_number     => l_sequence_number,
		   x_appl_rev_profile_id => p_appl_rev_profile_id,
                   x_appl_revprof_revgr_id => c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
                   x_mode => 'R');

	      -- Write the Application Instance which got
	      --Assigned to a Particular Review Code to the Log file
	      FND_FILE.PUT_LINE(FND_FILE.LOG,
		        LPAD(IGS_GE_NUMBER.TO_CANN(l_person_id),'20',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(l_admission_appl_number),'20',' ')||
			LPAD(l_nominated_course_cd,'15',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(l_sequence_number),'20',' '));

	    ELSIF c_arp_rec_found_rec.appl_revprof_revgr_id IS NULL THEN
	       -- Update Using Table Handler
	      igs_ad_appl_arp_pkg.update_row (
		   x_rowid => c_arp_rec_found_rec.rowid,
		   x_appl_arp_id => c_arp_rec_found_rec.appl_arp_id,
		   x_person_id => c_arp_rec_found_rec.person_id,
		   x_admission_appl_number => c_arp_rec_found_rec.admission_appl_number,
		   x_nominated_course_cd => c_arp_rec_found_rec.nominated_course_cd,
		   x_sequence_number     => c_arp_rec_found_rec.sequence_number,
		   x_appl_rev_profile_id => p_appl_rev_profile_id,
                   x_appl_revprof_revgr_id => c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
                   x_mode => 'R');

  	      -- Write the Application Instance which got
	      --Assigned to a Particular Review Code to the Log file
	      FND_FILE.PUT_LINE(FND_FILE.LOG,
		        LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.person_id),'20',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.admission_appl_number),'20',' ')||
			LPAD(c_arp_rec_found_rec.nominated_course_cd,'20',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.sequence_number),'20',' '));

            END IF;
            CLOSE c_arp_rec_found;
        END LOOP;
        dbms_sql.close_cursor(l_cursor_id);

    -- No include or exclude Records for this Group Code
    ELSE
      CLOSE c_revgr_addr;
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_NO_REC_FOUND'));
    END IF;
    END LOOP;





  -- Check if the Review Group Code is Geographical by Market Code
  ELSIF c_appl_revprof_group_cd_rec.appl_rev_profile_gr_cd = 'GEO_BY_MARKET_CODE' THEN
    FOR c_appl_revprof_revgr_rec IN c_appl_revprof_revgr(p_appl_rev_profile_id) LOOP
    -- Write the Group Code to the log file
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,
        LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_GRP_CD_PROC'),'27',' ') ||
	'    '||c_appl_revprof_revgr_rec.revprof_revgr_name);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,
	        LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_PERSON_ID'),'20',' ')||
		LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_NO'),'20',' ')||
		LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_CRS_CD'),'20',' ')||
		LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_SEQ_NUM'),'20',' '));

    l_cur_statement := NULL;
    -- Check if there are any include or exclude records for the Group id.
    OPEN c_revgr_incl_excl(c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
               g_incl_ind);
    FETCH c_revgr_incl_excl INTO  c_revgr_incl_excl_rec;
    IF c_revgr_incl_excl%FOUND THEN
    CLOSE c_revgr_incl_excl;


	fnd_dsql.init;
	fnd_dsql.add_text(' SELECT apl.person_id,apl.admission_appl_number, apl.nominated_course_cd, apl.sequence_number ');
	fnd_dsql.add_text(' FROM hz_parties hp, igs_ad_ps_appl_inst_all apl, igs_ad_appl_all app, igs_ad_doc_stat doc, igs_ad_ou_stat ou, igs_pe_hz_parties php, igs_ad_acad_history_v aah ');
	fnd_dsql.add_text(' WHERE aah.person_id = apl.person_id  AND aah.CURRENT_INST = ');
	fnd_dsql.add_bind('Y');
	fnd_dsql.add_text(' AND aah.institution_code = php.oss_org_unit_cd  AND doc.s_adm_doc_status = ' );
	fnd_dsql.add_bind(l_satisfied);
	fnd_dsql.add_text(' AND ou.s_adm_outcome_status = ' );
	fnd_dsql.add_bind(l_pending);
	fnd_dsql.add_text(' AND doc.adm_doc_status = apl.adm_doc_status AND ou.adm_outcome_status = apl.adm_outcome_status  AND (( ');

	fnd_dsql.add_bind(p_entry_stat_id);
	fnd_dsql.add_text(' IS NOT NULL AND apl.entry_status = ' );
	fnd_dsql.add_bind(p_entry_stat_id);
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_entry_stat_id );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(p_nominated_course_cd);
	fnd_dsql.add_text(' IS NOT NULL AND apl.nominated_course_cd = ');
	fnd_dsql.add_bind(p_nominated_course_cd);
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_nominated_course_cd );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(p_person_id);
	fnd_dsql.add_text(' IS NOT NULL AND apl.person_id = ' );
	fnd_dsql.add_bind(p_person_id);
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_person_id );
	fnd_dsql.add_text(' IS NULL )  AND (( ');

	fnd_dsql.add_bind(p_unit_set_cd);
	fnd_dsql.add_text(' IS NOT NULL AND apl.unit_set_cd = ');
	fnd_dsql.add_bind(p_unit_set_cd);
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_unit_set_cd);
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(l_admission_cat);
	fnd_dsql.add_text(' IS NOT NULL AND app.admission_cat = ' );
	fnd_dsql.add_bind(l_admission_cat );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(l_admission_cat );
	fnd_dsql.add_text(' IS NULL )  AND (( ');

	fnd_dsql.add_bind(l_s_admission_process_type);
	fnd_dsql.add_text(' IS NOT NULL AND app.s_admission_process_type = ');
	fnd_dsql.add_bind(l_s_admission_process_type );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(l_s_admission_process_type );
	fnd_dsql.add_text(' IS NULL ) AND apl.person_id = app.person_id  AND apl.admission_appl_number = app.admission_appl_number ');


		IF p_calendar_details IS NOT NULL THEN
	  -- Get the Academic Calander details form the Academic Calender Parameter
	  l_acad_cal_type		:= RTRIM ( SUBSTR ( p_calendar_details, 1, 10));
	  l_acad_ci_sequence_number   := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 14, 6));

	  -- Get the Admission Calander details form the Admission Calender Parameter
	  l_adm_cal_type              := RTRIM ( SUBSTR ( p_calendar_details, 23, 10));
	  l_adm_ci_sequence_number    := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 37, 6));


	  IF l_acad_cal_type IS NULL OR l_acad_ci_sequence_number IS NULL OR l_adm_cal_type IS NULL OR l_adm_ci_sequence_number IS NULL THEN
	   fnd_dsql.add_text(' 1=2 ' );
	  ELSE
           fnd_dsql.add_text(' AND app.acad_cal_type = ');
           fnd_dsql.add_bind(l_acad_cal_type);

	   fnd_dsql.add_text(' AND app.acad_ci_sequence_number = ');
           fnd_dsql.add_bind(l_acad_ci_sequence_number);

	   fnd_dsql.add_text(' AND app.adm_cal_type = ');
           fnd_dsql.add_bind(l_adm_cal_type);

	   fnd_dsql.add_text(' AND app.adm_ci_sequence_number = ');
           fnd_dsql.add_bind(l_adm_ci_sequence_number);

	  END IF;
	END IF;

	OPEN c_revgr_incl_excl(c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
               g_excl_ind);
	FETCH c_revgr_incl_excl INTO  c_revgr_incl_excl_rec;
	IF c_revgr_incl_excl%FOUND THEN
		CLOSE c_revgr_incl_excl;

	         fnd_dsql.add_text(' AND php.inst_eps_code IN ( ( SELECT inst_eps_code ');
		 fnd_dsql.add_text(' FROM igs_pe_hz_parties WHERE ');

		-- Open a cursor to fetch all the include Records and combine them to form a where clause
		FOR c_revgr_incl_excl_rec IN c_revgr_incl_excl(c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
			g_incl_ind) LOOP
			IF (l_count_incl_excl > 0) THEN
				fnd_dsql.add_text(' OR ');
			END IF;


			fnd_dsql.add_text(' ((UPPER(inst_eps_code) BETWEEN NVL(UPPER(');
	                fnd_dsql.add_bind(c_revgr_incl_excl_rec.start_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ) AND NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.end_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' )) OR UPPER(inst_eps_code) LIKE NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.end_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ))');


			l_count_incl_excl:=l_count_incl_excl+1;


		END LOOP;

		fnd_dsql.add_text(' )');

		l_count_incl_excl:=0;
		fnd_dsql.add_text(' MINUS  ( SELECT inst_eps_code FROM igs_pe_hz_parties WHERE ');

   		-- Open a cursor to fetch all the exclusion Records and combine them to form a where clause
		FOR c_revgr_incl_excl_rec IN c_revgr_incl_excl(c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
			g_excl_ind) LOOP

			IF (l_count_incl_excl > 0) THEN
				fnd_dsql.add_text(' OR ');
			END IF;

	  		fnd_dsql.add_text(' ((UPPER(inst_eps_code) BETWEEN NVL(UPPER(');
	                fnd_dsql.add_bind(c_revgr_incl_excl_rec.start_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ) AND NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.end_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' )) OR UPPER(inst_eps_code) LIKE NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.end_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ))');

			l_count_incl_excl:=l_count_incl_excl+1;
		END LOOP;

		fnd_dsql.add_text(' ))');
		l_count_incl_excl := 0;


	 ELSE
		CLOSE c_revgr_incl_excl;
		fnd_dsql.add_text(' AND php.inst_eps_code IN ( SELECT inst_eps_code ');
		fnd_dsql.add_text(' FROM igs_pe_hz_parties WHERE  ');

		FOR c_revgr_incl_excl_rec IN c_revgr_incl_excl(c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
			g_incl_ind) LOOP
			IF (l_count_incl_excl > 0) THEN
			  fnd_dsql.add_text(' OR ');
			END IF;

			fnd_dsql.add_text(' ((UPPER(inst_eps_code) BETWEEN NVL(UPPER(');
	                fnd_dsql.add_bind(c_revgr_incl_excl_rec.start_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ) AND NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.end_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' )) OR UPPER(inst_eps_code) LIKE NVL(UPPER(');
			fnd_dsql.add_bind(c_revgr_incl_excl_rec.end_value);
			fnd_dsql.add_text(' ),');
			fnd_dsql.add_bind(l_percentage_symbol);
			fnd_dsql.add_text(' ))');

			l_count_incl_excl:=l_count_incl_excl+1;


		END LOOP;

		l_count_incl_excl:=0;
		fnd_dsql.add_text(' )');

	END IF; -- End of checking presence of exclude records

	l_cur_statement := fnd_dsql.get_text(FALSE);

        l_cursor_id := dbms_sql.open_cursor;
        fnd_dsql.set_cursor(l_cursor_id);

        dbms_sql.parse(l_cursor_id, l_cur_statement, dbms_sql.native);
        fnd_dsql.do_binds;

        dbms_sql.define_column(l_cursor_id, 1, l_person_id);
	dbms_sql.define_column(l_cursor_id, 2, l_admission_appl_number);
	dbms_sql.define_column(l_cursor_id, 3, l_nominated_course_cd, 6);
	dbms_sql.define_column(l_cursor_id, 4, l_sequence_number);

        l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id);

	/*for debugging*/
	l_debug := fnd_dsql.get_text(TRUE);


        LOOP
	    EXIT WHEN dbms_sql.FETCH_ROWS(l_cursor_id) = 0;
            dbms_sql.column_value(l_cursor_id, 1, l_person_id);
	    dbms_sql.column_value(l_cursor_id, 2, l_admission_appl_number);
	    dbms_sql.column_value(l_cursor_id, 3, l_nominated_course_cd);
	    dbms_sql.column_value(l_cursor_id, 4, l_sequence_number);

	    OPEN  c_arp_rec_found(l_person_id,l_admission_appl_number,
		l_nominated_course_cd,l_sequence_number);
	    FETCH c_arp_rec_found INTO c_arp_rec_found_rec;
	    IF c_arp_rec_found%NOTFOUND THEN
	    -- Insert Using TableHandler
	      lv_rowid := NULL;
	      lv_appl_arp_id := NULL;
	      igs_ad_appl_arp_pkg.insert_row (
	           x_rowid => lv_rowid,
	           x_appl_arp_id => lv_appl_arp_id,
		   x_person_id => l_person_id,
		   x_admission_appl_number => l_admission_appl_number,
		   x_nominated_course_cd => l_nominated_course_cd,
		   x_sequence_number     => l_sequence_number,
		   x_appl_rev_profile_id => p_appl_rev_profile_id,
                   x_appl_revprof_revgr_id => c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
                   x_mode => 'R');

	      -- Write the Application Instance which got
	      --Assigned to a Particular Review Code to the Log file
	      FND_FILE.PUT_LINE(FND_FILE.LOG,LPAD(IGS_GE_NUMBER.TO_CANN(l_person_id),'20',' ')||
	        LPAD(IGS_GE_NUMBER.TO_CANN(l_admission_appl_number),'20',' ')||
		LPAD(l_nominated_course_cd,'15',' ')||
		LPAD(IGS_GE_NUMBER.TO_CANN(l_sequence_number),'20',' '));

	    ELSIF c_arp_rec_found_rec.appl_revprof_revgr_id IS NULL THEN
	    -- Update Using Table Handler
	      igs_ad_appl_arp_pkg.update_row (
		   x_rowid => c_arp_rec_found_rec.rowid,
		   x_appl_arp_id => c_arp_rec_found_rec.appl_arp_id,
		   x_person_id => c_arp_rec_found_rec.person_id,
		   x_admission_appl_number => c_arp_rec_found_rec.admission_appl_number,
		   x_nominated_course_cd => c_arp_rec_found_rec.nominated_course_cd,
		   x_sequence_number     => c_arp_rec_found_rec.sequence_number,
		   x_appl_rev_profile_id => p_appl_rev_profile_id,
                   x_appl_revprof_revgr_id => c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
                   x_mode => 'R');

  	     -- Write the Application Instance which got
	     --Assigned to a Particular Review Code to the Log file
	     FND_FILE.PUT_LINE(FND_FILE.LOG,
	                LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.person_id),'20',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.admission_appl_number),'20',' ')||
			LPAD(c_arp_rec_found_rec.nominated_course_cd,'20',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.sequence_number),'20',' '));

            END IF;
          CLOSE c_arp_rec_found;

        END LOOP;
        dbms_sql.close_cursor(l_cursor_id);

    -- No include or exclude Records for this Group Code
    ELSE
      CLOSE c_revgr_incl_excl;
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_NO_REC_FOUND'));
    END IF;
    -- Loop through the next Review Group Code for the Profile ID
    END LOOP;





  -- Check if the Review Group Code is Program of Study
  ELSIF c_appl_revprof_group_cd_rec.appl_rev_profile_gr_cd = 'PROG_OF_STUDY' THEN
    FOR c_appl_revprof_revgr_rec IN c_appl_revprof_revgr(p_appl_rev_profile_id) LOOP
    -- Write the Group Code to the log file
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,
        LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_GRP_CD_PROC'),'27',' ')
 	||'    '||c_appl_revprof_revgr_rec.revprof_revgr_name);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_PERSON_ID'),'20',' ')||
		LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_NO'),'20',' ')||
		LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_CRS_CD'),'20',' ')||
		LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_SEQ_NUM'),'20',' '));

    l_cur_statement := NULL;

    -- Check if there are any include or exclude records for the Group id.
    OPEN c_revgr_addr(c_appl_revprof_revgr_rec.appl_revprof_revgr_id);
    FETCH c_revgr_addr INTO  c_revgr_addr_rec;
    IF c_revgr_addr%FOUND THEN
    CLOSE c_revgr_addr;


	fnd_dsql.init;
	fnd_dsql.add_text(' SELECT apl.person_id,apl.admission_appl_number, apl.nominated_course_cd, apl.sequence_number ');
	fnd_dsql.add_text(' FROM  igs_ad_ps_appl_inst_all apl, igs_ad_appl_all app, igs_ad_doc_stat doc, igs_ad_ou_stat ou ');
	fnd_dsql.add_text(' WHERE doc.s_adm_doc_status = ');
	fnd_dsql.add_bind(l_satisfied);
	fnd_dsql.add_text(' AND ou.s_adm_outcome_status = ');
	fnd_dsql.add_bind(l_pending);
	fnd_dsql.add_text(' AND doc.adm_doc_status = apl.adm_doc_status AND ou.adm_outcome_status = apl.adm_outcome_status AND (( ');

	fnd_dsql.add_bind(p_entry_stat_id );
	fnd_dsql.add_text(' IS NOT NULL AND apl.entry_status = ' );
	fnd_dsql.add_bind(p_entry_stat_id);
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_entry_stat_id );
	fnd_dsql.add_text(' IS NULL )  AND (( ');

	fnd_dsql.add_bind(p_nominated_course_cd);
	fnd_dsql.add_text(' IS NOT NULL AND apl.nominated_course_cd = ');
	fnd_dsql.add_bind(p_nominated_course_cd );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_nominated_course_cd );
	fnd_dsql.add_text(' IS NULL )  AND (( ');

	fnd_dsql.add_bind(p_person_id);
	fnd_dsql.add_text(' IS NOT NULL AND apl.person_id = ' );
	fnd_dsql.add_bind(p_person_id);
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_person_id );
	fnd_dsql.add_text(' IS NULL )  AND (( ');

	fnd_dsql.add_bind(p_unit_set_cd);
	fnd_dsql.add_text(' IS NOT NULL AND apl.unit_set_cd = ' );
	fnd_dsql.add_bind(p_unit_set_cd );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_unit_set_cd );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(l_admission_cat );
	fnd_dsql.add_text(' IS NOT NULL AND app.admission_cat = ' );
	fnd_dsql.add_bind(l_admission_cat );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(l_admission_cat );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(l_s_admission_process_type );
	fnd_dsql.add_text(' IS NOT NULL AND app.s_admission_process_type = ');
	fnd_dsql.add_bind(l_s_admission_process_type );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(l_s_admission_process_type );
	fnd_dsql.add_text(' IS NULL )  AND apl.person_id = app.person_id AND apl.admission_appl_number = app.admission_appl_number ');


	IF p_calendar_details IS NOT NULL THEN
	  -- Get the Academic Calander details form the Academic Calender Parameter
	  l_acad_cal_type		:= RTRIM ( SUBSTR ( p_calendar_details, 1, 10));
	  l_acad_ci_sequence_number   := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 14, 6));

	  -- Get the Admission Calander details form the Admission Calender Parameter
	  l_adm_cal_type              := RTRIM ( SUBSTR ( p_calendar_details, 23, 10));
	  l_adm_ci_sequence_number    := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 37, 6));


	  IF l_acad_cal_type IS NULL OR l_acad_ci_sequence_number IS NULL OR l_adm_cal_type IS NULL OR l_adm_ci_sequence_number IS NULL THEN
	   fnd_dsql.add_text(' 1=2 ' );
	  ELSE
           fnd_dsql.add_text(' AND app.acad_cal_type = ');
           fnd_dsql.add_bind(l_acad_cal_type);

	   fnd_dsql.add_text(' AND app.acad_ci_sequence_number = ');
           fnd_dsql.add_bind(l_acad_ci_sequence_number);

	   fnd_dsql.add_text(' AND app.adm_cal_type = ');
           fnd_dsql.add_bind(l_adm_cal_type);

	   fnd_dsql.add_text(' AND app.adm_ci_sequence_number = ');
           fnd_dsql.add_bind(l_adm_ci_sequence_number);

	  END IF;
	END IF;


	l_count_incl_excl:= 0;
	fnd_dsql.add_text(' AND (');
	-- Open a cursor to fetch all the include Records and combine them to form a where clause
	FOR c_revgr_addr_rec IN c_revgr_addr(c_appl_revprof_revgr_rec.appl_revprof_revgr_id)
	LOOP
	IF (l_count_incl_excl > 0) THEN
		fnd_dsql.add_text(' OR ');
	END IF;


	fnd_dsql.add_text(' ( apl.nominated_course_cd = NVL(');
	fnd_dsql.add_bind(c_revgr_addr_rec.start_value );
	fnd_dsql.add_text(' ,');
	fnd_dsql.add_bind(l_percentage_symbol);
	fnd_dsql.add_text(' ) AND apl.crv_version_number = NVL(');
	fnd_dsql.add_bind(c_revgr_addr_rec.version_number);
	fnd_dsql.add_text(' ,');
	fnd_dsql.add_bind(l_percentage_symbol);
	fnd_dsql.add_text(' ))');

	l_count_incl_excl:=l_count_incl_excl+1;

	END LOOP;

	l_count_incl_excl:=0;
	fnd_dsql.add_text(' )');


	l_cur_statement := fnd_dsql.get_text(FALSE);

        l_cursor_id := dbms_sql.open_cursor;
        fnd_dsql.set_cursor(l_cursor_id);

        dbms_sql.parse(l_cursor_id, l_cur_statement, dbms_sql.native);
        fnd_dsql.do_binds;

        dbms_sql.define_column(l_cursor_id, 1, l_person_id);
	dbms_sql.define_column(l_cursor_id, 2, l_admission_appl_number);
	dbms_sql.define_column(l_cursor_id, 3, l_nominated_course_cd, 6);
	dbms_sql.define_column(l_cursor_id, 4, l_sequence_number);

        l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id);

	/*for debugging*/
	l_debug := fnd_dsql.get_text(TRUE);


        LOOP
	    EXIT WHEN dbms_sql.FETCH_ROWS(l_cursor_id) = 0;
            dbms_sql.column_value(l_cursor_id, 1, l_person_id);
	    dbms_sql.column_value(l_cursor_id, 2, l_admission_appl_number);
	    dbms_sql.column_value(l_cursor_id, 3, l_nominated_course_cd);
	    dbms_sql.column_value(l_cursor_id, 4, l_sequence_number);

	OPEN  c_arp_rec_found(l_person_id,l_admission_appl_number,
	      l_nominated_course_cd,l_sequence_number);
        FETCH c_arp_rec_found INTO c_arp_rec_found_rec;
	IF c_arp_rec_found%NOTFOUND THEN
	    -- Insert Using TableHandler
	    lv_rowid := NULL;
	    lv_appl_arp_id := NULL;
	    igs_ad_appl_arp_pkg.insert_row (
		   x_rowid => lv_rowid,
		   x_appl_arp_id => lv_appl_arp_id,
		   x_person_id => l_person_id,
		   x_admission_appl_number => l_admission_appl_number,
		   x_nominated_course_cd => l_nominated_course_cd,
		   x_sequence_number     => l_sequence_number,
		   x_appl_rev_profile_id => p_appl_rev_profile_id,
                   x_appl_revprof_revgr_id => c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
                   x_mode => 'R');

	    -- Write the Application Instance which got
	    -- Assigned to a Particular Review Code to the Log file
	    FND_FILE.PUT_LINE(FND_FILE.LOG,
	                LPAD(IGS_GE_NUMBER.TO_CANN(l_person_id),'20',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(l_admission_appl_number),'20',' ')||
			LPAD(l_nominated_course_cd,'15',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(l_sequence_number),'20',' '));

	ELSIF c_arp_rec_found_rec.appl_revprof_revgr_id IS NULL THEN
	   -- Update Using Table Handler
	   igs_ad_appl_arp_pkg.update_row (
		   x_rowid => c_arp_rec_found_rec.rowid,
		   x_appl_arp_id => c_arp_rec_found_rec.appl_arp_id,
		   x_person_id => c_arp_rec_found_rec.person_id,
		   x_admission_appl_number => c_arp_rec_found_rec.admission_appl_number,
		   x_nominated_course_cd => c_arp_rec_found_rec.nominated_course_cd,
		   x_sequence_number     => c_arp_rec_found_rec.sequence_number,
		   x_appl_rev_profile_id => p_appl_rev_profile_id,
                   x_appl_revprof_revgr_id => c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
                   x_mode => 'R');

  	   -- Write the Application Instance which got
	   -- Assigned to a Particular Review Code to the Log file
	   FND_FILE.PUT_LINE(FND_FILE.LOG,
	                LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.person_id),'20',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.admission_appl_number),'20',' ')||
			LPAD(c_arp_rec_found_rec.nominated_course_cd,'20',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.sequence_number),'20',' '));

	END IF;
        CLOSE c_arp_rec_found;

        END LOOP;
        dbms_sql.close_cursor(l_cursor_id);

    -- No include or exclude Records for this Group Code
    ELSE
      CLOSE c_revgr_addr;
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_NO_REC_FOUND'));
    END IF;
    -- Loop through the next Review Group Code for the Profile ID
    END LOOP;






  -- Check if the Review Group Code is Organization
  ELSIF c_appl_revprof_group_cd_rec.appl_rev_profile_gr_cd = 'ORGANIZATION' THEN
    FOR c_appl_revprof_revgr_rec IN c_appl_revprof_revgr(p_appl_rev_profile_id) LOOP
    -- Write the Group Code to the log file
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,
              LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_GRP_CD_PROC'),'27',' ') ||
	      '    '|| c_appl_revprof_revgr_rec.revprof_revgr_name);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_PERSON_ID'),'20',' ')||
		LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_NO'),'20',' ')||
		LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_CRS_CD'),'20',' ')||
		LPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_SEQ_NUM'),'20',' '));

    l_cur_statement := NULL;

    -- Check if there are any include or exclude records for the Group id.
    OPEN c_revgr_addr(c_appl_revprof_revgr_rec.appl_revprof_revgr_id);
    FETCH c_revgr_addr INTO  c_revgr_addr_rec;
    IF c_revgr_addr%FOUND THEN
    CLOSE c_revgr_addr;


	fnd_dsql.init;
	fnd_dsql.add_text('SELECT apl.person_id,apl.admission_appl_number, apl.nominated_course_cd, apl.sequence_number ' );
	fnd_dsql.add_text(' FROM  igs_ps_ver_all pva, igs_ad_ps_appl_inst_all apl, igs_ad_appl_all app, igs_ad_doc_stat doc, igs_ad_ou_stat ou ');
	fnd_dsql.add_text(' WHERE pva.course_cd = apl.nominated_course_cd AND doc.s_adm_doc_status = ' );
	fnd_dsql.add_bind(l_satisfied);
	fnd_dsql.add_text(' AND ou.s_adm_outcome_status = ' );
	fnd_dsql.add_bind(l_pending);
	fnd_dsql.add_text(' AND doc.adm_doc_status = apl.adm_doc_status AND ou.adm_outcome_status = apl.adm_outcome_status AND (( ');

	fnd_dsql.add_bind(p_entry_stat_id );
	fnd_dsql.add_text(' IS NOT NULL AND apl.entry_status = ');
	fnd_dsql.add_bind(p_entry_stat_id );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_entry_stat_id );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(p_nominated_course_cd );
	fnd_dsql.add_text(' IS NOT NULL AND apl.nominated_course_cd = ');
	fnd_dsql.add_bind(p_nominated_course_cd );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_nominated_course_cd );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(p_person_id );
	fnd_dsql.add_text(' IS NOT NULL AND apl.person_id = ' );
	fnd_dsql.add_bind(p_person_id );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_person_id );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(p_unit_set_cd );
	fnd_dsql.add_text(' IS NOT NULL AND apl.unit_set_cd = ');
	fnd_dsql.add_bind(p_unit_set_cd);
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(p_unit_set_cd );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(l_admission_cat );
	fnd_dsql.add_text(' IS NOT NULL AND app.admission_cat = ' );
	fnd_dsql.add_bind(l_admission_cat );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(l_admission_cat );
	fnd_dsql.add_text(' IS NULL ) AND (( ');

	fnd_dsql.add_bind(l_s_admission_process_type );
	fnd_dsql.add_text(' IS NOT NULL AND app.s_admission_process_type = ');
	fnd_dsql.add_bind(l_s_admission_process_type );
	fnd_dsql.add_text(' ) OR ' );
	fnd_dsql.add_bind(l_s_admission_process_type );
	fnd_dsql.add_text(' IS NULL ) AND apl.person_id = app.person_id AND apl.admission_appl_number = app.admission_appl_number ');

	IF p_calendar_details IS NOT NULL THEN
	  -- Get the Academic Calander details form the Academic Calender Parameter
	  l_acad_cal_type		:= RTRIM ( SUBSTR ( p_calendar_details, 1, 10));
	  l_acad_ci_sequence_number   := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 14, 6));

	  -- Get the Admission Calander details form the Admission Calender Parameter
	  l_adm_cal_type              := RTRIM ( SUBSTR ( p_calendar_details, 23, 10));
	  l_adm_ci_sequence_number    := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 37, 6));


	  IF l_acad_cal_type IS NULL OR l_acad_ci_sequence_number IS NULL OR l_adm_cal_type IS NULL OR l_adm_ci_sequence_number IS NULL THEN
	   fnd_dsql.add_text(' 1=2 ' );
	  ELSE
           fnd_dsql.add_text(' AND app.acad_cal_type = ');
           fnd_dsql.add_bind(l_acad_cal_type);

	   fnd_dsql.add_text(' AND app.acad_ci_sequence_number = ');
           fnd_dsql.add_bind(l_acad_ci_sequence_number);

	   fnd_dsql.add_text(' AND app.adm_cal_type = ');
           fnd_dsql.add_bind(l_adm_cal_type);

	   fnd_dsql.add_text(' AND app.adm_ci_sequence_number = ');
           fnd_dsql.add_bind(l_adm_ci_sequence_number);

	  END IF;
	END IF;


	fnd_dsql.add_text(' AND (');
	-- Open a cursor to fetch all the include Records and combine them to form a where clause
	FOR c_revgr_addr_rec IN c_revgr_addr(c_appl_revprof_revgr_rec.appl_revprof_revgr_id)
	LOOP
	IF (l_count_incl_excl > 0) THEN
		fnd_dsql.add_text(' OR ');
	END IF;

	fnd_dsql.add_text(' ( pva.responsible_org_unit_cd = NVL(' );
	fnd_dsql.add_bind(c_revgr_addr_rec.start_value);
	fnd_dsql.add_text(' ,');
	fnd_dsql.add_bind(l_percentage_symbol);
	fnd_dsql.add_text(' ))');


	l_count_incl_excl:=l_count_incl_excl+1;

	END LOOP;

	l_count_incl_excl:=0;
	fnd_dsql.add_text(' )');


	l_cur_statement := fnd_dsql.get_text(FALSE);

        l_cursor_id := dbms_sql.open_cursor;
        fnd_dsql.set_cursor(l_cursor_id);

        dbms_sql.parse(l_cursor_id, l_cur_statement, dbms_sql.native);
        fnd_dsql.do_binds;

        dbms_sql.define_column(l_cursor_id, 1, l_person_id);
	dbms_sql.define_column(l_cursor_id, 2, l_admission_appl_number);
	dbms_sql.define_column(l_cursor_id, 3, l_nominated_course_cd, 6);
	dbms_sql.define_column(l_cursor_id, 4, l_sequence_number);

        l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id);

	/*for debugging*/
	l_debug := fnd_dsql.get_text(TRUE);


        LOOP
	    EXIT WHEN dbms_sql.FETCH_ROWS(l_cursor_id) = 0;
            dbms_sql.column_value(l_cursor_id, 1, l_person_id);
	    dbms_sql.column_value(l_cursor_id, 2, l_admission_appl_number);
	    dbms_sql.column_value(l_cursor_id, 3, l_nominated_course_cd);
	    dbms_sql.column_value(l_cursor_id, 4, l_sequence_number);

         OPEN  c_arp_rec_found(l_person_id,l_admission_appl_number,
	       l_nominated_course_cd,l_sequence_number);
         FETCH c_arp_rec_found INTO c_arp_rec_found_rec;
	 IF c_arp_rec_found%NOTFOUND THEN
	   -- Insert Using TableHandler
	   lv_rowid := NULL;
	   lv_appl_arp_id := NULL;
	   igs_ad_appl_arp_pkg.insert_row (
		   x_rowid => lv_rowid,
		   x_appl_arp_id => lv_appl_arp_id,
		   x_person_id => l_person_id,
		   x_admission_appl_number => l_admission_appl_number,
		   x_nominated_course_cd => l_nominated_course_cd,
		   x_sequence_number     => l_sequence_number,
		   x_appl_rev_profile_id => p_appl_rev_profile_id,
                   x_appl_revprof_revgr_id => c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
                   x_mode => 'R');

	   -- Write the Application Instance which got
	   --Assigned to a Particular Review Code to the Log file
	   FND_FILE.PUT_LINE(FND_FILE.LOG,
	        LPAD(IGS_GE_NUMBER.TO_CANN(l_person_id),'20',' ')||
		LPAD(IGS_GE_NUMBER.TO_CANN(l_admission_appl_number),'20',' ')||
		LPAD(l_nominated_course_cd,'15',' ')||
		LPAD(IGS_GE_NUMBER.TO_CANN(l_sequence_number),'20',' '));

	 ELSIF c_arp_rec_found_rec.appl_revprof_revgr_id IS NULL THEN
	    -- Update Using Table Handler
	    igs_ad_appl_arp_pkg.update_row (
		   x_rowid => c_arp_rec_found_rec.rowid,
		   x_appl_arp_id => c_arp_rec_found_rec.appl_arp_id,
		   x_person_id => c_arp_rec_found_rec.person_id,
		   x_admission_appl_number => c_arp_rec_found_rec.admission_appl_number,
		   x_nominated_course_cd => c_arp_rec_found_rec.nominated_course_cd,
		   x_sequence_number     => c_arp_rec_found_rec.sequence_number,
		   x_appl_rev_profile_id => p_appl_rev_profile_id,
                   x_appl_revprof_revgr_id => c_appl_revprof_revgr_rec.appl_revprof_revgr_id,
                   x_mode => 'R');

  		   -- Write the Application Instance which got Assigned to a
		   --Particular Review Code to the Log file
		   FND_FILE.PUT_LINE(FND_FILE.LOG,
		        LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.person_id),'20',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.admission_appl_number),'20',' ')||
                        LPAD(c_arp_rec_found_rec.nominated_course_cd,'20',' ')||
			LPAD(IGS_GE_NUMBER.TO_CANN(c_arp_rec_found_rec.sequence_number),'20',' '));

         END IF;
	CLOSE c_arp_rec_found;

        END LOOP;
        dbms_sql.close_cursor(l_cursor_id);

    -- No include or exclude Records for this Group Code
    ELSE
      CLOSE c_revgr_addr;
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_NO_REC_FOUND'));
    END IF;
    -- Loop through the next Review Group Code for the Profile ID
    END LOOP;
  FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
  END IF;
 EXCEPTION
     WHEN OTHERS THEN
       retcode := 2;
       IGS_GE_MSG_STACK.Conc_Exception_Hndl;
END assign_review_group;
END igs_ad_assign_review_grp;

/
