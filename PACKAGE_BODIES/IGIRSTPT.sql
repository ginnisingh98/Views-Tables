--------------------------------------------------------
--  DDL for Package Body IGIRSTPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIRSTPT" AS
-- $Header: igistpdb.pls 120.17.12010000.2 2008/08/04 13:08:55 sasukuma ship $
l_message                      varchar2(240)   := NULL;
l_debug                        varchar2(5)     := NULL;
l_variable                     varchar2(80)    := NULL;
l_value                        varchar2(2000)  := NULL;
-- Bug 1058426
--l_org_id                        number          := fnd_profile.value('ORG_ID');     --shsaxena for bug 2964361
p_receivables_batch_source 	varchar2(80) := fnd_profile.value('IGI_STP_RECEIVABLES_BATCH');

p_payables_batch_source 	varchar2(80) := fnd_profile.value('IGI_STP_PAYABLES_SOURCE');

p_interface_context 		varchar2(80) := fnd_profile.value('IGI_STP_INTERFACE_CONTEXT');

-- End of Bug 1058426
--following variables added for bug 3199481: fnd logging changes: sdixit
   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;





-- --------------------------------------------------------------------------
--
-- Create_Ra_Interface
--
-- --------------------------------------------------------------------------

PROCEDURE Create_Ra_Interface (p_net_batch_id       in        number,
                               p_set_of_books_id    in        number,
                               p_org_id             in        number,
                               p_user_id            in        number,
                               p_login_id           in        number,
                               p_sysdate            in        date,
                               p_currency_code      in        varchar2)
IS

 -- Only Lines are managed --
 l_line_type                     varchar2(20)   := 'LINE';
 l_term_id                       number := fnd_profile.value('IGI_STP_AR_TERMS');

 l_uom_code                      varchar2(25) := fnd_profile.value('IGI_STP_UOM');



 -- Accounts combinations fro receivable and revenue --
 l_revenue_cc_id                 number;
 l_receivable_cc_id              number;

 l_standing_charge_count         number := 0;

 l_batch_source_name             VARCHAR2(50);
 l_batch_source_id               number;

 l_doc_sequence_name             varchar2(30);
 l_doc_sequence_number           number := 0;


 CURSOR get_ar_packages  IS
 SELECT pck.package_id,
        net.cust_trx_type_id,
        pck.rec_or_liab_ccid,
        pck.technical_ccid,
        pck.stp_id,
        pck.site_id,
        rsu.cust_acct_site_id,
        pck.amount,
        pck.description,
        pck.trx_number,
        pck.trx_type_class,
        pck.doc_category_code,
        pck.related_trx_number,
        pck.accounting_date,
	pck.currency_code,
	c.batch_id,
        pck.exchange_rate,
        pck.exchange_rate_type,
        pck.exchange_date
 FROM igi_stp_packages_all pck,
      igi_stp_control c,
      HZ_CUST_SITE_USES  rsu,
      igi_stp_net_type_alloc_all net
 WHERE c.control_id = p_net_batch_id
 AND pck.batch_id = c.batch_id
 AND pck.application ='AR'
 AND rsu.site_use_id = pck.site_id
 AND net.netting_trx_type_id = pck.netting_trx_type_id
 AND net.trx_type_class = pck.trx_type_class
 AND net.application = pck.application
 and pck.org_id = p_org_id
 and pck.org_id = net.org_id;

     BEGIN





     --l_uom_code := 'Ea';
    --  l_term_id :=4;

     --p_receivables_batch_source := 'BR Automatic Numbering';
     --p_payables_batch_source := 'INVOICE GATEWAY';
     --p_interface_context := 'STP NETTING';
     --
     -- insert a new Invoice line
     --

     l_message := 'Insert a new AR document';
     --fnd_file.put_line(fnd_file.log , l_message);

     -- Batch source id selection --
      SELECT batch_source_id,
		name
      INTO l_batch_source_id,
		l_batch_source_name
      FROM  ra_batch_sources_all
      WHERE name = p_receivables_batch_source
      and org_id = p_org_id;


      IF l_debug = 'TRUE'
            THEN

         l_variable := 'l_batch_source_id';
         l_value    := to_char(l_batch_source_id);
         l_message := 'Searching Batch source id : '||to_char(l_batch_source_id);
         fnd_file.put_line(fnd_file.log , l_message);
      END IF;


      -- Term identifier --
/*      select  fpov.profile_option_value
      into   l_term_id
      from fnd_profile_option_values fpov,
           fnd_profile_options fpo
      where fpo.profile_option_id = fpov.profile_option_id
      and profile_option_name = 'IGI_STP_AR_TERMS'; */
      --fnd_file.put_line(fnd_file.log , 'l_term_id'||l_term_id);
      IF l_debug = 'TRUE'
      THEN
         l_variable := 'l_term_id';
         l_value    := to_char(l_term_id);
         l_message := 'Searching Term identifier : '||to_char(l_term_id);
         fnd_file.put_line(fnd_file.log , l_message);
      END IF;



