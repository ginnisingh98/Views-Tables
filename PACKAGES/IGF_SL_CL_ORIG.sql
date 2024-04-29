--------------------------------------------------------
--  DDL for Package IGF_SL_CL_ORIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_CL_ORIG" AUTHID CURRENT_USER AS
/* $Header: IGFSL08S.pls 115.16 2003/10/30 07:17:00 ugummall ship $ */

/***************************************************************
   Created By       :   mesriniv
   Date Created By  :   2000/11/13
   Purpose      :   To Originate Common Line Loan Records and Create
                Output File
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who          When          What
   ugummall     29-OCT-2003   Bug 3102439. FA 126 - Multiple FA Offices.
                              Added 4 new parameters to cl_originate and 3 to sub_cl_originate.
   sjadhav      7-Oct-2003    Bug 3104228 Fa 122 Build
                              Added media type and recipient id
                              and relationship cd parameters
 ***************************************************************/
  PROCEDURE cl_originate(
  errbuf                OUT NOCOPY      VARCHAR2,
  retcode               OUT NOCOPY      NUMBER,
  p_award_year          IN              VARCHAR2,
  p_base_id             IN              VARCHAR2,
  p_loan_catg           IN              igf_lookups_view.lookup_code%TYPE,
  p_loan_number         IN              igf_sl_loans_all.loan_number%TYPE,
  p_org_id              IN              NUMBER,
  p_media_type          IN              VARCHAR2,
  p_recipient_id        IN              VARCHAR2,
  p_school_id           IN              VARCHAR2,
  non_ed_branch         IN              VARCHAR2,
  sch_non_ed_branch     IN              VARCHAR2
  );

  PROCEDURE sub_cl_originate(
  errbuf                OUT NOCOPY      VARCHAR2,
  retcode               OUT NOCOPY      NUMBER,
  p_ci_cal_type         IN              igs_ca_inst.cal_type%TYPE,
  p_ci_sequence_number  IN              igs_ca_inst.sequence_number%TYPE,
  p_loan_number         IN              igf_sl_loans_all.loan_number%TYPE,
  p_loan_catg           IN              igf_lookups_view.lookup_code%TYPE,
  p_org_id              IN              NUMBER,
  p_relationship_cd     IN              VARCHAR2,
  p_media_type          IN              VARCHAR2,
  p_base_id             IN              VARCHAR2,
  p_school_id           IN              VARCHAR2,
  sch_non_ed_branch     IN              VARCHAR2
  );

END igf_sl_cl_orig;

 

/
