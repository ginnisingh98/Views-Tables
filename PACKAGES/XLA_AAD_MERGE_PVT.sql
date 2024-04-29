--------------------------------------------------------
--  DDL for Package XLA_AAD_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AAD_MERGE_PVT" AUTHID CURRENT_USER AS
/* $Header: xlaalmer.pkh 120.1 2006/06/28 19:35:43 wychan noship $ */

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--=============================================================================
--
-- Name: merge
-- Description: This API merge the AADs and its components from the
--              staging area to the working area of an AMB context
--
--=============================================================================
PROCEDURE merge
(p_api_version          IN NUMBER
,x_return_status        IN OUT NOCOPY VARCHAR2
,p_application_id       IN INTEGER
,p_amb_context_code     IN VARCHAR2
,p_staging_context_code IN VARCHAR2
,p_analyzed_flag        IN VARCHAR2
,p_compile_flag         IN VARCHAR2
,x_merge_status         IN OUT NOCOPY VARCHAR2);

PROCEDURE merge
(p_api_version        IN NUMBER
,x_return_status      IN OUT NOCOPY VARCHAR2
,p_application_id     IN INTEGER
,p_amb_context_code   IN VARCHAR2
,p_analyzed_flag      IN VARCHAR2
,p_compile_flag       IN VARCHAR2
,x_merge_status       IN OUT NOCOPY VARCHAR2);

END xla_aad_merge_pvt;
 

/
