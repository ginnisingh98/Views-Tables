--------------------------------------------------------
--  DDL for Package BIS_BIA_RSG_INDEX_MGMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_BIA_RSG_INDEX_MGMT" AUTHID CURRENT_USER AS
/* $Header: BISBRIMS.pls 120.0 2005/05/31 18:13:17 appldev noship $ */

function is_Index_Mgmt_Enabled(p_mv_name in varchar2, p_mv_schema in varchar2) return varchar2;

procedure recreate_indexes_by_mv(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2, p_mv_name in varchar2,P_mv_schema in varchar2);

procedure Capture_and_drop_index_by_mv(p_mv_name in varchar2, p_mv_schema in varchar2);

procedure disable_index_mgmt(p_mv_name in varchar2,P_mv_schema in varchar2);

procedure enable_index_mgmt(p_mv_name in varchar2,P_mv_schema in varchar2);

procedure recreate_indexes_by_mv_wrapper(p_mv_name in varchar2,P_mv_schema in varchar2);

END;


 

/
