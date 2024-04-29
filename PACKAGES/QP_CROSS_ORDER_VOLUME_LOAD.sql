--------------------------------------------------------
--  DDL for Package QP_CROSS_ORDER_VOLUME_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_CROSS_ORDER_VOLUME_LOAD" AUTHID CURRENT_USER AS
/* $Header: QPXCOVLS.pls 120.3 2006/10/03 11:54:28 nirmkuma noship $ */
  -- Spec variables
  -- row who columns

    P_created_by 	NUMBER    DEFAULT FND_GLOBAL.USER_ID;
    P_creation_date  	DATE      DEFAULT SYSDATE;
    P_login_id       	NUMBER    DEFAULT FND_GLOBAL.LOGIN_ID;
    P_program_appl_id   NUMBER    DEFAULT FND_GLOBAL.PROG_APPL_ID;
    P_conc_program_id   NUMBER    DEFAULT FND_GLOBAL.CONC_PROGRAM_ID;
    P_request_id        NUMBER    DEFAULT FND_GLOBAL.CONC_REQUEST_ID;
    P_sob_id            NUMBER    ;
    P_user_id           NUMBER    DEFAULT FND_GLOBAL.USER_ID;
    err_buff		    VARCHAR2(2000);
    retcode		    NUMBER;

  PROCEDURE create_crossordvol_brk
		  (err_buff out NOCOPY /* file.sql.39 change */ VARCHAR2,
		   retcode out NOCOPY /* file.sql.39 change */ NUMBER,
		   x_org_id NUMBER,
		   x_load_effective_date VARCHAR2);

  PROCEDURE get_customer_total_amnts(x_cross_ordr_vol_perd1 	NUMBER,
                                     x_cross_ordr_vol_perd2 	NUMBER,
                                     x_cross_ordr_vol_perd3 	NUMBER,
							  x_sob_currency              VARCHAR2);

  FUNCTION get_uom_code(pitem_id NUMBER,porg_id NUMBER) RETURN VARCHAR2;

 -- PRAGMA RESTRICT_REFERENCES(get_uom_code,WNDS,WNPS);

  FUNCTION get_converted_qty(pitem_id NUMBER,porg_id NUMBER,pordr_qty NUMBER,porduom VARCHAR2) RETURN NUMBER;

  FUNCTION get_value(req_date DATE,perd_val NUMBER,p_inval NUMBER,
   p_invaltwo NUMBER) RETURN NUMBER;

  FUNCTION convert_to_base_curr(p_trans_amount NUMBER, p_from_currency VARCHAR2,
						  p_to_currency VARCHAR2, p_conversion_date DATE,
						  p_conversion_rate NUMBER, p_conversion_type VARCHAR2)
						  RETURN NUMBER;
END QP_Cross_Order_Volume_Load;

 

/
