--------------------------------------------------------
--  DDL for Package Body PO_POXRRCVV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRRCVV_XMLP_PKG" AS
/* $Header: POXRRCVVB.pls 120.2 2007/12/25 13:27:29 krreddy noship $ */

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;


/*SRW.MESSAGE(1, 'Report finished ' ||
         TO_CHAR(sysdate, 'fmMonth DD YYYY, HH:MIam'));*/null;

--raise_application_error(-20001,'After report');
  return (TRUE);
end;

function BeforeReport return boolean is
begin

/*srw.message(1,'before report');*/null;

DECLARE
    L_ORGANIZATION   VARCHAR2(60);
    L_EXT_PREC       NUMBER;
    L_ROUND_UNIT     NUMBER;
    L_SORT_BY        VARCHAR2(80);
    L_CAT_SET_NAME   VARCHAR2(30);
    L_DEF_COST_TYPE  NUMBER;
    L_PRIMARY_COST_METHOD NUMBER;
    L_COST_TYPE      VARCHAR2(30);
    L_DETAIL_LEVEL   VARCHAR2(80);
    L_DOCUMENT_TYPE_DISPLAYED VARCHAR2(80) ;
    L_FCN_CURRENCY   VARCHAR2(15);
    invalid_option   EXCEPTION;
    l_stmt_num       NUMBER;
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(8000);
    l_return_status  VARCHAR2(1);
    l_as_of_date     VARCHAR2(30);
    l_cst_inv_val    EXCEPTION;
    l_tmp  number;-- tmp

BEGIN
l_stmt_num := 0;





begin
	select primary_cost_method
	into l_primary_cost_method
	from mtl_parameters
	where organization_id = P_org_id ;

	P_COST_TYPE_ID := l_primary_cost_method ;
end;
if P_SORT_OPTION is null then
  P_SORT_OPTION:= 'ITEM';
end if;
l_stmt_num :=2;
IF (P_SORT_OPTION = 'ITEM' ) THEN P_SORT_OPTION1 := 1;
ELSIF (P_SORT_OPTION = 'CATEGORY' ) THEN  P_SORT_OPTION1 := 2;
ELSIF (P_SORT_OPTION = 'LOCATION' ) THEN  P_SORT_OPTION1 := 3;
ELSIF (P_SORT_OPTION = 'VENDOR' ) THEN  P_SORT_OPTION1 := 4;
ELSE
RAISE_application_error(-20101,'Invalid Sort Option');/*SRW.PROGRAM_ABORT;*/null;

END IF;

SELECT  PLC.DISPLAYED_FIELD
INTO    L_SORT_BY
FROM    PO_LOOKUP_CODES PLC
WHERE   PLC.LOOKUP_TYPE (+) = 'SRS ORDER BY'
AND     PLC.LOOKUP_CODE (+) = P_SORT_OPTION ;

P_SORT_HEADER_DISPLAYED       := L_SORT_BY;




l_stmt_num :=20;

SELECT  O.ORGANIZATION_NAME,
        NVL(EXTENDED_PRECISION, PRECISION),
        NVL(MINIMUM_ACCOUNTABLE_UNIT, POWER(10,NVL(-PRECISION,0))),
        MCS.CATEGORY_SET_NAME,
        DEFAULT_COST_TYPE_ID,
        COST_TYPE,
        PLC.DISPLAYED_FIELD,
        LU2.MEANING
INTO    L_ORGANIZATION,
        L_EXT_PREC,
        L_ROUND_UNIT,
        L_CAT_SET_NAME,
        L_DEF_COST_TYPE,
        L_COST_TYPE,
        L_SORT_BY,
        L_DETAIL_LEVEL
FROM    ORG_ORGANIZATION_DEFINITIONS O,
        FND_CURRENCIES FC,
        MTL_CATEGORY_SETS MCS,
        CST_COST_TYPES,
        PO_LOOKUP_CODES PLC,
        MFG_LOOKUPS LU2
WHERE   FC.CURRENCY_CODE = P_CURRENCY_CODE
AND     O.ORGANIZATION_ID = P_ORG_ID
AND     MCS.CATEGORY_SET_ID = P_CATEGORY_SET
AND     COST_TYPE_ID = P_COST_TYPE_ID
AND     PLC.LOOKUP_TYPE (+) = 'SRS ORDER BY'
AND     PLC.LOOKUP_CODE (+) = P_SORT_OPTION
AND     LU2.LOOKUP_TYPE (+) = 'CST_BICR_DETAIL_OPTION'
AND     LU2.LOOKUP_CODE (+) = P_RPT_OPTION;

