--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_REP_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_REP_INT_PVT" AS
/* $Header: OKCVXREPINTB.pls 120.0 2008/03/28 12:05:48 kkolukul noship $ */

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------

  G_FALSE                       CONSTANT VARCHAR2(1)    := FND_API.G_FALSE;
  G_TRUE                        CONSTANT VARCHAR2(1)    := FND_API.G_TRUE;

  G_RET_STS_SUCCESS             CONSTANT VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR               CONSTANT VARCHAR2(1)    := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR         CONSTANT VARCHAR2(1)    := FND_API.G_RET_STS_UNEXP_ERROR;

  G_PKG_NAME                    CONSTANT VARCHAR2(30)   := 'OKC_XPRT_REP_INT_PVT';
  G_MODULE_NAME			  CONSTANT VARCHAR2(250)  := 'OKC.PLSQL.'||G_PKG_NAME||'.';
  G_STMT_LEVEL				  CONSTANT NUMBER 		 := FND_LOG.LEVEL_STATEMENT;
  G_APP_NAME				  CONSTANT VARCHAR2(3)    := OKC_API.G_APP_NAME;

--Repository Specific Constants

  G_B_REP_CONTRACT_ADMIN     	  CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_CONTRACT_ADMIN'	;
  G_B_REP_CONTRACT_AMOUNT 	  CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_CONTRACT_AMOUNT'	;
  G_B_REP_CONTRACT_AUTH_PARTY 	  CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_CONTRACT_AUTH_PARTY'	;
  G_B_REP_CONTRACT_CURRENCY	  CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_CONTRACT_CURRENCY'	;
  G_B_REP_CONTRACT_EFF_DATE  	  CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_CONTRACT_EFF_DATE'  	;
  G_B_REP_CONTRACT_EXP_DATE   	  CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_CONTRACT_EXP_DATE'   	;
  G_B_REP_CONTRACT_NAME       	  CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_CONTRACT_NAME'       	;
  G_B_REP_CONTRACT_NUMBER   	  CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_CONTRACT_NUMBER'	;
  G_B_REP_CONTRACT_STATUS  	  CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_CONTRACT_STATUS'  	;
  G_B_REP_CONTRACT_TYPE   	  CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_CONTRACT_TYPE'   	;
  G_B_REP_CONTRACT_VERSION   	  CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_CONTRACT_VERSION'   	;
  G_B_REP_OPERATING_UNIT    	  CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_OPERATING_UNIT'    	;
  G_B_REP_OVERALL_RISK     	  CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_OVERALL_RISK'     	;
  G_B_REP_REF_DOC_TYPE 	          CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_REF_DOCUMENT_TYPE';
  G_B_REP_REF_DOC_NUMBER	  CONSTANT VARCHAR2(30)   := 		'OKC$B_REP_REF_DOCUMENT_NUMBER'	;

  G_S_REP_CONTRACT_ADMIN  	  CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_CONTRACT_ADMIN'  	;
  G_S_REP_CONTRACT_AMOUNT 	  CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_CONTRACT_AMOUNT' 	;
  G_S_REP_CONTRACT_AUTH_PARTY	  CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_CONTRACT_AUTH_PARTY'	;
  G_S_REP_CONTRACT_CURRENCY  	  CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_CONTRACT_CURRENCY'  	;
  G_S_REP_CONTRACT_EFF_DATE  	  CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_CONTRACT_EFF_DATE'  	;
  G_S_REP_CONTRACT_EXP_DATE  	  CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_CONTRACT_EXP_DATE'  	;
  G_S_REP_CONTRACT_NAME       	  CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_CONTRACT_NAME'       	;
  G_S_REP_CONTRACT_NUMBER    	  CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_CONTRACT_NUMBER'    	;
  G_S_REP_CONTRACT_STATUS   	  CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_CONTRACT_STATUS'   	;
  G_S_REP_CONTRACT_TYPE      	  CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_CONTRACT_TYPE'      	;
  G_S_REP_CONTRACT_VERSION  	  CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_CONTRACT_VERSION'  	;
  G_S_REP_OPERATING_UNIT    	  CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_OPERATING_UNIT'    	;
  G_S_REP_OVERALL_RISK       	  CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_OVERALL_RISK'       	;
  G_S_REP_REF_DOC_TYPE	          CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_REF_DOCUMENT_TYPE'	;
  G_S_REP_REF_DOC_NUMBER	  CONSTANT VARCHAR2(30)   := 		'OKC$S_REP_REF_DOCUMENT_NUMBER';



