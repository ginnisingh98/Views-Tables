--------------------------------------------------------
--  DDL for Package POR_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_TAX_PVT" AUTHID CURRENT_USER as
/* $Header: PORVTAXS.pls 120.3 2006/05/30 23:35:58 tolick noship $ */


PROCEDURE insert_line_det_attr (p_tax_info_tbl  IN  POR_INSERT_TAX_OBJ_TBL_TYPE,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_data      OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER);

PROCEDURE delete_all_tax_attr (p_org_id        IN  NUMBER,
                               p_trx_id        IN  NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER);

PROCEDURE calculate_tax (p_tax_head_tbl         IN  POR_TAX_HEADER_OBJ_TBL_TYPE,
                         p_tax_line_tbl         IN  POR_TAX_LINE_OBJ_TBL_TYPE,
                         p_tax_dist_tbl         IN  POR_TAX_DIST_OBJ_TBL_TYPE,
                         x_tax_dist_id_tbl      OUT NOCOPY ICX_TBL_NUMBER,
                         x_tax_recov_amt_tbl    OUT NOCOPY ICX_TBL_NUMBER,
	                 x_tax_nonrecov_amt_tbl OUT NOCOPY ICX_TBL_NUMBER,
                         x_return_status        OUT NOCOPY VARCHAR2,
                         x_msg_data             OUT NOCOPY VARCHAR2,
                         x_msg_count            OUT NOCOPY NUMBER);

PROCEDURE copy_tax_attributes (p_tax_copy_tbl   IN POR_TAX_COPY_OBJ_TBL_TYPE,
                               x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_data       OUT NOCOPY VARCHAR2,
                               x_msg_count      OUT NOCOPY NUMBER);

PROCEDURE get_default_tax_attributes (p_tax_head_tbl  IN  POR_TAX_HEADER_OBJ_TBL_TYPE,
                                      p_tax_line_tbl  IN  POR_TAX_LINE_OBJ_TBL_TYPE,
                                      x_tax_country   OUT NOCOPY VARCHAR2,
                                      x_doc_subtype   OUT NOCOPY VARCHAR2,
                                      x_tax_class_tbl OUT NOCOPY ICX_TBL_VARCHAR240,
                                      x_trx_bus_tbl   OUT NOCOPY ICX_TBL_VARCHAR240,
                                      x_prd_fisc_tbl  OUT NOCOPY ICX_TBL_VARCHAR240,
                                      x_prd_type_tbl  OUT NOCOPY ICX_TBL_VARCHAR240,
                                      x_int_use_tbl   OUT NOCOPY ICX_TBL_VARCHAR240,
                                      x_usr_fisc_tbl  OUT NOCOPY ICX_TBL_VARCHAR240,
                                      x_ass_val_tbl   OUT NOCOPY ICX_TBL_NUMBER,
                                      x_prd_cat_tbl   OUT NOCOPY ICX_TBL_VARCHAR240,
                                      x_override_tbl  OUT NOCOPY ICX_TBL_FLAG,
                                      x_line_id_tbl   OUT NOCOPY ICX_TBL_NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_data      OUT NOCOPY VARCHAR2,
                                      x_msg_count     OUT NOCOPY NUMBER);

END POR_TAX_PVT;

 

/
