--------------------------------------------------------
--  DDL for Package ARP_NON_DB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_NON_DB_PKG" AUTHID CURRENT_USER AS
/*$Header: ARXNODBS.pls 115.4 2003/02/28 22:27:40 djancis ship $*/

PROCEDURE check_natural_application(
                      p_creation_sign               IN VARCHAR2,
                      p_allow_overapplication_flag  IN VARCHAR2,
                      p_natural_app_only_flag       IN VARCHAR2,
                      p_sign_of_ps                  IN VARCHAR2 DEFAULT '-',
                      p_chk_overapp_if_zero         IN VARCHAR2 DEFAULT 'N',
                      p_payment_amount              IN NUMBER,
                      p_discount_taken              IN NUMBER,
                      p_amount_due_remaining        IN NUMBER,
                      p_amount_due_original         IN NUMBER,
	              event 			    IN VARCHAR2 DEFAULT NULL,
	              p_lockbox_record              IN BOOLEAN DEFAULT FALSE);

PROCEDURE check_natural_application(
	      p_creation_sign 		IN VARCHAR2,
	      p_allow_overapplication_flag IN VARCHAR2,
	      p_natural_app_only_flag 	IN VARCHAR2,
	      p_sign_of_ps 		IN VARCHAR2,
	      p_chk_overapp_if_zero 	IN VARCHAR2,
	      p_payment_amount 		IN NUMBER,
	      p_discount_taken 		IN NUMBER,
	      p_amount_due_remaining 	IN NUMBER,
	      p_amount_due_original 	IN NUMBER,
	      event 			IN VARCHAR2,
              p_message_name            OUT NOCOPY VARCHAR2,
              p_lockbox_record          IN BOOLEAN DEFAULT FALSE);


PROCEDURE check_creation_sign(
                      p_creation_sign  IN VARCHAR2,
                      p_amount         IN NUMBER,
                      event            IN VARCHAR2 DEFAULT NULL );

PROCEDURE check_creation_sign(
                      p_creation_sign  IN VARCHAR2,
                      p_amount         IN NUMBER,
                      event            IN VARCHAR2,
                      p_message_name   OUT NOCOPY VARCHAR2);

END ARP_NON_DB_PKG;

 

/
