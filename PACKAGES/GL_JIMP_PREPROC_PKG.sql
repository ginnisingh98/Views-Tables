--------------------------------------------------------
--  DDL for Package GL_JIMP_PREPROC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JIMP_PREPROC_PKG" AUTHID CURRENT_USER AS
/* $Header: glxfjcs.pls 120.2 2002/11/13 20:19:42 djogg ship $ */

FUNCTION revision RETURN VARCHAR2 ;

FUNCTION glxfjc(p_sob_id		IN	NUMBER,
		p_group_id		IN	NUMBER,
		p_je_source_name	IN	VARCHAR2,
		p_force_flag		IN	BOOLEAN) RETURN NUMBER ;

FUNCTION glxfj1(p_sob_id		IN 	NUMBER,
		p_group_id		IN 	NUMBER,
		p_je_source_name	IN	VARCHAR2,
		p_packet_id 		OUT NOCOPY	NUMBER) RETURN BOOLEAN ;

FUNCTION glxfj2(p_packet_id 	IN 	NUMBER
		) RETURN BOOLEAN ;

END gl_jimp_preproc_pkg;

 

/
