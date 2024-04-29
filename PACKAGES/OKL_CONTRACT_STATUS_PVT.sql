--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_STATUS_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRSTKS.pls 115.3 2002/11/30 09:02:01 spillaip noship $ */

-- Global variables for user hooks
  G_PKG_NAME   CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_STATUS_PVT';
  G_APP_NAME   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

-- Contract actions
  G_K_NEW  CONSTANT VARCHAR2(60) := OKL_CONTRACT_STATUS_PUB.G_K_NEW;
  G_K_EDIT CONSTANT VARCHAR2(60) := OKL_CONTRACT_STATUS_PUB.G_K_EDIT;
  G_K_QACHECK CONSTANT VARCHAR2(60) := OKL_CONTRACT_STATUS_PUB.G_K_QACHECK;
  G_K_STRMGEN CONSTANT VARCHAR2(60) := OKL_CONTRACT_STATUS_PUB.G_K_STRMGEN;
  G_K_JOURNAL CONSTANT VARCHAR2(60) := OKL_CONTRACT_STATUS_PUB.G_K_JOURNAL;
  G_K_SUBMIT4APPRVL CONSTANT VARCHAR2(60) := OKL_CONTRACT_STATUS_PUB.G_K_SUBMIT4APPRVL;
  G_K_APPROVAL CONSTANT VARCHAR2(60) := OKL_CONTRACT_STATUS_PUB.G_K_APPROVAL;
  G_K_ACTIVATE CONSTANT VARCHAR2(60) := OKL_CONTRACT_STATUS_PUB.G_K_ACTIVATE;

  G_K_NOT_ALLOWED CONSTANT VARCHAR2(100) := 'G_K_NOT_ALLOWED';

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
            p_khr_status      IN VARCHAR2,
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

End OKL_CONTRACT_STATUS_PVT;

 

/
