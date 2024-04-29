--------------------------------------------------------
--  DDL for Package Body QP_MASS_MAINTAIN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MASS_MAINTAIN_UTIL" AS
/* $Header: QPXMMUTB.pls 120.4.12010000.6 2008/10/21 21:24:56 rbadadar ship $ */

-- This Function returns 'N' if pte_code and source_system_code of passed list_header_id matches
-- with the corresponding profile values else returns 'Y'
-- Its confusing but has been done intentionally

FUNCTION Check_SS_PTE_Codes_Match (p_list_header_id     IN NUMBER )
  return VARCHAR2
  IS
    l_source_system_code       VARCHAR2(30);
    l_pte_code                 VARCHAR2(30);
    l_saved_source_system_code VARCHAR2(30);
    l_saved_pte_code           VARCHAR2(30);

  BEGIN

    begin
      select source_system_code, pte_code
      into   l_saved_source_system_code, l_saved_pte_code
      from   qp_list_headers_b
      where  list_header_id = p_list_header_id;
    exception
      when no_data_found then
        return 'Y';
    end;

    FND_PROFILE.GET('QP_SOURCE_SYSTEM_CODE', l_source_system_code);
    FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY', l_pte_code);

    IF l_saved_source_system_code = l_source_system_code AND
       l_saved_pte_code = l_pte_code
    THEN
      return 'N';
    ELSE
      return 'Y';
    END IF;

  EXCEPTION
    when others then
      raise;

  END Check_SS_PTE_Codes_Match;


-- This function return the product description
FUNCTION get_product_desc(p_product_attr_context  varchar2,
                            p_product_attr  varchar2,
                            p_product_attr_val varchar2)
  RETURN VARCHAR2
  is
    l_product_desc   varchar2(240) := null;
    l_org_id         number;
    l_Inventory_Item_Id         number;
    l_category_id         number;
    l_segment_name        VARCHAR2(240);
    l_attribute_name        VARCHAR2(240);
  begin
   if p_product_attr_context = 'ITEM' THEN
      IF p_product_attr = 'PRICING_ATTRIBUTE1'  THEN
         l_Inventory_Item_Id := p_product_attr_val;
         l_org_id := QP_UTIL.Get_Item_Validation_Org;

         select Description
           into l_product_desc
           From Mtl_System_Items_Vl
          Where Inventory_Item_Id = l_Inventory_Item_Id
            And Organization_Id = l_Org_Id;

      ELSIF p_product_attr = 'PRICING_ATTRIBUTE2'  THEN
         l_category_id := p_product_attr_val;
         Select Description
           Into l_product_desc
           From Mtl_categories_vl
          Where category_id = l_category_id;
      ELSE
         QP_UTIL.Get_Attribute_Code('QP_ATTR_DEFNS_PRICING',
                              p_product_attr_context,
                              p_product_attr,
                              l_attribute_name,
                              l_segment_name);
         --dbms_output.put_line('l_segment_name = ' || l_segment_name);

         l_product_desc := QP_UTIL.Get_Attribute_Value_Meaning('QP_ATTR_DEFNS_PRICING',
                             p_product_attr_context,
                             l_segment_name,
                             p_product_attr_val,
                             '=');
         --dbms_output.put_line('l_product_desc = ' || l_product_desc);
      END IF;
   END IF; -- context is ITEM

   return(l_product_desc);
  exception
    when no_data_found then
      return(l_product_desc);

    when others then
      return(l_product_desc);
end get_product_desc;

Function Get_Product_UOM_Code ( p_list_line_id IN NUMBER,
                                p_product_attr_context  IN VARCHAR2,
                                p_product_attr  IN VARCHAR2 ) return VARCHAR2
IS
l_context varchar2(30);
l_pricing_attribute varchar2(240);
l_attribute  varchar2(30);
l_uom_code varchar2(3);
begin

        select product_uom_code
        into l_uom_code
        from qp_pricing_attributes
        where list_line_id = p_list_line_id
        and product_attribute_context = p_product_attr_context
        and product_attribute = p_product_attr
        and rownum = 1;

        return l_uom_code;


end Get_Product_UOM_Code;

-- This procedure gets the select statement associated with context_code
-- and segment_code and return it.
PROCEDURE get_valueset_select(p_context_code IN  VARCHAR2,
                              p_segment_code IN  VARCHAR2,
                              x_select_stmt  OUT NOCOPY VARCHAR2,
                              p_segment_map_col IN VARCHAR2 DEFAULT NULL, -- sfiresto fix
                              p_pte IN VARCHAR2 DEFAULT NULL,  -- Hierarchical Categories
                              p_ss  IN VARCHAR2 DEFAULT NULL)  -- Hierarchical Categories
  is
    v_value_set_id   NUMBER;
    v_valueset_r     fnd_vset.valueset_r;
    v_valueset_dr    fnd_vset.valueset_dr;
    v_table_r        fnd_vset.table_r;
    v_select_clause   varchar2(4000);
    v_cols           varchar2(3000);
    v_fnarea_where_clause VARCHAR2(500);
    l_appl_id    NUMBER;

  begin
    if p_context_code = 'ITEM' AND p_segment_code = 'INVENTORY_ITEM_ID' then
     /* v_select_clause := 'select INVENTORY_ITEM_ID attribute_id, SEGMENT1 attribute_name, nvl(DESCRIPTION, SEGMENT1) attribute_meaning from MTL_SYSTEM_ITEMS_B where ORGANIZATION_ID = QP_UTIL.Get_Item_Validation_Org';*/
