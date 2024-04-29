--------------------------------------------------------
--  DDL for Package OKC_CRQUOTE_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CRQUOTE_ASMBLR_PVT" AUTHID CURRENT_USER AS
/*$Header: OKCRCQKS.pls 120.0 2005/05/25 23:04:42 appldev noship $ */

g_pkg_name CONSTANT varchar2(100) := 'OKC_CRQUOTE_ASMBLR_PVT';


PROCEDURE acn_assemble(
  p_api_version       IN NUMBER,
  p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2,

  p_contract_id       IN NUMBER,
  p_quote_number      IN NUMBER );


END OKC_CRQUOTE_ASMBLR_PVT;

 

/
