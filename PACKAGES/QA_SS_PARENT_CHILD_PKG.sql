--------------------------------------------------------
--  DDL for Package QA_SS_PARENT_CHILD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SS_PARENT_CHILD_PKG" AUTHID CURRENT_USER AS
/* $Header: qapcsss.pls 120.2 2005/12/19 03:56:49 srhariha noship $ */

  TYPE ErrorTable IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

  PROCEDURE post_error_messages (p_errors IN ErrorTable);

  PROCEDURE insert_plan_rel_chk(p_parent_plan_id       IN NUMBER,
                                p_parent_plan_name     IN VARCHAR2,
                                p_child_plan_id             IN NUMBER,
                                p_child_plan_name      IN VARCHAR2,
                                p_data_entry_mode      IN NUMBER,
                                p_layout_mode          IN NUMBER default null,
                                p_num_auto_rows        IN NUMBER,
                                x_parent_plan_id       OUT NOCOPY NUMBER,
                                x_child_plan_id        OUT NOCOPY NUMBER,
                                x_status               OUT NOCOPY VARCHAR2);

  PROCEDURE update_plan_rel_chk(
                           p_parent_plan_id       IN NUMBER,
                           p_parent_plan_name     IN VARCHAR2,
                           p_child_plan_id        IN NUMBER,
                           p_child_plan_name      IN VARCHAR2,
                           p_data_entry_mode      IN NUMBER,
                           p_layout_mode          IN NUMBER default null,
                           p_num_auto_rows        IN NUMBER,
                           p_new_plan             IN VARCHAR2,
                           x_parent_plan_id       OUT NOCOPY NUMBER,
                           x_child_plan_id        OUT NOCOPY NUMBER,
                           x_status               OUT NOCOPY VARCHAR2) ;



  PROCEDURE insert_plan_rel(p_parent_plan_id     NUMBER,
                            p_child_plan_id      NUMBER,
                            p_plan_relationship_type NUMBER,
                            p_data_entry_mode    NUMBER,
                            p_layout_mode        NUMBER default null,
                            p_auto_row_count     NUMBER,
                            p_default_parent_spec VARCHAR2,
                            p_last_updated_by    NUMBER := fnd_global.user_id,
                            p_created_by         NUMBER := fnd_global.user_id,
                            p_last_update_login  NUMBER := fnd_global.user_id,
                            x_plan_relationship_id IN OUT NOCOPY NUMBER);


  PROCEDURE insert_element_rel(p_plan_relationship_id       NUMBER,
                p_parent_char_id              NUMBER,
                p_child_char_id               NUMBER,
                p_element_relationship_type   NUMBER,
                p_link_flag                   VARCHAR2,
                p_last_updated_by             NUMBER  := fnd_global.user_id,
                p_created_by                  NUMBER  := fnd_global.user_id,
                p_last_update_login           NUMBER  := fnd_global.user_id,
                x_element_relationship_id OUT NOCOPY NUMBER);

  PROCEDURE insert_element_rel_chk(p_parent_char_id NUMBER,
                                   p_child_char_id  NUMBER,
                                   p_relationship_type NUMBER,
                                   x_status            OUT NOCOPY VARCHAR2);

  PROCEDURE insert_criteria_rel(p_plan_relationship_id       NUMBER,
                p_char_id           NUMBER,
                p_operator          NUMBER,
                p_low_value         VARCHAR2,
--                p_low_value_id      NUMBER,
                p_high_value        VARCHAR2,
--                p_high_value_id     NUMBER,
                p_last_updated_by   NUMBER  := fnd_global.user_id,
                p_created_by        NUMBER  := fnd_global.user_id,
                p_last_update_login NUMBER  := fnd_global.user_id,
                x_criteria_id       OUT NOCOPY NUMBER);

  PROCEDURE update_plan_rel(p_plan_relationship_id   NUMBER,
                            p_parent_plan_id         NUMBER,
                            p_child_plan_id          NUMBER,
                            p_plan_relationship_type NUMBER,
                            p_data_entry_mode        NUMBER,
                            p_layout_mode            NUMBER default null,
                            p_auto_row_count         NUMBER,
                            p_default_parent_spec    VARCHAR2,
                            p_last_updated_by        NUMBER:=fnd_global.user_id,
                            p_created_by             NUMBER:=fnd_global.user_id,
                            p_last_update_login      NUMBER:=fnd_global.user_id
                           );

  PROCEDURE update_element_rel(
                p_element_relationship_id     NUMBER,
                p_plan_relationship_id        NUMBER,
                p_parent_char_id              NUMBER,
                p_child_char_id               NUMBER,
                p_element_relationship_type   NUMBER,
                p_link_flag                   VARCHAR2,
                p_last_updated_by             NUMBER  := fnd_global.user_id,
                p_created_by                  NUMBER  := fnd_global.user_id,
                p_last_update_login           NUMBER  := fnd_global.user_id,
                p_row_id                      VARCHAR2);


  PROCEDURE update_criteria_rel(
                p_rowid                VARCHAR2,
                p_plan_relationship_id NUMBER,
                p_char_id              NUMBER,
                p_operator             NUMBER,
                p_low_value            VARCHAR2,
                p_high_value           VARCHAR2,
                p_last_updated_by      NUMBER  := fnd_global.user_id,
                p_created_by           NUMBER  := fnd_global.user_id,
                p_last_update_login    NUMBER  := fnd_global.user_id,
                p_criteria_id          NUMBER);


PROCEDURE delete_element_rel(p_element_relationship_id NUMBER);

PROCEDURE delete_criteria(p_criteria_id NUMBER);

FUNCTION descendant_plans_exist(p_plan_id NUMBER) RETURN VARCHAR2 ;

FUNCTION is_plan_applicable (
		p_plan_id IN NUMBER,
		search_array IN qa_txn_grp.ElementsArray)
	RETURN VARCHAR2;

FUNCTION get_plan_vqr_sql (
		p_plan_id IN NUMBER,
		p_search_str IN VARCHAR2,
		p_collection_id IN NUMBER default null,
		p_occurrence in NUMBER default null,
		p_search_str2 IN VARCHAR2 default null, --future use
		p_search_str3 IN VARCHAR2 default null)
	RETURN VARCHAR2;

FUNCTION check_for_elements (
			p_plan_id IN NUMBER,
			p_search_array IN qa_txn_grp.ElementsArray)
	RETURN VARCHAR2;

FUNCTION check_for_results (
			p_plan_id IN NUMBER,
			p_search_array IN qa_txn_grp.ElementsArray)
	RETURN VARCHAR2;


FUNCTION get_where_clause (
			p_plan_id IN NUMBER,
			p_search_array IN qa_txn_grp.ElementsArray)
	RETURN VARCHAR2;


FUNCTION get_child_vqr_sql (
		p_child_plan_id IN NUMBER,
		p_parent_plan_id IN NUMBER,
		p_parent_collection_id IN NUMBER,
		p_parent_occurrence IN NUMBER)
	RETURN VARCHAR2;

FUNCTION get_parent_vqr_sql (
		p_parent_plan_id IN NUMBER,
		p_parent_collection_id IN NUMBER,
		p_parent_occurrence IN NUMBER)
	RETURN VARCHAR2;

 PROCEDURE delete_plan_rel(p_plan_relationship_id NUMBER);

FUNCTION get_plan_ids (
		p_search_str IN VARCHAR2,
		p_org_id IN VARCHAR2 default null,
		p_search_str2 IN VARCHAR2 default null, --future use
		p_search_str3 IN VARCHAR2 default null)
	RETURN VARCHAR2;


END qa_ss_parent_child_pkg;

 

/
