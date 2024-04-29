--------------------------------------------------------
--  DDL for Package WF_LOCAL_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_LOCAL_SYNCH" AUTHID CURRENT_USER as
/* $Header: WFLOCALS.pls 120.10.12010000.3 2009/08/31 19:28:22 alsosa ship $ */
/*#
 * This interface provides APIs that enable synchronization
 * between the user and role information stored in
 * application tables by various Oracle e-Business Suite modules
 * and the information stored in the Workflow local tables.
 * @rep:scope internal
 * @rep:product OWF
 * @rep:displayname Workflow Local Synchronization
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_USER
 * @rep:ihelp FND/@lsyapi See the related online help
 */

/*
** propagate_user - Synchronizes the WF_LOCAL_USERS table and
**                  updates the entity mgr if appropriate
*/
/*#
 * This API synchronizes the information for a user
 * from an application table with the WF_LOCAL_ROLES
 * table .The user is identified by the specified
 * originating system and originating system ID.
 * @param p_orig_system Originating System
 * @param p_orig_system_id Originating System ID
 * @param p_attributes Attribute list for the user
 * @param p_start_date Start Date
 * @param p_expiration_date Expiration Date
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Propagate User
 * @rep:ihelp FND/@lsyapi#a_lspu See the related online help
 */
PROCEDURE propagate_user(p_orig_system      in varchar2,
                         p_orig_system_id   in number,
                         p_attributes       in wf_parameter_list_t,
                         p_start_date       in date default null,
                         p_expiration_date  in date default null);
------------------------------------------------------------------------------
/*
** propagate_role - Synchronizes the WF_LOCAL_ROLES table and
**                  updates the entity mgr if appropriate
*/
/*#
 * This API synchronizes the information for a role
 * from an application table with the WF_LOCAL_ROLES
 * table .The user is identified by the specified
 * originating system and originating system ID.
 * @param p_orig_system Originating System
 * @param p_orig_system_id Originating System ID
 * @param p_attributes Attribute list for the user
 * @param p_start_date Start Date
 * @param p_expiration_date Expiration Date
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Propagate Role
 * @rep:ihelp FND/@lsyapi#a_lspr See the related online help
 */
PROCEDURE propagate_role(p_orig_system      in varchar2,
                         p_orig_system_id   in number,
                         p_attributes       in wf_parameter_list_t,
                         p_start_date       in date default null,
                         p_expiration_date  in date default null);
------------------------------------------------------------------------------
/*
** propagate_user_role - (DEPRECATED) use propagateUserRole()
*/
/*#
 * This API Synchronizes the information for an
 * association of a user and a role from an application
 * table with the WF_LOCAL_USER_ROLES table.
 * @param p_user_orig_system User Originating System
 * @param p_user_orig_system_id User Originating System ID
 * @param p_role_orig_system Role Originating System
 * @param p_role_orig_system_id Role Originating System ID
 * @param p_start_date Start Date
 * @param p_expiration_date Expiration Date
 * @param p_overwrite Overwrite
 * @param p_raiseErrors Raise Errors
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Propagate User
 * @rep:ihelp FND/@lsyapi#a_lspur See the related online help
 */
PROCEDURE propagate_user_role(p_user_orig_system      in varchar2,
                              p_user_orig_system_id   in number,
                              p_role_orig_system      in varchar2,
                              p_role_orig_system_id   in number,
                              p_start_date            in date default null,
                              p_expiration_date       in date default null,
                              p_overwrite             in boolean default FALSE,
                              p_raiseErrors           in boolean default FALSE);
