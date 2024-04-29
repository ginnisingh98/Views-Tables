--------------------------------------------------------
--  DDL for Package BEN_BER_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BER_RKD" AUTHID CURRENT_USER as
/* $Header: beberrhi.pkh 120.0.12010000.1 2008/07/29 10:56:00 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_elig_rslt_id                 in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_elig_obj_id_o                in number
  ,p_person_id_o                  in number
  ,p_assignment_id_o              in number
  ,p_elig_flag_o                  in varchar2
  ,p_business_group_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end ben_ber_rkd;

/
