--------------------------------------------------------
--  DDL for Package CSM_PARTY_DOWNLOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_PARTY_DOWNLOAD_PUB" AUTHID CURRENT_USER AS
/* $Header: csmpptds.pls 120.3 2008/02/26 10:15:51 anaraman noship $ */

TYPE l_party_id_tbl_type             IS TABLE OF csm_parties_acc.party_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_user_id_tbl_type              IS TABLE OF csm_parties_acc.user_id%TYPE INDEX BY BINARY_INTEGER;

/*#
 * Assign a customer to an user API.
 *
 * @param p_api_version_number the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_user_id the user id to which the customer is to be assigned
 * @param p_party_id the customer to be assigned
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

PROCEDURE assign_cust_to_user
( p_api_version_number                IN  NUMBER,
  p_init_msg_list                     IN  VARCHAR2 :=FND_API.G_FALSE,
  p_user_id                           IN  NUMBER,
  p_party_id                          IN  NUMBER,
  p_operation                         IN  VARCHAR2,
  x_msg_count                         OUT NOCOPY NUMBER,
  x_return_status                     OUT NOCOPY VARCHAR2,
  x_error_message                     OUT NOCOPY VARCHAR2
);

/*#
 * Assign a multiple customers to multiple users API.
 *
 * @param p_api_version_number the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_user_id_lst the user id to which the customer is to be assigned
 * @param p_party_id_lst the customer to be assigned
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

PROCEDURE assign_mul_cust_to_users
( p_api_version_number                IN  NUMBER,
  p_init_msg_list                     IN  VARCHAR2 :=FND_API.G_FALSE,
  p_user_id_lst                       IN  l_user_id_tbl_type,
  p_party_id_lst                      IN  l_party_id_tbl_type,
  p_operation                         IN  VARCHAR2,
  x_msg_count                         OUT NOCOPY NUMBER,
  x_return_status                     OUT NOCOPY VARCHAR2,
  x_error_message                     OUT NOCOPY VARCHAR2
);

/*#
 * Assign a customer location to an user API.
 *
 * @param p_api_version_number the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_user_id the user id to which the customer is to be assigned
 * @param p_party_id the customer to be assigned
 * @param p_location_id the customer location to be assigned
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

PROCEDURE assign_cust_loc_to_user
( p_api_version_number                IN  NUMBER,
  p_init_msg_list                     IN  VARCHAR2 :=FND_API.G_FALSE,
  p_user_id                           IN  NUMBER,
  p_party_id                          IN  NUMBER,
  p_location_id                       IN  NUMBER,
  p_operation                         IN  VARCHAR2,
  x_msg_count                         OUT NOCOPY NUMBER,
  x_return_status                     OUT NOCOPY VARCHAR2,
  x_error_message                     OUT NOCOPY VARCHAR2
);

/*#
 * Assign a multiple customer locations to multiple users API.
 *
 * @param p_api_version_number the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_user_id_lst the user id to which the customer is to be assigned
 * @param p_party_id the customer to be assigned
 * @param p_location_id_lst the customer location to be assigned
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

PROCEDURE assign_mul_cust_loc_to_users
( p_api_version_number                IN  NUMBER,
  p_init_msg_list                     IN  VARCHAR2 :=FND_API.G_FALSE,
  p_user_id_lst                       IN  l_user_id_tbl_type,
  p_party_id                          IN  NUMBER,
  p_location_id_lst                   IN  l_party_id_tbl_type,
  p_operation                         IN  VARCHAR2,
  x_msg_count                         OUT NOCOPY NUMBER,
  x_return_status                     OUT NOCOPY VARCHAR2,
  x_error_message                     OUT NOCOPY VARCHAR2
);

/*#
 * To fetch the parties related to an user API.
 *
 * @param p_api_version_number the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_user_id the user id for which customers has to be fetched
 * @param p_party_id_lst the customers which are fetched
 * @param p_operation the operation to be performed can be null also
 * @param x_msg_count returns the number of messages in the API message list
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_error_message return the error message
 */

PROCEDURE get_parties_for_user
( p_api_version_number                IN  NUMBER,
  p_init_msg_list                     IN  VARCHAR2 :=FND_API.G_FALSE,
  p_user_id                           IN  NUMBER,
  p_party_id_lst                      OUT NOCOPY l_party_id_tbl_type,
  p_operation                         IN  VARCHAR2,
  x_msg_count                         OUT NOCOPY NUMBER,
  x_return_status                     OUT NOCOPY VARCHAR2,
  x_error_message                     OUT NOCOPY VARCHAR2
);

/*#
 * To fetch the locations of a party related to an user API.
 *
 * @param p_api_version_number the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_user_id the user id for which locations has to be fetched
 * @param p_party_id the customers for which locations has to be fetched
 * @param p_operation the operation to be performed can be null also
 * @param p_location_id the location which are fetched
 * @param x_msg_count returns the number of messages in the API message list
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_error_message return the error message
 */

PROCEDURE get_party_locations_for_user
( p_api_version_number                 IN  NUMBER,
  p_init_msg_list                      IN  VARCHAR2 :=FND_API.G_FALSE,
  p_user_id                            IN  NUMBER,
  p_party_id                           IN  NUMBER,
  p_location_id                        OUT NOCOPY l_party_id_tbl_type,
  p_operation                          IN  VARCHAR2,
  x_msg_count                          OUT NOCOPY NUMBER,
  x_return_status                      OUT NOCOPY VARCHAR2,
  x_error_message                      OUT NOCOPY VARCHAR2
);

END CSM_PARTY_DOWNLOAD_PUB;

/
