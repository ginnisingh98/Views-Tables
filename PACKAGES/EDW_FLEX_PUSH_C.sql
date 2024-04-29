--------------------------------------------------------
--  DDL for Package EDW_FLEX_PUSH_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_FLEX_PUSH_C" AUTHID CURRENT_USER AS
	/*$Header: EDWFLXGS.pls 115.5 2002/12/06 20:17:04 arsantha ship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
		  p_dimension   IN VARCHAR2,
                  p_from_date   IN  VARCHAR2,
                  p_to_date     IN  VARCHAR2);
   Procedure Push_Levels(p_from_date IN date, p_to_date IN DATE);
End EDW_FLEX_PUSH_C;

 

/
