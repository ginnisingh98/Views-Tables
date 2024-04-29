--------------------------------------------------------
--  DDL for Package HRI_OPL_BEN_ENRLACTN_EQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_BEN_ENRLACTN_EQ" AUTHID CURRENT_USER AS
/* $Header: hrieqeea.pkh 120.0 2005/09/21 01:26:25 anmajumd noship $ */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Name	:	HRI_OPL_BEN_ENRLACTN_EQ
	Purpose	:	Populate Benefits Enrollment Action event queue
------------------------------------------------------------------------------
History
-------
Version Date       Author           Comment
-------+----------+----------------+------------------------------------------
12.0    30-JUN-05   abparekh        Initial Version
-------------------------------------------------------------------------------
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

PROCEDURE insert_event (p_rec 			 in ben_pea_shd.g_rec_type,
		        p_effective_date	 in date,
		        p_datetrack_mode	 in varchar2 );

PROCEDURE update_event (p_rec 			 in ben_pea_shd.g_rec_type,
		        p_effective_date	 in date,
		        p_datetrack_mode	 in varchar2 );

PROCEDURE delete_event (p_rec 			 in ben_pea_shd.g_rec_type,
		        p_effective_date	 in date,
		        p_datetrack_mode	 in varchar2 );


END HRI_OPL_BEN_ENRLACTN_EQ ;

 

/
