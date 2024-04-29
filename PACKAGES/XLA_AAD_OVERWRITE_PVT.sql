--------------------------------------------------------
--  DDL for Package XLA_AAD_OVERWRITE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AAD_OVERWRITE_PVT" AUTHID CURRENT_USER AS
/* $Header: xlaalovw.pkh 120.2 2006/06/28 19:36:07 wychan noship $ */

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--=============================================================================
--
-- Name: overwrite
-- Description: This API overwrites the AADs and its components from the
--              staging area to the working area of an AMB context
--
--=============================================================================
PROCEDURE overwrite
(p_api_version          IN NUMBER
,x_return_status        IN OUT NOCOPY VARCHAR2
,p_application_id       IN INTEGER
,p_amb_context_code     IN VARCHAR2
,p_staging_context_code IN VARCHAR2
,p_force_flag           IN VARCHAR2
,p_compile_flag         IN VARCHAR2
,x_overwrite_status     IN OUT NOCOPY VARCHAR2);

PROCEDURE overwrite
(p_api_version        IN NUMBER
,x_return_status      IN OUT NOCOPY VARCHAR2
,p_application_id     IN INTEGER
,p_amb_context_code   IN VARCHAR2
,p_force_flag         IN VARCHAR2
,p_compile_flag       IN VARCHAR2
,x_overwrite_status   IN OUT NOCOPY VARCHAR2);

END xla_aad_overwrite_pvt;
 

/
