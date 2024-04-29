--------------------------------------------------------
--  DDL for Package IGS_UC_QUAL_DETS_IMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_QUAL_DETS_IMP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSUC28S.pls 115.6 2003/06/09 10:31:15 rgangara noship $ */

  /*************************************************************
  Created By      : rgopalan
  Date Created On : 2002/02/22
  Purpose         :This procedure will import qualification details
                   of an applicant in to secondry and teritory table
                   from UCAS Interface table based on HESA code mapping.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  rgangara        19-May-03       Added procedure Validate_PE_qual for
                                  Enh# 2961536. This procedure would
                                  be called from Adm Import process for
                                  validating Interface table data while
                                  importing Previous Qualification details.
                                  Adm Bug# 2860842
  (reverse chronological order - newest change first)
  ***************************************************************/


PROCEDURE igs_uc_qual_dets_imp (errbuf    OUT NOCOPY    VARCHAR2,
                                retcode   OUT NOCOPY    NUMBER
                                );



PROCEDURE validate_pe_qual(p_uc_qual_cur igs_ad_imp_028.c_uc_qual_cur%ROWTYPE,
                           p_status      OUT  NOCOPY VARCHAR2,
									p_error_code  OUT NOCOPY VARCHAR2);


END igs_uc_qual_dets_imp_pkg;

 

/