/*      select  fpov.profile_option_value
      into  l_uom_code
      from fnd_profile_option_values fpov,
           fnd_profile_options fpo
      where fpo.profile_option_id = fpov.profile_option_id
      and profile_option_name = 'IGI_STP_UOM'; */
      IF l_debug = 'TRUE'
      THEN
         l_variable := 'l_uom_code';
         l_value    := l_uom_code;
         l_message := 'Searching Term identifier : '||l_uom_code;
         fnd_file.put_line(fnd_file.log , l_message);
      END IF;



     FOR ar_rec in get_ar_packages LOOP

      -- Line number --

      l_standing_charge_count := l_standing_charge_count + 1;
         IF l_debug = 'TRUE'
         THEN
             l_message := to_char(l_standing_charge_count)||'- Creating AR document : '||ar_rec.trx_number;
             fnd_file.put_line(fnd_file.log , l_message);
             l_variable := 'l_standing_charge_count';
             l_value    := to_char(l_standing_charge_count);
         END IF;

      l_receivable_cc_id := ar_rec.rec_or_liab_ccid;
      l_revenue_cc_id := ar_rec.technical_ccid;

      IF l_debug = 'TRUE'
      THEN
         l_variable := 'l_receivable_cc_id';
         l_value    := to_char(l_receivable_cc_id);
         l_message := 'Receivable code combination id : '||to_char(l_receivable_cc_id);
         fnd_file.put_line(fnd_file.log , l_message);
         l_variable := 'l_revenue_cc_id';
         l_value    := to_char(l_revenue_cc_id);
         l_message := 'Revenue code combination id : '||to_char(l_revenue_cc_id);
         fnd_file.put_line(fnd_file.log , l_message);
      END IF;


      INSERT INTO ra_interface_lines_ALL( amount
                                    , batch_source_name       -- Mandatory
                                    , comments
                                    , description             -- Mandatory
                                    , currency_code           -- Mandatory
                                    , gl_date
                                    , conversion_date
                                    , conversion_rate
                                    , conversion_type         -- Mandatory
                                    , cust_trx_type_id
                                    , interface_line_attribute1
                                    , interface_line_attribute2
                                    , interface_line_attribute3
                                    , interface_line_attribute4
                                    , interface_line_attribute5
                                    , interface_line_attribute6
                                    , interface_line_attribute7
                                    , interface_line_context
                                    , link_to_line_context
                                    , line_number
                                    , line_type               -- Mandatory
                                    , orig_system_bill_customer_id
                                    , orig_system_bill_address_id
                                    , set_of_books_id         -- Mandatory
                                --  , document_number
                                    , trx_number
                                    , uom_code
                                    , created_by
                                    , creation_date
                                    , last_updated_by
                                    , last_update_date
                                    , last_update_login
                                    , term_id
                                    ,ORG_ID)
        VALUES ( round(ar_rec.amount,2)
               , l_batch_source_name
               , l_batch_source_name||' '||ar_rec.trx_number
               , ar_rec.description
               , nvl(ar_rec.currency_code,p_currency_code)
               , ar_rec.accounting_date
--               , p_sysdate
--               , 1
--               , 'User'
               , nvl(ar_rec.exchange_date,sysdate)
               , nvl(ar_rec.exchange_rate,1)
               , nvl(ar_rec.exchange_rate_type,'User')
               , ar_rec.cust_trx_type_id
               , ar_rec.stp_id
               , ar_rec.site_id
               , to_char(ar_rec.batch_id)
               , ar_rec.package_id
               , ar_rec.trx_number
               , ar_rec.trx_type_class
               , ar_rec.related_trx_number
	       , p_interface_context
	       , p_interface_context
               , l_standing_charge_count
               , l_line_type
               , ar_rec.stp_id
               , ar_rec.cust_acct_site_id
               , p_set_of_books_id
         --    , l_doc_sequence_number
               , ar_rec.trx_number
               , l_uom_code
               , p_user_id
               , p_sysdate
               , p_user_id
               , p_sysdate
               , p_login_id
               , decode(ar_rec.trx_type_class,'CM','',l_term_id)
               ,P_ORG_ID
               );

       --
       -- insert a new distribution line
       --
       IF l_receivable_cc_id IS NOT NULL
       THEN

          l_message := 'Inserting receivable distribution for '||ar_rec.trx_number;
          --fnd_file.put_line(fnd_file.log , l_message);
          INSERT INTO ra_interface_distributions_ALL(  account_class    -- Mandatory
                                            ,  interface_line_context
                                            ,  interface_line_attribute1
                                            ,  interface_line_attribute2
                                            ,  interface_line_attribute3
                                            ,  interface_line_attribute4
                                            ,  interface_line_attribute5
                                            ,  interface_line_attribute6
                                            ,  interface_line_attribute7
                                            ,  percent
                                            ,  code_combination_id
                                            ,  created_by
                                            ,  creation_date
                                            ,  last_updated_by
                                            ,  last_update_date
                                            ,  last_update_login
                                            ,ORG_ID
                                            )
         VALUES ( 'REC'
               , p_interface_context
               , ar_rec.stp_id
               , ar_rec.site_id
               , to_char(ar_rec.batch_id)
               , ar_rec.package_id
               , ar_rec.trx_number
               , ar_rec.trx_type_class
               , ar_rec.related_trx_number
               , 100
               , l_receivable_cc_id
               , p_user_id
               , p_sysdate
               , p_user_id
               , p_sysdate
               , p_login_id
               , p_org_id
                );

       END IF;
       IF l_revenue_cc_id IS NOT NULL
       THEN
          l_message := 'Inserting revenue distribution for '||ar_rec.trx_number;
          --fnd_file.put_line(fnd_file.log , l_message);

           INSERT INTO ra_interface_distributions_ALL(  account_class      -- Mandatory
                                                ,  interface_line_context
                                                ,  interface_line_attribute1
                                                ,  interface_line_attribute2
                                                ,  interface_line_attribute3
                                                ,  interface_line_attribute4
                                                ,  interface_line_attribute5
                                                ,  interface_line_attribute6
                                                ,  interface_line_attribute7
                                                ,  percent
                                                ,  code_combination_id
                                                ,  created_by
                                                ,  creation_date
                                                ,  last_updated_by
                                                ,  last_update_date
                                                ,  last_update_login
                                               ,  org_id
                                                )
          VALUES ( 'REV'
                 , p_interface_context
                 , ar_rec.stp_id
                 , ar_rec.site_id
                 , to_char(ar_rec.batch_id)
                 , ar_rec.package_id
                 , ar_rec.trx_number
                 , ar_rec.trx_type_class
                 , ar_rec.related_trx_number
		 , 100
                 , l_revenue_cc_id
                 , p_user_id
                 , p_sysdate
                 , p_user_id
                 , p_sysdate
                 , p_login_id
                 , p_org_id
                 );
       END IF;
       END LOOP;
       COMMIT;

   EXCEPTION
       WHEN NO_DATA_FOUND
                THEN
                l_message := substr(sqlerrm,1,120)||' : '||'No data found for receivable interface for '||l_value;
                --fnd_file.put_line(fnd_file.log , l_message);
	   	     UPDATE igi_stp_batches
                     SET batch_status = 'ARFAILED'
                     WHERE batch_id in
                        (select batch_id
                         from igi_stp_control
                         where control_id = p_net_batch_id);
              commit;
      --bug 3199481 fnd logging changes: sdixit

           IF ( l_excep_level >= l_debug_level ) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_excep_level,'igi.pls.IGIRSTPT.Create_Ra_Interface.msg1',TRUE);
           END IF;
              raise_application_error(-20000, 'Procedure Create_Ra_Interface failed '||SQLERRM);
       WHEN OTHERS
                THEN
                l_message := substr(sqlerrm,1,120)||' : '||l_message;
                --fnd_file.put_line(fnd_file.log , l_message);

	   	     UPDATE igi_stp_batches
                     SET batch_status = 'ARFAILED'
                     WHERE batch_id in
                        (select batch_id
                         from igi_stp_control
                         where control_id = p_net_batch_id);

              commit;
         --bug 3199481 fnd logging changes: sdixit
         --standard way to handle when-others as per FND logging guidelines
         --not setting seeded message as hardcoded message is being passed

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.pls.IGIRSTPT.Create_Ra_Interface.msg2',TRUE);
           END IF;
              raise_application_error(-20000, 'Procedure Create_Ra_Interface failed '||SQLERRM);

   END Create_Ra_Interface;

