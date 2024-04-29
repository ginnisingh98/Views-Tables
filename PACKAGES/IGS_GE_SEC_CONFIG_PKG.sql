--------------------------------------------------------
--  DDL for Package IGS_GE_SEC_CONFIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_SEC_CONFIG_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNIA3S.pls 115.1 2002/11/01 10:26:06 kpadiyar noship $ */
   TYPE t_result_set IS RECORD    (l_canvas VARCHAR2(100),
                                   l_query_hide igs_ge_cfg_tab.config_opt%TYPE);

   TYPE tb_result_set IS TABLE OF t_result_set INDEX BY BINARY_INTEGER;


   FUNCTION check_form_security
     ( p_responsibility_id IN NUMBER,
       p_form_name IN VARCHAR2)
     RETURN  BOOLEAN;

   FUNCTION check_tab_security
     ( p_responsibility_id IN NUMBER,
       p_form_name IN VARCHAR2
     )
      RETURN tb_result_set;

   FUNCTION check_tab_exists
     ( p_responsibility_id IN NUMBER,
       p_form_name IN VARCHAR2,
       p_tab_name  IN VARCHAR2
     )
      RETURN BOOLEAN;

END igs_ge_sec_config_pkg;

 

/
