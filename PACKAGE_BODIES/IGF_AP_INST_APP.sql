--------------------------------------------------------
--  DDL for Package Body IGF_AP_INST_APP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_INST_APP" AS
/* $Header: IGFAP50B.pls 120.0 2005/09/09 17:14:44 appldev noship $ */


  PROCEDURE update_ToDo_status(p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_application_code    igf_ap_appl_status_all.application_code%TYPE,
                              x_return_status       OUT NOCOPY VARCHAR2)
    IS
    ------------------------------------------------------------------
    --Created by  : upinjark, Oracle India
    --Date created: 04-Jul-2004
    --
    --Purpose:
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------

    --Cursor to fetch to do item
    CURSOR c_td_item (cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
             	      cp_application_code igf_ap_appl_status_all.application_code%TYPE)
                      IS
    SELECT tdmst.todo_number
      FROM igf_ap_td_item_inst_all tdinst, igf_ap_td_item_mst_all tdmst, Igf_ap_fa_base_rec_all baseRec
     WHERE tdmst.system_todo_type_code = 'INSTAPP'
       AND baseRec.ci_cal_type = tdmst.ci_cal_type
       AND baseRec.ci_sequence_number = tdmst.ci_sequence_number
       AND baseRec.base_id = tdinst.base_id
       AND tdmst.application_code = cp_application_code
       AND tdinst.item_sequence_number = tdmst.todo_number
       AND tdinst.base_id = cp_base_id;

    l_td_item c_td_item%ROWTYPE;

    l_todo_status VARCHAR(10) ;

  BEGIN
    x_return_status := 'F';
    l_todo_status := NULL ;
    --get the to do item sequence number
    OPEN c_td_item(p_base_id,p_application_code);
    FETCH c_td_item INTO l_td_item;
    CLOSE c_td_item;

    IF (l_td_item.todo_number IS NULL) THEN
        x_return_status := 'N' ;         -- for no To-Do item is available
    ELSE
        igf_ap_gen.update_td_status(
                                p_base_id                 => p_base_id ,
                                p_item_sequence_number    => l_td_item.todo_number ,
                                p_status                  => 'COM',
                                p_return_status           => l_todo_status
                                );

         IF(l_todo_status <> 'F') THEN
            x_return_status := 'T';           --- for successful updation of To-DO
         ELSE
            x_return_status := 'F';           --- for failure in updation of To-do
         END IF;
    END IF;

  EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := 'F';
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        igs_ge_msg_stack.add;

  END update_ToDo_status;

  PROCEDURE update_ToDo (p_base_id                igf_ap_fa_base_rec_all.base_id%TYPE,
                         p_application_code       igf_ap_appl_status_all.application_code%TYPE,
                         p_status              IN igf_ap_td_item_inst_all.status%TYPE,
                         x_return_status       OUT NOCOPY VARCHAR2)
    IS
    ------------------------------------------------------------------
    --Created by  : upinjark, Oracle India
    --Date created: 08-Aug-2004
    --
    --Purpose:
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------

    --Cursor to fetch to do item
    CURSOR c_td_item (cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
             	      cp_application_code igf_ap_appl_status_all.application_code%TYPE)
                      IS
    SELECT tdmst.todo_number
      FROM igf_ap_td_item_inst_all tdinst, igf_ap_td_item_mst_all tdmst, Igf_ap_fa_base_rec_all baseRec
     WHERE tdmst.system_todo_type_code = 'INSTAPP'
       AND baseRec.ci_cal_type = tdmst.ci_cal_type
       AND baseRec.ci_sequence_number = tdmst.ci_sequence_number
       AND baseRec.base_id = tdinst.base_id
       AND tdmst.application_code = cp_application_code
       AND tdinst.item_sequence_number = tdmst.todo_number
       AND tdinst.base_id = cp_base_id;

    l_td_item c_td_item%ROWTYPE;

    l_todo_status VARCHAR(10) ;

  BEGIN
    x_return_status := 'F';
    l_todo_status := NULL ;
    --get the to do item sequence number
    OPEN c_td_item(p_base_id,p_application_code);
    FETCH c_td_item INTO l_td_item;
    CLOSE c_td_item;

    IF (l_td_item.todo_number IS NULL) THEN
        x_return_status := 'N' ;         -- for no To-Do item is available
    ELSE
        igf_ap_gen.update_td_status(
                                    p_base_id                 => p_base_id ,
                                    p_item_sequence_number    => l_td_item.todo_number ,
                                    p_status                  => p_status,
                                    p_return_status           => l_todo_status
                                    );

         IF(l_todo_status <> 'F') THEN
            x_return_status := 'T';   --- for successful updation of To-DO
         ELSE
            x_return_status := 'F';   --- for failure in updation of To-do
         END IF;
    END IF;

  EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := 'F';
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        igs_ge_msg_stack.add;

  END update_ToDo;



  PROCEDURE update_app_status(p_base_id                   igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_application_code          igf_ap_appl_status_all.application_code%TYPE,
                              p_application_status_code   igf_ap_appl_status_all.application_status_code%TYPE,
                              x_return_status             OUT NOCOPY VARCHAR2)
    IS
    ------------------------------------------------------------------
    --Created by  : upinjark, Oracle India
    --Date created: 04-Jul-2004
    --
    --Purpose:
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------

  -- cursor to get the row from application status table
  CURSOR c_appl_status (cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                        cp_application_code igf_ap_appl_status_all.application_code%TYPE
                       ) IS
     SELECT rowid
       FROM IGF_AP_APPL_STATUS_ALL aps
      WHERE BASE_ID = cp_base_id
        AND APPLICATION_CODE = cp_application_code;

     l_appl_status c_appl_status%ROWTYPE;

  BEGIN
    x_return_status := 'F';

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_inst_app.update_app_status.debug','calling igf_ap_appl_status_all_pkg.update_row');
    END IF;


    OPEN c_appl_status(p_base_id, p_application_code);
    FETCH c_appl_status INTO l_appl_status;
    CLOSE c_appl_status;

    igf_ap_appl_status_pkg.update_row (
      x_rowid                                 => l_appl_status.rowid,
      x_base_id                                => p_base_id,
      x_application_code                       => p_application_code,
      x_application_status_code                => p_application_status_code
    );

    x_return_status := 'T';

  EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := 'F';
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        igs_ge_msg_stack.add;

  END update_app_status;


  PROCEDURE update_Ant_Data_For_All_Terms (p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                                           p_cal_type            igs_ca_inst_all.cal_type%TYPE,
                                           p_seq_number          igs_ca_inst_all.sequence_number%TYPE,
                                           p_ant_data_column     VARCHAR2,
                                           p_ant_data_value      VARCHAR2,
                                           x_return_status       OUT NOCOPY VARCHAR2,
                                           p_override_flag       VARCHAR2
                                           )
    IS
    ------------------------------------------------------------------
    --Created by  : upinjark, Oracle India
    --Date created: 04-Jul-2004
    --
    --Purpose:
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------

    -- cursor to fetch the terms withinn an award year
    CURSOR c_all_terms(cp_sup_cal_type igs_ca_inst_all.cal_type%TYPE,
                       cp_sup_seq_number igs_ca_inst_all.sequence_number%TYPE)
                       IS
    SELECT SUB_CAL_TYPE, SUB_CI_SEQUENCE_NUMBER
      FROM IGS_CA_INST_REL rel, IGS_CA_TYPE typ
     WHERE rel.SUP_CAL_TYPE = cp_sup_cal_type
       AND rel.SUP_CI_SEQUENCE_NUMBER = cp_sup_seq_number
       AND rel.sub_cal_type=typ.cal_type
       AND typ.s_cal_cat='LOAD';

    l_get_cal_typ_seq_num     c_all_terms%ROWTYPE;

    -- to fetch all the anticipated value for the given base_id and award year
    CURSOR c_get_ant_data(cp_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                          cp_ld_cal_type            igs_ca_inst_all.cal_type%TYPE,
                          cp_ld_seq_number          igs_ca_inst_all.sequence_number%TYPE
                          )
                          IS
    SELECT *
      FROM IGF_AP_FA_ANT_DATA
     WHERE BASE_ID = CP_BASE_ID
       AND LD_CAL_TYPE = cp_ld_cal_type
       AND LD_SEQUENCE_NUMBER = cp_ld_seq_number;

    l_ant_data_row c_get_ant_data%ROWTYPE;

    l_row_id VARCHAR2(25);

  BEGIN
      l_get_cal_typ_seq_num := NULL;
      l_row_id := NULL ;
      x_return_status := 'F';

      /*OPEN c_all_terms(p_cal_type,
                       p_seq_number
                       );

      FETCH c_all_terms INTO l_get_cal_typ_seq_num;
      CLOSE c_all_terms;*/

      FOR l_get_cal_typ_seq_num IN c_all_terms(p_cal_type, p_seq_number) LOOP
        OPEN c_get_ant_data(p_base_id, l_get_cal_typ_seq_num.sub_cal_type,l_get_cal_typ_seq_num.sub_ci_sequence_number);
        FETCH c_get_ant_data INTO l_ant_data_row;
        CLOSE c_get_ant_data;

        IF p_override_flag = 'Y' THEN
                  IF p_ant_data_column = 'ORG_UNIT_CD' THEN
                      l_ant_data_row.ORG_UNIT_CD := p_ant_data_value;
                ELSIF p_ant_data_column = 'PROGRAM_TYPE' THEN
                      l_ant_data_row.PROGRAM_TYPE := p_ant_data_value;
                ELSIF p_ant_data_column = 'PROGRAM_LOCATION_CD' THEN
                      l_ant_data_row.PROGRAM_LOCATION_CD := p_ant_data_value;
                ELSIF p_ant_data_column = 'PROGRAM_CD' THEN
                      l_ant_data_row.PROGRAM_CD := p_ant_data_value;
                ELSIF p_ant_data_column = 'CLASS_STANDING' THEN
                      l_ant_data_row.CLASS_STANDING := p_ant_data_value;
                ELSIF p_ant_data_column = 'RESIDENCY_STATUS_CODE' THEN
                      l_ant_data_row.RESIDENCY_STATUS_CODE := p_ant_data_value;
                ELSIF p_ant_data_column = 'HOUSING_STATUS_CODE' THEN
                      l_ant_data_row.HOUSING_STATUS_CODE := p_ant_data_value;
                ELSIF p_ant_data_column = 'ATTENDANCE_TYPE' THEN
                      l_ant_data_row.ATTENDANCE_TYPE := p_ant_data_value;
                ELSIF p_ant_data_column = 'ATTENDANCE_MODE' THEN
                      l_ant_data_row.ATTENDANCE_MODE := p_ant_data_value;
                ELSIF p_ant_data_column = 'MONTHS_ENROLLED_NUM' THEN
                      l_ant_data_row.MONTHS_ENROLLED_NUM := p_ant_data_value;
                ELSIF p_ant_data_column = 'CREDIT_POINTS_NUM' THEN
                      l_ant_data_row.CREDIT_POINTS_NUM := p_ant_data_value;
                END IF;

           ELSE
                IF p_ant_data_column = 'ORG_UNIT_CD' THEN
                      IF l_ant_data_row.ORG_UNIT_CD IS NULL THEN
                        l_ant_data_row.ORG_UNIT_CD := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'PROGRAM_TYPE' THEN
                      IF l_ant_data_row.PROGRAM_TYPE IS NULL THEN
                        l_ant_data_row.PROGRAM_TYPE := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'PROGRAM_LOCATION_CD' THEN
                      IF l_ant_data_row.PROGRAM_LOCATION_CD IS NULL THEN
                        l_ant_data_row.PROGRAM_LOCATION_CD := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'PROGRAM_CD' THEN
                      IF l_ant_data_row.PROGRAM_CD IS NULL THEN
                        l_ant_data_row.PROGRAM_CD := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'CLASS_STANDING' THEN
                      IF l_ant_data_row.CLASS_STANDING IS NULL THEN
                        l_ant_data_row.CLASS_STANDING := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'RESIDENCY_STATUS_CODE' THEN
                      IF l_ant_data_row.RESIDENCY_STATUS_CODE IS NULL THEN
                        l_ant_data_row.RESIDENCY_STATUS_CODE := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'HOUSING_STATUS_CODE' THEN
                      IF l_ant_data_row.HOUSING_STATUS_CODE IS NULL THEN
                        l_ant_data_row.HOUSING_STATUS_CODE := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'ATTENDANCE_TYPE' THEN
                      IF l_ant_data_row.ATTENDANCE_TYPE IS NULL THEN
                        l_ant_data_row.ATTENDANCE_TYPE := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'ATTENDANCE_MODE' THEN
                      IF l_ant_data_row.ATTENDANCE_MODE IS NULL THEN
                        l_ant_data_row.ATTENDANCE_MODE := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'MONTHS_ENROLLED_NUM' THEN
                      IF l_ant_data_row.MONTHS_ENROLLED_NUM IS NULL THEN
                        l_ant_data_row.MONTHS_ENROLLED_NUM := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'CREDIT_POINTS_NUM' THEN
                      IF l_ant_data_row.CREDIT_POINTS_NUM IS NULL THEN
                        l_ant_data_row.CREDIT_POINTS_NUM := p_ant_data_value;
                      END IF;
                END IF;

           END IF;

          igf_ap_fa_ant_data_pkg.add_row
          (
                      x_mode                              => 'R',
                      x_rowid                             => l_row_id,
                      x_base_id                           => p_base_id,
                      x_ld_cal_type                       => l_get_cal_typ_seq_num.sub_cal_type,
                      x_ld_sequence_number                => l_get_cal_typ_seq_num.sub_ci_sequence_number,
                      x_org_unit_cd                       => l_ant_data_row.org_unit_cd ,
                      x_program_type                      => l_ant_data_row.program_type,
                      x_program_location_cd               => l_ant_data_row.program_location_cd,
                      x_program_cd                        => l_ant_data_row.program_cd,
                      x_class_standing                    => l_ant_data_row.class_standing,
                      x_residency_status_code             => l_ant_data_row.residency_status_code,
                      x_housing_status_code               => l_ant_data_row.housing_status_code,
                      x_attendance_type                   => l_ant_data_row.attendance_type,
                      x_attendance_mode                   => l_ant_data_row.attendance_mode,
                      x_months_enrolled_num               => l_ant_data_row.months_enrolled_num,
                      x_credit_points_num                 => l_ant_data_row.credit_points_num
                    );

      END LOOP;

      x_return_status := 'T';

    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := 'F';
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        igs_ge_msg_stack.add;

  END update_Ant_Data_For_All_Terms;



  PROCEDURE update_Ant_Data_a_Term(p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                                            p_ld_cal_type         igs_ca_inst_all.cal_type%TYPE,
                                            p_ld_seq_number       igs_ca_inst_all.sequence_number%TYPE,
                                            p_ant_data_column     VARCHAR2,
                                            p_ant_data_value      VARCHAR2,
                                            x_return_status       OUT NOCOPY VARCHAR2,
                                            p_override_flag       VARCHAR2
                                           )
    IS
    ------------------------------------------------------------------
    --Created by  : upinjark, Oracle India
    --Date created: 04-Jul-2004
    --
    --Purpose:
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------


      -- to fetch all the anticipated value for the given base_id and award year
        CURSOR c_get_ant_data(cp_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                              cp_ld_cal_type            igs_ca_inst_all.cal_type%TYPE,
                              cp_ld_seq_number          igs_ca_inst_all.sequence_number%TYPE
                              )
                              IS
        SELECT *
          FROM IGF_AP_FA_ANT_DATA
         WHERE BASE_ID = CP_BASE_ID
           AND LD_CAL_TYPE = cp_ld_cal_type
           AND LD_SEQUENCE_NUMBER = cp_ld_seq_number;

        l_ant_data_row c_get_ant_data%ROWTYPE;

        l_row_id VARCHAR2(25);

  BEGIN
          l_row_id := NULL ;
          x_return_status := 'F';

          OPEN c_get_ant_data(p_base_id, p_ld_cal_type, p_ld_seq_number);
          FETCH c_get_ant_data INTO l_ant_data_row;
          CLOSE c_get_ant_data;

          IF p_override_flag = 'Y' THEN
                  IF p_ant_data_column = 'ORG_UNIT_CD' THEN
                      l_ant_data_row.ORG_UNIT_CD := p_ant_data_value;
                ELSIF p_ant_data_column = 'PROGRAM_TYPE' THEN
                      l_ant_data_row.PROGRAM_TYPE := p_ant_data_value;
                ELSIF p_ant_data_column = 'PROGRAM_LOCATION_CD' THEN
                      l_ant_data_row.PROGRAM_LOCATION_CD := p_ant_data_value;
                ELSIF p_ant_data_column = 'PROGRAM_CD' THEN
                      l_ant_data_row.PROGRAM_CD := p_ant_data_value;
                ELSIF p_ant_data_column = 'CLASS_STANDING' THEN
                      l_ant_data_row.CLASS_STANDING := p_ant_data_value;
                ELSIF p_ant_data_column = 'RESIDENCY_STATUS_CODE' THEN
                      l_ant_data_row.RESIDENCY_STATUS_CODE := p_ant_data_value;
                ELSIF p_ant_data_column = 'HOUSING_STATUS_CODE' THEN
                      l_ant_data_row.HOUSING_STATUS_CODE := p_ant_data_value;
                ELSIF p_ant_data_column = 'ATTENDANCE_TYPE' THEN
                      l_ant_data_row.ATTENDANCE_TYPE := p_ant_data_value;
                ELSIF p_ant_data_column = 'ATTENDANCE_MODE' THEN
                      l_ant_data_row.ATTENDANCE_MODE := p_ant_data_value;
                ELSIF p_ant_data_column = 'MONTHS_ENROLLED_NUM' THEN
                      l_ant_data_row.MONTHS_ENROLLED_NUM := p_ant_data_value;
                ELSIF p_ant_data_column = 'CREDIT_POINTS_NUM' THEN
                      l_ant_data_row.CREDIT_POINTS_NUM := p_ant_data_value;
                END IF;

           ELSE
                IF p_ant_data_column = 'ORG_UNIT_CD' THEN
                      IF l_ant_data_row.ORG_UNIT_CD IS NULL THEN
                        l_ant_data_row.ORG_UNIT_CD := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'PROGRAM_TYPE' THEN
                      IF l_ant_data_row.PROGRAM_TYPE IS NULL THEN
                        l_ant_data_row.PROGRAM_TYPE := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'PROGRAM_LOCATION_CD' THEN
                      IF l_ant_data_row.PROGRAM_LOCATION_CD IS NULL THEN
                        l_ant_data_row.PROGRAM_LOCATION_CD := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'PROGRAM_CD' THEN
                      IF l_ant_data_row.PROGRAM_CD IS NULL THEN
                        l_ant_data_row.PROGRAM_CD := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'CLASS_STANDING' THEN
                      IF l_ant_data_row.CLASS_STANDING IS NULL THEN
                        l_ant_data_row.CLASS_STANDING := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'RESIDENCY_STATUS_CODE' THEN
                      IF l_ant_data_row.RESIDENCY_STATUS_CODE IS NULL THEN
                        l_ant_data_row.RESIDENCY_STATUS_CODE := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'HOUSING_STATUS_CODE' THEN
                      IF l_ant_data_row.HOUSING_STATUS_CODE IS NULL THEN
                        l_ant_data_row.HOUSING_STATUS_CODE := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'ATTENDANCE_TYPE' THEN
                      IF l_ant_data_row.ATTENDANCE_TYPE IS NULL THEN
                        l_ant_data_row.ATTENDANCE_TYPE := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'ATTENDANCE_MODE' THEN
                      IF l_ant_data_row.ATTENDANCE_MODE IS NULL THEN
                        l_ant_data_row.ATTENDANCE_MODE := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'MONTHS_ENROLLED_NUM' THEN
                      IF l_ant_data_row.MONTHS_ENROLLED_NUM IS NULL THEN
                        l_ant_data_row.MONTHS_ENROLLED_NUM := p_ant_data_value;
                      END IF;

                ELSIF p_ant_data_column = 'CREDIT_POINTS_NUM' THEN
                      IF l_ant_data_row.CREDIT_POINTS_NUM IS NULL THEN
                        l_ant_data_row.CREDIT_POINTS_NUM := p_ant_data_value;
                      END IF;
                END IF;

           END IF;



          igf_ap_fa_ant_data_pkg.add_row
          (
                      x_mode                              => 'R',
                      x_rowid                             => l_row_id,
                      x_base_id                           => p_base_id,
                      x_ld_cal_type                       => p_ld_cal_type,
                      x_ld_sequence_number                => p_ld_seq_number,
                      x_org_unit_cd                       => l_ant_data_row.org_unit_cd ,
                      x_program_type                      => l_ant_data_row.program_type,
                      x_program_location_cd               => l_ant_data_row.program_location_cd,
                      x_program_cd                        => l_ant_data_row.program_cd,
                      x_class_standing                    => l_ant_data_row.class_standing,
                      x_residency_status_code             => l_ant_data_row.residency_status_code,
                      x_housing_status_code               => l_ant_data_row.housing_status_code,
                      x_attendance_type                   => l_ant_data_row.attendance_type,
                      x_attendance_mode                   => l_ant_data_row.attendance_mode,
                      x_months_enrolled_num               => l_ant_data_row.months_enrolled_num,
                      x_credit_points_num                 => l_ant_data_row.credit_points_num
                    );

        x_return_status := 'T';

    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := 'F';
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        igs_ge_msg_stack.add;

  END update_Ant_Data_a_Term;


  PROCEDURE raise_event_on_IA_submit (p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                                    p_application_code    igf_ap_appl_status_all.application_code%TYPE,
                                    x_return_status       OUT NOCOPY VARCHAR2)
    IS
    ------------------------------------------------------------------
    --Created by  : upinjark, Oracle India
    --Date created: 04-Jul-2004
    --
    --Purpose:
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------

    -- Get person number
     CURSOR c_person_number(
                            cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                           ) IS
       SELECT hz.party_number
         FROM hz_parties hz,
              igf_ap_fa_base_rec_all fa
        WHERE fa.person_id = hz.party_id
          AND fa.base_id = cp_base_id;
      l_person_number hz_parties.party_number%TYPE;


     -- Get award year alternate code
      CURSOR c_award_year(
                          cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                         ) IS
        SELECT ca.alternate_code
          FROM igs_ca_inst_all ca,
               igf_ap_fa_base_rec_all fa
         WHERE fa.base_id = cp_base_id
           AND fa.ci_cal_type = ca.cal_type
           AND fa.ci_sequence_number = ca.sequence_number;
      l_alternate_code igs_ca_inst_all.alternate_code%TYPE;


      -- Get Institutional application name
      CURSOR c_application_name(
                                cp_application_code igf_ap_appl_setup_all.application_name%TYPE
                               ) IS
        SELECT APPLICATION_NAME
          FROM IGF_AP_APPL_SETUP_ALL
         WHERE APPLICATION_CODE = cp_application_code
           AND ROWNUM = 1;
        l_application_name igf_ap_appl_setup_all.application_name%TYPE;

     l_seq_val       NUMBER;

     l_wf_event_t           WF_EVENT_T;
     l_wf_parameter_list_t  WF_PARAMETER_LIST_T;
     lv_event_name          VARCHAR2(4000);

    BEGIN
      x_return_status := 'F';

      OPEN c_person_number(p_base_id);
      FETCH c_person_number INTO l_person_number;
      CLOSE c_person_number;

      OPEN c_award_year(p_base_id);
      FETCH c_award_year INTO l_alternate_code;
      CLOSE c_award_year;

      OPEN c_application_name(p_application_code);
      FETCH c_application_name INTO l_application_name;
      CLOSE c_application_name;

      SELECT igs_pe_res_chg_s.nextval INTO l_seq_val FROM DUAL;

      -- Initialize the wf_event_t object
      WF_EVENT_T.Initialize(l_wf_event_t);
      -- Set the event name
      lv_event_name := 'oracle.apps.igf.ap.InstAppSubmitted';

      l_wf_event_t.setEventName(pEventName => lv_event_name);

      -- Set the event key
      l_wf_event_t.setEventKey(
                                 pEventKey => lv_event_name || l_seq_val
                                );

      -- Set the parameter list
      l_wf_event_t.setParameterList(
                                    pParameterList => l_wf_parameter_list_t
                                   );

      -- Set the message's subject
      fnd_message.set_name('IGF','IGF_AP_INSTAPPSUBMITTED_SUBJ');

      wf_event.addparametertolist(
                                  p_name          => 'SUBJECT',
                                  p_value         =>  'IGF_AP_INSTAPPSUBMITTED_SUBJ', --fnd_message.get,
                                  p_parameterlist => l_wf_parameter_list_t
                                 );

      -- Set the person number
      wf_event.addparametertolist(
                                  p_name          => 'STUDENT_NUMBER',
                                  p_value         => l_person_number,
                                  p_parameterlist => l_wf_parameter_list_t
                                 );

      -- Set the to do item description
      wf_event.addparametertolist(
                                  p_name          => 'APPLICATION_NAME',
                                  p_value         => l_application_name,
                                  p_parameterlist => l_wf_parameter_list_t
                                 );

      -- Set the award year alternate code
      wf_event.addparametertolist(
                                  p_name          => 'AWARD_YEAR',
                                  p_value         => l_alternate_code,
                                  p_parameterlist => l_wf_parameter_list_t
                                 );

      wf_Event.raise(
                     p_event_name => lv_event_name,
                     p_event_key  => lv_event_name || l_seq_val,
                     p_parameters => l_wf_parameter_list_t
                    );
      x_return_status := 'T';

     EXCEPTION
       WHEN OTHERS THEN
         ROLLBACK;
         x_return_status := 'F';
         fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
         igs_ge_msg_stack.add;

    END raise_event_on_IA_submit;


END igf_ap_inst_app;

/
