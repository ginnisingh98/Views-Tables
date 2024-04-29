--------------------------------------------------------
--  DDL for Package Body BIV_DBI_TMPL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_DBI_TMPL_UTIL" as
/* $Header: bivsrvrutlb.pls 120.1 2006/06/27 10:06:50 asparama noship $ */

  g_REQUEST_TYPE_BMAP number := 1;
  g_CATEGORY_BMAP     number := 2;
  g_PRODUCT_BMAP      number := 4;
  g_SEVERITY_BMAP     number := 8;
  g_STATUS_BMAP       number := 16;
  g_CHANNEL_BMAP      number := 32;
  g_RESOLUTION_BMAP   number := 64;
  g_CUSTOMER_BMAP     number := 128;
  g_ASSIGNMENT_BMAP   number := 256;
  g_AGING_BMAP        number := 512;
  g_BACKLOG_TYPE_BMAP number := 1024;
  g_RES_STATUS_BMAP   number := 2048;

-- get_col_name function returns the name of the column
-- from the FACT table that is needed to join to
-- the DIMENSION table based on the VIEW BY selected (p_dim_name)
function get_fact_col_name
( p_dim_name    in varchar2
, p_product_cat in varchar2 default null )
return varchar2 is
begin
  return (case p_dim_name
            when g_REQUEST_TYPE then 'incident_type_id'
            when g_CATEGORY then
              case
                when p_product_cat is null then 'vbh_parent_category_id'
                else 'vbh_child_category_id'
              end
            when g_PRODUCT then 'product_id'
            when g_SEVERITY then 'incident_severity_id'
            when g_STATUS then 'incident_status_id'
            when g_CHANNEL then 'sr_creation_channel'
            when g_RESOLUTION then 'resolution_code'
            when g_CUSTOMER then 'customer_id'
            when g_ASSIGNMENT then 'owner_group_id'
            when g_AGING then 'aging_id'
            when g_RES_STATUS then 'resolved_flag'
            else ''
          end);
end get_fact_col_name;

-- get_table function returns the name of the DIMENSION table or
-- view (or inline view) that needs to be joined to based on the
-- VIEW BY select (p_dim_name)
function get_dim_table_name
( p_dim_name in varchar2 )
return varchar2 is
begin
  return (case p_dim_name
            when g_REQUEST_TYPE then '(select incident_type_id id, name value from cs_incident_types_tl where userenv(''LANG'') = language)'
            when g_CATEGORY then 'eni_item_vbh_nodes_v'
            when g_PRODUCT then 'eni_item_v'
            when g_SEVERITY then 'biv_severities_v'
            when g_STATUS then 'biv_statuses_v'
            when g_CHANNEL then 'biv_channels_v'
            when g_RESOLUTION then 'biv_resolutions_v'
            when g_CUSTOMER then 'aso_bi_prospect_v'
            when g_ASSIGNMENT then '(select group_id id, group_name value from jtf_rs_groups_tl where userenv(''LANG'') = language)'
            when g_AGING then '(select id, value from biv_bucket_aging_v where short_name=''BIV_DBI_BACKLOG_AGING'')'
            when g_RES_STATUS then 'biv_dbi_res_status_v'
            else ''
          end);

end get_dim_table_name;

-- get_vb_aging_columns function returns the decoded columns
-- needed when backlog report is view by Aging
function get_vb_aging_columns
return varchar2
is
begin
  return '
, a.id aging_id
, decode(a.id,1,f.backlog_age_b1
             ,2,f.backlog_age_b2
             ,3,f.backlog_age_b3
             ,4,f.backlog_age_b4
             ,5,f.backlog_age_b5
             ,6,f.backlog_age_b6
             ,7,f.backlog_age_b7
             ,8,f.backlog_age_b8
             ,9,f.backlog_age_b9
             ,10,f.backlog_age_b10
             ,null) backlog_count
, decode(a.id,1,f.total_backlog_age_b1
             ,2,f.total_backlog_age_b2
             ,3,f.total_backlog_age_b3
             ,4,f.total_backlog_age_b4
             ,5,f.total_backlog_age_b5
             ,6,f.total_backlog_age_b6
             ,7,f.total_backlog_age_b7
             ,8,f.total_backlog_age_b8
             ,9,f.total_backlog_age_b9
             ,10,f.total_backlog_age_b10
             ,null) total_backlog_age
, decode(a.id,1,f.escalated_age_b1
             ,2,f.escalated_age_b2
             ,3,f.escalated_age_b3
             ,4,f.escalated_age_b4
             ,5,f.escalated_age_b5
             ,6,f.escalated_age_b6
             ,7,f.escalated_age_b7
             ,8,f.escalated_age_b8
             ,9,f.escalated_age_b9
             ,10,f.escalated_age_b10
             ,null) escalated_count
, decode(a.id,1,f.unowned_age_b1
             ,2,f.unowned_age_b2
             ,3,f.unowned_age_b3
             ,4,f.unowned_age_b4
             ,5,f.unowned_age_b5
             ,6,f.unowned_age_b6
             ,7,f.unowned_age_b7
             ,8,f.unowned_age_b8
             ,9,f.unowned_age_b9
             ,10,f.unowned_age_b10
             ,null) unowned_count';
end get_vb_aging_columns;

-- get_fact_mv_name function returns the name of the FACT table
-- based on report type (p_report_type) and parameter bitmap (p_bmap)
function get_fact_mv_name
( p_report_type in varchar2
, p_bmap        in number
, p_xtd         in varchar2
)
return varchar2 is
begin
  if p_report_type = 'ACTIVITY' then
    if bitand(p_bmap,g_PRODUCT_BMAP) = g_PRODUCT_BMAP or
       bitand(p_bmap,g_CUSTOMER_BMAP) = g_CUSTOMER_BMAP or
       bitand(p_bmap,g_ASSIGNMENT_BMAP) = g_ASSIGNMENT_BMAP or
       bitand(p_bmap,g_CHANNEL_BMAP) = g_CHANNEL_BMAP then
      if bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
        return '(
select
  v.top_node_flag vbh_top_node_flag, v.parent_id vbh_parent_category_id, v.imm_child_id vbh_child_category_id
, f.time_id, f.period_type_id, f.incident_type_id, f.product_id, f.incident_severity_id
, f.customer_id, f.owner_group_id, f.sr_creation_channel
, f.first_opened_count
, f.reopened_count
, f.closed_count
from
  biv_act_sum_mv f
, eni_denorm_hierarchies v
, mtl_default_category_sets m
where
    m.functional_area_id = 11
and v.object_id = m.category_set_id
and v.dbi_flag = ''Y''
and v.object_type = ''CATEGORY_SET''
and f.vbh_category_id = v.child_id
and f.grp_id = ' || get_grp_id(p_bmap) || '
)';
      else
        return '(select * from biv_act_sum_mv where grp_id = ' ||
                    get_grp_id(p_bmap) || ')';
      end if;
    else
      return 'biv_act_h_sum_mv';
    end if;

  elsif p_report_type = 'CLOSED' then
    if bitand(p_bmap,g_PRODUCT_BMAP) = g_PRODUCT_BMAP or
       bitand(p_bmap,g_CUSTOMER_BMAP) = g_CUSTOMER_BMAP or
       bitand(p_bmap,g_ASSIGNMENT_BMAP) = g_ASSIGNMENT_BMAP or
       bitand(p_bmap,g_CHANNEL_BMAP) = g_CHANNEL_BMAP or
       bitand(p_bmap,g_RESOLUTION_BMAP) = g_RESOLUTION_BMAP then
      if bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
        return '(
select
  v.top_node_flag vbh_top_node_flag, v.parent_id vbh_parent_category_id, v.imm_child_id vbh_child_category_id
