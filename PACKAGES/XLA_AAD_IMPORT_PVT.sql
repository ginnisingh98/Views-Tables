--------------------------------------------------------
--  DDL for Package XLA_AAD_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AAD_IMPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: xlaalimp.pkh 120.4 2005/09/10 00:06:24 wychan noship $ */

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--=============================================================================
--
-- Name: import
-- Description: This API imports the AADs and the components from the data file
--              to the staging area of an AMB context
--
--=============================================================================
PROCEDURE import
(p_api_version           IN NUMBER
,x_return_status         IN OUT NOCOPY VARCHAR2
,p_application_id        IN INTEGER
,p_source_pathname       IN VARCHAR2
,p_amb_context_code      IN VARCHAR2
,x_import_status         IN OUT NOCOPY VARCHAR2);

--=============================================================================
--
-- Name: pre_import
-- Description: This API
--
--=============================================================================
FUNCTION pre_import
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_staging_context_code  IN VARCHAR2)
RETURN VARCHAR2;

--=============================================================================
--
-- Name: post_import
-- Description: This API
--
--=============================================================================
PROCEDURE post_import
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_staging_context_code  IN VARCHAR2);

END xla_aad_import_pvt;
 

/