-- --------------------------------------------------------------------------
--
-- Create_Ap_Interface
--
-- --------------------------------------------------------------------------

  PROCEDURE Create_Ap_Interface( p_net_batch_id       in        number,
                                 p_set_of_books_id    in        number,
                                 p_org_id             in        number,
                                 p_user_id            in        number,
                                 p_login_id           in        number,
                                 p_sysdate            in        date,
                                 p_currency_code      in        varchar2)
                               IS

 l_invoice_id                    number;
 l_ap_source                     varchar2(25);
 l_term_id                       number := fnd_profile.value('IGI_STP_AP_TERMS');

--l_term_id                       number ;
 l_pay_group			 varchar2(25);

   CURSOR get_ap_packages IS
   SELECT pck.package_id,
          pck.rec_or_liab_ccid,
          pck.technical_ccid,
          pck.stp_id,
          pck.site_id,
          pck.amount,
          pck.description,
          pck.trx_number,
          pck.trx_type_class,
          type.cust_trx_type_id invoice_type_lookup_code,
          pck.accounting_date,
          pck.doc_category_code,
	  pck.currency_code,
          pck.exchange_rate,
          pck.exchange_rate_type,
          pck.exchange_date
   FROM igi_stp_packages_all pck,
	igi_stp_control c,
        igi_stp_net_type_alloc_all type
   WHERE c.control_id = p_net_batch_id
   AND pck.batch_id = c.batch_id
   AND pck.application = 'AP'
   AND type.netting_trx_type_id = pck.netting_trx_type_id
   AND type.trx_type_class = pck.trx_type_class
   AND type.application = 'SQLAP'
   and pck.org_id = p_org_id
   and pck.org_id = type.org_id;


  BEGIN



    l_pay_group := fnd_profile.value('IGI_STP_PAYGROUP');

    --l_pay_group := 'Standard';


    IF l_pay_group is null
    THEN

	l_pay_group := 'Standard';

    END IF;
    --p_payables_batch_source := 'INVOICE GATEWAY';
         --l_uom_code := 'Ea';
      --l_term_id := 4;

    select lookup_code
    into l_ap_source
--    from IGI_AP_PO_LOOKUP_CODES_V
    from AP_LOOKUP_CODES
    where lookup_type = 'SOURCE'
    and lookup_code = p_payables_batch_source;



          IF l_debug = 'TRUE'
          THEN
            l_variable := 'l_ap_source';
            l_value    := l_ap_source;
            l_message := 'Checking existance of an AP source : '||l_ap_source;
            fnd_file.put_line(fnd_file.log , l_message);
          END IF;


