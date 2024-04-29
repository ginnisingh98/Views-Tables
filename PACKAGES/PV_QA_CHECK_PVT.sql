--------------------------------------------------------
--  DDL for Package PV_QA_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_QA_CHECK_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvqacs.pls 120.0 2005/05/27 15:22:31 appldev noship $ */

  PROCEDURE execute_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_doc_type                     IN  VARCHAR2,
    p_doc_id                       IN  NUMBER,
    x_qa_return_status             OUT NOCOPY VARCHAR2,
    x_msg_tbl                      OUT NOCOPY JTF_VARCHAR2_TABLE_2000);

  END PV_QA_CHECK_PVT;


 

/
