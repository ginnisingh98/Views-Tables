--------------------------------------------------------
--  DDL for Package PAY_WC_STATE_SURCHARGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_WC_STATE_SURCHARGES_PKG" AUTHID CURRENT_USER as
/* $Header: pywss01t.pkh 115.0 99/07/17 06:50:55 porting ship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Surcharge_Id                   IN OUT NUMBER,
                       X_State_Code                     VARCHAR2,
                       X_Add_To_Rt                      VARCHAR2,
                       X_Name                           VARCHAR2,
                       X_Position                       VARCHAR2,
                       X_Rate                           NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Surcharge_Id                     NUMBER,
                     X_State_Code                       VARCHAR2,
                     X_Add_To_Rt                        VARCHAR2,
                     X_Name                             VARCHAR2,
                     X_Position                         VARCHAR2,
                     X_Rate                             NUMBER
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Surcharge_Id                   NUMBER,
                       X_State_Code                     VARCHAR2,
                       X_Add_To_Rt                      VARCHAR2,
                       X_Name                           VARCHAR2,
                       X_Position                       VARCHAR2,
                       X_Rate                           NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

PROCEDURE check_unique (p_surcharge_id NUMBER,
			p_state_code   VARCHAR2,
			p_name         VARCHAR2,
			p_position     VARCHAR2 );

PROCEDURE check_position ( p_state_code VARCHAR2,
			   p_position   VARCHAR2,
			   p_event      VARCHAR2 );

END PAY_WC_STATE_SURCHARGES_PKG;

 

/
