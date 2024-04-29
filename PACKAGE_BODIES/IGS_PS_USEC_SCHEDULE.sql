--------------------------------------------------------
--  DDL for Package Body IGS_PS_USEC_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_USEC_SCHEDULE" AS
/* $Header: IGSPS77B.pls 120.18 2006/05/22 10:06:18 sommukhe ship $ */
/* Change History
   Who           When       What
    sarakshi    05-May-2005     Bug#4349740, modified upd_usec_occurs_schd_status, changed the main if condition.
    smvk        29-Jun-2003     Bug # 3060089. Modified the procedure prgp_get_schd_records.
  --smvk        25-jun-2003     Enh bug#2918094. Added column cancel_flag in the call to igs_ps_usec_occurs_pkg.
                                Create a procedure abort_scheduling to provide the feature to the user to abort the
                                scheduling in progress unit section occurrence. modified the procedure purge_schd_record
                                to delete the particular unit section occurrence in interface table with is child and parent
                                information.
   jbegum       07-Apr-2003         Enh Bug #2833850.
                                As part of PSP Scheduling Interface Enhancements TD added a local procedure purge_schd_record.
                                Added a new public function get_enrollment_max
                                Added the columns preferred_region_code,no_set_day_ind to the call of igs_ps_usec_occurs_pkg.update_row
                                    Added the columns preferred_region_code to the calls of insert_row and update_row of
                                igs_ps_sch_int_pkg.
   (reverse chronological order - newest change first)
*/


-- Forward declaration of local procedures

PROCEDURE purge_schd_record( p_c_cal_type IN VARCHAR2,
                             p_n_seq_num  IN NUMBER);

PROCEDURE log_teach_cal  (p_c_cal_type IN VARCHAR2,
                          p_n_ci_sequence_number IN NUMBER);

PROCEDURE log_usec_details  (p_c_unit_cd IN VARCHAR2,
                             p_n_version_number IN NUMBER,
                             p_c_location_description IN VARCHAR2,
                             p_c_unit_class IN VARCHAR2,
                             p_n_enrollment_maximum IN NUMBER);

PROCEDURE log_usec_occurs   (p_c_trans_type IN VARCHAR2,
                             p_n_lead_instructor_id IN NUMBER,
                             p_usec_occur_rec IN igs_ps_usec_occurs_all%ROWTYPE,
                             p_c_call IN VARCHAR2);

PROCEDURE log_messages ( p_msg_name IN VARCHAR2,
                         p_msg_val  IN VARCHAR2,
                         p_val      IN NUMBER
                       ) ;
FUNCTION  get_alternate_code (p_c_cal_type IN VARCHAR2,
                              p_n_seq_num IN NUMBER)RETURN VARCHAR2;
g_n_user_id igs_ps_unit_ver_all.created_by%TYPE := NVL(fnd_global.user_id,-1);          -- Stores the User Id
g_n_login_id igs_ps_unit_ver_all.last_update_login%TYPE := NVL(fnd_global.login_id,-1); -- Stores the Login Id


