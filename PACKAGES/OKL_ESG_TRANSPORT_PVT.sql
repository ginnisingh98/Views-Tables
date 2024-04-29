--------------------------------------------------------
--  DDL for Package OKL_ESG_TRANSPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ESG_TRANSPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLESTRS.pls 120.1 2008/02/29 10:49:07 nikshah noship $ */
/*#
 * This package is used to send an external stream generation request to 3rd party.
 * @rep:scope public
 * @rep:product OKL
 * @rep:lifecycle active
 * @rep:displayname External Stream Generation Transport API
 * @rep:compatibility N
 * @rep:category BUSINESS_ENTITY OKL_ORIGINATION
 */

    G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
    G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
    G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

    G_RET_STS_SUCCESS     CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    G_RET_STS_ERROR       CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
    G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;

    G_PKG_NAME            CONSTANT VARCHAR2(200) := 'OKL_ESG_TRANSPORT_PVT';
    G_APP_NAME            CONSTANT VARCHAR2(3) := OKL_API.G_APP_NAME;

    /*#
     * This procedure is used to transport the outbound xml
     *    to 3rd party stream generation server.
     * @param p_transaction_number a transaction number
     * @rep:displayname Transport
     * @rep:lifecycle active
     * @rep:compatibility N
     */
    PROCEDURE transport(p_transaction_number  IN NUMBER);

    /*#
     * This procedure is used to process external stream generation.
     * @param p_transaction_number a transaction number
     * @param x_return_status return status of transport procedure
     * @rep:displayname Process External Stream Generation
     * @rep:lifecycle active
     * @rep:compatibility N
     */
    PROCEDURE process_esg(p_transaction_number IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

END OKL_ESG_TRANSPORT_PVT;

/
