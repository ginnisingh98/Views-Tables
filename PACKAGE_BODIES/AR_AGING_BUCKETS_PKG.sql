--------------------------------------------------------
--  DDL for Package Body AR_AGING_BUCKETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_AGING_BUCKETS_PKG" AS
/* $Header: ARAGBKTB.pls 120.0.12010000.7 2009/10/29 11:43:39 tthangav noship $ */


PG_DEBUG                VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
PG_PARALLEL             VARCHAR2(1) := NVL(FND_PROFILE.value('AR_USE_PARALLEL_HINT'), 'N');
MAX_ARRAY_SIZE          BINARY_INTEGER := 1000 ;


--package constants
AR_AGING_CTGRY_INVOICE    VARCHAR2(20) := 'INVOICE';
AR_AGING_CTGRY_RECEIPT    VARCHAR2(20) := 'RECEIPT';
AR_AGING_CTGRY_RISK       VARCHAR2(20) := 'RISK';
AR_AGING_CTGRY_BR         VARCHAR2(20) := 'BILLS_RECEIVABLE';

pg_org_where_ps           VARCHAR2(2000) := NULL;
pg_org_where_gld          VARCHAR2(2000) := NULL;
pg_org_where_ct           VARCHAR2(2000) := NULL;
pg_org_where_sales        VARCHAR2(2000) := NULL;
pg_org_where_ct2          VARCHAR2(2000) := NULL;
pg_org_where_adj          VARCHAR2(2000) := NULL;
pg_org_where_app          VARCHAR2(2000) := NULL;
pg_org_where_crh          VARCHAR2(2000) := NULL;
pg_org_where_ra           VARCHAR2(2000) := NULL;
pg_org_where_cr           VARCHAR2(2000) := NULL;
pg_org_where_sys_param    VARCHAR2(2000) := NULL;
pg_bal_seg_where          VARCHAR2(2000) := NULL;


pg_rep_type                 VARCHAR2(30);
pg_reporting_level          VARCHAR2(30);
pg_reporting_entity_id      NUMBER;
pg_coaid                    NUMBER;
pg_in_bal_segment_low       VARCHAR2(30);
pg_in_bal_segment_high      VARCHAR2(30);
pg_in_as_of_date_low        DATE;
pg_in_summary_option_low    VARCHAR2(80);
pg_in_format_option_low     VARCHAR2(80);
pg_in_bucket_type_low       VARCHAR2(30);
pg_credit_option            VARCHAR2(80);
pg_risk_option              VARCHAR2(80);
pg_in_currency              VARCHAR2(20);
pg_in_customer_name_low     VARCHAR2(240);
pg_in_customer_name_high    VARCHAR2(240);
pg_in_customer_num_low      VARCHAR2(200);
pg_in_customer_num_high     VARCHAR2(200);
pg_in_amt_due_low           VARCHAR2(200);
pg_in_amt_due_high          VARCHAR2(200);
pg_in_invoice_type_low      VARCHAR2(500);
pg_in_invoice_type_high     VARCHAR2(500);
pg_in_collector_low         VARCHAR2(30);
pg_in_collector_high        VARCHAR2(30);
pg_retain_staging_flag      VARCHAR(1);
pg_cons_profile_value       VARCHAR2(1);
pg_accounting_method        VARCHAR2(30);


pg_accounting_flexfield    VARCHAR2(2000);

pg_acct_flex_bal_seg       VARCHAR2(2000);

pg_report_name             VARCHAR2(2000);
pg_segment_label           VARCHAR2(2000);
pg_bal_label               VARCHAR2(2000);
pg_label_1                 VARCHAR2(2000);
pg_sort_on                 VARCHAR2(2000);
pg_grand_total             VARCHAR2(2000);
pg_label                   VARCHAR2(2000);
pg_param_org_id            NUMBER;
pg_company_name            VARCHAR2(2000);
pg_functional_currency     VARCHAR2(2000);
pg_func_curr_precision     NUMBER;
pg_convert_flag            VARCHAR2(2000);
pg_set_of_books_id         NUMBER;
pg_in_sortoption           VARCHAR2(2000);
pg_request_id              NUMBER;
pg_parent_request_id       NUMBER := -1;
pg_worker_id               NUMBER := 1;
pg_worker_count            NUMBER := 1;
pg_short_unid_phrase       VARCHAR2(2000);
pg_payment_meaning         VARCHAR2(2000);
pg_risk_meaning            VARCHAR2(2000);

pg_reporting_entity_name   VARCHAR2(2000);
pg_reporting_level_name    VARCHAR2(2000);

pg_temp_site_use_id        NUMBER;
pg_temp_contact_phone      VARCHAR2(360);
pg_temp_contacts           VARCHAR2(360);
pg_temp_contact_name       HZ_PARTIES.PARTY_NAME%TYPE;

p_not_implemented_exp      EXCEPTION;

TYPE aging_mfar_tab IS TABLE OF ar_aging_mfar_extract%ROWTYPE INDEX BY BINARY_INTEGER;

TYPE req_status_type  IS RECORD (
  request_id       NUMBER(15),
  dev_phase        VARCHAR2(255),
  dev_status       VARCHAR2(255),
  message          VARCHAR2(2000),
  phase            VARCHAR2(255),
  status           VARCHAR2(255));
  l_org_id         NUMBER;

TYPE req_status_tab_type   IS TABLE OF req_status_type INDEX BY BINARY_INTEGER;

pg_req_status_tab   req_status_tab_type;


