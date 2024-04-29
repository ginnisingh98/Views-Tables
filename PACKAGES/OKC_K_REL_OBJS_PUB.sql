--------------------------------------------------------
--  DDL for Package OKC_K_REL_OBJS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_REL_OBJS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPCRJS.pls 120.0 2005/05/25 18:38:20 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
/*  start added code
*/
/*
JTF object types (jtf_objects_vl)
----------------
OKX_ORDERHEAD	=> 'Sales Order'
OKX_ORDERLINE	=> 'Sales Order Line'
OKX_QUOTEHEAD	=> 'Quote'
OKX_QUOTELINE	=> 'Quote Line'
OKX_QUOTELINED	=> 'Quote Line Detail'

Relationships (fnd_lookups, type='OKC_REL_OBJ')
----------------
'QUOTESUBJECTCONTRACT'
'ORDERSUBJECTCONTRACT'
NB.	below read as 'obj1 verb obj2'
	where obj1 is result of verb on obj2
'QUOTERENEWSCONTRACT'
'ORDERRENEWSCONTRACT'
'ORDERSHIPSCONTRACT'
'CONTRACTNEGOTIATESQUOTE'
'CONTRACTISTERMSFORQUOTE'
'CONTRACTSERVICESORDER'
*/
TYPE	crj_rel_hdr_rec_type	IS RECORD -- all contract and object (and line) data for rel. create
/*		(
		chr_id			NUMBER					:= OKC_API.G_MISS_NUM
		,object1_id1		OKC_K_REL_OBJS.OBJECT1_ID1%TYPE		:= OKC_API.G_MISS_CHAR
		,object1_id2		OKC_K_REL_OBJS.OBJECT1_ID2%TYPE		:= OKC_API.G_MISS_CHAR
		)
*/		(
		chr_id			NUMBER
		,object1_id1		OKC_K_REL_OBJS.OBJECT1_ID1%TYPE
		,object1_id2		OKC_K_REL_OBJS.OBJECT1_ID2%TYPE
		)
;
g_miss_crj_rel_hdr_rec	crj_rel_hdr_rec_type;

TYPE	crj_rel_hdr_full_rec_type	IS RECORD -- all contract and object (and line) data for rel. create
/*		(
		chr_id			NUMBER					:= OKC_API.G_MISS_NUM
		,object1_id1		OKC_K_REL_OBJS.OBJECT1_ID1%TYPE		:= OKC_API.G_MISS_CHAR
		,object1_id2		OKC_K_REL_OBJS.OBJECT1_ID2%TYPE		:= OKC_API.G_MISS_CHAR
		,jtot_object1_code	OKC_K_REL_OBJS.jtot_object1_code%TYPE	:= OKC_API.G_MISS_CHAR
		,line_jtot_object1_code	OKC_K_REL_OBJS.jtot_object1_code%TYPE	:= OKC_API.G_MISS_CHAR
		,rty_code		OKC_K_REL_OBJS.RTY_CODE%TYPE		:= OKC_API.G_MISS_CHAR
		)
*/		(
		chr_id			NUMBER
		,object1_id1		OKC_K_REL_OBJS.OBJECT1_ID1%TYPE
		,object1_id2		OKC_K_REL_OBJS.OBJECT1_ID2%TYPE
		,jtot_object1_code	OKC_K_REL_OBJS.jtot_object1_code%TYPE
		,line_jtot_object1_code	OKC_K_REL_OBJS.jtot_object1_code%TYPE
		,rty_code		OKC_K_REL_OBJS.RTY_CODE%TYPE
		)
;
g_miss_crj_rel_hdr_full_rec	crj_rel_hdr_full_rec_type;

TYPE	crj_rel_line_rec_type	IS RECORD -- of contract and related object lines
/*		(
		cle_id			NUMBER					:= OKC_API.G_MISS_NUM
		,object1_id1		OKC_K_REL_OBJS.OBJECT1_ID1%TYPE		:= OKC_API.G_MISS_CHAR
		,object1_id2		OKC_K_REL_OBJS.OBJECT1_ID2%TYPE		:= OKC_API.G_MISS_CHAR
		)
*/		(
		cle_id			NUMBER
		,object1_id1		OKC_K_REL_OBJS.OBJECT1_ID1%TYPE
		,object1_id2		OKC_K_REL_OBJS.OBJECT1_ID2%TYPE
		)
;
g_miss_crj_rel_line_rec	crj_rel_line_rec_type;
TYPE	crj_rel_line_tbl_type	IS TABLE OF	crj_rel_line_rec_type	INDEX BY BINARY_INTEGER;

g_p_crj_rel_hdr_full_rec		crj_rel_hdr_full_rec_type;

