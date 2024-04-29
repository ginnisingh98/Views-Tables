--------------------------------------------------------
--  DDL for Package Body OKC_K_REL_OBJS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_K_REL_OBJS_PUB" AS
/* $Header: OKCPCRJB.pls 120.0 2005/05/25 19:31:41 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- Start of comments
--
-- Procedure Name	: create_k_rel_obj
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE create_k_rel_obj
		(-- create all the records required for a relationship between contract and quote, order etc.
		p_api_version		 	IN		NUMBER
		,p_init_msg_list		IN		VARCHAR2
		,x_return_status		OUT	NOCOPY	VARCHAR2
		,x_msg_count			OUT	NOCOPY	NUMBER
		,x_msg_data			OUT	NOCOPY	VARCHAR2
		,p_crj_rel_hdr_full_rec	IN		crj_rel_hdr_full_rec_type
		,p_crj_rel_line_tbl		IN		crj_rel_line_tbl_type
		,x_crj_rel_hdr_full_rec	OUT		NOCOPY	crj_rel_hdr_full_rec_type
		,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
		) IS

	l_api_version			CONSTANT	NUMBER			:= 1;
	l_api_name			CONSTANT	VARCHAR2(30)		:= 'create_k_rel_obj';
	l_return_status		VARCHAR2(1)				:= OKC_API.G_RET_STS_SUCCESS;
	l_crjv_tbl			crjv_tbl_type;
	l_x_crjv_tbl			crjv_tbl_type;
	l_obj_type_code		jtf_objects_b.OBJECT_CODE%type;
	l_error_message		varchar2(1000);
	i					number;
	j					number;
	l_char				varchar2(500);

	BEGIN
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(2, ' ');
   		okc_util.print_trace(2, '>START - OKC_K_REL_OBJS_PUB.CREATE_K_REL_OBJ -');
		END IF;
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					l_api_name
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call Before Logic Hook

		g_p_crj_rel_hdr_full_rec	:= p_crj_rel_hdr_full_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'B'
			);

		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(p_crj_rel_hdr_full_rec);
*/
		/*
		format parms for create rel. between headers
		*/
		l_crjv_tbl(1).jtot_object1_code	:= p_crj_rel_hdr_full_rec.jtot_object1_code;
		l_crjv_tbl(1).rty_code		:= p_crj_rel_hdr_full_rec.rty_code;
		l_crjv_tbl(1).chr_id		:= p_crj_rel_hdr_full_rec.chr_id;
		l_crjv_tbl(1).cle_id		:= null;
		l_crjv_tbl(1).object1_id1	:= p_crj_rel_hdr_full_rec.object1_id1;
		l_crjv_tbl(1).object1_id2	:= p_crj_rel_hdr_full_rec.object1_id2;

		l_return_status	:= OKC_API.G_RET_STS_SUCCESS;
		okc_crj_pvt.valid_rec_unique
			(
			l_crjv_tbl(1)
			,l_api_name
			,l_return_status
			);

		IF	(-- not unique header record, but lines to process
				l_return_status	<> OKC_API.G_RET_STS_SUCCESS
			and	p_crj_rel_line_tbl.EXISTS(1)
			) THEN
			-- header rel. already exists, ignore and continue with lines only
			j	:= 0;
			x_crj_rel_hdr_full_rec:=p_crj_rel_hdr_full_rec;
		ELSE	-- ok
			j	:= 1;
		END IF;
		l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

		i	:= 1;
		WHILE	(-- line data exists
				p_crj_rel_line_tbl.EXISTS(i)
			) LOOP
			/*
			format parms for create rel. between lines
			*/
			l_crjv_tbl(i+j).jtot_object1_code	:= p_crj_rel_hdr_full_rec.line_jtot_object1_code;
			l_crjv_tbl(i+j).rty_code		:= p_crj_rel_hdr_full_rec.rty_code;
			l_crjv_tbl(i+j).chr_id		:= p_crj_rel_hdr_full_rec.chr_id;

			l_crjv_tbl(i+j).cle_id		:= p_crj_rel_line_tbl(i).cle_id;
			l_crjv_tbl(i+j).object1_id1	:= p_crj_rel_line_tbl(i).object1_id1;
			l_crjv_tbl(i+j).object1_id2	:= p_crj_rel_line_tbl(i).object1_id2;
			i					:= i + 1;
      		END LOOP;

		/*
		create relationship records
		*/
		i := 1;
		WHILE(-- line data exists
				l_crjv_tbl.EXISTS(i)
			     and	x_return_status	= OKC_API.G_RET_STS_SUCCESS
			) LOOP
			OKC_K_REL_OBJS_PUB.create_row
				(
				p_api_version		=>	l_api_version
				,p_init_msg_list	=>	OKC_API.G_FALSE
				,x_return_status	=>	x_return_status
				,x_msg_count		=>	x_msg_count
				,x_msg_data		=>	x_msg_data
				,p_crjv_rec		=>	l_crjv_tbl(i)
				,x_crjv_rec		=>	l_x_crjv_tbl(i)
				);
				IF j = 0 THEN
				  x_crj_rel_line_tbl(i).cle_id:= l_x_crjv_tbl(i).cle_id;
				  x_crj_rel_line_tbl(i).object1_id1:=l_x_crjv_tbl(i).object1_id1;
				  x_crj_rel_line_tbl(i).object1_id2:=l_x_crjv_tbl(i).object1_id2;
                    ELSE
				  IF i > 1 THEN
				     x_crj_rel_line_tbl(i).cle_id:= l_x_crjv_tbl(i).cle_id;
				     x_crj_rel_line_tbl(i).object1_id1:=l_x_crjv_tbl(i).object1_id1;
				     x_crj_rel_line_tbl(i).object1_id2:=l_x_crjv_tbl(i).object1_id2;
				  ELSE
				     x_crj_rel_hdr_full_rec.chr_id:= l_x_crjv_tbl(i).chr_id;
				     x_crj_rel_hdr_full_rec.object1_id1:=l_x_crjv_tbl(i).object1_id1;
				     x_crj_rel_hdr_full_rec.object1_id2:=l_x_crjv_tbl(i).object1_id2;
				  END IF;
				END IF;
			     i:= i + 1;
      		END LOOP;

