--------------------------------------------------------
--  DDL for Package Body ECE_CDMO_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_CDMO_UTIL" as
-- $Header: ECCDMOB.pls 120.5 2006/05/02 10:30:29 sbastida noship $
  PROCEDURE Update_AR ( Document_Type               IN  VARCHAR2,
                        Transaction_ID              IN  NUMBER,
                        Installment_Number          IN  NUMBER,
                        Multiple_Installments_Flag  IN  VARCHAR2,
                        Maximum_Installment_Number  IN  NUMBER,
                        Update_Date                 IN  DATE )
  IS


  l_Update_Value          VARCHAR2(20);
  l_EDI_Flag              VARCHAR2(1);
  l_Print_Flag            VARCHAR2(1);
  xprogress              varchar2(100);

  BEGIN

    ec_debug.push('ECE_AR_TRANSACTION.UPDATE_AR');
    ec_debug.pl ( 3, 'Document_Type: ', Document_Type );
    ec_debug.pl ( 3, 'Transaction_ID: ', Transaction_ID );
    ec_debug.pl ( 3, 'Installment_Number: ', Installment_Number );
    ec_debug.pl ( 3, 'Multiple_Installments_Flag: ',Multiple_Installments_Flag );
    ec_debug.pl ( 3, 'Maximum_Installment_Number: ',Maximum_Installment_Number );
    ec_debug.pl ( 3, 'Update_Date: ',Update_Date );

    xProgress := '2000-20';
    BEGIN
/*  Replaced as per bug:5081637
      SELECT edi_flag,
             print_flag
        INTO l_EDI_flag,
             l_Print_flag
        FROM ece_cdmo_header_v      eih,
             ece_tp_details         etd,
             hz_cust_acct_sites     cas
       WHERE eih.bill_to_address_id = cas.cust_acct_site_id
         AND cas.tp_header_id       = etd.tp_header_id
         AND etd.document_type      = Update_AR.Document_Type
         AND eih.transaction_id     = Update_AR.Transaction_ID;
*/

       SELECT etd.edi_flag,etd.print_flag
        INTO l_EDI_flag,
             l_Print_flag
       FROM
           ra_customer_trx rct,
           hz_cust_site_uses_all csu,
           hz_cust_acct_sites_all cas,
           ece_tp_headers eth,
           ece_tp_details etd
       WHERE
           rct.bill_to_site_use_id = csu.site_use_id and
           csu.cust_acct_site_id = cas.cust_acct_site_id and
           cas.tp_header_id = eth.tp_header_id and
           eth.tp_header_id = etd.tp_header_id and
           rct.CUSTOMER_TRX_ID = update_ar.transaction_id and
           etd.document_type = update_ar.document_type;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ec_debug.pl ( 0,
                      'EC',
                      'ECE_NO_ROW_SELECTED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'INFO',
                      'EDI FLAG, PRINT FLAG',
                      'TABLE_NAME',
                      'ECE_CDMO_HEADER_V, ECE_TP_DETAILS, HZ_CUST_ACCT_SITES' );
