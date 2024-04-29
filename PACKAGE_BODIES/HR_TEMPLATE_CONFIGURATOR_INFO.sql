--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_CONFIGURATOR_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_CONFIGURATOR_INFO" 
/* $Header: hrtcrinf.pkb 120.0 2005/05/31 03:01:16 appldev noship $ */
AS
  --
  g_configurating                BOOLEAN   := FALSE;
  g_form_template_id             NUMBER;
  g_objects                      t_objects := t_objects();
  g_events                       t_events  := t_events();
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< configurating >-----------------------------|
-- -----------------------------------------------------------------------------
FUNCTION configurating
RETURN BOOLEAN
IS
BEGIN
  RETURN(g_configurating);
END configurating;
--
-- -----------------------------------------------------------------------------
-- |---------------------------< set_configurating >---------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE set_configurating
  (p_configurating                IN     BOOLEAN
  )
IS
BEGIN
  IF (p_configurating IS NOT NULL)
  THEN
    g_configurating := p_configurating;
  END IF;
END set_configurating;
--
-- -----------------------------------------------------------------------------
-- |---------------------------< form_template_id >----------------------------|
-- -----------------------------------------------------------------------------
FUNCTION form_template_id
RETURN NUMBER
IS
BEGIN
  RETURN(g_form_template_id);
END form_template_id;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< set_form_template_id >--------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE set_form_template_id
  (p_form_template_id             IN     NUMBER
  )
IS
BEGIN
  g_form_template_id := p_form_template_id;
END set_form_template_id;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< index_number >------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION index_number
  (p_object_type                  IN     VARCHAR2
  ,p_object_name                  IN     VARCHAR2
  ,p_event                        IN     VARCHAR2
  ,p_radio_button_name            IN     VARCHAR2 DEFAULT NULL
  ,p_property_type                IN     NUMBER   DEFAULT NULL
  ,p_tab_page_name                IN     VARCHAR2 DEFAULT NULL
  ,p_context_type                 IN     VARCHAR2 DEFAULT NULL
  ,p_segment1                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment2                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment3                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment4                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment5                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment6                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment7                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment8                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment9                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment10                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment11                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment12                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment13                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment14                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment15                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment16                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment17                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment18                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment19                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment20                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment21                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment22                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment23                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment24                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment25                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment26                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment27                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment28                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment29                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment30                    IN     VARCHAR2 DEFAULT NULL
  )
RETURN NUMBER
IS
  l_index_number                 NUMBER;
  l_object_found                 BOOLEAN := FALSE;
