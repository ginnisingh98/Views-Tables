--------------------------------------------------------
--  DDL for Package WF_DIRECTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_DIRECTORY" AUTHID CURRENT_USER as
/* $Header: wfdirs.pls 120.12.12010000.6 2013/09/05 02:53:22 alsosa ship $ */
/*#
 * Provides APIs that can be
 * called by an application program or a workflow
 * function in the runtime phase to retrieve information
 * about existing users and roles, as well as to create
 * and manage new ad hoc users and roles in the
 * directory service.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Directory Services
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_USER
 * @rep:ihelp FND/@a_ds See the related online help
 */

type UserTable is table of varchar2(320)
  index by binary_integer;

type RoleTable is table of varchar2(320)
  index by binary_integer;

type OrigSysTable is table of varchar2(30) index by binary_integer;

/*===========================================================================

  PL*SQL TABLE NAME:    wf_local_roles_tble_type

  DESCRIPTION:          Stores a list of attributes from
                        WF_LOCAL_ROLES

============================================================================*/

TYPE wf_local_roles_rec_type IS RECORD
(
 NAME                            VARCHAR2(320),
 DISPLAY_NAME                    VARCHAR2(360),
 DESCRIPTION                     VARCHAR2(1000),
 NOTIFICATION_PREFERENCE         VARCHAR2(8),
 LANGUAGE                        VARCHAR2(64),
 TERRITORY                       VARCHAR2(64),
 NLS_DATE_FORMAT                 varchar2(64), -- <7578908> full NLS support
 NLS_DATE_LANGUAGE               varchar2(64),
 NLS_CALENDAR                    varchar2(64),
 NLS_NUMERIC_CHARACTERS          varchar2(64),
 NLS_SORT                        varchar2(64),
 NLS_CURRENCY                    varchar2(64), -- </7578908>
 EMAIL_ADDRESS                   VARCHAR2(320),
 FAX                             VARCHAR2(240),
 STATUS                          VARCHAR2(8),
 EXPIRATION_DATE                 DATE,
 ORIG_SYSTEM                     VARCHAR2(240),
 ORIG_SYSTEM_ID                  NUMBER,
 PARENT_ORIG_SYSTEM              VARCHAR2(240),
 PARENT_ORIG_SYSTEM_ID           NUMBER,
 OWNER_TAG                       VARCHAR2(50),
 LAST_UPDATE_DATE                DATE,
 LAST_UPDATED_BY                 NUMBER(15),
 CREATION_DATE                   DATE,
 CREATED_BY                      NUMBER(15),
 LAST_UPDATE_LOGIN               NUMBER(15)
);

TYPE wf_local_roles_tbl_type IS TABLE OF
  wf_directory.wf_local_roles_rec_type
INDEX BY BINARY_INTEGER;

/*#
 * Returns a table of the users
 * that belong to the specified role.
 * @param role Role
 * @param users Users
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Role Users
 * @rep:ihelp FND/@a_ds#a_getru See the related online help
 */

procedure GetRoleUsers(
  Role in varchar2,
  Users out nocopy Wf_Directory.UserTable);

procedure GetUserRelation(
  Base_User in varchar2,
  Relation in varchar2,
  Users out nocopy Wf_Directory.UserTable);

/*#
 * Returns a table of the roles to which
 * the specified user belongs.
 * @param user User
 * @param roles Roles
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get User Roles
 * @rep:ihelp FND/@a_ds#a_getur See the related online help
 */

procedure GetUserRoles(
  User in varchar2,
  Roles out nocopy Wf_Directory.RoleTable);

/*#
 * Returns the display name,
 * email address, notification preference, language and
 * territory for the specified role.
 * @param role Role
 * @param display_name Display Name
 * @param email_address E-mail Address
 * @param notification_preference Notification Preference
 * @param language Language
 * @param territory Territory
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Role Info
 * @rep:ihelp FND/@a_ds#a_getrinf See the related online help
 */

procedure GetRoleInfo(
  Role in varchar2,
  Display_Name out nocopy varchar2,
  Email_Address out nocopy varchar2,
  Notification_Preference out nocopy varchar2,
  Language out nocopy varchar2,
  Territory out nocopy varchar2);

/*#
 * Returns information about the specified role in a PL/SQL table,
 * including the role's internal name, display name, description,
 * notification preference, e-mail address,
 * fax, status, expiration date, originating system,
 * originating system ID, parent originating system,
 * parent originating system ID, owner tag, NLS parameters
 * (NLS_LANGUAGE, NLS_TERRITORY, NLS_DATE_FORMAT, NLS_DATE_LANGUAGE,
 * NLS_CALENDAR, NLS_NUMERIC_CHARACTERS, NLS_SORT, and NLS_CURRENCY),
 * and standard Who columns.
 * @param role Role
 * @param Role_Info_Tbl Role Info Table
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Role Info Table
 * @rep:ihelp FND/@a_ds#a_getrinf2 See the related online help
 */


