--------------------------------------------------------
--  DDL for Package ECE_AR_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_AR_TRANSACTION" AUTHID CURRENT_USER AS
-- $Header: ECEINOS.pls 120.2 2005/09/28 07:23:39 arsriniv ship $
/* Bug1854866
Assigned default values to the parameter
cdebug_mode of the procedure extract_ino_outbound
since the default values are assigned to these parameters
in the package body
*/

   PROCEDURE extract_ino_outbound(
      errbuf                     OUT NOCOPY VARCHAR2,
      retcode                    OUT NOCOPY VARCHAR2,
      cOutputPath                IN  VARCHAR2,
      cOutput_Filename           IN  VARCHAR2,
      cCDate_From                IN  VARCHAR2,
      cCDate_To                  IN  VARCHAR2,
      cCustomer_Name             IN  VARCHAR2,
      cSite_Use_Code             IN  VARCHAR2,
      cDocument_Type             IN  VARCHAR2,
      cTransaction_Number        IN  VARCHAR2,
      cdebug_mode                IN  NUMBER DEFAULT 0);

   PROCEDURE update_ar(
      document_type		         IN	 VARCHAR2,
      transaction_id		         IN	 NUMBER,
      installment_number	      IN	 NUMBER,
      multiple_installments_flag IN	 VARCHAR2,
      maximum_installment_number IN	 NUMBER,
      update_date	               IN	 DATE);

   PROCEDURE get_remit_address(
      customer_trx_id            IN  NUMBER,
      remit_to_address1          OUT NOCOPY VARCHAR2,
      remit_to_address2          OUT NOCOPY VARCHAR2,
      remit_to_address3 	 OUT NOCOPY VARCHAR2,
      remit_to_address4 	 OUT NOCOPY VARCHAR2,
      remit_to_city		 OUT NOCOPY VARCHAR2,
      remit_to_county		 OUT NOCOPY VARCHAR2,
      remit_to_state		 OUT NOCOPY VARCHAR2,
      remit_to_province	         OUT NOCOPY VARCHAR2,
      remit_to_country           OUT NOCOPY VARCHAR2,
      remit_to_code_int          OUT NOCOPY VARCHAR2,
      remit_to_postal_code	 OUT NOCOPY VARCHAR2,
      remit_to_customer_name     OUT NOCOPY VARCHAR2,
      remit_to_edi_location_code OUT NOCOPY VARCHAR2);

   PROCEDURE get_payment(
      customer_trx_id            IN	 NUMBER,
      installment_number         IN	 NUMBER,
      multiple_installments_flag OUT NOCOPY VARCHAR2,
      maximum_installment_number OUT NOCOPY NUMBER,
      amount_tax_due	 	 OUT NOCOPY NUMBER,
      amount_charges_due         OUT NOCOPY NUMBER,
      amount_freight_due         OUT NOCOPY NUMBER,
      amount_line_items_due      OUT NOCOPY NUMBER,
      total_amount_due           OUT NOCOPY NUMBER);

--Bug 2389231 Added a new column invoice_date.

   PROCEDURE get_term_discount(
      document_type		 IN  VARCHAR2,
      term_id			 IN  NUMBER,
      term_sequence_number       IN  NUMBER,
      invoice_date               IN  DATE,
      discount_percent1          OUT NOCOPY NUMBER,
      discount_days1             OUT NOCOPY NUMBER,
      discount_date1             OUT NOCOPY DATE,
      discount_day_of_month1     OUT NOCOPY NUMBER,
      discount_months_forward1   OUT NOCOPY NUMBER,
      discount_percent2          OUT NOCOPY NUMBER,
      discount_days2             OUT NOCOPY NUMBER,
      discount_date2             OUT NOCOPY DATE,
      discount_day_of_month2     OUT NOCOPY NUMBER,
      discount_months_forward2   OUT NOCOPY NUMBER,
      discount_percent3          OUT NOCOPY NUMBER,
      discount_days3             OUT NOCOPY NUMBER,
      discount_date3             OUT NOCOPY DATE,
      discount_day_of_month3     OUT NOCOPY NUMBER,
      discount_months_forward3   OUT NOCOPY NUMBER);

   function get_currency_code
   return varchar2;

   PROCEDURE put_data_to_output_table(
      cCommunication_Method      IN  VARCHAR2,
      cTransaction_Type	         IN  VARCHAR2,
      iOutput_width		         IN  INTEGER,
      iRun_id			            IN  INTEGER,
      cHeader_Interface	         IN  VARCHAR2,
      cHeader_1_Interface        IN  VARCHAR2,
      cAlw_chg_Interface         IN  VARCHAR2,
      cLine_Interface		      IN  VARCHAR2,
      cLine_t_Interface	         IN  VARCHAR2);

   PROCEDURE populate_ar_trx(
      cCommunication_Method      IN  VARCHAR2,
      cTransaction_Type          IN  VARCHAR2,
      iOutput_Width              IN  INTEGER,
      dTransaction_date	         IN  DATE,
      iRun_Id                    IN  INTEGER,
      cHeader_Interface          IN  VARCHAR2,
      cHeader_1_Interface        IN  VARCHAR2,
      cAlw_chg_Interface         IN  VARCHAR2,
      cLine_Interface            IN  VARCHAR2,
      cLine_t_Interface          IN  VARCHAR2,
      cCreate_Date_From          IN  DATE,
      cCreate_Date_To            IN  DATE,
      cCustomer_Name             IN  VARCHAR2,
      cSite_Use_Code             IN  VARCHAR2,
      cDocument_Type             IN  VARCHAR2,
      cTransaction_Number        IN  VARCHAR2);

END;


 

/
