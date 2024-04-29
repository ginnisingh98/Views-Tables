--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_STATUS_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPSTKS.pls 120.4 2008/02/29 10:52:57 nikshah ship $ */
/*#
 * Contract Status API allows users to get the status of a
 * lease contract.
 * @rep:scope public
 * @rep:product OKL
 * @rep:displayname Get Contract Status API
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT_LIFECYCLE
 * @rep:lifecycle active
 * @rep:compatibility S
 */


-- Global variables for user hooks
  G_PKG_NAME   CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_STATUS_PUB';
  G_APP_NAME   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

-- Global error messages
  G_CANNOT_GENSTRMS      CONSTANT VARCHAR2(200) := 'OKL_LLA_CTGEN_STRMS';
  G_STRMS_IN_PROGRESS    CONSTANT VARCHAR2(200) := 'OKL_LLA_STRMS_PRGRS';
  G_GENSTRMS_REQ_FAILED  CONSTANT VARCHAR2(200) := 'OKL_LLA_STRMS_REQ_FLD';
  G_NO_ACTV_TMPCONTRACT  CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_ACTV_TMPCONTRACT';
  G_CANNOT_GENJRNL       CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_CTGEN_JRNLS';
  G_NOT_APPROVED         CONSTANT VARCHAR2(200) := 'OKL_LLA_NOT_APPROVED';
  G_NOT_COMPLETE         CONSTANT VARCHAR2(200) := 'OKL_LLA_NOT_COMPLETE';
  G_NOT_VALIDATE         CONSTANT VARCHAR2(200) := 'OKL_LLA_NOT_VALIDATE';

-- Contract actions
  G_K_NEW  CONSTANT VARCHAR2(60) := 'NEW';
  G_K_EDIT CONSTANT VARCHAR2(60) := 'EDIT';
  G_K_QACHECK CONSTANT VARCHAR2(60) := 'QA_CHECK';
  G_K_STRMGEN CONSTANT VARCHAR2(60) := 'STRMGEN';
  G_K_JOURNAL CONSTANT VARCHAR2(60) := 'JOURNAL';
  G_K_SUBMIT4APPRVL CONSTANT VARCHAR2(60) := 'SUBMIT_FOR_APPROVAL';
  G_K_APPROVAL CONSTANT VARCHAR2(60) := 'APPROVAL';
  G_K_ACTIVATE CONSTANT VARCHAR2(60) := 'ACTIVATE';

  G_K_NOT_ALLOWED CONSTANT VARCHAR2(100) := 'G_K_NOT_ALLOWED';

/*#
 * Get contract status.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Error message data
 * @param x_isAllowed True or False indicates whether event is allowed
 * @param x_PassStatus  Passed status
 * @param x_FailStatus  Failed status
 * @param p_event  Event name
 * @param p_chr_id Contract identifier
 * @rep:displayname Get Contract Status
 * @rep:scope public
 * @rep:lifecycle active
 */
  Procedure get_contract_status(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            x_isAllowed       OUT NOCOPY BOOLEAN,
            x_PassStatus      OUT NOCOPY VARCHAR2,
            x_FailStatus      OUT NOCOPY VARCHAR2,
            p_event           IN  VARCHAR2,
            p_chr_id          IN  VARCHAR2);

  Procedure update_contract_status(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_khr_status      IN  VARCHAR2,
            p_chr_id          IN  VARCHAR2);

Procedure cascade_lease_status
            (p_api_version     IN  NUMBER,
             p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2,
             p_chr_id          IN  NUMBER);

Procedure cascade_lease_status_edit
            (p_api_version     IN  NUMBER,
             p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2,
             p_chr_id          IN  NUMBER);
End OKL_CONTRACT_STATUS_PUB;

/
