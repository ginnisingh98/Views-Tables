--------------------------------------------------------
--  DDL for Package XLA_AAD_DOWNLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AAD_DOWNLOAD_PVT" AUTHID CURRENT_USER AS
/* $Header: xlaaldnl.pkh 120.0 2004/08/18 17:33:04 wychan noship $ */

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--=============================================================================
--
-- Name: download
-- Description: This API downloads the AADs and the components from an AMB
--              context to a data file.
--
--=============================================================================
PROCEDURE download
(p_api_version           IN NUMBER
,x_return_status         IN OUT NOCOPY VARCHAR2
,p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_destination_file      IN VARCHAR2
,x_download_status       IN OUT NOCOPY VARCHAR2);

END xla_aad_download_pvt;
 

/
