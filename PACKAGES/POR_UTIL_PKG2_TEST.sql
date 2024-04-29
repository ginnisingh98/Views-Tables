--------------------------------------------------------
--  DDL for Package POR_UTIL_PKG2_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_UTIL_PKG2_TEST" AUTHID CURRENT_USER AS
/* $Header: PORUTL2S.pls 115.0 99/07/17 03:33:09 porting shi $ */

g_document_type    VARCHAR2(20) := 'REQUISITION';
g_document_subtype VARCHAR2(20) := 'PURCHASE';

PROCEDURE get_approval_list(p_document_id             IN  NUMBER,
                            p_first_approver_id       IN  NUMBER DEFAULT NULL,
                            p_default_flag            IN  NUMBER DEFAULT NULL,
                            p_rebuild_flag            IN  NUMBER DEFAULT NULL,
                            p_approval_list_header_id OUT NUMBER,
                            p_last_update_date        OUT VARCHAR2,
                            p_approval_list_string    OUT VARCHAR2,
                            p_approval_list_count     OUT NUMBER,
                            p_quote_char              OUT VARCHAR2,
                            p_field_delimiter         OUT VARCHAR2,
                            p_return_code             OUT NUMBER,
                            p_error_stack_string      OUT VARCHAR2);


PROCEDURE save_approval_list(p_document_id             IN     NUMBER,
                             p_approval_list_string    IN     VARCHAR2,
                             p_approval_list_header_id IN OUT NUMBER,
                             p_first_approver_id       IN     NUMBER,
                             p_last_update_date        IN     VARCHAR2,
                             p_quote_char              IN     VARCHAR2,
                             p_field_delimiter         IN     VARCHAR2,
                             p_return_code             OUT    NUMBER,
                             p_error_stack_string      OUT    VARCHAR2);

END por_util_pkg2_test;

 

/
