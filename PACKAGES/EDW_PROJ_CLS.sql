--------------------------------------------------------
--  DDL for Package EDW_PROJ_CLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_PROJ_CLS" AUTHID CURRENT_USER AS
/* $Header: FIICAPCS.pls 120.0 2002/08/24 04:50:03 appldev noship $  */
VERSION        CONSTANT CHAR(80) := '$Header: EDWFKMPS.pls 110.17 99/04/06 15:28
:56 droy ship $';

-- ------------------------
-- Public Functions
-- ------------------------
Function get_class_fk(
   p_project_id        in NUMBER,
   p_cls_no in varchar2) return VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_class_fk,WNDS, WNPS, RNPS);
end;

 

/
