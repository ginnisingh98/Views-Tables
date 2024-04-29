--------------------------------------------------------
--  DDL for Package Body JAI_ETCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_ETCS_PKG" AS
/* $Header: jai_ar_etcs_prc.plb 120.6.12010000.7 2009/09/25 10:24:28 mbremkum ship $ */



/***************************************************************************************************
CREATED BY       : CSahoo
CREATED DATE     : 01-FEB-2007
ENHANCEMENT BUG  : 5631784
PURPOSE          : NEW ENH: TAX COLLECTION AT SOURCE IN RECEIVABLES

-- #
-- # Change History -


1.  01/02/2007   CSahoo for bug#5631784. File Version 120.0
		 Forward Porting of 11i BUG#4742259 (TAX COLLECTION AT SOURCE IN RECEIVABLES)

                 Column name org_tan_num is renamed to org_tan_no. So the change is propogated into this
                 package.
                 File name changed to jai_ar_etcs_prc.plb
                 Removed the Hard Coded values and replaced them with the
                 constants jai_constants.ar_cash_tax_confirmed and jai_constants.trx_type_inv_comp
2. 14/05/2007	bduvarag for bug#5631784. File Version 120.1
		Removed local_fnd_global

3.  26.06.2007  sacsethi for bug 6153881 file version 120.2

		Problem - R12RUP03-ST1:UNABLE TO RUN TCS RETURN REPORTS

		Solution - According to R12 Standard we should not use legal entity in out code , so
		           removing legal_entity_id from code ...

4.  28/06/2007  sacsethi for bug 6157120 File version 120.5

		R12RUP03-ST1:ETCS REPORT RUNS INTO ERROR

		Code Fix -

		     1.  Table insertion JAI_AP_ETDS_REQUESTS , Missing Data related to WHO Columns
		     2.  cursor c_pan_number is changed to get pan no .
		     3.  Cursor c_fin_year , Tan_number datatype changed from number to varchar2
		     4.  Cursor c_check_dtls ,c_bank_branch_code is changed

			 Problem - Table used under this cursor has been obsuleted in R12
			           we should not use ap_check_all , ap_bank_branches etc.

                     5. In File jai_constants.pls - Two variable is used pan_no , accounting_information  to Avoid Hard coding of these information.

4.  03/07/2007  sacsethi for bug 6157120 File version 120.6

		R12RUP03-ST1:ETCS REPORT RUNS INTO ERROR

		Problem - SH Cess FP missing

		Code Fix -

		     1. SHE Cess also added in CESS amount .

		     Previous Formula -
		              cess_amount := tcs_cess_amount + sur_cess_amount

		     New Formula -
		              cess_amount := tcs_cess_amount + sur_cess_amount + tcs_sh_cess_amount

5.  22-SEP-2009 Bug 8880543
                Added for eTDS/eTCS FVU changes.

*****************************************************************************************************/

  /*Bug 8880543 - Changes for eTDS/eTCS FVU Changes - Start*/

  FUNCTION VALIDATE_ALPHA_NUMERIC(p_str VARCHAR2, p_length NUMBER) RETURN VARCHAR2 IS
  lv_resp     VARCHAR2(10);
  BEGIN
 	FOR i in
   	  (SELECT TRANSLATE(UPPER(substr(p_str, 1, 5)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','AAAAAAAAAAAAAAAAAAAAAAAAAA') src_str1,
                  TRANSLATE(substr(p_str, 6, 4),'0123456789','0000000000') src_str2,
                  TRANSLATE(UPPER(substr(p_str, 10, 1)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','AAAAAAAAAAAAAAAAAAAAAAAAAA') src_str3,
                  'AAAAA0000A' dest_str
 	   FROM 	 dual) LOOP

 		IF (i.src_str1 || i.src_str2 || i.src_str3) = i.dest_str or p_str = 'PANNOTREQD' then
 		  lv_resp := 'VALID';
 		ELSE
 		  lv_resp := 'INVALID';
 		END IF;

 	  EXIT;
 	END LOOP;

    RETURN lv_resp;
  END;

  PROCEDURE chk_err (p_err IN VARCHAR2,
                       p_message IN VARCHAR2) IS
  BEGIN
    IF (p_err = 'E') THEN
        FND_FILE.put_line(FND_FILE.log, p_message);
        RAISE_APPLICATION_ERROR(-20099, p_message, true);
    ELSIF  (p_err in ('N', 'S')) THEN
        FND_FILE.put_line(FND_FILE.log, p_message);
    END IF;
  END chk_err;

  PROCEDURE get_attr_value (p_org_id IN NUMBER,
                            p_attr_code IN VARCHAR2,
                            p_attr_val OUT NOCOPY VARCHAR2,
                            p_err OUT NOCOPY VARCHAR2,
                            p_return_message OUT NOCOPY VARCHAR2
                            ) IS

  CURSOR c_org_exists (p_org_id NUMBER)
  IS
  select '1'
  from jai_rgm_definitions jrd,
       jai_rgm_parties jrp
  where jrd.regime_code = 'TCS'
  and   jrd.regime_id = jrp.regime_id
  and   jrp.organization_id = p_org_id;

  CURSOR c_party_setup (p_attr_code VARCHAR2, p_org_id NUMBER)
  IS
  select jrpr.attribute_value
  from jai_rgm_parties jrp,
       jai_rgm_definitions jrd,
       jai_rgm_party_regns jrpr,
       jai_rgm_registrations jrr
  where jrd.regime_code = 'TCS'
  and jrd.regime_id = jrp.regime_id
  and jrp.regime_org_id = jrpr.regime_org_id
  and jrr.attribute_code = p_attr_code
  and jrp.organization_id = p_org_id
  and jrr.registration_id = jrpr.registration_id;

  CURSOR c_regime_setup (p_attr_code VARCHAR2)
  IS
  select jrr.attribute_value
  from jai_rgm_definitions jrd,
       jai_rgm_registrations jrr
  where jrd.regime_code = 'TCS'
  and jrd.regime_id = jrr.regime_id
  and jrr.attribute_code = p_attr_code;

  l_org_exists NUMBER;
  l_attr_val   VARCHAR2(240);

  BEGIN

    l_org_exists := 0;
    l_attr_val := NULL;

    OPEN c_org_exists (p_org_id);
    FETCH c_org_exists INTO l_org_exists;
    CLOSE c_org_exists;

    IF (l_org_exists = 0) THEN
        p_return_message := 'Regime Registration Setup does not exist for the current Organization';
        p_err := 'E';
        p_attr_val := NULL;
        return;
    END IF;

    OPEN c_party_setup (p_attr_code, p_org_id);
    FETCH c_party_setup INTO l_attr_val;
    CLOSE c_party_setup;

    IF (l_attr_val IS NULL) THEN
        OPEN c_regime_setup (p_attr_code);
        FETCH c_regime_setup INTO l_attr_val;
        CLOSE c_regime_setup;
    END IF;

    IF (l_attr_val IS NULL) THEN
        p_return_message := 'Attribute ' || p_attr_code || ' is not defined';
        p_err := 'N';
        p_attr_val := NULL;
        return;
    ELSE
        p_attr_val := l_attr_val;
        p_return_message := 'Attribute ' || p_attr_code || ' = ' || p_attr_val;
        p_err := 'S';
    END IF;

  END get_attr_value;

  /*Bug 8880543 - Changes for eTDS/eTCS FVU Changes - End*/


  PROCEDURE openFile(
          p_directory IN VARCHAR2,
          p_filename IN VARCHAR2
  ) IS

  BEGIN

          jai_ap_tds_etds_pkg.v_filehandle := UTL_FILE.fopen(p_directory, p_filename, 'W', 2000);
          jai_ap_tds_etds_pkg.v_utl_file_dir  := p_directory;
          jai_ap_tds_etds_pkg.v_utl_file_name := p_filename;

  END openFile;

  PROCEDURE closeFile IS
  BEGIN
          UTL_FILE.fclose(jai_ap_tds_etds_pkg.v_filehandle);
  END closeFile;

  -- Date Population procedures for ETCS Quarterly Returns
  PROCEDURE create_quarterly_fh(
          p_batch_id IN NUMBER,
          p_period   IN VARCHAR2,
          p_RespPersAddress IN VARCHAR2,
          p_RespPersState IN VARCHAR2,
          p_RespPersPin IN NUMBER,
          p_RespPersAddrChange IN VARCHAR2
  ) IS
    v_req   JAI_AP_ETDS_REQUESTS%rowtype;
  BEGIN

     SELECT * INTO v_req FROM JAI_AP_ETDS_REQUESTS WHERE batch_id = p_batch_id;
         UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle, 'Input Parameters to this Request:');
         UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle, '-------------------------------------------------');
         UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
                              '  batch_id                   ->'||v_req.batch_id||fnd_global.local_chr(10)
                            ||'  request_id                 ->'||v_req.request_id||fnd_global.local_chr(10)
                            ||'  operating_unit_id          ->'||v_req.operating_unit_id||fnd_global.local_chr(10)
                            ||'  org_tan_number             ->'||v_req.org_tan_number||fnd_global.local_chr(10)
                            ||'  financial_year             ->'||v_req.financial_year||fnd_global.local_chr(10)
                            ||'  tax_authority_id           ->'||v_req.tax_authority_id||fnd_global.local_chr(10)
                            ||'  tax_authority_site_id      ->'||v_req.tax_authority_site_id||fnd_global.local_chr(10)
                            ||'  organization_id            ->'||v_req.organization_id||fnd_global.local_chr(10)
                            ||'  collector_name              ->'||v_req.deductor_name||fnd_global.local_chr(10)
                            ||'  collector_state             ->'||v_req.deductor_state||fnd_global.local_chr(10)
                            ||'  addr_changed_since_last_ret->'||v_req.addr_changed_since_last_ret||fnd_global.local_chr(10)
                            ||'  collector_status            ->'||v_req.deductor_status||fnd_global.local_chr(10)
                            ||'  person_resp_for_collection  ->'||v_req.person_resp_for_deduction||fnd_global.local_chr(10)
                            ||'  designation_of_pers_resp   ->'||v_req.designation_of_pers_resp||fnd_global.local_chr(10)
                            ||'  challan_start_date         ->'||v_req.challan_start_date||fnd_global.local_chr(10)
                            ||'  challan_end_date           ->'||v_req.challan_end_date||fnd_global.local_chr(10)
                            ||'  file_path                  ->'||v_req.file_path||fnd_global.local_chr(10)
                            ||'  filename                   ->'||v_req.filename||fnd_global.local_chr(10)
                            ||'  Period                     ->'||p_period||fnd_global.local_chr(10)
                            ||'  RespPerson''s Address      ->'||p_RespPersAddress||fnd_global.local_chr(10)
                            ||'  RespPerson''s State        ->'||p_RespPersState||fnd_global.local_chr(10)
                            ||'  RespPerson''s Pin          ->'||p_RespPersPin||fnd_global.local_chr(10)
                            ||'  RespPerson''s Addr Changed ->'||p_RespPersAddrChange||fnd_global.local_chr(10)
                      );

    UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
          LPAD('Line No', sq_len_9, v_quart_pad) || v_pad_char ||
          LPAD('RT', sq_len_2, v_quart_pad) || v_pad_char ||
          LPAD('FT', sq_len_4, v_quart_pad) || v_pad_char ||
          LPAD('UT', sq_len_2, v_quart_pad) || v_pad_char ||
          LPAD('FileDate', sq_len_8, v_quart_pad) || v_pad_char ||
          LPAD('SeqNo', sq_len_9, v_quart_pad) || v_pad_char ||
          LPAD('U', sq_len_1, v_quart_pad) || v_pad_char ||
          LPAD('TAN', sq_len_10, v_quart_pad) || v_pad_char ||
          LPAD('Batch Cnt', sq_len_9, v_quart_pad) || v_pad_char ||
          LPAD('Ret Prep util', sq_len_75, v_quart_pad) || v_pad_char ||  /*Bug 8880543 - Added Return Preperation Utility*/
          LPAD('RH', sq_len_2, v_quart_pad) || v_pad_char ||
          LPAD('FV', sq_len_2, v_quart_pad) || v_pad_char ||
          LPAD('FH', sq_len_2, v_quart_pad) || v_pad_char ||
          LPAD('SV', sq_len_2, v_quart_pad) || v_pad_char ||
          LPAD('SH', sq_len_2, v_quart_pad) || v_pad_char ||
          LPAD('SV', sq_len_2, v_quart_pad) || v_pad_char ||
          LPAD('SH', sq_len_2, v_quart_pad) );

    UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
          LPAD(v_underline_char, sq_len_9, v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_4, v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_8, v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_9, v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_1, v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_10,v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_9, v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_75,v_underline_char) || v_pad_char || /*Bug 8880543 - Added Return Preperation Utility*/
          LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
          LPAD(v_underline_char, sq_len_2, v_underline_char) );

  END create_quarterly_fh;

  PROCEDURE create_quarterly_bh
  IS
  BEGIN
        UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle, ' ' ) ;
        UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
                          LPAD('Line No', sq_len_9, v_quart_pad) || v_pad_char ||
                          LPAD('RT', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('Batch No', sq_len_9, v_quart_pad) || v_pad_char ||
                          LPAD('ChallCnt', sq_len_9, v_quart_pad) || v_pad_char ||
                          LPAD('FN', sq_len_4, v_quart_pad) || v_pad_char ||
                          LPAD('TT', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('BI', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('OR', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('PR', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('RN', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('RD', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('LT', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('Col TAN', sq_len_10, v_quart_pad) || v_pad_char ||
                          LPAD('F1', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('Col PAN', sq_len_10, v_quart_pad) || v_pad_char ||
                          LPAD('Ass.Yr', sq_len_6, v_quart_pad) || v_pad_char ||
                          LPAD('Fin.Yr', sq_len_6, v_quart_pad) || v_pad_char ||
                          LPAD('PD', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('Collector Name', sq_len_75, v_quart_pad) || v_pad_char ||
                          LPAD('Collector Branch', sq_len_75, v_quart_pad) || v_pad_char ||
                          LPAD('Collector Addr1', sq_len_25, v_quart_pad) || v_pad_char ||
                          LPAD('Collector Addr2', sq_len_25, v_quart_pad) || v_pad_char ||
                          LPAD('Collector Addr3', sq_len_25, v_quart_pad) || v_pad_char ||
                          LPAD('Collector Addr4', sq_len_25, v_quart_pad) || v_pad_char ||
                          LPAD('Collector Addr5', sq_len_25, v_quart_pad) || v_pad_char ||
                          LPAD('CS', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('ColPIN', sq_len_6, v_quart_pad) || v_pad_char ||
                          LPAD('Collector Email', sq_len_75, v_quart_pad) || v_pad_char ||
                          LPAD('ColSTD', sq_len_5, v_quart_pad) || v_pad_char ||
                          LPAD('Col Phone', sq_len_10, v_quart_pad) || v_pad_char ||
                          LPAD('C', sq_len_1, v_quart_pad) || v_pad_char ||
                          LPAD('T', sq_len_1, v_quart_pad) || v_pad_char ||
                          LPAD('RespPerson Name', sq_len_75, v_quart_pad) || v_pad_char ||
                          LPAD('RespPerson Desg', sq_len_20, v_quart_pad) || v_pad_char ||
                          LPAD('RespPerson Addr1', sq_len_25, v_quart_pad) || v_pad_char ||
                          LPAD('RespPerson Addr2', sq_len_25, v_quart_pad) || v_pad_char ||
                          LPAD('RespPerson Addr3', sq_len_25, v_quart_pad) || v_pad_char ||
                          LPAD('RespPerson Addr4', sq_len_25, v_quart_pad) || v_pad_char ||
                          LPAD('RespPerson Addr5', sq_len_25, v_quart_pad) || v_pad_char ||
                          LPAD('RS', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('ResPIN', sq_len_6, v_quart_pad) || v_pad_char ||
                          LPAD('RespPerson Email', sq_len_75, v_quart_pad) || v_pad_char ||
                          LPAD('Remark', sq_len_75, v_quart_pad) || v_pad_char ||
                          LPAD('ResSTD', sq_len_5, v_quart_pad) || v_pad_char ||
                          LPAD('ResPhone', sq_len_10, v_quart_pad) || v_pad_char ||
                          LPAD('C', sq_len_1, v_quart_pad) || v_pad_char ||
                          LPAD('TotChallanTax', sq_len_15, v_quart_pad) || v_pad_char ||
                          LPAD('TC', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('SC', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('GT', sq_len_2, v_quart_pad) || v_pad_char ||
                          LPAD('A', sq_len_1, v_quart_pad) || v_pad_char ||
                          LPAD('AO Approval No', sq_len_15, v_quart_pad) || v_pad_char ||
                          /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
                          LPAD('L', sq_len_1, v_quart_pad)  || v_pad_char ||
                          LPAD('SN', sq_len_2, v_quart_pad)  || v_pad_char ||
                          LPAD('PAO Code', sq_len_20, v_quart_pad)  || v_pad_char ||
                          LPAD('DDO Code', sq_len_20, v_quart_pad)  || v_pad_char ||
                          LPAD('MN', sq_len_3, v_quart_pad)  || v_pad_char ||
                          LPAD('Ministry Name Other', sq_len_150, v_quart_pad)  || v_pad_char ||
                          LPAD('F2', sq_len_12, v_quart_pad)  || v_pad_char ||
                          LPAD('PAORgNo', sq_len_7, v_quart_pad)  || v_pad_char ||
                          LPAD('DDORgNo', sq_len_10, v_quart_pad)  || v_pad_char ||
                          /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
                          LPAD('RH', sq_len_2, v_quart_pad) );

           UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
                            LPAD(v_underline_char, sq_len_9,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_9,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_9,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_4,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_10,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_10,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_6,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_6,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_75,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_75,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_6,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_75,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_5,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_10,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_1,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_1,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_75,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_20,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_6,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_75,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_75,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_5,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_10,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_1,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_15,  v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_1,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_15,  v_underline_char) || v_pad_char ||
                            /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
                            LPAD(v_underline_char, sq_len_1,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_20,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_20,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_3,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_150,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_12,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_7,   v_underline_char) || v_pad_char ||
                            LPAD(v_underline_char, sq_len_10,   v_underline_char) || v_pad_char ||
                            /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
                            LPAD(v_underline_char, sq_len_2,   v_underline_char) );

  END create_quarterly_bh;

  PROCEDURE create_quarterly_cd
  IS
  BEGIN
          UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle, ' ' ) ;
          UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
          LPAD('Line No', sq_len_9  , v_quart_pad) || v_pad_char ||
          LPAD('RT', sq_len_2  , v_quart_pad) || v_pad_char ||
          LPAD('Batch No', sq_len_9  , v_quart_pad) || v_pad_char ||
          LPAD('Chall No', sq_len_9  , v_quart_pad) || v_pad_char ||
          LPAD('Collect Cnt', sq_len_9  , v_quart_pad) || v_pad_char ||
          LPAD('I', sq_len_1  , v_quart_pad) || v_pad_char ||
          LPAD('U', sq_len_2  , v_quart_pad) || v_pad_char ||
          LPAD('F2', sq_len_2  , v_quart_pad) || v_pad_char ||
          LPAD('F3', sq_len_2  , v_quart_pad) || v_pad_char ||
          LPAD('F4', sq_len_2  , v_quart_pad) || v_pad_char ||
          LPAD('LC', sq_len_2  , v_quart_pad) || v_pad_char ||
          LPAD('Ch', sq_len_5  , v_quart_pad) || v_pad_char ||
          LPAD('LV', sq_len_2  , v_quart_pad) || v_pad_char ||
          LPAD('TrnsVouch', sq_len_9  , v_quart_pad) || v_pad_char ||
          LPAD('LB', sq_len_2  , v_quart_pad) || v_pad_char ||
          LPAD('Bank Br', sq_len_7  , v_quart_pad) || v_pad_char ||
          LPAD('LD', sq_len_2  , v_quart_pad) || v_pad_char ||
          LPAD('CH. Date', sq_len_8  , v_quart_pad) || v_pad_char ||
          LPAD('F5', sq_len_2  , v_quart_pad) || v_pad_char ||
          LPAD('F6', sq_len_2  , v_quart_pad) || v_pad_char ||
          LPAD('Sec', sq_len_3  , v_quart_pad) || v_pad_char ||
          LPAD('Oltas Tax', sq_len_15  , v_quart_pad) || v_pad_char ||
          LPAD('Oltas Sur', sq_len_15  , v_quart_pad) || v_pad_char ||
          LPAD('Oltas Cess', sq_len_15  , v_quart_pad) || v_pad_char ||
          LPAD('Oltas Interest', sq_len_15  , v_quart_pad) || v_pad_char ||
          LPAD('Oltas OtherAmt', sq_len_15  , v_quart_pad) || v_pad_char ||
          LPAD('Total Deposit', sq_len_15  , v_quart_pad) || v_pad_char ||
          LPAD('LD', sq_len_2  , v_quart_pad) || v_pad_char ||
          LPAD('TotTax Deposit', sq_len_15  , v_quart_pad) || v_pad_char ||
          LPAD('TCS Income Tax', sq_len_15  , v_quart_pad) || v_pad_char ||
          LPAD('TCS Surcharge', sq_len_15  , v_quart_pad) || v_pad_char ||
          LPAD('TCS Cess', sq_len_15  , v_quart_pad) || v_pad_char ||
          LPAD('Total TCS ', sq_len_15  , v_quart_pad) || v_pad_char ||
          LPAD('TDS Interest', sq_len_15  , v_quart_pad) || v_pad_char ||
          LPAD('TCS OtherAmt', sq_len_15  , v_quart_pad) || v_pad_char ||
          LPAD('Cheque/DD', sq_len_15  , v_quart_pad) || v_pad_char ||
          LPAD('B', sq_len_1  , v_quart_pad) || v_pad_char ||
          LPAD('Remarks', sq_len_14  , v_quart_pad) || v_pad_char ||
          LPAD('RH', sq_len_2  , v_quart_pad)
          );

         UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
         LPAD(v_underline_char , sq_len_9   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_9   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_9   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_9   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_1   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_5   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_9   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_7   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_8   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_3   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_1   , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_14  , v_underline_char) || v_pad_char ||
         LPAD(v_underline_char , sq_len_2   , v_underline_char)
         );

  END create_quarterly_cd;

  PROCEDURE create_quarterly_dd IS
        BEGIN
           UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle, ' ' ) ;
           UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
           LPAD('Line No', sq_len_9, v_quart_pad)  || v_pad_char ||
           LPAD('RT', sq_len_2, v_quart_pad)  || v_pad_char ||
           LPAD('Batch No', sq_len_9, v_quart_pad)  || v_pad_char ||
           LPAD('ChallNo', sq_len_9, v_quart_pad)  || v_pad_char ||
           LPAD('ColRecNo', sq_len_9, v_quart_pad)  || v_pad_char ||
           LPAD('M', sq_len_1, v_quart_pad)  || v_pad_char ||
           LPAD('EN', sq_len_2, v_quart_pad)  || v_pad_char ||
           LPAD('C', sq_len_1, v_quart_pad)  || v_pad_char ||
           LPAD('LP', sq_len_2, v_quart_pad)  || v_pad_char ||
           LPAD('Prt Pan', sq_len_10, v_quart_pad)  || v_pad_char ||
           LPAD('LP', sq_len_2, v_quart_pad)  || v_pad_char ||
           LPAD('PAN Ref No', sq_len_10, v_quart_pad)  || v_pad_char ||
           LPAD('Party Name', sq_len_75, v_quart_pad)  || v_pad_char ||
           LPAD('TCS Income Tax ', sq_len_15, v_quart_pad)  || v_pad_char ||
           LPAD('TCS Surcharge', sq_len_15, v_quart_pad)  || v_pad_char ||
           LPAD('TCS Cess', sq_len_15, v_quart_pad)  || v_pad_char ||
           LPAD('TCS Total', sq_len_15, v_quart_pad)  || v_pad_char ||
           LPAD('LT', sq_len_2, v_quart_pad)  || v_pad_char ||
           LPAD('TotTax Deposit', sq_len_15, v_quart_pad)  || v_pad_char ||
           LPAD('LT', sq_len_2, v_quart_pad)  || v_pad_char ||
           LPAD('TP', sq_len_15, v_quart_pad)  || v_pad_char ||
           LPAD('Payment Amt', sq_len_15, v_quart_pad)  || v_pad_char ||
           LPAD('Pay Dt', sq_len_8, v_quart_pad)  || v_pad_char ||
           LPAD('TaxColDt', sq_len_8, v_quart_pad)  || v_pad_char ||
           LPAD('DD', sq_len_2, v_quart_pad)  || v_pad_char ||
           LPAD('Tax Rt', sq_len_7, v_quart_pad)  || v_pad_char ||
           LPAD('GI', sq_len_2, v_quart_pad)  || v_pad_char ||
           LPAD('B', sq_len_1, v_quart_pad)  || v_pad_char ||
           LPAD('TD', sq_len_2, v_quart_pad)  || v_pad_char ||
           LPAD('R', sq_len_75, v_quart_pad)  || v_pad_char ||
           LPAD('Remarks 2', sq_len_75, v_quart_pad)  || v_pad_char ||
           LPAD('Remarks 3', sq_len_14, v_quart_pad)  || v_pad_char ||
           LPAD('RH', sq_len_2, v_quart_pad)
           );

           UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
           LPAD(v_underline_char  , sq_len_9  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_9  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_9  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_9  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_1  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_1  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_10 , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_10 , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_75 , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_15 , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_15 , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_15 , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_15 , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_15 , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_15  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_15 , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_8  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_8  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_7  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_1  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_75  , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_75 , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_14 , v_underline_char)  || v_pad_char ||
           LPAD(v_underline_char  , sq_len_2  , v_underline_char)
           );

        END create_quarterly_dd;

   PROCEDURE validate_Party_detail
           ( p_line_number                  IN  NUMBER ,
             p_record_type                  IN  VARCHAR2,
             p_batch_number                 IN  NUMBER,
             p_challan_line_num             IN  NUMBER,
             p_party_slno                   IN  NUMBER,
             p_dh_mode                      IN  VARCHAR2,
             p_quart_party_code             IN  VARCHAR2,
             p_party_pan                    IN  VARCHAR2,
             p_party_name                   IN  VARCHAR2,
             p_tcs_amt                      IN  NUMBER,
             p_surcharge_amt                IN  NUMBER ,
             p_cess_amt                     IN  NUMBER  ,
             p_party_total_tax_deducted     IN  NUMBER,
             p_base_taxabale_amount         IN  NUMBER,
             p_gl_date                      IN  DATE ,
             p_book_ent_oth                 IN  VARCHAR2,
             p_tcs_tax_rate                 IN NUMBER,
             p_total_purchase               IN NUMBER,
             p_party_total_tax_deposit      IN NUMBER,
             p_return_code                  OUT NOCOPY VARCHAR2,
             p_return_message               OUT NOCOPY VARCHAR2
        )
    IS
    BEGIN
      IF p_line_number  IS NULL THEN
        p_return_message := p_return_message ||     '  Line Number should not be null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_record_type  IS NULL THEN
        p_return_message := p_return_message ||     '  Record Type is null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_batch_number IS NULL THEN
        p_return_message := p_return_message ||   ' Batch Number is null. '   ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_challan_line_num   IS NULL THEN
        p_return_message := p_return_message ||     '  Challan Record Number is null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_party_slno  IS NULL THEN
        p_return_message := p_return_message ||     '  Party Detail Record Number is null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_dh_mode  IS NULL THEN
        p_return_message := p_return_message ||     '  Mode is null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_quart_Party_code  IS NULL THEN
        p_return_message := p_return_message ||     '  Deductee Party Code is null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_Party_pan IS NULL THEN
        p_return_message := p_return_message ||     '  Deductee PAN is null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      /*Bug 8880543 - Added validation for PAN - Start*/
      ELSE
       IF (validate_alpha_numeric(p_Party_pan, length(p_Party_pan)) = 'INVALID') THEN
          p_return_message := p_return_message ||  ' PAN format incorrect. The first five must be alphabets, followed by four numbers, and then followed by an alphabet.'  ;
          IF lv_action <> 'V' THEN
             goto  end_of_procedure  ;
          END IF ;
       END IF;
      /*Bug 8880543 - Added validation for PAN - End*/
      END IF ;
      IF p_Party_name  IS NULL THEN
        p_return_message := p_return_message ||     '  Party Name is null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_tcs_amt  IS NULL THEN
        p_return_message := p_return_message ||     '  TCS Income Tax for the Period is null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_surcharge_amt   IS NULL THEN
        p_return_message := p_return_message ||     '  TCS Surcharge is null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_cess_amt   IS NULL THEN
        p_return_message := p_return_message ||     '  TCS Cess is null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_party_total_tax_deducted IS NULL THEN
        p_return_message := p_return_message ||     '  Total TCS  is null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_base_taxabale_amount IS NULL THEN
        p_return_message := p_return_message ||     '  Payment Amount is null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_gl_date IS NULL THEN
        p_return_message := p_return_message ||     '  Date on which Amount Credited is null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_book_ent_oth  IS NULL THEN
        p_return_message := p_return_message ||     '  Book/Cash Entry is null. '  ;
        IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_tcs_tax_rate  IS NULL THEN
         p_return_message := p_return_message ||     '  Tcs Tax Rate Is Null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_total_purchase  IS NULL THEN
         p_return_message := p_return_message ||     '  Total Purchase Amount Is Null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_party_total_tax_deposit  IS NULL THEN
         p_return_message := p_return_message ||     '  Total Tax Deposited Is Null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF lv_action = 'V' THEN
         goto  end_of_procedure  ;
      END IF ;

      <<end_of_procedure>>
      IF p_return_message IS NOT NULL THEN
         p_return_code := 'E';
         p_return_message := 'Collectee Detail Error - ' ||  p_return_message ;
      END IF;

    END validate_Party_detail ;


 PROCEDURE create_quart_party_dtl(
          p_line_number      IN NUMBER,
          p_record_type      IN VARCHAR2,
          p_batch_number     IN NUMBER,
          p_dh_challan_recNo IN NUMBER,
          p_party_slno       IN NUMBER,
          p_dh_mode          IN VARCHAR2,
          p_emp_serial_no    IN VARCHAR2,
          p_party_code       IN VARCHAR2,
          p_last_emp_pan     IN VARCHAR2,
          p_party_pan        IN VARCHAR2,
          p_last_emp_pan_refno IN VARCHAR2,
          p_party_pan_refno IN VARCHAR2,
          p_party_name      IN VARCHAR2,
          p_party_tcs_income_tax IN NUMBER,
          p_party_tcs_surcharge  IN NUMBER,
          p_party_tcs_cess       IN NUMBER,
          p_party_total_tax_deducted IN NUMBER,
          p_last_total_tax_deducted  IN VARCHAR2,
          p_party_total_tax_deposit  IN NUMBER,
          p_last_total_tax_deposit   IN VARCHAR2,
          p_total_purchase           IN NUMBER,
          p_base_taxabale_amount     IN NUMBER,
          p_gl_date                  IN DATE,
          p_tcs_invoice_date         IN DATE,
          p_deposit_date             IN VARCHAR2,
          p_tcs_tax_rate             IN NUMBER,
          p_grossingUp_ind           IN VARCHAR2,
          p_book_ent_oth             IN VARCHAR2,
          p_certificate_issue_date   IN VARCHAR2,
          p_remarks1                 IN VARCHAR2,
          p_remarks2                 IN VARCHAR2,
          p_remarks3                 IN VARCHAR2,
          p_dh_recHash               IN VARCHAR2,
          p_generate_headers         IN VARCHAR2
        )
       IS
       BEGIN
            IF p_generate_headers = 'N' THEN
              UTL_FILE.PUT_LINE( jai_ap_tds_etds_pkg.v_filehandle,
                p_line_number                                             || v_delimeter  ||
                upper(p_record_type)                                      || v_delimeter  ||
                p_batch_number                                            || v_delimeter  ||
                p_dh_challan_recNo                                        || v_delimeter  ||
                p_party_slno                                              || v_delimeter  ||
                p_dh_mode                                                 || v_delimeter  ||
                p_emp_serial_no                                           || v_delimeter  ||
                p_party_code                                              || v_delimeter  ||
                p_last_emp_pan                                            || v_delimeter  ||
                p_party_pan                                               || v_delimeter  ||
                p_last_emp_pan_refno                                      || v_delimeter  ||
                p_party_pan_refno                                         || v_delimeter  ||
                p_party_name                                              || v_delimeter  ||
                to_char( p_party_tcs_income_tax, v_format_amount)         || v_delimeter  ||
                to_char( p_party_tcs_surcharge, v_format_amount)          || v_delimeter  ||
                to_char( p_party_tcs_cess, v_format_amount)               || v_delimeter  ||
                to_char( p_party_total_tax_deducted, v_format_amount)     || v_delimeter  ||
                p_last_total_tax_deducted                                 || v_delimeter  ||
                to_char( p_party_total_tax_deposit, v_format_amount)      || v_delimeter  ||
                p_last_total_tax_deposit                                  || v_delimeter  ||
                TO_CHAR(p_total_purchase,V_FORMAT_AMOUNT)                 || v_delimeter  ||
                to_char( p_base_taxabale_amount, v_format_amount)         || v_delimeter  ||
                to_char(p_gl_date,'ddmmyyyy')                             || v_delimeter  ||
                to_char(p_tcs_invoice_date,'ddmmyyyy')                    || v_delimeter  ||
                p_deposit_date                                            || v_delimeter  ||
                to_char(p_tcs_tax_rate,'FM99D0000')                       || v_delimeter  ||
                p_grossingUp_ind                                          || v_delimeter  ||
                p_book_ent_oth                                            || v_delimeter  ||
                p_certificate_issue_date                                  || v_delimeter  ||
                p_remarks1                                                || v_delimeter  ||
                p_remarks2                                                || v_delimeter  ||
                p_remarks3                                                || v_delimeter  ||
                p_dh_recHash
              );
            ELSE
              UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
                LPAD(p_line_number  , sq_len_9, v_quart_pad) || v_pad_char ||
                LPAD(upper(p_record_type)  , sq_len_2, v_quart_pad) || v_pad_char ||
                LPAD(p_batch_number  , sq_len_9, v_quart_pad) || v_pad_char ||
                LPAD(p_dh_challan_recNo  , sq_len_9, v_quart_pad) || v_pad_char ||
                LPAD(p_party_slno  , sq_len_9, v_quart_pad) || v_pad_char ||
                LPAD(p_dh_mode  , sq_len_1, v_quart_pad) || v_pad_char ||
                LPAD(NVL(p_emp_serial_no,v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
                LPAD(p_party_code  , sq_len_1, v_quart_pad) || v_pad_char ||
                LPAD(NVL(p_last_emp_pan, v_q_noval_filler), sq_len_2, v_quart_pad) || v_pad_char ||
                LPAD(p_party_pan  , sq_len_10, v_quart_pad) || v_pad_char ||
                LPAD(NVL(p_last_emp_pan_refno,v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
                LPAD(NVL(p_party_pan_refno,v_q_null_filler)  , sq_len_10, v_quart_pad) || v_pad_char ||
                LPAD(NVL(p_party_name, v_q_null_filler) , sq_len_75, v_quart_pad) || v_pad_char ||
                LPAD(to_char( p_party_tcs_income_tax, v_format_amount)    , sq_len_15, v_quart_pad) || v_pad_char ||
                LPAD(to_char( p_party_tcs_surcharge, v_format_amount)  , sq_len_15, v_quart_pad) || v_pad_char ||
                LPAD(to_char( p_party_tcs_cess, v_format_amount)  , sq_len_15, v_quart_pad) || v_pad_char ||
                LPAD(to_char( p_party_total_tax_deducted, v_format_amount)   , sq_len_15, v_quart_pad) || v_pad_char ||
                LPAD(NVL(p_last_total_tax_deducted, v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
                LPAD(to_char( p_party_total_tax_deposit, v_format_amount) , sq_len_15, v_quart_pad) || v_pad_char ||
                LPAD(NVL(p_last_total_tax_deposit, v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
                LPAD(TO_CHAR(p_total_purchase, v_FORMAT_AMOUNT)  , sq_len_15, v_quart_pad) || v_pad_char ||
                LPAD(to_char( p_base_taxabale_amount, v_format_amount) , sq_len_15, v_quart_pad) || v_pad_char ||
                LPAD(to_char(p_gl_date,'ddmmyyyy')  , sq_len_8, v_quart_pad) || v_pad_char ||
                LPAD(NVL(to_char(p_tcs_invoice_date,'ddmmyyyy'),G_DATE_DUMMY) , sq_len_8, v_quart_pad) || v_pad_char ||  -- change later
                LPAD(NVL(p_deposit_date, v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
                LPAD( to_char(p_tcs_tax_rate,v_format_rate), sq_len_7, v_quart_pad) || v_pad_char ||
                LPAD(NVL(p_grossingUp_ind, v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
                LPAD(p_book_ent_oth  , sq_len_1, v_quart_pad) || v_pad_char ||
                LPAD(NVL(p_certificate_issue_date,v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
                LPAD(NVL(p_remarks1,v_q_null_filler)  , sq_len_75, v_quart_pad) || v_pad_char ||
                LPAD(NVL(p_remarks2,v_q_noval_filler)  , sq_len_75, v_quart_pad) || v_pad_char ||
                LPAD(NVL(p_remarks3,v_q_noval_filler)  , sq_len_14, v_quart_pad) || v_pad_char ||
                 LPAD(NVL(p_dh_recHash,v_q_noval_filler) , sq_len_2, v_quart_pad)
              );
            END IF ;

          END create_quart_party_dtl;

     PROCEDURE validate_file_header
      ( p_line_number         IN NUMBER ,
        p_record_type         IN VARCHAR2,
        p_quartfile_type      IN VARCHAR2,
        p_upload_type         IN VARCHAR2,
        p_file_creation_date  IN DATE,
        p_file_sequence_number IN NUMBER,
        p_uploader_type       IN VARCHAR2,
        p_collector_tan        IN VARCHAR2,
        p_number_of_batches   IN NUMBER,
        p_period              IN VARCHAR2,
        p_start_date  IN DATE,
        p_end_date    IN DATE,
        p_fin_year            IN NUMBER,
        p_return_prep_util    IN VARCHAR2, /*Bug 8880543 - Added for eTCS/eTDS FVU Changes*/
        p_return_code         OUT NOCOPY VARCHAR2,
        p_return_message      OUT NOCOPY VARCHAR2
      )
      IS

     lv_q1_start_date   VARCHAR2(11) ;
       lv_q1_end_date     VARCHAR2(11) ;
       lv_q2_start_date   VARCHAR2(11) ;
       lv_q2_end_date     VARCHAR2(11) ;
       lv_q3_start_date   VARCHAR2(11) ;
       lv_q3_end_date     VARCHAR2(11) ;
       lv_q4_start_date   VARCHAR2(11) ;
       lv_q4_end_date     VARCHAR2(11) ;
       ln_fin_year        NUMBER ;

      BEGIN

         IF p_line_number IS NULL THEN
           p_return_message := p_return_message ||  ' Line Number should not be null. '   ;
             IF lv_action <> 'V' THEN
               goto  end_of_procedure  ;
             END IF ;
         END IF;
         IF p_record_type IS NULL THEN
           p_return_message := p_return_message ||  ' Record Type is null. '     ;
           IF lv_action <> 'V' THEN
              goto  end_of_procedure  ;
           END IF ;
         END IF;
         IF p_quartfile_type IS NULL THEN
           p_return_message := p_return_message ||  ' File Type is null. '   ;
           IF lv_action <> 'V' THEN
              goto  end_of_procedure  ;
           END IF ;
         END IF;
         IF p_upload_type IS NULL THEN
           p_return_message := p_return_message ||  ' Upload Type is null. '    ;
           IF lv_action <> 'V' THEN
              goto  end_of_procedure  ;
           END IF ;
         END IF;
         IF p_file_creation_date IS NULL THEN
           p_return_message := p_return_message ||  ' File Creation Date is null. '    ;
           IF lv_action <> 'V' THEN
              goto  end_of_procedure  ;
           END IF ;
         END IF;
         IF p_file_sequence_number IS NULL THEN
           p_return_message := p_return_message ||  ' File Sequence No is null. '  ;
           IF lv_action <> 'V' THEN
              goto  end_of_procedure  ;
           END IF ;
         END IF;
         IF p_uploader_type IS NULL THEN
           p_return_message := p_return_message ||  ' Upload Type is null. '   ;
           IF lv_action <> 'V' THEN
              goto  end_of_procedure  ;
           END IF ;
         END IF;
         IF p_collector_tan IS NULL THEN
           p_return_message := p_return_message ||  ' Collector TAN is null. '   ;
           IF lv_action <> 'V' THEN
              goto  end_of_procedure  ;
           END IF ;
         END IF;
         IF p_number_of_batches IS NULL THEN
           p_return_message := p_return_message ||  ' Batch Count is null. '   ;
           IF lv_action <> 'V' THEN
              goto  end_of_procedure  ;
           END IF ;
         END IF;
         /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
         IF p_return_prep_util IS NULL THEN
           p_return_message := p_return_message ||  ' Return Preperation Utility is null. '   ;
           IF lv_action <> 'V' THEN
              goto  end_of_procedure  ;
           END IF ;
         END IF;
         /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/

         -- code to validate whether the given challan start and end dates fall under the specified period.
         IF p_period = 'Q1' THEN
           lv_q1_start_date := '01/04/' || p_fin_year ;
           lv_q1_end_date   := '30/06/' || p_fin_year ;

       IF not ( p_start_date >=  to_date(lv_q1_start_date,'DD/MM/YYYY') and p_end_date <=  to_date(lv_q1_end_date,'DD/MM/YYYY') ) THEN
             p_return_message := ' The given Challan Start and end dates do not fall under the specified Quarter and Year. ' ;
             goto  end_of_procedure  ;
           END IF ;
         ELSIF p_period = 'Q2' THEN
           lv_q2_start_date := '01/07/' || p_fin_year;
           lv_q2_end_date   := '30/09/' || p_fin_year;

           IF not ( p_start_date >=  to_date(lv_q2_start_date,'DD/MM/YYYY')  and p_end_date <=  to_date(lv_q2_end_date,'DD/MM/YYYY') ) THEN
              p_return_message := ' The given Challan Start and end dates do not fall under the specified Quarter and Year. '  ;
              goto  end_of_procedure  ;
           END IF ;
         ELSIF p_period = 'Q3' THEN
           lv_q3_start_date := '01/10/' || p_fin_year;
           lv_q3_end_date   := '31/12/' || p_fin_year;

           IF not ( p_start_date >=  to_date(lv_q3_start_date,'DD/MM/YYYY') and p_end_date  <=  to_date(lv_q3_end_date,'DD/MM/YYYY') ) THEN
              p_return_message := ' The given Challan Start and end dates do not fall under the specified Quarter and Year. '  ;
              goto  end_of_procedure  ;
           END IF ;
         ELSIF p_period = 'Q4' THEN
           ln_fin_year := p_fin_year + 1 ;
           lv_q4_start_date := '01/01/' || ln_fin_year;
           lv_q4_end_date   := '31/03/' || ln_fin_year;

           IF not ( p_start_date >=  to_date(lv_q4_start_date,'DD/MM/YYYY') and p_end_date <= to_date(lv_q4_end_date,'DD/MM/YYYY')  ) THEN
              p_return_message := ' The given Challan Start and end dates do not fall under the specified Quarter and Year. '  ;
              goto  end_of_procedure  ;
           END IF ;
         END IF ;

         IF lv_action = 'V' THEN
           goto  end_of_procedure  ;
         END IF ;

        <<end_of_procedure>>
        IF p_return_message IS NOT NULL THEN
          FND_FILE.put_line(FND_FILE.log,' p_return_message ' || p_return_message ) ;
          p_return_code := 'E';
          p_return_message := 'File Header Error - ' || 'Line No : ' || p_line_number || '. ' ||  p_return_message ;
        END IF;

      END validate_file_header;

      PROCEDURE create_quarterly_file_header(
               p_line_number IN NUMBER,
               p_record_type IN VARCHAR2,
               p_file_type IN VARCHAR2,
               p_upload_type IN VARCHAR2,
               p_file_creation_date IN DATE,
               p_file_sequence_number IN NUMBER,
               p_uploader_type  IN VARCHAR2,
               p_collector_tan IN VARCHAR2,
               p_number_of_batches IN NUMBER,
               p_return_prep_util  IN VARCHAR2, /*Bug 8880543 - Added for eTDS/eTCS FVU Changes*/
               p_fh_recordHash IN VARCHAR2,
               p_fh_fvuVersion IN VARCHAR2,
               p_fh_fileHash   IN VARCHAR2,
               p_fh_samVersion IN VARCHAR2,
               p_fh_samHash    IN VARCHAR2,
               p_fh_scmVersion IN VARCHAR2,
               p_fh_scmHash    IN VARCHAR2,
               p_generate_headers IN VARCHAR2
        ) IS
        BEGIN
          IF p_generate_headers = 'N' THEN

            UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
                p_line_number             ||  v_delimeter||
                upper(p_record_type)      ||  v_delimeter||
                upper(p_file_type)        ||  v_delimeter||
                upper(p_upload_type)      ||  v_delimeter||
                to_char(p_file_creation_date,'ddmmyyyy') ||  v_delimeter||
                p_file_sequence_number    ||  v_delimeter||
                upper(p_uploader_type)    ||  v_delimeter||
                p_collector_tan           ||  v_delimeter||
                p_number_of_batches       ||  v_delimeter||
                p_return_prep_util        ||  v_delimeter|| /*Bug 8880543 - Added for eTDS/eTCS FVU Changes*/
                p_fh_recordHash           ||  v_delimeter||
                p_fh_fvuVersion           ||  v_delimeter||
                p_fh_fileHash             ||  v_delimeter||
                p_fh_samVersion           ||  v_delimeter||
                p_fh_samHash              ||  v_delimeter||
                p_fh_scmVersion           ||  v_delimeter||
                p_fh_scmHash);
          ELSE
            UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
            LPAD(p_line_number , sq_len_9, v_quart_pad) || v_pad_char ||
            LPAD( upper(p_record_type) , sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD(upper(p_file_type) , sq_len_4, v_quart_pad) || v_pad_char ||
            LPAD(upper(p_upload_type) , sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD(to_char(p_file_creation_date,'ddmmyyyy') , sq_len_8, v_quart_pad) || v_pad_char ||
            LPAD(p_file_sequence_number , sq_len_9, v_quart_pad) || v_pad_char ||
            LPAD(upper(p_uploader_type), sq_len_1, v_quart_pad) || v_pad_char ||
            LPAD(upper(p_collector_tan) , sq_len_10, v_quart_pad) || v_pad_char ||
            LPAD(p_number_of_batches , sq_len_9, v_quart_pad) || v_pad_char ||
            LPAD(p_return_prep_util , sq_len_75, v_quart_pad) || v_pad_char || /*Bug 8880543 - Added for eTDS/eTCS FVU Changes*/
            LPAD(NVL(p_fh_recordHash,v_q_noval_filler) , sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD(NVL(p_fh_fvuVersion, v_q_noval_filler) , sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD(NVL(p_fh_fileHash, v_q_noval_filler) , sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD(NVL(p_fh_samVersion, v_q_noval_filler) , sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD(NVL(p_fh_samHash, v_q_noval_filler) , sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD(NVL(p_fh_scmVersion, v_q_noval_filler) , sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD(NVL(p_fh_scmHash, v_q_noval_filler) , sq_len_2, v_quart_pad)
            ) ;

          END IF ;


        END create_quarterly_file_header ;

   PROCEDURE validate_batch_header
       ( p_line_number                IN NUMBER,
        p_record_type                IN VARCHAR2,
        p_batch_number               IN NUMBER,
        p_challan_cnt                IN NUMBER,
        p_quart_form_number          IN VARCHAR2,
        p_collector_tan               IN VARCHAR2,
        p_pan_of_tan                 IN VARCHAR2, /*Bug 8880543 - Added for eTDS/eTCS FVU Changes*/
        p_assessment_year            IN NUMBER,
        p_financial_year             IN NUMBER,
        p_collector_name              IN VARCHAR2,
        p_tan_address1               IN VARCHAR2,
        p_tan_state_code             IN NUMBER,
        p_tan_pin                    IN NUMBER,
        p_collector_type             IN VARCHAR2, /*Bug 8880543 - Modified Collector Status to Collector Type*/
        p_addrChangedSinceLastReturn IN VARCHAR2,
        p_personNameRespForCollection IN VARCHAR2,
        p_personDesgnRespForCollection IN VARCHAR2,
        p_RespPersAddress            IN VARCHAR2,
        p_RespPersState              IN NUMBER,
        p_RespPersPin                IN NUMBER,
        p_RespPersAddrChange         IN VARCHAR2,
        p_totTaxCollectedAsPerParty IN NUMBER,
        p_ao_approval                IN VARCHAR2,
        /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
        p_state_name                 IN  VARCHAR2,
        p_pao_code                   IN  VARCHAR2,
        p_ddo_code                   IN  VARCHAR2,
        p_ministry_name              IN  VARCHAR2,
        p_pao_registration_no        IN  NUMBER,
        p_ddo_registration_no        IN  VARCHAR2,
        /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
        p_return_code                OUT NOCOPY VARCHAR2,
        p_return_message             OUT NOCOPY VARCHAR2
     )
     IS
     BEGIN
       IF p_line_number IS NULL THEN
         p_return_message := p_return_message ||  ' Line Number should not be null. ' ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_record_type IS NULL THEN
         p_return_message := p_return_message ||  ' Record Type is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_batch_number  IS NULL THEN
         p_return_message := p_return_message ||  ' Batch Number is null. ' ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_challan_cnt IS NULL THEN
         p_return_message := p_return_message ||  ' Record Count is null. ' ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_quart_form_number  IS NULL THEN
         p_return_message := p_return_message ||  ' Form Number is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_collector_tan   IS NULL THEN
         p_return_message := p_return_message ||  ' Collector TAN is null. ' ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       /*Bug 8880543 - Added for PAN Number Validation - Start*/

       IF p_pan_of_tan   IS NULL THEN
         p_return_message := p_return_message ||  ' Collector PAN is null. ' ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       ELSE
        IF (validate_alpha_numeric(p_pan_of_tan, length(p_pan_of_tan)) = 'INVALID') THEN
          p_return_message := p_return_message ||  ' PAN format incorrect. The first five must be alphabets, followed by four numbers, and then followed by an alphabet.'  ;
          IF lv_action <> 'V' THEN
             goto  end_of_procedure  ;
          END IF ;
        END IF;
       END IF ;

       /*Bug 8880543 - Added for PAN Number Validation - End*/
       IF p_assessment_year IS NULL THEN
         p_return_message := p_return_message ||  ' Assessment Year is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_financial_year IS NULL THEN
         p_return_message := p_return_message ||  ' Financial Year is null. ' ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_collector_name IS NULL THEN
         p_return_message := p_return_message ||  ' Collector Name is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_tan_address1  IS NULL THEN
         p_return_message := p_return_message ||  ' Collector Address is null. ' ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_tan_state_code   IS NULL THEN
         p_return_message := p_return_message ||  ' Collector State is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_tan_pin    IS NULL THEN
         p_return_message := p_return_message ||  ' Collector Pin is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_collector_type IS NULL THEN  /*Bug 8880543 - Modified Collector Status to Collector Type*/
         p_return_message := p_return_message ||  ' Collector Type is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_addrChangedSinceLastReturn IS NULL THEN
         p_return_message := p_return_message ||  ' Field Collector Address Changed Since last year is null. ' ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_personNameRespForCollection IS NULL THEN
         p_return_message := p_return_message ||  ' Person Responsible For Collection is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_personDesgnRespForCollection IS NULL THEN
         p_return_message := p_return_message ||  ' Designation of Responsible Person  is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_RespPersAddress   IS NULL THEN
         p_return_message := p_return_message ||  ' Address of Responsible Person is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_RespPersState    IS NULL THEN
         p_return_message := p_return_message ||  ' State of Responsible Person is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_RespPersPin   IS NULL THEN
         p_return_message := p_return_message ||  ' Pin  of Responsible Person is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       IF p_RespPersAddrChange IS NULL THEN
         p_return_message := p_return_message ||  ' Field ''Address of Responsible Person has Changed'' is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       /*
       IF p_totTaxCollectedAsPerParty IS NULL THEN
         p_return_message := p_return_message ||  ' Total Deposit Amount as per Challan is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
       */
       IF p_ao_approval  IS NULL THEN
         p_return_message := p_return_message ||  ' AO Approval is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;

       /*Bug 8880543 - Validation for eTDs/eTCS FVU changes - Start*/

       IF p_collector_type in ('S', 'E', 'H', 'N') THEN
           IF p_state_name IS NULL THEN
               p_return_message := p_return_message ||  ' State is required when Deductor Type is S/E/H/N. '  ;
               IF lv_action <> 'V' THEN
                   goto  end_of_procedure  ;
               END IF ;
           END IF ;
       END IF;

       IF p_collector_type in ('A') THEN
           IF p_pao_code IS NULL THEN
               p_return_message := p_return_message ||  ' PAO Code is required when Deductor Type is A. '  ;
               IF lv_action <> 'V' THEN
                   goto  end_of_procedure  ;
               END IF ;
           END IF ;
           IF p_ddo_code IS NULL THEN
               p_return_message := p_return_message ||  ' DDO Code is required when Deductor Type is A. '  ;
               IF lv_action <> 'V' THEN
                   goto  end_of_procedure  ;
               END IF ;
           END IF ;
       END IF;

       IF p_collector_type in ('A', 'D', 'G') THEN
           IF p_ministry_name IS NULL THEN
               p_return_message := p_return_message ||  ' Ministry Name is required when Deductor Type is A/D/G. '  ;
               IF lv_action <> 'V' THEN
                   goto  end_of_procedure  ;
               END IF ;
           END IF ;
       END IF;

       /*Bug 8880543 - Validation for eTDs/eTCS FVU changes - End*/

       IF lv_action = 'V' THEN
         goto  end_of_procedure  ;
       END IF ;

      <<end_of_procedure>>
       IF p_return_message IS NOT NULL THEN
         p_return_code := 'E';
         p_return_message := 'Batch Header Error - ' || 'Line No : ' || p_line_number || '. ' || p_return_message ;
       END IF;

     END validate_batch_header ;

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
          p_collector_last_tan  IN VARCHAR2,
          p_collector_tan       IN VARCHAR2,
          p_filler1            IN VARCHAR2,
          p_collector_pan       IN VARCHAR2,
          p_assessment_year    IN NUMBER,
          p_financial_year     IN NUMBER,
          p_period             IN VARCHAR2,
          p_collector_name      IN VARCHAR2,
          p_collector_branch    IN VARCHAR2,
          p_tan_address1       IN VARCHAR2,
          p_tan_address2       IN VARCHAR2,
          p_tan_address3       IN VARCHAR2,
          p_tan_address4       IN VARCHAR2,
          p_tan_address5       IN VARCHAR2,
          p_tan_state_code     IN NUMBER,
          p_tan_pin            IN NUMBER,
          p_collector_email     IN VARCHAR2,
          p_collector_stdCode   IN NUMBER,
          p_collector_phoneNo   IN NUMBER,
          p_addrChangedSinceLastReturn IN VARCHAR2,
          p_type_of_collector   IN VARCHAR2, /*Bug 8880543 - Modified Status of Collector to Type of Collector*/
          p_pers_resp_for_collection IN VARCHAR2,
          p_RespPerson_designation  IN VARCHAR2,
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
          p_totTaxcollectedAsPerChallan IN NUMBER,
          p_tds_circle              IN VARCHAR2,
          p_salaryRecords_count     IN VARCHAR2,
          p_gross_total             IN VARCHAR2,
          p_ao_approval             IN VARCHAR2,
          p_ao_approval_number      IN VARCHAR2,
          /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
          p_last_collector_type     IN  VARCHAR2,
          p_state_name              IN  VARCHAR2,
          p_pao_code                IN  VARCHAR2,
          p_ddo_code                IN  VARCHAR2,
          p_ministry_name           IN  VARCHAR2,
          p_ministry_name_other     IN  VARCHAR2,
          p_filler2                 IN  VARCHAR2,
          p_pao_registration_no     IN  NUMBER,
          p_ddo_registration_no     IN  VARCHAR2,
          /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
          p_recHash                 IN VARCHAR2,
          p_generate_headers        IN VARCHAR2)
        IS
        BEGIN

      IF p_generate_headers = 'N' THEN
            UTL_FILE.PUT_LINE( jai_ap_tds_etds_pkg.v_filehandle,  p_line_number          ||  v_delimeter||
            upper(p_record_type)     ||  v_delimeter||
            p_batch_number           ||  v_delimeter||
            p_challan_count          ||  v_delimeter||
            upper(p_form_number)     ||  v_delimeter||
            p_trn_type               ||  v_delimeter||
            p_batchUpd               ||  v_delimeter||
            p_org_RRRno              ||  v_delimeter||
            p_prev_RRRno             ||  v_delimeter||
            p_RRRno                  ||  v_delimeter||
            p_RRRdate                 ||  v_delimeter||
            p_collector_last_tan      ||  v_delimeter||
            upper(p_collector_tan)    ||  v_delimeter||
            p_filler1                ||  v_delimeter||
            p_collector_pan          ||  v_delimeter||
            p_assessment_year        ||  v_delimeter||
            p_financial_year         ||  v_delimeter||
            p_period                 ||  v_delimeter||
            p_collector_name          ||  v_delimeter||
            p_collector_branch        ||  v_delimeter||
            p_tan_address1           ||  v_delimeter||
            p_tan_address2           ||  v_delimeter||
            p_tan_address3           ||  v_delimeter||
            p_tan_address4           ||  v_delimeter||
            p_tan_address5           ||  v_delimeter||
            p_tan_state_code         ||  v_delimeter||
            p_tan_pin                ||  v_delimeter||
            p_collector_email         ||  v_delimeter||
            p_collector_stdCode       ||  v_delimeter||
            p_collector_phoneNo       ||  v_delimeter||
            p_addrChangedSinceLastReturn ||  v_delimeter||
            p_type_of_collector       ||  v_delimeter|| /*Bug 8880543 - Changed Collector Status to Collector Type*/
            p_pers_resp_for_collection   ||  v_delimeter||
            p_RespPerson_designation    ||  v_delimeter||
            p_RespPerson_address1       ||  v_delimeter||
            p_RespPerson_address2       ||  v_delimeter||
            p_RespPerson_address3       ||  v_delimeter||
            p_RespPerson_address4       ||  v_delimeter||
            p_RespPerson_address5       ||  v_delimeter||
            p_RespPerson_state          ||  v_delimeter||
            p_RespPerson_pin            ||  v_delimeter||
            p_RespPerson_email          ||  v_delimeter||
            p_RespPerson_remark         ||  v_delimeter||
            p_RespPerson_stdCode        ||  v_delimeter||
            p_RespPerson_phoneNo        ||  v_delimeter||
            p_RespPerson_addressChange  ||  v_delimeter||
            to_char(p_totTaxcollectedAsPerChallan,v_format_amount) ||  v_delimeter||
            p_tds_circle    ||  v_delimeter||
            p_salaryRecords_count       ||  v_delimeter||
            p_gross_total               ||  v_delimeter||
            upper(p_ao_approval)        ||  v_delimeter||
            p_ao_approval_number        ||  v_delimeter||
            /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
            p_last_collector_type       ||  v_delimeter||
            p_state_name                ||  v_delimeter||
            p_pao_code                  ||  v_delimeter||
            p_ddo_code                  ||  v_delimeter||
            p_ministry_name             ||  v_delimeter||
            p_ministry_name_other       ||  v_delimeter||
            p_filler2                   ||  v_delimeter||
            to_char(p_pao_registration_no)       ||  v_delimeter||
            p_ddo_registration_no       ||  v_delimeter||
            /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
            p_recHash                             ) ;
        ELSE
         UTL_FILE.PUT_LINE( jai_ap_tds_etds_pkg.v_filehandle,
         LPAD(p_line_number, sq_len_9  , v_quart_pad) || v_pad_char ||
         LPAD(upper(p_record_type) , sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(p_batch_number, sq_len_9  , v_quart_pad) || v_pad_char ||
         LPAD(p_challan_count, sq_len_9  , v_quart_pad) || v_pad_char ||
         LPAD(upper(p_form_number), sq_len_4  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_trn_type,v_q_noval_filler ), sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_batchUpd,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_org_RRRno,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_prev_RRRno,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_RRRno,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_RRRdate,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_collector_last_tan,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(upper(p_collector_tan), sq_len_10  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_filler1,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_collector_pan,v_q_null_filler ) , sq_len_10  , v_quart_pad) || v_pad_char ||
         LPAD(p_assessment_year , sq_len_6  , v_quart_pad) || v_pad_char ||
         LPAD(p_financial_year  , sq_len_6  , v_quart_pad) || v_pad_char ||
         LPAD(p_period , sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(p_collector_name, sq_len_75  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_collector_branch ,v_q_null_filler ), sq_len_75  , v_quart_pad) || v_pad_char ||
         LPAD(p_tan_address1, sq_len_25  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_tan_address2,v_q_null_filler )   , sq_len_25  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_tan_address3,v_q_null_filler )     , sq_len_25  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_tan_address4,v_q_null_filler ) , sq_len_25  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_tan_address5,v_q_null_filler )   , sq_len_25  , v_quart_pad) || v_pad_char ||
         LPAD(p_tan_state_code, sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(p_tan_pin, sq_len_6  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_collector_email,v_q_null_filler ) , sq_len_75  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_collector_stdCode,v_quart_numfill ) , sq_len_5  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_collector_phoneNo,v_quart_numfill )    , sq_len_10  , v_quart_pad) || v_pad_char ||
         LPAD(p_addrChangedSinceLastReturn, sq_len_1  , v_quart_pad) || v_pad_char ||
         LPAD(p_type_of_collector, sq_len_1  , v_quart_pad) || v_pad_char ||  /*Bug 8880543 - Changed Collector Status to Collector Type*/
         LPAD(p_pers_resp_for_collection, sq_len_75  , v_quart_pad) || v_pad_char ||
         LPAD(p_RespPerson_designation, sq_len_20  , v_quart_pad) || v_pad_char ||
         LPAD(p_RespPerson_address1, sq_len_25  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_RespPerson_address2,v_q_null_filler ) , sq_len_25  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_RespPerson_address3,v_q_null_filler ) , sq_len_25  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_RespPerson_address4,v_q_null_filler ) , sq_len_25  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_RespPerson_address5,v_q_null_filler ) , sq_len_25  , v_quart_pad) || v_pad_char ||
         LPAD(p_RespPerson_state, sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(p_RespPerson_pin, sq_len_6  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_RespPerson_email,v_q_null_filler ) , sq_len_75  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_RespPerson_remark,v_q_null_filler ) , sq_len_75  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_RespPerson_stdCode,v_quart_numfill ) , sq_len_5  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_RespPerson_phoneNo,v_quart_numfill )   , sq_len_10  , v_quart_pad) || v_pad_char ||
         LPAD(p_RespPerson_addressChange, sq_len_1  , v_quart_pad) || v_pad_char ||
         LPAD(to_char(p_totTaxCollectedAsPerChallan,v_format_amount), sq_len_15  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_tds_circle,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_salaryRecords_count,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_gross_total,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(upper(p_ao_approval), sq_len_1  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_ao_approval_number,v_q_noval_filler ), sq_len_15  , v_quart_pad) || v_pad_char ||
         /*Bug 8880543 - Modified for eTDS/eTCS FVU changes - Start*/
         LPAD(NVL(p_last_collector_type, v_q_null_filler ) , sq_len_1  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_state_name, v_q_null_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_pao_code, v_q_null_filler ) , sq_len_20  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_ddo_code, v_q_null_filler ) , sq_len_20  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_ministry_name, v_q_null_filler ) , sq_len_3  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_ministry_name_other, v_q_null_filler ) , sq_len_150  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_filler2, v_q_null_filler ) , sq_len_12  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(to_char(p_pao_registration_no), v_q_null_filler ) , sq_len_7  , v_quart_pad) || v_pad_char ||
         LPAD(NVL(p_ddo_registration_no, v_q_null_filler ) , sq_len_10  , v_quart_pad) || v_pad_char ||
         /*Bug 8880543 - Modified for eTDS/eTCS FVU changes - End*/
         LPAD(NVL(p_recHash,v_q_noval_filler ) , sq_len_2  , v_quart_pad)
         );
       END IF ;

    END create_quarterly_batch_header;

    PROCEDURE validate_challan_detail
     (  p_line_number           IN NUMBER ,
        p_record_type           IN VARCHAR2,
        p_batch_number          IN NUMBER,
        p_challan_dtl_slno      IN NUMBER,
        p_party_cnt             IN NUMBER,
        p_nil_challan_indicat   IN VARCHAR2,
        p_tcs_section           IN VARCHAR2,
        p_tcs_amt               IN NUMBER,
        p_surcharge_amt         IN NUMBER,
        p_cess_amt              IN NUMBER,
        p_amt_of_oth            IN NUMBER,
        p_tcs_amount            IN NUMBER,
        p_total_income_tcs      IN NUMBER,
        p_challan_no            IN VARCHAR2,
        p_bank_branch_code      IN VARCHAR2,
        p_challan_Date          IN DATE,
        p_check_number          IN NUMBER,
        p_amt_of_int            IN NUMBER ,
        p_total_deposit         IN NUMBER ,
        p_tcs_income_tax        IN NUMBER,
        p_tcs_surcharge         IN NUMBER ,
        p_tcs_cess              IN NUMBER ,
        p_tcs_interest_amt      IN NUMBER ,
        p_tcs_other_amt         IN NUMBER ,
        p_return_code           OUT NOCOPY VARCHAR2,
        p_return_message        OUT NOCOPY VARCHAR2
    )
    IS
    BEGIN
      IF p_line_number               IS NULL THEN
        p_return_message := p_return_message ||     ' Line number should not be null. '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_record_type               IS NULL THEN
        p_return_message := p_return_message ||     ' Record Type is null. '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_batch_number              IS NULL THEN
        p_return_message := p_return_message ||     ' Batch Number is null. '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_challan_dtl_slno          IS NULL THEN
        p_return_message := p_return_message ||     ' Challan Record Number is null. '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF  p_party_cnt             IS NULL THEN
        p_return_message := p_return_message ||     ' Party Count is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_nil_challan_indicat       IS NULL THEN
        p_return_message := p_return_message ||     ' NIL Challan Indicator is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_tcs_section               IS NULL THEN
        p_return_message := p_return_message ||     ' TCS Section is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_tcs_amt                IS NULL THEN
        p_return_message := p_return_message ||     ' TCS Amount is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_surcharge_amt          IS NULL THEN
        p_return_message := p_return_message ||     ' TCS Surcharge Amount is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_cess_amt IS NULL THEN
        p_return_message := p_return_message ||     ' TCS Cess Amount is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_amt_of_oth                IS NULL THEN
        p_return_message := p_return_message ||     ' TCS Other Amount is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_tcs_amount                IS NULL THEN
        p_return_message := p_return_message ||     ' Total TCS Amount is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_challan_no                IS NULL THEN
        p_return_message := p_return_message ||   ' Challan No is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_challan_Date IS NULL THEN
        p_return_message := p_return_message ||   ' Challan Date is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;

      IF p_total_income_tcs IS NULL THEN
        p_return_message := p_return_message ||   ' Total Tax Deposit Amount is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_amt_of_int          IS NULL THEN
        p_return_message := p_return_message ||   ' TCS Interest Amount is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF p_total_deposit IS NULL THEN
        p_return_message := p_return_message ||   ' Amount As Per Party is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
        END IF ;
      END IF ;
       IF  p_tcs_income_tax IS NULL THEN
        p_return_message := p_return_message ||   ' Total Tax Deposit Amount As Per Party is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF  p_tcs_surcharge  IS NULL THEN
        p_return_message := p_return_message ||   ' Total TCS Surcharge is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF  p_tcs_cess        IS NULL THEN
        p_return_message := p_return_message ||   ' Total TCS Cess is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF  p_tcs_interest_amt IS NULL THEN
        p_return_message := p_return_message ||   ' Total TCS Interest is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
        END IF ;
      END IF ;
      IF  p_tcs_other_amt    IS NULL THEN
        p_return_message := p_return_message ||   ' Total TCS Other Amount is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
        END IF ;
      END IF ;

      jai_ap_tds_etds_pkg.check_numeric(p_challan_no, 'Check Number : ' || p_check_number  || ' Challan Number is not a Numeric Value', lv_action);
      jai_ap_tds_etds_pkg.check_numeric(p_bank_branch_code, 'Check Number : ' || p_check_number  || ' Bank Branch Code is not a Numeric Value ', lv_action);

      IF lv_action = 'V' THEN
        goto  end_of_procedure  ;
      END IF ;

      <<end_of_procedure>>
      IF p_return_message IS NOT NULL THEN
        p_return_code := 'E';
        p_return_message := 'Challan Detail Error - ' || 'Check Number : ' || p_check_number || '. ' || p_return_message ;
      END IF;
    END validate_challan_detail;

    PROCEDURE create_quart_challan_dtl(
                        p_line_number IN NUMBER ,
                        p_record_type IN VARCHAR2 ,
                        p_batch_number IN NUMBER ,
                        p_challan_dtl_slno IN NUMBER ,
                        p_collection_cnt  IN NUMBER ,
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
                        p_tcs_section IN VARCHAR2 ,
                        p_tcs_amt IN NUMBER ,
                        p_surcharge_amt IN NUMBER ,
                        p_cess_amt IN NUMBER ,
                        p_amt_of_int IN NUMBER ,
                        p_amt_of_oth IN NUMBER ,
                        p_tcs_amount IN NUMBER ,
                        p_last_total_depositAmt IN NUMBER ,
                        p_total_deposit IN NUMBER ,
                        p_tcs_income_tax IN NUMBER ,
                        p_tcs_surcharge IN NUMBER ,
                        p_tcs_cess IN NUMBER ,
                        p_total_income_tcs IN NUMBER ,
                        p_tcs_interest_amt IN NUMBER ,
                        p_tcs_other_amt IN NUMBER ,
                        p_check_number IN NUMBER ,
                        p_book_entry IN VARCHAR2 ,
                        p_remarks IN VARCHAR2 ,
                        p_ch_recHash IN VARCHAR2,
                        p_generate_headers IN VARCHAR2
                      )
     IS
         BEGIN
            IF p_generate_headers = 'N' THEN
               UTL_FILE.PUT_LINE(
               jai_ap_tds_etds_pkg.v_filehandle,p_line_number                  ||  v_delimeter||
               upper(p_record_type)                        ||  v_delimeter||
               p_batch_number                              ||  v_delimeter||
               p_challan_dtl_slno                          ||  v_delimeter||
               p_collection_cnt                            ||  v_delimeter||
               p_nil_challan_indicator                     ||  v_delimeter||
               p_ch_updIndicator                           ||  v_delimeter||
               p_filler2                                   ||  v_delimeter||
               p_filler3                                   ||  v_delimeter||
               p_filler4                                   ||  v_delimeter||
               p_last_bank_challan_no                      ||  v_delimeter||
               substr(p_bank_challan_no, 1,5)              ||  v_delimeter||
               p_last_transfer_voucher_no                  ||  v_delimeter||
               p_transfer_voucher_no                       ||  v_delimeter||
               p_last_bank_branch_code                     ||  v_delimeter||
               p_bank_branch_code                          ||  v_delimeter||
               p_challan_lastDate                          ||  v_delimeter||
               to_char(p_challan_Date,'ddmmyyyy')          ||  v_delimeter||
               p_filler5                                   ||  v_delimeter||
               p_filler6                                   ||  v_delimeter||
               p_tcs_section  ||  v_delimeter||
               to_char(p_tcs_amt,v_format_amount)       ||  v_delimeter||
               to_char(p_surcharge_amt,v_format_amount) ||  v_delimeter||
               to_char(p_cess_amt,v_format_amount)      ||  v_delimeter||
               to_char(p_amt_of_int,v_format_amount)       ||  v_delimeter||
               to_char(p_amt_of_oth,v_format_amount)       ||  v_delimeter||
               to_char(p_tcs_amount,v_format_amount)       ||  v_delimeter||
               p_last_total_depositAmt                     ||  v_delimeter||
               to_char(p_total_deposit,v_format_amount)    ||  v_delimeter||
               to_char(p_tcs_income_tax,v_format_amount)   ||  v_delimeter||
               to_char(p_tcs_surcharge,v_format_amount)    ||  v_delimeter||
               to_char(p_tcs_cess,v_format_amount)         ||  v_delimeter||
               to_char(p_total_income_tcs,v_format_amount) ||  v_delimeter||
               to_char(p_tcs_interest_amt,v_format_amount) ||  v_delimeter||
               to_char(p_tcs_other_amt, v_format_amount)   ||  v_delimeter||
               p_check_number                              ||  v_delimeter||
               p_book_entry                                ||  v_delimeter||
               p_remarks                                   ||  v_delimeter||
               p_ch_recHash ) ;
           ELSE
             UTL_FILE.PUT_LINE( jai_ap_tds_etds_pkg.v_filehandle,
              LPAD(p_line_number     , sq_len_9, v_quart_pad) || v_pad_char ||
              LPAD(upper(p_record_type)     , sq_len_2, v_quart_pad) || v_pad_char ||
              LPAD(p_batch_number       , sq_len_9, v_quart_pad) || v_pad_char ||
              LPAD(p_challan_dtl_slno       , sq_len_9, v_quart_pad) || v_pad_char ||
              LPAD(p_collection_cnt       , sq_len_9, v_quart_pad) || v_pad_char ||
              LPAD(p_nil_challan_indicator  , sq_len_1, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_ch_updIndicator,v_q_noval_filler),   sq_len_2, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_filler2,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_filler3,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_filler4,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_last_bank_challan_no,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_bank_challan_no,v_q_null_filler )       , sq_len_5, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_last_transfer_voucher_no,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_transfer_voucher_no,v_quart_numfill )       , sq_len_9, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_last_bank_branch_code,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_bank_branch_code,v_q_null_filler )       , sq_len_7, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_challan_lastDate,v_q_noval_filler ) , sq_len_2, v_quart_pad) || v_pad_char ||
              LPAD(to_char(p_challan_Date,'ddmmyyyy') , sq_len_8, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_filler5,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_filler6,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
              LPAD(p_tcs_section, sq_len_3, v_quart_pad) || v_pad_char ||
              LPAD(to_char(p_tcs_amt , v_format_amount)   , sq_len_15, v_quart_pad) || v_pad_char ||
              LPAD(to_char( p_surcharge_amt, v_format_amount)  , sq_len_15, v_quart_pad) || v_pad_char ||
              LPAD(to_char( p_cess_amt, v_format_amount)  , sq_len_15, v_quart_pad) || v_pad_char ||
              LPAD(to_char( p_amt_of_int, v_format_amount)   , sq_len_15, v_quart_pad) || v_pad_char ||
              LPAD(to_char( p_amt_of_oth, v_format_amount)   , sq_len_15, v_quart_pad) || v_pad_char ||
              LPAD(to_char( p_tcs_amount, v_format_amount)   , sq_len_15, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_last_total_depositAmt, v_quart_numfill) , sq_len_2, v_quart_pad) || v_pad_char ||
              LPAD(to_char( p_total_deposit, v_format_amount)    , sq_len_15, v_quart_pad) || v_pad_char ||
              LPAD(to_char( p_tcs_income_tax, v_format_amount)   , sq_len_15, v_quart_pad) || v_pad_char ||
              LPAD(to_char( p_tcs_surcharge, v_format_amount)    , sq_len_15, v_quart_pad) || v_pad_char ||
              LPAD(to_char( p_tcs_cess, v_format_amount)         , sq_len_15, v_quart_pad) || v_pad_char ||
              LPAD(to_char( p_total_income_tcs, v_format_amount) , sq_len_15, v_quart_pad) || v_pad_char ||
              LPAD(to_char( p_tcs_interest_amt, v_format_amount) , sq_len_15, v_quart_pad) || v_pad_char ||
              LPAD(to_char( p_tcs_other_amt, v_format_amount)    , sq_len_15, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_check_number,v_quart_numfill ) , sq_len_15, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_book_entry,v_q_null_filler )   , sq_len_1, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_remarks,v_q_null_filler )     , sq_len_14, v_quart_pad) || v_pad_char ||
              LPAD(NVL(p_ch_recHash,v_q_noval_filler )  , sq_len_2, v_quart_pad)
              );
           END IF ;

      END create_quart_challan_dtl;

  --Date Population procedures for ETCS Yearly Returns

    PROCEDURE create_file_header(
          p_line_number IN NUMBER,
          p_record_type IN VARCHAR2,
          p_file_type IN VARCHAR2,
          p_upload_type IN VARCHAR2,
          p_file_creation_date IN DATE,
          p_file_sequence_number IN NUMBER,
          p_deductor_tan IN VARCHAR2,
          p_number_of_batches IN NUMBER
      ) IS

     BEGIN

        UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
                LPAD(p_line_number, s_line_number, v_pad_number)
              ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(p_record_type, s_record_type, v_pad_char)
              ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(p_file_type, s_file_type, v_pad_char)
              ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(p_upload_type, s_upload_type, v_pad_char)
              ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(to_char(p_file_creation_date,'ddmmyyyy'), s_date, v_pad_date)
              ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(p_file_sequence_number, s_file_sequence_number, v_pad_number)
              ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(nvl(p_deductor_tan,' '), s_deductor_tan, v_pad_char)
              ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(nvl(p_number_of_batches,0), s_number_of_batches, v_pad_number)||fnd_global.local_chr(13)
      );
  END create_file_header ;

  PROCEDURE create_dd IS
  BEGIN

    -- Deductee Detail
    UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle, fnd_global.local_chr(10) );
    UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
              LPAD('LineNo', s_line_number, v_pad_char)
            ||v_pad_char||RPAD('RT', s_record_type, v_pad_char)
            ||v_pad_char||LPAD('B.No.', s_batch_number, v_pad_char)
            ||v_pad_char||LPAD('DSlNo', s_deductee_slno, v_pad_char)
            ||v_pad_char||RPAD('Secn.', s_deductee_section, v_pad_char)
            ||v_pad_char||RPAD('BCode', s_deductee_code, v_pad_char)
            ||v_pad_char||RPAD('PrtyPan', s_deductee_pan, v_pad_char)
            ||v_pad_char||RPAD('Party Name', s_deductee_name, v_pad_char)
            ||v_pad_char||RPAD('Party Addr1', s_deductee_address1, v_pad_char)
            ||v_pad_char||RPAD('Party Addr2', s_deductee_address2, v_pad_char)
            ||v_pad_char||RPAD('Party Addr3', s_deductee_address3, v_pad_char)
            ||v_pad_char||RPAD('Party Addr4', s_deductee_address4, v_pad_char)
            ||v_pad_char||RPAD('Party Addr5', s_deductee_address5, v_pad_char)
            ||v_pad_char||LPAD('PState', s_deductee_state, v_pad_char)
            ||v_pad_char||LPAD('PtePin', s_deductee_pin, v_pad_char)
            ||v_pad_char||LPAD('Purch Amount', s_filler, v_pad_char)
            ||v_pad_char||LPAD('Pay. Amount', s_payment_amount, v_pad_char)
            ||v_pad_char||LPAD('Pay. Date', s_date, v_pad_char)
            ||v_pad_char||LPAD('PBE', s_book_ent_oth , v_pad_char)
            ||v_pad_char||LPAD('TxRt', s_tax_rate, v_pad_char)
            ||v_pad_char||LPAD('Filler4', s_filler6, v_pad_char)
            ||v_pad_char||LPAD('TxColected', s_tax_deducted, v_pad_char)
            ||v_pad_char||LPAD('TxCol.Dt', s_date, v_pad_date)
            ||v_pad_char||RPAD('BSRCode', s_bank_branch_code, v_pad_char)
            ||v_pad_char||LPAD('TxPay.Dt', s_date, v_pad_date)
            ||v_pad_char||RPAD('ChlnNo', s_challan_no, v_pad_char)
            ||v_pad_char||LPAD('TcsCrtDt', s_date, v_pad_char)
            ||v_pad_char||RPAD('R', s_reason_for_nDeduction, v_pad_char)
            ||v_pad_char||LPAD('Filler5', s_filler, v_pad_char)
    );


    UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
              LPAD(v_underline_char, s_line_number, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_record_type, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_batch_number, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_deductee_slno, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_deductee_section, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_deductee_code, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_deductee_pan, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_deductee_name, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_deductee_address1, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_deductee_address2, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_deductee_address3, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_deductee_address4, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_deductee_address5, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_deductee_state, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_deductee_pin, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_filler, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_payment_amount, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_date, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_book_ent_oth , v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_tax_rate, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_filler6, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_tax_deducted, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_date, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_bank_branch_code, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_date, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_challan_no, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_date, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_reason_for_nDeduction, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_filler, v_underline_char)
    );

  END create_dd;


  PROCEDURE create_fh(p_batch_id IN NUMBER) IS
          v_req   JAI_AP_ETDS_REQUESTS%rowtype;
  BEGIN

          -- File Header
          SELECT * INTO v_req FROM JAI_AP_ETDS_REQUESTS WHERE batch_id = p_batch_id;

          UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle, 'Input Parameters to this Request:');
          UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle, '-------------------------------------------------');
          UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
                    '  batch_id                   ->'||v_req.batch_id||fnd_global.local_chr(10)
                  ||'  request_id                 ->'||v_req.request_id||fnd_global.local_chr(10)
                  ||'  operating_unit_id          ->'||v_req.operating_unit_id||fnd_global.local_chr(10)
                  ||'  org_tan_number             ->'||v_req.org_tan_number||fnd_global.local_chr(10)
                  ||'  financial_year             ->'||v_req.financial_year||fnd_global.local_chr(10)
                  ||'  tax_authority_id           ->'||v_req.tax_authority_id||fnd_global.local_chr(10)
                  ||'  tax_authority_site_id      ->'||v_req.tax_authority_site_id||fnd_global.local_chr(10)
                  ||'  organization_id            ->'||v_req.organization_id||fnd_global.local_chr(10)
                  ||'  deductor_name              ->'||v_req.deductor_name||fnd_global.local_chr(10)
                  ||'  deductor_state             ->'||v_req.deductor_state||fnd_global.local_chr(10)
                  ||'  addr_changed_since_last_ret->'||v_req.addr_changed_since_last_ret||fnd_global.local_chr(10)
                  ||'  deductor_status            ->'||v_req.deductor_status||fnd_global.local_chr(10)
                  ||'  person_resp_for_deduction  ->'||v_req.person_resp_for_deduction||fnd_global.local_chr(10)
                  ||'  designation_of_pers_resp   ->'||v_req.designation_of_pers_resp||fnd_global.local_chr(10)
                  ||'  challan_start_date         ->'||v_req.challan_start_date||fnd_global.local_chr(10)
                  ||'  challan_end_date           ->'||v_req.challan_end_date||fnd_global.local_chr(10)
                  ||'  file_path                  ->'||v_req.file_path||fnd_global.local_chr(10)
                  ||'  filename                   ->'||v_req.filename||fnd_global.local_chr(10)
          );


          UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
                    LPAD('LineNo', s_line_number, v_pad_char)
                  ||v_pad_char||RPAD('RT', s_record_type, v_pad_char)
                  ||v_pad_char||RPAD('FT', s_file_type, v_pad_char)
                  ||v_pad_char||RPAD('UT', s_upload_type, v_pad_char)
                  ||v_pad_char||LPAD('FileDate', s_date, v_pad_char)
                  ||v_pad_char||LPAD('FSeqNo', s_file_sequence_number, v_pad_char)
                  ||v_pad_char||RPAD('Org Tan', s_deductor_tan, v_pad_char)
                  ||v_pad_char||LPAD('NoOfBatches', s_number_of_batches, v_pad_char)
          );
          UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
                    LPAD(v_underline_char, s_line_number, v_underline_char)
                  ||v_pad_char||RPAD(v_underline_char, s_record_type, v_underline_char)
                  ||v_pad_char||RPAD(v_underline_char, s_file_type, v_underline_char)
                  ||v_pad_char||RPAD(v_underline_char, s_upload_type, v_underline_char)
                  ||v_pad_char||LPAD(v_underline_char, s_date, v_underline_char)
                  ||v_pad_char||LPAD(v_underline_char, s_file_sequence_number, v_underline_char)
                  ||v_pad_char||RPAD(v_underline_char, s_deductor_tan, v_underline_char)
                  ||v_pad_char||LPAD(v_underline_char, s_number_of_batches, v_underline_char)
          );
  END create_fh;

  PROCEDURE create_cd IS
  BEGIN

     -- Challan Detail
    UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle, fnd_global.local_chr(10) );
    UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
        LPAD('LineNo', s_line_number, v_pad_char)
      ||v_pad_char||RPAD('RT', s_record_type, v_pad_char)
      ||v_pad_char||LPAD('B.No', s_batch_number, v_pad_char)
      ||v_pad_char||LPAD('CSlNo', s_challan_slno, v_pad_char)
      ||v_pad_char||RPAD('Secn.', s_challan_section, v_pad_char)
      ||v_pad_char||LPAD('TCS amount', s_amount_tcs, v_pad_char)
      ||v_pad_char||LPAD('Surcharge amt',s_amount_sur , v_pad_char)
      ||v_pad_char||LPAD('CESS amount', s_amount_cess , v_pad_char)
      ||v_pad_char||LPAD('Amount of int', s_amount_cess , v_pad_char)
      ||v_pad_char||LPAD('Amount - others', s_amount_cess , v_pad_char)
      ||v_pad_char||LPAD('Total amount', s_amount_deducted , v_pad_char)
      ||v_pad_char||LPAD('Chq/DD.No', s_chq_dd_num , v_pad_char)
      ||v_pad_char||RPAD('BankBrCode', s_bank_branch_code, v_pad_char)
      ||v_pad_char||LPAD('TxdpDate', s_date, v_pad_char) --chq deposit date
      ||v_pad_char||RPAD('Chal.Num.', s_challan_no, v_pad_char)
      ||v_pad_char||RPAD('TBE ', s_tds_dep_book_ent , v_pad_char)
      ||v_pad_char||RPAD('C', s_filler4 , v_pad_char)
    );
    UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
              LPAD(v_underline_char, s_line_number, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_record_type, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_batch_number, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_challan_slno, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_challan_section, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_amount_tcs , v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_amount_sur , v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_amount_CESS , v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_amount_CESS , v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_amount_CESS , v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_amount_deducted , v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_chq_dd_num , v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_bank_branch_code, v_underline_char)
            ||v_pad_char||LPAD(v_underline_char, s_date, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_challan_no, v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_tds_dep_book_ent , v_underline_char)
            ||v_pad_char||RPAD(v_underline_char, s_filler4 , v_underline_char)
    );
   END create_cd;

        PROCEDURE create_deductee_detail(
                p_line_number IN NUMBER,
                p_record_type IN VARCHAR2,
                p_batch_number IN NUMBER,
                p_deductee_slno IN NUMBER,
                p_deductee_section IN VARCHAR2,
                p_deductee_code IN VARCHAR2,
                p_deductee_pan IN VARCHAR2,
                p_deductee_name IN VARCHAR2,
                p_deductee_address1 IN VARCHAR2,
                p_deductee_address2 IN VARCHAR2,
                p_deductee_address3 IN VARCHAR2,
                p_deductee_address4 IN VARCHAR2,
                p_deductee_address5 IN VARCHAR2,
                p_deductee_state IN VARCHAR2,
                p_deductee_pin IN NUMBER,
                p_purchase_amount IN NUMBER,
                p_payment_amount IN NUMBER,
                p_payment_date IN DATE,
                p_book_ent_oth IN VARCHAR2,
                p_tax_rate IN NUMBER,
                p_filler6  IN VARCHAR2,
                p_tax_deducted IN NUMBER,
                p_tax_deducted_date IN DATE,
                p_tax_payment_date IN DATE,
                p_bank_branch_code IN VARCHAR2,
                p_challan_no IN VARCHAR2,
                p_tds_certificate_date IN DATE,
                p_reason_for_nDeduction IN VARCHAR2,
                p_filler7 IN NUMBER
        ) IS

        BEGIN

          UTL_FILE.PUT_LINE(jai_ap_tds_etds_pkg.v_filehandle,
              LPAD(p_line_number, s_line_number, v_pad_number)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(p_record_type, s_record_type, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(p_batch_number, s_batch_number, v_pad_number)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(nvl(p_deductee_slno,0), s_deductee_slno, v_pad_number)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(p_deductee_section, s_deductee_section, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(nvl(p_deductee_code,' '), s_deductee_code, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(nvl(p_deductee_pan,' '), s_deductee_pan, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(nvl(p_deductee_name,' '), s_deductee_name, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(nvl(p_deductee_address1,' '), s_deductee_address1, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(nvl(p_deductee_address2,' '), s_deductee_address2, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(nvl(p_deductee_address3,' '), s_deductee_address3, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(nvl(p_deductee_address4,' '), s_deductee_address4, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(nvl(p_deductee_address5,' '), s_deductee_address5, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(nvl(p_deductee_state,'0'), s_deductee_state, v_pad_number)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(nvl(p_deductee_pin,0), s_deductee_pin, v_pad_number)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(jai_ap_tds_etds_pkg.formatAmount(p_purchase_amount), s_payment_amount, v_pad_number)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(jai_ap_tds_etds_pkg.formatAmount(p_payment_amount), s_payment_amount, v_pad_number)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(nvl(to_char(p_payment_date, 'ddmmyyyy'),' '), s_date, v_pad_date)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(p_book_ent_oth , s_book_ent_oth, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(jai_ap_tds_etds_pkg.formatAmount(p_tax_rate), s_tax_rate, v_pad_number)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(nvl(p_filler6,' '), s_filler6, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(jai_ap_tds_etds_pkg.formatAmount(p_tax_deducted), s_tax_deducted, v_pad_number)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(nvl(to_char(p_tax_deducted_date, 'ddmmyyyy'),' '), s_date, v_pad_date)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(nvl(p_bank_branch_code,' '), s_bank_branch_code, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(nvl(to_char(p_tax_payment_date, 'ddmmyyyy'),' '), s_date, v_pad_date)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(nvl(p_challan_no,' '), s_challan_no, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(nvl(to_char(p_tds_certificate_date, 'ddmmyyyy'),' '), s_date, v_pad_date)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||RPAD(nvl(p_reason_for_nDeduction,' '), s_reason_for_nDeduction, v_pad_char)
            ||jai_ap_tds_etds_pkg.v_debug_pad_char||LPAD(jai_ap_tds_etds_pkg.formatAmount(p_filler7), s_filler, v_pad_number) || fnd_global.local_chr(13)
          );

        END create_deductee_detail;


  PROCEDURE populate_details(
                  p_batch_id              IN NUMBER,
                  p_org_tan_num           IN VARCHAR2,
                  p_tax_authority_id      IN NUMBER,
                  p_tax_authority_site_id IN NUMBER,
                  p_from_date             IN DATE,
                  p_to_date               IN DATE,
                  p_collection_code       IN VARCHAR2
          )
  IS

    cursor c_tax_amount(cp_tax_type in varchar2, cp_source_doc_id in number, cp_check_id in number)
    is
      select nvl(sum(tax_amt),0)
      from jai_rgm_taxes
      where tax_type = cp_tax_type
      and trx_ref_id in
        ( select trx_ref_id
          from jai_rgm_refs_all jra
          where
            source_ref_document_id = cp_source_doc_id and
            jra.source_document_date between p_from_date and p_to_date
            and   settlement_id
            IN ( select settlement_id
                 from jai_ap_rgm_payments
                 where check_id = cp_check_id
               )
        )   ;


    cursor c_pan_no(cp_party_id in number)
    is
    select pan_no
    from JAI_CMN_CUS_ADDRESSES
    where customer_id = cp_party_id
    and confirm_pan   = 'Y'
    and pan_no is not null
    and rownum = 1 ;

    cursor c_buyer_code(cp_party_id in number)
    is
    select
      DECODE(jca.tcs_customer_type, 'COMPANIES', '01', 'OTHERS', '02') buyer_code
    from JAI_CMN_CUS_ADDRESSES jca
    where jca.customer_id = cp_party_id
    and  jca.tcs_customer_type is not null
    and rownum = 1 ;

    cursor c_get_recs
    is
    select *
    from jai_ar_etcs_t for update ;

    cursor c_line_amt(cp_source_document_ref_id number, cp_check_id in number) is
    select nvl(sum(line_amt),0)
    from jai_rgm_refs_all jra
    where
      source_ref_document_id = cp_source_document_ref_id and
      jra.source_document_date between p_from_date and p_to_date
      and   settlement_id
      IN ( select settlement_id
           from jai_ap_rgm_payments
           where check_id = cp_check_id
         ) ;


    ln_line_amt number ;

   lv_customer_type   varchar2(2) ;
   lv_pan_no          JAI_CMN_CUS_ADDRESSES.pan_no%TYPE ;
   lv_item_classification jai_rgm_lookups.display_value%type ;
   ln_tcs_amount       number ;
   ln_surcharge_amount number ;
   ln_cess_amount      number ;
   ln_tcs_cess_amount number ;
   ln_sur_cess_amount number ;
-- Date 03/07/2007 by sacsethi for bug 6157120
   ln_tcs_sh_cess_amount number ;


  Cursor c_rcpt_date(cp_receipt_id number)
  is
  select receipt_date
  from ar_cash_receipts
  where cash_receipt_id = cp_receipt_id ;

  Cursor c_source_ref_type(cp_source_ref_id in number)
  is
  select source_document_type
  from jai_rgm_refs_all
  where source_document_id = cp_source_ref_id
  and source_document_type IN (jai_constants.ar_cash_tax_confirmed , jai_constants.trx_type_inv_comp)
  and rownum = 1 ;

  Cursor c_inv_date(cp_inv_id number)
  is
  select trx_date
  from ra_customer_trx_all
  where customer_trx_id = cp_inv_id ;
-- Date 28/06/2007 by sacsethi for bug 6157120
/*  CURSOR c_check_dtls(cpn_check_id IN NUMBER) IS
  SELECT INTERNAL_BANK_ACCOUNT_ID
  FROM IBY_PAYMENTS_ALL
  WHERE paper_document_number =cpn_check_id;*/

-- Date 28/06/2007 by sacsethi for bug 6157120
/*  CURSOR c_bank_branch_code(cp_bank_account_id IN NUMBER) IS
  select a.branch_number
  from ce_bank_branches_v a, ce_bank_accounts b
  where a.branch_party_id = b.bank_branch_id
  and b.bank_account_id = cp_bank_account_id	;*/

  /*SELECT a.bank_num
  FROM ap_bank_branches a, ap_bank_accounts_all b
  WHERE a.bank_branch_id = b.bank_branch_id
  AND b.bank_account_id = cp_bank_account_id;*/

  v_bank_account_id       NUMBER(15);
  v_bank_branch_code      ce_bank_branches_v.BRANCH_NUMBER%TYPE;

  lv_source_ref_type jai_rgm_refs_all.source_document_type%TYPE ;
  lv_doc_date date ;

  BEGIN

    insert into jai_ar_etcs_t
    (
      Batch_id                       ,
      tcs_check_id                   ,
      check_number                   ,
      tcs_check_date                 ,
      challan_no                     ,
      challan_date                   ,
      bank_branch_code               ,
      source_document_id             ,
      party_id                       ,
      party_site_id                  ,
      collection_flag                ,
      tcs_tax_rate                   ,
      exempted_flag                  ,
      certificate_issue_date         ,
      created_by                     ,
      creation_date                  ,
      last_updated_by                ,
      last_update_date               ,
      last_update_login
    )
    select
      p_batch_id                    ,
      jrp.check_id                  ,
      jrp.check_number              ,
      jrp. check_deposit_date       ,
      jrp.challan_no                ,
      jrp.check_date                ,
      jrp.bsr_code                  ,
      jra.source_ref_document_id    ,
      jra.party_id                  ,
      jra.party_site_id             ,
      p_collection_code             ,
      jrt.tax_rate                  ,
      jrt.exempted_flag             ,
      jrc.issue_date                ,
      fnd_global.user_id            ,
      sysdate                       ,
      fnd_global.user_id            ,
      sysdate                       ,
      fnd_global.login_id
    from
      jai_ap_rgm_payments  jrp,
      jai_rgm_refs_all     jra,
      jai_rgm_taxes        jrt,
      jai_rgm_certificates jrc
    where
      jrp.settlement_id = jra.settlement_id      and
      jrp.tax_authority_id  = p_tax_authority_id     and
      jrp.tax_authority_site_id = nvl(p_tax_authority_site_id,jrp.tax_authority_site_id) and
      jrp.org_tan_no          = p_org_tan_num       and
      jrt.tax_type    = 'TCS' and
      jrt.trx_ref_id  = jra.trx_ref_id and
      jrc.certificate_id = jra.certificate_id and
      jra.item_classification = p_collection_code and
      jra.source_document_date between p_from_date and p_to_date and
      jra.settlement_id is not null and
      jra.certificate_id is not null
      group by
      p_batch_id                    ,
      jrp.check_id                  ,
      jrp.check_number              ,
      jrp.check_date                ,
      jrp.challan_no                ,
      jrp.check_deposit_date        ,
      jrp.bsr_code                  ,
      jra.source_ref_document_id    ,
      jra.party_id                  ,
      jra.party_site_id             ,
      jra.item_classification       ,
      jrt.tax_rate                  ,
      jrt.exempted_flag                    ,
      jrc.issue_date ;

      FOR rec in c_get_recs
      LOOP

        ln_line_amt := null ;
        ln_tcs_amount := null ;
        ln_surcharge_amount := null ;
        ln_tcs_cess_amount := null ;
        ln_sur_cess_amount := null ;
        ln_cess_amount := null ;

-- Date 03/07/2007 by sacsethi for bug 6157120
	ln_tcs_sh_cess_amount := null ;

        open c_line_amt(rec.source_document_id,  rec.tcs_check_id) ;
        fetch c_line_amt into ln_line_amt ;
        close c_line_amt ;

        open c_tax_amount(jai_constants.tax_type_tcs,rec.source_document_id, rec.tcs_check_id ) ;
        fetch c_tax_amount into ln_tcs_amount ;
        close c_tax_amount ;

        open c_tax_amount(jai_constants.tax_type_tcs_surcharge, rec.source_document_id, rec.tcs_check_id ) ;
        fetch c_tax_amount into ln_surcharge_amount ;
        close c_tax_amount ;

        open c_tax_amount(jai_constants.tax_type_tcs_cess, rec.source_document_id, rec.tcs_check_id ) ;
        fetch c_tax_amount into ln_tcs_cess_amount ;
        close c_tax_amount ;

        open c_tax_amount(jai_constants.tax_type_tcs_surcharge_cess, rec.source_document_id, rec.tcs_check_id ) ;
        fetch c_tax_amount into ln_sur_cess_amount ;
        close c_tax_amount ;

-- Date 03/07/2007 by sacsethi for bug 6157120

        open c_tax_amount(jai_constants.tax_type_sh_tcs_edu_cess, rec.source_document_id, rec.tcs_check_id ) ;
        fetch c_tax_amount into ln_tcs_sh_cess_amount ;
        close c_tax_amount ;

        ln_cess_amount := ln_tcs_cess_amount + ln_sur_cess_amount + ln_tcs_sh_cess_amount  ;  -- Date 03/07/2007 by sacsethi for bug 6157120

        open c_pan_no(rec.party_id) ;
        fetch c_pan_no into lv_pan_no ;
        close c_pan_no ;

        lv_pan_no := substr(lv_pan_no, 1,10);

        open c_buyer_code(rec.party_id) ;
        fetch c_buyer_code into lv_customer_type ;
        close c_buyer_code ;

        open c_source_ref_type(rec.source_document_id);
        fetch c_source_ref_type into lv_source_ref_type ;
        close c_source_ref_type ;

        lv_source_ref_type := substr(lv_source_ref_type, 1,50);

        IF lv_source_ref_type = jai_constants.trx_type_inv_comp THEN
          open c_inv_date(rec.source_document_id) ;
          fetch c_inv_date into lv_doc_date ;
          close c_inv_date ;
        ELSIF lv_source_ref_type = jai_constants.ar_cash_tax_confirmed THEN
          open c_rcpt_date(rec.source_document_id) ;
          fetch c_rcpt_date into lv_doc_date ;
          close c_rcpt_date ;
        END IF ;


	-- Date 28/06/2007 by sacsethi for bug 6157120
	-- Commenting this code because of no use
/*
	OPEN c_check_dtls(rec.check_number);
        FETCH c_check_dtls INTO v_bank_account_id ;
        CLOSE c_check_dtls;

        OPEN c_bank_branch_code(v_bank_account_id);
        FETCH c_bank_branch_code INTO v_bank_branch_code;
        CLOSE c_bank_branch_code;

        v_bank_branch_code := substr(v_bank_branch_code, 1,10);
  */

        FND_FILE.put_line(FND_FILE.log, ' lv_customer_type : ' || lv_customer_type || 'lv_pan_no : ' || lv_pan_no || ' lv_doc_date : ' || lv_doc_date ||
        ' v_bank_branch_code : ' || v_bank_branch_code ) ;

        update jai_ar_etcs_t
        set
            line_amt      = ln_line_amt         ,
            tcs_amt       = ln_tcs_amount       ,
            surcharge_amt = ln_surcharge_amount ,
            cess_amt      = ln_cess_amount      ,
            party_code    = lv_customer_type    ,
            party_pan     = lv_pan_no           ,
            source_document_date = lv_doc_date  ,
            source_document_type = lv_source_ref_type -- ,
            --bank_branch_code  = v_bank_branch_code
        where current of c_get_recs;

      END LOOP ;

  END populate_details;

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
    --p_collector_status            IN VARCHAR2 DEFAULT NULL    /*Bug 8880543 - Commeted for eTDS/eTCS FVU Changes*/
    )
  IS

    -- Date 28/06/2007 by sacsethi for bug 6157120

    CURSOR c_pan_number(p_organization_id IN NUMBER) IS
    Select ATTRIBUTE_VALUE
    from jai_rgm_org_regns_v jrorv  ,HR_ORGANIZATION_INFORMATION hrou
    where jrorv.attribute_code = jai_constants.pan_no AND
          hrou.org_information_context= jai_constants.accounting_information and
	  hrou.organization_id = p_organization_id  and
          jrorv.ORGANIZATION_ID =  hrou.org_information3 AND
          jrorv.REGIME_CODE = jai_constants.tds_regime ;
/*
    SELECT attribute2
    FROM hr_all_organization_units
    WHERE organization_id = p_organization_id;*/

      -- to get financial and assessment years
    CURSOR c_fin_year(p_tan_number IN varchar2, p_fin_year IN NUMBER) IS
    SELECT start_date, end_date
    FROM JAI_AP_TDS_YEARS
    WHERE tan_no  = p_tan_number --Date 26/05/2007 by sacsethi for bug 6153881
    AND fin_year = p_fin_year;

    -- gives Location_id linked to Organization
    CURSOR c_location_linked_to_org(p_organization_id IN NUMBER) IS
      SELECT location_id
      FROM hr_all_organization_units
      WHERE organization_id = p_organization_id;

    v_location_id   hr_all_organization_units.location_id%TYPE ;

    -- to get address details of location linked to given organization
    CURSOR c_address_details(p_location_id IN NUMBER) IS
      SELECT location_code, address_line_1, address_line_2, address_line_3, null, null,
        replace(postal_code, ' ') postal_code
      FROM hr_locations_all
      WHERE location_id = p_location_id;

    CURSOR c_get_errors(cp_batch_id JAI_AP_ETDS_T.batch_id%TYPE ) IS
     Select Error_Message from jai_ap_etds_errors_t
     where batch_id = cp_batch_id ;

    ln_errors_exist number ;

    v_location_code   HR_LOCATIONS_ALL.location_code%TYPE;
    v_tan_address1    HR_LOCATIONS_ALL.address_line_1%TYPE;
    v_tan_address2    HR_LOCATIONS_ALL.address_line_2%TYPE;
    v_tan_address3    HR_LOCATIONS_ALL.address_line_3%TYPE;
    v_tan_address4    VARCHAR2(75);
    v_tan_address5    VARCHAR2(75);
    v_postal_code     HR_LOCATIONS_ALL.postal_code%TYPE;
    v_tan_pin     NUMBER(6);

    ln_batch_id number ;
    lv_etcs_yearly_returns varchar2(1) ;
    v_conc_request_id NUMBER(15) ;
    v_deductor_pan  VARCHAR2(200);
    v_start_date JAI_AP_TDS_YEARS.start_date%type ;
    v_end_date   JAI_AP_TDS_YEARS.end_date%type;

    -- File Header variables
    v_line_number NUMBER(9);
    v_record_type CHAR(2);
    v_file_type   CHAR(3) ;
    v_quartfile_type   CHAR(3);
    v_upload_type CHAR(1);
    v_file_creation_date  date ;
    v_file_sequence_number  NUMBER(9);
    v_seller_tan      VARCHAR2(10);
    v_number_of_batches   NUMBER(9) ;
    v_return_prep_util    VARCHAR2(75); /*Bug 8880543 - Added for eTDS/eTCS FVU*/

    -- Quarterly File Header Variables
    v_fh_recordHash      varchar2(1);
    v_fh_fvuVersion      varchar2(1);
    v_fh_fileHash        varchar2(1);
    v_fh_samVersion       varchar2(1);
    v_fh_samHash         varchar2(1);
    v_fh_scmVersion      varchar2(1);
    v_fh_scmHash         varchar2(1);
    p_return_code    VARCHAR2(1) ;
    p_return_message VARCHAR2(2000) ;
    lv_generate_headers VARCHAR2(1) ;
    v_uploader_type varchar2(1);

    -- Batch Header

    v_totTaxDeductedAsPerChallan NUMBER;
    v_totTaxDeductedAsPerDeductee NUMBER;
    v_challan_cnt NUMBER(9) := 0;
    v_deductee_cnt  NUMBER(9) := 0;
    v_batch_number  NUMBER(9);
    v_form_number CHAR(4)     ;
    v_financial_year VARCHAR2(6);
    v_assessment_year VARCHAR2(6);
    v_ack_num_tan_app NUMBER(14);
    v_pro_rcpt_num_org_ret NUMBER(14);
    v_filler1                 VARCHAR2(1)   ;
    v_filler2                 VARCHAR2(1)   ;
    v_filler3                 VARCHAR2(1)   ;
    v_filler4                 VARCHAR2(1)   ;
    v_seller_name VARCHAR2(75);
    v_quarterlyOrYearly VARCHAR2(2) ;
    v_addrChangedSinceLastReturn VARCHAR2(1);
    v_seller_type VARCHAR2(1); /*Bug 8880543 - Chnaged Seller Status to Seller Type*/
    v_personNameRespForDedection VARCHAR2(75);
    v_personDesgnRespForDedection VARCHAR2(20);
    v_tan_state_code NUMBER(2);
    lv_dummy_date             date;

    -- Quarterly Batch Header variables
    v_bh_trnType VARCHAR2(1);
    v_bh_batchUpd VARCHAR2(1);
    v_bh_org_RRRno VARCHAR2(1);
    v_bh_prev_RRRno VARCHAR2(1);
    v_bh_RRRno      VARCHAR2(1);
    v_bh_RRRdate    VARCHAR2(1);
    v_bh_deductor_last_tan VARCHAR2(1);
    v_deductor_branch      VARCHAR2(75);
    v_deductor_email  VARCHAR2(75);
    v_deductor_stdCode NUMBER(5);
    v_deductor_phoneNo NUMBER(10);
    v_RespPerson_address2 VARCHAR2(25);
    v_RespPerson_address3 VARCHAR2(25);
    v_RespPerson_address4 VARCHAR2(25);
    v_RespPerson_address5 VARCHAR2(25);
    v_RespPerson_email    VARCHAR2(75);
    v_RespPerson_remark   VARCHAR2(75);
    v_RespPerson_stdCode  NUMBER(5);
    v_RespPerson_phoneNo  NUMBER(10);
    v_bh_tds_circle       CHAR(1);
    v_bh_salaryRecords_count  CHAR(1);
    v_bh_gross_total      CHAR(1);
    v_ao_approval         varchar2(1);
    v_ao_approval_number  VARCHAR2(15);
    /*Bug 8880543 - Start*/
    v_last_collector_type               VARCHAR2(1)  ;
    v_state_name                       VARCHAR2(2)  ;
    v_pao_code                         VARCHAR2(20) ;
    v_ddo_code                         VARCHAR2(20) ;
    v_ministry_name                    VARCHAR2(3)  ;
    v_ministry_name_other              VARCHAR2(150);
    v_pao_registration_no              NUMBER(10)   ;
    v_ddo_registration_no              VARCHAR2(10) ;
    v_challan_number                   VARCHAR2(10) ;
    v_return_message                   VARCHAR2(240);
    v_err                              VARCHAR2(1)  ;
    /*Bug 8880543 - End*/
    v_quart_form_number   varchar2(4);
    v_bh_recHash          varchar2(1);

    cursor c_deductee_cnt
    is
    select count(1), nvl(sum(tcs_amt + surcharge_amt + cess_amt),0)
    from
      jai_ar_etcs_t
    where
      batch_id = ln_batch_id ;

    CURSOR c_quart_deductee_cnt(cp_batch_id IN NUMBER , cp_check_number IN NUMBER ) IS
      select sum ( count( distinct tcs_tax_rate ) )
      from jai_ar_etcs_t
      WHERE  batch_id = cp_batch_id
      and    check_number = cp_check_number
      group  by  source_document_id, tcs_tax_rate, exempted_flag ;


    cursor c_challan_cnt
    is
    select count(1)
    from
      (  select 1
        from
          jai_ar_etcs_t
        where
          batch_id = ln_batch_id
          group by
            NVL(challan_no, 'No Challan Number'),
            NVL(challan_date,lv_dummy_date),
            NVL(bank_branch_code,'No Bank Branch'),
            NVL(tcs_check_id  ,  -1 )
     )     ;


    --Challan Detail

    v_challan_dtl_slno        number      ;
    v_collection_code         varchar2(1) ;
    ln_amt_of_oth             number(14);
    v_tcs_section             varchar2(5) ;

    -- Quarterly Challan Detail
    v_nil_challan_indicator     char(1);
    v_q_deductee_cnt            number(9);
    v_last_bank_challan_no      varchar2(1);
    v_last_transfer_voucher_no  varchar2(1);
    v_transfer_voucher_no       number(9);
    v_last_bank_branch_code     varchar2(1);
    v_challan_lastDate          varchar2(1);
    v_filler5                   varchar2(1);
    v_last_total_depositAmt     varchar2(1);
    v_remarks                   varchar2(14);
    V_ch_recHash                varchar2(1);
    v_total_deposit             number(15);
    v_bank_branch_code          varchar2(7);
    v_ch_updIndicator           varchar2(1);
    ln_amt_of_tds               number(15);

    v_check_number              NUMBER;

    CURSOR c_challan_records(p_batch_id IN NUMBER) IS
    select NVL(bank_branch_code,'No Bank Branch') bank_branch_code,
           NVL(challan_no,'No Challan Number') challan_no,
           NVL(challan_date,lv_dummy_date) challan_date,
           check_number check_number,
           tcs_check_id ,
           sum(tcs_amt + surcharge_amt + cess_amt ) total_tcs_amount,
           sum(tcs_amt) tcs_amt,
           sum(surcharge_amt) surcharge_amt,
           sum(cess_amt) cess_amt
    from   jai_ar_etcs_t a
    where a.batch_id = p_batch_id
    group by  NVL(bank_branch_code,'No Bank Branch'),
             NVL(challan_no,'No Challan Number'), NVL(challan_date,lv_dummy_date),
             check_number, tcs_check_id;

    cd c_challan_records%ROWTYPE ;

    cursor c_book_entry(cp_check_id number)
    is
    select nvl(book_entry_deposited,'N')
    from jai_ap_rgm_payments
    where check_id = cp_check_id ;

    v_book_entry              VARCHAR2(1) ;

    -- Deductee Detail
    v_challan_line_num        number ;
    v_party_name              hz_parties.party_name%type ;
    v_deductee_state_code     number;
    v_reason_for_nDeduction   varchar2(1);
    ln_diff_rate              number ;
    v_deductee_slno           number ;
    v_book_ent_oth            varchar2(1);
    v_filler6                 varchar2(1)   ;
    v_filler                  number(14);
    v_section_code            varchar2(5) ;

    -- Quarterly Deductee detail
    v_dh_mode                 varchar2(1);
    v_emp_serial_no           varchar2(1);
    v_last_emp_pan            varchar2(1);
    v_last_emp_pan_refno      varchar2(1);
    v_party_pan_ref_no        varchar2(10);
    v_last_total_tax_deducted varchar2(1);
    v_last_total_tax_deposit  varchar2(1);
    v_deposit_date            varchar2(1);
    v_grossingUp_ind          varchar2(1);
    v_certificate_issue_date  varchar2(1);
    v_remarks2                varchar2(1);
    v_remarks3                varchar2(1);
    v_dh_recHash              varchar2(1);
    v_quart_deductee_code     varchar2(1);


    /*
    Bug 8429168 - Customer Account ID was passed as parameter
    Hence joined hz_parties and hz_cust_accounts to get Party Name
    */
    cursor c_cust_name(cp_customer_id in number)
    is
    select hp.party_name
    from   hz_parties hp, hz_cust_accounts hca
    where  hca.cust_account_id = cp_customer_id
    and    hca.party_id = hp.party_id;


    cursor c_cust_site_dtls (cp_party_site_id number)
    is
    select
      address1,
      address2,
      address3,
      address4,
      city,
      state,
      postal_code
    from
      ar_addresses_v
    where
      address_id = cp_party_site_id ;

    v_site_dtls   c_cust_site_dtls%rowtype;

    cursor c_state_code(p_state_name in varchar2) is
      select meaning
      from fnd_common_lookups
      where lookup_type = 'IN_STATE'
      and lookup_code = p_state_name;

    cursor c_deductee_records(p_batch_id in number, p_challan_line_num in number) is
     select
          party_id,challan_line_num, party_site_id,exempted_flag,
          party_code, party_pan,source_document_id,
          NVL(bank_branch_code,'No Bank Branch') bank_branch_code,
          NVL(challan_no,'No Challan Number')   challan_no,
          NVL(challan_date,lv_dummy_date)        challan_date,
          check_number,
          tcs_tax_rate,
          sum(line_amt)                        line_amount,
          max(certificate_issue_date)          certificate_issue_date,
          max(source_document_date)            transaction_date ,
          max(tcs_check_date)                  tcs_check_date,
          sum(tcs_amt)                         tcs_amt,
          sum(surcharge_amt)                   surcharge_amt,
          sum(cess_amt)                        cess_amt,
          sum(tcs_amt + surcharge_amt + cess_amt ) total_tcs_amount
      from jai_ar_etcs_t  a
      where a.batch_id = p_batch_id and
            challan_line_num = NVL(p_challan_line_num, challan_line_num)
      group by
            challan_line_num, party_id, party_site_id,exempted_flag, tcs_tax_rate,
            check_number,party_code, party_pan,
            NVL(bank_branch_code,'No Bank Branch'),
            NVL(challan_no,'No Challan Number')  ,
            NVL(challan_date,lv_dummy_date)      ,
            source_document_id ;

    dd c_deductee_records%ROWTYPE ;

      PROCEDURE process_deductee_records
      IS
       v_deductee_total_tax_deducted number(15);
       v_quart_book_ent_oth       varchar2(1);
      BEGIN
        OPEN c_deductee_records(ln_batch_id, v_challan_line_num) ;
        LOOP
         FETCH c_deductee_records INTO dd ;
         EXIT WHEN
          c_deductee_records%NOTFOUND ;

          v_party_name := null;
          v_site_dtls := null;
          v_reason_for_nDeduction := null;
          v_filler := null;
          v_deductee_state_code := null;
          v_reason_for_nDeduction := null;
          ln_diff_rate :=null;

          v_line_number := v_line_number + 1;
          v_deductee_slno := v_deductee_slno + 1;

          OPEN  c_cust_name(dd.party_id);
          FETCH c_cust_name INTO v_party_name;
          CLOSE c_cust_name;

          OPEN  c_cust_site_dtls(dd.party_site_id);
          FETCH c_cust_site_dtls INTO v_site_dtls;
          CLOSE c_cust_site_dtls;

          OPEN  c_state_code(v_site_dtls.state);
          FETCH c_state_code INTO v_deductee_state_code;
          CLOSE c_state_code;

          IF v_deductee_state_code IS NULL THEN
            v_deductee_state_code := 99;
          END IF;

          v_book_ent_oth := ' ';
          v_batch_number := '000000001' ;
          v_section_code := '206C ' ;

          IF lv_etcs_yearly_returns = 'Y' THEN

            IF dd.exempted_flag = 'SR'  THEN
              v_reason_for_nDeduction := 'Y';
            ELSE
              v_reason_for_nDeduction := 'X';
            END IF;

            create_deductee_detail
            (
                p_line_number            =>    v_line_number,
                p_record_type            =>    v_record_type,
                p_batch_number           =>    v_batch_number,
                p_deductee_slno          =>    v_deductee_slno,
                p_deductee_section       =>    v_section_code,
                p_deductee_code          =>    dd.party_code,
                p_deductee_pan           =>    dd.party_pan,
                p_deductee_name          =>    v_party_name,
                p_deductee_address1      =>    v_site_dtls.address1,
                p_deductee_address2      =>    v_site_dtls.address2,
                p_deductee_address3      =>    v_site_dtls.address3,
                p_deductee_address4      =>    v_site_dtls.address4,
                p_deductee_address5      =>    v_site_dtls.city,
                p_deductee_state         =>    v_deductee_state_code,
                p_deductee_pin           =>    v_site_dtls.postal_code,
                p_purchase_amount        =>    dd.line_amount,
                p_payment_amount         =>    dd.line_amount,
                p_payment_date           =>    dd.challan_date,
                p_book_ent_oth           =>    v_book_ent_oth,
                p_tax_rate               =>    dd.tcs_tax_rate,
                p_filler6                =>    v_filler6,
                p_tax_deducted           =>    dd.total_tcs_amount,
                p_tax_deducted_date      =>    dd.transaction_date,
                p_tax_payment_date       =>    dd.tcs_check_date,
                p_bank_branch_code       =>    dd.bank_branch_code,
                p_challan_no             =>    dd.challan_no,
                p_tds_certificate_date   =>    dd.certificate_issue_date,
                p_reason_for_nDeduction  =>    v_reason_for_nDeduction,
                p_filler7                =>    v_filler
            );
          ELSE

            IF dd.exempted_flag = 'SR'  THEN
              v_reason_for_nDeduction := 'B';
            ELSE
              v_reason_for_nDeduction := 'A';
            END IF;

            IF dd.party_code = '01' THEN
               v_quart_deductee_code := '1' ;
            ELSIF dd.party_code = '02' THEN
               v_quart_deductee_code := '2' ;
            END IF ;

            v_deductee_total_tax_deducted := dd.tcs_amt+dd.surcharge_amt + dd.cess_amt ;
            v_quart_book_ent_oth := 'N' ;

            p_return_code    := null ;
            p_return_message := null ;
            v_dh_mode :='O';

            jai_etcs_pkg.validate_party_detail
              ( p_line_number                 => v_line_number  ,
                p_record_type                 => v_record_type  ,
                p_batch_number                => v_batch_number ,
                p_challan_line_num            => dd.challan_line_num   ,
                p_party_slno                  => v_deductee_slno  ,
                p_dh_mode                     => v_dh_mode  ,
                p_quart_party_code            => v_quart_deductee_code  ,
                p_party_pan                   => dd.party_pan ,
                p_party_name                  => v_party_name  ,
                p_tcs_amt                     => dd.tcs_amt,
                p_surcharge_amt               => dd.surcharge_amt   ,
                p_cess_amt                    => dd.cess_amt   ,
                p_party_total_tax_deducted    => v_deductee_total_tax_deducted,
                p_base_taxabale_amount        => dd.tcs_amt ,
                p_gl_date                     => dd.challan_date         ,
                p_book_ent_oth                => v_book_ent_oth,
                p_tcs_tax_rate                => dd.tcs_tax_rate,
                p_total_purchase              => dd.tcs_amt,
                p_party_total_tax_deposit     =>v_deductee_total_tax_deducted,
                p_return_code                 => p_return_code,
                p_return_message              => p_return_message
               );

      IF p_return_code = 'E' THEN
              IF lv_action = 'V' THEN
                INSERT INTO jai_ap_etds_errors_t
                (batch_id, record_type,  reference_id, error_message) VALUES
                ( ln_batch_id,'DD', v_line_number, p_return_message ) ;
              ELSE
                p_ret_code := jai_constants.request_error ;
                p_err_buf := p_return_message ;
                RETURN ;
              END IF ;
            END IF ;

      lv_generate_headers := null ;
            IF p_action <> 'V' THEN
              IF p_action = 'F' THEN
                lv_generate_headers := 'N' ;
              ELSIF p_action = 'H' THEN
                lv_generate_headers := 'Y' ;
              END IF ;

              jai_etcs_pkg.create_quart_party_dtl
               (
                p_line_number                 => v_line_number,
                p_record_type                 => v_record_type,
                p_batch_number                => v_batch_number,
                p_dh_challan_recNo            => v_challan_dtl_slno,
                p_party_slno                  => v_deductee_slno,
                p_dh_mode                     => v_dh_mode,
                p_emp_serial_no               => v_emp_serial_no,
                p_party_code                  => v_quart_deductee_code,
                p_last_emp_pan                => v_last_emp_pan,
                p_party_pan                   => dd.party_pan,
                p_last_emp_pan_refno          => v_last_emp_pan_refno,
                p_party_pan_refno             => v_party_pan_ref_no,
                p_party_name                  => v_party_name,
                p_party_tcs_income_tax        => dd.tcs_amt ,
                p_party_tcs_surcharge         => dd.surcharge_amt,
                p_party_tcs_cess              => dd.cess_amt,
                p_party_total_tax_deducted    => v_deductee_total_tax_deducted,
                p_last_total_tax_deducted     => v_last_total_tax_deducted,
                p_party_total_tax_deposit     => v_deductee_total_tax_deducted,
                p_last_total_tax_deposit      => v_last_total_tax_deposit,
                p_total_purchase              => dd.tcs_amt,
                p_base_taxabale_amount        => dd.tcs_amt,
                p_gl_date                     => dd.challan_date        ,
                p_tcs_invoice_date            => dd.challan_date,
                p_deposit_date                => v_deposit_date,
                p_tcs_tax_rate                => dd.tcs_tax_rate,
                p_grossingUp_ind              => v_grossingUp_ind,
                p_book_ent_oth                => v_quart_book_ent_oth,
                p_certificate_issue_date      => v_certificate_issue_date,
                p_remarks1                    => v_reason_for_nDeduction,
                p_remarks2                    => v_remarks2,
                p_remarks3                    => v_remarks3,
                p_dh_recHash                  => v_dh_recHash,
                p_generate_headers            => lv_generate_headers
               );

            END IF ;

    END IF ;

          UPDATE jai_ar_etcs_t
          SET deductee_line_num = v_line_number
          WHERE batch_id = ln_batch_id
            and challan_line_num                          = dd.challan_line_num
            and party_id                                  = dd.party_id
            and party_site_id                             = dd.party_site_id
            and exempted_flag                             = dd.exempted_flag
            and NVL(bank_branch_code,'No Bank Branch')    = NVL(dd.bank_branch_code,'No Bank Branch')
            and NVL(challan_no,'No Challan Number')       = NVL(dd.challan_no,'No Challan Number')
            and NVL(challan_date,lv_dummy_date)           = NVL(dd.challan_date,lv_dummy_date)
            and check_number                              = dd.check_number
            and tcs_tax_rate                              = dd.tcs_tax_rate
            and source_document_id                        = dd.source_document_id ;

        END LOOP;

        CLOSE c_deductee_records ;
      END process_deductee_records;

  BEGIN
    lv_dummy_date    := TO_DATE('01/01/1600', 'DD/MM/RRRR');

    v_conc_request_id := FND_PROFILE.value('CONC_REQUEST_ID');
    SELECT JAI_AP_ETDS_T_S.nextval INTO ln_batch_id FROM DUAL;
    v_line_number   := 0;


     IF NVL(p_period,'XX') = 'XX' THEN
       lv_etcs_yearly_returns := 'Y' ;
       FND_FILE.put_line(FND_FILE.log, '~~~~Ver:115.0~~~~ Start of eTCS File Creation for Yearly Returns
          Batch_id->'||ln_batch_id ||', Creation Date->'||to_char(SYSDATE,'dd-mon-yyyy hh24:mi:ss')||' ~~~~~~~~~~~~~~~~~~');
     ELSE
        lv_etcs_yearly_returns := 'N' ;
         FND_FILE.put_line(FND_FILE.log, '~~~~Ver:115.0~~~~ Start of eTCS File Creation for Quarterly returns
          Batch_id->'||ln_batch_id || 'Period : ' || p_period ||', Creation Date->' ||
          to_char(SYSDATE,'dd-mon-yyyy hh24:mi:ss')||' ~~~~~~~~~~~~~~~~~~');
     END IF ;

      IF NVL(p_action,'X') <> 'V' THEN
        IF NVL(p_generate_headers,'X') = 'Y' or NVL(p_action,'X') = 'H' THEN
          jai_ap_tds_etds_pkg.v_debug_pad_char := ' ';
          jai_ap_tds_etds_pkg.v_generate_headers := TRUE;
        ELSE
          jai_ap_tds_etds_pkg.v_debug_pad_char := '';
          jai_ap_tds_etds_pkg.v_generate_headers := FALSE;
        END IF;
      END IF ;

    IF length(p_tan_number) > 10 THEN
      FND_FILE.put_line(FND_FILE.log, 'Tan Number length is greater than 10 characters');
      RAISE_APPLICATION_ERROR(-20014, 'Tan Number length is greater than 10 characters', true);
    END IF;


    -- Date 26/05/2007 by sacsethi for bug 6153881
    -- Mark Legal_Entity_id as null

    INSERT INTO JAI_AP_ETDS_REQUESTS(
      batch_id, request_id,  legal_entity_id , org_tan_number, financial_year,
      tax_authority_id, tax_authority_site_id, organization_id,
      deductor_name, deductor_state, addr_changed_since_last_ret,
      --deductor_status, /*Bug 8880543 - Commented Deductor Status for eTDS/eTCS FVU Changes*/
      person_resp_for_deduction, designation_of_pers_resp, challan_start_date,
      challan_end_date, file_path, filename ,
      created_by ,creation_date , last_updated_by , last_update_date , last_update_login     -- Date 28/06/2007 by sacsethi for bug 6157120
    ) VALUES (
      ln_batch_id, v_conc_request_id, null  , p_tan_number, p_fin_year,
      p_tax_authority_id, p_tax_authority_site_id, p_organization_id,
      p_seller_name, p_seller_state, p_addrChangedSinceLastRet,
      --p_collector_status, /*Bug 8880543 - Commented Deductor Status for eTDS/eTCS FVU Changes*/
      p_persRespForCollection, p_desgOfPersResponsible, p_Start_Date,
      p_End_Date, p_file_path, p_filename ,
      fnd_global.user_id , sysdate , fnd_global.user_id , sysdate ,fnd_global.login_id  -- Date 28/06/2007 by sacsethi for bug 6157120
    );

    -- Fetching the Pan Number based on TAN
    OPEN c_pan_number(p_organization_id);
    FETCH c_pan_number INTO v_deductor_pan;
    CLOSE c_pan_number;

    IF v_deductor_pan IS NULL THEN
      FND_FILE.put_line(FND_FILE.log, 'Pan Number cannot be retreived based on given TAN Number');
      RAISE_APPLICATION_ERROR(-20015, 'Pan Number cannot be retreived based on given TAN Number', true);
    END IF;

    -- Fetching Start Date and End date of given Financial Year
    OPEN c_fin_year(p_tan_number, p_fin_year);
    FETCH c_fin_year INTO v_start_date, v_end_date;
    CLOSE c_fin_year;

    IF v_start_date IS NULL OR v_end_date IS NULL THEN
      FND_FILE.put_line(FND_FILE.log, 'Cannot get values for Financial Year and Assessment Year');
      RAISE_APPLICATION_ERROR( -20016, 'Cannot get values for Financial Year and Assessment Year');
    END IF;

    -- Fetching Location linked to Input Organization from where address details are captured
    OPEN c_location_linked_to_org(p_organization_id);
    FETCH c_location_linked_to_org INTO v_location_id;
    CLOSE c_location_linked_to_org;

    -- Shall Populate the Address Details of Batch Header
    OPEN c_address_details(v_location_id);
    FETCH c_address_details INTO v_location_code, v_tan_address1, v_tan_address2, v_tan_address3, v_tan_address4,
          v_tan_address5, v_postal_code;
    CLOSE c_address_details;

    -- checks for Pincode related to Address location
    IF length(v_postal_code) > 6 THEN
      RAISE_APPLICATION_ERROR(-20010, 'Postal Code of Location should not have more than 6 digit numbered value. Location Code (id):'||v_location_code||' ('||v_location_id||')');
    END IF;

    BEGIN
      v_tan_pin := to_number(v_postal_code);
    EXCEPTION
      WHEN VALUE_ERROR THEN
        RAISE_APPLICATION_ERROR(-20010, 'Postal Code of Location should be a 6 digit number. Location Code (id):'||v_location_code||' ('||v_location_id||')');
    END;

      populate_details
      (
        p_batch_id                =>   ln_batch_id             ,
        p_org_tan_num             =>   p_tan_number            ,
        p_tax_authority_id        =>   p_tax_authority_id      ,
        p_tax_authority_site_id   =>   p_tax_authority_site_id ,
        p_from_date               =>   p_Start_Date            ,
        p_to_date                 =>   p_end_Date              ,
        p_collection_code         =>   p_collection_code
      );


    BEGIN
      jai_etcs_pkg.openFile(p_file_path, p_filename);
    EXCEPTION
      WHEN OTHERS THEN
        FND_FILE.put_line(FND_FILE.log, 'Error Occured during opening of file(1):'||SQLERRM);
        RAISE_APPLICATION_ERROR(-20016, 'Error Occured(1):'||SQLERRM, true);
    END;

    IF p_action <> 'V' THEN
      FND_FILE.put_line(FND_FILE.log, 'Start File Header');
    END IF ;

    -- File Header (42 Chars)
    v_line_number := v_line_number + 1;
    v_record_type := 'FH';
    v_file_type   := 'NS3' ;
    v_upload_type := 'R' ;
    v_file_sequence_number := 1;
    v_seller_tan          := p_tan_number;
    v_file_creation_date  := sysdate;
    v_number_of_batches   := 1;
    v_quartfile_type      :='TC1';
    v_uploader_type :='D';

    get_attr_value (p_organization_id, 'RETURN_PREP_UTILITY', v_return_prep_util, v_err, v_return_message);
    chk_err(v_err, v_return_message);

    IF lv_etcs_yearly_returns = 'Y' THEN
      IF p_generate_headers = 'Y' THEN
        jai_etcs_pkg.create_fh(ln_batch_id);
      END IF;

      create_file_header
      (
         p_line_number          =>  v_line_number,
         p_record_type          =>   v_record_type,
         p_file_type            =>   v_file_type,
         p_upload_type          =>   v_upload_type,
         p_file_creation_date   =>   v_file_creation_date,
         p_file_sequence_number =>   v_file_sequence_number,
         p_deductor_tan         =>   v_seller_tan,
         p_number_of_batches    =>   v_number_of_batches
      );

    ELSE
      IF p_action = 'H' THEN
        jai_etcs_pkg.create_quarterly_fh(ln_batch_id, p_period,p_RespPersAddress, p_RespPersState, p_RespPersPin, p_RespPersAddrChange );
      END IF;

      p_return_code    := null ;
      p_return_message := null ;

      jai_etcs_pkg.validate_file_header
       ( p_line_number          => v_line_number ,
         p_record_type          => v_record_type ,
         p_quartfile_type       => v_quartfile_type,
         p_upload_type          => v_upload_type,
         p_file_creation_date   => v_file_creation_date,
         p_file_sequence_number => v_file_sequence_number,
         p_uploader_type        => v_uploader_type ,
         p_collector_tan        => v_seller_tan ,
         p_number_of_batches    => v_number_of_batches,
         p_period               => p_period,
         p_start_date           => p_start_date,
         p_end_date             => p_end_date,
         p_fin_year             => to_char(v_start_date,'YYYY'),
         p_return_prep_util     => v_return_prep_util, /*Bug 8880543 - Added for eTCS/eTCS FVU Changes*/
         p_return_code          => p_return_code,
         p_return_message       => p_return_message
       );

      IF p_return_code = 'E' THEN
        IF lv_action = 'V' THEN
           INSERT INTO jai_ap_etds_errors_t
           (batch_id, record_type,  error_message) values
           ( ln_batch_id, 'FH',  p_return_message ) ;
        ELSE
           p_ret_code := jai_constants.request_error ;
           p_err_buf := p_return_message ;
           RETURN ;
        END IF ;
      END IF ;

      lv_generate_headers := null ;
      IF p_action <> 'V' THEN
        IF p_action = 'F' THEN
          lv_generate_headers := 'N' ;
        ELSIF p_action = 'H' THEN
          lv_generate_headers := 'Y' ;
        END IF ;

        jai_etcs_pkg.create_quarterly_file_header
          (
            p_line_number              =>  v_line_number,
            p_record_type              =>  v_record_type,
            p_file_type                =>  v_quartfile_type,
            p_upload_type              =>  v_upload_type,
            p_file_creation_date       =>  v_file_creation_date,
            p_file_sequence_number     =>  v_file_sequence_number,
            p_uploader_type            =>  v_uploader_type,
            p_collector_tan            =>  v_seller_tan,
            p_number_of_batches        =>  v_number_of_batches,
            p_return_prep_util         =>  v_return_prep_util, /*Bug 8880543 - Added for eTDS/eTCS FVU Changes*/
            p_fh_recordHash            =>  v_fh_recordHash,
            p_fh_fvuVersion            =>  v_fh_fvuVersion,
            p_fh_fileHash              =>  v_fh_fileHash,
            p_fh_samVersion            =>  v_fh_samVersion,
            p_fh_samHash               =>  v_fh_samHash,
            p_fh_scmVersion            =>  v_fh_scmVersion,
            p_fh_scmHash               =>  v_fh_scmHash,
            p_generate_headers         =>  lv_generate_headers
          ) ;

      END IF ;

    END IF ;

   -- Batch Header (411 Chars)
    v_line_number                 := v_line_number + 1;
    v_record_type                 := 'BH';
    v_batch_number                := 1;
    v_form_number                 := '27E ';
    v_financial_year              := to_char(v_start_date, 'YYYY')||to_char(v_end_date, 'YY');
    v_assessment_year             := to_char(add_months(v_start_date,12), 'YYYY')||to_char(add_months(v_end_date,12), 'YY');
    v_seller_name                 := p_seller_name;
    v_addrChangedSinceLastReturn  := p_addrChangedSinceLastRet;
    --v_seller_status               := 'O'; /*Bug 8880543 - To be fetched from Regime Registration Setup*/
    v_quarterlyOrYearly           := 'Y';
    v_personNameRespForDedection  := p_persRespForCollection;
    v_personDesgnRespForDedection := p_desgOfPersResponsible;
    v_tan_state_code              := to_number(p_seller_state);
    v_ao_approval                 :='N';
    v_quart_form_number           :='27EQ';


    open c_deductee_cnt;
    fetch c_deductee_cnt into v_deductee_cnt, v_totTaxDeductedAsPerDeductee ;
    close c_deductee_cnt ;

    open c_challan_cnt  ;
    fetch c_challan_cnt into v_challan_cnt ;
    close c_challan_cnt ;

    v_totTaxDeductedAsPerChallan := v_totTaxDeductedAsPerDeductee ;

    IF p_action <> 'V' THEN
      FND_FILE.put_line(FND_FILE.log, 'Batch Header');
    END IF ;

    v_ack_num_tan_app := NULL;
    v_pro_rcpt_num_org_ret := nvl(p_pro_rcpt_num_org_ret,0);

    /*Bug 8880543 - Fetch Attribute values for eTDS/eTCS FVU Changes - Start*/
    get_attr_value (p_organization_id, 'COLLECTOR_TYPE', v_seller_type, v_err, v_return_message);
    chk_err(v_err, v_return_message);
    get_attr_value (p_organization_id, 'STATE', v_state_name, v_err, v_return_message);
    chk_err(v_err, v_return_message);
    get_attr_value (p_organization_id, 'MINISTRY_NAME', v_ministry_name, v_err, v_return_message);
    chk_err(v_err, v_return_message);
    get_attr_value (p_organization_id, 'PAO_CODE', v_pao_code, v_err, v_return_message);
    chk_err(v_err, v_return_message);
    get_attr_value (p_organization_id, 'DDO_CODE', v_ddo_code, v_err, v_return_message);
    chk_err(v_err, v_return_message);
    get_attr_value (p_organization_id, 'PAO_REGISTRATION_NO', v_pao_registration_no, v_err, v_return_message);
    chk_err(v_err, v_return_message);
    get_attr_value (p_organization_id, 'DDO_REGISTRATION_NO', v_ddo_registration_no, v_err, v_return_message);
    chk_err(v_err, v_return_message);

    IF v_ministry_name = '99' THEN
       select meaning into v_ministry_name_other
       from ja_lookups lkup
       where lkup.lookup_type = 'JAI_MIN_NAME_VALUES'
       and lkup.lookup_code = '99';
    else
       v_ministry_name_other := NULL;
    END IF;

    IF lv_etcs_yearly_returns = 'Y' THEN

      IF p_generate_headers = 'Y' THEN
          jai_ap_tds_etds_pkg.create_bh;
      END IF;

       jai_ap_tds_etds_pkg.create_batch_header(
          p_line_number                   =>  v_line_number,
          p_record_type                   =>  v_record_type,
          p_batch_number                  =>  v_batch_number,
          p_challan_count                 =>  v_challan_cnt,
          p_deductee_count                =>  v_deductee_cnt,
          p_form_number                   =>  v_form_number,
          p_filler1                       =>  v_filler1,
          p_deductor_tan                  =>  v_seller_tan,
          p_pan_of_tan                    =>  v_deductor_pan,
          p_assessment_year               =>  v_assessment_year,
          p_financial_year                =>  v_financial_year,
          p_deductor_name                 =>  v_seller_name,
          p_tan_address1                  =>  v_tan_address1,
          p_tan_address2                  =>  v_tan_address2,
          p_tan_address3                  =>  v_tan_address3,
          p_tan_address4                  =>  v_tan_address4,
          p_tan_address5                  =>  v_tan_address5,
          p_tan_state                     =>  v_tan_state_code,
          p_tan_pin                       =>  v_tan_pin,
          p_chng_addr_since_last_return   =>  v_addrChangedSinceLastReturn,
          p_type_of_deductor              =>  v_seller_type,    /*Modified the parameter Name - Bug 8880543*/
          p_quart_year_return             =>  v_quarterlyOrYearly,
          p_pers_resp_for_deduction       =>  v_personNameRespForDedection,
          p_pers_designation              =>  v_personDesgnRespForDedection,
          p_tot_tax_dedected_challan      =>  v_totTaxDeductedAsPerChallan,
          p_tot_tax_dedected_deductee     =>  v_totTaxDeductedAsPerDeductee,
          p_filler2                       =>  v_filler2,
          p_filler3                       =>  v_filler3,
          p_ack_num_tan_app               =>  v_ack_num_tan_app,
          p_pro_rcpt_num_org_ret          =>  v_pro_rcpt_num_org_ret,
          p_rrr_number                    =>  v_bh_RRRno,
					p_rrr_date                      => v_bh_RRRdate
       );

    ELSE
      IF p_action = 'H' THEN
        jai_etcs_pkg.create_quarterly_bh;
      END IF;

      p_return_code    := null ;
      p_return_message := null ;

       validate_batch_header
       ( p_line_number                  => v_line_number   ,
         p_record_type                  => v_record_type   ,
         p_batch_number                 => v_batch_number  ,
         p_challan_cnt                  => v_challan_cnt ,
         p_quart_form_number            => v_quart_form_number  ,
         p_collector_tan                => v_seller_tan  ,
         p_pan_of_tan                   => v_deductor_pan, /*Bug 8880543 - Added for PAN Number Validation for eTDS/eTCS FVU Changes*/
         p_assessment_year              => v_assessment_year,
         p_financial_year               => v_financial_year ,
         p_collector_name               => v_seller_name ,
         p_tan_address1                 => v_tan_address1  ,
         p_tan_state_code               => v_tan_state_code   ,
         p_tan_pin                      => v_tan_pin    ,
         p_collector_type               => v_seller_type , /*Modified the parameter Name - Bug 8880543*/
         p_addrChangedSinceLastReturn   => v_addrChangedSinceLastReturn,
         p_personNameRespForCollection  => v_personNameRespForDedection,
         p_personDesgnRespForCollection => v_personDesgnRespForDedection,
         p_RespPersAddress              => p_RespPersAddress   ,
         p_RespPersState                => p_RespPersState    ,
         p_RespPersPin                  => p_RespPersPin   ,
         p_RespPersAddrChange           => p_RespPersAddrChange ,
         p_totTaxCollectedAsPerParty    => v_totTaxDeductedAsPerDeductee,
         p_ao_approval                  => v_ao_approval,
         /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
         p_state_name                   => v_state_name,
         p_pao_code                     => v_pao_code,
         p_ddo_code                     => v_ddo_code,
         p_ministry_name                => v_ministry_name,
         p_pao_registration_no          => v_pao_registration_no,
         p_ddo_registration_no          => v_ddo_registration_no,
         /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
         p_return_code                  => p_return_code,
         p_return_message               => p_return_message
       );


       IF p_return_code = 'E' THEN
         IF lv_action = 'V' THEN
            insert into jai_ap_etds_errors_t(batch_id, record_type, error_message) values
            ( ln_batch_id, 'BH', p_return_message ) ;
         ELSE
            p_ret_code := jai_constants.request_error ;
            p_err_buf := p_return_message ;
            RETURN ;
         END IF ;
       END IF ;


      lv_generate_headers := null ;
      IF p_action <> 'V' THEN
        IF p_action = 'F' THEN
          lv_generate_headers := 'N' ;
        ELSIF p_action = 'H' THEN
          lv_generate_headers := 'Y' ;
       END IF ;

        jai_etcs_pkg.create_quarterly_batch_header
        (
            p_line_number                   => v_line_number,
            p_record_type                   => v_record_type,
            p_batch_number                  => v_batch_number,
            p_challan_count                 => v_challan_cnt,
            p_form_number                   => v_quart_form_number,
            p_trn_type                      => v_bh_trnType,
            p_batchUpd                      => v_bh_batchUpd,
            p_org_RRRno                     => v_bh_org_RRRno,
            p_prev_RRRno                    => v_bh_prev_RRRno,
            p_RRRno                         => v_bh_RRRno,
            p_RRRdate                       => v_bh_RRRdate,
            p_collector_last_tan            => v_bh_deductor_last_tan,
            p_collector_tan                 => v_seller_tan,
            p_filler1                       => v_filler1,
            p_collector_pan                 => v_deductor_pan,
            p_assessment_year               => v_assessment_year,
            p_financial_year                => v_financial_year,
            p_period                        => p_period,
            p_collector_name                => v_seller_name,
            p_collector_branch              => v_deductor_branch,
            p_tan_address1                  => v_tan_address1,
            p_tan_address2                  => v_tan_address2,
            p_tan_address3                  => v_tan_address3,
            p_tan_address4                  => v_tan_address4,
            p_tan_address5                  => v_tan_address5,
            p_tan_state_code                => v_tan_state_code,
            p_tan_pin                       => v_tan_pin,
            p_collector_email               => v_deductor_email,
            p_collector_stdCode             => v_deductor_stdCode,
            p_collector_phoneNo             => v_deductor_phoneNo,
            p_addrChangedSinceLastReturn    => v_addrChangedSinceLastReturn,
            p_type_of_collector             => v_seller_type, /*Modified Seller Status to Seller Type - Bug 8880543*/
            p_pers_resp_for_collection      => v_personNameRespForDedection,
            p_RespPerson_designation        => v_personDesgnRespForDedection,
            p_RespPerson_address1           => p_RespPersAddress,
            p_RespPerson_address2           => v_RespPerson_address2,
            p_RespPerson_address3           => v_RespPerson_address3,
            p_RespPerson_address4           => v_RespPerson_address4,
            p_RespPerson_address5           => v_RespPerson_address5,
            p_RespPerson_state              => p_RespPersState,
            p_RespPerson_pin                => p_RespPersPin,
            p_RespPerson_email              => v_RespPerson_email,
            p_RespPerson_remark             => v_RespPerson_remark,
            p_RespPerson_stdCode            => v_RespPerson_stdCode,
            p_RespPerson_phoneNo            => v_RespPerson_phoneNo,
            p_RespPerson_addressChange      => p_RespPersAddrChange,
            p_totTaxCollectedAsPerChallan   => round(v_totTaxDeductedAsPerDeductee),  -- decimal should be .00
            p_tds_circle                    => v_bh_tds_circle,
            p_salaryRecords_count           => v_bh_salaryRecords_count,
            p_gross_total                   => v_bh_gross_total,
            p_ao_approval                   => v_ao_approval     ,
            p_ao_approval_number            => v_ao_approval_number,
            /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
            p_last_collector_type           => v_last_collector_type,
            p_state_name                    => v_state_name,
            p_pao_code                      => v_pao_code,
            p_ddo_code                      => v_ddo_code,
            p_ministry_name                 => v_ministry_name,
            p_ministry_name_other           => v_ministry_name_other,
            p_filler2                       => v_filler2,
            p_pao_registration_no           => v_pao_registration_no,
            p_ddo_registration_no           => v_ddo_registration_no,
            /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
            p_recHash                       => v_bh_recHash,
            p_generate_headers              => lv_generate_headers
          ) ;
      END IF ;
    END IF ;

    IF p_action <> 'V' THEN
      FND_FILE.put_line(FND_FILE.log, 'Challan Detail');
    END IF ;

    v_record_type := 'CD';

    IF lv_etcs_yearly_returns = 'Y' THEN
      IF p_generate_headers = 'Y'  THEN
        create_cd;
      END IF ;
    END IF;

    v_challan_dtl_slno := 0;

    OPEN c_challan_records(ln_batch_id) ;
    LOOP
      FETCH c_challan_records INTO cd ;
      EXIT WHEN
       c_challan_records%NOTFOUND ;

      v_line_number := v_line_number + 1;
      v_challan_dtl_slno := v_challan_dtl_slno + 1;
      ln_amt_of_oth := 0;
      v_record_type := 'CD';
      v_tcs_section := '206C' ;
      v_collection_code := p_collection_code ;
      v_check_number := cd.check_number;

       IF cd.challan_date = lv_dummy_date THEN
         cd.challan_date := to_date(null) ;
       END IF ;

     IF lv_etcs_yearly_returns = 'Y' THEN

        jai_ap_tds_etds_pkg.create_challan_detail
        (
            p_line_number         =>       v_line_number,
            p_record_type         =>       v_record_type,
            p_batch_number        =>       v_batch_number,
            p_challan_slno        =>       v_challan_dtl_slno,
            p_challan_section     =>       v_tcs_section,
            p_amount_of_tds       =>       cd.tcs_amt,
            p_amount_of_surcharge =>       cd.surcharge_amt,
            p_amount_of_cess      =>       cd.cess_amt,
            p_amount_of_int       =>       ln_amt_of_oth,
            p_amount_of_oth       =>       ln_amt_of_oth,
            p_amount_deducted     =>       cd.total_tcs_amount,
            p_challan_num         =>       cd.challan_no,
            p_challan_date        =>       cd.challan_date,
            p_bank_branch_code    =>       cd.bank_branch_code,
            p_check_number        =>       cd.check_number,
            p_tds_dep_by_book     =>       'N'            ,
            p_filler4             =>       v_collection_code
         ) ;

     ELSE

       IF cd.challan_no = 'No Challan Number' THEN
         cd.challan_no := null ;
       END IF ;

       OPEN c_quart_deductee_cnt(ln_batch_id, cd.check_number) ;
       FETCH c_quart_deductee_cnt INTO v_q_deductee_cnt;
       CLOSE c_quart_deductee_cnt ;

       open c_book_entry(cd.tcs_check_id) ;
       fetch c_book_entry into v_book_entry ;
       close c_book_entry ;

       v_total_deposit            := cd.tcs_amt + cd.surcharge_amt + cd.cess_amt;
       v_nil_challan_indicator    := 'N' ;

       jai_ap_tds_etds_pkg.check_numeric(v_bank_branch_code, 'Check Number : ' || cd.check_number  || ' Bank Branch Code is not a Numeric Value ', p_action);

       FND_FILE.put_line(FND_FILE.log, 'create challan quarterly' );

       IF p_action = 'H'  THEN
         jai_etcs_pkg.create_quarterly_cd;
       END IF ;

       IF cd.challan_no IS NULL THEN
         v_bank_branch_code := null ;
       ELSE
         v_bank_branch_code := substr(cd.bank_branch_code,1,7);
       END IF ;


       p_return_code    := null ;
       p_return_message := null ;

       FND_FILE.put_line(FND_FILE.log, 'Validate Challan Detail' );

       validate_challan_detail
       (
            p_line_number           => v_line_number  ,
            p_record_type           => v_record_type  ,
            p_batch_number          => v_batch_number ,
            p_challan_dtl_slno      => v_challan_dtl_slno   ,
            p_party_cnt             => v_q_deductee_cnt ,
            p_nil_challan_indicat   => v_nil_challan_indicator,
            p_tcs_section           => v_collection_code,
            p_tcs_amt               => cd.tcs_amt    ,
            p_surcharge_amt         => cd.surcharge_amt  ,
            p_cess_amt              => cd.cess_amt  ,
            p_amt_of_oth            => ln_amt_of_oth   ,
            p_tcs_amount            => cd.total_tcs_amount   ,
            p_total_income_tcs      => v_total_deposit ,
            p_challan_no            => cd.challan_no,
            p_bank_branch_code      => cd.bank_branch_code,
            p_challan_Date          => cd.challan_date,
            p_check_number          => cd.check_number,
            p_amt_of_int            => round(ln_amt_of_oth),
            p_total_deposit         => v_total_deposit,
            p_tcs_income_tax        => cd.tcs_amt,
            p_tcs_surcharge         => cd.surcharge_amt,
            p_tcs_cess              => cd.cess_amt,
            p_tcs_interest_amt      => 0,
            p_tcs_other_amt         => 0,
            p_return_code           => p_return_code,
            p_return_message        => p_return_message
       );


        IF p_return_code = 'E' THEN
          IF lv_action = 'V' THEN
              insert into jai_ap_etds_errors_t
             (batch_id, record_type, reference_id, error_message) values
             ( ln_batch_id, 'CD', v_line_number, p_return_message ) ;
          ELSE
            p_ret_code := jai_constants.request_error ;
            p_err_buf := p_return_message ;
            RETURN ;
          END IF ;
        END IF ;


       lv_generate_headers := null ;
       IF p_action <> 'V' THEN
         IF p_action = 'F' THEN
           lv_generate_headers := 'N' ;
         ELSIF p_action = 'H' THEN
           lv_generate_headers := 'Y' ;
         END IF ;

         ln_amt_of_tds :=  cd.total_tcs_amount - round(cd.surcharge_amt) - round(cd.cess_amt) - round(ln_amt_of_oth) - round(ln_amt_of_oth) ;

         /*Bug 8880543 - Challan Number to be used only if deductor type is not A or S - Start*/
         IF (v_seller_type in ('A', 'S')) THEN
            v_transfer_voucher_no := to_number(cd.challan_no);
            v_challan_number := NULL;
            v_bank_branch_code := NULL;
            v_check_number := NULL;
            v_book_entry := 'Y';
         else
            v_challan_number := to_number(cd.challan_no);
            v_transfer_voucher_no := NULL;
            v_book_entry := 'N';
         END IF;
         /*Bug 8880543 - Challan Number to be used only if deductor type is not A or S - End*/

          create_quart_challan_dtl
          (
              p_line_number              => v_line_number,
              p_record_type              => v_record_type,
              p_batch_number             => v_batch_number,
              p_challan_dtl_slno         => v_challan_dtl_slno,
              p_collection_cnt           => v_q_deductee_cnt,
              p_nil_challan_indicator    => v_nil_challan_indicator,
              p_ch_updIndicator          => v_ch_updIndicator,
              p_filler2                  => v_filler2,
              p_filler3                  => v_filler3,
              p_filler4                  => v_filler4,
              p_last_bank_challan_no     => v_last_bank_challan_no,
              p_bank_challan_no          => v_challan_number,
              /*Bug 8880543 - Challan Number to be used only if deductory type is not A or S*/
              p_last_transfer_voucher_no => v_last_transfer_voucher_no,
              p_transfer_voucher_no      => v_transfer_voucher_no,
              /*Bug 8880543 - Replaced v_transfer_voucher_no with Challan Number if Deductor Type is A or S*/
              p_last_bank_branch_code    => v_last_bank_branch_code,
              p_bank_branch_code         => v_bank_branch_code ,
              p_challan_lastDate         => v_challan_lastDate,
              p_challan_Date             => cd.challan_date,
              p_filler5                  => v_filler5,
              p_filler6                  => v_filler6,
              p_tcs_section              => v_collection_code,
              p_tcs_amt                  => ln_amt_of_tds,
              p_surcharge_amt            => round(cd.surcharge_amt),
              p_cess_amt                 => round(cd.cess_amt),
              p_amt_of_int               => round(ln_amt_of_oth),
              p_amt_of_oth               => round(ln_amt_of_oth),
              p_tcs_amount               => cd.total_tcs_amount,
              p_last_total_depositAmt    => v_last_total_depositAmt,
              p_total_deposit            => v_total_deposit,
              p_tcs_income_tax           => cd.tcs_amt,
              p_tcs_surcharge            => cd.surcharge_amt,
              p_tcs_cess                 => cd.cess_amt,
              p_total_income_tcs         => v_total_deposit,
              p_tcs_interest_amt         => 0,
              p_tcs_other_amt            => 0,
              p_check_number             => v_check_number,
              p_book_entry               => v_book_entry,
              p_remarks                  => v_remarks,
              p_ch_recHash               => v_ch_recHash,
              p_generate_headers         => lv_generate_headers
           ) ;
       END IF ;
     END IF ;

      UPDATE jai_ar_etcs_t
      SET    challan_line_num = v_line_number
      WHERE  batch_id = ln_batch_id
      and    nvl(challan_no,'No Challan Number') = nvl(cd.challan_no, 'No Challan Number')
      and    nvl(challan_date, lv_dummy_date) = nvl(cd.challan_date, lv_dummy_date )
      and    nvl(bank_branch_code, 'No Bank Branch') = nvl(cd.bank_branch_code, 'No Bank Branch')
      and    check_number = cd.check_number;

      IF p_action <> 'V' THEN
        FND_FILE.put_line(FND_FILE.log, 'Challan Line:'||v_line_number
          || ', ChlNum:' || cd.challan_no ||', ChlDate:'||cd.challan_date||', bankBr:'||cd.bank_branch_code
        );
      END IF ;

     IF lv_etcs_yearly_returns= 'N' THEN
        v_record_type := 'DD';
        v_challan_line_num := v_line_number ;

        IF p_action = 'H' THEN
          create_quarterly_dd;
        END IF;

        v_deductee_slno := 0 ;
        process_deductee_records ;
        v_challan_line_num := null ;
     END IF;

    END LOOP;

    CLOSE c_challan_records ;

    IF lv_etcs_yearly_returns= 'Y' THEN

      v_record_type := 'DD';

      IF p_action <> 'V' THEN
        FND_FILE.put_line(FND_FILE.log, 'Deductee Detail');
      END IF ;

      IF p_generate_headers = 'Y' THEN
        create_dd;
      END IF;

      v_challan_line_num := null ;
      v_deductee_slno := 0 ;
      process_deductee_records ; -- internal procedure call

    END IF ;

    IF p_action = 'V' THEN

      FND_FILE.put_line(FND_FILE.log,' LISTING THE ERRORS IN THIS BATCH ' );
      FND_FILE.put_line(FND_FILE.log,'-------------------------------------------------------------------- ' );

      ln_errors_exist := 0;

      FOR rec_get_errors IN c_get_errors(ln_batch_id)
      LOOP
        ln_errors_exist := 1 ;
        FND_FILE.put_line(FND_FILE.log, rec_get_errors.Error_Message );
      END LOOP ;

      IF ln_errors_exist = 0 THEN
        FND_FILE.put_line(FND_FILE.log,' File Validation Successful. No Errors Found !! ' );
      END IF ;

      FND_FILE.put_line(FND_FILE.log,'-------------------------------------------------------------------- ' );
      FND_FILE.put_line(FND_FILE.log,' END OF ERRORS IN THIS BATCH ' );

    END IF ;

    jai_etcs_pkg.closeFile;

    IF p_action <> 'V' THEN
      FND_FILE.put_line(FND_FILE.log, '~~~~~~~~~~~~~~~ End of eTCS File Creation ~~~~~~~~~~~~~~~~~~');
    END IF ;

  END generate_etcs_returns;

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
   )
  IS
   pv_start_date  DATE DEFAULT fnd_date.canonical_to_date(p_start_date);
   pv_end_date    DATE DEFAULT fnd_date.canonical_to_date(p_end_date);

  BEGIN

     FND_FILE.put_line( FND_FILE.log, 'Parameters : ' || fnd_global.local_chr(10)
        ||'  org_tan_number             ->'||p_tan_number||fnd_global.local_chr(10)
        ||'  Organization_id            ->'||p_organization_id || fnd_global.local_chr(10)
        ||'  financial_year             ->'||p_fin_year||fnd_global.local_chr(10)
        ||'  Collection Code            ->'||p_collection_code||fnd_global.local_chr(10)
        ||'  tax_authority_id           ->'||p_tax_authority_id||fnd_global.local_chr(10)
        ||'  tax_authority_site_id      ->'||p_tax_authority_site_id||fnd_global.local_chr(10)
        ||'  seller                     ->'||p_seller_name||fnd_global.local_chr(10)
        ||'  seller state               ->'||p_seller_state||fnd_global.local_chr(10)
        ||'  addr_changed_since_last_ret->'||p_addrChangedSinceLastRet||fnd_global.local_chr(10)
        ||'  person_resp_for_collectio  ->'||p_persRespForCollection||fnd_global.local_chr(10)
        ||'  designation_of_pers_resp   ->'||p_desgOfPersResponsible||fnd_global.local_chr(10)
        ||'  Start_date                 ->'||p_start_date||fnd_global.local_chr(10)
        ||'  End_date                   ->'||p_end_date||fnd_global.local_chr(10)
        ||'  Provvisional Rcpt No       ->'||p_pro_rcpt_num_org_ret || fnd_global.local_chr(10)
        ||'  file_path                  ->'||p_file_path||fnd_global.local_chr(10)
        ||'  filename                   ->'||p_filename||fnd_global.local_chr(10)
        ||'  Generate_headers           ->'||p_generate_headers||fnd_global.local_chr(10)
        ) ;


    generate_etcs_returns
    (
      p_err_buf                  =>   p_err_buf                 ,
      p_ret_code                 =>   p_ret_code                ,
      p_tan_number               =>   p_tan_number              ,
      p_organization_id          =>   p_organization_id         ,
      p_fin_year                 =>   p_fin_year                ,
      p_tax_authority_id         =>   p_tax_authority_id        ,
      p_tax_authority_site_id    =>   p_tax_authority_site_id   ,
      p_seller_name              =>   p_seller_name             ,
      p_seller_state             =>   p_seller_state            ,
      p_addrChangedSinceLastRet  =>   p_addrChangedSinceLastRet ,
      p_persRespForCollection    =>   p_persRespForCollection   ,
      p_desgOfPersResponsible    =>   p_desgOfPersResponsible   ,
      p_Start_Date               =>   pv_start_date             ,
      p_End_Date                 =>   pv_end_date               ,
      p_pro_rcpt_num_org_ret     =>   p_pro_rcpt_num_org_ret    ,
      p_file_path                =>   p_file_path               ,
      p_filename                 =>   p_filename                ,
      p_collection_code          =>   p_collection_code         ,
      p_generate_headers         =>   p_generate_headers
    ) ;
  END yearly_returns;

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
   )
  IS
   pv_start_date  DATE DEFAULT fnd_date.canonical_to_date(p_start_date);
   pv_end_date    DATE DEFAULT fnd_date.canonical_to_date(p_end_date);

  BEGIN

     FND_FILE.put_line( FND_FILE.log, 'Parameters : ' || fnd_global.local_chr(10)
        ||'  org_tan_number             ->'||p_tan_number||fnd_global.local_chr(10)
        ||'  Organization_id            ->'||p_organization_id || fnd_global.local_chr(10)
        ||'  financial_year             ->'||p_fin_year||fnd_global.local_chr(10)
        ||'  Period                     ->'||p_period||fnd_global.local_chr(10)
        ||'  Collection Code            ->'||p_collection_code||fnd_global.local_chr(10)
        ||'  tax_authority_id           ->'||p_tax_authority_id||fnd_global.local_chr(10)
        ||'  tax_authority_site_id      ->'||p_tax_authority_site_id||fnd_global.local_chr(10)
        ||'  seller                     ->'||p_seller_name||fnd_global.local_chr(10)
        ||'  seller state               ->'||p_seller_state||fnd_global.local_chr(10)
        ||'  addr_changed_since_last_ret->'||p_addrChangedSinceLastRet||fnd_global.local_chr(10)
        --||'  collector_status           ->'||p_collector_status||fnd_global.local_chr(10) /*Bug 8880543 - Commented for eTDS/eTCS FVU Changes*/
        ||'  person_resp_for_collectio  ->'||p_persRespForCollection||fnd_global.local_chr(10)
        ||'  designation_of_pers_resp   ->'||p_desgOfPersResponsible||fnd_global.local_chr(10)
        ||'  RespPerson''s Address      ->'||p_RespPersAddress||fnd_global.local_chr(10)
        ||'  RespPerson''s State        ->'||p_RespPersState||fnd_global.local_chr(10)
        ||'  RespPerson''s Pin          ->'||p_RespPersPin||fnd_global.local_chr(10)
        ||'  RespPerson''s Addr Changed ->'||p_RespPersAddrChange||fnd_global.local_chr(10)
        ||'  Start_date                 ->'||p_start_date||fnd_global.local_chr(10)
        ||'  End_date                   ->'||p_end_date||fnd_global.local_chr(10)
        ||'  Provvisional Rcpt No       ->'||p_pro_rcpt_num_org_ret || fnd_global.local_chr(10)
        ||'  file_path                  ->'||p_file_path||fnd_global.local_chr(10)
        ||'  filename                   ->'||p_filename||fnd_global.local_chr(10)
        ||'  Action                     ->'||p_action||fnd_global.local_chr(10)
        ) ;


    generate_etcs_returns
    (
      p_err_buf                  =>   p_err_buf                 ,
      p_ret_code                 =>   p_ret_code                ,
      p_organization_id          =>   p_organization_id         ,
      p_tan_number               =>   p_tan_number              ,
      p_fin_year                 =>   p_fin_year                ,
      p_tax_authority_id         =>   p_tax_authority_id        ,
      p_tax_authority_site_id    =>   p_tax_authority_site_id   ,
      p_seller_name              =>   p_seller_name             ,
      p_seller_state             =>   p_seller_state            ,
      p_addrChangedSinceLastRet  =>   p_addrChangedSinceLastRet ,
      p_persRespForCollection    =>   p_persRespForCollection   ,
      p_desgOfPersResponsible    =>   p_desgOfPersResponsible   ,
      p_Start_Date               =>   pv_start_date             ,
      p_End_Date                 =>   pv_end_date               ,
      p_pro_rcpt_num_org_ret     =>   p_pro_rcpt_num_org_ret    ,
      p_file_path                =>   p_file_path               ,
      p_filename                 =>   p_filename                ,
      p_collection_code          =>   p_collection_code         ,
      p_period                   =>   p_period                  ,
      p_RespPersAddress          =>   p_RespPersAddress         ,
      p_RespPersState            =>   p_RespPersState           ,
      p_RespPersPin              =>   p_RespPersPin             ,
      p_RespPersAddrChange       =>   p_RespPersAddrChange      ,
      p_action                   =>   p_action
      --p_collector_status         =>   p_collector_status        /*Bug 8880543 - Commeneted for eTDS/eTCS FVU Changes*/
    ) ;
  END quarterly_returns;


END jai_etcs_pkg;

/
