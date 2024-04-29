--------------------------------------------------------
--  DDL for Package PER_SEU_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SEU_RKU" AUTHID CURRENT_USER as
/* $Header: peseurhi.pkh 120.3 2005/11/08 16:30:29 vbanner noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_security_user_id             in number
  ,p_user_id                      in number
  ,p_security_profile_id          in number
  ,p_process_in_next_run_flag     in varchar2 -- vik
  ,p_object_version_number        in number
  ,p_user_id_o                    in number
  ,p_security_profile_id_o        in number
  ,p_process_in_next_run_flag_o   in varchar2 -- vik
  ,p_object_version_number_o      in number
  ,p_del_static_lists_warning     in boolean
  );
--
end per_seu_rku;

 

/
