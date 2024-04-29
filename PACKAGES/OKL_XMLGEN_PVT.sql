--------------------------------------------------------
--  DDL for Package OKL_XMLGEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_XMLGEN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLXMLGS.pls 120.1.12010000.2 2008/10/21 04:43:59 kkorrapo ship $ */
/*#
 * This package is used to generate outbound xml document.
 * @rep:scope public
 * @rep:product OKL
 * @rep:lifecycle active
 * @rep:displayname Outbound XML Generation API
 * @rep:compatibility N
 * @rep:category BUSINESS_ENTITY OKL_ORIGINATION
 */

    G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
    G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
    G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

    G_RET_STS_SUCCESS     CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    G_RET_STS_ERROR       CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
    G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;

    G_PKG_NAME            CONSTANT VARCHAR2(200) := 'OKL_XMLGEN_PVT';
    G_APP_NAME            CONSTANT VARCHAR2(3) := OKL_API.G_APP_NAME;

    /*#
     * This procedure is used to to generate outbound xml document.
     * @param p_document_id document id
     * @return Generated XML Document
     * @rep:displayname Generate XML Document
     * @rep:lifecycle active
     * @rep:compatibility N
     * @rep:scope public
     */
    FUNCTION generate_xmldocument(p_document_id IN NUMBER) RETURN CLOB;

END OKL_XMLGEN_PVT;

/
