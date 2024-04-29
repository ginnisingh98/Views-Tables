--------------------------------------------------------
--  DDL for Package Body BEN_CWB_PR_CURR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_PR_CURR" as
/* $Header: bencwbcp.pkb 120.1 2006/03/29 13:10:54 maagrawa noship $ */

procedure getCurrencyCode
                                        (
                                         User_Id       IN  NUMBER,
                                         Business_grp_Id IN  NUMBER,
                                         profile_name    IN  VARCHAR2,
                                         RetCode         OUT NOCOPY VARCHAR2 ,
                                         defined         OUT NOCOPY VARCHAR2
                                         )
   as
        Code     VARCHAR2(20);
        def      BOOLEAN;
  BEGIN
    Select org_information10 into  Code
    from hr_organization_information
    where organization_id =business_grp_id
    and   org_information_context = 'Business Group Information';

   if code is null then
    defined :=' N';
   else
    defined := 'Y';
    RetCode := code;
   end if;
 def :=  FND_PROFILE.SAVE(PROFILE_NAME, code, 'USER', user_id);
 IF DEF THEN
   COMMIT;
 END IF;
  END getCurrencyCode ;

 procedure setProfile(
                                        USER_ID IN NUMBER,
                                        CURRENCY IN VARCHAR2,
                                       PROFILE_NAME IN VARCHAR2
                                      )
   as
         def boolean;
  BEGIN
   def :=  FND_PROFILE.SAVE(PROFILE_NAME, CURRENCY, 'USER', user_id);
 IF DEF THEN
  COMMIT;
 END IF;
  END setProfile ;

End ben_cwb_pr_curr;

/
