--------------------------------------------------------
--  DDL for Package AHL_UC_UNITCONFIG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UC_UNITCONFIG_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPUCXS.pls 120.0 2005/05/26 00:19:50 appldev noship $ */
/*#
 * This package provides the APIs for processing the Unit Configuration headers.
 * This is used to Create,Update and Expire Unit Configuration Headers
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Unit Configuration Header
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_UNIT_CONFIG
 */

-- Start of Comments  --
-- Define Procedure process_uc_header
-- This API is used to create, update or expire a UC header record in
-- ahl_unit_config_headers
--
-- Procedure name: process_uc_header
-- Type:           Public
-- Function:       To create, update or expire a UC header record in
--                 ahl_unit_config_headers.
-- Pre-reqs:
--
-- create_uc_header parameters:
-- p_dml_flag         IN VARCHAR2(1), required. To indicate DML operation of
--                    CREATE(C), UPDATE(U) OR DELETE(D).
-- p_x_uc_header_rec  IN OUT ahl_uc_instance_pvt.uc_header_rec_type, required.
--                    Record of UC header attributes including the newly created
--                    UC header ID
-- Version:    	Initial Version   1.0
--
-- End of Comments  --
/*#
 * This API is used to Create,Update or Expire the Unit Configuration Header.
 * @param p_api_version API Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @param p_dml_flag indicates the operation to be formed
 * @param p_x_uc_header_rec in out record of type ahl_uc_instance_pvt.uc_header_rec_type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Unit Configuration Header
 */
PROCEDURE process_uc_header(
  p_api_version           IN  NUMBER    := 1.0,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_dml_flag              IN  VARCHAR2,
  p_x_uc_header_rec       IN OUT NOCOPY ahl_uc_instance_pvt.uc_header_rec_type);

END AHL_UC_UNITCONFIG_PUB; -- Package spec

 

/
