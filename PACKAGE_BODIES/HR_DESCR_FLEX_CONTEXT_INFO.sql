--------------------------------------------------------
--  DDL for Package Body HR_DESCR_FLEX_CONTEXT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DESCR_FLEX_CONTEXT_INFO" 
/* $Header: hrdfcinf.pkb 115.2 2002/12/10 08:56:25 hjonnala ship $ */
AS
  --
  TYPE t_segment_header IS RECORD
    (application_id                 fnd_descr_flex_contexts.application_id%TYPE
    ,descriptive_flexfield_name     fnd_descr_flex_contexts.descriptive_flexfield_name%TYPE
    ,descr_flex_context_code        fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE
    ,effective_date                 DATE
    ,first_index_number             NUMBER
    ,last_index_number              NUMBER
    );
  TYPE t_segment_headers IS TABLE OF t_segment_header;
  --
  g_application_id1              fnd_descr_flex_contexts.application_id%TYPE;
  g_descriptive_flexfield_name1  fnd_descr_flex_contexts.descriptive_flexfield_name%TYPE;
  g_descr_flex_context_code1     fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE;
  g_effective_date1              DATE;
  g_segments1                    t_segments := t_segments();
  g_application_id2              fnd_descr_flex_contexts.application_id%TYPE;
  g_descriptive_flexfield_name2  fnd_descr_flex_contexts.descriptive_flexfield_name%TYPE;
  g_descr_flex_context_code2     fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE;
  g_effective_date2              DATE;
  g_segments2                    t_segments := t_segments();
  g_application_short_name3      fnd_application.application_short_name%TYPE;
  g_application_id3              fnd_application.application_id%TYPE;
  --
  g_segment_headers              t_segment_headers := t_segment_headers();
  g_segments                     t_segments        := t_segments();
--
-- -----------------------------------------------------------------------------
-- |------------------------------< add_segments >-----------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE add_segments
  (p_application_id               IN     fnd_descr_flex_contexts.application_id%TYPE
  ,p_descriptive_flexfield_name   IN     fnd_descr_flex_contexts.descriptive_flexfield_name%TYPE
  ,p_descr_flex_context_code      IN     fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE
  ,p_effective_date               IN     DATE
  ,p_segments                     IN     t_segments
  )
IS
  --
  l_index_number                 NUMBER;
--
BEGIN
  --
  g_segment_headers.EXTEND;
  g_segment_headers(g_segment_headers.LAST).application_id := p_application_id;
  g_segment_headers(g_segment_headers.LAST).descriptive_flexfield_name := p_descriptive_flexfield_name;
  g_segment_headers(g_segment_headers.LAST).descr_flex_context_code := p_descr_flex_context_code;
  g_segment_headers(g_segment_headers.LAST).effective_date := p_effective_date;
  l_index_number := p_segments.FIRST;
  WHILE (l_index_number IS NOT NULL)
  LOOP
    g_segments.EXTEND;
    IF (g_segment_headers(g_segment_headers.LAST).first_index_number IS NULL)
    THEN
      g_segment_headers(g_segment_headers.LAST).first_index_number := g_segments.LAST;
    END IF;
    g_segments(g_segments.LAST) := p_segments(l_index_number);
    l_index_number := p_segments.NEXT(l_index_number);
  END LOOP;
  g_segment_headers(g_segment_headers.LAST).last_index_number := g_segments.LAST;
--
END add_segments;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< get_segments >-----------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE get_segments
  (p_application_id               IN     fnd_descr_flex_contexts.application_id%TYPE
  ,p_descriptive_flexfield_name   IN     fnd_descr_flex_contexts.descriptive_flexfield_name%TYPE
  ,p_descr_flex_context_code      IN     fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE
  ,p_effective_date               IN     DATE
  ,p_segments                        OUT NOCOPY t_segments
  ,p_segments_exist                  OUT NOCOPY BOOLEAN
  )
