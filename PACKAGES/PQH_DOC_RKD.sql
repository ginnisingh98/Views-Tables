--------------------------------------------------------
--  DDL for Package PQH_DOC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DOC_RKD" AUTHID CURRENT_USER as
/* $Header: pqdocrhi.pkh 120.1 2005/09/15 13:51:17 rthiagar noship $ */
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
  ,p_document_id                  in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_short_name_o                 in varchar2
  ,p_document_name_o              in varchar2
  ,p_file_id_o                    in number
  ,p_enable_flag_o                in varchar2
  ,p_last_update_by_o             in number
  ,p_object_version_number_o      in number
  ,p_formula_id_o                 in number
  ,p_document_category_o          in varchar2
  /* Added for XDO changes */
  ,p_lob_code_o                   in varchar2
  ,p_language_o                   in varchar2
  ,p_territory_o                  in varchar2
  );
--
end pqh_doc_rkd;

 

/
