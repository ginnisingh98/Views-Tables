--------------------------------------------------------
--  DDL for Package OZF_MULTI_CURR_MIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_MULTI_CURR_MIG_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvmmcs.pls 120.1.12010000.2 2010/03/03 07:43:45 nepanda ship $ */

  --
  --
  -- Start of Comments
  --
  -- NAME
  --   ozf_multi_curr_mig_pvt
  --
  -- PURPOSE
  --   This package contains migration related code for sales team.
  --
  -- NOTES
  --
  -- HISTORY
  -- nirprasa      10/22/2009           Created
  -- **********************************************************************************************************


--
--

PROCEDURE Mig_Utilization_Records (x_errbuf OUT NOCOPY VARCHAR2,
                                   x_retcode OUT NOCOPY NUMBER,
				   p_debug_flag IN VARCHAR2);
FUNCTION get_functional_curr (p_org_id  NUMBER) RETURN VARCHAR2;

END ozf_multi_curr_mig_pvt;

/
