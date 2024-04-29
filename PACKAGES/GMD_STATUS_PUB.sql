--------------------------------------------------------
--  DDL for Package GMD_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_STATUS_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPSTSS.pls 115.1 2004/04/16 14:35:52 srsriran noship $ */
/*#
 * This interface is used to modify the Status of an entity (Formula, Recipe,
 * Operation, Routing, Validity Rule). This package defines and implements the
 * procedure and datatypes required to modify entity status after proper validations.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Status package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_STATUS_PUB
 */

  m_api_version   CONSTANT NUMBER         := 1;
  m_pkg_name      CONSTANT VARCHAR2 (30)  := 'GMD_STATUS_PUB';

 /*#
 * Modify Entity Status
 * This is a PL/SQL procedure to modify the Status of an entity.
 * Proper validations are performed before modifying the entity status.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_entity_name Entity Name (eg. Formula Name)
 * @param p_entity_id Entity ID (eg. Formula ID)
 * @param p_entity_no Entity Number (eg. Formula Number)
 * @param p_entity_version Entity Version (eg. Formula Version)
 * @param p_to_status Target Status
 * @param p_ignore_flag Flag to check if Validity rule status is to be changed along with Recipe
 * @param x_message_count Number of msg's on message stack
 * @param x_message_list Message list
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Modify Status procedure
 * @rep:compatibility S
 */
  PROCEDURE modify_status
  ( p_api_version       IN         NUMBER           := 1
  , p_init_msg_list     IN         BOOLEAN          := TRUE
  , p_entity_name       IN         VARCHAR2
  , p_entity_id         IN         NUMBER           := NULL
  , p_entity_no         IN         VARCHAR2         := NULL
  , p_entity_version    IN         NUMBER           := NULL
  , p_to_status         IN         VARCHAR2
  , p_ignore_flag       IN 	   BOOLEAN          := FALSE
  , x_message_count     OUT NOCOPY NUMBER
  , x_message_list      OUT NOCOPY VARCHAR2
  , x_return_status     OUT NOCOPY VARCHAR2
  );


END GMD_STATUS_PUB;

 

/
