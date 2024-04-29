--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_012
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_012" AS
/* $Header: IGSEN12B.pls 120.9 2006/04/13 01:52:36 smaddali ship $ */
  /*-------------------------------------------------------------------------------------------------------------------------------------
  --Change History:
  --Who         When          What
  --ckasu       05-Apr-2004   Modified IGS_EN_STDNT_PS_ATT_Pkg.update_Row procedure
                              call as a part of bug 3544927.
  --npalanis    10-JUN-2003   Bug:2923413 igs_pe_typ_instances_pkgs call
  --                          modified for the new employment category column added in the table
  --pradhakr    16-Dec-2002   Changed the call to the update_row of igs_en_su_attempt
  --                          table to igs_en_sua_api.update_unit_attempt.
  --                          Changes wrt ENCR031 build. Bug#2643207
  --nalkumar    05-OCT-2001   Modified the IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW call.
  --                          Added four new parameters to call it as per the Bug# 2027984.
  --Aiyer       10-Oct-2001   Added the column grading schema in all Tbh calls of IGS_EN_SU_ATTEMPT_PKG as a part of the bug 2037897.
  --pradhakr    07-Dec-2001   Added a column deg_aud_detail_id in the TBH calls
  --                  of IGS_EN_SU_ATTEMPT_PKG as part of
  --                  Degree Audit Interface build.(Bug# 2033208)
  --svenkata    20-Dec-2001   Added columns student_career_transcript and Student_career_statistics as part of build Career
  --                          Impact Part2 . Bug #2158626
  --svenkata    07-JAN-2002   Bug No. 2172405  Standard Flex Field columns have been added
  --                          to table handler procedure calls as part of CCR - ENCR022.
  --Nishikant   29-jan-2002   Added the column session_id  in the Tbh calls of IGS_EN_SU_ATTEMPT_PKG
  --                          as a part of the bug 2172380.
  --mesriniv    12-sep-2002   Added a new parameter waitlist_manual_ind in TBH call of IGS_EN_SU_ATTEMPT
  --                          for  Bug 2554109 MINI Waitlist Build for Jan 03 Release
  --                          Added refernces to column ORG_UNIT_CD incall to IGS_EN_SU_ATTEMPT TBH call as a part of bug 1964697
  --Bayadav     05-May-2002   Included  code in ENRP_UPD_SCA_STATUS proc to pass message back to IGSEN036 as a part of
  --                          bug 2335633 to indicate the program attempt status has changed.
  --Nishikant   15-may-2002   Condition in an IF clause in the function Enrp_Upd_Sca_Discont modified as part of the bug#2364216.
  --PKPATEL/SSAWHNEY    04-OCT-2002    Bug No: 2600842
  --                          Added the logic for synchronization of expiry date for IGS_PE_FUND_EXCL in the procedure Enrp_Upd_Expiry_Dts
  --amuthu      08-Oct-2002   Added call to drop_all_workflow as part of Drop Transfer Build.
  --                          the calls to the drop_all workflow is done after either dropping or
  --                          discontinuing a unit attempt. created new local procedure invoke_drop_workflow. Bug 2599925.
  --kkillams    08-11-2002    As part of Legacy Build bug no:2661533,
  --                          Impacted object, due to addition of new paramter to the enrp_val_sca_discont fuctions
  --svenkata   20-NOV-2002   Modified the call to the function igs_en_val_sua.enrp_val_sua_discont to add value 'N' for the parameter
  --                         p_legacy. Bug#2661533.
  --ptandon    21-MAY-2003    Replaced usage of Message IGS_GE_OK with message IGS_AD_OK. Bug#2755657
  --svanukur   26-jun-2003    Passing discontinued date with a nvl substitution of sysdate in the call to the update_row api of
  --                          ig_en_su_attmept in case of a "dropped" unit attempt status as part of bug 2898213.
  --smaddali   04-jul-03     modified procedure enrp_upd_sca_coo for bug 3035523  , to update igs_he_st_spa_all.version_number
  --rvivekan    3-SEP-2003     Waitlist Enhacements build # 3052426. 2 new columns added to
  --                           IGS_EN_SU_ATTEMPT_PKG procedures and consequently to IGS_EN_SUA_API procedures
  --rvangala    07-OCT-2003   Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
  --                          and IGS_EN_SU_ATTEMPT_PKG.UPDATE_ROW, added as part of Prevent Dropping Core Units. Enh Bug# 3052432
  --ptandon     05-DEC-2003   Modified cursor c_sua in Function Enrp_Upd_Sca_Discont as per Placements build. Bug# 3052438.
  --vkarthik    19-Apr-2004   Modified exception handling section to handle no_ausl_record_found
                              for bug 3526251 in Enrp_Upd_Sca_Discont
  --amuthu      21-NOV-2004   Modifed as part of program transfer build. When the program transfer is done the enrolled units are
  --                          no longer discontinued they are always dropped. Modified the logic for the same in enrp_upd_sca_discont
  -- sgurusam   17-Jun-05     Modified function Enrp_Upd_Sca_Discont to add parameters for upd_audit_flag and ss_source_ind
  --amuthu      11-Oct-05     Modified the exception section of the local procedure enrpl_upd_get_status such that it
  --                          does not throw an exception and stop the student program attempt update job from erroring out
  --                          completely. It will log a message in the log file and continue processing the next student.
  --bdeviset    17-Jan-05     Modified Enrp_Upd_Sca_Discont. Modifided the logic of making the program as seconadry
                              for Bug# 5020357
  -- smaddali  10-apr-06      Modified procedure Enrp_Upd_Sca_Statusb for EN324 build - bug#5091858
  -----------------------------------------------------------------------------------------------------------------------------------------*/

