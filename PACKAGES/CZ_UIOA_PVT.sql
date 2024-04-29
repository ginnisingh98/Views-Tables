--------------------------------------------------------
--  DDL for Package CZ_UIOA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_UIOA_PVT" AUTHID CURRENT_USER AS
/*	$Header: czuioas.pls 120.3.12010000.3 2009/09/03 13:12:53 vsingava ship $		*/

  G_OA_STYLE_UI                 CONSTANT VARCHAR2(255) := '7';

  g_temp_xmldoc           xmldom.DOMDocument;
  g_temp_source_xml_node  xmldom.DOMNode;
  g_temp_xml_node         xmldom.DOMNode;


  TYPE model_nodes_tbl_type IS TABLE OF CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE INDEX BY VARCHAR2(15);
  TYPE varchar_tbl_type IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

  FAILED_TO_LOCK_MODEL    EXCEPTION;
  FAILED_TO_LOCK_TEMPLATE EXCEPTION;

  --
  -- create a new UI for a given model
  -- Parameters :
  --   p_model_id           - identifies Model
  --   p_master_template_id - identifies UI Master Template
  --   px_ui_def_id         - Id of a new UI
  --   x_return_status      - status string
  --   x_msg_count          - number of error messages
  --   x_msg_data           - string which contains error messages
  --
  PROCEDURE create_UI(p_model_id           IN NUMBER,
                      p_master_template_id IN NUMBER   DEFAULT NULL,
                      p_ui_name            IN VARCHAR2 DEFAULT NULL,
                      p_description        IN VARCHAR2 DEFAULT NULL,
                      p_show_all_nodes     IN VARCHAR2 DEFAULT NULL,
                      p_create_empty_ui    IN VARCHAR2 DEFAULT NULL,
                      x_ui_def_id          OUT NOCOPY  NUMBER,
                      x_return_status      OUT NOCOPY  VARCHAR2,
                      x_msg_count          OUT NOCOPY  NUMBER,
                      x_msg_data           OUT NOCOPY  VARCHAR2);

  --
  -- refresh a given UI
  -- Parameters :
  --   p_ui_def_id          - identifies UI
  --   x_return_status      - status string
  --   x_msg_count          - number of error messages
  --   x_msg_data           - string which contains error messages
  --
  PROCEDURE refresh_UI(p_ui_def_id     IN NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count     OUT NOCOPY NUMBER,
                       x_msg_data      OUT NOCOPY VARCHAR2);

  --
  -- refresh given UI element recursively
  --
  PROCEDURE refresh_UI_Subtree(p_element_id            IN VARCHAR2,
                               p_page_id               IN NUMBER,
                               p_suppress_refresh_flag IN VARCHAR2 DEFAULT NULL);

  FUNCTION parse_JRAD_Document(p_doc_full_name IN VARCHAR2)
    RETURN xmldom.DOMDocument;

  PROCEDURE Save_Document(p_xml_doc  xmldom.DOMDocument,
                          p_doc_name IN VARCHAR2);

  FUNCTION create_UI_Page(p_node          IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                          x_page_set_id   OUT NOCOPY NUMBER,
                          x_page_set_type OUT NOCOPY NUMBER,
                          x_page_ref_id   OUT NOCOPY NUMBER,
                          p_parent_page_id IN NUMBER DEFAULT NULL)
    RETURN CZ_UI_PAGE_ELEMENTS%ROWTYPE;

  PROCEDURE add_CX_Button(p_node                IN CZ_UITEMPLS_FOR_PSNODES_V%ROWTYPE,
                          p_ui_node             IN CZ_UI_PAGE_ELEMENTS%ROWTYPE);

  PROCEDURE delete_UI_Subtree(p_ui_def_id      IN NUMBER,
                              p_ui_page_id     IN NUMBER,
                              p_element_id     IN VARCHAR2,
                              p_delete_xml     IN VARCHAR2,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2);

  PROCEDURE delete_UI_Page(p_ui_def_id      IN NUMBER,         -- ui_def_id of UI
                            p_ui_page_id    IN NUMBER,        -- page_id of
                                                                -- UI page which needs
                                                                -- to be deleted.
                            x_return_status  OUT NOCOPY VARCHAR2,-- status string
                            x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                            x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                            );


  PROCEDURE delete_UI_Page_Ref(p_ui_def_id      IN NUMBER,         -- ui_def_id of UI
                                p_page_ref_id   IN NUMBER,       -- page_ref_id of
                                                                    -- Menu/Page Flow link which needs
                                                                    -- to be deleted.
                                x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                );

  PROCEDURE delete_Local_Template(p_template_ui_def_id  IN NUMBER,      -- ui_def_id of UI
                                   p_template_id        IN NUMBER,    -- template_id of
                                                                        -- Local UI Template which needs
                                                                        -- to be deleted.
                                   x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                   x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                   x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                   );

  PROCEDURE delete_Local_Template_Elem(p_template_ui_def_id IN NUMBER,          -- ui_def_id of UI
                                       p_template_id        IN NUMBER,        -- template_id of
                                       p_element_id         IN VARCHAR2,        -- element_id of Element to delete
                                       x_return_status      OUT NOCOPY VARCHAR2,-- status string
                                       x_msg_count          OUT NOCOPY NUMBER,  -- number of error messages
                                       x_msg_data           OUT NOCOPY VARCHAR2 -- string which contains error messages
                                       );


  --
  -- This procedure copies a UI element and its subtree specified by parameters p_element_id, p_page_id and p_ui_def_id to
  -- to a new location specified by paremeters p_new_parent_element_id - new parent UI element  and p_target_ui_def_id.
  -- For all caption intl_text_ids, UI condtion rules ids  from the source page a new copies will be created for use in the copied page.
	-- Action records associated to the UI Elements will also be copied, pointing to the same action as the source Element.
  --
  PROCEDURE copy_UI_Subtree(p_source_ui_def_id      IN NUMBER,    -- ui_def_id of source UI
                            p_source_element_id     IN VARCHAR2,  -- element_id of
                                                                  -- UI element which needs
                                                                  -- to be copied ( source element )
                            p_source_ui_page_id IN NUMBER,        -- page_id of UI page to which source element belongs to
                            p_target_ui_def_id  IN NUMBER, -- ui_def_id of target UI
                            p_target_ui_page_id IN NUMBER,        -- page_id of target UI page
                            p_target_parent_element_id     IN VARCHAR2,  -- element_id of
                                                                         -- new parent UI element
                            x_new_element_id OUT NOCOPY VARCHAR2,     -- element_id of copied UI element
                            x_return_status  OUT NOCOPY VARCHAR2,-- status string
                            x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                            x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                            );

  PROCEDURE copy_UI_Page (p_source_ui_def_id       IN NUMBER,         -- ui_def_id of UI
                          p_source_ui_page_id      IN NUMBER,        -- page_id of
                                                               -- UI page which needs
                                                               -- to be copied
                          p_target_ui_def_id  IN NUMBER,        -- ui_def_id of target UI
                          x_new_ui_page_id    OUT NOCOPY NUMBER,-- page_id of copied UI page
                          x_return_status  OUT NOCOPY VARCHAR2,-- status string
                          x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                          x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                          );


  PROCEDURE copy_UI_Page_Ref(p_source_ui_def_id      IN NUMBER,    -- ui_def_id of UI
                             p_source_page_ref_id    IN NUMBER,  -- page_ref_id of
                                                                   -- Menu/Page Flow link which needs
                                                                   -- to be deleted.
                             p_target_ui_def_id       IN NUMBER,   -- ui_def_id of target UI
                             p_target_parent_page_ref_id IN NUMBER,-- new parent page ref id
                             x_page_ref_id OUT NOCOPY NUMBER,    -- template_id of
                                                                   -- Local UI Template which needs
                                                                   -- to be copied
                             x_return_status  OUT NOCOPY VARCHAR2, -- status string
                             x_msg_count      OUT NOCOPY NUMBER,   -- number of error messages
                             x_msg_data       OUT NOCOPY VARCHAR2  -- string which contains error messages
                             );


  PROCEDURE copy_Local_Template(p_source_ui_def_id       IN NUMBER,   -- ui_def_id of UI
                                p_source_template_id     IN NUMBER, -- template_id of
                                                                      -- Local UI Template which needs
                                                                      -- to be copied
                                p_target_ui_def_id       IN NUMBER,           -- ui_def_id of target UI
                                x_new_template_id        OUT NOCOPY NUMBER, -- template_id of
                                                                              -- Local UI Template which needs
                                                                              -- to be copied
                                x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                );

  PROCEDURE copy_Local_Template_Elem(p_source_ui_def_id      IN NUMBER,         -- ui_def_id of UI
                                     p_source_template_id    IN NUMBER,        -- template_id of
                                                                                 -- Local UI Template which needs
                                                                                 -- to be copied
                                     p_source_element_id     IN VARCHAR2,
                                     p_target_ui_def_id      IN NUMBER,          -- ui_def_id of UI
                                     p_target_template_id    IN NUMBER,        -- template_id of
                                                                                 -- Local UI Template which needs
                                                                                 -- to be copied
                                     p_target_parent_element_id IN VARCHAR2,
                                     x_new_element_id OUT NOCOPY VARCHAR2,       -- template_id of
                                                                                 -- Local UI Template which needs
                                                                                 -- to be copied
                                     x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                     x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                     x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                     );


  --
  -- This procedure creates a new copy of JRAD document specified by parameter p_source_jrad_doc
  -- new copy will have full JRAD path = p_target_jrad_doc
  --
  PROCEDURE copy_JRAD_Document(p_source_jrad_doc    IN VARCHAR2,   -- specify source JRAD document that will be copied
                               p_target_jrad_doc    IN VARCHAR2,   -- specify full JRAD path of new copy
                               x_return_status      OUT NOCOPY VARCHAR2,-- status string
                               x_msg_count          OUT NOCOPY NUMBER,  -- number of error messages
                               x_msg_data           OUT NOCOPY VARCHAR2 -- string which contains error messages
                               );

  PROCEDURE create_Region_From_Template (p_ui_def_id       IN NUMBER,   -- ui_def_id of UI
                                         p_template_id     IN NUMBER, -- template_id of
                                                                        -- Local UI Template which needs
                                                                        -- to be copied
                                         p_template_ui_def_id    IN NUMBER,
                                         p_ui_page_id            IN NUMBER,
                                         p_parent_element_id     IN VARCHAR2, -- ui_def_id of target UI
                                         x_new_element_id        OUT NOCOPY VARCHAR2, -- element_id of new UI region
                                         x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                         x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                         x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                         );

  PROCEDURE convert_Template_Reference  (p_ui_def_id      IN NUMBER,
                                         p_ui_page_id     IN NUMBER,
                                         p_element_id     IN VARCHAR2,
                                         x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                         x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                         x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                         );

  PROCEDURE add_Template_To_Template (p_template_id                 IN NUMBER,
                                      p_template_ui_def_id          IN NUMBER,
                                      p_target_template_id          IN NUMBER,
                                      p_target_template_ui_def_id   IN NUMBER,
                                      p_parent_element_id           IN VARCHAR2,          -- ui_def_id of target UI
                                      x_new_element_id        OUT NOCOPY VARCHAR2, -- element_id of new UI region
                                      x_return_status  OUT NOCOPY VARCHAR2,-- status string
                                      x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                                      x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                                      );

  ------------------------------------------------------------------------------
  ------------- some procedures for fast access to UI Generation ---------------
  ------------------------------------------------------------------------------

  FUNCTION get_Element_XML_Path(p_ui_def_id      IN NUMBER,
                                p_page_id        IN NUMBER,
                                p_element_id     IN VARCHAR2,
                                p_is_parser_open IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

  -- validate all UI conditions of given UI
  PROCEDURE validate_UI_Conditions(p_ui_def_id      IN NUMBER,
                                   p_is_parser_open IN VARCHAR2 DEFAULT NULL);

  --
  -- update UI Reference when target ui_def_id is changed
  -- ( it is called by Developer )
  --
  PROCEDURE update_UI_Reference
  (
   p_ui_def_id              IN NUMBER,
   p_ref_persistent_node_id IN NUMBER,
   p_new_target_ui_def_id   IN NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2,-- status string
   x_msg_count              OUT NOCOPY NUMBER,  -- number of error messages
   x_msg_data               OUT NOCOPY VARCHAR2 -- string which contains error messages
  );

  --
  -- simple UI Generation
  --
  PROCEDURE cui(p_model_id           IN NUMBER,
                p_master_template_id IN NUMBER DEFAULT NULL,
                p_ui_name            IN VARCHAR2 DEFAULT NULL,
                p_description        IN VARCHAR2 DEFAULT NULL,
                p_show_all_nodes     IN VARCHAR2 DEFAULT NULL,
                p_create_empty_ui    IN VARCHAR2 DEFAULT NULL,
                p_handling_mode      IN VARCHAR2 DEFAULT NULL);

  --
  -- simple UI Refresh
  --
  PROCEDURE rui(p_ui_def_id     IN NUMBER,
                p_handling_mode IN VARCHAR2 DEFAULT NULL);
  --vsingava bug8688987 24th Jul '09
  --
  --Moves  a given ui_page from one ui to another target ui
  --
  PROCEDURE move_JRAD_Document (p_source_jrad_doc IN VARCHAR2,      -- jrad_doc of a ui page to be moved
                          p_source_page_id         IN  NUMBER,      -- ui page_id of the page being moved
                          p_source_ui_def_id       IN NUMBER,         -- ui_def_id of UI
                          p_target_ui_def_id  IN NUMBER,        -- ui_def_id of target UI
                          x_new_jrad_doc    OUT NOCOPY VARCHAR2,-- jrad_doc of moved UI page doc
                          x_return_status  OUT NOCOPY VARCHAR2,-- status string
                          x_msg_count      OUT NOCOPY NUMBER,  -- number of error messages
                          x_msg_data       OUT NOCOPY VARCHAR2 -- string which contains error messages
                          );
END CZ_UIOA_PVT;

/