, f.time_id, f.period_type_id, f.incident_type_id, f.product_id, f.incident_severity_id
, f.customer_id, f.owner_group_id, f.sr_creation_channel, f.resolution_code
, f.closed_count
, f.total_time_to_close
, f.time_to_close_b1
, f.time_to_close_b2
, f.time_to_close_b3
, f.time_to_close_b4
, f.time_to_close_b5
, f.time_to_close_b6
, f.time_to_close_b7
, f.time_to_close_b8
, f.time_to_close_b9
, f.time_to_close_b10
from
  biv_clo_sum_mv f
, eni_denorm_hierarchies v
, mtl_default_category_sets m
where
    m.functional_area_id = 11
and v.object_id = m.category_set_id
and v.dbi_flag = ''Y''
and v.object_type = ''CATEGORY_SET''
and f.vbh_category_id = v.child_id
and f.grp_id = ' || get_grp_id(p_bmap) || '
)';
      else
        return '(select * from biv_clo_sum_mv where grp_id = ' ||
                    get_grp_id(p_bmap) || ')';
      end if;
    else
      return 'biv_clo_h_sum_mv';
    end if;

  elsif p_report_type = 'RESOLVED' then
    if bitand(p_bmap,g_PRODUCT_BMAP) = g_PRODUCT_BMAP or
       bitand(p_bmap,g_CUSTOMER_BMAP) = g_CUSTOMER_BMAP or
       bitand(p_bmap,g_ASSIGNMENT_BMAP) = g_ASSIGNMENT_BMAP or
       bitand(p_bmap,g_CHANNEL_BMAP) = g_CHANNEL_BMAP or
       bitand(p_bmap,g_RESOLUTION_BMAP) = g_RESOLUTION_BMAP then
      if bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
        return '(
select
  v.top_node_flag vbh_top_node_flag, v.parent_id vbh_parent_category_id, v.imm_child_id vbh_child_category_id
, f.time_id, f.period_type_id, f.incident_type_id, f.product_id, f.incident_severity_id
, f.customer_id, f.owner_group_id, f.sr_creation_channel, f.resolution_code
, f.resolution_count
, f.total_time_to_resolution
, f.time_to_resolution_b1
, f.time_to_resolution_b2
, f.time_to_resolution_b3
, f.time_to_resolution_b4
, f.time_to_resolution_b5
, f.time_to_resolution_b6
, f.time_to_resolution_b7
, f.time_to_resolution_b8
, f.time_to_resolution_b9
, f.time_to_resolution_b10
from
  biv_res_sum_mv f
, eni_denorm_hierarchies v
, mtl_default_category_sets m
where
    m.functional_area_id = 11
and v.object_id = m.category_set_id
and v.dbi_flag = ''Y''
and v.object_type = ''CATEGORY_SET''
and f.vbh_category_id = v.child_id
and f.grp_id = ' || get_grp_id(p_bmap) || '
)';
      else
        return '(select * from biv_res_sum_mv where grp_id = ' ||
                    get_grp_id(p_bmap) || ')';
      end if;
    else
      return 'biv_res_h_sum_mv';
    end if;

  elsif p_report_type = 'BACKLOG' then
-- XTD Model
IF( p_xtd IN ('DAY','WTD','MTD','QTD','YTD') ) THEN
    if bitand(p_bmap,g_PRODUCT_BMAP) = g_PRODUCT_BMAP or
       bitand(p_bmap,g_CUSTOMER_BMAP) = g_CUSTOMER_BMAP or
       bitand(p_bmap,g_ASSIGNMENT_BMAP) = g_ASSIGNMENT_BMAP or
       bitand(p_bmap,g_STATUS_BMAP) = g_STATUS_BMAP then
      if bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
        return '(
select
  v.top_node_flag vbh_top_node_flag, v.parent_id vbh_parent_category_id, v.imm_child_id vbh_child_category_id , f.*
from
  biv_bac_sum_mv f
, eni_denorm_hierarchies v
, mtl_default_category_sets m
where
    m.functional_area_id = 11
and v.object_id = m.category_set_id
and v.dbi_flag = ''Y''
and v.object_type = ''CATEGORY_SET''
and f.vbh_category_id = v.child_id
and f.grp_id = ' || get_grp_id( p_bmap ) || '
)';
      else
        return '( select * from biv_bac_sum_mv f where grp_id = ' || get_grp_id( p_bmap ) || ')';
      end if;
    else
      return 'biv_bac_h_sum_mv';
    end if;
ELSE
-- Rolling Model
    if bitand(p_bmap,g_PRODUCT_BMAP) = g_PRODUCT_BMAP or
       bitand(p_bmap,g_CUSTOMER_BMAP) = g_CUSTOMER_BMAP or
       bitand(p_bmap,g_ASSIGNMENT_BMAP) = g_ASSIGNMENT_BMAP or
       bitand(p_bmap,g_STATUS_BMAP) = g_STATUS_BMAP then
      if bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
        return '(
select
  v.top_node_flag vbh_top_node_flag, v.parent_id vbh_parent_category_id, v.imm_child_id vbh_child_category_id
, f.incident_type_id, f.product_id, f.incident_severity_id
, f.customer_id, f.owner_group_id, f.incident_status_id, f.resolved_flag
, f.backlog_count
, f.escalated_count
, f.unowned_count
, c.report_date
from
  biv_bac_sum_mv f
, eni_denorm_hierarchies v
, mtl_default_category_sets m
, fii_time_structures c
where
    m.functional_area_id = 11
and v.object_id = m.category_set_id
and v.dbi_flag = ''Y''
and v.object_type = ''CATEGORY_SET''
and f.vbh_category_id = v.child_id
and f.grp_id = ' || get_grp_id( p_bmap ) || '
and f.time_id = c.time_id
and f.period_type_id = c.period_type_id
and bitand(c.record_type_id,512) = 512
)';
      else
        return '(
select
  f.incident_type_id, f.product_id, f.incident_severity_id
, f.customer_id, f.owner_group_id, f.incident_status_id
, f.resolved_flag
, f.backlog_count
, f.escalated_count
, f.unowned_count
, c.report_date
from
  biv_bac_sum_mv f
, fii_time_structures c
where grp_id = ' || get_grp_id( p_bmap ) || '
and f.time_id = c.time_id
and f.period_type_id = c.period_type_id
and bitand(c.record_type_id,512) = 512
)';
      end if;
    else
      return '(
select
  f.vbh_top_node_flag, f.vbh_parent_category_id, f.vbh_child_category_id
, f.incident_type_id, f.incident_severity_id
, f.resolved_flag
, f.backlog_count
, f.escalated_count
, f.unowned_count
, c.report_date
from
  biv_bac_h_sum_mv f
, fii_time_structures c
where
    f.time_id = c.time_id
and f.period_type_id = c.period_type_id
and bitand(c.record_type_id,512) = 512
)';
    end if;
END IF; -- End of XTD Vs Rolloing

  elsif p_report_type = 'BACKLOG_AGE' then
    if bitand(p_bmap,g_PRODUCT_BMAP) = g_PRODUCT_BMAP or
       bitand(p_bmap,g_CUSTOMER_BMAP) = g_CUSTOMER_BMAP or
       bitand(p_bmap,g_ASSIGNMENT_BMAP) = g_ASSIGNMENT_BMAP or
       bitand(p_bmap,g_STATUS_BMAP) = g_STATUS_BMAP then
      if bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
        return '(
select
  v.top_node_flag vbh_top_node_flag, v.parent_id vbh_parent_category_id, v.imm_child_id vbh_child_category_id