/* loop in pvt insert does not check every record for status so do rows individually as above
		OKC_K_REL_OBJS_PUB.create_row
			(
			p_api_version		=>	l_api_version
			,p_init_msg_list	=>	OKC_API.G_FALSE
--			,x_return_status	=>	l_return_status
			,x_return_status	=>	x_return_status
			,x_msg_count		=>	x_msg_count
			,x_msg_data		=>	x_msg_data
			,p_crjv_tbl		=>	l_crjv_tbl
			,x_crjv_tbl		=>	l_x_crjv_tbl
			);
*/
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call After Logic Hook

		g_p_crj_rel_hdr_full_rec	:= x_crj_rel_hdr_full_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'A'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(x_crj_rel_hdr_full_rec);
*/
		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(2, '<END - OKC_K_REL_OBJS_PUB.CREATE_K_REL_OBJ -');
		END IF;
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);

		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
end create_k_rel_obj;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: create_quote_renews_contract
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE create_quote_renews_contract
		(-- create records required for a renews relationship between contract and quote
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
		,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
		,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
		,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
		) IS

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'create_quote_renews_k';
	l_return_status			VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_crj_rel_line_tbl			crj_rel_line_tbl_type;
	l_x_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_x_crj_rel_line_tbl		crj_rel_line_tbl_type;
	l_obj_type_code			jtf_objects_b.OBJECT_CODE%type;
	l_error_message			varchar2(1000);
	i						number;

	l_hdr_object_type			varchar2(30)	:= 'OKX_QUOTEHEAD';
	l_lne_object_type			varchar2(30)	:= 'OKX_QUOTELINE';
	l_relationship				varchar2(30)	:= 'QUOTERENEWSCONTRACT';

	G_UNEXPECTED_ERROR			CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION			exception;

	BEGIN
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(1, ' ');
   		okc_util.print_trace(1, '>START - OKC_K_REL_OBJS_PUB.CREATE_QUOTE_RENEWS_CONTRACT -');
		END IF;
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					substr(l_api_name,1,26)
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;
/*
		Call Before Logic Hook

		g_p_crj_rel_hdr_rec	:= p_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'B'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(p_crj_rel_hdr_rec);
*/
		/*
		format parms
		*/
		l_crj_rel_hdr_full_rec.jtot_object1_code	:= l_hdr_object_type;
		l_crj_rel_hdr_full_rec.line_jtot_object1_code:= l_lne_object_type;
		l_crj_rel_hdr_full_rec.rty_code		:= l_relationship;
		l_crj_rel_hdr_full_rec.chr_id			:= p_crj_rel_hdr_rec.chr_id;
		l_crj_rel_hdr_full_rec.object1_id1		:= p_crj_rel_hdr_rec.object1_id1;
		l_crj_rel_hdr_full_rec.object1_id2		:= p_crj_rel_hdr_rec.object1_id2;

		OKC_K_REL_OBJS_PUB.create_k_rel_obj
			(
			p_api_version		=> 1
			,p_init_msg_list	=> OKC_API.G_FALSE
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crj_rel_hdr_full_rec	=> l_crj_rel_hdr_full_rec
			,p_crj_rel_line_tbl	=> p_crj_rel_line_tbl
			,x_crj_rel_hdr_full_rec	=> l_x_crj_rel_hdr_full_rec
			,x_crj_rel_line_tbl	=> l_x_crj_rel_line_tbl
			);
		x_crj_rel_hdr_rec.chr_id:=l_x_crj_rel_hdr_full_rec.chr_id;
		x_crj_rel_hdr_rec.object1_id1:=l_x_crj_rel_hdr_full_rec.object1_id1;
		x_crj_rel_hdr_rec.object1_id2:=l_x_crj_rel_hdr_full_rec.object1_id2;
		x_crj_rel_line_tbl      :=l_x_crj_rel_line_tbl;
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call After Logic Hook

		g_p_crj_rel_hdr_rec	:= x_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'A'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(x_crj_rel_hdr_rec);
