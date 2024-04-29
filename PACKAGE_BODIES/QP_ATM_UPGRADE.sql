--------------------------------------------------------
--  DDL for Package Body QP_ATM_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_ATM_UPGRADE" AS
/* $Header: QPATMUPB.pls 120.2 2006/05/23 20:03:32 gtippire noship $ */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_ATM_UPGRADE';
--
--  moved to spec
/*CURSOR attribute_sourcing_cur (p_prc_context_code in varchar2,
                               p_segment_mapping_column in varchar2,
                               p_application_short_name in varchar2) is
  SELECT d.*
  FROM  oe_def_attr_condns b,
        ak_object_attributes a,
        oe_def_condn_elems c,
        oe_def_condn_elems c1,
        oe_def_attr_def_rules d
  WHERE substr(c.value_string,1,30) = p_prc_context_code and
        b.attribute_code = p_segment_mapping_column and
        substr(c1.value_string,1,30) = p_application_short_name and
        b.attr_def_condition_id = d.attr_def_condition_id and
        b.database_object_name = a.database_object_name and
        b.database_object_name = d.database_object_name and
        b.attribute_code = a.attribute_code and
        b.attribute_code = d.attribute_code and
        c.condition_id = b.condition_id and
        c1.condition_id = b.condition_id and
        c.attribute_code like '%CONTEXT%' and
        c1.attribute_code = 'SRC_SYSTEM_CODE' and
        a.attribute_application_id = 661 and
        nvl(b.enabled_flag,'Y') = 'Y';
*/
--
PROCEDURE p_upd_bad_upg_seed_data IS
--Private function to update bad seed data created from 10.7 to 11i upgrade.
BEGIN

  UPDATE oe_def_attr_condns
  SET enabled_flag = 'N'
  WHERE
  Condition_id IN (
             SELECT  C.condition_id
             FROM
               oe_def_attr_condns  C,
               oe_def_conditions_vl CT
             WHERE
               C.condition_id = CT.condition_id  AND
               C. database_object_name IN (
               'QP_HDR_QUALIF_ATTRIBS_V',
               'QP_LINE_PRICING_ATTRIBS_V',
               'QP_LINE_QUALIF_ATTRIBS_V' ) AND
               CT.display_name like 'ONT%'  AND
               C.condition_id > 1000        AND
               C.system_flag= 'Y'           AND
               1< (SELECT count(*) FROM  oe_def_conditions_vl CTS,
               oe_def_attr_condns  CS
               WHERE
               CTS.display_name = CT.display_name
               AND CTS.condition_id = CS.condition_id
               AND  CS.attribute_code = C.attribute_code  )
                );

  EXCEPTION

    WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          OE_MSG_PUB.Add_Exc_Msg
          (  G_PKG_NAME,
             'p_upd_bad_upg_seed_data');
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END p_upd_bad_upg_seed_data;


--
FUNCTION p_get_pte_for_rqt(p_request_type_code in varchar2) return varchar2 is
--Private function to get pte_code for a Request type.
  l_pte_code    varchar2(30);
begin
  select pte_code
  into l_pte_code
  from qp_pte_request_types_b
  where request_type_code = p_request_type_code and
        rownum = 1;
  return (l_pte_code);
exception
  when no_data_found then
    return('-1');
  when others then
    return('-2');
end;
--

FUNCTION p_ssc_exists(p_application_short_name in varchar2,
                      p_pte_code in varchar2) return number is
-- Private function to check if Source System Exists in QP_PTE_SOURCE_SYSTEMS table
-- for a given PTE.
  dummy   varchar2(1);
begin
  select 'x'
  into dummy
  from qp_pte_source_systems
  where application_short_name = p_application_short_name and
        pte_code = p_pte_code and
        rownum = 1;
  return(0);
exception
  when no_data_found then
    return(-1);
  when others then
    return(-2);
end;
--
FUNCTION p_req_exists(p_request_type_code in varchar2) return number is
--Private function to check if given Request Type Exists in QP_PTE_REQUEST_TYPES_B table.
  dummy   varchar2(1);
begin
  select 'x'
  into dummy
  from qp_pte_request_types_b
  where request_type_code = p_request_type_code and
        rownum = 1;
  return(0);
exception
  when no_data_found then
    return(-1);
  when others then
    return(-2);
end;
--
FUNCTION p_psg_exists(p_segment_id in number,p_pte_code in varchar2)
return number is
--Private function to check if given Segment and PTE exist in QP_PTE_SEGMENTS table.
  dummy   varchar2(1);
begin
  select 'x'
  into dummy
  from qp_pte_segments
  where pte_code = p_pte_code and
        segment_id = p_segment_id and
        rownum = 1;
  return(0);
exception
  when no_data_found then
    return(-1);
  when others then
    return(-2);
end;
--
FUNCTION p_sourcing_exists(p_segment_id in number,
                           p_request_type_code in varchar2,
                           p_attribute_sourcing_level in varchar2)
return number is
--Private function to check if given Segment,Request Type exist in QP_ATTRIBUTE_SOURCING table.
  dummy   varchar2(1);
begin
  select 'x'
  into dummy
  from qp_attribute_sourcing
  where segment_id = p_segment_id and
        request_type_code = p_request_type_code and
        attribute_sourcing_level = p_attribute_sourcing_level and
        rownum = 1;
  return(0);
exception
  when no_data_found then
    return(-1);
  when others then
    return(-2);
end;
--
FUNCTION p_con_exists (p_prc_context_code in varchar2,
                       p_flexfield_name in varchar2,
                       x_prc_context_id out NOCOPY /* file.sql.39 change */ number)
--Private function to check if Context code exists in QP_PRC_CONTEXTS_B table.
return number is
  l_prc_context_id   number(15);
begin
  select prc_context_id
  into l_prc_context_id
  from qp_prc_contexts_b
  where prc_context_code = p_prc_context_code and
        ((p_flexfield_name = 'QP_ATTR_DEFNS_QUALIFIER' and prc_context_type = 'QUALIFIER') or
         (p_flexfield_name <> 'QP_ATTR_DEFNS_QUALIFIER' and prc_context_type <> 'QUALIFIER')) and
        rownum = 1;
  x_prc_context_id := l_prc_context_id;
  return(0);
