--------------------------------------------------------
--  DDL for Package PER_CAI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CAI_RKI" AUTHID CURRENT_USER as
/* $Header: pecairhi.pkh 115.1 2002/12/04 05:50:27 raranjan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_cagr_api_id                  in number
  ,p_api_name                     in varchar2
  ,p_category_name                in varchar2
  ,p_object_version_number        in number
  );
end per_cai_rki;

 

/
