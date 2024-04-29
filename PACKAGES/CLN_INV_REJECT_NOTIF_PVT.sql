--------------------------------------------------------
--  DDL for Package CLN_INV_REJECT_NOTIF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_INV_REJECT_NOTIF_PVT" AUTHID CURRENT_USER AS
      /* $Header: CLN3C4S.pls 120.0 2005/05/24 16:20:00 appldev noship $ */


      -- Start of comments
      --	Procedure name 	    : SEPARATE_REASON_CODE
      --	Type		    : Private.
      --	Pre-reqs            : None.
      --	Function	    : It separates the line number from the given reasoncode
      --        Parameters	    :
      --	 IN		    : p_reason_code        IN  VARCHAR2 --- Required
      --         OUT                : x_err_string         OUT VARCHAR2 --- Required
      --                              x_line_num           OUT NUMBER  ----  Required
      --
      --       Notes                :
      -- End of comments

      PROCEDURE SEPARATE_REASON_CODE (p_reason_code IN VARCHAR2,
                                      x_err_string  OUT NOCOPY VARCHAR2,
                                      x_line_num    OUT NOCOPY NUMBER);

      -- Start of comments
      --	Procedure name 	    : ADD_MESSAGES_TO_COLL_HISTORY
      --	Type		    : Private.
      --	Pre-reqs            : None.
      --	Function	    : Adds messages to the Collaboration History.
      --        Parameters	    :
      --	 IN		    : p_internal_control_number        IN NUMBER --- Required
      --                              p_line_num                       IN NUMBER --- Required
      --                              p_err_string                     IN VARCHAR2  ----  Required
      --                              p_id                             IN VARCHAR2 --- Requried
      --       Notes                :
      -- End of comments

      PROCEDURE ADD_MESSAGES_TO_COLL_HISTORY( p_internal_control_number IN NUMBER,
                                              p_line_num                IN NUMBER,
                                              p_err_string              IN VARCHAR2,
                                              p_id                      IN VARCHAR2 );

      -- Start of comments
      --	Procedure name 	    : CALL_AR_API
      --	Type		    : Private.
      --	Pre-reqs            : None.
      --	Function	    : Calls 'ar_confirmation.initiate_confirmation_process' to send the notification
      --        Parameters	    :
      --	 IN		    : p_internal_control_number        IN NUMBER --- Required
      --                              p_reason_code                    IN VARCHAR2 --- Required
      --                              p_description                    IN VARCHAR2  ----  Required
      --                              p_id                             IN VARCHAR2 --- Requried
      --       Notes                :
      -- End of comments

      PROCEDURE  CALL_AR_API(p_reason_code             IN VARCHAR2,
                             p_id                      IN VARCHAR2,
                             p_description             IN VARCHAR2,
                             p_internal_control_number IN NUMBER);

      -- Start of comments
      --	Procedure name 	   : PROCESS_INBOUND_3C4
      --	Type	    	   : Private.
      --	Pre-reqs    	   : None.
      --	Function    	   : This procedure does
      --                             (1). Separates individual reason codes from the value of the parameter 'p_reason_code'
      --                                  and calls the 'ar_confirmation.initiate_confirmation_process'
      --                                  API the number of times as the number of times the reason codes are.
      --                             (2). Updates the Collaboration History with the '3C4 Inbound
      --                                  consumed successfully' message.
      --
      --	Parameters	   :
      --	IN	           : p_internal_control_number  IN NUMBER  ---  Required
      --                             p_reason_code              IN VARCHAR2 --- Optional
      --                             p_id                       IN VARCHAR2 --- Required
      --                             p_description              IN VARCHAR2 --- Optional
      --        Notes              : This procedure is called from the XML map(3C4 Inbound)
      -- End of comments

      PROCEDURE PROCESS_INBOUND_3C4  ( p_internal_control_number  IN NUMBER,
                                       p_reason_code              IN VARCHAR2,
                                       p_invoice_num              IN VARCHAR2,
                                       p_description              IN VARCHAR2,
				       p_tp_id                    IN NUMBER);

      -- Start of comments
      --	Procedure name 	  : NOTIFICATION_PROCESS_3C4_IN
      --	Type	    	  : Private.
      --	Pre-reqs    	  : None.
      --	Function          : This API does the actions specified in the notification code '3C4_01'.
      --
      --       Parameters   	  :
      --       IN	      	  : p_itemtype        IN VARCHAR2 --- Required
      --                            p_itemkey         IN VARCHAR2 --- Required
      --                            p_actid           IN NUMBER  ----  Required
      --                            p_funcmode        IN VARCHAR2  --- Required
      --       IN OUT             : x_resultout       IN OUT NOCOPY VARCHAR2  ---  Required
      --    Notes                 : This procedure is called from the XML map(3C4 Inbound)
      -- End of comments

      PROCEDURE NOTIFICATION_PROCESS_3C4_IN (  p_itemtype        IN VARCHAR2,
                                               p_itemkey         IN VARCHAR2,
                                               p_actid           IN NUMBER,
                                               p_funcmode        IN VARCHAR2,
                                               x_resultout       IN OUT NOCOPY VARCHAR2);

END CLN_INV_REJECT_NOTIF_PVT;

 

/
