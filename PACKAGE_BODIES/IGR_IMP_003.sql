--------------------------------------------------------
--  DDL for Package Body IGR_IMP_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_IMP_003" AS
/* $Header: IGSRT14B.pls 120.0 2005/06/01 16:09:32 appldev noship $ */
/* ------------------------------------------------------------------------------------------------------------------------
  ||  Created By : rbezawad
  ||  Created On : 28-Feb-05
  ||  Purpose : Extract of IGR related references from Admissions Import process packages (IGSAD97B.pls)
  ||            to get rid of probable compilation errors for non-IGR customers.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  WHO             WHEN                   WHAT
      9-Mar-05      rbezawad    Modified logic to Validated Inquiry Lines for APC Integration Build. Bug: 3973942.
                                Also obsoelted usage of Entry Status/Program/Unit Set code columns.
---------------------------------------------------------------------------------------------------------------------------*/

/** Main Cursor to iterate in Inquiry details records **/

CURSOR c_inquiry_dtls (cp_interface_run_id igr_i_appl_int.interface_run_id%TYPE)
  IS
  SELECT  a.rowid,a.*
   FROM     igr_i_appl_int a
   WHERE a.interface_run_id = cp_interface_run_id
   AND        a.status = '2';

CURSOR c_inquiry_lines (cp_interface_run_id igr_i_lines_int.interface_run_id%TYPE)
IS
  SELECT  a.rowid,a.*
  FROM   igr_i_lines_int a
  WHERE a.interface_run_id = cp_interface_run_id
    AND  a.status = '2';

 /***************************Get Meaning for error code******************************/

   FUNCTION Get_Meaning(
     p_lookup_code   igs_lookups_view.lookup_code%TYPE,
     p_lookup_type   igs_lookups_view.lookup_type%TYPE
                       )
   RETURN VARCHAR2 AS
 /*******************************************************************************
      Created By:         Syam Krishnan
      Date Created By:   06-12-2001 (MM-DD-YYYY)
      Purpose:           This fucntion is used to return the meaning for
                         a particular lookup_type and lookup_code combination.
      Known limitations,enhancements,remarks:
      Change History
      Who     When       What

  *******************************************************************************/
     lv_meaning igs_lookups_view.meaning%TYPE;

     -- Cursor c_lkup is used to select the record (if any) that matches the
     -- criteria passed  via the parameters to the fucntion
     CURSOR c_lkup (cp_lookup_type igs_lookups_view.lookup_type%TYPE,
                    cp_lookup_code igs_lookups_view.lookup_code%TYPE) IS
     SELECT
       meaning
     FROM
       igs_lookups_view
     WHERE
           lookup_type = cp_lookup_type
       AND lookup_code = cp_lookup_code;

   BEGIN
     OPEN c_lkup (p_lookup_type ,p_lookup_code);
     FETCH c_lkup INTO lv_meaning;

     IF c_lkup%NOTFOUND  THEN
       -- No records are found that match the criteria passed via the parameters
       -- hence closing the cursor and returning null value.
       CLOSE c_lkup;
       RETURN NULL;
     END IF;

     -- The control will come to this point only if a matching record is found
     -- Hence closing the cursor and returning the value.
     CLOSE c_lkup;
     RETURN lv_meaning;
   END get_meaning;
  /***************************Get Meaning for error code******************************/


  /***********************Start Create person inquiry *********************************/
  PROCEDURE create_person_inquiry ( p_inquiry_dtls_rec IN c_inquiry_dtls%ROWTYPE,
                                    p_source_type_id igs_ad_interface.source_type_id%TYPE,
                                    p_status OUT NOCOPY VARCHAR2
  ) AS
  /*************************************************************
  Created By :Syam.Krishnan
  Date Created By :12-JUN-2001
  Purpose : To create Person Inquiries
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  rrengara        14-Feb-2003     Changes for RCT Build
  (reverse chronological order - newest change first)
  ***************************************************************/

   ----------------Variable Declarations-------------------------------------
    lv_enq_appl_rowid ROWID;
    lv_enquiry_appl_number igr_i_appl.enquiry_appl_number%TYPE;
    ln_org_id  igr_i_appl.org_id%TYPE ;
    l_sales_lead_id igr_i_appl_v.sales_lead_id%TYPE;

    lv_msg_data      VARCHAR2(4000);
    lv_return_status VARCHAR2(1);
    lv_msg_count NUMBER;

    lv_new_person_type_code  igs_pe_typ_instances.person_type_code%TYPE;
    lv_new_funnel_status     igs_pe_typ_instances.funnel_status%TYPE;

    cst_PROSPECT CONSTANT varchar2(50)     DEFAULT 'PROSPECT';
    cst_IDENTIFIED  CONSTANT  varchar2(50) DEFAULT '100-IDENTIFIED';
    cst_INQUIRED  CONSTANT varchar2(50)    DEFAULT '300-INQUIRED';
    cst_CONTACTED  CONSTANT  varchar2(50)  DEFAULT '200-CONTACTED';

    l_prog_label  VARCHAR2(100);
    l_error_code VARCHAR2(30);
    l_request_id NUMBER;
    l_label  VARCHAR2(100);
    l_debug_str VARCHAR2(2000);
    l_enable_log VARCHAR2(1);
    l_rowid VARCHAR2(25);
    l_error_text VARCHAR2(2000);
    l_type VARCHAR2(1);
    l_status VARCHAR2(1);
    l_sqlerrm VARCHAR2(2000);

  --------------------End variable Declarations-------------------------------

  ----------------Cursor Declarations-----------------------------------------
    CURSOR
      c_prospect_exist (cp_person_id  igs_pe_typ_instances.person_id%TYPE) IS
    SELECT
      pti.rowid,pti.*
    FROM
      igs_pe_typ_instances_all pti,
      igs_pe_person_types pt
    WHERE
           pti.person_id = cp_person_id
    AND    pti.person_type_code = pt.person_type_code
    AND    pt.system_type = cst_PROSPECT
    AND    funnel_status IN (cst_IDENTIFIED,cst_INQUIRED,cst_CONTACTED);
  ----------------End Cursor Declarations-----------------------------------------


  --------------------Local Procedure for Finding Funnel Status and Person Type------------------
  PROCEDURE find_ptype_funnel_status (p_inquiry_dtls_rec c_inquiry_dtls%ROWTYPE ,
                                      p_source_type_id igs_ad_interface.source_type_id%TYPE,
                                      p_old_person_type_code igs_pe_typ_instances.person_type_code%TYPE,
                                      p_new_person_type_code OUT NOCOPY igs_pe_typ_instances.person_type_code%TYPE,
                                      p_new_funnel_status    OUT NOCOPY igs_pe_typ_instances.funnel_status%TYPE)  AS
  /*************************************************************
  Created By :Sykrishn
  Date Created By :06-SEP-2001
  Purpose : To find new person type and the new funnel status
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  Change History
  Who             When            What
  rboddu          09-OCT-2002     Removed the logic of fetching person_type_code and funnel_status
                                  from IGS_AD_INTERFACE_CTL as part of Enh Bug: 2604395
  ***************************************************************/

   ----------------------Variable Declarations-----------------------------------------
   lv_person_type_code  igs_pe_typ_instances.person_type_code%TYPE ;
   lv_funnel_status     igs_pe_typ_instances.funnel_status%TYPE    ;
   lb_int_found     BOOLEAN             ;
   lb_int_ctl_found BOOLEAN             ;

   cst_PROSPECT CONSTANT varchar2(50)  DEFAULT 'PROSPECT';
   cst_other CONSTANT varchar2(50)     DEFAULT 'OTHER';
   cst_applicant CONSTANT VARCHAR2(50) DEFAULT 'APPLICANT';
   ----------------------End Variable Declarations-----------------------------------------

   -----------------Cursor Declarations----------------------------------------------------
   /* Cursor to get the person_type and funnel_status from igs_ad_interface */
   CURSOR  c_interface (cp_interface_id  igs_ad_interface.interface_id%TYPE) IS
   SELECT
     person_type_code ,
     funnel_status
   FROM
     igs_ad_interface
   WHERE
     interface_id = cp_interface_id;

   CURSOR  c_pe_src_types (cp_source_type_id igs_ad_interface.source_type_id%TYPE) IS
   SELECT
     person_type_code ,
     funnel_status
   FROM
     igs_pe_src_types
   WHERE
     source_type_id = cp_source_type_id;

   CURSOR c_sys_person_type (p_person_type_code igs_pe_person_types.person_type_code%TYPE) IS
   SELECT
     system_type
   FROM
     igs_pe_person_types
   WHERE
     person_type_code = p_person_type_code ;

   l_sys_person_type igs_pe_person_types.system_type%TYPE;

   -----------------End Cursor Declarations----------------------------------------------------
  BEGIN

    lv_person_type_code := NULL;
    lv_funnel_status := NULL;
    lb_int_found := FALSE;
    lb_int_ctl_found := FALSE;


    OPEN c_interface(p_inquiry_dtls_rec.interface_id);
    FETCH c_interface INTO lv_person_type_code,lv_funnel_status;
    IF c_interface%FOUND THEN
      CLOSE c_interface;
      IF (lv_person_type_code IS NOT NULL ) AND (lv_funnel_status IS NOT NULL) THEN
        lb_int_found := TRUE;
      END IF;
    ELSE
      CLOSE c_interface;
    END IF;

    IF NOT lb_int_found THEN -- if not in ad_interface >> next level interface_ctl
      lv_person_type_code := NULL;
      lv_funnel_status := NULL;
      OPEN c_pe_src_types(p_source_type_id);
      FETCH c_pe_src_types INTO lv_person_type_code,lv_funnel_status;
      CLOSE c_pe_src_types;
    END IF;

    IF (lv_person_type_code IS NULL AND p_old_person_type_code = cst_OTHER) THEN
        BEGIN
          UPDATE igr_i_appl_int
          SET status = '3',
              error_code  = 'E731'
          WHERE interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;
        END;
    END IF;

    OPEN c_sys_person_type(lv_person_type_code);
    FETCH c_sys_person_type INTO l_sys_person_type;
    CLOSE c_sys_person_type;

    IF (lv_funnel_status IS NOT NULL AND l_sys_person_type <> cst_PROSPECT) THEN
        BEGIN
          UPDATE igr_i_appl_int
          SET status = '3',
              error_code  = 'E732' /* Invalid Person Type */
          WHERE interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;
        END;
    END IF;

    /* Anyway return the out parameters */
    p_new_person_type_code := lv_person_type_code;
    p_new_funnel_status := lv_funnel_status;
  END find_ptype_funnel_status;
  /*************************************Local Procedure for Finding Funnel Status and Person Type****************************/

  BEGIN
    ln_org_id := igs_ge_gen_003.get_org_id;
    FOR rec_prospect_exist IN c_prospect_exist  (p_inquiry_dtls_rec.person_id)  LOOP
     find_ptype_funnel_status (p_inquiry_dtls_rec => p_inquiry_dtls_rec ,
                               p_source_type_id  => p_source_type_id,
                               p_old_person_type_code => rec_prospect_exist.person_type_code,
                               p_new_person_type_code =>  lv_new_person_type_code,
                               p_new_funnel_status =>  lv_new_funnel_status );
    END LOOP;

    igr_inquiry_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => lv_enq_appl_rowid,
      x_person_id                         => p_inquiry_dtls_rec.person_id,
      x_enquiry_appl_number               => lv_enquiry_appl_number,
      x_sales_lead_id                     => l_sales_lead_id,
      x_acad_cal_type                     => p_inquiry_dtls_rec.acad_cal_type,
      x_acad_ci_sequence_number           => p_inquiry_dtls_rec.acad_ci_sequence_number,
      x_adm_cal_type                      => p_inquiry_dtls_rec.adm_cal_type,
      x_adm_ci_sequence_number            => p_inquiry_dtls_rec.adm_ci_sequence_number,
      x_enquiry_dt                        => p_inquiry_dtls_rec.inquiry_dt,
      x_registering_person_id             => p_inquiry_dtls_rec.registering_person_id,
      x_override_process_ind              => p_inquiry_dtls_rec.override_process_ind,
      x_indicated_mailing_dt              => p_inquiry_dtls_rec.indicated_mailing_dt,
      x_last_process_dt                   => p_inquiry_dtls_rec.last_process_dt,
      x_comments                          => p_inquiry_dtls_rec.comments,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_inq_entry_level_id                => p_inquiry_dtls_rec.inquiry_entry_level_id,
      x_edu_goal_id                       => p_inquiry_dtls_rec.edu_goal_id,
      x_party_id                          => p_inquiry_dtls_rec.inquiry_school_of_interest_id,
      x_how_knowus_id                     => p_inquiry_dtls_rec.learn_source_id,
      x_who_influenced_id                 => p_inquiry_dtls_rec.influence_source_id,
      x_attribute_category                => p_inquiry_dtls_rec.attribute_category,
      x_attribute1                        => p_inquiry_dtls_rec.attribute1,
      x_attribute2                        => p_inquiry_dtls_rec.attribute2,
      x_attribute3                        => p_inquiry_dtls_rec.attribute3,
      x_attribute4                        => p_inquiry_dtls_rec.attribute4,
      x_attribute5                        => p_inquiry_dtls_rec.attribute5,
      x_attribute6                        => p_inquiry_dtls_rec.attribute6,
      x_attribute7                        => p_inquiry_dtls_rec.attribute7,
      x_attribute8                        => p_inquiry_dtls_rec.attribute8,
      x_attribute9                        => p_inquiry_dtls_rec.attribute9,
      x_attribute10                       => p_inquiry_dtls_rec.attribute10,
      x_attribute11                       => p_inquiry_dtls_rec.attribute11,
      x_attribute12                       => p_inquiry_dtls_rec.attribute12,
      x_attribute13                       => p_inquiry_dtls_rec.attribute13,
      x_attribute14                       => p_inquiry_dtls_rec.attribute14,
      x_attribute15                       => p_inquiry_dtls_rec.attribute15,
      x_attribute16                       => p_inquiry_dtls_rec.attribute16,
      x_attribute17                       => p_inquiry_dtls_rec.attribute17,
      x_attribute18                       => p_inquiry_dtls_rec.attribute18,
      x_attribute19                       => p_inquiry_dtls_rec.attribute19,
      x_attribute20                       => p_inquiry_dtls_rec.attribute20,
      x_s_enquiry_status                  => p_inquiry_dtls_rec.inquiry_status,
      x_source_promotion_id               => p_inquiry_dtls_rec.source_promotion_id,
      x_person_type_code                  => lv_new_person_type_code,
      x_funnel_status                     => lv_new_funnel_status,
      x_ret_status                        => lv_return_status,
      x_msg_data                          => lv_msg_data,
      x_msg_count                         => lv_msg_count,
      x_inquiry_method_code               => p_inquiry_dtls_rec.inquiry_source_type,
      x_action                            => 'Import',
      x_pkg_reduct_ind                    => NVL(p_inquiry_dtls_rec.pkg_reduct_ind,'N')
    );

