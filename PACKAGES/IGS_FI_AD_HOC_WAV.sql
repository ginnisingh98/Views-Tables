--------------------------------------------------------
--  DDL for Package IGS_FI_AD_HOC_WAV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_AD_HOC_WAV" AUTHID CURRENT_USER AS
/* $Header: IGSFI70S.pls 120.0 2005/06/01 12:51:38 appldev noship $ */

 ------------------------------------------------------------------
  --Created by  : Jabeen Begum, Oracle IDC
  --Date created: 5/12/2001
  --
  --Purpose: This package is used for group application of waiver on charges
  --or group release of waiver present on charges
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smvk        16-Sep-2002     Removed the parameters p_n_sub_acc_1 and p_n_sub_acc_2,
  --                            As a part of Subaccount Removal Build. Bug # 2564643
  -------------------------------------------------------------------

  PROCEDURE group_waiver_proc( errbuf                   OUT NOCOPY VARCHAR2                                               ,
                               retcode                  OUT NOCOPY NUMBER                                                 ,
                               p_c_action               IN  VARCHAR2                                               ,
                               p_c_bal_type             IN  igs_lookups_view.lookup_code%TYPE                      ,
                               p_d_start_dt             IN  VARCHAR2                                               ,
                               p_d_end_dt               IN  VARCHAR2                                               ,
                               p_d_release_dt	        IN  VARCHAR2                                               ,
			       p_n_person_id            IN  igs_pe_person_v.person_id%TYPE                         ,
			       p_n_pers_id_grp_id       IN  igs_pe_persid_group_v.group_id%TYPE                    ,
			       p_c_fee_period           IN  VARCHAR2                                               ,
                              /* Removed the parameters p_n_sub_acc_1 and p_n_sub_acc_2, as a part of Bug # 2564643 */
			       p_c_fee_type_1           IN  igs_fi_inv_int.fee_type%TYPE                           ,
                               p_c_fee_type_2           IN  igs_fi_inv_int.fee_type%TYPE                           ,
			       p_c_fee_type_3           IN  igs_fi_inv_int.fee_type%TYPE                           ,
			       p_c_test_flag            IN  fnd_lookup_values.lookup_code%TYPE DEFAULT '1'
                             );

END igs_fi_ad_hoc_wav;

 

/
