--------------------------------------------------------
--  DDL for Package FND_NEW_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_NEW_MESSAGES_PKG" AUTHID CURRENT_USER as
/* $Header: AFMDMSGS.pls 120.3.12000000.1 2007/01/18 13:20:56 appldev ship $ */
/*#
* APIs to INSERT, UPDATE and DELETE messages into FND_NEW_MESSAGES table.
* @rep:scope public
* @rep:product FND
* @rep:displayname Message
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_MESSAGE
* @rep:ihelp FND/@fndmdmsg#fndmdmsg See the related online help
*/

  ADDN_COLS		VARCHAR2(1) := NULL; -- Backward compatability flag

procedure CHECK_COMPATIBILITY;

procedure ADD_LANGUAGE;

    /*#
     * Creates or updates Message Text info in Fnd_New_Messages as appropriate.
     * @param x_application_id Application Id to which the message belongs
     * @param x_message_name Message Name
     * @param x_message_number Message Number
     * @param x_message_text Message Text
     * @param x_description Description if any
     * @param x_type Message Type
     * @param x_max_length Message Text's Max Length
     * @param x_category Message Category
     * @param x_severity Message Severity
     * @param x_fnd_log_severity FND's log Severity used for logging debug messages
     * @param x_owner Owner Name
     * @param x_custom_mode Custom Mode
     * @param x_last_update_date Insert/Update Date
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:displayname Create/Update Message Text
     * @rep:compatibility S
     * @rep:ihelp FND/@fndmdmsg#fndmdmsg See the related online help
     */
procedure LOAD_ROW (
  X_APPLICATION_ID in NUMBER,
  X_MESSAGE_NAME in VARCHAR2,
  X_MESSAGE_NUMBER in VARCHAR2,
  X_MESSAGE_TEXT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_MAX_LENGTH in VARCHAR2,
  X_CATEGORY in VARCHAR2,
  X_SEVERITY in VARCHAR2,
  X_FND_LOG_SEVERITY in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
);

procedure TRANSLATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_MESSAGE_NAME in VARCHAR2,
  X_MESSAGE_TEXT in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
);

    /*#
     * Deletes Message from Fnd_New_Messages for a given language.
     * @param x_application_id Application Id to which the message belongs
     * @param x_message_name Message Name
     * @param x_language_code Language Code
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:displayname Delete Message record
     * @rep:compatibility S
     * @rep:ihelp FND/@fndmdmsg#fndmdmsg See the related online help
     */
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_LANGUAGE_CODE in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2
);

procedure CHECK_MESSAGE_TYPE (
 X_MESSAGE_NAME in VARCHAR2,
 X_TYPE in VARCHAR2
 );

procedure CHECK_MESSAGE_DESCRIPTION (
 X_MESSAGE_NAME in VARCHAR2,
 X_TYPE in VARCHAR2,
 X_DESCRIPTION in VARCHAR2
 );

procedure CHECK_MAX_LENGTH_TYPE (
 X_MESSAGE_NAME in VARCHAR2,
 X_TYPE in VARCHAR2,
 X_MAX_LENGTH in NUMBER
 );

/* OverLoaded Version Below */
procedure CHECK_MAX_LEN_MSG_LEN (
 X_MESSAGE_NAME in VARCHAR2,
 X_MESSAGE_TEXT in VARCHAR2,
 X_MAX_LENGTH in NUMBER
 );

procedure CHECK_TOKENS_ACCESS_KEYS (
 X_MESSAGE_NAME in VARCHAR2,
 X_MESSAGE_TEXT in VARCHAR2
 );

/* OverLoaded Version Below */
procedure CHECK_TYPE_RULES (
 X_MESSAGE_NAME in VARCHAR2,
 X_TYPE in VARCHAR2,
 X_MESSAGE_TEXT in VARCHAR2
 );

procedure CHECK_MAXIMUM_LENGTH_RANGE (
  X_MAX_LENGTH in NUMBER,
  X_MESSAGE_NAME in VARCHAR2
);

procedure CHECK_CATEGORY_SEVERITY (
  X_CATEGORY in VARCHAR2,
  X_SEVERITY in VARCHAR2,
  X_FND_LOG_SEVERITY in NUMBER,
  X_MESSAGE_NAME in VARCHAR2
);


/* OverLoaded Version Above */
procedure CHECK_MAX_LEN_MSG_LEN (
 X_MESSAGE_NAME in VARCHAR2,
 X_MESSAGE_TEXT in VARCHAR2,
 X_MAX_LENGTH in NUMBER,
 X_VALIDATION in VARCHAR2
 );

/* OverLoaded Version Above */
procedure CHECK_TYPE_RULES (
 X_MESSAGE_NAME in VARCHAR2,
 X_TYPE in VARCHAR2,
 X_MESSAGE_TEXT in VARCHAR2,
 X_VALIDATION  in VARCHAR2
 );

end FND_NEW_MESSAGES_PKG;

 

/