PROCEDURE prgp_init_prs_sched(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY NUMBER,
  p_teach_prd IN VARCHAR2,
  p_uoo_id IN NUMBER,
  p_usec_id IN NUMBER,
  p_sch_type IN VARCHAR2 ,
  p_org_id IN NUMBER)
  AS
  /**********************************************************
  Created By : kmunuswa

  Date Created By : 29-AUG-2000

  Purpose : For scheduling the Unit Section occurrences

  Know limitations, enhancements or remarks

  Change History

  Who           When            What
  sommukhe      24-Jan-2006     Bug #4926548,replaced igs_ps_unit_ofr_opt_v with igs_ps_unit_ofr_opt_all for cursor c_end_dt
  sarakshi      12-Jan-2005     Bug#4926548, modified cursor uoo_cur to remove the two outer joins with two tables and included them in the place of open cursor .Also
                                modified the cursor usec_occur to use its base table rather than the view IGS_PS_USEC_OCCURS_V
  sarakshi      06-Dec-2005     Bug#4863051,modified cursor pat_cur such that it excludes the inactive units for processing.
  sarakshi      19-Sep-2005     Bug#4588504, modified cursor uoo_cur such it picks the subtitle correctly.
  sarakshi      13-Sep-2005     Bug#4584578, removed the = condition when comparting sysdate with the teaching calendaer end date
 ***************************************************************/

  -- All active and inactive unit sections
  -- Added location_description in the following cursor as part of enh bug#2833850
       CURSOR uoo_cur( l_cal_type            igs_ca_inst.cal_type%TYPE,
                       l_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
		       cp_unit_cd VARCHAR2,
		       cp_version_number IN NUMBER,
		       cp_location_cd IN VARCHAR2,
		       cp_unit_class IN VARCHAR2) IS
        SELECT  uoo.uoo_id,
		uoo.unit_cd,
		uoo.version_number,
		uv.title title,
		uoo.location_cd,
		loc.description location_description,
		uoo.unit_class,
		uoo.unit_section_start_date,
		uoo.unit_section_end_date,
		uoo.enrollment_actual,
		uoo.unit_section_status,
		ci.start_dt cal_start_dt,
		ci.end_dt cal_end_dt,
		uoo.call_number,
		ci.alternate_code teaching_cal_alternate_code,
		NULL subtitle,
		uv.subtitle_id,
		NVL(uoo.owner_org_unit_cd, uv.owner_org_unit_cd) owner_org_unit_cd
		FROM   igs_ps_unit_ofr_opt_all uoo,igs_ps_unit_ver_all uv,igs_ca_inst_all ci, igs_ad_location_all loc
		WHERE  uoo.cal_type = l_cal_type
		AND uoo.ci_sequence_number = l_ci_sequence_number
		AND uoo.unit_cd=cp_unit_cd
		AND uoo.version_number=cp_version_number
		AND (uoo.location_cd=cp_location_cd OR cp_location_cd IS NULL)
		AND (uoo.unit_class=cp_unit_class OR cp_unit_class IS NULL)
		AND uoo.unit_cd = uv.unit_cd
		AND uoo.version_number = uv.version_number
		AND uoo.unit_section_status <> 'NOT_OFFERED'
		AND uoo.cal_type = ci.cal_type
		AND uoo.ci_sequence_number = ci.sequence_number
		AND uoo.location_cd = loc.location_cd;



    -- Get the Usec Occurrence data for a given uoo_id
    -- Modified the following cursor for Enh bug#2833850
    -- Added the no_set_day_ind check in the where clause and also replaced the columns in the select statement with *.
    -- Modified the following cursor for Enh Bug # 2918094. Removed schedule status 'PROCESSING' in the where clause.
       CURSOR usec_occur(l_uoo_id  igs_ps_unit_ofr_opt.uoo_id%TYPE,
                         cp_unit_section_occurrence_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
         SELECT  *
         FROM    igs_ps_usec_occurs_all
         WHERE   uoo_id = l_uoo_id
         AND     no_set_day_ind = 'N'
         AND     (unit_section_occurrence_id = cp_unit_section_occurrence_id OR cp_unit_section_occurrence_id IS NULL)
         AND     (
                   schedule_status IS NULL
                   OR
                   (schedule_status NOT IN('SCHEDULED'))
                 );


    -- Get the calendar end date  for the particular unit section for Bug # 2383553
       CURSOR c_end_dt (cp_uoo_id IGS_PS_UNIT_OFR_OPT_V.UOO_ID%TYPE) IS
          SELECT ci.end_dt cal_end_dt
          FROM   igs_ps_unit_ofr_opt_all uoo, igs_ca_inst_all ci
          WHERE  UOO_ID =cp_uoo_id
	  AND    uoo.cal_type = ci.cal_type
          AND    uoo.ci_sequence_number = ci.sequence_number;

    -- Check whether it is required to pass the unit section information to interface table or not.
    -- for aborting occurrences no need to pass the unit section occurrence process.
          CURSOR c_is_req (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                        cp_unit_section_occurrence_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE,
			cp_schedule_status igs_ps_usec_occurs_all.schedule_status%TYPE) IS
          SELECT 'x'
          FROM    igs_ps_usec_occurs_all
	  WHERE   NVL(schedule_status,'NULL') = DECODE(cp_unit_section_occurrence_id,NULL,cp_schedule_status,NVL(schedule_status,'NULL'))
          AND     uoo_id = cp_n_uoo_id
	  AND     no_set_day_ind = 'N'
	  AND     (unit_section_occurrence_id = cp_unit_section_occurrence_id OR cp_unit_section_occurrence_id IS NULL)
          AND     ROWNUM <2 ;

---
       CURSOR c_usec_param(cp_uoo_id IN NUMBER) IS
       SELECT unit_cd,version_number,cal_type,ci_sequence_number,unit_class,location_cd
       FROM  igs_ps_unit_ofr_opt_all
       WHERE uoo_id=cp_uoo_id;
       l_usec_param c_usec_param%ROWTYPE;

       CURSOR pat_cur(cp_cal_type  IN VARCHAR2, cp_ci_sequence_number IN NUMBER,
		     cp_unit_cd IN VARCHAR2, cp_version_number IN NUMBER) IS
       SELECT  us.*,b.alternate_code ,b.start_dt,b.end_dt,c.unit_status,c.enrollment_expected,c.enrollment_maximum,c.override_enrollment_max
       FROM    igs_ps_unit_ofr_pat us, igs_ca_inst_all b,igs_ps_unit_ver c, igs_ps_unit_stat d
       WHERE   us.cal_type=cp_cal_type
       AND     us.ci_sequence_number=cp_ci_sequence_number
       AND     (us.unit_cd=cp_unit_cd OR cp_unit_cd IS NULL)
       AND     (us.version_number=cp_version_number OR cp_version_number IS NULL)
       AND     us.cal_type=b.cal_type
       AND     us.ci_sequence_number=b.sequence_number
       AND     us.unit_cd=c.unit_cd
       AND     us.version_number=c.version_number
       AND     c.unit_status=d.unit_status
       AND     d.s_unit_status <> 'INACTIVE';
       l_uoo_cur uoo_cur%ROWTYPE;


       CURSOR c_occur_exists (cp_uoo_id IN NUMBER) IS
       SELECT 'X'
       FROM    igs_ps_usec_occurs_all
       WHERE   uoo_id=cp_uoo_id;
       l_c_var VARCHAR2(1);

       CURSOR c_section_int_exists(cp_int_pat_id IN NUMBER) IS
       SELECT  'X'
       FROM igs_ps_sch_usec_int_all
       WHERE int_pat_id = cp_int_pat_id;

       CURSOR c_pattern_int_exists(cp_transaction_id IN NUMBER) IS
       SELECT 'X'
       FROM   igs_ps_sch_pat_int
       WHERE  transaction_id = cp_transaction_id;

       CURSOR c_pattern_prod(cp_transaction_id IN NUMBER) IS
       SELECT *
       FROM   igs_ps_sch_pat_int
       WHERE  transaction_id=cp_transaction_id;

       CURSOR c_section(cp_int_pat_id IN NUMBER) IS
       SELECT *
       FROM   igs_ps_sch_usec_int_all
       WHERE  int_pat_id=cp_int_pat_id;

       CURSOR c_occurrence(cp_int_usec_id IN NUMBER) IS
       SELECT *
       FROM   igs_ps_sch_int_all
       WHERE  int_usec_id=cp_int_usec_id;

       l_int_pat_id              NUMBER;
       l_valid_occur             BOOLEAN;
       l_unit_status             igs_ps_unit_ver_all.unit_status%TYPE;
---

       l_trans_id                igs_ps_sch_hdr_int.transaction_id%TYPE;
       l_request_id              igs_ps_sch_hdr_int.request_id%TYPE;
       l_program_id              igs_ps_sch_hdr_int.program_id%TYPE;
       l_program_application_id  igs_ps_sch_hdr_int.program_application_id%TYPE;
       l_derd_sch_type           VARCHAR2(13); -- Changed as varchar2(13) from igs_ps_sch_int_all.transaction_type%TYPE w.r.t. Bug # 2383553
       l_int_sch_status          igs_ps_sch_int_all.transaction_type%TYPE;
       l_cal_type                igs_ca_inst.cal_type%TYPE;
       l_enrollment_maximum      igs_ps_usec_lim_wlst.enrollment_maximum%TYPE;
       l_enrollment_expected     igs_ps_usec_lim_wlst.enrollment_expected%TYPE;
       l_override_enrollment_max igs_ps_usec_lim_wlst.override_enrollment_max%TYPE;
       l_ci_sequence_number      igs_ca_inst.sequence_number%TYPE;
       l_start_date              igs_ca_inst.start_dt%TYPE;
       l_end_date                igs_ca_inst.end_dt%TYPE;
       l_trans_type              igs_ps_sch_int_all.transaction_type%TYPE;
       l_int_usec_id             igs_ps_sch_usec_int_all.int_usec_id%TYPE;
       l_max_enr_meet_grp        igs_ps_uso_clas_meet_v.enrollment_maximum%TYPE;
       l_lead_instructor_id      igs_ps_usec_tch_resp.instructor_id%TYPE;
       l_surname                 igs_pe_person.surname%TYPE ;
       l_given_names             igs_pe_person.given_names%TYPE ;
       l_middle_name             igs_pe_person.middle_name%TYPE;
       l_data_found              BOOLEAN := FALSE;  -- Added as a part of Bug # 2383553
       usec_occur_rec            usec_occur%ROWTYPE;
       rec_end_dt                c_end_dt%ROWTYPE;
       l_cal                     BOOLEAN := TRUE; -- Added as a part of Bug # 2833850
       l_usec                    BOOLEAN := TRUE; -- Added as a part of Bug # 2833850
       rec_is_req                c_is_req%ROWTYPE;


       PROCEDURE create_header IS
          -- create a header record for the process.
       BEGIN
	 INSERT INTO igs_ps_sch_hdr_int_all (
	    transaction_id                 ,
	    originator                     ,
	    request_date                   ,
	    org_id                         ,
   	    created_by                     ,
	    creation_date                  ,
	    last_updated_by                ,
	    last_update_date               ,
	    last_update_login)
	    VALUES (
	    IGS_PS_SCH_HDR_INT_S.NEXTVAL,
	    'INTERNAL',
	    SYSDATE,
	    p_org_id,
            g_n_user_id,
   	    SYSDATE,
            g_n_user_id,
            SYSDATE,
            g_n_login_id ) RETURNING transaction_id INTO l_trans_id;

       END create_header;

       -- Procedure to get the enrollment limits (Enrollment Expected, Enrollment Maximum and Override Maximum) for the unit section.
       -- Uses inheritance logic to get enrollment limits.
       -- (i.e gets enrollment limits from unit section[IGS_PS_USEC_LIM_WLST] level if defined (overriden) otherwise from unit level [IGS_PS_UNIT_VER_ALL].)
       PROCEDURE get_enrollment_lmts(p_n_uoo_id IN NUMBER) AS

           -- gets the enrollment limits defined at unit section level.
           CURSOR usec_lmts(cp_n_uoo_id IN NUMBER) IS
              SELECT usec.enrollment_expected,
                     NVL(usec.enrollment_maximum,999999),
                     NVL(usec.override_enrollment_max,999999)
               FROM igs_ps_usec_lim_wlst usec
               WHERE usec.uoo_id = cp_n_uoo_id;

           -- gets the enrollment limits defined at unit level.
           CURSOR unit_lmts(cp_n_uoo_id IN NUMBER) IS
              SELECT unit.enrollment_expected,
                     NVL(unit.enrollment_maximum, 999999),
                     NVL(unit.override_enrollment_max,999999)
              FROM   IGS_PS_UNIT_VER_ALL unit,
                     IGS_PS_UNIT_OFR_OPT_ALL usec
              WHERE  unit.unit_cd = usec.unit_cd
              AND    unit.version_number = usec.version_number
              AND    usec.uoo_id = cp_n_uoo_id;

        BEGIN
          l_enrollment_expected := NULL;
          l_enrollment_maximum := NULL;
          l_override_enrollment_max := NULL;
          OPEN usec_lmts(p_n_uoo_id);
          FETCH usec_lmts INTO l_enrollment_expected, l_enrollment_maximum, l_override_enrollment_max;
          IF usec_lmts%NOTFOUND THEN
             -- if limits are not overriden at unit section level then get it from unit level.
             OPEN unit_lmts (p_n_uoo_id);
             FETCH unit_lmts INTO l_enrollment_expected, l_enrollment_maximum, l_override_enrollment_max;
             CLOSE unit_lmts;
          END IF;
          CLOSE usec_lmts;

        END get_enrollment_lmts;

        -- function to get lead instructor information such as instructor identifier
        -- given name (first name), middle name and last name.
        -- returns false if it could not find the lead instructor information for the
        -- identifier existing in the unit section teaching responsibility.
        -- returns true, if the unit section does not have lead instructor or
        -- if it finds the lead instructor information successfully.

        FUNCTION get_instructor_info (p_n_uoo_id IN NUMBER) RETURN BOOLEAN AS
           -- Get the lead instructor identifier
           CURSOR c_lead_instructor (cp_n_uoo_id IN NUMBER) IS
             SELECT instructor_id
             FROM   igs_ps_usec_tch_resp
             WHERE  uoo_id = cp_n_uoo_id
             AND    lead_instructor_flag = 'Y' ;

           -- Get the given name (first name), middle name and last name for the given Instructor Identifier
           CURSOR c_get_names(cp_n_ins_id IN NUMBER) IS
             SELECT  first_name,
                     middle_name,
                     last_name
             FROM    igs_pe_person_base_v
             WHERE   person_id = cp_n_ins_id;
           l_ret_type BOOLEAN;
        BEGIN
          l_lead_instructor_id := NULL;
          l_given_names := NULL;
          l_middle_name := NULL;
          l_surname := NULL;
          l_ret_type := TRUE;
          OPEN c_lead_instructor(p_n_uoo_id);
          FETCH c_lead_instructor INTO l_lead_instructor_id;
          IF c_lead_instructor%FOUND THEN
             OPEN  c_get_names( l_lead_instructor_id );
             FETCH c_get_names INTO l_given_names,l_middle_name,l_surname;
             IF c_get_names%NOTFOUND THEN
               l_ret_type := FALSE;
             END IF;
             CLOSE c_get_names;
          END IF;
          CLOSE c_lead_instructor;
          return l_ret_type;
        END get_instructor_info;

---
	PROCEDURE transfer_patterns(p_pat_cur_rec IN pat_cur%ROWTYPE,
	                            p_unit_status OUT NOCOPY VARCHAR2,
	                            p_int_pat_id  OUT NOCOPY NUMBER) AS
	/**********************************************************
	  Created By : sarakshi

	  Date Created By : 21-May-2005

	  Purpose : Transfer Data to pattern interface table and its childs location and facilities

	  Know limitations, enhancements or remarks

	  Change History

	  Who           When            What
	***************************************************************/
	   l_u_enrollment_expected igs_ps_unit_ver_all.enrollment_expected%TYPE ;
	   l_u_enrollment_maximum  igs_ps_unit_ver_all.enrollment_maximum%TYPE ;
	   l_u_override_enrollment_max igs_ps_unit_ver_all.override_enrollment_max%TYPE ;


	   CURSOR c_section_exists(cp_cal_type IN igs_ps_unit_ofr_opt_all.cal_type%TYPE,
			           cp_ci_sequence_number IN igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE,
			           cp_unit_cd IN igs_ps_unit_ofr_opt_all.unit_cd%TYPE,
			           cp_version_number IN igs_ps_unit_ofr_opt_all.version_number%TYPE) IS
	   SELECT 'X'
	   FROM    igs_ps_unit_ofr_opt_all us
	   WHERE   us.cal_type=cp_cal_type
	   AND     us.ci_sequence_number=cp_ci_sequence_number
	   AND     us.unit_cd=cp_unit_cd
	   AND     us.version_number=cp_version_number;

	   CURSOR c_loc(cp_unit_cd IN VARCHAR2,
 		        cp_version_number IN NUMBER) IS
	   SELECT  *
	   FROM    igs_ps_unit_location_v
	   WHERE   unit_code=cp_unit_cd
	   AND     unit_version_number=cp_version_number;

	   CURSOR c_fac(cp_unit_cd IN VARCHAR2,
      		        cp_version_number IN NUMBER) IS
	   SELECT  *
	   FROM    igs_ps_unit_facility_v
	   WHERE   unit_code=cp_unit_cd
	   AND     unit_version_number=cp_version_number;

	BEGIN
	   -- Check if section record exist in production for the pattern
	   OPEN c_section_exists(l_cal_type,l_ci_sequence_number,p_pat_cur_rec.unit_cd,p_pat_cur_rec.version_number);
	   FETCH c_section_exists INTO l_c_var;
	   IF c_section_exists%FOUND THEN
	     l_u_enrollment_expected:= NULL;
	     l_u_enrollment_maximum:= NULL;
	     l_u_override_enrollment_max:= NULL;
	     p_unit_status:= NULL;
	   ELSE
	     l_u_enrollment_expected:= p_pat_cur_rec.enrollment_expected;
	     l_u_enrollment_maximum:= p_pat_cur_rec.enrollment_maximum;
	     l_u_override_enrollment_max:= p_pat_cur_rec.override_enrollment_max;
	     p_unit_status:= p_pat_cur_rec.unit_status;
	   END IF;
	   CLOSE c_section_exists;

	   --Insert into pattern interface table
	   INSERT INTO IGS_PS_SCH_PAT_INT
	   (int_pat_id ,
	   transaction_id                 ,
	   calendar_type                  ,
	   sequence_number                ,
	   teaching_cal_alternate_code    ,
	   start_date                     ,
	   end_date                       ,
	   unit_cd                        ,
	   version_number                 ,
	   enrollment_expected            ,
	   enrollment_maximum             ,
	   override_enrollment_maximum    ,
	   unit_status                    ,
	   abort_flag                     ,
	   import_done_flag               ,
	   created_by                     ,
	   creation_date                  ,
	   last_updated_by                ,
	   last_update_date               ,
	   last_update_login)
	   VALUES(
	   IGS_PS_SCH_PAT_INT_S.NEXTVAL,
	   l_trans_id,
	   l_cal_type,
	   l_ci_sequence_number,
	   p_pat_cur_rec.alternate_code,
	   p_pat_cur_rec.start_dt,
	   p_pat_cur_rec.end_dt,
	   p_pat_cur_rec.unit_cd,
	   p_pat_cur_rec.version_number,
	   l_u_enrollment_expected,
	   l_u_enrollment_maximum,
	   l_u_override_enrollment_max,
	   p_unit_status,
	   'N',
	   'N',
	   g_n_user_id,
	   SYSDATE,
	   g_n_user_id,
	   SYSDATE,
	   g_n_login_id
	   ) RETURNING int_pat_id INTO p_int_pat_id;


	   -- If sections does not exists for the pattern then insert the location and facilities
	   IF p_unit_status IS NOT NULL THEN

	     FOR c_loc_rec IN c_loc(p_pat_cur_rec.unit_cd,p_pat_cur_rec.version_number) LOOP
	       INSERT INTO IGS_PS_SCH_LOC_INT(
	       int_loc_id       ,
	       int_pat_id        ,
	       location_code      ,
	       location_description,
	       building_code        ,
	       building_description,
	       room_code            ,
	       room_description      ,
	       created_by             ,
	       creation_date          ,
	       last_updated_by        ,
	       last_update_date       ,
	       last_update_login )
	       VALUES
	       (IGS_PS_SCH_LOC_INT_S.NEXTVAL,
	       p_int_pat_id,
	       c_loc_rec.location_cd,
	       c_loc_rec.location_description,
	       c_loc_rec.building_cd,
	       c_loc_rec.building_description,
	       c_loc_rec.room_cd,
	       c_loc_rec.room_description,
	       g_n_user_id,
	       SYSDATE,
	       g_n_user_id,
	       SYSDATE,
	       g_n_login_id
	       );

	     END LOOP;

	     FOR c_fac_rec IN c_fac(p_pat_cur_rec.unit_cd,p_pat_cur_rec.version_number) LOOP
	       INSERT INTO IGS_PS_SCH_FAC_INT (
	       int_fac_id             ,
	       int_pat_id             ,
	       media_code             ,
	       media_description      ,
	       created_by             ,
	       creation_date          ,
	       last_updated_by        ,
	       last_update_date       ,
	       last_update_login
	       )
	       VALUES
	       (IGS_PS_SCH_FAC_INT_S.NEXTVAL,
	       p_int_pat_id,
	       c_fac_rec.media_code,
	       c_fac_rec.media_description,
	       g_n_user_id,
	       SYSDATE,
	       g_n_user_id,
	       SYSDATE,
	       g_n_login_id
	       );
	     END LOOP;
	   END IF;

	END  transfer_patterns;

	PROCEDURE transfer_sections(p_uoo_cur_rec IN uoo_cur%ROWTYPE,
                                    p_int_pat_id IN NUMBER,
                                    p_int_usec_id OUT NOCOPY NUMBER)  AS
	/**********************************************************
	  Created By : sarakshi

	  Date Created By : 21-May-2005

	  Purpose : Transfer Data to section interface table and its childs crosslisted and meetwith groups

	  Know limitations, enhancements or remarks

	  Change History

	  Who           When            What
          sommukhe      24-Jan-2006     Bug #4926548,modified the  cursor org_unit to fetch org_unit_description
	***************************************************************/
	   l_ou_description          igs_or_inst_org_base_v.party_name%TYPE;
	   l_usec_x_grp_name         igs_ps_usec_x_grp.usec_x_listed_group_name%TYPE;
	   l_max_enr_x_grp           igs_ps_usec_x_grpmem_v.enrollment_maximum%TYPE;
	   l_meet_with_grp_name      igs_ps_uso_cm_grp.class_meet_group_name%TYPE;

	    -- Get the Org Unit description for the unit
	       CURSOR org_unit( cp_owner_org_unit_cd igs_ps_unit_ofr_opt_all.owner_org_unit_cd%TYPE) IS
		  SELECT party_name org_unit_description
		  FROM   igs_or_inst_org_base_v
		  WHERE  party_number = cp_owner_org_unit_cd
		  AND inst_org_ind = 'O';


	       -- Get unit Section Cross Section
	       CURSOR usec_x_list ( l_uoo_id  igs_ps_unit_ofr_opt.uoo_id%TYPE ) IS
		       SELECT unit_sec_cross_unit_sec_id,
			      parent_uoo_id,child_uoo_id,
			      child_unit_cd,child_version_number,
			      child_title,child_cal_type,
			      child_alternate_code,start_dt,
			      end_dt,child_ci_sequence_number,child_unit_class,
			      child_unit_mode,child_location_cd,child_location_description
		       FROM   igs_ps_usec_x_usec_v
		       WHERE  parent_uoo_id = l_uoo_id;

	    -- Get the Cross Listed Group Name of the uoo_id
	       CURSOR usec_x_grp_name ( l_uoo_id  igs_ps_unit_ofr_opt.uoo_id%TYPE ) IS
		 SELECT  A.usec_x_listed_group_name
		 FROM    igs_ps_usec_x_grp_v A,
			 igs_ps_usec_x_grpmem_v B
		 WHERE   A.usec_x_listed_group_id = B.usec_x_listed_group_id
		 AND     B.uoo_id = l_uoo_id
		 AND     B.parent = 'Y';

	    -- Get the Maximum Enrollment Number for the Cross Listed Group of the uoo_id
	    -- Modified the cursor to select Enrollment Maximum when it is defined at group level(Cross Listed Unit Section)
	    -- otherwise from the unit section level as a part of Enh Bug # 2613933

	       CURSOR max_enr_x_grp ( l_uoo_id  igs_ps_unit_ofr_opt.uoo_id%TYPE ) IS
		 SELECT  NVL(A.max_ovr_group, A.max_enr_group) enroll_max
		 FROM    igs_ps_usec_x_grp A,
			 igs_ps_usec_x_grpmem B
		 WHERE  A.max_enr_group IS NOT NULL AND
			A.usec_x_listed_group_id = B.usec_x_listed_group_id AND
			B.uoo_id = l_uoo_id and B.parent = 'Y'
		 UNION ALL
		 SELECT  SUM(nvl(A.override_maximum, A.enrollment_maximum)) enroll_max
		 FROM   igs_ps_usec_x_grpmem_v A,
			igs_ps_usec_x_grpmem_v B
		 WHERE   A.enrollment_maximum is NOT NULL
		 AND    A.usec_x_listed_group_id = B.usec_x_listed_group_id
		 AND     B.uoo_id = l_uoo_id
		 AND     B.parent = 'Y';

	    -- Get the data of 'Meet_with' group related to the usec_id
	    -- Modified the cursor name from meet_with uso_id to meet_with_uoo_id and also modified
	    -- to select uoo_id instead of uso_id. As Meet with class functionality
	    -- is moved to Unit Section level as part of Enh Bug # 2613933
	       CURSOR meet_with_uoo_ids( l_uoo_id  igs_ps_uso_clas_meet.uoo_id%TYPE) IS
		  SELECT A.uoo_id host_uoo_id,
			 B.uoo_id guest_uoo_id
		  FROM   igs_ps_uso_clas_meet A,
			 igs_ps_uso_clas_meet B
		  WHERE  A.class_meet_group_id = B.class_meet_group_id AND
			 A.uoo_id = l_uoo_id AND
			 A.host  = 'Y' AND
			 B.host  = 'N' ;

	    -- Get the Class Meet Group Name of the usec_id
	    -- Modified the cursor to select group name from tables rather than view as a part of Enh Bug # 2613933
	       CURSOR meet_with_grp_name ( l_uoo_id  igs_ps_uso_clas_meet.uoo_id%TYPE) IS
		  SELECT  A.class_meet_group_name
		  FROM    igs_ps_uso_cm_grp A,
			  igs_ps_uso_clas_meet B
		  WHERE   A.class_meet_group_id = B.class_meet_group_id  AND
			  B.uoo_id = l_uoo_id  AND
			  B.host = 'Y';

	    -- Get the Maximum enrollment for meet with group of the usec_id
	    -- Modified the cursor to select Enrollment Maximum when it is defined at group level(Meet With Class)
	    -- otherwise from the unit section level as a part of Enh Bug # 2613933
	       CURSOR max_enr_meet_grp ( l_uoo_id  igs_ps_uso_clas_meet.uoo_id%TYPE) IS
		  SELECT  NVL(A.max_ovr_group, A.max_enr_group) enroll_max
		  FROM    igs_ps_uso_cm_grp A,
			  igs_ps_uso_clas_meet B
		  WHERE   A.max_enr_group IS NOT NULL AND
			  A.class_meet_group_id = B.class_meet_group_id AND
			  B.uoo_id = l_uoo_id and B.host = 'Y'
		  UNION ALL
		  SELECT SUM(NVL(A.override_maximum, A.enrollment_maximum)) enroll_max
		  FROM   igs_ps_uso_clas_meet_v A,
			 igs_ps_uso_clas_meet_v B
		  WHERE  A.enrollment_maximum IS NOT NULL  AND
			 A.class_meet_group_id = B.class_meet_group_id  AND
			 B.uoo_id = l_uoo_id  AND
			 B.host = 'Y';

	BEGIN
			 -- Get Org Unit
			 OPEN org_unit(p_uoo_cur_rec.owner_org_unit_cd);
			 FETCH org_unit INTO l_ou_description;
			 CLOSE  org_unit;

			 -- Procedure get_enrollment_lmts populates enrollment limts enrollment expected, enrollment maximum and
			 -- override maximum for this unit section in local variables l_enrollment_expected, l_enrollment_maximum
			 -- and l_override_enrollment_max respectively.

			 get_enrollment_lmts(p_uoo_cur_rec.uoo_id);

			 -- Insert Unit Section Occurs Interface Records  (IGS_PS_SCH_USEC_INT_ALL)
			 BEGIN
			    INSERT INTO igs_ps_sch_usec_int_all (
			       int_usec_id                       ,
			       calendar_type                     ,
			       sequence_number                   ,
			       unit_cd                           ,
			       version_number                    ,
			       unit_title                        ,
			       owner_org_unit_cd                 ,
			       unit_class                        ,
			       unit_section_start_date           ,
			       unit_section_end_date             ,
			       unit_section_status               ,
			       enrollment_maximum                ,
			       enrollment_actual                 ,
			       enrollment_expected               ,
			       override_enrollment_max           ,
			       location_cd                       ,
			       cal_start_dt                      ,
			       cal_end_dt                        ,
			       uoo_id                            ,
			       transaction_id                    ,
			       org_id                            ,
			       IMPORT_DONE_FLAG               ,
			       INT_PAT_ID                     ,
			       ABORT_FLAG                     ,
			       CALL_NUMBER                    ,
			       SUBTITLE                       ,
			       ORG_UNIT_DESCRIPTION           ,
			       TEACHING_CAL_ALTERNATE_CODE    ,
			       created_by             ,
			       creation_date          ,
			       last_updated_by        ,
			       last_update_date       ,
			       last_update_login
			      )
			      VALUES (
			      IGS_PS_SCH_USEC_INT_S.NEXTVAL,
			      l_cal_type,
			      l_ci_sequence_number,
			      p_uoo_cur_rec.unit_cd,
			      p_uoo_cur_rec.version_number,
			      p_uoo_cur_rec.title,
			      p_uoo_cur_rec.owner_org_unit_cd,
			      p_uoo_cur_rec.unit_class,
			      p_uoo_cur_rec.unit_section_start_date,
			      p_uoo_cur_rec.unit_section_end_date,
			      p_uoo_cur_rec.unit_section_status,
			      l_enrollment_maximum,
			      p_uoo_cur_rec.enrollment_actual,
			      l_enrollment_expected,
			      l_override_enrollment_max,
			      p_uoo_cur_rec.location_cd,
			      p_uoo_cur_rec.cal_start_dt,
			      p_uoo_cur_rec.cal_end_dt,
			      p_uoo_cur_rec.uoo_id,
			      l_trans_id,
			      p_org_id,
			      'N',
			      p_int_pat_id,
			      'N',
			      p_uoo_cur_rec.call_number,
			      p_uoo_cur_rec.subtitle,
			      l_ou_description,
			      p_uoo_cur_rec.teaching_cal_alternate_code,
			      g_n_user_id,
			      SYSDATE,
			      g_n_user_id,
			      SYSDATE,
			      g_n_login_id
			      ) RETURNING int_usec_id INTO p_int_usec_id;
			 END;

			 -- Insert Cross Listings Information
			 FOR usec_x_list_rec IN usec_x_list(p_uoo_cur_rec.uoo_id) LOOP

			     OPEN usec_x_grp_name(p_uoo_cur_rec.uoo_id);
			     FETCH usec_x_grp_name INTO l_usec_x_grp_name;
			     IF usec_x_grp_name%NOTFOUND THEN
				FND_MESSAGE.SET_NAME('IGS','IGS_PS_NO_GRP_EXISTS');
				FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
				l_usec_x_grp_name := NULL;
				ROLLBACK;
				retcode := 2;
				RETURN;
			     END IF;
			     CLOSE usec_x_grp_name;

			     OPEN max_enr_x_grp(p_uoo_cur_rec.uoo_id);
			     FETCH max_enr_x_grp INTO l_max_enr_x_grp;
			     IF max_enr_x_grp%NOTFOUND THEN
				FND_MESSAGE.SET_NAME('IGS','IGS_PS_NO_GRP_MAX_EXISTS');
				FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
				l_max_enr_x_grp := NULL;
				ROLLBACK;
				retcode := 2;
				RETURN;
			     END IF;
			     CLOSE max_enr_x_grp;

			     BEGIN
			       INSERT INTO igs_ps_sch_x_usec_int_all (
				int_usec_x_usec_id                ,
				int_usec_id                       ,
				unit_sec_cross_unit_sec_id        ,
				parent_uoo_id                     ,
				child_uoo_id                      ,
				child_unit_Cd                     ,
				child_version_number              ,
				child_title                       ,
				child_cal_type                    ,
				child_alternate_code              ,
				start_dt                          ,
				end_dt                            ,
				child_ci_sequence_number          ,
				child_unit_class                  ,
				child_unit_mode                   ,
				child_location_Cd                 ,
				child_location_description        ,
				org_id                            ,
				cross_list_group_name             ,
				class_max_enrollment_number       ,
				created_by             ,
				creation_date          ,
				last_updated_by        ,
				last_update_date       ,
				last_update_login
				)
				VALUES (
				IGS_PS_SCH_X_USEC_INT_S.NEXTVAL ,
				p_int_usec_id,
				usec_x_list_rec.unit_sec_cross_unit_sec_id,
				usec_x_list_rec.parent_uoo_id,
				usec_x_list_rec.child_uoo_id,
				usec_x_list_rec.child_unit_cd,
				usec_x_list_rec.child_version_number,
				usec_x_list_rec.child_title,
				usec_x_list_rec.child_cal_type,
				usec_x_list_rec.child_alternate_code,
				usec_x_list_rec.start_dt,
				usec_x_list_rec.end_dt,
				usec_x_list_rec.child_ci_sequence_number,
				usec_x_list_rec.child_unit_class,
				usec_x_list_rec.child_unit_mode,
				usec_x_list_rec.child_location_cd,
				usec_x_list_rec.child_location_description,
				p_org_id,
				l_usec_x_grp_name,
				l_max_enr_x_grp ,
				g_n_user_id,
				SYSDATE,
				g_n_user_id,
				SYSDATE,
				g_n_login_id
				) ;
			     END;

			 END LOOP;  -- End of FOR usec_x_list_rec IN usec_x_list(p_uoo_cur_rec.uoo_id) LOOP

			 -- MWC functionality has been moved from Unit Section Occurrence level to
			 -- Unit Section level. As per Enh Bug # 2613933
			 -- Insert Meet with group related Information
			 -- As the Meet with class functionality is moved to Unit Section level
			 -- Modified the cursors meet_with_uso_ids as meet_with_uoo_id. Also modified to cursor
			 -- to get meet_with_grp_name,max_enr_meet_grp with UOO_ID insted of USO_ID

			 FOR meet_with_grp_data_rec IN meet_with_uoo_ids ( p_uoo_cur_rec.uoo_id) LOOP

			     BEGIN

				OPEN meet_with_grp_name(p_uoo_cur_rec.uoo_id);
				FETCH meet_with_grp_name INTO l_meet_with_grp_name;
				IF meet_with_grp_name%NOTFOUND THEN
				   FND_MESSAGE.SET_NAME('IGS','IGS_PS_NO_MEET_GRP_EXISTS');
				   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
				   ROLLBACK;
				   RETCODE := 2;
				   RETURN;
				END IF;
				CLOSE meet_with_grp_name;

				OPEN max_enr_meet_grp(p_uoo_cur_rec.uoo_id);
				FETCH max_enr_meet_grp INTO l_max_enr_meet_grp;
				IF max_enr_meet_grp%NOTFOUND THEN
				   FND_MESSAGE.SET_NAME('IGS','IGS_PS_NO_MEET_GRP_MAX_EXISTS');
				   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
				   ROLLBACK;
				   RETCODE := 2;
				   RETURN;
				END IF;
				CLOSE max_enr_meet_grp;

				INSERT INTO  igs_ps_sch_mwc_all (
				mwc_group_id                      ,
				meet_with_class_group_name        ,
				host_uoo_id                       ,
				guest_uoo_id                      ,
				mwc_max_enrollment_number         ,
				org_id                            ,
				int_usec_id                       ,
				created_by             ,
				creation_date          ,
				last_updated_by        ,
				last_update_date       ,
				last_update_login
				)
				VALUES (
				IGS_PS_SCH_MWC_S.NEXTVAL,
				l_meet_with_grp_name,
				meet_with_grp_data_rec.host_uoo_id,
				meet_with_grp_data_rec.guest_uoo_id,
				l_max_enr_meet_grp,
				p_org_id,
				p_int_usec_id,
				g_n_user_id,
				SYSDATE,
				g_n_user_id,
				SYSDATE,
				g_n_login_id
				);
			     END;

			 END LOOP;    -- End of FOR meet_with_grp_data_rec IN meet_with_uoo_ids ( p_uoo_cur_rec.uoo_id) LOOP

	END  transfer_sections;


	PROCEDURE transfer_occurrences(p_usec_occur_rec usec_occur%ROWTYPE,
                                       p_uoo_cur_rec uoo_cur%ROWTYPE,
                                       p_int_usec_id IN NUMBER,
                                       P_trans_type IN VARCHAR2) AS
	/**********************************************************
	  Created By : sarakshi

	  Date Created By : 21-May-2005

	  Purpose : Transfer Data to occurrence interface table and its childs instructors, facilities and reference codes.

	  Know limitations, enhancements or remarks

	  Change History

	  Who           When            What
          sommukhe      24-Jan-2006     Bug #4926548,replaced igs_pe_person_v with hz_parties for cursor instrs
	***************************************************************/
	   l_int_occurs_id           igs_ps_sch_int_all.int_occurs_id%TYPE;
	    -- Get the reference code and reference code type
	       CURSOR ref_cd( l_usec_id  igs_ps_usec_occurs.unit_section_occurrence_id%TYPE) IS
		SELECT   reference_code,
			 reference_code_description,
			 reference_code_type,
			 reference_type_description
		FROM    igs_ps_usec_ocur_ref_v
		WHERE   unit_section_occurrence_id = l_usec_id;



	    -- Get the instructors of the usec_id
	       CURSOR instrs (l_usec_id  igs_ps_usec_occurs.unit_section_occurrence_id%TYPE) IS
		  SELECT A.instructor_id,
  			 B.PERSON_LAST_NAME surname,
  			 B.PERSON_FIRST_NAME given_names,
  			 B.PERSON_MIDDLE_NAME middle_name,
  			 B.party_name person_name
  		  FROM   igs_ps_uso_instrctrs_v A,
  			 HZ_PARTIES  B
  		  WHERE  A.person_number = B.party_number  AND
  			 A.unit_section_occurrence_id = l_usec_id;

	    -- Get the Facilities associated with the usec_id
	       CURSOR facilities (l_usec_id  igs_ps_usec_occurs.unit_section_occurrence_id%TYPE) IS
		  SELECT facility_code,
			 facility_description
		  FROM   igs_ps_uso_facility_v
		  WHERE  unit_section_occurrence_id = l_usec_id;

	    -- Get the Facilities associated with the usec_id
	       CURSOR unit_facilities (l_usec_id  igs_ps_usec_occurs.unit_section_occurrence_id%TYPE) IS
		  SELECT media_code,
			 media_description
		  FROM   igs_ps_usec_occurs_all a,
		         igs_ps_unit_ofr_opt_all b,
			 igs_ps_unit_facility_v c
		  WHERE  a.unit_section_occurrence_id = l_usec_id
		  AND    a.uoo_id=b.uoo_id
		  AND    b.unit_cd=c.unit_code
		  AND    b.version_number=c.unit_version_number;

               l_section_facility_exist BOOLEAN := FALSE;

	BEGIN

				   -- Insert Unit Section Occurs Interface Records
				   DECLARE
				      l_start_date igs_ps_usec_occurs_all.start_date%TYPE;
				      l_end_date igs_ps_usec_occurs_all.end_date%TYPE;
				   BEGIN
				      IF p_usec_occur_rec.start_date IS NULL OR p_usec_occur_rec.end_date IS NULL THEN
					l_start_date := p_uoo_cur_rec.cal_start_dt;
					l_end_date   := p_uoo_cur_rec.cal_end_dt;
				      ELSE
					l_start_date := p_usec_occur_rec.start_date;
					l_end_date   := p_usec_occur_rec.end_date;
				      END IF;

				      -- The fields which are passed as NULL are OBSOLETE columns as per the Modified Scheduling Interface DLD 1.0
				      -- Enh bug #2833850.
				      -- Added the column preferred_region_code to the call igs_ps_sch_int_pkg.insert_row
				      INSERT INTO igs_ps_sch_int_all (
					int_occurs_id                     ,
					int_usec_id                       ,
					calendar_type                     ,
					sequence_number                   ,
					transaction_type                  ,
					unit_section_occurrence_id        ,
					unit_cd                           ,
					version_number                    ,
					unit_title                        ,
					owner_org_unit_cd                 ,
					unit_class                        ,
					monday                            ,
					tuesday                           ,
					wednesday                         ,
					thursday                          ,
					friday                            ,
					saturday                          ,
					sunday                            ,
					unit_section_start_date           ,
					unit_section_end_date             ,
					start_time                        ,
					end_time                          ,
					enrollment_maximum                ,
					enrollment_actual                 ,
					instructor_id                     ,
					building_id                       ,
					room_id                           ,
					dedicated_building_id             ,
					dedicated_room_id                 ,
					preferred_building_id             ,
					preferred_room_id                 ,
					tba_status                        ,
					uso_start_date                    ,
					uso_end_date                      ,
					location_cd                       ,
					unit_sec_cross_unit_sec_id        ,
					uoo_id                            ,
					schedule_status                   ,
					error_text                        ,
					transaction_id                    ,
					surname                           ,
					given_names                       ,
					middle_name                       ,
					preferred_region_code             ,
					org_id                            ,
					occurrence_identifier             ,
					import_done_flag                  ,
					abort_flag                        ,
					created_by             ,
					creation_date          ,
					last_updated_by        ,
					last_update_date       ,
					last_update_login
					)
					VALUES (
					IGS_PS_SCH_INT_S.NEXTVAL,
					p_int_usec_id,
					NULL,
					NULL,
					P_trans_type,
					p_usec_occur_rec.unit_section_occurrence_id,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					p_usec_occur_rec.monday,
					p_usec_occur_rec.tuesday,
					p_usec_occur_rec.wednesday,
					p_usec_occur_rec.thursday,
					p_usec_occur_rec.friday,
					p_usec_occur_rec.saturday,
					p_usec_occur_rec.sunday,
					l_start_date,
					l_end_date,
					p_usec_occur_rec.start_time,
					p_usec_occur_rec.end_time,
					NULL,
					NULL,
					l_lead_instructor_id,
					p_usec_occur_rec.building_code,
					p_usec_occur_rec.room_code,
					p_usec_occur_rec.dedicated_building_code,
					p_usec_occur_rec.dedicated_room_code,
					p_usec_occur_rec.preferred_building_code,
					p_usec_occur_rec.preferred_room_code,
					p_usec_occur_rec.to_be_announced,
					p_usec_occur_rec.start_date,
					p_usec_occur_rec.end_date,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					l_surname ,
					l_given_names,
					l_middle_name,
					p_usec_occur_rec.preferred_region_code,
					p_org_id,
					p_usec_occur_rec.occurrence_identifier,
					'N',
					'N',
					g_n_user_id,
					SYSDATE,
					g_n_user_id,
					SYSDATE,
					g_n_login_id
					) RETURNING int_occurs_id INTO l_int_occurs_id;
				   END;

				   -- Insert Ref Cd Information
				   FOR ref_cd_rec IN ref_cd( p_usec_occur_rec.unit_section_occurrence_id ) LOOP
				      BEGIN
					-- The fields which are passed as NULL are OBSOLETE columns as per the Modified Scheduling Interface DLD 1.0
					INSERT INTO igs_ps_prefs_sch_int_all (
					int_prefs_id                     ,
					int_occurs_id                    ,
					reference_cd                     ,
					reference_code_description       ,
					reference_cd_type                ,
					reference_type_description       ,
					transaction_id                   ,
					unit_section_occurrence_id       ,
					org_id                           ,
					created_by             ,
					creation_date          ,
					last_updated_by        ,
					last_update_date       ,
					last_update_login
					)
					VALUES (
					IGS_PS_PREFS_SCH_INT_S.NEXTVAL,
					l_int_occurs_id,
					ref_cd_rec.reference_code,
					ref_cd_rec.reference_code_description,
					ref_cd_rec.reference_code_type,
					ref_cd_rec.reference_type_description,
					NULL,
					NULL,
					p_org_id,
					g_n_user_id,
					SYSDATE,
					g_n_user_id,
					SYSDATE,
					g_n_login_id
					);
				      END;
				   END LOOP;

				   -- Insert Instructor related Information
				   FOR instrs_rec IN instrs( p_usec_occur_rec.unit_section_occurrence_id ) LOOP
				      BEGIN
					INSERT INTO igs_ps_sch_instr_all (
					int_instruc_id                    ,
					instructor_id                     ,
					surname                           ,
					given_names                       ,
					middle_name                       ,
					int_occurs_id                     ,
					person_name                       ,
					org_id                            ,
					created_by             ,
					creation_date          ,
					last_updated_by        ,
					last_update_date       ,
					last_update_login
					)
					VALUES (
					IGS_PS_SCH_INSTR_S.NEXTVAL,
					instrs_rec.instructor_id,
					instrs_rec.surname,
					instrs_rec.given_names,
					instrs_rec.middle_name,
					l_int_occurs_id,
					instrs_rec.person_name,
					p_org_id,
					g_n_user_id,
					SYSDATE,
					g_n_user_id,
					SYSDATE,
					g_n_login_id
					);
				      END;
				   END LOOP;

				   -- Insert Facility related Information
				   FOR facilities_rec IN facilities ( p_usec_occur_rec.unit_section_occurrence_id ) LOOP
				      BEGIN
				        l_section_facility_exist := TRUE;
					INSERT INTO igs_ps_sch_faclt_all (
					facility_id                       ,
					facility_code                     ,
					facility_description              ,
					org_id                            ,
					int_occurs_id                     ,
					created_by             ,
					creation_date          ,
					last_updated_by        ,
					last_update_date       ,
					last_update_login
					)
					VALUES (
					IGS_PS_SCH_FACLT_S.NEXTVAL,
					facilities_rec.facility_code,
					facilities_rec.facility_description,
					p_org_id,
					l_int_occurs_id,
					g_n_user_id,
					SYSDATE,
					g_n_user_id,
					SYSDATE,
					g_n_login_id
					);
				      END;
				   END LOOP;

                                   --If facilities does not exist at section level then pass the unit level value
				   IF l_section_facility_exist = FALSE THEN
				     FOR unit_facilities_rec IN unit_facilities ( p_usec_occur_rec.unit_section_occurrence_id ) LOOP
					BEGIN
					  INSERT INTO igs_ps_sch_faclt_all (
					  facility_id                       ,
					  facility_code                     ,
					  facility_description              ,
					  org_id                            ,
					  int_occurs_id                     ,
					  created_by             ,
					  creation_date          ,
					  last_updated_by        ,
					  last_update_date       ,
					  last_update_login
					  )
					  VALUES (
					  IGS_PS_SCH_FACLT_S.NEXTVAL,
					  unit_facilities_rec.media_code,
					  unit_facilities_rec.media_description,
					  p_org_id,
					  l_int_occurs_id,
					  g_n_user_id,
					  SYSDATE,
					  g_n_user_id,
					  SYSDATE,
					  g_n_login_id
					  );
					END;
				     END LOOP;
				   END IF;

	END  transfer_occurrences;

	PROCEDURE call_generic_transfer ( p_c_unit_cd IN igs_ps_unit_ver.unit_cd%TYPE,
                                          p_n_version_number IN igs_ps_unit_ver.version_number%TYPE,
                                          p_c_location_cd IN igs_ps_unit_ofr_opt_all.location_cd%TYPE,
                                          p_n_unit_class IN igs_ps_unit_ofr_opt_all.unit_class%TYPE,
                                          p_n_usec_id IN igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE ) AS
	/**********************************************************
	  Created By : sarakshi

	  Date Created By : 21-May-2005

	  Purpose : Transfer Data to scheduling interface table

	  Know limitations, enhancements or remarks

	  Change History

	  Who           When            What
	  sommukhe      22-MAY-2006	Bug#5239345,Added one extra parameter to Cursor c_is_req and hence conditional
	                                transfer of sections depending on the schedule type.
	  sarakshi      12-Jan-2005     Bug#4926548, created cursors usec_ref and unit_sub
	***************************************************************/

	    CURSOR cur_prod_pattern(cp_unit_cd IN VARCHAR2,
				    cp_version_number IN NUMBER,
				    cp_cal_type IN VARCHAR2,
				    cp_ci_sequence_number IN NUMBER) IS
	    SELECT pt.*,pt.rowid
	    FROM  igs_ps_unit_ofr_pat pt
	    WHERE unit_cd=cp_unit_cd
	    AND   version_number=cp_version_number
	    AND   cal_type=cp_cal_type
	    AND   ci_sequence_number=cp_ci_sequence_number;
	    l_prod_pattern cur_prod_pattern%ROWTYPE;

	    CURSOR 	cur_prod_uoo(cp_uoo_id IN NUMBER) IS
	    SELECT us.*,us.rowid
	    FROM  igs_ps_unit_ofr_opt_all us
	    WHERE us.uoo_id = cp_uoo_id;
	    l_cur_uoo_rec cur_prod_uoo%ROWTYPE;

	    CURSOR 	cur_prod_uoo_occur(cp_unit_section_occurrence_id IN NUMBER) IS
	    SELECT us.*,us.rowid
	    FROM  igs_ps_usec_occurs_all us
	    WHERE us.unit_section_occurrence_id = cp_unit_section_occurrence_id;
	    l_usec_occurs_rec cur_prod_uoo_occur%ROWTYPE;

	    l_o_count NUMBER;
	    l_trans_type VARCHAR2(30);

	    CURSOR  usec_ref(cp_uoo_id  igs_ps_usec_ref_v.uoo_id%TYPE) IS
	    SELECT  ur.title, ur.subtitle
	    FROM    igs_ps_usec_ref_v ur
	    WHERE   ur.uoo_id = cp_uoo_id;

	    CURSOR  unit_sub(cp_subtitle_id igs_ps_unit_subtitle.subtitle_id%TYPE) IS
	    SELECT  usub.subtitle
	    FROM    igs_ps_unit_subtitle usub
	    WHERE   usub.subtitle_id = cp_subtitle_id ;
	    l_usec_title    igs_ps_usec_ref_v.title%TYPE;
	    l_usec_subtitle igs_ps_usec_ref_v.subtitle%TYPE;
	    l_unit_subtitle igs_ps_unit_subtitle.subtitle%TYPE;


	BEGIN
	       -- Set the Derived scheduler Type
	       IF p_sch_type = 'REQUEST' OR p_sch_type IS NULL THEN
		  l_derd_sch_type := 'NULL';
	       ELSIF p_sch_type = 'UPDATE' THEN
		  l_derd_sch_type := 'USER_UPDATE';
	       ELSIF p_sch_type = 'CANCEL' THEN
		  l_derd_sch_type := 'USER_CANCEL';
	       END IF;


	       --Get the pattern details and insert in the pattern interface table
	       FOR pat_cur_rec IN pat_cur(l_cal_type,l_ci_sequence_number,p_c_unit_cd,p_n_version_number) LOOP

		  IF l_trans_id IS NULL THEN
		    create_header;
		  END IF;

		  l_unit_status:= NULL;
		  l_int_pat_id:= NULL;
		  transfer_patterns(pat_cur_rec,l_unit_status,l_int_pat_id);

		  --If section does exists in the production
		  IF l_unit_status IS NULL THEN
		    -- Get the Unit Section Details
		    FOR uoo_cur_rec IN uoo_cur(l_cal_type, l_ci_sequence_number,pat_cur_rec.unit_cd,pat_cur_rec.version_number,p_c_location_cd,p_n_unit_class) LOOP

		      --For performance reason  share memory high , creating independent sql for getting certain values for the
		      --above cursor
                      l_usec_title :=NULL;
		      l_usec_subtitle := NULL;
                      l_unit_subtitle := NULL;

                      OPEN usec_ref(uoo_cur_rec.uoo_id);
		      FETCH usec_ref INTO l_usec_title,l_usec_subtitle;
		      CLOSE usec_ref;

                      IF l_usec_subtitle IS NULL  AND uoo_cur_rec.subtitle_id IS NOT NULL THEN
			OPEN unit_sub(uoo_cur_rec.subtitle_id);
			FETCH unit_sub INTO l_unit_subtitle;
			CLOSE unit_sub;
		      END IF;

                      uoo_cur_rec.title := NVL(l_usec_title,uoo_cur_rec.title);
                      uoo_cur_rec.subtitle := NVL(l_usec_subtitle,l_unit_subtitle);

		      l_valid_occur:= FALSE; --added by sarakshi
		      OPEN c_is_req (uoo_cur_rec.uoo_id,p_n_usec_id,l_derd_sch_type) ;
		      FETCH c_is_req INTO rec_is_req;
		      -- if there exist atleast one unit section which needs to be transferred to interface table then
		      IF c_is_req%FOUND THEN

			 transfer_sections(uoo_cur_rec,l_int_pat_id,l_int_usec_id);

		      END IF; -- End of
		      CLOSE c_is_req;

		      --function get_instructor_info populates lead instructor identifier, given name(first name), middle name
		      --and last name in the local variables l_lead_instructor_id, l_given_names ,l_middle_name and l_surname respectively.
		      -- returns false only when lead instructor is set at unit section and could not fetch instructor details.
		      IF NOT get_instructor_info(uoo_cur_rec.uoo_id) THEN
			 FND_MESSAGE.SET_NAME('IGS','IGS_PS_NO_NAMES_EXISTS');
			 FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
			 ROLLBACK;
			 RETCODE := 2;
			 RETURN;
		      END IF;


		      -- Get unit Section occurrence details
		      FOR usec_occur_rec IN usec_occur( uoo_cur_rec.uoo_id,p_n_usec_id) LOOP

			  -- Get the schedule_status
			  IF p_sch_type IS NOT NULL THEN --Called from SRS
			    IF NVL(usec_occur_rec.schedule_status,'NULL') = l_derd_sch_type THEN
			       l_valid_occur:= TRUE;
			       transfer_occurrences(usec_occur_rec,uoo_cur_rec,l_int_usec_id,p_sch_type);
			    END IF;
			  ELSE --Called from buttons (schedule current/set)
			     IF NVL(usec_occur_rec.schedule_status,'NULL') IN ('NULL','CANCELLED') THEN
			       l_trans_type := 'REQUEST';
			       l_valid_occur:= TRUE;
			       transfer_occurrences(usec_occur_rec,uoo_cur_rec,l_int_usec_id,l_trans_type);
			     ELSIF usec_occur_rec.schedule_status = 'USER_UPDATE' THEN
			       l_trans_type := 'UPDATE';
			       l_valid_occur:= TRUE;
			       transfer_occurrences(usec_occur_rec,uoo_cur_rec,l_int_usec_id,l_trans_type);
			     ELSIF usec_occur_rec.schedule_status = 'USER_CANCEL' THEN
			       l_trans_type := 'CANCEL';
			       l_valid_occur:= TRUE;
			       transfer_occurrences(usec_occur_rec,uoo_cur_rec,l_int_usec_id,l_trans_type);
			     END IF;

			  END IF;

		      END LOOP;    -- End of unit Section occurrence details loop

		      l_usec := TRUE;

		      --If valid occurrence is not there, and the section is not having any occurrences in production table then
		      --insert the section record
		      IF l_valid_occur = FALSE THEN
			 OPEN c_occur_exists(uoo_cur_rec.uoo_id);
			 FETCH c_occur_exists INTO l_c_var;
			 IF c_occur_exists%NOTFOUND THEN
			   IF p_sch_type = 'REQUEST' THEN
			     transfer_sections(uoo_cur_rec,l_int_pat_id,l_int_usec_id);
                           END IF;
			 END IF;
			 CLOSE c_occur_exists;
		      END IF;

		    END LOOP; -- End of FOR uoo_cur_rec IN uoo_cur
		  END IF;

		  --IF there is no section for the pattern record in the interface
		  --If no section are there in production also then do nothing else delete the pattern record.

		  OPEN c_section_int_exists(l_int_pat_id);
		  FETCH c_section_int_exists INTO l_c_var;
		  IF c_section_int_exists%NOTFOUND THEN
                    IF  (p_sch_type = 'REQUEST' AND l_unit_status IS NULL) OR (p_sch_type IN ('UPDATE','CANCEL') )  THEN
		      DELETE IGS_PS_SCH_PAT_INT WHERE int_pat_id=l_int_pat_id;
		    END IF;
		  END IF;
		  CLOSE c_section_int_exists;

		END LOOP; --Pattern loop

		--If there are no pattern records in the interface table against the header record then delete the header record.
		IF l_trans_id IS NOT NULL THEN
		  OPEN c_pattern_int_exists(l_trans_id);
		  FETCH c_pattern_int_exists INTO l_c_var;
		  IF c_pattern_int_exists%NOTFOUND THEN
		    DELETE IGS_PS_SCH_HDR_INT_ALL WHERE transaction_id = l_trans_id;
		    l_data_found := FALSE;
		  ELSE
		    l_data_found := TRUE;
		    --Update all the production records for the abort_flag='N'
		    FOR l_pattern_prod_rec IN c_pattern_prod(l_trans_id) LOOP

		       --Log the pattern in the log file
		       FND_FILE.NEW_LINE(FND_FILE.LOG,1);
		       fnd_file.put_line(fnd_file.log, igs_ps_validate_lgcy_pkg.get_lkup_meaning('PATTERNS','IGS_PS_TABLE_NAME')||':');
		       fnd_file.put_line(fnd_file.log, '**********');
		       log_teach_cal(l_pattern_prod_rec.calendar_type,l_pattern_prod_rec.sequence_number);
		       log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('UNIT_CD','LEGACY_TOKENS'),l_pattern_prod_rec.unit_cd,10);
		       log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('VERSION_NUMBER','IGS_PS_LOG_PARAMETERS'),l_pattern_prod_rec.version_number,10);


		      OPEN cur_prod_pattern(l_pattern_prod_rec.unit_cd,l_pattern_prod_rec.version_number,l_pattern_prod_rec.calendar_type,l_pattern_prod_rec.sequence_number);
		      FETCH cur_prod_pattern INTO l_prod_pattern;
		      CLOSE cur_prod_pattern;

		      igs_ps_unit_ofr_pat_pkg.update_row (
			  X_Mode                              => 'R',
			  X_RowId                             => l_prod_pattern.rowid,
			  X_Unit_Cd                           => l_prod_pattern.Unit_Cd,
			  X_Version_Number                    => l_prod_pattern.Version_Number,
			  X_Cal_Type                          => l_prod_pattern.Cal_Type,
			  X_Ci_Sequence_Number                => l_prod_pattern.Ci_Sequence_Number,
			  X_Ci_Start_Dt                       => l_prod_pattern.Ci_Start_Dt,
			  X_Ci_End_Dt                         => l_prod_pattern.Ci_End_Dt,
			  x_waitlist_allowed                  => l_prod_pattern.waitlist_allowed,
			  x_max_students_per_waitlist         => l_prod_pattern.max_students_per_waitlist,
			  x_delete_flag                       => l_prod_pattern.delete_flag,
			  x_abort_flag                        =>  'N'
			);


		      l_o_count:=1;
		      FOR l_section_prod_rec IN c_section(l_pattern_prod_rec.int_pat_id) LOOP

			 --Log the section in the log file
			 FND_FILE.NEW_LINE(FND_FILE.LOG,1);
			 IF l_o_count=1 THEN
			   fnd_file.put_line(fnd_file.log, igs_ps_validate_lgcy_pkg.get_lkup_meaning('SECTIONS','IGS_PS_TABLE_NAME')||':');
			   fnd_file.put_line(fnd_file.log, '----------');
			 END IF;
			 log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('UNIT_CD','LEGACY_TOKENS'),l_section_prod_rec.unit_cd,10);
			 log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('VERSION_NUMBER','IGS_PS_LOG_PARAMETERS'),l_section_prod_rec.version_number,10);
			 log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('LOC','IGS_FI_ACCT_ENTITIES'),l_section_prod_rec.location_cd,10);
			 log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('UNIT_CLASS','LEGACY_TOKENS'),l_section_prod_rec.unit_class,10);




			 OPEN cur_prod_uoo(l_section_prod_rec.uoo_id);
			 FETCH cur_prod_uoo INTO l_cur_uoo_rec;
			 CLOSE cur_prod_uoo;

			 igs_ps_unit_ofr_opt_pkg.update_row (
			    x_mode                              => 'R',
			    x_rowid                             => l_cur_uoo_rec.rowid,
			    x_unit_cd                           => l_cur_uoo_rec.unit_cd,
			    x_version_number                    => l_cur_uoo_rec.version_number,
			    x_cal_type                          => l_cur_uoo_rec.cal_type,
			    x_ci_sequence_number                => l_cur_uoo_rec.ci_sequence_number,
			    x_location_cd                       => l_cur_uoo_rec.location_cd,
			    x_unit_class                        => l_cur_uoo_rec.unit_class,
			    x_uoo_id                            => l_cur_uoo_rec.uoo_id,
			    x_ivrs_available_ind                => l_cur_uoo_rec.ivrs_available_ind,
			    x_call_number                       => l_cur_uoo_rec.call_number,
			    x_unit_section_status               => l_cur_uoo_rec.unit_section_status,
			    x_unit_section_start_date           => l_cur_uoo_rec.unit_section_start_date,
			    x_unit_section_end_date             => l_cur_uoo_rec.unit_section_end_date,
			    x_enrollment_actual                 => l_cur_uoo_rec.enrollment_actual,
			    x_waitlist_actual                   => l_cur_uoo_rec.waitlist_actual,
			    x_offered_ind                       => l_cur_uoo_rec.offered_ind,
			    x_state_financial_aid               => l_cur_uoo_rec.state_financial_aid,
			    x_grading_schema_prcdnce_ind        => l_cur_uoo_rec.grading_schema_prcdnce_ind,
			    x_federal_financial_aid             => l_cur_uoo_rec.federal_financial_aid,
			    x_unit_quota                        => l_cur_uoo_rec.unit_quota,
			    x_unit_quota_reserved_places        => l_cur_uoo_rec.unit_quota_reserved_places,
			    x_institutional_financial_aid       => l_cur_uoo_rec.institutional_financial_aid,
			    x_unit_contact                      => l_cur_uoo_rec.unit_contact,
			    x_grading_schema_cd                 => l_cur_uoo_rec.grading_schema_cd,
			    x_gs_version_number                 => l_cur_uoo_rec.gs_version_number,
			    x_owner_org_unit_cd                 => l_cur_uoo_rec.owner_org_unit_cd,
			    x_attendance_required_ind           => l_cur_uoo_rec.attendance_required_ind,
			    x_reserved_seating_allowed          => l_cur_uoo_rec.reserved_seating_allowed,
			    x_special_permission_ind            => l_cur_uoo_rec.special_permission_ind,
			    x_ss_enrol_ind                      => l_cur_uoo_rec.ss_enrol_ind,
			    x_ss_display_ind                    => l_cur_uoo_rec.ss_display_ind,
			    x_dir_enrollment                    => l_cur_uoo_rec.dir_enrollment,
			    x_enr_from_wlst                     => l_cur_uoo_rec.enr_from_wlst,
			    x_inq_not_wlst                      => l_cur_uoo_rec.inq_not_wlst,
			    x_rev_account_cd                    => l_cur_uoo_rec.rev_account_cd,
			    x_anon_unit_grading_ind             => l_cur_uoo_rec.anon_unit_grading_ind,
			    x_anon_assess_grading_ind           => l_cur_uoo_rec.anon_assess_grading_ind,
			    x_non_std_usec_ind                  => l_cur_uoo_rec.non_std_usec_ind,
			    x_auditable_ind                     => l_cur_uoo_rec.auditable_ind,
			    x_audit_permission_ind              => l_cur_uoo_rec.audit_permission_ind,
			    x_not_multiple_section_flag         => l_cur_uoo_rec.not_multiple_section_flag,
			    x_sup_uoo_id                        => l_cur_uoo_rec.sup_uoo_id,
			    x_relation_type                     => l_cur_uoo_rec.relation_type,
			    x_default_enroll_flag               => l_cur_uoo_rec.default_enroll_flag,
			    x_abort_flag                        => 'N'
			  );


			 --UPDATE igs_ps_unit_ofr_opt_all set abort_flag='N' where uoo_id=l_section_prod_rec.uoo_id;

			 l_o_count := 0;
			 FOR l_occurrence_prod_rec IN c_occurrence(l_section_prod_rec.int_usec_id) LOOP

			    --Log the occurrences in the log file
			    FND_FILE.NEW_LINE(FND_FILE.LOG,1);
			    IF l_o_count = 0 THEN
			      fnd_file.put_line(fnd_file.log, igs_ps_validate_lgcy_pkg.get_lkup_meaning('OCCURRENCES','IGS_PS_TABLE_NAME')||':');
			      fnd_file.put_line(fnd_file.log, '-------------');
			      l_o_count:=1;
			    END IF;
			    log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('USEC_OCCRS_ID','IGS_PS_LOG_PARAMETERS'),l_occurrence_prod_rec.occurrence_identifier,10);


			     OPEN cur_prod_uoo_occur(l_occurrence_prod_rec.unit_section_occurrence_id);
			     FETCH cur_prod_uoo_occur INTO l_usec_occurs_rec;
			     CLOSE cur_prod_uoo_occur;

			     igs_ps_usec_occurs_pkg.update_row (
			       x_rowid                             => l_usec_occurs_rec.ROWID,
			       x_unit_section_occurrence_id        => l_usec_occurs_rec.unit_section_occurrence_id,
			       x_uoo_id                            => l_usec_occurs_rec.uoo_id,
			       x_monday                            => l_usec_occurs_rec.monday,
			       x_tuesday                           => l_usec_occurs_rec.tuesday,
			       x_wednesday                         => l_usec_occurs_rec.wednesday,
			       x_thursday                          => l_usec_occurs_rec.thursday,
			       x_friday                            => l_usec_occurs_rec.friday,
			       x_saturday                          => l_usec_occurs_rec.saturday,
			       x_sunday                            => l_usec_occurs_rec.sunday,
			       x_start_time                        => l_usec_occurs_rec.start_time,
			       x_end_time                          => l_usec_occurs_rec.end_time,
			       x_building_code                     => l_usec_occurs_rec.building_code,
			       x_room_code                         => l_usec_occurs_rec.room_code,
			       x_schedule_status                   => 'PROCESSING',
			       x_status_last_updated               => SYSDATE,
			       x_instructor_id                     => l_usec_occurs_rec.instructor_id,
			       X_attribute_category                => l_usec_occurs_rec.attribute_category,
			       X_attribute1                        => l_usec_occurs_rec.attribute1,
			       X_attribute2                        => l_usec_occurs_rec.attribute2,
			       X_attribute3                        => l_usec_occurs_rec.attribute3,
			       X_attribute4                        => l_usec_occurs_rec.attribute4,
			       X_attribute5                        => l_usec_occurs_rec.attribute5,
			       X_attribute6                        => l_usec_occurs_rec.attribute6,
			       X_attribute7                        => l_usec_occurs_rec.attribute7,
			       X_attribute8                        => l_usec_occurs_rec.attribute8,
			       X_attribute9                        => l_usec_occurs_rec.attribute9,
			       X_attribute10                       => l_usec_occurs_rec.attribute10,
			       X_attribute11                       => l_usec_occurs_rec.attribute11,
			       X_attribute12                       => l_usec_occurs_rec.attribute12,
			       X_attribute13                       => l_usec_occurs_rec.attribute13,
			       X_attribute14                       => l_usec_occurs_rec.attribute14,
			       X_attribute15                       => l_usec_occurs_rec.attribute15,
			       X_attribute16                       => l_usec_occurs_rec.attribute16,
			       X_attribute17                       => l_usec_occurs_rec.attribute17,
			       X_attribute18                       => l_usec_occurs_rec.attribute18,
			       X_attribute19                       => l_usec_occurs_rec.attribute19,
			       X_attribute20                       => l_usec_occurs_rec.attribute20,
			       x_error_text                        => l_usec_occurs_rec.error_text,
			       x_mode                              => 'R',
			       X_start_date                        => l_usec_occurs_rec.start_date,
			       X_end_date                          => l_usec_occurs_rec.end_date,
			       X_to_be_announced                   => l_usec_occurs_rec.to_be_announced,
			       x_dedicated_building_code           => l_usec_occurs_rec.dedicated_building_code,
			       x_dedicated_room_code               => l_usec_occurs_rec.dedicated_room_code,
			       x_preferred_building_code           => l_usec_occurs_rec.preferred_building_code,
			       x_preferred_room_code               => l_usec_occurs_rec.preferred_room_code,
			       x_inst_notify_ind                   => l_usec_occurs_rec.inst_notify_ind,
			       x_notify_status                     => l_usec_occurs_rec.notify_status,
			       x_preferred_region_code             => l_usec_occurs_rec.preferred_region_code,
			       x_no_set_day_ind                    => l_usec_occurs_rec.no_set_day_ind,
			       x_cancel_flag                       => 'N',
			       x_occurrence_identifier             => l_usec_occurs_rec.occurrence_identifier,
			       x_abort_flag                        => 'N'
			     );

			   --UPDATE igs_ps_usec_occurs_all set abort_flag='N', schedule_status='PROCESSING',status_last_updated=SYSDATE,cancel_flag='N' where unit_section_occurrence_id=l_occurrence_prod_rec.unit_section_occurrence_id;

			 END LOOP;

		      END LOOP;

		    END LOOP;


		  END IF;
		  CLOSE c_pattern_int_exists;
		END IF;




	END call_generic_transfer;
