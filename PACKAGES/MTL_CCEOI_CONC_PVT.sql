--------------------------------------------------------
--  DDL for Package MTL_CCEOI_CONC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CCEOI_CONC_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVCCCS.pls 120.1 2005/06/20 02:07:22 appldev ship $ */
  --
  -- Concurrent Porgram Export
  --Added NOCOPY hint to ERRBUF,RETCODE OUT parameters to comply with
  --GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Export_CCEntriesIface(
  ERRBUF OUT NOCOPY VARCHAR2 ,
  RETCODE OUT NOCOPY VARCHAR2 ,
  P_Cycle_Count_Header_Id IN NUMBER ,
  P_Cycle_Count_Entry_ID IN NUMBER DEFAULT NULL,
  p_cc_entry_iface_group_id IN NUMBER DEFAULT NULL)
;
  --
  -- Concurrent Program Import
  --Added NOCOPY hint to ERRBUF,RETCODE OUT parameters to comply with
  --GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Import_CCEntriesIface(
  ERRBUF OUT NOCOPY VARCHAR2 ,
  RETCODE OUT NOCOPY VARCHAR2 ,
  P_Cycle_Count_Header_ID IN NUMBER DEFAULT NULL,
  P_Number_of_Worker IN NUMBER ,
  P_Commit_point IN NUMBER DEFAULT 100,
  P_ErrorReportLev IN NUMBER DEFAULT 2,
  P_DeleteProcRec IN NUMBER DEFAULT 2)
;
  --
  -- Concurrent program Purge
  --Added NOCOPY hint to ERRBUF,RETCODE OUT parameters to comply with
  --GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Purge_CCEntriesIface(
  ERRBUF OUT NOCOPY VARCHAR2 ,
  RETCODE OUT NOCOPY VARCHAR2 )
;
  --
  -- Worker for record processing
  --Added NOCOPY hint to ERRBUF,RETCODE OUT parameters to comply with
  --GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Worker_CCEntriesIface(
  ERRBUF OUT NOCOPY VARCHAR2 ,
  RETCODE OUT NOCOPY VARCHAR2 ,
  P_CC_Interface_Group_Id IN NUMBER ,
  p_commit_point IN NUMBER DEFAULT 100,
  P_ErrorReportLev IN NUMBER DEFAULT 2,
  P_DeleteProcRec IN NUMBER DEFAULT 2)
;
 PROCEDURE INV_CCEOI_SET_LOG_FILE;
END MTL_CCEOI_CONC_PVT;

 

/
