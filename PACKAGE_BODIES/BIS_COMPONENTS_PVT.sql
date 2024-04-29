--------------------------------------------------------
--  DDL for Package Body BIS_COMPONENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_COMPONENTS_PVT" AS
/* $Header: BISCOMPB.pls 115.1 2003/10/29 06:57:51 nbarik noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile:~PROD:~PATH:~FILE
  --nbarik - 10/28/03 - Bug Fix 3212861 - Added p_function_id
  PROCEDURE set_reference_path(
    p_function_name   IN VARCHAR2
   ,p_function_id     IN NUMBER
   ,p_page_id         IN NUMBER
   ,x_plug_id         OUT NOCOPY NUMBER
   ,x_reference_path  OUT NOCOPY VARCHAR2
  )
  IS
    l_function_id     NUMBER;
    l_plug_id         NUMBER;
    l_reference_path  VARCHAR2(2000);
    /*
    CURSOR c_function_id IS
      SELECT function_id FROM fnd_form_functions
      WHERE function_name = p_function_name;
    */
    CURSOR c_plug_id IS
      SELECT plug_id FROM icx_portlet_customizations
      WHERE reference_path = l_reference_path;

  BEGIN
    --nbarik - 10/28/03 - Bug Fix 3212861 - Added p_function_id
    /*
    OPEN c_function_id;
    FETCH c_function_id INTO l_function_id;
    CLOSE c_function_id;
    */
    l_function_id := p_function_id;
    IF l_function_id IS NULL OR p_page_id IS NULL THEN
      RETURN;
    END IF;

    l_reference_path := l_function_id || '_' || p_function_name || '_' || p_page_id;

    OPEN c_plug_id;
    FETCH c_plug_id INTO l_plug_id;
    CLOSE c_plug_id;

    IF l_plug_id IS NULL THEN
      SELECT icx_page_plugs_s.nextval INTO l_plug_id
      FROM sys.dual;

      INSERT INTO icx_portlet_customizations (reference_path, plug_id, user_id, caching_key)
      VALUES (l_reference_path, l_plug_id, -1, '0');
    END IF;

    x_plug_id := l_plug_id;
    x_reference_path := l_reference_path;

  EXCEPTION
    WHEN others THEN
      /*
      IF c_function_id%ISOPEN THEN
        CLOSE c_function_id;
      END IF;
      */
      IF c_plug_id%ISOPEN THEN
        CLOSE c_plug_id;
      END IF;
  END set_reference_path;

END BIS_COMPONENTS_PVT;

/