/*    select  fpov.profile_option_value
    into  l_term_id
    from fnd_profile_option_values fpov,
         fnd_profile_options fpo
    where fpo.profile_option_id = fpov.profile_option_id
    and profile_option_name = 'IGI_STP_AP_TERMS'; */
          IF l_debug = 'TRUE'
          THEN
            l_variable := 'l_term_id';
            l_value    := to_char(l_term_id);
            l_message := 'Searching term_id through a profile option : '||l_value;
            fnd_file.put_line(fnd_file.log , l_message);
          END IF;


    FOR ap_rec in get_ap_packages LOOP

      select ap_invoices_s.nextval
      into l_invoice_id
      from dual;
          IF l_debug = 'TRUE'
          THEN
            l_variable := 'l_invoice_id';
            l_value    := to_char(l_invoice_id);
            l_message := 'AP document number is '||ap_rec.trx_number||' and document id is: '||l_value;
            fnd_file.put_line(fnd_file.log , l_message);
          END IF;


      l_message := 'Inserting line for '||ap_rec.trx_number;
      --fnd_file.put_line(fnd_file.log , l_message);

      insert into ap_invoices_interface
      (ACCTS_PAY_CODE_COMBINATION_ID,
       CREATED_BY,
       CREATION_DATE,
       DESCRIPTION,
       DOC_CATEGORY_CODE,
       GL_DATE,
       INVOICE_AMOUNT,
       INVOICE_CURRENCY_CODE,
       INVOICE_DATE,
       INVOICE_ID,
       INVOICE_NUM,
       INVOICE_TYPE_LOOKUP_CODE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       ORG_ID,
       SOURCE,
       STATUS,
       TERMS_ID,
       VENDOR_ID,
       VENDOR_SITE_ID,
       PAY_GROUP_LOOKUP_CODE,
       EXCHANGE_RATE,
       EXCHANGE_RATE_TYPE,
       EXCHANGE_DATE,
       INVOICE_RECEIVED_DATE)                    -- bug6847252
    values
       (ap_rec.rec_or_liab_ccid,        	 -- ACCTS_PAY_CODE_COMBINATION_ID
        p_user_id,		           	 -- CREATED_BY
        p_sysdate,	                	 -- CREATION_DATE
        '',					 -- DESCRIPTION
        ap_rec.doc_category_code,       	 -- DOC_CATEGORY_CODE
        p_sysdate,		        	 -- GL_DATE
        round(ap_rec.amount,2), 		 -- INVOICE_AMOUNT
        nvl(ap_rec.currency_code,
	    p_currency_code),  	      		 -- INVOICE_CURRENCY_CODE
        p_sysdate,		       		 -- INVOICE_DATE
        l_invoice_id, 			         -- INVOICE_ID
        ap_rec.trx_number, 		         -- INVOICE_NUM
        ap_rec.invoice_type_lookup_code,         -- INVOICE_TYPE_LOOKUP_CODE
        p_user_id,			         -- LAST_UPDATED_BY
        p_sysdate,		                 -- LAST_UPDATE_DATE
        p_user_id,			         -- LAST_UPDATE_LOGIN
        p_org_id,			         -- ORG_ID
        l_ap_source,                             -- SOURCE
        '',			                 -- STATUS
        l_term_id,			         -- TERMS_ID
        ap_rec.stp_id,                          -- VENDOR_ID
        ap_rec.site_id,                         -- VENDOR_SITE_ID
 	l_pay_group,
        ap_rec.exchange_rate,
        ap_rec.exchange_rate_type,
        ap_rec.exchange_date,
        p_sysdate);                            -- bug6847252

    l_message := 'Inserting distribution for '||ap_rec.trx_number;
    --fnd_file.put_line(fnd_file.log , l_message);

     -- Line number --
    insert into ap_invoice_lines_interface
    (ACCOUNTING_DATE,
     AMOUNT,
     CREATED_BY,
     CREATION_DATE,
     DESCRIPTION,
     DIST_CODE_COMBINATION_ID,
     INVOICE_ID,
     INVOICE_LINE_ID,
     ITEM_DESCRIPTION,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     LINE_NUMBER,
     LINE_TYPE_LOOKUP_CODE,
     ORG_ID)
    values
    (p_sysdate,    		    -- ACCOUNTING_DATE
     round(ap_rec.amount,2),		    -- AMOUNT
     p_user_id,		            -- CREATED_BY
     p_sysdate,		            -- CREATION_DATE
     '',  		            -- DESCRIPTION
     ap_rec.technical_ccid,         -- DIST_CODE_COMBINATION_ID
     l_invoice_id,		    -- INVOICE_ID
     ap_invoice_lines_interface_s.nextval,
				    -- INVOICE_LINE_ID
     ap_rec.description,            -- ITEM_DESCRIPTION
     p_user_id,		            -- LAST_UPDATED_BY
     p_sysdate,  		    -- LAST_UPDATE_DATE
     p_login_id,		    -- LAST_UPDATE_LOGIN
     1,			            -- LINE_NUMBER
     'ITEM',			    -- LINE_TYPE_LOOKUP_CODE
     p_org_id	                    -- ORG_ID
);
    END LOOP;

  EXCEPTION
            WHEN NO_DATA_FOUND
                THEN l_message := substr(sqlerrm,1,120)||'No data found for AP Interfaces';
                     --fnd_file.put_line(fnd_file.log , l_message);
                     UPDATE igi_stp_batches
                     SET batch_status = 'APFAILED'
                     WHERE batch_id in
			(select batch_id
			 from igi_stp_control
			 where control_id = p_net_batch_id);
                     commit;

         --bug 3199481 fnd logging changes: sdixit
         --not setting seeded message as hardcoded message is being passed

           IF ( l_excep_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_excep_level,'igi.pls.igistpdb.IGIRSTPT.Create_Ap_interface.msg1',TRUE);
           END IF;
              raise_application_error(-20000, 'Procedure Create_AP_Interface failed '||SQLERRM);
            WHEN OTHERS
                THEN l_message := substr(sqlerrm,1,120)
                             ||l_message;
                     --fnd_file.put_line(fnd_file.log , l_message);

                     UPDATE igi_stp_batches
                     SET batch_status = 'APFAILED'
                     WHERE batch_id in
			(select batch_id
			 from igi_stp_control
			 where control_id = p_net_batch_id);

                     commit;

         --bug 3199481 fnd logging changes: sdixit
         --not setting seeded message as hardcoded message is being passed

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpdb.IGIRSTPT.Create_Ap_Interface.msg2',TRUE);
           END IF;
              raise_application_error(-20000, 'Procedure Create_AP_Interface failed '||SQLERRM);

 END Create_Ap_Interface;


-- --------------------------------------------------------------------------
--
-- Populate_Interfaces
--
-- --------------------------------------------------------------------------
PROCEDURE Populate_Interfaces (p_net_batch_id  in number,p_org_id in number
                               )  IS


p_sysdate                       date;
--p_org_id NUMBER;
p_set_of_books_id NUMBER;
p_ledger_name varchar2(50);
p_user_id NUMBER;
p_login_id NUMBER;
p_currency_code VARCHAR2(15);




l_flag                          varchar2(1) := 'N';

BEGIN


  p_sysdate := trunc(sysdate);
 /* p_org_id := fnd_profile.value('ORG_ID');
  p_set_of_books_id := fnd_profile.value('SET_OF_BOOKS_ID');
  p_user_id := fnd_profile.value('USER_ID');
  p_login_id := fnd_profile.value('LOGIN_ID'); */





  mo_utils.get_ledger_info(p_org_id,p_set_of_books_id,p_ledger_name);
  p_user_id := fnd_profile.value('USER_ID');
  p_login_id := fnd_profile.value('LOGIN_ID');



      IF l_debug = 'TRUE'
      THEN
         l_message := 'The profile options are : org_id '||to_char(p_org_id)||
                      ' , set_of_books_id '||to_char(p_set_of_books_id)||
                      ' , user_id '||to_char(p_user_id)||
                      ' , login_id '||to_char(p_login_id)||
                      ' , sysdate '||to_char(p_sysdate,'DD-MON-YYYY');
         fnd_file.put_line(fnd_file.log , l_message);
         l_variable := 'p_org_id';
         l_value    := to_char(p_org_id);
      END IF;

  l_flag := 'Y';
  select currency_code
  into p_currency_code
  from gl_ledgers_public_v
  where ledger_id = p_set_of_books_id;

  l_flag := 'N';
      IF l_debug = 'TRUE'
      THEN
         l_message := 'The profile currency_code is : '||p_currency_code;
         fnd_file.put_line(fnd_file.log , l_message);
         l_variable := 'p_currency_code';
         l_value    := p_currency_code;
      END IF;


    --------------------
    -- AP Application --
    --------------------
    --fnd_file.put_line(fnd_file.log , '** AP importation **');

    Create_Ap_Interface(p_net_batch_id,
                        p_set_of_books_id,
                        p_org_id,
                        p_user_id,
                        p_login_id,
                        p_sysdate,
                        p_currency_code);
     --fnd_file.put_line(fnd_file.log , ' ');

   --------------------
   -- AR Application --
   --------------------

    --fnd_file.put_line(fnd_file.log , '** AR importation **');

    Create_Ra_Interface(p_net_batch_id,
                        p_set_of_books_id,
                        p_org_id,
                        p_user_id,
                        p_login_id,
                        p_sysdate,
                        p_currency_code);
  EXCEPTION
            WHEN NO_DATA_FOUND THEN
               if l_flag = 'Y' then
                  UPDATE igi_stp_batches
                     SET batch_status = 'APFAILED'
                   WHERE batch_id in (select batch_id
	                              from igi_stp_control
	                              where control_id = p_net_batch_id);
                  commit;
         --bug 3199481 fnd logging changes: sdixit
         --standard way to handle when-others as per FND logging guidelines
         --not setting seeded message as hardcoded message is being passed
         --FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
         --retcode := 2;
         --errbuf :=  Fnd_message.get;

           IF ( l_excep_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_excep_level,'igi.plsql.igistpdb.IGIRSTPT.Populate_Interface.msg1',TRUE);
           END IF;
                  raise_application_error(-20000, 'Procedure Populate_Interfaces failed '||SQLERRM);
               else
         --bug 3199481 fnd logging changes: sdixit
         --standard way to handle when-others as per FND logging guidelines
         --not setting seeded message as hardcoded message is being passed
         --FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
         --retcode := 2;
         --errbuf :=  Fnd_message.get;

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpdb.IGIRSTPT.Populate_Interface.msg2',TRUE);
           END IF;
                  raise;
               end if;
            WHEN OTHERS THEN
               if l_flag = 'Y' then
                  UPDATE igi_stp_batches
                     SET batch_status = 'APFAILED'
                   WHERE batch_id in (select batch_id
	                              from igi_stp_control
	                              where control_id = p_net_batch_id);
                  commit;
         --bug 3199481 fnd logging changes: sdixit
         --standard way to handle when-others as per FND logging guidelines
         --not setting seeded message as hardcoded message is being passed
         --FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
         --retcode := 2;
         --errbuf :=  Fnd_message.get;

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpdb.IGIRSTPT.Populate_Interfaces.msg3',TRUE);
           END IF;
                  raise_application_error(-20000, 'Procedure Populate_Interfaces failed '||SQLERRM);
               else
                  raise;
      --bug 3199481 fnd logging changes: sdixit
      --standard way to handle when-others as per FND logging guidelines

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpdb.IGIRSTPT.Populate_Interfaces.msg4',TRUE);
           END IF;
               end if;

