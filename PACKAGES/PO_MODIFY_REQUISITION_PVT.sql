--------------------------------------------------------
--  DDL for Package PO_MODIFY_REQUISITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_MODIFY_REQUISITION_PVT" AUTHID CURRENT_USER AS
  /* $Header: PO_MODIFY_REQUISITION_PVT.pls 120.4 2005/09/22 04:23:09 asista noship $ */

    PROCEDURE create_requisition_lines(p_api_version      IN NUMBER,
                                      p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                                      p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                                      x_return_status    OUT NOCOPY VARCHAR2,
                                      x_msg_count        OUT NOCOPY NUMBER,
                                      x_msg_data         OUT NOCOPY VARCHAR2,
                                      p_req_line_id      IN NUMBER,
                                      p_num_of_new_lines IN NUMBER,
                                      p_quantity_tbl     IN PO_TBL_NUMBER,
                                      p_agent_id         IN NUMBER,
                                      p_calling_program  IN VARCHAR2,
                                      x_new_line_ids_tbl OUT NOCOPY PO_TBL_NUMBER,
                                      x_error_msg_tbl    OUT NOCOPY PO_TBL_VARCHAR2000
                                      ) ;

    PROCEDURE split_requisition_lines(p_api_version      IN NUMBER,
                                      p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                                      p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                                      x_return_status    OUT NOCOPY VARCHAR2,
                                      x_msg_count        OUT NOCOPY NUMBER,
                                      x_msg_data         OUT NOCOPY VARCHAR2,
                                      p_req_line_id      IN NUMBER,
                                      p_num_of_new_lines IN NUMBER,
                                      p_quantity_tbl     IN PO_TBL_NUMBER,
                                      p_agent_id         IN NUMBER,
                                      p_calling_program  IN VARCHAR2,
                                      p_handle_tax_diff_if_enc  IN VARCHAR2,
                                      x_new_line_ids_tbl OUT NOCOPY PO_TBL_NUMBER,
                                      x_error_msg_tbl    OUT NOCOPY PO_TBL_VARCHAR2000
                                      ) ;
    PROCEDURE post_modify_requisition_lines(p_api_version      IN NUMBER,
                                      p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                                      p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                                      x_return_status    OUT NOCOPY VARCHAR2,
                                      x_msg_count        OUT NOCOPY NUMBER,
                                      x_msg_data         OUT NOCOPY VARCHAR2,
                                      p_req_line_id      IN NUMBER,
                                      p_handle_tax_diff_if_enc  IN VARCHAR2,
                                      p_new_line_ids_tbl IN PO_TBL_NUMBER,
                                      x_error_msg_tbl    OUT NOCOPY PO_TBL_VARCHAR2000
                                      );
    PROCEDURE call_funds_reversal(p_api_version      IN NUMBER,
                                    p_commit           IN VARCHAR2,
                                    x_return_status    OUT NOCOPY VARCHAR2,
                                    x_msg_count        OUT NOCOPY NUMBER,
                                    x_msg_data         OUT NOCOPY VARCHAR2,
                                    p_req_line_id      IN NUMBER,
                                    p_handle_tax_flag  IN VARCHAR2,
                                    x_online_report_id OUT NOCOPY NUMBER) ;
END;

 

/
