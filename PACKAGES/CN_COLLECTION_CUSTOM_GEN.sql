--------------------------------------------------------
--  DDL for Package CN_COLLECTION_CUSTOM_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECTION_CUSTOM_GEN" AUTHID CURRENT_USER AS
-- $Header: cncusgens.pls 120.3 2007/09/26 19:52:02 apink ship $

--
-- Procedure Name
--   insert_cn_not_trx
-- Purpose
--   This procedure generates the Notification code
-- History
--
--
  PROCEDURE insert_cn_not_trx (
     x_table_map_id         cn_table_maps.table_map_id%TYPE,
     x_event_id             cn_events.event_id%TYPE,
     code IN OUT NOCOPY            cn_utils.code_type,
	 x_org_id IN NUMBER);


--
-- Procedure Name
--   insert_comm_lines_api_select
-- Purpose
--   This procedure uses the Direct Column Mappings to
--   generate the 'INSERT INTO cn_comm_lines_api VALUES (...) SELECT ...'
--   portion of the SQL statement wich populates the api table
--
-- History
--   03-17-00   Dave Maskell    Created for Release 11i2.
--
--

PROCEDURE insert_comm_lines_api_select(
           	x_table_map_id   IN     cn_table_maps_v.table_map_id%TYPE,
	      	code             IN OUT NOCOPY cn_utils.code_type,
	 	   x_org_id IN NUMBER,
		   x_parallel_hint  IN VARCHAR2);
--
-- Procedure Name
--   insert_comm_lines_api
-- Purpose
--   This procedure inserts into the CN_COMM_LINES_API table
-- History
--
--
  PROCEDURE insert_comm_lines_api (
	x_table_map_id		cn_table_maps.table_map_id%TYPE,
     x_event_id          cn_events.event_id%TYPE,
	code	IN OUT NOCOPY 	cn_utils.code_type,
	 x_org_id IN NUMBER);

----------------------------------------------------------+
-- Procedure Name
--   update_comm_lines_api
--
-- Purpose
--   Generates code to update the CN_COMM_LINES_API table
--   using Indirect Mappings
-- History
-- 16-Mar-00       Dave Maskell          Created
--
  PROCEDURE update_comm_lines_api (
     x_table_map_id      cn_table_maps.table_map_id%TYPE,
     code IN OUT NOCOPY         cn_utils.code_type,
	 x_org_id IN NUMBER);
----------------------------------------------------------+
-- Procedure Name
--   filter_comm_lines_api
--
-- Purpose
--   Generates code to filter the CN_COMM_LINES_API table
-- History
-- 29-Mar-00       Dave Maskell          Created
--

  PROCEDURE filter_comm_lines_api (
     x_table_map_id      cn_table_maps.table_map_id%TYPE,
     code IN OUT NOCOPY         cn_utils.code_type,
	 x_org_id IN NUMBER);

--
-- Procedure Name
--   Generate_user_code
-- Purpose
--   Gets user-specificed code for a particular location and generates that code
-- History
--   04-03-00	     Dave Maskell     Created
--

  PROCEDURE Generate_User_Code(
                 p_table_map_id  IN NUMBER,
			  p_location_name IN VARCHAR2,
                 code            IN OUT NOCOPY cn_utils.code_type,
	 x_org_id IN NUMBER);

END cn_collection_custom_gen;

/