exception
  when no_data_found then
    return(-1);
  when others then
    return(-2);
end;
--
FUNCTION p_seg_exists (p_prc_context_code in varchar2,
                       p_flexfield_name in varchar2,
                       p_segment_code in varchar2,
                       p_segment_mapping_column in varchar2)
--Private function to check if Segment code exists in QP_SEGMENTS_B table.
return number is
  dummy   varchar2(1);
begin
  select 'x'
  into dummy
  from qp_segments_b a,qp_prc_contexts_b b
  where a.prc_context_id = b.prc_context_id and
        b.prc_context_code = p_prc_context_code and
        (a.segment_code = p_segment_code or a.segment_mapping_column = p_segment_mapping_column) and
        ((p_flexfield_name = 'QP_ATTR_DEFNS_QUALIFIER' and b.prc_context_type = 'QUALIFIER') or
         (p_flexfield_name <> 'QP_ATTR_DEFNS_QUALIFIER' and b.prc_context_type <> 'QUALIFIER')) and
        rownum = 1;
  return(0);
exception
  when no_data_found then
    return(-1);
  when others then
    return(-2);
end;
--
FUNCTION p_seg_src_def_exists (p_prc_context_code in varchar2,
                               p_segment_mapping_column in varchar2)
--Private function to check if an attribute was meant to be sourced in old system.
return number is
  dummy   varchar2(1);
begin
  SELECT 'x'
  INTO  dummy
  FROM  oe_def_attr_condns b,
        ak_object_attributes oa,
        oe_def_condn_elems c1,
        oe_def_condn_elems c2
  WHERE c1.value_string = p_prc_context_code and
        b.attribute_code = p_segment_mapping_column and
        b.database_object_name = oa.database_object_name and
        b.attribute_code = oa.attribute_code and
        c1.condition_id = b.condition_id and
        c1.attribute_code like '%CONTEXT%' and
        c2.condition_id = b.condition_id and
        c2.attribute_code =  'SRC_SYSTEM_CODE' and
        --c2.value_string = 'QP' and
        oa.attribute_application_id = 661 and
        /* commented out as enabled_flag is also upgraded now */
        --nvl(b.enabled_flag,'Y') = 'Y' and,
        rownum = 1;
  return(0);
exception
  when no_data_found then
    return(-1);
  when others then
    return(-2);
end;
--
FUNCTION p_get_level (p_prc_context_code in varchar2,
                      p_segment_mapping_column in varchar2)
-- Private function to get segment level.
return varchar2 is
  l_segment_level    varchar2(10);
  l_count            number;
  dummy              varchar2(1);
begin
  l_count := 0;
  begin
    SELECT 'x'
    INTO dummy
    FROM  oe_def_attr_condns b,
          ak_object_attributes oa,
          oe_def_condn_elems c1
    WHERE c1.value_string = p_prc_context_code and
          b.attribute_code = p_segment_mapping_column and
          b.database_object_name = oa.database_object_name and
          b.attribute_code = oa.attribute_code and
          c1.condition_id = b.condition_id and
          c1.attribute_code like '%CONTEXT%' and
          oa.attribute_application_id = 661 and
          (b.database_object_name like '%HEADER%' or
           b.database_object_name like '%HDR%') and
        /* commented out as enabled_flag is also upgraded now */
         -- nvl(b.enabled_flag,'Y') = 'Y' and
          rownum = 1;
    l_count := l_count + 1;
    l_segment_level := 'ORDER';
  exception
    when no_data_found then
      null;
  end;
  --
  begin
    SELECT 'x'
    INTO dummy
    FROM  oe_def_attr_condns b,
          ak_object_attributes oa,
          oe_def_condn_elems c1
    WHERE c1.value_string = p_prc_context_code and
          b.attribute_code = p_segment_mapping_column and
          b.database_object_name = oa.database_object_name and
          b.attribute_code = oa.attribute_code and
          c1.condition_id = b.condition_id and
          c1.attribute_code like '%CONTEXT%' and
          oa.attribute_application_id = 661 and
          b.database_object_name like '%LINE%' and
        /* commented out as enabled_flag is also upgraded now */
        --  nvl(b.enabled_flag,'Y') = 'Y' and
          rownum = 1;
    l_segment_level := 'LINE';
    l_count := l_count + 1;
    --
    if l_count = 2 then
      l_segment_level := 'BOTH';
    end if;
    --
  exception
    when no_data_found then
      l_segment_level := 'UNEXPECTED';
  end;
  return(l_segment_level);
exception
  when no_data_found then
    return(-1);
end;
--
FUNCTION p_pte_code_exists (p_segment_id in number)
--Private function to check, if pte_code 'ONT' exists, for a given segment_id.
return number is
  dummy   varchar2(1);
begin
  select 'x'
  into dummy
  from qp_pte_segments
  where segment_id = p_segment_id and
        pte_code = 'ONT' and
        rownum = 1;
  return(0);
exception
  when no_data_found then
    return(-1);
end;
--
FUNCTION p_get_format_type (p_value_set_id in number)
--Private function to get Format type for a given value set.
return varchar2 is
  l_format_type   varchar2(1);
begin
  select format_type
  into l_format_type
  from fnd_flex_value_sets
  where flex_value_set_id = p_value_set_id and
        rownum = 1;
  return(l_format_type);
exception
  when no_data_found then
    return(null);
end;
--
PROCEDURE p_insert_lookup_code (p_lookup_type in varchar2,
                                p_lookup_code in varchar2) is
-- Private procedure to insert new PTEs and Request Types.
  l_row_id      varchar2(25);
  l_meaning     varchar2(80);
