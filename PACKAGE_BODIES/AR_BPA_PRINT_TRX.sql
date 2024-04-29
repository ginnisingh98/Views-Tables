--------------------------------------------------------
--  DDL for Package Body AR_BPA_PRINT_TRX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_PRINT_TRX" AS
/* $Header: arbpaptb.pls 120.0.12010000.3 2008/11/19 14:52:21 vsanka ship $ */
--*************************************************************************
-- Copyright (c)  2000    Oracle                 Product Development
-- All rights reserved
--*************************************************************************
--
-- HEADER
--  Source control header
--
-- PROGRAM NAME
--   arbpaptb.pls
--
-- DESCRIPTION
-- This script creates the package body of AR_BPA_PRINT_TRX
--
-- USAGE
--   To install        sqlplus <apps_user>/<apps_pwd> @arbpaptb.pls
--   To execute        sqlplus <apps_user>/<apps_pwd> AR_BPA_PRINT_TRX.
--
-- PROGRAM LIST        DESCRIPTION
--
-- PRINT_INVOICES      This function is used to print the selected invoices
--
-- DEPENDENCIES
-- None
--
-- CALLED BY
-- BPA Master Program
--
-- LAST UPDATE DATE    08-Jun-2007
-- Date the program has been modified for the last time.
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- --------------------------------------
-- Draft1A 08-Jun-2007 Sandeep Kumar G Initial Version
-- Draft1B 14-Jul-2008 Rakesh Pulla      Made changes as per the Bug #7216665
-- Draft1c 19-Nov-2008 Pavan 		Sync up changes to add Draft1B changes
--===========================================================================*/

PG_DEBUG VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'Y');
lv_msg   VARCHAR2(240);

--************************************************************
--************************************************************


FUNCTION build_from_clause RETURN VARCHAR2 IS
lc_from_clause VARCHAR2(8096);

BEGIN

lc_from_clause := '  FROM ' ||
      '  ar_payment_schedules_all        apsa,  ' ||
      '  ra_customer_trx                 rct,  ' ||
      '  ra_terms                        rt,  ' ||
      '  ra_cust_trx_types_all           rctt,    ' ||
      '  hz_cust_accounts_all            hcaa,  ' ||
      '  hz_parties                      hpar,  ' ||
      '  hz_cust_acct_sites_all          hcasa, ' ||
      '  hz_party_sites                  hps,' ||
      '  hz_locations                    hl, ' ||
      '  hz_cust_site_uses_all           hcsua ' ||
      '  WHERE    ' ||
      '  rct.cust_trx_type_id            = rctt.cust_trx_type_id  ' ||
      '  AND rct.org_id                  = rctt.org_id  ' ||
      '  AND rct.customer_trx_id         = apsa.customer_trx_id  ' ||
      '  AND rct.org_id                  = apsa.org_id  ' ||
      '  AND rct.printing_option         = ' || '''' || 'PRI' || '''' ||
      '  AND rct.bill_to_customer_id     = hcaa.cust_account_id   ' ||
      '  AND hcaa.party_id               = hpar.party_id ' ||
      '  AND rct.bill_to_site_use_id     = hcsua.site_use_id ' ||
      '  AND rct.org_id                  = hcsua.org_id ' ||
      '  AND hcsua.cust_acct_site_id     = hcasa.cust_acct_site_id(+) ' ||
      '  AND hcsua.org_id                = hcasa.org_id(+) ' ||
      '  AND hcasa.party_site_id         = hps.party_site_id(+) ' ||
      '  AND rct.term_id                 = rt.term_id(+) ' ||
      '  AND rt.billing_cycle_id         IS NULL ' ||
      '  AND hl.location_id(+)           = hps.location_id ' ;

RETURN lc_from_clause;

END build_from_clause;
--************************************************************
--************************************************************

PROCEDURE check_child_request(p_request_id  IN OUT  NOCOPY NUMBER) IS

  lb_call_status  BOOLEAN;
  lc_rphase       VARCHAR2(80);
  lc_rstatus      VARCHAR2(80);
  lc_dphase       VARCHAR2(30);
  lc_dstatus      VARCHAR2(30);
  lc_message      VARCHAR2(240);

BEGIN
  lb_call_status := FND_CONCURRENT.get_request_status(
                        p_request_id
                       ,''
                       ,''
                       ,lc_rphase
                       ,lc_rstatus
                       ,lc_dphase
                       ,lc_dstatus
                       ,lc_message);

  IF ((lc_dphase = 'COMPLETE') AND (lc_dstatus = 'NORMAL')) THEN
     FND_MESSAGE.set_name('FND','SRS-OUTCOME SUCCESS');
     lv_msg := FND_MESSAGE.get;
     FND_FILE.put_line(FND_FILE.log, p_request_id || lv_msg);

  ELSE
     FND_MESSAGE.set_name('FND','SRS-OUTCOME SUCCESS');
     lv_msg := FND_MESSAGE.get;
     FND_FILE.put_line(FND_FILE.log, p_request_id ||' not '||lv_msg);
  END IF;

END check_child_request;

