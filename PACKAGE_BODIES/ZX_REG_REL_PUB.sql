--------------------------------------------------------
--  DDL for Package Body ZX_REG_REL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_REG_REL_PUB" AS
/* $Header: zxcregrelpubb.pls 120.19 2006/03/16 07:48:14 hdudeja ship $ */

/* ==================================================================================================*
 | PROCEDURE insert_rel : Inserts records in the Tax Regime relations table and builds the hierarchy  |
 |			  Initially for the given child and parent a record is inserted with level 0  |
 |                        Further a hierarchy is created for the child based on the parents hierarchy.|
 * ==================================================================================================*/
PROCEDURE insert_rel
(
        x_return_status  OUT NOCOPY VARCHAR2,
        p_child          IN  VARCHAR2,
        p_parent         IN VARCHAR2,
	X_CREATED_BY in NUMBER,
	X_CREATION_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATE_LOGIN in NUMBER,
	X_REQUEST_ID in NUMBER,
	X_PROGRAM_ID in NUMBER,
	X_PROGRAM_LOGIN_ID in NUMBER,
	X_PROGRAM_APPLICATION_ID in NUMBER
	)
IS
CURSOR C1 is
          SELECT
          PARENT_REGIME_CODE,
          PARENT_REG_LEVEL+1 as lev
          from zx_regime_relations
          WHERE REGIME_CODE = p_parent;
R1  C1%rowtype;
l_level Number := 0;
BEGIN
   --  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
   --   Insert a record with level zero
        insert into zx_regime_relations (regime_rel_id,
                                        regime_code,
                                        parent_regime_code,
                                        parent_reg_level,
					CREATED_BY,
					CREATION_DATE,
					LAST_UPDATED_BY,
					LAST_UPDATE_DATE,
					LAST_UPDATE_LOGIN,
					REQUEST_ID,
					PROGRAM_ID,
					PROGRAM_LOGIN_ID,
					PROGRAM_APPLICATION_ID)
                                values (zx_regime_relations_s.NEXTVAL,
                                        p_child,
                                        p_parent,
                                        l_level,
					X_CREATED_BY,
					X_CREATION_DATE,
					X_LAST_UPDATED_BY,
					X_LAST_UPDATE_DATE,
					X_LAST_UPDATE_LOGIN,
					X_REQUEST_ID,
					X_PROGRAM_ID,
					X_PROGRAM_LOGIN_ID,
					X_PROGRAM_APPLICATION_ID);

  OPEN C1;
  LOOP
        FETCH C1 INTO R1;
	IF C1%NOTFOUND THEN
	   exit;
	END IF;
   --   Generating the hierarchy for the child based on the parent hierarchy
	insert into zx_regime_relations (regime_rel_id,                                                                                                             regime_code,
                                        parent_regime_code,
                                        parent_reg_level,
					CREATED_BY,
					CREATION_DATE,
					LAST_UPDATED_BY,
					LAST_UPDATE_DATE,
					LAST_UPDATE_LOGIN,
					REQUEST_ID,
					PROGRAM_ID,
					PROGRAM_LOGIN_ID,
					PROGRAM_APPLICATION_ID)
                                values (zx_regime_relations_s.NEXTVAL,
                                        p_child,
                                        R1.PARENT_REGIME_CODE,
                                        R1.LEV,
					X_CREATED_BY,
					X_CREATION_DATE,
					X_LAST_UPDATED_BY,
					X_LAST_UPDATE_DATE,
					X_LAST_UPDATE_LOGIN,
					X_REQUEST_ID,
					X_PROGRAM_ID,
					X_PROGRAM_LOGIN_ID,
					X_PROGRAM_APPLICATION_ID);

   END LOOP;
   close c1;
   EXCEPTION
     	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END insert_rel;

/* ================================================================================================*
| PROCEDURE update_rel : Updates records in Tax Regime relations table and rebuilds the hierarchy  |
|			 Initially for the given child, all records are deleted. The hierarchy is  |
|                        rebuild for the child. This process is repeated recursively for all the   |
|                        children of the given child.                                              |
|                                                               			           |
 * ===============================================================================================*/