-- bug 4718847
    END;

    IF l_EDI_Flag    = 'Y' AND
       l_Print_Flag  = 'Y'
    THEN
      l_Update_Value := 'EP';
    END IF;

    IF l_EDI_Flag    = 'Y' AND
       l_Print_Flag <> 'Y'
    THEN
      l_Update_Value := 'ED';
    END IF;

    IF l_EDI_Flag   <> 'Y' AND
       l_Print_Flag  = 'Y'
    THEN
      l_Update_Value := 'PR';
    END IF;

    ec_debug.pl ( 3, 'L_UPDATE_VALUE: ',l_Update_Value );

    xProgress := '2010-20';
    UPDATE ra_customer_trx
       SET last_update_date          = SYSDATE,
           printing_pending          = DECODE (Document_Type,
                                               'CM', 'N',
                                               'OACM', 'N',
                                               DECODE (Maximum_Installment_Number,
                                                       Installment_Number, 'N',
                                                       NULL, 'N',
                                                       1, 'N',
                                                       'Y')),
           printing_count            = NVL(printing_count,0) + 1,
           printing_last_printed     = SYSDATE,
           printing_original_date    = DECODE (NVL(printing_count,0),
                                               0, SYSDATE,
                                               printing_original_date ),
           last_printed_sequence_num = DECODE  (Multiple_Installments_Flag,
                                                'N',NULL,
                                                GREATEST(NVL(last_printed_sequence_num,0),
                                                         Installment_Number)),
           edi_processed_flag        = 'Y',
           edi_processed_status      = l_Update_Value
     WHERE customer_trx_id           = Update_AR.Transaction_ID;

    IF SQL%NOTFOUND
    THEN
      ec_debug.pl (0,
                   'EC',
                   'ECE_NO_ROW_UPDATED',
                   'PROGRESS_LEVEL',
                   xProgress,
                   'INFO',
                   'EDI PROCESSED',
                   'TABLE_NAME',
                   'RA_CUSTOMER_TRX' );
    END IF;

  /* The following lines were commented out was because of a request
     from a beta site.  Their business practice requires them to
     print multiple installment invoices at the same time.

     BE AWARE: by doing so, we are removing the data consistency test.
  */
  --  AND LAST_UPDATE_DATE = Update_AR.Update_Date;

    -- The join on last_update_date is to ensure that the
    -- record has not been updated by another user, between
    -- the select above and the lock created by this update.

  /*  IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20000,'Record changed by another user.');
    END IF;
  */

  ec_debug.pop('ECE_AR_TRANSACTION.UPDATE_AR');
  EXCEPTION
    WHEN OTHERS THEN

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_PROGRAM_ERROR',
                    'PROGRESS_LEVEL',
                    xProgress );

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_ERROR_MESSAGE',
                    'ERROR_MESSAGE',
                    SQLERRM );

      app_exception.raise_exception;

  END Update_AR;

PROCEDURE GET_REMIT_ADDRESS (
	customer_trx_id 	IN 	NUMBER,
	remit_to_address1 	OUT NOCOPY 	VARCHAR2,
	remit_to_address2 	OUT NOCOPY 	VARCHAR2,
	remit_to_address3 	OUT NOCOPY 	VARCHAR2,
	remit_to_address4 	OUT NOCOPY 	VARCHAR2,
	remit_to_city		OUT NOCOPY	VARCHAR2,
	remit_to_county		OUT NOCOPY	VARCHAR2,
	remit_to_state		OUT NOCOPY	VARCHAR2,
	remit_to_province	OUT NOCOPY	VARCHAR2,
	remit_to_country	OUT NOCOPY	VARCHAR2,
        remit_to_code_int       OUT NOCOPY      VARCHAR2,
	remit_to_postal_code	OUT NOCOPY	VARCHAR2)
IS

  xprogress              varchar2(100);
  L_REMIT_TO_ADDRESS_ID   NUMBER;
  DUMMY NUMBER;

BEGIN

ec_debug.pl(3, 'Inside Get Remit to Address');
xProgress := '2000-30';
begin
SELECT  REMIT_TO_ADDRESS_ID INTO l_remit_to_address_id
  FROM  RA_CUSTOMER_TRX
 WHERE  CUSTOMER_TRX_ID = get_remit_address.customer_trx_id;
exception
   when no_data_found
   then
      l_remit_to_address_id := null;
      ec_debug.pl(3, 'Remit to not found. Setting to Null');
end;

IF l_remit_to_address_id IS NULL THEN

  DECLARE
