--------------------------------------------------------
--  DDL for Package OKI_BUT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_BUT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRBUTS.pls 115.8 2002/12/01 17:51:51 rpotnuru noship $ */

--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name   : OKI_BUT_PVT
-- Type       : Process
-- Purpose    : This package contains procedure and functions that are common
--              to other bins
-- Modification History
-- 04-Jan-2002  mezra         Created
-- 20-Mar-2002  mezra         Added logic to retrieve title at contract level.
-- 27-Mar-2002  mezra         Added new procedure and functions to support
--                            scaling factor
-- 04-Apr-2002  mezra         Moved dbdrv to top of file.
--                            Synched branch with mainline.
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--
--
-- Notes      :
--
-- End of comments
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
  -- Package Global to hold scaling factor
--------------------------------------------------------------------------------
  g_scaling_factor VARCHAR2(30);

--------------------------------------------------------------------------------
  -- Function that returns the refresh date

--------------------------------------------------------------------------------
  FUNCTION get_rfh_date
  (   p_name IN VARCHAR2
  ) RETURN  VARCHAR2 ;

--------------------------------------------------------------------------------
  -- Function to get the period set name based on the user's profile.

--------------------------------------------------------------------------------
  FUNCTION get_period_set
  (   p_profile_value IN VARCHAR2
  ) RETURN VARCHAR2 ;


--------------------------------------------------------------------------------
  -- Function to get the period type based on the user's profile.

--------------------------------------------------------------------------------
  FUNCTION get_period_type
  (   p_profile_value IN VARCHAR2
  ) RETURN VARCHAR2 ;



--------------------------------------------------------------------------------
  -- Function to get the default the period name based on the user's profile:
  -- period set and period type

--------------------------------------------------------------------------------
  FUNCTION get_period_name
  (   p_profile_value IN VARCHAR2
  ) RETURN VARCHAR2 ;


--------------------------------------------------------------------------------
  -- Function to get the column label for the renewal aging report

--------------------------------------------------------------------------------
  FUNCTION get_aging_label1( p_col_pos IN VARCHAR2 ) return varchar2 ;
  FUNCTION get_aging_label2( p_col_pos IN VARCHAR2 ) return varchar2 ;
  FUNCTION get_aging_label3( p_col_pos IN VARCHAR2 ) return varchar2 ;
  FUNCTION get_aging_label4( p_col_pos IN VARCHAR2 ) return varchar2 ;

--------------------------------------------------------------------------------
  -- Function that returns the either the start age age value or the end age
  -- value of the age group.
--------------------------------------------------------------------------------
  FUNCTION get_start_end_age_val
  (  p_start_end_pos IN VARCHAR2
   , p_col_pos       IN VARCHAR2
  ) RETURN VARCHAR2 ;

--------------------------------------------------------------------------------
  -- Function that returns the title for a bin.
--------------------------------------------------------------------------------
  FUNCTION get_bin_title
  (  p_grouping   IN VARCHAR2
   , p_bin_name   IN VARCHAR2
   , p_code       IN VARCHAR2
  ) RETURN VARCHAR2 ;

--------------------------------------------------------------------------------
  -- Function that returns the title for a bin at the org level.
--------------------------------------------------------------------------------
  FUNCTION get_bin_title2
  (  p_param IN VARCHAR2
  ) RETURN VARCHAR2 ;

--------------------------------------------------------------------------------
  -- Function that returns the title for a bin at the contract level.
--------------------------------------------------------------------------------
  FUNCTION get_top_n_k_title
  (  p_param IN VARCHAR2
  ) RETURN VARCHAR2 ;

--------------------------------------------------------------------------------
-- Function to return the title for the bin
--------------------------------------------------------------------------------
  FUNCTION get_title_for_bin
  (  p_param IN VARCHAR2
  ) RETURN VARCHAR2 ;

--------------------------------------------------------------------------------
-- Function to return the scaling factor
--------------------------------------------------------------------------------
  FUNCTION get_scaling_factor RETURN VARCHAR2;

--------------------------------------------------------------------------------
-- Procedure to set the scaling factor from the bin parameter
--------------------------------------------------------------------------------
  PROCEDURE set_scaling_factor(p_param IN VARCHAR2) ;

--------------------------------------------------------------------------------
  -- Function that returns the default value for the summary build date.
--------------------------------------------------------------------------------
  FUNCTION dflt_summary_build_date
  (   p_name IN VARCHAR2
  ) RETURN  VARCHAR2 ;

END oki_but_pvt ;

 

/
