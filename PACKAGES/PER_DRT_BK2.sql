--------------------------------------------------------
--  DDL for Package PER_DRT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DRT_BK2" AUTHID CURRENT_USER as
/* $Header: pedrtapi.pkh 120.0.12010000.2 2018/04/13 09:21:35 gahluwal noship $ */
--
-- ------------------------------------------------------------------------------------
-- |-----------------------------< insert_columns_details_b >--------------------------|
-- ------------------------------------------------------------------------------------
--
procedure insert_columns_details_b
  (p_table_id          in number
  ,p_column_name       in varchar2
  ,p_column_phase      in number
  ,p_attribute         in varchar2
  ,p_ff_type           in varchar2
  ,p_rule_type         in varchar2
  ,p_parameter_1       in varchar2
  ,p_parameter_2       in varchar2
  ,p_comments          in varchar2
  ,p_column_id         in number
  );
--
-- ------------------------------------------------------------------------------------
-- |-----------------------------< insert_columns_details_a >--------------------------|
-- ------------------------------------------------------------------------------------
--
procedure insert_columns_details_a
  (p_table_id          in number
  ,p_column_name       in varchar2
  ,p_column_phase      in number
  ,p_attribute         in varchar2
  ,p_ff_type           in varchar2
  ,p_rule_type         in varchar2
  ,p_parameter_1       in varchar2
  ,p_parameter_2       in varchar2
  ,p_comments          in varchar2
  ,p_column_id         in number
  );
--
end per_drt_bk2;

/
