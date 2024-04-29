--------------------------------------------------------
--  DDL for Package BEN_CWB_WF_STAT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_WF_STAT_UPD" AUTHID CURRENT_USER AS
/* $Header: bencwbsu.pkh 115.0 2003/05/27 10:54:23 aprabhak noship $ */
 PROCEDURE woksheet_status_update
     (   p_popl_id      IN number
       , p_ws_stat_cd   IN varchar2
       , p_ws_acc_cd    IN varchar2
     );
END;

 

/
