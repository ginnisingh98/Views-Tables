--------------------------------------------------------
--  DDL for Package PAY_PWO_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PWO_RKI" AUTHID CURRENT_USER as
/* $Header: pypworhi.pkh 120.0 2005/05/29 08:07:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_occupation_id                  in number
 ,p_business_group_id              in number
 ,p_rate_id                        in number
 ,p_job_id                         in number
 ,p_comments                       in long
 ,p_object_version_number          in number
  );
end pay_pwo_rki;

 

/