begin
   if p_lookup_type = 'REQUEST_TYPE' then
      l_meaning := p_lookup_code|| '(New)';
   elsif p_lookup_type = 'QP_PTE_TYPE' then
      l_meaning := 'Unassigned-'|| g_pte_num;
   end if;
   --
   FND_LOOKUP_VALUES_PKG.INSERT_ROW(
    X_ROWID                => l_row_id,
    X_LOOKUP_TYPE          => p_lookup_type,
    X_SECURITY_GROUP_ID    => 0,
    X_VIEW_APPLICATION_ID  => 661,
    X_LOOKUP_CODE          => p_lookup_code,
    X_TAG                  => null,
    X_ATTRIBUTE_CATEGORY   => null,
    X_ATTRIBUTE1           => null,
    X_ATTRIBUTE2           => null,
    X_ATTRIBUTE3           => null,
    X_ATTRIBUTE4           => null,
    X_ENABLED_FLAG         => 'Y',
    X_START_DATE_ACTIVE    => sysdate,
    X_END_DATE_ACTIVE      => null,
    X_TERRITORY_CODE       => null,
    X_ATTRIBUTE5           => null,
    X_ATTRIBUTE6           => null,
    X_ATTRIBUTE7           => null,
    X_ATTRIBUTE8           => null,
    X_ATTRIBUTE9           => null,
    X_ATTRIBUTE10          => null,
    X_ATTRIBUTE11          => null,
    X_ATTRIBUTE12          => null,
    X_ATTRIBUTE13          => null,
    X_ATTRIBUTE14          => null,
    X_ATTRIBUTE15          => null,
    X_MEANING              => l_meaning,
    X_DESCRIPTION          => l_meaning,
    X_CREATION_DATE        => sysdate,
    X_CREATED_BY           => 1,
    X_LAST_UPDATE_DATE     => sysdate,
    X_LAST_UPDATED_BY      => 1,
    X_LAST_UPDATE_LOGIN    => null);
end;
--
PROCEDURE p_insert_context_b (p_flexfield_name in varchar2) is
-- Private procedure to insert Contexts in QP_PRC_CONTEXTS_B.
begin
    g_context_seqno := g_context_seqno + 1;
    INSERT into QP_PRC_CONTEXTS_B
      (PRC_CONTEXT_ID,
       PRC_CONTEXT_CODE,
       PRC_CONTEXT_TYPE,
       SEEDED_FLAG,
       ENABLED_FLAG,
       CONTEXT,
       ATTRIBUTE1,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE) values
      (g_context_seqno,
       g_context_b_rec.descriptive_flex_context_code,
       decode(p_flexfield_name,'QP_ATTR_DEFNS_QUALIFIER','QUALIFIER',
              decode(g_context_b_rec.descriptive_flex_context_code,'ITEM','PRODUCT','PRICING_ATTRIBUTE')),
       decode(g_context_b_rec.created_by,1,'Y','N'),
       g_context_b_rec.enabled_flag,
       null,null,null,null,null,null,null,null,
       null,null,null,null,null,null,null,null,
       g_context_b_rec.created_by,
       g_context_b_rec.creation_date,
       g_context_b_rec.last_updated_by,
       g_context_b_rec.last_update_date,
       g_context_b_rec.last_update_login,
       null,null,null);
end;
--
PROCEDURE p_insert_context_tl is
-- Private procedure to insert Contexts in QP_PRC_CONTEXTS_TL.
begin
   INSERT into QP_PRC_CONTEXTS_TL
     (PRC_CONTEXT_ID,
      LANGUAGE,
      SOURCE_LANG,
      SEEDED_PRC_CONTEXT_NAME,
      USER_PRC_CONTEXT_NAME,
      SEEDED_DESCRIPTION,
      USER_DESCRIPTION,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN ) values
     (g_context_seqno,
      g_context_tl_rec.language,
      g_context_tl_rec.source_lang,
      g_context_tl_rec.descriptive_flex_context_name,
      g_context_tl_rec.descriptive_flex_context_name,
      g_context_tl_rec.description,
      nvl(g_context_tl_rec.description,'** No description found **'),
      g_context_tl_rec.created_by,
      g_context_tl_rec.creation_date,
      g_context_tl_rec.last_updated_by,
      g_context_tl_rec.last_update_date,
      g_context_tl_rec.last_update_login);
end;
--
PROCEDURE p_insert_segment_b (p_prc_context_id in number,
                              p_valueset_id in number,
                              p_format_type in varchar2) is
-- Private procedure to insert Segments in QP_SEGMENTS_B.
begin
      g_segment_seqno := g_segment_seqno + 1;
      INSERT into QP_SEGMENTS_B
         (SEGMENT_ID,
          SEGMENT_CODE,
          PRC_CONTEXT_ID,
          AVAILABILITY_IN_BASIC,
          APPLICATION_ID,
          SEGMENT_MAPPING_COLUMN,
          SEEDED_FLAG,
	  REQUIRED_FLAG,
          SEEDED_PRECEDENCE,
          USER_PRECEDENCE,
          SEEDED_VALUESET_ID,
          USER_VALUESET_ID,
          SEEDED_FORMAT_TYPE,
          USER_FORMAT_TYPE,
          CONTEXT,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE) values
         (g_segment_seqno,
          g_segment_b_rec.end_user_column_name,
          p_prc_context_id,
          decode(qp_util.get_qp_status,'S','Y','N'),
          661,
          g_segment_b_rec.application_column_name,
          decode(g_segment_b_rec.created_by,1,'Y','N'),
	  g_segment_b_rec.required_flag,
          g_segment_b_rec.column_seq_num,
          g_segment_b_rec.column_seq_num,
          p_valueset_id,
          p_valueset_id,
          p_format_type,
          p_format_type,
          null,null,null,null,null,null,null,null,
          null,null,null,null,null,null,null,null,
          g_segment_b_rec.created_by,
          g_segment_b_rec.creation_date,
          g_segment_b_rec.last_updated_by,
          g_segment_b_rec.last_update_date,
          g_segment_b_rec.last_update_login,
          null,null,null);
