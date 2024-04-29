--------------------------------------------------------
--  DDL for Package Body AR_BPA_PRINT_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_PRINT_CONC" AS
/* $Header: ARBPPRIB.pls 120.26.12010000.4 2008/09/10 12:08:23 vsanka ship $ */

cr    		CONSTANT char(1) := '
';

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'Y');

FUNCTION build_from_clause RETURN VARCHAR2 IS
from_clause VARCHAR2(8096);
ignore_open_rec_flag varchar2(1) := NVL(FND_PROFILE.value('AR_BPA_IGNORE_OPEN_REC_FLAG'), 'N');

BEGIN

from_clause := '  FROM ' || cr ||
      '  ar_payment_schedules_all                ps,  ' || cr ||
      '  ra_customer_trx                         trx,  ' || cr ||
      '  ra_terms_tl                             t,  ' || cr ||
      '  ra_terms_b                              b,  ' || cr ||
      '  ra_cust_trx_types_all                   trx_type,    ' || cr ||
      '  hz_cust_accounts_all                    b_bill,  ' || cr ||
      '  hz_parties                              b_bill_party,  ' || cr ||
      '  hz_cust_acct_sites_all                  a_bill, ' || cr ||
      '  hz_party_sites                          a_bill_ps,' || cr ||
      '  hz_locations                            a_bill_loc, ' || cr ||
      '  hz_cust_site_uses_all                   u_bill ' || cr ||
      '  WHERE    ' || cr ||
      '  trx.cust_trx_type_id                    = trx_type.cust_trx_type_id ' || cr ||
      '  AND trx.customer_trx_id                 = ps.customer_trx_id';

      	IF(ignore_open_rec_flag = 'Y') THEN
          from_clause := from_clause || '(+)';
        END IF;

from_clause := from_clause || cr ||
      '  AND trx.org_id                          = trx_type.org_id  ' || cr ||
      '  AND trx.org_id                          = ps.org_id';

        IF(ignore_open_rec_flag = 'Y') THEN
          from_clause := from_clause || '(+)';
        END IF;

from_clause := from_clause || cr ||
      '  AND trx.printing_option                 = ' || '''' || 'PRI' || '''' || cr ||
      '  AND trx.bill_to_customer_id             = b_bill.cust_account_id   ' || cr ||
      '  ANd b_bill.party_id                     = b_bill_party.party_id ' || cr ||
      '  AND trx.bill_to_site_use_id             = u_bill.site_use_id ' || cr ||
      '  AND trx.org_id                          = u_bill.org_id ' || cr ||
      '  AND u_bill.cust_acct_site_id            = a_bill.cust_acct_site_id(+) ' || cr ||
      '  AND u_bill.org_id                       = a_bill.org_id(+) ' || cr ||
      '  AND a_bill.party_site_id                = a_bill_ps.party_site_id(+) ' || cr ||
      '  AND trx.term_id                         = b.term_id(+) ' || cr ||
      '  AND trx.term_id                         = t.term_id(+) ' || cr ||
      '  AND t.language(+)                       = userenv (' || '''' || 'LANG' || ''')' || cr ||
      '  AND b.billing_cycle_id is null ' || cr ||
      '  AND a_bill_loc.location_id(+)           = a_bill_ps.location_id ' ;

return from_clause;

END;

PROCEDURE check_child_request(
       p_request_id            IN OUT  NOCOPY  NUMBER
      ) IS

call_status     boolean;
rphase          varchar2(80);
rstatus         varchar2(80);
dphase          varchar2(30);
dstatus         varchar2(30);
message         varchar2(240);

BEGIN
    call_status := fnd_concurrent.get_request_status(
                        p_request_id,
                        '',
                        '',
                        rphase,
                        rstatus,
                        dphase,
                        dstatus,
                        message);

    fnd_file.put_line( fnd_file.output, arp_standard.fnd_message('AR_BPA_PRINT_CHILD_REQ',
                                                    'REQ_ID',
                                                    p_request_id,
                                                    'PHASE',
                                                    dphase,
                                                    'STATUS',
                                                    dstatus));

    IF ((dphase = 'COMPLETE') and (dstatus = 'NORMAL')) THEN
        fnd_file.put_line( fnd_file.log, 'child request id: ' || p_request_id || ' complete successfully');
    ELSE
        fnd_file.put_line( fnd_file.log, 'child request id: ' || p_request_id || ' did not complete successfully');
    END IF;

END;


FUNCTION submit_print_request(
       p_parent_request_id            IN     NUMBER,
       p_worker_id                    IN     NUMBER,
       p_order_by                     IN     VARCHAR2,
       p_template_id                  IN     NUMBER,
       p_stamp_flag					  IN     VARCHAR2,
       p_child_template_id            IN     NUMBER,
       p_locale                       IN     VARCHAR2,
       p_index_flag                   IN     VARCHAR2,
       p_nls_lang                     IN     VARCHAR2,
       p_nls_territory                IN     VARCHAR2,
       p_sub_request_flag             IN     BOOLEAN,
       p_description		      IN     VARCHAR2 DEFAULT NULL
      ) RETURN NUMBER IS

l_options_ok  BOOLEAN;
m_request_id  NUMBER;
number_of_copies	number;
printer		VARCHAR2(30);
print_style		VARCHAR2(30);
save_output_flag	VARCHAR2(30);
save_output_bool	BOOLEAN;
print_opt_populated BOOLEAN;

BEGIN

      l_options_ok := FND_REQUEST.SET_OPTIONS (
                      implicit      => 'NO'
                    , protected     => 'YES'
                    , language      => p_nls_lang
                    , territory     => p_nls_territory);
      IF (l_options_ok)
      THEN

        IF( FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS(p_parent_request_id,
      						number_of_copies,
      						print_style,
      						printer,
      						save_output_flag))THEN

          IF (save_output_flag = 'Y') THEN
            save_output_bool := TRUE;
          ELSE
            save_output_bool := FALSE;
          END IF;

          if (not FND_REQUEST.set_print_options(printer => printer,
                                        style => print_style,
                                        copies => number_of_copies,
                                        save_output => save_output_bool)) then
            print_opt_populated := false;
          else
            print_opt_populated := true;
          end if;

        End IF;

        m_request_id := FND_REQUEST.SUBMIT_REQUEST(
                  application   => 'AR'
                , program       => 'ARBPIPCP'
                , description   => p_description
                , start_time    => ''
                , sub_request   => p_sub_request_flag
                , argument1     => p_parent_request_id
                , argument2     => p_worker_id
                , argument3     => p_order_by
                , argument4     => p_template_id
                , argument5     => p_stamp_flag
                , argument6     => p_child_template_id
                , argument7     => 222
                , argument8     => p_locale
                , argument9     => p_index_flag
                , argument10    => chr(0)
                , argument11    => ''
                , argument12    => ''
                , argument13    => ''
                , argument14    => ''
                , argument15    => ''
                , argument16    => ''
                , argument17    => ''
                , argument18    => ''
                , argument19    => ''
                , argument20    => ''
                , argument21    => ''
                , argument22    => ''
                , argument23    => ''
                , argument24    => ''
                , argument25    => ''
                , argument26    => ''
                , argument27    => ''
                , argument28    => ''
                , argument29    => ''
                , argument30    => ''
                , argument31    => ''
                , argument32    => ''
                , argument33    => ''
                , argument34    => ''
                , argument35    => ''
                , argument36    => ''
                , argument37    => ''
                , argument38    => ''
                , argument39    => ''
                , argument40    => ''
                , argument41    => ''
                , argument42    => ''
                , argument43    => ''
                , argument44    => ''
                , argument45    => ''
                , argument46    => ''
                , argument47    => ''
                , argument48    => ''
                , argument49    => ''
                , argument50    => ''
                , argument51    => ''
                , argument52    => ''
                , argument53    => ''
                , argument54    => ''
                , argument55    => ''
                , argument56    => ''
                , argument57    => ''
                , argument58    => ''
                , argument59    => ''
                , argument61    => ''
                , argument62    => ''
                , argument63    => ''
                , argument64    => ''
                , argument65    => ''
                , argument66    => ''
                , argument67    => ''
                , argument68    => ''
                , argument69    => ''
                , argument70    => ''
                , argument71    => ''
                , argument72    => ''
                , argument73    => ''
                , argument74    => ''
                , argument75    => ''
                , argument76    => ''
                , argument77    => ''
                , argument78    => ''
                , argument79    => ''
                , argument80    => ''
                , argument81    => ''
                , argument82    => ''
                , argument83    => ''
                , argument84    => ''
                , argument85    => ''
                , argument86    => ''
                , argument87    => ''
                , argument88    => ''
                , argument89    => ''
                , argument90    => ''
                , argument91    => ''
                , argument92    => ''
                , argument93    => ''
                , argument94    => ''
                , argument95    => ''
                , argument96    => ''
                , argument97    => ''
                , argument98    => ''
                , argument99    => ''
                , argument100   => '');
   END IF;

   RETURN m_request_id;

