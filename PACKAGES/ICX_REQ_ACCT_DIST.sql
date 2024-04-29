--------------------------------------------------------
--  DDL for Package ICX_REQ_ACCT_DIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_REQ_ACCT_DIST" AUTHID CURRENT_USER AS
/* $Header: ICXRQADS.pls 115.1 99/07/17 03:22:36 porting ship $ */

TYPE varchar2_table IS TABLE OF VARCHAR2(50)
     INDEX BY BINARY_INTEGER;

TYPE segment_record IS RECORD (segment_name VARCHAR2(50),
                               update_flag  VARCHAR2(1));

TYPE segment_table IS TABLE OF segment_record
     INDEX BY BINARY_INTEGER;

PROCEDURE get_default_account (v_cart_id IN NUMBER,
                               v_cart_line_id IN NUMBER,
                               v_emp_id IN NUMBER,
                               v_oo_id IN NUMBER,
                               v_item_id IN VARCHAR2,
                               v_account_id OUT NUMBER,
                               v_account_num OUT VARCHAR2
                              );

PROCEDURE display_acct_distributions (p_cart_line_id IN NUMBER,
                                      p_cart_id IN NUMBER,
                                      p_show_more_lines IN NUMBER DEFAULT NULL,
                          icx_charge_acct_seg1 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg2 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg3 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg4 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg5 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg6 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg7 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg8 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg9 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg10 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg11 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg12 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg13 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg14 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg15 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg16 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg17 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg18 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg19 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg20 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg21 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg22 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg23 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg24 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg25 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg26 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg27 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg28 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg29 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg30 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_account_num IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_percentage IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_amount IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_distribution_num IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_distribution_id IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          v_error_text IN VARCHAR2 DEFAULT NULL
                                     );

PROCEDURE display_account_header (v_extended_price OUT NUMBER);

PROCEDURE print_lines_header;

PROCEDURE print_action_buttons;

PROCEDURE submit_accounts(p_cart_id IN NUMBER,
                          p_cart_line_id IN NUMBER,
                          p_user_action IN VARCHAR2 DEFAULT NULL,
                          p_show_more_lines IN NUMBER DEFAULT NULL,
                          icx_charge_acct_seg1 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg2 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg3 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg4 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg5 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg6 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg7 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg8 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg9 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg10 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg11 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg12 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg13 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg14 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg15 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg16 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg17 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg18 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg19 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg20 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg21 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg22 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg23 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg24 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg25 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg26 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg27 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg28 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg29 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg30 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_account_num IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_percentage IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_amount IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_distribution_num IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_distribution_id IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty
         );

PROCEDURE apply_account_distributions(v_cart_id IN NUMBER,
                          v_cart_line_id IN NUMBER,
                          icx_charge_acct_seg1 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg2 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg3 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg4 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg5 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg6 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg7 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg8 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg9 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg10 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg11 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg12 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg13 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg14 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg15 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg16 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg17 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg18 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg19 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg20 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg21 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg22 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg23 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg24 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg25 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg26 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg27 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg28 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg29 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg30 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_account_num IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_percentage IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_amount IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_distribution_num IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_distribution_id IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          v_error_text OUT VARCHAR2
         );

PROCEDURE apply_to_all(v_cart_id IN NUMBER,
                       v_cart_line_id IN NUMBER);

PROCEDURE display_account_errors(v_cart_id IN NUMBER,
                                 v_cart_line_id IN NUMBER);

END icx_req_acct_dist;

 

/
