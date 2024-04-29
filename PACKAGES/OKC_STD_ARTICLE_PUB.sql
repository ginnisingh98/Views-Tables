--------------------------------------------------------
--  DDL for Package OKC_STD_ARTICLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_STD_ARTICLE_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPSAES.pls 120.0 2005/05/25 18:39:38 appldev noship $ */
 subtype saev_rec_type is okc_std_article_pvt.saev_rec_type;
 subtype saev_tbl_type is okc_std_article_pvt.saev_tbl_type;

 subtype savv_rec_type is okc_std_article_pvt.savv_rec_type;
 subtype savv_tbl_type is okc_std_article_pvt.savv_tbl_type;

 subtype saiv_rec_type is okc_std_article_pvt.saiv_rec_type;
 subtype saiv_tbl_type is okc_std_article_pvt.saiv_tbl_type;

 subtype samv_rec_type is okc_std_article_pvt.samv_rec_type;
 subtype samv_tbl_type is okc_std_article_pvt.samv_tbl_type;

 subtype sacv_rec_type is okc_std_article_pvt.sacv_rec_type;
 subtype sacv_tbl_type is okc_std_article_pvt.sacv_tbl_type;


  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_STD_ARTICLE_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
  G_EXCEPTION_HALT_PROCESSING           EXCEPTION;

--Records for User Hooks
     g_saev_rec                     saev_rec_type;
     g_saiv_rec                     saiv_rec_type;
     g_sacv_rec                     sacv_rec_type;
     g_savv_rec                     savv_rec_type;
     g_samv_rec                     samv_rec_type;


  ---------------------------------------------------------------------------

--Procedures pertaining to Setting up of a standard Article

 PROCEDURE add_language;

 PROCEDURE Create_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type,
	p_savv_tbl		IN savv_tbl_type,
	p_saiv_tbl		IN saiv_tbl_type,
	p_samv_tbl		IN samv_tbl_type,
	x_saev_rec		OUT NOCOPY saev_rec_type,
	x_savv_tbl		OUT NOCOPY savv_tbl_type,
	x_saiv_tbl		OUT NOCOPY saiv_tbl_type,
	x_samv_tbl		OUT NOCOPY samv_tbl_type);



 PROCEDURE Update_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type,
	p_savv_tbl		IN savv_tbl_type,
	p_saiv_tbl		IN saiv_tbl_type,
	p_samv_tbl		IN samv_tbl_type,
	x_saev_rec		OUT NOCOPY saev_rec_type,
	x_savv_tbl		OUT NOCOPY savv_tbl_type,
	x_saiv_tbl		OUT NOCOPY saiv_tbl_type,
	x_samv_tbl		OUT NOCOPY samv_tbl_type);



 PROCEDURE Validate_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type,
	p_savv_tbl		IN savv_tbl_type,
	p_saiv_tbl		IN saiv_tbl_type,
	p_samv_tbl		IN samv_tbl_type);


 PROCEDURE create_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type,
	x_saev_tbl		OUT NOCOPY saev_tbl_type);


PROCEDURE create_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type,
	x_saev_rec		OUT NOCOPY saev_rec_type);

PROCEDURE lock_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type);


PROCEDURE lock_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type);

PROCEDURE update_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type,
	x_saev_tbl		OUT NOCOPY saev_tbl_type);


PROCEDURE update_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type,
	x_saev_rec		OUT NOCOPY saev_rec_type);

PROCEDURE delete_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type);


PROCEDURE delete_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type);

PROCEDURE validate_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type);


PROCEDURE validate_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type);


PROCEDURE validate_name(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type);

PROCEDURE validate_name(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type);

PROCEDURE validate_no_k_attached(
        p_saev_rec                     IN saev_rec_type,
        x_return_status                OUT NOCOPY VARCHAR2);

PROCEDURE validate_no_k_attached(
        p_saev_tbl			   IN saev_tbl_type,
        x_return_status                OUT NOCOPY VARCHAR2);


PROCEDURE create_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type,
	x_savv_tbl		OUT NOCOPY savv_tbl_type);


PROCEDURE create_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type,
	x_savv_rec		OUT NOCOPY savv_rec_type);

PROCEDURE lock_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type);


PROCEDURE  lock_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type);

PROCEDURE update_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type,
	x_savv_tbl		OUT NOCOPY savv_tbl_type);


PROCEDURE update_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type,
	x_savv_rec		OUT NOCOPY savv_rec_type);