IS
  --
  l_segments                     t_segments := t_segments();
  l_segments_exist               BOOLEAN    := FALSE;
  l_index_number                 NUMBER;
  l_first_index_number           NUMBER;
  l_last_index_number            NUMBER;
--
BEGIN
  --
  l_index_number := g_segment_headers.FIRST;
  WHILE (l_index_number IS NOT NULL)
    AND (NOT l_segments_exist)
  LOOP
    IF    (g_segment_headers(l_index_number).application_id = p_application_id)
      AND (g_segment_headers(l_index_number).descriptive_flexfield_name = p_descriptive_flexfield_name)
      AND (NVL(g_segment_headers(l_index_number).descr_flex_context_code,hr_api.g_varchar2) = NVL(p_descr_flex_context_code,hr_api.g_varchar2))
      AND (g_segment_headers(l_index_number).effective_date = p_effective_date)
    THEN
      l_first_index_number := g_segment_headers(l_index_number).first_index_number;
      l_last_index_number := g_segment_headers(l_index_number).last_index_number;
      l_segments_exist := TRUE;
    END IF;
    l_index_number := g_segment_headers.NEXT(l_index_number);
  END LOOP;
  --
  IF (l_segments_exist)
  THEN
    l_index_number := l_first_index_number;
    WHILE (l_index_number IS NOT NULL)
      AND (l_index_number <= l_last_index_number)
    LOOP
      l_segments.EXTEND;
      l_segments(l_segments.LAST) := g_segments(l_index_number);
      l_index_number := g_segments.NEXT(l_index_number);
    END LOOP;
  END IF;
  --
  p_segments := l_segments;
  p_segments_exist := l_segments_exist;
