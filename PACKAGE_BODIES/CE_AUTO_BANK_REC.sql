--------------------------------------------------------
--  DDL for Package Body CE_AUTO_BANK_REC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_AUTO_BANK_REC" AS
/* $Header: ceabrdrb.pls 120.17.12010000.2 2009/01/19 08:37:26 rtumati ship $ */

l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
--l_DEBUG varchar2(1) := 'Y';

FUNCTION body_revision RETURN VARCHAR2 IS
BEGIN

  RETURN '$Revision: 120.17.12010000.2 $';

END body_revision;

FUNCTION spec_revision RETURN VARCHAR2 IS
BEGIN

  RETURN G_spec_revision;

END spec_revision;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	find_gl_period							|
|									|
|  DESCRIPTION								|
|	Procedure to find valid GL period				|
 --------------------------------------------------------------------- */

FUNCTION find_gl_period(p_date		DATE,
			p_app_id	NUMBER) RETURN BOOLEAN IS
  dummy NUMBER;

BEGIN

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_REC.find_gl_period');
  END IF;

  SELECT 1
  INTO   dummy
  FROM   gl_period_statuses
  WHERE  application_id = p_app_id
  AND    set_of_books_id = CE_AUTO_BANK_REC.G_set_of_books_id
  AND    adjustment_period_flag = 'N'
  AND    closing_status in ('O','F')
  AND    p_date between start_date and end_date;
/*  AND    to_date(p_date) between start_date and end_date;*/

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_REC.find_gl_period');
  END IF;
  return(TRUE);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('find_gl_period() has no data found.');
    END IF;
    RETURN FALSE;
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:CE_AUTO_BANK_REC.find_gl_period:OTHERS');
    END IF;
    RAISE;
END find_gl_period;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	set_parameters							|
|									|
|  DESCRIPTION								|
|	Procedure to set parameter values into globals			|
|  CALLED BY								|
|	statement							|
|  REQUIRES								|
|	all parameters of CE_AUTO_BANK_REC.statement			|
 --------------------------------------------------------------------- */
PROCEDURE set_parameters(p_option                    	VARCHAR2,
                         p_bank_branch_id		NUMBER,
			 p_bank_account_id            	NUMBER,
			 p_statement_number_from      	VARCHAR2,
			 p_statement_number_to        	VARCHAR2,
			 p_statement_date_from	     	VARCHAR2,
			 p_statement_date_to	     	VARCHAR2,
			 p_gl_date                    	VARCHAR2,
			 p_receivables_trx_id	     	NUMBER,
			 p_payment_method_id	     	NUMBER,
			 p_nsf_handling               	VARCHAR2,
			 p_display_debug	   	VARCHAR2,
			 p_debug_path			VARCHAR2,
			 p_debug_file			VARCHAR2,
			 p_intra_day_flag		VARCHAR2,
			 p_org_id		     	NUMBER,
			 p_legal_entity_id	     	NUMBER) IS
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_REC.set_parameters');
  END IF;
  CE_AUTO_BANK_REC.G_option 			:= p_option;
  CE_AUTO_BANK_REC.G_bank_branch_id		:= p_bank_branch_id;
  CE_AUTO_BANK_REC.G_bank_account_id		:= p_bank_account_id;
  CE_AUTO_BANK_REC.G_statement_number_from 	:= p_statement_number_from;
  CE_AUTO_BANK_REC.G_statement_number_to 	:= p_statement_number_to;

  /* bug 1619492
     loader and autoreconciliation should not store the timestamp of a date */
  CE_AUTO_BANK_REC.G_statement_date_from	:= to_date(p_statement_date_from,'YYYY/MM/DD HH24:MI:SS');
  CE_AUTO_BANK_REC.G_statement_date_to		:= to_date(p_statement_date_to,'YYYY/MM/DD HH24:MI:SS');
  CE_AUTO_BANK_REC.G_gl_date			:= to_date(p_gl_date,'YYYY/MM/DD HH24:MI:SS');
  CE_AUTO_BANK_REC.G_gl_date_original		:= to_date(p_gl_date,'YYYY/MM/DD HH24:MI:SS');
  CE_AUTO_BANK_REC.G_receivables_trx_id	:= p_receivables_trx_id;
  CE_AUTO_BANK_REC.G_payment_method_id		:= p_payment_method_id;
  CE_AUTO_BANK_REC.G_nsf_handling		:= p_nsf_handling;
  CE_AUTO_BANK_REC.G_display_debug		:= p_display_debug;
  CE_AUTO_BANK_REC.G_debug_path                 := p_debug_path;
  CE_AUTO_BANK_REC.G_debug_file			:= p_debug_file;

  CE_AUTO_BANK_REC.G_intra_day_flag		:= p_intra_day_flag;
  CE_AUTO_BANK_REC.G_org_id			:= p_org_id;
  CE_AUTO_BANK_REC.G_legal_entity_id		:= p_legal_entity_id;

  IF l_DEBUG in ('Y', 'C') THEN
       show_parameters;
  	cep_standard.debug('<<CE_AUTO_BANK_REC.set_parameters');
  END IF;
