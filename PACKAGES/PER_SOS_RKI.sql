--------------------------------------------------------
--  DDL for Package PER_SOS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOS_RKI" AUTHID CURRENT_USER as
/* $Header: pesosrhi.pkh 120.0 2005/05/31 21:24:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_solution_id                  in number
  ,p_solution_set_name            in varchar2
  ,p_user_id                      in number
  ,p_object_version_number        in number
  );
end per_sos_rki;

 

/