PROCEDURE update_rel
(
        x_return_status  OUT NOCOPY VARCHAR2,
        p_child          IN  VARCHAR2,
        p_parent         IN  VARCHAR2 default null,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATE_LOGIN in NUMBER,
	X_REQUEST_ID in NUMBER,
	X_PROGRAM_ID in NUMBER,
	X_PROGRAM_LOGIN_ID in NUMBER,
	X_PROGRAM_APPLICATION_ID in NUMBER
	)
IS
CURSOR C1 is
       SELECT
       REGIME_CODE ,
       PARENT_REGIME_CODE
       FROM  zx_regime_relations
       WHERE PARENT_REGIME_CODE = p_child  AND
       PARENT_REG_LEVEL = 0;
 R1           C1%rowtype;
 l_err_status VARCHAR2(1) ;
BEGIN
     --  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
     -- Delete all the current records of the child
        Delete
        from zx_regime_relations
        where regime_code = p_child;
     -- Regenerate the child hierarchy with the new parent if the  p_parent is not null
       IF p_parent iS NOT NULL	THEN
	   insert_rel(l_err_status,p_child,p_parent,
	        -- for created by and created date use the same update by and update date
	        X_LAST_UPDATED_BY, X_LAST_UPDATE_DATE,
		X_LAST_UPDATED_BY, X_LAST_UPDATE_DATE,
		X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_ID,
		X_PROGRAM_LOGIN_ID, X_PROGRAM_APPLICATION_ID);
       END IF;
     -- Repeat the update process for all the children of the regime p_child
OPEN C1;
LOOP
	FETCH C1 INTO R1;
	IF C1%NOTFOUND THEN
		exit;
	END IF;
	update_rel(l_err_status,R1.REGIME_CODE,R1.PARENT_REGIME_CODE,
		X_LAST_UPDATED_BY, X_LAST_UPDATE_DATE,
		X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_ID,
		X_PROGRAM_LOGIN_ID, X_PROGRAM_APPLICATION_ID);

END LOOP;
close c1;
EXCEPTION
     	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     	       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	WHEN OTHERS THEN
	       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END;

/* ================================================================================================*
| PROCEDURE update_taxes : Updates records in Taxes table if the reporting tax authority or the    |
|			    collecting tax authority is updated in the tax regimes table and not   |
|                           overriddenin the taxes table.                                          |
* =================================================================================================*/

