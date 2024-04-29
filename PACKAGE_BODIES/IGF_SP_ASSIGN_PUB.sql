--------------------------------------------------------
--  DDL for Package Body IGF_SP_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SP_ASSIGN_PUB" AS
/* $Header: IGFSP05B.pls 120.1 2006/05/15 06:27:00 svuppala noship $ */

/****************************************************************************
Created By:         Vinay Chappidi
Date Created By:    19-Feb-2003
Purpose:            Public API for creating Sponsor-Student relation ship
Known limitations,enhancements,remarks:

Change History
Who         When           What
svuppala    12-May-2006     Bug 5217319 Added call to format amount by rounding off to currency precision
                           in the igf_sp_stdnt_rel_pkg.insert_row call in create_stdnt_spnsr_rel procedure.
vvutukur    20-Jul-2003    Enh#3038511.FICR106 Build. Modified procedure create_stdnt_spnsr_rel.
pathipat    24-Apr-2003    Enh 2831569 - Commercial Receivables build
                           Modified create_stdnt_spnsr_rel() - added call to chk_manage_account()
******************************************************************************/


  g_pkg_name CONSTANT VARCHAR2(30) := 'Igf_Sp_Assign_Pub';
  g_c_temp VARCHAR2(1);

  FUNCTION validate_prsn(p_n_person_id IN hz_parties.party_ID%TYPE) RETURN BOOLEAN
  AS
  /****************************************************************************
  Created By:         Vinay Chappidi
  Date Created By:    19-Feb-2003
  Purpose:            Local Function to validate if the person exists in the system
  Known limitations,enhancements,remarks:

  Change History

  Who         When           What
  ******************************************************************************/
    CURSOR c_check_valid_person (cp_n_person_id igs_pe_person_base_v.person_id%TYPE)
    IS
    SELECT 'x'
    FROM igs_pe_person_base_v
    WHERE person_id = cp_n_person_id;
  BEGIN
    OPEN c_check_valid_person(p_n_person_id);
    FETCH c_check_valid_person INTO g_c_temp;
    IF c_check_valid_person%FOUND THEN
      CLOSE c_check_valid_person;
      RETURN TRUE;
    ELSE
      CLOSE c_check_valid_person;
      RETURN FALSE;
    END IF;
  END validate_prsn;

  PROCEDURE validate_api_prsn_id(p_c_sys_prsn_id_typ IN igs_pe_person_id_typ.s_person_id_type%TYPE,
                                 p_c_usr_alt_prsn_id_typ IN igs_pe_person_id_typ.person_id_type%TYPE,
                                 p_c_api_prsn_id IN igs_pe_alt_pers_id.api_person_id%TYPE,
                                 p_b_ret_status OUT NOCOPY BOOLEAN,
                                 p_n_person_id OUT NOCOPY hz_parties.party_id%TYPE)
  AS
  /****************************************************************************
  Created By:         Vinay Chappidi
  Date Created By:    19-Feb-2003
  Purpose:            Local procedure for identifying a unique person depending on the
                      the alternate person details provided to this API
  Known limitations,enhancements,remarks:

  Change History
  Who         When           What
  ******************************************************************************/

    CURSOR cur_get_person_id(cp_c_sys_prsn_id_typ igs_pe_person_id_typ.s_person_id_type%TYPE,
                             cp_c_usr_alt_prs_id_type igs_pe_person_id_typ.person_id_type%TYPE,
                             cp_c_api_person_id igs_pe_alt_pers_id.api_person_id%TYPE)
    IS
    SELECT api.pe_person_id
    FROM igs_pe_person_id_typ pit,
         igs_pe_alt_pers_id api
    WHERE api.person_id_type = pit.person_id_type AND
          api.person_id_type = cp_c_usr_alt_prs_id_type AND
          api.api_person_id = cp_c_api_person_id AND
          pit.s_person_id_type = cp_c_sys_prsn_id_typ AND
          SYSDATE BETWEEN api.start_dt AND NVL(api.end_dt, SYSDATE);

    l_n_person_id hz_parties.party_id%TYPE;
  BEGIN
    -- check if for the combination of Alternate-Person Id Type, API Person ID if there exists a unique person
    -- when no person is identified or when there are more than one person identified from above cursor then
    -- set the return status OUT variable to FALSE and return.
    OPEN cur_get_person_id (p_c_sys_prsn_id_typ,p_c_usr_alt_prsn_id_typ,p_c_api_prsn_id);
    FETCH cur_get_person_id INTO l_n_person_id;
    IF cur_get_person_id%NOTFOUND THEN
      p_b_ret_status := FALSE;
      p_n_person_id := NULL;
    ELSE
      -- Check if there are any duplicate persons with the same value
      -- if the next fetch is successful then the Person Details are invalid.
      FETCH cur_get_person_id INTO l_n_person_id;
      IF cur_get_person_id%NOTFOUND THEN
        p_b_ret_status := TRUE;
        p_n_person_id := l_n_person_id;
      ELSE
        p_b_ret_status := FALSE;
        p_n_person_id := NULL;
      END IF;
    END IF;
    CLOSE cur_get_person_id;
  END validate_api_prsn_id;


  FUNCTION validate_spnsr_cd(p_c_sponsor_code IN igf_aw_fund_cat.fund_code%TYPE) RETURN BOOLEAN
  AS
  /****************************************************************************
  Created By:         Vinay Chappidi
  Date Created By:    19-Feb-2003
  Purpose:            Local Function for validating if the Sponsor Code is active in the system
  Known limitations,enhancements,remarks:

  Change History
  Who         When           What
  ******************************************************************************/
    CURSOR c_check_valid_spnsr_cd(cp_c_fund_code igf_aw_fund_cat.fund_code%TYPE,
                                  cp_c_sys_fund_type igf_aw_fund_cat.sys_fund_type%TYPE,
                                  cp_c_status igf_aw_fund_cat.active%TYPE)
    IS
    SELECT 'x'
    FROM igf_aw_fund_cat c,
         igf_aw_fund_mast m
    WHERE c.fund_code = m.fund_code AND
          c.fund_code = cp_c_fund_code AND
          c.sys_fund_type = cp_c_sys_fund_type AND
          c.active = cp_c_status;
  BEGIN
    -- validate the sponsor code parameter is a valid
    OPEN c_check_valid_spnsr_cd(p_c_sponsor_code,'SPONSOR','Y');
    FETCH c_check_valid_spnsr_cd INTO g_c_temp;
    IF c_check_valid_spnsr_cd%NOTFOUND THEN
      CLOSE c_check_valid_spnsr_cd;
      RETURN FALSE;
    ELSE
      CLOSE c_check_valid_spnsr_cd;
      RETURN TRUE;
    END IF;
  END validate_spnsr_cd;


  FUNCTION validate_award_cal_inst(p_c_awd_ci_cal_type igs_ca_inst.cal_type%TYPE,
                                   p_n_awd_ci_sequence_number igs_ca_inst.sequence_number%TYPE) RETURN BOOLEAN
  AS
  /****************************************************************************
  Created By:         Vinay Chappidi
  Date Created By:    19-Feb-2003
  Purpose:            Local function for validating the Award Calendar Instance parameters
  Known limitations,enhancements,remarks:

  Change History
  Who         When           What
  ******************************************************************************/

    CURSOR cur_check_ci_status(cp_c_cal_type igs_ca_inst.cal_type%TYPE,
                               cp_n_sequence_number igs_ca_inst.sequence_number%TYPE,
                               cp_c_cal_status igs_ca_stat.cal_status%TYPE)
    IS
    SELECT 'x'
    FROM igs_ca_inst i,
         igs_ca_stat s,
         igf_ap_batch_aw_map b
    WHERE i.cal_status = s.cal_status AND
          i.cal_type = b.ci_cal_type AND
          i.sequence_number = b.ci_sequence_number AND
          i.cal_type = cp_c_cal_type AND
          i.sequence_number = cp_n_sequence_number AND
          s.s_cal_status = cp_c_cal_status;
  BEGIN
    OPEN cur_check_ci_status(p_c_awd_ci_cal_type,p_n_awd_ci_sequence_number,'ACTIVE');
    FETCH cur_check_ci_status INTO g_c_temp;
    IF cur_check_ci_status%NOTFOUND THEN
      CLOSE cur_check_ci_status;
      RETURN FALSE;
    ELSE
      CLOSE cur_check_ci_status;
      RETURN TRUE;
    END IF;
  END validate_award_cal_inst;

  FUNCTION validate_load_cal_inst(p_c_ld_ci_cal_type igs_ca_inst.cal_type%TYPE,
                                  p_n_ld_ci_sequence_number igs_ca_inst.sequence_number%TYPE) RETURN BOOLEAN
  AS
  /****************************************************************************
  Created By:         Vinay Chappidi
  Date Created By:    19-Feb-2003
  Purpose:            Local function for validating the Term Calendar Instance parameters
  Known limitations,enhancements,remarks:

  Change History
  Who         When           What
  ******************************************************************************/
    CURSOR cur_check_ci_status (cp_c_cal_type igs_ca_inst.cal_type%TYPE,
                                cp_n_sequence_number igs_ca_inst.sequence_number%TYPE,
                                cp_c_cal_status igs_ca_stat.cal_status%TYPE,
                                cp_c_awd_cal_cat igs_ca_type.s_cal_cat%TYPE,
                                cp_c_ld_cal_cat igs_ca_type.s_cal_cat%TYPE)
    IS
    SELECT 'x'
    FROM igs_ca_inst aw,
         igs_ca_inst ld,
         igs_ca_type ld_t,
         igs_ca_type aw_t,
         igs_ca_inst_rel rel,
         igs_ca_stat status
    WHERE rel.sup_cal_type=aw.cal_type AND
          rel.sup_ci_sequence_number=aw.sequence_number AND
          rel.sub_cal_type=ld.cal_type AND
          rel.sub_ci_sequence_number=ld.sequence_number AND
          aw.cal_type = aw_t.cal_type AND
          aw_t.s_cal_cat= cp_c_awd_cal_cat AND
          ld.cal_type = ld_t.cal_type AND
          ld_t.s_cal_cat= cp_c_ld_cal_cat AND
          ld.cal_status = status.cal_status AND
          status.s_cal_status= cp_c_cal_status AND
          ld.cal_type = cp_c_cal_type AND
          ld.sequence_number = cp_n_sequence_number;

  BEGIN
    OPEN cur_check_ci_status(p_c_ld_ci_cal_type,p_n_ld_ci_sequence_number,'ACTIVE','AWARD','LOAD');
    FETCH cur_check_ci_status INTO g_c_temp;
    IF cur_check_ci_status%NOTFOUND THEN
      CLOSE cur_check_ci_status;
      RETURN FALSE;
    ELSE
      CLOSE cur_check_ci_status;
      RETURN TRUE;
    END IF;
  END validate_load_cal_inst;

  PROCEDURE check_spnsr_awd_rel(p_c_fund_code IN igf_aw_fund_mast.fund_code%TYPE,
                                p_c_aw_cal_type IN igs_ca_inst.cal_type%TYPE,
                                p_n_aw_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                                p_c_ld_cal_type IN igs_ca_inst.cal_type%TYPE,
                                p_n_ld_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                                p_b_return_status OUT NOCOPY BOOLEAN,
                                p_n_fund_id OUT NOCOPY igf_aw_fund_mast.fund_id%TYPE)
  AS
  /****************************************************************************
  Created By:         Vinay Chappidi
  Date Created By:    19-Feb-2003
  Purpose:            Local procedure for checking if the Sponsor, Award Calendar and Load Calendar
                      combination exists in the system.
  Known limitations,enhancements,remarks:

  Change History
  Who         When           What
  ******************************************************************************/
    CURSOR c_check_spn_awd(cp_c_fund_code igf_aw_fund_mast.fund_code%TYPE,
                           cp_c_fund_status igf_aw_fund_mast.discontinue_fund%TYPE,
                           cp_c_aw_cal_type igf_aw_fund_mast.ci_cal_type%TYPE,
                           cp_n_aw_sequence_number igf_aw_fund_mast.ci_sequence_number%TYPE,
                           cp_c_ld_cal_type igf_aw_fund_tp.tp_cal_type%TYPE,
                           cp_n_ld_sequence_number igf_aw_fund_tp.tp_sequence_number%TYPE)
    IS
    SELECT m.fund_id
    FROM igf_aw_fund_mast m,
         igf_aw_fund_tp t
    WHERE m.fund_id = t.fund_id AND
          m.fund_code = cp_c_fund_code AND
          m.ci_cal_type = cp_c_aw_cal_type AND
          m.ci_sequence_number = cp_n_aw_sequence_number AND
          m.discontinue_fund = cp_c_fund_status AND
          t.tp_cal_type = cp_c_ld_cal_type AND
          t.tp_sequence_number = cp_n_ld_sequence_number;

    l_n_fund_id igf_aw_fund_mast.fund_id%TYPE;
  BEGIN
    -- Check if the Award Calendar Insatnce, Load Calendar Instance and the Sponsor Details are setup in the system
    -- Return False when there is no relation and TRUE when there exists a relation
    OPEN c_check_spn_awd(p_c_fund_code,'N',p_c_aw_cal_type,p_n_aw_sequence_number,p_c_ld_cal_type,p_n_ld_sequence_number);
    FETCH c_check_spn_awd INTO l_n_fund_id;
    IF c_check_spn_awd%NOTFOUND THEN
       p_b_return_status := FALSE;
       p_n_fund_id := NULL;
    ELSE
       p_b_return_status := TRUE;
       p_n_fund_id := l_n_fund_id;
    END IF;
    CLOSE c_check_spn_awd;
  END check_spnsr_awd_rel;

  PROCEDURE check_create_fa_rec(p_n_person_id hz_parties.party_id%TYPE,
                                p_c_awd_ci_cal_type igs_ca_inst.cal_type%TYPE,
                                p_n_awd_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
                                p_b_ret_status OUT NOCOPY BOOLEAN,
                                p_n_base_id OUT NOCOPY NUMBER)
  AS
  /****************************************************************************
  Created By:         Vinay Chappidi
  Date Created By:    19-Feb-2003
  Purpose:            Local procedure for checking if there exists FA Base record for the
                      Award Calendar Instance, Person combination. If a there is no record
                      then a new FA base record is created by invoking existing function
  Known limitations,enhancements,remarks:

  Change History
  Who         When           What
  ******************************************************************************/
    l_b_ret_status BOOLEAN := FALSE;
    l_n_base_id igf_ap_fa_base_rec_all.base_id%TYPE;
    l_c_message_text fnd_new_messages.message_text%TYPE;

  BEGIN
    -- Check if FA base record is already existing, if yes then assign the Base ID to the OUT variable and return
    -- from this procedure. when a FA base record is not found then create using the existing function
    -- If the function returns FALSE without value for base_id then assign NULL to the base_id OUT variable,
    -- if the function returns TRUE then assign this base id to the OUT variable and return


    -- OUT variable message text will be passed only when the person is already having a FA Base Record
    -- since we are upfront checking for FA base record existance, messges text OUT variable will be NULL
    -- and hence no need to add to the message list.
    l_b_ret_status := igf_sp_create_base_rec.create_fa_base_record(p_cal_type => p_c_awd_ci_cal_type,
                                                                   p_sequence_number => p_n_awd_ci_sequence_number,
                                                                   p_person_id => p_n_person_id,
                                                                   p_base_id => l_n_base_id,
                                                                   p_message => l_c_message_text);
    IF (l_b_ret_status OR (l_b_ret_status=FALSE AND l_n_base_id IS NOT NULL))THEN
      p_n_base_id := l_n_base_id;
      p_b_ret_status := TRUE;
    ELSE
      p_n_base_id := NULL;
      p_b_ret_status := FALSE;
    END IF;
  END check_create_fa_rec;

  FUNCTION  check_spnsr_stdnt_rel(p_c_fund_id igf_aw_fund_mast.fund_id%TYPE,
                                  p_n_base_id igf_ap_fa_base_rec.base_id%TYPE,
                                  p_c_ld_cal_type igs_ca_inst.cal_type%TYPE,
                                  p_n_ld_ci_sequence_number igs_ca_inst.sequence_number%TYPE) RETURN BOOLEAN
  AS
  /****************************************************************************
  Created By:         Vinay Chappidi
  Date Created By:    19-Feb-2003
  Purpose:            Local function for checking if there already exists a Sponsor-Student relationship.
  Known limitations,enhancements,remarks:

  Change History
  Who         When           What
  ******************************************************************************/
    CURSOR c_check_stdnt_spnsr_rel(cp_n_fund_id igf_sp_stdnt_rel.fund_id%TYPE,
                                   cp_n_base_id igf_sp_stdnt_rel.base_id%TYPE,
                                   cp_c_ld_cal_type igf_sp_stdnt_rel.ld_cal_type%TYPE,
                                   cp_n_ld_seq_number igf_sp_stdnt_rel.ld_sequence_number%TYPE)
    IS
    SELECT 'x'
    FROM igf_sp_stdnt_rel
    WHERE fund_id = cp_n_fund_id AND
          base_id = cp_n_base_id AND
          ld_cal_type = cp_c_ld_cal_type AND
          ld_sequence_number = cp_n_ld_seq_number;
  BEGIN
    -- check if the Sponsor-Student relation is already exists.
    -- if the relation is already existing then return TRUE else return FALSE
    OPEN c_check_stdnt_spnsr_rel(p_c_fund_id,p_n_base_id,p_c_ld_cal_type,p_n_ld_ci_sequence_number);
    FETCH c_check_stdnt_spnsr_rel INTO g_c_temp;
    IF c_check_stdnt_spnsr_rel%NOTFOUND THEN
      CLOSE c_check_stdnt_spnsr_rel;
      RETURN FALSE;
    ELSE
      CLOSE c_check_stdnt_spnsr_rel;
      RETURN TRUE;
    END IF;
  END check_spnsr_stdnt_rel;

  PROCEDURE create_stdnt_spnsr_rel(p_api_version   IN NUMBER,
                                   p_init_msg_list IN VARCHAR2,
                                   p_commit        IN VARCHAR2,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_person_id     IN NUMBER,
                                   p_alt_person_id_type IN VARCHAR2,
                                   p_api_person_id IN VARCHAR2,
                                   p_sponsor_code IN VARCHAR2,
                                   p_awd_ci_cal_type IN VARCHAR2,
                                   p_awd_ci_sequence_number IN NUMBER,
                                   p_ld_cal_type IN VARCHAR2,
                                   p_ld_ci_sequence_number IN NUMBER,
                                   p_amount IN NUMBER)
  AS
  /****************************************************************************
  Created By:         Vinay Chappidi
  Date Created By:    19-Feb-2003
  Purpose:            This procedure is the main api for creating a Sponsor-Student relationship.
                      For validating all parameters, local functions/ procedures are invoked.
  Known limitations,enhancements,remarks:

  Change History

  Who         When           What
  svuppala    12-May-2006     Bug 5217319 Added call to format amount by rounding off to currency precision
                             in the igf_sp_stdnt_rel_pkg.insert_row call
  vvutukur    20-Jul-2003    Enh#3038511.FICR106 Build. Added call to generic procedure
                             igs_fi_crdapi_util.get_award_year_status to validate Award Year Status.
  pathipat    24-Apr-2003    Enh 2831569 - Commercial Receivables build
                             Added check for manage_accounts - call to chk_manage_account()
  ******************************************************************************/
    l_b_error BOOLEAN :=FALSE;
    -- variable for capturing the return status from a procedure
    l_b_ret_status BOOLEAN := FALSE;
    l_rowid VARCHAR2(25);

    l_api_name               CONSTANT    VARCHAR2(30) := 'Create_Stdnt_Spnsr_Rel';
    l_api_version            CONSTANT    NUMBER       := 1.0;

    l_n_person_id hz_parties.party_id%TYPE;
    l_n_fund_id igf_aw_fund_mast.fund_id%TYPE;
    l_c_sys_alt_prs_id_typ igs_pe_person_id_typ.s_person_id_type%TYPE;
    l_n_base_id igf_ap_fa_base_rec_all.base_id%TYPE;
    l_n_spr_stdnt_id igf_sp_stdnt_rel.spnsr_stdnt_id%TYPE;

    l_c_manage_acc      igs_fi_control_all.manage_accounts%TYPE  := NULL;
    l_c_message_name    fnd_new_messages.message_name%TYPE       := NULL;

    l_v_awd_yr_status_cd     igf_ap_batch_aw_map.award_year_status_code%TYPE;

  BEGIN

    -- Create a savepoint
    SAVEPOINT create_stdnt_spnsr_rel_pub;

    -- Check for the Compatible API call if the versions of the API and the version passed are
    -- different then raise the unexpected error message
    IF NOT fnd_api.compatible_api_call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- If the calling program has passed the parameter for initializing the message list
    -- then call the Initialize program of the FND_MSG_PUB package
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Set the return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Obtain the value of manage_accounts in the System Options form
    -- If it is null, then raise error. For normal processing, the value should
    -- be 'OTHER' or 'STUDENT_FINANCE'
    igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_c_manage_acc,
                                                 p_v_message_name => l_c_message_name
                                               );
    IF (l_c_manage_acc IS NULL) THEN
       l_b_error := TRUE;
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('IGS',l_c_message_name);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
       END IF;
    END IF;


    IF (p_person_id IS NOT NULL AND p_api_person_id IS NOT NULL) THEN
      l_b_error := TRUE;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS','IGS_FI_PRSID_ALTID_INVALID');
        fnd_message.set_token('PERSON_ID',p_person_id);
        fnd_message.set_token('API_PERS_ID',p_api_person_id);
        fnd_msg_pub.add;
      END IF;
    END IF;

    -- check if the user has provided either person_id or alternate person details
    IF (p_person_id IS NULL AND p_api_person_id IS NULL) THEN
      l_b_error := TRUE;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS','IGS_FI_PRSID_OR_ALTID');
        fnd_msg_pub.add;
      END IF;
    END IF;

    --validate person id parameter if it is not null
    IF p_person_id IS NOT NULL THEN
      l_b_ret_status := validate_prsn(p_person_id);
      IF NOT l_b_ret_status THEN
        l_b_error := TRUE;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('IGS','IGS_FI_INVALID_PRS_ID');
          fnd_message.set_token('PERSON_ID',p_person_id);
          fnd_msg_pub.add;
        END IF;
      END IF;
    END IF;

    -- When user inputs User Defined Person ID Type then validate User-Defined Person ID Type if it exists
    -- and setup as Unique in the system
    -- Since User-Defined Alternate ID should be passed when the user inputs API Person ID, validate User-Defined
    -- Alternate Person Id only when API Person ID is not null.
    IF p_api_person_id IS NOT NULL THEN
      igs_fi_gen_006.validate_prsn_id_typ(p_c_usr_alt_prs_id_typ => p_alt_person_id_type,
                                          p_c_unique => 'Y',
                                          p_b_status => l_b_ret_status,
                                          p_c_sys_alt_prs_id_typ => l_c_sys_alt_prs_id_typ);

      IF NOT l_b_ret_status THEN
        l_b_error := TRUE;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('IGS','IGS_FI_INVALID_ALT_PERS_ID_TYP');
          fnd_message.set_token('API_PERS_ID_TYPE',p_alt_person_id_type);
          fnd_msg_pub.add;
        END IF;
      END IF;
    END IF;

    -- validate alternate person id parameter and determine person id
    IF (p_api_person_id IS NOT NULL AND p_alt_person_id_type IS NOT NULL) THEN
      validate_api_prsn_id(p_c_sys_prsn_id_typ => l_c_sys_alt_prs_id_typ,
                           p_c_usr_alt_prsn_id_typ => p_alt_person_id_type,
                           p_c_api_prsn_id => p_api_person_id,
                           p_b_ret_status => l_b_ret_status,
                           p_n_person_id => l_n_person_id);


      IF NOT l_b_ret_status THEN
        l_b_error := TRUE;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('IGS','IGS_FI_INVALID_ALT_PERS_ID');
          fnd_message.set_token('API_PERS_ID',p_api_person_id);
          fnd_msg_pub.add;
        END IF;
      END IF;
    END IF;

    -- validate sponsor code parameter
    IF p_sponsor_code IS NULL THEN
      l_b_error := TRUE;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS','IGS_FI_SPNSR_CD_NULL');
        fnd_msg_pub.add;
      END IF;
    ELSE
      l_b_ret_status := validate_spnsr_cd(p_sponsor_code);
      IF NOT l_b_ret_status THEN
        l_b_error := TRUE;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('IGS','IGS_FI_INVALID_SPNSR_CD');
          fnd_message.set_token('SPONSOR_CODE',p_sponsor_code);
          fnd_msg_pub.add;
        END IF;
      END IF;
    END IF;

    -- validate Award Calendar Instance parameters
    IF (p_awd_ci_cal_type IS NULL OR p_awd_ci_sequence_number IS NULL) THEN
      l_b_error := TRUE;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS','IGS_FI_AWD_INST_NULL');
        fnd_msg_pub.add;
      END IF;
    ELSE
      l_b_ret_status := validate_award_cal_inst(p_awd_ci_cal_type,p_awd_ci_sequence_number);
      IF NOT l_b_ret_status THEN
        l_b_error := TRUE;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('IGS','IGS_FI_INVALID_AWD_CAL_INST');
          fnd_message.set_token('AWARD_YR_TYPE',p_awd_ci_cal_type);
          fnd_message.set_token('AWARD_YR_CAL_SEQ',p_awd_ci_sequence_number);
          fnd_msg_pub.add;
        END IF;
      END IF;

      --Validate the Award Year Status. If the status is not open, show the error message.
      l_c_message_name := NULL;
      igs_fi_crdapi_util.get_award_year_status( p_v_awd_cal_type     =>  p_awd_ci_cal_type,
                                                p_n_awd_seq_number   =>  p_awd_ci_sequence_number,
                                                p_v_awd_yr_status    =>  l_v_awd_yr_status_cd,
                                                p_v_message_name     =>  l_c_message_name
                                               );
      IF l_c_message_name IS NOT NULL THEN
        l_b_error := TRUE;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          IF l_c_message_name = 'IGF_SP_INVALID_AWD_YR_STATUS' THEN
            fnd_message.set_name('IGF',l_c_message_name);
          ELSE
            fnd_message.set_name('IGS',l_c_message_name);
          END IF;
          fnd_msg_pub.add;
        END IF;
      END IF;
    END IF;

    -- validate Load Calendar Instance parameters
    IF (p_ld_cal_type IS NULL OR p_ld_ci_sequence_number IS NULL ) THEN
      l_b_error := TRUE;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS','IGS_FI_LD_INST_NULL');
        fnd_msg_pub.add;
      END IF;
    ELSE
      l_b_ret_status := validate_load_cal_inst(p_ld_cal_type,p_ld_ci_sequence_number);
      IF NOT l_b_ret_status THEN
        l_b_error := TRUE;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('IGS','IGS_FI_INVALID_TRM_CAL_INST');
          fnd_message.set_token('LOAD_CAL_TYPE',p_ld_cal_type);
          fnd_message.set_token('LOAD_CAL_SEQ',p_ld_ci_sequence_number);
          fnd_msg_pub.add;
        END IF;
      END IF;
    END IF;

    -- Validate Amount parameter
    IF (p_amount IS NULL OR p_amount < 0) THEN
      l_b_error := TRUE;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS','IGS_FI_INVALID_SPR_AMT');
        fnd_msg_pub.add;
      END IF;
    END IF;

    IF (p_sponsor_code IS NOT NULL AND
        p_awd_ci_cal_type IS NOT NULL AND
        p_awd_ci_sequence_number IS NOT NULL AND
        p_ld_cal_type IS NOT NULL AND
        p_ld_ci_sequence_number IS NOT NULL ) THEN
      -- Check if the Sponsor and Award Calendar Instance is pre-defined in the system
      check_spnsr_awd_rel(p_c_fund_code=> p_sponsor_code,
                          p_c_aw_cal_type => p_awd_ci_cal_type,
                          p_n_aw_sequence_number => p_awd_ci_sequence_number,
                          p_c_ld_cal_type => p_ld_cal_type,
                          p_n_ld_sequence_number => p_ld_ci_sequence_number,
                          p_b_return_status => l_b_ret_status,
                          p_n_fund_id => l_n_fund_id );

      IF NOT l_b_ret_status THEN
        l_b_error := TRUE;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('IGS','IGS_FI_SPNR_INACTIVE');
          fnd_message.set_token('SPONSOR_CODE',p_sponsor_code);
          fnd_message.set_token('AWARD_YR_TYPE',p_awd_ci_cal_type);
          fnd_message.set_token('AWARD_YR_CAL_SEQ',p_awd_ci_sequence_number);
          fnd_message.set_token('LOAD_CAL_TYPE',p_ld_cal_type);
          fnd_message.set_token('LOAD_CAL_SEQ',p_ld_ci_sequence_number);
          fnd_msg_pub.add;
        END IF;
      END IF;
    END IF;

    -- If any of the parameter validation fails then there is no need to proceed further.
    -- For erroring out in this case, should RAISE g_exc_error exception
    IF NOT l_b_error THEN
       -- invoke local procedure to identify the base id of the student for the Award Calendar Instance and Person Id combination
       check_create_fa_rec(NVL(p_person_id,l_n_person_id),p_awd_ci_cal_type,p_awd_ci_sequence_number,l_b_ret_status,l_n_base_id);

       -- If the above procedure returns TRUE then the OUT variable l_n_base_id has the value for Base ID
       IF l_b_ret_status THEN
         l_b_ret_status:= check_spnsr_stdnt_rel(l_n_fund_id,
                                                l_n_base_id,
                                                p_ld_cal_type,
                                                p_ld_ci_sequence_number);
         IF l_b_ret_status THEN
           IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
             fnd_message.set_name('IGS','IGS_FI_SPNR_STDNT_EXISTS');
             fnd_message.set_token('PERSON_ID',NVL(p_person_id,l_n_person_id));
             fnd_message.set_token('SPONSOR_CODE',p_sponsor_code);
             fnd_message.set_token('AWARD_YR_TYPE',p_awd_ci_cal_type);
             fnd_message.set_token('AWARD_YR_CAL_SEQ',p_awd_ci_sequence_number);
             fnd_message.set_token('LOAD_CAL_TYPE',p_ld_cal_type);
             fnd_message.set_token('LOAD_CAL_SEQ',p_ld_ci_sequence_number);
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_error;
           END IF;
         ELSE
           -- If there is no relation then a new Sponsor-Student relation should be created.
           -- Bug 5217319 Added call to format amount by rounding off to currency precision
           igf_sp_stdnt_rel_pkg.insert_row (x_rowid => l_rowid,
                                            x_spnsr_stdnt_id=> l_n_spr_stdnt_id,
                                            x_fund_id => l_n_fund_id ,
                                            x_base_id=> l_n_base_id,
                                            x_person_id=> NVL(p_person_id, l_n_person_id),
                                            x_ld_cal_type=> p_ld_cal_type,
                                            x_ld_sequence_number=> p_ld_ci_sequence_number,
                                            x_tot_spnsr_amount=> igs_fi_gen_gl.get_formatted_amount(p_amount),
                                            x_min_credit_points=> NULL,
                                            x_min_attendance_type=> NULL);
         END IF;
       END IF;
    ELSE
      RAISE fnd_api.g_exc_error;
    END IF;

    -- If the calling program has passed the parameter for committing the data and there
    -- have been no errors in calling the balances process, then commit the work
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count          => x_msg_count,
                              p_data           => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_stdnt_spnsr_rel_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_count          => x_msg_count,
                                 p_data           => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_stdnt_spnsr_rel_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count          => x_msg_count,
                                 p_data           => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_stdnt_spnsr_rel_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name,
                                l_api_name);
      END IF;
      fnd_msg_pub.count_and_get( p_count          => x_msg_count,
                                 p_data           => x_msg_data);
  END create_stdnt_spnsr_rel;
END igf_sp_assign_pub;

/
