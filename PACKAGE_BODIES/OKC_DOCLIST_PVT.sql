--------------------------------------------------------
--  DDL for Package Body OKC_DOCLIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_DOCLIST_PVT" AS
/*$Header: OKCRUBLB.pls 120.0 2005/05/25 19:14:14 appldev noship $*/

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--===================
-- TYPES
--===================
-- add your type declarations here if any
--



--===================
-- PACKAGE CONSTANTS
--===================
--
	x_msg_count	NUMBER;
	x_msg_data	VARCHAR2(2000);
	x_return_status	VARCHAR2(1);

--===================
-- LOCAL PROCEDURES AND FUNCTIONS
--===================
--
PROCEDURE process_row (
        row_type                        IN  VARCHAR2
	,x_return_status			OUT NOCOPY VARCHAR2
	,x_msg_count			OUT NOCOPY NUMBER
	,x_msg_data			OUT NOCOPY VARCHAR2 )
IS

    CURSOR ubl_csr_type (cp_program      	IN VARCHAR2
			 ,cp_user		IN NUMBER
			 ,cp_type		IN VARCHAR2 ) IS
	SELECT	id, creation_date, contract_id
	  FROM	okc_user_bins
	 WHERE	program_name = cp_program
	   AND	created_by = cp_user
	   AND	bin_type = cp_type
	ORDER BY creation_date;

    TYPE id_table_type 		IS TABLE OF okc_user_bins.id%TYPE INDEX BY BINARY_INTEGER;
    TYPE cdate_tbl_type		IS TABLE OF okc_user_bins.creation_date%TYPE INDEX BY BINARY_INTEGER;
    TYPE cid_tbl_type		IS TABLE OF okc_user_bins.contract_id%TYPE INDEX BY BINARY_INTEGER;

    l_api_name		VARCHAR2(20) := 'PROCESS_ROW';
    l_dups_deleted	NUMBER := 0;
    l_fifos_deleted	NUMBER := 0;

    l_return_status	VARCHAR2(1) := okc_api.g_ret_sts_success;
    l_msg_count		NUMBER := 0;
    l_msg_data		VARCHAR2(2000);
    bin_rec         ubl_csr_type%ROWTYPE;
    id_tab		id_table_type;
    cdate_tab		cdate_tbl_type;
    cid_tab		cid_tbl_type;
    i               NUMBER := 0;
BEGIN

--
--  Start the logical activity...
--
	x_return_status := OKC_API.start_activity (
				P_API_NAME		=> l_api_name
				,P_INIT_MSG_LIST	=> g_init_msg_list
				,P_API_TYPE		=> '_PVT'
				,X_RETURN_STATUS	=> x_return_status );

	IF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN
		RAISE okc_api.g_exception_unexpected_error;
	ELSIF (x_return_status = okc_api.g_ret_sts_error) THEN
		RAISE okc_api.g_exception_error;
	END IF;

--
--   validate the record before calling insert
--
	okc_ubl_pvt.validate_row (
			p_api_version		=> g_package_version
			,p_init_msg_list	=> g_init_msg_list
			,x_return_status	=> l_return_status
			,x_msg_count		=> l_msg_count
			,x_msg_data		=> l_msg_data
			,p_ubnv_rec		=> g_ubl_recin);

	IF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN
		RAISE okc_api.g_exception_unexpected_error;
	ELSIF (x_return_status = okc_api.g_ret_sts_error) THEN
		RAISE okc_api.g_exception_error;
	END IF;

--
-- insert if OK
--
	okc_ubl_pvt.insert_row (
			p_api_version		=> g_package_version
			,p_init_msg_list	=> g_init_msg_list
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_ubnv_rec		=> g_ubl_recin
			,x_ubnv_rec		=> g_ubl_recout );

	IF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN
		RAISE okc_api.g_exception_unexpected_error;
	ELSIF (x_return_status = okc_api.g_ret_sts_error) THEN
		RAISE okc_api.g_exception_error;
	END IF;
--*********Entire logic  Modified by MKS
--
--   check if a duplicate has been inserted. Duplicate is same contract, same type, same user
--   If exists, delete the duplicate and continue checking for rows to trim from the list length
--
	IF ROW_TYPE in ('BOOKMARK', 'RECENT') THEN
	  OPEN ubl_csr_type (g_ubl_recout.program_name, g_ubl_recout.created_by, g_ubl_recout.bin_type);
