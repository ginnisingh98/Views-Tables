--------------------------------------------------------
--  DDL for Package Body IGS_PS_CAL_RSR_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_CAL_RSR_VAL" as
/* $Header: IGSPS78B.pls 120.2 2006/01/24 00:37:47 sarakshi ship $ */

  ------------------------------------------------------------------
  --Created by  : pradhakr, Oracle IDC
  --Date created:
  --
  --Purpose: Package Body contains code for procedures/Functions defined in
  --         package specification . Also body includes Functions/Procedures
  --         private to it .
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  -- Who         When            What
  --sarakshi    25-Nov-2003      Bug#3191862, created local procedure update_unit_version and modified procedure update_enroll_offer_unit
  --sarakshi     02-sep-2003     Enh#3052452,removed the reference of the columnsup_unit_allowed_ind and sub_unit_allowed_ind
  --vvutukur   05-Aug-2003       Enh#3045069.PSP Enh Build. Modified del_reserved_seating.
  -- sarakshi    10-Apr-2003     Bug#2550388, modified procedure del_reserved_seating to replace hard coded log messages with lookup values
  -- shtatiko	 30-OCT-2002	 Modified calles to igs_ps_unit_ver_pkg.update_row to incorporate addition of
  --				 auditable_ind, audit_permission_ind, max_auditors_allowed columns.
  --				 Added auditable_ind, audit_permission_ind to update_row call of igs_ps_unit_ofr_opt_pkg.
  --				 This has been done as part of Bug# 2636716.
  -- jbegum      17 April 02     As part of bug fix of bug #2322290 and bug#2250784
  --                             Removed the following 4 columns
  --                             BILLING_CREDIT_POINTS,BILLING_HRS,FIN_AID_CP,FIN_AID_HRS
  --                             from calls to IGS_PS_UNIT_VER_PKG.
  -- prraj       14-Feb-2002     Added column NON_STD_USEC_IND to the tbh calls for
  --                             pkg IGS_PS_UNIT_OFR_OPT_PKG (Bug# 2224366)
  -- ddey        01-FEB-2002     Added columns anon_unit_grading_ind  and anon_assess_grading_ind in the calls
  --                             for the package IGS_PS_UNIT_OFR_OPT_PKG and IGS_PS_UNIT_VER_PKG
  -- ayedubat    20/6/2001       Added one new procedure ,update_enroll_offer_unit
  -- msrinivi    16 Aug,2001     Added new col rev_account_cd to igs_ps_unit_ver_pkg,igs_ps_unit_ofr_opt_pkg
  --                             TBH calls
  -------------------------------------------------------------------

   PROCEDURE log_messages ( p_msg_name  VARCHAR2 ,
                           p_msg_val   VARCHAR2
                         ) IS
  ------------------------------------------------------------------
  --Created by  : pradhakr, Oracle IDC
  --Date created: 23/May/2001
  --
  --Purpose: This procedure is private to this package body .
  --         The procedure logs all the parameter values ,
  --         table values
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  BEGIN
    FND_MESSAGE.SET_NAME('IGS','IGS_PS_DEL_PRIORITY_LOG');
    FND_MESSAGE.SET_TOKEN('PARAMETER_NAME',p_msg_name);
    FND_MESSAGE.SET_TOKEN('PARAMETER_VAL' ,p_msg_val) ;
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
  END log_messages ;

  PROCEDURE del_reserved_seating ( errbuf           OUT NOCOPY VARCHAR2,
                           	   retcode          OUT NOCOPY NUMBER,
                           	   p_teach_prd      IN  VARCHAR2,
 			   	   p_org_unit_cd    IN  VARCHAR2,
 			   	   p_unit_cd 	    IN  igs_ps_unit_ofr_opt.unit_cd%TYPE,
 			   	   p_version_number IN  igs_ps_unit_ofr_opt.version_number%TYPE,
			  	   p_location_cd    IN  igs_ps_unit_ofr_opt.location_cd%TYPE,
			   	   p_unit_class     IN  igs_ps_unit_ofr_opt.unit_class%TYPE,
			   	   p_unit_mode      IN  igs_ps_unit_ofr_opt_v.unit_mode%TYPE,
			   	   p_org_id 	    IN  NUMBER
                          	 ) IS
------------------------------------------------------------------
  --Created by  : pradhakr, Oracle IDC
  --Date created: 23/May/2001
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sarakshi   12-Jan-2006      Bug#4926548, modified cursor cur_uoo1 from performance perspective.
  --sommukhe   27-JUL-2005      Bug#4344483,Modified the call to igs_ps_unit_ofr_opt_pkg.update_row to include new parameter abort_flag.
  --sarakshi   10-Sep-2004      Enh#3882537, modifed cursor cur_uoo1 to exclude INACTIVE units and rearranged the cursor.
  --sarakshi   22-sep-2003      Enh#3052452,added column relation-type,sup_uoo_id,default_enroll_flag in the call of to igs_ps_unit_ofr_opt_pkg.update_row
  --vvutukur   05-Aug-2003      Enh#3045069.PSP Enh Build. Modified the call to igs_ps_unit_ofr_opt_pkg.update_row to include
  --                            new parameter not_multiple_section_flag.
  --sarakshi   10_apr-2003      Bug#2550388, modified procedure to replace hard coded log message with
  --                            lookups values
  --Pradhakr   23-Jul-2001	Added three new columns in he TBH call
  --				as part of Enrollment Build process.
  --				(Enh Bug# 1832130)
  -------------------------------------------------------------------

  l_calendar_type igs_ps_unit_ofr_opt.cal_type%TYPE;
  l_sequence_number igs_ps_unit_ofr_opt.ci_sequence_number%TYPE;

  CURSOR cur_uoo1( p_cal_type VARCHAR2,
  		 p_ci_sequence_number NUMBER) IS
  SELECT uoov.*,uoov.rowid row_id,uc.unit_mode,loc.description location_description
  FROM igs_ps_unit_ofr_opt_all uoov,igs_as_unit_class_all uc, igs_ad_location_all loc,
       igs_ps_unit_ver_all uv,
       igs_ps_unit_stat st
  WHERE uoov.cal_type = p_cal_type AND
        uoov.ci_sequence_number = p_ci_sequence_number AND
        (uoov.owner_org_unit_cd = p_org_unit_cd OR p_org_unit_cd IS NULL) AND
        (uoov.unit_cd = p_unit_cd OR p_unit_cd IS NULL) AND
        (uoov.location_cd = p_location_cd OR p_location_cd IS NULL) AND
        (uoov.unit_class = p_unit_class OR p_unit_class IS NULL) AND
        (uc.unit_mode = p_unit_mode OR p_unit_mode IS NULL) AND
        (uoov.version_number = p_version_number OR p_version_number IS NULL) AND
	uoov.unit_section_status IN ('PLANNED','CANCELLED','NOT_OFFERED') AND
        uoov.location_cd=loc.location_cd AND
	uoov.unit_class=uc.unit_class   AND
	uoov.unit_cd=uv.unit_cd AND
        uoov.version_number=uv.version_number AND
        uv.unit_status=st.unit_status AND
        st.s_unit_status <>'INACTIVE';

  CURSOR cur_check_enr (cp_uoo_id igs_en_su_attempt_all.uoo_id%TYPE) IS
  SELECT 'X'
  FROM igs_en_su_attempt_all
  WHERE uoo_id= cp_uoo_id
  AND ROWNUM <2;
  l_c_var VARCHAR2(1);

  my_continue EXCEPTION;

  CURSOR cur_priority (l_uoo_id NUMBER) IS
  SELECT * FROM igs_ps_rsv_usec_pri_v
  WHERE uoo_id = l_uoo_id;

  CURSOR cur_preference(l_rsv_usec_pri_id igs_ps_rsv_usec_pri_v.rsv_usec_pri_id%TYPE) IS
  SELECT a.rowid FROM igs_ps_rsv_usec_prf a
  WHERE a.rsv_usec_pri_id = l_rsv_usec_pri_id;

  l_cur_priority_row cur_priority%ROWTYPE;
  l_cur_preference_row cur_preference%ROWTYPE;

  BEGIN
    -- Set the multiorg id
    igs_ge_gen_003.set_org_id(p_org_id);

    -- logs all the parameters
    log_messages(igs_fi_gen_gl.get_lkp_meaning('IGS_PS_LOG_PARAMETERS','TEACHING_PERIOD')||' : ',p_teach_prd);
    log_messages(igs_fi_gen_gl.get_lkp_meaning('LEGACY_TOKENS','ORG_UNIT_CD')||' : ',p_org_unit_cd);
    log_messages(igs_fi_gen_gl.get_lkp_meaning('LEGACY_TOKENS','UNIT_CD')||' : ',p_unit_cd);
    log_messages(igs_fi_gen_gl.get_lkp_meaning('LEGACY_TOKENS','UNIT_VER_NUM')||' : ',p_version_number);
    log_messages(igs_fi_gen_gl.get_lkp_meaning('ORG_STRUCTURE_TYPE','LOCATION')||' : ',p_location_cd);
    log_messages(igs_fi_gen_gl.get_lkp_meaning('LEGACY_TOKENS','UNIT_CLASS')||' : ',p_unit_class);
    log_messages(igs_fi_gen_gl.get_lkp_meaning('IGS_PS_LOG_PARAMETERS','UNIT_MODE')||' : ',p_unit_mode);
    FND_FILE.PUT_LINE(FND_FILE.LOG,NULL);
    FND_FILE.PUT_LINE(FND_FILE.LOG,NULL);

    -- Checking whether Organisation unit code or Unit code is present or not.
    -- If both the values are not available then it will terminate the process.

    IF ((p_org_unit_cd IS NULL) AND (p_unit_cd IS NULL) ) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_PS_ORG_OR_UNIT_MUST');
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION ;

    ELSE
      -- Extracting the values of Calendar type and sequence number
       l_calendar_type  := RTRIM(SUBSTR(p_teach_prd, 101, 10));
       l_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_teach_prd, 113, 8)));


       FOR r_cur_uoo IN cur_uoo1(l_calendar_type, l_sequence_number)
       LOOP
          BEGIN

	    OPEN cur_check_enr(r_cur_uoo.uoo_id);
	    FETCH cur_check_enr INTO l_c_var;
	    IF cur_check_enr%FOUND THEN
	      CLOSE cur_check_enr;
	      RAISE my_continue;
	    END IF;
	    CLOSE cur_check_enr;

	    -- Writing into the log file
	    log_messages(igs_fi_gen_gl.get_lkp_meaning('LEGACY_TOKENS','UNIT_CD')||' : ',r_cur_uoo.unit_cd);
	    log_messages(igs_fi_gen_gl.get_lkp_meaning('LEGACY_TOKENS','UNIT_VER_NUM')||' : ',r_cur_uoo.version_number);
	    log_messages(igs_fi_gen_gl.get_lkp_meaning('ORG_STRUCTURE_TYPE','LOCATION')||' : ',r_cur_uoo.location_description);
	    log_messages(igs_fi_gen_gl.get_lkp_meaning('LEGACY_TOKENS','UNIT_CLASS')||' : ',r_cur_uoo.unit_class);
	    log_messages(igs_fi_gen_gl.get_lkp_meaning('IGS_PS_LOG_PARAMETERS','UNIT_MODE')||' : ',r_cur_uoo.unit_mode);
	    FND_FILE.PUT_LINE(FND_FILE.LOG,NULL);


	    -- Updating Reserved Seating Allowed value to 'N'
	    -- Added auditable_ind and audit_permission_ind to the following call as part of Bug# 2636716 by shtatiko
	    igs_ps_unit_ofr_opt_pkg.update_row(x_rowid                     =>  r_cur_uoo.row_id,
					   x_unit_cd                       =>  r_cur_uoo.unit_cd,
					   x_version_number                =>  r_cur_uoo.version_number,
					   x_cal_type                      =>  r_cur_uoo.cal_type,
					   x_ci_sequence_number            =>  r_cur_uoo.ci_sequence_number,
					   x_location_cd                   =>  r_cur_uoo.location_cd,
					   x_unit_class                    =>  r_cur_uoo.unit_class,
					   x_uoo_id                        =>  r_cur_uoo.uoo_id,
					   x_ivrs_available_ind            =>  r_cur_uoo.ivrs_available_ind,
					   x_call_number                   =>  r_cur_uoo.call_number,
					   x_unit_section_status           =>  r_cur_uoo.unit_section_status,
					   x_unit_section_start_date       =>  r_cur_uoo.unit_section_start_date,
					   x_unit_section_end_date         =>  r_cur_uoo.unit_section_end_date,
					   x_enrollment_actual             =>  r_cur_uoo.enrollment_actual,
					   x_waitlist_actual               =>  r_cur_uoo.waitlist_actual,
					   x_offered_ind                   =>  r_cur_uoo.offered_ind,
					   x_state_financial_aid           =>  r_cur_uoo.state_financial_aid,
					   x_grading_schema_prcdnce_ind    =>  r_cur_uoo.grading_schema_prcdnce_ind,
					   x_federal_financial_aid         =>  r_cur_uoo.federal_financial_aid,
					   x_unit_quota                    =>  r_cur_uoo.unit_quota,
					   x_unit_quota_reserved_places    =>  r_cur_uoo.unit_quota_reserved_places,
					   x_institutional_financial_aid   =>  r_cur_uoo.institutional_financial_aid,
					   x_grading_schema_cd             =>  r_cur_uoo.grading_schema_cd,
					   x_gs_version_number             =>  r_cur_uoo.gs_version_number,
					   x_unit_contact                  =>  r_cur_uoo.unit_contact,
					   x_mode                          =>  'R',
					   x_ss_enrol_ind                  =>  r_cur_uoo.ss_enrol_ind,
					   x_owner_org_unit_cd             =>  r_cur_uoo.owner_org_unit_cd,
					   x_attendance_required_ind       =>  r_cur_uoo.attendance_required_ind,
					   x_reserved_seating_allowed      =>  'N',
					   x_ss_display_ind                =>  r_cur_uoo.ss_display_ind,
					   x_special_permission_ind        =>  r_cur_uoo.special_permission_ind,
					   x_dir_enrollment	         =>  r_cur_uoo.dir_enrollment,
					   x_enr_from_wlst	         =>  r_cur_uoo.enr_from_wlst,
					   x_inq_not_wlst		         =>  r_cur_uoo.inq_not_wlst,
					   x_rev_account_cd                =>  r_cur_uoo.rev_account_cd,
					   x_anon_unit_grading_ind         =>  r_cur_uoo.anon_unit_grading_ind,
					   x_anon_assess_grading_ind       =>  r_cur_uoo.anon_assess_grading_ind,
					   x_non_std_usec_ind              =>  r_cur_uoo.non_std_usec_ind,
					   x_auditable_ind		 =>  r_cur_uoo.auditable_ind,
					   x_audit_permission_ind		 =>  r_cur_uoo.audit_permission_ind,
					   x_not_multiple_section_flag     =>  r_cur_uoo.not_multiple_section_flag,
					   x_sup_uoo_id                    =>  r_cur_uoo.sup_uoo_id,
					   x_relation_type                 =>  r_cur_uoo.relation_type,
					   x_default_enroll_flag           =>  r_cur_uoo.default_enroll_flag,
					   x_abort_flag                    =>  r_cur_uoo.abort_flag
					);

	    -- Deleting all the Priority and Preference

	    FOR  pri IN  cur_priority(r_cur_uoo.uoo_id)  LOOP
		FOR pref IN cur_preference(pri.rsv_usec_pri_id) LOOP
		  igs_ps_rsv_usec_prf_pkg.delete_row(
			  x_rowid=>pref.rowid
			  );
		END LOOP;
		  igs_ps_rsv_usec_pri_pkg.delete_row(
			  x_rowid=>pri.row_id
			  );
	    END LOOP;

          EXCEPTION
	     WHEN my_continue THEN
                NULL; -- continue with the next record
	  END;
	END LOOP;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
		retcode := 2;
		errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

 END del_reserved_seating;

 PROCEDURE update_unit_version ( p_unit_cd                     igs_ps_unit_ver_all.unit_cd%TYPE ,
                                 p_version_number              igs_ps_unit_ver_all.version_number%TYPE ,
                                 p_cal_type_enrol_load_cal     igs_ps_unit_ver_all.cal_type_enrol_load_cal%TYPE ,
				 p_sequence_num_enrol_load_cal igs_ps_unit_ver_all.sequence_num_enrol_load_cal%TYPE,
				 p_cal_type_offer_load_cal     igs_ps_unit_ver_all.cal_type_offer_load_cal%TYPE,
				 p_sequence_num_offer_load_cal igs_ps_unit_ver_all.sequence_num_offer_load_cal%TYPE
				 ) IS
   ------------------------------------------------------------------
   --Created by  : sarakshi, Oracle IDC
   --Date created: 25-Nov-2003
   --
   --Purpose: To update the last enrolled and offered calendar for a unit version.
   --
   --
   --
   --Known limitations/enhancements and/or remarks:
   --
   --Change History:
   --Who         When            What
   --sarakshi    30-Apr-2004     Bug#3568858, Added columns ovrd_wkld_val_flag, workload_val_code in the TBH call igs_ps_unit_ver_pkg.update_row
   -------------------------------------------------------------------
   CURSOR cur_unit_ver  IS
   SELECT *
   FROM   igs_ps_unit_ver
   WHERE  unit_cd = p_unit_cd
   AND    version_number = p_version_number;
   cur_unit_ver_rec cur_unit_ver%ROWTYPE;

 BEGIN

   --Update the unit version record
   OPEN cur_unit_ver;
   FETCH cur_unit_ver INTO cur_unit_ver_rec;

   igs_ps_unit_ver_pkg.update_row (
     X_Mode                              => 'R'                                          ,
     X_RowId                             => cur_unit_ver_rec.Row_Id                      ,
     X_Unit_Cd                           => cur_unit_ver_rec.Unit_Cd                     ,
     X_Version_Number                    => cur_unit_ver_rec.Version_Number              ,
     X_Start_Dt                          => cur_unit_ver_rec.Start_Dt                    ,
     X_Review_Dt                         => cur_unit_ver_rec.Review_Dt                   ,
     X_Expiry_Dt                         => cur_unit_ver_rec.Expiry_Dt                   ,
     X_End_Dt                            => cur_unit_ver_rec.End_Dt                      ,
     X_Unit_Status                       => cur_unit_ver_rec.Unit_Status                 ,
     X_Title                             => cur_unit_ver_rec.Title                       ,
     X_Short_Title                       => cur_unit_ver_rec.Short_Title                 ,
     X_Title_Override_Ind                => cur_unit_ver_rec.Title_Override_Ind          ,
     X_Abbreviation                      => cur_unit_ver_rec.Abbreviation                ,
     X_Unit_Level                        => cur_unit_ver_rec.Unit_Level                  ,
     X_Credit_Point_Descriptor           => cur_unit_ver_rec.Credit_Point_Descriptor     ,
     X_Enrolled_Credit_Points            => cur_unit_ver_rec.Enrolled_Credit_Points      ,
     X_Points_Override_Ind               => cur_unit_ver_rec.Points_Override_Ind         ,
     X_Supp_Exam_Permitted_Ind           => cur_unit_ver_rec.Supp_Exam_Permitted_Ind     ,
     X_Coord_Person_Id                   => cur_unit_ver_rec.Coord_Person_Id             ,
     X_Owner_Org_Unit_Cd                 => cur_unit_ver_rec.Owner_Org_Unit_Cd           ,
     X_Owner_Ou_Start_Dt                 => cur_unit_ver_rec.Owner_Ou_Start_Dt           ,
     X_Award_Course_Only_Ind             => cur_unit_ver_rec.Award_Course_Only_Ind       ,
     X_Research_Unit_Ind                 => cur_unit_ver_rec.Research_Unit_Ind           ,
     X_Industrial_Ind                    => cur_unit_ver_rec.Industrial_Ind              ,
     X_Practical_Ind                     => cur_unit_ver_rec.Practical_Ind               ,
     X_Repeatable_Ind                    => cur_unit_ver_rec.Repeatable_Ind              ,
     X_Assessable_Ind                    => cur_unit_ver_rec.Assessable_Ind              ,
     X_Achievable_Credit_Points          => cur_unit_ver_rec.Achievable_Credit_Points    ,
     X_Points_Increment                  => cur_unit_ver_rec.Points_Increment            ,
     X_Points_Min                        => cur_unit_ver_rec.Points_Min                  ,
     X_Points_Max                        => cur_unit_ver_rec.Points_Max                  ,
     X_Unit_Int_Course_Level_Cd          => cur_unit_ver_rec.Unit_Int_Course_Level_Cd    ,
     X_Subtitle                          => NULL                                         ,
     X_Subtitle_Modifiable_Flag          => cur_unit_ver_rec.Subtitle_Modifiable_Flag    ,
     X_Approval_Date                     => cur_unit_ver_rec.Approval_Date               ,
     X_Lecture_Credit_Points             => cur_unit_ver_rec.Lecture_Credit_Points       ,
     X_Lab_Credit_Points                 => cur_unit_ver_rec.Lab_Credit_Points           ,
     X_Other_Credit_Points               => cur_unit_ver_rec.Other_Credit_Points         ,
     X_Clock_Hours                       => cur_unit_ver_rec.Clock_Hours                 ,
     X_Work_Load_Cp_Lecture              => cur_unit_ver_rec.Work_Load_Cp_Lecture        ,
     X_Work_Load_Cp_Lab                  => cur_unit_ver_rec.Work_Load_Cp_Lab            ,
     X_Continuing_Education_Units        => cur_unit_ver_rec.Continuing_Education_Units  ,
     X_Enrollment_Expected               => cur_unit_ver_rec.Enrollment_Expected         ,
     X_Enrollment_Minimum                => cur_unit_ver_rec.Enrollment_Minimum          ,
     X_Enrollment_Maximum                => cur_unit_ver_rec.Enrollment_Maximum          ,
     X_Advance_Maximum                   => cur_unit_ver_rec.Advance_Maximum             ,
     X_State_Financial_Aid               => cur_unit_ver_rec.State_Financial_Aid         ,
     X_Federal_Financial_Aid             => cur_unit_ver_rec.Federal_Financial_Aid       ,
     X_Institutional_Financial_Aid       => cur_unit_ver_rec.Institutional_Financial_Aid ,
     X_Same_Teaching_Period              => cur_unit_ver_rec.Same_Teaching_Period        ,
     X_Max_Repeats_For_Credit            => cur_unit_ver_rec.Max_Repeats_For_Credit      ,
     X_Max_Repeats_For_Funding           => cur_unit_ver_rec.Max_Repeats_For_Funding     ,
     X_Max_Repeat_Credit_Points          => cur_unit_ver_rec.Max_Repeat_Credit_Points    ,
     X_Same_Teach_Period_Repeats_Cp      => cur_unit_ver_rec.Same_Teach_Period_Repeats_Cp,
     X_Same_Teach_Period_Repeats         => cur_unit_ver_rec.Same_Teach_Period_Repeats   ,
     X_Attribute_Category                => cur_unit_ver_rec.Attribute_Category          ,
     X_Attribute1                        => cur_unit_ver_rec.Attribute1                  ,
     X_Attribute2                        => cur_unit_ver_rec.Attribute2                  ,
     X_Attribute3                        => cur_unit_ver_rec.Attribute3                  ,
     X_Attribute4                        => cur_unit_ver_rec.Attribute4                  ,
     X_Attribute5                        => cur_unit_ver_rec.Attribute5                  ,
     X_Attribute6                        => cur_unit_ver_rec.Attribute6                  ,
     X_Attribute7                        => cur_unit_ver_rec.Attribute7                  ,
     X_Attribute8                        => cur_unit_ver_rec.Attribute8                  ,
     X_Attribute9                        => cur_unit_ver_rec.Attribute9                  ,
     X_Attribute10                       => cur_unit_ver_rec.Attribute10                 ,
     X_Attribute11                       => cur_unit_ver_rec.Attribute11                 ,
     X_Attribute12                       => cur_unit_ver_rec.Attribute12                 ,
     X_Attribute13                       => cur_unit_ver_rec.Attribute13                 ,
     X_Attribute14                       => cur_unit_ver_rec.Attribute14                 ,
     X_Attribute15                       => cur_unit_ver_rec.Attribute15                 ,
     X_Attribute16                       => cur_unit_ver_rec.Attribute16                 ,
     X_Attribute17                       => cur_unit_ver_rec.Attribute17                 ,
     X_Attribute18                       => cur_unit_ver_rec.Attribute18                 ,
     X_Attribute19                       => cur_unit_ver_rec.Attribute19                 ,
     X_Attribute20                       => cur_unit_ver_rec.Attribute20                 ,
     X_Subtitle_Id                       => cur_unit_ver_rec.Subtitle_Id                 ,
     X_Work_Load_Other                   => cur_unit_ver_rec.Work_Load_Other             ,
     X_Contact_Hrs_Lecture               => cur_unit_ver_rec.Contact_Hrs_Lecture         ,
     X_Contact_Hrs_Lab                   => cur_unit_ver_rec.Contact_Hrs_Lab             ,
     X_Contact_Hrs_Other                 => cur_unit_ver_rec.Contact_Hrs_Other           ,
     X_Non_Schd_Required_Hrs             => cur_unit_ver_rec.Non_Schd_Required_Hrs       ,
     X_Exclude_From_Max_Cp_Limit         => cur_unit_ver_rec.Exclude_From_Max_Cp_Limit   ,
     X_Record_Exclusion_Flag             => cur_unit_ver_rec.Record_Exclusion_Flag       ,
     X_Ss_Display_Ind                    => cur_unit_ver_rec.Ss_Display_Ind              ,
     X_Cal_Type_Enrol_Load_Cal           => NVL(p_cal_type_enrol_load_cal,cur_unit_ver_rec.cal_type_enrol_load_cal) ,
     X_Sequence_Num_Enrol_Load_Cal       => NVL(p_sequence_num_enrol_load_cal,cur_unit_ver_rec.sequence_num_enrol_load_cal) ,
     X_Cal_Type_Offer_Load_Cal           => NVL(p_cal_type_offer_load_cal,cur_unit_ver_rec.cal_type_offer_load_cal) ,
     X_Sequence_Num_Offer_Load_Cal       => NVL(p_sequence_num_offer_load_cal,cur_unit_ver_rec.sequence_num_offer_load_cal) ,
     X_Curriculum_Id                     => cur_unit_ver_rec.Curriculum_Id               ,
     X_Override_Enrollment_Max           => cur_unit_ver_rec.Override_Enrollment_Max     ,
     X_Rpt_Fmly_Id                       => cur_unit_ver_rec.Rpt_Fmly_Id                 ,
     X_Unit_Type_Id                      => cur_unit_ver_rec.Unit_Type_Id                ,
     X_Special_Permission_Ind            => cur_unit_ver_rec.Special_Permission_Ind      ,
     x_ivr_enrol_ind			 => cur_unit_ver_rec.ivr_enrol_ind	          ,
     x_ss_enrol_ind                      => cur_unit_ver_rec.ss_enrol_ind,
     x_rev_account_cd                    => cur_unit_ver_rec.rev_account_cd,
     x_claimable_hours                   => cur_unit_ver_rec.claimable_hours ,
     x_anon_unit_grading_ind             => cur_unit_ver_rec.anon_unit_grading_ind    ,
     x_anon_assess_grading_ind  	 => cur_unit_ver_rec.anon_assess_grading_ind ,
     x_auditable_ind  			 => cur_unit_ver_rec.auditable_ind ,
     x_audit_permission_ind  		 => cur_unit_ver_rec.audit_permission_ind ,
     x_max_auditors_allowed		 => cur_unit_ver_rec.max_auditors_allowed ,
     x_billing_credit_points		 => cur_unit_ver_rec.billing_credit_points,
     x_ovrd_wkld_val_flag                => cur_unit_ver_rec.ovrd_wkld_val_flag,
     x_workload_val_code                 => cur_unit_ver_rec.workload_val_code,
     x_billing_hrs                       => cur_unit_ver_rec.billing_hrs
   );

   CLOSE cur_unit_ver;

 END  update_unit_version;

 PROCEDURE update_enroll_offer_unit(errbuf  OUT NOCOPY VARCHAR2,
                                     retcode OUT NOCOPY NUMBER,
                                     p_org_id IN IGS_PS_UNIT_VER.ORG_ID%TYPE,
                                     p_load_calendar  IN VARCHAR2) IS
  ------------------------------------------------------------------
  --Created by  : ayedubat, Oracle IDC
  --Date created: 12/6/2001
  --
  --Purpose: To update the last enrolled and offered calendar for unit.
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sarakshi    12-Jul-2004     Bug#3729462, Added the predicate DELETE_FLAG to cursor cur_units
  --sarakshi    25-Nov-2003     Bug#3191862, Modified the cursors cur_units,cur_teach_to_load also moved the
  --                            updation in a local procedure and calling only once for a unit using local variable.
  --sarakshi    06-Nov-2003     Enh#3116171, Added billing_credit_points for igs_ps_unit_ver_pkg.update_row
  -------------------------------------------------------------------
  l_input_load_cal_type IGS_CA_INST_ALL.CAL_TYPE%TYPE;
  l_input_load_sequence_number IGS_CA_INST_ALL.SEQUENCE_NUMBER%TYPE;

  l_recent_teach_start_date IGS_CA_INST_ALL.START_DT%TYPE;

  CURSOR cur_load_to_teach( p_input_load_cal_type IGS_CA_INST_ALL.CAL_TYPE%TYPE,
                            p_input_load_sequence_number IGS_CA_INST_ALL.SEQUENCE_NUMBER%TYPE
                          )  IS
    SELECT teach_cal_type,
           teach_ci_sequence_number,
           teach_start_dt
    FROM   igs_ca_load_to_teach_v
    WHERE  load_cal_type = p_input_load_cal_type AND
           load_ci_sequence_number = p_input_load_sequence_number
    ORDER BY teach_start_dt DESC;
  cur_load_to_teach_rec cur_load_to_teach%ROWTYPE;

  CURSOR cur_units( p_input_load_cal_type IGS_CA_INST_ALL.CAL_TYPE%TYPE,
                    p_input_load_sequence_number IGS_CA_INST_ALL.SEQUENCE_NUMBER%TYPE ) IS
    SELECT DISTINCT uop.unit_cd,
           uop.version_number
    FROM   igs_ps_unit_ofr_pat uop , igs_ca_load_to_teach_v lteach ,igs_ps_unit_ver_all uv, igs_ps_unit_stat us
    WHERE  lteach.load_cal_type = p_input_load_cal_type AND
           lteach.load_ci_sequence_number = p_input_load_sequence_number AND
           uop.cal_type = lteach.teach_cal_type AND
           uop.ci_sequence_number = lteach.teach_ci_sequence_number AND
	   uop.unit_cd = uv.unit_cd AND
	   uop.version_number = uv.version_number AND
	   uv.unit_status = us.unit_status AND
	   us.s_unit_status <> 'INACTIVE' AND
	   uop.delete_flag='N';

  CURSOR cur_ps_unit_ofr_opt_enroll( p_unit_cd IGS_PS_UNIT_OFR_OPT_ALL.unit_cd%TYPE,
                                     p_version_number IGS_PS_UNIT_OFR_OPT_ALL.version_number%TYPE,
                                     p_start_date IGS_CA_INST_ALL.start_dt%TYPE ) IS
    SELECT uoov.cal_type,
           uoov.ci_sequence_number,
           ci.start_dt
    FROM   igs_ps_unit_ofr_opt uoov, igs_ca_inst ci
    WHERE  uoov.cal_type = ci.cal_type AND
           uoov.ci_sequence_number = ci.sequence_number AND
           uoov.enrollment_actual > 0  AND
           ci.start_dt <= p_start_date AND
           uoov.unit_cd = p_unit_cd    AND
           uoov.version_number = p_version_number
    ORDER BY ci.start_dt DESC;
  cur_ps_unit_ofr_opt_enroll_rec cur_ps_unit_ofr_opt_enroll%ROWTYPE;

    CURSOR cur_ps_unit_ofr_opt_offer( p_unit_cd IGS_PS_UNIT_OFR_OPT_ALL.unit_cd%TYPE,
                                      p_version_number IGS_PS_UNIT_OFR_OPT_ALL.version_number%TYPE,
                                      p_start_date IGS_CA_INST_ALL.start_dt%TYPE ) IS
    SELECT uoov.cal_type,
           uoov.ci_sequence_number,
           ci.start_dt
    FROM   igs_ps_unit_ofr_opt uoov, igs_ca_inst ci
    WHERE  uoov.cal_type = ci.cal_type AND
           uoov.ci_sequence_number = ci.sequence_number AND
           uoov.unit_section_status NOT IN ('PLANNED')  AND
           uoov.offered_ind = 'Y'  AND
           ci.start_dt <= p_start_date AND
           uoov.unit_cd = p_unit_cd    AND
           uoov.version_number = p_version_number
    ORDER BY ci.start_dt DESC;
  cur_ps_unit_ofr_opt_offer_rec cur_ps_unit_ofr_opt_offer%ROWTYPE;

  CURSOR cur_teach_to_load( p_teach_cal_type IGS_CA_INST_ALL.CAL_TYPE%TYPE,
                            p_teach_sequence_number IGS_CA_INST_ALL.SEQUENCE_NUMBER%TYPE ) IS
    SELECT load_cal_type,
           load_ci_sequence_number,
           load_start_dt
    FROM   igs_ca_teach_to_load_v
    WHERE  teach_cal_type = p_teach_cal_type AND
           teach_ci_sequence_number = p_teach_sequence_number
    ORDER BY load_start_dt DESC;
  cur_teach_to_load_rec cur_teach_to_load%ROWTYPE;

  CURSOR cur_unit_ver_enroll(p_unit_cd IGS_PS_UNIT_OFR_OPT_ALL.unit_cd%TYPE,
                             p_version_number IGS_PS_UNIT_OFR_OPT_ALL.version_number%TYPE) IS
    SELECT ci.start_dt start_date
    FROM   igs_ps_unit_ver uv,igs_ca_inst ci
    WHERE  uv.unit_cd = p_unit_cd   AND
           uv.version_number = p_version_number AND
           uv.cal_type_enrol_load_cal = ci.cal_type AND
           uv.sequence_num_enrol_load_cal = ci.sequence_number;
  cur_unit_ver_enroll_rec cur_unit_ver_enroll%ROWTYPE;

  CURSOR cur_unit_ver_offer(p_unit_cd IGS_PS_UNIT_OFR_OPT_ALL.unit_cd%TYPE,
                            p_version_number IGS_PS_UNIT_OFR_OPT_ALL.version_number%TYPE) IS
    SELECT ci.start_dt start_date
    FROM   igs_ps_unit_ver uv,igs_ca_inst ci
    WHERE  uv.unit_cd = p_unit_cd   AND
           uv.version_number = p_version_number AND
           uv.cal_type_offer_load_cal = ci.cal_type AND
           uv.sequence_num_offer_load_cal = ci.sequence_number;
  cur_unit_ver_offer_rec cur_unit_ver_offer%ROWTYPE;


  l_cal_type_enrol_load_cal     igs_ps_unit_ver_all.cal_type_enrol_load_cal%TYPE ;
  l_sequence_num_enrol_load_cal igs_ps_unit_ver_all.sequence_num_enrol_load_cal%TYPE;
  l_cal_type_offer_load_cal     igs_ps_unit_ver_all.cal_type_offer_load_cal%TYPE;
  l_sequence_num_offer_load_cal igs_ps_unit_ver_all.sequence_num_offer_load_cal%TYPE;


  BEGIN

    -- Set the multiorg id
    igs_ge_gen_003.set_org_id(p_org_id);

    -- Initialize the RetCode
    retcode := 0;

    -- Extracting the Calendar Type , Sequence Number , Start Date and End date from the input parameter,p_load_calendar.
    l_input_load_cal_type := RTRIM(SUBSTR(p_load_calendar,101,10));
    l_input_load_sequence_number := RTRIM(SUBSTR(p_load_calendar,112,6));

    -- Find all the teaching calendar instances for the given load calendar instance
    OPEN cur_load_to_teach(l_input_load_cal_type,l_input_load_sequence_number);
    FETCH cur_load_to_teach INTO cur_load_to_teach_rec;

    -- If teaching calendars found for the given Load Calendar instance then proces the units ,
    -- otherwise terminate the process
    IF cur_load_to_teach%FOUND THEN

      -- store the start date of the most recent teaching calendar instance.
      l_recent_teach_start_date := cur_load_to_teach_rec.teach_start_dt;

      -- Process all the units for all the teaching calendar instances of the given load calendar instance
      FOR cur_units_rec IN cur_units(l_input_load_cal_type,l_input_load_sequence_number) LOOP

        --Update the Last Enrolled Calendar of an Unit.

	--Initialise the local variables inside the loop
	l_cal_type_enrol_load_cal     := NULL;
        l_sequence_num_enrol_load_cal := NULL;
        l_cal_type_offer_load_cal     := NULL;
        l_sequence_num_offer_load_cal := NULL;

        --Find the most recent teaching calendar instance of the unit.
        OPEN cur_ps_unit_ofr_opt_enroll(cur_units_rec.unit_cd,cur_units_rec.version_number,l_recent_teach_start_date);
        FETCH cur_ps_unit_ofr_opt_enroll INTO cur_ps_unit_ofr_opt_enroll_rec;

        IF (cur_ps_unit_ofr_opt_enroll%FOUND) THEN

          -- Fectch the Load Calendar Instance for the teaching calendar instance of a unit.
          OPEN cur_teach_to_load(cur_ps_unit_ofr_opt_enroll_rec.cal_type,cur_ps_unit_ofr_opt_enroll_rec.ci_sequence_number);
          FETCH cur_teach_to_load INTO cur_teach_to_load_rec;

          --Fetch the Enrolled Calendar Instance for the unit from IGS_PS_UNIT_VER.
          OPEN cur_unit_ver_enroll(cur_units_rec.unit_cd,cur_units_rec.version_number);
          FETCH cur_unit_ver_enroll INTO cur_unit_ver_enroll_rec;

          -- If Load Calendar Instance is greater than the Enrolled Calendar Instance or there is no calendar instance defined for the unit
          -- then Update the table,IGS_PS_UNIT_VER

          IF ( cur_unit_ver_enroll%NOTFOUND OR
              TRUNC(cur_unit_ver_enroll_rec.start_date) < TRUNC(cur_teach_to_load_rec.load_start_dt) ) THEN

            -- Set the value of cal_type_enrol_load_cal and sequence_num_enrol_load_cal of IGS_PS_UNIT_VER table.
       	    l_cal_type_enrol_load_cal     := cur_teach_to_load_rec.load_cal_type;
            l_sequence_num_enrol_load_cal := cur_teach_to_load_rec.load_ci_sequence_number;

          END IF;
          CLOSE cur_unit_ver_enroll;
          CLOSE cur_teach_to_load;
        END IF;
        CLOSE cur_ps_unit_ofr_opt_enroll;

        -- Update the Last Offered Calendar of an Unit

        -- Find the most recent teaching calendar instance of the unit.
        OPEN cur_ps_unit_ofr_opt_offer(cur_units_rec.unit_cd,cur_units_rec.version_number,l_recent_teach_start_date);
        FETCH cur_ps_unit_ofr_opt_offer INTO cur_ps_unit_ofr_opt_offer_rec;

        IF (cur_ps_unit_ofr_opt_offer%FOUND) THEN

          -- Fectch the Load Calendar Instance for the teaching calendar instance of a unit.
          OPEN cur_teach_to_load(cur_ps_unit_ofr_opt_offer_rec.cal_type,cur_ps_unit_ofr_opt_offer_rec.ci_sequence_number);
          FETCH cur_teach_to_load INTO cur_teach_to_load_rec;

          --Fetch the Offered Calendar Instance for the unit from IGS_PS_UNIT_VER.
          OPEN cur_unit_ver_offer(cur_units_rec.unit_cd,cur_units_rec.version_number);
          FETCH cur_unit_ver_offer INTO cur_unit_ver_offer_rec;

           -- If Load Calendar Instance is greater than the Enrolled Calendar Instance then Update the table,IGS_PS_UNIT_VER.
          IF ( cur_unit_ver_offer%NOTFOUND  OR
               TRUNC(cur_unit_ver_offer_rec.start_date) < TRUNC(cur_teach_to_load_rec.load_start_dt) ) THEN

            -- Set the value of cal_type_offer_load_cal and sequence_num_offer_load_cal of IGS_PS_UNIT_VER table.
            l_cal_type_offer_load_cal     := cur_teach_to_load_rec.load_cal_type ;
            l_sequence_num_offer_load_cal := cur_teach_to_load_rec.load_ci_sequence_number;

          END IF; -- End of Updation
          CLOSE cur_unit_ver_offer;
          CLOSE cur_teach_to_load;

        END IF;
        CLOSE cur_ps_unit_ofr_opt_offer;

	--Perform the updation of the unit version record
        IF l_sequence_num_enrol_load_cal IS NOT NULL  OR l_sequence_num_offer_load_cal IS NOT NULL THEN
           update_unit_version ( p_unit_cd                     => cur_units_rec.unit_cd,
                                 p_version_number              => cur_units_rec.version_number,
                                 p_cal_type_enrol_load_cal     => l_cal_type_enrol_load_cal,
				 p_sequence_num_enrol_load_cal => l_sequence_num_enrol_load_cal,
				 p_cal_type_offer_load_cal     => l_cal_type_offer_load_cal ,
				 p_sequence_num_offer_load_cal => l_sequence_num_offer_load_cal
				) ;
        END IF;

      END LOOP; -- all units are processed.
      CLOSE cur_load_to_teach;

    ELSE

      FND_MESSAGE.SET_NAME('IGS','IGS_PS_TEACH_CAL_NOT_FOUND');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      retcode := 2;
      errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END update_enroll_offer_unit;

END igs_ps_cal_rsr_val;

/