procedure GetRoleInfo2(
  Role in varchar2,
  Role_Info_Tbl out nocopy wf_directory.wf_local_roles_tbl_type);

procedure GetRoleInfoMail(
  role in varchar2,
  display_name out nocopy varchar2,
  email_address out nocopy varchar2,
  notification_preference out nocopy varchar2,
  language out nocopy varchar2,
  territory out nocopy varchar2,
  orig_system out nocopy varchar2,
  orig_system_id out nocopy number,
  installed_flag out nocopy varchar2);

  /* (private)
   *
   * Returns role attributes for the given role. NLS attribute values are obtained
   * from EBS profile values when the role orig system is either FND_USR or PER.
   * Created for phase 1 of full NLS support changes, bug 7578908.
   */
  procedure GetRoleInfoMail2( p_role in varchar2,
                              p_display_name out NOCOPY varchar2,
                              p_email_address out NOCOPY varchar2,
                              p_notification_preference out NOCOPY varchar2,
                              p_orig_system out NOCOPY varchar2,
                              p_orig_system_id out NOCOPY number,
                              p_installed_flag out NOCOPY varchar2
                            , p_nlsLanguage out NOCOPY varchar2,
                              p_nlsTerritory out NOCOPY varchar2
                            , p_nlsDateFormat out NOCOPY varchar2
                            , p_nlsDateLanguage out NOCOPY varchar2
                            , p_nlsCalendar out NOCOPY varchar2
                            , p_nlsNumericCharacters out NOCOPY varchar2
                            , p_nlsSort out NOCOPY varchar2
                            , p_nlsCurrency out NOCOPY varchar2);
--
-- GetRoleOrigSysInfo (PRIVATE)
-- Used by Workflow Internal Only
--
procedure GetRoleOrigSysInfo(
  Role in varchar2,
  Orig_System out nocopy varchar2,
  Orig_System_Id out nocopy number);

--
-- GetRolePartitionInfo (PRIVATE)
-- Used by Workflow Internal Only
--
procedure GetRolePartitionInfo(
  role in varchar2,
  partition_id out nocopy number,
  orig_system out nocopy varchar2,
  display_name out nocopy varchar2);

--
-- GetRoleNtfPref (PRIVATE)
-- Used by Workflow Internal
-- To obtain notification preference
-- for a given role

function GetRoleNtfPref(
  Role in varchar2)
return varchar2;

/*#
 * Returns TRUE or FALSE to identify
 * whether the specified user is a performer of
 * the specified role.
 * @param user User
 * @param role Role
 * @return Is Performer
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Is Performer
 * @rep:ihelp FND/@a_ds#a_isperf See the related online help
 */

function IsPerformer(
    User in varchar2,
    Role in varchar2)
return boolean;

function CurrentUser
return varchar2;
--
-- Function determins if a user is currently active
-- and therefore available to participate in a workflow
--  In :
--      Username
-- Returns:
--      True  - If user is Active
--      False - If User is NOT Active
--
/*#
 * Returns TRUE or FALSE to identify whether
 * the specified user currently has a status of 'ACTIVE'
 * and is available to participate
 * in a workflow
 * @param username User Name
 * @return Is Active
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname User Active
 * @rep:ihelp FND/@a_ds#a_usract See the related online help
 */

function UserActive(username in varchar2)
return boolean;

--  RoleActive
--  Scope: public internal
--  Returns TRUE or FALSE to say if a user or role is active
--  Internally calls UserActive
--  IN
--    rolename
--  RETURN:
--   True  - If user or role is Active
--   False - If User or role is NOT Active
function RoleActive(p_rolename in varchar2)
return boolean;

--
-- Procedure Gets the User_name given the orig system info
--   Get the username
-- IN:
--      orig_system     - Code identifying the original table
--      orig_system_id  - Id of the row in original table
-- Returns:
--      user_name       - Workflow user_name
--
/*#
 * Returns the Workflow display name and internal name
 * for a user given the identifying information for that
 * user in the directory repository from which it originated.
 * @param p_orig_system Originating System
 * @param p_orig_system_id Originating System ID
 * @param p_name Name
 * @param p_display_name Display Name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get User Name
 * @rep:ihelp FND/@a_ds#a_getun See the related online help
 */

