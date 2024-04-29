--------------------------------------------------------
--  DDL for Package QP_MAINTAIN_DENORMALIZED_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MAINTAIN_DENORMALIZED_DATA" AUTHID CURRENT_USER AS
/* $Header: QPXDENOS.pls 120.0.12010000.2 2009/04/28 15:30:44 dnema ship $ */
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

  Procedure Set_HVOP_Pricing (x_return_status OUT NOCOPY VARCHAR2,
                              x_return_status_text OUT NOCOPY VARCHAR2);

  PROCEDURE Update_Qualifiers
		  (err_buff out NOCOPY VARCHAR2,
		   retcode out NOCOPY NUMBER,
		   p_List_Header_Id NUMBER deFAult null,
		   p_List_Header_Id_high NUMBER deFAult null,
		   p_update_type VARCHAR2 DEFAULT 'BATCH' ,
                   p_dummy VARCHAR2 DEFAULT null,
		   p_request_id NUMBER := NULL --bug 8359554
		   );

procedure update_pricing_phases(p_update_type IN VARCHAR2 DEFAULT 'DELAYED'
                                , p_pricing_phase_id IN NUMBER DEFAULT NULL
                                , p_automatic_flag IN VARCHAR2 DEFAULT NULL ----fix for bug 3756625
                                ,p_count IN NUMBER DEFAULT NULL
				,p_call_from IN NUMBER DEFAULT NULL
                                , x_return_status OUT NOCOPY VARCHAR2
                                , x_return_status_text OUT NOCOPY VARCHAR2);

procedure update_row_count(p_List_Header_Id_low NUMBER DEFAULT NULL
					 ,p_List_Header_Id_High NUMBER DEFAULT NULL
					 ,p_update_type VARCHAR DEFAULT 'BATCH'
					 ,x_return_status OUT NOCOPY VARCHAR2
	                                 ,x_return_status_text OUT NOCOPY VARCHAR2);

END QP_Maintain_Denormalized_Data;

/
