--------------------------------------------------------
--  DDL for Package QP_PURGE_ENTITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PURGE_ENTITY" AUTHID CURRENT_USER AS
/* $Header: QPXPURGS.pls 120.0 2005/06/02 00:00:19 appldev noship $ */

G_PKG_NAME		CONSTANT	VARCHAR2(30):='QP_PURGE_ENTITY';

PROCEDURE Purge_Entity
(
 errbuf                 OUT NOCOPY    	VARCHAR2,
 retcode                OUT NOCOPY    	NUMBER,
 p_source_system_code  	IN      	VARCHAR2,
 p_archive_name     	IN      	VARCHAR2,
 p_entity_type          IN      	VARCHAR2,
 p_entity     		IN      	NUMBER,
 p_archive_start_date	IN      	VARCHAR2,
 p_archive_end_date     IN   		VARCHAR2
);

END QP_PURGE_ENTITY;

 

/