-- bug 4718847
  CURSOR remit_cur IS
  SELECT RT.ADDRESS_ID
    FROM RA_CUSTOMER_TRX RCT,HZ_CUST_ACCT_SITES A,RA_REMIT_TOS RT,
         HZ_PARTY_SITES HPS,HZ_LOCATIONS LOC
   WHERE RCT.CUSTOMER_TRX_ID = get_remit_address.customer_trx_id
     AND RCT.BILL_TO_ADDRESS_ID = A.CUST_ACCT_SITE_ID
     AND A.PARTY_SITE_ID = HPS.PARTY_SITE_ID
     AND HPS.LOCATION_ID = LOC.LOCATION_ID
     AND RT.STATUS = 'A'
     AND NVL(A.STATUS,'A') = 'A'
     AND RT.COUNTRY = LOC.COUNTRY
     AND ( LOC.STATE = NVL(RT.STATE, LOC.STATE )
          OR    (   LOC.STATE IS NULL
	         AND RT.STATE IS NULL
	        )
  	  OR    (   LOC.STATE IS NULL
	         AND LOC.POSTAL_CODE <= NVL(RT.POSTAL_CODE_HIGH, LOC.POSTAL_CODE)
                 AND LOC.POSTAL_CODE >= NVL(RT.POSTAL_CODE_LOW,  LOC.POSTAL_CODE)
   	         AND (   POSTAL_CODE_LOW IS NOT NULL
	              OR POSTAL_CODE_HIGH IS NOT NULL
	             )
	        )
	 )
     AND ( (    LOC.POSTAL_CODE <= NVL(RT.POSTAL_CODE_HIGH, LOC.POSTAL_CODE)
            AND LOC.POSTAL_CODE >= NVL(RT.POSTAL_CODE_LOW, LOC.POSTAL_CODE)
	   )
	   OR (    LOC.POSTAL_CODE IS NULL
	       AND RT.POSTAL_CODE_LOW  IS NULL
	       AND RT.POSTAL_CODE_HIGH IS NULL
	      )
	 )
   ORDER BY RT.STATE, RT.POSTAL_CODE_LOW, RT.POSTAL_CODE_HIGH;

  BEGIN
  -- We only want the first record from the select since the
  -- order by puts the records in a special order
  xProgress := '2010-30';
  OPEN remit_cur;
  FETCH remit_cur INTO l_remit_to_address_id;
  IF remit_cur%NOTFOUND THEN
    l_remit_to_address_id := NULL;
  END IF;
  CLOSE remit_cur;

  END;

END IF;

IF l_remit_to_address_id IS NULL THEN
  xProgress := '2020-30';

  SELECT MIN(ADDRESS_ID) INTO l_remit_to_address_id
    FROM RA_REMIT_TOS
   WHERE STATUS='A'
     AND STATE   = 'DEFAULT'
     AND COUNTRY = 'DEFAULT';

END IF;
 -- bug 4718847
xProgress := '2030-30';
SELECT  LOC.ADDRESS1, LOC.ADDRESS2, LOC.ADDRESS3, LOC.ADDRESS4,
	  LOC.CITY, LOC.COUNTY, LOC.STATE, LOC.PROVINCE, LOC.COUNTRY, LOC.POSTAL_CODE,
          HCAS.ORIG_SYSTEM_REFERENCE
  INTO  remit_to_address1, remit_to_address2, remit_to_address3,
	  remit_to_address4, remit_to_city, remit_to_county, remit_to_state,
	  remit_to_province, remit_to_country, remit_to_postal_code,
          remit_to_code_int
  FROM  HZ_CUST_ACCT_SITES HCAS,
        HZ_LOCATIONS LOC,
        HZ_PARTY_SITES HPS
 WHERE  HPS.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
   AND  HPS.LOCATION_ID = LOC.LOCATION_ID
   AND  HCAS.CUST_ACCT_SITE_ID = l_remit_to_address_id;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('EC','ECE_PROGRAM_ERROR');
    fnd_message.set_token('PROGRESS_LEVEL',xProgress);
    ec_debug.pl( 3,fnd_message.get);
    ec_debug.pl( 3,SQLERRM);
/*    app_exception.raise_exception; */

END GET_REMIT_ADDRESS;

PROCEDURE GET_PAYMENT (
	customer_trx_id 	    	      IN 	NUMBER,
	installment_number		IN	NUMBER,
	multiple_installments_flag	OUT NOCOPY	VARCHAR2,
	maximum_installment_number	OUT NOCOPY	NUMBER,
	amount_tax_due	 		OUT NOCOPY 	NUMBER,
	amount_charges_due		OUT NOCOPY 	NUMBER,
	amount_freight_due 		OUT NOCOPY 	NUMBER,
	amount_line_items_due		OUT NOCOPY 	NUMBER,
	total_amount_due		OUT NOCOPY 	NUMBER,
        total_amount_remaining          OUT NOCOPY     NUMBER)