*/
		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(1, '<END - OKC_K_REL_OBJS_PUB.CREATE_QUOTE_RENEWS_CONTRACT -');
		END IF;
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						substr(l_api_name,1,26)
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
			OKC_API.set_message
				(
				G_APP_NAME
				,G_UNEXPECTED_ERROR
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
end create_quote_renews_contract;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: create_order_renews_contract
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE create_order_renews_contract
		(-- create records required for a renews relationship between contract and order
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
		,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
		,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
		,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
		) IS

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'create_order_renews_k';
	l_return_status			VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_crj_rel_line_tbl			crj_rel_line_tbl_type;
	l_x_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_x_crj_rel_line_tbl		crj_rel_line_tbl_type;
	l_obj_type_code			jtf_objects_b.OBJECT_CODE%type;
	l_error_message			varchar2(1000);
	i				  	     number;

	l_hdr_object_type			varchar2(30)	:= 'OKX_ORDERHEAD';
	l_lne_object_type			varchar2(30)	:= 'OKX_ORDERLINE';
	l_relationship				varchar2(30)	:= 'ORDERRENEWSCONTRACT';

	G_UNEXPECTED_ERROR			CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION			exception;

	BEGIN
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					substr(l_api_name,1,26)
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;
/*
		Call Before Logic Hook

		g_p_crj_rel_hdr_rec	:= p_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'B'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(p_crj_rel_hdr_rec);
*/
		/*
		format parms
		*/
		l_crj_rel_hdr_full_rec.jtot_object1_code	:= l_hdr_object_type;
		l_crj_rel_hdr_full_rec.line_jtot_object1_code	:= l_lne_object_type;
		l_crj_rel_hdr_full_rec.rty_code			:= l_relationship;
		l_crj_rel_hdr_full_rec.chr_id			:= p_crj_rel_hdr_rec.chr_id;
		l_crj_rel_hdr_full_rec.object1_id1		:= p_crj_rel_hdr_rec.object1_id1;
		l_crj_rel_hdr_full_rec.object1_id2		:= p_crj_rel_hdr_rec.object1_id2;

		OKC_K_REL_OBJS_PUB.create_k_rel_obj
			(
			p_api_version		=> 1
			,p_init_msg_list	=> OKC_API.G_FALSE
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crj_rel_hdr_full_rec	=> l_crj_rel_hdr_full_rec
			,p_crj_rel_line_tbl	=> p_crj_rel_line_tbl
			,x_crj_rel_hdr_full_rec	=> l_x_crj_rel_hdr_full_rec
			,x_crj_rel_line_tbl	=> l_x_crj_rel_line_tbl
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call After Logic Hook

		g_p_crj_rel_hdr_rec	:= x_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'A'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(x_crj_rel_hdr_rec);
*/
		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);

		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
			OKC_API.set_message
				(
				G_APP_NAME
				,G_UNEXPECTED_ERROR
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
end create_order_renews_contract;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: create_order_ships_contract
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE create_order_ships_contract
		(-- create records required for a ships relationship between contract and order
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
		,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
		,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
		,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
		) IS

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'create_order_ships_k';
	l_return_status			VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_crj_rel_line_tbl			crj_rel_line_tbl_type;
	l_x_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_x_crj_rel_line_tbl		crj_rel_line_tbl_type;
	l_obj_type_code			jtf_objects_b.OBJECT_CODE%type;
	l_error_message			varchar2(1000);
	i					     number;

	l_hdr_object_type			varchar2(30)	:= 'OKX_ORDERHEAD';
	l_lne_object_type			varchar2(30)	:= 'OKX_ORDERLINE';
	l_relationship				varchar2(30)	:= 'ORDERSHIPSCONTRACT';

	G_UNEXPECTED_ERROR		CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION			exception;

	BEGIN
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(1, ' ');
   		okc_util.print_trace(1, '>START - OKC_K_REL_OBJS_PUB.CREATE_ORDER_SHIPS_CONTRACT -');
		END IF;
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					substr(l_api_name,1,26)
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;
/*
		Call Before Logic Hook

		g_p_crj_rel_hdr_rec	:= p_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'B'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(p_crj_rel_hdr_rec);
*/
		/*
		format parms
		*/
		l_crj_rel_hdr_full_rec.jtot_object1_code	:= l_hdr_object_type;
		l_crj_rel_hdr_full_rec.line_jtot_object1_code	:= l_lne_object_type;
		l_crj_rel_hdr_full_rec.rty_code			:= l_relationship;
		l_crj_rel_hdr_full_rec.chr_id			:= p_crj_rel_hdr_rec.chr_id;
		l_crj_rel_hdr_full_rec.object1_id1		:= p_crj_rel_hdr_rec.object1_id1;
		l_crj_rel_hdr_full_rec.object1_id2		:= p_crj_rel_hdr_rec.object1_id2;

		OKC_K_REL_OBJS_PUB.create_k_rel_obj
			(
			p_api_version		=> 1
			,p_init_msg_list	=> OKC_API.G_FALSE
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crj_rel_hdr_full_rec	=> l_crj_rel_hdr_full_rec
			,p_crj_rel_line_tbl	=> p_crj_rel_line_tbl
			,x_crj_rel_hdr_full_rec	=> l_x_crj_rel_hdr_full_rec
			,x_crj_rel_line_tbl	=> l_x_crj_rel_line_tbl
			);
		x_crj_rel_hdr_rec.chr_id:=l_x_crj_rel_hdr_full_rec.chr_id;
		x_crj_rel_hdr_rec.object1_id1:=l_x_crj_rel_hdr_full_rec.object1_id1;
		x_crj_rel_hdr_rec.object1_id2:=l_x_crj_rel_hdr_full_rec.object1_id2;
		x_crj_rel_line_tbl      :=l_x_crj_rel_line_tbl;
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call After Logic Hook

		g_p_crj_rel_hdr_rec	:= x_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'A'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(x_crj_rel_hdr_rec);
*/
		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(1, '<END - OKC_K_REL_OBJS_PUB.CREATE_ORDER_SHIPS_CONTRACT -');
		END IF;
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);

		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
			OKC_API.set_message
				(
				G_APP_NAME
				,G_UNEXPECTED_ERROR
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
end create_order_ships_contract;


---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: create_core_orders_service
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE create_core_orders_service
	(-- create records required for a relationship between a service contract and a sales contract
 	 p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
        ,p_rel_type             IN              VARCHAR2
	,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
	,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
	,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
	,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
	) IS

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'create_core_orders_service_k';
	l_return_status			VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_crj_rel_line_tbl			crj_rel_line_tbl_type;
	l_x_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_x_crj_rel_line_tbl		crj_rel_line_tbl_type;
	l_obj_type_code			jtf_objects_b.OBJECT_CODE%type;
	l_error_message			varchar2(1000);
	i					     number;

	l_hdr_object_type			varchar2(30)	:= 'OKX_KHEAD';
	l_lne_object_type			varchar2(30)	:= 'OKX_KLINE';
	l_relationship				varchar2(30)	:= 'COREORDERSSERVICECONTRACT';

	G_UNEXPECTED_ERROR		CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION			exception;

	BEGIN
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(1, ' ');
   		okc_util.print_trace(1, '>START - OKC_K_REL_OBJS_PUB.CREATE_CORE_ORDERS_SERVICE -');
		END IF;
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					substr(l_api_name,1,26)
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;


                IF p_rel_type IS NOT NULL THEN      -- added new parameter to remove hardcoding of relationship
                   l_relationship := p_rel_type;
                END IF;

/*
		Call Before Logic Hook

		g_p_crj_rel_hdr_rec	:= p_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'B'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(p_crj_rel_hdr_rec);
*/
		/*
		format parms
		*/
		l_crj_rel_hdr_full_rec.jtot_object1_code	:= l_hdr_object_type;
		l_crj_rel_hdr_full_rec.line_jtot_object1_code	:= l_lne_object_type;
		l_crj_rel_hdr_full_rec.rty_code			:= l_relationship;
		l_crj_rel_hdr_full_rec.chr_id			:= p_crj_rel_hdr_rec.chr_id;
		l_crj_rel_hdr_full_rec.object1_id1		:= p_crj_rel_hdr_rec.object1_id1;
		l_crj_rel_hdr_full_rec.object1_id2		:= p_crj_rel_hdr_rec.object1_id2;

		OKC_K_REL_OBJS_PUB.create_k_rel_obj
			(
			p_api_version		=> 1
			,p_init_msg_list	=> OKC_API.G_FALSE
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crj_rel_hdr_full_rec	=> l_crj_rel_hdr_full_rec
			,p_crj_rel_line_tbl	=> p_crj_rel_line_tbl
			,x_crj_rel_hdr_full_rec	=> l_x_crj_rel_hdr_full_rec
			,x_crj_rel_line_tbl	=> l_x_crj_rel_line_tbl
			);
		x_crj_rel_hdr_rec.chr_id:=l_x_crj_rel_hdr_full_rec.chr_id;
		x_crj_rel_hdr_rec.object1_id1:=l_x_crj_rel_hdr_full_rec.object1_id1;
		x_crj_rel_hdr_rec.object1_id2:=l_x_crj_rel_hdr_full_rec.object1_id2;
		x_crj_rel_line_tbl      :=l_x_crj_rel_line_tbl;
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call After Logic Hook

		g_p_crj_rel_hdr_rec	:= x_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'A'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(x_crj_rel_hdr_rec);
*/
		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(1, '<END - OKC_K_REL_OBJS_PUB.CREATE_CORE_ORDERS_SERVICE -');
		END IF;
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);

		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
			OKC_API.set_message
				(
				G_APP_NAME
				,G_UNEXPECTED_ERROR
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
end create_core_orders_service;


---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name   : create_k_terms_for_quote
-- Description      :
-- Business Rules   :
-- Parameters       :
-- Version          : 1.0
-- End of comments
--
PROCEDURE create_k_terms_for_quote
		(-- create records required for specified relationship between contract and quote
           p_api_version       IN             NUMBER
          ,p_init_msg_list    IN             VARCHAR2
          ,x_return_status    OUT  NOCOPY    VARCHAR2
          ,x_msg_count        OUT  NOCOPY    NUMBER
	     ,x_msg_data         OUT  NOCOPY    VARCHAR2
	     ,p_crj_rel_hdr_rec  IN             crj_rel_hdr_rec_type
	     ,p_crj_rel_line_tbl IN             crj_rel_line_tbl_type
	     ,x_crj_rel_hdr_rec  OUT  NOCOPY    crj_rel_hdr_rec_type
		,x_crj_rel_line_tbl OUT  NOCOPY    crj_rel_line_tbl_type
	    ) IS

l_api_version       CONSTANT  NUMBER              := 1;
l_api_name          CONSTANT  VARCHAR2(30)        := 'create_k_neg_quote';
l_return_status               VARCHAR2(1)         := OKC_API.G_RET_STS_SUCCESS;
l_crj_rel_hdr_full_rec        crj_rel_hdr_full_rec_type;
l_crj_rel_line_tbl            crj_rel_line_tbl_type;
l_x_crj_rel_hdr_full_rec      crj_rel_hdr_full_rec_type;
l_x_crj_rel_line_tbl          crj_rel_line_tbl_type;
l_obj_type_code               jtf_objects_b.OBJECT_CODE%type;
l_error_message               varchar2(1000);
i                             number;

l_relationship                varchar2(30)   := 'CONTRACTISTERMSFORQUOTE';

BEGIN

  create_k_quote_rel(p_api_version      => 1
                    ,p_init_msg_list    => okc_api.g_false
                    ,x_return_status    => x_return_status
                    ,x_msg_count        => x_msg_count
                    ,x_msg_data         => x_msg_data
                    ,p_crj_rel_hdr_rec  => p_crj_rel_hdr_rec
                    ,p_crj_rel_line_tbl => p_crj_rel_line_tbl
                    ,p_rel_type         => l_relationship
                    ,x_crj_rel_hdr_rec  => x_crj_rel_hdr_rec
                    ,x_crj_rel_line_tbl => x_crj_rel_line_tbl
                    );

END create_k_terms_for_quote;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: create_k_quote_rel
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE create_k_quote_rel
		(-- create records required for specified relationship between contract and quote
		p_api_version		IN		     NUMBER
		,p_init_msg_list	IN		     VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crj_rel_hdr_rec	IN		     crj_rel_hdr_rec_type
		,p_crj_rel_line_tbl IN             crj_rel_line_tbl_type
		,p_rel_type         IN             OKC_K_REL_OBJS.RTY_CODE%TYPE
		,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
		,x_crj_rel_line_tbl OUT  NOCOPY    crj_rel_line_tbl_type
		) IS

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'create_k_quote_rel';
	l_return_status			VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_x_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_crj_rel_line_tbl            crj_rel_line_tbl_type;
	l_x_crj_rel_line_tbl          crj_rel_line_tbl_type;
	l_obj_type_code			jtf_objects_b.OBJECT_CODE%type;
	l_error_message			varchar2(1000);
	i					     number;

	l_hdr_object_type			varchar2(30)	:= 'OKX_QUOTEHEAD';
	l_lne_object_type             varchar2(30)   := 'OKX_QUOTELINE';
	-- l_relationship				varchar2(30)	:= 'CONTRACTISTERMSFORQUOTE';

	G_UNEXPECTED_ERROR		     CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION	exception;

	BEGIN
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					substr(l_api_name,1,26)
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;
		/*
		format parms
		*/
		l_crj_rel_hdr_full_rec.jtot_object1_code	 := l_hdr_object_type;
          l_crj_rel_hdr_full_rec.line_jtot_object1_code := l_lne_object_type;
		l_crj_rel_hdr_full_rec.rty_code			 := p_rel_type; -- l_relationship;
		l_crj_rel_hdr_full_rec.chr_id			:= p_crj_rel_hdr_rec.chr_id;
		l_crj_rel_hdr_full_rec.object1_id1		:= p_crj_rel_hdr_rec.object1_id1;
		l_crj_rel_hdr_full_rec.object1_id2		:= p_crj_rel_hdr_rec.object1_id2;

		OKC_K_REL_OBJS_PUB.create_k_rel_obj
			(
			p_api_version		    => 1
			,p_init_msg_list	    => OKC_API.G_FALSE
			,x_return_status	    => x_return_status
			,x_msg_count		    => x_msg_count
			,x_msg_data		    => x_msg_data
			,p_crj_rel_hdr_full_rec => l_crj_rel_hdr_full_rec
               ,p_crj_rel_line_tbl     => p_crj_rel_line_tbl
			,x_crj_rel_hdr_full_rec => l_x_crj_rel_hdr_full_rec
               ,x_crj_rel_line_tbl     => l_x_crj_rel_line_tbl
			);

		     x_crj_rel_hdr_rec.chr_id      := l_x_crj_rel_hdr_full_rec.chr_id;
		     x_crj_rel_hdr_rec.object1_id1 := l_x_crj_rel_hdr_full_rec.object1_id1;
		     x_crj_rel_hdr_rec.object1_id2 := l_x_crj_rel_hdr_full_rec.object1_id2;
			x_crj_rel_line_tbl            := l_x_crj_rel_line_tbl;

		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;

		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);

		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
			OKC_API.set_message
				(
				G_APP_NAME
				,G_UNEXPECTED_ERROR
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);

end create_k_quote_rel;


---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: create_contract_neg_quote
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE create_contract_neg_quote
		(-- create records required for a negotiates relationship between contract and quote
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
		,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
		,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
		,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
		) IS

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'create_k_neg_quote';
	l_return_status				VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_crj_rel_hdr_full_rec			crj_rel_hdr_full_rec_type;
	l_crj_rel_line_tbl			crj_rel_line_tbl_type;
	l_x_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_x_crj_rel_line_tbl			crj_rel_line_tbl_type;
	l_obj_type_code				jtf_objects_b.OBJECT_CODE%type;
	l_error_message				varchar2(1000);
	i					number;

	l_hdr_object_type			varchar2(30)	:= 'OKX_QUOTEHEAD';
	l_lne_object_type			varchar2(30)	:= 'OKX_QUOTELINE';
	l_relationship				varchar2(30)	:= 'CONTRACTNEGOTIATESQUOTE';

	G_UNEXPECTED_ERROR		CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION			exception;

	BEGIN
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					substr(l_api_name,1,26)
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;
/*
		Call Before Logic Hook

		g_p_crj_rel_hdr_rec	:= p_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'B'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(p_crj_rel_hdr_rec);
*/
		/*
		format parms
		*/
		l_crj_rel_hdr_full_rec.jtot_object1_code	:= l_hdr_object_type;
		l_crj_rel_hdr_full_rec.line_jtot_object1_code	:= l_lne_object_type;
		l_crj_rel_hdr_full_rec.rty_code			:= l_relationship;
		l_crj_rel_hdr_full_rec.chr_id			:= p_crj_rel_hdr_rec.chr_id;
		l_crj_rel_hdr_full_rec.object1_id1		:= p_crj_rel_hdr_rec.object1_id1;
		l_crj_rel_hdr_full_rec.object1_id2		:= p_crj_rel_hdr_rec.object1_id2;

		OKC_K_REL_OBJS_PUB.create_k_rel_obj
			(
			p_api_version		=> 1
			,p_init_msg_list	=> OKC_API.G_FALSE
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crj_rel_hdr_full_rec	=> l_crj_rel_hdr_full_rec
			,p_crj_rel_line_tbl	=> p_crj_rel_line_tbl
			,x_crj_rel_hdr_full_rec	=> l_x_crj_rel_hdr_full_rec
			,x_crj_rel_line_tbl	=> l_x_crj_rel_line_tbl
			);
		     x_crj_rel_hdr_rec.chr_id:=l_x_crj_rel_hdr_full_rec.chr_id;
		     x_crj_rel_hdr_rec.object1_id1:=l_x_crj_rel_hdr_full_rec.object1_id1;
		     x_crj_rel_hdr_rec.object1_id2:=l_x_crj_rel_hdr_full_rec.object1_id2;
		     x_crj_rel_line_tbl      :=l_x_crj_rel_line_tbl;

		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call After Logic Hook

		g_p_crj_rel_hdr_rec	:= x_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'A'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(x_crj_rel_hdr_rec);
*/
		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);

		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
			OKC_API.set_message
				(
				G_APP_NAME
				,G_UNEXPECTED_ERROR
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
end create_contract_neg_quote;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: create_quote_subject_contract
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE create_quote_subject_contract
		(-- create records required for a quote subject to contract
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
		,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
		,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
		,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
		) IS

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'create_quote_subject_k';
	l_return_status				VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_crj_rel_hdr_full_rec			crj_rel_hdr_full_rec_type;
	l_crj_rel_line_tbl			crj_rel_line_tbl_type;
	l_x_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_x_crj_rel_line_tbl			crj_rel_line_tbl_type;
	l_obj_type_code				jtf_objects_b.OBJECT_CODE%type;
	l_error_message				varchar2(1000);
	i					number;

	l_hdr_object_type			varchar2(30)	:= 'OKX_QUOTEHEAD';
	l_lne_object_type			varchar2(30)	:= 'OKX_QUOTELINE';
	l_relationship				varchar2(30)	:= 'QUOTESUBJECTCONTRACT';

	G_UNEXPECTED_ERROR		CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION			exception;

	BEGIN
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(1, ' ');
   		okc_util.print_trace(1, '>START - OKC_K_REL_OBJS_PUB.CREATE_QUOTE_SUBJECT_CONTRACT -');
		END IF;
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					substr(l_api_name,1,26)
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;
/*
		Call Before Logic Hook

		g_p_crj_rel_hdr_rec	:= p_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'B'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(p_crj_rel_hdr_rec);
*/
		/*
		format parms
		*/
		l_crj_rel_hdr_full_rec.jtot_object1_code	:= l_hdr_object_type;
		l_crj_rel_hdr_full_rec.line_jtot_object1_code	:= l_lne_object_type;
		l_crj_rel_hdr_full_rec.rty_code			:= l_relationship;
		l_crj_rel_hdr_full_rec.chr_id			:= p_crj_rel_hdr_rec.chr_id;
		l_crj_rel_hdr_full_rec.object1_id1		:= p_crj_rel_hdr_rec.object1_id1;
		l_crj_rel_hdr_full_rec.object1_id2		:= p_crj_rel_hdr_rec.object1_id2;

		OKC_K_REL_OBJS_PUB.create_k_rel_obj
			(
			p_api_version		=> 1
			,p_init_msg_list	=> OKC_API.G_FALSE
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crj_rel_hdr_full_rec	=> l_crj_rel_hdr_full_rec
			,p_crj_rel_line_tbl	=> p_crj_rel_line_tbl
			,x_crj_rel_hdr_full_rec	=> l_x_crj_rel_hdr_full_rec
			,x_crj_rel_line_tbl	=> l_x_crj_rel_line_tbl
			);
		x_crj_rel_hdr_rec.chr_id:=l_x_crj_rel_hdr_full_rec.chr_id;
		x_crj_rel_hdr_rec.object1_id1:=l_x_crj_rel_hdr_full_rec.object1_id1;
		x_crj_rel_hdr_rec.object1_id2:=l_x_crj_rel_hdr_full_rec.object1_id2;
		x_crj_rel_line_tbl      :=l_x_crj_rel_line_tbl;
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call After Logic Hook

		g_p_crj_rel_hdr_rec	:= x_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'A'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(x_crj_rel_hdr_rec);
*/
		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(1, '<END - OKC_K_REL_OBJS_PUB.CREATE_QUOTE_SUBJECT_CONTRACT -');
		END IF;
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);

		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
			OKC_API.set_message
				(
				G_APP_NAME
				,G_UNEXPECTED_ERROR
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
end create_quote_subject_contract;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: create_order_subject_contract
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE create_order_subject_contract
		(-- create records required for an order subject to contract
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
		,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
		,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
		,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
		) IS

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'create_order_subject_k';
	l_return_status			VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_crj_rel_line_tbl			crj_rel_line_tbl_type;
	l_x_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_x_crj_rel_line_tbl		crj_rel_line_tbl_type;
	l_obj_type_code			jtf_objects_b.OBJECT_CODE%type;
	l_error_message			varchar2(1000);
	i					     number;

	l_hdr_object_type			varchar2(30)	:= 'OKX_ORDERHEAD';
	l_lne_object_type			varchar2(30)	:= 'OKX_ORDERLINE';
	l_relationship				varchar2(30)	:= 'ORDERSUBJECTCONTRACT';

	G_UNEXPECTED_ERROR		CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION			exception;

	BEGIN
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					substr(l_api_name,1,26)
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;
/*
		Call Before Logic Hook

		g_p_crj_rel_hdr_rec	:= p_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'B'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(p_crj_rel_hdr_rec);
*/
		/*
		format parms
		*/
		l_crj_rel_hdr_full_rec.jtot_object1_code	:= l_hdr_object_type;
		l_crj_rel_hdr_full_rec.line_jtot_object1_code	:= l_lne_object_type;
		l_crj_rel_hdr_full_rec.rty_code			:= l_relationship;
		l_crj_rel_hdr_full_rec.chr_id			:= p_crj_rel_hdr_rec.chr_id;
		l_crj_rel_hdr_full_rec.object1_id1		:= p_crj_rel_hdr_rec.object1_id1;
		l_crj_rel_hdr_full_rec.object1_id2		:= p_crj_rel_hdr_rec.object1_id2;

		OKC_K_REL_OBJS_PUB.create_k_rel_obj
			(
			p_api_version		=> 1
			,p_init_msg_list	=> OKC_API.G_FALSE
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crj_rel_hdr_full_rec	=> l_crj_rel_hdr_full_rec
			,p_crj_rel_line_tbl	=> p_crj_rel_line_tbl
			,x_crj_rel_hdr_full_rec	=> l_x_crj_rel_hdr_full_rec
			,x_crj_rel_line_tbl	=> l_x_crj_rel_line_tbl
			);
		x_crj_rel_hdr_rec.chr_id:=l_x_crj_rel_hdr_full_rec.chr_id;
		x_crj_rel_hdr_rec.object1_id1:=l_x_crj_rel_hdr_full_rec.object1_id1;
		x_crj_rel_hdr_rec.object1_id2:=l_x_crj_rel_hdr_full_rec.object1_id2;
		x_crj_rel_line_tbl      :=l_x_crj_rel_line_tbl;
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call After Logic Hook

		g_p_crj_rel_hdr_rec	:= x_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'A'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(x_crj_rel_hdr_rec);
*/
		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);

		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
			OKC_API.set_message
				(
				G_APP_NAME
				,G_UNEXPECTED_ERROR
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
end create_order_subject_contract;


---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: create_contract_serv_order
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE create_contract_serv_order
		(-- create records required for an order subject to contract
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
		,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
		,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
		,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
		) IS

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'create_k_serv_order';
	l_return_status			VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_crj_rel_line_tbl			crj_rel_line_tbl_type;
	l_x_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;
	l_x_crj_rel_line_tbl		crj_rel_line_tbl_type;
	l_obj_type_code			jtf_objects_b.OBJECT_CODE%type;
	l_error_message			varchar2(1000);
	i					     number;

	l_hdr_object_type			varchar2(30)	:= 'OKX_ORDERHEAD';
	l_lne_object_type			varchar2(30)	:= 'OKX_ORDERLINE';
	l_relationship				varchar2(30)	:= 'CONTRACTSERVICESORDER';

	G_UNEXPECTED_ERROR		     CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION			exception;

	BEGIN
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					substr(l_api_name,1,26)
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;
/*
		Call Before Logic Hook

		g_p_crj_rel_hdr_rec	:= p_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'B'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(p_crj_rel_hdr_rec);
*/
		/*
		format parms
		*/
		l_crj_rel_hdr_full_rec.jtot_object1_code	:= l_hdr_object_type;
		l_crj_rel_hdr_full_rec.line_jtot_object1_code	:= l_lne_object_type;
		l_crj_rel_hdr_full_rec.rty_code			:= l_relationship;
		l_crj_rel_hdr_full_rec.chr_id			:= p_crj_rel_hdr_rec.chr_id;
		l_crj_rel_hdr_full_rec.object1_id1		:= p_crj_rel_hdr_rec.object1_id1;
		l_crj_rel_hdr_full_rec.object1_id2		:= p_crj_rel_hdr_rec.object1_id2;

		OKC_K_REL_OBJS_PUB.create_k_rel_obj
			(
			p_api_version		=> 1
			,p_init_msg_list	=> OKC_API.G_FALSE
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crj_rel_hdr_full_rec	=> l_crj_rel_hdr_full_rec
			,p_crj_rel_line_tbl	=> p_crj_rel_line_tbl
			,x_crj_rel_hdr_full_rec	=> l_x_crj_rel_hdr_full_rec
			,x_crj_rel_line_tbl	=> l_x_crj_rel_line_tbl
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call After Logic Hook

		g_p_crj_rel_hdr_rec	:= x_crj_rel_hdr_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'A'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(x_crj_rel_hdr_rec);
*/
		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);

		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
			OKC_API.set_message
				(
				G_APP_NAME
				,G_UNEXPECTED_ERROR
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
end create_contract_serv_order;

/*  end added code
*/

  -------------------------------------
  -- create_row for:OKC_K_REL_OBJS_V --
  -------------------------------------
  PROCEDURE create_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type,
    x_crjv_rec                     OUT NOCOPY crjv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_create_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crjv_rec                     crjv_rec_type := p_crjv_rec;
    l_def_crjv_rec                 crjv_rec_type;
    l_crj_rec                      crj_rec_type;
    lx_crj_rec                     crj_rec_type;
    l_x_crjv_rec		   		crjv_rec_type;

    -----------------------------------------
    -- Set_Attributes for:OKC_K_REL_OBJS_V --
    -----------------------------------------
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(3, ' ');
       okc_util.print_trace(3, '>START - OKC_K_REL_OBJS_PUB.CREATE_ROW -');
    END IF;
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------------
    -- Call the create_row for each child record
    --------------------------------------------
		/*
  		create_row
		*/
		OKC_CRJ_PVT.insert_row
			(
			p_api_version		=> 1
			,p_init_msg_list	=> OKC_API.G_FALSE
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crjv_rec		=> p_crjv_rec
			,x_crjv_rec		=> x_crjv_rec
			)
		;
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(3, '<END - OKC_K_REL_OBJS_PUB.CREATE_ROW -');
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END create_row;
  ----------------------------------------
  -- PL/SQL TBL create_row for:CRJV_TBL --
  ----------------------------------------
  PROCEDURE create_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type,
    x_crjv_tbl                     OUT NOCOPY crjv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_create_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_x_crjv_rec		   crjv_rec_type;
    l_x_crjv_tbl		   crjv_tbl_type;
    i                              NUMBER := 0;
  BEGIN
/*  start added code
*/
	    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	                                              G_PKG_NAME,
	                                              p_init_msg_list,
	                                              l_api_version,
	                                              p_api_version,
	                                              '_PUB',
	                                              x_return_status);
	    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	      RAISE OKC_API.G_EXCEPTION_ERROR;
	    END IF;
		/*  create_row
		*/
		OKC_CRJ_PVT.insert_row
			(
			p_api_version		=> 1
			,p_init_msg_list	=> OKC_API.G_FALSE
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crjv_tbl		=> p_crjv_tbl
			,x_crjv_tbl		=> x_crjv_tbl
			)
		;
	    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	      RAISE OKC_API.G_EXCEPTION_ERROR;
	    END IF;
	    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
/*  end added code
*/
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END create_row;

  -----------------------------------
  -- lock_row for:OKC_K_REL_OBJS_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crj_rec                      crj_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

	/* lock_row
	*/
	OKC_CRJ_PVT.lock_row
		(
		p_api_version		=> p_api_version
		,p_init_msg_list	=> p_init_msg_list
		,x_return_status	=> x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,p_crjv_rec		=> p_crjv_rec
		);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:CRJV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
	/* lock_rows
	*/
	OKC_CRJ_PVT.lock_row
		(
		p_api_version		=> p_api_version
		,p_init_msg_list	=> p_init_msg_list
		,x_return_status	=> x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,p_crjv_tbl		=> p_crjv_tbl
		);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END lock_row;

  -------------------------------------
  -- update_row for:OKC_K_REL_OBJS_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type,
    x_crjv_rec                     OUT NOCOPY crjv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crjv_rec                     crjv_rec_type := p_crjv_rec;
    l_def_crjv_rec                 crjv_rec_type;
    l_crj_rec                      crj_rec_type;
    lx_crj_rec                     crj_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
	/* update_row
	*/
	OKC_CRJ_PVT.update_row
		(
		p_api_version		=> p_api_version
		,p_init_msg_list		=> p_init_msg_list
		,x_return_status		=> x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,p_crjv_rec		=> p_crjv_rec
		,x_crjv_rec		=> x_crjv_rec
		);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    end if;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:CRJV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type,
    x_crjv_tbl                     OUT NOCOPY crjv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
	/* update_rows
	*/
	OKC_CRJ_PVT.update_row
		(
		p_api_version		=> p_api_version
		,p_init_msg_list	=> p_init_msg_list
		,x_return_status	=> x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,p_crjv_tbl		=> p_crjv_tbl
		,x_crjv_tbl		=> x_crjv_tbl
		);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END update_row;

  -------------------------------------
  -- delete_row for:OKC_K_REL_OBJS_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crjv_rec                     crjv_rec_type := p_crjv_rec;
    l_crj_rec                      crj_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
	/* delete_row
	*/
	OKC_CRJ_PVT.delete_row
		(
		p_api_version		=> p_api_version
		,p_init_msg_list	=> p_init_msg_list
		,x_return_status	=> x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,p_crjv_rec		=> p_crjv_rec
		);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END delete_row;
  ----------------------------------------
  -- PL/SQL TBL delete_row for:CRJV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
	/* delete_rows
	*/
	OKC_CRJ_PVT.delete_row
		(
		p_api_version		=> p_api_version
		,p_init_msg_list	=> p_init_msg_list
		,x_return_status	=> x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,p_crjv_tbl		=> p_crjv_tbl
		);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END delete_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKC_K_REL_OBJS_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crjv_rec                     crjv_rec_type := p_crjv_rec;
    l_crj_rec                      crj_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
	/* validate_row
	*/
	OKC_CRJ_PVT.validate_row
		(
		p_api_version		=> p_api_version
		,p_init_msg_list	=> p_init_msg_list
		,x_return_status	=> x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,p_crjv_rec		=> p_crjv_rec
		);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:CRJV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
	/* validate_rows
	*/
	OKC_CRJ_PVT.validate_row
		(
		p_api_version		=> p_api_version
		,p_init_msg_list	=> p_init_msg_list
		,x_return_status	=> x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,p_crjv_tbl		=> p_crjv_tbl
		);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: quote_is_renewal
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE quote_is_renewal
		(
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crjv_rec		IN		crjv_rec_type
		,x_true_false		out	nocopy	varchar2
		) is

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'quote_is_renewal';
	l_return_status				VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_true_false				boolean			:= false;
	i					number;

	G_UNEXPECTED_ERROR		CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION			exception;

	BEGIN
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					substr(l_api_name,1,26)
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call Before Logic Hook

		g_p_crj_rel_rec	:= p_...;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'B'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(p_...);
*/
		/* is quote for renewal?
		*/
		OKC_CRJ_PVT.quote_is_renewal
			(
			p_api_version		=> p_api_version
			,p_init_msg_list	=> p_init_msg_list
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crjv_rec		=> p_crjv_rec
			,x_true_false		=> l_true_false
			);

		x_true_false	:= okc_api.g_false;
		if	(
				l_true_false
			) then
			x_true_false	:= okc_api.g_true;
		end if;
/*
		Call After Logic Hook

		g_p_crj_rel_rec	:= x_...;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'A'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(x_...);
*/
		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);

		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
