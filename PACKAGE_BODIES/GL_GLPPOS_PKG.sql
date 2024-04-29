--------------------------------------------------------
--  DDL for Package Body GL_GLPPOS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLPPOS_PKG" as
/* $Header: glupohkb.pls 120.8.12000000.2 2007/10/20 07:21:24 aktelang ship $ */


PROCEDURE glphk (posting_run_id IN NUMBER) is
begin
   JG_GLPPOS_PKG.glphk(posting_run_id );
end;

PROCEDURE after_final_journals_update (posting_run_id IN NUMBER) is
begin
   IGI_POST.IGI_POST_GL_POSTING(posting_run_id);
end;

END gl_glppos_pkg;

/
