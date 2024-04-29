--------------------------------------------------------
--  DDL for Package FII_TIME_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_TIME_M_C" AUTHID CURRENT_USER AS
/* $Header: FIICMCAS.pls 120.1 2002/11/16 00:12:45 djanaswa ship $ */

 	G_PUSH_DATE_RANGE1         Date:=Null;
 	G_PUSH_DATE_RANGE2         Date:=Null;
 	G_EXCEPTION_MSG            VARCHAR2(2000):=NULL;

   Procedure Push_gl_and_ent_calendar (
               p_from_date IN Date,
               p_to_date   IN Date);

   Procedure Push(Errbuf           out NOCOPY Varchar2,
               Retcode          out NOCOPY Varchar2,
               p_from_date      in  Varchar2 := NULL,
               p_to_date        in  Varchar2 := NULL);

End FII_TIME_M_C;

 

/