l_stmt_num := 30;
P_ORGANIZATION  := L_ORGANIZATION;
ROUND_UNIT      := L_ROUND_UNIT;
P_CAT_SET_NAME  := L_CAT_SET_NAME;
P_SORT_BY       := L_SORT_BY;
P_DETAIL_LEVEL  := L_DETAIL_LEVEL;
P_DEF_COST_TYPE := L_DEF_COST_TYPE;
P_COST_TYPE     := L_COST_TYPE;
P_DOCUMENT_TYPE_DISPLAYED  := '' ;


l_stmt_num := 40;
/*SRW.USER_EXIT('FND SRWINIT');*/null;




SELECT  currency_code
INTO    l_fcn_currency
FROM    cst_organization_definitions cod
WHERE   cod.organization_id = P_org_id;

l_stmt_num := 50;
IF L_FCN_CURRENCY = P_CURRENCY_CODE THEN
    P_CURRENCY_DSP := P_CURRENCY_CODE;
ELSE
    P_CURRENCY_DSP := P_CURRENCY_CODE || ' @ ' ||
               TO_CHAR(ROUND(1/P_EXCHANGE_RATE,5)) || L_FCN_CURRENCY;
END IF;

l_stmt_num := 70;

 null;


l_stmt_num := 80;

 null;

