--------------------------------------------------------
--  DDL for Package CZ_APC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_APC_GRP" AUTHID CURRENT_USER AS
/*	$Header: czapcgs.pls 120.0 2005/06/28 14:00:53 appldev noship $		*/

  FUNCTION Is_Supported_By_CZ
    (p_attr IN EGO_EXT_FWK_PUB.EGO_ATTR_USG_METADATA) RETURN BOOLEAN;

END CZ_APC_GRP;

 

/
