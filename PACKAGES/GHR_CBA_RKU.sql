--------------------------------------------------------
--  DDL for Package GHR_CBA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CBA_RKU" AUTHID CURRENT_USER as
/* $Header: ghcbarhi.pkh 120.0 2005/05/29 02:49:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_compl_basis_id               in number
  ,p_compl_claim_id               in number
  ,p_basis                        in varchar2
  ,p_value                        in varchar2
  ,p_statute                      in varchar2
  ,p_agency_finding               in varchar2
  ,p_aj_finding                   in varchar2
  ,p_object_version_number        in number
  ,p_compl_claim_id_o             in number
  ,p_basis_o                      in varchar2
  ,p_value_o                      in varchar2
  ,p_statute_o                    in varchar2
  ,p_agency_finding_o             in varchar2
  ,p_aj_finding_o                 in varchar2
  ,p_object_version_number_o      in number
  );
--
end ghr_cba_rku;


 

/
