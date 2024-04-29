--------------------------------------------------------
--  DDL for Package MSC_CL_WIP_ODS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_WIP_ODS_LOAD" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCLWIPS.pls 120.0 2007/04/12 06:48:39 rsyadav noship $ */
--v_coll_prec             MSC_CL_EXCHANGE_PARTTBL.CollParamRec;
   link_top_transaction_id_req   BOOLEAN := FALSE;

   PROCEDURE LOAD_JOB_DETAILS;
   PROCEDURE LOAD_WIP_DEMAND;

   PROCEDURE LOAD_RES_REQ;
   PROCEDURE LOAD_RES_INST_REQ;
END MSC_CL_WIP_ODS_LOAD;

/
