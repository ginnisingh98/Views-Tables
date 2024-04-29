--------------------------------------------------------
--  DDL for Package Body IGF_AP_VER_GRPS_PRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_VER_GRPS_PRC_PKG" AS
/* $Header: IGFAP29B.pls 120.5 2006/04/20 02:59:03 veramach ship $ */

  lb_return_value    BOOLEAN := FALSE;

  PROCEDURE log_input_params( p_awd_cal_type      IN  igs_ca_inst.cal_type%TYPE                    ,
                              p_awd_seq_num       IN  igs_ca_inst.sequence_number%TYPE             ,
                              p_base_id           IN  igf_ap_fa_base_rec_all.base_id%TYPE          ,
                              p_prs_grp_id        IN  VARCHAR2                                     ,
                              p_isir_field        IN  igf_ap_inst_ver_item.isir_map_col%TYPE       ,
                              p_item_number_1     IN  igf_ap_td_item_mst_all.todo_number%TYPE      ,
                              p_item_number_2     IN  igf_ap_td_item_mst_all.todo_number%TYPE      ,
                              p_item_number_3     IN  igf_ap_td_item_mst_all.todo_number%TYPE      ,
                              p_item_number_4     IN  igf_ap_td_item_mst_all.todo_number%TYPE      ,
                              p_item_number_5     IN  igf_ap_td_item_mst_all.todo_number%TYPE      ,
                              p_item_number_6     IN  igf_ap_td_item_mst_all.todo_number%TYPE      ,
                              p_item_number_7     IN  igf_ap_td_item_mst_all.todo_number%TYPE      ,
                              p_item_number_8     IN  igf_ap_td_item_mst_all.todo_number%TYPE      ,
                              p_item_number_9     IN  igf_ap_td_item_mst_all.todo_number%TYPE      ,
                              p_item_number_10    IN  igf_ap_td_item_mst_all.todo_number%TYPE      ,
                              p_item_number_11    IN  igf_ap_td_item_mst_all.todo_number%TYPE      ,
                              p_item_number_12    IN  igf_ap_td_item_mst_all.todo_number%TYPE      ,
                              p_item_number_13    IN  igf_ap_td_item_mst_all.todo_number%TYPE      ,
                              p_item_number_14    IN  igf_ap_td_item_mst_all.todo_number%TYPE      ,
                              p_item_number_15    IN  igf_ap_td_item_mst_all.todo_number%TYPE
                            ) AS
    /*
    ||  Created By : masehgal
    ||  Created On : 26-Sep-2002
    ||  Purpose    : Logs all the Input Parameters
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    --Cursor to find the User Parameter Award Year (which is same as Alternate Code) to display in the Log
    CURSOR c_alternate_code( cp_ci_cal_type         igs_ca_inst.cal_type%TYPE         ,
                             cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE
                           ) IS
       SELECT alternate_code
       FROM   igs_ca_inst
       WHERE  cal_type        = cp_ci_cal_type
       AND    sequence_number = cp_ci_sequence_number ;

    CURSOR c_get_parameters ( cp_lkup_type  VARCHAR2 ) IS
       SELECT meaning, lookup_code
       FROM   igf_lookups_view
       WHERE  lookup_type  = cp_lkup_type
       AND    lookup_code IN ('AWARD_YEAR','PERSON_NUMBER','PERSON_ID_GROUP','ITEM_CODE',
                              'PARAMETER_PASS','ISIR_FIELD') ;
    l_lkup_type   VARCHAR2(60) ;

    -- Get the details of Item codes and its descritpions
    CURSOR c_item_details( cp_todo_number   igf_ap_td_item_mst.todo_number%TYPE ) IS
       SELECT description
       FROM   igf_ap_td_item_mst
       WHERE  todo_number = cp_todo_number ;

    -- Get Verification Item Descrition
    CURSOR c_get_verif_item (cp_ci_cal_type         igs_ca_inst.cal_type%TYPE ,
                             cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE ,
                             cp_isir_field          igf_ap_inst_ver_item.isir_map_col%TYPE,
                             cp_lkup_type           VARCHAR2 )  IS
       SELECT lkup.meaning   meaning
         FROM igf_ap_batch_aw_map  map,
              Igf_fc_sar_cd_mst    sar ,
              igf_lookups_view     lkup
        WHERE map.ci_cal_type        = cp_ci_cal_type
          AND map.ci_sequence_number = cp_ci_sequence_number
          AND sar.sys_award_year     = map.sys_award_year
          AND sar.sar_field_name     = cp_isir_field
          AND lkup.lookup_type       = cp_lkup_type
          AND lkup.lookup_code       = sar.sar_field_name
          AND lkup.enabled_flag      = 'Y'  ;

    -- Get the person_number
    CURSOR c_person_number( cp_base_id        IN  igf_ap_fa_base_rec_all.base_id%TYPE ) IS
       SELECT pe.person_number
       FROM   igs_pe_person_base_v pe,
              igf_ap_fa_base_rec_all fa
       WHERE  pe.person_id = fa.person_id
       AND    fa.base_id = cp_base_id;

    -- Get the details of group
    CURSOR c_person_group( cp_person_id_grp   IN  igs_pe_persid_group_all.group_id%TYPE ) IS
    SELECT description
      FROM igs_pe_persid_group
     WHERE group_id = cp_person_id_grp;

    -- Get Item Description
    CURSOR c_item_descrption( cp_item_number  IN  igf_ap_td_item_mst_all.todo_number%TYPE ) IS
       SELECT description
       FROM   igf_ap_td_item_mst_all
       WHERE  todo_number = cp_item_number;


    parameter_rec              c_get_parameters%ROWTYPE ;
    verif_item_pmpt_rec        c_get_verif_item%ROWTYPE ;
    lc_item_description        igf_ap_td_item_mst.description%TYPE ;
    lv_awd_alternate_code      igs_ca_inst.alternate_code%TYPE ;
    lv_isir_field              igf_lookups_view.meaning%TYPE ;
    lv_incl_in_tol             igf_lookups_view.meaning%TYPE ;

    lv_award_year_pmpt         igf_lookups_view.meaning%TYPE ;
    lv_person_number_pmpt      igf_lookups_view.meaning%TYPE ;
    lv_person_id_grp_pmpt      igf_lookups_view.meaning%TYPE ;
    lv_item_code_pmpt          igf_lookups_view.meaning%TYPE ;
    lv_isir_field_pmpt         igf_lookups_view.meaning%TYPE ;
    l_para_pass                igf_lookups_view.meaning%TYPE ;

    l_person_number            igs_pe_person_base_v.person_number%TYPE;
    l_group_desc               igs_pe_persid_group_all.description%TYPE;
    l_item_description         igf_ap_td_item_mst_all.description%TYPE;


  BEGIN

    -- Set all the Prompts for the Input Parameters
    l_lkup_type := 'IGF_GE_PARAMETERS' ;
    OPEN c_get_parameters (l_lkup_type );
    LOOP
     FETCH c_get_parameters INTO  parameter_rec ;
     EXIT WHEN c_get_parameters%NOTFOUND ;

     IF parameter_rec.lookup_code ='AWARD_YEAR' THEN
       lv_award_year_pmpt := TRIM ( parameter_rec.meaning ) ;

     ELSIF parameter_rec.lookup_code ='PERSON_NUMBER' THEN
       lv_person_number_pmpt := TRIM ( parameter_rec.meaning );

     ELSIF parameter_rec.lookup_code ='PERSON_ID_GROUP' THEN
       lv_person_id_grp_pmpt := TRIM ( parameter_rec.meaning );

     ELSIF parameter_rec.lookup_code ='ITEM_CODE' THEN
       lv_item_code_pmpt := TRIM ( parameter_rec.meaning ) ;

     ELSIF parameter_rec.lookup_code ='ISIR_FIELD' THEN
       lv_isir_field_pmpt := TRIM ( parameter_rec.meaning ) ;

     ELSIF parameter_rec.lookup_code ='PARAMETER_PASS' THEN
       l_para_pass := TRIM ( parameter_rec.meaning ) ;

     END IF;

    END LOOP;
    CLOSE c_get_parameters ;

    -- Get the Award Year Alternate Code
    OPEN c_alternate_code( p_awd_cal_type, p_awd_seq_num ) ;
    FETCH c_alternate_code INTO lv_awd_alternate_code ;
    CLOSE c_alternate_code ;

        -- Get the Person Number
    OPEN c_person_number(p_base_id);
    FETCH c_person_number INTO l_person_number;
    CLOSE c_person_number;

    -- Get the Person Group
    OPEN c_person_group(p_prs_grp_id);
    FETCH c_person_group INTO l_group_desc;
    CLOSE c_person_group;

    -- Get verification item meaning
    l_lkup_type := 'IGF_AP_SAR_FIELD_MAP' ;
    OPEN  c_get_verif_item( p_awd_cal_type,
                            p_awd_seq_num,
                            p_isir_field,
                            l_lkup_type ) ;
    FETCH c_get_verif_item INTO verif_item_pmpt_rec ;
    lv_isir_field := verif_item_pmpt_rec.meaning ;
    CLOSE c_get_verif_item ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ') ;
    FND_FILE.PUT_LINE( FND_FILE.LOG, l_para_pass) ; --------------Parameters Passed--------------
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ') ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( lv_award_year_pmpt, 40)    || ' : '|| lv_awd_alternate_code ) ;
    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( lv_person_number_pmpt, 40) || ' : '|| l_person_number ) ;
    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( lv_person_id_grp_pmpt, 40) || ' : '|| l_group_desc ) ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( lv_isir_field_pmpt, 40) || ' : '|| lv_isir_field ) ;

    l_item_description := NULL;
    IF p_item_number_1 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_1);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 1',  40) || ' : ' || l_item_description );

    l_item_description := NULL;
    IF p_item_number_2 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_2);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 2',  40) || ' : ' || l_item_description );

    l_item_description := NULL;
    IF p_item_number_3 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_3);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 3',  40) || ' : ' || l_item_description );

    l_item_description := NULL;
    IF p_item_number_4 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_4);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 4',  40) || ' : ' || l_item_description );

    l_item_description := NULL;
    IF p_item_number_5 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_5);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 5',  40) || ' : ' || l_item_description );

    l_item_description := NULL;
    IF p_item_number_6 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_6);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 6',  40) || ' : ' || l_item_description );

    l_item_description := NULL;
    IF p_item_number_7 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_7);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 7',  40) || ' : ' || l_item_description );

    l_item_description := NULL;
    IF p_item_number_8 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_8);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 8',  40) || ' : ' || l_item_description );

    l_item_description := NULL;
    IF p_item_number_9 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_9);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 9',  40) || ' : ' || l_item_description );

    l_item_description := NULL;
    IF p_item_number_10 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_10);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 10',  40) || ' : ' || l_item_description );

    l_item_description := NULL;
    IF p_item_number_11 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_11);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 11',  40) || ' : ' || l_item_description );

    l_item_description := NULL;
    IF p_item_number_12 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_12);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 12',  40) || ' : ' || l_item_description );

    l_item_description := NULL;
    IF p_item_number_13 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_13);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 13',  40) || ' : ' || l_item_description );

    l_item_description := NULL;
    IF p_item_number_14 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_14);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 14',  40) || ' : ' || l_item_description );

    l_item_description := NULL;
    IF p_item_number_15 IS NOT NULL THEN
      OPEN c_item_descrption(p_item_number_15);
      FETCH c_item_descrption INTO l_item_description;
      CLOSE c_item_descrption;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(lv_item_code_pmpt || ' 15',  40) || ' : ' || l_item_description );

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE( FND_FILE.LOG, '-------------------------------------------------------------');
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END log_input_params ;


  FUNCTION dup_ver_item ( p_base_id     IN  igf_ap_fa_base_rec_all.base_id%TYPE    ,
                          p_isir_field  IN  igf_ap_inst_ver_item.isir_map_col%TYPE
                        ) RETURN BOOLEAN AS

    /*
    ||  Created By : masehgal
    ||  Created On : 26-Sep-2002
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

  -- cursor to select existing record from igf_ap_inst_ver_item for a particular base_id and isir_map_col
  CURSOR c_ver_item_exists ( cp_base_id     igf_ap_inst_ver_item.base_id%TYPE      ,
                             cp_isir_field  igf_ap_inst_ver_item.isir_map_col%TYPE
                            ) IS
     SELECT 1
     FROM   igf_ap_inst_ver_item
     WHERE  base_id      = cp_base_id
     AND    isir_map_col = cp_isir_field ;

     ver_item_exists_rec   c_ver_item_exists%ROWTYPE ;
     lv_ver_item_exists    NUMBER ;

  BEGIN
     -- open cursor for given base id and isir_field
     OPEN  c_ver_item_exists ( p_base_id , p_isir_field ) ;
     FETCH c_ver_item_exists INTO lv_ver_item_exists ;
     IF c_ver_item_exists%FOUND THEN
        CLOSE c_ver_item_exists ;
        RETURN TRUE ;
     ELSE
        CLOSE c_ver_item_exists ;
        RETURN FALSE ;
     END IF ;

   EXCEPTION
     WHEN OTHERS THEN
        CLOSE c_ver_item_exists ;
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP') ;
        IGS_GE_MSG_STACK.ADD ;

        RETURN TRUE ;
   END ;



  FUNCTION add_ver_item(
                         p_base_id           IN  igf_ap_fa_base_rec_all.base_id%TYPE         ,
                         p_awd_cal_type      IN  igs_ca_inst.cal_type%TYPE                   ,
                         p_awd_seq_num       IN  igs_ca_inst.sequence_number%TYPE            ,
                         p_isir_field        IN  igf_ap_inst_ver_item.isir_map_col%TYPE      ,
                         p_item_number_1     IN  igf_ap_td_item_mst_all.todo_number%TYPE     ,
                         p_item_number_2     IN  igf_ap_td_item_mst_all.todo_number%TYPE     ,
                         p_item_number_3     IN  igf_ap_td_item_mst_all.todo_number%TYPE     ,
                         p_item_number_4     IN  igf_ap_td_item_mst_all.todo_number%TYPE     ,
                         p_item_number_5     IN  igf_ap_td_item_mst_all.todo_number%TYPE     ,
                         p_item_number_6     IN  igf_ap_td_item_mst_all.todo_number%TYPE     ,
                         p_item_number_7     IN  igf_ap_td_item_mst_all.todo_number%TYPE     ,
                         p_item_number_8     IN  igf_ap_td_item_mst_all.todo_number%TYPE     ,
                         p_item_number_9     IN  igf_ap_td_item_mst_all.todo_number%TYPE     ,
                         p_item_number_10    IN  igf_ap_td_item_mst_all.todo_number%TYPE     ,
                         p_item_number_11    IN  igf_ap_td_item_mst_all.todo_number%TYPE     ,
                         p_item_number_12    IN  igf_ap_td_item_mst_all.todo_number%TYPE     ,
                         p_item_number_13    IN  igf_ap_td_item_mst_all.todo_number%TYPE     ,
                         p_item_number_14    IN  igf_ap_td_item_mst_all.todo_number%TYPE     ,
                         p_item_number_15    IN  igf_ap_td_item_mst_all.todo_number%TYPE
                        ) RETURN BOOLEAN AS
    /*
    ||  Created By : masehgal
    ||  Created On : 26-Sep-2002
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  rasahoo         17-Oct-2003     #3085558  FA121 Added parameter use_blank_flag in
    ||                                  igf_ap_inst_ver_item_pkg.insert_row
    ||  masehgal        21-May-2003     #2885882  FACR113 SAR Updates
    ||                                  Changed cursors for SAR Number updates
    ||  masehgal        22-Oct-2002     Added message to show duplicate ver item rather
    ||                                  than eding the process as an error
    ||  (reverse chronological order - newest change first)
    */

      lv_rowid             ROWID   := NULL ;
      lv_meaning           igf_lookups_view.meaning%TYPE;
      l_isir_map_col       igf_fc_sar_cd_mst.sar_field_number%TYPE;
      CURSOR cur_isir_desc (cp_base_id     igf_ap_fa_base_rec.base_id%TYPE ,
                            lv_isir_field  igf_ap_inst_ver_item.isir_map_col%TYPE,
                            cp_lkup_type   VARCHAR2 )  IS
         SELECT sar.sar_field_number isir_map_col, lkup.meaning  meaning
           FROM igf_ap_batch_aw_map    map,
                igf_ap_fa_base_rec_all fabase,
                Igf_fc_sar_cd_mst      sar ,
                igf_lookups_view       lkup
          WHERE fabase.base_id         = p_base_id
            AND map.ci_cal_type        = fabase.ci_cal_type
            AND map.ci_sequence_number = fabase.ci_sequence_number
            AND sar.sys_award_year     = map.sys_award_year
            AND sar.sar_field_name     = lv_isir_field
            AND lkup.lookup_type       = cp_lkup_type
            AND lkup.lookup_code       = sar.sar_field_name
            AND lkup.enabled_flag      = 'Y'  ;

            l_lkup_type   VARCHAR2(60) ;

  BEGIN

      -- Check whether a person_id has been passed or not
      IF p_base_id IS NOT NULL THEN

           l_lkup_type := 'IGF_AP_SAR_FIELD_MAP' ;
           OPEN  cur_isir_desc (p_base_id, p_isir_field, l_lkup_type);
           FETCH cur_isir_desc INTO l_isir_map_col, lv_meaning;
           CLOSE cur_isir_desc;

        -- check for dup_ver_item
        IF NOT (dup_ver_item ( p_base_id     =>  p_base_id ,
                               p_isir_field  =>  l_isir_map_col ) ) THEN

            -- Insert in IGF_AP_INST_VER_ITEM Table
                igf_ap_inst_ver_item_pkg.insert_row
                    (
                      X_ROWID                       => lv_rowid ,
                      X_BASE_ID                     => p_base_id ,
                      X_UDF_VERN_ITEM_SEQ_NUM       => NULL ,
                      X_ITEM_VALUE                  => NULL ,
                      X_WAIVE_FLAG                  => 'N' ,
                      X_INCL_IN_TOLERANCE           => NULL ,
                      X_ISIR_MAP_COL                => l_isir_map_col ,
                      x_legacy_record_flag          => NULL ,
                      x_use_blank_flag              => NULL,
                      X_MODE                        => 'R'
                    );

                 IF (
                    (p_item_number_1 IS NOT NULL) OR
                    (p_item_number_2 IS NOT NULL) OR
                    (p_item_number_3 IS NOT NULL) OR
                    (p_item_number_4 IS NOT NULL) OR
                    (p_item_number_5 IS NOT NULL) OR
                    (p_item_number_6 IS NOT NULL) OR
                    (p_item_number_7 IS NOT NULL) OR
                    (p_item_number_8 IS NOT NULL) OR
                    (p_item_number_9 IS NOT NULL) OR
                    (p_item_number_10 IS NOT NULL) OR
                    (p_item_number_11 IS NOT NULL) OR
                    (p_item_number_12 IS NOT NULL) OR
                    (p_item_number_13 IS NOT NULL) OR
                    (p_item_number_14 IS NOT NULL) OR
                    (p_item_number_15 IS NOT NULL) )
                  THEN


                    -- Insert To Do Items in IGF_AP_TD_ITEM_INST
                     lb_return_value := igf_ap_todo_grps_prc_pkg.assign_todo (
                                p_base_id         => p_base_id ,
                                p_person_id_grp   => NULL ,
                                p_awd_cal_type    => p_awd_cal_type ,
                                p_awd_seq_num     => p_awd_seq_num ,
                                p_upd_mode        => 'DO_NO_UPD',
                                p_item_number_1   => p_item_number_1 ,
                                p_item_number_2   => p_item_number_2 ,
                                p_item_number_3   => p_item_number_3 ,
                                p_item_number_4   => p_item_number_4 ,
                                p_item_number_5   => p_item_number_5 ,
                                p_item_number_6   => p_item_number_6 ,
                                p_item_number_7   => p_item_number_7 ,
                                p_item_number_8   => p_item_number_8 ,
                                p_item_number_9   => p_item_number_9 ,
                                p_item_number_10  => p_item_number_10 ,
                                p_item_number_11  => p_item_number_11 ,
                                p_item_number_12  => p_item_number_12 ,
                                p_item_number_13  => p_item_number_13 ,
                                p_item_number_14  => p_item_number_14 ,
                                p_item_number_15  => p_item_number_15 ,
                                p_calling_from    => 'VER_ITEM'
                                ) ;

                 END IF;

          -- If there are no to do items required for application complete, then update the application process status.
          -- Bug# 3240804 Whenever a new verification item gets added then update the fed_verifiation_status to 'SELECTED'
          igf_ap_batch_ver_prc_pkg.update_fed_verif_status(p_base_id,'SELECTED');

        ELSE

           FND_MESSAGE.SET_NAME('IGF','IGF_AP_VER_ITEM_PRESENT');
           FND_MESSAGE.SET_TOKEN('ITEM', lv_meaning);
           FND_FILE.PUT_LINE(FND_FILE.LOG ,FND_MESSAGE.GET);
        END IF ;
    END IF ;
    RETURN lb_return_value;

  EXCEPTION
    WHEN OTHERS THEN
     IF cur_isir_desc%ISOPEN THEN
        CLOSE cur_isir_desc;
     END IF;
     FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP') ;
     FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_ASSIGN_VER_ITEM_PKG.ADD_VER_ITEM') ;
     IGS_GE_MSG_STACK.ADD ;
     APP_EXCEPTION.RAISE_EXCEPTION ;
  END add_ver_item ;


  PROCEDURE main(
                 errbuf              OUT NOCOPY VARCHAR2,
                 retcode             OUT NOCOPY NUMBER,
                 p_awd_yr            IN  VARCHAR2,
                 p_prs_grp_id        IN  igs_pe_prsid_grp_mem.group_id%TYPE,
                 p_base_id           IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                 p_isir_field        IN  igf_ap_inst_ver_item.isir_map_col%TYPE,
                 p_item_1            IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                 p_item_2            IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                 p_item_3            IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                 p_item_4            IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                 p_item_5            IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                 p_item_6            IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                 p_item_7            IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                 p_item_8            IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                 p_item_9            IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                 p_item_10           IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                 p_item_11           IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                 p_item_12           IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                 p_item_13           IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                 p_item_14           IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                 p_item_15           IN  igf_ap_td_item_mst_all.todo_number%TYPE
                ) IS
    /*
    ||  Created By : masehgal
    ||  Created On : 26-Sep-2002
    ||  Purpose : Main process, does the main processing.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  ridas          07-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
    ||  tsailaja       13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    ||  (reverse chronological order - newest change first)
    */

        -- Get all Active persons from the given person_id_group.
 /* Variables for the dynamic person id group */
    lv_status         VARCHAR2(1) := 'S';  /*Defaulted to 'S' and the function will return 'F' in case of failure */
    lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

    lv_sql_stmt       VARCHAR(32767) := igf_ap_ss_pkg.get_pid(p_prs_grp_id,lv_status,lv_group_type);

    /* Variable to change the dynamic sql stmt and get the count */
    lv_sql_cnt   VARCHAR(32767) ;

   TYPE c_person_id_grpCurTyp IS REF CURSOR ;
     c_person_id_grp c_person_id_grpCurTyp ;
   TYPE c_person_id_grp_recTyp IS RECORD (  person_id igs_pe_person_base_v.person_id%TYPE,  person_number igs_pe_person_base_v.person_number%TYPE,
                                            full_name igs_pe_person_base_v.full_name%TYPE );
     c_person_id_grp_rec c_person_id_grp_recTyp ;

    -- Check whether the sudent exists in the FA system or not.
    CURSOR c_fa_base( cp_person_id           igf_ap_fa_base_rec_all.person_id%TYPE           ,
                      cp_ci_cal_type         igf_ap_fa_base_rec_all.ci_cal_type%TYPE         ,
                      cp_ci_sequence_number  igf_ap_fa_base_rec_all.ci_sequence_number%TYPE
                    ) IS
      SELECT base_id
      FROM   igf_ap_fa_base_rec
      WHERE  person_id = cp_person_id
      AND    ci_cal_type = cp_ci_cal_type
      AND    ci_sequence_number = cp_ci_sequence_number ;


    -- Get the person number and person name with the person id.
    CURSOR c_person_details( cp_base_id   igf_ap_fa_base_rec_all.base_id%TYPE ) IS
      SELECT pe.person_number, pe.full_name, fa.person_id
      FROM   igf_ap_fa_base_rec fa, igs_pe_person_base_v pe
      WHERE  fa.base_id = cp_base_id
      AND    fa.person_id = pe.person_id;


    --- Get the Person Number prompt
    CURSOR c_get_parameters ( cp_lkup_type  VARCHAR2 ,
                              cp_lkup_code  VARCHAR2 ) IS
       SELECT meaning
       FROM  igf_lookups_view
       WHERE lookup_type = cp_lkup_type
       AND   lookup_code = cp_lkup_code ;
    l_lkup_type   VARCHAR2(30) ;
    l_lkup_code   VARCHAR2(30) ;

    lv_ci_sequence_number  igf_ap_fa_base_rec_all.ci_sequence_number%TYPE ;
    lv_ci_cal_type         igf_ap_fa_base_rec_all.ci_cal_type%TYPE ;
    lc_person_details_rec  c_person_details%ROWTYPE ;
    ln_base_id_rec         c_fa_base%ROWTYPE ;
    ln_base_id             igf_ap_fa_base_rec_all.base_id%TYPE ;
    ln_stdnt_count         NUMBER := 0;
    l_person_number        igf_lookups_view.meaning%TYPE;
    l_datatype             VARCHAR2(30);


  BEGIN
  igf_aw_gen.set_org_id(NULL);
    retcode := 0;
    -- Get the Award Year Calender Type and the Sequence Number
    -- for processing the students in context with the given Award Year.
    lv_ci_cal_type        := RTRIM(SUBSTR(p_awd_yr,1,10));
    lv_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_awd_yr,11)));


    -- Log Input Parameters
    log_input_params( lv_ci_cal_type, lv_ci_sequence_number, p_base_id, p_prs_grp_id,
                      p_isir_field, p_item_1, p_item_2,
                      p_item_3, p_item_4, p_item_5, p_item_6,
                      p_item_7, p_item_8, p_item_9, p_item_10,
                      p_item_11, p_item_12, p_item_13, p_item_14,
                      p_item_15
                    );
  IF p_isir_field IN ('DRN', 'FAA_ADJUSTMENT', 'PARENTS_EMAIL_ADDRESS_TXT', 'DEPENDENCY_OVERRIDE_IND') THEN
    return;
  END IF;
    -- If Person ID Group and Person ID both are present then,
    -- exit the process stating that either of the one should be present.
    IF p_base_id IS NOT NULL AND p_prs_grp_id IS NOT NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_FI_NO_PERS_PGRP');
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
       retcode := 2;
       errbuf  := FND_MESSAGE.GET_STRING('IGS','IGS_FI_NO_PERS_PGRP');
       RETURN ;


    ELSIF p_base_id IS NULL AND p_prs_grp_id IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_FI_PRS_PRSIDGRP_NULL');
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
       retcode := 2;
       errbuf  := FND_MESSAGE.GET_STRING('IGS','IGS_FI_PRS_PRSIDGRP_NULL');
       RETURN ;
    END IF;

  -- fnd_file.put_line(fnd_file.log, 'SQL Statement:'|| lv_sql_stmt);

    IF p_prs_grp_id IS NOT NULL THEN
      /* Changing the string to get the count only*/
      BEGIN
        lv_sql_cnt := 'SELECT COUNT(1) '||substr(lv_sql_stmt,instr(lv_sql_stmt,'FROM'));

        --Bug #5021084. Passing Group ID if the group type is STATIC.
        IF lv_group_type = 'STATIC' THEN
          EXECUTE IMMEDIATE lv_sql_cnt INTO ln_stdnt_count USING p_prs_grp_id;
        ELSIF lv_group_type = 'DYNAMIC' THEN
          EXECUTE IMMEDIATE lv_sql_cnt INTO ln_stdnt_count;
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
          retcode := 2;
          errbuf  := FND_MESSAGE.GET_STRING('IGF','IGF_DB_NO_PER_GRP');
          RETURN;
       END IF;
     END IF ;


     IF p_base_id IS NOT NULL THEN

           OPEN c_person_details(p_base_id);
           FETCH c_person_details INTO lc_person_details_rec;
           CLOSE c_person_details;

           FND_MESSAGE.SET_NAME('IGF','IGF_AP_PROCESSING_STUDENT');
           FND_MESSAGE.SET_TOKEN('PERSON_NAME', lc_person_details_rec.full_name);
           FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', lc_person_details_rec.person_number);
           FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

           -- process records
           -- Assign verification item for all the students

           lb_return_value := add_ver_item(
                 p_awd_cal_type           => lv_ci_cal_type,
                 p_awd_seq_num            => lv_ci_sequence_number,
                 p_base_id                => p_base_id,
                 p_isir_field             => p_isir_field,
                 p_item_number_1          => p_item_1,
                 p_item_number_2          => p_item_2,
                 p_item_number_3          => p_item_3,
                 p_item_number_4          => p_item_4,
                 p_item_number_5          => p_item_5,
                 p_item_number_6          => p_item_6,
                 p_item_number_7          => p_item_7,
                 p_item_number_8          => p_item_8,
                 p_item_number_9          => p_item_9,
                 p_item_number_10         => p_item_10,
                 p_item_number_11         => p_item_11,
                 p_item_number_12         => p_item_12,
                 p_item_number_13         => p_item_13,
                 p_item_number_14         => p_item_14,
                 p_item_number_15         => p_item_15
                );

     -- If person_grp_id is provided , loop for all persons, check for dup_ver_item for each person
     ELSIF p_prs_grp_id IS NOT NULL THEN

        --Bug #5021084. Passing Group ID if the group type is STATIC.
        IF lv_group_type = 'STATIC' THEN
            -- Get all the Active students from the Person Group
            OPEN c_person_id_grp  FOR 'SELECT person_id,person_number,full_name
                                    FROM igs_pe_person_base_v
                  WHERE person_id in ('||lv_sql_stmt||') ' USING p_prs_grp_id;
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

              -- Check whether the student exists in the FA System,
              -- If present assign all TO Dos to the person,
              -- Else skip the student and mention the log message
              -- log a message for the processing student.

              OPEN c_fa_base( c_person_id_grp_rec.person_id, lv_ci_cal_type, lv_ci_sequence_number ) ;
              FETCH c_fa_base INTO ln_base_id_rec ;

              IF c_fa_base%NOTFOUND THEN

               l_lkup_type := 'IGF_GE_PARAMETERS' ;
               l_lkup_code := 'PERSON_NUMBER' ;
               OPEN  c_get_parameters ( l_lkup_type, l_lkup_code ) ;
               FETCH c_get_parameters INTO l_person_number;
               CLOSE c_get_parameters;
               FND_FILE.PUT_LINE(FND_FILE.LOG,l_person_number|| ' : '|| c_person_id_grp_rec.person_number);

               -- Log a message and skip the student
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_BASEID');
               FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

              ELSE
                 ln_base_id := ln_base_id_rec.base_id ;

              OPEN c_person_details(ln_base_id);
              FETCH c_person_details INTO lc_person_details_rec;
              CLOSE c_person_details;
              FND_MESSAGE.SET_NAME('IGF','IGF_AP_PROCESSING_STUDENT');
              FND_MESSAGE.SET_TOKEN('PERSON_NAME', lc_person_details_rec.full_name);
              FND_MESSAGE.SET_TOKEN('PERSON_NUMBER', lc_person_details_rec.person_number);
              FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);


                 -- process records
                 -- Assign verification item for all the students
                 lb_return_value := add_ver_item(
             p_awd_cal_type           => lv_ci_cal_type,
             p_awd_seq_num            => lv_ci_sequence_number,
             p_base_id                => ln_base_id ,
             p_isir_field             => p_isir_field,
             p_item_number_1          => p_item_1,
             p_item_number_2          => p_item_2,
             p_item_number_3          => p_item_3,
             p_item_number_4          => p_item_4,
             p_item_number_5          => p_item_5,
             p_item_number_6          => p_item_6,
             p_item_number_7          => p_item_7,
             p_item_number_8          => p_item_8,
             p_item_number_9          => p_item_9,
             p_item_number_10         => p_item_10,
             p_item_number_11         => p_item_11,
             p_item_number_12         => p_item_12,
             p_item_number_13         => p_item_13,
             p_item_number_14         => p_item_14,
             p_item_number_15         => p_item_15
                            );

              END IF ;
              CLOSE c_fa_base ;
           END LOOP ;
     END IF ;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM) ;
      RETCODE := 2 ;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP') ;
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_ASSIGN_VER_ITEM_PKG.MAIN') ;
      errbuf := FND_MESSAGE.GET ;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL ;
  END main;


END  igf_ap_ver_grps_prc_pkg;

/
