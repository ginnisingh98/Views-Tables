--------------------------------------------------------
--  DDL for Package OE_OE_FORM_CANCEL_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_FORM_CANCEL_LINE" AUTHID CURRENT_USER AS
/* $Header: OEXFCANS.pls 120.1 2005/06/22 11:24:19 appldev ship $ */

--  Start of Comments
--  API name    Process_Order
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

G_PKG_NAME         VARCHAR2(30) := 'OE_OE_FORM_CANCEL_LINE';
COMMIT_EXIT_ON_ERROR        NUMBER := 1;
ROLLBACK_EXIT_ON_ERROR      NUMBER := 2;
COMMIT_SHOW_ERROR           NUMBER := 3;
ASK_COMMIT                  NUMBER := 4;
IS_MASS_CHANGE          VARCHAR2(1) := 'F';
/* Added for bug 2965878 */
g_record_ids   OE_GLOBALS.Selected_Record_Tbl;
g_num_of_records  NUMBER:=0;
g_ord_lvl_can boolean :=FALSE;-- For bug# 2922468.
procedure Process_cancel_quantity
(    p_num_of_records       IN NUMBER
    ,p_record_ids           IN OE_GLOBALS.Selected_Record_Tbl -- MOAC
    ,p_cancel_to_quantity   IN NUMBER
    ,p_cancellation_comments IN VARCHAR2
    ,p_reason_code          IN VARCHAR2
    ,p_cancellation_type    IN VARCHAR2
    ,p_mc_err_handling_flag IN NUMBER := FND_API.G_MISS_NUM
    ,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
    ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
    ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
    ,x_error_count          OUT NOCOPY /* file.sql.39 change */ NUMBER);


procedure Process_cancel_order
(    p_num_of_records       IN NUMBER
    ,p_record_ids           IN OE_GLOBALS.Selected_Record_Tbl -- MOAC
    ,p_cancellation_comments IN VARCHAR2
    ,p_reason_code          IN VARCHAR2
    ,p_mc_err_handling_flag IN NUMBER := FND_API.G_MISS_NUM
    ,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
    ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
    ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
    ,x_error_count          OUT NOCOPY /* file.sql.39 change */ NUMBER);

-- Fix for bug 2259556.We pass p_num_of_records and p_record_ids as IN parameters
Procedure Cancel_Remaining_Order(p_num_of_records IN NUMBER,
                p_record_ids IN OE_GLOBALS.Selected_Record_Tbl, -- MOAC
		 x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    		p_cancellation_comments IN VARCHAR2,
    		p_reason_code          IN VARCHAR2,
    	      x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
		 x_msg_data OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Call_Process_Order ( p_line_tbl IN OE_ORDER_PUB.LINE_TBL_TYPE,
                               p_old_line_tbl IN OE_ORDER_PUB.LINE_TBL_TYPE,
                                x_return_status  OUT NOCOPY VARCHAR2);

END OE_OE_FORM_CANCEL_LINE;

 

/
