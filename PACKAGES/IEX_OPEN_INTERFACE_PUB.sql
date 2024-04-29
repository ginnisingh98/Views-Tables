--------------------------------------------------------
--  DDL for Package IEX_OPEN_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_OPEN_INTERFACE_PUB" AUTHID CURRENT_USER AS
/* $Header: IEXPOPIS.pls 120.3 2004/12/16 15:20:56 jsanju ship $ */

subtype iohv_rec_type is iex_ioh_pvt.iohv_rec_type;
subtype oinv_rec_type is okl_open_int_pub.oinv_rec_type;

---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
G_PKG_NAME			CONSTANT VARCHAR2(200) := 'IEX_OPEN_INTERFACE_PUB';
G_APP_NAME			CONSTANT VARCHAR2(3)   := 'IEX';

---------------------------------------------------------------------------
-- GLOBAL EXCEPTION
---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
---------------------------------------------------------------------------

  PROCEDURE report_all_credit_bureau(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER);

  PROCEDURE insert_pending(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2,
     p_object1_id1              IN VARCHAR2,
     p_object1_id2              IN VARCHAR2,
     p_jtot_object1_code        IN VARCHAR2,
     p_action                   IN VARCHAR2,
     p_status                   IN VARCHAR2,
     p_comments                 IN VARCHAR2,
     p_ext_agncy_id             IN NUMBER,
     p_review_date              IN DATE,
     p_recall_date              IN DATE,
     p_automatic_recall_flag    IN VARCHAR2,
     p_review_before_recall_flag    IN VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  PROCEDURE process_pending(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_jtot_object1_code        IN VARCHAR2,
     p_case_number              IN VARCHAR2);

  PROCEDURE complete_report_cb(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 ,
     p_interface_id             IN NUMBER,
     p_report_date              IN DATE,
     p_comments                 IN VARCHAR2 ,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  PROCEDURE complete_transfer(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 ,
     p_interface_id             IN NUMBER,
     p_transfer_date            IN DATE,
     p_comments                 IN VARCHAR2 ,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  PROCEDURE recall_transfer(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT NULL,
     p_interface_id             IN NUMBER,
     p_recall_date              IN DATE,
     p_comments                 IN VARCHAR2 DEFAULT NULL,
     p_ext_agncy_id             IN NUMBER DEFAULT NULL,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  PROCEDURE review_transfer(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 ,
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_oinv_rec                 OUT NOCOPY oinv_rec_type,
     x_iohv_rec                 OUT NOCOPY iohv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  PROCEDURE notify_customer(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_jtot_object1_code        IN VARCHAR2,
     p_case_number              IN VARCHAR2,
     p_party_id                 IN NUMBER,
     p_agent_id                 IN NUMBER,
     p_content_id               IN VARCHAR2,
     p_from                     IN  VARCHAR2,
     p_subject                  IN VARCHAR2,
     p_email                    IN VARCHAR2);

  PROCEDURE notify_recall_external_agency(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_jtot_object1_code        IN VARCHAR2,
     p_case_number              IN VARCHAR2,
     p_ext_agncy_id             IN NUMBER,
     p_comments                 IN VARCHAR2);

  PROCEDURE notify_external_agency(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_jtot_object1_code        IN VARCHAR2,
     p_case_number              IN VARCHAR2,
     p_ext_agncy_id             IN NUMBER,
     p_agent_id                 IN NUMBER,
     p_content_id               IN VARCHAR2,
     p_from                     IN  VARCHAR2,
     p_subject                  IN VARCHAR2,
     p_email                    IN VARCHAR2);

PROCEDURE recall_from_external_agency(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_jtot_object1_code        IN VARCHAR2,
     p_case_number              IN VARCHAR2,
     p_ext_agncy_id             IN NUMBER,
     p_comments                 IN VARCHAR2);

END iex_open_interface_pub;

 

/
