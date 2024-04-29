--------------------------------------------------------
--  DDL for Package XLA_AAD_INSTALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AAD_INSTALL_PVT" AUTHID CURRENT_USER AS
/* $Header: xlainaad.pkh 120.0 2006/06/28 19:37:24 wychan noship $ */

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

PROCEDURE pre_import
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,x_return_status         IN OUT NOCOPY VARCHAR2);

PROCEDURE post_import
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_import_mode           IN VARCHAR2
,p_force_overwrite       IN VARCHAR2
,x_return_status         IN OUT NOCOPY VARCHAR2);

PROCEDURE pre_export
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_versioning_mode       IN VARCHAR2
,p_user_version          IN VARCHAR2
,p_version_comment       IN VARCHAR2
,x_return_status         IN OUT NOCOPY VARCHAR2);

END xla_aad_install_pvt;
 

/
