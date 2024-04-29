--------------------------------------------------------
--  DDL for Package EDW_SIZE_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SIZE_WRAPPER" AUTHID CURRENT_USER AS
/* $Header: EDWAUTSS.pls 115.7 2002/12/05 23:22:36 sbuenits noship $*/


PROCEDURE function_call(errbuf            OUT NOCOPY  VARCHAR2,
                        retcode           OUT NOCOPY  VARCHAR2,
                        p_log_name        IN   VARCHAR2,
                        p_from_date       IN   VARCHAR2,
                        p_to_date         IN   VARCHAR2,
                        p_input_num_rows  IN   NUMBER DEFAULT 0,
                        p_custom          IN   NUMBER DEFAULT 0,
                        p_commit_size     IN   NUMBER DEFAULT 10000);

PROCEDURE calculate_detail(p_avg_row_len NUMBER, p_num_rows NUMBER);

PROCEDURE print_f (v_TABLE_OWNER                     VARCHAR2,
                   v_FROM_DATE                       VARCHAR2,
                   v_TO_DATE                         VARCHAR2,
                   v_TEMP_SIZE_SOURCE                NUMBER,
                   v_AVG_ROW_LEN_STAGE               NUMBER,
                   v_AVG_ROW_LEN                     NUMBER,
                   v_AVG_ROW_LEN_IND_S               NUMBER,
                   v_AVG_ROW_LEN_IND                 NUMBER,
                   v_NUM_ROWS                        NUMBER,
                   v_TABLE_SIZE_STAGE                NUMBER,
                   v_INDEX_SIZE_STAGE                NUMBER,
                   v_TABLE_SIZE                      NUMBER,
                   v_INDEX_SIZE                      NUMBER,
                   v_TEMP_SIZE                       NUMBER,
                   v_RB_SIZE                         NUMBER,
                   v_TEMP_TABLE_SIZE                 NUMBER,
                   v_TOTAL_PEM_SPACE                 NUMBER,
                   v_TOTAL_TMP_SPACE                 NUMBER);


PROCEDURE print_m (v_TABLE_OWNER                     VARCHAR2,
                   v_FROM_DATE                       VARCHAR2,
                   v_TO_DATE                         VARCHAR2,
                   v_AVG_ROW_LEN_STAGE               NUMBER,
                   v_AVG_ROW_LEN_LEVEL               NUMBER,
                   v_AVG_ROW_LEN                     NUMBER,
                   v_AVG_ROW_LEN_IND_S               NUMBER,
                   v_AVG_ROW_LEN_IND_L               NUMBER,
                   v_AVG_ROW_LEN_IND                 NUMBER,
                   v_NUM_ROWS                        NUMBER,
                   v_TABLE_SIZE_STAGE                NUMBER,
                   v_INDEX_SIZE_STAGE                NUMBER,
                   v_TABLE_SIZE_LEVEL                NUMBER,
                   v_INDEX_SIZE_LEVEL                NUMBER,
                   v_TABLE_SIZE                      NUMBER,
                   v_INDEX_SIZE                      NUMBER,
                   v_TEMP_SIZE                       NUMBER,
                   v_RB_SIZE                         NUMBER,
                   v_TEMP_TABLE_SIZE                 NUMBER,
                   v_TOTAL_PEM_SPACE                 NUMBER,
                   v_TOTAL_TMP_SPACE                 NUMBER);

PROCEDURE show_results (errbuf        OUT NOCOPY VARCHAR2,
                        retcode       OUT NOCOPY VARCHAR2,
                        p_log_name    IN   VARCHAR2);

g_table_name       VARCHAR2(70)   := 'null';
g_table_type       VARCHAR2(30)   := 'null';
g_log_name         VARCHAR2(200)  := 'null';
g_schema           VARCHAR2(30)   := 'null';
g_message          VARCHAR2(2000) := 'null';
g_from_date        DATE;
g_to_date          DATE;
g_custom           NUMBER;
g_commit_size      NUMBER;
g_all_index_space  NUMBER := 0;
g_all_table_space  NUMBER := 0;


END;

 

/
