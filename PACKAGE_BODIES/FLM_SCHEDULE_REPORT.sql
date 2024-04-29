--------------------------------------------------------
--  DDL for Package Body FLM_SCHEDULE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_SCHEDULE_REPORT" AS
/* $Header: FLMFSCHB.pls 115.6 2002/12/12 13:32:15 sjagan ship $ */

  -- Function that returns the revision of the item
  FUNCTION get_revision(p_org_id NUMBER, p_item_id NUMBER, p_date DATE) return VARCHAR2
  IS
    l_rev VARCHAR2(3);
  BEGIN
    BOM_REVISIONS.Get_Revision(
                type            => 'PART',
                eco_status      => 'ALL',
                examine_type    => 'ALL',
                org_id          => p_org_id,
                item_id         => p_item_id,
                rev_date        => p_date,
                itm_rev         => l_rev);
    return l_rev;
  END get_revision;

  -- Function that determines if the item need to be displayed.
  -- It returns 1 if the item need to be displayed, 2 otherwise
  -- This will be called for all item in the bill except for level 1.
  -- For level 1 component, the report display only the non-phantom
  -- item.
  -- The function returns 1 for the item that has the parents with
  -- the phantom component.
  FUNCTION display_item(p_level NUMBER,
                        p_sort_order VARCHAR2,
                        p_top_bill_seq_id NUMBER,
                        p_org_id NUMBER)
  RETURN number IS
    l_parent_id		NUMBER;
    l_comp_id		NUMBER;
    l_top_id		NUMBER;
    /* Changed the size of l_Comp_type and l_parent_type from 10 to 30 for bug number 2152161 */
    l_comp_type		VARCHAR2(30);
    l_parent_type	VARCHAR2(30);
  BEGIN
    select component_item_id, assembly_item_id, top_item_id
    into l_comp_id, l_parent_id, l_top_id
    from bom_explosions
    where top_bill_sequence_id = p_top_bill_seq_id
      and sort_order = p_sort_order
      and explosion_type = 'ALL';

    select item_type
    into l_comp_type
    from mtl_system_items
    where inventory_item_id = l_comp_id
      and organization_id = p_org_id;

    select item_type
    into l_parent_type
    from mtl_system_items
    where inventory_item_id = l_parent_id
      and organization_id = p_org_id;

    /* Criteria :
       - Don't show the phantom component itself.
       - Don't show the item that has parent that doesn't have phantom type, except for
         component of top_assembly item
       - Show the item that is part of the phantom item
         (This phantom item is component of top_assembly item).
       - Recursively call the display_item for its parent. */
    if (p_level = 1 AND l_comp_type = 'PH') then
      return 2;
    elsif (l_top_id <> l_parent_id AND l_parent_type <> 'PH') then
      return 2;
    elsif (l_top_id = l_parent_id AND l_comp_type = 'PH') then
      return 1;
    else
      return(display_item(p_level+1, substr(p_sort_order, 0, length(p_sort_order)-4), p_top_bill_seq_id, p_org_id));
    end if;

  END display_item;
END flm_schedule_report;

/
