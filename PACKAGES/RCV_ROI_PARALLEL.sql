--------------------------------------------------------
--  DDL for Package RCV_ROI_PARALLEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ROI_PARALLEL" AUTHID CURRENT_USER AS
/* $Header: RCVPGRPS.pls 120.2 2006/02/26 23:06:48 spendokh noship $*/

TYPE reqid_list IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE spawn_process (p_num_of_groups IN NUMBER,
                         p_req_ids OUT NOCOPY RCV_ROI_PARALLEL.reqid_list);

END RCV_ROI_PARALLEL;

 

/