end;
--
PROCEDURE p_insert_segment_tl is
-- Private procedure to insert Segments in QP_SEGMENTS_TL.
begin
   INSERT into QP_SEGMENTS_TL
     (SEGMENT_ID,
      LANGUAGE,
      SOURCE_LANG,
      SEEDED_SEGMENT_NAME,
      USER_SEGMENT_NAME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN ) values
     (g_segment_seqno,
      g_segment_tl_rec.language,
      g_segment_tl_rec.source_lang,
      g_segment_tl_rec.form_left_prompt,
      g_segment_tl_rec.form_left_prompt,
      g_segment_tl_rec.created_by,
      g_segment_tl_rec.creation_date,
      g_segment_tl_rec.last_updated_by,
      g_segment_tl_rec.last_update_date,
      g_segment_tl_rec.last_update_login);
end;
--
PROCEDURE p_insert_ssc (p_source_system_code in varchar2,
                        p_pte_code in varchar2) is
-- Private procedure to insert Source Systems.
begin
   g_ssc_seqno := g_ssc_seqno + 1;
   INSERT into QP_PTE_SOURCE_SYSTEMS
           (PTE_SOURCE_SYSTEM_ID,
            PTE_CODE,
            APPLICATION_SHORT_NAME,
            ENABLED_FLAG,
            CONTEXT,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE) values
           (g_ssc_seqno,
            p_pte_code,
            p_source_system_code,
            'Y',
            null,null,null,null,
            null,null,null,null,
            null,null,null,null,
            null,null,null,null,
            1,
            sysdate,
            1,
            sysdate,
            null,
            null,null,null);
end;
--
PROCEDURE p_insert_rqt (p_request_type_code in varchar2,
                        p_pte_code in varchar2) is
-- Private procedure to insert Request Types in QP_PTE_REQUEST_TYPES_B/TL tables.
  l_order_level_global_struct   varchar2(80);
  l_line_level_global_struct    varchar2(80);
begin
   if p_request_type_code = 'ASO' then
     l_order_level_global_struct := 'ASO_PRICING_INT.G_HEADER_REC';
     l_line_level_global_struct := 'ASO_PRICING_INT.G_LINE_REC';
   elsif p_request_type_code = 'OKC' then
     l_order_level_global_struct := 'OKC_PRICE_PUB.G_CONTRACT_INFO';
     l_line_level_global_struct := 'OKC_PRICE_PUB.G_CONTRACT_INFO';
   elsif p_request_type_code = 'INV' then
     l_order_level_global_struct := 'INV_IC_ORDER_PUB.G_HDR';
     l_line_level_global_struct := 'INV_IC_ORDER_PUB.G_LINE';
   elsif p_request_type_code = 'ONT' then
     l_order_level_global_struct := 'OE_ORDER_PUB.G_HDR';
     l_line_level_global_struct := 'OE_ORDER_PUB.G_LINE';
   else
     l_order_level_global_struct := null;
     l_line_level_global_struct := null;
   end if;
   --
   INSERT into QP_PTE_REQUEST_TYPES_B
         (REQUEST_TYPE_CODE,
          PTE_CODE,
          ORDER_LEVEL_GLOBAL_STRUCT,
          LINE_LEVEL_GLOBAL_STRUCT,
          ORDER_LEVEL_VIEW_NAME,
          LINE_LEVEL_VIEW_NAME,
          ENABLED_FLAG,
          CONTEXT,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE) values
         (p_request_type_code,
          p_pte_code,
          l_order_level_global_struct,
          l_line_level_global_struct,
          null,
          null,
          'Y',
          null,null,null,null,
          null,null,null,null,
          null,null,null,null,
          null,null,null,null,
          1,
          sysdate,
          1,
          sysdate,
          null,
          null,null,null);
          --
       INSERT into QP_PTE_REQUEST_TYPES_TL
         (REQUEST_TYPE_CODE,
          LANGUAGE,
          SOURCE_LANG,
          REQUEST_TYPE_DESC,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN)
            select p_request_type_code,
                   language,
                   source_lang,
                   nvl(description,meaning),
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login
            from fnd_lookup_values
            where lookup_type = 'REQUEST_TYPE' and
                  lookup_code = p_request_type_code;
            --
end;
--
PROCEDURE p_insert_pte_segments (p_segment_id      in number,
                                 p_pte_code        in varchar2,
                                 p_segment_level   in varchar2,
                                 p_sourcing_method in varchar2,
                                 p_sourcing_enabled in varchar2) is
-- Private procedure to insert PTE-Segments in qp_pte_segments.
begin
   g_psg_seqno := g_psg_seqno + 1;
   INSERT into QP_PTE_SEGMENTS
           (SEGMENT_PTE_ID,
            SEGMENT_ID,
            PTE_CODE,
            SEGMENT_LEVEL,
            SOURCING_ENABLED,
            SEEDED_SOURCING_METHOD,
            USER_SOURCING_METHOD,
            SOURCING_STATUS,
            LOV_ENABLED,
            LIMITS_ENABLED,
            CONTEXT,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE) values
           (g_psg_seqno,
            p_segment_id,
            p_pte_code,
            p_segment_level,
            p_sourcing_enabled,
            p_sourcing_method,
            p_sourcing_method,
            'N',
            'Y',
            'Y',
            null,null,null,null,
            null,null,null,null,
            null,null,null,null,
            null,null,null,null,
            1, -- fnd_profile.value('USER_ID')
            sysdate,
            1,
            sysdate,
            null,
            null,null,null);
end;
--
PROCEDURE p_insert_sourcing( p_request_type_code in varchar2,
                             p_attribute_sourcing_level in varchar2,
                             p_value_string in varchar2,
			     p_enabled_flag in varchar2) is
