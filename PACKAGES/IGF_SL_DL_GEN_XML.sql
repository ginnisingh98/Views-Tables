--------------------------------------------------------
--  DDL for Package IGF_SL_DL_GEN_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_GEN_XML" AUTHID CURRENT_USER AS
/* $Header: IGFSL25S.pls 120.0 2005/06/01 13:19:20 appldev noship $ */

--
-- Process to generate direct loan XML output file
-- main is the  entry point through concurrent program
--
-- main would validate loan records and insert into _LOR_LOC
-- table with document id. Then it would raise business event
-- to call the xml gateway routines to create xml document
-- this business event would have document id as a parameter
--
  PROCEDURE main(errbuf       OUT NOCOPY VARCHAR2,
                 retcode      OUT NOCOPY NUMBER,
                 p_award_year VARCHAR2,
                 p_source_id  VARCHAR2,
                 p_report_id  VARCHAR2,
                 p_attend_id  VARCHAR2,
                 p_fund_id    NUMBER,
                 p_fund_dummy NUMBER,
                 p_base_id    NUMBER,
                 p_base_dummy NUMBER,
                 p_loan_id    NUMBER,
                 p_loan_dummy NUMBER,
                 p_pgroup_id  NUMBER);

--
-- Workfwlo Process to store XML output file
-- this process is initiated after xml gateway sucessfully
-- creates xml document
-- this process would store the generated document into
-- table after editing it and pass it for printing
--

  PROCEDURE store_xml(itemtype   IN VARCHAR2,
                      itemkey    IN VARCHAR2,
                      actid      IN NUMBER,
                      funcmode   IN VARCHAR2,
                      resultout  OUT NOCOPY VARCHAR2);
--
-- Process to print direct loan XML output file
--

  PROCEDURE print_xml(errbuf        OUT NOCOPY VARCHAR2,
                      retcode       OUT NOCOPY NUMBER,
                      p_document_id_txt VARCHAR2);


  PROCEDURE print_out_xml(p_xml_clob CLOB);
  PROCEDURE edit_clob(p_document_id_txt VARCHAR2,p_xml_clob OUT NOCOPY CLOB, p_rowid OUT NOCOPY ROWID);
--
-- Cursor to pick up loan records
--
    CURSOR cur_pick_loans (p_cal_type   VARCHAR2, p_seq_number NUMBER,
                           p_base_id    NUMBER,
                           p_report_id  VARCHAR2,
                           p_attend_id  VARCHAR2,
                           p_fund_id    NUMBER,
                           p_loan_id    NUMBER
                          )
    IS
    SELECT
    lor.*, fcat.fed_fund_code, fmast.ci_cal_type,fmast.ci_sequence_number,
    awd.base_id, awd.offered_amt,awd.accepted_amt,loan.loan_per_begin_date,loan.loan_per_end_date,
    loan.loan_number,loan.award_id,loan.loan_status,loan.loan_chg_status,loan.loan_status_date,
    loan.loan_chg_status_date, loan.active, loan.active_date
    FROM
    igf_sl_loans_all loan,
    igf_sl_lor_all   lor,
    igf_aw_award_all awd,
    igf_aw_fund_mast_all fmast,
    igf_aw_fund_cat_all  fcat
    WHERE
    fmast.ci_cal_type = p_cal_type AND
    fmast.ci_sequence_number = p_seq_number AND
    fcat.fed_fund_code IN ('DLP','DLS','DLU') AND
    fmast.fund_code  = fcat.fund_code AND
    awd.fund_id   = fmast.fund_id AND
    loan.award_id = awd.award_id AND
    loan.loan_id  = lor.loan_id  AND
    fmast.fund_id = NVL(p_fund_id, fmast.fund_id) AND
    awd.base_id   = NVL(p_base_id, awd.base_id)  AND
    loan.loan_id  = NVL(p_loan_id, loan.loan_id)  AND
    lor.atd_entity_id_txt = NVL(p_attend_id,atd_entity_id_txt) AND
    lor.rep_entity_id_txt = NVL(p_report_id,rep_entity_id_txt) AND
    loan.active   = 'Y'                                        AND
    (loan.loan_status = 'G' OR loan.loan_chg_status = 'G' )
    ORDER BY
    lor.rep_entity_id_txt,
    lor.atd_entity_id_txt,
    awd.base_id,
    fcat.fed_fund_code;

     CURSOR cur_pick_loans_all_status (p_cal_type   VARCHAR2, p_seq_number NUMBER,
                           p_base_id    NUMBER,
                           p_report_id  VARCHAR2,
                           p_attend_id  VARCHAR2,
                           p_fund_id    NUMBER,
                           p_loan_id    NUMBER
                          )
    IS
    SELECT
    lor.*, fcat.fed_fund_code, fmast.ci_cal_type,fmast.ci_sequence_number,
    awd.base_id, awd.offered_amt,awd.accepted_amt,loan.loan_per_begin_date,loan.loan_per_end_date,
    loan.loan_number,loan.award_id,loan.loan_status,loan.loan_chg_status,loan.loan_status_date,
    loan.loan_chg_status_date, loan.active, loan.active_date
    FROM
    igf_sl_loans_all loan,
    igf_sl_lor_all   lor,
    igf_aw_award_all awd,
    igf_aw_fund_mast_all fmast,
    igf_aw_fund_cat_all  fcat
    WHERE
    fmast.ci_cal_type = p_cal_type AND
    fmast.ci_sequence_number = p_seq_number AND
    fcat.fed_fund_code IN ('DLP','DLS','DLU') AND
    fmast.fund_code  = fcat.fund_code AND
    awd.fund_id   = fmast.fund_id AND
    loan.award_id = awd.award_id AND
    loan.loan_id  = lor.loan_id  AND
    fmast.fund_id = NVL(p_fund_id, fmast.fund_id) AND
    awd.base_id   = NVL(p_base_id, awd.base_id)  AND
    loan.loan_id  = NVL(p_loan_id, loan.loan_id)  AND
    lor.atd_entity_id_txt = NVL(p_attend_id,atd_entity_id_txt) AND
    lor.rep_entity_id_txt = NVL(p_report_id,rep_entity_id_txt) AND
    loan.active   = 'Y'                                        AND
    (loan.loan_status in ('G', 'N','R')
    OR loan.loan_chg_status in ('G','N','R') )
    ORDER BY
    lor.rep_entity_id_txt,
    lor.atd_entity_id_txt,
    awd.base_id,
    fcat.fed_fund_code;

END igf_sl_dl_gen_xml;

 

/
