--------------------------------------------------------
--  DDL for Package IEX_STRATEGY_TYPE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRATEGY_TYPE_PUB" AUTHID CURRENT_USER AS
/* $Header: iexpstts.pls 120.0 2004/01/24 03:20:06 appldev noship $ */


    TYPE STRY_CNT_REC_TYPE IS RECORD (
        DELINQUENCY_ID          NUMBER,
        PARTY_CUST_ID           NUMBER,
        CUST_ACCOUNT_id         NUMBER,
        TRANSACTION_ID          NUMBER,
        PAYMENT_SCHEDULE_ID     NUMBER,
        SCORE_VALUE             NUMBER,
        STRATEGY_ID             NUMBER,
        OBJECT_ID               NUMBER,
        OBJECT_TYPE             VARCHAR2(30),
        STRATEGY_LEVEL          NUMBER,
        JTF_OBJECT_ID           NUMBER,
        JTF_OBJECT_TYPE         VARCHAR2(30),
        CUSTOMER_SITE_USE_ID    VARCHAR2(30),
        STATUS                  VARCHAR2(30)
    );

    TYPE STRY_CNT_TBL_TYPE is Table of STRY_CNT_REC_TYPE
            index by binary_integer;

   INST_STRY_CNT_REC        IEX_STRATEGY_TYPE_PUB.STRY_CNT_REC_TYPE;
   INST_STRY_CNT_TBL        IEX_STRATEGY_TYPE_PUB.STRY_CNT_TBL_TYPE;


END IEX_STRATEGY_TYPE_PUB;

 

/
