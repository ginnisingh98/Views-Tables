--------------------------------------------------------
--  DDL for Package Body FA_FASINSVR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASINSVR_XMLP_PKG" AS
/* $Header: FASINSVRB.pls 120.0.12010000.1 2008/07/28 13:16:48 appldev ship $ */

function AfterReport return boolean is
begin
/*srw.break;*/null;

/*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;

function BeforeReport return boolean is
begin

/*srw.user_exit('FND SRWINIT');*/null;


DECLARE

  coaid     NUMBER;
  sobname   VARCHAR2(30);
  functcurr VARCHAR2(15);
  errbuf    VARCHAR2(132);

BEGIN


SELECT  SOB.Set_Of_Books_ID,
	SOB.name,
	SC.Category_Flex_Structure,
	SC.location_flex_structure,
	BC.Book_Type_Code,
	BC.book_class,
	BC.Accounting_Flex_Structure,
	BC.Distribution_Source_Book,
	SOB.Currency_Code,
	CR.Precision,
	BC.current_fiscal_year,
	to_char(sysdate,'DD-MON-YYYY,:HH:MI')
INTO	C_SET_OF_BOOKS_ID,
	C_SOB_NAME,
	C_Cat_Flex_Struct,
	C_locn_flex_struct,
	C_Book_Type_Code,
	C_book_class,
	C_Acct_Flex_Struct,
	C_Distribution_Source_Book,
	C_Currency_Code,
	C_Precision,
	C_current_fiscal_year,
	C_TODAYS_DATE
FROM	FND_CURRENCIES	CR,
	FA_SYSTEM_CONTROLS	SC,
	GL_SETS_OF_BOOKS 	SOB,
	FA_BOOK_CONTROLS 	BC

WHERE
	BC.Book_Type_Code = P_ASSET_BOOK
AND	SOB.Set_Of_Books_ID = BC.Set_Of_Books_ID
AND	CR.CURRENCY_CODE= SOB.CURRENCY_CODE;

l_count := SQL%rowcount;





IF P_COMPANY_FROM is not null and
   P_COMPANY_TO is not  null then

/*SRW.REFERENCE(c_acct_flex_struct);*/null;


 null;
C_ACCT_FLEX_BAL_WHERE := 'AND'||C_ACCT_FLEX_BAL_WHERE;
end if;


/*srw.reference(c_acct_flex_bal_seg);*/null;

/*SRW.REFERENCE(c_acct_flex_struct);*/null;


 null;


IF P_CATEGORY_FLEX_FROM is not null and
P_CATEGORY_FLEX_TO is not  null then

/*SRW.REFERENCE(c_cat_flex_struct);*/null;


 null;
C_WHERE_CAT_FLEX := 'AND'||C_WHERE_CAT_FLEX;
end if;

IF P_LOCATION_FLEX_FROM is not null and
P_LOCATION_FLEX_TO is not  null then

/*SRW.REFERENCE(c_locn_flex_struct);*/null;


 null;
C_WHERE_LOCN_FLEX := 'AND  '||C_WHERE_LOCN_FLEX;
end if;

IF P_CAL_METHOD_FROM is not null and
 P_CAL_METHOD_TO is not null then
   c_where_cal_method := 'and fmp.calculation_method between '''||P_CAL_METHOD_FROM||
  ''' and '''||P_CAL_METHOD_TO || '''';

END IF;

IF P_INSURANCE_COMPANY_FROM is not null and
 P_INSURANCE_COMPANY_TO is not null then

SELECT vendor_name
INTO cp_insurance_from
FROM po_vendors
where vendor_id = P_INSURANCE_COMPANY_FROM;

SELECT vendor_name
INTO cp_insurance_to
FROM po_vendors
where vendor_id = P_INSURANCE_COMPANY_TO;

c_where_ins_company := 'and pvo.vendor_name between '''||CP_INSURANCE_FROM
		|| ''' and ''' ||CP_INSURANCE_TO  || '''';
END IF;

IF P_ASSET_NUMBER_FROM is not null and
	P_ASSET_NUMBER_TO is not null then
c_where_asset_number  := 'and fad.asset_number between '''|| P_ASSET_NUMBER_FROM
      ||''' and ''' || P_ASSET_NUMBER_TO || '''';
END IF;

IF C_CURRENT_FISCAL_YEAR <> P_YEAR THEN
c_where_old_ins_data := ' and	fiv.indexation_year = ' || P_YEAR;
END IF;

END;
/*srw.break;*/null;

  return (TRUE);
end;

function CF_NO_DATA_FOUNDFormula return Number is
begin
  c_no_data_found := 'N';
return(1);
end;

--Functions to refer Oracle report placeholders--

 Function c_acct_flex_struct_p return number is
	Begin
	 return c_acct_flex_struct;
	 END;
 Function c_acct_flex_bal_seg_p return varchar2 is
	Begin
	 return c_acct_flex_bal_seg;
	 END;
 Function c_cat_flex_struct_p return number is
	Begin
	 return c_cat_flex_struct;
	 END;
 Function c_where_cat_flex_p return varchar2 is
	Begin
	 return c_where_cat_flex ;
	 END;
 Function c_cat_flex_seg_p return varchar2 is
	Begin
	 return c_cat_flex_seg;
	 END;
 Function C_SOB_NAME_p return varchar2 is
	Begin
	 return C_SOB_NAME;
	 END;
 Function c_book_class_p return varchar2 is
	Begin
	 return c_book_class;
	 END;
 Function c_book_type_code_p return varchar2 is
	Begin
	 return c_book_type_code;
	 END;
 Function c_distribution_source_book_p return varchar2 is
	Begin
	 return c_distribution_source_book;
	 END;
 Function C_currency_code_p return varchar2 is
	Begin
	 return C_currency_code;
	 END;
 Function c_precision_p return number is
	Begin
	 return c_precision;
	 END;
 Function c_locn_flex_struct_p return number is
	Begin
	 return c_locn_flex_struct;
	 END;
 Function c_loc_flex_seg_p return varchar2 is
	Begin
	 return c_loc_flex_seg;
	 END;
 Function c_where_locn_flex_p return varchar2 is
	Begin
	 return c_where_locn_flex;
	 END;
 Function c_acct_flex_bal_where_p return varchar2 is
	Begin
	 return c_acct_flex_bal_where;
	 END;
 Function C_NO_DATA_FOUND_p return varchar2 is
	Begin
	 return C_NO_DATA_FOUND;
	 END;
 Function C_TODAYS_DATE_p return varchar2 is
	Begin
	 return C_TODAYS_DATE;
	 END;
 Function c_where_cal_method_p return varchar2 is
	Begin
	 return c_where_cal_method;
	 END;
 Function c_where_ins_company_p return varchar2 is
	Begin
	 return c_where_ins_company;
	 END;
 Function c_where_asset_number_p return varchar2 is
	Begin
	 return c_where_asset_number;
	 END;
 Function C_WHERE_OLD_INS_DATA_p return varchar2 is
	Begin
	 return C_WHERE_OLD_INS_DATA;
	 END;
 Function C_CURRENT_FISCAL_YEAR_p return varchar2 is
	Begin
	 return C_CURRENT_FISCAL_YEAR;
	 END;
 Function L_count_p return number is
	Begin
	 return L_count;
	 END;
 Function CP_insurance_from_p return varchar2 is
	Begin
	 return CP_insurance_from;
	 END;
 Function CP_insurance_to_p return varchar2 is
	Begin
	 return CP_insurance_to;
	 END;
END FA_FASINSVR_XMLP_PKG ;


/
