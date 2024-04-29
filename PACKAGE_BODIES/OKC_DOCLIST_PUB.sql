--------------------------------------------------------
--  DDL for Package Body OKC_DOCLIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_DOCLIST_PUB" AS
/*$Header: OKCPUBLB.pls 120.0 2005/05/26 09:40:26 appldev noship $*/
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--
-- TYPES
--===================
-- add your type declarations here if any
--


    g_ubl_recin			okc_ubl_pvt.ubnv_rec_type;

    g_ubl_recout			okc_ubl_pvt.ubnv_rec_type;


--===================
-- PACKAGE CONSTANTS
--===================
--
	x_msg_count			NUMBER;
	x_msg_data			VARCHAR2(2000);
	x_return_status		VARCHAR2(1);

--===================
-- LOCAL PROCEDURES AND FUNCTIONS
--===================
--

--===================
-- PACKAGE PROCEDURES AND FUNCTIONS
--===================
--

--
-- ---------------------------------------------------------------------------------
-- PROCEDURE: Add_Recent                                                          --
-- DESCRIPTION: Adds a recent document row (type R) to the okc_user_bins table    --
--            using the record passed                                             --
-- DEPENDENCIES: none                                                             --
-- CHANGE HISTORY:                                                                --
--   19/aug/99  - created                                                         --
--                                                                                --
-- ---------------------------------------------------------------------------------
--
PROCEDURE add_recent (
	p_contract_id			IN  OKC_K_HEADERS_B.id%TYPE
	,p_contract_number		IN  OKC_K_HEADERS_B.contract_number%TYPE
	,p_contract_type		IN  OKC_K_HEADERS_B.chr_type%TYPE
	,p_contract_modifier		IN  OKC_K_HEADERS_B.contract_number_modifier%TYPE
	,p_short_description		IN  OKC_K_HEADERS_TL.short_description%TYPE
	,p_program_name			IN  OKC_USER_BINS.program_name%TYPE
	,x_return_status		OUT NOCOPY VARCHAR2
	,x_msg_count			OUT NOCOPY NUMBER
	,x_msg_data			OUT NOCOPY VARCHAR2 )
IS
     PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name				VARCHAR2(20) := 'ADD_RECENT';

BEGIN
--
--   pass the input parms to the private procedure to process
--


	okc_doclist_pvt.add_recent (
		p_contract_id            => p_contract_id
                ,p_contract_number       => p_contract_number
                ,p_contract_type         => p_contract_type
                ,p_contract_modifier     => p_contract_modifier
                ,p_short_description     => p_short_description
                ,p_program_name          => p_program_name
		,x_return_status         =>  x_return_status
		,x_msg_count             =>  x_msg_count
		,x_msg_data              =>  x_msg_data );

	IF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN
		RAISE okc_api.g_exception_unexpected_error;
	ELSIF (x_return_status = okc_api.g_ret_sts_error) THEN
		RAISE okc_api.g_exception_error;
	END IF;

	COMMIT;

EXCEPTION
   WHEN okc_api.g_exception_error THEN
	x_return_status := okc_api.handle_exceptions (
				p_api_name		=> l_api_name
				,p_pkg_name		=> g_package_name
				,p_exc_name		=> 'OKC_API.g_ret_sts_error'
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data
				,p_api_type		=> '_PUB' );

   WHEN okc_api.g_exception_unexpected_error THEN
	x_return_status := okc_api.handle_exceptions (
				p_api_name		=> l_api_name
				,p_pkg_name		=> g_package_name
				,p_exc_name		=> 'OKC_API.g_ret_sts_unexp_error'
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data
				,p_api_type		=> '_PUB' );
   WHEN OTHERS THEN
	x_return_status := okc_api.handle_exceptions (
				p_api_name		=> l_api_name
				,p_pkg_name		=> g_package_name
				,p_exc_name		=> 'OTHERS'
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data
				,p_api_type		=> '_PUB' );

END  add_recent;



--
-- ---------------------------------------------------------------------------------
-- PROCEDURE:  Add_Bookmark                                                       --
-- DESCRIPTION: Inserts a row for a bookmarked contract (Type B) into             --
--              okc_user_bins using the row record passed                         --
-- DEPENDENCIES: none                                                             --
-- CHANGE HISTORY:                                                                --
--   19/aug/99  - created                                                         --
--                                                                                --
-- ---------------------------------------------------------------------------------
--
PROCEDURE add_bookmark (
	p_contract_id			IN  OKC_K_HEADERS_B.id%TYPE
	,p_contract_number		IN  OKC_K_HEADERS_B.contract_number%TYPE
	,p_contract_type		IN  OKC_K_HEADERS_B.chr_type%TYPE
	,p_contract_modifier		IN  OKC_K_HEADERS_B.contract_number_modifier%TYPE
	,p_short_description		IN  OKC_K_HEADERS_TL.short_description%TYPE
	,p_program_name			IN  VARCHAR2
	,x_return_status			OUT NOCOPY VARCHAR2
	,x_msg_count				OUT NOCOPY NUMBER
	,x_msg_data				OUT NOCOPY VARCHAR2 )
