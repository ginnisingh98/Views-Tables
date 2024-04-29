--------------------------------------------------------
--  DDL for Package POR_IFT_ADMIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_IFT_ADMIN_PKG" AUTHID CURRENT_USER AS
/* $Header: PORIFTAS.pls 115.4 2003/08/25 17:24:46 liwang ship $ */

PROCEDURE insert_template(p_name          IN  VARCHAR2,
                          p_org_id        IN  NUMBER,
                          p_attach_cat_id IN NUMBER,
                          p_user_id       IN  NUMBER,
                          p_login_id      IN  NUMBER,
                          p_template_code IN OUT NOCOPY VARCHAR2,
                          p_row_id        OUT NOCOPY    VARCHAR2);

PROCEDURE lock_template(p_row_id        IN VARCHAR2,
                        p_template_code IN VARCHAR2,
                        p_name          IN VARCHAR2,
                        p_user_id       IN NUMBER,
                        p_login_id      IN NUMBER);


PROCEDURE update_template(p_row_id        IN VARCHAR2,
                          p_template_code IN VARCHAR2,
                          p_name          IN VARCHAR2,
                          p_org_id        IN  NUMBER,
                          p_attach_cat_id IN NUMBER,
                          p_user_id       IN NUMBER,
                          p_login_id      IN NUMBER);

PROCEDURE delete_template(p_row_id   IN VARCHAR2);

PROCEDURE insert_template_attribute(p_template_code     IN  VARCHAR2,
                                    p_display_sequence  IN  NUMBER,
                                    p_attribute_name    IN  VARCHAR2,
                                    p_description       IN  VARCHAR2,
                                    p_default_value     IN  VARCHAR2,
                                    p_flex_value_set_id IN  NUMBER,
                                    p_required_flag     IN  VARCHAR2,
                                    p_node_display_flag IN  VARCHAR2,
                                    p_user_id           IN  NUMBER,
                                    p_login_id          IN  NUMBER,
                                    p_attribute_code    IN OUT NOCOPY VARCHAR2,
                                    p_row_id            OUT NOCOPY VARCHAR2);

PROCEDURE lock_template_attribute(p_row_id            IN VARCHAR2,
                                  p_template_code     IN VARCHAR2,
                                  p_attribute_code    IN VARCHAR2,
                                  p_display_sequence  IN NUMBER,
                                  p_attribute_name    IN VARCHAR2,
                                  p_description       IN VARCHAR2,
                                  p_default_value     IN VARCHAR2,
                                  p_flex_value_set_id IN  NUMBER,
                                  p_required_flag     IN VARCHAR2,
                                  p_node_display_flag IN VARCHAR2,
                                  p_user_id           IN NUMBER,
                                  p_login_id          IN NUMBER);

PROCEDURE update_template_attribute(p_row_id            IN VARCHAR2,
                                    p_template_code     IN VARCHAR2,
                                    p_attribute_code    IN VARCHAR2,
                                    p_display_sequence  IN NUMBER,
                                    p_attribute_name    IN VARCHAR2,
                                    p_description       IN VARCHAR2,
                                    p_default_value     IN VARCHAR2,
                                    p_flex_value_set_id IN  NUMBER,
                                    p_required_flag     IN VARCHAR2,
                                    p_node_display_flag IN VARCHAR2,
                                    p_user_id           IN NUMBER,
                                    p_login_id          IN NUMBER);

PROCEDURE delete_template_attribute(p_row_id   IN VARCHAR2);


PROCEDURE insert_template_assoc(p_region_code           IN  VARCHAR2,
                                p_item_or_category_flag IN  VARCHAR2,
                                p_item_or_category_id   IN  NUMBER,
                                p_user_id               IN  NUMBER,
                                p_login_id              IN  NUMBER,
                                p_template_assoc_id     OUT NOCOPY NUMBER,
                                p_row_id                OUT NOCOPY VARCHAR2);

PROCEDURE lock_template_assoc(p_row_id                IN VARCHAR2,
                              p_template_assoc_id     IN NUMBER,
                              p_region_code           IN VARCHAR2,
                              p_item_or_category_flag IN VARCHAR2,
                              p_item_or_category_id   IN NUMBER,
                              p_user_id               IN NUMBER,
                              p_login_id              IN NUMBER);

PROCEDURE update_template_assoc(p_row_id                IN VARCHAR2,
                                p_template_assoc_id     IN NUMBER,
                                p_region_code           IN VARCHAR2,
                                p_item_or_category_flag IN VARCHAR2,
                                p_item_or_category_id   IN NUMBER,
                                p_user_id               IN NUMBER,
                                p_login_id              IN NUMBER);

PROCEDURE delete_template_assoc(p_row_id IN VARCHAR2);

PROCEDURE delete_all_template_assoc(p_region_code IN VARCHAR2);

PROCEDURE add_language;

END por_ift_admin_pkg;

 

/
