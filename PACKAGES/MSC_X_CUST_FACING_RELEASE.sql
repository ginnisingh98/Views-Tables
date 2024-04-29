--------------------------------------------------------
--  DDL for Package MSC_X_CUST_FACING_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_CUST_FACING_RELEASE" AUTHID CURRENT_USER AS
/* $Header: MSCXRSOS.pls 120.0.12000000.1 2007/01/16 22:40:55 appldev ship $     */

G_REPLENISHMENT        CONSTANT  NUMBER := 1;
G_PLANNER_OVERRIDE_ATP CONSTANT  NUMBER := 2;
G_CONSUMPTION_ADVICE   CONSTANT  NUMBER := 3;

G_CONSIGNED_VMI        CONSTANT NUMBER := 1;
G_UNCONSIGNED_VMI      CONSTANT NUMBER := 2;

G_REPLENISHMENT_ORDER        CONSTANT  NUMBER := 19;

SYS_YES  CONSTANT NUMBER := 1;
SYS_NO   CONSTANT NUMBER := 2;

G_UNRELEASED CONSTANT  NUMBER := 0;
G_RELEASED   CONSTANT  NUMBER := 1;

G_CREATE CONSTANT NUMBER := 1;
G_UPDATE CONSTANT NUMBER := 2;

G_OEM_ID CONSTANT NUMBER := 1;

G_SUCCESS  CONSTANT NUMBER := 0;
G_WARNING  CONSTANT NUMBER := 1;
G_ERROR    CONSTANT NUMBER := 2;

G_SUCCESSFUL  CONSTANT NUMBER := 1;

PROCEDURE VMI_RELEASE
  ( itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout out nocopy varchar2
  );

PROCEDURE SCHEDULE_DATE_CHANGED
  ( itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout out nocopy varchar2
  );

PROCEDURE UPDATE_SO_ATP_OVERRIDE
  ( itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout out nocopy varchar2
  );

PROCEDURE DELETE_INTERFACE_RECORD
  ( itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout out nocopy varchar2
  );

PROCEDURE IS_CONSIGNED_VMI
  ( itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout out nocopy varchar2
  );

PROCEDURE CREATE_VMI_RELEASE( ERRBUF    OUT NOCOPY VARCHAR2,
			      RETCODE   OUT NOCOPY NUMBER,
			      pItem_name          in varchar2,
			      pCustomer_name      in varchar2,
			      pCustomer_site_name in varchar2,
			      itemtype            in varchar2,
			      itemkey             in varchar2,
			      pRelease_ID         in number,
			      pDestination        in number,
          p_instance_id IN  NUMBER,
          p_instance_code  IN  VARCHAR2,
          p_a2m_dblink IN  VARCHAR2
			       );

END MSC_X_CUST_FACING_RELEASE;

 

/
