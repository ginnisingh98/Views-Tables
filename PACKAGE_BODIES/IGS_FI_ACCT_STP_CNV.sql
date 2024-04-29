--------------------------------------------------------
--  DDL for Package Body IGS_FI_ACCT_STP_CNV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_ACCT_STP_CNV" AS
/* $Header: IGSFI82B.pls 120.4 2006/05/04 23:32:53 sapanigr ship $ */

/*-------------------------------------------------------------------------
Created by  : vvutukur, Oracle IDC
Date created: 23-May-2003

Purpose:

Known limitations/enhancements and/or remarks:

Change History:
Who         When            What
sapanigr   05-May-2006      Bug 5178077: Modified procedure updt_ftci_acct_info to disable process in R12.
svuppala   14-JUL-2005      Enh 3392095 - impact of Tution Waivers build
                            Modified igs_fi_control_pkg.update_row by adding two new columns
                            post_waiver_gl_flag, waiver_notify_finaid_flag
gurprsin    18-Jun-2005    Bug# 3392088 , Modified call to igs_fi_f_typ_ca_inst_pkg.update_row method to include
                           scope_rul_sequence_num and elm_rng_order_name
gurprsin   02-Jun-2005     Enh# 3442712 - Fee Based on Unit Level Attributes
                           Added 4 new columns unit_level,unit_type_id,unit_class,unit_mode in insert_ftci_accounts
                           Modifications to reflect the Addition of 4 new parameters to incorporate Unit Level Attributes.
                           updated call to insert_ftci_accts in updt_ftci_acct_info procedure to pass new parameters with NULL values
svuppala   13-Apr-2005     Bug 4297359 - ER REGISTRATION FEE ISSUE - ASSESSED TO STUDENTS WITH NO LOAD
                           Modifications to reflect the data model changes (NONZERO_BILLABLE_CP_FLAG) in
                           Fee Type Calendar Instances Table
rmaddipa    17-Sep-2004     Enh# 3880438 Modified the procedure update_ftci_rev_acc_cd
jbegum      14-June-2003    Bug# 2998266 Obsoleted the column NEXT_INVOICE_NUMBER.
shtatiko    12-JUN-2003     Enh# 2831582, Modified updt_ftci_acct_info.
-------------------------------------------------------------------*/

  skip EXCEPTION;
  incomplete_setup EXCEPTION;
  success EXCEPTION;