PROCEDURE Enrp_Upd_Expiry_Dts(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
 AS
/*
  ||  Created By : pkpatel
  ||  Created On : 27-SEP-2002
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel         04-OCT-2002     Bug No: 2600842
  ||                                  Added the logic for synchronization of expiry date for IGS_PE_FUND_EXCL
  ||  (reverse chronological order - newest change first)
*/
BEGIN
DECLARE

    CURSOR c_psn_encmb_eff (
        cp_person_id        IGS_PE_PERS_ENCUMB.person_id%TYPE,
        cp_encumbrance_type IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
        cp_start_dt     IGS_PE_PERS_ENCUMB.start_dt%TYPE,
        cp_expiry_dt        IGS_PE_PERS_ENCUMB.expiry_dt%TYPE) IS
        SELECT  ROWID, IGS_PE_PERSENC_EFFCT.*
        FROM    IGS_PE_PERSENC_EFFCT
        WHERE   person_id    = cp_person_id     AND
            encumbrance_type = cp_encumbrance_type  AND
            pen_start_dt     = cp_start_dt      AND
            (expiry_dt IS NULL          OR
            expiry_dt    > cp_expiry_dt)
        FOR UPDATE OF IGS_PE_PERSENC_EFFCT.person_id NOWAIT;


    CURSOR c_psn_crs_grp_excl (
        cp_person_id        IGS_PE_PERS_ENCUMB.person_id%TYPE,
        cp_encumbrance_type IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
        cp_start_dt     IGS_PE_PERS_ENCUMB.start_dt%TYPE,
        cp_expiry_dt        IGS_PE_PERS_ENCUMB.expiry_dt%TYPE) IS
        SELECT  PCGE.ROWID, PCGE.*
        FROM    IGS_PE_CRS_GRP_EXCL  PCGE,
            IGS_PE_PERSENC_EFFCT PEE
        WHERE   PCGE.person_id       = cp_person_id        AND
            PCGE.encumbrance_type    = cp_encumbrance_type     AND
            PCGE.pen_start_dt    = cp_start_dt         AND
            PCGE.s_encmb_effect_type = PEE.s_encmb_effect_type AND
            PCGE.pee_start_dt    = PEE.pee_start_dt        AND
            (PCGE.expiry_dt IS NULL                OR
            PCGE.expiry_dt > cp_expiry_dt)
        FOR UPDATE OF PCGE.person_id NOWAIT;


    CURSOR c_psn_crs_excl (
        cp_person_id        IGS_PE_PERS_ENCUMB.person_id%TYPE,
        cp_encumbrance_type IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
        cp_start_dt     IGS_PE_PERS_ENCUMB.start_dt%TYPE,
        cp_expiry_dt        IGS_PE_PERS_ENCUMB.expiry_dt%TYPE) IS
        SELECT  PCE.ROWID, PCE.*
        FROM    IGS_PE_COURSE_EXCL      PCE,
            IGS_PE_PERSENC_EFFCT PEE
        WHERE   PCE.person_id        = cp_person_id        AND
            PCE.encumbrance_type     = cp_encumbrance_type     AND
            PCE.pen_start_dt     = cp_start_dt         AND
            PCE.s_encmb_effect_type  = PEE.s_encmb_effect_type AND
            PCE.pee_start_dt     = PEE.pee_start_dt        AND
            (PCE.expiry_dt IS NULL                 OR
            PCE.expiry_dt > cp_expiry_dt)
        FOR UPDATE OF PCE.person_id NOWAIT;


    CURSOR c_psn_unit_excl (
        cp_person_id        IGS_PE_PERS_ENCUMB.person_id%TYPE,
        cp_encumbrance_type IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
        cp_start_dt     IGS_PE_PERS_ENCUMB.start_dt%TYPE,
        cp_expiry_dt        IGS_PE_PERS_ENCUMB.expiry_dt%TYPE) IS
        SELECT  PUE.ROWID,
            PUE.*
        FROM    IGS_PE_PERS_UNT_EXCL     PUE,
            IGS_PE_PERSENC_EFFCT PEE
        WHERE   PUE.person_id        = cp_person_id        AND
            PUE.encumbrance_type     = cp_encumbrance_type     AND
            PUE.pen_start_dt     = cp_start_dt         AND
            PUE.s_encmb_effect_type  = PEE.s_encmb_effect_type AND
            PUE.pee_start_dt     = PEE.pee_start_dt        AND
            (PUE.expiry_dt IS NULL                 OR
            PUE.expiry_dt > cp_expiry_dt)
        FOR UPDATE OF PUE.person_id NOWAIT;


    CURSOR c_psn_unit_rqmnt (
        cp_person_id        IGS_PE_PERS_ENCUMB.person_id%TYPE,
        cp_encumbrance_type IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
        cp_start_dt     IGS_PE_PERS_ENCUMB.start_dt%TYPE,
        cp_expiry_dt        IGS_PE_PERS_ENCUMB.expiry_dt%TYPE) IS
        SELECT  PUR.ROWID,
            PUR.*
        FROM    IGS_PE_UNT_REQUIRMNT   PUR,
            IGS_PE_PERSENC_EFFCT PEE
        WHERE   PUR.person_id        = cp_person_id        AND
            PUR.encumbrance_type     = cp_encumbrance_type     AND
            PUR.pen_start_dt     = cp_start_dt         AND
            PUR.s_encmb_effect_type  = PEE.s_encmb_effect_type AND
            PUR.pee_start_dt     = PEE.pee_start_dt        AND
            (PUR.expiry_dt IS NULL                 OR
            PUR.expiry_dt > cp_expiry_dt)
        FOR UPDATE OF PUR.person_id NOWAIT;

    CURSOR  fund_cur(
        cp_person_id        IGS_PE_PERS_ENCUMB.person_id%TYPE,
        cp_encumbrance_type IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
        cp_start_dt     IGS_PE_PERS_ENCUMB.start_dt%TYPE,
        cp_expiry_dt        IGS_PE_PERS_ENCUMB.expiry_dt%TYPE) IS
        SELECT  fun.ROWID,
                fun.*
        FROM    IGS_PE_FUND_EXCL  fun,
            IGS_PE_PERSENC_EFFCT PEE
        WHERE   fun.person_id        = cp_person_id        AND
            fun.encumbrance_type     = cp_encumbrance_type     AND
            fun.pen_start_dt     = cp_start_dt         AND
            fun.s_encmb_effect_type  = PEE.s_encmb_effect_type AND
            fun.pee_start_dt     = PEE.pee_start_dt        AND
            fun.person_id        = pee.person_id       AND
            fun.encumbrance_type = pee.encumbrance_type        AND
            fun.pen_start_dt     = pee.pee_start_dt            AND
            fun.pee_sequence_number = pee.sequence_number AND
            (fun.expiry_dt IS NULL                 OR
            fun.expiry_dt > cp_expiry_dt)
        FOR UPDATE OF fun.person_id NOWAIT;

BEGIN
    -- This procedure sets the expiry date for all
    -- child records of the nominated IGS_PE_PERS_ENCUMB
    -- when the expiry_dt is set.
    -- SELECTING ALL IGS_PE_PERS_ENCUMB RECORDS
    FOR v_psn_encmb_eff_rec IN c_psn_encmb_eff(p_person_id,
                               p_encumbrance_type,
                               p_start_dt,
                           p_expiry_dt) LOOP
        -- for each IGS_PE_PERSENC_EFFCT record returned,
        -- update the expiry_dt


        IF (v_psn_encmb_eff_rec.pee_start_dt > p_expiry_dt) THEN

                        Igs_Pe_Persenc_Effct_Pkg.UPDATE_ROW(
                                              X_ROWID => v_psn_encmb_eff_rec.ROWID ,
                                              X_PERSON_ID => v_psn_encmb_eff_rec.PERSON_ID ,
                                              X_ENCUMBRANCE_TYPE => v_psn_encmb_eff_rec.ENCUMBRANCE_TYPE ,
                                              X_PEN_START_DT => v_psn_encmb_eff_rec.PEN_START_DT ,
                                              X_S_ENCMB_EFFECT_TYPE => v_psn_encmb_eff_rec.S_ENCMB_EFFECT_TYPE ,
                                              X_PEE_START_DT => v_psn_encmb_eff_rec.PEE_START_DT ,
                                              X_SEQUENCE_NUMBER => v_psn_encmb_eff_rec.SEQUENCE_NUMBER ,
                                              X_EXPIRY_DT => v_psn_encmb_eff_rec.pee_start_dt ,
                                              X_COURSE_CD => v_psn_encmb_eff_rec.COURSE_CD ,
                                              X_RESTRICTED_ENROLMENT_CP => v_psn_encmb_eff_rec.RESTRICTED_ENROLMENT_CP ,
                                              X_RESTRICTED_ATTENDANCE_TYPE => v_psn_encmb_eff_rec.RESTRICTED_ATTENDANCE_TYPE ,
                                              X_MODE =>  'R'
                                                );


        ELSE

                       Igs_Pe_Persenc_Effct_Pkg.UPDATE_ROW(
                                              X_ROWID => v_psn_encmb_eff_rec.ROWID ,
                                              X_PERSON_ID => v_psn_encmb_eff_rec.PERSON_ID ,
                                              X_ENCUMBRANCE_TYPE => v_psn_encmb_eff_rec.ENCUMBRANCE_TYPE ,
                                              X_PEN_START_DT => v_psn_encmb_eff_rec.PEN_START_DT ,
                                              X_S_ENCMB_EFFECT_TYPE => v_psn_encmb_eff_rec.S_ENCMB_EFFECT_TYPE ,
                                              X_PEE_START_DT => v_psn_encmb_eff_rec.PEE_START_DT ,
                                              X_SEQUENCE_NUMBER => v_psn_encmb_eff_rec.SEQUENCE_NUMBER ,
                                              X_EXPIRY_DT => p_expiry_dt ,
                                              X_COURSE_CD => v_psn_encmb_eff_rec.COURSE_CD ,
                                              X_RESTRICTED_ENROLMENT_CP => v_psn_encmb_eff_rec.RESTRICTED_ENROLMENT_CP ,
                                              X_RESTRICTED_ATTENDANCE_TYPE => v_psn_encmb_eff_rec.RESTRICTED_ATTENDANCE_TYPE ,
                                              X_MODE =>  'R'
                                             );





        END IF;
        -- SELECTING ALL IGS_PE_CRS_GRP_EXCL RECORDS
        FOR v_psn_crs_grp_excl_rec IN c_psn_crs_grp_excl(p_person_id,
                                     p_encumbrance_type,
                                     p_start_dt,
                                 p_expiry_dt) LOOP
            -- for each IGS_PE_CRS_GRP_EXCL record returned,
            -- update the expiry_dt
            IF (v_psn_crs_grp_excl_rec.pcge_start_dt > p_expiry_dt) THEN

                                   Igs_Pe_Crs_Grp_Excl_Pkg.UPDATE_ROW(
                                       X_ROWID => v_psn_crs_grp_excl_rec.ROWID ,
                                       X_PERSON_ID => v_psn_crs_grp_excl_rec.PERSON_ID ,
                                       X_ENCUMBRANCE_TYPE => v_psn_crs_grp_excl_rec.ENCUMBRANCE_TYPE ,
                                       X_PEN_START_DT => v_psn_crs_grp_excl_rec.PEN_START_DT ,
                                       X_S_ENCMB_EFFECT_TYPE => v_psn_crs_grp_excl_rec.S_ENCMB_EFFECT_TYPE ,
                                       X_PEE_START_DT => v_psn_crs_grp_excl_rec.PEE_START_DT ,
                                       X_PEE_SEQUENCE_NUMBER => v_psn_crs_grp_excl_rec.PEE_SEQUENCE_NUMBER ,
                                       X_COURSE_GROUP_CD => v_psn_crs_grp_excl_rec.COURSE_GROUP_CD ,
                                       X_PCGE_START_DT => v_psn_crs_grp_excl_rec.PCGE_START_DT ,
                                       X_EXPIRY_DT => v_psn_crs_grp_excl_rec.PCGE_START_DT ,
                                      X_MODE => 'R'
                                    );


            ELSE
                                  Igs_Pe_Crs_Grp_Excl_Pkg.UPDATE_ROW(
                                       X_ROWID => v_psn_crs_grp_excl_rec.ROWID ,
                                       X_PERSON_ID => v_psn_crs_grp_excl_rec.PERSON_ID ,
                                       X_ENCUMBRANCE_TYPE => v_psn_crs_grp_excl_rec.ENCUMBRANCE_TYPE ,
                                       X_PEN_START_DT => v_psn_crs_grp_excl_rec.PEN_START_DT ,
                                       X_S_ENCMB_EFFECT_TYPE => v_psn_crs_grp_excl_rec.S_ENCMB_EFFECT_TYPE ,
                                       X_PEE_START_DT => v_psn_crs_grp_excl_rec.PEE_START_DT ,
                                       X_PEE_SEQUENCE_NUMBER => v_psn_crs_grp_excl_rec.PEE_SEQUENCE_NUMBER ,
                                       X_COURSE_GROUP_CD => v_psn_crs_grp_excl_rec.COURSE_GROUP_CD ,
                                       X_PCGE_START_DT => v_psn_crs_grp_excl_rec.PCGE_START_DT ,
                                       X_EXPIRY_DT => p_expiry_dt ,
                                      X_MODE => 'R'
                                    );


            END IF;
        END LOOP;
        -- SELECTING ALL IGS_PE_COURSE_EXCL RECORDS


        FOR v_psn_crs_excl_rec IN c_psn_crs_excl(p_person_id,
                                 p_encumbrance_type,
                                 p_start_dt,
                             p_expiry_dt) LOOP
            -- for each IGS_PE_COURSE_EXCL record returned,
            -- update the expiry_dt
            IF (v_psn_crs_excl_rec.pce_start_dt > p_expiry_dt) THEN
                                  Igs_Pe_Course_Excl_Pkg.UPDATE_ROW(
                                              X_ROWID => v_psn_crs_excl_rec.ROWID ,
                                              X_PERSON_ID => v_psn_crs_excl_rec.PERSON_ID ,
                                              X_ENCUMBRANCE_TYPE => v_psn_crs_excl_rec.ENCUMBRANCE_TYPE ,
                                              X_PEN_START_DT => v_psn_crs_excl_rec.PEN_START_DT ,
                                              X_S_ENCMB_EFFECT_TYPE => v_psn_crs_excl_rec.S_ENCMB_EFFECT_TYPE ,
                                              X_PEE_START_DT => v_psn_crs_excl_rec.PEE_START_DT ,
                                              X_PEE_SEQUENCE_NUMBER => v_psn_crs_excl_rec.PEE_SEQUENCE_NUMBER ,
                                              X_COURSE_CD => v_psn_crs_excl_rec.COURSE_CD ,
                                              X_PCE_START_DT => v_psn_crs_excl_rec.PCE_START_DT ,
                                              X_EXPIRY_DT => v_psn_crs_excl_rec.pce_start_dt ,
                                              X_MODE  =>  'R'
                                                                    );



            ELSE

                                 Igs_Pe_Course_Excl_Pkg.UPDATE_ROW(
                                              X_ROWID => v_psn_crs_excl_rec.ROWID ,
                                              X_PERSON_ID => v_psn_crs_excl_rec.PERSON_ID ,
                                              X_ENCUMBRANCE_TYPE => v_psn_crs_excl_rec.ENCUMBRANCE_TYPE ,
                                              X_PEN_START_DT => v_psn_crs_excl_rec.PEN_START_DT ,
                                              X_S_ENCMB_EFFECT_TYPE => v_psn_crs_excl_rec.S_ENCMB_EFFECT_TYPE ,
                                              X_PEE_START_DT => v_psn_crs_excl_rec.PEE_START_DT ,
                                              X_PEE_SEQUENCE_NUMBER => v_psn_crs_excl_rec.PEE_SEQUENCE_NUMBER ,
                                              X_COURSE_CD => v_psn_crs_excl_rec.COURSE_CD ,
                                              X_PCE_START_DT => v_psn_crs_excl_rec.PCE_START_DT ,
                                              X_EXPIRY_DT => p_expiry_dt,
                                              X_MODE  =>  'R'
                                                                    );



            END IF;
        END LOOP;
        -- SELECTING ALL IGS_PE_PERS_UNT_EXCL RECORDS
        FOR v_psn_unit_excl_rec IN c_psn_unit_excl(p_person_id,
                                   p_encumbrance_type,
                                   p_start_dt,
                               p_expiry_dt) LOOP
            -- for each IGS_PE_PERS_UNT_EXCL record returned,
            -- update the expiry_dt
            IF (v_psn_unit_excl_rec.pue_start_dt > p_expiry_dt) THEN

                                Igs_Pe_Pers_Unt_Excl_Pkg.UPDATE_ROW(
                                                   X_ROWID => v_psn_unit_excl_rec.ROWID ,
                                                   X_PERSON_ID => v_psn_unit_excl_rec.PERSON_ID ,
                                                   X_ENCUMBRANCE_TYPE => v_psn_unit_excl_rec.ENCUMBRANCE_TYPE ,
                                                   X_PEN_START_DT => v_psn_unit_excl_rec.PEN_START_DT ,
                                                   X_S_ENCMB_EFFECT_TYPE => v_psn_unit_excl_rec.S_ENCMB_EFFECT_TYPE ,
                                                   X_PEE_START_DT => v_psn_unit_excl_rec.PEE_START_DT ,
                                                   X_PEE_SEQUENCE_NUMBER => v_psn_unit_excl_rec.PEE_SEQUENCE_NUMBER ,
                                                   X_UNIT_CD => v_psn_unit_excl_rec.UNIT_CD ,
                                                   X_PUE_START_DT => v_psn_unit_excl_rec.PUE_START_DT ,
                                                   X_EXPIRY_DT =>  v_psn_unit_excl_rec.pue_start_dt,
                                                   X_MODE  =>  'R'
                                                                );


            ELSE
                                Igs_Pe_Pers_Unt_Excl_Pkg.UPDATE_ROW(
                                                   X_ROWID => v_psn_unit_excl_rec.ROWID ,
                                                   X_PERSON_ID => v_psn_unit_excl_rec.PERSON_ID ,
                                                   X_ENCUMBRANCE_TYPE => v_psn_unit_excl_rec.ENCUMBRANCE_TYPE ,
                                                   X_PEN_START_DT => v_psn_unit_excl_rec.PEN_START_DT ,
                                                   X_S_ENCMB_EFFECT_TYPE => v_psn_unit_excl_rec.S_ENCMB_EFFECT_TYPE ,
                                                   X_PEE_START_DT => v_psn_unit_excl_rec.PEE_START_DT ,
                                                   X_PEE_SEQUENCE_NUMBER => v_psn_unit_excl_rec.PEE_SEQUENCE_NUMBER ,
                                                   X_UNIT_CD => v_psn_unit_excl_rec.UNIT_CD ,
                                                   X_PUE_START_DT => v_psn_unit_excl_rec.PUE_START_DT ,
                                                   X_EXPIRY_DT =>  p_expiry_dt,
                                                   X_MODE  =>  'R'
                                                                );

            END IF;
        END LOOP;
        -- SELECTING ALL IGS_PE_UNT_REQUIRMNT RECORDS
        FOR v_psn_unit_rqmnt_rec IN c_psn_unit_rqmnt(p_person_id,
                                     p_encumbrance_type,
                                     p_start_dt,
                                 p_expiry_dt) LOOP
            -- for each IGS_PE_UNT_REQUIRMNT record returned,
            -- update the expiry_dt
            IF (v_psn_unit_rqmnt_rec.pur_start_dt > p_expiry_dt) THEN


                        Igs_Pe_Unt_Requirmnt_Pkg.UPDATE_ROW(
                                 X_ROWID =>v_psn_unit_rqmnt_rec.ROWID ,
                                         X_PERSON_ID =>v_psn_unit_rqmnt_rec.PERSON_ID ,
                                         X_ENCUMBRANCE_TYPE =>v_psn_unit_rqmnt_rec.ENCUMBRANCE_TYPE ,
                                         X_PEN_START_DT =>v_psn_unit_rqmnt_rec.PEN_START_DT ,
                                         X_S_ENCMB_EFFECT_TYPE =>v_psn_unit_rqmnt_rec.S_ENCMB_EFFECT_TYPE ,
                                         X_PEE_START_DT =>v_psn_unit_rqmnt_rec.PEE_START_DT ,
                                         X_PEE_SEQUENCE_NUMBER =>v_psn_unit_rqmnt_rec.PEE_SEQUENCE_NUMBER ,
                                         X_UNIT_CD =>v_psn_unit_rqmnt_rec.UNIT_CD ,
                                         X_PUR_START_DT =>v_psn_unit_rqmnt_rec.PUR_START_DT ,
                                         X_EXPIRY_DT =>  v_psn_unit_rqmnt_rec.pur_start_dt,
                                         X_MODE  =>  'R');



            ELSE

                         Igs_Pe_Unt_Requirmnt_Pkg.UPDATE_ROW(
                                 X_ROWID =>v_psn_unit_rqmnt_rec.ROWID ,
                                         X_PERSON_ID =>v_psn_unit_rqmnt_rec.PERSON_ID ,
                                         X_ENCUMBRANCE_TYPE =>v_psn_unit_rqmnt_rec.ENCUMBRANCE_TYPE ,
                                         X_PEN_START_DT =>v_psn_unit_rqmnt_rec.PEN_START_DT ,
                                         X_S_ENCMB_EFFECT_TYPE =>v_psn_unit_rqmnt_rec.S_ENCMB_EFFECT_TYPE ,
                                         X_PEE_START_DT =>v_psn_unit_rqmnt_rec.PEE_START_DT ,
                                         X_PEE_SEQUENCE_NUMBER =>v_psn_unit_rqmnt_rec.PEE_SEQUENCE_NUMBER ,
                                         X_UNIT_CD =>v_psn_unit_rqmnt_rec.UNIT_CD ,
                                         X_PUR_START_DT =>v_psn_unit_rqmnt_rec.PUR_START_DT ,
                                         X_EXPIRY_DT => p_expiry_dt,
                                         X_MODE  =>  'R');



            END IF;

        END LOOP;

        -- SELECTING ALL IGS_PE_FUND_EXCL RECORDS
        FOR fund_rec IN fund_cur(p_person_id,
                                 p_encumbrance_type,
                                 p_start_dt,
                                 p_expiry_dt) LOOP
            -- for each IGS_PE_FUND_EXCL record returned,
            -- update the expiry_dt
            IF (fund_rec.pfe_start_dt > p_expiry_dt) THEN

                        igs_pe_fund_excl_pkg.update_row(
                                         X_ROWID         =>fund_rec.ROWID ,
                                         X_FUND_EXCL_ID   =>fund_rec.FUND_EXCL_ID,
                                         X_PERSON_ID     =>fund_rec.PERSON_ID ,
                                         X_ENCUMBRANCE_TYPE =>fund_rec.ENCUMBRANCE_TYPE ,
                                         X_PEN_START_DT  =>fund_rec.PEN_START_DT ,
                                         X_S_ENCMB_EFFECT_TYPE =>fund_rec.S_ENCMB_EFFECT_TYPE ,
                                         X_PEE_START_DT  =>fund_rec.PEE_START_DT ,
                                         X_PEE_SEQUENCE_NUMBER =>fund_rec.PEE_SEQUENCE_NUMBER ,
                                         X_FUND_CODE     =>fund_rec.FUND_CODE ,
                                         X_PFE_START_DT  =>fund_rec.PFE_START_DT ,
                                         X_EXPIRY_DT     =>fund_rec.pfe_start_dt,
                                         X_MODE  =>  'R');
            ELSE
                        igs_pe_fund_excl_pkg.update_row(
                                         X_ROWID         =>fund_rec.ROWID ,
                                         X_FUND_EXCL_ID   =>fund_rec.FUND_EXCL_ID,
                                         X_PERSON_ID     =>fund_rec.PERSON_ID ,
                                         X_ENCUMBRANCE_TYPE =>fund_rec.ENCUMBRANCE_TYPE ,
                                         X_PEN_START_DT  =>fund_rec.PEN_START_DT ,
                                         X_S_ENCMB_EFFECT_TYPE =>fund_rec.S_ENCMB_EFFECT_TYPE ,
                                         X_PEE_START_DT  =>fund_rec.PEE_START_DT ,
                                         X_PEE_SEQUENCE_NUMBER =>fund_rec.PEE_SEQUENCE_NUMBER ,
                                         X_FUND_CODE     =>fund_rec.FUND_CODE ,
                                         X_PFE_START_DT  =>fund_rec.PFE_START_DT ,
                                         X_EXPIRY_DT     =>p_expiry_dt,
                                         X_MODE  =>  'R');

            END IF;

        END LOOP;

    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_012.enrp_upd_expiry_dts');
                IGS_GE_MSG_STACK.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
END;
END enrp_upd_expiry_dts;

FUNCTION Enrp_Upd_Sca_Coo(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN  AS
/*
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  sarakshi      19-Nov-2004     Enh#4000939, added column FUTURE_DATED_TRANS_FLAG  in the update row call of IGS_EN_STDNT_PS_ATT_PKG
  ||  ckasu         05-Apr-2004     Modified IGS_EN_STDNT_PS_ATT_Pkg.update_Row procedure
  ||                                call as a part of bug 3544927.
  ||  smaddali        04-jul-03     Bug No: 3035523
  ||       Added the logic for updating the version number in hesa program attempt details belonging to this program attempt
  ||  (reverse chronological order - newest change first)
  || svanukur         17-feb-2004   Added logic to trap the exception IGS_RE_ATND_HIST_STRT_CRS_ATM since this should not be
  ||                                 displayed as an error as per bug 3297473
*/

    v_other_detail  VARCHAR2(255);
    v_person_id IGS_PE_PERSON.person_id%TYPE;
    v_course_cd IGS_PS_OFR_OPT.course_cd%TYPE;
    v_version_number    IGS_PS_OFR_OPT.version_number%TYPE;
    v_cal_type      IGS_PS_OFR_OPT.cal_type%TYPE;
    v_location_cd   IGS_PS_OFR_OPT.location_cd%TYPE;
    v_attendance_mode   IGS_PS_OFR_OPT.attendance_mode%TYPE;
    v_attendance_type   IGS_PS_OFR_OPT.attendance_type%TYPE;
    v_coo_id        IGS_PS_OFR_OPT.coo_id%TYPE;

        CURSOR c_IGS_EN_STDNT_PS_ATT IS
    SELECT  ROWID,
                IGS_EN_STDNT_PS_ATT.*
    FROM    IGS_EN_STDNT_PS_ATT
    WHERE   person_id = p_person_id AND
        course_cd = p_course_cd
    FOR UPDATE NOWAIT;


    --  cursor added as per the HESA DLD  Bug# 3035523.
    -- get the hesa program attempt details for update
    CURSOR c_upd_spa IS
    SELECT spa.rowid , spa.*
    FROM igs_he_st_spa_all spa
    WHERE spa.person_id = p_person_id
        AND spa.course_cd  = p_course_cd
    FOR UPDATE NOWAIT;

    l_enc_message_name VARCHAR2(2000) := NULL;
    l_app_short_name VARCHAR2(10) := NULL;
    l_message_name VARCHAR2(100) := NULL;
    l_mesg_txt VARCHAR2(4000) := NULL;
    l_msg_index NUMBER;

BEGIN
      p_message_name := NULL;

    -- Attempt to lock the record - failure will fall through to
    -- the exception handler.

    v_course_cd := p_course_cd;
    v_version_number := p_version_number;
    v_cal_type := p_cal_type;
    v_location_cd := p_location_cd;
    v_attendance_mode := p_attendance_mode;
    v_attendance_type := p_attendance_type;

    Igs_Ps_Gen_003.crsp_get_coo_key (
        v_coo_id,
        v_course_cd,
        v_version_number,
        v_cal_type,
        v_location_cd,
        v_attendance_mode,
        v_attendance_type);

    -- Having gotten the lock, update the record.

        FOR c_IGS_EN_STDNT_PS_ATT_rec IN c_IGS_EN_STDNT_PS_ATT LOOP

                         Igs_En_Stdnt_Ps_Att_Pkg.UPDATE_ROW(
                                             X_ROWID => c_IGS_EN_STDNT_PS_ATT_rec.ROWID,
                                                 X_PERSON_ID  => c_IGS_EN_STDNT_PS_ATT_rec.PERSON_ID,
                                                 X_COURSE_CD => c_IGS_EN_STDNT_PS_ATT_rec.COURSE_CD,
                                                 X_ADVANCED_STANDING_IND => c_IGS_EN_STDNT_PS_ATT_rec.ADVANCED_STANDING_IND,
                                                 X_FEE_CAT => c_IGS_EN_STDNT_PS_ATT_rec.FEE_CAT,
                                                 X_CORRESPONDENCE_CAT => c_IGS_EN_STDNT_PS_ATT_rec.CORRESPONDENCE_CAT,
                                                 X_SELF_HELP_GROUP_IND => c_IGS_EN_STDNT_PS_ATT_rec.SELF_HELP_GROUP_IND,
                                                 X_LOGICAL_DELETE_DT  => c_IGS_EN_STDNT_PS_ATT_rec.LOGICAL_DELETE_DT,
                                                 X_ADM_ADMISSION_APPL_NUMBER  => c_IGS_EN_STDNT_PS_ATT_rec.ADM_ADMISSION_APPL_NUMBER,
                                                 X_ADM_NOMINATED_COURSE_CD => c_IGS_EN_STDNT_PS_ATT_rec.ADM_NOMINATED_COURSE_CD,
                                                 X_ADM_SEQUENCE_NUMBER  => c_IGS_EN_STDNT_PS_ATT_rec.ADM_SEQUENCE_NUMBER,
                                                 X_VERSION_NUMBER  => p_version_number,
                                                 X_CAL_TYPE => p_cal_type,
                                                 X_LOCATION_CD => p_location_cd,
                                                 X_ATTENDANCE_MODE => p_attendance_mode,
                                                 X_ATTENDANCE_TYPE => p_attendance_type,
                                                 X_COO_ID  => v_coo_id,
                                                 X_STUDENT_CONFIRMED_IND => c_IGS_EN_STDNT_PS_ATT_rec.STUDENT_CONFIRMED_IND,
                                                 X_COMMENCEMENT_DT  => c_IGS_EN_STDNT_PS_ATT_rec.COMMENCEMENT_DT,
                                                 X_COURSE_ATTEMPT_STATUS => c_IGS_EN_STDNT_PS_ATT_rec.COURSE_ATTEMPT_STATUS,
                                                 X_PROGRESSION_STATUS => c_IGS_EN_STDNT_PS_ATT_rec.PROGRESSION_STATUS,
                                                 X_DERIVED_ATT_TYPE => c_IGS_EN_STDNT_PS_ATT_rec.DERIVED_ATT_TYPE,
                                                 X_DERIVED_ATT_MODE => c_IGS_EN_STDNT_PS_ATT_rec.DERIVED_ATT_MODE,
                                                 X_PROVISIONAL_IND => c_IGS_EN_STDNT_PS_ATT_rec.PROVISIONAL_IND,
                                                 X_DISCONTINUED_DT  => c_IGS_EN_STDNT_PS_ATT_rec.DISCONTINUED_DT,
                                                 X_DISCONTINUATION_REASON_CD => c_IGS_EN_STDNT_PS_ATT_rec.DISCONTINUATION_REASON_CD,
                                                 X_LAPSED_DT  => c_IGS_EN_STDNT_PS_ATT_rec.LAPSED_DT,
                                                 X_FUNDING_SOURCE => c_IGS_EN_STDNT_PS_ATT_rec.FUNDING_SOURCE,
                                                 X_EXAM_LOCATION_CD => c_IGS_EN_STDNT_PS_ATT_rec.EXAM_LOCATION_CD,
                                                 X_DERIVED_COMPLETION_YR  => c_IGS_EN_STDNT_PS_ATT_rec.DERIVED_COMPLETION_YR,
                                                 X_DERIVED_COMPLETION_PERD => c_IGS_EN_STDNT_PS_ATT_rec.DERIVED_COMPLETION_PERD,
                                                 X_NOMINATED_COMPLETION_YR  => c_IGS_EN_STDNT_PS_ATT_rec.NOMINATED_COMPLETION_YR,
                                                 X_NOMINATED_COMPLETION_PERD => c_IGS_EN_STDNT_PS_ATT_rec.NOMINATED_COMPLETION_PERD,
                                                 X_RULE_CHECK_IND => c_IGS_EN_STDNT_PS_ATT_rec.RULE_CHECK_IND,
                                                 X_WAIVE_OPTION_CHECK_IND => c_IGS_EN_STDNT_PS_ATT_rec.WAIVE_OPTION_CHECK_IND,
                                                 X_LAST_RULE_CHECK_DT  => c_IGS_EN_STDNT_PS_ATT_rec.LAST_RULE_CHECK_DT,
                                                 X_PUBLISH_OUTCOMES_IND => c_IGS_EN_STDNT_PS_ATT_rec.PUBLISH_OUTCOMES_IND,
                                                 X_COURSE_RQRMNT_COMPLETE_IND => c_IGS_EN_STDNT_PS_ATT_rec.COURSE_RQRMNT_COMPLETE_IND,
                                                 X_COURSE_RQRMNTS_COMPLETE_DT  =>  c_IGS_EN_STDNT_PS_ATT_rec.COURSE_RQRMNTS_COMPLETE_DT,
                                                 X_S_COMPLETED_SOURCE_TYPE => c_IGS_EN_STDNT_PS_ATT_rec.S_COMPLETED_SOURCE_TYPE,
                                                 X_OVERRIDE_TIME_LIMITATION  => c_IGS_EN_STDNT_PS_ATT_rec.OVERRIDE_TIME_LIMITATION,
                                                 X_MODE =>  'R',
                                                 X_LAST_DATE_OF_ATTENDANCE   => c_IGS_EN_STDNT_PS_ATT_rec.LAST_DATE_OF_ATTENDANCE,
                                                 X_DROPPED_BY  => c_IGS_EN_STDNT_PS_ATT_rec.DROPPED_BY,
                                                 X_IGS_PR_CLASS_STD_ID => c_IGS_EN_STDNT_PS_ATT_rec.IGS_PR_CLASS_STD_ID,
                         -- Added next four parameters as per the Career Impact Build Bug# 2027984
                         x_primary_program_type      => c_IGS_EN_STDNT_PS_ATT_rec.primary_program_type,
                         x_primary_prog_type_source  => c_IGS_EN_STDNT_PS_ATT_rec.primary_prog_type_source,
                         x_catalog_cal_type          => c_IGS_EN_STDNT_PS_ATT_rec.catalog_cal_type,
                         x_catalog_seq_num           => c_IGS_EN_STDNT_PS_ATT_rec.catalog_seq_num,
                         x_key_program              =>  c_IGS_EN_STDNT_PS_ATT_rec.key_program,
                         -- The following two parameters were added as part of EN015 build. Bug# 2158654 - pradhakr
                         x_override_cmpl_dt   => c_IGS_EN_STDNT_PS_ATT_rec.override_cmpl_dt,
                         x_manual_ovr_cmpl_dt_ind => c_IGS_EN_STDNT_PS_ATT_rec.manual_ovr_cmpl_dt_ind,
                         -- added by ckasu as part of bug # 3544927
                         X_ATTRIBUTE_CATEGORY                => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE_CATEGORY,
                         X_ATTRIBUTE1                        => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE1,
                         X_ATTRIBUTE2                        => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE2,
                         X_ATTRIBUTE3                        => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE3,
                         X_ATTRIBUTE4                        => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE4,
                         X_ATTRIBUTE5                        => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE5,
                         X_ATTRIBUTE6                        => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE6,
                         X_ATTRIBUTE7                        => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE7,
                         X_ATTRIBUTE8                        => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE8,
                         X_ATTRIBUTE9                        => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE9,
                         X_ATTRIBUTE10                       => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE10,
                         X_ATTRIBUTE11                       => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE11,
                         X_ATTRIBUTE12                       => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE12,
                         X_ATTRIBUTE13                       => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE13,
                         X_ATTRIBUTE14                       => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE14,
                         X_ATTRIBUTE15                       => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE15,
                         X_ATTRIBUTE16                       => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE16,
                         X_ATTRIBUTE17                       => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE17,
                         X_ATTRIBUTE18                       => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE18,
                         X_ATTRIBUTE19                       => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE19,
                         X_ATTRIBUTE20                       => c_IGS_EN_STDNT_PS_ATT_rec.ATTRIBUTE20,
			 X_FUTURE_DATED_TRANS_FLAG           => c_IGS_EN_STDNT_PS_ATT_rec.FUTURE_DATED_TRANS_FLAG);



                --  Start of the New code added as per the HESA bug#3035523
               IF ( c_igs_en_stdnt_ps_att_rec.version_number <> p_version_number AND
                    fnd_profile.value('OSS_COUNTRY_CODE') = 'GB' ) THEN

                      BEGIN
                            FOR c_upd_spa_rec IN c_upd_spa LOOP
                                  -- update the version_number of the hesa program attempt record
                                  IGS_HE_ST_SPA_ALL_PKG.update_row (
                                        x_rowid                       => c_upd_spa_rec.rowid   ,
                                        x_hesa_st_spa_id              => c_upd_spa_rec.hesa_st_spa_id  ,
                                        x_org_id                      => c_upd_spa_rec.org_id  ,
                                        x_person_id                   => c_upd_spa_rec.person_id  ,
                                        x_course_cd                   => c_upd_spa_rec.course_cd  ,
                                        x_version_number              => p_version_number  , -- updated
                                        x_fe_student_marker           => c_upd_spa_rec.fe_student_marker  ,
                                        x_domicile_cd                 => c_upd_spa_rec.domicile_cd   ,
                                        x_inst_last_attended          => c_upd_spa_rec.inst_last_attended  ,
                                        x_year_left_last_inst         => c_upd_spa_rec.year_left_last_inst  ,
                                        x_highest_qual_on_entry       => c_upd_spa_rec.highest_qual_on_entry  ,
                                        x_date_qual_on_entry_calc     => c_upd_spa_rec.date_qual_on_entry_calc  ,
                                        x_a_level_point_score         => c_upd_spa_rec.a_level_point_score  ,
                                        x_highers_points_scores       => c_upd_spa_rec.highers_points_scores  ,
                                        x_occupation_code             => c_upd_spa_rec.occupation_code  ,
                                        x_commencement_dt             => c_upd_spa_rec.commencement_dt  ,
                                        x_special_student             => c_upd_spa_rec.special_student  ,
                                        x_student_qual_aim            => c_upd_spa_rec.student_qual_aim  ,
                                        x_student_fe_qual_aim         => c_upd_spa_rec.student_fe_qual_aim  ,
                                        x_teacher_train_prog_id       => c_upd_spa_rec.teacher_train_prog_id  ,
                                        x_itt_phase                   => c_upd_spa_rec.itt_phase  ,
                                        x_bilingual_itt_marker        => c_upd_spa_rec.bilingual_itt_marker  ,
                                        x_teaching_qual_gain_sector   => c_upd_spa_rec.teaching_qual_gain_sector  ,
                                        x_teaching_qual_gain_subj1    => c_upd_spa_rec.teaching_qual_gain_subj1  ,
                                        x_teaching_qual_gain_subj2    => c_upd_spa_rec.teaching_qual_gain_subj2  ,
                                        x_teaching_qual_gain_subj3    => c_upd_spa_rec.teaching_qual_gain_subj3  ,
                                        x_student_inst_number         => c_upd_spa_rec.student_inst_number  ,
                                        x_destination                 => c_upd_spa_rec.destination  ,
                                        x_itt_prog_outcome            => c_upd_spa_rec.itt_prog_outcome  ,
                                        x_hesa_return_name            => c_upd_spa_rec.hesa_return_name   ,
                                        x_hesa_return_id              => c_upd_spa_rec.hesa_return_id  ,
                                        x_hesa_submission_name        => c_upd_spa_rec.hesa_submission_name  ,
                                        x_associate_ucas_number       => c_upd_spa_rec.associate_ucas_number  ,
                                        x_associate_scott_cand        => c_upd_spa_rec.associate_scott_cand  ,
                                        x_associate_teach_ref_num     => c_upd_spa_rec.associate_teach_ref_num  ,
                                        x_associate_nhs_reg_num       => c_upd_spa_rec.associate_nhs_reg_num   ,
                                        x_nhs_funding_source          => c_upd_spa_rec.nhs_funding_source  ,
                                        x_ufi_place                   => c_upd_spa_rec.ufi_place  ,
                                        x_postcode                    => c_upd_spa_rec.postcode   ,
                                        x_social_class_ind            => c_upd_spa_rec.social_class_ind  ,
                                        x_occcode                     => c_upd_spa_rec.occcode  ,
                                        x_total_ucas_tariff           => c_upd_spa_rec.total_ucas_tariff  ,
                                        x_nhs_employer                => c_upd_spa_rec.nhs_employer   ,
                                        x_return_type                 => c_upd_spa_rec.return_type  ,
                                        x_qual_aim_subj1              => c_upd_spa_rec.qual_aim_subj1  ,
                                        x_qual_aim_subj2              => c_upd_spa_rec.qual_aim_subj2  ,
                                        x_qual_aim_subj3              => c_upd_spa_rec.qual_aim_subj3  ,
                                        x_qual_aim_proportion         => c_upd_spa_rec.qual_aim_proportion ,
                                        x_mode                        => 'R' ,
                                        x_dependants_cd               => c_upd_spa_rec.dependants_cd ,
                                        x_implied_fund_rate           => c_upd_spa_rec.implied_fund_rate ,
                                        x_gov_initiatives_cd          => c_upd_spa_rec.gov_initiatives_cd ,
                                        x_units_for_qual              => c_upd_spa_rec.units_for_qual ,
                                        x_disadv_uplift_elig_cd       => c_upd_spa_rec.disadv_uplift_elig_cd ,
                                        x_franch_partner_cd           => c_upd_spa_rec.franch_partner_cd ,
                                        x_units_completed             => c_upd_spa_rec.units_completed ,
                                        x_franch_out_arr_cd           => c_upd_spa_rec.franch_out_arr_cd ,
                                        x_employer_role_cd            => c_upd_spa_rec.employer_role_cd ,
                                        x_disadv_uplift_factor        => c_upd_spa_rec.disadv_uplift_factor ,
                                        x_enh_fund_elig_cd            => c_upd_spa_rec.enh_fund_elig_cd
                                  ) ;
                            END LOOP ;
                      EXCEPTION
                            WHEN OTHERS THEN
                                  p_message_name := 'IGS_HE_UPD_SPA_FAIL' ;
                                  RETURN FALSE ;
                      END ;

               END IF ; -- end of change in version and country code check
               --  End of the New code added as per the HESA bug#3035523

    -- trap the exception to return true to the calling form along with the message name
    -- so that the message can be shown as a warnign to the user, bug 3297473.

    IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
    FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);
    IF l_message_name = 'IGS_RE_ATND_HIST_STRT_CRS_ATM' THEN
       p_message_name := l_message_name;
       END IF;
    END LOOP;


    RETURN TRUE;


EXCEPTION
      --raise any functional messaged raised as errors to teh calling form
      --to avoid unhandled exceptions when there are valid error messages
      WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
      RAISE;
    WHEN OTHERS THEN
    IF SQLCODE = -54 THEN
            p_message_name := 'IGS_EN_STUD_PRG_REC_LOCKED';
            RETURN FALSE;
        ELSE
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_012.Enrp_Upd_Sca_Coo');
                Igs_Ge_Msg_Stack.ADD;
                    App_Exception.Raise_Exception;
        END IF;
END enrp_upd_sca_coo;



  PROCEDURE invoke_drop_workflow(p_uoo_ids IN VARCHAR2,
                               p_unit_cds IN VARCHAR2,
                               p_teach_cal_type IN VARCHAR2,
                               p_teach_ci_sequence_number IN NUMBER,
                               p_person_id IN NUMBER,
                               p_course_cd IN VARCHAR2,
                               p_source_of_drop IN VARCHAR2,
                               p_message_name IN OUT NOCOPY VARCHAR2)
  AS
/*
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kkillams        08-10-2003      Remove the call to drop_all_workflow procedure and setting the
  ||                                  student unit attempt package variables as part of bug#3160856
*/
    CURSOR c_tl IS
      SELECT load_cal_type, load_ci_sequence_number
      FROM IGS_CA_TEACH_TO_LOAD_V
      WHERE teach_cal_type = p_teach_cal_type
      AND   teach_ci_sequence_number = p_teach_ci_sequence_number
      ORDER BY LOAD_START_DT ASC;

    CURSOR c_reason IS
     SELECT meaning
     FROM IGS_LOOKUPS_VIEW
     WHERE lookup_type = 'CRS_ATTEMPT_STATUS'
     AND   lookup_CODE = 'DISCONTIN';

    l_load_cal_type            IGS_CA_INST.CAL_TYPE%TYPE;
    l_load_ci_sequence_number  IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
    l_return_status            VARCHAR2(10);
    l_meaning                  IGS_LOOKUPS_VIEW.MEANING%TYPE;

  BEGIN

    OPEN c_tl;
    FETCH c_tl INTO l_load_cal_type, l_load_ci_sequence_number;
    CLOSE c_tl;

    OPEN c_reason;
    FETCH c_reason INTO l_meaning;
    CLOSE c_reason;

    FND_MESSAGE.SET_NAME('IGS','IGS_EN_REASON_DRP_UNIT');
    FND_MESSAGE.SET_TOKEN('UNIT',p_unit_cds);
    FND_MESSAGE.SET_TOKEN('REASON',l_meaning);
    igs_ss_en_wrappers.drop_notif_variable(FND_MESSAGE.GET(),p_source_of_drop );

  END invoke_drop_workflow;



FUNCTION Enrp_Upd_Sca_Discont(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_version_number              IN NUMBER ,
  p_course_attempt_status       IN VARCHAR2 ,
  p_commencement_dt             IN DATE ,
  p_discontinued_dt             IN DATE ,
  p_discontinuation_reason_cd   IN VARCHAR2 ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_source                      IN VARCHAR2,
  p_transf_course_cd            IN VARCHAR2
)
/*
  ||  Created By : pkpatel
  ||  Created On : 27-SEP-2002
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  sarakshi        19-Nov-2004     Enh#4000939, added column FUTURE_DATED_TRANS_FLAG  in the update row call of IGS_EN_STDNT_PS_ATT_PKG
  ||  ckasu           05-Apr-2004     Modified IGS_EN_STDNT_PS_ATT_Pkg.update_Row procedure
  ||                                  call as a part of bug 3544927.
  ||  kkillams        21-03-2003      Added new parameter p_transf_course_cd to the function.
  ||                                  Which will distigush the from where this function was called.
  ||                                  Value will be passed if function is invoked from program transfer
  ||                                  else  null value wil come w.r.t bug 2863707
  ||  kkillams        28-04-2003      Modified c_suao_check,c_sua_drop and c_igs_en_su_attempt cursors in this function
  ||                                  due to change in pk of student unit attempt w.r.t. bug number 2829262
  ||  rvangala        07-OCT-2003     Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
  ||                                  and IGS_EN_SU_ATTEMPT_PKG.UPDATE_ROW, added as part of Prevent Dropping Core Units. Enh Bug# 3052432
  ||  ptandon         05-DEC-2003     Modified the cursor c_sua to include the order by clause to select the subordinate units first
  ||                                  for discontinuation. Placements build. Bug# 3052438.
  ||  vkarthik        19-Apr-2004     Modified exception handling section to handle no_ausl_record_found
  ||                                  for bug 3526251
  ||  amuthu          23-Dec-2004     Corrected the logic for setting the program as non-key based on the parameter rather than the sct record
*/
RETURN BOOLEAN  AS
BEGIN
DECLARE
    v_discontinuation_reason_cd             IGS_EN_STDNT_PS_ATT.discontinuation_reason_cd%TYPE;
    v_description                           IGS_EN_DCNT_REASONCD.description%TYPE;
    v_administrative_unit_status            IGS_EN_SU_ATTEMPT.ADMINISTRATIVE_UNIT_STATUS%TYPE;
    v_suao_person_id                        IGS_EN_STDNT_PS_ATT.person_id%TYPE;
    v_sca_status                            IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
    v_alias_val                             DATE;
    v_message_name                          VARCHAR2(30);
    v_admin_unit_status_str                 VARCHAR2(2000);
    v_other_detail                          VARCHAR2(255);
    cst_enrolled                            CONSTANT VARCHAR2(10) := 'ENROLLED';
    cst_lapsed                              CONSTANT VARCHAR2(6) :=  'LAPSED';
    cst_inactive                            CONSTANT VARCHAR2(8) :=  'INACTIVE';
    cst_intermit                            CONSTANT VARCHAR2(8) :=  'INTERMIT';
    cst_discontinue                         CONSTANT VARCHAR2(10) := 'DISCONTIN';
    cst_dropped                             CONSTANT VARCHAR2(10) := 'DROPPED';
    cst_waitlisted                          CONSTANT VARCHAR2(10) := 'WAITLISTED';
    l_primary_prg_type  igs_en_stdnt_ps_att_all.primary_program_type%TYPE;
    v_dummy VARCHAR2(1);
    -- added for bug 3526251
    NO_AUSL_RECORD_FOUND EXCEPTION;
    PRAGMA EXCEPTION_INIT(NO_AUSL_RECORD_FOUND , -20010);

    CURSOR c_sua
        (cp_person_id   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
         cp_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
        SELECT  sua.person_id,
            sua.course_cd,
            sua.unit_cd,
            sua.version_number,
            sua.cal_type,
            sua.ci_sequence_number,
            sua.ci_start_dt,
            sua.enrolled_dt,
            sua.unit_attempt_status,
            sua.uoo_id
        FROM    IGS_EN_SU_ATTEMPT sua
        WHERE   sua.person_id = cp_person_id AND
                sua.course_cd = cp_course_cd AND
                sua.unit_attempt_status IN (cst_enrolled,cst_waitlisted)
        ORDER BY sup_unit_cd ASC
        FOR UPDATE NOWAIT;

    CURSOR c_suao_check
        (cp_person_id       IGS_EN_STDNT_PS_ATT.person_id%TYPE,
         cp_course_cd       IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
         cp_uoo_id          IGS_EN_SU_ATTEMPT.uoo_id%TYPE) IS
        SELECT  suao.person_id
        FROM    IGS_AS_SU_STMPTOUT suao
        WHERE   suao.person_id          = cp_person_id AND
                suao.course_cd          = cp_course_cd AND
                suao.uoo_id             = cp_uoo_id;

    CURSOR c_sca_check
        (cp_person_id       IGS_EN_STDNT_PS_ATT.person_id%TYPE,
        cp_course_cd        IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
        SELECT  sca.course_attempt_status, primary_program_type
        FROM    IGS_EN_STDNT_PS_ATT sca
        WHERE   sca.person_id = cp_person_id AND
                sca.course_cd = cp_course_cd;

    CURSOR c_prgs_in_career IS
        SELECT  'X'
        FROM   igs_en_stdnt_ps_att spa, igs_ps_ver pv1, igs_ps_ver pv2
        WHERE  spa.person_id = p_person_id
        AND    spa.course_cd = p_transf_course_cd -- dest course cd
        AND    pv1.course_cd = spa.course_cd
        AND    pv1.version_number = spa.version_number
        AND    pv2.course_cd = p_course_cd
        AND    pv2.version_number = p_version_number
        AND    pv1.course_type = pv2.course_type;

       CURSOR c_unit_dcnt is
       SELECT DISCONTINUATION_REASON_CD
       FROM IGS_EN_DCNT_REASONCD
       WHERE S_DISCONTINUATION_REASON_TYPE = 'UNIT_TRANS'
       AND DCNT_UNIT_IND = 'Y'
       AND SYS_DFLT_IND = 'Y'
       AND CLOSED_IND = 'N';

       l_unt_disc_code IGS_EN_DCNT_REASONCD.DISCONTINUATION_REASON_CD%TYPE := null;
       l_dflt_disc_code IGS_EN_DCNT_REASONCD.DISCONTINUATION_REASON_CD%TYPE := null;

       CURSOR c_dcnt_rsn IS
       SELECT discontinuation_reason_cd
       FROM igs_en_dcnt_reasoncd
       WHERE  NVL(closed_ind,'N') ='N'
       AND  dflt_ind ='Y'
       AND dcnt_unit_ind ='Y'
       AND s_discontinuation_reason_type IS NULL;

BEGIN
    -- This module updates the IGS_EN_STDNT_PS_ATT future dated
    -- discontinuation.  This will need to do the following :
    -- 1. Discontinue/delete currently enrolled student_unit_attmmpts :
    --  a) check to see if a IGS_EN_SU_ATTEMPT can be deleted
    --     as defined by IGS_PS_UNIT Discontinuation date Criteria
    --  b) if deletion is allowed, delete
    --  c) if deletion is not allowed, then discontinue
    --     IGS_EN_SU_ATTEMPT
    --      i) get administrative IGS_PS_UNIT status
    --         ii) validate that the IGS_EN_SU_ATTEMPT
    --         can be discontinued
    --        iii) set IGS_EN_SU_ATTEMPT discontinuation
    --         details
    --         iv) set IGS_EN_SU_ATTEMPT.unit_attempt_status
    --         (this is done by table database trigger)
    -- 2. Validate that the IGS_EN_STDNT_PS_ATT can be
    --    discontinued
    -- 3. Discontinue IGS_EN_STDNT_PS_ATT, setting default
    --    IGS_EN_DCNT_REASONCD
    -- 4. Set IGS_EN_STDNT_PS_ATT.course_attempt_status (this
    --    is done by table database trigger).
    --
    -- IGS_GE_NOTE : This process will be called to the update student_
    --        course_attempt.course_attempt_status process that
    --    should be run by the job schedular on a nightly
    --    basis.
    -- validate the input parameters
    IF (p_person_id IS NULL OR
        p_course_cd IS NULL OR
        p_discontinued_dt IS NULL) THEN
        p_message_name := 'IGS_EN_INSUFF_INFO_SPA_DISCON';
        RETURN FALSE;
    END IF;
    -- establish a savepoint
    SAVEPOINT sp_discontinue_sua;
    -- setting the message number beforehand
    -- so if failure of the lock occurs, this
    -- value can be passed to the exception handler
    p_message_name := 'IGS_EN_UNABLE_UPD_STUDENR';

     --get the unit discontinuation reason type as part of transfer
       OPEN c_unit_dcnt;
       FETCH c_unit_dcnt into l_unt_disc_code;
       CLOSE c_unit_dcnt;

       OPEN c_dcnt_rsn;
       FETCH c_dcnt_rsn INTO l_dflt_disc_code;
       CLOSE c_dcnt_rsn;

    FOR v_sua IN c_sua(
            p_person_id,
            p_course_cd) LOOP
        -- delete the IGS_EN_SU_ATTEMPT if allowed
      -- Added the OR clause in the below If condtion OR unit_attempt status is WAITLISTED
      -- Added by Nishikant - bug#2364216. If the status is WAITLISTED then no need to check whether the unit attempt can be deleted
        IF (Igs_En_Gen_008.enrp_get_ua_del_alwd(
                v_sua.cal_type,
                v_sua.ci_sequence_number,
                p_discontinued_dt, v_sua.uoo_id) = 'Y'
		  OR v_sua.unit_attempt_status = 'WAITLISTED'
		  OR p_transf_course_cd IS NOT NULL) THEN
            -- check to see whether child
            -- IGS_AS_SU_STMPTOUT records
            -- exist, otherwise a delete can not
            -- be performed on the IGS_EN_SU_ATTEMPT
            -- table
            OPEN c_suao_check(
                p_person_id,
                p_course_cd,
                v_sua.uoo_id);
            FETCH c_suao_check INTO v_suao_person_id;
            IF (c_suao_check%FOUND) THEN
                CLOSE c_suao_check;
                -- rollback to the savepoint
                ROLLBACK TO sp_discontinue_sua;
                p_message_name := 'IGS_EN_ONE_SUA_NOT_DISCONT';
                RETURN FALSE;
            ELSE
                CLOSE c_suao_check;
                -- delete IGS_EN_SU_ATTEMPT
                -- The logic of deleting the Unit attempt status
                -- when trying to discontinue has been modified
                -- to Update the Record with the Unit Attempt status
                -- set to DROPPED
                -- amuthu

                                  DECLARE
                                    v_unit_cds    VARCHAR2(4000);
                                    v_uoo_ids     VARCHAR2(4000);
                                    tr_flag       NUMBER(1);
                                    CURSOR c_sua_drop IS
                                      SELECT sua.ROWID, sua.*
                                      FROM IGS_EN_SU_ATTEMPT sua
                                      WHERE person_id = p_person_id AND
                                            course_cd = p_course_cd AND
                                            uoo_id    = v_sua.uoo_id;
                                    CURSOR c_trans_cd(cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
                                           SELECT 1
                                           FROM IGS_EN_SU_ATTEMPT sua
                                           WHERE person_id      = p_person_id
                                           AND   course_cd      = p_transf_course_cd
                                           AND   uoo_id         = cp_uoo_id
										   AND unit_Attempt_status <> 'DROPPED';
                                  BEGIN
                                    v_uoo_ids := null;
                                    v_unit_cds := null;
                                    FOR sua_drop_rec  IN  c_sua_drop LOOP
                                      --Following validation is added as part of bug fix.2860412
                                      --Cursor will checks the context unit attempt got transferred or not.
                                      --If Unit got transferred then call the direct tbh call else
                                      --call the igs_en_sua_api.update_unit_attempt.
                                      --Reason is,igs_en_sua_api.update_unit_attempt function will
                                      --decrement available seats for that unit section.
                                      tr_flag:=0;
                                      OPEN c_trans_cd(sua_drop_rec.uoo_id);
                                      FETCH c_trans_cd INTO tr_flag;
                                      CLOSE c_trans_cd;
                                      invoke_drop_workflow(
                                        p_uoo_ids                  => v_uoo_ids,
                                        p_unit_cds                 => v_unit_cds,
                                        p_teach_cal_type           => v_sua.cal_type,
                                        p_teach_ci_sequence_number => v_sua.ci_sequence_number,
                                        p_person_id                => p_person_id,
                                        p_course_cd                => p_course_cd,
                                        p_source_of_drop           => p_source,
                                        p_message_name             => v_message_name
                                      );
                                      IF (p_transf_course_cd IS NULL OR tr_flag =0)
                                          THEN
                                          -- Call the API to update the student unit attempt. This API is a
                                          -- wrapper to the update row of the TBH.
                                            igs_en_sua_api.update_unit_attempt(
                                                X_ROWID                      => sua_drop_rec.ROWID,
                                                X_PERSON_ID                  => sua_drop_rec.PERSON_ID,
                                                X_COURSE_CD                  => sua_drop_rec.COURSE_CD ,
                                                X_UNIT_CD                    => sua_drop_rec.UNIT_CD,
                                                X_CAL_TYPE                   => sua_drop_rec.CAL_TYPE,
                                                X_CI_SEQUENCE_NUMBER         => sua_drop_rec.CI_SEQUENCE_NUMBER ,
                                                X_VERSION_NUMBER             => sua_drop_rec.VERSION_NUMBER ,
                                                X_LOCATION_CD                => sua_drop_rec.LOCATION_CD,
                                                X_UNIT_CLASS                 => sua_drop_rec.UNIT_CLASS ,
                                                X_CI_START_DT                => sua_drop_rec.CI_START_DT,
                                                X_CI_END_DT                  => sua_drop_rec.CI_END_DT,
                                                X_UOO_ID                     => sua_drop_rec.UOO_ID ,
                                                X_ENROLLED_DT                => sua_drop_rec.ENROLLED_DT,
                                                X_UNIT_ATTEMPT_STATUS        => cst_dropped, -- c_IGS_EN_SU_ATTEMPT_rec.UNIT_ATTEMPT_STATUS,
                                                X_ADMINISTRATIVE_UNIT_STATUS => sua_drop_rec.administrative_unit_status,
                                                X_ADMINISTRATIVE_PRIORITY    => sua_drop_rec.administrative_PRIORITY,
                                                X_DISCONTINUED_DT            => nvl(sua_drop_rec.discontinued_dt,trunc(SYSDATE)),
                                                X_DCNT_REASON_CD             => l_dflt_disc_code,
                                                X_RULE_WAIVED_DT             => sua_drop_rec.RULE_WAIVED_DT ,
                                                X_RULE_WAIVED_PERSON_ID      => sua_drop_rec.RULE_WAIVED_PERSON_ID ,
                                                X_NO_ASSESSMENT_IND          => sua_drop_rec.NO_ASSESSMENT_IND,
                                                X_SUP_UNIT_CD                => sua_drop_rec.SUP_UNIT_CD ,
                                                X_SUP_VERSION_NUMBER         => sua_drop_rec.SUP_VERSION_NUMBER,
                                                X_EXAM_LOCATION_CD           => sua_drop_rec.EXAM_LOCATION_CD,
                                                X_ALTERNATIVE_TITLE          => sua_drop_rec.ALTERNATIVE_TITLE,
                                                X_OVERRIDE_ENROLLED_CP       => sua_drop_rec.OVERRIDE_ENROLLED_CP,
                                                X_OVERRIDE_EFTSU             => sua_drop_rec.OVERRIDE_EFTSU ,
                                                X_OVERRIDE_ACHIEVABLE_CP     => sua_drop_rec.OVERRIDE_ACHIEVABLE_CP,
                                                X_OVERRIDE_OUTCOME_DUE_DT    => sua_drop_rec.OVERRIDE_OUTCOME_DUE_DT,
                                                X_OVERRIDE_CREDIT_REASON     => sua_drop_rec.OVERRIDE_CREDIT_REASON,
                                                X_WAITLIST_DT                => sua_drop_rec.waitlist_dt,
                                                X_MODE                       =>  'R',
                                                -- Added 5 columns as part of Enroll Process build - amuthu
                                                X_GS_VERSION_NUMBER          => sua_drop_rec.gs_version_number,
                                                X_ENR_METHOD_TYPE            => sua_drop_rec.enr_method_type,
                                                X_FAILED_UNIT_RULE           => sua_drop_rec.FAILED_UNIT_RULE,
                                                X_CART                       => sua_drop_rec.CART,
                                                X_RSV_SEAT_EXT_ID            => sua_drop_rec.RSV_SEAT_EXT_ID ,
                                                X_ORG_UNIT_CD                => sua_drop_rec.org_unit_cd    ,
                                                -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                                X_SESSION_ID                 => sua_drop_rec.session_id,
                                                -- Added the column grading schema as a part of the bug 2037897. - aiyer
                                                X_GRADING_SCHEMA_CODE        => sua_drop_rec.grading_schema_code,
                                                X_DEG_AUD_DETAIL_ID          => sua_drop_rec.deg_aud_detail_id,
                                                X_SUBTITLE                   =>  sua_drop_rec.subtitle,
                                                X_STUDENT_CAREER_TRANSCRIPT  => sua_drop_rec.student_career_transcript,
                                                X_STUDENT_CAREER_STATISTICS  => sua_drop_rec.student_career_statistics,
                                                X_ATTRIBUTE_CATEGORY         => sua_drop_rec.attribute_category,
                                                X_ATTRIBUTE1                 => sua_drop_rec.attribute1,
                                                X_ATTRIBUTE2                 => sua_drop_rec.attribute2,
                                                X_ATTRIBUTE3                 => sua_drop_rec.attribute3,
                                                X_ATTRIBUTE4                 => sua_drop_rec.attribute4,
                                                X_ATTRIBUTE5                 => sua_drop_rec.attribute5,
                                                X_ATTRIBUTE6                 => sua_drop_rec.attribute6,
                                                X_ATTRIBUTE7                 => sua_drop_rec.attribute7,
                                                X_ATTRIBUTE8                 => sua_drop_rec.attribute8,
                                                X_ATTRIBUTE9                 => sua_drop_rec.attribute9,
                                                X_ATTRIBUTE10                => sua_drop_rec.attribute10,
                                                X_ATTRIBUTE11                => sua_drop_rec.attribute11,
                                                X_ATTRIBUTE12                => sua_drop_rec.attribute12,
                                                X_ATTRIBUTE13                => sua_drop_rec.attribute13,
                                                X_ATTRIBUTE14                => sua_drop_rec.attribute14,
                                                X_ATTRIBUTE15                => sua_drop_rec.attribute15,
                                                X_ATTRIBUTE16                => sua_drop_rec.attribute16,
                                                X_ATTRIBUTE17                => sua_drop_rec.attribute17,
                                                X_ATTRIBUTE18                => sua_drop_rec.attribute18,
                                                X_ATTRIBUTE19                => sua_drop_rec.attribute19,
                                                X_ATTRIBUTE20                => sua_drop_rec.attribute20,
                                                X_WAITLIST_MANUAL_IND        => sua_drop_rec.waitlist_manual_ind, --Added by mesriniv for Bug 2554109 Mini Waitlist Build.
                                                X_WLST_PRIORITY_WEIGHT_NUM   => sua_drop_rec.wlst_priority_weight_num,
                                                X_WLST_PREFERENCE_WEIGHT_NUM => sua_drop_rec.wlst_preference_weight_num,
                                                -- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
                                                X_CORE_INDICATOR_CODE        => sua_drop_rec.core_indicator_code
                                                );
                                     ELSE
                                           IF l_unt_disc_code IS NULL THEN
                                      -- implies no system reason for unit drop due to transfer is setup
                                      --hence throw error and return
                                      ROLLBACK to sp_discontinue_sua;
                                      p_message_name := 'IGS_EN_NO_SYS_DFLT_REASON';
                                      RETURN FALSE;
                                      END IF;

                                           IGS_EN_SU_ATTEMPT_PKG.UPDATE_ROW(
                                                X_ROWID                      => sua_drop_rec.ROWID,
                                                X_PERSON_ID                  => sua_drop_rec.PERSON_ID,
                                                X_COURSE_CD                  => sua_drop_rec.COURSE_CD ,
                                                X_UNIT_CD                    => sua_drop_rec.UNIT_CD,
                                                X_CAL_TYPE                   => sua_drop_rec.CAL_TYPE,
                                                X_CI_SEQUENCE_NUMBER         => sua_drop_rec.CI_SEQUENCE_NUMBER ,
                                                X_VERSION_NUMBER             => sua_drop_rec.VERSION_NUMBER ,
                                                X_LOCATION_CD                => sua_drop_rec.LOCATION_CD,
                                                X_UNIT_CLASS                 => sua_drop_rec.UNIT_CLASS ,
                                                X_CI_START_DT                => sua_drop_rec.CI_START_DT,
                                                X_CI_END_DT                  => sua_drop_rec.CI_END_DT,
                                                X_UOO_ID                     => sua_drop_rec.UOO_ID ,
                                                X_ENROLLED_DT                => sua_drop_rec.ENROLLED_DT,
                                                X_UNIT_ATTEMPT_STATUS        => cst_dropped, -- c_IGS_EN_SU_ATTEMPT_rec.UNIT_ATTEMPT_STATUS,
                                                X_ADMINISTRATIVE_UNIT_STATUS => sua_drop_rec.administrative_unit_status,
                                                X_ADMINISTRATIVE_PRIORITY    => sua_drop_rec.administrative_PRIORITY,
                                                X_DISCONTINUED_DT            => nvl(sua_drop_rec.discontinued_dt,SYSDATE),
                                                X_DCNT_REASON_CD             => l_unt_disc_code,
                                                X_RULE_WAIVED_DT             => sua_drop_rec.RULE_WAIVED_DT ,
                                                X_RULE_WAIVED_PERSON_ID      => sua_drop_rec.RULE_WAIVED_PERSON_ID ,
                                                X_NO_ASSESSMENT_IND          => sua_drop_rec.NO_ASSESSMENT_IND,
                                                X_SUP_UNIT_CD                => sua_drop_rec.SUP_UNIT_CD ,
                                                X_SUP_VERSION_NUMBER         => sua_drop_rec.SUP_VERSION_NUMBER,
                                                X_EXAM_LOCATION_CD           => sua_drop_rec.EXAM_LOCATION_CD,
                                                X_ALTERNATIVE_TITLE          => sua_drop_rec.ALTERNATIVE_TITLE,
                                                X_OVERRIDE_ENROLLED_CP       => sua_drop_rec.OVERRIDE_ENROLLED_CP,
                                                X_OVERRIDE_EFTSU             => sua_drop_rec.OVERRIDE_EFTSU ,
                                                X_OVERRIDE_ACHIEVABLE_CP     => sua_drop_rec.OVERRIDE_ACHIEVABLE_CP,
                                                X_OVERRIDE_OUTCOME_DUE_DT    => sua_drop_rec.OVERRIDE_OUTCOME_DUE_DT,
                                                X_OVERRIDE_CREDIT_REASON     => sua_drop_rec.OVERRIDE_CREDIT_REASON,
                                                X_WAITLIST_DT                => sua_drop_rec.waitlist_dt,
                                                X_MODE                       =>  'R',
                                                -- Added 5 columns as part of Enroll Process build - amuthu
                                                X_GS_VERSION_NUMBER          => sua_drop_rec.gs_version_number,
                                                X_ENR_METHOD_TYPE            => sua_drop_rec.enr_method_type,
                                                X_FAILED_UNIT_RULE           => sua_drop_rec.FAILED_UNIT_RULE,
                                                X_CART                       => sua_drop_rec.CART,
                                                X_RSV_SEAT_EXT_ID            => sua_drop_rec.RSV_SEAT_EXT_ID ,
                                                X_ORG_UNIT_CD                => sua_drop_rec.org_unit_cd    ,
                                                -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                                X_SESSION_ID                 => sua_drop_rec.session_id,
                                                -- Added the column grading schema as a part of the bug 2037897. - aiyer
                                                X_GRADING_SCHEMA_CODE        => sua_drop_rec.grading_schema_code,
                                                X_DEG_AUD_DETAIL_ID          => sua_drop_rec.deg_aud_detail_id,
                                                X_SUBTITLE                   =>  sua_drop_rec.subtitle,
                                                X_STUDENT_CAREER_TRANSCRIPT  => sua_drop_rec.student_career_transcript,
                                                X_STUDENT_CAREER_STATISTICS  => sua_drop_rec.student_career_statistics,
                                                X_ATTRIBUTE_CATEGORY         => sua_drop_rec.attribute_category,
                                                X_ATTRIBUTE1                 => sua_drop_rec.attribute1,
                                                X_ATTRIBUTE2                 => sua_drop_rec.attribute2,
                                                X_ATTRIBUTE3                 => sua_drop_rec.attribute3,
                                                X_ATTRIBUTE4                 => sua_drop_rec.attribute4,
                                                X_ATTRIBUTE5                 => sua_drop_rec.attribute5,
                                                X_ATTRIBUTE6                 => sua_drop_rec.attribute6,
                                                X_ATTRIBUTE7                 => sua_drop_rec.attribute7,
                                                X_ATTRIBUTE8                 => sua_drop_rec.attribute8,
                                                X_ATTRIBUTE9                 => sua_drop_rec.attribute9,
                                                X_ATTRIBUTE10                => sua_drop_rec.attribute10,
                                                X_ATTRIBUTE11                => sua_drop_rec.attribute11,
                                                X_ATTRIBUTE12                => sua_drop_rec.attribute12,
                                                X_ATTRIBUTE13                => sua_drop_rec.attribute13,
                                                X_ATTRIBUTE14                => sua_drop_rec.attribute14,
                                                X_ATTRIBUTE15                => sua_drop_rec.attribute15,
                                                X_ATTRIBUTE16                => sua_drop_rec.attribute16,
                                                X_ATTRIBUTE17                => sua_drop_rec.attribute17,
                                                X_ATTRIBUTE18                => sua_drop_rec.attribute18,
                                                X_ATTRIBUTE19                => sua_drop_rec.attribute19,
                                                X_ATTRIBUTE20                => sua_drop_rec.attribute20,
                                                X_WAITLIST_MANUAL_IND        => sua_drop_rec.waitlist_manual_ind ,--Added by mesriniv for Bug 2554109 Mini Waitlist Build.
                                                X_WLST_PRIORITY_WEIGHT_NUM   => sua_drop_rec.wlst_priority_weight_num,
                                                X_WLST_PREFERENCE_WEIGHT_NUM => sua_drop_rec.wlst_preference_weight_num,
                                                -- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
                                                X_CORE_INDICATOR_CODE        => sua_drop_rec.core_indicator_code,
                                                X_UPD_AUDIT_FLAG             => sua_drop_rec.upd_audit_flag,
                                                X_SS_SOURCE_IND              => sua_drop_rec.ss_source_ind
                                               );
                                          END IF;
                                    IF v_unit_cds IS NULL THEN
                                      v_unit_cds := v_sua.unit_Cd;
                                    ELSE
                                      v_unit_cds := v_unit_Cds || ',' || v_sua.unit_Cd;
                                    END IF;
                                    IF v_uoo_ids IS NULL THEN
                                      v_uoo_ids := to_char(sua_drop_rec.uoo_id);
                                    ELSE
                                      v_uoo_ids := v_uoo_ids || ',' || to_char(sua_drop_rec.uoo_id);
                                    END IF;
                                  END LOOP;
                                END;

            END IF;
        ELSE
            -- discontinue IGS_EN_SU_ATTEMPT
            -- get administrative IGS_PS_UNIT status associated
            -- with discontinued
            v_administrative_unit_status := Igs_En_Gen_008.enrp_get_uddc_aus(
                                            p_discontinued_dt,
                                            v_sua.cal_type,
                                            v_sua.ci_sequence_number,
                                            v_admin_unit_status_str,
                                            v_alias_val,
                                            v_sua.uoo_id);
            IF (v_administrative_unit_status IS NULL) THEN
                -- rollback any student_unit_attempts deleted previously
                ROLLBACK TO sp_discontinue_sua;
                p_message_name := 'IGS_EN_ONE_SUA_NOT_DISCONTINU';
                RETURN FALSE;
            END IF;
            -- validate discontinuation
            IF (Igs_En_Val_Sua.enrp_val_sua_discont(
                            p_person_id,
                            p_course_cd,
                            v_sua.unit_cd,
                            v_sua.version_number,
                            v_sua.ci_start_dt,
                            v_sua.enrolled_dt,
                            v_administrative_unit_status,
                            v_sua.unit_attempt_status,
                            p_discontinued_dt,
                            v_message_name ,
                            'N' ) = FALSE) THEN
                -- rollback any student_unit_attempts deleted previously
                ROLLBACK TO sp_discontinue_sua;
                p_message_name := 'IGS_EN_ONE_SUA_NOTBE_DISCONT';
                RETURN FALSE;
            ELSE
                -- update IGS_EN_SU_ATTEMPT

                                DECLARE
                                  v_unit_cds    VARCHAR2(4000);
                                  v_uoo_ids     VARCHAR2(4000);
                                  CURSOR c_igs_en_su_attempt IS
                                    SELECT ROWID, IGS_EN_SU_ATTEMPT.*
                                    FROM   IGS_EN_SU_ATTEMPT
                                    WHERE  person_id          = p_person_id AND
                                           course_cd          = p_course_cd AND
                                           uoo_id             = v_sua.uoo_id;

                                BEGIN
                                  v_uoo_ids := null;
                                  v_unit_cds := null;

                                  FOR  c_IGS_EN_SU_ATTEMPT_rec  IN   c_IGS_EN_SU_ATTEMPT LOOP

                                      --Following validation is added as part of bug fix.2860412
                                      --Cursor will checks the context unit attempt got transferred or not.
                                      --If Unit got transferred then call the direct tbh call else
                                      --call the igs_en_sua_api.update_unit_attempt.
                                      --Reason is,igs_en_sua_api.update_unit_attempt function will
                                      --decrement available seats for the unit section.
                                      invoke_drop_workflow(
                                        p_uoo_ids                  => v_uoo_ids,
                                        p_unit_cds                 => v_unit_cds,
                                        p_teach_cal_type           => v_sua.cal_type,
                                        p_teach_ci_sequence_number => v_sua.ci_sequence_number,
                                        p_person_id                => p_person_id,
                                        p_course_cd                => p_course_cd,
                                        p_source_of_drop           => p_source,
                                        p_message_name             => v_message_name
                                      );
                                        -- Call the API to update the student unit attempt. This API is a
                                        -- wrapper to the update row of the TBH.
                                        igs_en_sua_api.update_unit_attempt(
                                           X_ROWID                      => c_IGS_EN_SU_ATTEMPT_rec.ROWID,
                                           X_PERSON_ID                  => c_IGS_EN_SU_ATTEMPT_rec.PERSON_ID,
                                           X_COURSE_CD                  => c_IGS_EN_SU_ATTEMPT_rec.COURSE_CD ,
                                           X_UNIT_CD                    => c_IGS_EN_SU_ATTEMPT_rec.UNIT_CD,
                                           X_CAL_TYPE                   => c_IGS_EN_SU_ATTEMPT_rec.CAL_TYPE,
                                           X_CI_SEQUENCE_NUMBER         => c_IGS_EN_SU_ATTEMPT_rec.CI_SEQUENCE_NUMBER ,
                                           X_VERSION_NUMBER             => c_IGS_EN_SU_ATTEMPT_rec.VERSION_NUMBER ,
                                           X_LOCATION_CD                => c_IGS_EN_SU_ATTEMPT_rec.LOCATION_CD,
                                           X_UNIT_CLASS                 => c_IGS_EN_SU_ATTEMPT_rec.UNIT_CLASS ,
                                           X_CI_START_DT                => c_IGS_EN_SU_ATTEMPT_rec.CI_START_DT,
                                           X_CI_END_DT                  => c_IGS_EN_SU_ATTEMPT_rec.CI_END_DT,
                                           X_UOO_ID                     => c_IGS_EN_SU_ATTEMPT_rec.UOO_ID ,
                                           X_ENROLLED_DT                => c_IGS_EN_SU_ATTEMPT_rec.ENROLLED_DT,
                                           X_UNIT_ATTEMPT_STATUS        => cst_discontinue, -- c_IGS_EN_SU_ATTEMPT_rec.UNIT_ATTEMPT_STATUS,
                                           X_ADMINISTRATIVE_UNIT_STATUS => v_administrative_unit_status,
                                           X_ADMINISTRATIVE_PRIORITY    => c_IGS_EN_SU_ATTEMPT_rec.administrative_PRIORITY,
                                           X_DISCONTINUED_DT            => p_discontinued_dt,
                                           X_DCNT_REASON_CD             => NULL, -- unable to insert value in to this field
                                           X_RULE_WAIVED_DT             => c_IGS_EN_SU_ATTEMPT_rec.RULE_WAIVED_DT ,
                                           X_RULE_WAIVED_PERSON_ID      => c_IGS_EN_SU_ATTEMPT_rec.RULE_WAIVED_PERSON_ID ,
                                           X_NO_ASSESSMENT_IND          => c_IGS_EN_SU_ATTEMPT_rec.NO_ASSESSMENT_IND,
                                           X_SUP_UNIT_CD                => c_IGS_EN_SU_ATTEMPT_rec.SUP_UNIT_CD ,
                                           X_SUP_VERSION_NUMBER         => c_IGS_EN_SU_ATTEMPT_rec.SUP_VERSION_NUMBER,
                                           X_EXAM_LOCATION_CD           => c_IGS_EN_SU_ATTEMPT_rec.EXAM_LOCATION_CD,
                                           X_ALTERNATIVE_TITLE          => c_IGS_EN_SU_ATTEMPT_rec.ALTERNATIVE_TITLE,
                                           X_OVERRIDE_ENROLLED_CP       => c_IGS_EN_SU_ATTEMPT_rec.OVERRIDE_ENROLLED_CP,
                                           X_OVERRIDE_EFTSU             => c_IGS_EN_SU_ATTEMPT_rec.OVERRIDE_EFTSU ,
                                           X_OVERRIDE_ACHIEVABLE_CP     => c_IGS_EN_SU_ATTEMPT_rec.OVERRIDE_ACHIEVABLE_CP,
                                           X_OVERRIDE_OUTCOME_DUE_DT    => c_IGS_EN_SU_ATTEMPT_rec.OVERRIDE_OUTCOME_DUE_DT,
                                           X_OVERRIDE_CREDIT_REASON     => c_IGS_EN_SU_ATTEMPT_rec.OVERRIDE_CREDIT_REASON,
                                           X_WAITLIST_DT                => c_IGS_EN_SU_ATTEMPT_rec.waitlist_dt,
                                           X_MODE                       =>  'R',
                                           -- Added 5 cols as part of Enrollement Process Build -- amuthu
                                           X_GS_VERSION_NUMBER          => c_IGS_EN_SU_ATTEMPT_rec.gs_version_number,
                                           X_ENR_METHOD_TYPE            => c_IGS_EN_SU_ATTEMPT_rec.enr_method_type,
                                           X_FAILED_UNIT_RULE           => c_IGS_EN_SU_ATTEMPT_rec.FAILED_UNIT_RULE,
                                           X_CART                       => c_IGS_EN_SU_ATTEMPT_rec.cart,
                                           X_RSV_SEAT_EXT_ID            => c_IGS_EN_SU_ATTEMPT_rec.RSV_SEAT_EXT_ID,
                                           X_ORG_UNIT_CD                => c_IGS_EN_SU_ATTEMPT_rec.ORG_UNIT_CD,
                                           -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                           X_SESSION_ID                 => c_IGS_EN_SU_ATTEMPT_rec.SESSION_ID,
                                           -- Added the column grading schema as a part of the bug 2037897. - aiyer
                                           X_GRADING_SCHEMA_CODE        => c_IGS_EN_SU_ATTEMPT_rec.grading_schema_code,
                                           X_DEG_AUD_DETAIL_ID          => c_IGS_EN_SU_ATTEMPT_rec.deg_aud_detail_id,
                                           X_SUBTITLE                   =>  c_IGS_EN_SU_ATTEMPT_rec.subtitle,
                                           X_STUDENT_CAREER_TRANSCRIPT  => c_IGS_EN_SU_ATTEMPT_rec.student_career_transcript,
                                           X_STUDENT_CAREER_STATISTICS  => c_IGS_EN_SU_ATTEMPT_rec.student_career_statistics,
                                           X_ATTRIBUTE_CATEGORY         => c_IGS_EN_SU_ATTEMPT_rec.attribute_category,
                                           X_ATTRIBUTE1                 => c_IGS_EN_SU_ATTEMPT_rec.attribute1,
                                           X_ATTRIBUTE2                 => c_IGS_EN_SU_ATTEMPT_rec.attribute2,
                                           X_ATTRIBUTE3                 => c_IGS_EN_SU_ATTEMPT_rec.attribute3,
                                           X_ATTRIBUTE4                 => c_IGS_EN_SU_ATTEMPT_rec.attribute4,
                                           X_ATTRIBUTE5                 => c_IGS_EN_SU_ATTEMPT_rec.attribute5,
                                           X_ATTRIBUTE6                 => c_IGS_EN_SU_ATTEMPT_rec.attribute6,
                                           X_ATTRIBUTE7                 => c_IGS_EN_SU_ATTEMPT_rec.attribute7,
                                           X_ATTRIBUTE8                 => c_IGS_EN_SU_ATTEMPT_rec.attribute8,
                                           X_ATTRIBUTE9                 => c_IGS_EN_SU_ATTEMPT_rec.attribute9,
                                           X_ATTRIBUTE10                => c_IGS_EN_SU_ATTEMPT_rec.attribute10,
                                           X_ATTRIBUTE11                => c_IGS_EN_SU_ATTEMPT_rec.attribute11,
                                           X_ATTRIBUTE12                => c_IGS_EN_SU_ATTEMPT_rec.attribute12,
                                           X_ATTRIBUTE13                => c_IGS_EN_SU_ATTEMPT_rec.attribute13,
                                           X_ATTRIBUTE14                => c_IGS_EN_SU_ATTEMPT_rec.attribute14,
                                           X_ATTRIBUTE15                => c_IGS_EN_SU_ATTEMPT_rec.attribute15,
                                           X_ATTRIBUTE16                => c_IGS_EN_SU_ATTEMPT_rec.attribute16,
                                           X_ATTRIBUTE17                => c_IGS_EN_SU_ATTEMPT_rec.attribute17,
                                           X_ATTRIBUTE18                => c_IGS_EN_SU_ATTEMPT_rec.attribute18,
                                           X_ATTRIBUTE19                => c_IGS_EN_SU_ATTEMPT_rec.attribute19,
                                           X_ATTRIBUTE20                => c_IGS_EN_SU_ATTEMPT_rec.attribute20,
                                           X_WAITLIST_MANUAL_IND        => c_IGS_EN_SU_ATTEMPT_rec.waitlist_manual_ind ,--Added by mesriniv for Bug 2554109 Mini Waitlist Build.
                                           X_WLST_PRIORITY_WEIGHT_NUM   => c_IGS_EN_SU_ATTEMPT_rec.wlst_priority_weight_num,
                                           X_WLST_PREFERENCE_WEIGHT_NUM => c_IGS_EN_SU_ATTEMPT_rec.wlst_preference_weight_num,
                                           -- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
                                           X_CORE_INDICATOR_CODE        => c_IGS_EN_SU_ATTEMPT_rec.core_indicator_code
                                           );

                                    IF v_unit_cds IS NULL THEN
                                      v_unit_cds := v_sua.unit_cd;
                                    ELSE
                                      v_unit_cds := v_unit_Cds || ',' || v_sua.unit_Cd;
                                    END IF;
                                    IF v_uoo_ids IS NULL THEN
                                      v_uoo_ids := to_char(c_IGS_EN_SU_ATTEMPT_rec.uoo_id);
                                    ELSE
                                      v_uoo_ids := v_uoo_ids || ',' || to_char(c_IGS_EN_SU_ATTEMPT_rec.uoo_id);
                                    END IF;
                                  END LOOP;
                                END;
            END IF;
        END IF;
    END LOOP;
    -- Suspend the current session to overcome problem of multiple updates
    -- affecting the SCA history table with primary key conflicts.
    DBMS_LOCK.SLEEP (1);
    -- discontinue IGS_EN_STDNT_PS_ATT
    -- validate discontinuation
    IF (Igs_En_Val_Sca.enrp_val_sca_discont(
                    p_person_id,
                    p_course_cd,
                    p_version_number,
                    p_course_attempt_status,
                    p_discontinuation_reason_cd,
                    p_discontinued_dt,
                    p_commencement_dt,
                    v_message_name,
                                        'N') = FALSE) THEN
            p_message_name := v_message_name;
            RETURN FALSE;
    ELSE
        -- Check if the IGS_PS_COURSE attempt status has been changed by the IGS_PS_UNIT processing.
        -- If so, check that it is still valid to be discontinued.
        OPEN c_sca_check (
            p_person_id,
            p_course_cd);
        FETCH c_sca_check INTO v_sca_status,l_primary_prg_type;
        IF (c_sca_check%FOUND) THEN
            CLOSE c_sca_check;
            IF v_sca_status IN
                  (cst_enrolled, cst_lapsed, cst_inactive, cst_intermit) OR
                  (v_sca_status= cst_discontinue AND l_primary_prg_type='PRIMARY' AND p_source = 'PROGRAM_TRANSFER' )THEN
                -- discontinue IGS_EN_STDNT_PS_ATT

                             DECLARE
                                   CURSOR c_si_en_stnd_ps_att IS
                                   SELECT ROWID, IGS_EN_STDNT_PS_ATT.*
                                   FROM  IGS_EN_STDNT_PS_ATT
                                   WHERE person_id = p_person_id AND
                                   course_cd = p_course_cd;
                             BEGIN

                                FOR c_si_en_stnd_ps_att_rec IN c_si_en_stnd_ps_att LOOP
                             -- If program discontinuing from the Program transfer form then changing the key_program value to 'N', The FROM program
                             -- discontinueing  and key program value changing to N. pmarada bug 2384025
                              IF p_transf_course_cd IS NOT NULL AND p_source = 'PROGRAM_TRANSFER' THEN

                                 c_si_en_stnd_ps_att_rec.key_program := 'N';
                                 OPEN c_prgs_in_career;
                                 FETCH c_prgs_in_career INTO v_dummy;
                                 IF c_prgs_in_career%FOUND THEN
                    			          c_si_en_stnd_ps_att_rec.primary_program_type := 'SECONDARY';
                                 END IF;
                                 CLOSE c_prgs_in_career;

                              END IF;

                              Igs_En_Stdnt_Ps_Att_Pkg.UPDATE_ROW(
                                                 X_ROWID                        => c_si_en_stnd_ps_att_rec.ROWID,
                                                 X_PERSON_ID                    => c_si_en_stnd_ps_att_rec.PERSON_ID,
                                                 X_COURSE_CD                    => c_si_en_stnd_ps_att_rec.COURSE_CD,
                                                 X_ADVANCED_STANDING_IND        => c_si_en_stnd_ps_att_rec.ADVANCED_STANDING_IND,
                                                 X_FEE_CAT                      => c_si_en_stnd_ps_att_rec.FEE_CAT,
                                                 X_CORRESPONDENCE_CAT           => c_si_en_stnd_ps_att_rec.CORRESPONDENCE_CAT,
                                                 X_SELF_HELP_GROUP_IND          => c_si_en_stnd_ps_att_rec.SELF_HELP_GROUP_IND,
                                                 X_LOGICAL_DELETE_DT            => c_si_en_stnd_ps_att_rec.LOGICAL_DELETE_DT,
                                                 X_ADM_ADMISSION_APPL_NUMBER    => c_si_en_stnd_ps_att_rec.ADM_ADMISSION_APPL_NUMBER,
                                                 X_ADM_NOMINATED_COURSE_CD      => c_si_en_stnd_ps_att_rec.ADM_NOMINATED_COURSE_CD,
                                                 X_ADM_SEQUENCE_NUMBER          => c_si_en_stnd_ps_att_rec.ADM_SEQUENCE_NUMBER,
                                                 X_VERSION_NUMBER               => c_si_en_stnd_ps_att_rec.version_number,
                                                 X_CAL_TYPE                     => c_si_en_stnd_ps_att_rec.cal_type,
                                                 X_LOCATION_CD                  => c_si_en_stnd_ps_att_rec.location_cd,
                                                 X_ATTENDANCE_MODE              => c_si_en_stnd_ps_att_rec.attendance_mode,
                                                 X_ATTENDANCE_TYPE              => c_si_en_stnd_ps_att_rec.attendance_type,
                                                 X_COO_ID                       => c_si_en_stnd_ps_att_rec.coo_id,
                                                 X_STUDENT_CONFIRMED_IND        => c_si_en_stnd_ps_att_rec.STUDENT_CONFIRMED_IND,
                                                 X_COMMENCEMENT_DT              => c_si_en_stnd_ps_att_rec.COMMENCEMENT_DT,
                                                 X_COURSE_ATTEMPT_STATUS        => cst_discontinue, --c_si_en_stnd_ps_att_rec.COURSE_ATTEMPT_STATUS,
                                                 X_PROGRESSION_STATUS           => c_si_en_stnd_ps_att_rec.PROGRESSION_STATUS,
                                                 X_DERIVED_ATT_TYPE             => c_si_en_stnd_ps_att_rec.DERIVED_ATT_TYPE,
                                                 X_DERIVED_ATT_MODE             => c_si_en_stnd_ps_att_rec.DERIVED_ATT_MODE,
                                                 X_PROVISIONAL_IND              => c_si_en_stnd_ps_att_rec.PROVISIONAL_IND,
                                                 X_DISCONTINUED_DT              => p_discontinued_dt,
                                                 X_DISCONTINUATION_REASON_CD    => p_discontinuation_reason_cd,
                                                 X_LAPSED_DT                    => c_si_en_stnd_ps_att_rec.LAPSED_DT,
                                                 X_FUNDING_SOURCE               => c_si_en_stnd_ps_att_rec.FUNDING_SOURCE,
                                                 X_EXAM_LOCATION_CD             => c_si_en_stnd_ps_att_rec.EXAM_LOCATION_CD,
                                                 X_DERIVED_COMPLETION_YR        => c_si_en_stnd_ps_att_rec.DERIVED_COMPLETION_YR,
                                                 X_DERIVED_COMPLETION_PERD      => c_si_en_stnd_ps_att_rec.DERIVED_COMPLETION_PERD,
                                                 X_NOMINATED_COMPLETION_YR      => c_si_en_stnd_ps_att_rec.NOMINATED_COMPLETION_YR,
                                                 X_NOMINATED_COMPLETION_PERD    => c_si_en_stnd_ps_att_rec.NOMINATED_COMPLETION_PERD,
                                                 X_RULE_CHECK_IND               => c_si_en_stnd_ps_att_rec.RULE_CHECK_IND,
                                                 X_WAIVE_OPTION_CHECK_IND       => c_si_en_stnd_ps_att_rec.WAIVE_OPTION_CHECK_IND,
                                                 X_LAST_RULE_CHECK_DT           => c_si_en_stnd_ps_att_rec.LAST_RULE_CHECK_DT,
                                                 X_PUBLISH_OUTCOMES_IND         => c_si_en_stnd_ps_att_rec.PUBLISH_OUTCOMES_IND,
                                                 X_COURSE_RQRMNT_COMPLETE_IND   => c_si_en_stnd_ps_att_rec.COURSE_RQRMNT_COMPLETE_IND,
                                                 X_COURSE_RQRMNTS_COMPLETE_DT   =>  c_si_en_stnd_ps_att_rec.COURSE_RQRMNTS_COMPLETE_DT,
                                                 X_S_COMPLETED_SOURCE_TYPE      => c_si_en_stnd_ps_att_rec.S_COMPLETED_SOURCE_TYPE,
                                                 X_OVERRIDE_TIME_LIMITATION     => c_si_en_stnd_ps_att_rec.OVERRIDE_TIME_LIMITATION,
                                                 X_MODE                         =>  'R',
                                                 X_LAST_DATE_OF_ATTENDANCE      => c_si_en_stnd_ps_att_rec.LAST_DATE_OF_ATTENDANCE,
                                                 X_DROPPED_BY                   => c_si_en_stnd_ps_att_rec.DROPPED_BY,
                                                 X_IGS_PR_CLASS_STD_ID          => c_si_en_stnd_ps_att_rec.IGS_PR_CLASS_STD_ID,
                                                 -- Added next four parameters as per the Career Impact Build Bug# 2027984
                                                 x_primary_program_type         => c_si_en_stnd_ps_att_rec.primary_program_type,
                                                 x_primary_prog_type_source     => c_si_en_stnd_ps_att_rec.primary_prog_type_source,
                                                 x_catalog_cal_type             => c_si_en_stnd_ps_att_rec.catalog_cal_type,
                                                 x_catalog_seq_num              => c_si_en_stnd_ps_att_rec.catalog_seq_num,
                                                 x_key_program                  => c_si_en_stnd_ps_att_rec.key_program,
                                                 -- The following two parameters were added as part of EN015 build. Bug# 2158654 - pradhakr
                                                 x_override_cmpl_dt             => c_si_en_stnd_ps_att_rec.override_cmpl_dt,
                                                 x_manual_ovr_cmpl_dt_ind       => c_si_en_stnd_ps_att_rec.manual_ovr_cmpl_dt_ind,
                                                  -- added by ckasu as a part of bug # 3544927
                                                 X_ATTRIBUTE_CATEGORY                => c_si_en_stnd_ps_att_rec.ATTRIBUTE_CATEGORY,
                                                 X_ATTRIBUTE1                        => c_si_en_stnd_ps_att_rec.ATTRIBUTE1,
                                                 X_ATTRIBUTE2                        => c_si_en_stnd_ps_att_rec.ATTRIBUTE2,
                                                 X_ATTRIBUTE3                        => c_si_en_stnd_ps_att_rec.ATTRIBUTE3,
                                                 X_ATTRIBUTE4                        => c_si_en_stnd_ps_att_rec.ATTRIBUTE4,
                                                 X_ATTRIBUTE5                        => c_si_en_stnd_ps_att_rec.ATTRIBUTE5,
                                                 X_ATTRIBUTE6                        => c_si_en_stnd_ps_att_rec.ATTRIBUTE6,
                                                 X_ATTRIBUTE7                        => c_si_en_stnd_ps_att_rec.ATTRIBUTE7,
                                                 X_ATTRIBUTE8                        => c_si_en_stnd_ps_att_rec.ATTRIBUTE8,
                                                 X_ATTRIBUTE9                        => c_si_en_stnd_ps_att_rec.ATTRIBUTE9,
                                                 X_ATTRIBUTE10                       => c_si_en_stnd_ps_att_rec.ATTRIBUTE10,
                                                 X_ATTRIBUTE11                       => c_si_en_stnd_ps_att_rec.ATTRIBUTE11,
                                                 X_ATTRIBUTE12                       => c_si_en_stnd_ps_att_rec.ATTRIBUTE12,
                                                 X_ATTRIBUTE13                       => c_si_en_stnd_ps_att_rec.ATTRIBUTE13,
                                                 X_ATTRIBUTE14                       => c_si_en_stnd_ps_att_rec.ATTRIBUTE14,
                                                 X_ATTRIBUTE15                       => c_si_en_stnd_ps_att_rec.ATTRIBUTE15,
                                                 X_ATTRIBUTE16                       => c_si_en_stnd_ps_att_rec.ATTRIBUTE16,
                                                 X_ATTRIBUTE17                       => c_si_en_stnd_ps_att_rec.ATTRIBUTE17,
                                                 X_ATTRIBUTE18                       => c_si_en_stnd_ps_att_rec.ATTRIBUTE18,
                                                 X_ATTRIBUTE19                       => c_si_en_stnd_ps_att_rec.ATTRIBUTE19,
                                                 X_ATTRIBUTE20                       => c_si_en_stnd_ps_att_rec.ATTRIBUTE20,
			 			                         X_FUTURE_DATED_TRANS_FLAG           => c_si_en_stnd_ps_att_rec.FUTURE_DATED_TRANS_FLAG
                                                 );
                                END LOOP;
                             END;

            END IF;
        ELSE
            CLOSE c_sca_check;
        END IF;
    END IF;
    -- return the default message
    p_message_name := NULL;
    RETURN TRUE;

EXCEPTION
    -- added for bug 3526251
    WHEN NO_AUSL_RECORD_FOUND THEN
               ROLLBACK TO sp_discontinue_sua;
               RAISE;
    WHEN OTHERS THEN
        IF SQLCODE = -54 THEN
            -- rollback any student_unit_attempts updated
            ROLLBACK TO sp_discontinue_sua;
            RETURN FALSE;
        ELSE
                    Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_012.enrp_upd_sca_discont');
                Igs_Ge_Msg_Stack.ADD;
                    App_Exception.Raise_Exception;
        END IF;
END;
END enrp_upd_sca_discont;


PROCEDURE Enrp_Upd_Sca_Lapse(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_org_unit_cd IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_grace_days IN NUMBER ,
  p_log_creation_dt OUT NOCOPY DATE ,
  p_trm_or_tch_cal_type IN VARCHAR2 ,
  p_trm_or_tch_seq_number IN NUMBER )
 -- add the parameters p_trm_or_tch_cal_type,p_trm_or_tch_seq_number, pmarada
 AS
    gv_other_detail         VARCHAR2(255);
BEGIN
/****************************************************************************
History
  Who      When                   Why
  sarakshi 19-Nov-2004          Enh#4000939, added column FUTURE_DATED_TRANS_FLAG  in the update row call of IGS_EN_STDNT_PS_ATT_PKG
  ckasu    05-Apr-2004          Modified IGS_EN_STDNT_PS_ATT_Pkg.update_Row procedure
                                call as a part of bug 3544927.


*****************************************************************************/
    -- enrp_upd_sca_lapse
    -- Update students who's enrolment has lapsed and set the lapse date in
    -- their IGS_PS_COURSE attempt, which in turn will set their IGS_PS_COURSE attempt status
    -- to lapsed.
    -- IGS_GE_NOTE: This job is run from the report ENRR05E0 which handles the
    -- parameter processing and running the report subsequent to this job
    -- committing the log entry records.

DECLARE
    cst_active  CONSTANT    VARCHAR2(10) := 'ACTIVE';
    cst_inactive    CONSTANT    VARCHAR2(10) := 'INACTIVE';
    cst_enrolled    CONSTANT    VARCHAR2(10) := 'ENROLLED';
    cst_discontin   CONSTANT    VARCHAR2(10) := 'DISCONTIN';
    cst_completed   CONSTANT    VARCHAR2(10) := 'COMPLETED';
    cst_sca_lapse   CONSTANT    VARCHAR2(10) := 'SCA-LAPSE';
    cst_future  CONSTANT    VARCHAR2(10) := 'FUTURE';
    cst_no_future   CONSTANT    VARCHAR2(10) := 'NO-FUTURE';
    e_record_locked         EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_record_locked, -54);
    v_lapse_dt_alias    IGS_EN_CAL_CONF.lapse_dt_alias%TYPE ;
    v_log_creation_dt   IGS_GE_S_LOG.creation_dt%TYPE ;
    v_next_lapse_dt     IGS_CA_DA_INST_V.alias_val%TYPE ;
    v_next_lapse_dt_found   BOOLEAN := FALSE;
    v_enr_form_due_dt   DATE ;
    v_lapsed        BOOLEAN := FALSE;
    v_dummy         VARCHAR2(1);
    v_alternate_code    IGS_CA_INST.alternate_code%TYPE;
    v_last_teaching     VARCHAR2(30);
    CURSOR c_secc IS
        SELECT  secc.lapse_dt_alias
        FROM    IGS_EN_CAL_CONF  secc
        WHERE   secc.s_control_num  = 1;
    CURSOR c_ci IS
        SELECT  ci.start_dt,
                ci.end_dt
        FROM    IGS_CA_INST ci
        WHERE   ci.cal_type = p_acad_cal_type AND
                ci.sequence_number = p_acad_sequence_number;
    v_ci_rec    c_ci%ROWTYPE;
    CURSOR c_daiv (p_cal_type VARCHAR2, p_seq_num NUMBER)IS
        SELECT  daiv.absolute_val alias_val
        FROM    IGS_CA_DA_INST_V    daiv
        WHERE   daiv.cal_type       = p_cal_type AND
            daiv.ci_sequence_number = p_seq_num AND
            daiv.dt_alias       = v_lapse_dt_alias
        ORDER BY daiv.absolute_val; -- first row found is the earliest date
        --modified for perf bug 3699543 : sqlid 14792129
    CURSOR c_sca_crv IS
        SELECT  sca.person_id,
            sca.course_cd
        FROM    IGS_EN_STDNT_PS_ATT     sca,
            IGS_PS_VER          crv
        WHERE   sca.cal_type            = p_acad_cal_type AND
            sca.course_cd           LIKE p_course_cd AND
            sca.course_attempt_status   = cst_inactive AND
            crv.course_cd           = sca.course_cd AND
            crv.version_number      = sca.version_number AND
            (crv.responsible_org_unit_cd    LIKE p_org_unit_cd OR
            EXISTS  (
                SELECT  'X'
                FROM    IGS_OR_INST_ORG_BASE_V ou,
                    IGS_OR_STATUS   os
                WHERE   ou.PARTY_NUMBER  LIKE p_org_unit_cd AND
                     os.org_status   = ou.org_status AND
                     os.s_org_status = cst_active AND
                     Igs_Or_Gen_001.orgp_get_within_ou(ou.PARTY_NUMBER,
                             ou.start_dt,
                             crv.responsible_org_unit_cd,
                             crv.responsible_ou_start_dt,
                             'N')
                             = 'Y')) AND
             (p_enrolment_cat        = '%' OR
             EXISTS  (
                 SELECT  'X'
                 FROM    IGS_AS_SC_ATMPT_ENR scae
                 WHERE   scae.person_id      = sca.person_id AND
                     scae.course_cd      = sca.course_cd AND
                     Igs_En_Gen_014.enrs_get_within_ci(p_acad_cal_type,
                                 p_acad_sequence_number,
                                 scae.cal_type,
                                 scae.ci_sequence_number,
                                 'Y')
                                = 'Y' AND
                     scae.enrolment_cat  LIKE p_enrolment_cat));
    CURSOR c_scae_ci (cp_person_id      IGS_AS_SC_ATMPT_ENR.person_id%TYPE,
            cp_course_cd        IGS_AS_SC_ATMPT_ENR.course_cd%TYPE) IS
        SELECT  scae.person_id,
            scae.course_cd,
            scae.cal_type,
            scae.ci_sequence_number,
            scae.enr_form_due_dt
        FROM    IGS_AS_SC_ATMPT_ENR scae,
            IGS_CA_INST     ci
        WHERE   scae.person_id      = cp_person_id AND
            scae.course_cd      = cp_course_cd AND
            ci.cal_type     = scae.cal_type AND
            ci.sequence_number  = scae.ci_sequence_number AND
            ci.end_dt       > SYSDATE
        ORDER BY ci.start_dt        DESC;   -- for latest date
    CURSOR c_sua (
        cp_person_id        IGS_EN_SU_ATTEMPT.person_id%TYPE,
        cp_course_cd        IGS_EN_SU_ATTEMPT.course_cd%TYPE) IS
        SELECT  ci.alternate_code,
                sua.cal_type,
                sua.ci_sequence_number
        FROM    IGS_EN_SU_ATTEMPT   sua,
                IGS_CA_INST ci
        WHERE   sua.person_id       = cp_person_id AND
            sua.course_cd       = cp_course_cd AND
            sua.unit_attempt_status IN (cst_enrolled,cst_discontin,cst_completed) AND
            sua.ci_start_dt <= TRUNC(SYSDATE) AND
            ci.cal_type = sua.cal_type AND
            ci.sequence_number = sua.ci_sequence_number
        ORDER BY    ci_start_dt DESC;
    v_sua_rec   c_sua%ROWTYPE;
    v_scae_ci_rec               c_scae_ci%ROWTYPE;
    CURSOR c_sca (
        cp_person_id        IGS_EN_SU_ATTEMPT.person_id%TYPE,
        cp_course_cd        IGS_EN_SU_ATTEMPT.course_cd%TYPE) IS
        SELECT  ROWID,sca.*
        FROM    IGS_EN_STDNT_PS_ATT sca
        WHERE   sca.person_id       = cp_person_id AND
            sca.course_cd       = cp_course_cd
        FOR UPDATE  NOWAIT;
        v_sca_exists        c_sca%ROWTYPE;

    CURSOR c_teachLoad(cp_cal_type VARCHAR2, cp_ci_sequence_number NUMBER) IS
               SELECT start_dt, end_dt FROM IGS_CA_INST_ALL
               WHERE cal_type = cp_cal_type AND
                     sequence_number = cp_ci_sequence_number;
    v_teachload_rec    c_teachload%ROWTYPE;
    v_trm_or_tch_start_date  DATE;
    v_trm_or_tch_end_date    DATE;