---


   BEGIN

     l_data_found := FALSE;

     -- Set the default status as success
     retcode := 0;

     -- set the multi org id
     igs_ge_gen_003.set_org_id (p_org_id);

     -- Check for  the scheduling software is installed or not
     -- Profile name (IGS: Indicates whether Scheduling Software is installed.)
     -- Give a message to user if the software is not installed and
     -- stop the further processing
     IF (NVL(FND_PROFILE.VALUE('IGS_PS_SCH_SOFT_NOT_INSTLD'),'N')) = 'N' THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_PS_SCH_SOFT_NOT_INSTLD');
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            retcode := 2;
            RETURN;
     END IF;


     -- Not enough parameters condition
     IF ( (p_teach_prd IS NULL) AND (p_uoo_id IS NULL) AND (p_usec_id IS NULL ) AND (p_sch_type IS NULL) ) THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_GE_NOT_ENGH_PARAM');
           FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
           retcode := 2;
           RETURN;
     END IF;

    -- Scheduling Can only be done for Current and Future teaching period Unit Sections and
    -- not for past teaching period unit sections for the Bug # 2383610  as a part of Bug # 2383553

     IF p_teach_prd IS NULL AND p_uoo_id IS NOT NULL THEN
        OPEN  c_end_dt(p_uoo_id);
        FETCH c_end_dt INTO rec_end_dt;
        CLOSE c_end_dt;
        IF TRUNC(rec_end_dt.cal_end_dt) < TRUNC(sysdate) THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_PS_CANT_SCH_PAST_TP');
           FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
           ROLLBACK;
           retcode := 2;
           RETURN;
        END IF;
     END IF;


     -- check the valid values for the sch_type
     IF p_sch_type IS NOT NULL AND p_sch_type NOT IN ('REQUEST', 'UPDATE', 'CANCEL' ) THEN

	 FND_MESSAGE.SET_NAME('IGS','IGS_PS_INVALID_SCHTYPE');
	 FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
	 retcode := 2;
	 RETURN;
     END IF;

     -- Batch Program case
     -- 1.Teach Period is supplied - Batch Process
     --
     IF p_teach_prd IS NOT NULL THEN

        -- Get the cal_tpe,sequence_number and start date and End date
        l_cal_type := RTRIM(SUBSTR(p_teach_prd,101,10));
        l_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_teach_prd,112,6)));
        l_start_date := fnd_date.string_to_date(RTRIM(SUBSTR(p_teach_prd,11,11)), 'DD-MON-YYYY');
        l_end_date := fnd_date.string_to_date(RTRIM(SUBSTR(p_teach_prd,24,11)), 'DD-MON-YYYY');

        -- Check for End date is <= sysdate
        -- Thus avoiding scheduling of past teaching periods.
        IF TRUNC(l_end_date) < TRUNC(sysdate) THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_PS_CANT_SCH_PAST_TP');
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            ROLLBACK;
            retcode := 2;
            RETURN;
        END IF;

	call_generic_transfer (
	      p_c_unit_cd =>NULL,
	      p_n_version_number =>NULL,
	      p_c_location_cd =>NULL,
	      p_n_unit_class =>NULL,
	      p_n_usec_id =>NULL);

     ELSIF p_uoo_id IS NOT NULL AND p_usec_ID IS NULL THEN
        OPEN c_usec_param(p_uoo_id);
	FETCH c_usec_param INTO l_usec_param;
	CLOSE c_usec_param;

        l_cal_type := l_usec_param.cal_type;
        l_ci_sequence_number := l_usec_param.ci_sequence_number;

	call_generic_transfer (
	      p_c_unit_cd =>l_usec_param.unit_cd,
	      p_n_version_number =>l_usec_param.version_number,
	      p_c_location_cd =>l_usec_param.location_cd,
	      p_n_unit_class =>l_usec_param.unit_class,
	      p_n_usec_id =>NULL);


     ELSIF p_uoo_id IS NOT NULL AND p_usec_ID IS NOT NULL THEN
	OPEN c_usec_param(p_uoo_id);
	FETCH c_usec_param INTO l_usec_param;
	CLOSE c_usec_param;

        l_cal_type := l_usec_param.cal_type;
        l_ci_sequence_number := l_usec_param.ci_sequence_number;

	call_generic_transfer (
	      p_c_unit_cd =>l_usec_param.unit_cd,
	      p_n_version_number =>l_usec_param.version_number,
	      p_c_location_cd =>l_usec_param.location_cd,
	      p_n_unit_class =>l_usec_param.unit_class,
	      p_n_usec_id =>p_usec_id);

     END IF;

      -- if there exist no valid USO then transfer of data should not take place and rollback should take place for the earlier inserted records
      IF l_data_found = FALSE THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_PS_NO_DATA_TRANSFER');
	    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
	    ROLLBACK;
	    RETURN;
      END IF;

     -- Call the Hooker Procedure
     prgp_init_scheduling;


     -- End of Procedure
     retcode := 0;
     FND_MESSAGE.SET_NAME('IGS','IGS_PS_SCH_PRS_INIT_SUCCESS');
     FND_FILE.NEW_LINE(FND_FILE.LOG,1);
     FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

EXCEPTION
   WHEN OTHERS THEN
       ROLLBACK;
       retcode:=2;
       FND_FILE.PUT_LINE(FND_FILE.LOG,sqlerrm);
       ERRBUF := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION') ;
       Igs_Ge_Msg_Stack.CONC_EXCEPTION_HNDL;

END prgp_init_prs_sched;


PROCEDURE prgp_init_scheduling AS
/**********************************************************
  Created By : kmunuswa

  Date Created By : 29-AUG-2000

  Purpose : To Initiate the scheduling.

  Know limitations, enhancements or remarks

  Change History

  Who           When            What

  (reverse chronological order - newest change first)
 ***************************************************************/
BEGIN

    NULL;

