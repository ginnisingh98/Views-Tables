--------------------------------------------------------
--  DDL for Package EDW_BOM_RES_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_BOM_RES_M_C" AUTHID CURRENT_USER AS
/*$Header: ENICRESS.pls 120.0 2005/05/26 19:36:11 appldev noship $*/
   VERSION                 CONSTANT CHAR(80) :=
      '$Header: ENICRESS.pls 120.0 2005/05/26 19:36:11 appldev noship $';

   Procedure Push(Errbuf        out NOCOPY Varchar2,
                  Retcode       out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
   Procedure Push_EDW_BRES_PLANT(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
   Procedure Push_EDW_BRES_PLANT1(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
   Procedure Push_EDW_BRES_RESOURCE(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
   Procedure Push_EDW_BRES_RESGROUP(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
   Procedure Push_EDW_BRES_RESTYPE(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
   Procedure Push_EDW_BRES_RESCAT(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
   Procedure Push_EDW_BRES_PARENT_DEPT(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
   Procedure Push_EDW_BRES_DEPT(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
   Procedure Push_EDW_BRES_DEPT_CLASS(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
End EDW_BOM_RES_M_C;

 

/
