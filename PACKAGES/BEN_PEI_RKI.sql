--------------------------------------------------------
--  DDL for Package BEN_PEI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PEI_RKI" AUTHID CURRENT_USER as
/* $Header: bepeirhi.pkh 120.0 2005/05/28 10:33:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
        (
         p_pl_extract_identifier_id    in  number,
         p_pl_id                       in  number,
         p_plip_id                     in  number,
         p_oipl_id                     in  number,
         p_third_party_identifier      in  varchar2,
         p_organization_id             in  number,
         p_job_id                      in  number,
         p_position_id                 in  number,
         p_people_group_id             in  number,
         p_grade_id                    in  number,
         p_payroll_id                  in  number,
         p_home_state                  in  varchar2,
         p_home_zip                    in  varchar2,
         p_effective_start_date        in  date,
         p_effective_end_date          in  date,
         p_object_version_number       in  number,
         p_business_group_id           in  number,
         p_effective_date              in date,
         p_validation_start_date       in date,
         p_validation_end_date         in date
        );
end ben_pei_rki;

 

/
