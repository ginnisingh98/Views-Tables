--------------------------------------------------------
--  DDL for Package Body IGS_UC_APPLICANTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_APPLICANTS_PKG" AS
/* $Header: IGSXI01B.pls 120.3 2006/08/21 03:36:34 jbaber ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_applicants%ROWTYPE;
  new_references igs_uc_applicants%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_app_id                            IN     NUMBER      ,
    x_app_no                            IN     NUMBER      ,
    x_check_digit                       IN     NUMBER      ,
    x_enquiry_no                        IN     NUMBER      ,
    x_oss_person_id                     IN     NUMBER      ,
    x_application_source                IN     VARCHAR2    ,
    x_name_change_date                  IN     DATE        ,
    x_student_support                   IN     VARCHAR2    ,
    x_address_area                      IN     VARCHAR2    ,
    x_application_date                  IN     DATE        ,
    x_application_sent_date             IN     DATE        ,
    x_application_sent_run              IN     NUMBER      ,
    x_lea_code                          IN     NUMBER      ,
    x_fee_payer_code                    IN     NUMBER      ,
    x_fee_text                          IN     VARCHAR2    ,
    x_domicile_apr                      IN     NUMBER      ,
    x_code_changed_date                 IN     DATE        ,
    x_school                            IN     NUMBER      ,
    x_withdrawn                         IN     VARCHAR2    ,
    x_withdrawn_date                    IN     DATE        ,
    x_rel_to_clear_reason               IN     VARCHAR2    ,
    x_route_b                           IN     VARCHAR2    ,
    x_exam_change_date                  IN     DATE        ,
    x_a_levels                          IN     NUMBER      ,
    x_as_levels                         IN     NUMBER      ,
    x_highers                           IN     NUMBER      ,
    x_csys                              IN     NUMBER      ,
    x_winter                            IN     NUMBER      ,
    x_previous                          IN     NUMBER      ,
    x_gnvq                              IN     VARCHAR2    ,
    x_btec                              IN     VARCHAR2    ,
    x_ilc                               IN     VARCHAR2    ,
    x_ailc                              IN     VARCHAR2    ,
    x_ib                                IN     VARCHAR2    ,
    x_manual                            IN     VARCHAR2    ,
    x_reg_num                           IN     VARCHAR2    ,
    x_oeq                               IN     VARCHAR2    ,
    x_eas                               IN     VARCHAR2    ,
    x_roa                               IN     VARCHAR2    ,
    x_status                            IN     VARCHAR2    ,
    x_firm_now                          IN     NUMBER      ,
    x_firm_reply                        IN     NUMBER      ,
    x_insurance_reply                   IN     NUMBER      ,
    x_conf_hist_firm_reply              IN     NUMBER      ,
    x_conf_hist_ins_reply               IN     NUMBER      ,
    x_residential_category              IN     VARCHAR2    ,
    x_personal_statement                IN     LONG        ,
    x_match_prev                        IN     VARCHAR2    ,
    x_match_prev_date                   IN     DATE        ,
    x_match_winter                      IN     VARCHAR2    ,
    x_match_summer                      IN     VARCHAR2    ,
    x_gnvq_date                         IN     DATE        ,
    x_ib_date                           IN     DATE        ,
    x_ilc_date                          IN     DATE        ,
    x_ailc_date                         IN     DATE        ,
    x_gcseqa_date                       IN     DATE        ,
    x_uk_entry_date                     IN     DATE        ,
    x_prev_surname                      IN     VARCHAR2    ,
    x_criminal_convictions              IN     VARCHAR2    ,
    x_sent_to_hesa                      IN     VARCHAR2    ,
    x_sent_to_oss                       IN     VARCHAR2    ,
    x_batch_identifier                  IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    -- Added following 8 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_gce                               IN     NUMBER      ,
    x_vce                               IN     NUMBER      ,
    x_sqa                               IN     VARCHAR2    ,
    x_previousas                        IN     NUMBER      ,
    x_keyskills                         IN     VARCHAR2    ,
    x_vocational                        IN     VARCHAR2    ,
    x_scn                               IN     VARCHAR2    ,
    x_prevoeq                           IN     VARCHAR2    ,
    -- Added the following 5 columns as part of UCFD06 Build: Bug#2574566
    x_choices_transparent_ind           IN     VARCHAR2,
    x_extra_status                      IN     NUMBER  ,
    x_extra_passport_no                 IN     VARCHAR2,
    x_request_app_dets_ind              IN     VARCHAR2,
    x_request_copy_app_frm_ind          IN     VARCHAR2,
    x_cef_no                            IN     NUMBER,
      -- Added the following columns as part of UCFD102 Build: Bug#2643048
    x_system_code                 IN            VARCHAR2        ,
        x_gcse_eng                      IN              VARCHAR2        ,
        x_gcse_math                     IN              VARCHAR2        ,
        x_degree_subject                  IN            VARCHAR2        ,
        x_degree_status         IN              VARCHAR2        ,
        x_degree_class              IN          VARCHAR2        ,
        x_gcse_sci                      IN              VARCHAR2        ,
        x_welshspeaker              IN          VARCHAR2  ,
        x_ni_number                     IN              VARCHAR2,
        x_earliest_start            IN          VARCHAR2,
        x_near_inst                     IN              VARCHAR2,
        x_pref_reg                      IN              NUMBER  ,
        x_qual_eng                      IN              VARCHAR2,
        x_qual_math                     IN              VARCHAR2,
        x_qual_sci                      IN              VARCHAR2,
        x_main_qual                     IN              VARCHAR2,
        x_qual_5                          IN            VARCHAR2,
        x_future_serv                 IN                VARCHAR2,
        x_future_set                  IN                VARCHAR2,
        x_present_serv                  IN              VARCHAR2,
        x_present_set                 IN                VARCHAR2,
        x_curr_employment               IN              VARCHAR2,
        x_edu_qualification             IN              VARCHAR2,
	-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	x_ad_batch_id			IN		NUMBER,
	x_ad_interface_id		IN		NUMBER,
	x_nationality			IN		NUMBER,
	x_dual_nationality		IN		NUMBER,
	x_special_needs			IN		VARCHAR2,
	x_country_birth			IN		NUMBER,
	x_personal_id                   IN              VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali added columns for ucfd203 - multiple cycles bug#2669208
  ||  jchin         10-Mar-05        Modified for bug 4083559/4124006 convert null to 'n' for routeb
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_APPLICANTS
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.app_id                            := x_app_id;
    new_references.app_no                            := x_app_no;
    new_references.check_digit                       := x_check_digit;
    new_references.enquiry_no                        := x_enquiry_no;
    new_references.oss_person_id                     := x_oss_person_id;
    new_references.application_source                := x_application_source;
    new_references.name_change_date                  := x_name_change_date;
    new_references.student_support                   := x_student_support;
    new_references.address_area                      := x_address_area;
    new_references.application_date                  := x_application_date;
    new_references.application_sent_date             := x_application_sent_date;
    new_references.application_sent_run              := x_application_sent_run;
    new_references.lea_code                          := x_lea_code;
    new_references.fee_payer_code                    := x_fee_payer_code;
    new_references.fee_text                          := x_fee_text;
    new_references.domicile_apr                      := x_domicile_apr;
    new_references.code_changed_date                 := x_code_changed_date;
    new_references.school                            := x_school;
    new_references.withdrawn                         := x_withdrawn;
    new_references.withdrawn_date                    := x_withdrawn_date;
    new_references.rel_to_clear_reason               := x_rel_to_clear_reason;
    new_references.route_b                           := NVL(x_route_b, 'N');
    new_references.exam_change_date                  := x_exam_change_date;
    new_references.a_levels                          := x_a_levels;
    new_references.as_levels                         := x_as_levels;
    new_references.highers                           := x_highers;
    new_references.csys                              := x_csys;
    new_references.winter                            := x_winter;
    new_references.previous                          := x_previous;
    new_references.gnvq                              := x_gnvq;
    new_references.btec                              := x_btec;
    new_references.ilc                               := x_ilc;
    new_references.ailc                              := x_ailc;
    new_references.ib                                := x_ib;
    new_references.manual                            := x_manual;
    new_references.reg_num                           := x_reg_num;
    new_references.oeq                               := x_oeq;
    new_references.eas                               := x_eas;
    new_references.roa                               := x_roa;
    new_references.status                            := x_status;
    new_references.firm_now                          := x_firm_now;
    new_references.firm_reply                        := x_firm_reply;
    new_references.insurance_reply                   := x_insurance_reply;
    new_references.conf_hist_firm_reply              := x_conf_hist_firm_reply;
    new_references.conf_hist_ins_reply               := x_conf_hist_ins_reply;
    new_references.residential_category              := x_residential_category;
    new_references.personal_statement                := x_personal_statement;
    new_references.match_prev                        := x_match_prev;
    new_references.match_prev_date                   := x_match_prev_date;
    new_references.match_winter                      := x_match_winter;
    new_references.match_summer                      := x_match_summer;
    new_references.gnvq_date                         := x_gnvq_date;
    new_references.ib_date                           := x_ib_date;
    new_references.ilc_date                          := x_ilc_date;
    new_references.ailc_date                         := x_ailc_date;
    new_references.gcseqa_date                       := x_gcseqa_date;
    new_references.uk_entry_date                     := x_uk_entry_date;
    new_references.prev_surname                      := x_prev_surname;
    new_references.criminal_convictions              := x_criminal_convictions;
    new_references.sent_to_hesa                      := x_sent_to_hesa;
    new_references.sent_to_oss                       := x_sent_to_oss;
    new_references.batch_identifier                  := x_batch_identifier;
    new_references.gce                               := x_gce;
    new_references.vce                               := x_vce;
    new_references.sqa                               := x_sqa;
    new_references.previousas                        := x_previousas;
    new_references.keyskills                         := x_keyskills;
    new_references.vocational                        := x_vocational;
    new_references.scn                               := x_scn;
    new_references.prevoeq                           := x_prevoeq;

    new_references.choices_transparent_ind           := x_choices_transparent_ind;
    new_references.extra_status                      := x_extra_status;
    new_references.extra_passport_no                 := x_extra_passport_no;
    new_references.request_app_dets_ind              := x_request_app_dets_ind;
    new_references.request_copy_app_frm_ind          := x_request_copy_app_frm_ind;
    new_references.cef_no                            := x_cef_no;
      new_references.system_code                :=            x_system_code     ;
      new_references.gcse_eng         :=              x_gcse_eng        ;
      new_references.gcse_math        :=              x_gcse_math       ;
      new_references.degree_subject     :=              x_degree_subject        ;
      new_references.degree_status        :=          x_degree_status   ;
      new_references.degree_class         :=          x_degree_class    ;
      new_references.gcse_sci         :=              x_gcse_sci        ;
      new_references.welshspeaker           :=      x_welshspeaker      ;
      new_references.ni_number      :=          x_ni_number     ;
      new_references.earliest_start         :=    x_earliest_start      ;
      new_references.near_inst              :=  x_near_inst     ;
      new_references.pref_reg       :=          x_pref_reg      ;
      new_references.qual_eng       :=          x_qual_eng      ;
      new_references.qual_math      :=          x_qual_math     ;
      new_references.qual_sci       :=          x_qual_sci      ;
      new_references.main_qual              :=  x_main_qual     ;
      new_references.qual_5         :=                  x_qual_5        ;
      new_references.future_serv            :=        x_future_serv     ;
      new_references.future_set     :=        x_future_set      ;
      new_references.present_serv           :=  x_present_serv  ;
      new_references.present_set            :=        x_present_set     ;
      new_references.curr_employment        :=    x_curr_employment     ;
      new_references.edu_qualification      :=  x_edu_qualification     ;
      -- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
      new_references.ad_batch_id            :=        x_ad_batch_id     ;
      new_references.ad_interface_id	    :=        x_ad_interface_id ;
      new_references.nationality            :=	      x_nationality  ;
      new_references.dual_nationality       :=        x_dual_nationality     ;
      new_references.special_needs          :=        x_special_needs     ;
      new_references.country_birth          :=        x_country_birth    ;
      new_references.personal_id            :=        x_personal_id    ;





    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
    END IF;

    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;

  END set_column_values;



  PROCEDURE check_child_existance IS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 6-jun-03 added new child checks for bug#2669208 UCFD203 - multiple cycles build
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_uc_app_choices_pkg.get_fk_igs_uc_applicants (
      old_references.app_id
    );

    igs_uc_app_clearing_pkg.get_fk_igs_uc_applicants (
      old_references.app_id
    );

    igs_uc_app_stats_pkg.get_fk_igs_uc_applicants (
      old_references.app_id
    );

    igs_uc_app_results_pkg.get_fk_igs_uc_applicants(
    old_references.app_id
    );

    -- smaddali added these new child checks as part of bug#2669208 - ucfd203 multiple cycles build
    igs_uc_app_addreses_pkg.get_ufk_igs_uc_applicants(
    old_references.app_no
    );

    igs_uc_app_names_pkg.get_ufk_igs_uc_applicants(
    old_references.app_no
    );

    igs_uc_app_referees_pkg.get_ufk_igs_uc_applicants(
    old_references.app_no
    );

    igs_uc_form_quals_pkg.get_ufk_igs_uc_applicants(
    old_references.app_no
    );

  END check_child_existance;



 PROCEDURE check_parent_existance AS
  /*
  ||  Created By : bayadav
  ||  Created On : 11-NOV-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || smaddali 6-jun-03 modified igs_uc_adm_systems_pkg.get_uk_for_validation with
  ||     igs_uc_defaults_pkg.get_pk_for_validation for UCFD203 - bug#2669208
  */
  BEGIN

    IF ((old_references.system_code = new_references.system_code)  OR
        (new_references.system_code IS NULL)) THEN
      NULL;
    ELSIF NOT igs_uc_defaults_pkg.get_pk_for_validation (
                new_references.system_code
                ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.oss_person_id = new_references.oss_person_id)) OR
        ((new_references.oss_person_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_person_pkg.get_pk_for_validation (
                new_references.oss_person_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


   PROCEDURE check_uniqueness AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

   IF ( get_uk_for_validation(new_references.app_no)
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
     app_exception.raise_exception;
   END IF;


  END check_uniqueness;




  PROCEDURE get_fk_igs_uc_defaults (
    x_system_code                         IN VARCHAR2
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 6-jun-03
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_applicants
      WHERE   ((system_code = x_system_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCAP_UAS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_defaults;

  PROCEDURE get_fk_igs_pe_person (
    x_oss_person_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : rbezawad
  ||  Created On : 12-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_applicants
      WHERE   ((oss_person_id = x_oss_person_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCAP_PE_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pe_person;

  FUNCTION get_pk_for_validation (
    x_app_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_applicants
      WHERE    app_id = x_app_id      ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_pk_for_validation;


FUNCTION get_uk_for_validation (
    x_app_no                       IN    NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : bayadav
  ||  Created On : 23-OCT-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  Pmarada        17-dec-02     Added the rowid where condition in the cursor
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_applicants
      WHERE    app_no = x_app_no
      AND  ((l_rowid IS NULL) OR (rowid <> l_rowid))      ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_app_id                            IN     NUMBER      ,
    x_app_no                            IN     NUMBER      ,
    x_check_digit                       IN     NUMBER      ,
    x_enquiry_no                        IN     NUMBER      ,
    x_oss_person_id                     IN     NUMBER      ,
    x_application_source                IN     VARCHAR2    ,
    x_name_change_date                  IN     DATE        ,
    x_student_support                   IN     VARCHAR2    ,
    x_address_area                      IN     VARCHAR2    ,
    x_application_date                  IN     DATE        ,
    x_application_sent_date             IN     DATE        ,
    x_application_sent_run              IN     NUMBER      ,
    x_lea_code                          IN     NUMBER      ,
    x_fee_payer_code                    IN     NUMBER      ,
    x_fee_text                          IN     VARCHAR2    ,
    x_domicile_apr                      IN     NUMBER      ,
    x_code_changed_date                 IN     DATE        ,
    x_school                            IN     NUMBER      ,
    x_withdrawn                         IN     VARCHAR2    ,
    x_withdrawn_date                    IN     DATE        ,
    x_rel_to_clear_reason               IN     VARCHAR2    ,
    x_route_b                           IN     VARCHAR2    ,
    x_exam_change_date                  IN     DATE        ,
    x_a_levels                          IN     NUMBER      ,
    x_as_levels                         IN     NUMBER      ,
    x_highers                           IN     NUMBER      ,
    x_csys                              IN     NUMBER      ,
    x_winter                            IN     NUMBER      ,
    x_previous                          IN     NUMBER      ,
    x_gnvq                              IN     VARCHAR2    ,
    x_btec                              IN     VARCHAR2    ,
    x_ilc                               IN     VARCHAR2    ,
    x_ailc                              IN     VARCHAR2    ,
    x_ib                                IN     VARCHAR2    ,
    x_manual                            IN     VARCHAR2    ,
    x_reg_num                           IN     VARCHAR2    ,
    x_oeq                               IN     VARCHAR2    ,
    x_eas                               IN     VARCHAR2    ,
    x_roa                               IN     VARCHAR2    ,
    x_status                            IN     VARCHAR2    ,
    x_firm_now                          IN     NUMBER      ,
    x_firm_reply                        IN     NUMBER      ,
    x_insurance_reply                   IN     NUMBER      ,
    x_conf_hist_firm_reply              IN     NUMBER      ,
    x_conf_hist_ins_reply               IN     NUMBER      ,
    x_residential_category              IN     VARCHAR2    ,
    x_personal_statement                IN     LONG        ,
    x_match_prev                        IN     VARCHAR2    ,
    x_match_prev_date                   IN     DATE        ,
    x_match_winter                      IN     VARCHAR2    ,
    x_match_summer                      IN     VARCHAR2    ,
    x_gnvq_date                         IN     DATE        ,
    x_ib_date                           IN     DATE        ,
    x_ilc_date                          IN     DATE        ,
    x_ailc_date                         IN     DATE        ,
    x_gcseqa_date                       IN     DATE        ,
    x_uk_entry_date                     IN     DATE        ,
    x_prev_surname                      IN     VARCHAR2    ,
    x_criminal_convictions              IN     VARCHAR2    ,
    x_sent_to_hesa                      IN     VARCHAR2    ,
    x_sent_to_oss                       IN     VARCHAR2    ,
    x_batch_identifier                  IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    -- Added following 8 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_gce                               IN     NUMBER      ,
    x_vce                               IN     NUMBER      ,
    x_sqa                               IN     VARCHAR2    ,
    x_previousas                        IN     NUMBER      ,
    x_keyskills                         IN     VARCHAR2    ,
    x_vocational                        IN     VARCHAR2    ,
    x_scn                               IN     VARCHAR2    ,
    x_prevoeq                           IN     VARCHAR2    ,
    x_choices_transparent_ind           IN     VARCHAR2,
    x_extra_status                      IN     NUMBER,
    x_extra_passport_no                 IN     VARCHAR2,
    x_request_app_dets_ind              IN     VARCHAR2,
    x_request_copy_app_frm_ind          IN     VARCHAR2,
    x_cef_no                            IN     NUMBER,
    -- Added the following columns as part of UCFD102 Build: Bug#2643048
    x_system_code                 IN            VARCHAR2        ,
        x_gcse_eng                      IN              VARCHAR2        ,
        x_gcse_math                     IN              VARCHAR2        ,
        x_degree_subject                  IN            VARCHAR2        ,
        x_degree_status         IN              VARCHAR2        ,
        x_degree_class              IN          VARCHAR2        ,
        x_gcse_sci                      IN              VARCHAR2        ,
        x_welshspeaker              IN          VARCHAR2  ,
        x_ni_number                     IN              VARCHAR2,
        x_earliest_start            IN          VARCHAR2,
        x_near_inst                     IN              VARCHAR2,
        x_pref_reg                      IN              NUMBER  ,
        x_qual_eng                      IN              VARCHAR2,
        x_qual_math                     IN              VARCHAR2,
        x_qual_sci                      IN              VARCHAR2,
        x_main_qual                     IN              VARCHAR2,
        x_qual_5                          IN            VARCHAR2,
        x_future_serv                 IN                VARCHAR2,
        x_future_set                  IN                VARCHAR2,
        x_present_serv                  IN              VARCHAR2,
        x_present_set                 IN                VARCHAR2,
        x_curr_employment               IN              VARCHAR2,
        x_edu_qualification             IN              VARCHAR2,
	-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	x_ad_batch_id			IN		NUMBER,
	x_ad_interface_id		IN		NUMBER,
	x_nationality			IN		NUMBER,
	x_dual_nationality		IN		NUMBER,
	x_special_needs			IN		VARCHAR2,
	x_country_birth			IN		NUMBER,
	x_personal_id                   IN              VARCHAR2

  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali added columns for ucfd203 - multiple cycles bug#2669208
  ||  (reverse chronological order - newest change first)
  ||  dsridhar        27-AUG-2003      Bug No: 3087784. Resetting the value of l_rowid to NULL.
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_app_id,
      x_app_no,
      x_check_digit,
      x_enquiry_no,
      x_oss_person_id,
      x_application_source,
      x_name_change_date,
      x_student_support,
      x_address_area,
      x_application_date,
      x_application_sent_date,
      x_application_sent_run,
      x_lea_code,
      x_fee_payer_code,
      x_fee_text,
      x_domicile_apr,
      x_code_changed_date,
      x_school,
      x_withdrawn,
      x_withdrawn_date,
      x_rel_to_clear_reason,
      x_route_b,
      x_exam_change_date,
      x_a_levels,
      x_as_levels,
      x_highers,
      x_csys,
      x_winter,
      x_previous,
      x_gnvq,
      x_btec,
      x_ilc,
      x_ailc,
      x_ib,
      x_manual,
      x_reg_num,
      x_oeq,
      x_eas,
      x_roa,
      x_status,
      x_firm_now,
      x_firm_reply,
      x_insurance_reply,
      x_conf_hist_firm_reply,
      x_conf_hist_ins_reply,
      x_residential_category,
      x_personal_statement,
      x_match_prev,
      x_match_prev_date,
      x_match_winter,
      x_match_summer,
      x_gnvq_date,
      x_ib_date,
      x_ilc_date,
      x_ailc_date,
      x_gcseqa_date,
      x_uk_entry_date,
      x_prev_surname,
      x_criminal_convictions,
      x_sent_to_hesa,
      x_sent_to_oss,
      x_batch_identifier,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_gce,
      x_vce,
      x_sqa,
      x_previousas,
      x_keyskills,
      x_vocational,
      x_scn,
      x_prevoeq,
      x_choices_transparent_ind,
      x_extra_status           ,
      x_extra_passport_no       ,
      x_request_app_dets_ind   ,
      x_request_copy_app_frm_ind,
      x_cef_no,
       x_system_code            ,
        x_gcse_eng                    ,
        x_gcse_math                   ,
        x_degree_subject                ,
        x_degree_status     ,
        x_degree_class            ,
        x_gcse_sci                    ,
        x_welshspeaker            ,
        x_ni_number                   ,
        x_earliest_start          ,
        x_near_inst             ,
        x_pref_reg              ,
        x_qual_eng              ,
        x_qual_math                   ,
        x_qual_sci                    ,
        x_main_qual             ,
        x_qual_5                        ,
        x_future_serv               ,
        x_future_set                ,
        x_present_serv          ,
        x_present_set               ,
        x_curr_employment         ,
        x_edu_qualification	,
	-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	x_ad_batch_id		,
	x_ad_interface_id	,
	x_nationality		,
	x_dual_nationality	,
	x_special_needs		,
	x_country_birth		,
	x_personal_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.app_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.app_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

    -- Bug No: 3087784. Resetting the value of l_rowid to NULL.
    IF (p_action IN ('VALIDATE_INSERT', 'VALIDATE_UPDATE', 'VALIDATE_DELETE')) THEN
      l_rowid := NULL;
    END IF;

  END before_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_id                            IN OUT NOCOPY NUMBER,
    x_app_no                            IN     NUMBER,
    x_check_digit                       IN     NUMBER,
    x_enquiry_no                        IN OUT NOCOPY NUMBER,
    x_oss_person_id                     IN     NUMBER,
    x_application_source                IN     VARCHAR2,
    x_name_change_date                  IN     DATE,
    x_student_support                   IN     VARCHAR2,
    x_address_area                      IN     VARCHAR2,
    x_application_date                  IN     DATE,
    x_application_sent_date             IN     DATE,
    x_application_sent_run              IN     NUMBER,
    x_lea_code                          IN     NUMBER,
    x_fee_payer_code                    IN     NUMBER,
    x_fee_text                          IN     VARCHAR2,
    x_domicile_apr                      IN     NUMBER,
    x_code_changed_date                 IN     DATE,
    x_school                            IN     NUMBER,
    x_withdrawn                         IN     VARCHAR2,
    x_withdrawn_date                    IN     DATE,
    x_rel_to_clear_reason               IN     VARCHAR2,
    x_route_b                           IN     VARCHAR2,
    x_exam_change_date                  IN     DATE,
    x_a_levels                          IN     NUMBER,
    x_as_levels                         IN     NUMBER,
    x_highers                           IN     NUMBER,
    x_csys                              IN     NUMBER,
    x_winter                            IN     NUMBER,
    x_previous                          IN     NUMBER,
    x_gnvq                              IN     VARCHAR2,
    x_btec                              IN     VARCHAR2,
    x_ilc                               IN     VARCHAR2,
    x_ailc                              IN     VARCHAR2,
    x_ib                                IN     VARCHAR2,
    x_manual                            IN     VARCHAR2,
    x_reg_num                           IN     VARCHAR2,
    x_oeq                               IN     VARCHAR2,
    x_eas                               IN     VARCHAR2,
    x_roa                               IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_firm_now                          IN     NUMBER,
    x_firm_reply                        IN     NUMBER,
    x_insurance_reply                   IN     NUMBER,
    x_conf_hist_firm_reply              IN     NUMBER,
    x_conf_hist_ins_reply               IN     NUMBER,
    x_residential_category              IN     VARCHAR2,
    x_personal_statement                IN     LONG,
    x_match_prev                        IN     VARCHAR2,
    x_match_prev_date                   IN     DATE,
    x_match_winter                      IN     VARCHAR2,
    x_match_summer                      IN     VARCHAR2,
    x_gnvq_date                         IN     DATE,
    x_ib_date                           IN     DATE,
    x_ilc_date                          IN     DATE,
    x_ailc_date                         IN     DATE,
    x_gcseqa_date                       IN     DATE,
    x_uk_entry_date                     IN     DATE,
    x_prev_surname                      IN     VARCHAR2,
    x_criminal_convictions              IN     VARCHAR2,
    x_sent_to_hesa                      IN     VARCHAR2,
    x_sent_to_oss                       IN     VARCHAR2,
    x_batch_identifier                  IN     NUMBER,
    x_mode                              IN     VARCHAR2 ,
    -- Added following 8 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_gce                               IN     NUMBER      ,
    x_vce                               IN     NUMBER      ,
    x_sqa                               IN     VARCHAR2    ,
    x_previousas                        IN     NUMBER      ,
    x_keyskills                         IN     VARCHAR2    ,
    x_vocational                        IN     VARCHAR2    ,
    x_scn                               IN     VARCHAR2    ,
    x_prevoeq                           IN     VARCHAR2    ,
    x_choices_transparent_ind           IN     VARCHAR2,
    x_extra_status                      IN     NUMBER,
    x_extra_passport_no                 IN     VARCHAR2,
    x_request_app_dets_ind              IN     VARCHAR2,
    x_request_copy_app_frm_ind          IN     VARCHAR2,
    x_cef_no                            IN     NUMBER,
      -- Added the following columns as part of UCFD102 Build: Bug#2643048
    x_system_code                 IN            VARCHAR2        ,
        x_gcse_eng                      IN              VARCHAR2        ,
        x_gcse_math                     IN              VARCHAR2        ,
        x_degree_subject                  IN            VARCHAR2        ,
        x_degree_status         IN              VARCHAR2        ,
        x_degree_class              IN          VARCHAR2        ,
        x_gcse_sci                      IN              VARCHAR2        ,
        x_welshspeaker              IN          VARCHAR2  ,
        x_ni_number                     IN              VARCHAR2,
        x_earliest_start            IN          VARCHAR2,
        x_near_inst                     IN              VARCHAR2,
        x_pref_reg                      IN              NUMBER  ,
        x_qual_eng                      IN              VARCHAR2,
        x_qual_math                     IN              VARCHAR2,
        x_qual_sci                      IN              VARCHAR2,
        x_main_qual                     IN              VARCHAR2,
        x_qual_5                          IN            VARCHAR2,
        x_future_serv                 IN                VARCHAR2,
        x_future_set                  IN                VARCHAR2,
        x_present_serv                  IN              VARCHAR2,
        x_present_set                 IN                VARCHAR2,
        x_curr_employment               IN              VARCHAR2,
        x_edu_qualification             IN              VARCHAR2,
	-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	x_ad_batch_id			IN		NUMBER,
	x_ad_interface_id		IN		NUMBER,
	x_nationality			IN		NUMBER,
	x_dual_nationality		IN		NUMBER,
	x_special_needs			IN		VARCHAR2,
	x_country_birth			IN		NUMBER,
	x_personal_id                   IN              VARCHAR2
) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  Nishikant       24SEP2002       The value for the column enquiry_no was being populated from a sequence
  ||                                  igs_uc_applicants_s2 which is removed now. UCFD06-Bug#2574566.
  ||  smaddali added columns for ucfd203 - multiple cycles bug#2669208
  ||  (reverse chronological order - newest change first)
  ||  dsridhar        27-AUG-2003      Bug No: 3087784. Resetting the value of l_rowid to NULL.
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_applicants
      WHERE    app_id                            = x_app_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (X_MODE IN ('R', 'S')) THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT    igs_uc_applicants_s1.NEXTVAL
    INTO      x_app_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_app_id                            => x_app_id,
      x_app_no                            => x_app_no,
      x_check_digit                       => x_check_digit,
      x_enquiry_no                        => x_enquiry_no,
      x_oss_person_id                     => x_oss_person_id,
      x_application_source                => x_application_source,
      x_name_change_date                  => x_name_change_date,
      x_student_support                   => x_student_support,
      x_address_area                      => x_address_area,
      x_application_date                  => x_application_date,
      x_application_sent_date             => x_application_sent_date,
      x_application_sent_run              => x_application_sent_run,
      x_lea_code                          => x_lea_code,
      x_fee_payer_code                    => x_fee_payer_code,
      x_fee_text                          => x_fee_text,
      x_domicile_apr                      => x_domicile_apr,
      x_code_changed_date                 => x_code_changed_date,
      x_school                            => x_school,
      x_withdrawn                         => x_withdrawn,
      x_withdrawn_date                    => x_withdrawn_date,
      x_rel_to_clear_reason               => x_rel_to_clear_reason,
      x_route_b                           => x_route_b,
      x_exam_change_date                  => x_exam_change_date,
      x_a_levels                          => x_a_levels,
      x_as_levels                         => x_as_levels,
      x_highers                           => x_highers,
      x_csys                              => x_csys,
      x_winter                            => x_winter,
      x_previous                          => x_previous,
      x_gnvq                              => x_gnvq,
      x_btec                              => x_btec,
      x_ilc                               => x_ilc,
      x_ailc                              => x_ailc,
      x_ib                                => x_ib,
      x_manual                            => x_manual,
      x_reg_num                           => x_reg_num,
      x_oeq                               => x_oeq,
      x_eas                               => x_eas,
      x_roa                               => x_roa,
      x_status                            => x_status,
      x_firm_now                          => x_firm_now,
      x_firm_reply                        => x_firm_reply,
      x_insurance_reply                   => x_insurance_reply,
      x_conf_hist_firm_reply              => x_conf_hist_firm_reply,
      x_conf_hist_ins_reply               => x_conf_hist_ins_reply,
      x_residential_category              => x_residential_category,
      x_personal_statement                => x_personal_statement,
      x_match_prev                        => x_match_prev,
      x_match_prev_date                   => x_match_prev_date,
      x_match_winter                      => x_match_winter,
      x_match_summer                      => x_match_summer,
      x_gnvq_date                         => x_gnvq_date,
      x_ib_date                           => x_ib_date,
      x_ilc_date                          => x_ilc_date,
      x_ailc_date                         => x_ailc_date,
      x_gcseqa_date                       => x_gcseqa_date,
      x_uk_entry_date                     => x_uk_entry_date,
      x_prev_surname                      => x_prev_surname,
      x_criminal_convictions              => x_criminal_convictions,
      x_sent_to_hesa                      => x_sent_to_hesa,
      x_sent_to_oss                       => x_sent_to_oss,
      x_batch_identifier                  => x_batch_identifier,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_gce                               => x_gce,
      x_vce                               => x_vce,
      x_sqa                               => x_sqa,
      x_previousas                        => x_previousas,
      x_keyskills                         => x_keyskills,
      x_vocational                        => x_vocational,
      x_scn                               => x_scn,
      x_prevoeq                           => x_prevoeq ,
      x_choices_transparent_ind           => x_choices_transparent_ind ,
      x_extra_status                      => x_extra_status             ,
      x_extra_passport_no                 => x_extra_passport_no        ,
      x_request_app_dets_ind              => x_request_app_dets_ind    ,
      x_request_copy_app_frm_ind          => x_request_copy_app_frm_ind,
      x_cef_no                            => x_cef_no,
      x_system_code         =>  x_system_code   ,
      x_gcse_eng            =>  x_gcse_eng      ,
      x_gcse_math           =>  x_gcse_math     ,
      x_degree_subject      =>  x_degree_subject        ,
      x_degree_status       =>  x_degree_status ,
      x_degree_class        =>  x_degree_class  ,
      x_gcse_sci            =>  x_gcse_sci      ,
      x_welshspeaker        =>  x_welshspeaker  ,
      x_ni_number           =>  x_ni_number     ,
      x_earliest_start      =>  x_earliest_start        ,
      x_near_inst           =>  x_near_inst     ,
     x_pref_reg     =>  x_pref_reg      ,
x_qual_eng          =>  x_qual_eng      ,
x_qual_math         =>  x_qual_math     ,
x_qual_sci          =>  x_qual_sci      ,
x_main_qual         =>  x_main_qual     ,
x_qual_5            =>  x_qual_5        ,
x_future_serv       =>  x_future_serv   ,
x_future_set        =>  x_future_set    ,
x_present_serv      =>  x_present_serv  ,
x_present_set       =>  x_present_set   ,
x_curr_employment           =>  x_curr_employment       ,
x_edu_qualification         =>  x_edu_qualification	,
-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	x_ad_batch_id		=> x_ad_batch_id	,
	x_ad_interface_id	=> x_ad_interface_id	,
	x_nationality		=> x_nationality	,
	x_dual_nationality	=> x_dual_nationality	,
	x_special_needs		=> x_special_needs	,
	x_country_birth		=> x_country_birth      ,
	x_personal_id           => x_personal_id
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_uc_applicants (
      app_id,
      app_no,
      check_digit,
      enquiry_no,
      oss_person_id,
      application_source,
      name_change_date,
      student_support,
      address_area,
      application_date,
      application_sent_date,
      application_sent_run,
      lea_code,
      fee_payer_code,
      fee_text,
      domicile_apr,
      code_changed_date,
      school,
      withdrawn,
      withdrawn_date,
      rel_to_clear_reason,
      route_b,
      exam_change_date,
      a_levels,
      as_levels,
      highers,
      csys,
      winter,
      previous,
      gnvq,
      btec,
      ilc,
      ailc,
      ib,
      manual,
      reg_num,
      oeq,
      eas,
      roa,
      status,
      firm_now,
      firm_reply,
      insurance_reply,
      conf_hist_firm_reply,
      conf_hist_ins_reply,
      residential_category,
      personal_statement,
      match_prev,
      match_prev_date,
      match_winter,
      match_summer,
      gnvq_date,
      ib_date,
      ilc_date,
      ailc_date,
      gcseqa_date,
      uk_entry_date,
      prev_surname,
      criminal_convictions,
      sent_to_hesa,
      sent_to_oss,
      batch_identifier,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      gce,
      vce,
      sqa,
      previousas,
      keyskills,
      vocational,
      scn,
      prevoeq   ,
      choices_transparent_ind,
      extra_status,
      extra_passport_no,
      request_app_dets_ind,
      request_copy_app_frm_ind,
      cef_no,
        system_code             ,
        gcse_eng                      ,
        gcse_math                     ,
        degree_subject          ,
        degree_status       ,
        degree_class              ,
        gcse_sci                      ,
        welshspeaker              ,
        ni_number                     ,
        earliest_start    ,
        near_inst               ,
        pref_reg                ,
        qual_eng                ,
        qual_math                     ,
        qual_sci                      ,
        main_qual               ,
        qual_5                  ,
        future_serv                 ,
        future_set                  ,
        present_serv            ,
        present_set                 ,
        curr_employment   ,
        edu_qualification ,
      	-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	ad_batch_id		,
	ad_interface_id		,
	nationality		,
	dual_nationality	,
	special_needs		,
	country_birth	        ,
	personal_id
    ) VALUES (
      new_references.app_id,
      new_references.app_no,
      new_references.check_digit,
      new_references.enquiry_no,
      new_references.oss_person_id,
      new_references.application_source,
      new_references.name_change_date,
      new_references.student_support,
      new_references.address_area,
      new_references.application_date,
      new_references.application_sent_date,
      new_references.application_sent_run,
      new_references.lea_code,
      new_references.fee_payer_code,
      new_references.fee_text,
      new_references.domicile_apr,
      new_references.code_changed_date,
      new_references.school,
      new_references.withdrawn,
      new_references.withdrawn_date,
      new_references.rel_to_clear_reason,
      new_references.route_b,
      new_references.exam_change_date,
      new_references.a_levels,
      new_references.as_levels,
      new_references.highers,
      new_references.csys,
      new_references.winter,
      new_references.previous,
      new_references.gnvq,
      new_references.btec,
      new_references.ilc,
      new_references.ailc,
      new_references.ib,
      new_references.manual,
      new_references.reg_num,
      new_references.oeq,
      new_references.eas,
      new_references.roa,
      new_references.status,
      new_references.firm_now,
      new_references.firm_reply,
      new_references.insurance_reply,
      new_references.conf_hist_firm_reply,
      new_references.conf_hist_ins_reply,
      new_references.residential_category,
      new_references.personal_statement,
      new_references.match_prev,
      new_references.match_prev_date,
      new_references.match_winter,
      new_references.match_summer,
      new_references.gnvq_date,
      new_references.ib_date,
      new_references.ilc_date,
      new_references.ailc_date,
      new_references.gcseqa_date,
      new_references.uk_entry_date,
      new_references.prev_surname,
      new_references.criminal_convictions,
      new_references.sent_to_hesa,
      new_references.sent_to_oss,
      new_references.batch_identifier,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.gce,
      new_references.vce,
      new_references.sqa,
      new_references.previousas,
      new_references.keyskills,
      new_references.vocational,
      new_references.scn,
      new_references.prevoeq,
      new_references.choices_transparent_ind,
      new_references.extra_status,
      new_references.extra_passport_no,
      new_references.request_app_dets_ind,
      new_references.request_copy_app_frm_ind,
      new_references.cef_no,
      new_references.system_code                ,
      new_references.gcse_eng                 ,
      new_references.gcse_math                ,
      new_references.degree_subject             ,
      new_references.degree_status          ,
      new_references.degree_class                 ,
      new_references.gcse_sci                 ,
      new_references.welshspeaker                 ,
      new_references.ni_number                ,
      new_references.earliest_start       ,
      new_references.near_inst          ,
      new_references.pref_reg           ,
      new_references.qual_eng           ,
      new_references.qual_math                ,
      new_references.qual_sci                 ,
      new_references.main_qual          ,
      new_references.qual_5                     ,
      new_references.future_serv                    ,
      new_references.future_set             ,
      new_references.present_serv       ,
      new_references.present_set                    ,
      new_references.curr_employment      ,
      new_references.edu_qualification	,
      	-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	new_references.ad_batch_id	,
	new_references.ad_interface_id		,
	new_references.nationality			,
	new_references.dual_nationality		,
	new_references.special_needs			,
	new_references.country_birth			,
	new_references.personal_id
    );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

    -- Bug No: 3087784. Resetting the value of l_rowid to NULL.
    l_rowid := NULL;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_check_digit                       IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_oss_person_id                     IN     NUMBER,
    x_application_source                IN     VARCHAR2,
    x_name_change_date                  IN     DATE,
    x_student_support                   IN     VARCHAR2,
    x_address_area                      IN     VARCHAR2,
    x_application_date                  IN     DATE,
    x_application_sent_date             IN     DATE,
    x_application_sent_run              IN     NUMBER,
    x_lea_code                          IN     NUMBER,
    x_fee_payer_code                    IN     NUMBER,
    x_fee_text                          IN     VARCHAR2,
    x_domicile_apr                      IN     NUMBER,
    x_code_changed_date                 IN     DATE,
    x_school                            IN     NUMBER,
    x_withdrawn                         IN     VARCHAR2,
    x_withdrawn_date                    IN     DATE,
    x_rel_to_clear_reason               IN     VARCHAR2,
    x_route_b                           IN     VARCHAR2,
    x_exam_change_date                  IN     DATE,
    x_a_levels                          IN     NUMBER,
    x_as_levels                         IN     NUMBER,
    x_highers                           IN     NUMBER,
    x_csys                              IN     NUMBER,
    x_winter                            IN     NUMBER,
    x_previous                          IN     NUMBER,
    x_gnvq                              IN     VARCHAR2,
    x_btec                              IN     VARCHAR2,
    x_ilc                               IN     VARCHAR2,
    x_ailc                              IN     VARCHAR2,
    x_ib                                IN     VARCHAR2,
    x_manual                            IN     VARCHAR2,
    x_reg_num                           IN     VARCHAR2,
    x_oeq                               IN     VARCHAR2,
    x_eas                               IN     VARCHAR2,
    x_roa                               IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_firm_now                          IN     NUMBER,
    x_firm_reply                        IN     NUMBER,
    x_insurance_reply                   IN     NUMBER,
    x_conf_hist_firm_reply              IN     NUMBER,
    x_conf_hist_ins_reply               IN     NUMBER,
    x_residential_category              IN     VARCHAR2,
    x_personal_statement                IN     LONG,
    x_match_prev                        IN     VARCHAR2,
    x_match_prev_date                   IN     DATE,
    x_match_winter                      IN     VARCHAR2,
    x_match_summer                      IN     VARCHAR2,
    x_gnvq_date                         IN     DATE,
    x_ib_date                           IN     DATE,
    x_ilc_date                          IN     DATE,
    x_ailc_date                         IN     DATE,
    x_gcseqa_date                       IN     DATE,
    x_uk_entry_date                     IN     DATE,
    x_prev_surname                      IN     VARCHAR2,
    x_criminal_convictions              IN     VARCHAR2,
    x_sent_to_hesa                      IN     VARCHAR2,
    x_sent_to_oss                       IN     VARCHAR2,
    x_batch_identifier                  IN     NUMBER,
    -- Added following 8 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_gce                               IN     NUMBER      ,
    x_vce                               IN     NUMBER      ,
    x_sqa                               IN     VARCHAR2    ,
    x_previousas                        IN     NUMBER      ,
    x_keyskills                         IN     VARCHAR2    ,
    x_vocational                        IN     VARCHAR2    ,
    x_scn                               IN     VARCHAR2    ,
    x_prevoeq                           IN     VARCHAR2   ,
    x_choices_transparent_ind           IN     VARCHAR2,
    x_extra_status                      IN     NUMBER,
    x_extra_passport_no                 IN     VARCHAR2,
    x_request_app_dets_ind              IN     VARCHAR2,
    x_request_copy_app_frm_ind          IN     VARCHAR2,
    x_cef_no                            IN     NUMBER,
       -- Added the following columns as part of UCFD102 Build: Bug#2643048
    x_system_code                 IN            VARCHAR2        ,
        x_gcse_eng                      IN              VARCHAR2        ,
        x_gcse_math                     IN              VARCHAR2        ,
        x_degree_subject                  IN            VARCHAR2        ,
        x_degree_status         IN              VARCHAR2        ,
        x_degree_class              IN          VARCHAR2        ,
        x_gcse_sci                      IN              VARCHAR2        ,
        x_welshspeaker              IN          VARCHAR2  ,
        x_ni_number                     IN              VARCHAR2,
        x_earliest_start            IN          VARCHAR2,
        x_near_inst                     IN              VARCHAR2,
        x_pref_reg                      IN              NUMBER  ,
        x_qual_eng                      IN              VARCHAR2,
        x_qual_math                     IN              VARCHAR2,
        x_qual_sci                      IN              VARCHAR2,
        x_main_qual                     IN              VARCHAR2,
        x_qual_5                          IN            VARCHAR2,
        x_future_serv                 IN                VARCHAR2,
        x_future_set                  IN                VARCHAR2,
        x_present_serv                  IN              VARCHAR2,
        x_present_set                 IN                VARCHAR2,
        x_curr_employment               IN              VARCHAR2,
        x_edu_qualification             IN              VARCHAR2,
	-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	x_ad_batch_id			IN		NUMBER,
	x_ad_interface_id		IN		NUMBER,
	x_nationality			IN		NUMBER,
	x_dual_nationality		IN		NUMBER,
	x_special_needs			IN		VARCHAR2,
	x_country_birth			IN		NUMBER,
	x_personal_id                   IN              VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali added columns for ucfd203 - multiple cycles bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        app_no,
        check_digit,
        enquiry_no,
        oss_person_id,
        application_source,
        name_change_date,
        student_support,
        address_area,
        application_date,
        application_sent_date,
        application_sent_run,
        lea_code,
        fee_payer_code,
        fee_text,
        domicile_apr,
        code_changed_date,
        school,
        withdrawn,
        withdrawn_date,
        rel_to_clear_reason,
        route_b,
        exam_change_date,
        a_levels,
        as_levels,
        highers,
        csys,
        winter,
        previous,
        gnvq,
        btec,
        ilc,
        ailc,
        ib,
        manual,
        reg_num,
        oeq,
        eas,
        roa,
        status,
        firm_now,
        firm_reply,
        insurance_reply,
        conf_hist_firm_reply,
        conf_hist_ins_reply,
        residential_category,
        personal_statement,
        match_prev,
        match_prev_date,
        match_winter,
        match_summer,
        gnvq_date,
        ib_date,
        ilc_date,
        ailc_date,
        gcseqa_date,
        uk_entry_date,
        prev_surname,
        criminal_convictions,
        sent_to_hesa,
        sent_to_oss,
        batch_identifier,
        gce,
        vce,
        sqa,
        previousas,
        keyskills,
        vocational,
        scn,
        prevoeq   ,
        choices_transparent_ind,
        extra_status,
        extra_passport_no,
        request_app_dets_ind,
        request_copy_app_frm_ind,
        cef_no,
        system_code             ,
        gcse_eng                      ,
        gcse_math                     ,
        degree_subject          ,
        degree_status       ,
        degree_class              ,
        gcse_sci                      ,
        welshspeaker              ,
        ni_number                     ,
        earliest_start    ,
        near_inst               ,
        pref_reg                ,
        qual_eng                ,
        qual_math                     ,
        qual_sci                      ,
        main_qual               ,
        qual_5                  ,
        future_serv                 ,
        future_set                  ,
        present_serv            ,
        present_set                 ,
        curr_employment   ,
        edu_qualification,
	-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	ad_batch_id		,
	ad_interface_id		,
	nationality		,
	dual_nationality	,
	special_needs		,
	country_birth	        ,
	personal_id
      FROM  igs_uc_applicants
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        ((tlinfo.app_no = x_app_no) OR ((tlinfo.app_no IS NULL) AND (X_app_no IS NULL)))
        AND ((tlinfo.check_digit = x_check_digit) OR ((tlinfo.check_digit IS NULL) AND (X_check_digit IS NULL)))
        AND ((tlinfo.enquiry_no = x_enquiry_no) OR ((tlinfo.enquiry_no IS NULL) AND (X_enquiry_no IS NULL)))
        AND ((tlinfo.oss_person_id = x_oss_person_id) OR ((tlinfo.oss_person_id IS NULL) AND (X_oss_person_id IS NULL)))
        AND (tlinfo.application_source = x_application_source)
        AND ((tlinfo.name_change_date = x_name_change_date) OR ((tlinfo.name_change_date IS NULL) AND (X_name_change_date IS NULL)))
        AND ((tlinfo.student_support = x_student_support) OR ((tlinfo.student_support IS NULL) AND (X_student_support IS NULL)))
        AND ((tlinfo.address_area = x_address_area) OR ((tlinfo.address_area IS NULL) AND (X_address_area IS NULL)))
        AND ((tlinfo.application_date = x_application_date) OR ((tlinfo.application_date IS NULL) AND (X_application_date IS NULL)))
        AND ((tlinfo.application_sent_date = x_application_sent_date) OR ((tlinfo.application_sent_date IS NULL) AND (X_application_sent_date IS NULL)))
        AND ((tlinfo.application_sent_run = x_application_sent_run) OR ((tlinfo.application_sent_run IS NULL) AND (X_application_sent_run IS NULL)))
        AND ((tlinfo.lea_code = x_lea_code) OR ((tlinfo.lea_code IS NULL) AND (X_lea_code IS NULL)))
        AND ((tlinfo.fee_payer_code = x_fee_payer_code) OR ((tlinfo.fee_payer_code IS NULL) AND (X_fee_payer_code IS NULL)))
        AND ((tlinfo.fee_text = x_fee_text) OR ((tlinfo.fee_text IS NULL) AND (X_fee_text IS NULL)))
        AND ((tlinfo.domicile_apr = x_domicile_apr) OR ((tlinfo.domicile_apr IS NULL) AND (X_domicile_apr IS NULL)))
        AND ((tlinfo.code_changed_date = x_code_changed_date) OR ((tlinfo.code_changed_date IS NULL) AND (X_code_changed_date IS NULL)))
        AND ((tlinfo.school = x_school) OR ((tlinfo.school IS NULL) AND (X_school IS NULL)))
        AND ((tlinfo.withdrawn = x_withdrawn) OR ((tlinfo.withdrawn IS NULL) AND (X_withdrawn IS NULL)))
        AND ((tlinfo.withdrawn_date = x_withdrawn_date) OR ((tlinfo.withdrawn_date IS NULL) AND (X_withdrawn_date IS NULL)))
        AND ((tlinfo.rel_to_clear_reason = x_rel_to_clear_reason) OR ((tlinfo.rel_to_clear_reason IS NULL) AND (X_rel_to_clear_reason IS NULL)))
        AND (tlinfo.route_b = x_route_b)
        AND ((tlinfo.exam_change_date = x_exam_change_date) OR ((tlinfo.exam_change_date IS NULL) AND (X_exam_change_date IS NULL)))
        AND ((tlinfo.a_levels = x_a_levels) OR ((tlinfo.a_levels IS NULL) AND (X_a_levels IS NULL)))
        AND ((tlinfo.as_levels = x_as_levels) OR ((tlinfo.as_levels IS NULL) AND (X_as_levels IS NULL)))
        AND ((tlinfo.highers = x_highers) OR ((tlinfo.highers IS NULL) AND (X_highers IS NULL)))
        AND ((tlinfo.csys = x_csys) OR ((tlinfo.csys IS NULL) AND (X_csys IS NULL)))
        AND ((tlinfo.winter = x_winter) OR ((tlinfo.winter IS NULL) AND (X_winter IS NULL)))
        AND ((tlinfo.previous = x_previous) OR ((tlinfo.previous IS NULL) AND (X_previous IS NULL)))
        AND ((tlinfo.gnvq = x_gnvq) OR ((tlinfo.gnvq IS NULL) AND (X_gnvq IS NULL)))
        AND ((tlinfo.btec = x_btec) OR ((tlinfo.btec IS NULL) AND (X_btec IS NULL)))
        AND ((tlinfo.ilc = x_ilc) OR ((tlinfo.ilc IS NULL) AND (X_ilc IS NULL)))
        AND ((tlinfo.ailc = x_ailc) OR ((tlinfo.ailc IS NULL) AND (X_ailc IS NULL)))
        AND ((tlinfo.ib = x_ib) OR ((tlinfo.ib IS NULL) AND (X_ib IS NULL)))
        AND ((tlinfo.manual = x_manual) OR ((tlinfo.manual IS NULL) AND (X_manual IS NULL)))
        AND ((tlinfo.reg_num = x_reg_num) OR ((tlinfo.reg_num IS NULL) AND (X_reg_num IS NULL)))
        AND ((tlinfo.oeq = x_oeq) OR ((tlinfo.oeq IS NULL) AND (X_oeq IS NULL)))
        AND ((tlinfo.eas = x_eas) OR ((tlinfo.eas IS NULL) AND (X_eas IS NULL)))
        AND ((tlinfo.roa = x_roa) OR ((tlinfo.roa IS NULL) AND (X_roa IS NULL)))
        AND ((tlinfo.status = x_status) OR ((tlinfo.status IS NULL) AND (X_status IS NULL)))
        AND ((tlinfo.firm_now = x_firm_now) OR ((tlinfo.firm_now IS NULL) AND (X_firm_now IS NULL)))
        AND ((tlinfo.firm_reply = x_firm_reply) OR ((tlinfo.firm_reply IS NULL) AND (X_firm_reply IS NULL)))
        AND ((tlinfo.insurance_reply = x_insurance_reply) OR ((tlinfo.insurance_reply IS NULL) AND (X_insurance_reply IS NULL)))
        AND ((tlinfo.conf_hist_firm_reply = x_conf_hist_firm_reply) OR ((tlinfo.conf_hist_firm_reply IS NULL) AND (X_conf_hist_firm_reply IS NULL)))
        AND ((tlinfo.conf_hist_ins_reply = x_conf_hist_ins_reply) OR ((tlinfo.conf_hist_ins_reply IS NULL) AND (X_conf_hist_ins_reply IS NULL)))
        AND ((tlinfo.residential_category = x_residential_category) OR ((tlinfo.residential_category IS NULL) AND (X_residential_category IS NULL)))
        AND ((tlinfo.personal_statement = x_personal_statement) OR ((tlinfo.personal_statement IS NULL) AND (X_personal_statement IS NULL)))
        AND ((tlinfo.match_prev = x_match_prev) OR ((tlinfo.match_prev IS NULL) AND (X_match_prev IS NULL)))
        AND ((tlinfo.match_prev_date = x_match_prev_date) OR ((tlinfo.match_prev_date IS NULL) AND (X_match_prev_date IS NULL)))
        AND ((tlinfo.match_winter = x_match_winter) OR ((tlinfo.match_winter IS NULL) AND (X_match_winter IS NULL)))
        AND ((tlinfo.match_summer = x_match_summer) OR ((tlinfo.match_summer IS NULL) AND (X_match_summer IS NULL)))
        AND ((tlinfo.gnvq_date = x_gnvq_date) OR ((tlinfo.gnvq_date IS NULL) AND (X_gnvq_date IS NULL)))
        AND ((tlinfo.ib_date = x_ib_date) OR ((tlinfo.ib_date IS NULL) AND (X_ib_date IS NULL)))
        AND ((tlinfo.ilc_date = x_ilc_date) OR ((tlinfo.ilc_date IS NULL) AND (X_ilc_date IS NULL)))
        AND ((tlinfo.ailc_date = x_ailc_date) OR ((tlinfo.ailc_date IS NULL) AND (X_ailc_date IS NULL)))
        AND ((tlinfo.gcseqa_date = x_gcseqa_date) OR ((tlinfo.gcseqa_date IS NULL) AND (X_gcseqa_date IS NULL)))
        AND ((tlinfo.uk_entry_date = x_uk_entry_date) OR ((tlinfo.uk_entry_date IS NULL) AND (X_uk_entry_date IS NULL)))
        AND ((tlinfo.prev_surname = x_prev_surname) OR ((tlinfo.prev_surname IS NULL) AND (X_prev_surname IS NULL)))
        AND ((tlinfo.criminal_convictions = x_criminal_convictions) OR ((tlinfo.criminal_convictions IS NULL) AND (x_criminal_convictions IS NULL)))
        AND (tlinfo.sent_to_hesa = x_sent_to_hesa)
        AND ((tlinfo.sent_to_oss = x_sent_to_oss)  OR ((tlinfo.sent_to_oss IS NULL) AND (X_sent_to_oss IS NULL)))
        AND ((tlinfo.batch_identifier = x_batch_identifier) OR ((tlinfo.batch_identifier IS NULL) AND (X_batch_identifier IS NULL)))
        AND ((tlinfo.gce        =  x_gce       ) OR ((tlinfo.gce         IS NULL) AND ( x_gce        IS NULL)))
        AND ((tlinfo.vce        =  x_vce       ) OR ((tlinfo.vce         IS NULL) AND ( x_vce        IS NULL)))
        AND ((tlinfo.sqa        =  x_sqa       ) OR ((tlinfo.sqa         IS NULL) AND ( x_sqa        IS NULL)))
        AND ((tlinfo.previousas =  x_previousas) OR ((tlinfo.previousas  IS NULL) AND ( x_previousas IS NULL)))
        AND ((tlinfo.keyskills  =  x_keyskills ) OR ((tlinfo.keyskills   IS NULL) AND ( x_keyskills  IS NULL)))
        AND ((tlinfo.vocational =  x_vocational) OR ((tlinfo.vocational  IS NULL) AND ( x_vocational IS NULL)))
        AND ((tlinfo.scn        =  x_scn       ) OR ((tlinfo.scn         IS NULL) AND ( x_scn        IS NULL)))
        AND ((tlinfo.prevoeq    =  x_prevoeq   ) OR ((tlinfo.prevoeq     IS NULL) AND ( x_prevoeq    IS NULL)))
        AND ((tlinfo.choices_transparent_ind    =  x_choices_transparent_ind   ) OR ((tlinfo.choices_transparent_ind     IS NULL) AND ( x_choices_transparent_ind  IS NULL)))
        AND ((tlinfo.extra_status    =  x_extra_status   ) OR ((tlinfo.extra_status     IS NULL) AND ( x_extra_status    IS NULL)))
        AND ((tlinfo.extra_passport_no    =  x_extra_passport_no   ) OR ((tlinfo.extra_passport_no     IS NULL) AND ( x_extra_passport_no    IS NULL)))
        AND ((tlinfo.request_app_dets_ind    =  x_request_app_dets_ind   ) OR ((tlinfo.request_app_dets_ind     IS NULL) AND ( x_request_app_dets_ind    IS NULL)))
        AND ((tlinfo.request_copy_app_frm_ind    =  x_request_copy_app_frm_ind   ) OR ((tlinfo.request_copy_app_frm_ind     IS NULL) AND ( x_request_copy_app_frm_ind    IS NULL)))
        AND ((tlinfo.cef_no =  x_cef_no ) OR ((tlinfo.cef_no IS NULL) AND ( x_cef_no IS NULL)))
 AND          (tlinfo.system_code        =               x_system_code  )
 AND            ((tlinfo.gcse_eng            =           x_gcse_eng     ) OR          ((                 tlinfo.gcse_eng        IS NULL) AND (    x_gcse_eng    IS NULL)))
 AND            ((tlinfo.gcse_math         =             x_gcse_math    ) OR        ((           tlinfo.gcse_math       IS NULL) AND (    x_gcse_math   IS NULL)))
AND             ((tlinfo.degree_subject =                x_degree_subject       ) OR    ((               tlinfo.degree_subject  IS NULL) AND ( x_degree_subject IS NULL)))
AND             ((tlinfo.degree_status  =                x_degree_status        ) OR    ((               tlinfo.degree_status   IS NULL) AND ( x_degree_status  IS NULL)))
AND             ((tlinfo.degree_class     =              x_degree_class ) OR      ((             tlinfo.degree_class    IS NULL) AND ( x_degree_class   IS NULL)))
AND             ((tlinfo.gcse_sci              =               x_gcse_sci       ) OR          ((                 tlinfo.gcse_sci        IS NULL) AND (  x_gcse_sci      IS NULL)))
AND             ((tlinfo.welshspeaker      =           x_welshspeaker   ) OR      ((             tlinfo.welshspeaker    IS NULL) AND ( x_welshspeaker   IS NULL)))
AND             ((tlinfo.ni_number           =         x_ni_number      ) OR        ((           tlinfo.ni_number       IS NULL) AND        (  x_ni_number      IS NULL)))
AND             ((tlinfo.earliest_start  =             x_earliest_start ) OR    ((               tlinfo.earliest_start  IS NULL) AND  ( x_earliest_start        IS NULL)))
AND             ((tlinfo.near_inst       =             x_near_inst              ) OR  ((                 tlinfo.near_inst               IS NULL) AND (  x_near_inst IS NULL)))
AND             ((tlinfo.pref_reg        =             x_pref_reg       ) OR          ((                 tlinfo.pref_reg        IS NULL) AND          ( x_pref_reg      IS NULL)))
AND             ((tlinfo.qual_eng              =               x_qual_eng       ) OR          ((                 tlinfo.qual_eng        IS NULL) AND          (  x_qual_eng     IS NULL)))
AND             ((tlinfo.qual_math           =         x_qual_math      ) OR        ((           tlinfo.qual_math       IS NULL) AND          (  x_qual_math    IS NULL)))
AND             ((tlinfo.qual_sci              =               x_qual_sci       ) OR          ((                 tlinfo.qual_sci        IS NULL) AND ( x_qual_sci       IS NULL)))
AND             ((tlinfo.main_qual       =             x_main_qual              ) OR ((          tlinfo.main_qual               IS NULL) AND (  x_main_qual     IS NULL)))
AND             ((tlinfo.qual_5          =             x_qual_5 ) OR             ((              tlinfo.qual_5  IS NULL) AND (    x_qual_5      IS NULL)))
AND             ((tlinfo.future_serv       =           x_future_serv    ) OR       ((            tlinfo.future_serv     IS NULL) AND (    x_future_serv IS NULL)))
AND             ((tlinfo.future_set          =         x_future_set     ) OR         ((          tlinfo.future_set      IS NULL) AND (    x_future_set  IS NULL)))
AND             ((tlinfo.present_serv    =             x_present_serv           ) OR   ((                tlinfo.present_serv            IS NULL) AND (  x_present_serv          IS NULL)))
AND             ((tlinfo.present_set        =          x_present_set    ) OR       ((            tlinfo.present_set     IS NULL) AND (  x_present_set   IS NULL)))
AND             ((tlinfo.curr_employment        =              x_curr_employment        ) OR   ((                tlinfo.curr_employment IS NULL) AND (  x_curr_employment       IS NULL)))
AND             ((tlinfo.edu_qualification      =            x_edu_qualification        ) OR ((          tlinfo.edu_qualification       IS NULL) AND (  x_edu_qualification     IS NULL)))
-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
AND             ((tlinfo.ad_batch_id	    =     x_ad_batch_id       ) OR   ((  tlinfo.ad_batch_id        IS NULL) AND (  x_ad_batch_id       IS NULL)))
AND             ((tlinfo.ad_interface_id    =     x_ad_interface_id   ) OR   ((  tlinfo.ad_interface_id    IS NULL) AND (  x_ad_interface_id   IS NULL)))
AND             ((tlinfo.nationality        =     x_nationality       ) OR   ((  tlinfo.nationality	   IS NULL) AND (  x_nationality       IS NULL)))
AND             ((tlinfo.dual_nationality   =     x_dual_nationality  ) OR   ((  tlinfo.dual_nationality   IS NULL) AND (  x_edu_qualification IS NULL)))
AND             ((tlinfo.special_needs      =     x_special_needs     ) OR   ((  tlinfo.special_needs      IS NULL) AND (  x_special_needs     IS NULL)))
AND             ((tlinfo.country_birth      =     x_country_birth     ) OR   ((  tlinfo.country_birth      IS NULL) AND (  x_country_birth     IS NULL)))
AND             ((tlinfo.personal_id        =     x_personal_id       ) OR   ((  tlinfo.personal_id        IS NULL) AND (  x_personal_id         IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_check_digit                       IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_oss_person_id                     IN     NUMBER,
    x_application_source                IN     VARCHAR2,
    x_name_change_date                  IN     DATE,
    x_student_support                   IN     VARCHAR2,
    x_address_area                      IN     VARCHAR2,
    x_application_date                  IN     DATE,
    x_application_sent_date             IN     DATE,
    x_application_sent_run              IN     NUMBER,
    x_lea_code                          IN     NUMBER,
    x_fee_payer_code                    IN     NUMBER,
    x_fee_text                          IN     VARCHAR2,
    x_domicile_apr                      IN     NUMBER,
    x_code_changed_date                 IN     DATE,
    x_school                            IN     NUMBER,
    x_withdrawn                         IN     VARCHAR2,
    x_withdrawn_date                    IN     DATE,
    x_rel_to_clear_reason               IN     VARCHAR2,
    x_route_b                           IN     VARCHAR2,
    x_exam_change_date                  IN     DATE,
    x_a_levels                          IN     NUMBER,
    x_as_levels                         IN     NUMBER,
    x_highers                           IN     NUMBER,
    x_csys                              IN     NUMBER,
    x_winter                            IN     NUMBER,
    x_previous                          IN     NUMBER,
    x_gnvq                              IN     VARCHAR2,
    x_btec                              IN     VARCHAR2,
    x_ilc                               IN     VARCHAR2,
    x_ailc                              IN     VARCHAR2,
    x_ib                                IN     VARCHAR2,
    x_manual                            IN     VARCHAR2,
    x_reg_num                           IN     VARCHAR2,
    x_oeq                               IN     VARCHAR2,
    x_eas                               IN     VARCHAR2,
    x_roa                               IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_firm_now                          IN     NUMBER,
    x_firm_reply                        IN     NUMBER,
    x_insurance_reply                   IN     NUMBER,
    x_conf_hist_firm_reply              IN     NUMBER,
    x_conf_hist_ins_reply               IN     NUMBER,
    x_residential_category              IN     VARCHAR2,
    x_personal_statement                IN     LONG,
    x_match_prev                        IN     VARCHAR2,
    x_match_prev_date                   IN     DATE,
    x_match_winter                      IN     VARCHAR2,
    x_match_summer                      IN     VARCHAR2,
    x_gnvq_date                         IN     DATE,
    x_ib_date                           IN     DATE,
    x_ilc_date                          IN     DATE,
    x_ailc_date                         IN     DATE,
    x_gcseqa_date                       IN     DATE,
    x_uk_entry_date                     IN     DATE,
    x_prev_surname                      IN     VARCHAR2,
    x_criminal_convictions              IN     VARCHAR2,
    x_sent_to_hesa                      IN     VARCHAR2,
    x_sent_to_oss                       IN     VARCHAR2,
    x_batch_identifier                  IN     NUMBER,
    x_mode                              IN     VARCHAR2 ,
    -- Added following 8 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_gce                               IN     NUMBER      ,
    x_vce                               IN     NUMBER      ,
    x_sqa                               IN     VARCHAR2    ,
    x_previousas                        IN     NUMBER      ,
    x_keyskills                         IN     VARCHAR2    ,
    x_vocational                        IN     VARCHAR2    ,
    x_scn                               IN     VARCHAR2    ,
    x_prevoeq                           IN     VARCHAR2   ,
    x_choices_transparent_ind           IN     VARCHAR2,
    x_extra_status                      IN     NUMBER,
    x_extra_passport_no                 IN     VARCHAR2,
    x_request_app_dets_ind              IN     VARCHAR2,
    x_request_copy_app_frm_ind          IN     VARCHAR2,
    x_cef_no                            IN     NUMBER,
       -- Added the following columns as part of UCFD102 Build: Bug#2643048
    x_system_code                 IN            VARCHAR2        ,
        x_gcse_eng                      IN              VARCHAR2        ,
        x_gcse_math                     IN              VARCHAR2        ,
        x_degree_subject                  IN            VARCHAR2        ,
        x_degree_status         IN              VARCHAR2        ,
        x_degree_class              IN          VARCHAR2        ,
        x_gcse_sci                      IN              VARCHAR2        ,
        x_welshspeaker              IN          VARCHAR2  ,
        x_ni_number                     IN              VARCHAR2,
        x_earliest_start            IN          VARCHAR2,
        x_near_inst                     IN              VARCHAR2,
        x_pref_reg                      IN              NUMBER  ,
        x_qual_eng                      IN              VARCHAR2,
        x_qual_math                     IN              VARCHAR2,
        x_qual_sci                      IN              VARCHAR2,
        x_main_qual                     IN              VARCHAR2,
        x_qual_5                          IN            VARCHAR2,
        x_future_serv                 IN                VARCHAR2,
        x_future_set                  IN                VARCHAR2,
        x_present_serv                  IN              VARCHAR2,
        x_present_set                 IN                VARCHAR2,
        x_curr_employment               IN              VARCHAR2,
        x_edu_qualification             IN              VARCHAR2,
	-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	x_ad_batch_id			IN		NUMBER,
	x_ad_interface_id		IN		NUMBER,
	x_nationality			IN		NUMBER,
	x_dual_nationality		IN		NUMBER,
	x_special_needs			IN		VARCHAR2,
	x_country_birth			IN		NUMBER,
	x_personal_id                   IN              VARCHAR2
) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali added columns for ucfd203 - multiple cycles bug#2669208
  ||  (reverse chronological order - newest change first)
  ||  dsridhar        27-AUG-2003      Bug No: 3087784. Resetting the value of l_rowid to NULL.
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (X_MODE IN ('R', 'S')) THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_app_id                            => x_app_id,
      x_app_no                            => x_app_no,
      x_check_digit                       => x_check_digit,
      x_enquiry_no                        => x_enquiry_no,
      x_oss_person_id                     => x_oss_person_id,
      x_application_source                => x_application_source,
      x_name_change_date                  => x_name_change_date,
      x_student_support                   => x_student_support,
      x_address_area                      => x_address_area,
      x_application_date                  => x_application_date,
      x_application_sent_date             => x_application_sent_date,
      x_application_sent_run              => x_application_sent_run,
      x_lea_code                          => x_lea_code,
      x_fee_payer_code                    => x_fee_payer_code,
      x_fee_text                          => x_fee_text,
      x_domicile_apr                      => x_domicile_apr,
      x_code_changed_date                 => x_code_changed_date,
      x_school                            => x_school,
      x_withdrawn                         => x_withdrawn,
      x_withdrawn_date                    => x_withdrawn_date,
      x_rel_to_clear_reason               => x_rel_to_clear_reason,
      x_route_b                           => x_route_b,
      x_exam_change_date                  => x_exam_change_date,
      x_a_levels                          => x_a_levels,
      x_as_levels                         => x_as_levels,
      x_highers                           => x_highers,
      x_csys                              => x_csys,
      x_winter                            => x_winter,
      x_previous                          => x_previous,
      x_gnvq                              => x_gnvq,
      x_btec                              => x_btec,
      x_ilc                               => x_ilc,
      x_ailc                              => x_ailc,
      x_ib                                => x_ib,
      x_manual                            => x_manual,
      x_reg_num                           => x_reg_num,
      x_oeq                               => x_oeq,
      x_eas                               => x_eas,
      x_roa                               => x_roa,
      x_status                            => x_status,
      x_firm_now                          => x_firm_now,
      x_firm_reply                        => x_firm_reply,
      x_insurance_reply                   => x_insurance_reply,
      x_conf_hist_firm_reply              => x_conf_hist_firm_reply,
      x_conf_hist_ins_reply               => x_conf_hist_ins_reply,
      x_residential_category              => x_residential_category,
      x_personal_statement                => x_personal_statement,
      x_match_prev                        => x_match_prev,
      x_match_prev_date                   => x_match_prev_date,
      x_match_winter                      => x_match_winter,
      x_match_summer                      => x_match_summer,
      x_gnvq_date                         => x_gnvq_date,
      x_ib_date                           => x_ib_date,
      x_ilc_date                          => x_ilc_date,
      x_ailc_date                         => x_ailc_date,
      x_gcseqa_date                       => x_gcseqa_date,
      x_uk_entry_date                     => x_uk_entry_date,
      x_prev_surname                      => x_prev_surname,
      x_criminal_convictions              => x_criminal_convictions,
      x_sent_to_hesa                      => x_sent_to_hesa,
      x_sent_to_oss                       => x_sent_to_oss,
      x_batch_identifier                  => x_batch_identifier,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_gce                               => x_gce,
      x_vce                               => x_vce,
      x_sqa                               => x_sqa,
      x_previousas                        => x_previousas,
      x_keyskills                         => x_keyskills,
      x_vocational                        => x_vocational,
      x_scn                               => x_scn,
      x_prevoeq                           => x_prevoeq ,
      x_choices_transparent_ind           => x_choices_transparent_ind ,
      x_extra_status                      => x_extra_status             ,
      x_extra_passport_no                 => x_extra_passport_no        ,
      x_request_app_dets_ind              => x_request_app_dets_ind    ,
      x_request_copy_app_frm_ind          => x_request_copy_app_frm_ind,
      x_cef_no                            => x_cef_no,
        x_system_code       =>  x_system_code   ,
      x_gcse_eng            =>  x_gcse_eng      ,
      x_gcse_math           =>  x_gcse_math     ,
      x_degree_subject      =>  x_degree_subject        ,
      x_degree_status       =>  x_degree_status ,
      x_degree_class        =>  x_degree_class  ,
      x_gcse_sci            =>  x_gcse_sci      ,
      x_welshspeaker        =>  x_welshspeaker  ,
      x_ni_number           =>  x_ni_number     ,
      x_earliest_start      =>  x_earliest_start        ,
      x_near_inst           =>  x_near_inst     ,
     x_pref_reg     =>  x_pref_reg      ,
x_qual_eng          =>  x_qual_eng      ,
x_qual_math         =>  x_qual_math     ,
x_qual_sci          =>  x_qual_sci      ,
x_main_qual         =>  x_main_qual     ,
x_qual_5            =>  x_qual_5        ,
x_future_serv       =>  x_future_serv   ,
x_future_set        =>  x_future_set    ,
x_present_serv      =>  x_present_serv  ,
x_present_set       =>  x_present_set   ,
x_curr_employment           =>  x_curr_employment       ,
x_edu_qualification         =>  x_edu_qualification	,
-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	x_ad_batch_id		=> x_ad_batch_id	,
	x_ad_interface_id	=> x_ad_interface_id	,
	x_nationality		=> x_nationality	,
	x_dual_nationality	=> x_dual_nationality	,
	x_special_needs		=> x_special_needs	,
	x_country_birth		=> x_country_birth      ,
	x_personal_id           => x_personal_id
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_uc_applicants
      SET
        app_no                            = new_references.app_no,
        check_digit                       = new_references.check_digit,
        enquiry_no                        = new_references.enquiry_no,
        oss_person_id                     = new_references.oss_person_id,
        application_source                = new_references.application_source,
        name_change_date                  = new_references.name_change_date,
        student_support                   = new_references.student_support,
        address_area                      = new_references.address_area,
        application_date                  = new_references.application_date,
        application_sent_date             = new_references.application_sent_date,
        application_sent_run              = new_references.application_sent_run,
        lea_code                          = new_references.lea_code,
        fee_payer_code                    = new_references.fee_payer_code,
        fee_text                          = new_references.fee_text,
        domicile_apr                      = new_references.domicile_apr,
        code_changed_date                 = new_references.code_changed_date,
        school                            = new_references.school,
        withdrawn                         = new_references.withdrawn,
        withdrawn_date                    = new_references.withdrawn_date,
        rel_to_clear_reason               = new_references.rel_to_clear_reason,
        route_b                           = new_references.route_b,
        exam_change_date                  = new_references.exam_change_date,
        a_levels                          = new_references.a_levels,
        as_levels                         = new_references.as_levels,
        highers                           = new_references.highers,
        csys                              = new_references.csys,
        winter                            = new_references.winter,
        previous                          = new_references.previous,
        gnvq                              = new_references.gnvq,
        btec                              = new_references.btec,
        ilc                               = new_references.ilc,
        ailc                              = new_references.ailc,
        ib                                = new_references.ib,
        manual                            = new_references.manual,
        reg_num                           = new_references.reg_num,
        oeq                               = new_references.oeq,
        eas                               = new_references.eas,
        roa                               = new_references.roa,
        status                            = new_references.status,
        firm_now                          = new_references.firm_now,
        firm_reply                        = new_references.firm_reply,
        insurance_reply                   = new_references.insurance_reply,
        conf_hist_firm_reply              = new_references.conf_hist_firm_reply,
        conf_hist_ins_reply               = new_references.conf_hist_ins_reply,
        residential_category              = new_references.residential_category,
        personal_statement                = new_references.personal_statement,
        match_prev                        = new_references.match_prev,
        match_prev_date                   = new_references.match_prev_date,
        match_winter                      = new_references.match_winter,
        match_summer                      = new_references.match_summer,
        gnvq_date                         = new_references.gnvq_date,
        ib_date                           = new_references.ib_date,
        ilc_date                          = new_references.ilc_date,
        ailc_date                         = new_references.ailc_date,
        gcseqa_date                       = new_references.gcseqa_date,
        uk_entry_date                     = new_references.uk_entry_date,
        prev_surname                      = new_references.prev_surname,
        criminal_convictions              = new_references.criminal_convictions,
        sent_to_hesa                      = new_references.sent_to_hesa,
        sent_to_oss                       = new_references.sent_to_oss,
        batch_identifier                  = new_references.batch_identifier,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        gce                               = new_references.gce,
        vce                               = new_references.vce,
        sqa                               = new_references.sqa,
        previousas                        = new_references.previousas,
        keyskills                         = new_references.keyskills,
        vocational                        = new_references.vocational,
        scn                               = new_references.scn,
        prevoeq                           = new_references.prevoeq   ,
        choices_transparent_ind           = new_references.choices_transparent_ind,
        extra_status                      = new_references.extra_status         ,
        extra_passport_no                 = new_references.extra_passport_no    ,
        request_app_dets_ind              = new_references.request_app_dets_ind  ,
        request_copy_app_frm_ind          = new_references.request_copy_app_frm_ind,
        cef_no                            = new_references.cef_no,
        system_code     =       new_references.system_code      ,
        gcse_eng        =       new_references.gcse_eng ,
        gcse_math       =       new_references.gcse_math        ,
        degree_subject  =       new_references.degree_subject   ,
        degree_status   =       new_references.degree_status    ,
        degree_class    =       new_references.degree_class     ,
        gcse_sci        =       new_references.gcse_sci ,
        welshspeaker    =       new_references.welshspeaker     ,
        ni_number       =       new_references.ni_number        ,
        earliest_start  =       new_references.earliest_start   ,
        near_inst               =       new_references.near_inst        ,
        pref_reg        =       new_references.pref_reg ,
        qual_eng        =       new_references.qual_eng ,
        qual_math       =       new_references.qual_math        ,
        qual_sci        =       new_references.qual_sci ,
        main_qual               =       new_references.main_qual                ,
        qual_5  =       new_references.qual_5   ,
        future_serv     =       new_references.future_serv      ,
        future_set      =       new_references.future_set       ,
        present_serv            =       new_references.present_serv     ,
        present_set     =       new_references.present_set      ,
        curr_employment =       new_references.curr_employment  ,
        edu_qualification       =       new_references.edu_qualification	,
	-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	ad_batch_id		= new_references.ad_batch_id	,
	ad_interface_id		= new_references.ad_interface_id	,
	nationality		= new_references.nationality	,
	dual_nationality	= new_references.dual_nationality	,
	special_needs		= new_references.special_needs	,
	country_birth		= new_references.country_birth  ,
	personal_id             = new_references.personal_id
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    -- Bug No: 3087784. Resetting the value of l_rowid to NULL.
    l_rowid := NULL;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE = (-28115)) THEN
        fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
        fnd_message.set_token ('ERR_CD', SQLCODE);
        igs_ge_msg_stack.add;
        igs_sc_gen_001.unset_ctx('R');
        app_exception.raise_exception;
      ELSE
        igs_sc_gen_001.unset_ctx('R');
        RAISE;
      END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_id                            IN OUT NOCOPY NUMBER,
    x_app_no                            IN     NUMBER,
    x_check_digit                       IN     NUMBER,
    x_enquiry_no                        IN OUT NOCOPY NUMBER,
    x_oss_person_id                     IN     NUMBER,
    x_application_source                IN     VARCHAR2,
    x_name_change_date                  IN     DATE,
    x_student_support                   IN     VARCHAR2,
    x_address_area                      IN     VARCHAR2,
    x_application_date                  IN     DATE,
    x_application_sent_date             IN     DATE,
    x_application_sent_run              IN     NUMBER,
    x_lea_code                          IN     NUMBER,
    x_fee_payer_code                    IN     NUMBER,
    x_fee_text                          IN     VARCHAR2,
    x_domicile_apr                      IN     NUMBER,
    x_code_changed_date                 IN     DATE,
    x_school                            IN     NUMBER,
    x_withdrawn                         IN     VARCHAR2,
    x_withdrawn_date                    IN     DATE,
    x_rel_to_clear_reason               IN     VARCHAR2,
    x_route_b                           IN     VARCHAR2,
    x_exam_change_date                  IN     DATE,
    x_a_levels                          IN     NUMBER,
    x_as_levels                         IN     NUMBER,
    x_highers                           IN     NUMBER,
    x_csys                              IN     NUMBER,
    x_winter                            IN     NUMBER,
    x_previous                          IN     NUMBER,
    x_gnvq                              IN     VARCHAR2,
    x_btec                              IN     VARCHAR2,
    x_ilc                               IN     VARCHAR2,
    x_ailc                              IN     VARCHAR2,
    x_ib                                IN     VARCHAR2,
    x_manual                            IN     VARCHAR2,
    x_reg_num                           IN     VARCHAR2,
    x_oeq                               IN     VARCHAR2,
    x_eas                               IN     VARCHAR2,
    x_roa                               IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_firm_now                          IN     NUMBER,
    x_firm_reply                        IN     NUMBER,
    x_insurance_reply                   IN     NUMBER,
    x_conf_hist_firm_reply              IN     NUMBER,
    x_conf_hist_ins_reply               IN     NUMBER,
    x_residential_category              IN     VARCHAR2,
    x_personal_statement                IN     LONG,
    x_match_prev                        IN     VARCHAR2,
    x_match_prev_date                   IN     DATE,
    x_match_winter                      IN     VARCHAR2,
    x_match_summer                      IN     VARCHAR2,
    x_gnvq_date                         IN     DATE,
    x_ib_date                           IN     DATE,
    x_ilc_date                          IN     DATE,
    x_ailc_date                         IN     DATE,
    x_gcseqa_date                       IN     DATE,
    x_uk_entry_date                     IN     DATE,
    x_prev_surname                      IN     VARCHAR2,
    x_criminal_convictions              IN     VARCHAR2,
    x_sent_to_hesa                      IN     VARCHAR2,
    x_sent_to_oss                       IN     VARCHAR2,
    x_batch_identifier                  IN     NUMBER,
    x_mode                              IN     VARCHAR2 ,
    -- Added following 8 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_gce                               IN     NUMBER      ,
    x_vce                               IN     NUMBER      ,
    x_sqa                               IN     VARCHAR2    ,
    x_previousas                        IN     NUMBER      ,
    x_keyskills                         IN     VARCHAR2    ,
    x_vocational                        IN     VARCHAR2    ,
    x_scn                               IN     VARCHAR2    ,
    x_prevoeq                           IN     VARCHAR2    ,

    x_choices_transparent_ind           IN     VARCHAR2,
    x_extra_status                      IN     NUMBER,
    x_extra_passport_no                 IN     VARCHAR2,
    x_request_app_dets_ind              IN     VARCHAR2,
    x_request_copy_app_frm_ind          IN     VARCHAR2,
    x_cef_no                            IN     NUMBER,
      -- Added the following columns as part of UCFD102 Build: Bug#2643048
    x_system_code                 IN            VARCHAR2        ,
        x_gcse_eng                      IN              VARCHAR2        ,
        x_gcse_math                     IN              VARCHAR2        ,
        x_degree_subject                  IN            VARCHAR2        ,
        x_degree_status         IN              VARCHAR2        ,
        x_degree_class              IN          VARCHAR2        ,
        x_gcse_sci                      IN              VARCHAR2        ,
        x_welshspeaker              IN          VARCHAR2  ,
        x_ni_number                     IN              VARCHAR2,
        x_earliest_start            IN          VARCHAR2,
        x_near_inst                     IN              VARCHAR2,
        x_pref_reg                      IN              NUMBER  ,
        x_qual_eng                      IN              VARCHAR2,
        x_qual_math                     IN              VARCHAR2,
        x_qual_sci                      IN              VARCHAR2,
        x_main_qual                     IN              VARCHAR2,
        x_qual_5                          IN            VARCHAR2,
        x_future_serv                 IN                VARCHAR2,
        x_future_set                  IN                VARCHAR2,
        x_present_serv                  IN              VARCHAR2,
        x_present_set                 IN                VARCHAR2,
        x_curr_employment               IN              VARCHAR2,
        x_edu_qualification             IN              VARCHAR2,
	-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	x_ad_batch_id			IN		NUMBER,
	x_ad_interface_id		IN		NUMBER,
	x_nationality			IN		NUMBER,
	x_dual_nationality		IN		NUMBER,
	x_special_needs			IN		VARCHAR2,
	x_country_birth			IN		NUMBER,
	x_personal_id                   IN              VARCHAR2
) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali added columns for ucfd203 - multiple cycles bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_applicants
      WHERE    app_id                            = x_app_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_app_id,
        x_app_no,
        x_check_digit,
        x_enquiry_no,
        x_oss_person_id,
        x_application_source,
        x_name_change_date,
        x_student_support,
        x_address_area,
        x_application_date,
        x_application_sent_date,
        x_application_sent_run,
        x_lea_code,
        x_fee_payer_code,
        x_fee_text,
        x_domicile_apr,
        x_code_changed_date,
        x_school,
        x_withdrawn,
        x_withdrawn_date,
        x_rel_to_clear_reason,
        x_route_b,
        x_exam_change_date,
        x_a_levels,
        x_as_levels,
        x_highers,
        x_csys,
        x_winter,
        x_previous,
        x_gnvq,
        x_btec,
        x_ilc,
        x_ailc,
        x_ib,
        x_manual,
        x_reg_num,
        x_oeq,
        x_eas,
        x_roa,
        x_status,
        x_firm_now,
        x_firm_reply,
        x_insurance_reply,
        x_conf_hist_firm_reply,
        x_conf_hist_ins_reply,
        x_residential_category,
        x_personal_statement,
        x_match_prev,
        x_match_prev_date,
        x_match_winter,
        x_match_summer,
        x_gnvq_date,
        x_ib_date,
        x_ilc_date,
        x_ailc_date,
        x_gcseqa_date,
        x_uk_entry_date,
        x_prev_surname,
        x_criminal_convictions,
        x_sent_to_hesa,
        x_sent_to_oss,
        x_batch_identifier,
        x_mode,
        x_gce,
        x_vce,
        x_sqa,
        x_previousas,
        x_keyskills,
        x_vocational,
        x_scn,
        x_prevoeq,
        x_choices_transparent_ind,
        x_extra_status,
        x_extra_passport_no,
        x_request_app_dets_ind,
        x_request_copy_app_frm_ind,
        x_cef_no,
        x_system_code           ,
        x_gcse_eng                    ,
        x_gcse_math                   ,
        x_degree_subject                ,
        x_degree_status     ,
        x_degree_class            ,
        x_gcse_sci                    ,
        x_welshspeaker            ,
        x_ni_number                   ,
        x_earliest_start          ,
        x_near_inst             ,
        x_pref_reg              ,
        x_qual_eng              ,
        x_qual_math                   ,
        x_qual_sci                    ,
        x_main_qual             ,
        x_qual_5                        ,
        x_future_serv               ,
        x_future_set                ,
        x_present_serv          ,
        x_present_set               ,
        x_curr_employment         ,
        x_edu_qualification	,
	-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	x_ad_batch_id		,
	x_ad_interface_id	,
	x_nationality		,
	x_dual_nationality	,
	x_special_needs		,
	x_country_birth		,
	x_personal_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_app_id,
      x_app_no,
      x_check_digit,
      x_enquiry_no,
      x_oss_person_id,
      x_application_source,
      x_name_change_date,
      x_student_support,
      x_address_area,
      x_application_date,
      x_application_sent_date,
      x_application_sent_run,
      x_lea_code,
      x_fee_payer_code,
      x_fee_text,
      x_domicile_apr,
      x_code_changed_date,
      x_school,
      x_withdrawn,
      x_withdrawn_date,
      x_rel_to_clear_reason,
      x_route_b,
      x_exam_change_date,
      x_a_levels,
      x_as_levels,
      x_highers,
      x_csys,
      x_winter,
      x_previous,
      x_gnvq,
      x_btec,
      x_ilc,
      x_ailc,
      x_ib,
      x_manual,
      x_reg_num,
      x_oeq,
      x_eas,
      x_roa,
      x_status,
      x_firm_now,
      x_firm_reply,
      x_insurance_reply,
      x_conf_hist_firm_reply,
      x_conf_hist_ins_reply,
      x_residential_category,
      x_personal_statement,
      x_match_prev,
      x_match_prev_date,
      x_match_winter,
      x_match_summer,
      x_gnvq_date,
      x_ib_date,
      x_ilc_date,
      x_ailc_date,
      x_gcseqa_date,
      x_uk_entry_date,
      x_prev_surname,
      x_criminal_convictions,
      x_sent_to_hesa,
      x_sent_to_oss,
      x_batch_identifier,
      x_mode,
      x_gce,
      x_vce,
      x_sqa,
      x_previousas,
      x_keyskills,
      x_vocational,
      x_scn,
      x_prevoeq ,
      x_choices_transparent_ind,
      x_extra_status,
      x_extra_passport_no,
      x_request_app_dets_ind,
      x_request_copy_app_frm_ind,
      x_cef_no,
        x_system_code           ,
        x_gcse_eng                    ,
        x_gcse_math                   ,
        x_degree_subject                ,
        x_degree_status     ,
        x_degree_class            ,
        x_gcse_sci                    ,
        x_welshspeaker            ,
        x_ni_number                   ,
        x_earliest_start          ,
        x_near_inst             ,
        x_pref_reg              ,
        x_qual_eng              ,
        x_qual_math                   ,
        x_qual_sci                    ,
        x_main_qual             ,
        x_qual_5                        ,
        x_future_serv               ,
        x_future_set                ,
        x_present_serv          ,
        x_present_set               ,
        x_curr_employment         ,
        x_edu_qualification	,
	-- smaddali added these columns for ucfd203 - multiple cycles bug#2669208
	x_ad_batch_id		,
	x_ad_interface_id	,
	x_nationality		,
	x_dual_nationality	,
	x_special_needs		,
	x_country_birth		,
	x_personal_id
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  dsridhar        27-AUG-2003      Bug No: 3087784. Resetting the value of l_rowid to NULL.
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_uc_applicants
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    -- Bug No: 3087784. Resetting the value of l_rowid to NULL.
    l_rowid := NULL;

  END delete_row;

END igs_uc_applicants_pkg;

/
