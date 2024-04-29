--------------------------------------------------------
--  DDL for Package JTF_RS_GROUP_REPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_GROUP_REPORT_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrsbgs.pls 120.0 2005/05/11 08:19:19 appldev ship $ */

/************************************************************

   This is a sql to get the history of movement of members in and out of groups

   15-JUN-2004    nsinghai   added dummy parameters for selective enabling
                             disbaling of fields.

 *****************************************************************************/

PROCEDURE query_group(ERRBUF  OUT NOCOPY VARCHAR2,
                      RETCODE OUT NOCOPY VARCHAR2,
                      P_REP_TYPE   IN  VARCHAR2 ,
                      P_DUMMY_1    IN VARCHAR2 DEFAULT NULL,
                      P_DUMMY_2    IN VARCHAR2 DEFAULT NULL,
                      P_DUMMY_3    IN VARCHAR2 DEFAULT NULL,
                      P_GROUP_ID   IN NUMBER DEFAULT NULL,
                      P_RES_ID     IN NUMBER DEFAULT NULL,
                      P_USAGE      IN VARCHAR2 DEFAULT NULL,
                      P_USR_NAME   IN VARCHAR2 DEFAULT NULL,
                      P_DATE_OPT   IN  VARCHAR2 DEFAULT 'RANGE',
                      P_START_DATE IN varchar2 default null,
                      P_END_DATE   IN varchar2 default null,
                      P_NO_OF_DAYS IN number default null) ;

/*
 * Procedure overloaded to give user choice to display DFF fields in the report.
 * While submitting the concurrent request, The user may choose to display DFF fields in the report.
 * Ref: ER# 2549463
 */

PROCEDURE query_group(ERRBUF  OUT NOCOPY VARCHAR2,
                      RETCODE OUT NOCOPY VARCHAR2,
                      P_REP_TYPE   IN  VARCHAR2 ,
                      P_DUMMY_1    IN VARCHAR2 DEFAULT NULL,
                      P_DUMMY_2    IN VARCHAR2 DEFAULT NULL,
                      P_DUMMY_3    IN VARCHAR2 DEFAULT NULL,
                      P_GROUP_ID   IN NUMBER DEFAULT NULL,
                      P_RES_ID     IN NUMBER DEFAULT NULL,
                      P_USAGE      IN VARCHAR2 DEFAULT NULL,
                      P_USR_NAME   IN VARCHAR2 DEFAULT NULL,
                      P_DATE_OPT   IN  VARCHAR2 DEFAULT 'RANGE',
                      P_START_DATE IN varchar2 default null,
                      P_END_DATE   IN varchar2 default null,
                      P_NO_OF_DAYS IN number default null,
                      P_DISP_DFF_FIELDS IN VARCHAR2 DEFAULT 'N');


/*
 * Added P_DISP_ROLE parameter vide Bug# 1745032
 */

PROCEDURE query_group_hierarchy(ERRBUF  OUT NOCOPY VARCHAR2,
                      RETCODE OUT NOCOPY VARCHAR2,
                      P_GROUP_NAME IN VARCHAR2 DEFAULT NULL,
                      P_DISP_ROLE IN VARCHAR2 DEFAULT 'N');


/*
 * Procedure overloaded to give user choice to display DFF fields in the report.
 * While submitting the concurrent request, The user may choose to display DFF fields in the report.
 * Ref: ER# 2549463
 */

PROCEDURE query_group_hierarchy(ERRBUF  OUT NOCOPY VARCHAR2,
                      RETCODE OUT NOCOPY VARCHAR2,
                      P_GROUP_NAME IN VARCHAR2 DEFAULT NULL,
                      P_DISP_ROLE IN VARCHAR2 DEFAULT 'N',
                      P_DISP_DFF_FIELDS IN VARCHAR2 DEFAULT 'N');
end;

 

/
