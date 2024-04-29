--------------------------------------------------------
--  DDL for Package BEN_CWB_MATRIX_DTL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_MATRIX_DTL_BK1" AUTHID CURRENT_USER as
/* $Header: bebcdapi.pkh 120.0.12010000.1 2008/07/29 10:53:17 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_cwb_matrix_dtl_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cwb_matrix_dtl_b
  (p_cwb_matrix_id                  in     number
  ,p_business_group_id              in     number
  ,p_row_crit_val                   in     varchar2
  ,p_col_crit_val                   in     varchar2
  ,p_pct_emp_cndr                   in     number
  ,p_pct_val                        in     number
  ,p_emp_amt                        in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_cwb_matrix_dtl_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cwb_matrix_dtl_a
  (p_cwb_matrix_dtl_id             in     number
  ,p_cwb_matrix_id                 in     number
  ,p_business_group_id             in     number
  ,p_row_crit_val                  in     varchar2
  ,p_col_crit_val                  in     varchar2
  ,p_pct_emp_cndr                  in     number
  ,p_pct_val                       in     number
  ,p_emp_amt                       in     number
  ,p_object_version_number         in     number
  );
--
end ben_cwb_matrix_dtl_bk1;

/
