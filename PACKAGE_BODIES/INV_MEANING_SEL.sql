--------------------------------------------------------
--  DDL for Package Body INV_MEANING_SEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MEANING_SEL" as
/* $Header: INVRPTMB.pls 120.1.12010000.3 2010/03/01 07:05:36 qyou ship $ */

FUNCTION C_MFG_LOOKUP(lookup_code_val in number,lookup_type_val in varchar2) RETURN varchar2 IS
        temp    varchar2(80);
begin
if (lookup_code_val is NOT NULL) then
        select  meaning
        into temp
        from mfg_lookups
        where lookup_code = lookup_code_val
        and lookup_type = lookup_type_val;
        return (temp);
else
        return (NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return(SQLCODE);
end C_MFG_LOOKUP;

FUNCTION C_UNIT_MEASURE(uom_code_val in varchar2) RETURN varchar2 IS
ret_string    varchar2(80);
begin
if (uom_code_val is NOT NULL) then
        select  unit_of_measure
        into ret_string
        from mtl_units_of_measure
        where uom_code = uom_code_val;
        return (ret_string);
else
        return (NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return(SQLCODE);
end C_UNIT_MEASURE;

FUNCTION C_PO_UN_NUMB(un_number_val in number) RETURN varchar2 IS
ret_string    varchar2(25);
begin
if (un_number_val is NOT NULL) then
        select  un_number
        into ret_string
        from po_un_numbers_tl
        where un_number_id = un_number_val
        and   language = userenv('LANG');
        return (ret_string);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return(SQLCODE);
end C_PO_UN_NUMB;

FUNCTION C_PO_HAZARD_CLASS(hazard_val in number) RETURN varchar2 IS
ret_string    varchar2(40);
begin
if (hazard_val is NOT NULL) then
        select  HAZARD_CLASS
        into ret_string
        from po_hazard_classes_tl
        where hazard_class_id = hazard_val
        and   language = userenv('LANG');
        return (ret_string);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return(SQLCODE);
end C_PO_HAZARD_CLASS;


FUNCTION C_PER_PEOPLE(person_id_val in number) RETURN varchar2 IS
ret_string    varchar2(240);
begin
if (person_id_val is NOT NULL) then
        select  full_name
        into ret_string
        from per_people_f
        where person_id = person_id_val
        and trunc(sysdate) >= effective_start_date(+)
        and trunc(sysdate) <= effective_end_date(+);
        return (ret_string);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return(SQLCODE);
end C_PER_PEOPLE;

FUNCTION C_LOOKUPS(Lookup_code_val in varchar2,lookup_type_val in varchar2) RETURN varchar2 IS
temp    varchar2(80);
begin
if (lookup_code_val is NOT NULL) then
        select  meaning
        into temp
        from fnd_lookups
        where lookup_code = lookup_code_val
        and lookup_type = lookup_type_val;
        return (temp);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return(SQLCODE);
end C_LOOKUPS;

FUNCTION C_PICK_RULES(pick_id_val in number) RETURN varchar2 IS
ret_string    varchar2(30);
begin
if (pick_id_val is NOT NULL) then
        select  picking_rule_name
        into ret_string
        from mtl_picking_rules
        where picking_rule_id = pick_id_val;
        return (ret_string);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return(SQLCODE);
end C_PICK_RULES;


FUNCTION C_ATP_RULES(atp_id_val in number) RETURN varchar2 IS
ret_string    varchar2(30);
begin
if (atp_id_val is NOT NULL) then
        select  rule_name
        into ret_string
        from mtl_atp_rules
        where rule_id = atp_id_val;
        return (ret_string);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return(SQLCODE);
end C_ATP_RULES;


FUNCTION C_ORG_NAME(org_id_val in number) RETURN VARCHAR2 is
ret_string    varchar2(240);
begin
if (org_id_val is NOT NULL) then
        --Perf Issue : Replaced org_organizations_definitions view.
        select name into ret_string
        from   hr_organization_units
        where  organization_id = org_id_val;
        return (ret_string);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return(SQLCODE);
end C_ORG_NAME;


FUNCTION C_RA_RULES(rule_id_val in NUMBER) RETURN varchar2 IS
ret_string    varchar2(30);
begin
if (rule_id_val is NOT NULL) then
        select  name
        into ret_string
        from ra_rules
        where rule_id = rule_id_val;
        return (ret_string);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return(SQLCODE);
end C_RA_RULES;

FUNCTION C_RA_TERMS(term_id_val in NUMBER) RETURN varchar2 IS
ret_string    varchar2(15);
begin
if (term_id_val is NOT NULL) then
        select  name
        into ret_string
        from ra_terms
        where term_id = term_id_val;
        return (ret_string);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return(SQLCODE);
end C_RA_TERMS;

FUNCTION C_FND_LOOKUP_VL(lookup_code_val in varchar2,lookup_type_val in varchar2) RETURN varchar2 IS
        temp    varchar2(80);
begin
if (lookup_code_val is not null) then
        select  meaning
        into temp
        from fnd_lookup_values_vl
        where lookup_code = lookup_code_val
        and lookup_type = lookup_type_val;
        return (temp);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return('Error');
end C_FND_LOOKUP_VL;


FUNCTION C_PO_LOOKUP(lookup_code_val in varchar2,lookup_type_val in varchar2) RETURN varchar2 IS
        temp    varchar2(80);
begin
if (lookup_code_val is NOT NULL) then
        select  displayed_field
        into temp
        from po_lookup_codes
        where lookup_code = lookup_code_val
        and lookup_type = lookup_type_val;
        return (temp);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return('Error');
end C_PO_LOOKUP;

FUNCTION C_FND_LOOKUP(lookup_code_val in varchar2,lookup_type_val in varchar2) RETURN varchar2 IS
        temp    varchar2(80);
begin
if (lookup_code_val is NOT NULL) then
        select  meaning
        into temp
        from fnd_lookup_values
        where lookup_code = lookup_code_val
        and lookup_type = lookup_type_val
        and view_application_id = 3
        and language = userenv('LANG');
        return (temp);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return('Error');
end C_FND_LOOKUP;

FUNCTION C_LOT_LOOKUP(status_id_val in Number) RETURN varchar2 IS
         temp    varchar2(80);
begin
if (status_id_val is NOT NULL) then
        select STATUS_CODE
        into temp
        from mtl_material_statuses_vl
        where LOT_CONTROL =1
        and ENABLED_FLAG = 1
        and Status_Id = status_id_val;
        return(temp);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return('Error');
end C_LOT_LOOKUP;

FUNCTION C_SERIAL_LOOKUP(status_id_val in Number) RETURN varchar2 IS
         temp    varchar2(80);
begin
if (status_id_val is NOT NULL) then
        select STATUS_CODE
        into temp
        from mtl_material_statuses_vl
        where SERIAL_CONTROL =1
        and ENABLED_FLAG = 1
        and Status_Id = status_id_val;
        return(temp);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return('Error');
end C_SERIAL_LOOKUP;

FUNCTION C_UNITMEASURE(uom_code_val in Varchar2) RETURN varchar2 IS
         temp    varchar2(80);
begin
if (uom_code_val is NOT NULL) then
        select unit_of_measure
        into temp
        from mtl_units_of_measure_vl
        where uom_code = uom_code_val
        and language = userenv('LANG');
        return(temp);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return('Error');
end C_UNITMEASURE;

FUNCTION C_FNDCOMMON(lookup_code_val in Varchar2 , lookup_type_val in Varchar2) RETURN varchar2 IS
         temp    varchar2(80);
begin
if (lookup_code_val is NOT NULL) then
        select meaning
        into temp
        from fnd_common_lookups
        where lookup_code = lookup_code_val
        and  lookup_type = lookup_type_val;
        return(temp);
else
        return(NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return('Error');
end C_FNDCOMMON;


FUNCTION C_QTY_ON_HAND(Item_Id in Number,Org_Id in Number , Sub_Code in Varchar2, Break_Id in Number) RETURN Number IS
 temp   Number ;
Begin
        if (Break_Id = 1) then
                Select sum(primary_transaction_quantity)
                into   temp
                from   mtl_onhand_quantities_detail
                where  inventory_item_id = Item_Id
                and    organization_id  = Org_Id
                and    subinventory_code = Sub_Code;
        else
                Select sum(primary_transaction_quantity)
                into   temp
                from   mtl_onhand_quantities_detail
                where  inventory_item_id = Item_Id
                and    organization_id  = Org_Id;
        end if;
        return (temp);
exception
        when NO_DATA_FOUND then
                return(0);
end C_QTY_ON_HAND;

FUNCTION C_ITEM_DESCRIPTION(Item_Id in Number, Org_Id in Number) RETURN varchar2 IS
         temp    varchar2(240);
begin
        select description
        into temp
        from mtl_system_items_tl
        where INVENTORY_ITEM_ID = Item_Id
        and ORGANIZATION_ID = Org_Id
        and LANGUAGE = userenv('LANG');
        return(temp);
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return('Error');
end C_ITEM_DESCRIPTION;

FUNCTION C_ITEM_REV_DESCRIPTION(Item_Id in Number, Org_Id in Number , Rev_id in NUMBER) RETURN varchar2 IS
         temp    varchar2(240);
begin
        select description
        into temp
        from mtl_item_revisions_tl
        where INVENTORY_ITEM_ID = Item_Id
        and ORGANIZATION_ID = Org_Id
        and REVISION_ID = Rev_Id
        and LANGUAGE = userenv('LANG');
        return(temp);
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return('Error');
end C_ITEM_REV_DESCRIPTION;

--2961986: OE lookup function for default so source type
FUNCTION C_OE_LOOKUP(lookup_code_val in varchar2,lookup_type_val in varchar2) RETURN varchar2 IS
        temp    varchar2(80);
begin
if (lookup_code_val is NOT NULL) then
        select  meaning
        into temp
        from oe_lookups
        where lookup_code = lookup_code_val
        and   lookup_type = lookup_type_val;
        return (temp);
else
        return (NULL);
end if;
exception
        when NO_DATA_FOUND then
                return(NULL);
        when Others then
                return(SQLCODE);
end C_OE_LOOKUP;

FUNCTION C_COVERAGE_SCHEDULE(COVERAGE_SCHEDULE_ID NUMBER) RETURN VARCHAR2 IS
   l_temp VARCHAR2(240) := NULL;
BEGIN
   IF COVERAGE_SCHEDULE_ID IS NOT NULL THEN
     SELECT name INTO l_temp
     FROM   OKS_COVERAGE_TEMPLTS_V
     WHERE  ID = COVERAGE_SCHEDULE_ID;
   END IF;
   RETURN (l_temp);
EXCEPTION
   WHEN OTHERS THEN
      return(NULL);
END C_COVERAGE_SCHEDULE;
--Bug: 1968090
FUNCTION C_ITEM_STATUS (status_code_val in varchar2) RETURN varchar2 IS
        ret_string    varchar2(80);
BEGIN
        IF (status_code_val IS NOT NULL) THEN
                select  inventory_item_status_code_tl
                into ret_string
                from mtl_item_status
                where inventory_item_status_code = status_code_val;
                return (ret_string);
        ELSE
                RETURN (NULL);
        END IF;
EXCEPTION
        when NO_DATA_FOUND then
             return(NULL);
        when Others then
               return(SQLCODE);
END C_ITEM_STATUS;

-- Bug 8762354
FUNCTION C_DEFAULT_MATERIAL_STATUS (status_code_val in varchar2) RETURN varchar2
IS
        ret_string    varchar2(80);
BEGIN
        IF (STATUS_CODE_VAL IS NOT NULL) THEN
                select  status_code
                into ret_string
                from MTL_MATERIAL_STATUSES_TL
                where status_id = status_code_val AND language =
userenv('LANG');
                return (ret_string);
        ELSE
                RETURN (NULL);
        END IF;
EXCEPTION
        when NO_DATA_FOUND then
             return(NULL);
        when OTHERS then
               return(SQLCODE);
END C_DEFAULT_MATERIAL_STATUS;

end INV_MEANING_SEL;

/
