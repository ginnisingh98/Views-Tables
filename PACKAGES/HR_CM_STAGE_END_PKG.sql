--------------------------------------------------------
--  DDL for Package HR_CM_STAGE_END_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CM_STAGE_END_PKG" AUTHID CURRENT_USER AS
/* $Header: hrcmstge.pkh 115.2 2002/01/04 07:05:44 pkm ship       $ */

FUNCTION gl_du_dp_stage_end return varchar2;
/*
This stage end function is for use with datauploader. It evaluates the
completion status of the data uploader stage and if success it updates the
link_value so that all batch lines get processed regardless of the number
of errors raised and submits a concurrent request set to run DataPump and
the Datapump Exceptions report. This has been written for the GL Cost
Center project.
*/
end hr_cm_stage_end_pkg;

 

/