SUBTYPE crj_rec_type	IS OKC_CRJ_PVT.crj_rec_type;
SUBTYPE crj_tbl_type	is OKC_CRJ_PVT.crj_tbl_type;
SUBTYPE crjv_rec_type	IS OKC_CRJ_PVT.crjv_rec_type;
SUBTYPE crjv_tbl_type	IS OKC_CRJ_PVT.crjv_tbl_type;
/*  end added code
*/
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_K_REL_OBJS_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
/*  start added
*/

PROCEDURE create_quote_renews_contract
	(-- create records required for a renews relationship between contract and quote
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT	OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
	,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
	,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
	,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
	)
;

PROCEDURE create_order_renews_contract
	(-- create records required for a renews relationship between contract and quote
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT	OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
	,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
	,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
	,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
	)
;

PROCEDURE create_contract_neg_quote
	(-- create records required for a negotiates relationship between contract and quote
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT	OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
	,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
	,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
	,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
	)
;

PROCEDURE create_k_terms_for_quote
	(-- create records required for a terms relationship between contract and quote
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT	OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
	,p_crj_rel_line_tbl IN        crj_rel_line_tbl_type
	,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
	,x_crj_rel_line_tbl OUT  NOCOPY    crj_rel_line_tbl_type
	)
;


PROCEDURE create_k_quote_rel
	(-- create records required for relationship between contract and quote
	 p_api_version		IN		     NUMBER
	,p_init_msg_list	IN		     VARCHAR2	DEFAULT	OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crj_rel_hdr_rec	IN		     crj_rel_hdr_rec_type
	,p_crj_rel_line_tbl IN             crj_rel_line_tbl_type
	,p_rel_type         IN             OKC_K_REL_OBJS.RTY_CODE%TYPE
	,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
	,x_crj_rel_line_tbl OUT  NOCOPY    crj_rel_line_tbl_type
	);


PROCEDURE create_order_ships_contract
	(-- create records required for a ships relationship between contract and order
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT	OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
	,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
	,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
	,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
	)
;


PROCEDURE create_core_orders_service
	(-- create records required for a relationship between a service contract and a sales contract
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT	OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
        ,p_rel_type             IN              VARCHAR2
	,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
	,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
	,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
	,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
	)
;



PROCEDURE create_quote_subject_contract
	(-- create records required for a quote subject to contract
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT	OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
	,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
	,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
	,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
	)
;

PROCEDURE create_order_subject_contract
	(-- create records required for an order subject to contract
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT	OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
	,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
	,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
	,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
	)
;

PROCEDURE create_contract_serv_order
	(-- create records required for a contract services order
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT	OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crj_rel_hdr_rec	IN		crj_rel_hdr_rec_type
	,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
	,x_crj_rel_hdr_rec	OUT	NOCOPY	crj_rel_hdr_rec_type
	,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
	)
;

PROCEDURE create_k_rel_obj
	(-- create all the records required for a relationship between contract and quote, order etc.
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT	OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crj_rel_hdr_full_rec	IN		crj_rel_hdr_full_rec_type
	,p_crj_rel_line_tbl	IN		crj_rel_line_tbl_type
	,x_crj_rel_hdr_full_rec	OUT	NOCOPY	crj_rel_hdr_full_rec_type
	,x_crj_rel_line_tbl	OUT	NOCOPY	crj_rel_line_tbl_type
	)
;

/*  end added
*/
  PROCEDURE create_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type,
    x_crjv_rec                     OUT NOCOPY crjv_rec_type);

  PROCEDURE create_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type,
    x_crjv_tbl                     OUT NOCOPY crjv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type);
/*
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type,
    x_crjv_rec                     OUT NOCOPY crjv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type,
    x_crjv_tbl                     OUT NOCOPY crjv_tbl_type);
*/
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type);

  PROCEDURE quote_is_renewal
	(
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crjv_rec		IN		crjv_rec_type
	,x_true_false		out	nocopy	varchar2
	);

  PROCEDURE order_is_renewal
	(
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crjv_rec		IN		crjv_rec_type
	,x_true_false		out	nocopy	varchar2
	);

  PROCEDURE quote_is_subject
	(
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crjv_rec		IN		crjv_rec_type
	,x_true_false		out	nocopy	varchar2
	);

  PROCEDURE order_is_subject
	(
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crjv_rec		IN		crjv_rec_type
	,x_true_false		out	nocopy	varchar2
	);

  PROCEDURE quote_contract_is_ordered
	(
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crjv_rec		IN		crjv_rec_type
	,x_true_false		out	nocopy	varchar2
	);

END OKC_K_REL_OBJS_PUB;

 

/
