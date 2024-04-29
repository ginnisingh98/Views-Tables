--------------------------------------------------------
--  DDL for Package PSP_MESSAGE_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_MESSAGE_S" AUTHID CURRENT_USER AS
/*$Header: PSPSTMSS.pls 115.7 2002/11/20 04:36:04 ddubey ship $*/

FUNCTION  Get      ( p_msg_index     IN NUMBER   ,
		     p_encoded       IN VARCHAR2 := FND_API.G_TRUE)
RETURN VARCHAR2;


PROCEDURE  Print_Error ( p_mode        	IN VARCHAR2,
                         p_print_header	IN VARCHAR2 := FND_API.G_TRUE );

/**************************************************************
PROCEDURE  Insert_Error ( p_source_process IN VARCHAR2,
			  p_process_id	   IN NUMBER,
			  p_msg_count      IN NUMBER,
                          p_msg_data       IN VARCHAR2,
                          p_desc_sequence  IN VARCHAR2 := FND_API.G_FALSE
                        );

****************************************************************/

PROCEDURE  Print_Success ;

PROCEDURE  Get_Error_Message  ( p_print_header   IN VARCHAR2 := FND_API.G_TRUE,
				p_msg_string    OUT NOCOPY VARCHAR2 ) ;

PROCEDURE  Get_Success_Message( p_msg_string OUT NOCOPY VARCHAR2 ) ;

END PSP_MESSAGE_S;

 

/
