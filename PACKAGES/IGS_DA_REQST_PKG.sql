--------------------------------------------------------
--  DDL for Package IGS_DA_REQST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_DA_REQST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDA04S.pls 115.8 2003/04/07 06:59:17 nalkumar noship $ */

/***************************************************************************************************************

Created By:        Arun Iyer

Date Created By:   26-11-2001

Purpose:     This package is called from the Request self service screens.
             It has procedure which captures the request information into the Degree Audit data exchange area
             and call the out NOCOPY packages to fetch data from the Oss tables.

Known limitations,enhancements,remarks:

Change History

Who        When        What
Aiyer      19-Feb-2002   Changes have been made as a part of the code fix for the bug 2233298
                         Added IN OUT NOCOPY parameters p_major_seq_num ,p_minor_seq_num,p_track_seq_num
                         to procedures insert_majors, insert_minors, insert_tracks  respectively

rgangara   22-Feb-2002   Added parameter Alt_Person_id to Insert_student_requesst procedure
                         as part of CCR SWCR009 Bug# 2237145

Aiyer      12-Dec-2002   Procedure validate_batch_request and insert_batch_request modified for
                         the bug #2638656.Obsoletion of athletic_program_id field from these procedures
Nalin Kumar 07-Apr-2003  Obsoleted the 'Degree Audit Single Request Submission' & 'Degree Audit Multiple Request Submission' Job.
                         This is as per DA UI Build. Bug# 2829285.
****************************************************************************************************************** */

	PROCEDURE single_da_request (errbuf		OUT NOCOPY VARCHAR2,
															 retcode	OUT NOCOPY NUMBER,
															 p_batch_id   	IN NUMBER,
															 p_org_id       IN NUMBER);

	PROCEDURE multiple_da_request (errbuf		OUT NOCOPY VARCHAR2,
																 retcode	OUT NOCOPY NUMBER,
																 p_batch_id   	IN NUMBER,
																 p_org_id       IN NUMBER);
END igs_da_reqst_pkg;

 

/
