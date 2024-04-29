--------------------------------------------------------
--  DDL for Package OKC_XML_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XML_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRXMLS.pls 120.0 2005/05/25 19:25:15 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- TYPES
  ---------------------------------------------------------------------------
  -- CONSTANTS
  ---------------------------------------------------------------------------
  -- PUBLIC VARIABLES
  ---------------------------------------------------------------------------
  -- EXCEPTIONS
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE build_xml_clob (
    p_corrid_rec IN okc_aq_pvt.corrid_rec_typ,
    p_element_tbl   IN  okc_aq_pvt.msg_tab_typ,
    x_xml_clob      OUT NOCOPY  system.okc_aq_msg_typ
    );

  PROCEDURE get_element_vals (
    p_msg       IN     system.okc_aq_msg_typ,
    x_msg_tab   OUT NOCOPY    okc_aq_pvt.msg_tab_typ,
    x_corrid    OUT NOCOPY    okc_aq_pvt.corrid_rec_typ
    );


END;

 

/
