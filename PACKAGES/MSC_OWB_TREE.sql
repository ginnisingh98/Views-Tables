--------------------------------------------------------
--  DDL for Package MSC_OWB_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_OWB_TREE" AUTHID CURRENT_USER AS
/* $Header: MSCOSTRS.pls 115.5 2002/12/02 22:11:43 dsting ship $ */


LABEL_DELIM                     CONSTANT VARCHAR2(1) := '$';

--MFG_LOOKUPS

ORGANIZATIONS	   		CONSTANT NUMBER := 2;
CATEGORIES			CONSTANT NUMBER := 12;
EXCEPTIONS			CONSTANT NUMBER := 18;
SALES_ORDERS			CONSTANT NUMBER := 30;
SHIP_SETS			CONSTANT NUMBER := 31;
ARRIVAL_SETS			CONSTANT NUMBER := 32;
SHORTAGE			CONSTANT NUMBER := 33;
LATER_THAN_OLD_SCHEDULE_DATE	CONSTANT NUMBER := 34;
LATER_THAN_PROMISE_DATE		CONSTANT NUMBER := 35;
LATER_THAN_REQUEST_DATE		CONSTANT NUMBER := 36;
INSUFFICIENT_MARGIN		CONSTANT NUMBER := 37;
MODIFIED_SOURCE			CONSTANT NUMBER := 39;

SALES_ORDERS_N                  CONSTANT NUMBER := 40;
CATEGORY_SETS                   CONSTANT NUMBER := 41; -- not used
CATEGORY_SETS_N                 CONSTANT NUMBER := 42; -- not used
PRODUCT_FAMILIES_N              CONSTANT NUMBER := 43;
ITEMS                           CONSTANT NUMBER := 4;
SHIP_SETS_N			CONSTANT NUMBER := 45;
ARRIVAL_SETS_N			CONSTANT NUMBER := 46;
CATEGORIES_N                    CONSTANT NUMBER := 47;
PRODUCT_FAMILIES		CONSTANT NUMBER := 48;
ORGANIZATIONS_N                 CONSTANT NUMBER := 49;
INDEP_LINES                     CONSTANT NUMBER := 50;
SOURCES                         CONSTANT NUMBER := 51;
SOURCES_N                       CONSTANT NUMBER := 52;
ITEMS_N                         CONSTANT NUMBER := 53;
ERRORS                          CONSTANT NUMBER := 54;

-- I don't need Option classes in the text

EXCP_TREE                       CONSTANT NUMBER := 1;
ITEMS_TREE                      CONSTANT NUMBER := 2;
ORDERS_TREE                     CONSTANT NUMBER := 3;

NODES_IN_EXCP_TREE              CONSTANT NUMBER := 8;
NODES_IN_ORDERS_TREE            CONSTANT NUMBER := 5;
NODES_IN_ITEMS_TREE             CONSTANT NUMBER := 7;

ICON_FOLDER                     CONSTANT VARCHAR2(10) := 'aftreecl';
--ICON_SALES_ORDER                CONSTANT VARCHAR2(10) := 'MRPSAORD';
ICON_DEMAND                     CONSTANT VARCHAR2(10) := 'afplan';
ICON_MAKE_AT                    CONSTANT VARCHAR2(10) := 'mscmake1';
ICON_TRANSFER                   CONSTANT VARCHAR2(10) := 'msctxfer';
ICON_BUY                        CONSTANT VARCHAR2(10) := 'mscsupps';
ICON_SUP_CAP                    CONSTANT VARCHAR2(10) := 'mscsuppg';
ICON_SUP_CAP_CRIT               CONSTANT VARCHAR2(10) := 'mscsuppr';
--ICON_MATERIAL_DEM               CONSTANT VARCHAR2(10) := 'mscmatls';
ICON_MATERIAL                   CONSTANT VARCHAR2(10) := 'mscflagg'; -- 'mscmatlg';
ICON_MATERIAL_CRIT              CONSTANT VARCHAR2(10) := 'mscsupc'; -- 'mscmatlr';
--ICON_RESOURCE_DEM               CONSTANT VARCHAR2(10) := 'mschamrs';
ICON_RESOURCE_CAP               CONSTANT VARCHAR2(10) := 'mschamrg';
ICON_RESOURCE_CAP_CRIT          CONSTANT VARCHAR2(10) := 'mschamrr';
ICON_NO_PEGGING                 CONSTANT VARCHAR2(10) := 'mscnopeg';
ICON_BATCH_RESOURCE             CONSTANT VARCHAR2(10) := 'mscresbt';


LOOKUPS_COUNT                   CONSTANT NUMBER := 25;

NULL_VALUE   CONSTANT NUMBER := -1;

COLLAPSED   CONSTANT NUMBER := -1;
EXPANDED    CONSTANT NUMBER := 1;
LEAF_NODE   CONSTANT NUMBER := 0;
next_level  CONSTANT NUMBER := 1;
all_levels  CONSTANT NUMBER := 9999999999;
-- ATP Pegging
constraint_level CONSTANT NUMBER := 2;
/*
TYPE number_arr IS TABLE OF number;
TYPE char80_arr IS TABLE of VARCHAR2(80);
TYPE char100_arr IS TABLE of VARCHAR2(100);
TYPE char240_arr IS TABLE of VARCHAR2(240);
TYPE char_500_arr IS TABLE of VARCHAR2(500);

-- same as lookups_count
TYPE char80_var_arr IS varray(25) OF VARCHAR2(80);

lookups char80_var_arr;

TYPE nodeRec IS RECORD (
			tree_type             OWB_TREE.number_arr,
			parent_node_type      OWB_TREE.number_arr,
			state                 OWB_TREE.number_arr,
			depth                 OWB_TREE.number_arr,
			label                 OWB_TREE.char240_arr,
			icon                  OWB_TREE.char80_arr,
			data                  OWB_TREE.char80_arr
			);

TYPE nodeData IS RECORD (
			 state                 OWB_TREE.number_arr,
			 depth                 OWB_TREE.number_arr,
			 label                 OWB_TREE.char240_arr,
			 -- many things are concatenated in the sourcing tree.
			 icon                  OWB_TREE.char80_arr,
			 data                  OWB_TREE.char80_arr
			 );
*/

PROCEDURE getstructure ( p_session_id NUMBER,
			 p_mode       NUMBER,
			 p_nodes  OUT NoCopy OWB_TREE.noderec);
FUNCTION get_excp_count( p_session_id NUMBER,
			 col_num NUMBER) RETURN INTEGER ;
FUNCTION get_cust_hier_string
         (dmd_class in VARCHAR2) return VARCHAR2;

FUNCTION get_demand_class ( p_pegging_id IN NUMBER, p_session_id IN NUMBER)
          return VARCHAR2;

PROCEDURE get_Sourcing_Nodes(p_end_pegging_id    NUMBER,
			     p_session_id        NUMBER,
			     p_nodes OUT         NoCopy OWB_TREE.NodeData,
			     p_expand_level      NUMBER,
			     p_current_node_data NUMBER,
                             p_checkbox BOOLEAN DEFAULT FALSE);
PROCEDURE get_lookups;

record_count NUMBER;


END MSC_OWB_TREE;

 

/
