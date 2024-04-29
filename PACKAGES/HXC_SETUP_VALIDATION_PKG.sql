--------------------------------------------------------
--  DDL for Package HXC_SETUP_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_SETUP_VALIDATION_PKG" AUTHID CURRENT_USER as
/* $Header: hxcotcvld.pkh 115.7 2003/04/16 20:20:44 gpaytonm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_setup_validation_pkg.';
--

-- ----------------------------------------------------------------------------
-- |------------------------< execute_otc_validation >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- This procedure is used to check that certain areas of OTC are configured
-- correctly at time entry. This is to avoid usability issues later on in the
-- system.
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--   function returns TRUE if period maximu not violated
--
-- Post Failure:
--
--   function returns FALSE if the period maximum violated
--
-- Access Status:
--   Public.
--

PROCEDURE execute_otc_validation (
		p_operation	    VARCHAR2
        ,       p_resource_id       NUMBER
	,       p_timecard_bb_id    NUMBER
        ,       p_timecard_bb_ovn   NUMBER
        ,       p_start_date        DATE
        ,       p_end_date          DATE
        ,       p_master_pref_table IN OUT NOCOPY hxc_preference_evaluation.t_pref_table
	,	p_messages	    IN OUT NOCOPY hxc_message_table_type );

end hxc_setup_validation_pkg;

 

/
