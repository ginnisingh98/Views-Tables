--------------------------------------------------------
--  DDL for Package CTO_AUTO_PURGE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_AUTO_PURGE_PK" AUTHID CURRENT_USER AS
/*$Header: CTODCFGS.pls 120.3 2008/01/18 16:52:00 abhissri ship $ */
/*============================================================================+
|  Copyright (c) 1999 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   	: CTODCFGS.pls                                                |
| DESCRIPTION	: Purge Configurations from bom_ato_configurations table      |
| HISTORY     	: 							      |
| 26-Nov-2002	: Kundan Sarkar  Initial Version                              |
| 21-Jun-2005   : Renga  Kannan  Added nocopy for out parameters
|                             						      |
=============================================================================*/


   g_pkg_name     CONSTANT  VARCHAR2(30) := 'CTO_AUTO_PURGE_PK';


/**************************************************************************
   Procedure:   AUTO_PURGE
   Parameters:  p_base_model	     		NUMBER        -- Base model Id
                p_config_item			NUMBER        -- Config Item Id
                p_created_days_ago		NUMBER	      -- Number of days since creation
                p_last_ref_days_ago		NUMBER        -- Number of days since last referenced
   Description: This procedure is called from the concurrent program Purge
                Configuration Items .
*****************************************************************************/
PROCEDURE auto_purge (
	   errbuf	OUT NOCOPY	VARCHAR2,
	   retcode	OUT NOCOPY	VARCHAR2,
           p_created_days_ago	     	NUMBER,
           p_last_ref_days_ago	       	NUMBER,
           dummy                        VARCHAR2,
           p_config_item             	NUMBER,
           dummy2                        VARCHAR2,
           p_base_model              	NUMBER,
           p_option_item             	NUMBER default null ) ;
END cto_auto_purge_pk;

/
