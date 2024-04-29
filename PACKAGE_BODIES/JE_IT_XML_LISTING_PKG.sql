--------------------------------------------------------
--  DDL for Package Body JE_IT_XML_LISTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_IT_XML_LISTING_PKG" AS
/*$Header: jeitxlstb.pls 120.2 2008/01/02 14:03:50 spasupun noship $*/
gv_row_val      VARCHAR2(1680);
gn_row_inserted NUMBER := 0;
g_vat_reg_error VARCHAR2(100);

--------------------------------------------------------------------------------
--Private Methods Declaration
--------------------------------------------------------------------------------

procedure VALIDATE_NIF_IT(NIF in varchar2,
                           Xi_UNIQUE_FLAG in varchar2,
                           RET_VAR OUT NOCOPY varchar2,
                           RET_MESSAGE OUT NOCOPY varchar2);

FUNCTION generate_dynamic_string RETURN BOOLEAN;

FUNCTION beforeReport RETURN BOOLEAN
AS
BEGIN
        IF P_PROG_NUM IS NULL THEN
               RETURN TRUE;
        ELSE
                RETURN generate_dynamic_string;
        END IF;
        RETURN TRUE;
END beforeReport;


FUNCTION validate_vat_reg_num (p_vat_reg_num VARCHAR2, p_party_type_code VARCHAR2) RETURN VARCHAR2
IS
 CURSOR tax_reg_num_csr(c_registration_number varchar2, c_party_type_code varchar2) IS
 SELECT ptp.party_id
 FROM   zx_registrations  reg,
        zx_party_tax_profile ptp
 WHERE  ptp.party_tax_profile_id = reg.party_tax_profile_id
 AND reg.registration_number = c_registration_number
 AND sysdate >= reg.effective_from
 AND (sysdate <= reg.effective_to OR reg.effective_to IS NULL)
 AND ptp.party_type_code = c_party_type_code;  --'THIRD_PARTY'

 l_count number :=0;
 error_status VARCHAR2(10);
 eror_buffer VARCHAR2(100);
 l_party_id  VARCHAR2(100);

BEGIN
 l_count := 0;
 eror_buffer := NULL;
 error_status := NULL;
IF p_vat_reg_num IS NOT NULL THEN

OPEN tax_reg_num_csr(p_vat_reg_num, p_party_type_code);
   LOOP

    EXIT WHEN tax_reg_num_csr%NOTFOUND;
    FETCH tax_reg_num_csr into l_party_id ;

     IF tax_reg_num_csr%FOUND THEN
	     l_count := l_count+ 1;
     END IF;
END LOOP;

IF l_count  > 1 THEN

    FND_MESSAGE.SET_NAME('JE','JE_IT_VAT_DUPLICATE');
	g_vat_reg_error := FND_MESSAGE.get;
	RETURN g_vat_reg_error;

END IF;

IF l_count < 2 THEN

    ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_IT( p_trn_value => p_vat_reg_num
                                          ,p_trn_type => NULL
                                          ,p_check_unique_flag => 'S'
                    				      ,p_return_status => error_status
		  	 	                          ,p_error_buffer => eror_buffer);

    IF error_status = 'E' THEN
        FND_MESSAGE.SET_NAME('JE','JE_IT_VAT_INVALID');
    	g_vat_reg_error := FND_MESSAGE.get;
	RETURN g_vat_reg_error;
    END IF;
END IF;

RETURN 'TRUE';

END IF;
RETURN 'TRUE';

EXCEPTION
WHEN others THEN
 fnd_file.put_line(fnd_file.log,'Error Message:'||SQLERRM||'Error Code:'||SQLCODE);
 FND_MESSAGE.SET_NAME('JE','JE_IT_VAT_INVALID');
 g_vat_reg_error := FND_MESSAGE.get;
 RETURN g_vat_reg_error;

END validate_vat_reg_num;

PROCEDURE insert_into_table (col_data VARCHAR2, appl_id NUMBER)
AS
BEGIN
	INSERT INTO je_it_list_trx_gt
	(je_info_n1,
	je_info_v1)
	VALUES
	(appl_id,
	col_data);