end quote_is_renewal;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: order_is_renewal
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE order_is_renewal
		(
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crjv_rec		IN		crjv_rec_type
		,x_true_false		out	nocopy	varchar2
		) is

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'order_is_renewal';
	l_return_status				VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_true_false				boolean			:= false;
	i					number;

	G_UNEXPECTED_ERROR		CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION			exception;

	BEGIN
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					substr(l_api_name,1,26)
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call Before Logic Hook

		g_p_crj_rel_rec	:= p_...;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'B'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(p_...);
*/
		/* is order for renewal?
		*/
		OKC_CRJ_PVT.order_is_renewal
			(
			p_api_version		=> p_api_version
			,p_init_msg_list	=> p_init_msg_list
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crjv_rec		=> p_crjv_rec
			,x_true_false		=> l_true_false
			);

		x_true_false	:= okc_api.g_false;
		if	(
				l_true_false
			) then
			x_true_false	:= okc_api.g_true;
		end if;
/*
		Call After Logic Hook

		g_p_crj_rel_rec	:= x_...;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'A'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(x_...);
*/
		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);

		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
end order_is_renewal;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: quote_is_subject
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE quote_is_subject
		(
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crjv_rec		IN		crjv_rec_type
		,x_true_false		out	nocopy	varchar2
		) is

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'quote_is_subject';
	l_return_status				VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_true_false				boolean			:= false;
	i					number;

	G_UNEXPECTED_ERROR		CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION			exception;

	BEGIN
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					substr(l_api_name,1,26)
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call Before Logic Hook

		g_p_crj_rel_rec	:= p_...;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'B'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(p_...);
