--------------------------------------------------------
--  DDL for Package BEN_CWB_STOCK_OPTN_DTLS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_STOCK_OPTN_DTLS_BK3" AUTHID CURRENT_USER as
/* $Header: becsoapi.pkh 120.4 2006/10/17 10:30:58 steotia noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_cwb_stock_optn_dtls_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cwb_stock_optn_dtls_b
  (p_effective_date                in     date
  ,p_cwb_stock_optn_dtls_id        in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_cwb_stock_optn_dtls_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cwb_stock_optn_dtls_a
  (p_effective_date                in     date
  ,p_cwb_stock_optn_dtls_id        in     number
  ,p_object_version_number         in     number
  );
--
end BEN_CWB_STOCK_OPTN_DTLS_BK3;

 

/