BEGIN
    -- Load the calendar configuration details which point to lapse date aliases.
    -- If no configuration details exist, or the lapse date alias is null then
    -- raise an exception. The process cannot continue.
    OPEN c_secc;
    FETCH c_secc INTO v_lapse_dt_alias;
    IF (c_secc%NOTFOUND) THEN
        CLOSE c_secc;

                    Fnd_Message.Set_Name('IGS', 'IGS_EN_NO_CAL_CONFIG_DTL_XS');
                Igs_Ge_Msg_Stack.ADD;
                    App_Exception.Raise_Exception;

        END IF;
    CLOSE c_secc;
    IF v_lapse_dt_alias IS NULL THEN
                    Fnd_Message.Set_Name('IGS', 'IGS_EN_LAPSE_DT_ALIAS_NOT_SET');
                Igs_Ge_Msg_Stack.ADD;
                    App_Exception.Raise_Exception;
    END IF;
    -- Create a system log to hold details of students who have lapsed.
    OPEN c_ci;
    FETCH c_ci INTO v_ci_rec;
    CLOSE c_ci;

        OPEN c_teachLoad( p_trm_or_tch_cal_type, p_trm_or_tch_seq_number);
        FETCH c_teachLoad INTO v_teachload_rec ;
        IF c_teachLoad%FOUND THEN
           v_trm_or_tch_start_date := v_teachload_rec.start_dt;
           v_trm_or_tch_end_date := v_teachload_rec.end_dt;
        END IF;
        CLOSE c_teachload;

    Igs_Ge_Gen_003.genp_ins_log(cst_sca_lapse,
            p_acad_cal_type || ',' ||
            TO_CHAR(p_acad_sequence_number) || ',' ||
            TO_CHAR(v_ci_rec.start_dt,'DD/MM/YYYY') || ',' ||
            TO_CHAR(v_ci_rec.end_dt,'DD/MM/YYYY') || ',' ||
            p_org_unit_cd || ',' ||
            p_course_cd || ',' ||
            p_enrolment_cat || ',' ||
            TO_CHAR(p_grace_days) || ',' ||
                        p_trm_or_tch_cal_type || ',' ||
                        TO_CHAR(p_trm_or_tch_seq_number) || ',' ||
                        TO_CHAR(v_trm_or_tch_start_date, 'DD/MM/YYYY') || ',' ||
                        TO_CHAR(v_trm_or_tch_end_date ,'DD/MM/YYYY') ,
            v_log_creation_dt);
        --  passing p_trm_or_tch_cal_type,p_trm_or_seq_number,P_trm_or_tch_start_date,p_trm_or_tch_end_date parameters.
        --  bug no 1830175 pmarada

    p_log_creation_dt := v_log_creation_dt;
    -- Select the next relevant lapse date in the Term period.
        -- bugno 1830175 pmarada
    FOR v_alias_val_rec IN c_daiv (p_trm_or_tch_cal_type, p_trm_or_tch_seq_number) LOOP
            v_next_lapse_dt_found := TRUE;
            IF v_alias_val_rec.alias_val >= SYSDATE THEN
                v_next_lapse_dt := v_alias_val_rec.alias_val;
                EXIT;
            END IF;
    END LOOP;
    -- Select the next relevant lapse date in the academic period.
        IF NOT v_next_lapse_dt_found THEN
       FOR v_alias_val_rec IN c_daiv (p_acad_cal_type, p_acad_sequence_number) LOOP
            v_next_lapse_dt_found := TRUE;
            IF v_alias_val_rec.alias_val >= SYSDATE THEN
                v_next_lapse_dt := v_alias_val_rec.alias_val;
                EXIT;
            END IF;
       END LOOP;
        END IF;

    IF NOT v_next_lapse_dt_found THEN
        -- c_daiv record not found
        v_next_lapse_dt := SYSDATE;
    END IF;
    -- If there is no future date (or no date at all - which means always lapse)
    -- then exit the routine - nobody has to be lapsed
    IF v_next_lapse_dt IS NULL THEN
        RETURN;
    END IF;

    -- Select students who are currently inactive and match the parameters
    FOR v_sca_crv_rec IN c_sca_crv LOOP
        -- Determine if the student has been pre-enrolled for a future
        -- enrollment period and has not yet passed the enrolment form
        -- due date
        v_lapsed := TRUE;
        OPEN c_scae_ci(
                v_sca_crv_rec.person_id,
                v_sca_crv_rec.course_cd);
        FETCH c_scae_ci INTO v_scae_ci_rec;
        IF (c_scae_ci%FOUND) THEN
            -- Call routine to determine the enrolment form due date for
            -- the scae record
            v_enr_form_due_dt := Igs_En_Gen_004.enrp_get_scae_due(v_scae_ci_rec.person_id,
                                v_scae_ci_rec.course_cd,
                                v_scae_ci_rec.cal_type,
                                v_scae_ci_rec.ci_sequence_number,
                                'Y',
                                v_scae_ci_rec.enr_form_due_dt);
            IF v_enr_form_due_dt IS NOT NULL THEN

                IF v_enr_form_due_dt + p_grace_days > SYSDATE THEN
                    v_lapsed := FALSE;
                END IF;
            END IF;

        END IF;
        CLOSE c_scae_ci;
        IF v_lapsed THEN
            BEGIN
                -- Anybody who has reached this point in the code is to be lapsed
                -- as they are not enrolled for a future period, and there is a
                -- lapse date >= the SYSDATE value.
                OPEN c_sca(
                        v_sca_crv_rec.person_id,
                        v_sca_crv_rec.course_cd);
                FETCH c_sca INTO v_sca_exists;
                IF (c_sca%FOUND) THEN
                      Igs_En_Stdnt_Ps_Att_Pkg.UPDATE_ROW(
                                             X_ROWID => v_sca_exists.ROWID,
                                                 X_PERSON_ID  => v_sca_exists.PERSON_ID,
                                                 X_COURSE_CD => v_sca_exists.COURSE_CD,
                                                 X_ADVANCED_STANDING_IND => v_sca_exists.ADVANCED_STANDING_IND,
                                                 X_FEE_CAT => v_sca_exists.FEE_CAT,
                                                 X_CORRESPONDENCE_CAT => v_sca_exists.CORRESPONDENCE_CAT,
                                                 X_SELF_HELP_GROUP_IND => v_sca_exists.SELF_HELP_GROUP_IND,
                                                 X_LOGICAL_DELETE_DT  => v_sca_exists.LOGICAL_DELETE_DT,
                                                 X_ADM_ADMISSION_APPL_NUMBER  => v_sca_exists.ADM_ADMISSION_APPL_NUMBER,
                                                 X_ADM_NOMINATED_COURSE_CD => v_sca_exists.ADM_NOMINATED_COURSE_CD,
                                                 X_ADM_SEQUENCE_NUMBER  => v_sca_exists.ADM_SEQUENCE_NUMBER,
                                                 X_VERSION_NUMBER  => v_sca_exists.version_number,
                                                 X_CAL_TYPE => v_sca_exists.cal_type,
                                                 X_LOCATION_CD => v_sca_exists.location_cd,
                                                 X_ATTENDANCE_MODE => v_sca_exists.attendance_mode,
                                                 X_ATTENDANCE_TYPE => v_sca_exists.attendance_type,
                                                 X_COO_ID  => v_sca_exists.coo_id,
                                                 X_STUDENT_CONFIRMED_IND => v_sca_exists.STUDENT_CONFIRMED_IND,
                                                 X_COMMENCEMENT_DT  => v_sca_exists.COMMENCEMENT_DT,
                                                 X_COURSE_ATTEMPT_STATUS =>v_sca_exists.COURSE_ATTEMPT_STATUS,
                                                 X_PROGRESSION_STATUS => v_sca_exists.PROGRESSION_STATUS,
                                                 X_DERIVED_ATT_TYPE => v_sca_exists.DERIVED_ATT_TYPE,
                                                 X_DERIVED_ATT_MODE => v_sca_exists.DERIVED_ATT_MODE,
                                                 X_PROVISIONAL_IND => v_sca_exists.PROVISIONAL_IND,
                                                 X_DISCONTINUED_DT  => v_sca_exists.discontinued_dt,
                                                 X_DISCONTINUATION_REASON_CD => v_sca_exists.discontinuation_reason_cd,
                                                 X_LAPSED_DT  => TRUNC(SYSDATE),
                                                 X_FUNDING_SOURCE => v_sca_exists.FUNDING_SOURCE,
                                                 X_EXAM_LOCATION_CD => v_sca_exists.EXAM_LOCATION_CD,
                                                 X_DERIVED_COMPLETION_YR  => v_sca_exists.DERIVED_COMPLETION_YR,
                                                 X_DERIVED_COMPLETION_PERD => v_sca_exists.DERIVED_COMPLETION_PERD,
                                                 X_NOMINATED_COMPLETION_YR  => v_sca_exists.NOMINATED_COMPLETION_YR,
                                                 X_NOMINATED_COMPLETION_PERD => v_sca_exists.NOMINATED_COMPLETION_PERD,
                                                 X_RULE_CHECK_IND => v_sca_exists.RULE_CHECK_IND,
                                                 X_WAIVE_OPTION_CHECK_IND => v_sca_exists.WAIVE_OPTION_CHECK_IND,
                                                 X_LAST_RULE_CHECK_DT  => v_sca_exists.LAST_RULE_CHECK_DT,
                                                 X_PUBLISH_OUTCOMES_IND => v_sca_exists.PUBLISH_OUTCOMES_IND,
                                                 X_COURSE_RQRMNT_COMPLETE_IND => v_sca_exists.COURSE_RQRMNT_COMPLETE_IND,
                                                 X_COURSE_RQRMNTS_COMPLETE_DT  =>  v_sca_exists.COURSE_RQRMNTS_COMPLETE_DT,
                                                 X_S_COMPLETED_SOURCE_TYPE => v_sca_exists.S_COMPLETED_SOURCE_TYPE,
                                                 X_OVERRIDE_TIME_LIMITATION  => v_sca_exists.OVERRIDE_TIME_LIMITATION,
                                                 X_MODE =>  'R',
                         X_LAST_DATE_OF_ATTENDANCE  => v_sca_exists.LAST_DATE_OF_ATTENDANCE,
                                                 X_DROPPED_BY  => v_sca_exists.DROPPED_BY,
                         X_IGS_PR_CLASS_STD_ID => v_sca_exists.IGS_PR_CLASS_STD_ID,
                         -- Added next four parameters as per the Career Impact Build Bug# 2027984
                         x_primary_program_type      => v_sca_exists.primary_program_type,
                         x_primary_prog_type_source  => v_sca_exists.primary_prog_type_source,
                         x_catalog_cal_type          => v_sca_exists.catalog_cal_type,
                         x_catalog_seq_num           => v_sca_exists.catalog_seq_num,
                         x_key_program              =>  v_sca_exists.key_program,
                         -- The following two parameters were added as part of EN015 build. Bug# 2158654 - pradhakr
                         x_override_cmpl_dt   => v_sca_exists.override_cmpl_dt,
                         x_manual_ovr_cmpl_dt_ind => v_sca_exists.manual_ovr_cmpl_dt_ind,
                         -- added by ckasu as part of bug # 3544927
                         X_ATTRIBUTE_CATEGORY                => v_sca_exists.ATTRIBUTE_CATEGORY,
                         X_ATTRIBUTE1                        => v_sca_exists.ATTRIBUTE1,
                         X_ATTRIBUTE2                        => v_sca_exists.ATTRIBUTE2,
                         X_ATTRIBUTE3                        => v_sca_exists.ATTRIBUTE3,
                         X_ATTRIBUTE4                        => v_sca_exists.ATTRIBUTE4,
                         X_ATTRIBUTE5                        => v_sca_exists.ATTRIBUTE5,
                         X_ATTRIBUTE6                        => v_sca_exists.ATTRIBUTE6,
                         X_ATTRIBUTE7                        => v_sca_exists.ATTRIBUTE7,
                         X_ATTRIBUTE8                        => v_sca_exists.ATTRIBUTE8,
                         X_ATTRIBUTE9                        => v_sca_exists.ATTRIBUTE9,
                         X_ATTRIBUTE10                       => v_sca_exists.ATTRIBUTE10,
                         X_ATTRIBUTE11                       => v_sca_exists.ATTRIBUTE11,
                         X_ATTRIBUTE12                       => v_sca_exists.ATTRIBUTE12,
                         X_ATTRIBUTE13                       => v_sca_exists.ATTRIBUTE13,
                         X_ATTRIBUTE14                       => v_sca_exists.ATTRIBUTE14,
                         X_ATTRIBUTE15                       => v_sca_exists.ATTRIBUTE15,
                         X_ATTRIBUTE16                       => v_sca_exists.ATTRIBUTE16,
                         X_ATTRIBUTE17                       => v_sca_exists.ATTRIBUTE17,
                         X_ATTRIBUTE18                       => v_sca_exists.ATTRIBUTE18,
                         X_ATTRIBUTE19                       => v_sca_exists.ATTRIBUTE19,
                         X_ATTRIBUTE20                       => v_sca_exists.ATTRIBUTE20,
                         X_FUTURE_DATED_TRANS_FLAG           => v_sca_exists.FUTURE_DATED_TRANS_FLAG
                         );


                              DECLARE
                                CURSOR c1 IS
                                --modified for performance bug 3699543
                                SELECT 'X'
                                            FROM    igs_pe_typ_instances_all PTI,
                                        IGS_PE_PERSON_TYPES PPT
                                        WHERE PPT.system_type = 'STUDENT' AND
                                              ppt.person_type_code = pti.person_type_code AND
                                              pti.COURSE_CD = v_sca_exists.COURSE_CD AND
                                      pti.PERSON_ID = v_sca_exists.PERSON_ID;

                                c1_rec c1%ROWTYPE;

                                                CURSOR c_former_stdnt IS
                                                SELECT person_type_code
                                                FROM igs_pe_person_types
                                                WHERE system_type = 'FORMER_STUDENT';

                                l_person_type_code igs_pe_person_types.person_type_code%TYPE := NULL;

                                l_rowid VARCHAR2(25);
                                l_pk NUMBER(15);
                                l_org_id NUMBER := igs_ge_gen_003.get_org_id;

                             BEGIN
                                    -- fetching person_type_code for system_type of 'FORMER_STUDENT'
                                OPEN c_former_stdnt;
                                FETCH c_former_stdnt INTO l_person_type_code;
                                CLOSE c_former_stdnt;

                                    OPEN c1;
                                FETCH c1 INTO c1_rec;
                                IF c1%FOUND THEN

                                DECLARE
                                        CURSOR c2 IS
                                        SELECT ROWID, ti.*
                                        FROM igs_pe_typ_instances_all ti
                                        WHERE course_cd =  v_sca_exists.COURSE_CD AND
                                          person_id =  v_sca_exists.PERSON_ID;

                                        l_rowid VARCHAR2(25);
                                        l_pk NUMBER(15);

                                BEGIN

                                        FOR c2_rec IN c2 LOOP
                                              Igs_Pe_Typ_Instances_Pkg.update_row(
                                          --   X_ROWID =>l_rowid,     -- Old
                                             X_ROWID =>c2_rec.ROWID,  -- New due to bug no#1516658
                                             X_PERSON_ID =>c2_rec.PERSON_ID,
                                             X_COURSE_CD =>c2_rec.COURSE_CD,
                                             X_TYPE_INSTANCE_ID =>c2_rec.TYPE_INSTANCE_ID,
                                             X_PERSON_TYPE_CODE =>c2_rec.PERSON_TYPE_CODE,
                                             X_CC_VERSION_NUMBER =>c2_rec.CC_VERSION_NUMBER,
                                             X_FUNNEL_STATUS =>c2_rec.FUNNEL_STATUS,
                                             X_ADMISSION_APPL_NUMBER =>c2_rec.ADMISSION_APPL_NUMBER,
                                             X_NOMINATED_COURSE_CD =>c2_rec.NOMINATED_COURSE_CD,
                                             X_NCC_VERSION_NUMBER =>c2_rec.NCC_VERSION_NUMBER,
                                             X_SEQUENCE_NUMBER =>c2_rec.SEQUENCE_NUMBER,
                                             X_START_DATE =>c2_rec.START_DATE,
                                             X_END_DATE => SYSDATE,
                                             X_CREATE_METHOD =>c2_rec.CREATE_METHOD,
                                             X_ENDED_BY =>c2_rec.ENDED_BY,
                                             X_END_METHOD =>'PRG_ATTMPT_ST_INACTIVE',
                                             X_MODE =>'R',
                                             X_EMPLMNT_CATEGORY_CODE => c2_rec.emplmnt_category_code);

                                        END LOOP; -- End loop for Ending the Type.

                                                            Igs_Pe_Typ_Instances_Pkg.insert_row(
                                             X_ROWID =>l_rowid,
                                             X_PERSON_ID => v_sca_exists.PERSON_ID,
                                             X_COURSE_CD =>v_sca_exists.COURSE_CD,
                                             X_TYPE_INSTANCE_ID =>l_pk,
                                             X_PERSON_TYPE_CODE =>l_person_type_code,
                                             X_CC_VERSION_NUMBER =>NULL,
                                             X_FUNNEL_STATUS => NULL,
                                             X_ADMISSION_APPL_NUMBER=>
                                               v_sca_exists.ADM_ADMISSION_APPL_NUMBER,
                                             X_NOMINATED_COURSE_CD =>
                                               v_sca_exists.ADM_NOMINATED_COURSE_CD,
                                             X_NCC_VERSION_NUMBER =>v_sca_exists.VERSION_NUMBER,
                                             X_SEQUENCE_NUMBER =>NULL,
                                             X_START_DATE => SYSDATE,
                                             X_END_DATE =>NULL,
                                             X_CREATE_METHOD =>'PRG_ATTMPT_ST_LAPSED',
                                             X_ENDED_BY =>NULL,
                                             X_END_METHOD =>NULL,
                                             X_MODE =>'R',
                                                 x_org_id => l_org_id,
                                                 X_EMPLMNT_CATEGORY_CODE => null);
                                 END;-- End for Update Process

                                 ELSE -- If Cursor%NOTFOUND

                                       Igs_Pe_Typ_Instances_Pkg.insert_row(
                                         X_ROWID =>l_rowid,
                                         X_PERSON_ID => v_sca_exists.PERSON_ID,
                                         X_COURSE_CD =>v_sca_exists.COURSE_CD,
                                         X_TYPE_INSTANCE_ID =>l_pk,
                                         X_PERSON_TYPE_CODE =>l_person_type_code,
                                         X_CC_VERSION_NUMBER =>NULL,
                                         X_FUNNEL_STATUS => NULL,
                                         X_ADMISSION_APPL_NUMBER
                                            =>v_sca_exists.ADM_ADMISSION_APPL_NUMBER,
                                         X_NOMINATED_COURSE_CD
                                                    =>v_sca_exists.ADM_NOMINATED_COURSE_CD,
                                         X_NCC_VERSION_NUMBER =>v_sca_exists.VERSION_NUMBER,
                                         X_SEQUENCE_NUMBER =>NULL,
                                         X_START_DATE => SYSDATE,
                                         X_END_DATE =>NULL,
                                         X_CREATE_METHOD =>'PRG_ATTMPT_ST_LAPSED',
                                         X_ENDED_BY =>NULL,
                                         X_END_METHOD =>NULL,
                                         X_MODE =>'R',
                                                                     x_org_id => l_org_id,
                                                 X_EMPLMNT_CATEGORY_CODE => null);

                                END IF;-- End IF for Cursor%FOUND
                              CLOSE C1;
                        END;

                    CLOSE c_sca;
                ELSE
                    CLOSE c_sca;
                END IF; --End IF for sca%found

                OPEN c_sua(
                    v_sca_crv_rec.person_id,
                    v_sca_crv_rec.course_cd);
                FETCH c_sua INTO v_sua_rec;
                IF (c_sua%FOUND) THEN
                    v_alternate_code := Igs_En_Gen_014.ENRS_GET_ACAD_ALT_CD(v_sua_rec.cal_type,
                                                        v_sua_rec.ci_sequence_number);
                    v_last_teaching := v_alternate_code || '/' || v_sua_rec.alternate_code;
                ELSE
                    v_last_teaching := '-';
                END IF;
                CLOSE c_sua;

                -- Write log entry indicating future enrolled IGS_PS_UNIT attempts
                -- were found - typically the student will be intermittent
                -- or the like.

                Igs_Ge_Gen_003.genp_ins_log_entry(cst_sca_lapse,
                        v_log_creation_dt,
                        v_sca_crv_rec.person_id || ',' ||
                        v_sca_crv_rec.course_cd || ',' ||
                        v_last_teaching,
                        NULL,
                        NULL);
            EXCEPTION

                WHEN e_record_locked THEN
                    NULL;
            END;
        END IF; -- End If for  v_lapsed
    END LOOP;
    -- initially thought of commenting the commit statement but on investigating it found that
    -- this procedure is called from IGSEN%01.rdf reports hence the commit is used
    -- Hence do not comment this commit statement
    -- amuthu 27-jul-2001
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_secc%ISOPEN) THEN
            CLOSE c_secc;
        END IF;
        IF (c_daiv%ISOPEN) THEN
            CLOSE c_daiv;
        END IF;
        IF (c_sca_crv%ISOPEN) THEN
            CLOSE c_sca_crv;
        END IF;
        IF (c_scae_ci%ISOPEN) THEN
            CLOSE c_scae_ci;
        END IF;
        IF (c_sua%ISOPEN) THEN
            CLOSE c_sua;
        END IF;
        RAISE;