IF lv_return_status <>'U'  AND lv_msg_data IS NOT NULL THEN
  IF l_enable_log = 'Y' THEN
    igs_ad_imp_001.logerrormessage(p_inquiry_dtls_rec.interface_inq_appl_id,lv_msg_data);
  END IF;
ELSIF lv_return_status = 'U' THEN
  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
    l_label :=  'igs.plsql.igr_imp_003.process_person_inquiry.exception '||'E322';

    fnd_message.set_name('IGS','IGS_PE_IMP_DET_ERROR');
                fnd_message.set_token('CONTEXT',p_inquiry_dtls_rec.interface_inq_appl_id);
                fnd_message.set_token('ERROR', l_error_text);

                l_debug_str :=  fnd_message.get;

    fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;
END IF;

IF lv_msg_data IS NOT NULL THEN
/* Return status of Null should be treated as Success */
  IF NVL(lv_return_status,'S') = 'S' THEN
    UPDATE igr_i_appl_int
    SET status = '4',
        error_code = 'E702',
        error_text = lv_msg_data
     WHERE rowid = p_inquiry_dtls_rec.rowid;
   ELSE
     ROLLBACK TO perinq_save;
     UPDATE igr_i_appl_int
     SET status = '3',
         error_code = 'E322',
         error_text = lv_msg_data
     WHERE rowid = p_inquiry_dtls_rec.rowid;
   END IF;
 ELSE