*/
		/* is quote subject?
		*/
		OKC_CRJ_PVT.quote_is_subject
			(
			p_api_version		=> p_api_version
			,p_init_msg_list	=> p_init_msg_list
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crjv_rec		=> p_crjv_rec
			,x_true_false		=> l_true_false
			);

		x_true_false	:= okc_api.g_false;
		if	(
				l_true_false
			) then
			x_true_false	:= okc_api.g_true;
		end if;
/*
		Call After Logic Hook

		g_p_crj_rel_rec	:= x_...;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'A'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(x_...);
*/
		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);

		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
end quote_is_subject;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: order_is_subject
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE order_is_subject
		(
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crjv_rec		IN		crjv_rec_type
		,x_true_false		out	nocopy	varchar2
		) is

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'order_is_subject';
	l_return_status				VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_true_false				boolean			:= false;
	i					number;

	G_UNEXPECTED_ERROR		CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION			exception;

	BEGIN
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					substr(l_api_name,1,26)
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call Before Logic Hook

		g_p_crj_rel_rec	:= p_...;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'B'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(p_...);
*/
		/* is order subject?
		*/
		OKC_CRJ_PVT.order_is_subject
			(
			p_api_version		=> p_api_version
			,p_init_msg_list	=> p_init_msg_list
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crjv_rec		=> p_crjv_rec
			,x_true_false		=> l_true_false
			);

		x_true_false	:= okc_api.g_false;
		if	(
				l_true_false
			) then
			x_true_false	:= okc_api.g_true;
		end if;
