--------------------------------------------------------
--  DDL for Package PER_CAI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CAI_RKD" AUTHID CURRENT_USER as
/* $Header: pecairhi.pkh 115.1 2002/12/04 05:50:27 raranjan noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_cagr_api_id                  in number
  ,p_api_name_o                   in varchar2
  ,p_category_name_o              in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_cai_rkd;

 

/
