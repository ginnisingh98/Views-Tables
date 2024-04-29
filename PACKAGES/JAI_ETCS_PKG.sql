--------------------------------------------------------
--  DDL for Package JAI_ETCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_ETCS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ar_etcs_prc.pls 120.2.12010000.3 2009/09/23 11:32:34 mbremkum ship $ */

/***************************************************************************************************
CREATED BY       : CSahoo
CREATED DATE     : 01-FEB-2007
ENHANCEMENT BUG  : 5631784
PURPOSE          : NEW ENH: TAX COLLECTION AT SOURCE IN RECEIVABLES


-- #
-- # Change History -


1.  01/02/2007   CSahoo for bug#5631784. File Version 120.0
		 Forward Porting of 11i BUG#4742259 (TAX COLLECTION AT SOURCE IN RECEIVABLES)

2.  26.06.2007  sacsethi for bug 6153881 file version 120.2

		Problem - R12RUP03-ST1:UNABLE TO RUN TCS RETURN REPORTS

		Solution - According to R12 Standard we should not use legal entity in out code , so
		           removing legal_entity_id from code ...

*******************************************************************************************************/

  -- debug variables
  v_pad_date              VARCHAR2(1) := ' ';
  v_pad_char              VARCHAR2(1) := ' ';
  v_pad_number            VARCHAR2(1) := '0';

  -- File Header Size Variables
  s_line_number           NUMBER(2) := 9;
  s_record_type           NUMBER(2) := 2;
  s_file_type             NUMBER(2) := 3;
  s_upload_type           NUMBER(2) := 1;
  s_file_sequence_number  NUMBER(2) := 9;
  s_deductor_tan          NUMBER(2) := 10;
  s_number_of_batches     NUMBER(2) := 9;
  v_underline_char        VARCHAR2(1) := '-';

  -- Challan Detail
  s_batch_number          NUMBER(2) := 9;
  s_challan_slno          NUMBER(2) := 9;
  s_challan_section       NUMBER(2) := 5;
  s_amount_deducted       NUMBER(2) := 14;
  s_amount_sur            NUMBER(2) := 14;
  s_amount_cess           NUMBER(2) := 14;
  s_amount_tcs            NUMBER(2) := 14;
  s_chq_dd_num            NUMBER(2) := 14;
  s_challan_num           NUMBER(2) := 9;
  s_bank_branch_code      NUMBER(2) := 7;
  s_tds_dep_book_ent      NUMBER(2) := 1;
  s_filler4               NUMBER(2) := 1;

  -- Deductee Detail
  s_deductee_slno         NUMBER(2) := 9;
  s_deductee_section      NUMBER(2) := 5;
  s_deductee_code         NUMBER(2) := 2;
  s_deductee_pan          NUMBER(2) := 10;
  s_deductee_name         NUMBER(2) := 75;
  s_deductee_address1     NUMBER(2) := 25;
  s_deductee_address2     NUMBER(2) := 25;
  s_deductee_address3     NUMBER(2) := 25;
  s_deductee_address4     NUMBER(2) := 25;
  s_deductee_address5     NUMBER(2) := 25;
  s_deductee_state        NUMBER(2) := 2;
  s_deductee_pin          NUMBER(2) := 6;
  s_payment_amount        NUMBER(2) := 14;
  s_tax_rate              NUMBER(2) := 4;
  s_grossing_up_factor    NUMBER(2) := 1;
  s_tax_deducted          NUMBER(2) := 14;
  s_challan_no            NUMBER(2) := 9;
  s_reason_for_nDeduction NUMBER(2) := 1;
  s_filler                NUMBER(2) := 14;
  s_filler6               NUMBER(2) := 1;
  s_book_ent_oth          NUMBER(2) := 1;
  s_date                  NUMBER(1) := 8;


  ---ADDED BY VASAVI---
  G_DATE_DUMMY CONSTANT VARCHAR2(1) := '-';
  v_delimeter       VARCHAR2(1) := '^' ;
  v_quart_len       NUMBER := 15 ;

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
  sq_len_150        NUMBER :=150  ; /*Bug 8880543 - Added length 150*/

  v_quart_pad       VARCHAR2(1) := ' ';
  v_q_noval_filler  VARCHAR2(1) := '-';
  v_q_null_filler   VARCHAR2(1) := '*';
  v_quart_numfill   NUMBER      := 0 ;
  v_format_amount   VARCHAR2(17)  := 'FM999999999990D00' ;
  v_format_rate     VARCHAR2(9)   := 'FM90D0000';
  ln_batch_id       NUMBER ;
  lv_action         VARCHAR2(1) ;


  PROCEDURE openFile(
          p_directory IN VARCHAR2,
          p_filename IN VARCHAR2
  ) ;

  PROCEDURE closeFile ;

  PROCEDURE create_fh(p_batch_id IN NUMBER) ;

  PROCEDURE create_quarterly_fh
         (p_batch_id IN NUMBER,
          p_period   IN VARCHAR2,
          p_RespPersAddress IN VARCHAR2,
          p_RespPersState IN VARCHAR2,
          p_RespPersPin IN NUMBER,
          p_RespPersAddrChange IN VARCHAR2
         );


  PROCEDURE generate_etcs_returns(
    p_err_buf OUT NOCOPY            VARCHAR2,
    p_ret_code OUT NOCOPY           NUMBER,
    p_tan_number                    IN VARCHAR2,
    p_organization_id               IN NUMBER,
    p_fin_year                      IN NUMBER,
    p_tax_authority_id              IN NUMBER,
    p_tax_authority_site_id         IN NUMBER,
    p_seller_name                 IN VARCHAR2,
    p_seller_state                IN VARCHAR2,
    p_addrChangedSinceLastRet       IN VARCHAR2,
    p_persRespForCollection          IN VARCHAR2,
    p_desgOfPersResponsible         IN VARCHAR2,
    p_Start_Date                    IN DATE,
    p_End_Date                      IN DATE,
    p_pro_rcpt_num_org_ret          IN NUMBER,
    p_file_path                     IN VARCHAR2,
    p_filename                      IN VARCHAR2,
    p_collection_code               IN VARCHAR2,
    p_generate_headers              IN VARCHAR2 DEFAULT NULL,
    p_period                        IN VARCHAR2 DEFAULT NULL,
    p_RespPersAddress               IN VARCHAR2 DEFAULT NULL,
    p_RespPersState                 IN VARCHAR2 DEFAULT NULL,
    p_RespPersPin                   IN NUMBER   DEFAULT NULL,
    p_RespPersAddrChange            IN VARCHAR2 DEFAULT NULL,
    p_action                        IN VARCHAR2 DEFAULT NULL
    --p_collector_status              IN VARCHAR2 DEFAULT NULL
    ) ;

    PROCEDURE yearly_returns
     (
      p_err_buf OUT NOCOPY      VARCHAR2,
      p_ret_code OUT NOCOPY     NUMBER,
      p_tan_number              IN VARCHAR2,
      p_organization_id         IN NUMBER,
      p_fin_year                IN NUMBER,
      p_collection_code         IN VARCHAR2,
      p_tax_authority_id        IN NUMBER,
      p_tax_authority_site_id   IN NUMBER,
      p_seller_name           IN VARCHAR2,
      p_seller_state          IN VARCHAR2,
      p_addrChangedSinceLastRet IN VARCHAR2,
      p_persRespForCollection    IN VARCHAR2,
      p_desgOfPersResponsible   IN VARCHAR2,
      p_start_date      IN VARCHAR2,
      p_end_date        IN VARCHAR2,
      p_pro_rcpt_num_org_ret    IN NUMBER,
      p_file_path               IN VARCHAR2,
      p_filename                IN VARCHAR2,
      p_generate_headers        IN VARCHAR2 DEFAULT 'N'
     ) ;

   PROCEDURE quarterly_returns
     (
      p_err_buf OUT NOCOPY      VARCHAR2,
      p_ret_code OUT NOCOPY     NUMBER,
      p_tan_number              IN VARCHAR2,
      p_organization_id         IN NUMBER,
      p_fin_year                IN NUMBER,
      p_period                  IN VARCHAR2 ,
      p_collection_code         IN VARCHAR2,
      p_tax_authority_id        IN NUMBER,
      p_tax_authority_site_id   IN NUMBER,
      p_seller_name           IN VARCHAR2,
      p_seller_state          IN VARCHAR2,
      p_addrChangedSinceLastRet IN VARCHAR2,
      --p_collector_status        IN VARCHAR2, /*Bug 8880543 - Commented for eTDS/eTCS FVU Changes*/
      p_persRespForCollection    IN VARCHAR2,
      p_desgOfPersResponsible   IN VARCHAR2,
      p_RespPersAddress  IN VARCHAR2 ,
      p_RespPersState    IN VARCHAR2 ,
      p_RespPersPin      IN VARCHAR2 ,
      p_RespPersAddrChange  IN VARCHAR2,
      p_start_date      IN VARCHAR2,
      p_end_date        IN VARCHAR2,
      p_pro_rcpt_num_org_ret    IN NUMBER,
      p_file_path               IN VARCHAR2,
      p_filename                IN VARCHAR2,
      p_action           IN VARCHAR2
     ) ;
END jai_etcs_pkg;

/
