--------------------------------------------------------
--  DDL for Package OZF_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_VENDORMERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: ozfvmrgs.pls 120.1 2005/08/30 07:11:02 sshivali noship $ */

	PROCEDURE Merge_Vendor
	(    p_api_version			IN            NUMBER
		,p_init_msg_list		IN            VARCHAR2 default FND_API.G_FALSE
		,p_commit				IN            VARCHAR2 default FND_API.G_FALSE
		,p_validation_level		IN            NUMBER   default FND_API.G_VALID_LEVEL_FULL
		,p_return_status		OUT	NOCOPY    VARCHAR2
		,p_msg_count			OUT	NOCOPY    NUMBER
		,p_msg_data			    OUT	NOCOPY    VARCHAR2
		,p_vendor_id			IN            NUMBER
		,p_dup_vendor_id		IN            NUMBER
		,p_vendor_site_id		IN            NUMBER
		,p_dup_vendor_site_id   IN            NUMBER
		,p_party_id				IN            NUMBER
		,p_dup_party_id		    IN            NUMBER
		,p_party_site_id		IN            NUMBER
		,p_dup_party_site_id    IN            NUMBER
	);

END OZF_VENDORMERGE_GRP;

 

/