END;

PROCEDURE build_where_clause(
        p_org_id  IN NUMBER DEFAULT NULL,
		p_choice  IN VARCHAR2,
		p_batch_id IN NUMBER DEFAULT NULL,
        p_cust_trx_class  IN VARCHAR2 DEFAULT NULL,
		p_trx_type_id IN NUMBER DEFAULT NULL,
		p_trx_number_low  IN VARCHAR2 DEFAULT NULL,
		p_trx_number_high IN VARCHAR2 DEFAULT NULL,
		p_print_date_low IN DATE DEFAULT NULL,
		p_print_date_high IN DATE DEFAULT NULL,
		p_customer_class_code IN VARCHAR2 DEFAULT NULL,
		p_customer_no_low  IN VARCHAR2 DEFAULT NULL,
		p_customer_no_high IN VARCHAR2 DEFAULT NULL,
		p_customer_name_low IN VARCHAR2 DEFAULT NULL,
		p_customer_name_high	IN VARCHAR2 DEFAULT NULL,
		p_installment_no IN NUMBER DEFAULT NULL,
		p_open_invoice_flag   IN VARCHAR2 DEFAULT NULL,
		p_invoice_list_string IN VARCHAR2 DEFAULT NULL,
		p_union_flag   IN VARCHAR2 DEFAULT NULL,
		where_clause   OUT NOCOPY VARCHAR2) IS

BEGIN


   /*------------------------------------------------------------------------+
   |   Build where clause depending on passed parameters.                    |
   |   Operating Unit        	     p_org_id                                |
   |   Transactions to Print 	     p_choice = NEW / ANY / OLD              |
   |   Customer Class                p_customer_class_code                   |
   |   (High) Bill TO Customer Name  p_customer_name_high                    |
   |   (Low) Bill TO Customer Name   p_customer_name_low                     |
   |   (High) Bill To Customer Numberp_customer_no_high                      |
   |   (Low) Bill To Customer Number p_customer_no_low                       |
   |   Transaction Class             p_cust_trx_class                        |
   |   Transaction Type              p_cust_trx_type_id                      |
   |   (High) Transaction Number     p_trx_number_high                       |
   |   (Low) Transaction Number      p_trx_number_low                        |
   |   Installment Number            p_installment_no                        |
   |   Open Invoices Only            p_open_invoice_flag                     |
   |   Batch                         p_batch_id                              |
   |   (High) Print Date             p_print_date_high                       |
   |   (Low) Print Date              p_print_date_low                        |
   |   Order By                      p_order_by                              |
   |   Invoice Trx Id List           p_invoice_list_string                   |
   --------------------------------------------------------------------------*/

   IF (p_choice = 'NEW' ) THEN
      where_clause :=where_clause || ' AND  nvl(trx.printing_pending, ' ||'''' || 'N' ||'''' ||' ) = ' || '''' || 'Y' ||'''' ||
                     ' AND  ps.terms_sequence_number > NVL(TRX.LAST_PRINTED_SEQUENCE_NUM,0) ' ;
   ELSIF (p_choice = 'OLD' ) THEN
       where_clause :=where_clause || ' AND NVL(trx.last_printed_sequence_num, 0) >= ps.terms_sequence_number '; --bug 6130518
   END IF;

   IF ( p_org_id is not null ) THEN
     where_clause :=where_clause || ' AND trx.org_id = :org_id ' ;
   END IF;

   IF ( p_customer_class_code is not null ) THEN
     where_clause :=where_clause || ' AND b_bill.customer_class_code = :customer_class_code ' ;
   END IF;

   IF ( p_customer_name_low is not null and p_customer_name_high is null )THEN
     where_clause :=where_clause || ' AND b_bill_party.party_name = :customer_name_low ';
   ELSIF ( (p_customer_name_high is not null) and (p_customer_name_low is null ) ) THEN
     where_clause :=where_clause || ' AND b_bill_party.party_name  = :customer_name_high ';
   ELSIF ( (p_customer_name_high is not null) and (p_customer_name_low is not null) )  THEN
     where_clause :=where_clause || ' AND b_bill_party.party_name >=  :customer_name_low ';
     where_clause :=where_clause || ' AND b_bill_party.party_name  <= :customer_name_high ';
   END IF;

   IF ( (p_customer_no_low is not null) and (p_customer_no_high is null) ) THEN
     where_clause :=where_clause || ' AND b_bill.account_number = :customer_no_low ' ;
   ELSIF ( (p_customer_no_high is not null) and (p_customer_no_low is  null) ) THEN
     where_clause :=where_clause || ' AND b_bill.account_number = :customer_no_high ';
   ELSIF ( (p_customer_no_high is not null) and (p_customer_no_low is not null) ) THEN
     where_clause :=where_clause || ' AND b_bill.account_number >= :customer_no_low ';
     where_clause :=where_clause || ' AND b_bill.account_number <= :customer_no_high ' ;
   END IF;

   IF ( p_cust_trx_class is not null ) THEN
      where_clause :=where_clause || ' AND trx_type.type = :cust_trx_class ';
   END IF;

   IF ( p_trx_type_id is not null ) THEN
      where_clause :=where_clause || ' AND trx_type.cust_trx_type_id = :trx_type_id ' ;
   END IF;

   IF ( (p_trx_number_low is not null) and (p_trx_number_high is null )) THEN
     where_clause :=where_clause || ' AND trx.trx_number = :trx_number_low ';
   ELSIF ( (p_trx_number_high is not null) and (p_trx_number_low is null) ) THEN
     where_clause :=where_clause || ' AND trx.trx_number = :trx_number_high ';
   ELSIF ( (p_trx_number_high is not null ) and (p_trx_number_low is not null) ) THEN
     where_clause :=where_clause || ' AND trx.trx_number >= :trx_number_low ';
     where_clause :=where_clause || ' AND trx.trx_number <= :trx_number_high ';
   END IF;

   IF ( (p_installment_no is not null) ) THEN
     where_clause :=where_clause || ' AND  ps.terms_sequence_number = :installment_no ' ;
   END IF;

   IF (  p_open_invoice_flag = 'Y' ) THEN
     where_clause :=where_clause || ' AND ps.AMOUNT_DUE_REMAINING <> 0 ' ;
   END IF;

   IF ( p_batch_id is not null ) THEN
      where_clause := where_clause || ' AND trx.batch_id = :batch_id ' ;
   END IF;

   IF ( p_invoice_list_string is not null ) THEN
      where_clause :=where_clause || ' AND trx.customer_trx_id in ( ' || p_invoice_list_string||' )';
   END IF;


   /**********************************************************************************
   Handle Print Lead Days IF date range is provided. IF the invoice you are printing
   has a payment term where Print Lead Days is 0, Receivables uses the transaction date
   to determine IF this transaction falls into the Start and END Date range you specIFy.
   IF the invoice you are printing has a payment term where Print Lead Days is greater
   than 0, Receivables uses the FORmula Due Date - Print Lead Days to determine IF this
   transaction is to be printed
   ************************************************************************************/

   IF ( (p_print_date_low is not null) or (p_print_date_low is not null) ) THEN
      IF ( p_union_flag = 'N' ) THEN
         where_clause := where_clause || ' AND nvl(b.printing_lead_days,0)  = 0 ' ;
         IF ( p_print_date_low is not null and p_print_date_high is not null ) THEN
 	      where_clause := where_clause || ' AND trx.TRX_DATE BETWEEN TO_DATE(:print_date_low, ';
            where_clause := where_clause || '''DD-MM-YYYY-HH24:MI:SS'')';
            where_clause := where_clause ||  '                   AND TO_DATE(:print_date_high, ';
            where_clause := where_clause || '''DD-MM-YYYY-HH24:MI:SS'')';
         ELSIF ( p_print_date_low is not null and  p_print_date_high is  null) THEN
 	      where_clause := where_clause ||  'AND trx.TRX_DATE >= TO_DATE(:print_date_low, ';
            where_clause := where_clause ||  '''DD-MM-YYYY-HH24:MI:SS'')';
         ELSIF ( p_print_date_high is not null and p_print_date_low is null ) THEN
            where_clause := where_clause ||  'AND trx.TRX_DATE <= TO_DATE(:print_date_high, ';
            where_clause := where_clause ||  '''DD-MM-YYYY-HH24:MI:SS'')';
         END IF;
      ELSE
         where_clause :=where_clause || ' AND b.printing_lead_days > 0 ' ;
         IF ( p_print_date_low is not null and p_print_date_high is not null ) THEN
            where_clause := where_clause ||  'AND ps.DUE_DATE BETWEEN TO_DATE(:print_date_low, ';
            where_clause := where_clause || '''DD-MM-YYYY-HH24:MI:SS'')';
            where_clause := where_clause || '                       + NVL (B.PRINTING_LEAD_DAYS, 0)';
            where_clause := where_clause || '                   AND TO_DATE(:print_date_high, ';
            where_clause := where_clause || '''DD-MM-YYYY-HH24:MI:SS'')';
            where_clause := where_clause || '                       + NVL (B.PRINTING_LEAD_DAYS, 0)';
        ELSIF ( p_print_date_low is not null and p_print_date_high is  null ) THEN
            where_clause := where_clause || 'AND ps.DUE_DATE >= TO_DATE(:print_date_low, ';
            where_clause := where_clause || '''DD-MM-YYYY-HH24:MI:SS'') + NVL (B.PRINTING_LEAD_DAYS, 0)';
         ELSIF ( p_print_date_high is not null and p_print_date_low is null ) THEN
            where_clause := where_clause || 'AND ps.DUE_DATE <= TO_DATE(:print_date_high, ';
            where_clause := where_clause || '''DD-MM-YYYY-HH24:MI:SS'') + NVL (B.PRINTING_LEAD_DAYS, 0)';
        END IF;
     END IF;
  END IF;


