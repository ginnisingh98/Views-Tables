--------------------------------------------------------
--  DDL for Package Body PO_POXPRREQ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXPRREQ_XMLP_PKG" AS
/* $Header: POXPRREQB.pls 120.1 2007/12/25 11:28:07 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;




  If P_req_num_from = P_req_num_to THEN
	P_single_req_print := 1;
  END IF;




    if (get_p_struct_num <> TRUE )
     then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;
  if (get_chart_of_accounts_id <> TRUE )
  then /*SRW.MESSAGE('2','Init failed');*/null;

  end if;

 null;


 null;


 null;

RETURN TRUE;
END;  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function get_p_struct_num return boolean is

l_p_struct_num number;

begin
        select structure_id
        into l_p_struct_num
        from mtl_default_sets_view
        where functional_area_id = 2 ;

        P_STRUCT_NUM := l_p_struct_num ;

        return(TRUE) ;

        RETURN NULL; exception
        when others then return(FALSE) ;
end;

function get_chart_of_accounts_id return boolean is

l_chart_of_accounts_id number;

begin
        select gsob.chart_of_accounts_id
        into l_chart_of_accounts_id
        from gl_sets_of_books gsob,
        financials_system_parameters fsp
        where  fsp.set_of_books_id = gsob.set_of_books_id ;

        P_CHART_OF_ACCOUNTS_ID := l_chart_of_accounts_id ;

        return(TRUE) ;

        RETURN NULL; exception
        when others then return(FALSE) ;
end;

function g_requisitiongroupfilter(req_num_type in varchar2, Requisition in varchar2) return boolean is
begin

declare

check_req_num number;
check_req_num_from number;
check_req_num_to number;

begin

if req_num_type = 'NUMERIC' then
    if rtrim(Requisition, '0123456789') is null then
        check_req_num := to_number(Requisition);
    else
        check_req_num := -1;
    end if;

    if rtrim(nvl(P_req_num_from, Requisition), '0123456789') is null then
        check_req_num_from := to_number(nvl(P_req_num_from, Requisition));
    else
        check_req_num_from := -1;
    end if;

    if rtrim(nvl(P_req_num_to, Requisition), '0123456789') is null then
        check_req_num_to := to_number(nvl(P_req_num_to, Requisition));
    else
        check_req_num_to := -1;
    end if;

    if check_req_num between check_req_num_from and check_req_num_to then
        return true ;
    else
        return false;
    end if;
else
    return true;
end if;

end ;
  return (TRUE);
end;

function line_notesformula(line_note_datatype_id in number, line_note_media_id in number) return char is
short_note Varchar2(2000);
long_note Long;
begin
  if line_note_datatype_id = 1 then
    select short_text
      into short_note
      from fnd_documents_short_text
     where media_id = line_note_media_id;
    return short_note;
  elsif line_note_datatype_id = 2 then
    select long_text
      into long_note
      from fnd_documents_long_text
     where media_id = line_note_media_id;
    return long_note;
  else
    return 'Attachment is not a Text format';
  end if;

end;

function item_noteformula(item_note_datatype_id in number, item_note_media_id in number) return char is
short_note Varchar2(2000);
long_note Long;
begin
  if item_note_datatype_id = 1 then
    select short_text
      into short_note
      from fnd_documents_short_text
     where media_id = item_note_media_id;
    return short_note;
  elsif item_note_datatype_id = 2 then
    select long_text
      into long_note
      from fnd_documents_long_text
     where media_id = item_note_media_id;
    return long_note;
  else
    return 'Attachment is not a Text format';
  end if;

end;

function header_notesformula(header_note_datatype_id in number, header_note_media_id in number) return char is
short_note Varchar2(2000) := NULL;
long_note Long := NULL;
begin
  if header_note_datatype_id = 1 then
                IF (header_note_media_id IS NOT NULL)THEN
      select short_text
        into short_note
        from fnd_documents_short_text
        where media_id = header_note_media_id;
    END IF;
    return short_note;
  elsif header_note_datatype_id = 2 then
    IF (header_note_media_id IS NOT NULL)THEN
      select long_text
        into long_note
        from fnd_documents_long_text
        where media_id = header_note_media_id;
    END IF;
    return long_note;
  else
    return 'Attachment is not a Text format';
  end if;

end;

function c_amount_precision(GL_CURRENCY in varchar2, C_AMOUNT in number) return number is





X_CURRENCY_PRECISION NUMBER;
DUMMY_NUM1 NUMBER;
DUMMY_NUM2 NUMBER;
BEGIN

   /*SRW.REFERENCE(C_AMOUNT);*/null;

   /*SRW.REFERENCE(GL_CURRENCY);*/null;

   FND_CURRENCY.GET_INFO(GL_CURRENCY,X_CURRENCY_PRECISION,DUMMY_NUM1,DUMMY_NUM2);
   return  ROUND(C_AMOUNT,X_CURRENCY_PRECISION);

END;

function c_total_amount_precision(GL_CURRENCY in varchar2, TOTAL_AMOUNT in number) return number is





X_CURRENCY_PRECISION NUMBER;
TOT_AMOUNT_WITH_PRECISION_DISP VARCHAR2(38);
DUMMY_NUM1 NUMBER;
DUMMY_NUM2 NUMBER;

BEGIN

   /*SRW.REFERENCE(GL_CURRENCY);*/null;

   /*SRW.REFERENCE(TOTAL_AMOUNT);*/null;

   FND_CURRENCY.GET_INFO(GL_CURRENCY,X_CURRENCY_PRECISION,DUMMY_NUM1, DUMMY_NUM2);
   --return ROUND(TOTAL_AMOUNT,X_CURRENCY_PRECISION);
   return X_CURRENCY_PRECISION;


END;

--Functions to refer Oracle report placeholders--

END PO_POXPRREQ_XMLP_PKG ;


/
