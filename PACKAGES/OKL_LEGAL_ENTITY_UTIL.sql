--------------------------------------------------------
--  DDL for Package OKL_LEGAL_ENTITY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEGAL_ENTITY_UTIL" AUTHID CURRENT_USER AS
/* $Header: OKLRXLES.pls 120.2 2006/11/17 12:46:22 kthiruva noship $ */

SUBTYPE legal_entity_rec IS XLE_UTILITIES_GRP.LegalEntity_Rec;

  PROCEDURE get_legal_entity_info
               (p_legal_entity_id IN NUMBER,
                x_legal_entity_rec OUT NOCOPY legal_entity_rec,
                x_return_status  OUT NOCOPY VARCHAR2,
                x_msg_data       OUT NOCOPY VARCHAR2,
                x_msg_count      OUT NOCOPY NUMBER);

  FUNCTION get_legal_entity_name(p_legal_entity_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION get_khr_le_id (p_khr_id IN NUMBER) RETURN NUMBER;
  FUNCTION get_khr_line_le_id (p_kle_id IN NUMBER) RETURN NUMBER;
  FUNCTION check_le_id_exists (p_le_id IN NUMBER) RETURN NUMBER;

END OKL_LEGAL_ENTITY_UTIL;

/
