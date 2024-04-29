--------------------------------------------------------
--  DDL for Package XTR_IMPORT_DEAL_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_IMPORT_DEAL_DATA" AUTHID CURRENT_USER AS
/* $Header: xtrimdds.pls 120.4 2005/06/29 08:34:39 badiredd ship $*/


Procedure Transfer_Deals(	ERRBUF			Out NOCOPY	Varchar2,
				RETCODE			Out NOCOPY	Varchar2,
				P_Company_Code     	In	Varchar2,
				P_Deal_Type        	In	Varchar2,
               			P_Ext_Deal_Id_From 	In 	Varchar2,
               			P_Ext_Deal_Id_To   	In 	Varchar2,
               			P_Load_Status           In 	Varchar2,
               			P_Source           	In 	Varchar2
               			) ;

Procedure Translate_Deal_Details( deal_type In Varchar2,
                                  ARec In Out NOCOPY xtr_deals_interface%rowtype);

Procedure Translate_Deal_Details_UI(p_external_deal_id xtr_deals_interface.external_deal_id%type,
                                    p_user_deal_type   xtr_deals_interface.deal_type%type);

Procedure Log_Interface_Errors(AExt_Deal_Id In Varchar2,
                               ADeal_Type Varchar2,
                               Error_Column In Varchar2,
                               Error_Code in Varchar2,
                               Transaction_No in Number Default Null);

Procedure Log_Deal_Warning(p_warning_message  In Varchar2);

Procedure log_successful_deal(Deal_Type    IN VARCHAR2,
                                  Deal_Number  IN NUMBER,
                                  Deal_Subtype IN VARCHAR2,
                                  Product_Type IN VARCHAR2,
                                  Company_Code IN VARCHAR2,
                                  Cparty_Code  IN VARCHAR2,
                                  Currency     IN VARCHAR2,
                                  Amount       IN NUMBER);

Procedure log_failed_deal(Deal_Type         IN VARCHAR2,
                              External_Deal_Id  IN VARCHAR2,
                              Deal_Subtype      IN VARCHAR2,
                              Product_Type      IN VARCHAR2,
                              Company_Code      IN VARCHAR2,
                              Cparty_Code       IN VARCHAR2,
                              Currency          IN VARCHAR2,
                              Amount            IN NUMBER);

procedure CHECK_DEAL_DUPLICATE_ID(p_external_deal_id IN VARCHAR2,
                                  p_external_deal_type IN  VARCHAR2,
                                  p_deal_type        IN VARCHAR2,
                                  error                OUT NOCOPY BOOLEAN);

Procedure Put_Log(Avr_Buff In Varchar2);

PROCEDURE CHECK_USER_AUTH(p_external_deal_id IN VARCHAR2,
                          p_deal_type        IN VARCHAR2,
                          p_company_code     IN VARCHAR2,
                          error              OUT NOCOPY BOOLEAN);


  --* Public Variables
  type message_list_type is table of varchar2(4000) index by binary_integer;
  G_current_deal_log_list message_list_type;
  G_failure_log_list message_list_type;

  G_Total_Success_Recs		Number Default 0;
  G_Total_Failure_Recs		Number Default 0;
  G_Control_Total		Number Default 0;
  G_Total_Record_Scanned	Number Default 0;
  G_Has_Warnings                Boolean Default false;
  G_DFF_Error_Column		Varchar2(80);

FUNCTION val_desc_flex( p_Interface_Rec    IN XTR_DEALS_INTERFACE%ROWTYPE,
                        p_desc_flex        IN VARCHAR2,
                        p_error_segment    IN OUT NOCOPY VARCHAR2) return BOOLEAN;

FUNCTION val_transaction_desc_flex( p_Interface_Rec    IN XTR_TRANSACTIONS_INTERFACE%ROWTYPE,
                          p_desc_flex        IN VARCHAR2,
                          p_error_segment    IN OUT NOCOPY VARCHAR2) return BOOLEAN;
END;

 

/
