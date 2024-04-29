--------------------------------------------------------
--  DDL for Package WIP_INFRESSCHED_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_INFRESSCHED_GRP" AUTHID CURRENT_USER as
/* $Header: wipinrss.pls 120.0.12010000.1 2008/07/24 05:22:54 appldev ship $ */

  type num_tbl_t is table of number;
  type date_tbl_t is table of date;


/*
  type op_res_usage_rectbl_t is record(startDate date_tbl_t,
                                       endDate date_tbl_t,
                                       cumMinProcTime num_tbl_t);--cumulative proc time in minutes

  type op_res_usage_tbl_t is table of op_res_usage_rectbl_t index by binary_integer;
*/
  type op_res_rectbl_t is record(opSeqNum          num_tbl_t,
                                 resID             num_tbl_t,
                                 deptID            num_tbl_t,
                                 resSeqNum         num_tbl_t,
                                 schedSeqNum       num_tbl_t,
                                 schedFlag         num_tbl_t,
                                 avail24Flag       num_tbl_t,
                                 startDate         date_tbl_t,
                                 endDate           date_tbl_t,
                                 totalDaysUsg      num_tbl_t,
                                 usgStartIdx       num_tbl_t,
                                 usgEndIdx         num_tbl_t,
                                 usgStartDate      date_tbl_t,
                                 usgEndDate        date_tbl_t,
                                 usgCumMinProcTime num_tbl_t);



  procedure schedule(p_orgID IN NUMBER,
                     p_repLineID NUMBER := null,
                     p_startDate DATE := null,
                     p_endDate DATE := null,
                     p_opSeqNum NUMBER := null,
                     p_resSeqNum NUMBER := null,
                     p_endDebug VARCHAR2 := null,
                     x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T,
                     x_returnStatus OUT NOCOPY VARCHAR2);

  procedure dumpResources(p_resTbls IN OP_RES_RECTBL_T);

end wip_infResSched_grp;

/
