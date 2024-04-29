--------------------------------------------------------
--  DDL for Package GMF_GL_GET_SOB_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GL_GET_SOB_ID" AUTHID CURRENT_USER AS
/* $Header: gmfsobis.pls 115.1 2002/11/11 00:44:35 rseshadr ship $ */
  PROCEDURE proc_gl_get_sob_id(
          st_date  in out  NOCOPY date,
          en_date    in out  NOCOPY date,
          sob_name    in out  NOCOPY varchar2,
          sob_id     out   NOCOPY number,
          row_to_fetch in number,
          error_status out   NOCOPY number);
END GMF_GL_GET_SOB_ID;

 

/