PROCEDURE update_taxes
(
          x_return_status  OUT NOCOPY VARCHAR2,
          p_regime_code          IN  VARCHAR2,
          p_old_rep_tax_auth_id      IN  NUMBER,
	  p_old_coll_tax_auth_id      IN  NUMBER,
          p_new_rep_tax_auth_id       IN  NUMBER,
	  p_new_coll_tax_auth_id      IN  NUMBER
)
IS
   CURSOR C1 is
     SELECT
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         Has_Tax_Point_Date_Rule_Flag,
         Print_On_Invoice_Flag,
         Use_Legal_Msg_Flag,
         Calc_Only_Flag,
         PRIMARY_RECOVERY_TYPE_CODE,
         Primary_Rec_Type_Rule_Flag,
         SECONDARY_RECOVERY_TYPE_CODE,
         Secondary_Rec_Type_Rule_Flag,
         Primary_Rec_Rate_Det_Rule_Flag,
         Sec_Rec_Rate_Det_Rule_Flag,
         Offset_Tax_Flag,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         Program_Login_Id,
         Record_Type_Code,
         Allow_Rounding_Override_Flag,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         Has_Exch_Rate_Date_Rule_Flag,
         Recovery_Rate_Override_Flag,
         TAX,
         TAX_ID,
         EFFECTIVE_FROM,
         EFFECTIVE_TO,
         TAX_REGIME_CODE,
         TAX_TYPE_CODE,
         Allow_Manual_Entry_Flag,
         Allow_Tax_Override_Flag,
         MIN_TXBL_BSIS_THRSHLD,
         MAX_TXBL_BSIS_THRSHLD,
         MIN_TAX_RATE_THRSHLD,
         MAX_TAX_RATE_THRSHLD,
         MIN_TAX_AMT_THRSHLD,
         MAX_TAX_AMT_THRSHLD,
         COMPOUNDING_PRECEDENCE,
         PERIOD_SET_NAME,
         EXCHANGE_RATE_TYPE,
         TAX_CURRENCY_CODE,
         REP_TAX_AUTHORITY_ID,
         COLL_TAX_AUTHORITY_ID,
         TAX_PRECISION,
         MINIMUM_ACCOUNTABLE_UNIT,
         Rounding_Rule_Code,
         Tax_Status_Rule_Flag,
         Tax_Rate_Rule_Flag,
         Def_Place_Of_Supply_Type_Code,
         Place_Of_Supply_Rule_Flag,
         Applicability_Rule_Flag,
         Tax_Calc_Rule_Flag,
         Txbl_Bsis_Thrshld_Flag,
         Tax_Rate_Thrshld_Flag,
         Tax_Amt_Thrshld_Flag,
         Taxable_Basis_Rule_Flag,
         Def_Inclusive_Tax_Flag,
         Thrshld_Grouping_Lvl_Code,
         Thrshld_Chk_Tmplt_Code,
         Has_Other_Jurisdictions_Flag,
         Allow_Exemptions_Flag,
         Allow_Exceptions_Flag,
         Allow_Recoverability_Flag,
         DEF_TAX_CALC_FORMULA,
         Tax_Inclusive_Override_Flag,
         DEF_TAXABLE_BASIS_FORMULA,
         Def_Registr_Party_Type_Code,
         Registration_Type_Rule_Flag,
         Reporting_Only_Flag,
         Auto_Prvn_Flag,
         Live_For_Processing_Flag,
         Has_Detail_Tb_Thrshld_Flag,
         Has_Tax_Det_Date_Rule_Flag,
         Regn_Num_Same_As_Le_Flag,
         ZONE_GEOGRAPHY_TYPE,
         Def_Rec_Settlement_Option_Code,
  	 Direct_Rate_Rule_Flag,
  	 CONTENT_OWNER_ID ,
  	 APPLIED_AMT_HANDLING_FLAG ,
	 PARENT_GEOGRAPHY_TYPE,
	 PARENT_GEOGRAPHY_ID,
	 ALLOW_MASS_CREATE_FLAG,
         TAX_FULL_NAME        ,
         LAST_UPDATE_DATE ,
         LAST_UPDATED_BY ,
         LAST_UPDATE_LOGIN,
	 SOURCE_TAX_FLAG,
	 SPECIAL_INCLUSIVE_TAX_FLAG,
	 DEF_PRIMARY_REC_RATE_CODE,
	 DEF_SECONDARY_REC_RATE_CODE,
	 ALLOW_DUP_REGN_NUM_FLAG,
         TAX_ACCOUNT_SOURCE_TAX,
         TAX_ACCOUNT_CREATE_METHOD_CODE,
	 OVERRIDE_GEOGRAPHY_TYPE,
         TAX_EXMPT_SOURCE_TAX,
         TAX_EXMPT_CR_METHOD_CODE,
         OBJECT_VERSION_NUMBER,
   	 LIVE_FOR_APPLICABILITY_FLAG,
         APPLICABLE_BY_DEFAULT_FLAG,
	 LEGAL_REPORTING_STATUS_DEF_VAL
     FROM	ZX_SCO_TAXES
    WHERE TAX_REGIME_CODE = p_regime_code;
    R1           C1%rowtype;
    update_flg  BOOLEAN := FALSE;
    l_rep_tax_auth_id NUMBER;
    l_coll_tax_auth_id NUMBER;
    BEGIN
        --  Initialize API return status to success
   	x_return_status := FND_API.G_RET_STS_SUCCESS;
        -- Check if update of reporting tax authority id or collecting tax authority has occurred..
    OPEN C1;
    LOOP
   	FETCH C1 INTO R1;
   		  EXIT WHEN C1%NOTFOUND ;
   	if (nvl(p_old_rep_tax_auth_id,-9999) = nvl(R1.REP_TAX_AUTHORITY_ID,-9999)) THEN
   			update_flg := TRUE;
                           l_rep_tax_auth_id :=  p_new_rep_tax_auth_id;
           ELSE
   			l_rep_tax_auth_id :=  R1.REP_TAX_AUTHORITY_ID;
   	END IF;
   	if (nvl(p_old_coll_tax_auth_id,-9999) = nvl(R1.COLL_TAX_AUTHORITY_ID,-9999)) THEN
   			update_flg := TRUE;
                           l_coll_tax_auth_id :=  p_new_coll_tax_auth_id;
           ELSE
   			l_coll_tax_auth_id :=  R1.COLL_TAX_AUTHORITY_ID;
   	END IF;
   	IF(update_flg) THEN
   	ZX_TAXES_PKG.UPDATE_ROW
   	   	(
   	   	  R1.TAX_ID ,
   		  R1.Recovery_Rate_Override_Flag ,
   		  R1.ATTRIBUTE13 ,
   		  R1.ATTRIBUTE14 ,
   		  R1.ATTRIBUTE15 ,
                  R1.ATTRIBUTE_CATEGORY ,
                  R1.ATTRIBUTE8 ,
   		  R1.ATTRIBUTE9 ,
   		  R1.ATTRIBUTE10 ,
   		  R1.ATTRIBUTE11 ,
                  R1.ATTRIBUTE12 ,
                  R1.Has_Tax_Point_Date_Rule_Flag ,
                  R1.Print_On_Invoice_Flag ,
   		  R1.Use_Legal_Msg_Flag ,
   		  R1.Calc_Only_Flag ,
   		  R1.PRIMARY_RECOVERY_TYPE_CODE    ,
   		  R1.Primary_Rec_Type_Rule_Flag     ,
   		  R1.SECONDARY_RECOVERY_TYPE_CODE  ,
   		  R1.Secondary_Rec_Type_Rule_Flag   ,
   		  R1.Primary_Rec_Rate_Det_Rule_Flag ,
   		  R1.Sec_Rec_Rate_Det_Rule_Flag     ,
   		  R1.Offset_Tax_Flag 		   ,
   		  R1.REQUEST_ID                    ,
   		  R1.PROGRAM_APPLICATION_ID        ,
   		  R1.PROGRAM_ID ,
   		  R1.Program_Login_Id ,
   		  R1.Record_Type_Code ,
   		  R1.Allow_Rounding_Override_Flag ,
   		  R1.ATTRIBUTE1 ,
   		  R1.ATTRIBUTE2 ,
   		  R1.ATTRIBUTE3 ,
   		  R1.ATTRIBUTE4 ,
   		  R1.ATTRIBUTE5 ,
   		  R1.ATTRIBUTE6 ,
   		  R1.ATTRIBUTE7 ,
   		  R1.Has_Exch_Rate_Date_Rule_Flag ,
   		  R1.TAX ,
   		  R1.EFFECTIVE_FROM ,
   		  R1.EFFECTIVE_TO ,
   		  R1.TAX_REGIME_CODE ,
   		  R1.TAX_TYPE_CODE ,
   		  R1.Allow_Manual_Entry_Flag ,
   		  R1.Allow_Tax_Override_Flag ,
   		  R1.MIN_TXBL_BSIS_THRSHLD ,
   		  R1.MAX_TXBL_BSIS_THRSHLD ,
   		  R1.MIN_TAX_RATE_THRSHLD ,
   		  R1.MAX_TAX_RATE_THRSHLD ,
   		  R1.MIN_TAX_AMT_THRSHLD ,
   		  R1.MAX_TAX_AMT_THRSHLD ,
   		  R1.COMPOUNDING_PRECEDENCE ,
   		  R1.PERIOD_SET_NAME ,
   		  R1.EXCHANGE_RATE_TYPE ,
   		  R1.TAX_CURRENCY_CODE ,
   		  l_rep_tax_auth_id,
   		  l_coll_tax_auth_id ,
   		  R1.TAX_PRECISION ,
   		  R1.MINIMUM_ACCOUNTABLE_UNIT ,
   		  R1.Rounding_Rule_Code ,
   		  R1.Tax_Status_Rule_Flag ,
   		  R1.Tax_Rate_Rule_Flag ,
   		  R1.Def_Place_Of_Supply_Type_Code ,
   		  R1.Place_Of_Supply_Rule_Flag ,
   		  R1.Applicability_Rule_Flag ,
   		  R1.Tax_Calc_Rule_Flag ,
   		  R1.Txbl_Bsis_Thrshld_Flag ,
   		  R1.Tax_Rate_Thrshld_Flag ,
   		  R1.Tax_Amt_Thrshld_Flag ,
   		  R1.Taxable_Basis_Rule_Flag ,
   		  R1.Def_Inclusive_Tax_Flag ,
   		  R1.Thrshld_Grouping_Lvl_Code ,
   		  R1.Thrshld_Chk_Tmplt_Code ,
   		  R1.Has_Other_Jurisdictions_Flag ,
   		  R1.Allow_Exemptions_Flag ,
   		  R1.Allow_Exceptions_Flag ,
   		  R1.Allow_Recoverability_Flag ,
   		  R1.DEF_TAX_CALC_FORMULA ,
   		  R1.Tax_Inclusive_Override_Flag ,
   		  R1.DEF_TAXABLE_BASIS_FORMULA ,
   		  R1.Def_Registr_Party_Type_Code ,
   		  R1.Registration_Type_Rule_Flag ,
   		  R1.Reporting_Only_Flag ,
   		  R1.Auto_Prvn_Flag ,
   		  R1.Live_For_Processing_Flag ,
   		  R1.Has_Detail_Tb_Thrshld_Flag ,
   		  R1.Has_Tax_Det_Date_Rule_Flag ,
   		  R1.TAX_FULL_NAME ,
   		  R1.ZONE_GEOGRAPHY_TYPE ,
   		  R1.Def_Rec_Settlement_Option_Code ,
   		  SYSDATE,
   		  fnd_global.user_id,
   		  FND_GLOBAL.CONC_LOGIN_ID,
   		  R1.Regn_Num_Same_As_Le_Flag  ,
     	          R1.Direct_Rate_Rule_Flag,
  		  R1.CONTENT_OWNER_ID ,
  		  R1.APPLIED_AMT_HANDLING_FLAG,
		  R1.PARENT_GEOGRAPHY_TYPE,
		  R1.PARENT_GEOGRAPHY_ID,
		  R1.ALLOW_MASS_CREATE_FLAG,
		  R1.SOURCE_TAX_FLAG,
		  R1.SPECIAL_INCLUSIVE_TAX_FLAG,
		  R1.DEF_PRIMARY_REC_RATE_CODE,
		  R1.DEF_SECONDARY_REC_RATE_CODE,
		  R1.ALLOW_DUP_REGN_NUM_FLAG,
		  R1.TAX_ACCOUNT_SOURCE_TAX,
                  R1.TAX_ACCOUNT_CREATE_METHOD_CODE,
                  R1.OVERRIDE_GEOGRAPHY_TYPE,
                  R1.TAX_EXMPT_SOURCE_TAX,
                  R1.TAX_EXMPT_CR_METHOD_CODE,
                  R1.OBJECT_VERSION_NUMBER,
 		  R1.LIVE_FOR_APPLICABILITY_FLAG,
                  R1.APPLICABLE_BY_DEFAULT_FLAG,
		  R1.LEGAL_REPORTING_STATUS_DEF_VAL
     	  );
   	END IF;
   END LOOP;
   close c1;
   EXCEPTION
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
end;

