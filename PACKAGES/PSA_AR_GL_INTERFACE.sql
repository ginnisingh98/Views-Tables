--------------------------------------------------------
--  DDL for Package PSA_AR_GL_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_AR_GL_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: PSAARTCS.pls 120.6 2006/09/13 11:01:52 agovil ship $ */

PROCEDURE reset_transaction_codes
                (err_buf   	OUT NOCOPY VARCHAR2,
                 ret_code  	OUT NOCOPY VARCHAR2,
                 p_pstctrl_id   IN  VARCHAR2);

FUNCTION is_mfar_transaction (p_doc_id NUMBER, p_sob_id NUMBER) RETURN VARCHAR2;

END PSA_AR_GL_INTERFACE;

 

/
