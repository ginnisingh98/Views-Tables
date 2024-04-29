--------------------------------------------------------
--  DDL for Package PA_CHECK_COMMITMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CHECK_COMMITMENTS" AUTHID CURRENT_USER AS
/* $Header: PAXCMTVS.pls 120.0 2005/05/29 18:43:34 appldev noship $*/

/* Commitments_Changed
	Return Y if commitments changed for the project.
	Return N if commitments not changed for the project.
	Calls PA_Client_Extn_Check_Cmt.Commitments_Changed for the
	client customized commitments.
*/

FUNCTION COMMITMENTS_CHANGED ( p_ProjectID IN NUMBER )
	RETURN VARCHAR2 ;
/* Pragma Restrict_References ( Commitments_Changed, WNDS, WNPS ); Commented for bug 3537697*/

END PA_CHECK_COMMITMENTS;

 

/