/* ===================================================================================================*
 | PROCEDURE get_regime_details: Obtains the regime details based on the country code or tax regime code|
 |                      				                                                |
 * ===================================================================================================*/

PROCEDURE get_regime_details
(
        x_return_status  OUT NOCOPY VARCHAR2,
        p_country_code   IN  VARCHAR2 default null,
        p_tax_regime_code IN VARCHAR2 default null,
        x_regime_rec  OUT NOCOPY regime_rec_arr_type
)
IS
CURSOR C1 is
          SELECT
          TAX_REGIME_CODE,
          TAX_REGIME_NAME
          from zx_REGIMES_VL
          WHERE TAX_REGIME_CODE = p_tax_regime_code;
R1  C1%rowtype;
CURSOR C2 is
          SELECT
          TAX_REGIME_CODE,
          TAX_REGIME_NAME
          from zx_REGIMES_VL
          WHERE COUNTRY_CODE = p_country_code;
R2  C2%rowtype;
l_num NUMBER := 1;
BEGIN
   --  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
	IF (p_country_code is null AND p_tax_regime_code is not null) THEN
	   OPEN C1;
           LOOP
		FETCH C1 INTo R1;
		EXIT WHEN C1%NOTFOUND;
                x_regime_rec(l_num).regime_code := R1.tax_regime_code;
                x_regime_rec(l_num).regime_name := R1.tax_regime_name;
                l_num := l_num + 1;
  	   END LOOP;
           CLOSE C1;
        ELSIF (p_country_code is not null AND p_tax_regime_code is null) THEN
  	   OPEN C2;
           LOOP
		FETCH C2 INTo R2;
		EXIT WHEN C2%NOTFOUND;
                x_regime_rec(l_num).regime_code := R2.tax_regime_code;
                x_regime_rec(l_num).regime_name := R2.tax_regime_name;
                l_num := l_num + 1;
  	   END LOOP;
           CLOSE C2;
	 ELSE
		x_return_status := 'WRONG INPUT PARAMETERS';
	 END IF;
   EXCEPTION
     	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN                                                                                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	WHEN OTHERS THEN
      		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END get_regime_details;
