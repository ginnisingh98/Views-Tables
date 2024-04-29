--------------------------------------------------------
--  DDL for Package FLM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_UTIL" AUTHID CURRENT_USER AS
/* $Header: FLMUTILS.pls 115.5 2003/05/02 01:26:59 yulin ship $  */

TYPE NODE_t IS RECORD (
    x 		NUMBER,
    y		NUMBER,
    sub		INTEGER
  );
TYPE NODE_LIST IS TABLE OF NODE_t INDEX BY BINARY_INTEGER;

TYPE LINK_t IS RECORD (
    n1		INTEGER,
    n2          INTEGER
  );
TYPE LINK_LIST IS TABLE OF LINK_t INDEX BY BINARY_INTEGER;

FLM_APPLICATION_ID  CONSTANT NUMBER :=  714;

FUNCTION get_key_flex_category(cat_id IN NUMBER) return VARCHAR2;
FUNCTION get_key_flex_item(item_id IN NUMBER, org_id IN NUMBER) return VARCHAR2;
FUNCTION get_key_flex_location(loc_id IN NUMBER, org_id IN NUMBER) return VARCHAR2;

/******************************************************************************
 * set_graph_coordinates, when passed in a graph, will position the nodes
 * automatically.
 * First we position all notes in a logical x-coordinate system;
 * After this step, all nodes are divided into one or more connected components
 * of a directed graph. X-position of a node is actually the relative position
 * to its neighbors; Then for each component, at each x-position, we put nodes
 * there into different logical y-positions (also relative position);
 * Finally, we move those nodes into world coordinate system one component
 * above another (vertically).
 ******************************************************************************/
PROCEDURE set_graph_coordinates(llist LINK_LIST, nlist IN OUT NOCOPY NODE_LIST);

/***********************************************
 * check whether Flow Manufacturing Application
 * is installed.
 ***********************************************/
FUNCTION Get_Install_Status RETURN VARCHAR2;


/****************************************************
 * to handle dynamic sql parameter binding
 * What we do is to maintain a list of bind
 * variables, their name and value
 * and do the binding later when do_binds is called
 *
 * Example :
 *  flm_util.init_bind;
 *
 *  ...
 * l_where_clause := l_where_clause || ' AND wip_entity_id =:wip_entity_id '
 * flm_util.add_bind(':wip_entity_id' , p_wip_entity_id);
 *
 * l_cursor := dbms_sql.open_cursor(l_sql);
 * dbms_sql.parse(...);
 *
 * flm_util.do_binds(l_cursor);
 *
 * dbms_sql.execute(...);
 * ...
 ****************************************************/
TYPE t_bind_rec IS RECORD (
        name        VARCHAR2(256),
        data_type   NUMBER, -- 1 string, 2 numer, 3 date
        value_string VARCHAR2(1024),
        value_number NUMBER,
        value_date   DATE );

TYPE t_bind_table IS TABLE OF t_bind_rec
        INDEX BY BINARY_INTEGER;

g_bind_table t_bind_table;

PROCEDURE init_bind;

FUNCTION get_next_bind_seq RETURN NUMBER;

PROCEDURE add_bind(p_name IN VARCHAR2, p_string IN VARCHAR2);

PROCEDURE add_bind(p_name IN VARCHAR2, p_number IN NUMBER);

PROCEDURE add_bind(p_name IN VARCHAR2, p_date IN DATE);

PROCEDURE do_binds( p_cursor IN INTEGER );

/**********************************************************
 * Construction where clause for cateogry/item flex fiedls.
 * It's done in a segment by segment fasion.
 * These two uses the bind procedures (above), so make sure
 * the caller use them also.
 *
 * These two are moved from Mrp_Flow_Schedule_Util package.
 *********************************************************/
FUNCTION Category_Where_Clause (  p_cat_lo      IN      VARCHAR2,
                                  p_cat_hi      IN      VARCHAR2,
                                  p_table_name  IN      VARCHAR2,
                                  p_cat_struct_id IN    NUMBER,
                                  p_where       OUT     NOCOPY	VARCHAR2,
                                  x_err_buf     OUT     NOCOPY	VARCHAR2 )
RETURN BOOLEAN;

FUNCTION Item_Where_Clause( p_item_lo           IN      VARCHAR2,
                             p_item_hi          IN      VARCHAR2,
                             p_table_name       IN      VARCHAR2,
                             x_where            OUT     NOCOPY	VARCHAR2,
                             x_err_buf          OUT     NOCOPY	VARCHAR2)
RETURN BOOLEAN;


END flm_util;

 

/
