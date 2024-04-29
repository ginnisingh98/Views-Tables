--------------------------------------------------------
--  DDL for Package Body GL_GLXJETAX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXJETAX_XMLP_PKG" AS
/* $Header: GLXJETAXB.pls 120.0 2007/12/27 14:58:58 vijranga noship $ */

UNKNOWN_USER_EXIT EXCEPTION;

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

begin
  /*srw.user_exit('FND SRWINIT');*/null;
CP_START_DATE := to_char(P_START_DATE,'DD-MON-YYYY');
CP_END_DATE := to_char(P_END_DATE,'DD-MON-YYYY');

exception
  when  UNKNOWN_USER_EXIT /*srw.unknown_user_exit */then
    /*srw.message(01,'FND SRWINIT user exit is unknown.');*/null;

    raise;
  when  USER_EXIT_FAILURE /*srw.user_exit_failure */then
    /*srw.message(02,'FND SRWINIT user exit failed.');*/null;

    raise;
end;

begin
  select name
  into H_ACCESS_SET_NAME
  from gl_access_sets
  where access_set_id = P_ACCESS_SET_ID;
exception
  when no_data_found then
    /*srw.message(03,'Cannot find data access set information');*/null;

    raise;
end;

begin
  select name, currency_code
  into H_LEDGER_NAME, H_CURRENCY_CODE
  from gl_ledgers
  where ledger_id = P_LEDGER_ID;
exception
  when no_data_found then
    /*srw.message(04,'Cannot find ledger information');*/null;

    raise;
end;

begin

 null;


 null;


 null;


 null;

exception
  when  UNKNOWN_USER_EXIT /*srw.unknown_user_exit */then
    /*srw.message(05,'FND FLEXSQL user exit is unknown.');*/null;

    raise;
  when  USER_EXIT_FAILURE /*srw.user_exit_failure */then
    /*srw.message(06,'FND FLEXSQL user exit failed.');*/null;

    raise;
end;

IF ((P_TAX_TYPE IS NULL) AND (P_TAX_CODE IS NULL)) THEN
  P_WHERE_TAX := '1 = 1';
ELSE
  IF (P_TAX_CODE IS NULL) THEN
    P_WHERE_TAX :=
       'gjl1.tax_type_code = ''' || P_TAX_TYPE || '''';
  ELSE     P_WHERE_TAX :=
       '(gjl1.tax_type_code, gjl1.tax_code_id) ' ||
         'IN (SELECT gtc.tax_type_code, gtc.tax_code_id ' ||
             'FROM   gl_tax_codes_v gtc ' ||
             'WHERE  gtc.tax_type_code = ''' || P_TAX_TYPE || ''' ' ||
             'AND    gtc.tax_code = ''' || replace(P_TAX_CODE, '''', '''''') || ''')';

  END IF;
END IF;

IF (P_POSTING_STATUS = 'E') THEN
  P_WHERE_POSTING_STATUS := 'gjb.status NOT in (''S'',''I'',''U'',''P'')';
