--------------------------------------------------------
--  DDL for Package Body IGF_GR_GEN_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_GEN_XML" AS
/* $Header: IGFGR12B.pls 120.13 2006/04/24 00:22:15 rajagupt noship $ */
  /*************************************************************
  Process Flow
  main()
  1.  log_input_parameters()
  2.  validate_input_parameters()
  3.  Process RFMS records based on input criteria.
      4.  process_rfms_record()
          5.  General validations
          6.  XML Validations
          7.  insert_into_cod_tables()  (IGF_GR_COD_DTLS and IGF_AW_DB_COD_DTLS)
  8.  submit_xml_event()
  9.  XML Gateway Standard to create xml
  10. store_xml()
      11. This will insert xml file into IGF_SL_COD_DOC_DTLS
      12. Launch print xml sub process IGFGRJ14
          13. Log input parameters
          14. igf_sl_dl_gen_xml.edit_clob()
              Edit the clob file and update it in IGF_SL_COD_DOC_DTLS table.
          15. igf_sl_dl_gen_xml.print_out_xml()
              Print XML file in out file.
  /*************************************************************/

  /*************************************************************
  Created By : ugummall
  Date Created On : 2004/10/04
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

gv_document_id_txt    VARCHAR2(30);
g_ver_num             VARCHAR2(30);
g_full_resp_code      VARCHAR2(30);
student_dtl_rec       igf_sl_gen.person_dtl_rec;

FUNCTION is_alpha_numeric(p_param_value IN  VARCHAR2)
 	 RETURN BOOLEAN AS
/*************************************************************
 Created By : bvisvana
 Date Created On : 2005/10/11
 Purpose : To check for Alpha numeric - Related to Bug # 4124839
 Know limitations, enhancements or remarks
 Change History
 Who             When            What
 (reverse chronological order - newest change first)
 ***************************************************************/
l_num   NUMBER;
BEGIN
  l_num := TO_NUMBER(TRIM(p_param_value));
  RETURN FALSE;
  EXCEPTION
    WHEN VALUE_ERROR THEN
      RETURN TRUE;
    WHEN OTHERS THEN
      RETURN TRUE;
END is_alpha_numeric;


PROCEDURE set_nls_fmt(PARAM in VARCHAR2)
AS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/
  l_temp VARCHAR2(10);
  l_sql_stmt VARCHAR2(100);
BEGIN
  l_temp := '.,';
  l_sql_stmt := 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''' || l_temp || '''';
  EXECute IMMEDIATE l_sql_stmt;
END set_nls_fmt;

FUNCTION  get_grp_name  ( p_per_grp_id IN NUMBER)
RETURN VARCHAR2
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/
AS

  CURSOR  cur_get_grp_name  ( p_per_grp_id NUMBER)  IS
    SELECT  group_cd
      FROM  IGS_PE_PERSID_GROUP_ALL
     WHERE  group_id = p_per_grp_id;
  get_grp_name_rec cur_get_grp_name%ROWTYPE;

BEGIN
  OPEN  cur_get_grp_name (p_per_grp_id);
  FETCH cur_get_grp_name INTO get_grp_name_rec;
  CLOSE cur_get_grp_name;

  RETURN get_grp_name_rec.group_cd;
EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GR_GEN_XML.GET_GRP_NAME');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END get_grp_name;

FUNCTION  check_fa_rec  ( p_base_id    NUMBER,
                          p_cal_type   VARCHAR2,
                          p_seq_number NUMBER)
RETURN BOOLEAN
AS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

  CURSOR  cur_chk_fa  ( cp_base_id    NUMBER,
                        cp_cal_type   VARCHAR2,
                        cp_seq_number NUMBER)  IS
    SELECT  base_id
      FROM  IGF_AP_FA_BASE_REC_ALL
     WHERE  base_id = cp_base_id
      AND   ci_cal_type = cp_cal_type
      AND   ci_sequence_number = cp_seq_number;
  chk_fa_rec cur_chk_fa%ROWTYPE;

BEGIN
  OPEN cur_chk_fa (p_base_id,p_cal_type,p_seq_number);
  FETCH cur_chk_fa INTO chk_fa_rec;
  CLOSE cur_chk_fa;
  IF chk_fa_rec.base_id IS NULL THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GR_GEN_XML.CHECK_FA_REC');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END check_fa_rec;

FUNCTION  per_in_fa ( p_person_id            igf_ap_fa_base_rec_all.person_id%TYPE,
                      p_ci_cal_type          VARCHAR2,
                      p_ci_sequence_number   NUMBER,
                      p_base_id          OUT NOCOPY NUMBER
                    )
RETURN VARCHAR2
AS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

  CURSOR  cur_get_pers_num  ( p_person_id  igf_ap_fa_base_rec_all.person_id%TYPE) IS
    SELECT  person_number
      FROM  IGS_PE_PERSON_BASE_V
     WHERE  person_id  = p_person_id;
  get_pers_num_rec   cur_get_pers_num%ROWTYPE;

  CURSOR  cur_get_base  ( p_cal_type        igs_ca_inst_all.cal_type%TYPE,
                          p_sequence_number igs_ca_inst_all.sequence_number%TYPE,
                          p_person_id       igf_ap_fa_base_rec_all.person_id%TYPE)  IS
    SELECT  base_id
      FROM  IGF_AP_FA_BASE_REC_ALL
     WHERE  person_id          = p_person_id
      AND   ci_cal_type        = p_cal_type
      AND   ci_sequence_number = p_sequence_number;

BEGIN
  OPEN  cur_get_pers_num(p_person_id);
  FETCH cur_get_pers_num  INTO get_pers_num_rec;

  IF  cur_get_pers_num%NOTFOUND THEN
    CLOSE cur_get_pers_num;
    RETURN NULL;
  ELSE
    CLOSE cur_get_pers_num;

    OPEN  cur_get_base(p_ci_cal_type,p_ci_sequence_number,p_person_id);
    FETCH cur_get_base INTO p_base_id;
    CLOSE cur_get_base;

    RETURN get_pers_num_rec.person_number;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GR_GEN_XML.PER_IN_FA');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END per_in_fa;

PROCEDURE log_input_parameters  (
                                  p_award_year          IN  VARCHAR2,
                                  p_source_entity_id    IN  VARCHAR2,
                                  p_report_entity_id    IN  VARCHAR2,
                                  p_attend_entity_id    IN  VARCHAR2,
                                  p_base_id             IN  NUMBER,
                                  p_persid_grp          IN  NUMBER
                                )
AS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

  -- To get group description for group_id
  CURSOR  cur_person_group(cp_persid_grp igs_pe_persid_group_all.group_id%TYPE) IS
    SELECT  group_cd group_name
      FROM  igs_pe_persid_group_all
     WHERE  group_id = cp_persid_grp;
  rec_person_group cur_person_group%ROWTYPE;

  l_ci_cal_type         VARCHAR2(11);
  l_ci_sequence_number  NUMBER(5);
  l_msg_str_1           VARCHAR2(2000);
  l_msg_str_2           VARCHAR2(2000);
  l_msg_str_3           VARCHAR2(2000);
  l_msg_str_4           VARCHAR2(2000);
  l_msg_str_5           VARCHAR2(2000);
  l_msg_str_6           VARCHAR2(2000);

BEGIN

  -- Get cal type and sequence number from award year
  l_ci_cal_type :=  LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
  l_ci_sequence_number  :=  NVL(TO_NUMBER(SUBSTR(p_award_year,11)),0);

  -- show award year
  l_msg_str_1 :=  RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','AWARD_YEAR'),30) ||
                  RPAD(igf_gr_gen.get_alt_code(l_ci_cal_type,l_ci_sequence_number),20);
  fnd_file.put_line(fnd_file.log,l_msg_str_1);

  -- show source entity id
  l_msg_str_2 :=  RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS', 'SOURCE_ENTITY_ID'),30) || p_source_entity_id;
  fnd_file.put_line(fnd_file.log,l_msg_str_2);

  -- show reporting entity
  IF (p_report_entity_id IS NOT NULL) THEN
    l_msg_str_3 :=  RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS', 'REPORT_ENTITY_ID'),30) || p_report_entity_id;
    fnd_file.put_line(fnd_file.log,l_msg_str_3);
  END IF;

  -- show attending entity
  IF (p_attend_entity_id IS NOT NULL) THEN
    l_msg_str_4 :=  RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS', 'ATTEND_ENTITY_ID'),30) || p_attend_entity_id;
    fnd_file.put_line(fnd_file.log,l_msg_str_4);
  END IF;

  -- show person number
  IF (p_base_id IS NOT NULL) THEN
    l_msg_str_5 :=  RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','BASE_ID'),30) ||
                    RPAD(igf_gr_gen.get_per_num(p_base_id),20);
    fnd_file.put_line(fnd_file.log,l_msg_str_5);
  END IF;

  -- show persond id group
  IF (p_persid_grp IS NOT NULL) THEN
    OPEN cur_person_group(p_persid_grp);
    FETCH cur_person_group INTO rec_person_group;
    CLOSE cur_person_group;
    l_msg_str_6 :=  RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS', 'PERSON_ID_GROUP'),30) || rec_person_group.group_name;
    fnd_file.put_line(fnd_file.log,l_msg_str_6);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GR_GEN_XML.LOG_INPUT_PARAMETERS');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END log_input_parameters;

FUNCTION validate_input_parameters (
                                p_award_year          IN  VARCHAR2,
                                p_source_entity_id    IN  VARCHAR2,
                                p_report_entity_id    IN  VARCHAR2,
                                p_attend_entity_id    IN  VARCHAR2,
                                p_base_id             IN  NUMBER,
                                p_persid_grp          IN  NUMBER
                              )
RETURN BOOLEAN
AS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
bvisvana        09-Aug-2005     Bug # 4124839 - Included the exception VALUE_ERROR
bvisvana        11-Oct-2005     Bug # 4124839 - Removed the exception VALUE_ERROR and handle it by adding a new function
                                 is_alpha_numeric