gn_row_inserted := gn_row_inserted + 1;
fnd_file.put_line(fnd_file.log,'Rows Inserted:'||gn_row_inserted);
EXCEPTION
WHEN others THEN
    fnd_file.put_line(fnd_file.log,'Error Message:'||SQLERRM||'Error Code:'||SQLCODE);
END insert_into_table;

PROCEDURE concatenate(pv_code VARCHAR2, pv_field VARCHAR2, pn_appl_id NUMBER)
AS
BEGIN
	IF(pv_field  IS NOT NULL AND (TRIM(pv_field) <> '0')) THEN
		IF (LENGTH(gv_row_val) <1680) THEN
                        gv_row_val    := gv_row_val||pv_code||pv_field;
                ELSE
                        -- Intitialize a new row....
			IF (gv_row_val IS NOT NULL) THEN
				insert_into_table(gv_row_val,pn_appl_id);
				gv_row_val := NULL;
			END IF;
                        gv_row_val := pv_code||pv_field;
                END IF;
        END IF;
END concatenate;

FUNCTION generate_dynamic_string RETURN BOOLEAN
AS
        CURSOR cur_q_customer
        IS
            SELECT    je.party_id CUST_PARTY_ID
                       ,je.transmission_num  TRANSMISSION_NUM
                       ,hzp.party_name PARTY_NAME
                       ,hzp.party_type PARTY_TYPE
                       ,je.fiscal_id_num  TAX_PAYERID
                       ,je.vat_registration_num VAT_REGISTRATION_NUM
                       ,ROUND(je.taxable_amt) TAXABLE_AMT
                       ,ROUND(je.vat_amt) VAT_AMT
                       ,ROUND(je.non_taxable_amt) NON_TAXABLE_AMT
                       ,ROUND(je.exempt_amt) EXEMPT_AMT
                       ,ROUND(je.taxable_vat_inv_amt) TAXABLE_VAT_INV_AMT
                       ,ROUND(je.cm_taxable_amt) TAXABLE_AMT_CM
                       ,ROUND(je.cm_vat_amt) VAT_AMT_CM
                       ,ROUND(je.cm_non_taxable_amt) NON_TAXABLE_AMT_CM
                       ,ROUND(je.cm_exempt_amt) EXEMPT_AMT_CM
                       ,ROUND(je.cm_taxable_vat_inv_amt) TAXABLE_VAT_INV_AMT_CM
                FROM    je_it_list_parties_all je
                       ,hz_cust_accounts   hzca
 		       ,hz_parties         hzp
                WHERE    je.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
			AND je.year_of_declaration = P_YEAR_OF_DECLARATION
			AND je.application_id  = 222
	                AND je.transmission_num  = P_PROG_NUM
	                AND je.party_id = hzca.cust_account_id
	  		AND hzca.party_id  = hzp.party_id
                ORDER BY je.party_sequence_num;

        CURSOR cur_q_supplier
        IS
        SELECT  je.party_id SUP_PARTY_ID
                ,je.transmission_num TRANSMISSION_NUM
                ,pv.vendor_name				   PARTY_NAME
                ,pv.vendor_type_lookup_code	   PARTY_TYPE
        		,je.fiscal_id_num                  TAX_PAYERID
		      	,je.vat_registration_num	       VAT_REGISTRATION_NUM
                ,ROUND(je.taxable_amt) TAXABLE_AMT
                ,ROUND(je.vat_amt) VAT_AMT
                ,ROUND(je.non_taxable_amt) NON_TAXABLE_AMT
                ,ROUND(je.exempt_amt) EXEMPT_AMT
                ,ROUND(je.taxable_vat_amt) TAXABLE_VAT_AMT
                ,ROUND(je.taxable_vat_inv_amt) TAXABLE_VAT_INV_AMT
                ,ROUND(je.cm_taxable_amt) TAXABLE_AMT_CM
                ,ROUND(je.cm_vat_amt) VAT_AMT_CM
                ,ROUND(je.cm_non_taxable_amt) NON_TAXABLE_AMT_CM
                ,ROUND(je.cm_exempt_amt) EXEMPT_AMT_CM
                ,ROUND(je.cm_taxable_vat_amt) TAXABLE_VAT_AMT_CM
                ,ROUND(je.cm_taxable_vat_inv_amt) TAXABLE_VAT_INV_AMT_CM
        FROM    je_it_list_parties_all je
                ,ap_suppliers pv
        WHERE   je.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
      	AND je.year_of_declaration = P_YEAR_OF_DECLARATION
        AND je.transmission_num   = P_PROG_NUM
      	AND je.application_id  = 200
      	AND je.party_id  = pv.vendor_id
      ORDER BY je.party_sequence_num;

        string_build VARCHAR2(1680);
        counter      NUMBER := 1;
        code         VARCHAR2(8);
        field        VARCHAR2(16);

