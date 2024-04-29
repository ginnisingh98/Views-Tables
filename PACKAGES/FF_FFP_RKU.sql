--------------------------------------------------------
--  DDL for Package FF_FFP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FFP_RKU" AUTHID CURRENT_USER as
/* $Header: ffffprhi.pkh 120.0 2005/05/27 23:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_function_id                  in number
  ,p_sequence_number              in number
  ,p_class                        in varchar2
  ,p_continuing_parameter         in varchar2
  ,p_data_type                    in varchar2
  ,p_name                         in varchar2
  ,p_optional                     in varchar2
  ,p_object_version_number        in number
  ,p_class_o                      in varchar2
  ,p_continuing_parameter_o       in varchar2
  ,p_data_type_o                  in varchar2
  ,p_name_o                       in varchar2
  ,p_optional_o                   in varchar2
  ,p_object_version_number_o      in number
  );
--
end ff_ffp_rku;

 

/
