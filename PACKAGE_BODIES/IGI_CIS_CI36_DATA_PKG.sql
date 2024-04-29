--------------------------------------------------------
--  DDL for Package Body IGI_CIS_CI36_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS_CI36_DATA_PKG" as
 /* $Header: igiciseb.pls 115.19 2003/12/17 13:54:28 hkaniven noship $ */



	l_debug_level NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
	l_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
	l_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
	l_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
	l_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
	l_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
	l_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
	l_path        VARCHAR2(50)  :=  'IGI.PLSQL.igiciseb.IGI_CIS_CI36_DATA_PKG.';


  PROCEDURE Debug    ( p_level IN NUMBER, p_path IN VARCHAR2, p_mesg IN VARCHAR2  ) is
    BEGIN
	IF (p_level >=  l_debug_level ) THEN
                  FND_LOG.STRING  (p_level , l_path || p_path , p_mesg );
        END IF;

    END ;



  PROCEDURE  Extract_data ( Errbuf             OUT NOCOPY VARCHAR2,
                            Retcode            OUT NOCOPY NUMBER,
                            x_cis_report        IN VARCHAR2,
                            x_operating_unit    IN VARCHAR2,
			    --x_sob_name          IN VARCHAR2,
                            --x_set_of_books_id   IN NUMBER,
                            x_low_date1         IN VARCHAR2,
                            x_high_date1        IN VARCHAR2,
                            x_vendor_id         IN NUMBER
		             )
   is



   CURSOR  c_cis_payments  IS
   SELECT  Invoice_id , Invoice_num, Invoice_payment_id, Amount, Pmt_vch_number, Pmt_vch_amount,
           Pmt_vch_description, Check_number, Check_date, Vendor_id, Vendor_name, Vendor_site_id,
           Vendor_site_code, Group_id, Certificate_type, Certificate_number, Certificate_description,
           Ni_number
   FROM    igi_cis_ci36_payments;

   /* Modified the AND condition to include nvl check for icatr1.end_date Bug Bug#2443887 -solakshm*/
   CURSOR c_cis_awt_tax_rates (P_vendor_id      igi_cis_awt_tax_rates.vendor_id%TYPE,
                               P_vendor_site_id igi_cis_awt_tax_rates.vendor_site_id%TYPE,
                               P_check_date     igi_cis_ci36_payments.Check_date%TYPE )
   IS
   SELECT	icatr1.certificate_type , icatr1.certificate_number ,
                Substr(icatr1.comments,1,50) "comments", icatr1.ni_number
   FROM	        igi_cis_awt_tax_rates icatr1
   WHERE 	icatr1.vendor_id        = P_vendor_id
    AND 	icatr1.vendor_site_id   = P_vendor_site_id
    AND 	icatr1.tax_name         = fnd_profile.value ('IGI_CIS_TAX_CODE')
    AND 	TRUNC(NVL(P_check_date,icatr1.start_date))
                BETWEEN  TRUNC(icatr1.start_date)
                         AND nvl(TRUNC(icatr1.end_date),to_date('9999/12/31','YYYY/MM/DD'))
    AND         NVL(icatr1.priority, '-1') =
         (SELECT   NVL(MIN(icatr2.priority), '-1')
          FROM      igi_cis_awt_tax_rates icatr2
          WHERE     icatr2.vendor_id                 = P_vendor_id
          AND       icatr2.vendor_site_id            = P_vendor_site_id
          AND       icatr2.tax_name                  = fnd_profile.value ('IGI_CIS_TAX_CODE')
          AND       TRUNC(NVL(P_check_date,icatr2.start_date))
                    BETWEEN TRUNC(icatr2.start_date)
                            AND nvl(TRUNC(icatr2.end_date),to_date('9999/12/31','YYYY/MM/DD')));

   /* Added this cursor for Bug 2938921 rgopalan */
   -- Bug 3102763 (Tpradhan), Removed the ABS function which was applied for cis_amount
   -- Bug 3146816 (Tpradhan), flipped the sign for cis_amount by multiplying it with -1
   CURSOR cur_insert_into_extract (p_invoice_id number)
   IS
       SELECT
               certificate_type,
               vendor_name,
               vendor_site_code,
               certificate_number,
               certificate_description,
               ni_number,
               pmt_vch_number,
               pmt_vch_description,
               SUM (DECODE (awt_group_id,icip.group_id,0,
                    NVL (DECODE (line_type_lookup_code, 'ITEM',  aid.amount, 0), 0)))
                    material_amount,
               SUM (NVL (DECODE (awt_group_id, icip.group_id, aid.amount,0),0))  labor_amount,
               SUM (NVL (DECODE  (line_type_lookup_code,'AWT',-aid.amount,0),0))  cis_amount,
              (NVL (icip.Amount,0) - SUM (NVL (DECODE (line_type_lookup_code, 'TAX', aid.amount, 0), 0))) net_amount
       FROM
               ap_invoice_distributions aid,
               igi_cis_ci36_payments icip
       WHERE
               aid.invoice_id = icip.invoice_id
       AND     aid.invoice_id = p_invoice_id
       GROUP BY
               certificate_type,
               vendor_name,
               vendor_site_code,
               certificate_number,
               certificate_description,
               ni_number,
               pmt_vch_number,
               pmt_vch_description,
               icip.Amount;


   /* Added this cursor for Bug 2938921 rgopalan */
   CURSOR cur_invoice_list
   IS
       SELECT
              ai.invoice_id,
              ai.invoice_num,
              icip.segment1,
              icip.check_number,
              icip.check_date,
              icip.amount,
              icip.address_line1,
              icip.address_line2,
              icip.address_line3,
              icip.zip,
              icip.pmt_vch_received_date
       FROM
              ap_invoices ai, igi_cis_ci36_payments icip
       WHERE
              ai.invoice_id = icip.invoice_id;


  /* Cursors for the log */
  Cursor cur_log1 is
          select count(*) from igi_cis_ci36_extract;

  Cursor cur_log2 is
          select count(*) from igi_cis_ci36_payments;

   l_invoice_num                 igi_cis_ci36_payments.invoice_num%TYPE;
   l_certificate_type            igi_cis_awt_tax_rates.certificate_type%TYPE;
   l_certificate_number          igi_cis_awt_tax_rates.certificate_number%TYPE;
   l_certificate_description     Varchar2(50);
   l_ni_number                   igi_cis_awt_tax_rates.ni_number%TYPE;
   l_return_status               Number;
   x_low_date                    date;
   x_high_date                   date;
   l_count1                      Number := 0;
   l_count2                      Number := 0;
   l_cis_records                 Number := 0;
   l_errbuf                      VARCHAR2(100) := '';

