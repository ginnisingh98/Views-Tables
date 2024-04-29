--------------------------------------------------------
--  DDL for Package Body PA_PCO_DOC_NUMBER_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PCO_DOC_NUMBER_CLIENT_EXTN" AS
/* $Header: PAPCORXB.pls 120.0.12010000.1 2009/07/20 10:03:36 sosharma noship $ */


PROCEDURE GET_NEXT_NUMBER (
         p_project_id           IN  NUMBER
        ,p_customer_appr        IN  VARCHAR2
        ,p_change_req_id        IN  NUMBER
        ,p_chage_req_ver        IN  NUMBER
        ,p_next_number          IN  OUT NOCOPY VARCHAR2
        ,x_return_status        OUT NOCOPY VARCHAR2
        ,x_msg_count            OUT NOCOPY NUMBER
        ,x_msg_data             OUT NOCOPY VARCHAR2) IS

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    p_next_number   := p_next_number;

EXCEPTION
    WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
END GET_NEXT_NUMBER;

END PA_PCO_DOC_NUMBER_CLIENT_EXTN;


/
