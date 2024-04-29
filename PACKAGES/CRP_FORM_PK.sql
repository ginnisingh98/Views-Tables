--------------------------------------------------------
--  DDL for Package CRP_FORM_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CRP_FORM_PK" AUTHID CURRENT_USER AS
     /* $Header: CRPSELES.pls 115.3 2002/07/12 21:15:01 jhegde ship $ */

   /*------Declaring Procedures-------*/
    PROCEDURE crp_selection_criteria(
          	       	       	  arg_query_id        NUMBER,
       	       	       	       	  arg_type            NUMBER,
       	       	       	       	  arg_org_id          NUMBER,
                                  arg_owning_dept_id  NUMBER DEFAULT NULL,
       	       	       	       	  arg_dept_id         NUMBER DEFAULT NULL,
       	       	       	       	  arg_res_id          NUMBER DEFAULT NULL,
       	       	       	       	  arg_line_id         NUMBER DEFAULT NULL,
       	       	       	       	  arg_res_type        NUMBER DEFAULT NULL,
       	       	       	       	  arg_dept_class      VARCHAR2 DEFAULT NULL,
                                  arg_res_grp         VARCHAR2 DEFAULT NULL);

   PROCEDURE crp_update_util(
				arg_query_id1		NUMBER,
				arg_query_id2		NUMBER,
				arg_line_capacity	NUMBER);

   PROCEDURE crp_upd_dept_class(arg_query_id       NUMBER);

   FUNCTION crp_resource_list(
                                arg_session_id  NUMBER,
                                arg_type        NUMBER,
                                arg_query_id1   NUMBER,
                                arg_query_id2   NUMBER) RETURN NUMBER;

   /*--------Defining Constants-------*/
   ROUTING_BASED       CONSTANT    NUMBER :=1;
   RATE_BASED          CONSTANT    NUMBER :=2;
   insufficient_args   EXCEPTION;

END crp_form_pk;

 

/
