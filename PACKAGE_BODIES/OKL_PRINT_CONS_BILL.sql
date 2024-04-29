--------------------------------------------------------
--  DDL for Package Body OKL_PRINT_CONS_BILL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PRINT_CONS_BILL" AS
/* $Header: OKLRCBPB.pls 120.2 2008/02/04 13:17:14 nikshah ship $ */

PROCEDURE print_cons_bill(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
) IS

CURSOR cons_hdr IS
	   SELECT a.*
	   FROM okl_cnsld_ar_hdrs_v a
       WHERE EXISTS (SELECT 1 FROM
                                  (SELECT x.id
                                   FROM okl_cnsld_ar_hdrs_v x,
                                        okl_cnsld_ar_lines_v y,
                                        okl_cnsld_ar_strms_v z
                                   WHERE x.trx_status_code like 'PROCESSED%' AND
                                         x.id              = y.cnr_id        AND
                                         y.id              = z.lln_id        AND
                                         z.receivables_invoice_id            IS NOT NULL) b
                     WHERE b.id = a.id
       -- nikshah bug 6747706 added org check
       AND NVL(a.ORG_ID, MO_GLOBAL.GET_CURRENT_ORG_ID) = MO_GLOBAL.GET_CURRENT_ORG_ID)
       -- nikshah bug 6747706 end
       ORDER BY to_number(a.consolidated_invoice_number);

CURSOR cons_line(p_cnr_id 		NUMBER) IS
	   SELECT sequence_number,
			  nvl(amount, 0) + nvl(tax_amount, 0) amount,
			  ilt_id,
			  khr_id,
			  kle_id
	   FROM okl_cnsld_ar_lines_v
	   WHERE cnr_id = p_cnr_id;

CURSOR invoice_line_type(p_ilt_id 	NUMBER) IS
	 SELECT name
 	 FROM okl_invc_line_types_v
	 WHERE id = p_ilt_id;

CURSOR contract_number (p_khr_id 	NUMBER) IS
	   SELECT contract_number
	   FROM okc_k_headers_b
	   WHERE id = p_khr_id;

CURSOR asset_name(p_kle_id 	NUMBER) IS
	 SELECT name, description
 	 FROM okx_asset_lines_v
	 WHERE parent_line_id = p_kle_id;

CURSOR party_name_csr ( p_party_id NUMBER ) is
	   SELECT party_name,
	   		  party_id
	   FROM hz_parties
	   where party_id = p_party_id;


CURSOR curr_csr ( p_code VARCHAR2 ) IS
	   Select name
	   from fnd_currencies_vl
	   WHERE currency_code = p_code;

l_curr_descr 			    fnd_currencies_vl.name%type;

l_line_name	  				VARCHAR2(150);

l_khr_id					NUMBER;
l_kle_id					NUMBER;
l_asset_name				VARCHAR2(150);
l_asset_descr				okx_asset_lines_v.description%TYPE;

l_contract_number 			okl_k_headers_full_v.contract_number%TYPE;

l_flag						VARCHAR2(1);

l_formatted_amount			VARCHAR2(38);

cntr						NUMBER;

CURSOR bill_addr_csr ( p_id 	NUMBER ) IS
	 SELECT
       CA.account_number,
       PY.PARTY_NAME,
  	   PY.ADDRESS1,
  	   PY.ADDRESS2,
  	   PY.ADDRESS3,
  	   PY.ADDRESS4,
  	   PY.CITY,
  	   PY.STATE,
  	   PY.POSTAL_CODE,
  	   PY.COUNTRY
     FROM HZ_CUST_ACCOUNTS CA,
  		  HZ_PARTIES PY
     WHERE CA.CUST_ACCOUNT_ID = p_id AND
  		   PY.PARTY_ID 		  = CA.PARTY_ID;


l_customer_number			HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE;
l_customer_name				hz_parties.PARTY_NAME%TYPE;
l_addr1          HZ_PARTIES.ADDRESS1%TYPE;
l_addr2   		 HZ_PARTIES.ADDRESS2%TYPE;
l_addr3   		 HZ_PARTIES.ADDRESS3%TYPE;
l_addr4   		 HZ_PARTIES.ADDRESS4%TYPE;
l_city    		 HZ_PARTIES.CITY%TYPE;
l_state   		 HZ_PARTIES.STATE%TYPE;
l_postal_code  	 HZ_PARTIES.POSTAL_CODE%TYPE;
l_country		 HZ_PARTIES.COUNTRY%TYPE;

l_format_type VARCHAR2(5) := '0';
l_format_set BOOLEAN := FALSE;

BEGIN

-- Null out local variables
l_khr_id	:= NULL;
l_kle_id	:= NULL;

