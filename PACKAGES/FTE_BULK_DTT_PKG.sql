--------------------------------------------------------
--  DDL for Package FTE_BULK_DTT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_BULK_DTT_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEDISUS.pls 115.6 2004/01/27 00:39:51 ablundel noship $ */


g_user_debug           NUMBER := 0;

TYPE fte_location_distance_rec IS RECORD(ORIGIN_ID                NUMBER,
                                         DESTINATION_ID           NUMBER,
                                         IDENTIFIER_TYPE          VARCHAR2(30),
                                         DISTANCE                 NUMBER,
                                         DISTANCE_UOM             VARCHAR2(3),
                                         TRANSIT_TIME             NUMBER,
                                         TRANSIT_TIME_UOM         VARCHAR2(3),
                                         CREATION_DATE            DATE,
                                         CREATED_BY               NUMBER,
                                         LAST_UPDATE_DATE         DATE,
                                         LAST_UPDATED_BY          NUMBER,
                                         LAST_UPDATE_LOGIN        NUMBER,
                                         PROGRAM_APPLICATION_ID   NUMBER,
                                         PROGRAM_ID               NUMBER,
                                         PROGRAM_UPDATE_DATE      DATE,
                                         REQUEST_ID               NUMBER);
TYPE fte_location_distance_tab IS TABLE OF fte_location_distance_rec INDEX BY BINARY_INTEGER;


TYPE fte_distu_tmp_num_table      IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE fte_distu_tmp_flag_table     IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE fte_distu_tmp_uom_table      IS TABLE OF VARCHAR2(3)    INDEX BY BINARY_INTEGER;
TYPE fte_distu_tmp_char4_table    IS TABLE OF VARCHAR2(4)    INDEX BY BINARY_INTEGER;
TYPE fte_distu_tmp_char10_table   IS TABLE OF VARCHAR2(10)   INDEX BY BINARY_INTEGER;
TYPE fte_distu_tmp_code_table     IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE fte_distu_tmp_char60_table   IS TABLE OF VARCHAR2(60)   INDEX BY BINARY_INTEGER;
TYPE fte_distu_tmp_desc_table     IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
TYPE fte_distu_tmp_msg_table      IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE fte_distu_tmp_date_table     IS TABLE OF DATE           INDEX BY BINARY_INTEGER;



PROCEDURE BULK_LOAD_DTT(p_load_id        IN         NUMBER,
                        p_src_filename   IN         VARCHAR2,
                        p_resp_id        IN         NUMBER,
                        p_resp_appl_id   IN         NUMBER,
                        p_user_id        IN         NUMBER,
                        p_user_debug     IN         NUMBER,
                        x_request_id     OUT NOCOPY NUMBER,
                        x_error_msg_text OUT NOCOPY VARCHAR2);


PROCEDURE LOAD_DTT_FILE(p_errbuf        OUT NOCOPY VARCHAR2,
                        p_retcode       OUT NOCOPY VARCHAR2,
                        p_load_id       IN NUMBER,
                        p_src_filename  IN VARCHAR2,
                        p_src_filedir   IN VARCHAR2,
                        p_user_debug    IN NUMBER);


PROCEDURE READ_DTT_FILE(p_source_file_directory  IN VARCHAR2,
                        p_source_file_name       IN VARCHAR2,
                        p_load_id                IN VARCHAR2,
                        x_return_message         OUT NOCOPY VARCHAR2,
                        x_return_status          OUT NOCOPY NUMBER);


FUNCTION FIRST_TIME RETURN BOOLEAN;


END FTE_BULK_DTT_PKG;

 

/
