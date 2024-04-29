--------------------------------------------------------
--  DDL for Package FND_PROFILE_OPTION_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PROFILE_OPTION_VALUES_PKG" AUTHID CURRENT_USER as
/* $Header: AFPOMPVS.pls 120.1.12010000.2 2008/10/29 18:13:23 pdeluna ship $ */
/*#
* Table Handler to Insert and Update data into FND_PROFILE_OPTION_VALUES table.
* * @rep:scope public
* @rep:product FND
* @rep:displayname Profile Table Handler
* @rep:category BUSINESS_ENTITY FND_PROFILE
* @rep:compatibility S
* @rep:lifecycle active
*/

/**
 * This procedure is used to insert a row into fnd_profile_option_values.
 * Due to the nature of profile option values having levels and granular
 * values associated to its levels, this routine distinguishes between
 * these levels to ensure data integrity.
 * @param X_ROWID variable to store unique rowid
 * @param X_APPLICATION_ID application ID of profile option
 * @param X_PROFILE_OPTION_ID ID of profile option
 * @param X_LEVEL_ID numeric ID of level where profile is being inserted
 * @param X_LEVEL_VALUE numeric context value to save profile at, e.g. user_id
 * @param X_CREATION_DATE date the record created
 * @param X_CREATED_BY user that created the record
 * @param X_LAST_UPDATE_DATE  date the record was last updated
 * @param X_LAST_UPDATED_BY user that last updated the record
 * @param X_LAST_UPDATE_LOGIN login ID of user that last updated the record
 * @param X_PROFILE_OPTION_VALUE profile value being saved
 * @param X_LEVEL_VALUE_APPLICATION_ID context value of RESP-sensitive profiles
 * @param X_LEVEL_VALUE2 second context value used for SERVRESP profiles
 * @rep:scope public
 * @rep:product fnd
 * @rep:lifecycle active
 * @rep:displayname Insert Row
 */
   procedure INSERT_ROW (
     X_ROWID in out nocopy VARCHAR2,
     X_APPLICATION_ID in NUMBER,
     X_PROFILE_OPTION_ID in NUMBER,
     X_LEVEL_ID in NUMBER,
     X_LEVEL_VALUE in NUMBER,
     X_CREATION_DATE in DATE,
     X_CREATED_BY in NUMBER,
     X_LAST_UPDATE_DATE in DATE,
     X_LAST_UPDATED_BY in NUMBER,
     X_LAST_UPDATE_LOGIN in NUMBER,
     X_PROFILE_OPTION_VALUE in VARCHAR2,
     X_LEVEL_VALUE_APPLICATION_ID in NUMBER,
     X_LEVEL_VALUE2 in NUMBER
   );

/**
 * This procedure is used to update a row into fnd_profile_option_values.
 * Due to the nature of profile option values having levels and granular
 * values associated to its levels, this routine distinguishes between
 * these levels to ensure data integrity. This is overloaded and provides
 * support to the SERVRESP profile option hierarchy.
 * @param X_APPLICATION_ID application ID of profile option
 * @param X_PROFILE_OPTION_ID ID of profile option
 * @param X_LEVEL_ID numeric ID of level where profile is being inserted
 * @param X_LEVEL_VALUE numeric context value to save profile at, e.g. user_id
 * @param X_LEVEL_VALUE_APPLICATION_ID context value of RESP-sensitive profiles
 * @param X_LEVEL_VALUE2 second context value used for SERVRESP profiles
 * @param X_PROFILE_OPTION_VALUE profile value being saved
 * @param X_LAST_UPDATE_DATE  date the record was last updated
 * @param X_LAST_UPDATED_BY user that last updated the record
 * @param X_LAST_UPDATE_LOGIN login ID of user that last updated the record
 * @rep:scope public
 * @rep:product fnd
 * @rep:lifecycle active
 * @rep:displayname Update Row
 */
   procedure UPDATE_ROW (
      X_APPLICATION_ID in NUMBER,
      X_PROFILE_OPTION_ID in NUMBER,
      X_LEVEL_ID in NUMBER,
      X_LEVEL_VALUE in NUMBER,
      X_LEVEL_VALUE_APPLICATION_ID in NUMBER,
      X_LEVEL_VALUE2 in NUMBER,
      X_PROFILE_OPTION_VALUE in VARCHAR2,
      X_LAST_UPDATE_DATE in DATE,
      X_LAST_UPDATED_BY in NUMBER,
      X_LAST_UPDATE_LOGIN in NUMBER
   );

