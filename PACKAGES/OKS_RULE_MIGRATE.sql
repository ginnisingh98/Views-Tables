--------------------------------------------------------
--  DDL for Package OKS_RULE_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_RULE_MIGRATE" AUTHID CURRENT_USER AS
/* $Header: OKSRMIGS.pls 120.0 2005/05/25 18:30:57 appldev noship $ */

---------------------------------------------------------------
--- The following procedures are for validation phase.  -------
---------------------------------------------------------------

PROCEDURE UPDATE_RULE_RECORD(
     P_ID                 IN NUMBER,
     P_COLUMN_NAME        IN VARCHAR2,
     P_NEW_VALUE          IN VARCHAR2,
     P_CURRENT_VALUE      IN VARCHAR2,
     P_RULE_INFO_CATEGORY IN VARCHAR2,
     P_ROW_ID             IN VARCHAR2,
     P_MAJOR_VERSION      IN NUMBER,
     X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
     X_ERROR_MSG          OUT NOCOPY VARCHAR2);

FUNCTION GET_DATA_VOLUME RETURN NUMBER ;

Procedure Validate_data1 (
    ERRBUF            OUT NOCOPY VARCHAR2,
    RETCODE           OUT NOCOPY NUMBER,
    P_STATUS          IN  VARCHAR2,
    P_ORG_ID          IN  NUMBER,
    P_LEVEL           IN  VARCHAR2,
    P_SUB_REQUESTS    IN  NUMBER,
    P_BATCH_SIZE      IN  NUMBER );

Procedure VALIDATE_HDR_RULE
   (ERRBUF            OUT NOCOPY VARCHAR2,
    RETCODE           OUT NOCOPY NUMBER,
    p_status          in VARCHAR2,
    p_org_id          in NUMBER ,
    p_batch_size      in NUMBER,
    p_us_yn           in VARCHAR2,
    p_id_low          in NUMBER,
    p_id_hig          in NUMBER );

Procedure VALIDATE_HDR_HIST_RULE
   (ERRBUF            OUT NOCOPY VARCHAR2,
    RETCODE           OUT NOCOPY NUMBER,
    p_status          in VARCHAR2,
    p_org_id          in NUMBER ,
    p_batch_size      in NUMBER,
    p_us_yn           in VARCHAR2,
    p_id_low          in NUMBER,
    p_id_hig          in NUMBER );

Procedure VALIDATE_LINE_RULE(
    ERRBUF            OUT NOCOPY VARCHAR2 ,
    RETCODE           OUT NOCOPY NUMBER ,
    p_status          in VARCHAR2,
    p_org_id          in NUMBER ,
    p_batch_size      in NUMBER,
    p_us_yn           in VARCHAR2,
    p_id_low          in NUMBER,
    p_id_hig          in NUMBER);

Procedure VALIDATE_LINE_HIST_RULE(
    ERRBUF            OUT NOCOPY VARCHAR2 ,
    RETCODE           OUT NOCOPY NUMBER ,
    p_status          in VARCHAR2,
    p_org_id          in NUMBER ,
    p_batch_size      in NUMBER,
    p_us_yn           in VARCHAR2,
    p_id_low          in NUMBER,
    p_id_hig          in NUMBER);

Procedure VALIDATE_ALLH_RULE(
     ERRBUF            OUT NOCOPY VARCHAR2 ,
     RETCODE           OUT NOCOPY NUMBER ,
     p_status          in VARCHAR2,
     p_org_id          in NUMBER ,
     p_batch_size      in NUMBER,
     p_us_yn           in VARCHAR2,
     p_id_low          in NUMBER,
     p_id_hig          in NUMBER) ;

Procedure VALIDATE_ALL_RULE(
     ERRBUF            OUT NOCOPY VARCHAR2 ,
     RETCODE           OUT NOCOPY NUMBER ,
     p_status          in VARCHAR2,
     p_org_id          in NUMBER ,
     p_batch_size      in NUMBER,
     p_us_yn           in VARCHAR2,
     p_id_low          in NUMBER,
     p_id_hig          in NUMBER) ;

----------------------------------------------------------
--The following procedures are for synchronization &    --
--reprocessing.                                         --
----------------------------------------------------------
Procedure REPROCESS_HDR_RULE(
    prow_id           in ROWID ,
    p_id              in NUMBER ,
    p_us_yn           in BOOLEAN,
    x_return_status            out NOCOPY VARCHAR2);

Procedure REPROCESS_HDR_HIST_RULE(
    prow_id           in ROWID ,
    p_id              in NUMBER ,
    p_major_version   in NUMBER ,
    p_us_yn           in BOOLEAN,
    x_return_status            out NOCOPY VARCHAR2);

Procedure REPROCESS_LINE_RULE(
    prow_id           in ROWID ,
    p_id              in NUMBER ,
    p_us_yn           in BOOLEAN,
    x_return_status            out NOCOPY VARCHAR2);

Procedure REPROCESS_LINE_HIST_RULE(
    prow_id           in ROWID ,
    p_id              in NUMBER ,
    p_major_version   in NUMBER ,
    p_us_yn           in BOOLEAN,
    x_return_status            out NOCOPY VARCHAR2);


