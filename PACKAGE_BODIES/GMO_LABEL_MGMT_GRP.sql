--------------------------------------------------------
--  DDL for Package Body GMO_LABEL_MGMT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_LABEL_MGMT_GRP" AS
/* $Header: GMOGLBPB.pls 120.7.12010000.2 2008/11/12 21:15:41 srpuri ship $ */


-- Start of comments
-- API name   : PRINT_LABEL
-- Type       : Group.
-- Function   : To Initiate Label Print.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : 	p_api_version            	IN NUMBER   Required
--              	p_init_msg_list	     		IN VARCHAR2 Required
--              	P_ENTITY_NAME            	IN VARCHAR2 Required
-- 		    	P_ENTITY_KEY             	IN VARCHAR2 Required
-- 			P_WMS_BUSINESS_FLOW_CODE      IN NUMBER   Required
-- 			P_LABEL_TYPE                  IN VARCHAR2 Required
-- 			P_TRANSACTION_ID              IN VARCHAR2 Required
-- 			P_TRANSACTION_TYPE            IN NUMBER   Required
-- 			P_APPLICATION_SHORT_NAME      IN VARCHAR2 Required
-- 			P_REQUESTER                   IN NUMBER   Required
-- 			P_CONTEXT                     IN TABLE OF RECORD of type CONTEXT_TABLE
--    .
-- OUT        : 	x_return_status  OUT VARCHAR2(1)
--              	x_msg_count      OUT NUMBER
--              	x_msg_data       OUT VARCHAR2(2000)
--    .           x_Label_ID       OUT NUMBER
-- Version    : Current version 1.0
--              Initial version  1.0
--
-- End of comments

PROCEDURE PRINT_LABEL (
		p_api_version		IN 	NUMBER,
	      p_init_msg_list		IN 	VARCHAR2,
	      x_return_status		OUT 	NOCOPY VARCHAR2,
	      x_msg_count		OUT	NOCOPY NUMBER,
	     x_msg_data		OUT	NOCOPY VARCHAR2,
	     P_ENTITY_NAME 		IN	VARCHAR2,
        P_ENTITY_KEY      	IN    VARCHAR2,
        P_WMS_BUSINESS_FLOW_CODE IN NUMBER,
        P_LABEL_TYPE IN VARCHAR2,
        P_TRANSACTION_ID IN VARCHAR2,
        P_TRANSACTION_TYPE IN NUMBER,
        P_APPLICATION_SHORT_NAME IN VARCHAR2,
        P_REQUESTER IN NUMBER,
        P_CONTEXT IN GMO_LABEL_MGMT_GRP.CONTEXT_TABLE,
	  x_Label_id		OUT	NOCOPY NUMBER) IS PRAGMA AUTONOMOUS_TRANSACTION;

CURSOR C_LABEL_HISTORY_S IS
SELECT GMO_LABEL_HISTORY_S.nextval from dual;

CURSOR C_LABEL_HISTORY_DTL_S IS
SELECT GMO_LABEL_HISTORY_DTL_S.nextval from dual;

l_index number;
l_label_id number;
l_labeldtl_id number;
l_labeltype varchar2(32):='###';
l_labelstring varchar2(100);
L_CREATION_DATE                DATE;
L_CREATED_BY                   NUMBER;
L_LAST_UPDATE_DATE             DATE;
L_LAST_UPDATED_BY              NUMBER;
L_LAST_UPDATE_LOGIN            NUMBER;
l_api_version	constant number:= 1.0;
l_api_name	constant VARCHAR2(30) :='PRINT_LABEL';
l_exit boolean:=true;

