--------------------------------------------------------
--  DDL for Package MSC_CL_ROUTING_ODS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_ROUTING_ODS_LOAD" AUTHID CURRENT_USER AS
/* $Header: MSCLRTGS.pls 120.1.12010000.2 2010/01/22 19:13:40 ahoque ship $ */

--v_coll_prec             MSC_CL_EXCHANGE_PARTTBL.CollParamRec;
   PROCEDURE LOAD_ROUTING ;
   PROCEDURE LOAD_ROUTING_OPERATIONS ;
   PROCEDURE LOAD_OPERATION_RESOURCES ;
   PROCEDURE LOAD_OPERATION_NETWORKS ;
   PROCEDURE LOAD_OPERATION_COMPONENTS ;
   PROCEDURE LOAD_OP_RESOURCE_SEQ ;
   PROCEDURE LOAD_STD_OP_RESOURCES;
    /* Bug 9194726 starts    */
   PROCEDURE GET_START_END_OP;
   PROCEDURE GET_START_END_OP_PARTIAL;
   FUNCTION get_start_op(v_instance_id in number,
                      v_routing_sequence_id in number,
                      v_routing_effdate in date)
          return number;


   FUNCTION get_last_op(v_instance_id in number,
                      v_routing_sequence_id in number,
                      v_routing_effdate in date)
          return number;

    /* Bug 9194726 starts    */

END MSC_CL_ROUTING_ODS_LOAD;

/
