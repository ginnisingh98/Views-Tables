--------------------------------------------------------
--  DDL for Package CSM_GROUP_DOWNLOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_GROUP_DOWNLOAD_PUB" AUTHID CURRENT_USER AS
/* $Header: csmpgpds.pls 120.2 2008/02/25 09:31:56 anaraman noship $ */

TYPE l_group_id_tbl_type             IS TABLE OF csm_groups.group_id%TYPE INDEX BY BINARY_INTEGER;

/*#
 * Downloading a related group to a group API.
 *
 * @param p_api_version_number the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_group_id the group id to which the related group  is to be downloaded
 * @param p_related_group_id the related group to be downloaded
 * @param p_operation the operation to be performed
 *   must have one of the following values:
 *   <LI><Code>INSERT</Code>
 *   <LI><Code>DELETE</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_error_message return the error message
 */

PROCEDURE assign_related_group
( p_api_version_number                    IN  NUMBER,
  p_init_msg_list                         IN  VARCHAR2 :=FND_API.G_FALSE,
  p_group_id                              IN  NUMBER,
  p_related_group_id                      IN  NUMBER,
  p_operation                             IN  VARCHAR2,
  x_msg_count                             OUT NOCOPY NUMBER,
  x_return_status                         OUT NOCOPY VARCHAR2,
  x_error_message                         OUT NOCOPY VARCHAR2
);

/*#
 * Downloading more than one related groups to a group API.
 *
 * @param p_api_version_number the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_group_id the group id to which the related group  is to be downloaded
 * @param p_related_group_lst the list of related group to be downloaded
 * @param p_operation the operation to be performed
 * must have one of the following values:
 *   <LI><Code>INSERT</Code>
 *   <LI><Code>DELETE</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_error_message return the error message
 */

PROCEDURE assign_mutiple_related_groups
( p_api_version_number                    IN  NUMBER,
  p_init_msg_list                         IN  VARCHAR2 :=FND_API.G_FALSE,
  p_group_id                              IN  NUMBER,
  p_related_group_lst                     IN  l_group_id_tbl_type,
  p_operation                             IN  VARCHAR2,
  x_msg_count                             OUT NOCOPY NUMBER,
  x_return_status                         OUT NOCOPY VARCHAR2,
  x_error_message                         OUT NOCOPY VARCHAR2
);

/*#
 * To fetch the related groups for a given group API.
 *
 * @param p_api_version_number the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_group_id the group id to which the related group  are downloaded
 * @param p_related_group_lst the list of related group to be fetched
 * @param x_msg_count returns the number of messages in the API message list
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_error_message return the error message
 */

PROCEDURE get_related_groups
( p_api_version_number                    IN  NUMBER,
  p_init_msg_list                         IN  VARCHAR2 :=FND_API.G_FALSE,
  p_group_id                              IN  NUMBER,
  p_related_group_lst                     OUT NOCOPY l_group_id_tbl_type,
  x_msg_count                             OUT NOCOPY NUMBER,
  x_return_status                         OUT NOCOPY VARCHAR2,
  x_error_message                         OUT NOCOPY VARCHAR2
);

END CSM_GROUP_DOWNLOAD_PUB;

/
