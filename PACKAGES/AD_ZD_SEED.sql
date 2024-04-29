--------------------------------------------------------
--  DDL for Package AD_ZD_SEED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_ZD_SEED" AUTHID CURRENT_USER AS
/* $Header: ADZDSMS.pls 120.2.12010000.2 2011/02/21 13:39:47 smadhapp noship $ */

/* Global Constants */
MODE_DEFAULT CONSTANT NUMBER  := 0;
MODE_FNDLOAD CONSTANT NUMBER  := 1;

/* Patch Event APIs */
procedure PREPARE(x_table_name in varchar2 );

/* Public APIs */
procedure INIT_LOG(x_mode in number, x_log_level in number);

END AD_ZD_SEED;

/
