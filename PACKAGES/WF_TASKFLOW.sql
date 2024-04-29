--------------------------------------------------------
--  DDL for Package WF_TASKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_TASKFLOW" AUTHID CURRENT_USER AS
/* $Header: wfflos.pls 120.5 2007/08/16 05:19:53 dsardar ship $ */


  /*
   * Name:
   *     get_flow_definition
   *
   * Description:
   *    Get definitions of all process activities and transitions in the base
   *    process.
   *
   * Parameters:
   *    x_base_type   - Base item type, first part of id.
   *    x_base_name   - Base process name, second part of id.
   *    x_parent_type - Parent item type. Default to null.
   *    x_parent_name - Parent process_name. Default to null.
   *
   * Notes:
   *    x_parent_type and x_parent_name are used when the base process has
   *    a parent process of different item_type. Used when zooming-in a
   *    subprocess.
   */
  FUNCTION get_flow_definition(x_base_type VARCHAR2,
                                x_base_name VARCHAR2,
                                x_parent_type VARCHAR2 DEFAULT NULL,
                                x_parent_name VARCHAR2 DEFAULT NULL) RETURN CLOB;


  /*
   * Name:
   *    get_flow_instance
   *
   * Description:
   *    Get defintions and state info of all process activities and
   *    transitions in the process instance.
   *
   * Parameters:
   *    x_item_type   - Item type for the  process instance, first part of
   *                    instance id.
   *    x_item_key    - Item key for the process instance, second part of
   *                    instance id. For retrieving state info.
   *    x_parent_type - Parent item type, for retrieving base process
   *                    information. (A process of one item_type can contain
   *                    activities of other item_types.) Default to null.
   *    x_parent_name - Parent process_name, for retrieving base process
   *                    information. (A process of one item_type can contain
   *                    activities of other item_types.) Default to null.
   *    x_base_type   - Item type, first id of the process defintion. Default
   *                    to null.
   *    x_base_name   - Process name, second id of the process definition.
   *                    Default to null.
   * Notes:
   *    Last 3 arguments are used when zooming-in a subprocess. The parent
   *    item type will be the same as x_item_type.
   *
   */
  FUNCTION get_flow_instance(x_item_type   IN VARCHAR2,
                              x_item_key    IN VARCHAR2,
                              x_parent_type IN VARCHAR2 DEFAULT NULL,
                              x_parent_name IN VARCHAR2 DEFAULT NULL,
                              x_base_type   IN VARCHAR2 DEFAULT NULL,
                              x_base_name   IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  /*
   * Name:
   *    get_translations
   *
   * Description:
   *    Given a name list concatenated with '^', parse the list and return
   *    a html page of translated list with the same order.
   *
   * Parameters:
   *    x_name_list   - List of names to be translated, concatenated with
   *                    agreed delimiter.
   */
  FUNCTION get_translations(x_name_list IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;


END WF_TASKFLOW;

/
