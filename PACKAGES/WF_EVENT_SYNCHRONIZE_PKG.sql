--------------------------------------------------------
--  DDL for Package WF_EVENT_SYNCHRONIZE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_EVENT_SYNCHRONIZE_PKG" AUTHID CURRENT_USER as
/* $Header: WFEVSYNS.pls 120.1 2005/07/02 03:14:55 appldev ship $ */
------------------------------------------------------------------------------
function SYNCHRONIZE (
 P_SUBSCRIPTION_GUID    in      raw,
 P_EVENT                in out nocopy  wf_event_t
) return varchar2;
------------------------------------------------------------------------------
function SYNCHRONIZEUPLOAD (
 P_SUBSCRIPTION_GUID    in      raw,
 P_EVENT                in out nocopy wf_event_t
) return varchar2;
------------------------------------------------------------------------------
procedure CREATESYNCCLOB (
 P_OBJECTTYPE	in	varchar2 DEFAULT NULL,
 P_OBJECTKEY	in	varchar2 DEFAULT NULL,
 P_ISEXACTNUM   in      integer  DEFAULT 1,
 P_OWNERTAG    in      varchar2  DEFAULT NULL,
 P_EVENTDATA    out nocopy     clob
);
------------------------------------------------------------------------------
procedure CREATEFILE (
 P_DIRECTORY    in      varchar2,
 P_FILENAME     in      varchar2,
 P_OBJECTTYPE   in      varchar2 DEFAULT NULL,
 P_OBJECTKEY    in      varchar2 DEFAULT NULL,
 P_ISEXACT      in      boolean DEFAULT TRUE
);
------------------------------------------------------------------------------
procedure CREATECLOBFILE (
 P_DIRECTORY    in      varchar2,
 P_FILENAME     in      varchar2,
 P_CLOB         in      clob
);
------------------------------------------------------------------------------
procedure UPLOADFILE (
 P_DIRECTORY	        in      varchar2,
 P_FILENAME             in      varchar2
);
------------------------------------------------------------------------------
procedure UPLOADSYNCCLOB (
 P_EVENTDATA		in	clob
);
------------------------------------------------------------------------------
function GETSYSTEMS (
 P_KEY		in	varchar2 DEFAULT NULL
) return clob;
------------------------------------------------------------------------------
function GETAGENTS (
 P_KEY          in      varchar2 DEFAULT NULL,
 P_ISEXACT      in      boolean  DEFAULT FALSE
) return clob;
------------------------------------------------------------------------------
function GETAGENTGROUPS (
 P_KEY          in      varchar2 DEFAULT NULL
) return clob;
/*
------------------------------------------------------------------------------
function GETEVENTS (
 P_KEY          in      varchar2 DEFAULT NULL
) return clob;
------------------------------------------------------------------------------
*/
function GETEVENTS (
 P_KEY          in      varchar2 DEFAULT NULL,
 P_OWNERTAG     in      varchar2 DEFAULT NULL
) return clob;
/*
------------------------------------------------------------------------------
function GETEVENTGROUPS (
 P_KEY          in      varchar2 DEFAULT NULL
) return clob;
------------------------------------------------------------------------------
*/
function GETEVENTGROUPS (
 P_KEY          in      varchar2,
 P_OWNERTAG     in      varchar2 DEFAULT NULL
) return clob;
------------------------------------------------------------------------------
function GETGROUPS (
 P_KEY          in      varchar2,
 P_OWNERTAG     in      varchar2 DEFAULT NULL
) return clob;
------------------------------------------------------------------------------
function GETEVENTGROUPBYGROUP (
 P_KEY          in      varchar2,
 P_OWNERTAG     in      varchar2  DEFAULT NULL
) return clob;
/*
------------------------------------------------------------------------------
function GETSUBSCRIPTIONS (
 P_KEY          in      varchar2 DEFAULT NULL,
 P_ISEXACT      in      boolean  DEFAULT FALSE
) return clob;
------------------------------------------------------------------------------
*/
function GETSUBSCRIPTIONS (
 P_KEY          in      varchar2 DEFAULT NULL,
 P_ISEXACT      in      boolean  DEFAULT FALSE,
 P_OWNERTAG     in      varchar2 DEFAULT NULL
) return clob;
------------------------------------------------------------------------------
function GETOBJECTTYPE(
 P_MESSAGEDATA		in	varchar2
) return varchar2;
------------------------------------------------------------------------------
procedure UploadObject(
 P_OBJECTTYPE		in	varchar2,
 P_MESSAGEDATA          in      varchar2,
 P_ERROR		out  nocopy   varchar2
);
------------------------------------------------------------------------------
procedure UpdateGUID (
 g_guid in varchar2 default null
);
------------------------------------------------------------------------------
function ReplaceContent (
 begTag in varchar2 default null,
 endTag in varchar2 default null,
 replaceTarget in varchar2 default null,
 newData in varchar2 default null,
 dataStr in varchar2 default null
) return varchar2;
------------------------------------------------------------------------------
function SetGUID (
 dataStr in varchar2 default null
) return varchar2;
------------------------------------------------------------------------------
function SetSYSTEMGUID (
 dataStr in varchar2 default null
) return varchar2;
------------------------------------------------------------------------------
function GetSID return varchar2;
------------------------------------------------------------------------------
function GetQOwner return varchar2;
------------------------------------------------------------------------------
function SetSID (
 dataStr in varchar2 default null
) return varchar2;
------------------------------------------------------------------------------
function SetAgent (
 dataStr in varchar2 default null
) return varchar2;
------------------------------------------------------------------------------
function SetPound (
 startPos in number default 0,
 dataStr in varchar2 default null,
 begTag in varchar2 default null,
 endTag in varchar2 default null,
 pound in varchar2 default null,
 matchStr in varchar2 default null
) return varchar2;
------------------------------------------------------------------------------
function SetNull (
 startPos in number   default 0,
 dataStr  in varchar2 default null,
 tag      in varchar2 default null
) return varchar2;
------------------------------------------------------------------------------
procedure CREATEEMPTYCLOB (
 P_OUTCLOB out nocopy      clob
);
------------------------------------------------------------------------------
function GetAgent (
 begTag in varchar2,
 endTag in varchar2,
 dataStr in varchar2
) return varchar2 ;
------------------------------------------------------------------------------
function SetAgent2 (
 begTag in varchar2,
 endTag in varchar2,
 dataStr in varchar2
) return varchar2;
------------------------------------------------------------------------------
procedure CREATESYNCCLOB2 (
 P_OBJECTTYPE   in      varchar2 DEFAULT NULL,
 P_OBJECTKEY    in      varchar2 DEFAULT NULL,
 P_ISEXACTNUM   in      integer  DEFAULT 1,
 P_OWNERTAG     in      varchar2 DEFAULT NULL,
 P_EVENTDATA    out nocopy clob,
 P_ERROR_CODE   out nocopy varchar2,
 P_ERROR_MSG    out nocopy varchar2
);
------------------------------------------------------------------------------

end WF_EVENT_SYNCHRONIZE_PKG;

 

/
