--------------------------------------------------------
--  DDL for Package Body PO_POXDETIT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXDETIT_XMLP_PKG" AS
/* $Header: POXDETITB.pls 120.1 2007/12/25 10:54:36 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

declare
l_active_inactive     po_lookup_codes.displayed_field%type ;
begin
if P_active_inactive is not null then

    select displayed_field
    into l_active_inactive
    from po_lookup_codes
    where lookup_code = P_active_inactive
    and lookup_type = 'ACTIVE_INACTIVE';

    P_act_inact_disp := l_active_inactive ;

else

    P_act_inact_disp := '' ;

end if;

end;

BEGIN
if (get_p_struct_num = false ) then
/*srw.message(1,'Failure to get :P_struct num.') ;*/null;

end if;
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'srw_init');*/null;

END;
BEGIN
   select gsb.chart_of_accounts_id into p_chart_of_accounts_id
   from gl_sets_of_books gsb, financials_system_parameters fsp
   where gsb.set_of_books_id = fsp.set_of_books_id;
EXCEPTION
   when no_data_found then
	/*srw.message(1,'chart of accounts id');*/null;

END;
BEGIN

  /*srw.user_exit('FND INSTALLATION OUTPUT_TYPE="STATUS"
                                 OUTPUT_FIELD=":P_OFA_STATUS"
                                         APPS="OFA"') ;*/null;

 temp:= fnd_installation.get_app_info('OFA',P_OFA_STATUS,l_INDUSTRY,l_ORACLE_SCHEMA);

/*srw.message(1,'OFA Installation status is ' || P_OFA_STATUS) ;*/null;


  /*srw.user_exit('FND INSTALLATION OUTPUT_TYPE="STATUS"
                                 OUTPUT_FIELD=":P_CST_STATUS"
                                         APPS="INV"') ;*/null;


 temp:= fnd_installation.get_app_info('INV',P_CST_STATUS,l_INDUSTRY,l_ORACLE_SCHEMA);

/*srw.message(1,'CST Installation status is ' || P_CST_STATUS) ;*/null;



 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Item Flex');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Acc Flex');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Cat Flex');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Category Where');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Item Where');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Item Orderby');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Categroy Orderby');*/null;

END;

IF (P_OFA_STATUS = 'I' ) then begin
 select count(*), max(category_flex_structure)
 into   P_FA_INSTALLED, P_acat_struct_num
 from fa_system_controls;
end;
end if;

if P_FA_INSTALLED <> 0 then begin

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Ass Flex');*/null;

END; end if;
RETURN TRUE;  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function orderby_clauseFormula return VARCHAR2 is
begin

if P_ORDERBY = 'CATEGORY' then
   return(P_ORDERBY_CAT);
else
   return(P_ORDERBY_ITEM);
end if;
RETURN NULL; end;

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

function C_OFA_dynamicFormula return VARCHAR2 is
begin

if (P_OFA_STATUS = 'I') then return ('fa_categories') ;
else return ('gl_code_combinations') ;
end if ;
RETURN NULL; end;

function C_OFA_WhereFormula return VARCHAR2 is
begin

IF (P_OFA_STATUS = 'I') then return ('AND      msi.asset_category_id             = fac.category_id (+)') ;
else return('and msi.expense_account               = fac.code_combination_id (+)') ;
end if;

RETURN NULL; end;

function C_CST_SELECTFormula return VARCHAR2 is
begin

IF (P_CST_STATUS = 'I') THEN
RETURN(',CIC.UNBURDENED_COST    standard_cost') ;
else
  RETURN(',null');
END IF;
RETURN NULL; end;

function C_CST_FROMFormula return VARCHAR2 is
begin


  IF (P_CST_STATUS = 'I') THEN
 	RETURN(',CST_ITEM_COSTS CIC,MTL_PARAMETERS MP');
	  else
   RETURN('');
  END IF;

  RETURN NULL;
end;

function C_CST_WHEREFormula return VARCHAR2 is
begin


 IF (P_CST_STATUS = 'I') THEN
  RETURN('
	AND  cic.organization_id = mp.cost_organization_id
	AND  cic.cost_type_id = mp.primary_cost_method
	AND  cic.inventory_item_id (+)  = msi.inventory_item_id
	AND  cic.organization_id (+)    = msi.organization_id
        ') ;
	  else
   RETURN('');
 END IF;
 RETURN NULL;

end;

function noteformula(item_note_datatype_id in number, item_note_media_id in number) return char is
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

--Functions to refer Oracle report placeholders--

END PO_POXDETIT_XMLP_PKG ;


/
