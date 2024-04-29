--------------------------------------------------------
--  DDL for Package IEX_DUNNING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_DUNNING_PUB" AUTHID CURRENT_USER AS
/* $Header: iexpduns.pls 120.9.12010000.8 2010/05/12 17:44:32 gnramasa ship $ */


  -- clchang added new column XDO_TEMPLATE_ID for 11.5.11

  TYPE AG_DN_XREF_REC_TYPE IS RECORD (
    AG_DN_XREF_ID          NUMBER        ,
    aging_bucket_id        NUMBER        ,
    aging_bucket_line_id   NUMBER        ,
    callback_flag          VARCHAR2(1)   ,
    callback_days          NUMBER        ,
    FM_METHOD              VARCHAR2(10)  ,
    template_id            NUMBER        ,
    xdo_template_id        NUMBER        ,
    score_RANGE_LOW        NUMBER        ,
    score_RANGE_HIGH       NUMBER        ,
    DUNNING_LEVEL          VARCHAR2(30)  ,
    OBJECT_VERSION_NUMBER  NUMBER        ,
    LAST_UPDATE_DATE       DATE          ,
    LAST_UPDATED_BY        NUMBER        ,
    CREATION_DATE          DATE          ,
    CREATED_BY             NUMBER        ,
    LAST_UPDATE_LOGIN      NUMBER        );

  TYPE AG_DN_XREF_TBL_TYPE is Table of AG_DN_XREF_REC_TYPE
					  index by binary_integer;


  TYPE AG_DN_XREF_ID_TBL_TYPE is Table of NUMBER index by binary_integer;

    G_MISS_AG_DN_XREF_REC          IEX_DUNNING_PUB.AG_DN_XREF_REC_TYPE;
    G_MISS_AG_DN_XREF_TBL          IEX_DUNNING_PUB.AG_DN_XREF_TBL_TYPE;
    G_MISS_AG_DN_XREF_ID_TBL       IEX_DUNNING_PUB.AG_DN_XREF_ID_TBL_TYPE;


  -- clchang added new column XML_REQUEST_ID, XML_TEMPLATE_ID for 11.5.11
  TYPE DUNNING_REC_TYPE IS RECORD (
    DUNNING_ID             NUMBER        ,
    TEMPLATE_ID            NUMBER        ,
    callback_yn            VARCHAR2(1)   ,
    callback_date          DATE          ,
    STATUS                 VARCHAR2(240) ,
    CAMPAIGN_SCHED_ID      NUMBER        ,
    DELINQUENCY_ID         NUMBER        ,
    FFM_REQUEST_ID         NUMBER        ,
    XML_REQUEST_ID         NUMBER        ,
    XML_TEMPLATE_ID        NUMBER        ,
    OBJECT_ID              NUMBER        ,
    OBJECT_TYPE            VARCHAR2(30)  ,
    DUNNING_LEVEL          VARCHAR2(30)  ,
    DUNNING_OBJECT_ID      NUMBER        ,
    DUNNING_METHOD         VARCHAR2(30)  ,
    AMOUNT_DUE_REMAINING   NUMBER        ,
    CURRENCY_CODE          VARCHAR2(15)  ,
    LAST_UPDATE_DATE       DATE          ,
    LAST_UPDATED_BY        NUMBER        ,
    CREATION_DATE          DATE          ,
    CREATED_BY             NUMBER        ,
    LAST_UPDATE_LOGIN      NUMBER        ,
    FINANCIAL_CHARGE       NUMBER        ,
    LETTER_NAME            VARCHAR2(30)  ,
    INTEREST_AMT           NUMBER        ,
    dunning_plan_id        number        ,
    contact_destination    varchar2(240) ,
    contact_party_id       number        ,
    REQUEST_ID             NUMBER        ,   -- added by gnramasa for bug 5661324 14-Mar-07
    DELIVERY_STATUS        VARCHAR2(30)  ,   -- added by gnramasa for bug 5661324 14-Mar-07
    PARENT_DUNNING_ID      NUMBER        ,   -- added by gnramasa for bug 5661324 14-Mar-07
    DUNNING_MODE	   VARCHAR2(10)  ,   -- added by gnramasa for bug 8489610 14-May-09
    CONFIRMATION_MODE	   VARCHAR2(10)  ,   -- added by gnramasa for bug 8489610 14-May-09
    org_id                 number        ,   -- added for bug 9151851
    AG_DN_XREF_ID          NUMBER        ,   -- added by gnramasa for bug 9326376 2-Feb-10
    CORRESPONDENCE_DATE    DATE              -- added by gnramasa for bug 9326376 2-Feb-10
  );

  G_MISS_DUNNING_REC     IEX_DUNNING_PUB.DUNNING_REC_TYPE;

  TYPE DUNNING_TBL_TYPE is Table of DUNNING_REC_TYPE
                           index by binary_integer;

  TYPE DelId_NumList is Table of Number;