-- Private procedure to insert Sourcing rules in QP_ATTRIBUTE_SOURCING.
begin
    g_source_seqno := g_source_seqno + 1;
    INSERT into QP_ATTRIBUTE_SOURCING
      (ATTRIBUTE_SOURCING_ID,
       SEGMENT_ID,
       REQUEST_TYPE_CODE,
       ATTRIBUTE_SOURCING_LEVEL,
       APPLICATION_ID,
       SEEDED_SOURCING_TYPE,
       USER_SOURCING_TYPE,
       SEEDED_VALUE_STRING,
       USER_VALUE_STRING,
       SEEDED_FLAG,
       ENABLED_FLAG,
       CONTEXT,
       ATTRIBUTE1,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE) values
      (g_source_seqno,
       g_all_seg_rec.segment_id,
       p_request_type_code,
       p_attribute_sourcing_level,
       661,
       g_sourcing_rec.src_type,
       g_sourcing_rec.src_type,
       p_value_string,
       p_value_string,
       decode(g_sourcing_rec.created_by,1,'Y','N'),
       p_enabled_flag, --'Y', upgrade enabled_flag also
       null,null,null,null,null,null,null,null,
       null,null,null,null,null,null,null,null,
       g_sourcing_rec.created_by,
       g_sourcing_rec.creation_date,
       g_sourcing_rec.last_updated_by,
       g_sourcing_rec.last_update_date,
       g_sourcing_rec.last_update_login,
       null,null,null);
end;
--
/*
FUNCTION p_mapping_rule_exists (p_prc_context_code in varchar2,
                                p_segment_mapping_column in varchar2,
                                p_application_short_name in varchar2)
-- Private procedure to find out if Attribute Mapping exists.
return number is
  l_sourcing_rec    g_sourcing_rec%rowtype;
  l_i               number := 0;
begin
  open attribute_sourcing_cur(p_prc_context_code,
                              p_segment_mapping_column,
                              p_application_short_name);
    fetch attribute_sourcing_cur into l_sourcing_rec;
    if attribute_sourcing_cur%notfound then
       l_i := -1;
    end if;
  close attribute_sourcing_cur;
  return(l_i);
end;
*/
--
PROCEDURE p_delete_PTE_attribute_links is
-- Private procedure to delete certain unwanted PTE_Attribute Links.
-- Private procedure to find out if Attribute Mapping exists.
begin
/*
  --
  -- 1. For LOGISTICS context and PTEs other than 'Logistics',
  --
  delete from qp_pte_segments a
  where a.pte_code <> 'LOGSTX' and
        exists ( select 'x'
                 from qp_segments_b b,
                      qp_prc_contexts_b c
                 where b.prc_context_id = c.prc_context_id and
                       b.segment_id = a.segment_id and
                       c.prc_context_code = 'LOGISTICS') and
        a.created_by = 1;
  --
  -- 2. COUPON_NO attribute and 'Logistics' PTE
  --
  delete from qp_pte_segments a
  where a.pte_code = 'LOGSTX' and
        exists ( select 'x'
                 from qp_segments_b b
                 where b.segment_id = a.segment_id and
                       b.segment_code = 'COUPON_NO') and
        a.created_by = 1;
  --
  -- 3. 'Number of Students' attribute and PTEs other than 'Order Fulfillment'.
  --
  delete from qp_pte_segments a
  where a.pte_code <> 'ORDFUL' and
        exists ( select 'x'
                 from qp_segments_b b
                 where b.segment_id = a.segment_id and
                       b.segment_code = 'Number of students') and
        a.created_by = 1;
*/
  --
  -- 4. Links having Attribute Mapping Method as ATTRIBUTE MAPPING
  --    and PTE as INTCOM without any Attribute Mapping rules.
  --
  delete from qp_pte_segments a
  where a.pte_code = 'INTCOM' and
        a.seeded_sourcing_method = 'ATTRIBUTE MAPPING' and
        not exists ( select 'x'
                     from qp_attribute_sourcing b,
                          qp_pte_request_types_b c
                     where b.segment_id = a.segment_id and
                           b.request_type_code = c.request_type_code and
                           a.pte_code = c.pte_code) and
        a.created_by = 1;
  --
  -- 5. Links having Attribute Mapping Method as ATTRIBUTE MAPPING
  --    and PTE as DEMAND without any Attribute Mapping rules.
  --
  delete from qp_pte_segments a
  where a.pte_code = 'DEMAND' and
        a.seeded_sourcing_method = 'ATTRIBUTE MAPPING' and
        not exists ( select 'x'
                     from qp_attribute_sourcing b,
                          qp_pte_request_types_b c
                     where b.segment_id = a.segment_id and
                           b.request_type_code = c.request_type_code and
                           a.pte_code = c.pte_code) and
        a.created_by = 1;
end;
--
PROCEDURE p_detect_dup_mapping_cols(p_prc_context_id in number,
                                    p_segment_mapping_column in varchar2,
                                    p_segment_code in varchar2) is
   l_segment_id    number;
   l_segment_code  varchar2(30);
begin
  select a.segment_id,
         a.segment_code
  into l_segment_id,
       l_segment_code
  from qp_segments_b a, qp_prc_contexts_b b
  where a.prc_context_id = b.prc_context_id and
        a.prc_context_id = p_prc_context_id and
        segment_mapping_column = p_segment_mapping_column and
        segment_code <> p_segment_code and
        rownum = 1;
  --
  insert into qp_upgrade_errors
    (creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     error_type,
     error_desc,
     error_module) values
    (sysdate,
     fnd_global.user_id,
     sysdate,
     fnd_global.user_id,
     'ATTRIBUTE_MANAGER_DATA_UPGRADE',
     substr('A new attribute '|| l_segment_code ||
     ' mapped to '|| g_segment_b_rec.application_column_name ||
     ' already exists. Add this Attribute and it''s PTE-Links and AM Rules manually.'||
     ' Refer to the Pricing Implementation Guide for details.',1,200),
     'Attribute Manager');
  --
  delete from qp_segments_tl where segment_id = l_segment_id;
  delete from qp_segments_b where segment_id = l_segment_id;
exception
  when no_data_found then
    null;
end;
--
PROCEDURE p_initialize_sequences is
begin
  select nvl(max(prc_context_id),100)
  into g_context_seqno
  from qp_prc_contexts_b
  where prc_context_id < 100000;
  --
  select nvl(max(segment_id),100)
  into g_segment_seqno
  from qp_segments_b
  where segment_id < 100000;
  --
  select nvl(max(pte_source_system_id),100)
  into g_ssc_seqno
  from qp_pte_source_systems
  where pte_source_system_id < 100000;
  --
  select nvl(max(segment_pte_id),100)
  into g_psg_seqno
  from qp_pte_segments
  where segment_pte_id < 100000;
  --
  select nvl(max(attribute_sourcing_id),100)
  into g_source_seqno
  from qp_attribute_sourcing
  where attribute_sourcing_id < 100000;
