--------------------------------------------------------
--  DDL for Package ZX_MIGRATE_TAX_PROFILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_MIGRATE_TAX_PROFILES" AUTHID CURRENT_USER AS
/* $Header: zxtaxprofilemigs.pls 120.0.12010000.2 2008/11/12 12:52:04 spasala ship $ */

PROCEDURE migrate_tax_profile_values;

PROCEDURE end_date_tax_profiles (p_mig_phase   VARCHAR2);

END zx_migrate_tax_profiles;

/