BEGIN
        FOR C_CUST_REC IN cur_q_customer
        LOOP
                field := counter;
                counter := counter + 1;
                field := LPAD(field,16,' ');
                code  := 'CL001001';
                concatenate(code,field,222);

                field := C_CUST_REC.tax_payerid;
                field := RPAD(SUBSTRB(field,1,16),16,' ');
                code  := 'CL002001';
                concatenate(code,field,222);

                field := C_CUST_REC.VAT_REGISTRATION_NUM;
                field := RPAD(SUBSTRB(field,1,16),16,' ');
                code  := 'CL003001';
                concatenate(code,field,222);

                field := C_CUST_REC.TAXABLE_AMT;
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                code  := 'CL004001';
                concatenate(code,field,222);

                field := C_CUST_REC.VAT_AMT;
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                code  := 'CL004002';
                concatenate(code,field,222);

                field := C_CUST_REC.NON_TAXABLE_AMT;
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                code  := 'CL005001';
                concatenate(code,field,222);

                field := C_CUST_REC.EXEMPT_AMT;
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                code  := 'CL006001';
                concatenate(code,field,222);

                field := C_CUST_REC.TAXABLE_VAT_INV_AMT;
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                code  := 'CL007001';
                concatenate(code,field,222);

--Credit memo amounts

                field := C_CUST_REC.TAXABLE_AMT_CM;
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                code  := 'CL008001';
                concatenate(code,field,222);

                field := C_CUST_REC.VAT_AMT_CM;
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                code  := 'CL008002';
                concatenate(code,field,222);

                field := C_CUST_REC.NON_TAXABLE_AMT_CM;
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                code  := 'CL009001';
                concatenate(code,field,222);

                field := C_CUST_REC.EXEMPT_AMT_CM;
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                code  := 'CL010001';
                concatenate(code,field,222);

                field := C_CUST_REC.TAXABLE_VAT_INV_AMT_CM;
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                code  := 'CL011001';
                concatenate(code,field,222);
        END LOOP;

        IF (gv_row_val IS NOT NULL) THEN
                insert_into_table(gv_row_val,222);
                gv_row_val := NULL;
        END IF;

        counter       := 1;

        FOR C_SUP_REC IN cur_q_supplier
        LOOP
                field := counter;
                counter := counter + 1;
                code  := 'FR001001';
                field := LPAD(field,16,' ');
                concatenate(code,field,200);

                field := C_SUP_REC.tax_payerid;
                code  := 'FR002001';
                field := RPAD(SUBSTRB(field,1,16),16,' ');
                concatenate(code,field,200);

                field := C_SUP_REC.VAT_REGISTRATION_NUM;
                code  := 'FR003001';
                field := RPAD(SUBSTRB(field,1,16),16,' ');
                concatenate(code,field,200);

                field := C_SUP_REC.TAXABLE_AMT;
                code  := 'FR004001';
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                concatenate(code,field,200);

                field := C_SUP_REC.VAT_AMT;
                code  := 'FR004002';
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                concatenate(code,field,200);

                field := C_SUP_REC.TAXABLE_VAT_AMT;
                code  := 'FR005001';
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                concatenate(code,field,200);

                field := C_SUP_REC.NON_TAXABLE_AMT;
                code  := 'FR006001';
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                concatenate(code,field,200);

                field := C_SUP_REC.EXEMPT_AMT;
                code  := 'FR007001';
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                concatenate(code,field,200);

                field := C_SUP_REC.TAXABLE_VAT_INV_AMT;
                code  := 'FR008001';
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                concatenate(code,field,200);