(reverse chronological order - newest change first)
***************************************************************/

  -- To get award year details from System award year mappings table.
  CURSOR  cur_awd_year  ( cp_cal_type         igs_ca_inst.cal_type%TYPE,
                          cp_sequence_number  igs_ca_inst.sequence_number%TYPE) IS
    SELECT  bam.award_year_status_code,
            bam.pell_participant_code,
            bam.sys_award_year
      FROM  IGF_AP_BATCH_AW_MAP bam
     WHERE  bam.ci_cal_type = cp_cal_type
      AND   bam.ci_sequence_number = cp_sequence_number;
  rec_awd_year  cur_awd_year%ROWTYPE;

  -- To get source entity id from Pell ID/Entity ID relationships.
  CURSOR  cur_source_entity ( cp_cal_type           igs_ca_inst.cal_type%TYPE,
                              cp_sequence_number    igs_ca_inst.sequence_number%TYPE,
                              cp_source_entity_id   igf_gr_report_pell.rep_entity_id_txt%TYPE) IS
    SELECT  'x'
      FROM  IGF_GR_REPORT_PELL rep
     WHERE  rep.ci_cal_type = cp_cal_type
      AND   rep.ci_sequence_number = cp_sequence_number
      AND   rep.rep_entity_id_txt = cp_source_entity_id;

  -- To check pell origination records exists or not with given report entity id.
  CURSOR  cur_rep_entity  ( cp_cal_type           igs_ca_inst.cal_type%TYPE,
                            cp_sequence_number    igs_ca_inst.sequence_number%TYPE,
                            cp_report_entity_id   igf_gr_rfms.rep_entity_id_txt%TYPE  ) IS
    SELECT  rfms.origination_id
      FROM  IGF_GR_RFMS rfms
     WHERE  rfms.ci_cal_type = cp_cal_type
      AND   rfms.ci_sequence_number = cp_sequence_number
      AND   rfms.rep_entity_id_txt = cp_report_entity_id;

  -- To check pell origination records exists or not with given report and attend entity ids.
  CURSOR  cur_attd_entity ( cp_cal_type           igs_ca_inst.cal_type%TYPE,
                            cp_sequence_number    igs_ca_inst.sequence_number%TYPE,
                            cp_report_entity_id   igf_gr_rfms.rep_entity_id_txt%TYPE,
                            cp_attend_entity_id   igf_gr_rfms.atd_entity_id_txt%TYPE  ) IS
    SELECT  rfms.origination_id
      FROM  IGF_GR_RFMS rfms
     WHERE  rfms.ci_cal_type = cp_cal_type
      AND   rfms.ci_sequence_number = cp_sequence_number
      AND   rfms.rep_entity_id_txt = cp_report_entity_id
      AND   rfms.atd_entity_id_txt = cp_attend_entity_id;

  -- To check fa base record exists or not.
  CURSOR  cur_fa_base ( cp_base_id  igf_ap_fa_base_rec_all.base_id%TYPE) IS
    SELECT  fabase.base_id
      FROM  IGF_AP_FA_BASE_REC_ALL fabase
     WHERE  fabase.base_id = cp_base_id;

  -- To check pell origination records exists or not with given person.
  CURSOR  cur_person_number ( cp_cal_type           igs_ca_inst.cal_type%TYPE,
                              cp_sequence_number    igs_ca_inst.sequence_number%TYPE,
                              cp_base_id            igf_ap_fa_base_rec_all.base_id%TYPE  ) IS
    SELECT  'x'
      FROM  IGF_GR_RFMS rfms
     WHERE  rfms.ci_cal_type = cp_cal_type
      AND   rfms.ci_sequence_number = cp_sequence_number
      AND   rfms.base_id = cp_base_id;

  -- To check fa base record exists or not.
  CURSOR  cur_person_group  ( cp_persid_grp igs_pe_persid_group_all.group_id%TYPE) IS
    SELECT  'x'
      FROM  IGS_PE_PERSID_GROUP_ALL pers
     WHERE  pers.group_id = cp_persid_grp
      AND   pers.closed_ind = 'N';

  l_params_status       BOOLEAN;
  l_ci_cal_type         VARCHAR2(11);
  l_ci_sequence_number  NUMBER;
  lv_dummy              VARCHAR2(40);
  ln_dummy              NUMBER(15);