/*==========================================================================
| PRIVATE FUNCTION get_reporting_entity_id                                 |
|                                                                          |
| DESCRIPTION                                                              |
|                                                                          |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
FUNCTION get_reporting_entity_id RETURN NUMBER is
BEGIN
    return pg_reporting_entity_id;
END get_reporting_entity_id;




PROCEDURE print_clob( p_clob IN CLOB) IS
  l_offset NUMBER DEFAULT 1;
BEGIN
  BEGIN
    LOOP
      EXIT WHEN l_offset > dbms_lob.getlength(p_clob);
      arp_standard.debug(  dbms_lob.substr( p_clob, 255, l_offset ) );
      l_offset := l_offset + 255;
    END LOOP;

  EXCEPTION
     WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug(  ' Exception '||SQLERRM);
	arp_standard.debug(  ' Exception print_clob()');
      END IF;
  END;
END print_clob;



/*==========================================================================
| PRIVATE FUNCTION get_report_heading                                      |
|                                                                          |
| DESCRIPTION                                                              |
|      Returns bucket related headers to be used in report display         |
|                                                                          |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
FUNCTION get_report_heading RETURN VARCHAR2 IS
  CURSOR buc_info_cur IS
    select report_heading1,
           report_heading2
    from ar_aging_bucket_lines lines,
         ar_aging_buckets buckets
    where lines.aging_bucket_id = buckets.aging_bucket_id
    and   UPPER(buckets.bucket_name) = UPPER(pg_in_bucket_type_low)
    and   NVL(buckets.status,'A') = 'A'
    order by lines.bucket_sequence_num;

l_report_heading  VARCHAR2(32767) := '';
i	          NUMBER(1)       := 0;
l_new_line        VARCHAR2(1)     := '
';

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.get_report_heading()+');
  END IF;

  FOR buc_rec IN buc_info_cur LOOP
    IF buc_rec.report_heading2 IS NULL THEN
	l_report_heading := l_report_heading ||l_new_line||
		 '<HEAD_TOP_'||i||'></HEAD_TOP_'||i||'>';
	    l_report_heading := l_report_heading ||l_new_line||
		 '<HEAD_BOT_'||i||'>'||buc_rec.report_heading1||'</HEAD_BOT_'||i||'>';
    ELSE
	    l_report_heading := l_report_heading ||l_new_line||
		 '<HEAD_TOP_'||i||'>'||buc_rec.report_heading1||'</HEAD_TOP_'||i||'>';
	    l_report_heading := l_report_heading ||l_new_line||
		 '<HEAD_BOT_'||i||'>'||buc_rec.report_heading2||'</HEAD_BOT_'||i||'>';
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(  'report_heading1: '||buc_rec.report_heading1);
      arp_standard.debug(  'report_heading2: '||buc_rec.report_heading2);
    END IF;

    i := i + 1;

  END LOOP;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.get_report_heading()-');
  END IF;

  RETURN l_report_heading;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug(  ' Exception '||SQLERRM);
	arp_standard.debug(  ' Exception AR_AGING_BUCKETS_PKG.get_report_heading()');
      END IF;
      RAISE;
END get_report_heading;




/*==========================================================================
| PRIVATE FUNCTION get_parent_request_id                                   |
|                                                                          |
| DESCRIPTION                                                              |
|                                                                          |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  p_request_id                                                            |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
FUNCTION get_parent_request_id(p_request_id NUMBER) RETURN NUMBER IS
  l_request_id NUMBER;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.get_parent_request_id()+');
    arp_standard.debug(  'p_request_id :'||p_request_id);
  END IF;

  SELECT parent_request_id
  INTO   l_request_id
  FROM fnd_concurrent_requests child
  WHERE child.request_id = p_request_id;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'Return value :'||l_request_id);
  END IF;

  RETURN l_request_id;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug(  ' Exception '||SQLERRM);
	arp_standard.debug(  ' Exception AR_AGING_BUCKETS_PKG.get_parent_request_id()');
      END IF;
      RAISE;
END get_parent_request_id;




/*==========================================================================
| PRIVATE FUNCTION get_contact_information                                 |
|                                                                          |
| DESCRIPTION                                                              |
|  Returns contact information  associated to given site,return values     |
|  also depends on what sort of information is requested                   |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  p_site_use_id                                                           |
|  p_info_type  -possible values are NAME and PHONE                        |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
FUNCTION get_contact_information( p_site_use_id NUMBER,
                                  p_info_type   VARCHAR2) RETURN VARCHAR2 IS

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'AR_AGING_BUCKETS_PKG.get_contact_information()+');
    arp_standard.debug( 'p_site_use_id         :'||p_site_use_id);
    arp_standard.debug( 'p_info_type           :'||p_info_type);
    arp_standard.debug( 'pg_temp_site_use_id   :'||pg_temp_site_use_id);
  END IF;

  IF p_site_use_id IS NULL THEN
    RETURN NULL;
  END IF;

  IF NVL(pg_temp_site_use_id,-99999) <> p_site_use_id THEN

    pg_temp_site_use_id    := p_site_use_id;
    pg_temp_contact_name   := NULL;
    pg_temp_contact_phone  := NULL;
    pg_temp_contacts       := NULL;

    BEGIN
      select RTRIM(RPAD(substrb(party.person_first_name,1,40), 1)) ||
	      decode( substrb(party.person_first_name,1,40),
		     NULL, NULL,
		     decode( substrb(party.person_last_name,1,50),
			     NULL, NULL,
			     '. ' )) ||
	      RTRIM(RPAD( substrb(party.person_last_name,1,50), 17)),
	  cont_point.phone_area_code  ||
	      ' ' ||
	      RTRIM(RPAD( decode(cont_point.contact_point_type,
				 'TLX', cont_point.telex_number,
				 cont_point.phone_number) , 15)),
	  decode(substrb(party.person_first_name,1,40),
		 NULL, decode( substrb(party.person_last_name,1,50),
			     NULL, decode( cont_point.phone_area_code,
					   NULL, NULL,
					   'Y' ),
			     decode( decode(cont_point.contact_point_type,
					     'TLX', cont_point.telex_number,
					    cont_point.phone_number),
				     NULL, NULL,
				    'Y' ),
			'Y' ),
		'Y')
      into  pg_temp_contact_name,
	    pg_temp_contact_phone,
	    pg_temp_contacts
      from  hz_cust_account_roles acct_role,
	    hz_parties  party,
	    hz_relationships rel,
	    hz_contact_points cont_point,
	    hz_cust_account_roles car,
	    hz_cust_site_uses_all site_uses
      where   site_uses.site_use_id = p_site_use_id
      and   site_uses.cust_acct_site_id  = acct_role.cust_acct_site_id(+)
      and   acct_role.party_id = rel.party_id(+)
      and	rel.subject_table_name(+) = 'HZ_PARTIES'
      and 	rel.object_table_name(+) = 'HZ_PARTIES'
      and   rel.directional_flag(+) = 'F'
      and   acct_role.role_type = 'CONTACT'
      and   rel.subject_id = party.party_id(+)
      and   acct_role.cust_account_role_id = car.cust_account_role_id(+)
      and   car.party_id = cont_point.owner_table_id(+)
      and   cont_point.owner_table_name(+) = 'HZ_PARTIES'
      and   NVL(cont_point.contact_point_type(+),'N') not in ('EDI','EMAIL','WEB')
      and   nvl( nvl(cont_point.phone_line_type(+),
		     cont_point.contact_point_type(+)), 'GEN') = 'GEN'
      and   nvl(acct_role.status,'A') = 'A'
      and   nvl(cont_point.status(+),'A') = 'A'
      and   rownum = 1;

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug( 'Exception message '||SQLERRM);
      END IF;
    END;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'pg_temp_contact_name  '||pg_temp_contact_name);
    arp_standard.debug( 'pg_temp_contact_phone '||pg_temp_contact_phone);
    arp_standard.debug( 'AR_AGING_BUCKETS_PKG.get_contact_information()-');
  END IF;

  IF p_info_type    = 'NAME' THEN
    RETURN pg_temp_contact_name;
  ELSE
    RETURN pg_temp_contact_phone;
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(  'Exception message '||SQLERRM);
      arp_standard.debug(  'Exception AR_AGING_BUCKETS_PKG.get_contact_information()');
    END IF;
    RETURN NULL;
END get_contact_information;




/*==========================================================================
| PRIVATE FUNCTION get_report_query                                        |
|                                                                          |
| DESCRIPTION                                                              |
| Report                                                                   |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
FUNCTION get_report_query RETURN VARCHAR2 IS

l_report_query    VARCHAR2(32000);
l_filter_criteria VARCHAR2(32000);

BEGIN
  l_filter_criteria := ' and ext.parent_request_id = '||pg_request_id;

  IF pg_in_amt_due_low IS NOT NULL THEN
   l_filter_criteria := l_filter_criteria||'
                        and ext.amt_due_remaining >= '||pg_in_amt_due_low;
  END IF;

  IF pg_in_amt_due_high IS NOT NULL THEN
   l_filter_criteria := l_filter_criteria||'
                       and ext.amt_due_remaining <= '||pg_in_amt_due_high;
  END IF;

  IF pg_accounting_method = 'MFAR' THEN
    IF pg_in_bal_segment_low IS NOT NULL THEN
     l_filter_criteria := l_filter_criteria||' and NVL(mfar.bal_segment_value,ext.bal_segment_value) >= '''||pg_in_bal_segment_low||'''';
    END IF;

    IF pg_in_bal_segment_high IS NOT NULL THEN
     l_filter_criteria := l_filter_criteria||' and NVL(mfar.bal_segment_value,ext.bal_segment_value ) <= '''||pg_in_bal_segment_high||'''';
    END IF;
  ELSE
    IF pg_in_bal_segment_low IS NOT NULL THEN
     l_filter_criteria := l_filter_criteria||' and ext.bal_segment_value >= '''||pg_in_bal_segment_low||'''';
    END IF;

    IF pg_in_bal_segment_high IS NOT NULL THEN
     l_filter_criteria := l_filter_criteria||' and ext.bal_segment_value <= '''||pg_in_bal_segment_high||'''';
    END IF;
  END IF;

  IF pg_accounting_method = 'MFAR' AND
     pg_rep_type          = 'ARXAGF' THEN

    IF pg_in_summary_option_low ='C' THEN
	l_report_query := '
	     select customer_id,
		customer_number,
		short_customer_name customer_name,
		sort_field1,
		inv_tid_inv,
		contact_site_id,
		customer_state,
		customer_city,
		cust_acct_site_id,
		sum(customer_amount ) customer_total,
		sum( risk_amount ) risk_total,
		sum( pmt_amount ) pmt_total,
		sum( cm_amount ) cm_total,
		sum( claim_amount ) claim_total,
		sum( inv_amount ) inv_total,
		data_converted_flag,
		SUM( bucket_0 ) b_0,
		SUM( bucket_1 ) b_1,
		SUM( bucket_2 ) b_2,
		SUM( bucket_3 ) b_3,
		SUM( bucket_4 ) b_4,
		SUM( bucket_5 ) b_5,
		SUM( bucket_6 ) b_6,
		bal_segment_value,
		contact_name,
		contact_phone
	    from
	    ( select
		ext.customer_id,
		ext.customer_number,
		ext.short_customer_name,
		NVL(mfar.sort_field1,ext.sort_field1) sort_field1,
		ext.sort_field2,
		ext.inv_tid_inv,
		ext.contact_site_id,
		ext.customer_state,
		ext.customer_city,
		ext.cust_acct_site_id,
		mfar.rec_aging_amount,
		ext.amt_due_remaining,
		nvl(mfar.rec_aging_amount,ext.amt_due_remaining)                         customer_amount,
		decode(class,'''|| pg_risk_meaning ||''',nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0)  risk_amount,
		decode(class,''PMT'',nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0)   pmt_amount,
		decode(class,''CM'',nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0)    cm_amount,
		decode(class,''CLAIM'',nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0) claim_amount,
		decode(class,'''|| pg_risk_meaning ||''',0,
				  ''PMT'',0,
				  ''CM'',0,
				  ''CLAIM'',0,nvl(mfar.rec_aging_amount,ext.amt_due_remaining)) inv_amount,
		ext.data_converted_flag,
		ext.exchange_rate,
		DECODE(bucket_0,0,0,
		       DECODE(class,'''|| pg_risk_meaning ||''',
		                              DECODE( '''|| pg_risk_option||''',''DETAIL'',
					              nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''PMT'', DECODE( '''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''CM'',  DECODE( '''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''CLAIM'',DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     nvl(mfar.rec_aging_amount,ext.amt_due_remaining) )) bucket_0,
		DECODE(bucket_1,0,0,
		       DECODE(class,'''|| pg_risk_meaning ||''',
		                               DECODE('''|| pg_risk_option||''',''DETAIL'',
					              nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''PMT'',  DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''CM'',   DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''CLAIM'',DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     nvl(mfar.rec_aging_amount,ext.amt_due_remaining) )) bucket_1,
		DECODE(bucket_2,0,0,
		       DECODE(class,'''|| pg_risk_meaning ||''',
		                              DECODE('''|| pg_risk_option||''',''DETAIL'',
					            nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''PMT'', DECODE('''|| pg_credit_option||''',''DETAIL'',
				                   nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''CM'',  DECODE('''|| pg_credit_option||''',''DETAIL'',
				                   nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''CLAIM'',DECODE('''|| pg_credit_option||''',''DETAIL'',
				                   nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     nvl(mfar.rec_aging_amount,ext.amt_due_remaining) )) bucket_2,
		DECODE(bucket_3,0,0,
		       DECODE(class,'''|| pg_risk_meaning ||''',
		                              DECODE('''|| pg_risk_option||''',''DETAIL'',
					              nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''PMT'', DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''CM'',  DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''CLAIM'',DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     nvl(mfar.rec_aging_amount,ext.amt_due_remaining) )) bucket_3,
		DECODE(bucket_4,0,0,
		       DECODE(class,'''|| pg_risk_meaning ||''',
		                              DECODE('''|| pg_risk_option||''',''DETAIL'',
					              nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''PMT'', DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''CM'',  DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''CLAIM'',DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     nvl(mfar.rec_aging_amount,ext.amt_due_remaining) )) bucket_4,
		DECODE(bucket_5,0,0,
		       DECODE(class,'''|| pg_risk_meaning ||''',
		                              DECODE('''|| pg_risk_option||''',''DETAIL'',
					              nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''PMT'', DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''CM'',  DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''CLAIM'',DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     nvl(mfar.rec_aging_amount,ext.amt_due_remaining) )) bucket_5,
		DECODE(bucket_6,0,0,
		       DECODE(class,'''|| pg_risk_meaning ||''',
		                              DECODE('''|| pg_risk_option||''',''DETAIL'',
					              nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''PMT'', DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''CM'',  DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     ''CLAIM'',DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      nvl(mfar.rec_aging_amount,ext.amt_due_remaining),0),
				     nvl(mfar.rec_aging_amount,ext.amt_due_remaining) )) bucket_6,
		DECODE(mfar.bal_segment_value,null,ext.bal_segment_value,
		                              mfar.bal_segment_value) bal_segment_value,
		ext.contact_name,
		ext.contact_phone
	    from ar_aging_extract ext,
	    ( select mfar.*,
		    '||pg_accounting_flexfield||' sort_field1,
		    '||pg_acct_flex_bal_seg||' bal_segment_value
	      from ar_aging_mfar_extract mfar,
		   gl_code_combinations c
	      where c.code_combination_id = mfar.code_combination_id
	     ) mfar
	    where ext.parent_request_id = mfar.parent_request_id(+)
	    and ext.payment_schedule_id = mfar.payment_schedule_id(+)
	    '||l_filter_criteria||'
	    )
	    group by customer_id,
		customer_number,
		short_customer_name,
		sort_field1,
		inv_tid_inv,
		contact_site_id,
		customer_state,
		customer_city,
		cust_acct_site_id,
		data_converted_flag,
		contact_name,
		contact_phone,
		bal_segment_value,
		rec_aging_amount
		having sum(nvl(rec_aging_amount,amt_due_remaining)) <> 0';
    ELSE
	l_report_query := '
	    SELECT ext.customer_id,
	    ext.customer_number,
	    ext.short_customer_name customer_name,
	    NVL(mfar.sort_field1,ext.sort_field1) sort_field1,
	    ext.sort_field2,
	    ext.inv_tid_inv,
	    ext.contact_site_id,
	    ext.customer_state,
	    ext.customer_city,
	    ext.cust_acct_site_id,
	    ext.payment_schedule_id,
	    ext.class,
	    TO_CHAR(ext.due_date,''YYYY-MM-DD'') due_date,
	    nvl(mfar.rec_aging_amount,ext.amt_due_remaining) amt_due_remaining,
	    ext.trx_number,
	    ext.days_past_due,
	    TO_CHAR(ext.gl_date,''YYYY-MM-DD'') gl_date,
	    ext.data_converted_flag,
	    ext.exchange_rate,
	    DECODE(bucket_0,0,0,nvl(mfar.rec_aging_amount,ext.amt_due_remaining)) b_0,
	    DECODE(bucket_1,0,0,nvl(mfar.rec_aging_amount,ext.amt_due_remaining)) b_1,
	    DECODE(bucket_2,0,0,nvl(mfar.rec_aging_amount,ext.amt_due_remaining)) b_2,
	    DECODE(bucket_3,0,0,nvl(mfar.rec_aging_amount,ext.amt_due_remaining)) b_3,
	    DECODE(bucket_4,0,0,nvl(mfar.rec_aging_amount,ext.amt_due_remaining)) b_4,
	    DECODE(bucket_5,0,0,nvl(mfar.rec_aging_amount,ext.amt_due_remaining)) b_5,
	    DECODE(bucket_6,0,0,nvl(mfar.rec_aging_amount,ext.amt_due_remaining)) b_6,
            DECODE(mfar.bal_segment_value,null,ext.bal_segment_value,
		                mfar.bal_segment_value) bal_segment_value,
	    ext.invoice_type,
	    ext.cons_billing_number,
	    ext.contact_name,
	    ext.contact_phone
	    from ar_aging_extract ext,
		 ( select mfar.*,
			  '||pg_accounting_flexfield||' sort_field1,
		          '||pg_acct_flex_bal_seg||' bal_segment_value
	            from ar_aging_mfar_extract mfar,
			 gl_code_combinations c
		   where c.code_combination_id = mfar.code_combination_id ) mfar
	    where ext.parent_request_id = mfar.parent_request_id(+)
            and ext.payment_schedule_id = mfar.payment_schedule_id(+)
	    and nvl(mfar.rec_aging_amount,ext.amt_due_remaining) <> 0
	    '||l_filter_criteria;
    END IF;
  ELSE
    IF pg_in_summary_option_low ='C' THEN
	l_report_query := '
	    select customer_id,
		customer_number,
		short_customer_name customer_name,
		sort_field1,
		inv_tid_inv,
		contact_site_id,
		customer_state,
		customer_city,
		cust_acct_site_id,
		sum(customer_amount ) customer_total,
		sum( risk_amount ) risk_total,
		sum( pmt_amount ) pmt_total,
		sum( cm_amount ) cm_total,
		sum( claim_amount ) claim_total,
		sum( inv_amount ) inv_total,
		data_converted_flag,
		SUM( bucket_0 ) b_0,
		SUM( bucket_1 ) b_1,
		SUM( bucket_2 ) b_2,
		SUM( bucket_3 ) b_3,
		SUM( bucket_4 ) b_4,
		SUM( bucket_5 ) b_5,
		SUM( bucket_6 ) b_6,
		bal_segment_value,
		contact_name,
		contact_phone
	    from
	    ( select
		ext.customer_id,
		ext.customer_number,
		ext.short_customer_name,
		ext.sort_field1 sort_field1,
		ext.sort_field2,
		ext.inv_tid_inv,
		ext.contact_site_id,
		ext.customer_state,
		ext.customer_city,
		ext.cust_acct_site_id,
		ext.amt_due_remaining,
		ext.amt_due_remaining                         customer_amount,
		decode(class,'''|| pg_risk_meaning ||''',ext.amt_due_remaining,0)  risk_amount,
		decode(class,''PMT'',ext.amt_due_remaining,0)   pmt_amount,
		decode(class,''CM'',ext.amt_due_remaining,0)    cm_amount,
		decode(class,''CLAIM'',ext.amt_due_remaining,0) claim_amount,
		decode(class,'''|| pg_risk_meaning ||''',0,
				  ''PMT'',0,
				  ''CM'',0,
				  ''CLAIM'',0,ext.amt_due_remaining) inv_amount,
		ext.data_converted_flag,
		ext.exchange_rate,
		DECODE(bucket_0,0,0,
		       DECODE(class,'''|| pg_risk_meaning ||''',
		                              DECODE( '''|| pg_risk_option||''',''DETAIL'',
					              ext.amt_due_remaining,0),
				     ''PMT'', DECODE( '''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ''CM'',  DECODE( '''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ''CLAIM'',DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ext.amt_due_remaining )) bucket_0,
		DECODE(bucket_1,0,0,
		       DECODE(class,'''|| pg_risk_meaning ||''',
		                               DECODE('''|| pg_risk_option||''',''DETAIL'',
					              ext.amt_due_remaining,0),
				     ''PMT'',  DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ''CM'',   DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ''CLAIM'',DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ext.amt_due_remaining )) bucket_1,
		DECODE(bucket_2,0,0,
		       DECODE(class,'''|| pg_risk_meaning ||''',
		                              DECODE('''|| pg_risk_option||''',''DETAIL'',
					            ext.amt_due_remaining,0),
				     ''PMT'', DECODE('''|| pg_credit_option||''',''DETAIL'',
				                   ext.amt_due_remaining,0),
				     ''CM'',  DECODE('''|| pg_credit_option||''',''DETAIL'',
				                   ext.amt_due_remaining,0),
				     ''CLAIM'',DECODE('''|| pg_credit_option||''',''DETAIL'',
				                   ext.amt_due_remaining,0),
				     ext.amt_due_remaining )) bucket_2,
		DECODE(bucket_3,0,0,
		       DECODE(class,'''|| pg_risk_meaning ||''',
		                              DECODE('''|| pg_risk_option||''',''DETAIL'',
					              ext.amt_due_remaining,0),
				     ''PMT'', DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ''CM'',  DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ''CLAIM'',DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ext.amt_due_remaining )) bucket_3,
		DECODE(bucket_4,0,0,
		       DECODE(class,'''|| pg_risk_meaning ||''',
		                              DECODE('''|| pg_risk_option||''',''DETAIL'',
					              ext.amt_due_remaining,0),
				     ''PMT'', DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ''CM'',  DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ''CLAIM'',DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ext.amt_due_remaining )) bucket_4,
		DECODE(bucket_5,0,0,
		       DECODE(class,'''|| pg_risk_meaning ||''',
		                              DECODE('''|| pg_risk_option||''',''DETAIL'',
					              ext.amt_due_remaining,0),
				     ''PMT'', DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ''CM'',  DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ''CLAIM'',DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ext.amt_due_remaining )) bucket_5,
		DECODE(bucket_6,0,0,
		       DECODE(class,'''|| pg_risk_meaning ||''',
		                              DECODE('''|| pg_risk_option||''',''DETAIL'',
					              ext.amt_due_remaining,0),
				     ''PMT'', DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ''CM'',  DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ''CLAIM'',DECODE('''|| pg_credit_option||''',''DETAIL'',
				                      ext.amt_due_remaining,0),
				     ext.amt_due_remaining )) bucket_6,
		bal_segment_value,
		ext.contact_name,
		ext.contact_phone
	    from ar_aging_extract ext
	    where 1 = 1
	    '||l_filter_criteria||'
	    )
	    group by customer_id,
		customer_number,
		short_customer_name,
		sort_field1,
		inv_tid_inv,
		contact_site_id,
		customer_state,
		customer_city,
		cust_acct_site_id,
		data_converted_flag,
		contact_name,
		contact_phone,
		bal_segment_value
		having sum(amt_due_remaining) <> 0';
    ELSE
	l_report_query := '
	    SELECT customer_id,
	    customer_number,
	    short_customer_name customer_name,
	    sort_field1,
	    sort_field2,
	    inv_tid_inv,
	    contact_site_id,
	    customer_state,
	    customer_city,
	    cust_acct_site_id,
	    payment_schedule_id,
	    class,
	    TO_CHAR(due_date,''YYYY-MM-DD'') due_date,
	    amt_due_remaining,
	    trx_number,
	    days_past_due,
	    TO_CHAR(gl_date,''YYYY-MM-DD'') gl_date,
	    gl_date,
	    data_converted_flag,
	    exchange_rate,
	    DECODE(bucket_0,0,0,amt_due_remaining) b_0,
	    DECODE(bucket_1,0,0,amt_due_remaining) b_1,
	    DECODE(bucket_2,0,0,amt_due_remaining) b_2,
	    DECODE(bucket_3,0,0,amt_due_remaining) b_3,
	    DECODE(bucket_4,0,0,amt_due_remaining) b_4,
	    DECODE(bucket_5,0,0,amt_due_remaining) b_5,
	    DECODE(bucket_6,0,0,amt_due_remaining) b_6,
	    bal_segment_value,
	    invoice_type,
	    cons_billing_number,
	    contact_name,
	    contact_phone
	    from ar_aging_extract ext
	    where 1=1 '||l_filter_criteria;
    END IF;
  END IF;

  RETURN l_report_query;
END get_report_query;




/*==========================================================================
| PRIVATE FUNCTION get_report_header_xml                                   |
|                                                                          |
| DESCRIPTION                                                              |
|                                                                          |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
FUNCTION get_report_header_xml RETURN VARCHAR2 IS
l_message    VARCHAR2(2000);
l_xml_header VARCHAR2(32000);

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.get_report_header_xml()+');
  END IF;

  IF to_number(pg_reporting_level) = 1000 AND
     mo_utils.check_ledger_in_sp(TO_NUMBER(pg_reporting_entity_id)) = 'N' THEN
    FND_MESSAGE.SET_NAME('FND','FND_MO_RPT_PARTIAL_LEDGER');
    l_message := FND_MESSAGE.get;
  END IF;

  l_xml_header := '<?xml version="1.0" encoding="'||fnd_profile.value('ICX_CLIENT_IANA_ENCODING')||'"?>
<ARAGEREP>
<MSG_TXT>'||l_message||'</MSG_TXT>
<COMPANY_NAME>'||pg_company_name||'</COMPANY_NAME>
<REPORTING_LEVEL>'||pg_reporting_level_name||'</REPORTING_LEVEL>
<REPORTING_ENTITY>'||pg_reporting_entity_name||'</REPORTING_ENTITY>
<BAL_SEG_LOW>'||pg_in_bal_segment_low||'</BAL_SEG_LOW>
<BAL_SEG_HIGH>'||pg_in_bal_segment_high||'</BAL_SEG_HIGH>
<AS_OF_GL_DATE>'||TO_CHAR(pg_in_as_of_date_low,'YYYY-MM-DD')||'</AS_OF_GL_DATE>
<SUMMARY_TYPE>'||pg_in_summary_option_low||'</SUMMARY_TYPE>
<SUMMARY_TYPE_MEANING>'||ARPT_SQL_FUNC_UTIL.get_lookup_meaning('REPORT_TYPE',pg_in_summary_option_low)||'</SUMMARY_TYPE_MEANING>
<REPORT_FORMAT>'||pg_in_format_option_low||'</REPORT_FORMAT>
<REPORT_FORMAT_MEANING>'||ARPT_SQL_FUNC_UTIL.get_lookup_meaning('REPORT_FORMAT',pg_in_format_option_low)||'</REPORT_FORMAT_MEANING>
<BUCKET_NAME>'||pg_in_bucket_type_low||'</BUCKET_NAME>
<CREDIT_OPTION>'||pg_credit_option||'</CREDIT_OPTION>
<CREDIT_OPTION_MEANING>'||ARPT_SQL_FUNC_UTIL.get_lookup_meaning('OPEN_CREDITS',pg_credit_option)||'</CREDIT_OPTION_MEANING>
<RISK_OPTION>'||pg_risk_option||'</RISK_OPTION>
<RISK_OPTION_MEANING>'||ARPT_SQL_FUNC_UTIL.get_lookup_meaning('SHOW_RISK',pg_risk_option)||'</RISK_OPTION_MEANING>
<CURRENCY>'||pg_in_currency||'</CURRENCY>
<CUST_NAME_LOW>'||pg_in_customer_name_low||'</CUST_NAME_LOW>
<CUST_NAME_HIGH>'||pg_in_customer_name_high||'</CUST_NAME_HIGH>
<CUST_NUM_LOW>'||pg_in_customer_num_low||'</CUST_NUM_LOW>
<CUST_NUM_HIGH>'||pg_in_customer_num_high||'</CUST_NUM_HIGH>
<AMT_DUE_LOW>'||pg_in_amt_due_low||'</AMT_DUE_LOW>
<AMT_DUE_HIGH>'||pg_in_amt_due_high||'</AMT_DUE_HIGH>
<INV_TYPE_LOW>'||pg_in_invoice_type_low||'</INV_TYPE_LOW>
<INV_TYPE_HIGH>'||pg_in_invoice_type_high||'</INV_TYPE_HIGH>
<CONS_PROFILE_VALUE>'||pg_cons_profile_value||'</CONS_PROFILE_VALUE>
<FUNC_CURRENCY>'||pg_functional_currency||'</FUNC_CURRENCY>
<RISK_MEANING>'||pg_risk_meaning||'</RISK_MEANING>'||AR_AGING_BUCKETS_PKG.get_report_heading();

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.get_report_header_xml()-');
  END IF;

  RETURN l_xml_header;

  EXCEPTION
   WHEN OTHERS THEN
    arp_standard.debug(  'Exception message '||SQLERRM);
    arp_standard.debug(  'Exception AR_AGING_BUCKETS_PKG.get_report_header_xml()');
    RETURN NULL;
END get_report_header_xml;




/*==========================================================================
| PRIVATE PROCEDURE populate_setup_information                             |
|                                                                          |
| DESCRIPTION                                                              |
|      Populates setup related info to local variables                     |
|                                                                          |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
PROCEDURE populate_setup_information IS
l_sys_query VARCHAR2(20000);

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  ' AR_AGING_BUCKETS_PKG.populate_setup_information()+');
  END IF;

  l_sys_query := '
        SELECT  param.org_id,
	  sob.name,
	  sob.chart_of_accounts_id,
	  sob.currency_code,
	  cur.precision,
	  decode(:p_in_currency,NULL,''Y'',NULL),
	  param.set_of_books_id
	FROM gl_sets_of_books sob,
             ar_system_parameters_all param,
             fnd_currencies cur
        WHERE  sob.set_of_books_id = param.set_of_books_id
        AND  sob.currency_code = cur.currency_code
	AND  rownum = 1
	'||pg_org_where_sys_param;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  ' l_sys_query  :'||l_sys_query);
  END IF;

  EXECUTE IMMEDIATE l_sys_query
  INTO pg_param_org_id,
       pg_company_name,
       pg_coaid,
       pg_functional_currency,
       pg_func_curr_precision,
       pg_convert_flag,
       pg_set_of_books_id
  USING  pg_in_currency;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  ' Rows returned  '||SQL%ROWCOUNT);
    arp_standard.debug(  ' AR_AGING_BUCKETS_PKG.populate_setup_information()+');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug(  ' Exception '||SQLERRM);
	arp_standard.debug(  ' Exception AR_AGING_BUCKETS_PKG.populate_setup_information()');
      END IF;
      RAISE;
END populate_setup_information;





/*==========================================================================
| PRIVATE PROCEDURE initialize_package_globals                             |
|                                                                          |
| DESCRIPTION                                                              |
|      Populates reporting entity criteria strings,balancing segment info  |
|     and other message info required                                      |
|                                                                          |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
PROCEDURE initialize_package_globals IS
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  ' AR_AGING_BUCKETS_PKG.initialize_package_globals()+');
  END IF;

  XLA_MO_REPORTING_API.Initialize(pg_reporting_level, pg_reporting_entity_id, 'AUTO');

  pg_reporting_entity_name := substrb(XLA_MO_REPORTING_API.get_reporting_entity_name,1,80);
  pg_reporting_level_name  := substrb(XLA_MO_REPORTING_API.get_reporting_level_name,1,30);

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  ' pg_reporting_entity_name  '||pg_reporting_entity_name );
    arp_standard.debug(  ' pg_reporting_level_name   '||pg_reporting_level_name );
  END IF;

  pg_org_where_ps    := XLA_MO_REPORTING_API.Get_Predicate('ps', 'push_subq');
  pg_org_where_gld   := XLA_MO_REPORTING_API.Get_Predicate('gld', 'push_subq');
  pg_org_where_ct    := XLA_MO_REPORTING_API.Get_Predicate('ct', 'push_subq');
  pg_org_where_sales := XLA_MO_REPORTING_API.Get_Predicate('sales', 'push_subq');
  pg_org_where_ct2   := XLA_MO_REPORTING_API.Get_Predicate('ct2', 'push_subq');
  pg_org_where_adj   := XLA_MO_REPORTING_API.Get_Predicate('adj', 'push_subq');
  pg_org_where_app   := XLA_MO_REPORTING_API.Get_Predicate('app', 'push_subq');
  pg_org_where_crh   := XLA_MO_REPORTING_API.Get_Predicate('crh', 'push_subq');
  pg_org_where_ra    := XLA_MO_REPORTING_API.Get_Predicate('app', 'push_subq');
  pg_org_where_cr    := XLA_MO_REPORTING_API.Get_Predicate('cr', 'push_subq');
  pg_org_where_sys_param := XLA_MO_REPORTING_API.Get_Predicate('PARAM',null);


  /* Replace the variables to bind with the function calls so that we don't have to bind those */
  pg_org_where_ps    := replace(pg_org_where_ps,
                                  ':p_reporting_entity_id','AR_AGING_BUCKETS_PKG.get_reporting_entity_id()');
  pg_org_where_gld   := replace(pg_org_where_gld,
                                  ':p_reporting_entity_id','AR_AGING_BUCKETS_PKG.get_reporting_entity_id()');
  pg_org_where_ct    := replace(pg_org_where_ct,
                                  ':p_reporting_entity_id','AR_AGING_BUCKETS_PKG.get_reporting_entity_id()');
  pg_org_where_sales := replace(pg_org_where_sales,
                                  ':p_reporting_entity_id','AR_AGING_BUCKETS_PKG.get_reporting_entity_id()');
  pg_org_where_ct2   := replace(pg_org_where_ct2,
                                  ':p_reporting_entity_id','AR_AGING_BUCKETS_PKG.get_reporting_entity_id()');
  pg_org_where_adj   := replace(pg_org_where_adj,
                                  ':p_reporting_entity_id','AR_AGING_BUCKETS_PKG.get_reporting_entity_id()');
  pg_org_where_app   := replace(pg_org_where_app,
                                  ':p_reporting_entity_id','AR_AGING_BUCKETS_PKG.get_reporting_entity_id()');
  pg_org_where_crh   := replace(pg_org_where_crh,
                                  ':p_reporting_entity_id','AR_AGING_BUCKETS_PKG.get_reporting_entity_id()');
  pg_org_where_ra    := replace(pg_org_where_ra,
                                  ':p_reporting_entity_id','AR_AGING_BUCKETS_PKG.get_reporting_entity_id()');
  pg_org_where_cr    := replace(pg_org_where_cr,
                                  ':p_reporting_entity_id','AR_AGING_BUCKETS_PKG.get_reporting_entity_id()');
  pg_org_where_sys_param := replace(pg_org_where_sys_param,
                                  ':p_reporting_entity_id','AR_AGING_BUCKETS_PKG.get_reporting_entity_id()');

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  ' Populating balancing segment strings.. ');
  END IF;

  IF pg_in_bal_segment_low IS NULL AND pg_in_bal_segment_high IS NULL THEN
    pg_bal_seg_where := NULL;
  ELSIF pg_in_bal_segment_low IS NULL THEN
    pg_bal_seg_where := ' AND ' ||
	   ar_calc_aging.FLEX_SQL(p_application_id => 101,
			   p_id_flex_code => 'GL#',
			   p_id_flex_num =>pg_coaid,
			   p_table_alias => 'GC',
			   p_mode => 'WHERE',
			   p_qualifier => 'GL_BALANCING',
			   p_function => '<=',
			   p_operand1 => pg_in_bal_segment_high);
  ELSIF pg_in_bal_segment_high IS NULL THEN
    pg_bal_seg_where := ' AND ' ||
	   ar_calc_aging.FLEX_SQL(p_application_id => 101,
			   p_id_flex_code => 'GL#',
			   p_id_flex_num => pg_coaid,
			   p_table_alias => 'GC',
			   p_mode => 'WHERE',
			   p_qualifier => 'GL_BALANCING',
			   p_function => '>=',
			   p_operand1 => pg_in_bal_segment_low);
  ELSE
    pg_bal_seg_where := ' AND ' ||
	   ar_calc_aging.FLEX_SQL(p_application_id => 101,
			   p_id_flex_code => 'GL#',
			   p_id_flex_num =>pg_coaid,
			   p_table_alias => 'GC',
			   p_mode => 'WHERE',
			   p_qualifier => 'GL_BALANCING',
			   p_function => 'BETWEEN',
			   p_operand1 => pg_in_bal_segment_low,
			   p_operand2 => pg_in_bal_segment_high);
  END IF;

  pg_accounting_flexfield :=
              ar_calc_aging.FLEX_SQL(p_application_id => 101,
			   p_id_flex_code => 'GL#',
			   p_id_flex_num =>pg_coaid,
			   p_table_alias => 'c',
			   p_mode => 'SELECT',
			   p_qualifier => 'ALL');

  pg_acct_flex_bal_seg :=
              ar_calc_aging.FLEX_SQL(p_application_id => 101,
			   p_id_flex_code => 'GL#',
			   p_id_flex_num =>pg_coaid,
			   p_table_alias => 'c',
			   p_mode => 'SELECT',
			   p_qualifier => 'GL_BALANCING');

  pg_cons_profile_value := AR_SETUP.value('AR_SHOW_BILLING_NUMBER',null);

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  ' pg_accounting_flexfield '||pg_accounting_flexfield);
    arp_standard.debug(  ' pg_bal_seg_where        '||pg_bal_seg_where);
    arp_standard.debug(  ' pg_acct_flex_bal_seg    '||pg_acct_flex_bal_seg);
    arp_standard.debug(  ' pg_cons_profile_value   '||pg_cons_profile_value);
  END IF;

  pg_report_name   := ARP_STANDARD.fnd_message(pg_rep_type||'_REPORT_NAME');
  pg_segment_label := ARP_STANDARD.fnd_message(pg_rep_type ||'_SEG_LABEL');
  pg_bal_label     := ARP_STANDARD.fnd_message(pg_rep_type ||'_BAL_LABEL');
  pg_label_1       := ARP_STANDARD.fnd_message(pg_rep_type||'_LABEL_1');


  IF pg_rep_type = 'ARXAGS' THEN
    IF UPPER(RTRIM(RPAD(pg_in_summary_option_low,1))) = 'I' THEN
      pg_bal_label := ARP_STANDARD.fnd_message(pg_rep_type ||'_BAL_LABEL_INV');
    END IF;

    IF UPPER(SUBSTR(pg_in_sortoption,1,1)) = 'C' THEN
      pg_sort_on     := ARP_STANDARD.fnd_message(pg_rep_type ||'_SORT_ONC');
      pg_grand_total := ARP_STANDARD.fnd_message(pg_rep_type ||'_GRAND_TOTAL_C');
    ELSE
      pg_sort_on     := ARP_STANDARD.fnd_message(pg_rep_type || '_SORT_ONT');
      pg_grand_total := ARP_STANDARD.fnd_message(pg_rep_type ||'_GRAND_TOTAL_T');
    END IF;
  ELSE
    pg_sort_on     := ARP_STANDARD.fnd_message(pg_rep_type||'_SORT_ON');
    pg_grand_total := ARP_STANDARD.fnd_message(pg_rep_type ||'_GRAND_TOTAL');
  END IF;

  IF pg_rep_type IN ('ARXAGL','ARXAGR') THEN
    pg_label := ARP_STANDARD.fnd_message(pg_rep_type||'_LABEL');
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  ' pg_report_name      '||pg_report_name);
    arp_standard.debug(  ' pg_segment_label    '||pg_segment_label);
    arp_standard.debug(  ' pg_bal_label        '||pg_bal_label);
    arp_standard.debug(  ' pg_label_1          '||pg_label_1);
    arp_standard.debug(  ' pg_sort_on          '||pg_sort_on);
    arp_standard.debug(  ' pg_grand_total      '||pg_grand_total);
    arp_standard.debug(  ' pg_label            '||pg_label);
  END IF;

  populate_setup_information;

  pg_short_unid_phrase := RTRIM(RPAD(ARPT_SQL_FUNC_UTIL.get_lookup_meaning
			             ('MISC_PHRASES','UNIDENTIFIED_PAYMENT'),20));

  pg_payment_meaning   := INITCAP(RTRIM(RPAD(ARPT_SQL_FUNC_UTIL.get_lookup_meaning
				     ('INV/CM/ADJ','PMT'),20)));

  pg_risk_meaning      := rtrim(rpad(ARPT_SQL_FUNC_UTIL.get_lookup_meaning
                                     ('MISC_PHRASES','RISK'),20));

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  ' pg_short_unid_phrase   :'||pg_short_unid_phrase);
    arp_standard.debug(  ' pg_payment_meaning     :'||pg_payment_meaning);
    arp_standard.debug(  ' pg_risk_meaning        :'||pg_risk_meaning);
    arp_standard.debug(  ' AR_AGING_BUCKETS_PKG.initialize_package_globals()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      arp_standard.debug(  ' Exception '||SQLERRM);
      arp_standard.debug(  ' Exception AR_AGING_BUCKETS_PKG.initialize_package_globals()');
      RAISE;
END initialize_package_globals;




/*==========================================================================
| PRIVATE PROCEDURE cleanup_staging_tables                                 |
|                                                                          |
| DESCRIPTION                                                              |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
PROCEDURE cleanup_staging_tables IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.cleanup_staging_tables()+');
    arp_standard.debug(  'pg_retain_staging_flag :'||pg_retain_staging_flag );
  END IF;

  DELETE
  FROM ar_aging_payment_schedules
  WHERE parent_request_id = pg_request_id;

  DELETE
  FROM ar_aging_extract
  WHERE parent_request_id = pg_request_id;

  DELETE
  FROM ar_aging_mfar_extract
  WHERE parent_request_id = pg_request_id;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.cleanup_staging_tables()-');
  END IF;
END cleanup_staging_tables;




/*==========================================================================
| PRIVATE PROCEDURE alloc_aging_payment_schedules                          |
|                                                                          |
| DESCRIPTION                                                              |
|      Populates all the eligible payment schedules based on the input     |
|      criteria provided.                                                  |
|                                                                          |
|      Procedure does the following                                        |
|      a) build query based on input parameter values                      |
|      b) populate interim table with selected payment schedule records    |
|      c) query also allocates the payment schedule to child workers       |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|  filters p_in_amt_due_low and p_in_amt_due_high are not handled in this  |
|  routine to avoid any possible read consistency issues as mentioned in   |
|  bug 3487101                                                             |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
PROCEDURE alloc_aging_payment_schedules IS
  l_insert_stmt    VARCHAR2(2000);
  l_select_caluse  VARCHAR2(2000);
  l_from_clause    VARCHAR2(32000);
  l_where_clause   VARCHAR2(2000);
  l_final_stmt     VARCHAR2(32000);
  l_crh_sub_query  VARCHAR2(2000);
  l_inv_sub_query  VARCHAR2(2000);
  l_ra_sub_query   VARCHAR2(2000);
  l_stmt_cursor    INTEGER;
  l_rows_processed NUMBER;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.alloc_aging_payment_schedules()+');
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'Deleting existing data for parent_request_id:'||pg_request_id);
  END IF;

  --clean up the interim tables if there exists any data refering to current request
  cleanup_staging_tables;

  /** customer info related table joins and where criteria gets appended to the query
      strings based on the filter criteria provided */
  IF pg_in_customer_num_low  IS NOT NULL OR pg_in_customer_num_high  IS NOT NULL OR
     pg_in_customer_name_low IS NOT NULL OR pg_in_customer_name_high IS NOT NULL THEN

    l_from_clause  := l_from_clause  || ',
                       hz_cust_accounts cust_acct ';
    l_where_clause := l_where_clause || '
             and ps.customer_id = cust_acct.cust_account_id ';

    IF pg_in_customer_num_low IS NOT NULL THEN
      l_where_clause := l_where_clause ||'
              and cust_acct.account_number >= :pg_in_customer_num_low';
    END IF;

    IF pg_in_customer_num_high IS NOT NULL THEN
      l_where_clause := l_where_clause ||'
              and cust_acct.account_number <= :pg_in_customer_num_high';
    END IF;

    IF pg_in_customer_name_low IS NOT NULL OR
       pg_in_customer_name_high IS NOT NULL  THEN

      l_from_clause  := l_from_clause || ',
                        hz_parties party ';
      l_where_clause := l_where_clause || '
			and cust_acct.party_id = party.party_id ';

      IF pg_in_customer_name_low IS NOT NULL THEN
	l_where_clause := l_where_clause || '
	       and party.party_name >= :pg_in_customer_name_low';
      END IF;

      IF pg_in_customer_name_high IS NOT NULL THEN
	l_where_clause := l_where_clause || '
	       and party.party_name <= :pg_in_customer_name_high';
      END IF;
    END IF;
  END IF;

  l_insert_stmt :=
         'INSERT /*HINT*/ INTO ar_aging_payment_schedules a
	   ( payment_schedule_id,
	      source_type,
	      parent_request_id,
	      worker_id
	   ) ';

  l_select_caluse :=
          ' SELECT payment_schedule_id,
	           source_type,'
                 ||pg_request_id||','||
	  ' DECODE('||pg_worker_count||',1,'||pg_worker_id||', MOD(ROWNUM, '||pg_worker_count||' ) + 1) ';


  l_inv_sub_query := '
	select ps.payment_schedule_id,
	       ''INV''  source_type
	from ar_payment_schedules_all ps '||l_from_clause||'
	WHERE ps.gl_date_closed > :as_of_date
	AND   ps.gl_date       <= :as_of_date
	AND  DECODE(UPPER(:pg_in_currency),NULL, ps.invoice_currency_code,
	     UPPER(:pg_in_currency)) = ps.invoice_currency_code
	AND ps.class <> ''PMT'''||pg_org_where_ps||l_where_clause;

  IF pg_in_invoice_type_low  IS NOT NULL THEN
    l_inv_sub_query := l_inv_sub_query || '
                       and arpt_sql_func_util.get_org_trx_type_details(ps.cust_trx_type_id,ps.org_id)
			>= :pg_in_invoice_type_low ';
  END IF;

  IF pg_in_invoice_type_high IS NOT NULL THEN
    l_inv_sub_query := l_inv_sub_query || '
                       and arpt_sql_func_util.get_org_trx_type_details(ps.cust_trx_type_id,ps.org_id)
			<= :pg_in_invoice_type_high ';
  END IF;

  l_crh_sub_query :=  '
	  select  /*+ leading(crh) index(ps AR_PAYMENT_SCHEDULES_U2)*/
	      distinct ps.payment_schedule_id,
	      ''CRH''  source_type
	  from ar_cash_receipt_history_all crh,
	       ar_payment_schedules_all ps '||l_from_clause||'
	  where crh.gl_date <= :as_of_date
	  and ( crh.current_record_flag = ''Y''  OR
		 crh.reversal_gl_date   > :as_of_date )
	  and crh.status NOT IN
	      ( DECODE(crh.factor_flag, ''Y'',''RISK_ELIMINATED'',
					''N'',''CLEARED''), ''REVERSED'')
	  and ps.cash_receipt_id = crh.cash_receipt_id
	  and ps.class                = ''PMT''
	  AND  DECODE(UPPER(:pg_in_currency),NULL, ps.invoice_currency_code,
	       UPPER(:pg_in_currency)) = ps.invoice_currency_code
	  and not exists
	 ( SELECT ''x''
	   FROM    ar_receivable_applications_all ra
	   WHERE ra.cash_receipt_id       = crh.cash_receipt_id
	   AND   ra.status                = ''ACTIVITY''
	   AND applied_payment_schedule_id = -2
	  )'||pg_org_where_crh||l_where_clause;

  l_ra_sub_query := '
	select /*+ leading(ps) index(ps AR_PAYMENT_SCHEDULES_N9) index(app AR_RECEIVABLE_APPLICATIONS_N1)*/
	     distinct ps.payment_schedule_id,
	     ''RA''  source_type
	from ar_receivable_applications_all app,
	     ar_payment_schedules_all ps '||l_from_clause||'
	where app.gl_date  <= :as_of_date
	AND app.status IN ( ''ACC''  ,
			   ''UNAPP'',
			   ''UNID'' ,
			   ''OTHER ACC'')
	AND NVL(app.confirmed_flag, ''Y'') = ''Y''
	AND app.reversal_gl_date IS NULL
	AND ps.cash_receipt_id      = app.cash_receipt_id
	AND ps.class                = ''PMT''
	AND  DECODE(UPPER(:pg_in_currency),NULL, ps.invoice_currency_code,
	     UPPER(:pg_in_currency)) = ps.invoice_currency_code
	AND ps.gl_date_closed       > :as_of_date
	AND NVL( ps.receipt_confirmed_flag, ''Y'' ) = ''Y'''||pg_org_where_ra||l_where_clause;

  l_from_clause := '
       FROM ('||l_inv_sub_query||'
	      UNION ALL
	      '||l_crh_sub_query||'
	      UNION ALL
	      '||l_ra_sub_query||') ps';


  IF PG_PARALLEL IN ('Y', 'C') THEN
     l_insert_stmt := REPLACE( l_insert_stmt,'/*HINT*/','/*+ parallel(a) append */');
  END IF;


  IF PG_PARALLEL IN ('Y', 'C') THEN
    COMMIT;
    EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
  END IF;

  l_final_stmt := l_insert_stmt   ||
                  l_select_caluse ||
                  l_from_clause   ;

  arp_standard.debug(   l_final_stmt );

  l_stmt_cursor := dbms_sql.open_cursor;
  dbms_sql.parse (l_stmt_cursor,l_final_stmt,dbms_sql.v7);

  dbms_sql.bind_variable (l_stmt_cursor,':as_of_date',pg_in_as_of_date_low);
  dbms_sql.bind_variable (l_stmt_cursor,':pg_in_currency',pg_in_currency);

  IF pg_in_customer_num_low IS NOT NULL THEN
    dbms_sql.bind_variable (l_stmt_cursor,':pg_in_customer_num_low',pg_in_customer_num_low);
  END IF;
  IF pg_in_customer_num_high IS NOT NULL THEN
    dbms_sql.bind_variable (l_stmt_cursor,':pg_in_customer_num_high',pg_in_customer_num_high);
  END IF;
  IF pg_in_customer_name_low IS NOT NULL THEN
    dbms_sql.bind_variable (l_stmt_cursor,':pg_in_customer_name_low',pg_in_customer_name_low);
  END IF;
  IF pg_in_customer_name_high IS NOT NULL THEN
    dbms_sql.bind_variable (l_stmt_cursor,':pg_in_customer_name_high',pg_in_customer_name_high);
  END IF;

  IF pg_in_invoice_type_low  IS NOT NULL THEN
    dbms_sql.bind_variable (l_stmt_cursor,':pg_in_invoice_type_low',pg_in_invoice_type_low );
  END IF;
  IF pg_in_invoice_type_high IS NOT NULL THEN
    dbms_sql.bind_variable (l_stmt_cursor,':pg_in_invoice_type_high',pg_in_invoice_type_high);
  END IF;

  l_rows_processed := dbms_sql.execute( l_stmt_cursor );

  IF PG_PARALLEL IN ('Y', 'C') THEN
    COMMIT;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'rows inserted into staging table:'||l_rows_processed);
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.alloc_aging_payment_schedules()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      arp_standard.debug(  'Exception : '||SQLERRM );
      arp_standard.debug(  'In AR_AGING_BUCKETS_PKG.alloc_aging_payment_schedules()-');
      RAISE;
