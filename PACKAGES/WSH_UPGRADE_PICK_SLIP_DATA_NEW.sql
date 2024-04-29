--------------------------------------------------------
--  DDL for Package WSH_UPGRADE_PICK_SLIP_DATA_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_UPGRADE_PICK_SLIP_DATA_NEW" AUTHID CURRENT_USER AS
/* $Header: wshpupds.pls 120.0 2005/05/26 18:16:04 appldev noship $ */

--
-- Package
--   	WSH_UPGRADE_PICK_SLIP_DATA_NEW
--
-- Purpose
--      To upgrade historic pick slip data to delivery based shipping
--

/*

PACKAGE: WSH_UPGRADE_PICK_SLIP_DATA_NEW.UPGRADE_ROWS

SUMMARY: The PL/SQL script consisting of the procedures described below is
         used to upgrade historic pick-slip data to the new Delivery based
         system (DBS) in release 10.7 and later versions. This script
         searches for picking headers (greater than zero) that do not have
         a delivery ID and which have already been shipped (with status
         CLOSED). New departure and delivery information is created for each
         picking header obtained in this manner. Each of these new delivery/
         departure rows contains existing data from their picking headers
         and order headers and can subsequently be used in new delivery-based
         forms and reports.

USAGE:   Please run the driver file for the patch to install the package
         WSH_UPGRADE_PICK_SLIP_DATA_NEW before executing the SQL driver
         statement in wshrpupd.sql.

         wshrpupd.sql <total workers> <worker number>
         e.g.
         sqlplus <username/password@database> @wshrpupd.sql 5 1

         The file wshrpupd.sql calls the procedure with another parameter
         num_rows which specifies the commit size.

*/

  PROCEDURE Upgrade_Rows(
	num_rows	IN		BINARY_INTEGER,
	total_workers	IN	BINARY_INTEGER,
	worker		IN	BINARY_INTEGER,
        batch_number    IN      BINARY_INTEGER
  );

END WSH_UPGRADE_PICK_SLIP_DATA_NEW;

 

/