-- fix for bug 6850999
       v_select_clause := 'select INVENTORY_ITEM_ID attribute_id,concatenated_segments attribute_name,nvl(DESCRIPTION, concatenated_segments) attribute_meaning from MTL_SYSTEM_ITEMS_B_KFV where ORGANIZATION_ID = QP_UTIL.Get_Item_Validation_Org';
       if p_pte = 'PO' then
        v_select_clause := v_select_clause||' '||'AND  PURCHASING_ITEM_FLAG = '||'''Y''';
       end if;
      x_select_stmt := 'Select * from (' || v_select_clause || ') AVVO';
      return;
/*
 * Commented out for Hierarchical Categories
 *
      elsif p_segment_code = 'ITEM_CATEGORY' then
        l_appl_id := FND_GLOBAL.RESP_APPL_ID;
        v_select_clause := 'select cat.CATEGORY_ID attribute_id, cat.CONCATENATED_SEGMENTS attribute_name, nvl(cat_vl.DESCRIPTION, cat.CONCATENATED_SEGMENTS) attribute_meaning ';
        v_select_clause := v_select_clause || 'from mtl_categories_b_kfv cat, mtl_categories_vl cat_vl ';
        v_select_clause := v_select_clause || 'where cat.category_id = cat_vl.category_id and cat.STRUCTURE_ID in ';
        v_select_clause := v_select_clause || '(select structure_id from mtl_category_sets where category_set_id = ( select category_set_id from mtl_default_category_sets where functional_area_id = decode(' || l_appl_id || ',201,2,7)) and rownum < 2) ';
        v_select_clause := v_select_clause || 'order by attribute_name';
        x_select_stmt := 'Select * from (' || v_select_clause || ') AVVO';
        return;
 *
 */
    end if;

--    select nvl(SEEDED_VALUESET_ID, USER_VALUESET_ID)
    select nvl(USER_VALUESET_ID, SEEDED_VALUESET_ID)
      into v_value_set_id
      from qp_segments_b seg, qp_prc_contexts_b cont, fnd_flex_value_sets vs
     where cont.PRC_CONTEXT_CODE = p_context_code
       and seg.SEGMENT_CODE =  p_segment_code
       and nvl(user_valueset_id, seeded_valueset_id) = vs.flex_value_set_id
       and cont.PRC_CONTEXT_ID = seg.PRC_CONTEXT_ID
       and seg.SEGMENT_MAPPING_COLUMN = nvl(p_segment_map_col, seg.SEGMENT_MAPPING_COLUMN) -- sfiresto fix
       and vs.validation_type <> 'N'; -- sfiresto for bug 5136873, all value set types but 'NONE'

    fnd_vset.get_valueset(v_value_set_id,v_valueset_r,v_valueset_dr);

    v_table_r := v_valueset_r.table_info;

    v_cols := nvl(v_table_r.ID_COLUMN_NAME, nvl(v_table_r.VALUE_COLUMN_NAME, 'null')) || ' attribute_id, '; -- sfiresto fix
    v_cols := v_cols || nvl(v_table_r.VALUE_COLUMN_NAME, 'null') || ' attribute_name, ';
    v_cols := v_cols || 'nvl(' || nvl(v_table_r.MEANING_COLUMN_NAME, 'null') || ', ' || nvl(v_table_r.VALUE_COLUMN_NAME, 'null') || ') attribute_meaning '; -- sfiresto fix

    if v_table_r.TABLE_NAME is not null then

       v_select_clause := 'select ';

       -- Hierarchical Categories distinct clause addition (sfiresto)
       if p_context_code = 'ITEM' AND p_segment_code = 'ITEM_CATEGORY' then
         v_select_clause := v_select_clause || 'distinct ';
       end if;

       v_select_clause := v_select_clause || v_cols || ' from ' || v_table_r.TABLE_NAME;

    else
       v_select_clause := 'select flex_value attribute_id, flex_value_meaning attribute_name, nvl(description, flex_value_meaning) attribute_meaning FROM fnd_flex_values_vl WHERE flex_value_set_id = '|| v_value_set_id;
    end if;

    if v_table_r.WHERE_CLAUSE is not null then
       -- Hierarchical Categories where clause addition (sfiresto)
       if p_context_code = 'ITEM' AND p_segment_code = 'ITEM_CATEGORY' then
         v_select_clause := v_select_clause || ' ' || QP_UTIL.merge_fnarea_where_clause(v_table_r.WHERE_CLAUSE, p_pte, p_ss);
       else
         v_select_clause := v_select_clause || ' ' || v_table_r.WHERE_CLAUSE;
       end if;
    end if;

    x_select_stmt := 'Select * from (' || v_select_clause || ') AVVO';

  exception
    when no_data_found then
--    Commented out these two lines to allow for differentiation between an LOV that has no value set and an
--     invalid value set/no row value set
--
--      v_select_clause := 'select flex_value attribute_id, flex_value_meaning attribute_name, nvl(description, flex_value_meaning) attribute_meaning FROM fnd_flex_values_vl WHERE flex_value_set_id = 0';
--      x_select_stmt := 'Select * from (' || v_select_clause || ') AVVO';
      x_select_stmt := null;
    when others then
      x_select_stmt := null;
      raise;

  end get_valueset_select;

END QP_MASS_MAINTAIN_UTIL;

/
