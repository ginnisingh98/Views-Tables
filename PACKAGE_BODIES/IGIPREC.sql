--------------------------------------------------------
--  DDL for Package Body IGIPREC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIPREC" AS
--  $Header: igiprecb.pls 115.7 2002/11/18 14:08:30 panaraya ship $

--------------------------------------------------------------------
	 --To fetch the Cash_Set_of_Books_Id   Chart Of Accounts
	 --------------------------------------------------------------------
	 CURSOR  C_system_parameters IS
	 SELECT  ap.secondary_set_of_books_id,
	         gl.chart_of_accounts_id
	 FROM    ap_system_parameters ap,
	         gl_sets_of_books gl
	 WHERE   ap.set_of_books_id = gl.set_of_books_id;
	 --------------------------------------------------------------------
	 --To fetch the Concurrent Request Id
	 --Use function FND_GLOBAL.CONC_REQUEST_ID
	 --------------------------------------------------------------------
	 --------------------------------------------------------------------
	 --To fetch the Source (Payables)
	 --------------------------------------------------------------------
	 CURSOR C_source_name IS
	 SELECT je_source_name , user_je_source_name
	 FROM   gl_je_sources
	 WHERE  je_source_name = 'Payables'
	        AND LANGUAGE =  USERENV('LANG');
	 --------------------------------------------------------------------
	 --To fetch the Category   (Manual adjustments)
	 --------------------------------------------------------------------
	 CURSOR C_category_name IS
	 SELECT  je_category_name , user_je_category_name
	 FROM    gl_je_categories
	 WHERE   je_category_name = '41'
	         AND LANGUAGE =  USERENV('LANG');
	 --------------------------------------------------------------------
	 --To set the start_date and the end_date sources from parameters From Period and To Period.
	 --------------------------------------------------------------------
	 CURSOR C_period_startdate (p_period gl_period_statuses.period_name%type, p_secondary_set_of_books_id gl_interface.set_of_books_id%type ) IS
	 SELECT  start_date
	 FROM    gl_period_statuses
	 WHERE   period_name = p_period
	 AND 	set_of_books_id = p_secondary_set_of_books_id
	 AND     application_id = (SELECT application_id FROM fnd_application WHERE application_short_name ='SQLGL');

	 CURSOR C_period_enddate (p_period gl_period_statuses.period_name%type , p_secondary_set_of_books_id gl_interface.set_of_books_id%type ) IS
	 SELECT end_date
	 FROM   gl_period_statuses
	 WHERE  period_name = p_period
	 AND set_of_books_id = p_secondary_set_of_books_id
	 AND application_id =
	 (SELECT application_id FROM fnd_application WHERE application_short_name = 'SQLGL');

         --------------------------------------------------------------------
	 -- To fetch the non recoverable tax lines to be modified
	 --------------------------------------------------------------------
	 CURSOR C_get_tax_lines ( start_date date, end_date date) IS
	 SELECT
	 inv.invoice_id   INVOICE_ID ,
	 inv.invoice_date INVOICE_DATE,
	 inv_dist1.set_of_books_id ACCURAL_SET_OF_BOOKS_ID,
	 inv_dist1.invoice_distribution_id  TAX_DIST_ID,
	 inv_dist1.dist_code_combination_id TAX_CCID,
	 chrg.allocated_base_amount   TAX_AMOUNT,
	 inv_dist2.invoice_distribution_id ITEM_DIST_ID,
	 inv_dist2.dist_code_combination_id ITEM_CCID ,
	 inv_dist2.org_id ORG_ID,
	 inv.invoice_currency_code INV_CURRENCY_CODE
	 FROM
	 ap_invoice_distributions inv_dist1,
	 ap_chrg_allocations chrg,
	 ap_invoice_distributions inv_dist2,
	 ap_invoices inv
	 WHERE
	 inv_dist1.cash_posted_flag = 'Y' AND
	 inv_dist1.tax_recoverable_flag = 'Y' AND inv_dist1.line_type_lookup_code = 'TAX'
	 AND inv_dist1.invoice_distribution_id = chrg.charge_dist_id
	 AND inv_dist2.invoice_distribution_id = chrg.item_dist_id
	 AND inv.invoice_id = inv_dist1.invoice_id
	 AND inv.invoice_date BETWEEN start_date AND end_date
	 AND NOT EXISTS
	 ( SELECT 'Y' FROM IGI_RECOVERABLE_LINES WHERE tax_distribution_id = chrg.charge_dist_id);