END alloc_aging_payment_schedules;




/*==========================================================================
| PRIVATE PROCEDURE get_report_specific_info                               |
|                                                                          |
| DESCRIPTION                                                              |
|      Populates all the eligible payment schedules based on the input     |
|      criteria provided.                                                  |
|                                                                          |
|      Procedure does the following                                        |
|      a) build query based on input parameter values                      |
|      b) populate interim table with selected payment schedule records    |
|      c) query also allocates the payment schedule to child workers       |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|  filters p_in_amt_due_low and p_in_amt_due_high are not handled in this  |
|  routine to avoid any possible read consistency issues as mentioned in   |
|  bug 3487101                                                             |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
PROCEDURE get_report_specific_info( p_qry_category       IN VARCHAR2,
                                    p_rep_specific_cols  OUT NOCOPY VARCHAR2,
                                    p_rep_from_info      OUT NOCOPY VARCHAR2,
				    p_rep_where_cls      OUT NOCOPY VARCHAR2,
				    p_rep_spec_sub_query OUT NOCOPY VARCHAR2,
				    p_rep_spec_grp_cols  OUT NOCOPY VARCHAR2) IS
BEGIN
   /*Only verified the flow related to aging by account report,need verify and replace the
     lexical parameters and test the complete flow when we decide to migrate all these
     reports(reports like ARXAGR ,ARXAGL and ARXAGS)*/
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.get_report_specific_info()+');
    arp_standard.debug(  'p_qry_category  '||p_qry_category);
  END IF;

  --report specific subquery
  IF pg_rep_type    = 'ARXAGR' THEN
      RAISE p_not_implemented_exp;--will introduce the below code at later stages