l_stmt_num := 120;
CST_Inventory_PUB.Calculate_InventoryValue(
    p_api_version => 1.0,
    p_init_msg_list => CST_Utility_PUB.get_true,
    p_organization_id => P_ORG_ID,
    p_onhand_value => 0,
    p_intransit_value => 0,
    p_receiving_value => 1,
    p_valuation_date => to_Date(P_AS_OF_DATE,'YYYY/MM/DD HH24:MI:SS'),
    p_cost_type_id => P_COST_TYPE_ID,
    p_item_from => P_ITEM_FROM,
    p_item_to => P_ITEM_TO,
    p_category_set_id => P_CATEGORY_SET,
    p_category_from => P_CAT_FROM,
    p_category_to => P_CAT_TO,
    p_cost_group_from => NULL,
    p_cost_group_to => NULL,
    p_subinventory_from => NULL,
    p_subinventory_to => NULL,
    p_qty_by_revision => P_ITEM_REVISION,
    p_zero_cost_only => 0,
    p_zero_qty => NULL,
    p_expense_item => NULL,
    p_expense_sub => NULL,
    p_unvalued_txns => NULL,
    p_receipt => NULL,
    p_shipment => NULL,
    p_own => 1,
    p_detail => NULL,
    p_cost_enabled_only => 0,
    p_one_time_item => P_ONE_TIME,
    p_include_period_end => P_PERIOD_END,
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data
  );

  l_stmt_num := 130;
  IF l_return_status <> CST_Utility_PUB.get_ret_sts_success
  THEN
    RAISE l_cst_inv_val;
  END IF;

  l_stmt_num := 140;
  FND_MSG_PUB.count_and_get(
    p_encoded => CST_Utility_PUB.get_false,
    p_count => l_msg_count,
    p_data => l_msg_data
  );

  l_stmt_num := 150;
  IF l_msg_count > 0
  THEN
    FOR i IN 1 ..l_msg_count
    LOOP
      l_msg_data := FND_MSG_PUB.get(i, CST_Utility_PUB.get_false);
      FND_FILE.PUT_LINE(CST_Utility_PUB.get_log, i ||'-'||l_msg_data);
    END LOOP;
  END IF;

  select to_char(to_date(P_AS_OF_DATE,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS')
  into l_as_of_date
  from dual;

  P_AS_OF_DATE1 :=l_as_of_date;
   FORMAT_MASK := PO_COMMON_XMLP_PKG.GET_PRECISION(P_qty_precision);

/*SRW.MESSAGE(0, 'Report started ' ||
         TO_CHAR(sysdate, 'fmMonth DD YYYY, HH:MIam'));*/null;


EXCEPTION
  WHEN invalid_option THEN
        raise_application_error(-20101,null);null;

  WHEN OTHERS THEN
   raise_application_error(-20101,SQLERRM);


    FND_MSG_PUB.count_and_get(
      		p_encoded => CST_Utility_PUB.get_false,
      		p_count => l_msg_count,
      		p_data => l_msg_data
    	        );
    IF l_msg_count > 0 THEN
      	FOR i IN 1 ..l_msg_count
      	 LOOP
          l_msg_data := FND_MSG_PUB.get(i, CST_Utility_PUB.get_false);
          FND_FILE.PUT_LINE(CST_Utility_PUB.get_log, i ||'-'||l_msg_data);
      	END LOOP;
    END IF;
 --   RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;


END;
  return (TRUE);
end;

function itemcatformula(CATEGORY_PSEG in varchar2) return varchar2 is
begin

/*SRW.REFERENCE(CATEGORY);*/null;

/*SRW.REFERENCE(CATEGORY_SEGMENT);*/null;

/*SRW.REFERENCE(CATEGORY_PSEG);*/null;

IF P_SORT_OPTION1 = 2 OR P_SORT_OPTION1 = 6 THEN
    RETURN(CATEGORY_PSEG);
ELSE
    RETURN('I have absolutely no idea why I am doing this');
END IF;
RETURN NULL; end;

function comp_avg_unit_price (ITEM_QUANTITY in number, ITEM_TOTAL_PUR_VALUE in number, c_ext_precision in number) return number is
comp NUMBER;
BEGIN
if ITEM_QUANTITY > 0 then
   comp := ROUND(nvl(ITEM_TOTAL_PUR_VALUE,0) /
           ITEM_QUANTITY,c_ext_precision);
else
   comp := ROUND(nvl(ITEM_TOTAL_PUR_VALUE,0),
	   c_ext_precision);
end if;
return (comp);
end;

procedure get_precision1 is
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

function total_pur_valueformula(total_purchase_value in number) return number is
begin

	return total_purchase_value;
end;

function c_quantityformula(quantity in number) return number is
begin
  return round(quantity, P_qty_precision);
end;

function c_total_pur_valueformula(total_pur_value in number) return number is
begin
  return round(total_pur_value*p_exchange_rate/round_unit)*round_unit;
end;

function CF_SORT_HEADER_DISPLAYEDFormul return Char is
begin
  return p_sort_header_displayed;
end;

function CF_cat_range_dispFormula return Char is
begin
  if ((P_CAT_FROM IS NOT NULL) OR (P_CAT_TO IS NOT NULL)) then
    return 'Y';
  else
    return 'N';
  end if;
end;

function CF_item_range_dispFormula return Char is
begin
  if ((P_ITEM_FROM IS NOT NULL) OR (P_ITEM_TO IS NOT NULL)) then
    return 'Y';
  else
    return 'N';
  end if;
end;

function cf_item_cost_dispformula(SORT_COLUMN in varchar2) return char is
begin
  if ((P_SORT_OPTION1 = 5 OR P_SORT_OPTION1 = 6) AND (SORT_COLUMN = 'Expense')) THEN
    return 'N';
  end if;
  return 'Y';
end;

function CF_MAIN_DISPFormula return Char is
begin
  if (P_RPT_OPTION = 1) then
    return 'Y';
  else
    return 'N';
  end if;
end;

function CF_REV_DISPFormula return Char is
begin
  if (P_ITEM_REVISION = 1) then
    return 'Y';
  else
    return 'N';
  end if;
end;

function CF_CAT_DISPFormula return Char is
begin
  if (P_SORT_OPTION1 = 2 OR P_SORT_OPTION1 = 6) then
    return 'Y';
  else
    return 'N';
  end if;
end;

function CF_cat_fromFormula return Char is
begin
  return p_cat_from;
end;

function CF_cat_toFormula return Char is
begin
  return p_cat_to;
end;

function CF_cost_typeFormula return Char is
begin
  return p_cost_type;
end;

function CF_currency_dspFormula return Char is
begin
  return p_currency_dsp;
end;

function CF_detail_levelFormula return Char is
begin
  return p_detail_level;
end;

function CF_item_fromFormula return Char is
begin
  return p_item_from;
end;

function CF_item_toFormula return Char is
begin
  return p_item_to;
end;

function CF_titleFormula return Char is
begin
  return p_title;
end;

function CF_cat_set_nameFormula return Char is
begin
  return p_cat_set_name;
end;

function CF_SORT_DISPFormula return Char is
begin
  if (P_SORT_OPTION1 > 2) then
    return 'Y';
  else
    return 'N';
  end if;
end;

--Functions to refer Oracle report placeholders--

END PO_POXRRCVV_XMLP_PKG ;


/