BEGIN
  l_index_number := g_objects.FIRST;
  WHILE (   (NOT l_object_found)
        AND (l_index_number IS NOT NULL) )
  LOOP
    IF (   (g_objects(l_index_number).object_type   = p_object_type)
       AND (g_objects(l_index_number).object_name   = p_object_name)
       AND (g_objects(l_index_number).event         = p_event)
       AND (  (g_objects(l_index_number).radio_button_name = p_radio_button_name)
           OR (p_radio_button_name IS NULL) )
       AND (  (g_objects(l_index_number).property_type = p_property_type)
           OR (p_property_type IS NULL) )
       AND (  (g_objects(l_index_number).tab_page_name = p_tab_page_name)
           OR (p_tab_page_name IS NULL) )
       AND (  (g_objects(l_index_number).context_type  = p_context_type)
           OR (p_context_type IS NULL) )
       AND (  (g_objects(l_index_number).segment1  = p_segment1 )
           OR (p_segment1  IS NULL) )
       AND (  (g_objects(l_index_number).segment2  = p_segment2 )
           OR (p_segment2  IS NULL) )
       AND (  (g_objects(l_index_number).segment3  = p_segment3 )
           OR (p_segment3  IS NULL) )
       AND (  (g_objects(l_index_number).segment4  = p_segment4 )
           OR (p_segment4  IS NULL) )
       AND (  (g_objects(l_index_number).segment5  = p_segment5 )
           OR (p_segment5  IS NULL) )
       AND (  (g_objects(l_index_number).segment6  = p_segment6 )
           OR (p_segment6  IS NULL) )
       AND (  (g_objects(l_index_number).segment7  = p_segment7 )
           OR (p_segment7  IS NULL) )
       AND (  (g_objects(l_index_number).segment8  = p_segment8 )
           OR (p_segment8  IS NULL) )
       AND (  (g_objects(l_index_number).segment9  = p_segment9 )
           OR (p_segment9  IS NULL) )
       AND (  (g_objects(l_index_number).segment10 = p_segment10)
           OR (p_segment10 IS NULL) )
       AND (  (g_objects(l_index_number).segment11 = p_segment11)
           OR (p_segment11 IS NULL) )
       AND (  (g_objects(l_index_number).segment12 = p_segment12)
           OR (p_segment12 IS NULL) )
       AND (  (g_objects(l_index_number).segment13 = p_segment13)
           OR (p_segment13 IS NULL) )
       AND (  (g_objects(l_index_number).segment14 = p_segment14)
           OR (p_segment14 IS NULL) )
       AND (  (g_objects(l_index_number).segment15 = p_segment15)
           OR (p_segment15 IS NULL) )
       AND (  (g_objects(l_index_number).segment16 = p_segment16)
           OR (p_segment16 IS NULL) )
       AND (  (g_objects(l_index_number).segment17 = p_segment17)
           OR (p_segment17 IS NULL) )
       AND (  (g_objects(l_index_number).segment18 = p_segment18)
           OR (p_segment18 IS NULL) )
       AND (  (g_objects(l_index_number).segment19 = p_segment19)
           OR (p_segment19 IS NULL) )
       AND (  (g_objects(l_index_number).segment20 = p_segment20)
           OR (p_segment20 IS NULL) )
       AND (  (g_objects(l_index_number).segment21 = p_segment21)
           OR (p_segment21 IS NULL) )
       AND (  (g_objects(l_index_number).segment22 = p_segment22)
           OR (p_segment22 IS NULL) )
       AND (  (g_objects(l_index_number).segment23 = p_segment23)
           OR (p_segment23 IS NULL) )
       AND (  (g_objects(l_index_number).segment24 = p_segment24)
           OR (p_segment24 IS NULL) )
       AND (  (g_objects(l_index_number).segment25 = p_segment25)
           OR (p_segment25 IS NULL) )
       AND (  (g_objects(l_index_number).segment26 = p_segment26)
           OR (p_segment26 IS NULL) )
       AND (  (g_objects(l_index_number).segment27 = p_segment27)
           OR (p_segment27 IS NULL) )
       AND (  (g_objects(l_index_number).segment28 = p_segment28)
           OR (p_segment28 IS NULL) )
       AND (  (g_objects(l_index_number).segment29 = p_segment29)
           OR (p_segment29 IS NULL) )
       AND (  (g_objects(l_index_number).segment30 = p_segment30)
           OR (p_segment30 IS NULL) ) )
    THEN
      l_object_found := TRUE;
    ELSE
      l_index_number := g_objects.NEXT(l_index_number);
    END IF;
  END LOOP;
  IF (NOT l_object_found)
  THEN
    g_objects.EXTEND;
    l_index_number := g_objects.LAST;
    g_objects(l_index_number).object_type   := p_object_type;
    g_objects(l_index_number).object_name   := p_object_name;
    g_objects(l_index_number).event         := p_event;
    g_objects(l_index_number).radio_button_name := p_radio_button_name;
    g_objects(l_index_number).property_type := p_property_type;
    g_objects(l_index_number).tab_page_name := p_tab_page_name;
    g_objects(l_index_number).context_type  := p_context_type;
    g_objects(l_index_number).segment1      := p_segment1;
    g_objects(l_index_number).segment2      := p_segment2;
    g_objects(l_index_number).segment3      := p_segment3;
    g_objects(l_index_number).segment4      := p_segment4;
    g_objects(l_index_number).segment5      := p_segment5;
    g_objects(l_index_number).segment6      := p_segment6;
    g_objects(l_index_number).segment7      := p_segment7;
    g_objects(l_index_number).segment8      := p_segment8;
    g_objects(l_index_number).segment9      := p_segment9;
    g_objects(l_index_number).segment10     := p_segment10;
    g_objects(l_index_number).segment11     := p_segment11;
    g_objects(l_index_number).segment12     := p_segment12;
    g_objects(l_index_number).segment13     := p_segment13;
    g_objects(l_index_number).segment14     := p_segment14;
    g_objects(l_index_number).segment15     := p_segment15;
    g_objects(l_index_number).segment16     := p_segment16;
    g_objects(l_index_number).segment17     := p_segment17;
    g_objects(l_index_number).segment18     := p_segment18;
    g_objects(l_index_number).segment19     := p_segment19;
    g_objects(l_index_number).segment20     := p_segment20;
    g_objects(l_index_number).segment21     := p_segment21;
    g_objects(l_index_number).segment22     := p_segment22;
    g_objects(l_index_number).segment23     := p_segment23;
    g_objects(l_index_number).segment24     := p_segment24;
    g_objects(l_index_number).segment25     := p_segment25;
    g_objects(l_index_number).segment26     := p_segment26;
    g_objects(l_index_number).segment27     := p_segment27;
    g_objects(l_index_number).segment28     := p_segment28;
    g_objects(l_index_number).segment29     := p_segment29;
    g_objects(l_index_number).segment30     := p_segment30;
  END IF;
  RETURN(l_index_number);
