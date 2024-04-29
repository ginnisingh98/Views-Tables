--------------------------------------------------------
--  DDL for Package Body PO_POXRVODS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRVODS_XMLP_PKG" AS
/* $Header: POXRVODSB.pls 120.1 2007/12/25 12:11:55 krreddy noship $ */

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function BeforeReport return boolean is
begin

Declare
l_org_displayed		org_organization_definitions.organization_name%type;
Begin
	If (P_org_id is not null) then
	begin
		select organization_name
		into l_org_displayed
		from org_organization_definitions
		where organization_id = P_org_id ;

		P_org_displayed := l_org_displayed ;
	end;
	else begin
		P_org_displayed := '' ;
	end;
	End if;
End;

/*	P_OVERDUE_DATE_param:=nvl(P_OVERDUE_DATE,sysdate-1);
	if P_OVERDUE_DATE= to_date('9999/01/01','yyyy/mm/dd') then P_OVERDUE_DATE_param:=sysdate-1; end if;
*/
        FORMAT_MASK := PO_COMMON_xmlp_pkg.GET_PRECISION(P_QTY_PRECISION);
BEGIN

/*SRW.MESSAGE('23','Test message');*/null;

  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','Init failed');*/null;

  end if;

 null;


 null;


 null;

  RETURN TRUE;
END;
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

function AfterPForm return boolean is
begin
Declare


apostrophe_pos_from	number;
before_apos_from	varchar2(240);
after_apos_from		varchar2(240);
vend_length_from	varchar2(240);

apostrophe_pos_to	number;
before_apos_to		varchar2(240);
after_apos_to		varchar2(240);
vend_length_to		varchar2(240);

check_apos_from		number;
check_apos_to		number;


apostrophe_pos_buyer	number;
before_apos_buyer		varchar2(240);
after_apos_buyer		varchar2(240);
vend_length_buyer		varchar2(240);

check_apos_buyer		number;




Begin





check_apos_buyer := instr(p_buyer,'''',1);

if check_apos_buyer > 0 then

	vend_length_buyer := NVL(length(p_buyer), 0);
	apostrophe_pos_buyer := instr(p_buyer,'''',1);
	before_apos_buyer := substr(p_buyer,1,apostrophe_pos_buyer - 1);
	after_apos_buyer := substr(p_buyer,apostrophe_pos_buyer + 1,vend_length_buyer);

	P_where_buyer := 'hre.full_name = 			'||''''||before_apos_buyer||''''||''''||after_apos_buyer||'''';

else
	if (P_buyer is  null) then
   		P_where_buyer := '1=1';
	else
		P_where_buyer := 'hre.full_name = '||''''||p_buyer||'''';
	end if;
end if;





check_apos_from := instr(p_vendor_from,'''',1);
check_apos_to := instr(p_vendor_to,'''',1);



if check_apos_from > 0 then

	vend_length_from := NVL(length(p_vendor_from), 0);
	apostrophe_pos_from := instr(p_vendor_from,'''',1);
	before_apos_from := substr(p_vendor_from,1,apostrophe_pos_from - 1);
	after_apos_from := substr(p_vendor_from,apostrophe_pos_from + 1,vend_length_from);

	P_where_vendor_from := 'pov.vendor_name >= 			'||''''||before_apos_from||''''||''''||after_apos_from||'''';

else
	if (P_vendor_from is  null) then
   		P_where_vendor_from := '1=1';
	else
		P_where_vendor_from := 'pov.vendor_name >= '||''''||p_vendor_from||'''';
	end if;
end if;

if check_apos_to > 0 then

	vend_length_to := NVL(length(p_vendor_to), 0);
	apostrophe_pos_to := instr(p_vendor_to,'''',1);
	before_apos_to := substr(p_vendor_to,1,apostrophe_pos_to - 1);
	after_apos_to := substr(p_vendor_to,apostrophe_pos_to + 1,vend_length_to);

	P_where_vendor_to := 'pov.vendor_name <= '	||''''||before_apos_to||''''||''''||after_apos_to||'''';

else
	if (P_vendor_to is  null) then
   		P_where_vendor_to := '1=1';
	else
		P_where_vendor_to := 'pov.vendor_name <= '||''''||p_vendor_to||'''';
	end if;
end if;


if P_WHERE_VENDOR_FROM is null then P_WHERE_VENDOR_FROM:= 'and 1=1'; end if;
if P_where_vendor_to is null then P_where_vendor_to:= 'and 1=1'; end if;
if P_where_buyer is null then P_where_buyer:= 'and 1=1'; end if;




End;
return (TRUE);
end;

function c_item_flexformula(item_id in number,C_ORGANISATION_ID in number) return char is
   t_stmt    VARCHAR2(2000);
   C_FLEX_ITEM varchar2(800);
BEGIN


 IF item_id IS NOT NULL THEN
   t_stmt := 'SELECT SUBSTR( '||P_FLEX_ITEM||' ,1,900)
   INTO   :C_FLEX_ITEM
   FROM   mtl_system_items msi
   WHERE  inventory_item_id = :item_id
   AND    organization_id = :organization_id';
   /*SRW.DO_SQL(t_stmt);*/
   execute immediate t_stmt using P_FLEX_ITEM,item_id,C_ORGANISATION_ID;
   null;

   RETURN C_FLEX_ITEM;
 ELSE
   RETURN NULL;
 END IF;
EXCEPTION
   WHEN OTHERS THEN
        RETURN NULL;
END;


--Functions to refer Oracle report placeholders--

END PO_POXRVODS_XMLP_PKG ;


/
