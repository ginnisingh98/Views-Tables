--------------------------------------------------------
--  DDL for Package M4U_XML_EXTN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_XML_EXTN_UTILS" AUTHID CURRENT_USER AS
/* $Header: M4UXUTLS.pls 120.0 2006/05/25 12:52:45 bsaratna noship $ */

        -- Constant values used in XML generation program
        -- mapping type - CONSTANT/VARIABLE/VIEW
        c_maptyp_const  CONSTANT VARCHAR2(30) := 'CONSTANT';
        c_maptyp_var    CONSTANT VARCHAR2(30) := 'VARIABLE';
        c_maptyp_view   CONSTANT VARCHAR2(30) := 'VIEW';

        -- element type - ATTRIBUTE/ELEMENT/CONTAINER
        c_nodetyp_attr  CONSTANT VARCHAR2(30) := 'ATTRIBUTE';
        c_nodetyp_cont  CONSTANT VARCHAR2(30) := 'CONTAINER';
        c_nodetyp_elmt  CONSTANT VARCHAR2(30) := 'ELEMENT';

        -- valdn type - DTD/XSD/NONE
        c_valdtn_dtd   CONSTANT VARCHAR2(30) := 'DTD';
        c_valdtn_xsd   CONSTANT VARCHAR2(30) := 'XSD';
        c_valdtn_none  CONSTANT VARCHAR2(30) := 'NONE';

        -- GLOBAL variables passed to map as event parameter list
        TYPE glb_var_typ                IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(60);
        g_glb_var_tab                   glb_var_typ;

        -- Header data -- m4u_xml_extensions
        -- Header identifier, validation data
        TYPE hdr_rec_typ IS RECORD
        (
                extn_name               m4u_xml_extensions.extn_name%TYPE,
                tp_id                   m4u_xml_extensions.trading_partner_id%TYPE,
                valdtn_typ              m4u_xml_extensions.validation_type%TYPE,
                dtd_schma_loc           m4u_xml_extensions.dtd_or_schema_location%TYPE,
                dtd_base_dir            m4u_xml_extensions.base_dir%TYPE,
                xml_root_node           m4u_xml_extensions.root_node%TYPE

        );
        g_hdr_rec hdr_rec_typ;

        -- Corresponds to rows from m4u_element_mapping table
        -- node identified, type, hierachy, mapping information
        TYPE elmnt_rec_typ IS RECORD
        (
                id                      m4u_element_mappings.node_id%TYPE,
                seq                     m4u_element_mappings.node_sequence%TYPE,
                name                    m4u_element_mappings.node_name%TYPE,
                type                    m4u_element_mappings.node_type%TYPE,
                lvl_id                  m4u_element_mappings.level_id%TYPE,
                parent_id               m4u_element_mappings.parent_node_id%TYPE,
                map_typ                 m4u_element_mappings.mapping_type%TYPE,
                view_nam                m4u_element_mappings.view_name%TYPE,
                col                     m4u_element_mappings.column_name%TYPE,
                view_lvl                m4u_element_mappings.view_level_id%TYPE,
                var                     m4u_element_mappings.variable_name%TYPE,
                const                   m4u_element_mappings.constant_val%TYPE
        );
        -- Element for below table need to be processed in sequnce for generating XML
        TYPE g_elmnt_map_typ IS TABLE OF elmnt_rec_typ INDEX BY BINARY_INTEGER;
        g_elmnt_map     g_elmnt_map_typ;
        g_elmnt_count   NUMBER; -- no of elements in above varray

        -- Recrod for each bind variable
        -- bind variable
        -- View/Global variable from which bind value to be fetched
        TYPE bind_rec_typ IS RECORD
        (
                nam                     m4u_view_binding.bind_variable%TYPE,
                typ                     m4u_view_binding.bind_type%TYPE,
                src_var                 m4u_view_binding.source_var%TYPE,
                src_view                m4u_view_binding.source_view%TYPE,
                src_col                 m4u_view_binding.source_column%TYPE,
                src_lvl_id              m4u_view_binding.source_level_id%TYPE
        );
        -- Table of bind variable associate with each view
        TYPE bind_tab_typ               IS TABLE OF bind_rec_typ INDEX BY BINARY_INTEGER;
        -- Table of column names associated with each view
        TYPE col_tab_typ                IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;

        -- Each view to be queried from the database.
        -- View name, column listing, where clause, bind variable listing
        -- number of rows fetched for the view
        TYPE view_rec_typ IS RECORD
        (
                view_nam                m4u_element_mappings.view_name%TYPE,
                whr_claus               VARCHAR2(4000),
                bind_tab                bind_tab_typ,
                bind_count              NUMBER,
                exec_sql                VARCHAR2(4000),
                col_tab                 col_tab_typ,
                col_count               NUMBER,
                rowcount                NUMBER
        );
        TYPE view_tab_typ               IS TABLE OF view_rec_typ INDEX BY BINARY_INTEGER;

        -- Table of number indexed by integer
        -- Used as base data-type for all stacks
        TYPE g_list_typ                 IS TABLE OF NUMBER  INDEX BY BINARY_INTEGER;
        -- Values which go into the XML.
        -- Index is rownum
        TYPE g_vals_typ                 IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

        -- to fetch 3rd row value of viewname.column name do
        -- lvl_rec.vals(viewname.column_nam)(3)
        TYPE col_val_tab_typ            IS TABLE of g_vals_typ    INDEX BY VARCHAR2(200);

        -- Record for each level
        -- id,view_tab,view_count,is_mapped      - are initialized a loading
        -- rpt_count,end_tag_stk,end_tag_stk_ptr,cntr - hold stack information
        TYPE lvl_rec_typ IS RECORD
        (
                id                      m4u_level_views.level_id%TYPE,
                view_tab                view_tab_typ,
                view_count              NUMBER,
                rpt_count               NUMBER,
                is_mapped               BOOLEAN,
                end_tag_stk_ptr         NUMBER,
                end_tag_stk             g_list_typ,
                vals                    col_val_tab_typ,
                cntr                    NUMBER
        );
        TYPE lvl_tab_typ IS TABLE OF lvl_rec_typ INDEX BY BINARY_INTEGER;

        -- table indexing level records
        g_lvl_rec_tab           lvl_tab_typ;

        -- stack of level. current level in on top and parent levels are stacked below
        g_lvl_stk               g_list_typ;
        g_lvl_stk_ptr           NUMBER := 0;


        -- Procedure to init map
        -- loads all map information into memory
        PROCEDURE init_map(
                a_extn_name             IN              VARCHAR2,
                a_tp_id                 IN              VARCHAR2,
                a_dflt_tp               IN              BOOLEAN,
                a_param_list            IN              wf_parameter_list_t,
                a_log_lvl               IN              NUMBER,
                x_ret_sts               OUT NOCOPY      VARCHAR2,
                x_ret_msg               OUT NOCOPY      VARCHAR2);

        -- called by init map, loads header info to memory
        PROCEDURE init_hdr(
                a_extn_name             IN              VARCHAR2,
                a_tp_id                 IN              VARCHAR2,
                a_dflt_tp               IN              BOOLEAN,
                x_ret_sts               OUT NOCOPY      VARCHAR2,
                x_ret_msg               OUT NOCOPY      VARCHAR2);

        -- called by init map, loads elmnt_mapping info to memory
        PROCEDURE load_elmnt_mapping(
                x_ret_sts       OUT NOCOPY VARCHAR2,
                x_ret_msg       OUT NOCOPY VARCHAR2);

        -- called by init map, loads level info to memory
        PROCEDURE load_lvls(
                x_ret_sts       OUT NOCOPY VARCHAR2,
                x_ret_msg       OUT NOCOPY VARCHAR2);

        -- load list of columns to be fetched for each view
        -- create exec_sql dynamically
        PROCEDURE load_view_cols(
                a_lvl_id        IN              NUMBER,
                x_view_rec      IN OUT NOCOPY   view_rec_typ,
                x_ret_sts       OUT NOCOPY      VARCHAR2,
                x_ret_msg       OUT NOCOPY      VARCHAR2);

        -- load list of bind variable to be supplied for each where clause
        -- load mapping info for each bind variable
        PROCEDURE load_bindings(
                        a_lvl_id        IN              NUMBER,
                        x_view_rec      IN OUT NOCOPY   view_rec_typ,
                        x_ret_sts       OUT NOCOPY      VARCHAR2,
                        x_ret_msg       OUT NOCOPY      VARCHAR2);


        -- Code to initialize a level
        -- Executes views sequels and stores data in memory
        -- of level record
        -- initializes counter, repeat count of level
        PROCEDURE init_level(a_lvl_id        IN              VARCHAR2,
                             x_lvl_rec       OUT NOCOPY      lvl_rec_typ,
                             x_ret_sts       OUT NOCOPY      VARCHAR2,
                             x_ret_msg       OUT NOCOPY      VARCHAR2);

        -- bundle unexpected error handling code
        PROCEDURE handle_exception(
                        a_sql_code      IN              NUMBER,
                        a_sql_errm      IN              VARCHAR2,
                        a_actn          IN              VARCHAR2,
                        a_proc          IN              VARCHAR2,
                        x_ret_sts       OUT NOCOPY      VARCHAR2,
                        x_ret_msg       OUT NOCOPY      VARCHAR2);

        -- lookup view, column value from run-time level stack
        FUNCTION lookup_view_value( a_view      IN VARCHAR2 ,
                                    a_col       IN VARCHAR2 ,
                                    a_lvl       IN NUMBER   ,
                                    x_ret_sts   OUT NOCOPY VARCHAR2,
                                    x_ret_msg   OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2;

        -- pushes input level into runtime level stack
        PROCEDURE push_lvl_stack(l_lvl_id    IN         NUMBER,
                                 x_ret_sts   OUT NOCOPY VARCHAR2,
                                 x_ret_msg   OUT NOCOPY VARCHAR2);

        -- pops input level from runtime level stack
        FUNCTION pop_lvl_stack( x_ret_sts OUT NOCOPY  VARCHAR2,
                                x_ret_msg OUT NOCOPY  VARCHAR2)
        RETURN NUMBER;

        -- called to validate XML fragment
        -- Validation  parameters are supplied by init_hdr
        PROCEDURE validate(
                a_xml                   IN         VARCHAR2,
                x_valdtn_sts            OUT NOCOPY VARCHAR2,
                x_valdtn_msg            OUT NOCOPY VARCHAR2,
                x_api_ret_sts           OUT NOCOPY VARCHAR2,
                x_api_ret_msg           OUT NOCOPY VARCHAR2);


        -- Helper procedure to log XML document into file
        -- for debug/logging purpose
        PROCEDURE log_xml(a_xml           IN              VARCHAR2,
                          x_ret_sts       OUT NOCOPY      VARCHAR2,
                          x_ret_msg       OUT NOCOPY      VARCHAR2);

        -- cleans up run-time info of level
        -- this is important
        -- since same level can be brought back onto stack multiple times
        -- so make sure data from previous run of level is not carried
        PROCEDURE un_init_level(a_lvl_id        IN              NUMBER,
                                x_ret_sts       OUT NOCOPY      VARCHAR2,
                                x_ret_msg       OUT NOCOPY      VARCHAR2);


        -- cleans up any memory held by map
        PROCEDURE un_init_map(x_ret_sts OUT NOCOPY VARCHAR2,
                              x_ret_msg OUT NOCOPY VARCHAR2);

        -- escape predefined entities from charter strings
        FUNCTION escape_entities(a_val IN varchar2)
        RETURN VARCHAR2;
END m4u_xml_extn_utils;

 

/
