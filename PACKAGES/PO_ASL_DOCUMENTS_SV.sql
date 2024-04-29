--------------------------------------------------------
--  DDL for Package PO_ASL_DOCUMENTS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_DOCUMENTS_SV" AUTHID CURRENT_USER as
/* $Header: POXA8LSS.pls 120.1 2007/12/12 08:43:25 irasoolm noship $ */

/*===========================================================================
  PACKAGE NAME:		po_asl_documents_sv

  DESCRIPTION:		Server-side procedures for PO_ASL_DOCUMENTS

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

function check_record_unique(x_asl_id	   		number,
			     x_using_organization_id	number,
			     x_sequence_num             number,
			     x_document_header_id	number,
			     x_record_status varchar2) return boolean;   --bug 6504696


END PO_ASL_DOCUMENTS_SV;

/
