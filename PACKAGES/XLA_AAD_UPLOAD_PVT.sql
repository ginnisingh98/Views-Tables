--------------------------------------------------------
--  DDL for Package XLA_AAD_UPLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AAD_UPLOAD_PVT" AUTHID CURRENT_USER AS
/* $Header: xlaalupl.pkh 120.3 2005/09/10 00:07:15 wychan noship $ */

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--=============================================================================
--
-- Name: upload
-- Description: This API upload the AADs and its component from the data file
--              to the staging area of the AMB context
--
--=============================================================================
PROCEDURE upload
(p_api_version           IN NUMBER
,x_return_status         IN OUT NOCOPY VARCHAR2
,p_application_id        IN INTEGER
,p_source_pathname       IN VARCHAR2
,p_amb_context_code      IN VARCHAR2
,x_upload_status         IN OUT NOCOPY VARCHAR2);

--=============================================================================
--
-- Name: post_upload
-- Description: This API is called only if FNDLOAD is not run as part of the
--              report
--
--=============================================================================
FUNCTION post_upload
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_staging_context_code  IN VARCHAR2)
RETURN VARCHAR2;

END xla_aad_upload_pvt;
 

/
