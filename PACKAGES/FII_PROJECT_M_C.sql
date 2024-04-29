--------------------------------------------------------
--  DDL for Package FII_PROJECT_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PROJECT_M_C" AUTHID CURRENT_USER AS
	/*$Header: FIICMPJS.pls 120.1 2002/11/27 02:14:17 svermett ship $ */
   Procedure Push(Errbuf        in out nocopy Varchar2,
                  Retcode       in out nocopy Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
   Procedure Push_EDW_PROJ_TASK_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_TOP_TASK_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_PROJECT_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_PRJ_TYP_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_CLS1_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_CLS2_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_CLS3_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_CLS4_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_CLS5_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_CLS6_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_CLS7_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_CATEG1_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_CATEG2_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_CATEG3_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_CATEG4_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_CATEG5_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_CATEG6_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_PROJ_CATEG7_LSTG(p_from_date IN date, p_to_date IN DATE);
End FII_PROJECT_M_C;

 

/
