--------------------------------------------------------
--  DDL for Package OKS_CCMIGRATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_CCMIGRATE_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKSCMIGS.pls 120.4 2005/11/18 18:27 hvaladip noship $ */

	---------------------------------------------------------------------------
	 -- GLOBAL EXCEPTIONS

	---------------------------------------------------------------------------
	 G_EXCEPTION_HALT_VALIDATION     EXCEPTION;


	---------------------------------------------------------------------------
	 -- GLOBAL VARIABLES

	---------------------------------------------------------------------------
	 G_PKG_NAME            CONSTANT VARCHAR2(200) := 'OKS_rule_report';
	 G_APP_NAME            CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;


	---------------------------------------------------------------------------
	 -- Procedures and Functions

	---------------------------------------------------------------------------

	Procedure Generate_report
	(
	   ERRBUF    OUT NOCOPY VARCHAR2,
	   RETCODE    OUT NOCOPY NUMBER
	);

  PROCEDURE MIGRATE_CC (
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    P_SUB_REQUESTS    IN NUMBER,
    P_BATCH_SIZE      IN NUMBER);

    PROCEDURE MIGRATE_CC_HDR(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER );

   PROCEDURE MIGRATE_CC_LINE(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER );

    PROCEDURE MIGRATE_CC_LINEH(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER );


   PROCEDURE MIGRATE_CC_HDRH(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER );

Procedure Purge_CC_Number
(
	ERRBUF	OUT NOCOPY VARCHAR2,
	RETCODE	OUT NOCOPY NUMBER,
      P_BATCH_SIZE      IN NUMBER
);

PROCEDURE UPDATE_CC_LINEH(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER );
PROCEDURE UPDATE_CC_HEADERH(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER );

PROCEDURE UPDATE_CC_HEADER(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER );
PROCEDURE UPDATE_CC_HEADER_RULE(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER );
PROCEDURE UPDATE_CC_LINE(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER );


END OKS_CCMIGRATE_PVT; --  Package spec

 

/
