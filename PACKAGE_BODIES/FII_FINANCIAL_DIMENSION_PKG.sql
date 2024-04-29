--------------------------------------------------------
--  DDL for Package Body FII_FINANCIAL_DIMENSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_FINANCIAL_DIMENSION_PKG" as
/*$Header: FIIFDIMB.pls 120.2 2006/03/27 19:07:52 juding ship $*/

g_debug_flag  VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

/*
function range_or_single(p_coa_id in number) return varchar2 as
  cursor numSeg is
    select count(*)
    from fnd_id_flex_segments
    where application_id = 101
    and   id_flex_code = 'GL#'
    and   id_flex_num = p_coa_id
    and   flex_value_set_id = ENI_VALUESET_CATEGORY.Get_Flex_Value_Set_Id('401', 'MCAT', ENI_DENORM_HRCHY.GET_CATEGORY_SET_ID);
  l_num number;
  l_r varchar2(1);
begin
  open numSeg;
  fetch numSeg into l_num;
  close numSeg;
  if l_num > 0 then
    l_r := 'Y';
  else
    l_r := 'N';
  end if;
  return l_r;
end;
*/
function range_or_single(p_coa_id in number) return varchar2 as
  l_num number;
  l_r varchar2(1);
begin

  begin
    select 1 into l_num
    from fnd_id_flex_segments
    where application_id = 101
    and   id_flex_code = 'GL#'
    and   id_flex_num = p_coa_id
    and   flex_value_set_id = ENI_VALUESET_CATEGORY.Get_Flex_Value_Set_Id('401', 'MCAT', ENI_DENORM_HRCHY.GET_CATEGORY_SET_ID)
    and   ROWNUM = 1;
  exception
    when NO_DATA_FOUND then
         l_num := 0;
  end;

  if l_num > 0 then
    l_r := 'Y';
  else
    l_r := 'N';
  end if;
  return l_r;
end;

/*
 Upon completion, check the value of x_status
 FND_API.G_RET_STS_SUCCESS: OK
 FND_API.G_RET_STS_ERROR  : NOT OK
*/

procedure update_dimension(	p_short_name		in varchar2,
				p_name  		in varchar2,
				p_description  		in varchar2,
				p_system_enabled_flag 	in varchar2,
				p_dbi_enabled_flag 	in varchar2,
				p_master_value_set_id 	in number,
				p_dbi_hier_top_node 	in varchar2,
				p_dbi_hier_top_node_id 	in number,
				x_status 		out nocopy varchar2,
                                x_message_count out nocopy number,
                                x_error_message out nocopy varchar2) as
begin
  if g_debug_flag = 'Y' then
    fii_util.debug_line('FII_FINANCIAL_DIMENSION_PKG.update_demension(+)');
  end if;

  update FII_FINANCIAL_DIMENSIONS
  set    system_enabled_flag = p_system_enabled_flag,
         dbi_enabled_flag = p_dbi_enabled_flag,
         master_value_set_id = p_master_value_set_id,
         dbi_hier_top_node = p_dbi_hier_top_node,
         dbi_hier_top_node_id = p_dbi_hier_top_node_id
  where  dimension_short_name = p_short_name;

  -- delete cross-value set ranges if the parent_value_set_id is not
  -- one of the dimension master value sets
  /*
  delete from fii_dim_norm_hierarchy
  where  child_flex_value_set_id <> parent_flex_value_set_id
  and    parent_flex_value_set_id not in
           ( select master_value_set_id
             from   fii_financial_dimensions_v );
  */
  DELETE /*+ index_ffs(fii_dim_norm_hierarchy) */
  FROM fii_dim_norm_hierarchy
  WHERE child_flex_value_set_id <> parent_flex_value_set_id
  AND NOT EXISTS
  (
   SELECT
       MASTER_VALUE_SET_ID
   FROM
       (
       SELECT /*+ NO_MERGE */
           DECODE(frd.dimension_short_name, 'ENI_ITEM_VBH_CAT',
                  ENI_VALUESET_CATEGORY.GET_FLEX_VALUE_SET_ID(401, 'MCAT',
                                        ENI_DENORM_HRCHY.GET_CATEGORY_SET_ID),
                  frd.master_value_set_id) MASTER_VALUE_SET_ID
       FROM fii_financial_dimensions frd
       WHERE dimension_short_name is not null
       )
   WHERE MASTER_VALUE_SET_ID = parent_flex_value_set_id
     AND MASTER_VALUE_SET_ID is not null
  );

  fii_change_log_pkg.set_recollection_for_fii(x_status,
                                              x_message_count,
                                              x_error_message);
  x_status := FND_API.G_RET_STS_SUCCESS;

  if g_debug_flag = 'Y' then
    fii_util.debug_line('FII_FINANCIAL_DIMENSION_PKG.update_demension(-)');
  end if;

