--------------------------------------------------------
--  DDL for Package XNP_MSG_BUILDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_MSG_BUILDER" AUTHID CURRENT_USER AS
/* $Header: XNPMBLPS.pls 120.1 2005/06/18 00:22:45 appldev  $ */

-- API interface to build XNP$<msg_type> package spec and body
--
PROCEDURE COMPILE
 (P_MSG_CODE IN VARCHAR2
 ,X_ERROR_CODE OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 ,X_PACKAGE_SPEC  OUT NOCOPY VARCHAR2
 ,X_PACKAGE_BODY  OUT NOCOPY VARCHAR2
 ,X_SYNONYM       OUT NOCOPY VARCHAR2
 );

g_ack_reqd_flag   VARCHAR2(2) := 'N' ;
--Copy Message from an existing message
--
  PROCEDURE CopyMesg(
        p_old_msg_code        IN VARCHAR2,
        p_new_msg_code        IN VARCHAR2,
        p_new_disp_name       IN VARCHAR2,
        p_return_code        OUT NOCOPY NUMBER,
        p_error_description  OUT NOCOPY VARCHAR2) ;


END XNP_MSG_BUILDER;

 

/