END index_number;
--
-- -----------------------------------------------------------------------------
-- |--------------------------------< objects >--------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION objects
RETURN t_objects
IS
  l_objects                      t_objects := t_objects();
  l_index_number                 NUMBER;
BEGIN
  l_index_number := g_objects.FIRST;
  WHILE (l_index_number IS NOT NULL)
  LOOP
    IF (g_objects(l_index_number).processed)
    THEN
      NULL;
    ELSE
      l_objects.EXTEND;
      l_objects(l_objects.LAST) := g_objects(l_index_number);
    END IF;
    l_index_number := g_objects.NEXT(l_index_number);
  END LOOP;
  RETURN(l_objects);
END objects;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< objects_pst >------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION objects_pst
RETURN t_objects_pst
IS
  l_objects_pst                  t_objects_pst;
  l_objects                      t_objects;
  l_index_number                 NUMBER;
BEGIN
  l_objects := objects();
  l_index_number := l_objects.FIRST;
  WHILE (l_index_number IS NOT NULL)
  LOOP
    l_objects_pst(l_index_number) := l_objects(l_index_number);
    l_index_number := l_objects.NEXT(l_index_number);
  END LOOP;
  RETURN(l_objects_pst);
END objects_pst;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< commit_objects >----------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE commit_objects
IS
  l_index_number                 NUMBER;
BEGIN
  l_index_number := index_number
    (p_object_type                  => NULL
    ,p_object_name                  => NULL
    ,p_event                        => 'COMMIT'
    );
  g_objects(l_index_number).processed := FALSE;
END commit_objects;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< create_object >-----------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE create_object
  (p_object_type                  IN     VARCHAR2
  ,p_object_name                  IN     VARCHAR2
  ,p_radio_button_name            IN     VARCHAR2 DEFAULT NULL
  ,p_tab_page_name                IN     VARCHAR2 DEFAULT NULL
  ,p_context_type                 IN     VARCHAR2 DEFAULT NULL
  ,p_segment1                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment2                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment3                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment4                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment5                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment6                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment7                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment8                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment9                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment10                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment11                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment12                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment13                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment14                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment15                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment16                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment17                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment18                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment19                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment20                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment21                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment22                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment23                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment24                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment25                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment26                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment27                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment28                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment29                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment30                    IN     VARCHAR2 DEFAULT NULL
  )
