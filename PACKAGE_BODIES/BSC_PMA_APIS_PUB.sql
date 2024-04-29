--------------------------------------------------------
--  DDL for Package Body BSC_PMA_APIS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PMA_APIS_PUB" AS
/* $Header: BSCPMAPB.pls 120.3 2006/01/11 13:26:10 arsantha noship $ */

FUNCTION is_recursive(p_dim_short_name VARCHAR2) return boolean is
cursor cParent is
select dim_level_id, parent_dim_level_id from bsc_sys_dim_level_rels
where dim_level_id in(select dim_level_id from bsc_sys_dim_levels_b where short_name=p_dim_short_name);
l_dim_level_id number;
l_parent_dim_level_id number;
BEGIN
  open cParent;
  fetch cParent into l_dim_level_id, l_parent_dim_level_id;
  if (cParent%NOTFOUND) then
    close cParent;
    return false;
  end if;
  close cParent;
  if (l_dim_level_id=l_parent_dim_level_id) then
    return true;
  end if;
  return false;
END;

procedure drop_denorm_table(p_dim_short_name varchar2) is
l_denorm_table varchar2(100);
begin
  l_denorm_table := BSC_DBGEN_METADATA_READER.get_denorm_dimension_table(p_dim_short_name);
  if bsc_dbgen_utils.table_exists(l_denorm_table) then
    bsc_dbgen_utils.drop_table(l_denorm_table);
  end if;
end;

FUNCTION sync_dimension_table(p_dim_short_name VARCHAR2, p_action VARCHAR2, p_error_message OUT NOCOPY VARCHAR2) return BOOLEAN IS
BEGIN
  if (p_action='DROP') then
    drop_denorm_table(p_dim_short_name);
  elsif p_action='ALTER' then
    -- check if a recursive dim has been changed to non-recursive, in this case, drop denorm table
    if is_recursive(p_dim_short_name)=false then
      drop_denorm_table(p_dim_short_name);
    end if;
  end if;
  return true;
  exception when others then
    p_error_message := sqlerrm;
    return false;
END;

PROCEDURE get_summary_object_for_level(
  p_objective          in number,
  p_periodicity_id     in number,
  p_dim_set_id         in number,
  p_level_pattern      in varchar2,
  p_option_string      in varchar2,
  p_table_name        out nocopy varchar2,
  p_mv_name           out nocopy varchar2,
  p_data_source       out nocopy varchar2,
  p_sql_stmt          out nocopy varchar2,
  p_projection_source out nocopy number,
  p_projection_data   out nocopy varchar2,
  p_error_message     out nocopy varchar2
) IS
cursor cSummaryInfo IS
select table_name, mv_name, data_source, sql_stmt, projection_source, projection_data
  from bsc_kpi_data_tables
 where indicator = p_objective
   and periodicity_id = p_periodicity_id
   and dim_set_id = p_dim_set_id
   and level_comb = p_level_pattern;
BEGIN
  open cSummaryInfo;
  fetch cSummaryInfo into p_table_name, p_mv_name, p_data_source, p_sql_stmt,
        p_projection_source, p_projection_data;
  close cSummaryInfo;
  EXCEPTION WHEN OTHERS THEN
    p_error_message:= 'Error in get_summary_object_for_level:'||sqlerrm;
    RAISE;
END;

END BSC_PMA_APIS_PUB;

/
