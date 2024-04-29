--------------------------------------------------------
--  DDL for Package PQH_DOA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DOA_RKU" AUTHID CURRENT_USER as
/* $Header: pqdoarhi.pkh 120.0 2005/05/29 01:49:09 appldev noship $ */
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
  ,p_document_attribute_id        in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_document_id                  in number
  ,p_attribute_id                 in number
  ,p_tag_name                     in varchar2
  ,p_object_version_number        in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_document_id_o                in number
  ,p_attribute_id_o               in number
  ,p_tag_name_o                   in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_doa_rku;

 

/
