--------------------------------------------------------
--  DDL for Package Body AR_ARXNROPN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXNROPN_XMLP_PKG" AS
/* $Header: ARXNROPNB.pls 120.0 2007/12/27 13:56:25 abraghun noship $ */
UNKNOWN_USER_EXIT EXCEPTION;
USER_EXIT_FAILURE EXCEPTION;
function BeforeReport return boolean is
begin
  begin
    /*srw.user_exit('FND SRWINIT');*/null;
  exception
   when  UNKNOWN_USER_EXIT /*srw.unknown_user_exit */then
    /*srw.message(01,'FND SRWINIT user exit is unknown.');*/null;
    raise;
   when  USER_EXIT_FAILURE /*srw.user_exit_failure */then
    /*srw.message(02,'FND SRWINIT user exit failed.');*/null;
    raise;
  end;
        begin
    /*srw.reference(RP_SORT_BY_PHONETICS);*/null;
    /*srw.user_exit('FND GETPROFILE
                   NAME="RA_CUSTOMERS_SORT_BY_PHONETICS"
                   FIELD="RP_SORT_BY_PHONETICS"
                   PRINT_ERROR="N"');*/null;
  exception
    when others then
      RP_SORT_BY_PHONETICS := 'N';
  end;
        begin
    select meaning
    into   HP_ORDER_BY
    from   ar_lookups
    where  lookup_type = 'ARXNROPN_ORDER_BY'
    and    lookup_code = P_ORDER_BY;
  exception
    when NO_DATA_FOUND
      then HP_ORDER_BY := '';
  end;
        begin
    select bank_account_num
    into   HP_BANK_ACCOUNT
    from   ce_bank_accounts
    where  bank_account_id = P_BANK_ACCOUNT_ID;
  exception
    when NO_DATA_FOUND
      then HP_BANK_ACCOUNT := '';
  end;
        begin
    select meaning
    into   HP_NOTE_STATUS
    from   ar_lookups
    where  lookup_type = decode(P_NOTE_STATUS,
			 'REMITTED', 'RECEIPT_CREATION_STATUS',
			 'AR_NOTE_STATUS')
    and	   lookup_code  = P_NOTE_STATUS;
  exception
    when NO_DATA_FOUND
      then HP_NOTE_STATUS := '';
  end;
  return (TRUE);
end;
function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
function AfterPForm return boolean is
begin
P_START_DATE1 := to_char(P_START_DATE,'DD-MON-YY');
P_END_DATE1 := to_char(P_END_DATE,'DD-MON-YY');
  IF P_CURRENCY_CODE IS NOT NULL THEN
    LP_CURRENCY_CODE := 'and cr.currency_code = :P_CURRENCY_CODE';
  END IF;
  IF P_START_DATE IS NOT NULL THEN
    LP_START_DATE := 'and ps.due_date >=  :P_START_DATE';
  END IF;
  IF P_END_DATE IS NOT NULL THEN
    LP_END_DATE := 'and ps.due_date <=  :P_END_DATE';
  END IF;
  IF P_REMITTANCE_BANK IS NOT NULL THEN
    LP_REMITTANCE_BANK := 'and bb.bank_name = :P_REMITTANCE_BANK';
  END IF;
  IF P_BANK_ACCOUNT_ID IS NOT NULL THEN
    LP_BANK_ACCOUNT_ID := 'and cr.remit_bank_acct_use_id = :P_BANK_ACCOUNT_ID';
  END IF;
  IF P_CUSTOMER_NAME_LOW IS NOT NULL THEN
    LP_CUSTOMER_NAME_LOW := 'and PARTY.PARTY_NAME >= :P_CUSTOMER_NAME_LOW';
  END IF;
  IF P_CUSTOMER_NAME_HIGH IS NOT NULL THEN
    LP_CUSTOMER_NAME_HIGH := 'and PARTY.PARTY_NAME <= :P_CUSTOMER_NAME_HIGH';
  END IF;
  IF P_CUSTOMER_NUMBER_LOW IS NOT NULL THEN
    LP_CUSTOMER_NUMBER_LOW := 'and cust.ACCOUNT_NUMBER >= :P_CUSTOMER_NUMBER_LOW';
  END IF;
  IF P_CUSTOMER_NUMBER_HIGH IS NOT NULL THEN
    LP_CUSTOMER_NUMBER_HIGH := 'and cust.ACCOUNT_NUMBER <= :P_CUSTOMER_NUMBER_HIGH';
  END IF;
  IF P_NOTE_STATUS = 'REMITTED' THEN
    LP_NOTE_STATUS := 'and lk.lookup_code = ''REMITTED''';
  ELSIF P_NOTE_STATUS = 'OPEN' THEN
    LP_NOTE_STATUS := 'and lk.lookup_code = ''OPEN''';
  ELSIF P_NOTE_STATUS = 'EXCHANGE' THEN
    LP_NOTE_STATUS := 'and lk.lookup_code = ''EXCHANGE''';
  ELSIF P_NOTE_STATUS = 'MATURED' THEN
    LP_NOTE_STATUS := 'and lk.lookup_code = ''MATURED''';
  END IF;
  return (TRUE);
end;
function setupformula(set_of_books_name in varchar2, functional_curr in varchar2, functional_curr_prec in number) return varchar2 is
begin
  RP_SET_OF_BOOKS_NAME    := set_of_books_name;
  RP_FUNCTIONAL_CURR      := functional_curr;
  RP_FUNCTIONAL_CURR_PREC := functional_curr_prec;
  return('');
end;
--Functions to refer Oracle report placeholders--
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function RP_SORT_BY_PHONETICS_p return varchar2 is
	Begin
	 return RP_SORT_BY_PHONETICS;
	 END;
 Function RP_FUNCTIONAL_CURR_p return varchar2 is
	Begin
	 return RP_FUNCTIONAL_CURR;
	 END;
 Function RP_FUNCTIONAL_CURR_PREC_p return number is
	Begin
	 return RP_FUNCTIONAL_CURR_PREC;
	 END;
 Function RP_SET_OF_BOOKS_NAME_p return varchar2 is
	Begin
	 return RP_SET_OF_BOOKS_NAME;
	 END;
END AR_ARXNROPN_XMLP_PKG ;


/
