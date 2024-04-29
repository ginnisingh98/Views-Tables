--------------------------------------------------------
--  DDL for Package Body BSC_COLOR_REPOSITORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_COLOR_REPOSITORY" AS
/* $Header: BSCRCOLB.pls 120.0.12000000.1 2007/07/17 07:44:22 appldev noship $ */


/* This function should be used by all clients who want to keep an object
 * for color properties in the system. It gives back the cached object
 * instead of querying db everytime.
 */
FUNCTION get_color_props
RETURN t_array_colors
IS
  CURSOR c_color IS
    SELECT color_id, short_name, perf_sequence, user_numeric_equivalent
      FROM bsc_sys_colors_b;

  l_array_colors  t_array_colors;
  l_color_rec     t_color_rec;
  l_color_index   NUMBER := 0;

BEGIN

  IF G_COLOR_SET THEN

    l_array_colors := g_array_colors;

  ELSE

    FOR l_color_rec IN c_color LOOP

      l_color_index := l_color_index + 1;
      l_array_colors(l_color_index) := l_color_rec;

    END LOOP;

    g_array_colors := l_array_colors;
    G_COLOR_SET := TRUE;

  END IF;

  RETURN l_array_colors;

EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_REPOSITORY.get_color_props');
    RETURN l_array_colors;
END get_color_props;



END BSC_COLOR_REPOSITORY;

/