procedure GetUserName ( p_orig_system           in varchar2,
                        p_orig_system_id        in varchar2,
                        p_name                  out nocopy varchar2,
                        p_display_name          out nocopy varchar2 );
--
--
--
-- Procedure Gets the Role_name given the orig system info
--   Get the Role name
-- IN:
--      orig_system     - Code identifying the original table
--      orig_system_id  - Id of the row in original table
-- Returns:
--      Role_name       - Workflow role_name
--
/*#
 * Returns the  Workflow display name
 * and internal name for a role given the
 * identifying information for that role in the
 * directory repository from which it originated.
 * @param p_orig_system Originating System
 * @param p_orig_system_id Originating System ID
 * @param p_name Name
 * @param p_display_name Display Name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Role Name
 * @rep:ihelp FND/@a_ds#a_grname See the related online help
 */

procedure GetRoleName ( p_orig_system           in varchar2,
                        p_orig_system_id        in varchar2,
                        p_name                  out nocopy varchar2,
                        p_display_name          out nocopy varchar2 );
--
/*#
 * Returns a Workflow role's display
 * name given an active role's internal name.
 * @param p_role_name Role Name
 * @return Display Name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Active Role Display Name
 * @rep:ihelp FND/@a_ds#a_grdname See the related online help
 */

function GetRoleDisplayName(p_role_name in varchar2)
return varchar2;
pragma restrict_references(GetRoleDisplayName, WNDS, WNPS);

/*#
 * Returns Workflow role's display
 * name given the role's internal name(active/inactive).
 * @param p_role_name Role Name
 * @return Display Name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Role Display Name
 * @rep:ihelp FND/@a_ds#a_grdname See the related online help
 */

function GetRoleDisplayName2(p_role_name in varchar2)
return varchar2;
pragma restrict_references(GetRoleDisplayName2, WNDS, WNPS);
--
--

--
-- SetAdHocUserStatus
--   Update status for user
-- IN
--   user_name        -
--   status           - status could be 'ACTIVE' or 'INACTIVE'
-- OUT
--
/*#
 * Sets the status of an ad hoc user
 * as 'ACTIVE' or 'INACTIVE'.
 * @param user_name User Name
 * @param status Status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Ad Hoc User Status
 * @rep:ihelp FND/@a_ds#a_sahust See the related online help
 */

procedure SetAdHocUserStatus(user_name      in varchar2,
                        status         in varchar2 default 'ACTIVE');

--
-- SetAdHocRoleStatus
--   Update status for role
-- IN
--   role_name        -
--   status           - status could be 'ACTIVE' or 'INACTIVE'
-- OUT
--
/*#
 * Sets the status of an ad hoc role as
 * 'ACTIVE' or 'INACTIVE'.
 * @param role_name Role Name
 * @param status Status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Ad Hoc Role Status
 * @rep:ihelp FND/@a_ds#a_sahrs See the related online help
 */

procedure SetAdHocRoleStatus(role_name      in varchar2,
                        status         in varchar2 default 'ACTIVE');



--
-- CreateUser (PRIVATE)
--   Create a User
-- IN
--   name          - User name
--   display_name  - User display name
--   orig_system
--   orig_system_id
--   language      -
--   territory     -
--   description   -
--   notification_preference -
--   email_address -
--   fax           -
--   status        -
--   expiration_date - NULL expiration date means no expiration
--   start_date
--   parent_orig_system
--   parent_orig_system_id
--   owner_tag -
--   last_update_date -
--   last_updated_by -
--   creation_date -
--   created_by -
--   last_update_login
-- OUT
--
procedure CreateUser( name                    in  varchar2,
                      display_name            in  varchar2,
                      orig_system             in  varchar2,
                      orig_system_id          in  number,
                      language                in  varchar2 default null,
                      territory               in  varchar2 default null,
                      description             in  varchar2 default null,
                      notification_preference in  varchar2 default 'MAILHTML',
                      email_address           in  varchar2 default null,
                      fax                     in  varchar2 default null,
                      status                  in  varchar2 default 'ACTIVE',
                      expiration_date         in  date     default NULL,
                      start_date              in  date     default sysdate,
                      parent_orig_system      in  varchar2 default null,
                      parent_orig_system_id   in  number   default null,
                      owner_tag               in  varchar2 default null,
                      last_update_date        in  date     default sysdate,
                      last_updated_by         in  number   default null,
                      creation_date           in  date     default sysdate,
                      created_by              in  number   default null,
                      last_update_login       in  number   default null,
                      source_lang             in  varchar2 default userenv('LANG'));


