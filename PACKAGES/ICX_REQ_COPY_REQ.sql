--------------------------------------------------------
--  DDL for Package ICX_REQ_COPY_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_REQ_COPY_REQ" AUTHID CURRENT_USER AS
/* $Header: ICXRQCPS.pls 115.1 99/07/17 03:23:06 porting ship $ */

PROCEDURE welcome_page;

PROCEDURE find_reqs;

PROCEDURE display_reqs (a_1 IN VARCHAR2 DEFAULT NULL,
                        c_1 IN VARCHAR2 DEFAULT NULL,
                        i_1 IN VARCHAR2 DEFAULT NULL,
                        a_2 IN VARCHAR2 DEFAULT NULL,
                        c_2 IN VARCHAR2 DEFAULT NULL,
                        i_2 IN VARCHAR2 DEFAULT NULL,
                        a_3 IN VARCHAR2 DEFAULT NULL,
                        c_3 IN VARCHAR2 DEFAULT NULL,
                        i_3 IN VARCHAR2 DEFAULT NULL,
                        a_4 IN VARCHAR2 DEFAULT NULL,
                        c_4 IN VARCHAR2 DEFAULT NULL,
                        i_4 IN VARCHAR2 DEFAULT NULL,
                        a_5 IN VARCHAR2 DEFAULT NULL,
                        c_5 IN VARCHAR2 DEFAULT NULL,
                        i_5 IN VARCHAR2 DEFAULT NULL,
                        m   IN VARCHAR2 DEFAULT NULL,
			o   IN VARCHAR2 DEFAULT 'AND',
                        p_start_row IN NUMBER DEFAULT 1,
                        p_end_row IN NUMBER DEFAULT NULL,
                        p_where IN NUMBER DEFAULT NULL);

PROCEDURE copy_req (v_req_header_id IN NUMBER);

END icx_req_copy_req;

 

/
