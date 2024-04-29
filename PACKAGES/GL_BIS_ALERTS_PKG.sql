--------------------------------------------------------
--  DDL for Package GL_BIS_ALERTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BIS_ALERTS_PKG" AUTHID CURRENT_USER as
/* $Header: glubisas.pls 120.2 2005/05/05 01:36:24 kvora ship $ */

--
-- Package
--   GL_BIS_ALERTS_PKG
-- Purpose
--   To create GL_BIS_ALERTS_PKG package.
-- History
--   28-MAY-99         K Vora           Created
--

  TYPE Target_Info_Rec_Type IS RECORD
    (target_id               BISBV_TARGETS.target_id%TYPE,
     plan_id                 BISBV_BUSINESS_PLANS.plan_id%TYPE,
     plan_name               BISBV_BUSINESS_PLANS.name%TYPE,
     org_level_value_id      BISBV_TARGETS.org_level_value_id%TYPE,
     sob_name                GL_SETS_OF_BOOKS.name%TYPE,
     chart_of_accounts_id    GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE,
     time_level_value_id     BISBV_TARGETS.time_level_value_id%TYPE,
     dim1_level_value_id     BISBV_TARGETS.dim1_level_value_id%TYPE,
     dim2_level_value_id     BISBV_TARGETS.dim2_level_value_id%TYPE,
     range1_low              BISBV_TARGETS.range1_low%TYPE,
     range1_high             BISBV_TARGETS.range1_high%TYPE,
     range2_low              BISBV_TARGETS.range2_low%TYPE,
     range2_high             BISBV_TARGETS.range2_high%TYPE,
     range3_low              BISBV_TARGETS.range3_low%TYPE,
     range3_high             BISBV_TARGETS.range3_high%TYPE,
     notify_resp1_id         BISBV_TARGETS.notify_resp1_id%TYPE,
     notify_resp1_short_name BISBV_TARGETS.notify_resp1_short_name%TYPE,
     notify_resp2_id         BISBV_TARGETS.notify_resp2_id%TYPE,
     notify_resp2_short_name BISBV_TARGETS.notify_resp2_short_name%TYPE,
     notify_resp3_id         BISBV_TARGETS.notify_resp3_id%TYPE,
     notify_resp3_short_name BISBV_TARGETS.notify_resp3_short_name%TYPE,
     dim1_segnum             FND_ID_FLEX_SEGMENTS.segment_num%TYPE,
     dim2_segnum             FND_ID_FLEX_SEGMENTS.segment_num%TYPE);

  --
  -- Procedure
  --   check_revenue
  -- Purpose
  --   Compares actual revenue versus planned revenue amounts
  --   and sends notifications.
  -- History
  --   28-MAY-1999  K Vora       Created
  -- Arguments
  --   p_period_id		Period set name + Period name
  -- Example
  --   gl_bis_alerts_pkg.check_revenue( 'Accounting+JAN-99');
  --

  PROCEDURE check_revenue(p_period_id    IN VARCHAR2);

  --
  -- Function
  --   set_performance_measures
  -- Purpose
  --   Set values for performance measures monitored on personal home page
  -- History
  --   01-JUL-1999  K Vora       Created
  -- Arguments
  --   p_sob_id                 Set of books id
  --   p_mapped_segnum1         Segment number of segment mapped to GL COMPANY
  --   p_mapped_segnum2         Segment number of segment mapped to GL SECONDARY MEASURE
  -- Returns
  --   TRUE  - Performance Measure value was updated correctly
  --   FALSE - Performance Measure value was not set
  -- Example
  --   ret_value := gl_bis_alerts_pkg.check_revenue( 1491, 1, 2);
  --

  FUNCTION set_performance_measures(p_sob_id           IN NUMBER,
                                    p_mapped_segnum1   IN NUMBER,
                                    p_mapped_segnum2   IN NUMBER)
           RETURN BOOLEAN;

  --
  -- Function
  --   get_ctarget
  -- Purpose
  --   Dummy function. Always returns -1.
  -- History
  --   28-MAY-1999  K Vora       Created
  -- Arguments
  --   p_target_rec             Target information
  -- Example
  --   gl_bis_alerts_pkg.get_ctarget(p_target_rec => l_target_rec);
  --

  FUNCTION get_ctarget(
           p_target_rec   IN BIS_TARGET_PUB.Target_Rec_Type)
           RETURN NUMBER;


END GL_BIS_ALERTS_PKG;

 

/