--    p_rep_specific_cols := ',extns.resource_name sort_field1
--			  ,nvl(sales.salesrep_id, -3) inv_tid_inv';
--
--    p_rep_from_info     := ',ra_salesreps_all sales ,jtf_rs_resource_extns_vl extns ';
--
--    p_rep_where_cls     := ' and ps.customer_trx_id = gld.customer_trx_id
--			     and nvl(ps.primary_salesrep_id,-3) = sales.salesrep_id
--                             and nvl(sales.org_id, ct.org_id) = ct.org_id ';
--
--    IF p_qry_category = AR_AGING_CTGRY_RECEIPT THEN
--      p_rep_spec_grp_cols := ',extns.resource_name sort_field1
--			      ,nvl(sales.salesrep_id, -3) ';
--    END IF;
--
--    IF p_qry_category = AR_AGING_CTGRY_INVOICE THEN
--      p_rep_spec_sub_query := '
--	UNION ALL
--	SELECT  /*HINT*/
--	  ps.customer_id,
--	  ps.customer_site_use_id ,
--	  ps.customer_trx_id,
--	  ps.payment_schedule_id,
--	  ps.class class_inv,
--	  ct.primary_salesrep_id primary_salesrep_id,
--	  ps.due_date  due_date_inv,
--	  decode( :c_convert_flag, ''Y'',
--		  ps.acctd_amount_due_remaining,
--		  ps.amount_due_remaining) amt_due_remaining_inv,
--	  ps.trx_number,
--	  ps.amount_adjusted ,
--	  ps.amount_applied ,
--	  ps.amount_credited ,
--	  ps.amount_adjusted_pending,
--	  ps.gl_date ,
--	  ps.cust_trx_type_id,
--	  ps.org_id,
--	  ps.invoice_currency_code,
--	  nvl(ps.exchange_rate, 1) exchange_rate,
--	  ps.cons_inv_id
--	FROM ar_aging_payment_schedules aging,
--	     ar_payment_schedules_all ps,
--	     ra_customer_trx_all ct,
--	     ar_adjustments_all adj
--	WHERE aging.parent_request_id  = :parent_request_id
--	AND  aging.worker_id           = :worker_id
--	AND  aging.payment_schedule_id = ps.payment_schedule_id
--	AND  ps.gl_date               <= :as_of_date
--	AND  ps.gl_date_closed         > :as_of_date
--	AND  ps.class                  = ''CB''
--	AND  ps.customer_trx_id        = adj.chargeback_customer_trx_id
--	AND  adj.customer_trx_id       = ct.customer_trx_id';
--    END IF;

  ELSIF pg_rep_type = 'ARXAGS' THEN
        RAISE p_not_implemented_exp;--will introduce the below code at later stages

--     IF p_qry_category IN (AR_AGING_CTGRY_INVOICE,AR_AGING_CTGRY_BR ) THEN
--       p_rep_specific_cols := ' ,decode(upper(:p_in_sortoption),
--                                    ''CUSTOMER'',NULL,
--                                    arpt_sql_func_util.get_org_trx_type_details(ps.cust_trx_type_id,ps.org_id)) sort_field1
--                                ,decode(upper(:p_in_sortoption),''CUSTOMER'',-999,ps.cust_trx_type_id) inv_tid_inv';
--
--     ELSIF p_qry_category = AR_AGING_CTGRY_RECEIPT THEN
--       p_rep_specific_cols := ',decode(upper(:p_in_sortoption),
--                                    ''CUSTOMER'',NULL,
--				    initcap(:lp_payment_meaning)) sort_field1
--			       ,-999 inv_tid_inv ';
--       p_rep_spec_grp_cols:= ',decode(upper(:p_in_sortoption),
--                                    ''CUSTOMER'',NULL,
--				    initcap(:lp_payment_meaning)) sort_field1
--			      ,-999 ';
--
--     ELSIF p_qry_category = AR_AGING_CTGRY_RISK THEN
--       p_rep_specific_cols := ',decode(upper(:p_in_sortoption),
--                                     ''CUSTOMER'',NULL,
--				     initcap(:pg_risk_meaning)) sort_field1
--			       ,-999 inv_tid_inv ';
--       p_rep_spec_grp_cols:= ',decode(upper(:p_in_sortoption),
--                                     ''CUSTOMER'',NULL,
--				     initcap(:pg_risk_meaning)) sort_field1
--			      ,-999 ';
--     END IF;

  ELSIF pg_rep_type = 'ARXAGL' THEN
      RAISE p_not_implemented_exp;--will introduce the below code at later stages

--     p_rep_specific_cols := ',col.name sort_field1
--                             ,col.collector_id inv_tid_inv';
--
--     p_rep_from_info := ',hz_customer_profiles site_cp
--        		,hz_customer_profiles cust_cp
--      			,ar_collectors col';
--
--     p_rep_where_cls := ' and cust_cp.cust_account_id = cust_acct.cust_account_id
--                          and cust_cp.site_use_id is null
--                          and site_cp.site_use_id(+) = ps.customer_site_use_id
--                          and col.collector_id = NVL(site_cp.collector_id, cust_cp.collector_id)
--			  and ps.customer_trx_id = gld.customer_trx_id ';
--
--
--    IF pg_in_collector_low IS NOT NULL THEN
--      p_rep_where_cls := p_rep_where_cls || ' and col.name >= :p_in_collector_low';
--    END IF;
--
--    IF pg_in_collector_high IS NOT NULL THEN
--      p_rep_where_cls := p_rep_where_cls || ' and col.name <= :p_in_collector_high' ;
--    END IF;
--
--    IF p_qry_category IN (AR_AGING_CTGRY_RECEIPT,AR_AGING_CTGRY_RISK ) THEN
--      p_rep_spec_grp_cols := ',col.name sort_field1
--                             ,col.collector_id ';
--    END IF;

  ELSIF(pg_rep_type  = 'ARXAGF') THEN

    IF p_qry_category = AR_AGING_CTGRY_INVOICE THEN
	p_rep_specific_cols := ',decode(types.post_to_gl, ''Y'', '||pg_accounting_flexfield||'
				,NULL) sort_field1
				,c.code_combination_id inv_tid_inv';

      IF pg_accounting_method = 'MFAR' THEN
        p_rep_where_cls := p_rep_where_cls || '
                 and types.cust_trx_type_id = ps.cust_trx_type_id
		 and types.org_id = ps.org_id
		 and decode(types.post_to_gl, ''N'', gld.code_combination_id,
				    decode(gld.posting_control_id,-3,-999999,gld.code_combination_id))
			            = c.code_combination_id ';

	p_rep_from_info := p_rep_from_info ||' ,ra_cust_trx_types_all types ';

      ELSE
	p_rep_from_info := p_rep_from_info ||'
		     ,xla_distribution_links lk
		     ,xla_ae_lines ae
		     ,ra_cust_trx_types_all types ';

	p_rep_where_cls := p_rep_where_cls || '
		 and types.cust_trx_type_id = ps.cust_trx_type_id
		 and types.org_id = ps.org_id
		 and gld.cust_trx_line_gl_dist_id = lk.source_distribution_id_num_1(+)
		 and lk.source_distribution_type(+)   = ''RA_CUST_TRX_LINE_GL_DIST_ALL''
		 and lk.application_id(+)             = 222
		 and ae.application_id(+)          = 222
		 and lk.ae_header_id                = ae.ae_header_id(+)
		 and lk.ae_line_num                 = ae.ae_line_num(+)
		 and decode(lk.accounting_line_code, '''', ''Y'',
						     ''CM_EXCH_GAIN_LOSS'', ''N'',
						     ''AUTO_GEN_GAIN_LOSS'', ''N'',
						     ''Y'') = ''Y''
		 and decode(ae.ledger_id,'''',decode(types.post_to_gl,
					 ''N'', gld.code_combination_id,
					 decode(gld.posting_control_id,
						  -3,-999999,
						  gld.code_combination_id)),
						gld.set_of_books_id,ae.code_combination_id,
					 -999999)= c.code_combination_id ';
      END IF;
    ELSE
      p_rep_specific_cols := ','||pg_accounting_flexfield||' sort_field1
			     ,c.code_combination_id inv_tid_inv';

      p_rep_spec_grp_cols := ','||pg_accounting_flexfield||'
			     ,c.code_combination_id';
    END IF;

  END IF;

  --will introduce the below code at later stages
