--------------------------------------------------------
--  DDL for Package CZ_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_API_PUB" AUTHID CURRENT_USER AS
/*	$Header: czapis.pls 120.0 2005/05/25 05:29:48 appldev noship $		*/

--- publication mode
G_PRODUCTION_PUB_MODE	CONSTANT VARCHAR2(1) := 'P';
G_TEST_PUB_MODE		CONSTANT VARCHAR2(1) := 'T';

--- publication usage
G_ANY_USAGE_NAME		CONSTANT VARCHAR2(20) := 'Any Usage';


--- config tree copy mode
--- Creates a new config header and copies all config items
--- (save_config_behavior = "new_config")
--- Used in re-order case
G_NEW_HEADER_COPY_MODE	CONSTANT VARCHAR2(1) := 'H';


-- Creates a new revision and copies all config items
-- (save_config_behavior = "new_revision")
-- Used for reconfiguring or repricing process
G_NEW_REVISION_COPY_MODE	CONSTANT VARCHAR2(1) := 'R';


-- validation context
--   Always checks pending IB instances first, looks at the installed only if not found
--   in pending look up.
G_PENDING_OR_INSTALLED	CONSTANT VARCHAR2(1) := 'P';

--   Only uses installed IB instances
G_INSTALLED           CONSTANT VARCHAR2(1) := 'I';

---- validation types for CZ_CF_API.VALIDATE
VALIDATE_ORDER        CONSTANT VARCHAR2(1) := 'O';
VALIDATE_FULFILLMENT  CONSTANT VARCHAR2(1) := 'F';
VALIDATE_RETURN       CONSTANT VARCHAR2(1) := 'R';
INTERACTIVE		    CONSTANT VARCHAR2(1) := 'I';

------number tbl declaration
-----TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE number_tbl_type IS TABLE OF NUMBER;

----varchar tbl declaration
TYPE varchar_tbl_type IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

-- publication applicability parameters
--   config_creation_date (optional)
--   config_model_lookup_date (optional)
--   config_effective_date (optional)
--   calling_application_id (required)
--   usage_name (optional): if usage_name is not supplied: the value of profile option 'CZ_PUBLICATION_USAGE'
--   will be used if it is set; G_ANY_USAGE_NAME will be used otherwise.
--   publication_mode (optional): if publication_mode is not provided: the value of profile option
--   'CZ_PUBLICATION_MODE' will be used if it is set; G_PRODUCTION_PUB_MODE will be used otherwise.
--   language (optional): default value is session language

TYPE appl_param_rec_type IS RECORD
(
  config_creation_date     DATE,
  config_model_lookup_date DATE,
  config_effective_date    DATE,
  calling_application_id   NUMBER,
  usage_name               VARCHAR2(255),
  publication_mode         VARCHAR2(1),
  language                 VARCHAR2(4)
);

-- config header record
TYPE config_rec_type IS RECORD
(
  config_hdr_id   cz_config_hdrs.config_hdr_id%TYPE,
  config_rev_nbr  cz_config_hdrs.config_rev_nbr%TYPE
);
TYPE config_tbl_type IS TABLE OF config_rec_type INDEX BY BINARY_INTEGER;


-- used for outputing in generate_config_trees and add_to_config_tree procedures
TYPE config_model_rec_type IS RECORD
(
  inventory_item_id  NUMBER,
  organization_id    NUMBER,
  config_hdr_id      NUMBER,
  config_rev_nbr     NUMBER,
  config_item_id     NUMBER
);
TYPE config_model_tbl_type IS TABLE OF config_model_rec_type INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------
END cz_api_pub ;

 

/
