--------------------------------------------------------
--  DDL for Package Body PO_POXRQRCO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRQRCO_XMLP_PKG" AS
/* $Header: POXRQRCOB.pls 120.1 2008/01/06 08:06:27 dwkrishn noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin



get_boiler_plates ;



DECLARE

l_message1	     po_lookup_codes.description%TYPE ;

BEGIN

QTY_PRECISION:=po_common_xmlp_pkg.get_precision(P_QTY_PRECISION);
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  /*srw.user_exit('FND INSTALLATION OUTPUT_TYPE="STATUS"
                                 OUTPUT_FIELD=":P_OE_STATUS"
                                         APPS="ONT"') ;*/null;


  if P_OE_STATUS <> 'I' then
	select description
	into l_message1
	from po_lookup_codes
	where lookup_type = 'SRW MESSAGE'
	and lookup_code = 'CANNOT RUN PROGRAM' ;

            /*srw.message(1,l_message1) ;*/null;

        return false;
  end if;


  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN

	select description
	into l_message1
	from po_lookup_codes
	where lookup_type = 'SRW MESSAGE'
	and lookup_code = 'FAILURE TO GET STATUS' ;

            /*srw.message(1,l_message1) ;*/null;

            return false;

END;

BEGIN
  if (get_p_struct_num <> TRUE )
     then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;

 null;


 null;


 null;


 null;
  RETURN TRUE;
END;

  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
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

procedure get_boiler_plates is

w_industry_code varchar2(20);
w_industry_stat varchar2(20);

begin

if fnd_installation.get(0, 0,
                        w_industry_stat,
	    	        w_industry_code) then
   if w_industry_code = 'C' then
      c_order_title := null ;
   else
      get_lookup_meaning('IND_SALES_ORDER',
                       	 w_industry_code,
			 c_order_title);
   end if;
end if;

c_industry_code :=   w_Industry_code ;

end ;

procedure get_lookup_meaning(p_lookup_type	in varchar2,
			     p_lookup_code	in varchar2,
			     p_lookup_meaning  	in out nocopy varchar2)
			    is

w_meaning varchar2(80);

begin

select meaning
  into w_meaning
  from fnd_lookups
 where lookup_type = p_lookup_type
   and lookup_code = p_lookup_code ;

p_lookup_meaning := w_meaning ;

exception
   when no_data_found then
        		p_lookup_meaning := null ;

end ;

function set_display_for_core return boolean is

begin

if c_industry_code = 'C' then
   return(TRUE);
else
   if c_order_title is not null then
      return(FALSE);
   else
      return(TRUE);
   end if;
end if;

RETURN NULL; end;

function set_display_for_gov return boolean is

begin


if c_industry_code = 'C' then
   return(FALSE);
else
   if c_order_title is not null then
      return(TRUE);
   else
      return(FALSE);
   end if;
end if;

RETURN NULL; end ;

--Functions to refer Oracle report placeholders--

 Function C_industry_code_p return varchar2 is
	Begin
	 return C_industry_code;
	 END;
 Function C_order_title_p return varchar2 is
	Begin
	 return C_order_title;
	 END;
END PO_POXRQRCO_XMLP_PKG ;


/