Procedure Writelog(
    p_mesg       IN varchar2
                  )
is
Begin
    fnd_file.put_line( fnd_file.log , p_mesg ) ;
End Writelog;

Procedure Gl_Interface_Insert(
    p_status                   IN gl_interface.status%type,
    p_set_of_books_id          IN gl_interface.set_of_books_id%type,
    p_accounting_date          IN gl_interface.accounting_date%type,
    p_currency_code            IN gl_interface.currency_code%type,
    p_date_created             IN gl_interface.date_created%type,
    p_created_by               IN gl_interface.created_by%type,
    p_actual_flag              IN gl_interface.actual_flag%type,
    p_user_je_category_name    IN gl_interface.user_je_category_name%type,
    p_user_je_source_name      IN gl_interface.user_je_source_name%type,
    p_entered_dr               IN gl_interface.entered_dr%type,
    p_entered_cr               IN gl_interface.entered_cr%type,
    p_accounted_dr             IN gl_interface.accounted_dr%type,
    p_accounted_cr             IN gl_interface.accounted_cr%type,
    p_transaction_date         IN gl_interface.transaction_date%type,
    p_reference1               IN gl_interface.reference1%type,
    p_reference4               IN gl_interface.reference4%type,
    p_reference6               IN gl_interface.reference6%type,
    p_reference10              IN gl_interface.reference10%type,
    p_reference21              IN gl_interface.reference21%type,
    p_reference22              IN gl_interface.reference22%type,
    p_period_name              IN gl_interface.period_name%type,
    p_chart_of_accounts_id     IN gl_interface.chart_of_accounts_id%type,
    p_functional_currency_code IN gl_interface.functional_currency_code%type,
    p_code_combination_id      IN gl_interface.code_combination_id%type,
    p_group_id                 IN gl_interface.group_id%type);

PROCEDURE Init_Gl_Interface(
    p_int_control     IN OUT NOCOPY glcontrol,
    p_set_of_books_id IN     gl_sets_of_books.set_of_books_id%type);

PROCEDURE Insert_Control_Rec(
    p_int_control in glcontrol );




PROCEDURE Submit(
	           errbuf      		OUT NOCOPY VARCHAR2,
	           retcode     		OUT NOCOPY NUMBER,
                   p_gl_from_period     in gl_period_statuses.period_name%type,
                   p_gl_to_period	in gl_period_statuses.period_name%type
                  ) is
         l_request_id number 		   ;
         l_secondary_set_of_books_id NUMBER;
         l_chart_of_accounts_id      NUMBER;
         l_je_source_name 	     gl_je_sources.je_source_name%type;
         l_user_je_source_name 	     gl_je_sources.user_je_source_name%type;
         l_je_category_name          gl_je_categories.je_category_name%type;
         l_user_je_category_name     gl_je_categories.user_je_category_name%type;
         l_start_date		     DATE;
         l_end_date		     DATE;
         l_processed		     Boolean;
         l_int_control           glcontrol;
         l_import_request_id     number;
         l_report_request_id     number;
         -------------------------------------------------------------------
	 --To fetch the Cash_Set_of_Books_Id  and  Chart Of Accounts
	 --------------------------------------------------------------------



        -- l_tax_lines		     C_get_tax_lines%rowtype;
 begin
 	 --------------------------------------------------------------------
         -- get the secondary Secondary set of books and Chart of accounts
         --------------------------------------------------------------------
