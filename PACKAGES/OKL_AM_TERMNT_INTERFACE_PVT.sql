--------------------------------------------------------
--  DDL for Package OKL_AM_TERMNT_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_TERMNT_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTIFS.pls 115.6 2003/10/21 14:18:59 rabhupat noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP				CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'SQLcode';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AM_TERMNT_INTERFACE_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_INSURANCE_ERROR EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
   -- OKL_TERMNT_INTERFACE Record Spec

 TYPE tif_rec_type IS RECORD (
     row_id                         ROWID
    ,transaction_number             OKL_TERMNT_INTERFACE.TRANSACTION_NUMBER%TYPE
    ,batch_number                   OKL_TERMNT_INTERFACE.BATCH_NUMBER%TYPE
    ,contract_id                    OKL_TERMNT_INTERFACE.CONTRACT_ID%TYPE
    ,contract_number                OKL_TERMNT_INTERFACE.CONTRACT_NUMBER%TYPE
    ,asset_id                       OKL_TERMNT_INTERFACE.ASSET_ID%TYPE
    ,asset_number                   OKL_TERMNT_INTERFACE.ASSET_NUMBER%TYPE
    ,asset_description              OKL_TERMNT_INTERFACE.ASSET_DESCRIPTION%TYPE
    ,serial_number                  OKL_TERMNT_INTERFACE.SERIAL_NUMBER%TYPE
    ,orig_system                    OKL_TERMNT_INTERFACE.ORIG_SYSTEM%TYPE
    ,orig_system_reference          OKL_TERMNT_INTERFACE.ORIG_SYSTEM_REFERENCE%TYPE
    ,units_to_terminate             OKL_TERMNT_INTERFACE.UNITS_TO_TERMINATE%TYPE
    ,comments                       OKL_TERMNT_INTERFACE.COMMENTS%TYPE
    ,date_processed                 OKL_TERMNT_INTERFACE.DATE_PROCESSED%TYPE
    ,date_effective_from            OKL_TERMNT_INTERFACE.DATE_EFFECTIVE_FROM%TYPE
    ,termination_notification_email OKL_TERMNT_INTERFACE.TERMINATION_NOTIFICATION_EMAIL%TYPE
    ,termination_notification_yn    OKL_TERMNT_INTERFACE.TERMINATION_NOTIFICATION_YN%TYPE
    ,auto_accept_yn                 OKL_TERMNT_INTERFACE.AUTO_ACCEPT_YN%TYPE
    ,quote_type_code                OKL_TERMNT_INTERFACE.QUOTE_TYPE_CODE%TYPE
    ,quote_reason_code              OKL_TERMNT_INTERFACE.QUOTE_REASON_CODE%TYPE
    ,qte_id                         OKL_TERMNT_INTERFACE.QTE_ID%TYPE
    ,status                         OKL_TERMNT_INTERFACE.STATUS%TYPE
    ,org_id                         OKL_TERMNT_INTERFACE.ORG_ID%TYPE
    ,request_id                     OKL_TERMNT_INTERFACE.REQUEST_ID%TYPE
    ,program_application_id         OKL_TERMNT_INTERFACE.PROGRAM_APPLICATION_ID%TYPE
    ,program_id                     OKL_TERMNT_INTERFACE.PROGRAM_ID%TYPE
    ,program_update_date            OKL_TERMNT_INTERFACE.PROGRAM_UPDATE_DATE%TYPE
    ,attribute_category             OKL_TERMNT_INTERFACE.ATTRIBUTE_CATEGORY%TYPE
    ,attribute1                     OKL_TERMNT_INTERFACE.ATTRIBUTE1%TYPE
    ,attribute2                     OKL_TERMNT_INTERFACE.ATTRIBUTE2%TYPE
    ,attribute3                     OKL_TERMNT_INTERFACE.ATTRIBUTE3%TYPE
    ,attribute4                     OKL_TERMNT_INTERFACE.ATTRIBUTE4%TYPE
    ,attribute5                     OKL_TERMNT_INTERFACE.ATTRIBUTE5%TYPE
    ,attribute6                     OKL_TERMNT_INTERFACE.ATTRIBUTE6%TYPE
    ,attribute7                     OKL_TERMNT_INTERFACE.ATTRIBUTE7%TYPE
    ,attribute8                     OKL_TERMNT_INTERFACE.ATTRIBUTE8%TYPE
    ,attribute9                     OKL_TERMNT_INTERFACE.ATTRIBUTE9%TYPE
    ,attribute10                    OKL_TERMNT_INTERFACE.ATTRIBUTE10%TYPE
    ,attribute11                    OKL_TERMNT_INTERFACE.ATTRIBUTE11%TYPE
    ,attribute12                    OKL_TERMNT_INTERFACE.ATTRIBUTE12%TYPE
    ,attribute13                    OKL_TERMNT_INTERFACE.ATTRIBUTE13%TYPE
    ,attribute14                    OKL_TERMNT_INTERFACE.ATTRIBUTE14%TYPE
    ,attribute15                    OKL_TERMNT_INTERFACE.ATTRIBUTE15%TYPE
    ,created_by                     OKL_TERMNT_INTERFACE.CREATED_BY%TYPE
    ,creation_date                  OKL_TERMNT_INTERFACE.CREATION_DATE%TYPE
    ,last_updated_by                OKL_TERMNT_INTERFACE.LAST_UPDATED_BY%TYPE
    ,last_update_date               OKL_TERMNT_INTERFACE.LAST_UPDATE_DATE%TYPE
    ,last_update_login              OKL_TERMNT_INTERFACE.LAST_UPDATE_LOGIN%TYPE
    ,group_number                   OKL_TERMNT_INTERFACE.GROUP_NUMBER%TYPE);

     g_miss_tif_rec                          tif_rec_type;
  -- OKL_TERMNT_INTERFACE table Spec
  TYPE tif_tbl_type IS TABLE OF tif_rec_type
        INDEX BY BINARY_INTEGER;

  -- OKL_TERMNT_INTF_PTY record Spec
  TYPE tip_rec_type IS RECORD(
     row_id                         ROWID
    ,contract_party_id              OKL_TERMNT_INTF_PTY.CONTRACT_PARTY_ID%TYPE
    ,contract_party_role            OKL_TERMNT_INTF_PTY.CONTRACT_PARTY_ROLE%TYPE
    ,contract_party_name            OKL_TERMNT_INTF_PTY.CONTRACT_PARTY_NAME%TYPE
    ,contract_party_number          OKL_TERMNT_INTF_PTY.CONTRACT_PARTY_NUMBER%TYPE
    ,party_object_code              OKL_TERMNT_INTF_PTY.PARTY_OBJECT_CODE%TYPE
    ,party_object_id1               OKL_TERMNT_INTF_PTY.PARTY_OBJECT_ID1%TYPE
    ,party_object_id2               OKL_TERMNT_INTF_PTY.PARTY_OBJECT_ID2%TYPE
    ,email_address                  OKL_TERMNT_INTF_PTY.EMAIL_ADDRESS%TYPE
    ,allocation_percentage          OKL_TERMNT_INTF_PTY.ALLOCATION_PERCENTAGE%TYPE
    ,delay_days                     OKL_TERMNT_INTF_PTY.DELAY_DAYS%TYPE
    ,qpy_id                         OKL_TERMNT_INTF_PTY.QPY_ID%TYPE
    ,transaction_number             OKL_TERMNT_INTF_PTY.TRANSACTION_NUMBER%TYPE
    ,status                         OKL_TERMNT_INTF_PTY.STATUS%TYPE
    ,request_id                     OKL_TERMNT_INTF_PTY.REQUEST_ID%TYPE
    ,program_application_id         OKL_TERMNT_INTF_PTY.PROGRAM_APPLICATION_ID%TYPE
    ,program_id                     OKL_TERMNT_INTF_PTY.PROGRAM_ID%TYPE
    ,program_update_date            OKL_TERMNT_INTF_PTY.PROGRAM_UPDATE_DATE%TYPE
    ,attribute_category             OKL_TERMNT_INTF_PTY.ATTRIBUTE_CATEGORY%TYPE
    ,attribute1                     OKL_TERMNT_INTF_PTY.ATTRIBUTE1%TYPE
    ,attribute2                     OKL_TERMNT_INTF_PTY.ATTRIBUTE2%TYPE
    ,attribute3                     OKL_TERMNT_INTF_PTY.ATTRIBUTE3%TYPE
    ,attribute4                     OKL_TERMNT_INTF_PTY.ATTRIBUTE4%TYPE
    ,attribute5                     OKL_TERMNT_INTF_PTY.ATTRIBUTE5%TYPE
    ,attribute6                     OKL_TERMNT_INTF_PTY.ATTRIBUTE6%TYPE
    ,attribute7                     OKL_TERMNT_INTF_PTY.ATTRIBUTE7%TYPE
    ,attribute8                     OKL_TERMNT_INTF_PTY.ATTRIBUTE8%TYPE
    ,attribute9                     OKL_TERMNT_INTF_PTY.ATTRIBUTE9%TYPE
    ,attribute10                    OKL_TERMNT_INTF_PTY.ATTRIBUTE10%TYPE
    ,attribute11                    OKL_TERMNT_INTF_PTY.ATTRIBUTE11%TYPE
    ,attribute12                    OKL_TERMNT_INTF_PTY.ATTRIBUTE12%TYPE
    ,attribute13                    OKL_TERMNT_INTF_PTY.ATTRIBUTE13%TYPE
    ,attribute14                    OKL_TERMNT_INTF_PTY.ATTRIBUTE14%TYPE
    ,attribute15                    OKL_TERMNT_INTF_PTY.ATTRIBUTE15%TYPE
    ,created_by                     OKL_TERMNT_INTF_PTY.CREATED_BY%TYPE
    ,creation_date                  OKL_TERMNT_INTF_PTY.CREATION_DATE%TYPE
    ,last_updated_by                OKL_TERMNT_INTF_PTY.LAST_UPDATED_BY%TYPE
    ,last_update_date               OKL_TERMNT_INTF_PTY.LAST_UPDATE_DATE%TYPE
    ,last_update_login              OKL_TERMNT_INTF_PTY.LAST_UPDATE_LOGIN%TYPE
    ,quote_role_code                OKL_TERMNT_INTF_PTY.QUOTE_ROLE_CODE%TYPE);

     g_miss_tip_rec                          tip_rec_type;
  -- OKL_TERMNT_INTF_PTY table Spec
  TYPE tip_tbl_type IS TABLE OF tip_rec_type
        INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

PROCEDURE termination_interface(p_api_version    IN NUMBER,
                                p_init_msg_list  IN VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                err_buf          OUT NOCOPY VARCHAR2,
                                ret_code         OUT NOCOPY NUMBER);

END OKL_AM_TERMNT_INTERFACE_PVT;

 

/
