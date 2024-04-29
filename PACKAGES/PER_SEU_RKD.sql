--------------------------------------------------------
--  DDL for Package PER_SEU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SEU_RKD" AUTHID CURRENT_USER as
/* $Header: peseurhi.pkh 120.3 2005/11/08 16:30:29 vbanner noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_security_user_id             in number
  ,p_user_id_o                    in number
  ,p_security_profile_id_o        in number
  ,p_object_version_number_o      in number
  ,p_del_static_lists_warning     in boolean -- vik and proc in next run?
  );
--
end per_seu_rkd;

 

/
