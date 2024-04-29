--------------------------------------------------------
--  DDL for Package OKC_DATE_ASSEMBLER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_DATE_ASSEMBLER_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPDASS.pls 120.0 2005/05/25 19:20:43 appldev noship $ */

-- GLOBAL CONSTANTS
  ----------------------------------------------------------------------------
  g_pkg_name     CONSTANT varchar2(100) := 'OKC_DATE_ASSEMBLER_PUB';

  ----------------------------------------------------------------------------
  -- PROCEDURE date_assemble
  ----------------------------------------------------------------------------
  PROCEDURE date_assemble(
    	p_api_version                  IN NUMBER DEFAULT 1.0,
    	p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    	x_return_status                OUT NOCOPY VARCHAR2,
    	x_msg_count                    OUT NOCOPY NUMBER,
    	x_msg_data                     OUT NOCOPY VARCHAR2);

  PROCEDURE conc_mgr(errbuf  OUT NOCOPY VARCHAR2,
                     retcode OUT NOCOPY VARCHAR2);

END OKC_DATE_ASSEMBLER_PUB;

 

/
