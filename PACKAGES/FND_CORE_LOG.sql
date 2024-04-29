--------------------------------------------------------
--  DDL for Package FND_CORE_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CORE_LOG" AUTHID CURRENT_USER as
/* $Header: AFCORLGS.pls 120.5.12000000.1 2007/01/18 13:14:06 appldev ship $ */

UTL_FILE_ERROR  exception;

PRAGMA exception_init(UTL_FILE_ERROR, -20100);

function ENABLED return varchar2;

function PROFILE_TO_LOG return varchar2;

procedure WRITE(
   CURRENT_API           in varchar2,
   LOG_USER_ID           in number default NULL,
   LOG_RESPONSIBILITY_ID in number default NULL,
   LOG_APPLICATION_ID    in number default NULL,
   LOG_ORG_ID            in number default NULL,
   LOG_SERVER_ID         in number default NULL);

procedure WRITE_PROFILE(
   LOG_PROFNAME          in varchar2,
   LOG_PROFVAL           in varchar2 default null,
   CURRENT_API           in varchar2,
   LOG_USER_ID           in number,
   LOG_RESPONSIBILITY_ID in number,
   LOG_APPLICATION_ID    in number,
   LOG_ORG_ID            in number,
   LOG_SERVER_ID         in number);

procedure WRITE_PROFILE_SAVE(
   X_NAME in varchar2,
      /* Profile name you are setting */
   X_VALUE in varchar2,
      /* Profile value you are setting */
   X_LEVEL_NAME in varchar2,
      /* Level that you're setting at: 'SITE','APPL','RESP','USER', etc. */
   X_LEVEL_VALUE in varchar2 default NULL,
      /* Level value that you are setting at, e.g. user id for 'USER' level.
         X_LEVEL_VALUE is not used at site level. */
   X_LEVEL_VALUE_APP_ID in varchar2 default NULL,
      /* Used for 'RESP' and 'SERVRESP' level; Resp Application_Id. */
   X_LEVEL_VALUE2 in varchar2 default NULL);

procedure PUT_NAMES(P_LOGFILE in varchar2, P_DIRECTORY in varchar2);

procedure OPEN_FILE;
pragma restrict_references(OPEN_FILE, WNDS, RNDS, TRUST);

procedure PUT(LOG_TEXT in varchar2);
pragma restrict_references(PUT, WNDS, RNDS, TRUST);

procedure PUT_LINE(LOG_PROFNAME in varchar2, LOG_TEXT in varchar2);
pragma restrict_references(PUT_LINE, WNDS, RNDS, TRUST);

procedure PUT_LINE(LOG_TEXT in varchar2);
pragma restrict_references(PUT_LINE, WNDS, RNDS, TRUST);

procedure NEW_LINE(LINES in natural := 1);
pragma restrict_references(NEW_LINE, WNDS, RNDS, TRUST);

procedure CLOSE_FILE;
pragma restrict_references(CLOSE_FILE, WNDS, RNDS, TRUST);

function IS_ENABLED return boolean;

end FND_CORE_LOG;

 

/
