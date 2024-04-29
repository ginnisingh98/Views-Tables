--------------------------------------------------------
--  DDL for Package PO_ASL_AUTHORIZATIONS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_AUTHORIZATIONS_SV" AUTHID CURRENT_USER as
/* $Header: POXACLSS.pls 120.0.12010000.1 2008/09/18 12:20:53 appldev noship $ */

/*===========================================================================
  PACKAGE NAME:		po_asl_authorizations_sv

  DESCRIPTION:		Server-side procedures for CHV_AUTHORIZATIONS
			for the ASL.

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:                cmok

  PROCEDURE NAMES:

===========================================================================*/
/*===========================================================================
  PROCEDURE NAME:	check_record_unique


  DESCRIPTION:     	Determines whether record contains unique combination
			of using_organization_id, asl_id and sequence_num


  CHANGE HISTORY:  	28-Jun-96	cmok		Created

===============================================================================*/

function check_record_unique(x_reference_id	   	number,
			     x_reference_type		varchar2,
			     x_authorization_code	varchar2,
			     x_authorization_sequence   number,
			     x_using_organization_id    number) return boolean;

END PO_ASL_AUTHORIZATIONS_SV;

/
