--------------------------------------------------------
--  DDL for Package PQH_RFT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RFT_RKI" AUTHID CURRENT_USER as
/* $Header: pqrftrhi.pkh 120.2 2005/10/12 20:19:08 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_ref_template_id                in number
 ,p_base_template_id               in number
 ,p_parent_template_id             in number
 ,p_reference_type_cd              in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end pqh_rft_rki;

 

/
