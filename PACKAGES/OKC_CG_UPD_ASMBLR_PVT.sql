--------------------------------------------------------
--  DDL for Package OKC_CG_UPD_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CG_UPD_ASMBLR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRCUAS.pls 120.1 2005/07/01 15:43:53 pnayani noship $ */

g_pkg_name CONSTANT varchar2(100) := 'OKC_CG_UPD_ASMBLR_PVT';


PROCEDURE acn_assemble(
  p_api_version                 IN NUMBER,
  p_init_msg_list               IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status               OUT NOCOPY VARCHAR2,
  x_msg_count                   OUT NOCOPY NUMBER,
  x_msg_data                    OUT NOCOPY VARCHAR2,
  p_counter_id		            IN NUMBER DEFAULT OKC_API.G_MISS_NUM
  );

END OKC_CG_UPD_ASMBLR_PVT;

 

/
