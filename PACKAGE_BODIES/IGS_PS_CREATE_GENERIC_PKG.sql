--------------------------------------------------------
--  DDL for Package Body IGS_PS_CREATE_GENERIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_CREATE_GENERIC_PKG" AS
/* $Header: IGSPS91B.pls 120.7 2006/05/12 04:59:39 abshriva noship $ */

  /***********************************************************************************************
    Created By     :  Sanjeeb Rakshit, Somnath Mukherjee
    Date Created By:  11-NOV-2002
    Purpose        :  This package has the 8 sub processes, which will be called from
                      PSP Unit API.
                      process 1 : create_unit_version
                                    Imports Unit Version and its associated Subtitle and Curriculum
                      process 2 : create_teach_resp
                                    Imports Teaching Reponsibility.
                      process 3 : create_unit_discip
                                    Imports Unit Discipline.
                      process 4 : create_unit_grd_sch
                                    Imports Unit Grading Schema.
                                : validate_unit_dtls
                                     Validations performed across different sub process at unil level.
                      process 5 : create_unit_section
                                    Imports Unit Section and its associated Credits Point and Referrence
                      process 6 : create_usec_grd_sch
                                    Imports Unit Section Grading Schema
                      process 7 : create_usec_occur
                                    Imports Unit Section Occurrence
                      process 8 : create_unit_ref_code
                                    Imports Unit / Unit Section / Unit Section Occurrence Referrences
                     process 9 : create_uso_ins
                                    Imports Unit Section Occurrence instructors and creates unit
                                    section teaching responsibilites record if current instructor
                                    getting imported does not already exists.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sommukhe    27-SEP-2005     BUG #4632652.FND logging included.
  ********************************************************************************************** */

  g_n_user_id igs_ps_unit_ver_all.created_by%TYPE := NVL(fnd_global.user_id,-1);          -- Stores the User Id
  g_n_login_id igs_ps_unit_ver_all.last_update_login%TYPE := NVL(fnd_global.login_id,-1); -- Stores the Login Id


  PROCEDURE create_usec_res_seat(
          p_usec_res_seat_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context  IN VARCHAR2
  ) AS
  /***********************************************************************************************
    Created By     :  Sommukhe
    Date Created By:  17-Jun-2005
    Purpose        :  This procedure is a sub process to insert records of Unit Section Reserve Seating.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    --sommukhe    12-AUG-2005     Bug#4377818,changed the cursor cur_hzp, included table igs_pe_hz_parties in
    --                            FROM clause and modified the WHERE clause by joining HZ_PARTIES and IGS_PE_HZ_PARTIES
    --                            using party_id and org unit being compared with oss_org_unit_cd of IGS_PE_HZ_PARTIES.
  ********************************************************************************************** */
     /* Private Procedures for create_usec_res_seat */

    l_insert_update      VARCHAR2(1);
    l_n_uoo_id           igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_n_rsv_usec_pri_id  igs_ps_rsv_usec_pri.rsv_usec_pri_id%type;
    l_n_group_id         igs_pe_persid_group_all.group_id%TYPE;

    l_tbl_uoo            igs_ps_create_generic_pkg.uoo_tbl_type;

    PROCEDURE trim_values ( p_usec_rsv_rec IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type ) AS
    BEGIN

      p_usec_rsv_rec.unit_cd := trim(p_usec_rsv_rec.unit_cd);
      p_usec_rsv_rec.version_number := trim(p_usec_rsv_rec.version_number);
      p_usec_rsv_rec.teach_cal_alternate_code := trim(p_usec_rsv_rec.teach_cal_alternate_code);
      p_usec_rsv_rec.location_cd := trim(p_usec_rsv_rec.location_cd);
      p_usec_rsv_rec.unit_class := trim(p_usec_rsv_rec.unit_class);
      p_usec_rsv_rec.priority_order := trim(p_usec_rsv_rec.priority_order);
      p_usec_rsv_rec.priority_value := trim(p_usec_rsv_rec.priority_value);
      p_usec_rsv_rec.preference_order := trim(p_usec_rsv_rec.preference_order);
      p_usec_rsv_rec.preference_code := trim(p_usec_rsv_rec.preference_code);
      p_usec_rsv_rec.preference_version := trim(p_usec_rsv_rec.preference_version);
      p_usec_rsv_rec.percentage_reserved := trim(p_usec_rsv_rec.percentage_reserved);
    END trim_values;


    PROCEDURE create_rsvpri( p_usec_rsv_rec IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type ) AS

      -- validate parameters passed reserved seating
      PROCEDURE validate_parameters ( p_usec_rsv_rec IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type ) AS
      BEGIN

	/* Check for Mandatory Parameters */
	IF p_usec_rsv_rec.unit_cd IS NULL OR p_usec_rsv_rec.unit_cd = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;

	IF p_usec_rsv_rec.version_number IS NULL OR p_usec_rsv_rec.version_number = FND_API.G_MISS_NUM THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;

	IF p_usec_rsv_rec.teach_cal_alternate_code IS NULL OR p_usec_rsv_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;

	IF p_usec_rsv_rec.location_cd IS NULL OR p_usec_rsv_rec.location_cd = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;

	IF p_usec_rsv_rec.unit_class IS NULL OR p_usec_rsv_rec.unit_class = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CLASS', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;

	IF p_usec_rsv_rec.priority_value IS NULL OR p_usec_rsv_rec.priority_value = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PRIORITY_VALUE', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;

      END validate_parameters ;


      --validate derivations of priority
      PROCEDURE validate_derivations_pri ( p_usec_rsv_rec IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type,p_insert_update VARCHAR2 ) AS
	l_c_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE;
	l_n_seq_num  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;
	l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
	l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
	l_c_message  VARCHAR2(30);
      BEGIN
	-- Derive Calander Type and Sequence Number
	igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_usec_rsv_rec.teach_cal_alternate_code,
					       p_cal_type           => l_c_cal_type,
					       p_ci_sequence_number => l_n_seq_num,
					       p_start_dt           => l_d_start_dt,
					       p_end_dt             => l_d_end_dt,
					       p_return_status      => l_c_message );
	IF ( l_c_message <> 'SINGLE' ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;
	-- Derive uoo_id
	l_c_message := NULL;
	igs_ps_validate_lgcy_pkg.get_uoo_id ( p_unit_cd    => p_usec_rsv_rec.unit_cd,
					      p_ver_num    => p_usec_rsv_rec.version_number,
					      p_cal_type   => l_c_cal_type,
					      p_seq_num    => l_n_seq_num,
					      p_loc_cd     => p_usec_rsv_rec.location_cd,
					      p_unit_class => p_usec_rsv_rec.unit_class,
					      p_uoo_id     => l_n_uoo_id,
					      p_message    => l_c_message );
	IF ( l_c_message IS NOT NULL ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;
      END validate_derivations_pri;

      -- Check for Update
      FUNCTION check_insert_update ( p_usec_rsv_rec IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type,p_n_rsv_usec_pri_id NUMBER) RETURN VARCHAR2 IS
	 CURSOR c_usec_rsv_pri(cp_n_uoo_id NUMBER,cp_priority_value VARCHAR2) IS
	 SELECT 'X'
	 FROM   igs_ps_rsv_usec_pri
	 WHERE  uoo_id = cp_n_uoo_id
	 AND    priority_value = cp_priority_value;

	 c_usec_rsv_pri_rec c_usec_rsv_pri%ROWTYPE;
      BEGIN
	  OPEN c_usec_rsv_pri(l_n_uoo_id,p_usec_rsv_rec.priority_value );
	  FETCH c_usec_rsv_pri INTO c_usec_rsv_pri_rec;
	  IF c_usec_rsv_pri%NOTFOUND THEN
	    CLOSE c_usec_rsv_pri;
	    RETURN 'I';
	  ELSE
	   CLOSE c_usec_rsv_pri;
	   RETURN 'U';
	  END IF;
      END check_insert_update;

      PROCEDURE Assign_default(p_usec_rsv_rec IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type,p_insert_update VARCHAR2 ) AS

         CURSOR c_usprv(cp_n_uoo_id NUMBER,cp_priority_value VARCHAR2) IS
	 SELECT priority_order
	 FROM   igs_ps_rsv_usec_pri
	 WHERE  uoo_id = cp_n_uoo_id
	 AND    priority_value = cp_priority_value;

	 rec_usprv  c_usprv%ROWTYPE;

      BEGIN

	IF p_insert_update = 'U' THEN
	   OPEN c_usprv( l_n_uoo_id,p_usec_rsv_rec.priority_value);
	   FETCH c_usprv INTO rec_usprv;
	   CLOSE c_usprv;

      	   IF p_usec_rsv_rec.priority_order IS NULL  THEN
	      p_usec_rsv_rec.priority_order:= rec_usprv.priority_order;
           ELSIF p_usec_rsv_rec.priority_order = FND_API.G_MISS_NUM THEN
	      igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PRIORITY_ORDER', 'LEGACY_TOKENS', FALSE);
              p_usec_rsv_rec.status := 'E';
	   END IF;

	 END IF;

      END Assign_default;

      -- Validate Database Constraints for reserved seating priority.
      PROCEDURE validate_db_cons_rsvpri ( p_usec_rsv_rec IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type,p_insert_update VARCHAR2 ) AS
      BEGIN
	IF(p_insert_update = 'I') THEN
	  /* Unique Key Validation */
	  IF igs_ps_rsv_usec_pri_pkg.get_uk_for_validation (x_uoo_id => l_n_uoo_id,
							    x_priority_value =>p_usec_rsv_rec.priority_value ) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'USEC_RSV_PRI', 'LEGACY_TOKENS', FALSE);
	    p_usec_rsv_rec.status := 'W';
	    RETURN;
	  END IF;
	END IF;
	 /* Validate FK Constraints */

	IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;

	 IF NOT igs_lookups_view_pkg.get_pk_for_validation('RESERVE_SEAT_PRIORITY', p_usec_rsv_rec.priority_value) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'PRIORITY_VALUE', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;
      END validate_db_cons_rsvpri;

    BEGIN

      IF p_usec_rsv_rec.status = 'S' THEN
        validate_parameters(p_usec_rsv_rec);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvpri.status_after_validate_parameters',
	  'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||'Status:'
	  ||p_usec_rsv_rec.status);
        END IF;

      END IF;

      IF p_usec_rsv_rec.status = 'S' THEN
        validate_derivations_pri(p_usec_rsv_rec,l_insert_update);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvpri.status_after_validate_derivations_pri',
	  'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||'Status:'
	  ||p_usec_rsv_rec.status);
        END IF;

      END IF;


      --Find out whether it is insert/update of record
      l_insert_update:='I';
      IF p_usec_rsv_rec.status = 'S' AND p_calling_context IN ('G','S') THEN
        l_insert_update:= check_insert_update(p_usec_rsv_rec,l_n_rsv_usec_pri_id);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvpri.status_after_check_insert_update',
	  'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||'Status:'
	  ||p_usec_rsv_rec.status);
        END IF;

      END IF;


      IF p_usec_rsv_rec.status = 'S' AND p_calling_context = 'S'  THEN
        IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
          fnd_msg_pub.add;
          p_usec_rsv_rec.status := 'A';
        END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvpri.status_after_check_import_allowed',
	  'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||'Status:'
	  ||p_usec_rsv_rec.status);
        END IF;

      END IF;

      IF p_usec_rsv_rec.status = 'S' THEN
	 Assign_default(p_usec_rsv_rec,l_insert_update);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvpri.status_after_Assign_default',
	   'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||'Status:'
	   ||p_usec_rsv_rec.status);
         END IF;

      END IF;



      IF l_tbl_uoo.count = 0 THEN
        l_tbl_uoo(l_tbl_uoo.count+1) :=l_n_uoo_id;
      ELSE
        IF NOT igs_ps_validate_lgcy_pkg.isExists(l_n_uoo_id,l_tbl_uoo) THEN
	  l_tbl_uoo(l_tbl_uoo.count+1) :=l_n_uoo_id;
	END IF;
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvpri.Count_unique_uoo_ids',
	'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||'Count:'||l_tbl_uoo.count);
      END IF;

      IF p_usec_rsv_rec.status = 'S' THEN
        validate_db_cons_rsvpri(p_usec_rsv_rec,l_insert_update);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvpri.status_after_validate_db_cons_rsvpri',
	  'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||'Status:'
	  ||p_usec_rsv_rec.status);
        END IF;

      END IF;


      IF p_usec_rsv_rec.status = 'S' THEN
        igs_ps_validate_generic_pkg.validate_usec_rsvpri (p_usec_rsv_rec,l_n_uoo_id,l_insert_update);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvpri.status_after_Business_validation',
	  'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||'Status:'
	  ||p_usec_rsv_rec.status);
        END IF;

      END IF;


      IF p_usec_rsv_rec.status = 'S' THEN
	 IF l_insert_update = 'I' THEN
              /* Insert Record */
              INSERT INTO igs_ps_rsv_usec_pri
	      (
	      rsv_usec_pri_id,
              uoo_id,
              priority_order,
              priority_value,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login
	      )
	      VALUES
	      (
              igs_ps_rsv_usec_pri_s.nextval,
              l_n_uoo_id,
              p_usec_rsv_rec.priority_order,
              p_usec_rsv_rec.priority_value,
              g_n_user_id,
              sysdate,
              g_n_user_id,
              sysdate,
              g_n_login_id
	      );

	      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvpri.Record_Inserted',
		'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
		||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
		p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value);
	      END IF;

         ELSE --update
	     UPDATE igs_ps_rsv_usec_pri SET
             priority_order= p_usec_rsv_rec.priority_order,
             last_updated_by = g_n_user_id,
             last_update_date= SYSDATE ,
             last_update_login= g_n_login_id
	     WHERE uoo_id =l_n_uoo_id AND priority_value = p_usec_rsv_rec.priority_value;

             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvpri.Record_Updated',
		'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
		||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
		p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value);
	     END IF;


         END IF;
      END IF;

    END create_rsvpri;

    PROCEDURE create_rsvprf( p_usec_rsv_rec IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type ) AS

      PROCEDURE validate_parameters_prf ( p_usec_rsv_rec IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type ) AS
      BEGIN

	/* Check for Mandatory Parameters */
	IF p_usec_rsv_rec.preference_order IS NULL OR p_usec_rsv_rec.preference_order = FND_API.G_MISS_NUM THEN
	   igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PREFERENCE_ORDER', 'LEGACY_TOKENS', FALSE);
	   p_usec_rsv_rec.status := 'E';
	END IF;

	IF p_usec_rsv_rec.preference_code IS NULL OR p_usec_rsv_rec.preference_code = FND_API.G_MISS_CHAR THEN
	   igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PREFERENCE_CODE', 'LEGACY_TOKENS', FALSE);
	   p_usec_rsv_rec.status := 'E';
	END IF;

	IF p_usec_rsv_rec.percentage_reserved IS NULL OR p_usec_rsv_rec.percentage_reserved = FND_API.G_MISS_NUM THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PERCENTAGE_RESERVED', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;

	IF p_usec_rsv_rec.priority_value IS NOT NULL AND p_usec_rsv_rec.priority_value IN ('PROGRAM','UNIT_SET') THEN
	  IF p_usec_rsv_rec.preference_version IS NULL OR p_usec_rsv_rec.preference_version = FND_API.G_MISS_NUM THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PREFERENCE_VERSION', 'LEGACY_TOKENS', FALSE);
	    p_usec_rsv_rec.status := 'E';
	  END IF;
	ELSIF p_usec_rsv_rec.priority_value IS NOT NULL AND p_usec_rsv_rec.priority_value NOT IN ('PROGRAM','UNIT_SET') THEN
	  IF p_usec_rsv_rec.preference_version IS NOT NULL THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'PREFERENCE_VERSION', 'LEGACY_TOKENS', FALSE);
	    p_usec_rsv_rec.status := 'E';
	  END IF;
	END IF;

      END validate_parameters_prf ;

      -- Carry out derivations and validate them
      PROCEDURE validate_derivations_prf ( p_usec_rsv_rec IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type,p_insert_update VARCHAR2 ) AS
	l_c_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE;
	l_n_seq_num  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;
	l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
	l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
	l_c_message  VARCHAR2(30);

	 CURSOR c_pri_id(cp_uoo_id NUMBER, cp_priority_value igs_ps_rsv_usec_pri.priority_value%type) IS
	 SELECT rsv_usec_pri_id
	 FROM   igs_ps_rsv_usec_pri
	 WHERE  uoo_id = cp_uoo_id
	 AND    priority_value = cp_priority_value;

      BEGIN

	OPEN c_pri_id(l_n_uoo_id,p_usec_rsv_rec.priority_value);
	FETCH c_pri_id INTO l_n_rsv_usec_pri_id;
	CLOSE c_pri_id;

      END validate_derivations_prf;


      FUNCTION check_insert_update ( p_usec_rsv_rec IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type,p_n_rsv_usec_pri_id NUMBER) RETURN VARCHAR2 IS
        CURSOR c_usec_rsv_prf(p_rsv_usec_pri_id NUMBER,p_preference_code VARCHAR2) IS
        SELECT 'X'
	FROM   igs_ps_rsv_usec_prf
        WHERE  rsv_usec_pri_id = p_rsv_usec_pri_id
        AND    preference_code = p_preference_code;

        c_usec_rsv_prf_rec c_usec_rsv_prf%ROWTYPE;

        CURSOR c_usec_rsv_prf1(cp_rsv_usec_pri_id NUMBER,cp_preference_code VARCHAR2,cp_preference_version NUMBER) IS
        SELECT 'X'
	FROM   igs_ps_rsv_usec_prf
        WHERE  rsv_usec_pri_id = cp_rsv_usec_pri_id
        AND    preference_code = cp_preference_code
        AND    preference_version = cp_preference_version;

        c_usec_rsv_prf1_rec c_usec_rsv_prf1%ROWTYPE;
      BEGIN
        IF p_usec_rsv_rec.priority_value IN ('PROGRAM', 'UNIT_SET') THEN
  	  OPEN c_usec_rsv_prf1(l_n_rsv_usec_pri_id,p_usec_rsv_rec.preference_code,p_usec_rsv_rec.preference_version );
	  FETCH c_usec_rsv_prf1 INTO c_usec_rsv_prf1_rec;
	  IF c_usec_rsv_prf1%NOTFOUND THEN
            CLOSE c_usec_rsv_prf1;
	    RETURN 'I';
          ELSE
            CLOSE c_usec_rsv_prf1;
	    RETURN 'U';
          END IF;
        ELSE
          OPEN c_usec_rsv_prf(l_n_rsv_usec_pri_id,p_usec_rsv_rec.preference_code );
	  FETCH c_usec_rsv_prf INTO c_usec_rsv_prf_rec;
	  IF c_usec_rsv_prf%NOTFOUND THEN
            CLOSE c_usec_rsv_prf;
	    RETURN 'I';
          ELSE
            CLOSE c_usec_rsv_prf;
	    RETURN 'U';
          END IF;
        END IF;
      END check_insert_update;

      -- Validate Database Constraints for reserved seating preference.
      PROCEDURE validate_db_cons_rsvprf ( p_usec_rsv_rec IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type,p_insert_update VARCHAR2 ) AS
      CURSOR cur_hzp(cp_preference_code VARCHAR2) IS
      SELECT 'x'
      FROM   hz_parties hp, igs_pe_hz_parties pe
      WHERE  hp.party_id = pe.party_id
      AND pe.oss_org_unit_cd =cp_preference_code;

      cur_Hzp_rec cur_Hzp%ROWTYPE;

      CURSOR c_group(cp_preference_code VARCHAR2) IS
      SELECT group_id
      FROM   igs_pe_persid_group_all
      WHERE  group_cd = cp_preference_code;

      BEGIN

	IF(p_insert_update = 'I') THEN
	  /* Unique Key Validation */
	  IF igs_ps_rsv_usec_prf_pkg.get_uk_for_validation(x_rsv_usec_pri_id => l_n_rsv_usec_pri_id ,
							    x_preference_code =>p_usec_rsv_rec.preference_code ) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'USEC_RSV_PRF', 'LEGACY_TOKENS', FALSE);
	    p_usec_rsv_rec.status := 'W';

	    RETURN;
	  END IF;
	END IF;

	/* check constraint */
	IF p_usec_rsv_rec.percentage_reserved < 0 OR p_usec_rsv_rec.percentage_reserved > 100 THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PER_0_100', null, null, FALSE);
          p_usec_rsv_rec.status := 'E';
	END IF;

	 /* Validate FK Constraints */
	IF (p_usec_rsv_rec.priority_value = 'PROGRAM') THEN
	  IF NOT igs_ps_ver_pkg.get_pk_for_validation (p_usec_rsv_rec.preference_code,p_usec_rsv_rec.preference_version  ) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_RSV_PRF', 'LEGACY_TOKENS', FALSE);
	    p_usec_rsv_rec.status := 'E';
	  END IF;
	END IF;

	IF (p_usec_rsv_rec.priority_value = 'PERSON_GRP') THEN
	  IF NOT igs_pe_persid_group_pkg.get_uk_for_validation (p_usec_rsv_rec.preference_code  ) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_RSV_PRF', 'LEGACY_TOKENS', FALSE);
	    p_usec_rsv_rec.status := 'E';
	  END IF;
	  OPEN c_group(p_usec_rsv_rec.preference_code);
	  FETCH c_group INTO l_n_group_id;
	  CLOSE c_group;
	END IF;

	IF (p_usec_rsv_rec.priority_value = 'UNIT_SET') THEN
	  IF NOT igs_en_unit_set_pkg.get_pk_for_validation (p_usec_rsv_rec.preference_code,p_usec_rsv_rec.preference_version) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_RSV_PRF', 'LEGACY_TOKENS', FALSE);
	    p_usec_rsv_rec.status := 'E';
	  END IF;
	END IF;

	IF (p_usec_rsv_rec.priority_value = 'PROGRAM_STAGE') THEN
	  IF NOT igs_ps_stage_type_pkg.get_pk_for_validation (p_usec_rsv_rec.preference_code  ) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_RSV_PRF', 'LEGACY_TOKENS', FALSE);
	    p_usec_rsv_rec.status := 'E';
	  END IF;
	END IF;

	IF (p_usec_rsv_rec.priority_value = 'CLASS_STD' ) THEN
	  IF NOT igs_pr_class_std_pkg.get_uk_for_validation (p_usec_rsv_rec.preference_code  ) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_RSV_PRF', 'LEGACY_TOKENS', FALSE);
	    p_usec_rsv_rec.status := 'E';
	  END IF;
	END IF;

	IF (p_usec_rsv_rec.priority_value = 'ORG_UNIT') THEN
	  OPEN  cur_hzp(p_usec_rsv_rec.preference_code );
	  FETCH cur_hzp INTO cur_hzp_rec;
	  IF cur_hzp%NOTFOUND THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_RSV_PRF', 'LEGACY_TOKENS', FALSE);
	    p_usec_rsv_rec.status := 'E';
	  END IF;
	  CLOSE cur_hzp;
	END IF;
      END validate_db_cons_rsvprf;

    BEGIN

      IF p_usec_rsv_rec.status = 'S' THEN
        validate_parameters_prf(p_usec_rsv_rec);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvprf.status_after_validate_parameters_prf',
	  'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||
	  'Preference Code:'||p_usec_rsv_rec.preference_code||' '||'Status:'||p_usec_rsv_rec.status);
        END IF;

      END IF;

      IF p_usec_rsv_rec.status = 'S' THEN
        validate_derivations_prf(p_usec_rsv_rec,l_insert_update);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvprf.status_after_validate_derivations_prf',
	  'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||
	  'Preference Code:'||p_usec_rsv_rec.preference_code||' '||'Status:'||p_usec_rsv_rec.status);
        END IF;

      END IF;


      --Find out whether it is insert/update of record
      l_insert_update:='I';
      IF p_usec_rsv_rec.status = 'S' AND p_calling_context IN ('G', 'S') THEN
        l_insert_update:= check_insert_update(p_usec_rsv_rec,l_n_rsv_usec_pri_id);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvprf.status_after_check_insert_update',
	  'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||
	  'Preference Code:'||p_usec_rsv_rec.preference_code||' '||'Status:'||p_usec_rsv_rec.status);
        END IF;

      END IF;


      IF p_usec_rsv_rec.status = 'S' THEN
         validate_db_cons_rsvprf(p_usec_rsv_rec,l_insert_update);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvprf.status_after_validate_db_cons_rsvprf',
	  'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||
	  'Preference Code:'||p_usec_rsv_rec.preference_code||' '||'Status:'||p_usec_rsv_rec.status);
         END IF;

      END IF;


      IF p_usec_rsv_rec.status = 'S' THEN
         igs_ps_validate_generic_pkg.validate_usec_rsvprf (p_usec_rsv_rec,l_insert_update);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvprf.status_after_Business_validation',
	   'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||
	   'Preference Code:'||p_usec_rsv_rec.preference_code||' '||'Status:'||p_usec_rsv_rec.status);
         END IF;

      END IF;


      IF p_usec_rsv_rec.status = 'S' THEN
	IF l_insert_update = 'I' THEN
          /* Insert Record */
          INSERT INTO igs_ps_rsv_usec_prf (
          rsv_usec_prf_id,
          rsv_usec_pri_id,
          preference_order,
          preference_code,
          preference_version,
          percentage_reserved,
          group_id,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login )
          VALUES (
          igs_ps_rsv_usec_prf_s.NEXTVAL,
          l_n_rsv_usec_pri_id,
          p_usec_rsv_rec.preference_order,
          p_usec_rsv_rec.preference_code,
	  p_usec_rsv_rec.preference_version,
          p_usec_rsv_rec.percentage_reserved,
          l_n_group_id,
          g_n_user_id,
          sysdate,
          g_n_user_id,
          sysdate,
          g_n_login_id );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvprf.status_after_Record_Inserted',
	     'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||
	     'Preference Code:'||p_usec_rsv_rec.preference_code);
          END IF;


        ELSE --update
	  UPDATE igs_ps_rsv_usec_prf SET
          preference_order= p_usec_rsv_rec.preference_order,
          percentage_reserved=p_usec_rsv_rec.percentage_reserved,
          preference_version=p_usec_rsv_rec.preference_version,
          last_updated_by = g_n_user_id,
          last_update_date= SYSDATE ,
          last_update_login= g_n_login_id
	  WHERE rsv_usec_pri_id  =l_n_rsv_usec_pri_id AND preference_code = p_usec_rsv_rec.preference_code;

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvprf.status_after_Record_Updated',
	     'Unit code:'||p_usec_rsv_rec.unit_cd||'  '||'Version number:'||p_usec_rsv_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_rsv_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rsv_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_rsv_rec.unit_class||'  '||'Priority Value:'||p_usec_rsv_rec.priority_value||'  '||
	     'Preference Code:'||p_usec_rsv_rec.preference_code);
          END IF;

        END IF;
      END IF;

    END create_rsvprf;

  /* Main Unit Section reserved seating Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.start_logging_for','Unit Section reserved Seating');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_usec_res_seat_tbl.LAST LOOP
      l_n_uoo_id:= NULL;
      l_n_rsv_usec_pri_id:=NULL;
      l_n_group_id := NULL;
      IF p_usec_res_seat_tbl.EXISTS(I) THEN
        p_usec_res_seat_tbl(I).status := 'S';
        p_usec_res_seat_tbl(I).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_usec_res_seat_tbl(I));


	--create reserved seating priority
	IF p_usec_res_seat_tbl(I).status = 'S' THEN

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvpri.call',
	    'Unit code:'||p_usec_res_seat_tbl(I).unit_cd||'  '||'Version number:'||p_usec_res_seat_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_res_seat_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_res_seat_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_res_seat_tbl(I).unit_class||'  '||'Priority Value:'||p_usec_res_seat_tbl(I).priority_value);
          END IF;

	  create_rsvpri(p_usec_res_seat_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvpri.status_after_creating_priority_record',
	    'Unit code:'||p_usec_res_seat_tbl(I).unit_cd||'  '||'Version number:'||p_usec_res_seat_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_res_seat_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_res_seat_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_res_seat_tbl(I).unit_class||'  '||'Priority Value:'||p_usec_res_seat_tbl(I).priority_value||'  '||'Status:'
	    ||p_usec_res_seat_tbl(I).status);
          END IF;

        END IF;

        -- Create reserved seating preference
	IF  p_usec_res_seat_tbl(I).status = 'S' THEN
	  IF p_usec_res_seat_tbl(I).preference_code IS NOT NULL THEN

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvprf.call',
	      'Unit code:'||p_usec_res_seat_tbl(I).unit_cd||'  '||'Version number:'||p_usec_res_seat_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_res_seat_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_res_seat_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_res_seat_tbl(I).unit_class||'  '||'Priority Value:'||p_usec_res_seat_tbl(I).priority_value||' '||
	      'Preference Code:'||p_usec_res_seat_tbl(I).preference_code);
            END IF;

            create_rsvprf(p_usec_res_seat_tbl(I));

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.create_rsvprf.status_after_creating_prefenrence_record',
	      'Unit code:'||p_usec_res_seat_tbl(I).unit_cd||'  '||'Version number:'||p_usec_res_seat_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_res_seat_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_res_seat_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_res_seat_tbl(I).unit_class||'  '||'Priority Value:'||p_usec_res_seat_tbl(I).priority_value||'  '||
	      'Preference Code:'||p_usec_res_seat_tbl(I).preference_code||' '||'Status:'||p_usec_res_seat_tbl(I).status);
            END IF;

          END IF;
	END IF;

        IF  p_usec_res_seat_tbl(I).status = 'S' THEN
          p_usec_res_seat_tbl(I).msg_from := NULL;
          p_usec_res_seat_tbl(I).msg_to := NULL;
        ELSIF  p_usec_res_seat_tbl(I).status = 'A' THEN
	  p_usec_res_seat_tbl(I).msg_from  := p_usec_res_seat_tbl(I).msg_from + 1;
	  p_usec_res_seat_tbl(I).msg_to := fnd_msg_pub.count_msg;
	ELSE
          p_c_rec_status :=  p_usec_res_seat_tbl(I).status;
          p_usec_res_seat_tbl(I).msg_from :=  p_usec_res_seat_tbl(I).msg_from + 1;
          p_usec_res_seat_tbl(I).msg_to := fnd_msg_pub.count_msg;
          IF p_c_rec_status = 'E' THEN
            RETURN;
          END IF;
        END IF;
      END IF;--exists
    END LOOP;

    /* Post Insert/Update Checks */
    IF NOT igs_ps_validate_generic_pkg.post_usec_rsv(p_usec_res_seat_tbl,l_tbl_uoo) THEN
      p_c_rec_status := 'E';
    END IF;

    l_tbl_uoo.DELETE;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_res_seat.after_import_status',p_c_rec_status);
    END IF;

  END create_usec_res_seat;

  PROCEDURE create_uso_facility (p_usec_occurs_facility_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_occurs_facility_tbl_type,
                                 p_c_rec_status OUT NOCOPY VARCHAR2,
                                 p_calling_context  IN VARCHAR2
  )  AS

  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:  17-MAR-2005
    Purpose        :  This procedure is a sub process to insert records of Unit Section Occurrence Facility.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What

  ********************************************************************************************** */
    l_n_uoo_id   igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_n_uso_id   igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE;

    /* Private Procedures for create_uso_facility */
    PROCEDURE trim_values ( p_uso_fclt_rec IN OUT NOCOPY igs_ps_generic_pub.usec_occurs_facility_rec_type ) AS
    BEGIN

      p_uso_fclt_rec.unit_cd := TRIM(p_uso_fclt_rec.unit_cd);
      p_uso_fclt_rec.version_number := TRIM(p_uso_fclt_rec.version_number);
      p_uso_fclt_rec.teach_cal_alternate_code := TRIM(p_uso_fclt_rec.teach_cal_alternate_code);
      p_uso_fclt_rec.location_cd := TRIM(p_uso_fclt_rec.location_cd);
      p_uso_fclt_rec.unit_class := TRIM(p_uso_fclt_rec.unit_class);
      p_uso_fclt_rec.production_uso_id := TRIM(p_uso_fclt_rec.production_uso_id);
      p_uso_fclt_rec.occurrence_identifier := TRIM(p_uso_fclt_rec.occurrence_identifier);
      p_uso_fclt_rec.facility_code := TRIM(p_uso_fclt_rec.facility_code);
    END trim_values;

    -- validate parameters passed.
    PROCEDURE validate_parameters (p_uso_fclt_rec IN OUT NOCOPY igs_ps_generic_pub.usec_occurs_facility_rec_type ) AS
    BEGIN
      /* Check for Mandatory Parameters */
      IF p_uso_fclt_rec.unit_cd IS NULL OR p_uso_fclt_rec.unit_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_uso_fclt_rec.status := 'E';
      END IF;
      IF p_uso_fclt_rec.version_number IS NULL OR p_uso_fclt_rec.version_number = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
        p_uso_fclt_rec.status := 'E';
      END IF;
      IF p_uso_fclt_rec.teach_cal_alternate_code IS NULL OR p_uso_fclt_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_uso_fclt_rec.status := 'E';
      END IF;
      IF p_uso_fclt_rec.location_cd IS NULL OR p_uso_fclt_rec.location_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD', 'LEGACY_TOKENS', FALSE);
        p_uso_fclt_rec.status := 'E';
      END IF;
      IF p_uso_fclt_rec.unit_class IS NULL OR p_uso_fclt_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CLASS', 'LEGACY_TOKENS', FALSE);
        p_uso_fclt_rec.status := 'E';
      END IF;
      IF (p_uso_fclt_rec.production_uso_id IS NULL OR p_uso_fclt_rec.production_uso_id = FND_API.G_MISS_NUM) AND  (p_uso_fclt_rec.occurrence_identifier IS NULL OR p_uso_fclt_rec.occurrence_identifier = FND_API.G_MISS_CHAR) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'USEC_OCCRS_ID', 'IGS_PS_LOG_PARAMETERS', FALSE);
        p_uso_fclt_rec.status := 'E';
      END IF;
      IF p_uso_fclt_rec.facility_code IS NULL OR p_uso_fclt_rec.facility_code = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'FACILITY_CODE', 'LEGACY_TOKENS', FALSE);
        p_uso_fclt_rec.status := 'E';
      END IF;

    END validate_parameters;

    PROCEDURE validate_derivations ( p_uso_fclt_rec IN OUT NOCOPY igs_ps_generic_pub.usec_occurs_facility_rec_type ) AS
      l_c_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE;
      l_n_seq_num  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;
      l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
      l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
      l_c_message  VARCHAR2(30);

      CURSOR c_uso_id (cp_occurrence_identifier igs_ps_usec_occurs_all.occurrence_identifier%TYPE,cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
      SELECT unit_section_occurrence_id
      FROM igs_ps_usec_occurs_all
      WHERE uoo_id = cp_n_uoo_id
      AND occurrence_identifier = cp_occurrence_identifier;


    BEGIN


      -- Derive Calander Type and Sequence Number
      igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_uso_fclt_rec.teach_cal_alternate_code,
                                             p_cal_type           => l_c_cal_type,
                                             p_ci_sequence_number => l_n_seq_num,
                                             p_start_dt           => l_d_start_dt,
                                             p_end_dt             => l_d_end_dt,
                                             p_return_status      => l_c_message );
      IF ( l_c_message <> 'SINGLE' ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_uso_fclt_rec.status := 'E';
      END IF;


      -- Derive uoo_id
      l_c_message := NULL;
      igs_ps_validate_lgcy_pkg.get_uoo_id ( p_unit_cd    => p_uso_fclt_rec.unit_cd,
                                            p_ver_num    => p_uso_fclt_rec.version_number,
                                            p_cal_type   => l_c_cal_type,
                                            p_seq_num    => l_n_seq_num,
                                            p_loc_cd     => p_uso_fclt_rec.location_cd,
                                            p_unit_class => p_uso_fclt_rec.unit_class,
                                            p_uoo_id     => l_n_uoo_id,
                                            p_message    => l_c_message );
      IF ( l_c_message IS NOT NULL ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_uso_fclt_rec.status := 'E';
      END IF;

      IF p_uso_fclt_rec.production_uso_id IS NOT NULL THEN
        l_n_uso_id := p_uso_fclt_rec.production_uso_id;
      ELSE
        OPEN c_uso_id(p_uso_fclt_rec.occurrence_identifier,l_n_uoo_id);
        FETCH c_uso_id INTO l_n_uso_id;
	IF c_uso_id%NOTFOUND THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'USEC_OCCRS_ID', 'IGS_PS_LOG_PARAMETERS', FALSE);
	  p_uso_fclt_rec.status := 'E';
	END IF;
        CLOSE c_uso_id;
      END IF;

    END validate_derivations;

    -- Validate Database Constraints
    PROCEDURE validate_db_cons ( p_uso_fclt_rec IN OUT NOCOPY igs_ps_generic_pub.usec_occurs_facility_rec_type ) AS
    BEGIN

      /* Validate UK Constraints */
      IF igs_ps_uso_facility_pkg.get_uk_for_validation (
           x_unit_section_occurrence_id           => l_n_uso_id,
	   x_facility_code                        =>  p_uso_fclt_rec.facility_code
           ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'FACILITY', 'LEGACY_TOKENS', FALSE);
        p_uso_fclt_rec.status := 'W';
        RETURN;
      END IF;

       /* Validate FK Constraints */
      IF NOT igs_ps_media_equip_pkg.get_pk_for_validation (p_uso_fclt_rec.facility_code) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'FACILITY_CODE', 'LEGACY_TOKENS', FALSE);
        p_uso_fclt_rec.status := 'E';
      END IF;

      IF NOT igs_ps_usec_occurs_pkg.get_pk_for_validation (l_n_uso_id) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_OCCUR', 'LEGACY_TOKENS', FALSE);
        p_uso_fclt_rec.status := 'E';
      END IF;

    END validate_db_cons;

  /* Main facilities Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_facility.start_logging_for','Unit Section Occurence facility');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_usec_occurs_facility_tbl.LAST LOOP
      IF ( p_usec_occurs_facility_tbl.EXISTS(I) ) THEN
        l_n_uoo_id      := NULL;
	l_n_uso_id      := NULL;
        p_usec_occurs_facility_tbl(I).status := 'S';
        p_usec_occurs_facility_tbl(I).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_usec_occurs_facility_tbl(I) );
        validate_parameters ( p_usec_occurs_facility_tbl(I) );

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_facility.status_after_validate_parameters',
	  'Unit code:'||p_usec_occurs_facility_tbl(I).unit_cd||'  '||'Version number:'||p_usec_occurs_facility_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_occurs_facility_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_occurs_facility_tbl(I).location_cd||'  '||'Unit Class:'||
	  p_usec_occurs_facility_tbl(I).unit_class||'  '||'Facility Code:'||p_usec_occurs_facility_tbl(I).facility_code||'  '||'Status:'||p_usec_occurs_facility_tbl(I).status);
        END IF;


	IF p_usec_occurs_facility_tbl(I).status = 'S' THEN
	    validate_derivations ( p_usec_occurs_facility_tbl(I));

	    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_facility.status_after_validate_derivations',
	      'Unit code:'||p_usec_occurs_facility_tbl(I).unit_cd||'  '||'Version number:'||p_usec_occurs_facility_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_occurs_facility_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_occurs_facility_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_occurs_facility_tbl(I).unit_class||'  '||'Facility Code:'||p_usec_occurs_facility_tbl(I).facility_code||'Unit Section Occurrence id:'||
	      l_n_uso_id||'  '||'Status:'||p_usec_occurs_facility_tbl(I).status);
            END IF;

        END IF;

        -- Find out whether record can go for import in context of cancelled/aborted
        IF p_usec_occurs_facility_tbl(I).status = 'S' AND p_calling_context ='S' THEN
	  IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,l_n_uso_id) = FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	    fnd_msg_pub.add;
	    p_usec_occurs_facility_tbl(I).status := 'A';
	  END IF;

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_facility.status_after_check_import_allowed',
	    'Unit code:'||p_usec_occurs_facility_tbl(I).unit_cd||'  '||'Version number:'||p_usec_occurs_facility_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_occurs_facility_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_occurs_facility_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_occurs_facility_tbl(I).unit_class||'  '||'Facility Code:'||p_usec_occurs_facility_tbl(I).facility_code||'Unit Section Occurrence id:'
	    ||l_n_uso_id||'  '||'Status:'||p_usec_occurs_facility_tbl(I).status);
          END IF;

	END IF;

	IF p_usec_occurs_facility_tbl(I).status = 'S' THEN
          validate_db_cons ( p_usec_occurs_facility_tbl(I) );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_facility.status_after_validate_db_cons',
	    'Unit code:'||p_usec_occurs_facility_tbl(I).unit_cd||'  '||'Version number:'||p_usec_occurs_facility_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_occurs_facility_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_occurs_facility_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_occurs_facility_tbl(I).unit_class||'  '||'Facility Code:'||p_usec_occurs_facility_tbl(I).facility_code||'Unit Section Occurrence id:'
	    ||l_n_uso_id||'  '||'Status:'||p_usec_occurs_facility_tbl(I).status);
          END IF;

        END IF;

        /* Business Validations */
        /* Proceed with business validations only if the status is Success, 'S' */
        IF p_usec_occurs_facility_tbl(I).status = 'S' THEN
           igs_ps_validate_generic_pkg.validate_facility ( p_usec_occurs_facility_tbl(I),l_n_uoo_id,l_n_uso_id,p_calling_context) ;

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_facility.status_after_Business_validations',
	     'Unit code:'||p_usec_occurs_facility_tbl(I).unit_cd||'  '||'Version number:'||p_usec_occurs_facility_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_occurs_facility_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_occurs_facility_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_occurs_facility_tbl(I).unit_class||'  '||'Facility Code:'||p_usec_occurs_facility_tbl(I).facility_code||'Unit Section Occurrence id:'
	     ||l_n_uso_id||'  '||'Status:'||p_usec_occurs_facility_tbl(I).status);
           END IF;

        END IF;

        IF p_usec_occurs_facility_tbl(I).status = 'S' THEN
            /* Insert record */
          INSERT INTO igs_ps_uso_facility
          (uso_facility_id,
           unit_section_occurrence_id,
           facility_code,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
          )
          VALUES
          (IGS_PS_USO_FACILITY_S.nextval,
           l_n_uso_id,
           p_usec_occurs_facility_tbl(I).facility_code,
           g_n_user_id,
           SYSDATE,
           g_n_user_id,
           SYSDATE,
           g_n_login_id
          );

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_facility.Record_Inserted',
	     'Unit code:'||p_usec_occurs_facility_tbl(I).unit_cd||'  '||'Version number:'||p_usec_occurs_facility_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_occurs_facility_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_occurs_facility_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_occurs_facility_tbl(I).unit_class||'  '||'Facility Code:'||p_usec_occurs_facility_tbl(I).facility_code||'Unit Section Occurrence id:'
	     ||l_n_uso_id);
           END IF;

        END IF;--insert

        IF p_usec_occurs_facility_tbl(I).status = 'S' THEN
	   p_usec_occurs_facility_tbl(I).msg_from := NULL;
	   p_usec_occurs_facility_tbl(I).msg_to := NULL;
	ELSIF  p_usec_occurs_facility_tbl(I).status = 'A' THEN
	   p_usec_occurs_facility_tbl(I).msg_from  := p_usec_occurs_facility_tbl(I).msg_from + 1;
	   p_usec_occurs_facility_tbl(I).msg_to := fnd_msg_pub.count_msg;
	ELSE
           p_c_rec_status := p_usec_occurs_facility_tbl(I).status;
           p_usec_occurs_facility_tbl(I).msg_from :=p_usec_occurs_facility_tbl(I).msg_from+1;
           p_usec_occurs_facility_tbl(I).msg_to := fnd_msg_pub.count_msg;
           IF p_usec_occurs_facility_tbl(I).status = 'E' THEN
             RETURN;
	   END IF;
         END IF;

      END IF;--Exists
    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_facility.after_import_status',p_c_rec_status);
    END IF;

  END create_uso_facility;



  PROCEDURE create_usec_cat (
          p_usec_cat_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_cat_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context  IN VARCHAR2
          )  AS

  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:  17-Jun-2005
    Purpose        :  This procedure is a sub process to insert records of Unit Section Catogories.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What

  ********************************************************************************************** */
    l_n_uoo_id           igs_ps_unit_ofr_opt_all.uoo_id%TYPE;

    /* Private Procedures for create_usec_cat */
    PROCEDURE trim_values ( p_usec_cat_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cat_rec_type ) AS
    BEGIN
      p_usec_cat_rec.unit_cd := TRIM(p_usec_cat_rec.unit_cd);
      p_usec_cat_rec.version_number := TRIM(p_usec_cat_rec.version_number);
      p_usec_cat_rec.teach_cal_alternate_code := TRIM(p_usec_cat_rec.teach_cal_alternate_code);
      p_usec_cat_rec.location_cd := TRIM(p_usec_cat_rec.location_cd);
      p_usec_cat_rec.unit_class := TRIM(p_usec_cat_rec.unit_class);
      p_usec_cat_rec.unit_cat := TRIM(p_usec_cat_rec.unit_cat);
    END trim_values;

    -- validate parameters passed.
    PROCEDURE validate_parameters (p_usec_cat_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cat_rec_type ) AS
    BEGIN
      /* Check for Mandatory Parameters */
      IF p_usec_cat_rec.unit_cd IS NULL OR p_usec_cat_rec.unit_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_cat_rec.status := 'E';
      END IF;
      IF p_usec_cat_rec.version_number IS NULL OR p_usec_cat_rec.version_number = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
        p_usec_cat_rec.status := 'E';
      END IF;
      IF p_usec_cat_rec.teach_cal_alternate_code IS NULL OR p_usec_cat_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_cat_rec.status := 'E';
      END IF;
      IF p_usec_cat_rec.location_cd IS NULL OR p_usec_cat_rec.location_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_cat_rec.status := 'E';
      END IF;
      IF p_usec_cat_rec.unit_class IS NULL OR p_usec_cat_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CLASS', 'LEGACY_TOKENS', FALSE);
        p_usec_cat_rec.status := 'E';
      END IF;
      IF p_usec_cat_rec.unit_cat IS NULL OR p_usec_cat_rec.unit_cat = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'CATEGORY', 'LEGACY_TOKENS', FALSE);
        p_usec_cat_rec.status := 'E';
      END IF;

    END validate_parameters;

    PROCEDURE validate_derivations ( p_usec_cat_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cat_rec_type ) AS
      l_c_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE;
      l_n_seq_num  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;
      l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
      l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
      l_c_message  VARCHAR2(30);

    BEGIN


      -- Derive Calander Type and Sequence Number
      igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_usec_cat_rec.teach_cal_alternate_code,
                                             p_cal_type           => l_c_cal_type,
                                             p_ci_sequence_number => l_n_seq_num,
                                             p_start_dt           => l_d_start_dt,
                                             p_end_dt             => l_d_end_dt,
                                             p_return_status      => l_c_message );
      IF ( l_c_message <> 'SINGLE' ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_cat_rec.status := 'E';
      END IF;


      -- Derive uoo_id
      l_c_message := NULL;
      igs_ps_validate_lgcy_pkg.get_uoo_id ( p_unit_cd    => p_usec_cat_rec.unit_cd,
                                            p_ver_num    => p_usec_cat_rec.version_number,
                                            p_cal_type   => l_c_cal_type,
                                            p_seq_num    => l_n_seq_num,
                                            p_loc_cd     => p_usec_cat_rec.location_cd,
                                            p_unit_class => p_usec_cat_rec.unit_class,
                                            p_uoo_id     => l_n_uoo_id,
                                            p_message    => l_c_message );

      IF ( l_c_message IS NOT NULL ) THEN

        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_usec_cat_rec.status := 'E';

      END IF;

    END validate_derivations;

    -- Validate Database Constraints
    PROCEDURE validate_db_cons ( p_usec_cat_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cat_rec_type ) AS
    BEGIN

      /* Validate UK Constraints */
      IF igs_ps_usec_category_pkg.get_uk_for_validation (
           x_uoo_id           => l_n_uoo_id,
	   x_unit_cat         => p_usec_cat_rec.unit_cat
           ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'CATEGORY', 'LEGACY_TOKENS', FALSE);
        p_usec_cat_rec.status := 'W';
        RETURN;
      END IF;

       /* Validate FK Constraints */
      IF NOT igs_ps_unit_cat_pkg.get_pk_for_validation (p_usec_cat_rec.unit_cat) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'CATEGORY', 'LEGACY_TOKENS', FALSE);
        p_usec_cat_rec.status := 'E';
      END IF;

      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation (l_n_uoo_id) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_usec_cat_rec.status := 'E';
      END IF;

    END validate_db_cons;

  /* Main Unit Section Category Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cat.start_logging_for','Unit Section category');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_usec_cat_tbl.LAST LOOP
      IF ( p_usec_cat_tbl.EXISTS(I) ) THEN
        l_n_uoo_id  := NULL;
        p_usec_cat_tbl(I).status := 'S';
        p_usec_cat_tbl(I).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_usec_cat_tbl(I) );
        validate_parameters ( p_usec_cat_tbl(I) );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cat.status_after_validate_parameters',
	  'Unit code:'||p_usec_cat_tbl(I).unit_cd||'  '||'Version number:'||p_usec_cat_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_cat_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_cat_tbl(I).location_cd||'  '||'Unit Class:'||
	  p_usec_cat_tbl(I).unit_class||'  '||'Unit_Cat:'||p_usec_cat_tbl(I).unit_cat||'  '||'Status:'||p_usec_cat_tbl(I).status);
        END IF;

	IF p_usec_cat_tbl(I).status = 'S' THEN
	  validate_derivations ( p_usec_cat_tbl(I));

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cat.status_after_validate_derivations',
	    'Unit code:'||p_usec_cat_tbl(I).unit_cd||'  '||'Version number:'||p_usec_cat_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_cat_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_cat_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_cat_tbl(I).unit_class||'  '||'Unit_Cat:'||p_usec_cat_tbl(I).unit_cat||'  '||'Status:'||p_usec_cat_tbl(I).status);
	  END IF;

        END IF;

        IF p_usec_cat_tbl(I).status = 'S' AND p_calling_context = 'S' THEN
	  IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	    fnd_msg_pub.add;
	    p_usec_cat_tbl(I).status := 'A';
	  END IF;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cat.status_after_check_import_allowed',
	    'Unit code:'||p_usec_cat_tbl(I).unit_cd||'  '||'Version number:'||p_usec_cat_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_cat_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_cat_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_cat_tbl(I).unit_class||'  '||'Unit_Cat:'||p_usec_cat_tbl(I).unit_cat||'  '||'Status:'||p_usec_cat_tbl(I).status);
	  END IF;

	END IF;

	IF p_usec_cat_tbl(I).status = 'S' THEN
          validate_db_cons ( p_usec_cat_tbl(I) );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cat.status_after_validate_db_cons',
	    'Unit code:'||p_usec_cat_tbl(I).unit_cd||'  '||'Version number:'||p_usec_cat_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_cat_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_cat_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_cat_tbl(I).unit_class||'  '||'Unit_Cat:'||p_usec_cat_tbl(I).unit_cat||'  '||'Status:'||p_usec_cat_tbl(I).status);
	  END IF;

        END IF;


          /* Proceed with business validations only if the status is Success, 'S' */
        IF p_usec_cat_tbl(I).status = 'S' THEN
          /* Validation# 1: Check for the closed_ind for UNIT_CAT */
           igs_ps_validate_generic_pkg.validate_category( p_usec_cat_tbl(I),l_n_uoo_id ) ;

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cat.status_after_Business_Validation',
	     'Unit code:'||p_usec_cat_tbl(I).unit_cd||'  '||'Version number:'||p_usec_cat_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_cat_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_cat_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_cat_tbl(I).unit_class||'  '||'Unit_Cat:'||p_usec_cat_tbl(I).unit_cat||'  '||'Status:'||p_usec_cat_tbl(I).status);
	   END IF;

        END IF;

	IF p_usec_cat_tbl(I).status = 'S' THEN
           /* Insert record */
           INSERT INTO igs_ps_usec_category
           (usec_cat_id,
            uoo_id,
            unit_cat,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login
           )
           VALUES
           (igs_ps_usec_category_s.nextval,
            l_n_uoo_id,
            p_usec_cat_tbl(I).unit_cat,
            g_n_user_id,
            SYSDATE,
            g_n_user_id,
            SYSDATE,
            g_n_login_id
           );

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cat.Record_Inserted',
	     'Unit code:'||p_usec_cat_tbl(I).unit_cd||'  '||'Version number:'||p_usec_cat_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_cat_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_cat_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_cat_tbl(I).unit_class||'  '||'Unit_Cat:'||p_usec_cat_tbl(I).unit_cat);
	   END IF;

        END IF; --insert

	IF p_usec_cat_tbl(I).status = 'S' THEN
	   p_usec_cat_tbl(I).msg_from := NULL;
	   p_usec_cat_tbl(I).msg_to := NULL;
	ELSIF  p_usec_cat_tbl(I).status = 'A' THEN
	   p_usec_cat_tbl(I).msg_from  := p_usec_cat_tbl(I).msg_from + 1;
	   p_usec_cat_tbl(I).msg_to := fnd_msg_pub.count_msg;
	ELSE
           p_c_rec_status := p_usec_cat_tbl(I).status;
           p_usec_cat_tbl(I).msg_from :=p_usec_cat_tbl(I).msg_from+1;
           p_usec_cat_tbl(I).msg_to := fnd_msg_pub.count_msg;
           IF p_usec_cat_tbl(I).status = 'E' THEN
            RETURN;
	   END IF;
        END IF;

      END IF;--Exists
    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cat.after_import_status',p_c_rec_status);
    END IF;

  END create_usec_cat;



/*teaching responsibility ovrd*/
PROCEDURE create_usec_teach_resp_ovrd (
          p_usec_teach_resp_ovrd_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_ovrd_tbl_type,
          p_c_rec_status             OUT NOCOPY VARCHAR2,
	  p_calling_context          IN VARCHAR2
  ) AS
  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:  10-JUN-2005
    Purpose        :  This procedure is a sub process to import records of Unit Section Teaching Responsibility Overrides.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
       l_insert_update  VARCHAR2(1);
       l_n_uoo_id       igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
       l_c_cal_type     igs_ps_unit_ofr_opt_all.cal_type%TYPE;
       l_n_seq_num      igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;

       l_tbl_uoo        igs_ps_create_generic_pkg.uoo_tbl_type;

       CURSOR c_tch_rsp_ovrd(p_unit_cd IN VARCHAR2,
       p_version_number NUMBER,
       p_cal_type VARCHAR2,
       p_ci_sequence_number NUMBER,
       p_location_cd VARCHAR2,
       p_unit_class VARCHAR2,
       p_org_unit_cd VARCHAR2,
       p_ou_start_dt DATE
       ) IS
       SELECT *
       FROM igs_ps_tch_resp_ovrd_all
       WHERE unit_cd = p_unit_cd
       AND version_number= p_version_number
       AND cal_type=p_cal_type
       AND ci_sequence_number=p_ci_sequence_number
       AND location_cd=p_location_cd
       AND unit_class=p_unit_class
       AND org_unit_cd=p_org_unit_cd
       AND ou_start_dt =p_ou_start_dt;

       c_tch_rsp_ovrd_rec c_tch_rsp_ovrd%ROWTYPE;

    /* Private Procedures for create_usec_teach_resp_ovrd */
    PROCEDURE trim_values ( p_tch_rsp_ovrd_rec IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_ovrd_rec_type ) AS
    BEGIN
      p_tch_rsp_ovrd_rec.unit_cd := trim(p_tch_rsp_ovrd_rec.unit_cd);
      p_tch_rsp_ovrd_rec.version_number := trim(p_tch_rsp_ovrd_rec.version_number);
      p_tch_rsp_ovrd_rec.teach_cal_alternate_code := trim(p_tch_rsp_ovrd_rec.teach_cal_alternate_code);
      p_tch_rsp_ovrd_rec.location_cd := trim(p_tch_rsp_ovrd_rec.location_cd);
      p_tch_rsp_ovrd_rec.unit_class := trim(p_tch_rsp_ovrd_rec.unit_class);
      p_tch_rsp_ovrd_rec.org_unit_cd := trim(p_tch_rsp_ovrd_rec.org_unit_cd);
      p_tch_rsp_ovrd_rec.ou_start_dt := TRUNC(p_tch_rsp_ovrd_rec.ou_start_dt);
      p_tch_rsp_ovrd_rec.percentage := trim(p_tch_rsp_ovrd_rec.percentage);
    END trim_values;

    -- validate parameters passed.
    PROCEDURE validate_parameters ( p_tch_rsp_ovrd_rec IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_ovrd_rec_type ) AS
    BEGIN

      /* Check for Mandatory Parameters */
      IF p_tch_rsp_ovrd_rec.unit_cd IS NULL OR p_tch_rsp_ovrd_rec.unit_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_tch_rsp_ovrd_rec.status := 'E';
      END IF;
      IF p_tch_rsp_ovrd_rec.version_number IS NULL OR p_tch_rsp_ovrd_rec.version_number = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
        p_tch_rsp_ovrd_rec.status := 'E';
      END IF;
      IF p_tch_rsp_ovrd_rec.teach_cal_alternate_code IS NULL OR p_tch_rsp_ovrd_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_tch_rsp_ovrd_rec.status := 'E';
      END IF;
      IF p_tch_rsp_ovrd_rec.location_cd IS NULL OR p_tch_rsp_ovrd_rec.location_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD', 'LEGACY_TOKENS', FALSE);
        p_tch_rsp_ovrd_rec.status := 'E';
      END IF;
      IF p_tch_rsp_ovrd_rec.unit_class IS NULL OR p_tch_rsp_ovrd_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CLASS', 'LEGACY_TOKENS', FALSE);
        p_tch_rsp_ovrd_rec.status := 'E';
      END IF;
      IF p_tch_rsp_ovrd_rec.org_unit_cd IS NULL OR p_tch_rsp_ovrd_rec.org_unit_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'ORG_UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_tch_rsp_ovrd_rec.status := 'E';
      END IF;
      IF p_tch_rsp_ovrd_rec.ou_start_dt IS NULL OR p_tch_rsp_ovrd_rec.ou_start_dt = FND_API.G_MISS_DATE THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'OU_START_DT', 'LEGACY_TOKENS', FALSE);
        p_tch_rsp_ovrd_rec.status := 'E';
      END IF;
      IF p_tch_rsp_ovrd_rec.percentage IS NULL OR p_tch_rsp_ovrd_rec.percentage = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PERCENTAGE', 'LEGACY_TOKENS', FALSE);
        p_tch_rsp_ovrd_rec.status := 'E';
      END IF;
    END validate_parameters;


    -- Check for Update
    FUNCTION check_insert_update ( p_tch_rsp_ovrd_rec IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_ovrd_rec_type ) RETURN VARCHAR2 IS
      CURSOR c_tch_resp_ovrd(p_unit_cd IN VARCHAR2,
			     p_version_number NUMBER,
			     p_cal_type VARCHAR2,
			     p_ci_sequence_number NUMBER,
			     p_location_cd VARCHAR2,
			     p_unit_class VARCHAR2,
			     p_org_unit_cd VARCHAR2,
			     p_ou_start_dt DATE
       ) IS
       SELECT 'X'
       FROM igs_ps_tch_resp_ovrd_all
       WHERE unit_cd = p_unit_cd
       AND version_number= p_version_number
       AND cal_type=p_cal_type
       AND ci_sequence_number=p_ci_sequence_number
       AND location_cd=p_location_cd
       AND unit_class=p_unit_class
       AND org_unit_cd=p_org_unit_cd
       AND ou_start_dt =p_ou_start_dt;

       c_tch_resp_ovrd_rec c_tch_resp_ovrd%ROWTYPE;

    BEGIN

	OPEN c_tch_resp_ovrd(p_tch_rsp_ovrd_rec.unit_cd,
			     p_tch_rsp_ovrd_rec.version_number,
			     l_c_cal_type,
			     l_n_seq_num,
			     p_tch_rsp_ovrd_rec.location_cd,
			     p_tch_rsp_ovrd_rec.unit_class,
			     p_tch_rsp_ovrd_rec.org_unit_cd,
			     p_tch_rsp_ovrd_rec.ou_start_dt);
	FETCH c_tch_resp_ovrd INTO c_tch_resp_ovrd_rec;
	IF c_tch_resp_ovrd%NOTFOUND THEN
          CLOSE c_tch_resp_ovrd;
	  RETURN 'I';
        ELSE
          CLOSE c_tch_resp_ovrd;
	  RETURN 'U';
        END IF;

    END check_insert_update;

    -- Carry out derivations and validate them
    PROCEDURE validate_derivations ( p_tch_rsp_ovrd_rec IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_ovrd_rec_type ) AS
      l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
      l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
      l_c_message  VARCHAR2(30);
    BEGIN


      -- Derive Calander Type and Sequence Number
      igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_tch_rsp_ovrd_rec.teach_cal_alternate_code,
                                             p_cal_type           => l_c_cal_type,
                                             p_ci_sequence_number => l_n_seq_num,
                                             p_start_dt           => l_d_start_dt,
                                             p_end_dt             => l_d_end_dt,
                                             p_return_status      => l_c_message );
      IF ( l_c_message <> 'SINGLE' ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_tch_rsp_ovrd_rec.status := 'E';
      END IF;


      -- Derive uoo_id
      l_c_message := NULL;
      igs_ps_validate_lgcy_pkg.get_uoo_id ( p_unit_cd    => p_tch_rsp_ovrd_rec.unit_cd,
                                            p_ver_num    => p_tch_rsp_ovrd_rec.version_number,
                                            p_cal_type   => l_c_cal_type,
                                            p_seq_num    => l_n_seq_num,
                                            p_loc_cd     => p_tch_rsp_ovrd_rec.location_cd,
                                            p_unit_class => p_tch_rsp_ovrd_rec.unit_class,
                                            p_uoo_id     => l_n_uoo_id,
                                            p_message    => l_c_message );
      IF ( l_c_message IS NOT NULL ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_tch_rsp_ovrd_rec.status := 'E';
      END IF;

    END validate_derivations;

    -- Validate Database Constraints
    PROCEDURE validate_db_cons ( p_tch_rsp_ovrd_rec IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_ovrd_rec_type,p_insert_update VARCHAR2 ) AS
    BEGIN
      IF (p_insert_update = 'I') THEN

	/* Unique Key Validation */
	IF igs_ps_tch_resp_ovrd_pkg.get_pk_for_validation ( x_unit_cd => p_tch_rsp_ovrd_rec.unit_cd,
							    x_version_number => p_tch_rsp_ovrd_rec.version_number,
							    x_cal_type=>l_c_cal_type,
							    x_ci_sequence_number=>l_n_seq_num,
							    x_location_cd=>p_tch_rsp_ovrd_rec.location_cd,
							    x_unit_class=>p_tch_rsp_ovrd_rec.unit_class,
							    x_org_unit_cd=>p_tch_rsp_ovrd_rec.org_unit_cd,
							    x_ou_start_dt =>p_tch_rsp_ovrd_rec.ou_start_dt ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	  p_tch_rsp_ovrd_rec.status := 'W';
	  RETURN;
	END IF;
      END IF;

      /* Validate Check Constraints */
      BEGIN
        igs_ps_tch_resp_ovrd_pkg.check_constraints ( 'CI_SEQUENCE_NUMBER', l_n_seq_num);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'CI_SEQUENCE_NUMBER', 'LEGACY_TOKENS', TRUE);
          p_tch_rsp_ovrd_rec.status := 'E';
      END;

      BEGIN
        igs_ps_tch_resp_ovrd_pkg.check_constraints ( 'UOO_ID', l_n_uoo_id);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'UOO_ID', 'LEGACY_TOKENS', TRUE);
          p_tch_rsp_ovrd_rec.status := 'E';
      END;

      BEGIN
        igs_ps_tch_resp_ovrd_pkg.check_constraints ( 'PERCENTAGE', p_tch_rsp_ovrd_rec.percentage);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PER_0_100', null, null, TRUE);
          p_tch_rsp_ovrd_rec.status := 'E';
      END;

      /* Validate FK Constraints */
      IF NOT igs_ps_unit_ofr_opt_pkg.get_pk_for_validation ( p_tch_rsp_ovrd_rec.unit_cd, p_tch_rsp_ovrd_rec.version_number,
      l_c_cal_type,l_n_seq_num,p_tch_rsp_ovrd_rec.location_cd,p_tch_rsp_ovrd_rec.unit_class) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_tch_rsp_ovrd_rec.status := 'E';
      END IF;

      IF NOT igs_or_unit_pkg.get_pk_for_validation ( p_tch_rsp_ovrd_rec.org_unit_cd,p_tch_rsp_ovrd_rec.ou_start_dt ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'ORG_UNIT', 'LEGACY_TOKENS', FALSE);
        p_tch_rsp_ovrd_rec.status := 'E';
      END IF;

      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_tch_rsp_ovrd_rec.status := 'E';
      END IF;
    END validate_db_cons;

  /* Main Unit Section Teaching Responsibililty Override Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp_ovrd.start_logging_for',
                      'Unit Section Teaching Responsibility Overrides ');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_usec_teach_resp_ovrd_tbl.LAST LOOP

      IF p_usec_teach_resp_ovrd_tbl.EXISTS(I) THEN
        l_n_uoo_id   := NULL;
	l_c_cal_type := NULL;
	l_n_seq_num  := NULL;
        p_usec_teach_resp_ovrd_tbl(I).status := 'S';
        p_usec_teach_resp_ovrd_tbl(I).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_usec_teach_resp_ovrd_tbl(I) );

        validate_parameters ( p_usec_teach_resp_ovrd_tbl(I) );

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp_ovrd.status_after_validate_parameters',
	  'Unit code:'||p_usec_teach_resp_ovrd_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_ovrd_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_teach_resp_ovrd_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_ovrd_tbl(I).location_cd||'  '||'Unit Class:'||
	  p_usec_teach_resp_ovrd_tbl(I).unit_class||'  '||'org_unit_cd:'||p_usec_teach_resp_ovrd_tbl(I).org_unit_cd
	  ||'  '||'ou_start_dt'||p_usec_teach_resp_ovrd_tbl(I).ou_start_dt||'  '||'Status:'||p_usec_teach_resp_ovrd_tbl(I).status);
        END IF;

        IF p_usec_teach_resp_ovrd_tbl(I).status = 'S' THEN
          validate_derivations ( p_usec_teach_resp_ovrd_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp_ovrd.status_after_validate_derivations',
	    'Unit code:'||p_usec_teach_resp_ovrd_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_ovrd_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_teach_resp_ovrd_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_ovrd_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_teach_resp_ovrd_tbl(I).unit_class||'  '||'org_unit_cd:'||p_usec_teach_resp_ovrd_tbl(I).org_unit_cd
	    ||'  '||'ou_start_dt'||p_usec_teach_resp_ovrd_tbl(I).ou_start_dt||'  '||'Status:'||p_usec_teach_resp_ovrd_tbl(I).status);
	  END IF;

	END IF;

	---INSERT /UPDATE
        l_insert_update:='I';
        IF p_usec_teach_resp_ovrd_tbl(I).status = 'S' AND p_calling_context IN ('G','S') THEN
          l_insert_update:= check_insert_update(p_usec_teach_resp_ovrd_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp_ovrd.status_after_check_insert_update',
	    'Unit code:'||p_usec_teach_resp_ovrd_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_ovrd_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_teach_resp_ovrd_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_ovrd_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_teach_resp_ovrd_tbl(I).unit_class||'  '||'org_unit_cd:'||p_usec_teach_resp_ovrd_tbl(I).org_unit_cd
	    ||'  '||'ou_start_dt'||p_usec_teach_resp_ovrd_tbl(I).ou_start_dt||'  '||'Status:'||p_usec_teach_resp_ovrd_tbl(I).status);
	  END IF;

        END IF;

	IF p_usec_teach_resp_ovrd_tbl(I).status = 'S' AND p_calling_context = 'S' THEN
	  IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	    fnd_msg_pub.add;
	    p_usec_teach_resp_ovrd_tbl(I).status := 'A';
	  END IF;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp_ovrd.status_after_check_import_allowed',
	    'Unit code:'||p_usec_teach_resp_ovrd_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_ovrd_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_teach_resp_ovrd_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_ovrd_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_teach_resp_ovrd_tbl(I).unit_class||'  '||'org_unit_cd:'||p_usec_teach_resp_ovrd_tbl(I).org_unit_cd
	    ||'  '||'ou_start_dt'||p_usec_teach_resp_ovrd_tbl(I).ou_start_dt||'  '||'Status:'||p_usec_teach_resp_ovrd_tbl(I).status);
	  END IF;

	END IF;

        IF l_tbl_uoo.count = 0 THEN
          l_tbl_uoo(l_tbl_uoo.count+1) :=l_n_uoo_id;
        ELSE
	  IF NOT igs_ps_validate_lgcy_pkg.isExists(l_n_uoo_id,l_tbl_uoo) THEN
	   l_tbl_uoo(l_tbl_uoo.count+1) :=l_n_uoo_id;
          END IF;
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp_ovrd.Count_of_unique_uoo_ids',
	  'Unit code:'||p_usec_teach_resp_ovrd_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_ovrd_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_teach_resp_ovrd_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_ovrd_tbl(I).location_cd||'  '||'Unit Class:'||
	  p_usec_teach_resp_ovrd_tbl(I).unit_class||'  '||'org_unit_cd:'||p_usec_teach_resp_ovrd_tbl(I).org_unit_cd
	  ||'  '||'ou_start_dt'||p_usec_teach_resp_ovrd_tbl(I).ou_start_dt||'  '||'Count:'||l_tbl_uoo.count);
	END IF;

        IF p_usec_teach_resp_ovrd_tbl(I).status = 'S' THEN
          validate_db_cons ( p_usec_teach_resp_ovrd_tbl(I),l_insert_update );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp_ovrd.status_after_validate_db_cons',
	    'Unit code:'||p_usec_teach_resp_ovrd_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_ovrd_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_teach_resp_ovrd_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_ovrd_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_teach_resp_ovrd_tbl(I).unit_class||'  '||'org_unit_cd:'||p_usec_teach_resp_ovrd_tbl(I).org_unit_cd
	    ||'  '||'ou_start_dt'||p_usec_teach_resp_ovrd_tbl(I).ou_start_dt||'  '||'Status:'||p_usec_teach_resp_ovrd_tbl(I).status);
	  END IF;

        END IF;

        /* Business Validations */
        /* Proceed with business validations only if the status is Success, 'S' */
        IF p_usec_teach_resp_ovrd_tbl(I).status = 'S' THEN
          igs_ps_validate_generic_pkg.validate_tch_rsp_ovrd ( p_usec_teach_resp_ovrd_tbl(I),l_n_uoo_id );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp_ovrd.status_after_Business_validation',
	    'Unit code:'||p_usec_teach_resp_ovrd_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_ovrd_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_teach_resp_ovrd_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_ovrd_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_teach_resp_ovrd_tbl(I).unit_class||'  '||'org_unit_cd:'||p_usec_teach_resp_ovrd_tbl(I).org_unit_cd
	    ||'  '||'ou_start_dt'||p_usec_teach_resp_ovrd_tbl(I).ou_start_dt||'  '||'Status:'||p_usec_teach_resp_ovrd_tbl(I).status);
	  END IF;

        END IF;

         IF p_usec_teach_resp_ovrd_tbl(I).status = 'S'  THEN
	   IF l_insert_update = 'I' THEN
             /* Insert Record */

             INSERT INTO igs_ps_tch_resp_ovrd_all
             (unit_cd,
              version_number,
              cal_type,
              ci_sequence_number,
              location_cd,
              unit_class,
              org_unit_cd,
              ou_start_dt,
              uoo_id,
              percentage,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login
             )
             VALUES
             (p_usec_teach_resp_ovrd_tbl(I).unit_cd,
              p_usec_teach_resp_ovrd_tbl(I).version_number,
	      l_c_cal_type,
	      l_n_seq_num,
	      p_usec_teach_resp_ovrd_tbl(I).location_cd,
              p_usec_teach_resp_ovrd_tbl(I).unit_class,
              p_usec_teach_resp_ovrd_tbl(I).org_unit_cd,
	      p_usec_teach_resp_ovrd_tbl(I).ou_start_dt,
              l_n_uoo_id,
              p_usec_teach_resp_ovrd_tbl(I).percentage,
              g_n_user_id,
              SYSDATE,
              g_n_user_id,
              SYSDATE,
              g_n_login_id
             );

	      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp_ovrd.Record_Inserted',
		'Unit code:'||p_usec_teach_resp_ovrd_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_ovrd_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		||p_usec_teach_resp_ovrd_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_ovrd_tbl(I).location_cd||'  '||'Unit Class:'||
		p_usec_teach_resp_ovrd_tbl(I).unit_class||'  '||'org_unit_cd:'||p_usec_teach_resp_ovrd_tbl(I).org_unit_cd
		||'  '||'ou_start_dt'||p_usec_teach_resp_ovrd_tbl(I).ou_start_dt);
	      END IF;

           ELSE
	     /*Update record*/

             --Opening the cursor to fetch the existing data wich will be used in the history table insert
	     --Note this fetch needs to be done prior to the update statement
             OPEN c_tch_rsp_ovrd(p_usec_teach_resp_ovrd_tbl(I).unit_cd,
	                         p_usec_teach_resp_ovrd_tbl(I).version_number,
	                         l_c_cal_type,
	                         l_n_seq_num,
	                         p_usec_teach_resp_ovrd_tbl(I).location_cd,
	                         p_usec_teach_resp_ovrd_tbl(I).unit_class,
	                         p_usec_teach_resp_ovrd_tbl(I).org_unit_cd,
	                         p_usec_teach_resp_ovrd_tbl(I).ou_start_dt);
	     FETCH c_tch_rsp_ovrd INTO c_tch_rsp_ovrd_rec;
             CLOSE c_tch_rsp_ovrd;

             UPDATE igs_ps_tch_resp_ovrd_all
	     SET percentage = p_usec_teach_resp_ovrd_tbl(I).percentage,
	     last_updated_by = g_n_user_id,
	     last_update_date = SYSDATE,
             last_update_login = g_n_login_id
	     WHERE unit_cd = p_usec_teach_resp_ovrd_tbl(I).unit_cd
             AND version_number= p_usec_teach_resp_ovrd_tbl(I).version_number
             AND cal_type=l_c_cal_type
             AND ci_sequence_number=l_n_seq_num
             AND location_cd=p_usec_teach_resp_ovrd_tbl(I).location_cd
             AND unit_class=p_usec_teach_resp_ovrd_tbl(I).unit_class
             AND org_unit_cd=p_usec_teach_resp_ovrd_tbl(I).org_unit_cd
             AND ou_start_dt =p_usec_teach_resp_ovrd_tbl(I).ou_start_dt;

	     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp_ovrd.Record_Updated',
		'Unit code:'||p_usec_teach_resp_ovrd_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_ovrd_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		||p_usec_teach_resp_ovrd_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_ovrd_tbl(I).location_cd||'  '||'Unit Class:'||
	        p_usec_teach_resp_ovrd_tbl(I).unit_class||'  '||'org_unit_cd:'||p_usec_teach_resp_ovrd_tbl(I).org_unit_cd
	       ||'  '||'ou_start_dt'||p_usec_teach_resp_ovrd_tbl(I).ou_start_dt);
	     END IF;

             --Inserting into the history table.
             IGS_PS_GEN_005.CRSP_INS_TRO_HIST (
				p_usec_teach_resp_ovrd_tbl(I).unit_cd,
				p_usec_teach_resp_ovrd_tbl(I).version_number,
				l_c_cal_type,
				l_n_seq_num,
				p_usec_teach_resp_ovrd_tbl(I).location_cd,
				p_usec_teach_resp_ovrd_tbl(I).unit_class,
				p_usec_teach_resp_ovrd_tbl(I).org_unit_cd,
				p_usec_teach_resp_ovrd_tbl(I).ou_start_dt,
				p_usec_teach_resp_ovrd_tbl(I).percentage,
				c_tch_rsp_ovrd_rec.percentage,
				g_n_user_id,
				c_tch_rsp_ovrd_rec.last_updated_by,
				SYSDATE,
				c_tch_rsp_ovrd_rec.last_update_date);

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp_ovrd.Record_Inserted_into_history_table',
		'Unit code:'||p_usec_teach_resp_ovrd_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_ovrd_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		||p_usec_teach_resp_ovrd_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_ovrd_tbl(I).location_cd||'  '||'Unit Class:'||
	        p_usec_teach_resp_ovrd_tbl(I).unit_class||'  '||'org_unit_cd:'||p_usec_teach_resp_ovrd_tbl(I).org_unit_cd
	       ||'  '||'ou_start_dt'||p_usec_teach_resp_ovrd_tbl(I).ou_start_dt);
	     END IF;

     	   END IF;--insert/update
         END IF;

	 IF p_usec_teach_resp_ovrd_tbl(I).status = 'S' THEN
	   p_usec_teach_resp_ovrd_tbl(I).msg_from := NULL;
	   p_usec_teach_resp_ovrd_tbl(I).msg_to := NULL;
	 ELSIF  p_usec_teach_resp_ovrd_tbl(I).status = 'A' THEN
	   p_usec_teach_resp_ovrd_tbl(I).msg_from  := p_usec_teach_resp_ovrd_tbl(I).msg_from + 1;
	   p_usec_teach_resp_ovrd_tbl(I).msg_to := fnd_msg_pub.count_msg;
	 ELSE
           p_c_rec_status := p_usec_teach_resp_ovrd_tbl(I).status;
           p_usec_teach_resp_ovrd_tbl(I).msg_from := p_usec_teach_resp_ovrd_tbl(I).msg_from+1;
           p_usec_teach_resp_ovrd_tbl(I).msg_to := fnd_msg_pub.count_msg;
           IF p_usec_teach_resp_ovrd_tbl(I).status = 'E' THEN
             RETURN;
           END IF;
         END IF;

       END IF;--exists
     END LOOP;

     /* Post Insert/Update Checks */
     IF NOT igs_ps_validate_generic_pkg.post_tch_rsp_ovrd (p_usec_teach_resp_ovrd_tbl,l_tbl_uoo) THEN
       p_c_rec_status := 'E';
     END IF;
     l_tbl_uoo.DELETE;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp_ovrd.after_import_status',p_c_rec_status);
     END IF;


  END create_usec_teach_resp_ovrd;



/*Unit Section assessment item groups*/

  PROCEDURE create_usec_ass_item_grp(
          p_usec_ass_item_grp_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context  IN VARCHAR2
  )   AS
  /***********************************************************************************************
    Created By     :  SOMMUKHE
    Date Created By:  17-Jun-2005
    Purpose        :  This procedure is a sub process to insert records of Unit Section assessment item groups.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
    l_n_uoo_id           igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_tbl_uoo            igs_ps_create_generic_pkg.uoo_tbl_type;
    l_insert_update      VARCHAR2(1);


    /* Private Procedures for create_usec_grd_sch */
    PROCEDURE trim_values ( p_as_us_ai_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type ) AS
    BEGIN
      p_as_us_ai_rec.unit_cd := trim(p_as_us_ai_rec.unit_cd);
      p_as_us_ai_rec.version_number := trim(p_as_us_ai_rec.version_number);
      p_as_us_ai_rec.teach_cal_alternate_code := trim(p_as_us_ai_rec.teach_cal_alternate_code);
      p_as_us_ai_rec.location_cd := trim(p_as_us_ai_rec.location_cd);
      p_as_us_ai_rec.unit_class := trim(p_as_us_ai_rec.unit_class);
      p_as_us_ai_rec.group_name := trim(p_as_us_ai_rec.group_name);
      p_as_us_ai_rec.midterm_formula_code := trim(p_as_us_ai_rec.midterm_formula_code);
      p_as_us_ai_rec.midterm_formula_qty := trim(p_as_us_ai_rec.midterm_formula_qty);
      p_as_us_ai_rec.midterm_weight_qty := trim(p_as_us_ai_rec.midterm_weight_qty);
      p_as_us_ai_rec.final_formula_code := trim(p_as_us_ai_rec.final_formula_code);
      p_as_us_ai_rec.final_formula_qty := trim(p_as_us_ai_rec.final_formula_qty);
      p_as_us_ai_rec.final_weight_qty := trim(p_as_us_ai_rec.final_weight_qty);

      p_as_us_ai_rec.assessment_id := trim(p_as_us_ai_rec.assessment_id);
      p_as_us_ai_rec.sequence_number := trim(p_as_us_ai_rec.sequence_number);
      p_as_us_ai_rec.due_dt := TRUNC(p_as_us_ai_rec.due_dt);
      p_as_us_ai_rec.reference := trim(p_as_us_ai_rec.reference);
      p_as_us_ai_rec.dflt_item_ind := trim(p_as_us_ai_rec.dflt_item_ind);
      --p_as_us_ai_rec.logical_delete_dt := TRUNC(p_as_us_ai_rec.logical_delete_dt);
      p_as_us_ai_rec.exam_cal_alternate_code := trim(p_as_us_ai_rec.exam_cal_alternate_code);
      p_as_us_ai_rec.grading_schema_cd := trim(p_as_us_ai_rec.grading_schema_cd);
      p_as_us_ai_rec.gs_version_number := trim(p_as_us_ai_rec.gs_version_number);
      p_as_us_ai_rec.description := trim(p_as_us_ai_rec.description);
      --p_as_us_ai_rec.release_date := TRUNC(p_as_us_ai_rec.release_date);
      p_as_us_ai_rec.midterm_mandatory_type_code := trim(p_as_us_ai_rec.midterm_mandatory_type_code);
      p_as_us_ai_rec.midterm_weight_qty_item := trim(p_as_us_ai_rec.midterm_weight_qty_item);
      p_as_us_ai_rec.final_mandatory_type_code := trim(p_as_us_ai_rec.final_mandatory_type_code);
      p_as_us_ai_rec.final_weight_qty_item := trim(p_as_us_ai_rec.final_weight_qty_item);


    END trim_values;

    PROCEDURE create_group( p_as_us_ai_group_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type ) AS
      -- validate parameters passed.
      PROCEDURE validate_parameters ( p_as_us_ai_group_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type ) AS
      BEGIN

	/* Check for Mandatory Parameters */
	IF p_as_us_ai_group_rec.unit_cd IS NULL OR p_as_us_ai_group_rec.unit_cd = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
	  p_as_us_ai_group_rec.status := 'E';
	END IF;
	IF p_as_us_ai_group_rec.version_number IS NULL OR p_as_us_ai_group_rec.version_number = FND_API.G_MISS_NUM  THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
	  p_as_us_ai_group_rec.status := 'E';
	END IF;
	IF p_as_us_ai_group_rec.teach_cal_alternate_code IS NULL OR p_as_us_ai_group_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_as_us_ai_group_rec.status := 'E';
	END IF;
	IF p_as_us_ai_group_rec.location_cd IS NULL  OR p_as_us_ai_group_rec.location_cd = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD', 'LEGACY_TOKENS', FALSE);
	  p_as_us_ai_group_rec.status := 'E';
	END IF;
	IF p_as_us_ai_group_rec.unit_class IS NULL OR p_as_us_ai_group_rec.unit_class = FND_API.G_MISS_CHAR  THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CLASS', 'LEGACY_TOKENS', FALSE);
	  p_as_us_ai_group_rec.status := 'E';
	END IF;
	IF p_as_us_ai_group_rec.group_name IS NULL  OR p_as_us_ai_group_rec.group_name = FND_API.G_MISS_CHAR  THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'GROUP_NAME', 'LEGACY_TOKENS', FALSE);
	  p_as_us_ai_group_rec.status := 'E';
	END IF;


      END validate_parameters;


      -- Check for Update
      FUNCTION check_insert_update ( p_as_us_ai_group_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type ) RETURN VARCHAR2 IS
	CURSOR c_us_ai_group(cp_group_name VARCHAR2 ,cp_n_uoo_id NUMBER) IS
	 SELECT 'X'
	 FROM  igs_as_us_ai_group
	 WHERE group_name = cp_group_name
	 AND uoo_id = cp_n_uoo_id;

	 c_us_ai_group_rec c_us_ai_group%ROWTYPE;

      BEGIN

	  OPEN c_us_ai_group(p_as_us_ai_group_rec.group_name, l_n_uoo_id);
	  FETCH c_us_ai_group INTO c_us_ai_group_rec;
	  IF c_us_ai_group%NOTFOUND THEN
	    CLOSE c_us_ai_group;
	    RETURN 'I';
	  ELSE
	    CLOSE c_us_ai_group;
	    RETURN 'U';
	  END IF;

      END check_insert_update;

      -- Carry out derivations and validate them
      PROCEDURE validate_derivations ( p_as_us_ai_group_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type) AS
	l_c_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE;
	l_n_seq_num  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;
	l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
	l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
	l_c_message  VARCHAR2(30);
      BEGIN


	-- Derive Calander Type and Sequence Number
	igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_as_us_ai_group_rec.teach_cal_alternate_code,
					       p_cal_type           => l_c_cal_type,
					       p_ci_sequence_number => l_n_seq_num,
					       p_start_dt           => l_d_start_dt,
					       p_end_dt             => l_d_end_dt,
					       p_return_status      => l_c_message );
	IF ( l_c_message <> 'SINGLE' ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_as_us_ai_group_rec.status := 'E';
	END IF;

	--check if calendar instance is inactive
	IF NOT  igs_ps_val_uai.crsp_val_crs_ci(l_c_cal_type, l_n_seq_num, l_c_message) THEN
	  fnd_message.set_name ( 'IGS', l_c_message );
	  fnd_msg_pub.add;
	  p_as_us_ai_group_rec.status := 'E';
	END IF;

	--check if calendar type is closed
	IF NOT  igs_as_val_uai.crsp_val_uo_cal_type(l_c_cal_type, l_c_message) THEN
	  fnd_message.set_name ( 'IGS', l_c_message );
	  fnd_msg_pub.add;
	  p_as_us_ai_group_rec.status := 'E';
	END IF;


	-- Derive uoo_id
	l_c_message := NULL;
	igs_ps_validate_lgcy_pkg.get_uoo_id ( p_unit_cd    => p_as_us_ai_group_rec.unit_cd,
					      p_ver_num    => p_as_us_ai_group_rec.version_number,
					      p_cal_type   => l_c_cal_type,
					      p_seq_num    => l_n_seq_num,
					      p_loc_cd     => p_as_us_ai_group_rec.location_cd,
					      p_unit_class => p_as_us_ai_group_rec.unit_class,
					      p_uoo_id     => l_n_uoo_id,
					      p_message    => l_c_message );
	IF ( l_c_message IS NOT NULL ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	  p_as_us_ai_group_rec.status := 'E';
	END IF;
      END validate_derivations;

      PROCEDURE Assign_default( p_as_us_ai_group_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type,p_insert_update VARCHAR2 ) AS

	CURSOR c_us_ai_group(cp_group_name VARCHAR2 ,cp_n_uoo_id NUMBER) IS
	SELECT *
	FROM  igs_as_us_ai_group
	WHERE group_name = cp_group_name
	AND uoo_id = cp_n_uoo_id;

	c_us_ai_group_rec c_us_ai_group%ROWTYPE;

      BEGIN

	IF p_insert_update = 'U' THEN
	   OPEN c_us_ai_group(p_as_us_ai_group_rec.group_name, l_n_uoo_id);
	   FETCH c_us_ai_group INTO c_us_ai_group_rec;
	   CLOSE c_us_ai_group;

	   IF p_as_us_ai_group_rec.midterm_formula_code IS NULL  THEN
	      p_as_us_ai_group_rec.midterm_formula_code := c_us_ai_group_rec.midterm_formula_code;
	   ELSIF  p_as_us_ai_group_rec.midterm_formula_code = FND_API.G_MISS_CHAR THEN
	      p_as_us_ai_group_rec.midterm_formula_code :=NULL;
	   END IF;

	   IF p_as_us_ai_group_rec.midterm_formula_qty IS NULL THEN
	     p_as_us_ai_group_rec.midterm_formula_qty := c_us_ai_group_rec.midterm_formula_qty;
	   ELSIF p_as_us_ai_group_rec.midterm_formula_qty = FND_API.G_MISS_NUM THEN
	     p_as_us_ai_group_rec.midterm_formula_qty :=NULL;
	   END IF;

	   IF p_as_us_ai_group_rec.midterm_weight_qty IS NULL THEN
	     p_as_us_ai_group_rec.midterm_weight_qty :=c_us_ai_group_rec.midterm_weight_qty;
	   ELSIF p_as_us_ai_group_rec.midterm_weight_qty  = FND_API.G_MISS_NUM THEN
	     p_as_us_ai_group_rec.midterm_weight_qty :=NULL;
	   END IF;

	   IF p_as_us_ai_group_rec.final_formula_code IS NULL THEN
	     p_as_us_ai_group_rec.final_formula_code :=c_us_ai_group_rec.final_formula_code;
	   ELSIF p_as_us_ai_group_rec.final_formula_code = FND_API.G_MISS_CHAR THEN
	     p_as_us_ai_group_rec.final_formula_code :=NULL;
	   END IF;

	   IF p_as_us_ai_group_rec.final_formula_qty IS NULL THEN
	     p_as_us_ai_group_rec.final_formula_qty := c_us_ai_group_rec.final_formula_qty;
	   ELSIF p_as_us_ai_group_rec.final_formula_qty = FND_API.G_MISS_NUM THEN
	     p_as_us_ai_group_rec.final_formula_qty :=NULL;
	   END IF;

	   IF p_as_us_ai_group_rec.final_weight_qty IS NULL THEN
	     p_as_us_ai_group_rec.final_weight_qty := c_us_ai_group_rec.final_weight_qty;
	   ELSIF p_as_us_ai_group_rec.final_weight_qty = FND_API.G_MISS_NUM THEN
	     p_as_us_ai_group_rec.final_weight_qty :=NULL;
	   END IF;

	END IF;

      END Assign_default;

      -- Validate Database Constraints
      PROCEDURE validate_db_cons ( p_as_us_ai_group_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type,p_insert_update VARCHAR2 ) AS
      BEGIN
	IF (p_insert_update = 'I') THEN
	  /* Unique Key Validation */
	  IF igs_as_us_ai_group_pkg.get_uk_for_validation (x_uoo_id => l_n_uoo_id,
							   x_group_name => p_as_us_ai_group_rec.group_name) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'USEC_ASSMNT', 'LEGACY_TOKENS', FALSE);
	    p_as_us_ai_group_rec.status := 'W';
	    RETURN;
	  END IF;
	END IF;

	/* Validate Check Constraints */
	IF p_as_us_ai_group_rec.midterm_formula_qty IS NOT NULL THEN
	  IF p_as_us_ai_group_rec.midterm_formula_qty <0 OR p_as_us_ai_group_rec.midterm_formula_qty >999 THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999', 'MIDTERM_FORMULA_QTY', 'LEGACY_TOKENS', FALSE);
	    p_as_us_ai_group_rec.status := 'E';
	  END IF;

	  --Format mask validation
	  IF p_as_us_ai_group_rec.status <> 'E' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_as_us_ai_group_rec.midterm_formula_qty,3,0) THEN
	        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999', 'MIDTERM_FORMULA_QTY', 'LEGACY_TOKENS', FALSE);
		p_as_us_ai_group_rec.status :='E';
	    END IF;
	  END IF;

	END IF;

	IF p_as_us_ai_group_rec.midterm_weight_qty IS NOT NULL THEN
	  IF p_as_us_ai_group_rec.midterm_weight_qty <0.001 OR p_as_us_ai_group_rec.midterm_weight_qty >999.999 THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_990D00', 'MIDTERM_WEIGHT_QTY', 'LEGACY_TOKENS', FALSE);
	    p_as_us_ai_group_rec.status := 'E';
	  END IF;

	  --Format mask validation
	  IF p_as_us_ai_group_rec.status <> 'E' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_as_us_ai_group_rec.midterm_weight_qty,3,3) THEN
	        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_990D00', 'MIDTERM_WEIGHT_QTY', 'LEGACY_TOKENS', FALSE);
		p_as_us_ai_group_rec.status :='E';
	    END IF;
	  END IF;

	END IF;

	IF p_as_us_ai_group_rec.final_formula_qty IS NOT NULL THEN
	  IF p_as_us_ai_group_rec.final_formula_qty <0 OR p_as_us_ai_group_rec.final_formula_qty >999 THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999', 'FINAL_FORMULA_QTY', 'LEGACY_TOKENS', FALSE);
	    p_as_us_ai_group_rec.status := 'E';
	  END IF;

	  --Format mask validation
	  IF p_as_us_ai_group_rec.status <> 'E' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_as_us_ai_group_rec.final_formula_qty,3,0) THEN
	        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999', 'FINAL_FORMULA_QTY', 'LEGACY_TOKENS', FALSE);
		p_as_us_ai_group_rec.status :='E';
	    END IF;
	  END IF;

	END IF;

	IF p_as_us_ai_group_rec.final_weight_qty IS NOT NULL THEN
	  IF p_as_us_ai_group_rec.final_weight_qty <0.001 OR p_as_us_ai_group_rec.final_weight_qty >999.999 THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_990D00', 'FINAL_WEIGHT_QTY', 'LEGACY_TOKENS', FALSE);
    	    p_as_us_ai_group_rec.status := 'E';
	  END IF;

	  --Format mask validation
	  IF p_as_us_ai_group_rec.status <> 'E' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_as_us_ai_group_rec.final_weight_qty,3,3) THEN
	        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_990D00', 'FINAL_WEIGHT_QTY', 'LEGACY_TOKENS', FALSE);
		p_as_us_ai_group_rec.status :='E';
	    END IF;
	  END IF;

	END IF;


	/* Validate FK Constraints */
	IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	  p_as_us_ai_group_rec.status := 'E';
	END IF;

      END validate_db_cons;

    -- Main section for assesment item group.
    BEGIN

       validate_parameters(p_as_us_ai_group_rec);

       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	 fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_group.status_after_validate_parameters_item',
	 'Unit code:'||p_as_us_ai_group_rec.unit_cd||'  '||'Version number:'||p_as_us_ai_group_rec.version_number||'  '||'teach_cal_alternate_code:'
	 ||p_as_us_ai_group_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_as_us_ai_group_rec.location_cd||'  '||'Unit Class:'||
	 p_as_us_ai_group_rec.unit_class||'Group name:'||p_as_us_ai_group_rec.group_name||' '||'Status:'||p_as_us_ai_group_rec.status);
       END IF;

       IF p_as_us_ai_group_rec.status = 'S' THEN
          validate_derivations(p_as_us_ai_group_rec);

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_group.status_after_validate_derivations',
	     'Unit code:'||p_as_us_ai_group_rec.unit_cd||'  '||'Version number:'||p_as_us_ai_group_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_as_us_ai_group_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_as_us_ai_group_rec.location_cd||'  '||'Unit Class:'||
	     p_as_us_ai_group_rec.unit_class||'Group name:'||p_as_us_ai_group_rec.group_name||' '||'Status:'||p_as_us_ai_group_rec.status);
	   END IF;

       END IF;

       --Find out whether it is insert/update of record
       l_insert_update:='I';
       IF p_as_us_ai_group_rec.status = 'S' AND p_calling_context IN ('G','S') THEN
         l_insert_update:= check_insert_update(p_as_us_ai_group_rec);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_group.status_after_check_insert_update',
	   'Unit code:'||p_as_us_ai_group_rec.unit_cd||'  '||'Version number:'||p_as_us_ai_group_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_as_us_ai_group_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_as_us_ai_group_rec.location_cd||'  '||'Unit Class:'||
	   p_as_us_ai_group_rec.unit_class||'Group name:'||p_as_us_ai_group_rec.group_name||' '||'Status:'||p_as_us_ai_group_rec.status);
	 END IF;

       END IF;

       -- Find out whether record can go for import in context of cancelled/aborted
       IF p_as_us_ai_group_rec.status = 'S' AND p_calling_context = 'S' THEN
	 IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	    fnd_msg_pub.add;
	    p_as_us_ai_group_rec.status := 'A';
	 END IF;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_group.status_after_check_import_allowed',
	   'Unit code:'||p_as_us_ai_group_rec.unit_cd||'  '||'Version number:'||p_as_us_ai_group_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_as_us_ai_group_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_as_us_ai_group_rec.location_cd||'  '||'Unit Class:'||
	   p_as_us_ai_group_rec.unit_class||'Group name:'||p_as_us_ai_group_rec.group_name||' '||'Status:'||p_as_us_ai_group_rec.status);
	 END IF;


       END IF;

       IF p_as_us_ai_group_rec.status = 'S' THEN
	  Assign_default(p_as_us_ai_group_rec,l_insert_update);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_group.status_after_Assign_default',
	    'Unit code:'||p_as_us_ai_group_rec.unit_cd||'  '||'Version number:'||p_as_us_ai_group_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_as_us_ai_group_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_as_us_ai_group_rec.location_cd||'  '||'Unit Class:'||
	    p_as_us_ai_group_rec.unit_class||'Group name:'||p_as_us_ai_group_rec.group_name||' '||'Status:'||p_as_us_ai_group_rec.status);
	  END IF;

       END IF;

       IF l_tbl_uoo.count = 0 THEN
          l_tbl_uoo(l_tbl_uoo.count+1) :=l_n_uoo_id;
       ELSE
          IF NOT igs_ps_validate_lgcy_pkg.isExists(l_n_uoo_id,l_tbl_uoo)  THEN
	     l_tbl_uoo(l_tbl_uoo.count+1) :=l_n_uoo_id;
	  END IF;
       END IF;

       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	 fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_group.Count_unique_uoo_ids',
	 'Unit code:'||p_as_us_ai_group_rec.unit_cd||'  '||'Version number:'||p_as_us_ai_group_rec.version_number||'  '||'teach_cal_alternate_code:'
	 ||p_as_us_ai_group_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_as_us_ai_group_rec.location_cd||'  '||'Unit Class:'||
	 p_as_us_ai_group_rec.unit_class||'Group name:'||p_as_us_ai_group_rec.group_name||'  '||'Count:'||l_tbl_uoo.count);
       END IF;

       IF p_as_us_ai_group_rec.status = 'S' THEN
          validate_db_cons(p_as_us_ai_group_rec,l_insert_update);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_group.status_after_validate_db_cons',
	    'Unit code:'||p_as_us_ai_group_rec.unit_cd||'  '||'Version number:'||p_as_us_ai_group_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_as_us_ai_group_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_as_us_ai_group_rec.location_cd||'  '||'Unit Class:'||
	    p_as_us_ai_group_rec.unit_class||'Group name:'||p_as_us_ai_group_rec.group_name||' '||'Status:'||p_as_us_ai_group_rec.status);
	  END IF;

       END IF;

       IF p_as_us_ai_group_rec.status = 'S' THEN
         igs_ps_validate_generic_pkg.validate_as_us_ai_group(p_as_us_ai_group_rec, l_n_uoo_id);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_group.status_after_Business_validation',
	   'Unit code:'||p_as_us_ai_group_rec.unit_cd||'  '||'Version number:'||p_as_us_ai_group_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_as_us_ai_group_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_as_us_ai_group_rec.location_cd||'  '||'Unit Class:'||
	   p_as_us_ai_group_rec.unit_class||'Group name:'||p_as_us_ai_group_rec.group_name||' '||'Status:'||p_as_us_ai_group_rec.status);
	 END IF;

       END IF;

       IF p_as_us_ai_group_rec.status = 'S' THEN
	 IF l_insert_update = 'I' THEN
              /* Insert Record */
           INSERT INTO igs_as_us_ai_group
           (us_ass_item_group_id,
           uoo_id,
           group_name,
           midterm_formula_code,
           midterm_formula_qty,
           midterm_weight_qty,
           final_formula_code,
           final_formula_qty,
           final_weight_qty,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
           )
           VALUES
           (igs_as_us_ai_group_s.NEXTVAL,
           l_n_uoo_id,
           p_as_us_ai_group_rec.group_name,
           p_as_us_ai_group_rec.midterm_formula_code,
           p_as_us_ai_group_rec.midterm_formula_qty,
	   p_as_us_ai_group_rec.midterm_weight_qty,
	   p_as_us_ai_group_rec.final_formula_code,
	   p_as_us_ai_group_rec.final_formula_qty,
	   p_as_us_ai_group_rec.final_weight_qty,
           g_n_user_id,
           SYSDATE,
           g_n_user_id,
           SYSDATE,
           g_n_login_id
           );

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_group.record_Inserted',
	     'Unit code:'||p_as_us_ai_group_rec.unit_cd||'  '||'Version number:'||p_as_us_ai_group_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_as_us_ai_group_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_as_us_ai_group_rec.location_cd||'  '||'Unit Class:'||
	     p_as_us_ai_group_rec.unit_class||'Group name:'||p_as_us_ai_group_rec.group_name);
	   END IF;

         ELSE --update
	   UPDATE igs_as_us_ai_group
	   SET midterm_formula_code=p_as_us_ai_group_rec.midterm_formula_code,
	   midterm_formula_qty=p_as_us_ai_group_rec.midterm_formula_qty,
	   midterm_weight_qty=p_as_us_ai_group_rec.midterm_weight_qty,
	   final_formula_code=p_as_us_ai_group_rec.final_formula_code,
	   final_formula_qty=p_as_us_ai_group_rec.final_formula_qty,
	   final_weight_qty=p_as_us_ai_group_rec.final_weight_qty,
	   last_updated_by = g_n_user_id,
	   last_update_date = SYSDATE,
           last_update_login = g_n_login_id
	   WHERE group_name =p_as_us_ai_group_rec.group_name
	   AND uoo_id = l_n_uoo_id;

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_group.record_updated',
	     'Unit code:'||p_as_us_ai_group_rec.unit_cd||'  '||'Version number:'||p_as_us_ai_group_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_as_us_ai_group_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_as_us_ai_group_rec.location_cd||'  '||'Unit Class:'||
	     p_as_us_ai_group_rec.unit_class||'Group name:'||p_as_us_ai_group_rec.group_name);
	   END IF;

         END IF;
       END IF;

    END create_group;

    PROCEDURE create_item( p_unitass_item_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type ) AS
      CURSOR c_unitass_item(cp_n_uoo_id NUMBER ,cp_assessment_id NUMBER,cp_sequence_number NUMBER) IS
      SELECT *
      FROM igs_ps_unitass_item
      WHERE uoo_id = cp_n_uoo_id
      AND ass_id = cp_assessment_id
      AND sequence_number=cp_sequence_number;

      l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
      l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;

      l_c_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE;
      l_n_seq_num  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;

      l_c_exam_cal_type igs_ca_inst_all.cal_type%TYPE;
      l_n_exam_seq_num  igs_ca_inst_all.sequence_number%TYPE;

      l_n_us_ass_item_group_id  igs_ps_unitass_item.us_ass_item_group_id%type;

      -- validate parameters passed.
      PROCEDURE validate_parameters_item ( p_unitass_item_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type ) AS
      BEGIN

	/* Check for Mandatory Parameters */
	IF p_unitass_item_rec.assessment_id IS NULL OR p_unitass_item_rec.assessment_id = FND_API.G_MISS_NUM THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'ASSESSMENT_ID', 'LEGACY_TOKENS', FALSE);
	  p_unitass_item_rec.status := 'E';
	END IF;
	IF p_unitass_item_rec.grading_schema_cd IS NULL OR p_unitass_item_rec.grading_schema_cd = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'GRADINGS_SCHEMA_CD', 'LEGACY_TOKENS', FALSE);
	  p_unitass_item_rec.status := 'E';
	END IF;
	IF p_unitass_item_rec.gs_version_number IS NULL OR p_unitass_item_rec.gs_version_number = FND_API.G_MISS_NUM THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'GS_VERSION_NUMBER', 'LEGACY_TOKENS', FALSE);
	  p_unitass_item_rec.status := 'E';
	END IF;

      END validate_parameters_item;


      -- Check for Update
      FUNCTION check_insert_update_item ( p_unitass_item_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type ) RETURN VARCHAR2 IS
	CURSOR c_unitass_item(cp_n_uoo_id NUMBER ,cp_assessment_id NUMBER,cp_sequence_number NUMBER) IS
	SELECT 'X'
	FROM igs_ps_unitass_item
	WHERE uoo_id = cp_n_uoo_id
	AND ass_id = cp_assessment_id
	AND sequence_number=cp_sequence_number;

	c_unitass_item_rec c_unitass_item%ROWTYPE;
      BEGIN
	OPEN c_unitass_item(l_n_uoo_id,p_unitass_item_rec.assessment_id,p_unitass_item_rec.sequence_number);
	FETCH c_unitass_item INTO c_unitass_item_rec;
	IF c_unitass_item%NOTFOUND THEN
	  CLOSE c_unitass_item;
	  RETURN 'I';
	ELSE
	  CLOSE c_unitass_item;
	  RETURN 'U';
	END IF;

      END check_insert_update_item;

      -- Carry out derivations and validate them
      PROCEDURE validate_derivations_item ( p_unitass_item_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type) AS

	  l_c_message  VARCHAR2(30);

	  CURSOR c_uaig_id(cp_uoo_id NUMBER,cp_group_name VARCHAR2) IS
	  SELECT us_ass_item_group_id
	  FROM igs_as_us_ai_group
	  WHERE uoo_id = cp_uoo_id
	  AND group_name = cp_group_name;

      BEGIN

	-- Derive Calander Type and Sequence Number
	igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_unitass_item_rec.teach_cal_alternate_code,
					       p_cal_type           => l_c_cal_type,
					       p_ci_sequence_number => l_n_seq_num,
					       p_start_dt           => l_d_start_dt,
					       p_end_dt             => l_d_end_dt,
					       p_return_status      => l_c_message );
	IF ( l_c_message <> 'SINGLE' ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_unitass_item_rec.status := 'E';
	END IF;

	--derive us_ass_item_group_id
	IF p_unitass_item_rec.status = 'S' THEN
	  OPEN c_uaig_id(l_n_uoo_id,p_unitass_item_rec.group_name);
	  FETCH c_uaig_id INTO l_n_us_ass_item_group_id;
	  CLOSE c_uaig_id;
	END IF;
      END validate_derivations_item;

      PROCEDURE Assign_default( p_unitass_item_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type,p_insert_update VARCHAR2 ) AS
	CURSOR c_unitass_item(cp_n_uoo_id NUMBER ,cp_assessment_id NUMBER,cp_sequence_number NUMBER) IS
	SELECT *
	FROM igs_ps_unitass_item
	WHERE uoo_id = cp_n_uoo_id
	AND ass_id = cp_assessment_id
	AND sequence_number=cp_sequence_number;

	c_unitass_item_rec c_unitass_item%ROWTYPE;

	CURSOR cal_type (cp_alternate_code igs_ca_inst_all.alternate_code%TYPE) IS
	SELECT cal_type,sequence_number
	FROM   igs_ca_inst_all
	WHERE  alternate_code = cp_alternate_code;

        CURSOR cur_exam_cal(cp_cal_type igs_ca_inst_all.cal_type%TYPE, cp_sequence_number igs_ca_inst_all.sequence_number%TYPE ) IS
	SELECT 'X'
	FROM   igs_ca_inst ci,
	       igs_ca_type cat
	WHERE  cat.s_cal_cat = 'EXAM'
	AND    ci.cal_type = cat.cal_type
	AND    ci.cal_type = cp_cal_type
	AND    ci.sequence_number = cp_sequence_number
	AND    ci.sequence_number IN (SELECT ci2.sequence_number
				      FROM   igs_ca_inst ci2,
					     igs_ca_inst_rel cir
				      WHERE  ci2.cal_type = cir.sup_cal_type
	                              AND    ci2.sequence_number = cir.sup_ci_sequence_number
	                              AND    cir.sub_cal_type = l_c_cal_type
	                              AND    cir.sub_ci_sequence_number = l_n_seq_num);
	l_c_var  VARCHAR2(1);

	CURSOR cur_ass_desc(cp_assessment_id NUMBER) IS
	SELECT description
	FROM igs_as_assessmnt_itm
	WHERE ass_id = cp_assessment_id;
	l_cur_ass_desc cur_ass_desc%ROWTYPE;

      BEGIN
	IF p_insert_update = 'I' THEN
	  IF p_unitass_item_rec.dflt_item_ind IS NULL  THEN
	    p_unitass_item_rec.dflt_item_ind :='Y';
	  ELSIF  p_unitass_item_rec.dflt_item_ind = FND_API.G_MISS_CHAR THEN
	    p_unitass_item_rec.dflt_item_ind :='Y';
	  END IF;

	  IF  p_unitass_item_rec.due_dt  = FND_API.G_MISS_DATE THEN
	    p_unitass_item_rec.due_dt  :=NULL;
	  END IF;

	  IF p_unitass_item_rec.reference = FND_API.G_MISS_CHAR THEN
	    p_unitass_item_rec.reference :=NULL;
	  END IF;


          IF p_unitass_item_rec.midterm_mandatory_type_code = FND_API.G_MISS_CHAR THEN
	    p_unitass_item_rec.midterm_mandatory_type_code :=NULL;
	  END IF;

	  IF p_unitass_item_rec.midterm_weight_qty_item   = FND_API.G_MISS_NUM THEN
	    p_unitass_item_rec.midterm_weight_qty_item   :=NULL;
	  END IF;

  	  IF p_unitass_item_rec.final_mandatory_type_code = FND_API.G_MISS_CHAR THEN
	    p_unitass_item_rec.final_mandatory_type_code :=NULL;
	  END IF;

	  IF p_unitass_item_rec.final_weight_qty_item = FND_API.G_MISS_NUM THEN
	    p_unitass_item_rec.final_weight_qty_item :=NULL;
	  END IF;

	  IF p_unitass_item_rec.release_date   = FND_API.G_MISS_DATE THEN
	    p_unitass_item_rec.release_date   :=NULL;
	  END IF;

	  IF p_unitass_item_rec.logical_delete_dt IS NOT NULL THEN
	    p_unitass_item_rec.logical_delete_dt :=NULL;
	  END IF;


	  IF p_unitass_item_rec.description IS NOT NULL THEN
            OPEN cur_ass_desc(p_unitass_item_rec.assessment_id);
	    FETCH cur_ass_desc INTO l_cur_ass_desc;
	    CLOSE cur_ass_desc;
	    IF l_cur_ass_desc.description = p_unitass_item_rec.description THEN
              p_unitass_item_rec.description:=NULL;
	    END IF;
	  ELSIF p_unitass_item_rec.description = FND_API.G_MISS_CHAR THEN
	    p_unitass_item_rec.description :=NULL;
	  END IF;

	  IF p_unitass_item_rec.exam_cal_alternate_code IS NULL THEN
            l_c_exam_cal_type := NULL;
            l_n_exam_seq_num  := NULL;
          ELSE
            OPEN cal_type(p_unitass_item_rec.exam_cal_alternate_code);
	    FETCH cal_type INTO l_c_exam_cal_type,l_n_exam_seq_num;
	    IF cal_type%NOTFOUND THEN
	      igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'EXAM_CAL_ALTERNATE_CODE', 'LEGACY_TOKENS', FALSE);
	      p_unitass_item_rec.status := 'E';
            ELSE
	      --validate the exam calendar is a valid one, if provided
	      OPEN cur_exam_cal(l_c_exam_cal_type,l_n_exam_seq_num);
	      FETCH cur_exam_cal INTO l_c_var;
	      IF cur_exam_cal%NOTFOUND THEN
		igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'EXAM_CAL_ALTERNATE_CODE', 'LEGACY_TOKENS', FALSE);
		p_unitass_item_rec.status := 'E';
	      END IF;
	      CLOSE cur_exam_cal;
	    END IF;
	    CLOSE cal_type;
	  END IF;

	END IF;

	IF p_insert_update = 'U' THEN
	  OPEN c_unitass_item(l_n_uoo_id,p_unitass_item_rec.assessment_id,p_unitass_item_rec.sequence_number);
	  FETCH c_unitass_item INTO c_unitass_item_rec;
	  CLOSE c_unitass_item;

	  IF p_unitass_item_rec.due_dt  IS NULL  THEN
	    p_unitass_item_rec.due_dt  := c_unitass_item_rec.due_dt ;
	  ELSIF  p_unitass_item_rec.due_dt  = FND_API.G_MISS_DATE THEN
	    p_unitass_item_rec.due_dt  :=NULL;
	  END IF;

	  IF p_unitass_item_rec.dflt_item_ind IS NULL  THEN
	    p_unitass_item_rec.dflt_item_ind :=c_unitass_item_rec.dflt_item_ind;
	  ELSIF  p_unitass_item_rec.dflt_item_ind = FND_API.G_MISS_CHAR THEN
	    p_unitass_item_rec.dflt_item_ind :='N';
	  END IF;

	  IF p_unitass_item_rec.reference IS NULL  THEN
	    p_unitass_item_rec.reference := c_unitass_item_rec.reference;
	  ELSIF  p_unitass_item_rec.reference = FND_API.G_MISS_CHAR THEN
	    p_unitass_item_rec.reference :=NULL;
	  END IF;

	  IF p_unitass_item_rec.logical_delete_dt IS NULL  THEN
	    p_unitass_item_rec.logical_delete_dt := c_unitass_item_rec.logical_delete_dt;
	  ELSIF  p_unitass_item_rec.logical_delete_dt = FND_API.G_MISS_DATE THEN
	    p_unitass_item_rec.logical_delete_dt :=NULL;
	  END IF;


          IF p_unitass_item_rec.description IS NULL THEN
            p_unitass_item_rec.description := c_unitass_item_rec.description;
	  ELSIF p_unitass_item_rec.description = FND_API.G_MISS_CHAR THEN
	    p_unitass_item_rec.description :=NULL;
          ELSIF p_unitass_item_rec.description IS NOT NULL THEN
            OPEN cur_ass_desc(p_unitass_item_rec.assessment_id);
	    FETCH cur_ass_desc INTO l_cur_ass_desc;
	    CLOSE cur_ass_desc;
	    IF l_cur_ass_desc.description = p_unitass_item_rec.description THEN
              p_unitass_item_rec.description:=NULL;
	    END IF;
	  END IF;




	  IF p_unitass_item_rec.exam_cal_alternate_code IS NULL THEN
            l_c_exam_cal_type := c_unitass_item_rec.exam_cal_type;
            l_n_exam_seq_num  := c_unitass_item_rec.exam_ci_sequence_number;
          ELSIF p_unitass_item_rec.exam_cal_alternate_code = FND_API.G_MISS_CHAR THEN
            l_c_exam_cal_type := NULL;
            l_n_exam_seq_num  := NULL;
	  ELSE
            OPEN cal_type(p_unitass_item_rec.exam_cal_alternate_code);
	    FETCH cal_type INTO l_c_exam_cal_type,l_n_exam_seq_num;
	    IF cal_type%NOTFOUND THEN
	      igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'EXAM_CAL_ALTERNATE_CODE', 'LEGACY_TOKENS', FALSE);
	      p_unitass_item_rec.status := 'E';
            ELSE
	      --validate the exam calendar is a valid one, if provided
	      OPEN cur_exam_cal(l_c_exam_cal_type,l_n_exam_seq_num);
	      FETCH cur_exam_cal INTO l_c_var;
	      IF cur_exam_cal%NOTFOUND THEN
		igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'EXAM_CAL_ALTERNATE_CODE', 'LEGACY_TOKENS', FALSE);
		p_unitass_item_rec.status := 'E';
	      END IF;
	      CLOSE cur_exam_cal;
	    END IF;
	    CLOSE cal_type;

	  END IF;

	  IF p_unitass_item_rec.release_date   IS NULL THEN
	    p_unitass_item_rec.release_date   := c_unitass_item_rec.release_date  ;
	  ELSIF p_unitass_item_rec.release_date   = FND_API.G_MISS_DATE THEN
	    p_unitass_item_rec.release_date   :=NULL;
	  END IF;

	  IF p_unitass_item_rec.midterm_mandatory_type_code IS NULL THEN
	    p_unitass_item_rec.midterm_mandatory_type_code := c_unitass_item_rec.midterm_mandatory_type_code;
	  ELSIF p_unitass_item_rec.midterm_mandatory_type_code = FND_API.G_MISS_CHAR THEN
	    p_unitass_item_rec.midterm_mandatory_type_code :=NULL;
	  END IF;

	  IF p_unitass_item_rec.midterm_weight_qty_item   IS NULL THEN
	    p_unitass_item_rec.midterm_weight_qty_item   := c_unitass_item_rec.midterm_weight_qty;
	  ELSIF p_unitass_item_rec.midterm_weight_qty_item   = FND_API.G_MISS_NUM THEN
	    p_unitass_item_rec.midterm_weight_qty_item   :=NULL;
	  END IF;

  	  IF p_unitass_item_rec.final_mandatory_type_code IS NULL THEN
	    p_unitass_item_rec.final_mandatory_type_code := c_unitass_item_rec.final_mandatory_type_code;
	  ELSIF p_unitass_item_rec.final_mandatory_type_code = FND_API.G_MISS_CHAR THEN
	    p_unitass_item_rec.final_mandatory_type_code :=NULL;
	  END IF;

	  IF p_unitass_item_rec.final_weight_qty_item IS NULL THEN
	    p_unitass_item_rec.final_weight_qty_item := c_unitass_item_rec.final_weight_qty;
	  ELSIF p_unitass_item_rec.final_weight_qty_item = FND_API.G_MISS_NUM THEN
	    p_unitass_item_rec.final_weight_qty_item :=NULL;
	  END IF;


	END IF;

      END Assign_default;

      -- Validate Database Constraints
      PROCEDURE validate_db_cons_item ( p_unitass_item_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type,p_insert_update VARCHAR2 ) AS
	CURSOR c_assessment_id(cp_assessment_id  igs_as_assessmnt_itm.ass_id%TYPE)IS
	SELECT 'X'
	FROM igs_as_assessmnt_itm
	WHERE ass_id =cp_assessment_id;

	c_assessment_id_rec c_assessment_id%ROWTYPE;
      BEGIN
        IF (p_insert_update = 'I') THEN
	  -- Unique Key Validation
	  IF igs_ps_unitass_item_pkg.get_uk_for_validation (x_ass_id =>p_unitass_item_rec.assessment_id,
	 						    x_sequence_number=>p_unitass_item_rec.sequence_number,
						            x_uoo_id =>l_n_uoo_id) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'USEC_ASSMNT', 'LEGACY_TOKENS', FALSE);
	    p_unitass_item_rec.status := 'W';
	    RETURN;
	  END IF;
	END IF;

	/* Validate Check Constraints */
	IF p_unitass_item_rec.midterm_weight_qty_item IS NOT NULL THEN
	  IF p_unitass_item_rec.midterm_weight_qty_item <0.001 OR p_unitass_item_rec.midterm_weight_qty_item >999.999 THEN
	    p_unitass_item_rec.status := 'E';
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_990D00', 'MIDTERM_WEIGHT_QTY_ITEM', 'LEGACY_TOKENS', FALSE);
	  END IF;

	  --Format mask validation
	  IF p_unitass_item_rec.status <> 'E' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_unitass_item_rec.midterm_weight_qty_item,3,3) THEN
	        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_990D00', 'MIDTERM_WEIGHT_QTY_ITEM', 'LEGACY_TOKENS', FALSE);
		p_unitass_item_rec.status :='E';
	    END IF;
	  END IF;

	END IF;

	IF p_unitass_item_rec.final_weight_qty_item IS NOT NULL THEN
	  IF p_unitass_item_rec.final_weight_qty_item <0.001 OR p_unitass_item_rec.final_weight_qty_item >999.999 THEN
	    p_unitass_item_rec.status := 'E';
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_990D00', 'FINAL_WEIGHT_QTY_ITEM', 'LEGACY_TOKENS', FALSE);
	  END IF;

	  --Format mask validation
	  IF p_unitass_item_rec.status <> 'E' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_unitass_item_rec.final_weight_qty_item,3,3) THEN
	        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_990D00', 'FINAL_WEIGHT_QTY_ITEM', 'LEGACY_TOKENS', FALSE);
		p_unitass_item_rec.status :='E';
	    END IF;
	  END IF;

	END IF;



	/* Validate FK Constraints */
	IF NOT igs_as_grd_schema_pkg.get_pk_for_validation ( p_unitass_item_rec.grading_schema_cd,p_unitass_item_rec.gs_version_number ) THEN
	   igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'GRADING_SCHEMA', 'LEGACY_TOKENS', FALSE);
	   p_unitass_item_rec.status := 'E';
	END IF;

	IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
	   igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	   p_unitass_item_rec.status := 'E';
	END IF;

	IF NOT igs_as_us_ai_group_pkg.get_pk_for_validation ( l_n_us_ass_item_group_id ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_ASSMNT', 'LEGACY_TOKENS', FALSE);
	  p_unitass_item_rec.status := 'E';
	END IF;

	OPEN c_assessment_id(p_unitass_item_rec.assessment_id);
	FETCH c_assessment_id INTO c_assessment_id_rec;
	IF c_assessment_id%NOTFOUND THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'ASSESSMENT_ID', 'LEGACY_TOKENS', FALSE);
	  p_unitass_item_rec.status := 'E';
	END IF;
	CLOSE c_assessment_id;


      END validate_db_cons_item;

    -- Main section for assesment item group.
    BEGIN
      validate_parameters_item(p_unitass_item_rec);

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_item.status_after_validate_parameters_item',
	'Unit code:'||p_unitass_item_rec.unit_cd||'  '||'Version number:'||p_unitass_item_rec.version_number||'  '||'teach_cal_alternate_code:'
	||p_unitass_item_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_unitass_item_rec.location_cd||'  '||'Unit Class:'||
	p_unitass_item_rec.unit_class||'  '||'Assesment_id:'||p_unitass_item_rec.assessment_id||' '||'Status:'||p_unitass_item_rec.status);
      END IF;

      IF p_unitass_item_rec.status = 'S' THEN
	validate_derivations_item(p_unitass_item_rec);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_item.status_after_validate_derivations_item',
	  'Unit code:'||p_unitass_item_rec.unit_cd||'  '||'Version number:'||p_unitass_item_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_unitass_item_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_unitass_item_rec.location_cd||'  '||'Unit Class:'||
	  p_unitass_item_rec.unit_class||'  '||'Assesment_id:'||p_unitass_item_rec.assessment_id||'  '||'Status:'||p_unitass_item_rec.status);
        END IF;

      END IF;

      l_insert_update:='I';
      --Find out whether it is insert/update of record
      IF p_unitass_item_rec.status = 'S' AND p_calling_context IN ('G','S') THEN
        l_insert_update:= check_insert_update_item(p_unitass_item_rec);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_item.status_after_check_insert_update_item',
	  'Unit code:'||p_unitass_item_rec.unit_cd||'  '||'Version number:'||p_unitass_item_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_unitass_item_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_unitass_item_rec.location_cd||'  '||'Unit Class:'||
	  p_unitass_item_rec.unit_class||'  '||'Assesment_id:'||p_unitass_item_rec.assessment_id||'  '||'Status:'||p_unitass_item_rec.status);
        END IF;

      END IF;

      IF p_unitass_item_rec.status = 'S' AND p_calling_context = 'S' THEN
        IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	  fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	  fnd_msg_pub.add;
	  p_unitass_item_rec.status := 'A';
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_item.status_after_check_import_allowed',
	  'Unit code:'||p_unitass_item_rec.unit_cd||'  '||'Version number:'||p_unitass_item_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_unitass_item_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_unitass_item_rec.location_cd||'  '||'Unit Class:'||
	  p_unitass_item_rec.unit_class||'  '||'Assesment_id:'||p_unitass_item_rec.assessment_id||'  '||'Status:'||p_unitass_item_rec.status);
        END IF;

      END IF;

       IF p_unitass_item_rec.status = 'S' THEN
	  Assign_default(p_unitass_item_rec,l_insert_update);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_item.Status_after_Assign_default',
	    'Unit code:'||p_unitass_item_rec.unit_cd||'  '||'Version number:'||p_unitass_item_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_unitass_item_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_unitass_item_rec.location_cd||'  '||'Unit Class:'||
	    p_unitass_item_rec.unit_class||'  '||'Assesment_id:'||p_unitass_item_rec.assessment_id||'  '||'Status:'||p_unitass_item_rec.status);
          END IF;

       END IF;

      IF p_unitass_item_rec.status = 'S' THEN
        validate_db_cons_item(p_unitass_item_rec,l_insert_update);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_item.Status_after_validate_db_cons_item',
	  'Unit code:'||p_unitass_item_rec.unit_cd||'  '||'Version number:'||p_unitass_item_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_unitass_item_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_unitass_item_rec.location_cd||'  '||'Unit Class:'||
	  p_unitass_item_rec.unit_class||'  '||'Assesment_id:'||p_unitass_item_rec.assessment_id||'  '||'Status:'||p_unitass_item_rec.status);
        END IF;

      END IF;

      IF p_unitass_item_rec.status = 'S' THEN
        igs_ps_validate_generic_pkg.validate_unitass_item (p_unitass_item_rec, l_c_cal_type ,l_n_seq_num ,l_n_uoo_id,l_insert_update);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_item.Status_after_Business_validation',
	  'Unit code:'||p_unitass_item_rec.unit_cd||'  '||'Version number:'||p_unitass_item_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_unitass_item_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_unitass_item_rec.location_cd||'  '||'Unit Class:'||
	  p_unitass_item_rec.unit_class||'  '||'Assesment_id:'||p_unitass_item_rec.assessment_id||'  '||'Status:'||p_unitass_item_rec.status);
        END IF;

      END IF;

      IF p_unitass_item_rec.status = 'S' THEN
        IF l_insert_update = 'I' THEN
	  /* Insert Record */
	  INSERT INTO igs_ps_unitass_item
	  (unit_section_ass_item_id,
	   uoo_id,
	   ass_id,
	   sequence_number,
	   ci_start_dt,
	   ci_end_dt,
	   due_dt,
	   reference,
	   dflt_item_ind,
	   logical_delete_dt,
	   action_dt,
	   exam_cal_type,
	   exam_ci_sequence_number,
	   created_by,
	   creation_date,
	   last_updated_by,
	   last_update_date,
	   last_update_login,
	   grading_schema_cd,
	   gs_version_number,
	   release_date,
	   description,
	   us_ass_item_group_id,
	   midterm_mandatory_type_code,
	   midterm_weight_qty,
	   final_mandatory_type_code,
	   final_weight_qty
	  )
	  VALUES
	  (igs_ps_unitass_item_s.NEXTVAL,
	  l_n_uoo_id,
	  p_unitass_item_rec.assessment_id,
	  igs_ps_unitass_item_seq_num_s.NEXTVAL,
	  l_d_start_dt,
	  l_d_end_dt,
	  p_unitass_item_rec.due_dt,
	  p_unitass_item_rec.reference,
	  p_unitass_item_rec.dflt_item_ind,
	  p_unitass_item_rec.logical_delete_dt,
	  SYSDATE,
          l_c_exam_cal_type,
          l_n_exam_seq_num,
	  g_n_user_id,
	  SYSDATE,
	  g_n_user_id,
	  SYSDATE,
	  g_n_login_id,
	  p_unitass_item_rec.grading_schema_cd,
	  p_unitass_item_rec.gs_version_number,
	  p_unitass_item_rec.release_date,
          p_unitass_item_rec.description,
	  l_n_us_ass_item_group_id,
	  p_unitass_item_rec.midterm_mandatory_type_code,
	  p_unitass_item_rec.midterm_weight_qty_item,
	  p_unitass_item_rec.final_mandatory_type_code,
	  p_unitass_item_rec.final_weight_qty_item
	  );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_item.Status_record_inserted',
	    'Unit code:'||p_unitass_item_rec.unit_cd||'  '||'Version number:'||p_unitass_item_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_unitass_item_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_unitass_item_rec.location_cd||'  '||'Unit Class:'||
	    p_unitass_item_rec.unit_class||'  '||'Assesment_id:'||p_unitass_item_rec.assessment_id);
          END IF;

        ELSE --update
	  UPDATE igs_ps_unitass_item
	  SET  due_dt = p_unitass_item_rec.due_dt,
	  reference = p_unitass_item_rec.reference,
	  dflt_item_ind = p_unitass_item_rec.dflt_item_ind,
	  logical_delete_dt = p_unitass_item_rec.logical_delete_dt,
	  action_dt = SYSDATE,
	  exam_cal_type = l_c_exam_cal_type,
	  exam_ci_sequence_number = l_n_exam_seq_num,
	  grading_schema_cd = p_unitass_item_rec.grading_schema_cd,
	  gs_version_number = p_unitass_item_rec.gs_version_number,
	  release_date = p_unitass_item_rec.release_date,
	  description = p_unitass_item_rec.description,
	  midterm_mandatory_type_code = p_unitass_item_rec.midterm_mandatory_type_code,
	  midterm_weight_qty = p_unitass_item_rec.midterm_weight_qty_item,
	  final_mandatory_type_code = p_unitass_item_rec.final_mandatory_type_code,
	  final_weight_qty = p_unitass_item_rec.final_weight_qty_item,
	  last_updated_by = g_n_user_id,
	  last_update_date = SYSDATE,
	  last_update_login = g_n_login_id
	  WHERE uoo_id = l_n_uoo_id
	  AND ass_id = p_unitass_item_rec.assessment_id
	  AND sequence_number=p_unitass_item_rec.sequence_number;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_item.Status_record_updated',
	    'Unit code:'||p_unitass_item_rec.unit_cd||'  '||'Version number:'||p_unitass_item_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_unitass_item_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_unitass_item_rec.location_cd||'  '||'Unit Class:'||
	    p_unitass_item_rec.unit_class||'  '||'Assesment_id:'||p_unitass_item_rec.assessment_id||'  '||'sequence_number:'||p_unitass_item_rec.sequence_number);
          END IF;

        END IF;
      END IF;

    END create_item;


  /* Main Unit Section Assessment groups/item  Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.start_logging_for',
                      'Unit Section Assessment groups/item ');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_usec_ass_item_grp_tbl.LAST LOOP
      l_n_uoo_id:= NULL;
      IF p_usec_ass_item_grp_tbl.EXISTS(I) THEN
        p_usec_ass_item_grp_tbl(I).status := 'S';
        p_usec_ass_item_grp_tbl(I).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_usec_ass_item_grp_tbl(I) );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_group.call',
	  'Unit code:'||p_usec_ass_item_grp_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ass_item_grp_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_ass_item_grp_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ass_item_grp_tbl(I).location_cd||'  '||'Unit Class:'||
	  p_usec_ass_item_grp_tbl(I).unit_class);
        END IF;

	-- unit section assesment item group
	create_group(p_usec_ass_item_grp_tbl(I));

	 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_group.status_after_record_creation',
	      'Unit code:'||p_usec_ass_item_grp_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ass_item_grp_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_ass_item_grp_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ass_item_grp_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_ass_item_grp_tbl(I).unit_class||'  '||'Status:'||p_usec_ass_item_grp_tbl(I).status);
	  END IF;

        -- Create section assesment items
	IF  p_usec_ass_item_grp_tbl(I).status = 'S' THEN
          IF p_usec_ass_item_grp_tbl(I).assessment_id IS NOT NULL THEN

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_item.call',
	      'Unit code:'||p_usec_ass_item_grp_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ass_item_grp_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_ass_item_grp_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ass_item_grp_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_ass_item_grp_tbl(I).unit_class||'  '||'Assesment_id:'||p_usec_ass_item_grp_tbl(I).assessment_id);
	    END IF;

	    create_item(p_usec_ass_item_grp_tbl(I));

	    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.create_item.status_after_record_creation',
	      'Unit code:'||p_usec_ass_item_grp_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ass_item_grp_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_ass_item_grp_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ass_item_grp_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_ass_item_grp_tbl(I).unit_class||'  '||'Assesment_id:'||p_usec_ass_item_grp_tbl(I).assessment_id||'  '||
	      'Status:'||p_usec_ass_item_grp_tbl(I).status);
	    END IF;

	  END IF;
	END IF;

        IF  p_usec_ass_item_grp_tbl(I).status = 'S' THEN
           p_usec_ass_item_grp_tbl(I).msg_from := NULL;
           p_usec_ass_item_grp_tbl(I).msg_to := NULL;
        ELSIF  p_usec_ass_item_grp_tbl(I).status = 'A' THEN
	   p_usec_ass_item_grp_tbl(I).msg_from  := p_usec_ass_item_grp_tbl(I).msg_from + 1;
	   p_usec_ass_item_grp_tbl(I).msg_to := fnd_msg_pub.count_msg;
	ELSE
           p_c_rec_status :=  p_usec_ass_item_grp_tbl(I).status;
           p_usec_ass_item_grp_tbl(I).msg_from :=  p_usec_ass_item_grp_tbl(I).msg_from + 1;
           p_usec_ass_item_grp_tbl(I).msg_to := fnd_msg_pub.count_msg;
          IF p_c_rec_status = 'E' THEN
            RETURN;
          END IF;
        END IF;
      END IF;--exists
    END LOOP;

    /* Post Insert/Update Checks */
    IF NOT igs_ps_validate_generic_pkg.post_as_us_ai(p_usec_ass_item_grp_tbl,l_tbl_uoo) THEN
      p_c_rec_status := 'E';
    END IF;

    l_tbl_uoo.DELETE;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ass_item_grp.after_import_status',p_c_rec_status);
    END IF;


  END create_usec_ass_item_grp;
  /* END OF UNIT SECTION ASSESMENT ITEM GROUPS */

--start of Meet with class group
PROCEDURE create_usec_meet_with(
          p_usec_meet_with_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context  IN VARCHAR2
  )   AS
  /***********************************************************************************************
    Created By     :  SOMMUKHE
    Date Created By:  17-Jun-2005
    Purpose        :  This procedure is a sub process to import records of meet with group.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */

    l_n_class_meet_group_id  igs_ps_uso_cm_grp.class_meet_group_id%type;
    l_n_uoo_id               igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_c_cal_type             igs_ps_unit_ofr_opt_all.cal_type%TYPE;
    l_n_seq_num              igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;
    l_insert_update          VARCHAR2(1);

    FUNCTION ifexists(p_n_class_meet_group_id igs_ps_uso_cm_grp.class_meet_group_id%type,
                   p_old_max_enr_group igs_ps_uso_cm_grp.max_enr_group%TYPE
		   ) RETURN BOOLEAN AS
    BEGIN
      FOR I in 1..class_meet_tab.count LOOP
        IF p_n_class_meet_group_id = class_meet_tab(i).class_meet_group_id THEN
           class_meet_tab(i).old_max_enr_group:= p_old_max_enr_group;
	   RETURN TRUE;
         END IF;
      END LOOP;
      RETURN FALSE;
    END ifexists;


    /* Private Procedures for create_usec_grd_sch */
    PROCEDURE trim_values ( p_usec_meet_with_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type ) AS
    BEGIN
      p_usec_meet_with_rec.unit_cd := trim(p_usec_meet_with_rec.unit_cd);
      p_usec_meet_with_rec.version_number := trim(p_usec_meet_with_rec.version_number);
      p_usec_meet_with_rec.teach_cal_alternate_code := trim(p_usec_meet_with_rec.teach_cal_alternate_code);
      p_usec_meet_with_rec.location_cd := trim(p_usec_meet_with_rec.location_cd);
      p_usec_meet_with_rec.unit_class := trim(p_usec_meet_with_rec.unit_class);
      p_usec_meet_with_rec.class_meet_group_name := trim(p_usec_meet_with_rec.class_meet_group_name);
      p_usec_meet_with_rec.max_enr_group := trim(p_usec_meet_with_rec.max_enr_group);
      p_usec_meet_with_rec.max_ovr_group := trim(p_usec_meet_with_rec.max_ovr_group);
      p_usec_meet_with_rec.host := trim(p_usec_meet_with_rec.host);

    END trim_values;


    PROCEDURE create_uso_cm_grp( p_uso_cm_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type ) AS

      l_n_tbl_cnt NUMBER;

      PROCEDURE validate_parameters ( p_uso_cm_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type ) AS
      BEGIN

	/* Check for Mandatory Parameters */
	IF p_uso_cm_grp_rec.teach_cal_alternate_code IS NULL OR p_uso_cm_grp_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_uso_cm_grp_rec.status := 'E';
	END IF;
	IF p_uso_cm_grp_rec.class_meet_group_name IS NULL  OR p_uso_cm_grp_rec.class_meet_group_name = FND_API.G_MISS_CHAR  THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'GROUP_NAME', 'LEGACY_TOKENS', FALSE);
	  p_uso_cm_grp_rec.status := 'E';
	END IF;

      END validate_parameters;

      -- Check for Update
      FUNCTION check_insert_update ( p_uso_cm_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type ) RETURN VARCHAR2 IS
	CURSOR c_uso_cm_grp(cp_cm_grp_name VARCHAR2) IS
	SELECT 'X'
	FROM igs_ps_uso_cm_grp
	WHERE class_meet_group_name =cp_cm_grp_name
	AND Cal_type=l_c_cal_type
	AND ci_sequence_number=l_n_seq_num;

	 c_uso_cm_grp_rec c_uso_cm_grp%ROWTYPE;

      BEGIN

	  OPEN c_uso_cm_grp( p_uso_cm_grp_rec.class_meet_group_name);
	  FETCH c_uso_cm_grp INTO c_uso_cm_grp_rec;
	  IF c_uso_cm_grp%NOTFOUND THEN
	    CLOSE c_uso_cm_grp;
	   RETURN 'I';
	  ELSE
	   CLOSE c_uso_cm_grp;
	   RETURN 'U';
	  END IF;

      END check_insert_update;

      -- Carry out derivations and validate them
      PROCEDURE validate_derivations ( p_uso_cm_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type) AS

	l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
	l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
	l_c_message  VARCHAR2(30);
      BEGIN


	-- Derive Calander Type and Sequence Number
	igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_uso_cm_grp_rec.teach_cal_alternate_code,
					       p_cal_type           => l_c_cal_type,
					       p_ci_sequence_number => l_n_seq_num,
					       p_start_dt           => l_d_start_dt,
					       p_end_dt             => l_d_end_dt,
					       p_return_status      => l_c_message );
	IF ( l_c_message <> 'SINGLE' ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_uso_cm_grp_rec.status := 'E';
	END IF;


      END validate_derivations;

      PROCEDURE Assign_default( p_uso_cm_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type,p_insert_update VARCHAR2 ) AS

        CURSOR c_uso_cm_grp(cp_cm_grp_name VARCHAR2) IS
	SELECT *
	FROM   igs_ps_uso_cm_grp
	WHERE  class_meet_group_name =cp_cm_grp_name
	AND    cal_type=l_c_cal_type
	AND    ci_sequence_number=l_n_seq_num;

	 c_uso_cm_grp_rec c_uso_cm_grp%ROWTYPE;

      BEGIN

	IF p_insert_update = 'U' THEN
	   OPEN c_uso_cm_grp(p_uso_cm_grp_rec.class_meet_group_name);
	   FETCH c_uso_cm_grp INTO c_uso_cm_grp_rec;
	   CLOSE c_uso_cm_grp;
	   l_n_class_meet_group_id := c_uso_cm_grp_rec.class_meet_group_id;

	   IF p_uso_cm_grp_rec.max_enr_group IS NULL  THEN
	      p_uso_cm_grp_rec.max_enr_group := c_uso_cm_grp_rec.max_enr_group;
	   ELSIF  p_uso_cm_grp_rec.max_enr_group = FND_API.G_MISS_NUM THEN
	      p_uso_cm_grp_rec.max_enr_group :=NULL;
	   END IF;

	   IF p_uso_cm_grp_rec.max_ovr_group IS NULL THEN
	      p_uso_cm_grp_rec.max_ovr_group := c_uso_cm_grp_rec.max_ovr_group;
	   ELSIF p_uso_cm_grp_rec.max_ovr_group = FND_API.G_MISS_NUM THEN
	      p_uso_cm_grp_rec.max_ovr_group :=NULL;
	   END IF;

	 END IF;

      END Assign_default;

      -- Validate Database Constraints
      PROCEDURE validate_db_cons ( p_uso_cm_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type,p_insert_update VARCHAR2 ) AS
      BEGIN
	IF (p_insert_update = 'I') THEN
	  /* Unique Key Validation */
	  IF igs_ps_uso_cm_grp_pkg.get_uk_for_validation (x_class_meet_group_name=>p_uso_cm_grp_rec.class_meet_group_name,
							  x_cal_type=>l_c_cal_type,
							  x_ci_sequence_number=>l_n_seq_num) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'USEC_MEET_WITH_CLASS_GROUP', 'LEGACY_TOKENS', FALSE);
	    p_uso_cm_grp_rec.status := 'W';
	    RETURN;
	  END IF;
	END IF;


        --Check constraint
	IF p_uso_cm_grp_rec.max_enr_group IS NOT NULL THEN
	  IF p_uso_cm_grp_rec.max_enr_group <1 OR p_uso_cm_grp_rec.max_enr_group >999999 THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_1_999999', 'MAX_ENR_GROUP', 'LEGACY_TOKENS', FALSE);
	    p_uso_cm_grp_rec.status := 'E';
	  END IF;

	  --Format mask validation
	  IF p_uso_cm_grp_rec.status <> 'E' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_uso_cm_grp_rec.max_enr_group,6,0) THEN
	        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_1_999999', 'MAX_ENR_GROUP', 'LEGACY_TOKENS', FALSE);
		p_uso_cm_grp_rec.status :='E';
	    END IF;
	  END IF;

	END IF;

	IF p_uso_cm_grp_rec.max_ovr_group IS NOT NULL THEN
	  IF p_uso_cm_grp_rec.max_ovr_group <1 OR p_uso_cm_grp_rec.max_ovr_group >999999 THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_1_999999', 'MAX_OVR_GROUP', 'LEGACY_TOKENS', FALSE);
	    p_uso_cm_grp_rec.status := 'E';
	  END IF;

	  --Format mask validation
	  IF p_uso_cm_grp_rec.status <> 'E' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_uso_cm_grp_rec.max_ovr_group,6,0) THEN
 	        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_1_999999', 'MAX_OVR_GROUP', 'LEGACY_TOKENS', FALSE);
		p_uso_cm_grp_rec.status :='E';
	    END IF;
	  END IF;

	END IF;

	/* Validate FK Constraints*/
	IF NOT igs_ca_inst_pkg.get_pk_for_validation (x_cal_type =>l_c_cal_type,
						      x_sequence_number =>l_n_seq_num) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_uso_cm_grp_rec.status := 'E';
	END IF;

      END validate_db_cons;

    -- Main section for meet with group header.
    BEGIN

      IF p_uso_cm_grp_rec.status = 'S' THEN
         validate_parameters(p_uso_cm_grp_rec);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_cm_grp.status_after_validate_parameters',
	   'Unit code:'||p_uso_cm_grp_rec.unit_cd||'  '||'Version number:'||p_uso_cm_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_uso_cm_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_cm_grp_rec.location_cd||'  '||'Unit Class:'||
	   p_uso_cm_grp_rec.unit_class||'  '||'Class meet group name:'||p_uso_cm_grp_rec.class_meet_group_name
	   ||'  '||'Status:'|| p_uso_cm_grp_rec.status);
         END IF;

      END IF;


      IF p_uso_cm_grp_rec.status = 'S' THEN
         validate_derivations(p_uso_cm_grp_rec);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_cm_grp.status_after_validate_derivations',
	   'Unit code:'||p_uso_cm_grp_rec.unit_cd||'  '||'Version number:'||p_uso_cm_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_uso_cm_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_cm_grp_rec.location_cd||'  '||'Unit Class:'||
	   p_uso_cm_grp_rec.unit_class||'  '||'Class meet group name:'||p_uso_cm_grp_rec.class_meet_group_name
	   ||'  '||'Status:'|| p_uso_cm_grp_rec.status);
         END IF;

      END IF;

      --Find out whether it is insert/update of record
      l_insert_update:='I';
      IF p_uso_cm_grp_rec.status = 'S' AND p_calling_context IN ('G','S') THEN
          l_insert_update:= check_insert_update(p_uso_cm_grp_rec);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_cm_grp.status_after_check_insert_update',
	   'Unit code:'||p_uso_cm_grp_rec.unit_cd||'  '||'Version number:'||p_uso_cm_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_uso_cm_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_cm_grp_rec.location_cd||'  '||'Unit Class:'||
	   p_uso_cm_grp_rec.unit_class||'  '||'Class meet group name:'||p_uso_cm_grp_rec.class_meet_group_name
	   ||'  '||'Status:'|| p_uso_cm_grp_rec.status);
         END IF;

      END IF;

      -- Find out whether record can go for import in context of cancelled/aborted
      IF p_uso_cm_grp_rec.status = 'S' AND p_calling_context = 'S' THEN
        IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	   fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	   fnd_msg_pub.add;
	   p_uso_cm_grp_rec.status := 'A';
	END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_cm_grp.status_after_check_import_allowed',
	   'Unit code:'||p_uso_cm_grp_rec.unit_cd||'  '||'Version number:'||p_uso_cm_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_uso_cm_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_cm_grp_rec.location_cd||'  '||'Unit Class:'||
	   p_uso_cm_grp_rec.unit_class||'  '||'Class meet group name:'||p_uso_cm_grp_rec.class_meet_group_name
	   ||'  '||'Status:'|| p_uso_cm_grp_rec.status);
         END IF;


      END IF;

      IF p_uso_cm_grp_rec.status = 'S' THEN
	 Assign_default(p_uso_cm_grp_rec,l_insert_update);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_cm_grp.status_after_Assign_default',
	   'Unit code:'||p_uso_cm_grp_rec.unit_cd||'  '||'Version number:'||p_uso_cm_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_uso_cm_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_cm_grp_rec.location_cd||'  '||'Unit Class:'||
	   p_uso_cm_grp_rec.unit_class||'  '||'Class meet group name:'||p_uso_cm_grp_rec.class_meet_group_name
	   ||'  '||'Status:'|| p_uso_cm_grp_rec.status);
         END IF;

      END IF;

      IF p_uso_cm_grp_rec.status = 'S' THEN
         validate_db_cons(p_uso_cm_grp_rec,l_insert_update);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_cm_grp.status_after_validate_db_cons',
	   'Unit code:'||p_uso_cm_grp_rec.unit_cd||'  '||'Version number:'||p_uso_cm_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_uso_cm_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_cm_grp_rec.location_cd||'  '||'Unit Class:'||
	   p_uso_cm_grp_rec.unit_class||'  '||'Class meet group name:'||p_uso_cm_grp_rec.class_meet_group_name
	   ||'  '||'Status:'|| p_uso_cm_grp_rec.status);
         END IF;



      END IF;

      IF p_uso_cm_grp_rec.status = 'S' THEN
        igs_ps_validate_generic_pkg.validate_uso_cm_grp(p_uso_cm_grp_rec, l_c_cal_type,l_n_seq_num,l_insert_update,class_meet_rec);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_cm_grp.status_after_Business_validation',
	   'Unit code:'||p_uso_cm_grp_rec.unit_cd||'  '||'Version number:'||p_uso_cm_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_uso_cm_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_cm_grp_rec.location_cd||'  '||'Unit Class:'||
	   p_uso_cm_grp_rec.unit_class||'  '||'Class meet group name:'||p_uso_cm_grp_rec.class_meet_group_name
	   ||'  '||'Status:'|| p_uso_cm_grp_rec.status);
         END IF;

      END IF;



      IF p_uso_cm_grp_rec.status = 'S' THEN
	IF l_insert_update = 'I' THEN
              /* Insert Record */
          INSERT INTO igs_ps_uso_cm_grp
          (class_meet_group_id,
           class_meet_group_name,
           cal_type,
           ci_sequence_number ,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
	   max_enr_group,
           max_ovr_group
          )
          VALUES
          (igs_ps_uso_cm_grp_s.NEXTVAL,
          p_uso_cm_grp_rec.class_meet_group_name,
          l_c_cal_type,
          l_n_seq_num,
	  g_n_user_id,
          SYSDATE,
          g_n_user_id,
          SYSDATE,
          g_n_login_id,
	  p_uso_cm_grp_rec.max_enr_group,
	  p_uso_cm_grp_rec.max_ovr_group
          ) RETURNING class_meet_group_id INTO l_n_class_meet_group_id;


         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_cm_grp.Record_Inserted',
	   'Unit code:'||p_uso_cm_grp_rec.unit_cd||'  '||'Version number:'||p_uso_cm_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_uso_cm_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_cm_grp_rec.location_cd||'  '||'Unit Class:'||
	   p_uso_cm_grp_rec.unit_class||'  '||'Class meet group name:'||p_uso_cm_grp_rec.class_meet_group_name);
         END IF;

        ELSE --update
	  UPDATE igs_ps_uso_cm_grp
	  SET max_enr_group=p_uso_cm_grp_rec.max_enr_group,
	  max_ovr_group=p_uso_cm_grp_rec.max_ovr_group,
	  last_updated_by = g_n_user_id,
	  last_update_date = SYSDATE,
	  last_update_login = g_n_login_id
	  WHERE class_meet_group_name =p_uso_cm_grp_rec.class_meet_group_name
	  AND cal_type = l_c_cal_type
	  AND ci_sequence_number =l_n_seq_num;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_cm_grp.Record_Updated',
	    'Unit code:'||p_uso_cm_grp_rec.unit_cd||'  '||'Version number:'||p_uso_cm_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_uso_cm_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_cm_grp_rec.location_cd||'  '||'Unit Class:'||
	    p_uso_cm_grp_rec.unit_class||'  '||'Class meet group name:'||p_uso_cm_grp_rec.class_meet_group_name);
         END IF;
        END IF;


	--populate the plsql table with unique cmgids
	IF class_meet_tab.count = 0 THEN
	  l_n_tbl_cnt :=class_meet_tab.count+1;
	  class_meet_tab(l_n_tbl_cnt).class_meet_group_name:= class_meet_rec.class_meet_group_name;
	  class_meet_tab(l_n_tbl_cnt).class_meet_group_id :=l_n_class_meet_group_id;
	  class_meet_tab(l_n_tbl_cnt).old_max_enr_group:=class_meet_rec.old_max_enr_group;
	ELSE
	  IF NOT ifexists(l_n_class_meet_group_id,class_meet_rec.old_max_enr_group) THEN
	    l_n_tbl_cnt :=class_meet_tab.count+1;
	    class_meet_tab(l_n_tbl_cnt).class_meet_group_name:= class_meet_rec.class_meet_group_name;
	    class_meet_tab(l_n_tbl_cnt).class_meet_group_id :=l_n_class_meet_group_id;
	    class_meet_tab(l_n_tbl_cnt).old_max_enr_group:=class_meet_rec.old_max_enr_group;
	  END IF;
	END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_cm_grp.Count_unique cmgids',
	  'teach_cal_alternate_code:'||p_uso_cm_grp_rec.teach_cal_alternate_code||'  '||'Class meet group name'
	  ||p_uso_cm_grp_rec.class_meet_group_name||'  '||'Count:'||class_meet_tab.count);
        END IF;


      END IF;

    END create_uso_cm_grp;

    PROCEDURE create_uso_clas_meet( p_uso_clas_meet_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type ) AS

      PROCEDURE validate_parameters_item ( p_uso_clas_meet_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type ) AS
      BEGIN

	/* Check for Mandatory Parameters */
	IF p_uso_clas_meet_rec.unit_cd IS NULL OR p_uso_clas_meet_rec.unit_cd = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
	  p_uso_clas_meet_rec.status := 'E';
	END IF;
	IF p_uso_clas_meet_rec.version_number IS NULL OR p_uso_clas_meet_rec.version_number = FND_API.G_MISS_NUM  THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
	  p_uso_clas_meet_rec.status := 'E';
	END IF;
	IF p_uso_clas_meet_rec.teach_cal_alternate_code IS NULL OR p_uso_clas_meet_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_uso_clas_meet_rec.status := 'E';
	END IF;
	IF p_uso_clas_meet_rec.location_cd IS NULL  OR p_uso_clas_meet_rec.location_cd = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD', 'LEGACY_TOKENS', FALSE);
	  p_uso_clas_meet_rec.status := 'E';
	END IF;
	IF p_uso_clas_meet_rec.unit_class IS NULL OR p_uso_clas_meet_rec.unit_class = FND_API.G_MISS_CHAR  THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CLASS', 'LEGACY_TOKENS', FALSE);
	  p_uso_clas_meet_rec.status := 'E';
	END IF;
	IF p_uso_clas_meet_rec.host IS NULL  OR p_uso_clas_meet_rec.host = FND_API.G_MISS_CHAR  THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'HOST', 'LEGACY_TOKENS', FALSE);
	  p_uso_clas_meet_rec.status := 'E';
	END IF;

      END validate_parameters_item;

      -- Check for Update
      FUNCTION check_insert_update_item ( p_uso_clas_meet_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type ) RETURN VARCHAR2 IS
	CURSOR c_uso_clas_meet(cp_n_uoo_id NUMBER) IS
	SELECT 'X'
	FROM igs_ps_uso_clas_meet
	WHERE uoo_id = cp_n_uoo_id;

	c_uso_clas_meet_rec c_uso_clas_meet%ROWTYPE;
      BEGIN
	OPEN c_uso_clas_meet(l_n_uoo_id);
	FETCH c_uso_clas_meet INTO c_uso_clas_meet_rec;
	IF c_uso_clas_meet%NOTFOUND THEN
	  CLOSE c_uso_clas_meet;
	  RETURN 'I';
	ELSE
	  CLOSE c_uso_clas_meet;
	  RETURN 'U';
	END IF;

      END check_insert_update_item;

      -- Carry out derivations and validate them
      PROCEDURE validate_derivations_item ( p_uso_clas_meet_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type) AS

	l_c_message  VARCHAR2(30);

      BEGIN

	-- Derive uoo_id
	l_c_message := NULL;
	igs_ps_validate_lgcy_pkg.get_uoo_id ( p_unit_cd    => p_uso_clas_meet_rec.unit_cd,
					      p_ver_num    => p_uso_clas_meet_rec.version_number,
					      p_cal_type   => l_c_cal_type,
					      p_seq_num    => l_n_seq_num,
					      p_loc_cd     => p_uso_clas_meet_rec.location_cd,
					      p_unit_class => p_uso_clas_meet_rec.unit_class,
					      p_uoo_id     => l_n_uoo_id,
					      p_message    => l_c_message );
	IF ( l_c_message IS NOT NULL ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	  p_uso_clas_meet_rec.status := 'E';
	END IF;

      END validate_derivations_item;


      -- Validate Database Constraints
      PROCEDURE validate_db_cons_cm ( p_uso_clas_meet_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type,p_insert_update VARCHAR2 ) AS
      BEGIN
	IF (p_insert_update = 'I') THEN
	/* Unique Key Validation */
	  IF igs_ps_uso_clas_meet_pkg.get_uk_for_validation (x_uoo_id =>l_n_uoo_id) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	    p_uso_clas_meet_rec.status := 'W';
	    RETURN;
	  END IF;
	END IF;

        /* Check constraint */
	IF p_uso_clas_meet_rec.host NOT IN ('Y','N') THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'HOST', 'LEGACY_TOKENS', FALSE);
	  p_uso_clas_meet_rec.status := 'E';
	END IF;

	  /* Validate FK Constraints */
	IF NOT igs_ps_uso_cm_grp_pkg.get_pk_for_validation ( l_n_class_meet_group_id ) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_MEET_WITH_CLASS_GROUP', 'LEGACY_TOKENS', FALSE);
	    p_uso_clas_meet_rec.status := 'E';
	END IF;

	IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	    p_uso_clas_meet_rec.status := 'E';
	END IF;

      END validate_db_cons_cm;

    -- Main section for meet with group child.
    BEGIN


      IF p_uso_clas_meet_rec.status = 'S' THEN
	validate_parameters_item(p_uso_clas_meet_rec);

	 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_clas_meet.status_after_validate_parameters_item',
	   'Unit code:'||p_uso_clas_meet_rec.unit_cd||'  '||'Version number:'||p_uso_clas_meet_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_uso_clas_meet_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_clas_meet_rec.location_cd||'  '||'Unit Class:'||
	   p_uso_clas_meet_rec.unit_class||'  '||'Class meet group name:'||p_uso_clas_meet_rec.class_meet_group_name||'  '||'Status:'|| p_uso_clas_meet_rec.status);
         END IF;
      END IF;


      IF p_uso_clas_meet_rec.status = 'S' THEN
	validate_derivations_item(p_uso_clas_meet_rec);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_clas_meet.status_after_validate_derivations_item',
	   'Unit code:'||p_uso_clas_meet_rec.unit_cd||'  '||'Version number:'||p_uso_clas_meet_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_uso_clas_meet_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_clas_meet_rec.location_cd||'  '||'Unit Class:'||
	   p_uso_clas_meet_rec.unit_class||'  '||'Class meet group name:'||p_uso_clas_meet_rec.class_meet_group_name||' '||'Status:'|| p_uso_clas_meet_rec.status);
        END IF;

      END IF;

      l_insert_update:='I';

      --Find out whether it is insert/update of record
      IF p_uso_clas_meet_rec.status = 'S' AND p_calling_context IN ('G','S') THEN
        l_insert_update:= check_insert_update_item(p_uso_clas_meet_rec);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_clas_meet.status_after_check_insert_update_item',
	   'Unit code:'||p_uso_clas_meet_rec.unit_cd||'  '||'Version number:'||p_uso_clas_meet_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_uso_clas_meet_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_clas_meet_rec.location_cd||'  '||'Unit Class:'||
	   p_uso_clas_meet_rec.unit_class||'  '||'Class meet group name:'||p_uso_clas_meet_rec.class_meet_group_name||'  '||'Status:'|| p_uso_clas_meet_rec.status);
        END IF;

      END IF;

      IF p_uso_clas_meet_rec.status = 'S' AND p_calling_context = 'S' THEN
        IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	  fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	  fnd_msg_pub.add;
	  p_uso_clas_meet_rec.status := 'A';
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_clas_meet.status_after_check_import_allowed',
	   'Unit code:'||p_uso_clas_meet_rec.unit_cd||'  '||'Version number:'||p_uso_clas_meet_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_uso_clas_meet_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_clas_meet_rec.location_cd||'  '||'Unit Class:'||
	   p_uso_clas_meet_rec.unit_class||'  '||'Class meet group name:'||p_uso_clas_meet_rec.class_meet_group_name||'  '||'Status:'|| p_uso_clas_meet_rec.status);
        END IF;

      END IF;

      IF p_uso_clas_meet_rec.status = 'S' THEN
        validate_db_cons_cm(p_uso_clas_meet_rec,l_insert_update);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_clas_meet.status_after_validate_db_cons_cm',
	   'Unit code:'||p_uso_clas_meet_rec.unit_cd||'  '||'Version number:'||p_uso_clas_meet_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_uso_clas_meet_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_clas_meet_rec.location_cd||'  '||'Unit Class:'||
	   p_uso_clas_meet_rec.unit_class||'  '||'Class meet group name:'||p_uso_clas_meet_rec.class_meet_group_name||'  '||'Status:'|| p_uso_clas_meet_rec.status);
        END IF;

      END IF;


      IF p_uso_clas_meet_rec.status = 'S' THEN
        igs_ps_validate_generic_pkg.validate_uso_clas_meet(p_uso_clas_meet_rec,l_n_uoo_id,l_n_class_meet_group_id,l_c_cal_type,l_n_seq_num);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_clas_meet.status_after_Business_validation',
	   'Unit code:'||p_uso_clas_meet_rec.unit_cd||'  '||'Version number:'||p_uso_clas_meet_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_uso_clas_meet_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_clas_meet_rec.location_cd||'  '||'Unit Class:'||
	   p_uso_clas_meet_rec.unit_class||'  '||'Class meet group name:'||p_uso_clas_meet_rec.class_meet_group_name||'  '||'Status:'|| p_uso_clas_meet_rec.status);
        END IF;

      END IF;

      IF p_uso_clas_meet_rec.status = 'S' THEN
        IF l_insert_update = 'I' THEN
	  /* Insert Record */
	  INSERT INTO igs_ps_uso_clas_meet
	  ( class_meet_id,
	   class_meet_group_id,
	   host,
	   created_by,
	   creation_date,
	   last_updated_by,
	   last_update_date,
	   last_update_login,
	   uoo_id
	  )
	  VALUES
	  (igs_ps_uso_clas_meet_s.NEXTVAL,
	  l_n_class_meet_group_id,
	  p_uso_clas_meet_rec.host,
	  g_n_user_id,
	  SYSDATE,
	  g_n_user_id,
	  SYSDATE,
	  g_n_login_id,
	  l_n_uoo_id
	  );

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_clas_meet.Record_Inserted',
	     'Unit code:'||p_uso_clas_meet_rec.unit_cd||'  '||'Version number:'||p_uso_clas_meet_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_uso_clas_meet_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_clas_meet_rec.location_cd||'  '||'Unit Class:'||
	     p_uso_clas_meet_rec.unit_class||'  '||'Class meet group name:'||p_uso_clas_meet_rec.class_meet_group_name);
           END IF;

        ELSE --update
	  UPDATE igs_ps_uso_clas_meet
	  SET host = p_uso_clas_meet_rec.host,
	  last_updated_by = g_n_user_id,
	  last_update_date = SYSDATE,
	  last_update_login = g_n_login_id
	  WHERE uoo_id = l_n_uoo_id;

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_clas_meet.Record_Updated',
	     'Unit code:'||p_uso_clas_meet_rec.unit_cd||'  '||'Version number:'||p_uso_clas_meet_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_uso_clas_meet_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_uso_clas_meet_rec.location_cd||'  '||'Unit Class:'||
	     p_uso_clas_meet_rec.unit_class||'  '||'Class meet group name:'||p_uso_clas_meet_rec.class_meet_group_name);
          END IF;

        END IF;
      END IF;

    END create_uso_clas_meet;


  /* Main Meet-With Unit Section  group  Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.start_logging_for',
                      'Meet-With Unit Section ');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_usec_meet_with_tbl.LAST LOOP
      l_c_cal_type:=NULL;
      l_n_seq_num:=NULL;
      l_n_uoo_id:= NULL;
      l_n_class_meet_group_id:= NULL;

      IF p_usec_meet_with_tbl.EXISTS(I) THEN
        p_usec_meet_with_tbl(I).status := 'S';
        p_usec_meet_with_tbl(I).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_usec_meet_with_tbl(I) );


	-- create meet with class group
	IF  p_usec_meet_with_tbl(I).status = 'S' THEN

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_cm_grp.call',
	     'Unit code:'||p_usec_meet_with_tbl(I).unit_cd||'  '||'Version number:'||p_usec_meet_with_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_meet_with_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_meet_with_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_meet_with_tbl(I).unit_class||'  '||'Class meet group name:'||p_usec_meet_with_tbl(I).class_meet_group_name);
          END IF;

	  create_uso_cm_grp(p_usec_meet_with_tbl(I));

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_cm_grp.status_after_creating_group_record',
	     'Unit code:'||p_usec_meet_with_tbl(I).unit_cd||'  '||'Version number:'||p_usec_meet_with_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_meet_with_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_meet_with_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_meet_with_tbl(I).unit_class||'  '||'Class meet group name:'||p_usec_meet_with_tbl(I).class_meet_group_name
	     ||'  '||'Status:'|| p_usec_meet_with_tbl(I).status);
          END IF;

	END IF;

	-- Create child
	IF  p_usec_meet_with_tbl(I).status = 'S' THEN
	  IF p_usec_meet_with_tbl(I).unit_cd IS NOT NULL THEN

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_clas_meet.call',
	     'Unit code:'||p_usec_meet_with_tbl(I).unit_cd||'  '||'Version number:'||p_usec_meet_with_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_meet_with_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_meet_with_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_meet_with_tbl(I).unit_class||'  '||'Class meet group name:'||p_usec_meet_with_tbl(I).class_meet_group_name);
          END IF;

            create_uso_clas_meet(p_usec_meet_with_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.create_uso_clas_meet.status_after_creating_item_record',
	     'Unit code:'||p_usec_meet_with_tbl(I).unit_cd||'  '||'Version number:'||p_usec_meet_with_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_meet_with_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_meet_with_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_meet_with_tbl(I).unit_class||'  '||'Class meet group name:'||p_usec_meet_with_tbl(I).class_meet_group_name
	     ||'  '||'Status:'|| p_usec_meet_with_tbl(I).status);
          END IF;

          END IF;
	END IF;

        IF  p_usec_meet_with_tbl(I).status = 'S' THEN
          p_usec_meet_with_tbl(I).msg_from := NULL;
          p_usec_meet_with_tbl(I).msg_to := NULL;
        ELSIF  p_usec_meet_with_tbl(I).status = 'A' THEN
	  p_usec_meet_with_tbl(I).msg_from  := p_usec_meet_with_tbl(I).msg_from + 1;
	  p_usec_meet_with_tbl(I).msg_to := fnd_msg_pub.count_msg;
	ELSE
          p_c_rec_status :=  p_usec_meet_with_tbl(I).status;
          p_usec_meet_with_tbl(I).msg_from :=  p_usec_meet_with_tbl(I).msg_from + 1;
          p_usec_meet_with_tbl(I).msg_to := fnd_msg_pub.count_msg;
          IF p_c_rec_status = 'E' THEN
            RETURN;
          END IF;
        END IF;
      END IF;--exists
    END LOOP;


    /* Post Insert/Update Checks */
    IF NOT igs_ps_validate_generic_pkg.post_usec_meet_with(p_usec_meet_with_tbl,class_meet_tab) THEN
      p_c_rec_status := 'E';
    END IF;

    class_meet_tab.DELETE;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_meet_with.after_import_status',p_c_rec_status);
    END IF;

  END create_usec_meet_with;

  --This procedure is a sub process to import records of Cross-listed Unit Section Group .
  PROCEDURE create_usec_cross_group(
          p_usec_cross_group_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context  IN VARCHAR2
  )   AS
  /***********************************************************************************************
    Created By     :  SOMMUKHE
    Date Created By:  17-Jun-2005
    Purpose        :  This procedure is a sub process to import records of Cross-listed Unit Section Group.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */

    l_n_usec_x_listed_group_id  igs_ps_usec_x_grp.usec_x_listed_group_id%type;
    l_n_uoo_id                  igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_c_cal_type                igs_ps_unit_ofr_opt_all.cal_type%TYPE;
    l_n_seq_num                 igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;
    l_insert_update             VARCHAR2(1);

    FUNCTION ifexists(p_n_usec_x_listed_group_id igs_ps_usec_x_grp.usec_x_listed_group_id%type,
                   p_old_max_enr_group igs_ps_usec_x_grp.max_enr_group%TYPE) RETURN BOOLEAN AS
    BEGIN
      FOR I in 1..cross_group_tab.count LOOP

         IF p_n_usec_x_listed_group_id = cross_group_tab(i).usec_x_listed_group_id THEN
           cross_group_tab(i).old_max_enr_group:= p_old_max_enr_group;
	   RETURN TRUE;
         END IF;
      END LOOP;
      RETURN FALSE;
    END ifexists;


    /* Private Procedures for create_usec_grd_sch */
    PROCEDURE trim_values ( p_usec_cross_group_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type ) AS
    BEGIN
      p_usec_cross_group_rec.unit_cd := trim(p_usec_cross_group_rec.unit_cd);
      p_usec_cross_group_rec.version_number := trim(p_usec_cross_group_rec.version_number);
      p_usec_cross_group_rec.teach_cal_alternate_code := trim(p_usec_cross_group_rec.teach_cal_alternate_code);
      p_usec_cross_group_rec.location_cd := trim(p_usec_cross_group_rec.location_cd);
      p_usec_cross_group_rec.unit_class := trim(p_usec_cross_group_rec.unit_class);
      p_usec_cross_group_rec.usec_x_listed_group_name := trim(p_usec_cross_group_rec.usec_x_listed_group_name);
      p_usec_cross_group_rec.location_inheritance := trim(p_usec_cross_group_rec.location_inheritance);
      p_usec_cross_group_rec.max_enr_group := trim(p_usec_cross_group_rec.max_enr_group);
      p_usec_cross_group_rec.max_ovr_group := trim(p_usec_cross_group_rec.max_ovr_group);
      p_usec_cross_group_rec.parent := trim(p_usec_cross_group_rec.parent);

    END trim_values;


    PROCEDURE create_usec_x_grp( p_usec_x_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type ) AS

      l_n_tbl_cnt NUMBER;

      PROCEDURE validate_parameters ( p_usec_x_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type ) AS
      BEGIN

	/* Check for Mandatory Parameters */
	IF p_usec_x_grp_rec.teach_cal_alternate_code IS NULL OR p_usec_x_grp_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_usec_x_grp_rec.status := 'E';
	END IF;

	IF p_usec_x_grp_rec.usec_x_listed_group_name IS NULL  OR p_usec_x_grp_rec.usec_x_listed_group_name = FND_API.G_MISS_CHAR  THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'GROUP_NAME', 'LEGACY_TOKENS', FALSE);
	  p_usec_x_grp_rec.status := 'E';
	END IF;

      END validate_parameters;

      -- Check for Update
      FUNCTION check_insert_update ( p_usec_x_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type ) RETURN VARCHAR2 IS
	CURSOR c_usec_x_grp(cp_x_grp_name VARCHAR2) IS
	SELECT 'X'
	FROM   igs_ps_usec_x_grp
	WHERE  usec_x_listed_group_name = cp_x_grp_name
	AND    cal_type = l_c_cal_type
	AND    ci_sequence_number = l_n_seq_num;
	c_usec_x_grp_rec c_usec_x_grp%ROWTYPE;
      BEGIN
	  OPEN c_usec_x_grp( p_usec_x_grp_rec.usec_x_listed_group_name);
	  FETCH c_usec_x_grp INTO c_usec_x_grp_rec;
	  IF c_usec_x_grp%NOTFOUND THEN
	    CLOSE c_usec_x_grp;
	    RETURN 'I';
	  ELSE
	    CLOSE c_usec_x_grp;
	    RETURN 'U';
	  END IF;
      END check_insert_update;

      -- Carry out derivations and validate them
      PROCEDURE validate_derivations ( p_usec_x_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type) AS
	l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
	l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
	l_c_message  VARCHAR2(30);
      BEGIN

	-- Derive Calander Type and Sequence Number
	igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_usec_x_grp_rec.teach_cal_alternate_code,
					       p_cal_type           => l_c_cal_type,
					       p_ci_sequence_number => l_n_seq_num,
					       p_start_dt           => l_d_start_dt,
					       p_end_dt             => l_d_end_dt,
					       p_return_status      => l_c_message );
	IF ( l_c_message <> 'SINGLE' ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_usec_x_grp_rec.status := 'E';
	END IF;


      END validate_derivations;

      PROCEDURE Assign_default( p_usec_x_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type,p_insert_update VARCHAR2 ) AS

        CURSOR c_usec_x_grp(cp_x_grp_name VARCHAR2) IS
	SELECT *
	FROM   igs_ps_usec_x_grp
	WHERE  usec_x_listed_group_name =cp_x_grp_name
	AND    cal_type=l_c_cal_type
	AND    ci_sequence_number=l_n_seq_num;

	c_usec_x_grp_rec c_usec_x_grp%ROWTYPE;

      BEGIN

	IF p_insert_update = 'U' THEN
	   OPEN c_usec_x_grp(p_usec_x_grp_rec.usec_x_listed_group_name);
	   FETCH c_usec_x_grp INTO c_usec_x_grp_rec;
	   CLOSE c_usec_x_grp;
	   l_n_usec_x_listed_group_id:= c_usec_x_grp_rec.usec_x_listed_group_id;

	   IF p_usec_x_grp_rec.max_enr_group IS NULL  THEN
	      p_usec_x_grp_rec.max_enr_group := c_usec_x_grp_rec.max_enr_group;
	   ELSIF  p_usec_x_grp_rec.max_enr_group = FND_API.G_MISS_NUM THEN
	      p_usec_x_grp_rec.max_enr_group :=NULL;
	   END IF;

	   IF p_usec_x_grp_rec.max_ovr_group IS NULL THEN
	     p_usec_x_grp_rec.max_ovr_group := c_usec_x_grp_rec.max_ovr_group;
	   ELSIF p_usec_x_grp_rec.max_ovr_group = FND_API.G_MISS_NUM THEN
	     p_usec_x_grp_rec.max_ovr_group :=NULL;
	   END IF;

   	   IF p_usec_x_grp_rec.location_inheritance IS NULL THEN
	     p_usec_x_grp_rec.location_inheritance := c_usec_x_grp_rec.location_inheritance;
	   ELSIF p_usec_x_grp_rec.location_inheritance = FND_API.G_MISS_CHAR THEN
	     p_usec_x_grp_rec.location_inheritance :='N';
	   END IF;
	END IF;

      END Assign_default;

      -- Validate Database Constraints
      PROCEDURE validate_db_cons ( p_usec_x_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type,p_insert_update VARCHAR2 ) AS
      BEGIN
	IF (p_insert_update = 'I') THEN
	  /* Unique Key Validation */
	  IF igs_ps_usec_x_grp_pkg.get_uk_for_validation (x_usec_x_listed_group_name=>p_usec_x_grp_rec.usec_x_listed_group_name,
							  x_cal_type=>l_c_cal_type,
							  x_ci_sequence_number=>l_n_seq_num) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'USEC_CROSS_LIST_GROUP', 'LEGACY_TOKENS', FALSE);
	    p_usec_x_grp_rec.status := 'W';
	    RETURN;
	  END IF;
	END IF;

        --Check constraint
	IF p_usec_x_grp_rec.max_enr_group IS NOT NULL THEN
	  IF p_usec_x_grp_rec.max_enr_group <1 OR p_usec_x_grp_rec.max_enr_group >999999 THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_1_999999', 'MAX_ENR_GROUP', 'LEGACY_TOKENS', FALSE);
	    p_usec_x_grp_rec.status := 'E';
	  END IF;

	  --Format mask validation
	  IF p_usec_x_grp_rec.status <> 'E' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_usec_x_grp_rec.max_enr_group,6,0) THEN
	        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_1_999999', 'MAX_ENR_GROUP', 'LEGACY_TOKENS', FALSE);
		p_usec_x_grp_rec.status :='E';
	    END IF;
	  END IF;

	END IF;


	IF p_usec_x_grp_rec.max_ovr_group IS NOT NULL THEN
	  IF p_usec_x_grp_rec.max_ovr_group <1 OR p_usec_x_grp_rec.max_ovr_group >999999 THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_1_999999', 'MAX_OVR_GROUP', 'LEGACY_TOKENS', FALSE);
	    p_usec_x_grp_rec.status := 'E';
	  END IF;

	  --Format mask validation
	  IF p_usec_x_grp_rec.status <> 'E' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_usec_x_grp_rec.max_ovr_group,6,0) THEN
	        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_1_999999', 'MAX_OVR_GROUP', 'LEGACY_TOKENS', FALSE);
		p_usec_x_grp_rec.status :='E';
	    END IF;
	  END IF;

	END IF;

	/* Validate FK Constraints*/
	IF NOT igs_ca_inst_pkg.get_pk_for_validation (x_cal_type =>l_c_cal_type,
						      x_sequence_number =>l_n_seq_num) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_usec_x_grp_rec.status := 'E';
	END IF;


      END validate_db_cons;

    -- Main section for assesment item group.
    BEGIN

       IF p_usec_x_grp_rec.status = 'S' THEN
          validate_parameters(p_usec_x_grp_rec);

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grp.status_after_validate_parameters',
             'Unit code:'||p_usec_x_grp_rec.unit_cd||'  '||'Version number:'||p_usec_x_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_x_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grp_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_x_grp_rec.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grp_rec.usec_x_listed_group_name
	     ||'  '||'Status:'|| p_usec_x_grp_rec.status);
          END IF;

       END IF;

       IF p_usec_x_grp_rec.status = 'S' THEN
          validate_derivations(p_usec_x_grp_rec);

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grp.status_after_validate_derivations',
             'Unit code:'||p_usec_x_grp_rec.unit_cd||'  '||'Version number:'||p_usec_x_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_x_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grp_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_x_grp_rec.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grp_rec.usec_x_listed_group_name
	     ||'  '||'Status:'|| p_usec_x_grp_rec.status);
          END IF;

       END IF;

       --Find out whether it is insert/update of record
       l_insert_update:='I';
       IF p_usec_x_grp_rec.status = 'S' AND p_calling_context IN ('G','S') THEN
           l_insert_update:= check_insert_update(p_usec_x_grp_rec);

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grp.status_after_check_insert_update',
             'Unit code:'||p_usec_x_grp_rec.unit_cd||'  '||'Version number:'||p_usec_x_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_x_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grp_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_x_grp_rec.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grp_rec.usec_x_listed_group_name
	     ||'  '||'Status:'|| p_usec_x_grp_rec.status);
           END IF;


       END IF;

       -- Find out whether record can go for import in context of cancelled/aborted
       IF p_usec_x_grp_rec.status = 'S' AND p_calling_context = 'S' THEN
	 IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	    fnd_msg_pub.add;
	    p_usec_x_grp_rec.status := 'A';
	 END IF;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grp.status_after_check_import_allowed',
	   'Unit code:'||p_usec_x_grp_rec.unit_cd||'  '||'Version number:'||p_usec_x_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_x_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grp_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_x_grp_rec.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grp_rec.usec_x_listed_group_name
	   ||'  '||'Status:'|| p_usec_x_grp_rec.status);
         END IF;


       END IF;

       IF p_usec_x_grp_rec.status = 'S' THEN
	  Assign_default(p_usec_x_grp_rec,l_insert_update);

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grp.status_after_Assign_default',
	    'Unit code:'||p_usec_x_grp_rec.unit_cd||'  '||'Version number:'||p_usec_x_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_x_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grp_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_x_grp_rec.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grp_rec.usec_x_listed_group_name
	    ||'  '||'Status:'|| p_usec_x_grp_rec.status);
          END IF;

       END IF;

       IF p_usec_x_grp_rec.status = 'S' THEN
          validate_db_cons(p_usec_x_grp_rec,l_insert_update);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grp.status_after_validate_db_cons',
	    'Unit code:'||p_usec_x_grp_rec.unit_cd||'  '||'Version number:'||p_usec_x_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_x_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grp_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_x_grp_rec.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grp_rec.usec_x_listed_group_name
	    ||'  '||'Status:'|| p_usec_x_grp_rec.status);
          END IF;

       END IF;

       IF p_usec_x_grp_rec.status = 'S' THEN
         igs_ps_validate_generic_pkg.validate_usec_x_grp(p_usec_x_grp_rec, l_c_cal_type,l_n_seq_num,l_insert_update,cross_group_rec);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grp.status_after_Business_validation',
	    'Unit code:'||p_usec_x_grp_rec.unit_cd||'  '||'Version number:'||p_usec_x_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_x_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grp_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_x_grp_rec.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grp_rec.usec_x_listed_group_name
	    ||'  '||'Status:'|| p_usec_x_grp_rec.status);
          END IF;

       END IF;

       IF p_usec_x_grp_rec.status = 'S' THEN
	 IF l_insert_update = 'I' THEN
           /* Insert Record */
           INSERT INTO igs_ps_usec_x_grp
           (usec_x_listed_group_id,
           usec_x_listed_group_name,
	   location_inheritance,
           cal_type,
           ci_sequence_number ,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
	   max_enr_group,
           max_ovr_group
           )
           VALUES
           (igs_ps_usec_x_grp_s.NEXTVAL,
           p_usec_x_grp_rec.usec_x_listed_group_name,
	   NVL(p_usec_x_grp_rec.location_inheritance,'Y'),
           l_c_cal_type,
           l_n_seq_num,
	   g_n_user_id,
           SYSDATE,
           g_n_user_id,
           SYSDATE,
           g_n_login_id,
	   p_usec_x_grp_rec.max_enr_group,
	   p_usec_x_grp_rec.max_ovr_group
           ) RETURNING usec_x_listed_group_id INTO l_n_usec_x_listed_group_id;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grp.Record_Inserted',
	    'Unit code:'||p_usec_x_grp_rec.unit_cd||'  '||'Version number:'||p_usec_x_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_x_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grp_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_x_grp_rec.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grp_rec.usec_x_listed_group_name);
          END IF;

         ELSE --update
	   UPDATE igs_ps_usec_x_grp
	   SET max_enr_group=p_usec_x_grp_rec.max_enr_group,
	   max_ovr_group=p_usec_x_grp_rec.max_ovr_group,
	   last_updated_by = g_n_user_id,
	   last_update_date = SYSDATE,
	   last_update_login = g_n_login_id
	   WHERE usec_x_listed_group_name =p_usec_x_grp_rec.usec_x_listed_group_name
	   AND cal_type = l_c_cal_type
	   AND ci_sequence_number =l_n_seq_num;

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grp.Record_Updated',
	     'Unit code:'||p_usec_x_grp_rec.unit_cd||'  '||'Version number:'||p_usec_x_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_x_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grp_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_x_grp_rec.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grp_rec.usec_x_listed_group_name);
           END IF;

         END IF;

	 --populate the plsql table with unique cmgids
	 IF cross_group_tab.count = 0 THEN
	   l_n_tbl_cnt :=cross_group_tab.count+1;
	   cross_group_tab(l_n_tbl_cnt).usec_x_listed_group_name:= cross_group_rec.usec_x_listed_group_name;
	   cross_group_tab(l_n_tbl_cnt).usec_x_listed_group_id :=l_n_usec_x_listed_group_id;
	   cross_group_tab(l_n_tbl_cnt).old_max_enr_group:=cross_group_rec.old_max_enr_group;
	 ELSE
	   IF NOT ifexists(l_n_usec_x_listed_group_id,cross_group_rec.old_max_enr_group) THEN
	     l_n_tbl_cnt :=cross_group_tab.count+1;
	     cross_group_tab(l_n_tbl_cnt).usec_x_listed_group_name:= cross_group_rec.usec_x_listed_group_name;
	     cross_group_tab(l_n_tbl_cnt).usec_x_listed_group_id :=l_n_usec_x_listed_group_id;
	     cross_group_tab(l_n_tbl_cnt).old_max_enr_group:=cross_group_rec.old_max_enr_group;
	   END IF;
	 END IF;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.Count_unique_xgids',
	   'Unit code:'||p_usec_x_grp_rec.unit_cd||'  '||'Version number:'||p_usec_x_grp_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_x_grp_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grp_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_x_grp_rec.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grp_rec.usec_x_listed_group_name
	   ||'  '||'Count:'||cross_group_tab.count);
         END IF;


       END IF;

    END create_usec_x_grp;

    PROCEDURE create_usec_x_grpmem( p_usec_x_grpmem IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type ) AS





      PROCEDURE validate_parameters_item ( p_usec_x_grpmem IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type ) AS
      BEGIN

	/* Check for Mandatory Parameters */
	IF p_usec_x_grpmem.unit_cd IS NULL OR p_usec_x_grpmem.unit_cd = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
	  p_usec_x_grpmem.status := 'E';
	END IF;
	IF p_usec_x_grpmem.version_number IS NULL OR p_usec_x_grpmem.version_number = FND_API.G_MISS_NUM  THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
	  p_usec_x_grpmem.status := 'E';
	END IF;
	IF p_usec_x_grpmem.teach_cal_alternate_code IS NULL OR p_usec_x_grpmem.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_usec_x_grpmem.status := 'E';
	END IF;
	IF p_usec_x_grpmem.location_cd IS NULL  OR p_usec_x_grpmem.location_cd = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD', 'LEGACY_TOKENS', FALSE);
	  p_usec_x_grpmem.status := 'E';
	END IF;
	IF p_usec_x_grpmem.unit_class IS NULL OR p_usec_x_grpmem.unit_class = FND_API.G_MISS_CHAR  THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CLASS', 'LEGACY_TOKENS', FALSE);
	  p_usec_x_grpmem.status := 'E';
	END IF;
	IF p_usec_x_grpmem.parent IS NULL  OR p_usec_x_grpmem.parent = FND_API.G_MISS_CHAR  THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PARENT', 'LEGACY_TOKENS', FALSE);
	  p_usec_x_grpmem.status := 'E';
	END IF;

      END validate_parameters_item;

      -- Check for Update
      FUNCTION check_insert_update_item ( p_usec_x_grpmem IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type ) RETURN VARCHAR2 IS
	CURSOR c_usec_x_grpmem(cp_n_uoo_id NUMBER) IS
	SELECT 'X'
	FROM   igs_ps_usec_x_grpmem
	WHERE  uoo_id = cp_n_uoo_id;

	c_usec_x_grpmem_rec c_usec_x_grpmem%ROWTYPE;
      BEGIN
	OPEN c_usec_x_grpmem(l_n_uoo_id);
	FETCH c_usec_x_grpmem INTO c_usec_x_grpmem_rec;
	IF c_usec_x_grpmem%NOTFOUND THEN
	  CLOSE c_usec_x_grpmem;
	  RETURN 'I';
	ELSE
	  CLOSE c_usec_x_grpmem;
	  RETURN 'U';
	END IF;

      END check_insert_update_item;

      -- Carry out derivations and validate them
      PROCEDURE validate_derivations_item ( p_usec_x_grpmem IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type) AS

	  l_c_message  VARCHAR2(30);

      BEGIN

	-- Derive uoo_id
	l_c_message := NULL;
	igs_ps_validate_lgcy_pkg.get_uoo_id ( p_unit_cd    => p_usec_x_grpmem.unit_cd,
					      p_ver_num    => p_usec_x_grpmem.version_number,
					      p_cal_type   => l_c_cal_type,
					      p_seq_num    => l_n_seq_num,
					      p_loc_cd     => p_usec_x_grpmem.location_cd,
					      p_unit_class => p_usec_x_grpmem.unit_class,
					      p_uoo_id     => l_n_uoo_id,
					      p_message    => l_c_message );
	IF ( l_c_message IS NOT NULL ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	  p_usec_x_grpmem.status := 'E';
	END IF;

      END validate_derivations_item;


      -- Validate Database Constraints
      PROCEDURE validate_db_cons_cm ( p_usec_x_grpmem IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type,p_insert_update VARCHAR2 ) AS
      BEGIN

	IF (p_insert_update = 'I') THEN
	/* Unique Key Validation */
	  IF igs_ps_usec_x_grpmem_pkg.get_uk_for_validation (x_uoo_id =>l_n_uoo_id) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	    p_usec_x_grpmem.status := 'W';
	    RETURN;
	  END IF;
	END IF;

        /* Check constraint */
	IF p_usec_x_grpmem.parent NOT IN ('Y','N') THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'PARENT', 'LEGACY_TOKENS', FALSE);
	  p_usec_x_grpmem.status := 'E';
	END IF;

	  /* Validate FK Constraints */
	IF NOT igs_ps_usec_x_grp_pkg.get_pk_for_validation ( l_n_usec_x_listed_group_id ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_CROSS_LIST_GROUP', 'LEGACY_TOKENS', FALSE);
	  p_usec_x_grpmem.status := 'E';
	END IF;

	IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	  p_usec_x_grpmem.status := 'E';
	END IF;


      END validate_db_cons_cm;

    -- Main section for assesment item group.
    BEGIN

      IF p_usec_x_grpmem.status = 'S' THEN
         validate_parameters_item(p_usec_x_grpmem);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grpmem.status_after_validate_parameters_item',
	   'Unit code:'||p_usec_x_grpmem.unit_cd||'  '||'Version number:'||p_usec_x_grpmem.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_x_grpmem.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grpmem.location_cd||'  '||'Unit Class:'||
	   p_usec_x_grpmem.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grpmem.usec_x_listed_group_name
	   ||'  '||'Status:'|| p_usec_x_grpmem.status);
         END IF;

      END IF;

      IF p_usec_x_grpmem.status = 'S' THEN
	validate_derivations_item(p_usec_x_grpmem);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grpmem.status_after_validate_derivations_item',
	   'Unit code:'||p_usec_x_grpmem.unit_cd||'  '||'Version number:'||p_usec_x_grpmem.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_x_grpmem.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grpmem.location_cd||'  '||'Unit Class:'||
	   p_usec_x_grpmem.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grpmem.usec_x_listed_group_name
	   ||'  '||'Status:'|| p_usec_x_grpmem.status);
         END IF;

      END IF;

      l_insert_update:='I';
      --Find out whether it is insert/update of record
      IF p_usec_x_grpmem.status = 'S' AND p_calling_context IN ('G','S') THEN
	l_insert_update:= check_insert_update_item(p_usec_x_grpmem);

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grpmem.status_after_check_insert_update_item',
	   'Unit code:'||p_usec_x_grpmem.unit_cd||'  '||'Version number:'||p_usec_x_grpmem.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_x_grpmem.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grpmem.location_cd||'  '||'Unit Class:'||
	   p_usec_x_grpmem.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grpmem.usec_x_listed_group_name
	   ||'  '||'Status:'|| p_usec_x_grpmem.status);
        END IF;

      END IF;

      IF p_usec_x_grpmem.status = 'S' AND p_calling_context = 'S' THEN
	IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	  fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	  fnd_msg_pub.add;
	  p_usec_x_grpmem.status := 'A';
	END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grpmem.status_after_check_import_allowed',
	   'Unit code:'||p_usec_x_grpmem.unit_cd||'  '||'Version number:'||p_usec_x_grpmem.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_x_grpmem.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grpmem.location_cd||'  '||'Unit Class:'||
	   p_usec_x_grpmem.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grpmem.usec_x_listed_group_name
	   ||'  '||'Status:'|| p_usec_x_grpmem.status);
        END IF;

      END IF;

      IF p_usec_x_grpmem.status = 'S' THEN
	validate_db_cons_cm(p_usec_x_grpmem,l_insert_update);

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grpmem.status_after_validate_db_cons_cm',
	   'Unit code:'||p_usec_x_grpmem.unit_cd||'  '||'Version number:'||p_usec_x_grpmem.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_x_grpmem.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grpmem.location_cd||'  '||'Unit Class:'||
	   p_usec_x_grpmem.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grpmem.usec_x_listed_group_name
	   ||'  '||'Status:'|| p_usec_x_grpmem.status);
        END IF;

      END IF;

      IF p_usec_x_grpmem.status = 'S' THEN
	igs_ps_validate_generic_pkg.validate_usec_x_grpmem(p_usec_x_grpmem,l_n_uoo_id,l_n_usec_x_listed_group_id,l_c_cal_type,l_n_seq_num);

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grpmem.status_after_Business_validation',
	   'Unit code:'||p_usec_x_grpmem.unit_cd||'  '||'Version number:'||p_usec_x_grpmem.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_x_grpmem.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grpmem.location_cd||'  '||'Unit Class:'||
	   p_usec_x_grpmem.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grpmem.usec_x_listed_group_name
	   ||'  '||'Status:'|| p_usec_x_grpmem.status);
        END IF;

      END IF;

      IF p_usec_x_grpmem.status = 'S' THEN
	IF l_insert_update = 'I' THEN
	  /* Insert Record */
	  INSERT INTO igs_ps_usec_x_grpmem
	  ( usec_x_listed_group_mem_id,
	   usec_x_listed_group_id,
	   parent,
	   created_by,
	   creation_date,
	   last_updated_by,
	   last_update_date,
	   last_update_login,
	   uoo_id
	  )
	  VALUES
	  (igs_ps_usec_x_grpmem_s.NEXTVAL,
	  l_n_usec_x_listed_group_id,
	  p_usec_x_grpmem.parent,
	  g_n_user_id,
	  SYSDATE,
	  g_n_user_id,
	  SYSDATE,
	  g_n_login_id,
	  l_n_uoo_id
	  );

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grpmem.Record_Inserted',
	    'Unit code:'||p_usec_x_grpmem.unit_cd||'  '||'Version number:'||p_usec_x_grpmem.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_x_grpmem.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grpmem.location_cd||'  '||'Unit Class:'||
	    p_usec_x_grpmem.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grpmem.usec_x_listed_group_name);
          END IF;

	ELSE --update
	  UPDATE igs_ps_usec_x_grpmem
	  SET parent = p_usec_x_grpmem.parent,
	  last_updated_by = g_n_user_id,
	  last_update_date = SYSDATE,
          last_update_login = g_n_login_id
	  WHERE uoo_id = l_n_uoo_id;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grpmem.Record_updated',
	    'Unit code:'||p_usec_x_grpmem.unit_cd||'  '||'Version number:'||p_usec_x_grpmem.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_x_grpmem.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_x_grpmem.location_cd||'  '||'Unit Class:'||
	    p_usec_x_grpmem.unit_class||'  '||'usec_x_listed_group_name:'||p_usec_x_grpmem.usec_x_listed_group_name);
          END IF;

	END IF;
      END IF;

    END create_usec_x_grpmem;


  /* Main Unit Section meet with class group  Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.start_logging_for',
                    'Unit Section meet with class group');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_usec_cross_group_tbl.LAST LOOP
      l_c_cal_type:=NULL;
      l_n_seq_num:=NULL;
      l_n_uoo_id:= NULL;
      l_n_usec_x_listed_group_id :=NULL;

      IF p_usec_cross_group_tbl.EXISTS(I) THEN
        p_usec_cross_group_tbl(I).status := 'S';
        p_usec_cross_group_tbl(I).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_usec_cross_group_tbl(I) );


	-- create crosslisted group
	 IF  p_usec_cross_group_tbl(I).status = 'S' THEN

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grp.call',
	     'Unit code:'||p_usec_cross_group_tbl(I).unit_cd||'  '||'Version number:'||p_usec_cross_group_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_cross_group_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_cross_group_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_cross_group_tbl(I).unit_class||'  '||'usec_x_listed_group_name:'||p_usec_cross_group_tbl(I).usec_x_listed_group_name);
           END IF;

	   create_usec_x_grp(p_usec_cross_group_tbl(I));

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grp.status_after_creating_group_record',
             'Unit code:'||p_usec_cross_group_tbl(I).unit_cd||'  '||'Version number:'||p_usec_cross_group_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_cross_group_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_cross_group_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_cross_group_tbl(I).unit_class||'  '||'usec_x_listed_group_name:'||p_usec_cross_group_tbl(I).usec_x_listed_group_name
	     ||'  '||'Status:'|| p_usec_cross_group_tbl(I).status);
          END IF;

	 END IF;

	-- create crosslisted group member
	IF  p_usec_cross_group_tbl(I).status = 'S' THEN
	   IF  p_usec_cross_group_tbl(I).unit_cd IS NOT NULL THEN

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grpmem.call',
	     'Unit code:'||p_usec_cross_group_tbl(I).unit_cd||'  '||'Version number:'||p_usec_cross_group_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_cross_group_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_cross_group_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_cross_group_tbl(I).unit_class||'  '||'usec_x_listed_group_name:'||p_usec_cross_group_tbl(I).usec_x_listed_group_name);
           END IF;

              create_usec_x_grpmem(p_usec_cross_group_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.create_usec_x_grpmem.status_after_creating_item_record',
             'Unit code:'||p_usec_cross_group_tbl(I).unit_cd||'  '||'Version number:'||p_usec_cross_group_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_cross_group_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_cross_group_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_cross_group_tbl(I).unit_class||'  '||'usec_x_listed_group_name:'||p_usec_cross_group_tbl(I).usec_x_listed_group_name
	     ||'  '||'Status:'|| p_usec_cross_group_tbl(I).status);
          END IF;

           END IF;
	END IF;

         IF  p_usec_cross_group_tbl(I).status = 'S' THEN
           p_usec_cross_group_tbl(I).msg_from := NULL;
           p_usec_cross_group_tbl(I).msg_to := NULL;
        ELSIF  p_usec_cross_group_tbl(I).status = 'A' THEN
	   p_usec_cross_group_tbl(I).msg_from  := p_usec_cross_group_tbl(I).msg_from + 1;
	   p_usec_cross_group_tbl(I).msg_to := fnd_msg_pub.count_msg;
	ELSE
           p_c_rec_status :=  p_usec_cross_group_tbl(I).status;
           p_usec_cross_group_tbl(I).msg_from :=  p_usec_cross_group_tbl(I).msg_from + 1;
           p_usec_cross_group_tbl(I).msg_to := fnd_msg_pub.count_msg;
          IF p_c_rec_status = 'E' THEN
            RETURN;
          END IF;
        END IF;
      END IF;--exists
    END LOOP;

    /* Post Insert/Update Checks */
    IF NOT igs_ps_validate_generic_pkg.post_usec_cross_group(p_usec_cross_group_tbl,cross_group_tab) THEN
      p_c_rec_status := 'E';
    END IF;

    cross_group_tab.DELETE;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_cross_group.after_import_status',p_c_rec_status);
    END IF;

  END create_usec_cross_group;


--Unit Section Waitlist
PROCEDURE create_usec_waitlist(
          p_usec_waitlist_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_tbl_type,
          p_c_rec_status      OUT NOCOPY VARCHAR2,
	  p_calling_context   IN VARCHAR2
  ) AS
  /***********************************************************************************************
    Created By     :  Sommukhe
    Date Created By:  18-Jun-2005
    Purpose        :  This procedure is a sub process to insert records of Unit Section Waitlist priority and preference.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    --sommukhe    12-AUG-2005     Bug#4377818,changed the cursor cur_hzp, included table igs_pe_hz_parties in
    --                            FROM clause and modified the WHERE clause by joining HZ_PARTIES and IGS_PE_HZ_PARTIES
    --                            using party_id and org unit being compared with oss_org_unit_cd of IGS_PE_HZ_PARTIES.
  ********************************************************************************************** */

    l_insert_update       VARCHAR2(1);
    l_n_uoo_id            igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_n_wlst_usec_pri_id  igs_ps_usec_wlst_pri.unit_sec_waitlist_priority_id%type;
    l_tbl_uoo             igs_ps_create_generic_pkg.uoo_tbl_type;

    /* Private Procedures for create_usec_waitlist */
    PROCEDURE trim_values ( p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type ) AS
    BEGIN
      p_usec_wlst_rec.unit_cd := trim(p_usec_wlst_rec.unit_cd);
      p_usec_wlst_rec.version_number := trim(p_usec_wlst_rec.version_number);
      p_usec_wlst_rec.teach_cal_alternate_code := trim(p_usec_wlst_rec.teach_cal_alternate_code);
      p_usec_wlst_rec.location_cd := trim(p_usec_wlst_rec.location_cd);
      p_usec_wlst_rec.unit_class := trim(p_usec_wlst_rec.unit_class);
      p_usec_wlst_rec.priority_number := trim(p_usec_wlst_rec.priority_number);
      p_usec_wlst_rec.priority_value := trim(p_usec_wlst_rec.priority_value);
      p_usec_wlst_rec.preference_order := trim(p_usec_wlst_rec.preference_order);
      p_usec_wlst_rec.preference_code := trim(p_usec_wlst_rec.preference_code);
      p_usec_wlst_rec.preference_version := trim(p_usec_wlst_rec.preference_version);

    END trim_values;

    PROCEDURE create_wlstpri( p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type ) AS

      -- validate parameters passed waitlist Priority
      PROCEDURE validate_parameters( p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type ) AS
      BEGIN

	/* Check for Mandatory Parameters */
	IF p_usec_wlst_rec.unit_cd IS NULL OR p_usec_wlst_rec.unit_cd = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;
	IF p_usec_wlst_rec.version_number IS NULL OR p_usec_wlst_rec.version_number = FND_API.G_MISS_NUM THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;
	IF p_usec_wlst_rec.teach_cal_alternate_code IS NULL OR p_usec_wlst_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;
	IF p_usec_wlst_rec.location_cd IS NULL OR p_usec_wlst_rec.location_cd = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;
	IF p_usec_wlst_rec.unit_class IS NULL OR p_usec_wlst_rec.unit_class = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CLASS', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;
	IF p_usec_wlst_rec.priority_value IS NULL OR p_usec_wlst_rec.priority_value = FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PRIORITY_VALUE', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;

      END validate_parameters ;


      --Validate the derivations
      PROCEDURE validate_derivations_pri ( p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type,p_insert_update VARCHAR2 ) AS
	l_c_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE;
	l_n_seq_num  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;
	l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
	l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
	l_c_message  VARCHAR2(30);

      BEGIN
	-- Derive Calander Type and Sequence Number
	igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_usec_wlst_rec.teach_cal_alternate_code,
					       p_cal_type           => l_c_cal_type,
					       p_ci_sequence_number => l_n_seq_num,
					       p_start_dt           => l_d_start_dt,
					       p_end_dt             => l_d_end_dt,
					       p_return_status      => l_c_message );
	IF ( l_c_message <> 'SINGLE' ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;
	-- Derive uoo_id
	l_c_message := NULL;
	igs_ps_validate_lgcy_pkg.get_uoo_id ( p_unit_cd    => p_usec_wlst_rec.unit_cd,
					      p_ver_num    => p_usec_wlst_rec.version_number,
					      p_cal_type   => l_c_cal_type,
					      p_seq_num    => l_n_seq_num,
					      p_loc_cd     => p_usec_wlst_rec.location_cd,
					      p_unit_class => p_usec_wlst_rec.unit_class,
					      p_uoo_id     => l_n_uoo_id,
					      p_message    => l_c_message );
	IF ( l_c_message IS NOT NULL ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;
      END validate_derivations_pri;

      -- Check for Update
      FUNCTION check_insert_update ( p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type,p_n_wlst_usec_pri_id NUMBER) RETURN VARCHAR2 IS
        CURSOR c_usec_wlst_pri(cp_n_uoo_id NUMBER,cp_priority_value VARCHAR2) IS
        SELECT 'X'
	FROM   igs_ps_usec_wlst_pri
        WHERE  uoo_id = cp_n_uoo_id
        AND    priority_value = cp_priority_value;

        c_usec_wlst_pri_rec c_usec_wlst_pri%ROWTYPE;

      BEGIN
	OPEN c_usec_wlst_pri( l_n_uoo_id,p_usec_wlst_rec.priority_value);
	FETCH c_usec_wlst_pri INTO c_usec_wlst_pri_rec;
	IF c_usec_wlst_pri%NOTFOUND THEN
	  CLOSE c_usec_wlst_pri;
	  RETURN 'I';
	ELSE
	  CLOSE c_usec_wlst_pri;
	  RETURN 'U';
	END IF;

      END check_insert_update;

      PROCEDURE Assign_default(p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type,p_insert_update VARCHAR2 ) AS

        CURSOR c_usprv(cp_n_uoo_id NUMBER,cp_priority_value VARCHAR2) IS
	SELECT priority_number
	FROM   igs_ps_usec_wlst_pri
	WHERE  uoo_id = cp_n_uoo_id
	AND    priority_value    = cp_priority_value;

	rec_usprv  c_usprv%ROWTYPE;

      BEGIN
	IF p_insert_update = 'U' THEN
	   OPEN c_usprv( l_n_uoo_id,p_usec_wlst_rec.priority_value);
	   FETCH c_usprv INTO rec_usprv;
	   CLOSE c_usprv;

	   IF p_usec_wlst_rec.priority_number IS NULL  THEN
	      p_usec_wlst_rec.priority_number:= rec_usprv.priority_number;
           ELSIF p_usec_wlst_rec.priority_number = FND_API.G_MISS_NUM THEN
	      igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PRIORITY_NUMBER', 'LEGACY_TOKENS', FALSE);
              p_usec_wlst_rec.status := 'E';
	   END IF;

	 END IF;
      END Assign_default;

      -- Validate Database Constraints for Waitlist seating priority.
      PROCEDURE validate_db_cons_wlstpri ( p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type,p_insert_update VARCHAR2 ) AS
      BEGIN
	IF(p_insert_update = 'I') THEN
	  /* Unique Key Validation */
	  IF igs_ps_usec_wlst_pri_pkg.get_uk_for_validation ( x_priority_value =>p_usec_wlst_rec.priority_value,
							      x_uoo_id => l_n_uoo_id) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'USEC_WLST_PRI', 'LEGACY_TOKENS', FALSE);
	    p_usec_wlst_rec.status := 'W';
	    RETURN;
	  END IF;
	END IF;
	 /* Validate FK Constraints */

	IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;

	IF NOT igs_lookups_view_pkg.get_pk_for_validation('UNIT_WAITLIST', p_usec_wlst_rec.priority_value) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'PRIORITY_VALUE', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;
      END validate_db_cons_wlstpri;

    BEGIN

      IF p_usec_wlst_rec.status = 'S' THEN
         validate_parameters(p_usec_wlst_rec);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstpri.status_after_validate_parameters',
	    'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value||'  '||'Status:'
	    ||p_usec_wlst_rec.status);
          END IF;

      END IF;

      IF p_usec_wlst_rec.status = 'S' THEN
         validate_derivations_pri(p_usec_wlst_rec,l_insert_update);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstpri.status_after_validate_derivations_pri',
	    'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value||'  '||'Status:'
	    ||p_usec_wlst_rec.status);
          END IF;

      END IF;

      --Find out whether it is insert/update of record
      l_insert_update:='I';
      IF p_usec_wlst_rec.status = 'S' AND p_calling_context IN ('G','S') THEN
        l_insert_update:= check_insert_update(p_usec_wlst_rec,l_n_wlst_usec_pri_id);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstpri.status_after_check_insert_update',
	  'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value||'  '||'Status:'
	  ||p_usec_wlst_rec.status);
        END IF;

      END IF;

      IF p_usec_wlst_rec.status = 'S' AND p_calling_context ='S' THEN
        IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
          fnd_msg_pub.add;
          p_usec_wlst_rec.status := 'A';
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstpri.status_after_check_import_allowed',
	  'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value||'  '||'Status:'
	  ||p_usec_wlst_rec.status);
        END IF;

      END IF;

      IF p_usec_wlst_rec.status = 'S' THEN
	 Assign_default(p_usec_wlst_rec,l_insert_update);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstpri.status_after_Assign_default',
	   'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value||'  '||'Status:'
	   ||p_usec_wlst_rec.status);
         END IF;

      END IF;

      IF l_tbl_uoo.count = 0 THEN
         l_tbl_uoo(l_tbl_uoo.count+1) :=l_n_uoo_id;
      ELSE
	IF NOT igs_ps_validate_lgcy_pkg.isExists(l_n_uoo_id,l_tbl_uoo) THEN
	   l_tbl_uoo(l_tbl_uoo.count+1) :=l_n_uoo_id;
	END IF;
      END IF;

      IF p_usec_wlst_rec.status = 'S' THEN
        validate_db_cons_wlstpri(p_usec_wlst_rec,l_insert_update);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstpri.status_after_validate_db_cons_wlstpri',
	   'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value||'  '||'Status:'
	   ||p_usec_wlst_rec.status);
         END IF;

      END IF;

      IF p_usec_wlst_rec.status = 'S' THEN
        igs_ps_validate_generic_pkg.validate_usec_wlstpri (p_usec_wlst_rec,l_n_uoo_id,l_insert_update);
      END IF;

      IF p_usec_wlst_rec.status = 'S' THEN
	IF l_insert_update = 'I' THEN
           /* Insert Record */
           INSERT INTO igs_ps_usec_wlst_pri
           ( unit_sec_waitlist_priority_id,
            priority_number,
            priority_value,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
	    uoo_id
           )
	   VALUES
	   (
	    igs_ps_usec_wlst_pri_s.nextval,
	    p_usec_wlst_rec.priority_number,
	    p_usec_wlst_rec.priority_value,
	    g_n_user_id,
	    sysdate,
	    g_n_user_id,
	    sysdate,
	    g_n_login_id,
	    l_n_uoo_id
           );

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstpri.Record_Inserted',
	     'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value);
           END IF;

        ELSE --update
	   UPDATE igs_ps_usec_wlst_pri SET
           priority_number= p_usec_wlst_rec.priority_number,
           last_updated_by = g_n_user_id,
           last_update_date= SYSDATE ,
           last_update_login= g_n_login_id
	   WHERE uoo_id =l_n_uoo_id AND priority_value = p_usec_wlst_rec.priority_value;

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstpri.Record_updated',
	     'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value);
           END IF;

        END IF;
      END IF;

    END create_wlstpri;

    PROCEDURE create_wlstprf( p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type ) AS

      -- validate parameters passed waitlist Priority
      PROCEDURE validate_parameters( p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type ) AS
      BEGIN

	/* Check for Mandatory Parameters */
	IF p_usec_wlst_rec.preference_order IS NULL OR p_usec_wlst_rec.preference_order = FND_API.G_MISS_NUM THEN
	   igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PREFERENCE_ORDER', 'LEGACY_TOKENS', FALSE);
	   p_usec_wlst_rec.status := 'E';
	END IF;
	IF p_usec_wlst_rec.preference_code IS NULL OR p_usec_wlst_rec.preference_code = FND_API.G_MISS_CHAR THEN
	   igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PREFERENCE_CODE', 'LEGACY_TOKENS', FALSE);
	   p_usec_wlst_rec.status := 'E';
	END IF;

	IF p_usec_wlst_rec.priority_value IS NOT NULL AND p_usec_wlst_rec.priority_value IN ('PROGRAM','UNIT_SET') THEN
	  IF p_usec_wlst_rec.preference_version IS NULL OR p_usec_wlst_rec.preference_version = FND_API.G_MISS_NUM THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PREFERENCE_VERSION', 'LEGACY_TOKENS', FALSE);
	    p_usec_wlst_rec.status := 'E';
	  END IF;
	ELSIF p_usec_wlst_rec.priority_value IS NOT NULL AND p_usec_wlst_rec.priority_value NOT IN ('PROGRAM','UNIT_SET') THEN
	  IF p_usec_wlst_rec.preference_version IS NOT NULL THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'PREFERENCE_VERSION', 'LEGACY_TOKENS', FALSE);
	    p_usec_wlst_rec.status := 'E';
	  END IF;
	END IF;

      END validate_parameters ;


      -- Carry out derivations and validate them
      PROCEDURE validate_derivations_prf ( p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type,p_insert_update VARCHAR2 ) AS

	CURSOR c_pri_id(cp_uoo_id NUMBER, cp_priority_value igs_ps_usec_wlst_pri.priority_value%type) IS
	SELECT unit_sec_waitlist_priority_id
	FROM igs_ps_usec_wlst_pri
	WHERE uoo_id = cp_uoo_id
	AND priority_value = cp_priority_value;

      BEGIN
        OPEN c_pri_id(l_n_uoo_id,p_usec_wlst_rec.priority_value);
	FETCH c_pri_id INTO l_n_wlst_usec_pri_id;
	CLOSE c_pri_id;
      END validate_derivations_prf;


      FUNCTION check_insert_update ( p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type,p_n_wlst_usec_pri_id NUMBER) RETURN VARCHAR2 IS

        CURSOR c_usec_wlst_prf(cp_n_wlst_usec_pri_id NUMBER,cp_preference_code VARCHAR2) IS
        SELECT 'X'
	FROM   igs_ps_usec_wlst_prf
        WHERE  unit_sec_waitlist_priority_id = cp_n_wlst_usec_pri_id
        AND    preference_code = cp_preference_code;

        c_usec_wlst_prf_rec c_usec_wlst_prf%ROWTYPE;

        CURSOR c_usec_wlst_prf1(cp_n_wlst_usec_pri_id NUMBER,
                                cp_preference_code VARCHAR2,
  	 		        cp_preference_version VARCHAR2) IS
        SELECT 'X'
	FROM   igs_ps_usec_wlst_prf
        WHERE  unit_sec_waitlist_priority_id = cp_n_wlst_usec_pri_id
        AND    preference_code = cp_preference_code
        AND    preference_version = cp_preference_version;
        c_usec_wlst_prf1_rec c_usec_wlst_prf1%ROWTYPE;

      BEGIN
	IF p_usec_wlst_rec.priority_value IN ('PROGRAM', 'UNIT_SET') THEN
	  OPEN c_usec_wlst_prf1(l_n_wlst_usec_pri_id,p_usec_wlst_rec.preference_code,p_usec_wlst_rec.preference_version );
	  FETCH c_usec_wlst_prf1 INTO c_usec_wlst_prf1_rec;
	  IF c_usec_wlst_prf1%NOTFOUND THEN
	    CLOSE c_usec_wlst_prf1;
	    RETURN 'I';
	  ELSE
	    CLOSE c_usec_wlst_prf1;
	    RETURN 'U';
	  END IF;
	ELSE
	  OPEN c_usec_wlst_prf(l_n_wlst_usec_pri_id,p_usec_wlst_rec.preference_code );
	  FETCH c_usec_wlst_prf INTO c_usec_wlst_prf_rec;
	  IF c_usec_wlst_prf%NOTFOUND THEN
	    CLOSE c_usec_wlst_prf;
	    RETURN 'I';
	  ELSE
	    CLOSE c_usec_wlst_prf;
	    RETURN 'U';
	  END IF;
	END IF;
      END check_insert_update;


      -- Validate Database Constraints for waitlist preference.
      PROCEDURE validate_db_cons_wlstprf ( p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type,p_insert_update VARCHAR2 ) AS
      CURSOR cur_hzp(cp_preference_code VARCHAR2) IS
      SELECT 'x'
      FROM   hz_parties hp, igs_pe_hz_parties pe
      WHERE  hp.party_id = pe.party_id
      AND pe.oss_org_unit_cd =cp_preference_code;

      cur_hzp_rec cur_hzp%ROWTYPE;
      BEGIN

	IF(p_insert_update = 'I') THEN
	  /* Unique Key Validation */
	  IF igs_ps_usec_wlst_prf_pkg.get_uk_for_validation(x_preference_code =>p_usec_wlst_rec.preference_code,
							    x_preference_version=>p_usec_wlst_rec.preference_version,
							    x_unit_sec_wlst_priority_id =>l_n_wlst_usec_pri_id) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'USEC_WLST_PRF', 'LEGACY_TOKENS', FALSE);
	    p_usec_wlst_rec.status := 'W';

	    RETURN;
	  END IF;
	END IF;

	 /* Validate FK Constraints */
	IF (p_usec_wlst_rec.priority_value = 'PROGRAM') THEN
	  IF NOT igs_ps_ver_pkg.get_pk_for_validation (p_usec_wlst_rec.preference_code,p_usec_wlst_rec.preference_version  ) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_WLST_PRF', 'LEGACY_TOKENS', FALSE);
	    p_usec_wlst_rec.status := 'E';

	   END IF;
	END IF;

	IF (p_usec_wlst_rec.priority_value = 'UNIT_SET') THEN
	  IF NOT igs_en_unit_set_pkg.get_pk_for_validation (p_usec_wlst_rec.preference_code,p_usec_wlst_rec.preference_version) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_WLST_PRF', 'LEGACY_TOKENS', FALSE);
	    p_usec_wlst_rec.status := 'E';
	  END IF;
	END IF;

	IF (p_usec_wlst_rec.priority_value = 'CLASS_STD' ) THEN
	  IF NOT igs_pr_class_std_pkg.get_uk_for_validation (p_usec_wlst_rec.preference_code  ) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_WLST_PRF', 'LEGACY_TOKENS', FALSE);
	    p_usec_wlst_rec.status := 'E';
	  END IF;
	END IF;

	IF (p_usec_wlst_rec.priority_value = 'PROGRAM_STAGE') THEN
	  IF NOT igs_ps_stage_type_pkg.get_pk_for_validation (p_usec_wlst_rec.preference_code  ) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_WLST_PRF', 'LEGACY_TOKENS', FALSE);
	    p_usec_wlst_rec.status := 'E';
	  END IF;
	END IF;

	IF (p_usec_wlst_rec.priority_value = 'ORG_UNIT') THEN
	  OPEN  cur_hzp(p_usec_wlst_rec.preference_code );
	  FETCH cur_hzp INTO cur_hzp_rec;
	  IF cur_hzp%NOTFOUND THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_WLST_PRF', 'LEGACY_TOKENS', FALSE);
	    p_usec_wlst_rec.status := 'E';
	  END IF;
	  CLOSE cur_hzp;
	END IF;

      END validate_db_cons_wlstprf;

    BEGIN

      IF p_usec_wlst_rec.status = 'S' THEN
        validate_parameters(p_usec_wlst_rec);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstprf.status_after_validate_parameters',
	   'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value||'  '||
	   'Preference Code:'||p_usec_wlst_rec.preference_code||' '||'Status:'||p_usec_wlst_rec.status);
         END IF;

      END IF;

      IF p_usec_wlst_rec.status = 'S' THEN
        validate_derivations_prf(p_usec_wlst_rec,l_insert_update);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstprf.status_after_validate_derivations_prf',
	   'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value||'  '||
	   'Preference Code:'||p_usec_wlst_rec.preference_code||' '||'Status:'||p_usec_wlst_rec.status);
         END IF;

      END IF;

      --Find out whether it is insert/update of record
      l_insert_update:='I';
      IF p_usec_wlst_rec.status = 'S' AND p_calling_context IN ('G', 'S') THEN
        l_insert_update:= check_insert_update(p_usec_wlst_rec,l_n_wlst_usec_pri_id);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstprf.status_after_check_insert_update',
	   'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value||'  '||
	   'Preference Code:'||p_usec_wlst_rec.preference_code||' '||'Status:'||p_usec_wlst_rec.status);
        END IF;

      END IF;


      IF p_usec_wlst_rec.status = 'S' THEN
         validate_db_cons_wlstprf(p_usec_wlst_rec,l_insert_update);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstprf.status_after_validate_db_cons_wlstprf',
	   'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value||'  '||
	   'Preference Code:'||p_usec_wlst_rec.preference_code||' '||'Status:'||p_usec_wlst_rec.status);
         END IF;

      END IF;

      IF p_usec_wlst_rec.status = 'S' THEN
         igs_ps_validate_generic_pkg.validate_usec_wlstprf(p_usec_wlst_rec,l_insert_update);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstprf.status_after_Business_validation',
	   'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value||'  '||
	   'Preference Code:'||p_usec_wlst_rec.preference_code||' '||'Status:'||p_usec_wlst_rec.status);
         END IF;

      END IF;



      IF p_usec_wlst_rec.status = 'S' THEN
	IF l_insert_update = 'I' THEN
          /* Insert Record */
          INSERT INTO igs_ps_usec_wlst_prf
          ( unit_sec_waitlist_pref_id,
            unit_sec_waitlist_priority_id,
            preference_order,
            preference_code,
            preference_version,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login
          )
	  VALUES
	  (
            igs_ps_usec_wlst_prf_s.nextval,
            l_n_wlst_usec_pri_id,
            p_usec_wlst_rec.preference_order,
            p_usec_wlst_rec.preference_code,
	    p_usec_wlst_rec.preference_version,
            g_n_user_id,
            sysdate,
            g_n_user_id,
            sysdate,
            g_n_login_id
          );

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstprf.Record_Inserted',
	     'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value||'  '||
	     'Preference Code:'||p_usec_wlst_rec.preference_code);
           END IF;

        ELSE ---update
	  UPDATE igs_ps_usec_wlst_prf SET
          preference_order= p_usec_wlst_rec.preference_order,
          preference_version=p_usec_wlst_rec.preference_version,
          last_updated_by = g_n_user_id,
          last_update_date= SYSDATE ,
          last_update_login= g_n_login_id
	  WHERE unit_sec_waitlist_priority_id  =l_n_wlst_usec_pri_id AND preference_code = p_usec_wlst_rec.preference_code;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstprf.Record_Updated',
	     'Unit code:'||p_usec_wlst_rec.unit_cd||'  '||'Version number:'||p_usec_wlst_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_wlst_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_wlst_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_wlst_rec.unit_class||'  '||'Priority Value:'||p_usec_wlst_rec.priority_value||'  '||
	     'Preference Code:'||p_usec_wlst_rec.preference_code);
          END IF;

        END IF;
      END IF;

    END create_wlstprf;

  /* Main Unit Section waitlist Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.start_logging_for',
                    'Unit Section Waitlist ');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_usec_waitlist_tbl.LAST LOOP
      l_n_uoo_id:= NULL;
      l_n_wlst_usec_pri_id:=NULL;
      IF p_usec_waitlist_tbl.EXISTS(I) THEN
        p_usec_waitlist_tbl(I).status := 'S';
        p_usec_waitlist_tbl(I).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_usec_waitlist_tbl(I));

	--create reserved seating priority
	IF p_usec_waitlist_tbl(I).status = 'S' THEN

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstpri.call',
	    'Unit code:'||p_usec_waitlist_tbl(I).unit_cd||'  '||'Version number:'||p_usec_waitlist_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_waitlist_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_waitlist_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_waitlist_tbl(I).unit_class||'  '||'Priority Value:'||p_usec_waitlist_tbl(I).priority_value);
          END IF;

	  create_wlstpri(p_usec_waitlist_tbl(I));


          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstpri.status_after_creating_priority_record',
	    'Unit code:'||p_usec_waitlist_tbl(I).unit_cd||'  '||'Version number:'||p_usec_waitlist_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_waitlist_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_waitlist_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_waitlist_tbl(I).unit_class||'  '||'Priority Value:'||p_usec_waitlist_tbl(I).priority_value||'  '||'Status:'
	    ||p_usec_waitlist_tbl(I).status);
          END IF;

        END IF;

	-- Create reserved seating preference
        IF p_usec_waitlist_tbl(I).status = 'S' THEN
	  IF p_usec_waitlist_tbl(I).preference_code IS NOT NULL THEN

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstprf.call',
	      'Unit code:'||p_usec_waitlist_tbl(I).unit_cd||'  '||'Version number:'||p_usec_waitlist_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_waitlist_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_waitlist_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_waitlist_tbl(I).unit_class||'  '||'Priority Value:'||p_usec_waitlist_tbl(I).priority_value||' '||
	      'Preference Code:'||p_usec_waitlist_tbl(I).preference_code);
            END IF;

            create_wlstprf(p_usec_waitlist_tbl(I));

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.create_wlstprf.status_after_creating_prefenrence_record',
	      'Unit code:'||p_usec_waitlist_tbl(I).unit_cd||'  '||'Version number:'||p_usec_waitlist_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_waitlist_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_waitlist_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_waitlist_tbl(I).unit_class||'  '||'Priority Value:'||p_usec_waitlist_tbl(I).priority_value||'  '||
	      'Preference Code:'||p_usec_waitlist_tbl(I).preference_code||' '||'Status:'||p_usec_waitlist_tbl(I).status);
            END IF;

          END IF;
	END IF;

        IF p_usec_waitlist_tbl(I).status = 'S' THEN
           p_usec_waitlist_tbl(I).msg_from := NULL;
           p_usec_waitlist_tbl(I).msg_to := NULL;
        ELSIF  p_usec_waitlist_tbl(I).status = 'A' THEN
	   p_usec_waitlist_tbl(I).msg_from  := p_usec_waitlist_tbl(I).msg_from + 1;
	   p_usec_waitlist_tbl(I).msg_to := fnd_msg_pub.count_msg;
	ELSE
           p_c_rec_status :=  p_usec_waitlist_tbl(I).status;
           p_usec_waitlist_tbl(I).msg_from :=  p_usec_waitlist_tbl(I).msg_from + 1;
           p_usec_waitlist_tbl(I).msg_to := fnd_msg_pub.count_msg;
          IF p_c_rec_status = 'E' THEN
            RETURN;
          END IF;
        END IF;

      END IF;--exists
    END LOOP;

    /* Post Insert/Update Checks */
    IF NOT igs_ps_validate_generic_pkg.post_usec_wlst(p_usec_waitlist_tbl,l_tbl_uoo) THEN
      p_c_rec_status := 'E';
    END IF;
    l_tbl_uoo.DELETE;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_waitlist.after_import_status',p_c_rec_status);
    END IF;

  END create_usec_waitlist;


  --Unit Section Notes
  PROCEDURE create_usec_notes(
          p_usec_notes_tbl  IN OUT NOCOPY igs_ps_generic_pub.usec_notes_tbl_type,
          p_c_rec_status    OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2
  ) AS
  /***********************************************************************************************
    Created By     :  Sommukhe
    Date Created By: 17-Jun-2005
    Purpose        :  This procedure is a sub process to import records of Unit Section Notes.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
     l_insert_update      VARCHAR2(1);
     l_n_uoo_id           igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
     l_n_reference_number igs_ge_note.reference_number%TYPE;
     l_c_cal_type         igs_ps_unit_ofr_opt_all.cal_type%TYPE;
     l_n_seq_num          igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;

    /* Private Procedures for create_usec_notes */
    PROCEDURE trim_values ( p_usec_notes_rec IN OUT NOCOPY igs_ps_generic_pub.usec_notes_rec_type ) AS
    BEGIN
      p_usec_notes_rec.unit_cd := trim(p_usec_notes_rec.unit_cd);
      p_usec_notes_rec.version_number := trim(p_usec_notes_rec.version_number);
      p_usec_notes_rec.teach_cal_alternate_code := trim(p_usec_notes_rec.teach_cal_alternate_code);
      p_usec_notes_rec.location_cd := trim(p_usec_notes_rec.location_cd);
      p_usec_notes_rec.unit_class := trim(p_usec_notes_rec.unit_class);
      p_usec_notes_rec.reference_number := trim(p_usec_notes_rec.reference_number);
      p_usec_notes_rec.crs_note_type := trim(p_usec_notes_rec.crs_note_type);
      p_usec_notes_rec.note_text := trim(p_usec_notes_rec.note_text);

    END trim_values;

    -- validate parameters passed.
    PROCEDURE validate_parameters ( p_usec_notes_rec IN OUT NOCOPY igs_ps_generic_pub.usec_notes_rec_type ) AS
    BEGIN

      /* Check for Mandatory Parameters */
      IF p_usec_notes_rec.unit_cd IS NULL OR p_usec_notes_rec.unit_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_notes_rec.status := 'E';
      END IF;
      IF p_usec_notes_rec.version_number IS NULL OR p_usec_notes_rec.version_number = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
        p_usec_notes_rec.status := 'E';
      END IF;
      IF p_usec_notes_rec.teach_cal_alternate_code IS NULL OR p_usec_notes_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_notes_rec.status := 'E';
      END IF;
      IF p_usec_notes_rec.location_cd IS NULL  OR p_usec_notes_rec.location_cd= FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_notes_rec.status := 'E';
      END IF;
      IF p_usec_notes_rec.unit_class IS NULL OR p_usec_notes_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CLASS', 'LEGACY_TOKENS', FALSE);
        p_usec_notes_rec.status := 'E';
      END IF;
      IF p_usec_notes_rec.crs_note_type IS NULL  OR p_usec_notes_rec.crs_note_type = FND_API.G_MISS_CHAR  THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'CRS_NOTE_TYPE', 'LEGACY_TOKENS', FALSE);
        p_usec_notes_rec.status := 'E';
      END IF;

    END validate_parameters;


    -- Check for Update
    FUNCTION check_insert_update ( p_usec_notes_rec IN OUT NOCOPY igs_ps_generic_pub.usec_notes_rec_type ) RETURN VARCHAR2 IS

    BEGIN

      IF p_usec_notes_rec.reference_number IS NULL THEN
	RETURN 'I';
      ELSE
	RETURN 'U';
      END IF;
    END check_insert_update;

    -- Carry out derivations and validate them
    PROCEDURE validate_derivations ( p_usec_notes_rec IN OUT NOCOPY igs_ps_generic_pub.usec_notes_rec_type ) AS
      l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
      l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
      l_c_message  VARCHAR2(30);
    BEGIN


      -- Derive Calander Type and Sequence Number
      igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_usec_notes_rec.teach_cal_alternate_code,
                                             p_cal_type           => l_c_cal_type,
                                             p_ci_sequence_number => l_n_seq_num,
                                             p_start_dt           => l_d_start_dt,
                                             p_end_dt             => l_d_end_dt,
                                             p_return_status      => l_c_message );
      IF ( l_c_message <> 'SINGLE' ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_notes_rec.status := 'E';
      END IF;


      -- Derive uoo_id
      l_c_message := NULL;
      igs_ps_validate_lgcy_pkg.get_uoo_id ( p_unit_cd    => p_usec_notes_rec.unit_cd,
                                            p_ver_num    => p_usec_notes_rec.version_number,
                                            p_cal_type   => l_c_cal_type,
                                            p_seq_num    => l_n_seq_num,
                                            p_loc_cd     => p_usec_notes_rec.location_cd,
                                            p_unit_class => p_usec_notes_rec.unit_class,
                                            p_uoo_id     => l_n_uoo_id,
                                            p_message    => l_c_message );
      IF ( l_c_message IS NOT NULL ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_usec_notes_rec.status := 'E';
      END IF;


    END validate_derivations;

    -- Validate Database Constraints
    PROCEDURE validate_db_cons ( p_usec_notes_rec IN OUT NOCOPY igs_ps_generic_pub.usec_notes_rec_type,p_insert_update VARCHAR2 ) AS
      CURSOR cur_ref_num(cp_uoo_id igs_ps_unt_ofr_opt_n.uoo_id%TYPE,
                         cp_reference_number igs_ps_unt_ofr_opt_n.reference_number%TYPE) IS
      SELECT b.note_text
      FROM   igs_ps_unt_ofr_opt_n a,igs_ge_note b
      WHERE  a.uoo_id=cp_uoo_id
      AND    a.reference_number=cp_reference_number
      AND    a.reference_number=b.reference_number;
      l_cur_ref_num  cur_ref_num%ROWTYPE;

    BEGIN
      IF (p_insert_update = 'U') THEN

	/* While update check if the reference number belong to the passed unit section */
	OPEN cur_ref_num(l_n_uoo_id, p_usec_notes_rec.reference_number);
	FETCH cur_ref_num INTO l_cur_ref_num;
	IF cur_ref_num%NOTFOUND THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'REFERENCE_NUMBER', 'LEGACY_TOKENS', FALSE);
	  p_usec_notes_rec.status := 'E';
        ELSE
	  IF  p_usec_notes_rec.note_text = FND_API.G_MISS_CHAR THEN
	      p_usec_notes_rec.note_text :=NULL;
          ELSIF p_usec_notes_rec.note_text IS NULL THEN
	      p_usec_notes_rec.note_text :=l_cur_ref_num.note_text;
	  END IF;
        END IF;
        CLOSE cur_ref_num;

      END IF;


      /* Validate FK Constraints */
      IF NOT igs_ps_note_type_pkg.get_pk_for_validation ( p_usec_notes_rec.crs_note_type) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'CRS_NOTE_TYPE', 'LEGACY_TOKENS', FALSE);
        p_usec_notes_rec.status := 'E';
      END IF;

      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_usec_notes_rec.status := 'E';
      END IF;

    END validate_db_cons;

  /* Main Unit Section Notes Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_notes.start_logging_for',
                    'Unit Section Notes');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_usec_notes_tbl.LAST LOOP

      IF p_usec_notes_tbl.EXISTS(I) THEN
        l_n_uoo_id := NULL;
	l_c_cal_type  := NULL;
        l_n_seq_num   := NULL;
        p_usec_notes_tbl(I).status := 'S';
        p_usec_notes_tbl(I).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_usec_notes_tbl(I) );

        validate_parameters ( p_usec_notes_tbl(I) );

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_notes.status_after_validate_parameters',
	 'Unit code:'||p_usec_notes_tbl(I).unit_cd||'  '||'Version number:'||p_usec_notes_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_notes_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_notes_tbl(I).location_cd||'  '||'Unit Class:'||
	  p_usec_notes_tbl(I).unit_class||'  '||'Crs Note Type:'||p_usec_notes_tbl(I).crs_note_type||'  '||
	  'Status:'||p_usec_notes_tbl(I).status);
        END IF;

	IF p_usec_notes_tbl(I).status = 'S' THEN
          validate_derivations ( p_usec_notes_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_notes.status_after_validate_derivations',
	   'Unit code:'||p_usec_notes_tbl(I).unit_cd||'  '||'Version number:'||p_usec_notes_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_notes_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_notes_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_notes_tbl(I).unit_class||'  '||'Crs Note Type:'||p_usec_notes_tbl(I).crs_note_type||'  '||
	    'Status:'||p_usec_notes_tbl(I).status);
          END IF;

        END IF;

	--Find out whether it is insert/update of record
        l_insert_update:='I';
        IF p_usec_notes_tbl(I).status = 'S' AND p_calling_context IN ('G','S') THEN
            l_insert_update:= check_insert_update(p_usec_notes_tbl(I));

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_notes.status_check_insert_update',
	     'Unit code:'||p_usec_notes_tbl(I).unit_cd||'  '||'Version number:'||p_usec_notes_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_notes_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_notes_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_notes_tbl(I).unit_class||'  '||'Crs Note Type:'||p_usec_notes_tbl(I).crs_note_type||'  '||
	      'Status:'||p_usec_notes_tbl(I).status);
            END IF;

        END IF;

	-- Find out whether record can go for import in context of cancelled/aborted
	IF  p_usec_notes_tbl(I).status = 'S' AND p_calling_context = 'S' THEN
	  IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	    fnd_msg_pub.add;
	    p_usec_notes_tbl(I).status := 'A';
	  END IF;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_notes.status_after_check_import_allowed',
	   'Unit code:'||p_usec_notes_tbl(I).unit_cd||'  '||'Version number:'||p_usec_notes_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_notes_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_notes_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_notes_tbl(I).unit_class||'  '||'Crs Note Type:'||p_usec_notes_tbl(I).crs_note_type||'  '||
	    'Status:'||p_usec_notes_tbl(I).status);
          END IF;

	END IF;

	IF p_usec_notes_tbl(I).status = 'S' THEN
          validate_db_cons ( p_usec_notes_tbl(I),l_insert_update );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_notes.status_after_validate_db_cons',
	   'Unit code:'||p_usec_notes_tbl(I).unit_cd||'  '||'Version number:'||p_usec_notes_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_notes_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_notes_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_notes_tbl(I).unit_class||'  '||'Crs Note Type:'||p_usec_notes_tbl(I).crs_note_type||'  '||
	    'Status:'||p_usec_notes_tbl(I).status);
          END IF;

        END IF;

	/* Business Validations */
        /* Proceed with business validations only if the status is Success, 'S' */
        IF p_usec_notes_tbl(I).status = 'S' THEN
          igs_ps_validate_generic_pkg.validate_usec_notes ( p_usec_notes_tbl(I),l_n_uoo_id );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_notes.status_after_validate_usec_notes',
	   'Unit code:'||p_usec_notes_tbl(I).unit_cd||'  '||'Version number:'||p_usec_notes_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_notes_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_notes_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_notes_tbl(I).unit_class||'  '||'Crs Note Type:'||p_usec_notes_tbl(I).crs_note_type||'  '||
	    'Status:'||p_usec_notes_tbl(I).status);
          END IF;

        END IF;

        IF p_usec_notes_tbl(I).status = 'S'  THEN
	  IF l_insert_update = 'I' THEN
             /* Insert Record */
             INSERT INTO IGS_GE_NOTE
             (reference_number,
              s_note_format_type,
              note_text,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login
             )
             VALUES
             (IGS_GE_NOTE_RF_NUM_S.nextval,
	     'TEXT',
             p_usec_notes_tbl(I).note_text,
             g_n_user_id,
             SYSDATE,
             g_n_user_id,
             SYSDATE,
             g_n_login_id
             )RETURNING reference_number INTO l_n_reference_number;

             INSERT INTO igs_ps_unt_ofr_opt_n
             (unit_cd,
             version_number,
             cal_type,
             ci_sequence_number,
             location_cd,
             unit_class,
             reference_number,
             uoo_id,
             crs_note_type,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login
             )
             VALUES
             (p_usec_notes_tbl(I).unit_cd,
	     p_usec_notes_tbl(I).version_number,
             l_c_cal_type,
             l_n_seq_num,
	     p_usec_notes_tbl(I).location_cd,
	     p_usec_notes_tbl(I).unit_class,
             l_n_reference_number,
	     l_n_uoo_id,
             p_usec_notes_tbl(I).crs_note_type,
             g_n_user_id,
             SYSDATE,
             g_n_user_id,
             SYSDATE,
             g_n_login_id
             );

	     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	       fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_notes.Record_Inserted',
	      'Unit code:'||p_usec_notes_tbl(I).unit_cd||'  '||'Version number:'||p_usec_notes_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	       ||p_usec_notes_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_notes_tbl(I).location_cd||'  '||'Unit Class:'||
	       p_usec_notes_tbl(I).unit_class||'  '||'Crs Note Type:'||p_usec_notes_tbl(I).crs_note_type);
             END IF;

         ELSE
	      /*Update record*/
              UPDATE igs_ps_unt_ofr_opt_n
	      SET crs_note_type = p_usec_notes_tbl(I).crs_note_type,
	      last_updated_by = g_n_user_id,
	      last_update_date = SYSDATE,
	      last_update_login = g_n_login_id
	      WHERE reference_number = p_usec_notes_tbl(I).reference_number;

              UPDATE igs_ge_note
	      SET note_text = p_usec_notes_tbl(I).note_text,
	      last_updated_by = g_n_user_id,
	      last_update_date = SYSDATE,
	      last_update_login = g_n_login_id
	      WHERE reference_number = p_usec_notes_tbl(I).reference_number;

              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	        fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_notes.Record_updated',
	       'Unit code:'||p_usec_notes_tbl(I).unit_cd||'  '||'Version number:'||p_usec_notes_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	        ||p_usec_notes_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_notes_tbl(I).location_cd||'  '||'Unit Class:'||
	        p_usec_notes_tbl(I).unit_class||'  '||'Crs Note Type:'||p_usec_notes_tbl(I).crs_note_type);
              END IF;

	 END IF;
       END IF;--insert/update

       IF  p_usec_notes_tbl(I).status = 'S' THEN
	 p_usec_notes_tbl(I).msg_from := NULL;
	 p_usec_notes_tbl(I).msg_to := NULL;
       ELSIF   p_usec_notes_tbl(I).status = 'A' THEN
	 p_usec_notes_tbl(I).msg_from  :=  p_usec_notes_tbl(I).msg_from + 1;
	 p_usec_notes_tbl(I).msg_to := fnd_msg_pub.count_msg;
       ELSE
	 p_c_rec_status := p_usec_notes_tbl(I).status;
	 p_usec_notes_tbl(I).msg_from := p_usec_notes_tbl(I).msg_from+1;
	 p_usec_notes_tbl(I).msg_to := fnd_msg_pub.count_msg;
	 IF p_usec_notes_tbl(I).status = 'E' THEN
	   RETURN;
	 END IF;
       END IF;

     END IF;--exists
   END LOOP;

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_notes.after_import_status',p_c_rec_status);
   END IF;

 END create_usec_notes;

 ---Unit section assesment
 PROCEDURE create_usec_assmnt(
          p_usec_assmnt_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_assmnt_tbl_type,
          p_c_rec_status    OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2
  )AS

  /***********************************************************************************************
    Created By     :  Sommukhe
    Date Created By: 17-Jun-2005
    Purpose        :  This procedure is a sub process to import records of Unit Section Assessment(Exam).

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ***********************************************************************************************/
     l_insert_update      VARCHAR2(1);
     l_n_uoo_id           igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
     l_n_building_id      NUMBER;
     l_n_room_id          NUMBER;
     l_d_exam_start_time  igs_ps_usec_as.exam_start_time%TYPE;
     l_d_exam_end_time	  igs_ps_usec_as.exam_end_time%TYPE;

    /* Private Procedures for create_usec_assmnt */
    PROCEDURE trim_values ( p_usec_assmnt_rec IN OUT NOCOPY igs_ps_generic_pub.usec_assmnt_rec_type ) AS
    BEGIN

      p_usec_assmnt_rec.unit_cd := trim(p_usec_assmnt_rec.unit_cd);
      p_usec_assmnt_rec.version_number := trim(p_usec_assmnt_rec.version_number);
      p_usec_assmnt_rec.teach_cal_alternate_code := trim(p_usec_assmnt_rec.teach_cal_alternate_code);
      p_usec_assmnt_rec.location_cd := trim(p_usec_assmnt_rec.location_cd);
      p_usec_assmnt_rec.unit_class := trim(p_usec_assmnt_rec.unit_class);
      p_usec_assmnt_rec.final_exam_date := TRUNC(p_usec_assmnt_rec.final_exam_date);
      p_usec_assmnt_rec.exam_start_time := trim(p_usec_assmnt_rec.exam_start_time);
      p_usec_assmnt_rec.exam_end_time := trim(p_usec_assmnt_rec.exam_end_time);
      p_usec_assmnt_rec.exam_location_cd := trim(p_usec_assmnt_rec.exam_location_cd);
      p_usec_assmnt_rec.building_code := trim(p_usec_assmnt_rec.building_code);
      p_usec_assmnt_rec.room_code := trim(p_usec_assmnt_rec.room_code);

    END trim_values;

    -- validate parameters passed.
    PROCEDURE validate_parameters ( p_usec_assmnt_rec IN OUT NOCOPY igs_ps_generic_pub.usec_assmnt_rec_type ) AS
    BEGIN

      /* Check for Mandatory Parameters */
      IF p_usec_assmnt_rec.unit_cd IS NULL OR p_usec_assmnt_rec.unit_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_assmnt_rec.status := 'E';
      END IF;
      IF p_usec_assmnt_rec.version_number IS NULL OR p_usec_assmnt_rec.version_number = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
        p_usec_assmnt_rec.status := 'E';
      END IF;
      IF p_usec_assmnt_rec.teach_cal_alternate_code IS NULL OR p_usec_assmnt_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_assmnt_rec.status := 'E';
      END IF;
      IF p_usec_assmnt_rec.location_cd IS NULL  OR p_usec_assmnt_rec.location_cd= FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_assmnt_rec.status := 'E';
      END IF;
      IF p_usec_assmnt_rec.unit_class IS NULL OR p_usec_assmnt_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CLASS', 'LEGACY_TOKENS', FALSE);
        p_usec_assmnt_rec.status := 'E';
      END IF;
      IF p_usec_assmnt_rec.final_exam_date IS NULL  OR p_usec_assmnt_rec.final_exam_date = FND_API.G_MISS_DATE  THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'FINAL_EXAM_DATE', 'LEGACY_TOKENS', FALSE);
        p_usec_assmnt_rec.status := 'E';
      END IF;
      IF p_usec_assmnt_rec.exam_start_time IS NULL  OR p_usec_assmnt_rec.exam_start_time = FND_API.G_MISS_CHAR  THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'EXAM_START_TIME', 'LEGACY_TOKENS', FALSE);
        p_usec_assmnt_rec.status := 'E';
      END IF;
      IF p_usec_assmnt_rec.exam_end_time IS NULL  OR p_usec_assmnt_rec.exam_end_time = FND_API.G_MISS_CHAR  THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'EXAM_END_TIME', 'LEGACY_TOKENS', FALSE);
        p_usec_assmnt_rec.status := 'E';
      END IF;
      IF p_usec_assmnt_rec.exam_location_cd IS NULL  OR p_usec_assmnt_rec.exam_location_cd = FND_API.G_MISS_CHAR  THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'EXAM_LOCATION_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_assmnt_rec.status := 'E';
      END IF;

    END validate_parameters;


    -- Check for Update
    FUNCTION check_insert_update ( p_usec_assmnt_rec IN OUT NOCOPY igs_ps_generic_pub.usec_assmnt_rec_type ) RETURN VARCHAR2 IS
    CURSOR c_usec_as(cp_n_uoo_id NUMBER) IS
    SELECT 'X'
    FROM igs_ps_usec_as
    WHERE uoo_id = cp_n_uoo_id;

    c_usec_as_rec c_usec_as%ROWTYPE;
    BEGIN
      OPEN c_usec_as(l_n_uoo_id);
      FETCH c_usec_as INTO c_usec_as_rec;
      IF c_usec_as%NOTFOUND THEN
        CLOSE c_usec_as;
        RETURN 'I';
      ELSE
        CLOSE c_usec_as;
        RETURN 'U';
      END IF;
    END check_insert_update;

    -- Carry out derivations and validate them
    PROCEDURE validate_derivations ( p_usec_assmnt_rec IN OUT NOCOPY igs_ps_generic_pub.usec_assmnt_rec_type ) AS

      CURSOR c_bld_id ( cp_building_cd igs_ad_building_all.building_cd%TYPE,
			cp_location_cd igs_ad_building_all.location_cd%TYPE ) IS
      SELECT building_id
      FROM   igs_ad_building_all
      WHERE  building_cd = cp_building_cd
      AND    location_cd = cp_location_cd;

      CURSOR c_room_id ( cp_building_id igs_ad_building_all.building_id%TYPE,
			 cp_room_cd igs_ad_room_all.room_cd%TYPE ) IS
      SELECT room_id
      FROM   igs_ad_room_all
      WHERE  room_cd = cp_room_cd
      AND    building_id = cp_building_id;


      l_c_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE;
      l_n_seq_num  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;
      l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
      l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
      l_c_message  VARCHAR2(30);
    BEGIN


      -- Derive Calander Type and Sequence Number
      igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_usec_assmnt_rec.teach_cal_alternate_code,
                                             p_cal_type           => l_c_cal_type,
                                             p_ci_sequence_number => l_n_seq_num,
                                             p_start_dt           => l_d_start_dt,
                                             p_end_dt             => l_d_end_dt,
                                             p_return_status      => l_c_message );
      IF ( l_c_message <> 'SINGLE' ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_assmnt_rec.status := 'E';
      END IF;


      -- Derive uoo_id
      l_c_message := NULL;
      igs_ps_validate_lgcy_pkg.get_uoo_id ( p_unit_cd    => p_usec_assmnt_rec.unit_cd,
                                            p_ver_num    => p_usec_assmnt_rec.version_number,
                                            p_cal_type   => l_c_cal_type,
                                            p_seq_num    => l_n_seq_num,
                                            p_loc_cd     => p_usec_assmnt_rec.location_cd,
                                            p_unit_class => p_usec_assmnt_rec.unit_class,
                                            p_uoo_id     => l_n_uoo_id,
                                            p_message    => l_c_message );
      IF ( l_c_message IS NOT NULL ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_usec_assmnt_rec.status := 'E';
      END IF;


      -- Derive Building Identifier and associated Room Identifier.
      IF p_usec_assmnt_rec.building_code IS NOT NULL AND p_usec_assmnt_rec.building_code <> FND_API.G_MISS_CHAR THEN
        OPEN c_bld_id ( p_usec_assmnt_rec.building_code, p_usec_assmnt_rec.exam_location_cd );
        FETCH c_bld_id INTO l_n_building_id;
        IF ( c_bld_id%NOTFOUND ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'BUILDING_CODE', 'LEGACY_TOKENS', FALSE);
           p_usec_assmnt_rec.status := 'E';
        END IF;
        CLOSE c_bld_id;

        -- Derive Room Identifier
        IF p_usec_assmnt_rec.room_code IS NOT NULL AND p_usec_assmnt_rec.room_code <> FND_API.G_MISS_CHAR THEN
          OPEN c_room_id ( l_n_building_id, p_usec_assmnt_rec.room_code );
          FETCH c_room_id INTO l_n_room_id;
          IF ( c_room_id%NOTFOUND ) THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'ROOM_CODE', 'LEGACY_TOKENS', FALSE);
            p_usec_assmnt_rec.status := 'E';
          END IF;
          CLOSE c_room_id;
        END IF;
      END IF;


      --validate/derive date fields with time comp
      -- exam_sart_time in proper format

      BEGIN
        IF (p_usec_assmnt_rec.exam_start_time IS NOT NULL) THEN
          l_d_exam_start_time:= TO_DATE ('1900/01/01'||p_usec_assmnt_rec.exam_start_time, 'YYYY/MM/DD HH24:MI');
	  p_usec_assmnt_rec.exam_start_time := TO_CHAR(l_d_exam_start_time,'HH24:MI');
        END IF;
     EXCEPTION
     WHEN OTHERS THEN
        FND_MESSAGE.set_name ('IGS','IGS_GE_INVALID_DATE_FORMAT');
        fnd_msg_pub.add;
        p_usec_assmnt_rec.status := 'E';
     END;

     --exam end time in proper format
     BEGIN
       IF (p_usec_assmnt_rec.exam_end_time IS NOT NULL) THEN
          l_d_exam_end_time:= TO_DATE ('1900/01/01'||p_usec_assmnt_rec.exam_end_time, 'YYYY/MM/DD HH24:MI');
         p_usec_assmnt_rec.exam_end_time := TO_CHAR(l_d_exam_end_time,'HH24:MI');

       END IF;
     EXCEPTION
     WHEN OTHERS THEN
        FND_MESSAGE.set_name ('IGS','IGS_GE_INVALID_DATE_FORMAT');
        fnd_msg_pub.add;
        p_usec_assmnt_rec.status := 'E';
     END;

    END validate_derivations;


    PROCEDURE assign_defaults ( p_usec_assmnt_rec IN OUT NOCOPY igs_ps_generic_pub.usec_assmnt_rec_type, p_insert IN VARCHAR2) IS
     CURSOR cur_usec_exam ( cp_uoo_id IN NUMBER) IS
     SELECT *
     FROM   igs_ps_usec_as
     WHERE  uoo_id = cp_uoo_id;
     l_cur_usec_exam cur_usec_exam%ROWTYPE;

     CURSOR cur_room (cp_building_id IN NUMBER, cp_room_cd IN VARCHAR2) IS
     SELECT room_id
     FROM   igs_ad_room
     WHERE  room_cd=cp_room_cd
     AND    building_id=cp_building_id;

    BEGIN

      IF p_insert = 'U' THEN

        OPEN cur_usec_exam(l_n_uoo_id);
	FETCH cur_usec_exam INTO l_cur_usec_exam;
	CLOSE cur_usec_exam;

	IF p_usec_assmnt_rec.building_code IS NULL THEN
	  l_n_building_id := l_cur_usec_exam.building_code;
        ELSIF  p_usec_assmnt_rec.building_code = FND_API.G_MISS_CHAR THEN
	  l_n_building_id := NULL;
	END IF;

	IF p_usec_assmnt_rec.room_code IS NULL THEN
	   l_n_room_id := l_cur_usec_exam.room_code;
        ELSIF  p_usec_assmnt_rec.room_code = FND_API.G_MISS_CHAR THEN
	  l_n_room_id := NULL;
        ELSIF p_usec_assmnt_rec.room_code IS NOT NULL THEN
          OPEN cur_room(l_n_building_id,p_usec_assmnt_rec.room_code);
	  FETCH cur_room INTO l_n_room_id;
	  IF cur_room%NOTFOUND THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'ROOM_CODE', 'LEGACY_TOKENS', FALSE);
            p_usec_assmnt_rec.status := 'E';
	  END IF;
          CLOSE cur_room;
	END IF;

      END IF;

    END assign_defaults;

    -- Validate Database Constraints
    PROCEDURE validate_db_cons ( p_usec_assmnt_rec IN OUT NOCOPY igs_ps_generic_pub.usec_assmnt_rec_type,p_insert_update VARCHAR2 ) AS
    CURSOR c_loc_cd(cp_location_cd igs_ad_location_all.location_cd%TYPE) IS
    SELECT 'X'
    FROM   igs_ad_location_all
    WHERE  location_cd = cp_location_cd
    AND    closed_ind = 'N';

    c_loc_cd_rec c_loc_cd%ROWTYPE;

    BEGIN
      IF (p_insert_update = 'I') THEN
	/* Unique Key Validation */
	IF igs_ps_usec_as_pkg.get_uk_for_validation (x_building_code =>l_n_building_id,
						     x_final_exam_date =>p_usec_assmnt_rec.final_exam_date,
						     x_location_cd =>p_usec_assmnt_rec.exam_location_cd,
						     x_room_code =>l_n_room_id,
						     x_uoo_id =>l_n_uoo_id) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'USEC_ASSMNT', 'LEGACY_TOKENS', FALSE);
	  p_usec_assmnt_rec.status := 'W';
	  RETURN;
	END IF;
      END IF;


      /* Validate FK Constraints */
      OPEN c_loc_cd(p_usec_assmnt_rec.exam_location_cd);
      FETCH c_loc_cd INTO c_loc_cd_rec;
      IF c_loc_cd%NOTFOUND THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'EXAM_LOCATION_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_assmnt_rec.status := 'E';
      END IF;
      CLOSE c_loc_cd;


      -- Check for the existence of Buildings
      IF  l_n_building_id IS NOT NULL THEN
        IF NOT igs_ad_building_pkg.get_pk_for_validation ( l_n_building_id ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'BUILDING_CODE', 'LEGACY_TOKENS', FALSE);
          p_usec_assmnt_rec.status := 'E';
        END IF;
      END IF;

      -- Check for the existence of Rooms
      IF l_n_room_id IS NOT NULL THEN
        IF NOT igs_ad_room_pkg.get_pk_for_validation ( l_n_room_id ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'ROOM_CODE', 'LEGACY_TOKENS', FALSE);
          p_usec_assmnt_rec.status := 'E';
        END IF;
      END IF;


      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_usec_assmnt_rec.status := 'E';
      END IF;

    END validate_db_cons;

  /* Main Unit Section Assessment Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_assmnt.start_logging_for',
                    'Unit Section Assessment');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_usec_assmnt_tbl.LAST LOOP


      IF p_usec_assmnt_tbl.EXISTS(I) THEN
        l_n_uoo_id := NULL;
	l_d_exam_start_time:=NULL;
        l_d_exam_end_time :=NULL;
	l_n_building_id :=NULL;
        l_n_room_id  :=NULL;
	p_usec_assmnt_tbl(I).status := 'S';
        p_usec_assmnt_tbl(I).msg_from := fnd_msg_pub.count_msg;
	trim_values(p_usec_assmnt_tbl(I) );

        validate_parameters ( p_usec_assmnt_tbl(I) );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_assmnt.status_after_validate_parameters',
	 'Unit code:'||p_usec_assmnt_tbl(I).unit_cd||'  '||'Version number:'||p_usec_assmnt_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_assmnt_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_assmnt_tbl(I).location_cd||'  '||'Unit Class:'||
	  p_usec_assmnt_tbl(I).unit_class||'  '||'Status:'||p_usec_assmnt_tbl(I).status);
        END IF;

	IF p_usec_assmnt_tbl(I).status = 'S' THEN
          validate_derivations ( p_usec_assmnt_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_assmnt.status_after_validate_derivations',
	   'Unit code:'||p_usec_assmnt_tbl(I).unit_cd||'  '||'Version number:'||p_usec_assmnt_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_assmnt_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_assmnt_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_assmnt_tbl(I).unit_class||'  '||'Status:'||p_usec_assmnt_tbl(I).status);
          END IF;

        END IF;

	--Find out whether it is insert/update of record
        l_insert_update:='I';
        IF p_usec_assmnt_tbl(I).status = 'S' AND p_calling_context IN ('G','S') THEN
           l_insert_update:= check_insert_update(p_usec_assmnt_tbl(I));

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_assmnt.status_after_check_insert_update',
	     'Unit code:'||p_usec_assmnt_tbl(I).unit_cd||'  '||'Version number:'||p_usec_assmnt_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_assmnt_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_assmnt_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_assmnt_tbl(I).unit_class||'  '||'Status:'||p_usec_assmnt_tbl(I).status);
           END IF;

        END IF;

	-- Find out whether record can go for import in context of cancelled/aborted
	IF  p_usec_assmnt_tbl(I).status = 'S' AND p_calling_context = 'S' THEN
	  IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	    fnd_msg_pub.add;
	    p_usec_assmnt_tbl(I).status := 'A';
	  END IF;

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_assmnt.status_after_check_import_allowed',
	     'Unit code:'||p_usec_assmnt_tbl(I).unit_cd||'  '||'Version number:'||p_usec_assmnt_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_assmnt_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_assmnt_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_assmnt_tbl(I).unit_class||'  '||'Status:'||p_usec_assmnt_tbl(I).status);
           END IF;

	END IF;

        --Defaulting depending upon insert or update
	IF p_usec_assmnt_tbl(I).status = 'S' THEN
	  assign_defaults(p_usec_assmnt_tbl(I),l_insert_update);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_assmnt.status_after_assign_defaults',
	   'Unit code:'||p_usec_assmnt_tbl(I).unit_cd||'  '||'Version number:'||p_usec_assmnt_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_assmnt_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_assmnt_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_assmnt_tbl(I).unit_class||'  '||'Status:'||p_usec_assmnt_tbl(I).status);
          END IF;

	END IF;

	IF p_usec_assmnt_tbl(I).status = 'S' THEN
          validate_db_cons ( p_usec_assmnt_tbl(I),l_insert_update );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_assmnt.status_after_validate_db_cons',
	   'Unit code:'||p_usec_assmnt_tbl(I).unit_cd||'  '||'Version number:'||p_usec_assmnt_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_assmnt_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_assmnt_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_assmnt_tbl(I).unit_class||'  '||'Status:'||p_usec_assmnt_tbl(I).status);
          END IF;

        END IF;

        /* Business Validations */
        /* Proceed with business validations only if the status is Success, 'S' */
        IF p_usec_assmnt_tbl(I).status = 'S' THEN
          igs_ps_validate_generic_pkg.validate_usec_assmnt ( p_usec_assmnt_tbl(I),l_n_uoo_id,l_d_exam_start_time,l_d_exam_end_time,l_n_building_id,l_n_room_id,l_insert_update);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_assmnt.status_after_Business_validation',
	   'Unit code:'||p_usec_assmnt_tbl(I).unit_cd||'  '||'Version number:'||p_usec_assmnt_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_assmnt_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_assmnt_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_assmnt_tbl(I).unit_class||'  '||'Status:'||p_usec_assmnt_tbl(I).status);
          END IF;

        END IF;

        IF p_usec_assmnt_tbl(I).status = 'S'  THEN
	  IF l_insert_update = 'I' THEN
             /* Insert Record */

             INSERT INTO igs_ps_usec_as
             (unit_section_assessment_id,
             uoo_id,
             final_exam_date,
             exam_start_time,
             exam_end_time,
             location_cd,
             building_code,
             room_code,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login
             )
             VALUES
             (igs_ps_usec_as_s.nextval,
	     l_n_uoo_id,
	     p_usec_assmnt_tbl(I).final_exam_date,
	     l_d_exam_start_time,--p_usec_assmnt_tbl(I).final_exam_date,
	     l_d_exam_end_time,--p_usec_assmnt_tbl(I).exam_start_time,
             p_usec_assmnt_tbl(I).exam_location_cd,
	     l_n_building_id,
	     l_n_room_id,
             g_n_user_id,
             SYSDATE,
             g_n_user_id,
             SYSDATE,
             g_n_login_id
             );

              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_assmnt.Record_inserted',
	       'Unit code:'||p_usec_assmnt_tbl(I).unit_cd||'  '||'Version number:'||p_usec_assmnt_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		||p_usec_assmnt_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_assmnt_tbl(I).location_cd||'  '||'Unit Class:'||
		p_usec_assmnt_tbl(I).unit_class);
              END IF;


         ELSE

	      /*Update record*/
              UPDATE igs_ps_usec_as
	      SET final_exam_date = p_usec_assmnt_tbl(I).final_exam_date,
	      exam_start_time=l_d_exam_start_time,--p_usec_assmnt_tbl(I).exam_start_time,
	      exam_end_time=l_d_exam_end_time,--p_usec_assmnt_tbl(I).exam_end_time,
	      location_cd=p_usec_assmnt_tbl(I).exam_location_cd,
	      building_code=l_n_building_id,
	      room_code=l_n_room_id,
	      last_updated_by = g_n_user_id,
	      last_update_date = SYSDATE,
              last_update_login = g_n_login_id
	      WHERE uoo_id = l_n_uoo_id;

	      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_assmnt.Record_updated',
	       'Unit code:'||p_usec_assmnt_tbl(I).unit_cd||'  '||'Version number:'||p_usec_assmnt_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		||p_usec_assmnt_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_assmnt_tbl(I).location_cd||'  '||'Unit Class:'||
		p_usec_assmnt_tbl(I).unit_class);
              END IF;
	 END IF;
       END IF;--insert/update

       IF  p_usec_assmnt_tbl(I).status = 'S' THEN
	 p_usec_assmnt_tbl(I).msg_from := NULL;
	 p_usec_assmnt_tbl(I).msg_to := NULL;
       ELSIF   p_usec_assmnt_tbl(I).status = 'A' THEN
	 p_usec_assmnt_tbl(I).msg_from  :=  p_usec_assmnt_tbl(I).msg_from + 1;
	 p_usec_assmnt_tbl(I).msg_to := fnd_msg_pub.count_msg;
       ELSE
	 p_c_rec_status := p_usec_assmnt_tbl(I).status;
	 p_usec_assmnt_tbl(I).msg_from := p_usec_assmnt_tbl(I).msg_from+1;
	 p_usec_assmnt_tbl(I).msg_to := fnd_msg_pub.count_msg;
	 IF p_usec_assmnt_tbl(I).status = 'E' THEN
	   RETURN;
	 END IF;
       END IF;
     END IF;--exists
   END LOOP;

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_assmnt.after_import_status',p_c_rec_status);
   END IF;


 END create_usec_assmnt;


PROCEDURE create_uso_ins_ovrd(p_tab_uso_ins IN OUT NOCOPY igs_ps_generic_pub.uso_ins_tbl_type
                              ,p_c_rec_status OUT NOCOPY VARCHAR2
			      ,p_calling_context IN VARCHAR2) IS
    /***********************************************************************************************

    Created By:         sarakshi
    Date Created By:    31-May-2005
    Purpose:            This procedure imports(override) unit section occurrence instructor.

    Known limitations,enhancements,remarks:
    Change History
    Who       When         What
    ***********************************************************************************************/

    l_n_ins_id            igs_ps_uso_instrctrs.instructor_id%TYPE;
    l_n_uso_id            igs_ps_uso_instrctrs.unit_section_occurrence_id%TYPE;
    l_n_uoo_id            igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_d_start_dt          igs_ps_usec_occurs_all.start_date%TYPE;
    l_d_end_dt            igs_ps_usec_occurs_all.end_date%TYPE;
    l_insert_status       BOOLEAN;
    l_delete_status       BOOLEAN;
    l_message_name        VARCHAR2(30);

    PROCEDURE trim_values ( p_uso_ins_rec IN OUT NOCOPY igs_ps_generic_pub.uso_ins_rec_type) AS
    BEGIN
      p_uso_ins_rec.instructor_person_number := TRIM(p_uso_ins_rec.instructor_person_number);
      p_uso_ins_rec.production_uso_id := TRIM(p_uso_ins_rec.production_uso_id);
      p_uso_ins_rec.unit_cd := TRIM(p_uso_ins_rec.unit_cd);
      p_uso_ins_rec.version_number := TRIM(p_uso_ins_rec.version_number);
      p_uso_ins_rec.teach_cal_alternate_code := TRIM(p_uso_ins_rec.teach_cal_alternate_code);
      p_uso_ins_rec.location_cd := TRIM(p_uso_ins_rec.location_cd);
      p_uso_ins_rec.unit_class := TRIM(p_uso_ins_rec.unit_class);
      p_uso_ins_rec.occurrence_identifier := TRIM(p_uso_ins_rec.occurrence_identifier);
      p_uso_ins_rec.confirmed_flag := TRIM(p_uso_ins_rec.confirmed_flag);
      p_uso_ins_rec.wl_percentage_allocation := TRIM(p_uso_ins_rec.wl_percentage_allocation);
      p_uso_ins_rec.instructional_load_lecture := TRIM(p_uso_ins_rec.instructional_load_lecture);
      p_uso_ins_rec.instructional_load_laboratory :=  TRIM(p_uso_ins_rec.instructional_load_laboratory);
      p_uso_ins_rec.instructional_load_other :=  TRIM(p_uso_ins_rec.instructional_load_other);
      p_uso_ins_rec.lead_instructor_flag := TRIM(p_uso_ins_rec.lead_instructor_flag);

    END trim_values;

    PROCEDURE validate_parameters(p_uso_ins_rec IN OUT NOCOPY igs_ps_generic_pub.uso_ins_rec_type) AS
    /***********************************************************************************************

    Created By:         smvk
    Date Created By:    20-May-2003
    Purpose:            This procedure validates all mandatory parameter required for the unit section occurrence
                        instructor process to proceed.

    Known limitations,enhancements,remarks:
    Change History
    Who       When         What
    ***********************************************************************************************/

    BEGIN
      p_uso_ins_rec.status:='S';

      -- Checking for the mandatory existence of Unit Code, verison  number, instructor person number parameter in the record.
      IF p_uso_ins_rec.instructor_person_number IS NULL OR p_uso_ins_rec.instructor_person_number = FND_API.G_MISS_CHAR THEN
         fnd_message.set_name('IGS','IGS_PS_INS_PERSON_NUMBER');
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY',fnd_message.get,NULL,FALSE);
         p_uso_ins_rec.status := 'E';
      END IF;

      IF p_uso_ins_rec.unit_cd IS NULL OR p_uso_ins_rec.unit_cd = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CD','LEGACY_TOKENS',FALSE);
         p_uso_ins_rec.status := 'E';
      END IF;

      IF p_uso_ins_rec.version_number IS NULL OR p_uso_ins_rec.version_number = FND_API.G_MISS_NUM THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_VER_NUM','LEGACY_TOKENS',FALSE);
         p_uso_ins_rec.status := 'E';
      END IF;

      -- if the production USO id is not provided then Teching calendar alternate code, location code and
      -- unit class are required.
      IF p_uso_ins_rec.production_uso_id IS NULL OR p_uso_ins_rec.production_uso_id = FND_API.G_MISS_NUM THEN
         IF p_uso_ins_rec.teach_cal_alternate_code IS NULL OR p_uso_ins_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS',FALSE);
            p_uso_ins_rec.status := 'E';
         END IF;
         IF p_uso_ins_rec.location_cd IS NULL OR p_uso_ins_rec.location_cd = FND_API.G_MISS_CHAR THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD','LEGACY_TOKENS',FALSE);
            p_uso_ins_rec.status := 'E';
         END IF;
         IF p_uso_ins_rec.unit_class IS NULL OR p_uso_ins_rec.unit_class = FND_API.G_MISS_CHAR THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CLASS','LEGACY_TOKENS',FALSE);
          p_uso_ins_rec.status := 'E';
         END IF;
      END IF;

      IF (p_uso_ins_rec.teach_cal_alternate_code IS NULL OR p_uso_ins_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR ) AND
         (p_uso_ins_rec.location_cd IS NULL OR p_uso_ins_rec.location_cd = FND_API.G_MISS_CHAR ) AND
         (p_uso_ins_rec.unit_class IS NULL OR p_uso_ins_rec.unit_class = FND_API.G_MISS_CHAR) THEN
         IF p_uso_ins_rec.production_uso_id IS NULL OR p_uso_ins_rec.production_uso_id = FND_API.G_MISS_NUM THEN
            fnd_message.set_name('IGS','IGS_PS_PRODUCTION_USO_ID');
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY',fnd_message.get,NULL,FALSE);
            p_uso_ins_rec.status := 'E';
         END IF;
      END IF;

      IF (p_uso_ins_rec.production_uso_id IS NULL OR p_uso_ins_rec.production_uso_id = FND_API.G_MISS_NUM ) AND
          (p_uso_ins_rec.occurrence_identifier IS NULL OR p_uso_ins_rec.occurrence_identifier = FND_API.G_MISS_CHAR) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'USEC_OCCRS_ID','IGS_PS_LOG_PARAMETERS', FALSE);
         p_uso_ins_rec.status := 'E';
      END IF;


    END validate_parameters;

    PROCEDURE validate_derivation(p_uso_ins_rec IN OUT NOCOPY igs_ps_generic_pub.uso_ins_rec_type) AS
    /***********************************************************************************************

    Created By:         smvk
    Date Created By:    20-May-2003
    Purpose:            This procedure derives the values required for creation of unit section occurrence instructor in production table.

    Known limitations,enhancements,remarks:
    Change History
    Who       When         What
    smvk      28-Jul-2004  Bug # 3793580. Coded to call get_uso_id procedure and removed
                           cursors used to derive USO id.
    jbegum    5-June-2003  Bug#2972950
                           For the PSP Scheduling Enhancements TD:
                           Modified the two cursors c_tba_count,c_tba_uso_id
    ***********************************************************************************************/


      CURSOR c_uoo_id (cp_n_uso_id IN igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
        SELECT A.uoo_id
        FROM   igs_ps_usec_occurs_all A
        WHERE  A.unit_section_occurrence_id = cp_n_uso_id;

      l_c_cal_type    igs_ca_inst_all.cal_type%TYPE;
      l_n_seq_num     igs_ca_inst_all.sequence_number%TYPE;
      l_d_start       igs_ca_inst_all.start_dt%TYPE;
      l_d_end         igs_ca_inst_all.end_dt%TYPE;
      l_c_ret_status  VARCHAR2(30);
      l_c_msg         VARCHAR2(30);

    BEGIN
      -- Initialize the variable use to store the derived values.
      l_n_ins_id := NULL;
      l_n_uso_id := NULL;
      l_n_uoo_id := NULL;

      -- Derive the Instructor identifier
      igs_ps_validate_lgcy_pkg.get_party_id(p_uso_ins_rec.instructor_person_number, l_n_ins_id);
      IF l_n_ins_id IS NULL THEN
         fnd_message.set_name('IGS','IGS_PS_INS_PERSON_NUMBER');
         igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', fnd_message.get,NULL, FALSE);
         p_uso_ins_rec.status := 'E';
      END IF;

      -- if the production unit section occurrence identifier is provided then validate it
      -- otherwise derive the production unit section occurrence identifier.
      IF p_uso_ins_rec.production_uso_id IS NOT NULL THEN
         IF igs_ps_usec_occurs_pkg.get_pk_for_validation(p_uso_ins_rec.production_uso_id) THEN
            l_n_uso_id := p_uso_ins_rec.production_uso_id;
            -- Also derive the unit section identifier uoo_id for the the unit section occurrence identifier
            OPEN  c_uoo_id(l_n_uso_id);
            FETCH c_uoo_id INTO l_n_uoo_id;
            CLOSE c_uoo_id;
         ELSE
            fnd_message.set_name('IGS','IGS_PS_PRODUCTION_USO_ID');
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', fnd_message.get,NULL, FALSE);
            p_uso_ins_rec.status := 'E';
         END IF;
      ELSE
         -- Deriving the value of Unit section Occurrence identifier

         -- Deriving the Calendar Type and Calendar Sequence Number
         igs_ge_gen_003.get_calendar_instance(p_uso_ins_rec.teach_cal_alternate_code,'''TEACHING''',  l_c_cal_type, l_n_seq_num, l_d_start, l_d_end, l_c_ret_status);
         IF l_c_ret_status <> 'SINGLE' THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS', FALSE);
             p_uso_ins_rec.status := 'E';
         END IF;
         -- Deriving the Unit Offering Option Identifier
         l_c_ret_status := NULL;
         igs_ps_validate_lgcy_pkg.get_uoo_id(p_uso_ins_rec.unit_cd, p_uso_ins_rec.version_number, l_c_cal_type, l_n_seq_num, p_uso_ins_rec.location_cd, p_uso_ins_rec.unit_class, l_n_uoo_id, l_c_ret_status);
         IF l_c_ret_status IS NOT NULL THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','UNIT_SECTION','LEGACY_TOKENS', FALSE);
            p_uso_ins_rec.status := 'E';
         END IF;


	 --Derive the unit section occurrence id
	 l_c_msg := NULL;
	 igs_ps_validate_lgcy_pkg.get_uso_id( p_uoo_id                => l_n_uoo_id,
					      p_occurrence_identifier => p_uso_ins_rec.occurrence_identifier,
					      p_uso_id                => l_n_uso_id,
					      p_message               => l_c_msg
					    );
	 IF l_c_msg IS NOT NULL THEN
	    fnd_message.set_name('IGS',l_c_msg);
	    fnd_msg_pub.add;
	    p_uso_ins_rec.status := 'E';
	 END IF;

      END IF;
    END validate_derivation;

    PROCEDURE validate_db_cons(p_uso_ins_rec IN OUT NOCOPY igs_ps_generic_pub.uso_ins_rec_type) AS
       CURSOR c_unit_ver (cp_n_uso_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
          SELECT  a.unit_cd, a.version_number
          FROM    igs_ps_unit_ofr_opt_all a, igs_ps_usec_occurs_all b
          WHERE   a.uoo_id = b.uoo_id
          AND     b.unit_section_occurrence_id = cp_n_uso_id;

          rec_unit_ver c_unit_ver%ROWTYPE;

    BEGIN
      -- Check uniqueness validation should not be done as it is override, after delete only it should be done


      -- Check Constraints
      BEGIN
        igs_ps_unit_ver_pkg.check_constraints( 'UNIT_CD',p_uso_ins_rec.unit_cd);
      EXCEPTION
        WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE','UNIT_CD','LEGACY_TOKENS',TRUE);
            p_uso_ins_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('VERSION_NUMBER',p_uso_ins_rec.version_number);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VER_NUM_1_999',NULL,NULL,TRUE);
          p_uso_ins_rec.status :='E';
      END;

      -- Foreign Key Checking
      IF NOT igs_pe_person_pkg.get_pk_for_validation(l_n_ins_id ) THEN
         fnd_message.set_name('IGS','IGS_PS_INS_PERSON_NUMBER');
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', fnd_message.get, NULL, FALSE);
         p_uso_ins_rec.status := 'E';
      END IF;
      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation (l_n_uoo_id ) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
         p_uso_ins_rec.status := 'E';
      END IF;

      IF p_uso_ins_rec.production_uso_id IS NOT NULL THEN

         -- validate the production USO ID with unit_cd, version_number
         OPEN  c_unit_ver(p_uso_ins_rec.production_uso_id);
         FETCH c_unit_ver INTO rec_unit_ver;
         IF c_unit_ver%FOUND THEN
            IF p_uso_ins_rec.unit_cd <> rec_unit_ver.unit_cd  OR
               p_uso_ins_rec.version_number <> rec_unit_ver.version_number THEN
               fnd_message.set_name('IGS','IGS_PS_LGCY_UNIT_VER_NOT_USO');
               fnd_msg_pub.add;
               p_uso_ins_rec.status :='E';
            END IF;
         ELSE
            fnd_message.set_name('IGS','IGS_PS_LGCY_UNIT_VER_NOT_USO');
            fnd_msg_pub.add;
            p_uso_ins_rec.status :='E';
         END IF;
         CLOSE c_unit_ver;

      END IF;

    END validate_db_cons;

   PROCEDURE delete_records(p_delete_status OUT NOCOPY BOOLEAN) IS
     CURSOR cur_ins_exists(cp_uso_id IN NUMBER) IS
     SELECT 'X'
     FROM   igs_ps_uso_instrctrs
     WHERE  unit_section_occurrence_id =cp_uso_id;

     CURSOR cur_resp_exists(cp_uoo_id IN NUMBER,cp_ins_id IN NUMBER) IS
     SELECT 'X'
     FROM   igs_ps_usec_tch_resp
     WHERE  uoo_id =cp_uoo_id
     AND    instructor_id=cp_ins_id
     AND    NOT EXISTS (SELECT 'X' FROM igs_ps_uso_instrctrs a,igs_ps_usec_occurs_all b
                        WHERE a.unit_section_occurrence_id=b.unit_section_occurrence_id
			AND   b.uoo_id=cp_uoo_id
			AND   a.instructor_id=cp_ins_id);

     CURSOR cur_enr(cp_uoo_id IN NUMBER) IS
     SELECT 'X'
     FROM igs_ps_unit_ofr_opt_all
     WHERE uoo_id= cp_uoo_id
     AND ENROLLMENT_ACTUAL > 0;

     l_c_var VARCHAR2(1);
   BEGIN
     p_delete_status:= TRUE;

     FOR I in 1..p_tab_uso_ins.LAST LOOP
         IF p_tab_uso_ins.EXISTS(I) AND p_tab_uso_ins(I).status = 'S' THEN
           p_tab_uso_ins(I).msg_from := fnd_msg_pub.count_msg;

	   OPEN cur_ins_exists(p_tab_uso_ins(I).system_uso_id);
	   FETCH cur_ins_exists INTO l_c_var;
	   IF cur_ins_exists%FOUND THEN
             DELETE igs_ps_uso_instrctrs WHERE unit_section_occurrence_id=p_tab_uso_ins(I).system_uso_id ;
           END IF;
           CLOSE cur_ins_exists;

	   OPEN cur_resp_exists(p_tab_uso_ins(I).system_uoo_id,p_tab_uso_ins(I).system_instructor_id);
	   FETCH cur_resp_exists INTO l_c_var;
	   IF cur_resp_exists%FOUND THEN

	      OPEN cur_enr(p_tab_uso_ins(I).system_uoo_id);
	      FETCH cur_enr INTO l_c_var;
	      IF cur_enr%FOUND THEN
		fnd_message.set_name('IGS','IGS_PS_ENR_EXISTS_NO_IMPORT');
  	        fnd_msg_pub.add;
		p_tab_uso_ins(I).status := 'E';
		p_c_rec_status := p_tab_uso_ins(I).status;
		p_tab_uso_ins(I).msg_from := p_tab_uso_ins(I).msg_from+1;
		p_tab_uso_ins(I).msg_to := fnd_msg_pub.count_msg;
		p_delete_status:= FALSE;
		RETURN;
	      ELSE
		DELETE igs_ps_usec_tch_resp WHERE instructor_id=p_tab_uso_ins(I).system_instructor_id AND
		uoo_id = p_tab_uso_ins(I).system_uoo_id ;

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_ins_ovrd.Delete_for_IGS_PS_USO_INSTRCTRS',
		  'Unit code:'||p_tab_uso_ins(I).unit_cd||'  '||'Version number:'||p_tab_uso_ins(I).version_number||'  '||
		  'teach_cal_alternate_code:'||p_tab_uso_ins(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_uso_ins(I).location_cd
		  ||'  '||'Unit Class:'||p_tab_uso_ins(I).unit_class||'  '||'instructor_person_number:'||p_tab_uso_ins(I).instructor_person_number
		  ||'  '||'occurrence_identifier'||p_tab_uso_ins(I).occurrence_identifier
		  ||'  '||'production_uso_id:'||p_tab_uso_ins(I).production_uso_id);
	        END IF;

	      END IF;
              CLOSE cur_enr;

	   END IF;
           CLOSE cur_resp_exists;

	 END IF;
     END LOOP;

   END delete_records;

   PROCEDURE insert_instructors(p_insert_status OUT NOCOPY BOOLEAN) IS

   BEGIN
     p_insert_status:= TRUE;
     FOR I in 1..p_tab_uso_ins.LAST LOOP
        IF p_tab_uso_ins.EXISTS(I) AND  p_tab_uso_ins(I).status = 'S' THEN
          p_tab_uso_ins(I).msg_from := fnd_msg_pub.count_msg;

          -- Check uniqueness validation
          IF igs_ps_uso_instrctrs_pkg.get_uk_for_validation(p_tab_uso_ins(I).system_uso_id, p_tab_uso_ins(I).system_instructor_id) THEN
            p_tab_uso_ins(I).status :='E';
            fnd_message.set_name('IGS','IGS_PS_USO_INS');
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', fnd_message.get, NULL, FALSE);
	    p_c_rec_status := p_tab_uso_ins(I).status;
            p_tab_uso_ins(I).msg_from := p_tab_uso_ins(I).msg_from+1;
            p_tab_uso_ins(I).msg_to := fnd_msg_pub.count_msg;
            p_insert_status:= FALSE;
            RETURN;
          ELSE

	    INSERT INTO IGS_PS_USO_INSTRCTRS (
					  USO_INSTRUCTOR_ID,
					  UNIT_SECTION_OCCURRENCE_ID,
					  INSTRUCTOR_ID,
					  CREATED_BY ,
					  CREATION_DATE,
					  LAST_UPDATED_BY,
					  LAST_UPDATE_DATE ,
					  LAST_UPDATE_LOGIN
					) VALUES (
					  igs_ps_uso_instrctrs_s.nextval,
					  p_tab_uso_ins(I).system_uso_id,
					  p_tab_uso_ins(I).system_instructor_id,
					  g_n_user_id,
					  sysdate,
					  g_n_user_id,
					  sysdate,
					  g_n_login_id
					);
             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_ins_ovrd.Insert_for_IGS_PS_USO_INSTRCTRS',
		'Unit code:'||p_tab_uso_ins(I).unit_cd||'  '||'Version number:'||p_tab_uso_ins(I).version_number||'  '||
		'teach_cal_alternate_code:'||p_tab_uso_ins(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_uso_ins(I).location_cd
		||'  '||'Unit Class:'||p_tab_uso_ins(I).unit_class||'  '||'instructor_person_number:'||p_tab_uso_ins(I).instructor_person_number
		||'  '||'occurrence_identifier'||p_tab_uso_ins(I).occurrence_identifier
		||'  '||'production_uso_id:'||p_tab_uso_ins(I).production_uso_id);
	     END IF;

               igs_ps_validate_lgcy_pkg.post_uso_ins(p_tab_uso_ins(I).system_instructor_id,
	                                             p_tab_uso_ins(I).system_uoo_id,
						     p_tab_uso_ins(I),I);

               IF p_tab_uso_ins(I).status <> 'S' THEN
		  p_c_rec_status := p_tab_uso_ins(I).status;
		  p_tab_uso_ins(I).msg_from := p_tab_uso_ins(I).msg_from+1;
		  p_tab_uso_ins(I).msg_to := fnd_msg_pub.count_msg;
		  p_insert_status:= FALSE;
	          RETURN;
	       END IF;
          END IF;

	END IF;
     END LOOP;

   END insert_instructors;

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_ins_ovrd.start_logging_for',
                    'Unit Section Occurrence Instructor Ovrd');
  END IF;

  IF p_calling_context = 'G' THEN
    igs_ps_unit_lgcy_pkg.create_uso_ins( p_tab_uso_ins  => p_tab_uso_ins,
                                         p_c_rec_status => p_c_rec_status );

  ELSE
     p_c_rec_status := 'S';
     FOR I in 1..p_tab_uso_ins.LAST LOOP
         IF p_tab_uso_ins.EXISTS(I) THEN
            p_tab_uso_ins(I).status := 'S';
            p_tab_uso_ins(I).msg_from := fnd_msg_pub.count_msg;
            trim_values(p_tab_uso_ins(I));
            validate_parameters(p_tab_uso_ins(I));

	    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_ins_ovrd.status_after_validate_parameters',
	      'Unit code:'||p_tab_uso_ins(I).unit_cd||'  '||'Version number:'||p_tab_uso_ins(I).version_number||'  '||
	      'teach_cal_alternate_code:'||p_tab_uso_ins(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_uso_ins(I).location_cd
	      ||'  '||'Unit Class:'||p_tab_uso_ins(I).unit_class||'  '||'instructor_person_number:'||p_tab_uso_ins(I).instructor_person_number
	      ||'  '||'occurrence_identifier'||p_tab_uso_ins(I).occurrence_identifier
	      ||'  '||'production_uso_id:'||p_tab_uso_ins(I).production_uso_id||'  '||'Status:'|| p_tab_uso_ins(I).status);
	    END IF;

            IF p_tab_uso_ins(I).status = 'S' THEN
               validate_derivation(p_tab_uso_ins(I));
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_ins_ovrd.status_after_validate_derivation',
	      'Unit code:'||p_tab_uso_ins(I).unit_cd||'  '||'Version number:'||p_tab_uso_ins(I).version_number||'  '||
	      'teach_cal_alternate_code:'||p_tab_uso_ins(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_uso_ins(I).location_cd
	      ||'  '||'Unit Class:'||p_tab_uso_ins(I).unit_class||'  '||'instructor_person_number:'||p_tab_uso_ins(I).instructor_person_number
	      ||'  '||'occurrence_identifier'||p_tab_uso_ins(I).occurrence_identifier
	      ||'  '||'production_uso_id:'||p_tab_uso_ins(I).production_uso_id||'  '||'Status:'|| p_tab_uso_ins(I).status);
	    END IF;

            IF p_tab_uso_ins(I).status = 'S' THEN
               validate_db_cons ( p_tab_uso_ins(I) );

	       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_ins_ovrd.status_after_validate_db_cons',
		  'Unit code:'||p_tab_uso_ins(I).unit_cd||'  '||'Version number:'||p_tab_uso_ins(I).version_number||'  '||
		  'teach_cal_alternate_code:'||p_tab_uso_ins(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_uso_ins(I).location_cd
		  ||'  '||'Unit Class:'||p_tab_uso_ins(I).unit_class||'  '||'instructor_person_number:'||p_tab_uso_ins(I).instructor_person_number
		  ||'  '||'occurrence_identifier'||p_tab_uso_ins(I).occurrence_identifier
		  ||'  '||'production_uso_id:'||p_tab_uso_ins(I).production_uso_id||'  '||'Status:'|| p_tab_uso_ins(I).status);
	       END IF;

            END IF;

	    IF p_tab_uso_ins(I).status = 'S' THEN
    	      IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,l_n_uso_id) = FALSE THEN
                fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
                fnd_msg_pub.add;
                p_tab_uso_ins(I).status := 'A';
	      END IF;

              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_ins_ovrd.status_after_check_import_allowed',
		  'Unit code:'||p_tab_uso_ins(I).unit_cd||'  '||'Version number:'||p_tab_uso_ins(I).version_number||'  '||
		  'teach_cal_alternate_code:'||p_tab_uso_ins(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_uso_ins(I).location_cd
		  ||'  '||'Unit Class:'||p_tab_uso_ins(I).unit_class||'  '||'instructor_person_number:'||p_tab_uso_ins(I).instructor_person_number
		  ||'  '||'occurrence_identifier'||p_tab_uso_ins(I).occurrence_identifier
		  ||'  '||'production_uso_id:'||p_tab_uso_ins(I).production_uso_id||'  '||'Status:'|| p_tab_uso_ins(I).status);
	       END IF;

            END IF;

            --Business validations
            IF p_tab_uso_ins(I).status = 'S' THEN
	      --Check if the unit is INACTIVE, then do not allow to import
	      IF igs_ps_val_unit.crsp_val_iud_uv_dtl(p_tab_uso_ins(I).unit_cd, p_tab_uso_ins(I).version_number,l_message_name)=FALSE THEN
		    fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
		    fnd_msg_pub.add;
		    p_tab_uso_ins(I).status := 'E';
	      END IF;

	      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_ins_ovrd.status_after_check_import_allowed',
		  'Unit code:'||p_tab_uso_ins(I).unit_cd||'  '||'Version number:'||p_tab_uso_ins(I).version_number||'  '||
		  'teach_cal_alternate_code:'||p_tab_uso_ins(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_uso_ins(I).location_cd
		  ||'  '||'Unit Class:'||p_tab_uso_ins(I).unit_class||'  '||'instructor_person_number:'||p_tab_uso_ins(I).instructor_person_number
		  ||'  '||'occurrence_identifier'||p_tab_uso_ins(I).occurrence_identifier
		  ||'  '||'production_uso_id:'||p_tab_uso_ins(I).production_uso_id||'  '||'Status:'|| p_tab_uso_ins(I).status);
	       END IF;

            END IF;

            IF p_tab_uso_ins(I).status = 'S' THEN
	         p_tab_uso_ins(I).system_uoo_id:=l_n_uoo_id;
	         p_tab_uso_ins(I).system_uso_id:=l_n_uso_id;
	         p_tab_uso_ins(I).system_instructor_id:=l_n_ins_id;

		 --Insert is done in insert_instructors
            END IF;

            --Post validation is also done at insert_instructors

            IF p_tab_uso_ins(I).status = 'S' THEN
               p_tab_uso_ins(I).msg_from := NULL;
               p_tab_uso_ins(I).msg_to := NULL;
	    ELSIF  p_tab_uso_ins(I).status = 'A' THEN
	       p_tab_uso_ins(I).msg_from  := p_tab_uso_ins(I).msg_from + 1;
	       p_tab_uso_ins(I).msg_to := fnd_msg_pub.count_msg;
            ELSE
               p_c_rec_status := p_tab_uso_ins(I).status;
               p_tab_uso_ins(I).msg_from := p_tab_uso_ins(I).msg_from+1;
               p_tab_uso_ins(I).msg_to := fnd_msg_pub.count_msg;
               IF p_tab_uso_ins(I).status = 'E' THEN
                  RETURN;
               END IF;
            END IF;

         END IF;
     END LOOP;

     --Delete the existing records
     delete_records(l_delete_status);

     IF l_delete_status = FALSE THEN
        RETURN;
     END IF;
     --Insert the instructors
     insert_instructors(l_insert_status);
     IF l_insert_status = FALSE THEN
        RETURN;
     END IF;


     IF NOT igs_ps_validate_lgcy_pkg.post_uso_ins_busi(p_tab_uso_ins) THEN
        p_c_rec_status :=  'E';
     END IF;

  END IF; --Scheduling

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_uso_ins_ovrd.after_import_status',p_c_rec_status);
  END IF;


END create_uso_ins_ovrd;

PROCEDURE create_usec_teach_resp(p_usec_teach_resp_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_tbl_type
                                ,p_c_rec_status OUT NOCOPY VARCHAR2
			        ,p_calling_context IN VARCHAR2) IS
/***********************************************************************************************

Created By:         sarakshi
Date Created By:    31-May-2005
Purpose:            This procedure imports(Updates) unit section Teaching Responsibilities.

Known limitations,enhancements,remarks:
Change History
Who       When         What
***********************************************************************************************/
    l_n_ins_id            igs_ps_uso_instrctrs.instructor_id%TYPE;
    l_n_uoo_id            igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_d_start_dt          igs_ps_usec_occurs_all.start_date%TYPE;
    l_d_end_dt            igs_ps_usec_occurs_all.end_date%TYPE;
    l_message_name        VARCHAR2(30);


  -- for doing certain validation at unit section level while importing unit section occurrence of instructors
  TYPE usec_sr_rectype IS RECORD( uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                                  instr_index NUMBER);
  TYPE usec_sr_tbltype IS TABLE OF usec_sr_rectype INDEX BY BINARY_INTEGER;
  v_tab_usec_sr usec_sr_tbltype;

    PROCEDURE trim_values ( p_usec_teach_resp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_rec_type) AS
    BEGIN
      p_usec_teach_resp_rec.instructor_person_number := TRIM(p_usec_teach_resp_rec.instructor_person_number);
      p_usec_teach_resp_rec.unit_cd := TRIM(p_usec_teach_resp_rec.unit_cd);
      p_usec_teach_resp_rec.version_number := TRIM(p_usec_teach_resp_rec.version_number);
      p_usec_teach_resp_rec.teach_cal_alternate_code := TRIM(p_usec_teach_resp_rec.teach_cal_alternate_code);
      p_usec_teach_resp_rec.location_cd := TRIM(p_usec_teach_resp_rec.location_cd);
      p_usec_teach_resp_rec.unit_class := TRIM(p_usec_teach_resp_rec.unit_class);
      p_usec_teach_resp_rec.confirmed_flag := TRIM(p_usec_teach_resp_rec.confirmed_flag);
      p_usec_teach_resp_rec.wl_percentage_allocation := TRIM(p_usec_teach_resp_rec.wl_percentage_allocation);
      p_usec_teach_resp_rec.instructional_load_lecture := TRIM(p_usec_teach_resp_rec.instructional_load_lecture);
      p_usec_teach_resp_rec.instructional_load_laboratory :=  TRIM(p_usec_teach_resp_rec.instructional_load_laboratory);
      p_usec_teach_resp_rec.instructional_load_other :=  TRIM(p_usec_teach_resp_rec.instructional_load_other);
      p_usec_teach_resp_rec.lead_instructor_flag := TRIM(p_usec_teach_resp_rec.lead_instructor_flag);

    END trim_values;

    PROCEDURE validate_parameters(p_usec_teach_resp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_rec_type) AS

    BEGIN
      p_usec_teach_resp_rec.status:='S';

      -- Checking for the mandatory existence of Unit Code, verison  number, instructor person number parameter in the record.
      IF p_usec_teach_resp_rec.instructor_person_number IS NULL OR p_usec_teach_resp_rec.instructor_person_number = FND_API.G_MISS_CHAR THEN
         fnd_message.set_name('IGS','IGS_PS_INS_PERSON_NUMBER');
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY',fnd_message.get,NULL,FALSE);
         p_usec_teach_resp_rec.status := 'E';
      END IF;

      IF p_usec_teach_resp_rec.unit_cd IS NULL OR p_usec_teach_resp_rec.unit_cd = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CD','LEGACY_TOKENS',FALSE);
         p_usec_teach_resp_rec.status := 'E';
      END IF;

      IF p_usec_teach_resp_rec.version_number IS NULL OR p_usec_teach_resp_rec.version_number = FND_API.G_MISS_NUM THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_VER_NUM','LEGACY_TOKENS',FALSE);
         p_usec_teach_resp_rec.status := 'E';
      END IF;

      IF p_usec_teach_resp_rec.teach_cal_alternate_code IS NULL OR p_usec_teach_resp_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS',FALSE);
	 p_usec_teach_resp_rec.status := 'E';
      END IF;

      IF p_usec_teach_resp_rec.location_cd IS NULL OR p_usec_teach_resp_rec.location_cd = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD','LEGACY_TOKENS',FALSE);
	 p_usec_teach_resp_rec.status := 'E';
      END IF;

      IF p_usec_teach_resp_rec.unit_class IS NULL OR p_usec_teach_resp_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CLASS','LEGACY_TOKENS',FALSE);
	p_usec_teach_resp_rec.status := 'E';
      END IF;

    END validate_parameters;

    PROCEDURE validate_derivation(p_usec_teach_resp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_rec_type) AS

      l_c_cal_type    igs_ca_inst_all.cal_type%TYPE;
      l_n_seq_num     igs_ca_inst_all.sequence_number%TYPE;
      l_d_start       igs_ca_inst_all.start_dt%TYPE;
      l_d_end         igs_ca_inst_all.end_dt%TYPE;
      l_c_ret_status  VARCHAR2(30);

    BEGIN
      -- Initialize the variable use to store the derived values.
      l_n_ins_id := NULL;
      l_n_uoo_id := NULL;

      -- Derive the Instructor identifier
      igs_ps_validate_lgcy_pkg.get_party_id(p_usec_teach_resp_rec.instructor_person_number, l_n_ins_id);
      IF l_n_ins_id IS NULL THEN
         fnd_message.set_name('IGS','IGS_PS_INS_PERSON_NUMBER');
         igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', fnd_message.get,NULL, FALSE);
         p_usec_teach_resp_rec.status := 'E';
      END IF;


       -- Deriving the Calendar Type and Calendar Sequence Number
       igs_ge_gen_003.get_calendar_instance(p_usec_teach_resp_rec.teach_cal_alternate_code,'''TEACHING''',  l_c_cal_type, l_n_seq_num, l_d_start, l_d_end, l_c_ret_status);
       IF l_c_ret_status <> 'SINGLE' THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS', FALSE);
	   p_usec_teach_resp_rec.status := 'E';
       END IF;

       -- Deriving the Unit Offering Option Identifier
       l_c_ret_status := NULL;
       igs_ps_validate_lgcy_pkg.get_uoo_id(p_usec_teach_resp_rec.unit_cd, p_usec_teach_resp_rec.version_number, l_c_cal_type, l_n_seq_num, p_usec_teach_resp_rec.location_cd, p_usec_teach_resp_rec.unit_class, l_n_uoo_id, l_c_ret_status);
       IF l_c_ret_status IS NOT NULL THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','UNIT_SECTION','LEGACY_TOKENS', FALSE);
	  p_usec_teach_resp_rec.status := 'E';
       END IF;

    END validate_derivation;

    PROCEDURE validate_db_cons(p_usec_teach_resp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_rec_type) AS

    BEGIN

      -- Check Constraints
      BEGIN
        igs_ps_unit_ver_pkg.check_constraints( 'UNIT_CD',p_usec_teach_resp_rec.unit_cd);
      EXCEPTION
        WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE','UNIT_CD','LEGACY_TOKENS',TRUE);
            p_usec_teach_resp_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('VERSION_NUMBER',p_usec_teach_resp_rec.version_number);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VER_NUM_1_999',NULL,NULL,TRUE);
          p_usec_teach_resp_rec.status :='E';
      END;

      BEGIN
          igs_ps_usec_tch_resp_pkg.check_constraints('LEAD_INSTRUCTOR_FLAG', p_usec_teach_resp_rec.lead_instructor_flag);
      EXCEPTION
          WHEN OTHERS THEN
             fnd_message.set_name('IGS','IGS_PS_LEAD_INSTRUCTOR_FLAG');
             igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N',fnd_message.get, NULL,TRUE);
             p_usec_teach_resp_rec.status :='E';
      END;

      BEGIN
          igs_ps_usec_tch_resp_pkg.check_constraints('CONFIRMED_FLAG', p_usec_teach_resp_rec.confirmed_flag);
      EXCEPTION
         WHEN OTHERS THEN
             fnd_message.set_name('IGS','IGS_PS_CONFIRMED_FLAG');
             igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N',fnd_message.get, NULL,TRUE);
             p_usec_teach_resp_rec.status :='E';
      END;

       IF p_usec_teach_resp_rec.wl_percentage_allocation IS NOT NULL THEN
          BEGIN
             igs_ps_usec_tch_resp_pkg.check_constraints('PERCENTAGE_ALLOCATION', p_usec_teach_resp_rec.wl_percentage_allocation);
          EXCEPTION
             WHEN OTHERS THEN
                igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PTS_RANGE_0_999','PERCENTAGE','LEGACY_TOKENS',TRUE);
                p_usec_teach_resp_rec.status :='E';
          END;
       END IF;

       IF p_usec_teach_resp_rec.instructional_load_lecture IS NOT NULL THEN
          BEGIN
             igs_ps_usec_tch_resp_pkg.check_constraints('INSTRUCTIONAL_LOAD_LECTURE', p_usec_teach_resp_rec.instructional_load_lecture);
          EXCEPTION
             WHEN OTHERS THEN
               fnd_message.set_name('IGS','IGS_PS_INS_LOAD_LECTURE');
               igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_9999D99',fnd_message.get, NULL,TRUE);
               p_usec_teach_resp_rec.status :='E';
          END;
       END IF;

       IF p_usec_teach_resp_rec.instructional_load_laboratory IS NOT NULL THEN
          BEGIN
             igs_ps_usec_tch_resp_pkg.check_constraints('INSTRUCTIONAL_LOAD_LAB', p_usec_teach_resp_rec.instructional_load_laboratory);
          EXCEPTION
             WHEN OTHERS THEN
                fnd_message.set_name('IGS','IGS_PS_INS_LOAD_LAB');
                igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_9999D99',fnd_message.get,NULL,TRUE);
                p_usec_teach_resp_rec.status :='E';
          END;
       END IF;

       IF p_usec_teach_resp_rec.instructional_load_other IS NOT NULL THEN
          BEGIN
             igs_ps_usec_tch_resp_pkg.check_constraints('INSTRUCTIONAL_LOAD', p_usec_teach_resp_rec.instructional_load_other);
          EXCEPTION
             WHEN OTHERS THEN
                fnd_message.set_name('IGS','IGS_PS_INS_LOAD_OTHER');
                igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_9999D99',fnd_message.get,NULL,TRUE);
                p_usec_teach_resp_rec.status :='E';
          END;
       END IF;

      -- Foreign Key Checking
      IF NOT igs_pe_person_pkg.get_pk_for_validation(l_n_ins_id ) THEN
         fnd_message.set_name('IGS','IGS_PS_INS_PERSON_NUMBER');
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', fnd_message.get, NULL, FALSE);
         p_usec_teach_resp_rec.status := 'E';
      END IF;

      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation (l_n_uoo_id ) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
         p_usec_teach_resp_rec.status := 'E';
      END IF;

    END validate_db_cons;

    PROCEDURE Assign_default(p_usec_teach_resp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_rec_type) AS
      CURSOR cur_resp(cp_n_uoo_id IN NUMBER,cp_n_ins_id IN NUMBER) IS
      SELECT *
      FROM   igs_ps_usec_tch_resp
      WHERE  instructor_id = cp_n_ins_id
      AND    uoo_id = cp_n_uoo_id;
      l_cur_resp cur_resp%ROWTYPE;

    BEGIN

      OPEN cur_resp(l_n_uoo_id,l_n_ins_id);
      FETCH cur_resp into l_cur_resp;
      IF cur_resp%FOUND THEN

	IF p_usec_teach_resp_rec.confirmed_flag IS NULL THEN
	  p_usec_teach_resp_rec.confirmed_flag  := l_cur_resp.confirmed_flag;
        ELSIF p_usec_teach_resp_rec.confirmed_flag = FND_API.G_MISS_CHAR THEN
	  p_usec_teach_resp_rec.confirmed_flag  := 'N';
	END IF;

	IF p_usec_teach_resp_rec.lead_instructor_flag IS NULL THEN
	  p_usec_teach_resp_rec.lead_instructor_flag  := l_cur_resp.lead_instructor_flag;
        ELSIF p_usec_teach_resp_rec.lead_instructor_flag = FND_API.G_MISS_CHAR THEN
	  p_usec_teach_resp_rec.lead_instructor_flag  := 'N';
	END IF;

	IF p_usec_teach_resp_rec.wl_percentage_allocation IS NULL THEN
  	  p_usec_teach_resp_rec.wl_percentage_allocation      := l_cur_resp.percentage_allocation;
        ELSIF p_usec_teach_resp_rec.wl_percentage_allocation = FND_API.G_MISS_NUM THEN
  	  p_usec_teach_resp_rec.wl_percentage_allocation      := NULL;
	END IF;

	IF p_usec_teach_resp_rec.instructional_load_lecture IS NULL THEN
	  p_usec_teach_resp_rec.instructional_load_lecture    := l_cur_resp.instructional_load_lecture;
        ELSIF p_usec_teach_resp_rec.instructional_load_lecture = FND_API.G_MISS_NUM THEN
	  p_usec_teach_resp_rec.instructional_load_lecture    := NULL;
	END IF;

	IF p_usec_teach_resp_rec.instructional_load_laboratory IS NULL THEN
	  p_usec_teach_resp_rec.instructional_load_laboratory    := l_cur_resp.instructional_load_lab;
        ELSIF p_usec_teach_resp_rec.instructional_load_laboratory = FND_API.G_MISS_NUM THEN
	  p_usec_teach_resp_rec.instructional_load_laboratory    := NULL;
	END IF;

	IF p_usec_teach_resp_rec.instructional_load_other IS NULL THEN
	  p_usec_teach_resp_rec.instructional_load_other    := l_cur_resp.instructional_load;
        ELSIF p_usec_teach_resp_rec.instructional_load_other = FND_API.G_MISS_NUM THEN
	  p_usec_teach_resp_rec.instructional_load_other    := NULL;
	END IF;

      ELSE
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'TEACHING_RESPONSIBILITY', 'LEGACY_TOKENS', FALSE);
        p_usec_teach_resp_rec.status := 'E';
      END IF;
      CLOSE cur_resp;

    END Assign_default;

    PROCEDURE Business_validation(p_usec_teach_resp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_rec_type) AS
       CURSOR c_lead_cnd (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%type) IS
	 SELECT COUNT(*)
	 FROM   IGS_PS_USEC_TCH_RESP
	 WHERE  lead_instructor_flag='Y'
	 AND    uoo_id = cp_n_uoo_id
	 AND    ROWNUM = 1;

       CURSOR c_cal_inst (cp_n_uoo_id IN NUMBER) IS
	 SELECT A.cal_type,
		A.ci_sequence_number,
		A.unit_section_status
	 FROM   IGS_PS_UNIT_OFR_OPT_ALL A
	 WHERE  A.uoo_id  =  cp_n_uoo_id;

       CURSOR c_cal_setup IS
	 SELECT 'x'
	 FROM   IGS_PS_EXP_WL
	 WHERE  ROWNUM=1;

       rec_cal_inst c_cal_inst%ROWTYPE;

       l_n_t_lecture        igs_ps_usec_tch_resp.instructional_load_lecture%TYPE :=0;
       l_n_t_lab            igs_ps_usec_tch_resp.instructional_load_lab%TYPE :=0;
       l_n_t_other          igs_ps_usec_tch_resp.instructional_load%TYPE :=0;
       l_n_total_wl         NUMBER(10,2);
       l_n_exp_wl           NUMBER(6,2);
       l_n_tot_fac_wl       NUMBER(10,2);
       l_c_cal              VARCHAR2(1);
       l_n_no_of_instructor NUMBER;
       l_n_count            NUMBER;
    BEGIN
      --Check if the unit is INACTIVE, then do not allow to import
      IF igs_ps_val_unit.crsp_val_iud_uv_dtl(p_usec_teach_resp_rec.unit_cd, p_usec_teach_resp_rec.version_number,l_message_name)=FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
	    fnd_msg_pub.add;
	    p_usec_teach_resp_rec.status := 'E';
      END IF;

      -- Validation : Either percentage allocation or workload value should be provided. Both cannot be null
      -- Presently coded the mandatory validation for confirmed records.
      IF p_usec_teach_resp_rec.confirmed_flag = 'Y' AND
         p_usec_teach_resp_rec.wl_percentage_allocation IS NULL AND
         p_usec_teach_resp_rec.instructional_load_lecture IS NULL AND
         p_usec_teach_resp_rec.instructional_load_laboratory IS NULL AND
         p_usec_teach_resp_rec.instructional_load_other IS NULL THEN
           fnd_message.set_name('IGS','IGS_PS_PERCENT_WKLD_MANDATORY');
           fnd_msg_pub.add;
           p_usec_teach_resp_rec.status := 'E';
      END IF;


      --Instructor should be staff or faculty
      IF igs_ps_validate_lgcy_pkg.validate_staff_faculty (p_person_id => l_n_ins_id) = FALSE THEN
             p_usec_teach_resp_rec.status :='E';
             fnd_message.set_name('IGS','IGS_PS_INST_NOT_FACULTY_STAFF');
             fnd_msg_pub.add;
      END IF;

      -- if workload percentage is provided need to dervie the lecture /lab / other workloads.
      IF p_usec_teach_resp_rec.wl_percentage_allocation IS NOT NULL AND
          p_usec_teach_resp_rec.instructional_load_lecture IS NULL AND
          p_usec_teach_resp_rec.instructional_load_laboratory IS NULL AND
          p_usec_teach_resp_rec.instructional_load_other IS NULL THEN

          igs_ps_fac_credt_wrkload.calculate_teach_work_load(l_n_uoo_id, p_usec_teach_resp_rec.wl_percentage_allocation, l_n_t_lab , l_n_t_lecture, l_n_t_other);
             p_usec_teach_resp_rec.instructional_load_lecture := l_n_t_lecture;
             p_usec_teach_resp_rec.instructional_load_laboratory := l_n_t_lab;
             p_usec_teach_resp_rec.instructional_load_other := l_n_t_other;
      END IF;


      IF p_usec_teach_resp_rec.confirmed_flag = 'Y' THEN
          OPEN c_cal_setup;
          FETCH c_cal_setup INTO l_c_cal;
          CLOSE c_cal_setup;
          IF l_c_cal IS NULL THEN
             p_usec_teach_resp_rec.status :='E';
             fnd_message.set_name('IGS','IGS_PS_NO_CAL_CAT_SETUP');
             fnd_msg_pub.add;
          ELSIF l_c_cal = 'x' THEN
             l_n_total_wl := NVL(p_usec_teach_resp_rec.instructional_load_lecture,0) +
                             NVL(p_usec_teach_resp_rec.instructional_load_laboratory,0) +
                             NVL(p_usec_teach_resp_rec.instructional_load_other,0);

             OPEN c_cal_inst(l_n_uoo_id);
             FETCH c_cal_inst INTO rec_cal_inst;
             IF c_cal_inst%FOUND THEN
                IF rec_cal_inst.unit_section_status NOT IN ('CANCELLED','NOT_OFFERED') THEN
                   IF igs_ps_gen_001.teach_fac_wl (rec_cal_inst.cal_type,
                                                   rec_cal_inst.ci_sequence_number,
                                                   l_n_ins_id,
                                                   l_n_total_wl,
                                                   l_n_tot_fac_wl,
                                                   l_n_exp_wl
                                                   ) THEN
                      p_usec_teach_resp_rec.status :='E';
                      fnd_message.set_name('IGS','IGS_PS_FAC_EXCEED_EXP_WL');
                      fnd_msg_pub.add;
                   END IF;
                   IF l_n_exp_wl IS NULL OR l_n_exp_wl = 0 THEN
                      p_usec_teach_resp_rec.status :='E';
                      fnd_message.set_name('IGS','IGS_PS_NO_SETUP_FAC_EXCEED');
                      fnd_msg_pub.add;
                   END IF;
                END IF;
             END IF;
             CLOSE c_cal_inst;
          END IF;
      END IF;


    END Business_validation;

 FUNCTION post_uso_resp_busi (p_usec_teach_resp_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_tbl_type) RETURN BOOLEAN AS


   l_tab_uoo igs_ps_create_generic_pkg.uoo_tbl_type;

   CURSOR c_count_lead (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT count(*)
     FROM   IGS_PS_USEC_TCH_RESP
     WHERE  uoo_id = cp_n_uoo_id
      AND   lead_instructor_flag = 'Y';

   CURSOR c_count_percent(cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT SUM(PERCENTAGE_ALLOCATION)
     FROM   IGS_PS_USEC_TCH_RESP
     WHERE  confirmed_flag = 'Y'
     AND    uoo_id = cp_n_uoo_id;

   CURSOR c_unit_dtls (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT unit_cd,
            version_number
     FROM   igs_ps_unit_ofr_opt_all
     WHERE  uoo_id = cp_n_uoo_id
     AND    ROWNUM < 2;

   CURSOR c_null IS
   SELECT message_text
   FROM   fnd_new_messages
   WHERE  message_name = 'IGS_PS_NULL'
   AND    application_id = 8405
   AND    LANGUAGE_CODE = USERENV('LANG');

   l_c_null  fnd_new_messages.message_text%TYPE;

   l_n_count NUMBER;
   l_n_from NUMBER;
   l_n_to NUMBER;
   l_b_validation BOOLEAN;
   l_b_status BOOLEAN;
   l_b_wl_validation BOOLEAN;
   l_n_tot_lec NUMBER;
   l_n_tot_lab NUMBER;
   l_n_tot_oth NUMBER;
   rec_unit_dtls c_unit_dtls%ROWTYPE;
   l_c_validation_type igs_ps_unit_ver_all.workload_val_code%TYPE;


 BEGIN
   l_b_validation := TRUE;
   l_b_status :=TRUE;
   l_b_wl_validation := TRUE;

   IF v_tab_usec_sr.EXISTS(1) THEN
      l_tab_uoo(1) := v_tab_usec_sr(1).uoo_id;

     FOR I in 2.. v_tab_usec_sr.COUNT LOOP
         IF NOT igs_ps_validate_lgcy_pkg.isExists(v_tab_usec_sr(I).uoo_id,l_tab_uoo) THEN
           l_tab_uoo(l_tab_uoo.count+1) := v_tab_usec_sr(I).uoo_id;
         END IF;
     END LOOP;

     -- Get the parent unit version.
     OPEN c_unit_dtls (l_tab_uoo(1));
     FETCH c_unit_dtls INTO rec_unit_dtls;
     CLOSE c_unit_dtls;

     -- Get the workload validation type
     l_c_validation_type := igs_ps_fac_credt_wrkload.get_validation_type (rec_unit_dtls.unit_cd, rec_unit_dtls.version_number);

     FOR I in 1.. l_tab_uoo.count LOOP

        l_n_from := fnd_msg_pub.count_msg;
        l_b_validation := TRUE;
        l_b_wl_validation := TRUE;
        OPEN c_count_lead(l_tab_uoo(I));
        FETCH c_count_lead INTO l_n_count;
        CLOSE c_count_lead;
        IF l_n_count < 1 THEN
             fnd_message.set_name('IGS','IGS_PS_ATLST_ONE_LD_INSTRCTR');
             fnd_msg_pub.add;
             l_b_validation :=FALSE;
        ELSIF l_n_count > 1 THEN
             fnd_message.set_name ('IGS','IGS_PS_LEAD_INSTRUCTOR_ONE');
             fnd_msg_pub.add;
             l_b_validation :=FALSE;
        END IF;

        IF l_c_validation_type <> 'NONE' THEN
           OPEN c_count_percent(l_tab_uoo(I));
           FETCH c_count_percent INTO l_n_count;
           CLOSE c_count_percent;

           IF l_n_count <> 100 THEN
              fnd_message.set_name('IGS', 'IGS_PS_US_TCHRESP_NOTTOTAL_100');
              fnd_msg_pub.add;
              l_b_wl_validation :=FALSE;
           END IF;

           IF NOT igs_ps_fac_credt_wrkload.validate_workload(l_tab_uoo(I),l_n_tot_lec,l_n_tot_lab,l_n_tot_oth) THEN
              fnd_message.set_name('IGS','IGS_PS_WKLOAD_VALIDATION');
	      OPEN c_null;
	      FETCH c_null INTO l_c_null;
	      CLOSE c_null;

              IF l_n_tot_lec = -999 THEN
                fnd_message.set_token('WKLOAD_LECTURE',l_c_null);
              ELSE
                fnd_message.set_token('WKLOAD_LECTURE',l_n_tot_lec);
              END IF;

              IF l_n_tot_lab = -999 THEN
                fnd_message.set_token('WKLOAD_LAB',l_c_null);
              ELSE
                fnd_message.set_token('WKLOAD_LAB',l_n_tot_lab);
              END IF;

              IF l_n_tot_oth = -999 THEN
                fnd_message.set_token('WKLOAD_OTHER',l_c_null);
              ELSE
                fnd_message.set_token('WKLOAD_OTHER',l_n_tot_oth);
              END IF;

	      fnd_msg_pub.add;
              l_b_wl_validation :=FALSE;  -- modified as a part of Bug # 3568858.
           END IF;
        END IF;

        IF NOT (l_b_validation AND l_b_wl_validation) THEN
           l_n_to := fnd_msg_pub.count_msg;
           FOR j in 1.. v_tab_usec_sr.COUNT LOOP
               IF l_tab_uoo(I) = v_tab_usec_sr(j).uoo_id AND p_usec_teach_resp_tbl(v_tab_usec_sr(j).instr_index).status = 'S' THEN
                  -- Setting the status of the record properly
                  -- Set the status of records as error and return status (l_b_status) as error when
                  -- 1) if the lead instructor validation is fails
                  -- 2) if the percentage allocation or workload validation fails, when the workload validation type is 'DENY'.
                  -- Set the status of record as warning
                  -- 1) if the percentage allocation or workload validation fails, when the workload validation type is 'WARN'.
                  IF NOT l_b_validation THEN
                     -- Failure of lead instructor validation.
                     p_usec_teach_resp_tbl(v_tab_usec_sr(j).instr_index).status := 'E';
                     l_b_status :=FALSE;
                  ELSE
                      -- when workload validation type is not equal to NONE
                      IF l_c_validation_type = 'WARN' THEN
                         -- setting the status as warning for the record and not setting the value for l_b_status.
                         p_usec_teach_resp_tbl(v_tab_usec_sr(j).instr_index).status := 'W';
                      ELSE  -- workload workload validation type is DENY
                         -- setting the status of the record and l_b_status as error.
                         p_usec_teach_resp_tbl(v_tab_usec_sr(j).instr_index).status := 'E';
                         l_b_status :=FALSE;
                      END IF;
                   END IF;

                   p_usec_teach_resp_tbl(v_tab_usec_sr(j).instr_index).msg_from := l_n_from +1;
                   p_usec_teach_resp_tbl(v_tab_usec_sr(j).instr_index).msg_to := l_n_to;
               END IF;
           END LOOP;
        END IF;

     END LOOP;

     v_tab_usec_sr.delete;
     return l_b_status;
   ELSE

      RETURN TRUE;
   END IF;
 END post_uso_resp_busi;

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp.start_logging_for',
                    'Unit Section ');
  END IF;

  p_c_rec_status := 'S';
  FOR I in 1..p_usec_teach_resp_tbl.LAST LOOP
     IF p_usec_teach_resp_tbl.EXISTS(I) THEN
	p_usec_teach_resp_tbl(I).status := 'S';
	p_usec_teach_resp_tbl(I).msg_from := fnd_msg_pub.count_msg;
	trim_values(p_usec_teach_resp_tbl(I));
	validate_parameters(p_usec_teach_resp_tbl(I));

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp.status_after_validate_parameters',
	   'Unit code:'||p_usec_teach_resp_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_teach_resp_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_tbl(I).location_cd||'  '||'Unit Class:'||
	   p_usec_teach_resp_tbl(I).unit_class||'  '||'instructor_person_number:'||p_usec_teach_resp_tbl(I).instructor_person_number
	   ||'  '||'Status:'|| p_usec_teach_resp_tbl(I).status);
        END IF;

	IF p_usec_teach_resp_tbl(I).status = 'S' THEN
	   validate_derivation(p_usec_teach_resp_tbl(I));

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp.status_after_validate_derivation',
	     'Unit code:'||p_usec_teach_resp_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_teach_resp_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_teach_resp_tbl(I).unit_class||'  '||'instructor_person_number:'||p_usec_teach_resp_tbl(I).instructor_person_number
	     ||'  '||'Status:'|| p_usec_teach_resp_tbl(I).status);
           END IF;

	END IF;


	IF p_usec_teach_resp_tbl(I).status = 'S' AND p_calling_context = 'S' THEN
	  IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	    fnd_msg_pub.add;
	    p_usec_teach_resp_tbl(I).status := 'A';
	  END IF;

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp.status_after_check_import_allowed',
	     'Unit code:'||p_usec_teach_resp_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_teach_resp_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_teach_resp_tbl(I).unit_class||'  '||'instructor_person_number:'||p_usec_teach_resp_tbl(I).instructor_person_number
	     ||'  '||'Status:'|| p_usec_teach_resp_tbl(I).status);
          END IF;

	END IF;


	IF p_usec_teach_resp_tbl(I).status = 'S' THEN
	   Assign_default(p_usec_teach_resp_tbl(I));

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp.status_after_Assign_default',
	     'Unit code:'||p_usec_teach_resp_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_teach_resp_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_teach_resp_tbl(I).unit_class||'  '||'instructor_person_number:'||p_usec_teach_resp_tbl(I).instructor_person_number
	     ||'  '||'Status:'|| p_usec_teach_resp_tbl(I).status);
           END IF;

	END IF;

	IF p_usec_teach_resp_tbl(I).status = 'S' THEN
	   validate_db_cons ( p_usec_teach_resp_tbl(I) );

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp.status_after_validate_db_cons',
	     'Unit code:'||p_usec_teach_resp_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_teach_resp_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_teach_resp_tbl(I).unit_class||'  '||'instructor_person_number:'||p_usec_teach_resp_tbl(I).instructor_person_number
	     ||'  '||'Status:'|| p_usec_teach_resp_tbl(I).status);
           END IF;

	END IF;


	--Business validations
	IF p_usec_teach_resp_tbl(I).status = 'S' THEN
	  Business_validation(p_usec_teach_resp_tbl(I));

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp.status_after_Business_validation',
	     'Unit code:'||p_usec_teach_resp_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_teach_resp_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_teach_resp_tbl(I).unit_class||'  '||'instructor_person_number:'||p_usec_teach_resp_tbl(I).instructor_person_number
	     ||'  '||'Status:'|| p_usec_teach_resp_tbl(I).status);
           END IF;
	END IF;

	IF p_usec_teach_resp_tbl(I).status = 'S' THEN

	   UPDATE IGS_PS_USEC_TCH_RESP SET
           confirmed_flag = p_usec_teach_resp_tbl(I).confirmed_flag ,
	   lead_instructor_flag = p_usec_teach_resp_tbl(I).lead_instructor_flag,
	   instructional_load = p_usec_teach_resp_tbl(I).instructional_load_other,
	   instructional_load_lab = p_usec_teach_resp_tbl(I).instructional_load_laboratory,
	   instructional_load_lecture = p_usec_teach_resp_tbl(I).instructional_load_lecture,
	   percentage_allocation = p_usec_teach_resp_tbl(I).wl_percentage_allocation,
	   last_updated_by = g_n_user_id ,
	   last_update_date = sysdate ,
	   last_update_login = g_n_login_id
	   WHERE uoo_id=l_n_uoo_id AND instructor_id=l_n_ins_id;

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp.Record_updated',
	     'Unit code:'||p_usec_teach_resp_tbl(I).unit_cd||'  '||'Version number:'||p_usec_teach_resp_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_teach_resp_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_teach_resp_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_teach_resp_tbl(I).unit_class||'  '||'instructor_person_number:'||p_usec_teach_resp_tbl(I).instructor_person_number);
           END IF;

	   v_tab_usec_sr(v_tab_usec_sr.count +1).uoo_id := l_n_uoo_id;
           v_tab_usec_sr(v_tab_usec_sr.count).instr_index := I;

	END IF;


	IF p_usec_teach_resp_tbl(I).status = 'S' THEN
	   p_usec_teach_resp_tbl(I).msg_from := NULL;
	   p_usec_teach_resp_tbl(I).msg_to := NULL;
	ELSIF  p_usec_teach_resp_tbl(I).status = 'A' THEN
	   p_usec_teach_resp_tbl(I).msg_from  := p_usec_teach_resp_tbl(I).msg_from + 1;
	   p_usec_teach_resp_tbl(I).msg_to := fnd_msg_pub.count_msg;
	ELSE
	   p_c_rec_status := p_usec_teach_resp_tbl(I).status;
	   p_usec_teach_resp_tbl(I).msg_from := p_usec_teach_resp_tbl(I).msg_from+1;
	   p_usec_teach_resp_tbl(I).msg_to := fnd_msg_pub.count_msg;
	   IF p_usec_teach_resp_tbl(I).status = 'E' THEN
	      RETURN;
	   END IF;
	END IF;

     END IF;
  END LOOP;

  IF NOT post_uso_resp_busi(p_usec_teach_resp_tbl) THEN
	  p_c_rec_status :=  'E';
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_teach_resp.after_import_status',p_c_rec_status);
  END IF;

END create_usec_teach_resp;


PROCEDURE create_usec_sp_fee(p_usec_sp_fee_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_sp_fee_tbl_type
                             ,p_c_rec_status OUT NOCOPY VARCHAR2
			     ,p_calling_context IN VARCHAR2) IS
/***********************************************************************************************

Created By:         sarakshi
Date Created By:    31-May-2005
Purpose:            This procedure imports unit section special Fees.

Known limitations,enhancements,remarks:
Change History
Who        When          What
abshriva  12-May-2006   Bug #5217319, added the call to precision method to get the correct precision value
                       on insert and update, removed the hard coded format checks.
sommukhe   18-Jan-2006  Bug#4926548, modified cursorc_fee_type_exists to address the performance issue.
                        Created local procedures and functions.
***********************************************************************************************/
    l_c_cal_type    igs_ca_inst_all.cal_type%TYPE;
    l_n_seq_num     igs_ca_inst_all.sequence_number%TYPE;
    l_n_uoo_id      igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_insert_update  VARCHAR2(1);

    PROCEDURE trim_values ( p_usec_sp_fee_rec IN OUT NOCOPY igs_ps_generic_pub.usec_sp_fee_rec_type) AS
    BEGIN

      p_usec_sp_fee_rec.unit_cd := TRIM(p_usec_sp_fee_rec.unit_cd);
      p_usec_sp_fee_rec.version_number := TRIM(p_usec_sp_fee_rec.version_number);
      p_usec_sp_fee_rec.teach_cal_alternate_code := TRIM(p_usec_sp_fee_rec.teach_cal_alternate_code);
      p_usec_sp_fee_rec.location_cd := TRIM(p_usec_sp_fee_rec.location_cd);
      p_usec_sp_fee_rec.unit_class := TRIM(p_usec_sp_fee_rec.unit_class);
      p_usec_sp_fee_rec.fee_type := TRIM(p_usec_sp_fee_rec.fee_type);
      p_usec_sp_fee_rec.sp_fee_amt := TRIM(p_usec_sp_fee_rec.sp_fee_amt);
      p_usec_sp_fee_rec.closed_flag := TRIM(p_usec_sp_fee_rec.closed_flag);

    END trim_values;

    PROCEDURE validate_parameters(p_usec_sp_fee_rec IN OUT NOCOPY igs_ps_generic_pub.usec_sp_fee_rec_type) AS

    BEGIN
      p_usec_sp_fee_rec.status:='S';


      IF p_usec_sp_fee_rec.unit_cd IS NULL OR p_usec_sp_fee_rec.unit_cd = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CD','LEGACY_TOKENS',FALSE);
         p_usec_sp_fee_rec.status := 'E';
      END IF;

      IF p_usec_sp_fee_rec.version_number IS NULL OR p_usec_sp_fee_rec.version_number = FND_API.G_MISS_NUM THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_VER_NUM','LEGACY_TOKENS',FALSE);
         p_usec_sp_fee_rec.status := 'E';
      END IF;

      IF p_usec_sp_fee_rec.teach_cal_alternate_code IS NULL OR p_usec_sp_fee_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS',FALSE);
	 p_usec_sp_fee_rec.status := 'E';
      END IF;

      IF p_usec_sp_fee_rec.location_cd IS NULL OR p_usec_sp_fee_rec.location_cd = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD','LEGACY_TOKENS',FALSE);
	 p_usec_sp_fee_rec.status := 'E';
      END IF;

      IF p_usec_sp_fee_rec.unit_class IS NULL OR p_usec_sp_fee_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CLASS','LEGACY_TOKENS',FALSE);
	p_usec_sp_fee_rec.status := 'E';
      END IF;

      IF p_usec_sp_fee_rec.fee_type IS NULL OR p_usec_sp_fee_rec.fee_type = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','FEE_TYPE','IGS_FI_LOCKBOX',FALSE);
	p_usec_sp_fee_rec.status := 'E';
      END IF;

      IF p_usec_sp_fee_rec.sp_fee_amt IS NULL OR p_usec_sp_fee_rec.sp_fee_amt = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','FEE_AMOUNT','LEGACY_TOKENS',FALSE);
	p_usec_sp_fee_rec.status := 'E';
      END IF;

    END validate_parameters;

    PROCEDURE validate_derivation(p_usec_sp_fee_rec IN OUT NOCOPY igs_ps_generic_pub.usec_sp_fee_rec_type) AS

      l_d_start       igs_ca_inst_all.start_dt%TYPE;
      l_d_end         igs_ca_inst_all.end_dt%TYPE;
      l_c_ret_status  VARCHAR2(30);

    BEGIN

       -- Deriving the Calendar Type and Calendar Sequence Number
       igs_ge_gen_003.get_calendar_instance(p_usec_sp_fee_rec.teach_cal_alternate_code,'''TEACHING''',  l_c_cal_type, l_n_seq_num, l_d_start, l_d_end, l_c_ret_status);
       IF l_c_ret_status <> 'SINGLE' THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS', FALSE);
	   p_usec_sp_fee_rec.status := 'E';
       END IF;

       -- Deriving the Unit Offering Option Identifier
       l_c_ret_status := NULL;
       igs_ps_validate_lgcy_pkg.get_uoo_id(p_usec_sp_fee_rec.unit_cd, p_usec_sp_fee_rec.version_number, l_c_cal_type, l_n_seq_num, p_usec_sp_fee_rec.location_cd, p_usec_sp_fee_rec.unit_class, l_n_uoo_id, l_c_ret_status);
       IF l_c_ret_status IS NOT NULL THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','UNIT_SECTION','LEGACY_TOKENS', FALSE);
	  p_usec_sp_fee_rec.status := 'E';
       END IF;

    END validate_derivation;

    PROCEDURE validate_db_cons(p_usec_sp_fee_rec IN OUT NOCOPY igs_ps_generic_pub.usec_sp_fee_rec_type,p_insert_update IN VARCHAR2) AS

    BEGIN

      IF p_insert_update = 'I' THEN
	/* Unique Key Validation */
	IF igs_ps_usec_sp_fees_pkg.get_uk_for_validation (  x_fee_type => p_usec_sp_fee_rec.fee_type,
							    x_uoo_id => l_n_uoo_id ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'FEE_TYPE', 'IGS_FI_LOCKBOX', FALSE);
	  p_usec_sp_fee_rec.status := 'W';
	  RETURN;
	END IF;
      END IF;

      -- Check Constraints
      BEGIN
        igs_ps_unit_ver_pkg.check_constraints( 'UNIT_CD',p_usec_sp_fee_rec.unit_cd);
      EXCEPTION
        WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE','UNIT_CD','LEGACY_TOKENS',TRUE);
            p_usec_sp_fee_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('VERSION_NUMBER',p_usec_sp_fee_rec.version_number);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VER_NUM_1_999',NULL,NULL,TRUE);
          p_usec_sp_fee_rec.status :='E';
      END;

      BEGIN
          igs_ps_usec_sp_fees_pkg.check_constraints('CLOSED_FLAG', p_usec_sp_fee_rec.closed_flag);
      EXCEPTION
          WHEN OTHERS THEN
             igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','CLOSED_FLAG','LEGACY_TOKENS',TRUE);
             p_usec_sp_fee_rec.status :='E';
      END;

      BEGIN
         igs_ps_usec_sp_fees_pkg.check_constraints('SP_FEE_AMT', p_usec_sp_fee_rec.sp_fee_amt);
      EXCEPTION
         WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_9999D99','FEE_AMOUNT','LEGACY_TOKENS',TRUE);
            p_usec_sp_fee_rec.status :='E';
      END;


      -- Foreign Key Checking

      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation (l_n_uoo_id ) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
         p_usec_sp_fee_rec.status := 'E';
      END IF;

      IF NOT igs_fi_fee_type_pkg.get_pk_for_validation (p_usec_sp_fee_rec.fee_type ) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'FEE_TYPE', 'IGS_FI_LOCKBOX', FALSE);
         p_usec_sp_fee_rec.status := 'E';
      END IF;

    END validate_db_cons;

    -- Check for Update/Insert
    FUNCTION check_insert_update ( p_usec_sp_fee_rec IN OUT NOCOPY igs_ps_generic_pub.usec_sp_fee_rec_type) RETURN VARCHAR2 IS

      CURSOR c_sp_fee IS
      SELECT 'X'
      FROM  igs_ps_usec_sp_fees
      WHERE uoo_id = l_n_uoo_id
      AND   fee_type =p_usec_sp_fee_rec.fee_type;

      l_c_sp_fee c_sp_fee%ROWTYPE;

    BEGIN

       OPEN c_sp_fee;
       FETCH c_sp_fee INTO l_c_sp_fee;
       IF c_sp_fee%FOUND THEN
	 CLOSE c_sp_fee;
	 RETURN 'U';
       ELSE
	 CLOSE c_sp_fee;
	 RETURN 'I';
       END IF;

    END check_insert_update;

    PROCEDURE Assign_default(p_usec_sp_fee_rec IN OUT NOCOPY igs_ps_generic_pub.usec_sp_fee_rec_type,p_insert_update IN VARCHAR2) AS
      CURSOR cur_sp_fees(cp_n_uoo_id IN NUMBER,cp_c_fee_type IN VARCHAR2) IS
      SELECT *
      FROM   igs_ps_usec_sp_fees
      WHERE  uoo_id = cp_n_uoo_id
      AND    fee_type = cp_c_fee_type;

      l_cur_sp_fees cur_sp_fees%ROWTYPE;

    BEGIN
       IF p_insert_update = 'I' THEN

         IF p_usec_sp_fee_rec.closed_flag IS NULL THEN
           p_usec_sp_fee_rec.closed_flag := 'N';
	 END IF;

       ELSE

         OPEN cur_sp_fees(l_n_uoo_id,p_usec_sp_fee_rec.fee_type);
         FETCH cur_sp_fees into l_cur_sp_fees;
         CLOSE cur_sp_fees;

 	 IF p_usec_sp_fee_rec.closed_flag IS NULL THEN
	   p_usec_sp_fee_rec.closed_flag  := l_cur_sp_fees.closed_flag;
         ELSIF p_usec_sp_fee_rec.closed_flag = FND_API.G_MISS_CHAR THEN
	   p_usec_sp_fee_rec.closed_flag  := 'N';
	 END IF;

       END IF;

    END Assign_default;

    PROCEDURE Business_validation(p_usec_sp_fee_rec IN OUT NOCOPY igs_ps_generic_pub.usec_sp_fee_rec_type,p_insert_update IN VARCHAR2) AS

      CURSOR c_fee_type_exists(cp_source_fee_type      igs_fi_fee_type.fee_type%TYPE) IS
      SELECT ci.cal_type cal_type,ci.sequence_number sequence_number
      FROM  igs_fi_fee_type ft,
            igs_fi_f_typ_ca_inst ftci,
	    igs_ca_inst ci,
	    igs_ca_type ct,
	    igs_ca_stat cs
      WHERE ft.s_fee_type = 'SPECIAL'
      AND   ft.closed_ind = 'N'
      AND   ft.fee_type = ftci.fee_type
      AND   ft.fee_type = cp_source_fee_type
      AND   ftci.fee_cal_type = ci.cal_type
      AND   ftci.fee_ci_sequence_number = ci.sequence_number
      AND   ci.cal_type = ct.cal_type
      AND   ct.s_cal_cat = 'FEE'
      AND   ci.cal_status = cs.cal_status
      AND   cs.s_cal_status = 'ACTIVE' ;

      c_fee_type_exists_rec c_fee_type_exists%ROWTYPE;

      l_message_name VARCHAR2(30);
      l_c_var VARCHAR2(1);

      TYPE teach_cal_rec IS RECORD(
				 cal_type igs_ca_inst_all.cal_type%TYPE,
				 sequence_number igs_ca_inst_all.sequence_number%TYPE
				 );
      TYPE teachCalendar IS TABLE OF teach_cal_rec INDEX BY BINARY_INTEGER;
      teachCalendar_tbl teachCalendar;
      l_n_counter NUMBER(10);
      l_c_proceed BOOLEAN ;


      PROCEDURE createCalendar  IS

      CURSOR cur_cal_teach(cp_load_cal igs_ca_teach_to_load_v.load_cal_type%TYPE,
			   cp_load_seq igs_ca_teach_to_load_v.load_ci_sequence_number%TYPE) IS
      SELECT sup_cal_type,sup_ci_sequence_number
      FROM   igs_ca_inst_rel
      WHERE sub_cal_type = cp_load_cal
      AND sub_ci_sequence_number = cp_load_seq;

      CURSOR cur_cal_load IS
      SELECT load_cal_type,load_ci_sequence_number
      FROM   igs_ca_teach_to_load_v
      WHERE  teach_cal_type=l_c_cal_type
      AND    teach_ci_sequence_number=l_n_seq_num;

      BEGIN
	 --populate the pl-sql table with the superior calendar's by mapping the teach calendars.
	 l_n_counter :=1;
	 FOR rec_cur_cal_load IN cur_cal_load LOOP
	     FOR rec_cur_cal_teach IN cur_cal_teach(rec_cur_cal_load.load_cal_type ,rec_cur_cal_load.load_ci_sequence_number) LOOP
		teachCalendar_tbl(l_n_counter).cal_type :=rec_cur_cal_teach.sup_cal_type;
		teachCalendar_tbl(l_n_counter).sequence_number :=rec_cur_cal_teach.sup_ci_sequence_number;
		l_n_counter:=l_n_counter+1;
	     END LOOP;
	 END LOOP;

      END createCalendar;

      FUNCTION testCalendar(cp_cal_type igs_ca_inst_all.cal_type%TYPE,
			    cp_sequence_number igs_ca_inst_all.sequence_number%TYPE)  RETURN BOOLEAN AS
      BEGIN
	IF teachCalendar_tbl.EXISTS(1) THEN
	  FOR i IN 1..teachCalendar_tbl.last LOOP
	       IF cp_cal_type=teachCalendar_tbl(i).cal_type AND
		  cp_sequence_number=teachCalendar_tbl(i).sequence_number THEN
		  RETURN TRUE;
	       END IF;
	  END LOOP;
	END IF;
	RETURN FALSE;
      END testCalendar;


    BEGIN

    --Store the superior calendars in a pl-sql tables for the input teaching calendars
    createCalendar;
      --Check if the unit is INACTIVE, then do not allow to import
      IF igs_ps_val_unit.crsp_val_iud_uv_dtl(p_usec_sp_fee_rec.unit_cd, p_usec_sp_fee_rec.version_number,l_message_name)=FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
	    fnd_msg_pub.add;
	    p_usec_sp_fee_rec.status := 'E';
      END IF;

      --If enrollment exists for this unit section then insert/update
      IF igs_ps_gen_003.enrollment_for_uoo_check(l_n_uoo_id) = TRUE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_US_FEE_TYP_USED_ENROLL' );
	    fnd_msg_pub.add;
	    p_usec_sp_fee_rec.status := 'E';
      END IF;

      IF p_insert_update = 'I' THEN
	l_c_proceed:= FALSE;
	  FOR rec_c_fee_type_exists IN c_fee_type_exists(p_usec_sp_fee_rec.fee_type) LOOP
	    IF testCalendar(rec_c_fee_type_exists.cal_type ,rec_c_fee_type_exists.sequence_number ) THEN
	      l_c_proceed:= TRUE;
	      EXIT;
	    END IF;
          END LOOP;

	  IF l_c_proceed = FALSE THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'FEE_TYPE', 'IGS_FI_LOCKBOX', FALSE);
	    p_usec_sp_fee_rec.status := 'E';
	  END IF;
      END IF;

    IF teachCalendar_tbl.EXISTS(1) THEN
      teachCalendar_tbl.DELETE;
    END IF;


    END Business_validation;

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_sp_fee.start_logging_for',
                    'Unit Section Special Fees');
  END IF;

  p_c_rec_status := 'S';
  FOR I in 1..p_usec_sp_fee_tbl.LAST LOOP
     IF p_usec_sp_fee_tbl.EXISTS(I) THEN
	-- Initialize the variable use to store the derived values.
	l_n_uoo_id  := NULL;
	l_c_cal_type:= NULL;
	l_n_seq_num := NULL;
	p_usec_sp_fee_tbl(I).status := 'S';
	p_usec_sp_fee_tbl(I).msg_from := fnd_msg_pub.count_msg;
	trim_values(p_usec_sp_fee_tbl(I));
	validate_parameters(p_usec_sp_fee_tbl(I));

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_sp_fee.status_after_validate_parameters',
	  'Unit code:'||p_usec_sp_fee_tbl(I).unit_cd||'  '||'Version number:'||p_usec_sp_fee_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_sp_fee_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_sp_fee_tbl(I).location_cd||'  '||'Unit Class:'||
	  p_usec_sp_fee_tbl(I).unit_class||'  '||'Fee type:'||p_usec_sp_fee_tbl(I).fee_type||'  '||'Status:'||
	  p_usec_sp_fee_tbl(I).status);
        END IF;

	IF p_usec_sp_fee_tbl(I).status = 'S' THEN
	   validate_derivation(p_usec_sp_fee_tbl(I));

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_sp_fee.status_after_validate_derivation',
	     'Unit code:'||p_usec_sp_fee_tbl(I).unit_cd||'  '||'Version number:'||p_usec_sp_fee_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_sp_fee_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_sp_fee_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_sp_fee_tbl(I).unit_class||'  '||'Fee type:'||p_usec_sp_fee_tbl(I).fee_type
	     ||'  '||'Status:'||p_usec_sp_fee_tbl(I).status);
           END IF;

	END IF;

	--Find out whether it is insert/update of record
	l_insert_update:='I';
	IF p_usec_sp_fee_tbl(I).status = 'S' AND p_calling_context IN ('G','S') THEN
	  l_insert_update:= check_insert_update(p_usec_sp_fee_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_sp_fee.status_after_check_insert_update',
	     'Unit code:'||p_usec_sp_fee_tbl(I).unit_cd||'  '||'Version number:'||p_usec_sp_fee_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_sp_fee_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_sp_fee_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_sp_fee_tbl(I).unit_class||'  '||'Fee type:'||p_usec_sp_fee_tbl(I).fee_type
	     ||'  '||'Status:'||p_usec_sp_fee_tbl(I).status);
           END IF;

	END IF;

	IF p_usec_sp_fee_tbl(I).status = 'S' AND p_calling_context = 'S' THEN
	  IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	    fnd_msg_pub.add;
	    p_usec_sp_fee_tbl(I).status := 'A';
	  END IF;

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_sp_fee.status_after_check_import_allowed',
	     'Unit code:'||p_usec_sp_fee_tbl(I).unit_cd||'  '||'Version number:'||p_usec_sp_fee_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_sp_fee_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_sp_fee_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_sp_fee_tbl(I).unit_class||'  '||'Fee type:'||p_usec_sp_fee_tbl(I).fee_type
	     ||'  '||'Status:'||p_usec_sp_fee_tbl(I).status);
          END IF;

	END IF;


	IF p_usec_sp_fee_tbl(I).status = 'S' THEN
	   Assign_default(p_usec_sp_fee_tbl(I),l_insert_update);

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_sp_fee.status_after_Assign_default',
	     'Unit code:'||p_usec_sp_fee_tbl(I).unit_cd||'  '||'Version number:'||p_usec_sp_fee_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_sp_fee_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_sp_fee_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_sp_fee_tbl(I).unit_class||'  '||'Fee type:'||p_usec_sp_fee_tbl(I).fee_type
	     ||'  '||'Status:'||p_usec_sp_fee_tbl(I).status);
           END IF;

	END IF;

	IF p_usec_sp_fee_tbl(I).status = 'S' THEN
	   validate_db_cons ( p_usec_sp_fee_tbl(I),l_insert_update);

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_sp_fee.status_after_validate_db_cons',
	     'Unit code:'||p_usec_sp_fee_tbl(I).unit_cd||'  '||'Version number:'||p_usec_sp_fee_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_sp_fee_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_sp_fee_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_sp_fee_tbl(I).unit_class||'  '||'Fee type:'||p_usec_sp_fee_tbl(I).fee_type
	     ||'  '||'Status:'||p_usec_sp_fee_tbl(I).status);
           END IF;

	END IF;


	--Business validations
	IF p_usec_sp_fee_tbl(I).status = 'S' THEN
	  Business_validation(p_usec_sp_fee_tbl(I),l_insert_update);

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_sp_fee.status_after_Business_validation',
	     'Unit code:'||p_usec_sp_fee_tbl(I).unit_cd||'  '||'Version number:'||p_usec_sp_fee_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_sp_fee_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_sp_fee_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_sp_fee_tbl(I).unit_class||'  '||'Fee type:'||p_usec_sp_fee_tbl(I).fee_type
	     ||'  '||'Status:'||p_usec_sp_fee_tbl(I).status);
           END IF;

	END IF;

	IF p_usec_sp_fee_tbl(I).status = 'S' THEN
          p_usec_sp_fee_tbl(I).sp_fee_amt :=igs_fi_gen_gl.get_formatted_amount(p_usec_sp_fee_tbl(I).sp_fee_amt);
          IF l_insert_update = 'I' THEN
	    INSERT INTO IGS_PS_USEC_SP_FEES(
	      USEC_SP_FEES_ID,
	      UOO_ID,
	      FEE_TYPE,
	      SP_FEE_AMT,
	      CLOSED_FLAG,
	      CREATED_BY,
	      CREATION_DATE,
	      LAST_UPDATED_BY,
	      LAST_UPDATE_DATE,
	      LAST_UPDATE_LOGIN )
	    VALUES (
	       igs_ps_usec_sp_fees_s.NEXTVAL,
	       l_n_uoo_id,
	       p_usec_sp_fee_tbl(I).fee_type,
	       p_usec_sp_fee_tbl(I).sp_fee_amt,
	       p_usec_sp_fee_tbl(I).closed_flag,
	       g_n_user_id,
	       SYSDATE,
	       g_n_user_id,
	       SYSDATE,
	       g_n_login_id);

               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		 fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_sp_fee.Record_Inserted',
		 'Unit code:'||p_usec_sp_fee_tbl(I).unit_cd||'  '||'Version number:'||p_usec_sp_fee_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		 ||p_usec_sp_fee_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_sp_fee_tbl(I).location_cd||'  '||'Unit Class:'||
		 p_usec_sp_fee_tbl(I).unit_class||'  '||'Fee type:'||p_usec_sp_fee_tbl(I).fee_type);
               END IF;

          ELSE
            UPDATE IGS_PS_USEC_SP_FEES SET
            SP_FEE_AMT = p_usec_sp_fee_tbl(I).sp_fee_amt,
            CLOSED_FLAG = p_usec_sp_fee_tbl(I).closed_flag,
	    last_updated_by = g_n_user_id ,
	    last_update_date = sysdate ,
	    last_update_login = g_n_login_id
	    WHERE uoo_id=l_n_uoo_id AND fee_type=p_usec_sp_fee_tbl(I).fee_type;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	       fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_sp_fee.Record_Updated',
	       'Unit code:'||p_usec_sp_fee_tbl(I).unit_cd||'  '||'Version number:'||p_usec_sp_fee_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	       ||p_usec_sp_fee_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_sp_fee_tbl(I).location_cd||'  '||'Unit Class:'||
	       p_usec_sp_fee_tbl(I).unit_class||'  '||'Fee type:'||p_usec_sp_fee_tbl(I).fee_type);
            END IF;

          END IF;

	END IF;


	IF p_usec_sp_fee_tbl(I).status = 'S' THEN
	   p_usec_sp_fee_tbl(I).msg_from := NULL;
	   p_usec_sp_fee_tbl(I).msg_to := NULL;
	ELSIF  p_usec_sp_fee_tbl(I).status = 'A' THEN
	   p_usec_sp_fee_tbl(I).msg_from  := p_usec_sp_fee_tbl(I).msg_from + 1;
	   p_usec_sp_fee_tbl(I).msg_to := fnd_msg_pub.count_msg;
	ELSE
	   p_c_rec_status := p_usec_sp_fee_tbl(I).status;
	   p_usec_sp_fee_tbl(I).msg_from := p_usec_sp_fee_tbl(I).msg_from+1;
	   p_usec_sp_fee_tbl(I).msg_to := fnd_msg_pub.count_msg;
	   IF p_usec_sp_fee_tbl(I).status = 'E' THEN
	      RETURN;
	   END IF;
	END IF;

     END IF;
  END LOOP;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_sp_fee.after_import_status',p_c_rec_status);
  END IF;


END create_usec_sp_fee;

PROCEDURE create_usec_plus_hr(p_usec_plus_hr_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_plus_hr_tbl_type
                              ,p_c_rec_status OUT NOCOPY VARCHAR2
 			      ,p_calling_context IN VARCHAR2) IS
/***********************************************************************************************

Created By:         sarakshi
Date Created By:    01-Jun-2005
Purpose:            This procedure imports unit section Plus Hours.

Known limitations,enhancements,remarks:
Change History
Who       When         What
***********************************************************************************************/

	l_n_uoo_id      NUMBER;
        l_n_activity_id NUMBER;
        l_n_building_id NUMBER;
        l_n_room_id     NUMBER;
        l_n_ins_id      NUMBER;
        l_insert_update VARCHAR2(1);

    PROCEDURE trim_values ( p_usec_plus_hr_rec IN OUT NOCOPY igs_ps_generic_pub.usec_plus_hr_rec_type) AS
    BEGIN

      p_usec_plus_hr_rec.unit_cd := TRIM(p_usec_plus_hr_rec.unit_cd);
      p_usec_plus_hr_rec.version_number := TRIM(p_usec_plus_hr_rec.version_number);
      p_usec_plus_hr_rec.teach_cal_alternate_code := TRIM(p_usec_plus_hr_rec.teach_cal_alternate_code);
      p_usec_plus_hr_rec.location_cd := TRIM(p_usec_plus_hr_rec.location_cd);
      p_usec_plus_hr_rec.unit_class := TRIM(p_usec_plus_hr_rec.unit_class);
      p_usec_plus_hr_rec.activity_type_code := TRIM(p_usec_plus_hr_rec.activity_type_code);
      p_usec_plus_hr_rec.activity_location_cd := TRIM(p_usec_plus_hr_rec.activity_location_cd);
      p_usec_plus_hr_rec.building_cd := TRIM(p_usec_plus_hr_rec.building_cd);
      p_usec_plus_hr_rec.room_cd := TRIM(p_usec_plus_hr_rec.room_cd);
      p_usec_plus_hr_rec.number_of_students := TRIM(p_usec_plus_hr_rec.number_of_students);
      p_usec_plus_hr_rec.hours_per_student := TRIM(p_usec_plus_hr_rec.hours_per_student);
      p_usec_plus_hr_rec.hours_per_faculty := TRIM(p_usec_plus_hr_rec.hours_per_faculty);
      p_usec_plus_hr_rec.instructor_number := TRIM(p_usec_plus_hr_rec.instructor_number);

    END trim_values;

    PROCEDURE validate_parameters(p_usec_plus_hr_rec IN OUT NOCOPY igs_ps_generic_pub.usec_plus_hr_rec_type) AS

    BEGIN
      p_usec_plus_hr_rec.status:='S';


      IF p_usec_plus_hr_rec.unit_cd IS NULL OR p_usec_plus_hr_rec.unit_cd = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CD','LEGACY_TOKENS',FALSE);
         p_usec_plus_hr_rec.status := 'E';
      END IF;

      IF p_usec_plus_hr_rec.version_number IS NULL OR p_usec_plus_hr_rec.version_number = FND_API.G_MISS_NUM THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_VER_NUM','LEGACY_TOKENS',FALSE);
         p_usec_plus_hr_rec.status := 'E';
      END IF;

      IF p_usec_plus_hr_rec.teach_cal_alternate_code IS NULL OR p_usec_plus_hr_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS',FALSE);
	 p_usec_plus_hr_rec.status := 'E';
      END IF;

      IF p_usec_plus_hr_rec.location_cd IS NULL OR p_usec_plus_hr_rec.location_cd = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD','LEGACY_TOKENS',FALSE);
	 p_usec_plus_hr_rec.status := 'E';
      END IF;

      IF p_usec_plus_hr_rec.unit_class IS NULL OR p_usec_plus_hr_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CLASS','LEGACY_TOKENS',FALSE);
	p_usec_plus_hr_rec.status := 'E';
      END IF;

      IF p_usec_plus_hr_rec.activity_type_code IS NULL OR p_usec_plus_hr_rec.activity_type_code = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','ACTIVITY_TYPE_CODE','LEGACY_TOKENS',FALSE);
	p_usec_plus_hr_rec.status := 'E';
      END IF;

      IF p_usec_plus_hr_rec.activity_location_cd IS NULL OR p_usec_plus_hr_rec.activity_location_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','ACTIVITY_LOCATION_CD','LEGACY_TOKENS',FALSE);
	p_usec_plus_hr_rec.status := 'E';
      END IF;

      IF p_usec_plus_hr_rec.building_cd IS NULL OR p_usec_plus_hr_rec.building_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','BUILDING_CODE','LEGACY_TOKENS',FALSE);
	p_usec_plus_hr_rec.status := 'E';
      END IF;

      IF p_usec_plus_hr_rec.room_cd IS NULL OR p_usec_plus_hr_rec.room_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','ROOM_CODE','LEGACY_TOKENS',FALSE);
	p_usec_plus_hr_rec.status := 'E';
      END IF;

      IF p_usec_plus_hr_rec.number_of_students IS NULL OR p_usec_plus_hr_rec.number_of_students = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','NUMBER_OF_STUDENTS','LEGACY_TOKENS',FALSE);
	p_usec_plus_hr_rec.status := 'E';
      END IF;

      IF p_usec_plus_hr_rec.hours_per_student IS NULL OR p_usec_plus_hr_rec.hours_per_student = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','HOURS_PER_STUDENT','LEGACY_TOKENS',FALSE);
	p_usec_plus_hr_rec.status := 'E';
      END IF;

      IF p_usec_plus_hr_rec.hours_per_faculty IS NULL OR p_usec_plus_hr_rec.hours_per_faculty = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','HOURS_PER_FACULTY','LEGACY_TOKENS',FALSE);
	p_usec_plus_hr_rec.status := 'E';
      END IF;


    END validate_parameters;

    PROCEDURE validate_derivation(p_usec_plus_hr_rec IN OUT NOCOPY igs_ps_generic_pub.usec_plus_hr_rec_type) AS
      l_c_cal_type    VARCHAR2(10);
      l_n_seq_num     NUMBER;
      l_d_start       igs_ca_inst_all.start_dt%TYPE;
      l_d_end         igs_ca_inst_all.end_dt%TYPE;
      l_c_ret_status  VARCHAR2(30);

      CURSOR cur_activity_cd(cp_activity_type_code IN VARCHAR2) IS
      SELECT activity_type_id
      FROM   igs_ps_usec_act_type
      WHERE activity_type_code=cp_activity_type_code;

      CURSOR cur_building(cp_location_cd IN VARCHAR2,cp_building_code IN VARCHAR2) IS
      SELECT building_id
      FROM   igs_ad_building
      WHERE  location_cd = cp_location_cd
      AND    building_cd=cp_building_code;

      CURSOR cur_room(cp_building_id IN VARCHAR2,cp_room_cd IN VARCHAR2) IS
      SELECT room_id
      FROM   igs_ad_room
      WHERE  building_id=cp_building_id
      AND    room_cd= cp_room_cd;

    BEGIN

       -- Deriving the Calendar Type and Calendar Sequence Number
       igs_ge_gen_003.get_calendar_instance(p_usec_plus_hr_rec.teach_cal_alternate_code,'''TEACHING''',  l_c_cal_type, l_n_seq_num, l_d_start, l_d_end, l_c_ret_status);
       IF l_c_ret_status <> 'SINGLE' THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS', FALSE);
	   p_usec_plus_hr_rec.status := 'E';
       END IF;

       -- Deriving the Unit Offering Option Identifier
       l_c_ret_status := NULL;
       igs_ps_validate_lgcy_pkg.get_uoo_id(p_usec_plus_hr_rec.unit_cd, p_usec_plus_hr_rec.version_number, l_c_cal_type, l_n_seq_num, p_usec_plus_hr_rec.location_cd, p_usec_plus_hr_rec.unit_class, l_n_uoo_id, l_c_ret_status);
       IF l_c_ret_status IS NOT NULL THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','UNIT_SECTION','LEGACY_TOKENS', FALSE);
	  p_usec_plus_hr_rec.status := 'E';
       END IF;

       --Derive the activity id
       OPEN cur_activity_cd(p_usec_plus_hr_rec.activity_type_code);
       FETCH cur_activity_cd INTO l_n_activity_id;
       CLOSE cur_activity_cd;

       --Derive the building code
       OPEN cur_building(p_usec_plus_hr_rec.activity_location_cd,p_usec_plus_hr_rec.building_cd);
       FETCH cur_building INTO l_n_building_id;
       IF cur_building%NOTFOUND THEN
	     igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','BUILDING_CODE' ,'LEGACY_TOKENS', FALSE);
	     p_usec_plus_hr_rec.status := 'E';
       END IF;
       CLOSE cur_building;

       --Derive the room code
       OPEN cur_room(l_n_building_id,p_usec_plus_hr_rec.room_cd);
       FETCH cur_room INTO l_n_room_id;
       IF cur_room%NOTFOUND THEN
	     igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','ROOM_CODE' ,'LEGACY_TOKENS', FALSE);
	     p_usec_plus_hr_rec.status := 'E';
       END IF;
       CLOSE cur_room;

       -- Derive the Instructor identifier
       IF p_usec_plus_hr_rec.instructor_number IS NOT NULL AND p_usec_plus_hr_rec.instructor_number <> FND_API.G_MISS_CHAR THEN
	  igs_ps_validate_lgcy_pkg.get_party_id(p_usec_plus_hr_rec.instructor_number, l_n_ins_id);
	  IF l_n_ins_id IS NULL THEN
	     fnd_message.set_name('IGS','IGS_PS_INS_PERSON_NUMBER');
	     igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', fnd_message.get,NULL, FALSE);
	     p_usec_plus_hr_rec.status := 'E';
	  END IF;
       END IF;


    END validate_derivation;

    PROCEDURE validate_db_cons(p_usec_plus_hr_rec IN OUT NOCOPY igs_ps_generic_pub.usec_plus_hr_rec_type,p_insert_update IN VARCHAR2) AS

    BEGIN

      IF p_insert_update = 'I' THEN
	-- Unique Key Validation
	IF igs_ps_us_unsched_cl_pkg.get_uk_for_validation ( x_uoo_id           => l_n_uoo_id,
							    x_activity_type_id => l_n_activity_id,
							    x_location_cd      => p_usec_plus_hr_rec.activity_location_cd,
							    x_building_id      => l_n_building_id,
							    x_room_id          => l_n_room_id    ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'PLUS_HOUR', 'LEGACY_TOKENS', FALSE);
	  p_usec_plus_hr_rec.status := 'W';
	  RETURN;
	END IF;
      END IF;

      -- Check Constraints

      BEGIN
         igs_ps_us_unsched_cl_pkg.check_constraints('NUMBER_OF_STUDENTS', p_usec_plus_hr_rec.number_of_students);
      EXCEPTION
         WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_9999999999','NUMBER_OF_STUDENTS','LEGACY_TOKENS',TRUE);
            p_usec_plus_hr_rec.status :='E';
      END;

      BEGIN
         igs_ps_us_unsched_cl_pkg.check_constraints('HOURS_PER_STUDENT', p_usec_plus_hr_rec.hours_per_student);
      EXCEPTION
         WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D99','HOURS_PER_STUDENT','LEGACY_TOKENS',TRUE);
            p_usec_plus_hr_rec.status :='E';
      END;

      BEGIN
         igs_ps_us_unsched_cl_pkg.check_constraints('HOURS_PER_FACULTY', p_usec_plus_hr_rec.hours_per_faculty);
      EXCEPTION
         WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D99','HOURS_PER_FACULTY','LEGACY_TOKENS',TRUE);
            p_usec_plus_hr_rec.status :='E';
      END;

      -- Foreign Key Checking
      --Check for the existence of the unit section
      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation (l_n_uoo_id ) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
         p_usec_plus_hr_rec.status := 'E';
      END IF;

      -- Check for existence of Activity Code
      IF NOT  igs_ps_usec_act_type_pkg.get_pk_for_validation ( l_n_activity_id ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'ACTIVITY_TYPE_CODE', 'LEGACY_TOKENS', FALSE);
        p_usec_plus_hr_rec.status := 'E';
      END IF;

      -- Check for existence of Activity Location Code
      IF NOT igs_ad_location_pkg.get_pk_for_validation ( p_usec_plus_hr_rec.activity_location_cd ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'ACTIVITY_LOCATION_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_plus_hr_rec.status := 'E';
      END IF;

      -- Check for existence of Building Code Code
      IF NOT igs_ad_building_pkg.get_pk_for_validation ( l_n_building_id ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'BUILDING_CODE', 'LEGACY_TOKENS', FALSE);
        p_usec_plus_hr_rec.status := 'E';
      END IF;

      -- Check for existence of Room Code Code
      IF NOT igs_ad_room_pkg.get_pk_for_validation ( l_n_room_id ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'ROOM_CODE', 'LEGACY_TOKENS', FALSE);
        p_usec_plus_hr_rec.status := 'E';
      END IF;

      -- Check for existence of instructor number
      IF l_n_ins_id IS NOT NULL THEN
	IF NOT igs_pe_person_pkg.get_pk_for_validation(l_n_ins_id ) THEN
	   fnd_message.set_name('IGS','IGS_PS_INS_PERSON_NUMBER');
	   igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', fnd_message.get, NULL, FALSE);
	   p_usec_plus_hr_rec.status := 'E';
	END IF;
      END IF;

    END validate_db_cons;

    -- Check for Update/Insert
    FUNCTION check_insert_update ( p_usec_plus_hr_rec IN OUT NOCOPY igs_ps_generic_pub.usec_plus_hr_rec_type) RETURN VARCHAR2 IS

      CURSOR c_plus_hr IS
      SELECT 'X'
      FROM   igs_ps_us_unsched_cl
      WHERE  uoo_id =   l_n_uoo_id
      AND    activity_type_id = l_n_activity_id
      AND    location_cd = p_usec_plus_hr_rec.activity_location_cd
      AND    building_id = l_n_building_id
      AND    room_id = l_n_room_id;


      l_c_plus_hr c_plus_hr%ROWTYPE;

    BEGIN

       OPEN c_plus_hr;
       FETCH c_plus_hr INTO l_c_plus_hr;
       IF c_plus_hr%FOUND THEN
	 CLOSE c_plus_hr;
	 RETURN 'U';
       ELSE
	 CLOSE c_plus_hr;
	 RETURN 'I';
       END IF;

    END check_insert_update;

    PROCEDURE Assign_default(p_usec_plus_hr_rec IN OUT NOCOPY igs_ps_generic_pub.usec_plus_hr_rec_type,p_insert_update IN VARCHAR2) AS
      CURSOR cur_plus_hr IS
      SELECT *
      FROM   IGS_PS_US_UNSCHED_CL
      WHERE  uoo_id =   l_n_uoo_id
      AND    activity_type_id = l_n_activity_id
      AND    location_cd = p_usec_plus_hr_rec.activity_location_cd
      AND    building_id = l_n_building_id
      AND    room_id = l_n_room_id;

      l_cur_plus_hr cur_plus_hr%ROWTYPE;

    BEGIN
       IF p_insert_update = 'I' THEN

         IF p_usec_plus_hr_rec.instructor_number IS NULL THEN
           l_n_ins_id := NULL;
	 END IF;

       ELSE

         OPEN cur_plus_hr;
         FETCH cur_plus_hr INTO l_cur_plus_hr;
         CLOSE cur_plus_hr;

 	 IF p_usec_plus_hr_rec.instructor_number IS NULL THEN
	   l_n_ins_id := l_cur_plus_hr.instructor_id;
         ELSIF p_usec_plus_hr_rec.instructor_number = FND_API.G_MISS_CHAR THEN
	   l_n_ins_id  := NULL;
	 END IF;

       END IF;

    END Assign_default;

    PROCEDURE Business_validation(p_usec_plus_hr_rec IN OUT NOCOPY igs_ps_generic_pub.usec_plus_hr_rec_type) AS

      l_message_name VARCHAR2(30);
      l_preferred_name igs_pe_person.preferred_name%TYPE;
    BEGIN
      --Check if the unit is INACTIVE, then do not allow to import
      IF igs_ps_val_unit.crsp_val_iud_uv_dtl(p_usec_plus_hr_rec.unit_cd, p_usec_plus_hr_rec.version_number,l_message_name)=FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
	    fnd_msg_pub.add;
	    p_usec_plus_hr_rec.status := 'E';
      END IF;

      --Instructor should be staff
      IF l_n_ins_id IS NOT NULL THEN
	IF igs_ge_mnt_sdtt.pid_val_staff (p_person_id => l_n_ins_id,p_preferred_name=>l_preferred_name) = FALSE THEN
	       p_usec_plus_hr_rec.status :='E';
	       fnd_message.set_name('IGS','IGS_PS_INST_NOT_STAFF');
	       fnd_msg_pub.add;
	END IF;
      END IF;

    END Business_validation;


BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_plus_hr.start_logging_for',
                    'Unit Section Plus Hours');
  END IF;

  p_c_rec_status := 'S';
  FOR I in 1..p_usec_plus_hr_tbl.LAST LOOP
     IF p_usec_plus_hr_tbl.EXISTS(I) THEN
	-- Initialize the variable use to store the derived values.
	l_n_uoo_id      := NULL;
        l_n_activity_id := NULL;
        l_n_building_id := NULL;
        l_n_room_id     := NULL;
        l_n_ins_id      := NULL;

	p_usec_plus_hr_tbl(I).status := 'S';
	p_usec_plus_hr_tbl(I).msg_from := fnd_msg_pub.count_msg;
	trim_values(p_usec_plus_hr_tbl(I));
	validate_parameters(p_usec_plus_hr_tbl(I));

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_plus_hr.status_after_validate_parameters',
	  'Unit code:'||p_usec_plus_hr_tbl(I).unit_cd||'  '||'Version number:'||p_usec_plus_hr_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_plus_hr_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_plus_hr_tbl(I).location_cd||'  '||'Unit Class:'||
	  p_usec_plus_hr_tbl(I).unit_class||'  '||'Activity_type_code:'||p_usec_plus_hr_tbl(I).activity_type_code
	  ||'  '||'activity_location_cd:'||p_usec_plus_hr_tbl(I).activity_location_cd||'  '||'building_cd:'||p_usec_plus_hr_tbl(I).building_cd
	  ||'  '||'room_cd:'||p_usec_plus_hr_tbl(I).room_cd||'  '||'Status:'|| p_usec_plus_hr_tbl(I).status);
        END IF;

	IF p_usec_plus_hr_tbl(I).status = 'S' THEN
	   validate_derivation(p_usec_plus_hr_tbl(I));

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_plus_hr.status_after_validate_derivation',
	      'Unit code:'||p_usec_plus_hr_tbl(I).unit_cd||'  '||'Version number:'||p_usec_plus_hr_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_plus_hr_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_plus_hr_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_plus_hr_tbl(I).unit_class||'  '||'Activity_id:'||l_n_activity_id
	      ||'  '||'activity_location_cd:'||p_usec_plus_hr_tbl(I).activity_location_cd||'  '||'building_id:'||l_n_building_id
	      ||'  '||'room_id:'||l_n_room_id||'  '||'Status:'|| p_usec_plus_hr_tbl(I).status);
           END IF;

	END IF;

	--Find out whether it is insert/update of record
	l_insert_update:='I';
	IF p_usec_plus_hr_tbl(I).status = 'S' AND p_calling_context IN ('G','S') THEN
	  l_insert_update:= check_insert_update(p_usec_plus_hr_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_plus_hr.status_after_check_insert_update',
	    'Unit code:'||p_usec_plus_hr_tbl(I).unit_cd||'  '||'Version number:'||p_usec_plus_hr_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_plus_hr_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_plus_hr_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_plus_hr_tbl(I).unit_class||'  '||'Activity_id:'||l_n_activity_id
	    ||'  '||'activity_location_cd:'||p_usec_plus_hr_tbl(I).activity_location_cd||'  '||'building_id:'||l_n_building_id
	    ||'  '||'room_id:'||l_n_room_id||'  '||'Status:'|| p_usec_plus_hr_tbl(I).status);
          END IF;

	END IF;

	IF p_usec_plus_hr_tbl(I).status = 'S' AND p_calling_context = 'S' THEN
	  IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	    fnd_msg_pub.add;
	    p_usec_plus_hr_tbl(I).status := 'A';
	  END IF;

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_plus_hr.status_after_check_import_allowed',
	    'Unit code:'||p_usec_plus_hr_tbl(I).unit_cd||'  '||'Version number:'||p_usec_plus_hr_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_plus_hr_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_plus_hr_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_plus_hr_tbl(I).unit_class||'  '||'Activity_id:'||l_n_activity_id
	    ||'  '||'activity_location_cd:'||p_usec_plus_hr_tbl(I).activity_location_cd||'  '||'building_id:'||l_n_building_id
	    ||'  '||'room_id:'||l_n_room_id||'  '||'Status:'|| p_usec_plus_hr_tbl(I).status);
          END IF;

	END IF;

	IF p_usec_plus_hr_tbl(I).status = 'S' THEN
	   Assign_default(p_usec_plus_hr_tbl(I),l_insert_update);

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_plus_hr.status_after_Assign_default',
	      'Unit code:'||p_usec_plus_hr_tbl(I).unit_cd||'  '||'Version number:'||p_usec_plus_hr_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_plus_hr_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_plus_hr_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_plus_hr_tbl(I).unit_class||'  '||'Activity_id:'||l_n_activity_id
	      ||'  '||'activity_location_cd:'||p_usec_plus_hr_tbl(I).activity_location_cd||'  '||'building_id:'||l_n_building_id
	      ||'  '||'room_id:'||l_n_room_id||'  '||'Status:'|| p_usec_plus_hr_tbl(I).status);
            END IF;

	END IF;

	IF p_usec_plus_hr_tbl(I).status = 'S' THEN
	   validate_db_cons ( p_usec_plus_hr_tbl(I),l_insert_update);

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_plus_hr.status_after_validate_db_cons',
	      'Unit code:'||p_usec_plus_hr_tbl(I).unit_cd||'  '||'Version number:'||p_usec_plus_hr_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_plus_hr_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_plus_hr_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_plus_hr_tbl(I).unit_class||'  '||'Activity_id:'||l_n_activity_id
	      ||'  '||'activity_location_cd:'||p_usec_plus_hr_tbl(I).activity_location_cd||'  '||'building_id:'||l_n_building_id
	      ||'  '||'room_id:'||l_n_room_id||'  '||'Status:'|| p_usec_plus_hr_tbl(I).status);
            END IF;

	END IF;

	--Business validations
	IF p_usec_plus_hr_tbl(I).status = 'S' THEN
	  Business_validation(p_usec_plus_hr_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_plus_hr.status_after_Business_validation',
	    'Unit code:'||p_usec_plus_hr_tbl(I).unit_cd||'  '||'Version number:'||p_usec_plus_hr_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_plus_hr_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_plus_hr_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_plus_hr_tbl(I).unit_class||'  '||'Activity_id:'||l_n_activity_id
	    ||'  '||'activity_location_cd:'||p_usec_plus_hr_tbl(I).activity_location_cd||'  '||'building_id:'||l_n_building_id
	    ||'  '||'room_id:'||l_n_room_id||'  '||'Status:'|| p_usec_plus_hr_tbl(I).status);
          END IF;

	END IF;

	IF p_usec_plus_hr_tbl(I).status = 'S' THEN

          IF l_insert_update = 'I' THEN
	    INSERT INTO IGS_PS_US_UNSCHED_CL(
	      us_unscheduled_cl_id,
	      uoo_id,
	      activity_type_id,
	      location_cd,
	      building_id,
	      room_id,
	      number_of_students,
	      hours_per_student,
	      hours_per_faculty,
	      instructor_id,
	      created_by,
	      creation_date,
	      last_updated_by,
	      last_update_date,
	      last_update_login )
	    VALUES (
	       igs_ps_us_unsched_cl_s.NEXTVAL,
	       l_n_uoo_id,
	       l_n_activity_id,
       	       p_usec_plus_hr_tbl(I).activity_location_cd,
	       l_n_building_id,
	       l_n_room_id,
       	       p_usec_plus_hr_tbl(I).number_of_students,
	       p_usec_plus_hr_tbl(I).hours_per_student,
	       p_usec_plus_hr_tbl(I).hours_per_faculty,
	       l_n_ins_id,
	       g_n_user_id,
	       SYSDATE,
	       g_n_user_id,
	       SYSDATE,
	       g_n_login_id);


		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_plus_hr.Record_Inserted',
		  'Unit code:'||p_usec_plus_hr_tbl(I).unit_cd||'  '||'Version number:'||p_usec_plus_hr_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		  ||p_usec_plus_hr_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_plus_hr_tbl(I).location_cd||'  '||'Unit Class:'||
		  p_usec_plus_hr_tbl(I).unit_class||'  '||'Activity_id:'||l_n_activity_id
		  ||'  '||'activity_location_cd:'||p_usec_plus_hr_tbl(I).activity_location_cd||'  '||'building_id:'||l_n_building_id
		  ||'  '||'room_id:'||l_n_room_id);
		END IF;

          ELSE

            UPDATE IGS_PS_US_UNSCHED_CL SET
	    number_of_students = p_usec_plus_hr_tbl(I).number_of_students,
	    hours_per_student = p_usec_plus_hr_tbl(I).hours_per_student,
	    hours_per_faculty = p_usec_plus_hr_tbl(I).hours_per_faculty,
	    instructor_id = l_n_ins_id,
	    last_updated_by = g_n_user_id ,
	    last_update_date = sysdate ,
	    last_update_login = g_n_login_id
	    WHERE uoo_id=l_n_uoo_id AND activity_type_id=l_n_activity_id AND location_cd= p_usec_plus_hr_tbl(I).activity_location_cd
	    AND   building_id = l_n_building_id AND room_id = l_n_room_id;

	    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_plus_hr.Record_Updated',
	      'Unit code:'||p_usec_plus_hr_tbl(I).unit_cd||'  '||'Version number:'||p_usec_plus_hr_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_plus_hr_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_plus_hr_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_plus_hr_tbl(I).unit_class||'  '||'Activity_id:'||l_n_activity_id
	      ||'  '||'activity_location_cd:'||p_usec_plus_hr_tbl(I).activity_location_cd||'  '||'building_id:'||l_n_building_id
	      ||'  '||'room_id:'||l_n_room_id);
	   END IF;

          END IF;

	END IF;


	IF p_usec_plus_hr_tbl(I).status = 'S' THEN
	   p_usec_plus_hr_tbl(I).msg_from := NULL;
	   p_usec_plus_hr_tbl(I).msg_to := NULL;
	ELSIF  p_usec_plus_hr_tbl(I).status = 'A' THEN
	   p_usec_plus_hr_tbl(I).msg_from  := p_usec_plus_hr_tbl(I).msg_from + 1;
	   p_usec_plus_hr_tbl(I).msg_to := fnd_msg_pub.count_msg;
	ELSE
	   p_c_rec_status := p_usec_plus_hr_tbl(I).status;
	   p_usec_plus_hr_tbl(I).msg_from := p_usec_plus_hr_tbl(I).msg_from+1;
	   p_usec_plus_hr_tbl(I).msg_to := fnd_msg_pub.count_msg;
	   IF p_usec_plus_hr_tbl(I).status = 'E' THEN
	      RETURN;
	   END IF;
	END IF;

     END IF;
  END LOOP;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_plus_hr.after_import_status',p_c_rec_status);
  END IF;

END create_usec_plus_hr;

PROCEDURE create_usec_rule(p_usec_rule_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_rule_tbl_type,
                           p_c_rec_status OUT NOCOPY VARCHAR2,
       	                   p_calling_context IN VARCHAR2) IS
/***********************************************************************************************

Created By:         sarakshi
Date Created By:    01-Jun-2005
Purpose:            This procedure imports unit section Rules.

Known limitations,enhancements,remarks:
Change History
Who       When         What
***********************************************************************************************/

	l_n_uoo_id           NUMBER;
        l_n_select_group     NUMBER;
	l_c_rule_desc        igs_ru_description.rule_description%TYPE;
	l_n_rule_number      NUMBER;
	l_success            BOOLEAN;
	l_c_rule_unprocessed VARCHAR2(4500);
	l_n_lov_number       NUMBER;
	l_insert_update      VARCHAR2(1);

    PROCEDURE trim_values ( p_usec_rule_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rule_rec_type) AS
    BEGIN

      p_usec_rule_rec.unit_cd := TRIM(p_usec_rule_rec.unit_cd);
      p_usec_rule_rec.version_number := TRIM(p_usec_rule_rec.version_number);
      p_usec_rule_rec.teach_cal_alternate_code := TRIM(p_usec_rule_rec.teach_cal_alternate_code);
      p_usec_rule_rec.location_cd := TRIM(p_usec_rule_rec.location_cd);
      p_usec_rule_rec.unit_class := TRIM(p_usec_rule_rec.unit_class);
      p_usec_rule_rec.s_rule_call_cd := TRIM(p_usec_rule_rec.s_rule_call_cd);
      p_usec_rule_rec.rule_text := TRIM(p_usec_rule_rec.rule_text);

    END trim_values;

    PROCEDURE validate_parameters(p_usec_rule_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rule_rec_type) AS

    BEGIN
      p_usec_rule_rec.status:='S';


      IF p_usec_rule_rec.unit_cd IS NULL OR p_usec_rule_rec.unit_cd = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CD','LEGACY_TOKENS',FALSE);
         p_usec_rule_rec.status := 'E';
      END IF;

      IF p_usec_rule_rec.version_number IS NULL OR p_usec_rule_rec.version_number = FND_API.G_MISS_NUM THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_VER_NUM','LEGACY_TOKENS',FALSE);
         p_usec_rule_rec.status := 'E';
      END IF;

      IF p_usec_rule_rec.teach_cal_alternate_code IS NULL OR p_usec_rule_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS',FALSE);
	 p_usec_rule_rec.status := 'E';
      END IF;

      IF p_usec_rule_rec.location_cd IS NULL OR p_usec_rule_rec.location_cd = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD','LEGACY_TOKENS',FALSE);
	 p_usec_rule_rec.status := 'E';
      END IF;

      IF p_usec_rule_rec.unit_class IS NULL OR p_usec_rule_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CLASS','LEGACY_TOKENS',FALSE);
	p_usec_rule_rec.status := 'E';
      END IF;

      IF p_usec_rule_rec.s_rule_call_cd IS NULL OR p_usec_rule_rec.s_rule_call_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','S_RULE_CALL_CD','LEGACY_TOKENS',FALSE);
	p_usec_rule_rec.status := 'E';
      END IF;

      IF p_usec_rule_rec.rule_text IS NULL OR p_usec_rule_rec.rule_text = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','RULE_TEXT','LEGACY_TOKENS',FALSE);
	p_usec_rule_rec.status := 'E';
      END IF;

    END validate_parameters;

    PROCEDURE validate_derivation(p_usec_rule_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rule_rec_type) AS
      l_c_cal_type    VARCHAR2(10);
      l_n_seq_num     NUMBER;
      l_d_start       igs_ca_inst_all.start_dt%TYPE;
      l_d_end         igs_ca_inst_all.end_dt%TYPE;
      l_c_ret_status  VARCHAR2(30);


    BEGIN

       -- Deriving the Calendar Type and Calendar Sequence Number
       igs_ge_gen_003.get_calendar_instance(p_usec_rule_rec.teach_cal_alternate_code,'''TEACHING''',  l_c_cal_type, l_n_seq_num, l_d_start, l_d_end, l_c_ret_status);
       IF l_c_ret_status <> 'SINGLE' THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS', FALSE);
	   p_usec_rule_rec.status := 'E';
       END IF;

       -- Deriving the Unit Offering Option Identifier
       l_c_ret_status := NULL;
       igs_ps_validate_lgcy_pkg.get_uoo_id(p_usec_rule_rec.unit_cd, p_usec_rule_rec.version_number, l_c_cal_type, l_n_seq_num, p_usec_rule_rec.location_cd, p_usec_rule_rec.unit_class, l_n_uoo_id, l_c_ret_status);
       IF l_c_ret_status IS NOT NULL THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','UNIT_SECTION','LEGACY_TOKENS', FALSE);
	  p_usec_rule_rec.status := 'E';
       END IF;


    END validate_derivation;

    PROCEDURE validate_db_cons(p_usec_rule_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rule_rec_type,p_insert_update IN VARCHAR2) AS

    BEGIN

      IF p_insert_update = 'I' THEN
	-- Unique Key Validation
	IF igs_ps_usec_ru_pkg.get_uk_for_validation ( x_uoo_id           => l_n_uoo_id,
						      x_s_rule_call_cd   => p_usec_rule_rec.s_rule_call_cd ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'RULE', 'LEGACY_TOKENS', FALSE);
	  p_usec_rule_rec.status := 'W';
	  RETURN;
	END IF;
      END IF;

      -- Foreign Key Checking
      --Check for the existence of the unit section
      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation (l_n_uoo_id ) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
         p_usec_rule_rec.status := 'E';
      END IF;

      IF NOT igs_ru_call_pkg.get_pk_for_validation (p_usec_rule_rec.s_rule_call_cd ) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'S_RULE_CALL_CD', 'LEGACY_TOKENS', FALSE);
         p_usec_rule_rec.status := 'E';
      END IF;


    END validate_db_cons;

    -- Check for Update/Insert
    FUNCTION check_insert_update ( p_usec_rule_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rule_rec_type) RETURN VARCHAR2 IS

      CURSOR c_rule IS
      SELECT rul_sequence_number
      FROM   igs_ps_usec_ru
      WHERE  uoo_id = l_n_uoo_id
      AND    s_rule_call_cd = p_usec_rule_rec.s_rule_call_cd;

    BEGIN

       OPEN c_rule;
       FETCH c_rule INTO l_n_rule_number;
       IF c_rule%FOUND THEN
	 CLOSE c_rule;
	 RETURN 'U';
       ELSE
	 CLOSE c_rule;
	 RETURN 'I';
       END IF;

    END check_insert_update;


    PROCEDURE Business_validation(p_usec_rule_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rule_rec_type) AS

      CURSOR cur_rule_check IS
      SELECT rc.select_group,rd.rule_description
      FROM   igs_ru_call rc,igs_ru_description rd
      WHERE  rc.s_rule_type_cd = 'USEC'
      AND    rc.s_rule_call_cd = p_usec_rule_rec.s_rule_call_cd
      AND    rc.rud_sequence_number = rd.sequence_number;

      l_message_name VARCHAR2(30);
      l_c_var VARCHAR2(1);

    BEGIN
      --Check if the unit is INACTIVE, then do not allow to import
      IF igs_ps_val_unit.crsp_val_iud_uv_dtl(p_usec_rule_rec.unit_cd, p_usec_rule_rec.version_number,l_message_name)=FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
	    fnd_msg_pub.add;
	    p_usec_rule_rec.status := 'E';
      END IF;

      -- s_rule_call_cd must exists in igs_ru_call with S_RULE_TYPE_CD='USEC'
      --Valid values  of S_RULE_CALL_CD are 'USECCOREQ' and 'USECPREREQ'
      OPEN cur_rule_check;
      FETCH cur_rule_check INTO l_n_select_group,l_c_rule_desc;
      IF cur_rule_check%NOTFOUND THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'S_RULE_CALL_CD','LEGACY_TOKENS', FALSE);
	  p_usec_rule_rec.status := 'E';
      END IF;
      CLOSE cur_rule_check;

    END Business_validation;

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_rule.start_logging_for',
                    'Unit Section Rules');
  END IF;

  p_c_rec_status := 'S';
  FOR I in 1..p_usec_rule_tbl.LAST LOOP
     IF p_usec_rule_tbl.EXISTS(I) THEN
	-- Initialize the variable use to store the derived values.
	l_n_uoo_id           := NULL;
        l_n_select_group     := NULL;
	l_c_rule_desc        := NULL;
        l_n_rule_number      := NULL;
	l_success            := FALSE;
	l_c_rule_unprocessed := NULL;
        l_n_lov_number       := NULL;


	p_usec_rule_tbl(I).status := 'S';
	p_usec_rule_tbl(I).msg_from := fnd_msg_pub.count_msg;
	trim_values(p_usec_rule_tbl(I));
	validate_parameters(p_usec_rule_tbl(I));

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_rule.status_after_validate_parameters',
	  'Unit code:'||p_usec_rule_tbl(I).unit_cd||'  '||'Version number:'||p_usec_rule_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rule_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rule_tbl(I).location_cd||'  '||'Unit Class:'||
	  p_usec_rule_tbl(I).unit_class||'  '||'s_rule_call_cd:'||p_usec_rule_tbl(I).s_rule_call_cd||'  '||'Status:'||
	  p_usec_rule_tbl(I).status);
        END IF;

	IF p_usec_rule_tbl(I).status = 'S' THEN
	   validate_derivation(p_usec_rule_tbl(I));

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_rule.status_after_validate_derivation',
	      'Unit code:'||p_usec_rule_tbl(I).unit_cd||'  '||'Version number:'||p_usec_rule_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_rule_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rule_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_rule_tbl(I).unit_class||'  '||'s_rule_call_cd:'||p_usec_rule_tbl(I).s_rule_call_cd||'  '||'Status:'||
	      p_usec_rule_tbl(I).status);
           END IF;

	END IF;

	--Find out whether it is insert/update of record
	l_insert_update:='I';
	IF p_usec_rule_tbl(I).status = 'S' AND p_calling_context IN ('G','S') THEN
	  l_insert_update:= check_insert_update(p_usec_rule_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_rule.status_after_check_insert_update',
	    'Unit code:'||p_usec_rule_tbl(I).unit_cd||'  '||'Version number:'||p_usec_rule_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rule_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rule_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_rule_tbl(I).unit_class||'  '||'s_rule_call_cd:'||p_usec_rule_tbl(I).s_rule_call_cd||'  '||'Status:'||
	    p_usec_rule_tbl(I).status);
          END IF;

	END IF;

	IF p_usec_rule_tbl(I).status = 'S' AND p_calling_context = 'S' THEN
	  IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	    fnd_msg_pub.add;
	    p_usec_rule_tbl(I).status := 'A';
	  END IF;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_rule.status_after_check_import_allowed',
	    'Unit code:'||p_usec_rule_tbl(I).unit_cd||'  '||'Version number:'||p_usec_rule_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rule_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rule_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_rule_tbl(I).unit_class||'  '||'s_rule_call_cd:'||p_usec_rule_tbl(I).s_rule_call_cd||'  '||'Status:'||
	    p_usec_rule_tbl(I).status);
          END IF;

	END IF;



	IF p_usec_rule_tbl(I).status = 'S' THEN
	   validate_db_cons ( p_usec_rule_tbl(I),l_insert_update);

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_rule.status_after_validate_db_cons',
	     'Unit code:'||p_usec_rule_tbl(I).unit_cd||'  '||'Version number:'||p_usec_rule_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_rule_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rule_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_rule_tbl(I).unit_class||'  '||'s_rule_call_cd:'||p_usec_rule_tbl(I).s_rule_call_cd||'  '||'Status:'||
	     p_usec_rule_tbl(I).status);
           END IF;

	END IF;


	--Business validations
	IF p_usec_rule_tbl(I).status = 'S' THEN
	  Business_validation(p_usec_rule_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_rule.status_after_Business_validation',
	     'Unit code:'||p_usec_rule_tbl(I).unit_cd||'  '||'Version number:'||p_usec_rule_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_rule_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rule_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_rule_tbl(I).unit_class||'  '||'s_rule_call_cd:'||p_usec_rule_tbl(I).s_rule_call_cd||'  '||'Status:'||
	     p_usec_rule_tbl(I).status);
          END IF;

	END IF;

	IF p_usec_rule_tbl(I).status = 'S' THEN

	  l_success:=  igs_ru_gen_002.rulp_ins_parser (
		 p_group            =>  l_n_select_group,            -- 8 for Unit Co-requisite,2 for Unit Pre-requisite
		 p_return_type      => 'BOOLEAN',                    -- pass BOOLEAN
		 p_rule_description => l_c_rule_desc,                -- <Unit Co-requisite/Unit Pre-requisite>
		 p_rule_processed   => p_usec_rule_tbl(I).rule_text, -- Pass the rule_text
		 p_rule_unprocessed => l_c_rule_unprocessed,         -- id column out parameter
		 p_generate_rule    => TRUE,                         -- pass TRUE
		 p_rule_number      => l_n_rule_number,              -- id column out parameter
		 p_lov_number       => l_n_lov_number );             -- id column out parameter

          IF l_success THEN

	    IF l_insert_update = 'I' THEN
	      INSERT INTO IGS_PS_USEC_RU(
		usecru_id,
		uoo_id,
		s_rule_call_cd,
		rul_sequence_number,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login )
	      VALUES (
		 igs_ps_usec_ru_s.NEXTVAL,
		 l_n_uoo_id,
		 p_usec_rule_tbl(I).s_rule_call_cd,
		 l_n_rule_number,
		 g_n_user_id,
		 SYSDATE,
		 g_n_user_id,
		 SYSDATE,
		 g_n_login_id);

                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_rule.Record_Inserted',
		   'Unit code:'||p_usec_rule_tbl(I).unit_cd||'  '||'Version number:'||p_usec_rule_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		   ||p_usec_rule_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rule_tbl(I).location_cd||'  '||'Unit Class:'||
		   p_usec_rule_tbl(I).unit_class||'  '||'s_rule_call_cd:'||p_usec_rule_tbl(I).s_rule_call_cd);
		 END IF;
		 --Note: Update is not required as it does not update the base table, only rule table,
		 --which is getting done by igs_ru_gen_002.rulp_ins_parse function

	    END IF;

          ELSE
 	    --Error in Rule Text cannot import
	    fnd_message.set_name ( 'IGS', 'IGS_PS_INCORRECT_RULE' );
	    fnd_msg_pub.add;
	    p_usec_rule_tbl(I).status := 'E';
          END IF; --If l_success

	END IF;


	IF p_usec_rule_tbl(I).status = 'S' THEN
	   p_usec_rule_tbl(I).msg_from := NULL;
	   p_usec_rule_tbl(I).msg_to := NULL;
	ELSIF  p_usec_rule_tbl(I).status = 'A' THEN
	   p_usec_rule_tbl(I).msg_from  := p_usec_rule_tbl(I).msg_from + 1;
	   p_usec_rule_tbl(I).msg_to := fnd_msg_pub.count_msg;
	ELSE
	   p_c_rec_status := p_usec_rule_tbl(I).status;
	   p_usec_rule_tbl(I).msg_from := p_usec_rule_tbl(I).msg_from+1;
	   p_usec_rule_tbl(I).msg_to := fnd_msg_pub.count_msg;
	   IF p_usec_rule_tbl(I).status = 'E' THEN
	      RETURN;
	   END IF;
	END IF;

     END IF;
  END LOOP;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_rule.after_import_status',p_c_rec_status);
  END IF;

END create_usec_rule;


PROCEDURE create_usec_enr_dead(p_usec_enr_dead_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dead_tbl_type,
			         p_c_rec_status OUT NOCOPY VARCHAR2,
			         p_calling_context IN VARCHAR2) IS
/***********************************************************************************************

Created By:         sarakshi
Date Created By:    01-Jun-2005
Purpose:            This procedure imports unit section Enrollment Deadline.

Known limitations,enhancements,remarks:
Change History
Who       When         What
Sommukhe  13-Jan-2006  Bug #4926548 replaced igs_en_nsu_dlstp with igs_en_nsu_dlstp_all for cursor cur_dead_details
                       in  proccedure Assign_defaults
***********************************************************************************************/
    l_n_uoo_id                igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_n_non_std_usec_dls_id   igs_en_nsu_dlstp.non_std_usec_dls_id%TYPE;
    l_c_org_unit_code         igs_en_nsu_dlstp.org_unit_code%TYPE;
    l_c_definition_code       igs_en_nsu_dlstp.definition_code%TYPE;
    l_c_formula_method        igs_en_nsu_dlstp.formula_method%TYPE;
    l_c_round_method          igs_en_nsu_dlstp.round_method%TYPE;
    l_n_offset_duration       igs_en_nsu_dlstp.offset_duration%TYPE;
    l_c_offset_dt_code        igs_en_nsu_dlstp.offset_dt_code%TYPE;
    l_n_duration_days         igs_en_nstd_usec_dl.enr_dl_total_days%TYPE;
    l_n_offset_days           igs_en_nstd_usec_dl.enr_dl_offset_days%TYPE;
    l_d_enr_dl_date           igs_en_nstd_usec_dl.enr_dl_date%TYPE;
    l_insert_update           VARCHAR2(1);

    PROCEDURE trim_values ( p_usec_enr_dead_rec IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dead_rec_type) AS
    BEGIN

      p_usec_enr_dead_rec.unit_cd := TRIM(p_usec_enr_dead_rec.unit_cd);
      p_usec_enr_dead_rec.version_number := TRIM(p_usec_enr_dead_rec.version_number);
      p_usec_enr_dead_rec.teach_cal_alternate_code := TRIM(p_usec_enr_dead_rec.teach_cal_alternate_code);
      p_usec_enr_dead_rec.location_cd := TRIM(p_usec_enr_dead_rec.location_cd);
      p_usec_enr_dead_rec.unit_class := TRIM(p_usec_enr_dead_rec.unit_class);
      p_usec_enr_dead_rec.function_name := TRIM(p_usec_enr_dead_rec.function_name);
      p_usec_enr_dead_rec.enr_dl_date := TRUNC(p_usec_enr_dead_rec.enr_dl_date);

    END trim_values;

    PROCEDURE validate_parameters( p_usec_enr_dead_rec IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dead_rec_type) AS

    BEGIN
      p_usec_enr_dead_rec.status:='S';


      IF p_usec_enr_dead_rec.unit_cd IS NULL OR p_usec_enr_dead_rec.unit_cd = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CD','LEGACY_TOKENS',FALSE);
         p_usec_enr_dead_rec.status := 'E';
      END IF;

      IF p_usec_enr_dead_rec.version_number IS NULL OR p_usec_enr_dead_rec.version_number = FND_API.G_MISS_NUM THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_VER_NUM','LEGACY_TOKENS',FALSE);
         p_usec_enr_dead_rec.status := 'E';
      END IF;

      IF p_usec_enr_dead_rec.teach_cal_alternate_code IS NULL OR p_usec_enr_dead_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS',FALSE);
	 p_usec_enr_dead_rec.status := 'E';
      END IF;

      IF p_usec_enr_dead_rec.location_cd IS NULL OR p_usec_enr_dead_rec.location_cd = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD','LEGACY_TOKENS',FALSE);
	 p_usec_enr_dead_rec.status := 'E';
      END IF;

      IF p_usec_enr_dead_rec.unit_class IS NULL OR p_usec_enr_dead_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CLASS','LEGACY_TOKENS',FALSE);
	p_usec_enr_dead_rec.status := 'E';
      END IF;

      IF p_usec_enr_dead_rec.function_name IS NULL OR p_usec_enr_dead_rec.function_name = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','FUNCTION_NAME','LEGACY_TOKENS',FALSE);
	p_usec_enr_dead_rec.status := 'E';
      END IF;

      -- Function name should be one among 'GRADING_SCHEMA' ,'RECORD_CUTOFF' ,'VARIATION_CUTOFF'
      IF p_usec_enr_dead_rec.function_name NOT IN ('GRADING_SCHEMA' ,'RECORD_CUTOFF' ,'VARIATION_CUTOFF') THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'FUNCTION_NAME','LEGACY_TOKENS', FALSE);
	  p_usec_enr_dead_rec.status := 'E';
      END IF;

    END validate_parameters;

    PROCEDURE validate_derivation(p_usec_enr_dead_rec IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dead_rec_type) AS

      l_c_cal_type    VARCHAR2(10);
      l_n_seq_num     NUMBER;
      l_d_start       igs_ca_inst_all.start_dt%TYPE;
      l_d_end         igs_ca_inst_all.end_dt%TYPE;
      l_c_ret_status  VARCHAR2(30);


    BEGIN

       -- Deriving the Calendar Type and Calendar Sequence Number
       igs_ge_gen_003.get_calendar_instance(p_usec_enr_dead_rec.teach_cal_alternate_code,'''TEACHING''',  l_c_cal_type, l_n_seq_num, l_d_start, l_d_end, l_c_ret_status);
       IF l_c_ret_status <> 'SINGLE' THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS', FALSE);
	   p_usec_enr_dead_rec.status := 'E';
       END IF;

       -- Deriving the Unit Offering Option Identifier
       l_c_ret_status := NULL;
       igs_ps_validate_lgcy_pkg.get_uoo_id(p_usec_enr_dead_rec.unit_cd, p_usec_enr_dead_rec.version_number, l_c_cal_type, l_n_seq_num, p_usec_enr_dead_rec.location_cd, p_usec_enr_dead_rec.unit_class, l_n_uoo_id, l_c_ret_status);
       IF l_c_ret_status IS NOT NULL THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','UNIT_SECTION','LEGACY_TOKENS', FALSE);
	  p_usec_enr_dead_rec.status := 'E';
       END IF;

    END validate_derivation;

    PROCEDURE validate_db_cons(p_usec_enr_dead_rec IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dead_rec_type,p_insert_update IN VARCHAR2) AS

    BEGIN

      IF p_insert_update = 'I' THEN
	-- Unique Key Validation
	IF igs_en_nstd_usec_dl_pkg.get_uk_for_validation ( x_uoo_id           => l_n_uoo_id,
						           x_function_name    => p_usec_enr_dead_rec.function_name ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'ENR_DEADLINE', 'LEGACY_TOKENS', FALSE);
	  p_usec_enr_dead_rec.status := 'W';
	  RETURN;
	END IF;
      END IF;

      -- Foreign Key Checking
      --Check for the existence of the unit section
      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation (l_n_uoo_id ) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
         p_usec_enr_dead_rec.status := 'E';
      END IF;


      IF l_n_non_std_usec_dls_id IS NOT NULL THEN
	IF NOT igs_en_nsu_dlstp_pkg.get_pk_for_validation ( l_n_non_std_usec_dls_id) THEN
	   igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'NON_STD_USEC_DLS_ID', 'LEGACY_TOKENS', FALSE);
	   p_usec_enr_dead_rec.status := 'E';
	END IF;
      END IF;

    END validate_db_cons;

    -- Check for Update/Insert
    FUNCTION check_insert_update ( p_usec_enr_dead_rec IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dead_rec_type) RETURN VARCHAR2 IS

      CURSOR c_enr_dead IS
      SELECT 'X'
      FROM   igs_en_nstd_usec_dl
      WHERE  uoo_id = l_n_uoo_id
      AND    function_name = p_usec_enr_dead_rec.function_name;
      l_c_var  VARCHAR2(1);

    BEGIN

       OPEN c_enr_dead;
       FETCH c_enr_dead INTO l_c_var;
       IF c_enr_dead%FOUND THEN
	 CLOSE c_enr_dead;
	 RETURN 'U';
       ELSE
	 CLOSE c_enr_dead;
	 RETURN 'I';
       END IF;

    END check_insert_update;

    PROCEDURE Assign_defaults (p_usec_enr_dead_rec IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dead_rec_type,p_insert_update IN VARCHAR2) AS

      CURSOR cur_usec(cp_uoo_id IN NUMBER) IS
      SELECT owner_org_unit_cd
      FROM   igs_ps_unit_ofr_opt_all
      WHERE  uoo_id=cp_uoo_id;
      l_c_org_unit_cd   igs_ps_unit_ofr_opt_all.owner_org_unit_cd%TYPE;

      CURSOR cur_dead_details (cp_org_unit_cd IN VARCHAR2,cp_function_name IN VARCHAR2) IS
      SELECT formula_method,round_method,offset_duration,non_std_usec_dls_id,offset_dt_code,org_unit_code,definition_code
      FROM igs_en_nsu_dlstp_all
      WHERE ((org_unit_code = cp_org_unit_cd AND definition_code = 'ORGANIZATIONAL_UNIT') OR definition_code = 'INSTITUTION')
      AND function_name = cp_function_name;
      l_cur_dead_details   cur_dead_details%ROWTYPE;

      CURSOR c_enr_dead IS
      SELECT *
      FROM   igs_en_nstd_usec_dl
      WHERE  uoo_id = l_n_uoo_id
      AND    function_name = p_usec_enr_dead_rec.function_name;
      l_c_enr_dead c_enr_dead%ROWTYPE;

      l_c_message     VARCHAR2(30);

    BEGIN
      IF p_insert_update = 'I' THEN
	   -- Dervie the attributes from the org/institution level table
	   OPEN cur_usec(l_n_uoo_id);
	   FETCH cur_usec INTO l_c_org_unit_cd;
	   CLOSE cur_usec;


	   OPEN cur_dead_details(l_c_org_unit_cd,p_usec_enr_dead_rec.function_name);
	   FETCH cur_dead_details INTO  l_cur_dead_details;
	   IF cur_dead_details%FOUND THEN


	     l_n_non_std_usec_dls_id :=l_cur_dead_details.non_std_usec_dls_id;
	     l_c_org_unit_code := l_cur_dead_details.org_unit_code;
	     l_c_definition_code := l_cur_dead_details.definition_code;
	     l_c_formula_method := l_cur_dead_details.formula_method;
	     l_c_round_method := l_cur_dead_details.round_method;
	     l_n_offset_duration := l_cur_dead_details.offset_duration;
	     l_c_offset_dt_code := l_cur_dead_details.offset_dt_code;

	     l_d_enr_dl_date:= igs_ps_gen_004.recal_dl_date (
					   p_v_uoo_id        =>l_n_uoo_id,
					   p_formula_method  =>l_cur_dead_details.formula_method,
					   p_durationdays    =>l_n_duration_days,--out
					   p_round_method    =>l_cur_dead_details.round_method,
					   p_OffsetDuration  =>l_cur_dead_details.offset_duration,
					   p_OffsetDays      =>l_n_offset_days,--out
					   p_function_name   =>p_usec_enr_dead_rec.function_name,
					   p_setup_id        =>l_cur_dead_details.non_std_usec_dls_id,
					   p_offset_dt_code  =>l_cur_dead_details.offset_dt_code,
					   p_msg 	     =>l_c_message  --out
					   );
	      IF p_usec_enr_dead_rec.enr_dl_date IS NOT NULL THEN
		l_d_enr_dl_date := p_usec_enr_dead_rec.enr_dl_date;
	      END IF;
           ELSE
	     IF p_usec_enr_dead_rec.enr_dl_date IS NULL THEN
		igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','ENR_DEAD_DATE','LEGACY_TOKENS',FALSE);
		p_usec_enr_dead_rec.status := 'E';
             ELSE
	        l_d_enr_dl_date := p_usec_enr_dead_rec.enr_dl_date;
             END IF;
	   END IF;
           CLOSE cur_dead_details;

      ELSE --update

        OPEN c_enr_dead;
        FETCH c_enr_dead INTO l_c_enr_dead;
	CLOSE c_enr_dead;

         --Set the values to the databse values
	 l_n_non_std_usec_dls_id :=l_c_enr_dead.non_std_usec_dls_id;
	 l_c_org_unit_code := l_c_enr_dead.org_unit_code;
	 l_c_definition_code := l_c_enr_dead.definition_code;
	 l_c_formula_method := l_c_enr_dead.formula_method;
	 l_c_round_method := l_c_enr_dead.round_method;
	 l_n_offset_duration := l_c_enr_dead.offset_duration;
	 l_c_offset_dt_code := l_c_enr_dead.offset_dt_code;
	 l_n_duration_days :=  l_c_enr_dead.enr_dl_total_days;
	 l_n_offset_days :=    l_c_enr_dead.enr_dl_offset_days;

        IF l_c_enr_dead.non_std_usec_dls_id IS NOT NULL THEN
	   -- Dervie the attributes from the org/institution level table
	   OPEN cur_usec(l_n_uoo_id);
	   FETCH cur_usec INTO l_c_org_unit_cd;
	   CLOSE cur_usec;


	   OPEN cur_dead_details(l_c_org_unit_cd,p_usec_enr_dead_rec.function_name);
	   FETCH cur_dead_details INTO  l_cur_dead_details;
           IF cur_dead_details%FOUND THEN
	     IF (l_c_enr_dead.formula_method  <>  l_cur_dead_details.formula_method OR
		 l_c_enr_dead.round_method    <>  l_cur_dead_details.round_method   OR
		 l_c_enr_dead.offset_dt_code  <>  l_cur_dead_details.offset_dt_code OR
		 l_c_enr_dead.offset_duration <> l_cur_dead_details.offset_duration ) THEN

		   l_n_non_std_usec_dls_id :=l_cur_dead_details.non_std_usec_dls_id;
		   l_c_org_unit_code := l_cur_dead_details.org_unit_code;
		   l_c_definition_code := l_cur_dead_details.definition_code;
		   l_c_formula_method := l_cur_dead_details.formula_method;
		   l_c_round_method := l_cur_dead_details.round_method;
		   l_n_offset_duration := l_cur_dead_details.offset_duration;
		   l_c_offset_dt_code := l_cur_dead_details.offset_dt_code;

		   l_d_enr_dl_date:= igs_ps_gen_004.recal_dl_date (
						 p_v_uoo_id        =>l_n_uoo_id,
						 p_formula_method  =>l_cur_dead_details.formula_method,
						 p_durationdays    =>l_n_duration_days,--out
						 p_round_method    =>l_cur_dead_details.round_method,
						 p_OffsetDuration  =>l_cur_dead_details.offset_duration,
						 p_OffsetDays      =>l_n_offset_days,--out
						 p_function_name   =>p_usec_enr_dead_rec.function_name,
						 p_setup_id        =>l_cur_dead_details.non_std_usec_dls_id,
						 p_offset_dt_code  =>l_cur_dead_details.offset_dt_code,
						 p_msg 	           =>l_c_message  --out
						 );

	     END IF;
           END IF;
   	   CLOSE cur_dead_details;

        END IF;

	IF p_usec_enr_dead_rec.enr_dl_date IS NOT NULL THEN
	  l_d_enr_dl_date := p_usec_enr_dead_rec.enr_dl_date;
	ELSE
	  l_d_enr_dl_date := l_c_enr_dead.enr_dl_date;
	END IF;

      END IF; --insert/update

    END Assign_defaults;

    PROCEDURE Business_validation(p_usec_enr_dead_rec IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dead_rec_type) AS
      CURSOR cur_check_ns_usec(cp_n_uoo_id  IN NUMBER) IS
      SELECT 'X'
      FROM igs_ps_unit_ofr_opt_all
      WHERE uoo_id = cp_n_uoo_id
      AND non_std_usec_ind = 'Y';
      l_c_var    VARCHAR2(1);

      l_message_name VARCHAR2(30);

    BEGIN
      --Check if the unit is INACTIVE, then do not allow to import
      IF igs_ps_val_unit.crsp_val_iud_uv_dtl(p_usec_enr_dead_rec.unit_cd, p_usec_enr_dead_rec.version_number,l_message_name)=FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
	    fnd_msg_pub.add;
	    p_usec_enr_dead_rec.status := 'E';
      END IF;

      --Check if the Unit Scetion is not Not standard then insert/update is not allowed
      OPEN cur_check_ns_usec(l_n_uoo_id);
      FETCH cur_check_ns_usec INTO l_c_var;
      IF cur_check_ns_usec%NOTFOUND THEN
        fnd_message.set_name ( 'IGS', 'IGS_PS_NON_STD_USEC_NOT_IMP' );
	fnd_message.set_token('RECORD',igs_ps_validate_lgcy_pkg.get_lkup_meaning('ENR_DEADLINE','LEGACY_TOKENS'));
        fnd_msg_pub.add;
  	/*igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_NON_STD_USEC_NOT_IMP','ENR_DEADLINE','LEGACY_TOKENS',FALSE);*/
	p_usec_enr_dead_rec.status := 'E';
      END IF;
      CLOSE cur_check_ns_usec;

    END Business_validation;

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dead.start_logging_for',
                    'Unit Section Enrollment Deadline ');
  END IF;

  p_c_rec_status := 'S';
  FOR I in 1..p_usec_enr_dead_tbl.LAST LOOP
     IF p_usec_enr_dead_tbl.EXISTS(I) THEN
	-- Initialize the variable use to store the derived values.
	l_n_uoo_id := NULL;
        l_n_non_std_usec_dls_id :=NULL;
        l_c_org_unit_code :=NULL;
        l_c_definition_code :=NULL;
        l_c_formula_method :=NULL;
        l_c_round_method :=NULL;
        l_n_offset_duration :=NULL;
        l_c_offset_dt_code :=NULL;
        l_n_duration_days :=NULL;
        l_n_offset_days :=NULL;
        l_d_enr_dl_date :=NULL;

	p_usec_enr_dead_tbl(I).status := 'S';
	p_usec_enr_dead_tbl(I).msg_from := fnd_msg_pub.count_msg;
	trim_values(p_usec_enr_dead_tbl(I));

	validate_parameters(p_usec_enr_dead_tbl(I));


	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dead.status_after_validate_parameters',
	  'Unit code:'||p_usec_enr_dead_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dead_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_enr_dead_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dead_tbl(I).location_cd||'  '||'Unit Class:'||
	  p_usec_enr_dead_tbl(I).unit_class||'  '||'function_name:'||p_usec_enr_dead_tbl(I).function_name||'  '||'Status:'||
	  p_usec_enr_dead_tbl(I).status);
        END IF;

	IF p_usec_enr_dead_tbl(I).status = 'S' THEN
	   validate_derivation(p_usec_enr_dead_tbl(I));

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dead.status_after_validate_derivation',
	      'Unit code:'||p_usec_enr_dead_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dead_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_enr_dead_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dead_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_enr_dead_tbl(I).unit_class||'  '||'function_name:'||p_usec_enr_dead_tbl(I).function_name||'  '||'Status:'||
	      p_usec_enr_dead_tbl(I).status);
           END IF;

	END IF;

	--Find out whether it is insert/update of record
	l_insert_update:='I';
	IF p_usec_enr_dead_tbl(I).status = 'S' AND p_calling_context IN ('G','S') THEN
	  l_insert_update:= check_insert_update(p_usec_enr_dead_tbl(I));

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dead.status_after_check_insert_update',
	      'Unit code:'||p_usec_enr_dead_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dead_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_enr_dead_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dead_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_enr_dead_tbl(I).unit_class||'  '||'function_name:'||p_usec_enr_dead_tbl(I).function_name||'  '||'Status:'||
	      p_usec_enr_dead_tbl(I).status);
           END IF;


	END IF;

	IF p_usec_enr_dead_tbl(I).status = 'S' AND p_calling_context = 'S' THEN
	  IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	    fnd_msg_pub.add;
	    p_usec_enr_dead_tbl(I).status := 'A';
	  END IF;

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dead.status_after_check_import_allowed',
	      'Unit code:'||p_usec_enr_dead_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dead_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_enr_dead_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dead_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_enr_dead_tbl(I).unit_class||'  '||'function_name:'||p_usec_enr_dead_tbl(I).function_name||'  '||'Status:'||
	      p_usec_enr_dead_tbl(I).status);
           END IF;

	END IF;

	IF p_usec_enr_dead_tbl(I).status = 'S' THEN
	  assign_defaults(p_usec_enr_dead_tbl(I),l_insert_update);

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dead.status_after_assign_defaults',
	      'Unit code:'||p_usec_enr_dead_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dead_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_enr_dead_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dead_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_enr_dead_tbl(I).unit_class||'  '||'function_name:'||p_usec_enr_dead_tbl(I).function_name||'  '||'Status:'||
	      p_usec_enr_dead_tbl(I).status);
           END IF;

	END IF;

	IF p_usec_enr_dead_tbl(I).status = 'S' THEN
	   validate_db_cons ( p_usec_enr_dead_tbl(I),l_insert_update);

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dead.status_after_validate_db_cons',
	      'Unit code:'||p_usec_enr_dead_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dead_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_enr_dead_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dead_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_enr_dead_tbl(I).unit_class||'  '||'function_name:'||p_usec_enr_dead_tbl(I).function_name||'  '||'Status:'||
	      p_usec_enr_dead_tbl(I).status);
           END IF;

	END IF;


	--Business validations
	IF p_usec_enr_dead_tbl(I).status = 'S' THEN
	  Business_validation(p_usec_enr_dead_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dead.status_after_Business_validation',
	      'Unit code:'||p_usec_enr_dead_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dead_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_enr_dead_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dead_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_enr_dead_tbl(I).unit_class||'  '||'function_name:'||p_usec_enr_dead_tbl(I).function_name||'  '||'Status:'||
	      p_usec_enr_dead_tbl(I).status);
           END IF;

	END IF;

	IF p_usec_enr_dead_tbl(I).status = 'S' THEN

	  IF l_insert_update = 'I' THEN
	    INSERT INTO IGS_EN_NSTD_USEC_DL(
	      nstd_usec_dl_id        ,
	      non_std_usec_dls_id    ,
	      function_name          ,
	      definition_code        ,
	      org_unit_code          ,
	      formula_method         ,
	      round_method           ,
	      offset_dt_code         ,
	      offset_duration        ,
	      uoo_id                 ,
	      enr_dl_date            ,
	      enr_dl_total_days      ,
	      enr_dl_offset_days     ,
	      created_by,
	      creation_date,
	      last_updated_by,
	      last_update_date,
	      last_update_login )
	    VALUES (
	      igs_en_nstd_usec_dl_s.NEXTVAL,
              l_n_non_std_usec_dls_id,
              p_usec_enr_dead_tbl(I).function_name,
 	      l_c_definition_code,
	      l_c_org_unit_code,
	      l_c_formula_method,
	      l_c_round_method,
	      l_c_offset_dt_code,
	      l_n_offset_duration,
	      l_n_uoo_id,
	      l_d_enr_dl_date,
	      l_n_duration_days,
	      l_n_offset_days,
	      g_n_user_id,
	      SYSDATE,
	      g_n_user_id,
	      SYSDATE,
	      g_n_login_id);

	       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dead.Record_Inserted',
		  'Unit code:'||p_usec_enr_dead_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dead_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		  ||p_usec_enr_dead_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dead_tbl(I).location_cd||'  '||'Unit Class:'||
		  p_usec_enr_dead_tbl(I).unit_class||'  '||'function_name:'||p_usec_enr_dead_tbl(I).function_name);
               END IF;

          ELSE
            UPDATE IGS_EN_NSTD_USEC_DL SET
              non_std_usec_dls_id    = l_n_non_std_usec_dls_id,
	      definition_code        = l_c_definition_code,
	      org_unit_code          = l_c_org_unit_code,
	      formula_method         = l_c_formula_method,
	      round_method           = l_c_round_method,
	      offset_dt_code         = l_c_offset_dt_code,
	      offset_duration        = l_n_offset_duration,
	      enr_dl_date            = l_d_enr_dl_date,
	      enr_dl_total_days      = l_n_duration_days,
	      enr_dl_offset_days     = l_n_offset_days,
   	      last_updated_by        = g_n_user_id ,
	      last_update_date       = sysdate ,
	      last_update_login      = g_n_login_id
	    WHERE uoo_id=l_n_uoo_id AND function_name=p_usec_enr_dead_tbl(I).function_name;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dead.Record_Updated',
	      'Unit code:'||p_usec_enr_dead_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dead_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_enr_dead_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dead_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_enr_dead_tbl(I).unit_class||'  '||'function_name:'||p_usec_enr_dead_tbl(I).function_name);
            END IF;

	  END IF;


	END IF;


	IF p_usec_enr_dead_tbl(I).status = 'S' THEN
	   p_usec_enr_dead_tbl(I).msg_from := NULL;
	   p_usec_enr_dead_tbl(I).msg_to := NULL;
	ELSIF  p_usec_enr_dead_tbl(I).status = 'A' THEN
	   p_usec_enr_dead_tbl(I).msg_from  := p_usec_enr_dead_tbl(I).msg_from + 1;
	   p_usec_enr_dead_tbl(I).msg_to := fnd_msg_pub.count_msg;
	ELSE
	   p_c_rec_status := p_usec_enr_dead_tbl(I).status;
	   p_usec_enr_dead_tbl(I).msg_from := p_usec_enr_dead_tbl(I).msg_from+1;
	   p_usec_enr_dead_tbl(I).msg_to := fnd_msg_pub.count_msg;
	   IF p_usec_enr_dead_tbl(I).status = 'E' THEN
	      RETURN;
	   END IF;
	END IF;

     END IF;
  END LOOP;

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dead.after_import_status',p_c_rec_status);
   END IF;

END create_usec_enr_dead;

PROCEDURE create_usec_enr_dis(p_usec_enr_dis_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dis_tbl_type,
 	                      p_c_rec_status OUT NOCOPY VARCHAR2,
			      p_calling_context IN VARCHAR2) IS

/***********************************************************************************************

Created By:         sarakshi
Date Created By:    01-Jun-2005
Purpose:            This procedure imports unit section Enrollment Discontinuation.

Known limitations,enhancements,remarks:
Change History
Who       When         What
Sommukhe  13-Jan-2006  Bug #4926548 replaced igs_en_nsd_dlstp with igs_en_nsd_dlstp_all for cursor cur_disc_details
                       in  proccedure Assign_defaults
***********************************************************************************************/
    l_n_uoo_id                   igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_n_non_std_disc_dl_stp_id   igs_en_nsu_dlstp.non_std_usec_dls_id%TYPE;
    l_c_org_unit_code            igs_en_nsu_dlstp.org_unit_code%TYPE;
    l_c_definition_code          igs_en_nsu_dlstp.definition_code%TYPE;
    l_c_formula_method           igs_en_nsu_dlstp.formula_method%TYPE;
    l_c_round_method             igs_en_nsu_dlstp.round_method%TYPE;
    l_n_offset_duration          igs_en_nsu_dlstp.offset_duration%TYPE;
    l_c_offset_dt_code           igs_en_nsu_dlstp.offset_dt_code%TYPE;
    l_n_duration_days            igs_en_nstd_usec_dl.enr_dl_total_days%TYPE;
    l_n_offset_days              igs_en_nstd_usec_dl.enr_dl_offset_days%TYPE;
    l_d_enr_dl_date              igs_en_nstd_usec_dl.enr_dl_date%TYPE;
    l_insert_update              VARCHAR2(1);

    PROCEDURE trim_values ( p_usec_enr_dis_rec IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dis_rec_type) AS
    BEGIN

      p_usec_enr_dis_rec.unit_cd := TRIM(p_usec_enr_dis_rec.unit_cd);
      p_usec_enr_dis_rec.version_number := TRIM(p_usec_enr_dis_rec.version_number);
      p_usec_enr_dis_rec.teach_cal_alternate_code := TRIM(p_usec_enr_dis_rec.teach_cal_alternate_code);
      p_usec_enr_dis_rec.location_cd := TRIM(p_usec_enr_dis_rec.location_cd);
      p_usec_enr_dis_rec.unit_class := TRIM(p_usec_enr_dis_rec.unit_class);
      p_usec_enr_dis_rec.administrative_unit_status := TRIM(p_usec_enr_dis_rec.administrative_unit_status);
      p_usec_enr_dis_rec.usec_disc_dl_date := TRUNC(p_usec_enr_dis_rec.usec_disc_dl_date);

    END trim_values;

    PROCEDURE validate_parameters( p_usec_enr_dis_rec IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dis_rec_type) AS

    BEGIN
      p_usec_enr_dis_rec.status:='S';


      IF p_usec_enr_dis_rec.unit_cd IS NULL OR p_usec_enr_dis_rec.unit_cd = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CD','LEGACY_TOKENS',FALSE);
         p_usec_enr_dis_rec.status := 'E';
      END IF;

      IF p_usec_enr_dis_rec.version_number IS NULL OR p_usec_enr_dis_rec.version_number = FND_API.G_MISS_NUM THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_VER_NUM','LEGACY_TOKENS',FALSE);
         p_usec_enr_dis_rec.status := 'E';
      END IF;

      IF p_usec_enr_dis_rec.teach_cal_alternate_code IS NULL OR p_usec_enr_dis_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS',FALSE);
	 p_usec_enr_dis_rec.status := 'E';
      END IF;

      IF p_usec_enr_dis_rec.location_cd IS NULL OR p_usec_enr_dis_rec.location_cd = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD','LEGACY_TOKENS',FALSE);
	 p_usec_enr_dis_rec.status := 'E';
      END IF;

      IF p_usec_enr_dis_rec.unit_class IS NULL OR p_usec_enr_dis_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CLASS','LEGACY_TOKENS',FALSE);
	p_usec_enr_dis_rec.status := 'E';
      END IF;

      IF p_usec_enr_dis_rec.administrative_unit_status IS NULL OR p_usec_enr_dis_rec.administrative_unit_status = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','ADMINISTRATIVE_UNIT_STATUS','LEGACY_TOKENS',FALSE);
	p_usec_enr_dis_rec.status := 'E';
      END IF;


    END validate_parameters;

    PROCEDURE validate_derivation(p_usec_enr_dis_rec IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dis_rec_type) AS

      l_c_cal_type    VARCHAR2(10);
      l_n_seq_num     NUMBER;
      l_d_start       igs_ca_inst_all.start_dt%TYPE;
      l_d_end         igs_ca_inst_all.end_dt%TYPE;
      l_c_ret_status  VARCHAR2(30);


    BEGIN

       -- Deriving the Calendar Type and Calendar Sequence Number
       igs_ge_gen_003.get_calendar_instance(p_usec_enr_dis_rec.teach_cal_alternate_code,'''TEACHING''',  l_c_cal_type, l_n_seq_num, l_d_start, l_d_end, l_c_ret_status);
       IF l_c_ret_status <> 'SINGLE' THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS', FALSE);
	   p_usec_enr_dis_rec.status := 'E';
       END IF;

       -- Deriving the Unit Offering Option Identifier
       l_c_ret_status := NULL;
       igs_ps_validate_lgcy_pkg.get_uoo_id(p_usec_enr_dis_rec.unit_cd, p_usec_enr_dis_rec.version_number, l_c_cal_type, l_n_seq_num, p_usec_enr_dis_rec.location_cd, p_usec_enr_dis_rec.unit_class, l_n_uoo_id, l_c_ret_status);
       IF l_c_ret_status IS NOT NULL THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','UNIT_SECTION','LEGACY_TOKENS', FALSE);
	  p_usec_enr_dis_rec.status := 'E';
       END IF;

    END validate_derivation;

    PROCEDURE validate_db_cons(p_usec_enr_dis_rec IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dis_rec_type,p_insert_update IN VARCHAR2) AS
      CURSOR cur_amd_unit_stat(cp_administrative_unit_status IN igs_ad_adm_unit_stat.administrative_unit_status%TYPE) IS
      SELECT 'X'
      FROM  igs_ad_adm_unit_stat aus
      WHERE aus.administrative_unit_status = cp_administrative_unit_status
      AND aus.unit_attempt_status='DISCONTIN'
      AND aus.closed_ind ='N';
      l_c_var    VARCHAR2(1);

    BEGIN

      IF p_insert_update = 'I' THEN
	-- Unique Key Validation
	IF igs_en_usec_disc_dl_pkg.get_uk_for_validation ( x_uoo_id           => l_n_uoo_id,
						           x_administrative_unit_status => p_usec_enr_dis_rec.administrative_unit_status ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'ENR_DISCONTINUATION', 'LEGACY_TOKENS', FALSE);
	  p_usec_enr_dis_rec.status := 'W';
	  RETURN;
	END IF;

	--Administrative unit status validation (Fk)
	OPEN cur_amd_unit_stat(p_usec_enr_dis_rec.administrative_unit_status);
	FETCH cur_amd_unit_stat INTO l_c_var;
	IF cur_amd_unit_stat%NOTFOUND THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'ADMINISTRATIVE_UNIT_STATUS', 'LEGACY_TOKENS', FALSE);
         p_usec_enr_dis_rec.status := 'E';
	END IF;

      END IF;

      -- Foreign Key Checking
      --Check for the existence of the unit section
      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation (l_n_uoo_id ) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
         p_usec_enr_dis_rec.status := 'E';
      END IF;


      IF l_n_non_std_disc_dl_stp_id IS NOT NULL THEN
	IF NOT igs_en_nsd_dlstp_pkg.get_pk_for_validation ( l_n_non_std_disc_dl_stp_id) THEN
	   igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'NON_STD_DISC_DL_STP_ID', 'LEGACY_TOKENS', FALSE);
	   p_usec_enr_dis_rec.status := 'E';
	END IF;
      END IF;

    END validate_db_cons;

    -- Check for Update/Insert
    FUNCTION check_insert_update ( p_usec_enr_dis_rec IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dis_rec_type) RETURN VARCHAR2 IS

      CURSOR c_enr_disc IS
      SELECT 'X'
      FROM igs_en_usec_disc_dl
      WHERE uoo_id = l_n_uoo_id
      AND administrative_unit_status = p_usec_enr_dis_rec.administrative_unit_status;

      l_c_var  VARCHAR2(1);

    BEGIN

       OPEN c_enr_disc;
       FETCH c_enr_disc INTO l_c_var;
       IF c_enr_disc%FOUND THEN
	 CLOSE c_enr_disc;
	 RETURN 'U';
       ELSE
	 CLOSE c_enr_disc;
	 RETURN 'I';
       END IF;

    END check_insert_update;

    PROCEDURE Assign_defaults ( p_usec_enr_dis_rec IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dis_rec_type,p_insert_update IN VARCHAR2) AS

      CURSOR cur_usec(cp_uoo_id IN NUMBER) IS
      SELECT owner_org_unit_cd
      FROM   igs_ps_unit_ofr_opt_all
      WHERE  uoo_id=cp_uoo_id;
      l_c_org_unit_cd   igs_ps_unit_ofr_opt_all.owner_org_unit_cd%TYPE;

      CURSOR cur_disc_details (cp_org_unit_cd IN VARCHAR2,cp_administrative_unit_status IN VARCHAR2) IS
      SELECT formula_method,round_method,offset_duration,non_std_disc_dl_stp_id,offset_dt_code,org_unit_code,definition_code
      FROM igs_en_nsd_dlstp_all
      WHERE ((org_unit_code = cp_org_unit_cd AND definition_code = 'ORGANIZATIONAL_UNIT') OR definition_code = 'INSTITUTION')
      AND administrative_unit_status = cp_administrative_unit_status;
      l_cur_disc_details   cur_disc_details%ROWTYPE;

      CURSOR c_enr_disc IS
      SELECT *
      FROM igs_en_usec_disc_dl
      WHERE uoo_id = l_n_uoo_id
      AND administrative_unit_status = p_usec_enr_dis_rec.administrative_unit_status;
      l_c_enr_disc c_enr_disc%ROWTYPE;

      l_c_message     VARCHAR2(30);

    BEGIN

      IF p_insert_update = 'I' THEN
	   -- Dervie the attributes from the org/institution level table
	   OPEN cur_usec(l_n_uoo_id);
	   FETCH cur_usec INTO l_c_org_unit_cd;
	   CLOSE cur_usec;


	   OPEN cur_disc_details(l_c_org_unit_cd,p_usec_enr_dis_rec.administrative_unit_status);
	   FETCH cur_disc_details INTO  l_cur_disc_details;
	   IF cur_disc_details%FOUND THEN


	     l_n_non_std_disc_dl_stp_id :=l_cur_disc_details.non_std_disc_dl_stp_id;
	     l_c_org_unit_code := l_cur_disc_details.org_unit_code;
	     l_c_definition_code := l_cur_disc_details.definition_code;
	     l_c_formula_method := l_cur_disc_details.formula_method;
	     l_c_round_method := l_cur_disc_details.round_method;
	     l_n_offset_duration := l_cur_disc_details.offset_duration;
	     l_c_offset_dt_code := l_cur_disc_details.offset_dt_code;

	     l_d_enr_dl_date:= igs_ps_gen_004.recal_dl_date (
					   p_v_uoo_id        =>l_n_uoo_id,
					   p_formula_method  =>l_cur_disc_details.formula_method,
					   p_durationdays    =>l_n_duration_days,--out
					   p_round_method    =>l_cur_disc_details.round_method,
					   p_OffsetDuration  =>l_cur_disc_details.offset_duration,
					   p_OffsetDays      =>l_n_offset_days,--out
					   p_function_name   =>NULL,
					   p_setup_id        =>l_cur_disc_details.non_std_disc_dl_stp_id,
					   p_offset_dt_code  =>l_cur_disc_details.offset_dt_code,
					   p_msg 	     =>l_c_message  --out
					   );
	      IF p_usec_enr_dis_rec.usec_disc_dl_date IS NOT NULL THEN
		l_d_enr_dl_date := p_usec_enr_dis_rec.usec_disc_dl_date;
	      END IF;
           ELSE
	     IF p_usec_enr_dis_rec.usec_disc_dl_date IS NULL THEN
		igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','ENR_DISC_DATE','LEGACY_TOKENS',FALSE);
		p_usec_enr_dis_rec.status := 'E';
             ELSE
	        l_d_enr_dl_date := p_usec_enr_dis_rec.usec_disc_dl_date;
             END IF;
	   END IF;
           CLOSE cur_disc_details;

      ELSE --update

        OPEN c_enr_disc;
        FETCH c_enr_disc INTO l_c_enr_disc;
	CLOSE c_enr_disc;

         --Set the values to the databse values
	 l_n_non_std_disc_dl_stp_id :=l_c_enr_disc.non_std_disc_dl_stp_id;
	 l_c_org_unit_code := l_c_enr_disc.org_unit_code;
	 l_c_definition_code := l_c_enr_disc.definition_code;
	 l_c_formula_method := l_c_enr_disc.formula_method;
	 l_c_round_method := l_c_enr_disc.round_method;
	 l_n_offset_duration := l_c_enr_disc.offset_duration;
	 l_c_offset_dt_code := l_c_enr_disc.offset_dt_code;
	 l_n_duration_days :=  l_c_enr_disc.usec_disc_total_days;
	 l_n_offset_days :=    l_c_enr_disc.usec_disc_offset_days;

        IF l_c_enr_disc.non_std_disc_dl_stp_id IS NOT NULL THEN
	   -- Dervie the attributes from the org/institution level table
	   OPEN cur_usec(l_n_uoo_id);
	   FETCH cur_usec INTO l_c_org_unit_cd;
	   CLOSE cur_usec;


	   OPEN cur_disc_details(l_c_org_unit_cd,p_usec_enr_dis_rec.administrative_unit_status);
	   FETCH cur_disc_details INTO  l_cur_disc_details;
           IF cur_disc_details%FOUND THEN
	     IF (l_c_enr_disc.formula_method  <>  l_cur_disc_details.formula_method OR
		 l_c_enr_disc.round_method    <>  l_cur_disc_details.round_method   OR
		 l_c_enr_disc.offset_dt_code  <>  l_cur_disc_details.offset_dt_code OR
		 l_c_enr_disc.offset_duration <> l_cur_disc_details.offset_duration ) THEN

		   l_n_non_std_disc_dl_stp_id :=l_cur_disc_details.non_std_disc_dl_stp_id;
		   l_c_org_unit_code := l_cur_disc_details.org_unit_code;
		   l_c_definition_code := l_cur_disc_details.definition_code;
		   l_c_formula_method := l_cur_disc_details.formula_method;
		   l_c_round_method := l_cur_disc_details.round_method;
		   l_n_offset_duration := l_cur_disc_details.offset_duration;
		   l_c_offset_dt_code := l_cur_disc_details.offset_dt_code;

		   l_d_enr_dl_date:= igs_ps_gen_004.recal_dl_date (
						 p_v_uoo_id        =>l_n_uoo_id,
						 p_formula_method  =>l_cur_disc_details.formula_method,
						 p_durationdays    =>l_n_duration_days,--out
						 p_round_method    =>l_cur_disc_details.round_method,
						 p_OffsetDuration  =>l_cur_disc_details.offset_duration,
						 p_OffsetDays      =>l_n_offset_days,--out
						 p_function_name   =>NULL,
						 p_setup_id        =>l_cur_disc_details.non_std_disc_dl_stp_id,
						 p_offset_dt_code  =>l_cur_disc_details.offset_dt_code,
						 p_msg 	           =>l_c_message  --out
						 );

	     END IF;
           END IF;
   	   CLOSE cur_disc_details;

        END IF;

	IF p_usec_enr_dis_rec.usec_disc_dl_date IS NOT NULL THEN
	  l_d_enr_dl_date := p_usec_enr_dis_rec.usec_disc_dl_date;
	ELSE
	  l_d_enr_dl_date := l_c_enr_disc.usec_disc_dl_date;
	END IF;

      END IF; --insert/update

    END Assign_defaults;

    PROCEDURE Business_validation(p_usec_enr_dis_rec IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dis_rec_type) AS
      CURSOR cur_check_ns_usec(cp_n_uoo_id  IN NUMBER) IS
      SELECT 'X'
      FROM igs_ps_unit_ofr_opt_all
      WHERE uoo_id = cp_n_uoo_id
      AND non_std_usec_ind = 'Y';
      l_c_var    VARCHAR2(1);

      l_message_name VARCHAR2(30);

    BEGIN
      --Check if the unit is INACTIVE, then do not allow to import
      IF igs_ps_val_unit.crsp_val_iud_uv_dtl(p_usec_enr_dis_rec.unit_cd, p_usec_enr_dis_rec.version_number,l_message_name)=FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
	    fnd_msg_pub.add;
	    p_usec_enr_dis_rec.status := 'E';
      END IF;

      --Check if the Unit Scetion is not Not standard then insert/update is not allowed
      OPEN cur_check_ns_usec(l_n_uoo_id);
      FETCH cur_check_ns_usec INTO l_c_var;
      IF cur_check_ns_usec%NOTFOUND THEN
        fnd_message.set_name ( 'IGS', 'IGS_PS_NON_STD_USEC_NOT_IMP' );
	fnd_message.set_token('RECORD',igs_ps_validate_lgcy_pkg.get_lkup_meaning('ENR_DISCONTINUATION','LEGACY_TOKENS'));
        fnd_msg_pub.add;
      	/*igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_NON_STD_USEC_NOT_IMP','ENR_DISCONTINUATION','LEGACY_TOKENS',FALSE);*/
        p_usec_enr_dis_rec.status := 'E';
      END IF;
      CLOSE cur_check_ns_usec;

    END Business_validation;

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dis.start_logging_for',
                    'Unit Section Enrollment Discontinuation');
  END IF;

  p_c_rec_status := 'S';
  FOR I in 1..p_usec_enr_dis_tbl.LAST LOOP
     IF p_usec_enr_dis_tbl.EXISTS(I) THEN
	-- Initialize the variable use to store the derived values.
	l_n_uoo_id := NULL;
        l_n_non_std_disc_dl_stp_id :=NULL;
        l_c_org_unit_code :=NULL;
        l_c_definition_code :=NULL;
        l_c_formula_method :=NULL;
        l_c_round_method :=NULL;
        l_n_offset_duration :=NULL;
        l_c_offset_dt_code :=NULL;
        l_n_duration_days :=NULL;
        l_n_offset_days :=NULL;
        l_d_enr_dl_date :=NULL;

	p_usec_enr_dis_tbl(I).status := 'S';
	p_usec_enr_dis_tbl(I).msg_from := fnd_msg_pub.count_msg;
	trim_values(p_usec_enr_dis_tbl(I));
	validate_parameters(p_usec_enr_dis_tbl(I));

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dis.status_after_validate_parameters',
	  'Unit code:'||p_usec_enr_dis_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dis_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_enr_dis_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dis_tbl(I).location_cd||'  '||'Unit Class:'||
	  p_usec_enr_dis_tbl(I).unit_class||'  '||'Administrative_unit_status:'||p_usec_enr_dis_tbl(I).administrative_unit_status||'  '||'Status:'||
	  p_usec_enr_dis_tbl(I).status);
        END IF;

	IF p_usec_enr_dis_tbl(I).status = 'S' THEN
	   validate_derivation(p_usec_enr_dis_tbl(I));

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dis.status_after_validate_derivation',
	      'Unit code:'||p_usec_enr_dis_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dis_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_enr_dis_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dis_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_enr_dis_tbl(I).unit_class||'  '||'Administrative_unit_status:'||p_usec_enr_dis_tbl(I).administrative_unit_status||'  '||'Status:'||
	      p_usec_enr_dis_tbl(I).status);
            END IF;

	END IF;

	--Find out whether it is insert/update of record
	l_insert_update:='I';
	IF p_usec_enr_dis_tbl(I).status = 'S' AND p_calling_context IN ('G','S') THEN
	  l_insert_update:= check_insert_update(p_usec_enr_dis_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dis.status_after_check_insert_update',
	    'Unit code:'||p_usec_enr_dis_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dis_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_enr_dis_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dis_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_enr_dis_tbl(I).unit_class||'  '||'Administrative_unit_status:'||p_usec_enr_dis_tbl(I).administrative_unit_status||'  '||'Status:'||
	    p_usec_enr_dis_tbl(I).status);
          END IF;

	END IF;

	IF p_usec_enr_dis_tbl(I).status = 'S' AND p_calling_context = 'S' THEN
	  IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	    fnd_msg_pub.add;
	    p_usec_enr_dis_tbl(I).status := 'A';
	  END IF;

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dis.status_after_check_import_allowed',
	    'Unit code:'||p_usec_enr_dis_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dis_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_enr_dis_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dis_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_enr_dis_tbl(I).unit_class||'  '||'Administrative_unit_status:'||p_usec_enr_dis_tbl(I).administrative_unit_status||'  '||'Status:'||
	    p_usec_enr_dis_tbl(I).status);
          END IF;

	END IF;

	IF p_usec_enr_dis_tbl(I).status = 'S' THEN
	  assign_defaults(p_usec_enr_dis_tbl(I),l_insert_update);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dis.status_after_assign_defaults',
	    'Unit code:'||p_usec_enr_dis_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dis_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_enr_dis_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dis_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_enr_dis_tbl(I).unit_class||'  '||'Administrative_unit_status:'||p_usec_enr_dis_tbl(I).administrative_unit_status||'  '||'Status:'||
	    p_usec_enr_dis_tbl(I).status);
          END IF;

	END IF;

	IF p_usec_enr_dis_tbl(I).status = 'S' THEN
	   validate_db_cons ( p_usec_enr_dis_tbl(I),l_insert_update);

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dis.status_after_validate_db_cons',
	     'Unit code:'||p_usec_enr_dis_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dis_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_enr_dis_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dis_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_enr_dis_tbl(I).unit_class||'  '||'Administrative_unit_status:'||p_usec_enr_dis_tbl(I).administrative_unit_status||'  '||'Status:'||
	     p_usec_enr_dis_tbl(I).status);
           END IF;

	END IF;


	--Business validations
	IF p_usec_enr_dis_tbl(I).status = 'S' THEN
	  Business_validation(p_usec_enr_dis_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dis.status_after_Business_validation',
	     'Unit code:'||p_usec_enr_dis_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dis_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_enr_dis_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dis_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_enr_dis_tbl(I).unit_class||'  '||'Administrative_unit_status:'||p_usec_enr_dis_tbl(I).administrative_unit_status||'  '||'Status:'||
	     p_usec_enr_dis_tbl(I).status);
          END IF;

	END IF;

	IF p_usec_enr_dis_tbl(I).status = 'S' THEN

	  IF l_insert_update = 'I' THEN
	    INSERT INTO IGS_EN_USEC_DISC_DL(
	      usec_disc_dl_id        ,
	      non_std_disc_dl_stp_id ,
	      administrative_unit_status,
	      definition_code        ,
	      org_unit_code          ,
	      formula_method         ,
	      round_method           ,
	      offset_dt_code         ,
	      offset_duration        ,
	      uoo_id                 ,
	      usec_disc_dl_date      ,
	      usec_disc_total_days   ,
	      usec_disc_offset_days  ,
	      created_by,
	      creation_date,
	      last_updated_by,
	      last_update_date,
	      last_update_login )
	    VALUES (
	      igs_en_usec_disc_dl_s.NEXTVAL,
              l_n_non_std_disc_dl_stp_id,
              p_usec_enr_dis_tbl(I).administrative_unit_status,
 	      l_c_definition_code,
	      l_c_org_unit_code,
	      l_c_formula_method,
	      l_c_round_method,
	      l_c_offset_dt_code,
	      l_n_offset_duration,
	      l_n_uoo_id,
	      l_d_enr_dl_date,
	      l_n_duration_days,
	      l_n_offset_days,
	      g_n_user_id,
	      SYSDATE,
	      g_n_user_id,
	      SYSDATE,
	      g_n_login_id);

              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		 fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dis.Record_Inserted',
		 'Unit code:'||p_usec_enr_dis_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dis_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		 ||p_usec_enr_dis_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dis_tbl(I).location_cd||'  '||'Unit Class:'||
		 p_usec_enr_dis_tbl(I).unit_class||'  '||'Administrative_unit_status:'||p_usec_enr_dis_tbl(I).administrative_unit_status);
              END IF;

          ELSE
            UPDATE IGS_EN_USEC_DISC_DL SET
              non_std_disc_dl_stp_id = l_n_non_std_disc_dl_stp_id,
	      definition_code        = l_c_definition_code,
	      org_unit_code          = l_c_org_unit_code,
	      formula_method         = l_c_formula_method,
	      round_method           = l_c_round_method,
	      offset_dt_code         = l_c_offset_dt_code,
	      offset_duration        = l_n_offset_duration,
	      usec_disc_dl_date      = l_d_enr_dl_date,
	      usec_disc_total_days   = l_n_duration_days,
	      usec_disc_offset_days  = l_n_offset_days,
   	      last_updated_by        = g_n_user_id ,
	      last_update_date       = sysdate ,
	      last_update_login      = g_n_login_id
	    WHERE uoo_id=l_n_uoo_id AND administrative_unit_status=p_usec_enr_dis_tbl(I).administrative_unit_status;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	       fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dis.Record_Updated',
	       'Unit code:'||p_usec_enr_dis_tbl(I).unit_cd||'  '||'Version number:'||p_usec_enr_dis_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	       ||p_usec_enr_dis_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_enr_dis_tbl(I).location_cd||'  '||'Unit Class:'||
	       p_usec_enr_dis_tbl(I).unit_class||'  '||'Administrative_unit_status:'||p_usec_enr_dis_tbl(I).administrative_unit_status);
            END IF;

	  END IF;


	END IF;


	IF p_usec_enr_dis_tbl(I).status = 'S' THEN
	   p_usec_enr_dis_tbl(I).msg_from := NULL;
	   p_usec_enr_dis_tbl(I).msg_to := NULL;
	ELSIF  p_usec_enr_dis_tbl(I).status = 'A' THEN
	   p_usec_enr_dis_tbl(I).msg_from  := p_usec_enr_dis_tbl(I).msg_from + 1;
	   p_usec_enr_dis_tbl(I).msg_to := fnd_msg_pub.count_msg;
	ELSE
	   p_c_rec_status := p_usec_enr_dis_tbl(I).status;
	   p_usec_enr_dis_tbl(I).msg_from := p_usec_enr_dis_tbl(I).msg_from+1;
	   p_usec_enr_dis_tbl(I).msg_to := fnd_msg_pub.count_msg;
	   IF p_usec_enr_dis_tbl(I).status = 'E' THEN
	      RETURN;
	   END IF;
	END IF;

     END IF;
  END LOOP;


  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_enr_dis.after_import_status',p_c_rec_status);
  END IF;

END create_usec_enr_dis;


  PROCEDURE create_usec_ret(p_usec_ret_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_ret_tbl_type,
			    p_c_rec_status OUT NOCOPY VARCHAR2,
			    p_calling_context IN VARCHAR2) IS
  /***********************************************************************************************

  Created By:         sarakshi
  Date Created By:    01-Jun-2005
  Purpose:            This procedure imports unit section Retention.

  Known limitations,enhancements,remarks:
  Change History
  Who        When         What
  sommukhe   18-Jan-2006  Bug#4926548, modified cur_fee to address the performance issue. Created local procedures and functions.
  ***********************************************************************************************/
    l_c_cal_type    VARCHAR2(10);
    l_n_seq_num     NUMBER;
    l_n_uoo_id      igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_n_non_std_usec_rtn_id   NUMBER;
    l_insert_update VARCHAR2(1);

    PROCEDURE trim_values ( p_usec_ret_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ret_rec_type) AS
    BEGIN

      p_usec_ret_rec.unit_cd := TRIM(p_usec_ret_rec.unit_cd);
      p_usec_ret_rec.version_number := TRIM(p_usec_ret_rec.version_number);
      p_usec_ret_rec.teach_cal_alternate_code := TRIM(p_usec_ret_rec.teach_cal_alternate_code);
      p_usec_ret_rec.location_cd := TRIM(p_usec_ret_rec.location_cd);
      p_usec_ret_rec.unit_class := TRIM(p_usec_ret_rec.unit_class);
      p_usec_ret_rec.definition_level := TRIM(p_usec_ret_rec.definition_level);
      p_usec_ret_rec.fee_type := TRIM(p_usec_ret_rec.fee_type);
      p_usec_ret_rec.formula_method := TRIM(p_usec_ret_rec.formula_method);
      p_usec_ret_rec.round_method := TRIM(p_usec_ret_rec.round_method);
      p_usec_ret_rec.incl_wkend_duration_flag := TRIM(p_usec_ret_rec.incl_wkend_duration_flag);

    END trim_values;

    PROCEDURE validate_parameters( p_usec_ret_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ret_rec_type) AS

    BEGIN
      p_usec_ret_rec.status:='S';


      IF p_usec_ret_rec.unit_cd IS NULL OR p_usec_ret_rec.unit_cd = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CD','LEGACY_TOKENS',FALSE);
         p_usec_ret_rec.status := 'E';
      END IF;

      IF p_usec_ret_rec.version_number IS NULL OR p_usec_ret_rec.version_number = FND_API.G_MISS_NUM THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_VER_NUM','LEGACY_TOKENS',FALSE);
         p_usec_ret_rec.status := 'E';
      END IF;

      IF p_usec_ret_rec.teach_cal_alternate_code IS NULL OR p_usec_ret_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS',FALSE);
	 p_usec_ret_rec.status := 'E';
      END IF;

      IF p_usec_ret_rec.location_cd IS NULL OR p_usec_ret_rec.location_cd = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD','LEGACY_TOKENS',FALSE);
	 p_usec_ret_rec.status := 'E';
      END IF;

      IF p_usec_ret_rec.unit_class IS NULL OR p_usec_ret_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CLASS','LEGACY_TOKENS',FALSE);
	p_usec_ret_rec.status := 'E';
      END IF;

      IF p_usec_ret_rec.definition_level IS NULL OR p_usec_ret_rec.definition_level = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','DEFINITION_LEVEL','LEGACY_TOKENS',FALSE);
	p_usec_ret_rec.status := 'E';
      END IF;

      IF (p_usec_ret_rec.fee_type IS NULL OR p_usec_ret_rec.fee_type = FND_API.G_MISS_CHAR) AND p_usec_ret_rec.definition_level='UNIT_SECTION_FEE_TYPE' THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','FEE_TYPE','IGS_FI_LOCKBOX',FALSE);
	p_usec_ret_rec.status := 'E';
      END IF;

      IF p_usec_ret_rec.formula_method IS NULL OR p_usec_ret_rec.formula_method = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','FORMULA_METHOD','LEGACY_TOKENS',FALSE);
	p_usec_ret_rec.status := 'E';
      END IF;

      IF p_usec_ret_rec.round_method IS NULL OR p_usec_ret_rec.round_method = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','ROUND_METHOD','LEGACY_TOKENS',FALSE);
	p_usec_ret_rec.status := 'E';
      END IF;

      IF p_usec_ret_rec.incl_wkend_duration_flag IS NULL OR p_usec_ret_rec.incl_wkend_duration_flag = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','INCL_WKEND_DURATION_FLAG','LEGACY_TOKENS',FALSE);
	p_usec_ret_rec.status := 'E';
      END IF;

      -- valid values of definition_level is 'UNIT_SECTION_FEE_TYPE' , 'UNIT_SECTION'
      IF  p_usec_ret_rec.definition_level NOT IN  ('UNIT_SECTION_FEE_TYPE' , 'UNIT_SECTION') THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','DEFINITION_LEVEL','LEGACY_TOKENS',FALSE);
            p_usec_ret_rec.status :='E';
      END IF;

      --Fee type should not be there for definition_level = UNIT_SECTION
      IF  p_usec_ret_rec.definition_level = 'UNIT_SECTION' AND  p_usec_ret_rec.fee_type IS NOT NULL THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','FEE_TYPE','IGS_FI_LOCKBOX',FALSE);
            p_usec_ret_rec.status :='E';
      END IF;

    END validate_parameters;

    PROCEDURE validate_derivation(p_usec_ret_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ret_rec_type) AS

      l_d_start       igs_ca_inst_all.start_dt%TYPE;
      l_d_end         igs_ca_inst_all.end_dt%TYPE;
      l_c_ret_status  VARCHAR2(30);


    BEGIN

       -- Deriving the Calendar Type and Calendar Sequence Number
       igs_ge_gen_003.get_calendar_instance(p_usec_ret_rec.teach_cal_alternate_code,'''TEACHING''',  l_c_cal_type, l_n_seq_num, l_d_start, l_d_end, l_c_ret_status);
       IF l_c_ret_status <> 'SINGLE' THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS', FALSE);
	   p_usec_ret_rec.status := 'E';
       END IF;

       -- Deriving the Unit Offering Option Identifier
       l_c_ret_status := NULL;
       igs_ps_validate_lgcy_pkg.get_uoo_id(p_usec_ret_rec.unit_cd, p_usec_ret_rec.version_number, l_c_cal_type, l_n_seq_num, p_usec_ret_rec.location_cd, p_usec_ret_rec.unit_class, l_n_uoo_id, l_c_ret_status);
       IF l_c_ret_status IS NOT NULL THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','UNIT_SECTION','LEGACY_TOKENS', FALSE);
	  p_usec_ret_rec.status := 'E';
       END IF;

    END validate_derivation;

    PROCEDURE validate_db_cons(p_usec_ret_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ret_rec_type,p_insert_update IN VARCHAR2) AS

    BEGIN

      IF p_insert_update = 'I' AND p_usec_ret_rec.definition_level='UNIT_SECTION_FEE_TYPE' THEN
	-- Unique Key Validation
	IF igs_ps_nsus_rtn_pkg.get_uk_for_validation ( x_uoo_id   => l_n_uoo_id,
						       x_fee_type => p_usec_ret_rec.fee_type ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'RETENTION', 'LEGACY_TOKENS', FALSE);
	  p_usec_ret_rec.status := 'W';
	  RETURN;
	END IF;

	--Check for the existence of the Fee Type
	IF NOT igs_fi_fee_type_pkg.get_pk_for_validation (p_usec_ret_rec.fee_type ) THEN
	   igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'FEE_TYPE', 'IGS_FI_LOCKBOX', FALSE);
	   p_usec_ret_rec.status := 'E';
	END IF;

      END IF;


      --Check constraint
      BEGIN
         igs_ps_nsus_rtn_pkg.check_constraints('FORMULA_METHOD', p_usec_ret_rec.formula_method);
      EXCEPTION
         WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','FORMULA_METHOD','LEGACY_TOKENS',TRUE);
            p_usec_ret_rec.status :='E';
      END;

      BEGIN
         igs_ps_nsus_rtn_pkg.check_constraints('ROUND_METHOD', p_usec_ret_rec.round_method);
      EXCEPTION
         WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','ROUND_METHOD','LEGACY_TOKENS',TRUE);
            p_usec_ret_rec.status :='E';
      END;

      BEGIN
         igs_ps_nsus_rtn_pkg.check_constraints('INCL_WKEND_DURATION_FLAG', p_usec_ret_rec.incl_wkend_duration_flag);
      EXCEPTION
         WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','INCL_WKEND_DURATION_FLAG','LEGACY_TOKENS',TRUE);
            p_usec_ret_rec.status :='E';
      END;


      -- Foreign Key Checking
      --Check for the existence of the unit section
      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation (l_n_uoo_id ) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
         p_usec_ret_rec.status := 'E';
      END IF;



    END validate_db_cons;

    -- Check for Update/Insert
    FUNCTION check_insert_update ( p_usec_ret_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ret_rec_type) RETURN VARCHAR2 IS

      CURSOR c_ret_usec IS
      SELECT non_std_usec_rtn_id
      FROM igs_ps_nsus_rtn
      WHERE uoo_id = l_n_uoo_id
      AND   definition_code='UNIT_SECTION';

      CURSOR c_ret_usec_fee IS
      SELECT non_std_usec_rtn_id
      FROM igs_ps_nsus_rtn
      WHERE uoo_id = l_n_uoo_id
      AND   fee_type = p_usec_ret_rec.fee_type;

    BEGIN

       IF p_usec_ret_rec.definition_level='UNIT_SECTION' THEN
	 OPEN c_ret_usec;
	 FETCH c_ret_usec INTO l_n_non_std_usec_rtn_id;
	 IF c_ret_usec%FOUND THEN
	   CLOSE c_ret_usec;
	   RETURN 'U';
	 ELSE
	   CLOSE c_ret_usec;
	   RETURN 'I';
	 END IF;
      ELSE
	 OPEN c_ret_usec_fee;
	 FETCH c_ret_usec_fee INTO l_n_non_std_usec_rtn_id;
	 IF c_ret_usec_fee%FOUND THEN
	   CLOSE c_ret_usec_fee;
	   RETURN 'U';
	 ELSE
	   CLOSE c_ret_usec_fee;
	   RETURN 'I';
	 END IF;
      END IF;

    END check_insert_update;

    PROCEDURE Business_validation(p_usec_ret_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ret_rec_type,p_insert_update IN VARCHAR2) AS
      CURSOR cur_check_ns_usec(cp_n_uoo_id  IN NUMBER) IS
      SELECT 'X'
      FROM igs_ps_unit_ofr_opt_all
      WHERE uoo_id = cp_n_uoo_id
      AND non_std_usec_ind = 'Y';
      l_c_var    VARCHAR2(1);

      l_message_name VARCHAR2(30);

      CURSOR cur_fee(cp_fee_type IN VARCHAR2) IS
      SELECT ci.cal_type cal_type,ci.sequence_number sequence_number
      FROM  igs_fi_fee_type ft,
            igs_fi_f_typ_ca_inst ftci,
	    igs_ca_inst ci,
	    igs_ca_type ct,
	    igs_ca_stat cs
      WHERE ft.s_fee_type IN ('TUTNFEE', 'OTHER', 'SPECIAL', 'AUDIT')
      AND   ft.closed_ind = 'N'
      AND   ft.fee_type = ftci.fee_type
      AND   ft.fee_type = cp_fee_type
      AND   ftci.fee_cal_type = ci.cal_type
      AND   ftci.fee_ci_sequence_number = ci.sequence_number
      AND   ci.cal_type = ct.cal_type
      AND   ct.s_cal_cat = 'FEE'
      AND   ci.cal_status = cs.cal_status
      AND   cs.s_cal_status = 'ACTIVE';
      cur_fee_rec cur_fee%ROWTYPE;

      CURSOR cur_check_formula (cp_non_std_usec_rtn_id IN NUMBER) IS
      SELECT 'X'
      FROM   igs_ps_nsus_rtn nr,
             igs_ps_nsus_rtn_dtl nrd
      WHERE  nr.non_std_usec_rtn_id = nrd.non_std_usec_rtn_id
      AND    nr.non_std_usec_rtn_id = cp_non_std_usec_rtn_id
      AND    p_usec_ret_rec.formula_method IN ('P','M')
      AND    nrd.offset_value > 100;

      CURSOR c_cur(cp_non_std_usec_rtn_id igs_ps_nsus_rtn_dtl.non_std_usec_rtn_id%TYPE) IS
      SELECT *
      FROM   igs_ps_nsus_rtn_dtl a
      WHERE  non_std_usec_rtn_id = cp_non_std_usec_rtn_id
      AND    override_date_flag  = 'N';
      l_offset_date DATE;

       TYPE teach_cal_rec IS RECORD(
				 cal_type igs_ca_inst_all.cal_type%TYPE,
				 sequence_number igs_ca_inst_all.sequence_number%TYPE
				 );
      TYPE teachCalendar IS TABLE OF teach_cal_rec INDEX BY BINARY_INTEGER;
      teachCalendar_tbl teachCalendar;
      l_n_counter NUMBER(10);
      l_c_proceed BOOLEAN ;


      PROCEDURE createCalendar  IS

      CURSOR cur_cal_teach(cp_load_cal igs_ca_teach_to_load_v.load_cal_type%TYPE,
			   cp_load_seq igs_ca_teach_to_load_v.load_ci_sequence_number%TYPE) IS
      SELECT sup_cal_type,sup_ci_sequence_number
      FROM   igs_ca_inst_rel
      WHERE sub_cal_type = cp_load_cal
      AND sub_ci_sequence_number = cp_load_seq;

      CURSOR cur_cal_load IS
      SELECT load_cal_type,load_ci_sequence_number
      FROM   igs_ca_teach_to_load_v
      WHERE  teach_cal_type=l_c_cal_type
      AND    teach_ci_sequence_number=l_n_seq_num;

      BEGIN
	 --populate the pl-sql table with the superior calendar's by mapping the teach calendars.
	 l_n_counter :=1;
	 FOR rec_cur_cal_load IN cur_cal_load LOOP
	     FOR rec_cur_cal_teach IN cur_cal_teach(rec_cur_cal_load.load_cal_type ,rec_cur_cal_load.load_ci_sequence_number) LOOP
		teachCalendar_tbl(l_n_counter).cal_type :=rec_cur_cal_teach.sup_cal_type;
		teachCalendar_tbl(l_n_counter).sequence_number :=rec_cur_cal_teach.sup_ci_sequence_number;
		l_n_counter:=l_n_counter+1;
	     END LOOP;
	 END LOOP;

      END createCalendar;

      FUNCTION testCalendar(cp_cal_type igs_ca_inst_all.cal_type%TYPE,
			    cp_sequence_number igs_ca_inst_all.sequence_number%TYPE)  RETURN BOOLEAN AS
      BEGIN
	IF teachCalendar_tbl.EXISTS(1) THEN
	  FOR i IN 1..teachCalendar_tbl.last LOOP
	       IF cp_cal_type=teachCalendar_tbl(i).cal_type AND
		  cp_sequence_number=teachCalendar_tbl(i).sequence_number THEN
		  RETURN TRUE;
	       END IF;
	  END LOOP;
	END IF;
	RETURN FALSE;
      END testCalendar;

    BEGIN
       --Store the superior calendars in a pl-sql tables for the input teaching calendars
       createCalendar;
      --Check if the unit is INACTIVE, then do not allow to import
      IF igs_ps_val_unit.crsp_val_iud_uv_dtl(p_usec_ret_rec.unit_cd, p_usec_ret_rec.version_number,l_message_name)=FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
	    fnd_msg_pub.add;
	    p_usec_ret_rec.status := 'E';
      END IF;

      --Check if the Unit Section is not Not standard then insert/update is not allowed
      OPEN cur_check_ns_usec(l_n_uoo_id);
      FETCH cur_check_ns_usec INTO l_c_var;
      IF cur_check_ns_usec%NOTFOUND THEN
        fnd_message.set_name ( 'IGS', 'IGS_PS_NON_STD_USEC_NOT_IMP' );
	fnd_message.set_token('RECORD',igs_ps_validate_lgcy_pkg.get_lkup_meaning('RETENTION','LEGACY_TOKENS'));
        fnd_msg_pub.add;
	/*igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_NON_STD_USEC_NOT_IMP','RETENTION','LEGACY_TOKENS',FALSE);*/
	p_usec_ret_rec.status := 'E';
      END IF;
      CLOSE cur_check_ns_usec;

      IF p_insert_update = 'I' THEN

	IF p_usec_ret_rec.fee_type IS NOT NULL THEN
  	  l_c_proceed:= FALSE;
	  FOR rec_cur_fee IN cur_fee(p_usec_ret_rec.fee_type) LOOP
	    IF testCalendar(rec_cur_fee.cal_type ,rec_cur_fee.sequence_number ) THEN
	      l_c_proceed:= TRUE;
	      EXIT;
	    END IF;
          END LOOP;

	  IF l_c_proceed = FALSE THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'FEE_TYPE', 'IGS_FI_LOCKBOX', FALSE);
	    p_usec_ret_rec.status := 'E';
	  END IF;
        END IF;

      END IF;

      IF teachCalendar_tbl.EXISTS(1) THEN
        teachCalendar_tbl.DELETE;
      END IF;


      IF p_insert_update = 'U' THEN
        --If formula method is 'P'/'M' and any details exists such that offset is greater than 100 then it is an error condition
	OPEN cur_check_formula(l_n_non_std_usec_rtn_id);
	FETCH cur_check_formula INTO l_c_var;
	IF cur_check_formula%FOUND THEN
	  fnd_message.set_name ( 'IGS', 'IGS_PS_RTN_FORMULA_INVALID' );
	  fnd_msg_pub.add;
	  p_usec_ret_rec.status := 'E';
	END IF;
	CLOSE cur_check_formula;

        IF p_usec_ret_rec.status = 'S' THEN
          --update the offset date for the child records

	  FOR l_c_rec IN c_cur( l_n_non_std_usec_rtn_id) LOOP
	    l_offset_date := igs_ps_gen_004.f_retention_offset_date(
			      p_n_uoo_id              => l_n_uoo_id,
                              p_c_formula_method      => p_usec_ret_rec.formula_method,
			      p_c_round_method        => p_usec_ret_rec.round_method,
			      p_c_incl_wkend_duration => p_usec_ret_rec.incl_wkend_duration_flag,
		              p_n_offset_value        => l_c_rec.offset_value
			    );


	    UPDATE igs_ps_nsus_rtn_dtl SET
	      offset_date            = l_offset_date,
	      last_updated_by        = g_n_user_id ,
	      last_update_date       = sysdate ,
	      last_update_login      = g_n_login_id
	    WHERE non_std_usec_rtn_dtl_id = l_c_rec.non_std_usec_rtn_dtl_id;

          END LOOP;
        END IF;

      END IF;

    END Business_validation;

  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret.start_logging_for',
                    'Unit Section Retention ');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_usec_ret_tbl.LAST LOOP
       IF p_usec_ret_tbl.EXISTS(I) THEN
	  -- Initialize the variable use to store the derived values.
	  l_c_cal_type :=NULL;
	  l_n_seq_num :=NULL;
	  l_n_uoo_id := NULL;
          l_n_non_std_usec_rtn_id :=NULL;

	  p_usec_ret_tbl(I).status := 'S';
	  p_usec_ret_tbl(I).msg_from := fnd_msg_pub.count_msg;
	  trim_values(p_usec_ret_tbl(I));
	  validate_parameters(p_usec_ret_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret.status_after_validate_parameters',
	    'Unit code:'||p_usec_ret_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_ret_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_ret_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_tbl(I).fee_type||'  '||'definition_level:'
	    ||p_usec_ret_tbl(I).definition_level||'  '||'Status:'||p_usec_ret_tbl(I).status);
          END IF;


	  IF p_usec_ret_tbl(I).status = 'S' THEN
	     validate_derivation(p_usec_ret_tbl(I));

	      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret.status_after_validate_derivation',
		'Unit code:'||p_usec_ret_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		||p_usec_ret_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_tbl(I).location_cd||'  '||'Unit Class:'||
		p_usec_ret_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_tbl(I).fee_type||'  '||'definition_level:'
		||p_usec_ret_tbl(I).definition_level||'  '||'Status:'||p_usec_ret_tbl(I).status);
	      END IF;

	  END IF;

	  --Find out whether it is insert/update of record
	  l_insert_update:='I';
	  IF p_usec_ret_tbl(I).status = 'S' AND p_calling_context IN ('G','S') THEN
	    l_insert_update:= check_insert_update(p_usec_ret_tbl(I));

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret.status_after_check_insert_update',
	      'Unit code:'||p_usec_ret_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_ret_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_ret_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_tbl(I).fee_type||'  '||'definition_level:'
	      ||p_usec_ret_tbl(I).definition_level||'  '||'Status:'||p_usec_ret_tbl(I).status);
	    END IF;

	  END IF;

	  IF p_usec_ret_tbl(I).status = 'S' AND p_calling_context = 'S'  THEN
	    IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	      fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	      fnd_msg_pub.add;
	      p_usec_ret_tbl(I).status := 'A';
	    END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret.status_after_check_import_allowed',
	      'Unit code:'||p_usec_ret_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_ret_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_ret_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_tbl(I).fee_type||'  '||'definition_level:'
	      ||p_usec_ret_tbl(I).definition_level||'  '||'Status:'||p_usec_ret_tbl(I).status);
	    END IF;

	  END IF;


	  IF p_usec_ret_tbl(I).status = 'S' THEN
	     validate_db_cons ( p_usec_ret_tbl(I),l_insert_update);

             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	       fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret.status_after_validate_db_cons',
	       'Unit code:'||p_usec_ret_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	       ||p_usec_ret_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_tbl(I).location_cd||'  '||'Unit Class:'||
	       p_usec_ret_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_tbl(I).fee_type||'  '||'definition_level:'
	       ||p_usec_ret_tbl(I).definition_level||'  '||'Status:'||p_usec_ret_tbl(I).status);
	     END IF;

	  END IF;


	  --Business validations
	  IF p_usec_ret_tbl(I).status = 'S' THEN
	    Business_validation(p_usec_ret_tbl(I),l_insert_update);

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	       fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret.status_after_Business_validation',
	       'Unit code:'||p_usec_ret_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	       ||p_usec_ret_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_tbl(I).location_cd||'  '||'Unit Class:'||
	       p_usec_ret_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_tbl(I).fee_type||'  '||'definition_level:'
	       ||p_usec_ret_tbl(I).definition_level||'  '||'Status:'||p_usec_ret_tbl(I).status);
	     END IF;

	  END IF;

	  IF p_usec_ret_tbl(I).status = 'S' THEN

	    IF l_insert_update = 'I' THEN
	      INSERT INTO IGS_PS_NSUS_RTN(
		non_std_usec_rtn_id,
		uoo_id,
		fee_type,
		definition_code,
		formula_method,
		round_method,
		incl_wkend_duration_flag,
                created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login )
	      VALUES (
                igs_ps_nsus_rtn_s.NEXTVAL,
		l_n_uoo_id,
		p_usec_ret_tbl(I).fee_type,
		p_usec_ret_tbl(I).definition_level,
		p_usec_ret_tbl(I).formula_method,
		p_usec_ret_tbl(I).round_method,
		p_usec_ret_tbl(I).incl_wkend_duration_flag,
		g_n_user_id,
		SYSDATE,
		g_n_user_id,
		SYSDATE,
		g_n_login_id);

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret.Record_Inserted',
		  'Unit code:'||p_usec_ret_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		  ||p_usec_ret_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_tbl(I).location_cd||'  '||'Unit Class:'||
		  p_usec_ret_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_tbl(I).fee_type||'  '||'definition_level:'
		  ||p_usec_ret_tbl(I).definition_level);
	        END IF;


	    ELSE
	      UPDATE IGS_PS_NSUS_RTN SET
		formula_method = p_usec_ret_tbl(I).formula_method,
		round_method = p_usec_ret_tbl(I).round_method,
		incl_wkend_duration_flag = p_usec_ret_tbl(I).incl_wkend_duration_flag,
		last_updated_by        = g_n_user_id ,
		last_update_date       = sysdate ,
		last_update_login      = g_n_login_id
	      WHERE non_std_usec_rtn_id=l_n_non_std_usec_rtn_id;

              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret.Record_Updated',
		'Unit code:'||p_usec_ret_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		||p_usec_ret_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_tbl(I).location_cd||'  '||'Unit Class:'||
		p_usec_ret_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_tbl(I).fee_type||'  '||'definition_level:'
		||p_usec_ret_tbl(I).definition_level);
	      END IF;

	    END IF;


	  END IF;


	  IF p_usec_ret_tbl(I).status = 'S' THEN
	     p_usec_ret_tbl(I).msg_from := NULL;
	     p_usec_ret_tbl(I).msg_to := NULL;
	  ELSIF  p_usec_ret_tbl(I).status = 'A' THEN
	     p_usec_ret_tbl(I).msg_from  := p_usec_ret_tbl(I).msg_from + 1;
	     p_usec_ret_tbl(I).msg_to := fnd_msg_pub.count_msg;
	  ELSE
	     p_c_rec_status := p_usec_ret_tbl(I).status;
	     p_usec_ret_tbl(I).msg_from := p_usec_ret_tbl(I).msg_from+1;
	     p_usec_ret_tbl(I).msg_to := fnd_msg_pub.count_msg;
	     IF p_usec_ret_tbl(I).status = 'E' THEN
		RETURN;
	     END IF;
	  END IF;

       END IF;
    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret.after_import_status',p_c_rec_status);
    END IF;

  END create_usec_ret;

  PROCEDURE create_usec_ret_dtl(p_usec_ret_dtl_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_ret_dtl_tbl_type,
			        p_c_rec_status OUT NOCOPY VARCHAR2,
			        p_calling_context IN VARCHAR2) IS
  /***********************************************************************************************

  Created By:         sarakshi
  Date Created By:    01-Jun-2005
  Purpose:            This procedure imports unit section Retention Deatils.

  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
  ***********************************************************************************************/
    l_n_uoo_id      igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_n_non_std_usec_rtn_id   NUMBER;
    l_d_offset_date           DATE;
    l_insert_update VARCHAR2(1);

    PROCEDURE trim_values ( p_usec_ret_dtl_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ret_dtl_rec_type) AS
    BEGIN

      p_usec_ret_dtl_rec.unit_cd := TRIM(p_usec_ret_dtl_rec.unit_cd);
      p_usec_ret_dtl_rec.version_number := TRIM(p_usec_ret_dtl_rec.version_number);
      p_usec_ret_dtl_rec.teach_cal_alternate_code := TRIM(p_usec_ret_dtl_rec.teach_cal_alternate_code);
      p_usec_ret_dtl_rec.location_cd := TRIM(p_usec_ret_dtl_rec.location_cd);
      p_usec_ret_dtl_rec.unit_class := TRIM(p_usec_ret_dtl_rec.unit_class);
      p_usec_ret_dtl_rec.definition_level := TRIM(p_usec_ret_dtl_rec.definition_level);
      p_usec_ret_dtl_rec.fee_type := TRIM(p_usec_ret_dtl_rec.fee_type);
      p_usec_ret_dtl_rec.offset_value := TRIM(p_usec_ret_dtl_rec.offset_value);
      p_usec_ret_dtl_rec.retention_percent := TRIM(p_usec_ret_dtl_rec.retention_percent);
      p_usec_ret_dtl_rec.retention_amount := TRIM(p_usec_ret_dtl_rec.retention_amount);
      p_usec_ret_dtl_rec.override_date_flag := TRIM(p_usec_ret_dtl_rec.override_date_flag);
      p_usec_ret_dtl_rec.offset_date := TRUNC(p_usec_ret_dtl_rec.offset_date);

    END trim_values;

    PROCEDURE validate_parameters( p_usec_ret_dtl_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ret_dtl_rec_type) AS

    BEGIN
      p_usec_ret_dtl_rec.status:='S';


      IF p_usec_ret_dtl_rec.unit_cd IS NULL OR p_usec_ret_dtl_rec.unit_cd = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CD','LEGACY_TOKENS',FALSE);
         p_usec_ret_dtl_rec.status := 'E';
      END IF;

      IF p_usec_ret_dtl_rec.version_number IS NULL OR p_usec_ret_dtl_rec.version_number = FND_API.G_MISS_NUM THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_VER_NUM','LEGACY_TOKENS',FALSE);
         p_usec_ret_dtl_rec.status := 'E';
      END IF;

      IF p_usec_ret_dtl_rec.teach_cal_alternate_code IS NULL OR p_usec_ret_dtl_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS',FALSE);
	 p_usec_ret_dtl_rec.status := 'E';
      END IF;

      IF p_usec_ret_dtl_rec.location_cd IS NULL OR p_usec_ret_dtl_rec.location_cd = FND_API.G_MISS_CHAR THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD','LEGACY_TOKENS',FALSE);
	 p_usec_ret_dtl_rec.status := 'E';
      END IF;

      IF p_usec_ret_dtl_rec.unit_class IS NULL OR p_usec_ret_dtl_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CLASS','LEGACY_TOKENS',FALSE);
	p_usec_ret_dtl_rec.status := 'E';
      END IF;

      IF p_usec_ret_dtl_rec.definition_level IS NULL OR p_usec_ret_dtl_rec.definition_level = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','DEFINITION_LEVEL','LEGACY_TOKENS',FALSE);
	p_usec_ret_dtl_rec.status := 'E';
      END IF;

      IF (p_usec_ret_dtl_rec.fee_type IS NULL OR p_usec_ret_dtl_rec.fee_type = FND_API.G_MISS_CHAR) AND p_usec_ret_dtl_rec.definition_level='UNIT_SECTION_FEE_TYPE' THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','FEE_TYPE','IGS_FI_LOCKBOX',FALSE);
	p_usec_ret_dtl_rec.status := 'E';
      END IF;

      IF p_usec_ret_dtl_rec.offset_value IS NULL OR p_usec_ret_dtl_rec.offset_value = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','OFFSET_VALUE','LEGACY_TOKENS',FALSE);
	p_usec_ret_dtl_rec.status := 'E';
      END IF;


      --Offset date is mandatory when override date flag is set to 'Y'
      IF (p_usec_ret_dtl_rec.offset_date IS NULL OR p_usec_ret_dtl_rec.offset_date = FND_API.G_MISS_DATE) AND
          p_usec_ret_dtl_rec.override_date_flag ='Y'  THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_OFFSET_DATE_MANDATORY' );
	    fnd_msg_pub.add;
	    p_usec_ret_dtl_rec.status := 'E';
      END IF;


      IF p_usec_ret_dtl_rec.override_date_flag IS NULL OR p_usec_ret_dtl_rec.override_date_flag = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','OVERRIDE_DATE_FLAG','LEGACY_TOKENS',FALSE);
	p_usec_ret_dtl_rec.status := 'E';
      END IF;

      -- valid values of definition_level is 'UNIT_SECTION_FEE_TYPE' , 'UNIT_SECTION'
      IF  p_usec_ret_dtl_rec.definition_level NOT IN  ('UNIT_SECTION_FEE_TYPE' , 'UNIT_SECTION') THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','DEFINITION_LEVEL','LEGACY_TOKENS',FALSE);
            p_usec_ret_dtl_rec.status :='E';
      END IF;

      --Fee type should not be there for definition_level = UNIT_SECTION
      IF  p_usec_ret_dtl_rec.definition_level = 'UNIT_SECTION' AND  p_usec_ret_dtl_rec.fee_type IS NOT NULL THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','FEE_TYPE','IGS_FI_LOCKBOX',FALSE);
            p_usec_ret_dtl_rec.status :='E';
      END IF;

    END validate_parameters;

    PROCEDURE validate_derivation(p_usec_ret_dtl_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ret_dtl_rec_type) AS
      l_c_cal_type    VARCHAR2(10);
      l_n_seq_num     NUMBER;
      l_d_start       igs_ca_inst_all.start_dt%TYPE;
      l_d_end         igs_ca_inst_all.end_dt%TYPE;
      l_c_ret_status  VARCHAR2(30);

      CURSOR c_ret_usec IS
      SELECT non_std_usec_rtn_id,formula_method,round_method,incl_wkend_duration_flag
      FROM igs_ps_nsus_rtn
      WHERE uoo_id = l_n_uoo_id
      AND   definition_code='UNIT_SECTION';

      CURSOR c_ret_usec_fee IS
      SELECT non_std_usec_rtn_id,formula_method,round_method,incl_wkend_duration_flag
      FROM igs_ps_nsus_rtn
      WHERE uoo_id = l_n_uoo_id
      AND   fee_type = p_usec_ret_dtl_rec.fee_type;

      l_c_formula_method VARCHAR2(1);
      l_c_round_method   VARCHAR2(1);
      l_c_incl_wkend_duration_flag VARCHAR2(1);


    BEGIN

       -- Deriving the Calendar Type and Calendar Sequence Number
       igs_ge_gen_003.get_calendar_instance(p_usec_ret_dtl_rec.teach_cal_alternate_code,'''TEACHING''',  l_c_cal_type, l_n_seq_num, l_d_start, l_d_end, l_c_ret_status);
       IF l_c_ret_status <> 'SINGLE' THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS', FALSE);
	   p_usec_ret_dtl_rec.status := 'E';
       END IF;

       -- Deriving the Unit Offering Option Identifier
       l_c_ret_status := NULL;
       igs_ps_validate_lgcy_pkg.get_uoo_id(p_usec_ret_dtl_rec.unit_cd, p_usec_ret_dtl_rec.version_number, l_c_cal_type, l_n_seq_num, p_usec_ret_dtl_rec.location_cd, p_usec_ret_dtl_rec.unit_class, l_n_uoo_id, l_c_ret_status);
       IF l_c_ret_status IS NOT NULL THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','UNIT_SECTION','LEGACY_TOKENS', FALSE);
	  p_usec_ret_dtl_rec.status := 'E';
       END IF;

       --Derive the Master retention id
       IF p_usec_ret_dtl_rec.definition_level='UNIT_SECTION' THEN
	 OPEN c_ret_usec;
	 FETCH c_ret_usec INTO l_n_non_std_usec_rtn_id,l_c_formula_method,l_c_round_method,l_c_incl_wkend_duration_flag;
         CLOSE c_ret_usec;
       ELSE
	 OPEN c_ret_usec_fee;
	 FETCH c_ret_usec_fee INTO l_n_non_std_usec_rtn_id,l_c_formula_method,l_c_round_method,l_c_incl_wkend_duration_flag;
         CLOSE c_ret_usec_fee;
       END IF;

       IF l_n_non_std_usec_rtn_id IS NULL THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','RETENTION','LEGACY_TOKENS', FALSE);
	  p_usec_ret_dtl_rec.status := 'E';
       ELSE
         --Derive the offset date
         IF p_usec_ret_dtl_rec.status = 'S' THEN
	    IF p_usec_ret_dtl_rec.override_date_flag ='Y' THEN
              l_d_offset_date := p_usec_ret_dtl_rec.offset_date;
	    ELSE
	      l_d_offset_date := igs_ps_gen_004.f_retention_offset_date(
		  	      p_n_uoo_id              => l_n_uoo_id,
                              p_c_formula_method      => l_c_formula_method,
			      p_c_round_method        => l_c_round_method,
			      p_c_incl_wkend_duration => l_c_incl_wkend_duration_flag,
		              p_n_offset_value        => p_usec_ret_dtl_rec.offset_value
			    );
            END IF;
         END IF;
       END IF;

    END validate_derivation;

    PROCEDURE validate_db_cons(p_usec_ret_dtl_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ret_dtl_rec_type,p_insert_update IN VARCHAR2) AS

    BEGIN

      IF p_insert_update = 'I'  THEN
	-- Unique Key Validation
	IF igs_ps_nsus_rtn_dtl_pkg.get_uk_for_validation ( x_non_std_usec_rtn_id   => l_n_non_std_usec_rtn_id,
						           x_offset_value => p_usec_ret_dtl_rec.offset_value ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'RETENTION', 'LEGACY_TOKENS', FALSE);
	  p_usec_ret_dtl_rec.status := 'W';
	  RETURN;
	END IF;

      END IF;


      --Check constraint
      BEGIN
         igs_ps_nsus_rtn_dtl_pkg.check_constraints('OFFSET_VALUE', p_usec_ret_dtl_rec.offset_value);
      EXCEPTION
         WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','OFFSET_VALUE','LEGACY_TOKENS',TRUE);
            p_usec_ret_dtl_rec.status :='E';
      END;

      BEGIN
         igs_ps_nsus_rtn_dtl_pkg.check_constraints('RETENTION_PERCENT', p_usec_ret_dtl_rec.retention_percent);
      EXCEPTION
         WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','RETENTION_PERCENT','LEGACY_TOKENS',TRUE);
            p_usec_ret_dtl_rec.status :='E';
      END;

      BEGIN
         igs_ps_nsus_rtn_dtl_pkg.check_constraints('RETENTION_AMOUNT', p_usec_ret_dtl_rec.retention_amount);
      EXCEPTION
         WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','RETENTION_AMOUNT','LEGACY_TOKENS',TRUE);
            p_usec_ret_dtl_rec.status :='E';
      END;

      --Format mask check
      IF p_usec_ret_dtl_rec.retention_percent IS NOT NULL THEN
	IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_usec_ret_dtl_rec.retention_percent,3,2) THEN
	      igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','RETENTION_PERCENT','LEGACY_TOKENS',FALSE);
	      p_usec_ret_dtl_rec.status :='E';
	END IF;
      END IF;

      --Format mask check
      IF p_usec_ret_dtl_rec.retention_amount IS NOT NULL THEN
	IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_usec_ret_dtl_rec.retention_amount,6,2) THEN
	      igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','RETENTION_AMOUNT','LEGACY_TOKENS',FALSE);
	      p_usec_ret_dtl_rec.status :='E';
	END IF;
      END IF;

      IF p_usec_ret_dtl_rec.override_date_flag NOT IN ('Y','N') THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','OVERRIDE_DATE_FLAG','LEGACY_TOKENS',FALSE);
            p_usec_ret_dtl_rec.status :='E';
      END IF;

      -- Foreign Key Checking
      --Check for the existence of the unit section
      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation (l_n_uoo_id ) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
         p_usec_ret_dtl_rec.status := 'E';
      END IF;



    END validate_db_cons;

    -- Check for Update/Insert
    FUNCTION check_insert_update ( p_usec_ret_dtl_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ret_dtl_rec_type) RETURN VARCHAR2 IS

      CURSOR c_ret_det_usec IS
      SELECT 'X'
      FROM igs_ps_nsus_rtn_dtl
      WHERE non_std_usec_rtn_id = l_n_non_std_usec_rtn_id
      AND   offset_value = p_usec_ret_dtl_rec.offset_value;

      l_c_var   VARCHAR2(1);

    BEGIN

       OPEN c_ret_det_usec;
       FETCH c_ret_det_usec INTO l_c_var;
       IF c_ret_det_usec%FOUND THEN
	 CLOSE c_ret_det_usec;
	 RETURN 'U';
       ELSE
	 CLOSE c_ret_det_usec;
	 RETURN 'I';
       END IF;

    END check_insert_update;

    PROCEDURE Assign_defaults(p_usec_ret_dtl_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ret_dtl_rec_type,p_insert_update IN VARCHAR2) AS
      CURSOR cur_ret_det IS
      SELECT *
      FROM  igs_ps_nsus_rtn_dtl
      WHERE non_std_usec_rtn_id = l_n_non_std_usec_rtn_id
      AND   offset_value = p_usec_ret_dtl_rec.offset_value;

      l_cur_ret_det cur_ret_det%ROWTYPE;

    BEGIN
       IF p_insert_update = 'U' THEN

         OPEN cur_ret_det;
         FETCH cur_ret_det into l_cur_ret_det;
         CLOSE cur_ret_det;

 	 IF p_usec_ret_dtl_rec.retention_percent IS NULL THEN
	   p_usec_ret_dtl_rec.retention_percent  := l_cur_ret_det.retention_percent;
         ELSIF p_usec_ret_dtl_rec.retention_percent = FND_API.G_MISS_NUM THEN
	   p_usec_ret_dtl_rec.retention_percent  := NULL;
	 END IF;

 	 IF p_usec_ret_dtl_rec.retention_amount IS NULL THEN
	   p_usec_ret_dtl_rec.retention_amount  := l_cur_ret_det.retention_amount;
         ELSIF p_usec_ret_dtl_rec.retention_amount = FND_API.G_MISS_NUM THEN
	   p_usec_ret_dtl_rec.retention_amount  := NULL;
	 END IF;

       END IF;

    END Assign_defaults;

    PROCEDURE Business_validation(p_usec_ret_dtl_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ret_dtl_rec_type,p_insert_update IN VARCHAR2) AS
      CURSOR cur_check_ns_usec(cp_n_uoo_id  IN NUMBER) IS
      SELECT 'X'
      FROM igs_ps_unit_ofr_opt_all
      WHERE uoo_id = cp_n_uoo_id
      AND non_std_usec_ind = 'Y';
      l_c_var    VARCHAR2(1);

      l_message_name VARCHAR2(30);

      CURSOR cur_check_formula (cp_non_std_usec_rtn_id IN NUMBER) IS
      SELECT 'X'
      FROM   igs_ps_nsus_rtn nr
      WHERE  nr.non_std_usec_rtn_id = cp_non_std_usec_rtn_id
      AND    nr.formula_method IN ('P','M')
      AND    p_usec_ret_dtl_rec.offset_value > 100;


    BEGIN
      --Check if the unit is INACTIVE, then do not allow to import
      IF igs_ps_val_unit.crsp_val_iud_uv_dtl(p_usec_ret_dtl_rec.unit_cd, p_usec_ret_dtl_rec.version_number,l_message_name)=FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
	    fnd_msg_pub.add;
	    p_usec_ret_dtl_rec.status := 'E';
      END IF;

      --Check if the Unit Section is not Not standard then insert/update is not allowed
      OPEN cur_check_ns_usec(l_n_uoo_id);
      FETCH cur_check_ns_usec INTO l_c_var;
      IF cur_check_ns_usec%NOTFOUND THEN
        fnd_message.set_name ( 'IGS', 'IGS_PS_NON_STD_USEC_NOT_IMP' );
	fnd_message.set_token('RECORD',igs_ps_validate_lgcy_pkg.get_lkup_meaning('RETENTION','LEGACY_TOKENS'));
        fnd_msg_pub.add;
	/*igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_NON_STD_USEC_NOT_IMP','RETENTION','LEGACY_TOKENS',FALSE);*/
	p_usec_ret_dtl_rec.status := 'E';
      END IF;
      CLOSE cur_check_ns_usec;


      --If formula method is 'P'/'M' and  offset is greater than 100 then it is an error condition
      OPEN cur_check_formula(l_n_non_std_usec_rtn_id);
      FETCH cur_check_formula INTO l_c_var;
      IF cur_check_formula%FOUND THEN
	fnd_message.set_name ( 'IGS', 'IGS_PS_RTN_OFFSET_INVALID' );
	fnd_msg_pub.add;
	p_usec_ret_dtl_rec.status := 'E';
      END IF;
      CLOSE cur_check_formula;

      --Either retention percent or retention amount can be provided not both
      IF p_usec_ret_dtl_rec.retention_percent IS NOT NULL AND p_usec_ret_dtl_rec.retention_amount IS NOT NULL THEN
	fnd_message.set_name ( 'IGS', 'IGS_PS_PER_AMT_BOTH_NOT_ALLOW' );
	fnd_msg_pub.add;
	p_usec_ret_dtl_rec.status := 'E';
      END IF;

      --Either retention amount or percent are mandatory
      IF p_usec_ret_dtl_rec.retention_percent IS NULL  AND p_usec_ret_dtl_rec.retention_amount IS NULL   THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_PER_OR_AMT_MANDATORY' );
	    fnd_msg_pub.add;
	    p_usec_ret_dtl_rec.status := 'E';
      END IF;

    END Business_validation;

  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret_dtl.start_logging_for',
                    'Unit Section Retention Details');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_usec_ret_dtl_tbl.LAST LOOP
       IF p_usec_ret_dtl_tbl.EXISTS(I) THEN
	  -- Initialize the variable use to store the derived values.
	  l_n_uoo_id := NULL;
          l_n_non_std_usec_rtn_id :=NULL;
          l_d_offset_date :=NULL;

	  p_usec_ret_dtl_tbl(I).status := 'S';
	  p_usec_ret_dtl_tbl(I).msg_from := fnd_msg_pub.count_msg;
	  trim_values(p_usec_ret_dtl_tbl(I));
	  validate_parameters(p_usec_ret_dtl_tbl(I));

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret_dtl.status_after_validate_parameters',
	    'Unit code:'||p_usec_ret_dtl_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_dtl_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_ret_dtl_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_dtl_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_ret_dtl_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_dtl_tbl(I).fee_type||'  '||'definition_level:'
	    ||p_usec_ret_dtl_tbl(I).definition_level||'  '||'Offset Value:'||p_usec_ret_dtl_tbl(I).offset_value
	    ||'  '||'Status:'||p_usec_ret_dtl_tbl(I).status);
          END IF;

	  IF p_usec_ret_dtl_tbl(I).status = 'S' THEN
	     validate_derivation(p_usec_ret_dtl_tbl(I));

             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret_dtl.status_after_validate_derivation',
		'Unit code:'||p_usec_ret_dtl_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_dtl_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		||p_usec_ret_dtl_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_dtl_tbl(I).location_cd||'  '||'Unit Class:'||
		p_usec_ret_dtl_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_dtl_tbl(I).fee_type||'  '||'definition_level:'
		||p_usec_ret_dtl_tbl(I).definition_level||'  '||'Offset Value:'||p_usec_ret_dtl_tbl(I).offset_value
		||'  '||'Status:'||p_usec_ret_dtl_tbl(I).status);
             END IF;

	  END IF;

	  --Find out whether it is insert/update of record
	  l_insert_update:='I';
	  IF p_usec_ret_dtl_tbl(I).status = 'S' AND p_calling_context IN ('G','S') THEN
	    l_insert_update:= check_insert_update(p_usec_ret_dtl_tbl(I));

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret_dtl.status_after_check_insert_update',
	      'Unit code:'||p_usec_ret_dtl_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_dtl_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_ret_dtl_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_dtl_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_ret_dtl_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_dtl_tbl(I).fee_type||'  '||'definition_level:'
	      ||p_usec_ret_dtl_tbl(I).definition_level||'  '||'Offset Value:'||p_usec_ret_dtl_tbl(I).offset_value
	      ||'  '||'Status:'||p_usec_ret_dtl_tbl(I).status);
            END IF;

	  END IF;

	  IF p_usec_ret_dtl_tbl(I).status = 'S' AND p_calling_context = 'S' THEN
	    IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	      fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	      fnd_msg_pub.add;
	      p_usec_ret_dtl_tbl(I).status := 'A';
	    END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret_dtl.status_after_check_import_allowed',
	      'Unit code:'||p_usec_ret_dtl_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_dtl_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_ret_dtl_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_dtl_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_ret_dtl_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_dtl_tbl(I).fee_type||'  '||'definition_level:'
	      ||p_usec_ret_dtl_tbl(I).definition_level||'  '||'Offset Value:'||p_usec_ret_dtl_tbl(I).offset_value
	      ||'  '||'Status:'||p_usec_ret_dtl_tbl(I).status);
            END IF;

	  END IF;

	  --Defaulting depending upon insert or update
	  IF p_usec_ret_dtl_tbl(I).status = 'S' THEN
	    assign_defaults(p_usec_ret_dtl_tbl(I),l_insert_update);

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret_dtl.status_after_assign_defaults',
	      'Unit code:'||p_usec_ret_dtl_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_dtl_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_ret_dtl_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_dtl_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_ret_dtl_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_dtl_tbl(I).fee_type||'  '||'definition_level:'
	      ||p_usec_ret_dtl_tbl(I).definition_level||'  '||'Offset Value:'||p_usec_ret_dtl_tbl(I).offset_value
	      ||'  '||'Status:'||p_usec_ret_dtl_tbl(I).status);
            END IF;

	  END IF;

	  IF p_usec_ret_dtl_tbl(I).status = 'S' THEN
	     validate_db_cons ( p_usec_ret_dtl_tbl(I),l_insert_update);

             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	       fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret_dtl.status_after_validate_db_cons',
	       'Unit code:'||p_usec_ret_dtl_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_dtl_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	       ||p_usec_ret_dtl_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_dtl_tbl(I).location_cd||'  '||'Unit Class:'||
	       p_usec_ret_dtl_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_dtl_tbl(I).fee_type||'  '||'definition_level:'
	       ||p_usec_ret_dtl_tbl(I).definition_level||'  '||'Offset Value:'||p_usec_ret_dtl_tbl(I).offset_value
	       ||'  '||'Status:'||p_usec_ret_dtl_tbl(I).status);
             END IF;

	  END IF;


	  --Business validations
	  IF p_usec_ret_dtl_tbl(I).status = 'S' THEN
	    Business_validation(p_usec_ret_dtl_tbl(I),l_insert_update);

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret_dtl.status_after_Business_validation',
	      'Unit code:'||p_usec_ret_dtl_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_dtl_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_ret_dtl_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_dtl_tbl(I).location_cd||'  '||'Unit Class:'||
	      p_usec_ret_dtl_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_dtl_tbl(I).fee_type||'  '||'definition_level:'
	      ||p_usec_ret_dtl_tbl(I).definition_level||'  '||'Offset Value:'||p_usec_ret_dtl_tbl(I).offset_value
	      ||'  '||'Status:'||p_usec_ret_dtl_tbl(I).status);
            END IF;

	  END IF;

	  IF p_usec_ret_dtl_tbl(I).status = 'S' THEN

	    IF l_insert_update = 'I' THEN
	      INSERT INTO IGS_PS_NSUS_RTN_DTL(
		non_std_usec_rtn_dtl_id,
		non_std_usec_rtn_id,
		offset_value,
		retention_percent,
		retention_amount,
		offset_date,
		override_date_flag,
                created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login )
	      VALUES (
                igs_ps_nsus_rtn_dtl_s.NEXTVAL,
		l_n_non_std_usec_rtn_id,
		p_usec_ret_dtl_tbl(I).offset_value,
		p_usec_ret_dtl_tbl(I).retention_percent,
		p_usec_ret_dtl_tbl(I).retention_amount,
		l_d_offset_date,
		p_usec_ret_dtl_tbl(I).override_date_flag,
		g_n_user_id,
		SYSDATE,
		g_n_user_id,
		SYSDATE,
		g_n_login_id);

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret_dtl.Record_Inserted',
		  'Unit code:'||p_usec_ret_dtl_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_dtl_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		  ||p_usec_ret_dtl_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_dtl_tbl(I).location_cd||'  '||'Unit Class:'||
		  p_usec_ret_dtl_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_dtl_tbl(I).fee_type||'  '||'definition_level:'
		  ||p_usec_ret_dtl_tbl(I).definition_level||'  '||'Offset Value:'||p_usec_ret_dtl_tbl(I).offset_value);
		END IF;

	    ELSE
	      UPDATE IGS_PS_NSUS_RTN_DTL SET
		retention_percent      = p_usec_ret_dtl_tbl(I).retention_percent,
		retention_amount       = p_usec_ret_dtl_tbl(I).retention_amount,
		offset_date            = l_d_offset_date,
		override_date_flag     = p_usec_ret_dtl_tbl(I).override_date_flag,
		last_updated_by        = g_n_user_id ,
		last_update_date       = sysdate ,
		last_update_login      = g_n_login_id
	      WHERE non_std_usec_rtn_id = l_n_non_std_usec_rtn_id AND offset_value = p_usec_ret_dtl_tbl(I).offset_value ;

              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret_dtl.Record_updated',
		'Unit code:'||p_usec_ret_dtl_tbl(I).unit_cd||'  '||'Version number:'||p_usec_ret_dtl_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
		||p_usec_ret_dtl_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_ret_dtl_tbl(I).location_cd||'  '||'Unit Class:'||
		p_usec_ret_dtl_tbl(I).unit_class||'  '||'Fee type:'||p_usec_ret_dtl_tbl(I).fee_type||'  '||'definition_level:'
		||p_usec_ret_dtl_tbl(I).definition_level||'  '||'Offset Value:'||p_usec_ret_dtl_tbl(I).offset_value);
	      END IF;

	    END IF;


	  END IF;


	  IF p_usec_ret_dtl_tbl(I).status = 'S' THEN
	     p_usec_ret_dtl_tbl(I).msg_from := NULL;
	     p_usec_ret_dtl_tbl(I).msg_to := NULL;
	  ELSIF  p_usec_ret_dtl_tbl(I).status = 'A' THEN
	     p_usec_ret_dtl_tbl(I).msg_from  := p_usec_ret_dtl_tbl(I).msg_from + 1;
	     p_usec_ret_dtl_tbl(I).msg_to := fnd_msg_pub.count_msg;
	  ELSE
	     p_c_rec_status := p_usec_ret_dtl_tbl(I).status;
	     p_usec_ret_dtl_tbl(I).msg_from := p_usec_ret_dtl_tbl(I).msg_from+1;
	     p_usec_ret_dtl_tbl(I).msg_to := fnd_msg_pub.count_msg;
	     IF p_usec_ret_dtl_tbl(I).status = 'E' THEN
		RETURN;
	     END IF;
	  END IF;

       END IF;
    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_create_generic_pkg.create_usec_ret_dtl.after_import_status',p_c_rec_status);
    END IF;

  END create_usec_ret_dtl;


END igs_ps_create_generic_pkg;

/
