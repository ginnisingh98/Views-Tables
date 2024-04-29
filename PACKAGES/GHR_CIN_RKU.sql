--------------------------------------------------------
--  DDL for Package GHR_CIN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CIN_RKU" AUTHID CURRENT_USER as
/* $Header: ghcinrhi.pkh 120.0 2005/05/29 02:52:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_compl_incident_id            in number
  ,p_compl_claim_id               in number
  ,p_incident_date                in date
  ,p_description                  in varchar2
  ,p_date_amended                 in date
  ,p_date_acknowledged            in date
  ,p_object_version_number        in number
  ,p_compl_claim_id_o             in number
  ,p_incident_date_o              in date
  ,p_description_o                in varchar2
  ,p_date_amended_o               in date
  ,p_date_acknowledged_o          in date
  ,p_object_version_number_o      in number
  );
--
end ghr_cin_rku;

 

/
