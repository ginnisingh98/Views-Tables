--------------------------------------------------------
--  DDL for Package PQH_GVN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GVN_RKI" AUTHID CURRENT_USER as
/* $Header: pqgvnrhi.pkh 120.0 2005/05/29 02:01:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_level_number_id              in number
  ,p_level_number                 in varchar2
  ,p_description                  in varchar2
  ,p_object_version_number        in number
  );
end pqh_gvn_rki;

 

/
