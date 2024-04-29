--------------------------------------------------------
--  DDL for Package JAI_AP_TDS_ETDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_TDS_ETDS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ap_tds_etds.pls 120.8.12010000.5 2009/09/23 11:30:37 mbremkum ship $ */

  v_filehandle    UTL_FILE.FILE_TYPE;
  v_utl_file_dir  VARCHAR2(512);
  v_utl_file_name VARCHAR2(50);
  v_generate_headers  BOOLEAN := FALSE;

  -- Padding Variables
  v_pad_char    CONSTANT VARCHAR2(1) := ' ';
  v_pad_date    CONSTANT VARCHAR2(1) := ' ';
  v_pad_number  CONSTANT VARCHAR2(1) := '0';

  v_underline_char CONSTANT VARCHAR2(1) := '-';
  v_debug_pad_char VARCHAR2(1);

  s_date      NUMBER(1) := 8;

  -- Size and Format Related Variables (Updated on 25th Oct 2006)

  v_delimeter       VARCHAR2(1) := '^' ;
  v_quart_len       NUMBER := 15 ;
  v_chr13           VARCHAR2(7) := 'CHR(13)';
  v_chr10           VARCHAR2(7) := 'CHR(10)';
  sq_len_1          NUMBER := 1  ;
  sq_len_2          NUMBER :=2   ;
  sq_len_3          NUMBER :=3   ;
  sq_len_4          NUMBER :=4   ;
  sq_len_5          NUMBER :=5   ;
  sq_len_6          NUMBER :=6   ;
  sq_len_7          NUMBER :=7   ;
  sq_len_8          NUMBER :=8   ;
  sq_len_9          NUMBER :=9   ;
  sq_len_10         NUMBER :=10   ;
  sq_len_12         NUMBER :=12   ;
  sq_len_14         NUMBER :=14   ;
  sq_len_15         NUMBER :=15   ;
  sq_len_20         NUMBER :=20   ;
  sq_len_25         NUMBER :=25   ;
  sq_len_75         NUMBER :=75   ;
  sq_len_150        NUMBER :=150  ;

  v_quart_pad       VARCHAR2(1) := ' ';
  v_q_noval_filler  VARCHAR2(1) := '-';
  v_q_null_filler   VARCHAR2(1) := '*';
  v_quart_numfill   NUMBER      := 0 ;
  v_format_amount   VARCHAR2(17)  := 'FM999999999990D00' ;
  v_format_rate     VARCHAR2(9)   := 'FM90D0000';
  ln_batch_id       NUMBER ;
  lv_action         VARCHAR2(1) ;
  G_DATE_DUMMY CONSTANT VARCHAR2(1) := '-';

  -- File Header Size Variables
  s_line_number CONSTANT NUMBER(2) := 6;
  s_record_type CONSTANT NUMBER(2) := 2;
  s_file_type   CONSTANT NUMBER(2) := 3;
  s_upload_type CONSTANT NUMBER(2) := 1;
  s_file_sequence_number  CONSTANT NUMBER(2) := 8;
  s_deductor_tan    CONSTANT NUMBER(2) := 10;
  s_number_of_batches CONSTANT NUMBER(2) := 4;
  s_return_prep CONSTANT NUMBER(2) := 75; /*Bug 8880543 - Added for Return Preperation Utility*/

  -- Batch Header Size Variables
  s_batch_number CONSTANT NUMBER(2) := 4;
  s_challan_count CONSTANT NUMBER(2) := 5;
  s_deductee_count CONSTANT NUMBER(2) := 5;
  s_form_number CONSTANT NUMBER(2) := 4;
  s_rrr_number CONSTANT NUMBER(2) := 10;
  s_rrr_date CONSTANT NUMBER(2) := 8;
  s_pan_of_tan CONSTANT NUMBER(2) := 10;
  s_assessment_year CONSTANT NUMBER(2) := 6;
  s_financial_year CONSTANT NUMBER(2) := 6;
  s_deductor_name CONSTANT NUMBER(2) := 75;
  s_tan_address1 CONSTANT NUMBER(2) := 25;
  s_tan_address2 CONSTANT NUMBER(2) := 25;
  s_tan_address3 CONSTANT NUMBER(2) := 25;
  s_tan_address4 CONSTANT NUMBER(2) := 25;
  s_tan_address5 CONSTANT NUMBER(2) := 25;
  s_tan_state CONSTANT NUMBER(2) := 2;
  s_tan_pin CONSTANT NUMBER(2) := 6;
  s_chng_addr_since_last_return CONSTANT NUMBER(2) := 1;
  s_status_of_deductor CONSTANT NUMBER(2) := 1;
  s_quart_year_return CONSTANT NUMBER(2) := 2;
  s_pers_resp_for_deduction CONSTANT NUMBER(2) := 75;
  s_pers_designation CONSTANT NUMBER(2) := 20;
  s_tot_tax_dedected_challan CONSTANT NUMBER(2) := 14;
  s_tot_tax_dedected_deductee CONSTANT NUMBER(2) := 14;

  -- Challan Detail Size Variables
  s_challan_slno CONSTANT NUMBER(2) := 5;
  s_challan_section CONSTANT NUMBER(2) := 5;
  s_amount_deducted CONSTANT NUMBER(2) := 14;
  s_challan_num CONSTANT NUMBER(2) := 9;
  s_bank_branch_code CONSTANT NUMBER(2) := 7;

  -- Deductee Detail Size Variables
  s_deductee_slno CONSTANT NUMBER(2) := 5;
  s_deductee_section CONSTANT NUMBER(2) := 5;
  s_deductee_code CONSTANT NUMBER(2) := 2;
  s_deductee_pan CONSTANT NUMBER(2) := 10;
  s_deductee_name CONSTANT NUMBER(2) := 75;
  s_deductee_address1 CONSTANT NUMBER(2) := 25;
  s_deductee_address2 CONSTANT NUMBER(2) := 25;
  s_deductee_address3 CONSTANT NUMBER(2) := 25;
  s_deductee_address4 CONSTANT NUMBER(2) := 25;
  s_deductee_address5 CONSTANT NUMBER(2) := 25;
  s_deductee_state CONSTANT NUMBER(2) := 2;
  s_deductee_pin CONSTANT NUMBER(2) := 6;
  s_payment_amount CONSTANT NUMBER(2) := 14;
  s_tax_rate CONSTANT NUMBER(2) := 4;
  s_grossing_up_factor CONSTANT NUMBER(2) := 1;
  s_tax_deducted CONSTANT NUMBER(2) := 14;
  s_challan_no CONSTANT NUMBER(2) := 9;
  s_reason_for_nDeduction CONSTANT NUMBER(2) := 1;
  s_filler CONSTANT NUMBER(2) := 14;
  s_book_ent_oth  NUMBER(2) := 1; -- updated on 26th
  s_filler6       NUMBER(2) := 1; -- updated on 26th

  FUNCTION formatAmount( p_amount IN NUMBER) RETURN VARCHAR2;

  FUNCTION getSectionCode( p_section IN VARCHAR2, p_string IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

  PROCEDURE openFile(p_directory IN VARCHAR2, p_filename IN VARCHAR2);
  PROCEDURE closeFile;

  -- added,  Harshita for Bug 5096787
  PROCEDURE populate_details(
    p_batch_id IN NUMBER,
    p_org_tan_num IN VARCHAR2,
    p_tds_vendor_id IN NUMBER,
    p_tds_vendor_site_id IN NUMBER,
    p_tds_inv_from_date IN DATE,
    p_tds_inv_to_date IN DATE,
    p_etds_yearly_returns VARCHAR2 , -- updated on 25th october
    p_include_list  IN  VARCHAR2,      --Date 11-05-2007 by Sacsethi for bug 5647248
    p_exclude_list  IN  VARCHAR2
  );

  -- ended,  Harshita for Bug 5096787

  PROCEDURE create_file_header(
    p_line_number IN NUMBER,
    p_record_type IN VARCHAR2,
    p_file_type IN VARCHAR2,
    p_upload_type IN VARCHAR2,
    p_file_creation_date IN DATE,
    p_file_sequence_number IN NUMBER,
    p_deductor_tan IN VARCHAR2,
    p_number_of_batches IN NUMBER
  );

  PROCEDURE create_batch_header(
    p_line_number IN NUMBER,
    p_record_type IN VARCHAR2,
    p_batch_number IN NUMBER,
    p_challan_count IN NUMBER,
    p_deductee_count IN NUMBER,
    p_form_number IN CHAR,
    p_rrr_number IN NUMBER,
    p_rrr_date IN DATE,
    p_deductor_tan IN VARCHAR2,
    p_pan_of_tan IN VARCHAR2,
    p_assessment_year IN NUMBER,
    p_financial_year IN NUMBER,
    p_deductor_name IN VARCHAR2,
    p_tan_address1 IN VARCHAR2,
    p_tan_address2 IN VARCHAR2,
    p_tan_address3 IN VARCHAR2,
    p_tan_address4 IN VARCHAR2,
    p_tan_address5 IN VARCHAR2,
    p_tan_state IN NUMBER,
    p_tan_pin IN NUMBER,
    p_chng_addr_since_last_return IN VARCHAR2,
    p_type_of_deductor IN VARCHAR2,
    p_quart_year_return IN VARCHAR,
    p_pers_resp_for_deduction IN VARCHAR2,
    p_pers_designation IN VARCHAR2,
    p_tot_tax_dedected_challan IN NUMBER,
    p_tot_tax_dedected_deductee IN NUMBER,
    -- added. Harshita for Bug 5096787
    p_filler1    IN DATE DEFAULT NULL,
    p_filler2  IN NUMBER DEFAULT NULL,
    p_filler3  IN VARCHAR2 DEFAULT NULL,
    p_ack_num_tan_app IN NUMBER DEFAULT NULL,
    p_pro_rcpt_num_org_ret IN NUMBER  DEFAULT NULL
    -- ended. Harshita for Bug 5096787
  );

  PROCEDURE create_challan_detail(
    p_line_number IN NUMBER,  -- 6
    p_record_type IN VARCHAR2,  -- 2
    p_batch_number IN NUMBER, -- 4
    p_challan_slno IN NUMBER, -- 5
    p_challan_section IN VARCHAR2,    -- 5
    p_amount_deducted IN NUMBER,  -- 14
    p_challan_num IN VARCHAR2,    -- 9
    p_challan_date IN DATE,     -- 8
    p_bank_branch_code IN VARCHAR2,  -- 7
    -- added. Harshita for Bug 5096787
    p_amount_of_tds       IN NUMBER DEFAULT NULL,
    p_amount_of_surcharge IN NUMBER DEFAULT NULL,
    p_amount_of_cess      IN NUMBER DEFAULT NULL,
    p_amount_of_int       IN NUMBER DEFAULT NULL,
    p_amount_of_oth       IN NUMBER DEFAULT NULL,
    p_check_number        IN NUMBER DEFAULT NULL,
    p_tds_dep_by_book     IN VARCHAR2 DEFAULT NULL,
    p_filler4             IN VARCHAR2 DEFAULT NULL
    -- added. Harshita for Bug 5096787
  );

  PROCEDURE create_deductee_detail(
       p_line_number IN NUMBER,        -- 9
       p_record_type IN VARCHAR2,      -- 2
       p_batch_number IN NUMBER,       -- 9
       p_deductee_slno IN NUMBER,      -- 5
       p_deductee_section IN VARCHAR2, -- 5
       p_deductee_code IN VARCHAR2,    -- 2            01 for Companies and 02 for other than companies
       p_deductee_pan IN VARCHAR2,     -- 10
       p_deductee_name IN VARCHAR2,    -- 75
       p_deductee_address1 IN VARCHAR2,        -- 25
       p_deductee_address2 IN VARCHAR2,        -- 25
       p_deductee_address3 IN VARCHAR2,        -- 25
       p_deductee_address4 IN VARCHAR2,        -- 25
       p_deductee_address5 IN VARCHAR2,        -- 25
       p_deductee_state IN VARCHAR2,   -- 2
       p_deductee_pin IN VARCHAR2,       -- 6 /*Changed to VARCHAR2 - Bug7494473*/
       p_filler5 IN NUMBER,            -- 14 Added for bug#4353842
       p_payment_amount IN NUMBER,     -- 14 (12+2), DECIMAL
       p_payment_date IN DATE,         -- 8
       p_book_ent_oth IN VARCHAR2,     -- 1  Added for bug#4353842
       p_tax_rate IN NUMBER,           -- 4(2+2), DECIMAL
       p_filler6  IN VARCHAR2,         -- 1 Added for bug#4353842
       --p_grossing_up_factor IN VARCHAR2,     -- 1  -- Obsoleted via bug # 4353842
       p_tax_deducted IN NUMBER,       -- 14(12+2), DECIMAL
       p_tax_deducted_date IN DATE, -- 8
       p_tax_payment_date IN DATE,     -- 8
       p_bank_branch_code IN VARCHAR2, -- 7
       p_challan_no IN VARCHAR2,               -- 9
       p_tds_certificate_date IN DATE, -- 8
       p_reason_for_nDeduction IN VARCHAR2,    -- 1
       p_filler7 IN NUMBER                             -- 14, DECIMAL
         );


  PROCEDURE create_fh(p_batch_id IN NUMBER);
  PROCEDURE create_bh;
  PROCEDURE create_cd;
  PROCEDURE create_dd;



-- added, Harshita for Bug 5096787

        -- eTDS Quarterly Data Generation Procedues

        PROCEDURE create_quarterly_file_header(
          p_line_number IN NUMBER,
          p_record_type IN VARCHAR2,
          p_file_type IN VARCHAR2,
          p_upload_type IN VARCHAR2,
          p_file_creation_date IN DATE,
          p_file_sequence_number IN NUMBER,
          p_uploader_type  IN VARCHAR2,
          p_deductor_tan IN VARCHAR2,
          p_number_of_batches IN NUMBER,
          p_return_prep_util IN VARCHAR2, /*Bug 8880543 - Added Return Preperation Utility*/
          p_fh_recordHash IN VARCHAR2,
          p_fh_fvuVersion IN VARCHAR2,
          p_fh_fileHash   IN VARCHAR2,
          p_fh_samVersion IN VARCHAR2,
          p_fh_samHash    IN VARCHAR2,
          p_fh_scmVersion IN VARCHAR2,
          p_fh_scmHash    IN VARCHAR2,
          p_generate_headers IN VARCHAR2
        );


        PROCEDURE create_quarterly_batch_header(
          p_line_number IN NUMBER,
          p_record_type IN VARCHAR2,
          p_batch_number IN NUMBER,
          p_challan_count IN NUMBER,
          p_form_number IN CHAR,
          p_trn_type IN VARCHAR2,
          p_batchUpd IN VARCHAR2,
          p_org_RRRno IN VARCHAR2,
          p_prev_RRRno         IN VARCHAR2,
          p_RRRno              IN VARCHAR2 ,
          p_RRRdate            IN VARCHAR2 ,
          p_deductor_last_tan  IN VARCHAR2,
          p_deductor_tan       IN VARCHAR2,
          p_filler1            IN VARCHAR2,
          p_deductor_pan       IN VARCHAR2,
          p_assessment_year    IN NUMBER,
          p_financial_year     IN NUMBER,
          p_period             IN VARCHAR2,
          p_deductor_name      IN VARCHAR2,
          p_deductor_branch    IN VARCHAR2,
          p_tan_address1       IN VARCHAR2,
          p_tan_address2       IN VARCHAR2,
          p_tan_address3       IN VARCHAR2,
          p_tan_address4       IN VARCHAR2,
          p_tan_address5       IN VARCHAR2,
          p_tan_state_code     IN NUMBER,
          p_tan_pin            IN NUMBER,
          p_deductor_email     IN VARCHAR2,
          p_deductor_stdCode   IN NUMBER,
          p_deductor_phoneNo   IN NUMBER,
          p_addrChangedSinceLastReturn IN VARCHAR2,
          p_type_of_deductor   IN VARCHAR2,    /*Bug 8880543 - Modified Deductor Status to Deductor Type*/
          p_pers_resp_for_deduction IN VARCHAR2,
          p_PespPerson_designation  IN VARCHAR2,
          p_RespPerson_address1     IN VARCHAR2,
          p_RespPerson_address2     IN VARCHAR2,
          p_RespPerson_address3     IN VARCHAR2,
          p_RespPerson_address4     IN VARCHAR2,
          p_RespPerson_address5     IN VARCHAR2,
          p_RespPerson_state        IN VARCHAR2,
          p_RespPerson_pin          IN NUMBER,
          p_RespPerson_email        IN VARCHAR2,
          p_RespPerson_remark       IN VARCHAR2,
          p_RespPerson_stdCode      IN NUMBER,
          p_RespPerson_phoneNo      IN NUMBER,
          p_RespPerson_addressChange IN VARCHAR2,
          p_totTaxDeductedAsPerChallan IN NUMBER,
          p_tds_circle              IN VARCHAR2,
          p_salaryRecords_count     IN VARCHAR2,
          p_gross_total             IN VARCHAR2,
          p_ao_approval             IN VARCHAR2,
          p_ao_approval_number      IN VARCHAR2,
          /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
          p_last_deductor_type      IN  VARCHAR2,
          p_state_name              IN  VARCHAR2,
          p_pao_code                IN  VARCHAR2,
          p_ddo_code                IN  VARCHAR2,
          p_ministry_name           IN  VARCHAR2,
          p_ministry_name_other     IN  VARCHAR2,
          p_filler2                 IN VARCHAR2,
          p_pao_registration_no     IN  NUMBER,
          p_ddo_registration_no     IN  VARCHAR2,
          /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
          p_recHash                 IN VARCHAR2,
          p_generate_headers        IN VARCHAR2
        );


        PROCEDURE create_quart_challan_dtl(
          p_line_number IN NUMBER ,
          p_record_type IN VARCHAR2 ,
          p_batch_number IN NUMBER ,
          p_challan_dtl_slno IN NUMBER ,
          p_deductee_cnt IN NUMBER ,
          p_nil_challan_indicator IN VARCHAR2 ,
          p_ch_updIndicator IN VARCHAR2 ,
          p_filler2 IN VARCHAR2 ,
          p_filler3 IN VARCHAR2 ,
          p_filler4 IN VARCHAR2 ,
          p_last_bank_challan_no IN VARCHAR2 ,
          p_bank_challan_no IN VARCHAR2 ,
          p_last_transfer_voucher_no IN VARCHAR2 ,
          p_transfer_voucher_no IN NUMBER ,
          p_last_bank_branch_code IN VARCHAR2 ,
          p_bank_branch_code IN VARCHAR2 ,
          p_challan_lastDate IN VARCHAR2 ,
          p_challan_Date IN DATE ,
          p_filler5 IN VARCHAR2 ,
          p_filler6 IN VARCHAR2 ,
          p_tds_section IN VARCHAR2 ,
          p_amt_of_tds IN NUMBER ,
          p_amt_of_surcharge IN NUMBER ,
          p_amt_of_cess IN NUMBER ,
          p_amt_of_int IN NUMBER ,
          p_amt_of_oth IN NUMBER ,
          p_tds_amount IN NUMBER ,
          p_last_total_depositAmt IN NUMBER ,
          p_total_deposit IN NUMBER ,
          p_tds_income_tax IN NUMBER ,
          p_tds_surcharge IN NUMBER ,
          p_tds_cess IN NUMBER ,
          p_total_income_tds IN NUMBER ,
          p_tds_interest_amt IN NUMBER ,
          p_tds_other_amt IN NUMBER ,
          p_check_number IN NUMBER ,
          p_book_entry IN VARCHAR2 ,
          p_remarks IN VARCHAR2 ,
          p_ch_recHash IN VARCHAR2,
          p_generate_headers IN VARCHAR2,
  	  /* Bug 6796765. Added by Lakshmi Gopalsami
	   * Added p_form_name as this is required to print the
	   * section code depending on the section
	   */
	  p_form_name IN VARCHAR2
        ) ;


        PROCEDURE create_quart_deductee_dtl(
          p_line_number IN NUMBER,
          p_record_type IN VARCHAR2,
          p_batch_number IN NUMBER,
          p_dh_challan_recNo IN NUMBER,
          p_deductee_slno IN NUMBER,
          p_dh_mode IN VARCHAR2,
          p_emp_serial_no IN VARCHAR2,
          p_deductee_code IN VARCHAR2,
          p_last_emp_pan IN VARCHAR2,
          p_deductee_pan IN VARCHAR2,
          p_last_emp_pan_refno IN VARCHAR2,
          p_deductee_pan_refno IN VARCHAR2,
          p_vendor_name IN VARCHAR2,
          p_deductee_tds_income_tax IN NUMBER,
          p_deductee_tds_surcharge IN NUMBER,
          p_deductee_tds_cess IN NUMBER,
          p_deductee_total_tax_deducted IN NUMBER,
          p_last_total_tax_deducted IN VARCHAR2,
          p_deductee_total_tax_deposit IN NUMBER,
          p_last_total_tax_deposit IN VARCHAR2,
          p_total_purchase IN VARCHAR2,
          p_base_taxabale_amount IN NUMBER,
          p_gl_date IN DATE,
          p_tds_invoice_date IN DATE,
          p_deposit_date IN VARCHAR2,
          p_tds_tax_rate IN NUMBER,
          p_grossingUp_ind IN VARCHAR2,
          p_book_ent_oth IN VARCHAR2,
          p_certificate_issue_date IN VARCHAR2,
          p_remarks1 IN VARCHAR2,
          p_remarks2 IN VARCHAR2,
          p_remarks3 IN VARCHAR2,
          p_dh_recHash  IN VARCHAR2,
          p_generate_headers IN VARCHAR2
        ) ;

        -- Validation related Procedures.

        PROCEDURE validate_file_header
        ( p_line_number         IN NUMBER ,
          p_record_type         IN VARCHAR2,
          p_quartfile_type      IN VARCHAR2,
          p_upload_type         IN VARCHAR2,
          p_file_creation_date  IN DATE,
          p_file_sequence_number IN NUMBER,
          p_uploader_type       IN VARCHAR2,
          p_deductor_tan        IN VARCHAR2,
          p_number_of_batches   IN NUMBER,
          p_ret_prep_util       IN VARCHAR2, /*Bug 8880543 - Added Return Preperation Utility*/
          p_period              IN VARCHAR2,
          p_challan_start_date  IN DATE,
          p_challan_end_date    IN DATE,
          p_fin_year            IN NUMBER,
          p_return_code         OUT NOCOPY VARCHAR2,
          p_return_message      OUT NOCOPY VARCHAR2
       ) ;

        PROCEDURE validate_batch_header
         ( p_line_number                  IN  NUMBER,
           p_record_type                  IN  VARCHAR2,
           p_batch_number                 IN  NUMBER,
           p_challan_cnt                  IN  NUMBER,
           p_quart_form_number            IN  VARCHAR2,
           p_deductor_tan                 IN  VARCHAR2,
           p_assessment_year              IN  NUMBER,
           p_financial_year               IN  NUMBER,
           p_deductor_name                IN  VARCHAR2,
           p_deductor_pan                 IN  VARCHAR2, /*Bug 8880543 - Added for Validating PAN Number*/
           p_tan_address1                 IN  VARCHAR2,
           p_tan_state_code               IN  NUMBER,
           p_tan_pin                      IN  NUMBER,
           p_deductor_type                IN  VARCHAR2, /*Bug 8880543 - Modified Deductor Status to Deductor Type*/
           p_addrChangedSinceLastReturn   IN  VARCHAR2,
           p_personNameRespForDedection   IN  VARCHAR2,
           p_personDesgnRespForDedection  IN  VARCHAR2,
           p_RespPers_flat_no IN VARCHAR2 , -- Bug 6007891
	       p_RespPers_prem_bldg IN VARCHAR2 , -- Bug 6007891
	       p_RespPers_rd_st_lane IN VARCHAR2 , -- Bug 6007891
	       p_RespPers_area_loc IN VARCHAR2 , -- Bug 6007891
	       p_RespPers_tn_cty_dt IN VARCHAR2 , -- Bug 6007891
           p_RespPersState                IN  NUMBER,
           p_RespPersPin                  IN  NUMBER,
		   p_RespPers_tel_no IN VARCHAR2 , -- Bug 6007891
	       p_RespPers_email IN VARCHAR2 , -- Bug 6007891
           p_RespPersAddrChange           IN  VARCHAR2,
           p_totTaxDeductedAsPerDeductee  IN  NUMBER,
           p_ao_approval                  IN  VARCHAR2,
           /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
           p_state_name                   IN  VARCHAR2,
           p_pao_code                     IN  VARCHAR2,
           p_ddo_code                     IN  VARCHAR2,
           p_ministry_name                IN  VARCHAR2,
           p_pao_registration_no          IN  NUMBER,
           p_ddo_registration_no          IN  VARCHAR2,
           /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
           p_return_code                  OUT NOCOPY VARCHAR2,
           p_return_message               OUT NOCOPY VARCHAR2
         ) ;

         PROCEDURE validate_challan_detail
         (p_line_number           IN  NUMBER ,
          p_record_type           IN  VARCHAR2,
          p_batch_number          IN  NUMBER,
          p_challan_dtl_slno      IN  NUMBER,
          p_deductee_cnt          IN  NUMBER,
          p_nil_challan_indicat   IN  VARCHAR2,
          p_tds_section           IN  VARCHAR2,
          p_amt_of_tds            IN  NUMBER,
          p_amt_of_surcharge      IN  NUMBER,
          p_amt_of_cess           IN  NUMBER,
          p_amt_of_oth            IN  NUMBER,
          p_tds_amount            IN  NUMBER,
          p_total_income_tds      IN  NUMBER,
          p_challan_num           IN  VARCHAR2,
          p_bank_branch_code      IN  VARCHAR2,
          p_challan_no            IN  VARCHAR2,
          p_challan_Date          IN  DATE,
          p_check_number          IN  NUMBER,
          p_return_code           OUT NOCOPY VARCHAR2,
          p_return_message        OUT NOCOPY VARCHAR2
         ) ;

         PROCEDURE validate_deductee_detail
         ( p_line_number                  IN  NUMBER ,
           p_record_type                  IN  VARCHAR2,
           p_batch_number                 IN  NUMBER,
           p_challan_line_num             IN  NUMBER,
           p_deductee_slno                IN  NUMBER,
           p_dh_mode                      IN  VARCHAR2,
           p_quart_deductee_code          IN  VARCHAR2,
           p_deductee_pan                 IN  VARCHAR2,
           p_vendor_name                  IN  VARCHAR2,
           p_amt_of_tds                   IN  NUMBER,
           p_amt_of_surcharge             IN  NUMBER ,
           p_amt_of_cess                  IN  NUMBER  ,
           p_deductee_total_tax_deducted  IN  NUMBER,
           p_base_taxabale_amount         IN  NUMBER,
           p_gl_date                      IN  DATE ,
           p_book_ent_oth                 IN  VARCHAR2,
           p_return_code                  OUT NOCOPY VARCHAR2,
           p_return_message               OUT NOCOPY VARCHAR2
         ) ;

         PROCEDURE check_numeric
         (p_variable IN VARCHAR2 ,
          p_err      IN VARCHAR2 ,
          p_action   IN VARCHAR2
         ) ;

  /* Functional Related Procedures */

    PROCEDURE quarterly_returns(
      p_err_buf OUT NOCOPY VARCHAR2,
      p_ret_code OUT NOCOPY NUMBER,
     -- p_legal_entity_id   IN NUMBER, --commented by csahoo for bug#6158875
     -- p_profile_org_id    IN NUMBER, --commented by csahoo for bug#6158875
      p_tan_number      IN VARCHAR2,
      p_fin_year        IN NUMBER,
      p_period          IN VARCHAR2,
      p_tax_authority_id    IN NUMBER,
      p_tax_authority_site_id IN NUMBER,
      p_organization_id   IN NUMBER,
      p_deductor_name     IN VARCHAR2,
      p_deductor_state    IN VARCHAR2,
      p_addrChangedSinceLastRet IN VARCHAR2,
      --p_deductor_status   IN VARCHAR2, /*Bug 8880543 - Coomented for eTDS/eTCS FVU Changes*/
      p_persRespForDeduction  IN VARCHAR2,
      p_desgOfPersResponsible IN VARCHAR2,
      p_RespPers_flat_no IN VARCHAR2 , -- Bug 6007891
      p_RespPers_prem_bldg IN VARCHAR2 , -- Bug 6007891
      p_RespPers_rd_st_lane IN VARCHAR2 , -- Bug 6007891
      p_RespPers_area_loc IN VARCHAR2 , -- Bug 6007891
      p_RespPers_tn_cty_dt IN VARCHAR2 , -- Bug 6007891
      p_RespPersState IN VARCHAR2 ,
      p_RespPersPin IN NUMBER ,
      p_RespPers_tel_no IN VARCHAR2 , -- Bug 6007891
      p_RespPers_email IN VARCHAR2 , -- Bug 6007891
      p_RespPersAddrChange IN VARCHAR2,
      p_challan_Start_Date  IN VARCHAR2,  --changed the datatype by csahoo for bug#6158875
      p_challan_End_Date    IN VARCHAR2,	--changed the datatype by csahoo for bug#6158875
      p_pro_rcpt_num_org_ret IN NUMBER,
      p_file_path       IN VARCHAR2,
      p_filename        IN VARCHAR2,
      p_action          IN VARCHAR2 DEFAULT NULL ,
      p_include_list    IN VARCHAR2, --Date 11-05-2007 by Sacsethi for bug 5647248
      p_exclude_list    IN VARCHAR2

    ) ;

    PROCEDURE yearly_returns(
      p_err_buf OUT NOCOPY VARCHAR2,
      p_ret_code OUT NOCOPY NUMBER,
     -- p_legal_entity_id   IN NUMBER,  --commented by csahoo for bug#6158875
      --p_profile_org_id    IN NUMBER,	--commented by csahoo for bug#6158875
      p_tan_number      IN VARCHAR2,
      p_fin_year        IN NUMBER,
      p_organization_id   IN NUMBER,
      p_tax_authority_id    IN NUMBER,
      p_tax_authority_site_id IN NUMBER,
      p_deductor_name     IN VARCHAR2,
      p_deductor_state    IN VARCHAR2,
      p_addrChangedSinceLastRet IN VARCHAR2,
      p_deductor_status   IN VARCHAR2,
      p_persRespForDeduction  IN VARCHAR2,
      p_desgOfPersResponsible IN VARCHAR2,
      p_challan_Start_Date  IN VARCHAR2,  --changed the datatype by csahoo for bug#6158875
      p_challan_End_Date    IN VARCHAR2,	--changed the datatype by csahoo for bug#6158875
      --p_pro_rcpt_num_org_ret IN NUMBER,  --commented by csahoo for bug#6158875
      p_file_path       IN VARCHAR2,
      p_filename        IN VARCHAR2,
      p_generate_headers    IN VARCHAR2 DEFAULT NULL
    );
    -- ended, Harshita for Bug 4525089


  PROCEDURE generate_etds_returns
  (
      p_err_buf		OUT NOCOPY VARCHAR2,
      p_ret_code	OUT NOCOPY NUMBER,
      p_tan_number      IN VARCHAR2,
      p_fin_year        IN NUMBER,
      p_organization_id   IN NUMBER, -- Harshita for Bug 4889272
      p_tax_authority_id    IN NUMBER,
      p_tax_authority_site_id IN NUMBER,
      p_deductor_name     IN VARCHAR2,
      p_deductor_state    IN VARCHAR2,
      p_addrChangedSinceLastRet IN VARCHAR2,
      --p_deductor_status   IN VARCHAR2, /*Bug 8880543 - Coomented for eTDS/eTCS FVU Changes*/
      p_persRespForDeduction  IN VARCHAR2,
      p_desgOfPersResponsible IN VARCHAR2,
      pv_challan_Start_Date  IN VARCHAR2, /* rallamse for bu# 4334682 changed to varchar2 from date */
      pv_challan_End_Date    IN VARCHAR2, /* rallamse for bu# 4334682 changed to varchar2 from date */
      p_pro_rcpt_num_org_ret IN NUMBER,
      p_file_path       IN VARCHAR2,
      p_filename        IN VARCHAR2,
      p_generate_headers    IN VARCHAR2 DEFAULT NULL,
      p_period               IN VARCHAR2 DEFAULT NULL,
      p_RespPers_flat_no IN VARCHAR2 DEFAULT NULL, -- Bug 6007891
	  p_RespPers_prem_bldg IN VARCHAR2 DEFAULT NULL, -- Bug 6007891
	  p_RespPers_rd_st_lane IN VARCHAR2 DEFAULT NULL, -- Bug 6007891
	  p_RespPers_area_loc IN VARCHAR2 DEFAULT NULL, -- Bug 6007891
	  p_RespPers_tn_cty_dt IN VARCHAR2 DEFAULT NULL, -- Bug 6007891
      p_RespPersState        IN VARCHAR2 DEFAULT NULL,
      p_RespPersPin          IN NUMBER   DEFAULT NULL,
      p_RespPers_tel_no IN VARCHAR2 DEFAULT NULL, -- Bug 6007891
	  p_RespPers_email IN VARCHAR2 DEFAULT NULL, -- Bug 6007891
      p_RespPersAddrChange   IN VARCHAR2 DEFAULT NULL,
      p_action               IN VARCHAR2 DEFAULT NULL,
      p_form_number          IN VARCHAR2 DEFAULT NULL,     --Date 11-05-2007 by Sacsethi for bug 5647248
      p_include_list         IN VARCHAR2 DEFAULT NULL,
      p_exclude_list         IN VARCHAR2 DEFAULT NULL

   ) ;


END jai_ap_tds_etds_pkg;

/