------------------------------------------------------------------------------
/*
** propagateUserRole - Synchronizes the WF_LOCAL_USER_ROLES table and
**                     updates the entity mgr if appropriate
*/
PROCEDURE propagateUserRole(p_user_name             in varchar2,
                            p_role_name             in varchar2,
                            p_user_orig_system      in varchar2 default null,
                            p_user_orig_system_id   in number default null,
                            p_role_orig_system      in varchar2 default null,
                            p_role_orig_system_id   in number default null,
                            p_start_date            in date default null,
                            p_expiration_date       in date default null,
                            p_overwrite             in boolean default FALSE,
                            p_raiseErrors           in boolean default FALSE,
                            p_parent_orig_system    in varchar2 default null,
                            p_parent_orig_system_id in varchar2 default null,
                            p_ownerTag              in varchar2 default null,
                            p_createdBy             in number default null,
                            p_lastUpdatedBy         in number default null,
                            p_lastUpdateLogin       in number default null,
                            p_creationDate          in date   default null,
                            p_lastUpdateDate        in date   default null,
                            p_assignmentReason      in varchar2 default null,
                            p_updateWho             in boolean default null,
                            p_attributes            in wf_parameter_list_t default null);
------------------------------------------------------------------------------

/*
** BulkSynchronization - Synchronize the LOCAL tables en masse from
**                       the old views for the specified orig system
*/
PROCEDURE BulkSynchronization(p_orig_system in varchar2 default 'ALL',
                              p_parallel_processes in number default 0,
                              p_logging in varchar2 default 'LOGGING',
                              p_raiseErrors in boolean default TRUE,
                              p_temptablespace in varchar2 default null);
------------------------------------------------------------------------------
/*
** BulkSynchronization_conc - CM cover routine for BulkSynchronization
*/
PROCEDURE BulkSynchronization_conc(errbuf        out NOCOPY varchar2,
                                   retcode       out NOCOPY varchar2,
                                   p_orig_system in varchar2 default 'ALL',
                                   p_parallel_processes in varchar2 default '0',
                                   p_logging in varchar2 default 'LOGGING',
                                   p_temptablespace in varchar2 default null,
                                   p_raiseerrors in varchar2 default null);

------------------------------------------------------------------------------
/*
** CheckCache - <private>
**
**   Checks to see if a role is in the cache of recently created roles.
** IN
**   p_role_name VARCHAR2
** RETURNS
**   BOOLEAN
*/
FUNCTION CheckCache (p_role_name in VARCHAR2) return boolean;

------------------------------------------------------------------------------
/*
** DeleteCache - <private>
**
**   Removes a role from the cache of newly created roles.
** IN
**   p_role_name VARCHAR2
*/
PROCEDURE DeleteCache (p_role_name in VARCHAR2);

------------------------------------------------------------------------------
/*
** ValidateUserRoles - Validates and corrects denormalized user and role
**                     information in user/role relationships.
*/
PROCEDURE ValidateUserRoles(p_BatchSize  in NUMBER default null,
                            p_username    in varchar2 default null,
                            p_rolename    in varchar2 default null,
                            p_check_dangling in BOOLEAN default null,
                            p_check_missing_ura in BOOLEAN default null,
                            p_UpdateWho in BOOLEAN default null,
                            p_parallel_processes in number default null);
------------------------------------------------------------------------------
/*
** ValidateUserRoles_conc - CM cover routine for ValidateUserRoles()
*/
PROCEDURE ValidateUserRoles_conc(errbuf        out NOCOPY varchar2,
                                 retcode       out NOCOPY varchar2,
                                 p_BatchSize   in varchar2 default null,
								 p_username    in varchar2 default null,
								 p_rolename    in varchar2 default null,
                                 p_check_dangling in varchar2 default null,
                                 p_check_missing_ura in varchar2 default null,
                                 p_UpdateWho in varchar2 default null,
                                 p_parallel_processes in number default null);

------------------------------------------------------------------------------
/*
** Create_Stage_Indexes - <private>
**
**   This routine examines the base table provided and creates matching indexes
**   on the stage table.
*/
PROCEDURE Create_Stage_Indexes (p_sourceTable in VARCHAR2,
                                p_targetTable in VARCHAR2);

end WF_LOCAL_SYNCH;

/

  GRANT EXECUTE ON "APPS"."WF_LOCAL_SYNCH" TO "NONAPPS";
