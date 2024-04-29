--------------------------------------------------------
--  DDL for Package OKL_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLCREPS.pls 120.1 2008/01/29 14:45:25 schodava noship $ */

 SUBTYPE repv_rec_type IS	Okl_Rep_Pvt.repv_rec_type;
 SUBTYPE repv_tbl_type IS	Okl_Rep_Pvt.repv_tbl_type;

 SUBTYPE rpp_rec_type	 IS	Okl_Rpp_Pvt.rpp_rec_type;
 SUBTYPE rpp_tbl_type	 IS	Okl_Rpp_Pvt.rpp_tbl_type;

 SUBTYPE rap_rec_type	 IS	Okl_Rap_Pvt.rap_rec_type;
 SUBTYPE rap_tbl_type	 IS	Okl_Rap_Pvt.rap_tbl_type;

 SUBTYPE rps_rec_type	 IS	Okl_Rsp_Pvt.rps_rec_type;
 SUBTYPE rps_tbl_type	 IS	Okl_Rsp_Pvt.rps_tbl_type;

 SUBTYPE rtp_rec_type	 IS	Okl_Rtp_Pvt.rtp_rec_type;
 SUBTYPE rtp_tbl_type	 IS	Okl_Rtp_Pvt.rtp_tbl_type;

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_REPORT_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

 -- Variables for Pre Billing XML Publisher Report input parameters
 P_FROM_BILL_DATE       DATE;
 P_TO_BILL_DATE         DATE;
 P_CONTRACT_NUMBER			VARCHAR2(120);
 P_CUST_ACCT_ID         VARCHAR2(38);

 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

 PROCEDURE ADD_LANGUAGE;

 PROCEDURE create_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec			IN repv_rec_type,
    x_repv_rec			OUT NOCOPY repv_rec_type
 );

 PROCEDURE update_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec			IN repv_rec_type,
    x_repv_rec			OUT NOCOPY repv_rec_type
 );

 PROCEDURE delete_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec			IN repv_rec_type
 );

 PROCEDURE submit_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rep_id				IN NUMBER
 );

  PROCEDURE activate_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rep_id				IN NUMBER
 );


 PROCEDURE lock_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec			IN repv_rec_type
 );

 PROCEDURE create_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl			IN repv_tbl_type,
    x_repv_tbl			OUT NOCOPY repv_tbl_type
 );

 PROCEDURE update_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl			IN repv_tbl_type,
    x_repv_tbl			OUT NOCOPY repv_tbl_type
 );

 PROCEDURE delete_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl			IN repv_tbl_type
 );

 PROCEDURE lock_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl			IN repv_tbl_type
 );

 PROCEDURE create_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_rec			IN rpp_rec_type,
    x_rpp_rec			OUT NOCOPY rpp_rec_type
 );

 PROCEDURE update_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_rec			IN rpp_rec_type,
    x_rpp_rec			OUT NOCOPY rpp_rec_type
 );

 PROCEDURE delete_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_rec			IN rpp_rec_type
 );

 PROCEDURE lock_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_rec			IN rpp_rec_type
 );

 PROCEDURE create_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_tbl			IN rpp_tbl_type,
    x_rpp_tbl			OUT NOCOPY rpp_tbl_type
 );

 PROCEDURE update_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_tbl			IN rpp_tbl_type,
    x_rpp_tbl			OUT NOCOPY rpp_tbl_type
 );

 PROCEDURE delete_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_tbl			IN rpp_tbl_type
 );

 PROCEDURE lock_report_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rpp_tbl			IN rpp_tbl_type
 );

 PROCEDURE create_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_rec			IN rap_rec_type,
    x_rap_rec			OUT NOCOPY rap_rec_type
 );

 PROCEDURE update_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_rec			IN rap_rec_type,
    x_rap_rec			OUT NOCOPY rap_rec_type
 );

 PROCEDURE delete_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_rec			IN rap_rec_type
 );

 PROCEDURE lock_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_rec			IN rap_rec_type
 );

 PROCEDURE create_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_tbl			IN rap_tbl_type,
    x_rap_tbl			OUT NOCOPY rap_tbl_type
 );

 PROCEDURE update_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_tbl			IN rap_tbl_type,
    x_rap_tbl			OUT NOCOPY rap_tbl_type
 );

 PROCEDURE delete_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_tbl			IN rap_tbl_type
 );

 PROCEDURE lock_report_acc_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rap_tbl			IN rap_tbl_type
 );

 PROCEDURE create_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_rec			IN rps_rec_type,
    x_rps_rec			OUT NOCOPY rps_rec_type
 );

 PROCEDURE update_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_rec			IN rps_rec_type,
    x_rps_rec			OUT NOCOPY rps_rec_type
 );

 PROCEDURE delete_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_rec			IN rps_rec_type
 );

 PROCEDURE lock_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_rec			IN rps_rec_type
 );

 PROCEDURE create_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_tbl			IN rps_tbl_type,
    x_rps_tbl			OUT NOCOPY rps_tbl_type
 );

 PROCEDURE update_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_tbl			IN rps_tbl_type,
    x_rps_tbl			OUT NOCOPY rps_tbl_type
 );

 PROCEDURE delete_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_tbl			IN rps_tbl_type
 );

 PROCEDURE lock_report_strm_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rps_tbl			IN rps_tbl_type
 );

 PROCEDURE create_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_rec			IN rtp_rec_type,
    x_rtp_rec			OUT NOCOPY rtp_rec_type
 );

 PROCEDURE update_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_rec			IN rtp_rec_type,
    x_rtp_rec			OUT NOCOPY rtp_rec_type
 );

 PROCEDURE delete_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_rec			IN rtp_rec_type
 );

 PROCEDURE lock_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_rec			IN rtp_rec_type
 );

 PROCEDURE create_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_tbl			IN rtp_tbl_type,
    x_rtp_tbl			OUT NOCOPY rtp_tbl_type
 );

 PROCEDURE update_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_tbl			IN rtp_tbl_type,
    x_rtp_tbl			OUT NOCOPY rtp_tbl_type
 );

 PROCEDURE delete_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_tbl			IN rtp_tbl_type
 );

 PROCEDURE lock_report_trx_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtp_tbl			IN rtp_tbl_type
 );

 PROCEDURE create_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec			IN repv_rec_type,
    x_repv_rec			OUT NOCOPY repv_rec_type,
    p_rpp_tbl			IN rpp_tbl_type,
    x_rpp_tbl			OUT NOCOPY rpp_tbl_type,
    p_rap_tbl			IN rap_tbl_type,
    x_rap_tbl			OUT NOCOPY rap_tbl_type,
    p_rps_tbl			IN rps_tbl_type,
    x_rps_tbl			OUT NOCOPY rps_tbl_type,
    p_rtp_tbl			IN rtp_tbl_type,
    x_rtp_tbl			OUT NOCOPY rtp_tbl_type
 );

 PROCEDURE update_report(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec			IN repv_rec_type,
    x_repv_rec			OUT NOCOPY repv_rec_type,
    p_rpp_tbl			IN rpp_tbl_type,
    x_rpp_tbl			OUT NOCOPY rpp_tbl_type,
    p_rap_tbl			IN rap_tbl_type,
    x_rap_tbl			OUT NOCOPY rap_tbl_type,
    p_rps_tbl			IN rps_tbl_type,
    x_rps_tbl			OUT NOCOPY rps_tbl_type,
    p_rtp_tbl			IN rtp_tbl_type,
    x_rtp_tbl			OUT NOCOPY rtp_tbl_type
 );

 -- Function for Pre Billing Report Generation using
 -- XML Publisher
 FUNCTION pre_billing	RETURN BOOLEAN;

END Okl_Report_Pvt;

/
