--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_INCIDENTS_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_INCIDENTS_BK_1" AUTHID CURRENT_USER as
/* $Header: ghcinapi.pkh 120.1 2005/10/02 01:57:31 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_compl_incident_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_compl_incident_b
  (p_effective_date               in date
  ,p_compl_claim_id               in number
  ,p_incident_date                in date
  ,p_description                  in varchar2
  ,p_date_amended                 in date
  ,p_date_acknowledged            in date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_compl_incident_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_compl_incident_a
  (p_effective_date               in date
  ,p_compl_claim_id               in number
  ,p_incident_date                in date
  ,p_description                  in varchar2
  ,p_date_amended                 in date
  ,p_date_acknowledged            in date
  ,p_compl_incident_id            in number
  ,p_object_version_number        in number
  );
--
end ghr_complaint_incidents_bk_1;

 

/