IS
  l_index_number                 NUMBER;
BEGIN
  l_index_number := index_number
    (p_object_type                  => p_object_type
    ,p_object_name                  => p_object_name
    ,p_event                        => 'CREATE'
    ,p_radio_button_name            => p_radio_button_name
    ,p_tab_page_name                => p_tab_page_name
    ,p_context_type                 => p_context_type
    ,p_segment1                     => p_segment1
    ,p_segment2                     => p_segment2
    ,p_segment3                     => p_segment3
    ,p_segment4                     => p_segment4
    ,p_segment5                     => p_segment5
    ,p_segment6                     => p_segment6
    ,p_segment7                     => p_segment7
    ,p_segment8                     => p_segment8
    ,p_segment9                     => p_segment9
    ,p_segment10                    => p_segment10
    ,p_segment11                    => p_segment11
    ,p_segment12                    => p_segment12
    ,p_segment13                    => p_segment13
    ,p_segment14                    => p_segment14
    ,p_segment15                    => p_segment15
    ,p_segment16                    => p_segment16
    ,p_segment17                    => p_segment17
    ,p_segment18                    => p_segment18
    ,p_segment19                    => p_segment19
    ,p_segment20                    => p_segment20
    ,p_segment21                    => p_segment21
    ,p_segment22                    => p_segment22
    ,p_segment23                    => p_segment23
    ,p_segment24                    => p_segment24
    ,p_segment25                    => p_segment25
    ,p_segment26                    => p_segment26
    ,p_segment27                    => p_segment27
    ,p_segment28                    => p_segment28
    ,p_segment29                    => p_segment29
    ,p_segment30                    => p_segment30
    );
  g_objects(l_index_number).processed := FALSE;
END create_object;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< delete_object >-----------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE delete_object
  (p_object_type                  IN     VARCHAR2
  ,p_object_name                  IN     VARCHAR2
  ,p_radio_button_name            IN     VARCHAR2 DEFAULT NULL
  ,p_tab_page_name                IN     VARCHAR2 DEFAULT NULL
  ,p_context_type                 IN     VARCHAR2 DEFAULT NULL
  ,p_segment1                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment2                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment3                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment4                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment5                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment6                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment7                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment8                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment9                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment10                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment11                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment12                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment13                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment14                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment15                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment16                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment17                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment18                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment19                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment20                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment21                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment22                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment23                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment24                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment25                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment26                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment27                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment28                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment29                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment30                    IN     VARCHAR2 DEFAULT NULL
  )
IS
  l_index_number                 NUMBER;
BEGIN
  l_index_number := index_number
    (p_object_type                  => p_object_type
    ,p_object_name                  => p_object_name
    ,p_event                        => 'DELETE'
    ,p_radio_button_name            => p_radio_button_name
    ,p_tab_page_name                => p_tab_page_name
    ,p_context_type                 => p_context_type
    ,p_segment1                     => p_segment1
    ,p_segment2                     => p_segment2
    ,p_segment3                     => p_segment3
    ,p_segment4                     => p_segment4
    ,p_segment5                     => p_segment5
    ,p_segment6                     => p_segment6
    ,p_segment7                     => p_segment7
    ,p_segment8                     => p_segment8
    ,p_segment9                     => p_segment9
    ,p_segment10                    => p_segment10
    ,p_segment11                    => p_segment11
    ,p_segment12                    => p_segment12
    ,p_segment13                    => p_segment13
    ,p_segment14                    => p_segment14
    ,p_segment15                    => p_segment15
    ,p_segment16                    => p_segment16
    ,p_segment17                    => p_segment17
    ,p_segment18                    => p_segment18
    ,p_segment19                    => p_segment19
    ,p_segment20                    => p_segment20
    ,p_segment21                    => p_segment21
    ,p_segment22                    => p_segment22
    ,p_segment23                    => p_segment23
    ,p_segment24                    => p_segment24
    ,p_segment25                    => p_segment25
    ,p_segment26                    => p_segment26
    ,p_segment27                    => p_segment27
    ,p_segment28                    => p_segment28
    ,p_segment29                    => p_segment29
    ,p_segment30                    => p_segment30
    );
  g_objects(l_index_number).processed := FALSE;
