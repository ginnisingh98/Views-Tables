--------------------------------------------------------
--  DDL for Package AME_GPI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_GPI_RKD" AUTHID CURRENT_USER as
/* $Header: amgpirhi.pkh 120.0 2005/09/02 03:59 mbocutt noship $ */
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
  ,p_approval_group_item_id       in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_approval_group_id_o          in number
  ,p_parameter_name_o             in varchar2
  ,p_parameter_o                  in varchar2
  ,p_order_number_o               in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_security_group_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end ame_gpi_rkd;

 

/