PROCEDURE delete_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type);


PROCEDURE delete_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type);

PROCEDURE validate_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type);


PROCEDURE validate_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type);


PROCEDURE validate_sav_release(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type);

PROCEDURE validate_sav_release(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type);
PROCEDURE validate_date_active(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type);

PROCEDURE validate_date_active(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type);

PROCEDURE validate_updatable(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type);

PROCEDURE validate_updatable(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type);

PROCEDURE validate_no_k_attached(
        p_savv_rec                     IN savv_rec_type,
        x_return_status                OUT NOCOPY VARCHAR2);

PROCEDURE validate_no_k_attached(
        p_savv_tbl			   IN savv_tbl_type,
        x_return_status                OUT NOCOPY VARCHAR2);

PROCEDURE validate_latest(
        p_savv_rec                     IN savv_rec_type,
        x_return_status                OUT NOCOPY VARCHAR2);

PROCEDURE validate_latest(
        p_savv_tbl			   IN savv_tbl_type,
        x_return_status                OUT NOCOPY VARCHAR2);

/*
PROCEDURE validate_short_description(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type);

PROCEDURE validate_short_description(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type);
*/

PROCEDURE create_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type,
	x_saiv_tbl		OUT NOCOPY saiv_tbl_type);


PROCEDURE create_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type,
	x_saiv_rec		OUT NOCOPY saiv_rec_type);

PROCEDURE lock_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type);


PROCEDURE lock_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type);

PROCEDURE update_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type,
	x_saiv_tbl		OUT NOCOPY saiv_tbl_type);

PROCEDURE update_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type,
	x_saiv_rec		OUT NOCOPY saiv_rec_type);

PROCEDURE delete_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type);


PROCEDURE delete_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type);

PROCEDURE validate_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type);


PROCEDURE validate_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type);

PROCEDURE validate_unique(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type);

PROCEDURE validate_unique(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type);

PROCEDURE create_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type,
	x_sacv_tbl		OUT NOCOPY sacv_tbl_type);

PROCEDURE create_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type,
	x_sacv_rec		OUT NOCOPY sacv_rec_type);

PROCEDURE lock_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type);

PROCEDURE lock_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type);

PROCEDURE update_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type,
	x_sacv_tbl		OUT NOCOPY sacv_tbl_type);


PROCEDURE update_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type,
	x_sacv_rec		OUT NOCOPY sacv_rec_type);

PROCEDURE delete_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type);


PROCEDURE delete_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type);

PROCEDURE validate_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type);

PROCEDURE validate_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type);

PROCEDURE validate_price_type(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type);

PROCEDURE validate_price_type(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type);

PROCEDURE validate_scs_code(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type);

PROCEDURE validate_scs_code(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type);


PROCEDURE create_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type,
	x_samv_tbl		OUT NOCOPY samv_tbl_type);


PROCEDURE create_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type,
	x_samv_rec		OUT NOCOPY samv_rec_type);

PROCEDURE lock_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type);


PROCEDURE lock_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type);

PROCEDURE update_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type,
	x_samv_tbl		OUT NOCOPY samv_tbl_type);

PROCEDURE update_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type,
	x_samv_rec		OUT NOCOPY samv_rec_type);

PROCEDURE delete_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type);

PROCEDURE delete_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type);

PROCEDURE validate_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type);

PROCEDURE validate_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type);

PROCEDURE validate_unique(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type);

PROCEDURE validate_unique(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type);


FUNCTION used_in_contracts
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE,
  p_sav_sav_release          IN   okc_k_articles_b.sav_sav_release%TYPE
)
RETURN VARCHAR2 ;

FUNCTION empclob RETURN CLOB;

FUNCTION latest_release
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE
)
RETURN VARCHAR2 ;
-- BUG 3188215 - KOL: BACKWARD COMPATIBILITY CHANGES
-- Modified the Function signature.
FUNCTION latest_release
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE,
  p_article_version_number   IN   okc_article_versions.article_version_number%TYPE
)
RETURN VARCHAR2 ;
-- BUG 3188215 - KOL: BACKWARD COMPATIBILITY CHANGES
-- Modified the Function signature.
FUNCTION latest_or_future_release
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE,
  p_article_version_number   IN   okc_article_versions.article_version_number%TYPE,
  p_date_active              IN   okc_article_versions.start_date%TYPE
)
RETURN VARCHAR2 ;

END okc_std_article_pub;

 

/
