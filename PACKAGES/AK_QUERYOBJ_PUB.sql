--------------------------------------------------------
--  DDL for Package AK_QUERYOBJ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_QUERYOBJ_PUB" AUTHID CURRENT_USER as
/* $Header: akdpqrys.pls 115.1 2002/01/17 12:31:21 pkm ship      $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_QUERYOBJ_PUB';

-- Type definitions

TYPE queryobj_pk_rec_type is RECORD (
	query_code			varchar2(30) := NULL
);

TYPE queryobj_lines_pk_Rec_Type IS RECORD (
  query_code			VARCHAR2(30) := NULL,
  seq_num				NUMBER := NULL
);

TYPE queryobj_pk_tbl_type IS TABLE OF queryobj_pk_rec_type INDEX BY BINARY_INTEGER;

TYPE queryobj_lines_pk_Tbl_Type IS TABLE OF queryobj_lines_pk_Rec_Type
	INDEX BY BINARY_INTEGER;

TYPE queryobj_Tbl_Type IS TABLE OF ak_query_objects%ROWTYPE
    INDEX BY BINARY_INTEGER;

TYPE queryobj_lines_Tbl_Type IS TABLE OF ak_query_object_lines%ROWTYPE
    INDEX BY BINARY_INTEGER;

/* Constants for missing data types */
G_MISS_QUERYOBJ_REC				ak_query_objects%ROWTYPE;
G_MISS_QUERYOBJ_LINE_REC		ak_query_object_lines%ROWTYPE;
G_MISS_QUERYOBJ_PK_TBL			queryobj_pk_tbl_type;
G_MISS_QUERYOBJ_TBL				queryobj_tbl_type;
G_MISS_QUERYOBJ_LINES_TBL       queryobj_lines_Tbl_Type;

end AK_QUERYOBJ_PUB;

 

/