, f.report_date, f.incident_type_id, f.product_id, f.incident_severity_id
, f.customer_id, f.owner_group_id, f.incident_status_id, f.resolved_flag
, f.backlog_count
, f.total_backlog_age
, f.backlog_age_b1
, f.backlog_age_b2
, f.backlog_age_b3
, f.backlog_age_b4
, f.backlog_age_b5
, f.backlog_age_b6
, f.backlog_age_b7
, f.backlog_age_b8
, f.backlog_age_b9
, f.backlog_age_b10
, f.escalated_count
, f.total_escalated_age
, f.escalated_age_b1
, f.escalated_age_b2
, f.escalated_age_b3
, f.escalated_age_b4
, f.escalated_age_b5
, f.escalated_age_b6
, f.escalated_age_b7
, f.escalated_age_b8
, f.escalated_age_b9
, f.escalated_age_b10
, f.unowned_count
, f.total_unowned_age
, f.unowned_age_b1
, f.unowned_age_b2
, f.unowned_age_b3
, f.unowned_age_b4
, f.unowned_age_b5
, f.unowned_age_b6
, f.unowned_age_b7
, f.unowned_age_b8
, f.unowned_age_b9
, f.unowned_age_b10
from
  biv_bac_age_sum_f f
, eni_denorm_hierarchies v
, mtl_default_category_sets m
where
    m.functional_area_id = 11
and v.object_id = m.category_set_id
and v.dbi_flag = ''Y''
and v.object_type = ''CATEGORY_SET''
and f.vbh_category_id = v.child_id
and f.grp_id = ' || get_grp_id( p_bmap ) || '
)';
      else
        return '(select * from biv_bac_age_sum_f where grp_id = ' ||
                    get_grp_id( p_bmap ) || ')';
      end if;
    else
      return 'biv_b_age_h_sum_mv';
    end if;
  elsif p_report_type = 'BACKLOG_DETAIL' then
    return '(
select
  f.backlog_date_from
, f.backlog_date_to
, f.incident_id
, f.incident_type_id
, nvl(s.master_id,s.id) product_id
, f.incident_severity_id
, f.customer_id
, f.owner_group_id
, f.incident_status_id
, f.incident_date
, f.resolved_flag
, f.escalated_date
, f.unowned_date
, (&AGE_CURRENT_ASOF_DATE + &AGE_CURRENT_ASOF_DATE_TIME) - f.incident_date age' ||
  case when bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
         '
, v.top_node_flag vbh_top_node_flag
, v.parent_id vbh_parent_category_id
, v.imm_child_id vbh_child_category_id'
       else null
  end || '
from
  biv_dbi_backlog_sum_f f
, eni_oltp_item_star s' ||
  case when bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
         '
, eni_denorm_hierarchies v
, mtl_default_category_sets m'
       else null
  end || '
where
    f.inventory_item_id = s.inventory_item_id
and f.inv_organization_id = s.organization_id' ||
  case when bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
         '
and m.functional_area_id = 11
and v.object_id = m.category_set_id
and v.dbi_flag = ''Y''
and v.object_type = ''CATEGORY_SET''
and s.vbh_category_id = v.child_id'
       else null
  end || '
and (&AGE_CURRENT_ASOF_DATE + &AGE_CURRENT_ASOF_DATE_TIME) - f.incident_date >= 0
)';

  elsif p_report_type = 'CLOSED_DETAIL' then
    return '(
select
  f.report_date closed_date
, f.incident_id
, f.incident_type_id
, nvl(s.master_id,s.id) product_id
, f.incident_severity_id
, f.customer_id
, f.owner_group_id
, f.sr_creation_channel
, f.resolution_code
, f.time_to_close age' ||
  case when bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
         '
, v.top_node_flag vbh_top_node_flag
, v.parent_id vbh_parent_category_id
, v.imm_child_id vbh_child_category_id'
       else null
  end || '
from
  biv_dbi_closed_sum_f f
, eni_oltp_item_star s' ||
  case when bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
         '
, eni_denorm_hierarchies v
, mtl_default_category_sets m'
       else null
  end || '
where
    f.inventory_item_id = s.inventory_item_id
and f.inv_organization_id = s.organization_id' ||
  case when bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
         '
and m.functional_area_id = 11
and v.object_id = m.category_set_id
and v.dbi_flag = ''Y''
and v.object_type = ''CATEGORY_SET''
and s.vbh_category_id = v.child_id'
       else null
  end || '
and f.reopened_date is null
and f.time_to_close >= 0
)';

  elsif p_report_type = 'RESOLVED_DETAIL' then
    return '(
select
  f.report_date resolved_date
, f.incident_id
, f.incident_type_id
, nvl(s.master_id,s.id) product_id
, f.incident_severity_id
, f.customer_id
, f.owner_group_id
, f.sr_creation_channel
, f.resolution_code
, f.time_to_resolution age' ||
  case when bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
         '
, v.top_node_flag vbh_top_node_flag
, v.parent_id vbh_parent_category_id
, v.imm_child_id vbh_child_category_id'
       else null
  end || '
from
  biv_dbi_resolution_sum_f f
, eni_oltp_item_star s' ||
  case when bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
         '
, eni_denorm_hierarchies v
, mtl_default_category_sets m'
       else null
  end || '
where
    f.inventory_item_id = s.inventory_item_id
and f.inv_organization_id = s.organization_id' ||
  case when bitand(p_bmap,g_CATEGORY_BMAP) = g_CATEGORY_BMAP then
         '
and m.functional_area_id = 11
and v.object_id = m.category_set_id
and v.dbi_flag = ''Y''
and v.object_type = ''CATEGORY_SET''
and s.vbh_category_id = v.child_id'
       else null
  end || '
and f.time_to_resolution >= 0
)';
  end if;

  return '';
end get_fact_mv_name;

procedure init_dim_map
( x_dim_map         out nocopy poa_DBI_UTIL_PKG.poa_dbi_dim_map
, p_report_type     in varchar2 -- 'ACTIVITY','CLOSED','BACKLOG','BACKLOG_AGE'
                                -- 'BACKLOG_DETAIL', 'CLOSED_DETAIL', 'RESOLVED'
				-- , 'RESOLVED_DETAIL'
, p_product_cat     in varchar2
) is
  l_dim_rec poa_DBI_UTIL_PKG.poa_dbi_dim_rec;
