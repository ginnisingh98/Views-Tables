--------------------------------------------------------
--  DDL for Package MSC_A2A_XML_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_A2A_XML_WF" AUTHID CURRENT_USER as
/* $Header: MSCXMLWS.pls 115.4 2002/10/04 19:40:46 rawasthi ship $*/

PROCEDURE LOG_MESSAGE (pBUFF  IN  VARCHAR2);

PROCEDURE PURGE_INTERFACE (p_map_code IN VARCHAR2, p_unique_id IN NUMBER);

PROCEDURE RESCHEDULE_PO (p_map_code IN VARCHAR2 DEFAULT 'MSC_POO_OAG71_OUT',
                        p_instance_id IN NUMBER,
                        p_purchase_order_id IN NUMBER);


PROCEDURE CREATE_REQ ( p_map_code IN VARCHAR2 DEFAULT 'MSC_REQUISITNO_OAG71_OUT',
                      p_source_line_id IN NUMBER,
                      p_instance_id IN NUMBER);


PROCEDURE SYNC_WORK_ORDER(p_map_code IN VARCHAR2  DEFAULT 'MSC_PRODORDERO_OAG71_OUT',
                          p_source_line_id IN NUMBER,
                          p_instance_id IN NUMBER);


PROCEDURE CREATE_WORK_ORDER(p_map_code IN VARCHAR2 DEFAULT 'MSC_PRODORDERC_OAG71_OUT',
                            p_source_line_id IN NUMBER,
                            p_instance_id IN NUMBER);



PROCEDURE PUSH_PLAN_OUTPUT (p_map_code IN VARCHAR2 DEFAULT 'MSC_PLANSCHDO_OAG71_OUT',
                            p_compile_designator VARCHAR2,
                            p_instance_id IN NUMBER,
                            p_buy_items_only NUMBER);

PROCEDURE LEGACY_RELEASE ( p_instance_id IN NUMBER);


end MSC_A2A_XML_WF;

 

/
