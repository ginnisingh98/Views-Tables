--------------------------------------------------------
--  DDL for Package PER_GRA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GRA_RKD" AUTHID CURRENT_USER as
/* $Header: pegrarhi.pkh 120.0 2005/05/31 09:28:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_cagr_grade_id                  in number
 ,p_cagr_grade_structure_id_o      in number
 ,p_cagr_grade_def_id_o            in number
 ,p_sequence_o                     in number
 ,p_object_version_number_o        in number
 ,p_effective_date   		   in date
  );
--
end per_gra_rkd;

 

/
