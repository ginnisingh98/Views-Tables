--------------------------------------------------------
--  DDL for Package PQH_VLE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_VLE_RKI" AUTHID CURRENT_USER as
/* $Header: pqvlerhi.pkh 120.0 2005/05/29 02:55:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_event_id          in number
  ,p_validation_id                in number
  ,p_event_type                   in varchar2
  ,p_event_code                   in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_comments                     in varchar2
  ,p_object_version_number        in number
  );
end pqh_vle_rki;

 

/
