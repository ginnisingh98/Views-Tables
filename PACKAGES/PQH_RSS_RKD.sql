--------------------------------------------------------
--  DDL for Package PQH_RSS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RSS_RKD" AUTHID CURRENT_USER as
/* $Header: pqrssrhi.pkh 120.0 2005/05/29 02:38:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_result_set_id                in number
  ,p_gradual_value_number_from_o  in number
  ,p_gradual_value_number_to_o    in number
  ,p_grade_id_o                   in number
  ,p_object_version_number_o      in number
  );
--
end pqh_rss_rkd;

 

/