exception
  when others then
    x_status := FND_API.G_RET_STS_ERROR;
    x_message_count := 1;
    FND_MESSAGE.SET_NAME ('FII','FII_ERROR');
    FND_MESSAGE.SET_TOKEN('FUNCTION', 'FII_FINANCIAL_DIMENSION_PKG.update_dimension');
    FND_MESSAGE.SET_TOKEN('SQLERRMC', sqlerrm);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_message_count, p_data => x_error_message);
    if g_debug_flag = 'Y' then
      fii_util.debug_line('FII_FINANCIAL_DIMENSION_PKG.update_demension(EXCEPTION)');
      fii_util.debug_line(sqlerrm);
    end if;
end;

procedure resetProdCateg(        x_status     	     OUT nocopy VARCHAR2,
                                 x_message_count     OUT nocopy NUMBER,
                                 x_error_message     OUT nocopy VARCHAR2) as

cursor dim is
	select chart_of_accounts_id from fii_dim_mapping_rules
        where dimension_short_name = 'ENI_ITEM_VBH_CAT';
n number;
vsid number;
col_name varchar2(30);
begin
  if g_debug_flag = 'Y' then
    fii_util.debug_line('FII_FINANCIAL_DIMENSION_PKG.manage_dimension_map_rules(+)');
  end if;

  for r in dim loop
    begin
      select   	application_column_name,
		flex_value_set_id
      into      col_name,
                vsid
      from	fnd_id_flex_segments
      where 	application_id = 101
      and 	id_flex_code = 'GL#'
      and		id_flex_num = r.chart_of_accounts_id
      and         flex_value_set_id = ENI_VALUESET_CATEGORY.Get_Flex_Value_Set_Id('401', 'MCAT', ENI_DENORM_HRCHY.GET_CATEGORY_SET_ID);

      update fii_dim_mapping_rules
      set    MAPPING_TYPE_CODE = 'S',
              application_column_name1 = col_name,
              flex_value_set_id1 = vsid
      where  DIMENSION_SHORT_NAME = 'ENI_ITEM_VBH_CAT'
      and    CHART_OF_ACCOUNTS_ID = r.chart_of_accounts_id;

    exception
      when TOO_MANY_ROWS then
        update fii_dim_mapping_rules
        set    MAPPING_TYPE_CODE = 'R',
               application_column_name1 = null,
               flex_value_set_id1 = null
        where  DIMENSION_SHORT_NAME = 'ENI_ITEM_VBH_CAT'
        and    CHART_OF_ACCOUNTS_ID = r.chart_of_accounts_id;

      when NO_DATA_FOUND then
        update fii_dim_mapping_rules
        set    MAPPING_TYPE_CODE = 'R',
               application_column_name1 = null,
               flex_value_set_id1 = null
        where  DIMENSION_SHORT_NAME = 'ENI_ITEM_VBH_CAT'
        and    CHART_OF_ACCOUNTS_ID = r.chart_of_accounts_id;

      when others then
        raise;

    end;
  end loop;

  x_status := FND_API.G_RET_STS_SUCCESS;
  if g_debug_flag = 'Y' then
    fii_util.debug_line('FII_FINANCIAL_DIMENSION_PKG.manage_dimension_map_rules(-)');
  end if;

