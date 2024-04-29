--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_CONFIGURATOR_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_CONFIGURATOR_INFO" 
/* $Header: hrtcrinf.pkh 120.0 2005/05/31 03:01:36 appldev noship $ */
AUTHID CURRENT_USER AS
  --
  TYPE t_object IS RECORD
    (object_type                    VARCHAR2(30)
    ,object_name                    VARCHAR2(61)
    ,radio_button_name              VARCHAR2(30)
    ,event                          VARCHAR2(30)
    ,property_type                  NUMBER
    ,property_value                 VARCHAR2(2000)
    ,tab_page_name                  VARCHAR2(30)
    ,context_type                   VARCHAR2(150)
    ,segment1                       VARCHAR2(150)
    ,segment2                       VARCHAR2(150)
    ,segment3                       VARCHAR2(150)
    ,segment4                       VARCHAR2(150)
    ,segment5                       VARCHAR2(150)
    ,segment6                       VARCHAR2(150)
    ,segment7                       VARCHAR2(150)
    ,segment8                       VARCHAR2(150)
    ,segment9                       VARCHAR2(150)
    ,segment10                      VARCHAR2(150)
    ,segment11                      VARCHAR2(150)
    ,segment12                      VARCHAR2(150)
    ,segment13                      VARCHAR2(150)
    ,segment14                      VARCHAR2(150)
    ,segment15                      VARCHAR2(150)
    ,segment16                      VARCHAR2(150)
    ,segment17                      VARCHAR2(150)
    ,segment18                      VARCHAR2(150)
    ,segment19                      VARCHAR2(150)
    ,segment20                      VARCHAR2(150)
    ,segment21                      VARCHAR2(150)
    ,segment22                      VARCHAR2(150)
    ,segment23                      VARCHAR2(150)
    ,segment24                      VARCHAR2(150)
    ,segment25                      VARCHAR2(150)
    ,segment26                      VARCHAR2(150)
    ,segment27                      VARCHAR2(150)
    ,segment28                      VARCHAR2(150)
    ,segment29                      VARCHAR2(150)
    ,segment30                      VARCHAR2(150)
    ,processed                      BOOLEAN
    );
  TYPE t_objects IS TABLE OF t_object;
  TYPE t_objects_pst IS TABLE OF t_object INDEX BY BINARY_INTEGER;
  --
  TYPE t_event IS RECORD
    (event_name                     VARCHAR2(30)
    ,object_type                    VARCHAR2(30)
    ,object_name                    VARCHAR2(61)
    ,full_item_name                 VARCHAR2(61)
    ,context_type                   VARCHAR2(150)
    ,segment1                       VARCHAR2(150)
    ,segment2                       VARCHAR2(150)
    ,segment3                       VARCHAR2(150)
    ,segment4                       VARCHAR2(150)
    ,segment5                       VARCHAR2(150)
    ,segment6                       VARCHAR2(150)
    ,segment7                       VARCHAR2(150)
    ,segment8                       VARCHAR2(150)
    ,segment9                       VARCHAR2(150)
    ,segment10                      VARCHAR2(150)
    ,segment11                      VARCHAR2(150)
    ,segment12                      VARCHAR2(150)
    ,segment13                      VARCHAR2(150)
    ,segment14                      VARCHAR2(150)
    ,segment15                      VARCHAR2(150)
    ,segment16                      VARCHAR2(150)
    ,segment17                      VARCHAR2(150)
    ,segment18                      VARCHAR2(150)
    ,segment19                      VARCHAR2(150)
    ,segment20                      VARCHAR2(150)
    ,segment21                      VARCHAR2(150)
    ,segment22                      VARCHAR2(150)
    ,segment23                      VARCHAR2(150)
    ,segment24                      VARCHAR2(150)
    ,segment25                      VARCHAR2(150)
    ,segment26                      VARCHAR2(150)
    ,segment27                      VARCHAR2(150)
    ,segment28                      VARCHAR2(150)
    ,segment29                      VARCHAR2(150)
    ,segment30                      VARCHAR2(150)
    ,processed                      BOOLEAN
    );
  TYPE t_events IS TABLE OF t_event;
  TYPE t_events_pst IS TABLE OF t_event INDEX BY BINARY_INTEGER;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< configurating >-----------------------------|
-- -----------------------------------------------------------------------------
FUNCTION configurating
RETURN BOOLEAN;
--
-- -----------------------------------------------------------------------------
-- |---------------------------< set_configurating >---------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE set_configurating
  (p_configurating                IN     BOOLEAN
  );
--
-- -----------------------------------------------------------------------------
-- |---------------------------< form_template_id >----------------------------|
-- -----------------------------------------------------------------------------
FUNCTION form_template_id
RETURN NUMBER;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< set_form_template_id >--------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE set_form_template_id
  (p_form_template_id             IN     NUMBER
  );
--
-- -----------------------------------------------------------------------------
-- |--------------------------------< objects >--------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION objects
RETURN t_objects;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< objects_pst >------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION objects_pst
RETURN t_objects_pst;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< commit_objects >----------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE commit_objects;
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
  );
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
  );
--
-- -----------------------------------------------------------------------------
-- |----------------------------< process_objects >----------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE process_objects;
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
  );
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
  );
--
-- -----------------------------------------------------------------------------
-- |--------------------------------< events >---------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION events
RETURN t_events;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< events_pst >-------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION events_pst
RETURN t_events_pst;
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
  );
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< reset_contexts >----------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE reset_contexts;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< show_object >------------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE show_object
  (p_object_type                  IN     VARCHAR2
  ,p_object_name                  IN     VARCHAR2
  );
--
-- -----------------------------------------------------------------------------
-- |------------------------------< close_form >-------------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE close_form;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< reinit_item_contexts >--------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE reinit_item_contexts;
--
END hr_template_configurator_info;

 

/
