--------------------------------------------------------
--  DDL for Package CAC_SYNC_CONTACT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SYNC_CONTACT_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: cacvscus.pls 120.1 2005/07/02 02:20:55 appldev noship $ */
/*#
 * This is a utility package commonly used for contact synchronization.
 * @rep:scope private
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Contact Synchronization Utility
 * @rep:compatibility N
 * @rep:category BUSINESS_ENTITY CAC_SYNC_SERVER
 */

/**
 * This function formats the phone number and returns formatted phone number.
 * @param p_country_code phone country code
 * @param p_area_code area code
 * @param p_phone_number phone number
 * @param p_phone_extension extension number
 * @param p_delimit_country delimit for country code
 * @param p_delimit_area_code delimit for area code
 * @param p_delimit_phone_number delimit for phone number
 * @param p_delimit_extension delimit for extension
 * @return The formatted phone number
 * @rep:displayname FORMAT_PHONE
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION FORMAT_PHONE
( p_country_code         IN   VARCHAR2
, p_area_code            IN   VARCHAR2
, p_phone_number         IN   VARCHAR2
, p_phone_extension      IN   VARCHAR2 DEFAULT NULL
, p_delimit_country      IN   VARCHAR2 DEFAULT NULL
, p_delimit_area_code    IN   VARCHAR2 DEFAULT NULL
, p_delimit_phone_number IN   VARCHAR2 DEFAULT NULL
, p_delimit_extension    IN   VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;

/**
 * This procedure is used to create a log.
 * @param p_message an error message
 * @param p_prefix a prefix
 * @param p_msg_level a message level
 * @param p_module_prefix a module prefix
 * @param p_module a module
 * @rep:displayname LOG
 * @rep:lifecycle active
 * @rep:compatibility N
 */
PROCEDURE LOG
(p_message        IN     VARCHAR2,
 p_msg_level      IN     NUMBER,
 p_prefix         IN     VARCHAR2 DEFAULT NULL,
 p_module_prefix  IN     VARCHAR2 DEFAULT NULL,
 p_module         IN     VARCHAR2 DEFAULT NULL
);

END CAC_SYNC_CONTACT_UTIL_PVT;

 

/
