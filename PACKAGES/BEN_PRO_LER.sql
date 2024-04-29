--------------------------------------------------------
--  DDL for Package BEN_PRO_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRO_LER" AUTHID CURRENT_USER as
/* $Header: beprotrg.pkh 120.1 2006/02/16 01:16:32 rtagarra noship $ */
TYPE g_pro_ler_rec is RECORD
(PERSON_ID NUMBER
,BUSINESS_GROUP_ID NUMBER
,PAY_PROPOSAL_ID                 NUMBER
,OBJECT_VERSION_NUMBER           NUMBER
,ASSIGNMENT_ID                   NUMBER
,EVENT_ID                        NUMBER
,CHANGE_DATE                     DATE
,LAST_CHANGE_DATE                DATE
,NEXT_PERF_REVIEW_DATE           DATE
,NEXT_SAL_REVIEW_DATE            DATE
,PERFORMANCE_RATING              VARCHAR2(30)
,PROPOSAL_REASON                 VARCHAR2(30)
,PROPOSED_SALARY_N               NUMBER
,REVIEW_DATE                     DATE
,APPROVED                        VARCHAR2(30)
,MULTIPLE_COMPONENTS             VARCHAR2(30)
,FORCED_RANKING                  NUMBER
,PERFORMANCE_REVIEW_ID           NUMBER
,ATTRIBUTE1                      VARCHAR2(150)
,ATTRIBUTE2                      VARCHAR2(150)
,ATTRIBUTE3                      VARCHAR2(150)
,ATTRIBUTE4                      VARCHAR2(150)
,ATTRIBUTE5                      VARCHAR2(150)
,ATTRIBUTE6                      VARCHAR2(150)
,ATTRIBUTE7                      VARCHAR2(150)
,ATTRIBUTE8                      VARCHAR2(150)
,ATTRIBUTE9                      VARCHAR2(150)
,ATTRIBUTE10                     VARCHAR2(150)
,ATTRIBUTE11                     VARCHAR2(150)
,ATTRIBUTE12                     VARCHAR2(150)
,ATTRIBUTE13                     VARCHAR2(150)
,ATTRIBUTE14                     VARCHAR2(150)
,ATTRIBUTE15                     VARCHAR2(150)
,ATTRIBUTE16                     VARCHAR2(150)
,ATTRIBUTE17                     VARCHAR2(150)
,ATTRIBUTE18                     VARCHAR2(150)
,ATTRIBUTE19                     VARCHAR2(150)
,ATTRIBUTE20                     VARCHAR2(150)
,PROPOSED_SALARY                 VARCHAR2(60)
,date_to                         DATE
);

procedure ler_chk(p_old IN g_pro_ler_rec
                 ,p_new IN g_pro_ler_rec
                 ,p_effective_date in date default null );

procedure qua_in_gr_ler_chk( p_old_asg IN ben_asg_ler.g_asg_ler_rec
                            ,p_new_asg IN ben_asg_ler.g_asg_ler_rec
                            ,p_old_pro IN g_pro_ler_rec
                            ,p_new_pro IN g_pro_ler_rec
                            ,p_effective_date IN date default null
                            ,p_called_from IN varchar2);
end;

 

/
