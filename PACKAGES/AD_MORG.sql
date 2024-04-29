--------------------------------------------------------
--  DDL for Package AD_MORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_MORG" AUTHID CURRENT_USER as
/* $Header: admorgs.pls 120.2.12010000.3 2013/02/20 09:21:17 rahulshr ship $ */
--
-- Declare table for Multi-Org table list
--
type TableNameType is table of varchar2(30)
  index by binary_integer;

type FlagValueType is table of varchar2(1)
  index by binary_integer;

table_list      TableNameType;
view_list       TableNameType;
appl_list       TableNameType;
seed_data       TableNameType;
conv_method     FlagValueType;
owner_list      TableNameType;

--
-- Procedure
--   load_table_list
--
-- Purpose
--   Loads the hard-coded list of partitioned tables into PL/SQL tables.
--   These PL/SQL tables should replace AK_PARTITIONED_TABLES in 10.7.
--
-- Arguments
--   X_load_table_stats   indicates whether the tables' row count should
--                        be used to determine the conversion method
--                        (default Y)
--
-- Example
--   none
--
procedure load_table_list(x_load_table_stats in varchar2);


procedure load_table_list;

--
-- Procedure
--   replicate_table_data
--
-- Purpose
--   Perform seed data replication from the template to the specified
--   org for the specified table
--
-- Arguments
--   X_table_name       Name of table
--   X_source_org_id    org_id of the source organization_id
--   X_target_org_id    org_id of the target organization_id
--
-- Example
--   none
--
-- Notes
--   1. Templates for partitioned seed data have a source org_id of -3113.
--   2. Templates for shared seed data have a source org_id of -3114.
--   3. Custom data have a source org_id of NULL.
--
procedure replicate_table_data
           (X_table_name in varchar2,
            X_source_org_id in number,
            X_target_org_id in number);

--
-- Procedure
--   replicate_table_data_bulk
--
-- Purpose
--   Perform seed data replication from the template to
--   a group of orgs for the specified table
--
--   This procedure was adapted from replicate_table_data()
--
--   This was written to improve performance as described
--   in bug 5409325.
--
--   Instead of calling replicate_table_data() for each
--   value fetched from the cursor, the cursor is combined
--   with the dynamic INSERT statement to process all orgs
--   in one shot per table.
--
-- Arguments
--   X_table_name       Name of table
--   X_source_org_id    org_id of the source organization_id
--
-- Example
--   none
--
-- Notes
--   1. Templates for partitioned seed data have a source org_id of -3113.
--   2. Templates for shared seed data have a source org_id of -3114.
--   3. Custom data have a source org_id of NULL.
--
procedure replicate_table_data_bulk
           (X_table_name in varchar2,
            X_source_org_id in number);

--
-- Procedure
--   replicate_seed_data
--
-- Purpose
--   Perform seed data replication from the template to the specified
--   org or all orgs for the specified table or all tables from one
--   product or all tables
--
-- Arguments
--   X_org_id           org_id of the target organization_id (NULL if all)
--   X_appl_short_name  application (NULL if all)
--   X_table_name       Name of table (NULL if all)
--
-- Example
--   none
--
-- Notes
--   none
--
procedure replicate_seed_data
           (X_org_id          in number,
            X_appl_short_name in varchar2,
            X_table_name      in varchar2);

procedure get_next_table
           (X_number      in out nocopy number,
            X_table_name  out    nocopy varchar2,
            X_conv_method out    nocopy varchar2);

procedure initialize(X_number out nocopy number);

procedure verify_seed_data
           (X_appl_short_name IN varchar2,
            X_table           IN varchar2,
            X_debug_level     IN number default 1);

procedure update_book_id
            (X_org_id          in number,
             X_table_name      in varchar2);

end ad_morg;

/
