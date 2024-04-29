--------------------------------------------------------
--  DDL for Package BEN_BEO_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BEO_RKI" AUTHID CURRENT_USER as
/* $Header: bebeorhi.pkh 120.0.12010000.1 2008/07/29 10:54:56 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_elig_obj_id                  in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_table_name                   in varchar2
  ,p_column_name                  in varchar2
  ,p_column_value                 in varchar2
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  );
end ben_beo_rki;

/