END delete_object;
--
-- -----------------------------------------------------------------------------
-- |----------------------------< process_objects >----------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE process_objects
IS
  l_index_number                 NUMBER;
  l_committed                    BOOLEAN := FALSE;
BEGIN
  l_index_number := g_objects.FIRST;
  WHILE (   (NOT l_committed)
        AND (l_index_number IS NOT NULL) )
  LOOP
    IF (g_objects(l_index_number).processed)
    THEN
      NULL;
    ELSE
      IF (g_objects(l_index_number).event = 'COMMIT')
      THEN
        l_committed := TRUE;
      END IF;
      g_objects(l_index_number).processed := TRUE;
    END IF;
    l_index_number := g_objects.NEXT(l_index_number);
  END LOOP;
  IF (l_committed)
  THEN
    g_objects := t_objects();
  END IF;
  g_events := t_events();
END process_objects;
--
-- -----------------------------------------------------------------------------
-- |----------------------------< rollback_object >----------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE rollback_object
  (p_object_type                  IN     VARCHAR2
  ,p_object_name                  IN     VARCHAR2
  ,p_radio_button_name            IN     VARCHAR2 DEFAULT NULL
  ,p_context_type                 IN     VARCHAR2 DEFAULT NULL
  ,p_segment1                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment2                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment3                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment4                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment5                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment6                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment7                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment8                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment9                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment10                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment11                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment12                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment13                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment14                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment15                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment16                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment17                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment18                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment19                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment20                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment21                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment22                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment23                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment24                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment25                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment26                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment27                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment28                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment29                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment30                    IN     VARCHAR2 DEFAULT NULL
  )
IS
  l_index_number                 NUMBER;
BEGIN
  l_index_number := index_number
    (p_object_type                  => p_object_type
    ,p_object_name                  => p_object_name
    ,p_event                        => 'ROLLBACK'
    ,p_radio_button_name            => p_radio_button_name
    ,p_context_type                 => p_context_type
    ,p_segment1                     => p_segment1
    ,p_segment2                     => p_segment2
    ,p_segment3                     => p_segment3
    ,p_segment4                     => p_segment4
    ,p_segment5                     => p_segment5
    ,p_segment6                     => p_segment6
    ,p_segment7                     => p_segment7
    ,p_segment8                     => p_segment8
    ,p_segment9                     => p_segment9
    ,p_segment10                    => p_segment10
    ,p_segment11                    => p_segment11
    ,p_segment12                    => p_segment12
    ,p_segment13                    => p_segment13
    ,p_segment14                    => p_segment14
    ,p_segment15                    => p_segment15
    ,p_segment16                    => p_segment16
    ,p_segment17                    => p_segment17
    ,p_segment18                    => p_segment18
    ,p_segment19                    => p_segment19
    ,p_segment20                    => p_segment20
    ,p_segment21                    => p_segment21
    ,p_segment22                    => p_segment22
    ,p_segment23                    => p_segment23
    ,p_segment24                    => p_segment24
    ,p_segment25                    => p_segment25
    ,p_segment26                    => p_segment26
    ,p_segment27                    => p_segment27
    ,p_segment28                    => p_segment28
    ,p_segment29                    => p_segment29
    ,p_segment30                    => p_segment30
    );
  g_objects(l_index_number).processed := FALSE;