--
-- CreateAdHocUser
--   Create an ad hoc user given a user name, display name, etc.
-- IN
--   name          - User name
--   display_name  - User display name
--   description   -
--   notification_preference -
--   language      -
--   territory     -
--   email_address -
--   fax           -
--   status        -
--   expiration_date - NULL expiration date means no expiration
-- OUT
--
/*#
 * Creates a user in the Workflow local directory service tables
 * at runtime. This is referred to as an ad hoc user.
 * @param name Name
 * @param display_name Display Name
 * @param language Language
 * @param territory Territory
 * @param description Description
 * @param notification_preference Notification Preference
 * @param email_address Email Address
 * @param fax Fax
 * @param status Status
 * @param expiration_date Expiration Date
 * @param parent_orig_system Parent Originating System
 * @param parent_orig_system_id Parent Originating System ID
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Ad Hoc User
 * @rep:ihelp FND/@a_ds#a_crahu See the related online help
 */

procedure CreateAdHocUser(name                in out nocopy varchar2,
                      display_name            in out nocopy  varchar2,
                      language                in  varchar2 default null,
                      territory               in  varchar2 default null,
                      description             in  varchar2 default null,
                      notification_preference in varchar2 default null,
                      email_address           in  varchar2 default null,
                      fax                     in  varchar2 default null,
                      status                  in  varchar2 default 'ACTIVE',
                      expiration_date         in  date default null,
                      parent_orig_system      in varchar2 default null,
                      parent_orig_system_id   in number   default null);


--
-- CreateRole (PRIVATE)
--   Create an ad hoc role given a specific name
-- IN
--   role_name          -
--   role_display_name  -
--   role_description   -
--   notification_preference -
--   language      -
--   territory     -
--   email_address -
--   fax           -
--   status        -
--   expiration_date   - Null means no expiration date
--   orig_system   -
--   orig_system_id
-- OUT
--
procedure CreateRole( role_name               in  varchar2,
                      role_display_name       in  varchar2,
                      orig_system             in  varchar2,
                      orig_system_id          in  number,
                      language                in  varchar2 default null,
                      territory               in  varchar2 default null,
                      role_description        in  varchar2 default null,
                      notification_preference in  varchar2 default null,
                      email_address           in  varchar2 default null,
                      fax                     in  varchar2 default null,
                      status                  in  varchar2 default 'ACTIVE',
                      expiration_date         in  date default NULL,
                      start_date              in  date default sysdate,
                      parent_orig_system      in  varchar2 default null,
                      parent_orig_system_id   in  number   default null,
                      owner_tag               in  varchar2 default null,
                      last_update_date        in  date     default sysdate,
                      last_updated_by         in  number   default null,
                      creation_date           in  date     default sysdate,
                      created_by              in  number   default null,
                      last_update_login       in  number   default null,
                      source_lang             in  varchar2 default userenv('LANG'));




--
-- CreateAdHocRole
--   Create an ad hoc role given a specific name
-- IN
--   role_name          -
--   role_display_name  -
--   role_description   -
--   notification_preference -
--   role_users         - Comma or space delimited list
--   language      -
--   territory     -
--   email_address -
--   fax           -
--   status        -
--   expiration_date   - Null means no expiration date
-- OUT
--
/*#
 * Creates a role in the Workflow local directory
 * service tables at runtime. This is referred to as an
 * ad hoc role.
 * @param role_name Role Name
 * @param role_display_name Role Display Name
 * @param language Language
 * @param territory Territory
 * @param role_description Role Description
 * @param notification_preference Notification Preference
 * @param role_users Role Users
 * @param email_address Email Address
 * @param fax Fax
 * @param status Status
 * @param expiration_date Expiration Date
 * @param parent_orig_system Parent Originating System
 * @param parent_orig_system_id Parent Originating System ID
 * @param owner_tag Owner Tag
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Ad Hoc Role
 * @rep:ihelp FND/@a_ds#a_crahr See the related online help
 */

procedure CreateAdHocRole(role_name           in out nocopy varchar2,
                      role_display_name       in out nocopy  varchar2,
                      language                in  varchar2 default null,
                      territory               in  varchar2 default null,
                      role_description        in  varchar2 default null,
                      notification_preference in varchar2 default null,
                      role_users              in  varchar2 default null,
                      email_address           in  varchar2 default null,
                      fax                     in  varchar2 default null,
                      status                  in  varchar2 default 'ACTIVE',
                      expiration_date         in  date default null,
                      parent_orig_system      in varchar2 default null,
                      parent_orig_system_id   in number default null,
                      owner_tag               in  varchar2 default null);