END set_parameters;

PROCEDURE show_parameters IS
BEGIN
  cep_standard.debug('G_option = '|| CE_AUTO_BANK_REC.G_option);
  cep_standard.debug('G_statement_number_from = ' || CE_AUTO_BANK_REC.G_statement_number_from);
  cep_standard.debug('G_statement_number_to = ' || CE_AUTO_BANK_REC.G_statement_number_to);
  cep_standard.debug('G_statement_date_from = ' || CE_AUTO_BANK_REC.G_statement_date_from);
  cep_standard.debug('G_statement_date_to = ' || CE_AUTO_BANK_REC.G_statement_date_to);
  cep_standard.debug('G_bank_branch_id = ' || CE_AUTO_BANK_REC.G_bank_branch_id);
  cep_standard.debug('G_bank_account_id = ' || CE_AUTO_BANK_REC.G_bank_account_id);
  cep_standard.debug('G_gl_date = ' || CE_AUTO_BANK_REC.G_gl_date);
  cep_standard.debug('G_gl_date_original = ' || CE_AUTO_BANK_REC.G_gl_date_original);
  cep_standard.debug('G_receivables_trx_id = ' || CE_AUTO_BANK_REC.G_receivables_trx_id);
  cep_standard.debug('G_payment_method_id = ' || CE_AUTO_BANK_REC.G_payment_method_id);
  cep_standard.debug('G_nsf_handling = ' || CE_AUTO_BANK_REC.G_nsf_handling);
  cep_standard.debug('G_display_debug = ' || CE_AUTO_BANK_REC.G_display_debug);
  cep_standard.debug('G_debug_path = ' || CE_AUTO_BANK_REC.G_debug_path);
  cep_standard.debug('G_debug_file = ' || CE_AUTO_BANK_REC.G_debug_file);
  cep_standard.debug('G_org_id = ' || CE_AUTO_BANK_REC.G_org_id);
  cep_standard.debug('G_legal_entity_id = ' || CE_AUTO_BANK_REC.G_legal_entity_id);
END show_parameters;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	statement							|
|									|
|  DESCRIPTION								|
|	Auto Bank Rec has two main functions, import a statement from	|
|	the interface tables or reconcile a previously imported state-	|
|	ment.  								|
|									|
|	p_option may take the following values				|
|	IMPORT		Validate and if no errors exist, transfer the	|
|			statement held in the interface tables.		|
|	RECONCILE	Match, receconcile and clear statement lines	|
|			held within the statement tables.  The statement|
|			being reconciled must have previously been	|
|			imported.					|
|	ZALL		Import statement and reconcile the lines.	|
|									|
|  CALLS								|
|	import_process							|
|	match_process							|
|									|
|  REQUIRES								|
|	p_option							|
|       p_bank_branch_id                                                |
|	p_bank_account_id						|
|	p_statement_number_from						|
|	p_statement_number_to						|
|	p_statement_date_from						|
|	p_statement_date_to						|
|	p_gl_date							|
|	p_nsf_handling							|
|	p_debug_mode							|
|									|
|  RETURNS								|
|	errbuf								|
|	retcode								|
|									|
|  HISTORY								|
 --------------------------------------------------------------------- */
