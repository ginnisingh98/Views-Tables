--------------------------------------------------------
--  DDL for Package Body JL_BR_AP_VALIDATE_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AP_VALIDATE_COLLECTION" as
/* $Header: jlbrpvcb.pls 120.6.12010000.5 2009/11/19 16:07:11 gmeni ship $ */

/*---------------------------------------------------------------------------*/
/*<<<<<   		JL_BR_AP_VALIDATE_COLL_DOC			>>>>>*/
/*---------------------------------------------------------------------------*/
PROCEDURE jl_br_ap_validate_coll_doc (
   e_cnab_currency_code			IN	VARCHAR2,
   e_arrears_code 			     IN	VARCHAR2,
   e_accounting_balancing_segment	IN	VARCHAR2,
   e_set_of_books_id			IN	NUMBER,
   e_drawee_name			    IN	VARCHAR2,
   e_drawee_inscription_type  		IN	NUMBER,
   e_drawee_inscription_number		IN	VARCHAR2,
   e_drawee_bank_code			  IN	VARCHAR2,
   e_drawee_branch_code			IN	VARCHAR2,
   e_drawee_account			 IN	VARCHAR2,
   e_transferor_name			IN	VARCHAR2,
   e_transf_inscription_type  		IN	NUMBER,
   e_transf_inscription_number		IN	VARCHAR2,
   e_transferor_bank_code		 IN	VARCHAR2,
   e_transferor_branch_code	IN	VARCHAR2,
   e_arrears_date   			     IN      DATE,
   e_arrears_interest   		  IN      NUMBER,
   e_barcode                IN	VARCHAR2,
   e_electronic_format_flag IN	VARCHAR2,
   s_currency_code			      OUT NOCOPY	VARCHAR2,
   s_vendor_site_id			     OUT NOCOPY	NUMBER,
   s_error_code				     IN OUT NOCOPY	VARCHAR2
   )IS
x_aux   		VARCHAR2(1);
x_name   		jl_br_ap_int_collect.drawee_name%TYPE;
x_register_type   	jl_br_ap_int_collect.drawee_inscription_type%TYPE;
x_inscription_number   	jl_br_ap_int_collect.drawee_inscription_number%TYPE;
x_bank_branch_id   	ce_bank_branches_v.branch_party_id%TYPE;
x_vendor_name   	po_vendors.vendor_name%TYPE;
x_aux1			NUMBER;
x_aux2			NUMBER;

l_return_status         VARCHAR2(100);
l_msg_data              VARCHAR2(1000);
-- l_ledger_info           xle_businessinfo_grp.le_ledger_rec_type;
x_comp_name             varchar2(200);
x_registration_number    varchar2(100);

CURSOR Comp IS
   Select etb.establishment_name compname
         ,etb.registration_number
         ,etb.legal_entity_id
   From
          xle_establishment_v etb
         ,xle_bsv_associations bsv
         ,gl_ledger_le_v gl
   Where
         etb.legal_entity_id = gl.legal_entity_id
   And   bsv.legal_parent_id = etb.legal_entity_id
   And   etb.establishment_id = bsv.legal_construct_id
   And   bsv.entity_name = e_accounting_balancing_segment
   And   gl.ledger_id = e_set_of_books_id
   AND   etb.establishment_name = e_drawee_name;

BEGIN
   s_error_code := '00';
/*--------------------------------------------------------------------*/
/*    			Validate the currency code		      */
/*--------------------------------------------------------------------*/
/* Modified for Brazil:Bank Transfer Currency Issue On 09/03/99       */
/*   BEGIN
   	SELECT currency_code
   	INTO s_currency_code
   	FROM FND_CURRENCIES_VL
   	WHERE substr(global_attribute1,1,15) = e_cnab_currency_code;
   EXCEPTION
   	WHEN NO_DATA_FOUND THEN
   		s_error_code:='01';
   		GOTO fim;
   END;                                                               */

     -- Bug 4715379
     s_currency_code := jl_zz_sys_options_pkg.get_bank_transfer_currency;
