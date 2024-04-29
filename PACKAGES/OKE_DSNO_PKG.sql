--------------------------------------------------------
--  DDL for Package OKE_DSNO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DSNO_PKG" AUTHID CURRENT_USER AS
/* $Header: OKEDSNOS.pls 120.0 2005/05/25 17:30:51 appldev noship $ */

TYPE oke_hdr_rec_type IS RECORD(
   DELIVERY_ID                NUMBER
   ,SOURCE_HEADER_ID           NUMBER);

TYPE oke_pmt_rec_type IS RECORD(
   PAYMENT_TERM_NAME             VARCHAR2(80));


TYPE oke_curr_rec_type IS RECORD(
   CURRENCY_CODE                 VARCHAR2(80));

TYPE oke_billto_rec_type IS RECORD(
   BILL_TO_SITE_USE_ID          NUMBER);

PROCEDURE GET_OKE_K_TERM_VALUE ( p_oke_hdr_rec IN oke_hdr_rec_type,  x_oke_pmt_rec OUT NOCOPY oke_pmt_rec_type );

PROCEDURE GET_OKE_K_PARTY ( p_oke_hdr_rec IN oke_hdr_rec_type, x_billto_rec OUT NOCOPY oke_billto_rec_type );

PROCEDURE GET_OKE_CURRENCY_CODE ( p_oke_hdr_rec IN oke_hdr_rec_type,  x_oke_curr_rec OUT NOCOPY oke_curr_rec_type );

END;



 

/
