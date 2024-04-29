--------------------------------------------------------
--  DDL for Package GMS_POR_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_POR_API2" AUTHID CURRENT_USER as
--$Header: gmspor2s.pls 120.0 2005/05/29 12:26:03 appldev noship $

        --=============================================================
        -- The purpose of this API is to prepare for award distributions
        -- and kicks off award distribution engine
        --=============================================================
        PROCEDURE distribute_award ( p_doc_header_id               IN NUMBER,
                                     p_distribution_id             IN NUMBER,
                                     p_document_source             IN VARCHAR2,
                                     p_gl_encumbered_date          IN DATE,
                                     p_project_id                  IN NUMBER,
                                     p_task_id                     IN NUMBER,
                                     p_dummy_award_id              IN NUMBER,
                                     p_expenditure_type            IN VARCHAR2,
                                     p_expenditure_organization_id IN NUMBER,
                                     p_expenditure_item_date       IN DATE,
                                     p_quantity                    IN NUMBER,
                                     p_unit_price                  IN NUMBER,
                                     p_func_amount                 IN NUMBER,
                                     p_vendor_id                   IN NUMBER,
                                     p_source_type_code            IN VARCHAR2,
                                     p_award_qty_obj               OUT NOCOPY gms_obj_award2,
                                     p_status                      OUT NOCOPY VARCHAR2,
                                     p_error_msg_label             OUT NOCOPY VARCHAR2 );


END GMS_POR_API2 ;

 

/
