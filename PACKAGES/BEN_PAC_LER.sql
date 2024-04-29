--------------------------------------------------------
--  DDL for Package BEN_PAC_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PAC_LER" AUTHID CURRENT_USER as
/* $Header: bepactrg.pkh 115.0 2004/02/13 07:41:55 nhunur noship $ */


TYPE  g_pac_ler_rec is RECORD
(PERSON_ANALYSIS_ID               NUMBER(15)
 ,BUSINESS_GROUP_ID                NUMBER(15)
 ,ANALYSIS_CRITERIA_ID             NUMBER(15)
 ,PERSON_ID                        NUMBER(10)
 ,COMMENTS                         LONG
 ,DATE_FROM                        DATE
 ,DATE_TO                          DATE
 ,ID_FLEX_NUM                      NUMBER
 ,ATTRIBUTE_CATEGORY               VARCHAR2(30)
 ,ATTRIBUTE1                       VARCHAR2(150)
 ,ATTRIBUTE2                       VARCHAR2(150)
 ,ATTRIBUTE3                       VARCHAR2(150)
 ,ATTRIBUTE4                       VARCHAR2(150)
 ,ATTRIBUTE5                       VARCHAR2(150)
 ,ATTRIBUTE6                       VARCHAR2(150)
 ,ATTRIBUTE7                       VARCHAR2(150)
 ,ATTRIBUTE8                       VARCHAR2(150)
 ,ATTRIBUTE9                       VARCHAR2(150)
 ,ATTRIBUTE10                      VARCHAR2(150)
 ,ATTRIBUTE11                      VARCHAR2(150)
 ,ATTRIBUTE12                      VARCHAR2(150)
 ,ATTRIBUTE13                      VARCHAR2(150)
 ,ATTRIBUTE14                      VARCHAR2(150)
 ,ATTRIBUTE15                      VARCHAR2(150)
 ,ATTRIBUTE16                      VARCHAR2(150)
 ,ATTRIBUTE17                      VARCHAR2(150)
 ,ATTRIBUTE18                      VARCHAR2(150)
 ,ATTRIBUTE19                      VARCHAR2(150)
 ,ATTRIBUTE20                      VARCHAR2(150));
 --
procedure ler_chk(p_old IN g_pac_ler_rec
                 ,p_new IN g_pac_ler_rec
                 ,p_effective_date in date default null );
end;

 

/
