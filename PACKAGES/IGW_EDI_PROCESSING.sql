--------------------------------------------------------
--  DDL for Package IGW_EDI_PROCESSING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_EDI_PROCESSING" AUTHID CURRENT_USER as
/* $Header: igwecpos.pls 115.5 2002/11/14 18:44:21 vmedikon ship $ */
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGW_EDI_PROCESSING';

  --
  -- PROCEDURE:         Submit
  -- Purpose:           Submit PRPO for a proposal number

  PROCEDURE Submit (	errbuf IN OUT NOCOPY varchar2
			,retcode IN OUT NOCOPY varchar2
			,p_proposal_id			IN	NUMBER
			,p_output_path  		IN      VARCHAR2
			,p_narrative_type_code  	IN	VARCHAR2
			,p_narrative_submission_code  	IN	VARCHAR2
			,p_debug_mode			IN      NUMBER);

  PROCEDURE update_edi_date  ( x_proposal_id IN  NUMBER);


END IGW_EDI_PROCESSING;

 

/