--
-- CreateAdHocRole2
--   Create an ad hoc role given a specific name
-- IN
--   role_name          -
--   role_display_name  -
--   role_description   -
--   notification_preference -
--   role_users         - Comma or space delimited list
--   language      -
--   territory     -
--   email_address -
--   fax           -
--   status        -
--   expiration_date   - Null means no expiration date
-- OUT
--
procedure CreateAdHocRole2(role_name          in out nocopy varchar2,
                      role_display_name       in out nocopy  varchar2,
                      language                in  varchar2 default null,
                      territory               in  varchar2 default null,
                      role_description        in  varchar2 default null,
                      notification_preference in  varchar2 default null,
                      role_users              in  WF_DIRECTORY.UserTable,
                      email_address           in  varchar2 default null,
                      fax                     in  varchar2 default null,
                      status                  in  varchar2 default 'ACTIVE',
                      expiration_date         in  date default null,
                      parent_orig_system      in  varchar2 default null,
                      parent_orig_system_id   in  number default null,
                      owner_tag               in  varchar2 default null);


--
-- CreateUserRole (PRIVATE)
--   Create a user to role relationship.
-- IN
--   user_name -
--   role_name -
--   user_orig_system -
--   user_orig_system_id -
--   role_orig_system -
--   role_orig_system_id -
--
procedure CreateUserRole(user_name             in varchar2,
                         role_name             in varchar2,
                         user_orig_system      in varchar2 default NULL,
                         user_orig_system_id   in number default NULL,
                         role_orig_system      in varchar2 default NULL,
                         role_orig_system_id   in number default NULL,
                         validateUserRole      in boolean default TRUE,
                         start_date            in date default sysdate,
                         end_date              in date default NULL,
                         created_by            in number default -1,
                         creation_date         in date default sysdate,
                         last_updated_by       in number default -1,
                         last_update_date      in date default sysdate,
                         last_update_login     in number default -1,
                         assignment_type       in varchar2 default 'D',
                         parent_orig_system    in varchar2 default NULL,
                         parent_orig_system_id in number default null,
                         owner_tag             in  varchar2 default null,
                         assignment_reason     in  varchar2 default null,
                         eventParams           in wf_parameter_list_t default null);


--
-- SetUserRoleAttr (PRIVATE)
--   Update a user to role relationship.
-- IN
--   user_name -
--   role_name -
--   start_date -
--   expiration_date -
--   user_orig_system -
--   user_orig_system_id -
--   role_orig_system -
--   role_orig_system_id -
--   assignment_type -
--   parent_orig_system -
--   parent_orig_system_id
--   owner_tag -
--
procedure SetUserRoleAttr ( user_name             in  varchar2,
                            role_name             in  varchar2,
                            start_date            in  date     default NULL,
                            end_date              in  date     default NULL,
                            user_orig_system      in  varchar2,
                            user_orig_system_id   in  number,
                            role_orig_system      in  varchar2,
                            role_orig_system_id   in  number,
                            OverWrite             in  boolean  default FALSE,
                            last_updated_by       in  number   default -1,
                            last_update_date      in  date     default sysdate,
                            last_update_login     in  number   default -1,
                            created_by            in number    default NULL,
                            creation_date         in date      default NULL,
                            assignment_type       in  varchar2 default 'D',
                            parent_orig_system    in  varchar2 default null,
                            parent_orig_system_id in  number   default null,
                            owner_tag             in  varchar2 default null,
                            assignment_reason     in  varchar2 default null,
                            updateWho            in BOOLEAN   default null,
                            eventParams          in wf_parameter_list_t default null);


--
-- RemoveUserRole (PRIVATE)
--   Remove a user from a role.
-- IN
--   user_name -
--   role_name -
--   user_orig_system -
--   user_orig_system_id -
--   role_orig_system -
--   role_orig_system_id -
--
procedure RemoveUserRole(user_name           in varchar2,
                         role_name           in varchar2,
                         user_orig_system    in varchar2,
                         user_orig_system_id in number,
                         role_orig_system    in varchar2,
                         role_orig_system_id in number);

--
-- AddUsersToAdHocRole
--   Add users to an existing ad hoc role
-- IN
--   role_name     - AdHoc role name
--   role_users    - Space or comma delimited list of apps-based users
--                      or adhoc users
-- OUT
--
/*#
 * Adds users to an existing ad hoc role.
 * @param role_name Role Name
 * @param role_users Role Users
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Add Users To Ad Hoc Role
 * @rep:ihelp FND/@a_ds#a_autahr See the related online help
 */