end;
--
PROCEDURE upgrade_atm is
  CURSOR context_b_cur (p_flexfield_name in varchar2) is
    SELECT *
    FROM fnd_descr_flex_contexts
    WHERE application_id = 661
    AND descriptive_flexfield_name = p_flexfield_name
    ORDER BY descriptive_flex_context_code;
  --
  CURSOR context_tl_cur (p_flexfield_name in varchar2,
                         p_context_code in varchar2) is
    SELECT *
    FROM fnd_descr_flex_contexts_tl
    WHERE application_id = 661
    AND descriptive_flexfield_name = p_flexfield_name
    AND descriptive_flex_context_code = p_context_code;
  --
  CURSOR segment_b_cur (p_flexfield_name in varchar2,
                        p_context_code in varchar2) is
    SELECT *
    FROM fnd_descr_flex_column_usages
    WHERE application_id = 661
    AND descriptive_flexfield_name = p_flexfield_name
    AND descriptive_flex_context_code = p_context_code
    ORDER BY end_user_column_name;
  --
  CURSOR segment_tl_cur (p_flexfield_name in varchar2,
                         p_context_code in varchar2,
                         p_segment_code in varchar2) is
    SELECT *
    FROM fnd_descr_flex_col_usage_tl
    WHERE application_id = 661
    AND descriptive_flexfield_name = p_flexfield_name
    AND descriptive_flex_context_code = p_context_code
    AND application_column_name = p_segment_code;
  --
  CURSOR req_ssc_cur is
    SELECT request_type_code,
           source_system_code
    FROM qp_price_req_sources
    UNION
    SELECT 'ONT','AMS'
    FROM dual
    UNION
    SELECT 'ONT','QP'
    FROM dual
    UNION
    SELECT 'MSD','QP'
    FROM dual
    /*
    UNION
    SELECT 'KEN','KQM'
    FROM dual
    */
    UNION
    SELECT 'FTE','FTE'
    FROM dual;
  --
  CURSOR pte_cur is
    SELECT *
    FROM qp_lookups
    WHERE lookup_type = 'QP_PTE_TYPE';
  --
  CURSOR get_pte_cur (p_application_short_name in varchar2)is
    SELECT pte_code
    FROM   qp_pte_source_systems
    WHERE  application_short_name = p_application_short_name;
  --
  CURSOR all_segments_cur is
    SELECT b.prc_context_code,
           a.*
    FROM   qp_segments_b a,
           qp_prc_contexts_b b
    WHERE  b.prc_context_id = a.prc_context_id;
  --
  CURSOR pte_seg_cur (p_prc_context_code in varchar2,
                      p_segment_mapping_column in varchar2) is
    SELECT substr(c1.value_string,1,30) application_short_name
    FROM  oe_def_attr_condns b,
          ak_object_attributes a,
          oe_def_condn_elems c,
          oe_def_condn_elems c1
    WHERE substr(c.value_string,1,30) = p_prc_context_code and
          b.attribute_code = p_segment_mapping_column and
          b.database_object_name = a.database_object_name and
          b.attribute_code = a.attribute_code and
          c.condition_id = b.condition_id and
          c.attribute_code like '%CONTEXT%' and
          c1.condition_id = b.condition_id and
          c1.attribute_code = 'SRC_SYSTEM_CODE' and
          a.attribute_application_id = 661
        /* commented out as enabled_flag is also upgraded now */
        --  nvl(b.enabled_flag,'Y') = 'Y'
    GROUP BY substr(c1.value_string,1,30),
             substr(c.value_string,1,30),
             b.attribute_code;
  --
  CURSOR assign_pte_cur is
    select a.list_header_id,b.pte_code
    from qp_list_headers_b a,qp_pte_source_systems b
    where nvl(a.source_system_code,'x') = b.application_short_name
    order by decode(b.pte_code,'ORDFUL',2,1);
  --
  l_segment_level             varchar2(10);
  l_request_type_code         varchar2(30);
  l_flexfield_name            varchar2(30);
  l_format_type               varchar2(1);
  l_pte_code                  varchar2(30);
  l_application_short_name    varchar2(30);
  l_value_string              varchar2(2000);
  l_attribute_sourcing_level  varchar2(30);
  l_list_header_id            number;
  l_prc_context_id            number;
  dummy                       varchar2(1);
  x_prc_context_id            number;
  --
  retval                      number;
  segval                      number;
  atm_serious_problem         EXCEPTION;
  --
