--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_CUSTOM_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_CUSTOM_PACKAGE" AS
/* $Header: okcxprtudvtestprocb.pls 120.8.12010000.2 2008/12/17 10:14:28 kkolukul noship $ */

    -- Define GLOBAL CONSTANTS
    -- Always use the package name and procedure name in error messages
    -- for easy debug

    G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_XPRT_CUSTOM_PACKAGE';
    G_APP_NAME                   CONSTANT   VARCHAR2(3)   := OKC_API.G_APP_NAME;
    G_MODULE                     CONSTANT   VARCHAR2(250) := 'okc.plsql.'||g_pkg_name||'.';


    -- The following lines define true, false and product constants


    G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
    G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
    G_OKC                        CONSTANT   VARCHAR2(3) := 'OKC';

    --
    -- The following lines define The return status from the procedure
    -- The procedure must return on of these statuses in X_RETURN_STATUS
    --

    G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
    G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
    G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

    G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
    G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
    G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';


    PROCEDURE GET_OE_HEADER_VALUES (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	   P_VARIABLE_CODE		IN VARCHAR2,
	   X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	)
    IS


        -- TO CUSTOMIZE: Change the l_api_name value to this custom procedure
	--               Define local variables for variables addressed in this API
	--               Create appropriate cursor statements (use p_doc_id parameter)

           l_api_name		CONSTANT VARCHAR2(30) := 'GET_OE_HEADER_VALUES';

	   l_blanket_number	OE_ORDER_HEADERS_ALL.BLANKET_NUMBER%TYPE;
	   l_user_status_code	OE_ORDER_HEADERS_ALL.USER_STATUS_CODE%TYPE;
	   l_context		OE_ORDER_HEADERS_ALL.CONTEXT%TYPE;


	   --
	   -- Define Cursor to read the variable value for the document
	   -- If you are reading data from multiple tables with multiple SELECT statements,
	   -- define all cursors here with appropriate names.
	   --
	   -- The following cursor is defined to retrieve values for the user defined variables
	   -- for a sales order (DOCUMENT_TYPE = 'O')
	   --
        Cursor l_oe_header_csr Is
	    SELECT BLANKET_NUMBER,
                   USER_STATUS_CODE,
                   CONTEXT
	    FROM OE_ORDER_HEADERS_ALL
	    WHERE HEADER_ID = p_doc_id;

    BEGIN


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

	x_return_status := G_RET_STS_SUCCESS;



        -- TO CUSTOMIZE: Check for appropriate P_DOC_TYPE
        --               Change cursor names and INTO variables with local variables defined above
        --               Modify IF...ELSE statements appropriately to assign correct value to the our parameter


	IF P_DOC_TYPE = 'O' THEN
              OPEN l_oe_header_csr;
	      FETCH l_oe_header_csr INTO l_blanket_number, l_user_status_code, l_context;
	      CLOSE l_oe_header_csr;

              IF P_VARIABLE_CODE = 'OE$BLANKET_NUMBER' THEN
			            X_VARIABLE_VALUE_ID := l_blanket_number;

              ELSIF P_VARIABLE_CODE = 'OE$USER_STATUS_CODE' THEN
			            X_VARIABLE_VALUE_ID := l_user_status_code;

              ELSIF P_VARIABLE_CODE = 'OE$CONTEXT' THEN
			            X_VARIABLE_VALUE_ID := l_context;

              END IF;
        END IF;


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Variable Codes along with values:');

              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
			     'Variable Code and Value' || ' ' || P_VARIABLE_CODE ||
	                     ' = ' || X_VARIABLE_VALUE_ID );

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

    EXCEPTION
        --
        -- retain all error handling below as it is. Do not change
	--

        -- TO CUSTOMIZE: Close all cursors
        --               DO NOT delete debug statements.
	--               Add more debug statements if required. Follow the same structure for debug statements


        WHEN FND_API.G_EXC_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1001: Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_oe_header_csr%ISOPEN THEN
                CLOSE l_oe_header_csr;
            END IF;

	    --
	    -- if you have more cursors, add cursor closing statements here as shown above
	    --

            x_return_status := G_RET_STS_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded =>'F',
		                            p_count   => x_msg_count,
		                            p_data    => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1002: Unexpected Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_oe_header_csr%ISOPEN THEN
                CLOSE l_oe_header_csr;
            END IF;

	    --
	    -- if you have more cursors, add close cursor statements here as shown above
	    --

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1003: Other Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_oe_header_csr%ISOPEN THEN
                CLOSE l_oe_header_csr;
            END IF;

	    --
            -- if you have more cursors, add close cursor statements here as shown above
	    --

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    END GET_OE_HEADER_VALUES;


    PROCEDURE GET_PRICE_UPDATE_TOLERANCE (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	)
    IS

       l_api_name		CONSTANT VARCHAR2(30) := 'GET_PRICE_UPDATE_TOLERANCE';

	   l_price_update_tolerance	PO_HEADERS_ALL.PRICE_UPDATE_TOLERANCE%TYPE;


        Cursor l_price_update_csr Is
	   		select PRICE_UPDATE_TOLERANCE from PO_HEADERS_ALL
                                WHERE po_header_id = P_DOC_ID ;

		--AND TYPE_LOOKUP_CODE = P_DOC_TYPE

    BEGIN

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

	x_return_status := G_RET_STS_SUCCESS;


	OPEN l_price_update_csr;
	      FETCH l_price_update_csr INTO l_price_update_tolerance;
	      dbms_output.put_line('l_price_update_tolerance IS '||l_price_update_tolerance);
	      l_price_update_tolerance := l_price_update_tolerance+10;
	CLOSE l_price_update_csr;

	      IF  ( P_VARIABLE_CODE = 'PO$PRICE_TOLERANCE1' OR P_VARIABLE_CODE = 'PO$PRICE_TOLERANCE' ) AND P_DOC_TYPE = 'PA_BLANKET' THEN
				  X_VARIABLE_VALUE_ID := l_price_update_tolerance;
	      END IF;


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Variable Codes along with values:');

          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
			     'Variable Code and Value' || ' ' || P_VARIABLE_CODE ||
	                     ' = ' || X_VARIABLE_VALUE_ID );

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
    END IF;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1001: Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_price_update_csr%ISOPEN THEN
                CLOSE l_price_update_csr;
            END IF;


            x_return_status := G_RET_STS_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded =>'F',
		                            p_count   => x_msg_count,
		                            p_data    => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1002: Unexpected Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_price_update_csr%ISOPEN THEN
                CLOSE l_price_update_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1003: Other Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_price_update_csr%ISOPEN THEN
                CLOSE l_price_update_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    END GET_PRICE_UPDATE_TOLERANCE;

    PROCEDURE GET_QUOTE_SALES_SUPPLEMENT (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE		 IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	 IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	)
    IS

        l_api_name CONSTANT VARCHAR2(30) := 'GET_QUOTE_SALES_SUPPLEMENT';
        l_tmp_instance_id     ASO_SUP_tmpl_INSTANCE.TEMPLATE_INSTANCE_ID%TYPE;
        l_tmp_value           ASO_SUP_INSTANCE_VALUE.value%TYPE;
        l_tmp1_value          ASO_SUP_INSTANCE_VALUE.value%TYPE;
        l_tmp2_value          ASO_SUP_response_tl.response_name%TYPE;



 	    Cursor l_tmp_instance_csr is
        SELECT TEMPLATE_INSTANCE_ID FROM ASO_SUP_tmpl_INSTANCE  where owner_table_id = P_DOC_ID;

   	--cursor to get text values
        Cursor l_sup_value_csr(p_tmp_instace_id number,p_comp_name varchar2) is
        SELECT value FROM ASO_SUP_INSTANCE_VALUE
        WHERE template_instance_id = p_tmp_instace_id
        AND value is not null;