IS
  xprogress              varchar2(100);
l_term_id NUMBER;
l_payment_schedule_exists VARCHAR2(1);
l_term_base_amount NUMBER;
l_term_relative_amount NUMBER;
l_minimum_installment_number NUMBER;
l_amount_tax_due NUMBER;
l_amount_charges_due NUMBER;
l_amount_freight_due NUMBER;
l_amount_line_items_due NUMBER;
l_first_installment_code VARCHAR2(30);
l_type VARCHAR2(30);
l_currency_precision NUMBER;

-- This procedure gets the amount due/credited for a paricular installment
-- of an Invoice or Credit Memo (or any of the related documents)

BEGIN

  -- This select statement is used to determine whether this transaction
  -- has a payment_schedule.  If it does we can get all of the information
  -- we need directly from the payment_schedule, else we need to derive it
  -- from the payment term.
  xProgress := '2000-40';
  SELECT RCT.TERM_ID, FC.PRECISION, RCTT.ACCOUNTING_AFFECT_FLAG,
	   RCTT.TYPE, RT.FIRST_INSTALLMENT_CODE,
    	DECODE(RCTT.TYPE,
	      'CM',
	      'N',
	      'OACM',
	      'N',
	      DECODE(COUNT(*),
		     0,
		     'N',
		     1,
		     'N',
		     'Y')),
	MAX(RTL.SEQUENCE_NUM),
	MIN(RTL.SEQUENCE_NUM)
    INTO l_term_id, l_currency_precision, l_payment_schedule_exists, l_type,
	   l_first_installment_code, multiple_installments_flag,
	   maximum_installment_number, l_minimum_installment_number
    FROM RA_CUSTOMER_TRX RCT, RA_CUST_TRX_TYPES RCTT, RA_TERMS_LINES RTL,
	   RA_TERMS RT, FND_CURRENCIES FC
   WHERE RCT.CUSTOMER_TRX_ID = get_payment.customer_trx_id
     AND RCT.INVOICE_CURRENCY_CODE = FC.CURRENCY_CODE
     AND RCT.CUST_TRX_TYPE_ID = RCTT.CUST_TRX_TYPE_ID
     AND RCT.TERM_ID = RT.TERM_ID (+)
     AND RT.TERM_ID = RTL.TERM_ID (+)
     GROUP BY RCT.TERM_ID, FC.PRECISION, RCTT.ACCOUNTING_AFFECT_FLAG,
	   RCTT.TYPE, RT.FIRST_INSTALLMENT_CODE;

  xProgress := '2010-40';
  SELECT NVL(MIN(RTL.RELATIVE_AMOUNT),1), NVL(MIN(RT.BASE_AMOUNT),1)
    INTO  l_term_relative_amount, l_term_base_amount
    FROM  RA_TERMS RT, RA_TERMS_LINES RTL
    WHERE RT.TERM_ID = l_term_id
      AND RT.TERM_ID = RTL.TERM_ID
      AND RTL.SEQUENCE_NUM = get_payment.installment_number;

  IF l_payment_schedule_exists = 'Y' THEN
    xProgress := '2020-40';
    SELECT NVL(TAX_ORIGINAL,0),
	NVL(FREIGHT_ORIGINAL,0),
	NVL(AMOUNT_LINE_ITEMS_ORIGINAL,0),
	NVL(AMOUNT_DUE_ORIGINAL,0),
        NVL(AMOUNT_DUE_REMAINING,0)
      INTO amount_tax_due, amount_freight_due,
	     amount_line_items_due, total_amount_due,
           total_amount_remaining
      FROM AR_PAYMENT_SCHEDULES
     WHERE CUSTOMER_TRX_ID = get_payment.customer_trx_id
       AND DECODE(l_type,
	     'CM',get_payment.installment_number,
	     'OACM',get_payment.installment_number,
	     NVL(TERMS_SEQUENCE_NUMBER, get_payment.installment_number))
	   = get_payment.installment_number;

    xProgress := '2030-40';
    SELECT NVL(SUM((NVL(RCTL.QUANTITY_INVOICED, RCTL.QUANTITY_CREDITED) *
	            RCTL.UNIT_SELLING_PRICE)
                   * l_term_relative_amount / l_term_base_amount),0)
      INTO amount_charges_due
      FROM   RA_CUSTOMER_TRX_LINES RCTL
     WHERE  RCTL.CUSTOMER_TRX_ID = get_payment.customer_trx_id
       AND    RCTL.LINE_TYPE = 'CHARGES';

  ELSE

    -- There isn't any payment_schedule, so we need to get the information by
    -- summing up the tax, freight and lines and then applying the payment
    -- term, currency precision and if tax/freight are prorated
    xProgress := '2040-40';
    SELECT ROUND(SUM(EXTENDED_AMOUNT * l_term_relative_amount /
		     l_term_base_amount),l_currency_precision)
    INTO   l_amount_line_items_due
    FROM   RA_CUSTOMER_TRX_LINES
    WHERE  CUSTOMER_TRX_ID = get_payment.customer_trx_id
    AND    LINE_TYPE NOT IN ('TAX','FREIGHT','CHARGES');

    xProgress := '2050-40';
    SELECT ROUND(SUM(EXTENDED_AMOUNT * l_term_relative_amount /
		     l_term_base_amount),l_currency_precision)
    INTO   l_amount_charges_due
    FROM   RA_CUSTOMER_TRX_LINES
    WHERE  CUSTOMER_TRX_ID = get_payment.customer_trx_id
    AND    LINE_TYPE = 'CHARGES';

    -- Check to see if the tax/freight are prorated across installments
    -- or if they are simply included on the first installment.

    xProgress := '2060-40';
    IF l_first_installment_code = 'INCLUDE' THEN
      xProgress := '2070-40';
      IF l_minimum_installment_number = get_payment.installment_number THEN

        xProgress := '2080-40';
        SELECT SUM(EXTENDED_AMOUNT)
        INTO   l_amount_tax_due
        FROM   RA_CUSTOMER_TRX_LINES
        WHERE  CUSTOMER_TRX_ID = get_payment.customer_trx_id
        AND    LINE_TYPE = 'TAX';

        xProgress := '2090-40';
        SELECT SUM(EXTENDED_AMOUNT)
        INTO   l_amount_freight_due
        FROM   RA_CUSTOMER_TRX_LINES
        WHERE  CUSTOMER_TRX_ID = get_payment.customer_trx_id
        AND    LINE_TYPE = 'FREIGHT';

      ELSE
        l_amount_tax_due := 0;
        l_amount_freight_due := 0;
      END IF;

    ELSE

      xProgress := '2100-40';
      SELECT ROUND(SUM(EXTENDED_AMOUNT * l_term_relative_amount /
		       l_term_base_amount),l_currency_precision)
        INTO l_amount_tax_due
        FROM  RA_CUSTOMER_TRX_LINES
       WHERE  CUSTOMER_TRX_ID = get_payment.customer_trx_id
         AND  LINE_TYPE = 'TAX';

      xProgress := '2110-40';
      SELECT ROUND(SUM(EXTENDED_AMOUNT * l_term_relative_amount /
		       l_term_base_amount),l_currency_precision)
      INTO   l_amount_freight_due
      FROM   RA_CUSTOMER_TRX_LINES
      WHERE  CUSTOMER_TRX_ID = get_payment.customer_trx_id
      AND	   LINE_TYPE = 'FREIGHT';

    END IF;

    -- Total up the values and assign them to the out parameters.
    xProgress := '2120-40';
    total_amount_due := l_amount_tax_due + l_amount_freight_due
	                + l_amount_charges_due + l_amount_line_items_due;
    amount_tax_due := NVL(l_amount_tax_due,0);
    amount_charges_due := NVL(l_amount_charges_due,0);
    amount_freight_due := NVL(l_amount_freight_due,0);
    amount_line_items_due := NVL(l_amount_line_items_due,0);

  END IF;


EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('EC','ECE_PROGRAM_ERROR');
    fnd_message.set_token('PROGRESS_LEVEL',xProgress);
    app_exception.raise_exception;
END GET_PAYMENT;


-- The following procedure gets the discount information
-- for the term being used.  The discount info is a sub-table
-- off of terms, this procedure will get the first three
-- discounts, this is a denormalization, but is being used
-- to avoid the overhead of another level of data.
-- Also it is assumed that Credit Memo types (CM and OACM) do not have
-- payment terms information, even though they mat have a payment term

PROCEDURE GET_TERM_DISCOUNT (
	document_type		 IN	 VARCHAR2,
	term_id			 IN	 NUMBER,
	term_sequence_number     IN      NUMBER,
	discount_percent1        OUT NOCOPY 	 NUMBER,
	discount_days1           OUT NOCOPY      NUMBER,
	discount_date1           OUT NOCOPY      DATE,
	discount_day_of_month1   OUT NOCOPY      NUMBER,
	discount_months_forward1 OUT NOCOPY      NUMBER,
	discount_percent2        OUT NOCOPY 	 NUMBER,
	discount_days2           OUT NOCOPY      NUMBER,
	discount_date2           OUT NOCOPY      DATE,
	discount_day_of_month2   OUT NOCOPY      NUMBER,
	discount_months_forward2 OUT NOCOPY      NUMBER,
	discount_percent3        OUT NOCOPY 	 NUMBER,
	discount_days3           OUT NOCOPY      NUMBER,
	discount_date3           OUT NOCOPY      DATE,
	discount_day_of_month3   OUT NOCOPY    NUMBER,
	discount_months_forward3 OUT NOCOPY    NUMBER)
