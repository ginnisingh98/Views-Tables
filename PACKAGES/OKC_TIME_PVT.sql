--------------------------------------------------------
--  DDL for Package OKC_TIME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TIME_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCCTVES.pls 120.0 2005/05/25 18:54:57 appldev noship $ */
 --------------------------------------------------------------------------
 -- Global Variables
 G_INVALID_VALUE	CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
 G_COL_NAME_TOKEN	CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_TIME_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 G_DATE_ERROR           CONSTANT varchar2(200) := 'Start Date > End Date';
 --------------------------------------------------------------------------
  --Global Exception
  G_EXCEPTION_HALT_PROCEEDING	EXCEPTION;

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

  SUBTYPE talv_rec_type is okc_tal_pvt.talv_rec_type;

  PROCEDURE CREATE_TPA_RELTV(
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
    p_talv_rec	    IN talv_rec_type,
    x_talv_rec          OUT NOCOPY talv_rec_type) ;

  PROCEDURE DELETE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	    IN talv_rec_type);

  PROCEDURE LOCK_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	    IN talv_rec_type);

  PROCEDURE VALID_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	    IN talv_rec_type);

  TYPE talv_event_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
--Bug 3122962
    sfwt_flag                      OKC_TIME_TPA_RELATIVE_V.SFWT_FLAG%TYPE := 'N',
    spn_id                         NUMBER := OKC_API.G_MISS_NUM,
    cnh_id                         NUMBER := OKC_API.G_MISS_NUM,
    tve_id_limited                 NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                 NUMBER := OKC_API.G_MISS_NUM,
    tve_id_offset                  NUMBER := OKC_API.G_MISS_NUM,
    uom_code        OKC_TIME_TPA_RELATIVE_V.uom_code%TYPE  := OKC_API.G_MISS_CHAR,
    description                    OKC_TIME_TPA_RELATIVE_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_TIME_TPA_RELATIVE_V.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_TIME_TPA_RELATIVE_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    duration                       NUMBER := OKC_API.G_MISS_NUM,
    operator                       OKC_TIME_TPA_RELATIVE_V.OPERATOR%TYPE := OKC_API.G_MISS_CHAR,
    before_after                   OKC_TIME_TPA_RELATIVE_V.BEFORE_AFTER%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_TIME_TPA_RELATIVE_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_TIME_TPA_RELATIVE_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_TIME_TPA_RELATIVE_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    tze_id                         NUMBER := OKC_API.G_MISS_NUM);

  PROCEDURE CREATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_event_rec_type,
    x_talv_evt_rec          OUT NOCOPY talv_event_rec_type) ;
  PROCEDURE UPDATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_event_rec_type,
    x_talv_evt_rec          OUT NOCOPY talv_event_rec_type) ;

  PROCEDURE DELETE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_event_rec_type);

  PROCEDURE LOCK_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_event_rec_type);

  PROCEDURE VALID_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_event_rec_type);

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPA_VALUE
 --------------------------------------------------------------------------

  SUBTYPE tavv_rec_type is okc_tav_pvt.tavv_rec_type;

  PROCEDURE CREATE_TPA_VALUE(
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
    p_tavv_rec	    IN tavv_rec_type,
    x_tavv_rec          OUT NOCOPY tavv_rec_type) ;

  PROCEDURE DELETE_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	    IN tavv_rec_type);

  PROCEDURE LOCK_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	    IN tavv_rec_type);

  PROCEDURE VALID_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	    IN tavv_rec_type);


 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPG_DELIMITED
 --------------------------------------------------------------------------

  SUBTYPE tgdv_rec_type is okc_tgd_pvt.tgdv_rec_type;

  TYPE tgdv_extended_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
