--------------------------------------------------------
--  DDL for Package HXC_HTR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HTR_RKD" AUTHID CURRENT_USER as
/* $Header: hxchtrrhi.pkh 120.0.12010000.1 2008/07/28 11:13:32 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_time_recipient_id            in number
  ,p_name_o                       in varchar2
  ,p_application_id_o             in number
  ,p_object_version_number_o      in number
  );
--
end hxc_htr_rkd;

/
