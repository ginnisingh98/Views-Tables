--------------------------------------------------------
--  DDL for Package BEN_CWB_MATRIX_DTL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_MATRIX_DTL_API" AUTHID CURRENT_USER as
/* $Header: bebcdapi.pkh 120.0.12010000.1 2008/07/29 10:53:17 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_cwb_matrix_dtl >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                         Reqd    Type      Description
--  p_validate                     No     boolean   Commit or Rollback.
--  p_business_group_id            Yes    number    Business Group of Record
--  p_cwb_matrix_id                Yes    number    Matrix Id of the Master table
--  p_row_crit_val                 Yes    varchar2  Row Criterion Code
--  p_col_crit_val                 No     varchar2  Column Criterion Code
--  p_pct_emp_cndr                 No     number    Percent of Employees Considered
--  p_pct_val                      No     number    Percent of Eligible Salary
--  p_emp_amt                      No     number    Per Employee Amount
--
--
-- Post Success:
--
--  Out Parameters:
--   Name                                  Type     Description
--  p_cwb_matrix_dtl_id                    number   PK of record
--  p_object_version_number                number   OVN of record
--
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_cwb_matrix_dtl
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_cwb_matrix_id                 in     number
  ,p_row_crit_val                  in     varchar2
  ,p_col_crit_val                  in     varchar2 default null
  ,p_pct_emp_cndr                  in     number   default null
  ,p_pct_val                       in     number   default null
  ,p_emp_amt                       in     number   default null
  ,p_cwb_matrix_dtl_id             out nocopy    number
  ,p_object_version_number         out nocopy    number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_cwb_matrix_dtl >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                         Reqd    Type      Description
--  p_validate                     No     boolean   Commit or Rollback.
--  p_business_group_id            Yes    number    Business Group of Record
--  p_cwb_matrix_dtl_id            Yes    number    PK of record
--  p_cwb_matrix_id                Yes    number    Matrix Id of the Master table
--  p_row_crit_val                 Yes    varchar2  Row Criterion Code
--  p_col_crit_val                 No     varchar2  Column Criterion Code
--  p_pct_emp_cndr                 No     number    Percent of Employees Considered
--  p_pct_val                      No     number    Percent of Eligible Salary
--  p_emp_amt                      No     number    Per Employee Amount
--
-- Post Success:
--
--  Out Parameters:
--   Name                                  Type     Description
--  p_object_version_number                number   OVN of record
--
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_cwb_matrix_dtl
  (p_validate                      in     boolean  default false
  ,p_cwb_matrix_dtl_id             in     number
  ,p_cwb_matrix_id                 in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_row_crit_val                  in     varchar2 default hr_api.g_varchar2
  ,p_col_crit_val                  in     varchar2 default hr_api.g_varchar2
  ,p_pct_emp_cndr                  in     number   default hr_api.g_number
  ,p_pct_val                       in     number   default hr_api.g_number
  ,p_emp_amt                       in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_cwb_matrix_dtl >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                         Reqd     Type     Description
--  p_validate                     Yes     boolean   Commit or Rollback.
--  p_cwb_matrix_dtl_id            Yes     number    PK of record
--
-- Post Success:
--
--  Out Parameters:
--   Name                                  Type     Description
--  p_object_version_number                number   OVN of record
--
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_cwb_matrix_dtl
  (p_validate                      in     boolean  default false
  ,p_cwb_matrix_dtl_id             in     number
  ,p_object_version_number         in out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                         Reqd     Type     Description
--  p_cwb_matrix_dtl_id            Yes     number    PK of record
--  p_object_version_number        Yes     number    OVN of record
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (p_cwb_matrix_dtl_id             in     number
  ,p_object_version_number         in     number
  );
--
end ben_cwb_matrix_dtl_api;

/
