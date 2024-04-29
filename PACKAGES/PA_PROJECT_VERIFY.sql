--------------------------------------------------------
--  DDL for Package PA_PROJECT_VERIFY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_VERIFY" AUTHID CURRENT_USER AS
-- $Header: PAXPCO3S.pls 115.0 99/07/16 15:29:25 porting ship $

   verify_rule_name     pa_utils.Char30TabTyp;

   verify_error_code    pa_utils.Char30TabTyp;

   verify_required_flag  pa_utils.Char1TabTyp;

   verify_action_msg    pa_utils.Char240TabTyp;

   verify_error_msg    pa_utils.Char240TabTyp;

   procedure verification ( x_project_type  IN VARCHAR2, num_rows OUT NUMBER );


   procedure manager (x_index IN NUMBER, x_rule_name IN VARCHAR2,
   x_project_type IN VARCHAR2, x_description IN VARCHAR2, x_flag IN VARCHAR2);
   PROCEDURE client (x_index IN NUMBER, x_rule_name IN VARCHAR2,
   x_project_type IN VARCHAR2, x_description IN VARCHAR2, x_flag IN VARCHAR2);
   PROCEDURE contact (x_index IN NUMBER, x_rule_name IN VARCHAR2,
   x_project_type IN VARCHAR2, x_description IN VARCHAR2, x_flag IN VARCHAR2);
   PROCEDURE cost_budget (x_index IN NUMBER, x_rule_name IN VARCHAR2,
   x_project_type IN VARCHAR2, x_description IN VARCHAR2,x_flag IN VARCHAR2);
   PROCEDURE revenue_budget (x_index IN NUMBER, x_rule_name IN VARCHAR2,
   x_project_type IN VARCHAR2, x_description IN VARCHAR2,x_flag IN VARCHAR2);
   PROCEDURE category (x_index IN NUMBER, x_rule_name IN VARCHAR2,
   x_project_type IN VARCHAR2, x_description IN VARCHAR2,x_flag IN VARCHAR2);
   PROCEDURE billing_event (x_index IN NUMBER, x_rule_name IN VARCHAR2,
   x_project_type IN VARCHAR2, x_description IN VARCHAR2,x_flag IN VARCHAR2);

   function	get_rule_name(xrow IN NUMBER) return varchar2;
   function	get_error_msg(xrow IN NUMBER) return varchar2;
   function     get_action_msg(xrow IN NUMBER) return varchar2;
   function     get_required_flag(xrow IN NUMBER) return varchar2;

END;

 

/
