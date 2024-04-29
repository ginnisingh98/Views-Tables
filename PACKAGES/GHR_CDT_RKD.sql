--------------------------------------------------------
--  DDL for Package GHR_CDT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CDT_RKD" AUTHID CURRENT_USER as
/* $Header: ghcdtrhi.pkh 120.0 2005/05/29 02:51:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_compl_ca_detail_id           in number
  ,p_compl_ca_header_id_o         in number
  --,p_action_o                     in varchar2
  ,p_amount_o                     in number
  ,p_order_date_o                 in date
  ,p_due_date_o                   in date
  ,p_request_date_o               in date
  ,p_complete_date_o              in date
  ,p_category_o                   in varchar2
  --,p_type_o                       in varchar2
  ,p_phase_o                      in varchar2
  ,p_action_type_o                in varchar2
  ,p_payment_type_o               in varchar2
  ,p_object_version_number_o      in number
  ,p_description_o                in varchar2
  );
--
end ghr_cdt_rkd;

 

/
