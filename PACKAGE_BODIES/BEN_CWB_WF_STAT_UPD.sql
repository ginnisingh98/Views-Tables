--------------------------------------------------------
--  DDL for Package Body BEN_CWB_WF_STAT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_WF_STAT_UPD" as
/* $Header: bencwbsu.pkb 115.0 2003/05/27 10:53:52 aprabhak noship $ */
PROCEDURE woksheet_status_update
     (   p_popl_id      IN number
       , p_ws_stat_cd   IN varchar2
       , p_ws_acc_cd    IN varchar2
     )
     IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   l_ovn number;
   BEGIN
   select object_version_number into l_ovn
    from ben_pil_elctbl_chc_popl
   where pil_elctbl_chc_popl_id = p_popl_id;
   ben_pil_elctbl_chc_popl_api.update_Pil_Elctbl_chc_Popl
   (
	  p_validate                  => false
	, p_pil_elctbl_chc_popl_id    => p_popl_id
    , p_ws_stat_cd	              => p_ws_stat_cd
	, p_object_version_number     => l_ovn
	, p_effective_date            => sysdate
    , p_ws_acc_cd                 => p_ws_acc_cd
   );
   commit;
   END;
END;

/
