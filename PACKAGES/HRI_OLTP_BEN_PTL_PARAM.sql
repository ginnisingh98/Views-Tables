--------------------------------------------------------
--  DDL for Package HRI_OLTP_BEN_PTL_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_BEN_PTL_PARAM" AUTHID CURRENT_USER AS
/* $Header: hriopprmben.pkh 120.0 2005/09/21 01:27:30 anmajumd noship $ */

--
-- ----------------------------------------------------------------------------
-- |-------------------< GET_OES_DASHBOARD_PARAMS >---------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION GET_OES_DASHBOARD_PARAMS
   RETURN VARCHAR2;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< GET_PGM_DIMENSION >------------------------------|
-- ----------------------------------------------------------------------------
--
-- This function will return PGM_ID for default program. This ID will be used
-- to default the Program Dimension on all of the four standalone reports.
--
FUNCTION GET_PGM_DIMENSION
   RETURN VARCHAR2;
--
--
END hri_oltp_ben_ptl_param;

 

/
