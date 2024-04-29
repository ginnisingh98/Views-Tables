--------------------------------------------------------
--  DDL for Package HXC_HTC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HTC_RKI" AUTHID CURRENT_USER as
/* $Header: hxchtcrhi.pkh 120.0.12010000.1 2008/07/28 11:13:07 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_time_category_id                   in number
  ,p_time_category_name                 in varchar2
  ,p_operator                       in     varchar2
  ,p_description                    in     varchar2
  ,p_display                        in     varchar2
  ,p_object_version_number        in number
  );
end hxc_htc_rki;

/