END prgp_init_scheduling;

  FUNCTION prgp_get_schd_status (
  p_uoo_id IN NUMBER,
  p_usec_id IN NUMBER,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
 /**********************************************************
   Created By : Saperuma

   Date Created By : 29-AUG-2000

   Purpose : For scheduling the Unit Section occurrences

   Know limitations, enhancements or remarks

   Change History

   Who          When            What

  (reverse chronological order - newest change first)
 ***************************************************************/
  -- select the PROCSSING scheduling records for only the UOO_ID
  CURSOR c_get_schd_status_uoo IS
    SELECT 'X'
    FROM igs_ps_usec_occurs
    WHERE schedule_status='PROCESSING'
    AND UOO_ID=p_uoo_id;
  -- select the PROCSSING scheduling records for UOO_ID with UNIT_SECTION_OCCURRENCE_ID
  CURSOR c_get_schd_status_usec IS
    SELECT 'X'
    FROM igs_ps_usec_occurs
    WHERE schedule_status='PROCESSING'
    AND UOO_ID=p_uoo_id
    AND UNIT_SECTION_OCCURRENCE_ID=p_usec_id;
    l_dummy VARCHAR2(1);
  BEGIN
    -- check the uoo id
    IF p_uoo_id IS NULL THEN
     -- return the error message parameter cannot be null
      p_message_name := 'IGS_GE_PARAMETER_NOT_NULL';
      RETURN FALSE;
    ELSIF p_usec_id IS NULL THEN
    -- passing only the uoo id to check the scheduling status
      OPEN c_get_schd_status_uoo;
        FETCH c_get_schd_status_uoo INTO l_dummy;
          IF (c_get_schd_status_uoo%NOTFOUND) THEN
            CLOSE c_get_schd_status_uoo;
            p_message_name := NULL;
            RETURN FALSE;
          ELSE
            CLOSE c_get_schd_status_uoo;
            p_message_name := NULL;
            RETURN TRUE;
          END IF;
    ELSE
    -- passing uoo id,unit_section_occurence_id to check the scheduling status
      OPEN c_get_schd_status_usec;
        FETCH c_get_schd_status_usec INTO l_dummy;
          IF (c_get_schd_status_usec%NOTFOUND) THEN
            CLOSE c_get_schd_status_usec;
            p_message_name := NULL;
            RETURN FALSE;
          ELSE
            CLOSE c_get_schd_status_usec;
            p_message_name := NULL;
            RETURN TRUE;
          END IF;
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END prgp_get_schd_status;

 PROCEDURE prgp_schd_purge_data(
    errbuf  OUT NOCOPY  VARCHAR2,
    retcode OUT NOCOPY  NUMBER,
    p_teach_prd IN VARCHAR2,
    p_org_id IN NUMBER)
    AS
  /**********************************************************
    Created By : Saperuma

    Date Created By : 29-AUG-2000

    Purpose : For scheduling the Unit Section occurrences

    Know limitations, enhancements or remarks

    Change History

    Who   When      What
    jbegum      07-Apr-2003         Bug #2833850
                                Made changes to this procedure  as part of PSP Scheduling Interface Enhancements TD.
    schodava    6-Jun-2001      SI DLD
    schodava    30-Jan-2001     Modified Scheduling DLD Changes

   (reverse chronological order - newest change first)
 ***************************************************************/

  CURSOR cur_pat IS
  SELECT DISTINCT calendar_type,sequence_number
  FROM  igs_ps_sch_pat_int;

  BEGIN

    -- set the multi org id
    igs_ge_gen_003.set_org_id (p_org_id);

    IF p_teach_prd IS NOT NULL THEN
	purge_schd_record(RTRIM(SUBSTR(p_teach_prd, 101, 10)),TO_NUMBER(RTRIM(SUBSTR(p_teach_prd,112,6))));
    ELSE
      FOR cur_pat_rec IN cur_pat LOOP
	 purge_schd_record(cur_pat_rec.calendar_type,cur_pat_rec.sequence_number);
      END LOOP;
    END IF;

    retcode :=0;

  EXCEPTION
    WHEN OTHERS THEN
      retcode :=2;
      ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION') || ' : ' || SQLERRM;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
      ROLLBACK;
  END prgp_schd_purge_data;

  FUNCTION prgp_upd_usec_dtls (
  p_uoo_id IN NUMBER,
  p_location_cd IN VARCHAR2 ,
  p_usec_status IN VARCHAR2 ,
  p_max_enrollments IN NUMBER ,
  p_override_enrollment_max IN NUMBER ,
  p_enrollment_expected     IN NUMBER ,
  p_request_id OUT NOCOPY NUMBER,
  p_message_name OUT NOCOPY VARCHAR2
) RETURN BOOLEAN AS
/*************************************************************
Created By : Sreenivas.Bonam
Date Created : 2000/08/28
Purpose : To update the Scheduling Status of all unit section occurences
          belonging to the unit section passed whenever there is
          a change in a Unit Section's location/maximum enrollments/Unit Section Status
          If a Unit Section is closed then also submit a request to the scheduler to cancel
          the scheduled information for that Unit Section.
Know limitations, enhancements or remarks
Change History
Who             When                    What
  smvk          11-Mar-2003     Bug # 2831065. Modified the cursor c_usec_occurs to update schedule status of appropriate USO.
                                (i.e) Based on earlier and latest schedule status of USO.
   ssawhney                13-Nov-2000          chr(0)as the terminator in fnd_request.submit_request
(reverse chronological order - newest change first)
***************************************************************/

  CURSOR c_loc_modified_chk ( p_uoo_id IN NUMBER ) IS -- To check if location code has undergone modification
    SELECT location_cd
    FROM   igs_ps_unit_ofr_opt
    WHERE  uoo_id = p_uoo_id;

  CURSOR c_maxenrl_modified_chk ( p_uoo_id IN NUMBER ) IS -- To check if max. enrollments has undergone modification
    SELECT enrollment_maximum ,
           override_enrollment_max,
           enrollment_expected
    FROM   igs_ps_usec_lim_wlst
    WHERE  uoo_id = p_uoo_id;

  l_org_id NUMBER(15);
  lv_enrol_max c_maxenrl_modified_chk%ROWTYPE;

  -- Local procedure to update igs_ps_usec_occurs table with a given schedule status for a unit section id
  -- both of which are passed as parameters


  PROCEDURE upd_usec_occurs_schd_status ( p_uoo_id IN NUMBER, schd_stat IN VARCHAR2 ) AS

    --Bug # 2831065. Update the USO which are not in schedule status processing and input schedule status schd_stat.
    CURSOR c_usec_occurs ( p_uoo_id IN NUMBER, cp_c_schd_stat IN  igs_ps_usec_occurs.schedule_status%TYPE) IS
      SELECT ROWID, puo.*
      FROM   igs_ps_usec_occurs puo
      WHERE  uoo_id = p_uoo_id
        AND  (schedule_status IS NULL OR schedule_status <> cp_c_schd_stat)
        AND  NO_SET_DAY_IND ='N'
      FOR UPDATE NOWAIT;

    l_c_cancel igs_ps_usec_occurs_all.cancel_flag%TYPE;
    l_c_schedule_status igs_ps_usec_occurs_all.schedule_status%TYPE;

  BEGIN

    FOR c_usec_occurs_rec IN c_usec_occurs(p_uoo_id, schd_stat) LOOP

      IF schd_stat ='USER_CANCEL' THEN
         IF c_usec_occurs_rec.schedule_status = 'PROCESSING'  THEN
            l_c_schedule_status := 'PROCESSING';
         ELSE
            l_c_schedule_status := schd_stat;
         END IF;
         l_c_cancel := 'Y';
      ELSE
         l_c_schedule_status := schd_stat;
         l_c_cancel := 'N';
      END IF;

      IF schd_stat ='USER_CANCEL' OR (schd_stat ='USER_UPDATE' AND (c_usec_occurs_rec.schedule_status IS NOT NULL AND c_usec_occurs_rec.schedule_status <> 'PROCESSING')) THEN

          igs_ps_usec_occurs_pkg.update_row (
           x_rowid                             => c_usec_occurs_rec.ROWID,
           x_unit_section_occurrence_id        => c_usec_occurs_rec.unit_section_occurrence_id,
           x_uoo_id                            => c_usec_occurs_rec.uoo_id,
           x_monday                            => c_usec_occurs_rec.monday,
           x_tuesday                           => c_usec_occurs_rec.tuesday,
           x_wednesday                         => c_usec_occurs_rec.wednesday,
           x_thursday                          => c_usec_occurs_rec.thursday,
           x_friday                            => c_usec_occurs_rec.friday,
           x_saturday                          => c_usec_occurs_rec.saturday,
           x_sunday                            => c_usec_occurs_rec.sunday,
           x_start_time                        => c_usec_occurs_rec.start_time,
           x_end_time                          => c_usec_occurs_rec.end_time,
           x_building_code                     => c_usec_occurs_rec.building_code,
           x_room_code                         => c_usec_occurs_rec.room_code,
           x_schedule_status                   => l_c_schedule_status,
           x_status_last_updated               => c_usec_occurs_rec.status_last_updated,
           x_instructor_id                     => c_usec_occurs_rec.instructor_id,
           X_attribute_category                => c_usec_occurs_rec.attribute_category,
           X_attribute1                        => c_usec_occurs_rec.attribute1,
           X_attribute2                        => c_usec_occurs_rec.attribute2,
           X_attribute3                        => c_usec_occurs_rec.attribute3,
           X_attribute4                        => c_usec_occurs_rec.attribute4,
           X_attribute5                        => c_usec_occurs_rec.attribute5,
           X_attribute6                        => c_usec_occurs_rec.attribute6,
           X_attribute7                        => c_usec_occurs_rec.attribute7,
           X_attribute8                        => c_usec_occurs_rec.attribute8,
           X_attribute9                        => c_usec_occurs_rec.attribute9,
           X_attribute10                       => c_usec_occurs_rec.attribute10,
           X_attribute11                       => c_usec_occurs_rec.attribute11,
           X_attribute12                       => c_usec_occurs_rec.attribute12,
           X_attribute13                       => c_usec_occurs_rec.attribute13,
           X_attribute14                       => c_usec_occurs_rec.attribute14,
           X_attribute15                       => c_usec_occurs_rec.attribute15,
           X_attribute16                       => c_usec_occurs_rec.attribute16,
           X_attribute17                       => c_usec_occurs_rec.attribute17,
           X_attribute18                       => c_usec_occurs_rec.attribute18,
           X_attribute19                       => c_usec_occurs_rec.attribute19,
           X_attribute20                       => c_usec_occurs_rec.attribute20,
           x_error_text                        => c_usec_occurs_rec.error_text,
           x_mode                              => 'R',
           X_start_date                        => c_usec_occurs_rec.start_date,
           X_end_date                          => c_usec_occurs_rec.end_date,
           X_to_be_announced                   => c_usec_occurs_rec.to_be_announced,
           x_dedicated_building_code           => c_usec_occurs_rec.dedicated_building_code,
           x_dedicated_room_code               => c_usec_occurs_rec.dedicated_room_code,
           x_preferred_building_code           => c_usec_occurs_rec.preferred_building_code,
           x_preferred_room_code               => c_usec_occurs_rec.preferred_room_code,
           x_inst_notify_ind                   => c_usec_occurs_rec.inst_notify_ind,
           x_notify_status                     => c_usec_occurs_rec.notify_status,
           x_preferred_region_code             => c_usec_occurs_rec.preferred_region_code,
           x_no_set_day_ind                    => c_usec_occurs_rec.no_set_day_ind,
           x_cancel_flag                       => l_c_cancel,
 	   x_occurrence_identifier             => c_usec_occurs_rec.occurrence_identifier,
	   x_abort_flag                        => c_usec_occurs_rec.abort_flag
         );
       END IF;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','prgp_upd_usec_dtls:upd_usec_occurs_schd_status');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;

 END upd_usec_occurs_schd_status;

 BEGIN

   IF p_uoo_id IS NULL THEN
     p_message_name := 'IGS_GE_PARAMETER_NOT_NULL';
     RETURN FALSE;
   ELSIF (p_location_cd IS NOT NULL)                   AND
         (
          (p_usec_status IS NOT NULL)                  OR
           (
            p_max_enrollments IS NOT NULL             OR
            p_override_enrollment_max IS NOT NULL     OR
            p_enrollment_expected IS NOT NULL
           )
          )  THEN
     p_message_name := 'IGS_GE_NOT_ENGH_PARAM';
     RETURN FALSE;
   ELSIF (p_max_enrollments IS NOT NULL OR
          p_override_enrollment_max IS NOT NULL OR
          p_enrollment_expected IS NOT NULL  ) AND (p_location_cd IS NOT NULL              OR
                                                    p_usec_status IS NOT NULL
                                                   ) THEN
     p_message_name := 'IGS_PS_INVALID_PARAM';
     RETURN FALSE;
   ELSIF (p_usec_status IS NOT NULL)   AND
         (
          (p_location_cd IS NOT NULL)   OR
          (
            p_max_enrollments IS NOT NULL          OR
            p_override_enrollment_max IS NOT NULL  OR
            p_enrollment_expected     IS NOT NULL
          )
         )THEN
     p_message_name := 'IGS_GE_NOT_ENGH_PARAM';
     RETURN FALSE;

   END IF;

    -- Populate org id.
    l_org_id := igs_ge_gen_003.get_org_id;

IF p_usec_status ='CANCELLED' THEN

     upd_usec_occurs_schd_status(p_uoo_id,'USER_CANCEL');

     BEGIN

     -- Enh Bug#2833850
     -- Passing 'N' to argument6.This argument maps to the delete transaction completed record field of concurrent manager.

       p_request_id := FND_REQUEST.SUBMIT_REQUEST (
         application => 'IGS', program => 'IGSPSJ05', description => 'Initiate Scheduling of Units Section Occurrences', start_time => NULL,
         sub_request => FALSE, argument1 => NULL, argument2 => p_uoo_id, argument3 => NULL, argument4 => 'CANCEL', argument5 => l_org_id,
          argument6  => chr(0), argument7 => '', argument8 => '', argument9 => '', argument10 => '', argument11 => '', argument12 => '',
          argument13 => '', argument14 => '', argument15 => '', argument16 => '', argument17 => '', argument18 => '', argument19 => '',
          argument20 => '', argument21 => '', argument22 => '', argument23 => '', argument24 => '', argument25 => '', argument26 => '',
          argument27 => '', argument28 => '', argument29 => '', argument30 => '', argument31 => '', argument32 => '', argument33 => '',
          argument34 => '', argument35 => '', argument36 => '', argument37 => '', argument38 => '', argument39 => '', argument40 => '',
          argument41 => '', argument42 => '', argument43 => '', argument44 => '', argument45 => '', argument46 => '', argument47 => '',
          argument48 => '', argument49 => '', argument50 => '', argument51 => '', argument52 => '', argument53 => '', argument54 => '',
          argument55 => '', argument56 => '', argument57 => '', argument58 => '', argument59 => '', argument60 => '', argument61 => '',
          argument62 => '', argument63 => '', argument64 => '', argument65 => '', argument66 => '', argument67 => '', argument68 => '',
          argument69 => '', argument70 => '', argument71 => '', argument72 => '', argument73 => '', argument74 => '', argument75 => '',
          argument76 => '', argument77 => '', argument78 => '', argument79 => '', argument80 => '', argument81 => '', argument82 => '',
          argument83 => '', argument84 => '', argument85 => '', argument86 => '', argument87 => '', argument88 => '', argument89 => '',
          argument90 => '', argument91 => '', argument92 => '', argument93 => '', argument94 => '', argument95 => '', argument96 => '',
         argument97 => '', argument98 => '', argument99 => '', argument100 => '');
       IF p_request_id = 0 THEN
         FND_MESSAGE.RETRIEVE(p_message_name);
         RETURN FALSE;
       END IF;
       p_message_name := 'IGS_PS_SCST_CAN';
       RETURN TRUE;
     EXCEPTION
       WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
         FND_MESSAGE.SET_TOKEN('NAME','prgp_upd_usec_dtls');
         igs_ge_msg_stack.add;
         APP_EXCEPTION.RAISE_EXCEPTION;
     END;
     --
     -- the following code is added as part of Unit Section Enrollment Information
     -- build.
     -- the code triggers the workflow to raise business events
     --
     DECLARE
       l_message   VARCHAR2(30);
     BEGIN
       IF FND_PROFILE.VALUE('IGS_WF_ENABLE') = 'Y' THEN
          --
          -- raise business event only when workflow is installed
          --
          igs_ps_wf_event_pkg.wf_create_event(p_uoo_id      => p_uoo_id,
                                            p_usec_occur_id => NULL,
                                            p_event_type    => 'CNCL',
                                            p_message       => l_message);
          IF l_message IS NOT NULL THEN
            FND_MESSAGE.SET_NAME('IGS',l_message);
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
       END IF;
    END;
    --
    -- end of code as per theUnit Section Enrollment build
    --
ELSIF p_location_cd IS NOT NULL THEN
     DECLARE
       lv_location_cd igs_ps_unit_ofr_opt.location_cd%TYPE;
     BEGIN
       OPEN c_loc_modified_chk ( p_uoo_id );
       FETCH c_loc_modified_chk INTO lv_location_cd;
       IF nvl(p_location_cd,-999) <> nvl(lv_location_cd,-999) THEN -- Location has undergone modification
         upd_usec_occurs_schd_status(p_uoo_id,'USER_UPDATE');
       END IF;
       p_message_name := 'IGS_PS_SCST_UPD';
       RETURN TRUE;
     EXCEPTION
       WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
         FND_MESSAGE.SET_TOKEN('NAME','prgp_upd_usec_dtls');
         igs_ge_msg_stack.add;
         APP_EXCEPTION.RAISE_EXCEPTION;
     END;
 ELSIF ( p_max_enrollments IS NOT NULL or p_override_enrollment_max IS NOT NULL or  p_enrollment_expected IS NOT NULL)   THEN -- Maximum Enrollment case
        BEGIN
           OPEN c_maxenrl_modified_chk( p_uoo_id );
           FETCH c_maxenrl_modified_chk INTO lv_enrol_max;
           IF( ( nvl(lv_enrol_max.enrollment_maximum,-999) <> nvl(p_max_enrollments,-999) )
              OR
              ( nvl(lv_enrol_max.override_enrollment_max,-999) <> nvl(p_override_enrollment_max,-999) )
              OR
             ( nvl(lv_enrol_max.enrollment_expected,-999)  <> nvl(p_enrollment_expected,-999) )  ) THEN -- Max. Enrollments has undergone modification
             upd_usec_occurs_schd_status(p_uoo_id,'USER_UPDATE');
           END IF;
           p_message_name := 'IGS_PS_SCST_UPD';
           RETURN   TRUE;
           EXCEPTION
           WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
            FND_MESSAGE.SET_TOKEN('NAME','prgp_upd_usec_dtls');
            igs_ge_msg_stack.add;
            APP_EXCEPTION.RAISE_EXCEPTION;
         END;
  END IF;
           EXCEPTION
           WHEN OTHERS THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
           FND_MESSAGE.SET_TOKEN('NAME','prgp_upd_usec_dtls');
           igs_ge_msg_stack.add;
           APP_EXCEPTION.RAISE_EXCEPTION;


  END prgp_upd_usec_dtls;

PROCEDURE prgp_write_ref_file (
errbuf  OUT NOCOPY  VARCHAR2,
retcode OUT NOCOPY  NUMBER,
p_column_sep IN VARCHAR2,
p_org_id IN NUMBER ) AS
/**********************************************************
  Created By : rareddy

  Date Created By : 29-AUG-2000

  Purpose : EXporting Table Data in to Flat Files

  Know limitations, enhancements or remarks

  Change History

  Who             When      What
  sarakshi      02-Feb-2006     Bug#4960517, replaced the profile IGS_PS_EXP_DIR_PATH  to UTL_FILE_OUT
  jbegum        04-Apr-2003     As per bug#2833850 added code to export preferred region code information
                                to flat file.
  smvk          07-May-2002     Removed Hardcoded filename and filename are choosed from lookup_values to
                                overcome translation issues as per the Bug # 2401826
  smvk          09-May-2002     Created a private procedure prof_value_pres_pvt to check the value of
                                profile 'IGS_PS_EXP_DIR_PATH' is matches with the value of v$paramtere(table)
                                    whose name is 'utl_file_dir' and Output file names are modified to have
                                    request id with them as per Bug # 2343189
  (reverse chronological order - newest change first)
 ***************************************************************/

  l_message                       VARCHAR2(30);
  l_output_message                VARCHAR2(80);
  l_column_sep                    VARCHAR2(30);
  invalid                         EXCEPTION;
  valid                           EXCEPTION;
  dirnotfound                     EXCEPTION;
  l_check                         CHAR;
  l_handler_room                  UTL_FILE.FILE_TYPE ;
  l_handler_building              UTL_FILE.FILE_TYPE ;
  l_handler_location              UTL_FILE.FILE_TYPE ;
  l_handler_region                UTL_FILE.FILE_TYPE ; -- Added local variable as part of bug#2833850
  l_handler_check                 BOOLEAN;
  l_path_var                      VARCHAR2(80);
  l_req_id                          NUMBER       := FND_GLOBAL.CONC_REQUEST_ID();  -- returns the concurrent request id;
  l_prof_val_pres                 VARCHAR2(1);  -- to check profile value is present in utl_file_dir of v$parameter

  -- Cursor to get room information to be exported to flat file
  CURSOR c_room IS
    SELECT   room_id,building_id,room_cd,description,primary_use_cd,capacity,closed_ind
    FROM     igs_ad_room
    ORDER BY 1;

  -- Cursor to get building information to be exported to flat file
  CURSOR c_building IS
    SELECT   building_id,location_cd,building_cd,description,closed_ind
    FROM     igs_ad_building
    ORDER BY 1;

  -- Cursor to get location information to be exported to flat file
  CURSOR c_location IS
    SELECT   location_cd,description,location_type,mail_dlvry_wrk_days,coord_person_id,closed_ind
    FROM     igs_ad_location
    ORDER BY 1;

  -- Cursor added as part of bug#2833850
  -- Cursor to get region code information to be exported to flat file
  CURSOR c_region IS
    SELECT   lookup_code,meaning,description,tag,start_date_active,end_date_active,enabled_flag,closed_ind
    FROM     igs_lookup_values
    WHERE    lookup_type = 'IGS_OR_LOC_REGION'
    AND enabled_flag = 'Y'
    AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,TRUNC(SYSDATE))) AND TRUNC(NVL(end_date_active,TRUNC(SYSDATE)))
    ORDER BY lookup_code;

  -- cursors for getting the filenames to export data, Added as a part of Bug # 2401826

  -- Cursor to select the filename to export room information
  CURSOR c_room_fname IS
    SELECT meaning
    FROM IGS_LOOKUP_VALUES
    WHERE LOOKUP_TYPE='SCHED_EXP_FILES'  AND
          LOOKUP_CODE='IGS_PS_SCH_ROOM' ;

  -- Cursor to select the filename to export building information
  CURSOR c_building_fname IS
    SELECT meaning
    FROM IGS_LOOKUP_VALUES
    WHERE LOOKUP_TYPE='SCHED_EXP_FILES'  AND
          LOOKUP_CODE='IGS_PS_SCH_BLDG';

  -- Cursor to select the filename to export location information
  CURSOR c_location_fname IS
    SELECT meaning
    FROM IGS_LOOKUP_VALUES
    WHERE LOOKUP_TYPE='SCHED_EXP_FILES'  AND
          LOOKUP_CODE='IGS_PS_SCH_LOC';

  -- Cursor added as part of bug#2833850
  -- Cursor to select the filename to export preferred region information
  CURSOR c_reg_fname IS
    SELECT meaning
    FROM IGS_LOOKUP_VALUES
    WHERE LOOKUP_TYPE='SCHED_EXP_FILES'  AND
          LOOKUP_CODE='IGS_PS_SCH_PRF_REG';

  -- local variables to hold the export flat file name, Added as a part of Bug # 2401826

  rec_room_fname     c_room_fname%ROWTYPE;
  rec_building_fname c_building_fname%ROWTYPE;
  rec_location_fname c_location_fname%ROWTYPE;

  -- local variable added as part of bug#2833850 to hold the export flat file name for preferred region
  rec_reg_fname      c_reg_fname%ROWTYPE;

  -- Cursor added as part of bug#2833850
  CURSOR c_loc_reg_map(cp_c_loc_cd      IN igs_or_loc_region.location_cd%TYPE) IS
     SELECT region_cd
     FROM   igs_or_loc_region
     WHERE  location_cd = cp_c_loc_cd;

  procedure prof_value_pres_pvt(p_isthere OUT NOCOPY varchar2) AS
  /**********************************************************
  Created By : smvk

  Date Created By : 08-MAY-2002

  Purpose : Private procedure to check the value of profile 'IGS_PS_EXP_DIR_PATH'
            (output dir for export data file) matches with the value in v$parameter
              for the name utl_file_dir. Called within prgp_write_ref_file procedure only.

  Know limitations, enhancements or remarks

  Change History

  Who           When            What

  (reverse chronological order - newest change first)
 ***************************************************************/

  l_start_str_index     NUMBER := 1;
  l_end_comma_index     NUMBER := 1;
  l_start_comma_index   NUMBER := 1;
  l_dbvalue             V$PARAMETER.VALUE%TYPE;
  l_temp                V$PARAMETER.VALUE%TYPE;
  l_fndvalue            VARCHAR2(80);

  CURSOR c_value IS
      SELECT VALUE
      FROM V$PARAMETER
      WHERE NAME='utl_file_dir';

  BEGIN
      p_isthere  := 'N';
      l_fndvalue := LTRIM(RTRIM(FND_PROFILE.VALUE('UTL_FILE_OUT')));
      OPEN c_value ;
      FETCH c_value INTO l_dbvalue ;
      IF c_value%FOUND AND l_dbvalue IS NOT NULL THEN
          l_dbvalue:= LTRIM(RTRIM(l_dbvalue));
          LOOP
              SELECT INSTR(l_dbvalue,l_fndvalue,l_end_comma_index) INTO l_start_str_index FROM DUAL;
              IF l_start_str_index = 0  THEN
                 p_isthere  := 'N';
                 return;
              END IF;
                  SELECT INSTR(SUBSTR(l_dbvalue,1,l_start_str_index),',',-1)+1
                  INTO l_start_comma_index
                  FROM DUAL;
                  SELECT DECODE(
                                INSTR(l_dbvalue,',',l_start_str_index),0,LENGTH(l_dbvalue)+1,
                                INSTR(l_dbvalue,',',l_start_str_index))
                  INTO l_end_comma_index
                  FROM DUAL;
                  SELECT LTRIM(RTRIM(SUBSTR(l_dbvalue,l_start_comma_index, l_end_comma_index-l_start_comma_index)))
                  INTO l_temp
                  FROM DUAL;
              IF l_temp = l_fndvalue THEN
                  p_isthere := 'Y';
                  return;
              END IF;
           END LOOP;
      ELSE
          p_isthere  :='N';
      END IF;
      CLOSE c_value;
  END prof_value_pres_pvt;

BEGIN
   --adding the following code to overcome file.sql.35 warning.
   l_path_var      := FND_PROFILE.VALUE('UTL_FILE_OUT');
   l_prof_val_pres := 'N';  -- to check profile value is present in utl_file_dir of v$parameter

    -- set the multi org id
    igs_ge_gen_003.set_org_id (p_org_id);


    l_message       := NULL;
    retcode         := 0;
    l_column_sep    := NVL(p_column_sep,'###');

    IF (l_path_var IS NULL) THEN
       l_message  :='IGS_GE_DIR_PRF_NOT_SET';
       RAISE invalid;
    END IF;

  -- calling private procedure
  -- to check the value present in profile matches with that value of utl_file_dir in v$parameter
    prof_value_pres_pvt(l_prof_val_pres);
    IF l_prof_val_pres = 'N'  THEN
       l_message  :='IGS_PS_OUT_DIR_NOT_FOUND';
       RAISE dirnotfound;
    END IF;

    -- code added to get the filenames to export data, Added as a part of Bug # 2401826

    OPEN c_room_fname;
    FETCH c_room_fname INTO rec_room_fname;

    OPEN c_building_fname ;
    FETCH c_building_fname INTO rec_building_fname;

    OPEN c_location_fname;
    FETCH c_location_fname INTO rec_location_fname;

    CLOSE c_room_fname;
    CLOSE c_building_fname;
    CLOSE c_location_fname;

    -- Added code as part of bug#2833850 to get flat filename to export preferred region information
    OPEN c_reg_fname;
    FETCH c_reg_fname INTO rec_reg_fname;
    CLOSE c_reg_fname;


    -- WRITING from TABLES

    BEGIN
        l_handler_room   := UTL_FILE.FOPEN(l_path_var, LTRIM(RTRIM(rec_room_fname.meaning)) || l_req_id, 'w');
        l_handler_check  := UTL_FILE.IS_OPEN(l_handler_room);
        IF (l_handler_check = FALSE ) THEN
            RAISE invalid;
        END IF;
    EXCEPTION
       WHEN OTHERS THEN
           l_message  :='IGS_GE_DIR_FOPEN_ERR';
           RAISE invalid;
    END;

    FOR cur_temp IN c_room LOOP
        UTL_FILE.PUT_LINE(l_handler_room, cur_temp.room_id|| l_column_sep ||
        cur_temp.building_id|| l_column_sep ||cur_temp.room_cd|| l_column_sep ||
        cur_temp.description|| l_column_sep ||cur_temp.primary_use_cd||
        l_column_sep ||cur_temp.capacity|| l_column_sep ||cur_temp.closed_ind);
    END LOOP;
    UTL_FILE.FCLOSE(l_handler_room);

    BEGIN
       l_handler_building := UTL_FILE.FOPEN(l_path_var, LTRIM(RTRIM(rec_building_fname.meaning)) || l_req_id, 'w');
       l_handler_check    := UTL_FILE.IS_OPEN(l_handler_building);
       IF (l_handler_check = FALSE ) THEN
            RAISE invalid;
       END IF;
    EXCEPTION
       WHEN OTHERS THEN
           l_message  :='IGS_GE_DIR_FOPEN_ERR';
           RAISE invalid;
    END;

    FOR cur_temp IN c_building LOOP
       UTL_FILE.PUT_LINE(l_handler_building, cur_temp.building_id|| l_column_sep ||
       cur_temp.location_cd|| l_column_sep ||cur_temp.building_cd|| l_column_sep ||
       cur_temp.description|| l_column_sep ||cur_temp.closed_ind);
    END LOOP;
    UTL_FILE.FCLOSE(l_handler_building);

    BEGIN
         l_handler_location := UTL_FILE.FOPEN(l_path_var, LTRIM(RTRIM(rec_location_fname.meaning))|| l_req_id, 'w');
         l_handler_check    := UTL_FILE.IS_OPEN(l_handler_location);
         IF (l_handler_check = FALSE ) THEN
             RAISE invalid;
         END IF;
    EXCEPTION
        WHEN OTHERS THEN
            l_message  :='IGS_GE_DIR_FOPEN_ERR';
            RAISE invalid;
    END;

    -- As part of bug#2833850 added the cursor FOR loop cur_map
    -- This was done to modify the location flat file structure , so that it would show the region codes
    -- attached to a location code

    FOR cur_temp IN c_location LOOP
        UTL_FILE.PUT(l_handler_location,cur_temp.location_cd|| l_column_sep ||
        cur_temp.description|| l_column_sep ||cur_temp.location_type || l_column_sep ||
        cur_temp.mail_dlvry_wrk_days|| l_column_sep ||cur_temp.coord_person_id
        || l_column_sep ||cur_temp.closed_ind);
        FOR cur_map IN c_loc_reg_map(cur_temp.location_cd) LOOP
             UTL_FILE.PUT(l_handler_location,l_column_sep ||cur_map.region_cd);
        END LOOP;
        UTL_FILE.NEW_LINE(l_handler_location,1);
    END LOOP;

    UTL_FILE.FCLOSE(l_handler_location);


    -- Added following code as part of bug#2833850 to write preferred region information to the flat file

    BEGIN
         l_handler_region := UTL_FILE.FOPEN(l_path_var, LTRIM(RTRIM(rec_reg_fname.meaning))|| l_req_id, 'w');
         l_handler_check  := UTL_FILE.IS_OPEN(l_handler_region);
         IF (l_handler_check = FALSE ) THEN
             RAISE invalid;
         END IF;
    EXCEPTION
        WHEN OTHERS THEN
            l_message  :='IGS_GE_DIR_FOPEN_ERR';
            RAISE invalid;
    END;

    FOR cur_temp IN c_region LOOP
        UTL_FILE.PUT_LINE(l_handler_region, cur_temp.lookup_code|| l_column_sep ||
        cur_temp.meaning|| l_column_sep ||cur_temp.description|| l_column_sep ||
        cur_temp.tag|| l_column_sep ||cur_temp.start_date_active|| l_column_sep ||
        cur_temp.end_date_active|| l_column_sep ||cur_temp.enabled_flag|| l_column_sep ||cur_temp.closed_ind);
    END LOOP;

    UTL_FILE.FCLOSE(l_handler_region);

    l_message  :='IGS_PS_SCH_EXP_SUCCESS';
    RAISE valid;