PROCEDURE SYNCHRONIZE_RULE_DATA_SUBREQ(
    ERRBUF            OUT NOCOPY VARCHAR2,
    RETCODE           OUT NOCOPY NUMBER,
    P_BATCH_SIZE      IN NUMBER,
    P_ID_LOW          IN  NUMBER,
    P_ID_HI           IN  NUMBER );

PROCEDURE REPROCESS_RULE_DATA_SUBREQ(
    ERRBUF            OUT NOCOPY VARCHAR2,
    RETCODE           OUT NOCOPY NUMBER,
    P_BATCH_SIZE      IN NUMBER,
    P_ID_LOW          IN  NUMBER,
    P_ID_HI           IN  NUMBER );

PROCEDURE SYNCHRONIZE_RULE_HDR(
    P_RGP_ID          IN NUMBER,
    P_CHR_ID          IN NUMBER,
    p_us_yn           in BOOLEAN,
    x_return_status            out NOCOPY VARCHAR2);

PROCEDURE SYNCHRONIZE_RULE_LINE(
    P_RGP_ID          IN NUMBER,
    P_CLE_ID           IN NUMBER,
    DNZ_CHR_ID         IN NUMBER,
    p_us_yn           in BOOLEAN,
    x_return_status            out NOCOPY VARCHAR2);

PROCEDURE SYNCHRONIZE_RULE_LINEH(
    P_RGP_ID          IN NUMBER,
    P_CLE_ID           IN NUMBER,
    DNZ_CHR_ID         IN NUMBER,
    p_major_version   in NUMBER ,
    p_us_yn           in BOOLEAN,
    x_return_status            out NOCOPY VARCHAR2);

PROCEDURE SYNCHRONIZE_RULE_HDRH(
    P_RGP_ID          IN NUMBER,
    P_CHR_ID          IN NUMBER,
    p_major_version   in NUMBER ,
    p_us_yn           in BOOLEAN,
    x_return_status   out NOCOPY VARCHAR2);

Procedure REPROCESS_SYNCHL_RULE (
    prow_id           in ROWID
   ,p_id              in NUMBER
   ,p_major_version_number in NUMBER
   ,p_us_yn           in BOOLEAN
   ,x_return_status   OUT NOCOPY VARCHAR2 );

Procedure REPROCESS_OKSLEVEL (
    prow_id           in ROWID
   ,p_id              in NUMBER
   ,p_major_version_number in NUMBER
   ,p_us_yn           in BOOLEAN
   ,x_return_status   OUT NOCOPY VARCHAR2 );

Procedure SYNCHRONIZE_RULE_CVR(
		P_RGP_ID IN NUMBER,
		P_CLE_ID IN NUMBER,
		P_DNZ_CHR_ID IN NUMBER,
		P_MAJOR_VERSION IN NUMBER,
		X_RETURN_STATUS OUT NOCOPY VARCHAR2);

Procedure SYNCHRONIZE_RULE_ATM(
		P_RGP_ID IN NUMBER,
		P_CLE_ID IN NUMBER,
		P_DNZ_CHR_ID IN NUMBER,
		X_RETURN_STATUS OUT NOCOPY VARCHAR2);

Procedure SYNCHRONIZE_RULE_ATMH(
		P_RGP_ID IN NUMBER,
		P_CLE_ID IN NUMBER,
		P_DNZ_CHR_ID IN NUMBER,
		P_MAJOR_VERSION IN NUMBER,
		X_RETURN_STATUS OUT NOCOPY VARCHAR2);

Procedure SYNCHRONIZE_RULE_PML(
		P_RGP_ID IN NUMBER,
		P_CLE_ID IN NUMBER,
		P_DNZ_CHR_ID IN NUMBER,
		X_RETURN_STATUS OUT NOCOPY VARCHAR2);

Procedure SYNCHRONIZE_RULE_SLL(
                P_RGP_ID IN NUMBER,
		P_CLE_ID IN NUMBER,
                P_US_YN  IN BOOLEAN,
		X_RETURN_STATUS OUT NOCOPY VARCHAR2) ;

Procedure SYNCHRONIZE_RULE_SLLH(
                P_RGP_ID IN NUMBER,
		P_CHR_ID IN NUMBER,
                P_US_YN  IN BOOLEAN,
		X_RETURN_STATUS OUT NOCOPY VARCHAR2) ;

PROCEDURE SYNCHRONIZE_REPROC_RULE_DATA(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    P_SUB_REQUESTS    IN NUMBER,
    P_BATCH_SIZE      IN NUMBER );

PROCEDURE SYNCHRONIZE_RULE_OFS(
	P_RGP_ID IN NUMBER,
	P_CLE_ID IN NUMBER,
	P_DNZ_CHR_ID IN NUMBER,
	P_MAJOR_VERSION IN NUMBER,
	X_RETURN_STATUS OUT NOCOPY VARCHAR2);


END OKS_RULE_MIGRATE;


 

/