PROCEDURE statement (	errbuf		      OUT NOCOPY    VARCHAR2,
		        retcode		      OUT NOCOPY    NUMBER,
                        p_option                     VARCHAR2,
                        p_bank_branch_id 	     NUMBER,
			p_bank_account_id            NUMBER,
			p_statement_number_from      VARCHAR2,
			p_statement_number_to        VARCHAR2,
			p_statement_date_from        VARCHAR2,
			p_statement_date_to          VARCHAR2,
			p_gl_date                    VARCHAR2,
                        p_org_id		     VARCHAR2,
			p_legal_entity_id	     VARCHAR2,
			p_receivables_trx_id	     NUMBER,
			p_payment_method_id	     NUMBER,
			p_nsf_handling               VARCHAR2,
                        p_display_debug		     VARCHAR2,
			p_debug_path		     VARCHAR2,
			p_debug_file		     VARCHAR2,
			p_intra_day_flag	     VARCHAR2) IS
  req_id		NUMBER;
  request_id		NUMBER;
  reqid			VARCHAR2(30);
  number_of_copies	number;
  printer		VARCHAR2(30);
  print_style		VARCHAR2(30);
  save_output_flag	VARCHAR2(30);
  save_output_bool	BOOLEAN;
  ignore_trx_id		NUMBER;
  l_org_id		NUMBER;
  l_legal_entity_id	NUMBER;
  current_org_id		NUMBER;
  l_Report_Option VARCHAR2(2):='A';   --7720709 To exclude Reconcilation Errors in Bank Statemnet Import Execution Report

BEGIN
 -- populate ce_security_profiles_gt table with ce_security_procfiles_v
 CEP_STANDARD.init_security;

