--------------------------------------------------------
--  DDL for Package MTL_BILLING_HEADER_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_BILLING_HEADER_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: INVBHDRS.pls 120.0.12010000.2 2010/03/26 05:06:32 damahaja noship $ */

procedure INSERT_ROW(
       x_billing_rule_header_id IN NUMBER ,
       x_name IN VARCHAR2 ,
       x_description IN VARCHAR2 ,
       x_service_agreement IN VARCHAR2 ,
       x_service_agreement_id IN NUMBER ,
       x_start_date IN DATE ,
       x_end_date IN DATE ,
       x_creation_date IN DATE ,
       x_created_by IN NUMBER,
       x_last_update_date IN DATE,
       x_last_updated_by IN NUMBER ,
       x_last_update_login IN NUMBER
);

procedure LOCK_ROW(
      x_billing_rule_header_id IN NUMBER ,
       x_name IN VARCHAR2 ,
       x_description IN VARCHAR2 ,
       x_service_agreement IN VARCHAR2 ,
       x_service_agreement_id IN NUMBER ,
       x_start_date IN DATE ,
       x_end_date IN DATE ,
       x_creation_date IN DATE ,
       x_created_by IN NUMBER,
       x_last_update_date IN DATE,
       x_last_updated_by IN NUMBER ,
       x_last_update_login IN NUMBER
);

procedure UPDATE_ROW(
      x_billing_rule_header_id IN NUMBER ,
       x_name IN VARCHAR2 ,
       x_description IN VARCHAR2 ,
       x_service_agreement IN VARCHAR2 ,
       x_service_agreement_id IN NUMBER ,
       x_start_date IN DATE ,
       x_end_date IN DATE ,
       x_creation_date IN DATE ,
       x_created_by IN NUMBER,
       x_last_update_date IN DATE,
       x_last_updated_by IN NUMBER ,
       x_last_update_login IN NUMBER
);



 procedure DELETE_ROW (
  x_billing_rule_header_id in NUMBER);

    /* Added following procedure for bug 9447716 */
    procedure ADD_LANGUAGE;


end mtl_billing_header_rules_pkg;

/
