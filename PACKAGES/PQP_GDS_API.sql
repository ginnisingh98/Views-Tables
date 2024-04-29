--------------------------------------------------------
--  DDL for Package PQP_GDS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GDS_API" AUTHID CURRENT_USER as
/* $Header: pqgdsapi.pkh 120.0 2005/10/28 07:31 rvishwan noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_duration_summary >--------------------------|
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
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}




--
procedure create_duration_summary
 (p_validate                          IN  BOOLEAN DEFAULT FALSE
 ,p_date_start                        IN  DATE
 ,p_date_end                          IN  DATE
 ,p_assignment_id                     IN  NUMBER
 ,p_gap_absence_plan_id               IN  NUMBER
 ,p_duration_in_days                  IN  NUMBER
 ,p_duration_in_hours                 IN  NUMBER
 ,p_summary_type                      IN  VARCHAR2
 ,p_gap_level                         IN  VARCHAR2
 ,p_gap_duration_summary_id  OUT NOCOPY NUMBER
 ,p_object_version_number          OUT NOCOPY NUMBER
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_duration_summary >------------------|
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
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_duration_summary
 (p_validate                          IN  BOOLEAN DEFAULT FALSE
 ,p_gap_duration_summary_id     IN  NUMBER
 ,p_date_start                        IN  DATE
 ,p_date_end                          IN  DATE
 ,p_assignment_id                     IN  NUMBER
 ,p_gap_absence_plan_id               IN  NUMBER
 ,p_duration_in_days                  IN  NUMBER
 ,p_duration_in_hours                 IN  NUMBER
 ,p_summary_type                      IN  VARCHAR2
 ,p_gap_level                         IN  VARCHAR2
 ,p_object_version_number          IN OUT NOCOPY NUMBER
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_duration_summary >--------------------------|
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
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_duration_summary
 (p_validate                          IN  BOOLEAN DEFAULT FALSE
 ,p_gap_duration_summary_id     IN  NUMBER
 ,p_object_version_number             IN  NUMBER
  );
--
end pqp_gds_api;

 

/