fnd_profile.get('ORG_ID',l_secondary_set_of_books_id);

           WriteLog( '>> Initialized org_id '||l_secondary_set_of_books_id);
           Open  C_system_parameters;

           Fetch C_system_parameters into l_secondary_set_of_books_id,l_chart_of_accounts_id;
           Close C_system_parameters;

           WriteLog( '>> Initialized Secondary set of books and Chart of accounts '||l_secondary_set_of_books_id||'             '||l_chart_of_accounts_id );

           Open  C_period_startdate (p_gl_from_period,l_secondary_set_of_books_id );
           Fetch C_period_startdate into l_start_date;
           Close C_period_startdate;
           WriteLog( '>> Initialized Start period  ' || l_start_date );
           Open  C_period_enddate (p_gl_to_period,l_secondary_set_of_books_id);
	   Fetch C_period_enddate into l_end_date;
	   Close C_period_enddate;
           WriteLog( '>> Initialized end period    ' || l_end_date);

           Open  C_source_name ;
           Fetch C_source_name into l_je_source_name,l_user_je_source_name;
           Close C_source_name;

           WriteLog( '>> Initialized user journal name   <<<');

           Open  C_category_name ;
           Fetch C_category_name  into l_je_category_name,l_user_je_category_name;
           Close C_category_name ;

           WriteLog( '>> Initialized user journal category name   <<<');

           --------------------------------------------------------------------
           -- Fetch the recoverable tax lines from  the invoices in the given dates
           --------------------------------------------------------------------
           l_processed :=  false;

           For  l_tax_lines  in  C_get_tax_lines ( l_start_date,l_end_date) loop

           	WriteLog( '>> Processing Invoice '|| l_tax_lines.invoice_id ||' Distribution Num '||l_tax_lines.tax_dist_id);

		if not l_processed then
                  l_processed := true;
                end if;

	--------------------------------------------------------------------
	--insert into IGI_RECOVERABLE_LINES
	--------------------------------------------------------------------

	l_request_id := FND_GLOBAL.CONC_REQUEST_ID;

	          insert into IGI_RECOVERABLE_LINES

	         	( Invoice_id,
			  Accounting_date,
			  Invoice_date,
			  Inv_Currency_Code,
			  Accrual_Set_of_books_id,
			  Request_Id,
			  Tax_distribution_id,
			  Tax_ccid,
			  Tax_amount,
			  Item_distribution_id,
			  Item_ccid,
			  last_updated_by,
			  last_update_date,
			  created_by,
			  Created_date,
			  Last_update_login)
			values ( l_tax_lines.invoice_id,
				 sysdate,
				 l_tax_lines.invoice_date,
				 l_tax_lines.INV_CURRENCY_CODE,
				 l_tax_lines.ACCURAL_SET_OF_BOOKS_ID,
				 l_request_id,
				 l_tax_lines.tax_dist_id,
				 l_tax_lines.tax_ccid,
				 l_tax_lines.tax_amount,
				 l_tax_lines.item_dist_id,
				 l_tax_lines.item_ccid,
				 to_number(fnd_profile.value('USER_ID')),
				 sysdate,
				 to_number(fnd_profile.value('LOGIN_ID')),
				 sysdate,
				 to_number(fnd_profile.value('USER_ID')));

		  --------------------------------------------------------------------
	         /* For each recoverable tax line identified insert two line into GL Interface
		    IF the tax amount is positive THEN
	       	      Debit the Item Line Code Combination Id with the Tax Line Amount
		      Credit the Tax Line Code Combination Id with the Tax Line Amount
		    ELSEIF the tax amount is negative THEN
		      Debit Tax Line ccid with absolute Tax Line Amount
		      Credit Item Line ccid with absolute Tax Line Amount
 		    END IF*/
		  --------------------------------------------------------------------

		-- Start(1) bug 2119400 vgadde 23-NOV-2001

		IF ( l_tax_lines.tax_amount > 0 ) THEN

		-- End(1) bug 2119400 vgadde 23-NOV-2001

			 -----------------------------------------------------
			 -- Debit entry for item ccid for positive tax amount
			 -----------------------------------------------------
                     Gl_interface_insert(
			 'NEW',
	                 l_secondary_set_of_books_id,
                         sysdate,
	                 l_tax_lines.INV_CURRENCY_CODE,
	                 sysdate,
	                 to_number(fnd_profile.value('USER_ID')),
	                 'A',
	                 l_user_je_category_name,
	                 l_user_je_source_name,
	                 abs(l_tax_lines.tax_amount),
	                 NULL,
	                 abs(l_tax_lines.tax_amount),
	                 NULL,
	                 sysdate,
	                 l_je_category_name,                   -- reference1
	                 NULL,                   		-- reference4
	                 l_je_source_name,                      -- reference6
	                 NULL, -- reference10
	                 l_tax_lines.invoice_id,                  -- reference21
	                 l_tax_lines.tax_dist_id,              -- reference22
	                 NULL,
	                 l_chart_of_accounts_id,
	                 l_tax_lines.inv_currency_code,
	                 l_tax_lines.item_ccid,
	                 null );
	            --------------------------------------------------------------------
	            -- credit entry for tax ccid for positive tax amount
	            --------------------------------------------------------------------
	             Gl_Interface_Insert(
			  'NEW',
			  l_secondary_set_of_books_id,
			  sysdate,
			  l_tax_lines.INV_CURRENCY_CODE,
			  sysdate,
			  to_number(fnd_profile.value('USER_ID')),
			  'A',
			  l_user_je_category_name,
			  l_user_je_source_name,
			  NULL,
			  abs(l_tax_lines.tax_amount),
			  NULL,
			  abs(l_tax_lines.tax_amount),
			  sysdate,
			  l_je_category_name,                   -- reference1
			  NULL,                     -- reference4
			  l_je_source_name,                -- reference6
			  NULL, -- reference10
			  l_tax_lines.invoice_id,                    -- reference21
			  l_tax_lines.tax_dist_id,              -- reference22
			  NULL,
			  l_chart_of_accounts_id,
			  l_tax_lines.inv_currency_code,
			  l_tax_lines.tax_ccid,
			  null );

		--Start(2) bug 2119400 vgadde 23-NOV-2001

		ELSIF ( l_tax_lines.tax_amount < 0 ) THEN
		    -----------------------------------------------------------------
                    -- Debit entry for tax ccid for negative tax amount
		    -----------------------------------------------------------------
                     Gl_interface_insert(
                         'NEW',
                         l_secondary_set_of_books_id,
                         sysdate,
                         l_tax_lines.INV_CURRENCY_CODE,
                         sysdate,
                         to_number(fnd_profile.value('USER_ID')),
                         'A',
                         l_user_je_category_name,
                         l_user_je_source_name,
                         abs(l_tax_lines.tax_amount),
                         NULL,
                         abs(l_tax_lines.tax_amount),
                         NULL,
                         sysdate,
                         l_je_category_name,                   -- reference1
                         NULL,                                  -- reference4
                         l_je_source_name,                      -- reference6
                         NULL, -- reference10
                         l_tax_lines.invoice_id,                  -- reference21
                         l_tax_lines.tax_dist_id,              -- reference22
                         NULL,
                         l_chart_of_accounts_id,
                         l_tax_lines.inv_currency_code,
                         l_tax_lines.tax_ccid,
                         null );
                    --------------------------------------------------------------------
                    -- credit entry for item ccid for negative amount
                    --------------------------------------------------------------------
                     Gl_Interface_Insert(
                          'NEW',
                          l_secondary_set_of_books_id,
                          sysdate,
                          l_tax_lines.INV_CURRENCY_CODE,
                          sysdate,
                          to_number(fnd_profile.value('USER_ID')),
                          'A',
                          l_user_je_category_name,
                          l_user_je_source_name,
                          NULL,
                          abs(l_tax_lines.tax_amount),
                          NULL,
                          abs(l_tax_lines.tax_amount),
                          sysdate,
                          l_je_category_name,                   -- reference1
                          NULL,                     -- reference4
                          l_je_source_name,                -- reference6
                          NULL, -- reference10
                          l_tax_lines.invoice_id,                    -- reference21
                          l_tax_lines.tax_dist_id,              -- reference22
                          NULL,
                          l_chart_of_accounts_id,
                          l_tax_lines.inv_currency_code,
                          l_tax_lines.item_ccid,
                          null );
		END IF;

		-- End(2) bug 2119400 vgadde 23-NOV-2001

           End loop;
           WriteLog( '>> IGI_RECOVERABLE_LINES records transferred to GL Interface');

             l_report_request_id := fnd_request.submit_request
    	('IGI',
    	'IGIPRECL',
    	null,
    	null,
    	false,
    	p_gl_from_period,
        p_gl_to_period,
	l_request_id);
     /*   ' ' , ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
        ' ', ' ', ' ', ' ', ' ', ' ', ' ',' ', ' ', ' ',
        ' ', ' ', ' ', ' ', ' ', ' ', ' ',' ', ' ', ' ',
        ' ', ' ', ' ', ' ', ' ', ' ', ' ',' ', ' ', ' ',
        ' ', ' ', ' ', ' ', ' ', ' ', ' ',' ', ' ', ' ',
        ' ', ' ', ' ', ' ', ' ', ' ', ' ',' ', ' ', ' ',
        ' ', ' ', ' ', ' ', ' ', ' ', ' ',' ', ' ', ' ',
        ' ', ' ', ' ', ' ', ' ', ' ', ' ',' ', ' ', ' ',
        ' ', ' ', ' ', ' ', ' ', ' ', ' ',' ', ' ', ' ',
        ' ',' ',' ', ' ',' ',' ',' ',' ' );*/



           WriteLog( '>> report request '||l_report_request_id);
            Init_Gl_Interface(
	         l_int_control,
	         l_secondary_set_of_books_id);
	    Insert_Control_Rec(l_int_control);
	      ----------------------------------------------------
	      -- 'Submitting Journal Import Program';
	      ----------------------------------------------------
	      WriteLog( '>> Submitting GL Import routine ');
	      if l_processed then -- records found in gl_interface
	                WriteLog( '>> Adjustment records transferred to GL Interface');
	      l_import_request_id := Fnd_Request.Submit_Request(
	                                 'SQLGL'
	                                ,'GLLEZL'
	                                ,NULL
	                                ,NULL
	                                ,FALSE
	                                ,l_int_control.interface_run_id
	                                ,l_secondary_set_of_books_id
	                                ,'N'
	                                ,NULL
	                                ,NULL
	                                ,'N'
                            ,'N');
                errbuf := 'Submitted import request '||l_request_id;
              	retcode := 0;
              	commit;
           else
              errbuf := 'No records found to process No records inserted into GL INTERFACE';
              retcode := 0;
              rollback;
          end if;

          --------------------------------------------------------------------
	   -- update all the rows after inserting to gl_interface table
           -- so that the lines are not consider when run next time
           --------------------------------------------------------------------
	   if l_import_request_id = 0 then
	    update IGI_RECOVERABLE_LINES
            set je_created_flag = 'Y'
            where request_id =FND_GLOBAL.CONC_REQUEST_ID ;
            WriteLog( '>> IGI_RECOVERABLE_LINES updated ');
           end if;

     end;