END;
EXCEPTION
    WHEN OTHERS THEN

                    Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_012.enrp_upd_sca_lapse');
                Igs_Ge_Msg_Stack.ADD;
                        App_Exception.Raise_Exception;
END enrp_upd_sca_lapse;

FUNCTION Enrp_Upd_Sca_Status(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN  AS
    CURSOR c_sca    (cp_person_id IGS_EN_STDNT_PS_ATT.person_id%TYPE,
             cp_course_cd IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
    IS
    SELECT  sca.course_attempt_status
    FROM    IGS_EN_STDNT_PS_ATT sca
    WHERE   sca.person_id = p_person_id AND
        sca.course_cd = p_course_cd;
    v_course_attempt_status         IGS_LOOKUPS_VIEW.LOOKUP_CODE%TYPE;
    v_new_course_attempt_status
            IGS_LOOKUPS_VIEW.LOOKUP_CODE%TYPE;
    v_other_detail  VARCHAR2(255);
    v_person_id IGS_PE_PERSON.person_id%TYPE;
/****************************************************************************
History
  Who      When                   Why
  sarakshi 19-Nov-2004          Enh#4000939, added column FUTURE_DATED_TRANS_FLAG  in the update row call of IGS_EN_STDNT_PS_ATT_PKG
  ckasu    05-Apr-2004          Modified IGS_EN_STDNT_PS_ATT_Pkg.update_Row procedure
                                call as a part of bug 3544927.

*****************************************************************************/
BEGIN
    p_message_name := NULL;
    OPEN c_sca (p_person_id, p_course_cd);
    FETCH c_sca INTO v_course_attempt_status;
    IF c_sca%NOTFOUND THEN
        CLOSE c_sca;
        RETURN TRUE;
    END IF;
    CLOSE c_sca;
    v_new_course_attempt_status := Igs_En_Gen_006.ENRP_GET_SCA_STATUS(p_person_id,
            p_course_cd,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL);

  IF v_course_attempt_status <> v_new_course_attempt_status THEN
        -- Attempt to lock the record - failure will fall through to
        -- the exception handler.
    DECLARE
      CURSOR c_ps_att IS
      SELECT    ROWID,
                IGS_EN_STDNT_PS_ATT.*
      FROM  IGS_EN_STDNT_PS_ATT
      WHERE person_id = p_person_id AND
                course_cd = p_course_cd
      FOR UPDATE NOWAIT;
    BEGIN
        -- Having gotten the lock, update the record.

      FOR c_ps_att_rec IN c_ps_att LOOP
        Igs_En_Stdnt_Ps_Att_Pkg.UPDATE_ROW(
            X_ROWID => c_ps_att_rec.ROWID,
            X_PERSON_ID  => c_ps_att_rec.PERSON_ID,
            X_COURSE_CD => c_ps_att_rec.COURSE_CD,
            X_ADVANCED_STANDING_IND => c_ps_att_rec.ADVANCED_STANDING_IND,
            X_FEE_CAT => c_ps_att_rec.FEE_CAT,
            X_CORRESPONDENCE_CAT => c_ps_att_rec.CORRESPONDENCE_CAT,
            X_SELF_HELP_GROUP_IND => c_ps_att_rec.SELF_HELP_GROUP_IND,
            X_LOGICAL_DELETE_DT  => c_ps_att_rec.LOGICAL_DELETE_DT,
            X_ADM_ADMISSION_APPL_NUMBER  => c_ps_att_rec.ADM_ADMISSION_APPL_NUMBER,
            X_ADM_NOMINATED_COURSE_CD => c_ps_att_rec.ADM_NOMINATED_COURSE_CD,
            X_ADM_SEQUENCE_NUMBER  => c_ps_att_rec.ADM_SEQUENCE_NUMBER,
            X_VERSION_NUMBER  => c_ps_att_rec.version_number,
            X_CAL_TYPE => c_ps_att_rec.cal_type,
            X_LOCATION_CD => c_ps_att_rec.location_cd,
            X_ATTENDANCE_MODE => c_ps_att_rec.attendance_mode,
            X_ATTENDANCE_TYPE => c_ps_att_rec.attendance_type,
            X_COO_ID  => c_ps_att_rec.coo_id,
            X_STUDENT_CONFIRMED_IND => c_ps_att_rec.STUDENT_CONFIRMED_IND,
            X_COMMENCEMENT_DT  => c_ps_att_rec.COMMENCEMENT_DT,
            X_COURSE_ATTEMPT_STATUS => v_new_course_attempt_status,
            X_PROGRESSION_STATUS => c_ps_att_rec.PROGRESSION_STATUS,
            X_DERIVED_ATT_TYPE => c_ps_att_rec.DERIVED_ATT_TYPE,
            X_DERIVED_ATT_MODE => c_ps_att_rec.DERIVED_ATT_MODE,
            X_PROVISIONAL_IND => c_ps_att_rec.PROVISIONAL_IND,
            X_DISCONTINUED_DT  => c_ps_att_rec.discontinued_dt,
            X_DISCONTINUATION_REASON_CD => c_ps_att_rec.discontinuation_reason_cd,
            X_LAPSED_DT  =>c_ps_att_rec.lapsed_dt,
            X_FUNDING_SOURCE => c_ps_att_rec.FUNDING_SOURCE,
            X_EXAM_LOCATION_CD => c_ps_att_rec.EXAM_LOCATION_CD,
            X_DERIVED_COMPLETION_YR  => c_ps_att_rec.DERIVED_COMPLETION_YR,
            X_DERIVED_COMPLETION_PERD => c_ps_att_rec.DERIVED_COMPLETION_PERD,
            X_NOMINATED_COMPLETION_YR  => c_ps_att_rec.NOMINATED_COMPLETION_YR,
            X_NOMINATED_COMPLETION_PERD => c_ps_att_rec.NOMINATED_COMPLETION_PERD,
            X_RULE_CHECK_IND => c_ps_att_rec.RULE_CHECK_IND,
            X_WAIVE_OPTION_CHECK_IND => c_ps_att_rec.WAIVE_OPTION_CHECK_IND,
            X_LAST_RULE_CHECK_DT  => c_ps_att_rec.LAST_RULE_CHECK_DT,
            X_PUBLISH_OUTCOMES_IND => c_ps_att_rec.PUBLISH_OUTCOMES_IND,
            X_COURSE_RQRMNT_COMPLETE_IND => c_ps_att_rec.COURSE_RQRMNT_COMPLETE_IND,
            X_COURSE_RQRMNTS_COMPLETE_DT  =>  c_ps_att_rec.COURSE_RQRMNTS_COMPLETE_DT,
            X_S_COMPLETED_SOURCE_TYPE => c_ps_att_rec.S_COMPLETED_SOURCE_TYPE,
            X_OVERRIDE_TIME_LIMITATION  => c_ps_att_rec.OVERRIDE_TIME_LIMITATION,
            X_MODE =>  'R',
        X_LAST_DATE_OF_ATTENDANCE  => c_ps_att_rec.LAST_DATE_OF_ATTENDANCE,
            X_DROPPED_BY   => c_ps_att_rec.DROPPED_BY,
            X_IGS_PR_CLASS_STD_ID => c_ps_att_rec.IGS_PR_CLASS_STD_ID,
        -- Added next four parameters as per the Career Impact Build Bug# 2027984
        x_primary_program_type      => c_ps_att_rec.primary_program_type,
        x_primary_prog_type_source  => c_ps_att_rec.primary_prog_type_source,
        x_catalog_cal_type          => c_ps_att_rec.catalog_cal_type,
        x_catalog_seq_num           => c_ps_att_rec.catalog_seq_num,
        x_key_program               => c_ps_att_rec.key_program,
        -- The following two parameters were added as part of EN015 build. Bug# 2158654 - pradhakr
        x_override_cmpl_dt    => c_ps_att_rec.override_cmpl_dt,
        x_manual_ovr_cmpl_dt_ind => c_ps_att_rec.manual_ovr_cmpl_dt_ind,
        -- added by ckasu as part of bug # 3544927
        X_ATTRIBUTE_CATEGORY                => c_ps_att_rec.ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1                        => c_ps_att_rec.ATTRIBUTE1,
        X_ATTRIBUTE2                        => c_ps_att_rec.ATTRIBUTE2,
        X_ATTRIBUTE3                        => c_ps_att_rec.ATTRIBUTE3,
        X_ATTRIBUTE4                        => c_ps_att_rec.ATTRIBUTE4,
        X_ATTRIBUTE5                        => c_ps_att_rec.ATTRIBUTE5,
        X_ATTRIBUTE6                        => c_ps_att_rec.ATTRIBUTE6,
        X_ATTRIBUTE7                        => c_ps_att_rec.ATTRIBUTE7,
        X_ATTRIBUTE8                        => c_ps_att_rec.ATTRIBUTE8,
        X_ATTRIBUTE9                        => c_ps_att_rec.ATTRIBUTE9,
        X_ATTRIBUTE10                       => c_ps_att_rec.ATTRIBUTE10,
        X_ATTRIBUTE11                       => c_ps_att_rec.ATTRIBUTE11,
        X_ATTRIBUTE12                       => c_ps_att_rec.ATTRIBUTE12,
        X_ATTRIBUTE13                       => c_ps_att_rec.ATTRIBUTE13,
        X_ATTRIBUTE14                       => c_ps_att_rec.ATTRIBUTE14,
        X_ATTRIBUTE15                       => c_ps_att_rec.ATTRIBUTE15,
        X_ATTRIBUTE16                       => c_ps_att_rec.ATTRIBUTE16,
        X_ATTRIBUTE17                       => c_ps_att_rec.ATTRIBUTE17,
        X_ATTRIBUTE18                       => c_ps_att_rec.ATTRIBUTE18,
        X_ATTRIBUTE19                       => c_ps_att_rec.ATTRIBUTE19,
        X_ATTRIBUTE20                       => c_ps_att_rec.ATTRIBUTE20,
        X_FUTURE_DATED_TRANS_FLAG           => c_ps_att_rec.FUTURE_DATED_TRANS_FLAG
        );

        IF v_new_course_attempt_status= 'LAPSED' THEN

          DECLARE
                  CURSOR c1 IS
               -- modified for perf bug 3699560
               SELECT 'X'
               FROM igs_pe_typ_instances_all PTI,
                    IGS_PE_PERSON_TYPES PPT
               WHERE PPT.system_type = 'STUDENT' AND
                     ppt.person_type_code = pti.person_type_code
               AND pti.COURSE_CD = c_ps_att_rec.COURSE_CD
               AND pti.PERSON_ID = c_ps_att_rec.PERSON_ID;

               c1_rec c1%ROWTYPE;

                       CURSOR c_former_stdnt IS
                         SELECT person_type_code
                         FROM igs_pe_person_types
                         WHERE system_type = 'FORMER_STUDENT';

                         l_person_type_code igs_pe_person_types.person_type_code%TYPE := NULL;


             l_rowid VARCHAR2(25);
             l_pk NUMBER(15);

             BEGIN

                      -- fetching person_type_code for system_type of 'FORMER_STUDENT'
                                         OPEN c_former_stdnt;
                                         FETCH c_former_stdnt INTO l_person_type_code;
                                         CLOSE c_former_stdnt;
                        OPEN c1;
                        FETCH c1 INTO c1_rec;
                          IF c1%FOUND THEN
                           DECLARE
                             CURSOR c2 IS
                             SELECT ROWID, ti.*
                             FROM igs_pe_typ_instances_all ti
                             WHERE course_cd =  c_ps_att_rec.COURSE_CD
                             AND   person_id =  c_ps_att_rec.PERSON_ID;
                             l_rowid VARCHAR2(25);
                             l_pk NUMBER(15);
                             l_org_id NUMBER := igs_ge_gen_003.get_org_id;
                           BEGIN



                               FOR c2_rec IN c2 LOOP

                                  Igs_Pe_Typ_Instances_Pkg.update_row(
                                  -- previously l_rowid was being passed to the update row
                                  -- changed it to c2_rec.rowid
                                  -- amuthu 27-Jul-2001
                                 X_ROWID =>c2_rec.ROWID,
                                 X_PERSON_ID =>c2_rec.PERSON_ID,
                                 X_COURSE_CD =>c2_rec.COURSE_CD,
                                 X_TYPE_INSTANCE_ID =>c2_rec.TYPE_INSTANCE_ID,
                                 X_PERSON_TYPE_CODE =>c2_rec.PERSON_TYPE_CODE,
                                 X_CC_VERSION_NUMBER =>c2_rec.CC_VERSION_NUMBER,
                                 X_FUNNEL_STATUS =>c2_rec.FUNNEL_STATUS,
                                 X_ADMISSION_APPL_NUMBER =>c2_rec.ADMISSION_APPL_NUMBER,
                                 X_NOMINATED_COURSE_CD =>c2_rec.NOMINATED_COURSE_CD,
                                 X_NCC_VERSION_NUMBER =>c2_rec.NCC_VERSION_NUMBER,
                                 X_SEQUENCE_NUMBER =>c2_rec.SEQUENCE_NUMBER,
                                 X_START_DATE =>c2_rec.START_DATE,
                                 X_END_DATE => SYSDATE,
                                 X_CREATE_METHOD =>c2_rec.CREATE_METHOD,
                                 X_ENDED_BY =>c2_rec.ENDED_BY,
                                 X_END_METHOD =>'PRG_ATTMPT_ST_INACTIVE',
                                 X_MODE =>'R',
                                 X_EMPLMNT_CATEGORY_CODE => c2_rec.emplmnt_category_code);
                            END LOOP; -- End loop for Ending the Type.


                               Igs_Pe_Typ_Instances_Pkg.insert_row(
                                 X_ROWID =>l_rowid,
                                 X_PERSON_ID => c_ps_att_rec.PERSON_ID,
                                 X_COURSE_CD =>c_ps_att_rec.COURSE_CD,
                                 X_TYPE_INSTANCE_ID =>l_pk,
                                 X_PERSON_TYPE_CODE =>l_person_type_code,
                                 X_CC_VERSION_NUMBER =>NULL,
                                 X_FUNNEL_STATUS => NULL,
                                 X_ADMISSION_APPL_NUMBER=>
                                    c_ps_att_rec.ADM_ADMISSION_APPL_NUMBER,
                                 X_NOMINATED_COURSE_CD =>
                                    c_ps_att_rec.ADM_NOMINATED_COURSE_CD,
                                 X_NCC_VERSION_NUMBER =>c_ps_att_rec.VERSION_NUMBER,
                                 X_SEQUENCE_NUMBER =>NULL,
                                 X_START_DATE => SYSDATE,
                                 X_END_DATE =>NULL,
                                 X_CREATE_METHOD =>'PRG_ATTMPT_ST_LAPSED',
                                 X_ENDED_BY =>NULL,
                                 X_END_METHOD =>NULL,
                                 X_MODE =>'R',
                                                 x_org_id => l_org_id,
                                                 X_EMPLMNT_CATEGORY_CODE => null);
                         END;-- End for Update Process
                      ELSE -- If Cursor%NOTFOUND
                         DECLARE
                            l_org_id NUMBER := igs_ge_gen_003.get_org_id;
                               BEGIN
                               Igs_Pe_Typ_Instances_Pkg.insert_row(
                                 X_ROWID =>l_rowid,
                                 X_PERSON_ID => c_ps_att_rec.PERSON_ID,
                                 X_COURSE_CD =>c_ps_att_rec.COURSE_CD,
                                 X_TYPE_INSTANCE_ID =>l_pk,
                                 X_PERSON_TYPE_CODE =>l_person_type_code,
                                 X_CC_VERSION_NUMBER =>NULL,
                                 X_FUNNEL_STATUS => NULL,
                                 X_ADMISSION_APPL_NUMBER
                                    =>c_ps_att_rec.ADM_ADMISSION_APPL_NUMBER,
                                 X_NOMINATED_COURSE_CD
                                            =>c_ps_att_rec.ADM_NOMINATED_COURSE_CD,
                                 X_NCC_VERSION_NUMBER =>c_ps_att_rec.VERSION_NUMBER,
                                 X_SEQUENCE_NUMBER =>NULL,
                                 X_START_DATE => SYSDATE,
                                 X_END_DATE =>NULL,
                                 X_CREATE_METHOD =>'PRG_ATTMPT_ST_LAPSED',
                                 X_ENDED_BY =>NULL,
                                 X_END_METHOD =>NULL,
                                 X_MODE =>'R',
                                                             x_org_id => l_org_id,
                                                 X_EMPLMNT_CATEGORY_CODE => null);
                                                  END;
                      END IF;-- End IF for Cursor%FOUND
                  CLOSE C1;
            END;
        END IF;
    END LOOP;
  END;

  --Included this code  as a part of bug 2335633 to indicate the program attempt status has changed.
  p_message_name := 'IGS_AD_OK';
 END IF;
 RETURN TRUE;
/*commented as part of BUg 1571109
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -54 THEN
            p_message_name := 'IGS_EN_STUD_PRG_REC_LOCKED';
            RETURN FALSE;
        ELSE
                    Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_012.Enrp_Upd_Sca_Status');
                Igs_Ge_Msg_Stack.ADD;
                        App_Exception.Raise_Exception;
        END IF;
*/
END enrp_upd_sca_status;

PROCEDURE Enrp_Upd_Sca_Statusb(
   errbuf OUT NOCOPY VARCHAR2,
   retcode OUT NOCOPY NUMBER,
   p_org_id IN NUMBER)
 AS
------------------------------------------------------------------------
--  sarakshi  13-sep-2001  modified cursor c_sci_comm and c_sci_end
--                         as a part of Acedemic Record Maintenance Build.
-- rnirwani   13-Sep-2004    changed cursor c_sci_comm, c_sci_end to not consider logically deleted records and
--				also to avoid un-approved intermission records. Bug# 3885804
-- smaddali    Modified for build EN324 - bug#5091858
-------------------------------------------------------------------------
    gv_other_detail             VARCHAR2(255);

BEGIN
   retcode := 0;
   IGS_GE_GEN_003.set_org_id(p_org_id);
DECLARE
    v_creation_dt       DATE;
    v_updates_done      NUMBER;
    v_message_name      VARCHAR2(30);
    v_log_text          VARCHAR2(2000);

    CURSOR  c_sci_comm IS
        SELECT  sca.person_id,
            sca.course_cd,
            sca.course_attempt_status
        FROM    IGS_EN_STDNT_PS_INTM sci,
                        IGS_EN_INTM_TYPES eit,
            IGS_EN_STDNT_PS_ATT sca
        WHERE   sci.start_dt            <= trunc(SYSDATE) AND
            sci.end_dt          >= trunc(SYSDATE)    AND
            sci.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY') AND
            sca.person_id           = sci.person_id AND
            sca.course_cd           = sci.course_cd AND
                        eit.intermission_type=sci.intermission_type  AND
                        ((eit.appr_reqd_ind ='Y' AND sci.approved='Y') OR (eit.appr_reqd_ind='N'))  AND
            sca.course_attempt_status   NOT IN ('INTERMIT',
                                'DISCONTIN',
                                'DELETED',
                                'COMPLETED');

    CURSOR  c_sci_end IS
        SELECT  sca.person_id,
            sca.course_cd,
            sca.course_attempt_status,
            sci.start_dt,
            sci.logical_delete_date,
            cond_return_flag
        FROM    IGS_EN_STDNT_PS_INTM sci,
                IGS_EN_INTM_TYPES eit,
            IGS_EN_STDNT_PS_ATT sca
        WHERE   sci.end_dt          < TRUNC(SYSDATE) AND
            sca.person_id           = sci.person_id AND
            sca.course_cd           = sci.course_cd AND
            sci.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY') AND
            eit.intermission_type=sci.intermission_type  AND
           ((eit.appr_reqd_ind ='Y' AND sci.approved='Y') OR (eit.appr_reqd_ind='N'))  AND
            sca.course_attempt_status   = 'INTERMIT';

    CURSOR  c_scae IS
        SELECT  sca.person_id, sca.course_cd, sca.course_attempt_status
        FROM    IGS_EN_STDNT_PS_ATT sca
        WHERE   sca.course_attempt_status = 'ENROLLED' AND
                (
                  sca.discontinued_dt IS NULL OR
                  sca.discontinued_dt > SYSDATE
                 ) AND
        NOT EXISTS (    SELECT 'x'
                FROM    IGS_EN_SU_ATTEMPT sua
                WHERE   sua.person_id       = sca.person_id AND
                    sua.unit_attempt_status = 'ENROLLED'    AND
                    sua.ci_start_dt     <= SYSDATE)     AND
        NOT EXISTS (    SELECT 'x'
                FROM    IGS_AS_SC_ATMPT_ENR scae
                WHERE   scae.person_id              = sca.person_id AND
                    scae.course_cd              = sca.course_cd AND
                    Igs_En_Gen_004.ENRP_GET_SCAE_DUE(
                            scae.person_id,
                            scae.course_cd,
                            scae.cal_type,
                            scae.ci_sequence_number,
                            'Y',
                            scae.enr_form_due_dt)    > SYSDATE );

    CURSOR  c_sca_inactive IS
        SELECT  sca.person_id,
            sca.course_cd,
            sca.course_attempt_status
        FROM    IGS_EN_STDNT_PS_ATT sca
        WHERE   sca.course_attempt_status IN ('INACTIVE','LAPSED') AND
            EXISTS (
            SELECT 'x'
            FROM    IGS_EN_SU_ATTEMPT sua
            WHERE   person_id       = sca.person_id AND
                course_cd       = sca.course_cd AND
                unit_attempt_status     = 'ENROLLED'    AND
                ci_start_dt         <= SYSDATE);

    CURSOR  c_sca_future IS
        SELECT  sca.person_id,
            sca.course_cd,
            sca.version_number,
            sca.course_attempt_status,
            sca.commencement_dt,
            sca.discontinued_dt,
            sca.discontinuation_reason_cd
        FROM    IGS_EN_STDNT_PS_ATT sca
        WHERE   sca.discontinued_dt         IS NOT NULL     AND
            sca.discontinued_dt         <= SYSDATE  AND
            sca.course_attempt_status   NOT IN ('DISCONTIN',
                                'DELETED');
     -- smaddali added cursor for build EN324 - bug#5091858
     CURSOR c_sci_rcond (cp_person_id hz_parties.party_id%TYPE,
                         cp_course_cd igs_ps_ver.course_cd%TYPE,
                         cp_start_dt DATE,
                         cp_logical_del_dt DATE) IS
         SELECT hz.party_number
         FROM igs_en_spi_rconds rc, hz_parties hz
         WHERE rc.person_id = hz.party_id
         AND rc.person_id =cp_person_id
         AND rc.course_cd =cp_course_cd
         AND rc.start_dt =cp_start_dt
         AND rc.logical_delete_date =cp_logical_del_dt
         AND rc.status_code IN('FAILED','PENDING');
     l_rcond_exists c_sci_rcond%ROWTYPE;


    FUNCTION enrpl_upd_get_status(
        p_person_id         IGS_EN_STDNT_PS_ATT.person_id%TYPE,
        p_course_cd         IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
        p_course_attempt_status     IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE)
    RETURN BOOLEAN
     AS
            e_resource_busy_exception       EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
        l_msg_text VARCHAR2(2000);

        CURSOR c_person_number (cp_person_id HZ_PARTIES.PARTY_ID%TYPE) IS
        SELECT PARTY_NUMBER
        FROM HZ_PARTIES
        WHERE party_id = cp_person_id;

        l_person_number HZ_PARTIES.PARTY_NUMBER%TYPE;

      /****************************************************************************
      History
      Who      When                   Why
      sarakshi 19-Nov-2004          Enh#4000939, added column FUTURE_DATED_TRANS_FLAG  in the update row call of IGS_EN_STDNT_PS_ATT_PKG
      ckasu    05-Apr-2004          Modified IGS_EN_STDNT_PS_ATT_Pkg.update_Row procedure
                                call as a part of bug 3544927.
       *****************************************************************************/
        BEGIN   -- enrpl_upd_get_status

        -- This local function calls the function enrp_get_sca_status.
            -- If the return value is different to the current
            -- student_course_attempt_status the status is updated and TRUE
        -- is returned otherwise FALSE is returned.
        -- If a locked record is encountered the offending record is recorded
            -- and FALSE is returned allowing processing to continue.

        OPEN c_person_number(p_person_id);
        FETCH c_person_number INTO l_person_number;
        CLOSE c_person_number;

	SAVEPOINT enrpl_upd_get_status_a;

        DECLARE
                v_new_course_attempt_status
    IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
        v_person_id         IGS_EN_STDNT_PS_ATT.person_id%TYPE;
        BEGIN


                v_new_course_attempt_status := Igs_En_Gen_006.enrp_get_sca_status(
                                              p_person_id,
                                              p_course_cd,
                                              NULL,  -- course_attempt_status
                                              NULL,  -- student_cnfirmed_ind
                                              NULL,  -- discontinued_dt
                                              NULL,  -- lapsed_dt
                                              NULL,  -- course_rqrmnt_complete_ind
                                              NULL); -- logical_delete_dt

        IF (v_new_course_attempt_status <> p_course_attempt_status) THEN
            -- Attempt to lock the record - failure will fall through to
            -- the exception handler.

                     DECLARE
                        CURSOR c_enps_att IS
            SELECT  ROWID,
                                IGS_EN_STDNT_PS_ATT.*
            FROM    IGS_EN_STDNT_PS_ATT
            WHERE   person_id = p_person_id AND
                course_cd = p_course_cd
            FOR UPDATE NOWAIT;
                     BEGIN

            -- Having gotten the lock, update the record.
                      FOR c_enps_att_rec IN c_enps_att LOOP



                        Igs_En_Stdnt_Ps_Att_Pkg.UPDATE_ROW(
                                                 X_ROWID => c_enps_att_rec.ROWID,
                                                 X_PERSON_ID  => c_enps_att_rec.PERSON_ID,
                                                 X_COURSE_CD => c_enps_att_rec.COURSE_CD,
                                                 X_ADVANCED_STANDING_IND => c_enps_att_rec.ADVANCED_STANDING_IND,
                                                 X_FEE_CAT => c_enps_att_rec.FEE_CAT,
                                                 X_CORRESPONDENCE_CAT => c_enps_att_rec.CORRESPONDENCE_CAT,
                                                 X_SELF_HELP_GROUP_IND => c_enps_att_rec.SELF_HELP_GROUP_IND,
                                                 X_LOGICAL_DELETE_DT  => c_enps_att_rec.LOGICAL_DELETE_DT,
                                                 X_ADM_ADMISSION_APPL_NUMBER  => c_enps_att_rec.ADM_ADMISSION_APPL_NUMBER,
                                                 X_ADM_NOMINATED_COURSE_CD => c_enps_att_rec.ADM_NOMINATED_COURSE_CD,
                                                 X_ADM_SEQUENCE_NUMBER  => c_enps_att_rec.ADM_SEQUENCE_NUMBER,
                                                 X_VERSION_NUMBER  => c_enps_att_rec.version_number,
                                                 X_CAL_TYPE => c_enps_att_rec.cal_type,
                                                 X_LOCATION_CD => c_enps_att_rec.location_cd,
                                                 X_ATTENDANCE_MODE => c_enps_att_rec.attendance_mode,
                                                 X_ATTENDANCE_TYPE => c_enps_att_rec.attendance_type,
                                                 X_COO_ID  => c_enps_att_rec.coo_id,
                                                 X_STUDENT_CONFIRMED_IND => c_enps_att_rec.STUDENT_CONFIRMED_IND,
                                                 X_COMMENCEMENT_DT  => c_enps_att_rec.COMMENCEMENT_DT,
                                                 X_COURSE_ATTEMPT_STATUS => v_new_course_attempt_status,
                                                 X_PROGRESSION_STATUS => c_enps_att_rec.PROGRESSION_STATUS,
                                                 X_DERIVED_ATT_TYPE => c_enps_att_rec.DERIVED_ATT_TYPE,
                                                 X_DERIVED_ATT_MODE => c_enps_att_rec.DERIVED_ATT_MODE,
                                                 X_PROVISIONAL_IND => c_enps_att_rec.PROVISIONAL_IND,
                                                 X_DISCONTINUED_DT  => c_enps_att_rec.discontinued_dt,
                                                 X_DISCONTINUATION_REASON_CD => c_enps_att_rec.discontinuation_reason_cd,
                                                 X_LAPSED_DT  =>c_enps_att_rec.lapsed_dt,
                                                 X_FUNDING_SOURCE => c_enps_att_rec.FUNDING_SOURCE,
                                                 X_EXAM_LOCATION_CD => c_enps_att_rec.EXAM_LOCATION_CD,
                                                 X_DERIVED_COMPLETION_YR  => c_enps_att_rec.DERIVED_COMPLETION_YR,
                                                 X_DERIVED_COMPLETION_PERD => c_enps_att_rec.DERIVED_COMPLETION_PERD,
                                                 X_NOMINATED_COMPLETION_YR  => c_enps_att_rec.NOMINATED_COMPLETION_YR,
                                                 X_NOMINATED_COMPLETION_PERD => c_enps_att_rec.NOMINATED_COMPLETION_PERD,
                                                 X_RULE_CHECK_IND => c_enps_att_rec.RULE_CHECK_IND,
                                                 X_WAIVE_OPTION_CHECK_IND => c_enps_att_rec.WAIVE_OPTION_CHECK_IND,
                                                 X_LAST_RULE_CHECK_DT  => c_enps_att_rec.LAST_RULE_CHECK_DT,
                                                 X_PUBLISH_OUTCOMES_IND => c_enps_att_rec.PUBLISH_OUTCOMES_IND,
                                                 X_COURSE_RQRMNT_COMPLETE_IND => c_enps_att_rec.COURSE_RQRMNT_COMPLETE_IND,
                                                 X_COURSE_RQRMNTS_COMPLETE_DT  =>  c_enps_att_rec.COURSE_RQRMNTS_COMPLETE_DT,
                                                 X_S_COMPLETED_SOURCE_TYPE => c_enps_att_rec.S_COMPLETED_SOURCE_TYPE,
                                                 X_OVERRIDE_TIME_LIMITATION  => c_enps_att_rec.OVERRIDE_TIME_LIMITATION,
                                                 X_MODE =>  'R',
                                                 X_LAST_DATE_OF_ATTENDANCE => c_enps_att_rec.LAST_DATE_OF_ATTENDANCE,
                                                 X_DROPPED_BY => c_enps_att_rec.DROPPED_BY,
                                                 X_IGS_PR_CLASS_STD_ID => c_enps_att_rec.IGS_PR_CLASS_STD_ID,
                                                 -- Added next four parameters as per the Career Impact Build Bug# 2027984
                                                 x_primary_program_type      => c_enps_att_rec.primary_program_type,
                                                 x_primary_prog_type_source  => c_enps_att_rec.primary_prog_type_source,
                                                 x_catalog_cal_type          => c_enps_att_rec.catalog_cal_type,
                                                 x_catalog_seq_num           => c_enps_att_rec.catalog_seq_num ,
                                                 x_key_program               => c_enps_att_rec.key_program,
                                                 -- The following two parameters were added as part of EN015 build. Bug# 2158654 - pradhakr
                                                 x_override_cmpl_dt   => c_enps_att_rec.override_cmpl_dt,
                                                 x_manual_ovr_cmpl_dt_ind => c_enps_att_rec.manual_ovr_cmpl_dt_ind,
                                                 -- added by ckasu as part of bug # 3544927
                                                 X_ATTRIBUTE_CATEGORY                => c_enps_att_rec.ATTRIBUTE_CATEGORY,
                                                 X_ATTRIBUTE1                        => c_enps_att_rec.ATTRIBUTE1,
                                                 X_ATTRIBUTE2                        => c_enps_att_rec.ATTRIBUTE2,
                                                 X_ATTRIBUTE3                        => c_enps_att_rec.ATTRIBUTE3,
                                                 X_ATTRIBUTE4                        => c_enps_att_rec.ATTRIBUTE4,
                                                 X_ATTRIBUTE5                        => c_enps_att_rec.ATTRIBUTE5,
                                                 X_ATTRIBUTE6                        => c_enps_att_rec.ATTRIBUTE6,
                                                 X_ATTRIBUTE7                        => c_enps_att_rec.ATTRIBUTE7,
                                                 X_ATTRIBUTE8                        => c_enps_att_rec.ATTRIBUTE8,
                                                 X_ATTRIBUTE9                        => c_enps_att_rec.ATTRIBUTE9,
                                                 X_ATTRIBUTE10                       => c_enps_att_rec.ATTRIBUTE10,
                                                 X_ATTRIBUTE11                       => c_enps_att_rec.ATTRIBUTE11,
                                                 X_ATTRIBUTE12                       => c_enps_att_rec.ATTRIBUTE12,
                                                 X_ATTRIBUTE13                       => c_enps_att_rec.ATTRIBUTE13,
                                                 X_ATTRIBUTE14                       => c_enps_att_rec.ATTRIBUTE14,
                                                 X_ATTRIBUTE15                       => c_enps_att_rec.ATTRIBUTE15,
                                                 X_ATTRIBUTE16                       => c_enps_att_rec.ATTRIBUTE16,
                                                 X_ATTRIBUTE17                       => c_enps_att_rec.ATTRIBUTE17,
                                                 X_ATTRIBUTE18                       => c_enps_att_rec.ATTRIBUTE18,
                                                 X_ATTRIBUTE19                       => c_enps_att_rec.ATTRIBUTE19,
                                                 X_ATTRIBUTE20                       => c_enps_att_rec.ATTRIBUTE20,
						 X_FUTURE_DATED_TRANS_FLAG           => c_enps_att_rec.FUTURE_DATED_TRANS_FLAG);


                IF v_new_course_attempt_status= 'LAPSED' THEN

                  DECLARE
                       CURSOR c1 IS
                       -- modified for perf bug 3699628
                       SELECT 'X'
                       FROM igs_pe_typ_instances_all PTI,
                            IGS_PE_PERSON_TYPES PPT
                       WHERE PPT.system_type = 'STUDENT' AND
                             ppt.person_type_code = pti.person_type_code
                       AND pti.COURSE_CD = c_enps_att_rec.COURSE_CD
                       AND pti.PERSON_ID = c_enps_att_rec.PERSON_ID;
                       c1_rec c1%ROWTYPE;

                                  CURSOR c_former_stdnt IS
                                  SELECT person_type_code
                                  FROM igs_pe_person_types
                                  WHERE system_type = 'FORMER_STUDENT';

                                  l_person_type_code igs_pe_person_types.person_type_code%TYPE := NULL;

                       l_rowid VARCHAR2(25);
                       l_pk NUMBER(15);
                         BEGIN
                                -- fetching person_type_code for system_type of 'FORMER_STUDENT'
                                        OPEN c_former_stdnt;
                                        FETCH c_former_stdnt INTO l_person_type_code;
                                        CLOSE c_former_stdnt;

                        OPEN c1;
                        FETCH c1 INTO c1_rec;
                          IF c1%FOUND THEN

                           DECLARE

                             CURSOR c2 IS
                             SELECT ROWID, ti.*
                             FROM igs_pe_typ_instances_all ti
                             WHERE course_cd =  c_enps_att_rec.COURSE_CD
                             AND   person_id =  c_enps_att_rec.PERSON_ID;
                             l_rowid VARCHAR2(25);
                             l_pk NUMBER(15);
                             l_org_id NUMBER := igs_ge_gen_003.get_org_id;

                           BEGIN



                               FOR c2_rec IN c2 LOOP
                                  Igs_Pe_Typ_Instances_Pkg.update_row(
                                  -- previously l_rowid was being passed to the update row
                                  -- changed it to c2_rec.rowid
                                  -- amuthu 27-Jul-2001
                                 X_ROWID =>c2_rec.ROWID,
                                 X_PERSON_ID =>c2_rec.PERSON_ID,
                                 X_COURSE_CD =>c2_rec.COURSE_CD,
                                 X_TYPE_INSTANCE_ID =>c2_rec.TYPE_INSTANCE_ID,
                                 X_PERSON_TYPE_CODE =>c2_rec.PERSON_TYPE_CODE,
                                 X_CC_VERSION_NUMBER =>c2_rec.CC_VERSION_NUMBER,
                                 X_FUNNEL_STATUS =>c2_rec.FUNNEL_STATUS,
                                 X_ADMISSION_APPL_NUMBER =>c2_rec.ADMISSION_APPL_NUMBER,
                                 X_NOMINATED_COURSE_CD =>c2_rec.NOMINATED_COURSE_CD,
                                 X_NCC_VERSION_NUMBER =>c2_rec.NCC_VERSION_NUMBER,
                                 X_SEQUENCE_NUMBER =>c2_rec.SEQUENCE_NUMBER,
                                 X_START_DATE =>c2_rec.START_DATE,
                                 X_END_DATE => SYSDATE,
                                 X_CREATE_METHOD =>c2_rec.CREATE_METHOD,
                                 X_ENDED_BY =>c2_rec.ENDED_BY,
                                 X_END_METHOD =>'PRG_ATTMPT_ST_INACTIVE',
                                 X_MODE =>'R',
                                 X_EMPLMNT_CATEGORY_CODE => c2_rec.emplmnt_category_code);
                            END LOOP; -- End loop for Ending the Type.
                               Igs_Pe_Typ_Instances_Pkg.insert_row(
                                 X_ROWID =>l_rowid,
                                 X_PERSON_ID => c_enps_att_rec.PERSON_ID,
                                 X_COURSE_CD =>c_enps_att_rec.COURSE_CD,
                                 X_TYPE_INSTANCE_ID =>l_pk,
                                 X_PERSON_TYPE_CODE =>l_person_type_code,
                                 X_CC_VERSION_NUMBER =>NULL,
                                 X_FUNNEL_STATUS => NULL,
                                 X_ADMISSION_APPL_NUMBER=>
                                    c_enps_att_rec.ADM_ADMISSION_APPL_NUMBER,
                                 X_NOMINATED_COURSE_CD =>
                                    c_enps_att_rec.ADM_NOMINATED_COURSE_CD,
                                 X_NCC_VERSION_NUMBER =>c_enps_att_rec.VERSION_NUMBER,
                                 X_SEQUENCE_NUMBER =>NULL,
                                 X_START_DATE => SYSDATE,
                                 X_END_DATE =>NULL,
                                 X_CREATE_METHOD =>'PRG_ATTMPT_ST_LAPSED',
                                 X_ENDED_BY =>NULL,
                                 X_END_METHOD =>NULL,
                                 X_MODE =>'R',
                                 x_org_id => l_org_id,
                                 X_EMPLMNT_CATEGORY_CODE => null);
                         END;-- End for Update Process
                      ELSE -- If Cursor%NOTFOUND

                           DECLARE

                             l_org_id NUMBER := igs_ge_gen_003.get_org_id;
                                BEGIN
                               Igs_Pe_Typ_Instances_Pkg.insert_row(
                                 X_ROWID =>l_rowid,
                                 X_PERSON_ID => c_enps_att_rec.PERSON_ID,
                                 X_COURSE_CD =>c_enps_att_rec.COURSE_CD,
                                 X_TYPE_INSTANCE_ID =>l_pk,
                                 X_PERSON_TYPE_CODE =>l_person_type_code,
                                 X_CC_VERSION_NUMBER =>NULL,
                                 X_FUNNEL_STATUS => NULL,
                                 X_ADMISSION_APPL_NUMBER
                                    =>c_enps_att_rec.ADM_ADMISSION_APPL_NUMBER,
                                 X_NOMINATED_COURSE_CD
                                            =>c_enps_att_rec.ADM_NOMINATED_COURSE_CD,
                                 X_NCC_VERSION_NUMBER =>c_enps_att_rec.VERSION_NUMBER,
                                 X_SEQUENCE_NUMBER =>NULL,
                                 X_START_DATE => SYSDATE,
                                 X_END_DATE =>NULL,
                                 X_CREATE_METHOD =>'PRG_ATTMPT_ST_LAPSED',
                                 X_ENDED_BY =>NULL,
                                 X_END_METHOD =>NULL,
                                 X_MODE =>'R',
                                 x_org_id => l_org_id,
                                 X_EMPLMNT_CATEGORY_CODE => null);
                                                    END;
                      END IF;-- End IF for Cursor%FOUND
                  CLOSE C1;
                END;
        END IF;
      END LOOP;
    END;


            RETURN TRUE;
        END IF;
        RETURN FALSE;
    END;
    EXCEPTION
        WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
              l_msg_text := NULL;
              l_msg_text := FND_MESSAGE.GET;
              ROLLBACK TO enrpl_upd_get_status_a;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_person_number || ':' || p_course_cd || '- ' || l_msg_text);
              RETURN FALSE;
        WHEN OTHERS THEN
            IF SQLCODE = -54 THEN
              FND_MESSAGE.SET_NAME('FND','FND_LOCK_RECORD_ERROR');
              l_msg_text := NULL;
              l_msg_text := FND_MESSAGE.GET;
              ROLLBACK TO enrpl_upd_get_status_a;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_person_number || ':' || p_course_cd || '- ' || l_msg_text);
              RETURN FALSE;
            ELSE
              Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
              FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_012.enrpl_upd_get_status');
              l_msg_text := NULL;
              l_msg_text := FND_MESSAGE.GET;
              ROLLBACK TO enrpl_upd_get_status_a;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_person_number || ':' || p_course_cd || '- ' || l_msg_text);
              RETURN FALSE;
            END IF;
    END enrpl_upd_get_status;

