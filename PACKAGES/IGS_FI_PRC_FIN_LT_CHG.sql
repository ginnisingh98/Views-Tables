--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_FIN_LT_CHG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_FIN_LT_CHG" AUTHID CURRENT_USER AS
/* $Header: IGSFI69S.pls 120.0 2005/06/01 21:54:16 appldev noship $ */
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  This package declares procedure/function needed for the implementation of late
                    and finance charges.

  Known limitations,enhancements,remarks:
  Change History
  Who 	     When          What
  vvutukur   24-Nov-2002   Enh#2584986.Added p_d_gl_date parameter to calc_fin_lt_charge procedure.
  shtatiko   23-SEP-2002   Removed subaccount_id from the signature of calc_red_balance.
********************************************************************************************** */
PROCEDURE calc_fin_lt_charge(
                   errbuf             OUT NOCOPY   VARCHAR2,
                   retcode            OUT NOCOPY   NUMBER,
                   p_person_id        IN    igs_pe_person.person_id%TYPE DEFAULT NULL,
                   p_pers_id_grp_id   IN    igs_pe_persid_group.group_id%TYPE DEFAULT NULL,
                   p_plan_name        IN    igs_fi_fin_lt_plan.plan_name%TYPE ,
                   p_batch_cutoff_dt  IN    VARCHAR2,
                   p_batch_due_dt     IN    VARCHAR2,
                   p_fee_period       IN    VARCHAR2,
                   p_chg_crtn_dt      IN    VARCHAR2,
                   p_test_flag        IN    VARCHAR2 DEFAULT '1',
                   p_d_gl_date        IN    VARCHAR2
                 );
PROCEDURE calc_red_balance(
                   p_person_id        IN    igs_pe_person.person_id%TYPE,
                   p_bal_start_dt     IN    DATE,
                   p_bal_end_dt       IN    DATE,
                   p_bal_type         IN    igs_fi_balance_rules.balance_name%TYPE,
                   p_open_bal         IN    NUMBER,
                   p_red_bal          OUT NOCOPY   NUMBER
                 );

END IGS_FI_PRC_FIN_LT_CHG;

 

/
