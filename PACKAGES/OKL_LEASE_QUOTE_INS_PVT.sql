--------------------------------------------------------
--  DDL for Package OKL_LEASE_QUOTE_INS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_QUOTE_INS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRQUIS.pls 120.0.12010000.2 2008/11/18 10:22:46 kkorrapo ship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_LEASE_QUOTE_INS_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(30)  := OKL_API.G_APP_NAME;
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_USER_ID              CONSTANT NUMBER        := FND_GLOBAL.USER_ID;
  G_LOGIN_ID             CONSTANT NUMBER        := FND_GLOBAL.LOGIN_ID;
  G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
  G_DB_ERROR             CONSTANT VARCHAR2(30)  := 'OKL_DB_ERROR';
  G_PKG_NAME_TOKEN       CONSTANT VARCHAR2(30)  := 'PKG_NAME';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(30)  := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLERRM';

  TYPE ins_est_rec_type IS RECORD (
    id                    NUMBER
   ,ovn                   NUMBER
   ,quote_type_code       VARCHAR2(30)    -- mandatory  Allowable values: 'LQ' 'LA'
   ,lease_quote_id        NUMBER
   ,policy_term           BINARY_INTEGER
   ,stream_type_id        NUMBER
   ,payment_frequency     VARCHAR2(1)
   ,periodic_amount       NUMBER
   ,cashflow_object_id    NUMBER          -- mandatory for update
   ,cashflow_header_id    NUMBER          -- mandatory for update
   ,cashflow_header_ovn   NUMBER          -- mandatory for update
   ,cashflow_level_id     NUMBER          -- mandatory for update
   ,cashflow_level_ovn    NUMBER          -- mandatory for update
   ,description           VARCHAR2(240)
   --Bug 6935907-Added by kkorrapo
   ,attribute_category     VARCHAR2(90)
   ,attribute1             VARCHAR2(450)
   ,attribute2             VARCHAR2(450)
   ,attribute3             VARCHAR2(450)
   ,attribute4             VARCHAR2(450)
   ,attribute5             VARCHAR2(450)
   ,attribute6             VARCHAR2(450)
   ,attribute7             VARCHAR2(450)
   ,attribute8             VARCHAR2(450)
   ,attribute9             VARCHAR2(450)
   ,attribute10            VARCHAR2(450)
   ,attribute11            VARCHAR2(450)
   ,attribute12            VARCHAR2(450)
   ,attribute13            VARCHAR2(450)
   ,attribute14            VARCHAR2(450)
   ,attribute15            VARCHAR2(450)
   --Bug 6935907-Addition end
   );

  ----------------
  -- PROGRAM UNITS
  ----------------
  PROCEDURE create_insurance_estimate (
    p_api_version             IN  NUMBER
   ,p_init_msg_list           IN  VARCHAR2
   ,p_transaction_control     IN  VARCHAR2
   ,p_insurance_estimate_rec  IN  ins_est_rec_type
   ,x_insurance_estimate_id   OUT NOCOPY NUMBER
   ,x_return_status           OUT NOCOPY VARCHAR2
   ,x_msg_count               OUT NOCOPY NUMBER
   ,x_msg_data                OUT NOCOPY VARCHAR2
   );


  PROCEDURE update_insurance_estimate (
    p_api_version             IN  NUMBER
   ,p_init_msg_list           IN  VARCHAR2
   ,p_transaction_control     IN  VARCHAR2
   ,p_insurance_estimate_rec  IN  ins_est_rec_type
   ,x_return_status           OUT NOCOPY VARCHAR2
   ,x_msg_count               OUT NOCOPY NUMBER
   ,x_msg_data                OUT NOCOPY VARCHAR2
   );


  PROCEDURE delete_insurance_estimate (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_insurance_estimate_id   IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    );


END OKL_LEASE_QUOTE_INS_PVT;

/
