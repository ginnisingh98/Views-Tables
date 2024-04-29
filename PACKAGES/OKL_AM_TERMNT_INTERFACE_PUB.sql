--------------------------------------------------------
--  DDL for Package OKL_AM_TERMNT_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_TERMNT_INTERFACE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPTIFS.pls 115.3 2003/03/11 17:26:56 rabhupat noship $ */

---------------------------------------------------------------------------
   --  GLOBAL CONSTANTS
---------------------------------------------------------------------------

   G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_TERMNT_INTERFACE_PUB';
   G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
   G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

PROCEDURE termination_interface(err_buf   OUT NOCOPY VARCHAR2,
                                ret_code  OUT NOCOPY NUMBER);



END OKL_AM_TERMNT_INTERFACE_PUB;

 

/
