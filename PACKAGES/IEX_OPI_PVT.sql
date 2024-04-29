--------------------------------------------------------
--  DDL for Package IEX_OPI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_OPI_PVT" AUTHID CURRENT_USER AS
/* $Header: IEXROPIS.pls 120.0 2004/01/24 03:15:23 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- Sub type Open Interface records
  subtype oinv_rec_type is okl_oin_pvt.oinv_rec_type;
  subtype oinv_tbl_type is okl_oin_pvt.oinv_tbl_type;

  subtype iohv_rec_type is iex_ioh_pvt.iohv_rec_type;
  subtype iohv_tbl_type is iex_ioh_pvt.iohv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                     CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
  G_REQUIRED_VALUE              CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE               CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_INVALID_ACTION_STATUS       CONSTANT VARCHAR2(200) := 'INVALID_ACTION_STATUS';
  G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_NAME1_TOKEN             CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN             CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN	        CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'IEX_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'IEX_SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'IEX_SQLCODE';
  G_TASK_CREATION_FAILURE       CONSTANT VARCHAR2(200) := 'IEX_TASK_CREATION_FAILURE';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'IEX_OPI_PVT';
  G_APP_NAME                    CONSTANT VARCHAR2(3)   :=  'IEX';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_INVALID_PARAMETERS          EXCEPTION;

  ---------------------------------------------------------------------------
  -- CONSTANTS FOR ACTION AND STATUS
  ---------------------------------------------------------------------------
  ACTION_NOTIFY_CUST        CONSTANT VARCHAR2(30) := 'NOTIFY_CUST';
  ACTION_REPORT_CB          CONSTANT VARCHAR2(30) := 'REPORT_CB';
  ACTION_TRANSFER_EXT_AGNCY CONSTANT VARCHAR2(30) := 'TRANSFER_EXT_AGNCY';
  ACTION_NOTIFY_EXT_AGNCY   CONSTANT VARCHAR2(30) := 'NOTIFY_EXT_AGNCY';
  ACTION_RECALL_NOTICE      CONSTANT VARCHAR2(30) := 'RECALL_NOTICE';
  ACTION_NOTIFY_RECALL      CONSTANT VARCHAR2(30) := 'NOTIFY_RECALL';


  STATUS_PENDING_AUTO       CONSTANT VARCHAR2(30) := 'PENDING_AUTO';
  STATUS_PENDING_MANUAL     CONSTANT VARCHAR2(30) := 'PENDING_MANUAL';
  STATUS_PENDING_ALL        CONSTANT VARCHAR2(30) := 'PENDING_ALL';
  STATUS_PROCESSED          CONSTANT VARCHAR2(30) := 'PROCESSED';
  STATUS_COMPLETE           CONSTANT VARCHAR2(30) := 'COMPLETE';
  STATUS_RECALLED           CONSTANT VARCHAR2(30) := 'RECALLED';
  STATUS_NOTIFIED           CONSTANT VARCHAR2(30) := 'NOTIFIED';
  STATUS_COLLECTED          CONSTANT VARCHAR2(30) := 'COLLECTED';

  ---------------------------------------------------------------------------
  -- CONSTANTS FOR CASE DELINQUENCY STATUS
  ---------------------------------------------------------------------------
  CASE_STATUS_CURRENT       CONSTANT VARCHAR2(30) := 'CURRENT';
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;

  PROCEDURE report_all_credit_bureau(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER);

  PROCEDURE insert_pending_hst(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_iohv_rec                 IN iohv_rec_type,
     x_iohv_rec                 OUT NOCOPY iohv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  PROCEDURE process_pending_hst(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_iohv_rec                 OUT NOCOPY iohv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  PROCEDURE process_pending(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_case_number              IN VARCHAR2);

  ---------------------------------------------------------------------------
  -- API for the credit bureau to update the date the record was accesed
  -- and free text comment
  ---------------------------------------------------------------------------
  PROCEDURE complete_report_cb(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_interface_id             IN NUMBER,
     p_report_date              IN DATE,
     p_comments                 IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  ---------------------------------------------------------------------------
  -- API to update the notification date, the customer was notified about
  -- intent to report to the credit bureau
  ---------------------------------------------------------------------------
  PROCEDURE complete_notify(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_interface_id             IN NUMBER,
     p_hst_id                   IN NUMBER,
     p_notification_date        IN DATE,
     p_comments                 IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  ---------------------------------------------------------------------------
  -- API for the external agency to update the date the record was accesed
  -- and free text comment
  ---------------------------------------------------------------------------
  PROCEDURE complete_transfer(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_interface_id             IN NUMBER,
     p_transfer_date            IN DATE,
     p_comments                 IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  ---------------------------------------------------------------------------
  -- API to update the date, the external agency was notified about
  -- intent to recall or recall, of the contract
  ---------------------------------------------------------------------------
  PROCEDURE complete_notify_ext_agncy(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_interface_id             IN NUMBER,
     p_hst_id                   IN NUMBER,
     p_notification_date        IN DATE,
     p_comments                 IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  ---------------------------------------------------------------------------
  -- API to update the date the contract was actually recalled from the
  -- external agency. Optionally, the ext_agncy id of the agency to transfer the
  -- case to, after it has been recalled, can also be passed
  ---------------------------------------------------------------------------
  PROCEDURE recall_transfer(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_interface_id             IN NUMBER,
     p_recall_date              IN DATE,
     p_comments                 IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR,
     p_ext_agncy_id             IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);


  ---------------------------------------------------------------------------
  -- API to review the transfer of the contract to the external agency. It rescores
  -- the case to which the contract belongs, checks for score progress and recalls
  -- contracts with unsatisfactory score channges
  ---------------------------------------------------------------------------
  PROCEDURE review_transfer(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_oinv_rec                OUT NOCOPY oinv_rec_type,
     x_iohv_rec                OUT NOCOPY iohv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  ---------------------------------------------------------------------------
  -- API to create a followup task to review the transfer of the contract before recalling
  -- from the external agency
  ---------------------------------------------------------------------------
  PROCEDURE create_followup(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     p_task_name                IN VARCHAR2,
     p_description              IN VARCHAR2,
     p_start_date               IN DATE DEFAULT SYSDATE,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  ---------------------------------------------------------------------------
  -- Concurrent API to send out NOCOPY notifications to the customer about intent to
  -- report to credit bureau
  ---------------------------------------------------------------------------
  PROCEDURE notify_customer(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_case_number              IN VARCHAR2,
     p_party_id                 IN NUMBER,
     p_agent_id                 IN NUMBER,
     p_content_id               IN VARCHAR2,
     p_from                     IN  VARCHAR2,
     p_subject                  IN VARCHAR2,
     p_email                    IN VARCHAR2);

  ---------------------------------------------------------------------------
  -- Concurrent API to initiate the recall of contracts from external agencies.
  -- This API creates pending notifications to be sent to the external agency
  -- to inform them of intent to recall the contract.
  ---------------------------------------------------------------------------
  PROCEDURE notify_recall_external_agency(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_case_number              IN VARCHAR2,
     p_ext_agncy_id             IN NUMBER,
     p_comments                 IN VARCHAR2);

  ---------------------------------------------------------------------------
  -- Concurrent API to send out NOCOPY notifications to the external agency about
  -- recall/intent to recall contract
  ---------------------------------------------------------------------------
  PROCEDURE notify_external_agency(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_case_number              IN VARCHAR2,
     p_ext_agncy_id             IN NUMBER,
     p_agent_id                 IN NUMBER,
     p_content_id               IN VARCHAR2,
     p_from                     IN  VARCHAR2,
     p_subject                  IN VARCHAR2,
     p_email                    IN VARCHAR2);

  ---------------------------------------------------------------------------
  -- Concurrent API to recall contracts from external agencies.
  -- This API will recall contracts which the EA has been notified about
  -- and send a notification to inform them about the recall of the contract.
  ---------------------------------------------------------------------------
  PROCEDURE recall_from_external_agency(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_case_number              IN VARCHAR2,
     p_ext_agncy_id             IN NUMBER,
     p_comments                 IN VARCHAR2);

  PROCEDURE get_hst_info(
     p_hst_id                   IN NUMBER,
     x_action                   OUT NOCOPY VARCHAR2,
     x_status                   OUT NOCOPY VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE get_party_email(
     p_party_id                 IN NUMBER,
     x_email                    OUT NOCOPY VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE get_ext_agncy_email(
     p_ext_agncy_id             IN NUMBER,
     x_email                    OUT NOCOPY VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE get_external_agency(
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_ext_agncy_id             OUT NOCOPY NUMBER,
     x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE get_contract_recall(
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_recall                    OUT NOCOPY VARCHAR2,
     x_return_status             OUT NOCOPY VARCHAR2);

  PROCEDURE get_contract_delinquency_stat(
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_delinquency_status       OUT NOCOPY VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2);
END IEX_OPI_PVT;

 

/
