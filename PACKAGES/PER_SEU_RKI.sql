--------------------------------------------------------
--  DDL for Package PER_SEU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SEU_RKI" AUTHID CURRENT_USER as
/* $Header: peseurhi.pkh 120.3 2005/11/08 16:30:29 vbanner noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_security_user_id             in number
  ,p_user_id                      in number
  ,p_security_profile_id          in number
  ,p_process_in_next_run_flag     in varchar2
  ,p_object_version_number        in number
  );
end per_seu_rki;

 

/