END BUILD_WHERE_CLAUSE;

PROCEDURE BIND_VARIABLES(
        p_org_id  IN NUMBER DEFAULT NULL,
		p_choice  IN VARCHAR2,
		p_batch_id IN NUMBER DEFAULT NULL,
        p_cust_trx_class  IN VARCHAR2 DEFAULT NULL,
		p_trx_type_id IN NUMBER DEFAULT NULL,
		p_trx_number_low  IN VARCHAR2 DEFAULT NULL,
		p_trx_number_high IN VARCHAR2 DEFAULT NULL,
		p_print_date_low IN DATE DEFAULT NULL,
		p_print_date_high IN DATE DEFAULT NULL,
		p_customer_class_code IN VARCHAR2 DEFAULT NULL,
		p_customer_no_low  IN VARCHAR2 DEFAULT NULL,
		p_customer_no_high IN VARCHAR2 DEFAULT NULL,
		p_customer_name_low IN VARCHAR2 DEFAULT NULL,
		p_customer_name_high	IN VARCHAR2 DEFAULT NULL,
		p_installment_no IN NUMBER DEFAULT NULL,
		p_open_invoice_flag   IN VARCHAR2 DEFAULT NULL,
		p_invoice_list_string IN VARCHAR2 DEFAULT NULL,
		p_union_flag   IN VARCHAR2 DEFAULT NULL,
		cursor_name    IN INTEGER ) IS

