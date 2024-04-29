--------------------------------------------------------
--  DDL for Package PAY_ORG_PAYMENT_METHOD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ORG_PAYMENT_METHOD_BK3" AUTHID CURRENT_USER as
/* $Header: pyopmapi.pkh 120.5 2005/10/24 00:35:01 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_org_payment_method_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_org_payment_method_b
  (P_EFFECTIVE_DATE                in     date
  ,P_DATETRACK_DELETE_MODE         in     varchar2
  ,P_ORG_PAYMENT_METHOD_ID         in     number
  ,P_OBJECT_VERSION_NUMBER         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_org_payment_method_a >---------------------|
-- ----------------------------------------------------------------------------
--

procedure delete_org_payment_method_a
  (P_EFFECTIVE_DATE                in     date
  ,P_DATETRACK_DELETE_MODE         in     varchar2
  ,P_ORG_PAYMENT_METHOD_ID         in     number
  ,P_OBJECT_VERSION_NUMBER         in     number
  ,P_EFFECTIVE_START_DATE          in     date
  ,P_EFFECTIVE_END_DATE            in     date
  );
--
end pay_org_payment_method_bk3;

 

/