/*
		Call After Logic Hook

		g_p_crj_rel_rec	:= x_...;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'A'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(x_...);
*/
		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);

		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
end order_is_subject;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: quote_contract_is_ordered
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE quote_contract_is_ordered
		(--
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crjv_rec		IN		crjv_rec_type
		,x_true_false		out	nocopy	varchar2
		) IS

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'quote_k_is_ordered';
	l_return_status				VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_true_false				boolean			:= false;
	i					number;

	G_UNEXPECTED_ERROR		CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION			exception;

	BEGIN
		l_return_status	:= OKC_API.START_ACTIVITY
					(
					substr(l_api_name,1,26)
					,p_init_msg_list
					,'_PUB'
					,x_return_status
					);
		IF	(-- unexpected error
				l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				l_return_status = OKC_API.G_RET_STS_ERROR
			) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;

/*
		Call Before Logic Hook

		g_p_crj_rel_rec	:= p_crjv_rec;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'B'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(p_crjv_rec;
*/
		/* is quote contract ordered?
		*/
		OKC_CRJ_PVT.quote_contract_is_ordered
			(
			p_api_version		=> p_api_version
			,p_init_msg_list	=> p_init_msg_list
			,x_return_status	=> x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,p_crjv_rec		=> p_crjv_rec
			,x_true_false		=> l_true_false
			);

		x_true_false	:= okc_api.g_false;
		if	(
				l_true_false
			) then
			x_true_false	:= okc_api.g_true;
		end if;
/*
		Call After Logic Hook

		g_p_crj_rel_rec	:= x_...;
		okc_util.call_user_hook
			(
			x_return_status
			,g_pkg_name
			,l_api_name
			,'A'
			);
		IF	(-- unexpected error
				x_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF	(-- standard error
				x_return_status	= OKC_API.G_RET_STS_ERROR
			) THEN
			raise OKC_API.G_EXCEPTION_ERROR;
		END IF;
		reset(x_...);
*/
		OKC_API.END_ACTIVITY
				(
				x_msg_count
				,x_msg_data
				);
	EXCEPTION
		WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
		WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OKC_API.G_RET_STS_UNEXP_ERROR'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);

		WHEN	OTHERS	THEN
			x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
						(
						l_api_name
						,G_PKG_NAME
						,'OTHERS'
						,x_msg_count
						,x_msg_data
						,'_PUB'
						);
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
end quote_contract_is_ordered;

END OKC_K_REL_OBJS_PUB;

/