BEGIN
    -- This updates the IGS_EN_STDNT_PS_ATT.course_attempt_status
    -- when an element of the student's enrolment has chaged IN
    -- such a way as to require a re-derivation of their status.
    -- These things are :
    -- 1.   If an intermission period has commenced and their
    --      status is not INTERMIT
    -- 2.   If an intermission period has ended and their
    --      status is still INTERMIT
    -- 3.   If an enrolment form due date is reached and their
    --      status is ENROLLED (check that at lease one student
    --      IGS_PS_UNIT attempt has a status of enrolled)
    -- 4.   If status is INACTIVE or LAPSED and the teaching calender start date of
    --      an ENROLLED IGS_PS_UNIT attempt has been reached
    -- 5.   IF a future discontinuation date has been reached and
    --      the IGS_PS_COURSE attempt is still ENROLLED.
    --
    -- IGS_GE_NOTE : this process should be run by the job scheduler
    --    on a nightly basis to pick up statuses which
    --    should be re-calculated.
    -- Create a system log on the database

    Igs_Ge_Gen_003.genp_ins_log(
        'SCA-ST-UPD',
        NULL,
        v_creation_dt);
    -- commit the changes made
    COMMIT;

    -- 1.   CHECK FOR INTERMISSION PERIODS WHICH ARE COMMENCING
    -- IGS_GE_NOTE : also ignore IGS_PS_COURSE attempts with a status which
    --        would prevent an intermission from being actioned,
    --        being discontinuation, deletion or completed
    -- setting that no updates have yet been performed
    v_updates_done := 0;

    FOR v_sci_comm IN c_sci_comm LOOP
        -- get the status
        IF enrpl_upd_get_status(
                v_sci_comm.person_id,
                v_sci_comm.course_cd,
                v_sci_comm.course_attempt_status) = TRUE THEN

            v_updates_done := v_updates_done + 1;
        END IF;
    END LOOP;

    -- the number of updates done to student IGS_PS_COURSE attempt records
    -- have been summed and used in the call to genp_ins_log_entry
    FND_MESSAGE.SET_NAME('IGS','IGS_EN_STUD_INTER_ACTIVE');
    FND_MESSAGE.SET_TOKEN('UPDTDONE',TO_CHAR(v_updates_done));
    v_log_text := FND_MESSAGE.GET;
    FND_FILE.PUT_LINE(FND_FILE.LOG,v_log_text);


    Igs_Ge_Gen_003.genp_ins_log_entry(
        'SCA-ST-UPD',
        v_creation_dt,
        'INTERMIT',
        NULL,
        v_log_text);

    -- commit the changes made
    COMMIT;


    -- 2.   CHECK FOR INTERMISSION PERIODS WHICH ARE ENDING
    -- setting that no updates have yet been performed
    v_updates_done := 0;

    FOR v_sci_end IN c_sci_end LOOP

         -- get the pending/failed return conditions for the student intermission record
         l_rcond_exists := NULL;
         OPEN c_sci_rcond(v_sci_end.person_id,
                         v_sci_end.course_cd,
                         v_sci_end.start_dt,
                         v_sci_end.logical_delete_date);
         FETCH c_sci_rcond INTO l_rcond_exists;
         CLOSE  c_sci_rcond;
         -- if this student intermission requires authorization to return and
         -- this student intermission has got failed/pending return conditions then cannot make program
         -- attempt active. Hence log a message
         IF (v_sci_end.cond_return_flag = 'Y' AND l_rcond_exists.party_number IS NOT NULL ) THEN
                     FND_MESSAGE.SET_NAME('IGS','IGS_EN_NO_UPD_SCA_RCONDS');
                     FND_MESSAGE.SET_TOKEN('PER_NUM',TO_CHAR(l_rcond_exists.party_number));
                     FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
         ELSE

                    -- get the status
                    IF enrpl_upd_get_status(
                            v_sci_end.person_id,
                            v_sci_end.course_cd,
                            v_sci_end.course_attempt_status) = TRUE THEN

                        v_updates_done := v_updates_done + 1;
                    END IF;
         END IF;
    END LOOP;

    -- the number of updates done to student IGS_PS_COURSE attempt records
    -- have been summed and used in the call to genp_ins_log_entry
    FND_MESSAGE.SET_NAME('IGS','IGS_EN_STUD_INTER_END');
    FND_MESSAGE.SET_TOKEN('UPDTDONE',TO_CHAR(v_updates_done));
    v_log_text := FND_MESSAGE.GET;
        FND_FILE.PUT_LINE(FND_FILE.LOG,v_log_text);

    Igs_Ge_Gen_003.genp_ins_log_entry(
        'SCA-ST-UPD',
        v_creation_dt,
        'NONINTERMIT',
        NULL,
        v_log_text);
    -- commit the changes made
    COMMIT;


    -- 3.   CHECK FOR ENROLMENT FORM DUE DATE
    -- setting that no updates have yet been performed
    v_updates_done := 0;

    FOR v_scae IN c_scae LOOP
        -- get the status
        IF enrpl_upd_get_status(
                v_scae.person_id,
                v_scae.course_cd,
                v_scae.course_attempt_status) = TRUE THEN
            v_updates_done := v_updates_done + 1;
        END IF;
    END LOOP;


    -- the number of updates done to student IGS_PS_COURSE attempt records
    -- have been summed and used in the call to genp_ins_log_entry
    FND_MESSAGE.SET_NAME('IGS','IGS_EN_STUD_SCA_INACTIVE');
    FND_MESSAGE.SET_TOKEN('UPDTDONE',TO_CHAR(v_updates_done));
    v_log_text := FND_MESSAGE.GET;
    FND_FILE.PUT_LINE(FND_FILE.LOG,v_log_text);

    Igs_Ge_Gen_003.genp_ins_log_entry(
        'SCA-ST-UPD',
        v_creation_dt,
        'INACTIVE',
        NULL,
        v_log_text);
    -- commit the changes made
    COMMIT;


    -- 4.   Check for students who are inactive/lapsed but who now have an
    --  enrolled IGS_PS_UNIT attempt.
    v_updates_done := 0;
    FOR v_sca_inactive IN c_sca_inactive LOOP
        -- get the status
        IF enrpl_upd_get_status(
                v_sca_inactive.person_id,
                v_sca_inactive.course_cd,
                v_sca_inactive.course_attempt_status) = TRUE THEN

            v_updates_done := v_updates_done + 1;
        END IF;
    END LOOP;

    -- the number of updates done to student IGS_PS_COURSE attempt records
    -- have been summed and used in the call to genp_ins_log_entry
    FND_MESSAGE.SET_NAME('IGS','IGS_EN_STUD_SCA_ENROLLED');
    FND_MESSAGE.SET_TOKEN('UPDTDONE',TO_CHAR(v_updates_done));
    v_log_text := FND_MESSAGE.GET;
    FND_FILE.PUT_LINE(FND_FILE.LOG,v_log_text);

    Igs_Ge_Gen_003.genp_ins_log_entry(
            'SCA-ST-UPD',
            v_creation_dt,
            'ENROLLED',
            NULL,
            v_log_text);
    -- commit the changes made
    COMMIT;


    -- 5.   CHECK FOR FUTURE-DATES IGS_PS_COURSE DISCONTINUATIONS
    --  WHICH HAVE BEEN REACHED
    FOR v_sca_future IN c_sca_future LOOP
        -- update the student IGS_PS_COURSE attempt future
        -- dated discontinuation
        IF (enrp_upd_sca_discont(
                v_sca_future.person_id,
                v_sca_future.course_cd,
                v_sca_future.version_number,
                v_sca_future.course_attempt_status,
                v_sca_future.commencement_dt,
                v_sca_future.discontinued_dt,
                v_sca_future.discontinuation_reason_cd,
                v_message_name) = FALSE) THEN
            Igs_Ge_Gen_003.genp_ins_log_entry(
                'SCA-ST-UPD',
                v_creation_dt,
                'DISCONT|'                      ||
                TO_CHAR(v_sca_future.person_id)             ||'|'||
                v_sca_future.course_cd                  ||'|'||
                TO_CHAR(v_sca_future.discontinued_dt,'DD/MM/YYYY')  ||'|'||
                v_sca_future.discontinuation_reason_cd,
                v_message_name,
                NULL);
        ELSE
            Igs_Ge_Gen_003.genp_ins_log_entry(
                'SCA-ST-UPD',
                v_creation_dt,
                'DISCONT|'                      ||
                TO_CHAR(v_sca_future.person_id)             ||'|'||
                v_sca_future.course_cd                  ||'|'||
                TO_CHAR(v_sca_future.discontinued_dt,'DD/MM/YYYY')  ||'|'||
                v_sca_future.discontinuation_reason_cd,
                NULL,
                NULL);
        END IF;
    END LOOP;
    -- commit the changes made
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        IF (c_sci_comm%ISOPEN) THEN
            CLOSE c_sci_comm;
        END IF;
        IF (c_sci_end%ISOPEN) THEN
            CLOSE c_sci_end;
        END IF;
        IF (c_scae%ISOPEN) THEN
            CLOSE c_scae;
        END IF;
        IF (c_sca_inactive%ISOPEN) THEN
            CLOSE c_sca_inactive;
        END IF;
        IF (c_sca_future%ISOPEN) THEN
            CLOSE c_sca_future;
        END IF;
        RAISE;
