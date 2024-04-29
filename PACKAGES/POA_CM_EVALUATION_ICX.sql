--------------------------------------------------------
--  DDL for Package POA_CM_EVALUATION_ICX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_CM_EVALUATION_ICX" AUTHID CURRENT_USER AS
/* $Header: POACMHDS.pls 120.0 2005/06/02 01:40:14 appldev noship $ */

PROCEDURE header_page(poa_cm_custom_measure_code IN VARCHAR2 DEFAULT NULL,
                      poa_cm_custom_measure      IN VARCHAR2 DEFAULT NULL,
                      poa_cm_period_type         IN VARCHAR2 DEFAULT NULL,
                      poa_cm_user_period_type    IN VARCHAR2 DEFAULT NULL,
                      poa_cm_period_name         IN VARCHAR2 DEFAULT NULL,
                      poa_cm_supplier_id         IN VARCHAR2 DEFAULT NULL,
                      poa_cm_supplier            IN VARCHAR2 DEFAULT NULL,
                      poa_cm_supplier_site_id    IN VARCHAR2 DEFAULT NULL,
                      poa_cm_supplier_site       IN VARCHAR2 DEFAULT NULL,
                      poa_cm_category_id         IN VARCHAR2 DEFAULT NULL,
                      poa_cm_commodity           IN VARCHAR2 DEFAULT NULL,
                      poa_cm_item_id             IN VARCHAR2 DEFAULT NULL,
                      poa_cm_item	         IN VARCHAR2 DEFAULT NULL,
                      poa_cm_comments            IN VARCHAR2 DEFAULT NULL,
                      poa_cm_evaluated_by_id     IN VARCHAR2 DEFAULT NULL,
                      poa_cm_evaluated_by	 IN VARCHAR2 DEFAULT NULL,
                      poa_cm_org_id              IN VARCHAR2 DEFAULT NULL,
                      poa_cm_oper_unit_id        IN VARCHAR2 DEFAULT NULL,
                      poa_cm_operating_unit      IN VARCHAR2 DEFAULT NULL,
		      poa_cm_submit_type	 IN VARCHAR2 DEFAULT NULL,
		      poa_cm_evaluation_id	 IN VARCHAR2 DEFAULT NULL,
                      error_msg                  IN VARCHAR2 DEFAULT NULL
);

END poa_cm_evaluation_icx;
 

/
