--------------------------------------------------------
--  DDL for Package AME_ITU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITU_RKI" AUTHID CURRENT_USER as
/* $Header: amiturhi.pkh 120.0 2005/09/02 04:01 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
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
  );
end ame_itu_rki;

 

/