Procedure Create_AG_DN_XREF
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_AG_DN_XREF_TBL          IN IEX_DUNNING_PUB.AG_DN_XREF_TBL_TYPE  ,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            x_AG_DN_XREF_ID_TBL       OUT NOCOPY IEX_DUNNING_PUB.AG_DN_XREF_ID_TBL_TYPE);


Procedure Update_AG_DN_XREF
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_AG_DN_XREF_TBL          IN IEX_DUNNING_PUB.AG_DN_XREF_TBL_TYPE  ,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);



Procedure Delete_AG_DN_XREF
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_AG_DN_XREF_ID           IN NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);




Procedure Send_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_running_level           IN VARCHAR2,
	    p_parent_request_id       IN NUMBER,  -- added by gnramasa for bug 5661324 14-Mar-07
            p_dunning_plan_id         in number,
	    p_correspondence_date     IN DATE,    -- added by gnramasa for bug 9326376 2-Feb-10
	    p_dunning_mode	      IN VARCHAR2,     -- added by gnramasa for bug 8489610 14-May-09
	    p_process_err_rec_only    IN VARCHAR2,     -- added by gnramasa for bug 8489610 14-May-09
	    p_no_of_workers           IN number := 1,  -- added by gnramasa for bug 8489610 14-May-09
	    p_single_staged_letter    IN VARCHAR2 DEFAULT 'N',    -- added by gnramasa for bug 9326376 2-Feb-10
	    p_customer_name_low       IN VARCHAR2,
	    p_customer_name_high      IN VARCHAR2,
	    p_account_number_low      IN VARCHAR2,
	    p_account_number_high     IN VARCHAR2,
	    p_billto_location_low     IN VARCHAR2,
	    p_billto_location_high    IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);



/*=====================================================================
  clchang updated 10/02/2002 - no CloseDunning in 115.9

PROCEDURE Close_Dunning
           (p_api_version             IN NUMBER,
            p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
            p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
            --p_delinquencies_tbl       IN IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE
            --                          := IEX_DELINQUENCY_PUB.G_MISS_DELINQUENCY_TBL,
            p_delinquencies_tbl       IN DelId_NumList,
            p_security_check          IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);
*======================================================================*/


Procedure Daily_Dunning
           (p_api_version             IN NUMBER :=1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            --p_dunning_tbl             IN IEX_DUNNING_PUB.DUNNING_TBL_TYPE,
            p_running_level           IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);


PROCEDURE CALLBACK_CONCUR(
            ERRBUF      OUT NOCOPY     VARCHAR2,
            RETCODE     OUT NOCOPY     VARCHAR2,
            P_ORG_ID    IN NUMBER DEFAULT NULL); --Added for MOAC


PROCEDURE SEND_DUNNING_CONCUR(
            ERRBUF      OUT NOCOPY     VARCHAR2,
            RETCODE     OUT NOCOPY     VARCHAR2,
            dunning_plan_id            NUMBER,
	    p_staged_dunning_dummy  IN   VARCHAR2,	-- added by gnramasa for bug 9326376 2-Feb-10
	    p_correspondence_date   IN   VARCHAR2,	-- added by gnramasa for bug 9326376 2-Feb-10
	    p_parent_request_id     IN   NUMBER,  -- added by gnramasa for bug 5661324 14-Mar-07
	    p_dunning_mode          IN   VARCHAR2 DEFAULT 'FINAL',  -- added by gnramasa for bug 8489610 14-May-09
	    p_process_err_dummy     IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 14-May-09
	    p_process_err_rec_only  IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 14-May-09
	    p_no_of_workers         IN   number := 1,               -- added by gnramasa for bug 8489610 14-May-09
	    p_single_staged_letter  IN   VARCHAR2 DEFAULT 'N',      -- added by gnramasa for bug 9326376 2-Feb-10
	    p_coll_bus_level_dummy  IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    p_customer_name_low     IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    p_customer_name_high    IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    --p_account_number_dummy  IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    p_account_number_low    IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    p_account_number_high   IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    p_billto_location_dummy IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    p_billto_location_low   IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    p_billto_location_high  IN   VARCHAR2);                 -- added by gnramasa for bug 8489610 28-May-09

--Added for bug 9582646 gnramasa 5th May 10
PROCEDURE STG_DUNNING_MIG_CONCUR(
            ERRBUF      OUT NOCOPY     VARCHAR2,
            RETCODE     OUT NOCOPY     VARCHAR2,
	    p_migration_mode   IN   VARCHAR2 DEFAULT 'FINAL');


END IEX_DUNNING_PUB;

/
