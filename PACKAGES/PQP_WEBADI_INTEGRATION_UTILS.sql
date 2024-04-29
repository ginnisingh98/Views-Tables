--------------------------------------------------------
--  DDL for Package PQP_WEBADI_INTEGRATION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_WEBADI_INTEGRATION_UTILS" AUTHID CURRENT_USER AS
/* $Header: pqwadiut.pkh 115.1 2003/02/17 00:06:06 ashgupta noship $ */

--  For the given content, update the content with this parameter list.
--  Required for all Contents to be used from Forms.
--
--
-- ------------------------------------------------------------------------
-- | -----------------< register_integrator_to_form >---------------------|
-- ------------------------------------------------------------------------
--
-- Description:
--
--  Takes an integrator id, and a form name, and registers the integrator
--  for use on that form.
--  The param list for the form MUST exist.
--
-- ------------------------------------------------------------------------
PROCEDURE webadi_meta_data_info(p_application_id        IN  NUMBER
                               ,p_caller_identifier     IN  VARCHAR2
                               ,p_integrator_code       OUT NOCOPY VARCHAR2
                               ,p_layout_code           OUT NOCOPY VARCHAR2
                               ,p_supported_spreasheet  OUT NOCOPY VARCHAR2
                               );
END pqp_webadi_integration_utils;

 

/
