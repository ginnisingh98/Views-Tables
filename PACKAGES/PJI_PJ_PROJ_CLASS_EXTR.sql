--------------------------------------------------------
--  DDL for Package PJI_PJ_PROJ_CLASS_EXTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PJ_PROJ_CLASS_EXTR" AUTHID CURRENT_USER AS
/* $Header: PJISF10S.pls 120.0 2005/05/29 12:59:14 appldev noship $ */

  -- exceptions -----------------------------------

   e_dangling_class_fk          exception;

  procedure extr_class_codes;
  procedure extr_project_classes( p_worker_id number );
  procedure cleanup( p_worker_id number );

end PJI_PJ_PROJ_CLASS_EXTR;

 

/
