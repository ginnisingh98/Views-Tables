--------------------------------------------------------
--  DDL for Package MTL_BILLING_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_BILLING_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: INVBLINS.pls 120.0.12010000.3 2010/01/19 12:55:59 damahaja noship $ */

procedure INSERT_ROW(
       x_billing_rule_line_id IN NUMBER ,
       x_billing_rule_header_id IN NUMBER ,
       x_client_code IN VARCHAR2 ,
       x_client_number IN VARCHAR2 ,
       x_service_agreement_line_id IN NUMBER ,
       x_inventory_item_id IN NUMBER ,
       x_billing_source_id IN NUMBER ,
       x_creation_date IN DATE ,
       x_created_by IN NUMBER,
       x_last_update_date IN DATE,
       x_last_updated_by IN NUMBER ,
       x_last_update_login IN NUMBER
);

procedure LOCK_ROW(
       x_billing_rule_line_id IN NUMBER ,
       x_billing_rule_header_id IN NUMBER ,
       x_client_code IN VARCHAR2 ,
       x_client_number IN VARCHAR2 ,
       x_service_agreement_line_id IN NUMBER ,
       x_inventory_item_id IN NUMBER ,
       x_billing_source_id IN NUMBER ,
       x_creation_date IN DATE ,
       x_created_by IN NUMBER,
       x_last_update_date IN DATE,
       x_last_updated_by IN NUMBER ,
       x_last_update_login IN NUMBER
       );

procedure UPDATE_ROW(
       x_billing_rule_line_id IN NUMBER ,
       x_billing_rule_header_id IN NUMBER ,
       x_client_code IN VARCHAR2 ,
       x_client_number IN VARCHAR2 ,
       x_service_agreement_line_id IN NUMBER ,
       x_inventory_item_id IN NUMBER ,
       x_billing_source_id IN NUMBER ,
       x_creation_date IN DATE ,
       x_created_by IN NUMBER,
       x_last_update_date IN DATE,
       x_last_updated_by IN NUMBER ,
       x_last_update_login IN NUMBER
        );

 procedure DELETE_ROW (
  x_billing_rule_line_id IN NUMBER);


end mtl_billing_lines_pkg;

/