/*--------------------------------------------------------------------*/
/*    			Validate arrears code               	      */
/*--------------------------------------------------------------------*/
   BEGIN
   	SELECT 'Y'
   	INTO x_aux
   	FROM sys.dual
   	WHERE EXISTS (
   		SELECT null
   		FROM FND_LOOKUPS
   		WHERE lookup_type = 'JLBR_ARREARS_CODE'
   		AND   lookup_code = e_arrears_code );
   EXCEPTION
   	WHEN NO_DATA_FOUND THEN
   		s_error_code:='02';
   		GOTO fim;
   END;
/*--------------------------------------------------------------------*/
/* Get the drawee information (company) using 			      */
/* accounting_balancing_segment and set_of_books_id		      */
/*--------------------------------------------------------------------*/


BEGIN
/*
   XLE_BUSINESSINFO_GRP.Get_Ledger_Info
      (x_return_status =>l_return_status,                 --OUT VARCHAR2
       x_msg_data      =>l_msg_data,                      --OUT VARCHAR2
       P_Ledger_id     =>e_set_of_books_id,               --IN NUMBER
       P_BSV           =>e_accounting_balancing_segment,  --IN VARCHAR2
       x_ledger_info   =>l_ledger_info);                  --OUT LE_ledger_Rec_Type
*/

   For Cinfo In Comp Loop
       x_comp_name := Cinfo.compname;
       x_registration_number := Cinfo.registration_number;
   End Loop;
--bug8808666 Start
   /*if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  	s_error_code:='03';
 	GOTO fim;*/
--bug8808666 End
   IF UPPER(e_drawee_name) <> UPPER(x_comp_name)
   THEN
   	s_error_code:= '04';
   	GOTO fim;
--   ELSIF e_drawee_inscription_type <> x_register_type
--   THEN
--   	s_error_code:= '05';
--   	GOTO fim;
   ELSIF e_drawee_inscription_number <> x_registration_number
   THEN
   	s_error_code:= '06';
   	GOTO fim;
   END IF;

   BEGIN
     SELECT '1'
     INTO x_register_type
     FROM fnd_lookups
     WHERE lookup_code = e_drawee_inscription_type
     AND lookup_type   = 'JLBR_INSCRIPTION_TYPE'
     AND NVL(end_date_active,sysdate + 1) > sysdate;
   EXCEPTION
   WHEN OTHERS THEN
     s_error_code := '05';
     GOTO fim;
   END;
END;


/*--------------------------------------------------------------------*/
/*    	Check the drawee bank and branch numbers                      */
/*--------------------------------------------------------------------*/

   BEGIN
   	SELECT branch_party_id
   	INTO x_bank_branch_id
   	FROM ce_bank_branches_v
   	WHERE bank_number = e_drawee_bank_code
	AND branch_number = e_drawee_branch_code
        AND bank_home_country = 'BR';
   EXCEPTION
   	WHEN NO_DATA_FOUND THEN
   		s_error_code:='07';
   		GOTO fim;
   END;

/*----------------------------------------------------------------------*/
/*    		Check the drawee bank account number	 	        */
/* Drawee Account is considered to be Company account, that is Internal */
/* account.                                                             */
/*----------------------------------------------------------------------*/

   BEGIN
   	SELECT 'Y'
   	INTO x_aux
   	FROM sys.dual
   	WHERE EXISTS (
   		SELECT null
   		FROM ce_bank_accounts
   		WHERE bank_branch_id = x_bank_branch_id
   		AND   bank_account_num = e_drawee_account );
   EXCEPTION
   	WHEN NO_DATA_FOUND THEN
   		s_error_code:='08';
   		GOTO fim;
   END;
