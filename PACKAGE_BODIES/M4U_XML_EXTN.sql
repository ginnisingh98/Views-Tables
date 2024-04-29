--------------------------------------------------------
--  DDL for Package Body M4U_XML_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_XML_EXTN" AS
/* $Header: M4UGENXB.pls 120.0 2006/05/25 12:51:33 bsaratna noship $ */

        -- logging/error handling variables
        g_log_lvl               NUMBER;
        g_success_code          VARCHAR2(30);
        g_unexp_err_code        VARCHAR2(30);
        g_err_code              VARCHAR2(30);
        g_remove_empty_elmt     BOOLEAN;
        g_remove_empty_attr     BOOLEAN;

        -- get value for a element node
        -- based on mapping type
        -- return value or null in case of error
        FUNCTION get_node_value(
                        a_elmt_rec      IN            m4u_xml_extn_utils.elmnt_rec_typ,
                        x_ret_sts       OUT NOCOPY    VARCHAR2,
                        x_ret_msg       OUT NOCOPY    VARCHAR2)
        RETURN VARCHAR2 AS
                l_tmp_val VARCHAR2(32767);
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Get value for node - ' || a_elmt_rec.id;
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn.get_node_value',        2);
                        cln_debug_pub.add('a_elmt_rec.id       - ' || a_elmt_rec.id,     2);
                        cln_debug_pub.add('a_elmt_rec.map_typ  - ' || a_elmt_rec.map_typ,2);
                END IF;

                l_tmp_val := NULL;

                -- mapping type is constant then elmt_rec.const contains the
                -- node.value
                IF a_elmt_rec.map_typ   = m4u_xml_extn_utils.c_maptyp_const THEN

                        l_tmp_val := a_elmt_rec.const;
                -- if mapping type is variable, lookup global variables for value
                ELSIF a_elmt_rec.map_typ = m4u_xml_extn_utils.c_maptyp_var THEN

                        BEGIN
                                l_tmp_val := m4u_xml_extn_utils.g_glb_var_tab(a_elmt_rec.var);
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                        FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_INV_PARAM');
                                        FND_MESSAGE.SET_TOKEN('PARAM','Global variable');
                                        FND_MESSAGE.SET_TOKEN('VALUE',a_elmt_rec.var);
                                        x_ret_msg := FND_MESSAGE.GET;
                                        x_ret_sts := g_err_code;
                                        IF g_log_lvl <= 1 THEN
                                                cln_debug_pub.add('Fetch global variable error',1);
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                        END;
                -- if mapping type view, call lookup view value
                ELSIF a_elmt_rec.map_typ = m4u_xml_extn_utils.c_maptyp_view THEN

                        l_tmp_val := m4u_xml_extn_utils.lookup_view_value
                                        (a_elmt_rec.view_nam,a_elmt_rec.col,
                                        a_elmt_rec.view_lvl,x_ret_sts, x_ret_msg);

                        IF x_ret_sts <> g_success_code THEN
                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('lookup_view_value returns error',1);
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                ELSE
                        -- unknown mapping type
                        -- return error
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Mapping type not-found',1);
                        END IF;
                        FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_INV_PARAM');
                        FND_MESSAGE.SET_TOKEN('PARAM','Element mapping type');
                        FND_MESSAGE.SET_TOKEN('VALUE',a_elmt_rec.map_typ);
                        x_ret_msg := FND_MESSAGE.GET;
                        x_ret_sts := g_err_code;
                        RAISE FND_API.G_EXC_ERROR;

                END IF;
                -- return success
                x_ret_sts       := g_success_code;
                x_ret_msg       := NULL;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn.get_node_value - Normal',2);
                        cln_debug_pub.add('ret_val  - ' || substr(l_tmp_val,1,255), 2);
                END IF;

                l_tmp_val := m4u_xml_extn_utils.escape_entities(l_tmp_val);

                RETURN l_tmp_val;
        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                        IF g_log_lvl <= 6 THEN
                                cln_debug_pub.add('Exiting m4u_xml_extn.get_node_value - Error',6);
                                cln_debug_pub.add('x_ret_msg        - ' || x_ret_msg,6);
                        END IF;
                        x_ret_sts := g_err_code;
                        l_tmp_val := null;
                        RETURN l_tmp_val;
                WHEN OTHERS THEN
                        m4u_xml_extn_utils.handle_exception(SQLCODE,SQLERRM,l_progress,
                        'm4u_xml_extn.get_node_value',x_ret_sts,x_ret_msg);
                        l_tmp_val := null;
                        RETURN l_tmp_val;
        END get_node_value;

        -- push index of end tag onto level_reg.end_tag_stk
        PROCEDURE push_end_tag(a_el_idx         IN              NUMBER,
                               a_lvl_rec        IN OUT NOCOPY   m4u_xml_extn_utils.lvl_rec_typ,
                               x_ret_sts        OUT NOCOPY      VARCHAR2,
                               x_ret_msg        OUT NOCOPY      VARCHAR2)
        IS
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Stack end tag(idx) - ' || a_el_idx;
                IF g_log_lvl <= 2 THEN
                    cln_debug_pub.add('Entering push_end_tag',         2);
                    cln_debug_pub.add('a_el_idx       - ' || a_el_idx, 2);
                    cln_debug_pub.add('a_lvl_rec.id   - ' || a_lvl_rec.id,2);
                    cln_debug_pub.add('end_tag_stk_ptr- ' || a_lvl_rec.end_tag_stk_ptr,2);
                END IF;

                a_lvl_rec.end_tag_stk_ptr := a_lvl_rec.end_tag_stk_ptr+1;
                a_lvl_rec.end_tag_stk(a_lvl_rec.end_tag_stk_ptr):=  a_el_idx;

                IF g_log_lvl <= 1 THEN
                    cln_debug_pub.add('end_tag_stk_ptr-' || a_lvl_rec.end_tag_stk_ptr,1);
                END IF;

                x_ret_sts := g_success_code;
                x_ret_msg := null;
                IF g_log_lvl <= 2 THEN
                    cln_debug_pub.add('Exiting push_end_tag - Success',2);
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                    m4u_xml_extn_utils.handle_exception(SQLCODE,SQLERRM,l_progress,
                                'm4u_xml_extn.push_end_tag',x_ret_sts,x_ret_msg);
        END push_end_tag;


        -- processes element.
        -- puts start tag on to level XML
        -- gets value of element onto the level XML
        -- process attributes of the elements
        -- pushes element index into level end-tag-stk
        FUNCTION process_element(a_elmt_rec     IN         m4u_xml_extn_utils.elmnt_rec_typ,
                                 a_elmt_idx     IN         NUMBER,
                                 a_lvl_rec      IN OUT NOCOPY m4u_xml_extn_utils.lvl_rec_typ,
                                 x_nxt_idx      OUT NOCOPY NUMBER,
                                 x_ret_sts      OUT NOCOPY VARCHAR2,
                                 x_ret_msg      OUT NOCOPY VARCHAR2)
        RETURN VARCHAR2
        AS
                l_xml           VARCHAR2(32767);
                l_attr_idx      NUMBER;
                l_elmt_rec      m4u_xml_extn_utils.elmnt_rec_typ;
                l_tmp_val       VARCHAR2(4000);
                l_progress      VARCHAR2(4000);
                l_el_val        VARCHAR2(4000);
                l_no_attrval    BOOLEAN;
        BEGIN
                l_progress := 'Processing element - ' || a_elmt_rec.id;
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn.process_element',  2);
                        cln_debug_pub.add('a_elmt_rec.id    - ' || a_elmt_rec.id,   2);
                        cln_debug_pub.add('a_elmt_idx       - ' || a_elmt_idx,      2);
                        cln_debug_pub.add('a_lvl_rec.id     - ' || a_lvl_rec.id,    2);
                END IF;

                l_attr_idx := a_elmt_idx+1;

                -- print start tag
                l_xml := '<'|| a_elmt_rec.name;

                l_no_attrval := true;

                -- loop through element's attributes
                -- process each attribute and add to start-tag
                LOOP
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Loop l_attr_idx - ' || l_attr_idx,2);
                        END IF;

                        -- keep checking if we are tripping off the table
                        IF l_attr_idx > m4u_xml_extn_utils.g_elmnt_count THEN

                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('Exit loop l_attr_idx >= m4u_xml_extn_utils.g_elmnt_count',1);
                                END IF;
                                EXIT;
                        ELSE
                                l_elmt_rec := m4u_xml_extn_utils.g_elmnt_map(l_attr_idx);
                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('Next-rec l_elmt_rec.type     - ' || l_elmt_rec.type,         1);
                                        cln_debug_pub.add('Next-rec l_elmt_rec.id       - ' || l_elmt_rec.id,           1);
                                        cln_debug_pub.add('Next-rec l_elmt_rec.parent_id- ' || l_elmt_rec.parent_id,    1);
                                END IF;

                                -- if next record attribute and child or current element
                                IF l_elmt_rec.type = m4u_xml_extn_utils.c_nodetyp_attr
                                        AND     l_elmt_rec.parent_id = a_elmt_rec.id THEN

                                        l_tmp_val   := get_node_value(l_elmt_rec,x_ret_sts,x_ret_msg);

                                        IF l_tmp_val IS NOT NULL THEN
                                                l_no_attrval := false;
                                        END IF;

                                        IF x_ret_sts <> g_success_code THEN
                                                IF g_log_lvl <= 1 THEN
                                                        cln_debug_pub.add('get_node_value returns fail',1);
                                                END IF;
                                                RAISE FND_API.G_EXC_ERROR;
                                        END IF;
                                        -- print attribute="value" to the xml
                                        IF l_tmp_val is NOT NULL OR g_remove_empty_attr = false THEN
                                                l_xml       := l_xml || ' ' || l_elmt_rec.name || '="' || l_tmp_val || '"';
                                        END IF;
                                        l_attr_idx  := l_attr_idx + 1;
                                ELSE
                                        -- next element is not a attribute child
                                        -- so close current element (and attributes) ends here
                                        -- move out of loop
                                        IF g_log_lvl <= 1 THEN
                                                cln_debug_pub.add('Exit loop l_attr_idx.type <> attribute',1);
                                        END IF;
                                        EXIT;
                                END IF;
                        END IF;
                END LOOP;

                l_el_val := NULL;

                IF a_elmt_rec.type  = m4u_xml_extn_utils.c_nodetyp_elmt THEN

                        l_el_val := get_node_value(a_elmt_rec,x_ret_sts,x_ret_msg);
                        IF x_ret_sts <> g_success_code THEN
                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('get_node_value returns fail',1);
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                END IF;

                IF l_el_val IS NOT NULL OR a_elmt_rec.type = m4u_xml_extn_utils.c_nodetyp_cont THEN

                        l_xml := l_xml || '>' || l_el_val;
                        -- push end-tag to the stack
                        push_end_tag(a_elmt_idx,a_lvl_rec,x_ret_sts,x_ret_msg);
                        IF x_ret_sts <> g_success_code THEN
                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('push_end_tag returns fail',1);
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                ELSE
                        -- if element is empty and there are no non-null attributes
                        -- then don't print the element
                        IF g_remove_empty_elmt AND l_no_attrval THEN
                                l_xml := NULL;
                        ELSE
                                -- shorthand for element notation
                                l_xml := l_xml || '/>';
                        END IF;
                END IF;



                -- return next index to be processed
                -- this will skip all the elements attributes and
                -- point to the next element
                x_nxt_idx   := l_attr_idx;
                x_ret_sts   := g_success_code;
                x_ret_msg   := NULL;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn.process_element - NORMAL',2);
                        cln_debug_pub.add('x_xml            - ' || substr(l_xml,1,255),     2);
                        cln_debug_pub.add('x_nxt_idx        - ' || x_nxt_idx,               2);
                END IF;

                RETURN l_xml;

        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                        IF g_log_lvl <= 6 THEN
                                cln_debug_pub.add('Exiting m4u_xml_extn.process_element - Error',6);
                                cln_debug_pub.add('x_ret_msg    - ' || x_ret_msg,6);
                        END IF;
                        x_nxt_idx   := m4u_xml_extn_utils.g_elmnt_count+1;
                        x_ret_sts   := g_err_code;
                        l_xml := null;
                        RETURN l_xml;
                WHEN OTHERS THEN
                        m4u_xml_extn_utils.handle_exception(SQLCODE,SQLERRM,l_progress,
                        'm4u_xml_extn.process_element',x_ret_sts,x_ret_msg);
                        l_xml := null;
                        RETURN l_xml;
        END process_element;


        -- pop level's end-tag-stack till the a_el_idx is reached
        -- essentially this is called when a new element/level is to be processed.
        -- the parent-id of new element is passed to the routine
        -- so nested end tags are popped out
        FUNCTION pop_end_tags(a_el_idx  IN            NUMBER,
                              a_lvl_rec IN  OUT NOCOPY m4u_xml_extn_utils.lvl_rec_typ,
                              x_ret_sts OUT NOCOPY    VARCHAR2,
                              x_ret_msg OUT NOCOPY    VARCHAR2)
        RETURN VARCHAR2 AS
                l_ret_str       VARCHAR2(32767);
                l_idx           NUMBER;
                l_elmt_rec      m4u_xml_extn_utils.elmnt_rec_typ;
                l_el_idx        NUMBER;
                l_progress      VARCHAR2(4000);
        BEGIN
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering pop_end_tags',              2);
                        cln_debug_pub.add('a_el_idx       - ' || a_el_idx,      2);
                        cln_debug_pub.add('a_lvl_rec.id   - ' || a_lvl_rec.id , 2);
                        cln_debug_pub.add('end_tag_stk_ptr- ' || a_lvl_rec.end_tag_stk_ptr,2);
                END IF;
                l_progress := 'Pop end-tags - ' || a_el_idx;
                -- pop stack till a_el_idx is found or stack is empty
                l_idx := a_lvl_rec.end_tag_stk_ptr;

                LOOP

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Loop l_idx - ' || l_idx,1);
                        END IF;

                        IF l_idx <= 0 THEN
                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('Exiting l_idx < 0');
                                END IF;
                                EXIT;
                        END IF;

                        l_el_idx    := a_lvl_rec.end_tag_stk(l_idx);
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Loop l_el_idx - ' || l_el_idx,1);
                        END IF;

                        l_elmt_rec  := m4u_xml_extn_utils.g_elmnt_map(l_el_idx);
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Loop l_elmt_rec.id - ' || l_elmt_rec.id,1);
                        END IF;
                        -- if node we are looking for is on tos
                        -- return else pop xml tags to return string
                        IF l_elmt_rec.id = a_el_idx THEN
                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('l_elmt_rec.id = a_el_idx',1);
                                END IF;
                                a_lvl_rec.end_tag_stk_ptr := l_idx;
                                EXIT;
                        ELSE
                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('Loop l_elmt_rec.node_name - ' || l_elmt_rec.name,1);
                                        cln_debug_pub.add('Loop l_ret_str            - ' || l_ret_str           ,1);
                                END IF;
                                l_ret_str :=  l_ret_str || '</' || l_elmt_rec.name || '>';
                                a_lvl_rec.end_tag_stk(l_idx) := null;
                                l_idx := l_idx - 1;
                                a_lvl_rec.end_tag_stk_ptr := l_idx;
                        END IF;
                END LOOP;

                x_ret_sts := g_success_code;
                x_ret_msg := NULL;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting pop_end_tags - Success',2);
                        cln_debug_pub.add('l_ret_str - ' || substr(l_ret_str,1,255),2);
                END IF;
                RETURN l_ret_str;
        EXCEPTION
                WHEN OTHERS THEN
                        m4u_xml_extn_utils.handle_exception(SQLCODE,SQLERRM,l_progress,
                        'm4u_xml_extn.pop_end_tags',x_ret_sts,x_ret_msg);
        END pop_end_tags;

        --kludge to find next non-child level given
        --current level and start index of the current level
        --design does not allow better code
        FUNCTION next_lvl_elmnt(a_strt_idx    IN NUMBER,
                                a_lvl_id      IN NUMBER,
                                x_ret_sts     OUT NOCOPY VARCHAR2,
                                x_ret_msg     OUT NOCOPY VARCHAR2)

        RETURN NUMBER
        IS
                l_tmp_str1 VARCHAR2(32767);
                l_tmp_str2 VARCHAR2(30);
                l_pid      NUMBER;
                l_cnt      NUMBER;
                l_progress VARCHAR2(4000);
        BEGIN
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn.next_lvl_elmnt',2);
                        cln_debug_pub.add('a_start_idx - ' || a_strt_idx,2);
                        cln_debug_pub.add('a_lvl_id    - ' || a_lvl_id,2);
                END IF;

                l_progress := 'Lookup next element after idx - ' || a_strt_idx;

                x_ret_sts := g_success_code;
                x_ret_msg := NULL;

                l_cnt := m4u_xml_extn_utils.g_elmnt_count;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('l_cnt - ' || l_cnt,1);
                END IF;

                l_tmp_str1 := '@' || to_char(m4u_xml_extn_utils.g_elmnt_map(a_strt_idx).id) || '@';

                FOR i in a_strt_idx+1..l_cnt LOOP
                        l_tmp_str2 := '@' || to_char(m4u_xml_extn_utils.g_elmnt_map(i).parent_id) || '@';

                        IF  m4u_xml_extn_utils.g_elmnt_map(i).lvl_id <> a_lvl_id THEN
                                IF instr(l_tmp_str1,l_tmp_str2) <= 0 THEN
                                        IF g_log_lvl <= 2 THEN
                                                cln_debug_pub.add('Exiting m4u_xml_extn.next_lvl_elmnt',2);
                                                cln_debug_pub.add('i - ' || i,2);
                                        END IF;
                                        return i;
                                END IF;
                        END IF;

                        l_tmp_str1 := l_tmp_str1 ||  '@' || to_char(m4u_xml_extn_utils.g_elmnt_map(i).id) || '@';

                END LOOP;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn.next_lvl_elmnt',2);
                        cln_debug_pub.add('l_cnt - ' || l_cnt,2);
                END IF;

                return l_cnt + 1;
        EXCEPTION
                WHEN OTHERS THEN
                        m4u_xml_extn_utils.handle_exception(SQLCODE,SQLERRM,l_progress,
                        'm4u_xml_extn.next_lvl_elmnt',x_ret_sts,x_ret_msg);
        END next_lvl_elmnt;

        -- process_level starting at a_strt_idx
        -- return generated xml in x_xml
        -- return next_idx to be processed x_nxt_idx
        PROCEDURE process_level(a_strt_idx    IN         NUMBER,
                                x_xml         OUT NOCOPY VARCHAR2,
                                x_nxt_idx     OUT NOCOPY NUMBER,
                                x_ret_sts     OUT NOCOPY VARCHAR2,
                                x_ret_msg     OUT NOCOPY VARCHAR2)
        AS

                l_elmt_rec              m4u_xml_extn_utils.elmnt_rec_typ;
                l_lvl_rec               m4u_xml_extn_utils.lvl_rec_typ;

                l_lvl_id                NUMBER;
                l_cur_idx               NUMBER;
                l_nxt_idx               NUMBER;
                l_prv_idx               NUMBER;
                l_ret_idx               NUMBER;
                l_child_lvl             BOOLEAN;
                l_progress              VARCHAR2(4000);

                l_xml                   VARCHAR2(32767);
                l_tmp_xml               VARCHAR2(32767);
                HANDLED_EXCEPTION       exception;
        BEGIN
                l_progress := 'Processing element(idx) - ' || a_strt_idx;
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn.process_level',1);
                        cln_debug_pub.add('a_start_idx - ' || a_strt_idx,1);
                END IF;


                IF a_strt_idx > m4u_xml_extn_utils.g_elmnt_count THEN
                        x_xml       := NULL;
                        x_nxt_idx   := a_strt_idx;
                        x_ret_sts   := g_success_code;
                        x_ret_msg   := NULL;
                        RETURN;
                END IF;

                l_elmt_rec   := m4u_xml_extn_utils.g_elmnt_map(a_strt_idx);
                l_lvl_id     := l_elmt_rec.lvl_id;


                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Obtained element record',1);
                        cln_debug_pub.add('l_elmt_rec.id  - ' || l_elmt_rec.id,1);
                        cln_debug_pub.add('l_lvl_id       - ' || l_lvl_id,1);
                END IF;

                m4u_xml_extn_utils.init_level(l_lvl_id,l_lvl_rec,x_ret_sts, x_ret_msg);
                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('m4u_xml_extn_utils.init_level returned',1);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,1);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,1);
                END IF;
                IF x_ret_sts <> g_success_code THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                m4u_xml_extn_utils.push_lvl_stack(l_lvl_id,x_ret_sts,x_ret_msg);
                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('m4u_xml_extn_utils.push_lvl_stack returned',1);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,1);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,1);
                END IF;
                IF x_ret_sts <> g_success_code THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Level count - ' || l_lvl_rec.rpt_count,1);
                END IF;


                l_cur_idx := a_strt_idx;
                l_prv_idx := -1;
                l_nxt_idx := -1;
                l_ret_idx := -1;

                WHILE l_lvl_rec.cntr < l_lvl_rec.rpt_count LOOP

                        l_progress := 'Processing element(idx) - ' || l_cur_idx;

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Level loop   - ' || l_lvl_rec.cntr,1);
                                cln_debug_pub.add('l_cur_idx    - ' || l_cur_idx,1);
                                cln_debug_pub.add('l_prv_idx    - ' || l_prv_idx,1);
                                cln_debug_pub.add('l_nxt_idx    - ' || l_nxt_idx,1);
                        END IF;

                        IF l_cur_idx > m4u_xml_extn_utils.g_elmnt_count THEN
                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('l_cur_idx > g_elmnt_count',1);
                                END IF;

                                l_lvl_rec.cntr  := l_lvl_rec.cntr + 1;
                                l_xml           := l_xml || pop_end_tags(-1,l_lvl_rec,x_ret_sts,x_ret_msg);
                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('pop_end_tags - ' || x_ret_sts,1);
                                END IF;
                                IF x_ret_sts <> g_success_code THEN
                                        RAISE FND_API.G_EXC_ERROR;
                                END IF;
                                l_prv_idx       := l_cur_idx;
                                l_cur_idx       := a_strt_idx;
                                -- store changes back into global list of levels
                                m4u_xml_extn_utils.g_lvl_rec_tab(l_lvl_id) := l_lvl_rec;
                        ELSE
                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('l_cur_idx <= g_elmnt_count',1);
                                END IF;

                                l_elmt_rec      := m4u_xml_extn_utils.g_elmnt_map(l_cur_idx);

                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('l_elmt_rec.id - ' || l_elmt_rec.id,1);
                                END IF;

                                IF l_elmt_rec.lvl_id = l_lvl_id THEN

                                        IF g_log_lvl <= 1 THEN
                                                cln_debug_pub.add('l_elmt_rec.lvl_id = l_lvl_id',1);
                                        END IF;

                                        l_xml := l_xml || pop_end_tags(l_elmt_rec.parent_id,l_lvl_rec,x_ret_sts,x_ret_msg);


                                        IF g_log_lvl <= 1 THEN
                                                cln_debug_pub.add('pop_end_tags x_ret_sts - ' || x_ret_sts,1);
                                        END IF;
                                        IF x_ret_sts <> g_success_code THEN
                                                RAISE FND_API.G_EXC_ERROR;
                                        END IF;

                                        l_xml := l_xml || process_element(l_elmt_rec,l_cur_idx,l_lvl_rec,
                                                                        l_nxt_idx,x_ret_sts,x_ret_msg);

                                        IF g_log_lvl <= 1 THEN
                                            cln_debug_pub.add('process_element x_ret_sts - ' || x_ret_sts,1);
                                        END IF;
                                        IF x_ret_sts <> g_success_code THEN
                                                RAISE FND_API.G_EXC_ERROR;
                                        END IF;

                                        l_prv_idx := l_cur_idx;
                                        l_cur_idx := l_nxt_idx;
                                        -- store changes back into global list of levels
                                        m4u_xml_extn_utils.g_lvl_rec_tab(l_lvl_id) := l_lvl_rec;

                                ELSE
                                        IF g_log_lvl <= 1 THEN
                                                cln_debug_pub.add('l_elmt_rec.lvl_id <> l_lvl_id',1);
                                        END IF;

                                        l_child_lvl := false;

                                        FOR i IN 1..l_cur_idx-1 LOOP
                                                IF m4u_xml_extn_utils.g_elmnt_map(i).id = l_elmt_rec.parent_id THEN
                                                        IF m4u_xml_extn_utils.g_elmnt_map(i).lvl_id = l_lvl_id THEN
                                                                l_child_lvl := true;
                                                        END IF;
                                                END IF;
                                        END LOOP;

                                        IF l_child_lvl THEN
                                                IF g_log_lvl <= 1 THEN
                                                        cln_debug_pub.add('Child level found',1);
                                                END IF;
                                                l_xml := l_xml || pop_end_tags(l_elmt_rec.parent_id,l_lvl_rec,x_ret_sts,x_ret_msg);

                                                IF g_log_lvl <= 1 THEN
                                                        cln_debug_pub.add('pop_end_tags  - ' || x_ret_sts,1);
                                                END IF;
                                                IF x_ret_sts <> g_success_code THEN
                                                        RAISE FND_API.G_EXC_ERROR;
                                                END IF;

                                                process_level(l_cur_idx,l_tmp_xml,l_nxt_idx,x_ret_sts,x_ret_msg);

                                                IF g_log_lvl <= 1 THEN
                                                        cln_debug_pub.add('process_level x_ret_sts - ' || x_ret_sts,1);
                                                        cln_debug_pub.add('process_level l_nxt_idx - ' || l_nxt_idx,1);
                                                END IF;

                                                -- x_ret_msg now contains level/element-idx where
                                                -- the error has occured, dont over-write it
                                                IF x_ret_sts <> g_success_code THEN
                                                        RAISE HANDLED_EXCEPTION;
                                                END IF;

                                                l_xml := l_xml || l_tmp_xml;
                                                l_prv_idx := l_cur_idx;
                                                l_cur_idx := l_nxt_idx;

                                                IF l_nxt_idx <= m4u_xml_extn_utils.g_elmnt_count THEN
                                                        IF m4u_xml_extn_utils.g_elmnt_map(l_nxt_idx).lvl_id <> l_lvl_id THEN
                                                                l_ret_idx := l_nxt_idx;
                                                        END IF;
                                                ELSE
                                                        l_ret_idx := l_nxt_idx;
                                                END IF;
                                                -- store changes back into global list of levels
                                                m4u_xml_extn_utils.g_lvl_rec_tab(l_lvl_id) := l_lvl_rec;
                                        ELSE
                                                IF g_log_lvl <= 1 THEN
                                                        cln_debug_pub.add('non-child level found',1);
                                                END IF;
                                                l_xml := l_xml || pop_end_tags(-1,l_lvl_rec,x_ret_sts,x_ret_msg);

                                                IF g_log_lvl <= 1 THEN
                                                        cln_debug_pub.add('pop_end_tags x_ret_sts - ' || x_ret_sts,1);
                                                END IF;
                                                IF x_ret_sts <> g_success_code THEN
                                                        RAISE FND_API.G_EXC_ERROR;
                                                END IF;

                                                l_lvl_rec.cntr  := l_lvl_rec.cntr +1;
                                                l_prv_idx   := -1;
                                                l_nxt_idx   := -1;
                                                l_cur_idx   := a_strt_idx;
                                                -- store changes back into global list of levels
                                                m4u_xml_extn_utils.g_lvl_rec_tab(l_lvl_id) := l_lvl_rec;
                                        END IF;
                                END IF;
                        END IF;

                END LOOP;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('outside loop - ' || l_lvl_rec.cntr ,1);
                END IF;

                -- just to make sure
                l_xml := l_xml || pop_end_tags(-1,l_lvl_rec,x_ret_sts,x_ret_msg);
                m4u_xml_extn_utils.g_lvl_rec_tab(l_lvl_id) := l_lvl_rec;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('pop_end_tags x_ret_sts - ' || x_ret_sts,1);
                END IF;
                IF x_ret_sts <> g_success_code THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                -- above code can be deleted

                m4u_xml_extn_utils.un_init_level(l_lvl_id,x_ret_sts,x_ret_msg);
                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('m4u_xml_extn_utils.un_init_level - ' || x_ret_sts,1);
                END IF;
                IF x_ret_sts <> g_success_code THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;


                IF l_ret_idx = -1 THEN
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Finding ret_idx for lvl_id - ' || l_lvl_id,1);
                        END IF;
                        l_ret_idx := next_lvl_elmnt(a_strt_idx,l_lvl_id,x_ret_sts,x_ret_msg);
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('ret_idx  - ' || l_ret_idx ,1);
                        END IF;
                        IF x_ret_sts <> g_success_code THEN
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                END IF;
                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('m4u_xml_extn_utils.next_lvl_elmnt: l_ret_idx - ' || l_ret_idx,1);
                END IF;

                l_lvl_id := m4u_xml_extn_utils.pop_lvl_stack(x_ret_sts,x_ret_msg);
                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('m4u_xml_extn_utils.pop_lvl_stack x_ret_sts - ' || x_ret_sts,1);
                END IF;
                IF x_ret_sts <> g_success_code THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                x_xml         := l_xml;
                x_ret_sts     := g_success_code;
                x_ret_msg     := NULL;
                x_nxt_idx     := l_ret_idx;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn.process_level',2);
                END IF;
        EXCEPTION
                WHEN  FND_API.G_EXC_ERROR THEN
                        IF g_log_lvl <= 6 THEN
                                cln_debug_pub.add('process_level - WHEN FND_API.G_EXC_ERROR',6);
                                cln_debug_pub.add('l_lvl_id   - ' || l_lvl_id   ,6);
                                cln_debug_pub.add('l_cur_idx  - ' || l_cur_idx  ,6);
                                cln_debug_pub.add('l_progress - ' || l_progress ,6);
                                cln_debug_pub.add('x_ret_msg  - ' || x_ret_msg  ,6);
                        END IF;

                        FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_PROCESS_ERR');
                        FND_MESSAGE.SET_TOKEN('LEVEL_ID'    ,l_lvl_id);
                        FND_MESSAGE.SET_TOKEN('ELEMENT_IDX' ,l_cur_idx);
                        FND_MESSAGE.SET_TOKEN('ACTION'      ,l_progress);
                        FND_MESSAGE.SET_TOKEN('ERROR'       ,x_ret_msg);
                        x_ret_msg := FND_MESSAGE.GET;
                        x_ret_sts := g_err_code;

                WHEN  HANDLED_EXCEPTION   THEN
                        IF g_log_lvl <= 6 THEN
                                cln_debug_pub.add('process_level - HANDLED_EXCEPTION ',6);
                                cln_debug_pub.add('l_lvl_id   - ' || l_lvl_id   ,6);
                                cln_debug_pub.add('l_cur_idx  - ' || l_cur_idx  ,6);
                                cln_debug_pub.add('l_progress - ' || l_progress ,6);
                                cln_debug_pub.add('x_ret_msg  - ' || x_ret_msg  ,6);
                        END IF;
                        x_ret_sts := g_err_code;
                WHEN OTHERS THEN
                        m4u_xml_extn_utils.handle_exception(SQLCODE,SQLERRM,l_progress,
                        'm4u_xml_extn.process_level',x_ret_sts,x_ret_msg);
        END process_level;


        -- Generate XML fragment for given extn, tp_id combination
        -- global variables for xml generation can be passed in a_param_lst
        -- generated XML is copied back to x_xml
        -- if a_tp_dflt = true then M4U_DEFAULT_TP is used as default TP mapping
        PROCEDURE generate_xml_fragment
        (
                a_extn_name             IN              VARCHAR2,
                a_tp_id                 IN              VARCHAR2,
                a_tp_dflt               IN              BOOLEAN,
                a_param_lst             IN              wf_parameter_list_t,
                a_log_lvl               IN              NUMBER,
                a_remove_empty_elmt     IN              BOOLEAN,
                a_remove_empty_attr     IN              BOOLEAN,
                x_ret_sts               OUT NOCOPY      VARCHAR2,
                x_ret_msg               OUT NOCOPY      VARCHAR2,
                x_xml                   OUT NOCOPY      VARCHAR2
        ) AS
                l_tp_id         NUMBER;
                l_xml_frgmt     VARCHAR2(32767);
                l_api_ret_sts   VARCHAR2(30);
                l_api_ret_msg   VARCHAR2(4000);
                l_valdtn_sts    VARCHAR2(30);
                l_valdtn_msg    VARCHAR2(4000);
                l_nxt           NUMBER;
                l_progress      VARCHAR2(4000);
        BEGIN

                g_log_lvl := NVL(a_log_lvl,g_log_lvl);
                g_remove_empty_elmt := a_remove_empty_elmt;
                g_remove_empty_attr := a_remove_empty_attr;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn.generate_xml_fragment',2);
                        cln_debug_pub.add('a_extn_name  - ' || a_extn_name,     2);
                        cln_debug_pub.add('a_tp_id      - ' || a_tp_id  ,       2);
                        IF a_tp_dflt THEN
                                cln_debug_pub.add('a_tp_default         - Y' ,2);
                        ELSE
                                cln_debug_pub.add('a_tp_default         - N' ,2);
                        END IF;
                        cln_debug_pub.add('a_log_lvl    - ' || a_log_lvl,       2);
                END IF;

                -- load map data into memory structures
                l_progress := 'XML fragment generation - Map initialization';
                m4u_xml_extn_utils.init_map(
                                             a_extn_name        => a_extn_name,
                                             a_tp_id            => a_tp_id,
                                             a_dflt_tp          => a_tp_dflt,
                                             a_param_list       => a_param_lst,
                                             a_log_lvl          => a_log_lvl,
                                             x_ret_sts          => x_ret_sts,
                                             x_ret_msg          => x_ret_msg);


                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Returned from API m4u_xml_extn_utils.init_map',1);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,1);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,1);
                END IF;

                IF x_ret_sts <> g_success_code THEN
                        FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_INIT_ERR');
                        FND_MESSAGE.SET_TOKEN('EXTN_NAME',a_extn_name);
                        FND_MESSAGE.SET_TOKEN('TP_ID',a_tp_id);
                        x_ret_msg := FND_MESSAGE.GET || ' - ' || x_ret_msg;
                        RETURN;
                END IF;

                l_progress := 'XML fragment generation - Map processing';
                -- process elememts starting from element 1
                process_level(  a_strt_idx      => 1,
                                x_xml           => l_xml_frgmt,
                                x_nxt_idx       => l_nxt,
                                x_ret_sts       => x_ret_sts,
                                x_ret_msg       => x_ret_msg);

                IF x_ret_sts <> g_success_code THEN
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Returned from API m4u_xml_extn_utils.process_level Error',1);
                        END IF;
                        FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_XMLGEN_ERR');
                        FND_MESSAGE.SET_TOKEN('EXTN_NAME',a_extn_name);
                        FND_MESSAGE.SET_TOKEN('TP_ID',a_tp_id);
                        x_ret_msg := FND_MESSAGE.GET || ' - ' || x_ret_msg;
                        RETURN;
                END IF;

                l_progress := 'XML fragment generation - Logging';

                -- log generated XML
                m4u_xml_extn_utils.log_xml(a_xml        => l_xml_frgmt ,
                                           x_ret_sts   => l_api_ret_sts,
                                           x_ret_msg   => l_api_ret_msg);

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Returned from m4u_xml_utils.log_xml',1);
                        cln_debug_pub.add('x_ret_sts - ' || l_api_ret_sts,1);
                        cln_debug_pub.add('x_ret_msg - ' || l_api_ret_msg,1);
                END IF;

                l_progress := 'XML fragment generation - Validation';

                -- validate generated XML
                IF l_xml_frgmt IS NOT NULL AND length(l_xml_frgmt) > 0 THEN
                        m4u_xml_extn_utils.validate(a_xml           => l_xml_frgmt,
                                                x_valdtn_sts    => l_valdtn_sts,
                                                x_valdtn_msg    => l_valdtn_msg,
                                                x_api_ret_sts   => l_api_ret_sts,
                                                x_api_ret_msg   => l_api_ret_msg);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Returned from m4u_xml_utils.validate',1);
                                cln_debug_pub.add('x_valdtn_sts  - ' || l_valdtn_sts,1);
                                cln_debug_pub.add('x_valdtn_msg  - ' || l_valdtn_msg,1);
                                cln_debug_pub.add('x_api_ret_sts - ' || l_api_ret_sts,1);
                                cln_debug_pub.add('x_api_ret_msg - ' || l_api_ret_msg,1);
                        END IF;

                        -- return success/failure of validation
                        IF l_api_ret_sts = g_success_code THEN
                                x_ret_sts := l_valdtn_sts;
                                x_ret_msg := l_valdtn_msg;
                        ELSE
                                x_ret_sts := g_unexp_err_code;
                                x_ret_msg := l_api_ret_msg;
                        END IF;
                END IF;

                x_xml := l_xml_frgmt;

                l_progress := 'XML fragment generation - free resources';
                -- free-memory used by map
                m4u_xml_extn_utils.un_init_map(
                                        x_ret_sts => l_api_ret_sts ,
                                        x_ret_msg => l_api_ret_msg);
                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Returned from m4u_xml_extn_utils.un_init_map',1);
                        cln_debug_pub.add('x_api_ret_sts - ' || l_api_ret_sts,1);
                        cln_debug_pub.add('x_api_ret_msg - ' || l_api_ret_msg,1);
                END IF;


                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn.generate_xml_fragment - NORMAL',2);
                END IF;
                RETURN;
        EXCEPTION
                WHEN OTHERS THEN
                        m4u_xml_extn_utils.handle_exception(SQLCODE,SQLERRM,l_progress,
                                'm4u_xml_extn.generate_xml_fragment',x_ret_sts,x_ret_msg);
                        BEGIN
                                m4u_xml_extn_utils.un_init_map(
                                        x_ret_sts => l_api_ret_sts ,
                                        x_ret_msg => l_api_ret_msg);
                        EXCEPTION
                                WHEN OTHERS THEN
                                        null;
                        END;
        END generate_xml_fragment;

BEGIN
        -- initialize contansts and profile dependant values
        g_log_lvl               := NVL(FND_PROFILE.VALUE('CLN_DEBUG_LEVEL'), 5);
        g_success_code          := FND_API.G_RET_STS_SUCCESS;
        g_err_code              := FND_API.G_RET_STS_ERROR;
        g_unexp_err_code        := FND_API.G_RET_STS_UNEXP_ERROR;
END m4u_xml_extn;

/
