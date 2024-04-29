--------------------------------------------------------
--  DDL for Package Body MSD_CS_DFN_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_CS_DFN_UTL" as
/* $Header: msdcsutb.pls 115.9 2002/12/03 20:28:01 pinamati ship $ */

Procedure populate_column_defn_array (p_cs_definition_id in number, p_cs_dfn_clmn_map_list out nocopy G_TYP_CS_DEFN_CLMN_MAP_LIST) is

    cursor c1( p_cs_definition_id number) is
        select * from msd_cs_defn_column_dtls
        where cs_definition_id = p_cs_definition_id;

    l_placeholder  number:=0;
    l_counter      number:=6;
    l_map_list     G_TYP_CS_DEFN_CLMN_MAP_LIST;
Begin
   /*
     initialize first six elements of array
    */
    l_map_list := G_TYP_CS_DEFN_CLMN_MAP_LIST( null);

    For c1_rec in c1(p_cs_definition_id)
    loop

/*        if c1_rec.column_identifier = 'PRD_LEVEL_ID' then
            l_placeholder := C_PRD_LEVEL_ID;
        elsif c1_rec.column_identifier = 'ORG_LEVEL_ID' then
            l_placeholder := C_ORG_LEVEL_ID;
        elsif c1_rec.column_identifier = 'GEO_LEVEL_ID' then
            l_placeholder := C_GEO_LEVEL_ID;
        elsif c1_rec.column_identifier = 'CHN_LEVEL_ID' then
            l_placeholder := C_CHN_LEVEL_ID;
        elsif c1_rec.column_identifier = 'REP_LEVEL_ID' then
            l_placeholder := C_REP_LEVEL_ID;
        elsif c1_rec.column_identifier = 'CUS_LEVEL_ID' then
            l_placeholder := C_CUS_LEVEL_ID;
        else
            l_map_list.extend;
            l_counter := l_counter + 1;
            l_placeholder := l_counter;
        end if;

*/
        l_map_list.extend;
        l_placeholder := l_placeholder + 1;
        l_map_list(l_placeholder).table_column              := c1_rec.table_column;
        l_map_list(l_placeholder).source_view_column_name   := c1_rec.source_view_column_name;
/*        l_map_list(l_placeholder).planning_view_column_name := c1_rec.planning_view_column_name; */
        l_map_list(l_placeholder).column_identifier         := c1_rec.column_identifier;
/*        l_map_list(l_placeholder).alt_key_flag              := c1_rec.alt_key_flag; */
        l_map_list(l_placeholder).index_cntr                := substr(c1_rec.table_column, instr(c1_rec.table_column, '_') + 1);

    end loop;
    p_cs_dfn_clmn_map_list := l_map_list;
End;

Procedure conv_cs_rec_to_array(
    p_cs_rec        in out nocopy G_TYP_ARRAY_VARCHAR,
    p_attribute1    in  varchar2,   p_attribute2    in  varchar2,
    p_attribute3    in  varchar2,   p_attribute4    in  varchar2,
    p_attribute5    in  varchar2,   p_attribute6    in  varchar2,
    p_attribute7    in  varchar2,   p_attribute8    in  varchar2,
    p_attribute9    in  varchar2,   p_attribute10   in  varchar2,
    p_attribute11   in  varchar2,   p_attribute12   in  varchar2,
    p_attribute13   in  varchar2,   p_attribute14   in  varchar2,
    p_attribute15   in  varchar2,   p_attribute16   in  varchar2,
    p_attribute17   in  varchar2,   p_attribute18   in  varchar2,
    p_attribute19   in  varchar2,   p_attribute20   in  varchar2,
    p_attribute21   in  varchar2,   p_attribute22   in  varchar2,
    p_attribute23   in  varchar2,   p_attribute24   in  varchar2,
    p_attribute25   in  varchar2,   p_attribute26   in  varchar2,
    p_attribute27   in  varchar2,   p_attribute28   in  varchar2,
    p_attribute29   in  varchar2,   p_attribute30   in  varchar2,
    p_attribute31   in  varchar2,   p_attribute32   in  varchar2,
    p_attribute33   in  varchar2,   p_attribute34   in  varchar2,
    p_attribute35   in  varchar2,   p_attribute36   in  varchar2,
    p_attribute37   in  varchar2,   p_attribute38   in  varchar2,
    p_attribute39   in  varchar2,   p_attribute40   in  varchar2,
    p_attribute41   in  varchar2,   p_attribute42   in  varchar2,
    p_attribute43   in  varchar2,   p_attribute44   in  varchar2,
    p_attribute45   in  varchar2,   p_attribute46   in  varchar2,
    p_attribute47   in  varchar2,   p_attribute48   in  varchar2,
    p_attribute49   in  varchar2,   p_attribute50   in  varchar2,
    p_attribute51   in  varchar2,   p_attribute52   in  varchar2,
    p_attribute53   in  varchar2,   p_attribute54   in  varchar2,
    p_attribute55   in  varchar2,   p_attribute56   in  varchar2,
    p_attribute57   in  varchar2,   p_attribute58   in  varchar2,
    p_attribute59   in  varchar2,   p_attribute60   in  varchar2) is