cntr		:= 0;
 --Process all headers
 FOR hdr IN cons_hdr LOOP
     l_format_type := '0';
     l_format_set := FALSE;

 	 cntr		:= cntr + 1;
 	 l_flag := 'Y';


     -- Clear Variables
     l_customer_name    := NULL;
     l_customer_number  := NULL;
     /*
 	 OPEN  party_name_csr ( hdr.ixx_id );
	 FETCH party_name_csr INTO l_customer_name, l_customer_number;
	 CLOSE party_name_csr;
	 */

	 l_addr1	   := NULL;
	 l_addr2	   := NULL;
  	 l_addr3	   := NULL;
  	 l_addr4       := NULL;
  	 l_city        := NULL;
	 l_state	   := NULL;
	 l_postal_code := NULL;
	 l_country 	   := NULL;

     -- Clear Variables
     l_curr_descr := NULL;
	 OPEN  curr_csr ( hdr.currency_code );
	 FETCH curr_csr INTO l_curr_descr;
	 CLOSE curr_csr;

	 OPEN  bill_addr_csr ( hdr.ixx_id );
	 FETCH bill_addr_csr INTO l_customer_number,
                              l_customer_name,
                              l_addr1,
	 	   				 	  l_addr2,
							  l_addr3,
							  l_addr4,
							  l_city,
							  l_state,
							  l_postal_code,
							  l_country;
	 CLOSE bill_addr_csr;


     FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rpad(' ', 54, ' ') || ('** Page : '||cntr||' **') || lpad(' ', 54, ' '));
	 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('-', 121, '-'));
     FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('Invoice Number', 20, ' ') || ': ' || rpad (hdr.consolidated_invoice_number,30,' ') || rPAD('Currency ', 20, ' ') || ': ' || rPAD(l_curr_descr, 47, ' '));
	 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('Customer Account', 20, ' ') || ': ' || rpad(l_customer_number,30,' ') || rPAD('Customer Name ', 20, ' ') || ': ' || rPAD(l_customer_name, 47, ' '));
	 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('Invoice Date', 20, ' ') || ': '|| rPAD( hdr.date_consolidated , 99, ' ') );

	 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('Billing Address', 20, ' ')||': '||rPAD( l_addr1 , 99, ' '));

	 IF ( l_addr2 IS NOT NULL ) THEN
	      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 22, ' ') || rPAD( l_addr2 , 99, ' ') );
	 END IF;
	 IF ( l_addr3 IS NOT NULL ) THEN
	      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 22, ' ') || rPAD( l_addr3 , 99, ' ') );
	 END IF;
	 IF ( l_addr4 IS NOT NULL ) THEN
	      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 22, ' ')|| rPAD( l_addr4 , 99, ' ') );
	 END IF;
	 IF ( l_city IS NOT NULL ) THEN
	      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 22, ' ') || rPAD( l_city , 99, ' ') );
	 END IF;
	 IF ( l_state IS NOT NULL ) THEN
	      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 22, ' ') || rPAD( l_state , 99, ' ') );
	 END IF;
	 IF ( l_postal_code IS NOT NULL ) THEN
	      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 22, ' ') || rPAD( l_postal_code , 99, ' ') );
	 END IF;
	 IF ( l_country IS NOT NULL ) THEN
	      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 22, ' ') || rPAD( l_country , 99, ' ') );
	 END IF;

	 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 121, ' '));
 	 --Process all lines
     l_khr_id	:= NULL;
     l_kle_id	:= NULL;
     FOR lines IN cons_line(hdr.id) LOOP
	     l_formatted_amount := okl_accounting_util.format_amount(lines.amount, hdr.currency_code);

	 	 IF l_khr_id IS NULL AND l_kle_id IS NULL THEN
		 	-- This could be the first time for this cons bill
			--Set those to cursor variables
	 		l_khr_id	:= lines.khr_id;
	 		l_kle_id	:= lines.kle_id;
		 END IF;
	 	 --This cursor fetches the consolidated bill line
		 --name into a local variable
         l_line_name := NULL;
	 	 OPEN invoice_line_type(lines.ilt_id);
	 	 FETCH invoice_line_type INTO l_line_name;
	 	 CLOSE invoice_line_type;

		 IF (l_line_name is null) THEN
		 	l_line_name := 'NONE';
		 END IF;

         l_contract_number := NULL;
		 -- Assign the lines to the correct format
		 IF ((l_format_type = '1') OR (lines.khr_id IS NOT NULL AND lines.kle_id IS NOT NULL)) THEN
            --setting the format type
            IF(NOT(l_format_set)) THEN
              l_format_type := '1';
              l_format_set := TRUE;
            END IF;

 	 	    OPEN contract_number( lines.khr_id );
	 	 	FETCH contract_number INTO l_contract_number;
	 	 	CLOSE contract_number;

		 	IF (lines.khr_id <> l_khr_id) THEN
			   l_khr_id := lines.khr_id;
			END IF;

			--Get Asset Name from OKX View
            l_asset_name    := NULL;
            l_asset_descr   := NULL;

			OPEN asset_name(lines.kle_id);
			FETCH asset_name INTO l_asset_name, l_asset_descr;
			CLOSE asset_name;

			IF (l_flag = 'Y') THEN
			  l_flag := 'N';
	 		  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, LPAD('-', 121, '-'));
 		      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rpad('Lease Contract', 30, ' ') ||rpad('Asset Number', 15, ' ') ||rpad('Asset Description', 31, ' ')|| rpad('Item', 20, ' ') || lpad('Amount',25,' '));
	 		  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,LPAD('-', 121, '-'));

			END IF;
	        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rpad(l_contract_number, 30,' ') ||rpad(nvl(l_asset_name, ' '),15,' ')||rpad(nvl(l_asset_descr, ' '),31,' ')||rpad(l_line_name,20,' ')|| lpad(l_formatted_amount,25,' '));
		 ELSIF ((l_format_type = '2') OR (lines.khr_id IS NOT NULL AND lines.kle_id IS NULL)) THEN

            --setting the format type
            IF(NOT(l_format_set)) THEN
              l_format_type := '2';
              l_format_set := TRUE;
            END IF;

 	 	 	OPEN contract_number( lines.khr_id );
	 	 	FETCH contract_number INTO l_contract_number;
	 	 	CLOSE contract_number;

		 	IF (lines.khr_id <> l_khr_id) THEN
			   l_khr_id := lines.khr_id;
			END IF;
			IF (l_flag = 'Y') THEN
			  l_flag := 'N';

	 		  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, LPAD('-', 121, '-'));
	          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rpad('Lease Contract' ,45, ' ')||rpad('Item' ,51,' ')||lpad('Amount',25,' '));
	 		  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, LPAD('-', 121, '-'));
			END IF;
	        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rpad(l_contract_number,45,' ')||rpad(l_line_name,51,' ')||lpad(l_formatted_amount,25,' ') );
		 ELSE
			IF (l_flag = 'Y') THEN
			  l_flag := 'N';
	 		  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, LPAD('-', 121, '-'));
	          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rpad('Item' ,96,' ') ||lpad('Amount',25,' '));
	 		  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, LPAD('-', 121, '-'));
			END IF;
 	        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(l_line_name,96,' ') || lpad(l_formatted_amount,25,' '));
		 END IF;

	 END LOOP;

 	 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, RPAD(' ', 95, ' ') || RPAD('-', 26, '-') );
	 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, LPAD('Invoice Total : ', 96, ' ') ||lpad(okl_accounting_util.format_amount(hdr.amount,hdr.currency_code), 25 ,' ') );
	 FND_FILE.PUT_LINE (FND_FILE.OUTPUT,RPAD('=', 121, '='));

	 --Start afresh for next invoice
	 l_khr_id	:= NULL;
	 l_kle_id	:= NULL;
 END LOOP;
 x_return_status := okl_api.g_ret_sts_success;
