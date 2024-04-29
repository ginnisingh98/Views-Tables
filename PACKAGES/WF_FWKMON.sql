--------------------------------------------------------
--  DDL for Package WF_FWKMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_FWKMON" AUTHID CURRENT_USER as
/* $Header: wffkmons.pls 120.2.12010000.2 2014/10/24 23:14:01 alsosa ship $ */
/*#
 * This public interface provides APIs to retrieve
 * parameters for use with the self-service functions
 * that provide access to the Oracle Applications
 * Framework-based Status Monitor. These APIs help
 * to integrate other applications with the Status Monitor.
 * @rep:scope internal
 * @rep:product OWF
 * @rep:displayname Workflow Status Monitor
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_ENGINE
 * @rep:ihelp FND/@stmonapi See the related online help
 */



-- ===========================================================================
-- FUNCTION NAME:       getNotificationResult
--
-- DESCRIPTION:         Returns the display result value for a notification.
--
-- PARAMETERS:          x_notificationId IN  Notification ID
--
-- ===========================================================================
FUNCTION getNotificationResult(x_notificationId IN number) return varchar2;


-- ===========================================================================
-- FUNCTION NAME:     isRespondNotification
--
-- DESCRIPTION:       Determines whether the notification requires a response.
--
--                    Returns 1 if the notification requires a response, 0
--                    if it doesn't.
--
-- PARAMETERS:        x_notificationId IN  Notification ID
--
-- ===========================================================================
FUNCTION isRespondNotification(x_notificationId IN number) RETURN number;


-- ===========================================================================
-- FUNCTION NAME:        getItemStatus
--
-- DESCRIPTION:          Determines the overall status of a root process based
--                       its end_date and activity statuses.
--
--                       Returns one of the following states:
--
--                       ERROR (workflow has at least one activity in error)
--                       COMPLETE
--                       COMPLETE_WITH_ERRORS
--                       SUSPEND_WITH_ERRORS (root process is suspended, but
--                       workflow has errors)
--                       FORCE (translates to "Canceled")
--                       ACTIVE
--                       SUSPEND
--
--
-- PARAMETERS:           x_itemType    IN Item type.
--                       x_itemKey     IN Item key.
--                       x_endDate     IN Item end date.
--                       x_rootProcess IN Item root activity.
--                       x_rootVersion IN Item root activity version.
--
-- ===========================================================================
FUNCTION getItemStatus(x_itemType    IN varchar2,
                       x_itemKey     IN varchar2,
                       x_endDate     IN date,
                       x_rootProcess IN varchar2,
                       x_rootVersion IN number) RETURN varchar2;


-- ===========================================================================
-- FUNCTION NAME:        getRoleEmailAddress
--
-- DESCRIPTION:          Returns an email address for a role.
--
-- PARAMETERS:           x_role_name IN  Role internal name.
--
-- ===========================================================================
FUNCTION getRoleEmailAddress (x_role_name in varchar2) RETURN varchar2;


-- ===========================================================================
--  FUNCTION NAME:        getEncryptedAccessKey
--
--  DESCRIPTION:          Returns an encrypted Monitor access key for the given
--                        item type, item key and admin mode.
--
--  PARAMETERS:
--          itemType  IN  valid workflow item type
--          itemKey   IN  valid workflow item key
--          adminMode IN  valid options include: 'Y' to grant administrator
--                        privileges or 'N' to withhold them
--
-- =============================================================================
/*#
 * This API returns an encrypted access key password
 * that controls access to the specified workflow process
 * instance in the Status Monitor with the specified
 * administrator mode. The administrator mode lets you
 * determine whether the user who accesses the Status
 * Monitor with this access key should have privileges
 * to perform administrative operations in the Status Monitor.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param adminmode Administrator Mode
 * @return AccessKey
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Get Encrypted Access Key
 * @rep:ihelp FND/@stmonapi#a_fmgeak See the related online help
 */
