--------------------------------------------------------
--  DDL for Package PQH_JOB_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_JOB_RKI" AUTHID CURRENT_USER as
/* $Header: pqwvjrhi.pkh 120.0 2005/05/29 03:05:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_wrkplc_vldtn_job_id          in number
  ,p_wrkplc_vldtn_op_id           in number
  ,p_wrkplc_job_id                in number
  ,p_description                  in varchar2
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  );
end pqh_job_rki;

 

/