--Bug 3122962
    sfwt_flag                      OKC_TIME_TPG_DELIMITED_V.SFWT_FLAG%TYPE := 'N',
    tve_id_limited                 NUMBER := OKC_API.G_MISS_NUM,
    limited_start_date             DATE := OKC_API.G_MISS_DATE,
    limited_end_date               DATE := OKC_API.G_MISS_DATE,
    dnz_chr_id                 NUMBER := OKC_API.G_MISS_NUM,
    description                    OKC_TIME_TPG_DELIMITED_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_TIME_TPG_DELIMITED_V.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_TIME_TPG_DELIMITED_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    month                          NUMBER := OKC_API.G_MISS_NUM,
    day                            NUMBER := OKC_API.G_MISS_NUM,
    day_of_week                    OKC_TIME_TPG_DELIMITED_V.DAY_OF_WEEK%TYPE := OKC_API.G_MISS_CHAR,
    hour                           NUMBER := OKC_API.G_MISS_NUM,
    minute                         NUMBER := OKC_API.G_MISS_NUM,
    second                         NUMBER := OKC_API.G_MISS_NUM,
    nth                         NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_TIME_TPG_DELIMITED_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_TIME_TPG_DELIMITED_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_TIME_TPG_DELIMITED_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    tze_id                         NUMBER := OKC_API.G_MISS_NUM);

  PROCEDURE CREATE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_extended_rec_type,
    x_tgdv_ext_rec          OUT NOCOPY tgdv_extended_rec_type) ;

  PROCEDURE UPDATE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_extended_rec_type,
    x_tgdv_ext_rec          OUT NOCOPY tgdv_extended_rec_type) ;

  PROCEDURE DELETE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_extended_rec_type) ;

  PROCEDURE LOCK_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_extended_rec_type) ;

  PROCEDURE VALID_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_extended_rec_type) ;


 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPG_NAMED
 --------------------------------------------------------------------------

  SUBTYPE tgnv_rec_type is okc_tgn_pvt.tgnv_rec_type;

  PROCEDURE CREATE_TPG_NAMED(
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
    p_tgnv_rec	    IN tgnv_rec_type,
    x_tgnv_rec          OUT NOCOPY tgnv_rec_type) ;

  PROCEDURE DELETE_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	    IN tgnv_rec_type);

  PROCEDURE LOCK_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	    IN tgnv_rec_type);

  PROCEDURE VALID_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	    IN tgnv_rec_type);


 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_IA_STARTEND
 --------------------------------------------------------------------------

  SUBTYPE isev_rec_type is okc_ise_pvt.isev_rec_type;

  TYPE isev_extended_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
--Bug 3122962
    sfwt_flag                      OKC_TIME_IA_STARTEND_V.SFWT_FLAG%TYPE := 'N',
    spn_id                         NUMBER := OKC_API.G_MISS_NUM,
    tve_id_limited                 NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                 NUMBER := OKC_API.G_MISS_NUM,
    tve_id_started                 NUMBER := OKC_API.G_MISS_NUM,
    tve_id_ended                   NUMBER := OKC_API.G_MISS_NUM,
    duration                       NUMBER := OKC_API.G_MISS_NUM,
    uom_code                OKC_TIME_IA_STARTEND_V.uom_code%TYPE := OKC_API.G_MISS_CHAR,
    before_after                   OKC_TIME_IA_STARTEND_V.BEFORE_AFTER%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_TIME_IA_STARTEND_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_TIME_IA_STARTEND_V.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_TIME_IA_STARTEND_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    operator                       OKC_TIME_IA_STARTEND_V.OPERATOR%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_TIME_IA_STARTEND_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_TIME_IA_STARTEND_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_TIME_IA_STARTEND_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_TIME_IA_STARTEND_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_TIME_IA_STARTEND_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_TIME_IA_STARTEND_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_TIME_IA_STARTEND_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_TIME_IA_STARTEND_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_TIME_IA_STARTEND_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    start_date                     DATE := OKC_API.G_MISS_DATE,
    end_date                       DATE := OKC_API.G_MISS_DATE,
    tze_id                         NUMBER := OKC_API.G_MISS_NUM);

  TYPE isev_reltv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
