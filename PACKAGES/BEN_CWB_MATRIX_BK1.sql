--------------------------------------------------------
--  DDL for Package BEN_CWB_MATRIX_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_MATRIX_BK1" AUTHID CURRENT_USER as
/* $Header: bebcmapi.pkh 120.0.12010000.1 2008/07/29 10:53:45 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_cwb_matrix_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cwb_matrix_b
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_name                          in     varchar2
  ,p_plan_id                       in     number
  ,p_matrix_typ_cd                 in     varchar2
  ,p_person_id                     in     number
  ,p_row_crit_cd                   in     varchar2
  ,p_col_crit_cd                   in     varchar2
  ,p_alct_by_cd                    in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_cwb_matrix_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cwb_matrix_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_name                          in     varchar2
  ,p_plan_id                       in     number
  ,p_matrix_typ_cd                 in     varchar2
  ,p_person_id                     in     number
  ,p_row_crit_cd                   in     varchar2
  ,p_col_crit_cd                   in     varchar2
  ,p_alct_by_cd                    in     varchar2
  ,p_cwb_matrix_id                 in     number
  ,p_object_version_number         in     number
  );
--
end ben_cwb_matrix_bk1;

/
