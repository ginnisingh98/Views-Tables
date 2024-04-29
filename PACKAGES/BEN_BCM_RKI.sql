--------------------------------------------------------
--  DDL for Package BEN_BCM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BCM_RKI" AUTHID CURRENT_USER as
/* $Header: bebcmrhi.pkh 120.0.12010000.1 2008/07/29 10:53:52 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_cwb_matrix_id                in number
  ,p_name                         in varchar2
  ,p_date_saved                   in date
  ,p_plan_id                      in number
  ,p_matrix_typ_cd                in varchar2
  ,p_person_id                    in number
  ,p_row_crit_cd                  in varchar2
  ,p_col_crit_cd                  in varchar2
  ,p_alct_by_cd                   in varchar2
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  );
end ben_bcm_rki;

/