END Populate_Interfaces;


-- --------------------------------------------------------------------------
--
-- Initiate_Interfaces
--
-- --------------------------------------------------------------------------
PROCEDURE Initiate_Interfaces (p_net_batch_id  in number,p_org_id number)  IS


   --shsaxena for bug 2713715
   CURSOR Cur_trx_type
   IS
      SELECT netting_trx_type_id
      FROM   igi_stp_batches_all
      WHERE  batch_id in
                     (select batch_id
                      from igi_stp_control
                      where control_id =p_net_batch_id)
      and org_id = p_org_id;
   l_trx_type_id                igi_stp_batches.netting_trx_type_id%type;
   --shsaxena for bug 2713715


p_set_of_books_id               number(15);
p_ledger_name varchar2(50);
--p_org_id                        number;
p_user_id                       number;
p_login_id                      number;
p_sysdate                       date;
p_currency_code                 varchar2(15);
l_chart_of_accounts_id          number(15);

l_ap_source                     varchar2(25);

p_ar_import_request_id          number;
p_ap_import_request_id          number;
l_ar_wait_for_request           boolean;
l_ap_wait_for_request           boolean;
l_ar_get_request_status         boolean;
l_ap_get_request_status         boolean;
l_ap_phase                      varchar2(30);
l_ar_phase                      varchar2(30);
l_ap_status                     varchar2(30);
l_ar_status                     varchar2(30);
l_ap_dev_phase                  varchar2(30);
l_ar_dev_phase                  varchar2(30);
l_ap_dev_status                 varchar2(30);
l_ar_dev_status                 varchar2(240);
l_ap_message                    varchar2(240);
l_ar_message                    varchar2(240);

l_batch_source_name             VARCHAR2(50);
l_interface_context		varchar2(80);
l_payables_source_name          varchar2(80);
l_batch_source_id               number;
l_pay_group			varchar2(25);
l_flag                          varchar2(1) := 'P';

BEGIN
l_batch_source_name := fnd_profile.value('IGI_STP_RECEIVABLES_BATCH');
--l_batch_source_name := 'BR Automatic Numbering';
l_payables_source_name :=fnd_profile.value('IGI_STP_PAYABLES_SOURCE');
--l_payables_source_name := 'INVOICE GATEWAY';
l_interface_context    :=fnd_profile.value('IGI_STP_INTERFACE_CONTEXT');
--l_interface_context := 'STP NETTING';
l_pay_group := fnd_profile.value('IGI_STP_PAYGROUP');
--l_pay_group := 'Standard';

IF l_pay_group is null
    THEN

        l_pay_group := 'Standard';

END IF;

  --p_org_id := fnd_profile.value('ORG_ID');
     IF l_debug = 'TRUE'
     THEN
        l_message := 'ORG_ID : '||to_char(p_org_id);
        fnd_file.put_line(fnd_file.log , l_message);
        l_variable := 'p_org_id';
        l_value    := to_char(p_org_id);
     END IF;

  --p_set_of_books_id := fnd_profile.value('GL_SET_OF_BKS_ID');

  mo_utils.get_ledger_info(p_org_id,p_set_of_books_id,p_ledger_name);
     IF l_debug = 'TRUE'
     THEN
        l_message := 'GL_SET_OF_BKS_ID : '||to_char(p_set_of_books_id);
        fnd_file.put_line(fnd_file.log , l_message);
        l_variable := 'p_set_of_books_id';
        l_value    := to_char(p_set_of_books_id);
     END IF;

  select chart_of_accounts_id
  into l_chart_of_accounts_id
  from gl_ledgers_public_v
  where ledger_id = p_set_of_books_id;
     IF l_debug = 'TRUE'
     THEN
        l_message := 'CHART_OF_ACCOUNTS_ID : '||to_char(l_chart_of_accounts_id);
        fnd_file.put_line(fnd_file.log , l_message);
        l_variable := 'l_chart_of_accounts_id';
        l_value    := to_char(l_chart_of_accounts_id);
     END IF;

  p_user_id := fnd_profile.value('USER_ID');
     IF l_debug = 'TRUE'
     THEN
        l_message := 'USER_ID : '||to_char(p_user_id);
        fnd_file.put_line(fnd_file.log , l_message);
        l_variable := 'p_user_id';
        l_value    := to_char(p_user_id);
     END IF;

  p_login_id := fnd_profile.value('LOGIN_ID');
     IF l_debug = 'TRUE'
     THEN
        l_message := 'LOGIN_ID : '||to_char(p_login_id);
        fnd_file.put_line(fnd_file.log , l_message);
        l_variable := 'p_login_id';
        l_value    := to_char(p_login_id);
     END IF;

  p_sysdate := sysdate;

  select currency_code
  into p_currency_code
  from gl_ledgers_public_v
  where ledger_id = p_set_of_books_id;
     IF l_debug = 'TRUE'
     THEN
        l_message := 'CURRENCY_CODE : '||p_currency_code;
        fnd_file.put_line(fnd_file.log , l_message);
        l_variable := 'p_currency_code';
        l_value    := p_currency_code;
     END IF;


    --------------------
    -- AP Application --
    --------------------

  --fnd_file.put_line(fnd_file.log , '** AP importation **');
  --fnd_file.put_line(fnd_file.log , l_message);

  select lookup_code
  into l_ap_source
