--------------------------------------------------------
--  DDL for Package BEN_PYMT_CHECK_DET_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PYMT_CHECK_DET_BK3" AUTHID CURRENT_USER as
/* $Header: bepdtapi.pkh 120.0 2005/05/28 10:28:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pymt_check_det_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pymt_check_det_b
  (
   p_pymt_check_det_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pymt_check_det_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pymt_check_det_a
  (
   p_pymt_check_det_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_pymt_check_det_bk3;

 

/
