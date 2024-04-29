--------------------------------------------------------
--  DDL for Package Body IGS_DA_REQST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_DA_REQST_PKG" AS
/* $Header: IGSDA04B.pls 115.41 2003/04/07 07:08:39 nalkumar noship $ */


/**************************************************************************************************************************

Created By:        Arun Iyer

Date Created By:   20-11-2001

Purpose:     The various procedures in this package would be called by the Self service Request screen
             and the In and Out NOCOPY Degree Audit Packages.
       This has been made as per the Degree Audit Dld Bug # 2033208
             This package does the functionality of storing request information that has been given by
       the self service screen and updated by the various packages

Known limitations,enhancements,remarks:

Change History

Who        When          What
Aiyer      19-Feb-2002   Changes have been made as a part of the code fix for the bug 2233298
                         Added IN OUT NOCOPY parameters p_major_seq_num ,p_minor_seq_num,p_track_seq_num
                         to procedures insert_majors, insert_minors, insert_tracks  respectively

rgangara   22-Feb-2002   Enchancements as per CCR SWCR009. Bug# 2237145.
                         Added Alt_person_id as parameter in Insert_batch_request, Insert_student_request procedures
rgangara   25-Feb-2002   Fixing of Review comments
Aiyer      08-Mar-2002   Fix for the bug 2248040. Validation 10 in Validate Request procedure was added as a part of this bug
Aiyer      20-Mar-2002   The procedure delete_request has been modified due to the performance bug #2219307
Aiyer      16-May-2002   The procedure insert_batch_student was changed for the fix of the bugs 2370194,2370165
Aiyer      16-May-2002   The procedure insert_batch_student was modified for the fix of the bug 2369716
Aiyer      22-May-2002   The procedure insert_batch_student was modified for the fix of the bug 2370124
Aiyer      19-Jun-2002   The procedure Update_request and Submit_audit_request have been modifed for the fix of the bug 2422143.
Aiyer      29-May-2002   This has been done as a part of the bug fix for the bug 2415113. The procedure insert_batch_students has
                         been modified for this fix.
Aiyer      11-Jul-2002   This has been done as a part of the bug fix for the bug 2453391. The procedure insert_batch_students has
                         been modified for this fix.
DDEY       09-Aug-2002   The Dyanmic SQL query for Graduation Term is changed as per the bug # 2436029 .
kumma      18-OCT-2002   Changed the query to fetch the new columns from igs_pe_athletic_dtl_v and igs_pe_athletic_prg_v, 2608360
kumma      08-NOV-2002   Removed the Default Keywords from the procedure signatures
Aiyer      12-Dec-2002   Procedure validate_batch_request and insert_batch_request modified for
                         the bug #2638656.Obsoletion of athletic_program_id field from these procedures
Nalin Kumar 07-Apr-2003  Obsoleted the 'Degree Audit Single Request Submission' & 'Degree Audit Multiple Request Submission' Job.
                         This is as per DA UI Build. Bug# 2829285.
******************************************************************************************************************************/
  PROCEDURE single_da_request (errbuf   OUT NOCOPY VARCHAR2,
                               retcode  OUT NOCOPY NUMBER,
                               p_batch_id     IN  NUMBER,
                               p_org_id       IN  NUMBER)  IS
  BEGIN
    -- This concurrent job is made obsolete as part of Enh#2829285. If user tried to
    -- run the program then an error message should be written to the Log file that
    -- the Concurrent Program is obsolete and this should not be run. DA UI Build.
    FND_MESSAGE.Set_Name('IGS', 'IGS_GE_OBSOLETE_JOB');
    FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
    retcode := 0;
  END single_da_request;

  PROCEDURE multiple_da_request (errbuf   OUT NOCOPY VARCHAR2,
                                 retcode  OUT NOCOPY NUMBER,
                                 p_batch_id     IN NUMBER,
                                 p_org_id       IN NUMBER) IS
  BEGIN
    -- This concurrent job is made obsolete as part of Enh#2829285. If user tried to
    -- run the program then an error message should be written to the Log file that
    -- the Concurrent Program is obsolete and this should not be run. DA UI Build.
    FND_MESSAGE.Set_Name('IGS', 'IGS_GE_OBSOLETE_JOB');
    FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
    retcode := 0;
  END multiple_da_request;
END igs_da_reqst_pkg;

/
