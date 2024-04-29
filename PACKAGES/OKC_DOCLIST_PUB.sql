--------------------------------------------------------
--  DDL for Package OKC_DOCLIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_DOCLIST_PUB" AUTHID CURRENT_USER AS
/*$Header: OKCPUBLS.pls 120.0 2005/05/25 22:47:55 appldev noship $*/

--===================
-- TYPES
--===================
--


--===================
-- CONSTANTS
--===================
--
   g_unexpected_error		CONSTANT VARCHAR2(200) := 'OKC_UBL_UNEXP_ERROR';
   g_sqlerrm_token			CONSTANT VARCHAR2(200) := 'SQLerrm';
   g_sqlcode_token			CONSTANT VARCHAR2(200) := 'SQLcode';
   g_uppercase_required		CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';

   g_package_name			CONSTANT VARCHAR2(200) := 'OKC_DOCLIST_PUB';
   g_package_version		CONSTANT NUMBER := 1;
   g_application_name		CONSTANT VARCHAR2(10) := okc_api.g_app_name;
   g_init_msg_list			CONSTANT VARCHAR2(1) := okc_api.g_true;

   g_recent_type			CONSTANT VARCHAR2(12) := 'RECENT';
   g_bookmark_type			CONSTANT VARCHAR2(12) := 'BOOKMARK';

--===================
-- PUBLIC VARIABLES
--===================
-- none used

--===================
-- PROCEDURES AND FUNCTIONS
--===================
--
   PROCEDURE add_recent (
	p_contract_id                   IN  OKC_K_HEADERS_B.id%TYPE
	,p_contract_number              IN  OKC_K_HEADERS_B.contract_number%TYPE
	,p_contract_type                IN  OKC_K_HEADERS_B.chr_type%TYPE
	,p_contract_modifier            IN  OKC_K_HEADERS_B.contract_number_modifier%TYPE
	,p_short_description            IN  OKC_K_HEADERS_TL.short_description%TYPE
	,p_program_name                 IN  OKC_USER_BINS.program_name%TYPE
	,x_return_status                OUT NOCOPY VARCHAR2
	,x_msg_count                    OUT NOCOPY NUMBER
	,x_msg_data                     OUT NOCOPY VARCHAR2 );


   PROCEDURE add_bookmark (
	p_contract_id                   IN  OKC_K_HEADERS_B.id%TYPE
	,p_contract_number              IN  OKC_K_HEADERS_B.contract_number%TYPE
	,p_contract_type                IN  OKC_K_HEADERS_B.chr_type%TYPE
	,p_contract_modifier            IN  OKC_K_HEADERS_B.contract_number_modifier%TYPE
	,p_short_description            IN  OKC_K_HEADERS_TL.short_description%TYPE
	,p_program_name                 IN  VARCHAR2
	,x_return_status                OUT NOCOPY VARCHAR2
	,x_msg_count                    OUT NOCOPY NUMBER
	,x_msg_data                     OUT NOCOPY VARCHAR2 );

   PROCEDURE delete_entry (
  	x_ubl_id                        IN  OKC_USER_BINS.id%TYPE
	,x_return_status                OUT NOCOPY VARCHAR2
	,x_msg_count                    OUT NOCOPY NUMBER
	,x_msg_data                     OUT NOCOPY VARCHAR2 );

END OKC_DOCLIST_PUB;

 

/
