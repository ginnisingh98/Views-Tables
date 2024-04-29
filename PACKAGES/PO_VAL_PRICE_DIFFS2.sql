--------------------------------------------------------
--  DDL for Package PO_VAL_PRICE_DIFFS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_PRICE_DIFFS2" AUTHID CURRENT_USER AS
-- $Header: PO_VAL_PRICE_DIFFS2.pls 120.3 2006/08/02 23:14:24 jinwang noship $


  PROCEDURE price_type(p_id_tbl         IN PO_TBL_NUMBER,
                       p_price_type_tbl IN PO_TBL_VARCHAR30,
                       x_result_set_id  IN OUT NOCOPY NUMBER,
                       x_result_type    OUT NOCOPY VARCHAR2);

  PROCEDURE multiple_price_diff(p_id_tbl          IN PO_TBL_NUMBER,
                                p_price_type_tbl  IN PO_TBL_VARCHAR30,
                                p_entity_type_tbl IN PO_TBL_VARCHAR30,
                                p_entity_id_tbl   IN PO_TBL_NUMBER,
                                x_result_set_id   IN OUT NOCOPY NUMBER,
                                x_result_type     OUT NOCOPY VARCHAR2);

  PROCEDURE entity_type(p_id_tbl          IN PO_TBL_NUMBER,
                        p_entity_type_tbl IN PO_TBL_VARCHAR30,
                        p_doc_type        IN VARCHAR2,
                        x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                        x_result_type     OUT NOCOPY VARCHAR2);

  PROCEDURE multiplier(p_id_tbl          IN PO_TBL_NUMBER,
                       p_entity_type_tbl IN PO_TBL_VARCHAR30,
                       p_multiplier_tbl  IN PO_TBL_NUMBER,
                       x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                       x_result_type     OUT NOCOPY VARCHAR2);

  PROCEDURE min_multiplier(p_id_tbl             IN PO_TBL_NUMBER,
                           p_entity_type_tbl    IN PO_TBL_VARCHAR30,
                           p_min_multiplier_tbl IN PO_TBL_NUMBER,
                           x_results            IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                           x_result_type        OUT NOCOPY VARCHAR2);

  PROCEDURE max_multiplier(p_id_tbl             IN PO_TBL_NUMBER,
                           p_entity_type_tbl    IN PO_TBL_VARCHAR30,
                           p_max_multiplier_tbl IN PO_TBL_NUMBER,
                           x_results            IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                           x_result_type        OUT NOCOPY VARCHAR2);

  PROCEDURE style_related_info(p_id_tbl            IN              po_tbl_number,
                               p_style_id_tbl      IN              po_tbl_number,
                               x_result_set_id     IN OUT NOCOPY   NUMBER,
                               x_result_type       OUT NOCOPY      VARCHAR2);


END PO_VAL_PRICE_DIFFS2;

 

/
