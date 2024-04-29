--------------------------------------------------------
--  DDL for Package WSM_JOBPURGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_JOBPURGE_GRP" AUTHID CURRENT_USER AS
/* $Header: WSMPLBJS.pls 120.2 2006/03/27 20:43:31 mprathap noship $ */

REPORT_ONLY      constant number := 1;
PURGE_AND_REPORT constant number := 2;
PURGE_ONLY       constant number := 3;
-- Info type
EXCEPTIONS    constant number := 1;
ROWS_AFFECTED constant number := 2;


procedure delete_osfm_tables(
                              p_option        in number,
                              p_group_id      in number,
                              p_purge_request in wip_wictpg.get_purge_requests%rowtype,
                              -- ST Fix for bug 4918553
                              p_detail_flag   IN BOOLEAN DEFAULT TRUE,
                              p_return_status out NOCOPY VARCHAR2
                              );


END WSM_JobPurge_GRP;

 

/