begin
  -- Request Type
  l_dim_rec.col_name := get_fact_col_name(g_REQUEST_TYPE);
  l_dim_rec.view_by_table := get_dim_table_name(g_REQUEST_TYPE);
  l_dim_rec.bmap := G_REQUEST_TYPE_BMAP;
  x_dim_map(g_REQUEST_TYPE) := l_dim_rec;

  -- Product Category
  l_dim_rec.col_name := get_fact_col_name(g_CATEGORY, p_product_cat);
  l_dim_rec.view_by_table := get_dim_table_name(g_CATEGORY);
  l_dim_rec.bmap := G_CATEGORY_BMAP;
  x_dim_map(g_CATEGORY) := l_dim_rec;

  -- Product
  l_dim_rec.col_name := get_fact_col_name(g_PRODUCT);
  l_dim_rec.view_by_table := get_dim_table_name(g_PRODUCT);
  l_dim_rec.bmap := G_PRODUCT_BMAP;
  x_dim_map(g_PRODUCT) := l_dim_rec;

  -- Severity
  l_dim_rec.col_name := get_fact_col_name(g_SEVERITY);
  l_dim_rec.view_by_table := get_dim_table_name(g_SEVERITY);
  l_dim_rec.bmap := G_SEVERITY_BMAP;
  x_dim_map(g_SEVERITY) := l_dim_rec;

  -- Status
  if p_report_type in ('BACKLOG','BACKLOG_AGE','BACKLOG_DETAIL') then
    l_dim_rec.col_name := get_fact_col_name(g_STATUS);
    l_dim_rec.view_by_table := get_dim_table_name(g_STATUS);
    l_dim_rec.bmap := G_STATUS_BMAP;
    x_dim_map(g_STATUS) := l_dim_rec;
  end if;

  -- Channel
  if p_report_type in ( 'ACTIVITY', 'CLOSED','CLOSED_DETAIL', 'RESOLVED','RESOLVED_DETAIL' ) then
    l_dim_rec.col_name := get_fact_col_name(g_CHANNEL);
    l_dim_rec.view_by_table := get_dim_table_name(g_CHANNEL);
    l_dim_rec.bmap := G_CHANNEL_BMAP;
    x_dim_map(g_CHANNEL) := l_dim_rec;
  end if;

  -- Resolution
  if p_report_type in ( 'CLOSED','CLOSED_DETAIL','RESOLVED' ,'RESOLVED_DETAIL' ) then
    l_dim_rec.col_name := get_fact_col_name(g_RESOLUTION);
    l_dim_rec.view_by_table := get_dim_table_name(g_RESOLUTION);
    l_dim_rec.bmap := G_RESOLUTION_BMAP;
    x_dim_map(g_RESOLUTION) := l_dim_rec;
  end if;

  -- Customer
  l_dim_rec.col_name := get_fact_col_name(g_CUSTOMER);
  l_dim_rec.view_by_table := get_dim_table_name(g_CUSTOMER);
  l_dim_rec.bmap := G_CUSTOMER_BMAP;
  x_dim_map(g_CUSTOMER) := l_dim_rec;

  -- Assignment Group
  l_dim_rec.col_name := get_fact_col_name(g_ASSIGNMENT);
  l_dim_rec.view_by_table := get_dim_table_name(g_ASSIGNMENT);
  l_dim_rec.bmap := G_ASSIGNMENT_BMAP;
  x_dim_map(g_ASSIGNMENT) := l_dim_rec;

  if p_report_type in ( 'BACKLOG_DETAIL', 'CLOSED_DETAIL', 'RESOLVED_DETAIL' ) then
    l_dim_rec.col_name := '<replace this>';
    l_dim_rec.view_by_table := get_dim_table_name(g_AGING);
    l_dim_rec.bmap := g_AGING_BMAP;
    x_dim_map(g_AGING) := l_dim_rec;
  end if;

  -- Backlog Type
  if p_report_type = 'BACKLOG_AGE' then
    l_dim_rec.col_name := get_fact_col_name(g_BACKLOG_TYPE);
    l_dim_rec.view_by_table := get_dim_table_name(g_BACKLOG_TYPE);
    l_dim_rec.bmap := g_BACKLOG_TYPE_BMAP;
    -- don't register Backlog Type as we deal with this in the
    -- outer query
    --x_dim_map(g_BACKLOG_TYPE) := l_dim_rec;
  end if;

  -- Resolution Status
  l_dim_rec.col_name := get_fact_col_name(g_RES_STATUS);
  l_dim_rec.view_by_table := get_dim_table_name(g_RES_STATUS);
  l_dim_rec.bmap := g_RES_STATUS_BMAP;
  x_dim_map(g_RES_STATUS) := l_dim_rec;


end init_dim_map;

function get_join_info
( p_view_by in varchar2
, p_dim_map in poa_DBI_UTIL_PKG.poa_dbi_dim_map
)
return poa_DBI_UTIL_PKG.poa_dbi_join_tbl
is
  l_join_rec poa_DBI_UTIL_PKG.poa_dbi_join_rec;
  l_join_tbl poa_DBI_UTIL_PKG.poa_dbi_join_tbl;
begin
  -- reinitialize the join table
  l_join_tbl := poa_DBI_UTIL_PKG.poa_dbi_join_tbl();

  -- If the view by column is not in the bitmap, then
  -- there is nothing to join to. Can this ever be true?
  if (not p_dim_map.exists(p_view_by)) then
    return l_join_tbl;
  end if;

  -- Otherwise, join to a table
  -- The view by table
  l_join_rec.table_name := p_dim_map(p_view_by).view_by_table;
  l_join_rec.table_alias := 'v';

  -- the fact column to join to
  l_join_rec.fact_column := p_dim_map(p_view_by).col_name;

  --
  if p_view_by = g_CATEGORY then
    l_join_rec.additional_where_clause := 'v.parent_id = v.child_id';
  end if;

  -- depending on the dimension level, select the appropriate
  -- join table column name
  l_join_rec.column_name :=
         (case p_view_by
            when g_REQUEST_TYPE then 'id'
            when g_CATEGORY then 'id'
            when g_PRODUCT then 'id'
            when g_SEVERITY then 'id'
            when g_STATUS then 'id'
            when g_CHANNEL then 'id'
            when g_RESOLUTION then 'id'
            when g_CUSTOMER then 'id'
            when g_ASSIGNMENT then 'id'
            when g_AGING then 'id'
            when g_RES_STATUS then 'id'
            else ''
          end);

  --l_join_rec.dim_outer_join := 'Y';

  -- Add the join table
  l_join_tbl.extend;
  l_join_tbl(l_join_tbl.count) := l_join_rec;

  return l_join_tbl;

END get_join_info;

function get_type_sec_where_clause
return varchar2
is
begin
  return biv_dbi_tmpl_sec.get_type_sec_where_clause;
end get_type_sec_where_clause;