END rollback_object;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< update_object >-----------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE update_object
  (p_object_type                  IN     VARCHAR2
  ,p_object_name                  IN     VARCHAR2
  ,p_radio_button_name            IN     VARCHAR2 DEFAULT NULL
  ,p_property_type                IN     NUMBER   DEFAULT NULL
  ,p_property_value               IN     VARCHAR2 DEFAULT NULL
  ,p_tab_page_name                IN     VARCHAR2 DEFAULT NULL
  ,p_context_type                 IN     VARCHAR2 DEFAULT NULL
  ,p_segment1                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment2                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment3                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment4                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment5                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment6                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment7                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment8                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment9                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment10                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment11                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment12                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment13                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment14                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment15                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment16                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment17                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment18                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment19                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment20                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment21                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment22                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment23                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment24                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment25                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment26                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment27                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment28                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment29                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment30                    IN     VARCHAR2 DEFAULT NULL
  )
IS
  l_index_number                 NUMBER;
BEGIN
  l_index_number := index_number
    (p_object_type                  => p_object_type
    ,p_object_name                  => p_object_name
    ,p_event                        => 'UPDATE'
    ,p_radio_button_name            => p_radio_button_name
    ,p_property_type                => p_property_type
    ,p_tab_page_name                => p_tab_page_name
    ,p_context_type                 => p_context_type
    ,p_segment1                     => p_segment1
    ,p_segment2                     => p_segment2
    ,p_segment3                     => p_segment3
    ,p_segment4                     => p_segment4
    ,p_segment5                     => p_segment5
    ,p_segment6                     => p_segment6
    ,p_segment7                     => p_segment7
    ,p_segment8                     => p_segment8
    ,p_segment9                     => p_segment9
    ,p_segment10                    => p_segment10
    ,p_segment11                    => p_segment11
    ,p_segment12                    => p_segment12
    ,p_segment13                    => p_segment13
    ,p_segment14                    => p_segment14
    ,p_segment15                    => p_segment15
    ,p_segment16                    => p_segment16
    ,p_segment17                    => p_segment17
    ,p_segment18                    => p_segment18
    ,p_segment19                    => p_segment19
    ,p_segment20                    => p_segment20
    ,p_segment21                    => p_segment21
    ,p_segment22                    => p_segment22
    ,p_segment23                    => p_segment23
    ,p_segment24                    => p_segment24
    ,p_segment25                    => p_segment25
    ,p_segment26                    => p_segment26
    ,p_segment27                    => p_segment27
    ,p_segment28                    => p_segment28
    ,p_segment29                    => p_segment29
    ,p_segment30                    => p_segment30
    );
  g_objects(l_index_number).property_value := p_property_value;
  g_objects(l_index_number).processed := FALSE;
END update_object;
--
-- -----------------------------------------------------------------------------
-- |--------------------------------< events >---------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION events
RETURN t_events
IS
  l_events                       t_events := t_events();
  l_index_number                 NUMBER;
BEGIN
  l_index_number := g_events.FIRST;
  WHILE (l_index_number IS NOT NULL)
  LOOP
    IF (g_events(l_index_number).processed)
    THEN
      NULL;
    ELSE
      l_events.EXTEND;
      l_events(l_events.LAST) := g_events(l_index_number);
    END IF;
    l_index_number := g_events.NEXT(l_index_number);
  END LOOP;
  RETURN(l_events);
END events;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< events_pst >-------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION events_pst
RETURN t_events_pst
IS
  l_events_pst                   t_events_pst;
  l_events                       t_events;
  l_index_number                 NUMBER;
BEGIN
  l_events := events();
  l_index_number := l_events.FIRST;
  WHILE (l_index_number IS NOT NULL)
  LOOP
    l_events_pst(l_index_number) := l_events(l_index_number);
    l_index_number := l_events.NEXT(l_index_number);
  END LOOP;
  RETURN(l_events_pst);
