--------------------------------------------------------
--  DDL for Package CUG_VALIDATE_ADDRESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CUG_VALIDATE_ADDRESS_PUB" AUTHID CURRENT_USER AS
/* $Header: CUGVADRS.pls 120.0 2006/03/01 18:38:21 spusegao noship $ */
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


TYPE incident_address_tbl IS TABLE OF CUG_ADDRESS_CREATION_PKG.incident_address_rec_type  INDEX BY BINARY_INTEGER;

     PROCEDURE   Validate_Incident_Address (
                p_api_version   IN NUMBER,
                p_init_msg_list IN VARCHAR2 default fnd_api.g_false,
                p_commit        IN VARCHAR2 default fnd_api.g_false,
                p_incident_type_id IN NUMBER,
                p_incident_address_rec IN OUT NOCOPY CUG_VALIDATE_ADDRESS_PUB.INCIDENT_ADDRESS_TBL,
                x_msg_count		OUT NOCOPY NUMBER,
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


END; -- Package spec

 

/