ELSE
  P_WHERE_POSTING_STATUS :=
    'gjb.status||'''' = ' || '''' || P_POSTING_STATUS || '''';
END IF;

P_WHERE_DAS := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(
                  P_ACCESS_SET_ID,
                  'F',
                  'LEDGER_ID',
                  to_char(P_LEDGER_ID),
                  null,
                  'NO_SEG_VAL',
                  null,
                  null,
                  null);

IF (P_WHERE_DAS IS NOT NULL) THEN
  P_WHERE_DAS := ' and ' || P_WHERE_DAS ;
END IF;

IF (P_WHERE_DAS IS NULL) THEN
  P_WHERE_DAS := 'and 1 = 1' ;
END IF;

  return (TRUE);
end;

function AfterReport return boolean is
begin

/*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;

function c_dr_or_crformula(C_TAXABLE_ACC_DR in number, C_TAXABLE_ACC_CR in number) return varchar2 is
begin

if abs(nvl(C_TAXABLE_ACC_DR,0))
    > abs(nvl(C_TAXABLE_ACC_CR,0))
  then return('D');
  else return('C');
end if;
RETURN NULL; end;

function c_taxable_acc_amountformula(C_TAXABLE_ACC_DR in number, C_TAXABLE_ACC_CR in number) return number is
begin

if abs(nvl(C_TAXABLE_ACC_DR,0)) > abs(nvl(C_TAXABLE_ACC_CR,0)) then
   return (nvl(C_TAXABLE_ACC_DR,0) - nvl(C_TAXABLE_ACC_CR,0));
else
   return (nvl(C_TAXABLE_ACC_CR,0) - nvl(C_TAXABLE_ACC_DR,0));
end if;

end;

function c_accounted_amountformula(C_ACCOUNTED_DR in number, C_ACCOUNTED_CR in number) return number is
begin

if abs(nvl(C_ACCOUNTED_DR,0)) > abs(nvl(C_ACCOUNTED_CR,0)) then
   return(nvl(C_ACCOUNTED_DR,0) - nvl(C_ACCOUNTED_CR,0));
else
   return(nvl(C_ACCOUNTED_CR,0) - nvl(C_ACCOUNTED_DR,0));
end if;
end;

function c_grossformula(C_GROSS_DR in number, C_GROSS_CR in number) return number is
begin

if abs(C_GROSS_DR) > abs(C_GROSS_CR) then
   return(C_GROSS_DR - C_GROSS_CR);
else
   return(C_GROSS_CR - C_GROSS_DR);
end if;
end;

function c_gross_drformula(C_TAXABLE_ACC_DR in number, C_ACCOUNTED_DR in number) return number is
begin

return(nvl(C_TAXABLE_ACC_DR,0) + nvl(C_ACCOUNTED_DR,0));
end;

function c_gross_crformula(C_TAXABLE_ACC_CR in number, C_ACCOUNTED_CR in number) return number is
begin

return(nvl(C_TAXABLE_ACC_CR,0) + nvl(C_ACCOUNTED_CR,0));
end;

function c_jou_grossformula(C_JOU_GROSS_DR in number, C_JOU_GROSS_CR in number) return number is
begin

if abs(C_JOU_GROSS_DR) > abs(C_JOU_GROSS_CR) then
   return(C_JOU_GROSS_DR - C_JOU_GROSS_CR);
else
   return(C_JOU_GROSS_CR - C_JOU_GROSS_DR);
end if;
end;

function c_jou_accounted_sumformula(C_JOU_ACCOUNTED_DR in number, C_JOU_ACCOUNTED_CR in number) return number is
begin

if abs(nvl(C_JOU_ACCOUNTED_DR,0)) > abs(nvl(C_JOU_ACCOUNTED_CR,0)) then
   return(nvl(C_JOU_ACCOUNTED_DR,0) - nvl(C_JOU_ACCOUNTED_CR,0));
else
   return(nvl(C_JOU_ACCOUNTED_CR,0) - nvl(C_JOU_ACCOUNTED_DR,0));
end if;
end;

function c_jou_taxable_acc_sumformula(C_JOU_TAXABLE_ACC_DR in number, C_JOU_TAXABLE_ACC_CR in number) return number is
begin

if abs(nvl(C_JOU_TAXABLE_ACC_DR,0)) > abs(nvl(C_JOU_TAXABLE_ACC_CR,0)) then
   return(nvl(C_JOU_TAXABLE_ACC_DR,0) - nvl(C_JOU_TAXABLE_ACC_CR,0));
else
   return(nvl(C_JOU_TAXABLE_ACC_CR,0) - nvl(C_JOU_TAXABLE_ACC_DR,0));
end if;

end;

function c_jou_gross_drformula(C_JOU_TAXABLE_ACC_DR in number, C_JOU_ACCOUNTED_DR in number) return number is
begin

return(nvl(C_JOU_TAXABLE_ACC_DR,0) + nvl(C_JOU_ACCOUNTED_DR,0));
end;

function c_jou_gross_crformula(C_JOU_TAXABLE_ACC_CR in number, C_JOU_ACCOUNTED_CR in number) return number is
begin

return(nvl(C_JOU_TAXABLE_ACC_CR,0) + nvl(C_JOU_ACCOUNTED_CR,0));
end;

function c_tax_codeformula(C_TAX_TYPE_CODE in varchar2, C_TAX_CODE_ID in number) return varchar2 is
begin

DECLARE
  tax_code VARCHAR2(50);
  temp_return_status     VARCHAR2(1);
  err_msg                VARCHAR2(30);
  err_buf                VARCHAR2(2000);
BEGIN

   zx_gl_tax_options_pkg.get_tax_rate_code(
          1.0,
          C_TAX_TYPE_CODE,
          C_TAX_CODE_ID,
          tax_code, temp_return_status, err_msg);
   if(temp_return_status='E') then
      fnd_message.set_name('ZX', err_msg);
      fnd_message.set_token('FUNCTION', 'C_TAX_CODEFormula');
      err_buf := substrb(fnd_message.get,1,132);
      /*srw.message(07,err_buf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

   elsif (temp_return_status ='U') then
      fnd_message.set_token('FUNCTION', 'C_TAX_CODEFormula');
      err_buf := substrb(fnd_message.get,1,132);
      /*srw.message(07,err_buf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

   end if;
   RETURN(tax_code);
END;
RETURN NULL; end;

function c_jou_dr_or_crformula(C_JOU_TAXABLE_ACC_DR in number, C_JOU_TAXABLE_ACC_CR in number) return varchar2 is
begin

if abs(nvl(C_JOU_TAXABLE_ACC_DR,0))
    > abs(nvl(C_JOU_TAXABLE_ACC_CR,0))
  then return('D');
  else return('C');
end if;
RETURN NULL; end;

function C_OLD_GROUPSFormula return VARCHAR2 is
begin

/*srw.reference(C_NEW_GROUP);*/null;

RETURN NULL; end;

function c_new_groupformula(C_JE_HEADER_ID in number, C_TAX_GROUP_ID in number, C_ACCOUNTED_DR in number, C_ACCOUNTED_CR in number) return varchar2 is
begin

IF (nvl(C_OLD_HEADER_ID, -1) <> C_JE_HEADER_ID) THEN
  C_OLD_GROUPS := '-';
  C_OLD_HEADER_ID := C_JE_HEADER_ID;
END IF;

IF (instr(nvl(C_OLD_GROUPS, '-'),
          '-' || to_char(C_TAX_GROUP_ID) || '-')
      = 0
   ) THEN
  C_OLD_GROUPS :=    '-'
		   || to_char(C_TAX_GROUP_ID)
		   || nvl(C_OLD_GROUPS,'-');

  C_RUN_ACCOUNTED_DR := C_ACCOUNTED_DR;
  C_RUN_ACCOUNTED_CR := C_ACCOUNTED_CR;

  RETURN('Y');
ELSE
  C_RUN_ACCOUNTED_DR := 0;
  C_RUN_ACCOUNTED_CR := 0;

  RETURN('N');
END IF;

RETURN NULL; end;

function C_OLD_HEADER_IDFormula return Number is
begin

/*srw.reference(C_NEW_GROUP);*/null;

RETURN NULL; end;

function C_RUN_ACCOUNTED_DRFormula return Number is
begin

/*srw.reference(C_NEW_GROUP);*/null;

RETURN NULL; end;

function C_RUN_ACCOUNTED_CRFormula return Number is
begin

/*srw.reference(C_NEW_GROUP);*/null;

RETURN NULL; end;

function g_taxablegroupfilter(ACC_SECURE in varchar2) return boolean is
begin

  /*srw.reference(P_CHART_OF_ACCOUNTS_ID);*/null;

  /*srw.reference(C_TAXABLE_ACC_SEGMENT);*/null;


  IF(ACC_SECURE = 'S') THEN
     return(FALSE);
  ELSE
     return (TRUE);
  END IF;
end;

function g_bal_segmentgroupfilter(BAL_SECURE in varchar2) return boolean is
begin
  /*SRW.REFERENCE(C_BAL_SEGMENT);*/null;

  /*SRW.REFERENCE(P_CHART_OF_ACCOUNTS_ID);*/null;


  IF(BAL_SECURE = 'S') THEN
    return(FALSE);
  ELSE
    return (TRUE);
  END IF;
end;

--Functions to refer Oracle report placeholders--

 Function C_OLD_GROUPS_p return varchar2 is
	Begin
	 return C_OLD_GROUPS;
	 END;
 Function C_OLD_HEADER_ID_p return number is
	Begin
	 return C_OLD_HEADER_ID;
	 END;
 Function C_RUN_ACCOUNTED_DR_p return number is
	Begin
	 return C_RUN_ACCOUNTED_DR;
	 END;
 Function C_RUN_ACCOUNTED_CR_p return number is
	Begin
	 return C_RUN_ACCOUNTED_CR;
	 END;
 Function H_LEDGER_NAME_p return varchar2 is
	Begin
	 return H_LEDGER_NAME;
	 END;
 Function H_CURRENCY_CODE_p return varchar2 is
	Begin
	 return H_CURRENCY_CODE;
	 END;
 Function H_POSTING_MEANING_p return varchar2 is
	Begin
	 return H_POSTING_MEANING;
	 END;
 Function H_ACCESS_SET_NAME_p return varchar2 is
	Begin
	 return H_ACCESS_SET_NAME;
	 END;
 Function P_BAL_SEGMENT_p return varchar2 is
	Begin
	 return P_BAL_SEGMENT;
	 END;
 Function P_TAXABLE_ACC_SEGMENT_p return varchar2 is
	Begin
	 return P_TAXABLE_ACC_SEGMENT;
	 END;
 Function P_TAX_ACC_SEGMENT_p return varchar2 is
	Begin
	 return P_TAX_ACC_SEGMENT;
	 END;
 Function P_WHERE_BAL_SEGMENT_p return varchar2 is
	Begin
	 return P_WHERE_BAL_SEGMENT;
	 END;
 Function P_WHERE_POSTING_STATUS_p return varchar2 is
	Begin
	 return P_WHERE_POSTING_STATUS;
	 END;
 Function P_WHERE_TAX_p return varchar2 is
	Begin
	 return P_WHERE_TAX;
	 END;
 Function P_WHERE_DAS_p return varchar2 is
	Begin
	 return P_WHERE_DAS;
	 END;
END GL_GLXJETAX_XMLP_PKG ;


/
