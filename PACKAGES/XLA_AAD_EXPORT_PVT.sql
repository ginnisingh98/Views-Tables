--------------------------------------------------------
--  DDL for Package XLA_AAD_EXPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AAD_EXPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: xlaalexp.pkh 120.3 2006/05/04 18:57:04 wychan noship $ */

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--=============================================================================
--
-- Name: export
-- Description: This API exports the AADs and the components from the AMB
--              context to the data file
--
--=============================================================================
PROCEDURE export
(p_api_version          IN NUMBER
,x_return_status        IN OUT NOCOPY VARCHAR2
,p_application_id       IN VARCHAR2
,p_amb_context_code     IN VARCHAR2
,p_destination_pathname IN VARCHAR2
,p_versioning_mode      IN VARCHAR2
,p_user_version         IN VARCHAR2
,p_version_comment      IN VARCHAR2
,x_export_status        IN OUT NOCOPY VARCHAR2);

--=============================================================================
--
-- Name: pre_export
-- Description: This API
--
--=============================================================================
FUNCTION pre_export
(p_application_id   IN INTEGER
,p_amb_context_code IN VARCHAR2
,p_versioning_mode  IN VARCHAR2
,p_user_version     IN VARCHAR2
,p_version_comment  IN VARCHAR2
,p_owner_type       IN VARCHAR2)
RETURN VARCHAR2;

END xla_aad_export_pvt;
 

/
