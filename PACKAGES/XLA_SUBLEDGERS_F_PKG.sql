--------------------------------------------------------
--  DDL for Package XLA_SUBLEDGERS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_SUBLEDGERS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatbapp.pkh 120.9.12010000.2 2009/12/28 09:19:54 vkasina ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_subledgers                                                     |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_subledgers                            |
|                                                                       |
| HISTORY                                                               |
|   08/06/02  W Chan        Created                                     |
|   09/05/04  W Chan        Add load_row API to be used by FNDLOAD      |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            	IN OUT NOCOPY VARCHAR2
  ,x_application_id                   	IN NUMBER
  ,x_application_type_code              IN VARCHAR2
  ,x_je_source_name			IN VARCHAR2
  ,x_valuation_method_flag		IN VARCHAR2
  ,x_drilldown_procedure_name		IN VARCHAR2
  ,x_security_function_name		IN VARCHAR2
--  ,x_control_account_enabled_flag	IN VARCHAR2
--  ,x_control_account_source_code	IN VARCHAR2
--  ,x_default_party_type_code		IN VARCHAR2
  ,x_control_account_type_code  	IN VARCHAR2
  ,x_alc_enabled_flag			IN VARCHAR2
  ,x_creation_date                    	IN DATE
  ,x_created_by                       	IN NUMBER
  ,x_last_update_date                 	IN DATE
  ,x_last_updated_by                  	IN NUMBER
  ,x_last_update_login                	IN NUMBER);

PROCEDURE lock_row
  (x_application_id                     IN NUMBER
  ,x_application_type_code              IN VARCHAR2
  ,x_je_source_name                     IN VARCHAR2
  ,x_valuation_method_flag              IN VARCHAR2
  ,x_drilldown_procedure_name           IN VARCHAR2
  ,x_security_function_name		IN VARCHAR2
--  ,x_control_account_enabled_flag	IN VARCHAR2
--  ,x_control_account_source_code	IN VARCHAR2
--  ,x_default_party_type_code		IN VARCHAR2
  ,x_control_account_type_code  	IN VARCHAR2
  ,x_alc_enabled_flag			IN VARCHAR2);

PROCEDURE update_row
  (x_application_id                     IN NUMBER
  ,x_application_type_code              IN VARCHAR2 DEFAULT NULL
  ,x_je_source_name                     IN VARCHAR2
  ,x_valuation_method_flag              IN VARCHAR2
  ,x_drilldown_procedure_name           IN VARCHAR2
  ,x_security_function_name		IN VARCHAR2
--  ,x_control_account_enabled_flag	IN VARCHAR2
--  ,x_control_account_source_code	IN VARCHAR2
--  ,x_default_party_type_code		IN VARCHAR2
  ,x_control_account_type_code  	IN VARCHAR2
  ,x_alc_enabled_flag			IN VARCHAR2
  ,x_last_update_date                   IN DATE
  ,x_last_updated_by                    IN NUMBER
  ,x_last_update_login                  IN NUMBER);

PROCEDURE delete_row
 (x_application_id                   IN NUMBER);

PROCEDURE load_row
(p_application_short_name                   IN VARCHAR2
,p_je_source_name                           IN VARCHAR2
,p_valuation_method_flag                    IN VARCHAR2
,p_drilldown_procedure_name                 IN VARCHAR2
,p_security_function_name                   IN VARCHAR2
,p_application_type_code                    IN VARCHAR2
--,p_control_account_enabled_flag             IN VARCHAR2
--,p_default_party_type_code                  IN VARCHAR2
,p_alc_enabled_flag                         IN VARCHAR2
  ,p_control_account_type_code              IN VARCHAR2
,p_owner                                    IN VARCHAR2
,p_last_update_date                         IN VARCHAR2);

END xla_subledgers_f_pkg;

/