--Cursor to fetch all the fee type calendar instances for account conversion.
  CURSOR cur_ftci IS
    SELECT ca.start_dt,
           ca.end_dt,
           ft.s_fee_type,
           h.name,
           ftci.rowid,
           ftci.*
    FROM   igs_fi_fee_type ft,
           igs_fi_f_typ_ca_inst ftci,
           igs_ca_inst ca,
           igs_fi_hier_accounts h
    WHERE  ft.fee_type = ftci.fee_type
    AND    ftci.fee_cal_type = ca.cal_type
    AND    ftci.fee_ci_sequence_number = ca.sequence_number
    AND    ftci.acct_hier_id = h.acct_hier_id
    ORDER BY ft.fee_type,
             ftci.fee_cal_type,
             ca.start_dt;

  PROCEDURE insert_ftci_accounts(   p_v_fee_type                          IN     VARCHAR2,
                                    p_v_fee_cal_type                      IN     VARCHAR2,
                                    p_n_fee_ci_sequence_number            IN     NUMBER,
                                    p_n_order_sequence                    IN     NUMBER,
                                    p_n_natural_account_segment           IN     VARCHAR2,
                                    p_v_rev_account_cd                    IN     VARCHAR2,
                                    p_v_location_cd                       IN     VARCHAR2,
                                    p_v_attendance_type                   IN     VARCHAR2,
                                    p_v_attendance_mode                   IN     VARCHAR2,
                                    p_v_course_cd                         IN     VARCHAR2,
                                    p_n_crs_version_number                IN     NUMBER,
                                    p_v_unit_cd                           IN     VARCHAR2,
                                    p_n_unit_version_number               IN     NUMBER,
                                    p_v_org_unit_cd                       IN     VARCHAR2,
                                    p_v_residency_status_cd               IN     VARCHAR2,
                                    p_n_uoo_id                            IN     NUMBER,
                                    p_v_unit_level                        IN     VARCHAR2,
                                    p_n_unit_type_id                      IN     NUMBER,
                                    p_v_unit_mode                         IN     VARCHAR2,
                                    p_v_unit_class                        IN     VARCHAR2
                                  ) IS
  /*------------------------------------------------------------------
  Created by  : vvutukur, Oracle IDC
  Date created: 23-May-2003

  Purpose: Inserts record into igs_fi_ftci_accts table using the specified parameters.

  Known limitations/enhancements and/or remarks:

  Change History:
  Who         When            What
  gurprsin    02-Jun-2005     Enh# 3442712, Added 4 new paramters for Unit Level Attributes
  -------------------------------------------------------------------*/
  l_rowid   VARCHAR2(25);
  l_n_acct_id igs_fi_ftci_accts.acct_id%TYPE;

  BEGIN

    l_rowid := NULL;
    l_n_acct_id := NULL;

    igs_fi_ftci_accts_pkg.insert_row (
                                         x_rowid                        => l_rowid,
                                         x_acct_id                      => l_n_acct_id,
                                         x_fee_type                     => p_v_fee_type,
                                         x_fee_cal_type                 => p_v_fee_cal_type,
                                         x_fee_ci_sequence_number       => p_n_fee_ci_sequence_number,
                                         x_order_sequence               => p_n_order_sequence,
                                         x_natural_account_segment      => p_n_natural_account_segment,
                                         x_rev_account_cd               => p_v_rev_account_cd,
                                         x_location_cd                  => p_v_location_cd,
                                         x_attendance_type              => p_v_attendance_type,
                                         x_attendance_mode              => p_v_attendance_mode,
                                         x_course_cd                    => p_v_course_cd,
                                         x_crs_version_number           => p_n_crs_version_number,
                                         x_unit_cd                      => p_v_unit_cd,
                                         x_unit_version_number          => p_n_unit_version_number,
                                         x_org_unit_cd                  => p_v_org_unit_cd,
                                         x_residency_status_cd          => p_v_residency_status_cd,
                                         x_uoo_id                       => p_n_uoo_id,
                                         x_mode                         => 'R',
                                         x_unit_level                   => p_v_unit_level,
                                         x_unit_type_id                 => p_n_unit_type_id,
                                         x_unit_mode                    => p_v_unit_mode,
                                         x_unit_class                   => p_v_unit_class
                                        );
  END insert_ftci_accounts;

  PROCEDURE update_ftci_rev_acc_cd( l_cur_ftci_details  cur_ftci%ROWTYPE,
                                    p_v_rev_account_cd  igs_fi_f_typ_ca_inst.rev_account_cd%TYPE) IS
  /*------------------------------------------------------------------
  Created by  : vvutukur, Oracle IDC
  Date created: 05-Jun-2003

  Purpose: Updates the FTCI record with the specified revenue account code parameter value.

  Known limitations/enhancements and/or remarks:

  Change History:
  Who         When            What
 gurprsin    18-Jun-2005     Bug# 3392088 , Modified call to igs_fi_f_typ_ca_inst_pkg.update_row method to include
                             scope_rul_sequence_num and elm_rng_order_name
 svuppala    13-Apr-2005     Bug 4297359 - ER REGISTRATION FEE ISSUE - ASSESSED TO STUDENTS WITH NO LOAD
                             TBH impact of NONZERO_BILLABLE_CP_FLAG field in Fee Type Calendar Instances Table
 rmaddipa    17-Sep-2004     Added two parameters retention_level_code,complete_ret_flag.
  -------------------------------------------------------------------*/

  BEGIN

    igs_fi_f_typ_ca_inst_pkg.update_row(
                                         x_rowid                     =>  l_cur_ftci_details.rowid,
                                         x_fee_type                  =>  l_cur_ftci_details.fee_type,
                                         x_fee_cal_type              =>  l_cur_ftci_details.fee_cal_type,
                                         x_fee_ci_sequence_number    =>  l_cur_ftci_details.fee_ci_sequence_number,
                                         x_fee_type_ci_status        =>  l_cur_ftci_details.fee_type_ci_status,
                                         x_start_dt_alias            =>  l_cur_ftci_details.start_dt_alias,
                                         x_start_dai_sequence_number =>  l_cur_ftci_details.start_dai_sequence_number,
                                         x_end_dt_alias              =>  l_cur_ftci_details.end_dt_alias,
                                         x_end_dai_sequence_number   =>  l_cur_ftci_details.end_dai_sequence_number,
                                         x_retro_dt_alias            =>  l_cur_ftci_details.retro_dt_alias,
                                         x_retro_dai_sequence_number =>  l_cur_ftci_details.retro_dai_sequence_number,
                                         x_s_chg_method_type         =>  l_cur_ftci_details.s_chg_method_type,
                                         x_rul_sequence_number       =>  l_cur_ftci_details.rul_sequence_number,
                                         x_mode                      =>  'R',
                                         x_initial_default_amount    =>  l_cur_ftci_details.initial_default_amount,
                                         x_acct_hier_id              =>  l_cur_ftci_details.acct_hier_id,
                                         x_rec_gl_ccid               =>  l_cur_ftci_details.rec_gl_ccid,
                                         x_rev_account_cd            =>  p_v_rev_account_cd,
                                         x_rec_account_cd            =>  l_cur_ftci_details.rec_account_cd,
                                         x_ret_gl_ccid               =>  l_cur_ftci_details.ret_gl_ccid,
                                         x_ret_account_cd            =>  l_cur_ftci_details.ret_account_cd,
                                         x_retention_level_code      =>  l_cur_ftci_details.retention_level_code,
                                         x_complete_ret_flag         =>  l_cur_ftci_details.complete_ret_flag,
                                         x_nonzero_billable_cp_flag  =>  l_cur_ftci_details.nonzero_billable_cp_flag,
                                         x_scope_rul_sequence_num    =>  l_cur_ftci_details.scope_rul_sequence_num,
                                         x_elm_rng_order_name        =>  l_cur_ftci_details.elm_rng_order_name
                                        );
  END update_ftci_rev_acc_cd;

  PROCEDURE updt_ftci_acct_info( errbuf    OUT NOCOPY VARCHAR2,
                                 retcode   OUT NOCOPY NUMBER
                                ) IS
  /*------------------------------------------------------------------
  Created by  : vvutukur, Oracle IDC
  Date created: 23-May-2003

  Purpose: Converts Existing Accounting Setup Details.

  Known limitations/enhancements and/or remarks:

  Change History:
  Who         When            What
  sapanigr   05-May-2006      Bug 5178077: Added call to igs_ge_gen_003.set_org_id. to disable process in R12
  svuppala   14-JUL-2005      Enh 3392095 - impact of Tution Waivers build
                              Modified igs_fi_control_pkg.update_row by adding two new columns
                              post_waiver_gl_flag, waiver_notify_finaid_flag
  gurprsin    02-Jun-2005     Enh#3442712, Modified calls to igs_fi_accts_pkg.get_uk2_for_validation by adding 4 new unit level parameters
                              insert_ftci_accounts and updt_ftci_acct_info method
  pmarada    19-Nov-2004      Bug 4017841, Removed the obsoleted res_dt_alias column reference from igs_fi_control table update row
  uudayapr   23-dec-2003      Enh#3167098 Removed Column Name PRG_CHG_DT_ALIAS and added RES_DT_ALIAS in
                                           igs_fi_control_pkg.update_row
  shtatiko   12-JUN-2003      Enh# 2831582, Removed Obsoleted columns from igs_fi_control_pkg.update_row
  -------------------------------------------------------------------*/

  CURSOR cur_ctrl IS
    SELECT fc.rowid, fc.*
    FROM   igs_fi_control_all fc;

  l_cur_ctrl  cur_ctrl%ROWTYPE;

  CURSOR cur_chk_acct_rec_exists(cp_v_fee_type        igs_fi_fee_type.fee_type%TYPE,
                                 cp_v_fee_cal_type    igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                                 cp_n_seq_number      igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE
                                 )IS
    SELECT 'x'
    FROM   igs_fi_ftci_accts
    WHERE  fee_type = cp_v_fee_type
    AND    fee_cal_type = cp_v_fee_cal_type
    AND    fee_ci_sequence_number = cp_n_seq_number;

    l_v_var    VARCHAR2(1);
    l_n_seq    igs_fi_ftci_accts.order_sequence%TYPE;

  CURSOR cur_hier(cp_n_acct_hier_id igs_fi_hier_acct_tbl.acct_hier_id%TYPE) IS
    SELECT entity_type_code
    FROM   igs_fi_hier_acct_tbl
    WHERE  acct_hier_id = cp_n_acct_hier_id
    ORDER BY order_sequence;

  CURSOR cur_prg_rev_cd IS
    SELECT course_cd, version_number, rev_account_cd
    FROM   igs_ps_ver
    WHERE  rev_account_cd IS NOT NULL
    ORDER BY course_cd, version_number;

  CURSOR cur_unit_rev_cd IS
    SELECT unit_cd, version_number, rev_account_cd
    FROM   igs_ps_unit_ver
    WHERE  rev_account_cd IS NOT NULL
    ORDER BY unit_cd, version_number;

  CURSOR cur_uoo_rev_cd IS
    SELECT uoo_id, rev_account_cd
    FROM   igs_ps_unit_ofr_opt
    WHERE  rev_account_cd IS NOT NULL
    ORDER BY unit_cd, version_number, cal_type, ci_sequence_number, location_cd, unit_class;

  CURSOR cur_loc_rev_cd IS
    SELECT location_cd, rev_account_cd
    FROM   igs_ad_location
    WHERE  rev_account_cd IS NOT NULL
    ORDER BY location_cd;

  CURSOR cur_org_rev_cd IS
    SELECT org_unit_cd, rev_account_cd
    FROM   igs_or_unit_acct_cd
    WHERE  rev_account_cd IS NOT NULL
    ORDER BY org_unit_cd;

  CURSOR cur_hier_oth(cp_acct_hier_id NUMBER) IS
    SELECT entity_type_code
    FROM   igs_fi_hier_acct_tbl
    WHERE  acct_hier_id = cp_acct_hier_id
    AND    entity_type_code IN ('FTCI','SA')
    ORDER BY order_sequence;

  CURSOR cur_hier_oth_count(cp_acct_hier_id NUMBER) IS
    SELECT COUNT(entity_type_code)
    FROM   igs_fi_hier_acct_tbl
    WHERE  acct_hier_id = cp_acct_hier_id
    AND    entity_type_code IN ('FTCI','SA');

  l_v_fee_type         igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_TYPE');
  l_v_fee_period       igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_PERIOD');
  l_v_acct_hierarchy   igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','ACCT_HIERARCHY');
  l_v_message_text     igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','MESSAGE_TEXT');

  l_v_rev_account_cd   igs_fi_f_typ_ca_inst.rev_account_cd%TYPE;
  l_v_entity_code      igs_fi_hier_acct_tbl.entity_type_code%TYPE;

  --For Program.
  TYPE prg_rec_type IS RECORD (
    course_cd         igs_ps_ver.course_cd%TYPE,
    version_number    igs_ps_ver.version_number%TYPE,
    rev_account_cd    igs_ps_ver.rev_account_cd%TYPE);

  TYPE prg_tbl_type IS TABLE OF prg_rec_type INDEX BY BINARY_INTEGER;
  prg_tbl prg_tbl_type;


  --For Unit.
  TYPE unit_rec_type IS RECORD (
    unit_cd         igs_ps_unit_ver.unit_cd%TYPE,
    version_number  igs_ps_unit_ver.version_number%TYPE,
    rev_account_cd  igs_ps_unit_ver.rev_account_cd%TYPE);

  TYPE unit_tbl_type IS TABLE OF unit_rec_type INDEX BY BINARY_INTEGER;
  unit_tbl unit_tbl_type;


  --For Unit Section.
  TYPE usec_rec_type IS RECORD (
    uoo_id          igs_ps_unit_ofr_opt.uoo_id%TYPE,
    rev_account_cd  igs_ps_unit_ofr_opt.rev_account_cd%TYPE);

  TYPE usec_tbl_type IS TABLE OF usec_rec_type INDEX BY BINARY_INTEGER;
  usec_tbl usec_tbl_type;


  --For Location.
  TYPE loc_rec_type IS RECORD (
    location_cd     igs_ad_location.location_cd%TYPE,
    rev_account_cd  igs_ad_location.rev_account_cd%TYPE);

  TYPE loc_tbl_type IS TABLE OF loc_rec_type INDEX BY BINARY_INTEGER;
  loc_tbl loc_tbl_type;


  --For Organization Unit Code.
  TYPE org_rec_type IS RECORD (
    org_unit_cd     igs_or_unit_acct_cd.org_unit_cd%TYPE,
    rev_account_cd  igs_or_unit_acct_cd.rev_account_cd%TYPE);

  TYPE org_tbl_type IS TABLE OF org_rec_type INDEX BY BINARY_INTEGER;
  org_tbl org_tbl_type;

  i  PLS_INTEGER;
  l_n_no_of_hier_entities NUMBER := 0;

  l_org_id VARCHAR2(15);

  BEGIN

     BEGIN
          l_org_id := NULL;
          igs_ge_gen_003.set_org_id(l_org_id);
       EXCEPTION
         WHEN OTHERS THEN
            fnd_file.put_line (fnd_file.log, fnd_message.get);
            RETCODE:=2;
            RETURN;
     END;

    --For Operating Student Finance module, user needs to setup the details in the System Options form.
    --Check the set up done in System Options form.
    OPEN cur_ctrl;
    FETCH cur_ctrl INTO l_cur_ctrl;
    --If no set up is done in System Options Form, message is logged in the log file and process completes with warning.
    IF cur_ctrl%NOTFOUND THEN
      CLOSE cur_ctrl;
      fnd_message.set_name('IGS','IGS_FI_ACCT_CNV_PRC_NOT_REQ');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      retcode := 1;
      RETURN;
    ELSE--if record exists in igs_fi_control table...
      CLOSE cur_ctrl;

      --This process is intended to execute only when Oracle General Ledger is not installed in the system.
      --Check if Oracle General Ledger is installed..
      IF l_cur_ctrl.rec_installed = 'Y' THEN
        --If yes, then log the error message in the logfile and the process completes with error.
        fnd_message.set_name('IGS','IGS_FI_ACCT_CNV_PRC_NOT_VALID');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        retcode := 2;
        RETURN;
      END IF;

      --This process is intended to for onetime usage only. Check if the value of acct_conv_flag in igs_fi_control_all is null.
      --If this value is not null, then message is logged in the log file and process completes with warning.
      IF l_cur_ctrl.acct_conv_flag IS NOT NULL THEN
        fnd_message.set_name('IGS','IGS_FI_ACCT_CNV_PRC_NOT_REQ');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        retcode := 1;
        RETURN;
      END IF;
    END IF;

    i := 1;
    --Capture the program details in table type variable.
    FOR l_cur_prg_rev_cd IN cur_prg_rev_cd LOOP
      prg_tbl(i).course_cd       := l_cur_prg_rev_cd.course_cd;
      prg_tbl(i).version_number  := l_cur_prg_rev_cd.version_number;
      prg_tbl(i).rev_account_cd  := l_cur_prg_rev_cd.rev_account_cd;
      i := i + 1;
    END LOOP;

    i := 1;
    --Capture the unit details in table type variable.
    FOR l_cur_unit_rev_cd IN cur_unit_rev_cd LOOP
      unit_tbl(i).unit_cd         := l_cur_unit_rev_cd.unit_cd;
      unit_tbl(i).version_number  := l_cur_unit_rev_cd.version_number;
      unit_tbl(i).rev_account_cd  := l_cur_unit_rev_cd.rev_account_cd;
      i := i + 1;
    END LOOP;

    i := 1;
    --Capture the unit section details in table type variable.
    FOR l_cur_uoo_rev_cd IN cur_uoo_rev_cd LOOP
      usec_tbl(i).uoo_id          := l_cur_uoo_rev_cd.uoo_id;
      usec_tbl(i).rev_account_cd  := l_cur_uoo_rev_cd.rev_account_cd;
      i := i + 1;
    END LOOP;

    i := 1;
    --Capture the location details in table type variable.
    FOR l_cur_loc_rev_cd IN cur_loc_rev_cd LOOP
      loc_tbl(i).location_cd      := l_cur_loc_rev_cd.location_cd;
      loc_tbl(i).rev_account_cd   := l_cur_loc_rev_cd.rev_account_cd;
      i := i + 1;
    END LOOP;

    i := 1;
    --Capture the organization unit code details in table type variable.
    FOR l_cur_org_rev_cd IN cur_org_rev_cd LOOP
      org_tbl(i).org_unit_cd      := l_cur_org_rev_cd.org_unit_cd;
      org_tbl(i).rev_account_cd   := l_cur_org_rev_cd.rev_account_cd;
      i := i + 1;
    END LOOP;


    --Loop through each FTCI record.
    FOR l_cur_ftci IN cur_ftci LOOP
      --log FTCI details in the log file.
      fnd_file.put_line(fnd_file.log,RPAD('-',77,'-'));
      fnd_file.put_line(fnd_file.log,'');
      fnd_file.put_line(fnd_file.log,l_v_fee_type||RPAD(' ',10,' ')||': '||l_cur_ftci.fee_type);
      fnd_file.put_line(fnd_file.log,l_v_fee_period||RPAD(' ',8,' ')||': '||l_cur_ftci.fee_cal_type||' '||l_cur_ftci.start_dt||' - '||l_cur_ftci.end_dt);
      fnd_file.put_line(fnd_file.log,l_v_acct_hierarchy||RPAD(' ',1,' ')||': '||l_cur_ftci.name);

      BEGIN

        --If the System Fee Type of the context FTCI is either Tuition or Other.
        IF l_cur_ftci.s_fee_type IN ('TUTNFEE','OTHER') THEN
          --Check if a record is present in the accounts table for the context FTCI combination.
          OPEN cur_chk_acct_rec_exists(l_cur_ftci.fee_type,
                                       l_cur_ftci.fee_cal_type,
                                       l_cur_ftci.fee_ci_sequence_number);
          FETCH cur_chk_acct_rec_exists INTO l_v_var;

          --For a Fee Type Calendar Instance in context, if the user has already defined the Accounting details in the Account Table,
          --(igs_fi_ftci_accts), log the error message in the log file, skip the current FTCI record and process the next one.
          IF cur_chk_acct_rec_exists%FOUND THEN
            CLOSE cur_chk_acct_rec_exists;
            fnd_message.set_name('IGS','IGS_FI_FTCI_ACCT_REC_EXISTS');
            fnd_file.put_line(fnd_file.log,l_v_message_text||RPAD(' ',6,' ')||': '||fnd_message.get);
            RAISE skip;
          END IF;
          CLOSE cur_chk_acct_rec_exists;

          l_n_seq := 0;

          --Get the accounting hierarchy order for the account hierarchy attached to the Fee Type Calendar Instance.
          FOR l_cur_hier IN cur_hier(l_cur_ftci.acct_hier_id) LOOP

            --If the hierarchy entity is either System Options or Fee Type.
            IF l_cur_hier.entity_type_code IN ('FTCI','SA') THEN

              --Check there is no record in the accounts table with the context FTCI details and other attributes as NULL.
              --Added 4 new paramters for Unit Level Attributes
              IF NOT igs_fi_ftci_accts_pkg.get_uk2_for_validation( x_fee_type                => l_cur_ftci.fee_type,
                                                                   x_fee_cal_type            => l_cur_ftci.fee_cal_type,
                                                                   x_fee_ci_sequence_number  => l_cur_ftci.fee_ci_sequence_number,
                                                                   x_location_cd             => NULL,
                                                                   x_attendance_type         => NULL,
                                                                   x_attendance_mode         => NULL,
                                                                   x_course_cd               => NULL,
                                                                   x_crs_version_number      => NULL,
                                                                   x_unit_cd                 => NULL,
                                                                   x_unit_version_number     => NULL,
                                                                   x_org_unit_cd             => NULL,
                                                                   x_residency_status_cd     => NULL,
                                                                   x_uoo_id                  => NULL,
                                                                   x_unit_level              => NULL,
                                                                   x_unit_type_id            => NULL,
                                                                   x_unit_mode               => NULL,
                                                                   x_unit_class              => NULL
                                                                  ) THEN

                --Get the revenue account code that is set up at context entity type.(either FTCI or SA).
                IF l_cur_hier.entity_type_code = 'FTCI' THEN
                  l_v_rev_account_cd := l_cur_ftci.rev_account_cd;
                ELSE
                  l_v_rev_account_cd := l_cur_ctrl.rev_account_cd;
                END IF;

                IF l_v_rev_account_cd IS NOT NULL THEN

                  --Increment the order sequence as this is part of unique key.
                  l_n_seq := l_n_seq + 1;

                  --Insert a record in igs_fi_ftci_accts table.
                  --Added 4 new paramters for Unit Level Attributes
                  insert_ftci_accounts(p_v_fee_type                  =>  l_cur_ftci.fee_type,
                                       p_v_fee_cal_type              =>  l_cur_ftci.fee_cal_type,
                                       p_n_fee_ci_sequence_number    =>  l_cur_ftci.fee_ci_sequence_number,
                                       p_n_order_sequence            =>  l_n_seq,
                                       p_n_natural_account_segment   =>  NULL,
                                       p_v_rev_account_cd            =>  l_v_rev_account_cd,
                                       p_v_location_cd               =>  NULL,
                                       p_v_attendance_type           =>  NULL,
                                       p_v_attendance_mode           =>  NULL,
                                       p_v_course_cd                 =>  NULL,
                                       p_n_crs_version_number        =>  NULL,
                                       p_v_unit_cd                   =>  NULL,
                                       p_n_unit_version_number       =>  NULL,
                                       p_v_org_unit_cd               =>  NULL,
                                       p_v_residency_status_cd       =>  NULL,
                                       p_n_uoo_id                    =>  NULL,
                                       p_v_unit_level                =>  NULL,
                                       p_n_unit_type_id              =>  NULL,
                                       p_v_unit_mode                 =>  NULL,
                                       p_v_unit_class                =>  NULL);
                END IF;
              END IF;
            ELSIF l_cur_hier.entity_type_code = 'PS' THEN
              IF prg_tbl.COUNT > 0 THEN
                FOR i IN prg_tbl.FIRST .. prg_tbl.LAST LOOP
                  IF prg_tbl.EXISTS(i) THEN
                    --Increment the order sequence as this is part of unique key.
                    l_n_seq := l_n_seq + 1;
                  --Insert a record in igs_fi_ftci_accts table with corresponding program details.
                  --Added 4 new paramters for Unit Level Attributes
                    insert_ftci_accounts(p_v_fee_type                  =>  l_cur_ftci.fee_type,
                                         p_v_fee_cal_type              =>  l_cur_ftci.fee_cal_type,
                                         p_n_fee_ci_sequence_number    =>  l_cur_ftci.fee_ci_sequence_number,
                                         p_n_order_sequence            =>  l_n_seq,
                                         p_n_natural_account_segment   =>  NULL,
                                         p_v_rev_account_cd            =>  prg_tbl(i).rev_account_cd,
                                         p_v_location_cd               =>  NULL,
                                         p_v_attendance_type           =>  NULL,
                                         p_v_attendance_mode           =>  NULL,
                                         p_v_course_cd                 =>  prg_tbl(i).course_cd,
                                         p_n_crs_version_number        =>  prg_tbl(i).version_number,
                                         p_v_unit_cd                   =>  NULL,
                                         p_n_unit_version_number       =>  NULL,
                                         p_v_org_unit_cd               =>  NULL,
                                         p_v_residency_status_cd       =>  NULL,
                                         p_n_uoo_id                    =>  NULL,
                                         p_v_unit_level                =>  NULL,
                                         p_n_unit_type_id              =>  NULL,
                                         p_v_unit_mode                 =>  NULL,
                                         p_v_unit_class                =>  NULL);
                  END IF;
                END LOOP;
              END IF;
            ELSIF l_cur_hier.entity_type_code = 'UNIT' THEN
              IF unit_tbl.COUNT > 0 THEN
                FOR i IN unit_tbl.FIRST .. unit_tbl.LAST LOOP
                  IF unit_tbl.EXISTS(i) THEN

                    --Increment the order sequence as this is part of unique key.
                    l_n_seq := l_n_seq + 1;

                    --Insert a record in igs_fi_ftci_accts table with corresponding unit details.
                    --Added 4 new paramters for Unit Level Attributes
                    insert_ftci_accounts(p_v_fee_type                  =>  l_cur_ftci.fee_type,
                                         p_v_fee_cal_type              =>  l_cur_ftci.fee_cal_type,
                                         p_n_fee_ci_sequence_number    =>  l_cur_ftci.fee_ci_sequence_number,
                                         p_n_order_sequence            =>  l_n_seq,
                                         p_n_natural_account_segment   =>  NULL,
                                         p_v_rev_account_cd            =>  unit_tbl(i).rev_account_cd,
                                         p_v_location_cd               =>  NULL,
                                         p_v_attendance_type           =>  NULL,
                                         p_v_attendance_mode           =>  NULL,
                                         p_v_course_cd                 =>  NULL,
                                         p_n_crs_version_number        =>  NULL,
                                         p_v_unit_cd                   =>  unit_tbl(i).unit_cd,
                                         p_n_unit_version_number       =>  unit_tbl(i).version_number,
                                         p_v_org_unit_cd               =>  NULL,
                                         p_v_residency_status_cd       =>  NULL,
                                         p_n_uoo_id                    =>  NULL,
                                         p_v_unit_level                =>  NULL,
                                         p_n_unit_type_id              =>  NULL,
                                         p_v_unit_mode                 =>  NULL,
                                         p_v_unit_class                =>  NULL);
                  END IF;
                END LOOP;
              END IF;
            ELSIF l_cur_hier.entity_type_code = 'USEC' THEN
              IF usec_tbl.COUNT > 0 THEN
                FOR i IN usec_tbl.FIRST .. usec_tbl.LAST LOOP
                  IF usec_tbl.EXISTS(i) THEN
                    l_n_seq := l_n_seq + 1;

                    --Insert a record in igs_fi_ftci_accts table with corresponding unit section details.
                    --Added 4 new paramters for Unit Level Attributes
                    insert_ftci_accounts(p_v_fee_type                  =>  l_cur_ftci.fee_type,
                                         p_v_fee_cal_type              =>  l_cur_ftci.fee_cal_type,
                                         p_n_fee_ci_sequence_number    =>  l_cur_ftci.fee_ci_sequence_number,
                                         p_n_order_sequence            =>  l_n_seq,
                                         p_n_natural_account_segment   =>  NULL,
                                         p_v_rev_account_cd            =>  usec_tbl(i).rev_account_cd,
                                         p_v_location_cd               =>  NULL,
                                         p_v_attendance_type           =>  NULL,
                                         p_v_attendance_mode           =>  NULL,
                                         p_v_course_cd                 =>  NULL,
                                         p_n_crs_version_number        =>  NULL,
                                         p_v_unit_cd                   =>  NULL,
                                         p_n_unit_version_number       =>  NULL,
                                         p_v_org_unit_cd               =>  NULL,
                                         p_v_residency_status_cd       =>  NULL,
                                         p_n_uoo_id                    =>  usec_tbl(i).uoo_id,
                                         p_v_unit_level                =>  NULL,
                                         p_n_unit_type_id              =>  NULL,
                                         p_v_unit_mode                 =>  NULL,
                                         p_v_unit_class                =>  NULL);
                  END IF;
                END LOOP;
              END IF;
            ELSIF l_cur_hier.entity_type_code = 'LOC' THEN
              IF loc_tbl.COUNT > 0 THEN
                FOR i IN loc_tbl.FIRST .. loc_tbl.LAST LOOP
                  IF loc_tbl.EXISTS(i) THEN

                    --Increment the order sequence as this is part of unique key.
                    l_n_seq := l_n_seq + 1;

                    --Insert a record in igs_fi_ftci_accts table with corresponding location details.
                    --Added 4 new paramters for Unit Level Attributes
                    insert_ftci_accounts(p_v_fee_type                  =>  l_cur_ftci.fee_type,
                                         p_v_fee_cal_type              =>  l_cur_ftci.fee_cal_type,
                                         p_n_fee_ci_sequence_number    =>  l_cur_ftci.fee_ci_sequence_number,
                                         p_n_order_sequence            =>  l_n_seq,
                                         p_n_natural_account_segment   =>  NULL,
                                         p_v_rev_account_cd            =>  loc_tbl(i).rev_account_cd,
                                         p_v_location_cd               =>  loc_tbl(i).location_cd,
                                         p_v_attendance_type           =>  NULL,
                                         p_v_attendance_mode           =>  NULL,
                                         p_v_course_cd                 =>  NULL,
                                         p_n_crs_version_number        =>  NULL,
                                         p_v_unit_cd                   =>  NULL,
                                         p_n_unit_version_number       =>  NULL,
                                         p_v_org_unit_cd               =>  NULL,
                                         p_v_residency_status_cd       =>  NULL,
                                         p_n_uoo_id                    =>  NULL,
                                         p_v_unit_level                =>  NULL,
                                         p_n_unit_type_id              =>  NULL,
                                         p_v_unit_mode                 =>  NULL,
                                         p_v_unit_class                =>  NULL);
                  END IF;
                END LOOP;
              END IF;
            ELSIF l_cur_hier.entity_type_code = 'ORG' THEN
              IF org_tbl.COUNT > 0 THEN
                FOR i IN org_tbl.FIRST .. org_tbl.LAST LOOP
                  IF org_tbl.EXISTS(i) THEN

                    --Increment the order sequence as this is part of unique key.
                    l_n_seq := l_n_seq + 1;

                    --Insert a record in igs_fi_ftci_accts table with corresponding org unit code details.
                    --Added 4 new paramters for Unit Level Attributes
                    insert_ftci_accounts(p_v_fee_type                  =>  l_cur_ftci.fee_type,
                                         p_v_fee_cal_type              =>  l_cur_ftci.fee_cal_type,
                                         p_n_fee_ci_sequence_number    =>  l_cur_ftci.fee_ci_sequence_number,
                                         p_n_order_sequence            =>  l_n_seq,
                                         p_n_natural_account_segment   =>  NULL,
                                         p_v_rev_account_cd            =>  org_tbl(i).rev_account_cd,
                                         p_v_location_cd               =>  NULL,
                                         p_v_attendance_type           =>  NULL,
                                         p_v_attendance_mode           =>  NULL,
                                         p_v_course_cd                 =>  NULL,
                                         p_n_crs_version_number        =>  NULL,
                                         p_v_unit_cd                   =>  NULL,
                                         p_n_unit_version_number       =>  NULL,
                                         p_v_org_unit_cd               =>  org_tbl(i).org_unit_cd,
                                         p_v_residency_status_cd       =>  NULL,
                                         p_n_uoo_id                    =>  NULL,
                                         p_v_unit_level                =>  NULL,
                                         p_n_unit_type_id              =>  NULL,
                                         p_v_unit_mode                 =>  NULL,
                                         p_v_unit_class                =>  NULL);
                  END IF;
                END LOOP;
              END IF;
            END IF;
          END LOOP;--cur_hier loop.

          --If the user has not set up the Revenue Account Code anywhere...
          IF l_n_seq = 0 THEN
            RAISE incomplete_setup;
          ELSE
            RAISE success;
          END IF;

        ELSE--If system fee type is not in either TUTNFEE or OTHER.

          --Check how many hierarchy order entities are defined in the hierarchy order form.
          OPEN cur_hier_oth_count(l_cur_ftci.acct_hier_id);
          FETCH cur_hier_oth_count INTO l_n_no_of_hier_entities;
          CLOSE cur_hier_oth_count;

          --If no hierarchy order ntities are defined for the account hierarchy, which is attached to the context FTCI.
          IF l_n_no_of_hier_entities = 0 THEN
            --log the incomplete account set up information message in the log file.
            RAISE incomplete_setup;
          ELSE--if atleast one hierarchy order entity is specified..

            --Capture the first hierarchy order entity.
            OPEN cur_hier_oth(l_cur_ftci.acct_hier_id);
            FETCH cur_hier_oth INTO l_v_entity_code;
            CLOSE cur_hier_oth;
            --If the only one hierarchy order entity is specified in hierarchy order form..
            IF l_n_no_of_hier_entities = 1 THEN
              --If System Options is the one and only hierarchy order specified in hierarchy order form.
              IF l_v_entity_code = 'SA' THEN
                --Override the revenue account code at FTCI with the revenue account code that is present in System Options Level.
                --Here irrespective of the values present at both the levels, the value will be overridden.
                update_ftci_rev_acc_cd(l_cur_ftci,l_cur_ctrl.rev_account_cd);

                --After the above update happens, if the revenue account code is NULL both at System Options Level and FTCI level.
                --show the incomplete account set up message to the user.
                IF l_cur_ctrl.rev_account_cd IS NULL THEN
                  RAISE incomplete_setup;
                END IF;
              ELSE
                --If FTCI is the one and only hierarchy order specified in hierarchy order form, we do not need to do anything for conversion.
                --But if revenue account code is not set up at both levels, incomplete set up message should be logged.
                IF l_cur_ftci.rev_account_cd IS NULL THEN
                  RAISE incomplete_setup;
                END IF;
              END IF;
            --If both Fee Type and System Option hierarchy orders are specified in the hierarchy order form.
            ELSIF l_n_no_of_hier_entities = 2 THEN
              --Check if the first in the order of sequence is Fee Type.
              IF l_v_entity_code = 'FTCI' THEN
                --
                IF l_cur_ftci.rev_account_cd IS NULL THEN
                  IF l_cur_ctrl.rev_account_cd IS NOT NULL THEN
                    update_ftci_rev_acc_cd(l_cur_ftci,l_cur_ctrl.rev_account_cd);
                  ELSE
                    RAISE incomplete_setup;
                  END IF;
                END IF;
              --Check if the first in the order of sequence is Fee Type.
              ELSIF l_v_entity_code = 'SA' THEN
                --Check if a value is present for the revenue account code at System level.
                IF l_cur_ctrl.rev_account_cd IS NOT NULL THEN
                  --the context FTCI record's revenue account code will be overridden with the revenue account code at system level,
                  --if revenue account code at system level is having some value.
                  update_ftci_rev_acc_cd(l_cur_ftci,l_cur_ctrl.rev_account_cd);
                ELSE
                  --If revenue account code is not specified either at system level or at FTCI level..
                  IF l_cur_ftci.rev_account_cd IS NULL THEN
                    --then log the incomplete account set up message.
                    RAISE incomplete_setup;
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;

        END IF;--System Fee Type.

        --log successful account conversion message for the FTCI record after all the above steps are passed.
        RAISE success;

      EXCEPTION
        WHEN incomplete_setup THEN
          --log the information message that the accounting setup is incomplete for the context FTCI.
          fnd_message.set_name('IGS','IGS_FI_ACCT_INCOMPLETE_SETUP');
          fnd_file.put_line(fnd_file.log,l_v_message_text||RPAD(' ',6,' ')||': '||fnd_message.get);
          retcode := 1;
        WHEN success THEN
          --log the information message that the accounting setup is completed.
          fnd_message.set_name('IGS','IGS_FI_ACCT_CNV_PRC_SUCCESS');
          fnd_file.put_line(fnd_file.log,l_v_message_text||RPAD(' ',6,' ')||': '||fnd_message.get);
        WHEN skip THEN
          NULL;
      END;

      -- Committing after each and every FTCI record.
      COMMIT;

    END LOOP;--FTCI loop

    fnd_file.put_line(fnd_file.log,RPAD('-',77,'-'));


    --After accounting conversion is completed, update the Account Conversion Flag to Y.

    --Update acct_conv_flag column only with value 'Y', of igs_fi_control table.
    -- Removed lockbox_context, lockbox_number_attribute and ar_int_org_id columns from the following call
    -- as part of Enh# 2831582, Lockbox.
    -- Bug#2998266 Removed the column next_invoice_number from call to igs_fi_control_pkg.update_row
    -- Enh 3392095 added two new columns post_waiver_gl_flag, waiver_notify_finaid_flag
    igs_fi_control_pkg.update_row(x_rowid                      => l_cur_ctrl.rowid,
                                  x_rec_installed              => l_cur_ctrl.rec_installed,
                                  x_accounting_method          => l_cur_ctrl.accounting_method,
                                  x_set_of_books_id            => l_cur_ctrl.set_of_books_id,
                                  x_refund_dr_gl_ccid          => l_cur_ctrl.refund_dr_gl_ccid,
                                  x_refund_cr_gl_ccid          => l_cur_ctrl.refund_cr_gl_ccid,
                                  x_refund_dr_account_cd       => l_cur_ctrl.refund_dr_account_cd,
                                  x_refund_cr_account_cd       => l_cur_ctrl.refund_cr_account_cd,
                                  x_refund_dt_alias            => l_cur_ctrl.refund_dt_alias,
                                  x_fee_calc_mthd_code         => l_cur_ctrl.fee_calc_mthd_code,
                                  x_planned_credits_ind        => l_cur_ctrl.planned_credits_ind,
                                  x_rec_gl_ccid                => l_cur_ctrl.rec_gl_ccid,
                                  x_cash_gl_ccid               => l_cur_ctrl.cash_gl_ccid,
                                  x_unapp_gl_ccid              => l_cur_ctrl.unapp_gl_ccid,
                                  x_rec_account_cd             => l_cur_ctrl.rec_account_cd,
                                  x_rev_account_cd             => l_cur_ctrl.rev_account_cd,
                                  x_cash_account_cd            => l_cur_ctrl.cash_account_cd,
                                  x_unapp_account_cd           => l_cur_ctrl.unapp_account_cd,
                                  x_conv_process_run_ind       => l_cur_ctrl.conv_process_run_ind,
                                  x_currency_cd                => l_cur_ctrl.currency_cd,
                                  x_rfnd_destination           => l_cur_ctrl.rfnd_destination,
                                  x_ap_org_id                  => l_cur_ctrl.ap_org_id,
                                  x_dflt_supplier_site_name    => l_cur_ctrl.dflt_supplier_site_name,
                                  x_manage_accounts            => l_cur_ctrl.manage_accounts,
                                  x_acct_conv_flag             => 'Y',
                                  x_post_waiver_gl_flag        => l_cur_ctrl.post_waiver_gl_flag,
                                  x_waiver_notify_finaid_flag  => l_cur_ctrl.waiver_notify_finaid_flag
                                  );
    -- Issuing commit here to update the account conversion flag to 'Y' even if the process completes with warning.
    -- Issued explicit commit as the concurrent manager does not commit when the process completes with warning.
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      retcode := 2;
      errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION')||SQLERRM;
      igs_ge_msg_stack.conc_exception_hndl;

  END updt_ftci_acct_info;

END igs_fi_acct_stp_cnv;

/
