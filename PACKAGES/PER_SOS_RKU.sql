--------------------------------------------------------
--  DDL for Package PER_SOS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOS_RKU" AUTHID CURRENT_USER as
/* $Header: pesosrhi.pkh 120.0 2005/05/31 21:24:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_solution_id                  in number
  ,p_solution_set_name            in varchar2
  ,p_user_id                      in number
  ,p_object_version_number        in number
  ,p_object_version_number_o      in number
  );
--
end per_sos_rku;

 

/
