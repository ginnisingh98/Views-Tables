--------------------------------------------------------
--  DDL for Package Body PO_POXRQUNI_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRQUNI_XMLP_PKG" AS
/* $Header: POXRQUNIB.pls 120.1 2007/12/25 12:01:52 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

DECLARE
   l_yes_no      fnd_lookups.meaning%type;
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;


  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;

  IF P_PRINT_PRICE_HISTORY is NULL THEN
     P_PRINT_PRICE_HISTORY_1 := 'N';
     ELSE
     P_PRINT_PRICE_HISTORY_1 := P_PRINT_PRICE_HISTORY;
  END IF;

     SELECT meaning
     INTO l_yes_no
     FROM FND_LOOKUPS
     WHERE lookup_type = 'YES_NO'
     AND lookup_code = P_PRINT_PRICE_HISTORY_1;

     P_PRINT_PRICE_HISTORY_DISP := l_yes_no;

  FORMAT_MASK := PO_COMMON_XMLP_PKG.GET_PRECISION(P_qty_precision);
 null;


 null;


 null;

  RETURN TRUE;
END;  return (TRUE);
end;

procedure get_precision is
begin
/*srw.attr.mask        :=  SRW.FORMATMASK_ATTR;*/null;

if P_qty_precision = 0 then /*srw.attr.formatmask  := '-NNN,NNN,NNN,NN0';*/null;

else
if P_qty_precision = 1 then /*srw.attr.formatmask  := '-NNN,NNN,NNN,NN0.0';*/null;

else
if P_qty_precision = 3 then /*srw.attr.formatmask  :=  '-NN,NNN,NNN,NN0.000';*/null;

else
if P_qty_precision = 4 then /*srw.attr.formatmask  :=   '-N,NNN,NNN,NN0.0000';*/null;

else
if P_qty_precision = 5 then /*srw.attr.formatmask  :=     '-NNN,NNN,NN0.00000';*/null;

else
if P_qty_precision = 6 then /*srw.attr.formatmask  :=      '-NN,NNN,NN0.000000';*/null;

else /*srw.attr.formatmask  :=  '-NNN,NNN,NNN,NN0.00';*/null;

end if; end if; end if; end if; end if; end if;
/*srw.set_attr(0,srw.attr);*/null;

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

function AfterPForm return boolean is
begin



  if(p_location is not null) then

     select hlt.location_id
     into p_location_id
     from hr_locations_all_tl hlt
     where hlt.location_code = p_location
           and hlt.language=userenv('LANG');
  end if;
  if(P_NEEDBY_DATE_FROM <> to_date('1900/01/01','yyyy/mm/dd') and P_NEED_BY_DATE_TO <> to_date('9999/01/01','yyyy/mm/dd')) then
P_NEEDBY_DATE_FROM1 := to_char(P_NEEDBY_DATE_FROM,'DD-MON-YYYY');
P_NEED_BY_DATE_TO1 := to_char(P_NEED_BY_DATE_TO,'DD-MON-YYYY');
   else
P_NEEDBY_DATE_FROM1 := '';
P_NEED_BY_DATE_TO1 := '';
   end if;
  return (TRUE);
end;

function locationformula(p_location_id in number) return char is

x_location_code varchar2(100);
x_count number;

begin

  if(p_location is not null) then
    return p_location;
  else
   begin
     select hlt.location_code
     into x_location_code
     from hr_locations_all_tl hlt
     where hlt.location_id=p_location_id
           and hlt.language=userenv('LANG');

   exception when no_data_found then

     select (substr(hzl.address1,1,50) || '-' || hzl.city )
     into x_location_code
     from hz_locations hzl
     where hzl.location_id = location_id;

   end;
   return x_location_code;
  end if;
end;

--Functions to refer Oracle report placeholders--

END PO_POXRQUNI_XMLP_PKG ;


/