-- Credit Memo Lines

                field := C_SUP_REC.TAXABLE_AMT_CM;
                code  := 'FR009001';
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                concatenate(code,field,200);

                field := C_SUP_REC.VAT_AMT_CM;
                code  := 'FR009002';
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                concatenate(code,field,200);

                field := C_SUP_REC.TAXABLE_VAT_AMT_CM;
                code  := 'FR010001';
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                concatenate(code,field,200);

                field := C_SUP_REC.NON_TAXABLE_AMT_CM;
                code  := 'FR011001';
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                concatenate(code,field,200);

                field := C_SUP_REC.EXEMPT_AMT_CM;
                code  := 'FR012001';
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                concatenate(code,field,200);

                field := C_SUP_REC.TAXABLE_VAT_INV_AMT_CM;
                code  := 'FR013001';
                field := LPAD(SUBSTRB(field,1,16),16,' ');
                concatenate(code,field,200);

        END LOOP;
        IF (gv_row_val IS NOT NULL) THEN
                insert_into_table(gv_row_val,200);
        END IF;
        RETURN TRUE;
END generate_dynamic_string;


procedure VALIDATE_NIF_IT (NIF in varchar2,
                           Xi_UNIQUE_FLAG in varchar2,
                           RET_VAR OUT NOCOPY varchar2,
                           RET_MESSAGE OUT NOCOPY varchar2)
                                      AS
nif_value            varchar2(20);
check_digit          varchar2(1);
position_i           number(2);
position_weight      number(2);
total_weighting      number(3);
char_value           varchar2(1);
calc_check           number(2);
calc_cd              varchar2(1);
vat_ret_code         varchar2(1);
vat_ret_message      varchar2(60);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_uniqueness is
begin
      RET_VAR := 'F';
      RET_MESSAGE := 'NIF_DUPLICATE_NIF_NUM';
end fail_uniqueness;

procedure fail_check is
begin
      RET_VAR := 'F';
      RET_MESSAGE := 'NIF_INVALID_NIF_NUM';
end fail_check;

procedure system_failure is
begin
      RET_VAR := 'F';
      RET_MESSAGE := 'NIF_INVALID_NIF_NUM';
end system_failure;

procedure pass_check is
begin
      RET_VAR := 'P';
      RET_MESSAGE := '';
end pass_check;

/**** weighting assignment functions ****/

/**     function returns the calculated check digit  **/
function find_check_digit(REMAINDER NUMBER) RETURN VARCHAR2 IS
cd_result varchar2(1);
begin
  IF REMAINDER = 0
      then
        cd_result := 'A';
  ELSIF REMAINDER = 1
      then
        cd_result := 'B';
  ELSIF REMAINDER = 2
      then
        cd_result := 'C';
  ELSIF REMAINDER = 3
      then
        cd_result := 'D';
  ELSIF REMAINDER = 4
      then
        cd_result := 'E';
  ELSIF REMAINDER = 5
      then
        cd_result := 'F';
  ELSIF REMAINDER = 6
      then
        cd_result := 'G';
  ELSIF REMAINDER = 7
      then
        cd_result := 'H';
  ELSIF REMAINDER = 8
      then
        cd_result := 'I';
  ELSIF REMAINDER = 9
      then
        cd_result := 'J';
  ELSIF REMAINDER = 10
      then
        cd_result := 'K';
  ELSIF REMAINDER = 11
      then
        cd_result := 'L';
  ELSIF REMAINDER = 12
      then
        cd_result := 'M';
  ELSIF REMAINDER = 13
      then
        cd_result := 'N';
  ELSIF REMAINDER = 14
      then
        cd_result := 'O';
  ELSIF REMAINDER = 15
      then
        cd_result := 'P';
  ELSIF REMAINDER = 16
      then
        cd_result := 'Q';
  ELSIF REMAINDER = 17
      then
        cd_result := 'R';
  ELSIF REMAINDER = 18
      then
        cd_result := 'S';
  ELSIF REMAINDER = 19
      then
        cd_result := 'T';
  ELSIF REMAINDER = 20
      then
        cd_result := 'U';
  ELSIF REMAINDER = 21
      then
        cd_result := 'V';
  ELSIF REMAINDER = 22
      then
        cd_result := 'W';
  ELSIF REMAINDER = 23
      then
        cd_result := 'X';
  ELSIF REMAINDER = 24
      then
        cd_result := 'Y';
  ELSIF REMAINDER = 25
      then
        cd_result := 'Z';
  ELSE
      system_failure;
  END IF;

      RETURN cd_result;

