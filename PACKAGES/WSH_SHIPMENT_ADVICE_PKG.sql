--------------------------------------------------------
--  DDL for Package WSH_SHIPMENT_ADVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SHIPMENT_ADVICE_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHSAPKS.pls 120.0.12010000.1 2010/02/25 17:02:20 sankarun noship $ */

--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Shipment_Advice_Inbound
--
-- PARAMETERS:
--       errbuf                 => Message returned to Concurrent Manager
--       retcode                => Code (0, 1, 2) returned to Concurrent Manager
--       p_transaction_status   => Either AP, ER, NULL
--	     p_from_document_number => From Document Number
--       p_to_document_number   => To Document Number
--       p_from_creation_date   => From Creation Date
--       p_to_creation_date     => To Creation Date
--       p_transaction_id       => Transacation id to be processed
--       p_log_level            => Either 1(Debug), 0(No Debug)
-- COMMENT:
--       API will be invoked from Concurrent Manager whenever concurrent program
--       'Process Shipment Advices' is triggered.
--=============================================================================
--
   PROCEDURE Shipment_Advice_Inbound (
             errbuf                 OUT NOCOPY   VARCHAR2,
             retcode                OUT NOCOPY   NUMBER,
             p_transaction_status   IN  VARCHAR2,
             p_from_document_number IN  VARCHAR2,
             p_to_document_number   IN  VARCHAR2,
             p_from_creation_date   IN  VARCHAR2,
             p_to_creation_date     IN  VARCHAR2,
             p_transaction_id       IN  NUMBER,
             p_log_level            IN  NUMBER );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Process_Shipment_Advice
--
-- PARAMETERS:
--       p_commit_flag          => Either FND_API.G_TRUE, FND_API.G_FALSE
--       p_transaction_status   => Either AP, ER, NULL
--	     p_from_document_number => From Document Number
--       p_to_document_number   => To Document Number
--       p_from_creation_date   => From Creation Date
--       p_to_creation_date     => To Creation Date
--       p_transaction_id       => Transacation id to be processed
--       x_return_status        => Return Status of API (S,W,E,U)
-- COMMENT:
--       Based on input parameter values, eligble records for processing are
--       queried from WTH table.
--       Calling API WSH_PROCESS_INTERFACED_PKG.Process_Inbound to process the
--       eligible records queried from WTH table.
--=============================================================================
--
   PROCEDURE Process_Shipment_Advice (
             p_commit_flag          IN  VARCHAR2,
             p_transaction_status   IN  VARCHAR2,
             p_from_document_number IN  VARCHAR2,
             p_to_document_number   IN  VARCHAR2,
             p_from_creation_date   IN  VARCHAR2,
             p_to_creation_date     IN  VARCHAR2,
             p_transaction_id       IN  NUMBER,
             x_return_status        OUT NOCOPY VARCHAR2 );

END WSH_SHIPMENT_ADVICE_PKG;

/