BEGIN


   /*------------------------------------------------------------------------+
   |   Bind clause depending on passed parameters.                           |
   |   Operating Unit        	     p_org_id                                |
   |   Transactions to Print 	     p_choice = NEW / ANY / OLD              |
   |   Customer Class                p_customer_class_code                   |
   |   (High) Bill TO Customer Name  p_customer_name_high                    |
   |   (Low) Bill TO Customer Name   p_customer_name_low                     |
   |   (High) Bill To Customer Numberp_customer_no_high                      |
   |   (Low) Bill To Customer Number p_customer_no_low                       |
   |   Transaction Class             p_cust_trx_class                        |
   |   Transaction Type              p_cust_trx_type_id                      |
   |   (High) Transaction Number     p_trx_number_high                       |
   |   (Low) Transaction Number      p_trx_number_low                        |
   |   Installment Number            p_installment_no                        |
   |   Open Invoices Only            p_open_invoice_flag                     |
   |   Batch                         p_batch_id                              |
   |   (High) Print Date             p_print_date_high                       |
   |   (Low) Print Date              p_print_date_low                        |
   |   Order By                      p_order_by                              |
   |   Invoice Trx Id List           p_invoice_list_string                   |
   --------------------------------------------------------------------------*/


   IF ( p_customer_class_code is not null ) THEN
     dbms_sql.bind_variable( cursor_name, ':customer_class_code', p_customer_class_code) ;
   END IF;

   IF ( p_org_id is not null ) THEN
     dbms_sql.bind_variable( cursor_name, ':org_id', p_org_id) ;
   END IF;

   IF ( p_customer_name_low is not null and p_customer_name_high is null )THEN
     dbms_sql.bind_variable( cursor_name, ':customer_name_low', p_customer_name_low);
   ELSIF ( (p_customer_name_high is not null) and (p_customer_name_low is null ) ) THEN
     dbms_sql.bind_variable( cursor_name, ':customer_name_high', p_customer_name_high );
   ELSIF ( (p_customer_name_high is not null) and (p_customer_name_low is not null) )  THEN
     dbms_sql.bind_variable( cursor_name, ':customer_name_low',  p_customer_name_low);
     dbms_sql.bind_variable( cursor_name,':customer_name_high', p_customer_name_high);
   END IF;

   IF ( (p_customer_no_low is not null) and (p_customer_no_high is null) ) THEN
      dbms_sql.bind_variable( cursor_name, ':customer_no_low', p_customer_no_low ) ;
   ELSIF ( (p_customer_no_high is not null) and (p_customer_no_low is  null) ) THEN
      dbms_sql.bind_variable( cursor_name, ':customer_no_high', p_customer_no_high );
   ELSIF ( (p_customer_no_high is not null) and (p_customer_no_low is not null) ) THEN
      dbms_sql.bind_variable( cursor_name, ':customer_no_low', p_customer_no_low  ) ;
      dbms_sql.bind_variable( cursor_name, ':customer_no_high', p_customer_no_high ) ;
   END IF;

   IF ( p_cust_trx_class is not null ) THEN
      dbms_sql.bind_variable( cursor_name, ':cust_trx_class', p_cust_trx_class );
   END IF;

   IF ( p_trx_type_id is not null ) THEN
      dbms_sql.bind_variable( cursor_name, ':trx_type_id', p_trx_type_id ) ;
   END IF;

   IF ( (p_trx_number_low is not null) and (p_trx_number_high is null )) THEN
     dbms_sql.bind_variable( cursor_name, ':trx_number_low', p_trx_number_low);
   ELSIF ( (p_trx_number_high is not null) and (p_trx_number_low is null) ) THEN
     dbms_sql.bind_variable( cursor_name, ':trx_number_high', p_trx_number_high);
   ELSIF ( (p_trx_number_high is not null ) and (p_trx_number_low is not null) ) THEN
     dbms_sql.bind_variable( cursor_name, ':trx_number_low' , p_trx_number_low);
     dbms_sql.bind_variable( cursor_name, ':trx_number_high', p_trx_number_high);
   END IF;

   IF ( (p_installment_no is not null) ) THEN
     dbms_sql.bind_variable( cursor_name, ':installment_no', p_installment_no) ;
   END IF;


   IF ( p_batch_id is not null ) THEN
      dbms_sql.bind_variable( cursor_name, ':batch_id', p_batch_id ) ;
   END IF;


   /**********************************************************************************
   Handle Print Lead Days IF date range is provided. IF the invoice you are printing
   has a payment term where Print Lead Days is 0, Receivables uses the transaction date
   to determine IF this transaction falls into the Start and END Date range you specIFy.
   IF the invoice you are printing has a payment term where Print Lead Days is greater
   than 0, Receivables uses the FORmula Due Date - Print Lead Days to determine IF this
   transaction is to be printed
   ************************************************************************************/

   IF ( (p_print_date_low is not null) or (p_print_date_low is not null) ) THEN
      IF ( p_union_flag = 'N' ) THEN
         IF ( p_print_date_low is not null and p_print_date_high is not null ) THEN
            dbms_sql.bind_variable( cursor_name, ':print_date_low' ,
                                  TO_CHAR(p_print_date_low ,'DD-MM-YYYY-HH24:MI:SS'));
            dbms_sql.bind_variable( cursor_name, ':print_date_high' ,
                                  TO_CHAR(p_print_date_high ,'DD-MM-YYYY-HH24:MI:SS'));
         ELSIF ( p_print_date_low is not null and  p_print_date_high is  null) THEN
            dbms_sql.bind_variable( cursor_name, ':print_date_low' ,
                                  TO_CHAR(p_print_date_low ,'DD-MM-YYYY-HH24:MI:SS'));
         ELSIF ( p_print_date_high is not null and p_print_date_low is null ) THEN
            dbms_sql.bind_variable( cursor_name, ':print_date_high' ,
                                  TO_CHAR(p_print_date_high ,'DD-MM-YYYY-HH24:MI:SS'));
         END IF;
      ELSE
         IF ( p_print_date_low is not null and p_print_date_high is not null ) THEN
            dbms_sql.bind_variable( cursor_name, ':print_date_low' ,
                                  TO_CHAR(p_print_date_low ,'DD-MM-YYYY-HH24:MI:SS'));
            dbms_sql.bind_variable( cursor_name, ':print_date_high' ,
                                  TO_CHAR(p_print_date_high ,'DD-MM-YYYY-HH24:MI:SS'));
        ELSIF ( p_print_date_low is not null and p_print_date_high is  null ) THEN
            dbms_sql.bind_variable( cursor_name, ':print_date_low' ,
                                  TO_CHAR(p_print_date_low ,'DD-MM-YYYY-HH24:MI:SS'));
         ELSIF ( p_print_date_high is not null and p_print_date_low is null ) THEN
            dbms_sql.bind_variable( cursor_name, ':print_date_high' ,
                                  TO_CHAR(p_print_date_high ,'DD-MM-YYYY-HH24:MI:SS'));
        END IF;
     END IF;
  END IF;


END BIND_VARIABLES;


function PRINT_MLS_FUNCTION RETURN VARCHAR2 IS

-- variables used by build_where_clause
p_org_id              number         := NULL;
p_job_size            number         := NULL;
p_choice              varchar2(40)   := NULL;
p_order_by            varchar2(20)   := NULL;
p_batch_id            number   	 := NULL;
p_cust_trx_class      VARCHAR2(30)   := NULL;
p_trx_type_id         number         := NULL;
p_customer_class_code varchar2(40)	 := NULL;
p_customer_name_low   varchar2(360)	 := NULL;
p_customer_name_high  varchar2(360)	 := NULL;
p_customer_no_low     varchar2(30)	 := NULL;
p_customer_no_high    varchar2(30)	 := NULL;
p_trx_number_low      varchar2(20)	 := NULL;
p_trx_number_high     varchar2(20)	 := NULL;
p_installment_no      number		 := NULL;
p_print_date_low      date  		 := NULL;
p_print_date_high     date		 := NULL;
p_open_invoice_flag   varchar2(1)    := NULL;
p_invoice_list_string varchar2(2000) := NULL;


p_where1 		varchar2(8096);
p_where2 		varchar2(8096);
filter_exists   boolean := false;

--local variables
userenv_lang 	varchar2(4);
base_lang 		varchar2(4);
retval 		number;
parm_number 	number;
parm_name		varchar2(80);

sql_stmt_c		   number;
sql_stmt             varchar2(8096);
select_stmt          varchar2(8096);
lang_str 	    	   varchar2(240);

TYPE sql_stmt_rec_type IS RECORD
(language VARCHAR2(4));

sql_stmt_rec 		sql_stmt_rec_type ;
l_ignore                INTEGER;

