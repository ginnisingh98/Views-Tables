--------------------------------------------------------
--  DDL for Package Body IGF_AP_TODO_GRPS_PRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_TODO_GRPS_PRC_PKG" AS
/* $Header: IGFAP28B.pls 120.10 2006/04/20 02:58:36 veramach ship $ */
/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGF_AP_TODO_GRPS_PRC_PKG                |
 |                                                                       |
 | NOTES:                                                                |
 |   This process adds one or more To Do Items to the given Student or to|
 |   the group of students using Person ID Groups for a given Award Year.|
 |                                                                       |
 | HISTORY                                                               |
 | Who         When          What                                        |
 | bvisvana   05-Jul-2005   Bug# 3440755. When no record for Person group|
 |                          (ln_stdnt_count = 0), set retcode = 0 not 2  |
 | bvisvana   20-Jun-2005   -FA 140 - To Do Item Process                 |
 |                          Included Status 1 to Status 15 corresponding |
 |                          to the 15 to do items.                       |
 |                          -If the TO DO item is CAREER item then it is |
 |                          updated for the base_id with which it was    |
 |                          added. PREFLEND to do item is not updated.   |
 |                          Skipped when trying to add it again.         |
  |                          - main proc and log_input_params gets changed|
 | cdcruz     01-Oct-2003   Bug 3085558  - FA121 Verificaion Wksht       |
 |                          all parameters made optional now             |
 | bkkumar     04-jun-2003  Bug #2858504
 |                          Added legacy_record_flag
 |                          in the table handler calls for
 |                          igf_ap_td_item_inst_pkg.insert_row
 | rasingh     09-Jan-2003   Bug 2738442, Message IGF_AP_INVALID_QUERY   |
 |                           added                                                 |
 | brajendr    19-OCT-2002   Bug # 2632359                               |
 |                           Modified the Log file contents with         |
 |                           descriptive messages                        |
 |
 | brajendr    12-Oct-2002   Changes the paramter order as specified in  |
 |                           the concurrent Job                          |
 |                           Modified the Messages IGF_AP_NO_BASEID      |
 | bkkumar     04-jun-2003   Bug #2858504                                |
 |                           Added legacy_record_flag                    |
 |                           in the table handler calls for              |
 |                           igf_ap_td_item_inst_pkg.insert_row          |
 | gvarapra    13-sep-2004   Added the validation to auto update the     |
 |                           To Do Item status that are attached to the  |
 |                            system to do type of ISIR or PROFILE.      |
 *=======================================================================*/

  -- global Variables
  ln_skip_items NUMBER := 0;
  ln_item_cnt   NUMBER := 0;
  l_has_payment_isir      VARCHAR2(1) := NULL;
  l_has_active_profile    VARCHAR2(1) := NULL;
  l_has_isir      VARCHAR2(1) := NULL;
  l_has_profile   VARCHAR2(1) := NULL;

  PROCEDURE log_input_params(
                             p_awd_cal_type    IN  igs_ca_inst.cal_type%TYPE,
                             p_awd_seq_num     IN  igs_ca_inst.sequence_number%TYPE,
                             p_base_id         IN  NUMBER,
                             p_person_id_grp   IN  NUMBER,
                             p_upd_mode        IN  VARCHAR2,
                             p_item_number_1   IN  NUMBER,
                             p_status_1        IN  VARCHAR,
                             p_item_number_2   IN  NUMBER,
                             p_status_2        IN  VARCHAR,
                             p_item_number_3   IN  NUMBER,
                             p_status_3        IN  VARCHAR,
                             p_item_number_4   IN  NUMBER,
                             p_status_4        IN  VARCHAR,
                             p_item_number_5   IN  NUMBER,
                             p_status_5        IN  VARCHAR,
                             p_item_number_6   IN  NUMBER,
                             p_status_6        IN  VARCHAR,
                             p_item_number_7   IN  NUMBER,
                             p_status_7        IN  VARCHAR,
                             p_item_number_8   IN  NUMBER,
                             p_status_8        IN  VARCHAR,
                             p_item_number_9   IN  NUMBER,
                             p_status_9        IN  VARCHAR,
                             p_item_number_10  IN  NUMBER,
                             p_status_10       IN  VARCHAR,
                             p_item_number_11  IN  NUMBER,
                             p_status_11       IN  VARCHAR,
                             p_item_number_12  IN  NUMBER,
                             p_status_12       IN  VARCHAR,
                             p_item_number_13  IN  NUMBER,
                             p_status_13       IN  VARCHAR,
                             p_item_number_14  IN  NUMBER,
                             p_status_14       IN  VARCHAR,
                             p_item_number_15  IN  NUMBER,
                             p_status_15       IN  VARCHAR
                            ) AS
    /*
    ||  Created By : brajendr
    ||  Created On : 23-Sep-2002
    ||  Purpose    : Logs all the Input Parameters
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  bvisvana        20-Jun-2005     Moved the log printing inside IF condition
    ||                                  i.e If the item is NOT NULL then log it else don't log it
    ||                                  Signature of log_input_params changed
    ||  (reverse chronological order - newest change first)
    */

    --Cursor to find the User Parameter Award Year (which is same as Alternate Code) to display in the Log
    CURSOR c_alternate_code(
                            cp_ci_cal_type    igs_ca_inst.cal_type%TYPE,
                            cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE
                           ) IS
    SELECT alternate_code
      FROM igs_ca_inst
     WHERE cal_type        = cp_ci_cal_type
       AND sequence_number = cp_ci_sequence_number;

    CURSOR c_get_parameters IS
    SELECT meaning, lookup_code
      FROM igf_lookups_view
     WHERE lookup_type='IGF_GE_PARAMETERS'
       AND lookup_code IN ('AWARD_YEAR','PERSON_NUMBER','PERSON_ID_GROUP','ITEM_CODE','PARAMETER_PASS','UPDATE_TD_MODE');

    -- Get the details of Item codes and its descritpions
    CURSOR c_item_details(
                          cp_todo_number   igf_ap_td_item_mst.todo_number%TYPE
                         ) IS
    SELECT description
      FROM igf_ap_td_item_mst
     WHERE todo_number = cp_todo_number;

    -- Get the details of
    CURSOR c_person_number(
                           cp_base_id         IN  NUMBER
                          ) IS
    SELECT pe.person_number
      FROM igs_pe_person_base_v pe,
           igf_ap_fa_base_rec_all fa
     WHERE pe.person_id = fa.person_id
       AND fa.base_id = cp_base_id;

    -- Get the details of
    CURSOR c_person_group(
                           cp_person_id_grp   IN  NUMBER
                          ) IS
    SELECT description
      FROM igs_pe_all_persid_group_v
     WHERE group_id = cp_person_id_grp;

    -- Get Item Description
    CURSOR c_item_descrption(
                             cp_item_number  IN  NUMBER
                            ) IS
    SELECT description
      FROM igf_ap_td_item_mst_all
     WHERE todo_number = cp_item_number;

    parameter_rec              c_get_parameters%ROWTYPE;
    lc_item_description        igf_ap_td_item_mst.description%TYPE;
    lv_awd_alternate_code      igs_ca_inst.alternate_code%TYPE;
    lv_award_year_pmpt         igf_lookups_view.meaning%TYPE;
    lv_person_number_pmpt      igf_lookups_view.meaning%TYPE;
    lv_person_id_grp_pmpt      igf_lookups_view.meaning%TYPE;
    lv_item_code_pmpt          igf_lookups_view.meaning%TYPE;
    lv_status_pmpt             igf_lookups_view.meaning%TYPE;
    l_para_pass                igf_lookups_view.meaning%TYPE;
    l_person_number            hz_parties.party_number%TYPE;
    l_group_desc               igs_pe_persid_group_all.description%TYPE;
    l_item_description         igf_ap_td_item_mst_all.description%TYPE;
    l_upd_mode_pmpt            igf_lookups_view.meaning%TYPE;

  BEGIN

    -- Set all the Prompts for the Input Parameters
    lv_status_pmpt := igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','STATUS');

    OPEN c_get_parameters;
    LOOP
     FETCH c_get_parameters INTO  parameter_rec;
     EXIT WHEN c_get_parameters%NOTFOUND;

     IF parameter_rec.lookup_code ='AWARD_YEAR' THEN
       lv_award_year_pmpt := TRIM(parameter_rec.meaning);

     ELSIF parameter_rec.lookup_code ='PERSON_NUMBER' THEN
       lv_person_number_pmpt := TRIM(parameter_rec.meaning);

     ELSIF parameter_rec.lookup_code ='PERSON_ID_GROUP' THEN
       lv_person_id_grp_pmpt := TRIM(parameter_rec.meaning);

     ELSIF parameter_rec.lookup_code ='ITEM_CODE' THEN
       lv_item_code_pmpt := TRIM(parameter_rec.meaning);

     ELSIF parameter_rec.lookup_code ='PARAMETER_PASS' THEN
       l_para_pass := TRIM(parameter_rec.meaning);

     ELSIF parameter_rec.lookup_code ='UPDATE_TD_MODE' THEN
       l_upd_mode_pmpt := TRIM(parameter_rec.meaning);

     END IF;

    END LOOP;
    CLOSE c_get_parameters;

    -- Get the Award Year Alternate Code
    OPEN c_alternate_code(p_awd_cal_type, p_awd_seq_num);
    FETCH c_alternate_code INTO lv_awd_alternate_code;
    CLOSE c_alternate_code;

    -- Get the Person Number
    OPEN c_person_number(p_base_id);
    FETCH c_person_number INTO l_person_number;
    CLOSE c_person_number;

    -- Get the Person Group
    OPEN c_person_group(p_person_id_grp);
    FETCH c_person_group INTO l_group_desc;
    CLOSE c_person_group;

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_para_pass); --------------Parameters Passed--------------
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_award_year_pmpt,40)    || ' : '|| lv_awd_alternate_code);
    IF l_group_desc IS NOT NULL THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_person_id_grp_pmpt,40) || ' : '|| l_group_desc);
    END IF;
    IF l_person_number IS NOT NULL THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_person_number_pmpt,40) || ' : '|| l_person_number);
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(l_upd_mode_pmpt,40)    || ' : '|| igf_aw_gen.lookup_desc('IGF_AP_TD_UPD_MODE',p_upd_mode));

    l_item_description := NULL;
    IF p_item_number_1 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_1);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 1',  40) || ' : ' || l_item_description );
      IF p_status_1 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_1));
      END IF;
    END IF;

    l_item_description := NULL;
    IF p_item_number_2 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_2);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 2',  40) || ' : ' || l_item_description );
      IF p_status_2 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_2));
      END IF;
    END IF ;

    l_item_description := NULL;
    IF p_item_number_3 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_3);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 3',  40) || ' : ' || l_item_description );
      IF p_status_3 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_3));
      END IF;
    END IF;

    l_item_description := NULL;
    IF p_item_number_4 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_4);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 4',  40) || ' : ' || l_item_description );
      IF p_status_4 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_4));
      END IF;
    END IF ;

    l_item_description := NULL;
    IF p_item_number_5 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_5);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 5',  40) || ' : ' || l_item_description );
      IF p_status_5 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_5));
      END IF;
    END IF;

    l_item_description := NULL;
    IF p_item_number_6 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_6);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 6',  40) || ' : ' || l_item_description );
      IF p_status_6 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_6));
      END IF;
    END IF;

    l_item_description := NULL;
    IF p_item_number_7 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_7);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 7',  40) || ' : ' || l_item_description );
      IF p_status_7 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_7));
      END IF;
    END IF;

    l_item_description := NULL;
    IF p_item_number_8 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_8);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 8',  40) || ' : ' || l_item_description );
      IF p_status_8 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_8));
      END IF;
    END IF;

    l_item_description := NULL;
    IF p_item_number_9 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_9);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 9',  40) || ' : ' || l_item_description );
      IF p_status_9 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_9));
      END IF;
    END IF;

    l_item_description := NULL;
    IF p_item_number_10 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_10);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 10',  40) || ' : ' || l_item_description );
      IF p_status_10 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_10));
      END IF;
    END IF;

    l_item_description := NULL;
    IF p_item_number_11 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_11);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 11',  40) || ' : ' || l_item_description );
      IF p_status_11 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_11));
      END IF;
    END IF;

    l_item_description := NULL;
    IF p_item_number_12 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_12);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 12',  40) || ' : ' || l_item_description );
      IF p_status_12 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_12));
      END IF;
    END IF;

    l_item_description := NULL;
    IF p_item_number_13 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_13);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 13',  40) || ' : ' || l_item_description );
      IF p_status_13 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_13));
      END IF;
    END IF;

    l_item_description := NULL;
    IF p_item_number_14 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_14);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 14',  40) || ' : ' || l_item_description );
      IF p_status_14 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_14));
      END IF;
    END IF;

    l_item_description := NULL;
    IF p_item_number_15 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_15);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 15',  40) || ' : ' || l_item_description );
      IF p_status_15 IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_status_pmpt || ' 1',  40) || ' : ' || igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',p_status_15));
      END IF;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

  EXCEPTION
    WHEN others THEN
      FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_TODO_GRPS_PRC_PKG.LOG_INPUT_PARAMS');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END log_input_params;


  PROCEDURE add_to_do(
                      p_base_id      IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                      p_todo_number  IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                      p_item_cnt     IN  NUMBER,
                      p_person_id    IN  igf_ap_fa_base_rec_all.person_id%TYPE,
                      p_status       IN  igf_ap_td_item_inst_all.status%TYPE,
                      p_upd_mode    IN  VARCHAR2
                     ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  bvisvana        21-Jun-2005     Added a parameter p_status to the procedure's signature
    ||                                  Updation of Status field if already present
    ||                                  If item is PREFLEND, then the base id with which it was added is updated not with
    ||                                  the current base id
    ||  (reverse chronological order - newest change first)
    */

    -- Get the details of Item codes and its descritpions
    CURSOR c_item_details(
                          cp_todo_number   igf_ap_td_item_mst.todo_number%TYPE
                         ) IS
      SELECT item_code, description, required_for_application, freq_attempt, max_attempt, career_item, system_todo_type_code
      FROM igf_ap_td_item_mst
      WHERE todo_number = cp_todo_number;


    CURSOR c_chk_career_exists(
                               cp_person_id    igf_ap_fa_base_rec_all.person_id%TYPE,
                               cp_todo_number  igf_ap_td_item_mst.todo_number%TYPE
                              ) IS
    SELECT 1 value, fab.base_id base_id
      FROM igf_ap_fa_base_rec fab,
           igf_ap_td_item_inst inst,
           igf_ap_td_item_mst mst
     WHERE fab.person_id = cp_person_id
       AND mst.todo_number = cp_todo_number
       AND mst.career_item = 'Y'
       AND inst.item_sequence_number = mst.todo_number
       AND inst.base_id = fab.base_id;

    --FA 140 - To Avoid skipping of items if already present. Need to update
    CURSOR c_to_do_item (
                          cp_base_id              igf_ap_fa_base_rec_all.base_id%TYPE,
                          cp_item_sequence_number igf_ap_td_item_inst_all.item_sequence_number%TYPE
                        ) IS
      SELECT  item_inst.ROWID row_id, item_inst.*
      FROM    igf_ap_td_item_inst_all item_inst
      WHERE   base_id = cp_base_id
      AND     item_sequence_number  = cp_item_sequence_number;

    CURSOR c_check_preflender(cp_person_id igf_ap_fa_base_rec_all.person_id%TYPE) IS
      SELECT 'x'
        FROM
        igf_sl_cl_pref_lenders
      WHERE person_id = cp_person_id AND
      TRUNC(SYSDATE) BETWEEN TRUNC(start_date) AND NVL(TRUNC(end_date),TRUNC(sysdate));


    lc_item_details         c_item_details%ROWTYPE;
    lc_chk_career_exists    c_chk_career_exists%ROWTYPE;
    lv_rowid                ROWID;
    lb_item_present         BOOLEAN := FALSE;
    l_status                igf_ap_td_item_inst_all.status%TYPE := 'REQ';

    lc_check_preflender     c_check_preflender%ROWTYPE;
    lc_to_do_item           c_to_do_item%ROWTYPE;
    l_base_id               igf_ap_fa_base_rec_all.base_id%TYPE;


  BEGIN

      l_base_id := p_base_id;
      -- check whether the TO Do item is a Career Item, then there should be one instance it for a student acrosss Award Years
      -- bvisvana - If this is a career item do not return, instead get the base_id of the this item to which it was added
      -- Use the base_id to validate for item present and update
      OPEN c_chk_career_exists(p_person_id, p_todo_number);
      FETCH c_chk_career_exists INTO lc_chk_career_exists;
      CLOSE c_chk_career_exists;
      IF lc_chk_career_exists.value = 1 THEN
        l_base_id := lc_chk_career_exists.base_id;
      END IF;

      -- Get the details of Item Codes like Required for application, item_code, description
      OPEN c_item_details( p_todo_number);
      FETCH c_item_details INTO lc_item_details;
      CLOSE c_item_details;

      IF lc_item_details.system_todo_type_code = 'ISIR' THEN
        IF l_has_isir = 'Y' THEN
          IF l_has_payment_isir = 'Y' THEN
            l_status := 'COM';
          ELSE
            l_status := 'REC';
          END IF;
        ELSE
          l_status := 'REQ';
        END IF;
      ELSIF lc_item_details.system_todo_type_code = 'PROFILE' THEN
        IF l_has_profile = 'Y' THEN
          IF l_has_active_profile = 'Y' THEN
            l_status := 'COM';
          ELSE
            l_status := 'REC';
          END IF;
        ELSE
          l_status := 'REQ';
        END IF;
      -- bvisvana - FA 140 - if Others and Instapp, then consider the status if specified else it goes as 'REQ'
      -- So as per FA 140 Pref Lender item of Type "PREFLEND" would go as "REQ"
      ELSIF lc_item_details.system_todo_type_code IN ('OTHERS','INSTAPP') AND p_status IS NOT NULL THEN
        l_status := p_status;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.add_to_do.debug','l_status:'||l_status);
    END IF;

    -- To check whether the SYSTEM_TODO_TYPE_CODE = 'PREFLEND' and if so check whether a active pref lender exists for the person
    IF lc_item_details.system_todo_type_code = 'PREFLEND' THEN
        OPEN c_check_preflender(cp_person_id => p_person_id);
        FETCH c_check_preflender INTO lc_check_preflender;
        IF c_check_preflender%FOUND THEN
          -- If already an active preflender present - then Skip that item for processing and log a message
          fnd_message.set_name('IGF','IGF_AP_LEND_TD_NO_ASSGN');
          fnd_message.set_token('ITEM',lc_item_details.description);
          FND_FILE.PUT_LINE(FND_FILE.LOG ,FND_MESSAGE.GET);
          ln_skip_items := ln_skip_items + 1;
          RETURN;
        END IF;
        CLOSE c_check_preflender;
    END IF;

    -- Check whether the TO DO items was already added or not.
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.add_to_do.debug','opening c_to_do_item with base_id/item_seq_number:'||l_base_id||'/'||p_todo_number);
    END IF;
    OPEN c_to_do_item(cp_base_id              => l_base_id,
                      cp_item_sequence_number => p_todo_number);
    FETCH c_to_do_item INTO lc_to_do_item;
    IF c_to_do_item%FOUND THEN
      lb_item_present := TRUE;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.add_to_do.debug','p_todo_number:'||p_todo_number||' already present for base_id:'||p_base_id);
      END IF;
    ELSE
      lb_item_present := FALSE;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.add_to_do.debug','p_todo_number:'||p_todo_number||' not present for base_id:'||p_base_id);
      END IF;
    END IF;
    CLOSE c_to_do_item;

    IF lb_item_present = TRUE THEN
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.add_to_do.debug','opening c_to_do_item for p_todo_number:'||p_todo_number||' and base_id:'||l_base_id);
     END IF;
     OPEN c_to_do_item(cp_base_id              => l_base_id,
                       cp_item_sequence_number => p_todo_number);
     FETCH c_to_do_item INTO lc_to_do_item;
     CLOSE c_to_do_item;
     IF lc_to_do_item.inactive_flag = 'Y' THEN
      fnd_message.set_name('IGF','IGF_AP_INAC_TD_SKIP');
      fnd_message.set_token('ITEMCODE',lc_item_details.description);
      FND_FILE.PUT_LINE(FND_FILE.LOG ,FND_MESSAGE.GET);
      ln_skip_items := ln_skip_items + 1;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.add_to_do.debug','p_todo_number:'||p_todo_number||' skipped as it is inactive');
      END IF;
      RETURN;
     END IF;
     /*
        Here, we have to update the item based on the following conditions:
        If p_upd_mode = UPD, then update the item at all times
        If p_upd_mode = NO_UPD_IF_COMP, then update is the status is NOT COM

     */
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.add_to_do.debug','p_upd_mode:'||p_todo_number||' and lc_to_do_item.status:'||lc_to_do_item.status);
     END IF;
     IF p_upd_mode = 'UPD' OR (p_upd_mode = 'NO_UPD_IF_COMP' AND lc_to_do_item.status <> 'COM') THEN
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.add_to_do.debug','calling igf_ap_td_item_inst_pkg.update_row with base_id/item_seq_number:'||lc_to_do_item.base_id||'/'||lc_to_do_item.item_sequence_number);
       END IF;
     igf_ap_td_item_inst_pkg.update_row (
                                          x_mode                      => 'R',
                                          x_rowid                     => lc_to_do_item.row_id,
                                          x_base_id                   => lc_to_do_item.base_id,
                                          x_item_sequence_number      => lc_to_do_item.item_sequence_number,
                                          x_status                    => l_status,
                                          x_status_date               => TRUNC(SYSDATE),
                                          x_add_date                  => lc_to_do_item.add_date,
                                          x_corsp_date                => lc_to_do_item.corsp_date,
                                          x_corsp_count               => lc_to_do_item.corsp_count,
                                          x_inactive_flag             => lc_to_do_item.inactive_flag,
                                          x_required_for_application  => lc_to_do_item.required_for_application,
                                          x_freq_attempt              => lc_to_do_item.freq_attempt,
                                          x_max_attempt               => lc_to_do_item.max_attempt,
                                          x_legacy_record_flag        => lc_to_do_item.legacy_record_flag,
                                          x_clprl_id                  => lc_to_do_item.clprl_id
                                         );

      -- Log message with the Updated To Do Item.
      fnd_message.set_name('IGF','IGF_AP_TODO_UPD');
      fnd_message.set_token('ITEM',lc_item_details.description);
      fnd_message.set_token('STATUS',igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',l_status));
      FND_FILE.PUT_LINE(FND_FILE.LOG ,FND_MESSAGE.GET);
      END IF;
     ELSIF lb_item_present = FALSE THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.add_to_do.debug','calling igf_ap_td_item_inst_pkg.insert_row with base_id/item_seq_number:'||l_base_id||'/'||p_todo_number);
      END IF;
      igf_ap_td_item_inst_pkg.insert_row (
                                          x_mode                      => 'R',
                                          x_rowid                     => lv_rowid,
                                          x_base_id                   => l_base_id,
                                          x_item_sequence_number      => p_todo_number,
                                          x_status                    => l_status,
                                          x_status_date               => TRUNC(SYSDATE),
                                          x_add_date                  => TRUNC(SYSDATE),
                                          x_corsp_date                => NULL,
                                          x_corsp_count               => NULL,
                                          x_inactive_flag             => 'N',
                                          x_required_for_application  => lc_item_details.required_for_application,
                                          x_freq_attempt              => lc_item_details.freq_attempt,
                                          x_max_attempt               => lc_item_details.max_attempt,
                                          x_legacy_record_flag        => NULL,
                                          x_clprl_id                  => NULL
                                         );

      -- Log message with the added To Do Item added to the student.
      fnd_message.set_name('IGF','IGF_AP_TODO_ASSIGN');
      fnd_message.set_token('ITEM',lc_item_details.description);
      fnd_message.set_token('STATUS',igf_aw_gen.lookup_desc('IGF_TD_ITEM_STATUS',l_status));
      FND_FILE.PUT_LINE(FND_FILE.LOG ,FND_MESSAGE.GET);
    END IF;

  EXCEPTION
    WHEN others THEN
      FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_TODO_GRPS_PRC_PKG.ADD_TO_DO');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END add_to_do;

  FUNCTION assign_todo(
                         p_base_id         IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                         p_person_id_grp   IN  igs_pe_persid_group_all.group_id%TYPE,
                         p_awd_cal_type    IN  igs_ca_inst.cal_type%TYPE,
                         p_awd_seq_num     IN  igs_ca_inst.sequence_number%TYPE,
                         p_upd_mode        IN  VARCHAR2,
                         p_item_number_1   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_1        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_2   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_2        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_3   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_3        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_4   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_4        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_5   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_5        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_6   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_6        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_7   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_7        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_8   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_8        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_9   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_9        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_10  IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_10       IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_11  IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_11       IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_12  IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_12       IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_13  IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_13       IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_14  IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_14       IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_15  IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_15       IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_calling_from    IN  VARCHAR2
                        ) RETURN BOOLEAN AS
    /*
    ||  Created By : brajendr
    ||  Created On : 23-Sep-2002
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  ridas          07-Feb-2006      Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
    ||  bvisvana       21-Jun-2005      Signature of assign_todo is changed to include status from 1 to 15
    ||  (reverse chronological order - newest change first)
    */

    -- Get all Active persons from the given person_id_group.
 /* Variables for the dynamic person id group */
    lv_status         VARCHAR2(1) := 'S';  /*Defaulted to 'S' and the function will return 'F' in case of failure */
    lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

    lv_sql_stmt   VARCHAR(32767) := igf_ap_ss_pkg.get_pid(p_person_id_grp,lv_status,lv_group_type);

   TYPE c_person_id_grpCurTyp IS REF CURSOR ;
     c_person_id_grp c_person_id_grpCurTyp ;
   TYPE c_person_id_grp_recTyp IS RECORD (  person_id igs_pe_person_base_v.person_id%TYPE,  person_number igs_pe_person_base_v.person_number%TYPE, full_name igs_pe_person_base_v.full_name%TYPE );
     c_person_id_grp_rec c_person_id_grp_recTyp ;

  /*  CURSOR c_person_id_grp (cp_person_id_grp igs_pe_persid_group_all.group_id%TYPE) IS
    SELECT person_id, person_number, full_name
      FROM igs_pe_prsid_grp_mem_v
     WHERE group_id = cp_person_id_grp
       AND TRUNC(SYSDATE) BETWEEN  NVL(start_date,TRUNC(SYSDATE)) AND NVL(end_date,TRUNC(SYSDATE));
*/


    -- Check whether the sudent exists in the FA system or not.
    CURSOR c_fa_base(
                     cp_person_id           igf_ap_fa_base_rec_all.person_id%TYPE,
                     cp_ci_cal_type         igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                     cp_ci_sequence_number  igf_ap_fa_base_rec_all.ci_sequence_number%TYPE
                    ) IS
    SELECT base_id
      FROM igf_ap_fa_base_rec
     WHERE person_id = cp_person_id
       AND ci_cal_type = cp_ci_cal_type
       AND ci_sequence_number = cp_ci_sequence_number;


    -- Get the person number and person name with the person id.
    CURSOR c_person_details(
                            cp_base_id           igf_ap_fa_base_rec_all.base_id%TYPE
                           ) IS
    SELECT pe.person_number, pe.full_name person_name, fa.person_id
     FROM igf_ap_fa_base_rec fa,
          igs_pe_person_base_v pe
    WHERE fa.base_id = cp_base_id
      AND fa.person_id = pe.person_id;

    --- Get the Person Number prompt
    CURSOR c_get_parameters IS
    SELECT meaning
      FROM igf_lookups_view
     WHERE lookup_type='IGF_GE_PARAMETERS'
       AND lookup_code IN ('PERSON_NUMBER');


    ln_base_id             igf_ap_fa_base_rec_all.base_id%TYPE;
    lc_person_details_rec  c_person_details%ROWTYPE;
    ln_item_cnt            NUMBER(3) := 0;
    l_person_number        igf_lookups_view.meaning%TYPE;


    PROCEDURE each_student_todo(
                                p_base_id    IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                                p_person_id  IN  igf_ap_fa_base_rec_all.person_id%TYPE
                               ) AS
      /*
      ||  Created By : brajendr
      ||  Created On :
      ||  Purpose :
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      */
      -- Get the isir status for a student
    CURSOR c_has_payment_isir(
                              p_base_id igf_ap_isir_matched_all.base_id%type
                             )IS
    SELECT isir_id
      FROM igf_ap_isir_matched_all
     WHERE payment_isir='Y'
       AND base_id=p_base_id
       AND system_record_type NOT IN ('INTERNAL','SIMULATED');

     -- Get the profile status for a student
    CURSOR c_has_active_profile(
                                 p_base_id igf_ap_css_profile_all.base_id%type
                                )IS
    SELECT cssp_id
      FROM igf_ap_css_profile_all
     WHERE active_profile='Y'
       AND base_id=p_base_id;

    CURSOR c_has_isir(
                       p_base_id igf_ap_isir_matched_all.base_id%type
                     )IS
    SELECT isir_id
      FROM igf_ap_isir_matched_all
     WHERE base_id=p_base_id
       AND system_record_type IN ('ORIGINAL');

     -- Get the profile status for a student
    CURSOR c_has_profile(
                           p_base_id igf_ap_css_profile_all.base_id%type
                        )IS
    SELECT cssp_id
      FROM igf_ap_css_profile_all
     WHERE base_id=p_base_id;
    lc_has_payment_isir c_has_payment_isir%ROWTYPE;
    lc_has_isir         c_has_isir%ROWTYPE;
    lc_has_profile      c_has_profile%ROWTYPE;
    lc_has_active_profile c_has_active_profile%ROWTYPE;
    BEGIN

      ln_skip_items := 0;
      ln_item_cnt   := 0;

      OPEN c_has_isir(p_base_id);
      FETCH c_has_isir INTO lc_has_isir;
      IF c_has_isir%FOUND THEN
        l_has_isir := 'Y';
        OPEN c_has_payment_isir(p_base_id);
        FETCH c_has_payment_isir INTO lc_has_payment_isir;
        IF c_has_payment_isir%FOUND THEN
          l_has_payment_isir := 'Y';
        ELSE
          l_has_payment_isir := 'N';
        END IF;
        CLOSE c_has_payment_isir;
      ELSE
        l_has_isir := 'N';
      END IF;
      CLOSE c_has_isir;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','l_has_isir:'||l_has_isir);
      END IF;

      OPEN c_has_profile(p_base_id);
      FETCH c_has_profile INTO lc_has_profile;
      IF c_has_profile%FOUND THEN
        l_has_profile := 'Y';
        OPEN c_has_active_profile(p_base_id);
        FETCH c_has_active_profile INTO lc_has_active_profile;
        IF c_has_active_profile%FOUND THEN
          l_has_active_profile := 'Y';
        ELSE
          l_has_active_profile := 'N';
        END IF;
        CLOSE c_has_active_profile;
      ELSE
        l_has_profile := 'N';
      END IF;
      CLOSE c_has_profile;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','l_has_profile:'||l_has_profile);
      END IF;

      -- Process for each To Do Items, if items are not null
      IF p_item_number_1 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number_1/status/p_upd_mode:'||p_base_id||'/'||p_item_number_1||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_1, ln_item_cnt, p_person_id, p_status_1,p_upd_mode);
      END IF;

      IF p_item_number_2 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number/status/p_upd_mode:'||p_base_id||'/'||p_item_number_2||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_2, ln_item_cnt, p_person_id, p_status_2,p_upd_mode);
      END IF;

      IF p_item_number_3 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number/status/p_upd_mode:'||p_base_id||'/'||p_item_number_3||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_3, ln_item_cnt, p_person_id, p_status_3,p_upd_mode);
      END IF;

      IF p_item_number_4 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number/status/p_upd_mode:'||p_base_id||'/'||p_item_number_4||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_4, ln_item_cnt, p_person_id, p_status_4,p_upd_mode);
      END IF;

      IF p_item_number_5 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number/status/p_upd_mode:'||p_base_id||'/'||p_item_number_5||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_5, ln_item_cnt, p_person_id, p_status_5,p_upd_mode);
      END IF;

      IF p_item_number_6 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number/status/p_upd_mode:'||p_base_id||'/'||p_item_number_6||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_6, ln_item_cnt, p_person_id, p_status_6,p_upd_mode);
      END IF;

      IF p_item_number_7 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number/status/p_upd_mode:'||p_base_id||'/'||p_item_number_7||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_7, ln_item_cnt, p_person_id, p_status_7,p_upd_mode);
      END IF;

      IF p_item_number_8 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number/status/p_upd_mode:'||p_base_id||'/'||p_item_number_8||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_8, ln_item_cnt, p_person_id, p_status_8,p_upd_mode);
      END IF;

      IF p_item_number_9 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number/status/p_upd_mode:'||p_base_id||'/'||p_item_number_9||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_9, ln_item_cnt, p_person_id, p_status_9,p_upd_mode);
      END IF;

      IF p_item_number_10 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number/status/p_upd_mode:'||p_base_id||'/'||p_item_number_10||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_10, ln_item_cnt, p_person_id, p_status_10,p_upd_mode);
      END IF;

      IF p_item_number_11 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number/status/p_upd_mode:'||p_base_id||'/'||p_item_number_11||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_11, ln_item_cnt, p_person_id, p_status_11,p_upd_mode);
      END IF;

      IF p_item_number_12 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number/status/p_upd_mode:'||p_base_id||'/'||p_item_number_12||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_12, ln_item_cnt, p_person_id, p_status_12,p_upd_mode);
      END IF;

      IF p_item_number_13 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number/status/p_upd_mode:'||p_base_id||'/'||p_item_number_13||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_13, ln_item_cnt, p_person_id, p_status_13,p_upd_mode);
      END IF;

      IF p_item_number_14 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number/status/p_upd_mode:'||p_base_id||'/'||p_item_number_14||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_14, ln_item_cnt, p_person_id, p_status_14,p_upd_mode);
      END IF;

      IF p_item_number_15 IS NOT NULL THEN
        ln_item_cnt := ln_item_cnt + 1;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','ln_item_cnt:'||ln_item_cnt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling add_to_do with base_id/p_item_number/status/p_upd_mode:'||p_base_id||'/'||p_item_number_15||'/'||p_status_1||'/'||p_upd_mode);
        END IF;
        add_to_do( p_base_id, p_item_number_15, ln_item_cnt, p_person_id, p_status_15,p_upd_mode);
      END IF;

      FND_MESSAGE.SET_NAME('IGF', 'IGF_AP_TODO_ADDED');
      FND_MESSAGE.SET_TOKEN('COUNT',  TO_CHAR(ln_item_cnt-ln_skip_items));
      FND_FILE.PUT_LINE(FND_FILE.LOG ,FND_MESSAGE.GET);
      FND_FILE.PUT_LINE(FND_FILE.LOG ,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG ,' ');

      -- Update the FA Process Stauses with the TO DO Details
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.each_student_todo.debug','calling igf_ap_batch_ver_prc_pkg.update_process_status');
      END IF;
      igf_ap_batch_ver_prc_pkg.update_process_status(p_base_id, NULL);

    EXCEPTION
      WHEN others THEN
      FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_TODO_GRPS_PRC_PKG.EACH_STUDENT_TODO');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;

    END each_student_todo;  -- End of each_student_todo

  BEGIN -- Begin of assign_todo

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.assign_todo.debug','entering assign_todo');
    END IF;
    -- If both Person and Person ID Group are present then return back false
    IF p_base_id IS NOT NULL AND p_person_id_grp IS NOT NULL THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_NO_PERS_PGRP');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      RETURN FALSE;

    ELSIF p_base_id IS NULL AND p_person_id_grp IS NULL THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_PRS_PRSIDGRP_NULL');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      RETURN FALSE;

    ELSE

      -- Add To DO to the person if base id is present
      -- else, get the base id from the person id groups and then add TO Do for each student.
      IF p_base_id IS NOT NULL THEN

        -- log a message for the processing student.
        OPEN c_person_details(p_base_id);
        FETCH c_person_details INTO lc_person_details_rec;
        CLOSE c_person_details;
        IF p_calling_from = 'TODO' THEN
          FND_MESSAGE.SET_NAME('IGF','IGF_AP_PROCESSING_STUDENT');
          FND_MESSAGE.SET_TOKEN('PERSON_NAME',lc_person_details_rec.person_name);
          FND_MESSAGE.SET_TOKEN('PERSON_NUMBER',lc_person_details_rec.person_number);
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.assign_todo.debug','calling each_student_todo for base_id:'||p_base_id);
        END IF;
        -- Process the student, add TO DO to the students
        each_student_todo(p_base_id, lc_person_details_rec.person_id );

      ELSIF p_person_id_grp IS NOT NULL THEN

        --Bug #5021084. Passing Group ID if the group type is STATIC.
        IF lv_group_type = 'STATIC' THEN
          -- Get all the Active students from the Person Group
          OPEN c_person_id_grp  FOR 'SELECT person_id,person_number,full_name
                                        FROM igs_pe_person_base_v
                                        WHERE person_id in ('||lv_sql_stmt||') ' USING  p_person_id_grp;
        ELSIF lv_group_type = 'DYNAMIC' THEN
          -- Get all the Active students from the Person Group
          OPEN c_person_id_grp  FOR 'SELECT person_id,person_number,full_name
                                        FROM igs_pe_person_base_v
                                        WHERE person_id in ('||lv_sql_stmt||')';
        END IF;

        LOOP

          -- Check whether the student exists in the FA System, If present assign all TO Dos to the person, Else skip the student and mention the log message

          FETCH c_person_id_grp INTO c_person_id_grp_rec;
          EXIT WHEN c_person_id_grp%NOTFOUND;

          OPEN c_fa_base( c_person_id_grp_rec.person_id, p_awd_cal_type, p_awd_seq_num);
          FETCH c_fa_base INTO ln_base_id;
          IF c_fa_base%NOTFOUND THEN

            OPEN c_get_parameters;
            FETCH c_get_parameters INTO l_person_number;
            CLOSE c_get_parameters;
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_person_number|| ' : '|| c_person_id_grp_rec.person_number);

            -- Log a message and skip the student
            FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_BASEID');
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          ELSE

            -- log a message for the processing student.
            IF p_calling_from = 'TODO' THEN
              FND_MESSAGE.SET_NAME('IGF','IGF_AP_PROCESSING_STUDENT');
              FND_MESSAGE.SET_TOKEN('PERSON_NAME',c_person_id_grp_rec.full_name);
              FND_MESSAGE.SET_TOKEN('PERSON_NUMBER',c_person_id_grp_rec.person_number);
              FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            END IF;

            -- Process the student, add TO DO to the students
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.assign_todo.debug','calling each_student_todo for base_id:'||p_base_id);
            END IF;
            each_student_todo(ln_base_id, c_person_id_grp_rec.person_id);
          END IF;
          CLOSE c_fa_base;

        END LOOP;  -- Person ID Group Loop

      END IF;
      RETURN TRUE;
    END IF;  -- End of check for both Person and Person ID Group

  EXCEPTION
    WHEN others THEN
      FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_TODO_GRPS_PRC_PKG.ASSIGN_TODO');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END assign_todo;


  PROCEDURE main(
                 errbuf            OUT NOCOPY VARCHAR2,
                 retcode           OUT NOCOPY NUMBER,
                 p_award_year      IN  VARCHAR2,
                 p_person_id_grp   IN  NUMBER,
                 p_base_id         IN  NUMBER,
                 p_upd_mode        IN  VARCHAR2,
                 p_item_1          IN  NUMBER,
                 p_status_1        IN  VARCHAR2 DEFAULT NULL,
                 p_item_2          IN  NUMBER,
                 p_status_2        IN  VARCHAR2 DEFAULT NULL,
                 p_item_3          IN  NUMBER,
                 p_status_3        IN  VARCHAR2 DEFAULT NULL,
                 p_item_4          IN  NUMBER,
                 p_status_4        IN  VARCHAR2 DEFAULT NULL,
                 p_item_5          IN  NUMBER,
                 p_status_5        IN  VARCHAR2 DEFAULT NULL,
                 p_item_6          IN  NUMBER,
                 p_status_6        IN  VARCHAR2 DEFAULT NULL,
                 p_item_7          IN  NUMBER,
                 p_status_7        IN  VARCHAR2 DEFAULT NULL,
                 p_item_8          IN  NUMBER,
                 p_status_8        IN  VARCHAR2 DEFAULT NULL,
                 p_item_9          IN  NUMBER,
                 p_status_9        IN  VARCHAR2 DEFAULT NULL,
                 p_item_10         IN  NUMBER,
                 p_status_10       IN  VARCHAR2 DEFAULT NULL,
                 p_item_11         IN  NUMBER,
                 p_status_11       IN  VARCHAR2 DEFAULT NULL,
                 p_item_12         IN  NUMBER,
                 p_status_12       IN  VARCHAR2 DEFAULT NULL,
                 p_item_13         IN  NUMBER,
                 p_status_13       IN  VARCHAR2 DEFAULT NULL,
                 p_item_14         IN  NUMBER,
                 p_status_14       IN  VARCHAR2 DEFAULT NULL,
                 p_item_15         IN  NUMBER,
                 p_status_15       IN  VARCHAR2 DEFAULT NULL
                ) IS
    /*
    ||  Created By : brajendr
    ||  Created On : 23-Sep-2002
    ||  Purpose : Main process, does the main processing.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  ridas          07-Feb-2006      Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
    ||  tsailaja       13/Jan/2006      Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    ||  bvisvana       21-Jun-2005      Signature of main is changed to include status from 1 to 15
    ||                                  log_input_params and assign_todo signature changed
    ||  (reverse chronological order - newest change first)
    */

    lv_ci_sequence_number  igf_ap_fa_base_rec_all.ci_sequence_number%TYPE;
    lv_ci_cal_type         igf_ap_fa_base_rec_all.ci_cal_type%TYPE;
    lb_return_value        BOOLEAN := FALSE;
    ln_stdnt_count         NUMBER := 0;

 /* Variables for the dynamic person id group */
    lv_status         VARCHAR2(1) := 'S';  /*Defaulted to 'S' and the function will return 'F' in case of failure */
    lv_group_type     igs_pe_persid_group_v.group_type%TYPE;
    lv_sql_stmt       VARCHAR(32767) := igf_ap_ss_pkg.get_pid(p_person_id_grp,lv_status,lv_group_type);

  BEGIN
  igf_aw_gen.set_org_id(NULL);
    retcode := 0;

    -- Get the Award Year Calender Type and the Sequence Number for processing the students in context with the given Award Year.
    lv_ci_cal_type        := RTRIM(SUBSTR(p_award_year,1,10));
    lv_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_award_year,11)));

    -- Log Input Parameters
    log_input_params(
                     lv_ci_cal_type, lv_ci_sequence_number, p_base_id, p_person_id_grp,p_upd_mode,
                     p_item_1,  p_status_1, p_item_2, p_status_2,
                     p_item_3,  p_status_3, p_item_4, p_status_4,
                     p_item_5,  p_status_5, p_item_6, p_status_6,
                     p_item_7,  p_status_7, p_item_8, p_status_8,
                     p_item_9,  p_status_9, p_item_10, p_status_10,
                     p_item_11, p_status_11, p_item_12, p_status_12,
                     p_item_13, p_status_13, p_item_14, p_status_14,
                     p_item_15, p_status_15
                    );

    -- If Person ID Group and Person ID both are present then, exit the process stating that either of the one should be present.
    IF p_base_id IS NOT NULL AND p_person_id_grp IS NOT NULL THEN
        errbuf:= FND_MESSAGE.GET_STRING('IGS','IGS_FI_NO_PERS_PGRP');
        retcode := 2;
        RETURN;
    ELSIF p_base_id IS NULL AND p_person_id_grp IS NULL THEN
        errbuf:= FND_MESSAGE.GET_STRING('IGS','IGS_FI_PRS_PRSIDGRP_NULL');
        retcode := 2;
        RETURN;
    END IF;

    -- Check whether the Person Groups has some records, if no students were attached to the student then log the message

    IF  p_person_id_grp IS NOT NULL THEN

      /* Changing the string to get the count only*/

      BEGIN
        lv_sql_stmt := 'SELECT COUNT(1) FROM ( '||lv_sql_stmt||')';

        --Bug #5021084. Passing Group ID if the group type is STATIC.
        IF lv_group_type = 'STATIC' THEN
          EXECUTE IMMEDIATE lv_sql_stmt INTO ln_stdnt_count USING p_person_id_grp;
        ELSIF lv_group_type = 'DYNAMIC' THEN
          EXECUTE IMMEDIATE lv_sql_stmt INTO ln_stdnt_count;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME ('IGF','IGF_AP_INVALID_QUERY');
            FND_FILE.PUT_LINE (FND_FILE.LOG,FND_MESSAGE.GET);
            RETURN;
    END;

        IF ln_stdnt_count = 0 THEN
            FND_MESSAGE.SET_NAME('IGF','IGF_DB_NO_PER_GRP');
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            retcode := 0;
            RETURN;
        END IF;
     END IF;

    -- Assign TODO for all the students
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_todo_grps_prc_pkg.main.debug','calling assgin_todo');
    END IF;
    lb_return_value := assign_todo(
                 p_base_id, p_person_id_grp, lv_ci_cal_type, lv_ci_sequence_number,p_upd_mode,
                 p_item_1,  p_status_1, p_item_2, p_status_2,
                 p_item_3,  p_status_3, p_item_4, p_status_4,
                 p_item_5,  p_status_5, p_item_6, p_status_6,
                 p_item_7,  p_status_7, p_item_8, p_status_8,
                 p_item_9,  p_status_9, p_item_10, p_status_10,
                 p_item_11, p_status_11, p_item_12, p_status_12,
                 p_item_13, p_status_13, p_item_14, p_status_14,
                 p_item_15, p_status_15, 'TODO' );

    -- If Person ID Group and Person ID both are present then, exit the process stating that either of the one should be present.
    IF lb_return_value = FALSE THEN
      IF p_base_id IS NOT NULL AND p_person_id_grp IS NOT NULL THEN
        errbuf:= FND_MESSAGE.GET_STRING('IGS','IGS_FI_NO_PERS_PGRP');
        retcode := 2;
        RETURN;
      ELSIF p_base_id IS NULL AND p_person_id_grp IS NULL THEN
        errbuf:= FND_MESSAGE.GET_STRING('IGS','IGS_FI_PRS_PRSIDGRP_NULL');
        retcode := 2;
        RETURN;
      END IF;
    END IF;
  EXCEPTION
    WHEN others THEN
      ROLLBACK;
      FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
      RETCODE := 2 ;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_TODO_GRPS_PRC_PKG.MAIN');
      errbuf := FND_MESSAGE.GET ;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL ;
  END main;


END igf_ap_todo_grps_prc_pkg;

/
