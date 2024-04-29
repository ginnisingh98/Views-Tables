--------------------------------------------------------
--  DDL for Package Body PO_POXPOCOM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXPOCOM_XMLP_PKG" AS
/* $Header: POXPOCOMB.pls 120.1 2007/12/25 11:12:22 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

declare

l_sort     po_lookup_codes.displayed_field%type ;
begin
/*SRW.USER_EXIT('FND SRWINIT');*/null;

P_SORT_1:=P_SORT;


if P_SORT_1 is not null then

    select displayed_field
    into l_sort
    from po_lookup_codes
    where lookup_code = P_SORT_1
    and lookup_type = 'SRS ORDER BY';

    P_orderby_displayed := l_sort ;

else
    select displayed_field
    into l_sort
    from po_lookup_codes
    where lookup_code = 'VENDOR'
    and lookup_type = 'SRS ORDER BY';

    P_orderby_displayed := l_sort ;

end if;


if (UPPER(P_SORT_1) = 'VENDOR') THEN

    select displayed_field
    into l_sort
    from po_lookup_codes
    where lookup_code = 'BUYER'
    and lookup_type = 'SRS ORDER BY';

    P_ALT_orderby_displayed := l_sort ;

elsif (UPPER(P_SORT_1) = 'BUYER') THEN

    select displayed_field
    into l_sort
    from po_lookup_codes
    where lookup_code = 'VENDOR'
    and lookup_type = 'SRS ORDER BY';

    P_ALT_orderby_displayed := l_sort ;

else

    P_ALT_orderby_displayed := 'Buyer Name' ;

end if;



end;

BEGIN
 /*SRW.USER_EXIT('FND SRWINIT');*/null;

 EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
  /*SRW.MESSAGE(1,'srw_iinit');*/null;

END;
BEGIN
  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;
  if (get_period_num <> TRUE )
    then begin
        /*SRW.MESSAGE('2','P Period Num Init failed.') ;*/null;

        raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

         end;
  end if;
END;

BEGIN

 null;

  /*SRW.MESSAGE('99', P_WHERE_CAT);*/null;

  return(true);
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Cat Where');*/null;


END;     return (TRUE);
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

function get_period_num return boolean is

l_period_num number;
l_period_year number;

begin
     select distinct gps.period_num, gps.period_year
     into l_period_num, l_period_year
     from gl_period_statuses		gps,
	  financials_system_parameters fsp
     where gps.period_name = P_PERIOD
     and gps.set_of_books_id = fsp.set_of_books_id ;

     P_PERIOD_NUM := l_period_num;
     P_PERIOD_YEAR := l_period_year;

     return(TRUE) ;

     RETURN NULL; exception
     when others then return(FALSE) ;
end;

function C_break_headerFormula return VARCHAR2 is
begin





declare

l_sort     po_lookup_codes.displayed_field%type ;

begin

        if P_SORT_1 is null then
                select displayed_field
                into l_sort
                from po_lookup_codes
                where lookup_code = 'VENDOR'
                and lookup_type = 'SRS ORDER BY';
                return(l_sort);
        elsif (UPPER(P_SORT_1) = 'VENDOR') then
                select displayed_field
                into l_sort
                from po_lookup_codes
                where lookup_code = 'VENDOR'
                and lookup_type = 'SRS ORDER BY';
                return(l_sort);
        else
                select displayed_field
                into l_sort
                from po_lookup_codes
                where lookup_code = 'BUYER'
                and lookup_type = 'SRS ORDER BY';
                return(l_sort);

	end if;
end;

end;

function C_other_headerFormula return VARCHAR2 is
begin

if P_SORT_1 is null then return('Buyer') ;
elsif P_SORT_1 = 'VENDOR' then return('Buyer') ;
else return('Vendor') ;
end if;
RETURN NULL; end;

function c_sum_allformula(C_break_per1 in number, C_break_per2 in number, C_break_per3 in number, C_break_per4 in number, c_precision in number) return number is
begin

/*srw.reference(C_break_per1) ;*/null;

/*srw.reference(C_break_per2) ;*/null;

/*srw.reference(C_break_per3) ;*/null;

/*srw.reference(C_break_per4) ;*/null;

/*srw.reference(c_precision);*/null;

return(round((nvl(C_break_per1,0) + nvl(C_break_per2,0) + nvl(C_break_per3,0) + nvl(C_break_per4,0)), c_precision)) ;
end;

function G_periodsGroupFilter return boolean is
begin

return true;  return (TRUE);
end;

function c_break_per1_round(c_break_per1 in number, c_precision in number) return number is
begin

/*srw.reference(c_precision);*/null;

/*srw.reference(c_break_per1);*/null;

return(round(c_break_per1, c_precision));

end;

function c_break_per2_round(c_break_per2 in number, c_precision in number) return number is
begin

/*srw.reference(c_precision);*/null;

/*srw.reference(c_break_per2);*/null;


return(round(c_break_per2, c_precision));

end;

function c_break_per3_round(c_break_per3 in number, c_precision in number) return number is
begin

/*srw.reference(c_precision);*/null;

/*srw.reference(c_break_per3);*/null;


return(round(c_break_per3, c_precision));
end;

function c_break_per4_round(c_break_per4 in number, c_precision in number) return number is
begin

/*srw.reference(c_precision);*/null;

/*srw.reference(c_break_per4);*/null;


return(round(c_break_per4, c_precision));

end;

function c_amt_per1_round(c_amount_per1 in number, c_precision in number) return number is
begin

/*srw.reference(c_precision);*/null;

/*srw.reference(c_amount_per1);*/null;


return(round(c_amount_per1, c_precision));

end;

function c_amt_per2_round(c_amount_per2 in number, c_precision in number) return number is
begin

/*srw.reference(c_precision);*/null;

/*srw.reference(c_amount_per2);*/null;


return(round(c_amount_per2, c_precision));

end;

function c_amt_per3_round(c_amount_per3 in number, c_precision in number) return number is
begin

/*srw.reference(c_precision);*/null;

/*srw.reference(c_amount_per3);*/null;


return(round(c_amount_per3, c_precision));
end;

function c_amt_per4_round(c_amount_per4 in number, c_precision in number) return number is
begin

/*srw.reference(c_precision);*/null;

/*srw.reference(c_amount_per4);*/null;


return(round(c_amount_per4, c_precision));

end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXPOCOM_XMLP_PKG ;


/
