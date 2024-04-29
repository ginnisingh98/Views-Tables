--------------------------------------------------------
--  DDL for Package OKL_AM_INTEGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_INTEGRATION_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPKRBS.pls 120.4 2008/02/29 10:13:11 veramach ship $ */
/*#
 *Terminate API invalidates all termination quotes that
 * do not have a status of Complete or Canceled for a given contract.
 * @rep:scope internal
 * @rep:product OKL
 * @rep:displayname Termination API
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT_LIFECYCLE
 * @rep:lifecycle active
 * @rep:compatibility S
 */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_APP_NAME             CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_INTEGRATION_PUB';
  G_API_NAME             CONSTANT VARCHAR2(30)  := 'OKL_AM_INTEGRATION_PUB';
  G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLERRM';
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
  G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
/*#
 * Cancel Termination Quote API invalidates all termination quotes that
 * do not have a status of Complete or Canceled and updates the
 * quote status to Canceled.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param p_khr_id Contract identifier
 * @param p_source_trx_id Source transaction identifier
 * @param x_return_status  Return dtatus from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @rep:displayname Cancel Termination Quote
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT_LIFECYCLE
 */

  PROCEDURE cancel_termination_quotes  (p_api_version   IN          NUMBER,
                                        p_init_msg_list IN          VARCHAR2 DEFAULT G_FALSE,
                                        p_khr_id        IN          NUMBER,
                                        p_source_trx_id IN          NUMBER ,
                                        p_source        IN          VARCHAR2 DEFAULT NULL, -- rmunjulu 4508497
                                        x_return_status OUT NOCOPY  VARCHAR2,
                                        x_msg_count     OUT NOCOPY  NUMBER,
                                        x_msg_data      OUT NOCOPY  VARCHAR2);


END  OKL_AM_INTEGRATION_PUB;

/
