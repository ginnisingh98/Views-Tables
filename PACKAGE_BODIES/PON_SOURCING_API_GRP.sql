--------------------------------------------------------
--  DDL for Package Body PON_SOURCING_API_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_SOURCING_API_GRP" AS
/* $Header: PONNELTB.pls 120.1 2006/03/06 11:41:54 sssahai noship $ */

   /*======================================================================
   PROCEDURE :  val_neg_exists_for_line_type   PUBLIC
     PARAMETERS:
     p_line_type_id     IN     line_type that we want to check for
     x_result           OUT NOCOPY  result returns 'Y' if negotiations exist,else 'N'
     x_error_code       OUT NOCOPY    errcode if any error generate
     x_error_message    OUT NOCOPY    error message if any error. size is 250.

     COMMENT : validate if any negotiations exist using the line type specified.
     ======================================================================*/

   PROCEDURE val_neg_exists_for_line_type(p_line_type_id NUMBER,
				 x_result OUT NOCOPY VARCHAR2,
				 x_error_code OUT NOCOPY VARCHAR2,
				 x_error_message OUT NOCOPY VARCHAR2
				    )
     IS

	v_debug_status VARCHAR2(100);
	v_neg_count NUMBER;

   BEGIN

      x_result := 'N';

       -- look for records in the auctions tables
      v_debug_status := 'VAL_NEG_EXISTS';

      SELECT COUNT(1) INTO v_neg_count
	FROM pon_auction_item_prices_all
	WHERE line_type_id = p_line_type_id and
              rownum = 1;

      IF (v_neg_count > 0) THEN
	 x_result := 'Y';
       ELSE
	 x_result := 'N';
      END IF;


      RETURN;

   EXCEPTION
      WHEN others THEN
	 fnd_message.set_name('PON','PON_AUC_PLSQL_ERR');
	 fnd_message.set_token('PACKAGE','PON_SOURCING_OPENAPI_GRP');
	 fnd_message.set_token('PROCEDURE', 'val_neg_exists_for_line_type');
	 fnd_message.set_token('ERROR','[' || SQLERRM || ']');
	 app_exception.raise_exception;
   END val_neg_exists_for_line_type;


END PON_SOURCING_API_GRP;

/
