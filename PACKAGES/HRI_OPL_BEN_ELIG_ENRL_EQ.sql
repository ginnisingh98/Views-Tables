--------------------------------------------------------
--  DDL for Package HRI_OPL_BEN_ELIG_ENRL_EQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_BEN_ELIG_ENRL_EQ" AUTHID CURRENT_USER AS
/* $Header: hrieqeec.pkh 120.0 2005/09/21 01:26:48 anmajumd noship $ */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Name	:	HRI_OPL_BEN_ELIG_ENRL_EQ
	Purpose	:	Populate Benefits Eligbility and Enrollment event queue
------------------------------------------------------------------------------
History
-------
Version Date       Author           Comment
-------+----------+----------------+------------------------------------------
12.0    30-JUN-05   nhunur          Initial Version
-------------------------------------------------------------------------------
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

PROCEDURE insert_event (p_rec 			 in ben_pen_shd.g_rec_type,
		        p_effective_date	 in date,
		        p_datetrack_mode	 in varchar2 );

PROCEDURE update_event (p_rec 			 in ben_pen_shd.g_rec_type,
		        p_effective_date	 in date,
		        p_datetrack_mode	 in varchar2 );

PROCEDURE delete_event (p_rec 			 in ben_pen_shd.g_rec_type,
		        p_effective_date	 in date,
		        p_datetrack_mode	 in varchar2 );

function get_plip_id (p_pl_id in number ,
                      p_pgm_id in number,
		      p_effective_date in date ) return number ;
function get_lf_evt_dt(p_per_in_ler_id in number ) return date;

END HRI_OPL_BEN_ELIG_ENRL_EQ;

 

/
