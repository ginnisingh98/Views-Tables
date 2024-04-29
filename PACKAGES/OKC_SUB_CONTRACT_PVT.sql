--------------------------------------------------------
--  DDL for Package OKC_SUB_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_SUB_CONTRACT_PVT" AUTHID CURRENT_USER AS
/*$Header: OKCRSUBS.pls 120.0 2005/05/26 09:49:31 appldev noship $*/

 PROCEDURE subcontract_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_id                       IN NUMBER,
    x_cle_id                       OUT NOCOPY NUMBER);

END okc_sub_contract_pvt;

 

/