--  from IGI_AP_PO_LOOKUP_CODES_V
  from AP_LOOKUP_CODES
  where lookup_type = 'SOURCE'
  and lookup_code = p_payables_batch_source;
     IF l_debug = 'TRUE'
     THEN
        l_message := 'AP source : '||l_ap_source;
        fnd_file.put_line(fnd_file.log , l_message);
        l_variable := 'l_ap_source';
        l_value    := l_ap_source;
     END IF;


  update ap_expense_report_headers
  set vouchno = 0
  where vouchno in
	(select batch_id
	 from 	igi_stp_control
	 where	control_id
		= p_net_batch_id);

  --shsaxena for bug 2713715
  OPEN  Cur_trx_type;
  FETCH Cur_trx_type into l_trx_type_id;
  CLOSE Cur_trx_type;
  IF l_trx_type_id IN (3,4,5,6)
  THEN
  --shsaxena for bug 2713715

  fnd_file.put_line(fnd_file.log , 'AP request submitted');
  p_ap_import_request_id := fnd_request.submit_request
  ('SQLAP',
  'APXIIMPT',
   NULL,
   NULL,
   FALSE,
   p_org_id,                               --ORG_ID
   l_ap_source,                            -- Netting Source --
   '',                                     -- Group id : batch name --
   '',                                     -- Invoice batch name --
   '',                                     -- No hold --
   '',                                     -- Hold reason --
   to_char(p_sysdate,'YYYY/MM/DD HH24:MI:SS'),  -- GL date --
   'N',                                    -- No purge --
   'N',                                    -- Trace switch --
   'N',                                    -- Debug switch --
   'N',	                                   -- Summary flag --
   1000,                                   -- Commit batch size --
   p_user_id,                              -- User id --
   p_login_id);                            -- Login id --

   commit;
    --fnd_file.put_line(fnd_file.log , 'AP import request id is ...'||p_ap_import_request_id);
    IF p_ap_import_request_id = 0
    THEN
        ROLLBACK;
        --fnd_file.put_line(fnd_file.log , 'Submission failed');

        UPDATE igi_stp_batches
        SET batch_status = 'APFAILED'
        WHERE batch_id in
		(select batch_id
		 from	igi_stp_control
		 where	control_id
			= p_net_batch_id);
        COMMIT;

         --bug 3199481 fnd logging changes: sdixit
         --standard way to handle when-others as per FND logging guidelines
         --not setting seeded message as hardcoded message is being passed
         --FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
         --retcode := 2;
         --errbuf :=  Fnd_message.get;

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpdb.IGIRSTPT.Interface_Batches',TRUE);
           END IF;
        raise_application_error(-20003, 'Invoice Import failed for the batch :'||l_batch_source_name);

    ELSE
          l_ap_wait_for_request :=
          fnd_concurrent.wait_for_request (p_ap_import_request_id,
                                           60,
                                           0,
                                           l_ap_phase,
                                           l_ap_status,
                                           l_ap_dev_phase,
                                           l_ap_dev_status,
                                           l_ap_message);

                  IF l_debug = 'TRUE'
                  THEN
                       l_message := 'Wait for AP request with phase '||l_ap_phase||', status '||l_ap_status||', dev_phase '||l_ap_dev_phase||', dev_status '||l_ap_dev_status||', message '||l_ap_message;
                       fnd_file.put_line(fnd_file.log , l_message);
                  END IF;

          l_ap_get_request_status :=
          fnd_concurrent.get_request_status (p_ap_import_request_id,
                                            'SQLAP',
-- Bug 1335318
--                                          'APXXTR',
                                            'APXIIMPT',
--
                                            l_ap_phase,
                                            l_ap_status,
                                            l_ap_dev_phase,
                                            l_ap_dev_status,
                                            l_ap_message);

                  IF l_debug = 'TRUE'
                  THEN
                       l_message := 'Get_request_status with phase '||l_ap_phase||', status '||l_ap_status||', dev_phase '||l_ap_dev_phase||', dev_status '||l_ap_dev_status||', message '||l_ap_message;
                       fnd_file.put_line(fnd_file.log , l_message);
                  END IF;


-- Bug 1335318

        /* commented the following code for 2713715 by shsaxena
        -- if l_ap_dev_phase = 'COMPLETE'
        --         then
        --         if l_ap_dev_status = 'NORMAL'
        --         then
        --
        --           UPDATE igi_stp_batches
        --           SET batch_status = 'COMPLETE'
        --           WHERE batch_id in
        --              (select batch_id
        --               from   igi_stp_control
        --               where  control_id = p_net_batch_id);
        --
        --           commit;
        --        --fnd_file.put_line(fnd_file.log , 'Submission succeded '||to_char(p_ap_import_request_id));
        --      end if;
        --  end if;
        -- commented the following code for 2713715 by shsaxena */

     END IF;
     --fnd_file.put_line(fnd_file.log , ' ');

-- Submit AP Approval

--mo_global.set_policy_context('S',p_org_id);

--fnd_request.set_org_id(mo_global.get_current_org_id);