PROCEDURE get_clause_variable_values
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_sys_var_value_tbl          IN OUT NOCOPY OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)

IS

l_api_name 		VARCHAR2(30) := 'get_clause_variable_values';
l_package_procedure VARCHAR2(60);
l_api_version 		CONSTANT NUMBER := 1;
l_debug			Boolean;
l_module			VARCHAR2(250)   := G_MODULE_NAME||l_api_name;

  --
  --cursor to fetch all the values of Repository header level variables.
  --

  cursor c_get_repository_variables IS

     SELECT orc.contract_version_num,
       orc.contract_name,
       orc.contract_number,
       orc.contract_type,
       orc.contract_effective_date,
       orc.contract_expiration_date,
       orc.amount,
       fl.meaning contract_status,
       (SELECT name
        FROM   Hr_all_organization_units
        WHERE  organization_id = orc.org_id)   contract_organization,
       (SELECT nvl(pf.full_name, fu.user_name)
        FROM   Per_all_people_f   pf,
               fnd_user    fu
        WHERE  fu.user_id = orc.owner_id
        AND    pf.person_id (+) = fu.employee_id
        AND   (fu.employee_id IS NULL OR pf.effective_start_date = (SELECT MAX(effective_start_date)
                                                                    FROM   per_all_people_f
                                                                    WHERE  person_id = fu.employee_id)))  contract_owner,
       obd.name    contract_type_name,
       fl1.meaning  intent,
       (SELECT meaning
        FROM   okc_lookups_v
        WHERE  lookup_type = 'OKC_RISK_LEVELS'
        AND    lookup_code = orc.OVERALL_RISK_CODE)  overall_risk,
       (SELECT meaning
        FROM   okc_lookups_v
        WHERE  lookup_type = 'OKC_AUTHORING_PARTY'
        AND    lookup_code = orc.AUTHORING_PARTY_CODE)  authoring_party,
       Curr.Name currency_name,
       orc.reference_document_type,
       orc.reference_document_number
    FROM OKC_REP_CONTRACTS_ALL orc,
     okc_lookups_v  fl,
     okc_bus_doc_types_vl  obd,
     okc_lookups_v  fl1,
     Fnd_Currencies_Tl Curr
    WHERE orc.contract_id = p_doc_id
    AND   fl.lookup_type = 'OKC_REP_CONTRACT_STATUSES'
    AND   fl.lookup_code = orc.CONTRACT_STATUS_CODE
    AND   obd.document_type = orc.Contract_Type
    AND   fl1.lookup_type = 'OKC_REP_CONTRACT_INTENTS'
    AND   fl1.lookup_code = obd.intent
    AND   orc.Currency_Code = Curr.Currency_Code (+)
    AND   Curr.Language (+) = Userenv('LANG');

    l_rep_header_variables c_get_repository_variables%ROWTYPE;

