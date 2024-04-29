--------------------------------------------------------
--  DDL for Package Body WSH_DSNO_OKE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DSNO_OKE" as
/* $Header: WSHDOKEB.pls 120.1 2005/07/15 15:33:13 bsadri noship $ */

--
-- FUNCTION:          GET_OKE_CURRENCY_CODE
-- Purpose:           get currency code for DSNO from OKE
-- Arguments:         delivery_id
--                    source_header_id
-- Description:       returns currency code (char)

--
-- FUNCTION :         GET_OKE_TERM_VALUE
-- Purpose:           get payment terms info for DSNO from OKE
-- Arguments:         delivery_id
--          source_header_id
-- Description:       returns payment term name (char)

--
-- PROCEDURE:         GET_OKE_PARTY
-- Purpose:           get party info for DSNO from OKE
-- Arguments:         delivery_detail_id -
--          source_header_id
-- Description:       returns bill_to_site_use_id (number)

FUNCTION GET_OKE_PARTY ( delivery_detail_id_in NUMBER, source_header_id_in NUMBER ) return NUMBER IS

x_bill_to_site_use_id number;
x_hdr_rec oke_dsno_pkg.oke_hdr_rec_type;
x_billto_rec oke_dsno_pkg.oke_billto_rec_type;
x_delivery_id number;


CURSOR del_details ( p_delivery_detail_id NUMBER ) IS
  SELECT a.delivery_id
  FROM wsh_delivery_details w, wsh_delivery_assignments_v a
  WHERE w.delivery_detail_id = p_delivery_detail_id
  AND w.source_code = 'OKE'
  AND w.delivery_detail_id = a.delivery_detail_id;

BEGIN

  OPEN  del_details (delivery_detail_id_in);
  FETCH del_details INTO x_delivery_id;
  CLOSE del_details;

  x_hdr_rec.delivery_id := x_delivery_id;
  x_hdr_rec.source_header_id := source_header_id_in;

  oke_dsno_pkg.get_oke_k_party(
    p_oke_hdr_rec      => x_hdr_rec,
    x_billto_rec     => x_billto_rec);

  x_bill_to_site_use_id :=  x_billto_rec.bill_to_site_use_id;
  return x_bill_to_site_use_id;

END GET_OKE_PARTY;


FUNCTION  GET_OKE_TERM_VALUE (delivery_id_in NUMBER , source_header_id_in NUMBER) return VARCHAR2 IS

payment_term_name_x varchar2(80);
x_hdr_rec oke_dsno_pkg.oke_hdr_rec_type;
x_pmt_rec oke_dsno_pkg.oke_pmt_rec_type;

BEGIN
  x_hdr_rec.delivery_id := delivery_id_in;
  x_hdr_rec.source_header_id := source_header_id_in;

  oke_dsno_pkg.get_oke_k_term_value(
    p_oke_hdr_rec      => x_hdr_rec,
    x_oke_pmt_rec    => x_pmt_rec);

  payment_term_name_x :=  x_pmt_rec.payment_term_name;

  return payment_term_name_x;

END GET_OKE_TERM_VALUE;

FUNCTION GET_OKE_CURRENCY_CODE (delivery_id_in NUMBER, source_header_id_in NUMBER) return VARCHAR2 IS
    x_curr_rec oke_dsno_pkg.oke_curr_rec_type;
    x_hdr_rec  oke_dsno_pkg.oke_hdr_rec_type;
    currency_code_x varchar2(15);
BEGIN

    x_hdr_rec.delivery_id := delivery_id_in;
    x_hdr_rec.source_header_id := source_header_id_in;

    oke_dsno_pkg.get_oke_currency_code(
      p_oke_hdr_rec     => x_hdr_rec,
      x_oke_curr_rec    => x_curr_rec);

    currency_code_x := x_curr_rec.currency_code;

    return currency_code_x;

END GET_OKE_CURRENCY_CODE;
END WSH_DSNO_OKE;

/
