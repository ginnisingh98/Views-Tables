--------------------------------------------------------
--  DDL for Package OKC_CRORDER_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CRORDER_ASMBLR_PVT" AUTHID CURRENT_USER AS
/*$Header: OKCRCOKS.pls 120.0 2005/05/25 19:32:03 appldev noship $ */

g_pkg_name CONSTANT varchar2(100) := 'OKC_CRORDER_ASMBLR_PVT';


PROCEDURE acn_assemble(
  p_api_version       IN NUMBER,
  p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2,

  p_contract_id       IN NUMBER,
  p_order_number      IN NUMBER );


END OKC_CRORDER_ASMBLR_PVT;

 

/
