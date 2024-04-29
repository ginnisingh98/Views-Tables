--------------------------------------------------------
--  DDL for Package GMF_GL_GET_CONVERSION_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GL_GET_CONVERSION_TYPES" AUTHID CURRENT_USER AS
/* $Header: gmfcnvts.pls 115.1 2002/11/11 00:33:01 rseshadr ship $ */
      PROCEDURE gl_get_conversion_types(  startdate in date,
                              enddate in date,
                              creation_date out NOCOPY date,
                              last_update_date out NOCOPY date,
                              created_by out NOCOPY number,
                              last_updated_by out NOCOPY number,
                              conversiontype in out NOCOPY varchar2,
                              usr_conversiontype in out NOCOPY varchar2,
                              descr in out NOCOPY varchar2,
                              row_to_fetch in out NOCOPY number,
                              statuscode out NOCOPY number);
/*      ad_by number;*/
/*      mod_by number;*/
     END GMF_GL_GET_CONVERSION_TYPES;

 

/
