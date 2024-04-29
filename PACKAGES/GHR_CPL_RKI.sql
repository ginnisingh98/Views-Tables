--------------------------------------------------------
--  DDL for Package GHR_CPL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CPL_RKI" AUTHID CURRENT_USER as
/* $Header: ghcplrhi.pkh 120.0 2005/05/29 03:03:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_compl_person_id              in number
  ,p_person_id                    in number
  ,p_complaint_id                 in number
  ,p_role_code                    in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_object_version_number        in number
  );
end ghr_cpl_rki;

 

/
