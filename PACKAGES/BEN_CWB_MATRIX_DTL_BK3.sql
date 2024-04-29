--------------------------------------------------------
--  DDL for Package BEN_CWB_MATRIX_DTL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_MATRIX_DTL_BK3" AUTHID CURRENT_USER as
/* $Header: bebcdapi.pkh 120.0.12010000.1 2008/07/29 10:53:17 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_cwb_matrix_dtl_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cwb_matrix_dtl_b
  (p_cwb_matrix_dtl_id             in    number
  ,p_object_version_number         in    number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_cwb_matrix_dtl_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cwb_matrix_dtl_a
  (p_cwb_matrix_dtl_id             in     number
  ,p_object_version_number         in     number
  );
--
end ben_cwb_matrix_dtl_bk3;

/
