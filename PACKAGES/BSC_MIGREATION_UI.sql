--------------------------------------------------------
--  DDL for Package BSC_MIGREATION_UI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_MIGREATION_UI" AUTHID CURRENT_USER AS
/*$Header: BSCMGUIS.pls 120.3 2005/12/16 01:43 amitgupt noship $*/

TYPE respMapRec IS RECORD(
  src_resp_id   BSC_RESPONSIBILITY_VL.RESPONSIBILITY_ID%TYPE,
  src_resp_name BSC_RESPONSIBILITY_VL.RESPONSIBILITY_NAME%TYPE,
  tar_resp_id   BSC_RESPONSIBILITY_VL.RESPONSIBILITY_ID%TYPE,
  tar_resp_name BSC_RESPONSIBILITY_VL.RESPONSIBILITY_NAME%TYPE
);

TYPE objectRec IS RECORD(
  object_id     BSC_KPIS_VL.INDICATOR%TYPE,
  object_name   BSC_KPIS_VL.NAME%TYPE
);

TYPE objectList IS TABLE OF objectRec;
TYPE RespMapTable IS TABLE OF respMapRec;

procedure createDbLink( p_dblink_sql IN varchar2,
			p_dblink_name IN varchar2,
      		        p_create_status OUT NOCOPY NUMBER);

procedure dropDbLink(p_dblink_name IN varchar2);

procedure initRespTmpTable(p_process_id IN varchar2,
                           p_dblink_name IN varchar2,
                           num_rows OUT NOCOPY Number);

procedure initTmpObjTable(p_process_id IN varchar2,
                          p_dblink_name IN varchar2,
                          pFetchMode IN varchar2,
                          pRespList  IN varchar2);

END BSC_MIGREATION_UI;

 

/
