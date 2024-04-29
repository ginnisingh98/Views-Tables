--------------------------------------------------------
--  DDL for Package FTE_DIST_DWNLD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_DIST_DWNLD_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEDISDS.pls 115.9 2004/03/18 20:18:28 ablundel noship $ */

-- ------------------------------------------------------------------------------------------- --
--                                                                                             --
-- Tables and records for input                                                                --
-- ----------------------------                                                                --
--                                                                                             --
-- ------------------------------------------------------------------------------------------- --
g_user_debug           NUMBER := 0;

TYPE fte_distd_tmplt_col_rec IS RECORD(seq        NUMBER,
                                       type       VARCHAR2(30),
                                       start_pos  NUMBER,
                                       length     NUMBER,
                                       delim      VARCHAR2(10));
TYPE fte_distd_tmplt_col_tab IS TABLE OF fte_distd_tmplt_col_rec INDEX BY BINARY_INTEGER;


TYPE  fte_distd_col_rec IS RECORD(seq         NUMBER,
                                  code        VARCHAR2(30),
                                  length      NUMBER,
                                  delim       VARCHAR2(10),
                                  start_pos   NUMBER,
                                  id          NUMBER);
TYPE fte_distd_col_tab IS TABLE OF fte_distd_col_rec INDEX BY BINARY_INTEGER;


TYPE  fte_distd_attr_rec IS RECORD(seq        NUMBER,
                                   code       VARCHAR2(30),
                                   length     NUMBER,
                                   delim      VARCHAR2(10));
TYPE  fte_distd_attr_tab IS TABLE OF  fte_distd_attr_rec INDEX BY BINARY_INTEGER;

TYPE fte_distd_region_rec IS RECORD(region_id    NUMBER,
                                    postal_code  VARCHAR2(30),
                                    city         VARCHAR2(60),
                                    state        VARCHAR2(60),
                                    county       VARCHAR2(60),
                                    country      VARCHAR2(60));
TYPE  fte_distd_region_tab IS TABLE OF fte_distd_region_rec INDEX BY BINARY_INTEGER;

TYPE fte_distd_od_pair_rec IS RECORD(origin_id        NUMBER,
                                     destination_id   NUMBER,
                                     origin_line      VARCHAR2(2000),
                                     destination_line VARCHAR2(2000),
                                     file_line        VARCHAR2(2000));
TYPE fte_distd_od_pair_tab IS TABLE OF fte_distd_od_pair_rec INDEX BY BINARY_INTEGER;

TYPE fte_distd_reg_code_rec IS RECORD(region_id     NUMBER,
                                      state_code    VARCHAR2(10),
                                      country_code  VARCHAR2(10));
TYPE fte_distd_reg_code_tab IS TABLE OF fte_distd_reg_code_rec INDEX BY BINARY_INTEGER;

-- -----------------------------------------------------------------------------------
-- GLOBAL VARIABLES/CONSTANTS
-- --------------------------
--
-- -----------------------------------------------------------------------------------
g_max_table_size    CONSTANT PLS_INTEGER := 150;


TYPE fte_distd_tmp_num_table      IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE fte_distd_tmp_flag_table     IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE fte_distd_tmp_uom_table      IS TABLE OF VARCHAR2(3)    INDEX BY BINARY_INTEGER;
TYPE fte_distd_tmp_char4_table    IS TABLE OF VARCHAR2(4)    INDEX BY BINARY_INTEGER;
TYPE fte_distd_tmp_char10_table   IS TABLE OF VARCHAR2(10)   INDEX BY BINARY_INTEGER;
TYPE fte_distd_tmp_code_table     IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE fte_distd_tmp_char60_table   IS TABLE OF VARCHAR2(60)   INDEX BY BINARY_INTEGER;
TYPE fte_distd_tmp_char80_table   IS TABLE OF VARCHAR2(80)   INDEX BY BINARY_INTEGER;
TYPE fte_distd_tmp_desc_table     IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
TYPE fte_distd_tmp_msg_table      IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE fte_distd_tmp_date_table     IS TABLE OF DATE           INDEX BY BINARY_INTEGER;





