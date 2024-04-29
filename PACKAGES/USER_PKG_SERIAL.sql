--------------------------------------------------------
--  DDL for Package USER_PKG_SERIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."USER_PKG_SERIAL" AUTHID CURRENT_USER AS
/* $Header: INVUDSGS.pls 120.0 2005/05/25 04:43:51 appldev noship $ */
/*#
 * The user defined serial generation procedures allow users to create Serial
 * Numbers in the system using the logic defined by them, as opposed to the
 * standard Oracle serial number generation logic.
 * @rep:scope public
 * @rep:product INV
 * @rep:lifecycle active
 * @rep:displayname User Defined Serial Generation API
 * @rep:category BUSINESS_ENTITY INV_SERIAL_NUMBER
 */

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
--

/*#
 * Use this procedure to define the logic to be used by the system
 * when generating the serial numbers. This procedure is invoked by the
 * system while generating a serial number if the serial generation
 * level is set as 'User Defined' for a particular organization. The
 * user needs to fill in the logic for generating a serial number in
 * the stub provided and apply the package to the database.
 * @ param x_return_status Return status indicating success or failure
 * @ paraminfo {@rep:required}
 * @ param x_msg_data Return the error message in case of failure
 * @ paraminfo {@rep:required}
 * @ param x_msg_count Return message count from the error stack in case of failure
 * @ paraminfo {@rep:required}
 * @ param x_serial_number Return the serial number to be generated
 * @ paraminfo {@rep:required}
 * @ param p_org_id Organization Id is passed as input in this variable
 * @ paraminfo {@rep:required}
 * @ param p_item_id Inventory Item id passed as input in this variable
 * @ paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate User Defined Serial Number
 */
procedure generate_serial_number(x_return_status              OUT  NOCOPY VARCHAR2
				,x_msg_data                   OUT  NOCOPY VARCHAR2
				,x_msg_count                  OUT  NOCOPY NUMBER
				,x_serial_number              OUT  NOCOPY VARCHAR2
				,p_org_id                     IN   NUMBER
				,p_item_id                    IN   NUMBER);
END user_pkg_serial;

 

/