EXCEPTION

  WHEN VALID THEN
    retcode:=0;
    errbuf:=FND_MESSAGE.GET_STRING('IGS',l_message);
  WHEN INVALID THEN
    retcode:=2;
    errbuf :=FND_MESSAGE.GET_STRING('IGS',l_message);
  WHEN dirnotfound THEN
    retcode:=2;
    errbuf :=FND_MESSAGE.GET_STRING('IGS',l_message);
  WHEN OTHERS THEN
    retcode:=2;
    errbuf:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

END prgp_write_ref_file;

PROCEDURE prgp_get_schd_records(
  errbuf  OUT NOCOPY  varchar2,
  retcode OUT NOCOPY  number ,
  p_org_id IN NUMBER
  ) AS
  /**********************************************************
  Created By : John Victor Deekollu

  Date Created By : 29-AUG-2000

  Purpose : Gets the Scheduled Records from Interface Table

  Know limitations, enhancements or remarks

  Change History

  Who           When            What
  sommukhe      27-APR-2006     Bug#5122473,Modified the cursor check_ovrd and the code respectively to include Date override check so that the Get Scheduled interface job considers Date Occurrence Override during import.
  sarakshi      12-Jan-2006     bug#4926548, replaced the cursor c_table with the pl-sql table . Also Modified cursor c_ipsuo and c_print_uso such that it uses its base table.
  sarakshi      16-Feb-2004     Bug#3431844, added owner filter in the cursor c_table and modified its usage accordingly
  smvk          29-Jun-2003     Bug # 3060089. Modified the procedure update_info to display the message 'IGS_PS_SCH_TBA_USO_NSD_USEC'.
  smvk          13-May-2003     Created a local procedures update_info and local function get_location_description for code optimization
                                and coded the validation mentioned PSP Scheduling inteface enhancements TD.Enh Bug #2833850.
  smvk          26-Jun-2002     In interface table, when there is no unit section occurrence exist in valid state
                                to populate in production table, proper message should log in the log file.
                                as per the Bug # 2427725
  schodava      30-Jan-2001     Modified Scheduling DLD Changes
  bayadav       28-May-2001     SCheduling Interface DLD Changes
  smvk          31-Dec-2002     Bug # 2710978. Collecting the statistics of the interface table as per standards.
  (reverse chronological order - newest change first)
  ***************************************************************/

  l_originator                  igs_ps_sch_hdr_int.originator%TYPE;
  l_status                      igs_ps_usec_occurs.schedule_status%TYPE;
  l_unit_section_occurrence_id  igs_ps_usec_occurs.unit_section_occurrence_id%TYPE;
  l_schedule_status             igs_ps_usec_occurs.schedule_status%TYPE;
  l_inter_error_text            igs_ps_usec_occurs.error_text%TYPE;
  l_transaction_type            igs_ps_sch_int.transaction_type%TYPE;
  l_building_code               igs_ps_usec_occurs.building_code%TYPE;
  l_room_code                   igs_ps_usec_occurs.room_code%TYPE;
  l_start_time                  igs_ps_usec_occurs.start_time%TYPE;
  l_end_time                    igs_ps_usec_occurs.end_time%TYPE;
  l_error_text                  igs_ps_usec_occurs.error_text%TYPE;
  l_trans_id                    igs_ps_sch_usec_int_all.transaction_id%TYPE;
  --Added By Bayadav as a part of Nov,2001 SI Build
  l_monday                      igs_ps_usec_occurs.monday%TYPE;
  l_tuesday                     igs_ps_usec_occurs.tuesday%TYPE;
  l_wednesday                   igs_ps_usec_occurs.wednesday%TYPE;
  l_thursday                    igs_ps_usec_occurs.thursday%TYPE;
  l_friday                      igs_ps_usec_occurs.friday%TYPE;
  l_saturday                    igs_ps_usec_occurs.saturday%TYPE;
  l_sunday                      igs_ps_usec_occurs.sunday%TYPE;
  l_set_scheduled_status        igs_ps_sch_int_all.schedule_status%TYPE;
  l_set_transaction_type        igs_ps_sch_int_all.transaction_type%TYPE;
  l_tba_status                  igs_ps_sch_int_all.tba_status%TYPE;
  l_d_uso_start_date            igs_ps_sch_int_all.unit_section_start_date%TYPE; -- Added as a part of Enh Bug #2833850
  l_d_uso_end_date              igs_ps_sch_int_all.unit_section_end_date%TYPE;   -- Added as a part of Enh Bug #2833850
  l_c_t_cal_type                igs_ca_inst_all.cal_type%TYPE;
  l_n_t_seq_num                 igs_ca_inst_all.sequence_number%TYPE;
  l_n_t_uoo_id                  igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
  l_b_print_cal                 BOOLEAN;
  l_b_print_uoo                 BOOLEAN;

  -- is there any schduled records exists needs to be transfer to production table as per the Bug # 2427725
  l_valid_rec_for_prod          BOOLEAN := FALSE;

  CURSOR c_get_usec_inter IS
    SELECT sui.*
    FROM   igs_ps_sch_usec_int_all sui
    WHERE  sui.import_done_flag = 'N'
    FOR UPDATE NOWAIT
    ORDER BY sui.calendar_type, sui.sequence_number, sui.uoo_id;

  CURSOR c_get_records_inter(cp_int_usec_id IN NUMBER) IS
    SELECT ipsi.rowid,ipsi.*
    FROM igs_ps_sch_int_all ipsi, igs_ps_usec_occurs_all uso
    WHERE ipsi.transaction_type IN ('REQUEST','UPDATE','CANCEL') AND ipsi.schedule_status IN ('OK','ERROR')
    AND   ipsi.unit_section_occurrence_id=uso.unit_section_occurrence_id
    AND   uso.schedule_status <> 'CANCELLED'
    AND   uso.abort_flag = 'N'
    AND   ipsi.import_done_flag = 'N'
    AND   ipsi.int_usec_id = cp_int_usec_id
    FOR UPDATE NOWAIT;

  CURSOR c_get_originator(p_transaction_id NUMBER) IS
    SELECT originator
    FROM igs_ps_sch_hdr_int_ALL
    WHERE transaction_id=p_transaction_id;

  CURSOR c_ipsuo(p_usec_id NUMBER) IS
    SELECT *
    FROM igs_ps_usec_occurs_all ipsuo
    WHERE unit_section_occurrence_id=p_usec_id
    FOR UPDATE NOWAIT;


  TYPE tabnames IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  tablenames_tbl tabnames;

  l_ipsuo                       c_ipsuo%ROWTYPE;
  l_c_status                    VARCHAR2(1);
  l_c_industry                  VARCHAR2(1);
  l_c_schema                    VARCHAR2(30);
  l_b_return                    BOOLEAN;

  CURSOR c_date (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
    SELECT a.unit_section_start_date us_start_date,
           a.unit_section_end_date us_end_date,
           b.start_dt tp_start_date,
           b.end_dt tp_end_date
    FROM   igs_ps_unit_ofr_opt_all a,
           igs_ca_inst_all b
    WHERE  a.uoo_id = cp_n_uoo_id
    AND    a.cal_type = b.cal_type
    AND    a.ci_sequence_number = b.sequence_number;

  CURSOR c_bldg_exists (cp_n_building_id igs_ad_building_all.building_id%TYPE) IS
    SELECT 'x'
    FROM    igs_ad_building_all
    WHERE   building_id = cp_n_building_id
    AND     ROWNUM < 2 ;

  CURSOR c_room_exists (cp_n_room_id igs_ad_room_all.room_id%TYPE) IS
    SELECT 'x'
    FROM    igs_ad_room_all
    WHERE   room_id = cp_n_room_id
    AND     ROWNUM < 2 ;

  CURSOR c_bldg_room_exists (cp_n_building_id igs_ad_building_all.building_id%TYPE,
                             cp_n_room_id igs_ad_room_all.room_id%TYPE) IS
    SELECT 'x'
    FROM   igs_ad_room_all
    WHERE  building_id = cp_n_building_id
    AND    room_id = cp_n_room_id
    AND    ROWNUM < 2 ;

  l_c_exists  VARCHAR2(1);
  rec_date c_date%ROWTYPE;


  CURSOR check_ovrd IS
  SELECT day_ovrd_flag, time_ovrd_flag, scheduled_bld_ovrd_flag, scheduled_room_ovrd_flag,date_ovrd_flag
  FROM igs_ps_sch_ocr_cfig;

  l_check_ovrd check_ovrd%ROWTYPE;


    PROCEDURE update_info( p_n_prd_uso_id   igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE,
                           p_n_int_uso_id   igs_ps_sch_int_all.unit_section_occurrence_id%TYPE,
                           p_c_sch_status   igs_ps_usec_occurs_all.schedule_status%TYPE,
                           p_c_trans_type   igs_ps_sch_int_all.transaction_type%TYPE,
                           p_n_bldg_cd      igs_ps_usec_occurs_all.building_code%TYPE,
                           p_n_room_cd      igs_ps_usec_occurs_all.room_code%TYPE,
                           p_d_uso_start_dt igs_ps_usec_occurs_all.start_date%TYPE,
                           p_d_uso_end_dt   igs_ps_usec_occurs_all.end_date%TYPE,
                           p_d_uso_start_tm igs_ps_usec_occurs_all.start_time%TYPE,
                           p_d_uso_end_tm   igs_ps_usec_occurs_all.end_time%TYPE,
                           p_c_sunday       igs_ps_usec_occurs_all.sunday%TYPE,
                           p_c_monday       igs_ps_usec_occurs_all.monday%TYPE,
                           p_c_tuesday      igs_ps_usec_occurs_all.tuesday%TYPE,
                           p_c_wednesday    igs_ps_usec_occurs_all.wednesday%TYPE,
                           p_c_thursday     igs_ps_usec_occurs_all.thursday%TYPE,
                           p_c_friday       igs_ps_usec_occurs_all.friday%TYPE,
                           p_c_saturday     igs_ps_usec_occurs_all.saturday%TYPE,
                           p_c_tba_uso      igs_ps_usec_occurs_all.to_be_announced%TYPE,
                           p_c_err_text     igs_ps_usec_occurs_all.error_text%TYPE
                           ) AS
      CURSOR c_prd_uso(cp_n_uso_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
        SELECT rowid,uso.*
        FROM   igs_ps_usec_occurs_all uso
        WHERE  uso.unit_section_occurrence_id=cp_n_uso_id;

      CURSOR c_int_uso (cp_n_uso_id igs_ps_sch_int_all.int_occurs_id%TYPE) IS
        SELECT uso.rowid, uso.*, usec.int_pat_id
        FROM   igs_ps_sch_int_all uso, igs_ps_sch_usec_int_all usec
	WHERE uso.int_usec_id = usec.int_usec_id
	AND   uso.int_occurs_id = cp_n_uso_id;

      CURSOR c_print_uso(cp_n_uso_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
        SELECT *
        FROM   igs_ps_usec_occurs_all
        WHERE  unit_section_occurrence_id=cp_n_uso_id;

      -- Bug #3060089. Cursor to check the unit section is non standard unit section or not.
      CURSOR c_nstd_us (cp_n_uso_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
        SELECT 'x'
        FROM   igs_ps_usec_occurs_all uso,
               igs_ps_unit_ofr_opt_all uoo
        WHERE  uoo.non_std_usec_ind = 'Y'
          AND  uoo.uoo_id = uso.uoo_id
          AND  uso.unit_section_occurrence_id=cp_n_uso_id;

      rec_prd_uso    c_prd_uso%ROWTYPE;
      rec_int_uso    c_int_uso%ROWTYPE;
      rec_print_uso  c_print_uso%ROWTYPE;
      l_c_prf_reg    igs_ps_usec_occurs_all.preferred_region_code%TYPE;
      l_n_prf_bld    igs_ps_usec_occurs_all.preferred_building_code%TYPE;
      l_n_prf_rom    igs_ps_usec_occurs_all.preferred_room_code%TYPE;
      l_n_ded_bld    igs_ps_usec_occurs_all.dedicated_building_code%TYPE;
      l_n_ded_rom    igs_ps_usec_occurs_all.dedicated_room_code%TYPE;
      l_c_sch_status igs_ps_usec_occurs_all.schedule_status%TYPE;
      l_c_trans_type igs_ps_sch_int_all.transaction_type%TYPE;
      l_c_err_text   igs_ps_usec_occurs_all.error_text%TYPE;
      l_c_exists     VARCHAR2(1);

      /*CURSOR check_ovrd IS
      SELECT day_ovrd_flag, time_ovrd_flag, scheduled_bld_ovrd_flag, scheduled_room_ovrd_flag
      FROM igs_ps_sch_ocr_cfig;

      l_check_ovrd check_ovrd%ROWTYPE;
      l_c_monday     igs_ps_usec_occurs_all.monday%TYPE;
      l_c_tuesday    igs_ps_usec_occurs_all.tuesday%TYPE;
      l_c_wednesday  igs_ps_usec_occurs_all.wednesday%TYPE;
      l_c_thursday   igs_ps_usec_occurs_all.thursday%TYPE;
      l_c_friday     igs_ps_usec_occurs_all.friday%TYPE;
      l_c_saturday   igs_ps_usec_occurs_all.saturday%TYPE;
      l_c_sunday     igs_ps_usec_occurs_all.sunday%TYPE;
      l_start_time   igs_ps_usec_occurs_all.start_time%TYPE;
      l_end_time     igs_ps_usec_occurs_all.end_time%TYPE;
      l_sch_bld      igs_ps_usec_occurs_all.building_code%TYPE;
      l_sch_room     igs_ps_usec_occurs_all.room_code%TYPE;*/
      l_import_done  VARCHAR2(1);

      CURSOR cur_section_import(cp_int_usec_id IN NUMBER) IS
      SELECT 'X'
      FROM   igs_ps_sch_int_all
      WHERE  int_usec_id=cp_int_usec_id
      AND    import_done_flag='N';

      CURSOR cur_pattern_import(cp_int_pat_id IN NUMBER) IS
      SELECT 'X'
      FROM   igs_ps_sch_usec_int_all
      WHERE  int_pat_id=cp_int_pat_id
      AND    import_done_flag='N';
      l_c_var VARCHAR2(1);

    BEGIN

      OPEN  c_prd_uso (p_n_prd_uso_id);
      FETCH c_prd_uso INTO rec_prd_uso;
      CLOSE c_prd_uso;

      OPEN  c_int_uso (p_n_int_uso_id);
      FETCH c_int_uso INTO rec_int_uso;
      CLOSE c_int_uso;

      -- if the unit section occurrece is succesfully scheduled (i.e schedule_status = 'SCHEDULED')
      -- then clear the scheduling preferences such as preferred region, preferred / dedicated building/room.
      IF p_c_sch_status <> 'SCHEDULED' THEN
         l_c_prf_reg := rec_prd_uso.preferred_region_code;
         l_n_prf_bld := rec_prd_uso.preferred_building_code;
         l_n_prf_rom := rec_prd_uso.preferred_room_code;
         l_n_ded_bld := rec_prd_uso.dedicated_building_code;
         l_n_ded_rom := rec_prd_uso.dedicated_room_code;
      END IF;

      BEGIN

         /*OPEN check_ovrd;
	 FETCH check_ovrd INTO l_check_ovrd;
	 IF check_ovrd%FOUND THEN
	   --Days override
	   IF l_check_ovrd.day_ovrd_flag = 'N' AND (rec_prd_uso.monday='Y' OR
	                                             rec_prd_uso.tuesday='Y' OR
						     rec_prd_uso.wednesday='Y' OR
						     rec_prd_uso.thursday='Y' OR
						     rec_prd_uso.friday='Y' OR
						     rec_prd_uso.saturday='Y' OR
						     rec_prd_uso.sunday='Y'  ) THEN
             l_c_monday := rec_prd_uso.monday;
             l_c_tuesday := rec_prd_uso.tuesday;
             l_c_wednesday := rec_prd_uso.wednesday;
             l_c_thursday := rec_prd_uso.thursday;
	     l_c_friday := rec_prd_uso.friday;
             l_c_saturday := rec_prd_uso.saturday;
             l_c_sunday := rec_prd_uso.sunday;
           ELSE
             l_c_monday := p_c_monday;
             l_c_tuesday := p_c_tuesday;
             l_c_wednesday := p_c_wednesday;
             l_c_thursday := p_c_thursday;
	     l_c_friday := p_c_friday;
             l_c_saturday := p_c_saturday;
             l_c_sunday := p_c_sunday;
           END IF;
	   --Time override
	   IF l_check_ovrd.time_ovrd_flag = 'N' AND (rec_prd_uso.start_time IS NOT NULL  OR
                                                rec_prd_uso.end_time IS NOT NULL ) THEN
             l_start_time := rec_prd_uso.start_time;
             l_end_time := rec_prd_uso.end_time;
           ELSE
             l_start_time := p_d_uso_start_tm;
             l_end_time := p_d_uso_end_tm;
	   END IF;
           --Schedule Building override
	   IF l_check_ovrd.scheduled_bld_ovrd_flag = 'N' AND (rec_prd_uso.building_code IS NOT NULL) THEN
             l_sch_bld := rec_prd_uso.building_code;
           ELSE
             l_sch_bld := l_building_code;
	   END IF;
           --Schedule Room override
	   IF l_check_ovrd.scheduled_room_ovrd_flag = 'N' AND (rec_prd_uso.room_code IS NOT NULL ) THEN
             l_sch_room := rec_prd_uso.room_code;
           ELSE
             l_sch_room := l_room_code;
	   END IF;

         ELSE
             l_c_monday := p_c_monday;
             l_c_tuesday := p_c_tuesday;
             l_c_wednesday := p_c_wednesday;
             l_c_thursday := p_c_thursday;
	     l_c_friday := p_c_friday;
             l_c_saturday := p_c_saturday;
             l_c_sunday := p_c_sunday;
             l_start_time := p_d_uso_start_tm;
             l_end_time := p_d_uso_end_tm;
	     l_sch_bld := l_building_code;
	     l_sch_room := l_room_code;
	 END IF;
         CLOSE check_ovrd;*/

         -- Update production table with scheduling details(i.e building/room code and schedule status)
         igs_ps_usec_occurs_pkg.update_row
         (
            X_Mode                              => 'R',
            X_RowId                             => rec_prd_uso.rowid ,
            X_unit_section_occurrence_id        => rec_prd_uso.unit_section_occurrence_id,
            X_uoo_id                            => rec_prd_uso.uoo_id,
            X_monday                            => p_c_monday,
            X_tuesday                           => p_c_tuesday,
            X_wednesday                         => p_c_wednesday,
            X_thursday                          => p_c_thursday,
            X_friday                            => p_c_friday,
            X_saturday                          => p_c_saturday,
            X_sunday                            => p_c_sunday,
            X_start_time                        => p_d_uso_start_tm,
            X_end_time                          => p_d_uso_end_tm,
            X_building_code                     => l_building_code,
            X_room_code                         => l_room_code,
            X_schedule_status                   => p_c_sch_status,
            X_status_last_updated               => sysdate,
            X_instructor_id                     => rec_prd_uso.instructor_id,
            X_attribute_category                => rec_prd_uso.attribute_category,
            X_attribute1                        => rec_prd_uso.attribute1,
            X_attribute2                        => rec_prd_uso.attribute2,
            X_attribute3                        => rec_prd_uso.attribute3,
            X_attribute4                        => rec_prd_uso.attribute4,
            X_attribute5                        => rec_prd_uso.attribute5,
            X_attribute6                        => rec_prd_uso.attribute6,
            X_attribute7                        => rec_prd_uso.attribute7,
            X_attribute8                        => rec_prd_uso.attribute8,
            X_attribute9                        => rec_prd_uso.attribute9,
            X_attribute10                       => rec_prd_uso.attribute10,
            X_attribute11                       => rec_prd_uso.attribute11,
            X_attribute12                       => rec_prd_uso.attribute12,
            X_attribute13                       => rec_prd_uso.attribute13,
            X_attribute14                       => rec_prd_uso.attribute14,
            X_attribute15                       => rec_prd_uso.attribute15,
            X_attribute16                       => rec_prd_uso.attribute16,
            X_attribute17                       => rec_prd_uso.attribute17,
            X_attribute18                       => rec_prd_uso.attribute18,
            X_attribute19                       => rec_prd_uso.attribute19,
            X_attribute20                       => rec_prd_uso.attribute20,
            X_error_text                        => p_c_err_text,
            X_start_date                        => p_d_uso_start_dt,
            X_end_date                          => p_d_uso_end_dt,
            X_to_be_Announced                   => p_c_tba_uso,
            X_dedicated_building_code           => l_n_ded_bld,
            X_dedicated_room_code               => l_n_ded_rom,
            X_preferred_building_code           => l_n_prf_bld,
            X_preferred_room_code               => l_n_prf_rom,
            X_inst_notify_ind                   => rec_prd_uso.inst_notify_ind,
            X_notify_status                     => rec_prd_uso.notify_status,
            x_preferred_region_code             => l_c_prf_reg,
            x_no_set_day_ind                    => rec_prd_uso.no_set_day_ind,
            x_cancel_flag                       => rec_prd_uso.cancel_flag,
 	    x_occurrence_identifier             => rec_prd_uso.occurrence_identifier,
	    x_abort_flag                        => rec_prd_uso.abort_flag
         );

         IF p_c_trans_type ='COMPLETE' THEN
 	   l_import_done:= 'Y';
         ELSE
	   l_import_done:= 'N';
         END IF;
         -- Update interface Occurrence table
         UPDATE igs_ps_sch_int_all set transaction_type=p_c_trans_type,schedule_status=p_c_sch_status,error_text=p_c_err_text,
         import_done_flag=l_import_done WHERE int_occurs_id = p_n_int_uso_id;


	 IF l_import_done = 'Y' THEN
  	   --Update the interface section import_done_flag
	   OPEN cur_section_import(rec_int_uso.int_usec_id);
	   FETCH cur_section_import INTO l_c_var;
	   IF cur_section_import%NOTFOUND  THEN
             UPDATE igs_ps_sch_usec_int_all set import_done_flag='Y' WHERE int_usec_id = rec_int_uso.int_usec_id;
           END IF;
	   CLOSE cur_section_import;

           --Update the interface pattern import_done_flag
	   OPEN cur_pattern_import(rec_int_uso.int_pat_id);
	   FETCH cur_pattern_import INTO l_c_var;
	   IF cur_pattern_import%NOTFOUND  THEN
             UPDATE igs_ps_sch_pat_int set import_done_flag='Y' WHERE int_pat_id = rec_int_uso.int_pat_id;
           END IF;
	   CLOSE cur_pattern_import;
	 END IF;


         OPEN  c_print_uso (p_n_prd_uso_id);
         FETCH c_print_uso INTO rec_print_uso;
         CLOSE c_print_uso;
         log_usec_occurs (p_c_trans_type, rec_int_uso.instructor_id, rec_print_uso,'G');
         IF rec_prd_uso.to_be_announced = 'Y' AND p_c_sch_status = 'SCHEDULED' THEN
            OPEN c_nstd_us(p_n_prd_uso_id);
            FETCH c_nstd_us INTO l_c_exists;
            IF c_nstd_us%FOUND THEN
               fnd_message.set_name('IGS','IGS_PS_SCH_TBA_USO_NSD_USEC');
               fnd_file.put_line(fnd_file.LOG,'                    ' ||fnd_message.get);
            END IF;
            CLOSE c_nstd_us;
         END IF;

       EXCEPTION
         WHEN OTHERS THEN
           l_c_sch_status := 'ERROR' ;
           l_c_trans_type := 'INCOMPLETE';
           l_c_err_text:=fnd_message.get || sqlerrm;
           -- Update production table with exception error(i.e. error text and schedule status)
           igs_ps_usec_occurs_pkg.update_row
           (
              X_Mode                              => 'R',
              X_RowId                             => rec_prd_uso.rowid ,
              X_unit_section_occurrence_id        => rec_prd_uso.unit_section_occurrence_id,
              X_uoo_id                            => rec_prd_uso.uoo_id,
              X_monday                            => rec_prd_uso.monday,
              X_tuesday                           => rec_prd_uso.tuesday,
              X_wednesday                         => rec_prd_uso.wednesday,
              X_thursday                          => rec_prd_uso.thursday,
              X_friday                            => rec_prd_uso.friday,
              X_saturday                          => rec_prd_uso.saturday,
              X_sunday                            => rec_prd_uso.sunday,
              X_start_time                        => rec_prd_uso.start_time,
              X_end_time                          => rec_prd_uso.end_time,
              X_building_code                     => rec_prd_uso.building_code,
              X_room_code                         => rec_prd_uso.room_code,
              X_schedule_status                   => l_c_sch_status,
              X_status_last_updated               => sysdate,
              X_instructor_id                     => rec_prd_uso.instructor_id,
              X_attribute_category                => rec_prd_uso.attribute_category,
              X_attribute1                        => rec_prd_uso.attribute1,
              X_attribute2                        => rec_prd_uso.attribute2,
              X_attribute3                        => rec_prd_uso.attribute3,
              X_attribute4                        => rec_prd_uso.attribute4,
              X_attribute5                        => rec_prd_uso.attribute5,
              X_attribute6                        => rec_prd_uso.attribute6,
              X_attribute7                        => rec_prd_uso.attribute7,
              X_attribute8                        => rec_prd_uso.attribute8,
              X_attribute9                        => rec_prd_uso.attribute9,
              X_attribute10                       => rec_prd_uso.attribute10,
              X_attribute11                       => rec_prd_uso.attribute11,
              X_attribute12                       => rec_prd_uso.attribute12,
              X_attribute13                       => rec_prd_uso.attribute13,
              X_attribute14                       => rec_prd_uso.attribute14,
              X_attribute15                       => rec_prd_uso.attribute15,
              X_attribute16                       => rec_prd_uso.attribute16,
              X_attribute17                       => rec_prd_uso.attribute17,
              X_attribute18                       => rec_prd_uso.attribute18,
              X_attribute19                       => rec_prd_uso.attribute19,
              X_attribute20                       => rec_prd_uso.attribute20,
              X_error_text                        => l_c_err_text,
              X_start_date                        => rec_prd_uso.start_date,
              X_end_date                          => rec_prd_uso.end_date,
              X_to_be_Announced                   => rec_prd_uso.to_be_announced,
              X_dedicated_building_code           => rec_prd_uso.dedicated_building_code,
              X_dedicated_room_code               => rec_prd_uso.dedicated_room_code,
              X_preferred_building_code           => rec_prd_uso.preferred_building_code,
              X_preferred_room_code               => rec_prd_uso.preferred_room_code,
              X_inst_notify_ind                   => rec_prd_uso.inst_notify_ind,
              X_notify_status                     => rec_prd_uso.notify_status,
              x_preferred_region_code             => rec_prd_uso.preferred_region_code,
              x_no_set_day_ind                    => rec_prd_uso.no_set_day_ind,
              x_cancel_flag                       => rec_prd_uso.cancel_flag,
 	      x_occurrence_identifier             => rec_prd_uso.occurrence_identifier,
	      x_abort_flag                        => rec_prd_uso.abort_flag
           );

           -- Update interface Occurrence table
   	   -- Update interface table (i.e. Transaction Type) by transaction status as 'INCOMPLETE' and Schedule status as 'ERROR'
           UPDATE igs_ps_sch_int_all set transaction_type=l_c_trans_type,schedule_status=l_c_sch_status,error_text=l_c_err_text
           WHERE int_occurs_id = p_n_int_uso_id;

           OPEN  c_print_uso (p_n_prd_uso_id);
           FETCH c_print_uso INTO rec_print_uso;
           CLOSE c_print_uso;
           log_usec_occurs (l_c_trans_type, rec_int_uso.instructor_id, rec_print_uso,'G');
      END;

    END update_info;
    FUNCTION get_location_description(p_location_cd igs_ad_location_all.location_cd%TYPE) RETURN VARCHAR2 AS
       CURSOR c_desc(cp_c_location_cd IN igs_ad_location_all.location_cd%TYPE) IS
         SELECT description
         FROM   igs_ad_location_all
         WHERE  location_cd = cp_c_location_cd;
         l_c_description igs_ad_location_all.description%TYPE;
    BEGIN
        OPEN c_desc(p_location_cd);
        FETCH c_desc INTO l_c_description;
        CLOSE c_desc;
        RETURN l_c_description;
    END get_location_description;

  BEGIN

    -- To fetch table schema name for gather statistics
    l_b_return := fnd_installation.get_app_info('IGS', l_c_status, l_c_industry, l_c_schema);

    -- Collect statistics of the interface table as per standards. Bug # 2710978
    tablenames_tbl(1) := 'IGS_PS_SCH_INSTR_ALL';
    tablenames_tbl(2) := 'IGS_PS_SCH_MWC_ALL';
    tablenames_tbl(3) := 'IGS_PS_SCH_FACLT_ALL';
    tablenames_tbl(4) := 'IGS_PS_SCH_X_USEC_INT_ALL';
    tablenames_tbl(5) := 'IGS_PS_SCH_USEC_INT_ALL';
    tablenames_tbl(6) := 'IGS_PS_SCH_INT_ALL';
    tablenames_tbl(7) := 'IGS_PS_PREFS_SCH_INT_ALL';
    tablenames_tbl(8) := 'IGS_PS_SCH_HDR_INT_ALL';

     FOR i IN 1.. tablenames_tbl.LAST
     LOOP
      fnd_stats.gather_table_stats(ownname => l_c_schema,
                                   tabname => tablenames_tbl(i),
                                   cascade => TRUE
                                   );
    END LOOP;

    -- set the multi org id
    igs_ge_gen_003.set_org_id (p_org_id);

    -- set the flag to success
    retcode:=0;

    -- open the Scheduler Unit Section Details Data cursor - This is the Main LOOP
    FOR l_fetch_usec_inter IN c_get_usec_inter
    LOOP
      IF l_c_t_cal_type IS NULL AND l_n_t_seq_num IS NULL AND l_n_t_uoo_id IS NULL THEN
         l_c_t_cal_type := l_fetch_usec_inter.calendar_type;
         l_n_t_seq_num  := l_fetch_usec_inter.sequence_number;
         l_n_t_uoo_id   := l_fetch_usec_inter.uoo_id;
         l_b_print_cal  := TRUE;
         l_b_print_uoo  := TRUE;
      ELSE
         IF (l_c_t_cal_type <> l_fetch_usec_inter.calendar_type) AND
            (l_n_t_seq_num <> l_fetch_usec_inter.sequence_number) THEN
            l_b_print_cal :=TRUE;
            l_b_print_uoo := TRUE;
            l_c_t_cal_type := l_fetch_usec_inter.calendar_type;
            l_n_t_seq_num  := l_fetch_usec_inter.sequence_number;
         ELSE
            IF l_n_t_uoo_id <> l_fetch_usec_inter.uoo_id THEN
               l_b_print_uoo := TRUE;
               l_n_t_uoo_id   := l_fetch_usec_inter.uoo_id;
            END IF;
         END IF;
      END IF;

      -- cursor for fetching Originator id
      OPEN c_get_originator(l_fetch_usec_inter.transaction_id);
      FETCH c_get_originator INTO l_originator;
        IF (c_get_originator%NOTFOUND) THEN
          CLOSE c_get_originator;
          retcode:=2;
          fnd_message.set_name('IGS','IGS_GE_VAL_DOES_NOT_XS');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          app_exception.raise_exception;
        END IF;
      CLOSE c_get_originator; -- closing cursor for originator id

      -- Cursor for fetching records from Interface Table(igs_ps_sch_int)
      -- For each record fetched by the main Unit Section Details Cursor Loop,
      -- We Loop across the Scheduler Interface Details table.

      FOR fetch_records_inter IN c_get_records_inter(l_fetch_usec_inter.int_usec_id)
      Loop
        l_error_text := NULL;
        l_valid_rec_for_prod  := TRUE;
        l_unit_section_occurrence_id := fetch_records_inter.unit_section_occurrence_id;
        l_schedule_status            := fetch_records_inter.schedule_status;
        l_inter_error_text           := fetch_records_inter.error_text;
        l_transaction_type           := fetch_records_inter.transaction_type;
        l_building_code              := fetch_records_inter.building_id;
        l_room_code                  := fetch_records_inter.room_id;
        l_start_time                 := fetch_records_inter.start_time;
        l_end_time                   := fetch_records_inter.end_time;
        l_monday                     := fetch_records_inter.monday;
        l_tuesday                    := fetch_records_inter.tuesday;
        l_wednesday                  := fetch_records_inter.wednesday;
        l_thursday                   := fetch_records_inter.thursday;
        l_friday                     := fetch_records_inter.friday;
        l_saturday                   := fetch_records_inter.saturday;
        l_sunday                     := fetch_records_inter.sunday;
        l_d_uso_start_date           := fetch_records_inter.uso_start_date;
        l_d_uso_end_date             := fetch_records_inter.uso_end_date;

        -- Fetching records from production table(igs_ps_usec_occurs)

        OPEN c_ipsuo(fetch_records_inter.unit_section_occurrence_id);
        FETCH c_ipsuo INTO l_ipsuo;
          IF (c_ipsuo%NOTFOUND) THEN
            CLOSE c_ipsuo;
            retcode:=2;
            fnd_message.set_name('IGS','IGS_GE_VAL_DOES_NOT_XS');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            app_exception.raise_exception;
          END IF;
          -- This is added as part of bug#4287940
	  l_tba_status := l_ipsuo.to_be_announced;

          --Check if the production record is already schdeuled to avoid confliction in scheduling
          --added  by Babita
          IF l_originator = 'INTERNAL' OR l_originator = 'EXTERNAL' THEN
             -- Conflicting scheduling: 1
             -- if the schedule status of the USO is scheduled in production table, then it is already scheduled
             -- no need to import the record, log the message IGS_PS_USO_SCHED
             -- Conflicting scheduling: 2, if the origination of transaction is external then the schedule status of the corresponding
             -- unit section occurrence should not be in 'Scheduling in Progress', 'Cancellation Requested' and 'Rescheduling Requested'
             -- Set the error message to indicate to 3rd party s/w about conflicting schedule
             -- Also set the values of variables l_set_scheduled_status and l_transaction_type to be used to update interface table
                l_status:=l_ipsuo.schedule_status;
             IF l_status = 'SCHEDULED' OR (l_originator = 'EXTERNAL' AND l_status IN ('PROCESSING','USER_UPDATE','USER_CANCEL')) THEN
                   IF l_status = 'SCHEDULED'  THEN
                      fnd_message.set_name('IGS','IGS_PS_USO_SCHED');
                      l_error_text:= fnd_message.get;
                      l_set_scheduled_status := 'SCHEDULED';
                      l_set_transaction_type := 'COMPLETE';
                   ELSE
                      fnd_message.set_name('IGS','IGS_PS_CONFLICT_SCHD');
                      l_error_text:= fnd_message.get;
                      l_set_scheduled_status := 'ERROR';
                      l_set_transaction_type := 'INCOMPLETE';
                   END IF;

             -- if the scheduling software could not schedules a unit section occurrence (schedule_status ='ERROR') then scheduling software
             -- should provide the error message. if error message is not provided then set the default error message 'IGS_PS_REF_3RD_PRTY_SW_ERR'
             ELSIF l_schedule_status = 'ERROR' THEN
                IF l_inter_error_text IS NULL THEN
                   fnd_message.set_name('IGS','IGS_PS_REF_3RD_PRTY_SW_ERR');
                   l_error_text:= fnd_message.get;
                ELSE
                   l_error_text:=l_inter_error_text;
                END IF;  -- end of l_inter_error_text
                --Added  to get the values of variables to be set in interface table
                l_set_transaction_type := 'INCOMPLETE';
                l_set_scheduled_status := 'ERROR';

             -- if the scheduling software successfully scheduled a unit section occurrence it sets the schedule status = 'SCHEDULED'
             ELSIF l_schedule_status = 'OK' THEN
                l_error_text :=NULL;
                -- if the unit section occurrence is request for schedule / request for rescheduled then scheduling software should provide
                -- scheduled building identifier and room identifier for normal unit section occurrence. for to be announced unit section
                -- occurrence scheduling software should provide  unit section occcurrence effective dates, start/end time along wich scheduled
                -- building/room identifier.
                IF l_transaction_type IN ('REQUEST','UPDATE') THEN

----
         OPEN check_ovrd;
	 FETCH check_ovrd INTO l_check_ovrd;
	 IF check_ovrd%FOUND THEN
	   --Days override
	   IF l_check_ovrd.day_ovrd_flag = 'N' AND (l_ipsuo.monday='Y' OR
	                                             l_ipsuo.tuesday='Y' OR
						     l_ipsuo.wednesday='Y' OR
						     l_ipsuo.thursday='Y' OR
						     l_ipsuo.friday='Y' OR
						     l_ipsuo.saturday='Y' OR
						     l_ipsuo.sunday='Y'  ) THEN
             l_monday := l_ipsuo.monday;
             l_tuesday := l_ipsuo.tuesday;
             l_wednesday := l_ipsuo.wednesday;
             l_thursday := l_ipsuo.thursday;
	     l_friday := l_ipsuo.friday;
             l_saturday := l_ipsuo.saturday;
             l_sunday := l_ipsuo.sunday;
           END IF;
	    --Date override
	   IF l_check_ovrd.date_ovrd_flag = 'N' AND (l_ipsuo.start_date IS NOT NULL  OR
                                                l_ipsuo.end_date IS NOT NULL ) THEN
             l_d_uso_start_date := l_ipsuo.start_date;
             l_d_uso_end_date := l_ipsuo.end_date;
	   END IF;
	   --Time override
	   IF l_check_ovrd.time_ovrd_flag = 'N' AND (l_ipsuo.start_time IS NOT NULL  OR
                                                l_ipsuo.end_time IS NOT NULL ) THEN
             l_start_time := l_ipsuo.start_time;
             l_end_time := l_ipsuo.end_time;
	   END IF;
           --Schedule Building override
	   IF l_check_ovrd.scheduled_bld_ovrd_flag = 'N' AND (l_ipsuo.building_code IS NOT NULL) THEN
             l_building_code := l_ipsuo.building_code;
	   END IF;
           --Schedule Room override
	   IF l_check_ovrd.scheduled_room_ovrd_flag = 'N' AND (l_ipsuo.room_code IS NOT NULL ) THEN
             l_room_code := l_ipsuo.room_code;
	   END IF;
	 END IF;
         CLOSE check_ovrd;
----

                   -- check whehter the scheduling software provided building identifier / room identifier
                   IF l_building_code is NULL OR
                      l_d_uso_start_date IS NULL OR l_d_uso_end_date IS NULL OR
                      ( (NVL(l_sunday,'N') = 'N') AND (NVL(l_monday,'N') = 'N') AND (NVL(l_tuesday,'N') = 'N') AND (NVL(l_wednesday,'N') = 'N')
                         AND (NVL(l_thursday,'N') = 'N') AND (NVL(l_friday,'N') = 'N') AND (NVL(l_saturday,'N') = 'N') ) THEN
                       --check for the value of tba_status,If 'Y' then set the corresponding error textwith scheduled status = 'TBA'
                      IF fetch_records_inter.tba_status  = 'Y' THEN
                         fnd_message.set_name('IGS','IGS_PS_USO_TBA_STATUS');
                         l_error_text:= fnd_message.get;
                         l_set_scheduled_status := 'TBA' ;
                      ELSE
                        IF l_inter_error_text IS NULL THEN
                           fnd_message.set_name('IGS','IGS_PS_VALUES_NULL');
                           l_error_text:= fnd_message.get;
                        ELSE
                           l_error_text:=l_inter_error_text;
                        END IF;
                           l_set_scheduled_status := 'ERROR';
                      END IF;
                      l_set_transaction_type := 'INCOMPLETE';
                   ELSE
                      l_set_scheduled_status  := 'SCHEDULED' ;
                      l_set_transaction_type  := 'COMPLETE';
                      l_error_text            := NULL;

                      --Check the value of TBA_STATUS.
                      /*IF fetch_records_inter.tba_status  = 'Y' THEN
                         -- for to be announced unit section occurrence. Apart from building /room identifier. Scheduling software
                         -- provides the meeting days (Sunday - Monday) , start / end time. Also unit section occurrence effective dates
                         -- if not provided by the user in the system.*/

		       IF l_start_time IS NOT NULL AND l_end_time IS NOT NULL THEN
			 IF TO_CHAR(l_start_time,'HH24:MI:SS') > TO_CHAR(l_end_time,'HH24:MI:SS') THEN
			 -- start time should be less than end time.
			    fnd_message.set_name('IGS', 'IGS_GE_ST_TIME_LT_END_TIME');
			    l_error_text := fnd_message.get;
			 END IF;
		       END IF;

		       --  if the unit section occurrence start / end date is not provided by user in the system then it would be
		       --  provided by scheduling software, need to validate the user provided date is valid date.
			  OPEN c_date(l_ipsuo.uoo_id);
			  FETCH c_date INTO rec_date;
			  CLOSE c_date;

                        -- l_d_uso_start_date and l_d_uso_end_date should be not null for non tba occurrence
			IF l_d_uso_start_date IS NOT NULL AND l_d_uso_end_date IS NOT NULL THEN

			  -- Unit section occurrence start date should be less than end date
			  IF l_d_uso_end_date < l_d_uso_start_date THEN
			     fnd_message.set_name('IGS','IGS_PE_EDT_LT_SDT');
			     l_error_text := fnd_message.get;
			  END IF;

                          IF l_d_uso_start_date IS NOT NULL THEN
			     IF rec_date.us_start_date IS NOT NULL THEN
				IF l_d_uso_start_date  <  rec_date.us_start_date THEN
				   fnd_message.set_name ('IGS','IGS_PS_USO_STDT_GE_US_STDT');
				   l_error_text := fnd_message.get;
				END IF;
			     ELSE
				IF l_d_uso_start_date  <  rec_date.tp_start_date THEN
				   fnd_message.set_name ('IGS','IGS_PS_USO_STDT_GE_TP_STDT');
				   l_error_text := fnd_message.get;
				END IF;
			     END IF;

			     IF rec_date.us_end_date IS NOT NULL THEN
				IF l_d_uso_start_date  >  rec_date.us_end_date THEN
				   fnd_message.set_name ('IGS','IGS_PS_USO_ST_DT_UOO_END_DT');
				   l_error_text := fnd_message.get;
				END IF;
			     ELSE
				IF l_d_uso_start_date  >  rec_date.tp_end_date THEN
				   fnd_message.set_name ('IGS','IGS_PS_USO_ST_DT_TP_END_DT');
				   l_error_text := fnd_message.get;
				END IF;
			     END IF;
			  END IF;

			  IF l_d_uso_end_date IS NOT NULL THEN
			     IF rec_date.us_start_date IS NOT NULL THEN
				IF l_d_uso_end_date  <  rec_date.us_start_date THEN
				   fnd_message.set_name ('IGS','IGS_PS_USO_END_DT_UOO_ST_DT');
				   l_error_text := fnd_message.get;
				END IF;
			     ELSE
				IF l_d_uso_end_date  <  rec_date.tp_start_date THEN
				   fnd_message.set_name ('IGS','IGS_PS_USO_END_DT_TP_ST_DT');
				   l_error_text := fnd_message.get;
				END IF;
			     END IF;

			     IF rec_date.us_end_date IS NOT NULL THEN
				IF l_d_uso_end_date  >  rec_date.us_end_date THEN
				   fnd_message.set_name ('IGS','IGS_PS_USO_ENDT_LE_US_ENDT');
				   l_error_text := fnd_message.get;
				END IF;
			     ELSE
				IF l_d_uso_end_date  >  rec_date.tp_end_date THEN
				   fnd_message.set_name ('IGS','IGS_PS_USO_ENDT_LE_TP_ENDT');
				   l_error_text := fnd_message.get;

				END IF;
			     END IF;

			  END IF;
                      END IF;


		       -- if the unit section occurrence is success in all the above validation then set the tba_status as 'N'
		       IF l_error_text IS NULL THEN
			  l_tba_status := 'N' ;
		       END IF;
                      /*ELSE  -- for normal unit section occurrences
                         l_monday            := l_ipsuo.monday ;
                         l_tuesday           := l_ipsuo.tuesday;
                         l_wednesday         := l_ipsuo.wednesday;
                         l_thursday          := l_ipsuo.thursday;
                         l_friday            := l_ipsuo.friday;
                         l_saturday          := l_ipsuo.saturday;
                         l_sunday            := l_ipsuo.sunday;
                         l_d_uso_start_date  := l_ipsuo.start_date;
                         l_d_uso_end_date    := l_ipsuo.end_date;
                         l_start_time        := l_ipsuo.start_time;
                         l_end_time          := l_ipsuo.end_time;
                      END IF;*/

                      -- validate the building identifier
                      OPEN c_bldg_exists(l_building_code);
                      FETCH c_bldg_exists INTO l_c_exists;
                      IF c_bldg_exists%NOTFOUND THEN
                         fnd_message.set_name ('IGS','IGS_PS_BUILDING_ID_INVALID');
                         l_error_text := fnd_message.get;
                      END IF;
                      CLOSE c_bldg_exists;

                      IF   l_room_code IS NOT NULL THEN
			 -- validate the room identifier
			 OPEN c_room_exists(l_room_code);
			 FETCH c_room_exists INTO l_c_exists;
			 IF c_room_exists%NOTFOUND THEN
			   fnd_message.set_name ('IGS','IGS_PS_ROOM_ID_INVALID');
			   l_error_text := fnd_message.get;
			 END IF;
			 CLOSE c_room_exists;

			 -- validate the building / room identifier
			 OPEN c_bldg_room_exists(l_building_code,l_room_code);
			 FETCH c_bldg_room_exists INTO l_c_exists;
			 IF c_bldg_room_exists%NOTFOUND THEN
			   fnd_message.set_name ('IGS','IGS_PS_ROOM_INV_FOR_BLD');
			   l_error_text := fnd_message.get;
			 END IF;
			 CLOSE c_bldg_room_exists;
                      END IF;

                      IF l_error_text IS NOT NULL THEN
                         l_set_scheduled_status  := 'ERROR' ;
                      END IF;
                   END IF;  -- if start time , end time , building identifier and room identifier are null.
                ELSIF l_transaction_type = 'CANCEL' THEN
                   IF l_building_code IS NULL AND l_room_code IS NULL THEN
                      l_set_scheduled_status := 'CANCELLED';
                      l_set_transaction_type := 'COMPLETE';
                      l_error_text := NULL;
                   ELSE
                     IF l_inter_error_text IS NULL THEN
                        fnd_message.set_name('IGS','IGS_PS_VALUES_NOT_NULL');
                        l_error_text:= fnd_message.get;
                     ELSE
                        l_error_text:=l_inter_error_text;
                     END IF;
                        l_set_scheduled_status := 'ERROR';
                        l_set_transaction_type := 'INCOMPLETE';
                   END IF;    -- End of checking for NOT NULL values
                END IF;      -- End Transcation Type(REQUEST,UPDATE,CANCEL)
             END IF;        -- End of Schedule Status(ERROR,OK)


	     IF l_error_text IS NOT NULL THEN
                l_set_transaction_type := 'INCOMPLETE';
                l_building_code        := l_ipsuo.building_code;
                l_room_code            := l_ipsuo.room_code;
                l_d_uso_start_date     := l_ipsuo.start_date;
                l_d_uso_end_date       := l_ipsuo.end_date;
                l_start_time           := l_ipsuo.start_time;
                l_end_time             := l_ipsuo.end_time;
                l_sunday               := l_ipsuo.sunday;
                l_monday               := l_ipsuo.monday;
                l_tuesday              := l_ipsuo.tuesday;
                l_wednesday            := l_ipsuo.wednesday;
                l_thursday             := l_ipsuo.thursday;
                l_friday               := l_ipsuo.friday;
                l_saturday             := l_ipsuo.saturday;
                l_tba_status           := l_ipsuo.to_be_announced;
             END IF;

             -- Printing calendar details
             IF l_b_print_cal THEN
                log_teach_cal  (l_fetch_usec_inter.calendar_type,
                                l_fetch_usec_inter.sequence_number);
                l_b_print_cal := FALSE;
             END IF;
             -- Printing unit section details
             IF l_b_print_uoo THEN
                log_usec_details  (l_fetch_usec_inter.unit_cd,
                                   l_fetch_usec_inter.version_number,
                                   get_location_description(l_fetch_usec_inter.location_cd),
                                   l_fetch_usec_inter.unit_class,
                                   l_fetch_usec_inter.enrollment_maximum);
                l_b_print_uoo :=FALSE;
             END IF;

             update_info( l_ipsuo.unit_section_occurrence_id,
                          fetch_records_inter.int_occurs_id,
                          l_set_scheduled_status,
                          l_set_transaction_type,
                          l_building_code,
                          l_room_code,
                          l_d_uso_start_date,
                          l_d_uso_end_date,
                          l_start_time,
                          l_end_time,
                          l_sunday,
                          l_monday,
                          l_tuesday,
                          l_wednesday,
                          l_thursday,
                          l_friday,
                          l_saturday,
                          l_tba_status,
                          l_error_text
             );
          END IF;          -- End of Originator Id(INTERNAL,EXTERNAL)
        CLOSE c_ipsuo;  -- closing of production table cursor
      END LOOP;  -- for c_fetch_records_inter loop
    END LOOP;    -- for c_fetch_usec_inter loop

    -- Modified to show the success messsage only if some valid records are transfered from
    -- interface table to production table, otherwise log the message ' NO valid record exists
    -- to import into the production table', added as a part of Bug # 2427725
    IF l_valid_rec_for_prod THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_PS_SCH_GET_SCHD_SUCCESS');
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    ELSE
       -- Message is logged when there exists no scheduled records in interface table that needs to be
       -- transfer from Interface tables
       FND_MESSAGE.SET_NAME('IGS','IGS_PS_NO_SHD_REC_FRM_INT');
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
        RETCODE:=2;
        fnd_file.put_line(fnd_file.log, SQLERRM);
        ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION') || ' : ' || SQLERRM;
        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
        ROLLBACK;
END prgp_get_schd_records ;


PROCEDURE abort_sched(
  errbuf            OUT NOCOPY  VARCHAR2,
  retcode           OUT NOCOPY  NUMBER,
  p_teach_calendar  IN VARCHAR2 ,
  p_unit_cd         IN VARCHAR2 ,
  p_version_number  IN NUMBER,
  p_location        IN VARCHAR2,
  p_unit_class      IN VARCHAR2,
  p_cancel_only     IN VARCHAR2)  AS
/**********************************************************************
  Created By       : sommukhe

  Date Created On  : 12-May-2005

  Purpose          : To abort records from scheduling interface tables.

  Know limitations, enhancements or remarks

  Change History
  Who               When                             What
  (reverse chronological order - newest change first)
   sommukhe   9-JAN-2006       Bug# 4869737,included call to igs_ge_gen_003.set_org_id
************************************************************************/

  --This cursor picks those occurrences from the interface table whose schedule status is null and filtered by the input parameters
  CURSOR c_int_uso_ss (cp_sequence_number igs_ps_sch_int_all.sequence_number%TYPE,
		       cp_cal_type  igs_ps_sch_int_all.calendar_type%type) IS
  SELECT a.ROWID intrid,a.*,b.ROWID prodrid,
         c.unit_cd UNIT_CODE,c.version_number UNIT_VERSION_NUMBER,c.location_cd LOCATION_CODE,c.unit_class UNIT_CLS
  FROM igs_ps_sch_int_all a,Igs_ps_usec_occurs_all b, igs_ps_sch_usec_int_all c
  WHERE a.unit_section_occurrence_id=b.unit_section_occurrence_id
  AND a.int_usec_id = c.int_usec_id
  AND c.calendar_type=cp_cal_type
  AND c.sequence_number =cp_sequence_number
  AND c.unit_cd= NVL (p_unit_cd, c.unit_cd)
  AND c.version_number= NVL (p_version_number, c.version_number)
  AND c.location_cd=NVL (p_location, c.location_cd)
  AND c.unit_class= NVL (p_unit_class, c.unit_class)
  AND (p_cancel_only ='N' OR b.cancel_flag = 'Y')
  AND a.schedule_status IS NULL;


  --all the interface section records
  CURSOR c_int_usec_ss (cp_sequence_number igs_ps_sch_int_all.sequence_number%TYPE,
		       cp_cal_type  igs_ps_sch_int_all.calendar_type%TYPE) IS
  SELECT us.ROWID intrid,us.*
  FROM   igs_ps_sch_usec_int_all us
  WHERE  calendar_type=cp_cal_type
  AND    sequence_number = cp_sequence_number
  AND    unit_cd= NVL (p_unit_cd, us.unit_cd)
  AND    version_number=NVL (p_version_number, us.version_number)
  AND    location_cd=NVL (p_location, us.location_cd)
  AND    unit_class= NVL (p_unit_class, us.unit_class);

  --all the interface pattern records
  CURSOR c_int_pat_ss (cp_sequence_number igs_ps_sch_int_all.sequence_number%TYPE,
		       cp_cal_type  igs_ps_sch_int_all.calendar_type%TYPE) IS
  SELECT pt.ROWID intrid,pt.*
  FROM igs_ps_sch_pat_int pt
  WHERE pt.calendar_type=cp_cal_type
  AND pt.sequence_number =cp_sequence_number
  AND pt.unit_cd= NVL (p_unit_cd,pt.unit_cd)
  AND pt.version_number=NVL (p_version_number, pt.version_number);


  CURSOR c_int_uso (cp_n_int_usec_id igs_ps_sch_int_all.int_usec_id%TYPE) IS
  SELECT count(*)
  FROM   igs_ps_sch_int_all a
  WHERE  a.int_usec_id = cp_n_int_usec_id
  AND    a.abort_flag = 'N';

  c_int_uso_rec c_int_uso%ROWTYPE;

  CURSOR c_int_usec (cp_n_int_pat_id igs_ps_sch_usec_int_all.int_pat_id%TYPE) IS
  SELECT count(*)
  FROM   igs_ps_sch_usec_int_all  a
  WHERE  a.int_pat_id = cp_n_int_pat_id
  AND    a.abort_flag = 'N';

  CURSOR c_int_uso_prod (cp_rowid ROWID) IS
  SELECT b.ROWID prodrid,b.*
  FROM   igs_ps_usec_occurs_all b
  WHERE  rowid = cp_rowid;

  c_int_uso_prod_rec c_int_uso_prod%ROWTYPE;

  CURSOR c_prod_usec (cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
  SELECT a.rowid prodrid,a.*
  FROM   igs_ps_unit_ofr_opt_all  a
  WHERE  a.uoo_id=cp_uoo_id;

  c_prod_usec_rec c_prod_usec%ROWTYPE;

  CURSOR c_prod_pat (cp_sequence_number igs_ps_sch_int_all.sequence_number%TYPE,
		     cp_cal_type        igs_ps_sch_int_all.calendar_type%TYPE,
		     cp_unit_cd         igs_ps_unit_ofr_pat_all.unit_cd%TYPE,
		     cp_version_number  igs_ps_unit_ofr_pat_all.version_number%TYPE) IS
  SELECT pt.ROWID prodrid,pt.*
  FROM   igs_ps_unit_ofr_pat_all pt
  WHERE  cal_type=cp_cal_type
  AND    ci_sequence_number =cp_sequence_number
  AND    unit_cd= cp_unit_cd
  AND    version_number=cp_version_number;

  c_prod_pat_rec c_prod_pat%ROWTYPE;


  l_cal_type                igs_ca_inst.cal_type%TYPE;
  l_ci_sequence_number      igs_ca_inst.sequence_number%TYPE;
  l_start_date              igs_ca_inst.start_dt%TYPE;
  l_end_date                igs_ca_inst.end_dt%TYPE;
  l_uso_count               NUMBER(10);
  l_abort_flag              VARCHAR2(2);
  l_abort_count             NUMBER(10);
  l_proc_count              NUMBER(10);

BEGIN

      igs_ge_gen_003.set_org_id (NULL);
      retcode:=0;

      fnd_message.set_name('IGS','IGS_FI_CAL_BALANCES_LOG');
      fnd_message.set_token('PARAMETER_NAME',igs_ps_validate_lgcy_pkg.get_lkup_meaning('TEACHING_PERIOD','IGS_PS_LOG_PARAMETERS'));
      fnd_message.set_token('PARAMETER_VAL' ,p_teach_calendar);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_CD' )
                                || '           : ' || p_unit_cd );
      fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_VER_NUM' )
                                || ' : ' || TO_CHAR (p_version_number) );
      fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'LOCATION_CD' )
                                || ' : ' || p_location );
      fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_CLASS' )
                                || ' : ' || p_unit_class );

      fnd_message.set_name('IGS','IGS_FI_CAL_BALANCES_LOG');
      fnd_message.set_token('PARAMETER_NAME',igs_ps_validate_lgcy_pkg.get_lkup_meaning('CANCEL_OCCUR_ONLY','IGS_PS_LOG_PARAMETERS'));
      fnd_message.set_token('PARAMETER_VAL' ,p_cancel_only);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.put_line(fnd_file.log,' ');
      fnd_file.put_line(fnd_file.log,' ');


      -- Get the cal_tpe,sequence_number and start date and End date
      l_cal_type := RTRIM(SUBSTR(p_teach_calendar,101,10));
      l_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_teach_calendar,112,6)));
      l_start_date := fnd_date.string_to_date(RTRIM(SUBSTR(p_teach_calendar,11,11)), 'DD-MON-YYYY');
      l_end_date := fnd_date.string_to_date(RTRIM(SUBSTR(p_teach_calendar,24,11)), 'DD-MON-YYYY');

      l_abort_count := 0;
      l_proc_count  := 0;

      fnd_message.set_name('IGS','IGS_PS_ABORT_OCCURS_SEC_PAT');
      fnd_message.set_token('TABLENAME',igs_ps_validate_lgcy_pkg.get_lkup_meaning('OCCURRENCES','IGS_PS_TABLE_NAME'));
      fnd_file.put_line ( fnd_file.LOG,fnd_message.get );
      fnd_file.put_line(fnd_file.log,' ');

      FOR c_int_uso_ss_rec IN c_int_uso_ss(l_ci_sequence_number,l_cal_type) LOOP

	 fnd_file.put_line ( fnd_file.LOG,igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_CD' )
					|| '           : ' || c_int_uso_ss_rec.unit_code );
	 fnd_file.put_line ( fnd_file.LOG,igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_VER_NUM' )
					|| ' : ' || TO_CHAR (c_int_uso_ss_rec.unit_version_number) );
	 fnd_file.put_line ( fnd_file.LOG,igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'LOCATION_CD' )
					|| ' : ' || c_int_uso_ss_rec.location_code );
	 fnd_file.put_line ( fnd_file.LOG,igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_CLASS' )
					|| ' : ' || c_int_uso_ss_rec.unit_cls );
	 fnd_message.set_name('IGS','IGS_FI_CAL_BALANCES_LOG');
	 fnd_message.set_token('PARAMETER_NAME',igs_ps_validate_lgcy_pkg.get_lkup_meaning('USEC_OCCRS_ID','IGS_PS_LOG_PARAMETERS'));
	 fnd_message.set_token('PARAMETER_VAL' ,c_int_uso_ss_rec.occurrence_identifier);
	 fnd_file.put_line(fnd_file.log,fnd_message.get);
 	 fnd_file.put_line ( fnd_file.LOG, 'Int Occurs Id'|| ' : ' || c_int_uso_ss_rec.int_occurs_id );
	 fnd_file.put_line(fnd_file.log,'  ');

	 UPDATE igs_ps_sch_int_all SET abort_flag = 'Y'
	 WHERE ROWID = c_int_uso_ss_rec.intrid;

	 OPEN c_int_uso_prod(c_int_uso_ss_rec.prodrid);
	 FETCH c_int_uso_prod INTO c_int_uso_prod_rec;


	 igs_ps_usec_occurs_pkg.update_row (
                       X_RowId                             => c_int_uso_prod_rec.prodrid ,
                       X_unit_section_occurrence_id        => c_int_uso_prod_rec.unit_section_occurrence_id,
                       X_uoo_id                            => c_int_uso_prod_rec.uoo_id,
                       X_monday                            => c_int_uso_prod_rec.monday,
                       X_tuesday                           => c_int_uso_prod_rec.tuesday,
                       X_wednesday                         => c_int_uso_prod_rec.wednesday,
                       X_thursday                          => c_int_uso_prod_rec.thursday,
                       X_friday                            => c_int_uso_prod_rec.friday,
                       X_saturday                          => c_int_uso_prod_rec.saturday,
                       X_sunday                            => c_int_uso_prod_rec.sunday,
                       X_start_time                        => c_int_uso_prod_rec.start_time,
                       X_end_time                          => c_int_uso_prod_rec.end_time,
                       X_building_code                     => c_int_uso_prod_rec.building_code,
                       X_room_code                         => c_int_uso_prod_rec.room_code,
                       X_schedule_status                   => NULL,
                       X_status_last_updated               => SYSDATE,
                       X_instructor_id                     => c_int_uso_prod_rec.instructor_id,
                       X_attribute_category                => c_int_uso_prod_rec.attribute_category,
                       X_attribute1                        => c_int_uso_prod_rec.attribute1,
                       X_attribute2                        => c_int_uso_prod_rec.attribute2,
                       X_attribute3                        => c_int_uso_prod_rec.attribute3,
                       X_attribute4                        => c_int_uso_prod_rec.attribute4,
                       X_attribute5                        => c_int_uso_prod_rec.attribute5,
                       X_attribute6                        => c_int_uso_prod_rec.attribute6,
                       X_attribute7                        => c_int_uso_prod_rec.attribute7,
                       X_attribute8                        => c_int_uso_prod_rec.attribute8,
                       X_attribute9                        => c_int_uso_prod_rec.attribute9,
                       X_attribute10                       => c_int_uso_prod_rec.attribute10,
                       X_attribute11                       => c_int_uso_prod_rec.attribute11,
                       X_attribute12                       => c_int_uso_prod_rec.attribute12,
                       X_attribute13                       => c_int_uso_prod_rec.attribute13,
                       X_attribute14                       => c_int_uso_prod_rec.attribute14,
                       X_attribute15                       => c_int_uso_prod_rec.attribute15,
                       X_attribute16                       => c_int_uso_prod_rec.attribute16,
                       X_attribute17                       => c_int_uso_prod_rec.attribute17,
                       X_attribute18                       => c_int_uso_prod_rec.attribute18,
                       X_attribute19                       => c_int_uso_prod_rec.attribute19,
                       X_attribute20                       => c_int_uso_prod_rec.attribute20,
                       X_error_text                        => c_int_uso_prod_rec.error_text ,
		       x_mode                              => 'R',
                       X_start_date                        => c_int_uso_prod_rec.start_date,
                       X_end_date                          => c_int_uso_prod_rec.end_date,
                       X_to_be_announced                   => c_int_uso_prod_rec.to_be_announced,
                       X_inst_notify_ind                   => c_int_uso_prod_rec.inst_notify_ind,
                       X_notify_status                     => c_int_uso_prod_rec.notify_status,
                       X_dedicated_building_code           => c_int_uso_prod_rec.dedicated_building_code,
                       X_dedicated_room_code               => c_int_uso_prod_rec.dedicated_room_code,
		       X_preferred_building_code           => c_int_uso_prod_rec.preferred_building_code,
                       X_preferred_room_code               => c_int_uso_prod_rec.preferred_room_code,
		       X_preferred_region_code             => c_int_uso_prod_rec.preferred_region_code,
    	               X_no_set_day_ind                    => c_int_uso_prod_rec.no_set_day_ind,
                       x_cancel_flag                       => 'N',
           	       x_occurrence_identifier             => c_int_uso_prod_rec.occurrence_identifier,
		       x_abort_flag                        => 'Y'
                    );
         CLOSE c_int_uso_prod;
	 l_abort_count := l_abort_count +1;
      END LOOP;

      fnd_message.set_name('IGS','IGS_PS_TOT_RECORDS_PROCESS');
      fnd_message.set_token('TABLE',igs_ps_validate_lgcy_pkg.get_lkup_meaning('OCCURRENCES','IGS_PS_TABLE_NAME'));
      fnd_file.put_line ( fnd_file.LOG, '   ' || fnd_message.get||l_abort_count );
      fnd_message.set_name('IGS','IGS_PS_TOT_RECORDS_ABORTED');
      fnd_message.set_token('TABLE',igs_ps_validate_lgcy_pkg.get_lkup_meaning('OCCURRENCES','IGS_PS_TABLE_NAME'));
      fnd_file.put_line ( fnd_file.LOG, '   ' || fnd_message.get||l_abort_count );

      l_abort_count:= 0;
      l_proc_count := 0;

      fnd_file.put_line ( fnd_file.LOG, ' ' );
      fnd_message.set_name('IGS','IGS_PS_ABORT_OCCURS_SEC_PAT');
      fnd_message.set_token('TABLENAME',igs_ps_validate_lgcy_pkg.get_lkup_meaning('SECTIONS','IGS_PS_TABLE_NAME'));
      fnd_file.put_line ( fnd_file.LOG,fnd_message.get );
      fnd_file.put_line ( fnd_file.LOG, ' ' );

      FOR c_int_usec_ss_rec IN c_int_usec_ss(l_ci_sequence_number,l_cal_type) LOOP
        l_uso_count := NULL;
        OPEN c_int_uso(c_int_usec_ss_rec.int_usec_id);
        FETCH c_int_uso INTO l_uso_count;
	CLOSE c_int_uso;

	IF NVL(l_uso_count,0) = 0 THEN
	  l_abort_flag := 'Y';
	  l_abort_count := l_abort_count +1;

	  --aborting the following section
	  fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_CD' )
					|| '           : ' || c_int_usec_ss_rec.unit_cd );
	  fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_VER_NUM' )
					|| ' : ' || TO_CHAR (c_int_usec_ss_rec.version_number) );
	  fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'LOCATION_CD' )
					|| ' : ' || c_int_usec_ss_rec.location_cd );
	  fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_CLASS' )
					|| ' : ' || c_int_usec_ss_rec.unit_class );
 	  fnd_file.put_line ( fnd_file.LOG, 'Int Usec Id'|| ' : ' || c_int_usec_ss_rec.int_usec_id );
	  fnd_file.put_line ( fnd_file.LOG,'  ' );


	ELSE
          l_abort_flag := 'N';
	END IF;


        --update the interface table
        UPDATE igs_ps_sch_usec_int_all SET abort_flag = l_abort_flag
        WHERE ROWID =c_int_usec_ss_rec.intrid ;

	--update the production table
	OPEN c_prod_usec(c_int_usec_ss_rec.uoo_id);
	FETCH c_prod_usec INTO c_prod_usec_rec;

	igs_ps_unit_ofr_opt_pkg.update_row(
	                                 x_rowid                         =>  c_prod_usec_rec.prodrid,
                                         x_unit_cd                       =>  c_prod_usec_rec.unit_cd,
                                         x_version_number                =>  c_prod_usec_rec.version_number,
                                         x_cal_type                      =>  c_prod_usec_rec.cal_type,
                                         x_ci_sequence_number            =>  c_prod_usec_rec.ci_sequence_number,
                                         x_location_cd                   =>  c_prod_usec_rec.location_cd,
                                         x_unit_class                    =>  c_prod_usec_rec.unit_class,
                                         x_uoo_id                        =>  c_prod_usec_rec.uoo_id,
                                         x_ivrs_available_ind            =>  c_prod_usec_rec.ivrs_available_ind,
                                         x_call_number                   =>  c_prod_usec_rec.call_number,
                                         x_unit_section_status           =>  c_prod_usec_rec.unit_section_status,
                                         x_unit_section_start_date       =>  c_prod_usec_rec.unit_section_start_date,
                                         x_unit_section_end_date         =>  c_prod_usec_rec.unit_section_end_date,
                                         x_enrollment_actual             =>  c_prod_usec_rec.enrollment_actual,
                                         x_waitlist_actual               =>  c_prod_usec_rec.waitlist_actual,
                                         x_offered_ind                   =>  c_prod_usec_rec.offered_ind,
                                         x_state_financial_aid           =>  c_prod_usec_rec.state_financial_aid,
                                         x_grading_schema_prcdnce_ind    =>  c_prod_usec_rec.grading_schema_prcdnce_ind,
                                         x_federal_financial_aid         =>  c_prod_usec_rec.federal_financial_aid,
                                         x_unit_quota                    =>  c_prod_usec_rec.unit_quota,
                                         x_unit_quota_reserved_places    =>  c_prod_usec_rec.unit_quota_reserved_places,
                                         x_institutional_financial_aid   =>  c_prod_usec_rec.institutional_financial_aid,
                                         x_grading_schema_cd             =>  c_prod_usec_rec.grading_schema_cd,
                                         x_gs_version_number             =>  c_prod_usec_rec.gs_version_number,
                                         x_unit_contact                  =>  c_prod_usec_rec.unit_contact,
                                         x_mode                          =>  'R',
                                         x_ss_enrol_ind                  =>  c_prod_usec_rec.ss_enrol_ind,
                                         x_owner_org_unit_cd             =>  c_prod_usec_rec.owner_org_unit_cd,
                                         x_attendance_required_ind       =>  c_prod_usec_rec.attendance_required_ind,
                                         x_reserved_seating_allowed      =>  c_prod_usec_rec.reserved_seating_allowed,
                                         x_ss_display_ind                =>  c_prod_usec_rec.ss_display_ind,
                                         x_special_permission_ind        =>  c_prod_usec_rec.special_permission_ind,
                                         x_dir_enrollment	         =>  c_prod_usec_rec.dir_enrollment,
                                         x_enr_from_wlst	         =>  c_prod_usec_rec.enr_from_wlst,
                                         x_inq_not_wlst		         =>  c_prod_usec_rec.inq_not_wlst,
                                         x_rev_account_cd                =>  c_prod_usec_rec.rev_account_cd,
      	                                 x_anon_unit_grading_ind         =>  c_prod_usec_rec.anon_unit_grading_ind,
                                         x_anon_assess_grading_ind       =>  c_prod_usec_rec.anon_assess_grading_ind,
                                         x_non_std_usec_ind              =>  c_prod_usec_rec.non_std_usec_ind,
					 x_auditable_ind		 =>  c_prod_usec_rec.auditable_ind,
					 x_audit_permission_ind		 =>  c_prod_usec_rec.audit_permission_ind,
					 x_not_multiple_section_flag     =>  c_prod_usec_rec.not_multiple_section_flag,
					 x_sup_uoo_id                    =>  c_prod_usec_rec.sup_uoo_id,
					 x_relation_type                 =>  c_prod_usec_rec.relation_type,
					 x_default_enroll_flag           =>  c_prod_usec_rec.default_enroll_flag,
					 x_abort_flag                    =>  l_abort_flag
                                      );

        CLOSE c_prod_usec;
        l_proc_count := l_proc_count +1;
      END LOOP;

      fnd_message.set_name('IGS','IGS_PS_TOT_RECORDS_PROCESS');
      fnd_message.set_token('TABLE',igs_ps_validate_lgcy_pkg.get_lkup_meaning('SECTIONS','IGS_PS_TABLE_NAME'));
      fnd_file.put_line ( fnd_file.LOG, '   ' || fnd_message.get||l_proc_count );
      fnd_message.set_name('IGS','IGS_PS_TOT_RECORDS_ABORTED');
      fnd_message.set_token('TABLE',igs_ps_validate_lgcy_pkg.get_lkup_meaning('SECTIONS','IGS_PS_TABLE_NAME'));
      fnd_file.put_line ( fnd_file.LOG, '   ' || fnd_message.get||l_abort_count );

      l_abort_count := 0;
      l_proc_count := 0;

      fnd_file.put_line ( fnd_file.LOG, ' ' );
      fnd_message.set_name('IGS','IGS_PS_ABORT_OCCURS_SEC_PAT');
      fnd_message.set_token('TABLENAME',igs_ps_validate_lgcy_pkg.get_lkup_meaning('PATTERNS','IGS_PS_TABLE_NAME'));
      fnd_file.put_line ( fnd_file.LOG, fnd_message.get );
      fnd_file.put_line ( fnd_file.LOG, ' ' );

      FOR c_int_pat_ss_rec IN c_int_pat_ss(l_ci_sequence_number,l_cal_type) LOOP
        l_uso_count:=null;
	OPEN c_int_usec(c_int_pat_ss_rec.int_pat_id);
        FETCH c_int_usec INTO l_uso_count;
	CLOSE c_int_usec;

	IF NVL(l_uso_count,0) = 0 THEN
	  l_abort_flag := 'Y';
	  l_abort_count := l_abort_count +1;

	  --aborting the following patterns
	  fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_CD' )
					|| '           : ' || c_int_pat_ss_rec.unit_cd );
	  fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_VER_NUM' )
					|| ' : ' || TO_CHAR (c_int_pat_ss_rec.version_number) );
	  fnd_message.set_name('IGS','IGS_FI_CAL_BALANCES_LOG');
	  fnd_message.set_token('PARAMETER_NAME',igs_ps_validate_lgcy_pkg.get_lkup_meaning('TEACHING_PERIOD','IGS_PS_LOG_PARAMETERS'));
	  fnd_message.set_token('PARAMETER_VAL' ,p_teach_calendar);
	  fnd_file.put_line(fnd_file.log, fnd_message.get);
 	  fnd_file.put_line ( fnd_file.LOG, 'Int Pat Id'|| ' : ' || c_int_pat_ss_rec.int_pat_id );
	  fnd_file.put_line ( fnd_file.LOG, ' ' );

	ELSE
          l_abort_flag := 'N';
	END IF;


        --update the interface table
        UPDATE igs_ps_sch_pat_int SET abort_flag = l_abort_flag
        WHERE ROWID =c_int_pat_ss_rec.intrid ;

	--update the production table
	OPEN c_prod_pat(l_ci_sequence_number,l_cal_type,c_int_pat_ss_rec.unit_cd ,c_int_pat_ss_rec.version_number );
	FETCH c_prod_pat INTO c_prod_pat_rec;
	igs_ps_unit_ofr_pat_pkg.update_row (
          x_rowid                     => c_prod_pat_rec.prodrid ,
          x_unit_cd                   => c_prod_pat_rec.unit_cd,
          x_version_number            => c_prod_pat_rec.version_number,
          x_ci_sequence_number        => c_prod_pat_rec.ci_sequence_number,
          x_cal_type                  => c_prod_pat_rec.cal_type,
          x_ci_start_dt               => c_prod_pat_rec.ci_start_dt,
          x_ci_end_dt                 => c_prod_pat_rec.ci_end_dt,
          x_waitlist_allowed          => c_prod_pat_rec.waitlist_allowed,
          x_max_students_per_waitlist => c_prod_pat_rec.max_students_per_waitlist,
          x_mode                      => 'R' ,
	  x_delete_flag               => c_prod_pat_rec.delete_flag,
	  x_abort_flag                => l_abort_flag
        );
	CLOSE c_prod_pat;
        l_proc_count := l_proc_count +1;
      END LOOP;

      fnd_message.set_name('IGS','IGS_PS_TOT_RECORDS_PROCESS');
      fnd_message.set_token('TABLE',igs_ps_validate_lgcy_pkg.get_lkup_meaning('PATTERNS','IGS_PS_TABLE_NAME'));
      fnd_file.put_line ( fnd_file.LOG, '   ' || fnd_message.get||l_proc_count );
      fnd_message.set_name('IGS','IGS_PS_TOT_RECORDS_ABORTED');
      fnd_message.set_token('TABLE',igs_ps_validate_lgcy_pkg.get_lkup_meaning('PATTERNS','IGS_PS_TABLE_NAME'));
      fnd_file.put_line ( fnd_file.LOG, '   ' || fnd_message.get||l_abort_count );

