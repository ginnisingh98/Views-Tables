--------------------------------------------------------
--  DDL for Package HXC_HTC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HTC_RKU" AUTHID CURRENT_USER as
/* $Header: hxchtcrhi.pkh 120.0.12010000.1 2008/07/28 11:13:07 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_time_category_id                   in number
  ,p_time_category_name                 in varchar2
  ,p_operator                       in     varchar2
  ,p_description                    in     varchar2
  ,p_display                        in     varchar2
  ,p_object_version_number        in number
  ,p_time_category_name_o         in varchar2
  ,p_operator_o                   in     varchar2
  ,p_description_o                in     varchar2
  ,p_display_o                    in     varchar2
  ,p_object_version_number_o      in number
  );
--
end hxc_htc_rku;

/
