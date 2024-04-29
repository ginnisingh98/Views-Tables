--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_BASES_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_BASES_BK_1" AUTHID CURRENT_USER as
/* $Header: ghcbaapi.pkh 120.1 2005/10/02 01:57:14 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_compl_basis_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_compl_basis_b
  (p_effective_date               in date
  ,p_compl_claim_id               in number
  ,p_basis                        in varchar2
  ,p_value                        in varchar2
  ,p_statute                      in varchar2
  ,p_agency_finding               in varchar2
  ,p_aj_finding                   in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_compl_basis_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_compl_basis_a
  (p_effective_date               in date
  ,p_compl_claim_id               in number
  ,p_basis                        in varchar2
  ,p_value                        in varchar2
  ,p_statute                      in varchar2
  ,p_agency_finding               in varchar2
  ,p_aj_finding                   in varchar2
  ,p_compl_basis_id               in number
  ,p_object_version_number        in number
  );
--
end ghr_complaint_bases_bk_1;

 

/