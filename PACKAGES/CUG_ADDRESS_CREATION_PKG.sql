--------------------------------------------------------
--  DDL for Package CUG_ADDRESS_CREATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CUG_ADDRESS_CREATION_PKG" AUTHID CURRENT_USER AS
/* $Header: CUGADRCS.pls 120.1 2006/03/27 14:36:21 appldev noship $ */
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

   TYPE incident_address_rec_type IS RECORD(
	   location_id              NUMBER,
        address1                VARCHAR2(240),
        address2                VARCHAR2(240),
        address3                VARCHAR2(240),
        address4                VARCHAR2(240),
        city                    VARCHAR2(60),
        state                   VARCHAR2(60),
        postal_code             VARCHAR2(60),
        province                VARCHAR2(60),
        county                  VARCHAR2(60),
        country                 VARCHAR2(60),
        street                  VARCHAR2(50),
        house_number            VARCHAR2(50),
        apartment_number        VARCHAR2(50),
        building                VARCHAR2(50),
        position                VARCHAR2(50),
        po_box_number           VARCHAR2(50),
        street_number           VARCHAR2(50),
        room                    VARCHAR2(50),
        floor                   VARCHAR2(50),
        suite                   VARCHAR2(50),
        jurisdiction_status     VARCHAR2(1) default null,
        validation_status       VARCHAR2(1) default null) ;

   PROCEDURE Create_Incident_Address (
    p_incident_id IN NUMBER,
	p_address_rec		IN	INCIDENT_ADDRESS_REC_TYPE,
	x_msg_count		OUT	NOCOPY NUMBER,
     x_msg_data          OUT  NOCOPY VARCHAR2,
	x_return_status     OUT  NOCOPY VARCHAR2,
	x_location_id		OUT  NOCOPY NUMBER);


END CUG_ADDRESS_CREATION_PKG; -- Package spec

/
