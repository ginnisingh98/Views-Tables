--------------------------------------------------------
--  DDL for Package PER_DRT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DRT_BK1" AUTHID CURRENT_USER as
/* $Header: pedrtapi.pkh 120.0.12010000.2 2018/04/13 09:21:35 gahluwal noship $ */
--
-- ------------------------------------------------------------------------------------
-- |-----------------------------< insert_tables_details_b >--------------------------|
-- ------------------------------------------------------------------------------------
--
procedure insert_tables_details_b
  (p_product_code          in varchar2
  ,p_schema                in varchar2
  ,p_table_name            in varchar2
  ,p_table_phase           in number
  ,p_record_identifier     in varchar2
  ,p_entity_type           in varchar2
  ,p_table_id              in number
  );
--
-- ------------------------------------------------------------------------------------
-- |-----------------------------< insert_tables_details_a >--------------------------|
-- ------------------------------------------------------------------------------------
--
procedure insert_tables_details_a
  (p_product_code          in varchar2
  ,p_schema                in varchar2
  ,p_table_name            in varchar2
  ,p_table_phase           in number
  ,p_record_identifier     in varchar2
  ,p_entity_type           in varchar2
  ,p_table_id              in number
  );
--
end per_drt_bk1;

/
