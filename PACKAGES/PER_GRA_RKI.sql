--------------------------------------------------------
--  DDL for Package PER_GRA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GRA_RKI" AUTHID CURRENT_USER as
/* $Header: pegrarhi.pkh 120.0 2005/05/31 09:28:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_cagr_grade_id                  in number
 ,p_cagr_grade_structure_id        in number
 ,p_cagr_grade_def_id              in number
 ,p_sequence                       in number
 ,p_object_version_number          in number
 ,p_effective_date   in date
  );
end per_gra_rki;

 

/
