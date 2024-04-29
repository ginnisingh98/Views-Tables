--------------------------------------------------------
--  DDL for Package PER_PJU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PJU_RKD" AUTHID CURRENT_USER as
/* $Header: pepjurhi.pkh 120.0 2005/05/31 14:24:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_previous_job_usage_id        in number
  );
--
end per_pju_rkd;

 

/
