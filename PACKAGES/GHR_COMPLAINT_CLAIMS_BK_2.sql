--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_CLAIMS_BK_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_CLAIMS_BK_2" AUTHID CURRENT_USER as
/* $Header: ghcclapi.pkh 120.1 2005/10/02 01:57:22 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_compl_claim_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_compl_claim_b
  (p_effective_date               in     date
  ,p_complaint_id                 in     number
  ,p_claim                        in     varchar2
  ,p_incident_date                in     date
  ,p_phase                        in     varchar2
  ,p_mixed_flag                   in     varchar2
  ,p_claim_source                 in     varchar2
  ,p_agency_acceptance            in     varchar2
  ,p_aj_acceptance                in     varchar2
  ,p_agency_appeal                in     varchar2
  ,p_compl_claim_id               in     number
  ,p_object_version_number        in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <BUS_PROCESS_NAME>_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_compl_claim_a
  (p_effective_date               in     date
  ,p_complaint_id                 in     number
  ,p_claim                        in     varchar2
  ,p_incident_date                in     date
  ,p_phase                        in     varchar2
  ,p_mixed_flag                   in     varchar2
  ,p_claim_source                 in     varchar2
  ,p_agency_acceptance            in     varchar2
  ,p_aj_acceptance                in     varchar2
  ,p_agency_appeal                in     varchar2
  ,p_compl_claim_id               in     number
  ,p_object_version_number        in     number
  );
--
end ghr_complaint_claims_bk_2;

 

/
