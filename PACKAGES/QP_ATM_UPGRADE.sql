--------------------------------------------------------
--  DDL for Package QP_ATM_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_ATM_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: QPATMUPS.pls 120.0 2005/06/02 01:20:51 appldev noship $ */


TYPE seg_type IS RECORD (
  segment_id       number,
  segment_code     varchar2(30));
--
g_seg_row                seg_type;
--
TYPE req_ssc_type IS RECORD (
  request_type_code         varchar2(30),
  source_system_code        varchar2(30));
--
g_req_ssc_rec            req_ssc_type;
--
CURSOR all_seg_cur is
 SELECT b.prc_context_code,
        a.*
 FROM   qp_segments_b a,
        qp_prc_contexts_b b
        WHERE b.prc_context_id = a.prc_context_id
        AND a.segment_id = 1;
--
g_all_seg_rec            all_seg_cur%rowtype;
--
CURSOR attribute_sourcing_cur (p_prc_context_code in varchar2,
                               p_segment_mapping_column in varchar2,
                               p_application_short_name in varchar2) is
  SELECT d.*, b.enabled_flag
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
        a.attribute_application_id = 661;
--
g_sourcing_rec           attribute_sourcing_cur%rowtype;
--
g_pte_rec                qp_lookups%rowtype;
g_context_b_rec          fnd_descr_flex_contexts%rowtype;
g_segment_b_rec          fnd_descr_flex_column_usages%rowtype;
g_context_tl_rec         fnd_descr_flex_contexts_tl%rowtype;
g_segment_tl_rec         fnd_descr_flex_col_usage_tl%rowtype;
--
g_context_seqno          number;
g_segment_seqno          number;
g_ssc_seqno              number;
g_psg_seqno              number;
g_source_seqno           number;
g_pte_num                number := 0;
--
Procedure Upgrade_atm;
--
END QP_ATM_UPGRADE;

 

/