END;
EXCEPTION
    WHEN OTHERS THEN
            retcode:=2;
              ERRBUF := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        Igs_Ge_Msg_Stack.CONC_EXCEPTION_HNDL;
    END enrp_upd_sca_statusb;

FUNCTION Enrp_Upd_Sca_Urule(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_log_type IN VARCHAR2 ,
  p_creation_dt IN DATE )
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Modified code in this function due to change in pk of student
  --                            unit attempt w.r.t. bug number 2829262
  --rvangala    07-OCT-2003     Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
  --                            added as part of Prevent Dropping Core Units. Enh Bug# 3052432
  -------------------------------------------------------------------------------------------
RETURN BOOLEAN  AS
    gv_other_detail     VARCHAR2(255);
    gv_cntr         NUMBER;
BEGIN
DECLARE
    -- table to hold sua records which have been checked and cannot be changed
    TYPE r_checked_sua_typ IS RECORD(
        unit_cd         IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
        cal_type        IGS_EN_SU_ATTEMPT.cal_type%TYPE,
        ci_sequence_number  IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE);
    r_checked_sua           r_checked_sua_typ;
    TYPE t_checked_sua_typ IS TABLE OF r_checked_sua%TYPE
        INDEX BY BINARY_INTEGER;
    t_checked_sua           t_checked_sua_typ;
    t_checked_sua_blank     t_checked_sua_typ;
    e_resource_busy_exception       EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
    cst_invalid     VARCHAR2(10) := 'INVALID';
    cst_enrolled        VARCHAR2(10) := 'ENROLLED';
    cst_attdate     VARCHAR2(10) := 'ATT-DATE';
    cst_unit        VARCHAR2(10) := 'UNIT';
    cst_changed     VARCHAR2(10) := 'CHANGED';
    cst_attvalid        VARCHAR2(10) := 'ATT-VALID';
    v_ret_val       BOOLEAN := TRUE;
    v_dummy         VARCHAR2(1);
    v_message_text      VARCHAR2(1000);
    v_fail_type     VARCHAR2(10);
    v_rec_found     BOOLEAN;
    v_validation_error  BOOLEAN;
    v_message_name      VARCHAR2(30);
    v_unit_attempt_status   IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
    v_change_made       BOOLEAN;
    PROCEDURE enrpl_upd_invalid_ua(
        p_acad_cal_type         IGS_CA_INST.cal_type%TYPE,
        p_acad_sequence_number      IGS_CA_INST.sequence_number%TYPE,
        p_person_id         IGS_EN_STDNT_PS_ATT.person_id%TYPE,
        p_course_cd         IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
        p_s_log_type            IGS_GE_S_LOG.s_log_type%TYPE,
        p_creation_dt           IGS_GE_S_LOG.creation_dt%TYPE)  AS
    BEGIN
    -- Re-check all INVALID IGS_PS_UNIT attempts and switch to ENROLLED if the rules
    -- are now passed. If an invalid IGS_PS_UNIT passes all rules the status is set
    -- to ENROLLED and the select is repeated. This repeats until no more invalid
    -- IGS_PS_UNIT attempts pass the IGS_PS_UNIT rules.
    DECLARE
        CURSOR  c_sua_sca IS
            SELECT
                sua.person_id,
                sua.course_cd,
