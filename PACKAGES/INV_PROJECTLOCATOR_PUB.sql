--------------------------------------------------------
--  DDL for Package INV_PROJECTLOCATOR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PROJECTLOCATOR_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPJMAS.pls 120.0 2005/05/25 06:45:51 appldev noship $ */

FUNCTION Check_Project_References(
			  arg_organization_id IN NUMBER,
			  arg_locator_id IN NUMBER,
			  arg_validation_mode IN VARCHAR2,
			  arg_required_flag IN VARCHAR2,
			  arg_project_id IN NUMBER DEFAULT NULL,
			  arg_task_id IN NUMBER DEFAULT NULL) RETURN BOOLEAN;

FUNCTION GET_PHYSICAL_LOCATION(
                               P_ORGANIZATION_ID IN NUMBER,
                               P_LOCATOR_ID      IN NUMBER
                              )
RETURN BOOLEAN;

FUNCTION GET_PROJECT_NUMBER(P_PROJECT_ID IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_TASK_NUMBER(P_TASK_ID IN NUMBER) RETURN VARCHAR2;

END INV_ProjectLocator_PUB;

 

/
