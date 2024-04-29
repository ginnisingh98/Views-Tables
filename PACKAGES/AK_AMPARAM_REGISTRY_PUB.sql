--------------------------------------------------------
--  DDL for Package AK_AMPARAM_REGISTRY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_AMPARAM_REGISTRY_PUB" AUTHID CURRENT_USER as
/* $Header: akdpaprs.pls 115.3 2002/09/27 17:54:17 tshort noship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_AMPARAM_REGISTRY_PUB';

-- Type definitions

TYPE amparamreg_pk_rec_type is RECORD (
APPLICATIONMODULE_DEFN_NAME			varchar2(240) := NULL
);

TYPE amparamreg_pk_tbl_type IS TABLE OF amparamreg_pk_rec_type INDEX BY BINARY_INTEGER;

TYPE amparamreg_Tbl_Type IS TABLE OF ak_am_parameter_registry%ROWTYPE
INDEX BY BINARY_INTEGER;

/* Constants for missing data types */
G_MISS_AMPARAMREG_REC				ak_am_parameter_registry%ROWTYPE;
G_MISS_AMPARAMREG_PK_TBL			amparamreg_pk_tbl_type;
G_MISS_AMPARAMREG_TBL				amparamreg_Tbl_Type;

end AK_AMPARAM_REGISTRY_PUB;

 

/
