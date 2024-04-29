--------------------------------------------------------
--  DDL for Package MSC_RELEASE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_RELEASE_PK" AUTHID CURRENT_USER AS
/* $Header: MSCARELS.pls 120.1 2008/01/21 12:17:55 sbyerram ship $ */

   TYPE ReqRecTyp
      IS RECORD (
      instanceCode       varchar2(50),
      ReqID              varchar2(50),
      ReqType            varchar2(50)
   );

    TYPE ReqTblTyp IS TABLE OF ReqRecTyp index by BINARY_INTEGER;


PROCEDURE msc_auto_release
                (errbuf			OUT NOCOPY VARCHAR2,
                 retcode		OUT NOCOPY NUMBER,
                 arg_plan_id            IN  NUMBER,
                 arg_org_id             IN  NUMBER,
                 arg_instance_id        IN  NUMBER,
                 arg_use_start_date     IN  VARCHAR2);

PROCEDURE msc_web_service_release (
                pPlan_id 			            Number,
            	Use_Plan_start_date    	        Varchar2,
            	RETCODE		        OUT  NOCOPY Number,
            	ERRMSG		        OUT  NOCOPY Varchar2,
            	REQ_ID		        OUT  NOCOPY ReqTblTyp
                );

END msc_release_pk;

/
