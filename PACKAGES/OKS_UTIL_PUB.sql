--------------------------------------------------------
--  DDL for Package OKS_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSUTPRS.pls 120.3 2006/03/13 16:46:20 jakuruvi noship $ */

 G_PRODUCT_STATUS VARCHAR2(30)  := FND_API.G_MISS_CHAR;
 G_VALIDATE_FLAG 	boolean :=TRUE;
 G_UNEXPECTED_ERROR          		CONSTANT VARCHAR2(200) := 'OKS_RENEW_UNEXPECTED_ERROR';
 G_EXPECTED_ERROR          		CONSTANT VARCHAR2(200) := 'OKS_RENEW_ERROR';
 G_SQLCODE_TOKEN              		CONSTANT VARCHAR2(200) := 'SQLcode';
 G_SQLERRM_TOKEN              		CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_EXCEPTION_HALT_VALIDATION 	EXCEPTION;
 G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

 G_APP_ID                      CONSTANT NUMBER        := 515;
 G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'OKS_UTIL_PUB';

  PROCEDURE get_valueset_id(p_flexfield_name In varchar2,
					        p_context IN  VARCHAR2 ,
                            p_seg  IN  VARCHAR2 ,
				            x_vsid  OUT NOCOPY number,
					        x_format_type  OUT NOCOPY varchar2,
                            x_validation_type OUT NOCOPY VARCHAR2
  						 );
 PROCEDURE validate_oks_flexfield(flexfield_name        IN     VARCHAR2,
                                 context                IN     VARCHAR2,
                                 attribute              IN     VARCHAR2,
                                 value                  IN     VARCHAR2,
                                 application_short_name IN     VARCHAR2,
                                 context_flag           OUT NOCOPY VARCHAR2,
                                 attribute_flag         OUT NOCOPY VARCHAR2,
                                 value_flag             OUT NOCOPY VARCHAR2,
                                 datatype               OUT NOCOPY VARCHAR2,
                                 precedence   	        OUT NOCOPY VARCHAR2,
                                 error_code    	        OUT NOCOPY NUMBER ,
                                 check_enabled          IN     BOOLEAN := TRUE);

FUNCTION value_exists_in_table(p_table_r  fnd_vset.table_r,
							p_value       VARCHAR2,
							x_id	   OUT NOCOPY  VARCHAR2,
							x_value OUT NOCOPY  VARCHAR2) RETURN BOOLEAN;

    FUNCTION Get_OKS_Status
    RETURN VARCHAR2;

FUNCTION Resp_Org_id RETURN NUMBER;

PROCEDURE UPDATE_CONTACTS_SALESGROUP
   ( ERRBUF            OUT      NOCOPY VARCHAR2,
     RETCODE           OUT      NOCOPY NUMBER,
     P_CONTRACT_ID     IN              NUMBER,
     P_GROUP_ID        IN              NUMBER);

FUNCTION get_line_name( p_lty_code IN VARCHAR2,
                        p_object1_id1 IN VARCHAR2,
                        p_object1_id2 IN VARCHAR2 ) RETURN VARCHAR2;

FUNCTION get_line_name( p_subline_id IN NUMBER ) RETURN VARCHAR2;

Procedure create_transaction_extension(P_Api_Version IN NUMBER
                                      ,P_Init_Msg_List IN VARCHAR2
                                      ,P_Header_ID IN NUMBER
                                      ,P_Line_ID IN NUMBER
                                      ,P_Source_Trx_Ext_ID IN NUMBER
                                      ,P_Cust_Acct_ID IN NUMBER
                                      ,P_Bill_To_Site_Use_ID IN NUMBER
                                      ,x_entity_id OUT NOCOPY NUMBER
                                      ,x_msg_data OUT NOCOPY VARCHAR2
                                      ,x_msg_count OUT NOCOPY NUMBER
                                      ,x_return_status OUT NOCOPY VARCHAR2);

END; -- Package Specification OKS_UTIL

 

/