EXCEPTION
  WHEN OTHERS THEN
    RETCODE:=2;
    fnd_file.put_line ( fnd_file.LOG, ' ');
    ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION') || ' : ' || SQLERRM;
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
    ROLLBACK;
END abort_sched;



PROCEDURE purge_schd_record(
                             p_c_cal_type IN VARCHAR2,
                             p_n_seq_num  IN NUMBER
                           ) AS
/**********************************************************************
  Created By       : jbegum

  Date Created On  : 07-Apr-2003

  Purpose          : To purge records from scheduling interface tables.

  Know limitations, enhancements or remarks

  Change History
  Who               When                             What
  (reverse chronological order - newest change first)
************************************************************************/

CURSOR cur_config (cp_teaching_calendar_type IN igs_ps_sch_prg_cfig.teaching_calendar_type%TYPE) IS
SELECT purge_type
FROM igs_ps_sch_prg_cfig
WHERE teaching_calendar_type=cp_teaching_calendar_type;
l_teaching_calendar_type igs_ps_sch_prg_cfig.teaching_calendar_type%TYPE;

CURSOR cur_dates (cp_cal_type IN igs_ca_inst_all.cal_type%TYPE,
                  cp_sequence_number IN igs_ca_inst_all.sequence_number%TYPE) IS