-- ------------------------------------------------------------------------------------------- --
--                                                                                             --
-- PROCEDURE DEFINITONS                                                                        --
-- --------------------                                                                        --
--                                                                                             --
-- ------------------------------------------------------------------------------------------- --
PROCEDURE BULK_DOWNLOAD_DTT(p_load_id                      IN NUMBER,
                            p_template_id                  IN NUMBER,
                            p_origin_facility_id           IN VARCHAR2,
                            p_origin_region_id             IN VARCHAR2,
                            p_origin_all_fac_flag          IN VARCHAR2,
                            p_all_fac_no_data_flag         IN VARCHAR2,
                            p_dest_facility_id             IN VARCHAR2,
                            p_dest_region_id               IN VARCHAR2,
                            p_dest_all_fac_flag            IN VARCHAR2,
                            p_file_extension               IN VARCHAR2,
                            p_src_filename                 IN VARCHAR2,
                            p_resp_id                      IN NUMBER,
                            p_resp_appl_id                 IN NUMBER,
                            p_user_id                      IN NUMBER,
                            p_user_debug                   IN NUMBER,
                            x_filename                     OUT NOCOPY VARCHAR2,
                            x_request_id                   OUT NOCOPY NUMBER,
                            x_error_msg_text               OUT NOCOPY VARCHAR2);

PROCEDURE DOWNLOAD_DTT_FILE(p_errbuf                      OUT NOCOPY VARCHAR2,
                            p_retcode                     OUT NOCOPY VARCHAR2,
                            p_load_id                     IN NUMBER,
                            p_src_filename                IN VARCHAR2,
                            p_src_filedir                 IN VARCHAR2,
                            p_user_debug                  IN NUMBER,
                            p_template_id                 IN NUMBER,
                            p_origin_facility_id          IN NUMBER,
                            p_origin_region_id            IN NUMBER,
                            p_origin_all_fac_flag         IN VARCHAR2,
                            p_all_fac_no_data_flag        IN VARCHAR2,
                            p_dest_facility_id            IN NUMBER,
                            p_dest_region_id              IN NUMBER,
                            p_dest_all_fac_flag           IN VARCHAR2,
                            p_file_extension              IN VARCHAR2);

PROCEDURE DOWNLOAD_OD_DATA(p_template_id                  IN NUMBER,
                           p_origin_facility_id           IN NUMBER,
                           p_origin_region_id             IN NUMBER,
                           p_origin_all_fac_flag          IN VARCHAR2,
                           p_all_fac_no_data_flag         IN VARCHAR2,
                           p_dest_facility_id             IN NUMBER,
                           p_dest_region_id               IN NUMBER,
                           p_dest_all_fac_flag            IN VARCHAR2,
                           p_file_extension               IN VARCHAR2,
                           p_user_debug_flag              IN VARCHAR2,
                           x_filename                     IN OUT NOCOPY VARCHAR2,
                           x_return_message               OUT NOCOPY VARCHAR2,
                           x_return_status                OUT NOCOPY VARCHAR2);


PROCEDURE CREATE_DWNLD_FILENAME(p_user_debug_flag IN VARCHAR2,
                                x_file_extension IN OUT NOCOPY VARCHAR2,
                                x_file_name      OUT NOCOPY VARCHAR2,
                                x_return_message OUT NOCOPY VARCHAR2,
                                x_return_status  OUT NOCOPY VARCHAR2);


PROCEDURE CREATE_DWNLD_FILE(p_origin_route      IN PLS_INTEGER,
                            p_destination_route IN PLS_INTEGER,
                            p_origin_id         IN NUMBER,
                            p_destination_id    IN NUMBER,
                            p_template_id       IN NUMBER,
                            p_file_name         IN VARCHAR2,
                            p_file_extension    IN VARCHAR2,
                            p_region_type       IN NUMBER,
                            p_distance_profile  IN VARCHAR2,
                            p_user_debug_flag   IN VARCHAR2,
                            x_return_message    OUT NOCOPY VARCHAR2,
                            x_return_status     OUT NOCOPY VARCHAR2);

FUNCTION FIRST_TIME RETURN BOOLEAN;



END FTE_DIST_DWNLD_PKG;

 

/
