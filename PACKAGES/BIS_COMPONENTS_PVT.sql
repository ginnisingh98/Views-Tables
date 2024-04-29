--------------------------------------------------------
--  DDL for Package BIS_COMPONENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_COMPONENTS_PVT" AUTHID CURRENT_USER as
/* $Header: BISCOMPS.pls 115.1 2003/10/29 06:57:42 nbarik noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile:~PROD:~PATH:~FILE

  --nbarik - 10/28/03 - Bug Fix 3212861 - Added p_function_id
  PROCEDURE set_reference_path(
    p_function_name   IN VARCHAR2
   ,p_function_id     IN NUMBER
   ,p_page_id         IN NUMBER
   ,x_plug_id         OUT NOCOPY NUMBER
   ,x_reference_path  OUT NOCOPY VARCHAR2
  );

END BIS_COMPONENTS_PVT;

 

/