p_ap_import_request_id := fnd_request.submit_request
  ('SQLAP',
  'APPRVL',
   NULL,
   NULL,
   FALSE,
   P_ORG_ID,                         --ORG_ID
   'All',                            -- MATCH OPTION --
   '',                               -- Group id : batch name --
   '',                               -- START_INVOICE_DATE --
   '',                               -- End invoice date --
   '',                               -- VENDOR_ID --
   l_pay_group,                      -- PAY GROUP --
   null,                          --INVOICE ID--
   null,                           --ENTERED BY USER ID--
   p_set_of_books_id,               --LEDGER ID--
   'N',
   1000);

   commit;
   l_flag := 'R';

  END IF;  -- shsaxena for bug 2713715


    --------------------
    -- AR Application --
    --------------------

    --fnd_file.put_line(fnd_file.log , '** AR importation **');
    --fnd_file.put_line(fnd_file.log , l_message);


 IF l_trx_type_id IN (4,6) -- shsaxena for bug 2713715
 THEN

     SELECT batch_source_id
     INTO l_batch_source_id
     FROM  ra_batch_sources_all
     WHERE name = l_batch_source_name
     and org_id = p_org_id;

    IF l_debug = 'TRUE'
    THEN
       l_message := 'batch source name : '||l_batch_source_name;
       fnd_file.put_line(fnd_file.log , l_message);
       l_variable := 'l_batch_source_id';
       l_value    := to_char(l_batch_source_id);
    END IF;

     p_ar_import_request_id := fnd_request.submit_request
	 ( 'AR'
	 , 'RAXMTR'                           -- AutoInvoice Master Program
	 , NULL
	 , NULL
	 , FALSE
	 , 1                                  -- 10 Number of Instances
	 ,P_ORG_ID                            --ORG_ID
	 , l_batch_source_id                  -- 20 Batch Source Id
	 , l_batch_source_name                -- 30 Batch Source Name
	 , p_sysdate                          -- 40 Default Date
	 , NULL                               -- 50 Transaction Flexfield
	 , NULL                               -- 60 Transaction Type
	 , NULL                               -- 70 (Low) Bill To Customer Numbe
	 , NULL                               -- 80 (High) Bill To Customer Numb
	 , NULL                               -- 90 (Low) Bill To Customer Name
	 , NULL                               --100 (High) Bill To Customer Name
	 , NULL                               --110 (Low) GL Date
	 , NULL                               --120 (High) GL Date
	 , NULL                               --130 (Low) Ship Date
	 , NULL                               --140 (High) Ship Date
	 , NULL                               --150 (Low) Transaction Number
	 , NULL                               --160 (High) Transaction  Number
	 , NULL                               --170 (Low) Sales Order Number
	 , NULL                               --180 (High) Sales Order Number
	 , NULL                               --190 (Low) Invoice Date
	 , NULL                               --200 (High) Invoice Date
	 , NULL                               --210 (Low) Ship To Customer Numbe
	 , NULL                               --220 (High) Ship To Customer Numb
	 , NULL                               --230 (Low) Ship To Customer Name
	 , NULL                               --240 (High) Ship To Customer Name
	 , 'Y'                                --250 Base Due Date on Trx Date
	 , NULL                               --260 Due Date Adjustment Days
--	, l_org_id                            --270 Ord_id   --shsaxena bug 2964361
             );

         commit;
     --fnd_file.put_line(fnd_file.log , 'AR import request id is ...'||p_ar_import_request_id);
          IF p_ar_import_request_id = 0
          THEN
              ROLLBACK;

		     UPDATE igi_stp_batches
                     SET batch_status = 'ARFAILED'
                     WHERE batch_id in
                        (select batch_id
                         from igi_stp_control
                         where control_id = p_net_batch_id);

              COMMIT;

         --bug 3199481 fnd logging changes: sdixit
         --standard way to handle when-others as per FND logging guidelines
         --not setting seeded message as hardcoded message is being passed
         --FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
         --retcode := 2;
         --errbuf :=  Fnd_message.get;

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpdb.IGIRSTPT.Initiate_Interfaces',TRUE);
           END IF;
              raise_application_error(-20002, ' Auto Invoice not submitted  : batch source '||to_char(l_batch_source_id)||' is not found in RA_BATCH_SOURCES');
              raise_application_error(-20000, 'Procedure IGIRSTPN.INITIATE_INTERFACES failed '||SQLERRM);

              --fnd_file.put_line(fnd_file.log , 'Submission failed');
          ELSE
               l_ar_wait_for_request :=
               fnd_concurrent.wait_for_request(p_ar_import_request_id,
                                              60,
                                              0,
                                              l_ar_phase,
                                              l_ar_status,
                                              l_ar_dev_phase,
                                              l_ar_dev_status,
                                              l_ar_message);


                  IF l_debug = 'TRUE'
                  THEN
                       l_message := 'Wait for AR request with phase '||l_ar_phase||', status '||l_ar_status||', dev_phase '||l_ar_dev_phase||', dev_status '||l_ar_dev_status||', message '||l_ar_message;
                       fnd_file.put_line(fnd_file.log , l_message);
                  END IF;
              l_ar_get_request_status :=
              fnd_concurrent.get_request_status(p_ar_import_request_id,
                                               'SQLAP',
-- Bug 1335318
--                                               'APXXTR',
	                                       'RAXMTR',
--
                                               l_ar_phase,
                                               l_ar_status,
                                               l_ar_dev_phase,
                                               l_ar_dev_status,
                                               l_ar_message);
                  IF l_debug = 'TRUE'
                  THEN
                       l_message := 'Get_request_status with phase '||l_ar_phase||', status'||l_ar_status||', dev_phase '||l_ar_dev_phase||', dev_status '||l_ar_dev_status||', message '||l_ar_message;
                       fnd_file.put_line(fnd_file.log , l_message);
                  END IF;


            /* commented by shsaxena for bug 2713715
            --  if l_ar_dev_phase = 'COMPLETE'
            --  then
            --     if l_ar_dev_status = 'NORMAL'
            --     then
            --
            --       UPDATE igi_stp_batches
            --         SET batch_status = 'COMPLETE'
            --         WHERE batch_id in
            --            (select batch_id
            --             from igi_stp_control
            --             where control_id = p_net_batch_id);
            --
            --       COMMIT;
            --       --fnd_file.put_line(fnd_file.log , 'Submission succeded '||to_char(p_ar_import_request_id));
            --     end if;
            --  end if;
            -- commented by shsaxena for bug 2713715
            */

          END IF;
   END IF;  -- shsaxena for bug 2713715

   /* Added by shsaxena for Bug 2713715 START */

  /* IF l_trx_type_id IN (1,2)
   THEN
      IF  (l_ar_dev_phase = 'COMPLETE') AND (l_ar_dev_status = 'NORMAL')
      AND (l_ap_dev_phase = 'COMPLETE') AND (l_ap_dev_status = 'NORMAL')
      THEN
           UPDATE igi_stp_batches
           SET batch_status = 'COMPLETE'
           WHERE batch_id in
                 (select batch_id
                  from  igi_stp_control
                  where control_id = p_net_batch_id);

           commit;
           fnd_file.put_line (fnd_file.log , 'Submission succeded for AR --> '||to_char(p_ar_import_request_id));
           fnd_file.put_line (fnd_file.log , 'Submission succeded for AP --> '||to_char(p_ap_import_request_id));
      END IF; */

  IF l_trx_type_id IN (3,5,6)
  THEN
      IF (l_ap_dev_phase = 'COMPLETE') AND (l_ap_dev_status = 'NORMAL')
      THEN
           UPDATE igi_stp_batches
           SET batch_status = 'COMPLETE'
           WHERE batch_id in
                 (select batch_id
                  from   igi_stp_control
                  where   control_id = p_net_batch_id);

           COMMIT;
           fnd_file.put_line (fnd_file.log , 'Submission succeded for AP --> '||to_char(p_ap_import_request_id));
      END IF;

  ELSIF l_trx_type_id IN( 4,6)
  THEN
     IF ( l_ar_dev_phase = 'COMPLETE') AND (l_ar_dev_status = 'NORMAL')
     THEN
        UPDATE igi_stp_batches
        SET batch_status = 'COMPLETE'
        WHERE batch_id in
              (select batch_id
               from   igi_stp_control
               where  control_id = p_net_batch_id);

        COMMIT;
           fnd_file.put_line (fnd_file.log , 'Submission succeded for AR --> '||to_char(p_ar_import_request_id));
     END IF;

  END IF;
   /* Added by shsaxena for Bug 2713715 END */

   EXCEPTION
            WHEN NO_DATA_FOUND THEN
               if l_flag = 'P' then
                  UPDATE igi_stp_batches
                     SET batch_status = 'APFAILED'
                   WHERE batch_id in (select batch_id
	                              from igi_stp_control
	                              where control_id = p_net_batch_id);
                  commit;
         --bug 3199481 fnd logging changes: sdixit
         --standard way to handle when-others as per FND logging guidelines
         --not setting seeded message as hardcoded message is being passed
         --FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
         --retcode := 2;
         --errbuf :=  Fnd_message.get;

           IF ( l_excep_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_excep_level,'igi.plsql.igistpdb.IGIRSTPT.Initiate_Interfaces',TRUE);
           END IF;
                  raise_application_error(-20000, 'Procedure Initiate_Interfaces failed '||SQLERRM);
               elsif l_flag = 'R' then
                  UPDATE igi_stp_batches
                     SET batch_status = 'ARFAILED'
                   WHERE batch_id in (select batch_id
	                              from igi_stp_control
	                              where control_id = p_net_batch_id);
                  commit;
         --bug 3199481 fnd logging changes: sdixit
         --standard way to handle when-others as per FND logging guidelines
         --not setting seeded message as hardcoded message is being passed
         --FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
         --retcode := 2;
         --errbuf :=  Fnd_message.get;

           IF ( l_excep_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_excep_level,'igi.plsql.igistpdb.IGIRSTPT.Initiate_Interfaces',TRUE);
           END IF;
                  raise_application_error(-20000, 'Procedure Initiate_Interfaces failed '||SQLERRM);
               else
                  raise;
               end if;
            WHEN OTHERS THEN
               if l_flag = 'P' then
                  UPDATE igi_stp_batches
                     SET batch_status = 'APFAILED'
                   WHERE batch_id in (select batch_id
	                              from igi_stp_control
	                              where control_id = p_net_batch_id);
                  commit;
         --bug 3199481 fnd logging changes: sdixit
         --standard way to handle when-others as per FND logging guidelines
         --not setting seeded message as hardcoded message is being passed
         --FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
         --retcode := 2;
         --errbuf :=  Fnd_message.get;

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpdb.IGIRSTPT.Initiate_Interfaces',TRUE);
           END IF;
                  raise_application_error(-20000, 'Procedure Initiate_Interfaces failed '||SQLERRM);
               elsif l_flag = 'R' then
                  UPDATE igi_stp_batches
                     SET batch_status = 'ARFAILED'
                   WHERE batch_id in (select batch_id
	                              from igi_stp_control
	                              where control_id = p_net_batch_id);
                  commit;
         --bug 3199481 fnd logging changes: sdixit
         --standard way to handle when-others as per FND logging guidelines
         --not setting seeded message as hardcoded message is being passed
         --FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
         --retcode := 2;
         --errbuf :=  Fnd_message.get;

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpdb.IGIRSTPT.Initiate_Interfaces',TRUE);
           END IF;
                  raise_application_error(-20000, 'Procedure Initiate_Interfaces failed '||SQLERRM);
               else
         --bug 3199481 fnd logging changes: sdixit
         --standard way to handle when-others as per FND logging guidelines
         --not setting seeded message as hardcoded message is being passed
         --FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
         --retcode := 2;
         --errbuf :=  Fnd_message.get;

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpdb.IGIRSTPT.Initiate_Interfaces',TRUE);
           END IF;
                  raise;
               end if;

 END Initiate_Interfaces;


-- --------------------------------------------------------------------------
--
-- Submit_Batch
--
-- --------------------------------------------------------------------------
PROCEDURE Submit_Batch (errbuf out NOCOPY varchar2,
			retcode out NOCOPY varchar2,
			p_net_batch_id  in number,
			p_org_id in number)  IS
BEGIN

 fnd_profile.get('IGI_DEBUG',l_debug);

 l_message := '*** Open Interface for Netting called for batch '||p_net_batch_id||' ***';
 --fnd_file.put_line(fnd_file.log , l_message);
 --fnd_file.put_line(fnd_file.log , ' ');
 --fnd_file.put_line(fnd_file.log , ' ');

 l_message := '*** Feed AP/AR interface tables ***';
 --fnd_file.put_line(fnd_file.log , l_message);
 Populate_Interfaces(p_net_batch_id,p_org_id);
 --fnd_file.put_line(fnd_file.log , ' ');
 --fnd_file.put_line(fnd_file.log , ' ');

 l_message := '*** Execute AP/AR interfaces  ***';
 --fnd_file.put_line(fnd_file.log , l_message);
 Initiate_Interfaces(p_net_batch_id,p_org_id);

END Submit_Batch;


END IGIRSTPT;

/
