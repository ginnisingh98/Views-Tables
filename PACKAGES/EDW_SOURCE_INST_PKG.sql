--------------------------------------------------------
--  DDL for Package EDW_SOURCE_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SOURCE_INST_PKG" AUTHID CURRENT_USER AS
/* $Header: EDWSRCS.pls 115.0 99/09/03 14:12:45 porting shi $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |      EDWSRCS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM | APIs to upload and download translation data for edw_source_instances |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 04-AUG-99 arsantha   Creation
REM +=======================================================================+
*/
--
-- Data Types: Records
--
TYPE src_inst_rec_type IS RECORD
(
 Instance_code					 VARCHAR2(30)
, link						 VARCHAR2(30)
, Enabled_flag					 VARCHAR2(1)
, name						 VARCHAR2(30)
, description					 VARCHAR2(240)
);

--
-- Data Types: Tables
--
Procedure Translate_EDW_source_instances
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_src_inst_rec      IN  EDW_SOURCE_INST_PKG.src_inst_rec_type
, p_OWNER             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT VARCHAR2
);
--
Procedure Load_edw_source_instances
(
p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_src_inst_rec      IN  EDW_SOURCE_INST_PKG.src_inst_rec_type
, p_OWNER             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT VARCHAR2
);
--
END EDW_SOURCE_INST_PKG;

 

/
