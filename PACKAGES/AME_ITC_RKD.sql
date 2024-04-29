--------------------------------------------------------
--  DDL for Package AME_ITC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITC_RKD" AUTHID CURRENT_USER as
/* $Header: amitcrhi.pkh 120.0 2005/09/02 04:00 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_item_class_id                in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_name_o                       in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_object_version_number_o      in number
  );
--
end ame_itc_rkd;

 

/
