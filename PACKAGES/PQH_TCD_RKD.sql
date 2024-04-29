--------------------------------------------------------
--  DDL for Package PQH_TCD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TCD_RKD" AUTHID CURRENT_USER as
/* $Header: pqtcdrhi.pkh 120.0 2005/05/29 02:46:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_document_id                  in number
  ,p_transaction_category_id      in number
  ,p_type_code_o                  in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_tcd_rkd;

 

/
