--------------------------------------------------------
--  DDL for Package HXC_HTR_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HTR_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxchtrupl.pkh 120.0 2005/05/29 05:44:03 appldev noship $ */

PROCEDURE load_time_recipient_row (
          p_name                            IN VARCHAR2
	, p_owner		            IN VARCHAR2
	, p_application_name	            IN VARCHAR2
	, p_custom_mode		            IN VARCHAR2
        , p_appl_retrieval_function         IN VARCHAR2
        , p_appl_update_process             IN VARCHAR2
        , p_appl_validation_process         IN VARCHAR2
        , p_appl_period_function            IN VARCHAR2
        , p_appl_dyn_template_process       IN VARCHAR2
        , p_extension_function1             IN VARCHAR2
        , p_extension_function2             IN VARCHAR2
	,p_last_update_date                 IN VARCHAR2 DEFAULT NULL);

END hxc_htr_upload_pkg;

 

/