--        AND sect_comp_map_id =
--      (select component_id from ASO_SUP_component_tl where component_name = p_comp_name and language =  'US');


        --cursor to get LOV values
        -- Modified on 03232007 to return Value id instead of Value name from fnd_flex_values_vl

        Cursor l_sup_lov_value_csr(p_tmp_instace_id number,p_comp_name varchar2) is
	        SELECT flex_value_id
	          FROM fnd_flex_values_vl
	         WHERE flex_value_set_id = (SELECT flex_value_set_id
	                                      FROM fnd_flex_value_sets
        			             -- Added the Flex vbalue set where condition again on 04162007
	                                     WHERE flex_value_set_name	= 'Industry Type') --1022577 -- Need to be known from setup for 'Industry Type'
	           AND flex_value =  (SELECT response_name
	                                FROM ASO_SUP_response_tl
	                               WHERE response_id IN (SELECT response_id
	                                                       FROM ASO_SUP_INSTANCE_VALUE
	                                                      WHERE template_instance_id = p_tmp_instace_id)
                                         AND language = USERENV('LANG'));

        --Cursor l_sup_lov_value_csr(p_tmp_instace_id number,p_comp_name varchar2) is
        --select response_name from ASO_SUP_response_tl where response_id in
        --(SELECT response_id FROM ASO_SUP_INSTANCE_VALUE WHERE template_instance_id = p_tmp_instace_id)
        --and language = 'US';


    BEGIN

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;


	x_return_status := G_RET_STS_SUCCESS;

    dbms_output.put_line('start of proc ');
	OPEN l_tmp_instance_csr;
	FETCH l_tmp_instance_csr INTO l_tmp_instance_id;
	CLOSE l_tmp_instance_csr;
	dbms_output.put_line('l_tmp_instance_id IS '||l_tmp_instance_id);

	OPEN l_sup_value_csr(l_tmp_instance_id,'Benefit');
	FETCH l_sup_value_csr INTO l_tmp_value;
	CLOSE l_sup_value_csr;
	dbms_output.put_line('l_tmp_value IS '||l_tmp_value);

	OPEN l_sup_value_csr(l_tmp_instance_id,'Name of VAD');
	FETCH l_sup_value_csr INTO l_tmp1_value;
	CLOSE l_sup_value_csr;
	dbms_output.put_line('l_tmp1_value IS '||l_tmp1_value);

	--getting lov value
	OPEN l_sup_lov_value_csr(l_tmp_instance_id,'Industry-Type');
	FETCH l_sup_lov_value_csr INTO l_tmp2_value;
	CLOSE l_sup_lov_value_csr;
	dbms_output.put_line('l_tmp2_value IS '||l_tmp2_value);


	IF P_VARIABLE_CODE  = 'QUOTE$SUP_VAD' THEN
		X_VARIABLE_VALUE_ID := l_tmp_value;
	ELSIF P_VARIABLE_CODE = 'QUOTE$BENEFIT' THEN
		X_VARIABLE_VALUE_ID := l_tmp1_value;
	ELSIF P_VARIABLE_CODE  = 'QUOTE$INDL' THEN
		X_VARIABLE_VALUE_ID := l_tmp2_value;
	END IF;


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Variable Codes along with values:');

		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
			     'Variable Code and Value' || ' ' || P_VARIABLE_CODE ||
	                     ' = ' || X_VARIABLE_VALUE_ID );

		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
	END IF;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1001: Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;


        x_return_status := G_RET_STS_ERROR ;
    	FND_MSG_PUB.Count_And_Get(p_encoded =>'F',
		                            p_count   => x_msg_count,
		                            p_data    => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1002: Unexpected Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN

	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1003: Other Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;


            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    END GET_QUOTE_SALES_SUPPLEMENT;

        PROCEDURE GET_SHIP_WAREHOUSE (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	)
    IS

       l_api_name		CONSTANT VARCHAR2(30) := 'GET_SHIP_WAREHOUSE';

	   l_ship_warehouse	MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;


        Cursor l_ship_warehouse_csr Is
		SELECT SHIP_FROM_ORG_ID
                FROM OE_BLANKET_HEADERS_ALL
                WHERE HEADER_ID = P_DOC_ID;

    BEGIN

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

	x_return_status := G_RET_STS_SUCCESS;


	OPEN l_ship_warehouse_csr;
	      FETCH l_ship_warehouse_csr INTO l_ship_warehouse;
	CLOSE l_ship_warehouse_csr;

	      IF P_VARIABLE_CODE = 'SA$WHS' AND P_DOC_TYPE = 'B'  THEN
				  X_VARIABLE_VALUE_ID := l_ship_warehouse;
	      END IF;


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Variable Codes along with values:');

          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
			     'Variable Code and Value' || ' ' || P_VARIABLE_CODE ||
	                     ' = ' || X_VARIABLE_VALUE_ID );

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
    END IF;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1001: Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_ship_warehouse_csr%ISOPEN THEN
                CLOSE l_ship_warehouse_csr;
            END IF;


            x_return_status := G_RET_STS_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded =>'F',
		                            p_count   => x_msg_count,
		                            p_data    => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1002: Unexpected Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_ship_warehouse_csr%ISOPEN THEN
                CLOSE l_ship_warehouse_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1003: Other Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_ship_warehouse_csr%ISOPEN THEN
                CLOSE l_ship_warehouse_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    END GET_SHIP_WAREHOUSE;

    PROCEDURE GET_SOURCING_UOM (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	)
    IS

       l_api_name		CONSTANT VARCHAR2(30) := 'GET_SOURCING_UOM';

       l_uom_code	PON_AUCTION_ITEM_PRICES_ALL.UOM_CODE%TYPE;


        Cursor l_rfq_uom_code_csr Is
            SELECT UOM
            FROM PON_BID_ITEM_PRICES
            WHERE BID_NUMBER = P_DOC_ID;

        Cursor l_quote_uom_code_csr Is
            SELECT UOM_CODE
            FROM PON_AUCTION_ITEM_PRICES_ALL
            WHERE BEST_BID_NUMBER = P_DOC_ID;

    BEGIN

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

	x_return_status := G_RET_STS_SUCCESS;


	IF (P_VARIABLE_CODE = 'RF$UOM' OR P_VARIABLE_CODE = 'RFQ$UOM') THEN
  	  IF P_DOC_TYPE = 'RFQ' THEN
 	    OPEN l_rfq_uom_code_csr;
 	    FETCH l_rfq_uom_code_csr INTO l_uom_code;
 	    CLOSE l_rfq_uom_code_csr;
 	  END IF;

	  IF P_DOC_TYPE = 'RFQ_RESPONSE' THEN
	    OPEN l_quote_uom_code_csr;
	    FETCH l_quote_uom_code_csr INTO l_uom_code;
	    CLOSE l_quote_uom_code_csr;
	  END IF;

	  X_VARIABLE_VALUE_ID := l_uom_code;
	END IF;


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Variable Codes along with values:');

          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
			     'Variable Code and Value' || ' ' || P_VARIABLE_CODE ||
	                     ' = ' || X_VARIABLE_VALUE_ID );

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
    END IF;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1001: Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_rfq_uom_code_csr%ISOPEN THEN
                CLOSE l_rfq_uom_code_csr;
            END IF;

            IF l_quote_uom_code_csr%ISOPEN THEN
                CLOSE l_quote_uom_code_csr;
            END IF;


            x_return_status := G_RET_STS_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded =>'F',
		                            p_count   => x_msg_count,
		                            p_data    => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1002: Unexpected Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_rfq_uom_code_csr%ISOPEN THEN
                CLOSE l_rfq_uom_code_csr;
            END IF;

            IF l_quote_uom_code_csr%ISOPEN THEN
                CLOSE l_quote_uom_code_csr;
            END IF;


            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1003: Other Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_rfq_uom_code_csr%ISOPEN THEN
                CLOSE l_rfq_uom_code_csr;
            END IF;

            IF l_quote_uom_code_csr%ISOPEN THEN
                CLOSE l_quote_uom_code_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    END GET_SOURCING_UOM;

       PROCEDURE GET_PO_UOM (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	)
    IS

       l_api_name		CONSTANT VARCHAR2(30) := 'GET_PO_UOM';

	   l_uom_code	PO_LINES_ALL.UNIT_MEAS_LOOKUP_CODE%TYPE;


        -- Modified the cursor for bug 6010684
        Cursor l_uom_code_csr Is
        SELECT UOM_CODE
	  FROM MTL_UNITS_OF_MEASURE
         WHERE UNIT_OF_MEASURE = (SELECT UNIT_MEAS_LOOKUP_CODE
                                    FROM PO_LINES_ALL
                                   WHERE PO_HEADER_ID = P_DOC_ID);
        --Cursor l_uom_code_csr Is
        --SELECT UNIT_MEAS_LOOKUP_CODE
        --FROM PO_LINES_ALL
        --WHERE PO_HEADER_ID = P_DOC_ID;

    BEGIN

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

	x_return_status := G_RET_STS_SUCCESS;


	OPEN l_uom_code_csr;
	      FETCH l_uom_code_csr INTO l_uom_code;
	CLOSE l_uom_code_csr;

	      IF (P_VARIABLE_CODE = 'PO$UOM' OR P_VARIABLE_CODE = 'POS$UOM') AND P_DOC_TYPE = 'PO_STANDARD' THEN
				  X_VARIABLE_VALUE_ID := l_uom_code;
	      END IF;


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Variable Codes along with values:');

          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
			     'Variable Code and Value' || ' ' || P_VARIABLE_CODE ||
	                     ' = ' || X_VARIABLE_VALUE_ID );

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
    END IF;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1001: Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_uom_code_csr%ISOPEN THEN
                CLOSE l_uom_code_csr;
            END IF;


            x_return_status := G_RET_STS_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded =>'F',
		                            p_count   => x_msg_count,
		                            p_data    => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1002: Unexpected Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_uom_code_csr%ISOPEN THEN
                CLOSE l_uom_code_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1003: Other Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_uom_code_csr%ISOPEN THEN
                CLOSE l_uom_code_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    END GET_PO_UOM;

       PROCEDURE GET_RELEASE_RATIO (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	)
    IS

       l_api_name		CONSTANT VARCHAR2(30) := 'GET_RELEASE_RATIO';

	   l_release_ratio	NUMBER;


        Cursor l_release_ratio_csr Is
        SELECT NVL(MIN_RELEASE_AMOUNT,0)/NVL(AMOUNT_LIMIT, 1)
        FROM PO_HEADERS_ALL
        WHERE PO_HEADER_ID = P_DOC_ID;

    BEGIN

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

	x_return_status := G_RET_STS_SUCCESS;


	OPEN l_release_ratio_csr;
	      FETCH l_release_ratio_csr INTO l_release_ratio;
	CLOSE l_release_ratio_csr;

	      IF P_VARIABLE_CODE = 'PO$RELRAT' AND P_DOC_TYPE = 'PA_BLANKET' THEN
				  X_VARIABLE_VALUE_ID := l_release_ratio;
	      END IF;


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Variable Codes along with values:');

          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
			     'Variable Code and Value' || ' ' || P_VARIABLE_CODE ||
	                     ' = ' || X_VARIABLE_VALUE_ID );

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
    END IF;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1001: Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_release_ratio_csr%ISOPEN THEN
                CLOSE l_release_ratio_csr;
            END IF;


            x_return_status := G_RET_STS_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded =>'F',
		                            p_count   => x_msg_count,
		                            p_data    => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1002: Unexpected Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_release_ratio_csr%ISOPEN THEN
                CLOSE l_release_ratio_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1003: Other Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_release_ratio_csr%ISOPEN THEN
                CLOSE l_release_ratio_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    END GET_RELEASE_RATIO;

    PROCEDURE GET_BLANKET_AMOUNT_RANGE (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	)
    IS

       l_api_name		CONSTANT VARCHAR2(30) := 'GET_BLANKET_AMOUNT_RANGE';

	   l_blanket_amount_range	NUMBER;


        Cursor l_blanket_amount_range_csr Is
        SELECT BLANKET_MAX_AMOUNT - BLANKET_MIN_AMOUNT
        FROM OE_BLANKET_HEADERS_EXT
        WHERE ORDER_NUMBER = (SELECT ORDER_NUMBER
                              FROM OE_BLANKET_HEADERS_ALL
                              WHERE HEADER_ID = P_DOC_ID);

    BEGIN

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

	x_return_status := G_RET_STS_SUCCESS;


	OPEN l_blanket_amount_range_csr;
	      FETCH l_blanket_amount_range_csr INTO l_blanket_amount_range;
	CLOSE l_blanket_amount_range_csr;

	      IF P_VARIABLE_CODE = 'SA$BLRAN' AND P_DOC_TYPE = 'B' THEN
				  X_VARIABLE_VALUE_ID := l_blanket_amount_range;
	      END IF;


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Variable Codes along with values:');

          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
			     'Variable Code and Value' || ' ' || P_VARIABLE_CODE ||
	                     ' = ' || X_VARIABLE_VALUE_ID );

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
    END IF;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1001: Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_blanket_amount_range_csr%ISOPEN THEN
                CLOSE l_blanket_amount_range_csr;
            END IF;


            x_return_status := G_RET_STS_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded =>'F',
		                            p_count   => x_msg_count,
		                            p_data    => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1002: Unexpected Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_blanket_amount_range_csr%ISOPEN THEN
                CLOSE l_blanket_amount_range_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1003: Other Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_blanket_amount_range_csr%ISOPEN THEN
                CLOSE l_blanket_amount_range_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    END GET_BLANKET_AMOUNT_RANGE;

    PROCEDURE GET_DFF_PO (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	)
    IS

       l_api_name		CONSTANT VARCHAR2(30) := 'GET_DFF_PO';

	   l_attribute4_val	PO_HEADERS_ALL.ATTRIBUTE4%TYPE;


        Cursor l_attribute4_val_csr Is
        SELECT ATTRIBUTE4
        FROM PO_HEADERS_ALL
        WHERE PO_HEADER_ID = P_DOC_ID;

    BEGIN

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

	x_return_status := G_RET_STS_SUCCESS;


	OPEN l_attribute4_val_csr;
	      FETCH l_attribute4_val_csr INTO l_attribute4_val;
	CLOSE l_attribute4_val_csr;

	      IF P_VARIABLE_CODE = 'PO$DFF' AND P_DOC_TYPE IN ( 'PA_BLANKET', 'PO_STANDARD') THEN
				  X_VARIABLE_VALUE_ID := l_attribute4_val;
	      END IF;


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Variable Codes along with values:');

          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
			     'Variable Code and Value' || ' ' || P_VARIABLE_CODE ||
	                     ' = ' || X_VARIABLE_VALUE_ID );

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
    END IF;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1001: Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_attribute4_val_csr%ISOPEN THEN
                CLOSE l_attribute4_val_csr;
            END IF;


            x_return_status := G_RET_STS_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded =>'F',
		                            p_count   => x_msg_count,
		                            p_data    => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1002: Unexpected Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_attribute4_val_csr%ISOPEN THEN
                CLOSE l_attribute4_val_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1003: Other Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_attribute4_val_csr%ISOPEN THEN
                CLOSE l_attribute4_val_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    END GET_DFF_PO;

    PROCEDURE GET_DFF_SA (
        P_DOC_TYPE		     IN VARCHAR2,
        P_DOC_ID		     IN NUMBER,
	    P_VARIABLE_CODE			IN VARCHAR2,
    	X_VARIABLE_VALUE_ID	IN OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
        X_MSG_COUNT		     OUT NOCOPY NUMBER,
        X_MSG_DATA		     OUT NOCOPY VARCHAR2
	)
    IS

       l_api_name		CONSTANT VARCHAR2(30) := 'GET_DFF_SA';

	   l_attribute4_val	OE_BLANKET_HEADERS_ALL.ATTRIBUTE4%TYPE := NULL;


        Cursor l_attribute4_val_csr Is
        SELECT ATTRIBUTE4
        FROM OE_BLANKET_HEADERS_ALL
        WHERE HEADER_ID = P_DOC_ID;

        Cursor l_flex_value_id_csr(p_flex_value varchar2) is
        SELECT flex_value_id
		FROM fnd_flex_values_vl ffvv,okc_bus_variables_b obvb
		WHERE ffvv.flex_value_set_id = obvb.VALUE_SET_ID and
		    	obvb.VARIABLE_CODE = p_variable_code and
				ffvv.FLEX_VALUE = p_flex_value;


    BEGIN

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

	x_return_status := G_RET_STS_SUCCESS;


	OPEN l_attribute4_val_csr;
	      FETCH l_attribute4_val_csr INTO l_attribute4_val;
	CLOSE l_attribute4_val_csr;

	      IF P_VARIABLE_CODE = 'SA$DFF' AND P_DOC_TYPE = 'B' AND l_attribute4_val IS NOT NULL THEN
        	OPEN l_flex_value_id_csr(l_attribute4_val);
	           FETCH l_flex_value_id_csr INTO X_VARIABLE_VALUE_ID;
        	CLOSE l_flex_value_id_csr;
         ELSE
            X_VARIABLE_VALUE_ID := NULL;
	      END IF;


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Variable Codes along with values:');

          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
			     'Variable Code and Value' || ' ' || P_VARIABLE_CODE ||
	                     ' = ' || X_VARIABLE_VALUE_ID );

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                          '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
    END IF;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1001: Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_attribute4_val_csr%ISOPEN THEN
                CLOSE l_attribute4_val_csr;
            END IF;


            x_return_status := G_RET_STS_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded =>'F',
		                            p_count   => x_msg_count,
		                            p_data    => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1002: Unexpected Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_attribute4_val_csr%ISOPEN THEN
                CLOSE l_attribute4_val_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                               '1003: Other Error: Leaving '||G_PKG_NAME ||'.'||l_api_name);
            END IF;

            IF l_attribute4_val_csr%ISOPEN THEN
                CLOSE l_attribute4_val_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
		  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    END GET_DFF_SA;

END OKC_XPRT_CUSTOM_PACKAGE;


/