IS
CURSOR discount IS SELECT DISCOUNT_PERCENT,
				DISCOUNT_DAYS,
				DISCOUNT_DATE,
				DISCOUNT_DAY_OF_MONTH,
				DISCOUNT_MONTHS_FORWARD
		    FROM 	RA_TERMS_LINES_DISCOUNTS
		   WHERE	TERM_ID = get_term_discount.term_id
		     AND	SEQUENCE_NUM =
			get_term_discount.term_sequence_number;
l_counter 		      NUMBER DEFAULT 1;
l_discount_percent            NUMBER;
l_discount_days               NUMBER;
l_discount_date               DATE;
l_discount_day_of_month       NUMBER;
l_discount_months_forward     NUMBER;
  xprogress              varchar2(100);

BEGIN

  xProgress := '2000-50';
  IF get_term_discount.document_type IN ('CM','OACM') THEN

    discount_percent1		:= null;
    discount_days1		:= null;
    discount_date1		:= null;
    discount_day_of_month1 	:= null;
    discount_months_forward1 	:= null;
    discount_percent2		:= null;
    discount_days2		:= null;
    discount_date2		:= null;
    discount_day_of_month2 	:= null;
    discount_months_forward2 	:= null;
    discount_percent3		:= null;
    discount_days3		:= null;
    discount_date3		:= null;
    discount_day_of_month3 	:= null;
    discount_months_forward3 	:= null;

  ELSE
    xProgress := '2010-50';
    OPEN DISCOUNT;

    LOOP
      xProgress := '2020-50';
      FETCH discount into l_discount_percent,
			l_discount_days,
			l_discount_date,
			l_discount_day_of_month,
			l_discount_months_forward;
      EXIT WHEN discount%NOTFOUND;

      xProgress := '2030-50';
      IF l_counter = 1 THEN
      	discount_percent1        := l_discount_percent;
	discount_days1           := l_discount_days;
	discount_date1           := l_discount_date;
	discount_day_of_month1   := l_discount_day_of_month;
	discount_months_forward1 := l_discount_months_forward;
      END IF;

      xProgress := '2040-50';
      IF l_counter = 2 THEN
      	discount_percent2        := l_discount_percent;
	discount_days2           := l_discount_days;
	discount_date2           := l_discount_date;
	discount_day_of_month2   := l_discount_day_of_month;
	discount_months_forward2 := l_discount_months_forward;
      END IF;

      xProgress := '2050-50';
      IF l_counter = 3 THEN
      	discount_percent3        := l_discount_percent;
	discount_days3           := l_discount_days;
	discount_date3           := l_discount_date;
	discount_day_of_month3   := l_discount_day_of_month;
	discount_months_forward3 := l_discount_months_forward;
      END IF;

      l_counter := l_counter + 1;

    END LOOP;

  END IF;