exception
  when others then
    x_status := FND_API.G_RET_STS_ERROR;
    x_message_count := 1;
    FND_MESSAGE.SET_NAME ('FII','FII_ERROR');
    FND_MESSAGE.SET_TOKEN('FUNCTION', 'FII_FINANCIAL_DIMENSION_PKG.resetProdCateg');
    FND_MESSAGE.SET_TOKEN('SQLERRMC', sqlerrm);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_message_count, p_data => x_error_message);
    if g_debug_flag = 'Y' then
      fii_util.debug_line('FII_FINANCIAL_DIMENSION_PKG.resetProdCateg(EXCEPTION)');
      fii_util.debug_line(sqlerrm);
    end if;
end;


procedure manage_dimension_map_rules(p_chart_of_accounts_id in number,
                                     p_event in varchar2,
                                     x_status out nocopy varchar2,
                                     x_message_count out nocopy number,
                                     x_error_message out nocopy varchar2) as

  cursor rules is
	select 	ffd.dimension_short_name 	dimension_short_name,
		fdmr.chart_of_accounts_id       chart_of_accounts_id,
		'O' 				status_code,
		sysdate 			creation_date,
		fnd_global.user_id 		created_by,
		sysdate 			last_update_date,
		fnd_global.user_id 		last_updated_by,
		fnd_global.user_id 		last_update_login,
		'S'				mapping_type_code,
		null 				application_column_name1,
		null 				flex_value_set_id1,
		null 				application_column_name2,
		null 				flex_value_set_id2,
		null 				application_column_name3,
		null 				flex_value_set_id3
        from   	fii_financial_dimensions_v ffd,
               	fii_dim_mapping_rules fdmr
        where  	ffd.dimension_short_name = fdmr.dimension_short_name(+)
        and    	fdmr.chart_of_accounts_id(+) = p_chart_of_accounts_id;

  rule_rec fii_dim_mapping_rules%rowtype;
  l_segment_attribute_type varchar2(30);

  cursor segment(p_chart_of_accounts_id number,
		 p_segment_attribute_type varchar2) is
	select 	fsav.application_column_name,
      	 	fifs.flex_value_set_id
	from   	fnd_id_flex_segments fifs,
       		fnd_segment_attribute_values fsav
	where  	fifs.application_id = 101
	and    	fifs.id_flex_code = 'GL#'
	and    	fifs.application_column_name = fsav.application_column_name
	and    	fifs.id_flex_code = fsav.id_flex_code
	and    	fifs.id_flex_num = fsav.id_flex_num
	and    	fsav.attribute_value = 'Y'
	and    	fifs.id_flex_num = p_chart_of_accounts_id
	and    	fsav.segment_attribute_type = p_segment_attribute_type;

  /*
  cursor coa is
    select 	'X'
    from	fnd_id_flex_structures
    where       application_id = 101
    and         id_flex_code = 'GL#'
    and		id_flex_num = p_chart_of_accounts_id;
  */

  cursor prod_val is
    select	application_column_name,
		flex_value_set_id
    from	fnd_id_flex_segments
    where 	application_id = 101
    and 	id_flex_code = 'GL#'
    and		id_flex_num = p_chart_of_accounts_id
    and         flex_value_set_id = ENI_VALUESET_CATEGORY.Get_Flex_Value_Set_Id('401', 'MCAT', ENI_DENORM_HRCHY.GET_CATEGORY_SET_ID);

  l_x varchar2(1);
  l_p varchar2(1);
  l_col_name varchar2(30);
  l_val_set_id number;
  l_i number := 0;

  cursor forDBI is
    select 'x' from dual
    where exists (select 'x' from fii_source_ledger_groups x, fii_slg_assignments y
                  where x.source_ledger_group_id = y.source_ledger_group_id and
                        y.chart_of_accounts_id =  p_chart_of_accounts_id and
                        x.usage_code='DBI');

