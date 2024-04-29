--------------------------------------------------------
--  DDL for Package AME_APG_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APG_RKU" AUTHID CURRENT_USER as
/* $Header: amapgrhi.pkh 120.0 2005/09/02 03:50 mbocutt noship $ */
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
  ,p_approval_group_id            in number
  ,p_name                         in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_description                  in varchar2
  ,p_query_string                 in varchar2
  ,p_is_static                    in varchar2
  ,p_security_group_id            in number
  ,p_object_version_number        in number
  ,p_name_o                       in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_description_o                in varchar2
  ,p_query_string_o               in varchar2
  ,p_is_static_o                  in varchar2
  ,p_security_group_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end ame_apg_rku;

 

/
