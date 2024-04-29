--------------------------------------------------------
--  DDL for Package Body CN_CUST_AIA_ORD_PROC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CUST_AIA_ORD_PROC_PUB" AS
-- $Header: CNPCPTROMB.pls 120.0.12010000.1 2009/06/05 12:52:05 rajukum noship $


--
-- Procedure Name
--   collect
-- Purpose
--   This procedure do user specific pre-prcessing source data for aia orders
-- History
--
--

  PROCEDURE ct_aia_om_pre_processing (x_return_status out nocopy varchar2 )
  IS

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

  END ct_aia_om_pre_processing;

END CN_CUST_AIA_ORD_PROC_PUB;

/
