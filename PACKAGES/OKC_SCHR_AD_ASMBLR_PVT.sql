--------------------------------------------------------
--  DDL for Package OKC_SCHR_AD_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_SCHR_AD_ASMBLR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRSARS.pls 120.0 2005/05/25 19:29:57 appldev noship $ */

g_pkg_name CONSTANT varchar2(100) := 'OKC_SCHR_AD_ASMBLR_PVT';

--Procedure to assemble all the attributes which are required to notify Events Evaluator
PROCEDURE acn_assemble(
  p_api_version       		IN NUMBER,
  p_init_msg_list     		IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status     		OUT NOCOPY VARCHAR2,
  x_msg_count         		OUT NOCOPY NUMBER,
  x_msg_data          		OUT NOCOPY VARCHAR2,
  p_rtv_id			IN NUMBER,
  p_actual_date			IN DATE);

END OKC_SCHR_AD_ASMBLR_PVT;

 

/
