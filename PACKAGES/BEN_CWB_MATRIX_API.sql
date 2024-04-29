--------------------------------------------------------
--  DDL for Package BEN_CWB_MATRIX_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_MATRIX_API" AUTHID CURRENT_USER as
/* $Header: bebcmapi.pkh 120.0.12010000.1 2008/07/29 10:53:45 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_cwb_matrix >---------------------------|
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
--   Name                         Reqd    Type     Description
--  p_validate                     No     boolean   Commit or Rollback.
--  p_effective_date               No     date      Session Date
--  p_business_group_id            Yes    number    Business Group of Record
--  p_name                         Yes    varchar2  Name of the Matrix
--  p_person_id                    No     number    Person Id
--  p_sheet_type                   Yes    varchar2  Sheet Type
--  p_plan_id                      No     number    Plan Id
--  p_row_crit_cd                  Yes    varchar2  Row Criterion Code
--  p_col_crit_cd                  No     varchar2  Column Criterion Code
--
-- Post Success:
--
--  Out Parameters:
--   Name                                 Type     Description
--  p_cwb_matrix_id                        number   PK of record
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
procedure create_cwb_matrix
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_name                          in     varchar2
  ,p_plan_id                       in     number   default null
  ,p_matrix_typ_cd                 in     varchar2 default null
  ,p_person_id                     in     number   default null
  ,p_row_crit_cd                   in     varchar2
  ,p_col_crit_cd                   in     varchar2 default null
  ,p_alct_by_cd                    in     varchar2 default 'PCT'
  ,p_cwb_matrix_id                 out nocopy    number
  ,p_object_version_number         out nocopy    number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_cwb_matrix >--------------------------|
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
--  p_validate                     No      boolean   Commit or Rollback.
--  p_cwb_matrix_id                Yes     number    PK of record
--  p_effective_date               No      date      Session Date
--  p_business_group_id            Yes     number    Business Group of Record
--  p_name                         Yes     varchar2  Name of the Matrix
--  p_person_id                    No      number    Person Id
--  p_matrix_typ_cd                   Yes     varchar2  Sheet Type
--  p_plan_id                      No      number    Plan Id
--  p_row_crit_cd                  Yes     varchar2  Row Criterion Code
--  p_col_crit_cd                  No      varchar2  Column Criterion Code
--
-- Post Success:
--
--  Out Parameters:
--   Name                                 Type     Description
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
procedure update_cwb_matrix
  (p_validate                      in     boolean  default false
  ,p_cwb_matrix_id                 in     number
  ,p_effective_date                in     date
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_plan_id                       in     number   default hr_api.g_number
  ,p_matrix_typ_cd                 in     varchar2 default hr_api.g_varchar2
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_row_crit_cd                   in     varchar2 default hr_api.g_varchar2
  ,p_col_crit_cd                   in     varchar2 default hr_api.g_varchar2
  ,p_alct_by_cd                    in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_cwb_matrix >---------------------------|
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
--  p_validate                     No      boolean   Commit or Rollback.
--  p_cwb_matrix_id                Yes     number    PK of record
--  p_effective_date               No      date      Session Date
--
-- Post Success:
--
--  Out Parameters:
--   Name                                 Type     Description
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
procedure delete_cwb_matrix
  (p_validate                      in     boolean  default false
  ,p_cwb_matrix_id                 in     number
  ,p_effective_date                in     date
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
--  p_cwb_matrix_id                Yes     number    PK of record
--  p_object_version_number        Yes     number    OVN of record
--  p_effective_date               No      date      Session Date
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
  (p_cwb_matrix_id                 in     number
  ,p_effective_date                in     date
  ,p_object_version_number         in     number
  );
--
end ben_cwb_matrix_api;

/