procedure AddUsersToAdHocRole(role_name         in varchar2,
                              role_users       in  varchar2);

--
-- AddUsersToAdHocRole2
--   Add users to an existing ad hoc role
-- IN
--   role_name     - AdHoc role name
--   role_users    - Table of user names.
--
-- OUT
--
procedure AddUsersToAdHocRole2(role_name         in varchar2,
                               role_users        in WF_DIRECTORY.UserTable);

--
-- SetUserAttr (PRIVATE)
--   Update additional attributes for users
-- IN
--   user_name        - user name
--   orig_system      -
--   orig_system_id   -
--   display_name  -
--   description -
--   notification_preference -
--   language      -
--   territory     -
--   email_address -
--   fax           -
--   expiration_date  - New expiration date
--   status           - status could be 'ACTIVE' or 'INACTIVE'
--   start_date
--   OverWrite  - Turns off existing data protection.
--   parent_orig_system -
--   parent_orig_system_id -
--   owner_tag
-- OUT
--
procedure SetUserAttr(user_name               in  varchar2,
                      orig_system             in  varchar2,
                      orig_system_id          in  number,
                      display_name            in  varchar2 default null,
                      description             in  varchar2 default null,
                      notification_preference in varchar2  default null,
                      language                in  varchar2 default null,
                      territory               in  varchar2 default null,
                      email_address           in  varchar2 default null,
                      fax                     in  varchar2 default null,
                      expiration_date         in  date     default null,
                      status                  in  varchar2 default null,
                      start_date              in  date     default null,
                      OverWrite               in  boolean  default FALSE,
                      Parent_Orig_System      in  varchar2 default null,
                      Parent_Orig_System_ID   in  number   default null,
                      owner_tag               in  varchar2 default null,
                      last_updated_by         in  number   default null,
                      last_update_date        in  date     default null,
                      last_update_login       in  number   default null,
                      created_by              in  number   default null,
                      creation_date           in  date     default null,
                      eventParams             in  wf_parameter_list_t default null,
                      source_lang             in  varchar2 default userenv('LANG'));

--
-- SetRoleAttr (PRIVATE)
--   Update additional attributes for roles
-- IN
--   role_name        - role name
--   orig_system      -
--   orig_system_id   -
--   display_name  -
--   notification_preference -
--   language      -
--   territory     -
--   email_address -
--   fax           -
--   expiration_date  - New expiration date
--   status           - status could be 'ACTIVE' or 'INACTIVE'
--   start_date
--   OverWrite - Turns off existing data protection.
-- OUT
--
procedure SetRoleAttr(role_name               in  varchar2,
                      orig_system             in  varchar2,
                      orig_system_id          in  number,
                      display_name            in  varchar2 default null,
                      description             in  varchar2 default null,
                      notification_preference in  varchar2 default null,
                      language                in  varchar2 default null,
                      territory               in  varchar2 default null,
                      email_address           in  varchar2 default null,
                      fax                     in  varchar2 default null,
                      expiration_date         in  date     default null,
                      status                  in  varchar2 default null,
                      start_date              in  date     default null,
                      OverWrite               in  boolean  default FALSE,
                      Parent_Orig_System      in  varchar2 default null,
                      Parent_Orig_System_ID   in  number   default null,
                      owner_tag               in  varchar2 default null,
                      last_updated_by         in  number   default null,
                      last_update_date        in  date     default sysdate,
                      last_update_login       in  number   default null,
                      created_by              in  number   default null,
                      creation_date           in  date     default null,
                      eventParams             in  wf_parameter_list_t default null,
                      source_lang             in  varchar2 default userenv('LANG'));

--
-- SetAdHocUserExpiration
--   Update expiration date for ad hoc users
-- IN
--   user_name        - Ad hoc user name
--   expiration_date  - New expiration date
-- OUT
--
/*#
 * Updates the expiration date for
 * an ad hoc user.
 * @param user_name User Name
 * @param expiration_date Expiration Date
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Ad Hoc User Expiration
 * @rep:ihelp FND/@a_ds#a_sahue See the related online help
 */

procedure SetAdHocUserExpiration(user_name      in varchar2,
                      expiration_date           in date default sysdate);

--
-- SetAdHocRoleExpiration
--   Update expiration date for ad hoc roles, user roles
-- IN
--   role_name        - Ad hoc role name
--   expiration_date  - New expiration date
-- OUT
--
/*#
 * Updates the expiration date for
 * an ad hoc role.
 * @param role_name Role Name
 * @param expiration_date Expiration Date
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Ad Hoc Role Expiration
 * @rep:ihelp FND/@a_ds#a_sahre See the related online help
 */

