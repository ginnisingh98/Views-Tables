--------------------------------------------------------
--  DDL for Package PER_JP_REPORT_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JP_REPORT_COMMON_PKG" AUTHID CURRENT_USER
-- $Header: pejpcmrp.pkh 120.0.12010000.3 2009/06/08 14:32:48 spattem noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- *  pejpcmrp.pkh
-- *
-- * DESCRIPTION
-- * This script creates the package header of per_jp_report_common_pkg.
-- *
-- * DEPENDENCIES
-- *   None
-- *
-- * CALLED BY
-- *   Concurrent Program
-- *
-- * LAST UPDATE DATE   08-JUN-2009
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * DATE        AUTHOR(S)  VERSION           BUG NO     DESCRIPTION
-- * -----------+---------+-----------------+----------+----------------------------
-- * 26-MAY-2009 SPATTEM    120.0.12010000.1  8558615    Creation
-- * 08-JUN-2009 SPATTEM    120.0.12010000.2  8558615    Changes done as per review Comments
-- *************************************************************************
AS
--
TYPE gt_org_tbl IS TABLE of NUMBER INDEX BY binary_integer;
--
FUNCTION get_org_hirerachy(p_business_group_id     IN per_assignments_f.business_group_id%TYPE
                          ,p_organization_id       IN per_assignments_f.organization_id%TYPE
                          ,p_include_org_hierarchy IN VARCHAR2
                          )
RETURN gt_org_tbl;
--
END per_jp_report_common_pkg;

/