/*--------------------------------------------------------------------*/
/* Using transferor inscription type and transferor inscription number*/
/* get and validate the transferor data                               */
/*--------------------------------------------------------------------*/
   BEGIN
   	IF e_transf_inscription_type = 1	/* CPF */
   	THEN 		/* Considering 3 zeros on the left */
   		SELECT 	povs.vendor_site_id,
   			substr(pov.vendor_name,1,240)
   		INTO	s_vendor_site_id,
   			x_vendor_name
   		FROM	po_vendor_sites povs,
   			po_vendors	pov
   		WHERE	povs.global_attribute9 = e_transf_inscription_type
   		AND	povs.global_attribute10 = substr(e_transf_inscription_number,4,9)
   		AND	povs.global_attribute12 = substr(e_transf_inscription_number,13,2)
   		AND	pov.vendor_id = povs.vendor_id;

   	ELSIF e_transf_inscription_type = 2	/* CGC */
   	   OR e_transf_inscription_type = 99	/* Others */
   	THEN		/* Include one zero on the left */
   		SELECT 	povs.vendor_site_id,
   			substr(pov.vendor_name,1,240)
   		INTO	s_vendor_site_id,
   			x_vendor_name
   		FROM	po_vendor_sites povs,
   			po_vendors	pov
   		WHERE	povs.global_attribute9 = e_transf_inscription_type
   		AND	povs.global_attribute10 = '0'||substr(e_transf_inscription_number,1,8)
   		AND	povs.global_attribute11 = substr(e_transf_inscription_number,9,4)
   		AND	povs.global_attribute12 = substr(e_transf_inscription_number,13,2)
   		AND	pov.vendor_id = povs.vendor_id;

   	ELSE
   		s_error_code:='09';
   		GOTO fim;

   	END IF;
   EXCEPTION
   	WHEN NO_DATA_FOUND THEN
   		s_error_code:='10';
   		GOTO fim;
   	WHEN TOO_MANY_ROWS THEN
   		s_error_code:='14';
   		GOTO fim;
   END;

   IF e_transferor_name <> x_vendor_name
   THEN
   	s_error_code:='11';
   	GOTO fim;
   END IF;

/*--------------------------------------------------------------------*/
/*    	Check the transferor bank and branch number                   */
/*--------------------------------------------------------------------*/
   BEGIN
   	SELECT 'Y'
   	INTO x_aux
   	FROM sys.dual
   	WHERE EXISTS (
   		SELECT null
   		FROM ce_bank_branches_v
   		WHERE bank_number = e_transferor_bank_code
   		AND   branch_number = e_transferor_branch_code
                AND   bank_home_country = 'BR' );
   EXCEPTION
   	WHEN NO_DATA_FOUND THEN
   		s_error_code:='12';
   		GOTO fim;
   END;

/*--------------------------------------------------------------------*/
/*     Check ARREARS_DATE, ARREARS_CODE and ARREARS_INTEREST fields   */
/*--------------------------------------------------------------------*/
   BEGIN
	SELECT (decode(e_arrears_code,NULL,0,1)+
		decode(e_arrears_date,NULL,0,1)+
            	abs(nvl(e_arrears_interest,0))),
	       (decode(e_arrears_code,NULL,0,1)*
		decode(e_arrears_date,NULL,0,1)*
            	nvl(e_arrears_interest,0))
	INTO x_aux1,x_aux2
	FROM sys.dual;

	IF x_aux1 <> 0 AND x_aux2 = 0
	THEN
   		s_error_code:='13';
   		GOTO fim;
	END IF;
   END;

/*--------------------------------------------------------------------*/
/*                        Check ELECTRONIC_FORMAT_FLAG fields                        */
/*--------------------------------------------------------------------*/
   BEGIN
      IF NVL(e_electronic_format_flag,'N') not in ('Y','N')
      THEN
         s_error_code:='15';
        	GOTO fim;
     	END IF;
   END;

/*--------------------------------------------------------------------*/
/*                        Check BARCODE fields                        */
/*--------------------------------------------------------------------*/
   BEGIN

      jl_br_ap_validate_collect_pub.validate_barcode(e_barcode,x_aux1);

     	IF x_aux1 <> 0
      THEN
         s_error_code:='16';
        	GOTO fim;
     	END IF;
   END;


/*--------------------------------------------------------------------*/
<<fim>>
   NULL;
END jl_br_ap_validate_coll_doc;

END JL_BR_AP_VALIDATE_COLLECTION;

/