/* Return status of Null should be treated as Success */
  IF NVL(lv_return_status,'S') = 'S'  THEN
     UPDATE igr_i_appl_int
     SET status = '1',
         error_code = NULL,
         error_text = NULL,
         enquiry_appl_number=  lv_enquiry_appl_number,
         sales_lead_id = l_sales_lead_id
     WHERE rowid = p_inquiry_dtls_rec.rowid;
  ELSE
     l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E322', 8405);
     ROLLBACK TO perinq_save;
     UPDATE igr_i_appl_int
     SET status = '3',
         error_code = 'E322',
         error_text = l_error_text
     WHERE rowid = p_inquiry_dtls_rec.rowid;
   END IF;
 END IF;


  EXCEPTION
    WHEN OTHERS THEN
     l_sqlerrm := SQLERRM;
     /* If insert is NOT successful update status to 3 in table igr_i_appl_int */
      p_status := '3';

      ROLLBACK TO perinq_save;

      UPDATE
        igr_i_appl_int
      SET
        status = '3',
        error_code  = 'E322' ,
        error_text = NVL(lv_msg_data,l_sqlerrm)
      WHERE
        interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;
  END create_person_inquiry ;
  /***********************End Create person inquiry *********************************/

  PROCEDURE validate_person_inquiry ( p_inquiry_dtls_rec IN c_inquiry_dtls%ROWTYPE,
                                      p_validation OUT NOCOPY BOOLEAN )
  AS
  /*************************************************************
  Created By :Syam.Krishnan
  Date Created By :12-JUN-2001
  Purpose : Validate data elements for person inquiry
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  -- kamohan 5/23/02       Changed the condition to check
  --                                   the user defined status and not the system defined
  --pbondugu  19-Mar-2003  Added the validation for inquiry date. New error code is added
                                        for  the same.
  ***************************************************************/

   -------------------------Variable Declarations-------------------------------------------------------
   lv_deceased_ind igs_pe_hz_parties.deceased_ind%TYPE;

   lv_exist varchar2(2000);
   l_birth_date     igs_pe_person_base_v.birth_date%TYPE;

   l_error_text VARCHAR2(2000);
  -------------------------End Variable Declarations-------------------------------------------------------

  ------------------------------------Cursor Declarations----------------------------------------------
    /*cursor to select Birth Date*/
     CURSOR c_birth_date(p_person_id igs_pe_person_base_v.person_id%TYPE) IS
     SELECT birth_date
     FROM   igs_pe_person_base_v
     WHERE  person_id =p_person_id ;

    /*cursor to select inquiry status*/
    CURSOR  c_inquiry_status  (cp_inquiry_status   igr_i_appl_int.inquiry_status%TYPE) IS
    SELECT
      'X'
    FROM
      igr_i_status_v
    WHERE
          s_enquiry_status = cp_inquiry_status
      AND dsp_closed_ind = 'N';

   /*cursor to select inquiry source type */
    CURSOR  c_inquiry_source_type (cp_inquiry_source_type  igr_i_appl_int.inquiry_source_type%TYPE) IS
    SELECT
      'X'
    FROM
      fnd_lookup_values
    WHERE
      LOOKUP_TYPE ='VEHICLE_RESPONSE_CODE'
      AND lookup_code = cp_inquiry_source_type
      AND enabled_flag ='Y'
      AND LANGUAGE = USERENV('LANG')
      AND VIEW_APPLICATION_ID = 279
      AND SECURITY_GROUP_ID = 0;

   /*cursor to select inquiry entry status id */
    CURSOR  c_inquiry_type_id (cp_inquiry_type_id  igr_i_appl_int.inquiry_type_id%TYPE) IS
    SELECT
      'X'
    FROM
      igr_i_inquiry_types
    WHERE
      enabled_flag ='Y' AND
      inquiry_type_id = cp_inquiry_type_id;

    /*cursor to select inquiry entry level id */
    CURSOR  c_inquiry_entry_level_id (cp_inquiry_entry_level_id  igr_i_appl_int.inquiry_entry_level_id%TYPE) IS
    SELECT
      inq_entry_level_id
    FROM
      igr_i_entry_lvls_v
    WHERE
      closed_ind = 'N'
      AND inq_entry_level_id = cp_inquiry_entry_level_id;


    /*cursor to select registering person id */
    CURSOR  c_registering_person_id (cp_registering_person_id  igr_i_appl_int.registering_person_id%TYPE) IS
    SELECT
      'X'
    FROM
      igs_pe_person_base_v
    WHERE
      person_id  = cp_registering_person_id;

    /*cursor to select education goal */
    CURSOR  c_edu_goal_id (cp_edu_goal_id  igr_i_appl_int.edu_goal_id%TYPE) IS
    SELECT
      'X'
    FROM
      igs_ad_code_classes cc
    WHERE
             cc.class = 'EDU_GOALS'
      AND    NVL(cc.closed_ind,'N') = 'N'
      AND    cc.code_id = cp_edu_goal_id;

    /*cursor to select inquiry school of interest id */
    CURSOR  c_inq_school_of_interest_id (cp_inq_school_of_interest_id  igr_i_appl_int.inquiry_school_of_interest_id%TYPE) IS
    SELECT
      'X'
    FROM
      igs_ad_schl_aply_to
    WHERE
          closed_ind = 'N'
      AND sch_apl_to_id = cp_inq_school_of_interest_id;

    /*cursor to select learn source id */
    CURSOR  c_learn_source_id (cp_learn_source_id  igr_i_appl_int.learn_source_id%TYPE) IS
    SELECT
      'X'
    FROM
      igs_ad_code_classes cc
    WHERE
           cc.class = 'INQ_HOW_KNOWUS'
    AND    NVL(cc.closed_ind,'N') = 'N'
    AND    cc.code_id = cp_learn_source_id;


    /*cursor to select influence source id */
    CURSOR  c_influence_source_id (cp_influence_source_id  igr_i_appl_int.influence_source_id%TYPE) IS
    SELECT
      'X'
    FROM
      igs_ad_code_classes cc
    WHERE
             cc.class = 'INQ_WHO_INFLUENCED'
      AND    NVL(cc.closed_ind,'N') = 'N'
      AND    cc.code_id = cp_influence_source_id;


    /*cursor to select academic cal type and ci sequence number  */
    CURSOR c_acad_cal_type_ci (p_acad_cal_type igr_i_appl_int.acad_cal_type%TYPE,
                               p_acad_ci_sequence_number igr_i_appl_int.acad_ci_sequence_number%TYPE)  IS

    SELECT
      'X'
    FROM
      igs_ca_inst_alt_v ciav,
      igs_lookups_view lkupv,
      igs_lookups_view lkupv1
    WHERE
      (ciav.s_cal_cat = 'ACADEMIC' AND ciav.s_cal_status IN ('ACTIVE')
     AND (p_acad_cal_type, p_acad_ci_sequence_number) IN
     (SELECT
        cir.sup_cal_type,
        cir.sup_ci_sequence_number
      FROM
        igs_ca_inst_rel cir
      WHERE
        cir.sub_cal_type IN
         (SELECT
           ct.cal_type
          FROM
            igs_ca_type ct
          WHERE
            ct.s_cal_cat = 'ADMISSION')))
     AND lkupv.lookup_type='CAL_CAT' and lkupv.lookup_code='ACADEMIC'
     AND lkupv1.lookup_code = ciav.s_cal_status
     AND lkupv1.lookup_type = 'CALENDAR_STATUS';


    /*cursor to select admission cal type and ci sequence number  */
    CURSOR c_adm_cal_type_ci (p_adm_cal_type  igr_i_appl_int.adm_cal_type%TYPE,
                              p_adm_ci_sequence_number igr_i_appl_int.adm_ci_sequence_number%TYPE)  IS
     SELECT
       'X'
     FROM
        igs_ca_inst_alt_v ciav1,
        igs_lookups_view lkupv,
        igs_lookups_view lkupv1
     WHERE
        (ciav1.s_cal_cat = 'ADMISSION' and ciav1.s_cal_status in ('ACTIVE')
        AND     (p_adm_cal_type, p_adm_ci_sequence_number)
        IN
          (SELECT
            cir.sub_cal_type,
            cir.sub_ci_sequence_number
           FROM
             igs_ca_inst_rel cir
           WHERE
             cir.sup_cal_type = P_INQUIRY_DTLS_REC.ACAD_CAL_TYPE
             AND cir.sup_ci_sequence_number = P_INQUIRY_DTLS_REC.ACAD_CI_SEQUENCE_NUMBER ))
             AND lkupv.lookup_type='CAL_CAT' and lkupv.lookup_code = 'ADMISSION'
             AND lkupv1.lookup_type = 'CALENDAR_STATUS' and lkupv1.lookup_code = ciav1.s_cal_status;

   -- Validation for the deceased person is added as a part of the bug #2028066
   CURSOR c_deceased(cp_party_id igs_pe_hz_parties.party_id%TYPE) IS
   SELECT
     deceased_ind
   FROM
     igs_pe_hz_parties
   WHERE
     party_id = cp_party_id;

   -- Validation for the source_promotion_id added as a part of the Capture Campaign event

   CURSOR c_source_promotion (cp_source_promotion_id  igr_i_appl_int.source_promotion_id%TYPE) IS
   SELECT
     'X'
   FROM
     ams_p_source_codes_v sc,
     ams_lookups lkup
   WHERE sc.source_code_id = cp_source_promotion_id
     AND sc.status IN ('ACTIVE','COMPLETED')
     AND sc.source_type IN ('EVEH','CAMP')
     AND sc.source_type = lkup.lookup_code(+)
     AND lkup.lookup_type = 'AMS_SYS_ARC_QUALIFIER'
     AND start_date < TRUNC (SYSDATE) ;


   ------------------------------------End Cursor Declarations----------------------------------------------
  BEGIN
    /* setting the validation flag to true by default */
    p_validation := TRUE;
   /* Validation for inquiry date */
     IF( p_inquiry_dtls_rec.inquiry_dt> SYSDATE) THEN
       l_error_text  := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E349', 8405);
       UPDATE
        igr_i_appl_int
      SET
        status = '3',
        error_code  = 'E349' ,  /* Error code for validation to check if system date is greater than system date */
        error_text = l_error_text
      WHERE
        interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;

      p_validation := FALSE;
      RETURN;
    END IF;

    /* Validation to check for Birth Date */
     OPEN c_birth_date(p_inquiry_dtls_rec.person_id);
     FETCH c_birth_date INTO l_birth_date;
     CLOSE c_birth_date;

     IF ((l_birth_date IS NOT NULL) AND (l_birth_date > p_inquiry_dtls_rec.inquiry_dt)) THEN

      l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E583', 8405);
      UPDATE
        igr_i_appl_int
      SET
        status = '3',
        error_code  = 'E583' ,  /* Error code for validation to check if the person is deceased */
        error_text = l_error_text
      WHERE
        interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;
      p_validation := FALSE;
      RETURN;
    END IF;

    /* Validation to check for deceased person */
    OPEN  c_deceased (p_inquiry_dtls_rec.person_id);
    FETCH c_deceased INTO lv_deceased_ind;
    CLOSE c_deceased;
    IF lv_deceased_ind = 'Y' THEN
      l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E528', 8405);
      UPDATE
        igr_i_appl_int
      SET
        status = '3',
        error_code  = 'E528' ,  /* Error code for validation to check if the person is deceased */
        error_text = l_error_text
      WHERE
        interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;

      p_validation := FALSE;
      RETURN;
    END IF;

    /* validation for inquiry status */
    OPEN  c_inquiry_status (p_inquiry_dtls_rec.inquiry_status);
    FETCH c_inquiry_status INTO lv_exist;
    IF c_inquiry_status%NOTFOUND THEN
      l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E302', 8405);
      UPDATE
        igr_i_appl_int
      SET
        status = '3',
        error_code  = 'E302' ,  /* Error code for validation for field Inquiry Status */
        error_text = l_error_text
      WHERE
        interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;

      p_validation := FALSE;
      CLOSE c_inquiry_status;
      RETURN;
    END IF;

    IF c_inquiry_status%ISOPEN THEN
      CLOSE c_inquiry_status;
    END IF;


    /* validation for inquiry source type */
    OPEN  c_inquiry_source_type (p_inquiry_dtls_rec.inquiry_source_type);
    FETCH c_inquiry_source_type INTO lv_exist;
    IF c_inquiry_source_type%NOTFOUND THEN
      l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E303', 8405);
      UPDATE
        igr_i_appl_int
      SET
        status = '3',
        error_code  =  'E303',  /*Error code  for validation for field Inquiry Source Type*/
        error_text = l_error_text
      WHERE
        interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;

      p_validation := FALSE;
      CLOSE c_inquiry_source_type;
      RETURN;
    END IF;

    IF c_inquiry_source_type%ISOPEN THEN
      CLOSE c_inquiry_source_type;
    END IF;

    /*validation for inquiry_type_id */
    OPEN  c_inquiry_type_id (p_inquiry_dtls_rec.inquiry_type_id);
    FETCH c_inquiry_type_id INTO lv_exist;
    IF c_inquiry_type_id%NOTFOUND THEN
      l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E313', 8405);
      UPDATE
        igr_i_appl_int
      SET
        status = '3',
        error_code  =  'E313', --Error code  for validation for field Inquiry Type Id
        error_text = l_error_text
      WHERE
        interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;

      p_validation := FALSE;

      CLOSE c_inquiry_type_id;
      RETURN;
    END IF;

    IF c_inquiry_type_id%ISOPEN THEN
      CLOSE c_inquiry_type_id;
    END IF;

    /* validation for Package items Reduction indicator */
    IF p_inquiry_dtls_rec.pkg_reduct_ind IS NOT NULL THEN
      IF p_inquiry_dtls_rec.pkg_reduct_ind NOT IN ('Y','N') THEN
        l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E360', 8405);
        UPDATE  igr_i_appl_int
        SET    status = '3',
          error_code  = 'E360' ,/*Error code  for validation for field  Package items Reduction Ind */
          error_text = l_error_text
        WHERE
          interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;
        p_validation := FALSE;
        RETURN;
      END IF;
    END IF;

    IF p_inquiry_dtls_rec.inquiry_entry_level_id IS NOT NULL THEN
    /* validation for inquiry entry level id */
      OPEN  c_inquiry_entry_level_id (p_inquiry_dtls_rec.inquiry_entry_level_id);
      FETCH c_inquiry_entry_level_id INTO lv_exist;
      IF c_inquiry_entry_level_id%NOTFOUND THEN
        l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E305', 8405);
        UPDATE
          igr_i_appl_int
        SET
          status = '3',
          error_code  = 'E305' ,/*Error code  for validation for field Inquiry Entry Level Id*/
          error_text = l_error_text
        WHERE
          interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;

        p_validation := FALSE;
        CLOSE c_inquiry_entry_level_id;
        RETURN;
      END IF;

      IF c_inquiry_entry_level_id%ISOPEN THEN
        CLOSE c_inquiry_entry_level_id;
      END IF;
    END IF;

    /* validation for registering person id */
    IF p_inquiry_dtls_rec.registering_person_id IS NOT NULL THEN
      OPEN  c_registering_person_id (p_inquiry_dtls_rec.registering_person_id);
      FETCH c_registering_person_id INTO lv_exist;

      IF c_registering_person_id%NOTFOUND THEN
        l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E306', 8405);

        UPDATE   igr_i_appl_int
        SET     status = '3',
          error_code  =  'E306' , /*Error code  for validation for field Registering person Id*/
          error_text = l_error_text
        WHERE
          interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;
        p_validation := FALSE;
        CLOSE c_registering_person_id;
        RETURN;
      END IF;

      IF c_registering_person_id%ISOPEN THEN
        CLOSE c_registering_person_id;
      END IF;
    END IF;

    /* validation for override process indicator */
    IF p_inquiry_dtls_rec.override_process_ind IS NOT NULL THEN
      IF p_inquiry_dtls_rec.override_process_ind NOT IN ('Y','N') THEN
        l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E307', 8405);
        UPDATE  igr_i_appl_int
        SET    status = '3',
          error_code  = 'E307' ,/*Error code  for validation for field  Override Process Ind */
          error_text = l_error_text
        WHERE
          interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;
        p_validation := FALSE;
        RETURN;
      END IF;
    END IF;

     /* validation for education goal id */
    IF p_inquiry_dtls_rec.edu_goal_id IS NOT NULL THEN
      OPEN  c_edu_goal_id (p_inquiry_dtls_rec.edu_goal_id);
      FETCH c_edu_goal_id INTO lv_exist;

      IF c_edu_goal_id%NOTFOUND THEN
        l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E308', 8405);
          UPDATE igr_i_appl_int
          SET    status = '3',
          error_code  = 'E308', /*Error code  for validation for field Education Goal Id*/
          error_text = l_error_text
        WHERE
          interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;

        p_validation := FALSE;
        CLOSE c_edu_goal_id;
        RETURN;
      END IF;
      IF c_edu_goal_id%ISOPEN THEN
        CLOSE c_edu_goal_id;
      END IF;
    END IF;

    /* validation for inquiry school of interest  */
    IF p_inquiry_dtls_rec.inquiry_school_of_interest_id IS NOT NULL THEN
      OPEN  c_inq_school_of_interest_id (p_inquiry_dtls_rec.inquiry_school_of_interest_id);
      FETCH c_inq_school_of_interest_id INTO lv_exist;
      IF c_inq_school_of_interest_id%NOTFOUND THEN
        l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E309', 8405);
        UPDATE  igr_i_appl_int
        SET    status = '3',
          error_code  = 'E309' ,/*Error code  for validation for field Inquiry School of Interest Id*/
          error_text = l_error_text
        WHERE
          interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;

        p_validation := FALSE;
        CLOSE c_inq_school_of_interest_id;
        RETURN;
      END IF;

      IF c_inq_school_of_interest_id%ISOPEN THEN
        CLOSE c_inq_school_of_interest_id;
      END IF;
    END IF;


    /* validation for learn source id  */
    IF p_inquiry_dtls_rec.learn_source_id IS NOT NULL THEN
      OPEN  c_learn_source_id (p_inquiry_dtls_rec.learn_source_id);
      FETCH c_learn_source_id INTO lv_exist;
      IF c_learn_source_id%NOTFOUND THEN
        l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E310', 8405);
        UPDATE igr_i_appl_int
        SET    status = '3',
          error_code  = 'E310' ,/*Error code  for validation for field Learn Source Id*/
          error_text = l_error_text
        WHERE
          interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;

        p_validation := FALSE;
        CLOSE c_learn_source_id;
        RETURN;
      END IF;
      IF c_learn_source_id%ISOPEN THEN
        CLOSE c_learn_source_id;
      END IF;
    END IF;

    /* validation for  influence source id  */
    IF  p_inquiry_dtls_rec.influence_source_id IS NOT NULL THEN
      OPEN  c_influence_source_id (p_inquiry_dtls_rec.influence_source_id);
      FETCH c_influence_source_id INTO lv_exist;
      IF c_influence_source_id%NOTFOUND THEN
        l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E311', 8405);
        UPDATE    igr_i_appl_int
        SET   status = '3',
          error_code  = 'E311' ,/*Error code  for validation for field Influence Source Id*/
          error_text = l_error_text
        WHERE
          interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;

        p_validation := FALSE;
        CLOSE c_influence_source_id;
        RETURN;
      END IF;
      IF c_influence_source_id%ISOPEN THEN
        CLOSE c_influence_source_id;
      END IF;
    END IF;

    /* validation for  the decriptive flex field attributes  */
    IF p_inquiry_dtls_rec.attribute_category IS NOT NULL THEN
      IF NOT igs_ad_imp_018.validate_desc_flex
              ( P_ATTRIBUTE_CATEGORY => p_inquiry_dtls_rec.attribute_category,
                P_ATTRIBUTE1 =>  p_inquiry_dtls_rec.attribute1,
                P_ATTRIBUTE2 =>  p_inquiry_dtls_rec.attribute2,
                P_ATTRIBUTE3 =>  p_inquiry_dtls_rec.attribute3,
                P_ATTRIBUTE4 =>  p_inquiry_dtls_rec.attribute4,
                P_ATTRIBUTE5 =>  p_inquiry_dtls_rec.attribute5,
                P_ATTRIBUTE6 =>  p_inquiry_dtls_rec.attribute6,
                P_ATTRIBUTE7 =>  p_inquiry_dtls_rec.attribute7,
                P_ATTRIBUTE8 =>  p_inquiry_dtls_rec.attribute8,
                P_ATTRIBUTE9 =>  p_inquiry_dtls_rec.attribute9,
                P_ATTRIBUTE10 => p_inquiry_dtls_rec.attribute10,
                P_ATTRIBUTE11 => p_inquiry_dtls_rec.attribute11,
                P_ATTRIBUTE12 => p_inquiry_dtls_rec.attribute12,
                P_ATTRIBUTE13 => p_inquiry_dtls_rec.attribute13,
                P_ATTRIBUTE14 => p_inquiry_dtls_rec.attribute14,
                P_ATTRIBUTE15 => p_inquiry_dtls_rec.attribute15,
                P_ATTRIBUTE16 => p_inquiry_dtls_rec.attribute16,
                P_ATTRIBUTE17 => p_inquiry_dtls_rec.attribute17,
                P_ATTRIBUTE18 => p_inquiry_dtls_rec.attribute18,
                P_ATTRIBUTE19 => p_inquiry_dtls_rec.attribute19,
                P_ATTRIBUTE20 => p_inquiry_dtls_rec.attribute20,
                P_DESC_FLEX_NAME =>  'IGR_S_INQUIRY_FLEX'
               ) THEN

        l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E008', 8405);
        UPDATE igr_i_appl_int
        SET  status = '3',
          error_code  = 'E008' ,/*Using this Error code  for validation for field  Flex Field as no error code specified for this*/
          error_text = l_error_text
        WHERE
          interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;

        p_validation := FALSE;
        RETURN;
      END IF;
    END IF;

    /* validation for  academic cal type and ci sequence number */
    IF p_inquiry_dtls_rec.acad_cal_type IS NOT NULL THEN
      OPEN  c_acad_cal_type_ci (p_inquiry_dtls_rec.acad_cal_type,
                                p_inquiry_dtls_rec.acad_ci_sequence_number);


      FETCH c_acad_cal_type_ci INTO lv_exist;
      IF c_acad_cal_type_ci%NOTFOUND THEN
        l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E301', 8405);
        UPDATE  igr_i_appl_int
        SET  status = '3',
          error_code  = 'E301' ,/*Using this Error code  for validation for field Acad Cal type ci seq number as no specific error code specified for this*/
          error_text = l_error_text
        WHERE  interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;

        p_validation := FALSE;
        CLOSE c_acad_cal_type_ci;
        RETURN;
      END IF;

      IF c_acad_cal_type_ci%ISOPEN THEN
        CLOSE c_acad_cal_type_ci;
      END IF;
    END IF;

    /* validation for  admission cal type and ci sequence number */
    IF p_inquiry_dtls_rec.adm_cal_type IS NOT NULL THEN
      OPEN  c_adm_cal_type_ci (p_inquiry_dtls_rec.adm_cal_type,
                                 p_inquiry_dtls_rec.adm_ci_sequence_number);


      FETCH c_adm_cal_type_ci INTO lv_exist;
      IF c_adm_cal_type_ci%NOTFOUND THEN
        l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E301', 8405);
        UPDATE  igr_i_appl_int
        SET   status = '3',
          error_code  = 'E301' ,/* Using this  Error code  for validation for field Adm Cal type ci seq number as no specific error code specified*/
          error_text = l_error_text
        WHERE
          interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;
        p_validation := FALSE;
        CLOSE c_adm_cal_type_ci;
        RETURN;
      END IF;

      IF c_adm_cal_type_ci%ISOPEN THEN
        CLOSE c_adm_cal_type_ci;
      END IF;
    END IF;

        /* Validation to check for Source Promotion */
     IF p_inquiry_dtls_rec.source_promotion_id IS NOT NULL THEN
       OPEN c_source_promotion(p_inquiry_dtls_rec.source_promotion_id);
       FETCH c_source_promotion INTO lv_exist;

       IF c_source_promotion%NOTFOUND THEN
        l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E584', 8405);
        UPDATE
          igr_i_appl_int
        SET
          status = '3',
          error_code  = 'E584'  , /* Error code if source promotion ID is not correct */
          error_text = l_error_text
        WHERE
          interface_inq_appl_id  = p_inquiry_dtls_rec.interface_inq_appl_id ;
          p_validation := FALSE;
          CLOSE c_source_promotion;
        RETURN;
       END IF;

       IF c_source_promotion%ISOPEN THEN
          CLOSE c_source_promotion;
       END IF;
     END IF ;


    /* Setting the validation flag to TRUE in case there are no validation errors*/
    p_validation := TRUE;
  END validate_person_inquiry;


  PROCEDURE process_person_inquiry (
                                             p_interface_run_id IN NUMBER,
                                             p_source_type_id   IN NUMBER,
                                             p_enable_log       IN VARCHAR2,
                                             p_rule             IN VARCHAR2) AS
 /*************************************************************
  Created By :Syam.Krishnan
  Date Created By :12-JUN-2001
  Purpose : To process person inquiries
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  rrengara        11-FEB-2003     As a part of Build RCT. All the funnel status logic has been moved to TBH
  mesriniv        19-FEB-2002     Funnel Status Values for IDENTIFIED,CONTACTED,INQUIRED
                                  were changed as below as per the  SWCR001 Person Change Build
                                  Bug :2203778
  sykrishn        05/09           IDOPA2 Changes
  (reverse chronological order - newest change first)
  ***************************************************************/
  --------------Variable Declaration-----------------------------------------
    lb_validation boolean ;
    v_pr_inq_status varchar2(1);
    l_records_processed NUMBER;

   l_request_id NUMBER;
   l_error_text VARCHAR2(2000);

  --------------End Variable Declaration-----------------------------------------
 BEGIN
   l_records_processed := 0;
    lb_validation := FALSE;

   IF (l_request_id IS NULL) THEN
         l_request_id := fnd_global.conc_request_id;
   END IF;

  /* loop across the inquiry details interface records */
  FOR v_inquiry_dtls_rec IN  c_inquiry_dtls  (p_interface_run_id) LOOP
     l_records_processed := l_records_processed + 1;
     SAVEPOINT perinq_save;
     /* procedure to validate the data elements in inquiry details records*/
     validate_person_inquiry (v_inquiry_dtls_rec,lb_validation);
     /* If validation is passed then create the person inquiry */
     IF  lb_validation THEN
       /* procedure to create person inquiry */
       create_person_inquiry  (v_inquiry_dtls_rec,p_source_type_id,v_pr_inq_status);
     END IF;
     IF l_records_processed = 100 THEN
       COMMIT;
       l_records_processed := 0;
     END IF;
  END LOOP;
  IF l_records_processed < 100 AND l_records_processed > 0  THEN
    COMMIT;
  END IF;
  END process_person_inquiry;

  PROCEDURE validate_inquiry_lines ( p_inquiry_lines_rec IN c_inquiry_lines%ROWTYPE,
                                     p_validation OUT NOCOPY BOOLEAN )
  AS
  /*************************************************************
  Created By :Ramesh.Rengarajan
  Date Created By :5-FEB-2003
  Purpose : To validate inquiry lines
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  --------------------Variable Declaration-----------------------------------------------
  lv_exists VARCHAR2(2000);

  l_error_text VARCHAR2(2000);
  --------------------End Variable Declaration-----------------------------------------------

  ---------------------Cursor Declaration------------------------------------------------------------

  /*Cursor to validate the Product Category Id and Product Category Set ID *****/
  CURSOR c_val_acad_int(cp_product_category_id     igr_i_lines_int.product_category_id%TYPE,
                        cp_product_category_set_id igr_i_lines_int.product_category_set_id%TYPE) IS
  SELECT 'X'
  FROM ENI_PROD_DENORM_HRCHY_V EPDHV,
       ENI_PROD_DEN_HRCHY_PARENTS_V P,
       MTL_CATEGORIES_V C
  WHERE P.CATEGORY_ID = EPDHV.CHILD_ID
      AND EPDHV.PARENT_ID = C.CATEGORY_ID
      AND C.DESCRIPTION = 'OSS Academic Interest'
      AND EPDHV.PARENT_ID <> P.CATEGORY_ID
      AND P.PURCHASE_INTEREST = 'Y'
      AND ( P.DISABLE_DATE IS NULL OR P.DISABLE_DATE > SYSDATE )
      AND P.category_id = cp_product_category_id
      AND P.category_set_id = cp_product_category_set_id;


  ---------------------End Cursor Declaration------------------------------------------------------------
  BEGIN
    /* setting the validation flag to true by default */
    p_validation := TRUE;

    OPEN c_val_acad_int(p_inquiry_lines_rec.product_category_id, p_inquiry_lines_rec.product_category_set_id );
    FETCH c_val_acad_int INTO lv_exists;
    IF c_val_acad_int%NOTFOUND THEN

      l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E314', 8405);

      UPDATE
        igr_i_lines_int
      SET
        status = 3,
        error_code = 'E314',
        error_text = l_error_text
      WHERE
        interface_lines_id = p_inquiry_lines_rec.interface_lines_id;

      p_validation := FALSE;
      CLOSE c_val_acad_int;
      RETURN;
    END IF;
    CLOSE c_val_acad_int;

    /**if all validations passed set it to true **/
  p_validation := TRUE;
  END validate_inquiry_lines;

