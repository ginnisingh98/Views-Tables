--------------------------------------------------------
--  DDL for Package OZF_GENERATE_XML_CLOB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_GENERATE_XML_CLOB_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvxmls.pls 115.1 2004/03/22 21:23:29 mgudivak noship $ */
-- Start of Comments
-- Package name     : ozf_generate_xml_clob_pvt
-- Purpose          :
-- History          : 09-OCT-2003  vansub   Created
-- NOTE             :
-- End of Comments



FUNCTION generate_offer_clob (p_event_name in varchar2,
                              p_event_key in varchar2,
                              p_parameter_list in wf_parameter_list_t default null)
RETURN CLOB;

FUNCTION generate_quota_clob (p_event_name in varchar2,
                              p_event_key in varchar2,
                              p_parameter_list in wf_parameter_list_t default null)
RETURN CLOB;

FUNCTION generate_target_clob (p_event_name in varchar2,
                              p_event_key in varchar2,
                              p_parameter_list in wf_parameter_list_t default null)
RETURN CLOB;

END  ozf_generate_xml_clob_pvt;

 

/
