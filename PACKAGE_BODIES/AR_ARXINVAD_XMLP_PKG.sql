--------------------------------------------------------
--  DDL for Package Body AR_ARXINVAD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXINVAD_XMLP_PKG" AS
/* $Header: ARXINVADB.pls 120.0 2007/12/27 13:53:56 abraghun noship $ */
FUNCTION  get_cover_page_values   RETURN BOOLEAN IS
BEGIN
RETURN(TRUE);
RETURN NULL; EXCEPTION
WHEN OTHERS THEN
  RETURN(FALSE);
END;
FUNCTION  get_nls_strings     RETURN BOOLEAN IS
   nls_no_data       fnd_new_messages.message_text%type;
   l_sequence_name   fnd_document_sequences.name%type;
   l_sequence_method fnd_lookups.meaning%type;
lang varchar2(50);
BEGIN
   nls_no_data :=  ARP_STANDARD.FND_MESSAGE('AR_NO_DATA_FOUND');
   c_nls_no_data_exists := '*** '|| nls_no_data || ' ***';
   SELECT ds.name,
          lu.meaning
   INTO   l_sequence_name,
          l_sequence_method
   FROM   fnd_document_sequences ds,
          fnd_lookups lu
   WHERE  ds.doc_sequence_id = p_sequence_id
   AND    lu.lookup_type = 'SEQUENCE_METHOD'
   AND    lu.LOOKUP_CODE = ds.type;
   c_sequence_name := l_sequence_name;
   c_sequence_method := l_sequence_method;
RETURN (TRUE);
RETURN NULL;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      nls_no_data := 'No data found';
   WHEN OTHERS THEN
      RETURN (FALSE);
END;
function BeforeReport return boolean is
init_failure    EXCEPTION;
begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;
C_last_value:=-1;
  IF (P_Debug_Switch = 'Y') THEN
       /*srw.message (100, 'DEBUG:  Get the report type from AR Lookups.');*/null;
  END IF;
  IF (get_report_type <> TRUE) THEN
     RAISE init_failure;
  END IF;
  IF (P_Debug_Switch = 'Y') THEN
       /*srw.message (100, 'DEBUG:  Get Organization Name and Sysdate.');*/null;
  END IF;
  IF (get_company_name <> TRUE) THEN
     RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE(100, 'DEBUG:  Get NLS Strings for All, Yes, No, No Data');*/null;
  END IF;
  IF (GET_NLS_STRINGS <> TRUE) THEN
     RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE(100, 'DEBUG:  Get Code, Precision, Min A/C Unit, Desc for Base Currency');*/null;
  END IF;
  IF (get_base_curr_data <> TRUE) THEN
     RAISE init_failure;
  END IF;
  RETURN (TRUE);
RETURN NULL; EXCEPTION
  WHEN   OTHERS  THEN
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;
end;
function AfterReport return boolean is
begin
BEGIN
   /*SRW.USER_EXIT('FND SRWEXIT');*/null;
   IF (P_DEBUG_SWITCH = 'Y') THEN
      /*SRW.MESSAGE('20','After SRWEXIT');*/null;
   END IF;
EXCEPTION
WHEN OTHERS THEN
   RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;
END;  return (TRUE);
end;
FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%TYPE;
  l_name                  gl_sets_of_books.name%TYPE;
  l_sob_id                NUMBER;
  l_report_start_date     DATE;
BEGIN
  l_report_start_date := sysdate;   l_sob_id := p_set_of_books_id;
  SELECT  name,
          chart_of_accounts_id
  INTO    l_name,
          l_chart_of_accounts_id
  FROM    gl_sets_of_books
  WHERE   set_of_books_id = l_sob_id;
  c_company_name_header     := l_name;
  c_chart_of_accounts_id    := l_chart_of_accounts_id;
  c_report_start_date       := l_report_start_date;
  RETURN (TRUE);
RETURN NULL; EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (FALSE);
END;
function C_enteredFormula return VARCHAR2 is
begin
DECLARE
  status VARCHAR2(30);
BEGIN
  select SUBSTR(meaning, 1, 30)
  into   status
  from   fnd_lookups
  where  lookup_type='SEQ_DOCUMENT_STATUS'
  and    lookup_code='E';
  return(status);
END;
RETURN NULL; end;
function C_deletedFormula return VARCHAR2 is
begin
DECLARE
  status VARCHAR2(30);
