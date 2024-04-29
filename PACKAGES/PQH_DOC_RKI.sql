--------------------------------------------------------
--  DDL for Package PQH_DOC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DOC_RKI" AUTHID CURRENT_USER as
/* $Header: pqdocrhi.pkh 120.1 2005/09/15 13:51:17 rthiagar noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_document_id                  in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_short_name                   in varchar2
  ,p_document_name                in varchar2
  ,p_file_id                      in number
  ,p_enable_flag                  in varchar2
  ,p_last_update_by               in number
  ,p_object_version_number        in number
  ,p_formula_id                   in number
  ,p_document_category            in varchar2
  /* Added for XDO changes */
  ,p_lob_code                     in varchar2
  ,p_language                     in varchar2
  ,p_territory                    in varchar2
  );
end pqh_doc_rki;

 

/