--************************************************************
--************************************************************

FUNCTION submit_print_request(p_parent_request_id  IN NUMBER
			     ,p_worker_id          IN NUMBER
			     ,p_template_id        IN NUMBER
			     ,p_choice             IN VARCHAR2
			     ,p_stamp_flag         IN VARCHAR2
			     ,p_child_template_id  IN NUMBER   DEFAULT NULL
			     ,p_nls_lang           IN VARCHAR2
			     ,p_nls_territory      IN VARCHAR2
			     ,p_sub_request_flag   IN BOOLEAN
			     ,p_description        IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER IS

  lb_options_ok        BOOLEAN;
  ln_m_request_id        NUMBER;
  ln_number_of_copies    NUMBER;
  lc_printer             VARCHAR2(30);
  lc_print_style         VARCHAR2(30);
  lc_save_output_flag    VARCHAR2(30);
  lb_save_output_bool    BOOLEAN;
  lb_print_opt_populated BOOLEAN;
  ln_conc_prog_code      VARCHAR2(30);
     ln_conc_prog_id        NUMBER;

BEGIN

SELECT fcp.concurrent_program_name
,fcp.concurrent_program_id
INTO ln_conc_prog_code
,ln_conc_prog_id
FROM
fnd_concurrent_programs
fcp
,fnd_concurrent_requests
fcr
WHERE
fcp.concurrent_program_id
=
fcr.concurrent_program_id
AND
fcr.request_id
=
p_parent_request_id;


  lb_options_ok := FND_REQUEST.set_options(implicit  => 'NO'
					 ,protected => 'YES'
					 ,language  => p_nls_lang
					 ,territory => p_nls_territory);
  IF (lb_options_ok) THEN

  IF ln_conc_prog_code='ARBPAIPMP_IL' THEN
  IF p_choice ='NEW' THEN

  UPDATE fnd_concurrent_requests
  SET save_output_flag='N'
  ,number_of_copies=1
  WHERE
  request_id
  =
  p_parent_request_id
  AND
  concurrent_program_id
  =
  ln_conc_prog_id;
  ELSE
  UPDATE
  fnd_concurrent_requests
  SET
  save_output_flag='Y'
  WHERE
  request_id
  =
  p_parent_request_id
  AND
  concurrent_program_id
  =
  ln_conc_prog_id;
  END
  IF;
  END
  IF;

    IF( FND_CONCURRENT.get_request_print_options(p_parent_request_id
                                                ,ln_number_of_copies
                                                ,lc_print_style
                                                ,lc_printer
                                                ,lc_save_output_flag)) THEN

      IF (lc_save_output_flag = 'Y') THEN
        lb_save_output_bool := TRUE;
      ELSE
        lb_save_output_bool := FALSE;
      END IF;

      IF (NOT FND_REQUEST.set_print_options(printer     => lc_printer
                                           ,style       => lc_print_style
                                           ,copies      => ln_number_of_copies
                                           ,save_output => lb_save_output_bool)) THEN
        lb_print_opt_populated := FALSE;
      ELSE
        lb_print_opt_populated := TRUE;
      END IF;
    END IF;
    ln_m_request_id := FND_REQUEST.submit_request(
                  application=> 'AR'
                , program    => 'ARBPIPCP'
                , description=> p_description
                , start_time => ''
                , sub_request=> p_sub_request_flag
                , argument1  => p_parent_request_id
                , argument2  => p_worker_id
                , argument3  => 'TRX_NUMBER'
                , argument4  => p_template_id
                , argument5  => p_stamp_flag
                , argument6  => p_child_template_id
                , argument7  => 222
                , argument8  => 'en-US'
                , argument9  => 'N'
                , argument10 => chr(0)
                , argument11 => '', argument12 => '', argument13 => '', argument14 => '', argument15 => ''
                , argument16 => '', argument17 => '', argument18 => '', argument19 => '', argument20 => ''
                , argument21 => '', argument22 => '', argument23 => '', argument24 => '', argument25 => ''
                , argument26 => '', argument27 => '', argument28 => '', argument29 => '', argument30 => ''
                , argument31 => '', argument32 => '', argument33 => '', argument34 => '', argument35 => ''
                , argument36 => '', argument37 => '', argument38 => '', argument39 => '', argument40 => ''
                , argument41 => '', argument42 => '', argument43 => '', argument44 => '', argument45 => ''
                , argument46 => '', argument47 => '', argument48 => '', argument49 => '', argument50 => ''
                , argument51 => '', argument52 => '', argument53 => '', argument54 => '', argument55 => ''
                , argument56 => '', argument57 => '', argument58 => '', argument59 => '', argument60 => ''
                , argument61 => '', argument62 => '', argument63 => '', argument64 => '', argument65 => ''
                , argument66 => '', argument67 => '', argument68 => '', argument69 => '', argument70 => ''
                , argument71 => '', argument72 => '', argument73 => '', argument74 => '', argument75 => ''
                , argument76 => '', argument77 => '', argument78 => '', argument79 => '', argument80 => ''
                , argument81 => '', argument82 => '', argument83 => '', argument84 => '', argument85 => ''
                , argument86 => '', argument87 => '', argument88 => '', argument89 => '', argument90 => ''
                , argument91 => '', argument92 => '', argument93 => '', argument94 => '', argument95 => ''
                , argument96 => '', argument97 => '', argument98 => '', argument99 => '', argument100=> '');
  END IF;
  RETURN ln_m_request_id;

END submit_print_request;

--************************************************************
--************************************************************

PROCEDURE build_where_clause(p_org_id IN NUMBER   DEFAULT NULL
			    ,p_choice             IN VARCHAR2
			    ,p_cust_trx_class     IN VARCHAR2 DEFAULT NULL
			    ,p_trx_type_id        IN NUMBER   DEFAULT NULL
			    ,p_trx_number_low     IN VARCHAR2 DEFAULT NULL
			    ,p_trx_number_high    IN VARCHAR2 DEFAULT NULL
			    ,p_doc_number_low     IN VARCHAR2 DEFAULT NULL
			    ,p_doc_number_high    IN VARCHAR2 DEFAULT NULL
			    ,p_print_date_low     IN DATE     DEFAULT NULL
			    ,p_print_date_high    IN DATE     DEFAULT NULL
			    ,p_customer_no_low    IN VARCHAR2 DEFAULT NULL
			    ,p_customer_no_high   IN VARCHAR2 DEFAULT NULL
			    ,p_customer_name_low  IN VARCHAR2 DEFAULT NULL
			    ,p_customer_name_high IN VARCHAR2 DEFAULT NULL
			    ,p_union_flag         IN VARCHAR2 DEFAULT NULL
			    ,where_clause         OUT NOCOPY VARCHAR2) IS
BEGIN

   /*------------------------------------------------------------------------+
   |   Build where clause depending on passed parameters.                    |
   |   Operating Unit                p_org_id                                |
   |   Transactions to Print         p_choice = NEW / ANY / OLD              |
   |   (High) Bill TO Customer Name  p_customer_name_high                    |
   |   (Low) Bill TO Customer Name   p_customer_name_low                     |
   |   (High) Bill To Customer Numberp_customer_no_high                      |
   |   (Low) Bill To Customer Number p_customer_no_low                       |
   |   Transaction Class             p_cust_trx_class                        |
   |   Transaction Type              p_cust_trx_type_id                      |
   |   (High) Transaction Number     p_trx_number_high                       |
   |   (Low) Transaction Number      p_trx_number_low                        |
   |   (High) Document Number        p_doc_number_high                       |
   |   (Low)  Document Number        p_doc_number_low                        |
   |   (High) Print Date             p_print_date_high                       |
   |   (Low) Print Date              p_print_date_low                        |
   --------------------------------------------------------------------------*/

   IF (p_choice = 'NEW' ) THEN
      where_clause :=where_clause || ' AND  NVL(rct.printing_pending, ' ||'''' || 'N' ||'''' ||' ) = ' || '''' || 'Y' ||'''' ||
                     ' AND  apsa.terms_sequence_number > NVL(rct.last_printed_sequence_num,0) ' ;
   ELSIF (p_choice = 'OLD' ) THEN
       -- Changed from apsa.terms_sequence_number to 0 (Zero) because,
       -- if it is apsa.terms_sequence_number then the report is not fetching the
       -- data for the p_choice = 'OLD'
       where_clause :=where_clause || ' AND NVL(rct.last_printed_sequence_num, 0) > 0 ';
   END IF;

   IF ( p_org_id IS NOT NULL ) THEN
     where_clause :=where_clause || ' AND rct.org_id = :org_id ' ;
   END IF;

   IF ( p_customer_name_low IS NOT NULL AND p_customer_name_high IS NULL )THEN
     where_clause :=where_clause || ' AND hpar.party_name = :customer_name_low ';
   ELSIF ( (p_customer_name_high IS NOT NULL) AND (p_customer_name_low IS NULL ) ) THEN
     where_clause :=where_clause || ' AND hpar.party_name  = :customer_name_high ';
   ELSIF ( (p_customer_name_high IS NOT NULL) AND (p_customer_name_low IS NOT NULL) )  THEN
     where_clause :=where_clause || ' AND hpar.party_name >=  :customer_name_low ';
     where_clause :=where_clause || ' AND hpar.party_name  <= :customer_name_high ';
   END IF;

   IF ( (p_customer_no_low IS NOT NULL) AND (p_customer_no_high IS NULL) ) THEN
     where_clause :=where_clause || ' AND hcaa.account_number = :customer_no_low ' ;
   ELSIF ( (p_customer_no_high IS NOT NULL) AND (p_customer_no_low IS  NULL) ) THEN
     where_clause :=where_clause || ' AND hcaa.account_number = :customer_no_high ';
   ELSIF ( (p_customer_no_high IS NOT NULL) AND (p_customer_no_low IS NOT NULL) ) THEN
     where_clause :=where_clause || ' AND hcaa.account_number >= :customer_no_low ';
     where_clause :=where_clause || ' AND hcaa.account_number <= :customer_no_high ' ;
   END IF;

   IF ( p_cust_trx_class IS NOT NULL ) THEN
      where_clause :=where_clause || ' AND rctt.type = :cust_trx_class ';
   END IF;

   IF ( p_trx_type_id IS NOT NULL ) THEN
      where_clause :=where_clause || ' AND rctt.cust_trx_type_id = :trx_type_id ' ;
   END IF;

   IF ( (p_trx_number_low IS NOT NULL) AND (p_trx_number_high IS NULL )) THEN
     where_clause :=where_clause || ' AND rct.trx_number = :trx_number_low ';
   ELSIF ( (p_trx_number_high IS NOT NULL) AND (p_trx_number_low IS NULL) ) THEN
     where_clause :=where_clause || ' AND rct.trx_number = :trx_number_high ';
   ELSIF ( (p_trx_number_high IS NOT NULL ) AND (p_trx_number_low IS NOT NULL) ) THEN
     where_clause :=where_clause || ' AND rct.trx_number >= :trx_number_low ';
     where_clause :=where_clause || ' AND rct.trx_number <= :trx_number_high ';
   END IF;

   IF ( (p_doc_number_low IS NOT NULL) AND (p_doc_number_high IS NULL )) THEN
     where_clause :=where_clause || ' AND rct.doc_sequence_value = :doc_number_low ';
   ELSIF ( (p_doc_number_high IS NOT NULL) AND (p_doc_number_low IS NULL) ) THEN
     where_clause :=where_clause || ' AND rct.doc_sequence_value = :doc_number_high ';
   ELSIF ( (p_doc_number_high IS NOT NULL ) AND (p_doc_number_low IS NOT NULL) ) THEN
     where_clause :=where_clause || ' AND rct.doc_sequence_value >= :doc_number_low ';
     where_clause :=where_clause || ' AND rct.doc_sequence_value <= :doc_number_high ';
   END IF;

   /**********************************************************************************
   Handle Print Lead Days IF date range is provided. IF the invoice you are printing
   has a payment term where Print Lead Days is 0, Receivables uses the transaction date
   to determine IF this transaction falls into the Start and END Date range you specIFy.
   IF the invoice you are printing has a payment term where Print Lead Days is greater
   than 0, Receivables uses the FORmula Due Date - Print Lead Days to determine IF this
   transaction is to be printed
   ************************************************************************************/

   IF ( (p_print_date_low IS NOT NULL) or (p_print_date_low IS NOT NULL) ) THEN
      IF ( p_union_flag = 'N' ) THEN
         where_clause := where_clause || ' AND nvl(rt.printing_lead_days,0)  = 0 ' ;
         IF ( p_print_date_low IS NOT NULL AND p_print_date_high IS NOT NULL ) THEN
              where_clause := where_clause || ' AND rct.trx_date BETWEEN TO_DATE(:print_date_low, ';
            where_clause := where_clause || '''DD-MM-YYYY-HH24:MI:SS'')';
            where_clause := where_clause ||  '                   AND TO_DATE(:print_date_high, ';
            where_clause := where_clause || '''DD-MM-YYYY-HH24:MI:SS'')';
         ELSIF ( p_print_date_low IS NOT NULL AND  p_print_date_high IS  NULL) THEN
              where_clause := where_clause ||  'AND rct.trx_date >= TO_DATE(:print_date_low, ';
            where_clause := where_clause ||  '''DD-MM-YYYY-HH24:MI:SS'')';
         ELSIF ( p_print_date_high IS NOT NULL AND p_print_date_low IS NULL ) THEN
            where_clause := where_clause ||  'AND rct.trx_date <= TO_DATE(:print_date_high, ';
            where_clause := where_clause ||  '''DD-MM-YYYY-HH24:MI:SS'')';
         END IF;
      ELSE
         where_clause :=where_clause || ' AND nvl(rt.printing_lead_days,0) > 0 ' ;
         IF ( p_print_date_low IS NOT NULL AND p_print_date_high IS NOT NULL ) THEN
            where_clause := where_clause ||  'AND apsa.due_date BETWEEN TO_DATE(:print_date_low, ';
            where_clause := where_clause || '''DD-MM-YYYY-HH24:MI:SS'')';
            where_clause := where_clause || '                       + NVL (rt.printing_lead_days, 0)';
            where_clause := where_clause || '                   AND TO_DATE(:print_date_high, ';
            where_clause := where_clause || '''DD-MM-YYYY-HH24:MI:SS'')';
            where_clause := where_clause || '                       + NVL (rt.printing_lead_days, 0)';
        ELSIF ( p_print_date_low IS NOT NULL AND p_print_date_high IS  NULL ) THEN
            where_clause := where_clause || 'AND apsa.due_date >= TO_DATE(:print_date_low, ';
            where_clause := where_clause || '''DD-MM-YYYY-HH24:MI:SS'') + NVL (rt.printing_lead_days, 0)';
         ELSIF ( p_print_date_high IS NOT NULL AND p_print_date_low IS NULL ) THEN
            where_clause := where_clause || 'AND apsa.due_date <= TO_DATE(:print_date_high, ';
            where_clause := where_clause || '''DD-MM-YYYY-HH24:MI:SS'') + NVL (rt.printing_lead_days, 0)';
        END IF;
     END IF;
  END IF;

