--------------------------------------------------------
--  DDL for Package CS_SR_DELETE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_DELETE_UTIL" AUTHID CURRENT_USER AS
/* $Header: csvsrdls.pls 120.3 2005/08/23 02:32:31 varnaray noship $ */
/*#
 * This package encapsulates procedures that act as helpers to
 * cs_servicerequest_pvt.delete_servicerequest API. The validation procedure
 * in this package performs validations against child objects that are
 * linked to SRs to check if they can be deleted, as a result of which it
 * can be decided if the SR itself can be deleted. The delete procedure
 * encapsulates calls to the delete APIs of all child objects and also actually
 * deletes the SRs finally.
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Service Request Delete Helper
 */

PROCEDURE delete_sr_validations
(
  p_api_version_number            IN  NUMBER := 1.0
, p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
, p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
, p_object_type                   IN  VARCHAR2
, p_processing_set_id             IN  NUMBER
, p_purge_source_with_open_task   IN  VARCHAR2
, x_return_status                 OUT NOCOPY  VARCHAR2
, x_msg_count                     OUT NOCOPY  NUMBER
, x_msg_data                      OUT NOCOPY  VARCHAR2
);

PROCEDURE delete_servicerequest
(
  p_api_version_number IN  NUMBER := 1.0
, p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
, p_commit             IN  VARCHAR2 := FND_API.G_FALSE
, p_purge_set_id       IN  NUMBER
, p_processing_set_id  IN  NUMBER
, p_object_type        IN  VARCHAR2
, p_audit_required     IN  VARCHAR2
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
);

END cs_sr_delete_util;

 

/