/**
 * This procedure is used to update a row into fnd_profile_option_values.
 * Due to the nature of profile option values having levels and granular
 * values associated to its levels, this routine distinguishes between
 * these levels to ensure data integrity.
 * @param X_APPLICATION_ID application ID of pThis is overloaded and provides
 * support to the SERVRESP profile option hierarchy.rofile option
 * @param X_PROFILE_OPTION_ID ID of profile option
 * @param X_LEVEL_ID numeric ID of level where profile is being inserted
 * @param X_LEVEL_VALUE numeric context value to save profile at, e.g. user_id
 * @param X_LEVEL_VALUE_APPLICATION_ID context value of RESP-sensitive profiles
 * @param X_PROFILE_OPTION_VALUE profile value being saved
 * @param X_LAST_UPDATE_DATE  date the record was last updated
 * @param X_LAST_UPDATED_BY user that last updated the record
 * @param X_LAST_UPDATE_LOGIN login ID of user that last updated the record
 * @rep:scope public
 * @rep:product fnd
 * @rep:lifecycle active
 * @rep:displayname Update Row
 */
   procedure UPDATE_ROW (
      X_APPLICATION_ID in NUMBER,
      X_PROFILE_OPTION_ID in NUMBER,
      X_LEVEL_ID in NUMBER,
      X_LEVEL_VALUE in NUMBER,
      X_LEVEL_VALUE_APPLICATION_ID in NUMBER,
      X_PROFILE_OPTION_VALUE in VARCHAR2,
      X_LAST_UPDATE_DATE in DATE,
      X_LAST_UPDATED_BY in NUMBER,
      X_LAST_UPDATE_LOGIN in NUMBER
   );

/**
 * This procedure is used to delete profile option values at a given level,
 * (if it applies). This is overloaded and provides support to the SERVRESP
 * profile option hierarchy.
 * @param X_APPLICATION_ID application ID of profile option
 * @param X_PROFILE_OPTION_ID ID of profile option
 * @param X_LEVEL_ID numeric ID of level where profile is being inserted
 * @param X_LEVEL_VALUE numeric context value to save profile at, e.g. user_id
 * @param X_LEVEL_VALUE_APPLICATION_ID context value of RESP-sensitive profiles
 * @param X_LEVEL_VALUE2 second context value used for SERVRESP profiles
 * @rep:scope public
 * @rep:product fnd
 * @rep:lifecycle active
 * @rep:displayname Delete Row
 */
   procedure DELETE_ROW (
      X_APPLICATION_ID in NUMBER,
      X_PROFILE_OPTION_ID in NUMBER,
      X_LEVEL_ID in NUMBER,
      X_LEVEL_VALUE in NUMBER,
      X_LEVEL_VALUE_APPLICATION_ID in NUMBER,
      X_LEVEL_VALUE2 in NUMBER
   );

/**
 * This procedure is used to delete profile option values at a given level,
 * (if it applies).
 * @param X_APPLICATION_ID application ID of profile option
 * @param X_PROFILE_OPTION_ID ID of profile option
 * @param X_LEVEL_ID numeric ID of level where profile is being inserted
 * @param X_LEVEL_VALUE numeric context value to save profile at, e.g. user_id
 * @param X_LEVEL_VALUE_APPLICATION_ID context value of RESP-sensitive profiles
 * @rep:scope public
 * @rep:product fnd
 * @rep:lifecycle active
 * @rep:displayname Delete Row
 */
   procedure DELETE_ROW (
      X_APPLICATION_ID in NUMBER,
      X_PROFILE_OPTION_ID in NUMBER,
      X_LEVEL_ID in NUMBER,
      X_LEVEL_VALUE in NUMBER,
      X_LEVEL_VALUE_APPLICATION_ID in NUMBER
   );

/**
 * This procedure is only going to be called from
 * FND_PROFILE_OPTIONS_PKG.DELETE_ROW which deletes profile option
 * definitions.  This procedure ensures that there will be no dangling
 * references in FND_PROFILE_OPTION_VALUES to the profile option being
 * deleted, i.e. if a profile is being deleted, it should have no rows
 * for profile option values.
 * Please note that it is not recommended that this API be used outside of
 * FND_PROFILE_OPTIONS_PKG.DELETE_ROW as it is only meant to be called when a
 * profile option is being deleted. Should it be used for purposes other
 * than described, the risks involved with a blanket deletion of profile
 * option values are assumed by the caller, not FND.
 * @param X_PROFILE_OPTION_NAME Unique name of profile option
 * @rep:scope public
 * @rep:product fnd
 * @rep:lifecycle active
 * @rep:displayname Delete Profile Option Values
 */
   procedure DELETE_PROFILE_OPTION_VALUES (X_PROFILE_OPTION_NAME in VARCHAR2);

end FND_PROFILE_OPTION_VALUES_PKG;

/
