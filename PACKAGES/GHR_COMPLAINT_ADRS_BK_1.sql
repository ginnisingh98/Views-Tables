--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_ADRS_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_ADRS_BK_1" AUTHID CURRENT_USER as
/* $Header: ghcadapi.pkh 120.1 2005/10/02 01:57:04 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Create_compl_adr_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_compl_adr_b
  (p_effective_date                 in     date
  ,p_complaint_id                   in     number
  ,p_stage                          in     varchar2
  ,p_start_date                     in     date
  ,p_end_date                       in     date
  ,p_adr_resource                   in     varchar2
  ,p_technique                      in     varchar2
  ,p_outcome                        in     varchar2
  ,p_adr_offered                    in     varchar2
  ,p_date_accepted                  in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Create_compl_adr_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_compl_adr_a
  (p_effective_date                in     date
  ,p_complaint_id                  in     number
  ,p_stage                         in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_adr_resource                  in     varchar2
  ,p_technique                     in     varchar2
  ,p_outcome                       in     varchar2
  ,p_adr_offered                   in     varchar2
  ,p_date_accepted                 in     date
  ,p_compl_adr_id                  in     number
  ,p_object_version_number         in     number
  );
--
end ghr_complaint_adrs_bk_1;

 

/
