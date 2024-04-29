--------------------------------------------------------
--  DDL for Package AME_GPI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_GPI_RKI" AUTHID CURRENT_USER as
/* $Header: amgpirhi.pkh 120.0 2005/09/02 03:59 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_approval_group_item_id       in number
  ,p_approval_group_id            in number
  ,p_parameter_name               in varchar2
  ,p_parameter                    in varchar2
  ,p_order_number                 in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_security_group_id            in number
  ,p_object_version_number        in number
  );
end ame_gpi_rki;

 

/
