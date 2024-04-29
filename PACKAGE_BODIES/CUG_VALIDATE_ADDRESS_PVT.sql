--------------------------------------------------------
--  DDL for Package Body CUG_VALIDATE_ADDRESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_VALIDATE_ADDRESS_PVT" AS
/* $Header: CUGVADPB.pls 120.0 2006/04/25 14:24:43 spusegao noship $ */
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

     PROCEDURE   Validate_Incident_Address (
                p_api_version   IN NUMBER,
                p_init_msg_list IN VARCHAR2 default fnd_api.g_false,
                p_commit        IN VARCHAR2 default fnd_api.g_false,
                p_incident_type_id IN NUMBER,
                p_incident_address_rec IN OUT NOCOPY CUG_VALIDATE_ADDRESS_PUB.INCIDENT_ADDRESS_TBL,
                x_msg_count		OUT	NOCOPY NUMBER,
                x_msg_data          OUT  NOCOPY VARCHAR2,
            	x_return_status     OUT  NOCOPY VARCHAR2,
                p_validation_level IN NUMBER:=FND_API.G_VALID_LEVEL_FULL)
      IS
           l_incident_address_index  BINARY_INTEGER;

     BEGIN

    l_incident_address_index := p_incident_address_rec.FIRST;

    IF (p_incident_address_rec(l_incident_address_index).validation_status is null) OR
        (p_incident_address_rec(l_incident_address_index).validation_status = 'S') THEN

             x_return_status := FND_API.G_RET_STS_SUCCESS ;
             p_incident_address_rec := p_incident_address_rec;
    END IF;

    IF (p_incident_address_rec(l_incident_address_index).validation_status = 'N') THEN

             x_return_status := FND_API.G_RET_STS_ERROR ;
             p_incident_address_rec := p_incident_address_rec;
    END IF;


      END Validate_Incident_Address;


     PROCEDURE   Validate_Incident_Type (
                p_api_version   IN NUMBER,
                p_init_msg_list IN VARCHAR2 default fnd_api.g_false,
                p_commit        IN VARCHAR2 default fnd_api.g_false,
                p_incident_type_id IN NUMBER,
                p_incident_address_rec IN OUT NOCOPY CUG_VALIDATE_ADDRESS_PUB.INCIDENT_ADDRESS_TBL,
                x_msg_count		OUT	NOCOPY NUMBER,
                x_msg_data          OUT  NOCOPY VARCHAR2,
            	x_return_status     OUT  NOCOPY VARCHAR2,
                p_validation_level IN NUMBER:=FND_API.G_VALID_LEVEL_FULL)
      IS
           l_incident_address_index  BINARY_INTEGER;

     BEGIN

    l_incident_address_index := p_incident_address_rec.FIRST;

    IF (p_incident_address_rec(l_incident_address_index).jurisdiction_status is null) OR
        (p_incident_address_rec(l_incident_address_index).jurisdiction_status = 'S') THEN
             x_return_status := FND_API.G_RET_STS_SUCCESS ;
             p_incident_address_rec := p_incident_address_rec;
    END IF;

    IF (p_incident_address_rec(l_incident_address_index).jurisdiction_status = 'N') THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
             p_incident_address_rec := p_incident_address_rec;
    END IF;


   END Validate_Incident_Type;

END; -- Package Body CUG_VALIDATE_ADDRESS_PVT

/
