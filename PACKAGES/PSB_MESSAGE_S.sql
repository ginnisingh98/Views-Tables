--------------------------------------------------------
--  DDL for Package PSB_MESSAGE_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_MESSAGE_S" AUTHID CURRENT_USER AS
/* $Header: PSBSTMSS.pls 120.2 2004/12/06 17:35:38 viraghun ship $ */

/* Start bug no 4030864 */
l_batch_error_flag  BOOLEAN := FALSE;
/* End bug no 4030864 */

FUNCTION  Get      ( p_msg_index     IN NUMBER   ,
		     p_encoded       IN VARCHAR2 := FND_API.G_TRUE )
RETURN VARCHAR2;

PROCEDURE  Print_Error ( p_mode         IN VARCHAR2,
			 p_print_header IN VARCHAR2 := FND_API.G_TRUE );

PROCEDURE  Insert_Error ( p_source_process IN VARCHAR2,
			  p_process_id     IN NUMBER,
			  p_msg_count      IN NUMBER,
			  p_msg_data       IN VARCHAR2,
			  p_desc_sequence  IN VARCHAR2 := FND_API.G_FALSE
			);

PROCEDURE  Print_Success ;

PROCEDURE  Get_Error_Message  ( p_print_header   IN VARCHAR2 := FND_API.G_TRUE,
				p_msg_string    OUT  NOCOPY VARCHAR2 ) ;

PROCEDURE  Get_Success_Message( p_msg_string OUT  NOCOPY VARCHAR2 ) ;

FUNCTION  Get_Error_Stack( p_msg_count NUMBER )
	  RETURN VARCHAR2;

/* Start bug no 4030864 */
PROCEDURE BATCH_INSERT_ERROR (
  p_source_process IN VARCHAR2,
  p_process_id     IN NUMBER);
/* End bug no 4030864 */


END PSB_MESSAGE_S;

 

/
