--------------------------------------------------------
--  DDL for Package CUG_VALIDATE_ADDRESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CUG_VALIDATE_ADDRESS_PVT" AUTHID CURRENT_USER AS
/* $Header: CUGVADPS.pls 120.0 2006/04/25 14:25:13 spusegao noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

     PROCEDURE   Validate_Incident_Address (
                p_api_version   IN NUMBER,
                p_init_msg_list IN VARCHAR2 default fnd_api.g_false,
                p_commit        IN VARCHAR2 default fnd_api.g_false,
                p_incident_type_id IN NUMBER,
                p_incident_address_rec IN OUT NOCOPY CUG_VALIDATE_ADDRESS_PUB.INCIDENT_ADDRESS_TBL,
                x_msg_count		OUT	NOCOPY NUMBER,
                x_msg_data          OUT  NOCOPY VARCHAR2,
            	x_return_status     OUT  NOCOPY VARCHAR2,
                p_validation_level IN NUMBER:=FND_API.G_VALID_LEVEL_FULL);


     PROCEDURE   Validate_Incident_Type (
                p_api_version   IN NUMBER,
                p_init_msg_list IN VARCHAR2 default fnd_api.g_false,
                p_commit        IN VARCHAR2 default fnd_api.g_false,
                p_incident_type_id IN NUMBER,
                p_incident_address_rec IN OUT NOCOPY CUG_VALIDATE_ADDRESS_PUB.INCIDENT_ADDRESS_TBL,
                x_msg_count		OUT	NOCOPY NUMBER,
                x_msg_data          OUT  NOCOPY VARCHAR2,
            	x_return_status     OUT  NOCOPY VARCHAR2,
                p_validation_level IN NUMBER:=FND_API.G_VALID_LEVEL_FULL);

END; -- Package Specification CUG_VALIDATE_ADDRESS_PVT

 

/
