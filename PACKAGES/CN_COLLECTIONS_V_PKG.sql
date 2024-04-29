--------------------------------------------------------
--  DDL for Package CN_COLLECTIONS_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECTIONS_V_PKG" AUTHID CURRENT_USER AS
-- $Header: cncocvs.pls 120.1 2005/09/03 03:12:00 apink noship $

-- Procedure Name
--   insert_row

  PROCEDURE insert_row (
                        X_module_id NUMBER,
                        X_rep_id NUMBER,
                        X_set_of_books NUMBER,
                        X_source_id NUMBER,
                        X_version VARCHAR2,
                        X_schema  VARCHAR2,
                        X_status  VARCHAR2,
                        X_description VARCHAR2,
                        X_type    VARCHAR2,
						x_org_id IN NUMBER);

  --+
  -- Procedure Name
  --   insert_collection
  -- Purpose
  --   Insert a collection without creating a new repository to collect into
  -- History
  --                    Tony Lower              Created

  PROCEDURE insert_collection (
                        X_module_id NUMBER,
                        X_rep_id NUMBER,
                        X_event_id NUMBER,
                        X_module_type VARCHAR2,
                        X_set_of_books NUMBER,
                        X_source_id NUMBER,
                        X_version VARCHAR2,
                        X_schema  VARCHAR2,
                        X_status  VARCHAR2,
                        X_description VARCHAR2,
                        X_type    VARCHAR2,
						x_org_id IN NUMBER);

  --+
  -- Procedure Name
  --   update_row
  --+

  PROCEDURE update_row(
                        X_module_id NUMBER,
                        X_rep_id NUMBER,
                        X_event_id NUMBER,
                        X_module_type VARCHAR2,
                        X_set_of_books NUMBER,
                        X_source_id NUMBER,
                        X_version VARCHAR2,
                        X_schema  VARCHAR2,
                        X_status  VARCHAR2,
                        X_type    VARCHAR2,
						x_org_id IN NUMBER,
						x_object_Version_number IN OUT NOCOPY NUMBER);

  --+
  -- Procedure Name
  --   lock_row
  --+

  PROCEDURE lock_row (x_module_id  NUMBER);

  --+
  -- Procedure Name
  --   update_collect_flag
  --+

  PROCEDURE update_collect_flag (x_module_id      NUMBER,
                                 x_collect_flag   VARCHAR2,
 		 						 x_org_id IN NUMBER);

END cn_collections_v_pkg;

 

/