END events_pst;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< set_context >------------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE set_context
  (p_full_item_name               IN     VARCHAR2
  ,p_context_type                 IN     VARCHAR2
  ,p_segment1                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment2                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment3                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment4                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment5                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment6                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment7                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment8                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment9                     IN     VARCHAR2 DEFAULT NULL
  ,p_segment10                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment11                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment12                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment13                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment14                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment15                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment16                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment17                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment18                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment19                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment20                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment21                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment22                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment23                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment24                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment25                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment26                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment27                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment28                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment29                    IN     VARCHAR2 DEFAULT NULL
  ,p_segment30                    IN     VARCHAR2 DEFAULT NULL
  )
IS
BEGIN
  g_events.EXTEND;
  g_events(g_events.LAST).event_name     := 'SET_CONTEXT';
  g_events(g_events.LAST).full_item_name := p_full_item_name;
  g_events(g_events.LAST).context_type   := p_context_type;
  g_events(g_events.LAST).segment1       := p_segment1;
  g_events(g_events.LAST).segment2       := p_segment2;
  g_events(g_events.LAST).segment3       := p_segment3;
  g_events(g_events.LAST).segment4       := p_segment4;
  g_events(g_events.LAST).segment5       := p_segment5;
  g_events(g_events.LAST).segment6       := p_segment6;
  g_events(g_events.LAST).segment7       := p_segment7;
  g_events(g_events.LAST).segment8       := p_segment8;
  g_events(g_events.LAST).segment9       := p_segment9;
  g_events(g_events.LAST).segment10      := p_segment10;
  g_events(g_events.LAST).segment11      := p_segment11;
  g_events(g_events.LAST).segment12      := p_segment12;
  g_events(g_events.LAST).segment13      := p_segment13;
  g_events(g_events.LAST).segment14      := p_segment14;
  g_events(g_events.LAST).segment15      := p_segment15;
  g_events(g_events.LAST).segment16      := p_segment16;
  g_events(g_events.LAST).segment17      := p_segment17;
  g_events(g_events.LAST).segment18      := p_segment18;
  g_events(g_events.LAST).segment19      := p_segment19;
  g_events(g_events.LAST).segment20      := p_segment20;
  g_events(g_events.LAST).segment21      := p_segment21;
  g_events(g_events.LAST).segment22      := p_segment22;
  g_events(g_events.LAST).segment23      := p_segment23;
  g_events(g_events.LAST).segment24      := p_segment24;
  g_events(g_events.LAST).segment25      := p_segment25;
  g_events(g_events.LAST).segment26      := p_segment26;
  g_events(g_events.LAST).segment27      := p_segment27;
  g_events(g_events.LAST).segment28      := p_segment28;
  g_events(g_events.LAST).segment29      := p_segment29;
  g_events(g_events.LAST).segment30      := p_segment30;
END set_context;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< reset_contexts >----------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE reset_contexts
IS
BEGIN
  g_events.EXTEND;
  g_events(g_events.LAST).event_name := 'RESET_CONTEXTS';
END reset_contexts;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< show_object >------------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE show_object
  (p_object_type                  IN     VARCHAR2
  ,p_object_name                  IN     VARCHAR2
  )
IS
BEGIN
  g_events.EXTEND;
  g_events(g_events.LAST).event_name := 'SHOW_OBJECT';
  g_events(g_events.LAST).object_type := p_object_type;
  g_events(g_events.LAST).object_name := p_object_name;
END show_object;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< close_form >-------------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE close_form
IS
BEGIN
  g_events.EXTEND;
  g_events(g_events.LAST).event_name := 'CLOSE_FORM';
END close_form;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< reinit_item_contexts >--------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE reinit_item_contexts
IS
BEGIN
  g_events.EXTEND;
  g_events(g_events.LAST).event_name := 'REINIT_ITEM_CONTEXTS';
END reinit_item_contexts;
--
END hr_template_configurator_info;

/
