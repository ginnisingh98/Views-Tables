--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_INCIDENTS_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_INCIDENTS_BK_3" AUTHID CURRENT_USER as
/* $Header: ghcinapi.pkh 120.1 2005/10/02 01:57:31 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_compl_incident_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_compl_incident_b
  (p_compl_incident_id            in number
  ,p_object_version_number        in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_compl_incident_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_compl_incident_a
  (p_compl_incident_id            in number
  ,p_object_version_number        in number
  );
--
end ghr_complaint_incidents_bk_3;

 

/
