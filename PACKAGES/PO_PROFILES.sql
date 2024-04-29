--------------------------------------------------------
--  DDL for Package PO_PROFILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PROFILES" AUTHID CURRENT_USER AS
-- $Header: PO_PROFILES.pls 120.0 2005/06/01 15:09:20 appldev noship $

------------------------------------------------------------------
------------------------------------------------------------------
-- Seeded PO Profile constants
------------------------------------------------------------------
------------------------------------------------------------------
PO_CHECK_OPEN_PERIODS CONSTANT VARCHAR2(30) := 'PO_CHECK_OPEN_PERIODS';
PO_VMI_DISPLAY_WARNING CONSTANT VARCHAR2(30) := 'PO_VMI_DISPLAY_WARNING';

END PO_PROFILES;

 

/