Procedure Init_Gl_Interface(
    p_int_control     IN OUT NOCOPY glcontrol,
    p_set_of_books_id IN     gl_sets_of_books.set_of_books_id%type) IS
  l_debug_loc             varchar2(30) := 'Init_Gl_Interface';
  l_curr_calling_sequence varchar2(2000);
  l_debug_info            varchar2(100);
Begin
  --------------------------------------------------------------------
  -- 'Initializing GL Interface control variables';
  --------------------------------------------------------------------
  Select gl_journal_import_s.Nextval,
    p_set_of_books_id,
    NULL,
    'S',
    'Payables'
  Into
    p_int_control.interface_run_id,
    p_int_control.set_of_books_id,
    p_int_control.group_id,
    p_int_control.status,
    p_int_control.je_source_name
  From sys.dual ;
Exception
  When Others Then
   Null;
End Init_Gl_Interface;
PROCEDURE Insert_Control_Rec(
   p_int_control in glcontrol) IS
  l_debug_loc             varchar2(30) := 'Insert_Control_Rec';
  l_curr_calling_sequence varchar2(2000);
  l_debug_info            varchar2(100);
BEGIN
  --------------------------------------------------------------------
  --l_debug_info := 'Inserting into gl_interface_control';
  --------------------------------------------------------------------
  Insert Into gl_interface_control(
    je_source_name,
    status,
    interface_run_id,
    group_id,
    set_of_books_id)
  Values(
    p_int_control.je_source_name,
    p_int_control.status,
    p_int_control.interface_run_id,
    p_int_control.group_id,
    p_int_control.set_of_books_id);
