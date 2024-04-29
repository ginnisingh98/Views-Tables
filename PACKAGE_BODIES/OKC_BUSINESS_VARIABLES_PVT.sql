--------------------------------------------------------
--  DDL for Package Body OKC_BUSINESS_VARIABLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_BUSINESS_VARIABLES_PVT" AS
/* $Header: OKCVBVBB.pls 120.4.12010000.4 2013/08/07 15:10:49 serukull ship $ */
 l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
 G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';

  Function Resolve_Var_Data_Type(p_value_set_id IN NUMBER,
                                  p_variable_type IN VARCHAR2,
						    p_variable_datatype IN VARCHAR2)
						    Return VARCHAR2 IS
    l_variable_datatype OKC_BUS_VARIABLES_B.Variable_datatype%TYPE;
    Cursor l_Data_Type_Csr(lc_value_set_id NUMBER) IS
      Select Decode(format_type,'C','V','X','D',format_type) format_type
	 From fnd_flex_value_sets
	 Where flex_value_set_id = lc_value_set_id
	 And validation_type IN ('F','N','I');
  Begin
    l_variable_datatype := p_variable_datatype;
    If p_variable_type = 'U' Then
      Open l_Data_Type_Csr (p_value_set_id);
        Fetch L_Data_Type_Csr INTO l_variable_datatype;
      Close l_Data_Type_Csr;
    End If;

    Return l_variable_datatype;

  Exception
    When Others Then
      Return l_variable_datatype;
  End Resolve_Var_Data_Type;


   procedure INSERT_ROW (
     X_ROWID in out NOCOPY VARCHAR2,
     X_VARIABLE_CODE in VARCHAR2,
     X_VARIABLE_DEFAULT_VALUE in VARCHAR2,
     X_VARIABLE_DATATYPE in VARCHAR2,
     X_OBJECT_VERSION_NUMBER in NUMBER,
     X_VARIABLE_TYPE in VARCHAR2,
     X_EXTERNAL_YN in VARCHAR2,
     X_APPLICATION_ID in NUMBER,
     X_VARIABLE_INTENT in VARCHAR2,
     X_CONTRACT_EXPERT_YN in VARCHAR2,
     X_DISABLED_YN in VARCHAR2,
     X_VALUE_SET_ID in NUMBER,
     X_ORIG_SYSTEM_REFERENCE_CODE in VARCHAR2 DEFAULT NULL,
	X_ORIG_SYSTEM_REFERENCE_ID1 in VARCHAR2 DEFAULT NULL,
	X_ORIG_SYSTEM_REFERENCE_ID2 in VARCHAR2 DEFAULT NULL,
	X_DATE_PUBLISHED in DATE DEFAULT NULL,
     X_ATTRIBUTE_CATEGORY in VARCHAR2,
     X_ATTRIBUTE1 in VARCHAR2,
     X_ATTRIBUTE2 in VARCHAR2,
     X_ATTRIBUTE3 in VARCHAR2,
     X_ATTRIBUTE4 in VARCHAR2,
     X_ATTRIBUTE5 in VARCHAR2,
     X_ATTRIBUTE6 in VARCHAR2,
     X_ATTRIBUTE7 in VARCHAR2,
     X_ATTRIBUTE8 in VARCHAR2,
     X_ATTRIBUTE9 in VARCHAR2,
     X_ATTRIBUTE10 in VARCHAR2,
     X_ATTRIBUTE11 in VARCHAR2,
     X_ATTRIBUTE12 in VARCHAR2,
     X_ATTRIBUTE13 in VARCHAR2,
     X_ATTRIBUTE14 in VARCHAR2,
     X_ATTRIBUTE15 in VARCHAR2,
     X_VARIABLE_NAME in VARCHAR2,
     X_DESCRIPTION in VARCHAR2,
     X_CREATION_DATE in DATE,
     X_CREATED_BY in NUMBER,
     X_LAST_UPDATE_DATE in DATE,
     X_LAST_UPDATED_BY in NUMBER,
     X_LAST_UPDATE_LOGIN in NUMBER,
     X_XPRT_VALUE_SET_NAME in VARCHAR2,
     X_LINE_LEVEL_FLAG in VARCHAR2,
     X_PROCEDURE_NAME in VARCHAR2,
    X_VARIABLE_SOURCE in VARCHAR2, -- CLM Changes
    X_CLM_SOURCE IN VARCHAR2,      -- CLM Changes
    X_CLM_REF1 IN VARCHAR2,        -- CLM Changes
    X_CLM_REF2 IN VARCHAR2,        -- CLM Changes
    X_CLM_REF3 IN VARCHAR2,        -- CLM Changes
    X_CLM_REF4 IN VARCHAR2,        -- CLM Changes
    X_CLM_REF5 IN VARCHAR2,         -- CLM Changes
    X_MRV_FLAG IN VARCHAR2,        -- MRV Changes
    X_MRV_TMPL_CODE IN  VARCHAR2    -- MRV Changes
   ) is
     cursor C is select ROWID from OKC_BUS_VARIABLES_B
       where VARIABLE_CODE = X_VARIABLE_CODE
       ;
     L_VARIABLE_DATATYPE OKC_BUS_VARIABLES_B.VARIABLE_DATATYPE%TYPE;


   begin
     L_VARIABLE_DATATYPE :=
	    Resolve_Var_Data_Type(X_VALUE_SET_ID,X_VARIABLE_TYPE,X_VARIABLE_DATATYPE);
     insert into OKC_BUS_VARIABLES_B (
       VARIABLE_DEFAULT_VALUE,
       VARIABLE_DATATYPE,
       VARIABLE_CODE,
       OBJECT_VERSION_NUMBER,
       VARIABLE_TYPE,
       EXTERNAL_YN,
       APPLICATION_ID,
       VARIABLE_INTENT,
       CONTRACT_EXPERT_YN,
       DISABLED_YN,
       VALUE_SET_ID,
       ORIG_SYSTEM_REFERENCE_CODE,
	  ORIG_SYSTEM_REFERENCE_ID1,
	  ORIG_SYSTEM_REFERENCE_ID2,
	  DATE_PUBLISHED,
       ATTRIBUTE_CATEGORY,
       ATTRIBUTE1,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       XPRT_VALUE_SET_NAME,
       LINE_LEVEL_FLAG,
       PROCEDURE_NAME,
       VARIABLE_SOURCE, -- CLM Changes
       CLM_SOURCE,      -- CLM Changes
       CLM_REF1,        -- CLM Changes
       CLM_REF2,        -- CLM Changes
       CLM_REF3,        -- CLM Changes
       CLM_REF4,        -- CLM Changes
       CLM_REF5,         -- CLM Changes
       mrv_flag,         -- MRV Changes
       mrv_tmpl_code     -- MRV Changes

     ) values (
       X_VARIABLE_DEFAULT_VALUE,
       L_VARIABLE_DATATYPE,
       X_VARIABLE_CODE,
       X_OBJECT_VERSION_NUMBER,
       X_VARIABLE_TYPE,
       X_EXTERNAL_YN,
       X_APPLICATION_ID,
       X_VARIABLE_INTENT,
       X_CONTRACT_EXPERT_YN,
       X_DISABLED_YN,
       X_VALUE_SET_ID,
       X_ORIG_SYSTEM_REFERENCE_CODE,
	  X_ORIG_SYSTEM_REFERENCE_ID1,
	  X_ORIG_SYSTEM_REFERENCE_ID2,
	  X_DATE_PUBLISHED,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_ATTRIBUTE2,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_ATTRIBUTE11,
       X_ATTRIBUTE12,
       X_ATTRIBUTE13,
       X_ATTRIBUTE14,
       X_ATTRIBUTE15,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN,
       X_XPRT_VALUE_SET_NAME,
       X_LINE_LEVEL_FLAG,
       X_PROCEDURE_NAME,
       X_VARIABLE_SOURCE, -- CLM Changes
       X_CLM_SOURCE,      -- CLM Changes
       X_CLM_REF1,        -- CLM Changes
       X_CLM_REF2,        -- CLM Changes
       X_CLM_REF3,        -- CLM Changes
       X_CLM_REF4,        -- CLM Changes
       X_CLM_REF5,         -- CLM Changes
       X_MRV_FLAG,         -- MRV Changes
       X_MRV_TMPL_CODE     -- MRV Changes
     );

     insert into OKC_BUS_VARIABLES_TL (
       VARIABLE_CODE,
       VARIABLE_NAME,
       DESCRIPTION,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       LANGUAGE,
       SOURCE_LANG
     ) select
       X_VARIABLE_CODE,
       X_VARIABLE_NAME,
       X_DESCRIPTION,
       X_CREATED_BY,
       X_CREATION_DATE,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN,
       L.LANGUAGE_CODE,
       userenv('LANG')
     from FND_LANGUAGES L
     where L.INSTALLED_FLAG in ('I', 'B')
     and not exists
       (select NULL
       from OKC_BUS_VARIABLES_TL T
       where T.VARIABLE_CODE = X_VARIABLE_CODE
       and T.LANGUAGE = L.LANGUAGE_CODE);

     open c;
     fetch c into X_ROWID;
     if (c%notfound) then
       close c;
       raise no_data_found;
     end if;
     close c;

   end INSERT_ROW;

   procedure LOCK_ROW (
     X_VARIABLE_CODE in VARCHAR2,
     X_VARIABLE_DEFAULT_VALUE in VARCHAR2,
     X_VARIABLE_DATATYPE in VARCHAR2,
     X_OBJECT_VERSION_NUMBER in NUMBER,
     X_VARIABLE_TYPE in VARCHAR2,
     X_EXTERNAL_YN in VARCHAR2,
     X_APPLICATION_ID in NUMBER,
     X_VARIABLE_INTENT in VARCHAR2,
     X_CONTRACT_EXPERT_YN in VARCHAR2,
     X_DISABLED_YN in VARCHAR2,
     X_VALUE_SET_ID in NUMBER,
     X_ORIG_SYSTEM_REFERENCE_CODE in VARCHAR2 DEFAULT NULL,
	X_ORIG_SYSTEM_REFERENCE_ID1 in VARCHAR2 DEFAULT NULL,
	X_ORIG_SYSTEM_REFERENCE_ID2 in VARCHAR2 DEFAULT NULL,
	X_DATE_PUBLISHED in DATE DEFAULT NULL,
     X_ATTRIBUTE_CATEGORY in VARCHAR2,
     X_ATTRIBUTE1 in VARCHAR2,
     X_ATTRIBUTE2 in VARCHAR2,
     X_ATTRIBUTE3 in VARCHAR2,
     X_ATTRIBUTE4 in VARCHAR2,
     X_ATTRIBUTE5 in VARCHAR2,
     X_ATTRIBUTE6 in VARCHAR2,
     X_ATTRIBUTE7 in VARCHAR2,
     X_ATTRIBUTE8 in VARCHAR2,
     X_ATTRIBUTE9 in VARCHAR2,
     X_ATTRIBUTE10 in VARCHAR2,
     X_ATTRIBUTE11 in VARCHAR2,
     X_ATTRIBUTE12 in VARCHAR2,
     X_ATTRIBUTE13 in VARCHAR2,
     X_ATTRIBUTE14 in VARCHAR2,
     X_ATTRIBUTE15 in VARCHAR2,
     X_VARIABLE_NAME in VARCHAR2,
     X_DESCRIPTION in VARCHAR2,
     X_XPRT_VALUE_SET_NAME in VARCHAR2,
     X_LINE_LEVEL_FLAG in VARCHAR2,
     X_PROCEDURE_NAME in VARCHAR2,
    X_VARIABLE_SOURCE in VARCHAR2, -- CLM Changes
    X_CLM_SOURCE IN VARCHAR2,      -- CLM Changes
    X_CLM_REF1 IN VARCHAR2,        -- CLM Changes
    X_CLM_REF2 IN VARCHAR2,        -- CLM Changes
    X_CLM_REF3 IN VARCHAR2,        -- CLM Changes
    X_CLM_REF4 IN VARCHAR2,        -- CLM Changes
    X_CLM_REF5 IN VARCHAR2,         -- CLM Changes
    X_MRV_FLAG IN VARCHAR2,         -- MRV Changes
    X_MRV_TMPL_CODE IN  VARCHAR2    -- MRV Changes
   ) is
     cursor c is select
         VARIABLE_DEFAULT_VALUE,
         VARIABLE_DATATYPE,
         OBJECT_VERSION_NUMBER,
         VARIABLE_TYPE,
         EXTERNAL_YN,
         APPLICATION_ID,
         VARIABLE_INTENT,
         CONTRACT_EXPERT_YN,
         DISABLED_YN,
         VALUE_SET_ID,
         ORIG_SYSTEM_REFERENCE_CODE,
	    ORIG_SYSTEM_REFERENCE_ID1,
	    ORIG_SYSTEM_REFERENCE_ID2,
	    DATE_PUBLISHED,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         XPRT_VALUE_SET_NAME,
         LINE_LEVEL_FLAG,
         PROCEDURE_NAME,
       VARIABLE_SOURCE, -- CLM Changes
       CLM_SOURCE,      -- CLM Changes
       CLM_REF1,        -- CLM Changes
       CLM_REF2,        -- CLM Changes
       CLM_REF3,        -- CLM Changes
       CLM_REF4,        -- CLM Changes
       CLM_REF5,         -- CLM Changes
       MRV_FLAG,        -- MRV Changes
       MRV_TMPL_CODE    -- MRV Changes
       from OKC_BUS_VARIABLES_B
       where VARIABLE_CODE = X_VARIABLE_CODE
       for update of VARIABLE_CODE nowait;
     recinfo c%rowtype;

     cursor c1 is select
         VARIABLE_NAME,
         DESCRIPTION,
         decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
       from OKC_BUS_VARIABLES_TL
       where VARIABLE_CODE = X_VARIABLE_CODE
       and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
       for update of VARIABLE_CODE nowait;
   begin
     open c;
     fetch c into recinfo;
     if (c%notfound) then
       close c;
       fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
       app_exception.raise_exception;
     end if;
     close c;
     if (    ((recinfo.VARIABLE_DEFAULT_VALUE = X_VARIABLE_DEFAULT_VALUE)
              OR ((recinfo.VARIABLE_DEFAULT_VALUE is null) AND (X_VARIABLE_DEFAULT_VALUE is null)))
         AND ((recinfo.VARIABLE_DATATYPE = X_VARIABLE_DATATYPE)
              OR ((recinfo.VARIABLE_DATATYPE is null) AND (X_VARIABLE_DATATYPE is null)))
         AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
         AND (recinfo.VARIABLE_TYPE = X_VARIABLE_TYPE)
         AND (recinfo.EXTERNAL_YN = X_EXTERNAL_YN)
         AND ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
              OR ((recinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
         AND (recinfo.VARIABLE_INTENT = X_VARIABLE_INTENT)
         AND (recinfo.CONTRACT_EXPERT_YN = X_CONTRACT_EXPERT_YN)
         AND (recinfo.DISABLED_YN = X_DISABLED_YN)
         AND ((recinfo.VALUE_SET_ID = X_VALUE_SET_ID)
              OR ((recinfo.VALUE_SET_ID is null) AND (X_VALUE_SET_ID is null)))
         AND ((recinfo.ORIG_SYSTEM_REFERENCE_CODE = X_ORIG_SYSTEM_REFERENCE_CODE)
              OR ((recinfo.ORIG_SYSTEM_REFERENCE_CODE is null) AND (X_ORIG_SYSTEM_REFERENCE_CODE is null)))
         AND ((recinfo.ORIG_SYSTEM_REFERENCE_ID1 = X_ORIG_SYSTEM_REFERENCE_ID1)
              OR ((recinfo.ORIG_SYSTEM_REFERENCE_ID1 is null) AND (X_ORIG_SYSTEM_REFERENCE_ID1 is null)))
         AND ((recinfo.ORIG_SYSTEM_REFERENCE_ID2 = X_ORIG_SYSTEM_REFERENCE_ID2)
              OR ((recinfo.ORIG_SYSTEM_REFERENCE_ID2 is null) AND (X_ORIG_SYSTEM_REFERENCE_ID2 is null)))
         AND ((recinfo.DATE_PUBLISHED = X_DATE_PUBLISHED)
              OR ((recinfo.DATE_PUBLISHED is null) AND (X_DATE_PUBLISHED is null)))
         AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
              OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
         AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
              OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
         AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
              OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
         AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
              OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
         AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
              OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
         AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
              OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
         AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
              OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
         AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
              OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
         AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
              OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
         AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
              OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
         AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
              OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
         AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
              OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
         AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
              OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
         AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
              OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
         AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
              OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
         AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
              OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
	 AND ((recinfo.XPRT_VALUE_SET_NAME = X_XPRT_VALUE_SET_NAME)
              OR ((recinfo.XPRT_VALUE_SET_NAME is null) AND (X_XPRT_VALUE_SET_NAME is null)))
	 AND ((recinfo.LINE_LEVEL_FLAG = X_LINE_LEVEL_FLAG)
              OR ((recinfo.LINE_LEVEL_FLAG is null) AND (X_LINE_LEVEL_FLAG is null)))
     AND ((recinfo.PROCEDURE_NAME = X_PROCEDURE_NAME)
              OR ((recinfo.PROCEDURE_NAME is null) AND (X_PROCEDURE_NAME is null)))
     AND ((recinfo.VARIABLE_SOURCE = X_VARIABLE_SOURCE)
              OR ((recinfo.VARIABLE_SOURCE is null) AND (X_VARIABLE_SOURCE is null)))
              -- CLM Changes Begins
     AND ((recinfo.CLM_SOURCE = X_CLM_SOURCE)
              OR ((recinfo.CLM_SOURCE is null) AND (X_CLM_SOURCE is null)))
     AND ((recinfo.CLM_REF1 = X_CLM_REF1)
              OR ((recinfo.CLM_REF1 is null) AND (X_CLM_REF1 is null)))
     AND ((recinfo.CLM_REF2 = X_CLM_REF2)
              OR ((recinfo.CLM_REF2 is null) AND (X_CLM_REF2 is null)))
     AND ((recinfo.CLM_REF3 = X_CLM_REF3)
              OR ((recinfo.CLM_REF3 is null) AND (X_CLM_REF3 is null)))
     AND ((recinfo.CLM_REF4 = X_CLM_REF4)
              OR ((recinfo.CLM_REF4 is null) AND (X_CLM_REF4 is null)))
     AND ((recinfo.CLM_REF5 = X_CLM_REF5)
              OR ((recinfo.CLM_REF5 is null) AND (X_CLM_REF5 is null)))
              -- CLM Changes Ends
              -- MRV Changes Start
    AND ((recinfo.mrv_flag = X_mrv_flag)
              OR ((recinfo.mrv_flag is null) AND (X_mrv_flag is null)))

    AND ((recinfo.mrv_tmpl_code = X_mrv_tmpl_code)
              OR ((recinfo.mrv_tmpl_code is null) AND (X_mrv_tmpl_code is null)))
            -- MRV Changes End
     ) then
       null;
     else
       fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
       app_exception.raise_exception;
     end if;

     for tlinfo in c1 loop
       if (tlinfo.BASELANG = 'Y') then
          if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND (tlinfo.VARIABLE_NAME = X_VARIABLE_NAME)
          ) then
           null;
         else
           fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
           app_exception.raise_exception;
         end if;
       end if;
     end loop;
     return;
   end LOCK_ROW;

   procedure UPDATE_ROW (
     X_VARIABLE_CODE in VARCHAR2,
     X_VARIABLE_DEFAULT_VALUE in VARCHAR2,
     X_VARIABLE_DATATYPE in VARCHAR2,
     X_OBJECT_VERSION_NUMBER in NUMBER,
     X_VARIABLE_TYPE in VARCHAR2,
     X_EXTERNAL_YN in VARCHAR2,
     X_APPLICATION_ID in NUMBER,
     X_VARIABLE_INTENT in VARCHAR2,
     X_CONTRACT_EXPERT_YN in VARCHAR2,
     X_DISABLED_YN in VARCHAR2,
     X_VALUE_SET_ID in NUMBER,
     X_ORIG_SYSTEM_REFERENCE_CODE in VARCHAR2,
	X_ORIG_SYSTEM_REFERENCE_ID1 in VARCHAR2,
	X_ORIG_SYSTEM_REFERENCE_ID2 in VARCHAR2,
	X_DATE_PUBLISHED in DATE,
     X_ATTRIBUTE_CATEGORY in VARCHAR2,
     X_ATTRIBUTE1 in VARCHAR2,
     X_ATTRIBUTE2 in VARCHAR2,
     X_ATTRIBUTE3 in VARCHAR2,
     X_ATTRIBUTE4 in VARCHAR2,
     X_ATTRIBUTE5 in VARCHAR2,
     X_ATTRIBUTE6 in VARCHAR2,
     X_ATTRIBUTE7 in VARCHAR2,
     X_ATTRIBUTE8 in VARCHAR2,
     X_ATTRIBUTE9 in VARCHAR2,
     X_ATTRIBUTE10 in VARCHAR2,
     X_ATTRIBUTE11 in VARCHAR2,
     X_ATTRIBUTE12 in VARCHAR2,
     X_ATTRIBUTE13 in VARCHAR2,
     X_ATTRIBUTE14 in VARCHAR2,
     X_ATTRIBUTE15 in VARCHAR2,
     X_VARIABLE_NAME in VARCHAR2,
     X_DESCRIPTION in VARCHAR2,
     X_LAST_UPDATE_DATE in DATE,
     X_LAST_UPDATED_BY in NUMBER,
     X_LAST_UPDATE_LOGIN in NUMBER,
     X_XPRT_VALUE_SET_NAME in VARCHAR2,
     X_LINE_LEVEL_FLAG in VARCHAR2,
     X_PROCEDURE_NAME in VARCHAR2,
    X_VARIABLE_SOURCE in VARCHAR2, -- CLM Changes
    X_CLM_SOURCE IN VARCHAR2,      -- CLM Changes
    X_CLM_REF1 IN VARCHAR2,        -- CLM Changes
    X_CLM_REF2 IN VARCHAR2,        -- CLM Changes
    X_CLM_REF3 IN VARCHAR2,        -- CLM Changes
    X_CLM_REF4 IN VARCHAR2,        -- CLM Changes
    X_CLM_REF5 IN VARCHAR2,         -- CLM Changes
    X_MRV_FLAG IN VARCHAR2,        -- MRV Changes
    X_MRV_TMPL_CODE IN VARCHAR2    -- MRV Changes
   ) is
     L_VARIABLE_DATATYPE OKC_BUS_VARIABLES_B.VARIABLE_DATATYPE%TYPE;
   begin
     L_VARIABLE_DATATYPE :=
	           Resolve_Var_Data_Type(X_VALUE_SET_ID,X_VARIABLE_TYPE,X_VARIABLE_DATATYPE);
     update OKC_BUS_VARIABLES_B set
       VARIABLE_DEFAULT_VALUE = X_VARIABLE_DEFAULT_VALUE,
       VARIABLE_DATATYPE = L_VARIABLE_DATATYPE,
       OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
       VARIABLE_TYPE = X_VARIABLE_TYPE,
       EXTERNAL_YN = X_EXTERNAL_YN,
       APPLICATION_ID = X_APPLICATION_ID,
       VARIABLE_INTENT = X_VARIABLE_INTENT,
       CONTRACT_EXPERT_YN = X_CONTRACT_EXPERT_YN,
       DISABLED_YN = X_DISABLED_YN,
       VALUE_SET_ID = X_VALUE_SET_ID,
       ORIG_SYSTEM_REFERENCE_CODE = X_ORIG_SYSTEM_REFERENCE_CODE,
	  ORIG_SYSTEM_REFERENCE_ID1  = X_ORIG_SYSTEM_REFERENCE_ID1,
	  ORIG_SYSTEM_REFERENCE_ID2  = X_ORIG_SYSTEM_REFERENCE_ID2,
	  DATE_PUBLISHED = X_DATE_PUBLISHED,
       ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
       ATTRIBUTE1 = X_ATTRIBUTE1,
       ATTRIBUTE2 = X_ATTRIBUTE2,
       ATTRIBUTE3 = X_ATTRIBUTE3,
       ATTRIBUTE4 = X_ATTRIBUTE4,
       ATTRIBUTE5 = X_ATTRIBUTE5,
       ATTRIBUTE6 = X_ATTRIBUTE6,
       ATTRIBUTE7 = X_ATTRIBUTE7,
       ATTRIBUTE8 = X_ATTRIBUTE8,
       ATTRIBUTE9 = X_ATTRIBUTE9,
       ATTRIBUTE10 = X_ATTRIBUTE10,
       ATTRIBUTE11 = X_ATTRIBUTE11,
       ATTRIBUTE12 = X_ATTRIBUTE12,
       ATTRIBUTE13 = X_ATTRIBUTE13,
       ATTRIBUTE14 = X_ATTRIBUTE14,
       ATTRIBUTE15 = X_ATTRIBUTE15,
       LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
       LAST_UPDATED_BY = X_LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
       XPRT_VALUE_SET_NAME =X_XPRT_VALUE_SET_NAME,
       LINE_LEVEL_FLAG = X_LINE_LEVEL_FLAG,
       PROCEDURE_NAME = X_PROCEDURE_NAME,
       VARIABLE_SOURCE = X_VARIABLE_SOURCE, -- CLM Changes
       CLM_SOURCE = X_CLM_SOURCE, -- CLM Changes
       CLM_REF1 = X_CLM_REF1, -- CLM Changes
       CLM_REF2 = X_CLM_REF2, -- CLM Changes
       CLM_REF3 = X_CLM_REF3, -- CLM Changes
       CLM_REF4 = X_CLM_REF4, -- CLM Changes
       CLM_REF5 = X_CLM_REF5, -- CLM Changes
       MRV_FLAG = X_MRV_FLAG, -- MRV Changes
       MRV_TMPL_CODE = X_MRV_TMPL_CODE  -- MRV Changes
     where VARIABLE_CODE = X_VARIABLE_CODE;

     if (sql%notfound) then
       raise no_data_found;
     end if;

     update OKC_BUS_VARIABLES_TL set
       VARIABLE_NAME = X_VARIABLE_NAME,
       DESCRIPTION = X_DESCRIPTION,
       LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
       LAST_UPDATED_BY = X_LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
       SOURCE_LANG = userenv('LANG')
     where VARIABLE_CODE = X_VARIABLE_CODE
     and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

     if (sql%notfound) then
       raise no_data_found;
     end if;
   end UPDATE_ROW;

   procedure DELETE_ROW (
     X_VARIABLE_CODE in VARCHAR2
   ) is
   l_existing_variables_tbl     variable_code_tbl_type;

   CURSOR variable_doc_assoc_csr (cp_variable_code IN VARCHAR) IS
          SELECT VARIABLE_CODE FROM OKC_VARIABLE_DOC_TYPES
             WHERE VARIABLE_CODE = cp_variable_code;

   x_return_status          VARCHAR2(3000);
   x_msg_count              NUMBER;
   x_msg_data               VARCHAR2(3000);
   x_errorcode              NUMBER;

      CURSOR cur_ag_assoc
      IS
      SELECT  eo.ASSOCIATION_ID
       FROM okc_bus_variables_b b, fnd_objects o, EGO_OBJ_AG_ASSOCS_B  eo
       WHERE b.variable_code=X_VARIABLE_CODE
       AND   o.obj_name='OKC_K_ART_VARIABLES'
       AND   eo.ATTR_GROUP_ID=b.clm_ref1
       AND   eo.OBJECT_ID=o.object_id
       AND   eo.CLASSIFICATION_CODE=b.variable_code
       AND   b.mrv_flag='Y';


   BEGIN

     ---
     -- Delete ego ag associations.
     ---
     FOR ag_rec IN cur_ag_assoc
      LOOP
       EGO_EXT_FWK_PUB.Delete_Association (
         p_api_version                   => 1.0
        ,p_association_id               =>   ag_rec.ASSOCIATION_ID
        ,p_init_msg_list                 =>  fnd_api.g_FALSE
        ,p_commit                        =>  fnd_api.g_FALSE
        ,p_force                         =>  fnd_api.g_FALSE ,
         x_return_status                    => x_return_status,
         x_errorcode                        => x_errorcode,
         x_msg_count                        => x_msg_count,
         x_msg_data                         => x_msg_data

      );


      IF (l_debug = 'Y') THEN
        okc_debug.log('1740: EGO_EXT_FWK_PUB.Delete_Association completed in '||SQLERRM ||' Status for association' ||ag_rec.ASSOCIATION_ID , 2);

      END IF;
      END LOOP;

     delete from OKC_BUS_VARIABLES_TL
     where VARIABLE_CODE = X_VARIABLE_CODE;

     if (sql%notfound) then
      raise no_data_found;

     end if;

     delete from OKC_BUS_VARIABLES_B
     where VARIABLE_CODE = X_VARIABLE_CODE;

     if (sql%notfound) then
      raise no_data_found;
     end if;

     OPEN  variable_doc_assoc_csr(X_VARIABLE_CODE);
          FETCH variable_doc_assoc_csr BULK COLLECT INTO l_existing_variables_tbl;
          CLOSE  variable_doc_assoc_csr;

            IF l_existing_variables_tbl.COUNT > 0 Then
              FORALL i in l_existing_variables_tbl.FIRST .. l_existing_variables_tbl.LAST
                DELETE FROM OKC_VARIABLE_DOC_TYPES
                 WHERE VARIABLE_CODE = l_existing_variables_tbl(i);
                END IF;


    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
       Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_VAR_DEL_ERROR');
     WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1750: Leaving DELETE_ROW in OKC_BUSINESS_VARIABLES_PVT because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF variable_doc_assoc_csr%ISOPEN THEN
        CLOSE variable_doc_assoc_csr;
      END IF;
   end DELETE_ROW;

   procedure ADD_LANGUAGE
   is
   begin
     delete from OKC_BUS_VARIABLES_TL T
     where not exists
       (select NULL
       from OKC_BUS_VARIABLES_B B
       where B.VARIABLE_CODE = T.VARIABLE_CODE
       );

     update OKC_BUS_VARIABLES_TL T set (
         VARIABLE_NAME,
         DESCRIPTION
       ) = (select
         B.VARIABLE_NAME,
         B.DESCRIPTION
       from OKC_BUS_VARIABLES_TL B
       where B.VARIABLE_CODE = T.VARIABLE_CODE
       and B.LANGUAGE = T.SOURCE_LANG)
     where (
         T.VARIABLE_CODE,
         T.LANGUAGE
     ) in (select
         SUBT.VARIABLE_CODE,
         SUBT.LANGUAGE
       from OKC_BUS_VARIABLES_TL SUBB, OKC_BUS_VARIABLES_TL SUBT
       where SUBB.VARIABLE_CODE = SUBT.VARIABLE_CODE
       and SUBB.LANGUAGE = SUBT.SOURCE_LANG
       and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
         or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
         or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
         or SUBB.VARIABLE_NAME <> SUBT.VARIABLE_NAME
        ));

     insert into OKC_BUS_VARIABLES_TL (
       VARIABLE_CODE,
       VARIABLE_NAME,
       DESCRIPTION,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       LANGUAGE,
       SOURCE_LANG
     ) select
       B.VARIABLE_CODE,
       B.VARIABLE_NAME,
       B.DESCRIPTION,
       B.CREATED_BY,
       B.CREATION_DATE,
       B.LAST_UPDATE_DATE,
       B.LAST_UPDATED_BY,
       B.LAST_UPDATE_LOGIN,
       L.LANGUAGE_CODE,
       B.SOURCE_LANG
     from OKC_BUS_VARIABLES_TL B, FND_LANGUAGES L
     where L.INSTALLED_FLAG in ('I', 'B')
     and B.LANGUAGE = userenv('LANG')
     and not exists
       (select NULL
       from OKC_BUS_VARIABLES_TL T
       where T.VARIABLE_CODE = B.VARIABLE_CODE
       and T.LANGUAGE = L.LANGUAGE_CODE);
   end ADD_LANGUAGE;





END OKC_BUSINESS_VARIABLES_PVT;


/
