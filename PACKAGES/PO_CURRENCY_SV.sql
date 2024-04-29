--------------------------------------------------------
--  DDL for Package PO_CURRENCY_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CURRENCY_SV" AUTHID CURRENT_USER AS
/* $Header: POXDOCUS.pls 120.0.12010000.2 2010/07/30 07:18:53 dashah ship $*/
/*===========================================================================
  FUNCTION NAME:	val_currency()

  DESCRIPTION:		This function checks whether a given Currency
			is still valid.


  PARAMETERS:		X_currency_code IN VARCHAR2

  RETURN TYPE:		BOOLEAN

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	09-JUL-1995	LBROADBE
			Changed to	14-AUG-1995	LBROADBE
			Function
===========================================================================*/
FUNCTION  val_currency(X_currency_code IN VARCHAR2) return BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:       get_rate

  DESCRIPTION:          Get the dispaly_rate, and conversion_rate
                        from gl_daily_conversion_rates. The inverse rate
                        is returned based on client side business
                        rules (criteria).


  PARAMETERS:           x_set_of_books_id                IN     NUMBER
                        x_currency_code                  IN     VARCHAR2
                        x_rate_type                      IN     VARCHAR2
                        x_rate_date                      IN     DATE
                        x_inverse_rate_display_flag      IN     VARCHAR2
                        x_display_rate                   IN OUT NUMBER
                        x_rate                           IN OUT NUMBER


  DESIGN REFERENCES:	../POXPOREL.doc
			../currency.dd

  ALGORITHM:            decode(:x_inverse_rate_display_flag,
                        'Y', 1/conversion_rate,
                        conversion_rate) --- gets the inverse rate

  NOTES:                get_default_rate = get_rate (get_default_rate
                        is referenced in POXRQERQ.doc)

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       ALOCATEL Last Change on 5/12
===========================================================================*/

PROCEDURE get_rate(x_set_of_books_id              IN     NUMBER,
                   x_currency_code                IN     VARCHAR2,
                   x_rate_type                    IN     VARCHAR2,
                   x_rate_date                    IN     DATE,
                   x_inverse_rate_display_flag    IN     VARCHAR2,
                   x_rate                         IN OUT NOCOPY NUMBER,
                   x_display_rate                 IN OUT NOCOPY NUMBER);


/*===========================================================================
  PROCEDURE NAME:       get_rate

  DESCRIPTION:          Get the dispaly_rate, and conversion_rate
                        from gl_daily_conversion_rates. The inverse rate
                        is returned based on client side business
                        rules (criteria).


  PARAMETERS:           x_set_of_books_id                IN     NUMBER
                        x_currency_code                  IN     VARCHAR2
                        x_rate_type                      IN     VARCHAR2
                        x_rate_date                      IN     DATE
                        x_inverse_rate_display_flag      IN     VARCHAR2
                        x_display_rate                   IN OUT NUMBER
                        x_rate                           IN OUT NUMBER


  DESIGN REFERENCES:	../POXPOREL.doc
			../currency.dd

  ALGORITHM:            decode(:x_inverse_rate_display_flag,
                        'Y', 1/conversion_rate,
                        conversion_rate) --- gets the inverse rate

  NOTES:                get_default_rate = get_rate (get_default_rate
                        is referenced in POXRQERQ.doc)

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       ALOCATEL Last Change on 5/12
===========================================================================*/

PROCEDURE test_get_rate(x_set_of_books_id         IN     NUMBER,
                   x_currency_code                IN     VARCHAR2,
                   x_rate_type                    IN     VARCHAR2,
                   x_rate_date                    IN     DATE,
                   x_inverse_rate_display_flag    IN     VARCHAR2);



/*===========================================================================
  PROCEDURE NAME:       get_rate_type_disp

  DESCRIPTION:          Get the displayed rate type given a
			rate type.


  PARAMETERS:           x_rate_type		IN   	VARCHAR2
			x_rate_type_disp	IN OUT	VARCHAR2


  DESIGN REFERENCES:	POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Y. Mulpury	06/27
===========================================================================*/

PROCEDURE get_rate_type_disp (x_rate_type	IN 	VARCHAR2,
			      x_rate_type_disp  IN OUT	NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:     validate_currency_info

  DESCRIPTION:        Validates the components of the currency record
                      and returns error status and error messages based
                      on a set of business rules.

  PARAMETERS:         p_cur_record IN OUT RCV_SHIPMENT_HEADER_SV.CurRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Raj Bhakta 11/01/96  Created
===========================================================================*/

PROCEDURE validate_currency_info (
          p_cur_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.CurRecType);

--<Shared Proc FPJ START>
PROCEDURE get_functional_currency_code(
         p_org_id                   IN NUMBER,
         x_functional_currency_code OUT NOCOPY VARCHAR2);

FUNCTION rate_exists(
                p_from_currency         VARCHAR2,
                p_to_currency           VARCHAR2,
                p_conversion_date       DATE,
                p_conversion_type       VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

PROCEDURE get_rate(p_from_currency                IN     VARCHAR2,
                   p_to_currency                  IN     VARCHAR2,
                   p_rate_type                    IN     VARCHAR2,
                   p_rate_date                    IN     DATE,
                   p_inverse_rate_display_flag    IN     VARCHAR2,
                   x_rate                         OUT NOCOPY NUMBER,
                   x_display_rate                 OUT NOCOPY NUMBER,
                   x_return_status                OUT NOCOPY VARCHAR2,
                   x_error_message_name           OUT NOCOPY VARCHAR2);
--<Shared Proc FPJ END>

-- bug3294883
FUNCTION get_currency_precision ( p_currency IN  VARCHAR2 ) RETURN NUMBER;

--<HTMLAC START>
FUNCTION get_cross_ou_rate ( p_from_ou_id IN NUMBER, p_to_ou_id IN NUMBER )
RETURN NUMBER;
--<HTMLAC END>
--Bug 9929991 When Function curruncey is differnt then PO curruncey we need to convert From Function to PO curruncey
FUNCTION get_converted_unit_price
(
  p_list_unit_price IN NUMBER ,
  p_rate IN NUMBER ,
  p_currency_code VARCHAR2

) RETURN NUMBER;
--Bug 9929991 When Function curruncey is differnt then PO curruncey we need to convert From Function to PO curruncey


END po_currency_sv;

/
