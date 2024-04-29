--------------------------------------------------------
--  DDL for Package Body CUG_ADDRESS_CREATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_ADDRESS_CREATION_PKG" AS
/* $Header: CUGADRCB.pls 120.1 2006/03/27 14:36:07 appldev noship $ */
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person     Date      Comments
-- ---------  --------  ------------------------------------------
-- dejoseph   12-05-02  Replaced reference to install_site_use_id with
--                      install_site_id. ER# 2695480.
-- aneemuch   11-Feb-04 To fix bug 2657648 changed hz_location_pub to hz_location_v2pub
--
--
   -- Enter procedure, function bodies as shown below


 G_PKG_NAME	CONSTANT    VARCHAR2(25):=  'CUG_ADDRESS_CREATION_PKG';

 PROCEDURE Create_Incident_Address (
    p_incident_id IN NUMBER,
	p_address_rec		IN	INCIDENT_ADDRESS_REC_TYPE,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	x_return_status     OUT  NOCOPY VARCHAR2,
	x_location_id		OUT  NOCOPY NUMBER) Is

-- To fix bug 2657648 changed hz_location_pub to hz_location_v2pub, aneemuch 11-Feb-2004
   l_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(2000);
   l_location_id NUMBER;
   l_incident_id NUMBER;

 Begin

    l_incident_id := p_incident_id;

   l_location_rec.address1 := p_address_rec.address1;
   l_location_rec.address2 := p_address_rec.address2;
   l_location_rec.address3 := p_address_rec.address3;
   l_location_rec.address4 := p_address_rec.address4;
   l_location_rec.city     := p_address_rec.city;
   l_location_rec.state 	  := p_address_rec.state;
   l_location_rec.county   := p_address_rec.county;
   l_location_rec.country  := p_address_rec.country;
   l_location_rec.postal_code := p_address_rec.postal_code;
   l_location_rec.province := p_address_rec.province;
   l_location_rec.county := p_address_rec.county;
   l_location_rec.po_box_number := p_address_rec.po_box_number;
   l_location_rec.street := p_address_rec.street;
   l_location_rec.house_number := p_address_rec.house_number;
--   l_location_rec.apartment_number := p_address_rec.apartment_number;
--   l_location_rec.building := p_address_rec.building;
   l_location_rec.street_number := p_address_rec.street_number;
--   l_location_rec.room := p_address_rec.room;
   l_location_rec.floor := p_address_rec.floor;
   l_location_rec.suite := p_address_rec.suite;
   l_location_rec.position := p_address_rec.position;


-- To fix bug 2657648 changed hz_location_pub to hz_location_v2pub, aneemuch 11-Feb-2004
/*
    HZ_LOCATION_V2PUB.create_location (
       	p_api_version		=> 1.0,
	    p_init_msg_list     => FND_API.G_FALSE,
    	p_commit			=> FND_API.G_TRUE,
    	p_location_rec		=> l_location_rec,
    	x_return_status	=> l_return_status,
    	x_msg_count		=> l_msg_count,
    	x_msg_data		=> l_msg_data,
    	x_location_id       => l_location_id,
        p_validation_level  => FND_API.G_VALID_LEVEL_FULL);
*/
   HZ_LOCATION_V2PUB.create_location (
        p_init_msg_list     => FND_API.G_FALSE,
    	p_location_rec      => l_location_rec,
    	x_location_id       => l_location_id,
    	x_return_status	    => l_return_status,
    	x_msg_count	    => l_msg_count,
    	x_msg_data	    => l_msg_data);
-- end of changes for bug 2657648, aneemuch 11-Feb-2004


    x_return_status := l_return_status;
	x_msg_count     := l_msg_count;
	x_msg_data      := l_msg_data;

	If (x_return_status = CSC_CORE_UTILS_PVT.G_RET_STS_SUCCESS) Then
		x_location_id	 := l_location_id;
	End If;
        update cs_incidents_all_b set install_site_id = l_location_id
            where incident_id = l_incident_id;

 End Create_Incident_Address;


END CUG_ADDRESS_CREATION_PKG;

/