END build_where_clause;

--************************************************************
--************************************************************

PROCEDURE bind_variables(p_org_id IN NUMBER   DEFAULT NULL
			,p_choice             IN VARCHAR2
			,p_cust_trx_class     IN VARCHAR2 DEFAULT NULL
			,p_trx_type_id        IN NUMBER   DEFAULT NULL
			,p_trx_number_low     IN VARCHAR2 DEFAULT NULL
			,p_trx_number_high    IN VARCHAR2 DEFAULT NULL
			,p_doc_number_low     IN VARCHAR2 DEFAULT NULL
			,p_doc_number_high    IN VARCHAR2 DEFAULT NULL
			,p_print_date_low     IN DATE     DEFAULT NULL
			,p_print_date_high    IN DATE     DEFAULT NULL
			,p_customer_no_low    IN VARCHAR2 DEFAULT NULL
			,p_customer_no_high   IN VARCHAR2 DEFAULT NULL
			,p_customer_name_low  IN VARCHAR2 DEFAULT NULL
			,p_customer_name_high IN VARCHAR2 DEFAULT NULL
			,p_union_flag         IN VARCHAR2 DEFAULT NULL
			,cursor_name          IN INTEGER ) IS
BEGIN

   /*------------------------------------------------------------------------+
   |   Bind clause depending on passed parameters.                           |
   |   Operating Unit                p_org_id                                |
   |   Transactions to Print         p_choice = NEW / ANY / OLD              |
   |   (High) Bill TO Customer Name  p_customer_name_high                    |
   |   (Low) Bill TO Customer Name   p_customer_name_low                     |
   |   (High) Bill To Customer Numberp_customer_no_high                      |
   |   (Low) Bill To Customer Number p_customer_no_low                       |
   |   Transaction Class             p_cust_trx_class                        |
   |   Transaction Type              p_cust_trx_type_id                      |
   |   (High) Transaction Number     p_trx_number_high                       |
   |   (Low) Transaction Number      p_trx_number_low                        |
   |   (High) Document Number        p_doc_number_high                       |
   |   (Low) Document Number         p_doc_number_low                        |
   |   (High) Print Date             p_print_date_high                       |
   |   (Low) Print Date              p_print_date_low                        |
   --------------------------------------------------------------------------*/

   IF ( p_org_id IS NOT NULL ) THEN
     DBMS_SQL.bind_variable( cursor_name, ':org_id', p_org_id) ;
   END IF;

   IF ( p_customer_name_low IS NOT NULL AND p_customer_name_high IS NULL )THEN
     DBMS_SQL.bind_variable( cursor_name, ':customer_name_low', p_customer_name_low);
   ELSIF ( (p_customer_name_high IS NOT NULL) AND (p_customer_name_low IS NULL ) ) THEN
     DBMS_SQL.bind_variable( cursor_name, ':customer_name_high', p_customer_name_high );
   ELSIF ( (p_customer_name_high IS NOT NULL) AND (p_customer_name_low IS NOT NULL) )  THEN
     DBMS_SQL.bind_variable( cursor_name, ':customer_name_low',  p_customer_name_low);
     DBMS_SQL.bind_variable( cursor_name,':customer_name_high', p_customer_name_high);
   END IF;

   IF ( (p_customer_no_low IS NOT NULL) AND (p_customer_no_high IS NULL) ) THEN
      DBMS_SQL.bind_variable( cursor_name, ':customer_no_low', p_customer_no_low ) ;
   ELSIF ( (p_customer_no_high IS NOT NULL) AND (p_customer_no_low IS  NULL) ) THEN
      DBMS_SQL.bind_variable( cursor_name, ':customer_no_high', p_customer_no_high );
   ELSIF ( (p_customer_no_high IS NOT NULL) AND (p_customer_no_low IS NOT NULL) ) THEN
      DBMS_SQL.bind_variable( cursor_name, ':customer_no_low', p_customer_no_low  ) ;
      DBMS_SQL.bind_variable( cursor_name, ':customer_no_high', p_customer_no_high ) ;
   END IF;

   IF ( p_cust_trx_class IS NOT NULL ) THEN
      DBMS_SQL.bind_variable( cursor_name, ':cust_trx_class', p_cust_trx_class );
   END IF;

   IF ( p_trx_type_id IS NOT NULL ) THEN
      DBMS_SQL.bind_variable( cursor_name, ':trx_type_id', p_trx_type_id ) ;
   END IF;

   IF ( (p_trx_number_low IS NOT NULL) AND (p_trx_number_high IS NULL )) THEN
     DBMS_SQL.bind_variable( cursor_name, ':trx_number_low', p_trx_number_low);
   ELSIF ( (p_trx_number_high IS NOT NULL) AND (p_trx_number_low IS NULL) ) THEN
     DBMS_SQL.bind_variable( cursor_name, ':trx_number_high', p_trx_number_high);
   ELSIF ( (p_trx_number_high IS NOT NULL ) AND (p_trx_number_low IS NOT NULL) ) THEN
     DBMS_SQL.bind_variable( cursor_name, ':trx_number_low' , p_trx_number_low);
     DBMS_SQL.bind_variable( cursor_name, ':trx_number_high', p_trx_number_high);
   END IF;

   IF ( (p_doc_number_low IS NOT NULL) AND (p_doc_number_high IS NULL )) THEN
     DBMS_SQL.bind_variable( cursor_name, ':doc_number_low', p_doc_number_low);
   ELSIF ( (p_doc_number_high IS NOT NULL) AND (p_doc_number_low IS NULL) ) THEN
     DBMS_SQL.bind_variable( cursor_name, ':doc_number_high', p_doc_number_high);
   ELSIF ( (p_doc_number_high IS NOT NULL ) AND (p_doc_number_low IS NOT NULL) ) THEN
     DBMS_SQL.bind_variable( cursor_name, ':doc_number_low' , p_doc_number_low);
     DBMS_SQL.bind_variable( cursor_name, ':doc_number_high', p_doc_number_high);
   END IF;

   /**********************************************************************************
   Handle Print Lead Days IF date range is provided. IF the invoice you are printing
   has a payment term where Print Lead Days is 0, Receivables uses the transaction date
   to determine IF this transaction falls into the Start and END Date range you specIFy.
   IF the invoice you are printing has a payment term where Print Lead Days is greater
   than 0, Receivables uses the FORmula Due Date - Print Lead Days to determine IF this
   transaction is to be printed
   ************************************************************************************/

   IF ( (p_print_date_low IS NOT NULL) or (p_print_date_low IS NOT NULL) ) THEN
      IF ( p_union_flag = 'N' ) THEN
         IF ( p_print_date_low IS NOT NULL AND p_print_date_high IS NOT NULL ) THEN
            DBMS_SQL.bind_variable( cursor_name, ':print_date_low' ,
                                  TO_CHAR(p_print_date_low ,'DD-MM-YYYY-HH24:MI:SS'));
            DBMS_SQL.bind_variable( cursor_name, ':print_date_high' ,
                                  TO_CHAR(p_print_date_high ,'DD-MM-YYYY-HH24:MI:SS'));
         ELSIF ( p_print_date_low IS NOT NULL AND  p_print_date_high IS  NULL) THEN
            DBMS_SQL.bind_variable( cursor_name, ':print_date_low' ,
                                  TO_CHAR(p_print_date_low ,'DD-MM-YYYY-HH24:MI:SS'));
         ELSIF ( p_print_date_high IS NOT NULL AND p_print_date_low IS NULL ) THEN
            DBMS_SQL.bind_variable( cursor_name, ':print_date_high' ,
                                  TO_CHAR(p_print_date_high ,'DD-MM-YYYY-HH24:MI:SS'));
         END IF;
      ELSE
         IF ( p_print_date_low IS NOT NULL AND p_print_date_high IS NOT NULL ) THEN
            DBMS_SQL.bind_variable( cursor_name, ':print_date_low' ,
                                  TO_CHAR(p_print_date_low ,'DD-MM-YYYY-HH24:MI:SS'));
            DBMS_SQL.bind_variable( cursor_name, ':print_date_high' ,
                                  TO_CHAR(p_print_date_high ,'DD-MM-YYYY-HH24:MI:SS'));
        ELSIF ( p_print_date_low IS NOT NULL AND p_print_date_high IS  NULL ) THEN
            DBMS_SQL.bind_variable( cursor_name, ':print_date_low' ,
                                  TO_CHAR(p_print_date_low ,'DD-MM-YYYY-HH24:MI:SS'));
         ELSIF ( p_print_date_high IS NOT NULL AND p_print_date_low IS NULL ) THEN
            DBMS_SQL.bind_variable( cursor_name, ':print_date_high' ,
                                  TO_CHAR(p_print_date_high ,'DD-MM-YYYY-HH24:MI:SS'));
        END IF;
     END IF;
  END IF;

