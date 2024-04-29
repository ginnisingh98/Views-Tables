--------------------------------------------------------
--  DDL for Package XLA_AAD_MERGE_ANALYSIS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AAD_MERGE_ANALYSIS_PVT" AUTHID CURRENT_USER AS
/* $Header: xlaalman.pkh 120.3 2006/06/28 19:34:15 wychan noship $ */

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--=============================================================================
--
-- Name:
-- Description:
--
--=============================================================================
PROCEDURE analysis
(p_api_version          IN NUMBER
,x_return_status        IN OUT NOCOPY VARCHAR2
,p_application_id       INTEGER
,p_amb_context_code     VARCHAR2
,p_staging_context_code VARCHAR2
,p_batch_name           VARCHAR2
,x_analysis_status      IN OUT NOCOPY VARCHAR2);

PROCEDURE analysis
(p_api_version        IN NUMBER
,x_return_status      IN OUT NOCOPY VARCHAR2
,p_application_id     INTEGER
,p_amb_context_code   VARCHAR2
,p_batch_name         VARCHAR2
,x_analysis_status    IN OUT NOCOPY VARCHAR2);

END xla_aad_merge_analysis_pvt;
 

/
