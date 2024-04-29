--------------------------------------------------------
--  DDL for Package PER_RI_RT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_RT_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: perrirtutil.pkh 120.0 2005/06/01 00:53:30 appldev noship $ */
PROCEDURE insert_per_ri_rt_gen (p_job_name      VARCHAR2,
                                p_request_id    NUMBER,
				p_user_id       NUMBER);

FUNCTION get_display_prompt (p_flexfield VARCHAR2,
                             p_context   VARCHAR2,
			     p_column    VARCHAR2) return varchar2;

FUNCTION get_display_value(p_flexfield  VARCHAR2,
                            p_context   VARCHAR2,
			    p_column    VARCHAR2,
			    p_value     VARCHAR2) return varchar2;

FUNCTION chk_context (p_flexfield VARCHAR2,
                      p_context   VARCHAR2) RETURN NUMBER;

PROCEDURE  generate_xml (p_entity_code  VARCHAR2,
                         p_sample_size  NUMBER ,
			 p_business_group_id NUMBER,
			 p_xmldata     OUT nocopy CLOB);
PROCEDURE apps_initialise;
end;

 

/