function get_product_category
( p_param in bis_pmv_page_parameter_tbl )
return varchar2
is
begin
  for i in 1..p_param.count loop
    if p_param(i).parameter_name = g_CATEGORY then
      return replace(p_param(i).parameter_id,'''',null);
    end if;
  end loop;
  return null;
end get_product_category;

procedure get_detail_join_info
( p_report_type in varchar2
, x_join_from   out nocopy varchar2
, x_join_where  out nocopy varchar2
)
is

  l_dim_map  poa_DBI_UTIL_PKG.poa_dbi_dim_map;
  l_alias    varchar2(10);
  l_dim      varchar2(50);

begin

  init_dim_map(l_dim_map, p_report_type, 'All');

  l_dim := l_dim_map.first;
  loop
    exit when l_dim is null;

    if l_dim = g_REQUEST_TYPE then
      l_alias := 'rt';
    elsif l_dim = g_PRODUCT then
      l_alias := 'pr';
    elsif l_dim = g_SEVERITY then
      l_alias := 'sv';
    elsif l_dim = g_STATUS then
      l_alias := 'st';
    elsif l_dim = g_CHANNEL then
      l_alias := 'ch';
    elsif l_dim = g_RESOLUTION then
      l_alias := 're';
    elsif l_dim = g_CUSTOMER then
      l_alias := 'cu';
    elsif l_dim = g_ASSIGNMENT then
      l_alias := 'ag';
    elsif l_dim = g_RES_STATUS then
      l_alias := 'rs';
    else
      l_alias := null;
    end if;

-- added l_alias <> rs condition to avoid joins to resolved dimension
    if (l_alias is not null and  l_alias <> 'rs') then
      x_join_from := x_join_from || '
, ' || l_dim_map(l_dim).view_by_table || ' ' || l_alias;

      x_join_where := x_join_where || '
and fact.' || l_dim_map(l_dim).col_name || ' = ' || l_alias || '.id';

    end if;

    l_dim := l_dim_map.next(l_dim);
  end loop;

end get_detail_join_info;

-- ------------------------------------------------------------
-- PUBLIC PROCEDURES ARE HERE
-- ------------------------------------------------------------

procedure process_parameters
( p_param            in bis_pmv_page_parameter_tbl
, p_report_type      in varchar2 -- 'ACTIVITY','CLOSED','BACKLOG','BACKLOG_AGE'
, p_trend            in varchar2
, x_view_by          out nocopy varchar2
, x_view_by_col_name out nocopy varchar2
, x_comparison_type  out nocopy varchar2
, x_xtd              out nocopy varchar2
, x_where_clause     out nocopy varchar2
, x_mv               out nocopy varchar2
, x_join_tbl         out nocopy poa_DBI_UTIL_PKG.poa_dbi_join_tbl
, x_as_of_date       out nocopy date
) is

  l_dim_map         poa_DBI_UTIL_PKG.poa_dbi_dim_map;
  l_as_of_date      date;
  l_prev_as_of_date date;
  l_nested_pattern  number;
  l_cur_suffix      varchar2(1);
  l_dim_bmap        number := 0;
  l_view_by         varchar2(50);
  l_where_clause    varchar2(10000);
  l_mv_name         varchar2(10000);
  l_product_cat     varchar2(1000);

begin

  l_product_cat := get_product_category(p_param);

  init_dim_map(l_dim_map, p_report_type, l_product_cat);

  poa_DBI_UTIL_PKG.get_parameter_values
  ( p_param           => p_param
  , p_dim_map         => l_dim_map
  , p_view_by         => l_view_by
  , p_comparison_type => x_comparison_type
  , p_xtd             => x_xtd
  , p_as_of_date      => x_as_of_date
  , p_prev_as_of_date => l_prev_as_of_date
  , p_cur_suffix      => l_cur_suffix
  , p_nested_pattern  => l_nested_pattern
  , p_dim_bmap        => l_dim_bmap
  );

  l_mv_name := get_fact_mv_name(p_report_type, l_dim_bmap,x_xtd);

  if (l_dim_map.exists(l_view_by)) then
    if l_dim_map(l_view_by).col_name = 'vbh_child_category_id' and
       l_product_cat is null then
      x_view_by_col_name := 'vbh_parent_category_id';
    else
      x_view_by_col_name := l_dim_map(l_view_by).col_name;
    end if;
  end if;

  x_view_by := l_view_by;

  l_where_clause := poa_DBI_UTIL_PKG.get_where_clauses(l_dim_map, p_trend);

  if l_mv_name like '%_h_sum_mv%' or
     l_mv_name like '%vbh_top_node_flag%' then
    if l_product_cat is null then
      l_where_clause := l_where_clause || ' and fact.vbh_top_node_flag = ''Y''';
    else
      l_where_clause := replace(l_where_clause, 'vbh_child_category_id', 'vbh_parent_category_id');
    end if;
  end if;

  l_where_clause := l_where_clause || get_type_sec_where_clause;

  x_where_clause := l_where_clause;

  x_join_tbl := get_join_info(l_view_by, l_dim_map);

  -- no longer need to do this as poa_DBI_UTIL_PKG.get_parameter_values
  -- does it correctly.
  --
  -- x_xtd := get_period_type(p_param);

  x_mv := l_mv_name;


end process_parameters;

function get_period_type
( p_param in bis_pmv_page_parameter_tbl )
return varchar2
is
begin
  for i in 1..p_param.count loop
    if p_param(i).parameter_name = 'PERIOD_TYPE' then
      return case
               when p_param(i).parameter_value = 'FII_ROLLING_WEEK' then
                 'RLW'
               when p_param(i).parameter_value = 'FII_ROLLING_MONTH' then
                 'RLM'
               when p_param(i).parameter_value = 'FII_ROLLING_QTR' then
                 'RLQ'
               when p_param(i).parameter_value = 'FII_ROLLING_YEAR' then
                 'RLY'
               else
                 ''
             end;
    end if;
  end loop;
  return null;
end get_period_type;

function get_backlog_type
( p_param in bis_pmv_page_parameter_tbl )
return varchar2
is
begin
  for i in 1..p_param.count loop
    if p_param(i).parameter_name = g_BACKLOG_TYPE then
      return replace(p_param(i).parameter_id,'''',null);
    end if;
  end loop;
  return null;
end get_backlog_type;

function get_bucket_query
( p_column_name_base in varchar2
, p_column_number    in number
, p_alias_base       in varchar2
, p_total_flag       in varchar2
, p_backlog_col      in varchar2
)
return varchar2
is
begin
  if p_backlog_col is null then
    return ', nvl(' || p_column_name_base || '_b' || p_column_number ||
                       case p_total_flag
                         when 'Y' then '_total'
                       end || ',0) ' ||
               p_alias_base || '_B' || p_column_number;
  end if;
  return ', ' || rate_column( p_column_name_base || '_b' || p_column_number ||
                              case p_total_flag
                                when 'Y' then '_total'
                              end
                            , p_backlog_col ||
                              case p_total_flag
                                when 'Y' then '_total'
                              end
                            , p_alias_base || '_B' || p_column_number
                            );

end get_bucket_query;

function get_bucket_outer_query
( p_bucket_rec       in bis_bucket_pub.bis_bucket_rec_type
, p_column_name_base in varchar2
, p_alias_base       in varchar2
, p_total_flag       in varchar2 default 'N'
, p_backlog_col      in varchar2 default null
)
return varchar2
is
  l_query varchar2(10000);
begin
  if p_bucket_rec.range1_name is not null then
    l_query := get_bucket_query(p_column_name_base,1,p_alias_base,p_total_flag,p_backlog_col);
  end if;
  if p_bucket_rec.range2_name is not null then
    l_query := l_query || fnd_global.newline ||
               get_bucket_query(p_column_name_base,2,p_alias_base,p_total_flag,p_backlog_col);
  end if;
  if p_bucket_rec.range3_name is not null then
    l_query := l_query || fnd_global.newline ||
               get_bucket_query(p_column_name_base,3,p_alias_base,p_total_flag,p_backlog_col);
  end if;
  if p_bucket_rec.range4_name is not null then
    l_query := l_query || fnd_global.newline ||
               get_bucket_query(p_column_name_base,4,p_alias_base,p_total_flag,p_backlog_col);
  end if;
  if p_bucket_rec.range5_name is not null then
    l_query := l_query || fnd_global.newline ||
               get_bucket_query(p_column_name_base,5,p_alias_base,p_total_flag,p_backlog_col);
  end if;
  if p_bucket_rec.range6_name is not null then
    l_query := l_query || fnd_global.newline ||
               get_bucket_query(p_column_name_base,6,p_alias_base,p_total_flag,p_backlog_col);
  end if;
  if p_bucket_rec.range7_name is not null then
    l_query := l_query || fnd_global.newline ||
               get_bucket_query(p_column_name_base,7,p_alias_base,p_total_flag,p_backlog_col);
  end if;
  if p_bucket_rec.range8_name is not null then
    l_query := l_query || fnd_global.newline ||
               get_bucket_query(p_column_name_base,8,p_alias_base,p_total_flag,p_backlog_col);
  end if;
  if p_bucket_rec.range9_name is not null then
    l_query := l_query || fnd_global.newline ||
               get_bucket_query(p_column_name_base,9,p_alias_base,p_total_flag,p_backlog_col);
  end if;
  if p_bucket_rec.range10_name is not null then
    l_query := l_query || fnd_global.newline ||
               get_bucket_query(p_column_name_base,10,p_alias_base,p_total_flag,p_backlog_col);
  end if;
  return l_query;
end get_bucket_outer_query;

procedure add_bucket_inner_query
( p_short_name   in varchar2
, p_col_tbl      in out nocopy poa_DBI_UTIL_PKG.poa_dbi_col_tbl
, p_col_name     in varchar2
, p_alias_name   in varchar2
, p_grand_total  in varchar2
, p_prior_code   in varchar2
, p_to_date_type in varchar2
, x_bucket_rec   out nocopy bis_bucket_pub.bis_bucket_rec_type
)
is
  l_bucket_rec bis_bucket_pub.bis_bucket_rec_type;
  l_return_status varchar2(3);
  l_error_tbl bis_utilities_pub.error_tbl_type;
begin
  bis_bucket_pub.retrieve_bis_bucket
  ( p_short_name     => p_short_name
  , x_bis_bucket_rec => l_bucket_rec
  , x_return_status  => l_return_status
  , x_error_tbl      => l_error_tbl
  );
  if l_return_status = 'S' then
    if l_bucket_rec.range1_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b1'
      , p_alias_name => p_alias_name || '_b1'
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range2_name is not null then
     poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b2'
      , p_alias_name => p_alias_name || '_b2'
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range3_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b3'
      , p_alias_name => p_alias_name || '_b3'
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range4_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b4'
      , p_alias_name => p_alias_name || '_b4'
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range5_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b5'
      , p_alias_name => p_alias_name || '_b5'
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range6_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b6'
      , p_alias_name => p_alias_name || '_b6'
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range7_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b7'
      , p_alias_name => p_alias_name || '_b7'
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range8_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b8'
      , p_alias_name => p_alias_name || '_b8'
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range9_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b9'
      , p_alias_name => p_alias_name || '_b9'
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
    if l_bucket_rec.range10_name is not null then
      poa_DBI_UTIL_PKG.add_column
      ( p_col_tbl    => p_col_tbl
      , p_col_name   => p_col_name || '_b10'
      , p_alias_name => p_alias_name || '_b10'
      , p_to_date_type => p_to_date_type
      , p_prior_code => p_prior_code
      );
    end if;
  end if;
  x_bucket_rec := l_bucket_rec;
end add_bucket_inner_query;

function get_view_by_col_name
( p_dim_name in varchar2 )
return varchar2
is
  l_col_name varchar2(60);
begin
  return (case p_dim_name
            when g_REQUEST_TYPE then 'v.value'
            when g_CATEGORY then 'v.value'
            when g_PRODUCT then 'v.value'
            when g_SEVERITY then 'v.value'
            when g_STATUS then 'v.value'
            when g_CHANNEL then 'v.value'
            when g_RESOLUTION then 'v.value'
            when g_CUSTOMER then 'v.value'
            when g_ASSIGNMENT then 'v.value'
            when g_AGING then 'v.value'
            when g_RES_STATUS then 'v.value'
            else ''
          end);
end get_view_by_col_name;

function get_category_drill_down
( p_view_by_name  in varchar2
, p_function_name in varchar2
, p_column_alias  in varchar2 default 'BIV_ATTRIBUTE4' )
return varchar2
is
begin
  if p_view_by_name = g_CATEGORY then
    return 'decode(v.leaf_node_flag, ''Y''' ||
                 ',''pFunctionName=' || p_function_name || '&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y''' ||
                 ',''pFunctionName=' || p_function_name || '&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y''' ||
                 ') ' || p_column_alias;
  end if;

  return 'null ' || p_column_alias;

end get_category_drill_down;

-- this is a wrapper to poa_dbi_util_pkg.change_clause
function change_column
( p_current_column  in varchar2
, p_prior_column    in varchar2
, p_column_alias    in varchar2
, p_percent         in varchar2 default 'Y'
) return varchar2
is
begin
  if p_percent = 'Y' then
    return poa_DBI_UTIL_PKG.change_clause(p_current_column,p_prior_column) ||
           ' ' || p_column_alias;
  end if;
--  return poa_DBI_UTIL_PKG.change_clause('nvl('||p_current_column||',0)',p_prior_column,'X') ||
  return poa_DBI_UTIL_PKG.change_clause(p_current_column,p_prior_column,'X') ||
         ' ' || p_column_alias;
end change_column;

-- this is a wrapper to poa_dbi_util_pkg.rate_clause
function rate_column
( p_numerator       in varchar2
, p_denominator     in varchar2
, p_column_alias    in varchar2
, p_percent         in varchar2 default 'Y'
) return varchar2
is
begin
  return poa_DBI_UTIL_PKG.rate_clause( p_numerator
                                     , p_denominator
                                     , case p_percent
                                         when 'Y' then 'P'
                                         else 'NP'
                                       end ) ||
         ' ' || p_column_alias;
end rate_column;

function dump_parameters
( p_param in bis_pmv_page_parameter_tbl )
return varchar2
is
  l_stmt varchar2(10000);
begin
  l_stmt := '
/*
';
  for i in 1..p_param.count loop
    l_stmt := l_stmt || '"' || p_param(i).parameter_name ||
                        ',' || p_param(i).parameter_value ||
                        ',' || p_param(i).parameter_id ||
                        ',' || p_param(i).dimension ||
                        ',' || p_param(i).period_date ||
                        '"
';
  end loop;
  l_stmt := l_stmt || '*/';
  return l_stmt;
end dump_parameters;

function dump_binds
( p_custom_output in bis_query_attributes_tbl)
return varchar2
IS
   l_stmt varchar2(10000);
BEGIN
  l_stmt := '
/*
';
  for i in 1..p_custom_output.count loop
    l_stmt := l_stmt || '"' || p_custom_output(i).attribute_name ||
                        ',' || p_custom_output(i).attribute_value ||
                        ',' || p_custom_output(i).attribute_type ||
                        ',' || p_custom_output(i).attribute_data_type ||
                        '"
';
  end loop;
  l_stmt := l_stmt || '*/';
  return l_stmt;
END;


procedure override_order_by
( p_view_by in varchar2
, p_param   in bis_pmv_page_parameter_tbl
, p_stmt    in out nocopy varchar2
)
is
  l_orderby varchar2(1000);
begin

  if p_view_by = g_SEVERITY  or
     p_view_by = g_AGING then

    for i in 1..p_param.count loop
      if p_param(i).parameter_name = 'ORDERBY' then
        l_orderby := p_param(i).parameter_value;
        exit;
      end if;
    end loop;

    if l_orderby like '%VIEWBY%' then
      if l_orderby like '% DESC%' then
        l_orderby := 'ORDER BY ' || case p_view_by
                                      when g_SEVERITY then
                                        'v.importance_level'
                                      else
                                        'v.id'
                                    end
                                  || ' DESC, NLSSORT(VIEWBY,''NLS_SORT=BINARY'') DESC';
      else
        l_orderby := 'ORDER BY ' || case p_view_by
                                      when g_SEVERITY then
                                        'v.importance_level'
                                      else
                                        'v.id'
                                    end
                                  || ' ASC, NLSSORT(VIEWBY,''NLS_SORT=BINARY'') ASC';
      end if;
      p_stmt := replace(p_stmt,'&ORDER_BY_CLAUSE',l_orderby);
    end if;

  end if;

end override_order_by;

function get_balance_fact
( p_mv              in varchar2
)
return varchar2
is

  l_collection_date_inc date;
  l_collection_date_ini date;
  l_collection_date date;
  l_collection_name varchar2(50);
  l_mv_name varchar2(50);
  l_mv_date date;

begin

  l_collection_date_inc := fnd_date.displaydt_to_date
                       ( bis_collection_utilities.get_last_refresh_period('BIV_DBI_COLLECTION'));

  l_collection_date_ini := fnd_date.displaydt_to_date
                       ( bis_collection_utilities.get_last_refresh_period('BIV_DBI_COLLECT_INIT_BACKLOG'));

  if l_collection_date_inc > l_collection_date_ini then
    l_collection_date := l_collection_date_inc;
    l_collection_name := 'BIV_DBI_COLLECTION';
  else
    l_collection_date := l_collection_date_ini;
    l_collection_name := 'BIV_DBI_COLLECT_INIT_BACKLOG';
  end if;

  return l_collection_name;

end get_balance_fact;

function get_trace_file_name
return varchar2
is

  l_trace_file_name varchar2(200);

begin
  select
    '/* ' ||
    lower(rtrim(i.instance, chr(0)))||'_ora_'||p.spid||'.trc'
    || ' */'
  into l_trace_file_name
  from
    ( select
        p.spid
      from
        sys.v_$mystat m,
        sys.v_$session s,
        sys.v_$process p
      where
        m.statistic# = 1 and
        s.sid = m.sid and
        p.addr = s.paddr
    ) p,
    ( select
        t.instance
      from
        sys.v_$thread  t,
        sys.v_$parameter  v
      where
        v.name = 'thread' and
        (
          v.value = 0 or
          t.thread# = to_number(v.value)
        )
  ) i;

  return l_trace_file_name;

end get_trace_file_name;

function drill_detail
( p_function_name in varchar2
, p_bucket_number in number
, p_bucket_name   in varchar2
, p_base_alias    in varchar2
) return varchar2
is
  l_base_function varchar2(500) := '
, ''pFunctionName=' || p_function_name || '&pParamIds=Y' ||
  '&BUCKET_AGING+SERVICE_DISTRIBUTION=';
begin

  if p_bucket_number <> 0 and
     p_bucket_name is null then
    return null;
  end if;

  return '
, ''pFunctionName=' || p_function_name ||
     case
       when p_bucket_number = 0 then
         null
       else
         '&SERVICE_DISTRIBUTION=' || p_bucket_number
     end ||
     '&VIEW_BY_NAME=VIEW_BY_ID' ||
     '&pParamIds=Y'' ' ||
     case
       when p_bucket_number = 0 then
         p_base_alias
       else
         p_base_alias || '_B' || p_bucket_number
     end;

end drill_detail;

function bucket_detail_drill
( p_function_name in varchar2
, p_bucket_rec    in bis_bucket_pub.bis_bucket_rec_type
, p_base_alias    in varchar2
) return varchar2
is
begin
  return
    drill_detail(p_function_name, 1, p_bucket_rec.range1_name, p_base_alias) ||
    drill_detail(p_function_name, 2, p_bucket_rec.range2_name, p_base_alias) ||
    drill_detail(p_function_name, 3, p_bucket_rec.range3_name, p_base_alias) ||
    drill_detail(p_function_name, 4, p_bucket_rec.range4_name, p_base_alias) ||
    drill_detail(p_function_name, 5, p_bucket_rec.range5_name, p_base_alias) ||
    drill_detail(p_function_name, 6, p_bucket_rec.range6_name, p_base_alias) ||
    drill_detail(p_function_name, 7, p_bucket_rec.range7_name, p_base_alias) ||
    drill_detail(p_function_name, 8, p_bucket_rec.range8_name, p_base_alias) ||
    drill_detail(p_function_name, 9, p_bucket_rec.range9_name, p_base_alias) ||
    drill_detail(p_function_name, 10, p_bucket_rec.range10_name, p_base_alias);
end bucket_detail_drill;

procedure get_detail_page_function
( x_function_name   out nocopy varchar2
, x_sr_id_parameter out nocopy varchar2
)
is

  l_drill_option constant varchar2(10) := '11.5.10';
  -- note change the above to 11.5.9 to revert to
  -- 11.5.9 drill to SR Quick View

begin

  if l_drill_option = '11.5.10' then
    -- 11.5.10 code ----
    x_function_name := 'CSZ_SR_UP_RO_FN' ||
                       '&cszReadOnlySRPageMode=REGULARREADONLY' ||
--                       '&cszReadOnlySRRetURL=null' ||
--                       '&cszReadOnlySRRetLabel=.' ||
                       '&OAPB=BIV_DBI_SR_BRAND';

    -- note: we are providing empty parameter values for
    --       cszReadOnlySRRetURL and cszReadOnlySRRetLabel
    --       as PMV does not currently provide us with the ability
    --       to return both of these.
    --       the result is that no return link will be rendered on
    --       OA page.

    x_sr_id_parameter := 'cszIncidentId';
    --

  else

    -- 11.5.9 code -----
    x_function_name := 'BIV_DBI_SR_DETAIL_OA';
    x_sr_id_parameter := 'pUpd=N&SR_ID';
    --

  end if;

end get_detail_page_function;

procedure bind_yes_no
( p_yes           in varchar2
, p_no            in varchar2
, p_custom_output in out nocopy bis_query_attributes_tbl
)
is

  cursor c_yes_no is
    -- the max function enables the to rows to be returned via a single fetch
    select
      max(decode(lookup_code,'Y',meaning,null))
    , max(decode(lookup_code,'N',meaning,null))
    from fnd_lookup_values
    where lookup_type = 'YES_NO'
    and view_application_id = 0
    and language = userenv('LANG');

  l_yes varchar2(80);
  l_no varchar2(80);

  l_custom_rec BIS_QUERY_ATTRIBUTES;

begin

  open c_yes_no;
  fetch c_yes_no into l_yes, l_no;
  close c_yes_no;

  if p_custom_output is null then
    p_custom_output := bis_query_attributes_tbl();
  end if;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  l_custom_rec.attribute_name := p_yes;
  l_custom_rec.attribute_value := l_yes;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := p_no;
  l_custom_rec.attribute_value := l_no;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

end bind_yes_no;

procedure bind_low_high
( p_param         in bis_pmv_page_parameter_tbl
, p_short_name    in varchar2
, p_low           in varchar2
, p_high          in varchar2
, p_custom_output in out nocopy bis_query_attributes_tbl
)
is

  l_range_low number;
  l_range_high number;

  l_range_id number;
  l_bucket_rec bis_bucket_pub.bis_bucket_rec_type;
  l_return_status varchar2(3);
  l_error_tbl bis_utilities_pub.error_tbl_type;

  l_custom_rec BIS_QUERY_ATTRIBUTES;

begin

  for i in 1..p_param.count loop
    if p_param(i).parameter_name = g_AGING then
      l_range_id :=  replace(p_param(i).parameter_id,'''',null);
    end if;
  end loop;

  if l_range_id is null then
    return;
  end if;

  bis_bucket_pub.retrieve_bis_bucket
  ( p_short_name     => p_short_name
  , x_bis_bucket_rec => l_bucket_rec
  , x_return_status  => l_return_status
  , x_error_tbl      => l_error_tbl
  );

  if l_return_status = 'S' then

    if l_range_id = 1 then
      l_range_low := l_bucket_rec.range1_low;
      l_range_high := l_bucket_rec.range1_high;
    elsif l_range_id = 2 then
      l_range_low := l_bucket_rec.range2_low;
      l_range_high := l_bucket_rec.range2_high;
    elsif l_range_id = 3 then
      l_range_low := l_bucket_rec.range3_low;
      l_range_high := l_bucket_rec.range3_high;
    elsif l_range_id = 4 then
      l_range_low := l_bucket_rec.range4_low;
      l_range_high := l_bucket_rec.range4_high;
    elsif l_range_id = 5 then
      l_range_low := l_bucket_rec.range5_low;
      l_range_high := l_bucket_rec.range5_high;
    elsif l_range_id = 6 then
      l_range_low := l_bucket_rec.range6_low;
      l_range_high := l_bucket_rec.range6_high;
    elsif l_range_id = 7 then
      l_range_low := l_bucket_rec.range7_low;
      l_range_high := l_bucket_rec.range7_high;
    elsif l_range_id = 8 then
      l_range_low := l_bucket_rec.range8_low;
      l_range_high := l_bucket_rec.range8_high;
    elsif l_range_id = 9 then
      l_range_low := l_bucket_rec.range9_low;
      l_range_high := l_bucket_rec.range9_high;
    elsif l_range_id = 10 then
      l_range_low := l_bucket_rec.range10_low;
      l_range_high := l_bucket_rec.range10_high;
    end if;
  end if;

  if p_custom_output is null then
    p_custom_output := bis_query_attributes_tbl();
  end if;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  l_custom_rec.attribute_name := p_low;
  l_custom_rec.attribute_value := l_range_low;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := p_high;
  l_custom_rec.attribute_value := l_range_high;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

end bind_low_high;

procedure process_parameters
( p_param            in bis_pmv_page_parameter_tbl
, p_report_type      in varchar2 -- 'BACKLOG_DETAIL', 'CLOSED_DETAIL', 'RESOLVED_DETAIL'
, x_where_clause     out nocopy varchar2
, x_xtd              out nocopy varchar2
, x_mv               out nocopy varchar2
, x_join_from        out nocopy varchar2
, x_join_where       out nocopy varchar2
, x_join_tbl         out nocopy poa_DBI_UTIL_PKG.poa_dbi_join_tbl
, x_as_of_date       out nocopy date
)
is

  l_view_by           varchar2(500);
  l_view_by_col_name  varchar2(500);
  l_comparison_type   varchar2(100);
  l_xtd               varchar2(100);

begin
  process_parameters
  ( p_param            => p_param
  , p_report_type      => p_report_type
  , p_trend            => 'N'
  , x_view_by          => l_view_by -- ignore
  , x_view_by_col_name => l_view_by_col_name -- ignore
  , x_comparison_type  => l_comparison_type -- ignore
  , x_xtd              => x_xtd -- ignore
  , x_where_clause     => x_where_clause
  , x_mv               => x_mv
  , x_join_tbl         => x_join_tbl
  , x_as_of_date       => x_as_of_date
  );

  get_detail_join_info
  ( p_report_type => p_report_type
  , x_join_from   => x_join_from
  , x_join_where  => x_join_where
  );

end process_parameters;

function get_order_by
( p_param in bis_pmv_page_parameter_tbl )
return varchar2
is

begin
  for i in 1..p_param.count loop
    if p_param(i).parameter_name = 'ORDERBY' then
      return p_param(i).parameter_value;
    end if;
  end loop;
  return null;
end get_order_by;

procedure bind_age_dates
( p_param            in bis_pmv_page_parameter_tbl
, p_current_name     in varchar2
, p_prior_name       in varchar2
, p_custom_output in out nocopy bis_query_attributes_tbl
)
is

  l_period_type     varchar2(200);
  l_comparison_type varchar2(200);
  l_current_date    date;
  l_current_date_time number;
  l_prior_date      date;

  l_custom_rec BIS_QUERY_ATTRIBUTES;

begin

  for i in 1..p_param.count loop
    if p_param(i).parameter_name = 'PERIOD_TYPE' then
      l_period_type := p_param(i).parameter_value;
    elsif p_param(i).parameter_name = 'TIME_COMPARISON_TYPE' then
      l_comparison_type := p_param(i).parameter_value;
    end if;
    if l_period_type is not null and
       l_comparison_type is not null then
      exit;
    end if;
  end loop;

  select max(report_date)
  into l_current_date
  from biv_dbi_backlog_age_dates;

  l_current_date_time := l_current_date - trunc(l_current_date);
  l_current_date := trunc(l_current_date);

  if l_comparison_type = 'YEARLY' then
    l_prior_date := add_months(l_current_date,-12);
  else
    l_prior_date := l_current_date - case l_period_type
                                       when 'FII_ROLLING_WEEK' then 7
                                       when 'FII_ROLLING_MONTH' then 30
                                       when 'FII_ROLLING_QTR' then 90
                                       when 'FII_ROLLING_YEAR' then 365
                                       else 0 -- catchall
                                     end;
  end if;

  if p_custom_output is null then
    p_custom_output := bis_query_attributes_tbl();
  end if;

  l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;

  l_custom_rec.attribute_name := p_current_name;
  l_custom_rec.attribute_value := to_char(l_current_date,'dd/mm/yyyy');
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := '&AGE_CURRENT_ASOF_DATE_TIME';
  l_custom_rec.attribute_value := l_current_date_time;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := p_prior_name;
  l_custom_rec.attribute_value := to_char(l_prior_date,'dd/mm/yyyy');
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

end bind_age_dates;

function get_grp_id
( p_bmap in number )
return number
is
  l_grp_id number;
begin
  case
    when bitand(p_bmap,g_RESOLUTION_BMAP) = g_RESOLUTION_BMAP and
         not ( bitand(p_bmap,g_CUSTOMER_BMAP) = g_CUSTOMER_BMAP or
               bitand(p_bmap,g_CHANNEL_BMAP) = g_CHANNEL_BMAP or
               bitand(p_bmap,g_STATUS_BMAP) = g_STATUS_BMAP or
               bitand(p_bmap,g_ASSIGNMENT_BMAP) = g_ASSIGNMENT_BMAP or
               bitand(p_bmap,g_PRODUCT_BMAP) = g_PRODUCT_BMAP ) then
      l_grp_id := 6;
    when bitand(p_bmap,g_CHANNEL_BMAP) = g_CHANNEL_BMAP and
         not ( bitand(p_bmap,g_CUSTOMER_BMAP) = g_CUSTOMER_BMAP or
               bitand(p_bmap,g_RESOLUTION_BMAP) = g_RESOLUTION_BMAP or
               bitand(p_bmap,g_STATUS_BMAP) = g_STATUS_BMAP or
               bitand(p_bmap,g_ASSIGNMENT_BMAP) = g_ASSIGNMENT_BMAP or
               bitand(p_bmap,g_PRODUCT_BMAP) = g_PRODUCT_BMAP ) then
      l_grp_id := 5;
    when bitand(p_bmap,g_STATUS_BMAP) = g_STATUS_BMAP and
         not ( bitand(p_bmap,g_CUSTOMER_BMAP) = g_CUSTOMER_BMAP or
               bitand(p_bmap,g_RESOLUTION_BMAP) = g_RESOLUTION_BMAP or
               bitand(p_bmap,g_CHANNEL_BMAP) = g_CHANNEL_BMAP or
               bitand(p_bmap,g_ASSIGNMENT_BMAP) = g_ASSIGNMENT_BMAP or
               bitand(p_bmap,g_PRODUCT_BMAP) = g_PRODUCT_BMAP ) then
      l_grp_id := 4;
    when bitand(p_bmap,g_ASSIGNMENT_BMAP) = g_ASSIGNMENT_BMAP and
         not ( bitand(p_bmap,g_CUSTOMER_BMAP) = g_CUSTOMER_BMAP or
               bitand(p_bmap,g_RESOLUTION_BMAP) = g_RESOLUTION_BMAP or
               bitand(p_bmap,g_CHANNEL_BMAP) = g_CHANNEL_BMAP or
               bitand(p_bmap,g_STATUS_BMAP) = g_STATUS_BMAP or
               bitand(p_bmap,g_PRODUCT_BMAP) = g_PRODUCT_BMAP ) then
      l_grp_id := 3;
    when bitand(p_bmap,g_CUSTOMER_BMAP) = g_CUSTOMER_BMAP and
         not ( bitand(p_bmap,g_STATUS_BMAP) = g_STATUS_BMAP or
               bitand(p_bmap,g_RESOLUTION_BMAP) = g_RESOLUTION_BMAP or
               bitand(p_bmap,g_CHANNEL_BMAP) = g_CHANNEL_BMAP or
               bitand(p_bmap,g_ASSIGNMENT_BMAP) = g_ASSIGNMENT_BMAP or
               bitand(p_bmap,g_PRODUCT_BMAP) = g_PRODUCT_BMAP ) then
      l_grp_id := 2;
    when bitand(p_bmap,g_PRODUCT_BMAP) = g_PRODUCT_BMAP and
         not ( bitand(p_bmap,g_STATUS_BMAP) = g_STATUS_BMAP or
               bitand(p_bmap,g_RESOLUTION_BMAP) = g_RESOLUTION_BMAP or
               bitand(p_bmap,g_CHANNEL_BMAP) = g_CHANNEL_BMAP or
               bitand(p_bmap,g_ASSIGNMENT_BMAP) = g_ASSIGNMENT_BMAP or
               bitand(p_bmap,g_CUSTOMER_BMAP) = g_CUSTOMER_BMAP ) then
      l_grp_id := 1;
    else
      l_grp_id := 0;
  end case;
  return l_grp_id;
end get_grp_id;

end biv_dbi_tmpl_util;

/
