--------------------------------------------------------
--  DDL for Package Body GL_JIMP_PREPROC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JIMP_PREPROC_PKG" AS
/* $Header: glxfjcb.pls 120.6 2005/07/21 11:41:12 tpradhan ship $ */
/* ---------------------- Public functions -------------------------------- */

FUNCTION revision RETURN VARCHAR2 IS
BEGIN

  RETURN '$Revision: 120.6 $';

END revision;

FUNCTION glxfjc(p_sob_id		IN	NUMBER,
		p_group_id		IN	NUMBER,
		p_je_source_name	IN	VARCHAR2,
		p_force_flag		IN	BOOLEAN) RETURN NUMBER IS
BEGIN
    return 0;
END glxfjc;

/*=======================================================================+
 |    Copyright (c) 1998 Oracle Corporation Belmont, California, USA     |
 |                           All rights reserved.                        |
 +=======================================================================+
 | FILENAME                                                              |
 |    glxfj1()    < Pre-Funds Checker Submodule >       		 |
 |                                                                       |
 | DESCRIPTION                                                           |
 |    This submodule does the following activities in execution          |
 |    sequence:                                  			 |
 |      o  Generate packet_id from sequence gl_bc_packets		 |
 |      o  Initiate packet_id member of control structure		 |
 |      o  Copy transaction records from gl_interface to gl_bc_packets	 |
 |                                                                       |
 | CALLING MODULES                                                       |
 |    GL_JI_PREPROCESSOR.glxfjc() - Funds Check Journal-import 		 |
 |				    Preprocessor 	         	 |
 |                                                                       |
 | CALLED MODULES                                                        |
 |    None                                                               |
 |                                                                       |
 | RETURN VALUES                                                         |
 |    This routine returns TRUE if successful, otherwise it              |
 |    returns FALSE.                                                     |
 |                                                                       |
 | ARGUMENTS	                                                         |
 |    control  Main communication area among glxfjc(), glxfj1(),         |
 |	       glxfj2(), and other funds check modules.			 |
 |                                                                       |
 |    sob_id           Set of books ID					 |
 |    group_id         Journal Import group ID				 |
 |    je_source_name   Journal source name in English			 |
 |                                                                       |
 | PREREQUISITES                                                         |
 |    None                                                               |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | HISTORY                                                               |
 | 	06/10/93  S Ram      Created.                                    |
 *=======================================================================*/

FUNCTION glxfj1(p_sob_id		IN 	NUMBER,
		p_group_id		IN 	NUMBER,
		p_je_source_name	IN	VARCHAR2,
		p_packet_id 		OUT NOCOPY	NUMBER) RETURN BOOLEAN IS
BEGIN
	RETURN FALSE;
END glxfj1;

/*=======================================================================+
 |    Copyright (c) 1998 Oracle Corporation Belmont, California, USA     |
 |                           All rights reserved.                        |
 +=======================================================================+
 | FILENAME                                                              |
 |    glxfj2()    < Post-Funds Checker Submodule >       		 |
 |                                                                       |
 | DESCRIPTION                                                           |
 |    This submodule does the following activities in execution          |
 |    sequence:                                  			 |
 |      o  Copy generated transaction from gl_bc_packets to gl_interface |
 |      o  Delete encumbrance transactions in gl_interface with 	 |
 |         account level automatic encumbrance option turned off	 |
 |                                                                       |
 | CALLING MODULES                                                       |
 |    glxfjc() - Funds Check Journal-import Concurrent program API       |
 |                                                                       |
 | CALLED MODULES                                                        |
 |    None                                                               |
 |                                                                       |
 | RETURN VALUES                                                         |
 |    This routine returns TRUE if successful, otherwise it              |
 |    returns FALSE.                                                     |
 |                                                                       |
 | ARGUMENTS	                                                         |
 |    control  Main communication area among glxfjc(), glxfj1(),         |
 |	       glxfj2(), and other funds check modules.			 |
 |                                                                       |
 | PREREQUISITES                                                         |
 |    None                                                               |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | HISTORY                                                               |
 | 	11/23/98  BKALIAPP	Created.                                 |
 *=======================================================================*/
FUNCTION glxfj2( p_packet_id 	IN 	NUMBER
		) RETURN BOOLEAN IS
BEGIN

    RETURN FALSE;

END glxfj2;

BEGIN
	null;
END gl_jimp_preproc_pkg;

/