procedure SetAdHocRoleExpiration(role_name      in varchar2,
                      expiration_date           in date default sysdate);

--
-- SetAdHocUserAttr
--   Update additional attributes for ad hoc users
-- IN
--   user_name        - Ad hoc user name
--   display_name  -
--   notification_preference -
--   language      -
--   territory     -
--   email_address -
--   fax           -
-- OUT
--
/*#
 * Updates the attributes for an ad hoc user.
 * @param user_name User Name
 * @param display_name Display Name
 * @param notification_preference Notification Preference
 * @param language Language
 * @param territory Territory
 * @param email_address E-mail address
 * @param fax Fax
 * @param parent_orig_system Parent Originating System
 * @param parent_orig_system_id Parent Originating System ID
 * @param owner_tag Owner Tag
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Ad Hoc User Attributes
 * @rep:ihelp FND/@a_ds#a_sahua See the related online help
 */

procedure SetAdHocUserAttr(user_name               in  varchar2,
                           display_name            in  varchar2 default null,
                           notification_preference in  varchar2 default null,
                           language                in  varchar2 default null,
                           territory               in  varchar2 default null,
                           email_address           in  varchar2 default null,
                           fax                     in  varchar2 default null,
                           parent_orig_system      in  varchar2 default null,
                           parent_orig_system_id   in  number   default null,
                           owner_tag               in  varchar2 default null);

--
-- SetAdHocRoleAttr
--   Update additional attributes for ad hoc roles, user roles
-- IN
--   role_name        - Ad hoc role name
--   display_name  -
--   notification_preference -
--   language      -
--   territory     -
--   email_address -
--   fax           -
-- OUT
--
/*#
 * Updates the attributes for an ad hoc role.
 * @param role_name Role Name
 * @param display_name Display Name
 * @param notification_preference Notification Preference
 * @param language Language
 * @param territory Territory
 * @param email_address E-mail address
 * @param fax Fax
 * @param parent_orig_system Parent Originating System
 * @param parent_orig_system_id Parent Originating System ID
 * @param owner_tag Owner Tag
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Ad Hoc Role Attributes
 * @rep:ihelp FND/@a_ds#a_sahra See the related online help
 */
procedure SetAdHocRoleAttr(role_name          in  varchar2,
                      display_name            in  varchar2 default null,
                      notification_preference in  varchar2 default null,
                      language                in  varchar2 default null,
                      territory               in  varchar2 default null,
                      email_address           in  varchar2 default null,
                      fax                     in  varchar2 default null,
                      parent_orig_system      in  varchar2 default null,
                      parent_orig_system_id   in  number   default null,
                      owner_tag               in  varchar2 default null);

--
-- RemoveUsersFromAdHocRole
--   Remove users from an existing ad hoc role
-- IN
--   role_name     -
--   role_users    -
-- OUT
--
/*#
 * Removes users from an existing
 * ad hoc role.
 * @param role_name Role Name
 * @param role_users Role Users
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Remove Users From Ad Hoc Role
 * @rep:ihelp FND/@a_ds#a_rufahr See the related online help
 */

procedure RemoveUsersFromAdHocRole(role_name in varchar2,
                      role_users             in varchar2 default null);

--
-- ChangeLocalUserName
--  Change a User's Name in the WF_LOCAL_USERS table.
-- IN
--  OldName
--  NewName
--  Propagate - call WF_MAINTENANCE.PropagateChangedName.
-- OUT
--
function ChangeLocalUserName(OldName in varchar2,
                             NewName in varchar2,
                             Propagate in boolean default true)
return BOOLEAN;

--
-- ReassignUserRoles
--   Reassigns user/roles when the user information changes.
-- IN
--   p_user_name
--   p_old_user_origSystem
--   p_old_user_origSystemID
--   p_new_user_origSystem
--   p_new_user_origSystemID
--   p_last_update_date
--   p_last_updated_by
--   p_last_update_login
--   p_overWriteUserRoles - if TRUE, provided new column values should not be null for the
--                 corresponding column update to happen.
-- OUT
--
procedure ReassignUserRoles (p_user_name             in VARCHAR2,
                             p_old_user_origSystem   in VARCHAR2,
                             p_old_user_origSystemID in VARCHAR2,
                             p_new_user_origSystem   in VARCHAR2,
                             p_new_user_origSystemID in VARCHAR2,
                             p_last_update_date      in DATE   default NULL,
                             p_last_updated_by       in NUMBER default NULL,
                             p_last_update_login     in NUMBER default NULL
                             -- <6817561>
                           , p_overWriteUserRoles in boolean default false -- </6817561>
                             );


