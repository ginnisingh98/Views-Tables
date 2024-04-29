--------------------------------------------------------
--  DDL for Package XTR_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_WORKFLOW_PKG" AUTHID CURRENT_USER AS
/* $Header: xtrwfpks.pls 120.1 2005/06/29 07:22:28 rjose ship $*/

FUNCTION CREATE_XTR_ROLES(p_role_users IN VARCHAR2,
                          p_expiration_date IN DATE) RETURN VARCHAR2;

PROCEDURE START_WORKFLOW(p_process     IN VARCHAR2,
                         p_owner       IN VARCHAR2,
                         p_deal_no     IN NUMBER,
                         p_trans_no    IN NUMBER,
                         p_deal_type   IN VARCHAR2,
                         p_log_id      IN NUMBER default null,
                         p_varnum_1    IN NUMBER default null,
                         p_varnum_2    IN NUMBER default null,
                         p_varchar_1   IN VARCHAR2 default null,
                         p_varchar_2   IN VARCHAR2 default null,
                         p_vardate_1   IN DATE default null,
                         p_vardate_2   IN DATE default null);

PROCEDURE START_LIMITS_NTF(p_process  IN VARCHAR2,
                           p_owner    IN VARCHAR2,
                           p_receiver IN VARCHAR2,
                           p_log_id   IN NUMBER);

PROCEDURE LIMITS_BREACHED_DOC(document_id IN VARCHAR2,
                              display_type IN VARCHAR2,
                              document IN OUT NOCOPY VARCHAR2,
                              document_type IN OUT NOCOPY VARCHAR2);

PROCEDURE DELETE_XTR_USERS(p_name IN VARCHAR2,
                           p_dsp_name IN VARCHAR2,
                           p_email IN VARCHAR2);

END XTR_WORKFLOW_PKG;


 

/
