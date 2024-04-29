--------------------------------------------------------
--  DDL for Package PO_INTERFACE_ERRORS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_INTERFACE_ERRORS_SV1" AUTHID CURRENT_USER AS
/* $Header: POXPIIES.pls 115.10 2004/03/05 23:30:39 mbhargav ship $ */

/*==================================================================
  FUNCTION NAME:  handle_interface_errors()

  DESCRIPTION:    This API is basically a error handling "wrapper" routine for
		  for PO_HEADERS_INTERFACE and PO_LINES_INTERFACE.

  DESIGN
  REFERENCES:	  832erro5.doc

  CHANGE
  HISTORY:	  Created	03-Mar-1996	Rajan Odayar
		  Modified      04-MAR-1996     Daisy Yu
                  Modified      21-APR-1996     daisy Yu

=======================================================================*/
 PROCEDURE handle_interface_errors(X_interface_type           IN  VARCHAR2,
                                   X_Error_type               IN  VARCHAR2,
				   X_Batch_id                 IN  NUMBER,
                                   X_Interface_Header_Id      IN  NUMBER,
                                   X_Interface_Line_id        IN  NUMBER,
				   X_Error_message_name       IN  VARCHAR2,
        			   X_Table_name               IN  VARCHAR2,
                                   X_Column_name              IN  VARCHAR2,
				   X_TokenName1               IN  VARCHAR2,
                                   X_TokenName2               IN  VARCHAR2,
                                   X_TokenName3               IN  VARCHAR2,
                                   X_TokenName4               IN  VARCHAR2,
                                   X_TokenName5               IN  VARCHAR2,
                                   X_TokenName6               IN  VARCHAR2,
				   X_TokenValue1              IN  VARCHAR2,
				   X_TokenValue2              IN  VARCHAR2,
				   X_TokenValue3              IN  VARCHAR2,
				   X_TokenValue4              IN  VARCHAR2,
				   X_TokenValue5              IN  VARCHAR2,
				   X_TokenValue6              IN  VARCHAR2,
				   X_header_processable_flag  IN OUT NOCOPY VARCHAR2,
                                   X_Interface_Dist_Id        IN  NUMBER DEFAULT null);

/*==================================================================
  FUNCTION NAME:  insert_po_interface_errors()

  DESCRIPTION:    This API inserts records into po_interface_errors table.
                  Bug 2705777. Changed to be an AUTONOMOUS TRANSACTION
  DESIGN
  REFERENCES:	  832erro5.doc

  CHANGE
  HISTORY:	  Created	03-Mar-1996	Rajan Odayar
		  Modified      04-MAR-1996     Daisy Yu
                                03-MAR-2004     Manish Bhargava
=======================================================================*/
FUNCTION  insert_po_interface_errors(X_interface_type       IN VARCHAR2,
                        X_Error_type           IN VARCHAR2, --<Bug 3375881>
                        X_Batch_id             IN NUMBER,
                        X_Interface_Header_ID  IN NUMBER,
                        X_Interface_Line_Id    IN NUMBER,
                        X_Interface_Dist_Id    IN NUMBER,
                        X_error_message_name   IN VARCHAR2,
	                X_column_name          IN VARCHAR2,
			X_table_name           IN VARCHAR2,
                        X_TokenName1           IN VARCHAR2,
                        X_TokenName2           IN VARCHAR2,
                        X_TokenName3           IN VARCHAR2,
                        X_TokenName4           IN VARCHAR2,
                        X_TokenName5           IN VARCHAR2,
                        X_TokenName6           IN VARCHAR2,
                        X_TokenValue1          IN VARCHAR2,
                        X_TokenValue2          IN VARCHAR2,
                        X_TokenValue3          IN VARCHAR2,
                        X_TokenValue4          IN VARCHAR2,
                        X_TokenValue5          IN VARCHAR2,
                        X_TokenValue6          IN VARCHAR2)
 RETURN VARCHAR2 ;

 -- Bug 2705777. Removed procedures rollback_changes and rollback_line_changes

  -- <PDOI-Grants Integration Project: START>
  /*==================================================================
  FUNCTION NAME:  handle_interface_errors_msg()

  DESCRIPTION:    This API is identical to the handle_interface_errors()
                  defined above. However, instead of message code, this API
                  takes in the translated message string as one of the
                  parameters.

  DESIGN
  REFERENCES:

  CHANGE
  HISTORY:        Created  16-May-2003 Puneet Thapliyal

  =======================================================================*/
  PROCEDURE handle_interface_errors_msg(
                    X_interface_type           IN  VARCHAR2,
                    X_Error_type               IN  VARCHAR2,
                    X_Batch_id                 IN  NUMBER,
                    X_Interface_Header_Id      IN  NUMBER,
                    X_Interface_Line_id        IN  NUMBER,
                    X_Error_message_text       IN  VARCHAR2,
                    X_Error_message_name       IN  VARCHAR2,
                    X_Table_name               IN  VARCHAR2,
                    X_Column_name              IN  VARCHAR2,
                    X_header_processable_flag  IN OUT NOCOPY VARCHAR2,
                    X_Interface_Dist_Id        IN  NUMBER DEFAULT NULL);
  -- <PDOI-Grants Integration Project: END>

END PO_INTERFACE_ERRORS_SV1;


 

/
