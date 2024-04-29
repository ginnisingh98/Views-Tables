--------------------------------------------------------
--  DDL for Package Body WSH_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PARAMETERS_PVT" as
/* $Header: WSHUPRMB.pls 115.2 99/07/16 08:23:22 porting ship $ */

 X_ROW_FETCHED                     NUMBER := 0;
 CUR_ORGANIZATION_ID               NUMBER := 0;
 X_PLANNING_METHOD_FLAG            VARCHAR2(1);
 X_WEIGHT_UOM_CLASS                VARCHAR2(10) ;
 X_VOLUME_UOM_CLASS                VARCHAR2(10) ;
 X_INVOICE_DEL_COMPLETE_FLAG       VARCHAR2(1) ;
 X_WEIGHT_VOLUME_DPW_FLAG          VARCHAR2(1) ;
 X_WEIGHT_VOLUME_SC_FLAG           VARCHAR2(1) ;
 X_INV_CONTROLS_CONTAINER_FLAG     VARCHAR2(1) ;
 X_PERCENT_FILL_BASIS_FLAG         VARCHAR2(1) ;
 X_ENFORCE_PACKING_FLAG            VARCHAR2(1) ;
 X_DEPARTURE_REPORT_SET_ID         NUMBER ;
 X_DELIVERY_REPORT_SET_ID          NUMBER ;
 X_PICK_RELEASE_REPORT_SET_ID      NUMBER ;
 X_RELEASE_SEQ_RULE_ID             NUMBER ;
 X_PICK_SLIP_RULE_ID               NUMBER ;
 X_PRINT_PICK_SLIP_MODE            VARCHAR2(1) ;

 Procedure x_fetch_row  IS
   Cursor C (x_organization_id NUMBER) Is
     Select PLANNING_METHOD_FLAG,            WEIGHT_UOM_CLASS,
            VOLUME_UOM_CLASS,                INVOICE_DELIVERY_COMPLETE_FLAG,
	    WEIGHT_VOLUME_DPW_FLAG,          WEIGHT_VOLUME_SC_FLAG,
	    INV_CONTROLS_CONTAINER_FLAG,     PERCENT_FILL_BASIS_FLAG,
	    nvl(DEPARTURE_REPORT_SET_ID, 0), nvl(DELIVERY_REPORT_SET_ID, 0),
	    RELEASE_SEQ_RULE_ID,             PICK_SLIP_RULE_ID,
	    nvl(PRINT_PICK_SLIP_MODE,''),    PICK_RELEASE_REPORT_SET_ID,
            ENFORCE_PACKING_FLAG
     From wsh_parameters
     Where organization_id = x_organization_id;

 Begin
   OPEN C (CUR_ORGANIZATION_ID);
   FETCH C INTO
     X_PLANNING_METHOD_FLAG,        X_WEIGHT_UOM_CLASS,
     X_VOLUME_UOM_CLASS,            X_INVOICE_DEL_COMPLETE_FLAG,
     X_WEIGHT_VOLUME_DPW_FLAG,      X_WEIGHT_VOLUME_SC_FLAG,
     X_INV_CONTROLS_CONTAINER_FLAG, X_PERCENT_FILL_BASIS_FLAG,
     X_DEPARTURE_REPORT_SET_ID,     X_DELIVERY_REPORT_SET_ID,
     X_RELEASE_SEQ_RULE_ID,         X_PICK_SLIP_RULE_ID,
     X_PRINT_PICK_SLIP_MODE,        X_PICK_RELEASE_REPORT_SET_ID,
     X_ENFORCE_PACKING_FLAG;

   If (C%NOTFOUND) Then
      Close C;
      FND_MESSAGE.SET_NAME('OE','WSH_DPW_PARAM_NOT_SET');
      FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', TO_CHAR(CUR_ORGANIZATION_ID));
      APP_EXCEPTION.RAISE_EXCEPTION;
   End if;

   Close C;
 End x_fetch_row;

  --
  -- PUBLIC FUNCTIONS
  --

/*===========================================================================+
 | Name: get_param_value                                                     |
 | Purpose: To get the value of a parameter from wsh_parameters table        |
 +===========================================================================*/

  PROCEDURE get_param_value(x_organization_id IN NUMBER,
			    param_name IN VARCHAR2,
			    param_value OUT VARCHAR2) IS
  BEGIN
    if (( x_organization_id <> CUR_ORGANIZATION_ID ) OR
	( x_row_fetched = 0 )) Then
      CUR_ORGANIZATION_ID := x_organization_id;
      wsh_parameters_pvt.x_fetch_row;
      x_row_fetched := 1;
    end if;
    if ( param_name = 'PLANNING_METHOD_FLAG') Then
      param_value := X_PLANNING_METHOD_FLAG;
    elsif ( param_name = 'WEIGHT_UOM_CLASS') Then
      param_value := X_WEIGHT_UOM_CLASS;
    elsif ( param_name = 'VOLUME_UOM_CLASS') Then
      param_value := X_VOLUME_UOM_CLASS;
    elsif ( param_name = 'INVOICE_DELIVERY_COMPLETE_FLAG') Then
      param_value := X_INVOICE_DEL_COMPLETE_FLAG;
    elsif ( param_name = 'WEIGHT_VOLUME_DPW_FLAG') Then
      param_value := X_WEIGHT_VOLUME_DPW_FLAG;
    elsif ( param_name = 'WEIGHT_VOLUME_SC_FLAG') Then
      param_value := X_WEIGHT_VOLUME_SC_FLAG;
    elsif ( param_name = 'INV_CONTROLS_CONTAINER_FLAG') Then
      param_value := X_INV_CONTROLS_CONTAINER_FLAG;
    elsif ( param_name = 'PERCENT_FILL_BASIS_FLAG') Then
      param_value := X_PERCENT_FILL_BASIS_FLAG;
    elsif ( param_name = 'PRINT_PICK_SLIP_MODE') Then
      param_value := X_PRINT_PICK_SLIP_MODE;
    elsif ( param_name = 'ENFORCE_PACKING_FLAG') Then
      param_value := X_ENFORCE_PACKING_FLAG;
    end if;
  END get_param_value;

  PROCEDURE get_param_value_num(x_organization_id IN NUMBER,
			        param_name IN VARCHAR2,
			        param_value OUT NUMBER) IS
  BEGIN
    if (( x_organization_id <> CUR_ORGANIZATION_ID ) OR
	( x_row_fetched = 0 )) Then
      CUR_ORGANIZATION_ID := x_organization_id;
      wsh_parameters_pvt.x_fetch_row;
      x_row_fetched := 1;
    end if;
    if ( param_name = 'DEPARTURE_REPORT_SET_ID') Then
      param_value := X_DEPARTURE_REPORT_SET_ID;
    elsif ( param_name = 'DELIVERY_REPORT_SET_ID') Then
      param_value := X_DELIVERY_REPORT_SET_ID;
    elsif ( param_name = 'PICK_RELEASE_REPORT_SET_ID') Then
      param_value := X_PICK_RELEASE_REPORT_SET_ID;
    elsif ( param_name = 'RELEASE_SEQ_RULE_ID') Then
      param_value := X_RELEASE_SEQ_RULE_ID;
    elsif ( param_name = 'PICK_SLIP_RULE_ID') Then
      param_value := X_PICK_SLIP_RULE_ID;
    end if;
  END get_param_value_num;

END WSH_PARAMETERS_PVT;

/
