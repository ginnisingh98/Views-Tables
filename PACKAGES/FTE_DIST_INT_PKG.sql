--------------------------------------------------------
--  DDL for Package FTE_DIST_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_DIST_INT_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEDISIS.pls 115.2 2003/09/13 19:40:47 ablundel noship $ */

-- ------------------------------------------------------------------------------------------- --
--                                                                                             --
-- Tables and records for input                                                                --
-- ----------------------------                                                                --
--                                                                                             --
-- ------------------------------------------------------------------------------------------- --
TYPE fte_dist_input_rec IS RECORD(origin_id           NUMBER,
                                  destination_id      NUMBER);
TYPE fte_dist_input_tab IS TABLE OF fte_dist_input_rec INDEX BY BINARY_INTEGER;


TYPE fte_dist_search_rec IS RECORD(origin_id           NUMBER,
                                   destination_id      NUMBER,
                                   origin_loc_id       NUMBER,
                                   dest_loc_id         NUMBER);
TYPE fte_dist_search_tab IS TABLE OF fte_dist_search_rec INDEX BY BINARY_INTEGER;


TYPE fte_dist_output_rec IS RECORD (location_region_flag      VARCHAR2(1),
                                    origin_location_id        NUMBER,
                                    destination_location_id   NUMBER,
                                    origin_region_id          NUMBER,
                                    destination_region_id     NUMBER,
                                    type                      VARCHAR2(30),
                                    distance                  NUMBER,
                                    distance_uom              VARCHAR2(3),
                                    transit_time              NUMBER,
                                    transit_time_uom          VARCHAR2(3),
                                    status                    VARCHAR2(1),
                                    error_msg                 VARCHAR2(240),
                                    msg_id                    NUMBER);
TYPE fte_dist_output_tab IS TABLE OF fte_dist_output_rec INDEX BY BINARY_INTEGER;


TYPE fte_dist_output_message_rec IS RECORD (sequence_number       NUMBER,
                                            message_type          VARCHAR2(1),
                                            message_code          VARCHAR2(30),
                                            message_text          VARCHAR2(2000),
                                            level                 VARCHAR2(30),
                                            location_region_flag  VARCHAR2(1),
                                            table_origin_id       NUMBER,
                                            table_destination_id  NUMBER,
                                            input_origin_id       NUMBER,
                                            input_destination_id  NUMBER);
TYPE fte_dist_output_message_tab IS TABLE OF fte_dist_output_message_rec INDEX BY BINARY_INTEGER;
-- ----------------------------------------------------------------------------------------- --




-- -----------------------------------------------------------------------------------
-- GLOBAL VARIABLES/CONSTANTS
-- --------------------------
--
-- -----------------------------------------------------------------------------------
g_max_table_size    CONSTANT PLS_INTEGER := 150;


TYPE fte_dist_tmp_num_table      IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE fte_dist_tmp_flag_table     IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE fte_dist_tmp_uom_table      IS TABLE OF VARCHAR2(3)    INDEX BY BINARY_INTEGER;
TYPE fte_dist_tmp_char4_table    IS TABLE OF VARCHAR2(4)    INDEX BY BINARY_INTEGER;
TYPE fte_dist_tmp_code_table     IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE fte_dist_tmp_desc_table     IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
TYPE fte_dist_tmp_msg_table      IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE fte_dist_tmp_date_table     IS TABLE OF DATE           INDEX BY BINARY_INTEGER;





-- ------------------------------------------------------------------------------------------- --
--                                                                                             --
-- PROCEDURE DEFINITONS                                                                        --
-- --------------------                                                                        --
--                                                                                             --
-- ------------------------------------------------------------------------------------------- --
PROCEDURE GET_DISTANCE_TIME(p_distance_input_tab   IN  OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_input_tab,
                            p_location_region_flag IN  VARCHAR2,
                            p_messaging_yn         IN  VARCHAR2,
                            p_api_version          IN  VARCHAR2,
                            p_command              IN  VARCHAR2,
                            x_distance_output_tab  OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_output_tab,
                            x_distance_message_tab OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_output_message_tab,
                            x_return_message       OUT NOCOPY VARCHAR2,
                            x_return_status        OUT NOCOPY VARCHAR2);



PROCEDURE LOG_DISTANCE_MESSAGES(p_message_type_tab         IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_flag_table,
                                p_message_code_tab         IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_code_table,
                                p_message_text_tab         IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_msg_table,
                                p_location_region_flag_tab IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_flag_table,
                                p_level_tab                IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_code_table,
                                p_table_origin_id_tab      IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_num_table,
                                p_table_destination_id_tab IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_num_table,
                                p_input_origin_id_tab      IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_num_table,
                                p_input_destination_tab    IN OUT NOCOPY FTE_DIST_INT_PKG.fte_dist_tmp_num_table,
                                x_return_status            OUT NOCOPY VARCHAR2,
                                x_return_message           OUT NOCOPY VARCHAR2);


END FTE_DIST_INT_PKG;

 

/
