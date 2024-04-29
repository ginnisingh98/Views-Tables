--------------------------------------------------------
--  DDL for Package ZPB_SECURITY_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_SECURITY_CONTEXT" AUTHID CURRENT_USER AS
/* $Header: ZPBVCTXS.pls 120.4 2007/12/04 14:38:20 mbhat ship $ */

PROCEDURE INITCONTEXT           (P_USER_ID          IN VARCHAR2,
                                 P_SHADOW_ID        IN VARCHAR2,
                                 P_RESP_ID          IN VARCHAR2,
                                 P_SESSION_ID       IN VARCHAR2,
                                 P_BUSINESS_AREA_ID IN NUMBER);

PROCEDURE INITOPENSQL		 (P_BUSINESS_AREA_ID IN NUMBER, P_LANG IN VARCHAR2 default null);

PROCEDURE INITEPBLANG           (P_LANG_ID          IN VARCHAR2);

END ZPB_SECURITY_CONTEXT;


/