EXCEPTION
  WHEN others THEN
    fnd_message.set_name('EC','ECE_PROGRAM_ERROR');
    fnd_message.set_token('PROGRESS_LEVEL',xProgress);
    app_exception.raise_exception;
END GET_TERM_DISCOUNT;

--Bug 1940758
PROCEDURE UPDATE_HEADER_WITH_LINE (
        p_customer_trx_id                 IN      NUMBER) IS
nPos1			pls_integer;
nPos2			pls_integer;
nPos3			pls_integer;
nPos4			pls_integer;
nPos5			pls_integer;
nPos6			pls_integer;
nPos7			pls_integer;
nPos8			pls_integer;
l_gross_weight  	varchar2(30);
l_net_weight    	varchar2(30);
l_weight_uom_code	varchar2(3);
l_volume		varchar2(30);
l_volume_uom_code	varchar2(3);
l_shipment_number	varchar2(30);
l_booking_number	varchar2(30);
l_bill_of_lading	varchar2(30);
xprogress              varchar2(100);
BEGIN
      xProgress := '2070-10';
      ec_utils.find_pos (
         1,
         'GROSS_WEIGHT',
         nPos1);

      xProgress := '2070-20';
      ec_utils.find_pos (
         1,
         'NET_WEIGHT',
         nPos2);

      xProgress := '2070-30';
      ec_utils.find_pos (
         1,
         'WEIGHT_UOM_CODE_INT',
         nPos3);

      xProgress := '2070-40';
      ec_utils.find_pos (
         1,
         'VOLUME',
         nPos4);

      xProgress := '2070-50';
      ec_utils.find_pos (
         1,
         'VOLUME_UOM_CODE_INT',
         nPos5);

      xProgress := '2070-60';
      ec_utils.find_pos (
         1,
         'SHIPMENT_NUMBER',
         nPos6);

      xProgress := '2070-70';
      ec_utils.find_pos (
         1,
         'BOOKING_NUMBER',
         nPos7);

      xProgress := '2070-80';
      ec_utils.find_pos (
         1,
         'BILL_OF_LADING_NUMBER',
         nPos8);

      begin
      xProgress := '2070-90';
      select    TO_CHAR(gross_weight),
		TO_CHAR(net_weight),
		weight_uom_code_int,
		TO_CHAR(volume),
		volume_uom_code_int,
		TO_CHAR(shipment_number) ,
		booking_number,
		bill_of_lading_number
      into   l_gross_weight,
	     l_net_weight,
	     l_weight_uom_code,
	     l_volume,
	     l_volume_uom_code,
	     l_shipment_number,
	     l_booking_number,
	     l_bill_of_lading
      from   ece_cdmo_line_v
      where  transaction_id = p_customer_trx_id
      and    sales_order_number is not null
      and    rownum=1;

    exception
    when no_data_found then
	ec_debug.pl(3,'No records found for the customer_trx_id',p_customer_trx_id);
    end;

      xProgress := '2070-100';
      ec_utils.g_file_tbl(nPos1).value:=	l_gross_weight;
      ec_utils.g_file_tbl(nPos2).value:=	l_net_weight;
      ec_utils.g_file_tbl(nPos3).value:=	l_weight_uom_code;
      ec_utils.g_file_tbl(nPos4).value:=	l_volume;
      ec_utils.g_file_tbl(nPos5).value:=	l_volume_uom_code;
      ec_utils.g_file_tbl(nPos6).value:=	l_shipment_number;
      ec_utils.g_file_tbl(nPos7).value:=	l_booking_number;
      ec_utils.g_file_tbl(nPos8).value:=	l_bill_of_lading;

EXCEPTION
  WHEN others THEN
    fnd_message.set_name('EC','ECE_PROGRAM_ERROR');
    fnd_message.set_token('PROGRESS_LEVEL',xProgress);
    app_exception.raise_exception;
END UPDATE_HEADER_WITH_LINE;

end ece_cdmo_util;

/