--Bug 3122962
    sfwt_flag                      OKC_TIME_IA_STARTEND_V.SFWT_FLAG%TYPE := 'N',
    spn_id                         NUMBER := OKC_API.G_MISS_NUM,
    tve_id_limited                 NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                 NUMBER := OKC_API.G_MISS_NUM,
    tve_id_started                 NUMBER := OKC_API.G_MISS_NUM,
    tve_id_ended                   NUMBER := OKC_API.G_MISS_NUM,
    duration                       NUMBER := OKC_API.G_MISS_NUM,
    uom_code                OKC_TIME_IA_STARTEND_V.uom_code%TYPE := OKC_API.G_MISS_CHAR,
    before_after                   OKC_TIME_IA_STARTEND_V.BEFORE_AFTER%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_TIME_IA_STARTEND_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_TIME_IA_STARTEND_V.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_TIME_IA_STARTEND_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    operator                       OKC_TIME_IA_STARTEND_V.OPERATOR%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_TIME_IA_STARTEND_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_TIME_IA_STARTEND_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_TIME_IA_STARTEND_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_TIME_IA_STARTEND_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_TIME_IA_STARTEND_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_TIME_IA_STARTEND_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_TIME_IA_STARTEND_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_TIME_IA_STARTEND_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_TIME_IA_STARTEND_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_TIME_IA_STARTEND_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    start_tve_id_offset            NUMBER := OKC_API.G_MISS_NUM,
    start_parent_date              DATE := OKC_API.G_MISS_DATE,
    start_uom_code      OKC_TIME_TPA_RELATIVE_V.uom_code%TYPE := OKC_API.G_MISS_CHAR,
    start_duration                 NUMBER := OKC_API.G_MISS_NUM,
    start_operator                 OKC_TIME_TPA_RELATIVE_V.OPERATOR%TYPE := OKC_API.G_MISS_CHAR,
    end_date                       DATE := OKC_API.G_MISS_DATE,
    tze_id                         NUMBER := OKC_API.G_MISS_NUM);

  PROCEDURE CREATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_extended_rec_type,
    x_isev_ext_rec          OUT NOCOPY isev_extended_rec_type) ;
  PROCEDURE UPDATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_extended_rec_type,
    x_isev_ext_rec          OUT NOCOPY isev_extended_rec_type) ;
  PROCEDURE DELETE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_extended_rec_type);

  PROCEDURE LOCK_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_extended_rec_type);

  PROCEDURE VALID_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_extended_rec_type) ;

  PROCEDURE CREATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_reltv_rec_type,
    x_isev_rel_rec          OUT NOCOPY isev_reltv_rec_type) ;
  PROCEDURE UPDATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_reltv_rec_type,
    x_isev_rel_rec          OUT NOCOPY isev_reltv_rec_type) ;
  PROCEDURE DELETE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_reltv_rec_type);

  PROCEDURE LOCK_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_reltv_rec_type);

  PROCEDURE VALID_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_reltv_rec_type) ;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_IG_STARTEND
 --------------------------------------------------------------------------

  SUBTYPE igsv_rec_type is okc_igs_pvt.igsv_rec_type;

  TYPE igsv_extended_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
--Bug 3122962
    sfwt_flag                      OKC_TIME_IG_STARTEND_V.SFWT_FLAG%TYPE := 'N',
    tve_id_limited                 NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                 NUMBER := OKC_API.G_MISS_NUM,
    tve_id_started                 NUMBER := OKC_API.G_MISS_NUM,
    tve_id_ended                   NUMBER := OKC_API.G_MISS_NUM,
    description                    OKC_TIME_IG_STARTEND_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_TIME_IG_STARTEND_V.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_TIME_IG_STARTEND_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_TIME_IG_STARTEND_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_TIME_IG_STARTEND_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_TIME_IG_STARTEND_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_TIME_IG_STARTEND_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_TIME_IG_STARTEND_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_TIME_IG_STARTEND_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_TIME_IG_STARTEND_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_TIME_IG_STARTEND_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_TIME_IG_STARTEND_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    start_month                    NUMBER := OKC_API.G_MISS_NUM,
    start_day                      NUMBER := OKC_API.G_MISS_NUM,
    start_day_of_week              OKC_TIME_TPG_DELIMITED_V.DAY_OF_WEEK%TYPE := OKC_API.G_MISS_CHAR,
    start_hour                     NUMBER := OKC_API.G_MISS_NUM,
    start_minute                   NUMBER := OKC_API.G_MISS_NUM,
    start_second                   NUMBER := OKC_API.G_MISS_NUM,
    start_nth                      NUMBER := OKC_API.G_MISS_NUM,
    end_month                      NUMBER := OKC_API.G_MISS_NUM,
    end_day                        NUMBER := OKC_API.G_MISS_NUM,
    end_day_of_week                OKC_TIME_TPG_DELIMITED_V.DAY_OF_WEEK%TYPE := OKC_API.G_MISS_CHAR,
    end_hour                       NUMBER := OKC_API.G_MISS_NUM,
    end_minute                     NUMBER := OKC_API.G_MISS_NUM,
    end_second                     NUMBER := OKC_API.G_MISS_NUM,
    end_nth                        NUMBER := OKC_API.G_MISS_NUM,
    tze_id                         NUMBER := OKC_API.G_MISS_NUM);

  PROCEDURE CREATE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_extended_rec_type,
    x_igsv_ext_rec          OUT NOCOPY igsv_extended_rec_type) ;

  PROCEDURE UPDATE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_extended_rec_type,
    x_igsv_ext_rec          OUT NOCOPY igsv_extended_rec_type);

  PROCEDURE DELETE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_extended_rec_type) ;

  PROCEDURE LOCK_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_extended_rec_type) ;

  PROCEDURE VALID_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_extended_rec_type) ;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_CYCLE
 --------------------------------------------------------------------------

  SUBTYPE cylv_rec_type is okc_cyl_pvt.cylv_rec_type;
  TYPE cylv_extended_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