begin
  if g_debug_flag = 'Y' then
    fii_util.debug_line('FII_FINANCIAL_DIMENSION_PKG.manage_dimension_map_rules(+)');
  end if;

  if p_event = 'D' then
    delete from fii_dim_mapping_rules
    where chart_of_accounts_id = p_chart_of_accounts_id and
          not exists(select 'x' from
                     fii_slg_assignments
                     where chart_of_accounts_id = p_chart_of_accounts_id);

    fii_change_log_pkg.set_recollection_for_fii(x_status,
                                                x_message_count,
                                                x_error_message);
  elsif p_event = 'I' then
	/*
    open coa;
    fetch coa into l_x;
    close coa;
	*/
   begin
    select 	'X' into l_x
    from	fnd_id_flex_structures
    where       application_id = 101
    and         id_flex_code = 'GL#'
    and		id_flex_num = p_chart_of_accounts_id
    and     ROWNUM = 1;
   exception
    when NO_DATA_FOUND then
         l_x := null;
   end;

    for rule_rec in rules loop
	      if rule_rec.chart_of_accounts_id is null and l_x is not null then

        if rule_rec.dimension_short_name = 'FII_CO' then
          l_segment_attribute_type := 'GL_BALANCING';
        elsif rule_rec.dimension_short_name = 'FII_CC' then
          l_segment_attribute_type := 'FA_COST_CTR';
        elsif rule_rec.dimension_short_name = 'GL_FII_FIN_ITEM' then
          l_segment_attribute_type := 'GL_ACCOUNT';
        else
          l_segment_attribute_type := null;
        end if;

        if l_segment_attribute_type is not null then
          open segment(p_chart_of_accounts_id, l_segment_attribute_type);
          fetch segment into rule_rec.application_column_name1,
                             rule_rec.flex_value_set_id1;
          close segment;
        end if;


        open prod_val;
        loop
	  fetch prod_val into l_col_name, l_val_set_id;
          exit when prod_val%notfound;
          l_i := l_i + 1;
        end loop;
        close prod_val;

        if rule_rec.dimension_short_name = 'ENI_ITEM_VBH_CAT' then
          if l_i = 0 then
            rule_rec.mapping_type_code := 'R';
          else
            rule_rec.mapping_type_code := 'S';
            if l_i = 1 then
              rule_rec.application_column_name1 := l_col_name;
              rule_rec.flex_value_set_id1 := l_val_set_id;
            end if;
          end if;
        end if;

        insert into fii_dim_mapping_rules(
          DIMENSION_SHORT_NAME,
          CHART_OF_ACCOUNTS_ID,
          STATUS_CODE,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          MAPPING_TYPE_CODE,
          APPLICATION_COLUMN_NAME1,
          FLEX_VALUE_SET_ID1,
          APPLICATION_COLUMN_NAME2,
          FLEX_VALUE_SET_ID2,
          APPLICATION_COLUMN_NAME3,
          FLEX_VALUE_SET_ID3
	)
	 values(
          rule_rec.DIMENSION_SHORT_NAME,
          p_chart_of_accounts_id,
          rule_rec.STATUS_CODE,
          rule_rec.CREATION_DATE,
          rule_rec.CREATED_BY,
          rule_rec.LAST_UPDATE_DATE,
          rule_rec.LAST_UPDATED_BY,
          rule_rec.LAST_UPDATE_LOGIN,
          rule_rec.MAPPING_TYPE_CODE,
          rule_rec.APPLICATION_COLUMN_NAME1,
          rule_rec.FLEX_VALUE_SET_ID1,
          rule_rec.APPLICATION_COLUMN_NAME2,
          rule_rec.FLEX_VALUE_SET_ID2,
          rule_rec.APPLICATION_COLUMN_NAME3,
          rule_rec.FLEX_VALUE_SET_ID3);
      end if;
    end loop;

    x_status := FND_API.G_RET_STS_SUCCESS;

    l_x := null;
    open forDBI;
    fetch forDBI into l_x;
    close forDBI;

    if l_x is not null then

      fii_change_log_pkg.set_recollection_for_fii(x_status,
                                                  x_message_count,
                                                  x_error_message);
    end if;
  end if;

  if g_debug_flag = 'Y' then
    fii_util.debug_line('FII_FINANCIAL_DIMENSION_PKG.manage_dimension_map_rules(-)');
  end if;

