--------------------------------------------------------
--  DDL for Package PAY_PWO_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PWO_RKU" AUTHID CURRENT_USER as
/* $Header: pypworhi.pkh 120.0 2005/05/29 08:07:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_occupation_id                  in number
 ,p_business_group_id              in number
 ,p_rate_id                        in number
 ,p_job_id                         in number
 ,p_comments                       in long
 ,p_object_version_number          in number
 ,p_business_group_id_o            in number
 ,p_rate_id_o                      in number
 ,p_job_id_o                       in number
 ,p_comments_o                     in long
 ,p_object_version_number_o        in number
  );
--
end pay_pwo_rku;

 

/
