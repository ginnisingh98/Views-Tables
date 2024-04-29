--------------------------------------------------------
--  DDL for Package PQH_GSP_DEL_GRADE_LADDER_OBJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GSP_DEL_GRADE_LADDER_OBJ" AUTHID CURRENT_USER as
/* $Header: pqgspdel.pkh 115.0 2003/09/16 19:53 srajakum noship $ */
--
--
--
-- This is the main function called before copying BEN objects from staging
-- tables to actual BEN tables
-- Returns either 'SUCCESS' or 'FAILURE'
--
--
Function delete_from_ben (p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_datetrack_mode     in varchar2 default null)
RETURN varchar2;
--
-- The following functions allow deleting individual components under a txn
-- Values returned are 'SUCCESS' / 'FAILURE'
--
--
Function unlink_plan_from_pgm (p_copy_entity_txn_id in number,
                               p_effective_date     in date,
                               p_datetrack_mode     in varchar2 default null)
RETURN varchar2;
--
Function unlink_oipl_from_plan (p_copy_entity_txn_id in number,
                               p_effective_date     in date,
                               p_datetrack_mode     in varchar2 default null)
RETURN varchar2;
--
Function delete_option (p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_datetrack_mode     in varchar2 default null)
RETURN varchar2;
--
Function unlink_elig_prfl (p_copy_entity_txn_id in number,
                           p_effective_date     in date,
                           p_datetrack_mode     in varchar2 default null)
RETURN varchar2;
--
End;

 

/
