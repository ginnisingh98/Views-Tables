--------------------------------------------------------
--  DDL for Package AK_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_SECURITY_PUB" AUTHID CURRENT_USER as
/* $Header: akdpsecs.pls 115.4 2002/01/17 12:31:22 pkm ship      $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_SECURITY_PUB';

-- Type definitions

TYPE Resp_PK_Rec_Type IS RECORD (
  responsibility_id      NUMBER:= NULL,
  responsibility_appl_id NUMBER:= NULL,
  attribute_appl_id      NUMBER := NULL,
  attribute_code         VARCHAR2(30) := NULL
);


TYPE Resp_PK_Tbl_Type IS TABLE OF Resp_PK_Rec_Type
	INDEX BY BINARY_INTEGER;

TYPE Excluded_Tbl_Type IS TABLE OF ak_excluded_items%ROWTYPE
    INDEX BY BINARY_INTEGER;

TYPE Resp_Sec_Tbl_Type IS TABLE OF ak_resp_security_attributes%ROWTYPE
    INDEX BY BINARY_INTEGER;

/* Constants for missing data types */
G_MISS_RESP_PK_TBL       Resp_PK_Tbl_Type;

end AK_SECURITY_PUB;

 

/