--  IF pg_rep_type  <> 'ARXAGF' THEN
--    p_rep_where_cls := p_rep_where_cls || '
--		      and gld.code_combination_id = c.code_combination_id ';
--  END IF;

  /**set the column list along with tables and required joins to fetch consolidated billing
     info based on the profile  */
  IF ( pg_cons_profile_value = 'N' ) then
    p_rep_specific_cols := p_rep_specific_cols || ',
                           to_char(NULL) cons_billing_number ';
  ELSE
    p_rep_specific_cols := p_rep_specific_cols || ',
                           ci.cons_billing_number cons_billing_number ';
    p_rep_from_info     := p_rep_from_info || '
                           ,ar_cons_inv_all ci ';
    p_rep_where_cls     := p_rep_where_cls || '
                           and ps.cons_inv_id = ci.cons_inv_id(+) ';
    p_rep_spec_grp_cols := p_rep_spec_grp_cols || '
                          ,ci.cons_billing_number ';
  END IF;


  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'p_rep_specific_cols  '||p_rep_specific_cols );
    arp_standard.debug(  'p_rep_from_info      '||p_rep_from_info );
    arp_standard.debug(  'p_rep_where_cls      '||p_rep_where_cls );
    arp_standard.debug(  'p_rep_spec_sub_query '||p_rep_spec_sub_query );
    arp_standard.debug(  'p_rep_spec_grp_cols  '||p_rep_spec_grp_cols );
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.get_report_specific_info()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      arp_standard.debug(  'Exception '||SQLERRM);
      arp_standard.debug(  'Exception :AR_AGING_BUCKETS_PKG.get_report_specific_info()-');
      RAISE;
END get_report_specific_info;



