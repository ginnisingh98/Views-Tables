--------------------------------------------------------
--  DDL for Package FII_GL_BOOK_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_BOOK_M_C" AUTHID CURRENT_USER AS
	/*$Header: FIICMBKS.pls 120.1 2002/11/15 23:57:37 djanaswa ship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
   Procedure Push_EDW_GL_BOOK_FA_BOOK_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_GL_BOOK_BOOK_LSTG(p_from_date IN date, p_to_date IN DATE);
End FII_GL_BOOK_M_C;

 

/
