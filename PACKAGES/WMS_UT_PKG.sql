--------------------------------------------------------
--  DDL for Package WMS_UT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_UT_PKG" AUTHID CURRENT_USER AS
/* $Header: WMSUTTSS.pls 120.2.12010000.1 2008/07/28 18:37:42 appldev ship $ */

g_use   BOOLEAN;
TYPE numtabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE datetabtype IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE chartabtype30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE chartabtype3 IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
TYPE chartabtype10 IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
TYPE chartabtype80 IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE chartabtype150 IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE arrchartabtype150 IS TABLE OF chartabtype150 INDEX BY BINARY_INTEGER;
TYPE dblarrchartabtype150 IS TABLE OF arrchartabtype150 INDEX BY BINARY_INTEGER;
TYPE charchartabtype30 IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);

g_params charchartabtype30;

TYPE g_ut_rsv_rec is RECORD (
  serial_number     CHARTABTYPE30
, primary_quantity     NUMTABTYPE
, secondary_quantity     NUMTABTYPE
, lot_number        CHARTABTYPE80
, subinventory_code        CHARTABTYPE10
, locator_id        NUMTABTYPE
, lpn_id   NUMTABTYPE);


TYPE g_mmtt_rec_type is RECORD (
  from_organization_id   NUMTABTYPE
, serial_number     CHARTABTYPE30
, transaction_quantity     NUMTABTYPE
, primary_quantity     NUMTABTYPE
, secondary_quantity     NUMTABTYPE
, lot_number        CHARTABTYPE80
, lot_expiration_date        DATETABTYPE
, from_subinventory_code        CHARTABTYPE10
, from_locator_id        NUMTABTYPE
, rule_id        NUMTABTYPE
, reservation_id        NUMTABTYPE
, to_subinventory_code        CHARTABTYPE10
, to_locator_id        NUMTABTYPE
, to_organization_id   NUMTABTYPE
, from_cost_group_id   NUMTABTYPE
, to_cost_group_id   NUMTABTYPE
, lpn_id   NUMTABTYPE
, grade_code   CHARTABTYPE150
);

-- Flow Type
  g_ft_rule_alloc    VARCHAR2(3)  := 10;
  g_ft_inbound       VARCHAR2(3)  := 2;

-- Flows
  g_flow_pick_rel    VARCHAR2(3)  := 'PR';
  g_flow_sugg_rsv    VARCHAR2(3)  := 'SR';
  g_flow_create_sugg VARCHAR2(3)  := 'CS';

-- Actions
  g_refresh_onhand_picture  VARCHAR2(30) := 'REFRESH_ONHAND';
  g_clear_lpns VARCHAR2(30) := 'CLEAR_LPNS';

g_lotser_cnt    NUMBER := 0;

TYPE g_datamaskrec is RECORD (
   dtype    VARCHAR2(30),
   dmask    VARCHAR2(150));

TYPE g_datamasktbl is TABLE of g_datamaskrec INDEX BY BINARY_INTEGER;

  g_data_masks     g_datamasktbl;

TYPE g_flow_rec is RECORD (
   flowtype    VARCHAR2(30),
   datatype    numtabtype);

TYPE g_flow_tbl is TABLE of g_flow_rec INDEX BY BINARY_INTEGER;

g_flow_type_datatypes  g_flow_tbl;

g_start_time    DATE;
g_end_time      DATE;

PROCEDURE indt;

PROCEDURE initialize;

PROCEDURE import_test_cases(p_txt   chartabtype150,
                      p_overwrite   VARCHAR2);

PROCEDURE import_test_cases (p_file    IN   VARCHAR2,
                             p_path    IN   VARCHAR2,
                             p_overwrite IN VARCHAR2);

FUNCTION get_flow_mask(p_mask IN varchar2, p_flow  IN number) RETURN VARCHAR2;
FUNCTION get_mask(p_mask IN varchar2) RETURN VARCHAR2;
-- Call to create temp table
PROCEDURE Create_ut_tables
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2,
   p_commit                     IN      VARCHAR2,
   x_return_status              OUT     NOCOPY VARCHAR2,
   x_msg_count                  OUT     NOCOPY NUMBER,
   x_msg_data                   OUT     NOCOPY VARCHAR2);

 PROCEDURE Create_ut_seq
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2,
   p_commit                     IN      VARCHAR2,
   x_return_status              OUT     NOCOPY VARCHAR2,
   x_msg_count                  OUT     NOCOPY NUMBER,
   x_msg_data                   OUT     NOCOPY VARCHAR2);

PROCEDURE create_wms_ut123_pkg;
PROCEDURE drop_ut_tables;
PROCEDURE drop_ut_seq;
PROCEDURE drop_ut_pkg;

PROCEDURE Create_ut_datatypes
  (p_flow_type_id               IN      NUMBER,
   p_testset_id                 IN      NUMBER,
   p_testset                    IN      VARCHAR2,
   p_test_id                    IN      NUMBER,
   p_testname                   IN      VARCHAR2,
   p_runid                      IN      NUMBER,
   x_return_status              OUT     NOCOPY VARCHAR2,
   x_msg_count                  OUT     NOCOPY NUMBER,
   x_msg_data                   OUT     NOCOPY VARCHAR2);

   Function get_datatype_id(p_datatype   VARCHAR2) Return NUMBER;
   Function get_value(p_data   IN   dblarrchartabtype150,  p_datatype   VARCHAR2) Return VARCHAR2;
   PROCEDURE gather_and_setup(p_data  IN OUT NOCOPY     dblarrchartabtype150,
                              p_org_id    IN     NUMBER,
                              p_user_id   IN     NUMBER,
                              p_flow_type_id IN     NUMBER,
                           p_run_id    IN     NUMBER,
                           p_test_id    IN     NUMBER);
   PROCEDURE execute_ut_test_flow(p_data  IN OUT NOCOPY     dblarrchartabtype150,
                              p_org_id    IN     NUMBER,
                              p_user_id   IN     NUMBER,
                           p_flow_type_id IN     NUMBER,
                           p_run_id    IN     NUMBER,
                           p_test_id    IN     NUMBER);
   PROCEDURE write_to_output(p_test_id NUMBER, p_datatype    VARCHAR2, p_text     VARCHAR2, p_runid    VARCHAR2);
   PROCEDURE write_ut_test_output(p_data  IN OUT NOCOPY     dblarrchartabtype150,
                              p_org_id    IN     NUMBER,
                              p_user_id   IN     NUMBER,
                              p_flow_type_id IN     NUMBER,
                               p_testset_id  IN       NUMBER,
                               p_test_id  IN       NUMBER,
                               p_run_id   IN       NUMBER,
                               p_file_name IN     VARCHAR2,
                            p_log_dir   IN     VARCHAR2) ;
   FUNCTION parse_text(p_text VARCHAR2, p_separation VARCHAR2)
Return chartabtype150;
Procedure print_debug(p_msg     VARCHAR2);

END wms_ut_pkg;

/