BEGIN

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      l_debug := true;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_package_procedure := G_PKG_NAME || '.' || l_api_name;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'10: Entered ' || l_package_procedure);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'20: p_doc_type: ' || p_doc_type);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'30: p_doc_id: ' || p_doc_id);
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
   THEN
   	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
  	FND_MSG_PUB.initialize;
   END IF;

     -- Query REPOSITORY tables to retrieve values against variable codes sent in by calling contract expert API.

  IF p_sys_var_value_tbl.FIRST IS NOT NULL THEN

        OPEN c_get_repository_variables;
        FETCH c_get_repository_variables INTO l_rep_header_variables;

         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'70: Contract Administrator = '||l_rep_header_variables.contract_owner );
         END IF;

	CLOSE c_get_repository_variables;

	 FOR i IN p_sys_var_value_tbl.FIRST..p_sys_var_value_tbl.LAST LOOP

	--BUY intent Variables

	  IF p_sys_var_value_tbl(i).variable_code = G_B_REP_CONTRACT_ADMIN THEN
           p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_owner;

           ELSIF p_sys_var_value_tbl(i).variable_code = G_B_REP_CONTRACT_AMOUNT THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.amount;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_B_REP_CONTRACT_AUTH_PARTY THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.authoring_party;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_B_REP_CONTRACT_CURRENCY THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.currency_name;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_B_REP_CONTRACT_EFF_DATE THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_effective_date;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_B_REP_CONTRACT_EXP_DATE THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_expiration_date;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_B_REP_CONTRACT_NAME THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_name;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_B_REP_CONTRACT_NUMBER THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_number;

	   ELSIF p_sys_var_value_tbl(i).variable_code =  G_B_REP_CONTRACT_STATUS THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_status;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_B_REP_CONTRACT_TYPE THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_type_name;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_B_REP_CONTRACT_VERSION THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_version_num;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_B_REP_OPERATING_UNIT THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_organization;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_B_REP_OVERALL_RISK THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.overall_risk;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_B_REP_REF_DOC_TYPE THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.reference_document_type;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_S_REP_REF_DOC_NUMBER THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.reference_document_number;

	--SELL intent Variables

	  ELSIF p_sys_var_value_tbl(i).variable_code = G_S_REP_CONTRACT_ADMIN THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_owner;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_S_REP_CONTRACT_AMOUNT THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.amount;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_S_REP_CONTRACT_AUTH_PARTY THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables. authoring_party;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_S_REP_CONTRACT_CURRENCY THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.currency_name;

	   ELSIF p_sys_var_value_tbl(i).variable_code =  G_S_REP_CONTRACT_EFF_DATE THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_effective_date;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_S_REP_CONTRACT_EXP_DATE THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_expiration_date;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_S_REP_CONTRACT_NAME THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_name;

	   ELSIF p_sys_var_value_tbl(i).variable_code =  G_S_REP_CONTRACT_NUMBER THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_number;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_S_REP_CONTRACT_STATUS THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_status;

	   ELSIF p_sys_var_value_tbl(i).variable_code =  G_S_REP_CONTRACT_TYPE THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_type_name;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_S_REP_CONTRACT_VERSION THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_version_num;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_S_REP_OPERATING_UNIT THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.contract_organization;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_S_REP_OVERALL_RISK THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.overall_risk;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_S_REP_REF_DOC_TYPE THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.	reference_document_type;

	   ELSIF p_sys_var_value_tbl(i).variable_code =  G_S_REP_REF_DOC_NUMBER THEN
            p_sys_var_value_tbl(i).variable_value_id := l_rep_header_variables.reference_document_number;


	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'480: p_sys_var_value_tbl('||i||').variable_code     : '||p_sys_var_value_tbl(i).variable_code);
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'485: p_sys_var_value_tbl('||i||').variable_value_id : '||p_sys_var_value_tbl(i).variable_value_id);

     END IF;

     END IF;

     END LOOP;

  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'490: End of '||l_package_procedure||' for repository header level variables, x_return_status ' || x_return_status);
  END IF;

  EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
        IF c_get_repository_variables%ISOPEN THEN
	   CLOSE c_get_repository_variables;
	   END IF;

	x_return_status := FND_API.G_RET_STS_ERROR ;

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'500: '||l_package_procedure||' In the FND_API.G_EXC_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'510: x_return_status = '||x_return_status);
	END IF;

  	FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          	    p_data => x_msg_data  );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF c_get_repository_variables%ISOPEN THEN
           CLOSE c_get_repository_variables;
        END IF;

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'520: '||l_package_procedure||' In the FND_API.G_RET_STS_UNEXP_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'530: x_return_status = '||x_return_status);
	END IF;

  	FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          	    p_data => x_msg_data  );

     WHEN OTHERS THEN

        IF c_get_repository_variables%ISOPEN THEN
           CLOSE c_get_repository_variables;
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'540: '||l_package_procedure||' In the OTHERS section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'550: x_return_status = '||x_return_status);
	END IF;

    	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         	   FND_MSG_PUB.Add_Exc_Msg(
          	        G_PKG_NAME ,
          	        l_api_name );
  	END IF;

  	FND_MSG_PUB.Count_And_Get(
  	     p_count => x_msg_count,
       	 p_data => x_msg_data );

END get_clause_variable_values;

END OKC_XPRT_REP_INT_PVT;

/
