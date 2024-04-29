--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_ACCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_ACCT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSFI60S.pls 120.2 2005/07/27 08:50:40 appldev ship $ */

  /*******************************************************************************
  Created by   : rbezawad
  Date created : 19-Jul-2001
  Purpose      : This procedure generates debit and credit account pairs for
                 Charge and Credit Transactions.

  Known limitations/enhancements/remarks:

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  gurprsin        27-Jul-2005     Bug# 3392095 Tuition Waiver build, Added Waiver_Name in build_accounts procedure.
  bannamal        03-JUN-2005     Bug#3442712 Unit Level Fee Assessment Build
                                  Added new parameters unit_type_id, unit_class,
                                  unit_mode, unit_level in procedure build_accounts.
  vchappid        19-May-2003     Build Bug# 2831572, Financial Accounting Enhancements
                                  Added Attendance Type, Attendance Mode and Residency Status parameters
  agairola        17-May-2002     For bug fix 2323555, modified the Build Account
                                  procedure - made the account codes as IN OUT NOCOPY

  *******************************************************************************/
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
    p_v_attendance_type IN VARCHAR2 DEFAULT NULL,
    p_v_attendance_mode IN VARCHAR2 DEFAULT NULL,
    p_v_residency_status_cd IN VARCHAR2 DEFAULT NULL,
    p_n_unit_type_id  IN NUMBER DEFAULT NULL,
    p_v_unit_class IN VARCHAR2 DEFAULT NULL,
    p_v_unit_mode IN VARCHAR2 DEFAULT NULL,
    p_v_unit_level IN VARCHAR2  DEFAULT NULL,
    p_v_waiver_name IN VARCHAR2 DEFAULT NULL
  );

END igs_fi_prc_acct_pkg;

 

/
