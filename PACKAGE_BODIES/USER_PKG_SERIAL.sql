--------------------------------------------------------
--  DDL for Package Body USER_PKG_SERIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."USER_PKG_SERIAL" AS
/* $Header: INVUDSGB.pls 120.1 2005/05/25 16:34:55 appldev  $ */

-- PROCEDURE: generate_serial_number
-- INPUTS:
-- 1) p_org_id: Organization_id is supplied in this parameter
-- 2) p_item_id: Inventory_item_id is supplied in this parameter

-- OUTPUTS:
-- 1) x_serial_number: Serial NUMBER created using the User defined
-- logic should be returned IN this variable.
-- Note that the serial Number returned should not be greater than 30 characters.
--
-- 2) x_return_status: on successful generation of the serial number using
-- the User defined logic, this variable needs TO be assigned the value
-- FND_API.G_RET_STS_SUCCESS and returned.
-- All other return values returned in the varaible are interpreted as error
-- by the calling program
--
-- 3) x_msg_data: Error message should be returned in this variable on
-- encountering an error
--
-- 4) x_msg_count: Number of errors encountered

procedure generate_serial_number(x_return_status               OUT  NOCOPY VARCHAR2
				,x_msg_data                   OUT  NOCOPY VARCHAR2
				,x_msg_count                  OUT  NOCOPY NUMBER
				,x_serial_number              OUT  NOCOPY VARCHAR2
				,p_org_id                     IN   NUMBER
				,p_item_id                    IN   NUMBER)
  IS
BEGIN

   NULL;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_serial_number := NULL;
      IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg ('USER_PKG_SERIAL','GENERATE_SERIAL_NUMBER');
      END IF;
END generate_serial_number;

END user_pkg_serial;

/
