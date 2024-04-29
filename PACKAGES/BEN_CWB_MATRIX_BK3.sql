--------------------------------------------------------
--  DDL for Package BEN_CWB_MATRIX_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_MATRIX_BK3" AUTHID CURRENT_USER as
/* $Header: bebcmapi.pkh 120.0.12010000.1 2008/07/29 10:53:45 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_cwb_matrix_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cwb_matrix_b
  (p_cwb_matrix_id                 in    number
  ,p_effective_date                in     date
  ,p_object_version_number         in    number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_cwb_matrix_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cwb_matrix_a
  (p_effective_date                in     date
  ,p_cwb_matrix_id                 in     number
  ,p_object_version_number         in     number
  );
--
end ben_cwb_matrix_bk3;

/
