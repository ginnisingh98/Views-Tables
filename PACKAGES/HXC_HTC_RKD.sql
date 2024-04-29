--------------------------------------------------------
--  DDL for Package HXC_HTC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HTC_RKD" AUTHID CURRENT_USER as
/* $Header: hxchtcrhi.pkh 120.0.12010000.1 2008/07/28 11:13:07 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_time_category_id             in number
  ,p_time_category_name_o         in varchar2
  ,p_operator_o                   in varchar2
  ,p_description_o                in     varchar2
  ,p_display_o                    in     varchar2
  ,p_object_version_number_o      in number
  );
--
end hxc_htc_rkd;

/
