--------------------------------------------------------
--  DDL for Package WSH_EXTREPS_MLS_LANG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_EXTREPS_MLS_LANG" AUTHID CURRENT_USER AS
/* $Header: WSHMLSLS.pls 120.0.12000000.1 2007/01/16 05:48:19 appldev ship $ */

   TYPE lang_record_type is record
          (lang_code     varchar2(4),
           nls_language  varchar2(30),
           nls_territory varchar2(30));

   TYPE lang_tab_type is table of lang_record_type INDEX BY BINARY_INTEGER;

   FUNCTION GET_LANG RETURN VARCHAR2;

   PROCEDURE GET_NLS_LANG (
                              p_prog_name IN VARCHAR2,
                              p_doc_param_info IN WSH_DOCUMENT_SETS.document_set_rec_type,
                              p_nls_comp       IN  VARCHAR2,
                              x_nls_lang       OUT NOCOPY lang_tab_type,
                              x_return_status  OUT NOCOPY VARCHAR2
                          );


END WSH_EXTREPS_MLS_LANG;

 

/