BEGIN
           /* deleting all the records from the temporary table as it will have data
              related to previous session */

           x_low_date  := to_date(x_low_date1, 'YYYY/MM/DD HH24:MI:SS');
           x_high_date := to_date(x_high_date1, 'YYYY/MM/DD HH24:MI:SS');

	   /***************** This is for the log file ******************/


	   Debug(l_state_level, 'Extract_data',' *************** Populating the CIS Temporary Table *************** ');
	   Debug(l_state_level, 'Extract_data',' PARAMTER LIST');
	   Debug(l_state_level, 'Extract_data',' x_cis_report -> ' || x_cis_report);
	   Debug(l_state_level, 'Extract_data',' x_low_date  -> ' || x_low_date );
	   Debug(l_state_level, 'Extract_data',' x_high_date -> ' || x_high_date );
	   Debug(l_state_level, 'Extract_data',' ');
	   Debug(l_state_level, 'Extract_data',' Deleting rows from temporary table');



           open  cur_log1;
           fetch cur_log1 INTO l_count1;
           close cur_log1;

           open  cur_log2;
           fetch cur_log2 INTO l_count2;
           close cur_log2;


	   Debug(l_state_level, 'Extract_data',' No. of records selected for deletion' ||
                                             ' from igi_cis_ci36_extract  : ' || l_count1);
	   Debug(l_state_level, 'Extract_data',' No. of records selected for deletion' ||
                                             ' from igi_cis_ci36_payments : ' || l_count2);

           /***************** This is for the log file ******************/

           DELETE FROM igi_cis_ci36_extract;
           DELETE FROM igi_cis_ci36_payments;

           COMMIT;

          /***************** This is for the log file ******************/
          /***************** This is for the log file ******************/

	  Debug(l_state_level, 'Extract_data',' all rows deleted ');
	  Debug(l_state_level, 'Extract_data','  ');
	  Debug(l_state_level, 'Extract_data',' Inserting records into  igi_cis_ci36_payments Table ');



           INSERT INTO igi_cis_ci36_payments (
                   INVOICE_PAYMENT_ID,
                   INVOICE_ID,
                   PMT_VCH_NUMBER,
                   PMT_VCH_AMOUNT,
                   PMT_VCH_DESCRIPTION,
                   AMOUNT,
                   PAYMENT_NUM,
                   PMT_VCH_RECEIVED_DATE,
                   INVOICE_NUM,
                   VENDOR_ID,
                   VENDOR_SITE_ID,
                   CHECK_NUMBER,
                   CHECK_DATE,
                   GROUP_ID
                   )
              SELECT
                   icip.invoice_payment_id,
                   icip.invoice_id,
                   icip.pmt_vch_number,
                   icip.pmt_vch_amount,
                   icip.pmt_vch_description,
                   icip.amount,
                   icip.payment_num,
                   icip.pmt_vch_received_date,
                   ai.invoice_num,
                   ai.vendor_id,
                   ai.vendor_site_id,
                   ac.check_number,
                   ac.check_date,
                   aag.group_id
              FROM
                   igi_cis_invoice_payments icip,
                   ap_invoices ai,
                   ap_awt_groups aag,
                   ap_checks ac
             WHERE ai.payment_status_flag = 'Y'
              AND ai.invoice_id = icip.invoice_id
              AND ai.awt_group_id = aag.group_id
              AND aag.name = igi_cis_get_profile.cis_tax_group
              AND icip.check_id = ac.check_id
              AND ac.void_date IS NULL
              AND ai.vendor_id = nvl(x_vendor_id,ai.vendor_id)
              AND TRUNC(NVL(ac.check_date,x_low_date)) BETWEEN TRUNC(x_low_date) AND TRUNC(x_high_date);


           COMMIT;

           /***************** This is for the log file ******************/
           l_count1 := 0;
           open  cur_log2;
           fetch cur_log2 INTO l_count1;
           close cur_log2;

           Debug(l_state_level, 'Extract_data',' No. of records inserted : ' || l_count1);
	   Debug(l_state_level, 'Extract_data','  ');
	   Debug(l_state_level, 'Extract_data',' deleting all black listed' ||
                                             ' vendors from  igi_cis_ci36_payments ');




           /***************** This is for the log file ******************/

           /* deleting all black listed vendors */
           DELETE FROM igi_cis_ci36_payments a
           WHERE EXISTS  (SELECT  'x'     FROM   po_vendors b
                                          WHERE  b.vendor_id  = a.vendor_id
                                          AND    nvl(b.enabled_flag,'N') <> 'Y');

           /***************** This is for the log file ******************/
           l_count2 := 0;
           open  cur_log2;
           fetch cur_log2 INTO l_count2;
           close cur_log2;

           Debug(l_state_level, 'Extract_data',' No. of records deleted : '
                               || (nvl(l_count1,0) - nvl(l_count2,0)));
	   Debug(l_state_level, 'Extract_data','  ');
	   Debug(l_state_level, 'Extract_data',' Updating the vendor name' ||
                               ' for the corresponding vendor id in igi_cis_ci36_payments ');


           /***************** This is for the log file ******************/

          /* updating the vendor name for the corresponding vendor id */

           UPDATE igi_cis_ci36_payments a
           SET (a.vendor_name,a.segment1) =
                               (SELECT  vendor_name,segment1  FROM  po_vendors
                                WHERE   vendor_id = a.vendor_id);
           COMMIT;

           /***************** This is for the log file ******************/


	   Debug(l_state_level, 'Extract_data',' Removing the vendor sites which'    ||
                                             ' does not have automatic withholding'||
                                             ' tax from igi_cis_ci36_payments ');




           l_count1 := 0;
           open  cur_log2;
           fetch cur_log2 INTO l_count1;
           close cur_log2;
           /***************** This is for the log file ******************/


          /* remove the vendor sites which does not have automatic withholding tax */
           DELETE FROM igi_cis_ci36_payments a
           WHERE EXISTS  (SELECT 'x'      FROM    po_vendor_sites b
                                          WHERE   b.vendor_site_id = a.vendor_site_id
                                          AND     ( nvl(b.allow_awt_flag,'N') <> 'Y'
                                          OR      b.awt_group_id  <> a.group_id));

           /***************** This is for the log file ******************/
           l_count2 := 0;
           open  cur_log2;
           fetch cur_log2 INTO l_count2;
           close cur_log2;

           /***************** This is for the log file ******************/


	  Debug(l_state_level, 'Extract_data',' No. of records deleted : '
                                             || (nvl(l_count1,0) - nvl(l_count2,0)));
	  Debug(l_state_level, 'Extract_data','  ');
	  Debug(l_state_level, 'Extract_data',' Updating with proper vendor site code' ||
                                             ' for the corresponding vendor site id' ||
                                             ' in igi_cis_ci36_payments ');



          /* updating with proper vendor site code for the corresponding vendor site id */
          UPDATE igi_cis_ci36_payments a
          SET (a.vendor_site_code,a.address_line1,A.address_line2,A.address_line3,a.zip ) =
          (SELECT vendor_site_code,address_line1,address_line2,address_line3,zip
                                    FROM   po_vendor_sites b
                                    WHERE  b.vendor_site_id = a.vendor_site_id );
          COMMIT;


	  Debug(l_state_level, 'Extract_data',' Updating  certificate details in igi_cis_ci36_payments ');

          FOR cur_cis_payments in c_cis_payments
          LOOP

             OPEN   c_cis_awt_tax_rates (cur_cis_payments.vendor_id,
                                         cur_cis_payments.vendor_site_id,
                                         cur_cis_payments.check_date);

             FETCH  c_cis_awt_tax_rates INTO l_certificate_type,
                                             l_certificate_number,
                                             l_certificate_description,
                                             l_ni_number;

             IF (c_cis_awt_tax_rates%FOUND) THEN

                 UPDATE igi_cis_ci36_payments
                 SET     certificate_type            = l_certificate_type,
                         certificate_number          = l_certificate_number,
                         certificate_description     = l_certificate_description,
                         ni_number                   = l_ni_number
                 WHERE    vendor_id               =  cur_cis_payments.vendor_id
                 AND      vendor_site_id          =  cur_cis_payments.vendor_site_id
                 AND      invoice_id              =  cur_cis_payments.invoice_id
                 AND      invoice_payment_id      =  cur_cis_payments.invoice_payment_id
                 AND      check_number            =  cur_cis_payments.check_number;

            END IF;

            IF (c_cis_awt_tax_rates%ISOPEN) THEN
               CLOSE  c_cis_awt_tax_rates;
            END IF;

        END LOOP;

        Debug(l_state_level, 'Extract_data',' Inserting certificate details in  igi_cis_ci36_extract table ');


       /* Bug 2938921 rgopalan 25.6.2003 START*/

        FOR J IN cur_invoice_list
        LOOP

        Debug(l_state_level, 'Extract_data',' Invoice number --> '|| J.invoice_num);

         FOR I IN cur_insert_into_extract (J.invoice_id)
         LOOP

          INSERT INTO igi_cis_ci36_extract (
                 invoice_num,
                 Segment1,
                 check_number,
                 check_date,
                 amount,
                 address_line1,
                 address_line2,
                 address_line3,
                 zip,
                 pmt_vch_received_date,
                 certificate_type,
                 vendor_name,
                 vendor_site_code,
                 certificate_number,
                 certificate_description,
                 ni_number,
                 pmt_vch_number,
                 pmt_vch_description,
                 material_amount,
                 labor_amount,
                 cis_amount,
                 net_amount)
          VALUES
                (J.invoice_num,
                 J.Segment1,
                 J.check_number,
                 J.check_date,
                 J.amount,
                 J.address_line1,
                 J.address_line2,
                 J.address_line3,
                 J.zip,
                 J.pmt_vch_received_date,
                 I.certificate_type,
                 I.vendor_name,
                 I.vendor_site_code,
                 I.certificate_number,
                 I.certificate_description,
                 I.ni_number,
                 I.pmt_vch_number,
                 I.pmt_vch_description,
                 I.material_amount,
                 I.labor_amount,
                 I.cis_amount,
                 I.net_amount);

       END LOOP;

      END LOOP;

       /* Bug 2938921 rgopalan 25.6.2003 END */

      Debug(l_state_level, 'Extract_data','Commiting the changes ');

      COMMIT;

  /***************** This is for the log file ******************/
   l_count1 := 0;
   open  cur_log1;
   fetch cur_log1 INTO l_count1;
   close cur_log1;

   /***************** This is for the log file ******************/


   Debug(l_state_level, 'Extract_data',' No. of records Inserted into igi_cis_ci36_extract table : ' || l_count1);
   Debug(l_state_level, 'Extract_data','  ');
   Debug(l_state_level, 'Extract_data',' Placing a request for the report ' || x_cis_report);



  /* placing a request for the report */


  IF x_cis_report = 'IGIPCI36' THEN

  l_return_status := Fnd_request.submit_request
                   (APPLICATION   => 'IGI',
                    PROGRAM       => 'IGIPCI36',
                    DESCRIPTION   => 'Construction industry scheme: CI36 report (End of Year)',
                    START_TIME    => '',
                    SUB_REQUEST   => FALSE,
                    ARGUMENT1     => x_low_date,
                    ARGUMENT2     => x_high_date);

  Debug(l_state_level, 'Extract_data',' Placed a request for the report IGIPCI36 ');

  ELSIF x_cis_report='IGIPNVCH' THEN

  l_return_status := Fnd_request.submit_request
                   (APPLICATION  => 'IGI',
                    PROGRAM      => 'IGIPNVCH',
                    DESCRIPTION  => '',
                    START_TIME   => '',
                    SUB_REQUEST  => FALSE,
                    ARGUMENT1    => x_low_date,
                    ARGUMENT2    => x_high_date,
                    ARGUMENT3    => x_vendor_id);

  Debug(l_state_level, 'Extract_data',' Placed a request for the report IGIPNVCH');



  ELSIF   x_cis_report='IGIPVCH' THEN

  l_return_status := Fnd_request.submit_request
                   (APPLICATION  =>'IGI',
                    PROGRAM      =>'IGIPVCH',
                    DESCRIPTION  =>'',
                    START_TIME   => '',
                    SUB_REQUEST  => FALSE,
                    ARGUMENT1    => x_low_date,
                    ARGUMENT2    => x_high_date,
                    ARGUMENT3    => x_vendor_id);

  Debug(l_state_level, 'Extract_data',' Placed a request for the report IGIPVCH');

  END IF;

  Debug(l_state_level, 'Extract_data',' **************** END **************** ');


   EXCEPTION
   WHEN OTHERS THEN

      /* making sure all the cursors are closed properly */
      IF (c_cis_awt_tax_rates%ISOPEN) THEN
         CLOSE  c_cis_awt_tax_rates;
      END IF;

      retcode := 2;


      FND_MESSAGE.set_name ('IGI', 'IGI_GEN_UNHANDLED_EXCEPTION');
      FND_MESSAGE.set_token ('NAME','IGI_CIS_CI36_DATA_PKG.EXTRACT_DATA');
      errbuf :=  Fnd_message.get;

      Debug(l_excep_level, 'Extract_data',errbuf);

      l_errbuf :=  'Error Message: ' || sqlerrm || ' Error Code: ' || to_char(sqlcode);
      Debug(l_excep_level, 'Extract_data',l_errbuf);


      IF ( l_unexp_level >= l_debug_level ) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,l_path || 'Extract_data' , TRUE);
      END IF;
      APP_EXCEPTION.raise_exception;

   END Extract_data;

 END Igi_cis_ci36_data_pkg;

/
