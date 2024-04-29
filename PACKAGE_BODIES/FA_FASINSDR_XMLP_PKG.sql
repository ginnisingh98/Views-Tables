--------------------------------------------------------
--  DDL for Package Body FA_FASINSDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASINSDR_XMLP_PKG" AS
/* $Header: FASINSDRB.pls 120.0.12010000.1 2008/07/28 13:16:46 appldev ship $ */

function AfterReport return boolean is
begin

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
	BC.Book_Type_Code,
	BC.book_class,
	BC.Accounting_Flex_Structure,
	SC.location_flex_structure,
	BC.Distribution_Source_Book,
	SOB.Currency_Code,
	CR.Precision,
	to_char(sysdate,'DD-MON-YYYY')
INTO	C_SET_OF_BOOKS_ID,
	C_SOB_NAME,
	C_Cat_Flex_Struct,
	C_Book_Type_Code,
	C_book_class,
	C_Acct_Flex_Struct,
	C_locn_flex_struct,
	C_Distribution_Source_Book,
	C_Currency_Code,
	C_Precision,
	C_TODAYS_DATE
FROM	FND_CURRENCIES	CR,
	FA_SYSTEM_CONTROLS	SC,
	GL_SETS_OF_BOOKS 	SOB,
	FA_BOOK_CONTROLS 	BC

WHERE
	BC.Book_Type_Code = P_ASSET_BOOK
AND	SOB.Set_Of_Books_ID = BC.Set_Of_Books_ID
AND	CR.CURRENCY_CODE= SOB.CURRENCY_CODE;


IF P_COMPANY_FROM is not null and
   P_COMPANY_TO is not  null then

/*SRW.REFERENCE(c_acct_flex_struct);*/null;


 null;
C_ACCT_FLEX_BAL_WHERE := 'AND'||C_ACCT_FLEX_BAL_WHERE;
end if;
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
C_WHERE_LOCN_FLEX := 'AND'||C_WHERE_LOCN_FLEX;
end if;

END;
  return (TRUE);
end;

function C_1Formula return VARCHAR2 is
begin

c_no_data_found := 'N';
RETURN NULL; end;

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
	 return c_where_cat_flex;
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
 Function c_precision_p return varchar2 is
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
 Function C_WHERE_ASSET_NUMBER_p return varchar2 is
	Begin
	 return C_WHERE_ASSET_NUMBER;
	 END;
END FA_FASINSDR_XMLP_PKG ;


/