BEGIN

   select  substr(userenv('LANG'),1,4)
   into    userenv_lang
   from    dual;

   select  language_code
   into    base_lang
   from    fnd_languages
   where   installed_flag = 'B';

   MO_global.init('AR');
   fnd_file.put_line( fnd_file.log, 'userenv_lang: ' || userenv_lang);
   fnd_file.put_line( fnd_file.log, 'base_lang: ' || base_lang);

   /* Read in Parameter Values supplied by user */
   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Operating Unit',parm_number);
   IF retval = -1 THEN
      p_org_id := NULL;
   ELSE
      p_org_id:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_org_id: ' || p_org_id);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Job Size',parm_number);
   IF retval = -1 THEN
      p_job_size:= NULL;
   ELSE
      p_job_size:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_job_size: ' || p_job_size);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Transactions to Print',parm_number);
   IF retval = -1 THEN
      p_choice:= NULL;
   ELSE
      p_choice:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_choice: ' || p_choice);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Order By',parm_number);
   IF retval = -1 THEN
      p_order_by:= NULL;
   ELSE
      p_order_by:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_order_by: ' || p_order_by);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Batch',parm_number);
   IF retval = -1 THEN
      p_BATCH_ID := NULL;
   ELSE
      p_BATCH_ID := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
	  filter_exists := true;
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_BATCH_ID: ' || p_BATCH_ID);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Transaction Class',parm_number);
   IF retval = -1 THEN
      p_cust_trx_class := NULL;
   ELSE
      p_cust_trx_class := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_cust_trx_class: ' || p_cust_trx_class);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Transaction Type',parm_number);
   IF retval = -1 THEN
      p_TRX_TYPE_ID := NULL;
   ELSE
      p_TRX_TYPE_ID := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_TRX_TYPE_ID: ' || p_TRX_TYPE_ID);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Customer Class',parm_number);
   IF retval = -1 THEN
      p_customer_class_code:= NULL;
   ELSE
      p_customer_class_code:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_customer_class_code: ' || p_customer_class_code);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('(From) Bill To Customer Name',parm_number);
   IF retval = -1 THEN
      p_customer_name_low:= NULL;
   ELSE
      p_customer_name_low:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_customer_name_low: ' || p_customer_name_low);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('(To) Bill To Customer Name',parm_number);
   IF retval = -1 THEN
      p_CUSTOMER_NAME_HIGH := NULL;
   ELSE
      p_CUSTOMER_NAME_HIGH := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_CUSTOMER_NAME_HIGH: ' || p_CUSTOMER_NAME_HIGH);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('(Low) Bill To Customer Number',parm_number);
   IF retval = -1 THEN
      p_customer_no_low:= NULL;
   ELSE
      p_customer_no_low:= FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_customer_no_low: ' || p_customer_no_low);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('(High) Bill To Customer Number',parm_number);
   IF retval = -1 THEN
      p_customer_no_high := NULL;
   ELSE
      p_customer_no_high := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_customer_no_high: ' || p_customer_no_high);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('(Low) Transaction Number',parm_number);
   IF retval = -1 THEN
      p_TRX_NUMBER_LOW := NULL;
   ELSE
      p_TRX_NUMBER_LOW := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_TRX_NUMBER_LOW: ' || p_TRX_NUMBER_LOW);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('(High) Transaction Number',parm_number);
   IF retval = -1 THEN
      p_TRX_NUMBER_HIGH := NULL;
   ELSE
      p_TRX_NUMBER_HIGH := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_TRX_NUMBER_HIGH: ' || p_TRX_NUMBER_HIGH);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Installment Number',parm_number);
   IF retval = -1 THEN
      p_INSTALLMENT_NO := NULL;
   ELSE
      p_INSTALLMENT_NO := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_INSTALLMENT_NO: ' || p_INSTALLMENT_NO);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('(Low) Print Date',parm_number);
   IF retval = -1 THEN
      p_PRINT_DATE_LOW := NULL;
   ELSE
      p_PRINT_DATE_LOW := fnd_date.canonical_to_date(FND_REQUEST_INFO.GET_PARAMETER(parm_number));
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_PRINT_DATE_LOW: ' || p_PRINT_DATE_LOW);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('(High) Print Date',parm_number);
   IF retval = -1 THEN
      p_PRINT_DATE_HIGH := NULL;
   ELSE
      p_PRINT_DATE_HIGH := fnd_date.canonical_to_date(FND_REQUEST_INFO.GET_PARAMETER(parm_number));
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_PRINT_DATE_HIGH: ' || p_PRINT_DATE_HIGH);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Open Invoices Only',parm_number);
   IF retval = -1 THEN
      p_OPEN_INVOICE_FLAG := NULL;
   ELSE
      p_OPEN_INVOICE_FLAG := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_OPEN_INVOICE_FLAG: ' || p_OPEN_INVOICE_FLAG);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Invoice Trx Id List',parm_number);
   IF retval = -1 THEN
      p_INVOICE_LIST_STRING := NULL;
   ELSE
      p_INVOICE_LIST_STRING := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   END IF;
   fnd_file.put_line( fnd_file.log, 'p_INVOICE_LIST_STRING: ' || p_INVOICE_LIST_STRING);


  select_stmt :=
      '  select distinct(nvl(rtrim(substr(a_bill.language,1,4)), ''' || base_lang || ''')) language ' || cr ||
         build_from_clause;

    AR_BPA_PRINT_CONC.Build_where_clause(
        p_org_id,
		p_choice ,
		p_batch_id ,
        p_cust_trx_class,
		p_trx_type_id ,
		p_trx_number_low  ,
		p_trx_number_high ,
		p_print_date_low  ,
		p_print_date_high ,
		p_customer_class_code ,
		p_customer_no_low     ,
		p_customer_no_high    ,
		p_customer_name_low  ,
		p_customer_name_high  ,
		p_installment_no      ,
		p_open_invoice_flag   ,
		p_invoice_list_string ,
		'N'          ,
		p_where1   ) ;

  sql_stmt := select_stmt || cr || p_where1;

  IF ( p_PRINT_DATE_LOW IS NOT NULL OR  p_PRINT_DATE_HIGH IS NOT NULL ) THEN
     AR_BPA_PRINT_CONC.Build_where_clause(
        p_org_id,
		p_choice ,
		p_batch_id ,
        p_cust_trx_class,
		p_trx_type_id ,
		p_trx_number_low  ,
		p_trx_number_high ,
		p_print_date_low  ,
		p_print_date_high ,
		p_customer_class_code ,
		p_customer_no_low     ,
		p_customer_no_high    ,
		p_customer_name_low  ,
		p_customer_name_high  ,
		p_installment_no      ,
		p_open_invoice_flag   ,
		p_invoice_list_string ,
		'Y'          ,
		p_where2  ) ;
     sql_stmt := sql_stmt || cr || ' UNION ' || cr || select_stmt || cr || p_where2 ;
  END IF;

  --fnd_file.put_line( fnd_file.log, 'The final sql: ' || sql_stmt);
  ------------------------------------------------
  -- Parse sql stmts
  ------------------------------------------------

  sql_stmt_c:= dbms_sql.open_cursor;

  dbms_sql.parse( sql_stmt_c, sql_stmt , dbms_sql.v7 );
  bind_variables(
            p_org_id,
            p_choice ,
	 		p_batch_id ,
		    p_cust_trx_class,
			p_trx_type_id ,
			p_trx_number_low  ,
			p_trx_number_high ,
			p_print_date_low  ,
			p_print_date_high ,
			p_customer_class_code ,
			p_customer_no_low     ,
			p_customer_no_high    ,
			p_customer_name_low  ,
			p_customer_name_high  ,
			p_installment_no      ,
			p_open_invoice_flag   ,
			p_invoice_list_string ,
			'N'          ,
                  sql_stmt_c );

  IF ( p_print_date_low IS NOT NULL OR  p_print_date_high IS NOT NULL ) THEN
     bind_variables(
            p_org_id,
            p_choice ,
	 		p_batch_id ,
		    p_cust_trx_class,
			p_trx_type_id ,
			p_trx_number_low  ,
			p_trx_number_high ,
			p_print_date_low  ,
			p_print_date_high ,
			p_customer_class_code ,
			p_customer_no_low     ,
			p_customer_no_high    ,
			p_customer_name_low  ,
			p_customer_name_high  ,
			p_installment_no      ,
			p_open_invoice_flag   ,
			p_invoice_list_string ,
			'Y'          ,
                  sql_stmt_c );
  END IF;


  dbms_sql.define_column( sql_stmt_c, 1, sql_stmt_rec.language, 4);


  l_ignore := dbms_sql.execute( sql_stmt_c);

  LOOP
    IF (dbms_sql.fetch_rows( sql_stmt_c) > 0)
    THEN

        ------------------------------------------------------
        -- Get column values
        ------------------------------------------------------
        dbms_sql.column_value( sql_stmt_c, 1, sql_stmt_rec.language );

        IF (lang_str is null) THEN
            lang_str := sql_stmt_rec.language;
        ELSE
            lang_str := lang_str || ',' ||  sql_stmt_rec.language;
        END IF;
    ELSE
        EXIT;
    END IF;
 END LOOP;

 IF lang_str IS NULL THEN
   fnd_file.put_line( fnd_file.log, 'No transactions matched the input parameters.' );
 ELSE
   fnd_file.put_line( fnd_file.log, 'lang_str: ' || lang_str);
 END IF;

RETURN lang_str;

EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line( fnd_file.log, sql_stmt);
	RAISE;

END PRINT_MLS_FUNCTION  ;


PROCEDURE PRINT_INVOICES(
       errbuf                         IN OUT NOCOPY VARCHAR2,
       retcode                        IN OUT NOCOPY VARCHAR2,
       p_org_id                       IN NUMBER,
       p_job_size                     IN NUMBER,
       p_choice                       IN VARCHAR2,
       p_order_by                     IN VARCHAR2,
       p_batch_id                     IN NUMBER,
       p_cust_trx_class               IN VARCHAR2,
       p_trx_type_id                  IN NUMBER,
       p_customer_class_code          IN VARCHAR2,
       p_customer_name_low            IN VARCHAR2,
       p_customer_name_high           IN VARCHAR2,
       p_customer_no_low              IN VARCHAR2,
       p_customer_no_high             IN VARCHAR2,
       p_trx_number_low               IN VARCHAR2,
       p_trx_number_high              IN VARCHAR2,
       p_installment_no               IN NUMBER,
       p_print_date_low_in            IN VARCHAR2,
       p_print_date_high_in           IN VARCHAR2,
       p_open_invoice_flag            IN VARCHAR2,
       p_invoice_list_string          IN VARCHAR2,
       p_template_id                  IN NUMBER,
       p_child_template_id            IN NUMBER,
       p_locale                       IN VARCHAR2,
       p_index_flag                   IN VARCHAR2
      ) IS
l_job_size      INTEGER := 500;
p_print_date_low      date       := NULL;
p_print_date_high     date		 := NULL;
p_where1 		varchar2(8096);
p_where2 		varchar2(8096);
filter_exists   boolean := false;

--local variables
base_lang 		varchar2(4);
userenv_lang 	varchar2(4);
retval 		number;
parm_number 	number;
parm_name		varchar2(80);

sql_stmt_c		   number;
sql_stmt             varchar2(8096);
insert_stmt          varchar2(240);
select_stmt          varchar2(8096);

inserted_row_counts  INTEGER;
row_counts_perworker number;
divided_worker_counts number := 1;

-- variable used for concurrent program
req_data varchar2(240);
l_request_id    number;     -- child request id
m_request_id    number;     -- parent request id

l_low_range  NUMBER := 1;
l_high_range NUMBER := 1;
l_worker_id  NUMBER := 1;

cnt_warnings INTEGER := 0;
cnt_errors   INTEGER := 0;
request_status BOOLEAN;
return_stat    VARCHAR2(2000);
l_fail_count	NUMBER := 0;

BEGIN

	 MO_global.init('AR');
   FND_FILE.PUT_LINE( FND_FILE.LOG, 'AR_BPA_PRINT_CONC.print_invoices(+)' );
   -- to check if the output directory exists

   -- read the variable request_data to check if it is reentering the program
   req_data := fnd_conc_global.request_data;
   m_request_id := fnd_global.conc_request_id;

   FND_FILE.PUT_LINE( FND_FILE.LOG, 'print_invoices: ' || 'req_data: '|| req_data );
   FND_FILE.PUT_LINE( FND_FILE.LOG, 'print_invoices: ' || 'm_request_id: '|| m_request_id );
   IF (req_data is null) THEN
       FND_FILE.PUT_LINE( FND_FILE.LOG, 'print_invoices: '
                     || 'Entering print master program at the first time');
       -- read the user env language
      select  substr(userenv('LANG'),1,4)
      into    userenv_lang
      from    dual;

      select  language_code
      into    base_lang
      from    fnd_languages
      where   installed_flag = 'B';

      FND_FILE.PUT_LINE( FND_FILE.LOG, 'userenv_lang: '|| userenv_lang );
      fnd_file.put_line( fnd_file.log, 'base_lang: ' || base_lang);

      if p_job_size > 0 then l_job_size := p_job_size; end if;
      p_print_date_high := fnd_date.canonical_to_date(p_print_date_high_in);
      p_print_date_low := fnd_date.canonical_to_date(p_print_date_low_in);
      -- print out the input parameters;
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_org_id: '|| p_org_id );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'l_job_size: '|| l_job_size );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_choice: '|| p_choice );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_order_by: '|| p_order_by );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_BATCH_ID: '|| p_BATCH_ID );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_cust_trx_class '|| p_cust_trx_class );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_TRX_TYPE_ID: '|| p_TRX_TYPE_ID );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_customer_class_code: '|| p_customer_class_code );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_customer_name_low: '|| p_customer_name_low );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_CUSTOMER_NAME_HIGH: '|| p_CUSTOMER_NAME_HIGH );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_customer_no_low: '|| p_customer_no_low );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_customer_no_high: '|| p_customer_no_high );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_TRX_NUMBER_LOW: '|| p_TRX_NUMBER_LOW );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_TRX_NUMBER_HIGH: '|| p_TRX_NUMBER_HIGH );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_INSTALLMENT_NO: '|| p_INSTALLMENT_NO );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_PRINT_DATE_LOW: '|| p_PRINT_DATE_LOW );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_PRINT_DATE_HIGH: '|| p_PRINT_DATE_HIGH );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_OPEN_INVOICE_FLAG: '|| p_OPEN_INVOICE_FLAG );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_INVOICE_LIST_STRING: '|| p_INVOICE_LIST_STRING );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_TEMPLATE_ID: '|| p_template_id );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_child_TEMPLATE_ID: '|| p_child_template_id );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_locale: '|| p_locale);
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'p_index_flag: '|| p_index_flag);

      -- fetch a list of payment schedule id based on the inputted parameters
      -- and insert into the ar_bpa_print_requests table

      insert_stmt := '  insert into ar_bpa_print_requests (request_id, payment_schedule_id,
			worker_id, created_by, creation_date,last_updated_by, last_update_date, customer_trx_id)';
      select_stmt := '  select  ' || m_request_id || ', payment_schedule_id, rownum, 1, sysdate, 1, sysdate, customer_trx_id from '
                     || cr ||' ( select ps.payment_schedule_id, trx.customer_trx_id '|| cr || build_from_clause ||
              '  AND nvl(a_bill.language,' || '''' || base_lang || ''') = ' || '''' || userenv_lang || '''' ;

        AR_BPA_PRINT_CONC.Build_where_clause(
            p_org_id,
    		p_choice ,
    		p_batch_id ,
            p_cust_trx_class,
    		p_trx_type_id ,
    		p_trx_number_low  ,
    		p_trx_number_high ,
    		p_print_date_low  ,
    		p_print_date_high ,
    		p_customer_class_code ,
    		p_customer_no_low     ,
    		p_customer_no_high    ,
    		p_customer_name_low  ,
    		p_customer_name_high  ,
    		p_installment_no      ,
    		p_open_invoice_flag   ,
    		p_invoice_list_string ,
    		'N'          ,
    		p_where1   ) ;

      sql_stmt := insert_stmt || cr || select_stmt || cr || p_where1 || ')';

      IF ( p_PRINT_DATE_LOW IS NOT NULL OR  p_PRINT_DATE_HIGH IS NOT NULL ) THEN
         AR_BPA_PRINT_CONC.Build_where_clause(
            p_org_id,
    		p_choice ,
    		p_batch_id ,
            p_cust_trx_class,
    		p_trx_type_id ,
    		p_trx_number_low  ,
    		p_trx_number_high ,
    		p_print_date_low  ,
    		p_print_date_high ,
    		p_customer_class_code ,
    		p_customer_no_low     ,
    		p_customer_no_high    ,
    		p_customer_name_low  ,
    		p_customer_name_high  ,
    		p_installment_no      ,
    		p_open_invoice_flag   ,
    		p_invoice_list_string ,
    		'Y'          ,
    		p_where2  ) ;
         sql_stmt := sql_stmt || cr || ' UNION ALL ' || cr || select_stmt || cr || p_where2 || ')';
      END IF;