end find_check_digit;

/**     returns the weighting of the even-postitioned figures. **/
function func_even_weighting(IN_VALUE VARCHAR2) RETURN NUMBER IS
even_result number(2);
begin
  IF IN_VALUE in ('A','0')
      then
        even_result := 0;
  ELSIF IN_VALUE in ('B','1')
      then
        even_result := 1;
  ELSIF IN_VALUE in ('C','2')
      then
        even_result := 2;
  ELSIF IN_VALUE in ('D','3')
      then
        even_result := 3;
  ELSIF IN_VALUE in ('E','4')
      then
        even_result := 4;
  ELSIF IN_VALUE in ('F','5')
      then
        even_result := 5;
  ELSIF IN_VALUE in ('G','6')
      then
        even_result := 6;
  ELSIF IN_VALUE in ('H','7')
      then
        even_result := 7;
  ELSIF IN_VALUE in ('I','8')
      then
        even_result := 8;
  ELSIF IN_VALUE in ('J','9')
      then
        even_result := 9;
  ELSIF IN_VALUE = 'K'
      then
        even_result := 10;
  ELSIF IN_VALUE = 'L'
      then
        even_result := 11;
  ELSIF IN_VALUE = 'M'
      then
        even_result := 12;
  ELSIF IN_VALUE = 'N'
      then
        even_result := 13;
  ELSIF IN_VALUE = 'O'
      then
        even_result := 14;
  ELSIF IN_VALUE = 'P'
      then
        even_result := 15;
  ELSIF IN_VALUE = 'Q'
      then
        even_result := 16;
  ELSIF IN_VALUE = 'R'
      then
        even_result := 17;
  ELSIF IN_VALUE = 'S'
      then
        even_result := 18;
  ELSIF IN_VALUE = 'T'
      then
        even_result := 19;
  ELSIF IN_VALUE = 'U'
      then
        even_result := 20;
  ELSIF IN_VALUE = 'V'
      then
        even_result := 21;
  ELSIF IN_VALUE = 'W'
      then
        even_result := 22;
  ELSIF IN_VALUE = 'X'
      then
        even_result := 23;
  ELSIF IN_VALUE = 'Y'
      then
        even_result := 24;
  ELSIF IN_VALUE = 'Z'
      then
        even_result := 25;
  END IF;

      RETURN even_result;

end func_even_weighting;

/**     returns the weighting of the odd-postitioned figures.  **/
function func_odd_weighting(ODD_VALUE VARCHAR2) RETURN NUMBER IS
/* Bug 758931. Changed the odd_result to 3 for ODD_VALUE 'P' so that
               Italian fiscal code validation is correct */
