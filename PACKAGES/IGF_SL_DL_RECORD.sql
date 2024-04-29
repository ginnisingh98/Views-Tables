--------------------------------------------------------
--  DDL for Package IGF_SL_DL_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_RECORD" AUTHID CURRENT_USER AS
/* $Header: IGFSL11S.pls 120.0 2005/06/01 14:50:04 appldev noship $ */

  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/13
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who         When            What
  ugummall    17-OCT-2003     Bug 3102439. FA 126 Multiple FA Offices.
                              New parameter p_school_code is added to procedures
                              DLHeader_cur and DLOrig_cur.
  masehgal    08-Jan-2003     # 2593215   Removed functions to get begin and end of call dates
                              added procedure get_acad_cal_dtls instead

  (reverse chronological order - newest change first)
  ***************************************************************/


    -- REF Cursor for Direct Loan Origination File : Header Record
    TYPE DLHeaderType  IS REF CURSOR;

    -- REF Cursor for Direct Loan Origination File : Transaction Record
    TYPE DLOrigType    IS REF CURSOR;

    -- REF Cursor for Direct Loan Origination File : Trailer Record
    TYPE DLTrailerType IS REF CURSOR;


    -- DLDisbDetails should not be called by external programs
    FUNCTION  DLDisbDetails(p_dl_version    igf_lookups_view.lookup_code%TYPE,
                            p_award_id      igf_aw_award.award_id%TYPE)
    RETURN VARCHAR2;


    PROCEDURE DLHeader_cur(p_dl_version         igf_lookups_view.lookup_code%TYPE,
                           p_dl_loan_catg       igf_lookups_view.lookup_code%TYPE,
                           p_cal_type           igs_ca_inst.cal_type%TYPE,
                           p_cal_seq_num        igs_ca_inst.sequence_number%TYPE,
                           p_file_type          igf_sl_dl_file_type.dl_file_type%TYPE,
                           p_school_code  IN     VARCHAR2,
                           p_dbth_id        IN OUT NOCOPY igf_sl_dl_batch.dbth_id%TYPE,
                           p_batch_id       IN OUT NOCOPY igf_sl_dl_batch.batch_id%TYPE,
                           p_mesg_class     IN OUT NOCOPY igf_sl_dl_batch.message_class%TYPE,
                           Header_Rec       IN OUT NOCOPY igf_sl_dl_record.DLHeaderType);

    PROCEDURE DLTrailer_cur(p_dl_version         igf_lookups_view.lookup_code%TYPE,
                            p_num_of_rec         NUMBER,
                            Trailer_Rec   IN OUT NOCOPY igf_sl_dl_record.DLTrailerType);

    PROCEDURE DLOrig_cur(p_dl_version        igf_lookups_view.lookup_code%TYPE,
                         p_dl_loan_catg      igf_lookups_view.lookup_code%TYPE,
                         p_ci_cal_type       igs_ca_inst.cal_type%TYPE,
                         p_ci_seq_num        igs_ca_inst.sequence_number%TYPE,
                         p_dl_loan_number    igf_sl_loans.loan_number%TYPE,
                         p_dl_batch_id       igf_sl_dl_batch.batch_id%TYPE,
                         p_school_code  IN     VARCHAR2,
                         Orig_Rec     IN OUT NOCOPY igf_sl_dl_record.DLOrigType);




-- masehgal   new procedure to get acad cal dates
-- This would replace the get_acad_begin_date and get_acad_end_date
    PROCEDURE get_acad_cal_dtls( p_loan_number                 igf_sl_loans_all.loan_number%TYPE,
                                 p_acad_cal_type    OUT NOCOPY igs_ca_inst_all.cal_type%TYPE,
                                 p_acad_seq_num     OUT NOCOPY igs_ca_inst_all.sequence_number%TYPE,
                                 p_acad_begin_date  IN OUT NOCOPY igs_ps_ofr_inst.ci_start_dt%TYPE,
                                 p_acad_end_date    IN OUT NOCOPY igs_ps_ofr_inst.ci_end_dt%TYPE ,
                                 p_message          OUT NOCOPY VARCHAR2 );

    PRAGMA RESTRICT_REFERENCES (DLDisbDetails,       WNDS, WNPS);

END igf_sl_dl_record;

 

/
