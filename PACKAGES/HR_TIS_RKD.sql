--------------------------------------------------------
--  DDL for Package HR_TIS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TIS_RKD" AUTHID CURRENT_USER as
/* $Header: hrtisrhi.pkh 120.1 2008/01/25 13:51:38 avarri ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_topic_integrations_id        in number
  ,p_topic_id_o                   in number
  ,p_integration_id_o             in number
  ,p_param_name1_o                in varchar2
  ,p_param_value1_o               in varchar2
  ,p_param_name2_o                in varchar2
  ,p_param_value2_o               in varchar2
  ,p_param_name3_o                in varchar2
  ,p_param_value3_o               in varchar2
  ,p_param_name4_o                in varchar2
  ,p_param_value4_o               in varchar2
  ,p_param_name5_o                in varchar2
  ,p_param_value5_o               in varchar2
  ,p_param_name6_o                in varchar2
  ,p_param_value6_o               in varchar2
  ,p_param_name7_o                in varchar2
  ,p_param_value7_o               in varchar2
  ,p_param_name8_o                in varchar2
  ,p_param_value8_o               in varchar2
  ,p_param_name9_o                in varchar2
  ,p_param_value9_o               in varchar2
  ,p_param_name10_o               in varchar2
  ,p_param_value10_o              in varchar2
  ,p_object_version_number_o      in number
  );
--
end hr_tis_rkd;

/