--	  FETCH ubl_csr_type BULK COLLECT INTO id_tab, cdate_tab, cid_tab;
	  i := 1;
	  LOOP
	  FETCH ubl_csr_type INTO id_tab(i), cdate_tab(i), cid_tab(i);
	  EXIT WHEN ubl_csr_type%NOTFOUND;
	  i := i+1;
	  END LOOP;
	  CLOSE ubl_csr_type;
	  x_return_status := okc_api.g_ret_sts_success;
	  l_dups_deleted := 0;
	  l_fifos_deleted := 0;
	  i := 0;

	  FOR i in id_tab.FIRST..id_tab.LAST LOOP
	  --
	  --   check if a duplicate
	  --
	  --	dbms_output.put_line('checking Dups:' ||id_tab.LAST ||'*'|| l_dups_deleted ||'*'|| l_fifos_deleted ||'*'|| g_max_list_length );
	  -- Because of the following logic, there can be at most one duplicate at a time. Therefore exit after finding the duplicate
		IF cid_tab(i) = g_ubl_recout.contract_id
		   AND cdate_tab(i) <> g_ubl_recout.creation_date THEN
			delete_entry (	p_ubl_id		=> id_tab(i)
					,x_return_status 	=> x_return_status
					,x_msg_count		=> x_msg_count
					,x_msg_data		=> x_msg_data);
			IF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN
				RAISE okc_api.g_exception_unexpected_error;
			ELSIF (x_return_status = okc_api.g_ret_sts_error) THEN
				RAISE okc_api.g_exception_error;
			END IF;
			l_dups_deleted := l_dups_deleted + 1;
			id_tab.DELETE(i);
			cid_tab.DELETE(i);
			cdate_tab.DELETE(i);
			exit;
		END IF;
	  END LOOP;
	  IF ROW_TYPE =  'RECENT' THEN
	  --
	  --   delete rows beyond list length
	  --
	    IF (id_tab.COUNT - l_dups_deleted ) > g_max_list_length THEN
	      --FOR i in id_tab.FIRST..id_tab.LAST LOOP
		 --dbms_output.put_line('checking LIFOs:' ||id_tab.COUNT ||'*'|| l_dups_deleted ||'*'|| l_fifos_deleted ||'*'|| g_max_list_length );
		 --IF (id_tab.COUNT - l_dups_deleted - l_fifos_deleted) > g_max_list_length THEN
	      --	delete_entry (	p_ubl_id		=>  id_tab(i)
			delete_entry (	p_ubl_id		=>  id_tab(id_tab.FIRST)
					,x_return_status 	=> x_return_status
					,x_msg_count		=> x_msg_count
					,x_msg_data		=> x_msg_data);
			IF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN
				RAISE okc_api.g_exception_unexpected_error;
			ELSIF (x_return_status = okc_api.g_ret_sts_error) THEN
				RAISE okc_api.g_exception_error;
			END IF;
		--	l_fifos_deleted := l_fifos_deleted + 1;
		--  END IF;
	     -- END LOOP;
         END IF;
	END IF;
  END IF;

--********* End of Mod
--
--   close the activity
--
	okc_api.end_activity (
			x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data);


EXCEPTION
   WHEN okc_api.g_exception_error THEN
	IF ubl_csr_type%ISOPEN THEN
		close ubl_csr_type;
	END IF;
	x_return_status := okc_api.handle_exceptions (
				p_api_name		=> l_api_name
				,p_pkg_name		=> g_package_name
				,p_exc_name		=> 'OKC_API.g_ret_sts_error'
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data
				,p_api_type		=> '_PVT' );

   WHEN okc_api.g_exception_unexpected_error THEN
	IF ubl_csr_type%ISOPEN THEN
		close ubl_csr_type;
	END IF;
	x_return_status := okc_api.handle_exceptions (
				p_api_name		=> l_api_name
				,p_pkg_name		=> g_package_name
				,p_exc_name		=> 'OKC_API.g_ret_sts_unexp_error'
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data
				,p_api_type		=> '_PVT' );
   WHEN OTHERS THEN
	IF ubl_csr_type%ISOPEN THEN
		close ubl_csr_type;
	END IF;
	x_return_status := okc_api.handle_exceptions (
				p_api_name		=> l_api_name
				,p_pkg_name		=> g_package_name
				,p_exc_name		=> 'OTHERS'
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data
				,p_api_type		=> '_PVT' );

END  Process_row;

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
--   12/aug/99  - created                                                         --
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
--    move the passed parameters to a record structure and process
--
	g_ubl_recin.id 			:= 0;
	g_ubl_recin.contract_id 	:= p_contract_id;
	g_ubl_recin.contract_number 	:= p_contract_number;
	g_ubl_recin.contract_type 	:= p_contract_type;
	g_ubl_recin.contract_number_modifier := p_contract_modifier;
	g_ubl_recin.program_name	:= p_program_name;
	g_ubl_recin.short_description	:= p_short_description;
	g_ubl_recin.bin_type		:= g_recent_type;
	g_ubl_recin.created_by		:= 0;
	g_ubl_recin.creation_date	:= null;

	x_return_status := okc_api.g_ret_sts_success;
	Process_row (
                row_type                => 'RECENT'
		,x_return_status        => x_return_status
		,x_msg_count            => x_msg_count
		,x_msg_data             => x_msg_data );

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

END  add_recent;



--
-- ---------------------------------------------------------------------------------
-- PROCEDURE:  Add_Bookmark                                                       --
-- DESCRIPTION: Inserts a row for a bookmarked contract (Type B) into             --
--              okc_user_bins using the row record passed                         --
-- DEPENDENCIES: none                                                             --
-- CHANGE HISTORY:                                                                --
--   12/aug/99  - created                                                         --
--                                                                                --
-- ---------------------------------------------------------------------------------
--
PROCEDURE add_bookmark (
	p_contract_id			IN  OKC_K_HEADERS_B.id%TYPE
	,p_contract_number		IN  OKC_K_HEADERS_B.contract_number%TYPE
	,p_contract_type		IN  OKC_K_HEADERS_B.chr_type%TYPE
	,p_contract_modifier	IN  OKC_K_HEADERS_B.contract_number_modifier%TYPE
	,p_short_description	IN  OKC_K_HEADERS_TL.short_description%TYPE
	,p_program_name		IN  VARCHAR2
	,x_return_status		OUT NOCOPY VARCHAR2
	,x_msg_count			OUT NOCOPY NUMBER
	,x_msg_data			OUT NOCOPY VARCHAR2 )
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name				VARCHAR2(20) := 'ADD_BOOKMARK';

BEGIN
--
--   move the passed parameters to a record structure and process
--
	g_ubl_recin.id 			:= 0;
	g_ubl_recin.contract_id 	     := p_contract_id;
	g_ubl_recin.contract_number 	:= p_contract_number;
	g_ubl_recin.contract_type 	:= p_contract_type;
	g_ubl_recin.contract_number_modifier := p_contract_modifier;
	g_ubl_recin.program_name		:= p_program_name;
	g_ubl_recin.short_description	:= p_short_description;
	g_ubl_recin.bin_type		:= g_bookmark_type;
	g_ubl_recin.created_by		:= 0;
	g_ubl_recin.creation_date	:= null;

	x_return_status := okc_api.g_ret_sts_success;
	process_row (
                row_type                => 'BOOKMARK'
		,x_return_status        => x_return_status
		,x_msg_count            => x_msg_count
		,x_msg_data             => x_msg_data);

/*	IF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN
		RAISE okc_api.g_exception_unexpected_error;
	ELSIF (x_return_status = okc_api.g_ret_sts_error) THEN
		RAISE okc_api.g_exception_error;
	END IF;
	*/

	IF (x_return_status = okc_api.g_ret_sts_success) THEN
	  COMMIT;
	END IF;

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

END   add_bookmark;


--
-- ---------------------------------------------------------------------------------
-- PROCEDURE:  Delete_Entry                                                       --
-- DESCRIPTION: Deletes the row identified in the record passed                   --
--                                                                                --
-- DEPENDENCIES: none                                                             --
-- CHANGE HISTORY:                                                                --
--   12/aug/99  - created                                                         --
--                                                                                --
-- ---------------------------------------------------------------------------------
--
PROCEDURE delete_entry (
	p_ubl_id			IN  OKC_USER_BINS.id%TYPE
	,x_return_status		OUT NOCOPY VARCHAR2
	,x_msg_count			OUT NOCOPY NUMBER
	,x_msg_data			OUT NOCOPY VARCHAR2 )
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name				VARCHAR2(30) := 'DELETE_ENTRY';

BEGIN
--
--   set-up the record structure then call delete
--
	g_ubl_recin.id 			:= p_ubl_id;
	g_ubl_recin.contract_id 	:= null;
	g_ubl_recin.contract_number 	:= null;
	g_ubl_recin.contract_type 	:= null;
	g_ubl_recin.contract_number_modifier :=null;
	g_ubl_recin.program_name	:= null;
	g_ubl_recin.short_description		:= null;
	g_ubl_recin.bin_type		:= null;
	g_ubl_recin.created_by		:= null;
	g_ubl_recin.creation_date	:= null;

	okc_ubl_pvt.delete_row (
			p_api_version		=> g_package_version
			,p_init_msg_list	=> g_init_msg_list
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_ubnv_rec		=> g_ubl_recin );

/*	IF (x_return_status = okc_api.g_ret_sts_unexp_error) THEN
		RAISE okc_api.g_exception_unexpected_error;
	ELSIF (x_return_status = okc_api.g_ret_sts_error) THEN
		RAISE okc_api.g_exception_error;
	END IF;
*/
	IF (x_return_status = okc_api.g_ret_sts_success) THEN
	  COMMIT;
	END IF;

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

END OKC_DOCLIST_PVT;

/
