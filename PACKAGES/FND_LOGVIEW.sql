--------------------------------------------------------
--  DDL for Package FND_LOGVIEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_LOGVIEW" AUTHID CURRENT_USER as
/* $Header: AFUTLPFS.pls 115.9 2002/02/08 21:49:45 nbhambha ship $ */




procedure preferences; /* Lets user adjust their logging preferences */
procedure preferences_user;
procedure preferences_sysadmin;
procedure preferences_sysadmin_debug;

/* Internal; called by preferences_user etc. */
procedure preferences_generic(user_mode in varchar2,
                              user_id_x in number default NULL);

procedure Update_Prefs(
                ENABLED     in VARCHAR2 default 'off',
                FILENAME    in VARCHAR2,
                LEVEL       in VARCHAR2 default NULL,
                MODULE      in VARCHAR2,
                SESSION_TO_PURGE   in VARCHAR2 default NULL,
                USER_TO_PURGE      in VARCHAR2 default NULL,
                USER_TO_SET        in VARCHAR2 default NULL,
                SAVE               in VARCHAR2 default NULL,
                clearprefs         in VARCHAR2 default NULL,
                clearsessionlog    in VARCHAR2 default NULL,
                clearuserlog       in VARCHAR2 default NULL,
                clear              in VARCHAR2 default NULL,
                sysclear           in VARCHAR2 default NULL,
                syssave            in VARCHAR2 default NULL,
                syspurgeallusers   in VARCHAR2 default NULL,
                syssetuserprefs    in VARCHAR2 default NULL,
                SYSCLEARPREFS      in VARCHAR2 default NULL,
                SYSCLEARSESSIONLOG in VARCHAR2 default NULL,
                SYSCLEARUSERLOG    in VARCHAR2 default NULL,
                USER_ID            in VARCHAR2 default NULL);

procedure find_display; /* Deprecated; equivalent to find_user */

procedure find;           /* Deprecated; equivalent to find_user */
procedure find_user;      /* Brings up find window to view log for a user */
procedure find_sysadmin;  /* Brings up find window to view log for sysadmin */
procedure find_sysadmin_debug;

/* Internal; called by find_user etc. */
procedure find_log(user_mode in varchar2);

procedure display( LEVEL     in VARCHAR2,
                MODULE       in VARCHAR2,
                START_DATE   in VARCHAR2,
                END_DATE     in VARCHAR2,
                ONLY_SESSION in VARCHAR2 default NULL,
                USERNAME     in VARCHAR2 default NULL,
                ONLY_USER    in VARCHAR2 default NULL,
                FIND_USER        in VARCHAR2 default NULL,
                FIND_SYSADMIN    in VARCHAR2 default NULL,
                CLEARSESSIONLOG  in VARCHAR2 default NULL,
                CLEARUSERLOG     in VARCHAR2 default NULL,
                STARTROW         in VARCHAR2 default NULL,
                NUMROWS          in VARCHAR2 default NULL);

procedure test;


end fnd_logview;

 

/