/* ===============================================================================================*
 | PROCEDURE get_regime_hierarchy: Obtains the regime relations based on the tax regime code      |
 * ==============================================================================================*/

PROCEDURE get_regime_hierarchy
(
        x_return_status  OUT NOCOPY VARCHAR2,
        p_tax_regime_code IN VARCHAR2 default null,
        x_regime_level_rec  OUT NOCOPY regime_rec_level_arr_type
)
IS
CURSOR C1 is
          SELECT
          REGIME_CODE,
          PARENT_REGIME_CODE,
          PARENT_REG_LEVEL
          from zx_REGIME_RELATIONS
          WHERE REGIME_CODE = p_tax_regime_code;
R1  C1%rowtype;
l_num NUMBER := 1;
BEGIN
   --  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
   --   Insert a record with level zero
	IF (p_tax_regime_code is not null) THEN
	   OPEN C1;
           LOOP
		FETCH C1 into R1;
		EXIT WHEN C1%NOTFOUND;
	        x_regime_level_rec(l_num).regime_code := R1.regime_code;
                x_regime_level_rec(l_num).parent_regime_code := R1.parent_regime_code;
                x_regime_level_rec(l_num).level := R1.parent_reg_level;
                l_num := l_num + 1;
   	   END LOOP;
           CLOSE C1;
	 ELSE
  	   x_return_status := 'WRONG INPUT PARAMETERS';
	 END IF;
   EXCEPTION
     	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN                                                                                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	WHEN OTHERS THEN                                                                                                                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END get_regime_hierarchy;
END;

/
