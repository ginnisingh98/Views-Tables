--------------------------------------------------------
--  DDL for Package GHR_CBA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CBA_RKD" AUTHID CURRENT_USER as
/* $Header: ghcbarhi.pkh 120.0 2005/05/29 02:49:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_compl_basis_id               in number
  ,p_compl_claim_id_o             in number
  ,p_basis_o                      in varchar2
  ,p_value_o                      in varchar2
  ,p_statute_o                    in varchar2
  ,p_agency_finding_o             in varchar2
  ,p_aj_finding_o                 in varchar2
  ,p_object_version_number_o      in number
  );
--
end ghr_cba_rkd;

 

/