BEGIN

  l_params_status := TRUE;

  -- Get cal type and sequence number from award year
  l_ci_cal_type :=  LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
  l_ci_sequence_number  :=  NVL(TO_NUMBER(SUBSTR(p_award_year,11)),0);

  -- Award year is mandatory parameter
  IF p_award_year IS NULL OR l_ci_cal_type IS NULL OR l_ci_sequence_number IS NULL THEN
    l_params_status := FALSE;
    fnd_message.set_name('IGF', 'IGF_SL_COD_REQ_PARAM');
    fnd_message.set_token('PARAM', igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','AWARD_YEAR'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
  END IF;

  -- Source entity id is mandatory parameter
  IF TRIM(p_source_entity_id) IS NULL THEN
    l_params_status := FALSE;
    fnd_message.set_name('IGF', 'IGF_SL_COD_REQ_PARAM');
    fnd_message.set_token('PARAM', igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS', 'SOURCE_ENTITY_ID'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
  ELSIF is_alpha_numeric(p_source_entity_id) OR LENGTH(TRIM(p_source_entity_id)) > 8 THEN
     -- bvisvana BUg # 4124839
    l_params_status := FALSE;
    fnd_message.set_name('IGF','IGF_SL_COD_INVL_SOURCE_ID');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
  END IF;

  -- validating person number and person group are mutually exclusive or not.
  IF ( (p_base_id IS NOT NULL) AND (p_persid_grp IS NOT NULL) ) THEN
    l_params_status := FALSE;
    fnd_message.set_name('IGF', 'IGF_SL_COD_INV_PARAM');
    fnd_message.set_token('PARAM1', igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS', 'BASE_ID'));
    fnd_message.set_token('PARAM2', igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS', 'PERSON_ID_GROUP'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
  END IF;

  -- Validating attributes for COD support.
  IF p_award_year IS NOT NULL THEN
    OPEN cur_awd_year(l_ci_cal_type, l_ci_sequence_number);
    FETCH cur_awd_year INTO rec_awd_year;
    IF cur_awd_year%NOTFOUND
      OR rec_awd_year.award_year_status_code IS NULL
      OR rec_awd_year.pell_participant_code IS NULL
      OR rec_awd_year.sys_award_year IS NULL
    THEN
      -- ie award year is not setup at System Award Year Mappings Form.
      l_params_status := FALSE;
      fnd_message.set_name('IGF', 'IGF_SL_COD_INV_AWD_YR');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      fnd_file.new_line(fnd_file.log, 1);
    ELSE
      -- check award year is Open award year or not.
      IF (rec_awd_year.award_year_status_code <> 'O') THEN
        l_params_status := FALSE;
        fnd_message.set_name('IGF', 'IGF_GR_COD_AWDYR_OPEN');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_file.new_line(fnd_file.log, 1);
      END IF;

      -- check pell participation is Full or not.
      IF (rec_awd_year.pell_participant_code <> 'FULL_PARTICIPANT') THEN
        l_params_status := FALSE;
        fnd_message.set_name('IGF', 'IGF_GR_COD_AWDYR_FULL');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_file.new_line(fnd_file.log, 1);
      END IF;

      -- check wether the award year is before 04-05.
      IF (rec_awd_year.sys_award_year < '0405') THEN
        l_params_status := FALSE;
        fnd_message.set_name('IGF', 'IGF_SL_COD_XML_SUPPORT');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_file.new_line(fnd_file.log, 1);
      END IF;
    END IF;
    CLOSE cur_awd_year;
  END IF;

  -- Validating source entity id.
  IF (p_source_entity_id IS NOT NULL) THEN
    OPEN cur_source_entity(l_ci_cal_type, l_ci_sequence_number, p_source_entity_id);
    FETCH cur_source_entity INTO lv_dummy;
    IF cur_source_entity%NOTFOUND THEN
      -- Not a valid source entity id.
      l_params_status := FALSE;
      fnd_message.set_name('IGF', 'IGF_SL_COD_INV_SRC_ID');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      fnd_file.new_line(fnd_file.log, 1);
    END IF;
    CLOSE cur_source_entity;
  END IF;

  -- Validate Reporting Entity ID. Records with report entity id exists or not.
  IF (p_report_entity_id IS NOT NULL) THEN
    OPEN cur_rep_entity(l_ci_cal_type, l_ci_sequence_number, p_report_entity_id);
    FETCH cur_rep_entity INTO lv_dummy;
    IF cur_rep_entity%NOTFOUND THEN
      -- No origination records to process.
      l_params_status := FALSE;
      fnd_message.set_name('IGF', 'IGF_GR_COD_INV_REP_ID');
      fnd_message.set_token('REPORTING_ID', p_report_entity_id);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      fnd_file.new_line(fnd_file.log, 1);
    END IF;
    CLOSE cur_rep_entity;
  END IF;

  -- Validate attending entity id. Is it present without reporting entity id.
  IF (p_attend_entity_id IS NOT NULL AND p_report_entity_id IS NULL) THEN
    l_params_status := FALSE;
    fnd_message.set_name('IGF', 'IGF_SL_COD_INV_ATD_PARAM');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
  END IF;

  -- Validate Attending Entity ID. Records with report and attend entity id exists or not.
  IF (p_attend_entity_id IS NOT NULL AND p_report_entity_id IS NOT NULL) THEN
    OPEN cur_attd_entity(l_ci_cal_type, l_ci_sequence_number, p_report_entity_id, p_attend_entity_id);
    FETCH cur_attd_entity INTO lv_dummy;
    IF cur_attd_entity%NOTFOUND THEN
      -- No origination records to process.
      l_params_status := FALSE;
      fnd_message.set_name('IGF', 'IGF_GR_COD_INV_ATD_ID');
      fnd_message.set_token('REPORTING_ID', p_report_entity_id);
      fnd_message.set_token('ATTENDING_ID', p_attend_entity_id);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      fnd_file.new_line(fnd_file.log, 1);
    END IF;
    CLOSE cur_attd_entity;
  END IF;

  -- Validate Person Number.
  IF (p_base_id IS NOT NULL) THEN
    -- check fa base record exists or not.
    IF NOT check_fa_rec(p_base_id, l_ci_cal_type, l_ci_sequence_number) THEN
      l_params_status := FALSE;
      fnd_message.set_name('IGF', 'IGF_SP_NO_FA_BASE_REC');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      fnd_file.new_line(fnd_file.log, 1);
    ELSE
      -- check wether this person has any pell origination records or not.
      OPEN cur_person_number(l_ci_cal_type, l_ci_sequence_number, p_base_id);
      FETCH cur_person_number INTO lv_dummy;
      IF cur_person_number%NOTFOUND THEN
        -- no pell origination records for this person.
        l_params_status := FALSE;
        fnd_message.set_name('IGF', 'IGF_GR_COD_NO_ORIG_REC');
        fnd_message.set_token('PERSON_NUMBER', igf_gr_gen.get_per_num(p_base_id));
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_file.new_line(fnd_file.log, 1);
      END IF;
      CLOSE cur_person_number;
    END IF;
  END IF;

  -- Validate Person Id group.
  IF (p_persid_grp IS NOT NULL) THEN
    OPEN cur_person_group(p_persid_grp);
    FETCH cur_person_group INTO lv_dummy;
    IF cur_person_group%NOTFOUND THEN
      -- Invalid person id group.
      l_params_status := FALSE;
      fnd_message.set_name('IGF', 'IGF_SL_COD_PERSID_GRP_INV');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      fnd_file.new_line(fnd_file.log, 1);
    END IF;
    CLOSE cur_person_group;
  END IF;

  RETURN l_params_status;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GR_GEN_XML.VALIDATE_INPUT_PARAMETERS');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END validate_input_parameters;

FUNCTION  xml_boundary_validate ( p_rfms_rec cur_rfms%ROWTYPE )
RETURN BOOLEAN AS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

  -- Cursor to get disbursement data from IGF_AW_DB_CHG_DTLS table.
  CURSOR cur_disb_chg_dtls  ( cp_award_id igf_aw_db_chg_dtls.award_id%TYPE) IS
    SELECT  award_id,
            disb_num,
            disb_seq_num,
            disb_accepted_amt,
            disb_date
      FROM  IGF_AW_DB_CHG_DTLS dbchgdtls
     WHERE  dbchgdtls.award_id = cp_award_id;
  rec_disb_chg_dtls  cur_disb_chg_dtls%ROWTYPE;


  student_dtl_cur   igf_sl_gen.person_dtl_cur;
  lv_complete       BOOLEAN := TRUE;
  l_award_id        igf_aw_db_chg_dtls.award_id%TYPE;

  --akomurav

  CURSOR cur_isir_info (p_base_id NUMBER) IS
    SELECT  payment_isir,transaction_num,dependency_status,
        date_of_birth,current_ssn,last_name,middle_initial
	FROM  igf_ap_isir_matched_all
	WHERE base_id      = p_base_id
		AND   payment_isir = 'Y'
		AND   system_record_type = 'ORIGINAL';



  isir_info_rec cur_isir_info%ROWTYPE;
  --akomurav

BEGIN

  -- Use the igf_sl_gen.get_person_details for getting the student
  igf_sl_gen.get_person_details(igf_gr_gen.get_person_id(p_rfms_rec.base_id),student_dtl_cur);
  FETCH student_dtl_cur INTO student_dtl_rec;

  CLOSE student_dtl_cur;

  --akomurav
  OPEN  cur_isir_info (p_rfms_rec.base_id);
  FETCH cur_isir_info INTO isir_info_rec;
  CLOSE cur_isir_info;

  student_dtl_rec.p_date_of_birth := isir_info_rec.date_of_birth;
  student_dtl_rec.p_ssn := isir_info_rec.current_ssn;
  student_dtl_rec.p_last_name := UPPER(isir_info_rec.last_name);
  student_dtl_rec.p_middle_name := UPPER(isir_info_rec.middle_initial);
  --akomurav


  lv_complete  := TRUE;

  -- validating full response code
  IF ( p_rfms_rec.full_resp_code NOT IN ('S', 'F', 'M', 'N') ) THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','FULL_RESP_CD'));
    fnd_message.set_token('FIELD_VALUE',p_rfms_rec.full_resp_code);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- validating student's date of birth
  IF g_ver_num = '2004-2005' THEN
    IF ( (student_dtl_rec.p_date_of_birth < TO_DATE('01011905', 'DDMMYYYY')) OR (student_dtl_rec.p_date_of_birth > TO_DATE('31121996', 'DDMMYYYY')) ) THEN
      lv_complete := FALSE;
      fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
      fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_DATE_OF_BIRTH'));
      fnd_message.set_token('FIELD_VALUE',p_rfms_rec.birth_dt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    END IF;
  END IF;
  IF g_ver_num = '2005-2006' THEN
    IF ( (student_dtl_rec.p_date_of_birth < TO_DATE('01011906', 'DDMMYYYY')) OR (student_dtl_rec.p_date_of_birth > TO_DATE('31121997', 'DDMMYYYY')) ) THEN
      lv_complete := FALSE;
      fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
      fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_DATE_OF_BIRTH'));
      fnd_message.set_token('FIELD_VALUE',p_rfms_rec.birth_dt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    END IF;
  END IF;
    IF g_ver_num = '2006-2007' THEN -- check made as part of FA162(COD Reg Updates R12 porting)
    IF ( (student_dtl_rec.p_date_of_birth < TO_DATE('01011907', 'DDMMYYYY')) OR (student_dtl_rec.p_date_of_birth > TO_DATE('31121998', 'DDMMYYYY')) ) THEN
      lv_complete := FALSE;
      fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
      fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_DATE_OF_BIRTH'));
      fnd_message.set_token('FIELD_VALUE',p_rfms_rec.birth_dt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    END IF;
  END IF;

  -- validating student's SSN
  IF ( (student_dtl_rec.p_ssn < '001010001') OR (student_dtl_rec.p_ssn > '999999998') ) THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_SSN'));
    fnd_message.set_token('FIELD_VALUE',student_dtl_rec.p_ssn);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- validating student's first name
  IF ( LENGTH(student_dtl_rec.p_first_name) > 12) THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_FIRST_NAME'));
    fnd_message.set_token('FIELD_VALUE',student_dtl_rec.p_first_name);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- validating student's last name
  IF ( LENGTH(student_dtl_rec.p_last_name) > 35) THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_LAST_NAME'));
    fnd_message.set_token('FIELD_VALUE',student_dtl_rec.p_last_name);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- validating student's middle name
  IF ( LENGTH(student_dtl_rec.p_middle_name) > 1) THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_MIDDLE_NAME'));
    fnd_message.set_token('FIELD_VALUE',student_dtl_rec.p_middle_name);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- validating student's driver licencse state
  IF ( (LENGTH(student_dtl_rec.p_license_state) < 2) OR (LENGTH(student_dtl_rec.p_license_state) > 3) )THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','P_LICENSE_STATE'));
    fnd_message.set_token('FIELD_VALUE',student_dtl_rec.p_license_state);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- validating student's driver licencse number
  IF ( LENGTH(student_dtl_rec.p_license_num) > 20) THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_LICENSE_NUM'));
    fnd_message.set_token('FIELD_VALUE',student_dtl_rec.p_license_num);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- validating student's citizenship status code
  IF ( (LENGTH(student_dtl_rec.p_citizenship_status) > 1) OR (student_dtl_rec.p_citizenship_status NOT IN ('1', '2', '3')) ) THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_CITIZENSHIP_STATUS'));
    fnd_message.set_token('FIELD_VALUE',student_dtl_rec.p_citizenship_status);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- validating note message
  IF ( LENGTH(p_rfms_rec.note_message) > 20) THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','NOTE_MESSAGE'));
    fnd_message.set_token('FIELD_VALUE',p_rfms_rec.note_message);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- validating student's low_tution_fee
  IF ( (LENGTH(p_rfms_rec.low_tution_fee) > 1) OR (p_rfms_rec.low_tution_fee NOT IN ('1', '2', '3', '4')) ) THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','LOW_TUTION_FEE'));
    fnd_message.set_token('FIELD_VALUE',p_rfms_rec.low_tution_fee);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- validating transaction number
  IF ( (LENGTH(p_rfms_rec.transaction_num) < '01') OR (LENGTH(p_rfms_rec.transaction_num) > '99') ) THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','TRANSACTION_NUMBER'));
    fnd_message.set_token('FIELD_VALUE',p_rfms_rec.transaction_num);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- validating enrollment date
  IF g_ver_num = '2004-2005' THEN
    IF ( (p_rfms_rec.enrollment_dt < TO_DATE('01012004', 'DDMMYYYY')) OR (p_rfms_rec.enrollment_dt > TO_DATE('30062005', 'DDMMYYYY')) ) THEN
      lv_complete := FALSE;
      fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
      fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ENROLLMENT_DT'));
      fnd_message.set_token('FIELD_VALUE',p_rfms_rec.enrollment_dt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    END IF;
  END IF;
  IF g_ver_num = '2005-2006' THEN
    IF ( (p_rfms_rec.enrollment_dt < TO_DATE('01012005', 'DDMMYYYY')) OR (p_rfms_rec.enrollment_dt > TO_DATE('30062006', 'DDMMYYYY')) ) THEN
      lv_complete := FALSE;
      fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
      fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ENROLLMENT_DT'));
      fnd_message.set_token('FIELD_VALUE',p_rfms_rec.enrollment_dt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    END IF;
  END IF;
    IF g_ver_num = '2006-2007' THEN -- check made as part of FA162(COD Reg Updates R12 porting)
    IF ( (p_rfms_rec.enrollment_dt < TO_DATE('01012006', 'DDMMYYYY')) OR (p_rfms_rec.enrollment_dt > TO_DATE('30062007', 'DDMMYYYY')) ) THEN
      lv_complete := FALSE;
      fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
      fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ENROLLMENT_DT'));
      fnd_message.set_token('FIELD_VALUE',p_rfms_rec.enrollment_dt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    END IF;
  END IF;

  -- validating secondary efc
  IF ( (LENGTH(p_rfms_rec.secondary_efc_cd) > 1) OR (p_rfms_rec.secondary_efc_cd NOT IN ('O', 'S')) ) THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_AP_AWARDING_FC_TYPE','2'));
    fnd_message.set_token('FIELD_VALUE',p_rfms_rec.secondary_efc);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- validating verification status code
  IF ( (LENGTH(p_rfms_rec.ver_status_code) > 1) OR (p_rfms_rec.ver_status_code NOT IN ('W', 'V', 'S')) ) THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SYS_VAL_VER'));
    fnd_message.set_token('FIELD_VALUE',p_rfms_rec.ver_status_code);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- validating incarcerated status.
  IF ( p_rfms_rec.incrcd_fed_pell_rcp_cd IS NOT NULL AND ((LENGTH(p_rfms_rec.incrcd_fed_pell_rcp_cd) > 1) OR (p_rfms_rec.incrcd_fed_pell_rcp_cd NOT IN ('Y', 'N'))) ) THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','INCRCD_FED_PELL_RCP_CD'));
    fnd_message.set_token('FIELD_VALUE',p_rfms_rec.incrcd_fed_pell_rcp_cd);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  IF ( p_rfms_rec.pell_amount >= 999999999.99) THEN
    lv_complete := FALSE;
    fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
    fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SYS_VAL_PELL'));
    fnd_message.set_token('FIELD_VALUE',p_rfms_rec.pell_amount);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

  -- validating disbursement data from the IGF_AW_DB_CHG_DTLS table
  l_award_id := p_rfms_rec.award_id;
  FOR rec_disb_chg_dtls IN cur_disb_chg_dtls(l_award_id) LOOP
    -- validating disbursement accepted amount
    IF ( rec_disb_chg_dtls.disb_accepted_amt >= 999999999.99) THEN
      lv_complete := FALSE;
      fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
      fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SYS_VAL_DB_AMT'));
      fnd_message.set_token('FIELD_VALUE',rec_disb_chg_dtls.disb_accepted_amt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    END IF;

    -- validating disbursement number
    IF ( rec_disb_chg_dtls.disb_num >= 60) THEN
      lv_complete := FALSE;
      fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
      fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','DISB_NUM'));
      fnd_message.set_token('FIELD_VALUE',rec_disb_chg_dtls.disb_num);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    END IF;

    -- validating disbursement sequence number
    IF ( rec_disb_chg_dtls.disb_seq_num >= 99) THEN
      lv_complete := FALSE;
      fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
      fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_SEQ_NUM'));
      fnd_message.set_token('FIELD_VALUE',rec_disb_chg_dtls.disb_seq_num);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    END IF;

    -- validating disbursement date
    IF g_ver_num = '2004-2005' THEN
      IF ( (rec_disb_chg_dtls.disb_date < TO_DATE('22062003', 'DDMMYYYY')) OR (rec_disb_chg_dtls.disb_date > TO_DATE('27102006', 'DDMMYYYY')) ) THEN
        lv_complete := FALSE;
        fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
        fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_CL_CHANGE_FIELDS','DISB_DATE'));
        fnd_message.set_token('FIELD_VALUE',rec_disb_chg_dtls.disb_date);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
      END IF;
    END IF;
    IF g_ver_num = '2005-2006' THEN
      IF ( (rec_disb_chg_dtls.disb_date < TO_DATE('22062004', 'DDMMYYYY')) OR (rec_disb_chg_dtls.disb_date > TO_DATE('27102007', 'DDMMYYYY')) ) THEN
        lv_complete := FALSE;
        fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
        fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_CL_CHANGE_FIELDS','DISB_DATE'));
        fnd_message.set_token('FIELD_VALUE',rec_disb_chg_dtls.disb_date);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
      END IF;
    END IF;
    IF g_ver_num = '2006-2007' THEN    -- check made as part of FA162(COD Reg Updates R12 porting)
      IF ( (rec_disb_chg_dtls.disb_date < TO_DATE('01072006', 'DDMMYYYY')) OR (rec_disb_chg_dtls.disb_date > TO_DATE('27102009', 'DDMMYYYY')) ) THEN
 	lv_complete := FALSE;
 	fnd_message.set_name('IGF','IGF_GR_COD_INVALID_VALUE');
  fnd_message.set_token('FIELD_NAME',igf_aw_gen.lookup_desc('IGF_SL_CL_CHANGE_FIELDS','DISB_DATE'));
 	fnd_message.set_token('FIELD_VALUE',rec_disb_chg_dtls.disb_date);
 	fnd_file.put_line(fnd_file.log, fnd_message.get);
      END IF;
    END IF;
  END LOOP;

  RETURN lv_complete;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GR_GEN_XML.XML_BOUNDARY_VALIDATE');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END xml_boundary_validate;

PROCEDURE insert_into_cod_tables(p_rfms_rec cur_rfms%ROWTYPE, p_source_entity_id VARCHAR2)
IS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

  -- Cursor to get disbursement data from IGF_AW_DB_CHG_DTLS table.
  CURSOR cur_disb_chg_dtls  ( cp_award_id igf_aw_db_chg_dtls.award_id%TYPE) IS
    SELECT  award_id,
            disb_num,
            disb_seq_num,
            disb_accepted_amt,
            disb_date
      FROM  IGF_AW_DB_CHG_DTLS dbchgdtls
     WHERE  dbchgdtls.award_id = cp_award_id;
  rec_disb_chg_dtls  cur_disb_chg_dtls%ROWTYPE;

  -- Cursor to get ssn, last_name, dob from IGF_GR_COD_DTLS table
  CURSOR cur_get_chg_data ( cp_origination_id igf_gr_cod_dtls.origination_id%TYPE)  IS
    SELECT  s_ssn, s_last_name, s_date_of_birth
      FROM  IGF_GR_COD_DTLS
     WHERE  origination_id  = cp_origination_id;
  rec_get_chg_data  cur_get_chg_data%ROWTYPE;

  -- Cursor to get disbursement data.
  CURSOR cur_disb_rec (cp_award_id NUMBER) IS
    SELECT  chg.*
      FROM  igf_aw_db_chg_dtls chg
     WHERE  award_id = cp_award_id
      AND   disb_status = 'G';  -- Ready to Send (introduced this predicate again bcz of bug #4390096)

  student_dtl_cur   igf_sl_gen.person_dtl_cur;

  lv_last_name      VARCHAR2(150);
  lv_ssn            VARCHAR2(30);
  ld_dob            DATE;
  lv_chg_last_name  VARCHAR2(150);
  lv_chg_ssn        VARCHAR2(30);
  ld_chg_dob        DATE;
  lv_rowid          ROWID;
  l_s_phone         VARCHAR2(30);


  --akomurav

  CURSOR cur_isir_info (p_base_id NUMBER) IS
    SELECT  payment_isir,transaction_num,dependency_status,
        date_of_birth,current_ssn,last_name,middle_initial
	FROM  igf_ap_isir_matched_all
	WHERE base_id      = p_base_id
		AND   payment_isir = 'Y'
		AND   system_record_type = 'ORIGINAL';



  isir_info_rec cur_isir_info%ROWTYPE;
  --akomurav

BEGIN

  -- Use the igf_sl_gen.get_person_details for getting the student
  igf_sl_gen.get_person_details(igf_gr_gen.get_person_id(p_rfms_rec.base_id),student_dtl_cur);
  FETCH student_dtl_cur INTO student_dtl_rec;
  CLOSE student_dtl_cur;

  --akomurav
   OPEN  cur_isir_info (p_rfms_rec.base_id);
   FETCH cur_isir_info INTO isir_info_rec;
   CLOSE cur_isir_info;

   student_dtl_rec.p_date_of_birth := isir_info_rec.date_of_birth;
   student_dtl_rec.p_ssn := isir_info_rec.current_ssn;
   student_dtl_rec.p_last_name := UPPER(isir_info_rec.last_name);
   student_dtl_rec.p_middle_name := UPPER(isir_info_rec.middle_initial);
  --akomurav



  lv_chg_last_name  :=  NULL;
  lv_chg_ssn        :=  NULL;
  ld_chg_dob        :=  NULL;

  OPEN cur_get_chg_data(p_rfms_rec.origination_id);
  FETCH cur_get_chg_data INTO rec_get_chg_data;
  IF cur_get_chg_data%NOTFOUND THEN
    lv_last_name  :=  UPPER(student_dtl_rec.p_last_name);
    lv_ssn        :=  student_dtl_rec.p_ssn;
    ld_dob        :=  student_dtl_rec.p_date_of_birth;
    CLOSE cur_get_chg_data;
  ELSE
    lv_last_name      :=  UPPER(rec_get_chg_data.s_last_name);
    lv_ssn            :=  rec_get_chg_data.s_ssn;
    ld_dob            :=  rec_get_chg_data.s_date_of_birth;

    IF UPPER(rec_get_chg_data.s_last_name) <> UPPER(student_dtl_rec.p_last_name) THEN
      lv_chg_last_name  :=  UPPER(student_dtl_rec.p_last_name);
    END IF;

    IF rec_get_chg_data.s_ssn <> student_dtl_rec.p_ssn THEN
      lv_chg_ssn  :=  student_dtl_rec.p_ssn;
    END IF;

    IF rec_get_chg_data.s_date_of_birth <> student_dtl_rec.p_date_of_birth THEN
      ld_chg_dob  :=  student_dtl_rec.p_date_of_birth;
    END IF;

    CLOSE cur_get_chg_data;
  END IF;
  --akomurav

  l_s_phone := igf_sl_gen.get_person_phone(igf_gr_gen.get_person_id(p_rfms_rec.base_id));

  IF l_s_phone = 'N/A' then
     l_s_phone := NULL;
  END IF;

  igf_gr_cod_dtls_pkg.add_row(
    x_rowid                             =>  lv_rowid,
    x_origination_id                    =>  p_rfms_rec.origination_id,
    x_award_id                          =>  p_rfms_rec.award_id,
    x_document_id_txt                   =>  gv_document_id_txt,
    x_base_id                           =>  p_rfms_rec.base_id,
    x_fin_award_year                    =>  SUBSTR(g_ver_num,-4),
    x_cps_trans_num                     =>  p_rfms_rec.transaction_num,
    x_award_amt                         =>  p_rfms_rec.pell_amount,
    x_coa_amt                           =>  p_rfms_rec.coa_amount,
    x_low_tution_fee                    =>  p_rfms_rec.low_tution_fee,
    x_incarc_flag                       =>  p_rfms_rec.incrcd_fed_pell_rcp_cd,
    x_ver_status_code                   =>  p_rfms_rec.ver_status_code,
    x_enrollment_date                   =>  p_rfms_rec.enrollment_dt,
    x_sec_efc_code                      =>  p_rfms_rec.secondary_efc,
    x_ytd_disb_amt                      =>  NULL,
    x_tot_elig_used                     =>  NULL,
    x_schd_pell_amt                     =>  NULL,
    x_neg_pend_amt                      =>  NULL,
    x_cps_verif_flag                    =>  NULL,
    x_high_cps_trans_num                =>  NULL,
    x_note_message                      =>  p_rfms_rec.note_message,
    x_full_resp_code                    =>  NVL(g_full_resp_code, 'F'),
    x_atd_entity_id_txt                 =>  p_rfms_rec.atd_entity_id_txt,
    x_rep_entity_id_txt                 =>  p_rfms_rec.rep_entity_id_txt,
    x_source_entity_id_txt              =>  p_source_entity_id,
    x_pell_status                       =>  p_rfms_rec.orig_action_code,
    x_pell_status_date                  =>  p_rfms_rec.orig_status_dt,
    x_s_ssn                               =>  lv_ssn,
    x_driver_lic_state                  =>  student_dtl_rec.p_license_state,
    x_driver_lic_number                 =>  student_dtl_rec.p_license_num,
    x_s_date_of_birth                        =>  ld_dob,
    x_first_name                        =>  UPPER(student_dtl_rec.p_first_name),
    x_middle_name                       =>  UPPER(student_dtl_rec.p_middle_name),
    x_s_last_name                         =>  lv_last_name,
    x_s_chg_date_of_birth               =>  ld_chg_dob,
    x_s_chg_ssn                         =>  lv_chg_ssn,
    x_s_chg_last_name                   =>  lv_chg_last_name,
    x_permt_addr_foreign_flag           =>  NULL,
    x_addr_type_code                    =>  NULL,
    x_permt_addr_line_1                 =>  UPPER(student_dtl_rec.p_permt_addr1),
    x_permt_addr_line_2                 =>  UPPER(student_dtl_rec.p_permt_addr2),
    x_permt_addr_line_3                 =>  NULL,--UPPER(student_dtl_rec.p_permt_addr3),
    x_permt_addr_city                   =>  UPPER(student_dtl_rec.p_permt_city),
    x_permt_addr_state_code             =>  UPPER(student_dtl_rec.p_permt_state),
    x_permt_addr_post_code              =>  UPPER(student_dtl_rec.p_permt_zip),
    x_permt_addr_county                 =>  UPPER(student_dtl_rec.p_county),
    x_permt_addr_country                =>  UPPER(student_dtl_rec.p_country),
    x_phone_number_1                    =>  l_s_phone,
    x_phone_number_2                    =>  NULL,
    x_phone_number_3                    =>  NULL,
    x_email_address                     =>  UPPER(student_dtl_rec.p_email_addr),
    x_citzn_status_code                 =>  student_dtl_rec.p_citizenship_status,
    x_mode                              =>  'R');

  FOR rec IN cur_disb_rec (p_rfms_rec.award_id)
  LOOP
    lv_rowid := NULL;
    IF rec.disb_conf_flag IS NULL THEN
      rec.disb_conf_flag := 'false';
    ELSIF rec.disb_conf_flag = 'Y' THEN
      rec.disb_conf_flag := 'false';
    ELSIF rec.disb_conf_flag = 'N' THEN
      rec.disb_conf_flag := 'true';
    END IF;
    igf_aw_db_cod_dtls_pkg.add_row( x_rowid                 => lv_rowid,
                                    x_award_id              => rec.award_id,
                                    x_document_id_txt       => gv_document_id_txt,
                                    x_disb_num              => rec.disb_num,
                                    x_disb_seq_num          => rec.disb_seq_num,
                                    x_disb_accepted_amt     => rec.disb_accepted_amt,
                                    x_orig_fee_amt          => rec.orig_fee_amt,
                                    x_disb_net_amt          => rec.disb_net_amt,
                                    x_disb_date             => rec.disb_date,
                                    x_disb_rel_flag         => LOWER(rec.disb_rel_flag),
                                    x_first_disb_flag       => rec.first_disb_flag,
                                    x_interest_rebate_amt   => rec.interest_rebate_amt,
                                    x_disb_conf_flag        => rec.disb_conf_flag,
                                    x_pymnt_per_start_date  => rec.pymnt_prd_start_date,
                                    x_note_message          => rec.note_message,
                                    x_rep_entity_id_txt     => p_rfms_rec.rep_entity_id_txt,
                                    x_atd_entity_id_txt     => p_rfms_rec.atd_entity_id_txt,
                                    x_mode                  => 'R');

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.insert_into_cod_tables.debug','after inserting cod db dtls seq num, disb num, award id' || rec.disb_seq_num || ' , ' || rec.disb_num || ' , ' || rec.award_id);
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GR_GEN_XML.INSERT_INTO_COD_TABLES');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END insert_into_cod_tables;

PROCEDURE process_rfms_record(p_rfms_rec IN OUT NOCOPY cur_rfms%ROWTYPE, p_source_entity_id VARCHAR2)
IS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

  CURSOR cur_attending_entity ( cp_ci_cal_type          igf_gr_report_pell.ci_cal_type%TYPE,
                                cp_ci_sequence_number   igf_gr_report_pell.ci_sequence_number%TYPE,
                                cp_rep_entity_id_txt    igf_gr_report_pell.rep_entity_id_txt%TYPE,
                                cp_atd_entity_id_txt    igf_gr_attend_pell.atd_entity_id_txt%TYPE)  IS
    SELECT  'Y'
      FROM  IGF_GR_REPORT_PELL rep, IGF_GR_ATTEND_PELL atd
     WHERE  rep.rcampus_id            =   atd.rcampus_id
      AND   rep.ci_cal_type           =   cp_ci_cal_type
      AND   rep.ci_sequence_number    =   cp_ci_sequence_number
      AND   rep.rep_entity_id_txt     =   cp_rep_entity_id_txt
      AND   atd.atd_entity_id_txt     =   cp_atd_entity_id_txt;
  rec_attending_entity  cur_attending_entity%ROWTYPE;

  CURSOR  cur_pymnt_isir  ( cp_base_id  igf_gr_rfms.base_id%TYPE )  IS
    SELECT  isir.transaction_num
      FROM  IGF_AP_ISIR_MATCHED_ALL isir
     WHERE  isir.base_id = cp_base_id
      AND   isir.payment_isir = 'Y'
      AND   isir.system_record_type = 'ORIGINAL';
  cur_pymnt_isir_rec cur_pymnt_isir%rowtype;

  CURSOR  cur_disb_amt_tot  ( cp_award_id igf_aw_db_chg_dtls.award_id%TYPE) IS
    SELECT  sum(a.disb_accepted_amt) disb_amt_tot
      FROM  IGF_AW_DB_CHG_DTLS a
     WHERE  a.award_id = cp_award_id
      AND   NVL(a.disb_activity, 'x') <> 'Q'
      AND   a.disb_seq_num = (  SELECT  max(b.disb_seq_num)
                                  FROM  IGF_AW_DB_CHG_DTLS b
                                 WHERE  b.award_id = cp_award_id
                                  AND   NVL(b.disb_activity, 'x') <> 'Q'
                                  AND   b.disb_num = a.disb_num);
  rec_disb_amt_tot  cur_disb_amt_tot%ROWTYPE;

  -- To get number of disbursements with disbursement release indicator 'true'
  CURSOR cur_get_num_of_disb  (cp_award_id igf_aw_awd_disb.award_id%TYPE) IS
    SELECT  count(*)
      FROM  IGF_AW_AWD_DISB disb
     WHERE  disb.award_id = cp_award_id
      AND   UPPER(disb.hold_rel_ind) = 'TRUE';
  ln_num_disb_with_relflag_true NUMBER(3);

  l_isir_present      BOOLEAN;
  lb_spoint_est       BOOLEAN;
  l_pell_amt          igf_gr_rfms.pell_amount%TYPE;
  l_ft_pell_amt       igf_gr_rfms_all.ft_pell_amount%TYPE;
  l_return_status     VARCHAR2(1);
  l_return_mesg_text  VARCHAR2(2000);

BEGIN
  -- This is Step 4.

  IF gv_document_id_txt IS NULL THEN
    gv_document_id_txt := TO_CHAR(TRUNC(SYSDATE),'YYYY-MM-DD')||'T'||TO_CHAR(SYSDATE,'HH:MM:SS') || '.00' || LPAD(p_source_entity_id, 8, '0');
  END IF;
  -- 1. validate general validations
  -- 2. validate xml boundary validations
  -- 3. insert data into IGF_GR_COD_DTLS and IGF_AW_DB_COD_DTLS tables.

  fnd_message.set_name('IGF','IGF_GR_PROCESS_STUD');
  fnd_message.set_token('PER_NUM',igf_gr_gen.get_per_num(p_rfms_rec.base_id));
  fnd_message.set_token('ORIG_ID',p_rfms_rec.origination_id);
  fnd_file.put_line(fnd_file.log,fnd_message.get);

  -- validate general validations

  -- check if attending entity id is a child of reporting entity id.
  rec_attending_entity := NULL;
  OPEN cur_attending_entity ( p_rfms_rec.ci_cal_type, p_rfms_rec.ci_sequence_number, p_rfms_rec.rep_entity_id_txt, p_rfms_rec.atd_entity_id_txt);
  FETCH cur_attending_entity INTO rec_attending_entity;
  IF (cur_attending_entity%NOTFOUND) THEN               -- Attending entity child record exists?
    -- No attending pell child record exists. Do not process this record
    CLOSE cur_attending_entity;
    fnd_message.set_name('IGF','IGF_GR_ATD_ENTITY_NOT_SETUP');
	  fnd_message.set_token('ATD_ENTITY', p_rfms_rec.atd_entity_id_txt);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    RETURN;
  ELSE
    -- attending pell child record exists. Proceed further...
    CLOSE cur_attending_entity;
  END IF;

  -- Get The Payment ISIR Transaction Number
  cur_pymnt_isir_rec := NULL;
  l_isir_present     := TRUE;
  OPEN cur_pymnt_isir(p_rfms_rec.base_id);
  FETCH cur_pymnt_isir INTO cur_pymnt_isir_rec;
  IF cur_pymnt_isir%NOTFOUND THEN
    l_isir_present  := FALSE;
  END IF;
  CLOSE cur_pymnt_isir;

  IF NOT l_isir_present THEN
    fnd_message.set_name('IGF','IGF_AP_NO_PAYMENT_ISIR');
    fnd_file.put_line(fnd_file.log,fnd_message.get);

  -- If the Transaction Number being reported does not match do not Originate
  ELSIF p_rfms_rec.transaction_num <> NVL(cur_pymnt_isir_rec.transaction_num,-1) THEN
    fnd_message.set_name('IGF','IGF_GR_PYMNT_ISIR_MISMATCH');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RETURN;
  END IF;

  -- Get disbursements amounts total
  rec_disb_amt_tot := NULL;
  OPEN cur_disb_amt_tot(p_rfms_rec.award_id);
  FETCH cur_disb_amt_tot INTO rec_disb_amt_tot;
  CLOSE cur_disb_amt_tot;

  -- If origination record's amount is less than sum of disbursement amounts, then do not originate.
  IF (p_rfms_rec.pell_amount < rec_disb_amt_tot.disb_amt_tot) THEN
    fnd_message.set_name('IGF','IGF_GR_PELL_DIFF_AMTS');
    fnd_message.set_token('DISB_AMT', TO_CHAR(rec_disb_amt_tot.disb_amt_tot));
    fnd_message.set_token('PELL_TOT', TO_CHAR(p_rfms_rec.pell_amount));
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RETURN;
  END IF;

  -- If Student's verification status is 'W' then we can send only one disbursment with
  -- disbursement release indicator as 'true'. If there are more than one disb, then log a mesg.
  IF (p_rfms_rec.ver_status_code = 'W') THEN
    -- count number of disb with release indicator as 'true'
    ln_num_disb_with_relflag_true := 0;
    OPEN cur_get_num_of_disb(p_rfms_rec.award_id);
    FETCH cur_get_num_of_disb INTO ln_num_disb_with_relflag_true;
    CLOSE cur_get_num_of_disb;

    IF ln_num_disb_with_relflag_true > 1 THEN
      fnd_message.set_name('IGF','IGF_GR_COD_VERF_STAT_W');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RETURN;
    END IF;
  END IF;

  -- Check accepted pell <= Calculated Pell. Otherwise log mesg.
  igf_gr_pell_calc.calc_ft_max_pell ( cp_base_id          =>  p_rfms_rec.base_id,
                                      cp_cal_type         =>  p_rfms_rec.ci_cal_type,
                                      cp_sequence_number  =>  p_rfms_rec.ci_sequence_number,
                                      cp_flag             =>  'FULL_TIME',
                                      cp_aid              =>  l_pell_amt,
                                      cp_ft_aid           =>  l_ft_pell_amt,
                                      cp_return_status    =>  l_return_status,
                                      cp_message          =>  l_return_mesg_text
                                    );
  IF (l_return_status = 'E') THEN
    fnd_file.put_line(fnd_file.log, l_return_mesg_text);
    RETURN;
  ELSE
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_gen_xml.process_rfms_record.debug','l_pell_amt = ' || l_pell_amt || 'and l_ft_pell_amt = ' || l_ft_pell_amt);
    END IF;
    IF p_rfms_rec.pell_amount > l_ft_pell_amt THEN
      fnd_message.set_name('IGF','IGF_GR_LIMIT_EXC');
      fnd_message.set_token('PEL_AMT',l_ft_pell_amt);
      fnd_message.set_token('AWD_AMT',p_rfms_rec.pell_amount);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RETURN;
    END IF;
  END IF;

  -- Updates to COD Technical Reference (May 05 changes)
  -- Attendance Cost tag is mandatory when processing a Pell Grant anticipated/actual disbursement.
  -- Check wether the attendance cost value is NULL or not. If NULL, then log a message.
  IF p_rfms_rec.coa_amount IS NULL THEN
    fnd_message.set_name('IGF','IGF_GR_NO_COA_NULL');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    RETURN;
  END IF;

  -- xml boundary validations.
  IF NOT xml_boundary_validate (p_rfms_rec) THEN
    RETURN;
  END IF;

  -- insert data into cod tables.
  lb_spoint_est := FALSE;
  SAVEPOINT IGFGR12B_PROCESS_RFMS_REC;
  lb_spoint_est := TRUE;
  insert_into_cod_tables(p_rfms_rec, p_source_entity_id);

EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_gen_xml.process_rfms_record.exception','Exception:'||SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GR_XML_INSERT_EXC');
    fnd_message.set_token('ORIGINATION_ID',p_rfms_rec.origination_id);
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    fnd_file.put_line(fnd_file.log,SQLERRM);
    IF lb_spoint_est THEN
      lb_spoint_est := FALSE;
      ROLLBACK TO IGFGR12B_PROCESS_RFMS_REC;
    END IF;
END process_rfms_record;

PROCEDURE submit_xml_event  ( p_document_id VARCHAR2)
IS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

  l_parameter_list  wf_parameter_list_t;

  l_event_name  VARCHAR2(255);
  l_event_key   NUMBER;
  l_map_code    VARCHAR2(255);
  l_param_1     VARCHAR2(255);

  CURSOR cur_sequence IS SELECT IGF_GR_PELL_GEN_XML_S.NEXTVAL FROM DUAL;

BEGIN

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.submit_xml_event','p_document id: '||p_document_id);
  END IF;

  l_parameter_list  := wf_parameter_list_t();
  l_event_name      := 'oracle.apps.igf.gr.genxml';
  l_map_code        := 'IGF_GR_PELL_OUT';
  l_param_1         :=  p_document_id;

  OPEN  cur_sequence;
  FETCH cur_sequence INTO l_event_key;
  CLOSE cur_sequence;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.submit_xml_event','l_event_key : '||l_event_key);
  END IF;

  -- Now add the parameters to the list to be passed to the workflow

  wf_event.addparametertolist(
     p_name          => 'EVENT_NAME',
     p_value         => l_event_name,
     p_parameterlist => l_parameter_list
     );
  wf_event.addparametertolist(
    p_name           => 'EVENT_KEY',
    p_value          => l_event_key,
    p_parameterlist  => l_parameter_list
    );
  wf_event.addparametertolist(
    p_name           => 'ECX_MAP_CODE',
    p_value          => l_map_code,
    p_parameterlist  => l_parameter_list
    );

  wf_event.addparametertolist(
    p_name           => 'ECX_PARAMETER1',
    p_value          => l_param_1,
    p_parameterlist  => l_parameter_list
    );

  wf_event.RAISE (
    p_event_name      => l_event_name,
    p_event_key       => l_event_key,
    p_parameters      => l_parameter_list);

  fnd_message.set_name('IGF','IGF_GR_COD_RAISE_EVENT');
  fnd_message.set_token('EVENT_KEY_VALUE',l_event_key);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  fnd_file.new_line(fnd_file.log,1);

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.submit_xml_event','raised event ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_gen_xml.submit_xml_event.exception','Exception:'||SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GR_GEN_XML.SUBMIT_XML_EVENT');
    igs_ge_msg_stack.add;
END submit_xml_event;

PROCEDURE main  (
                  errbuf                 OUT    NOCOPY  VARCHAR2,
                  retcode                OUT    NOCOPY  NUMBER,
                  p_award_year           IN             VARCHAR2,
                  p_source_entity_id     IN             VARCHAR2,
                  p_report_entity_id     IN             VARCHAR2,
                  p_rep_dummy            IN             VARCHAR2,
                  p_attend_entity_id     IN             VARCHAR2,
                  p_atd_dummy            IN             VARCHAR2,
                  p_base_id              IN             IGF_GR_RFMS_ALL.BASE_ID%TYPE,
                  p_per_dummy            IN             NUMBER,
                  p_persid_grp           IN             NUMBER
                )
IS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
ridas           08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
tsailaja		    15/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
***************************************************************/

  CURSOR  cur_cod_dtls  ( cp_document_id VARCHAR2) IS
    SELECT  document_id_txt
      FROM  IGF_GR_COD_DTLS
     WHERE  document_id_txt = cp_document_id;
  cod_dtls_rec cur_cod_dtls%ROWTYPE;

  CURSOR  cur_full_resp_code  ( cp_cal_type VARCHAR2, cp_sequence_number NUMBER, cp_source_entity_id VARCHAR2) IS
    SELECT  response_option_code
      FROM  IGF_GR_PELL_SETUP_ALL
     WHERE  ci_cal_type = cp_cal_type
      AND   ci_sequence_number = cp_sequence_number
      AND   rep_entity_id_txt = cp_source_entity_id;
  rec_full_resp_code  cur_full_resp_code%ROWTYPE;

  TYPE cur_person_id_type IS REF CURSOR;
  cur_per_grp cur_person_id_type;

  l_params_status       BOOLEAN;
  l_flag                BOOLEAN;
  lb_record_exist       BOOLEAN;
  lb_record_exist_stdnt BOOLEAN;
  lv_status             VARCHAR2(1);
  l_ci_cal_type         VARCHAR2(11);
  l_ci_sequence_number  NUMBER;
  ln_base_id            NUMBER;
  lv_person_number      hz_parties.party_number%TYPE;
  l_person_id           hz_parties.party_id%TYPE;
  l_list                VARCHAR2(32767);
  lv_group_type         igs_pe_persid_group_v.group_type%TYPE;

BEGIN

  --
  -- Steps
  -- 1. Print parameters
  -- 2. Validate parameters
  -- 3. Find PELL records to be processed
  -- 4. Validate Pell records
  -- 5. Insert valid pell records into IGF_GR_COD_DTLS, and disb records into IGF_AW_DB_COD_DTLS
  -- 6. Raise Business Event
  --
  igf_aw_gen.set_org_id(NULL);
  retcode := 0;
  l_ci_cal_type :=  LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
  l_ci_sequence_number  :=  NVL(TO_NUMBER(SUBSTR(p_award_year,11)),0);
  g_ver_num  := igf_aw_gen.get_ver_num(l_ci_cal_type,l_ci_sequence_number,'P');

  -- Step 1. Print parameters
  log_input_parameters(p_award_year, p_source_entity_id, p_report_entity_id, p_attend_entity_id, p_base_id, p_persid_grp);

  -- Step 2. Validate input parameters
  IF NOT validate_input_parameters(p_award_year, p_source_entity_id, p_report_entity_id, p_attend_entity_id, p_base_id, p_persid_grp) THEN
    RETURN;
  END IF;

  -- Get the full response code using Source Entity ID.
  OPEN cur_full_resp_code(l_ci_cal_type, l_ci_sequence_number, p_source_entity_id);
  FETCH cur_full_resp_code INTO rec_full_resp_code;
  IF cur_full_resp_code%NOTFOUND THEN
    -- print error message;
    fnd_message.set_name('IGF','IGF_GR_NO_RESP_OPT_SRC_ENTITY');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    CLOSE cur_full_resp_code;
    RETURN;
  ELSE
    g_full_resp_code := rec_full_resp_code.response_option_code;
    CLOSE cur_full_resp_code;
  END IF;

  -- Start of Step 3. Find all PELL records to be processed and process them.
  -- Processing when base_id is given.
  IF p_base_id IS NOT NULL THEN
    fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
    fnd_message.set_token('STDNT',igf_gr_gen.get_per_num(p_base_id));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    lb_record_exist := FALSE;
    FOR rec IN  cur_rfms (l_ci_cal_type, l_ci_sequence_number, p_report_entity_id, p_attend_entity_id, p_base_id)
    LOOP
      process_rfms_record(rec,p_source_entity_id);
      IF NOT lb_record_exist THEN
        lb_record_exist := TRUE;
      END IF;
    END LOOP;

    IF NOT lb_record_exist THEN
      fnd_message.set_name('IGF','IGF_GR_COD_NO_STDNT_RFMS_REC');
      fnd_message.set_token('PER_NUM',igf_gr_gen.get_per_num(p_base_id));
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      fnd_file.new_line(fnd_file.log, 1);
      RETURN;
    END IF;
  END IF;

  -- Processing when person id group is given.
  IF p_persid_grp IS NOT NULL THEN
    fnd_message.set_name('IGF','IGF_AW_PERSON_ID_GROUP');
    fnd_message.set_token('P_PER_GRP',get_grp_name(p_persid_grp));
    fnd_file.new_line(fnd_file.log, 1);
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    --Bug #5021084
    l_list := igf_ap_ss_pkg.get_pid(p_persid_grp,lv_status,lv_group_type);

    --Bug #5021084. Passing Group ID if the group type is STATIC.
    IF lv_group_type = 'STATIC' THEN
      OPEN cur_per_grp FOR ' SELECT PARTY_ID FROM HZ_PARTIES WHERE PARTY_ID IN (' || l_list  || ') ' USING p_persid_grp;
    ELSIF lv_group_type = 'DYNAMIC' THEN
      OPEN cur_per_grp FOR ' SELECT PARTY_ID FROM HZ_PARTIES WHERE PARTY_ID IN (' || l_list  || ') ';
    END IF;

    FETCH cur_per_grp INTO l_person_id;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.main.debug','Starting to process person group '||p_persid_grp);
    END IF;

    IF cur_per_grp%NOTFOUND THEN
      CLOSE cur_per_grp;
      fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.main.debug','No persons in group '||p_persid_grp);
      END IF;
    ELSE
      IF cur_per_grp%FOUND THEN -- Check if the person exists in FA.
        lb_record_exist := FALSE;
        LOOP
          ln_base_id := NULL;
          lv_person_number  := NULL;
          lv_person_number  := per_in_fa (l_person_id,l_ci_cal_type,l_ci_sequence_number,ln_base_id);
          IF lv_person_number IS NOT NULL THEN
            IF ln_base_id IS NOT NULL THEN
              fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
              fnd_message.set_token('STDNT',lv_person_number);
              fnd_file.put_line(fnd_file.log, fnd_message.get);

              lb_record_exist_stdnt := FALSE;
              FOR rec IN  cur_rfms (l_ci_cal_type, l_ci_sequence_number, p_report_entity_id, p_attend_entity_id, ln_base_id)
              LOOP
                process_rfms_record(rec,p_source_entity_id);
                IF NOT lb_record_exist_stdnt THEN
                  lb_record_exist_stdnt := TRUE;
                END IF;
                IF NOT lb_record_exist THEN
                  lb_record_exist := TRUE;
                END IF;
              END LOOP;

              IF NOT lb_record_exist_stdnt THEN
                fnd_message.set_name('IGF','IGF_GR_COD_NO_STDNT_RFMS_REC');
                fnd_message.set_token('PER_NUM',igf_gr_gen.get_per_num(p_base_id));
                fnd_file.put_line(fnd_file.log, fnd_message.get);
                fnd_file.new_line(fnd_file.log, 1);
              END IF;
            ELSE -- log a message and skip this person, base id not found
              fnd_message.set_name('IGF','IGF_GR_LI_PER_INVALID');
              fnd_message.set_token('PERSON_NUMBER',lv_person_number);
              fnd_message.set_token('AWD_YR',igf_gr_gen.get_alt_code(l_ci_cal_type,l_ci_sequence_number));
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.main.debug',igf_gr_gen.get_per_num_oss(l_person_id) || ' not in FA');
              END IF;
            END IF; -- base id not found
          ELSE
            fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
            fnd_file.put_line(fnd_file.log,RPAD(' ',5) ||fnd_message.get);
          END IF; -- person number not null

          FETCH cur_per_grp INTO l_person_id;
          EXIT WHEN cur_per_grp%NOTFOUND;
        END LOOP;
        CLOSE cur_per_grp;
        IF NOT lb_record_exist THEN
          fnd_message.set_name('IGF','IGF_GR_NO_RFMS_ORIG');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          fnd_file.new_line(fnd_file.log, 1);
        END IF;
      END IF; -- group found
    END IF;
  END IF;

  -- Processing when base_id and persond id groups are not given.
  IF p_base_id IS NULL AND p_persid_grp IS NULL THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.main.debug',' processing when base_id and person id groups are null');
    END IF;

    lb_record_exist := FALSE;
    FOR rec IN  cur_rfms (l_ci_cal_type, l_ci_sequence_number, p_report_entity_id, p_attend_entity_id, p_base_id)
    LOOP
      process_rfms_record(rec,p_source_entity_id);
      IF NOT lb_record_exist THEN
        lb_record_exist := TRUE;
      END IF;
    END LOOP;
    IF NOT lb_record_exist THEN
      fnd_message.set_name('IGF','IGF_GR_NO_RFMS_ORIG');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      fnd_file.new_line(fnd_file.log, 1);
    END IF;
  END IF;
  -- End of Step 3.

  -- Start of Step 6.
  OPEN  cur_cod_dtls(gv_document_id_txt);
  FETCH cur_cod_dtls INTO cod_dtls_rec;
  CLOSE cur_cod_dtls;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.main.debug',' gv_document_id_txt ' || gv_document_id_txt);
  END IF;

  IF cod_dtls_rec.document_id_txt IS NULL THEN
    fnd_message.set_name('IGF','IGF_GR_COD_NO_REC');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RETURN;
  ELSE
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.main.debug',' before submit event ');
    END IF;
    submit_xml_event (gv_document_id_txt);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.main.debug',' after submit event ');
    END IF;
  END IF;
  -- End of Step 6.

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    retcode := 2;
    errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    fnd_file.put_line(fnd_file.log,SQLERRM);
    igs_ge_msg_stack.conc_exception_hndl;
END main;

PROCEDURE store_xml ( itemtype   IN VARCHAR2,
                      itemkey    IN VARCHAR2,
                      actid      IN NUMBER,
                      funcmode   IN VARCHAR2,
                      resultout  OUT NOCOPY VARCHAR2)
IS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

  l_clob          CLOB;
  l_event         wf_event_t;
  ln_request_id   NUMBER;
  lv_rowid        ROWID;
  lv_document_id  VARCHAR2(30);

BEGIN

  --
  -- Steps
  -- 1. Read event data
  -- 2. Push xml into table
  -- 3. Launch Concurrent Request
  --

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.store_xml.debug',' before reading lob ');
  END IF;

  l_event     :=    wf_engine.getitemattrevent  ( itemtype,
                                                  itemkey,
                                                  'ECX_EVENT_MESSAGE'
                                                );
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.store_xml.debug',' after reading lob ');
  END IF;

  l_clob      :=    l_event.geteventdata;

  IF DBMS_LOB.GETLENGTH(l_clob) = 0 THEN
    resultout := 'EMPTY_CLOB';
  ELSE
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.store_xml.debug',' get doc id ');
    END IF;
    lv_document_id := NULL;
    lv_document_id := wf_engine.getitemattrtext ( itemtype,
                                                  itemkey,
                                                  'ECX_PARAMETER1'
                                                );
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.store_xml.debug',' get doc id = ' || lv_document_id);
    END IF;

    IF lv_document_id IS NULL THEN
      resultout := 'DOCUMENT_ID_NOT_FOUND';
    ELSE
      lv_rowid    := NULL;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.store_xml.debug',' insert into doc dtls ');
      END IF;

      igf_sl_cod_doc_dtls_pkg.insert_row(
                                      x_rowid             => lv_rowid,
                                      x_document_id_txt   => lv_document_id,
                                      x_outbound_doc      => l_clob,
                                      x_inbound_doc       => NULL,
                                      x_send_date         => NULL,
                                      x_ack_date          => NULL,
                                      x_doc_status        => 'R',
                                      x_doc_type          => 'PELL',
                                      x_full_resp_code    =>  NULL,
                                      x_mode              => 'R');
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.store_xml.debug',' before submitting req ');
      END IF;

      ln_request_id := apps.fnd_request.submit_request(
                                               'IGF','IGFGRJ14','','',FALSE,
                                               lv_document_id,CHR(0),
                                               '','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','');

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.store_xml.debug',' request id ' || ln_request_id);
      END IF;

      IF ln_request_id = 0 THEN
        resultout := 'CONCURRENT_REQUEST_FAILED';
      ELSE
        resultout := 'SUCCESS';
      END IF; -- request failed
    END IF; -- doc id is null
  END IF; -- lob length

EXCEPTION
  WHEN OTHERS THEN
    resultout := 'E';
    wf_core.context ( 'IGF_GR_GEN_XML',
                      'STORE_XML',
                      itemtype,
                      itemkey,
                      to_char(actid),
                      funcmode
                    );
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.store_xml.debug','sqlerrm ' || SQLERRM);
    END IF;
END store_xml;

PROCEDURE update_status(p_document_id_txt VARCHAR2)
IS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

  CURSOR  cur_cod_orig  ( cp_document_id_txt VARCHAR2)  IS
    SELECT  coddtls.origination_id
      FROM  IGF_GR_COD_DTLS coddtls
     WHERE  coddtls.document_id_txt = cp_document_id_txt;

  CURSOR  cur_cod_disb  ( cp_document_id_txt VARCHAR2)  IS
    SELECT  disb.award_id, disb.disb_num, disb.disb_seq_num
      FROM  IGF_AW_DB_COD_DTLS disb
     WHERE  disb.document_id_txt = cp_document_id_txt;

  CURSOR  cur_rfms_orig ( cp_origination_id VARCHAR2) IS
    SELECT  rfms.*
      FROM  IGF_GR_RFMS rfms
     WHERE  rfms.origination_id = cp_origination_id;

  CURSOR  cur_sys_disb  ( cp_award_id NUMBER, cp_disb_num NUMBER, cp_disb_seq NUMBER) IS
    SELECT  disb.rowid row_id,disb.*
      FROM  IGF_AW_DB_CHG_DTLS disb
     WHERE  disb.award_id = cp_award_id
      AND   disb.disb_num = cp_disb_num
      AND   disb.disb_seq_num = cp_disb_seq;

  l_pell_amt          igf_gr_rfms.pell_amount%TYPE;
  l_ft_pell_amt       igf_gr_rfms_all.ft_pell_amount%TYPE;
  l_return_status     VARCHAR2(1);
  l_return_mesg_text  VARCHAR2(2000);

BEGIN

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.update_status.debug','First doc id ' || p_document_id_txt);
  END IF;

  FOR cod_rec IN cur_cod_orig(p_document_id_txt)
  LOOP
    FOR rfms_rec IN cur_rfms_orig (cod_rec.origination_id)
    LOOP
      IF NVL(rfms_rec.orig_action_code,'*') = 'R' THEN
        rfms_rec.orig_action_code := 'S';
      END IF;

      igf_gr_rfms_pkg.update_row  ( x_rowid                   => rfms_rec.row_id,
                                    x_origination_id          => rfms_rec.origination_id,
                                    x_ci_cal_type             => rfms_rec.ci_cal_type,
                                    x_ci_sequence_number      => rfms_rec.ci_sequence_number,
                                    x_base_id                 => rfms_rec.base_id,
                                    x_award_id                => rfms_rec.award_id ,
                                    x_rfmb_id                 => rfms_rec.rfmb_id ,
                                    x_sys_orig_ssn            => rfms_rec.sys_orig_ssn ,
                                    x_sys_orig_name_cd        => rfms_rec.sys_orig_name_cd ,
                                    x_transaction_num         => rfms_rec.transaction_num ,
                                    x_efc                     => rfms_rec.efc,
                                    x_ver_status_code         => rfms_rec.ver_status_code ,
                                    x_secondary_efc           => rfms_rec.secondary_efc ,
                                    x_secondary_efc_cd        => rfms_rec.secondary_efc_cd ,
                                    x_pell_amount             => rfms_rec.pell_amount ,
                                    x_pell_profile            => rfms_rec.pell_profile ,
                                    x_enrollment_status       => rfms_rec.enrollment_status ,
                                    x_enrollment_dt           => rfms_rec.enrollment_dt ,
                                    x_coa_amount              => rfms_rec.coa_amount ,
                                    x_academic_calendar       => rfms_rec.academic_calendar ,
                                    x_payment_method          => rfms_rec.payment_method ,
                                    x_total_pymt_prds         => rfms_rec.total_pymt_prds ,
                                    x_incrcd_fed_pell_rcp_cd  => rfms_rec.incrcd_fed_pell_rcp_cd ,
                                    x_attending_campus_id     => rfms_rec.attending_campus_id ,
                                    x_est_disb_dt1            => rfms_rec.est_disb_dt1 ,
                                    x_orig_action_code        => rfms_rec.orig_action_code ,
                                    x_orig_status_dt          => rfms_rec.orig_status_dt ,
                                    x_orig_ed_use_flags       => rfms_rec.orig_ed_use_flags ,
                                    x_ft_pell_amount          => rfms_rec.ft_pell_amount ,
                                    x_prev_accpt_efc          => rfms_rec.prev_accpt_efc ,
                                    x_prev_accpt_tran_no      => rfms_rec.prev_accpt_tran_no    ,
                                    x_prev_accpt_sec_efc_cd   => rfms_rec.prev_accpt_sec_efc_cd ,
                                    x_prev_accpt_coa          => rfms_rec.prev_accpt_coa         ,
                                    x_orig_reject_code        => rfms_rec.orig_reject_code       ,
                                    x_wk_inst_time_calc_pymt  => rfms_rec.wk_inst_time_calc_pymt ,
                                    x_wk_int_time_prg_def_yr  => rfms_rec.wk_int_time_prg_def_yr ,
                                    x_cr_clk_hrs_prds_sch_yr  => rfms_rec.cr_clk_hrs_prds_sch_yr ,
                                    x_cr_clk_hrs_acad_yr      => rfms_rec.cr_clk_hrs_acad_yr     ,
                                    x_inst_cross_ref_cd       => rfms_rec.inst_cross_ref_cd      ,
                                    x_low_tution_fee          => rfms_rec.low_tution_fee         ,
                                    x_rec_source              => rfms_rec.rec_source             ,
                                    x_pending_amount			    => rfms_rec.pending_amount         ,
                                    x_mode                    => 'R'                             ,
                                    x_birth_dt                => rfms_rec.birth_dt               ,
                                    x_last_name               => rfms_rec.last_name              ,
                                    x_first_name              => rfms_rec.first_name             ,
                                    x_middle_name             => rfms_rec.middle_name            ,
                                    x_current_ssn             => rfms_rec.current_ssn            ,
                                    x_legacy_record_flag      => rfms_rec.legacy_record_flag     ,
                                    x_reporting_pell_cd       => rfms_rec.rep_pell_id            ,
                                    x_rep_entity_id_txt       => rfms_rec.rep_entity_id_txt      ,
                                    x_atd_entity_id_txt       => rfms_rec.atd_entity_id_txt      ,
                                    x_note_message            => rfms_rec.note_message           ,
                                    x_full_resp_code          => rfms_rec.full_resp_code         ,
                                    x_document_id_txt         => p_document_id_txt
                                  );
    END LOOP;
  END LOOP;

  FOR cod_rec IN cur_cod_disb(p_document_id_txt)
  LOOP
    FOR sys_rec IN cur_sys_disb(cod_rec.award_id,cod_rec.disb_num,cod_rec.disb_seq_num)
    LOOP
      sys_rec.disb_status      := 'S';
      sys_rec.disb_status_date := TRUNC(SYSDATE);

      igf_aw_db_chg_dtls_pkg.update_row ( x_rowid                => sys_rec.row_id,
                                          x_award_id             => sys_rec.award_id,
                                          x_disb_num             => sys_rec.disb_num,
                                          x_disb_seq_num         => sys_rec.disb_seq_num,
                                          x_disb_accepted_amt    => sys_rec.disb_accepted_amt,
                                          x_orig_fee_amt         => sys_rec.orig_fee_amt,
                                          x_disb_net_amt         => sys_rec.disb_net_amt,
                                          x_disb_date            => sys_rec.disb_date,
                                          x_disb_activity        => sys_rec.disb_activity,
                                          x_disb_status          => sys_rec.disb_status,
                                          x_disb_status_date     => sys_rec.disb_status_date,
                                          x_disb_rel_flag        => sys_rec.disb_rel_flag,
                                          x_first_disb_flag      => sys_rec.first_disb_flag,
                                          x_interest_rebate_amt  => sys_rec.interest_rebate_amt,
                                          x_disb_conf_flag       => sys_rec.disb_conf_flag,
                                          x_pymnt_prd_start_date => sys_rec.pymnt_prd_start_date,
                                          x_note_message         => sys_rec.note_message,
                                          x_batch_id_txt         => sys_rec.batch_id_txt,
                                          x_ack_date             => sys_rec.ack_date,
                                          x_booking_id_txt       => sys_rec.booking_id_txt,
                                          x_booking_date         => sys_rec.booking_date,
                                          x_mode                 => 'R'
                                          );
    END LOOP;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_gen_xml.update_status.exception','Exception:'||SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GR_GEN_XML.UPDATE_STATUS');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END update_status;

PROCEDURE print_xml ( errbuf        OUT NOCOPY VARCHAR2,
                      retcode       OUT NOCOPY NUMBER,
                      p_document_id VARCHAR2)
IS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
tsailaja		  15/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
***************************************************************/

  CURSOR  c_get_parameters  IS
    SELECT  meaning, lookup_code
      FROM  IGF_LOOKUPS_VIEW
     WHERE  lookup_type = 'IGF_GE_PARAMETERS'
      AND   lookup_code IN ('PARAMETER_PASS','DOCUMENT_ID');
  parameter_rec c_get_parameters%ROWTYPE;

  lv_parameter_pass       VARCHAR2(80);
  lv_document_id          VARCHAR2(80);
  lc_newxmldoc            CLOB;
  lv_rowid                ROWID;

BEGIN
    --
    -- Steps
    --
    -- 1. Print parameters
    -- 2. Validate parameters
    -- 3. Edit CLOB for additional tags
    -- 4. Update DOC_DTLS table
    -- 5. Update LOR_LOC table, DISB table for Status
    -- 5. Print CLOB on the output file
    --
  igf_aw_gen.set_org_id(NULL);
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.print_xml.debug','p doc id ' || p_document_id);
  END IF;

  OPEN c_get_parameters;
  LOOP
    FETCH c_get_parameters INTO  parameter_rec;
    EXIT WHEN c_get_parameters%NOTFOUND;

    IF parameter_rec.lookup_code ='PARAMETER_PASS' THEN
      lv_parameter_pass   := TRIM(parameter_rec.meaning);
    ELSIF parameter_rec.lookup_code ='DOCUMENT_ID' THEN
      lv_document_id      := TRIM(parameter_rec.meaning);
    END IF;
  END LOOP;
  CLOSE c_get_parameters;

  fnd_file.new_line(fnd_file.log,1);
  fnd_file.put_line(fnd_file.log, lv_parameter_pass); --------------Parameters Passed--------------
  fnd_file.new_line(fnd_file.log,1);

  fnd_file.put_line(fnd_file.log, RPAD(lv_document_id,40) || ' : '|| p_document_id);

  fnd_file.new_line(fnd_file.log,1);
  fnd_file.put_line(fnd_file.log, '--------------------------------------------------------');
  fnd_file.new_line(fnd_file.log,1);

  igf_sl_dl_gen_xml.edit_clob(p_document_id,lc_newxmldoc,lv_rowid);

  -- update the modified clob in DOC_DTLS table
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.print_xml.debug','before updating status');
  END IF;
  igf_sl_cod_doc_dtls_pkg.update_row  ( x_rowid             => lv_rowid,
                                        x_document_id_txt   => p_document_id,
                                        x_outbound_doc      => lc_newxmldoc,
                                        x_inbound_doc       => NULL,
                                        x_send_date         => TRUNC(SYSDATE),
                                        x_ack_date          => NULL,
                                        x_doc_status        => 'S',
                                        x_doc_type          => 'PELL',
                                        x_full_resp_code    =>  NULL,
                                        x_mode              => 'R');
  --
  -- update IGF_GR_RFMS_ALL.ORIG_ACTION_CODE to sent
  -- update IGF_AW_DB_CHG_DTLS.DISB_STATUS to sent
  update_status(p_document_id);

  -- print out xml outfile
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.print_xml.debug','before calling print_out_xml method');
  END IF;
  igf_sl_dl_gen_xml.print_out_xml(lc_newxmldoc);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    retcode := 2;
    errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    fnd_file.put_line(fnd_file.log,SQLERRM);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_gen_xml.print_xml.debug','OTHERS exception raised in print_xml: ' || SQLERRM);
    END IF;
    igs_ge_msg_stack.conc_exception_hndl;
END print_xml;

END IGF_GR_GEN_XML;

/
