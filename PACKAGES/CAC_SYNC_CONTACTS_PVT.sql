--------------------------------------------------------
--  DDL for Package CAC_SYNC_CONTACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SYNC_CONTACTS_PVT" AUTHID CURRENT_USER as
/* $Header: cacvscts.pls 120.1.12000000.1 2007/01/18 16:23:04 appldev ship $ */
/*#
 * This package is used to perform fast and slow synchronization.
 *
 * @rep:scope private
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Contact Synchronization API
 * @rep:compatibility N
 * @rep:category BUSINESS_ENTITY CAC_SYNC_SERVER
 */

/*******************************************************************************
** Private APIs
*******************************************************************************/

/**
 * This function formats the phone number and returns formatted phone number
 * by calling CAC_SYNC_CONTACT_UTIL_PVT.format_phone().
 *
 * @param p_country_code phone country code
 * @param p_area_code area code
 * @param p_phone_number phone number
 * @param p_phone_extension extension number
 * @return The formatted phone number
 * @rep:displayname Format Phone
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION FORMAT_PHONE
(
  p_country_code         IN   VARCHAR2
, p_area_code            IN   VARCHAR2
, p_phone_number         IN   VARCHAR2
, p_phone_extension      IN   VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;


/**
 * This procedure is executed to retrieve contacts modified since last sync.
 * It performs a fetch from HZ tables based on the timestamp and
 * populates the CAC_SYNC_CONTACT_TEMPS table.
 *
 * @param p_api_version an api version i.e 1.0
 * @param p_init_msg_list a message initialization flag
 * @param p_principal_id a principal id
 * @param p_person_party_id a person party id
 * @param p_sync_anchor a sync anchor
 * @return Returns a status, the number of messages and an error message
 * @rep:displayname Prepare Fast Sync
 * @rep:lifecycle active
 * @rep:compatibility N
 */
PROCEDURE PREPARE_FASTSYNC
(
  p_api_version          IN     NUMBER                       -- Standard version parameter
, p_init_msg_list        IN     VARCHAR2    DEFAULT NULL     -- Standard message initialization flag
, p_principal_id         IN     NUMBER                       -- Principal ID
, p_person_party_id      IN     NUMBER                       -- Person Party ID
, p_sync_anchor          IN     DATE                         -- Timestamp for sync anchor
, x_return_status        OUT NOCOPY  VARCHAR2                -- Standard API return status parameter
, x_msg_count            OUT NOCOPY  NUMBER                  -- Standard return parameter for the no of msgs in the stack
, x_msg_data             OUT NOCOPY  VARCHAR2                -- Standard return parameter for the msgs in the stack
);

/**
 * This procedure is executed to retrieve contacts modified since last sync.
 * It performs a fetch from HZ tables for all synchronoxable contact records
 * and populates the CAC_SYNC_CONTACT_TEMPS table.
 *
 * @param p_api_version an api version i.e 1.0
 * @param p_init_msg_list a message initialization flag
 * @param p_person_party_id a person party id
 * @return Returns a status, the number of messages and an error message
 * @rep:displayname Prepare Slow Sync
 * @rep:lifecycle active
 * @rep:compatibility N
 */
PROCEDURE PREPARE_SLOWSYNC
(
  p_api_version          IN     NUMBER                       -- Standard version parameter
, p_init_msg_list        IN     VARCHAR2    DEFAULT NULL     -- Standard message initialization flag
, p_person_party_id      IN     NUMBER                       -- Person Party ID
, x_return_status        OUT NOCOPY   VARCHAR2               -- Standard API return status parameter
, x_msg_count            OUT NOCOPY   NUMBER                 -- Standard return parameter for the no of msgs in the stack
, x_msg_data             OUT NOCOPY   VARCHAR2               -- Standard return parameter for the msgs in the stack
);

SERVER_URI_CONST  CONSTANT cac_sync_mappings.server_uri%TYPE := './contacts';

END CAC_SYNC_CONTACTS_PVT;

 

/