/*==========================================================================
| PRIVATE PROCEDURE bind_bucket_parameters                                 |
|                                                                          |
| DESCRIPTION                                                              |
|  The procedure is a utility to bind bucket info required across various  |
|  select statements that make use of bucket_function.                     |
|                                                                          |
|      Procedure does the following                                        |
|      a) binds all the info related to the current bucket                 |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
| The cursor ensures that we always bind all the 7 bucket info.            |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
PROCEDURE bind_bucket_parameters( p_cursor INTEGER) IS

CURSOR buc_info_cur IS
  select *
  from
    ( select lines.bucket_sequence_num buc_number,
	    days_start,
	    days_to,
	    report_heading1,
	    report_heading2,
	    type,
	    DECODE(type,'DISPUTE_ONLY',type,
	                'PENDADJ_ONLY',type,
                        'DISPUTE_PENDADJ',type,null) bucket_category
      from ar_aging_bucket_lines lines,
	   ar_aging_buckets buckets
      where lines.aging_bucket_id = buckets.aging_bucket_id
      and upper(buckets.bucket_name) = upper(pg_in_bucket_type_low)
      and nvl(buckets.status,'A') = 'A'
    ) buckets,
   (  select rownum-1 sequence_number
      from dual
      connect by
      rownum < 8 ) dummy
  where dummy.sequence_number = buckets.buc_number(+);


BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'AR_AGING_BUCKETS_PKG.bind_bucket_parameters()+');
    arp_standard.debug( 'p_cursor  :'||p_cursor);
  END IF;

  FOR buc_rec IN buc_info_cur LOOP
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( ':bucket_days_from_'||buc_rec.sequence_number||' value '||buc_rec.days_start);
      arp_standard.debug( ':bucket_days_to_'||buc_rec.sequence_number||' value '||buc_rec.days_to);
      arp_standard.debug( ':bucket_line_type_'||buc_rec.sequence_number||' value '||buc_rec.type);
      arp_standard.debug( ':bucket_category_'||buc_rec.sequence_number||' value '||buc_rec.bucket_category);
    END IF;

    dbms_sql.bind_variable(p_cursor, ':bucket_days_from_'||buc_rec.sequence_number,
                           buc_rec.days_start);
    dbms_sql.bind_variable(p_cursor, ':bucket_days_to_'||buc_rec.sequence_number,
                           buc_rec.days_to);
    dbms_sql.bind_variable(p_cursor, ':bucket_line_type_'||buc_rec.sequence_number,
                           buc_rec.type);
    dbms_sql.bind_variable(p_cursor, ':bucket_category_'||buc_rec.sequence_number,
                           buc_rec.bucket_category);
  END LOOP;


  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'AR_AGING_BUCKETS_PKG.bind_bucket_parameters()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      arp_standard.debug( 'Exception '||SQLERRM);
      arp_standard.debug( 'EXception AR_AGING_BUCKETS_PKG.bind_bucket_parameters()');
      RAISE;
END bind_bucket_parameters;




/*==========================================================================
| PRIVATE PROCEDURE extract_aging_information                              |
|                                                                          |
| DESCRIPTION                                                              |
|      Extracts the data using given query and populates the staging table |
|                                                                          |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
PROCEDURE extract_aging_information(  p_qry_category    IN VARCHAR2,
                                      p_in_report_query IN VARCHAR2) IS
l_cursor           INTEGER;
l_rows_processed   INTEGER;
l_insert_stmt      VARCHAR2(32000);

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.extract_aging_information()+');
    arp_standard.debug(  'p_qry_category  :'||p_qry_category);
  END IF;

  l_insert_stmt  := '
      insert into ar_aging_extract
      ( customer_id,
	customer_number,
	short_customer_name,
	sort_field1,
	sort_field2,
	inv_tid_inv,
	contact_site_id,
	customer_state,
	customer_city,
	cust_acct_site_id,
	payment_schedule_id,
	class,
	due_date,
	amt_due_remaining,
	trx_number,
	days_past_due,
	amount_adjusted,
	amount_applied,
	amount_credited,
	gl_date,
	data_converted_flag,
	exchange_rate,
	contact_name,
	contact_phone,
	bucket_0,
	bucket_1,
	bucket_2,
	bucket_3,
	bucket_4,
	bucket_5,
	bucket_6,
	bal_segment_value,
	invoice_type,
	cons_billing_number,
	category,
	parent_request_id,
	worker_id)
      select customer_id,
	customer_number,
	short_customer_name,
	sort_field1,
	sort_field2,
	inv_tid_inv,
	contact_site_id,
	customer_state,
	customer_city,
	cust_acct_site_id,
	payment_schedule_id,
	class,
	due_date,
	amt_due_remaining,
	trx_number,
	days_past_due,
	amount_adjusted,
	amount_applied,
	amount_credited,
	gl_date,
	data_converted_flag,
	exchange_rate,
	AR_AGING_BUCKETS_PKG.get_contact_information( contact_site_id,
						     ''NAME'') contact_name,
	AR_AGING_BUCKETS_PKG.get_contact_information( contact_site_id,
						     ''PHONE'') contact_phone,
	bucket_0,
	bucket_1,
	bucket_2,
	bucket_3,
	bucket_4,
	bucket_5,
	bucket_6,
	bal_segment_value,
	invoice_type,
	cons_billing_number
	,'''||p_qry_category||'''
	,'||pg_parent_request_id||'
	,'||pg_worker_id||'
      from (';

  l_cursor := dbms_sql.open_cursor;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'as_of_date               '||pg_in_as_of_date_low);
    arp_standard.debug(  'pg_rep_type              '||pg_rep_type);
    arp_standard.debug(  'pg_in_format_option_low  '||pg_in_format_option_low);
    arp_standard.debug(  'pg_convert_flag          '||pg_convert_flag);
    arp_standard.debug(  'pg_functional_currency   '||pg_functional_currency);
    arp_standard.debug(  'worker_id                '||pg_worker_id);
    arp_standard.debug(  'pg_parent_request_id     '||pg_parent_request_id);
  END IF;


  dbms_sql.parse(l_cursor,l_insert_stmt||p_in_report_query||')',DBMS_SQL.NATIVE);

  bind_bucket_parameters( l_cursor  );

  IF p_qry_category = AR_AGING_CTGRY_INVOICE THEN
    dbms_sql.bind_variable(l_cursor, ':pg_rep_type', pg_rep_type);
  END IF;

  dbms_sql.bind_variable(l_cursor, ':as_of_date', pg_in_as_of_date_low);

  --temporary,need to set the actual currency code
  dbms_sql.bind_variable(l_cursor, ':functional_currency',     pg_functional_currency);
  dbms_sql.bind_variable(l_cursor, ':format_detailed',         pg_in_format_option_low);
  dbms_sql.bind_variable(l_cursor, ':c_convert_flag',          pg_convert_flag);
  dbms_sql.bind_variable(l_cursor, ':worker_id',               pg_worker_id);
  dbms_sql.bind_variable(l_cursor, ':parent_request_id',       pg_parent_request_id);

  l_rows_processed := dbms_sql.execute(l_cursor);

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'Rows Processed '||l_rows_processed);
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.extract_aging_information()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      arp_standard.debug(  'Exception '||SQLERRM);
      arp_standard.debug(  'AR_AGING_BUCKETS_PKG.extract_aging_information()-');
      RAISE;
END extract_aging_information;



/*==========================================================================
| PRIVATE PROCEDURE build_select_stmt                                      |
|                                                                          |
| DESCRIPTION                                                              |
|      construct and return various queries to extract the aging info      |
|                                                                          |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
PROCEDURE build_select_stmt( p_out_invoice_query   OUT NOCOPY VARCHAR2,
                             p_out_receipt_query   OUT NOCOPY VARCHAR2,
			     p_out_riskinfo_query  OUT NOCOPY VARCHAR2,
			     p_out_br_query        OUT NOCOPY VARCHAR2) IS

l_inv_app_act_query  VARCHAR2(32000);
l_inv_act_sub_query  VARCHAR2(32000);
l_pmt_info_query     VARCHAR2(32000);
l_rep_specific_cols  VARCHAR2(2000);
l_rep_spec_sub_query VARCHAR2(2000);
l_rep_spec_from_list VARCHAR2(2000);
l_rep_spec_where_cls VARCHAR2(2000);
l_rep_spec_grp_cols  VARCHAR2(2000);
l_accting_source     VARCHAR2(30);

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.build_select_stmt()+');
  END IF;

  get_report_specific_info( p_qry_category       => AR_AGING_CTGRY_INVOICE,
                            p_rep_specific_cols  => l_rep_specific_cols,
			    p_rep_from_info      => l_rep_spec_from_list,
			    p_rep_where_cls      => l_rep_spec_where_cls,
			    p_rep_spec_sub_query => l_rep_spec_sub_query,
			    p_rep_spec_grp_cols  => l_rep_spec_grp_cols);

  l_inv_act_sub_query := '(
    SELECT a.customer_id,
      a.customer_site_use_id ,
      a.customer_trx_id,
      a.payment_schedule_id,
      a.class ,
      sum(a.primary_salesrep_id) primary_salesrep_id,
      a.due_date ,
      sum(a.amount_due_remaining) amt_due_remaining_inv,
      a.trx_number,
      a.amount_adjusted,
      a.amount_applied ,
      a.amount_credited ,
      a.amount_adjusted_pending,
      a.gl_date ,
      a.cust_trx_type_id,
      a.org_id,
      a.invoice_currency_code,
      a.exchange_rate,
      sum(a.cons_inv_id) cons_inv_id
    FROM
    ( SELECT  /*HINT*/
	ps.customer_id,
	ps.customer_site_use_id ,
	ps.customer_trx_id,
	ps.payment_schedule_id,
	ps.class ,
	0 primary_salesrep_id,
	ps.due_date ,
	nvl(sum ( decode( :c_convert_flag, ''Y'',
		       nvl(adj.acctd_amount, 0),
		       adj.amount )
		       ),0) * (-1)  amount_due_remaining,
	ps.trx_number,
	ps.amount_adjusted ,
	ps.amount_applied ,
	ps.amount_credited ,
	ps.amount_adjusted_pending,
	ps.gl_date ,
	ps.cust_trx_type_id,
	ps.org_id,
	ps.invoice_currency_code,
	nvl(ps.exchange_rate,1) exchange_rate,
	0 cons_inv_id
      FROM ar_aging_payment_schedules aging,
           ar_payment_schedules_all ps,
	   ar_adjustments_all adj
      WHERE aging.parent_request_id = :parent_request_id
      AND aging.worker_id           = :worker_id
      AND aging.source_type         = ''INV''
      AND aging.payment_schedule_id = ps.payment_schedule_id
      AND ps.gl_date                <= :as_of_date
      AND ps.customer_id            > 0
      AND ps.gl_date_closed          > :as_of_date
      AND adj.payment_schedule_id    = ps.payment_schedule_id
      AND adj.status                 = ''A''
      AND adj.gl_date                > :as_of_date
      GROUP BY
	ps.customer_id,
	ps.customer_site_use_id ,
	ps.customer_trx_id,
	ps.class ,
	ps.due_date,
	ps.trx_number,
	ps.amount_adjusted ,
	ps.amount_applied ,
	ps.amount_credited ,
	ps.amount_adjusted_pending,
	ps.gl_date ,
	ps.cust_trx_type_id,
	ps.org_id,
	ps.invoice_currency_code,
	nvl(ps.exchange_rate,1),
	ps.payment_schedule_id

      UNION ALL

      SELECT /*HINT*/
        ps.customer_id,
	ps.customer_site_use_id ,
	ps.customer_trx_id,
	ps.payment_schedule_id,
	ps.class ,
	0 primary_salesrep_id,
	ps.due_date  ,
	nvl(sum ( decode
		     ( :c_convert_flag, ''Y'',
		       (decode(ps.class, ''CM'',
				  decode ( app.application_type, ''CM'',
					   app.acctd_amount_applied_from,
					   app.acctd_amount_applied_to
					  ),
				  app.acctd_amount_applied_to)+
			 nvl(app.acctd_earned_discount_taken,0) +
			 nvl(app.acctd_unearned_discount_taken,0))
		       ,
		       ( app.amount_applied +
			 nvl(app.earned_discount_taken,0) +
			 nvl(app.unearned_discount_taken,0) )
		     ) *
		     decode
		     ( ps.class, ''CM'',
			decode(app.application_type, ''CM'', -1, 1), 1 )
		  ), 0) amount_due_remaining_inv,
	ps.trx_number ,
	ps.amount_adjusted,
	ps.amount_applied ,
	ps.amount_credited ,
	ps.amount_adjusted_pending,
	ps.gl_date gl_date_inv,
	ps.cust_trx_type_id,
	ps.org_id,
	ps.invoice_currency_code,
	nvl(ps.exchange_rate, 1) exchange_rate,
	0 cons_inv_id
      FROM ar_aging_payment_schedules aging,
           ar_payment_schedules_all ps,
	   ar_receivable_applications_all app
      WHERE aging.parent_request_id   = :parent_request_id
      AND  aging.worker_id            = :worker_id
      AND  aging.source_type          = ''INV''
      AND  aging.payment_schedule_id  = ps.payment_schedule_id
      AND  ps.gl_date                <= :as_of_date
      AND  ps.customer_id             > 0
      AND  ps.gl_date_closed          > :as_of_date
      AND  (app.applied_payment_schedule_id = ps.payment_schedule_id
		OR
	  app.payment_schedule_id     = ps.payment_schedule_id)
      AND  app.status IN (''APP'', ''ACTIVITY'')
      AND  nvl( app.confirmed_flag, ''Y'' ) = ''Y''
      AND  app.gl_date                      > :as_of_date
      GROUP BY
	ps.customer_id,
	ps.customer_site_use_id ,
	ps.customer_trx_id,
	ps.class ,
	ps.due_date,
	ps.trx_number,
	ps.amount_adjusted ,
	ps.amount_applied ,
	ps.amount_credited ,
	ps.amount_adjusted_pending,
	ps.gl_date ,
	ps.cust_trx_type_id,
	ps.org_id,
	ps.invoice_currency_code,
	nvl(ps.exchange_rate, 1),
	ps.payment_schedule_id

      UNION ALL

      SELECT /*HINT*/
        ps.customer_id,
	ps.customer_site_use_id ,
	ps.customer_trx_id,
	ps.payment_schedule_id,
	ps.class class_inv,
	nvl(ct.primary_salesrep_id, -3) primary_salesrep_id,
	ps.due_date  due_date_inv,
	decode( :c_convert_flag, ''Y'',
	     ps.acctd_amount_due_remaining,
	     ps.amount_due_remaining) amt_due_remaining_inv,
	ps.trx_number,
	ps.amount_adjusted ,
	ps.amount_applied ,
	ps.amount_credited ,
	ps.amount_adjusted_pending,
	ps.gl_date ,
	ps.cust_trx_type_id,
	ps.org_id,
	ps.invoice_currency_code,
	nvl(ps.exchange_rate, 1) exchange_rate,
	ps.cons_inv_id
      FROM ar_aging_payment_schedules aging,
           ar_payment_schedules_all ps,
           ra_customer_trx_all ct
      WHERE aging.parent_request_id = :parent_request_id
      AND aging.worker_id           = :worker_id
      AND aging.source_type         = ''INV''
      AND aging.payment_schedule_id = ps.payment_schedule_id
      AND ps.gl_date               <= :as_of_date
      AND ps.gl_date_closed         > :as_of_date
      AND ps.customer_trx_id        = ct.customer_trx_id
      AND DECODE(:pg_rep_type,''ARXAGR'',ps.class,''NULL'') <> ''CB''
      '||nvl(l_rep_spec_sub_query,CHR(0)) || '
    ) a
    GROUP BY a.customer_id,
      a.customer_site_use_id ,
      a.customer_trx_id,
      a.payment_schedule_id,
      a.class ,
      a.due_date ,
      a.trx_number,
      a.amount_adjusted,
      a.amount_applied ,
      a.amount_credited ,
      a.amount_adjusted_pending,
      a.gl_date ,
      a.cust_trx_type_id,
      a.org_id,
      a.invoice_currency_code,
      a.exchange_rate) ps, ';

  l_inv_act_sub_query := REPLACE( l_inv_act_sub_query ,'/*HINT*/','/*+ LEADING(aging) */');

  l_inv_app_act_query :=  '
    select  /*+ LEADING(ps) */
            nvl(cust_acct.cust_account_id,-999) customer_id,
            cust_acct.account_number customer_number,
	    substrb(party.party_name,1,50) short_customer_name,
            arpt_sql_func_util.get_org_trx_type_details(ps.cust_trx_type_id,ps.org_id) sort_field2,
	    site.site_use_id contact_site_id,
	    loc.state customer_state,
	    loc.city customer_city,
	    decode(:format_detailed,NULL,-1,acct_site.cust_acct_site_id) cust_acct_site_id,
	    ps.payment_schedule_id payment_schedule_id,
	    ps.class class,
	    ps.due_date  due_date,
	    amt_due_remaining_inv amt_due_remaining,
	    ps.trx_number trx_number,
	    ceil(:as_of_date - ps.due_date) days_past_due,
	    ps.amount_adjusted amount_adjusted,
	    ps.amount_applied amount_applied,
	    ps.amount_credited amount_credited,
	    ps.gl_date gl_date,
	    decode(ps.invoice_currency_code, :functional_currency, NULL,
		  decode(ps.exchange_rate, NULL, ''*'', NULL)) data_converted_flag,
	    nvl(ps.exchange_rate, 1) exchange_rate,
	     arpt_sql_func_util.bucket_function(:bucket_line_type_0,
		      dh.amount_in_dispute,ps.amount_adjusted_pending,
		      :bucket_days_from_0,:bucket_days_to_0,
		       ps.due_date,:bucket_category_0,:as_of_date) bucket_0,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_1,
		      dh.amount_in_dispute,ps.amount_adjusted_pending,
		      :bucket_days_from_1,:bucket_days_to_1,
		       ps.due_date,:bucket_category_1,:as_of_date) bucket_1,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_2,
		      dh.amount_in_dispute,ps.amount_adjusted_pending,
		      :bucket_days_from_2,:bucket_days_to_2,
		       ps.due_date,:bucket_category_2,:as_of_date) bucket_2,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_3,
		      dh.amount_in_dispute,ps.amount_adjusted_pending,
		      :bucket_days_from_3,:bucket_days_to_3,
		       ps.due_date,:bucket_category_3,:as_of_date) bucket_3,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_4,
		      dh.amount_in_dispute,ps.amount_adjusted_pending,
		      :bucket_days_from_4,:bucket_days_to_4,
		       ps.due_date,:bucket_category_4,:as_of_date) bucket_4,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_5,
		      dh.amount_in_dispute,ps.amount_adjusted_pending,
		      :bucket_days_from_5,:bucket_days_to_5,
		       ps.due_date,:bucket_category_5,:as_of_date) bucket_5,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_6,
		      dh.amount_in_dispute,ps.amount_adjusted_pending,
		      :bucket_days_from_6,:bucket_days_to_6,
		       ps.due_date,:bucket_category_6,:as_of_date) bucket_6, '||pg_acct_flex_bal_seg||'
             bal_segment_value,
	    arpt_sql_func_util.get_org_trx_type_details(ps.cust_trx_type_id,ps.org_id)
		invoice_type '|| l_rep_specific_cols || '
      from '||l_inv_act_sub_query|| '
	hz_cust_accounts cust_acct,
	hz_parties party,
	hz_cust_site_uses_all site,
	hz_cust_acct_sites_all acct_site,
	hz_party_sites party_site,
	hz_locations loc,
	ra_cust_trx_line_gl_dist_all gld,
	ar_dispute_history dh,
	gl_code_combinations c '||l_rep_spec_from_list ||'
      where   ps.customer_site_use_id  = site.site_use_id
	and   ps.customer_id           = cust_acct.cust_account_id
	and   ps.customer_trx_id       = gld.customer_trx_id
	and   site.cust_acct_site_id   = acct_site.cust_acct_site_id
	and   acct_site.party_site_id  = party_site.party_site_id
	and   loc.location_id          = party_site.location_id
	and   gld.account_class        = ''REC''
	and   gld.latest_rec_flag      = ''Y''
	and   ps.payment_schedule_id   =  dh. payment_schedule_id(+)
	and  :as_of_date               >= nvl(dh.start_date(+), :as_of_date)
	and  :as_of_date               <  nvl(dh.end_date(+), :as_of_date + 1)
	and   cust_acct.party_id       = party.party_id '||l_rep_spec_where_cls;

  p_out_invoice_query := l_inv_app_act_query;

  get_report_specific_info( p_qry_category       => AR_AGING_CTGRY_RECEIPT,
                            p_rep_specific_cols  => l_rep_specific_cols,
			    p_rep_from_info      => l_rep_spec_from_list,
			    p_rep_where_cls      => l_rep_spec_where_cls,
			    p_rep_spec_sub_query => l_rep_spec_sub_query,
			    p_rep_spec_grp_cols  => l_rep_spec_grp_cols);

  l_pmt_info_query := '
     select /*+ LEADING(aging) */
            substrb(nvl(party.party_name, '''||pg_short_unid_phrase||'''),1,50) short_customer_name,
            cust_acct.account_number customer_number,
            site.site_use_id contact_site_id,
	    loc.state customer_state,
	    loc.city customer_city,
	    decode(:format_detailed,NULL,-1,acct_site.cust_acct_site_id) cust_acct_site_id,
	    nvl(cust_acct.cust_account_id, -999) customer_id,
	    ps.payment_schedule_id payment_schedule_id,
	    DECODE(app.applied_payment_schedule_id,-4,''CLAIM'',ps.class) class,
	    ps.due_date due_date,
	    decode ( :c_convert_flag, ''Y'', nvl(-sum(app.acctd_amount_applied_from),0) ,
	     nvl(-sum(app.amount_applied),0)) amt_due_remaining,
	    ps.trx_number trx_number,
	    ceil(:as_of_date - ps.due_date) days_past_due,
	    ps.amount_adjusted amount_adjusted,
	    ps.amount_applied amount_applied,
	    ps.amount_credited amount_credited,
	    ps.gl_date gl_date,
	    decode(ps.invoice_currency_code, :functional_currency, NULL,
		decode(ps.exchange_rate, NULL, ''*'', NULL) ) data_converted_flag,
	    nvl(ps.exchange_rate, 1) exchange_rate,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_0,
		  ps.amount_in_dispute,ps.amount_adjusted_pending,
		  :bucket_days_from_0,:bucket_days_to_0,
		   ps.due_date,:bucket_category_0,:as_of_date) bucket_0,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_1,
		  ps.amount_in_dispute,ps.amount_adjusted_pending,
		  :bucket_days_from_1,:bucket_days_to_1,
		   ps.due_date,:bucket_category_1,:as_of_date) bucket_1,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_2,
		  ps.amount_in_dispute,ps.amount_adjusted_pending,
		  :bucket_days_from_2,:bucket_days_to_2,
		   ps.due_date,:bucket_category_2,:as_of_date) bucket_2,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_3,
		  ps.amount_in_dispute,ps.amount_adjusted_pending,
		  :bucket_days_from_3,:bucket_days_to_3,
		   ps.due_date,:bucket_category_3,:as_of_date) bucket_3,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_4,
		  ps.amount_in_dispute,ps.amount_adjusted_pending,
		  :bucket_days_from_4,:bucket_days_to_4,
		   ps.due_date,:bucket_category_4,:as_of_date) bucket_4,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_5,
		  ps.amount_in_dispute,ps.amount_adjusted_pending,
		  :bucket_days_from_5,:bucket_days_to_5,
		   ps.due_date,:bucket_category_5,:as_of_date) bucket_5,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_6,
		  ps.amount_in_dispute,ps.amount_adjusted_pending,
		  :bucket_days_from_6,:bucket_days_to_6,
		   ps.due_date,:bucket_category_6,:as_of_date) bucket_6,
             '||pg_acct_flex_bal_seg||'
              bal_segment_value,
	     '''|| pg_payment_meaning ||''' sort_field2,
	     '''|| pg_payment_meaning ||''' invoice_type '|| l_rep_specific_cols ||'
      from  hz_cust_accounts cust_acct,
            hz_parties party,
	    ar_aging_payment_schedules aging,
            ar_payment_schedules_all ps,
            hz_cust_site_uses_all site,
            hz_cust_acct_sites_all acct_site,
            hz_party_sites party_site,
            hz_locations loc,
            ar_receivable_applications_all app,
            gl_code_combinations c '||l_rep_spec_from_list ||'
      where aging.parent_request_id     = :parent_request_id
      AND    aging.worker_id            = :worker_id
      AND    aging.source_type          = ''RA''
      AND    aging.payment_schedule_id  = ps.payment_schedule_id
      AND    app.gl_date               <= :as_of_date
      and    ps.trx_number is not null
      and    ps.customer_id             = cust_acct.cust_account_id(+)
      and    cust_acct.party_id         = party.party_id (+)
      and    ps.cash_receipt_id         = app.cash_receipt_id
      and    app.code_combination_id    = c.code_combination_id
      and    app.status in ( ''ACC'', ''UNAPP'', ''UNID'',''OTHER ACC'')
      and    nvl(app.confirmed_flag, ''Y'') = ''Y''
      and    ps.customer_site_use_id    = site.site_use_id(+)
      and    site.cust_acct_site_id     = acct_site.cust_acct_site_id(+)
      and    acct_site.party_site_id    = party_site.party_site_id(+)
      and    loc.location_id(+)         = party_site.location_id
      and    ps.gl_date_closed  > :as_of_date
      and    ((app.reversal_gl_date is not null AND
                    ps.gl_date <= :as_of_date) OR
                   app.reversal_gl_date is null )
      and    nvl( ps.receipt_confirmed_flag, ''Y'' ) = ''Y''
      '||l_rep_spec_where_cls||'
      GROUP BY party.party_name,
	cust_acct.account_number,
	site.site_use_id,
	loc.state,
	loc.city,
	acct_site.cust_acct_site_id,
	cust_acct.cust_account_id,
	ps.payment_schedule_id,
	ps.due_date,
	ps.trx_number,
	ps.amount_adjusted,
	ps.amount_applied,
	ps.amount_credited,
	ps.gl_date,
	ps.amount_in_dispute,
	ps.amount_adjusted_pending,
	ps.invoice_currency_code,
	ps.exchange_rate,
	DECODE(app.applied_payment_schedule_id,-4,''CLAIM'',ps.class),
	'||pg_acct_flex_bal_seg||',
        decode( app.status, ''UNID'', ''UNID'',''OTHER ACC'',''OTHER ACC'',''UNAPP''),
        '''|| pg_payment_meaning||''''|| l_rep_spec_grp_cols;

  p_out_receipt_query := l_pmt_info_query;

  get_report_specific_info( p_qry_category       => AR_AGING_CTGRY_RISK,
                            p_rep_specific_cols  => l_rep_specific_cols,
			    p_rep_from_info      => l_rep_spec_from_list,
			    p_rep_where_cls      => l_rep_spec_where_cls,
			    p_rep_spec_sub_query => l_rep_spec_sub_query,
			    p_rep_spec_grp_cols  => l_rep_spec_grp_cols);

  p_out_riskinfo_query := '
      select /*+ LEADING(aging) */
            substrb(nvl(party.party_name,  '''||pg_short_unid_phrase||'''),1,50) short_customer_name,
            cust_acct.account_number customer_number,
            site.site_use_id contact_site_id,
            loc.state customer_state,
            loc.city customer_city,
            decode(:format_detailed,NULL,-1,acct_site.cust_acct_site_id) cust_acct_site_id,
            nvl(cust_acct.cust_account_id, -999) customer_id,
            ps.payment_schedule_id payment_schedule_id,
            '''|| pg_risk_meaning ||''' class,
            ps.due_date due_date ,
            decode( :c_convert_flag, ''Y'', crh.acctd_amount, crh.amount) amt_due_remaining,
            ps.trx_number trx_number,
            ceil(:as_of_date - ps.due_date) days_past_due,
            ps.amount_adjusted amount_adjusted,
            ps.amount_applied amount_applied,
            ps.amount_credited amount_credited,
            crh.gl_date gl_date,
            decode(ps.invoice_currency_code, :functional_currency, NULL,
                decode(crh.exchange_rate, NULL, ''*'', NULL)) data_converted_flag,
            nvl(crh.exchange_rate, 1) exchange_rate,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_0,
		      0,0,:bucket_days_from_0,:bucket_days_to_0,
		       ps.due_date,:bucket_category_0,:as_of_date) bucket_0,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_1,
		      0,0,:bucket_days_from_1,:bucket_days_to_1,
		       ps.due_date,:bucket_category_1,:as_of_date) bucket_1,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_2,
		      0,0,:bucket_days_from_2,:bucket_days_to_2,
		       ps.due_date,:bucket_category_2,:as_of_date) bucket_2,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_3,
		      0,0,:bucket_days_from_3,:bucket_days_to_3,
		       ps.due_date,:bucket_category_3,:as_of_date) bucket_3,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_4,
		      0,0,:bucket_days_from_4,:bucket_days_to_4,
		       ps.due_date,:bucket_category_4,:as_of_date) bucket_4,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_5,
		      0,0,:bucket_days_from_5,:bucket_days_to_5,
		       ps.due_date,:bucket_category_5,:as_of_date) bucket_5,
	    arpt_sql_func_util.bucket_function(:bucket_line_type_6,
		      0,0,:bucket_days_from_6,:bucket_days_to_6,
		       ps.due_date,:bucket_category_6,:as_of_date) bucket_6,
             '||pg_acct_flex_bal_seg||'
              bal_segment_value,
	     '''|| pg_risk_meaning ||''' sort_field2,
	     '''|| pg_risk_meaning ||''' invoice_type '|| l_rep_specific_cols ||'
      from hz_cust_accounts cust_acct,
           hz_parties party,
	   ar_aging_payment_schedules aging,
           ar_payment_schedules_all ps,
           hz_cust_site_uses_all site,
           hz_cust_acct_sites_all acct_site,
           hz_party_sites party_site,
           hz_locations loc,
           ar_cash_receipts_all cr,
           ar_cash_receipt_history_all crh,
           gl_code_combinations c '||l_rep_spec_from_list ||'
      where  aging.parent_request_id = :parent_request_id
       and    aging.worker_id       = :worker_id
       and    aging.source_type     = ''CRH''
       and    aging.payment_schedule_id = ps.payment_schedule_id
       and    crh.gl_date <= :as_of_date
       and    ps.trx_number is not null
       and    ps.customer_id = cust_acct.cust_account_id(+)
       and    cust_acct.party_id = party.party_id(+)
       and    ps.cash_receipt_id = cr.cash_receipt_id
       and    cr.cash_receipt_id = crh.cash_receipt_id
       and    crh.account_code_combination_id = c.code_combination_id
       and    ps.customer_site_use_id = site.site_use_id(+)
       and    site.cust_acct_site_id = acct_site.cust_acct_site_id(+)
       and    acct_site.party_site_id = party_site.party_site_id(+)
       and    loc.location_id(+) = party_site.location_id
       and (  crh.current_record_flag = ''Y''
	      or crh.reversal_gl_date > :as_of_date )
       and    crh.status not in ( decode(crh.factor_flag,
					   ''Y'',''RISK_ELIMINATED'',
					   ''N'',''CLEARED''),
						 ''REVERSED'')
       and   not exists (select ''x''
			 from ar_receivable_applications_all ra
			 where ra.cash_receipt_id = cr.cash_receipt_id
			 and ra.status = ''ACTIVITY''
			 and applied_payment_schedule_id = -2)
      '||l_rep_spec_where_cls;


    IF pg_rep_type = 'ARXAGF'  then
        l_accting_source := 'ar_xla_ard_lines_v ';
    ELSE
        l_accting_source := 'ar_distributions_all ';
    END IF;

  get_report_specific_info( p_qry_category       => AR_AGING_CTGRY_BR,
                            p_rep_specific_cols  => l_rep_specific_cols,
			    p_rep_from_info      => l_rep_spec_from_list,
			    p_rep_where_cls      => l_rep_spec_where_cls,
			    p_rep_spec_sub_query => l_rep_spec_sub_query,
			    p_rep_spec_grp_cols  => l_rep_spec_grp_cols);

  p_out_br_query := '
       select /*+ LEADING(aging) */
           substrb(party.party_name,1,50) short_customer_name,
           cust_acct.account_number customer_number,
           arpt_sql_func_util.get_org_trx_type_details(ps.cust_trx_type_id,ps.org_id) sort_field2,
           site.site_use_id contact_site_id,
           loc.state customer_state,
           loc.city customer_city,
           decode(:format_detailed,NULL,-1,acct_site.cust_acct_site_id) cust_acct_site_id,
           nvl(cust_acct.cust_account_id,-999) customer_id,
           ps.payment_schedule_id payment_schedule_id,
           ps.class class,
           ps.due_date  due_date,
           decode( :c_convert_flag, ''Y'',
                 ps.acctd_amount_due_remaining,
                 ps.amount_due_remaining) amt_due_remaining,
           ps.trx_number trx_number,
           ceil(:as_of_date - ps.due_date) days_past_due,
           ps.amount_adjusted amount_adjusted,
           ps.amount_applied amount_applied,
           ps.amount_credited amount_credited,
           ps.gl_date gl_date,
           decode(ps.invoice_currency_code, :functional_currency, NULL,
                         decode(ps.exchange_rate, NULL, ''*'', NULL)) data_converted_flag,
           nvl(ps.exchange_rate, 1) exchange_rate,
	   arpt_sql_func_util.bucket_function(:bucket_line_type_0,
		    ps.amount_in_dispute,ps.amount_adjusted_pending,
		    :bucket_days_from_0,:bucket_days_to_0,
		     ps.due_date,:bucket_category_0,:as_of_date) bucket_0,
	  arpt_sql_func_util.bucket_function(:bucket_line_type_1,
		    ps.amount_in_dispute,ps.amount_adjusted_pending,
		    :bucket_days_from_1,:bucket_days_to_1,
		     ps.due_date,:bucket_category_1,:as_of_date) bucket_1,
	  arpt_sql_func_util.bucket_function(:bucket_line_type_2,
		    ps.amount_in_dispute,ps.amount_adjusted_pending,
		    :bucket_days_from_2,:bucket_days_to_2,
		     ps.due_date,:bucket_category_2,:as_of_date) bucket_2,
	  arpt_sql_func_util.bucket_function(:bucket_line_type_3,
		    ps.amount_in_dispute,ps.amount_adjusted_pending,
		    :bucket_days_from_3,:bucket_days_to_3,
		     ps.due_date,:bucket_category_3,:as_of_date) bucket_3,
	  arpt_sql_func_util.bucket_function(:bucket_line_type_4,
		    ps.amount_in_dispute,ps.amount_adjusted_pending,
		    :bucket_days_from_4,:bucket_days_to_4,
		     ps.due_date,:bucket_category_4,:as_of_date) bucket_4,
	  arpt_sql_func_util.bucket_function(:bucket_line_type_5,
		    ps.amount_in_dispute,ps.amount_adjusted_pending,
		    :bucket_days_from_5,:bucket_days_to_5,
		     ps.due_date,:bucket_category_5,:as_of_date) bucket_5,
	  arpt_sql_func_util.bucket_function(:bucket_line_type_6,
		    ps.amount_in_dispute,ps.amount_adjusted_pending,
		    :bucket_days_from_6,:bucket_days_to_6,
		     ps.due_date,:bucket_category_6,:as_of_date) bucket_6,
	  '||pg_acct_flex_bal_seg||'
	  bal_segment_value,
         arpt_sql_func_util.get_org_trx_type_details(ps.cust_trx_type_id,ps.org_id) invoice_type
	 '|| l_rep_specific_cols ||'
    from  hz_cust_accounts cust_acct,
          hz_parties party,
	  ar_aging_payment_schedules aging,
          ar_payment_schedules_all ps,
          hz_cust_site_uses_all site,
          hz_cust_acct_sites_all acct_site,
          hz_party_sites party_site,
          hz_locations loc,
          ar_transaction_history_all th,
          gl_code_combinations c,
	  '||l_accting_source ||' dist '||l_rep_spec_from_list ||'
   where  aging.parent_request_id = :parent_request_id
    and   aging.worker_id       = :worker_id
    and   aging.source_type     = ''INV''
    and   aging.payment_schedule_id = ps.payment_schedule_id
    and   ps.gl_date <= :as_of_date
    and   ps.customer_site_use_id = site.site_use_id
    and   site.cust_acct_site_id = acct_site.cust_acct_site_id
    and   acct_site.party_site_id  = party_site.party_site_id
    and   loc.location_id = party_site.location_id
    and   ps.gl_date_closed  > :as_of_date
    and   ps.class = ''BR''
    and   th.transaction_history_id = dist.source_id
    and ps.customer_id=cust_acct.cust_account_id
    and ps.customer_trx_id = th.customer_trx_id
    and   dist.source_table = ''TH''
    and   dist.amount_dr is not null
    and   dist.source_table_secondary is NULL
    and   dist.code_combination_id = c.code_combination_id
    and   cust_acct.party_id = party.party_id
    and   th.transaction_history_id =
         (select max(transaction_history_id)
          from ar_transaction_history_all th2,
	       '||l_accting_source ||' dist2
          where th2.transaction_history_id = dist2.source_id
          and  dist2.source_table = ''TH''
          and  th2.gl_date <= :as_of_date
          and  dist2.amount_dr is not null
          and  th2.customer_trx_id = ps.customer_trx_id)';

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.build_select_stmt()-');
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(  'Exception AR_AGING_BUCKETS_PKG.build_select_stmt()');
      arp_standard.debug(  'Exception message '||SQLERRM);
    END IF;
    RAISE;
