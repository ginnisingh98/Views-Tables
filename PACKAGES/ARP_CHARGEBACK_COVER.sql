--------------------------------------------------------
--  DDL for Package ARP_CHARGEBACK_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CHARGEBACK_COVER" AUTHID CURRENT_USER AS
/* $Header: ARXCBCVS.pls 120.5 2005/06/03 18:43:03 jbeckett noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/
    TYPE Chargeback_Rec_Type IS RECORD (
      amount                          NUMBER
    , attribute_category              VARCHAR2(30)
    , attribute1                      VARCHAR2(150)
    , attribute2                      VARCHAR2(150)
    , attribute3                      VARCHAR2(150)
    , attribute4                      VARCHAR2(150)
    , attribute5                      VARCHAR2(150)
    , attribute6                      VARCHAR2(150)
    , attribute7                      VARCHAR2(150)
    , attribute8                      VARCHAR2(150)
    , attribute9                      VARCHAR2(150)
    , attribute10                     VARCHAR2(150)
    , attribute11                     VARCHAR2(150)
    , attribute12                     VARCHAR2(150)
    , attribute13                     VARCHAR2(150)
    , attribute14                     VARCHAR2(150)
    , attribute15                     VARCHAR2(150)
    , cust_trx_type_id                NUMBER
    , code_combination_id             NUMBER
    , reason_code                     RA_CUSTOMER_TRX.reason_code%TYPE
    , comments                        RA_CUSTOMER_TRX.comments%TYPE
    , default_ussgl_trx_code_context  ra_customer_trx.default_ussgl_trx_code_context%TYPE
    , default_ussgl_transaction_code  ra_customer_trx.default_ussgl_transaction_code%TYPE
    , gl_date                         DATE
    , due_date                        DATE
    , cash_receipt_id                 NUMBER
    , secondary_application_ref_id    NUMBER
    , new_second_application_ref_id   NUMBER
    , application_ref_type            ar_receivable_applications.application_ref_type%TYPE
    , bill_to_site_use_id             NUMBER
    , interface_header_context        VARCHAR2(30)
    , interface_header_attribute1     VARCHAR2(30)
    , interface_header_attribute2     VARCHAR2(30)
    , interface_header_attribute3     VARCHAR2(30)
    , interface_header_attribute4     VARCHAR2(30)
    , interface_header_attribute5     VARCHAR2(30)
    , interface_header_attribute6     VARCHAR2(30)
    , interface_header_attribute7     VARCHAR2(30)
    , interface_header_attribute8     VARCHAR2(30)
    , interface_header_attribute9     VARCHAR2(30)
    , interface_header_attribute10    VARCHAR2(30)
    , interface_header_attribute11    VARCHAR2(30)
    , interface_header_attribute12    VARCHAR2(30)
    , interface_header_attribute13    VARCHAR2(30)
    , interface_header_attribute14    VARCHAR2(30)
    , interface_header_attribute15    VARCHAR2(30)
    , internal_notes                  ra_customer_trx.internal_notes%TYPE
    , customer_reference              ra_customer_trx.customer_reference%TYPE
    , legal_entity_id 		      ra_customer_trx.legal_entity_id%TYPE
);
/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/
    temp_exception EXCEPTION;

/*========================================================================
 | PUBLIC PROCEDURE    create_chargeback
 |
 | DESCRIPTION
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03-OCT-2001           jbeckett          Created
 |
 *=======================================================================*/
PROCEDURE create_chargeback (
  p_chargeback_rec           IN  arp_chargeback_cover.Chargeback_Rec_Type,
  p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_doc_sequence_id          OUT NOCOPY  NUMBER,
  x_doc_sequence_value       OUT NOCOPY ra_customer_trx.doc_sequence_value%TYPE,
  x_trx_number               OUT NOCOPY ra_customer_trx.trx_number%TYPE,
  x_customer_trx_id          OUT NOCOPY NUMBER,
  x_return_status            OUT NOCOPY VARCHAR2,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2);


END ARP_CHARGEBACK_COVER;

 

/