FUNCTION getEncryptedAccessKey (itemType in varchar2,
                                itemKey in varchar2,
                                adminMode in varchar2 default 'N') RETURN varchar2;


-- ===========================================================================
--  FUNCTION NAME:        getEncryptedAdminMode
--
--  DESCRIPTION:          Returns an encrypted value for the given administrator
--                        mode.
--
--  PARAMETERS:
--          adminMode IN  valid options include: 'Y' to grant administrator
--                        privileges or 'N' to withhold them
--
-- ============================================================================
/*#
 * This API returns an encrypted value for the
 * specified administrator mode. The administrator
 * mode lets you determine whether a user accessing
 * the Status Monitor should have privileges to perform
 * administrative operations in the Status Monitor.
 * @param adminmode Administrator Mode
 * @return Encrypted AdminMode
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Get Encrypted Admin Mode
 * @rep:ihelp FND/@stmonapi#a_fmgeam See the related online help
 */
FUNCTION getEncryptedAdminMode (adminMode in varchar2) RETURN varchar2;


-- ===========================================================================
--  FUNCTION NAME:        isMonitorAdministrator
--
--  DESCRIPTION:          Returns 'Y' if the given user has Workflow Administrator
--                        privileges and 'N' if he/she does not.
--
--  PARAMETERS:
--          userName IN valid username - e.g. 'BLEWIS'
--
-- ============================================================================
/*#
 * This API returns 'Y' if the specified user has
 * workflow administrator privileges, or 'N' if the
 * specified user does not have workflow
 * administrator privileges. Workflow administrator privileges
 * are assigned in the Workflow Configuration page.
 * @param userName User Name
 * @return isMonitorAdministrator
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname is Monitor Administrator
 * @rep:ihelp FND/@stmonapi#a_fmima See the related online help
 */
FUNCTION isMonitorAdministrator(userName in varchar2) RETURN varchar2;


-- ============================================================================
--  FUNCTION NAME:        getAnonymousSimpleURL
--
--  DESCRIPTION:          Returns a complete URL allowing for anonymous, guest
--                        access to the simple,"Guest" Status Monitor.
--
--                        The URL will be in the following form:
--
--  http://<Apps PL/SQL Web Agent>/wf_fwkmon.GuestMonitor?<params>
--
--			  The access key and admin mode parameters will be encrypted.
--                        The item type, item key, access key and admin mode parameters
--                        will be encoded.
--
--  PARAMETERS:
--          itemType  IN  a valid workflow item type
--          itemKey   IN  a valid workflow item key
--          firstPage IN  valid options include:  'HISTORY' to go to the
--                        Notification History page or 'DIAGRAM' to go to
--                        the Status Diagram page
--          adminMode IN  valid options include:  'Y' to grant administrator
--                        privileges or 'N' to withhold them
--
-- =============================================================================
FUNCTION getAnonymousSimpleURL(itemType in varchar2,
                               itemKey in varchar2,
			       firstPage in varchar2 default 'HISTORY',
                               adminMode in varchar2 default 'N') RETURN varchar2;


-- =============================================================================
--  FUNCTION NAME:        getAnonymousAdvanceURL
--
--  DESCRIPTION:          Returns a complete URL allowing for anonymous, guest
--                        access to the advanced,"Guest" Status Monitor.
--
--                        The URL will be in the following form:
--
--  http://<Apps PL/SQL Web Agent>/wf_fwkmon.GuestMonitor?<params>
--
--			  The access key and admin mode parameters will be encrypted.
--                        The item type, item key, access key and admin mode parameters
--                        will be encoded.
--
--  PARAMETERS:
--          itemType  IN  a valid workflow item type
--          itemKey   IN  a valid workflow item key
--          firstPage IN  valid options include:  'HISTORY' to go to the
--                        Activity History page or 'DIAGRAM' to go to
--                        the Status Diagram page
--          adminMode IN  valid options include:  'Y' to grant administrator
--                        privileges or 'N' to withhold them
--
-- =============================================================================
FUNCTION getAnonymousAdvanceURL(itemType in varchar2,
                                itemKey in varchar2,
                                firstPage in varchar2 default 'HISTORY',
                                adminMode in varchar2 default 'N') RETURN varchar2;