END build_select_stmt;




/*==========================================================================
| PRIVATE PROCEDURE prorate_aging_balances_mfar                            |
|                                                                          |
| DESCRIPTION                                                              |
|      query and prorate the information to each receivable account of     |
|      given documents                                                     |
|                                                                          |
|      Procedure does the following                                        |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
PROCEDURE prorate_aging_balances_mfar(p_category VARCHAR2) IS

  CURSOR aging_ps_cur IS
    select /*+leading(age_ps) */
        pg_parent_request_id,
        payment_schedule_id,
        code_combination_id,
	currency_code,
	rec_amount,
	0 rec_aging_amount,
	SUM(rec_amount) OVER (PARTITION BY payment_schedule_id) receivable_total,
	amt_due_remaining,
	p_category category
    from
    ( select /*+ leading(age_ps)*/
            ae.code_combination_id,
	    sum(nvl(xdl.unrounded_entered_dr,0)-nvl(xdl.unrounded_entered_cr,0)) rec_amount,
	    age_ps.payment_schedule_id,
	    age_ps.amt_due_remaining,
	    ae.currency_code
      from xla_ae_headers hdr,
	   xla_ae_lines ae,
	   xla_distribution_links xdl,
	   ( select /*+ leading(ext) index(ra AR_RECEIVABLE_APPLICATIONS_N3)*/
	            ra.event_id,
		    ext.payment_schedule_id,
		    ext.amt_due_remaining,
		    'RA_APPLIED_FROM' source_identifier
	     from ar_aging_extract ext,
		  ar_receivable_applications_all ra
	     where ext.parent_request_id = pg_parent_request_id
	     and ext.worker_id           = pg_worker_id
	     and ext.payment_schedule_id = ra.payment_schedule_id
	     and ra.gl_date             <= pg_in_as_of_date_low
	     and ra.status in ('APP','ACTIVITY')
	     group by ra.event_id,
	     ext.payment_schedule_id,
	     ext.amt_due_remaining

	     UNION ALL

	     select /*+ leading(ext) index(ra AR_RECEIVABLE_APPLICATIONS_N8)*/
	            ra.event_id,
		    ext.payment_schedule_id,
		    ext.amt_due_remaining,
		    'RA_APPLIED_TO' source_identifier
	     from ar_aging_extract ext,
		  ar_receivable_applications_all ra
	     where ext.parent_request_id = pg_parent_request_id
	     and ext.worker_id           = pg_worker_id
	     and ext.payment_schedule_id = ra.applied_payment_schedule_id
	     and ra.gl_date             <= pg_in_as_of_date_low
	     and ra.status in ('APP','ACTIVITY')
	     group by ra.event_id,
	     ext.payment_schedule_id,
	     ext.amt_due_remaining

	     UNION ALL

	     select /*+ leading(ext) index(adj AR_ADJUSTMENTS_N3)*/
	            adj.event_id,
		    ext.payment_schedule_id,
		    ext.amt_due_remaining,
		    'ADJ' source_identifier
	     from ar_aging_extract ext,
		  ar_adjustments_all adj
	     where ext.parent_request_id = pg_parent_request_id
	     and ext.worker_id           = pg_worker_id
	     and ext.payment_schedule_id = adj.payment_schedule_id
	     and adj.gl_date            <= pg_in_as_of_date_low
	     and nvl(postable,'Y')       = 'Y'
	     group by adj.event_id,
	     ext.payment_schedule_id,
	     ext.amt_due_remaining

	     UNION ALL

	     select /*+ leading(ext) index(ctlgd  RA_CUST_TRX_LINE_GL_DIST_N6)*/
	            ctlgd.event_id,
		    ext.payment_schedule_id,
		    ext.amt_due_remaining,
		    'CTLGD' source_identifier
	     from ar_aging_extract ext,
		  ar_payment_schedules_all ps,
		  ra_cust_trx_line_gl_dist_all ctlgd
	     where ext.parent_request_id = pg_parent_request_id
	     and ext.worker_id           = pg_worker_id
	     and ext.payment_schedule_id = ps.payment_schedule_id
	     and ps.customer_trx_id      = ctlgd.customer_trx_id
	     and ctlgd.gl_date           <= pg_in_as_of_date_low
	     group by ctlgd.event_id,
	     ext.payment_schedule_id,
	     ext.amt_due_remaining

	   ) age_ps
      where hdr.application_id  = 222
      and ae.application_id     = 222
      and xdl.application_id    = 222
      and hdr.ledger_id         = pg_set_of_books_id
      and ae.ae_header_id       = hdr.ae_header_id
      and ae.accounting_class_code = 'RECEIVABLE'
      and hdr.accounting_entry_status_code = 'F'
      and hdr.event_id          = age_ps.event_id
      and xdl.ae_header_id      = hdr.ae_header_id
      and xdl.event_id          = hdr.event_id
      and xdl.ae_line_num       = ae.ae_line_num
      and ( age_ps.source_identifier     <> 'RA_APPLIED_TO' OR
            xdl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL') --to restrict CM accounting records
      group by ae.code_combination_id,
               age_ps.payment_schedule_id,
	       age_ps.amt_due_remaining,
	       ae.currency_code
      order by payment_schedule_id
    );

  l_aging_mfar_tab    AR_AGING_BUCKETS_PKG.AGING_MFAR_TAB;
  l_run_alloc_tot     NUMBER;
  l_alloc_amt         NUMBER;
  l_run_rec_tot       NUMBER;
  l_pror_identifier   NUMBER(15);

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'AR_AGING_BUCKETS_PKG.prorate_aging_balances_mfar()+');
    arp_standard.debug( 'p_category '||p_category);
  END IF;

  OPEN aging_ps_cur;

  LOOP
    FETCH  aging_ps_cur BULK COLLECT INTO l_aging_mfar_tab LIMIT MAX_ARRAY_SIZE;

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'current fetch count   '|| l_aging_mfar_tab.count);
    END IF;

    EXIT WHEN l_aging_mfar_tab.count = 0;

    --loop over the array and prorate amounts
    FOR i IN l_aging_mfar_tab.FIRST..l_aging_mfar_tab.LAST LOOP

      IF NVL(l_pror_identifier,-9999) <> l_aging_mfar_tab(i).payment_schedule_id THEN
        l_run_alloc_tot    := 0;
	l_run_rec_tot      := 0;
        l_pror_identifier  := l_aging_mfar_tab(i).payment_schedule_id;
      END IF;

      IF l_aging_mfar_tab(i).rec_amount <> 0  AND
         l_aging_mfar_tab(i).amt_due_remaining <>0  THEN
	l_run_rec_tot := l_run_rec_tot + l_aging_mfar_tab(i).rec_amount;
	l_alloc_amt   := ar_unposted_item_util.CurrRound(
			   (l_run_rec_tot / l_aging_mfar_tab(i).receivable_total) *
			    l_aging_mfar_tab(i).amt_due_remaining - l_run_alloc_tot,
			    l_aging_mfar_tab(i).currency_code );

	l_aging_mfar_tab(i).rec_aging_amount := l_alloc_amt;
	l_run_alloc_tot :=  l_run_alloc_tot + l_alloc_amt;
      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug('l_alloc_amt         '|| l_alloc_amt);
	arp_standard.debug('l_run_alloc_tot     '|| l_run_alloc_tot);
	arp_standard.debug('l_run_rec_tot       '|| l_run_rec_tot);
	arp_standard.debug('l_pror_identifier   '|| l_pror_identifier);
	arp_standard.debug('payment_schedule_id '|| l_aging_mfar_tab(i).payment_schedule_id);
      END IF;

    END LOOP;

    FORALL i IN l_aging_mfar_tab.FIRST..l_aging_mfar_tab.LAST
      INSERT INTO ar_aging_mfar_extract
             VALUES l_aging_mfar_tab(i);

    EXIT WHEN aging_ps_cur%NOTFOUND;
  END LOOP;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'AR_AGING_BUCKETS_PKG.prorate_aging_balances_mfar()-');
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'Exception message '||SQLERRM);
      arp_standard.debug( 'Exception AR_AGING_BUCKETS_PKG.prorate_aging_balances_mfar()');
    END IF;
    RAISE;
END prorate_aging_balances_mfar;




