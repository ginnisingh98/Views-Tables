--------------------------------------------------------
--  DDL for Package CZ_UI_GENERATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_UI_GENERATOR" AUTHID CURRENT_USER AS
/*	$Header: czuigens.pls 120.1 2007/11/26 12:12:10 kdande ship $		*/

TYPE IntArray     IS TABLE OF INTEGER INDEX BY VARCHAR2(15);
TYPE IntArrayIndexBinaryInt     IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
UIS  IntArray;
MUID INTEGER;

InterfaceName       VARCHAR2(1000);
MODE_REFRESH        BOOLEAN:=FALSE;
NO_FLAG             CONSTANT VARCHAR2(1):='0';
YES_FLAG            CONSTANT VARCHAR2(1):='1';

PROCEDURE createUI
(in_product_id       IN  INTEGER,
 out_ui_def_id       OUT NOCOPY INTEGER,
 out_run_id          OUT NOCOPY INTEGER,
 in_ui_style         IN  VARCHAR2 , -- DEFAULT 'COMPONENTS',
 in_frame_allocation IN  INTEGER  , -- DEFAULT 30,
 in_width            IN  INTEGER  , -- DEFAULT 640,
 in_height           IN  INTEGER  , -- DEFAULT 480,
 in_show_all_nodes   IN  VARCHAR2 , -- DEFAULT '0',
 in_use_labels       IN  VARCHAR2 , -- DEFAULT '1',
 in_look_and_feel    IN  VARCHAR2 , -- DEFAULT 'BLAF',
 in_max_bom_per_page IN  INTEGER  , -- DEFAULT 10,
 in_wizard_style     IN  VARCHAR2   -- DEFAULT '0'
);

PROCEDURE create_UI
(in_product_id       IN  INTEGER,
 in_ui_style         IN  VARCHAR2, -- DEFAULT 'COMPONENTS',
 in_show_all_nodes   IN  VARCHAR2, -- DEFAULT '0',
 in_frame_allocation IN  INTEGER , -- DEFAULT 30,
 in_width            IN  INTEGER , -- DEFAULT 640,
 in_height           IN  INTEGER , -- DEFAULT 480,
 in_use_labels       IN  VARCHAR2, -- DEFAULT '1',
 in_look_and_feel    IN  VARCHAR2, -- DEFAULT 'BLAF',
 in_max_bom_per_page IN  INTEGER , -- DEFAULT 10,
 in_wizard_style     IN  VARCHAR2  -- DEFAULT '0'
);

PROCEDURE refreshUI
(in_ui_def_id    IN OUT NOCOPY INTEGER,
 out_run_id      OUT NOCOPY    INTEGER);

PROCEDURE refresh_UI
(in_ui_def_id    IN INTEGER);

PROCEDURE  clone_it
(in_old_def_id   IN  INTEGER,
 in_new_def_id   IN  INTEGER,
 in_project_id   IN  INTEGER,
 in_replace_flag IN  VARCHAR2 -- DEFAULT NO_FLAG
);

PROCEDURE update_Labels
(in_ui_node_id IN INTEGER,
 in_use_labels IN VARCHAR2);

END CZ_UI_GENERATOR;

/
