--------------------------------------------------------
--  DDL for Package IEX_LOAD_FILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_LOAD_FILE_PVT" AUTHID CURRENT_USER AS
/* $Header: iexvfils.pls 120.0 2004/01/24 03:26:03 appldev noship $ */


Procedure UPDATE_AMV_ATTACH1
           (p_file_id             IN NUMBER DEFAULT NULL );

Procedure UPDATE_AMV_ATTACH2
           (p_file_id             IN NUMBER DEFAULT NULL );

Procedure UPDATE_AMV_ATTACH3
           (p_file_id             IN NUMBER DEFAULT NULL );

Procedure UPDATE_AMV_ATTACH4
           (p_file_id             IN NUMBER DEFAULT NULL );

Procedure UPDATE_AMV_ATTACH5
           (p_file_id             IN NUMBER DEFAULT NULL );

Procedure UPDATE_FILE_NAME
           (p_file_id             IN NUMBER );

END IEX_LOAD_FILE_PVT;

 

/
