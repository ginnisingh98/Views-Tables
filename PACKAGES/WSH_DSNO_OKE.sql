--------------------------------------------------------
--  DDL for Package WSH_DSNO_OKE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DSNO_OKE" AUTHID CURRENT_USER as
/* $Header: WSHDOKES.pls 120.1 2005/07/15 15:32:26 bsadri noship $ */
  --
  -- FUNCTION :         GET_OKE_TERM_VALUE
  -- Purpose:           get payment terms info for DSNO from OKE
  -- Arguments:         delivery_detail_id
  --      source_header_id
  -- Description:
  --
  -- FUNCTION:         GET_OKE_PARTY
  -- Purpose:           get party info for DSNO from OKE
  -- Arguments:         delivery_id
  --      source_header_id

  -- FUNCTION:         GET_OKE_CURRENCY_CODE
  -- Purpose:          get currency code for DSNO from OKE
  -- Arguments:        delivery_id
  --                   source_header_id

FUNCTION  GET_OKE_PARTY(delivery_detail_id_in NUMBER , source_header_id_in NUMBER) return NUMBER;

FUNCTION  GET_OKE_TERM_VALUE(delivery_id_in NUMBER , source_header_id_in NUMBER) return VARCHAR2;

FUNCTION  GET_OKE_CURRENCY_CODE(delivery_id_in NUMBER, source_header_id_in NUMBER) return VARCHAR2;
END WSH_DSNO_OKE;

 

/
