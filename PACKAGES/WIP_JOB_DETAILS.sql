--------------------------------------------------------
--  DDL for Package WIP_JOB_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_JOB_DETAILS" AUTHID CURRENT_USER as
/* $Header: wipjdlds.pls 115.17 2004/07/12 21:14:27 ccai ship $ */

   /* constants */
   WIP_DELETE   CONSTANT NUMBER := 1;
   WIP_ADD      CONSTANT NUMBER := 2;
   WIP_CHANGE   CONSTANT NUMBER := 3;

   WIP_RESOURCE        CONSTANT NUMBER := 1;
   WIP_MTL_REQUIREMENT CONSTANT NUMBER := 2;
   WIP_OPERATION       CONSTANT NUMBER := 3;
   WIP_RES_USAGE       CONSTANT NUMBER := 4;
   WIP_SUB_RES         CONSTANT NUMBER := 5;
   WIP_OP_LINK         CONSTANT NUMBER := 6;
   WIP_SERIAL          CONSTANT NUMBER := 7;
   WIP_RES_INSTANCE    CONSTANT NUMBER := 8;
   WIP_RES_INSTANCE_USAGE CONSTANT NUMBER := 9;

   std_alone    integer;

Procedure Load_All_Details( p_group_id in number,
                            p_parent_header_id in number,
                            p_std_alone    in integer,
                            x_err_code out nocopy varchar2,
                            x_err_msg  out nocopy varchar2,
                            x_return_status out nocopy varchar2);

Procedure default_wip_entity_id (p_group_id         number,
                                 p_parent_header_id number,
                                 x_err_code         out nocopy varchar2,
                                 x_err_msg          out nocopy varchar2,
                                 x_return_status    out nocopy varchar2);

End WIP_JOB_DETAILS;

 

/
