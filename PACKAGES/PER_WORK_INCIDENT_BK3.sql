--------------------------------------------------------
--  DDL for Package PER_WORK_INCIDENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_WORK_INCIDENT_BK3" AUTHID CURRENT_USER as
/* $Header: peincapi.pkh 120.1 2005/10/02 02:17:38 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_work_incident_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_work_incident_b
  (p_incident_id                   in      number
  ,p_object_version_number         in      number
  );
--
-- delete_location_extra_info_a
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_work_incident_a >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_work_incident_a
  (p_incident_id                   in      number
  ,p_object_version_number         in      number
  );

end per_work_incident_bk3;

 

/
