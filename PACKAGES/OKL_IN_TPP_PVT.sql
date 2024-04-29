--------------------------------------------------------
--  DDL for Package OKL_IN_TPP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_IN_TPP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTPPS.pls 115.2 2002/12/18 12:51:47 kjinger noship $ */
 ---------------------------------------------------------------------------
   -- GLOBAL MESSAGE CONSTANTS
   ---------------------------------------------------------------------------
   G_FND_APP			      CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
   G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
   G_INVALID_VALUE		      CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
   G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME';
   G_COL_NAME1_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME1';
   G_COL_NAME2_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME2';
   G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
   G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
   G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
   ---------------------------------------------------------------------------
   -- GLOBAL VARIABLES
   ---------------------------------------------------------------------------
   G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_IN_TPP_PVT';
   G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';
    ---------------------------------------------------------------------------
   -- GLOBAL EXCEPTION
   ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  FUNCTION agency_address(  p_isu_id     IN  NUMBER,
                               p_agency_site_id IN NUMBER,
                                     x_agency_name   	 OUT NOCOPY VARCHAR2,
                                     x_agency_addrss1	 OUT NOCOPY VARCHAR2,
                                     x_agency_addrss2	 OUT NOCOPY VARCHAR2,
                                     x_agency_addrss3	 OUT NOCOPY VARCHAR2,
                                     x_agency_addrss4	 OUT NOCOPY VARCHAR2,
                                     x_agency_city		 OUT NOCOPY VARCHAR2,
                                     x_agency_county	 OUT NOCOPY VARCHAR2,
                                     x_agency_province	 OUT NOCOPY VARCHAR2,
                                     x_agency_state		 OUT NOCOPY VARCHAR2,
                                     x_agency_postalcode	 OUT NOCOPY VARCHAR2,
                                     x_agency_country	 OUT NOCOPY VARCHAR2
        		    	 ) RETURN VARCHAR2;
 FUNCTION agent_address(  p_int_id     IN  NUMBER,
                          p_agent_site_id IN NUMBER,
                          x_agent_name   	 OUT NOCOPY VARCHAR2,
                          x_agent_addrss1	 OUT NOCOPY VARCHAR2,
                          x_agent_addrss2	 OUT NOCOPY VARCHAR2,
                          x_agent_addrss3	 OUT NOCOPY VARCHAR2,
                          x_agent_addrss4	 OUT NOCOPY VARCHAR2,
                          x_agent_city	 OUT NOCOPY VARCHAR2,
                          x_agent_county	 OUT NOCOPY VARCHAR2,
                          x_agent_province OUT NOCOPY VARCHAR2,
                          x_agent_state	 OUT NOCOPY VARCHAR2,
                          x_agent_postalcode OUT NOCOPY VARCHAR2,
                          x_agent_country	   OUT NOCOPY VARCHAR2
        		) RETURN VARCHAR2;
END OKL_IN_TPP_PVT;

 

/
