--------------------------------------------------------
--  DDL for Package Body OKL_XMLGEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_XMLGEN_PVT" AS
/* $Header: OKLXMLGB.pls 120.0 2006/05/26 15:07:23 pagarg noship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_xmlgen_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_EXCEPTION_ON BOOLEAN;
    G_IS_DEBUG_ERROR_ON BOOLEAN;
    G_IS_DEBUG_PROCEDURE_ON BOOLEAN;

    FUNCTION generate_xmldocument(p_document_id IN NUMBER)
    RETURN CLOB
    IS
      CURSOR c_tp IS
      SELECT tp.tp_header_id, tp.party_site_id, tp.party_type
        FROM ecx_tp_headers tp
           , hz_parties p
       WHERE tp.party_id = p.party_id
         AND p.party_name = 'SuperTrump';

      CURSOR c_tt (b_transaction_number NUMBER) IS
      SELECT t.ext_subtype, m.map_code, o.object_type
        FROM ecx_tp_details_v t
           , ecx_mappings m
           , ecx_objects o
           , okl_stream_interfaces si
       WHERE t.transaction_type = 'OKL_ST'
         AND t.transaction_subtype = si.deal_type
         AND m.map_id = t.map_id
         AND o.map_id = m.map_id
         AND o.object_id = m.object_id_target
         AND si.transaction_number = b_transaction_number;

      rec  c_tp%ROWTYPE;
      rec2 c_tt%ROWTYPE;

      l_xmldoc clob;

      l_api_name CONSTANT VARCHAR2(30) := 'generate_xmldocument';
      l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||p_document_id;

    BEGIN
      IF(G_IS_DEBUG_PROCEDURE_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_document_id||': begin okl_xmlgen_pvt.generate_xmldocument');
      END IF;

      OPEN c_tp;
      FETCH c_tp INTO rec;
      CLOSE c_tp;

      OPEN c_tt(p_document_id);
      FETCH c_tt INTO rec2;
      CLOSE c_tt;

      IF(G_IS_DEBUG_PROCEDURE_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_document_id||': Transaction Subtype = '||rec2.ext_subtype);
      END IF;

      IF(G_IS_DEBUG_PROCEDURE_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_document_id||': Map Code = '||rec2.map_code);
      END IF;

      ecx_outbound.process_outbound_documents
      (i_message_standard    => 'W3C',
       i_transaction_type    => 'OKL_ST',
       i_transaction_subtype => rec2.ext_subtype, -- ex. LEASE_BOOKING
       i_tp_id               => rec.tp_header_id,
       i_tp_site_id          => rec.party_site_id,
       i_tp_type             => rec.party_type,
       i_document_id         => p_document_id,
       i_map_code            => rec2.map_code, --ex. 'OKL_STLEASEBOOKING_W3C10_OUT',
       i_xmldoc              => l_xmldoc,
       i_message_type        => rec2.object_type -- 'XML'
      );

      IF(G_IS_DEBUG_PROCEDURE_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_document_id||': end okl_xmlgen_pvt.generate_xmldocument');
      END IF;

      RETURN l_xmldoc;
    END generate_xmldocument;

END OKL_XMLGEN_PVT;

/
