--------------------------------------------------------
--  DDL for Package HR_TIS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TIS_RKU" AUTHID CURRENT_USER as
/* $Header: hrtisrhi.pkh 120.1 2008/01/25 13:51:38 avarri ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
--
procedure after_update
  (p_topic_integrations_id        in number
  ,p_topic_id                     in number
  ,p_integration_id               in number
  ,p_param_name1                  in varchar2
  ,p_param_value1                 in varchar2
  ,p_param_name2                  in varchar2
  ,p_param_value2                 in varchar2
  ,p_param_name3                  in varchar2
  ,p_param_value3                 in varchar2
  ,p_param_name4                  in varchar2
  ,p_param_value4                 in varchar2
  ,p_param_name5                  in varchar2
  ,p_param_value5                 in varchar2
  ,p_param_name6                  in varchar2
  ,p_param_value6                 in varchar2
  ,p_param_name7                  in varchar2
  ,p_param_value7                 in varchar2
  ,p_param_name8                  in varchar2
  ,p_param_value8                 in varchar2
  ,p_param_name9                  in varchar2
  ,p_param_value9                 in varchar2
  ,p_param_name10                 in varchar2
  ,p_param_value10                in varchar2
  ,p_object_version_number        in number
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
end hr_tis_rku;

/
