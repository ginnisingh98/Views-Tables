--------------------------------------------------------
--  DDL for Package PA_GL_TIEBACK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_GL_TIEBACK_PKG" AUTHID CURRENT_USER As
/* $Header: PAGLTIES.pls 115.2 2002/04/15 21:12:14 pkm ship        $*/

Procedure PA_GL_TIEBACK  (
                         P_MODULE     In      Varchar2,
                         X_COUNT      Out     Number ,
                         X_ERROR      Out     VARCHAR2
                         );

END ;

 

/