BEGIN
   IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, GMO_LABEL_MGMT_GRP.G_PKG_NAME)
    THEN
    RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF FND_API.to_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /* Insert master row into GMO_LABEL_HISTORY */
      OPEN  C_LABEL_HISTORY_S;
      fetch C_LABEL_HISTORY_S into l_label_id;
      CLOSE C_LABEL_HISTORY_S;


     /* Get WHo columns */
      GMO_UTILITIEs.GET_WHO_COLUMNS(   	X_CREATION_DATE   =>L_CREATION_DATE,
 					X_CREATED_BY   =>  L_CREATED_BY,
					X_LAST_UPDATE_DATE  =>L_LAST_UPDATE_DATE,
					X_LAST_UPDATED_BY    =>L_LAST_UPDATED_BY,
					X_LAST_UPDATE_LOGIN  =>L_LAST_UPDATE_LOGIN);

      INSERT INTO GMO_LABEL_HISTORY
                  ( LABEL_ID,
 		    ENTITY_NAME,
 		    ENTITY_KEY,
 		    WMS_BUSINESSFLOW_CODE,
 		    WMS_BUSINESSFLOW_TRANS_ID,
                    TRANSACTION_TYPE,
 		    REQUESTER,
 		    REQUESTED_DATE,
 		    ERECORD_ID,
                    STATUS,
 		    CREATED_BY,
 		    CREATION_DATE,
 		    LAST_UPDATED_BY,
 		    LAST_UPDATE_DATE,
 	            LAST_UPDATE_LOGIN)
              VALUES
                    ( L_LABEL_ID,
                      P_ENTITY_NAME,
                      P_ENTITY_KEY,
                      P_WMS_BUSINESS_FLOW_CODE,
                      P_TRANSACTION_ID,
                      P_TRANSACTION_TYPE,
                      P_REQUESTER,
                      SYSDATE,
                      NULL,
                      'NEW',
                      L_CREATED_BY,
 		          L_CREATION_DATE,
 		          L_LAST_UPDATED_BY,
 		          L_LAST_UPDATE_DATE,
 	                L_LAST_UPDATE_LOGIN
                     );

   /* Resolve label type */
             /* Process the label type with comma delimiters */
             l_labelstring:=P_LABEL_TYPE;
        while l_exit
            LOOP
             if instr(L_LABELSTRING,',') = 0 then
                L_LABELTYPE:=L_LABELSTRING;
                L_EXIT:= false;
             else
                L_LABELTYPE:=substr(L_LABELSTRING,0,instr(L_LABELSTRING,',')-1) ;
             end if;
               /* Insert DTL row into GMO_LABEL_HISTORY_TL */
		      OPEN  C_LABEL_HISTORY_DTL_S;
		      fetch C_LABEL_HISTORY_DTL_S into l_labeldtl_id;
		      CLOSE C_LABEL_HISTORY_DTL_S;

                      INSERT INTO GMO_LABEL_HISTORY_DTL
                  	( 	LABEL_DTL_ID,
                                LABEL_ID,
 		    		LABEL_TYPE,
 		    		WMS_LABEL_ID,
 		    		WMS_PRINT_STATUS,
 		    		CREATED_BY,
 		    		CREATION_DATE,
 		    		LAST_UPDATED_BY,
 		    		LAST_UPDATE_DATE,
 	            		LAST_UPDATE_LOGIN)
              VALUES
                    ( L_LABELDTL_ID,
                      L_LABEL_ID,
                      L_LABELTYPE,
                      NULL,
                      NULL,
                      L_CREATED_BY,
 		      L_CREATION_DATE,
 		      L_LAST_UPDATED_BY,
 		      L_LAST_UPDATE_DATE,
 	              L_LAST_UPDATE_LOGIN
                     );
                     L_LABELSTRING:=substr(L_LABELSTRING,instr(L_LABELSTRING,',')+1);
            END LOOP;


       /* Insert the Context for display */
           for L_INDEX in 1 .. P_CONTEXT.count
              loop

                      INSERT INTO GMO_LABEL_CONTEXT_T
                  	( 	LABEL_ID,
                                CONTEXT_MESSAGE_TOKEN,
                                CONTEXT_VALUE,
                                APPLICATION_SHORT_NAME,
                                DISPLAY_SEQUENCE,
 		    		CREATED_BY,
 		    		CREATION_DATE,
 		    		LAST_UPDATED_BY,
 		    		LAST_UPDATE_DATE,
 	            		LAST_UPDATE_LOGIN)
              VALUES
                    ( L_LABEL_ID,
                      P_CONTEXT(L_INDEX).name,
                      P_CONTEXT(L_INDEX).value,
                      P_APPLICATION_SHORT_NAME,
                      P_CONTEXT(L_INDEX).display_sequence,
                      L_CREATED_BY,
 		          L_CREATION_DATE,
 		          L_LAST_UPDATED_BY,
 		          L_LAST_UPDATE_DATE,
 	                L_LAST_UPDATE_LOGIN
                     );
             end loop;

      x_Label_id:=L_LABEL_ID;

      commit;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
        ROLLBACK;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
        ROLLBACK;
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
		FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
        ROLLBACK;
END PRINT_LABEL;

