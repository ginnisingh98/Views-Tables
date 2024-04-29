--------------------------------------------------------
--  DDL for Package PER_DRT_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DRT_BK4" AUTHID CURRENT_USER as
/* $Header: pedrtapi.pkh 120.0.12010000.2 2018/04/13 09:21:35 gahluwal noship $ */
--
-- ------------------------------------------------------------------------------------
-- |-----------------------------< update_tables_details_b >--------------------------|
-- ------------------------------------------------------------------------------------
--
procedure update_tables_details_b
  (p_table_id            in number
  ,p_product_code        in varchar2
  ,p_schema              in varchar2
  ,p_table_name          in varchar2
  ,p_table_phase         in number
  ,p_record_identifier   in varchar2
  ,p_entity_type         in varchar2
  );
--
-- ------------------------------------------------------------------------------------
-- |-----------------------------< update_tables_details_a >--------------------------|
-- ------------------------------------------------------------------------------------
--
procedure update_tables_details_a
  (p_table_id            in number
  ,p_product_code        in varchar2
  ,p_schema              in varchar2
  ,p_table_name          in varchar2
  ,p_table_phase         in number
  ,p_record_identifier   in varchar2
  ,p_entity_type         in varchar2
  );
--
end per_drt_bk4;

/
