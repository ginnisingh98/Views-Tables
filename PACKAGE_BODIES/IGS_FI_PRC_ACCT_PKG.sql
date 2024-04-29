--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_ACCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_ACCT_PKG" AS
/* $Header: IGSFI60B.pls 120.5 2006/06/26 09:33:39 abshriva ship $ */

  -- Global variables for the Package.
  g_oracle_rec_installed igs_fi_control.rec_installed%TYPE;
  g_n_coa_id gl_sets_of_books.chart_of_accounts_id%TYPE;

  TYPE accsegs IS RECORD(
    l_segment    igs_fi_acct_segs_v.segment%TYPE,
    lv_Segment_num   igs_fi_acct_segs_v.segment_num%TYPE,
    lv_segment_value igs_ps_accts.segment_value%TYPE,
    l_value_length   fnd_flex_Value_Sets.maximum_size%TYPE);

  TYPE accsegs_list IS TABLE OF accsegs;

  g_accsegs  accsegs_list := accsegs_list();
  -- Profile for determining whether Nominated or Derived values are used
  g_v_att_profile         CONSTANT fnd_lookup_values.lookup_code%TYPE := FND_PROFILE.VALUE('IGS_FI_NOM_DER_VALUES');

  PROCEDURE concat_seg_values(
    p_err_string IN OUT NOCOPY VARCHAR2,
    p_return_status OUT NOCOPY BOOLEAN
  ) AS

    /******************************************************************
     Created By      :   rbezawad
     Date Created By :   24-07-2001
     Purpose         :   This procedure concatenates the Segment values
                         with the error string passed.

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */

  -- Get the Delimiter that is set for the Segment Code Combinations
  -- and use this for seperating the segments
  l_v_delimiter fnd_id_flex_structures.concatenated_segment_delimiter%TYPE := fnd_flex_ext.get_delimiter('SQLGL','GL#',g_n_coa_id);
  l_v_null igs_lookup_values.meaning%TYPE;
  BEGIN


    l_v_null := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','NULL_VALUE');

    -- Loop through the Segment values of the Table and concatenate
    -- the error string with values.  If segment value is NULL then
    -- concatenate the segment value as NULL delimeted by '-'.

    FOR i IN 1..g_accsegs.COUNT LOOP
      IF g_accsegs(i).lv_segment_value IS NULL THEN
        IF i = 1 THEN
          p_err_string := SUBSTR(p_err_string||l_v_null,1,1000);
        ELSE
          p_err_string := SUBSTR(p_err_string||' '||l_v_delimiter||' '||l_v_null,1,1000);
        END IF;
      ELSE
        IF i = 1 THEN
          p_err_string := SUBSTR(p_err_string||' '||g_accsegs(i).lv_segment_value,1,1000);
        ELSE
          p_err_string := SUBSTR(p_err_string||' '||l_v_delimiter||' '||g_accsegs(i).lv_segment_value,1,1000);
        END IF;
      END IF;
    END LOOP;

    p_return_status := TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FALSE;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','CONCAT_SEG_VALUES: '||SQLERRM);
      RETURN;
  END concat_seg_values;

  PROCEDURE get_charge_acct_ccids(
    x_cr_gl_ccid OUT NOCOPY NUMBER,
    p_error_type OUT NOCOPY NUMBER,
    p_error_string OUT NOCOPY VARCHAR2,
    p_return_status OUT NOCOPY BOOLEAN
  ) AS

    /*****************************************************************************
     Created By      :   rbezawad
     Date Created By :   24-07-2001
     Purpose         :   This procedure returns the Revenue and
                         Receivables CCID's for a Charge Transactions.

     Known limitations,enhancements,remarks:
     Change History
     Who         When           What
     pathipat    20-Jun-2003    Bug: 3004932 - Set error type = 2 instead of 3 if
                                flexfield validation fails.
    ******************************************************************************/

    PRAGMA AUTONOMOUS_TRANSACTION;

    --
    --To get the No of Segements
    --
    CURSOR cur_n_seg(cp_v_enabled_flag VARCHAR2, cp_v_flex_cd VARCHAR2, cp_n_coa_id NUMBER)
    IS
    SELECT COUNT(*)
    FROM fnd_id_flex_segments
    WHERE id_flex_num = cp_n_coa_id
    AND enabled_flag= cp_v_enabled_flag
    AND id_flex_code = cp_v_flex_cd;

    l_rev_gl_ccid NUMBER;
    l_n_seg NUMBER;                                            -- To hold the Number Segments defined for Flex field.
    l_sv_list fnd_flex_ext.segmentarray;
  BEGIN
    OPEN cur_n_seg('Y','GL#',g_n_coa_id);
    FETCH cur_n_seg INTO l_n_seg;
    CLOSE cur_n_seg;

    FOR i IN 1 .. g_accsegs.COUNT LOOP
      l_sv_list(i) := g_accsegs(i).lv_segment_value;
    END LOOP;
    -- After the following funcion call, Revenue CCID is returned to x_cr_gl_ccid paramter which is a OUT NOCOPY paramter
    IF (fnd_flex_ext.get_combination_id( application_short_name => 'SQLGL',
                                         key_flex_code          => 'GL#',
                                         structure_number       => g_n_coa_id,
                                         validation_date        => SYSDATE,
                                         n_segments             => l_n_seg,
                                         segments               => l_sv_list,
                                         combination_id         => l_rev_gl_ccid) = FALSE) THEN

       --If the Passed Combination of Values is Invalid then ROLLBACK the Transaction and return.
       p_error_string := fnd_flex_ext.get_message;
       p_error_string := p_error_string||' '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','SEGMENT_VALUE')||' ';
       concat_seg_values(p_error_string,p_return_status);
       IF (p_return_status = FALSE) THEN
         --When and Unhandled Exception Occurs in Concat_seg_values then Return with Type 1 Error
         p_error_type := 1;
         p_error_string := SUBSTR(fnd_message.get,1,1000);
         ROLLBACK;
         RETURN;
       END IF;
       p_error_type := 2;  -- Modified to error type 2 instead of 3 to maintain consistency
       p_return_status := FALSE;
       ROLLBACK;
       RETURN;
    ELSE
      COMMIT;  -- Commit's the transaction if a new Combination is inserted.
      x_cr_gl_ccid := l_rev_gl_ccid; -- Revenue CCID is passed to OUT NOCOPY parameter
      p_return_status := TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','GET_CHARGE_ACCT_CCIDS: '||SQLERRM);
      p_error_type := 1;
      p_return_status := FALSE;
      ROLLBACK;
      RETURN;
  END get_charge_acct_ccids;

  PROCEDURE get_segment_values_list(
    p_entity_type_code IN VARCHAR2,
    p_fee_type IN VARCHAR2,
    p_fee_cal_type IN VARCHAR2,
    p_fee_ci_sequence_number IN NUMBER,
    p_course_cd IN VARCHAR2,
    p_course_version_number IN NUMBER,
    p_org_unit_cd IN VARCHAR2,
    p_org_start_dt IN DATE,
    p_unit_cd IN VARCHAR2,
    p_unit_version_number IN NUMBER,
    p_uoo_id IN NUMBER,
    p_location_cd IN VARCHAR2,
    p_error_string OUT NOCOPY VARCHAR2,
    p_return_status OUT NOCOPY BOOLEAN
  ) AS

    /**********************************************************************************************
     Created By      :   rbezawad
     Date Created By :   24-07-2001
     Purpose         :   This procedure returns the the Segment Values List for the entity basing on
                         given p_entity_type_code value. This procedure also checks for an entity, whether
                         any of the segment values are NULL.  If any of them are NULL then 1 is returned
                         to p_null_flag.  If all the segment values are found then 0 is returned.
                         And if there is no Segment Data available in Account Tables then p_null_flag
                         will contain NULL.

     Known limitations,enhancements,remarks:
     Change History
     Who        When            What
     vchappid   19-May-2003     Build Bug# 2831572, Financial Accounting Enhancements,
                                variable p_seg_num_val is removed, update of the segments is directly done
                                Hence procedure update_seg_values is also removed since it is not required to update
                                the Global segments.
     schodava   20-Sep-2002     Enh # 2564643 - Subaccount Removal
                                Removed references to subaccount.
    *************************************************************************************************/

    --
    --Get the Segment Values for the Program Entity
    --
    CURSOR cur_ps_accts (cp_course_cd  igs_ps_accts.course_cd%TYPE,
                         cp_version_number igs_ps_accts.version_number%TYPE)
    IS
    SELECT segment_num,segment_value
    FROM   igs_ps_accts
    WHERE  course_cd= cp_course_cd
    AND    version_number = cp_version_number;

    --
    --Get the Segment Values for the Unit Entity
    --
    CURSOR cur_ps_unit_accts (cp_unit_cd  igs_ps_unit_accts.unit_cd%TYPE,
                              cp_version_number igs_ps_unit_accts.version_number%TYPE)
    IS
    SELECT segment_num,segment_value
    FROM   igs_ps_unit_accts
    WHERE  unit_cd= cp_unit_cd
    AND    version_number = cp_version_number;

    --
    --Get the Segment Values for the Unit Section Entity
    --
    CURSOR cur_ps_usec_accts (cp_uoo_id igs_ps_usec_accts.uoo_id%TYPE)
    IS
    SELECT segment_num,segment_value
    FROM   igs_ps_usec_accts
    WHERE  uoo_id = cp_uoo_id;

    --
    --Get the Segment Values for the Organization Entity
    --
    CURSOR cur_or_unit_accts (cp_org_unit_cd igs_or_unit_accts.org_unit_cd%TYPE,
                              cp_start_dt igs_or_unit_accts.start_dt%TYPE)
    IS
    SELECT segment_num,segment_value
    FROM   igs_or_unit_accts
    WHERE  org_unit_cd = cp_org_unit_cd
    AND    start_dt = cp_start_dt;

    --
    --Get the Segment Values for the Location Entity
    --
    CURSOR cur_ad_loc_accts (cp_location_cd igs_ad_loc_accts.location_cd%TYPE)
    IS
    SELECT segment_num,segment_value
    FROM   igs_ad_loc_accts
    WHERE  location_cd = cp_location_cd;

    --
    --Get the Segment Values for the Sub Account Entity
    --
    CURSOR cur_fi_sa_segments
    IS
    SELECT segment_num,segment_value
    FROM   igs_fi_sa_segments;

    --
    --Get the Segment Values for the Fee Type Entity
    --
    CURSOR cur_fi_f_type_accts (cp_fee_type igs_fi_f_type_accts.fee_type%TYPE,
                                cp_fee_cal_type igs_fi_f_type_accts.fee_cal_type%TYPE,
                                cp_fee_ci_sequence_number igs_fi_f_type_accts.fee_ci_sequence_number%TYPE)
    IS
    SELECT segment_num,segment_value
    FROM   igs_fi_f_type_accts
    WHERE  fee_type = cp_fee_type
    AND    fee_cal_type = cp_fee_cal_type
    AND    fee_ci_sequence_number = cp_fee_ci_sequence_number;

  BEGIN

    --Collect all Segment Values of the Entity Unit Section
    IF (p_entity_type_code = 'USEC') THEN
      FOR l_ps_usec_accts_rec IN cur_ps_usec_accts(p_uoo_id) LOOP
        IF ((l_ps_usec_accts_rec.segment_value IS NOT NULL)
            AND
           (g_accsegs(l_ps_usec_accts_rec.segment_num).lv_segment_value) IS NULL) THEN
            g_accsegs(l_ps_usec_accts_rec.segment_num).lv_segment_value := l_ps_usec_accts_rec.segment_value;
        END IF;
      END LOOP;

    ELSIF (p_entity_type_code = 'LOC') THEN
      FOR l_ad_loc_accts_rec IN cur_ad_loc_accts(p_location_cd) LOOP
        IF ((l_ad_loc_accts_rec.segment_value IS NOT NULL)
            AND
           (g_accsegs(l_ad_loc_accts_rec.segment_num).lv_segment_value) IS NULL) THEN
            g_accsegs(l_ad_loc_accts_rec.segment_num).lv_segment_value := l_ad_loc_accts_rec.segment_value;
        END IF;
      END LOOP;

    ELSIF (p_entity_type_code = 'FTCI') THEN
      FOR l_fi_f_type_accts_rec IN cur_fi_f_type_accts(p_fee_type, p_fee_cal_type, p_fee_ci_sequence_number) LOOP
        IF ((l_fi_f_type_accts_rec.segment_value IS NOT NULL)
            AND
           (g_accsegs(l_fi_f_type_accts_rec.segment_num).lv_segment_value) IS NULL) THEN
            g_accsegs(l_fi_f_type_accts_rec.segment_num).lv_segment_value := l_fi_f_type_accts_rec.segment_value;
        END IF;
      END LOOP;
    ELSIF (p_entity_type_code = 'SA') THEN
      FOR l_fi_sa_segments_rec IN cur_fi_sa_segments LOOP
        IF ((l_fi_sa_segments_rec.segment_value IS NOT NULL)
            AND
           (g_accsegs(l_fi_sa_segments_rec.segment_num).lv_segment_value) IS NULL) THEN
            g_accsegs(l_fi_sa_segments_rec.segment_num).lv_segment_value := l_fi_sa_segments_rec.segment_value;
        END IF;
      END LOOP;
    ELSIF (p_entity_type_code = 'PS') THEN
      FOR l_ps_accts_rec IN cur_ps_accts(p_course_cd, p_course_version_number) LOOP
        IF ((l_ps_accts_rec.segment_value IS NOT NULL)
            AND
           (g_accsegs(l_ps_accts_rec.segment_num).lv_segment_value) IS NULL) THEN
            g_accsegs(l_ps_accts_rec.segment_num).lv_segment_value := l_ps_accts_rec.segment_value;
        END IF;
      END LOOP;
    ELSIF (p_entity_type_code = 'ORG') THEN
      FOR l_or_unit_accts_rec IN cur_or_unit_accts(p_org_unit_cd, p_org_start_dt) LOOP
        IF ((l_or_unit_accts_rec.segment_value IS NOT NULL)
            AND
           (g_accsegs(l_or_unit_accts_rec.segment_num).lv_segment_value) IS NULL) THEN
            g_accsegs(l_or_unit_accts_rec.segment_num).lv_segment_value := l_or_unit_accts_rec.segment_value;
        END IF;
      END LOOP;
    ELSIF (p_entity_type_code = 'UNIT') THEN
      FOR l_ps_unit_accts_rec IN cur_ps_unit_accts(p_unit_cd, p_unit_version_number) LOOP
        IF ((l_ps_unit_accts_rec.segment_value IS NOT NULL)
            AND
           (g_accsegs(l_ps_unit_accts_rec.segment_num).lv_segment_value) IS NULL) THEN
            g_accsegs(l_ps_unit_accts_rec.segment_num).lv_segment_value := l_ps_unit_accts_rec.segment_value;
        END IF;
      END LOOP;
    END IF;
    p_return_status := TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FALSE;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','GET_SEGMENT_VALUES_LIST: '||SQLERRM);
      RETURN;
  END get_segment_values_list;

  PROCEDURE get_natural_account(p_v_fee_type VARCHAR2,
                                p_v_fee_cal_type VARCHAR2,
                                p_n_fee_ci_seq_num NUMBER,
                                p_v_location_cd VARCHAR2,
                                p_v_att_type VARCHAR2,
                                p_v_att_mode VARCHAR2,
                                p_v_course_cd VARCHAR2,
                                p_n_crs_ver_num NUMBER,
                                p_v_unit_cd VARCHAR2,
                                p_n_unit_ver_num NUMBER,
                                p_v_org_unit_cd VARCHAR2,
                                p_v_residency_status_cd VARCHAR2,
                                p_n_uoo_id NUMBER,
                                p_v_nat_acc_seg OUT NOCOPY VARCHAR2,
                                p_v_account_cd  OUT NOCOPY VARCHAR2,
                                p_n_err_type OUT NOCOPY NUMBER,
                                p_v_err_msg OUT NOCOPY VARCHAR2,
                                p_b_status OUT NOCOPY BOOLEAN,
                                p_n_unit_type_id IN NUMBER,
                                p_v_unit_class   IN VARCHAR2,
                                p_v_unit_mode    IN VARCHAR2,
                                p_v_unit_level   IN VARCHAR2
                               )
  AS
  /******************************************************************
   Created By      : vchappid
   Date Created By : 16-May-2003
   Purpose         : This is the local procedure for identifying the natural account segment,
                     reveue account code for the input attributes.

   Known limitations,enhancements,remarks:
   Change History
   Who      When         What
   abshriva 19-JUN-2006  Bug#5104329:Added cursor cur_get_att_mode
   bannamal 03-JUN-2005  Bug#3442712 Unit Level Fee Assessment Build
                         Added new parameters for this build.
  ***************************************************************** */

    CURSOR cur_ftci_accts (cp_v_fee_type VARCHAR2,
                           cp_v_fee_cal_type VARCHAR2,
                           cp_n_sequence_number NUMBER)
    IS
    SELECT *
    FROM igs_fi_ftci_accts
    WHERE fee_type = cp_v_fee_type
    AND fee_cal_type = cp_v_fee_cal_type
    AND fee_ci_sequence_number = cp_n_sequence_number
    ORDER BY order_sequence;

    CURSOR cur_get_att_mode( p_att_mode igs_en_atd_mode_all.attendance_mode%TYPE)
    IS
    SELECT am.govt_attendance_mode
    FROM igs_en_atd_mode_all am
    WHERE am.attendance_mode=p_att_mode;

    l_cur_ftci_accts cur_ftci_accts%ROWTYPE;
    l_n_rec_exists NUMBER :=0;
    l_b_flag BOOLEAN := FALSE;
    l_b_rec_matchs BOOLEAN := FALSE;
    l_v_natural_account_segment igs_fi_ftci_accts.natural_account_segment%TYPE;
    l_v_rev_account_cd igs_fi_ftci_accts.rev_account_cd%TYPE;
    cst_nominated   CONSTANT igs_lookups_view.lookup_code%TYPE := 'NOMINATED';
    cst_derived     CONSTANT igs_lookups_view.lookup_code%TYPE := 'DERIVED';
    l_v_att_mode           igs_en_atd_mode_all.attendance_mode%TYPE;
  BEGIN

    FOR l_rec_ftci_accts IN cur_ftci_accts(p_v_fee_type,p_v_fee_cal_type,p_n_fee_ci_seq_num) LOOP
      l_b_flag := TRUE;

      -- Initialize the record count indicator to the number of records fetched by the cursor
      -- when uer has not setup any accounting information then the record count will be 0
      l_n_rec_exists := cur_ftci_accts%ROWCOUNT;

      -- Match the Org Unit Code attribute when it is found that the Fee Type Account Record has a value
      -- for the Org Unit Code column.
      IF (l_rec_ftci_accts.org_unit_cd IS NOT NULL) THEN
        IF (l_rec_ftci_accts.org_unit_cd <> p_v_org_unit_cd OR p_v_org_unit_cd IS NULL) THEN
          l_b_flag := FALSE;
        END IF;
      END IF;

      -- Match the Location Code attribute when it is found that the Fee Type Account Record has a value
      -- for the Location Code column.
      IF (l_rec_ftci_accts.location_cd IS NOT NULL) AND l_b_flag THEN
        IF (l_rec_ftci_accts.location_cd <> p_v_location_cd OR p_v_location_cd IS NULL) THEN
          l_b_flag := FALSE;
        END IF;
      END IF;

      -- Match the Unit Section attribute when it is found that the Fee Type Account Record has a value
      -- for the Unit Section column.
      IF (l_rec_ftci_accts.uoo_id IS NOT NULL) AND l_b_flag THEN
        IF (l_rec_ftci_accts.uoo_id <> p_n_uoo_id OR p_n_uoo_id IS NULL) THEN
          l_b_flag := FALSE;
        END IF;
      END IF;

      -- Match the Unit Code attribute when it is found that the Fee Type Account Record has a value
      -- for the Unit Code column.
      IF (l_rec_ftci_accts.unit_cd  IS NOT NULL AND l_rec_ftci_accts.unit_version_number IS NOT NULL) AND l_b_flag THEN
        IF ((l_rec_ftci_accts.unit_cd <> p_v_unit_cd) OR p_v_unit_cd IS NULL) THEN
          l_b_flag := FALSE;
        ELSIF ((l_rec_ftci_accts.unit_version_number <> p_n_unit_ver_num ) OR (p_n_unit_ver_num IS NULL )) THEN
          l_b_flag := FALSE;
        END IF;
      END IF;

      -- Match the Course Code attribute when it is found that the Fee Type Account Record has a value
      -- for the Course Code column.
      IF (l_rec_ftci_accts.course_cd IS NOT NULL AND l_rec_ftci_accts.crs_version_number IS NOT NULL) AND l_b_flag THEN
        IF ((l_rec_ftci_accts.course_cd <> p_v_course_cd) OR p_v_course_cd IS NULL) THEN
          l_b_flag := FALSE;
        ELSIF ((l_rec_ftci_accts.crs_version_number <> p_n_crs_ver_num ) OR (p_n_crs_ver_num IS NULL )) THEN
          l_b_flag := FALSE;
        END IF;
      END IF;

      -- Match the Residency Status attribute when it is found that the Fee Type Account Record has a value
      -- for the Residency Status column.
      IF (l_rec_ftci_accts.residency_status_cd IS NOT NULL) AND l_b_flag THEN
        IF (l_rec_ftci_accts.residency_status_cd <> p_v_residency_status_cd OR p_v_residency_status_cd IS NULL) THEN
          l_b_flag := FALSE;
        END IF;
      END IF;

      -- Match the Attendance Type attribute when it is found that the Fee Type Account Record has a value
      -- for the Attendance Type column.
      IF (l_rec_ftci_accts.attendance_type IS NOT NULL) AND l_b_flag THEN
        IF (l_rec_ftci_accts.attendance_type <> p_v_att_type OR p_v_att_type IS NULL) THEN
          l_b_flag := FALSE;
        END IF;
      END IF;

      -- Match the Attendance Mode attribute when it is found that the Fee Type Account Record has a value
      -- for the Attendance Mode column.
      IF (l_rec_ftci_accts.attendance_mode IS NOT NULL) AND l_b_flag THEN
        IF (g_v_att_profile=cst_nominated) THEN
          IF (l_rec_ftci_accts.attendance_mode <> p_v_att_mode OR p_v_att_mode IS NULL) THEN
            l_b_flag := FALSE;
          END IF;
        END IF;
        IF (g_v_att_profile=cst_derived) THEN
          OPEN cur_get_att_mode(l_rec_ftci_accts.attendance_mode);
          FETCH cur_get_att_mode INTO l_v_att_mode;
          CLOSE cur_get_att_mode;
          IF ( l_v_att_mode <> p_v_att_mode OR p_v_att_mode IS NULL) THEN
            l_b_flag := FALSE;
          END IF;
        END IF;
      END IF;

      -- Match the Unit Program Type Level attribute when it is found that the Fee Type Account Record has a value
      -- for the Unit Program Type Level column.
      IF (l_rec_ftci_accts.unit_type_id IS NOT NULL) AND l_b_flag THEN
        IF (l_rec_ftci_accts.unit_type_id <> p_n_unit_type_id OR p_n_unit_type_id IS NULL) THEN
           l_b_flag := FALSE;
        END IF;
      END IF;

      -- Match the Unit Class attribute when it is found that the Fee Type Account Record has a value
      -- for the Unit Class column.
      IF (l_rec_ftci_accts.unit_class IS NOT NULL) AND l_b_flag THEN
        IF (l_rec_ftci_accts.unit_class <> p_v_unit_class OR p_v_unit_class IS NULL) THEN
           l_b_flag := FALSE;
        END IF;
      END IF;

      -- Match the Unit Mode attribute when it is found that the Fee Type Account Record has a value
      -- for the Unit Mode column.
      IF (l_rec_ftci_accts.unit_mode IS NOT NULL) AND l_b_flag THEN
        IF (l_rec_ftci_accts.unit_mode <> p_v_unit_mode OR p_v_unit_mode IS NULL) THEN
           l_b_flag := FALSE;
        END IF;
      END IF;

      -- Match the Unit Level attribute when it is found that the Fee Type Account Record has a value
      -- for the Unit Level column.
      IF (l_rec_ftci_accts.unit_level IS NOT NULL) AND l_b_flag THEN
        IF (l_rec_ftci_accts.unit_level <> p_v_unit_level OR p_v_unit_level IS NULL) THEN
           l_b_flag := FALSE;
        END IF;
      END IF;

      -- If the record matches then assign the natural account segment, revenue account code and the exit the loop
      IF l_b_flag THEN
        l_b_rec_matchs := TRUE;
        l_v_natural_account_segment := l_rec_ftci_accts.natural_account_segment;
        l_v_rev_account_cd := l_rec_ftci_accts.rev_account_cd;
        EXIT;
      END IF;
    END LOOP;

    -- No records exists in the Fee Type Accounts table for the Fee Type, Fee Period assign FALSE to the variable
    -- and exit of the procedure
    IF l_n_rec_exists = 0 THEN
      p_v_nat_acc_seg := NULL;
      p_v_account_cd := NULL;
      p_n_err_type := 0;
      p_v_err_msg := NULL;
      p_b_status := FALSE;
    ELSE
      -- When there are records existing and if the attributes matches then assign the natural account segment,
      -- revenue account code to the variables and exit from the procedure
      IF l_b_rec_matchs THEN
        --records exists and matches
        p_v_nat_acc_seg := l_v_natural_account_segment;
        p_v_account_cd := l_v_rev_account_cd;
        p_n_err_type := 0;
        p_v_err_msg := NULL;
        p_b_status := TRUE;
      ELSE
        -- When there are records existing and if the attributes doesnot match
        -- assign FALSE to the variable and exit the procedure
        p_v_nat_acc_seg := NULL;
        p_v_account_cd := NULL;
        p_n_err_type := 1;
        p_v_err_msg := 'IGS_FI_NAT_ACC_SEG_NOTDERIVED';
        p_b_status := FALSE;
      END IF;
    END IF;
  END get_natural_account;

  PROCEDURE build_accounts(
    p_fee_type IN VARCHAR2,
    p_fee_cal_type IN VARCHAR2,
    p_fee_ci_sequence_number IN NUMBER,
    p_course_cd IN VARCHAR2,
    p_course_version_number IN NUMBER,
    p_org_unit_cd IN VARCHAR2,
    p_org_start_dt IN DATE,
    p_unit_cd IN VARCHAR2,
    p_unit_version_number IN NUMBER,
    p_uoo_id IN NUMBER,
    p_location_cd IN VARCHAR2,
    p_transaction_type IN VARCHAR2,
    p_credit_type_id IN NUMBER,
    p_source_transaction_id IN NUMBER,
    x_dr_gl_ccid IN OUT NOCOPY NUMBER,
    x_cr_gl_ccid IN OUT NOCOPY NUMBER,
    x_dr_account_cd IN OUT NOCOPY VARCHAR2,
    x_cr_account_cd IN OUT NOCOPY VARCHAR2,
    x_err_type OUT NOCOPY NUMBER,
    x_err_string OUT NOCOPY VARCHAR2,
    x_ret_status OUT NOCOPY BOOLEAN,
    p_v_attendance_type IN VARCHAR2,
    p_v_attendance_mode IN VARCHAR2,
    p_v_residency_status_cd IN VARCHAR2,
    p_n_unit_type_id  IN NUMBER,
    p_v_unit_class IN VARCHAR2,
    p_v_unit_mode IN VARCHAR2,
    p_v_unit_level IN VARCHAR2,
    p_v_waiver_name IN VARCHAR2
    ) IS

    /*******************************************************************************
    Created by  : rbezawad
    Date created: 19-Jul-2001

    Purpose:  This procedure generates debit and credit account pairs for
              Charge and Credit Transactions.

    Known limitations/enhancements/remarks:
              1) The generated Debit and Credit Account pairs will be passed to
                 x_dr_gl_ccid, x_cr_gl_ccid, x_dr_account_cd, x_cr_account_cd
                 variables.
              2) If any Error Occurs then x_err_type, x_err_string will be set and
                 x_ret_status will be set to FALSE. x_err_type will be set to one of
                 the values 1 to 3.
              3) If Error Type is 1 then the calling calling programs should not
                 proceed further and the transaction should not be complete.
              4) If Error Type is 2 or 3 then calling program should proceed further
                 and transaction shuld be complete.  These kind of errors would be
                 allowed for User Correction in Charges History Form.
              5) If Build Account Process Runs successfully then it returns
                 TRUE to x_ret_status.
              6) In this procedure,  for getting Revenue CCID for a charge transaction
                 traversing through entities is done.  To Identify the Entity,
                 Lookups table(IGS_FI_ACCT_ENTITIES Lookup Type) data is used.

    Change History: (who, when, what: NO CREATION RECORDS HERE!)
    Who             When            What
    bannamal        03-JUN-2005     Bug#3442712 Unit Level Fee Assessment Build
                                    Added new parameters for this build.
    uudayapr        08-mar-2004     Bug# 3478599,added 'Document' also added as valid system fee type to raise
                                    Error(IGS_FI_SRC_TXN_ACC_INV) when  revenue account segment value cannot
                                    be derived.
    shtatiko        13-DEC-2003     Bug# 3288973, Added code to handle transaction type of RETENTION.
    uudayapr        16-oct-2003     Enh# 3117341 Modified as a part of AUDIT AND SPECIAL FEES Build.
    vchappid        16-May-2003     Bug# 2831572, Modified the Build Account Process as per the Financial Accounting
                                    Build.
    shtatiko        20-JAN-2003     Bug# 2739054, Modified code so that it won't return back if receivables information
                                    is not found and if the system fee type is EXTERNAL.
    vchappid        07-Jan-2003     Bug#2737685, For a system fee type of Ancillary, user should not be allowed
                                    to create any charge with error account as 'Y'.
    schodava        20-Sep-2002     Enh # 2564643 - Subaccount Removal
                                    Removed references to subaccount.
    agairola        17-May-2002     Following modifications were done for the bug
                                    2323555.
                                    1. Modified the cursor cur_f_typ_ca_inst_lkp to fetch
                                    the Account Codes and the receivables Account ccid
                                    and removed the redundant cursors which were written
                                    to fetch individual values.
                                    2. Handled the code to validate if the particular value
                                    is passed for the account, then the required processing
                                    should not be done for getting the particular account.
                                    For e.g. if the Revenue Account is passed, then the
                                    processing is not done for getting the Revenue Account
                                    and only receivable account is derived.
    agairola        12-May-2002     Added the code for deleting the g_accsegs PL/SQL
                                    table as part of bug 2366070
    agairola        30-Apr-2002     Modified the cursor call for cur_ftci_rec_acct_cd

    *******************************************************************************/

    -- Local variables for the Procedure Build_Accounts.

    --
    --Get the CCID's, Account Codes for a Credit Type Transaction.
    --
    CURSOR cur_cr_types (cp_credit_type_id igs_fi_cr_types.credit_type_id%TYPE)
    IS
    SELECT dr_gl_ccid,
           cr_gl_ccid,
           dr_account_cd,
           cr_account_cd
    FROM   igs_fi_cr_types
    WHERE  credit_type_id = cp_credit_type_id;

    l_cr_types_rec cur_cr_types%ROWTYPE;

    --
    --Get the Account Hierachy ID.
    --
    CURSOR cur_f_typ_ca_inst_lkp (cp_fee_type igs_fi_f_typ_ca_inst_lkp_v.fee_type%TYPE,
                                  cp_fee_cal_type igs_fi_f_typ_ca_inst_lkp_v.fee_cal_type%TYPE,
                                  cp_fee_ci_sequence_number igs_fi_f_typ_ca_inst_lkp_v.fee_ci_sequence_number%TYPE)
    IS
    SELECT acct_hier_id,
           rec_account_cd,
           rec_gl_ccid,
           rev_account_cd,
           ret_gl_ccid,
           ret_account_cd
    FROM   igs_fi_f_typ_ca_inst
    WHERE  fee_type = cp_fee_type
    AND    fee_cal_type = cp_fee_cal_type
    AND    fee_ci_sequence_number = cp_fee_ci_sequence_number;

    l_f_typ_ca_inst_lkp_rec cur_f_typ_ca_inst_lkp%ROWTYPE;

    --
    --Get the Zero_fill flag defined for the Account Hierarchy ID
    --
    CURSOR cur_hier_accounts (cp_acct_hier_id igs_fi_hier_accounts.acct_hier_id%TYPE)
    IS
    SELECT zero_fill_flag
    FROM   igs_fi_hier_accounts
    WHERE  acct_hier_id = cp_acct_hier_id;

    l_hier_accounts_rec cur_hier_accounts%ROWTYPE;

    --
    --Get the Account Hierarchy Order Details for Entities Associated with given Account Hierarchy ID
    --
    CURSOR cur_hier_acct_tbl (cp_acct_hier_id igs_fi_hier_accounts.acct_hier_id%TYPE)
    IS
    SELECT acct_tbl_id,
           order_sequence,
           entity_type_code
    FROM   igs_fi_hier_acct_tbl
    WHERE  acct_hier_id = cp_acct_hier_id
    ORDER BY order_sequence;

   --This cursor added as a part of bug#2410396
   CURSOR  cur_sys_opt
   IS
   SELECT  rec_account_cd,
           rec_gl_ccid
   FROM    igs_fi_control;
   l_cur_sys_opt  cur_sys_opt%ROWTYPE;

   CURSOR cur_acc_segs
   IS
   SELECT seg.segment,seg.segment_num,val.maximum_size maximum_size
   FROM   igs_fi_acct_segs_v seg,
          fnd_flex_value_sets val
   WHERE  seg.flex_value_set_id = val.flex_value_set_id
   ORDER BY segment_num;

    -- cursor for selecting system fee type attached to the fee type that is passed as input to this procedure
    CURSOR c_sys_fee_type (cp_fee_type IN igs_fi_fee_type.fee_type%TYPE)
    IS
    SELECT s_fee_type
    FROM igs_fi_fee_type
    WHERE fee_type = cp_fee_type;
    l_v_s_fee_type igs_fi_fee_type.s_fee_type%TYPE;

    -- cursor for getting the Natural Account Segment for Application, Chart OF Accounts and
    -- Segment Attribute Type of GL_ACCOUNT
    CURSOR cur_seg_num (cp_n_coa_id NUMBER,
                        cp_n_appl_id NUMBER,
                        cp_v_attr_type VARCHAR2,
                        cp_v_attr_value VARCHAR2)
    IS
    SELECT application_column_name segment_name
    FROM fnd_segment_attribute_values
    WHERE id_flex_num = cp_n_coa_id
    AND application_id = cp_n_appl_id
    AND segment_attribute_type = cp_v_attr_type
    AND attribute_value = cp_v_attr_value;
    l_v_seg_name fnd_id_flex_segments.application_column_name%TYPE;

    l_return_status BOOLEAN;                                   -- To capture returned Status from get_charge_acct_ccids procedure call.
    l_error_string igs_fi_invln_int.error_string%TYPE;         -- To capture returned error string from get_charge_acct_ccids procedure call.
    l_error_type NUMBER;                                       -- To capture returned error type from get_charge_acct_ccids procedure call.
    l_error_type_cr NUMBER;
    l_error_string_cr igs_fi_invln_int.error_string%TYPE;
    l_return_status_cr BOOLEAN;


    l_rev_account_cd igs_fi_control.rev_account_cd%TYPE;       -- To hold Revenue Account Code.
    l_coa_id gl_sets_of_books.chart_of_accounts_id%TYPE;
    l_entity_no NUMBER;
    l_b_err_type1  BOOLEAN := FALSE;

    l_v_nat_acct_seg igs_fi_ftci_accts.natural_account_segment%TYPE;
    l_v_account_cd  igs_fi_acc.account_cd%TYPE;
    l_n_err_type NUMBER;
    l_v_err_msg fnd_new_messages.message_name%TYPE;
    l_b_nat_rec BOOLEAN;

    --Bug#3392095 - Tuition Waiver, Cursor to obtain the waiver program attributes for the fee, fee cal types combination.
    CURSOR cur_get_waiver_attr(cp_v_fee_type  igs_fi_inv_int_all.fee_type%TYPE,
                               cp_v_fee_cal_type igs_fi_inv_int_all.fee_cal_type%TYPE,
                               cp_n_fee_ci_sequence_number igs_fi_inv_int_all.fee_ci_sequence_number%TYPE,
                               cp_v_waiver_name igs_fi_waiver_pgms.waiver_name%TYPE)
    IS
    SELECT fwp.fee_cal_type,
           fwp.fee_ci_sequence_number,
           fwp.waiver_name,
           fwp.credit_type_id,
           fwp.target_fee_type
    FROM   igs_fi_waiver_pgms fwp
    WHERE  fwp.adjustment_fee_type = cp_v_fee_type
    AND    fwp.fee_cal_type    = cp_v_fee_cal_type
    AND    fwp.fee_ci_sequence_number = cp_n_fee_ci_sequence_number
    AND    fwp.waiver_name = cp_v_waiver_name;

    l_cur_get_waiver_attr cur_get_waiver_attr%ROWTYPE;

    l_cur_cr_types_rec1 cur_cr_types%ROWTYPE;

  BEGIN

    -- To know whether Oracle Receivables Installed in the System  or Not.
    g_oracle_rec_installed := igs_fi_gen_005.finp_get_receivables_inst;
    g_accsegs.DELETE;

    x_ret_status := TRUE;

    -- If the values are passed to the Build Account process for the accounts,
    -- return.
    IF ((x_dr_gl_ccid IS NOT NULL AND x_cr_gl_ccid IS NOT NULL) OR
        (x_dr_account_cd IS NOT NULL AND x_cr_account_cd IS NOT NULL)) THEN
        x_ret_status := TRUE;
       RETURN;
    END IF;

    IF (p_transaction_type = 'CREDIT') THEN
      -- If Transaction is a Credit Transaction

      OPEN cur_cr_types(p_credit_type_id);
      FETCH cur_cr_types INTO l_cr_types_rec;

      IF (cur_cr_types%FOUND) THEN
        IF (g_oracle_rec_installed = 'Y') THEN
          -- if the Oracle Receivables is Installed then return Credit and Debit CCID's
          x_dr_gl_ccid := l_cr_types_rec.dr_gl_ccid;
          x_cr_gl_ccid := l_cr_types_rec.cr_gl_ccid;
          x_dr_account_cd := NULL;
          x_cr_account_cd := NULL;
        ELSE
          -- if the Oracle Receivables is Installed then return Credit and Debit Account Codes
          x_dr_account_cd := l_cr_types_rec.dr_account_cd;
          x_cr_account_cd := l_cr_types_rec.cr_account_cd;
          x_dr_gl_ccid := NULL;
          x_cr_gl_ccid := NULL;
        END IF;
        CLOSE cur_cr_types;
        x_ret_status := TRUE;
        RETURN;
      ELSE
        -- If there is no Account Record found for the Credit Type and Sub Account arguments then raise error and Exit.
        CLOSE cur_cr_types;
        x_err_string := 'IGS_FI_CR_TYPE_NO_ACCT';
        x_err_type := 1;
        x_ret_status := FALSE;
        RETURN;
      END IF;

    ELSIF (p_transaction_type IN ('CHARGE', 'RETENTION')) THEN
      -- If Transaction is a Charge Transaction
      -- get the system fee type attached to the fee type that is passed as input to this procedure.
      OPEN c_sys_fee_type(p_fee_type);
      FETCH c_sys_fee_type INTO l_v_s_fee_type;
      CLOSE c_sys_fee_type;

      OPEN cur_f_typ_ca_inst_lkp(p_fee_type, p_fee_cal_type, p_fee_ci_sequence_number);
      FETCH cur_f_typ_ca_inst_lkp INTO l_f_typ_ca_inst_lkp_rec;
      IF ((cur_f_typ_ca_inst_lkp%NOTFOUND) AND (g_oracle_rec_installed = 'Y')) THEN
        CLOSE cur_f_typ_ca_inst_lkp;
        x_err_string := 'IGS_FI_NO_ACCT_HIER_FTCI';
        x_err_type := 1;
        x_ret_status := FALSE;
        RETURN;
      ELSE
        CLOSE cur_f_typ_ca_inst_lkp;

        --Bug #3392095 - Tuition Waiver.  Check user has selected TRANSACTION TYPE as Waiver Adjustment
        IF l_v_s_fee_type = 'WAIVER_ADJ' THEN
          --Obtain the waiver program attributes for the combination of fee type, fee cal type, fee ci seq number and waiver name
          --passed as inbound paramter to this procedure.
          OPEN cur_get_waiver_attr(p_fee_type,p_fee_cal_type, p_fee_ci_sequence_number, p_v_waiver_name);
          FETCH cur_get_waiver_attr INTO l_cur_get_waiver_attr;
          IF cur_get_waiver_attr%NOTFOUND THEN
            CLOSE cur_get_waiver_attr;
            x_err_string := 'IGS_FI_WAV_PGM_NO_REC_FOUND';
            x_err_type := 1;
            x_ret_status := FALSE;
            RETURN;
          END IF;
          CLOSE cur_get_waiver_attr;

          --Obtain the accounting information for the waiver credit type id.
          OPEN cur_cr_types(l_cur_get_waiver_attr.credit_type_id);
          FETCH cur_cr_types INTO l_cur_cr_types_rec1;
          IF cur_cr_types%NOTFOUND THEN
            CLOSE cur_cr_types;
            x_err_string := 'IGS_FI_CR_TYPE_NO_ACCT';
            x_err_type := 1;
            x_ret_status := FALSE;
            RETURN;
           END IF;
           CLOSE cur_cr_types;
        END IF;

        IF (g_oracle_rec_installed = 'Y') THEN
          --If Account Hierarchy ID found at FTCI Level then Get all the Account Hierarchy details.
          OPEN cur_hier_accounts(l_f_typ_ca_inst_lkp_rec.acct_hier_id);
          FETCH cur_hier_accounts INTO l_hier_accounts_rec;
          CLOSE cur_hier_accounts;

          --If Recievables CCID's found and pass to OUT NOCOPY parameters else raise Type 1 Error
          x_dr_gl_ccid := NVL(x_dr_gl_ccid, l_f_typ_ca_inst_lkp_rec.rec_gl_ccid);

          --Bug#2410396,if receivables ccid is not found at ftci level then fetch it from system options level
          IF x_dr_gl_ccid IS NULL THEN
            OPEN cur_sys_opt;
            FETCH cur_sys_opt INTO l_cur_sys_opt;
            CLOSE cur_sys_opt;
            x_dr_gl_ccid:=l_cur_sys_opt.rec_gl_ccid;
          END IF;

          IF x_dr_gl_ccid IS NULL THEN
            x_err_string := 'IGS_FI_NO_REC_ACCT_CD_FTCI';
            x_err_type := 1;
            x_ret_status := FALSE;

            -- We do not return from procedure if the system fee type is EXTERNAL.
            -- Continue to check whether revenue account setup is complete or not.
            -- But finally after checking the revenue account setup return with x_err_type = 1
            -- This has been done as part of Bug# 2739054
            IF l_v_s_fee_type = 'EXTERNAL' THEN
              l_b_err_type1 := TRUE;
            ELSE
              RETURN;
            END IF;
          END IF;

          --Bug#3392095 - Tution Waiver - Check user has selected TRANSACTION TYPE as Waiver Adjustment
          IF l_v_s_fee_type = 'WAIVER_ADJ' THEN
             --check whether GL debit account code for credit types record found exists or not.
             --accordingly, set the message to x_err_string var. and return back to the calling procedure.
             IF l_cur_cr_types_rec1.dr_gl_ccid IS NULL THEN
               x_err_string := 'IGS_FI_CR_TYPE_NO_ACCT';
               x_err_type := 1;
               x_ret_status := FALSE;
               RETURN;
             END IF;
             x_cr_gl_ccid := l_cur_cr_types_rec1.dr_gl_ccid;
             RETURN;
          END IF;

          -- For RETENTION Charges retention account information is mandatory
          IF p_transaction_type = 'RETENTION' THEN
            x_cr_gl_ccid := NVL(x_cr_gl_ccid, l_f_typ_ca_inst_lkp_rec.ret_gl_ccid);
            IF x_cr_gl_ccid IS NULL THEN
              x_err_string := 'IGS_FI_NO_RETENTION_ACC';
              x_err_type := 1;
              x_ret_status := FALSE;
              RETURN;
            END IF;
          END IF;

          --Check if Chart Of Accounts ID available or not.
          g_n_coa_id := igs_fi_gen_007.get_coa_id;
          IF (g_n_coa_id IS NULL) THEN
            x_err_string := 'IGS_FI_NO_COA_ID';
            x_err_type := 1;
            x_ret_status := FALSE;
            RETURN;
          END IF;

          IF (x_cr_gl_ccid IS NULL) THEN
            OPEN cur_seg_num (g_n_coa_id,101,'GL_ACCOUNT','Y');
            FETCH cur_seg_num INTO l_v_seg_name;
            CLOSE cur_seg_num;
          --Enh #3117341  Added 'AUDIT' also as a valid value for system fee type with
          --              the Existing 'TUTNFEE','OTHER'
            IF (l_v_s_fee_type IN ('TUTNFEE','OTHER','AUDIT')) THEN
              get_natural_account( p_v_fee_type => p_fee_type,
                                   p_v_fee_cal_type => p_fee_cal_type,
                                   p_n_fee_ci_seq_num => p_fee_ci_sequence_number,
                                   p_v_location_cd => p_location_cd,
                                   p_v_att_type => p_v_attendance_type,
                                   p_v_att_mode => p_v_attendance_mode,
                                   p_v_course_cd => p_course_cd ,
                                   p_n_crs_ver_num => p_course_version_number,
                                   p_v_unit_cd => p_unit_cd,
                                   p_n_unit_ver_num => p_unit_version_number,
                                   p_v_org_unit_cd => p_org_unit_cd,
                                   p_v_residency_status_cd => p_v_residency_status_cd,
                                   p_n_uoo_id => p_uoo_id,
                                   p_v_nat_acc_seg => l_v_nat_acct_seg,
                                   p_v_account_cd  => l_v_account_cd,
                                   p_n_err_type => l_n_err_type,
                                   p_v_err_msg => l_v_err_msg,
                                   p_b_status => l_b_nat_rec,
                                   p_n_unit_type_id => p_n_unit_type_id,
                                   p_v_unit_class => p_v_unit_class,
                                   p_v_unit_mode => p_v_unit_mode,
                                   p_v_unit_level => p_v_unit_level
                                   );

              IF (l_b_nat_rec = FALSE) AND (l_n_err_type = 1) THEN
                x_cr_gl_ccid := NULL;
                x_err_type :=2;
                x_err_string := fnd_message.get_string('IGS',l_v_err_msg);
                x_ret_status := FALSE;
                RETURN;
              END IF;
            END IF;

            -- To initialize the Account Segments Values Global Variable.
            FOR l_cur_acc_segs IN cur_Acc_segs LOOP
              g_accsegs.EXTEND;
              g_accsegs(g_accsegs.COUNT).l_segment := l_cur_acc_Segs.segment;
              g_accsegs(g_accsegs.COUNT).lv_segment_num := l_cur_acc_Segs.segment_num;
              --Enh #3117341 Added AUDIT also as a valid value for s_fee_type for intializing the
              --             segment value with the natural account segment derivied by get_natural_account proc.
              IF ((l_cur_acc_segs.segment = l_v_seg_name) AND (l_v_s_fee_type IN ('TUTNFEE','OTHER','AUDIT'))) THEN
                g_accsegs(g_accsegs.COUNT).lv_segment_value := l_v_nat_acct_seg;
              ELSE
                g_accsegs(g_accsegs.COUNT).lv_segment_value := NULL;
              END IF;
              g_accsegs(g_accsegs.COUNT).l_value_length := l_cur_acc_segs.maximum_size;
            END LOOP;

            FOR l_hier_acct_tbl_rec IN cur_hier_acct_tbl(l_f_typ_ca_inst_lkp_rec.acct_hier_id) LOOP
              -- Loop through the Each entity to get the Data.
              -- If Oracle Receivables Installed then Get the data from ACCTS_ALL tables for the
              -- Entities( Program, Unit, Unit Section, Organization, Location, System Options.
              -- Get the Segment Values list
              get_segment_values_list( l_hier_acct_tbl_rec.entity_type_code,
                                         p_fee_type,
                                         p_fee_cal_type,
                                         p_fee_ci_sequence_number,
                                         p_course_cd,
                                         p_course_version_number,
                                         p_org_unit_cd,
                                         p_org_start_dt,
                                         p_unit_cd,
                                         p_unit_version_number,
                                         p_uoo_id,
                                         p_location_cd,
                                         l_error_string,
                                         l_return_status
                                        );
              IF (l_return_status = FALSE) THEN
                x_err_string := l_error_string;
                x_err_type := 1;
                x_ret_status := FALSE;
                RETURN;
              END IF;
            END LOOP;  -- End of Entites Loop


            -- If any of the Segment Values are NULL and the entity is the  last level in Hierarchy
            -- then check the Zero Flag value.  If it is checked then fill the with zeros
            -- for the incomplete segment and get the CCID for the combination of segment values
            -- else raise error and exit.
            l_return_status := TRUE;
            FOR i IN 1..g_accsegs.COUNT LOOP
              IF  g_accsegs(i).lv_segment_value IS NULL THEN
                l_return_status := FALSE;
                EXIT;
              END IF;
            END LOOP;

            -- check if any of the segment is NULL at this stage. If any of the segments are null then depending
            -- the zero_fill_flag is set to 'Y' or not show error message.
            IF l_return_status = FALSE THEN
              IF (l_hier_accounts_rec.zero_fill_flag = 'Y') THEN
                -- If Zero Fill Flag is checked then fill with zeros for the incomplete segments and get CCID for combination.
                FOR i IN 1..g_accsegs.COUNT LOOP
                  IF  g_accsegs(i).lv_segment_value IS NULL THEN
                    g_accsegs(i).lv_segment_value := RPAD('0',g_accsegs(i).l_value_length,'0');
                  END IF;
                END LOOP;
              ELSE
                -- if the system fee type is Ancillary then the user should not be allowed to create
                -- any charge with error account as 'Y' Ancillary Charges cannot be created when Revenue
                -- Account Segments cannot be derived.
                -- Added Document also as a valid type to show the error msg and return from the function
                IF l_v_s_fee_type IN ('ANCILLARY','DOCUMENT') THEN
                  IF l_v_s_fee_type = 'ANCILLARY' THEN
                    x_err_string := 'IGS_FI_REV_ACCT_CD_NOT_EXIST';
                  ELSE
                    x_err_string := 'IGS_FI_SRC_TXN_ACC_INV';
                  END IF;

                  x_err_type := 1;
                  x_ret_status := FALSE;  --Set the Return Status.
                  RETURN; -- should return from this procedure
                ELSIF NOT l_b_err_type1 THEN
                  -- We have to handle l_b_err_type1 = TRUE case (Receivables account setup not done at FTCI and system
                  -- options level) to avoid masking of message IGS_FI_NO_REC_ACCT_CD_FTCI with this message.
                  x_err_string := fnd_message.get_string('IGS','IGS_FI_ZERO_FLAG_NOT_SET');
                  x_err_type := 2;
                  x_ret_status := FALSE;  --Set the Return Status.
                END IF;

                -- Concatenate the Segment Values to The Error Sting.
                concat_seg_values(x_err_string,l_return_status);
                IF (l_return_status = FALSE) THEN
                  --When and Unhandled Exception Occurs in Concat_seg_values then Return with Type 1 Error
                  x_err_type := 1;
                  x_ret_status := FALSE;
                  RETURN;
                END IF;
                RETURN; -- Return to Calling program by setting Type 2 error type and message concatenated with segment values.
              END IF;   --Zero flag Check
            END IF; -- l_return_status check

            -- get the gl ccid when the ccid is NULL.
            IF x_cr_gl_ccid IS NULL THEN
              get_charge_acct_ccids( x_cr_gl_ccid,
                                     l_error_type_cr,
                                     l_error_string_cr,
                                     l_return_status_cr
                                    );
            END IF;

            IF l_b_err_type1 THEN
              -- System Fee Type is External and the Receivables is not derived then the message and the return status are already set
              -- Just Return from the procedure.
              RETURN;
            ELSE
              IF l_return_status_cr THEN
                -- Accounting Information successfully derived
                x_err_string := NULL;
                x_err_type := NULL;
                x_ret_status := TRUE;
                RETURN;
              ELSE
                -- When there is any error in fetching the Code Combination ID then
                -- show that message.
                x_err_string := SUBSTR(l_error_string_cr,1,1000);
                x_err_type := l_error_type_cr;
                x_ret_status := FALSE;
                RETURN;
              END IF;
            END IF;
          END IF;
        ELSE
          -- If Oracle Receivables is not Installed then get the Data from Account Code String Tables for entities.
          -- Get the Corresponding Receivables Account Code defined at FTCI Level and pass
          -- to x_dr_account_cd which is a OUT NOCOPY parameter and Return.
          x_dr_account_cd := NVL(x_dr_account_cd,l_f_typ_ca_inst_lkp_rec.rec_account_cd);

          --Bug#2410396,if receivables Account code is not found at ftci level then fetch it from system level
          IF x_dr_account_cd IS NULL THEN
            OPEN cur_sys_opt;
            FETCH cur_sys_opt INTO l_cur_sys_opt;
            CLOSE cur_sys_opt;
            x_dr_account_cd := l_cur_sys_opt.rec_account_cd;
          END IF;

          -- Error out if the System Fee type is other than External
          -- In case of External system fee type continue with the revenue account ccid
          IF x_dr_account_cd IS NULL THEN
            x_err_string := 'IGS_FI_NO_REC_ACCT_CD_FTCI';
            x_err_type := 1;
            x_ret_status := FALSE;
            -- If system fee type is EXTERNAL we do not have to return but continue fetch
            -- revenue accounting information
            IF l_v_s_fee_type <> 'EXTERNAL' THEN
              RETURN;
            END IF;
          END IF;

          --Bug#3392095 - Tution Waiver - Check user has selected TRANSACTION TYPE as Waiver Adjustment
          IF l_v_s_fee_type = 'WAIVER_ADJ' THEN
             --check whether debit account code for credit types record found exists or not
             --accordingly, set the message to x_err_string var. and return back to the calling procedure.
             IF l_cur_cr_types_rec1.dr_account_cd IS NULL THEN
               x_err_string := 'IGS_FI_CR_TYPE_NO_ACCT';
               x_err_type := 1;
               x_ret_status := FALSE;
               RETURN;
             END IF;
             x_cr_account_cd := l_cur_cr_types_rec1.dr_account_cd;
             RETURN;
          END IF;

          -- For RETENTION Charges retention account information is mandatory
          IF p_transaction_type = 'RETENTION' THEN
            x_cr_account_cd  := NVL(x_cr_account_cd, l_f_typ_ca_inst_lkp_rec.ret_account_cd);
            IF x_cr_account_cd IS NULL THEN
              x_err_string := 'IGS_FI_NO_RETENTION_ACC';
              x_err_type := 1;
              x_ret_status := FALSE;
              RETURN;
            END IF;
          END IF;

          -- proceed with finding out the cr account code if it is not null
          IF (x_cr_account_cd IS NULL) THEN
          --Enh#3117341 added audit,special also as a valid system fee as a part of Audit and special fees build.
            IF (l_v_s_fee_type IN ('TUTNFEE','OTHER','AUDIT','SPECIAL')) THEN
              get_natural_account( p_v_fee_type => p_fee_type,
                                   p_v_fee_cal_type => p_fee_cal_type,
                                   p_n_fee_ci_seq_num => p_fee_ci_sequence_number,
                                   p_v_location_cd => p_location_cd,
                                   p_v_att_type => p_v_attendance_type,
                                   p_v_att_mode => p_v_attendance_mode,
                                   p_v_course_cd => p_course_cd ,
                                   p_n_crs_ver_num => p_course_version_number,
                                   p_v_unit_cd => p_unit_cd,
                                   p_n_unit_ver_num => p_unit_version_number,
                                   p_v_org_unit_cd => p_org_unit_cd,
                                   p_v_residency_status_cd => p_v_residency_status_cd,
                                   p_n_uoo_id => p_uoo_id,
                                   p_v_nat_acc_seg => l_v_nat_acct_seg,
                                   p_v_account_cd  => l_v_account_cd,
                                   p_n_err_type => l_n_err_type,
                                   p_v_err_msg => l_v_err_msg,
                                   p_b_status => l_b_nat_rec,
                                   p_n_unit_type_id => p_n_unit_type_id,
                                   p_v_unit_class => p_v_unit_class,
                                   p_v_unit_mode => p_v_unit_mode,
                                   p_v_unit_level => p_v_unit_level
                                   );

              IF (l_b_nat_rec = FALSE) THEN
                IF (l_n_err_type = 0) THEN
                  x_cr_account_cd  := NULL;
                  x_err_type := 1;
                  x_err_string := 'IGS_FI_REV_ACCT_CD_NOT_EXIST';
                  x_ret_status := FALSE;
                  RETURN;
                ELSIF (l_n_err_type = 1) THEN
                  x_cr_account_cd  := NULL;
                  x_err_type := 1;
                  x_err_string := l_v_err_msg;
                  x_ret_status := FALSE;
                  RETURN;
                END IF;
              ELSE
                x_cr_account_cd := l_v_account_cd;
                x_err_type := NULL;
                x_err_string := NULL;
                x_ret_status := TRUE;
                RETURN;
              END IF;
            ELSE
              -- In case when the system fee type is other than Tution/Other than
              -- get the rev_account_cd from the FTCI.
              -- No hierarchy will be taken into consideration.
              x_cr_account_cd := l_f_typ_ca_inst_lkp_rec.rev_account_cd;
            END IF;

            -- If the system fee type is External, since the message is already set before
            -- just return from this procedure
            IF x_dr_account_cd IS NULL THEN
              IF l_v_s_fee_type = 'EXTERNAL' THEN
                RETURN;
              END IF;
            ELSE
              IF x_cr_account_cd IS NULL THEN
                x_err_type := 1;
                x_err_string := 'IGS_FI_REV_ACCT_CD_NOT_EXIST';
                x_ret_status := FALSE;
              RETURN;
              END IF; -- x_cr_account_cd check
            END IF; -- x_dr_account_cd Check
          END IF; -- x_cr_account_cd is null check
        END IF; -- g_oracle_rec_installed check
      END IF; -- cur_f_typ_ca_inst_lkp cursor
    ELSE
      -- If Transaction Type is not Credit or Charge Transaction then Raise the error and Exit.
      x_err_string := 'IGS_FI_INVALID_TRANS';
      x_err_type := 1;
      x_ret_status := FALSE;
      RETURN;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','BUILD_ACCOUNTS: '||SQLERRM);
      x_err_type := 1;
      x_ret_status := FALSE;
      RETURN;
  END build_accounts;
END igs_fi_prc_acct_pkg;

/
