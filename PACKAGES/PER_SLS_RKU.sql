--------------------------------------------------------
--  DDL for Package PER_SLS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SLS_RKU" AUTHID CURRENT_USER as
/* $Header: peslsrhi.pkh 120.0 2005/05/31 21:14:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_solution_set_name            in varchar2
  ,p_user_id                      in number
  ,p_description                  in varchar2
  ,p_status                       in varchar2
  ,p_solution_set_impl_id         in number
  ,p_object_version_number        in number
  ,p_description_o                in varchar2
  ,p_status_o                     in varchar2
  ,p_solution_set_impl_id_o       in number
  ,p_object_version_number_o      in number
  );
--
end per_sls_rku;

 

/