BEGIN
  --dbms_output.enable(1000000);
  -- Initialize sequences.
  p_initialize_sequences;
  --
  FOR flexno in 1..2 loop
    if flexno = 1 then
       l_flexfield_name := 'QP_ATTR_DEFNS_QUALIFIER';
    elsif flexno = 2 then
       l_flexfield_name := 'QP_ATTR_DEFNS_PRICING';
    end if;
    --
  open context_b_cur(l_flexfield_name);
  -- Copy all Contexts from 'Qualifier Contexts' and Pricing Contexts'.
  loop
     fetch context_b_cur INTO g_context_b_rec;
     exit when context_b_cur%notfound;
     --
     retval := p_con_exists(g_context_b_rec.descriptive_flex_context_code,
                            l_flexfield_name,
                            x_prc_context_id);
     if retval in (0,-1) then
       if retval = -1 then
         p_insert_context_b (l_flexfield_name);
         --
         open context_tl_cur(l_flexfield_name,g_context_b_rec.descriptive_flex_context_code);
         loop
           fetch context_tl_cur INTO g_context_tl_rec;
           exit when context_tl_cur%notfound;
           --
           p_insert_context_tl;
           --
         end loop;
         close context_tl_cur;
       end if;
       --
       -- Opening Segments Cursor
       --
       open segment_b_cur(l_flexfield_name,g_context_b_rec.descriptive_flex_context_code);
       loop
         fetch segment_b_cur INTO g_segment_b_rec;
         exit when segment_b_cur%notfound;
         --
         --l_valueset_id := nvl(g_segment_b_rec.flex_value_set_id,102189);
         l_format_type := p_get_format_type (g_segment_b_rec.flex_value_set_id);
         --
         segval := p_seg_exists(g_context_b_rec.descriptive_flex_context_code,
                                l_flexfield_name,
                                g_segment_b_rec.end_user_column_name,
                                g_segment_b_rec.application_column_name);
         if segval = -1 then
           if retval = 0 then
             p_insert_segment_b (x_prc_context_id,g_segment_b_rec.flex_value_set_id, l_format_type);
             l_prc_context_id := x_prc_context_id;
           elsif retval = -1 then
             p_insert_segment_b (g_context_seqno,g_segment_b_rec.flex_value_set_id, l_format_type);
             l_prc_context_id := g_context_seqno;
           end if;
           --
           open segment_tl_cur( l_flexfield_name,
                                g_context_b_rec.descriptive_flex_context_code,
                                g_segment_b_rec.application_column_name);
           loop
             fetch segment_tl_cur INTO g_segment_tl_rec;
             exit when segment_tl_cur%notfound;
             p_insert_segment_tl;
           end loop;
           close segment_tl_cur;
           --
           p_detect_dup_mapping_cols(l_prc_context_id,
                                     g_segment_b_rec.application_column_name,
                                     g_segment_b_rec.end_user_column_name);
           --
         elsif segval = -2 then
           raise atm_serious_problem;
         end if;
         --
       end loop;
       close segment_b_cur;
       --
     elsif retval = -2 then
       raise atm_serious_problem;
     end if;
     ---
  end loop;
  close context_b_cur;
  END loop;
  --
  --   Creating PTEs and copying Request Types and Source System Codes
  --   Creating Sourcing Rules
  --
  open req_ssc_cur;
  --
  -- This Cusror is the new seeded data of Source Systems-Request Types for the new system.
  --
  loop
     fetch req_ssc_cur INTO g_req_ssc_rec;
     exit when req_ssc_cur%notfound;
     --
     retval := p_req_exists(g_req_ssc_rec.request_type_code);
     if retval = 0 then
     --
     -- If Request Type exists in New System, get the PTE to which it is attached.
     -- If the PTE does not have the Source System, add the source system
     --
       l_pte_code := p_get_pte_for_rqt(g_req_ssc_rec.request_type_code);
       --
       if p_ssc_exists(g_req_ssc_rec.source_system_code, l_pte_code) = -1 then
          p_insert_ssc(g_req_ssc_rec.source_system_code,l_pte_code);
       end if;
     elsif retval = -1 then
       --
       -- If Request Type does not exist in New System,
       -- Follow a pre-determined way of associating the Request Type to PTEs as shown below.
       --
       if g_req_ssc_rec.request_type_code in ('ONT','ASO','OKC') then
         l_pte_code := 'ORDFUL';
       elsif g_req_ssc_rec.request_type_code = 'IC' then
         l_pte_code := 'INTCOM';
       elsif g_req_ssc_rec.request_type_code = 'MSD' then
         l_pte_code := 'DEMAND';
       elsif g_req_ssc_rec.request_type_code = 'FTE' then
         l_pte_code := 'LOGSTX';
       else
         g_pte_num := g_pte_num + 1;
         --
         -- If Request Type is not a seeded Request type, create a brand new PTE for it.
         --
         l_pte_code := g_req_ssc_rec.request_type_code||'_PTE';
         p_insert_lookup_code('QP_PTE_TYPE',l_pte_code);
       end if;
       --
       -- Insert the new and Unseeded Request Types into lookups and Attribute Mapping tables,
       -- with the PTEs as determined above.
       --
       p_insert_lookup_code('REQUEST_TYPE',g_req_ssc_rec.request_type_code);
       p_insert_rqt (g_req_ssc_rec.request_type_code,l_pte_code);
       --
       -- Insert into qp_pte_source_systems, source systems and their corresponding PTEs
       --
       if p_ssc_exists(g_req_ssc_rec.source_system_code,l_pte_code) = -1 then
          p_insert_ssc(g_req_ssc_rec.source_system_code,l_pte_code);
       end if;
       --
     elsif retval = -2 then
       raise atm_serious_problem;
     end if;
  end loop;
  close req_ssc_cur;
  --
  --   Attribute Mapping and sourcing
  --
--bug 2559788 start

   p_upd_bad_upg_seed_data;

