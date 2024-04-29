--------------------------------------------------------
--  DDL for Package PQH_JOB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_JOB_RKD" AUTHID CURRENT_USER as
/* $Header: pqwvjrhi.pkh 120.0 2005/05/29 03:05:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_wrkplc_vldtn_job_id          in number
  ,p_wrkplc_vldtn_op_id_o         in number
  ,p_wrkplc_job_id_o              in number
  ,p_description_o                in varchar2
  ,p_business_group_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end pqh_job_rkd;

 

/