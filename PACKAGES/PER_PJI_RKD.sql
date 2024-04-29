--------------------------------------------------------
--  DDL for Package PER_PJI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PJI_RKD" AUTHID CURRENT_USER as
/* $Header: pepjirhi.pkh 120.0 2005/05/31 14:22:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_previous_job_extra_info_id   in number
  );
--
end per_pji_rkd;

 

/
