--------------------------------------------------------
--  DDL for Package PQH_TCD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TCD_RKI" AUTHID CURRENT_USER as
/* $Header: pqtcdrhi.pkh 120.0 2005/05/29 02:46:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_document_id                  in number
  ,p_transaction_category_id      in number
  ,p_type_code                    in varchar2
  ,p_object_version_number        in number
  );
end pqh_tcd_rki;

 

/
