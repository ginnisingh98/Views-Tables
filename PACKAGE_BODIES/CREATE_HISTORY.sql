--------------------------------------------------------
--  DDL for Package Body CREATE_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CREATE_HISTORY" as
/* $Header: GMPDPHSTB.pls 115.2 2003/01/30 17:29:04 rpatangy noship $ */

procedure shipment_history (
                        errbuf       OUT  NOCOPY VARCHAR2,
                        retcode      OUT  NOCOPY VARCHAR2,
                        p_sr_item_pk IN   VARCHAR2,
			pfrom_date   IN   DATE,
			pto_date     IN   DATE ,
                        pqty         IN   NUMBER )
IS
 local_date                    DATE ;
 l_INSTANCE                        VARCHAR2(40) ;
 l_INV_ORG                                  VARCHAR2(320) ;
 l_ITEM                                     VARCHAR2(320) ;
 l_CUSTOMER                                 VARCHAR2(320) ;
 l_SALES_CHANNEL                            VARCHAR2(320) ;
 l_SALES_REP                                VARCHAR2(1000) ;
 l_SHIP_TO_LOC                              VARCHAR2(320) ;
 l_USER_DEFINED1                            VARCHAR2(320) ;
 l_USER_DEFINED2                            VARCHAR2(320) ;
 l_BOOKED_DATE                              DATE ;
 l_REQUESTED_DATE                           DATE ;
 l_PROMISED_DATE                            DATE ;
 l_SHIPPED_DATE                             DATE ;
 l_AMOUNT                                   NUMBER ;
 l_QTY_SHIPPED                              NUMBER ;
 l_CREATION_DATE                   DATE ;
 l_CREATED_BY                      NUMBER ;
 l_LAST_UPDATE_DATE                DATE ;
 l_LAST_UPDATED_BY                 NUMBER ;
 l_LAST_UPDATE_LOGIN               NUMBER ;
 l_REQUEST_ID                               NUMBER ;
 l_PROGRAM_APPLICATION_ID                   NUMBER ;
 l_PROGRAM_ID                               NUMBER ;
 l_PROGRAM_UPDATE_DATE                      DATE ;
 l_SR_INV_ORG_PK                            VARCHAR2(240) ;
 l_SR_ITEM_PK                               VARCHAR2(240) ;
 l_SR_CUSTOMER_PK                           VARCHAR2(240) ;
 l_SR_SALES_CHANNEL_PK                      VARCHAR2(240) ;
 l_SR_SALES_REP_PK                          VARCHAR2(240) ;
 l_SR_SHIP_TO_LOC_PK                        VARCHAR2(240) ;
 l_SR_USER_DEFINED1_PK                      VARCHAR2(240) ;
 l_SR_USER_DEFINED2_PK                      VARCHAR2(240) ;

BEGIN

--  This code is being used for developement purpose and not suppose to
--  be included in any patchsets. As it is already included in the patchsets
--  , we are removing the complete code with NULL statement.

    NULL ;
END shipment_history  ;

-- ==========================================================================
procedure booking_history (
                        errbuf       OUT  NOCOPY VARCHAR2,
                        retcode      OUT  NOCOPY VARCHAR2,
                        p_sr_item_pk IN   VARCHAR2,
			pfrom_date   IN   DATE,
			pto_date     IN   DATE ,
                        pqty         IN   NUMBER )
IS
 local_date                    DATE ;
 l_INSTANCE                        VARCHAR2(40) ;
 l_INV_ORG                                  VARCHAR2(320) ;
 l_ITEM                                     VARCHAR2(320) ;
 l_CUSTOMER                                 VARCHAR2(320) ;
 l_SALES_CHANNEL                            VARCHAR2(320) ;
 l_SALES_REP                                VARCHAR2(1000) ;
 l_SHIP_TO_LOC                              VARCHAR2(320) ;
 l_USER_DEFINED1                            VARCHAR2(320) ;
 l_USER_DEFINED2                            VARCHAR2(320) ;
 l_BOOKED_DATE                              DATE ;
 l_REQUESTED_DATE                           DATE ;
 l_PROMISED_DATE                            DATE ;
 l_SCHEDULED_DATE                             DATE ;
 l_AMOUNT                                   NUMBER ;
 l_QTY_ORDERED                              NUMBER ;
 l_CREATION_DATE                   DATE ;
 l_CREATED_BY                      NUMBER ;
 l_LAST_UPDATE_DATE                DATE ;
 l_LAST_UPDATED_BY                 NUMBER ;
 l_LAST_UPDATE_LOGIN               NUMBER ;
 l_REQUEST_ID                               NUMBER ;
 l_PROGRAM_APPLICATION_ID                   NUMBER ;
 l_PROGRAM_ID                               NUMBER ;
 l_PROGRAM_UPDATE_DATE                      DATE ;
 l_SR_INV_ORG_PK                            VARCHAR2(240) ;
 l_SR_ITEM_PK                               VARCHAR2(240) ;
 l_SR_CUSTOMER_PK                           VARCHAR2(240) ;
 l_SR_SALES_CHANNEL_PK                      VARCHAR2(240) ;
 l_SR_SALES_REP_PK                          VARCHAR2(240) ;
 l_SR_SHIP_TO_LOC_PK                        VARCHAR2(240) ;
 l_SR_USER_DEFINED1_PK                      VARCHAR2(240) ;
 l_SR_USER_DEFINED2_PK                      VARCHAR2(240) ;

BEGIN

--  This code is being used for developement purpose and not suppose to
--  be included in any patchsets. As it is already included in the patchsets
--  , we are removing the complete code with NULL statement.

    NULL ;
END booking_history ;

END create_history ;

/
