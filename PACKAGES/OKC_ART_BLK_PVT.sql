--------------------------------------------------------
--  DDL for Package OKC_ART_BLK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ART_BLK_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVARTBLKS.pls 120.0 2005/05/25 19:28:00 appldev noship $ */

TYPE ver_details_rec is RECORD(
	org_id			OKC_ARTICLES_ALL.ORG_ID%TYPE,
	ver_id			OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE,
	global_yn		OKC_ARTICLE_VERSIONS.GLOBAL_YN%TYPE,
	adoption_type	OKC_ARTICLE_VERSIONS.ADOPTION_TYPE%TYPE
);
TYPE ver_details_tbl_type is TABLE OF ver_details_rec;

TYPE validation_rec IS RECORD (
	error_code			VARCHAR2(250), -- contains some pre-defined error codes
	error_message		VARCHAR2(2000), -- contains a detail error message
	article_id			OKC_ARTICLES_ALL.ARTICLE_ID%TYPE,
	article_version_id	OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE,
	article_title		OKC_ARTICLES_ALL.ARTICLE_TITLE%TYPE
 );

TYPE validation_tbl_type IS TABLE OF validation_rec INDEX BY BINARY_INTEGER;

TYPE num_tbl_type		IS TABLE OF NUMBER;
TYPE date_tbl_type		IS TABLE OF DATE;
TYPE varchar_tbl_type	IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;


---------------- Private APIs BEGIN  ----------------------------
FUNCTION get_uniq_id RETURN NUMBER;


PROCEDURE validate_article_versions_blk(
	p_api_version			IN	NUMBER ,
  	p_init_msg_list			IN	VARCHAR2    DEFAULT FND_API.G_FALSE ,
	p_commit				IN	VARCHAR2    DEFAULT FND_API.G_FALSE ,
	p_validation_level		IN	NUMBER	    DEFAULT FND_API.G_VALID_LEVEL_FULL ,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
	x_msg_count				OUT	NOCOPY NUMBER ,
	x_msg_data				OUT	NOCOPY VARCHAR2 ,

	p_org_id				IN	NUMBER ,
	p_art_ver_tbl			IN	num_tbl_type ,
    p_id                    IN  NUMBER DEFAULT NULL,
    x_qa_return_status      OUT NOCOPY VARCHAR2,
	x_validation_results	OUT	NOCOPY validation_tbl_type );


PROCEDURE auto_adopt_articles_blk(
	p_api_version			IN	NUMBER ,
  	p_init_msg_list			IN	VARCHAR2    DEFAULT FND_API.G_FALSE ,
	p_commit				IN	VARCHAR2    DEFAULT FND_API.G_FALSE ,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
	x_msg_count				OUT	NOCOPY NUMBER ,
	x_msg_data				OUT	NOCOPY VARCHAR2 ,

	p_id        			IN	NUMBER);

PROCEDURE pending_approval_blk(
	p_api_version			IN	NUMBER ,
  	p_init_msg_list			IN	VARCHAR2 DEFAULT FND_API.G_FALSE ,
	p_commit				IN	VARCHAR2 DEFAULT FND_API.G_FALSE ,
	p_validation_level		IN	NUMBER	DEFAULT FND_API.G_VALID_LEVEL_FULL ,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
	x_msg_count				OUT	NOCOPY NUMBER ,
	x_msg_data				OUT	NOCOPY VARCHAR2 ,

	p_org_id				IN	NUMBER ,
	p_art_ver_tbl			IN	num_tbl_type ,
	x_validation_results	OUT	NOCOPY validation_tbl_type );


PROCEDURE approve_blk(
	p_api_version			IN	NUMBER ,
  	p_init_msg_list			IN	VARCHAR2    DEFAULT FND_API.G_FALSE ,
	p_commit				IN	VARCHAR2    DEFAULT FND_API.G_FALSE ,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
	x_msg_count				OUT	NOCOPY NUMBER ,
	x_msg_data				OUT	NOCOPY VARCHAR2 ,

	p_org_id				IN	NUMBER ,
	p_art_ver_tbl			IN	num_tbl_type ,
	x_validation_results	OUT	NOCOPY validation_tbl_type );


PROCEDURE reject_blk(
	p_api_version			IN	NUMBER ,
  	p_init_msg_list			IN	VARCHAR2    DEFAULT FND_API.G_FALSE ,
	p_commit				IN	VARCHAR2    DEFAULT FND_API.G_FALSE ,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
	x_msg_count				OUT	NOCOPY NUMBER ,
	x_msg_data				OUT	NOCOPY VARCHAR2 ,

	p_org_id				IN	NUMBER ,
	p_art_ver_tbl			IN	num_tbl_type ,
	x_validation_results	OUT	NOCOPY validation_tbl_type );


---------------- Private APIs END  ------------------------------


END OKC_ART_BLK_PVT;

 

/
