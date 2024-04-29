--------------------------------------------------------
--  DDL for Package AME_ACA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACA_RKI" AUTHID CURRENT_USER as
/* $Header: amacarhi.pkh 120.0 2005/09/02 03:47 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_fnd_application_id           in number
  ,p_application_name             in varchar2
  ,p_transaction_type_id          in varchar2
  ,p_application_id               in number
  ,p_line_item_id_query           in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_security_group_id            in number
  ,p_object_version_number        in number
  );
end ame_aca_rki;

 

/
