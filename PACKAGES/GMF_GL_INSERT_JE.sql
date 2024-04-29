--------------------------------------------------------
--  DDL for Package GMF_GL_INSERT_JE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GL_INSERT_JE" AUTHID CURRENT_USER AS
/* $Header: gmfjcats.pls 115.0 99/07/16 04:20:42 porting shi $ */
  PROCEDURE GMF_GL_INSERT_JE_CATEGORY(categoryname in varchar2,
                  descrip in varchar2,
                  createdby in number,
                  statuscode out number) ;
  PROCEDURE GMF_GL_INSERT_JE_SOURCE(sourcename in varchar2,
                  descrip    in varchar2,
                  createdby  in number,
                  statuscode out number) ;

END GMF_GL_INSERT_JE;

 

/