END bind_variables;

--************************************************************
--************************************************************

PROCEDURE print_invoices(errbuf                IN OUT NOCOPY VARCHAR2
                        ,retcode               IN OUT NOCOPY VARCHAR2
                        ,p_org_id              IN NUMBER
                        ,p_job_size            IN NUMBER
			 ,p_template_id         IN NUMBER
                        ,p_choice              IN VARCHAR2
                        ,p_cust_trx_class      IN VARCHAR2
                        ,p_trx_type_id         IN NUMBER
                        ,p_customer_name_low   IN VARCHAR2
                        ,p_customer_name_high  IN VARCHAR2
                        ,p_customer_no_low     IN VARCHAR2
                        ,p_customer_no_high    IN VARCHAR2
                        ,p_trx_number_low      IN VARCHAR2
                        ,p_trx_number_high     IN VARCHAR2
                        ,p_doc_number_low      IN VARCHAR2
                        ,p_doc_number_high     IN VARCHAR2
                        ,p_print_date_low_in   IN VARCHAR2
                        ,p_print_date_high_in  IN VARCHAR2)
IS
  ln_job_size         INTEGER := 500;
  ld_print_date_low   DATE    := NULL;
  ld_print_date_high  DATE    := NULL;
  lc_where1           VARCHAR2(8096);
  lc_where2           VARCHAR2(8096);
  lb_filter_exists      BOOLEAN := FALSE;

  --local variables
  lc_base_lang          VARCHAR2(4);
  lc_userenv_lang       VARCHAR2(4);
  ln_retval             NUMBER;
  ln_parm_number        NUMBER;
  lc_parm_name          VARCHAR2(80);

  ln_sql_stmt_c         NUMBER;
  lc_sql_stmt           VARCHAR2(8096);
  lc_insert_stmt        VARCHAR2(240);
  lc_select_stmt        VARCHAR2(8096);

  ln_inserted_row_counts   INTEGER;
  ln_row_counts_perworker  NUMBER;
  ln_divided_worker_counts NUMBER := 1;

  -- variable used for concurrent program
  lc_req_data         VARCHAR2(240);
  ln_request_id     NUMBER;     -- child request id
  ln_m_request_id     NUMBER;     -- parent request id

  ln_low_range      NUMBER := 1;
  ln_high_range     NUMBER := 1;
  ln_worker_id      NUMBER := 1;

  ln_cnt_warnings     INTEGER := 0;
  ln_cnt_errors       INTEGER := 0;
  lb_request_status   BOOLEAN;
  lc_return_stat      VARCHAR2(2000);
  ln_fail_count     NUMBER := 0;

  ln_test_num NUMBER;

