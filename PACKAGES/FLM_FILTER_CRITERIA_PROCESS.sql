--------------------------------------------------------
--  DDL for Package FLM_FILTER_CRITERIA_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_FILTER_CRITERIA_PROCESS" AUTHID CURRENT_USER AS
/* $Header: FLMFLCRS.pls 115.0 2002/12/18 00:15:31 asuherma noship $ */

  /* Procedure to construct the where clause of the FLM filter criteria.
     The data is obtained from FLM_FILTER_CRITERIA table. */
  PROCEDURE get_filter_clause (p_criteria_group_id IN NUMBER,
                               p_table_alias IN VARCHAR2,
                               p_init_msg_list IN VARCHAR2,
                               x_filter OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2);

END flm_filter_criteria_process;

 

/
