--------------------------------------------------------
--  DDL for Package CN_CUST_AIA_ORD_PROC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CUST_AIA_ORD_PROC_PUB" AUTHID CURRENT_USER AS
-- $Header: CNPCPTROMS.pls 120.0.12010000.1 2009/06/02 09:24:16 rajukum noship $


--
-- Procedure Name
--   collect
-- Purpose
--   This procedure do user specific pre-prcessing source data for aia orders
-- History
--
--

  PROCEDURE ct_aia_om_pre_processing (x_return_status out nocopy varchar2 );

END CN_CUST_AIA_ORD_PROC_PUB;

/
