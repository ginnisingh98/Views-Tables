--------------------------------------------------------
--  DDL for Package POS_PUB_HISTORY_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_PUB_HISTORY_BO_PKG" AUTHID CURRENT_USER AS
/* $Header: POSPUBHIS.pls 120.0.12010000.4 2010/05/24 20:22:51 huiwan noship $ */
/*#
 * This package provides APIs to retrieve supplier business objects
 * from the supplier data hub publication repository and for spoke
 * systems to send responses to the supplier data hub.
 *
 * @rep:scope public
 * @rep:product POS
 * @rep:lifecycle active
 * @rep:displayname Supplier Data Publication APIs
 * @rep:category BUSINESS_ENTITY AP_SUPPLIER
 */


  /*#
  * This API returns the supplier business objects given a supplier
  * publication event.
  * @param p_api_version Standard API version.  Use 1.0.
  * @param p_init_msg_list Standard API initialize message list flag.  Default is fnd_api.g_true
  * @param p_event_id Supplier publication event ID
  * @param p_party_id Party ID of a particular supplier to be retrieved if known.
  * @param p_orig_system If party ID is not known, supply the original system name.
  * @param p_orig_system_reference If party ID is not known, supply the original system reference.  Party ID and original system references can be NULL in which case, all suppliers published in the given event will be returned.
  * @param x_suppliers Return value.  A table of objects, each containing a supplier business object in XML format.
  * @param x_return_status Standard API return status
  * @param x_msg_count Standard API message count
  * @param x_msg_data Standard API message data
  * @rep:displayname Get Supplier Publication History
  */
  PROCEDURE get_published_suppliers
  (
    p_api_version            IN NUMBER DEFAULT NULL,
    p_init_msg_list          IN VARCHAR2 DEFAULT NULL,
    p_event_id               IN NUMBER,
    p_party_id               IN NUMBER,
    p_orig_system            IN VARCHAR2,
    p_orig_system_reference  IN VARCHAR2,
    x_suppliers              OUT NOCOPY pos_pub_history_bo_tbl,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
  );


      /*
          Private version of the above.
       */
      PROCEDURE get_pos_pub_history_bo_tbl
      (
        p_api_version            IN NUMBER DEFAULT NULL,
        p_init_msg_list          IN VARCHAR2 DEFAULT NULL,
        p_event_id               IN NUMBER,
        p_party_id               IN NUMBER,
        p_orig_system            IN VARCHAR2,
        p_orig_system_reference  IN VARCHAR2,
        x_pos_pub_history_bo_tbl OUT NOCOPY pos_pub_history_bo_tbl,
        x_return_status          OUT NOCOPY VARCHAR2,
        x_msg_count              OUT NOCOPY NUMBER,
        x_msg_data               OUT NOCOPY VARCHAR2
      );


  /*#
  * This API is intended to be used by a spoke system to respond to a
  * Supplier Publication Event.  A message will be written to the
  * Supplier Hub's event response table.
  * @param p_api_version Standard API version.  Use 1.0.
  * @param p_init_msg_list Standard API initialize message list flag.  Default is fnd_api.g_true
  * @param p_commit Commit flag.  Perform commit if value is fnd_api.g_true.  Default is fnd_api.g_false.
  * @param p_target_system The spoke system's identity.  Required.
  * @param p_response_process_id Response process ID.  Response ID required to uniquely identify a response for a target system.  Required.
  * @param p_response_process_status Response process status code.  Stored in response table with open interpretation.
  * @param p_request_process_id Request process ID.  Stored in response table with open interpretation.
  * @param p_request_process_status Request process status code.  Stored in response table with open interpretation.
  * @param p_event_id Supplier publication event ID this response refers to.  Required.
  * @param p_party_id Party ID of a particular supplier of the event this response refers to.  Required.
  * @param p_message Response message.  Stored in response table with open interpretation.
  * @param x_return_status Standard API return status
  * @param x_msg_count Standard API message count
  * @param x_msg_data Standard API message data
  * @rep:displayname Create Supplier Publication Response
  */
  PROCEDURE create_publication_response
  (
    p_api_version             IN NUMBER DEFAULT NULL,
    p_init_msg_list           IN VARCHAR2 DEFAULT NULL,
    p_commit                  IN VARCHAR2 DEFAULT NULL,
    p_target_system           IN VARCHAR2,
    p_response_process_id     IN NUMBER,
    p_response_process_status IN VARCHAR2,
    p_request_process_id      IN NUMBER,
    p_request_process_status  IN VARCHAR2,
    p_event_id                IN NUMBER,
    p_party_id                IN NUMBER,
    p_message                 IN VARCHAR2,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2
  );


END pos_pub_history_bo_pkg;

/