IS
     PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name				VARCHAR2(20) := 'ADD_BOOKMARK';

BEGIN
--
--   pass the parameters to the private procedure and process
--

        okc_doclist_pvt.add_bookmark (
		p_contract_id            => p_contract_id
                ,p_contract_number       => p_contract_number
                ,p_contract_type         => p_contract_type
                ,p_contract_modifier     => p_contract_modifier
                ,p_short_description     => p_short_description
                ,p_program_name          => p_program_name
		,x_return_status       =>  x_return_status
		,x_msg_count           =>  x_msg_count
		,x_msg_data            =>  x_msg_data );

	IF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN
		RAISE okc_api.g_exception_unexpected_error;
	ELSIF (x_return_status = okc_api.g_ret_sts_error) THEN
		RAISE okc_api.g_exception_error;
	END IF;

	COMMIT;

EXCEPTION
   WHEN okc_api.g_exception_error THEN
	x_return_status := okc_api.handle_exceptions (
				p_api_name		=> l_api_name
				,p_pkg_name		=> g_package_name
				,p_exc_name		=> 'OKC_API.g_ret_sts_error'
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data
				,p_api_type		=> '_PUB' );

   WHEN okc_api.g_exception_unexpected_error THEN
	x_return_status := okc_api.handle_exceptions (
				p_api_name		=> l_api_name
				,p_pkg_name		=> g_package_name
				,p_exc_name		=> 'OKC_API.g_ret_sts_unexp_error'
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data
				,p_api_type		=> '_PUB' );
   WHEN OTHERS THEN
	x_return_status := okc_api.handle_exceptions (
				p_api_name		=> l_api_name
				,p_pkg_name		=> g_package_name
				,p_exc_name		=> 'OTHERS'
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data
				,p_api_type		=> '_PUB' );

END   add_bookmark;


--
-- ---------------------------------------------------------------------------------
-- PROCEDURE:  Delete_Entry                                                       --
-- DESCRIPTION: Deletes the row identified in the record passed                   --
--                                                                                --
-- DEPENDENCIES: none                                                             --
-- CHANGE HISTORY:                                                                --
--   19/aug/99  - created                                                         --
--                                                                                --
-- ---------------------------------------------------------------------------------
--
PROCEDURE delete_entry (
	x_ubl_id				IN  OKC_USER_BINS.id%TYPE
	,x_return_status		OUT NOCOPY VARCHAR2
	,x_msg_count			OUT NOCOPY NUMBER
	,x_msg_data			OUT NOCOPY VARCHAR2 )
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name				VARCHAR2(30) := 'DELETE_ENTRY';
    this_row                  NUMBER;

BEGIN
--
--  call the private API to delete the row passed
--
     this_row := x_ubl_id;
	okc_Doclist_pvt.delete_entry (
			p_ubl_id            => this_row
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data);

	IF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN
		RAISE okc_api.g_exception_unexpected_error;
	ELSIF (x_return_status = okc_api.g_ret_sts_error) THEN
		RAISE okc_api.g_exception_error;
	END IF;

	COMMIT;

EXCEPTION
   WHEN okc_api.g_exception_error THEN
	x_return_status := okc_api.handle_exceptions (
				p_api_name		=> l_api_name
				,p_pkg_name		=> g_package_name
				,p_exc_name		=> 'OKC_API.g_ret_sts_error'
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data
				,p_api_type		=> '_PVT' );

   WHEN okc_api.g_exception_unexpected_error THEN
	x_return_status := okc_api.handle_exceptions (
				p_api_name		=> l_api_name
				,p_pkg_name		=> g_package_name
				,p_exc_name		=> 'OKC_API.g_ret_sts_unexp_error'
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data
				,p_api_type		=> '_PVT' );
   WHEN OTHERS THEN
	x_return_status := okc_api.handle_exceptions (
				p_api_name		=> l_api_name
				,p_pkg_name		=> g_package_name
				,p_exc_name		=> 'OTHERS'
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data
				,p_api_type		=> '_PVT' );

END   delete_entry;



END OKC_DOCLIST_PUB;

/