odd_result number(2);
begin
  IF ODD_VALUE in ('A','0')
      then
        odd_result := 1;
  ELSIF ODD_VALUE in ('B','1')
      then
        odd_result := 0;
  ELSIF ODD_VALUE in ('C','2')
      then
        odd_result := 5;
  ELSIF ODD_VALUE in ('D','3')
      then
        odd_result := 7;
  ELSIF ODD_VALUE in ('E','4')
      then
        odd_result := 9;
  ELSIF ODD_VALUE in ('F','5')
      then
        odd_result := 13;
  ELSIF ODD_VALUE in ('G','6')
      then
        odd_result := 15;
  ELSIF ODD_VALUE in ('H','7')
      then
        odd_result := 17;
  ELSIF ODD_VALUE in ('I','8')
      then
        odd_result := 19;
  ELSIF ODD_VALUE in ('J','9')
      then
        odd_result := 21;
  ELSIF ODD_VALUE = 'K'
      then
        odd_result := 2;
  ELSIF ODD_VALUE = 'L'
      then
        odd_result := 4;
  ELSIF ODD_VALUE = 'M'
      then
        odd_result := 18;
  ELSIF ODD_VALUE = 'N'
      then
        odd_result := 20;
  ELSIF ODD_VALUE = 'O'
      then
        odd_result := 11;
  ELSIF ODD_VALUE = 'P'
      then
        odd_result := 3;
  ELSIF ODD_VALUE = 'Q'
      then
        odd_result := 6;
  ELSIF ODD_VALUE = 'R'
      then
        odd_result := 8;
  ELSIF ODD_VALUE = 'S'
      then
        odd_result := 12;
  ELSIF ODD_VALUE = 'T'
      then
        odd_result := 14;
  ELSIF ODD_VALUE = 'U'
      then
        odd_result := 16;
  ELSIF ODD_VALUE = 'V'
      then
        odd_result := 10;
  ELSIF ODD_VALUE = 'W'
      then
        odd_result := 22;
  ELSIF ODD_VALUE = 'X'
      then
        odd_result := 25;
  ELSIF ODD_VALUE = 'Y'
      then
        odd_result := 24;
  ELSIF ODD_VALUE = 'Z'
      then
        odd_result := 23;
  END IF;

      RETURN odd_result;

end func_odd_weighting;

                            /****************/
                            /* MAIN SECTION */
                            /****************/

BEGIN

nif_value := NIF;
check_digit := substr(NIF_VALUE, length(NIF_VALUE));
total_weighting := 0;
position_weight := 0;

IF Xi_UNIQUE_FLAG = 'F'
  then
     fail_uniqueness;

ELSIF Xi_UNIQUE_FLAG = 'P'
  then

  /**  make sure that Fiscal code is only 16 chars - including Check digit **/
  IF length(NIF) = 16
    then

       FOR position_i IN 1..15 LOOP

   /** moves along length of Fiscal Code and assigns weightings  **/
   /** to each of the codes characters upto and including  the 15th char **/
   /** on each loop the total of weightings is totalled            **/

            char_value := substr(NIF_VALUE,position_i,1);
            IF position_i in (2,4,6,8,10,12,14)
              then
                position_weight := func_even_weighting(char_value);
            ELSE
                position_weight := func_odd_weighting(char_value);
            END IF;

            total_weighting := total_weighting + position_weight;

       END LOOP;   /** of the counter position_i **/

      /** Divide the total by 23 and store the remainder into cal_check **/
          calc_check :=  MOD(total_weighting, 26);

          calc_cd := find_check_digit(calc_check);

       /*** After having calculated what should be the ITALIAN Fiscal  ***/
       /*** Check digit compare to the actual and fail if not the same ***/

       IF calc_cd <> check_digit
           then
             fail_check;
       ELSE
             pass_check;
       END IF;

  ELSIF length(NIF) = 11
    then

      /** RW 21-FEB-95 Additional requirement of Italy                  **/
      /** This is a new requirement. Italian Fiscal Codes may either be **/
      /** 16 OR 11 chars - if 11 then must pass the VAT Code validation **/
      /** routine - if 16 must be Fiscal Code for an individual which   **/
      /** has this procedure to validate it                             **/

         ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_IT( p_trn_value => nif_value
                                               ,p_trn_type => NULL
                                               ,p_check_unique_flag => 'S'
                              			       ,p_return_status => vat_ret_code
		  	 	                               ,p_error_buffer => vat_ret_message);

                IF vat_ret_code = 'E'
                  then
                    fail_check;
                ELSE
                    pass_check;
                END IF;


  ELSE
    fail_check; /** Fiscal code is incorrect length **/

  END IF;

ELSE
  pass_check;
END IF; /** of fail uniqueness check **/

END VALIDATE_NIF_IT;

FUNCTION validate_taxpayer_id (pv_taxpayer_id VARCHAR2, p_party_type_code VARCHAR2) RETURN VARCHAR2
IS