Begin

    p_cs_rec := G_TYP_ARRAY_VARCHAR(
        p_attribute1    ,p_attribute2    ,        p_attribute3    ,p_attribute4    ,
        p_attribute5    ,p_attribute6    ,        p_attribute7    ,p_attribute8    ,
        p_attribute9    ,p_attribute10   ,        p_attribute11   ,p_attribute12   ,
        p_attribute13   ,p_attribute14   ,        p_attribute15   ,p_attribute16   ,
        p_attribute17   ,p_attribute18   ,        p_attribute19   ,p_attribute20   ,
        p_attribute21   ,p_attribute22   ,        p_attribute23   ,p_attribute24   ,
        p_attribute25   ,p_attribute26   ,        p_attribute27   ,p_attribute28   ,
        p_attribute29   ,p_attribute30   ,        p_attribute31   ,p_attribute32   ,
        p_attribute33   ,p_attribute34   ,        p_attribute35   ,p_attribute36   ,
        p_attribute37   ,p_attribute38   ,        p_attribute39   ,p_attribute40   ,
        p_attribute41   ,p_attribute42   ,        p_attribute43   ,p_attribute44   ,
        p_attribute45   ,p_attribute46   ,        p_attribute47   ,p_attribute48   ,
        p_attribute49   ,p_attribute50   ,        p_attribute51   ,p_attribute52   ,
        p_attribute53   ,p_attribute54   ,        p_attribute55   ,p_attribute56   ,
        p_attribute57   ,p_attribute58   ,        p_attribute59   ,p_attribute60
        );
End;

Function get_dim_desc ( p_dim_code in varchar2) return varchar2 is

  cursor c1 is
  select meaning from fnd_lookup_values_vl
  where lookup_type = 'MSD_DIMENSIONS' and
        lookup_code = p_dim_code;

  l_ret varchar2(80);

Begin

  open c1;
  fetch c1 into l_ret;
  close c1;

  return nvl(l_ret, p_dim_code);

END;

Function get_level_id ( p_dim_code in varchar2, p_level_name in varchar2) return number is

    cursor c_lvl is
    select level_id
    from msd_levels
    where dimension_code = p_dim_code and level_name = p_level_name;

    l_ret   number;

Begin

  if p_dim_code = 'TIM' then
    /* Get Level name from lookup */
    l_ret := p_level_name;

  else

    open c_lvl;
    fetch c_lvl into l_ret;
    close c_lvl;

  end if;
  --
  return l_ret;
End;

Function get_level_name ( p_dim_code in varchar2, p_level_id varchar2) return varchar2 is

    cursor c_lvl is
    select level_name
    from msd_levels
    where dimension_code = p_dim_code and level_id = p_level_id;

    l_ret   varchar2(80);

Begin

  if p_dim_code = 'TIM' then
    /* Get Level name from lookup */
    l_ret := p_level_id;

  else

    open c_lvl;
    fetch c_lvl into l_ret;
    close c_lvl;

  end if;
  --
  return l_ret;
End;

Function get_level_desc ( p_dim_code in varchar2, p_level_id varchar2) return varchar2 is

    cursor c_tim is
    select meaning
    from fnd_lookup_values_vl
    where lookup_type = 'MSD_PERIOD_TYPE' and
          lookup_code = p_level_id;

    cursor c_lvl is
    select description
    from msd_levels_v
    where owning_dimension_code = p_dim_code and level_id = p_level_id;

    l_ret   varchar2(80);

Begin

  if p_dim_code = 'TIM' then
    /* Get Level name from lookup */
    open c_tim;
    fetch c_tim into l_ret;
    close c_tim;

  else

    open c_lvl;
    fetch c_lvl into l_ret;
    close c_lvl;

  end if;
  --
  return l_ret;
End;


Function get_planning_server_clmn ( p_cs_definition_id in varchar2, p_column_identifier in varchar2) return varchar2 is

    cursor c is
    select planning_view_column_name
    from msd_cs_defn_column_dtls_v
    where cs_definition_id  = p_cs_definition_id and column_identifier = p_column_identifier;


    l_ret   varchar2(200);

Begin

    if (p_cs_definition_id is null OR p_column_identifier is null) then
	l_ret := null;
    else

      open c;
      fetch c into l_ret;
      close c;

    end if;

    return l_ret;
End;


End;

/