Exception
  When Others Then
    Null;
End Insert_Control_Rec;

Procedure Gl_Interface_Insert(
    p_status                   IN gl_interface.status%type,
    p_set_of_books_id          IN gl_interface.set_of_books_id%type,
    p_accounting_date          IN gl_interface.accounting_date%type,
    p_currency_code            IN gl_interface.currency_code%type,
    p_date_created             IN gl_interface.date_created%type,
    p_created_by               IN gl_interface.created_by%type,
    p_actual_flag              IN gl_interface.actual_flag%type,
    p_user_je_category_name    IN gl_interface.user_je_category_name%type,
    p_user_je_source_name      IN gl_interface.user_je_source_name%type,
    p_entered_dr               IN gl_interface.entered_dr%type,
    p_entered_cr               IN gl_interface.entered_cr%type,
    p_accounted_dr             IN gl_interface.accounted_dr%type,
    p_accounted_cr             IN gl_interface.accounted_cr%type,
    p_transaction_date         IN gl_interface.transaction_date%type,
    p_reference1               IN gl_interface.reference1%type,
    p_reference4               IN gl_interface.reference4%type,
    p_reference6               IN gl_interface.reference6%type,
    p_reference10              IN gl_interface.reference10%type,
    p_reference21              IN gl_interface.reference21%type,
    p_reference22              IN gl_interface.reference22%type,
    p_period_name              IN gl_interface.period_name%type,
    p_chart_of_accounts_id     IN gl_interface.chart_of_accounts_id%type,
    p_functional_currency_code IN gl_interface.functional_currency_code%type,
    p_code_combination_id      IN gl_interface.code_combination_id%type,
    p_group_id                 IN gl_interface.group_id%type) IS
  l_debug_loc             varchar2(30) := 'GL_interface';
  l_curr_calling_sequence varchar2(2000);
  l_debug_info            varchar2(100);
