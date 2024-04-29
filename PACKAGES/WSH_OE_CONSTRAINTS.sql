--------------------------------------------------------
--  DDL for Package WSH_OE_CONSTRAINTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_OE_CONSTRAINTS" AUTHID CURRENT_USER as
/* $Header: WSHOECOS.pls 115.1 2002/11/13 20:11:09 nparikh ship $ */

PROCEDURE Validate_Reservations
(
        p_application_id                IN      NUMBER
,       p_entity_short_name             IN      VARCHAR2
,       p_validation_entity_short_name  IN      VARCHAR2
,       p_validation_tmplt_short_name   IN      VARCHAR2
,       p_record_set_short_name         IN      VARCHAR2
,       p_scope                         IN      VARCHAR2
,       x_result_out                    OUT NOCOPY      NUMBER
);

PROCEDURE Validate_Sub_Change
(
        p_application_id                IN      NUMBER
,       p_entity_short_name             IN      VARCHAR2
,       p_validation_entity_short_name  IN      VARCHAR2
,       p_validation_tmplt_short_name   IN      VARCHAR2
,       p_record_set_short_name         IN      VARCHAR2
,       p_scope                         IN      VARCHAR2
,       x_result_out                    OUT NOCOPY      NUMBER
);


END WSH_OE_CONSTRAINTS;

 

/