-- ==============================================================================
--  FUNCTION NAME:        getGuestMonitorURL
--
--  DESCRIPTION:          Returns a URL allowing for anonynmous, guest access to
--                        the simple or advanced OA Framework Status Monitor as
--                        specified by the parameters.
--
--			  ** NOTE:  this is not intended to be called directly
--                        ** outside of Workflow.
--
--                        Please call getAnonymousSimpleURL() or
--                        getAnonymousAdvanceURL() to obtain the URL that
--                        calls the GuestMonitorURL procedure, or call the
--                        corresponding methods in the following Java class:
--
--			  oracle.apps.fnd.wf.monitor.webui.Monitor
--
--  PARAMETERS:
--          akRegionApplicationId IN  target page AK region application id
--                                    (always 0 in this case)
--          akRegionCode          IN  target page AK region code
--          accessKey             IN  must be an encrypted, encoded Monitor accessKey
--                                    value that is valid for the given adminMode, itemType
--                                    and itemKey
--          adminMode             IN  must be an encrypted, encoded adminMode value that is
--                                    valid for the given accessKey, itemType and itemKey
--          itemType              IN  a valid workflow item type
--          itemKey               IN  a valid workflow item key
--
-- ==============================================================================
FUNCTION getGuestMonitorURL (akRegionApplicationId in varchar2 default null,
                             akRegionCode in varchar2 default null,
                             accessKey in varchar2 default null,
                             adminMode in varchar2 default null,
                             itemType in varchar2 default null,
                             itemKey in varchar2 default null) RETURN varchar2;


-- ============================================================================
--  PROCEDURE NAME:       GuestMonitor
--
--  DESCRIPTION:          Called when a URL constructed in getGuestMonitorURL
--                        is invoked.  Logs the user in as GUEST
--                        and redirect to the OA Framework Status Monitor.
--
--			  NOTE: if the user already has an ICX session, this will
--                        be reused and a new session for the GUEST user will not
--                        be created.
--
--  PARAMETERS:
--          akRegionApplicationId IN  target page AK region application id
--                                    (always 0 in this case)
--          akRegionCode          IN  target page AK region code
--          wa                    IN  must be an encrypted, encoded Monitor accessKey value
--                                    that is valid for the given adminMode, itemType and itemKey
--                                    Must be encrypted using the routine in this pacakge, or in
--                                    oracle.apps.fnd.wf.monitor.webui.Monitor class
--          wm                    IN  must be an encrypted, encoded adminMode value that is valid
--                                    for the given accessKey, itemType and itemKey.  Must be
--                                    encrypted using the routine in this package, or in the
--                                    oracle.apps.fnd.wf.monitor.webui.Monitor class
--          itemType              IN  a valid encoded workflow item type
--          itemKey               IN  a valid encoded workflow item key
--
-- ==============================================================================
PROCEDURE GuestMonitor (akRegionApplicationId in varchar2 default null,
                        akRegionCode in varchar2 default null,
                        wa in varchar2 default null,
                        wm in varchar2 default null,
                        itemType in varchar2 default null,
                        itemKey  in varchar2 default null);

--
-- GetNtfResponderName
--   Function to return the Notification Responder's display name
--
--    a) Call wf_directory.GetRoleDisplayName2.
--    b) If null, retrieve column value WF_COMMENTS.FROM_USER
--       for RESPOND action on the notification id.
--
-- IN
--   p_notification_id - Notification ID
-- RETURN
--   Responder's display anme
--
function GetNtfResponderName(p_notification_id in number)
return varchar2;

end wf_fwkmon;

/