Begin
  ----------------------------------------------------------------------
  l_curr_calling_sequence := 'IGI_ITR_GL_INTERFACE_PKG.' || l_debug_loc;
  l_debug_info := 'Inserting record into gl_interface';
  ----------------------------------------------------------------------
  Insert Into gl_interface(
      status,
      set_of_books_id,
      accounting_date,
      currency_code,
      date_created,
      created_by,
      actual_flag,
      user_je_category_name,
      user_je_source_name,
      entered_dr,
      entered_cr,
      accounted_dr,
      accounted_cr,
      transaction_date,
      reference1,
      reference4,
      reference6,
      reference10,
      reference21,
      reference22,
      period_name,
      chart_of_accounts_id,
      functional_currency_code,
      code_combination_id,
      group_id)
  Values(
      p_status,
      p_set_of_books_id,
      p_accounting_date,
      p_currency_code,
      p_date_created,
      p_created_by,
      p_actual_flag,
      p_user_je_category_name,
      p_user_je_source_name,
      p_entered_dr,
      p_entered_cr,
      p_accounted_dr,
      p_accounted_cr,
      p_transaction_date,
      p_reference1,
      p_reference4 ,
      p_reference6,
      p_reference10,
      p_reference21,
      p_reference22,
      p_period_name,
      p_chart_of_accounts_id,
      p_currency_code,
      p_code_combination_id,
      p_group_id );
Exception
  When Others Then
    writelog ( '>>>' || sqlerrm(sqlcode) || '<<<<<');
    Null;
End Gl_Interface_Insert;
END IGIPREC;

/