--      IF p_order_by = 'TRX_NUMBER' THEN
--        sql_stmt := sql_stmt || cr || ' ORDER BY ps.trx_number ' ;
--      ELSIF p_order_by = 'CUSTOMER' THEN
--        sql_stmt := sql_stmt || cr || ' ORDER BY substrb(b_bill_party.party_name,1,50) ' ;
--      ELSIF p_order_by = 'POSTAL_CODE' THEN
--        sql_stmt := sql_stmt || cr || ' ORDER BY a_bill_loc.postal_code ' ;
--      END IF;


      --fnd_file.put_line( fnd_file.log, sql_stmt);
      ------------------------------------------------
      -- Parse sql stmts
      ------------------------------------------------

      sql_stmt_c:= dbms_sql.open_cursor;

      dbms_sql.parse( sql_stmt_c, sql_stmt , dbms_sql.v7 );

      bind_variables(
            p_org_id,
            p_choice ,
	 		p_batch_id ,
		    p_cust_trx_class,
			p_trx_type_id ,
			p_trx_number_low  ,
			p_trx_number_high ,
			p_print_date_low  ,
			p_print_date_high ,
			p_customer_class_code ,
			p_customer_no_low     ,
			p_customer_no_high    ,
			p_customer_name_low  ,
			p_customer_name_high  ,
			p_installment_no      ,
			p_open_invoice_flag   ,
			p_invoice_list_string ,
			'N'          ,
                  sql_stmt_c );

     IF ( p_print_date_low IS NOT NULL OR  p_print_date_high IS NOT NULL ) THEN
        bind_variables(
            p_org_id,
            p_choice ,
	 		p_batch_id ,
            p_cust_trx_class,
			p_trx_type_id ,
			p_trx_number_low  ,
			p_trx_number_high ,
			p_print_date_low  ,
			p_print_date_high ,
			p_customer_class_code ,
			p_customer_no_low     ,
			p_customer_no_high    ,
			p_customer_name_low  ,
			p_customer_name_high  ,
			p_installment_no      ,
			p_open_invoice_flag   ,
			p_invoice_list_string ,
			'Y'          ,
                  sql_stmt_c );
      END IF;


      inserted_row_counts := dbms_sql.execute(sql_stmt_c);
      fnd_file.put_line( fnd_file.log, 'inserted row count: ' || inserted_row_counts);

      IF inserted_row_counts > 0 THEN

        divided_worker_counts := ceil(inserted_row_counts/l_job_size);
        row_counts_perworker  := ceil(inserted_row_counts/divided_worker_counts);

        fnd_file.put_line( fnd_file.log, 'row count per worker: ' || row_counts_perworker);
        fnd_file.put_line( fnd_file.log, 'divided worker count: ' || divided_worker_counts);

        l_worker_id  := 1 ;
        l_low_range  := 1 ;
	  l_high_range := row_counts_perworker ;

         LOOP
            UPDATE ar_bpa_print_requests
                SET worker_id = l_worker_id
                WHERE request_id = m_request_id
                AND worker_id BETWEEN  l_low_range AND l_high_range;

	      IF l_worker_id >= divided_worker_counts THEN
                EXIT;
            END IF;

            l_worker_id        :=  l_worker_id  + 1;
            l_low_range        :=  l_low_range  + row_counts_perworker ;
            l_high_range       :=  l_high_range + row_counts_perworker ;

         END LOOP;
         commit;  -- commit the record here


         FOR no_of_workers in 1 .. divided_worker_counts
         LOOP
             l_request_id := AR_BPA_PRINT_CONC.submit_print_request(
                                           m_request_id,
                                           no_of_workers,
                                           p_order_by,
                                           p_template_id,
                                           'Y',
                                           p_child_template_id,
                                           p_locale,
                                           p_index_flag,
                                           '','', TRUE);
             IF (l_request_id = 0) THEN
                fnd_file.put_line( fnd_file.log, 'can not start for worker_id: ' ||no_of_workers );
		FND_MESSAGE.RETRIEVE(return_stat);
		fnd_file.put_line( fnd_file.log, 'Error occured : ' ||return_stat );
		l_fail_count := l_fail_count + 1;
             ELSE
                commit;
                fnd_file.put_line( fnd_file.log, 'child request id: ' ||
                    l_request_id || ' started for worker_id: ' ||no_of_workers );
             END IF;
        END LOOP;

        fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                        request_data => to_char(inserted_row_counts));
        fnd_file.put_line( fnd_file.log, 'The Master program changed status to pause and wait for child processes');
      ELSE
        fnd_file.new_line( fnd_file.log,1 );
        fnd_file.put_line( fnd_file.log, 'No transactions matched the input parameters.');
        fnd_file.new_line( fnd_file.log,1 );
      END IF;

    ELSE

        FND_FILE.PUT_LINE( FND_FILE.LOG, 'print_invoices: '
                     || 'Entering print master program at the second time');
        fnd_file.put_line( fnd_file.output,
                           arp_standard.fnd_message('AR_BPA_PRINT_OUTPUT_HDR',
                                                    'NUM_OF_WORKER',
                                                    divided_worker_counts,
                                                    'TRX_COUNT',
                                                    req_data));

	IF divided_worker_counts > 0
	THEN
           DECLARE
               CURSOR child_request_cur(p_request_id IN NUMBER) IS
                   SELECT request_id, status_code
                   FROM fnd_concurrent_requests
                   WHERE parent_request_id = p_request_id;
           BEGIN
               FOR child_request_rec IN child_request_cur(m_request_id)
               LOOP
                   check_child_request(child_request_rec.request_id);
                   IF ( child_request_rec.status_code = 'G' OR child_request_rec.status_code = 'X'
                          OR child_request_rec.status_code ='D' OR child_request_rec.status_code ='T'  ) THEN
                       cnt_warnings := cnt_warnings + 1;
                   ELSIF ( child_request_rec.status_code = 'E' ) THEN
                       cnt_errors := cnt_errors + 1;
                   END IF;
               END LOOP;

               IF ((cnt_errors >  0) OR ( l_fail_count = divided_worker_counts ))
	       THEN
                   request_status := fnd_concurrent.set_completion_status('ERROR', '');
               ELSIF ((cnt_warnings > 0) OR (l_fail_count > 0) )
	       THEN
		    request_status := fnd_concurrent.set_completion_status('WARNING', '');
               ELSE
                   request_status := fnd_concurrent.set_completion_status('NORMAL', '');
               END IF;
           END;
	END IF;

	DELETE FROM ar_bpa_print_requests
	WHERE request_id = m_request_id;

	COMMIT;

    END IF;

    FND_FILE.PUT_LINE( FND_FILE.LOG, 'AR_BPA_PRINT_CONC.print_invoices(-)' );