CURSOR supplier_taxpayer_id_csr(c_taxpayer_id varchar2) IS
    SELECT 1
    FROM  ap_suppliers pv,
        (SELECT distinct person_id
	          ,national_identifier
        FROM per_all_people_f
    	 WHERE nvl(effective_end_date,sysdate) >= sysdate ) papf
    WHERE pv.employee_id = papf.person_id (+)
    AND NVL(papf.national_identifier,NVL(pv.individual_1099,pv.num_1099)) = c_taxpayer_id;

CURSOR customer_taxpayer_id_csr(c_taxpayer_id varchar2) IS
SELECT 1 FROM hz_parties
WHERE  jgzz_fiscal_code = c_taxpayer_id;


 l_count number :=0;
 error_status VARCHAR2(10);
 eror_buffer VARCHAR2(100);
 l_number  number;

BEGIN
 l_count := 0;
 eror_buffer := NULL;
 error_status := NULL;

IF  pv_taxpayer_id IS NOT NULL THEN  --if1

    IF  p_party_type_code = 'SUPPLIER' THEN --if2

       OPEN supplier_taxpayer_id_csr(pv_taxpayer_id);
       LOOP

         EXIT WHEN supplier_taxpayer_id_csr%NOTFOUND;

         FETCH supplier_taxpayer_id_csr into l_number ;

        IF supplier_taxpayer_id_csr%FOUND THEN  --if3
                l_count := l_count+ 1;
         END IF;  --if3

       END LOOP;

        IF l_count  > 1 THEN  --if4
            FND_MESSAGE.SET_NAME('JE','JE_IT_NIF_DUPLICATE');
        	g_vat_reg_error := FND_MESSAGE.get;
        	RETURN g_vat_reg_error;
		END IF;  --if4

		IF l_count < 2 THEN  --if5

			VALIDATE_NIF_IT (pv_taxpayer_id,'P',error_status,g_vat_reg_error);

			IF 	error_status = 'F' THEN
			FND_MESSAGE.SET_NAME('JE','JE_IT_NIF_INVALID');
        	g_vat_reg_error := FND_MESSAGE.get;
        	RETURN g_vat_reg_error;
			END IF;

    	END IF;  --if5

	ELSIF p_party_type_code = 'CUSTOMER' THEN  	 --if2

		l_count := 0;

     OPEN customer_taxpayer_id_csr(pv_taxpayer_id);
      LOOP

      EXIT WHEN customer_taxpayer_id_csr%NOTFOUND;

      FETCH customer_taxpayer_id_csr into l_number ;

       IF customer_taxpayer_id_csr%FOUND THEN  --if6
           l_count := l_count+ 1;
       END IF;  --if6

      END LOOP;

        IF l_count  > 1 THEN  --if7
            FND_MESSAGE.SET_NAME('JE','JE_IT_NIF_DUPLICATE');
        	g_vat_reg_error := FND_MESSAGE.get;
        	RETURN g_vat_reg_error;
		END IF;  --if7

		IF l_count < 2 THEN  --if8

			VALIDATE_NIF_IT (pv_taxpayer_id,'P',error_status,g_vat_reg_error);
			IF 	error_status = 'F' THEN
			FND_MESSAGE.SET_NAME('JE','JE_IT_NIF_INVALID');
        	g_vat_reg_error := FND_MESSAGE.get;
        	RETURN g_vat_reg_error;
			END IF;

    	END IF;  --if8

	END IF; ----if2

END IF;   --if1

RETURN 'TRUE';

EXCEPTION
WHEN others THEN
 fnd_file.put_line(fnd_file.log,'Error in Taxpayer ID validation');
 fnd_file.put_line(fnd_file.log,'Error Message:'||SQLERRM||'Error Code:'||SQLCODE);
 FND_MESSAGE.SET_NAME('JE','JE_IT_NIF_INVALID');
 g_vat_reg_error := FND_MESSAGE.get;
 RETURN g_vat_reg_error;

END validate_taxpayer_id;

END JE_IT_XML_LISTING_PKG;

/