SELECT start_dt,end_dt
FROM   igs_ca_inst_all
WHERE  cal_type=cp_cal_type
AND    sequence_number=cp_sequence_number;

-- cursor to select occurrence interface records for purging
CURSOR c_uso( cp_c_cal_type igs_ps_sch_usec_int_all.calendar_type%TYPE,
              cp_n_seq_num  igs_ps_sch_usec_int_all.sequence_number%TYPE,
	      cp_completed  VARCHAR2,
	      cp_cancelled  VARCHAR2,
	      cp_aborted    VARCHAR2) IS

SELECT uso.int_occurs_id int_occurs_id,uso.occurrence_identifier, us.unit_cd, us.version_number, us.unit_class, us.location_cd
FROM   igs_ps_sch_int_all uso, igs_ps_sch_usec_int_all us
WHERE  us.calendar_type= cp_c_cal_type
AND    us.sequence_number=cp_n_seq_num
AND    us.int_usec_id = uso.int_usec_id
AND    ((uso.transaction_type = 'COMPLETE' AND cp_completed ='Y')
        OR  (uso.schedule_status = 'CANCELLED' AND cp_cancelled ='Y')
        OR   (uso.abort_flag = 'Y' AND cp_aborted ='Y'))
AND (uso.import_done_flag = 'Y' OR (uso.import_done_flag='N' AND (uso.abort_flag = 'Y' AND cp_aborted ='Y')));

-- cursor to select section interface records for purging
CURSOR c_usec( cp_c_cal_type igs_ps_sch_usec_int_all.calendar_type%TYPE,
               cp_n_seq_num  igs_ps_sch_usec_int_all.sequence_number%TYPE,
	       cp_aborted    VARCHAR2) IS
SELECT us.int_usec_id, us.unit_cd, us.version_number, us.unit_class, us.location_cd
FROM  igs_ps_sch_usec_int_all  us
WHERE us.calendar_type= cp_c_cal_type
AND   us.sequence_number=cp_n_seq_num
AND (import_done_flag = 'Y' OR (import_done_flag='N' AND (us.abort_flag = 'Y' AND cp_aborted ='Y')))
AND  NOT EXISTS (SELECT 'X' FROM igs_ps_sch_int_all uso WHERE uso.int_usec_id=us.int_usec_id) ;


-- cursor to select section interface records for purging
CURSOR c_pat( cp_c_cal_type igs_ps_sch_usec_int_all.calendar_type%TYPE,
              cp_n_seq_num  igs_ps_sch_usec_int_all.sequence_number%TYPE,
	      cp_aborted    VARCHAR2) IS
SELECT pat.int_pat_id, pat.unit_cd,pat.version_number
FROM  igs_ps_sch_pat_int   pat
WHERE pat.calendar_type= cp_c_cal_type
AND   pat.sequence_number=cp_n_seq_num
AND (import_done_flag = 'Y' OR (import_done_flag='N' AND (pat.abort_flag = 'Y' AND cp_aborted ='Y')))
AND  NOT EXISTS (SELECT 'X' FROM igs_ps_sch_usec_int_all us WHERE us.int_pat_id=pat.int_pat_id) ;

CURSOR c_header IS
SELECT hdr.transaction_id
FROM  igs_ps_sch_hdr_int hdr
WHERE NOT EXISTS ( SELECT 'X' FROM igs_ps_sch_pat_int pat WHERE pat.transaction_id = hdr.transaction_id);


