--------------------------------------------------------
--  DDL for Package IGI_EXPWARNINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXPWARNINGS" AUTHID CURRENT_USER as
--  $Header: igiexpls.pls 115.7 2002/11/18 11:59:06 sowsubra ship $

      PROCEDURE CHECK_DOC_TYPE(itemtype IN VARCHAR2,
				itemkey  IN VARCHAR2,
				actid	 IN NUMBER,
				funcmode IN VARCHAR2,
				result 	 OUT NOCOPY VARCHAR2 );

      PROCEDURE START_WORKFLOW (p_new_line wf_messages_tl.body%TYPE,
 	 		    p_item_key 		VARCHAR2,
			    p_preparer_id 	fnd_user.employee_id%type,
			    p_document_type	VARCHAR2);

      PROCEDURE AP_DOC_OUTSIDE_DU_WARNING(p_wait_days 	IN NUMBER);

      PROCEDURE AR_DOC_OUTSIDE_DU_WARNING(p_wait_days 	IN NUMBER);

      PROCEDURE INTEREST_PAYMENT_ACO_WARNING;

      PROCEDURE INTEREST_PAYMENT_AUT_WARNING;

	  PROCEDURE INITIATE_WARNING_CHECKS (p_wait_days IN NUMBER ) ;

end igi_expwarnings ;

 

/
