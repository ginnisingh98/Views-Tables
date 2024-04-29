--------------------------------------------------------
--  DDL for Package GHR_SESSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_SESSION" AUTHID CURRENT_USER as
/* $Header: ghstsess.pkh 120.0.12010000.3 2009/05/26 12:10:24 utokachi noship $ */
--
-- Package Variables
--
-- ----------------------------------------------------------------------------
-- |-----------------------< set_session_var_for_core  >------------------------|
-- ----------------------------------------------------------------------------
---- Make sure that there is an entry in the fnd_sessions table for the current session

 Procedure set_session_var_for_core
 (p_effective_date   in date
 );

 end ghr_session;

/
