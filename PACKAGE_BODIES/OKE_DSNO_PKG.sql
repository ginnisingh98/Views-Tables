--------------------------------------------------------
--  DDL for Package Body OKE_DSNO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DSNO_PKG" AS
/* $Header: OKEDSNOB.pls 120.3 2005/07/27 10:21:45 ausmani noship $ */

--
-- Global Declarations
--

--
-- Public Procedures and Functions
--
--
PROCEDURE GET_OKE_K_PARTY ( p_oke_hdr_rec  oke_hdr_rec_type, x_billto_rec OUT NOCOPY oke_billto_rec_type ) IS

  l_site_use_id NUMBER;
  l_delivery_id NUMBER;
  l_oke_id NUMBER;

  CURSOR oke_c ( p_delivery_id NUMBER, p_oke_id NUMBER ) IS
  SELECT w.source_line_id
  FROM wsh_delivery_details w, wsh_delivery_assignments_v a
  WHERE a.delivery_id = p_delivery_id
  AND w.source_code = 'OKE'
  AND w.delivery_detail_id = a.delivery_detail_id
  AND w.source_header_id = p_oke_id;


BEGIN

  FOR oke_rec in oke_c ( p_oke_hdr_rec.delivery_id, p_oke_hdr_rec.source_header_id ) LOOP



    IF l_site_use_id > 0 THEN

      IF l_site_use_id <> OKE_DELIVERABLE_UTILS.Get_Party(oke_rec.source_line_id, 'BILL_TO') THEN

	l_site_use_id := null;
        exit;

      END IF;

    ELSE

      l_site_use_id := OKE_DELIVERABLE_UTILS.Get_Party(oke_rec.source_line_id, 'BILL_TO');

    END IF;

  END LOOP;

  x_billto_rec.bill_to_site_use_id := L_site_use_id;



END GET_OKE_K_PARTY;


PROCEDURE GET_OKE_K_TERM_VALUE ( p_oke_hdr_rec  oke_hdr_rec_type, x_oke_pmt_rec OUT NOCOPY oke_pmt_rec_type ) IS
  l_term_name VARCHAR2(80);
  l_delivery_id NUMBER;
  l_oke_id NUMBER;

  CURSOR oke_c ( p_delivery_id NUMBER, p_oke_id NUMBER ) IS
  SELECT w.source_line_id
  FROM wsh_delivery_details w, wsh_delivery_assignments_v a
  WHERE a.delivery_id = p_delivery_id
  AND w.source_code = 'OKE'
  AND w.delivery_detail_id = a.delivery_detail_id
  AND w.source_header_id = p_oke_id;

BEGIN

  FOR oke_rec in oke_c ( p_oke_hdr_rec.delivery_id, p_oke_hdr_rec.source_header_id ) LOOP

    l_term_name :=  OKE_DELIVERABLE_UTILS.Get_Term_Value( oke_rec.source_line_id, 'RA_PAYMENT_TERMS' );

    IF x_oke_pmt_rec.payment_term_name IS NOT NULL THEN

      IF  l_term_name <> x_oke_pmt_rec.payment_term_name THEN

        x_oke_pmt_rec.payment_term_name := null;
	EXIT;

      END IF;

    ELSE

      x_oke_pmt_rec.payment_term_name := l_term_name;

    END IF;

  END LOOP;

END GET_OKE_K_TERM_VALUE;

PROCEDURE GET_OKE_CURRENCY_CODE ( p_oke_hdr_rec IN oke_hdr_rec_type,  x_oke_curr_rec OUT NOCOPY oke_curr_rec_type ) IS
    l_currency_code varchar2(80);

    CURSOR c_curr (p_deliverable_id number) IS
    SELECT currency_code
    FROM  oke_k_deliverables_b
    WHERE  deliverable_id=p_deliverable_id;

    CURSOR oke_c ( p_delivery_id NUMBER, p_oke_id NUMBER ) IS
    SELECT w.source_line_id
    FROM wsh_delivery_details w, wsh_delivery_assignments_v a
    WHERE a.delivery_id = p_delivery_id
    AND w.source_code = 'OKE'
    AND w.delivery_detail_id = a.delivery_detail_id
    AND w.source_header_id = p_oke_id;

BEGIN
    FOR oke_rec in oke_c ( p_oke_hdr_rec.delivery_id, p_oke_hdr_rec.source_header_id ) LOOP

      open c_curr(oke_rec.source_line_id);
      fetch c_curr into l_currency_code;
      close c_curr;

      IF x_oke_curr_rec.currency_code IS NOT NULL THEN

          IF  l_currency_code <> x_oke_curr_rec.currency_code THEN

               x_oke_curr_rec.currency_code := null;
	           EXIT;

          END IF;

      ELSE
        x_oke_curr_rec.currency_code := l_currency_code;
      END IF;

    END LOOP;

END GET_OKE_CURRENCY_CODE;

END OKE_DSNO_PKG;

/
