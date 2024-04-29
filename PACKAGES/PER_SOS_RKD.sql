--------------------------------------------------------
--  DDL for Package PER_SOS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOS_RKD" AUTHID CURRENT_USER as
/* $Header: pesosrhi.pkh 120.0 2005/05/31 21:24:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_solution_id                  in number
  ,p_solution_set_name            in varchar2
  ,p_user_id                      in number
  ,p_object_version_number_o      in number
  );
--
end per_sos_rkd;

 

/
