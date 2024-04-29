--------------------------------------------------------
--  DDL for Package XLA_AAD_LOADER_INSTALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AAD_LOADER_INSTALL_PVT" AUTHID CURRENT_USER AS
/* $Header: xlaalins.pkh 120.0 2006/06/29 02:25:35 wychan noship $ */

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

PROCEDURE pre_export
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_versioning_mode       IN VARCHAR2
,p_user_version          IN VARCHAR2
,p_version_comment       IN VARCHAR2
,x_return_status         IN OUT NOCOPY VARCHAR2);

FUNCTION get_segment
(p_chart_of_accounts_id  INTEGER
,p_code_combination_id   INTEGER
,p_segment_num           INTEGER)
RETURN VARCHAR2;

END xla_aad_loader_install_pvt;
 

/