-- Start of comments
-- API name   : COMPLETE_LABEL_PRINT
-- Type       : Group.
-- Function   : To Complete label printing.
-- Pre-reqs   : PRINT_LABEL should have been called earlier to this API.
-- Parameters :
-- IN         : 	p_api_version            	IN NUMBER   Required
--              	p_init_msg_list	     		IN VARCHAR2 Required
--              	P_ENTITY_NAME            	IN VARCHAR2 Required
-- 		    	P_ENTITY_KEY             	IN VARCHAR2 Required
-- 			P_LABEL_ID                    IN NUMBER   Required
-- 			P_ERECORD_ID                  IN NUMBER
-- 			P_ERECORD_STATUS              IN VARCHAR2

-- OUT        : 	x_return_status  OUT VARCHAR2(1)
--              	x_msg_count      OUT NUMBER
--              	x_msg_data       OUT VARCHAR2(2000)
--    .           x_Print_status   OUT VARCHAR2
-- Version    : Current version 1.0
--              Initial version  1.0
--
-- End of comments

PROCEDURE COMPLETE_LABEL_PRINT(
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	P_LABEL_ID 	        IN	NUMBER,
        P_ERECORD_ID            IN      NUMBER,
        P_ERECORD_STATUS        IN      VARCHAR2,
	x_print_status	        OUT	NOCOPY VARCHAR2) IS

l_label_id number;
l_wms_businessflow_code        GMO_LABEL_HISTORY.wms_businessflow_code%TYPE;
l_WMS_BUSINESSFLOW_TRANS_ID    GMO_LABEL_HISTORY.WMS_BUSINESSFLOW_TRANS_ID%TYPE;
L_TRANSACTION_TYPE             GMO_LABEL_HISTORY.TRANSACTION_TYPE%TYPE;
L_LABEL_TYPE                   GMO_LABEL_HISTORY_DTL.LABEL_TYPE%TYPE;
L_LABEL_STATUS                 GMO_LABEL_HISTORY_DTL.WMS_PRINT_STATUS%TYPE;
L_WMS_LABEL_ID                 GMO_LABEL_HISTORY_DTL.WMS_LABEL_ID%TYPE;
L_CREATION_DATE                DATE;
L_CREATED_BY                   NUMBER;
L_LAST_UPDATE_DATE             DATE;
L_LAST_UPDATED_BY              NUMBER;
L_LAST_UPDATE_LOGIN            NUMBER;
l_api_version	constant number := 1;
l_api_name	VARCHAR2(50) :='COMPLETE_LABEL_PRINT';
L_txn_id_rec    inv_label.transaction_id_rec_type;
l_input_param    inv_label.input_parameter_rec_type;

CURSOR C_LABEL_HDR is
SELECT WMS_BUSINESSFLOW_CODE,
       WMS_BUSINESSFLOW_TRANS_ID,
       TRANSACTION_TYPE
   from GMO_LABEL_HISTORY
 where LABEL_ID=p_LABEL_ID;


CURSOR C_LABEL_DTL IS
select LABEL_TYPE from GMO_LABEL_HISTORY_DTL
       where label_id=P_LABEL_ID;