--
END get_segments;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< used_segments >-----------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of columns used by a
--   descriptive flexfield context.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_application_id               Y    number   Application identifier
--   p_descriptive_flexfield_name   Y    varchar2 Descriptive flexfield name
--   p_descr_flex_context_code      Y    varchar2 Descriptive flexfield context
--   p_effective_date               Y    date     Effective date
--
-- Post Success
--   A table containg the details of columns used by a descriptive flexfield
--   context is returned.
--
-- Post Failure
--   An error is raised.
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION used_segments
  (p_application_id               IN     fnd_descr_flex_contexts.application_id%TYPE
  ,p_descriptive_flexfield_name   IN     fnd_descr_flex_contexts.descriptive_flexfield_name%TYPE
  ,p_descr_flex_context_code      IN     fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN t_segments
IS
  --
  -- Local cursors
  --
  CURSOR csr_column_usages
    (p_application_id               IN     fnd_descr_flex_contexts.application_id%TYPE
    ,p_descriptive_flexfield_name   IN     fnd_descr_flex_contexts.descriptive_flexfield_name%TYPE
    ,p_descr_flex_context_code      IN     fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE
    )
  IS
    SELECT fcu.application_column_name
          ,fcu.column_seq_num
          ,fcu.concatenation_description_len
          ,fcu.default_type
          ,fcu.default_value
          ,fcu.display_flag
          ,fcu.display_size
          ,fcu.enabled_flag
          ,fcu.end_user_column_name
          ,fcu.flex_value_set_id
          ,fcu.form_above_prompt
          ,fcu.form_left_prompt
          ,fcu.maximum_description_len
          ,fcu.required_flag
      FROM fnd_descr_flex_col_usage_vl fcu
          ,fnd_descr_flex_contexts_vl ctx
     WHERE fcu.application_id = ctx.application_id
       AND fcu.descriptive_flexfield_name = ctx.descriptive_flexfield_name
       AND fcu.descriptive_flex_context_code = ctx.descriptive_flex_context_code
       AND ctx.application_id = p_application_id
       AND ctx.descriptive_flexfield_name = p_descriptive_flexfield_name
       AND ctx.descriptive_flex_context_code = p_descr_flex_context_code
       AND ctx.enabled_flag = 'Y'
    UNION
    SELECT fcu.application_column_name
          ,fcu.column_seq_num
          ,fcu.concatenation_description_len
          ,fcu.default_type
          ,fcu.default_value
          ,fcu.display_flag
          ,fcu.display_size
          ,fcu.enabled_flag
          ,fcu.end_user_column_name
          ,fcu.flex_value_set_id
          ,fcu.form_above_prompt
          ,fcu.form_left_prompt
          ,fcu.maximum_description_len
          ,fcu.required_flag
      FROM fnd_descr_flex_col_usage_vl fcu
          ,fnd_descr_flex_contexts_vl ctx
     WHERE fcu.application_id = ctx.application_id
       AND fcu.descriptive_flexfield_name = ctx.descriptive_flexfield_name
       AND fcu.descriptive_flex_context_code = ctx.descriptive_flex_context_code
       AND ctx.application_id = p_application_id
       AND ctx.descriptive_flexfield_name = p_descriptive_flexfield_name
       AND ctx.global_flag = 'Y'
       AND ctx.enabled_flag = 'Y'
       AND NOT EXISTS (SELECT NULL
                         FROM fnd_descr_flex_col_usage_vl cu1
                             ,fnd_descr_flex_contexts_vl cx1
                        WHERE cu1.application_id = cx1.application_id
                          AND cu1.descriptive_flexfield_name = cx1.descriptive_flexfield_name
                          AND cu1.descriptive_flex_context_code = cx1.descriptive_flex_context_code
                          AND cu1.application_column_name = fcu.application_column_name
                          AND cx1.application_id = ctx.application_id
                          AND cx1.descriptive_flexfield_name = ctx.descriptive_flexfield_name
                          AND cx1.descriptive_flex_context_code = p_descr_flex_context_code
                          AND NVL(cx1.global_flag,'N') <> 'Y'
                          AND cx1.enabled_flag = 'Y');
  --
  -- Local variables
  --
  l_used_segments                t_segments                         := t_segments();
  l_value_set                    hr_flex_value_set_info.t_value_set;
--
BEGIN
  --
  FOR l_column_usage IN csr_column_usages
    (p_application_id               => p_application_id
    ,p_descriptive_flexfield_name   => p_descriptive_flexfield_name
    ,p_descr_flex_context_code      => p_descr_flex_context_code
    )
  LOOP
    --
    -- Retrieve value set details for segment
    --
    l_value_set := hr_flex_value_set_info.value_set
      (p_flex_value_set_id            => l_column_usage.flex_value_set_id
      ,p_effective_date               => p_effective_date
      );
    --
    -- Add segment to table
    --
    l_used_segments.EXTEND;
    l_used_segments(l_used_segments.LAST).column_name                   := l_column_usage.application_column_name;
    l_used_segments(l_used_segments.LAST).sequence                      := l_column_usage.column_seq_num;
    l_used_segments(l_used_segments.LAST).concatenation_description_len := l_column_usage.concatenation_description_len;
    l_used_segments(l_used_segments.LAST).default_type                  := l_column_usage.default_type;
    l_used_segments(l_used_segments.LAST).default_value                 := l_column_usage.default_value;
    l_used_segments(l_used_segments.LAST).display_flag                  := l_column_usage.display_flag;
    l_used_segments(l_used_segments.LAST).display_size                  := l_column_usage.display_size;
    l_used_segments(l_used_segments.LAST).enabled_flag                  := l_column_usage.enabled_flag;
    l_used_segments(l_used_segments.LAST).end_user_column_name          := l_column_usage.end_user_column_name;
    l_used_segments(l_used_segments.LAST).flex_value_set_id             := l_column_usage.flex_value_set_id;
    l_used_segments(l_used_segments.LAST).form_above_prompt             := l_column_usage.form_above_prompt;
    l_used_segments(l_used_segments.LAST).form_left_prompt              := l_column_usage.form_left_prompt;
    l_used_segments(l_used_segments.LAST).maximum_description_len       := l_column_usage.maximum_description_len;
    l_used_segments(l_used_segments.LAST).required_flag                 := l_column_usage.required_flag;
    l_used_segments(l_used_segments.LAST).additional_column1_title      := l_value_set.additional_column1_title;
    l_used_segments(l_used_segments.LAST).additional_column1_width      := l_value_set.additional_column1_width;
    l_used_segments(l_used_segments.LAST).additional_column2_title      := l_value_set.additional_column2_title;
    l_used_segments(l_used_segments.LAST).additional_column2_width      := l_value_set.additional_column2_width;
    l_used_segments(l_used_segments.LAST).additional_column3_title      := l_value_set.additional_column3_title;
    l_used_segments(l_used_segments.LAST).additional_column3_width      := l_value_set.additional_column3_width;
    l_used_segments(l_used_segments.LAST).alphanumeric_allowed_flag     := l_value_set.alphanumeric_allowed_flag;
    l_used_segments(l_used_segments.LAST).flex_value_set_name           := l_value_set.flex_value_set_name;
    l_used_segments(l_used_segments.LAST).format_type                   := l_value_set.format_type;
    l_used_segments(l_used_segments.LAST).identification_sql            := l_value_set.identification_sql;
    l_used_segments(l_used_segments.LAST).id_column_type                := l_value_set.id_column_type;
    l_used_segments(l_used_segments.LAST).has_meaning                   := l_value_set.has_meaning;
    l_used_segments(l_used_segments.LAST).longlist_flag                 := l_value_set.longlist_flag;
    l_used_segments(l_used_segments.LAST).maximum_size                  := l_value_set.maximum_size;
    l_used_segments(l_used_segments.LAST).maximum_value                 := l_value_set.maximum_value;
    l_used_segments(l_used_segments.LAST).minimum_value                 := l_value_set.minimum_value;
    l_used_segments(l_used_segments.LAST).number_precision              := l_value_set.number_precision;
    l_used_segments(l_used_segments.LAST).numeric_mode_enabled_flag     := l_value_set.numeric_mode_enabled_flag;
    l_used_segments(l_used_segments.LAST).uppercase_only_flag           := l_value_set.uppercase_only_flag;
    l_used_segments(l_used_segments.LAST).validation_sql                := l_value_set.validation_sql;
    l_used_segments(l_used_segments.LAST).validation_type               := l_value_set.validation_type;
  --
  END LOOP;
  --
  RETURN(l_used_segments);
--
END used_segments;
--
-- -----------------------------------------------------------------------------
-- |--------------------------------< segments >-------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION segments
  (p_application_id               IN     fnd_descr_flex_contexts.application_id%TYPE
  ,p_descriptive_flexfield_name   IN     fnd_descr_flex_contexts.descriptive_flexfield_name%TYPE
  ,p_descr_flex_context_code      IN     fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN t_segments
IS
  --
  -- Local variables
  --
  l_segments                     t_segments                    := t_segments();
  l_segments_exist               BOOLEAN                       := FALSE;
  l_all_segments                 hr_descr_flex_info.t_segments := hr_descr_flex_info.t_segments();
  l_used_segments                t_segments                    := t_segments();
  l_all_index_number             NUMBER;
  l_used_index_number            NUMBER;
  l_used_segment_found           BOOLEAN;
--
BEGIN
  --
  get_segments
    (p_application_id               => p_application_id
    ,p_descriptive_flexfield_name   => p_descriptive_flexfield_name
    ,p_descr_flex_context_code      => p_descr_flex_context_code
    ,p_effective_date               => p_effective_date
    ,p_segments                     => l_segments
    ,p_segments_exist               => l_segments_exist
    );
  --
  IF (l_segments_exist)
  THEN
    --
    NULL;
  --
  ELSE
    --
    -- Retrieve all segments available for this descriptive flexfield
    --
    l_all_segments := hr_descr_flex_info.segments
      (p_application_id               => p_application_id
      ,p_descriptive_flexfield_name   => p_descriptive_flexfield_name
      );
    --
    -- Retrieve segments used by the descriptive flexfield structure
    --
    l_used_segments := used_segments
      (p_application_id               => p_application_id
      ,p_descriptive_flexfield_name   => p_descriptive_flexfield_name
      ,p_descr_flex_context_code      => p_descr_flex_context_code
      ,p_effective_date               => p_effective_date
      );
    --
    -- For all segments available for this descriptive flexfield
    --
    l_all_index_number := l_all_segments.FIRST;
    WHILE (l_all_index_number IS NOT NULL)
    LOOP
      --
      -- Determine if the avaiable segment is actually used by the descriptive
      -- flexfield context
      --
      l_used_segment_found := FALSE;
      l_used_index_number := l_used_segments.FIRST;
      WHILE (l_used_index_number IS NOT NULL)
        AND (NOT l_used_segment_found)
      LOOP
        IF (l_all_segments(l_all_index_number).column_name = l_used_segments(l_used_index_number).column_name)
        THEN
          l_used_segment_found := TRUE;
        ELSE
          l_used_index_number := l_used_segments.NEXT(l_used_index_number);
        END IF;
      END LOOP;
      --
      -- Add used segment details, if segment is used by the descriptive
      -- flexfield context; otherwise just add the segments basic details to table
      --
      l_segments.EXTEND;
      IF (l_used_segment_found)
      THEN
        l_segments(l_segments.LAST).column_name                   := l_used_segments(l_used_index_number).column_name;
        l_segments(l_segments.LAST).sequence                      := l_used_segments(l_used_index_number).sequence;
        l_segments(l_segments.LAST).additional_column1_title      := l_used_segments(l_used_index_number).additional_column1_title;
        l_segments(l_segments.LAST).additional_column1_width      := l_used_segments(l_used_index_number).additional_column1_width;
        l_segments(l_segments.LAST).additional_column2_title      := l_used_segments(l_used_index_number).additional_column2_title;
        l_segments(l_segments.LAST).additional_column2_width      := l_used_segments(l_used_index_number).additional_column2_width;
        l_segments(l_segments.LAST).additional_column3_title      := l_used_segments(l_used_index_number).additional_column3_title;
        l_segments(l_segments.LAST).additional_column3_width      := l_used_segments(l_used_index_number).additional_column3_width;
        l_segments(l_segments.LAST).alphanumeric_allowed_flag     := l_used_segments(l_used_index_number).alphanumeric_allowed_flag;
        l_segments(l_segments.LAST).concatenation_description_len := l_used_segments(l_used_index_number).concatenation_description_len;
        l_segments(l_segments.LAST).default_type                  := l_used_segments(l_used_index_number).default_type;
        l_segments(l_segments.LAST).default_value                 := l_used_segments(l_used_index_number).default_value;
        l_segments(l_segments.LAST).display_flag                  := l_used_segments(l_used_index_number).display_flag;
        l_segments(l_segments.LAST).display_size                  := l_used_segments(l_used_index_number).display_size;
        l_segments(l_segments.LAST).enabled_flag                  := l_used_segments(l_used_index_number).enabled_flag;
        l_segments(l_segments.LAST).end_user_column_name          := l_used_segments(l_used_index_number).end_user_column_name;
        l_segments(l_segments.LAST).flex_value_set_id             := l_used_segments(l_used_index_number).flex_value_set_id;
        l_segments(l_segments.LAST).flex_value_set_name           := l_used_segments(l_used_index_number).flex_value_set_name;
        l_segments(l_segments.LAST).format_type                   := l_used_segments(l_used_index_number).format_type;
        l_segments(l_segments.LAST).form_above_prompt             := l_used_segments(l_used_index_number).form_above_prompt;
        l_segments(l_segments.LAST).form_left_prompt              := l_used_segments(l_used_index_number).form_left_prompt;
        l_segments(l_segments.LAST).identification_sql            := l_used_segments(l_used_index_number).identification_sql;
        l_segments(l_segments.LAST).id_column_type                := l_used_segments(l_used_index_number).id_column_type;
        l_segments(l_segments.LAST).has_meaning                   := l_used_segments(l_used_index_number).has_meaning;
        l_segments(l_segments.LAST).longlist_flag                 := l_used_segments(l_used_index_number).longlist_flag;
        l_segments(l_segments.LAST).maximum_description_len       := l_used_segments(l_used_index_number).concatenation_description_len;
        l_segments(l_segments.LAST).maximum_size                  := l_used_segments(l_used_index_number).maximum_size;
        l_segments(l_segments.LAST).maximum_value                 := l_used_segments(l_used_index_number).maximum_value;
        l_segments(l_segments.LAST).minimum_value                 := l_used_segments(l_used_index_number).minimum_value;
        l_segments(l_segments.LAST).numeric_mode_enabled_flag     := l_used_segments(l_used_index_number).numeric_mode_enabled_flag;
        l_segments(l_segments.LAST).required_flag                 := l_used_segments(l_used_index_number).required_flag;
        l_segments(l_segments.LAST).uppercase_only_flag           := l_used_segments(l_used_index_number).uppercase_only_flag;
        l_segments(l_segments.LAST).validation_sql                := l_used_segments(l_used_index_number).validation_sql;
        l_segments(l_segments.LAST).validation_type               := l_used_segments(l_used_index_number).validation_type;
      ELSE
        l_segments(l_segments.LAST).column_name               := l_all_segments(l_all_index_number).column_name;
      END IF;
      --
      l_all_index_number := l_all_segments.NEXT(l_all_index_number);
      --
    END LOOP;
    --
    add_segments
      (p_application_id               => p_application_id
      ,p_descriptive_flexfield_name   => p_descriptive_flexfield_name
      ,p_descr_flex_context_code      => p_descr_flex_context_code
      ,p_effective_date               => p_effective_date
      ,p_segments                     => l_segments
      );
  --
  END IF;
  --
  RETURN(l_segments);
--
END segments;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< segments_pst >-----------------------------|
-- -----------------------------------------------------------------------------
FUNCTION segments_pst
  (p_application_short_name       IN     fnd_application.application_short_name%TYPE
  ,p_descriptive_flexfield_name   IN     fnd_descr_flex_contexts.descriptive_flexfield_name%TYPE
  ,p_descr_flex_context_code      IN     fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN t_segments_pst
IS
  --
  --
  --
  CURSOR csr_applications
    (p_application_short_name       IN fnd_application.application_short_name%TYPE
    )
  IS
    SELECT app.application_id
      FROM fnd_application app
     WHERE app.application_short_name = p_application_short_name;
  --
  -- Local variables
  --
  l_segments_pst                 t_segments_pst;
  l_application_id               fnd_application.application_id%TYPE;
  l_segments                     t_segments     := t_segments();
  l_index_number                 NUMBER;
--
BEGIN
  --
  IF (p_application_short_name = g_application_short_name3)
  THEN
    --
    l_application_id := g_application_id3;
  --
  ELSE
    --
    OPEN csr_applications
      (p_application_short_name       => p_application_short_name
      );
    FETCH csr_applications INTO l_application_id;
    CLOSE csr_applications;
    --
    g_application_short_name3 := p_application_short_name;
    g_application_id3 := l_application_id;
  --
  END IF;
  --
  l_segments := segments
    (p_application_id               => l_application_id
    ,p_descriptive_flexfield_name   => p_descriptive_flexfield_name
    ,p_descr_flex_context_code      => p_descr_flex_context_code
    ,p_effective_date               => p_effective_date
    );
  --
  l_index_number := l_segments.FIRST;
  WHILE (l_index_number IS NOT NULL)
  LOOP
    l_segments_pst(l_index_number) := l_segments(l_index_number);
    l_index_number := l_segments.NEXT(l_index_number);
  END LOOP;
  --
  RETURN(l_segments_pst);
--
END segments_pst;
--
END hr_descr_flex_context_info;

/
