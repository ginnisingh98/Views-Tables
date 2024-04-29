--------------------------------------------------------
--  DDL for Package HRI_OPL_BEN_ELCTN_EVNTS_EQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_BEN_ELCTN_EVNTS_EQ" AUTHID CURRENT_USER AS
/* $Header: hrieqele.pkh 120.0 2005/09/21 01:27:09 anmajumd noship $ */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Name	:	HRI_OPL_BEN_ELCTN_EVNTS_EQ
	Purpose	:	Populate Benefits Election events queue
------------------------------------------------------------------------------
History
-------
Version Date       Author           Comment
-------+----------+----------------+------------------------------------------
12.0    30-JUN-05   nhunur          Initial Version
-------------------------------------------------------------------------------
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

PROCEDURE insert_event (p_rec 			 in ben_pel_shd.g_rec_type,
                        p_pil_rec 		 in ben_pil_shd.g_rec_type,
                        p_called_from            in varchar2,
		        p_effective_date	 in date,
		        p_datetrack_mode	 in varchar2 );

PROCEDURE update_event (p_rec 			 in ben_pel_shd.g_rec_type,
                        p_pil_rec 		 in ben_pil_shd.g_rec_type,
                        p_called_from            in varchar2,
                        p_effective_date	 in date,
		        p_datetrack_mode	 in varchar2 );

PROCEDURE delete_event (p_rec 			 in ben_pel_shd.g_rec_type,
		        p_effective_date	 in date,
		        p_datetrack_mode	 in varchar2 );


END HRI_OPL_BEN_ELCTN_EVNTS_EQ;

 

/
