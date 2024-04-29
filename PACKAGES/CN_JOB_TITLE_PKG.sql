--------------------------------------------------------
--  DDL for Package CN_JOB_TITLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_JOB_TITLE_PKG" AUTHID CURRENT_USER AS
/*$Header: cntjobs.pls 115.4 2002/11/21 21:09:47 hlchen ship $*/

PROCEDURE Insert_Row(newrec   IN OUT
                     CN_JOB_TITLE_PVT.JOB_ROLE_REC_TYPE);
PROCEDURE Update_Row(newrec
                     CN_JOB_TITLE_PVT.JOB_ROLE_REC_TYPE);
PROCEDURE Lock_Row  (p_job_role_id           IN NUMBER,
                     p_object_version_number IN NUMBER);
PROCEDURE Delete_Row(p_job_role_id              NUMBER);

END CN_JOB_TITLE_PKG;

 

/
