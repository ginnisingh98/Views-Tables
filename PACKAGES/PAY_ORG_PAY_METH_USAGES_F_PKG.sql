--------------------------------------------------------
--  DDL for Package PAY_ORG_PAY_METH_USAGES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ORG_PAY_METH_USAGES_F_PKG" AUTHID CURRENT_USER as
/* $Header: pyopu01t.pkh 120.0.12010000.1 2008/07/27 23:18:46 appldev ship $ */
--
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_org_pay_meth_usages_f_pkg
  Purpose
    Supports the OPU block in the form PAYWSDPG (Define Payroll).
  Notes

  History
    16-Dec-02  D.E.Saxby   115.1        Bug 2692195 - nocopy changes.
    31-Jan-95  J.S.Hobbs   40.4         Removed aol WHO columns.
    11-Mar-94  J.S.Hobbs   40.0         Date created.
 ============================================================================*/
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   opmu_end_date                                                         --
 -- Purpose                                                                 --
 --   Returns the date effective end date of an OPMU that is about to be    --
 --   created. This takes into account future opmu's and also the end date  --
 --   of the opm.                                                           --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 function opmu_end_date
 (
  p_org_pay_method_usage_id number,
  p_payroll_id              number,
  p_org_payment_method_id   number,
  p_session_date            date,
  p_validation_start_date   date
 ) return date;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   validate_delete_opmu                                                  --
 -- Purpose                                                                 --
 --   Checks to see if it is valid to delete the opmu.                      --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 procedure validate_delete_opmu
 (
  p_payroll_id              number,
  p_org_payment_method_id   number,
  p_effective_start_date    date,
  p_effective_end_date      date,
  p_dt_delete_mode          varchar2,
  p_validation_start_date   date,
  p_validation_end_date     date
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of an OPMU via the   --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                      X_Org_Pay_Method_Usage_Id      IN OUT NOCOPY NUMBER,
                      X_Effective_Start_Date                       DATE,
                      X_Effective_End_Date           IN OUT NOCOPY DATE,
                      X_Payroll_Id                                 NUMBER,
                      X_Org_Payment_Method_Id                      NUMBER);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a formula by applying a lock on a formula in the Define Payroll    --
 --   form.                                                                 --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Org_Pay_Method_Usage_Id               NUMBER,
                    X_Effective_Start_Date                  DATE,
                    X_Effective_End_Date                    DATE,
                    X_Payroll_Id                            NUMBER,
                    X_Org_Payment_Method_Id                 NUMBER);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of an OPMU   via the --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Org_Pay_Method_Usage_Id             NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Payroll_Id                          NUMBER,
                      X_Org_Payment_Method_Id               NUMBER);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a OPMU via the    --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid VARCHAR2);
--
END PAY_ORG_PAY_METH_USAGES_F_PKG;

/
