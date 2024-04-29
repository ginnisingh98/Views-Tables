--------------------------------------------------------
--  DDL for Package Body EDW_PROJ_CLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_PROJ_CLS" AS
/* $Header: FIICAPCB.pls 120.0 2002/08/24 04:49:59 appldev noship $  */
VERSION  CONSTANT CHAR(80) := '$Header: EDWFKMPB.pls 110.48 99/06/09 11:55:56 vs
urendr ship $';

Function get_class_fk(
   p_project_id        in NUMBER,
   p_cls_no in VARCHAR2) return VARCHAR2 is
  l_cat     VARCHAR2(120) := 'NA_EDW';
BEGIN
   select class_code
          || '-'
          || edw_instance.get_code
    into l_cat
    from pa_project_classes
    where project_id = p_project_id
      and class_category =  p_cls_no;

return l_cat ;
exception
   when no_data_found
     then l_cat := 'NA_EDW';
    return 'NA_EDW';
end;
end;

/
