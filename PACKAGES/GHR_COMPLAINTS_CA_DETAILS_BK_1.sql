--------------------------------------------------------
--  DDL for Package GHR_COMPLAINTS_CA_DETAILS_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINTS_CA_DETAILS_BK_1" AUTHID CURRENT_USER as
/* $Header: ghcdtapi.pkh 120.1 2005/10/02 01:57:27 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ca_detail_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ca_detail_b
  (p_effective_date                 in     date
  ,p_compl_ca_header_id             in     number
  --,p_action                         in     varchar2
  ,p_amount                         in     number
  ,p_order_date                     in     date
  ,p_due_date                       in     date
  ,p_request_date                   in     date
  ,p_complete_date                  in     date
  ,p_category                       in     varchar2
  --,p_type                           in     varchar2
  ,p_phase                          in     varchar2
  ,p_action_type                    in     varchar2
  ,p_payment_type                   in     varchar2
  ,p_description                    in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ca_detail_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ca_detail_a
  (p_effective_date                 in     date
  ,p_compl_ca_header_id             in     number
  --,p_action                         in     varchar2
  ,p_amount                         in     number
  ,p_order_date                     in     date
  ,p_due_date                       in     date
  ,p_request_date                   in     date
  ,p_complete_date                  in     date
  ,p_category                       in     varchar2
  --,p_type                           in     varchar2
  ,p_phase                          in     varchar2
  ,p_action_type                    in     varchar2
  ,p_payment_type                   in     varchar2
  ,p_description                    in     varchar2
  ,p_compl_ca_detail_id             in    number
  ,p_object_version_number          in    number
  );
--
end ghr_complaints_ca_details_bk_1;

 

/
