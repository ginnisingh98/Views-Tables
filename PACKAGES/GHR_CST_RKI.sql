--------------------------------------------------------
--  DDL for Package GHR_CST_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CST_RKI" AUTHID CURRENT_USER as
/* $Header: ghcstrhi.pkh 120.0 2005/05/29 03:05:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date                in date
  ,p_compl_agency_cost_id         in number
  ,p_complaint_id                  in number
  ,p_phase                         in varchar2
  ,p_stage                         in varchar2
  ,p_category                      in varchar2
  ,p_amount                        in number
  ,p_cost_date                     in date
  ,p_description                   in varchar2
  ,p_object_version_number         in number
  );
end ghr_cst_rki;

 

/
