--------------------------------------------------------
--  DDL for Package WIP_DIAG_DATA_COLL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DIAG_DATA_COLL" AUTHID CURRENT_USER AS
/* $Header: WIPDCOLS.pls 120.0.12000000.1 2007/07/10 09:22:09 mraman noship $ */


sqltxt  varchar2(20000);
dummy_num       number;

release_level   varchar2(20) ;
other_info      varchar2(20) ;
l_result        boolean ;
l_found         number ;

PROCEDURE disc_lot_job(p_wip_entity_id IN NUMBER) ;
PROCEDURE repetitive(p_wip_entity_id IN NUMBER,
                     p_line_id IN NUMBER,
                     p_rep_schedule_id IN NUMBER ) ;
PROCEDURE flow(p_wip_entity_id IN NUMBER) ;
PROCEDURE setup(p_org_id IN NUMBER ,
                report OUT NOCOPY JTF_DIAG_REPORT,
                reportClob OUT NOCOPY CLOB);

PROCEDURE Pending_Txns(p_org_id IN NUMBER) ;
END;

 

/
