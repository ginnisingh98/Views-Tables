--------------------------------------------------------
--  DDL for Package Body CUG_VALIDATE_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_VALIDATE_TYPE_PKG" AS
/* $Header: CUGVTPIB.pls 115.2 2002/12/04 20:35:13 pkesani noship $ */
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

     PROCEDURE   Validate_Incident_Type (
                p_api_version   IN NUMBER,
                p_init_msg_list IN VARCHAR2 default fnd_api.g_false,
                p_commit        IN VARCHAR2 default fnd_api.g_false,
                p_incident_type_id IN NUMBER,
                p_incident_address_rec IN OUT NOCOPY CUG_VALIDATE_ADDRESS_TYPE.INCIDENT_ADDRESS_TBL,
                x_msg_count		OUT	NOCOPY NUMBER,
                x_msg_data          OUT  NOCOPY VARCHAR2,
            	x_return_status     OUT  NOCOPY VARCHAR2,
                p_validation_level IN NUMBER:=FND_API.G_VALID_LEVEL_FULL)
      IS
           l_incident_address_index  BINARY_INTEGER;

     BEGIN

    l_incident_address_index := p_incident_address_rec.FIRST;
    p_incident_address_rec(l_incident_address_index).validation_status := 'S';
    p_incident_address_rec(l_incident_address_index).jurisdiction_status := 'S';

    IF (p_incident_address_rec(l_incident_address_index).jurisdiction_status is null) OR
        (p_incident_address_rec(l_incident_address_index).jurisdiction_status = 'S') THEN
             x_return_status := FND_API.G_RET_STS_SUCCESS ;
    ELSE
        p_incident_address_rec(l_incident_address_index).validation_status := 'F';
        p_incident_address_rec(l_incident_address_index).jurisdiction_status := 'F';
        x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF;
             p_incident_address_rec := p_incident_address_rec;

  END Validate_Incident_Type;


   -- Enter further code below as specified in the Package spec.
END; -- Package Body CUG_VALIDATE_TYPE_PKG

/