EXCEPTION
  WHEN OTHERS THEN
	RAISE;
END PRINT_INVOICES;

FUNCTION GENXSL_MLS_FUNCTION RETURN VARCHAR2 IS
 cursor lang_cur is
   select language_code from fnd_languages_vl
   where installed_flag in ('I', 'B');
 lang_str VARCHAR2(240);

BEGIN
   for lang_rec in lang_cur
   loop
       if ( lang_str is null ) then
        lang_str := lang_rec.language_code;
    else
           lang_str := lang_str ||','|| lang_rec.language_code;
    end if;
   end loop;
   return lang_str;
END GENXSL_MLS_FUNCTION ;


PROCEDURE process_print_request( p_id_list   IN  VARCHAR2,
                                 x_req_id_list  OUT NOCOPY VARCHAR2,
                                 p_list_type    IN  VARCHAR2,
                                 p_description  IN  VARCHAR2 ,
                                 p_template_id  IN  NUMBER,
                                 p_stamp_flag		IN VARCHAR2,
                                 p_child_template_id  IN  NUMBER
				)
IS
TYPE lang_cur is REF CURSOR;
lang_cv lang_cur;

lang_selector VARCHAR2(8096);
lang_code     VARCHAR2(4);
base_lang     VARCHAR2(4);
nls_lang      VARCHAR2(30);
nls_terr      VARCHAR2(30);

select_stmt   VARCHAR2(8096);
select_cur    INTEGER;

ps_id  dbms_sql.number_table;

