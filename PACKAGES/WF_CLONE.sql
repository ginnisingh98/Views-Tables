--------------------------------------------------------
--  DDL for Package WF_CLONE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_CLONE" AUTHID CURRENT_USER as
/*$Header: wfclones.pls 120.2 2005/10/04 05:36:45 rtodi noship $*/
--This API updates attribute values which refernce the source
--system to target references.

procedure UpdateAttrValues(WEB_HOST in  varchar2,
                           DOMAIN   in varchar2,
                           WEB_PORT in varchar2,
                           SID      in varchar2,
			   URL_PROTO in varchar2 default NULL);


--This API updates the system_guid and related tables

procedure UpdateSysGuid;

--This API updates the mailer parameters

procedure UpdateMailer(WEB_HOST in  varchar2,
                       DOMAIN   in varchar2,
                       WEB_PORT in varchar2,
                       SID      in varchar2,
		 URL_PROTO in varchar2 default NULL);


--This API updates WF_SYSTEM_GUID token in wf_resources with
--the new system guid.
procedure UpdateResource(WEB_HOST in  varchar2,
                           DOMAIN   in varchar2,
                           WEB_PORT in varchar2,
                           SID      in varchar2,
			   URL_PROTO in varchar2 default NULL);


--This API detemines whether its a clone run or install/
--upgrade/rerun.
--Incase of install/upgrade/rerun we return false so that
--clone APIs are not called.

Function    DetermineClone(WEB_HOST in  varchar2,
                           DOMAIN   in varchar2,
                           WEB_PORT in varchar2,
                           SID      in varchar2 ,
			   URL_PROTO in varchar2 default NULL)

return   boolean;

--Procedure Clone
--This API calls all the cloning related APIs
--This will be invoked by the concurrent program
Procedure WFClone(P_WEB_HOST    in  varchar2,
                P_DOMAIN      in  varchar2,
                P_WEB_PORT    in  varchar2,
                P_SID         in  varchar2,
                P_URL_PROTO in varchar2 default NULL);


procedure purgedata;

--Keep the default of raise_error as FALSE as
--autoconfig cannot throw errors but still we can
--potentially record it in standalone

PROCEDURE TruncateTable (TableName      IN     VARCHAR2,
                         Owner          IN     VARCHAR2,
                         raise_error    IN     BOOLEAN default FALSE );

--Truncate Queue Table
PROCEDURE QTableTruncate(QName      IN     VARCHAR2,
                      raise_error    IN     BOOLEAN default FALSE );

PROCEDURE QDequeue(QName      IN     VARCHAR2,
                   owner      in      VARCHAR2,
                   AgtName    IN    VARCHAR2 default null,
                   raise_error    IN     BOOLEAN default FALSE );
--Concurrent Programs
--#1. CLONE - Where u do a complete source_data migration
--            over to target system updating all transactional
--            data also to be compatiable.
PROCEDURE CLONE(errbuf        out NOCOPY varchar2,
                retcode       out NOCOPY varchar2,
                P_WEB_HOST      in  varchar2,
                P_DOMAIN        in varchar2,
                P_WEB_PORT      in varchar2,
                P_SID           in varchar2 ,
                P_URL_PROTO in varchar2 default NULL);


--#2. PURGE - Where u do a complete purge of transaction/
--            runtime data.
PROCEDURE PURGE(errbuf        out NOCOPY varchar2,
                retcode       out NOCOPY varchar2);


end wf_clone;


 

/