BEGIN

  MO_GLOBAL.init('AR');
  -- to check if the output directory exists
  -- read the variable request_data to check if it is reentering the program
  lc_req_data := FND_CONC_GLOBAL.request_data;
  ln_m_request_id := FND_GLOBAL.conc_request_id;

  IF (lc_req_data IS NULL) THEN
    -- read the user env language
    SELECT SUBSTR(userenv('LANG'),1,4)
    INTO   lc_userenv_lang
    FROM   SYS.DUAL;

    FND_FILE.put_line(FND_FILE.log,'User Lang ::'||lc_userenv_lang );
    BEGIN
	  SELECT fl.language_code
      INTO   lc_base_lang
      FROM   fnd_languages fl
      WHERE  fl.installed_flag = 'B';
    EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	    lc_base_lang := 'US';
	END;
    FND_FILE.put_line(FND_FILE.log,'Base Lang ::'||lc_base_lang);

    IF p_job_size > 0 THEN
      ln_job_size := p_job_size;
    END IF;

    ld_print_date_high := FND_DATE.canonical_to_date(p_print_date_high_in);
    ld_print_date_low  := FND_DATE.canonical_to_date(p_print_date_low_in);

    -- print out the input parameters;
    -- fetch a list of payment schedule id based on the inputted parameters
    -- AND insert into the ar_bpa_print_requests table

    lc_insert_stmt := '  INSERT INTO ar_bpa_print_requests (request_id, payment_schedule_id,
                      worker_id, created_by, creation_date,last_updated_by, last_update_date)';
    lc_select_stmt := '  SELECT  ' || ln_m_request_id || ', payment_schedule_id, ROWNUM, 1, SYSDATE, 1, SYSDATE FROM '
                   ||' ( SELECT apsa.payment_schedule_id '|| build_from_clause ||
                   '  AND NVL(hcasa.language,' || '''' || lc_base_lang || ''') = ' || '''' || lc_userenv_lang || '''' ;

    AR_BPA_PRINT_TRX.build_where_clause(p_org_id
  		      ,p_choice
  		      ,p_cust_trx_class
  		      ,p_trx_type_id
  		      ,p_trx_number_low
  		      ,p_trx_number_high
  		      ,p_doc_number_low
  		      ,p_doc_number_high
  		      ,ld_print_date_low
  		      ,ld_print_date_high
  		      ,p_customer_no_low
  		      ,p_customer_no_high
  		      ,p_customer_name_low
  		      ,p_customer_name_high
  		      ,'N'
  		      ,lc_where1) ;

    lc_sql_stmt := lc_insert_stmt || lc_select_stmt || lc_where1 || ')';

    IF ( ld_print_date_low IS NOT NULL OR  ld_print_date_high IS NOT NULL ) THEN
      AR_BPA_PRINT_TRX.build_where_clause(p_org_id
			,p_choice
            ,p_cust_trx_class
			,p_trx_type_id
			,p_trx_number_low
			,p_trx_number_high
    		,p_doc_number_low
  		    ,p_doc_number_high
			,ld_print_date_low
			,ld_print_date_high
			,p_customer_no_low
			,p_customer_no_high
			,p_customer_name_low
			,p_customer_name_high
			,'Y'
			,lc_where2);
      lc_sql_stmt := lc_sql_stmt || ' UNION ALL ' || lc_select_stmt || lc_where2 || ')';
    END IF;


    ------------------------------------------------
    -- Parse sql stmts
    ------------------------------------------------

    ln_sql_stmt_c:= DBMS_SQL.open_cursor;
    DBMS_SQL.parse( ln_sql_stmt_c, lc_sql_stmt , DBMS_SQL.v7 );
    AR_BPA_PRINT_TRX.bind_variables(p_org_id
                ,p_choice
                ,p_cust_trx_class
                ,p_trx_type_id
                ,p_trx_number_low
                ,p_trx_number_high
  		        ,p_doc_number_low
  		        ,p_doc_number_high
                ,ld_print_date_low
                ,ld_print_date_high
                ,p_customer_no_low
                ,p_customer_no_high
                ,p_customer_name_low
                ,p_customer_name_high
                ,'N'
                ,ln_sql_stmt_c );

     IF ( ld_print_date_low IS NOT NULL OR  ld_print_date_high IS NOT NULL ) THEN
       AR_BPA_PRINT_TRX.bind_variables(p_org_id
            ,p_choice
            ,p_cust_trx_class
            ,p_trx_type_id
            ,p_trx_number_low
            ,p_trx_number_high
  	        ,p_doc_number_low
            ,p_doc_number_high
            ,ld_print_date_low
            ,ld_print_date_high
            ,p_customer_no_low
            ,p_customer_no_high
            ,p_customer_name_low
            ,p_customer_name_high
            ,'Y'
            ,ln_sql_stmt_c );

      END IF;

      ln_inserted_row_counts := DBMS_SQL.execute(ln_sql_stmt_c);

      IF ln_inserted_row_counts > 0 THEN
        ln_divided_worker_counts := ceil(ln_inserted_row_counts/ln_job_size);
        ln_row_counts_perworker  := ceil(ln_inserted_row_counts/ln_divided_worker_counts);

        ln_worker_id  := 1 ;
        ln_low_range  := 1 ;
        ln_high_range := ln_row_counts_perworker ;

        LOOP
          UPDATE ar_bpa_print_requests
          SET    worker_id  = ln_worker_id
          WHERE  request_id = ln_m_request_id
          AND    worker_id BETWEEN  ln_low_range AND ln_high_range;

          IF ln_worker_id >= ln_divided_worker_counts THEN
            FND_MESSAGE.set_name('FND','CONC-DG-EXIT');
            lv_msg := FND_MESSAGE.get;
	    FND_FILE.put_line(FND_FILE.log,lv_msg);

            EXIT;
          END IF;

          ln_worker_id   :=  ln_worker_id  + 1;
          ln_low_range   :=  ln_low_range  + ln_row_counts_perworker ;
          ln_high_range  :=  ln_high_range + ln_row_counts_perworker ;

        END LOOP;
        COMMIT;  -- commit the record here

        FOR no_of_workers IN 1 .. ln_divided_worker_counts LOOP
          ln_request_id := AR_BPA_PRINT_TRX.submit_print_request(
                                           ln_m_request_id
                                          ,no_of_workers
                                          ,p_template_id
					  ,p_choice
                                          ,'Y'
                                          ,NULL
                                          ,'','', TRUE);

          IF (ln_request_id = 0) THEN
            FND_MESSAGE.retrieve(lc_return_stat);
            ln_fail_count := ln_fail_count + 1;
          ELSE
            COMMIT;
          END IF;

        END LOOP;

        FND_CONC_GLOBAL.set_req_globals(conc_status => 'PAUSED'
                                       ,request_data => to_char(ln_inserted_row_counts));
      END IF;

    ELSE
      IF ln_divided_worker_counts > 0 THEN
        DECLARE
          CURSOR child_request_cur(p_request_id IN NUMBER) IS
          SELECT fcr.request_id
		        ,fcr.status_code
          FROM   fnd_concurrent_requests fcr
          WHERE  fcr.parent_request_id = p_request_id;
        BEGIN
          FOR child_request_rec IN child_request_cur(ln_m_request_id)
          LOOP

            check_child_request(child_request_rec.request_id);
            IF (  child_request_rec.status_code ='G'
               OR child_request_rec.status_code ='X'
               OR child_request_rec.status_code ='D'
               OR child_request_rec.status_code ='T') THEN

              ln_cnt_warnings := ln_cnt_warnings + 1;
            ELSIF (child_request_rec.status_code = 'E') THEN
              ln_cnt_errors := ln_cnt_errors + 1;
            END IF;
          END LOOP;

          IF ((ln_cnt_errors >  0) OR ( ln_fail_count = ln_divided_worker_counts )) THEN
            lb_request_status := FND_CONCURRENT.set_completion_status('ERROR', '');
          ELSIF ((ln_cnt_warnings > 0) OR (ln_fail_count > 0)) THEN
            lb_request_status := FND_CONCURRENT.set_completion_status('WARNING', '');
          ELSE
            lb_request_status := FND_CONCURRENT.set_completion_status('NORMAL', '');
          END IF;
        END;
       END IF;

    DELETE FROM ar_bpa_print_requests
    WHERE request_id = ln_m_request_id;

    COMMIT;
     END IF;
END print_invoices;

END ar_bpa_print_trx;

/