exception
  when others then
    x_status := FND_API.G_RET_STS_ERROR;
    x_message_count := 1;
    FND_MESSAGE.SET_NAME ('FII','FII_ERROR');
    FND_MESSAGE.SET_TOKEN('FUNCTION', 'FII_FINANCIAL_DIMENSION_PKG.manage_dimension_map_rules');
    FND_MESSAGE.SET_TOKEN('SQLERRMC', sqlerrm);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_message_count, p_data => x_error_message);
    if g_debug_flag = 'Y' then
      fii_util.debug_line('FII_FINANCIAL_DIMENSION_PKG.manage_dimension_map_rules(EXCEPTION)');
      fii_util.debug_line(sqlerrm);
    end if;
end;


/*****************************************************************************
 | DESCRIPTION                                                               |
 | 	Plsql api to delete je inclusion rules associated with a particular  |
 |      je rule set id.  (When slg assignment is deleted, associated         |
 |      je inclusion rules need to be deleted).                              |
 | HISTORY                                                                   |
 |	21-JUL-03	H.Chung		Created  	                     |
 |	05-APR-05	MManasse	Bug 4277376: Added update of je_rule_set_id to null in|
 |							fii_slg_assignments.							 |
 |                                                                           |
 *****************************************************************************/
PROCEDURE DeleteJeInclusionRules(p_je_rule_set_id    IN NUMBER,
                                 x_status            OUT nocopy VARCHAR2,
                                 x_message_count     OUT nocopy NUMBER,
                                 x_error_message     OUT nocopy VARCHAR2)
AS
  l_msg_count number;
  l_msg_data varchar2(2000);
BEGIN
  IF g_debug_flag = 'Y' THEN
    FII_UTIL.debug_line('FII_FINANCIAL_DIMENSION_PKG.DeleteJeInclusionRules(+)');
  END IF;

  DELETE FROM GL_JE_INCLUSION_RULES
  WHERE je_rule_set_id = p_je_rule_set_id;

  UPDATE FII_SLG_ASSIGNMENTS
  SET JE_RULE_SET_ID = NULL WHERE JE_RULE_SET_ID = p_je_rule_set_id;

  x_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_flag = 'Y' THEN
    FII_UTIL.debug_line('FII_FINANCIAL_DIMENSION_PKG.update_demension(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_status := FND_API.G_RET_STS_ERROR;
    x_message_count := 1;
    FND_MESSAGE.SET_NAME ('FII','FII_ERROR');
    FND_MESSAGE.SET_TOKEN('FUNCTION', 'FII_FINANCIAL_DIMENSION_PKG.DeleteJeInclusionRules');
    FND_MESSAGE.SET_TOKEN('SQLERRMC', sqlerrm);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_message_count, p_data => x_error_message);
    IF g_debug_flag = 'Y' THEN
      FII_UTIL.debug_line('FII_FINANCIAL_DIMENSION_PKG.DeleteJeInclusionRules(EXCEPTION)');
      FII_UTIL.debug_line(sqlerrm);
    END IF;
END;

end FII_FINANCIAL_DIMENSION_PKG;

/