--
-- AssignPartition (PRIVATE)
--
-- IN
--  p_orig_system (VARCHAR2)
--
-- RETURNS
--  Partition ID (NUMBER)
--
-- COMMENTS
--  This api will check to see the partition for the p_orig_system exists.
--  if it does not exist, it will be added to p_table_name.  In either case
--  the Partition_ID will be returned for the calling api to properly populate
--  that column on insert/update.
--
procedure  AssignPartition (p_orig_system   in  varchar2,
                            p_partitionID   out nocopy number,
                            p_partitionName out nocopy varchar2);

--Bug 3090738
--This API queries wf_roles for information of the
--user when the e-mail address is give.
procedure getInfoFromMail(mailid   in varchar2,
                          role out nocopy  varchar2,
                          display_name out NOCOPY varchar2,
                          description out NOCOPY varchar2,
                          notification_preference out NOCOPY varchar2,
                          language out NOCOPY varchar2,
                          territory out NOCOPY varchar2,
                          fax       out NOCOPY varchar2,
                          expiration_date out NOCOPY date,
                          status  out NOCOPY varchar2,
                          orig_system  out NOCOPY varchar2,
                          orig_system_id out NOCOPY number);

    /* (PRIVATE) - to be used by WF only
     *
     * Fetches role information when the e-mail address is given.
     * Added other parameters for full NLS support -phase 1-, bug 7578908
     */
    procedure GetInfoFromMail2( p_emailid in varchar2
                              , p_role out NOCOPY varchar2,
                                p_display_name out NOCOPY varchar2,
                                p_description out NOCOPY varchar2,
                                p_notification_preference out NOCOPY varchar2,
                                p_orig_system out NOCOPY varchar2,
                                p_orig_system_id out NOCOPY number,
                                p_fax out NOCOPY number,
                                p_expiration_date out nocopy date,
                                p_status out NOCOPY varchar2
                              , p_nlsLanguage out NOCOPY varchar2,
                                p_nlsTerritory out NOCOPY varchar2
                              , p_nlsDateFormat out NOCOPY varchar2
                              , p_nlsDateLanguage out NOCOPY varchar2
                              , p_nlsCalendar out NOCOPY varchar2
                              , p_nlsNumericCharacters out NOCOPY varchar2
                              , p_nlsSort out NOCOPY varchar2
                              , p_nlsCurrency out NOCOPY varchar2);

function IsMLSEnabled(p_orig_system  in   varchar2)
return boolean;

--
-- Change_Name_References_RF (PRIVATE)
--
-- IN
--  p_sub_guid (RAW)
--  p_event    (WF_EVENT_T)
--
-- RETURNS
--  varchar2
--
-- COMMENTS
--  This api is a rule function to be called by BES.  It is primarily used for
--  a user name change to update all the fk references.  The subscription is
--  set as deferred to offline the updates to return control back to the user
--  more quickly.
--
function Change_Name_References_RF( p_sub_guid  in            RAW,
                                    p_event     in out NOCOPY WF_EVENT_T )
return varchar2;


--
-- DeleteRole
--
-- IN
-- p_name (VARCHAR2)
-- p_OrigSystem (VARCHAR2)
-- p_OrigSystemID (NUMBER)
--
--
-- COMMENTS
-- This API is to be used to remove a specified end-dated role/user
-- along with its references, from the WFDS Tables.

procedure DeleteRole ( p_name in varchar2,
                       p_origSystem in varchar2,
                       p_origSystemID in number);



--
-- DeleteUserRole
--
-- IN
-- p_username (VARCHAR2)
-- p_rolename (VARCHAR2)
-- p_userOrigSystem (VARCHAR2)
-- p_userOrigSystemID (NUMBER)
-- p_roleOrigSystem (VARCHAR2)
-- p_roleOrigSystemID (NUMBER)
--
--
-- COMMENTS
-- This API is to be used to remove a specified end-dated user/role
-- assignment along with its references from the WFDS Tables.
--
procedure DeleteUserRole ( p_username in varchar2 default null,
                           p_rolename in varchar2 default null,
                           p_userorigSystem in varchar2  default null,
                           p_userorigSystemID in number  default null,
                           p_roleorigSystem in varchar2  default null,
                           p_roleorigSystemID in number  default null);

--
-- Add_Language
--
--IN: none
--
--Added as part of the implementation of ER 16570228 so that when a new
--language is enabled the qualifying roles in WFDS are added to the
--translation table WF_LOCAL_ROLES_TL

procedure add_language;

end Wf_Directory;

/