-- bug 2559788 end

  open all_segments_cur;
  loop
     fetch all_segments_cur INTO g_all_seg_rec;
     exit when all_segments_cur%notfound;
     --
     retval := p_seg_src_def_exists(g_all_seg_rec.prc_context_code,
                                    g_all_seg_rec.segment_mapping_column);
     --
     if retval = 0 then
        -- If a defaulting rule exists for the chosen segment, in the old system,
        -- find all Source Systems for that Segment and
        -- link the segment to the all PTE, based on PTE-Source System association.
        open pte_seg_cur(g_all_seg_rec.prc_context_code,
                         g_all_seg_rec.segment_mapping_column);
        loop
          fetch pte_seg_cur INTO l_application_short_name;
          exit when pte_seg_cur%notfound;
          --
          open get_pte_cur(l_application_short_name);
          loop
            fetch get_pte_cur INTO l_pte_code;
            exit when get_pte_cur%notfound;
            -- Look for level , irrespective of Source System Code.
            -- In case there is BOTH for any SSC, that must override LINE or ORDER for any other SSC
            l_segment_level := p_get_level (g_all_seg_rec.prc_context_code,
                                            g_all_seg_rec.segment_mapping_column);
            if p_psg_exists(g_all_seg_rec.segment_id,l_pte_code) = -1 then
                p_insert_pte_segments (g_all_seg_rec.segment_id,
                                       l_pte_code,
                                       l_segment_level,
                                       'ATTRIBUTE MAPPING',
                                       'Y');
            end if;
            open attribute_sourcing_cur(g_all_seg_rec.prc_context_code,
                                        g_all_seg_rec.segment_mapping_column,
                                        l_application_short_name);
            -- For Segments with defaulting rules, they must be sourced in the
            -- new system. The Source System code of the segments will determine, as to
            -- which Request types, they will be sourced for.
            loop
              fetch attribute_sourcing_cur INTO g_sourcing_rec;
              exit when attribute_sourcing_cur%notfound;
              --
              if g_sourcing_rec.src_type in ('API','API_MULTIREC') then
                 l_value_string := g_sourcing_rec.src_api_pkg||'.'||g_sourcing_rec.src_api_fn;
              elsif g_sourcing_rec.src_type = 'PROFILE_OPTION' then
                 l_value_string := g_sourcing_rec.src_profile_option;
              elsif g_sourcing_rec.src_type = 'RELATED_RECORD' then
                 l_value_string := g_sourcing_rec.src_database_object_name||'.'||
                                   g_sourcing_rec.src_attribute_code;
              elsif g_sourcing_rec.src_type = 'SAME_RECORD' then
                 l_value_string := g_sourcing_rec.src_attribute_code;
              elsif g_sourcing_rec.src_type = 'SYSTEM' then
                 l_value_string := g_sourcing_rec.src_system_variable_expr;
              elsif g_sourcing_rec.src_type in ('SALES_CHANNEL_CODE','SOURCE_TYPE_CODE',
                                                'TAX_EXEMPT_CODE','CONSTANT') then
                 l_value_string := g_sourcing_rec.src_constant_value;
              end if;
              --
              if instr(upper(g_sourcing_rec.database_object_name),'LINE') = 0 then
                 l_attribute_sourcing_level := 'ORDER';
              else
                 l_attribute_sourcing_level := 'LINE';
              end if;
              --
              -- Rules of sourcing :
              -- If the Source System is QP,sourcing will be done for ONT Request Types only.
              -- else if it is OKC,sourcing will be done for OKC Request Types only.
              -- else if it is ASO,sourcing will be done for ASO Request Types only.
              -- else if it is AMS,sourcing will be done for ONT and ASO Request Types respectively.
              --
              if l_application_short_name = 'QP' then
                l_request_type_code := 'ONT';
              elsif l_application_short_name = 'OKC' then
                l_request_type_code := 'OKC';
              elsif l_application_short_name = 'ASO' then
                l_request_type_code := 'ASO';
              elsif l_application_short_name = 'AMS' then
                l_request_type_code := 'ONT';
              end if;
              --
              if p_sourcing_exists(g_all_seg_rec.segment_id,l_request_type_code,l_attribute_sourcing_level) = -1 then
                p_insert_sourcing(l_request_type_code,l_attribute_sourcing_level,l_value_string, g_sourcing_rec.enabled_flag);
              end if;
              --
              if l_application_short_name = 'AMS' then
                if p_sourcing_exists(g_all_seg_rec.segment_id,'ASO',l_attribute_sourcing_level) = -1 then
                  p_insert_sourcing('ASO',l_attribute_sourcing_level,l_value_string, g_sourcing_rec.enabled_flag);
                end if;
              end if;
              --
            end loop;
            close attribute_sourcing_cur;
            --
         end loop;
         close get_pte_cur;
         --
       end loop;
       close pte_seg_cur;
       --
     elsif retval = -1 then
        -- If a defaulting rule does not exist for the chosen segment, in the old system,
        -- link the segment to the all PTEs.
        open pte_cur;
        loop
          fetch pte_cur INTO g_pte_rec;
          exit when pte_cur%notfound;
          --
          if p_psg_exists(g_all_seg_rec.segment_id,g_pte_rec.lookup_code) = -1 then
            -- Do not create pte_segment links
            -- for LOGISTICS context and PTEs other than 'Logistics',
            -- COUPON_NO attribute and 'Logistics' PTE,
            -- 'Number of Students' attribute and PTEs other than 'Order Fulfillment'.
            if (g_all_seg_rec.prc_context_code = 'LOGISTICS' and
                g_pte_rec.lookup_code <> 'LOGSTX') or
               (g_all_seg_rec.segment_code = 'COUPON_NO' and
                g_pte_rec.lookup_code = 'LOGSTX') or
               (g_all_seg_rec.segment_code = 'TOTAL_ITEM_QUANTITY' and
                g_pte_rec.lookup_code = 'ORDFUL') or
               (g_all_seg_rec.segment_code = 'Number of students' and
                g_pte_rec.lookup_code <> 'ORDFUL') then
                null;
            else
            p_insert_pte_segments (g_all_seg_rec.segment_id,
                                   g_pte_rec.lookup_code,
                                   'LINE',
                                   'USER ENTERED',
                                   'N');
            end if;
          end if;
        end loop;
        close pte_cur;
        --
     elsif retval = -2 then
       raise atm_serious_problem;
     end if;
     --
  end loop;
  close all_segments_cur;
  --
  --  Delete PTE-Attributes Links that are not required
  --
  p_delete_PTE_attribute_links;
  --
  commit;
  --
  --  Derving PTE code and assigning PTE code to new pte_code column
  --  in qp_list_headers_b table
  --
  open assign_pte_cur;
  loop
     fetch assign_pte_cur INTO l_list_header_id,l_pte_code;
     exit when assign_pte_cur%notfound;
     --
     update qp_list_headers_b
     set pte_code = l_pte_code
     where list_header_id = l_list_header_id;
     --
  end loop;
  close assign_pte_cur;
  --
  commit;
  --
EXCEPTION
  WHEN atm_serious_problem THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
        FND_MESSAGE.SET_NAME('QP','QP_UPGRADE_SERIOUS_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR_DESCRIPTION',sqlerrm);
        OE_MSG_PUB.Add;
    END IF;
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        OE_MSG_PUB.Add_Exc_Msg
        (  G_PKG_NAME,
           'Upgrade_ATM');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END upgrade_atm;
--
END QP_ATM_UPGRADE;

/
