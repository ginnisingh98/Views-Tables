--------------------------------------------------------
--  DDL for Package ICX_POR_ITEM_UPLOAD_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_ITEM_UPLOAD_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: ICXIULVS.pls 115.3 2002/05/23 13:19:04 pkm ship    $*/

PROCEDURE validate_interface_data (p_job_supplier_name IN VARCHAR2,
                                   p_job_supplier_id IN NUMBER,
                                   p_exchange_operator_name IN VARCHAR2,
                                   p_table_name IN VARCHAR2,
                                   p_language IN VARCHAR2,
                                   p_row_count IN NUMBER);

PROCEDURE validate_interface_data (p_job_supplier_name IN VARCHAR2,
                                   p_job_supplier_id IN NUMBER,
                                   p_exchange_operator_name IN VARCHAR2,
                                   p_table_name IN VARCHAR2,
                                   p_language IN VARCHAR2,
                                   p_start_row IN NUMBER,
                                   p_end_row IN NUMBER);

PROCEDURE set_debug_channel(p_debug_channel IN number);

/* Procedure to insert the log messages into fnd_log_messages table */
PROCEDURE insert_fnd_log_messages (p_debug_bind_variables VARCHAR2,
				   p_debug_sql_string     VARCHAR2);

/* This will be set to TRUE when the DEBUG_CHANNEL is ON in the
Loader configuration file. This will be set only at the time of
starting up the loader */
g_debug_channel   BOOLEAN       := FALSE;
g_job_number      NUMBER        := null;
g_module_name     VARCHAR2(50)  := 'ICX.PLSQL.LOADER.';

END ICX_POR_ITEM_UPLOAD_VALIDATE;

 

/
