--------------------------------------------------------
--  DDL for Package OKC_CEVT_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CEVT_ASMBLR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRCERS.pls 120.0 2005/05/25 22:54:20 appldev noship $ */

g_pkg_name CONSTANT varchar2(100) := 'OKC_CEVT_ASMBLR_PVT';

--Procedure to assemble all the attributes which are required to notify Events Evaluator
PROCEDURE acn_assemble(
  p_api_version       		IN NUMBER,
  p_init_msg_list     		IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status     		OUT NOCOPY VARCHAR2,
  x_msg_count         		OUT NOCOPY NUMBER,
  x_msg_data          		OUT NOCOPY VARCHAR2,
  p_contract_id			IN NUMBER,
  p_cont_evt_name		IN VARCHAR2,
  p_cont_evt_date		IN DATE);

END OKC_CEVT_ASMBLR_PVT;

 

/
