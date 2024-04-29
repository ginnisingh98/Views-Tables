--------------------------------------------------------
--  DDL for Package BEN_PEI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PEI_RKU" AUTHID CURRENT_USER as
/* $Header: bepeirhi.pkh 120.0 2005/05/28 10:33:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
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
         p_validation_end_date         in date,
         p_datetrack_mode              in varchar2,
         p_pl_id_o                     in  number,
         p_plip_id_o                   in  number,
         p_oipl_id_o                   in  number,
         p_third_party_identifier_o    in  varchar2,
         p_organization_id_o           in  number,
         p_job_id_o                    in  number,
         p_position_id_o               in  number,
         p_people_group_id_o           in  number,
         p_grade_id_o                  in  number,
         p_payroll_id_o                in  number,
         p_home_state_o                in  varchar2,
         p_home_zip_o                  in  varchar2,
         p_effective_start_date_o      in  date,
         p_effective_end_date_o        in  date,
         p_object_version_number_o     in  number,
         p_business_group_id_o         in  number
        );
--
end ben_pei_rku;

 

/
