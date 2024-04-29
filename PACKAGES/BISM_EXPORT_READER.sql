--------------------------------------------------------
--  DDL for Package BISM_EXPORT_READER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BISM_EXPORT_READER" AUTHID CURRENT_USER AS
/* $Header: bibexps.pls 120.2 2006/04/03 05:22:29 akbansal noship $ */
TYPE SchemaCurType IS REF CURSOR;
PROCEDURE delete_objects(a_timeinsecs integer);
PROCEDURE delete_object(a_gname raw,a_guid raw,a_filename nvarchar2);
FUNCTION get_object(a_gname in raw,a_guid in out nocopy raw, a_filename in nvarchar2) RETURN SchemaCurType;
END;

 

/
