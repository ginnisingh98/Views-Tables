--------------------------------------------------------
--  DDL for Package XLA_CMP_TAB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_TAB_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacptab.pkh 120.1 2004/06/21 15:15:27 aquaglia ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_cmp_tab_pkg                                                    |
|                                                                       |
| DESCRIPTION                                                           |
|    Transaction Account Builder API compiler                           |
|                                                                       |
| HISTORY                                                               |
|    26-JAN-04 A.Quaglia      Created                                   |
|    21-JUN-04 A.Quaglia      get_ccid_additional_info:                 |
|                                removed x_concatenated_values          |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/


   TYPE gt_table_of_varchar2_1        IS TABLE OF VARCHAR2(1);
   TYPE gt_table_of_varchar2_10       IS TABLE OF VARCHAR2(10);
   TYPE gt_table_of_varchar2_30       IS TABLE OF VARCHAR2(30);

   g_all_object_name_affixes          gt_table_of_varchar2_10;
   g_compiled_object_name_affixes     gt_table_of_varchar2_10;

   g_table_of_sources                 gt_table_of_varchar2_30;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| compile_api_srs                                                       |
|                                                                       |
| SRS wrapper for compile_api                                           |
|	p_retcode := 0 means that the compilation was successful.       |
|	p_retcode := 2 means that errors were encountered and that the  |
|                      generation of the API was unsuccessful.          |
+======================================================================*/
PROCEDURE compile_api_srs
                           ( p_errbuf               OUT NOCOPY VARCHAR2
                            ,p_retcode              OUT NOCOPY NUMBER
                            ,p_application_id       IN         NUMBER
                           );


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| compile_api                                                           |
|                                                                       |
| It generates the Transaction Account Builder API for the specified    |
| application.                                                          |
| It generates one package header and one package body in the <APPS>    |
| schema and one or more global temporary tables in the Product schema  |
| (e.g. AP, AR etc.).                                                   |
| The number of interface tables actually generated depends on the      |
| number of distinct values of object_name_affix defined for the        |
| different Transaction Account Types within the specified application. |
|                                                                       |
| It returns a BOOLEAN value.                                           |
|     TRUE  means that the compilation was successful.                  |
|     FALSE means that errors were encountered and that the generation  |
|                 of the API was unsuccessful.                          |
+======================================================================*/
FUNCTION compile_api
                           ( p_application_id       IN         NUMBER
                           )
RETURN BOOLEAN
;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_distinct_affixes                                                  |
|                                                                       |
|                                                                       |
| Returns false if no affixes are found                                 |
|                                                                       |
+======================================================================*/
FUNCTION read_distinct_affixes
                           ( p_application_id        IN NUMBER
                           )
RETURN BOOLEAN;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_interface_object_names                                            |
|                                                                       |
| Return the names of the objects that form the TAB API interface for   |
| the specified affix.                                                  |
|                                                                       |
| Returns TRUE if successful, FALSE otherwise.                          |
|                                                                       |
+======================================================================*/
FUNCTION get_interface_object_names
            (
              p_application_id           IN         VARCHAR2
             ,p_object_name_affix        IN         VARCHAR2
             ,x_global_table_name        OUT NOCOPY VARCHAR2
             ,x_plsql_table_name         OUT NOCOPY VARCHAR2
            )
RETURN BOOLEAN;




/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_interface_sources                                                 |
|                                                                       |
| Return a list of the sources included in the TAB API interface for    |
| the specified affix.                                                  |
|                                                                       |
| Returns TRUE if successful, FALSE otherwise.                          |
|                                                                       |
+======================================================================*/
FUNCTION get_interface_sources
            (
              p_application_id            IN         VARCHAR2
             ,p_object_name_affix         IN         VARCHAR2
             ,x_table_of_sources          OUT NOCOPY gt_table_of_varchar2_30
             ,x_table_of_source_datatypes OUT NOCOPY gt_table_of_varchar2_1
            )
RETURN BOOLEAN;




/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_tab_api_package_name                                              |
|                                                                       |
| Return the names of the objects that form the TAB API interface for   |
| the specified affix.                                                  |
|                                                                       |
| Returns TRUE if successful, FALSE otherwise.                          |
|                                                                       |
+======================================================================*/
FUNCTION get_tab_api_package_name
            (
              p_application_id           IN         VARCHAR2
             ,x_tab_api_package_name     OUT NOCOPY VARCHAR2
            )
RETURN BOOLEAN;



/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_tab_api_info_for_tat                                              |
|                                                                       |
| Returns information about the TAB API interface for the specified     |
| Transaction Account Type                                              |
|                                                                       |
| Returns TRUE if successful, FALSE otherwise.                          |
|                                                                       |
+======================================================================*/
FUNCTION get_tab_api_info_for_tat
            (
              p_application_id            IN         VARCHAR2
             ,p_account_type_code         IN         VARCHAR2
             ,x_object_name_affix         OUT NOCOPY VARCHAR2
             ,x_tab_api_package_name      OUT NOCOPY VARCHAR2
             ,x_global_table_name         OUT NOCOPY VARCHAR2
             ,x_plsql_table_name          OUT NOCOPY VARCHAR2
             ,x_write_proc_name           OUT NOCOPY VARCHAR2
             ,x_read_proc_name            OUT NOCOPY VARCHAR2
             ,x_table_of_sources          OUT NOCOPY FND_TABLE_OF_VARCHAR2_30
             ,x_table_of_source_datatypes OUT NOCOPY FND_TABLE_OF_VARCHAR2_1
            )
RETURN BOOLEAN;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_ccid_additional_info                                              |
|                                                                       |
| Returns information about a code combination id                       |
|                                                                       |
| Returns TRUE if successful, FALSE otherwise.                          |
|                                                                       |
+======================================================================*/
FUNCTION get_ccid_additional_info
            (
              p_chart_of_accounts_id      IN         NUMBER
             ,p_ccid                      IN         NUMBER
             ,x_concatenated_descriptions OUT NOCOPY VARCHAR2
            )
RETURN BOOLEAN;



/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| remove_deleted_tats                                                   |
|                                                                       |
| Removes Transaction Account Types headers that have been              |
| deleted in the UI.                                                    |
|                                                                       |
| It returns a BOOLEAN value.                                           |
|     TRUE  means that the function was successful.                     |
|     FALSE means that errors were encountered                          |
|                                                                       |
+======================================================================*/

FUNCTION remove_deleted_tats
             (
                p_application_id IN NUMBER
             )
RETURN BOOLEAN;


END xla_cmp_tab_pkg;
 

/
