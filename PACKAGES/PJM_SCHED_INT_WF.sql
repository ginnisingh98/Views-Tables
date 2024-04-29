--------------------------------------------------------
--  DDL for Package PJM_SCHED_INT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_SCHED_INT_WF" AUTHID CURRENT_USER AS
/* $Header: PJMSIWFS.pls 115.8 2002/08/14 01:19:02 alaw ship $ */
--  ---------------------------------------------------------------------
--  Public Functions / Procedures
--  ---------------------------------------------------------------------

PROCEDURE start_wf
( c_document_type     varchar2
, n_tolerance_days    number
, c_requestor         varchar2
, c_ntf_proj_mgr      varchar2
, c_ntf_task_mgr      varchar2
, c_item_from         varchar2
, c_item_to           varchar2
, c_project_from      varchar2
, c_project_to        varchar2
, d_date_from         varchar2
, d_date_to           varchar2
, c_oe_or_ont         varchar2
);


END PJM_SCHED_INT_WF;

 

/
