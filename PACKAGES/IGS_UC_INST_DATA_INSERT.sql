--------------------------------------------------------
--  DDL for Package IGS_UC_INST_DATA_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_INST_DATA_INSERT" AUTHID CURRENT_USER AS
/* $Header: IGSUC62S.pls 115.3 2003/07/10 07:48:56 rgangara noship $  */

  PROCEDURE proc_uvcontact_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit		  IN	  NUMBER
    );

  PROCEDURE proc_uvcontgrp (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit		  IN	  NUMBER
    );

END IGS_UC_INST_DATA_INSERT;

 

/