l_start_date DATE;
l_end_date   DATE;
l_completed  VARCHAR2(1);
l_cancelled  VARCHAR2(1);
l_aborted    VARCHAR2(1);

l_c_occurrence_exists BOOLEAN :=FALSE;
l_c_section_exists BOOLEAN :=FALSE;
l_c_pat_exists BOOLEAN :=FALSE;

BEGIN
	l_completed:='N';
	l_cancelled :='N';
	l_aborted:= 'N';

        OPEN cur_dates( p_c_cal_type, p_n_seq_num);
	FETCH cur_dates INTO l_start_date,l_end_date;
	CLOSE cur_dates;

	IF TRUNC(l_end_date) < TRUNC(SYSDATE) THEN
   	  l_teaching_calendar_type := 'PAST';
        ELSIF  TRUNC(l_start_date) > TRUNC(SYSDATE) THEN
          l_teaching_calendar_type := 'FUTURE';
        ELSE
	  l_teaching_calendar_type := 'PRESENT';
        END IF;

	FOR cur_config_rec IN cur_config(l_teaching_calendar_type) LOOP
	  IF cur_config_rec.purge_type = 'COMPLETED' THEN
	    l_completed := 'Y';
	  ELSIF cur_config_rec.purge_type = 'CANCELLED' THEN
	    l_cancelled :='Y';
	  ELSIF cur_config_rec.purge_type = 'ABORTED' THEN
	    l_aborted := 'Y';
	  END IF;
	END LOOP;

        /*Log the Teaching Calendar information */
        fnd_file.put_line(fnd_file.log,' ');
        fnd_file.put_line(fnd_file.log,' ');
	fnd_message.set_name('IGS','IGS_FI_CAL_BALANCES_LOG');
        fnd_message.set_token('PARAMETER_NAME',igs_ps_validate_lgcy_pkg.get_lkup_meaning('CAL_TYPE','LEGACY_TOKENS'));
        fnd_message.set_token('PARAMETER_VAL' ,p_c_cal_type);
	fnd_file.put_line(fnd_file.log,fnd_message.get);
	fnd_message.set_name('IGS','IGS_FI_CAL_BALANCES_LOG');
        fnd_message.set_token('PARAMETER_NAME',igs_ps_validate_lgcy_pkg.get_lkup_meaning('START_DT','IGS_FI_LOCKBOX'));
        fnd_message.set_token('PARAMETER_VAL' ,TO_CHAR(TRUNC(l_start_date)));
	fnd_file.put_line(fnd_file.log,fnd_message.get);
	fnd_message.set_name('IGS','IGS_FI_CAL_BALANCES_LOG');
        fnd_message.set_token('PARAMETER_NAME',igs_ps_validate_lgcy_pkg.get_lkup_meaning('END_DT','IGS_FI_LOCKBOX'));
        fnd_message.set_token('PARAMETER_VAL' ,TO_CHAR(TRUNC(l_end_date)));
	fnd_file.put_line(fnd_file.log,fnd_message.get);
	fnd_file.put_line(fnd_file.log,'--------------------------------------------------------');
        fnd_file.put_line(fnd_file.log,' ');
        fnd_file.put_line(fnd_file.log,' ');


        --If purge type setup is there then only process else return
        IF l_completed = 'Y' OR l_cancelled = 'Y' OR l_aborted = 'Y' THEN

          /********************** Purging the Occurrence Records***************************/
	  l_c_occurrence_exists:=FALSE;
          FOR rec_uso IN c_uso(p_c_cal_type,p_n_seq_num,l_completed,l_cancelled,l_aborted) LOOP

	    IF NOT l_c_occurrence_exists THEN
	      fnd_file.put_line ( fnd_file.LOG,'Purging The Following Occurrences:' );
	      fnd_file.put_line(fnd_file.log,' ');
	      l_c_occurrence_exists:=TRUE;
	    END IF;

            -- Deleting the child of the occurrence
	    DELETE FROM igs_ps_prefs_sch_int_all WHERE int_occurs_id=rec_uso.int_occurs_id;
	    DELETE FROM igs_ps_sch_faclt_all WHERE int_occurs_id=rec_uso.int_occurs_id;
	    DELETE FROM igs_ps_sch_instr_all WHERE int_occurs_id=rec_uso.int_occurs_id;

	    --Deleting the occurrence record
	    DELETE FROM igs_ps_sch_int_all WHERE int_occurs_id=rec_uso.int_occurs_id;

	    fnd_file.put_line ( fnd_file.LOG,igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_CD' )
					  || '             : ' || rec_uso.unit_cd );
	    fnd_file.put_line ( fnd_file.LOG,igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_VER_NUM' )
					  || '   : ' || TO_CHAR (rec_uso.version_number) );
	    fnd_file.put_line ( fnd_file.LOG,igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'LOCATION_CD' )
					  || '         : ' || rec_uso.location_cd );
	    fnd_file.put_line ( fnd_file.LOG,igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_CLASS' )
					  || '            : ' || rec_uso.unit_class );

	    fnd_file.put_line ( fnd_file.LOG,igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'USEC_OCCRS_ID' )
					  || ' : ' || rec_uso.occurrence_identifier );
	    fnd_file.put_line(fnd_file.log,'  ');


	  END LOOP;

	  IF NOT l_c_occurrence_exists THEN
	    fnd_file.put_line ( fnd_file.LOG,'No Occurrence record to be purged' );
	    fnd_file.put_line(fnd_file.log,' ');
	  END IF;

          /********************** Purging the Section Records***************************/
          l_c_section_exists:=FALSE;
          FOR rec_usec IN c_usec(p_c_cal_type,p_n_seq_num,l_aborted) LOOP

	    IF NOT l_c_section_exists THEN
	      fnd_file.put_line ( fnd_file.LOG,'Purging The Following Sections:' );
	      fnd_file.put_line(fnd_file.log,' ');
	      l_c_section_exists:=TRUE;
	    END IF;


	    -- Deleting the child of unit section
	    DELETE FROM igs_ps_sch_x_usec_int_all WHERE int_usec_id=rec_usec.int_usec_id;
	    DELETE FROM igs_ps_sch_mwc_all WHERE int_usec_id=rec_usec.int_usec_id;

	    -- Deleting unit section record
	    DELETE FROM igs_ps_sch_usec_int_all WHERE int_usec_id=rec_usec.int_usec_id;


	    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_CD' )
					  || '           : ' || rec_usec.unit_cd );
	    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_VER_NUM' )
					  || ' : ' || TO_CHAR (rec_usec.version_number) );
	    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'LOCATION_CD' )
					  || '       : ' || rec_usec.location_cd );
	    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_CLASS' )
					  || '          : ' || rec_usec.unit_class );
	    fnd_file.put_line ( fnd_file.LOG,'  ' );


	  END LOOP;

	  IF NOT l_c_section_exists THEN
	    fnd_file.put_line ( fnd_file.LOG,'No Section record to be purged' );
	    fnd_file.put_line(fnd_file.log,' ');
	  END IF;


          /********************** Purging the pattern Records***************************/
          l_c_pat_exists:=FALSE;
          FOR rec_pat IN c_pat(p_c_cal_type,p_n_seq_num,l_aborted) LOOP

	    IF NOT l_c_pat_exists THEN
	      fnd_file.put_line ( fnd_file.LOG,'Purging The Following Patterns:' );
	      fnd_file.put_line(fnd_file.log,' ');
	      l_c_pat_exists:=TRUE;
	    END IF;


	    -- Deleting the child of patterns
	    DELETE FROM igs_ps_sch_loc_int WHERE int_pat_id=rec_pat.int_pat_id;
	    DELETE FROM igs_ps_sch_fac_int WHERE int_pat_id=rec_pat.int_pat_id;

	    -- Deleting pattern record
	    DELETE FROM igs_ps_sch_pat_int WHERE int_pat_id=rec_pat.int_pat_id;

	    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_CD' )
					  || '           : ' || rec_pat.unit_cd );
	    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_VER_NUM' )
					  || ' : ' || TO_CHAR (rec_pat.version_number) );
	    fnd_file.put_line ( fnd_file.LOG, ' ' );

	  END LOOP;

	  IF NOT l_c_pat_exists THEN
	    fnd_file.put_line ( fnd_file.LOG,'No pattern record to be purged' );
	    fnd_file.put_line(fnd_file.log,' ');
	  END IF;


          /********************** Purging the header Records***************************/
          FOR rec_header IN c_header LOOP

	     -- Deleting transaction header record
	     DELETE FROM igs_ps_sch_hdr_int_all WHERE transaction_id=rec_header.transaction_id;

	  END LOOP;


        END IF;

	IF l_c_occurrence_exists=FALSE AND l_c_section_exists=FALSE AND l_c_pat_exists=FALSE THEN
	  fnd_file.put_line ( fnd_file.LOG,'No records to be purged for this teaching calendar' );
          fnd_file.put_line(fnd_file.log,' ');
	END IF;


END purge_schd_record;


FUNCTION get_enrollment_max(
                           p_n_uoo_id IN NUMBER
                           ) RETURN NUMBER AS

/**********************************************************************
  Created By       : jbegum

  Date Created On  : 24-Apr-2003

  Purpose          : Function to return maximum enrollment for a unit section

  Know limitations, enhancements or remarks

  Change History
  Who               When                             What
  (reverse chronological order - newest change first)
************************************************************************/

CURSOR c_enr_max( cp_n_uoo_id igs_ps_usec_lim_wlst.uoo_id%TYPE ) IS
SELECT enrollment_maximum
FROM   igs_ps_usec_lim_wlst
WHERE  uoo_id = cp_n_uoo_id;

l_n_enr_max igs_ps_usec_lim_wlst.enrollment_maximum%TYPE;

BEGIN

  OPEN c_enr_max(p_n_uoo_id);
  FETCH c_enr_max INTO l_n_enr_max;
  CLOSE c_enr_max;

  l_n_enr_max := NVL(l_n_enr_max,999999);

  RETURN l_n_enr_max;

END get_enrollment_max;

PROCEDURE log_messages ( p_msg_name IN VARCHAR2,
                         p_msg_val  IN VARCHAR2,
                         p_val      IN NUMBER
                       ) AS
/**********************************************************************
  Created By       : jbegum

  Date Created On  : 15-Apr-2003

  Purpose          : This procedure is private to this package body .
                     The procedure logs transferred information to the log file.

  Know limitations, enhancements or remarks

  Change History
  Who               When                             What
  (reverse chronological order - newest change first)
************************************************************************/

l_c_str VARCHAR2(50);

BEGIN

    FND_MESSAGE.SET_NAME('IGS','IGS_FI_CAL_BALANCES_LOG');
    FND_MESSAGE.SET_TOKEN('PARAMETER_NAME',p_msg_name);
    FND_MESSAGE.SET_TOKEN('PARAMETER_VAL' ,p_msg_val);
    FOR i IN 1..p_val LOOP
        l_c_str := l_c_str || ' ';
    END LOOP;
    FND_FILE.PUT_LINE(FND_FILE.LOG,l_c_str||FND_MESSAGE.GET);

END log_messages;

PROCEDURE log_teach_cal  (p_c_cal_type IN VARCHAR2,
                          p_n_ci_sequence_number IN NUMBER) AS
/**********************************************************************
  Created By       : jbegum

  Date Created On  : 15-Apr-2003

  Purpose          : To log alternate code of teaching calendar.

  Know limitations, enhancements or remarks

  Change History
  Who               When                             What
  (reverse chronological order - newest change first)
************************************************************************/

CURSOR c_alt_cd(cp_c_cal_type igs_ca_inst.cal_type%TYPE,cp_n_ci_sequence_number igs_ca_inst.sequence_number%TYPE) IS
SELECT alternate_code
FROM   igs_ca_inst
WHERE  cal_type = cp_c_cal_type
AND    sequence_number = cp_n_ci_sequence_number;

l_alt_code igs_ca_inst.alternate_code%TYPE;

BEGIN

  OPEN  c_alt_cd(p_c_cal_type,p_n_ci_sequence_number);
  FETCH c_alt_cd INTO l_alt_code;
  CLOSE c_alt_cd;

  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('TEACHING','CAL_CAT'),l_alt_code,3);

END log_teach_cal;

PROCEDURE log_usec_details  (p_c_unit_cd IN VARCHAR2,
                             p_n_version_number IN NUMBER,
                             p_c_location_description IN VARCHAR2,
                             p_c_unit_class IN VARCHAR2,
                             p_n_enrollment_maximum IN NUMBER) AS
/**********************************************************************
  Created By       : jbegum

  Date Created On  : 15-Apr-2003

  Purpose          : To log transferred unit section details

  Know limitations, enhancements or remarks

  Change History
  Who               When                             What
  (reverse chronological order - newest change first)
************************************************************************/

BEGIN

  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('UNIT_CD','LEGACY_TOKENS'),p_c_unit_cd,10);
  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('VERSION_NUMBER','IGS_PS_LOG_PARAMETERS'),p_n_version_number,10);
  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('LOC','IGS_FI_ACCT_ENTITIES'),p_c_location_description,10);
  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('UNIT_CLASS','LEGACY_TOKENS'),p_c_unit_class,10);
  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('ENROLLMENT_MAXIMUM','LEGACY_TOKENS'),p_n_enrollment_maximum,10);


END log_usec_details;

PROCEDURE log_usec_occurs   (p_c_trans_type IN VARCHAR2,
                             p_n_lead_instructor_id IN NUMBER,
                             p_usec_occur_rec IN igs_ps_usec_occurs_all%ROWTYPE,
                             p_c_call IN VARCHAR2) AS
/**********************************************************************
  Created By       : jbegum

  Date Created On  : 15-Apr-2003

  Purpose          : To log transferred unit section occurrences details

  Know limitations, enhancements or remarks

  Change History
  Who               When                             What
  (reverse chronological order - newest change first)
  sarakshi          12-Jan-2006  Bug#4926548, created cursors bld_desc,rom_desc and cur_lookup_meaning and used them appropriately
************************************************************************/

CURSOR c_ins_name(cp_n_lead_instructor_id igs_pe_person_base_v.person_id%TYPE) IS
SELECT first_name , last_name
FROM igs_pe_person_base_v
WHERE person_id = cp_n_lead_instructor_id;

rec_ins_name c_ins_name%ROWTYPE;
l_str VARCHAR2(1000);

CURSOR  bld_desc(cp_bld_code  igs_ad_building_all.building_id%TYPE) IS
SELECT  description
FROM    igs_ad_building_all
WHERE   building_id = cp_bld_code;

CURSOR  rom_desc(cp_rom_code  igs_ad_room_all.room_id%TYPE) IS
SELECT  description
FROM    igs_ad_room_all
WHERE   room_id = cp_rom_code;
l_sch_bld_desc igs_ad_building_all.description%TYPE;
l_sch_rom_desc igs_ad_room_all.description%TYPE;
l_ded_bld_desc igs_ad_building_all.description%TYPE;
l_ded_rom_desc igs_ad_room_all.description%TYPE;
l_prf_bld_desc igs_ad_building_all.description%TYPE;
l_prf_rom_desc igs_ad_room_all.description%TYPE;

CURSOR cur_lookup_meaning (cp_lookup_type igs_lookup_values.lookup_type%TYPE,
                           cp_lookup_code igs_lookup_values.lookup_code%TYPE) IS
SELECT meaning
FROM   igs_lookup_values
WHERE  lookup_type=cp_lookup_type
AND    lookup_code=cp_lookup_code;
l_prf_reg_desc igs_lookup_values.meaning%TYPE;
l_sch_status_desc igs_lookup_values.meaning%TYPE;

BEGIN

  OPEN  c_ins_name(p_n_lead_instructor_id);
  FETCH c_ins_name INTO rec_ins_name;
  CLOSE c_ins_name;

  IF p_usec_occur_rec.monday = 'Y' THEN
     l_str := igs_ps_validate_lgcy_pkg.get_lkup_meaning('MONDAY','DT_OFFSET_CONSTRAINT_TYPE')||' ';
  END IF;

  IF p_usec_occur_rec.tuesday = 'Y' THEN
     l_str := l_str || igs_ps_validate_lgcy_pkg.get_lkup_meaning('TUESDAY','DT_OFFSET_CONSTRAINT_TYPE')||' ';
  END IF;

  IF p_usec_occur_rec.wednesday = 'Y' THEN
     l_str := l_str || igs_ps_validate_lgcy_pkg.get_lkup_meaning('WEDNESDAY','DT_OFFSET_CONSTRAINT_TYPE')||' ';
  END IF;

  IF p_usec_occur_rec.thursday = 'Y' THEN
     l_str := l_str || igs_ps_validate_lgcy_pkg.get_lkup_meaning('THURSDAY','DT_OFFSET_CONSTRAINT_TYPE')||' ';
  END IF;

  IF p_usec_occur_rec.friday = 'Y' THEN
     l_str := l_str || igs_ps_validate_lgcy_pkg.get_lkup_meaning('FRIDAY','DT_OFFSET_CONSTRAINT_TYPE')||' ';
  END IF;

  IF p_usec_occur_rec.saturday = 'Y' THEN
     l_str := l_str || igs_ps_validate_lgcy_pkg.get_lkup_meaning('SATURDAY','DT_OFFSET_CONSTRAINT_TYPE')||' ';
  END IF;

  IF p_usec_occur_rec.sunday = 'Y' THEN
     l_str := l_str || igs_ps_validate_lgcy_pkg.get_lkup_meaning('SUNDAY','DT_OFFSET_CONSTRAINT_TYPE')||' ';
  END IF;

  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('USEC_OCCUR_ID','IGS_PS_LOG_PARAMETERS'),p_usec_occur_rec.unit_section_occurrence_id,20);
  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('TRANSACTION_TYPE','IGS_PS_LOG_PARAMETERS'),p_c_trans_type,20);

  OPEN cur_lookup_meaning('SCHEDULE_TYPE',p_usec_occur_rec.schedule_status);
  FETCH cur_lookup_meaning INTO l_sch_status_desc;
  CLOSE cur_lookup_meaning;
  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('SCHEDULE_STATUS','IGS_PS_LOG_PARAMETERS'),l_sch_status_desc,20);

  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('USEC_OCCUR_DATES','IGS_PS_LOG_PARAMETERS'),
               TO_CHAR(p_usec_occur_rec.start_date,'DD MON YYYY')||' - '||TO_CHAR(p_usec_occur_rec.end_date,'DD MON YYYY'),20);
  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('TBA_IND','IGS_PS_LOG_PARAMETERS'),NVL(p_usec_occur_rec.to_be_announced,'N'),20);
  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('DAYS','IGS_PS_PROGRAM_LENGTH_MESR'),l_str,20);
  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('TIME','IGS_PS_LOG_PARAMETERS'),
               TO_CHAR(p_usec_occur_rec.start_time,'HH24:MIam')||' - '||TO_CHAR(p_usec_occur_rec.end_time,'HH24:MIam'),20);
  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('INSTRUCTOR_NAME','IGS_AS_ADV_SEARCH'),rec_ins_name.first_name||' '||rec_ins_name.last_name,20);

  -- Following transferred information is printed in log file if procedure log_usec_occurs is called from
  -- Initiate Scheduling Unit Section Occurrence process
  IF p_c_call = 'I' THEN
     OPEN cur_lookup_meaning('IGS_OR_LOC_REGION',p_usec_occur_rec.preferred_region_code);
     FETCH cur_lookup_meaning INTO l_prf_reg_desc;
     CLOSE cur_lookup_meaning;
     log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('IGSPS130-CG$TABPAGE_2','GE_CFG_TAB'),l_prf_reg_desc,20);
  END IF;

  OPEN bld_desc(p_usec_occur_rec.building_code);
  FETCH bld_desc INTO l_sch_bld_desc;
  CLOSE bld_desc;

  OPEN rom_desc(p_usec_occur_rec.room_code);
  FETCH rom_desc INTO l_sch_rom_desc;
  CLOSE rom_desc;


  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('SCHEDULED_BLD','IGS_PS_LOG_PARAMETERS'),l_sch_bld_desc,20);
  log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('SCHEDULED_ROOM','IGS_PS_LOG_PARAMETERS'),l_sch_rom_desc,20);

  -- Following transferred information is printed in log file if procedure log_usec_occurs is called from
  -- Initiate Scheduling Unit Section Occurrence process
  IF p_c_call = 'I' THEN
    OPEN bld_desc(p_usec_occur_rec.dedicated_building_code);
    FETCH bld_desc INTO l_ded_bld_desc;
    CLOSE bld_desc;

    OPEN rom_desc(p_usec_occur_rec.dedicated_room_code);
    FETCH rom_desc INTO l_ded_rom_desc;
    CLOSE rom_desc;
    log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('DEDICATED_BLD','IGS_PS_LOG_PARAMETERS'),l_ded_bld_desc,20);
    log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('DEDICATED_ROOM','IGS_PS_LOG_PARAMETERS'),l_ded_rom_desc,20);

    OPEN bld_desc(p_usec_occur_rec.preferred_building_code);
    FETCH bld_desc INTO l_prf_bld_desc;
    CLOSE bld_desc;

    OPEN rom_desc(p_usec_occur_rec.preferred_room_code);
    FETCH rom_desc INTO l_prf_rom_desc;
    CLOSE rom_desc;
    log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('PREFERRED_BLD','IGS_PS_LOG_PARAMETERS'),l_prf_bld_desc,20);
    log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('PREFERRED_ROOM','IGS_PS_LOG_PARAMETERS'),l_prf_rom_desc,20);
  END IF;

  -- Following transferred information is printed in log file if procedure log_usec_occurs is called from
  -- Get Interface Scheduled data process
  IF p_c_call = 'G' THEN
     log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('ERROR_TEXT','IGS_PS_LOG_PARAMETERS'),p_usec_occur_rec.error_text,20);
  END IF;

END log_usec_occurs;

FUNCTION get_alternate_code (p_c_cal_type IN VARCHAR2,
                              p_n_seq_num IN NUMBER)RETURN VARCHAR2 AS

  CURSOR c_alt_code (cp_c_cal_type igs_ca_inst_all.cal_type%TYPE, cp_n_seq_num igs_ca_inst_all.sequence_number%TYPE) IS
    SELECT alternate_code
    FROM   IGS_CA_INST_ALL
    WHERE  cal_type =  cp_c_cal_type
    AND    sequence_number = cp_n_seq_num;

  l_c_alt_code IGS_CA_INST_ALL.alternate_code%TYPE;

BEGIN
  OPEN  c_alt_code(p_c_cal_type,p_n_seq_num) ;
  FETCH c_alt_code INTO l_c_alt_code;
  CLOSE c_alt_code;
  RETURN l_c_alt_code;
END get_alternate_code;

  PROCEDURE update_occurrence_status(
  p_unit_section_occurrence_id IN NUMBER,
  p_scheduled_status IN VARCHAR2,
  p_cancel_flag IN VARCHAR2
  ) IS
/**********************************************************************
  Created By       : sarakshi

  Date Created On  : 12-May-2005

  Purpose          : To update the schedule status to 'USER_UPDATE'

  Know limitations, enhancements or remarks

  Change History
  Who               When                             What
  (reverse chronological order - newest change first)
************************************************************************/
  CURSOR c_occurs IS
  SELECT uso.*,uso.ROWID
  FROM igs_ps_usec_occurs_all uso
  WHERE unit_section_occurrence_id=p_unit_section_occurrence_id;
  l_usec_occurs_rec c_occurs%ROWTYPE;

  BEGIN
          OPEN c_occurs;
	  FETCH c_occurs INTO l_usec_occurs_rec;
	  CLOSE c_occurs;

          igs_ps_usec_occurs_pkg.update_row (
           x_rowid                             => l_usec_occurs_rec.rowid,
           x_unit_section_occurrence_id        => l_usec_occurs_rec.unit_section_occurrence_id,
           x_uoo_id                            => l_usec_occurs_rec.uoo_id,
           x_monday                            => l_usec_occurs_rec.monday,
           x_tuesday                           => l_usec_occurs_rec.tuesday,
           x_wednesday                         => l_usec_occurs_rec.wednesday,
           x_thursday                          => l_usec_occurs_rec.thursday,
           x_friday                            => l_usec_occurs_rec.friday,
           x_saturday                          => l_usec_occurs_rec.saturday,
           x_sunday                            => l_usec_occurs_rec.sunday,
           x_start_time                        => l_usec_occurs_rec.start_time,
           x_end_time                          => l_usec_occurs_rec.end_time,
           x_building_code                     => l_usec_occurs_rec.building_code,
           x_room_code                         => l_usec_occurs_rec.room_code,
           x_schedule_status                   => p_scheduled_status,
           x_status_last_updated               => l_usec_occurs_rec.status_last_updated,
           x_instructor_id                     => l_usec_occurs_rec.instructor_id,
           X_attribute_category                => l_usec_occurs_rec.attribute_category,
           X_attribute1                        => l_usec_occurs_rec.attribute1,
           X_attribute2                        => l_usec_occurs_rec.attribute2,
           X_attribute3                        => l_usec_occurs_rec.attribute3,
           X_attribute4                        => l_usec_occurs_rec.attribute4,
           X_attribute5                        => l_usec_occurs_rec.attribute5,
           X_attribute6                        => l_usec_occurs_rec.attribute6,
           X_attribute7                        => l_usec_occurs_rec.attribute7,
           X_attribute8                        => l_usec_occurs_rec.attribute8,
           X_attribute9                        => l_usec_occurs_rec.attribute9,
           X_attribute10                       => l_usec_occurs_rec.attribute10,
           X_attribute11                       => l_usec_occurs_rec.attribute11,
           X_attribute12                       => l_usec_occurs_rec.attribute12,
           X_attribute13                       => l_usec_occurs_rec.attribute13,
           X_attribute14                       => l_usec_occurs_rec.attribute14,
           X_attribute15                       => l_usec_occurs_rec.attribute15,
           X_attribute16                       => l_usec_occurs_rec.attribute16,
           X_attribute17                       => l_usec_occurs_rec.attribute17,
           X_attribute18                       => l_usec_occurs_rec.attribute18,
           X_attribute19                       => l_usec_occurs_rec.attribute19,
           X_attribute20                       => l_usec_occurs_rec.attribute20,
           x_error_text                        => l_usec_occurs_rec.error_text,
           x_mode                              => 'R',
           X_start_date                        => l_usec_occurs_rec.start_date,
           X_end_date                          => l_usec_occurs_rec.end_date,
           X_to_be_announced                   => l_usec_occurs_rec.to_be_announced,
           x_dedicated_building_code           => l_usec_occurs_rec.dedicated_building_code,
           x_dedicated_room_code               => l_usec_occurs_rec.dedicated_room_code,
           x_preferred_building_code           => l_usec_occurs_rec.preferred_building_code,
           x_preferred_room_code               => l_usec_occurs_rec.preferred_room_code,
           x_inst_notify_ind                   => l_usec_occurs_rec.inst_notify_ind,
           x_notify_status                     => l_usec_occurs_rec.notify_status,
           x_preferred_region_code             => l_usec_occurs_rec.preferred_region_code,
           x_no_set_day_ind                    => l_usec_occurs_rec.no_set_day_ind,
           x_cancel_flag                       => p_cancel_flag,
 	   x_occurrence_identifier             => l_usec_occurs_rec.occurrence_identifier,
           x_abort_flag                        => l_usec_occurs_rec.abort_flag
         );

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','prgp_upd_usec_dtls:igs_ps_usec_schedule');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END;

END igs_ps_usec_schedule;

/
