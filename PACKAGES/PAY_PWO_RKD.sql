--------------------------------------------------------
--  DDL for Package PAY_PWO_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PWO_RKD" AUTHID CURRENT_USER as
/* $Header: pypworhi.pkh 120.0 2005/05/29 08:07:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_occupation_id                  in number
 ,p_business_group_id_o            in number
 ,p_rate_id_o                      in number
 ,p_job_id_o                       in number
 ,p_comments_o                     in long
 ,p_object_version_number_o        in number
  );
--
end pay_pwo_rkd;

 

/
