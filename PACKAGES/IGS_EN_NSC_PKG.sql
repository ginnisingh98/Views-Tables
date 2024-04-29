--------------------------------------------------------
--  DDL for Package IGS_EN_NSC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_NSC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEN87S.pls 120.0 2005/06/01 15:28:29 appldev noship $ */


/*
 This is the main procedure which creates the snapshots
 and stores it in the EDS. Also it submits the concurrent
 process which prints the data into the text file.
*/

PROCEDURE Create_Snapshot_Request(
  errbuf         OUT NOCOPY VARCHAR2,  -- Request standard error string
  retcode        OUT NOCOPY NUMBER  ,  -- Request standard return status
  p_comment      IN  VARCHAR2,  -- Runtime Comments
  p_school_id    IN  VARCHAR2,  -- School code
  p_branch_id    IN  VARCHAR2,  -- Branch code
  p_cal_inst_id  IN  VARCHAR2,  -- Calendar instance concatenated ID
  p_std_rep_flag IN  VARCHAR2,  -- Standard report flag
  p_dummy        IN  VARCHAR2,  -- Dummy parameter
  p_non_std_rpt_typ	IN VARCHAR2, -- Non Standard report type like GRADUATE
  p_prev_inst_id IN  igs_en_doc_instances.doc_inst_id%TYPE,   -- Previous snapshot Id (if any)
  p_dirpath      IN  VARCHAR2,  -- Output directory name
  p_file_name    IN  VARCHAR2,  -- Output file name
  p_debug_mode   IN  VARCHAR2 := FND_API.G_FALSE
);



/*
  This is the main procedure which prints the data into the text file.
  Its called from the concurent request form or from the Create_Snapshot procedure.
*/

PROCEDURE Print_Snapshot_Request (
  errbuf         OUT NOCOPY VARCHAR2,  -- Request standard error string
  retcode        OUT NOCOPY NUMBER  ,  -- Request standard return status
  p_comment	 IN  VARCHAR2,  -- Runtime comments
  p_inst_id      IN  igs_en_doc_instances.doc_inst_id%TYPE,   -- Snapshot Id to create a file
  p_dirpath      IN  VARCHAR2,  -- Output directory name
  p_file_name    IN  VARCHAR2,  -- Output file name
  p_debug_mode   IN  VARCHAR2 := FND_API.G_FALSE
);



/*
  This is the procedure which deletes the snapshot from the database.
*/

PROCEDURE Delete_Snapshot_Request (
  errbuf         OUT NOCOPY VARCHAR2,  -- Request standard error string
  retcode        OUT NOCOPY NUMBER  ,  -- Request standard return status
  p_comment	 IN  VARCHAR2, -- Runtime comments
  p_inst_id      IN  igs_en_doc_instances.doc_inst_id%TYPE ,   -- Snapshot Id to delete
  p_debug_mode   IN  VARCHAR2 := FND_API.G_FALSE
);

FUNCTION org_alt_check (p_org_id VARCHAR2 )
RETURN VARCHAR2;

END IGS_EN_NSC_PKG;

 

/