-- Add the following one line of code.       From Callista 2.0  18-May-2000
                sca.version_number sca_version_number,
                sua.unit_cd,
                sua.version_number,
                sua.cal_type,
                sua.ci_sequence_number,
                sua.ci_end_dt,
                sua.location_cd,
                sua.unit_class,
                sua.enrolled_dt,
                sua.uoo_id,
                Igs_En_Gen_004.enrp_get_rule_cutoff(
                    sua.cal_type,
                    sua.ci_sequence_number,
                    cst_enrolled) enrolled_cutoff_date
            FROM    IGS_EN_SU_ATTEMPT sua,
                IGS_EN_STDNT_PS_ATT sca
            WHERE   sua.person_id       = p_person_id AND
                sua.course_cd       = p_course_cd AND
                sua.unit_attempt_status = cst_invalid AND
                sca.person_id       = sua.person_id AND
                sca.course_cd       = sua.course_cd;

        lv_rule_failed IGS_EN_SU_ATTEMPT.FAILED_UNIT_RULE%TYPE;

    BEGIN
        v_change_made := FALSE;
        FOR v_sua_sca_rec IN c_sua_sca LOOP
            v_rec_found := FALSE;
            -- see if the record has already been checked and failed
            IF gv_cntr <> 0 THEN
                FOR cntr IN 1..(gv_cntr) LOOP
                    IF (t_checked_sua(cntr).unit_cd = v_sua_sca_rec.unit_cd AND
                            t_checked_sua(cntr).cal_type = v_sua_sca_rec.cal_type AND
                            t_checked_sua(cntr).ci_sequence_number
                                = v_sua_sca_rec.ci_sequence_number) THEN
                        v_rec_found := TRUE;
                    END IF;
                END LOOP;
            END IF;

            IF (v_rec_found = FALSE) THEN
                lv_rule_failed := NULL;
                IF Igs_Ru_Val_Unit_Rule.rulp_val_enrol_unit(
                        p_person_id,
                        p_course_cd,
-- Add the following one line of code.       From Callista 2.0  18-May-2000
                        v_sua_sca_rec.sca_version_number,
                        v_sua_sca_rec.unit_cd,
                        v_sua_sca_rec.version_number,
                        v_sua_sca_rec.cal_type,
                        v_sua_sca_rec.ci_sequence_number,
                        v_message_text
                       ,v_sua_sca_rec.uoo_id,
                        lv_rule_failed
                    ) = TRUE THEN
                    v_validation_error := FALSE;
                    IF (v_sua_sca_rec.enrolled_cutoff_date IS NOT NULL AND
                            SYSDATE > v_sua_sca_rec.enrolled_cutoff_date) THEN
                        Igs_Ge_Gen_003.genp_ins_log_entry(
                            p_s_log_type,
                            p_creation_dt,
                            cst_unit
                            ||','||cst_attdate
                            ||','||cst_enrolled
                            ||','||TO_CHAR(p_person_id)
                            ||','||p_course_cd
                            ||','||v_sua_sca_rec.unit_cd
                            ||','||v_sua_sca_rec.cal_type
                            ||','||TO_CHAR(v_sua_sca_rec.ci_sequence_number),
                            'IGS_EN_UA_CHGST_ENROLLED',
                            NULL);
                        v_ret_val := FALSE;
                        v_validation_error := TRUE;
                    ELSE
                        IF Igs_En_Val_Sua.enrp_val_sua_cnfrm(
                                v_sua_sca_rec.person_id,
                                v_sua_sca_rec.course_cd,
                                v_sua_sca_rec.unit_cd,
                                v_sua_sca_rec.version_number,
                                v_sua_sca_rec.cal_type,
                                v_sua_sca_rec.ci_sequence_number,
                                v_sua_sca_rec.ci_end_dt,
                                v_sua_sca_rec.location_cd,
                                v_sua_sca_rec.unit_class,
                                v_sua_sca_rec.enrolled_dt,
                                v_fail_type,
                                v_message_name) = FALSE THEN
                            Igs_Ge_Gen_003.genp_ins_log_entry (
                                p_s_log_type,
                                p_creation_dt,
                                cst_unit
                                    ||','||cst_attvalid
                                    ||','||cst_enrolled
                                    ||','||TO_CHAR(p_person_id)
                                    ||','||p_course_cd
                                    ||','||v_sua_sca_rec.unit_cd
                                    ||','||v_sua_sca_rec.cal_type
                                    ||','||TO_CHAR(v_sua_sca_rec.ci_sequence_number),
                                v_message_name,
                                NULL);
                            v_ret_val := FALSE;
                            v_validation_error := TRUE;
                        ELSE
                          DECLARE
                            -- update igs_en_su_attempt
                            CURSOR c_assu IS
                            SELECT  ROWID,
                                    IGS_EN_SU_ATTEMPT.*
                            FROM    IGS_EN_SU_ATTEMPT
                            WHERE   person_id       = v_sua_sca_rec.person_id   AND
                                    course_cd       = v_sua_sca_rec.course_cd   AND
                                    uoo_id          = v_sua_sca_rec.uoo_id
                            FOR UPDATE NOWAIT;
                            -- Having gotten the lock, update the record.
                            BEGIN
                                 FOR   c_assu_rec IN c_assu LOOP
                                         -- Call the API to update the student unit attempt. This API is a
                                         -- wrapper to the update row of the TBH.
                                         igs_en_sua_api.update_unit_attempt(
                                           x_rowid                      => c_assu_rec.rowid,
                                           x_person_id                  => c_assu_rec.person_id,
                                           x_course_cd                  => c_assu_rec.course_cd ,
                                           x_unit_cd                    => c_assu_rec.unit_cd,
                                           x_cal_type                   => c_assu_rec.cal_type,
                                           x_ci_sequence_number         => c_assu_rec.ci_sequence_number ,
                                           x_version_number             => c_assu_rec.version_number ,
                                           x_location_cd                => c_assu_rec.location_cd,
                                           x_unit_class                 => c_assu_rec.unit_class ,
                                           x_ci_start_dt                => c_assu_rec.ci_start_dt,
                                           x_ci_end_dt                  => c_assu_rec.ci_end_dt,
                                           x_uoo_id                     => c_assu_rec.uoo_id ,
                                           x_enrolled_dt                => c_assu_rec.enrolled_dt,
                                           x_unit_attempt_status        => cst_enrolled,
                                           x_administrative_unit_status => c_assu_rec.administrative_unit_status,
                                           x_administrative_priority    => c_assu_rec.administrative_priority,
                                           x_discontinued_dt            => c_assu_rec.discontinued_dt,
                                           x_dcnt_reason_cd             => c_assu_rec.dcnt_reason_cd,
                                           x_rule_waived_dt             => c_assu_rec.rule_waived_dt ,
                                           x_rule_waived_person_id      => c_assu_rec.rule_waived_person_id ,
                                           x_no_assessment_ind          => c_assu_rec.no_assessment_ind,
                                           x_sup_unit_cd                => c_assu_rec.sup_unit_cd ,
                                           x_sup_version_number         => c_assu_rec.sup_version_number,
                                           x_exam_location_cd           => c_assu_rec.exam_location_cd,
                                           x_alternative_title          => c_assu_rec.alternative_title,
                                           x_override_enrolled_cp       => c_assu_rec.override_enrolled_cp,
                                           x_override_eftsu             => c_assu_rec.override_eftsu ,
                                           x_override_achievable_cp     => c_assu_rec.override_achievable_cp,
                                           x_override_outcome_due_dt    => c_assu_rec.override_outcome_due_dt,
                                           x_override_credit_reason     => c_assu_rec.override_credit_reason,
                                           x_waitlist_dt                => c_assu_rec.waitlist_dt,
                                           x_mode                       => 'R',
                                           -- Added as part of Enroll Process build - amuthu
                                           x_gs_version_number          => c_assu_rec.gs_version_number,
                                           x_enr_method_type            => c_assu_rec.enr_method_type,
                                           x_failed_unit_rule           => NULL, -- since the rule has succeeded now
                                           x_cart                       => c_assu_rec.cart,
                                           x_rsv_seat_ext_id            => c_assu_rec.RSV_SEAT_EXT_ID,
                                           x_org_unit_cd                => c_assu_rec.org_unit_cd,
                                           -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                           x_session_id                 => c_assu_rec.session_id,
                                            -- Added the column grading schema as a part of the bug 2037897. - aiyer
                                           x_grading_schema_code        => c_assu_rec.grading_schema_code,
                                           x_deg_aud_detail_id          => c_assu_rec.deg_aud_detail_id,
                                           x_subtitle                   =>  c_assu_rec.subtitle,
                                           x_student_career_transcript  => c_assu_rec.student_career_transcript,
                                           x_student_career_statistics  => c_assu_rec.student_career_statistics,
                                           x_attribute_category         => c_assu_rec.attribute_category,
                                           x_attribute1                 => c_assu_rec.attribute1,
                                           x_attribute2                 => c_assu_rec.attribute2,
                                           x_attribute3                 => c_assu_rec.attribute3,
                                           x_attribute4                 => c_assu_rec.attribute4,
                                           x_attribute5                 => c_assu_rec.attribute5,
                                           x_attribute6                 => c_assu_rec.attribute6,
                                           x_attribute7                 => c_assu_rec.attribute7,
                                           x_attribute8                 => c_assu_rec.attribute8,
                                           x_attribute9                 => c_assu_rec.attribute9,
                                           x_attribute10                => c_assu_rec.attribute10,
                                           x_attribute11                => c_assu_rec.attribute11,
                                           x_attribute12                => c_assu_rec.attribute12,
                                           x_attribute13                => c_assu_rec.attribute13,
                                           x_attribute14                => c_assu_rec.attribute14,
                                           x_attribute15                => c_assu_rec.attribute15,
                                           x_attribute16                => c_assu_rec.attribute16,
                                           x_attribute17                => c_assu_rec.attribute17,
                                           x_attribute18                => c_assu_rec.attribute18,
                                           x_attribute19                => c_assu_rec.attribute19,
                                           x_attribute20                => c_assu_rec.attribute20,
                                           x_waitlist_manual_ind        => c_assu_rec.waitlist_manual_ind ,--Added by mesriniv for Bug 2554109 Mini Waitlist Build.
                                           x_wlst_priority_weight_num   => c_assu_rec.wlst_priority_weight_num,
                                           x_wlst_preference_weight_num => c_assu_rec.wlst_preference_weight_num,
                                           -- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
                                           x_core_indicator_code        => c_assu_rec.core_indicator_code
                                           );
                                     END LOOP;
                                  END;
                                      Igs_Ge_Gen_003.genp_ins_log_entry (
                                                                p_s_log_type,
                                                                p_creation_dt,
                                                                cst_unit
                                                                ||','||cst_changed
                                                                ||','||cst_enrolled
                                                                ||','||TO_CHAR(p_person_id)
                                                                ||','||p_course_cd
                                                                ||','||v_sua_sca_rec.unit_cd
                                                                ||','||v_sua_sca_rec.cal_type
                                                                ||','||TO_CHAR(v_sua_sca_rec.ci_sequence_number),
                                                                'IGS_EN_UA_STALT_INVALID_ENROL',
                                                                NULL);
                            v_ret_val := FALSE;
                            v_change_made := TRUE;
                        END IF; -- IGS_EN_VAL_SUA.enrp_val_sua_cnfrm
                    END IF; --(c_sua_sca_rec.enrolled_cutoff_date IS NOT NULL AND
                        --  SYSDATE > c_sua_sca_rec.enrolled_cutoff_date)
                    IF v_validation_error = TRUE THEN
                        -- no change done
                        -- add the record to the table
                        gv_cntr := gv_cntr+1;
                        t_checked_sua(gv_cntr).unit_cd := v_sua_sca_rec.unit_cd;
                        t_checked_sua(gv_cntr).cal_type := v_sua_sca_rec.cal_type;
                        t_checked_sua(gv_cntr).ci_sequence_number
                                    := v_sua_sca_rec.ci_sequence_number;
                    ELSE
                        -- change was done so exit and call again
                        EXIT;
                    END IF; -- v_validation_error = TRUE
                END IF; -- IGS_RU_VAL_UNIT_RULE.rulp_val_enrol_unit
            END IF; -- (v_rec_found = FALSE)
        END LOOP;
        -- if a change was made call the procedure again
        IF  v_change_made = TRUE THEN
            enrpl_upd_invalid_ua(
                    p_acad_cal_type,
                    p_acad_sequence_number,
                    p_person_id,
                    p_course_cd,
                    p_s_log_type,
                    p_creation_dt);
        END IF;/*
    EXCEPTION
        WHEN e_resource_busy_exception THEN
            IF (c_sua_sca%ISOPEN) THEN
                CLOSE c_sua_sca;
            END IF;
            RAISE;
        WHEN OTHERS THEN
            IF (c_sua_sca%ISOPEN) THEN
                CLOSE c_sua_sca;
            END IF;
            RAISE;*/
    END;
    /*
    EXCEPTION
        WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_012.enrpl_upd_invalid_ua');
                Igs_Ge_Msg_Stack.ADD;
                    App_Exception.Raise_Exception;*/
    END enrpl_upd_invalid_ua;

    PROCEDURE enrpl_upd_enrolled_ua(
        p_acad_cal_type         IGS_CA_INST.cal_type%TYPE,
        p_acad_sequence_number      IGS_CA_INST.sequence_number%TYPE,
        p_person_id         IGS_EN_STDNT_PS_ATT.person_id%TYPE,
        p_course_cd         IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
        p_s_log_type            IGS_GE_S_LOG.s_log_type%TYPE,
        p_creation_dt           IGS_GE_S_LOG.creation_dt%TYPE)  AS
  -------------------------------------------------------------------------------------------
  -- Check all ENROLLED IGS_PS_UNIT attempt IGS_PS_UNIT rules. If a IGS_RU_RULE is failed the
  -- status is set to INVALID and the select is repeated. This process
  -- repeats until no further units fail rules.
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Modified code in this function due to change in pk of student
  --                            unit attempt w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------
    BEGIN
    DECLARE