inserted_row_counts   INTEGER;
fetched_row_count     INTEGER;
ignore                INTEGER;

row_counts_perworker  number;
divided_worker_counts number := 1;

l_request_id    number;     -- child request id

l_low_range  NUMBER := 1;
l_high_range NUMBER := 1;

l_fail_flag VARCHAR2(1) ;

BEGIN

   SELECT    language_code
     INTO    base_lang
     FROM    fnd_languages
     WHERE   installed_flag = 'B';


   IF NVL( p_list_type , 'TRX') = 'TRX' THEN
      lang_selector := '  select distinct(nvl(rtrim(substr(a_bill.language,1,4)), '''
				|| base_lang || ''')) language ' || cr || build_from_clause
				|| ' AND trx.customer_trx_id in ('|| p_id_list || ' )' ;
   ELSE
      lang_selector := '  select distinct(nvl(rtrim(substr(a_bill.language,1,4)), '''
				|| base_lang || ''')) language ' || cr || build_from_clause
				|| ' AND ps.payment_schedule_id in ('|| p_id_list || ' )' ;
   END IF;

   OPEN lang_cv FOR lang_selector;

   LOOP

      FETCH lang_cv INTO lang_code;
      EXIT WHEN lang_cv%NOTFOUND;

      SELECT  nls_language, nls_territory
        INTO  nls_lang, nls_terr
        FROM  FND_LANGUAGES
        WHERE language_code = lang_code;

      IF NVL( p_list_type , 'TRX') = 'TRX' THEN
         select_stmt := ' SELECT ps.payment_schedule_id ' || cr || build_from_clause || cr ||
                        ' AND trx.customer_trx_id in ( ' || p_id_list || ' ) ' || cr ||
                        ' AND nvl(a_bill.language, ''' || base_lang ||''' ) = :lang_code ' || cr ||
                        ' ORDER BY ps.trx_number ' ;
      ELSE
         select_stmt := ' SELECT ps.payment_schedule_id ' || cr || build_from_clause || cr ||
                        ' AND ps.payment_schedule_id in ('|| p_id_list || ' ) ' || cr ||
                        ' AND nvl(a_bill.language, ''' || base_lang ||''' ) = :lang_code ' || cr ||
                        ' ORDER BY ps.trx_number ' ;
      END IF;

      select_cur := dbms_sql.open_cursor;
      dbms_sql.parse( select_cur, select_stmt, dbms_sql.native );

      dbms_sql.bind_variable(select_cur,':lang_code', lang_code );
      dbms_sql.define_array(select_cur,1,ps_id,500,1 );
      ignore := dbms_sql.execute(select_cur);

      LOOP
         fetched_row_count := dbms_sql.fetch_rows(select_cur);
         dbms_sql.column_value(select_cur,1,ps_id);

         EXIT WHEN fetched_row_count <> 500 ;
      END LOOP;
      dbms_sql.close_cursor(select_cur);

      inserted_row_counts := ps_id.COUNT    ;


      divided_worker_counts := ceil(inserted_row_counts/500);
      row_counts_perworker  := ceil(inserted_row_counts/divided_worker_counts);

      l_low_range  := 1 ;
      l_high_range := row_counts_perworker ;

      FOR no_of_workers in 1 .. divided_worker_counts
      LOOP

         -- When parent request id is passed as -1, child
         -- request uses its request id to pick data.

         l_request_id := AR_BPA_PRINT_CONC.submit_print_request(
                                                                -1,
                                                                no_of_workers,
                                                                'TRX_NUMBER',
                                                                p_template_id,
                                                                p_stamp_flag,
                                                                p_child_template_id,
                                                                '',
                                                                '',
                                                                nls_lang ,
                                                                nls_terr,
                       					        FALSE,
					                        p_description);

	 IF l_request_id = 0
	 THEN
	    l_fail_flag := 'Y';
	 ELSIF x_req_id_list IS NULL THEN
            x_req_id_list  := l_request_id;
         ELSE
            x_req_id_list  := x_req_id_list  ||','|| l_request_id;
         END IF;

         FORALL i in l_low_range .. l_high_range
            INSERT INTO ar_bpa_print_requests ( request_id,
                				payment_schedule_id,
     	                			worker_id,
           	        			created_by,
                   				creation_date,
               					last_updated_by,
     	               				last_update_date)
     	    VALUES (l_request_id,
               	    ps_id(i),
                    no_of_workers  ,
     	            1,
           	    sysdate,
                    1,
                    sysdate);

         COMMIT;
         l_low_range  := l_low_range + row_counts_perworker;
         l_high_range := l_high_range + row_counts_perworker;
      END LOOP;
   END LOOP;

   /* If any time a request failed to submit, then we send the request id
	list as zero */
   IF l_fail_flag = 'Y' THEN
      x_req_id_list := '0';
   END IF;

   CLOSE lang_cv;
EXCEPTION
   WHEN OTHERS THEN
      IF dbms_sql.is_open(select_cur) THEN
         dbms_sql.close_cursor(select_cur);
      END IF;
      IF lang_cv%ISOPEN THEN
         CLOSE lang_cv;
      END IF;
      RAISE;
END process_print_request;

PROCEDURE process_multi_print( 	p_id_list 	IN  VARCHAR2 ,
			       	x_request_id 	OUT NOCOPY NUMBER,
				x_out_status 	OUT NOCOPY VARCHAR2,
			       	p_list_type 	IN  VARCHAR2
			      )
IS

l_trx_ps_id NUMBER;

l_request_id    number;

l_count NUMBER := 0;
l_iter NUMBER := 0;

l_id_list VARCHAR2(250);

rows NUMBER;
ps_id  dbms_sql.number_table;

BEGIN
   SELECT fnd_concurrent_requests_s.nextval
     INTO   l_request_id
     FROM   dual;

   x_request_id := l_request_id;

   l_id_list := p_id_list;

   WHILE TRUE LOOP
      l_iter := l_iter + 1;

      l_count := INSTR(l_id_list  ,',') ;

      IF l_count = 0 THEN
         ps_id(l_iter) := TO_NUMBER(l_id_list);
         EXIT;
      ELSE
         ps_id(l_iter) := SUBSTR(l_id_list,1,l_count - 1);
         l_id_list:= SUBSTR(l_id_list,l_count+1);
      END IF;

   END LOOP;

   BEGIN
      IF NVL( p_list_type , 'TRX') = 'TRX'
      THEN
	 FORALL i IN 1..l_iter
            INSERT INTO ar_bpa_print_requests (request_id,
                   			       payment_schedule_id,
                     			       worker_id,
                  			       created_by,
                  			       creation_date,
                  			       last_updated_by,
                  			       last_update_date)
            (SELECT l_request_id ,
	  	    ps.payment_schedule_id,
		    1,
		    1,
		    sysdate,
		    1,
		    sysdate
	     FROM  ra_customer_trx ct ,
               	   ar_payment_schedules ps
             WHERE ct.customer_Trx_id = ps_id(i)
	       AND ps.customer_Trx_id = ct.customer_Trx_id);

	    rows := SQL%ROWCOUNT;
      ELSE
         FORALL i IN 1..l_iter
            INSERT INTO ar_bpa_print_requests (request_id,
                                               payment_schedule_id,
                                               worker_id,
                                               created_by,
                                               creation_date,
                                               last_updated_by,
                                               last_update_date)
            VALUES( l_request_id ,
                    ps_id(i),
                    1,
                    1,
                    sysdate,
                    1,
                    sysdate);

	    rows := SQL%ROWCOUNT;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN NULL;
   END;

   COMMIT;

   x_out_status := NULL;

EXCEPTION
   WHEN OTHERS THEN
      x_out_status := SUBSTR(SQLERRM, 1, 100);
END process_multi_print;

END AR_BPA_PRINT_CONC;

/
