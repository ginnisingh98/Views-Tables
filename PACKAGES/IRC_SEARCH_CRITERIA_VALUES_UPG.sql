--------------------------------------------------------
--  DDL for Package IRC_SEARCH_CRITERIA_VALUES_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_SEARCH_CRITERIA_VALUES_UPG" AUTHID CURRENT_USER AS
/* $Header: irscvupg.pkh 120.0 2005/10/19 18:48 gjaggava noship $ */

-- ----------------------------------------------------------------------------
-- |------------------------< update_criteria_values>-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description : This package declares functions used in upgrade
--               to multiple search criteria values model for
--               derived location and professional area fields.
--
--
procedure update_criteria_values(
  p_process_ctrl             IN           varchar2,
  p_start_pkid               IN           number,
  p_end_pkid                 IN           number,
  p_rows_processed           OUT nocopy   number);
--
end irc_search_criteria_values_upg;

 

/
