--------------------------------------------------------
--  DDL for Package PQH_GVN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GVN_RKU" AUTHID CURRENT_USER as
/* $Header: pqgvnrhi.pkh 120.0 2005/05/29 02:01:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_level_number_id              in number
  ,p_level_number                 in varchar2
  ,p_description                  in varchar2
  ,p_object_version_number        in number
  ,p_level_number_o               in varchar2
  ,p_description_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_gvn_rku;

 

/
