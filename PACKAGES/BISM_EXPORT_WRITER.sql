--------------------------------------------------------
--  DDL for Package BISM_EXPORT_WRITER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BISM_EXPORT_WRITER" AUTHID CURRENT_USER AS
/* $Header: bibexpws.pls 120.2 2006/04/03 05:23:34 akbansal noship $ */
TYPE SchemaCurType IS REF CURSOR;
FUNCTION get_guid RETURN RAW;
PROCEDURE delete_objects(a_timeinsecs integer);
FUNCTION insert_object(a_gname raw,a_guid raw, a_filename nvarchar2, a_data nclob, a_binary_data blob)
RETURN timestamp;
PROCEDURE delete_object(a_gname raw,a_guid raw, a_filename nvarchar2);
FUNCTION get_object(a_gname in raw,a_guid in out nocopy raw, a_filename in nvarchar2) RETURN SchemaCurType;
END;

 

/
