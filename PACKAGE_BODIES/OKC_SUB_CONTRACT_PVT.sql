--------------------------------------------------------
--  DDL for Package Body OKC_SUB_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SUB_CONTRACT_PVT" AS
/*$Header: OKCRSUBB.pls 120.0 2005/05/25 18:45:04 appldev noship $*/

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

 PROCEDURE subcontract_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_id                       IN NUMBER,
    x_cle_id                       OUT NOCOPY NUMBER) IS
BEGIN
NULL;
END;

END okc_sub_contract_pvt;

/