G_ce_debug_flag := l_DEBUG; /* Bug 3364143 added this line */
  IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.enable_debug(p_debug_path,
			      p_debug_file);

  	cep_standard.debug('>>CE_AUTO_BANK_REC.statement '||sysdate);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_option             :  '|| p_option);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_bank_branch_id     :  '|| p_bank_branch_id);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_bank_account_id    :  '|| p_bank_account_id);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_statement_number_from:  '|| p_statement_number_from);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_statement_number_to:  '|| p_statement_number_to);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_statement_date_from:  '|| p_statement_date_from);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_statement_date_to:    '|| p_statement_date_to);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_gl_date            :  '|| p_gl_date);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_receivables_trx_id :  '|| p_receivables_trx_id);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_payment_method_id  :  '|| p_payment_method_id);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_nsf_handling       :  '|| p_nsf_handling);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_display_debug      :  '|| p_display_debug);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_debug_path	      :  '|| p_debug_path);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_debug_file	      :  '|| p_debug_file);
  	cep_standard.debug('>>CE_AUTO_BANK_REC.p_org_id	      		:  '|| p_org_id);
   	cep_standard.debug('>>CE_AUTO_BANK_REC.p_legal_entity_id	:  '|| p_legal_entity_id);
  END IF;

  -- cannot pass both org_id and legal_entity_id from 1 value set/parameter
  -- p_org_id value are concatenated with both org_id and legal_entity_id
  -- org_id starts with 'O' and legal_entity_id start with 'L'
  IF (substr(p_org_id,1,1) = 'O') THEN
     l_org_id := substr(p_org_id,2);
     l_legal_entity_id := null;
  ELSIF (substr(p_org_id,1,1) = 'L') THEN
     l_org_id := null;
     l_legal_entity_id := substr(p_org_id,2);
  ELSE
     l_org_id := p_org_id;
     l_legal_entity_id := p_legal_entity_id;
  END IF;

  IF (p_org_id is null and p_legal_entity_id is null) THEN
     l_org_id := null;
     l_legal_entity_id := null;
  END IF;


  --mo_global.init('CE');

  IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('>>CE_AUTO_BANK_REC.l_org_id	      		:  '|| l_org_id);
   	cep_standard.debug('>>CE_AUTO_BANK_REC.l_legal_entity_id	:  '|| l_legal_entity_id);
  END IF;

  set_parameters(p_option,
                 p_bank_branch_id,
		 p_bank_account_id,
		 p_statement_number_from,
		 p_statement_number_to,
		 p_statement_date_from,
		 p_statement_date_to,
	         p_gl_date,
	         p_receivables_trx_id,
		 p_payment_method_id,
		 p_nsf_handling,
		 p_display_debug,
		 p_debug_path,
		 p_debug_file,
		 p_intra_day_flag,
                 l_org_id,
	 	 l_legal_entity_id);

  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('call CE_SYSTEM_PARAMETERS1_PKG.select_columns');
  END IF;

  --bug 4914608
  --IF (l_org_id is not null or l_legal_entity_id is not null) THEN
  IF (l_legal_entity_id is not null) THEN

    CE_SYSTEM_PARAMETERS1_PKG.select_columns(CE_AUTO_BANK_REC.G_rowid,
				CE_AUTO_BANK_REC.G_set_of_books_id,
				CE_AUTO_BANK_REC.G_cashbook_begin_date,
				CE_AUTO_BANK_REC.G_show_cleared_flag,
                                CE_AUTO_BANK_REC.G_show_void_payment_flag,
				CE_AUTO_BANK_REC.G_line_autocreation_flag,
			 	CE_AUTO_BANK_REC.G_interface_purge_flag,
				CE_AUTO_BANK_REC.G_interface_archive_flag,
				CE_AUTO_BANK_REC.G_lines_per_commit,
				CE_AUTO_BANK_REC.G_functional_currency,
				CE_AUTO_BANK_REC.G_sob_short_name,
				CE_AUTO_BANK_REC.G_account_period_type,
				CE_AUTO_BANK_REC.G_user_exchange_rate_type,
				CE_AUTO_BANK_REC.G_chart_of_accounts_id,
				CE_AUTO_BANK_REC.G_CASHFLOW_EXCHANGE_RATE_TYPE,
				CE_AUTO_BANK_REC.G_AUTHORIZATION_BAT,
				CE_AUTO_BANK_REC.G_BSC_EXCHANGE_DATE_TYPE,
                                CE_AUTO_BANK_REC.G_BAT_EXCHANGE_DATE_TYPE,
				CE_AUTO_BANK_REC.G_legal_entity_id
			);

  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('end call CE_SYSTEM_PARAMETERS1_PKG.select_columns');
    cep_standard.debug('CE_AUTO_BANK_REC.G_org_id '|| CE_AUTO_BANK_REC.G_org_id);
    cep_standard.debug('CE_AUTO_BANK_REC.G_legal_entity_id '|| CE_AUTO_BANK_REC.G_legal_entity_id);
 END IF;

  select mo_global.GET_CURRENT_ORG_ID
  into current_org_id
  from dual;

    -- bug 3782741 set single org, since AR will not allow org_id to be passed
  IF (CE_AUTO_BANK_REC.G_org_id is not null) THEN
    IF  ((current_org_id is null) or (CE_AUTO_BANK_REC.G_org_id <> current_org_id )) THEN
      cep_standard.debug('set policy_context '||CE_AUTO_BANK_REC.G_org_id);
      mo_global.set_policy_context('S',CE_AUTO_BANK_REC.G_org_id);

    END IF;
  END IF;

