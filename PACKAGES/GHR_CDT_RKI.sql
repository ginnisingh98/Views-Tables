--------------------------------------------------------
--  DDL for Package GHR_CDT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CDT_RKI" AUTHID CURRENT_USER as
/* $Header: ghcdtrhi.pkh 120.0 2005/05/29 02:51:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_compl_ca_detail_id           in number
  ,p_compl_ca_header_id           in number
  --,p_action                       in varchar2
  ,p_amount                       in number
  ,p_order_date                   in date
  ,p_due_date                     in date
  ,p_request_date                 in date
  ,p_complete_date                in date
  ,p_category                     in varchar2
  --,p_type                         in varchar2
  ,p_phase                        in varchar2
  ,p_action_type                  in varchar2
  ,p_payment_type                 in varchar2
  ,p_object_version_number        in number
  ,p_description                  in varchar2
  );
end ghr_cdt_rki;

 

/