EXCEPTION
	WHEN OTHERS THEN
        x_return_status := okl_api.g_ret_sts_unexp_error;
   		FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error in Printing Consolidated Bill : '||SQLERRM);
END print_cons_bill;




PROCEDURE print_cons_bill_conc (
                errbuf  OUT NOCOPY VARCHAR2,
                retcode OUT NOCOPY NUMBER

)

IS

  l_api_version   NUMBER := 1;
  lx_msg_count     NUMBER;
  l_from_bill_date   DATE;
  l_to_bill_date     DATE;
  l_count1          NUMBER :=0;
  l_count2          NUMBER :=0;
  l_count           NUMBER :=0;
  i                 NUMBER :=0;
  l_msg_index_out   NUMBER :=0;
  lx_msg_data    VARCHAR2(4000);
  lx_return_status  VARCHAR2(1);

BEGIN

    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Starting Consolidated Bill Printing ... ');



	     Okl_Print_Cons_Bill.print_cons_bill(
                p_init_msg_list => Okl_Api.G_FALSE,
                x_return_status => lx_return_status,
                x_msg_count     => lx_msg_count,
                x_msg_data      => errbuf
		  );

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'End Consolidated Bill Printing. ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date:'||SYSDATE);
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error Counts = '||lx_msg_count);
     FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Detailed Error Messages For Each Records and Columns from TAPI ');
    BEGIN
	 	 IF ( lx_msg_count > 0 ) THEN
         	FOR i IN 1..lx_msg_count LOOP

            	fnd_msg_pub.get (p_msg_index => i,
                       p_encoded => 'F',
                       p_data => lx_msg_data,
                       p_msg_index_out => l_msg_index_out);

    		    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,i || ': ' || lx_msg_data);
            END LOOP;
		 END IF;
    EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);

   	END;
EXCEPTION
      WHEN OTHERS THEN
          NULL ;
END print_cons_bill_conc;

END Okl_Print_Cons_Bill;

/
