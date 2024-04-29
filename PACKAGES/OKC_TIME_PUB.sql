--------------------------------------------------------
--  DDL for Package OKC_TIME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TIME_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPTVES.pls 120.0 2005/05/25 22:30:17 appldev noship $ */
 --------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_TIME_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 --------------------------------------------------------------------------
  --Global Exception
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPA_RELTV
 --------------------------------------------------------------------------

  PROCEDURE ADD_LANGUAGE;

  PROCEDURE DELETE_TIMEVALUES_N_TASKS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_chr_id            IN NUMBER  DEFAULT NULL,
    p_tve_id                IN NUMBER);

  SUBTYPE talv_rec_type is OKC_TIME_PVT.talv_rec_type;
  TYPE talv_tbl_type is table of OKC_TIME_PVT.talv_rec_type index by binary_integer;

  g_talv_rec talv_rec_type;
  g_talv_tbl talv_tbl_type;

  PROCEDURE CREATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	    IN talv_rec_type,
    x_talv_rec          OUT NOCOPY talv_rec_type) ;
  PROCEDURE CREATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_tbl	    IN talv_tbl_type,
    x_talv_tbl          OUT NOCOPY talv_tbl_type);

  PROCEDURE UPDATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	    IN talv_rec_type,
    x_talv_rec          OUT NOCOPY talv_rec_type) ;

  PROCEDURE UPDATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_tbl	    IN talv_tbl_type,
    x_talv_tbl          OUT NOCOPY talv_tbl_type) ;

  PROCEDURE DELETE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	    IN talv_rec_type) ;

  PROCEDURE DELETE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_tbl	    IN talv_tbl_type);

  PROCEDURE LOCK_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	    IN talv_rec_type) ;

  PROCEDURE LOCK_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_tbl	    IN talv_tbl_type);

  PROCEDURE VALID_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	    IN talv_rec_type) ;

  PROCEDURE VALID_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_tbl	    IN talv_tbl_type);

  SUBTYPE talv_evt_rec_type is OKC_TIME_PVT.talv_event_rec_type;
  TYPE talv_evt_tbl_type is table of OKC_TIME_PVT.talv_event_rec_type index by binary_integer;

  g_talv_evt_rec talv_evt_rec_type;
  g_talv_evt_tbl talv_evt_tbl_type;

  PROCEDURE CREATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_evt_rec_type,
    x_talv_evt_rec          OUT NOCOPY talv_evt_rec_type) ;
  PROCEDURE CREATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_tbl	    IN talv_evt_tbl_type,
    x_talv_evt_tbl          OUT NOCOPY talv_evt_tbl_type);

  PROCEDURE UPDATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_evt_rec_type,
    x_talv_evt_rec          OUT NOCOPY talv_evt_rec_type) ;

  PROCEDURE UPDATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_tbl	    IN talv_evt_tbl_type,
    x_talv_evt_tbl          OUT NOCOPY talv_evt_tbl_type) ;

  PROCEDURE DELETE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_evt_rec_type) ;

  PROCEDURE DELETE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_tbl	    IN talv_evt_tbl_type);

  PROCEDURE LOCK_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_evt_rec_type) ;

  PROCEDURE LOCK_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_tbl	    IN talv_evt_tbl_type);

  PROCEDURE VALID_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_evt_rec_type) ;

  PROCEDURE VALID_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_tbl	    IN talv_evt_tbl_type);


 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPA_VALUE
 --------------------------------------------------------------------------

  SUBTYPE tavv_rec_type is OKC_TIME_PVT.tavv_rec_type;
  TYPE tavv_tbl_type is table of OKC_TIME_PVT.tavv_rec_type index by binary_integer;

  g_tavv_rec tavv_rec_type;
  g_tavv_tbl tavv_tbl_type;

  PROCEDURE CREATE_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	    IN tavv_rec_type,
    x_tavv_rec          OUT NOCOPY tavv_rec_type) ;
  PROCEDURE CREATE_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_tbl	    IN tavv_tbl_type,
    x_tavv_tbl          OUT NOCOPY tavv_tbl_type);

  PROCEDURE UPDATE_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	    IN tavv_rec_type,
    x_tavv_rec          OUT NOCOPY tavv_rec_type) ;

  PROCEDURE UPDATE_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_tbl	    IN tavv_tbl_type,
    x_tavv_tbl          OUT NOCOPY tavv_tbl_type) ;

  PROCEDURE DELETE_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	    IN tavv_rec_type) ;

  PROCEDURE DELETE_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_tbl	    IN tavv_tbl_type);

  PROCEDURE LOCK_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	    IN tavv_rec_type) ;

  PROCEDURE LOCK_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_tbl	    IN tavv_tbl_type);

  PROCEDURE VALID_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	    IN tavv_rec_type) ;

  PROCEDURE VALID_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_tbl	    IN tavv_tbl_type);


 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPG_DELIMITED
 --------------------------------------------------------------------------

  SUBTYPE tgdv_ext_rec_type is OKC_TIME_PVT.tgdv_extended_rec_type;
  TYPE tgdv_ext_tbl_type is table of OKC_TIME_PVT.tgdv_extended_rec_type index by binary_integer;

  g_tgdv_ext_rec tgdv_ext_rec_type;
  g_tgdv_ext_tbl tgdv_ext_tbl_type;

  PROCEDURE CREATE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_ext_rec_type,
    x_tgdv_ext_rec          OUT NOCOPY tgdv_ext_rec_type) ;

  PROCEDURE CREATE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_tbl	    IN tgdv_ext_tbl_type,
    x_tgdv_ext_tbl          OUT NOCOPY tgdv_ext_tbl_type) ;

  PROCEDURE UPDATE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_ext_rec_type,
    x_tgdv_ext_rec          OUT NOCOPY tgdv_ext_rec_type) ;

  PROCEDURE UPDATE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_tbl	    IN tgdv_ext_tbl_type,
    x_tgdv_ext_tbl          OUT NOCOPY tgdv_ext_tbl_type) ;

  PROCEDURE DELETE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_ext_rec_type) ;

  PROCEDURE DELETE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_tbl	    IN tgdv_ext_tbl_type);

  PROCEDURE LOCK_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_ext_rec_type) ;

  PROCEDURE LOCK_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_tbl	    IN tgdv_ext_tbl_type);

  PROCEDURE VALID_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_ext_rec_type) ;

  PROCEDURE VALID_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_tbl	    IN tgdv_ext_tbl_type);


 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPG_NAMED
 --------------------------------------------------------------------------

  SUBTYPE tgnv_rec_type is OKC_TIME_PVT.tgnv_rec_type;
  TYPE tgnv_tbl_type is table of OKC_TIME_PVT.tgnv_rec_type index by binary_integer;

  g_tgnv_rec tgnv_rec_type;
  g_tgnv_tbl tgnv_tbl_type;

  PROCEDURE CREATE_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	    IN tgnv_rec_type,
    x_tgnv_rec          OUT NOCOPY tgnv_rec_type) ;
  PROCEDURE CREATE_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_tbl	    IN tgnv_tbl_type,
    x_tgnv_tbl          OUT NOCOPY tgnv_tbl_type);

  PROCEDURE UPDATE_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	    IN tgnv_rec_type,
    x_tgnv_rec          OUT NOCOPY tgnv_rec_type) ;

  PROCEDURE UPDATE_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_tbl	    IN tgnv_tbl_type,
    x_tgnv_tbl          OUT NOCOPY tgnv_tbl_type) ;

  PROCEDURE DELETE_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	    IN tgnv_rec_type) ;

  PROCEDURE DELETE_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_tbl	    IN tgnv_tbl_type);

  PROCEDURE LOCK_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	    IN tgnv_rec_type) ;

  PROCEDURE LOCK_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_tbl	    IN tgnv_tbl_type);

  PROCEDURE VALID_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	    IN tgnv_rec_type) ;

  PROCEDURE VALID_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_tbl	    IN tgnv_tbl_type);


 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_IA_STARTEND
 --------------------------------------------------------------------------

  SUBTYPE isev_rec_type is OKC_TIME_PVT.isev_rec_type;
  TYPE isev_tbl_type is table of OKC_TIME_PVT.isev_rec_type index by binary_integer;
  SUBTYPE isev_ext_rec_type is OKC_TIME_PVT.isev_extended_rec_type;
  TYPE isev_ext_tbl_type is table of OKC_TIME_PVT.isev_extended_rec_type index by binary_integer;

  SUBTYPE isev_rel_rec_type is OKC_TIME_PVT.isev_reltv_rec_type;
  TYPE isev_rel_tbl_type is table of OKC_TIME_PVT.isev_reltv_rec_type index by binary_integer;
  g_isev_rec isev_rec_type;
  g_isev_tbl isev_tbl_type;
  g_isev_ext_rec isev_ext_rec_type;
  g_isev_ext_tbl isev_ext_tbl_type;
  g_isev_rel_rec isev_rel_rec_type;
  g_isev_rel_tbl isev_rel_tbl_type;

  PROCEDURE CREATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_ext_rec_type,
    x_isev_ext_rec          OUT NOCOPY isev_ext_rec_type) ;

  PROCEDURE CREATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_tbl	    IN isev_ext_tbl_type,
    x_isev_ext_tbl          OUT NOCOPY isev_ext_tbl_type) ;

  PROCEDURE UPDATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_ext_rec_type,
    x_isev_ext_rec          OUT NOCOPY isev_ext_rec_type) ;

  PROCEDURE UPDATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_tbl	    IN isev_ext_tbl_type,
    x_isev_ext_tbl          OUT NOCOPY isev_ext_tbl_type) ;

  PROCEDURE DELETE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_ext_rec_type) ;

  PROCEDURE DELETE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_tbl	    IN isev_ext_tbl_type);

  PROCEDURE LOCK_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_ext_rec_type) ;

  PROCEDURE LOCK_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_tbl	    IN isev_ext_tbl_type) ;

  PROCEDURE VALID_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_ext_rec_type) ;

  PROCEDURE VALID_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_tbl	    IN isev_ext_tbl_type);

  PROCEDURE CREATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_rel_rec_type,
    x_isev_rel_rec          OUT NOCOPY isev_rel_rec_type) ;

  PROCEDURE CREATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_tbl	    IN isev_rel_tbl_type,
    x_isev_rel_tbl          OUT NOCOPY isev_rel_tbl_type) ;

  PROCEDURE UPDATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_rel_rec_type,
    x_isev_rel_rec          OUT NOCOPY isev_rel_rec_type) ;

  PROCEDURE UPDATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_tbl	    IN isev_rel_tbl_type,
    x_isev_rel_tbl          OUT NOCOPY isev_rel_tbl_type) ;

  PROCEDURE DELETE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_rel_rec_type) ;

  PROCEDURE DELETE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_tbl	    IN isev_rel_tbl_type);

  PROCEDURE LOCK_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_rel_rec_type) ;

  PROCEDURE LOCK_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_tbl	    IN isev_rel_tbl_type) ;

  PROCEDURE VALID_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_rel_rec_type) ;

  PROCEDURE VALID_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_tbl	    IN isev_rel_tbl_type);

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_IG_STARTEND
 --------------------------------------------------------------------------

  SUBTYPE igsv_ext_rec_type is OKC_TIME_PVT.igsv_extended_rec_type;
  TYPE igsv_ext_tbl_type is table of OKC_TIME_PVT.igsv_extended_rec_type index by binary_integer;

  g_igsv_ext_rec igsv_ext_rec_type;
  g_igsv_ext_tbl igsv_ext_tbl_type;

  PROCEDURE CREATE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_ext_rec_type,
    x_igsv_ext_rec          OUT NOCOPY igsv_ext_rec_type) ;

  PROCEDURE CREATE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_tbl	    IN igsv_ext_tbl_type,
    x_igsv_ext_tbl          OUT NOCOPY igsv_ext_tbl_type) ;

  PROCEDURE UPDATE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_ext_rec_type,
    x_igsv_ext_rec          OUT NOCOPY igsv_ext_rec_type) ;

  PROCEDURE UPDATE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_tbl	    IN igsv_ext_tbl_type,
    x_igsv_ext_tbl          OUT NOCOPY igsv_ext_tbl_type) ;

  PROCEDURE DELETE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_ext_rec_type) ;

  PROCEDURE DELETE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_tbl	    IN igsv_ext_tbl_type);

  PROCEDURE LOCK_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_ext_rec_type) ;

  PROCEDURE LOCK_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_tbl	    IN igsv_ext_tbl_type);

  PROCEDURE VALID_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_ext_rec_type) ;

  PROCEDURE VALID_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_tbl	    IN igsv_ext_tbl_type);


 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_CYCLE
 --------------------------------------------------------------------------

  SUBTYPE cylv_ext_rec_type is OKC_TIME_PVT.cylv_extended_rec_type;
  TYPE cylv_ext_tbl_type is table of OKC_TIME_PVT.cylv_extended_rec_type index by binary_integer;

  g_cylv_ext_rec cylv_ext_rec_type;
  g_cylv_ext_tbl cylv_ext_tbl_type;

  PROCEDURE CREATE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec		    IN cylv_ext_rec_type,
    x_cylv_ext_rec              OUT NOCOPY cylv_ext_rec_type) ;

  PROCEDURE CREATE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_tbl		    IN cylv_ext_tbl_type,
    x_cylv_ext_tbl              OUT NOCOPY cylv_ext_tbl_type) ;

  PROCEDURE UPDATE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec		    IN cylv_ext_rec_type,
    x_cylv_ext_rec              OUT NOCOPY cylv_ext_rec_type) ;

  PROCEDURE UPDATE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_tbl		    IN cylv_ext_tbl_type,
    x_cylv_ext_tbl              OUT NOCOPY cylv_ext_tbl_type) ;

  PROCEDURE DELETE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec		    IN cylv_ext_rec_type) ;

  PROCEDURE DELETE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_tbl		    IN cylv_ext_tbl_type);

  PROCEDURE LOCK_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec		    IN cylv_ext_rec_type) ;

  PROCEDURE LOCK_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_tbl		    IN cylv_ext_tbl_type);

  PROCEDURE VALID_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec		    IN cylv_ext_rec_type) ;

  PROCEDURE VALID_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_tbl		    IN cylv_ext_tbl_type);


 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_SPAN
 --------------------------------------------------------------------------

  SUBTYPE spnv_rec_type is OKC_TIME_PVT.spnv_rec_type;
  TYPE spnv_tbl_type is table of OKC_TIME_PVT.spnv_rec_type index by binary_integer;

  g_spnv_rec spnv_rec_type;
  g_spnv_tbl spnv_tbl_type;

  PROCEDURE CREATE_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec		    IN spnv_rec_type,
    x_spnv_rec              OUT NOCOPY spnv_rec_type) ;

  PROCEDURE CREATE_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_tbl		    IN spnv_tbl_type,
    x_spnv_tbl              OUT NOCOPY spnv_tbl_type) ;

  PROCEDURE UPDATE_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec		    IN spnv_rec_type,
    x_spnv_rec              OUT NOCOPY spnv_rec_type) ;

  PROCEDURE UPDATE_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_tbl		    IN spnv_tbl_type,
    x_spnv_tbl              OUT NOCOPY spnv_tbl_type) ;

  PROCEDURE DELETE_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec		    IN spnv_rec_type) ;

  PROCEDURE DELETE_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_tbl		    IN spnv_tbl_type);

  PROCEDURE LOCK_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec		    IN spnv_rec_type) ;

  PROCEDURE LOCK_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_tbl		    IN spnv_tbl_type);

  PROCEDURE VALID_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec		    IN spnv_rec_type) ;

  PROCEDURE VALID_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_tbl		    IN spnv_tbl_type);

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_CODE_UNITS
 --------------------------------------------------------------------------

  SUBTYPE tcuv_rec_type is OKC_TIME_PVT.tcuv_rec_type;
  TYPE tcuv_tbl_type is table of OKC_TIME_PVT.tcuv_rec_type index by binary_integer;

  g_tcuv_rec tcuv_rec_type;
  g_tcuv_tbl tcuv_tbl_type;

  PROCEDURE CREATE_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec		    IN tcuv_rec_type,
    x_tcuv_rec              OUT NOCOPY tcuv_rec_type) ;

  PROCEDURE CREATE_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_tbl		    IN tcuv_tbl_type,
    x_tcuv_tbl              OUT NOCOPY tcuv_tbl_type) ;

  PROCEDURE UPDATE_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec		    IN tcuv_rec_type,
    x_tcuv_rec              OUT NOCOPY tcuv_rec_type) ;

  PROCEDURE UPDATE_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_tbl		    IN tcuv_tbl_type,
    x_tcuv_tbl              OUT NOCOPY tcuv_tbl_type) ;

  PROCEDURE DELETE_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec		    IN tcuv_rec_type) ;

  PROCEDURE DELETE_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_tbl		    IN tcuv_tbl_type);

  PROCEDURE LOCK_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec		    IN tcuv_rec_type) ;

  PROCEDURE LOCK_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_tbl		    IN tcuv_tbl_type);

  PROCEDURE VALID_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec		    IN tcuv_rec_type) ;

  PROCEDURE VALID_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_tbl		    IN tcuv_tbl_type);
 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_RESOLVED_TIMEVALUES
 --------------------------------------------------------------------------

  SUBTYPE rtvv_rec_type is OKC_TIME_PVT.rtvv_rec_type;
  TYPE rtvv_tbl_type is table of OKC_TIME_PVT.rtvv_rec_type index by binary_integer;

  g_rtvv_rec rtvv_rec_type;
  g_rtvv_tbl rtvv_tbl_type;

  PROCEDURE CREATE_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec		    IN rtvv_rec_type,
    x_rtvv_rec              OUT NOCOPY rtvv_rec_type) ;

  PROCEDURE CREATE_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_tbl		    IN rtvv_tbl_type,
    x_rtvv_tbl              OUT NOCOPY rtvv_tbl_type) ;

  PROCEDURE UPDATE_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec		    IN rtvv_rec_type,
    x_rtvv_rec              OUT NOCOPY rtvv_rec_type) ;

  PROCEDURE UPDATE_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_tbl		    IN rtvv_tbl_type,
    x_rtvv_tbl              OUT NOCOPY rtvv_tbl_type) ;

  PROCEDURE DELETE_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec		    IN rtvv_rec_type) ;

  PROCEDURE DELETE_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_tbl		    IN rtvv_tbl_type);

  PROCEDURE LOCK_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec		    IN rtvv_rec_type) ;

  PROCEDURE LOCK_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_tbl		    IN rtvv_tbl_type);

  PROCEDURE VALID_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec		    IN rtvv_rec_type) ;

  PROCEDURE VALID_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_tbl		    IN rtvv_tbl_type);
END OKC_TIME_PUB;

 

/
