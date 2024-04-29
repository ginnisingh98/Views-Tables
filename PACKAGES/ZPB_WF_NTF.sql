--------------------------------------------------------
--  DDL for Package ZPB_WF_NTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_WF_NTF" AUTHID CURRENT_USER AS
/* $Header: zpbwfntf.pls 120.3 2007/12/04 16:23:42 mbhat ship $ */


PROCEDURE SETROLE (AdHocRole in varchar2, ExpDays in number, RoleDisplay in varchar2 default NULL);

PROCEDURE REMUSER (AdHocRole in varchar2,
                   UserList in varchar2) ;

-- REMALL cleans up wf_local_roles.  It is called from OES by ntf.purgerole
-- ntf.purgerole also calls wf_purge.notificatons and wf_purgeItem
-- along with this so all expired notifications are cleaned.
-- These are called by expiration_date.
--
PROCEDURE REMALL (AdHocRole in varchar2);

function MakeRoleName (ACID in Number, TaskID in Number, UserID in Number default NULL) return varchar2;

FUNCTION GetFNDResp (RespKey in Varchar2) return varchar2;

procedure SET_ATTRIBUTES (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2);

procedure SET_PAUSE (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2);

function Get_EPB_Users (RespKey in Varchar2) return clob;

function NotifyForTask (TaskID in Number) return varchar2;

procedure NOTIFY_ON_DELETE (numericID in number, IDType in Varchar2 default 'TASK');

procedure VALIDATE_BUS_AREA (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2);

Function SET_USERS_TO_NOTIFY (taskID in number,
           		  itemkey  in varchar2,
                          workflowprocess in varchar2,
                          relative in number,
                          thisOwner in varchar2,
                          thisOwnerID in number) return varchar2;

Procedure Set_EPB_Users (rolename in Varchar2, RespKey in Varchar2);

function update_Role_with_Shadows (roleName in Varchar2, thisUser Varchar2) return varchar2;

function ID_to_FNDUser (userID in number) return varchar2;

function FNDUser_to_ID (fndUser in varchar2) return number;

procedure ADD_SHADOW (rolename in varchar2, UserId in Number);

function USER_IN_ROLE (rolename in varchar2, UserName in varchar2) return varchar2;

Function HAS_SHADOW (userId in Number) return varchar2;

function OLD_STYLE_USERS(instanceID in number, taskID in number, thisOwner in varchar2, thisOwnerID in number, relative in number DEFAULT 0, UserList in varchar2 DEFAULT NULL) return varchar2;

procedure sendmsg(p_userid in number,
                   p_subject in varchar2,
                   p_message in varchar2);

-- added for b 5251227 and 5301285
procedure SHADOWS_FOR_EPBPERFORMER (itemtype in varchar2,
            		  itemkey  in varchar2,
	 	          actid    in number,
 		          funcmode in varchar2,
                          resultout   out nocopy varchar2);

-- added for b 4948928
procedure SendExpiredUserMsg(p_BPOwnerID in number, p_taskID in number, p_itemtype in varchar2);

function Get_Active_User (p_BPOwnerID in number, p_BAID in number) return varchar2;

function FindSecurityAdmin (p_BAID in number,
                  p_roleName in varchar2,
                  p_respID in number) return varchar2;

procedure Build_ExpiredUser_list (p_nid in number);

end ZPB_WF_NTF;

/
