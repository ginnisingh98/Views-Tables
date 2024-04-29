--------------------------------------------------------
--  DDL for Package INV_PICK_WAVE_PICK_CONFIRM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PICK_WAVE_PICK_CONFIRM_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPCPWS.pls 115.8 2004/02/07 00:42:52 yssingh ship $ */

-- Glbal constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_Pick_Wave_Pick_Confirm_PUB';

--  Forward declaration of Procedure Id_To_Value

PROCEDURE Pick_Confirm
(
    p_api_version_number	    IN  NUMBER
,   p_init_msg_list	 	    IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit			    IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status		    OUT NOCOPY VARCHAR2
,   x_msg_count			    OUT NOCOPY NUMBER
,   x_msg_data			    OUT NOCOPY VARCHAR2
,   p_move_order_type               IN  NUMBER
,   p_transaction_mode		    IN  NUMBER
,   p_trolin_tbl                    IN  INV_Move_Order_PUB.Trolin_Tbl_Type
,   p_mold_tbl			    IN  INV_MO_LINE_DETAIL_UTIL.g_mmtt_tbl_type
,   x_mmtt_tbl      	            IN OUT NOCOPY INV_MO_LINE_DETAIL_UTIL.g_mmtt_tbl_type
,   x_trolin_tbl                    IN OUT NOCOPY INV_Move_Order_PUB.Trolin_Tbl_Type
,   p_transaction_date              IN DATE DEFAULT NULL
);

Function INV_TM_Launch( program in varchar2,
                         args in varchar2 default NULL,
                         put1 in varchar2 default NULL,
                         put2 in varchar2 default NULL,
                         put3 in varchar2 default NULL,
                         put4 in varchar2 default NULL,
                         put5 in varchar2 default NULL,
                         get1 in varchar2 default NULL,
                         get2 in varchar2 default NULL,
                         get3 in varchar2 default NULL,
                         get4 in varchar2 default NULL,
                         get5 in varchar2 default NULL,
                         timeout in number default NULL,
                         rtval out NOCOPY NUMBER) return BOOLEAN;

Procedure TraceLog(err_msg IN VARCHAR2, module IN VARCHAR2, p_level IN NUMBER := 9);

END INV_Pick_Wave_Pick_Confirm_PUB;

 

/