-- Add the following one line of code.       From Callista 2.0  18-May-2000
        v_sca_version_number    IGS_EN_STDNT_PS_ATT.version_number%TYPE;
--
        CURSOR  c_sua IS
            SELECT  sua.person_id,
                sua.course_cd,
                sua.unit_cd,
                sua.version_number,
                sua.cal_type,
                sua.ci_sequence_number,
                sua.uoo_id,
                Igs_En_Gen_004.enrp_get_rule_cutoff(
                    sua.cal_type,
                    sua.ci_sequence_number,
                    cst_invalid) invalid_cutoff_date
            FROM    IGS_EN_SU_ATTEMPT sua
            WHERE   sua.person_id       = p_person_id AND
                sua.course_cd       = p_course_cd AND
                sua.unit_attempt_status = cst_enrolled AND
                sua.rule_waived_dt  IS NULL;
-- Add the following five lines of code.       From Callista 2.0  18-May-2000
    CURSOR  c_sca IS
            SELECT  sca.version_number
            FROM    IGS_EN_STDNT_PS_ATT sca
            WHERE   sca.person_id       = p_person_id AND
                sca.course_cd       = p_course_cd;

        lv_rule_failed VARCHAR2(30);
--
      BEGIN
        v_change_made := FALSE;
-- Add the following nine lines of code.       From Callista 2.0  18-May-2000
    -- Determine the version number of the course to be used in the call to
        -- rulp_val_enrol_unit.
        OPEN c_sca;
        FETCH c_sca INTO v_sca_version_number;
        IF c_sca%NOTFOUND THEN
            CLOSE c_sca;
            RAISE NO_DATA_FOUND;
        END IF;
        CLOSE c_sca;
--
        FOR v_sua_rec IN c_sua LOOP
            v_rec_found := FALSE;
            IF gv_cntr <> 0 THEN
                -- check if the record has already been checked and failed
                FOR cntr IN 1..gv_cntr LOOP
                    IF (t_checked_sua(cntr).unit_cd = v_sua_rec.unit_cd AND
                            t_checked_sua(cntr).cal_type = v_sua_rec.cal_type AND
                            t_checked_sua(cntr).ci_sequence_number
                                = v_sua_rec.ci_sequence_number) THEN
                        v_rec_found := TRUE;
                    END IF;
                END LOOP;
            END IF;

            IF (v_rec_found = FALSE) THEN
                lv_rule_failed := NULL;
                IF Igs_Ru_Val_Unit_Rule.rulp_val_enrol_unit(
                        p_person_id,
                        p_course_cd,
-- Add the following one line of code.       From Callista 2.0  18-May-2000
                        v_sca_version_number,
--
                        v_sua_rec.unit_cd,
                        v_sua_rec.version_number,
                        v_sua_rec.cal_type,
                        v_sua_rec.ci_sequence_number,
                        v_message_text
                        ,v_sua_rec.uoo_id,
                        lv_rule_failed
                    ) = FALSE THEN
                    IF (v_sua_rec.invalid_cutoff_date IS NOT NULL AND
                            SYSDATE > v_sua_rec.invalid_cutoff_date) THEN
                        Igs_Ge_Gen_003.genp_ins_log_entry(
                            p_s_log_type,
                            p_creation_dt,
                            cst_unit
                                ||','||cst_attdate
                                ||','||cst_invalid
                                ||','||TO_CHAR(p_person_id)
                                ||','||p_course_cd
                                ||','||v_sua_rec.unit_cd
                                ||','||v_sua_rec.cal_type
                                ||','||TO_CHAR(v_sua_rec.ci_sequence_number),
                            'IGS_EN_UA_FAILS_ST_INVALID',
                            v_message_text);
                        v_ret_val := FALSE;
                        -- no change done
                        -- so add the record to the table
                        gv_cntr := gv_cntr+1;
                        t_checked_sua(gv_cntr).unit_cd := v_sua_rec.unit_cd;
                        t_checked_sua(gv_cntr).cal_type := v_sua_rec.cal_type;
                        t_checked_sua(gv_cntr).ci_sequence_number
                                    := v_sua_rec.ci_sequence_number;
                    ELSE
                        -- set the IGS_EN_SU_ATTEMPT to invalid as rules are being breached
                        -- update IGS_EN_SU_ATTEMPT
                        DECLARE
                        CURSOR c_suatt IS
                        SELECT  ROWID,
                                IGS_EN_SU_ATTEMPT.*
                        FROM    IGS_EN_SU_ATTEMPT
                        WHERE   person_id       = v_sua_rec.person_id   AND
                                course_cd       = v_sua_rec.course_cd AND
                                uoo_id          = v_sua_rec.uoo_id
                        FOR UPDATE NOWAIT;
                        -- Having gotten the lock, update the record.
                                    BEGIN
                                      FOR c_suatt_rec IN c_suatt LOOP
                                        -- Call the API to update the student unit attempt. This API is a
                                        -- wrapper to the update row of the TBH.
                                        igs_en_sua_api.update_unit_attempt(
                                           X_ROWID                      => c_suatt_rec.ROWID,
                                           X_PERSON_ID                  => c_suatt_rec.PERSON_ID,
                                           X_COURSE_CD                  => c_suatt_rec.COURSE_CD ,
                                           X_UNIT_CD                    => c_suatt_rec.UNIT_CD,
                                           X_CAL_TYPE                   => c_suatt_rec.CAL_TYPE,
                                           X_CI_SEQUENCE_NUMBER         => c_suatt_rec.CI_SEQUENCE_NUMBER ,
                                           X_VERSION_NUMBER             => c_suatt_rec.VERSION_NUMBER ,
                                           X_LOCATION_CD                => c_suatt_rec.LOCATION_CD,
                                           X_UNIT_CLASS                 => c_suatt_rec.UNIT_CLASS ,
                                           X_CI_START_DT                => c_suatt_rec.CI_START_DT,
                                           X_CI_END_DT                  => c_suatt_rec.CI_END_DT,
                                           X_UOO_ID                     => c_suatt_rec.UOO_ID ,
                                           X_ENROLLED_DT                => c_suatt_rec.ENROLLED_DT,
                                           X_UNIT_ATTEMPT_STATUS        => cst_invalid,
                                           X_ADMINISTRATIVE_UNIT_STATUS => c_suatt_rec.administrative_unit_status,
                                           X_ADMINISTRATIVE_PRIORITY    => c_suatt_rec.administrative_PRIORITY,
                                           X_DISCONTINUED_DT            => c_suatt_rec.discontinued_dt,
                                           X_DCNT_REASON_CD             => c_suatt_rec.DCNT_REASON_CD ,
                                           X_RULE_WAIVED_DT             => c_suatt_rec.RULE_WAIVED_DT ,
                                           X_RULE_WAIVED_PERSON_ID      => c_suatt_rec.RULE_WAIVED_PERSON_ID ,
                                           X_NO_ASSESSMENT_IND          => c_suatt_rec.NO_ASSESSMENT_IND,
                                           X_SUP_UNIT_CD                => c_suatt_rec.SUP_UNIT_CD ,
                                           X_SUP_VERSION_NUMBER         => c_suatt_rec.SUP_VERSION_NUMBER,
                                           X_EXAM_LOCATION_CD           => c_suatt_rec.EXAM_LOCATION_CD,
                                           X_ALTERNATIVE_TITLE          => c_suatt_rec.ALTERNATIVE_TITLE,
                                           X_OVERRIDE_ENROLLED_CP       => c_suatt_rec.OVERRIDE_ENROLLED_CP,
                                           X_OVERRIDE_EFTSU             => c_suatt_rec.OVERRIDE_EFTSU ,
                                           X_OVERRIDE_ACHIEVABLE_CP     => c_suatt_rec.OVERRIDE_ACHIEVABLE_CP,
                                           X_OVERRIDE_OUTCOME_DUE_DT    => c_suatt_rec.OVERRIDE_OUTCOME_DUE_DT,
                                           X_OVERRIDE_CREDIT_REASON     => c_suatt_rec.OVERRIDE_CREDIT_REASON,
                                           X_WAITLIST_DT                => c_suatt_rec.waitlist_dt,
                                           X_MODE                       =>  'R',
                                           -- Added as part of Enroll Process build - amuthu
                                           X_GS_VERSION_NUMBER          => c_suatt_rec.gs_version_number,
                                           X_ENR_METHOD_TYPE            => c_suatt_rec.enr_method_type,
                                           X_FAILED_UNIT_RULE           => lv_rule_failed,
                                           X_CART                       =>    c_suatt_rec.cart,
                                           X_RSV_SEAT_EXT_ID            =>    c_suatt_rec.RSV_SEAT_EXT_ID,
                                           X_ORG_UNIT_CD                => c_suatt_rec.ORG_UNIT_CD,
                                           -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                           X_SESSION_ID                 => c_suatt_rec.session_id,
                                           -- Added the column grading schema as a part of the bug 2037897. - aiyer
                                           X_GRADING_SCHEMA_CODE        => c_suatt_rec.grading_schema_code,
                                           X_DEG_AUD_DETAIL_ID          => c_suatt_rec.deg_aud_detail_id,
                                           X_SUBTITLE                   =>  c_suatt_rec.subtitle,
                                           X_STUDENT_CAREER_TRANSCRIPT  => c_suatt_rec.student_career_transcript,
                                           X_STUDENT_CAREER_STATISTICS  => c_suatt_rec.student_career_statistics,
                                           X_ATTRIBUTE_CATEGORY         => c_suatt_rec.attribute_category,
                                           X_ATTRIBUTE1                 => c_suatt_rec.attribute1,
                                           X_ATTRIBUTE2                 => c_suatt_rec.attribute2,
                                           X_ATTRIBUTE3                 => c_suatt_rec.attribute3,
                                           X_ATTRIBUTE4                 => c_suatt_rec.attribute4,
                                           X_ATTRIBUTE5                 => c_suatt_rec.attribute5,
                                           X_ATTRIBUTE6                 => c_suatt_rec.attribute6,
                                           X_ATTRIBUTE7                 => c_suatt_rec.attribute7,
                                           X_ATTRIBUTE8                 => c_suatt_rec.attribute8,
                                           X_ATTRIBUTE9                 => c_suatt_rec.attribute9,
                                           X_ATTRIBUTE10                => c_suatt_rec.attribute10,
                                           X_ATTRIBUTE11                => c_suatt_rec.attribute11,
                                           X_ATTRIBUTE12                => c_suatt_rec.attribute12,
                                           X_ATTRIBUTE13                => c_suatt_rec.attribute13,
                                           X_ATTRIBUTE14                => c_suatt_rec.attribute14,
                                           X_ATTRIBUTE15                => c_suatt_rec.attribute15,
                                           X_ATTRIBUTE16                => c_suatt_rec.attribute16,
                                           X_ATTRIBUTE17                => c_suatt_rec.attribute17,
                                           X_ATTRIBUTE18                => c_suatt_rec.attribute18,
                                           X_ATTRIBUTE19                => c_suatt_rec.attribute19,
                                           X_ATTRIBUTE20                => c_suatt_rec.attribute20,
                                           X_WAITLIST_MANUAL_IND        => c_suatt_rec.waitlist_manual_ind ,--Added by mesriniv for Bug 2554109 Mini Waitlist Build.
                                           X_WLST_PRIORITY_WEIGHT_NUM   => c_suatt_rec.wlst_priority_weight_num,
                                           X_WLST_PREFERENCE_WEIGHT_NUM => c_suatt_rec.wlst_preference_weight_num,
                                           -- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
                                           X_CORE_INDICATOR_CODE        => c_suatt_rec.core_indicator_code
                                           );
                                    END LOOP;
                                END;
                                Igs_Ge_Gen_003.genp_ins_log_entry (
                                                           p_s_log_type,
                                                           p_creation_dt,
                                                           cst_unit
                                                           ||','||cst_changed
                                                           ||','||cst_invalid
                                                           ||','||TO_CHAR(p_person_id)
                                                           ||','||p_course_cd
                                                           ||','||v_sua_rec.unit_cd
                                                           ||','||v_sua_rec.cal_type
                                                           ||','||TO_CHAR(v_sua_rec.ci_sequence_number),
                                                           'IGS_EN_UA_FAILES_STATUS_INVAL',
                                                            v_message_text);
                                   v_ret_val := FALSE;
                                   -- change has been made so exit and call again
                                   v_change_made := TRUE;
                        EXIT;
                    END IF; -- (c_sua_rec.invalid_cutoff_date IS NOT NULL AND
                        --  SYSDATE > c_sua_sca_rec.invalid_cutoff_date)
                END IF; -- IGS_RU_VAL_UNIT_RULE.rulp_val_enrol_unit
            END IF; -- (v_rec_found = FALSE)
        END LOOP;
        -- if a change was made call the procedure again.
        IF v_change_made = TRUE THEN
            enrpl_upd_enrolled_ua(
                    p_acad_cal_type,
                    p_acad_sequence_number,
                    p_person_id,
                    p_course_cd,
                    p_s_log_type,
                    p_creation_dt);
        END IF;
    EXCEPTION
        WHEN e_resource_busy_exception THEN
            IF (c_sua%ISOPEN) THEN
                CLOSE c_sua;
            END IF;
            RAISE;
        WHEN OTHERS THEN
            IF (c_sua%ISOPEN) THEN
                CLOSE c_sua;
            END IF;
            RAISE;
    END;
    EXCEPTION
        WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_012.enrpl_upd_enrolled_ua');
                Igs_Ge_Msg_Stack.ADD;
                    App_Exception.Raise_Exception;
    END enrpl_upd_enrolled_ua;
BEGIN
    -- enrp_upd_sca_urule
    -- This process validates the IGS_PS_UNIT rules for all units for a student IGS_PS_COURSE
    -- attempt within the nominated academic calendar instance.
    -- Rules are checked recursively until no more rules are failed or passed
    -- (where invalid). The outcome is ENROLLED or INVALID IGS_PS_UNIT attempts.
    -- Switching of the status is subject to the
    -- IGS_EN_CAL_CONF.enrolled_rule_cutoff_dt_alias and
    -- IGS_EN_CAL_CONF.invalid_rule_cutoff_dt_alias which are represented as
    -- IGS_CA_DA_INST records within the relevant teaching periods.
    -- All parameters are required, else checking and logging is not possible.
    IF( p_acad_cal_type     IS NULL OR
            p_acad_sequence_number  IS NULL OR
            p_person_id         IS NULL OR
            p_course_cd         IS NULL OR
            p_s_log_type        IS NULL OR
            p_creation_dt       IS NULL) THEN
        RETURN v_ret_val;
    END IF;
    -- Issue savepoint
    SAVEPOINT sp_upd_sua_status;
    gv_cntr := 0;
    t_checked_sua := t_checked_sua_blank;
    -- Re-check all INVALID IGS_PS_UNIT attempts and switch to ENROLLED if the rules
    -- are now passed. If an invalid IGS_PS_UNIT passes all rules the status is set
    -- to ENROLLED and the select is repeated(procedure calls itself). This
    -- repeats until no more invalid IGS_PS_UNIT attempts pass the IGS_PS_UNIT rules.
    enrpl_upd_invalid_ua(
            p_acad_cal_type,
            p_acad_sequence_number,
            p_person_id,
            p_course_cd,
            p_s_log_type,
            p_creation_dt);
    gv_cntr := 0;
    t_checked_sua := t_checked_sua_blank;
    --  Check all ENROLLED IGS_PS_UNIT attempt IGS_PS_UNIT rules. If a IGS_RU_RULE is failed the
    --  status is set to INVALID and the select is repeated (procedure calls
    --  itself). This process repeats until no further units fail rules.
    enrpl_upd_enrolled_ua(
            p_acad_cal_type,
            p_acad_sequence_number,
            p_person_id,
            p_course_cd,
            p_s_log_type,
            p_creation_dt);
    RETURN v_ret_val;
EXCEPTION
    WHEN e_resource_busy_exception THEN
        -- exception is handled by calling routine
        ROLLBACK TO sp_upd_sua_status;
        RAISE;
END;
/*
EXCEPTION
    WHEN OTHERS THEN
                        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_012.enrp_upd_sca_urule');
                    Igs_Ge_Msg_Stack.ADD;
                    App_Exception.Raise_Exception;
                    */
END enrp_upd_sca_urule;

FUNCTION Enrp_Upd_Scho_Tfn(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_tax_file_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN  AS
BEGIN
DECLARE
    CURSOR  c_scho(
             cp_person_id IGS_EN_STDNTPSHECSOP.person_id%TYPE) IS
        SELECT   scho.tax_file_number
        FROM     IGS_EN_STDNTPSHECSOP scho
        WHERE    scho.person_id = cp_person_id AND
             scho.tax_file_number IS NOT NULL AND
             scho.tax_file_invalid_dt IS NULL
        ORDER BY scho.start_dt DESC;
    v_tax_file_number       IGS_EN_STDNTPSHECSOP.tax_file_number%TYPE;
    v_scho_rec_found        BOOLEAN;
    v_person_id     IGS_EN_STDNTPSHECSOP.person_id%TYPE;

BEGIN
    -- Update IGS_EN_STDNTPSHECSOP.tax_file_number.
    p_message_name := NULL;
    v_scho_rec_found := FALSE;
    -- If the Tax File Number is set to 999999999 then a default value
    -- must be determined
    IF(p_tax_file_number = 999999999) THEN
        FOR v_scho_rec IN c_scho(
                    p_person_id) LOOP
            v_scho_rec_found := TRUE;
            v_tax_file_number := v_scho_rec.tax_file_number;
            EXIT;
        END LOOP;
        IF(v_scho_rec_found = FALSE) THEN
            p_message_name := 'IGS_EN_DFLT_TAX_FILE_NUM';
            RETURN FALSE;
        END IF;
    ELSE
        v_tax_file_number := p_tax_file_number;
    END IF;
    -- Attempt to lock the record.
    -- Failure will fall through to the exception handler.

      DECLARE

        CURSOR c_hecs_opt IS
    SELECT scho.ROWID,
               scho.*
    FROM    IGS_EN_STDNTPSHECSOP scho
    WHERE   scho.person_id = p_person_id AND
        scho.course_cd = p_course_cd AND
        scho.start_dt = p_start_dt
    FOR UPDATE NOWAIT;


      BEGIN

         FOR  c_hecs_opt_rec IN c_hecs_opt LOOP

    -- update IGS_PE_PERSON's tax file number

                        Igs_En_Stdntpshecsop_Pkg.UPDATE_ROW(
                          X_ROWID => c_hecs_opt_rec.ROWID,
                          X_PERSON_ID => c_hecs_opt_rec.PERSON_ID,
                          X_COURSE_CD => c_hecs_opt_rec.COURSE_CD,
                          X_START_DT  => c_hecs_opt_rec.START_DT,
                          X_END_DT  => c_hecs_opt_rec.end_dt,
                          X_HECS_PAYMENT_OPTION => c_hecs_opt_rec.HECS_PAYMENT_OPTION,
                          X_DIFFERENTIAL_HECS_IND => c_hecs_opt_rec.DIFFERENTIAL_HECS_IND,
                          X_DIFF_HECS_IND_UPDATE_WHO => c_hecs_opt_rec.DIFF_HECS_IND_UPDATE_WHO,
                          X_DIFF_HECS_IND_UPDATE_ON  => c_hecs_opt_rec.DIFF_HECS_IND_UPDATE_ON ,
                          X_OUTSIDE_AUS_RES_IND => c_hecs_opt_rec.OUTSIDE_AUS_RES_IND,
                          X_NZ_CITIZEN_IND => c_hecs_opt_rec.NZ_CITIZEN_IND,
                          X_NZ_CITIZEN_LESS2YR_IND => c_hecs_opt_rec.NZ_CITIZEN_LESS2YR_IND,
                          X_NZ_CITIZEN_NOT_RES_IND => c_hecs_opt_rec.NZ_CITIZEN_NOT_RES_IND,
                          X_SAFETY_NET_IND => c_hecs_opt_rec.SAFETY_NET_IND,
                          X_TAX_FILE_NUMBER  => v_tax_file_number,
                          X_TAX_FILE_NUMBER_COLLECTED_DT  => c_hecs_opt_rec.TAX_FILE_NUMBER_COLLECTED_DT,
                          X_TAX_FILE_INVALID_DT  => c_hecs_opt_rec.TAX_FILE_INVALID_DT,
                          X_TAX_FILE_CERTIFICATE_NUMBER  => c_hecs_opt_rec.TAX_FILE_CERTIFICATE_NUMBER,
                          X_DIFF_HECS_IND_UPDATE_COMMENT => c_hecs_opt_rec.DIFF_HECS_IND_UPDATE_COMMENTs,
                          X_MODE =>  'R'
                          );

         END LOOP;

         END;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -54 THEN
            -- A record lock.
            p_message_name := 'IGS_EN_HECS_PRSN_LOCKED';
            RETURN FALSE;
        ELSE
                    Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_012.enrp_upd_scho_tfn');
                Igs_Ge_Msg_Stack.ADD;
                    App_Exception.Raise_Exception;
        END IF;
END;
END enrp_upd_scho_tfn;

END igs_en_gen_012;

/
