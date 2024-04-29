--------------------------------------------------------
--  DDL for Package PER_DRT_BK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DRT_BK6" AUTHID CURRENT_USER as
/* $Header: pedrtapi.pkh 120.0.12010000.2 2018/04/13 09:21:35 gahluwal noship $ */
--
-- ------------------------------------------------------------------------------------
-- |-----------------------------< update_col_contexts_details_b >--------------------------|
-- ------------------------------------------------------------------------------------
--
procedure update_col_contexts_details_b
  (p_ff_column_id      in number
  ,p_column_id         in number
  ,p_ff_name           in varchar2
  ,p_context_name      in varchar2
  ,p_column_name       in varchar2
  ,p_column_phase      in number
  ,p_attribute         in varchar2
  ,p_rule_type         in varchar2
  ,p_parameter_1       in varchar2
  ,p_parameter_2       in varchar2
  ,p_comments          in varchar2
  );
--
-- ------------------------------------------------------------------------------------
-- |-----------------------------< update_col_contexts_details_a >--------------------------|
-- ------------------------------------------------------------------------------------
--
procedure update_col_contexts_details_a
  (p_ff_column_id      in number
  ,p_column_id         in number
  ,p_ff_name           in varchar2
  ,p_context_name      in varchar2
  ,p_column_name       in varchar2
  ,p_column_phase      in number
  ,p_attribute         in varchar2
  ,p_rule_type         in varchar2
  ,p_parameter_1       in varchar2
  ,p_parameter_2       in varchar2
  ,p_comments          in varchar2
  );
--
end per_drt_bk6;

/
