--------------------------------------------------------
--  DDL for Package EGO_TEMPL_ATTRS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_TEMPL_ATTRS_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOTMPLS.pls 120.3 2007/05/02 19:50:20 ssarnoba ship $ */

                       ----------------------
                       -- Global Constants --
                       ----------------------

  G_TRANS_TEXT_DATA_TYPE     CONSTANT VARCHAR2(1) := 'A';
  G_CHAR_DATA_TYPE           CONSTANT VARCHAR2(1) := 'C';
  G_NUMBER_DATA_TYPE         CONSTANT VARCHAR2(1) := 'N';
  G_DATE_DATA_TYPE           CONSTANT VARCHAR2(1) := 'X';
  G_DATE_TIME_DATA_TYPE      CONSTANT VARCHAR2(1) := 'Y';

  G_INDEPENDENT_VALIDATION_CODE   CONSTANT VARCHAR2(1) := 'I';
  G_NONE_VALIDATION_CODE          CONSTANT VARCHAR2(1) := 'N';
  G_TABLE_VALIDATION_CODE         CONSTANT VARCHAR2(1) := 'F';

  G_ATTACH_DISP_TYPE         CONSTANT VARCHAR2(1) := 'A';
  G_CHECKBOX_DISP_TYPE       CONSTANT VARCHAR2(1) := 'C';
  G_DYN_URL_DISP_TYPE        CONSTANT VARCHAR2(1) := 'D';
  G_HIDDEN_DISP_TYPE         CONSTANT VARCHAR2(1) := 'H';
  G_RADIO_DISP_TYPE          CONSTANT VARCHAR2(1) := 'R';
  G_STATIC_URL_DISP_TYPE     CONSTANT VARCHAR2(1) := 'S';
  G_TEXT_FIELD_DISP_TYPE     CONSTANT VARCHAR2(1) := 'T';

  G_LOV_LONGLIST_FLAG        CONSTANT VARCHAR2(1) := 'N';
  G_POPLIST_LONGLIST_FLAG    CONSTANT VARCHAR2(1) := 'X';

                       ----------------------
                       -- Data Types --
                       ----------------------
/* Template Attribute Record Type */
TYPE template_attribute_rec_type IS RECORD
    (
     attr_id                   NUMBER,                      -- EGO attribute id
     attr_group_id             NUMBER,                -- EGO attribute group id
     application_column_name   VARCHAR2(30),     -- MSI_B  column for attribute
     attr_group_name           VARCHAR2(30),             -- EGO attr_group_name
     template_id               NUMBER,                   -- INV/EGO template_id
     enabled_flag              VARCHAR2(1),
     attribute_name            VARCHAR2(50),
     attribute_value           VARCHAR2(240)
    );

                       ----------------------
                       -- Procedures --
                       ----------------------

Procedure Sync_Template
  ( p_template_id      IN NUMBER,
    p_commit           IN VARCHAR2   :=  FND_API.G_FALSE,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_message_text     OUT NOCOPY VARCHAR2
  );


Procedure Sync_Template_Attribute
  ( p_template_id       IN NUMBER,
    p_attribute_name    IN VARCHAR2,
    p_attribute_value   IN VARCHAR2 ,
    p_enabled_flag      IN VARCHAR2 ,
    p_commit            IN VARCHAR2   := FND_API.G_FALSE,
    p_ego_attr_id       IN NUMBER,
    p_ego_attr_group_id IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_message_text      OUT NOCOPY VARCHAR2,
    p_always_insert     IN VARCHAR2   := FND_API.G_FALSE
  );

Procedure Sync_Template_Attribute
  ( p_template_id      IN NUMBER,
    p_attribute_name   IN VARCHAR2,
    p_commit           IN   VARCHAR2  :=  FND_API.G_FALSE,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_message_text     OUT NOCOPY VARCHAR2,
    p_always_insert     IN VARCHAR2   := FND_API.G_FALSE
  );

Procedure Insert_Template_Attribute
      ( p_template_id         IN NUMBER,
        p_attribute_group_id  IN NUMBER,
        p_attribute_id        IN NUMBER,
        p_data_level_id       IN NUMBER,
        p_enabled_flag        IN VARCHAR2,
        p_attribute_value     IN VARCHAR2,
        p_commit              IN VARCHAR2   :=  FND_API.G_FALSE,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_message_text        OUT NOCOPY VARCHAR2
      );

Procedure Update_Template_Attribute
  ( p_template_id          IN NUMBER,
    p_attribute_group_id   IN NUMBER,
    p_attribute_id         IN NUMBER,
    p_data_level_id        IN NUMBER,
    p_enabled_flag         IN VARCHAR2,
    p_attribute_value      IN VARCHAR2,
    p_commit               IN VARCHAR2   :=  FND_API.G_FALSE,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_message_text         OUT NOCOPY VARCHAR2
  );

END EGO_TEMPL_ATTRS_PUB;


/
