--------------------------------------------------------
--  DDL for Package POR_APPROVAL_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_APPROVAL_LIST" AUTHID CURRENT_USER AS
/* $Header: PORAPRLS.pls 120.1 2006/06/28 06:25:32 mkohale noship $ */

g_document_type    VARCHAR2(20) := 'REQUISITION';
g_document_subtype VARCHAR2(20) := 'PURCHASE';

PROCEDURE get_approval_list(p_document_id             IN  NUMBER,
                            p_first_approver_id       IN  NUMBER DEFAULT NULL,
                            p_default_flag            IN  NUMBER DEFAULT NULL,
                            p_rebuild_flag            IN  NUMBER DEFAULT NULL,
                            p_approval_list_header_id OUT NOCOPY NUMBER,
                            p_last_update_date        OUT NOCOPY VARCHAR2,
                            p_approval_list_string    OUT NOCOPY VARCHAR2,
                            p_approval_list_count     OUT NOCOPY NUMBER,
                            p_quote_char              OUT NOCOPY VARCHAR2,
                            p_field_delimiter         OUT NOCOPY VARCHAR2,
                            p_return_code             OUT NOCOPY NUMBER,
                            p_error_stack_string      OUT NOCOPY VARCHAR2,
			    p_preparer_can_approve    OUT NOCOPY NUMBER,
                            p_append_saved_approver_flag  IN  NUMBER DEFAULT NULL,
                            p_checkout_flow_type      IN  VARCHAR2 DEFAULT NULL);


PROCEDURE save_approval_list(p_document_id             IN     NUMBER,
                             p_approval_list_string    IN     VARCHAR2,
                             p_approval_list_header_id IN OUT NOCOPY NUMBER,
                             p_first_approver_id       IN     NUMBER,
                             p_last_update_date        IN OUT NOCOPY VARCHAR2,
                             p_quote_char              IN     VARCHAR2,
                             p_field_delimiter         IN     VARCHAR2,
                             p_return_code             OUT NOCOPY    NUMBER,
                             p_error_stack_string      OUT NOCOPY    VARCHAR2);

PROCEDURE temp_get_rebuild_to_work(p_document_id             IN  NUMBER);

procedure copy_approval_list(p_existing_requisition_id IN  NUMBER,
                            p_new_requisition_id IN  NUMBER);

END por_approval_list;

 

/