/*==========================================================================
| PRIVATE PROCEDURE generate_xml                                           |
|                                                                          |
| DESCRIPTION                                                              |
|      generates XML out of making use of input query                      |
|                                                                          |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|      p_extract_query                                                     |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
PROCEDURE generate_xml(p_extract_query VARCHAR2) IS
l_encoding       VARCHAR2(20);
l_result             CLOB;
tempResult           CLOB;
l_version            VARCHAR2(20);
l_compatibility      VARCHAR2(20);
l_majorVersion       NUMBER;
l_resultOffset       NUMBER;
l_rows_processed     NUMBER;
l_xml_header         VARCHAR2(32000);
l_xml_header_length  NUMBER;
queryCtx             DBMS_XMLquery.ctxType;
qryCtx               DBMS_XMLGEN.ctxHandle;
l_errNo              NUMBER;
l_errMsg             VARCHAR2(200);

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.generate_xml()+');
    print_clob(p_extract_query);
  END IF;

  DBMS_UTILITY.DB_VERSION(l_version, l_compatibility);
  l_majorVersion := to_number(substr(l_version, 1, instr(l_version,'.')-1));

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'l_version       :'||l_version);
    arp_standard.debug(  'l_compatibility :'||l_compatibility);
    arp_standard.debug(  'l_majorVersion  :'||l_majorVersion);
  END IF;

  IF (l_majorVersion > 8 and l_majorVersion < 9) THEN

    BEGIN
      queryCtx := DBMS_XMLQuery.newContext( p_extract_query );
      DBMS_XMLQuery.setRaiseNoRowsException(queryCtx,TRUE);

      IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug(  'Query context set.call to getXML...');
      END IF;

      l_result := DBMS_XMLQuery.getXML(queryCtx);
      DBMS_XMLQuery.closeContext(queryCtx);

      l_rows_processed := 1;

    EXCEPTION WHEN OTHERS THEN
      DBMS_XMLQuery.getExceptionContent(queryCtx,l_errNo,l_errMsg);
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug(  'l_errNo '||l_errNo);
      END IF;

      IF l_errNo = 1403 THEN
	l_rows_processed := 0;
      END IF;

      DBMS_XMLQuery.closeContext(queryCtx);
    END;

  ELSIF (l_majorVersion >= 9 ) THEN
    qryCtx   := DBMS_XMLGEN.newContext(p_extract_query);
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(  'Query context set.call to getXML...');
    END IF;

    l_result := DBMS_XMLGEN.getXML(qryCtx,DBMS_XMLGEN.NONE);
    l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
    DBMS_XMLGEN.closeContext(qryCtx);
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'l_rows_processed  '||l_rows_processed);
  END IF;

  IF l_rows_processed <> 0 THEN
    l_resultOffset   := DBMS_LOB.INSTR(l_result,'>');
    tempResult       := l_result;
  ELSE
    l_resultOffset   := 0;
  END IF;

  l_xml_header        := get_report_header_xml;
  l_xml_header_length := length(l_xml_header);

  IF l_rows_processed <> 0 THEN
    dbms_lob.write(tempResult,l_xml_header_length,1,l_xml_header);
    dbms_lob.copy(tempResult,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
    l_xml_header_length,l_resultOffset);
    dbms_lob.writeAppend(tempResult, length('</ARAGEREP>'), '</ARAGEREP>');
  ELSE
    dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
    dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);
    dbms_lob.writeAppend(tempResult, length('</ARAGEREP>'), '</ARAGEREP>');
  END IF;


  ar_cumulative_balance_report.process_clob(tempResult);

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.generate_xml()-');
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(  'Exception message '||SQLERRM);
      arp_standard.debug(  'Exception AR_AGING_BUCKETS_PKG.generate_xml()');
    END IF;
    RAISE;
END generate_xml;





/*==========================================================================
| PRIVATE PROCEDURE aging_rep_extract                                      |
|                                                                          |
| DESCRIPTION                                                              |
|    Acts as child process,makes required procedure call to process the    |
|    alllocated payment schedules and generate aging information           |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS                                         |
|    Used as part of the cocurrent program defintion                       |
|                                                                          |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
PROCEDURE aging_rep_extract(
                      p_errbuf                   OUT NOCOPY VARCHAR2,
                      p_retcode                  OUT NOCOPY NUMBER,
                      p_rep_type                 IN VARCHAR2,
		      p_reporting_level          IN VARCHAR2,
		      p_reporting_entity_id      IN VARCHAR2,
		      p_coaid                    IN VARCHAR2,
		      p_in_bal_segment_low       IN VARCHAR2,
		      p_in_bal_segment_high      IN VARCHAR2,
		      p_in_as_of_date_low        IN VARCHAR2,
		      p_in_summary_option_low    IN VARCHAR2,
		      p_in_format_option_low     IN VARCHAR2,
		      p_in_bucket_type_low       IN VARCHAR2,
		      p_credit_option            IN VARCHAR2,
		      p_risk_option              IN VARCHAR2,
		      p_in_currency              IN VARCHAR2,
		      p_in_customer_name_low     IN VARCHAR2,
		      p_in_customer_name_high    IN VARCHAR2,
		      p_in_customer_num_low      IN VARCHAR2,
		      p_in_customer_num_high     IN VARCHAR2,
		      p_in_amt_due_low           IN VARCHAR2,
		      p_in_amt_due_high          IN VARCHAR2,
		      p_in_invoice_type_low      IN VARCHAR2,
		      p_in_invoice_type_high     IN VARCHAR2,
		      p_accounting_method        IN VARCHAR2,
		      p_in_worker_id             IN VARCHAR2   DEFAULT -1,
		      p_in_worker_count          IN VARCHAR2   DEFAULT 1,
		      p_retain_staging_flag      IN VARCHAR2   DEFAULT NULL) IS
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.aging_rep_extract()+');
    arp_standard.debug(  'invoking procedure aging_seven_buckets..');
  END IF;

  aging_seven_buckets(  p_rep_type              => p_rep_type,
			p_reporting_level       => p_reporting_level,
			p_reporting_entity_id   => p_reporting_entity_id,
			p_coaid                 => p_coaid,
			p_in_bal_segment_low    => p_in_bal_segment_low,
			p_in_bal_segment_high   => p_in_bal_segment_high,
			p_in_as_of_date_low     => p_in_as_of_date_low,
			p_in_summary_option_low => p_in_summary_option_low,
			p_in_format_option_low  => p_in_format_option_low,
			p_in_bucket_type_low    => p_in_bucket_type_low,
			p_credit_option         => p_credit_option,
			p_risk_option           => p_risk_option,
			p_in_currency           => p_in_currency,
			p_in_customer_name_low  => p_in_customer_name_low,
			p_in_customer_name_high => p_in_customer_name_high,
			p_in_customer_num_low   => p_in_customer_num_low,
			p_in_customer_num_high  => p_in_customer_num_high,
			p_in_amt_due_low        => p_in_amt_due_low,
			p_in_amt_due_high       => p_in_amt_due_high,
			p_in_invoice_type_low   => p_in_invoice_type_low,
			p_in_invoice_type_high  => p_in_invoice_type_high,
			p_accounting_method     => p_accounting_method,
			p_in_worker_id          => p_in_worker_id,
			p_in_worker_count       => p_in_worker_count,
			p_retain_staging_flag   => p_retain_staging_flag,
			p_master_req_flag       => 'N');

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.aging_rep_extract()-');
  END IF;
END aging_rep_extract;




/*==========================================================================
| PRIVATE PROCEDURE aging_seven_buckets                                    |
|                                                                          |
| DESCRIPTION                                                              |
|                                                                          |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS                                         |
|    Used as part of the cocurrent program defintion                       |
|                                                                          |
| PARAMETERS                                                               |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
PROCEDURE aging_seven_buckets(
                      p_rep_type                 IN VARCHAR2,
		      p_reporting_level          IN VARCHAR2,
		      p_reporting_entity_id      IN VARCHAR2,
		      p_coaid                    IN VARCHAR2,
		      p_in_bal_segment_low       IN VARCHAR2,
		      p_in_bal_segment_high      IN VARCHAR2,
		      p_in_as_of_date_low        IN VARCHAR2,
		      p_in_summary_option_low    IN VARCHAR2,
		      p_in_format_option_low     IN VARCHAR2,
		      p_in_bucket_type_low       IN VARCHAR2,
		      p_credit_option            IN VARCHAR2,
		      p_risk_option              IN VARCHAR2,
		      p_in_currency              IN VARCHAR2,
		      p_in_customer_name_low     IN VARCHAR2,
		      p_in_customer_name_high    IN VARCHAR2,
		      p_in_customer_num_low      IN VARCHAR2,
		      p_in_customer_num_high     IN VARCHAR2,
		      p_in_amt_due_low           IN VARCHAR2,
		      p_in_amt_due_high          IN VARCHAR2,
		      p_in_invoice_type_low      IN VARCHAR2,
		      p_in_invoice_type_high     IN VARCHAR2,
		      p_accounting_method        IN VARCHAR2,
		      p_in_worker_id             IN VARCHAR2   DEFAULT -1,
		      p_in_worker_count          IN VARCHAR2   DEFAULT 1,
		      p_retain_staging_flag      IN VARCHAR2   DEFAULT NULL,
		      p_master_req_flag          IN VARCHAR2   DEFAULT 'Y' ) IS

  l_out_invoice_query    VARCHAR2(32000);
  l_out_unapp_query      VARCHAR2(32000);
  l_out_riskinfo_query   VARCHAR2(32000);
  l_out_br_query         VARCHAR2(32000);
  l_worker_number        NUMBER;
  l_complete             BOOLEAN := FALSE;

  PROCEDURE submit_subrequest ( p_worker_number IN NUMBER ) IS
    l_request_id  NUMBER;
  BEGIN
      arp_standard.debug(  'submit_subrequest()+');

      l_request_id := FND_REQUEST.submit_request( 'AR', 'ARXAGEXT',
				      '',
				      SYSDATE,
				      FALSE,
				      p_rep_type,
				      p_reporting_level,
				      p_reporting_entity_id,
				      p_coaid,
				      p_in_bal_segment_low,
				      p_in_bal_segment_high,
				      p_in_as_of_date_low,
				      p_in_summary_option_low,
				      p_in_format_option_low,
				      p_in_bucket_type_low,
				      p_credit_option,
				      p_risk_option,
				      p_in_currency,
				      p_in_customer_name_low,
				      p_in_customer_name_high,
				      p_in_customer_num_low,
				      p_in_customer_num_high,
				      p_in_amt_due_low,
				      p_in_amt_due_high,
				      p_in_invoice_type_low,
				      p_in_invoice_type_high,
				      p_accounting_method,
				      to_char(p_worker_number),
				      to_char(pg_worker_count));


      IF (l_request_id = 0) THEN
	  arp_standard.debug(  'can not start for worker_id: ' ||p_worker_number );
	arp_standard.debug(  'Error Message ' ||fnd_Message.get );
	  return;
      ELSE
	  commit;
	  arp_standard.debug(  'child request id: ' ||l_request_id ||
		       ' started for worker_id: ' ||p_worker_number );
      END IF;

       pg_req_status_tab(p_worker_number).request_id := l_request_id;
       arp_standard.debug(  'submit_subrequest()-');

  END submit_subrequest;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'AR_AGING_BUCKETS_PKG.aging_seven_buckets()+');
    arp_standard.debug(  'p_rep_type              '|| p_rep_type);
    arp_standard.debug(  'p_reporting_level       '|| p_reporting_level);
    arp_standard.debug(  'p_reporting_entity_id   '|| p_reporting_entity_id);
    arp_standard.debug(  'p_coaid                 '|| p_coaid);
    arp_standard.debug(  'p_in_bal_segment_low    '|| p_in_bal_segment_low);
    arp_standard.debug(  'p_in_bal_segment_high   '|| p_in_bal_segment_high);
    arp_standard.debug(  'p_in_as_of_date_low     '|| p_in_as_of_date_low);
    arp_standard.debug(  'p_in_summary_option_low '|| p_in_summary_option_low);
    arp_standard.debug(  'p_in_format_option_low  '|| p_in_format_option_low);
    arp_standard.debug(  'p_in_bucket_type_low    '|| p_in_bucket_type_low);
    arp_standard.debug(  'p_credit_option         '|| p_credit_option);
    arp_standard.debug(  'p_risk_option           '|| p_risk_option);
    arp_standard.debug(  'p_in_currency           '|| p_in_currency);
    arp_standard.debug(  'p_in_customer_name_low  '|| p_in_customer_name_low);
    arp_standard.debug(  'p_in_customer_name_high '|| p_in_customer_name_high);
    arp_standard.debug(  'p_in_customer_num_low   '|| p_in_customer_num_low);
    arp_standard.debug(  'p_in_customer_num_high  '|| p_in_customer_num_high);
    arp_standard.debug(  'p_in_amt_due_low        '|| p_in_amt_due_low);
    arp_standard.debug(  'p_in_amt_due_high       '|| p_in_amt_due_high);
    arp_standard.debug(  'p_in_invoice_type_low   '|| p_in_invoice_type_low);
    arp_standard.debug(  'p_in_invoice_type_high  '|| p_in_invoice_type_high);
    arp_standard.debug(  'p_worker_id             '|| p_in_worker_id);
    arp_standard.debug(  'p_worker_count          '|| p_in_worker_count);
    arp_standard.debug(  'p_retain_staging_flag   '|| p_retain_staging_flag);
    arp_standard.debug(  'p_accounting_method     '|| p_accounting_method);
  END IF;

  --set the parameter value to package global variables
  pg_rep_type               := p_rep_type;
  pg_reporting_level        := TO_NUMBER(NVL(p_reporting_level,0));
  pg_reporting_entity_id    := TO_NUMBER(NVL(p_reporting_entity_id,0));
  pg_coaid                  := TO_NUMBER(NVL(p_coaid,0));
  pg_in_bal_segment_low     := p_in_bal_segment_low;
  pg_in_bal_segment_high    := p_in_bal_segment_high;
  pg_in_as_of_date_low      := fnd_date.canonical_to_date(p_in_as_of_date_low);
  pg_in_summary_option_low  := p_in_summary_option_low;
  pg_in_format_option_low   := p_in_format_option_low;
  pg_in_bucket_type_low     := p_in_bucket_type_low;
  pg_credit_option          := p_credit_option;
  pg_risk_option            := p_risk_option;
  pg_in_currency            := p_in_currency;
  pg_in_customer_name_low   := p_in_customer_name_low;
  pg_in_customer_name_high  := p_in_customer_name_high;
  pg_in_customer_num_low    := p_in_customer_num_low;
  pg_in_customer_num_high   := p_in_customer_num_high;
  pg_in_invoice_type_low    := p_in_invoice_type_low;
  pg_in_invoice_type_high   := p_in_invoice_type_high;
  pg_worker_id              := TO_NUMBER(NVL(p_in_worker_id,'-1'));
  pg_worker_count           := TO_NUMBER(NVL(p_in_worker_count,'1'));
  pg_retain_staging_flag    := NVL(p_retain_staging_flag,'N');
  pg_accounting_method      := p_accounting_method;
  pg_in_amt_due_low         := p_in_amt_due_low;
  pg_in_amt_due_high        := p_in_amt_due_high;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(  'pg_reporting_level       '|| pg_reporting_level);
    arp_standard.debug(  'pg_reporting_entity_id   '|| pg_reporting_entity_id);
    arp_standard.debug(  'pg_coaid                 '|| pg_coaid);
    arp_standard.debug(  'pg_in_as_of_date_low     '|| pg_in_as_of_date_low);
    arp_standard.debug(  'pg_worker_id             '|| pg_worker_id);
    arp_standard.debug(  'pg_worker_count          '|| pg_worker_count);
    arp_standard.debug(  'pg_retain_staging_flag   '|| pg_retain_staging_flag);
  END IF;

  pg_request_id := arp_standard.profile.request_id;

  initialize_package_globals;

  IF nvl(p_master_req_flag,'Y') = 'Y' THEN
    pg_parent_request_id := pg_request_id;

    --distribute the workload across the workers
    alloc_aging_payment_schedules;
  ELSE
    pg_parent_request_id  := get_parent_request_id( pg_request_id );
  END IF;

  /* In case the request is to be processed by more than one worker then invoke
     required number of child processes, otherwise continue with processing the
     report */
  IF  nvl(p_master_req_flag,'Y') = 'Y' AND pg_worker_count > 1 THEN
      --Invoke the child programs
    FOR l_worker_number IN 1..pg_worker_count LOOP
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug(   'Submitting worker '|| l_worker_number );
      END IF;
      submit_subrequest ( l_worker_number );
    END LOOP;

    -- Wait for the completion of the submitted requests
    FOR i in 1..pg_worker_count LOOP
	IF PG_DEBUG in ('Y', 'C') THEN
	  arp_standard.debug(   'Waiting for the completion of worker '||pg_req_status_tab(i).request_id);
	END IF;

      l_complete := FND_CONCURRENT.WAIT_FOR_REQUEST(
		 request_id   => pg_req_status_tab(i).request_id,
		 interval     => 30,
		 max_wait     =>144000,
		 phase        =>pg_req_status_tab(i).phase,
		 status       =>pg_req_status_tab(i).status,
		 dev_phase    =>pg_req_status_tab(i).dev_phase,
		 dev_status   =>pg_req_status_tab(i).dev_status,
		 message      =>pg_req_status_tab(i).message);

      IF pg_req_status_tab(i).dev_phase <> 'COMPLETE' THEN
	arp_util.debug('Worker # '|| i||' has a phase '||pg_req_status_tab(i).dev_phase);

      ELSIF pg_req_status_tab(i).dev_phase = 'COMPLETE'
	     AND pg_req_status_tab(i).dev_status <> 'NORMAL' THEN
	arp_util.debug('Worker # '|| i||' completed with status '||pg_req_status_tab(i).dev_status);
      ELSE
	arp_util.debug('Worker # '|| i||' completed successfully');
      END IF;
    END LOOP;
  ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(  'Child processing..');
    END IF;

    build_select_stmt( p_out_invoice_query => l_out_invoice_query,
		       p_out_receipt_query => l_out_unapp_query,
		       p_out_riskinfo_query => l_out_riskinfo_query,
		       p_out_br_query       => l_out_br_query);

    arp_standard.debug(   l_out_unapp_query  );

    extract_aging_information( AR_AGING_CTGRY_INVOICE,
			       l_out_invoice_query );

    IF pg_accounting_method = 'MFAR' THEN
      prorate_aging_balances_mfar(AR_AGING_CTGRY_INVOICE);
    END IF;

    extract_aging_information( AR_AGING_CTGRY_RECEIPT,
			       l_out_unapp_query );

    IF pg_risk_option <> 'NONE' THEN
      extract_aging_information( AR_AGING_CTGRY_RISK,
				 l_out_riskinfo_query );
    END IF;

    extract_aging_information( AR_AGING_CTGRY_BR,
			       l_out_br_query );
  END IF;

  --invoke the report
  IF nvl(p_master_req_flag,'Y') = 'Y' THEN
    generate_xml( get_report_query );

    IF pg_retain_staging_flag <> 'Y' THEN
      cleanup_staging_tables;
    END IF;
  END IF;

END aging_seven_buckets;


END AR_AGING_BUCKETS_PKG;

/
