--------------------------------------------------------
--  DDL for Package GHR_NFC_ERROR_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_NFC_ERROR_PROC" AUTHID CURRENT_USER As
/* $Header: ghrnfcerrext.pkh 120.1 2005/07/12 15:49:50 hgattu noship $ */


g_proc_name  Varchar2(200) :='PQP_NFC_Position_Extracts.';


-- =============================================================================
-- ~ NFC_Extract_Process: This is called by the conc. program as is a
-- ~ wrapper around the benefits conc. program Extract Process.
-- =============================================================================
PROCEDURE NFC_Error_Process
           (errbuf                        OUT NOCOPY  VARCHAR2
           ,retcode                       OUT NOCOPY  VARCHAR2
           ,p_business_group_id           IN  NUMBER
           ,p_file_type                   IN  VARCHAR2
           ,p_pos_dummy                   IN  VARCHAR2
           ,p_pa_dummy                    IN  VARCHAR2
           ,p_dummy                       IN  VARCHAR2
           ,p_request_id                  IN  NUMBER
           );
--================================================================================
---PROCEDURE chk_for_err_data_pos
--Checks for error positions and takes action accordingly
--================================================================================
PROCEDURE chk_for_err_data_pos (p_request_id     IN NUMBER
                                ,p_rslt_id        IN NUMBER
                               );
--================================================================================
---PROCEDURE chk_same_day_act
--Checks for  the action that exists on same day with either correction or
--cancellation
--================================================================================
PROCEDURE chk_same_day_act (p_request_id  IN NUMBER
                           ,p_rslt_id     IN NUMBER
                           );

---============================================================================
--PROCEDURE chk_for_err_data_pa
--Check personnel action rows that errored with temp table.
---===========================================================================
PROCEDURE chk_for_err_data_pa (p_request_id     IN NUMBER
                                ,p_rslt_id        IN NUMBER
                               );

---============================================================================
--PROCEDURE Ins_Rslt_Dt
--insert new row.
---===========================================================================
PROCEDURE Ins_Rslt_Dtl
          (p_val_tab     in out NOCOPY ben_ext_rslt_dtl%rowtype
          ,p_rslt_dtl_id out NOCOPY number
          );
END ghr_nfc_error_proc;

 

/
