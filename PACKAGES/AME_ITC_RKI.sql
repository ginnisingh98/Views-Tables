--------------------------------------------------------
--  DDL for Package AME_ITC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITC_RKI" AUTHID CURRENT_USER as
/* $Header: amitcrhi.pkh 120.0 2005/09/02 04:00 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_item_class_id                in number
  ,p_name                         in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_object_version_number        in number
  );
end ame_itc_rki;

 

/
