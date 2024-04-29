--------------------------------------------------------
--  DDL for Package OPI_EDW_OPI_RES_UTIL_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_OPI_RES_UTIL_F_C" AUTHID CURRENT_USER AS
/* $Header: OPIMRUTS.pls 120.1 2005/06/08 18:20:05 appldev  $ */
PROCEDURE  Push(Errbuf      in out nocopy  Varchar2,
                Retcode     in out nocopy  Varchar2,
                p_from_date  IN   varchar2,
                p_to_date    IN   VARCHAR2    );

END OPI_EDW_OPI_RES_UTIL_F_C;

 

/
