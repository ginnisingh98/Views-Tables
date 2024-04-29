--------------------------------------------------------
--  DDL for Package Body PA_DM_NUMBER_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DM_NUMBER_CLIENT_EXTN" AS
/* $Header: PADMNRXB.pls 120.0.12010000.1 2009/07/21 10:59:35 sosharma noship $ */


PROCEDURE GET_NEXT_NUMBER (
         p_project_id           IN  NUMBER
        ,p_vendor_id            IN  NUMBER
        ,p_vendor_site_id       IN  NUMBER
        ,p_org_id               IN  NUMBER
        ,p_po_header_id         IN  NUMBER
        ,p_ci_id                IN  NUMBER
        ,p_dctn_req_date        IN  DATE
        ,p_debit_memo_date      IN  DATE
        ,p_next_number          IN  OUT NOCOPY VARCHAR2
        ,x_return_status        OUT NOCOPY VARCHAR2
        ,x_msg_count            OUT NOCOPY NUMBER
        ,x_msg_data             OUT NOCOPY VARCHAR2) IS

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    p_next_number   := p_next_number;
END GET_NEXT_NUMBER;
END PA_DM_NUMBER_CLIENT_EXTN;


/
