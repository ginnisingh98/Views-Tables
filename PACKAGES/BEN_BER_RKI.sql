--------------------------------------------------------
--  DDL for Package BEN_BER_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BER_RKI" AUTHID CURRENT_USER as
/* $Header: beberrhi.pkh 120.0.12010000.1 2008/07/29 10:56:00 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_elig_rslt_id                 in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_elig_obj_id                  in number
  ,p_person_id                    in number
  ,p_assignment_id                in number
  ,p_elig_flag                    in varchar2
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  );
end ben_ber_rki;

/
