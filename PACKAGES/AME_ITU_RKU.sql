--------------------------------------------------------
--  DDL for Package AME_ITU_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITU_RKU" AUTHID CURRENT_USER as
/* $Header: amiturhi.pkh 120.0 2005/09/02 04:01 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_application_id               in number
  ,p_item_class_id                in number
  ,p_item_id_query                in varchar2
  ,p_item_class_order_number      in number
  ,p_item_class_par_mode          in varchar2
  ,p_item_class_sublist_mode      in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_object_version_number        in number
  ,p_item_id_query_o              in varchar2
  ,p_item_class_order_number_o    in number
  ,p_item_class_par_mode_o        in varchar2
  ,p_item_class_sublist_mode_o    in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_object_version_number_o      in number
  );
--
end ame_itu_rku;

 

/
