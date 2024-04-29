--------------------------------------------------------
--  DDL for Package WSH_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: WSHUTILS.pls 115.4 2004/04/27 21:45:52 anviswan ship $ */

/* This Function return the output log directory to create any kind of output file */

Function Get_Output_file_dir return varchar2 ;

--3509004:public api change
PROCEDURE process_message(
			p_entity           IN             VARCHAR2,
			p_entity_name      IN             VARCHAR2,
			p_attributes        IN             VARCHAR2,
			x_return_status    OUT NOCOPY     VARCHAR2
			);

END Wsh_Utilities;

 

/
