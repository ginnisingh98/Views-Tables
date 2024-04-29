--------------------------------------------------------
--  DDL for Package IEX_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_PROFILE" AUTHID CURRENT_USER AS
/* $Header: iexrcnts.pls 120.3 2005/01/24 20:44:57 jypark ship $ */

 TYPE Profile_Rec is RECORD(
  Total_Promises   Number ,
  Broken_Promises  Number ,
  Open_Promises Number,
  Installments_Due Number  ,
  Unpaid_Installments Number  ,
  OnTime_Installments Number  ,
  Late_Installments Number  ,
  Credit_Limit_AMT NUMBER,
  Credit_Limit_AMT_CURR VARCHAR2(15),
  Credit_Status VARCHAR2(80),
  Credit_Rating VARCHAR2(80),
  Collector_Name VARCHAR2(360),
  Include_Dunning VARCHAR2(80),
  Last_Outcome   JTF_IH_OUTCOMES_VL.Short_Description%TYPE,
  last_contact_date  Date  ,
  last_Contacted_By  JTF_RS_RESOURCE_EXTNS_VL.Resource_Name%TYPE,
  Last_Result       JTF_IH_RESULTS_VL.Short_Description%TYPE
  ) ;

 -- Ref cursors to select the History and Activity Data
 TYPE PROFILE_CUR IS REF CURSOR ;

 -- Ref cursors to select the Payment info
 TYPE LAST_PAYMENT_CUR IS REF CURSOR ;


 PROCEDURE GET_PROFILE_INFO
       (p_api_version      IN  NUMBER,
        p_init_msg_list    IN  VARCHAR2,
        p_commit           IN  VARCHAR2,
        p_validation_level IN  NUMBER,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
     p_calling_app    IN  VARCHAR2,
     p_filter_mode      IN  VARCHAR2  ,
     p_Party_id      IN  Number,
     p_cust_account_id  IN  Number,
            p_delinquency_id   IN  NUMBER,  -- added by jypark
            p_customer_site_use_id IN NUMBER, -- added by jypark for Bill-to
            p_using_paying_rel IN VARCHAR2,  -- added by jypark for Paying Relationship
     x_profile_rec    OUT NOCOPY Profile_Rec) ;

End IEX_PROFILE ;

 

/