BEGIN
  select SUBSTR(meaning, 1, 30)
  into   status
  from   fnd_lookups
  where  lookup_type = 'SEQ_DOCUMENT_STATUS'
  and    lookup_code = 'D';
  return(status);
END;
RETURN NULL; end;
function c_new_recordsformula(doc_sequence_value in number) return number is
begin
DECLARE
  temp ra_customer_trx.doc_sequence_value%type;
BEGIN
  IF (C_last_value = -1) THEN
      C_last_value := P_sequence_from - 1;
  END IF;
 IF (doc_sequence_value <> (C_last_value + 1)) THEN
      temp := doc_sequence_value - C_last_value - 1;
  ELSE
      temp := 0;
  END IF;
C_last_value := doc_sequence_value;
  return(temp);
END;
RETURN NULL; end;
function C_not_enteredFormula return VARCHAR2 is
begin
DECLARE
  status VARCHAR2(30);
BEGIN
  select SUBSTR(meaning, 1, 30)
  into   status
  from   fnd_lookups
  where  lookup_type = 'SEQ_DOCUMENT_STATUS'
  and    lookup_code = 'N';
  return(status);
END;
RETURN NULL; end;
FUNCTION  get_base_curr_data  RETURN BOOLEAN IS
  base_curr gl_sets_of_books.currency_code%TYPE;   prec      fnd_currencies.precision%TYPE;       min_au    fnd_currencies.minimum_accountable_unit%TYPE;  descr     fnd_currencies_vl.description%TYPE;
BEGIN
  base_curr := '';
  prec      := 0;
  min_au    := 0;
  descr     := '';
  SELECT  g.currency_code,
          c.precision,
          c.minimum_accountable_unit,
          c.description
  INTO    base_curr,
          prec,
          min_au,
          descr
  FROM    ar_system_parameters p,
          gl_sets_of_books g,
          fnd_currencies_vl c
  WHERE        p.set_of_books_id = g.set_of_books_id
        AND    g.currency_code  = c.currency_code;
  c_base_currency_code  := base_curr;
  c_base_precision      := prec;
  c_base_min_acct_unit  := min_au;
  c_base_description    := descr;
  RETURN (TRUE);
RETURN NULL; EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (FALSE);
END;
FUNCTION  get_report_type    RETURN BOOLEAN IS
  l_report_type  AR_LOOKUPS.MEANING%TYPE;
BEGIN
  SELECT  meaning
  INTO    l_report_type
  FROM    ar_lookups
  WHERE   LOOKUP_TYPE = 'AUDIT_REPORT_TYPE'
  AND     LOOKUP_CODE = p_type;
  c_report_type     := l_report_type;
  RETURN (TRUE);
RETURN NULL; EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (FALSE);
END;
--Functions to refer Oracle report placeholders--
 Function C_last_value_p return number is
	Begin
	 return C_last_value;
	 END;
 Function C_BASE_CURRENCY_CODE_p return varchar2 is
	Begin
	 return C_BASE_CURRENCY_CODE;
	 END;
 Function C_BASE_PRECISION_p return number is
	Begin
	 return C_BASE_PRECISION;
	 END;
 Function C_BASE_MIN_ACCT_UNIT_p return number is
	Begin
	 return C_BASE_MIN_ACCT_UNIT;
	 END;
 Function C_BASE_DESCRIPTION_p return varchar2 is
	Begin
	 return C_BASE_DESCRIPTION;
	 END;
 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_REPORT_START_DATE_p return date is
	Begin
	 return C_REPORT_START_DATE;
	 END;
 Function C_NLS_NO_DATA_EXISTS_p return varchar2 is
	Begin
	 return C_NLS_NO_DATA_EXISTS;
	 END;
 Function C_CHART_OF_ACCOUNTS_ID_p return number is
	Begin
	 return C_CHART_OF_ACCOUNTS_ID;
	 END;
 Function C_sequence_name_p return varchar2 is
	Begin
	 return C_sequence_name;
	 END;
 Function C_sequence_method_p return varchar2 is
	Begin
	 return C_sequence_method;
	 END;
 Function C_report_type_p return varchar2 is
	Begin
	 return C_report_type;
	 END;
END AR_ARXINVAD_XMLP_PKG ;


/