PROCEDURE process_inquiry_lines (
                                             p_interface_run_id IN NUMBER,
                                             p_enable_log       IN VARCHAR2,
                                             p_rule             IN VARCHAR2) AS

  /*************************************************************
  Created By :Ramesh.Rengarajan
  Date Created By :5-FEB-2003
  Purpose : To Process Inquiry Programs
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  lv_msg_count NUMBER ;
  lv_msg_data      VARCHAR2(9000);
  lv_return_status VARCHAR2(1);
  lb_validation boolean ;
  l_sales_lead_line_id igr_i_a_lines.sales_lead_line_id%TYPE;
  lv_rowid VARCHAR2(100);
  l_records_processed NUMBER ;

  l_prog_label  VARCHAR2(100);
  l_error_code VARCHAR2(30);
  l_request_id NUMBER;
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_enable_log VARCHAR2(1);
  l_rowid VARCHAR2(25);
  l_error_text VARCHAR2(2000);
  l_type VARCHAR2(1);
  l_status VARCHAR2(1);


 BEGIN
   l_records_processed := 0;
   lb_validation := FALSE;
    IF (l_request_id IS NULL) THEN
         l_request_id := fnd_global.conc_request_id;
     END IF;

   /** Iterate in Cursor for Inquiry lines **/
   FOR v_inquiry_lines_rec IN  c_inquiry_lines  (p_interface_run_id) LOOP

     l_records_processed := l_records_processed + 1;
     SAVEPOINT perinqlin_save;

     validate_inquiry_lines (v_inquiry_lines_rec,lb_validation);

     IF lb_validation THEN

       BEGIN
         igr_inquiry_lines_pkg.insert_row (
                                        x_mode                              => 'R',
                                        x_rowid                             => lv_rowid,
                                        x_sales_lead_line_id                => l_sales_lead_line_id,
                                        x_person_id                         => v_inquiry_lines_rec.person_id,
                                        x_enquiry_appl_number               => v_inquiry_lines_rec.enquiry_appl_number,
                                        x_enquiry_dt                        => v_inquiry_lines_rec.inquiry_date,
                                        x_inquiry_method_code               => v_inquiry_lines_rec.inquiry_source_type,
                                        x_preference                        => v_inquiry_lines_rec.preference,
                                        x_ret_status                        => lv_return_status,
                                        x_msg_data                          => lv_msg_data,
                                        x_msg_count                         => lv_msg_count,
					x_product_category_id               => v_inquiry_lines_rec.product_category_id,
					x_product_category_set_id	    => v_inquiry_lines_rec.product_category_set_id
					);

           IF lv_return_status <>'U'  AND lv_msg_data IS NOT NULL THEN

             IF l_enable_log = 'Y' THEN
               igs_ad_imp_001.logerrormessage(v_inquiry_lines_rec.interface_inq_appl_id,lv_msg_data);
             END IF;

           ELSIF lv_return_status = 'U' THEN

             IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
               l_label :=  'igs.plsql.igr_imp_003.process_inquiry_lines.exception '||'E322';
               fnd_message.set_name('IGS','IGS_PE_IMP_DET_ERROR');
               fnd_message.set_token('CONTEXT',v_inquiry_lines_rec.interface_lines_id);
               fnd_message.set_token('ERROR', l_error_text);
               l_debug_str :=  fnd_message.get;
               fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
             END IF;

           END IF;

           IF lv_msg_data IS NOT NULL THEN

            /* Return status of Null should be treated as Success */
             IF NVL(lv_return_status,'S') = 'S'  THEN
               UPDATE igr_i_lines_int
               SET status = '4',
                        error_code = 'E702',
                              error_text = lv_msg_data
               WHERE rowid = v_inquiry_lines_rec.rowid;
             ELSE
               ROLLBACK TO perinqlin_save;
               UPDATE igr_i_lines_int
               SET  status = '3',
                        error_code = 'E322',
                              error_text = lv_msg_data
               WHERE rowid = v_inquiry_lines_rec.rowid;
             END IF;

           ELSE

      /* Return status of Null should be treated as Success */
          IF NVL(lv_return_status,'S') = 'S' THEN
               UPDATE igr_i_lines_int
               SET status = '1',
                        error_code = NULL,
                        error_text = NULL
               WHERE rowid = v_inquiry_lines_rec.rowid;
             ELSE

               l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E322', 8405);
               ROLLBACK TO perinqlin_save;
               UPDATE igr_i_lines_int
               SET status = '3',
                        error_code = 'E322',
                        error_text = l_error_text
                     WHERE rowid = v_inquiry_lines_rec.rowid;
             END IF;

           END IF;

       EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK TO perinqlin_save;
           l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E322', 8405);
           UPDATE igr_i_lines_int
           SET         status = '3',
                            error_code  = 'E322' ,
                            error_text = l_error_text
           WHERE  interface_lines_id  = v_inquiry_lines_rec.interface_lines_id;
       END;

     END IF;

     IF l_records_processed = 100 THEN
       COMMIT;
       l_records_processed := 0;
     END IF;

   END LOOP;

   IF l_records_processed < 100 AND l_records_processed > 0  THEN
     COMMIT;
   END IF;

 END process_inquiry_lines;

END IGR_IMP_003;

/