BEGIN
    IF NOT fnd_api.Compatible_API_Call (p_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN
            RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          GMO_UTILITIEs.GET_WHO_COLUMNS(X_CREATION_DATE   =>L_CREATION_DATE,
 					X_CREATED_BY   =>  L_CREATED_BY,
					X_LAST_UPDATE_DATE  =>L_LAST_UPDATE_DATE,
					X_LAST_UPDATED_BY    =>L_LAST_UPDATED_BY,
					X_LAST_UPDATE_LOGIN  =>L_LAST_UPDATE_LOGIN);


    If (P_ERECORD_ID is NULL and P_ERECORD_STATUS is NULL) or (P_ERECORD_STATUS in ('SUCCESS','NOACTION')) then
        OPEN C_LABEL_HDR;
        FETCH C_LABEL_HDR into L_WMS_BUSINESSFLOW_CODE,
                               L_WMS_BUSINESSFLOW_TRANS_ID,
                               L_TRANSACTION_TYPE ;
        CLOSE C_LABEL_HDR;
        /* Convert incomming paramter to inv_label record structure */
        L_txn_id_rec(1):=L_WMS_BUSINESSFLOW_TRANS_ID;
        OPEN C_LABEL_DTL;
        LOOP
         FETCH C_LABEL_DTL into L_LABEL_TYPE;
         EXIT when C_LABEL_DTL%NOTFOUND;

        /*Call INV_LABEL_API for each Business Flow */
          INV_LABEL.PRINT_LABEL
                    (
 			X_RETURN_STATUS       =>X_RETURN_STATUS,
 			X_MSG_COUNT           =>X_MSG_COUNT,
 			X_MSG_DATA            =>X_MSG_DATA,
 			X_LABEL_STATUS        =>L_LABEL_STATUS,
 			X_LABEL_REQUEST_ID    =>L_WMS_LABEL_ID,
 			P_API_VERSION         =>1.0,
 			P_PRINT_MODE          =>1,
                        p_input_param_rec   => l_input_param,
      			P_BUSINESS_FLOW_CODE  => L_WMS_BUSINESSFLOW_CODE,
 			P_TRANSACTION_ID      => L_txn_id_rec,
 			P_LABEL_TYPE_ID       => L_LABEL_TYPE,
 			P_TRANSACTION_IDENTIFIER =>  L_TRANSACTION_TYPE,
                        P_NO_OF_COPIES=>1,
                        P_FORMAT_ID=>NULL);


                     Update GMO_LABEL_HISTORY_DTL
                        set WMS_PRINT_STATUS=decode(X_RETURN_STATUS,'S','SUCCESS','FAILURE'),
                            WMS_LABEL_ID=L_WMS_LABEL_ID
                        where
                            label_id=P_LABEL_ID and
                            Label_type=L_LABEL_TYPE;


       END LOOP;
       CLOSE C_LABEL_DTL;
          UPDATE GMO_LABEL_HISTORY set
                           ERECORD_ID=P_ERECORD_ID,
                           STATUS='COMPLETE',
                           LAST_UPDATE_DATE=L_LAST_UPDATE_DATE,
                           LAST_UPDATED_BY = L_LAST_UPDATED_BY,
                           LAST_UPDATE_LOGIN=L_LAST_UPDATE_LOGIN
                     where
                          label_id=P_LABEL_ID;
  x_print_status:='SUCCESS';

   ELSE
   BEGIN
    If (P_ERECORD_ID is NULL and P_ERECORD_STATUS is NULL) then
         L_LABEL_STATUS := 'CANCEL';
    else
         L_LABEL_STATUS := P_ERECORD_STATUS;
    end if;

          UPDATE GMO_LABEL_HISTORY set
                           ERECORD_ID=P_ERECORD_ID,
                           STATUS=L_LABEL_STATUS,
                           LAST_UPDATE_DATE=L_LAST_UPDATE_DATE,
                           LAST_UPDATED_BY = L_LAST_UPDATED_BY,
                           LAST_UPDATE_LOGIN=L_LAST_UPDATE_LOGIN
                     where
                          label_id=P_LABEL_ID;

                    Update GMO_LABEL_HISTORY_DTL
                        set WMS_PRINT_STATUS=L_LABEL_STATUS,
                            WMS_LABEL_ID=NULL
                        where
                            label_id=P_LABEL_ID;

    END;
  x_print_status:= L_LABEL_STATUS;
  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
      x_print_status:='ERROR';
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
      x_print_status:='ERROR';
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
       x_print_status:='ERROR';
END;

-- Start of comments
-- API name   : CANCEL_LABEL_PRINT
-- Type       : Group.
-- Function   : To Cancel label printing.
-- Pre-reqs   : PRINT_LABEL should have been called earlier to this API.
-- Parameters :
-- IN         : 	p_api_version            	IN NUMBER   Required
--              	p_init_msg_list	     		IN VARCHAR2 Required
--              	P_ENTITY_NAME            	IN VARCHAR2 Required
-- 		    	P_ENTITY_KEY             	IN VARCHAR2 Required
-- 			P_LABEL_ID                    IN NUMBER   Required

-- OUT        : 	x_return_status  OUT VARCHAR2(1)
--              	x_msg_count      OUT NUMBER
--              	x_msg_data       OUT VARCHAR2(2000)
-- Version    : Current version 1.0
--              Initial version  1.0
--
-- End of comments

PROCEDURE CANCEL_LABEL_PRINT(
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	P_LABEL_ID 	        IN	NUMBER
        ) IS

l_label_id number;
L_CREATION_DATE                DATE;
L_CREATED_BY                   NUMBER;
L_LAST_UPDATE_DATE             DATE;
L_LAST_UPDATED_BY              NUMBER;
L_LAST_UPDATE_LOGIN            NUMBER;
l_api_version	constant number:= 1.0;
l_api_name	VARCHAR2(50) :='CANCEL_LABEL';

BEGIN
  IF NOT fnd_api.Compatible_API_Call ( p_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          GMO_UTILITIEs.GET_WHO_COLUMNS(X_CREATION_DATE   =>L_CREATION_DATE,
 					X_CREATED_BY   =>  L_CREATED_BY,
					X_LAST_UPDATE_DATE  =>L_LAST_UPDATE_DATE,
					X_LAST_UPDATED_BY    =>L_LAST_UPDATED_BY,
					X_LAST_UPDATE_LOGIN  =>L_LAST_UPDATE_LOGIN);

     UPDATE GMO_LABEL_HISTORY set
                           STATUS='CANCEL',
                           LAST_UPDATE_DATE=L_LAST_UPDATE_DATE,
                           LAST_UPDATED_BY = L_LAST_UPDATED_BY,
                           LAST_UPDATE_LOGIN=L_LAST_UPDATE_LOGIN
                     where
                          label_id=P_LABEL_ID;

                    Update GMO_LABEL_HISTORY_DTL
                        set WMS_PRINT_STATUS='CANCEL',
                            WMS_LABEL_ID=NULL
                        where
                            label_id=P_LABEL_ID;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

END;

-- Start of comments
-- API name   : AUTO_PRINT_ENABLED
-- Type       : Group.
-- Function   : Determines if auto matic label printing is enabled or not.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : 	None

-- OUT        : 	Boolean true or false
-- Version    : None
--
-- End of comments

FUNCTION AUTO_PRINT_ENABLED return boolean Is
L_VALUE VARCHAR2(32);
BEGIN

FND_PROFILE.GET(NAME=>'GMO_LABEL_PRINT_MODE',VAL=>L_VALUE);
if l_value ='AUTOMATIC' then
 return TRUE;
else
 return false;
end if;
END;

-- Start of comments
-- API name   : GET_PRINT_COUNT
-- Type       : Group.
-- Function   : Returns the no of labels printed for the given input parameters.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : 	p_api_version            	IN NUMBER   Required
--              	p_init_msg_list	     		IN VARCHAR2 Required
-- 			P_WMS_BUSINESS_FLOW_CODE      IN NUMBER   Required
-- 			P_LABEL_TYPE                  IN VARCHAR2 Required
-- 			P_TRANSACTION_ID              IN VARCHAR2 Required
-- 			P_TRANSACTION_TYPE            IN NUMBER   Required
--    .
-- OUT        : 	x_return_status  OUT VARCHAR2(1)
--              	x_msg_count      OUT NUMBER
--              	x_msg_data       OUT VARCHAR2(2000)
--    .           x_print_count    OUT NUMBER
-- Version    : Current version 1.0
--              Initial version  1.0
--
-- End of comments

PROCEDURE GET_PRINT_COUNT(
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	P_WMS_BUSINESS_FLOW_CODE IN NUMBER,
      P_LABEL_TYPE IN NUMBER,
      P_TRANSACTION_ID IN VARCHAR2,
      P_TRANSACTION_TYPE IN VARCHAR2,
      x_print_count	OUT	NOCOPY NUMBER) IS

l_api_version	constant number:= 1.0;
l_api_name	VARCHAR2(50) :='GET_PRINT_COUNT';

BEGIN
  IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;
         Select Count(*) into x_print_count
         --Bug 4912228: Start
	 From GMO_LABEL_HISTORY A, GMO_LABEL_HISTORY_DTL B
	 --Bug 4912228: End
         Where A.LABEL_ID=B.LABEL_ID
	 --Bug 5146629: start
         and B.WMS_PRINT_STATUS = 'SUCCESS'
	 and B.WMS_LABEL_ID is not null
         and A.WMS_BUSINESSFLOW_CODE=P_WMS_BUSINESS_FLOW_CODE
	 and (A.TRANSACTION_TYPE=P_TRANSACTION_TYPE or A.TRANSACTION_TYPE is null)
	 --Bug 5146629: end
         and A.WMS_BUSINESSFLOW_TRANS_ID=P_TRANSACTION_ID
         and B.LABEL_TYPE=P_LABEL_TYPE;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

END;

end GMO_LABEL_MGMT_GRP;

/