/*
  IF (CE_AUTO_BANK_REC.G_org_id is not null) THEN
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('set policy_context '||CE_AUTO_BANK_REC.G_org_id);
    END IF;
    mo_global.set_policy_context('S',CE_AUTO_BANK_REC.G_org_id);
  END IF;
*/
  select mo_global.GET_CURRENT_ORG_ID
  into current_org_id
  from dual;

  cep_standard.debug('current_org_id =' ||current_org_id );


  IF (CE_AUTO_BANK_REC.G_receivables_trx_id IS NOT NULL) THEN
    select liability_tax_code, asset_tax_code
    into   CE_AUTO_BANK_REC.G_dr_vat_tax_code,
	   CE_AUTO_BANK_REC.G_cr_vat_tax_code
    from ar_receivables_trx
    where receivables_trx_id = CE_AUTO_BANK_REC.G_receivables_trx_id;
  END IF;

  --
  -- Get the profile values
  --
  FND_PROFILE.get('UNIQUE:SEQ_NUMBERS',CE_AUTO_BANK_REC.G_sequence_numbering);
  FND_PROFILE.get('DISPLAY_INVERSE_RATE',CE_AUTO_BANK_REC.G_inverse_rate);

  IF (p_option IN ('IMPORT', 'ZALL')) THEN
    CE_AUTO_BANK_IMPORT.import_process;
	    COMMIT;
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_REC.statement - Return from Import');
  END IF;
  IF (p_option IN ('RECONCILE', 'ZALL')) THEN
    CE_AUTO_BANK_MATCH.match_process;
    COMMIT;
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_REC.statement - Return from Reconcile');
  END IF;
  --
  -- Get original request id
  --
  fnd_profile.get('CONC_REQUEST_ID', reqid);
  request_id := to_number(reqid);
  --
  -- Get print options
  --
  /* Bug 3479531 removed the NOT from the following condition */
  IF( FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS(request_id,
						number_of_copies,
						print_style,
						printer,
						save_output_flag))THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('statement: ' || 'Message: get print options success');
    END IF;
  ELSE
    IF (save_output_flag = 'Y') THEN
      save_output_bool := TRUE;
    ELSE
      save_output_bool := FALSE;
    END IF;

    IF( FND_CONCURRENT.GET_PROGRAM_ATTRIBUTES ('CE',
                                           'CEXINERR',
                                           printer,
                                           print_style,
                                           save_output_flag)) THEN
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('statement: ' || 'Message: get print options failed');
      END IF;
    END IF;

    IF( FND_CONCURRENT.GET_PROGRAM_ATTRIBUTES ('CE',
                                           'CEIMPERR',
                                           printer,
                                           print_style,
                                           save_output_flag)) THEN
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('statement: ' || 'Message: get print options failed');
      END IF;
    END IF;
  END IF; /* Bug 3479531 placed the END IF here */
    --
    -- Set print options
    --
    IF (NOT FND_REQUEST.set_print_options(printer,
                                           print_style,
                                           number_of_copies,
                                           save_output_bool)) THEN
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('statement: ' || 'Set print options failed');
      END IF;
    END IF;
  IF (p_option in ('IMPORT')) THEN
  l_Report_Option := 'I';  --7720709 To exclude Reconcilation Errors in Bank Statemnet Import Execution Report
    req_id := FND_REQUEST.SUBMIT_REQUEST('CE',
			            'CEIMPERR',
				    NULL,
                                    to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'),
				    /* to_date(sysdate),*/
			            FALSE,
                                    p_bank_branch_id,
				    p_bank_account_id,
				    p_statement_number_from,
				    p_statement_number_to,
				    p_statement_date_from,
				    p_statement_date_to,
				    p_display_debug,
				    p_display_debug,
				    l_Report_Option -- 7720709 To exclude Reconcilation Errors in Bank Statemnet Import Execution Report
            );
  COMMIT;
  END IF;
  IF (p_option IN ('RECONCILE', 'ZALL')) THEN
    req_id := FND_REQUEST.SUBMIT_REQUEST('CE',
			            'CEXINERR',
				    NULL,
				    to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'), /* Bug 4117560 replaced to_date(sysdate) */
			            FALSE,
                                    p_bank_branch_id,
				    p_bank_account_id,
				    p_statement_number_from,
				    p_statement_number_to,
				    p_statement_date_from,
				    p_statement_date_to,
			            --l_org_id,
			  	    --l_legal_entity_id,
				    p_display_debug,
				    p_display_debug);
    COMMIT;
  END IF;
  IF (req_id = 0) THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('statement: ' || 'ERROR submitting concurrent request');
    END IF;
  ELSE
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('statement: ' || 'EXECUTION REPORT SUBMITTED');
    END IF;
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_REC.statement '||sysdate);
	cep_standard.disable_debug(p_display_debug);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_AUTO_BANK_REC.statement');
    END IF;
    RAISE;
END statement;

END CE_AUTO_BANK_REC;

/