--Bug 3122962
    sfwt_flag                      OKC_TIME_CYCLE_V.SFWT_FLAG%TYPE := 'N',
    spn_id                         NUMBER := OKC_API.G_MISS_NUM,
    tve_id_limited                 NUMBER := OKC_API.G_MISS_NUM,
    limited_start_date             DATE := OKC_API.G_MISS_DATE,
    limited_end_date               DATE := OKC_API.G_MISS_DATE,
    tze_id                         NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                 NUMBER := OKC_API.G_MISS_NUM,
    uom_code                OKC_SPAN_V.uom_code%TYPE,
    duration                OKC_SPAN_V.DURATION%TYPE,
    active_yn                OKC_SPAN_V.ACTIVE_YN%TYPE,
    description                    OKC_TIME_CYCLE_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_TIME_CYCLE_V.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_TIME_CYCLE_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_TIME_CYCLE_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    interval_yn                    OKC_TIME_CYCLE_V.INTERVAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_TIME_CYCLE_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_TIME_CYCLE_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_TIME_CYCLE_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_TIME_CYCLE_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_TIME_CYCLE_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_TIME_CYCLE_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_TIME_CYCLE_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_TIME_CYCLE_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_TIME_CYCLE_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_TIME_CYCLE_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_TIME_CYCLE_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_TIME_CYCLE_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_TIME_CYCLE_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_TIME_CYCLE_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_TIME_CYCLE_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_TIME_CYCLE_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_TIME_CYCLE_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_TIME_CYCLE_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);

  PROCEDURE CREATE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec		    IN cylv_extended_rec_type,
    x_cylv_ext_rec              OUT NOCOPY cylv_extended_rec_type) ;

  PROCEDURE UPDATE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec		    IN cylv_extended_rec_type,
    x_cylv_ext_rec              OUT NOCOPY cylv_extended_rec_type) ;

  PROCEDURE DELETE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec		    IN cylv_extended_rec_type) ;

  PROCEDURE LOCK_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec		    IN cylv_extended_rec_type) ;

  PROCEDURE VALID_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec		    IN cylv_extended_rec_type) ;


 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_SPAN
 --------------------------------------------------------------------------

  SUBTYPE spnv_rec_type is okc_spn_pvt.spnv_rec_type;

  PROCEDURE CREATE_SPAN(
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
    p_spnv_rec		    IN spnv_rec_type,
    x_spnv_rec              OUT NOCOPY spnv_rec_type) ;

  PROCEDURE DELETE_SPAN(
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
    p_spnv_rec		    IN spnv_rec_type) ;

  PROCEDURE VALID_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec		    IN spnv_rec_type) ;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_CODE_UNITS
 --------------------------------------------------------------------------

  SUBTYPE tcuv_rec_type is okc_tcu_pvt.tcuv_rec_type;

  PROCEDURE CREATE_TIME_CODE_UNITS(
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
    p_tcuv_rec		    IN tcuv_rec_type,
    x_tcuv_rec              OUT NOCOPY tcuv_rec_type) ;

  PROCEDURE DELETE_TIME_CODE_UNITS(
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
    p_tcuv_rec		    IN tcuv_rec_type) ;

  PROCEDURE VALID_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec		    IN tcuv_rec_type) ;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_RESOLVED_TIMEVALUES
 --------------------------------------------------------------------------

  SUBTYPE rtvv_rec_type is okc_rtv_pvt.rtvv_rec_type;

  PROCEDURE CREATE_RESOLVED_TIMEVALUES(
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
    p_rtvv_rec		    IN rtvv_rec_type,
    x_rtvv_rec              OUT NOCOPY rtvv_rec_type) ;

  PROCEDURE DELETE_RESOLVED_TIMEVALUES(
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
    p_rtvv_rec		    IN rtvv_rec_type) ;

  PROCEDURE VALID_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec		    IN rtvv_rec_type) ;

---------------------------------------------------------------
-- Procedure for mass insert in OKC_TIMEVALUES _B and TL tables
---------------------------------------------------------------
  TYPE igsv_ext_tbl_type is table of igsv_extended_rec_type index by binary_integer;
  PROCEDURE INSERT_IGS_ROW_UPG(p_igsv_ext_tbl IN igsv_ext_tbl_type);
  TYPE tgdv_ext_tbl_type is table of tgdv_extended_rec_type index by binary_integer;
  PROCEDURE INSERT_TGD_ROW_UPG(p_tgdv_ext_tbl IN tgdv_ext_tbl_type);
  TYPE isev_ext_tbl_type is table of isev_extended_rec_type index by binary_integer;
  PROCEDURE INSERT_ISE_ROW_UPG(p_isev_ext_tbl IN isev_ext_tbl_type);
  TYPE isev_rel_tbl_type is table of isev_reltv_rec_type index by binary_integer;
  PROCEDURE INSERT_ISE_ROW_UPG(p_isev_rel_tbl IN isev_rel_tbl_type);
END OKC_TIME_PVT;

 

/
