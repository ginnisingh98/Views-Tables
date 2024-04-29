--------------------------------------------------------
--  DDL for Package Body XLA_DESCRIPT_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_DESCRIPT_DETAILS_PKG" AS
/* $Header: xlaamdpd.pkb 120.5 2005/02/26 02:03:31 weshen ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_descript_details_pkg                                           |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Description Priority Details Package                           |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_desc_prio_details                                              |
|                                                                       |
| Deletes all details attached to the priority                          |
|                                                                       |
+======================================================================*/

PROCEDURE delete_desc_prio_details
  (p_description_prio_id              IN NUMBER)

IS
   CURSOR c_desc_prio_details
   IS
   SELECT description_detail_id
     FROM xla_descript_details_b
    WHERE description_prio_id = p_description_prio_id;

   l_description_detail_id   NUMBER(38);

BEGIN

   xla_utility_pkg.trace('> xla_descript_details_pkg.delete_desc_prio_details'   , 10);

   xla_utility_pkg.trace('description_prio_id  = '||p_description_prio_id  , 20);

      OPEN c_desc_prio_details;
      LOOP
         FETCH c_desc_prio_details
          INTO l_description_detail_id;
         EXIT WHEN c_desc_prio_details%notfound;

        xla_descript_details_f_pkg.delete_row
          (x_description_detail_id   => l_description_detail_id);

     END LOOP;
     CLOSE c_desc_prio_details;

   xla_utility_pkg.trace('< xla_descript_details_pkg.delete_desc_prio_details'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_desc_prio_details%ISOPEN THEN
         CLOSE c_desc_prio_details;
      END IF;
      RAISE;
   WHEN OTHERS                                   THEN
      IF c_desc_prio_details%ISOPEN THEN
         CLOSE c_desc_prio_details;
      END IF;
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_descript_details_pkg.delete_desc_prio_details');

END delete_desc_prio_details;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| display_desc_prio_details                                             |
|                                                                       |
| Returns details for the priority                                      |
|                                                                       |
+======================================================================*/

FUNCTION display_desc_prio_details
  (p_description_prio_id              IN NUMBER
  ,p_chart_of_accounts_id             IN NUMBER)

RETURN VARCHAR2

IS

   CURSOR c_desc_prio_details
   IS
   SELECT user_sequence, value_type_code,
          source_application_id, source_type_code, source_code, source_name,
          source_flex_appl_id, source_id_flex_code,
          flexfield_segment_code, literal
     FROM xla_descript_details_fvl
    WHERE description_prio_id = p_description_prio_id
    ORDER BY user_sequence;

   --
   -- Local variables
   --
   l_desc_prio_detail  c_desc_prio_details%rowtype;

   l_desc_detail_dsp               VARCHAR2(2000) := NULL;
   l_flexfield_segment_name        VARCHAR2(80);
   l_source_id_flex_num            NUMBER(15);

BEGIN

   xla_utility_pkg.trace('> xla_descript_details_pkg.display_desc_prio_details'   , 10);

   xla_utility_pkg.trace('description_prio_id  = '||p_description_prio_id  , 20);
   xla_utility_pkg.trace('description_prio_id  = '||p_chart_of_accounts_id  , 20);

      OPEN c_desc_prio_details;
      LOOP
         FETCH c_desc_prio_details
          INTO l_desc_prio_detail;
         EXIT WHEN c_desc_prio_details%notfound;

         BEGIN
         IF l_desc_prio_detail.value_type_code = 'L' THEN

            l_desc_detail_dsp := rtrim(l_desc_detail_dsp)||
                                 l_desc_prio_detail.literal;
         ELSE
            l_desc_detail_dsp := rtrim(l_desc_detail_dsp)||
                                 l_desc_prio_detail.source_name;

         END IF;
         --
         -- Get flexfield_segment_name
         --
         IF l_desc_prio_detail.flexfield_segment_code is not null THEN

            IF l_desc_prio_detail.source_flex_appl_id = 101 and l_desc_prio_detail.source_id_flex_code = 'GL#' THEN
               l_flexfield_segment_name := xla_flex_pkg.get_flexfield_segment_name
                                          (p_application_id         => 101
                                          ,p_flex_code              => 'GL#'
                                          ,p_chart_of_accounts_id   => p_chart_of_accounts_id
                                          ,p_flexfield_segment_code => l_desc_prio_detail.flexfield_segment_code);

               IF l_flexfield_segment_name is null THEN
                  l_flexfield_segment_name := xla_flex_pkg.get_qualifier_name
                                                     (p_application_id     => 101
                                                     ,p_id_flex_code       => 'GL#'
                                                     ,p_qualifier_segment  => l_desc_prio_detail.flexfield_segment_code);


               END IF;
            ELSE

               l_source_id_flex_num := xla_flex_pkg.get_flexfield_structure
                                         (p_application_id    => l_desc_prio_detail.source_flex_appl_id
                                         ,p_id_flex_code      => l_desc_prio_detail.source_id_flex_code);

               l_flexfield_segment_name := xla_flex_pkg.get_flexfield_segment_name
                                          (p_application_id         => l_desc_prio_detail.source_flex_appl_id
                                          ,p_flex_code              => l_desc_prio_detail.source_id_flex_code
                                          ,p_chart_of_accounts_id   => l_source_id_flex_num
                                          ,p_flexfield_segment_code => l_desc_prio_detail.flexfield_segment_code);
            END IF;

            l_desc_detail_dsp := rtrim(l_desc_detail_dsp)||','||
                                 l_flexfield_segment_name;
         END IF;

         EXCEPTION
            WHEN VALUE_ERROR THEN
               xla_exceptions_pkg.raise_message
                                   ('XLA'
                                   ,'XLA_AB_DESC_TOO_LONG'
                                   ,'PROCEDURE'
                                   ,'xla_descript_details_pkg.display_desc_prio_details'
                                   ,'ERROR'
                                   ,sqlerrm
                                   );
         END;

      END LOOP;
      CLOSE c_desc_prio_details;

   xla_utility_pkg.trace('< xla_descript_details_pkg.display_desc_prio_details'    , 10);

   RETURN l_desc_detail_dsp;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_desc_prio_details%ISOPEN THEN
         CLOSE c_desc_prio_details;
      END IF;
      RAISE;
   WHEN OTHERS                                   THEN
      IF c_desc_prio_details%ISOPEN THEN
         CLOSE c_desc_prio_details;
      END IF;
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_descript_details_pkg.display_desc_prio_details');

END display_desc_prio_details;

END xla_descript_details_pkg;

/
